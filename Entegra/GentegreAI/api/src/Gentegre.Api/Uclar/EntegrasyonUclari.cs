using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ENTEGRASYON HESAPLARI uçları (336): bağlantı sınama ve SKRS kod listesi
/// senkronu.
///
/// SKRS (Sağlık Kodlama Referans Sunucusu) SOAP servisidir ve kimlik üç HTTP
/// başlığıyla verilir: KullaniciAdi · Sifre · UygulamaKodu (Sağlık.NET
/// hesabı). Bu yüzden kimlikler `entegrasyon_hesap` kaydından okunur -
/// kodda gömülü kimlik YOKTUR.
///
/// SKRS kodları YEREL KOD LİSTELERİNİN DEĞERİ olarak yazılır (kullanıcı
/// kararı): ayrı "yerel kod -> SKRS kodu" eşleme tablosu tutulmaz. Senkron,
/// hedef kod listesini SKRS'den gelen değerlerle günceller.
/// </summary>
public static class EntegrasyonUclari
{
    /// <summary>
    /// SKRS kod sistemi -> yerel kod listesi eşlemesi.
    ///
    /// Anahtar, SKRS'nin KOD SİSTEMİ ADIDIR (GetSkrsList'ten gelen `adi`) -
    /// servis listeyi adla değil GUID ile veriyor, GUID de kurulumdan kuruluma
    /// sabit ama listede aranarak bulunuyor. Adlar SKRS'de büyük harf ve
    /// Türkçe: "CİNSİYET", "MEDENİ HALİ", "KAN GRUBU"…
    /// </summary>
    private static readonly (string SkrsAd, string YerelListe)[] SkrsListeleri =
    {
        ("CİNSİYET",            "hasta.cinsiyet"),
        ("MEDENİ HALİ",         "hasta.medeni_hal"),
        ("YABANCI HASTA TÜRÜ",  "hasta.yabanci_turu"),
        ("KAN GRUBU",           "taraf.kan_grubu"),
        // 340: hekim branşı ve sigorta türü de SKRS'den gelir.
        ("PERSONEL BRANŞ KODU", "hekim.brans"),
        ("SİGORTALI TÜRÜ",      "taraf.sigorta_turu"),
        // KLINIK (455): once "SKRS'de boyle bir liste yok" diye not dusulmustu -
        //   katalog ASCII ile ("KLINIK") arandigi icin bulunamamis. Turkce
        //   yazimla liste duruyor: "KLİNİKLER". Kodlar `skrs.klinik` listesine
        //   yazilir; bolum kodu eslemesi oradan beslenir.
        ("KLİNİKLER",           "skrs.klinik"),
        // 505: SKRS katalogunda gercekten duran ve YEREL DEGERI KULLANILMAYAN
        //   iki liste daha. "REÇETE TÜRÜ" bilerek burada DEGIL: yerel degerleri
        //   22 binden fazla ilac kaydinda kullaniliyor, SKRS degerleriyle
        //   ezmek katalogu bozardi - o liste asagidaki ESLEME turuna girer.
        ("ÇIKIŞ ŞEKLİ",         "cikis.sekli"),
        ("VAKA TÜRÜ",           "muayene.vaka_turu"),
    };

    /// <summary>
    /// TABLO olarak tutulan SKRS listeleri (340): il · ilçe · ülke. Bunlar
    /// kod listesi değil, dolu ve referans verilen tablolardır - SKRS kodu
    /// `skrs_kod` kolonuna yazılır, `id` yerine geçmez. Sıra ÖNEMLİ: ilçe,
    /// ilin `skrs_kod`u dolduktan sonra bağlanabilir.
    /// </summary>
    private static readonly (string SkrsAd, string Hedef)[] SkrsTablolari =
    {
        ("İL",           "IL"),
        ("İLÇE",         "ILCE"),
        ("ÜLKE KODLARI", "ULKE"),
        // FAZ 0 (400): ICD-10 KENDI TABLOSUNDA (public.icd) - 20 bin satir
        //   kod_deger'e konmaz, arama/indeks ihtiyacini karsilamaz ve her
        //   combo cagrisini agirlastirirdi.
        //   SKRS'deki gercek ad "ICD10" (canli katalogdan dogrulandi; ayrica
        //   ICD-O morfoloji/yerlesim ve ICD10MSVS iliskisi listeleri var -
        //   onlar baska islerin kaynagi, tani katalogu degil).
        ("ICD10",               "ICD"),
    };


    public static void EntegrasyonUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/entegrasyon").WithTags("Entegrasyon")
                      .RequireAuthorization();

