using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// LABORATUVAR UÇLARI — v1 (433/434): istem, numune/barkod, kabul-ret,
/// sonuç girişi, iki aşamalı onay, panik bildirimi, cihaz çalışma listesi.
///
/// <para><b>Yetki üçe ayrılır:</b> <c>lab.numune</c> (kabul/ret),
/// <c>lab.sonuc</c> (giriş + teknik onay), <c>lab.onay</c> (uzman onayı).
/// Sonucu giren kişinin kendi sonucunu yayınlaması, iki aşamalı onayı
/// anlamsız kılardı.</para>
/// </summary>
public static partial class LabUclari
{
    /// <param name="BelgeId">
    /// Başvurulu istem (hasta burada). Dış kurum numunesinde BOŞ - o zaman
    /// <paramref name="DisKurumId"/> ve <paramref name="HastaId"/> zorunlu (637).
    /// </param>
    public sealed record IstemIstegi(int BelgeId, LabServisi.IstemSatiriIstegi[]? Satirlar,
                                     short? Oncelik, string? KlinikBilgi, string? TaniIcd,
                                     int? HastaId = null, int? DisKurumId = null);

    public sealed record NumuneDurumIstegi(short Durum, short? Kalite, short? RetNeden,
                                           string? Aciklama);

    /// <summary>Tüplerin saklama yeri ve sıcaklığı (mockup "🧊 Saklama Yeri").</summary>
    public sealed record SaklamaIstegi(string? Yer, decimal? Sicaklik);

    public sealed record OnayIstegi(short? Asama);

    public sealed record DuzeltmeIstegi(string Deger, string Neden);

    public sealed record PanikIstegi(string BildirilenAd, short? Kanal, string? Aciklama);

    public sealed record TeyitIstegi(string TeyitEden);

    public sealed record OnRaporIstegi(string Metin, bool? Kritik);

    public sealed record YorumIstegi(string Yorum, bool? Bildir, string Neden);

    public sealed record UzmanYorumIstegi(string? Yorum);

    public sealed record KulturIptalIstegi(string Neden);

    public sealed record DisRetIstegi(int IstemSatirId, short? Durum, string Neden);

    public sealed record DisFaturaIstegi(int BelgeId, decimal? Tutar);

    public sealed record VaryantSinifIstegi(short Sinif, string Neden, bool? Raporla);

    public sealed record DogrulamaIstegi(short Durum, string? Yontem);

    public sealed record GenetikOnayIstegi(string? Yorum, string? Oneriler,
                                           string? Sinirliliklar);

    public static void LabUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/lab").WithTags("Laboratuvar").RequireAuthorization();

        // ------------------------------------------------ katalog sol panel ---
        // GET /api/lab/tetkik/agac - Tetkik Katalogu SOL PANELI (492, mockup
        //   lab_tetkik_katalogu.html "Bölüm / Çalışma Grubu" + "Paneller").
        //
        //   Sayimlar SUNUCUDA: istemci sayfali listeden sayamaz (gordugu 50
        //   satir tum katalog degil). Panel uyeleri de burada doner - panele
        //   tiklayinca liste o tetkik kimlikleriyle suzulur; istemci uyelik
        //   kuralini kendisi kurmaz.
        // GET /api/lab/hizmet/{id}/tetkik - HIZMETIN laboratuvar karsiligi.
        //
        //   Istem kartinda tetkik JENERIK HIZMET ARAMASIYLA seciliyor
        //   (kullanici): kabul masasi SUT kodunu/adini biliyor, laboratuvarin
        //   ic tetkik kodunu degil. Secilen hizmet bir PANEL olabilir
        //   (hemogram 23 parametre) ya da tek tetkik; ekran hangisi oldugunu
        //   bilmeden satiri yazamaz.
        //
        //   PANEL ONCELIKLI: ayni hizmete hem panel hem tetkik baglanmis
        //   olsaydi (kurulum hatasi) tek tetkik yazmak panelin oteki
        //   parametrelerini sessizce dusururdu.
        grup.MapGet("/hizmet/{id:int}/tetkik", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            var bulunan = await veri.TekAsync("""
                select p.id as panel_id, null::integer as tetkik_id, p.kod, p.ad
                  from public.lab_panel p
                 where p.hizmet_id = @p0 and p.durum = 0
                union all
                select null, t.id, t.kod, t.ad
                  from public.lab_tetkik t
                 where t.hizmet_id = @p0 and t.durum = 0
                 order by 1 nulls last
                 limit 1
                """, [id],
                o => new { PanelId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0),
                           TetkikId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                           Kod = o.GetString(2), Ad = o.GetString(3) }, iptal);

            if (bulunan is null)
                throw GentegreHatasi.IsKurali(
                    "Bu hizmetin laboratuvar karşılığı tanımlı değil - tetkik "
                    + "kartındaki \"Hizmet (fiyat/fatura)\" alanını doldurun.");

