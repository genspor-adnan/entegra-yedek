using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RADYOLOJİ RAPORU (283/284) - kart sözleşmesine sığmayan ekran.
///
/// Rapor bölümleri ŞABLONDAN üretilir, metinleri hekim yazar; onay iki
/// aşamalıdır (asistan ön rapor → uzman onay) ve onaydan sonra rapor
/// KİLİTLENİR. Bu akış generic kartın "alanları oku/yaz" modeline sığmadığı
/// için kendi uçları var.
/// </summary>
public static class RadyolojiUclari
{
    /// <summary>islem_log.tablo_id - rapor.</summary>
    private const int LogTabloRapor = 941;

    public sealed record BolumIstegi(int? Id, int Sira, string Baslik, string Metin, short Yazdir);
    public sealed record AlanIstegi(string AlanKod, string AlanAd, string Deger);
    public sealed record RaporIstegi(int? SablonId, IReadOnlyList<BolumIstegi>? Bolumler,
                                     IReadOnlyList<AlanIstegi>? Alanlar, short? Kritik);
    public sealed record KritikIstegi(string Bulgu, string BildirilenAd, short Yol,
                                      string GeriBildirim);

    /// <summary>SONUC TESLIMI (304): film/CD/basili rapor kime verildi.</summary>
    public sealed record TeslimIstegi(short Tur, string AlanAd, string AlanYakinlik,
                                      short KimlikDogrulandi, string Aciklama);

    /// <summary>
    /// KONSULTASYON (304): ikinci gorus. Istek ve DONEN GORUS ayni ucu kullanir -
    /// gorus dolu gelirse kayit "donmus" sayilir.
    /// </summary>
    public sealed record KonsultasyonIstegi(int? HekimId, int? KurumId, string Gerekce,
                                            string? Gorus);

    /// <summary>islem_log.tablo_id - istem.</summary>
    private const int LogTabloIstem = 940;

    /// <summary>
    /// ISTEM OLUSTURMA (304). Bir seferde COK TETKIK secilir - her biri ayri
    /// istem (ayri accession no) olur; hasta bir kez yazilir, klinik bilgi
    /// hepsine gecer.
    /// </summary>
    public sealed record TetkikIstegi(int HizmetId, short? Oncelik, short? Kontrast);
    public sealed record IstemIstegi(
        int HastaId, int? BelgeId, int? IstekHekimId, string? DisHekimAd,
        int? IstekKurumId, string? OnTani, string? KlinikBilgi, short? Oncelik,
        /// <summary>Basvuruya UCRET SATIRI da eklensin mi (mockup: tetkik secilince tutar cikar).</summary>
        bool UcretEkle,
        IReadOnlyList<TetkikIstegi> Tetkikler,
        /// <summary>
        /// KABUL EKRANI (mockup radyoloji_kayit_kabul.html): disaridan gelen
        /// hastanin basvurusu YOKTUR - istemle birlikte acilir. Basvuru
        /// acilmadan ucret satiri yazilacak bir belge de olmaz; iki kayit tek
        /// islemde uretilir, aksi halde "istemi actim ama ucreti yok" durumu
        /// kalirdi.
        /// </summary>
        bool BasvuruAc = false,
        /// <summary>Basvuru acilirken odeyen kurum (249) - fiyat ve pay bolusumu buna bagli.</summary>
        int? OdeyenKurumId = null,
        /// <summary>Ozel sigorta police no - basvuru provizyon uzantisina yazilir (299).</summary>
        string? PoliceNo = null,
        /// <summary>
        /// KABUL SONRASI (311, mockup sag alt kutusu): cihaz listesine gonder,
        /// randevu SMS'i, hazirlik talimati, sonuc CD'si. MWL ve SMS
        /// entegrasyonlari yok - secim ISTEK olarak kayda gecer.
        /// </summary>
        short? MwlIstendi = null, short? SmsIstendi = null,
        short? HazirlikVerildi = null, short? CdIstendi = null);

    /// <summary>Cekim oncesi kontrol listesi yaniti (310).</summary>
    public sealed record KontrolYaniti(int SoruId, string Yanit);
    public sealed record KontrolIstegi(IReadOnlyList<KontrolYaniti> Yanitlar);

    public static void RadyolojiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/radyoloji").WithTags("Radyoloji").RequireAuthorization();

