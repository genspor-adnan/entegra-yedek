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
public static partial class RadyolojiUclari
{
    /// <summary>islem_log.tablo_id - rapor.</summary>
    private const int LogTabloRapor = 941;

    public sealed record BolumIstegi(int? Id, int Sira, string Baslik, string Metin, short Yazdir);
    public sealed record AlanIstegi(string AlanKod, string AlanAd, string Deger);
    public sealed record RaporIstegi(int? SablonId, IReadOnlyList<BolumIstegi>? Bolumler,
                                     IReadOnlyList<AlanIstegi>? Alanlar, short? Kritik);
    public sealed record KritikIstegi(string Bulgu, string BildirilenAd, short Yol,
                                      string GeriBildirim,
                                      /// <summary>Bildirilen hekim aldigini teyit etti mi (318).</summary>
                                      short? TeyitAlindi = null,
                                      /// <summary>Bildirimle birlikte takip kapatilsin mi (318).</summary>
                                      bool Kapat = false);

    /// <summary>SONUC TESLIMI (304): film/CD/basili rapor kime verildi.</summary>
    public sealed record TeslimIstegi(short Tur, string AlanAd, string AlanYakinlik,
                                      short KimlikDogrulandi, string Aciklama,
                                      /// <summary>
                                      /// TESLIM KALEMLERI (318): bir teslimde hastaya ayni anda
                                      /// rapor + film + CD verilir; tek "tur" kolonu bunu
                                      /// anlatamiyordu. Tur geriye donuk uyumluluk icin kalir.
                                      /// </summary>
                                      short? RaporVerildi = null, short? FilmVerildi = null,
                                      short? CdVerildi = null, short? DijitalVerildi = null);