            return Results.Ok(new { bulunan.PanelId, bulunan.TetkikId,
                                    bulunan.Kod, bulunan.Ad,
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapGet("/tetkik/agac", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.tetkik", Islem.Gor);

            var bolumler = await veri.ListeAsync("""
                select t.bolum as kod,
                       case t.bolum when 2 then 'Hematoloji' when 3 then 'Hormon'
                            when 4 then 'Mikrobiyoloji' when 5 then 'Seroloji'
                            when 6 then 'Koagülasyon' when 7 then 'İdrar'
                            when 9 then 'Diğer' else 'Biyokimya' end as ad,
                       case t.bolum when 2 then '🩸' when 3 then '🧪' when 4 then '🦠'
                            when 5 then '🧫' when 6 then '🩸' when 7 then '💧'
                            when 9 then '🔬' else '🧪' end as ikon,
                       count(*) as adet,
                       count(*) filter (where t.durum = 0) as aktif
                  from public.lab_tetkik t
                 group by t.bolum
                 order by t.bolum
                """, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            // PANEL UYELERI: panel basina tetkik kimlikleri. Paneller kucuktur
            //   (onlarca tetkik), tek istekte tasinmasi listeyi yavaslatmaz.
            var paneller = await veri.ListeAsync("""
                select p.id, p.kod, p.ad, p.durum,
                       coalesce(array_agg(s.tetkik_id order by s.sira)
                                filter (where s.tetkik_id is not null), '{}') as "tetkikIdleri"
                  from public.lab_panel p
                  left join public.lab_panel_satir s on s.panel_id = p.id
                 group by p.id, p.kod, p.ad, p.durum
                 order by p.ad
                """, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            var toplam = await veri.TekDegerAsync<long>(
                "select count(*) from public.lab_tetkik", [], iptal);

            return Results.Ok(new { toplam, bolumler, paneller, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ secili tetkik ozeti --
        // GET /api/lab/tetkik/{id}/ozet - Tetkik Katalogu listesinin SAG
        //   PANELI (492, mockup lab_tetkik_katalogu.html "Seçili Tetkik").
        //
        //   Panel dort soruyu cevaplar: tetkigin kimligi (LOINC/SKRS, olculebilir
        //   aralik, panik degeri), hangi referans kurallari var, hangi panellerde
        //   kullaniliyor ve simdi istenirse sonuc ne zaman cikar. Hepsi TEK
        //   istekte doner - satir secildikce dort ayri cagri yapmak listeyi
        //   yavaslatirdi.
        grup.MapGet("/tetkik/{id:int}/ozet", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.tetkik", Islem.Gor);

            // ALAN YETKISI KOLONU SORGUDAN CIKARIR, yanittan sonradan silmez
            //   (API sozlesmesi §3.1): yetkisiz deger ne SQL'e ne log'a duser.
            //   Ad -> SQL eslemesi SABIT; istekten gelen hicbir metin buraya
            //   girmez.
            (string Ad, string Sql)[] alanlar =
            [
                ("kod",             "t.kod"),
                ("ad",              "t.ad"),
                ("kisaAd",          "t.kisa_ad"),
                ("birim",           "t.birim"),
                ("loinc",           "t.loinc"),
                ("skrsKod",         "t.skrs_tetkik_kod"),
                ("yontem",          "t.yontem"),
                ("olculebilirAlt",  "t.olculebilir_alt"),
                ("olculebilirUst",  "t.olculebilir_ust"),
                ("panikAlt",        "t.panik_alt"),
                ("panikUst",        "t.panik_ust"),
                ("hedefTatDk",      "t.hedef_tat_dk"),
                ("acilTatDk",       "t.acil_tat_dk"),
                ("bolumAdi",
                 "case t.bolum when 2 then 'Hematoloji' when 3 then 'Hormon' "
                 + "when 4 then 'Mikrobiyoloji' when 5 then 'Seroloji' "
                 + "when 6 then 'Koagülasyon' when 7 then 'İdrar' "
                 + "when 9 then 'Diğer' else 'Biyokimya' end"),
                ("sonucZamani",
                 "public.fn_lab_tetkik_sonuc_zamani(t.id, now()::timestamp, 0::smallint)"),
            ];
            var secilen = alanlar
                .Where(a => baglam.Yetkiler.AlanOkunur("lab-tetkik", a.Ad)).ToList();
            // Kimlik alanlari bile gizlenmisse panelde gosterilecek bir sey yok.
            if (secilen.Count == 0) throw GentegreHatasi.Yasak("Tetkik alanları görüntülenemiyor.");

            var tetkik = await veri.TekAsync(
                "select " + string.Join(", ", secilen.Select(a => $"{a.Sql} as \"{a.Ad}\""))
                + " from public.lab_tetkik t where t.id = @p0",
                [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Tetkik bulunamadı.");

            // REFERANS ARALIKLARI: "kime" metni DB'de uretiliyor (488) - liste
            //   ile kart ayni cumleyi yazsin.
            var referanslar = await veri.ListeAsync("""
                select r.alt, r.ust, r.metin,
                       public.fn_lab_referans_kime(r.cinsiyet, r.yas_alt_gun,
                                                   r.yas_ust_gun, r.gebelik) as kime
                  from public.lab_tetkik_referans r
                 where r.tetkik_id = @p0
                 order by r.sira, r.yas_alt_gun
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var paneller = await veri.ListeAsync("""
                select p.id, p.ad
                  from public.lab_panel_satir s
                  join public.lab_panel p on p.id = s.panel_id
                 where s.tetkik_id = @p0
                 order by p.ad
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // SON 30 GUN ISTEM SAYISI: katalogda "bu tetkik gercekten
            //   kullaniliyor mu" sorusunun cevabi.
            var istemAdedi = await veri.TekDegerAsync<long>("""
                select count(*) from public.lab_istem_satir s
                 where s.tetkik_id = @p0 and s.ekleme_tarihi >= now() - interval '30 days'
                """, [id], iptal);

            return Results.Ok(new { tetkik, referanslar, paneller, istemAdedi,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // -------------------------------------------------- calisma takvimi ---
        // GET /api/lab/calisma-takvimi - tetkik kartinin "Çalışma Zamanları"
        //   sekmesindeki HAFTALIK TAKVIM ve UC OZET KUTUSU (487).
        //
        // Duzen PARAMETRE olarak gelir, tetkik id ile degil: kullanici
        //   ekranda duzeni degistirirken onizleme ANINDA guncellensin -
        //   kaydetmeden once "bu ayarla sonuc ne zaman cikar" gorulmeli.
        //   Hesabi yine SUNUCU yapar (fn_lab_calisma_sonuc_zamani): ayni kural
        //   kayitli tetkik icin de calisiyor, iki ayri hesap iki farkli saat
        //   soylerdi.
        grup.MapGet("/calisma-takvimi", async (
            short? duzen, short? gunler, string? saatler, int? kabulSonDk,
            int? tatDk, int? acilTatDk, short? acilBeklemez, DateTime? kabul,
            BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            var d   = duzen ?? 0;
            var g   = gunler ?? 0;
            var sa  = saatler ?? "";
            var ksd = kabulSonDk ?? 0;
            var tat = tatDk ?? 0;
            var atat = acilTatDk ?? 0;
            var ab  = acilBeklemez ?? 1;
            var an  = kabul ?? DateTime.Now;

            // Deger NULL olabilir ("tanim eksik, bilmiyorum") - TekDegerAsync
            //   struct'ta da null donebilsin diye nullable T ile cagrilir.
            async Task<DateTime?> ZamanAsync(DateTime kabulAn, short acil)
                => await veri.TekDegerAsync<DateTime?>(
                    "select public.fn_lab_calisma_sonuc_zamani(" +
                    "  @p0::smallint, @p1::smallint, @p2, @p3, @p4, @p5, @p6::smallint, " +
                    "  @p7, @p8::smallint)",
                    [d, g, sa, ksd, tat, atat, ab, kabulAn, acil], iptal);

            // HAFTALIK TAKVIM: saat satiri x gun sutunu. Her hucre o gun o
            //   saatte CALISILIR mi, ve kabul son saati kacta biter.
            var saatListesi = sa.Split(',', StringSplitOptions.RemoveEmptyEntries |
                                            StringSplitOptions.TrimEntries)
                                .Where(x => TimeOnly.TryParse(x, out _))
                                .Select(x => TimeOnly.Parse(x))
                                .OrderBy(x => x).ToList();
            // Sürekli / mesai düzeninde seri saati yoktur - takvim çizilmez.
            var hafta = new List<object>();
            if (d == 2)
                foreach (var saat in saatListesi)
                {
                    var gunler7 = new List<object>();
                    for (var i = 0; i < 7; i++)
                    {
                        var acikMi = (g & (1 << i)) > 0;
                        gunler7.Add(new
                        {
                            acik = acikMi,
                            // Sonuç saati o günün serisine göre: çalışma + TAT.
                            sonuc = acikMi ? saat.AddMinutes(tat).ToString("HH:mm") : null,
                        });
                    }
                    hafta.Add(new
                    {
                        saat = saat.ToString("HH:mm"),
                        kabulSon = saat.AddMinutes(-ksd).ToString("HH:mm"),
                        gunler = gunler7,
                    });
                }

            // ÜÇ ÖZET: mockup'taki kutular. Hepsi AYNI kuraldan geçer.
            var simdi = await ZamanAsync(an, 0);
            // "Kabul son saatinden sonra": bir sonraki seriye kalan numune.
            //   Bir dakika sonrası sorulur - sınırın hangi tarafına düştüğü
            //   kullanıcının en çok yanıldığı yerdir.
            var kacan = await ZamanAsync(
                (simdi is { } ilk && d == 2 ? ilk.AddMinutes(-tat) : an).AddMinutes(-ksd + 1), 0);
            var acilZaman = await ZamanAsync(an, 1);

            return Results.Ok(new
            {
                duzen = d, hafta,
                ozet = new
                {
                    simdiKabul = an,
                    simdi,
                    kacirilan = kacan,
                    acil = acilZaman,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ------------------------------------------------------------ istem ---

        // POST /api/lab/istem - istem açar, tüp planını ve barkodları üretir.
        //   Panel satırı tetkiklerine açılır; aynı tüpteki tetkikler TEK barkoda
        //   bağlanır (hastadan gereksiz tüp alınmaz).
        //
        //   IKI YOL (637): `belgeId` ile BAŞVURUDAN, ya da `disKurumId` +
        //   `hastaId` ile DIŞ KURUM NUMUNESİNDEN. İkincisinde hasta burada
        //   değildir - başvuru, ücretlendirme ve e-Nabız yoktur; fatura
        //   gönderen kuruma kesilir.
        grup.MapPost("/istem", async (
            IstemIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Ekle);

            var id = await servis.IstemAcAsync(
                istek.BelgeId, istek.Satirlar ?? [], istek.Oncelik ?? 1,
                istek.KlinikBilgi ?? "", istek.TaniIcd ?? "", baglam, iptal,
                istek.HastaId, istek.DisKurumId);

            var ozet = await IstemOzetAsync(veri, id, iptal);
            return Results.Ok(new { id, ozet.IstemNo, ozet.Barkodlar, ozet.TetkikSayisi,
                                    mesaj = $"İstem açıldı: {ozet.IstemNo} · "
                                          + $"{ozet.TetkikSayisi} tetkik · "
                                          + $"{ozet.Barkodlar.Count} tüp",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/istem/{id} - istem + numune + sonuç (rapor/ekran kaynağı).
        grup.MapGet("/istem/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            // Mockup lab_istem_numune_kabul.html sag panel: hasta satiri
            //   "Ayse Yilmaz · 39 K · 1234567****" - yas/cinsiyet ve MASKELI
            //   kimlik ekranda birlikte durur (banko tupu hastayla eslerken
            //   ad benzerligine guvenemez). Kimlik son dort hane gizli
            //   gelir: dogrulama icin ilk yedi hane yeter.
            // HAZIRLIK NOTU tetkik katalogundan toplanir (lab_tetkik.
            //   hazirlik_notu): "8 saat ac", "sabah ilaci alinmadan" gibi
            //   kosul saglanmadiysa sonuc yorumlanamaz.
            var basli = await veri.TekAsync("""
                select i.id, i.istem_no, i.istem_tarihi, i.durum, i.oncelik,
                       i.taraf_id, coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''),
                                            h.unvan) as hasta,
                       i.klinik_bilgi, i.tani_icd, i.hedef_bitis, i.belge_id,
                       case coalesce(th.cinsiyet, 0)
                            when 1 then 'E' when 2 then 'K' else '' end as cinsiyet,
                       case when th.dogum_tarihi is null then ''
                            when age(th.dogum_tarihi) >= interval '2 years'
                                 then extract(year from age(th.dogum_tarihi))::int::text || 'y'
                            when age(th.dogum_tarihi) >= interval '1 month'
                                 then (extract(year from age(th.dogum_tarihi))::int * 12
                                     + extract(month from age(th.dogum_tarihi))::int)::text || 'ay'
                            else (current_date - th.dogum_tarihi)::text || 'g' end as yas,
                       case when coalesce(h.vkno, '') = '' then ''
                            else left(h.vkno, greatest(length(h.vkno) - 4, 0))
                               || repeat('*', least(length(h.vkno), 4)) end as kimlik,
                       coalesce(bg.belge_no, '') as protokol,
                       coalesce(p.ad, '') as hekim,
                       coalesce((select string_agg(distinct nullif(trim(t2.hazirlik_notu), ''),
                                                   ' · ')
                                   from public.lab_istem_satir s2
                                   join public.lab_tetkik t2 on t2.id = s2.tetkik_id
                                  where s2.istem_id = i.id and s2.durum <> 0), '') as hazirlik,
                       -- KAYNAK (433): istem nereden acildi. Dis istemde
                       --   gonderen kurum, ic istemde basvuru numarasi -
                       --   numunenin nereden geldigi kabul kararini etkiler.
                       case i.kaynak when 2 then 'Teletıp' when 3 then 'Banko'
                            when 4 then 'Dış kurum' when 5 then 'Check-up'
                            else 'Muayene istemi' end as kaynak_ad,
                       coalesce(dk.unvan, '') as dis_kurum,
                       -- UYARI BANDI: sonucu ya da numune alimini degistiren
                       --   her sey hasta kartindan gelir (v_hasta_tibbi_ozet).
                       coalesce(o.alerjiler, '') as alerjiler,
                       coalesce(o.kronik_tanilar, '') as kronik,
                       coalesce(o.agir_alerji, 0) as agir_alerji,
                       -- Kan grubu KOD tutulur (kod_liste 'taraf.kan_grubu');
                       --   ekranda adiyla gorunmeli.
                       coalesce((select d.ad from public.kod_deger d
                                  join public.kod_liste l on l.id = d.liste_id
                                 where l.kod = 'taraf.kan_grubu'
                                   and d.deger = th.kan_grubu), '') as kan_grubu,
                       coalesce(h.kod, '') as dosya_no
                  from public.lab_istem i
                  join public.taraf h on h.id = i.taraf_id
                  left join public.taraf_hasta th on th.id = i.taraf_id
                  left join public.belge bg on bg.id = i.belge_id
                  left join public.v_personel_lookup p on p.id = i.personel_id
                  left join public.taraf dk on dk.id = i.dis_kurum_id
                  left join public.v_hasta_tibbi_ozet o on o.hasta_id = i.taraf_id
                 where i.id = @p0
                """, [id],
                o => new { Id = o.GetInt32(0), IstemNo = o.GetString(1),
                           Tarih = o.GetDateTime(2), Durum = o.GetInt16(3),
                           Oncelik = o.GetInt16(4), HastaId = o.GetInt32(5),
                           Hasta = o.GetString(6), Klinik = o.GetString(7),
                           Tani = o.GetString(8),
                           HedefBitis = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                           BelgeId = o.IsDBNull(10) ? (int?)null : o.GetInt32(10),
                           Cinsiyet = o.GetString(11), Yas = o.GetString(12),
                           Kimlik = o.GetString(13), Protokol = o.GetString(14),
                           Hekim = o.GetString(15), Hazirlik = o.GetString(16),
                           KaynakAd = o.GetString(17), DisKurum = o.GetString(18),
                           Alerjiler = o.GetString(19), Kronik = o.GetString(20),
                           AgirAlerji = o.GetInt64(21) > 0, KanGrubu = o.GetString(22),
                           DosyaNo = o.GetString(23) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            // Sonuç ONAYLI satırın kendisinden okunur; bayrak/referans o gün
            //   hesaplanmış hâliyle durur, sonradan referans değişse rapor aynı kalır.
            var satirlar = await veri.ListeAsync("""
                select s.id, s.kod, s.ad, s.durum, n.barkod, n.durum as numune_durum,
                       ls.id as sonuc_id, ls.deger_metin, ls.birim, ls.bayrak,
                       -- REFERANS: sonuc varsa O GUN damgalanan aralik
                       --   (sonradan referans degisse rapor aynen kalir),
                       --   yoksa tetkigin YURURLUKTEKI araligi. Sonucsuz
                       --   satirda bos gostermek, teknisyeni degeri
                       --   neyle kiyaslayacagini bilmeden birakirdi.
                       coalesce(ls.referans_alt, ref.alt) as referans_alt,
                       coalesce(ls.referans_ust, ref.ust) as referans_ust,
                       coalesce(nullif(ls.referans_metin, ''), ref.metin, '')
                           as referans_metin, ls.panik,
                       ls.delta_uyari, ls.durum as sonuc_durum, ls.olcum_zamani,
                       ls.onay_zamani, ls.yorum,
                       -- BOLUM ekranin gruplama olcusu (mockup: "Biyokimya /
                       --   Hematoloji / Mikrobiyoloji"): satirin kendisinde
                       --   yok, tetkik katalogundan gelir.
                       coalesce(t.bolum, 0) as bolum,
                       -- NUMUNE KABUL KOLONLARI (mockup: Numune · Tup · Barkod ·
                       --   Alindi · Kabul · Hedef TAT · Cihaz). Tup plani
                       --   uretilmemisse tetkik katalogunun ONERDIGI numune/tup
                       --   gosterilir - banko hangi tupu hazirlayacagini
                       --   barkod basilmadan da gormeli.
                       coalesce(n.numune_tipi, t.numune_tipi, 0)::smallint as numune_tipi,
                       coalesce(n.tup_tipi, t.tup_tipi, 0)::smallint as tup_tipi,
                       n.alim_zamani, n.kabul_zamani,
                       -- ACIL istemde sozu verilen sure farklidir; hangisinin
                       --   gecerli oldugu ekranda gorunmezse gecikme yanlis
                       --   olculur.
                       case when i.oncelik = 3 then coalesce(t.acil_tat_dk, t.hedef_tat_dk)
                            else t.hedef_tat_dk end as hedef_tat,
                       coalesce(c.kod, c.ad, '') as cihaz,
                       -- SONUCU KIM/NASIL GIRDI (kullanici: "sonucu elle
                       --   degistirdigim / girdigim bilgisi nerede"):
                       --   cihaz_id bos ise ELLE girilmistir. Giren kisi ve
                       --   olcum zamani sonucun kendi satirinda duruyor;
                       --   ekranda gostermeyince "bu deger nereden geldi"
                       --   sorusunun cevabi yalniz veritabaninda kaliyordu.
                       case when ls.id is null then ''
                            when ls.cihaz_id is null then 'Elle'
                            else 'Cihaz' end as giris_turu,
                       coalesce(gk.ad, '') as giren,
                       coalesce(ls.duzeltme_neden, '') as duzeltme_neden,
                       coalesce(ls.tekrar_no, 0) as tekrar_no,
                       -- PANEL: satir hangi panelden dogdu. Hemogram 23,
                       --   tam idrar 21 satir uretiyor - ekran onlari tek
                       --   baslik altinda toplasin diye adi da tasinir.
                       coalesce(s.panel_id, 0) as panel_id,
                       coalesce(lp.ad, '') as panel_ad
                  from public.lab_istem_satir s
                  join public.lab_istem i on i.id = s.istem_id
                  left join public.lab_numune n on n.id = s.numune_id
                  left join public.lab_tetkik t on t.id = s.tetkik_id
                  left join public.lab_panel lp on lp.id = s.panel_id
                  left join public.cihaz c
                         on c.id = coalesce(s.cihaz_id, t.varsayilan_cihaz_id)
                  left join lateral (
                        select * from public.lab_sonuc x
                         where x.istem_satir_id = s.id and x.durum <> 4
                         order by x.id desc limit 1) ls on true
                  -- SONUCU GIREN kisi: `ls` lateral'inden SONRA baglanir,
                  --   once yazilirsa "ls does not exist" verir.
                  left join public.v_kullanici_lookup gk on gk.id = ls.ekleyen
                  -- Referans HASTAYA gore secilir (yas/cinsiyet bandi);
                  --   642 hemogram ve tam idrar icin cocuk bantlarini da
                  --   tasiyor, fn EN DAR araligi doner.
                  left join lateral public.fn_lab_referans(
                        s.tetkik_id, i.taraf_id, current_date) ref on true
                 where s.istem_id = @p0 and s.durum <> 0
                 order by s.sira, s.id
                """, [id],
                o => new {
                    SatirId = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2),
                    Durum = o.GetInt16(3),
                    Barkod = o.IsDBNull(4) ? "" : o.GetString(4),
                    NumuneDurum = o.IsDBNull(5) ? (short)0 : o.GetInt16(5),
                    SonucId = o.IsDBNull(6) ? (long?)null : o.GetInt64(6),
                    Deger = o.IsDBNull(7) ? "" : o.GetString(7),
                    Birim = o.IsDBNull(8) ? "" : o.GetString(8),
                    Bayrak = o.IsDBNull(9) ? "" : o.GetString(9),
                    // Alan adlari diger lab uclariyla AYNI: ekran ayni
                    //   bilgiyi iki farkli adla okumak zorunda kalmasin.
                    ReferansAlt = o.IsDBNull(10) ? (decimal?)null : o.GetDecimal(10),
                    ReferansUst = o.IsDBNull(11) ? (decimal?)null : o.GetDecimal(11),
                    ReferansMetin = o.IsDBNull(12) ? "" : o.GetString(12),
                    Panik = !o.IsDBNull(13) && o.GetInt16(13) == 1,
                    DeltaUyari = !o.IsDBNull(14) && o.GetInt16(14) == 1,
                    SonucDurum = o.IsDBNull(15) ? (short)0 : o.GetInt16(15),
                    OlcumZamani = o.IsDBNull(16) ? (DateTime?)null : o.GetDateTime(16),
                    OnayZamani = o.IsDBNull(17) ? (DateTime?)null : o.GetDateTime(17),
                    Yorum = o.IsDBNull(18) ? "" : o.GetString(18),
                    Bolum = o.GetInt16(19),
                    NumuneTipi = o.GetInt16(20), TupTipi = o.GetInt16(21),
                    Alim = o.IsDBNull(22) ? (DateTime?)null : o.GetDateTime(22),
                    Kabul = o.IsDBNull(23) ? (DateTime?)null : o.GetDateTime(23),
                    HedefTat = o.IsDBNull(24) ? (int?)null : o.GetInt32(24),
                    Cihaz = o.GetString(25),
                    GirisTuru = o.GetString(26), Giren = o.GetString(27),
                    DuzeltmeNeden = o.GetString(28), TekrarNo = o.GetInt16(29),
                    PanelId = o.GetInt32(30), PanelAd = o.GetString(31) }, iptal);

            // NUMUNEYI ALAN ve KALITE mockup'ta sag panelde: "Hemsire N. Koc ·
            //   Kan alma 2", "Uygun / hemoliz…". Kabul edilmis tup icin bu iki
            //   alan sonucun guvenilirlik kaydidir.
            var numuneler = await veri.ListeAsync("""
                select n.id, n.barkod, n.numune_tipi, n.tup_tipi, n.durum,
                       n.alim_zamani, n.kabul_zamani, n.ret, n.ret_neden,
                       n.ret_aciklama, coalesce(n.kalite, 0)::smallint as kalite,
                       coalesce(a.ad, '') as alan,
                       -- 433: 1 kan alma · 2 servis · 3 ev · 4 dış. Numunenin
                       --   NEREDE alindigi kalite tartismasinda ilk sorudur.
                       case coalesce(n.alim_yeri, 1) when 2 then 'Servis'
                            when 3 then 'Ev' when 4 then 'Dış' else 'Kan alma' end
                         as alim_yeri,
                       coalesce(n.saklama_yeri, '') as saklama_yeri,
                       -- SERUM INDEKSI: sonucun guvenilirlik olcusu. Hemolizli
                       --   tupten cikan potasyum, laboratuvarin degil numunenin
                       --   sonucudur - deger ekranda kaliteyle birlikte durur.
                       coalesce(n.hemoliz_idx, 0)::smallint as hemoliz,
                       coalesce(n.lipemi_idx, 0)::smallint as lipemi,
                       coalesce(n.ikter_idx, 0)::smallint as ikter,
                       n.saklama_sicaklik
                  from public.lab_numune n
                  left join public.v_personel_lookup a on a.id = n.alan_id
                 where n.istem_id = @p0 order by n.id
                """, [id],
                o => new { Id = o.GetInt32(0), Barkod = o.GetString(1),
                           NumuneTipi = o.GetInt16(2), TupTipi = o.GetInt16(3),
                           Durum = o.GetInt16(4),
                           Alim = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                           Kabul = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                           Ret = o.GetInt16(7) == 1,
                           RetNeden = o.IsDBNull(8) ? (short?)null : o.GetInt16(8),
                           RetAciklama = o.GetString(9), Kalite = o.GetInt16(10),
                           Alan = o.GetString(11), AlimYeri = o.GetString(12),
                           SaklamaYeri = o.GetString(13), Hemoliz = o.GetInt16(14),
                           Lipemi = o.GetInt16(15), Ikter = o.GetInt16(16),
                           SaklamaSicaklik = o.IsDBNull(17) ? (short?)null : o.GetInt16(17) },
                iptal);

            // TAT: SOZ VERILEN SURE, bolum bolum. Saat KABULDE baslar - numune
            //   laboratuvara ulasmadan sure isletmek, gecikmeyi kan alma
            //   birimine yazardi. Yuzde ve kalan dakika SUNUCUDA hesaplanir:
            //   ekran ayni sayiyi ikinci kez turetmesin.
            var tatlar = await veri.ListeAsync("""
                select coalesce(t.bolum, 0) as bolum,
                       max(case when i.oncelik = 3
                                then coalesce(nullif(t.acil_tat_dk, 0), t.hedef_tat_dk)
                                else t.hedef_tat_dk end) as hedef_dk,
                       min(n.kabul_zamani) as baslangic,
                       count(*) filter (where s.durum in (3, 4, 5)) as biten,
                       count(*) as toplam
                  from public.lab_istem_satir s
                  join public.lab_istem i on i.id = s.istem_id
                  left join public.lab_tetkik t on t.id = s.tetkik_id
                  left join public.lab_numune n on n.id = s.numune_id
                 where s.istem_id = @p0 and s.durum <> 0
                 group by coalesce(t.bolum, 0)
                 order by 1
                """, [id],
                o => {
                    var hedefDk = o.IsDBNull(1) ? 0 : o.GetInt32(1);
                    var baslangic = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2);
                    var bitis = baslangic is { } b && hedefDk > 0
                        ? b.AddMinutes(hedefDk) : (DateTime?)null;
                    var kalanDk = bitis is { } bt
                        ? (int)Math.Round((bt - DateTime.Now).TotalMinutes) : (int?)null;
                    // Yuzde = gecen sure / hedef. Kabul edilmemis istemde 0:
                    //   cubugun dolmasi icin once saatin baslamasi gerekir.
                    var yuzde = baslangic is { } b2 && hedefDk > 0
                        ? Math.Clamp((int)Math.Round(
                            (DateTime.Now - b2).TotalMinutes / hedefDk * 100), 0, 100)
                        : 0;
                    return new { Bolum = o.GetInt16(0), HedefDk = hedefDk,
                                 Baslangic = baslangic, Bitis = bitis, KalanDk = kalanDk,
                                 Yuzde = yuzde, Biten = o.GetInt64(3), Toplam = o.GetInt64(4) };
                }, iptal);

            // SON LABORATUVAR: ayni hastanin ONAYLI onceki sonuclari. Delta
            //   kontrolunun dayanagi budur; hekim "yukselmis mi" sorusunu
            //   ayri ekran acmadan cevaplayabilmeli.
            var oncekiler = await veri.ListeAsync("""
                select coalesce(t.ad, ls2.ad) as ad, ls.deger_metin, coalesce(ls.birim, ''),
                       coalesce(ls.bayrak, ''), ls.olcum_zamani
                  from public.lab_sonuc ls
                  join public.lab_istem_satir ls2 on ls2.id = ls.istem_satir_id
                  join public.lab_istem i2 on i2.id = ls2.istem_id
                  left join public.lab_tetkik t on t.id = ls2.tetkik_id
                 where i2.taraf_id = @p1 and i2.id <> @p0 and ls.durum = 3
                 order by ls.olcum_zamani desc nulls last, ls.id desc
                 limit 6
                """, [id, basli.HastaId],
                o => new { Ad = o.GetString(0),
                           Deger = o.IsDBNull(1) ? "" : o.GetString(1),
                           Birim = o.GetString(2), Bayrak = o.GetString(3),
                           Zaman = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4) }, iptal);

            return Results.Ok(new { basli.Id, basli.IstemNo, basli.Tarih, basli.Durum,
                                    basli.Oncelik, basli.HastaId, basli.Hasta,
                                    basli.Klinik, basli.Tani, basli.HedefBitis,
                                    basli.BelgeId, basli.Cinsiyet, basli.Yas,
                                    basli.Kimlik, basli.Protokol, basli.Hekim,
                                    basli.Hazirlik, basli.KaynakAd, basli.DisKurum,
                                    basli.Alerjiler, basli.Kronik, basli.AgirAlerji,
                                    basli.KanGrubu, basli.DosyaNo,
                                    numuneler, satirlar, tatlar, oncekiler,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/basvuru/{belgeId}/istemler - muayene "İstem & Sonuçlar"
        //   sekmesi: başvurunun istemleri ve tamamlanma durumu.
        grup.MapGet("/basvuru/{belgeId:int}/istemler", async (
            int belgeId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select i.id, i.istem_no, i.istem_tarihi, i.durum, i.oncelik,
                       (select count(*) from public.lab_istem_satir s
                         where s.istem_id = i.id and s.durum <> 0) as tetkik,
                       (select count(*) from public.lab_istem_satir s
                         where s.istem_id = i.id and s.durum = 5) as onayli,
                       (select count(*) from public.lab_istem_satir s
                          join public.lab_sonuc ls on ls.istem_satir_id = s.id
                         where s.istem_id = i.id and ls.panik = 1
                           and ls.durum <> 4) as panik
                  from public.lab_istem i
                 where i.belge_id = @p0 and i.durum <> 0
                 order by i.id desc
                """, [belgeId],
                o => new { Id = o.GetInt32(0), IstemNo = o.GetString(1),
                           Tarih = o.GetDateTime(2), Durum = o.GetInt16(3),
                           Oncelik = o.GetInt16(4), Tetkik = o.GetInt64(5),
                           Onayli = o.GetInt64(6), Panik = o.GetInt64(7) }, iptal);

            return Results.Ok(new { belgeId, istemler = liste,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/istem/{id}/numune-plani - kart ekranından açılmış
        //   istemin barkodlarını üretir. Kart yolu tüp planını çalıştırmaz;
        //   barkodsuz istem kan alma biriminde "hangi tüp" sorusunu cevapsız
        //   bırakırdı.
        grup.MapPost("/istem/{id:int}/numune-plani", async (
            int id, BaglamCozucu cozucu, LabServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Ekle);

            var barkodlar = await servis.NumunePlaniAsync(id, baglam, iptal);
            return Results.Ok(new { id, barkodlar,
                mesaj = $"{barkodlar.Count} tüp barkodu üretildi: "
                      + string.Join(", ", barkodlar),
                izlemeNo = baglam.IzlemeNo });
        });

        // ----------------------------------------------------------- numune ---

        // POST /api/lab/numune/{id}/durum - alındı (2) / kabul (3) / ret (0).
        //   TAT kabulde başlar; ret satırları "tekrar bekliyor"a alır.
        grup.MapPost("/numune/{id:int}/durum", async (
            int id, NumuneDurumIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Degistir);

            var mesaj = await servis.NumuneDurumAsync(id, istek.Durum, istek.Kalite,
                istek.RetNeden, istek.Aciklama ?? "", baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/istem/{id}/numune-durum - İSTEMİN TÜM TÜPLERİ.
        //   Mockup araç çubuğu ("✔ Numune Kabul" / "✖ Numune Ret") istem
        //   satırının üzerindedir: banko hastanın tüplerini birlikte işler.
        grup.MapPost("/istem/{id:int}/numune-durum", async (
            int id, NumuneDurumIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Degistir);

            var mesaj = await servis.IstemNumuneDurumAsync(id, istek.Durum, istek.Kalite,
                istek.RetNeden, istek.Aciklama ?? "", baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/istem/{id}/saklama - tüplerin saklama yeri/sıcaklığı.
        //   Mockup "🧊 Saklama Yeri": çalışılmayı bekleyen tüp nerede duruyor?
        //   Kayıtsız buzdolabı, tekrar çalışma gerektiğinde numuneyi
        //   bulunamaz hâle getirir.
        grup.MapPost("/istem/{id:int}/saklama", async (
            int id, SaklamaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Degistir);

            var yer = (istek.Yer ?? "").Trim();
            if (yer.Length == 0)
                throw GentegreHatasi.Dogrulama("Saklama yeri zorunlu.",
                    [new("yer", "Saklama yeri boş bırakılamaz.")]);

            var say = await veri.CalistirAsync("""
                update public.lab_numune
                   set saklama_yeri = @p1, saklama_sicaklik = @p2,
                       degistiren = @p3, degistirme_tarihi = now()
                 where istem_id = @p0 and ret = 0
                """, [id, yer, istek.Sicaklik, baglam.KullaniciId], iptal);

            return Results.Ok(new { id, say,
                mesaj = say == 0 ? "Güncellenecek tüp bulunamadı."
                                 : $"{say} tüp için saklama yeri: {yer}.",
                izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/numune/barkod/{barkod} - barkod okutunca kabul ekranı.
        grup.MapGet("/numune/barkod/{barkod}", async (
            string barkod, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Gor);

            var n = await veri.TekAsync("""
                select n.id, n.barkod, n.durum, n.numune_tipi, n.tup_tipi,
                       n.istem_id, i.istem_no, i.oncelik, n.hasta_id,
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan),
                       n.alim_zamani, n.kabul_zamani,
                       (select count(*) from public.lab_istem_satir s
                         where s.numune_id = n.id and s.durum <> 0)
                  from public.lab_numune n
                  join public.lab_istem i on i.id = n.istem_id
                  join public.taraf h on h.id = n.hasta_id
                 where n.barkod = @p0
                """, [barkod],
                o => new { Id = o.GetInt32(0), Barkod = o.GetString(1),
                           Durum = o.GetInt16(2), NumuneTipi = o.GetInt16(3),
                           TupTipi = o.GetInt16(4), IstemId = o.GetInt32(5),
                           IstemNo = o.GetString(6), Oncelik = o.GetInt16(7),
                           HastaId = o.GetInt32(8), Hasta = o.GetString(9),
                           Alim = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10),
                           Kabul = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
                           Tetkik = o.GetInt64(12) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi($"'{barkod}' barkodlu numune yok.");

            return Results.Ok(new { n.Id, n.Barkod, n.Durum, n.NumuneTipi, n.TupTipi,
                                    n.IstemId, n.IstemNo, n.Oncelik, n.HastaId, n.Hasta,
                                    n.Alim, n.Kabul, n.Tetkik,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------------ sonuç ---

        // POST /api/lab/sonuc - kural motoru burada çalışır: referans, bayrak,
        //   panik, delta. Temiz sonuç oto-onaya gider, bayraklı sonuç insana.
        grup.MapPost("/sonuc", async (
            LabServisi.SonucIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Ekle);

            var s = await servis.SonucYazAsync(istek, null, null, baglam, iptal);
            return Results.Ok(new { s.SonucId, s.Bayrak, s.Panik, s.DeltaUyari, s.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/sonuc/{id}/onayla - aşama 1 teknik, 2 uzman (yayın).
        grup.MapPost("/sonuc/{id:long}/onayla", async (
            long id, OnayIstegi? istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var asama = istek?.Asama ?? 2;
            baglam.YetkiIste(asama == 1 ? "lab.sonuc" : "lab.onay", Islem.Degistir);

            var (mesaj, istemId) = await servis.OnaylaAsync(id, asama, baglam, iptal);

            // e-NABIZ 105 (632): YAYIN onayinda (asama 2) paket uretilir.
            //   Teknik onayda degil - o sonucu henuz yayinlamiyor, hastanin
            //   dosyasina yazilmayan bir sonucu USS'ye bildirmek olurdu.
            //   Uretim sessizdir: paket uretilemezse onay dusmez.
            if (asama == 2)
                await ctx.RequestServices
                         .GetRequiredService<Servisler.EnabizTetikleyici>()
                         .LabSonucOnaylandiAsync(istemId, baglam.KullaniciId, iptal);

            return Results.Ok(new { id, asama, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/sonuc/{id}/duzelt - onaylı sonuç GÜNCELLENMEZ; eski satır
        //   iptal edilir, yenisi açılır. Neden zorunlu.
        grup.MapPost("/sonuc/{id:long}/duzelt", async (
            long id, DuzeltmeIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var s = await servis.DuzeltAsync(id, istek.Deger, istek.Neden, baglam, iptal);
            return Results.Ok(new { s.SonucId, s.Bayrak, s.Panik, s.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------------ panik ---

        grup.MapPost("/sonuc/{id:long}/panik", async (
            long id, PanikIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Degistir);

            var bildirimId = await servis.PanikBildirAsync(id, istek.BildirilenAd,
                istek.Kanal ?? 1, istek.Aciklama ?? "", baglam, iptal);
            return Results.Ok(new { bildirimId,
                mesaj = "Bildirim kaydedildi - TEYİT alınmadan kapanmış sayılmaz.",
                izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/panik/{id:int}/teyit", async (
            int id, TeyitIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Degistir);

            var mesaj = await servis.PanikTeyitAsync(id, istek.TeyitEden, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        MikrobiyolojiEkle(grup);
        GenetikEkle(grup);
        RaporEkle(grup);
        KaliteKontrolEkle(grup);
        OzetVeSonuclarEkle(grup);
        DisLaboratuvarEkle(grup);
    }


    private sealed record IstemOzeti(string IstemNo, List<string> Barkodlar,
                                     int TetkikSayisi);

    private static async Task<IstemOzeti> IstemOzetAsync(VeriKaynagi v, int istemId,
                                                         CancellationToken iptal)
    {
        var no = await v.TekDegerAsync<string>(
            "select istem_no from public.lab_istem where id = @p0", [istemId], iptal) ?? "";
        var barkodlar = await v.ListeAsync(
            "select barkod from public.lab_numune where istem_id = @p0 order by id",
            [istemId], o => o.GetString(0), iptal);
        var adet = await v.TekDegerAsync<long>(
            "select count(*) from public.lab_istem_satir where istem_id = @p0 and durum <> 0",
            [istemId], iptal);
        return new IstemOzeti(no, barkodlar, (int)adet);
    }
}