        // ------------------------------------------- istem ekranı verisi ----
        // Tetkik ağacı (modalite > tetkik), isteyen hekim adayları ve hastanın
        //   SON 12 AYDA aynı tetkiği çekilip çekilmediği tek istekte gelir -
        //   mükerrer tetkik uyarısı (mockup) bu listeden çıkar.
        grup.MapGet("/istem-secenekleri", async (
            int? hastaId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            // HAZIRLIK TALIMATI (311): tetkikin KENDI protokolu varsa o, yoksa
            //   modalite varsayilani (kod listesi rad.hazirlik) - kabul masasi
            //   hastaya ne soyleyecegini ekranda gormeli.
            var tetkikler = await baglanti.ListeAsync("""
                select t.id, t.kod, t.ad, t.modalite,
                       coalesce(t.modalite_adi, '') as "modaliteAdi", t.kdv,
                       coalesce(nullif(p.hazirlik_metni, ''), kd.ad, '') as hazirlik,
                       -- PERSONELE uyari (314): gebelik/metal/kreatinin gibi cekim
                       --   oncesi sorulacaklar; hastaya verilen hazirliktan ayridir.
                       coalesce(p.ozel_uyari, '') as "ozelUyari",
                       coalesce(p.kontrast, 0) as "varsayilanKontrast",
                       coalesce(p.sure_dk, 0) as "sureDk"
                  from public.v_radyoloji_tetkik t
                  left join public.radyoloji_protokol p on p.hizmet_id = t.id
                  left join public.kod_liste kl on kl.kod = 'rad.hazirlik'
                  left join public.kod_deger kd on kd.liste_id = kl.id
                                               and kd.deger = t.modalite
                 order by t.modalite, t.ad
                """, null, [], Satir, iptal);

            // Bolum ve "randevu verilebilir" bayragi TARAF tablosunda
            //   (taraf.departman departman tablosuna isaret eder, 251) -
            //   taraf_personel yalniz ozluk bilgisini tasir.
            var hekimler = await baglanti.ListeAsync("""
                select t.id, t.unvan as ad, coalesce(d.ad, '') as "bolumAdi"
                  from public.taraf t
                  left join public.departman d on d.id = t.departman
                 where coalesce(t.personel, 0) = 1
                   and coalesce(t.randevu_verilebilir, 0) = 1
                   and coalesce(t.durum, 1) = 1
                 order by t.unvan
                """, null, [], Satir, iptal);

            // KAYITLI DIS HEKIMLER (305): dis istemde artik serbest metin yerine
            //   listeden secilir - "kim kac hasta gonderdi" sorusu ancak
            //   istek_hekim_id dolduysa cevaplanabiliyor.
            var disHekimler = await baglanti.ListeAsync("""
                select id, ad, kurum, brans from public.v_dis_hekim_lookup order by ad
                """, null, [], Satir, iptal);

            // Son 12 ay: aynı tetkik tekrar isteniyorsa hekim gerekçelendirsin.
            var gecmis = hastaId is null || hastaId <= 0
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select i.hizmet_id as "hizmetId", coalesce(hz.ad, '') as "tetkikAdi",
                           max(coalesce(i.cekim_tarihi, i.ekleme_tarihi)) as tarih
                      from public.radyoloji_istem i
                      left join public.hizmet hz on hz.id = i.hizmet_id
                     where i.hasta_id = @p0 and i.durum > 0
                       and coalesce(i.cekim_tarihi, i.ekleme_tarihi)
                           >= (current_date - interval '12 months')
                     group by i.hizmet_id, hz.ad
                    """, null, [hastaId.Value], Satir, iptal);

            return Results.Ok(new { tetkikler, hekimler, disHekimler, gecmis });
        });

        // ------------------------------------- dış hekim gönderim özeti ----
        // Hekim kartinin "Gönderim Geçmişi" sekmesindeki ozet kutular ve
        //   modalite dagilimi (mockup dis_doktor_karti.html). Grid zaten
        //   satirlari gosteriyor; buradaki soru "ne kadar, ne zaman, hangi
        //   cihazda" - satirlari istemcide toplamak sayfalama yuzunden
        //   yanlis sonuc verirdi.
        grup.MapGet("/hekim/{id:int}/ozet", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var ozet = await baglanti.TekAsync("""
                select count(*) as toplam,
                       count(*) filter (
                           where coalesce(i.cekim_tarihi, i.ekleme_tarihi)
                                 >= date_trunc('month', current_date)) as "buAy",
                       count(*) filter (where i.durum = 5) as raporlanan,
                       count(*) filter (where i.durum between 1 and 4) as bekleyen,
                       coalesce(sum(s.tutar), 0) as tutar,
                       max(coalesce(i.cekim_tarihi, i.ekleme_tarihi)) as "sonGonderim"
                  from public.radyoloji_istem i
                  left join public.belge_satir s on s.id = i.belge_satir_id
                 where i.istek_hekim_id = @p0 and i.durum > 0
                """, null, [id], Satir, iptal);

            // Modalite dagilimi: hangi cihaz bu hekim icin kritik - MR
            //   kapasitesi planlanirken en cok gonderen hekimler buradan okunur.
            var dagilim = await baglanti.ListeAsync("""
                select coalesce(kd.ad, 'Diğer') as ad, count(*) as adet
                  from public.radyoloji_istem i
                  left join public.kod_liste kl on kl.kod = 'rad.modalite'
                  left join public.kod_deger kd on kd.liste_id = kl.id
                                               and kd.deger = i.modalite
                 where i.istek_hekim_id = @p0 and i.durum > 0
                 group by coalesce(kd.ad, 'Diğer')
                 order by count(*) desc
                """, null, [id], Satir, iptal);

            return Results.Ok(new { ozet, dagilim });
        });

        // --------------------------------------------------- istem açma ----
        // Mockup: radyoloji_hekim_istem.html (iç istem) ve
        //   radyoloji_kayit_kabul.html (dış istem). İKİSİ AYNI UÇ: fark yalnız
        //   isteyenin kim olduğu (iç hekim / dış hekim + kurum) - akış, ücret
        //   ve accession üretimi aynıdır, iki uç yazmak ikisini ayrıştırırdı.
        //
        // Her tetkik AYRI istem olur: PACS ve raporlama accession bazlıdır,
        //   iki tetkiği tek isteme koymak raporu da tek yapardı.
        grup.MapPost("/istem", async (
            IstemIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.istem_ac");

            if (istek.Tetkikler is null || istek.Tetkikler.Count == 0)
                throw GentegreHatasi.Dogrulama("En az bir tetkik seçilmeli.",
                    new AlanHatasi("tetkikler", "Boş bırakılamaz."));
            if (istek.HastaId <= 0)
                throw GentegreHatasi.Dogrulama("Hasta seçilmeli.",
                    new AlanHatasi("hastaId", "Zorunlu."));
            // Klinik bilgi ZORUNLU (mockup): boş istem radyoloğa "neden çekildi"
            //   sorusunu bırakır ve raporun Klinik Bilgi bölümü boş kalır.
            if (string.IsNullOrWhiteSpace(istek.KlinikBilgi))
                throw GentegreHatasi.Dogrulama("Klinik bilgi / istem gerekçesi yazılmalı.",
                    new AlanHatasi("klinikBilgi", "Zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);
            var basvuruUyarilari = new List<string>();

            // ------------------------------------------------ BASVURU ACMA ----
            // Kabul ekraninda (radyoloji_kayit_kabul.html) hasta disaridan gelir:
            //   ortada bir basvuru yoktur. Basvuruyu ISTEMDEN ONCE aciyoruz -
            //   istem satirlari belge_id tasimali, sonradan baglamak "ucretsiz
            //   kalmis istem" penceresi acardi.
            var belgeId = istek.BelgeId is int bid && bid > 0 ? bid : (int?)null;
            var yazma = new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip);
            if (belgeId is null && istek.BasvuruAc)
            {
                var hasta = await baglanti.TekAsync("""
                    select coalesce(unvan, '') as unvan, coalesce(vkno, '') as vkno,
                           coalesce(vd, '') as vd
                      from public.taraf where id = @p0
                    """, null, [istek.HastaId], Satir, iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");

                // Fiyat listesi belgenin KIMLIGIDIR (274/302): kampanya ->
                //   sozlesme -> cari -> varsayilan sirasi tek yerde (fn)
                //   cozulur; burada ikinci bir sira kurmak ikisinin sapmasi olur.
                var listeId = await baglanti.TekDegerAsync<int?>("""
                    select public.fn_belge_varsayilan_liste(@p0, 19::smallint, current_date, @p1)
                    """, null, [istek.HastaId, istek.OdeyenKurumId], iptal);

                // KAMPANYA (274) belgenin KIMLIGIDIR: liste BAZ fiyati, kampanya
                //   INDIRIMI verir. Basliga yazilmazsa "bu tutar hangi anlasmayla
                //   olustu" izi kaybolur ve sonradan eklenen kalem indirimsiz
                //   fiyatlanir (ayni belgede iki fiyat politikasi).
                var kampanyaId = await baglanti.TekDegerAsync<int?>("""
                    select public.fn_taraf_kampanya(coalesce(@p1, @p0), current_date)
                    """, null, [istek.HastaId, istek.OdeyenKurumId], iptal);

                var basvuru = new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = 19,
                    // 30 = Hasta Basvurusu (301) - ayni turun siparisinden ayirir.
                    ["tipi"] = 30,
                    ["tarafId"] = istek.HastaId,
                    ["tarafUnvan"] = hasta["unvan"],
                    ["tarafVkno"] = hasta["vkno"],
                    ["tarafVd"] = hasta["vd"],
                    ["belgeTarihi"] = DateTime.Now,
                    ["belgeDovizi"] = "TL",
                    ["dovizKuru"] = 1m,
                    ["fiyatListesiId"] = listeId,
                    ["kampanyaId"] = kampanyaId,
                    ["odeyenKurumId"] = istek.OdeyenKurumId,
                    ["ossPoliceNo"] = istek.PoliceNo ?? "",
                    ["aciklama"] = "Radyoloji kabul",
                };

                // Kalemsiz acilir: ucret satirlari accession uretildikten SONRA
                //   eklenir (satir aciklamasi accession no ile eslesiyor).
                var (yeniBelgeId, basvuruUyari) = await belgeDepo.KaydetAsync(
                    basvuru, new List<Dictionary<string, JsonElement>>(),
                    new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                    yazma, iptal);
                belgeId = yeniBelgeId;
                basvuruUyarilari.AddRange(basvuruUyari);
            }

            var idler = new List<int>();
            var accessionlar = new List<string>();

            await using (var islem = await baglanti.BeginTransactionAsync(iptal))
            {
                foreach (var t in istek.Tetkikler)
                {
                    // Modalite HIZMETTEN okunur: tetkikin hangi cihaz ailesine
                    //   ait olduğu hizmet kartında tanımlı (286).
                    var modalite = await baglanti.TekDegerAsync<int>("""
                        select coalesce(modalite, 0) from public.hizmet where id = @p0
                        """, islem, [t.HizmetId], iptal);

                    var id = await baglanti.TekDegerAsync<int>("""
                        insert into public.radyoloji_istem
                            (sube_id, belge_id, hasta_id, hizmet_id, modalite, durum, oncelik,
                             istek_hekim_id, istek_kurum_id, dis_hekim_ad, on_tani, klinik_bilgi,
                             kontrast, ekleyen,
                             mwl_istendi, sms_istendi, hazirlik_verildi, cd_istendi)
                        values (@p0, @p1, @p2, @p3, @p4, 1, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12,
                                coalesce(@p13, 1), coalesce(@p14, 1),
                                coalesce(@p15, 1), coalesce(@p16, 0))
                        returning id
                        """, islem,
                        [baglam.SubeId, belgeId, istek.HastaId, t.HizmetId, modalite,
                         t.Oncelik ?? istek.Oncelik ?? 1,
                         istek.IstekHekimId, istek.IstekKurumId, istek.DisHekimAd ?? "",
                         istek.OnTani ?? "", istek.KlinikBilgi, t.Kontrast ?? 0,
                         baglam.KullaniciId,
                         istek.MwlIstendi, istek.SmsIstendi,
                         istek.HazirlikVerildi, istek.CdIstendi], iptal);

                    idler.Add(id);
                    accessionlar.Add(await baglanti.TekDegerAsync<string>(
                        "select accession_no from public.radyoloji_istem where id = @p0",
                        islem, [id], iptal) ?? "");

                    await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloIstem, id,
                        baglam.KullaniciId, baglam.SubeId, baglam.Ip, null, iptal: iptal);
                }
                await islem.CommitAsync(iptal);
            }

            // ÜCRET: başvurunun kalem listesine tetkikler eklenir. Belge yazma
            //   hattı (BelgeDeposu) kullanılır - fiyat listesi, kampanya, pay
            //   bölüşümü ve toplamlar orada çözülüyor; burada ikinci bir
            //   hesap yolu açmak ikisinin sapmasi demek olurdu.
            var uyarilar = new List<string>();
            if (istek.UcretEkle && belgeId is int ucretBelgeId && ucretBelgeId > 0)
            {
                var (belge, satirlar) = await BelgeGovdesiAsync(baglanti, ucretBelgeId, iptal);

                var sira = satirlar.Count;
                for (var i = 0; i < istek.Tetkikler.Count; i++)
                {
                    var t = istek.Tetkikler[i];
                    // FIYAT: once belgenin KENDI listesinden (basvuruya sozlesme
                    //   listesi islenmis olabilir), yoksa carinin kuralindan.
                    //   fn_belge_kalem_fiyati TABLO donduruyor - FROM'da
                    //   cagrilmali, COALESCE icinde kullanilamaz.
                    var fiyat = await baglanti.TekDegerAsync<decimal>("""
                        select coalesce(
                            (select fs.fiyat
                               from public.fiyat_listesi_satir fs
                               join public.belge b on b.id = @p2
                              where fs.liste_id = b.fiyat_listesi_id
                                and fs.hizmet_id = @p1
                              limit 1),
                            (select f.fiyat
                               from public.fn_belge_kalem_fiyati(
                                        @p0, 2::smallint, null, @p1, current_date) f
                              limit 1),
                            0)
                        """, null, [istek.HastaId, t.HizmetId, ucretBelgeId], iptal);
                    // KAMPANYA INDIRIMI: baz fiyat listeden, indirim kampanyadan.
                    //   Ekranda gosterilen tutar (fiyat/kalem ucu) ayni zinciri
                    //   kullaniyor - ikisi sapmamali, hastaya soylenen rakam
                    //   faturaya birebir gecmeli.
                    var belgeKampanya = await baglanti.TekDegerAsync<int?>(
                        "select kampanya_id from public.belge where id = @p0",
                        null, [ucretBelgeId], iptal);
                    if (belgeKampanya is int kid && kid > 0 && fiyat > 0)
                        fiyat = await baglanti.TekDegerAsync<decimal>("""
                            select coalesce(f.fiyat, @p3)
                              from public.fn_kampanya_fiyat(@p0, null, @p1, @p2) f
                             limit 1
                            """, null, [kid, t.HizmetId, fiyat, fiyat], iptal);

                    var kdv = await baglanti.TekDegerAsync<int>(
                        "select coalesce(kdv, 0) from public.hizmet where id = @p0",
                        null, [t.HizmetId], iptal);

                    satirlar.Add(SatirGovdesi(new Dictionary<string, object?>
                    {
                        ["tur"] = 2,
                        ["hizmetId"] = t.HizmetId,
                        ["miktar"] = 1m,
                        ["birimFiyat"] = fiyat,
                        ["kdv"] = kdv,
                        ["dovizCinsi"] = "TL",
                        ["aciklama"] = accessionlar[i],
                        ["sira"] = ++sira,
                    }));
                }

                var (_, uy) = await belgeDepo.GuncelleAsync(ucretBelgeId, belge, satirlar,
                    new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                    new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);
                uyarilar.AddRange(uy);

                // Üretilen satırlar istemlere BAĞLANIR: sonra "bu tetkik
                //   faturalandı mı" sorusu tek join ile cevaplanır.
                await baglanti.CalistirAsync("""
                    update public.radyoloji_istem i
                       set belge_satir_id = s.id
                      from public.belge_satir s
                     where s.belge_id = @p0 and s.aciklama = i.accession_no
                       and i.belge_satir_id is null and i.id = any(@p1)
                    """, null, [ucretBelgeId, idler.ToArray()], iptal);
            }

            // Kabul ekrani kaydettikten sonra PROTOKOL numarasini ve tutari
            //   gostermeli (mockup ozet seridi) - istemci ikinci bir istek
            //   atmasin diye belge ozeti burada doner.
            IDictionary<string, object?>? basvuruOzeti = null;
            if (belgeId is int ozetId && ozetId > 0)
                basvuruOzeti = await baglanti.TekAsync("""
                    -- PAY BOLUSUMU SATIRDA (289): belge basliginda kurum/hasta
                    --   tutari yok, satirlardan toplanir.
                    select b.id, coalesce(b.belge_no, '') as "belgeNo",
                           b.belge_tarihi as "belgeTarihi",
                           coalesce(b.kdv_tutari, 0) as "kdvToplam",
                           coalesce(b.genel_toplam, 0) as "genelToplam",
                           coalesce((select sum(s.kurum_tutar) from public.belge_satir s
                                      where s.belge_id = b.id), 0) as "kurumTutar",
                           coalesce((select sum(s.hasta_tutar) from public.belge_satir s
                                      where s.belge_id = b.id), 0) as "hastaTutar"
                      from public.belge b where b.id = @p0
                    """, null, [ozetId], Satir, iptal);

            uyarilar.InsertRange(0, basvuruUyarilari);
            return Results.Ok(new { idler, accessionlar, uyarilar, belgeId, basvuru = basvuruOzeti });
        });

        // ------------------------------------------ hastanin odeyicisi ----
        // Kabul ekrani (mockup: "Ödeyen Kurum" + "Poliçe No") hastanin AKTIF
        //   policesini onden doldurmali - kabul masasi her seferinde kurumu
        //   elle aramasin. Hasta kartinin detay uctan okunmasi ayni bilgiyi
        //   dolayli getirirdi; tek satirlik cevap yeter.
        grup.MapGet("/hasta/{id:int}/odeme", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var odeme = await baglanti.TekAsync("""
                select k.kurum_id as "kurumId",
                       coalesce(t.unvan, '') as "kurumAd",
                       coalesce(k.police_no, '') as "policeNo"
                  from public.taraf_hasta_kurum k
                  left join public.taraf t on t.id = k.kurum_id
                 where k.hasta_id = @p0 and coalesce(k.aktif, 1) = 1
                 order by k.id desc
                 limit 1
                """, null, [id], Satir, iptal);

            return Results.Ok(odeme ?? new Dictionary<string, object?>());
        });

        // ------------------------------------------- akis / ozet seridi ----
        // Mockup radyoloji_istem_karti.html: ustte "Istem -> Randevu -> Cekim ->
        //   Raporlaniyor -> Onay -> Teslim" seridi ve alttaki ozet (bekleme
        //   suresi, rapor durumu, olusturan). Bes ayri tablodan okunur; tek
        //   uc olmasi kartin acilista tek istek atmasini saglar.
        grup.MapGet("/istem/{id:int}/akis", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var akis = await baglanti.TekAsync("""
                select i.id, i.accession_no as "accessionNo", i.durum,
                       i.ekleme_tarihi as "istemZamani",
                       rv.baslangic as "randevuZamani",
                       i.cekim_tarihi as "cekimZamani",
                       r.yazma_tarihi as "raporZamani",
                       r.onay_tarihi as "onayZamani",
                       (select max(t.teslim_zamani) from public.radyoloji_teslim t
                         where t.istem_id = i.id) as "teslimZamani",
                       coalesce(r.durum, 0) as "raporDurum",
                       coalesce(r.rapor_no, '') as "raporNo",
                       coalesce(ry.unvan, '') as "raporYazan",
                       coalesce(ek.unvan, '') as "olusturan",
                       -- BEKLEME (kalite gostergesi): istemden cekime kac dakika.
                       case when i.cekim_tarihi is null then null
                            else round(extract(epoch from
                                 (i.cekim_tarihi - i.ekleme_tarihi)) / 60)::int end as "beklemeDk"
                  from public.radyoloji_istem i
                  left join public.randevu rv on rv.id = i.randevu_id
                  left join public.radyoloji_rapor r on r.istem_id = i.id and r.ust_rapor_id is null
                  -- Kullanici kaydi taraf ile AYNI id: taraf_kullanici 1:1
                  --   uzantidir, ayri bir "kullanici" tablosu yok.
                  left join public.taraf ry on ry.id = r.yazan_id
                  left join public.taraf ek on ek.id = i.ekleyen
                 where i.id = @p0
                """, null, [id], Satir, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Istem bulunamadi.");

            return Results.Ok(akis);
        });

        // ------------------------------------------ kontrol listesi (310) ----
        // Sorular MODALITEYE gore gelir; yanit varsa uzerine binmis olarak.
        grup.MapGet("/istem/{id:int}/kontrol", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var sorular = await baglanti.ListeAsync("""
                select s.id as "soruId", s.soru, s.yanit_tipi as "yanitTipi",
                       s.zorunlu, coalesce(k.yanit, '') as yanit,
                       k.kayit_zamani as "kayitZamani",
                       coalesce(p.unvan, '') as "kaydeden"
                  from public.radyoloji_istem i
                  join public.radyoloji_kontrol_soru s
                    on s.aktif = 1 and (s.modalite is null or s.modalite = i.modalite)
                  left join public.radyoloji_kontrol k on k.soru_id = s.id and k.istem_id = i.id
                  left join public.taraf p on p.id = k.kaydeden
                 where i.id = @p0
                 order by s.sira, s.id
                """, null, [id], Satir, iptal);

            return Results.Ok(new { sorular });
        });

        // Yanitlar TOPLU yazilir: kullanici listeyi bir kerede doldurur, her
        //   kutu icin ayri istek atmak yarim kalmis kayit birakirdi.
        grup.MapPost("/istem/{id:int}/kontrol", async (
            int id, KontrolIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            foreach (var y in istek.Yanitlar ?? [])
            {
                var yanit = (y.Yanit ?? "").Trim();
                if (yanit.Length == 0)
                {
                    // Bos yanit = "yanitlanmadi": kayit SILINIR, boylece zorunlu
                    //   soru tetigi (310) yine devrede kalir.
                    await baglanti.CalistirAsync(
                        "delete from public.radyoloji_kontrol where istem_id = @p0 and soru_id = @p1",
                        islem, [id, y.SoruId], iptal);
                    continue;
                }

                await baglanti.CalistirAsync("""
                    insert into public.radyoloji_kontrol
                        (istem_id, soru_id, yanit, kaydeden, kayit_zamani)
                    values (@p0, @p1, @p2, @p3, (now())::timestamp)
                    on conflict (istem_id, soru_id) do update
                       set yanit = excluded.yanit, kaydeden = excluded.kaydeden,
                           kayit_zamani = excluded.kayit_zamani
                    """, islem, [id, y.SoruId, yanit, baglam.KullaniciId], iptal);
            }

            await islem.CommitAsync(iptal);
            return Results.Ok(new { kaydedildi = true });
        });

        // ------------------------------------------------- rapor ekranı ----
        // Ekranın ihtiyacı olan HER ŞEY tek istekte: istem + hasta + tetkik,
        //   rapor (varsa bölümleriyle), uygun şablonlar, makrolar, skor
        //   tanımları ve hastanın önceki tetkikleri. Beş ayrı istek atmak
        //   ekranı açılışta yavaşlatır ve yarı dolu göstermeye açık bırakır.
        grup.MapGet("/istem/{id:int}/rapor", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var istem = await baglanti.TekAsync("""
                select i.id, i.accession_no as "accessionNo", i.durum, i.oncelik, i.modalite,
                       i.hasta_id as "hastaId", coalesce(h.unvan, '') as "hastaAdi",
                       coalesce(hs.cinsiyet, 0) as cinsiyet, hs.dogum_tarihi as "dogumTarihi",
                       i.hizmet_id as "hizmetId",
                       coalesce(hz.kod, '') as "tetkikKodu", coalesce(hz.ad, '') as "tetkikAdi",
                       i.on_tani as "onTani", i.klinik_bilgi as "klinikBilgi",
                       coalesce(ih.unvan, nullif(i.dis_hekim_ad, ''), '') as "isteyen",
                       i.cekim_tarihi as "cekimTarihi", i.kritik,
                       coalesce(cz.ad, '') as "cihazAdi",
                       i.seri_sayisi as "seriSayisi", i.goruntu_sayisi as "goruntuSayisi",
                       i.study_uid as "studyUid",
                       i.belge_id as "belgeId", coalesce(ok.unvan, '') as "odeyenKurum"
                  from public.radyoloji_istem i
                  left join public.taraf h on h.id = i.hasta_id
                  left join public.taraf_hasta hs on hs.id = i.hasta_id
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.taraf ih on ih.id = i.istek_hekim_id
                  left join public.radyoloji_cihaz cz on cz.id = i.cihaz_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf ok on ok.id = bb.odeyen_kurum_id
                 where i.id = @p0
                """, null, [id], Satir, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            var hizmetId = Convert.ToInt32(istem["hizmetId"] ?? 0);
            var hastaId  = Convert.ToInt32(istem["hastaId"] ?? 0);

            var rapor = await baglanti.TekAsync("""
                select r.id, r.sablon_id as "sablonId", r.sablon_surum as "sablonSurum",
                       r.durum, r.kilit, r.ust_rapor_id as "ustRaporId",
                       coalesce(yz.unvan, '') as "yazan", r.yazma_tarihi as "yazmaTarihi",
                       coalesce(on_.unvan, '') as "onaylayan", r.onay_tarihi as "onayTarihi"
                  from public.radyoloji_rapor r
                  left join public.taraf yz on yz.id = r.yazan_id
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                 where r.istem_id = @p0 and r.ust_rapor_id is null
                """, null, [id], Satir, iptal);

            var bolumler = rapor is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select b.id, b.sira, b.baslik, b.metin, b.yazdir,
                           coalesce(sb.zorunlu, 0) as zorunlu
                      from public.radyoloji_rapor_bolum b
                      join public.radyoloji_rapor r on r.id = b.rapor_id
                      left join public.radyoloji_sablon_bolum sb
                             on sb.sablon_id = r.sablon_id and sb.baslik = b.baslik
                     where b.rapor_id = @p0 order by b.sira
                    """, null, [Convert.ToInt32(rapor["id"])], Satir, iptal);

            var alanlar = rapor is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select alan_kod as "alanKod", alan_ad as "alanAd", deger
                      from public.radyoloji_rapor_alan where rapor_id = @p0 order by id
                    """, null, [Convert.ToInt32(rapor["id"])], Satir, iptal);

            // Şablonlar: önce tetkike bağlı olanlar, sonra aynı modalitenin
            //   genel şablonları (tetkike özel yoksa hekim yine bir şey bulsun).
            var sablonlar = await baglanti.ListeAsync("""
                select s.id, s.kod, s.ad, s.surum, s.varsayilan,
                       case when s.hizmet_id = @p0 then 1 else 0 end as "tetkigeOzel"
                  from public.radyoloji_sablon s
                 where s.durum = 1
                   and (s.hizmet_id = @p0
                        or (s.hizmet_id is null and s.modalite = @p1))
                 order by "tetkigeOzel" desc, s.varsayilan desc, s.ad
                """, null, [hizmetId, Convert.ToInt32(istem["modalite"] ?? 0)], Satir, iptal);

            var sablonId = rapor?["sablonId"] as int?
                        ?? (sablonlar.Count > 0 ? Convert.ToInt32(sablonlar[0]["id"]) : (int?)null);

            var makrolar = sablonId is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select kisayol, ad, metin, hedef_bolum as "hedefBolum"
                      from public.radyoloji_sablon_makro where sablon_id = @p0 order by id
                    """, null, [sablonId.Value], Satir, iptal);