        // ------------------------------------------- SKRS liste katalogu ----
        // SKRS'nin 499 kod listesinin ADLARI. Eslemeyi kuran kisi (ya da bu
        //   kodu yazan) hangi listenin gercekte hangi adla durdugunu ancak
        //   boyle gorur: adlar kurulumdan kuruluma degisiyor ("TANI KODLARI"
        //   mi "ICD10" mi?) ve yanlis ad sessiz bir "yok" raporu uretiyor.
        grup.MapGet("/{id:int}/skrs-listeler", async (
            int id, string? ara, BaglamCozucu cozucu, VeriKaynagi veri,
            IHttpClientFactory istemciler, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var hesap = await HesapOkuAsync(baglanti, id, iptal);
            if (!string.Equals(hesap.Kod, "SKRS", StringComparison.OrdinalIgnoreCase))
                throw GentegreHatasi.IsKurali("Bu işlem yalnız SKRS hesabında çalışır.");

            var katalog = await SkrsKatalogAsync(hesap, istemciler, iptal);
            var suz = Anahtar(ara ?? "");
            var satirlar = katalog
                .Where(x => suz.Length == 0 || x.Key.Contains(suz, StringComparison.Ordinal))
                .OrderBy(x => x.Key, StringComparer.Ordinal)
                .Select(x => new { ad = x.Key, guid = x.Value })
                .ToList();

            return Results.Ok(new { toplam = katalog.Count, satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------- SKRS liste ONIZLEME ----
        // GET /api/entegrasyon/{id}/skrs-liste?ad=KLİNİKLER&ara=…
        //
        // Bir listenin KODLARINI senkron etmeden gösterir. Eşlemeyi kuran kişi
        //   "SKRS'de bu kodun karşılığı ne" sorusunu ancak listeyi görerek
        //   cevaplıyordu; kod eşleme ekranına elle SKRS kodu yazmak, yanlış
        //   kodun paketin içine sessizce girmesi demekti.
        grup.MapGet("/{id:int}/skrs-liste", async (
            int id, string ad, string? ara, BaglamCozucu cozucu, VeriKaynagi veri,
            IHttpClientFactory istemciler, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var hesap = await HesapOkuAsync(baglanti, id, iptal);
            if (!string.Equals(hesap.Kod, "SKRS", StringComparison.OrdinalIgnoreCase))
                throw GentegreHatasi.IsKurali("Bu işlem yalnız SKRS hesabında çalışır.");

            var katalog = await SkrsKatalogAsync(hesap, istemciler, iptal);
            if (!katalog.TryGetValue(Anahtar(ad ?? ""), out var guid))
                throw GentegreHatasi.IsKurali(
                    $"SKRS kod listesinde \"{ad}\" yok. Adları /skrs-listeler ile görebilirsiniz.");

            var kodlar = await SkrsListesiCekAsync(hesap, guid, istemciler, iptal);
            var suz = Anahtar(ara ?? "");
            var satirlar = kodlar
                .Where(k => suz.Length == 0 || Anahtar(k.Ad).Contains(suz, StringComparison.Ordinal)
                            || k.Kod.Contains(suz, StringComparison.Ordinal))
                .Take(500)
                .Select(k => new { kod = k.Kod, ad = k.Ad, ust = k.Ust })
                .ToList();

            return Results.Ok(new { ad, guid, toplam = kodlar.Count, satirlar,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------- SKRS klinik eşleme ----
        // POST /api/entegrasyon/{id}/skrs-klinik-esle
        //
        // Bölüm adlarını SKRS klinik adlarıyla eşleştirir ve **kodu boş olan**
        //   bölümlerin `kod` alanına SKRS klinik kodunu yazar.
        //
        // AYRI KOLON YOK (kullanıcı): kod bölümün kendi kimlik alanıdır;
        //   e-Nabız için ikinci bir kod kolonu, iki yerde tutulan ve zamanla
        //   ayrışan bir kod demekti.
        //
        // DOLU KODA DOKUNULMAZ: kurum kendi kodlamasını yapmış olabilir;
        //   toplu işlem onu ezerse hem bildirim hem kurumun kendi düzeni
        //   bozulur. Eşleşmeyenler rapora düşer, elle seçilir.
        grup.MapPost("/{id:int}/skrs-klinik-esle", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var toplamKod = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.v_skrs_klinik_lookup", null, [], iptal);

            // Eşleme ADA göre, Türkçe-duyarsız normalize ile (il/ilçe deseni,
            //   340). TEK eşleşme şartı: iki SKRS kliniği aynı ada düşüyorsa
            //   hangisinin doğru olduğunu makine bilemez - o bölüm elle
            //   seçilsin diye boş bırakılır.
            var yazilan = toplamKod == 0 ? 0 : await baglanti.TekDegerAsync<int>("""
                with aday as (
                    select d.id as departman_id,
                           (select min(k.id) from public.v_skrs_klinik_lookup k
                             where public.fn_ara_metin(split_part(k.ad, ' - ', 2))
                                   = public.fn_ara_metin(d.ad)) as kod,
                           (select count(*) from public.v_skrs_klinik_lookup k
                             where public.fn_ara_metin(split_part(k.ad, ' - ', 2))
                                   = public.fn_ara_metin(d.ad)) as adet
                      from public.departman d
                     where coalesce(nullif(trim(d.kod), ''), null) is null
                       and coalesce(d.durum, 1) = 1
                ),
                yazim as (
                    update public.departman d
                       set kod = a.kod::text, degistiren = @p0, degistirme_tarihi = now()
                      from aday a
                     where d.id = a.departman_id and a.adet = 1
                    returning 1
                )
                select count(*)::int from yazim
                """, null, [baglam.KullaniciId], iptal);

            var kalan = await baglanti.ListeAsync("""
                select d.id, d.ad, coalesce(d.kod, '') as "kod"
                  from public.departman d
                 where coalesce(nullif(trim(d.kod), ''), null) is null
                   and coalesce(d.durum, 1) = 1
                 order by d.ad limit 50
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                eslenen = yazilan,
                eslesmeyen = kalan,
                skrsKodSayisi = toplamKod,
                mesaj = toplamKod == 0
                    ? "SKRS klinik listesi boş - önce SKRS senkronunu çalıştırın."
                    : $"{yazilan} bölümün kodu SKRS klinik kodundan dolduruldu; "
                      + $"{kalan.Count} bölüm elle bekliyor.",
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ---------------------------------------------------- bağlantı sına --
        // Kimlik ve adres doğru mu: servise en ucuz çağrı yapılır, sonuç
        //   kayda yazılır (son_kullanim / son_sonuc) - kullanıcı ekranda görür.
        grup.MapPost("/{id:int}/sina", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, IHttpClientFactory istemciler,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var hesap = await HesapOkuAsync(baglanti, id, iptal);

            // SINAMA SERVISE GORE (340): SKRS'de gerçek kod listesi çağrısı
            //   yapılır; öteki servislerde SKRS SOAP gövdesi göndermek anlamsız
            //   (İzibiz "Servis kullanılmamaktadır" dönüyordu) - orada adresin
            //   ayakta olup olmadığına ve kimliğin dolu olduğuna bakılır.
            var (basarili, mesaj) = string.Equals(hesap.Kod, "SKRS", StringComparison.OrdinalIgnoreCase)
                ? await SkrsDenemeAsync(hesap, istemciler, iptal)
                : await AdresDenemeAsync(hesap, istemciler, iptal);
            await SonucYazAsync(baglanti, id, mesaj, iptal);

            return Results.Ok(new { basarili, mesaj });
        });

        // ------------------------------------------------ SKRS ham cekim ----
        // POST /api/entegrasyon/{id}/skrs-ham?ad=SUT
        //
        // Listenin kayitlarini OLDUGU GIBI `skrs_ham`a yazar. Kod listesi
        //   senkronundan ayri: orada yalniz KODU/ADI/USTKODU aliniyor, SUT'un
        //   fiyati - islem puani - LOINC birimi sessizce dusuyordu. Burada
        //   hicbir alan yorumlanmaz; tipli ambar (skrs_sut vb.) ham JSON'dan
        //   SQL ile uretilir, alan adi degisirse servise tekrar gidilmez.
        grup.MapPost("/{id:int}/skrs-ham", async (
            int id, string ad, BaglamCozucu cozucu, VeriKaynagi veri,
            IHttpClientFactory istemciler, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            var hesap = await HesapOkuAsync(baglanti, id, iptal);
            if (!string.Equals(hesap.Kod, "SKRS", StringComparison.OrdinalIgnoreCase))
                throw GentegreHatasi.IsKurali("Bu işlem yalnız SKRS hesabında çalışır.");
            if (string.IsNullOrWhiteSpace(ad))
                throw GentegreHatasi.Dogrulama("Çekilecek SKRS listesinin adı verilmeli (ad).");

            var katalog = await SkrsKatalogAsync(hesap, istemciler, iptal);
            var anahtar = Anahtar(ad);
            // Tam ad bulunamazsa ICEREN tek liste kabul edilir: SKRS adlari
            //   Turkce ve uzun ("TIBBİ İŞLEM PUAN BİLGİSİ"); birden cok
            //   eslesirse tahmin edilmez, adaylar kullaniciya donulur.
            if (!katalog.TryGetValue(anahtar, out var guid))
            {
                var adaylar = katalog.Keys
                    .Where(k => k.Contains(anahtar, StringComparison.Ordinal)).ToList();
                if (adaylar.Count != 1)
                    throw GentegreHatasi.IsKurali(
                        $"'{ad}' SKRS kataloğunda bulunamadı."
                        + (adaylar.Count > 1 ? $" Adaylar: {string.Join(" · ", adaylar)}." : ""));
                anahtar = adaylar[0];
                guid = katalog[anahtar];
            }

            var (kayitlar, sayfa, kesildi) = await SkrsHamCekAsync(hesap, guid, istemciler, iptal);

            // YARIM CEKIM ESKISINI SILMESIN: servis ortada 500 donmusse eldeki
            //   ambar korunur, cagri hata olarak raporlanir.
            if (kesildi && kayitlar.Count == 0)
                throw GentegreHatasi.IsKurali(
                    $"'{anahtar}' çekilemedi - servis {sayfa}. sayfada hata döndü.");

            await baglanti.CalistirAsync(
                "delete from public.skrs_ham where liste = @p0", null, [anahtar], iptal);
            // TOPLU YAZIM: 15 bin satiri tek tek yazmak cekimin kendisinden
            //   uzun suruyordu - sayfa basina tek INSERT (dizi acilir).
            foreach (var oebek in kayitlar.GroupBy(x => x.Sayfa))
                await baglanti.CalistirAsync("""
                    insert into public.skrs_ham (liste, sayfa, kayit)
                    select @p0, @p1, x from jsonb_array_elements(@p2::jsonb) as x
                    """, null,
                    [anahtar, oebek.Key,
                     "[" + string.Join(",", oebek.Select(x => x.Json)) + "]"], iptal);

            var ozet = $"{anahtar}: {kayitlar.Count} kayıt ({sayfa} sayfa)"
                       + (kesildi ? " - servis hatası nedeniyle YARIM" : "");
            await SonucYazAsync(baglanti, id, ozet, iptal);

            var alanlar = await baglanti.ListeAsync("""
                select x.alan, count(*) as adet
                  from public.skrs_ham h, lateral jsonb_object_keys(h.kayit) as x(alan)
                 where h.liste = @p0
                 group by x.alan order by 2 desc, 1
                """, null, [anahtar], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                liste = anahtar, adet = kayitlar.Count, sayfa, yarim = kesildi,
                alanlar, mesaj = ozet, izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------- SKRS liste senkron
        grup.MapPost("/{id:int}/skrs-senkron", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, IHttpClientFactory istemciler,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            var hesap = await HesapOkuAsync(baglanti, id, iptal);

            if (!string.Equals(hesap.Kod, "SKRS", StringComparison.OrdinalIgnoreCase))
                throw GentegreHatasi.IsKurali("Bu işlem yalnız SKRS hesabında çalışır.");

            // KOD SISTEMI KATALOGU (GetSkrsList): ad -> GUID. Servis degerleri
            //   yalniz GUID ile veriyor; katalog tek kez cekilir.
            var katalog = await SkrsKatalogAsync(hesap, istemciler, iptal);

            var toplam = 0;
            var raporlar = new List<string>();
            foreach (var (skrsAd, yerelListe) in SkrsListeleri)
            {
                if (!katalog.TryGetValue(Anahtar(skrsAd), out var guid))
                {
                    raporlar.Add($"{skrsAd}: SKRS kod listesinde yok");
                    continue;
                }
                // TEK LISTENIN HATASI SENKRONU DURDURMAZ: SKRS bazi listelerde
                //   (or. ILCE) HTTP 500 donuyor; oteki listeler yazilabilsin,
                //   hata da rapora dussun - kullanici neyin gelmedigini gorsun.
                List<(string Kod, string Ad, string? Ust)> degerler;
                try
                {
                    degerler = await SkrsListesiCekAsync(hesap, guid, istemciler, iptal);
                }
                catch (Exception h)
                {
                    raporlar.Add($"{skrsAd}: {Kisalt(h.Message, 60)}");
                    continue;
                }
                if (degerler.Count == 0)
                {
                    raporlar.Add($"{skrsAd}: boş döndü");
                    continue;
                }

                var yazilan = await ListeYazAsync(baglanti, yerelListe, degerler,
                                                  baglam.KullaniciId, iptal);
                toplam += yazilan;
                raporlar.Add($"{skrsAd} → {yerelListe}: {yazilan}");
            }

            // Tablo listeleri (340): il -> ilçe -> ülke sırasıyla.
            foreach (var (skrsAd, hedef) in SkrsTablolari)
            {
                if (!katalog.TryGetValue(Anahtar(skrsAd), out var guid))
                {
                    raporlar.Add($"{skrsAd}: SKRS kod listesinde yok");
                    continue;
                }
                List<(string Kod, string Ad, string? Ust)> degerler;
                try
                {
                    degerler = await SkrsListesiCekAsync(hesap, guid, istemciler, iptal);
                }
                catch (Exception h)
                {
                    raporlar.Add($"{skrsAd}: {Kisalt(h.Message, 60)}");
                    continue;
                }
                if (degerler.Count == 0)
                {
                    raporlar.Add($"{skrsAd}: boş döndü");
                    continue;
                }

                var (yazilan, atlanan) = hedef switch
                {
                    "IL"   => await IlYazAsync(baglanti, degerler, iptal),
                    "ILCE" => await IlceYazAsync(baglanti, degerler, iptal),
                    "ICD"  => await IcdYazAsync(baglanti, degerler, iptal),
                    _      => await UlkeYazAsync(baglanti, degerler, iptal),
                };
                toplam += yazilan;
                raporlar.Add(atlanan > 0
                    ? $"{skrsAd}: {yazilan} (atlanan {atlanan})"
                    : $"{skrsAd}: {yazilan}");
            }

            // ------------------------------------------------- ESLEME PASI --
            // Degerleri KULLANIMDA olan yerel listeler SKRS degerleriyle
            //   EZILEMEZ (or. `ilac.recete_turu` 22.757 ilac kaydinda geciyor).
            //   Bunlar icin yalnizca KOPRU kurulur: `kod_deger.skrs_kod` ada
            //   gore doldurulur (503). Ad tutmuyorsa bos kalir - tahmin
            //   yazilmaz, `v_skrs_sapma` neyin eslesmedigini gosterir.
            var bagli = await baglanti.ListeAsync<(string Kod, string Skrs)>("""
                select l.kod, l.skrs_liste
                  from public.kod_liste l
                 where l.skrs_liste <> ''
                 order by l.kod
                """, null, [], o => (o.GetString(0), o.GetString(1)), iptal);

            var yazilanlar = SkrsListeleri.Select(x => x.YerelListe)
                                          .ToHashSet(StringComparer.OrdinalIgnoreCase);
            foreach (var (yerel, skrsListe) in bagli)
            {
                if (yazilanlar.Contains(yerel)) continue;      // degerleri zaten SKRS
                var ad = skrsListe.StartsWith("SKRS ", StringComparison.OrdinalIgnoreCase)
                    ? skrsListe[5..] : skrsListe;
                if (!katalog.TryGetValue(Anahtar(ad), out var g)) continue;

                List<(string Kod, string Ad, string? Ust)> kodlar;
                try { kodlar = await SkrsListesiCekAsync(hesap, g, istemciler, iptal); }
                catch (Exception h) { raporlar.Add($"{ad} (eşleme): {Kisalt(h.Message, 50)}"); continue; }

                var eslesen = 0;
                foreach (var (kod, kodAdi, _) in kodlar)
                {
                    eslesen += await baglanti.CalistirAsync("""
                        update public.kod_deger d
                           set skrs_kod = @p2
                          from public.kod_liste l
                         where l.id = d.liste_id and l.kod = @p0
                           and public.fn_ara_metin(d.ad) = public.fn_ara_metin(@p1)
                           and d.skrs_kod <> @p2
                        """, null, [yerel, kodAdi, kod], iptal);
                }
                raporlar.Add($"{ad} ⇢ {yerel} (eşleme): {eslesen}");
            }

            var ozet = toplam > 0
                ? $"SKRS listeleri güncellendi ({toplam} kod): {string.Join(" · ", raporlar)}"
                : $"SKRS'den kod alınamadı: {string.Join(" · ", raporlar)}";
            await SonucYazAsync(baglanti, id, ozet, iptal);

            return Results.Ok(new { satirSayisi = toplam, mesaj = ozet });
        });
    }

    // ============================================================== yardımcı ==
    private sealed record Hesap(int Id, string Kod, string KullaniciAdi, string Sifre,
                                string UygulamaKodu, string Adres);

    private static async Task<Hesap> HesapOkuAsync(
        NpgsqlConnection baglanti, int id, CancellationToken iptal)
    {
        var k = await baglanti.TekAsync("""
            select e.id, e.kod, e.kullanici_adi, e.sifre, e.uygulama_kodu,
                   -- ADRES UC NOKTADAN (340): satirin kendi adresi, yoksa
                   --   servisin bilinen varsayilani (e-Belge entegrator
                   --   katalogu / UTS referans ayari). Satirda adres bos
                   --   birakmak NORMALDIR - gonderim de ayni sirayi izliyor;
                   --   "Sina" bunu bilmeyip "adres bos" diyordu.
                   coalesce(
                     nullif(btrim(case when e.test_mi = 1 then e.test_url else e.url end), ''),
                     case when e.kod = 'EBELGE' then
                       (select case when e.test_mi = 1 then en.test_url else en.uretim_url end
                          from public.ebelge_entegrator en where en.id = e.entegrator_id)
                     end,
                     case when e.kod = 'UTS' then
                       coalesce(
                         nullif(btrim((select r.deger from public.referans r
                                        where r.anahtar = case when e.test_mi = 1
                                                               then 'uts.test_url'
                                                               else 'uts.uretim_url' end)), ''),
                         case when e.test_mi = 1 then 'https://utstest.saglik.gov.tr'
                              else 'https://utsuygulama.saglik.gov.tr' end)
                     end,
                     '') as adres,
                   e.aktif
              from public.entegrasyon_hesap e where e.id = @p0
            """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Entegrasyon hesabı bulunamadı.");

        string M(string ad) => k[ad]?.ToString() ?? "";

        if (Convert.ToInt32(k["aktif"] ?? 0) != 1)
            throw GentegreHatasi.IsKurali("Hesap pasif - önce aktifleştirin.");
        // KIMLIK KONTROLU SERVISE GORE (340) ve sinamanin KENDISINDE: SKRS
        //   kullanıcı+şifre+uygulama kodu ister, ÜTS yalnız TOKEN (kullanıcı
        //   adı yoktur) - burada topluca "kullanıcı adı boş" demek ÜTS
        //   hesabının sınanmasını engelliyordu. Adres de artık üç noktadan
        //   çözülüyor; gerçekten boşsa sınama mesajı söyler.
        if (M("kod") == "SKRS" && (M("kullanici_adi") == "" || M("sifre") == ""))
            throw GentegreHatasi.IsKurali(
                "SKRS kullanıcı adı ve şifresi girilmemiş (Ayarlar › Genel › Entegrasyon).");

        return new Hesap(id, M("kod"), M("kullanici_adi"), M("sifre"),
                         M("uygulama_kodu"), M("adres"));
    }

    private static async Task SonucYazAsync(
        NpgsqlConnection baglanti, int id, string sonuc, CancellationToken iptal)
        => await baglanti.CalistirAsync("""
            update public.entegrasyon_hesap
               set son_kullanim = (now())::timestamp,
                   son_sonuc = left(@p1, 300)
             where id = @p0
            """, null, [id, sonuc], iptal);

    /// <summary>
    /// SKRS'ye en ucuz çağrı: kod sistemi listesini ister. Amaç veriyi almak
    /// değil, KİMLİĞİN geçerliliğini görmek - hata metni kullanıcıya döner.
    /// </summary>
    private static async Task<(bool, string)> SkrsDenemeAsync(
        Hesap hesap, IHttpClientFactory istemciler, CancellationToken iptal)
    {
        try
        {
            // En ucuz gercek cagri: kod sistemi katalogu (parametresiz).
            var katalog = await SkrsKatalogAsync(hesap, istemciler, iptal);
            if (katalog.Count == 0)
                return (false, "Bağlantı kuruldu ama servis boş liste döndü "
                               + "(kullanıcı / şifre / uygulama kodu yetkisiz olabilir).");

            var eksik = SkrsListeleri.Select(x => x.SkrsAd)
                .Concat(SkrsTablolari.Select(x => x.SkrsAd))
                .Where(ad => !katalog.ContainsKey(Anahtar(ad)))
                .ToList();

            return (true, $"Bağlantı başarılı - {katalog.Count} SKRS kod listesi görüldü."
                          + (eksik.Count > 0
                             ? $" Eşleşmeyen: {string.Join(", ", eksik)}."
                             : ""));
        }
        catch (Exception h)
        {
            return (false, $"Bağlantı kurulamadı: {h.Message}");
        }
    }

    /// <summary>Ad karsilastirmasi: buyuk/kucuk ve bosluk farkini yok sayar.</summary>
    private static string Anahtar(string ad)
        => string.Join(' ', (ad ?? "").Split(' ', StringSplitOptions.RemoveEmptyEntries))
                 .ToUpperInvariant();

    /// <summary>
    /// SKRS KOD SISTEMI KATALOGU: GetSkrsList (parametresiz) -> ad -> GUID.
    /// 499 liste doner; bizim ilgilendiklerimiz adla bulunur.
    /// </summary>
    private static async Task<Dictionary<string, string>> SkrsKatalogAsync(
        Hesap hesap, IHttpClientFactory istemciler, CancellationToken iptal)
    {
        var govde = await SkrsIstekAsync(hesap, "GetSkrsList", istemciler, iptal);
        var sonuc = new Dictionary<string, string>(StringComparer.Ordinal);

        using var belge = JsonDocument.Parse(govde);
        if (!belge.RootElement.TryGetProperty("sonuc", out var liste)
            || liste.ValueKind != JsonValueKind.Array)
            return sonuc;

        foreach (var x in liste.EnumerateArray())
        {
            var ad = x.TryGetProperty("adi", out var a) ? a.GetString() ?? "" : "";
            var kod = x.TryGetProperty("kodu", out var k) ? k.GetString() ?? "" : "";
            if (ad != "" && kod != "") sonuc[Anahtar(ad)] = kod;
        }
        return sonuc;
    }


    /// <summary>
    /// SKRS dışındaki servisler için hafif sınama (340): adres ayakta mı ve
    /// kimlik alanları dolu mu. Gerçek oturum açma denemesi YAPILMAZ - her
    /// entegratörün kendi login sözleşmesi var ve yanlış istek kimi serviste
    /// hesabı kilitliyor; gönderim zaten kendi akışında doğruluyor.
    /// </summary>
    private static async Task<(bool, string)> AdresDenemeAsync(
        Hesap hesap, IHttpClientFactory istemciler, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(hesap.Adres))
            return (false, "Servis adresi boş - hesap kartında doldurun.");

        var eksik = new List<string>();
        if (string.IsNullOrWhiteSpace(hesap.KullaniciAdi) && hesap.Kod != "UTS")
            eksik.Add("kullanıcı adı");
        if (string.IsNullOrWhiteSpace(hesap.Sifre))
            eksik.Add(hesap.Kod == "UTS" ? "token" : "şifre");

        try
        {
            var istemci = istemciler.CreateClient("skrs");
            using var istek = new HttpRequestMessage(HttpMethod.Head, hesap.Adres);
            using var yanit = await istemci.SendAsync(istek, iptal);

            // 5xx = servis ayakta DEĞİL (502 "Bad Gateway" de dahil); 4xx bu
            //   sınamada normaldir - HEAD isteği yetkisiz/desteklenmez olabilir
            //   ama adres çözülüp yanıt üretmiştir.
            var kod = (int)yanit.StatusCode;
            var durum = $"HTTP {kod}";
            if (kod >= 500)
                return (false, $"Servis şu an yanıt veremiyor ({durum}) - adres doğru "
                               + "olabilir, servis tarafında sorun var.");

            return eksik.Count == 0
                ? (true, $"Adres yanıt veriyor ({durum}) ve kimlik alanları dolu. "
                         + "Gerçek oturum açma gönderim sırasında doğrulanır.")
                : (false, $"Adres yanıt veriyor ({durum}) ama {string.Join(" / ", eksik)} boş.");
        }
        catch (Exception h)
        {
            return (false, $"Adrese ulaşılamadı: {h.Message}");
        }
    }

    /// <summary>
    /// SKRS KOD LISTESI DEGERLERI: GetSkrsObject?skrsCodeSystemGuid=..&amp;page=N
    ///
    /// SERVIS REST'TIR, SOAP DEGIL (doc/index.html): GET + JSON, kimlik uc HTTP
    /// basliginda (KullaniciAdi / Sifre / UygulamaKodu). Onceki surum SOAP
    /// zarfi POST ediyordu ve servis HTTP 404 donuyordu.
    ///
    /// SAYFALAMA: her sayfada 1000 kayit, cevapta `sonrakiSayfa` gelir; deger
    /// 1 ise son sayfadir (dokumanin kendi kurali). Donguye ust sinir konur -
    /// servis yanlis sayfa numarasi dondurse bile istek yagmuru olmasin.
    /// </summary>
    private static async Task<List<(string Kod, string Ad, string? Ust)>> SkrsListesiCekAsync(
        Hesap hesap, string guid, IHttpClientFactory istemciler, CancellationToken iptal)
    {
        var liste = new List<(string, string, string?)>();
        var sayfa = 1;

        while (sayfa > 0 && sayfa <= 200)
        {
            var govde = await SkrsIstekAsync(hesap,
                $"GetSkrsObject?skrsCodeSystemGuid={Uri.EscapeDataString(guid)}&page={sayfa}",
                istemciler, iptal);

            using var belge = JsonDocument.Parse(govde);
            if (!belge.RootElement.TryGetProperty("sonuc", out var sonuc)
                || sonuc.ValueKind != JsonValueKind.Object) break;
            if (!sonuc.TryGetProperty("kayit", out var kayitlar)
                || kayitlar.ValueKind != JsonValueKind.Array) break;

            foreach (var k in kayitlar.EnumerateArray())
            {
                // PASIF kodlar alinmaz: SKRS gecmisi de doner (AKTIF=false).
                if (k.TryGetProperty("AKTIF", out var aktif)
                    && aktif.ValueKind == JsonValueKind.False) continue;

                var kod = Metin(k, "KODU");
                var ad  = Metin(k, "ADI");
                // ULKE listesinde KODU harflidir ("TR", "AF"); bizim eslesme
                //   kolonlari sayisal - MERNIS kodu (9840...) kullanilir.
                //   Hasta kayitlarinda uyruk da MERNIS kodudur, ayni dil.
                if (kod is not null && !int.TryParse(kod, out _))
                    kod = Metin(k, "MERNISKODU") ?? kod;
                if (kod is null || ad is null) continue;
                // UST KOD: ilce listesinde ilin kodu (alan adi surume gore degisiyor).
                liste.Add((kod, ad, Metin(k, "USTKODU", "ILKODU", "USTKOD", "PARENTKODU")));
            }

            var sonraki = sonuc.TryGetProperty("sonrakiSayfa", out var sy)
                          && sy.ValueKind == JsonValueKind.Number ? sy.GetInt32() : 1;
            if (sonraki <= 1 || sonraki == sayfa) break;   // 1 = son sayfa
            sayfa = sonraki;
        }

        return liste;
    }

    /// <summary>
    /// HAM CEKIM: listenin butun sayfalarini ham JSON metni olarak dondurur.
    /// Alan adi YORUMLANMAZ (bkz. 520) - tipli ambar SQL tarafinda uretilir.
    /// Ara sayfada hata olursa dongu KESILIR ama o ana kadar gelenler durur:
    /// SKRS buyuk listelerde ara sayfada 500 donebiliyor, hepsini atmak
    /// 14 bin satirlik bir cekimi bir sayfa yuzunden bosa cikariyordu.
    /// </summary>
    private static async Task<(List<(string Json, int Sayfa)> Kayitlar, int Sayfa, bool Kesildi)>
        SkrsHamCekAsync(Hesap hesap, string guid, IHttpClientFactory istemciler,
                        CancellationToken iptal)
    {
        var kayitlar = new List<(string, int)>();
        var sayfa = 1;

        while (sayfa > 0 && sayfa <= 400)
        {
            // YENIDEN DENEME: SKRS buyuk listelerde ara sayfada gecici 500
            //   donuyor (SUT 16. sayfa). Ilk hatada birakmak 15 bin satirlik
            //   cekimi yarim biraktigi icin sayfa uc kez denenir.
            string? govde = null;
            for (var deneme = 1; deneme <= 3 && govde is null; deneme++)
            {
                try
                {
                    govde = await SkrsIstekAsync(hesap,
                        $"GetSkrsObject?skrsCodeSystemGuid={Uri.EscapeDataString(guid)}&page={sayfa}",
                        istemciler, iptal);
                }
                catch
                {
                    if (deneme == 3) return (kayitlar, sayfa, true);
                    await Task.Delay(2000 * deneme, iptal);
                }
            }

            using var belge = JsonDocument.Parse(govde);
            if (!belge.RootElement.TryGetProperty("sonuc", out var sonuc)
                || sonuc.ValueKind != JsonValueKind.Object) break;
            if (!sonuc.TryGetProperty("kayit", out var liste)
                || liste.ValueKind != JsonValueKind.Array) break;

            foreach (var k in liste.EnumerateArray())
                kayitlar.Add((k.GetRawText(), sayfa));

            var sonraki = sonuc.TryGetProperty("sonrakiSayfa", out var sy)
                          && sy.ValueKind == JsonValueKind.Number ? sy.GetInt32() : 1;
            if (sonraki <= 1 || sonraki == sayfa) break;   // 1 = son sayfa
            sayfa = sonraki;
        }

        return (kayitlar, sayfa, false);
    }

    /// <summary>SKRS REST cagrisi: taban adres + yol, kimlik uc HTTP basliginda.</summary>
    private static async Task<string> SkrsIstekAsync(Hesap hesap, string yol,
        IHttpClientFactory istemciler, CancellationToken iptal)
    {
        var istemci = istemciler.CreateClient("skrs");
        var taban = hesap.Adres.TrimEnd('/');
        // Hesap kartina dokuman/portal adresi yazilmis olabilir; servis tabani
        //   ".../api/SkrsService". Yol zaten iceriyorsa oldugu gibi kullanilir.
        if (!taban.EndsWith("/api/SkrsService", StringComparison.OrdinalIgnoreCase))
        {
            var kok = taban;
            var i = kok.IndexOf("/api/", StringComparison.OrdinalIgnoreCase);
            if (i > 0) kok = kok[..i];
            else
            {
                var u = new Uri(kok);
                kok = $"{u.Scheme}://{u.Host}";
            }
            taban = kok + "/api/SkrsService";
        }

        using var istek = new HttpRequestMessage(HttpMethod.Get, $"{taban}/{yol}");
        istek.Headers.TryAddWithoutValidation("KullaniciAdi", hesap.KullaniciAdi);
        istek.Headers.TryAddWithoutValidation("Sifre", hesap.Sifre);
        istek.Headers.TryAddWithoutValidation("UygulamaKodu", hesap.UygulamaKodu);

        using var yanit = await istemci.SendAsync(istek, iptal);
        var metin = await yanit.Content.ReadAsStringAsync(iptal);

        if (!yanit.IsSuccessStatusCode)
            throw new InvalidOperationException($"HTTP {(int)yanit.StatusCode} - {Kisalt(metin)}");
        if (metin.TrimStart().StartsWith("<"))
            throw new InvalidOperationException(
                "Servis JSON yerine HTML dondurdu - adres SKRS servis ucu olmayabilir "
                + $"({taban}).");

        return metin;
    }

    /// <summary>JSON nesnesinden ilk dolu alani okur (alan adlari surume gore degisir).</summary>
    private static string? Metin(JsonElement nesne, params string[] adlar)
    {
        foreach (var ad in adlar)
            if (nesne.TryGetProperty(ad, out var d))
            {
                var v = d.ValueKind switch
                {
                    JsonValueKind.String => d.GetString(),
                    JsonValueKind.Number => d.ToString(),
                    _ => null,
                };
                if (!string.IsNullOrWhiteSpace(v)) return v!.Trim();
            }
        return null;
    }

    private static string Kisalt(string s, int uzunluk = 200)
        => s.Length <= uzunluk ? s : s[..uzunluk] + "…";

    /// <summary>
    /// Yerel kod listesini SKRS değerleriyle günceller. SAYISAL olmayan SKRS
    /// kodu atlanır: `kod_deger.deger` integer'dır (metin kodlu listeler için
    /// ayrı görünüm gerekir; bugünkü dört liste sayısaldır).
    /// </summary>
    private static async Task<int> ListeYazAsync(
        NpgsqlConnection baglanti, string listeKodu,
        List<(string Kod, string Ad, string? Ust)> degerler, int kullanici,
        CancellationToken iptal)
    {
        await baglanti.CalistirAsync("""
            insert into public.kod_liste (kod, ad)
            select @p0, @p0
             where not exists (select 1 from public.kod_liste where kod = @p0)
            """, null, [listeKodu], iptal);

        var sayac = 0;
        foreach (var (kod, ad, _) in degerler)
        {
            if (!int.TryParse(kod, out var sayi)) continue;
            await baglanti.CalistirAsync("""
                insert into public.kod_deger (liste_id, deger, ad, ekleyen)
                select kl.id, @p1, @p2, @p3 from public.kod_liste kl where kl.kod = @p0
                -- Benzersizlik (liste_id, deger, DIL) - dil kolonu varsayilanla
                --   gelir ama ON CONFLICT hedefi tam eslesmeli (42P10).
                on conflict (liste_id, deger, dil) do update set ad = excluded.ad
                """, null, [listeKodu, sayi, ad, kullanici], iptal);
            sayac++;
        }
        return sayac;
    }

    // ===================================================== tablo yazıcıları ==
    // İl / ilçe / ülke KOD LİSTESİ DEĞİL, dolu ve referans verilen tablolardır
    //   (340). Bu yüzden SKRS kodu `id`nin yerine yazılmaz: önce ADA göre
    //   eşleşen satır aranır ve ona `skrs_kod` işlenir; eşleşme yoksa satır
    //   YENİ kayıt olarak eklenir (id = max + 1, tablolarda identity yok).

    /// <summary>
    /// SKRS ICD listesi -> public.icd (400).
    ///
    /// KOD BURADA ANAHTARDIR (il/ilçenin tersine): "A09" hem SKRS'nin hem
    /// bizim kimliğimiz - ad eşlemesi aramaya gerek yok, kod üzerinden upsert
    /// edilir. `Ust` alanı doluysa ağaç bağı (blok → tanı) yazılır ve satır
    /// 4. seviye sayılır; SKRS bunu vermezse seviye 3 (tanı) kalır.
    ///
    /// AKTİFLİK: bu turda GELMEYEN kod pasife çekilmez. SKRS bazı listeleri
    /// sayfalı/eksik döndürebiliyor; tek eksik yanıt yüzünden binlerce tanıyı
    /// pasife almak, ertesi gün "tanı bulunamıyor" olarak geri gelirdi.
    /// Pasifleme, kaynak güvenilir olduğunda ayrı bir bakım işidir.
    /// </summary>
    private static async Task<(int Yazilan, int Atlanan)> IcdYazAsync(
        NpgsqlConnection baglanti, List<(string Kod, string Ad, string? Ust)> degerler,
        CancellationToken iptal)
    {
        int yazilan = 0, atlanan = 0;
        foreach (var (kod, ad, ust) in degerler)
        {
            var k = (kod ?? "").Trim();
            if (k.Length is 0 or > 12 || string.IsNullOrWhiteSpace(ad)) { atlanan++; continue; }

            await baglanti.CalistirAsync("""
                insert into public.icd (kod, ad, ust_kod, seviye, aktif, kaynak_surum, guncelleme)
                values (@p0, @p1, nullif(@p2, ''), case when nullif(@p2, '') is null then 3 else 4 end,
                        1, 'skrs', now())
                on conflict (kod) do update
                   set ad = excluded.ad,
                       ust_kod = coalesce(excluded.ust_kod, public.icd.ust_kod),
                       -- SEVIYE de tazelenir: kod once dosyadan (ustsuz)
                       --   yuklenmis olabilir; SKRS ust kodu getirince satir
                       --   agacta dogru yere otursun.
                       seviye = case when coalesce(excluded.ust_kod, public.icd.ust_kod) is null
                                     then 3 else 4 end,
                       aktif = 1, kaynak_surum = 'skrs',
                       guncelleme = now()
                """, null, [k, ad.Trim(), (ust ?? "").Trim()], iptal);
            yazilan++;
        }

        // KATALOG IZLEME (400): "ICD listesi ne zaman, kaç satırla güncellendi"
        //   sorusu tek yerden cevaplanır.
        await baglanti.CalistirAsync("""
            insert into public.katalog_senkron (kod, ad, son_calisma, satir_sayisi, sonuc, basarili)
            values ('icd', 'ICD-10 Tanı', now(), @p0, @p1, 1)
            on conflict (kod) do update
               set son_calisma = now(), satir_sayisi = excluded.satir_sayisi,
                   sonuc = excluded.sonuc, basarili = 1
            """, null, [yazilan, $"SKRS: {yazilan} kod yazıldı, {atlanan} atlandı."], iptal);

        return (yazilan, atlanan);
    }

    /// <summary>SKRS IL listesi -> public.il (ad eşlemesi + skrs_kod).</summary>
    private static async Task<(int Yazilan, int Atlanan)> IlYazAsync(
        NpgsqlConnection baglanti, List<(string Kod, string Ad, string? Ust)> degerler,
        CancellationToken iptal)
    {
        int yazilan = 0, atlanan = 0;
        foreach (var (kod, ad, _) in degerler)
        {
            if (!int.TryParse(kod, out var skrs)) { atlanan++; continue; }

            var etkilenen = await baglanti.CalistirAsync("""
                update public.il set skrs_kod = @p0
                 where public.fn_ara_metin(ad) = public.fn_ara_metin(@p1)
                   and skrs_kod is distinct from @p0
                """, null, [skrs, ad], iptal);

            if (etkilenen == 0)
                await baglanti.CalistirAsync("""
                    insert into public.il (id, ad, skrs_kod)
                    select coalesce((select max(id) from public.il), 0) + 1, @p1, @p0
                     where not exists (select 1 from public.il
                                        where public.fn_ara_metin(ad) = public.fn_ara_metin(@p1))
                    """, null, [skrs, ad], iptal);

            yazilan++;
        }
        return (yazilan, atlanan);
    }

    /// <summary>
    /// SKRS ILCE listesi -> public.ilce. Eşleme (il, ad) çiftiyle: ilçe adı
    /// tek başına benzersiz değil (onlarca "MERKEZ"). İlin bağı SKRS üst
    /// kodundan çözülür; üst kod yoksa ya da o ilin `skrs_kod`u henüz
    /// dolmadıysa satır ATLANIR (yanlış ile bağlamak, adres kayıtlarını
    /// sessizce bozardı).
    /// </summary>
    private static async Task<(int Yazilan, int Atlanan)> IlceYazAsync(
        NpgsqlConnection baglanti, List<(string Kod, string Ad, string? Ust)> degerler,
        CancellationToken iptal)
    {
        int yazilan = 0, atlanan = 0;
        foreach (var (kod, ad, ust) in degerler)
        {
            if (!int.TryParse(kod, out var skrs) || !int.TryParse(ust, out var ilSkrs))
            { atlanan++; continue; }

            var il = await baglanti.TekAsync(
                "select id from public.il where skrs_kod = @p0", null, [ilSkrs], OkuyucuGenisletmeleri.Sozluk, iptal);
            if (il is null) { atlanan++; continue; }
            var ilId = Convert.ToInt32(il["id"]);

            var etkilenen = await baglanti.CalistirAsync("""
                update public.ilce set skrs_kod = @p0
                 where il_id = @p2
                   and public.fn_ara_metin(ad) = public.fn_ara_metin(@p1)
                   and skrs_kod is distinct from @p0
                """, null, [skrs, ad, ilId], iptal);

            if (etkilenen == 0)
                await baglanti.CalistirAsync("""
                    insert into public.ilce (id, il_id, ad, aktif, skrs_kod)
                    select coalesce((select max(id) from public.ilce), 0) + 1, @p2, @p1, 1, @p0
                     where not exists (select 1 from public.ilce
                                        where il_id = @p2
                                          and public.fn_ara_metin(ad) = public.fn_ara_metin(@p1))
                    """, null, [skrs, ad, ilId], iptal);

            yazilan++;
        }
        return (yazilan, atlanan);
    }

    /// <summary>SKRS ULKE listesi -> public.ulke (ad eşlemesi + skrs_kod).</summary>
    private static async Task<(int Yazilan, int Atlanan)> UlkeYazAsync(
        NpgsqlConnection baglanti, List<(string Kod, string Ad, string? Ust)> degerler,
        CancellationToken iptal)
    {
        int yazilan = 0, atlanan = 0;
        foreach (var (kod, ad, _) in degerler)
        {
            if (!int.TryParse(kod, out var skrs)) { atlanan++; continue; }

            var etkilenen = await baglanti.CalistirAsync("""
                update public.ulke set skrs_kod = @p0
                 where public.fn_ara_metin(ad) = public.fn_ara_metin(@p1)
                   and skrs_kod is distinct from @p0
                """, null, [skrs, ad], iptal);

            if (etkilenen == 0)
                await baglanti.CalistirAsync("""
                    insert into public.ulke (id, ad, skrs_kod)
                    select coalesce((select max(id) from public.ulke), 0) + 1, @p1, @p0
                     where not exists (select 1 from public.ulke
                                        where public.fn_ara_metin(ad) = public.fn_ara_metin(@p1))
                    """, null, [skrs, ad], iptal);

            yazilan++;
        }
        return (yazilan, atlanan);
    }
}
