using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

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
                                     int? HastaId = null, int? DisKurumId = null,
                                     /// <summary>Dış kurum kabulünde açılan başvurunun sözleşmesi (913):
                                     /// gönderen kurumun birden çok sözleşmesi varsa SEÇİLMELİDİR
                                     /// (tekse sunucu kendisi atar).</summary>
                                     int? SozlesmeId = null,
                                     /// <summary>Akılcı istem kararları (873): uyarı alan tetkik için gerekçe kodu.</summary>
                                     LabServisi.AkilciKarar[]? Akilci = null);
    public sealed record AkilciKontrolIstegi(int HastaId, int? HekimId, int[] TetkikIdler);
    public sealed record AkilciKararIstegi(int HastaId, int? HekimId, LabServisi.AkilciKarar[] Kararlar);
    public sealed record ReflektifIstegi(int[] TetkikIdler, string? Aciklama);

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
                // SONUÇ DOĞRULAMA (893, KTS L1): tetkik özetinde hangi
                //   sınırların tanımlı olduğu görünsün - "neden reddedildi"
                //   sorusu tetkik kartına gitmeden cevaplanabilmeli.
                ("mantikAlt",       "t.mantik_alt"),
                ("mantikUst",       "t.mantik_ust"),
                ("degerDeseni",     "t.deger_deseni"),
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
                                                   r.yas_ust_gun, r.gebelik) as kime,
                       -- CIHAZ/YONTEM (888): tetkik panelinde hangi araligin
                       --   hangi cihaza ait oldugu gorunmeli - "iki farkli
                       --   aralik" bilgisi kendi basina yanilticidir.
                       coalesce(c.ad, '') as cihaz, r.yontem
                  from public.lab_tetkik_referans r
                  left join public.cihaz c on c.id = r.cihaz_id
                 where r.tetkik_id = @p0
                 order by (r.cihaz_id is not null), r.sira, r.yas_alt_gun
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
            VeriKaynagi veri, BelgeDeposu belgeDepo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Ekle);

            // DIŞ KURUM KABULÜ DE BAŞVURU ÜZERİNDEN (913, kullanıcı): numune
            //   dışarıdan gelir ama HBYS'de her kabul bir başvurudur - böylece
            //   ücretlendirme (ödeyen = gönderen kurum) ve izlem başvuruda
            //   toplanır. Başvuru türü 5 (Laboratuvar / Görüntüleme): hasta
            //   fiziken gelmedi, poliklinik değil. Radyoloji dış kabulü zaten
            //   böyle açıyor - lab da aynı hizaya geliyor.
            var belgeId = istek.BelgeId;
            var disBasvuruAcildi = false;
            if (belgeId is not > 0 && istek.DisKurumId is int dk && dk > 0)
            {
                if (istek.HastaId is not > 0)
                    throw GentegreHatasi.Dogrulama("Numunenin hastası seçilmeli.",
                        [new("hastaId", "Hasta seçin; kayıtlı değilse önce hasta kartı açın.")]);

                await using var b0 = await veri.AcAsync(iptal);
                var hasta = await b0.TekAsync("""
                    select coalesce(unvan, '') as unvan, coalesce(vkno, '') as vkno,
                           coalesce(vd, '') as vd
                      from public.taraf where id = @p0
                    """, null, [istek.HastaId], OkuyucuGenisletmeleri.Sozluk, iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");

                // Fiyat listesi + kampanya belgenin KİMLİĞİ (274/302): ödeyen
                //   dış kurumun anlaşması varsa oradan, yoksa hastanınki.
                var listeId = await b0.TekDegerAsync<int?>(
                    "select public.fn_belge_varsayilan_liste(19, @p0, current_date, @p1)",
                    null, [istek.HastaId, dk], iptal);
                var kampanyaId = await b0.TekDegerAsync<int?>(
                    "select public.fn_taraf_kampanya(coalesce(@p1, @p0), current_date)",
                    null, [istek.HastaId, dk], iptal);

                var basvuru = new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = 19, ["tipi"] = 30, ["tarafId"] = istek.HastaId,
                    ["tarafUnvan"] = hasta["unvan"], ["tarafVkno"] = hasta["vkno"],
                    ["tarafVd"] = hasta["vd"], ["belgeTarihi"] = DateTime.Now,
                    ["belgeDovizi"] = "TL", ["dovizKuru"] = 1m,
                    ["fiyatListesiId"] = listeId, ["kampanyaId"] = kampanyaId,
                    // Başvuru türü 5 = Laboratuvar / Görüntüleme; ödeyen = gönderen kurum.
                    ["basvuruTuru"] = (short)5, ["odeyenKurumId"] = dk,
                    // SÖZLEŞME (913): kurumun birden çok sözleşmesi varsa istek
                    //   taşır; tekse null gider ve tetik kendisi atar.
                    ["sozlesmeId"] = istek.SozlesmeId,
                    ["aciklama"] = "Dış kurum numune kabul",
                };
                var (yeniBelgeId, _) = await belgeDepo.KaydetAsync(
                    basvuru, new List<Dictionary<string, JsonElement>>(),
                    new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                    new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);
                belgeId = yeniBelgeId;
                disBasvuruAcildi = true;
            }

            // disKurumId İSTEMDE de yazılır (kaynak=4) - başvurulu da olsa dış
            //   kurum numunesidir; fatura ödeyen kuruma, kaynak "dış" kalır.
            var id = await servis.IstemAcAsync(
                belgeId, istek.Satirlar ?? [], istek.Oncelik ?? 1,
                istek.KlinikBilgi ?? "", istek.TaniIcd ?? "", baglam, iptal,
                istek.HastaId, istek.DisKurumId, akilci: istek.Akilci);

            // ÜCRET (913): dış kabulde açılan başvuruya tetkik/panel ÜCRET
            //   satırları eklenir - ödeyen kurum + ücret girilmeden istem
            //   worklist'e düşmez. Ücret girilince belge_satir tetiği istemi
            //   serbest bırakır. Fiyat/pay bölüşümü BelgeDeposu'nda (tek hesap).
            if (disBasvuruAcildi && belgeId is int ucretBelgeId && ucretBelgeId > 0)
            {
                await using var bkonn = await veri.AcAsync(iptal);
                // Sipariş edilen kalemlerin FATURALANACAK hizmeti: panel tek
                //   SUT kalemidir (içeriği değil), tetkik kendi hizmeti.
                var hizmetIdler = new List<int>();
                foreach (var s in istek.Satirlar ?? [])
                {
                    int? hid = null;
                    if (s.PanelId is > 0)
                        hid = await bkonn.TekDegerAsync<int?>(
                            "select hizmet_id from public.lab_panel where id = @p0", null, [s.PanelId], iptal);
                    else if (s.TetkikId is > 0)
                        hid = await bkonn.TekDegerAsync<int?>(
                            "select hizmet_id from public.lab_tetkik where id = @p0", null, [s.TetkikId], iptal);
                    if (hid is int h && h > 0 && !hizmetIdler.Contains(h)) hizmetIdler.Add(h);
                }

                if (hizmetIdler.Count > 0)
                {
                    var (belge, satirlar) = await BelgeGovdesi.OkuAsync(bkonn, ucretBelgeId, iptal);
                    var sira = satirlar.Count;
                    var belgeKampanya = await bkonn.TekDegerAsync<int?>(
                        "select kampanya_id from public.belge where id = @p0", null, [ucretBelgeId], iptal);
                    // SÖZLEŞME İSKONTOSU (914) + KARŞILAMA: lab kalemlerine
                    //   sözleşmenin lab iskontosu; kurum payı (pay) = varsayılan
                    //   karşılama (ödeyen kurum yüzdesi) - "kurum öder, hasta ödemez".
                    var iskonto = await bkonn.TekDegerAsync<int>("""
                        select coalesce(s.lab_iskonto, 0) from public.belge_basvuru bb
                          join public.kurum_sozlesme s on s.id = bb.sozlesme_id where bb.id = @p0
                        """, null, [ucretBelgeId], iptal);
                    var karsilama = await bkonn.TekDegerAsync<decimal>("""
                        select coalesce(s.varsayilan_karsilama, 0) from public.belge_basvuru bb
                          join public.kurum_sozlesme s on s.id = bb.sozlesme_id where bb.id = @p0
                        """, null, [ucretBelgeId], iptal);
                    foreach (var hid in hizmetIdler)
                    {
                        var fiyat = await bkonn.TekDegerAsync<decimal>("""
                            select coalesce(
                                (select fs.fiyat from public.fiyat_listesi_satir fs
                                   join public.belge b on b.id = @p2
                                  where fs.liste_id = b.fiyat_listesi_id and fs.hizmet_id = @p1 limit 1),
                                (select f.fiyat from public.fn_belge_kalem_fiyati(
                                        @p0, 2::smallint, null, @p1, current_date) f limit 1),
                                0)
                            """, null, [istek.HastaId, hid, ucretBelgeId], iptal);
                        if (belgeKampanya is int kid && kid > 0 && fiyat > 0)
                            fiyat = await bkonn.TekDegerAsync<decimal>("""
                                select coalesce(f.fiyat, @p3) from public.fn_kampanya_fiyat(@p0, null, @p1, @p2) f limit 1
                                """, null, [kid, hid, fiyat, fiyat], iptal);
                        var kdv = await bkonn.TekDegerAsync<int>(
                            "select coalesce(kdv, 0) from public.hizmet where id = @p0", null, [hid], iptal);
                        satirlar.Add(BelgeGovdesi.Satir(new Dictionary<string, object?>
                        {
                            ["tur"] = 2, ["hizmetId"] = hid, ["miktar"] = 1m,
                            ["birimFiyat"] = fiyat, ["iskonto"] = (decimal)iskonto,
                            // Sözleşme iskontosu ÖN-ONAYLI: eşik onayına takılmasın.
                            ["iskontoKilit"] = iskonto > 0 ? 1 : 0,
                            // Kurum payı = karşılama (ödeyen kurum yüzdesi).
                            ["pay"] = (int)karsilama,
                            ["kdv"] = kdv, ["dovizCinsi"] = "TL",
                            ["sira"] = ++sira,
                        }));
                    }
                    await belgeDepo.GuncelleAsync(ucretBelgeId, belge, satirlar,
                        new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                        new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);
                    // KARŞILAMA DAĞILIMI (915): ödeyen kurum payını üret - "Kurumu
                    //   Öder" türünde tutar kurum kovasına (oss), hasta payı 0.
                    await bkonn.CalistirAsync(
                        "select public.fn_belge_satir_dagilim_tazele(id) "
                      + "from public.belge_satir where belge_id = @p0 and hizmet_id is not null",
                        null, [ucretBelgeId], iptal);
                }
            }

            var ozet = await IstemOzetAsync(veri, id, iptal);
            return Results.Ok(new { id, ozet.IstemNo, ozet.Barkodlar, ozet.TetkikSayisi,
                                    mesaj = $"İstem açıldı: {ozet.IstemNo} · "
                                          + $"{ozet.TetkikSayisi} tetkik · "
                                          + $"{ozet.Barkodlar.Count} tüp",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------ AKILCI TEST İSTEMİ (873) --
        // POST /api/lab/akilci-kontrol - istem GÖNDERİLMEDEN önce uyarılar: branş,
        //   tekrar süresi (son 2 sonuç), basamak, kapalı test + SKRS gerekçe
        //   seçenekleri. Kararı hekim verir; istem ucu aynı kontrolü yeniden
        //   yapar (istemci kararı taşır, kuralı değil).
        grup.MapPost("/akilci-kontrol", async (
            AkilciKontrolIstegi istek, BaglamCozucu cozucu, LabServisi servis, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            var s = await servis.AkilciKontrolAsync(baglanti, null, istek.HastaId,
                                                    istek.HekimId ?? baglam.KullaniciId, baglam.SubeId ?? 0,
                                                    istek.TetkikIdler ?? [], iptal);
            return Results.Ok(new { s.Uyarilar, s.Gerekceler, s.KlinikGerekceler, s.Basamak,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/akilci-karar - hekim uyarıya "Hayır" dedi: istem açılmaz,
        //   vazgeçme kaydı düşer (kılavuz §4.6).
        grup.MapPost("/akilci-karar", async (
            AkilciKararIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);
            await servis.AkilciVazgecAsync(istek.HastaId, istek.HekimId, istek.Kararlar ?? [], baglam, iptal);
            return Results.Ok(new { tamam = true, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/istem/{id}/reflektif - LAB UZMANI sonuç sonrası ek tetkik
        //   ister (§7); satır kaynak_turu 2, numune planı ardından üretilir.
        grup.MapPost("/istem/{id:int}/reflektif", async (
            int id, ReflektifIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Gor);
            var eklenen = await servis.ReflektifEkleAsync(id, istek.TetkikIdler ?? [], istek.Aciklama ?? "", baglam, iptal);
            var barkodlar = eklenen.Count > 0 ? await servis.NumunePlaniAsync(id, baglam, iptal) : [];
            return Results.Ok(new { eklenen, barkodlar,
                                    mesaj = eklenen.Count == 0 ? "Seçilen tetkikler istemde zaten var."
                                          : $"Reflektif istem: {string.Join(", ", eklenen)}" + (barkodlar.Count > 0 ? $" · {barkodlar.Count} yeni tüp" : ""),
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/istem/{id} - istem + numune + sonuç (rapor/ekran kaynağı).
        grup.MapGet("/istem/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, KayitErisimi erisim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);
            // KAYIT KAPSAMI (denetim #3): liste ile aynı şube/portal kuralı.
            await erisim.IsteAsync(baglam, "lab-istem", id, "İstem bulunamadı.", iptal);

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
                                            public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120)) as hasta,
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
                       coalesce(public.fn_taraf_ad(dk.unvan, dk.ad, dk.soyad)::varchar(120), '') as dis_kurum,
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
                       coalesce(lp.ad, '') as panel_ad,
                       -- KARAR SINIRI NOTU (896, KTS L15) EN SONA: okuyucu
                       --   POZİSYONEL, araya kolon koymak sonraki bütün
                       --   indeksleri kaydırırdı.
                       coalesce(ls.karar_notu, '') as karar_notu
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
                  -- Referans HASTAYA ve CIHAZA gore secilir (yas/cinsiyet
                  --   bandi + olcum yontemi, 888); 642 hemogram ve tam idrar
                  --   icin cocuk bantlarini da tasiyor, fn cihaza ozel satir
                  --   varsa onu, yoksa EN DAR araligi doner. Cihaz sirasi:
                  --   sonucun olculdugu cihaz > satirin cihazi > tetkikin
                  --   varsayilani - hangi cihazda olculduyse onun araligi.
                  left join lateral public.fn_lab_referans(
                        s.tetkik_id, i.taraf_id, current_date,
                        coalesce(ls.cihaz_id, s.cihaz_id, t.varsayilan_cihaz_id)
                        ) ref on true
                 where s.istem_id = @p0 and s.durum <> 0
                   -- TEST SEVIYESINDE YETKI (889, KTS L7): kisitli tetkikin
                   --   satiri izinsiz role HIC donmez. Yanittan sonradan
                   --   silmek, satir sayisini ve toplamlari bozardi.
                   and public.fn_lab_tetkik_izin_roller(s.tetkik_id, @p1, 'gor')
                 order by s.sira, s.id
                """, [id, baglam.RolIdleri.ToArray()],
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
                    PanelId = o.GetInt32(30), PanelAd = o.GetString(31),
                    KararNotu = o.GetString(32) }, iptal);

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

        // DELETE /api/lab/istem/{id} - yanlış açılan lab istemini sil (muayene
        //   grid'i "🗑"). Güvence: sonucu girilmiş / onaylı istem silinmez.
        grup.MapDelete("/istem/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Sil);
            await using var b = await veri.AcAsync(iptal);

            var durum = await b.TekDegerAsync<int?>(
                "select durum from public.lab_istem where id = @p0", null, [id], iptal);
            if (durum is null)
                return Results.NotFound(new { hata = new { kod = "BULUNAMADI", mesaj = "İstem bulunamadı." } });
            if (durum >= 4)
                throw GentegreHatasi.IsKurali("Sonuçlanmış/onaylı istem silinemez.");
            var sonucVar = await b.TekDegerAsync<bool>(
                "select exists(select 1 from public.lab_sonuc s " +
                "  join public.lab_istem_satir t on t.id = s.istem_satir_id " +
                " where t.istem_id = @p0)", null, [id], iptal);
            if (sonucVar)
                throw GentegreHatasi.IsKurali("Sonucu girilmiş istem silinemez.");

            await b.CalistirAsync("select public.fn_lab_istem_sil(@p0)", null, [id], iptal);
            return Results.Ok(new { id, mesaj = "Lab istemi silindi.", izlemeNo = baglam.IzlemeNo });
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

        // -------------------------------------------- sonuc gecmisi (886) ---
        // ONAYLARKEN ESKI SONUCLAR VE TEKRARLAR (KTS maddesi L9).
        //   Motor zaten vardi: sonuc yazilirken delta hesaplaniyor ve onceki
        //   deger satira yaziliyor. Eksik olan ERISIMDI - onaylayan uzman
        //   "bu hastanin bu tetkiki daha once kacti" sorusunu baska ekrana
        //   gidip arayarak cevapliyordu.
        //
        //   UC SEY BIR ARADA: gecmis (ayni hastanin BASKA istemlerindeki
        //   ONAYLI sonuclari), tekrarlar (ayni istemdeki oteki calismalar)
        //   ve bu sonucun kendi delta bilgisi.
        grup.MapGet("/satir/{id:int}/gecmis", async (
            int id, int? adet, VeriKaynagi veri, BaglamCozucu cozucu, KayitErisimi erisim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Gor);
            // Geçmiş hastanın ÖNCEKİ sonuçlarıdır: satır kapsamı + tetkik izni.
            await erisim.LabSatirIsteAsync(baglam, id, iptal);
            await using var b = await veri.AcAsync(iptal);

            var satirlar = await b.ListeAsync("""
                select kaynak, sonuc_id, istem_id, istem_no, tarih, deger, birim,
                       bayrak, panik, tekrar_no, cihaz, onay_durum
                  from public.fn_lab_sonuc_gecmis(@p0, @p1)
                """, null, [id, adet ?? 10], o => new
            {
                kaynak = o.GetString(0), sonucId = o.GetInt64(1), istemId = o.GetInt32(2),
                istemNo = o.GetString(3), tarih = o.GetDateTime(4),
                deger = o.IsDBNull(5) ? "" : o.GetString(5), birim = o.GetString(6),
                bayrak = o.GetString(7), panik = o.GetInt16(8) == 1,
                tekrarNo = (int)o.GetInt16(9), cihaz = o.GetString(10),
                onayDurum = (int)o.GetInt16(11),
            }, iptal);

            // DELTA: sonucun KENDI satirinda duruyor (433 yazarken hesapladi).
            var delta = await b.TekAsync("""
                select r.delta_onceki, r.delta_yuzde, r.delta_uyari,
                       coalesce(t.delta_yuzde, 0), coalesce(t.delta_gun, 0),
                       coalesce(nullif(r.deger_metin, ''),
                                trim(to_char(r.deger_sayisal, 'FM999999990.999999')), ''),
                       r.birim, r.bayrak, r.panik
                  from public.lab_sonuc r
                  left join public.lab_tetkik t on t.id = r.tetkik_id
                 where r.istem_satir_id = @p0
                 order by r.tekrar_no desc, r.id desc limit 1
                """, null, [id], o => new
            {
                oncekiDeger = o.IsDBNull(0) ? (decimal?)null : o.GetDecimal(0),
                yuzde = o.IsDBNull(1) ? (decimal?)null : o.GetDecimal(1),
                uyari = o.GetInt16(2) == 1,
                kuralYuzde = o.GetDecimal(3), kuralGun = o.GetInt32(4),
                deger = o.IsDBNull(5) ? "" : o.GetString(5), birim = o.GetString(6),
                bayrak = o.GetString(7), panik = o.GetInt16(8) == 1,
            }, iptal);

            return Results.Ok(new
            {
                gecmis = satirlar.Where(x => x.kaynak == "gecmis"),
                tekrarlar = satirlar.Where(x => x.kaynak == "tekrar"),
                delta,
            });
        });

        // ------------------------------------------------- ret kriterleri ---
        // RET NEDENLERİ ARTIK TANIMDAN GELİYOR (879, KTS maddesi L6).
        //   Eskiden sekiz sabit kod hem sunucuda hem ekranda ayrı ayrı
        //   yazılıydı; laboratuvar kendi kabul/ret ölçütlerini giremiyordu.
        //   Ekran bu listeyi okur: ret penceresinin seçenekleri de, numune
        //   kabulündeki "kalite" listesi de aynı satırlardan çıkar.
        grup.MapGet("/ret-nedenleri", async (
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select kod, ad, aciklama, kabulde_secilebilir, hasta_bilgilendir
                  from public.v_lab_ret_nedeni
                 where aktif = 1
                 order by sira, kod
                """, null, [], o => new
            {
                kod = (int)o.GetInt16(0), ad = o.GetString(1), aciklama = o.GetString(2),
                kabuldeSecilebilir = o.GetInt16(3) == 1, hastaBilgilendir = o.GetInt16(4) == 1,
            }, iptal);
            return Results.Ok(new { nedenler = liste });
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
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120)),
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
        ArsivEkle(grup);
        TekrarEkle(grup);
        GrafikEkle(grup);
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