            var skorlar = sablonId is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select alan_kod as "alanKod", alan_ad as "alanAd", tip, secenekler,
                           zorunlu, rapora_bas as "raporaBas"
                      from public.radyoloji_sablon_alan where sablon_id = @p0 order by sira
                    """, null, [sablonId.Value], Satir, iptal);

            // Önceki tetkikler: karşılaştırma bölümü bunlardan yazılır.
            var gecmis = await baglanti.ListeAsync("""
                select i.id, i.accession_no as "accessionNo", coalesce(hz.ad, '') as "tetkikAdi",
                       coalesce(i.cekim_tarihi, i.ekleme_tarihi) as tarih,
                       coalesce(on_.unvan, '') as "raporlayan",
                       coalesce((select left(b.metin, 120) from public.radyoloji_rapor_bolum b
                                  join public.radyoloji_rapor r2 on r2.id = b.rapor_id
                                 where r2.istem_id = i.id and b.baslik ilike '%sonu%'
                                 order by b.sira limit 1), '') as "ozet"
                  from public.radyoloji_istem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.radyoloji_rapor r on r.istem_id = i.id and r.ust_rapor_id is null
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                 where i.hasta_id = @p0 and i.id <> @p1 and i.durum > 0
                 order by coalesce(i.cekim_tarihi, i.ekleme_tarihi) desc limit 8
                """, null, [hastaId, id], Satir, iptal);

            var kritikler = await baglanti.ListeAsync("""
                select bulgu, bildirilen_ad as "bildirilenAd", yol,
                       bildirim_zamani as "bildirimZamani", geri_bildirim as "geriBildirim"
                  from public.radyoloji_kritik_bulgu where istem_id = @p0 order by id desc
                """, null, [id], Satir, iptal);

            return Results.Ok(new { istem, rapor, bolumler, alanlar, sablonlar, makrolar,
                                    skorlar, gecmis, kritikler });
        });

        // ------------------------------------------------- rapor ÇIKTISI ----
        // Hastaya verilen belge (mockup: radyoloji_rapor_onizleme.html). Yazma
        //   ekranından AYRI uç: çıktının ihtiyacı şablon/makro/skor değil,
        //   KURUM ANTETİ, kimlik satırları, basılacak bölümler ve imzadır.
        //
        // Yalnız `yazdir = 1` bölümler döner: şablonda ekrana konan ama
        //   hastaya basılmayan bölümler (ör. teknisyen notu) çıktıya girmez.
        grup.MapGet("/rapor/{id:int}/cikti", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var rapor = await baglanti.TekAsync("""
                select r.id, r.rapor_no as "raporNo", r.durum, r.kilit,
                       r.ust_rapor_id as "ustRaporId",
                       coalesce(yz.unvan, '') as "yazan", r.yazma_tarihi as "yazmaTarihi",
                       coalesce(on_.unvan, '') as "onaylayan", r.onay_tarihi as "onayTarihi",
                       i.id as "istemId", i.accession_no as "accessionNo",
                       i.modalite, i.cekim_tarihi as "cekimTarihi",
                       i.on_tani as "onTani", i.klinik_bilgi as "klinikBilgi",
                       i.kontrast, coalesce(cz.ad, '') as "cihazAdi",
                       coalesce(hz.kod, '') as "tetkikKodu", coalesce(hz.ad, '') as "tetkikAdi",
                       coalesce(h.unvan, '') as "hastaAdi", coalesce(h.kod, '') as "hastaNo",
                       coalesce(h.vkno, '') as "hastaTc",
                       hs.dogum_tarihi as "dogumTarihi", coalesce(hs.cinsiyet, 0) as cinsiyet,
                       coalesce(ih.unvan, nullif(i.dis_hekim_ad, ''), '') as "isteyen",
                       coalesce(ik.unvan, '') as "isteyenKurum",
                       coalesce(b.belge_no, '') as "protokolNo",
                       coalesce(ok.unvan, '') as "odeyenKurum"
                  from public.radyoloji_rapor r
                  join public.radyoloji_istem i on i.id = r.istem_id
                  left join public.taraf yz on yz.id = r.yazan_id
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                  left join public.taraf h on h.id = i.hasta_id
                  left join public.taraf_hasta hs on hs.id = i.hasta_id
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.taraf ih on ih.id = i.istek_hekim_id
                  left join public.taraf ik on ik.id = i.istek_kurum_id
                  left join public.radyoloji_cihaz cz on cz.id = i.cihaz_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf ok on ok.id = bb.odeyen_kurum_id
                 where r.id = @p0
                """, null, [id], Satir, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Rapor bulunamadı.");

            var bolumler = await baglanti.ListeAsync("""
                select sira, baslik, metin
                  from public.radyoloji_rapor_bolum
                 where rapor_id = @p0 and coalesce(yazdir, 1) = 1
                   and coalesce(metin, '') <> ''
                 order by sira
                """, null, [id], Satir, iptal);

            // Skor/ölçüm alanları rapora BASILACAK olanlarla sınırlı.
            var alanlar = await baglanti.ListeAsync("""
                select a.alan_ad as "alanAd", a.deger
                  from public.radyoloji_rapor_alan a
                  join public.radyoloji_rapor r on r.id = a.rapor_id
                  left join public.radyoloji_sablon_alan sa
                         on sa.sablon_id = r.sablon_id and sa.alan_kod = a.alan_kod
                 where a.rapor_id = @p0
                   and coalesce(sa.rapora_bas, 1) = 1
                   and coalesce(a.deger, '') <> ''
                 order by a.id
                """, null, [id], Satir, iptal);

            // EK RAPORLAR (addendum): orijinalin altında, tarihleriyle basılır -
            //   düzeltme ayrı kayıttır, orijinal metin değişmez.
            var ekler = await baglanti.ListeAsync("""
                select r.id, r.rapor_no as "raporNo", r.onay_tarihi as "onayTarihi",
                       coalesce(on_.unvan, '') as "onaylayan",
                       coalesce((select string_agg(b.metin, E'\n' order by b.sira)
                                   from public.radyoloji_rapor_bolum b
                                  where b.rapor_id = r.id and coalesce(b.yazdir, 1) = 1), '') as metin
                  from public.radyoloji_rapor r
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                 where r.ust_rapor_id = @p0
                 order by r.id
                """, null, [id], Satir, iptal);

            // ANTET: raporun ait olduğu şube (kurum kimliği hastaya verilen
            //   belgede zorunlu). Şube yoksa varsayılan şube kullanılır.
            var kurum = await baglanti.TekAsync("""
                select coalesce(nullif(s.unvan, ''), s.ad) as unvan, s.adres, s.ilce, s.il,
                       s.telefon, s.mersis_no as "mersisNo", s.vkno, s.vd
                  from public.sube s
                 where s.id = coalesce((select i.sube_id from public.radyoloji_istem i
                                         join public.radyoloji_rapor r on r.istem_id = i.id
                                        where r.id = @p0),
                                       (select id from public.sube where varsayilan = 1 limit 1))
                """, null, [id], Satir, iptal);

            return Results.Ok(new { rapor, bolumler, alanlar, ekler, kurum });
        });

        // ------------------------------------------------- taslak kaydet ----
        // Rapor yoksa açılır, varsa güncellenir. Bölümler TOPLU yazılır
        //   (sil+yaz): sıra ve başlık şablondan gelir, kısmi güncelleme
        //   ikisini ayrıştırırdı.
        grup.MapPost("/istem/{id:int}/rapor", async (
            int id, RaporIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var mevcut = await baglanti.TekDegerAsync<int?>(
                "select id from public.radyoloji_rapor where istem_id = @p0 and ust_rapor_id is null",
                islem, [id], iptal);

            // KİLİT: onaylı rapor değiştirilemez - düzeltme addendum'dur.
            var kilit = mevcut is null ? 0 : await baglanti.TekDegerAsync<int>(
                "select coalesce(kilit, 0) from public.radyoloji_rapor where id = @p0",
                islem, [mevcut.Value], iptal);
            if (kilit == 1)
                throw GentegreHatasi.IsKurali(
                    "Rapor onaylanmış ve kilitli; düzeltme için ek rapor (addendum) açın.");

            int raporId;
            if (mevcut is null)
            {
                raporId = Convert.ToInt32(await baglanti.TekDegerAsync<int>("""
                    insert into public.radyoloji_rapor
                           (istem_id, sablon_id, sablon_surum, durum, yazan_id, yazma_tarihi, ekleyen)
                    select @p0, @p1,
                           coalesce((select surum from public.radyoloji_sablon where id = @p1), 1),
                           1, @p2, now()::timestamp, @p2
                    returning id
                    """, islem, [id, istek.SablonId, baglam.KullaniciId], iptal));
            }
            else
            {
                raporId = mevcut.Value;
                await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set sablon_id = coalesce(@p1, sablon_id),
                           degistiren = @p2, degistirme_tarihi = now()::timestamp
                     where id = @p0
                    """, islem, [raporId, istek.SablonId, baglam.KullaniciId], iptal);
            }

            if (istek.Bolumler is { Count: > 0 })
            {
                await baglanti.CalistirAsync(
                    "delete from public.radyoloji_rapor_bolum where rapor_id = @p0",
                    islem, [raporId], iptal);
                foreach (var b in istek.Bolumler)
                    await baglanti.CalistirAsync("""
                        insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, yazdir)
                        values (@p0, @p1, @p2, @p3, @p4)
                        """, islem, [raporId, (short)b.Sira, b.Baslik, b.Metin ?? "", b.Yazdir], iptal);
            }

            if (istek.Alanlar is not null)
            {
                await baglanti.CalistirAsync(
                    "delete from public.radyoloji_rapor_alan where rapor_id = @p0",
                    islem, [raporId], iptal);
                foreach (var a in istek.Alanlar.Where(x => !string.IsNullOrWhiteSpace(x.Deger)))
                    await baglanti.CalistirAsync("""
                        insert into public.radyoloji_rapor_alan (rapor_id, alan_kod, alan_ad, deger)
                        values (@p0, @p1, @p2, @p3)
                        """, islem, [raporId, a.AlanKod, a.AlanAd ?? "", a.Deger], iptal);
            }

            if (istek.Kritik is { } kritik)
                await baglanti.CalistirAsync(
                    "update public.radyoloji_istem set kritik = @p1 where id = @p0",
                    islem, [id, kritik], iptal);

            // İstem "Raporlanıyor"a geçer (henüz çekilmemişse dokunulmaz).
            await baglanti.CalistirAsync(
                "update public.radyoloji_istem set durum = 3 where id = @p0 and durum = 2",
                islem, [id], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { raporId });
        });

        // --------------------------------------------------- ön rapor / onay ----
        // İki aşama: asistan ÖN RAPOR gönderir (durum 2), uzman ONAYLAR
        //   (durum 3 + kilit). Onay ön koşulları veritabanında (284).
        grup.MapPost("/rapor/{id:int}/durum", async (
            int id, string hedef, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var onayMi = string.Equals(hedef, "onay", StringComparison.OrdinalIgnoreCase);
            baglam.AksiyonIste(onayMi ? "rad.rapor_onayla" : "rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);

            var engel = await baglanti.TekDegerAsync<string>(
                "select public.fn_radyoloji_rapor_onaylanabilir(@p0)", null, [id], iptal) ?? "";
            if (onayMi && engel.Length > 0) throw GentegreHatasi.IsKurali(engel);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var istemId = await baglanti.TekDegerAsync<int>(
                "select istem_id from public.radyoloji_rapor where id = @p0", islem, [id], iptal);

            if (onayMi)
            {
                // RESMI RAPOR NUMARASI onayda atanir (303): taslak asamasinda
                //   vermek, vazgecilen raporlarda numara boslugu birakirdi.
                //   Zaten numarali rapor (yeniden onay) numarasini KORUR.
                await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set durum = 3, kilit = 1, onaylayan_id = @p1, onay_tarihi = now()::timestamp,
                           rapor_no = case when rapor_no = ''
                                           then public.fn_radyoloji_rapor_no()
                                           else rapor_no end,
                           degistiren = @p1, degistirme_tarihi = now()::timestamp
                     where id = @p0
                    """, islem, [id, baglam.KullaniciId], iptal);
                await baglanti.CalistirAsync(
                    "update public.radyoloji_istem set durum = 5 where id = @p0", islem, [istemId], iptal);
            }
            else
            {
                await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set durum = 2, degistiren = @p1, degistirme_tarihi = now()::timestamp
                     where id = @p0 and coalesce(kilit, 0) = 0
                    """, islem, [id, baglam.KullaniciId], iptal);
                await baglanti.CalistirAsync(
                    "update public.radyoloji_istem set durum = 4 where id = @p0", islem, [istemId], iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRapor, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["durum"] = onayMi ? "Onaylandı" : "Ön rapor" },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { tamam = true });
        });

        // -------------------------------------------------------- addendum ----
        // Onaylı rapor kilitlidir; düzeltme AYRI kayıt olarak eklenir ve
        //   orijinal metin korunur.
        grup.MapPost("/rapor/{id:int}/addendum", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            var yeni = await baglanti.TekDegerAsync<int>("""
                insert into public.radyoloji_rapor
                       (istem_id, sablon_id, sablon_surum, durum, ust_rapor_id,
                        yazan_id, yazma_tarihi, ekleyen)
                select r.istem_id, r.sablon_id, r.sablon_surum, 1, r.id, @p1, now()::timestamp, @p1
                  from public.radyoloji_rapor r where r.id = @p0
                returning id
                """, null, [id, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, yazdir)
                values (@p0, 1, 'Ek Rapor', '', 1)
                """, null, [yeni], iptal);

            return Results.Ok(new { raporId = yeni });
        });

        // ---------------------------------------------------- kritik bulgu ----
        grup.MapPost("/istem/{id:int}/kritik-bulgu", async (
            int id, KritikIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                insert into public.radyoloji_kritik_bulgu
                       (istem_id, rapor_id, bulgu, bildiren_id, bildirilen_ad, yol,
                        geri_bildirim, ekleyen)
                select @p0,
                       (select id from public.radyoloji_rapor
                         where istem_id = @p0 and ust_rapor_id is null),
                       @p1, @p2, @p3, @p4, @p5, @p2
                """, islem, [id, istek.Bulgu ?? "", baglam.KullaniciId,
                             istek.BildirilenAd ?? "", istek.Yol, istek.GeriBildirim ?? ""], iptal);

            await baglanti.CalistirAsync(
                "update public.radyoloji_istem set kritik = 1 where id = @p0", islem, [id], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { tamam = true });
        });

        // -------------------------------------------------- sonuç teslimi ----
        // Film / CD / basılı raporun kime verildiği. Hasta dışında biri
        //   alıyorsa YAKINLIK ve kimlik doğrulaması kayda geçer: sonuç kişisel
        //   sağlık verisidir, "kime verdik" sorusunun cevabı belgede durmalı.
        grup.MapPost("/istem/{id:int}/teslim", async (
            int id, TeslimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.teslim");

            if (string.IsNullOrWhiteSpace(istek.AlanAd))
                throw GentegreHatasi.Dogrulama("Teslim alan kişi yazılmalı.",
                    new AlanHatasi("alanAd", "Zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            // Onaylı rapor varsa teslime BAĞLANIR: hangi rapor sürümünün
            //   verildiği sonradan sorulabiliyor (addendum sonrası önemli).
            var raporId = await baglanti.TekDegerAsync<int?>("""
                select max(id) from public.radyoloji_rapor
                 where istem_id = @p0 and durum = 3
                """, null, [id], iptal);

            await baglanti.CalistirAsync("""
                insert into public.radyoloji_teslim
                    (istem_id, rapor_id, tur, teslim_zamani, teslim_eden_id,
                     alan_ad, alan_yakinlik, kimlik_dogrulandi, aciklama, ekleyen)
                values (@p0, @p1, @p2, now()::timestamp, @p3, @p4, @p5, @p6, @p7, @p3)
                """, null,
                [id, raporId, istek.Tur, baglam.KullaniciId, istek.AlanAd,
                 istek.AlanYakinlik ?? "", istek.KimlikDogrulandi, istek.Aciklama ?? ""], iptal);

            return Results.Ok(new { tamam = true });
        });

        grup.MapGet("/istem/{id:int}/teslimler", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            return Results.Ok(await baglanti.ListeAsync("""
                select t.id, t.tur, t.teslim_zamani as "teslimZamani",
                       coalesce(p.unvan, '') as "teslimEden", t.alan_ad as "alanAd",
                       t.alan_yakinlik as "alanYakinlik",
                       t.kimlik_dogrulandi as "kimlikDogrulandi", t.aciklama
                  from public.radyoloji_teslim t
                  left join public.taraf p on p.id = t.teslim_eden_id
                 where t.istem_id = @p0 order by t.id desc
                """, null, [id], Satir, iptal));
        });

        // ------------------------------------------------- konsültasyon ----
        // İkinci görüş: raporu yazan radyolog başka bir hekimin/kurumun
        //   görüşünü ister. İstek ve DÖNEN GÖRÜŞ aynı uçtan yazılır - görüş
        //   dolu gelirse kayıt "döndü" (durum 2) sayılır; ayrı bir "cevapla"
        //   ucu, aynı satırın iki sahibi olması demekti.
        grup.MapPost("/istem/{id:int}/konsultasyon", async (
            int id, KonsultasyonIstegi istek, int? konsultasyonId,
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);

            if (konsultasyonId is int kid && kid > 0)
            {
                if (string.IsNullOrWhiteSpace(istek.Gorus))
                    throw GentegreHatasi.Dogrulama("Görüş metni boş olamaz.",
                        new AlanHatasi("gorus", "Zorunlu."));
                await baglanti.CalistirAsync("""
                    update public.radyoloji_konsultasyon
                       set gorus = @p1, durum = 2, donus_zamani = now()::timestamp,
                           degistiren = @p2, degistirme_tarihi = now()::timestamp
                     where id = @p0
                    """, null, [kid, istek.Gorus, baglam.KullaniciId], iptal);
                return Results.Ok(new { id = kid });
            }

            if (string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("Konsültasyon gerekçesi yazılmalı.",
                    new AlanHatasi("gerekce", "Zorunlu."));

            var raporId = await baglanti.TekDegerAsync<int?>(
                "select max(id) from public.radyoloji_rapor where istem_id = @p0",
                null, [id], iptal);

            var yeni = await baglanti.TekDegerAsync<int>("""
                insert into public.radyoloji_konsultasyon
                    (istem_id, rapor_id, hekim_id, kurum_id, durum,
                     gonderim_zamani, gerekce, ekleyen)
                values (@p0, @p1, @p2, @p3, 1, now()::timestamp, @p4, @p5)
                returning id
                """, null,
                [id, raporId, istek.HekimId, istek.KurumId, istek.Gerekce,
                 baglam.KullaniciId], iptal);

            return Results.Ok(new { id = yeni });
        });

        grup.MapGet("/istem/{id:int}/konsultasyonlar", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            return Results.Ok(await baglanti.ListeAsync("""
                select k.id, k.durum, k.gerekce, k.gorus,
                       k.gonderim_zamani as "gonderimZamani", k.donus_zamani as "donusZamani",
                       coalesce(h.unvan, '') as "hekim", coalesce(kr.unvan, '') as "kurum"
                  from public.radyoloji_konsultasyon k
                  left join public.taraf h on h.id = k.hekim_id
                  left join public.taraf kr on kr.id = k.kurum_id
                 where k.istem_id = @p0 order by k.id desc
                """, null, [id], Satir, iptal));
        });
    }

    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
    }

    /// <summary>
    /// Sozluk -> BelgeDeposu'nun bekledigi JsonElement satiri. Belge yazma
    /// hatti istegi JSON olarak aliyor; radyoloji ucu satiri kod icinde
    /// kurdugu icin ayni bicime cevrilir (icmal faturasi ile ayni desen).
    /// </summary>
    private static Dictionary<string, JsonElement> SatirGovdesi(
        IDictionary<string, object?> alanlar)
    {
        var json = JsonSerializer.SerializeToElement(alanlar);
        var sozluk = new Dictionary<string, JsonElement>(StringComparer.Ordinal);
        foreach (var alan in json.EnumerateObject()) sozluk[alan.Name] = alan.Value;
        return sozluk;
    }

    /// <summary>
    /// Mevcut belgeyi (baslik + satirlar) yazma hattinin bekledigi bicimde
    /// okur. Belgeye SATIR EKLEMEK icin gerekli: BelgeDeposu.GuncelleAsync
    /// belgeyi butun olarak yazar - eksik gonderilen satir SILINMIS sayilir.
    /// </summary>
    private static async Task<(IDictionary<string, object?> Belge,
                               List<Dictionary<string, JsonElement>> Satirlar)>
        BelgeGovdesiAsync(NpgsqlConnection baglanti, int belgeId, CancellationToken iptal)
    {
        var belge = await baglanti.TekAsync("""
            select b.tur, b.tipi, b.taraf_id as "tarafId", b.belge_tarihi as "belgeTarihi",
                   b.belge_seri as "belgeSeri", b.belge_no as "belgeNo",
                   b.belge_dovizi as "belgeDovizi", b.rapor_dovizi as "raporDovizi",
                   b.ekstre_dovizi as "ekstreDovizi", b.doviz_kuru as "dovizKuru",
                   b.vade_gun as "vadeGun", b.aciklama, b.ozel_kod as "ozelKod",
                   b.satici_id as "saticiId", b.cikis_depo_id as "cikisDepoId",
                   b.giris_depo_id as "girisDepoId", b.fiyat_listesi_id as "fiyatListesiId",
                   b.kampanya_id as "kampanyaId", b.sube_id as "subeId", b.senaryo,
                   -- ODEYEN KURUM (249) uzantida durur ama govdede OLMALI:
                   --   pay bolusumu (289) bu alandan hesaplaniyor - eksik
                   --   gonderilirse tum tutar hastaya yazilir.
                   bb.odeyen_kurum_id as "odeyenKurumId",
                   bb.bolum_id as "bolumId", bb.personel_id as "personelId"
              from public.belge b
              left join public.belge_basvuru bb on bb.id = b.id
             where b.id = @p0
            """, null, [belgeId], Satir, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Başvuru bulunamadı.");

        var mevcut = await baglanti.ListeAsync("""
            select s.id, s.tur, s.stok_id as "stokId", s.hizmet_id as "hizmetId",
                   s.masraf_id as "masrafId", s.aciklama, s.miktar, s.birim,
                   s.birim_fiyat as "birimFiyat", s.iskonto, s.kdv,
                   s.doviz_cinsi as "dovizCinsi",
                   -- Satirda TEK depo kolonu yok: yon'e gore giris/cikis
                   --   kolonlari kullaniliyor (belge_satir semasi).
                   s.giris_depo_id as "girisDepoId", s.cikis_depo_id as "cikisDepoId",
                   s.kaynak_tur as "kaynakTur", s.kaynak_id as "kaynakId",
                   s.pay, s.kurum_tutar as "kurumTutar", s.hasta_tutar as "hastaTutar",
                   s.sira
              from public.belge_satir s where s.belge_id = @p0 order by s.sira, s.id
            """, null, [belgeId], Satir, iptal);

        return (belge, mevcut.Select(SatirGovdesi).ToList());
    }
}