    /// <summary>
    /// KONSULTASYON (304): ikinci gorus. Istek ve DONEN GORUS ayni ucu kullanir -
    /// gorus dolu gelirse kayit "donmus" sayilir.
    /// </summary>
    public sealed record KonsultasyonIstegi(int? HekimId, int? KurumId, string Gerekce,
                                            string? Gorus,
                                            /// <summary>Gorus / ikinci okuma / klinik korelasyon (318).</summary>
                                            short? Tip = null, short? Acil = null);

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
        short? HazirlikVerildi = null, short? CdIstendi = null,
        /// <summary>
        /// RANDEVUDAN KABUL (317): hasta cogunlukla kuruma GELMEDEN randevu
        /// alir - o anda istem/basvuru/odeme yoktur. Hasta gelince "Geldi"
        /// denir, basvuru ve istem burada dogar; istem randevuya baglanir ki
        /// takvimdeki plan ile yapilan is ayni kayitta gorunsun.
        /// </summary>
        int? RandevuId = null);

    /// <summary>
    /// RANDEVU VERME (316): istem cihaza baglanir. Sure verilmezse cekim
    /// protokolunden (314), o da yoksa cihazin varsayilan suresinden gelir.
    /// </summary>
    public sealed record RandevuIstegi(int CihazId, DateTime Baslangic, short? SureDk,
                                       int? TeknikerId, string? Aciklama);

    /// <summary>
    /// SARF DUSUMU (320): cekim sonrasi kullanilan malzeme. Protokol
    /// VARSAYILANDIR - gercek kullanim teknisyenin onayindan gecer, sessiz
    /// otomatik dusum stok sayimini bozar.
    /// </summary>
    /// <summary>
    /// CIKIS belgesinde lot GIRILMEZ, stoktaki lotlardan SECILIR: belge hatti
    /// seri_lot_id bekler (lot no metni yetmez - ayni lot numarasi farkli
    /// girislerde tekrar edebilir).
    /// </summary>
    public sealed record SarfIzlemi(int SeriLotId, decimal Miktar);
    public sealed record SarfSatiri(int StokId, decimal Miktar,
                                    IReadOnlyList<SarfIzlemi>? Izlemler);
    public sealed record SarfIstegi(int? DepoId, IReadOnlyList<SarfSatiri> Satirlar);

    /// <summary>
    /// CIHAZ KAPATMA (318): bakim / ariza / tatil. Takvimden secilen aralikla
    /// acilir; kapatma randevuya kapali saat demektir (kural 316 tetiginde).
    /// </summary>
    public sealed record KapatmaIstegi(DateTime Baslangic, DateTime Bitis,
                                       short? NedenTur, string? Aciklama);

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
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

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
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            // KAYITLI DIS HEKIMLER (305): dis istemde artik serbest metin yerine
            //   listeden secilir - "kim kac hasta gonderdi" sorusu ancak
            //   istek_hekim_id dolduysa cevaplanabiliyor.
            var disHekimler = await baglanti.ListeAsync("""
                select id, ad, kurum, brans from public.v_dis_hekim_lookup order by ad
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

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
                    """, null, [hastaId.Value], OkuyucuGenisletmeleri.Sozluk, iptal);

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
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

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
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

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
                    """, null, [istek.HastaId], OkuyucuGenisletmeleri.Sozluk, iptal)
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

                    // MODALITESIZ TETKIK ISTEME DONUSMEZ (459): sifir yazmak
                    //   calisma listesine hicbir cihaza gonderilemeyen satir
                    //   birakiyordu. Ayni kural DB tetiginde de var; buradaki
                    //   kontrol hangi tetkikin sorunlu oldugunu SOYLER.
                    if (modalite <= 0)
                    {
                        var ad = await baglanti.TekDegerAsync<string>(
                            "select coalesce(ad, '') from public.hizmet where id = @p0",
                            islem, [t.HizmetId], iptal) ?? "";
                        throw GentegreHatasi.Dogrulama(
                            $"\"{(ad.Length > 0 ? ad : "#" + t.HizmetId)}\" radyoloji tetkiki "
                            + "degil (hizmet kartinda modalite yok).",
                            [new("hizmetId", "Radyoloji tetkiki secin ya da hizmet kartina "
                                             + "modalite girin.")]);
                    }

                    var id = await baglanti.TekDegerAsync<int>("""
                        insert into public.radyoloji_istem
                            (sube_id, belge_id, hasta_id, hizmet_id, modalite, durum, oncelik,
                             istek_hekim_id, istek_kurum_id, dis_hekim_ad, on_tani, klinik_bilgi,
                             kontrast, ekleyen,
                             mwl_istendi, sms_istendi, hazirlik_verildi, cd_istendi,
                             randevu_id)
                        values (@p0, @p1, @p2, @p3, @p4, 1, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12,
                                coalesce(@p13, 1), coalesce(@p14, 1),
                                coalesce(@p15, 1), coalesce(@p16, 0), @p17)
                        returning id
                        """, islem,
                        [baglam.SubeId, belgeId, istek.HastaId, t.HizmetId, modalite,
                         t.Oncelik ?? istek.Oncelik ?? 1,
                         istek.IstekHekimId, istek.IstekKurumId, istek.DisHekimAd ?? "",
                         istek.OnTani ?? "", istek.KlinikBilgi, t.Kontrast ?? 0,
                         baglam.KullaniciId,
                         istek.MwlIstendi, istek.SmsIstendi,
                         istek.HazirlikVerildi, istek.CdIstendi,
                         // Randevudan kabul (317): plan ile is ayni kayitta bagli.
                         istek.RandevuId], iptal);

                    // RANDEVUNUN CIHAZI isteme tasinir (317): cekim o cihazda
                    //   planlandi, MWL de bunu kullanacak. Kabul sirasinda
                    //   randevudakinden BASKA modalitede tetkik eklendiyse
                    //   yazilmaz - yanlis cihaza dusmesindense bos kalsin.
                    if (istek.RandevuId is int randevuId && randevuId > 0)
                        await baglanti.CalistirAsync("""
                            update public.radyoloji_istem i
                               set cihaz_id = c.id
                              from public.randevu r
                              join public.radyoloji_cihaz c on c.id = r.cihaz_id
                             where i.id = @p0 and r.id = @p1
                               and (coalesce(i.modalite, 0) = 0
                                    or coalesce(c.modalite, 0) = 0
                                    or i.modalite = c.modalite)
                            """, islem, [id, randevuId], iptal);

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
                           coalesce((select sum(dg.sgk + dg.oss) from public.belge_satir s
                             join public.belge_satir_dagilim dg
                               on dg.belge_satir_id = s.id
                                      where s.belge_id = b.id), 0) as "kurumTutar",
                           coalesce((select sum(dg.hasta_provizyon + dg.hasta_ek_katki)
                              from public.belge_satir s
                              join public.belge_satir_dagilim dg
                                on dg.belge_satir_id = s.id
                                      where s.belge_id = b.id), 0) as "hastaTutar"
                      from public.belge b where b.id = @p0
                    """, null, [ozetId], OkuyucuGenisletmeleri.Sozluk, iptal);

            uyarilar.InsertRange(0, basvuruUyarilari);
            return Results.Ok(new { idler, accessionlar, uyarilar, belgeId, basvuru = basvuruOzeti });
        });

        // ------------------------------------------------ tetkik bilgisi ----
        // RANDEVU KARTI (317): tetkik secilince sure ve modalite buradan gelir.
        //   Randevu ekrani radyoloji modulunu bilmek zorunda kalmasin diye tek
        //   ucta toplandi; yetki RANDEVU uzerinden - kabul masasinin radyoloji
        //   yetkisi olmayabilir.
        grup.MapGet("/tetkik-bilgi/{hizmetId:int}", async (
            int hizmetId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var satir = await baglanti.TekAsync("""
                select t.hizmet_id as "hizmetId", t.hizmet_adi as "hizmetAdi",
                       t.modalite, t.protokol_sure as "protokolSure",
                       t.kontrast, t.hazirlik_metni as "hazirlikMetni",
                       coalesce(kd.ad, '') as "modaliteAdi"
                  from public.v_randevu_tetkik_sure t
                  left join public.kod_liste kl on kl.kod = 'rad.modalite'
                  left join public.kod_deger kd
                         on kd.liste_id = kl.id and kd.deger = t.modalite
                 where t.hizmet_id = @p0
                """, null, [hizmetId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Radyoloji tetkiki DEGILSE bos doner - randevu karti da uyari cizmez.
            return Results.Ok(satir);
        });

        SarfVeKontrastEkle(grup);
        PanoVeCihazEkle(grup);
        AkisVeKontrolEkle(grup);
        RaporEkle(grup);
        OnayVeBulguEkle(grup);
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
            """, null, [belgeId], OkuyucuGenisletmeleri.Sozluk, iptal)
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
                   s.pay, coalesce(dg.sgk + dg.oss, 0) as "kurumTutar",
                   coalesce(dg.hasta_provizyon + dg.hasta_ek_katki, 0)
                     as "hastaTutar",
                   s.sira
              from public.belge_satir s
              left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
             where s.belge_id = @p0 order by s.sira, s.id
            """, null, [belgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

        return (belge, mevcut.Select(SatirGovdesi).ToList());
    }
}
