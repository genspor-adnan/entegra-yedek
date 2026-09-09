using System.Globalization;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

public static class KartUclari
{
    public static void KartUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kart").WithTags("Kart").RequireAuthorization();

        // POST /api/kart/cari/{id}/ebelge-mukellef - alicinin GIB e-Fatura
        //   kaydini entegratore SOR ve karta isle. Elle isaretlenen bayrak
        //   yanlissa belge yanlis turde gider ve GIB reddeder.
        yol.MapPost("/api/kart/cari/{id:int}/ebelge-mukellef", async (
            int id, BaglamCozucu cozucu, EBelgeSorgu sorgu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var oku = new Npgsql.NpgsqlCommand(
                "select coalesce(vkno, ''), coalesce(unvan, '') from public.taraf where id = @p0",
                baglanti);
            oku.Parameters.AddWithValue("p0", id);
            string vkno = "", unvan = "";
            await using (var o = await oku.ExecuteReaderAsync(iptal))
            {
                if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
                vkno = o.GetString(0); unvan = o.GetString(1);
            }

            var m = await sorgu.MukellefSorgulaAsync(vkno, baglam.SubeId, iptal);

            // Bayraklar ve POSTA KUTUSU (186) guncellenir; unvan/adres
            //   DOKUNULMAZ: musterinin kendi kaydi, entegratorun yazimiyla
            //   ezilmemeli - yanitta gelirler, kullanici isterse elle alir.
            //   Sorgu alias dondurmediyse elle girilmis alias korunur.
            await using var yaz = new Npgsql.NpgsqlCommand("""
                update public.taraf
                   set efatura = @p1, eirsaliye = @p3,
                       alias_eposta = case when @p4 <> '' then @p4 else alias_eposta end,
                       alias_irsaliye = case when @p5 <> '' then @p5 else alias_irsaliye end,
                       efatura_sorgu_tarihi = now()::timestamp,
                       degistiren = @p2, degistirme_tarihi = now()::timestamp
                 where id = @p0
                """, baglanti);
            yaz.Parameters.AddWithValue("p0", id);
            yaz.Parameters.AddWithValue("p1", (short)(m.Mukellef ? 1 : 0));
            yaz.Parameters.AddWithValue("p2", baglam.KullaniciId);
            yaz.Parameters.AddWithValue("p3", (short)(m.IrsaliyeKullanicisi ? 1 : 0));
            yaz.Parameters.AddWithValue("p4", m.Alias ?? "");
            yaz.Parameters.AddWithValue("p5", m.IrsaliyeAlias ?? "");
            await yaz.ExecuteNonQueryAsync(iptal);
            var degisti = true;

            return Results.Ok(new
            {
                mukellef = m.Mukellef, durum = m.Durum, degisti,
                alias = m.Alias, irsaliyeAlias = m.IrsaliyeAlias,
                gelen = new { unvan = m.Unvan, vergiDairesi = m.VergiDairesi,
                              il = m.Il, ilce = m.Ilce, adres = m.Adres },
                kayitli = new { unvan, vkno },
                izlemeNo = baglam.IzlemeNo,
            });
        }).RequireAuthorization();


        // ------------------------------------------------------------- oku ----
        grup.MapGet("/{kaynak}/{id:long}", async (
            string kaynak, long id, BaglamCozucu cozucu, KartDeposu depo, KullaniciAramaDeposu arama,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            var (okunabilir, gizli) = Alanlar(tanim, baglam);

            var kart = await depo.OkuAsync(tanim, id, okunabilir, baglam.Kapsam, iptal)
                       ?? throw GentegreHatasi.Bulunamadi();

            // KULLANICI_ARAMA karsiligi: kart her acilista upsert (Son/Sik Aranan).
            await arama.IsaretleAsync(baglam.KullaniciId, tanim.Ad, id, iptal);

            var govde = new Dictionary<string, object?>(kart.Kart, StringComparer.Ordinal)
            {
                ["surum"] = kart.Surum
            };

            return Results.Ok(new KartYaniti
            {
                Kart = govde,
                Detaylar = await depo.DetaylarAsync(tanim, id, iptal),
                KodAd = await depo.KodAdAsync(tanim, kart.Kart, iptal),
                Yetki = new KartYetkisi
                {
                    Duzenle = baglam.Yetkiler.Var(tanim.YetkiKodu, Islem.Degistir),
                    Sil = baglam.Yetkiler.Var(tanim.YetkiKodu, Islem.Sil),
                    GizliAlanlar = gizli
                },
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------------ ekle ----
        grup.MapPost("/{kaynak}", async (
            string kaynak, KartYazmaIstegi istek, BaglamCozucu cozucu, KartDeposu depo, KullaniciAramaDeposu arama,
            KullaniciDeposu kullanicilar, Servisler.RandevuHatirlatmasi hatirlatma,
            Servisler.PanikDegerBildirimi panik,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Ekle);

            var degerler = Degerler(tanim, istek.Kart, baglam, yeni: true);
            await EntegrasyonModKuraliAsync(tanim, degerler, depo, iptal);
            var yeniId = await depo.EkleAsync(tanim, degerler, istek.Detaylar,
                baglam.Yazma, iptal);

            // KULLANICI_ARAMA karsiligi: yeni kayit da ekleyen kullanici icin isaretlenir.
            await arama.IsaretleAsync(baglam.KullaniciId, tanim.Ad, yeniId, iptal);

            // PERSONELE OTOMATIK KULLANICI HESABI (kullanici): parolasi BOS,
            //   rolu "Rol Atanmamış"; kisi ilk giriste kendi parolasini belirler.
            if (tanim.Ad == "personel")
                await kullanicilar.OtomatikHesapAcAsync((int)yeniId, iptal);

            // RANDEVU HATIRLATMASI (399): kayit aninda kuyruga konur, isci
            //   zamani gelince gonderir. HATIRLATMA KAYDI DUSURMEZ - telefon
            //   yok / sablon pasif / SMS hesabi eksik olabilir; randevunun
            //   kendisi bu yuzden kaydedilmemis sayilmamali.
            if (tanim.Ad == "randevu")
                try { await hatirlatma.TazeleAsync(yeniId, baglam.KullaniciId, iptal); }
                catch (Exception h) { ctx.RequestServices
                    .GetRequiredService<ILoggerFactory>().CreateLogger("Randevu")
                    .LogError(h, "Randevu {Id}: hatirlatma kuyruga konamadi.", yeniId); }

            // PANIK DEGER (399): isareti "Panik" olan test satiri icin isteyen
            //   hekime bildirim. Bildirim LAB KAYDINI DUSURMEZ - sonuc girisi
            //   telefon eksikliginden geri cevrilmemeli.
            if (tanim.Ad == "lab-istem")
                try { await panik.TazeleAsync(yeniId, baglam.KullaniciId, iptal); }
                catch (Exception h) { ctx.RequestServices
                    .GetRequiredService<ILoggerFactory>().CreateLogger("Lab")
                    .LogError(h, "Lab istem {Id}: panik bildirimi konamadi.", yeniId); }

            var (okunabilir, _) = Alanlar(tanim, baglam);
            var kart = await depo.OkuAsync(tanim, yeniId, okunabilir, null, iptal);
            var govde = new Dictionary<string, object?>(kart!.Value.Kart, StringComparer.Ordinal)
            {
                ["surum"] = kart.Value.Surum
            };

            return Results.Created($"/api/kart/{tanim.Ad}/{yeniId}", new KartYaniti
            {
                Kart = govde,
                Detaylar = await depo.DetaylarAsync(tanim, yeniId, iptal),
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // -------------------------------------------------------- guncelle ----
        grup.MapPut("/{kaynak}/{id:long}", async (
            string kaynak, long id, KartYazmaIstegi istek, BaglamCozucu cozucu, KartDeposu depo,
            Servisler.RandevuHatirlatmasi hatirlatma, Servisler.PanikDegerBildirimi panik,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.Surum))
                throw GentegreHatasi.Dogrulama("Guncellemede surum zorunludur.",
                    new AlanHatasi("surum", "Kart okunurken donen surum geri gonderilmeli."));

            var (okunabilir, _) = Alanlar(tanim, baglam);
            var degerler = Degerler(tanim, istek.Kart, baglam, yeni: false);

            await depo.GuncelleAsync(tanim, id, istek.Surum!, degerler, istek.Detaylar,
                okunabilir, baglam.Yazma, iptal);

            // Randevu saati / durumu degismis olabilir: eski hatirlatma iptal
            //   edilip yenisi konur (RandevuHatirlatmasi.TazeleAsync).
            if (tanim.Ad == "randevu")
                try { await hatirlatma.TazeleAsync(id, baglam.KullaniciId, iptal); }
                catch (Exception h) { ctx.RequestServices
                    .GetRequiredService<ILoggerFactory>().CreateLogger("Randevu")
                    .LogError(h, "Randevu {Id}: hatirlatma tazelenemedi.", id); }

            // Sonuc SONRADAN girilir: panik isareti guncellemede dogar.
            if (tanim.Ad == "lab-istem")
                try { await panik.TazeleAsync(id, baglam.KullaniciId, iptal); }
                catch (Exception h) { ctx.RequestServices
                    .GetRequiredService<ILoggerFactory>().CreateLogger("Lab")
                    .LogError(h, "Lab istem {Id}: panik bildirimi konamadi.", id); }

            var kart = await depo.OkuAsync(tanim, id, okunabilir, baglam.Kapsam, iptal)
                       ?? throw GentegreHatasi.Bulunamadi();
            var govde = new Dictionary<string, object?>(kart.Kart, StringComparer.Ordinal)
            {
                ["surum"] = kart.Surum
            };

            return Results.Ok(new KartYaniti
            {
                Kart = govde,
                Detaylar = await depo.DetaylarAsync(tanim, id, iptal),
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------------- sil ----
        grup.MapDelete("/{kaynak}/{id:long}", async (
            string kaynak, long id, BaglamCozucu cozucu, KartDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Sil);

            // Silme logu kartin TAM halini saklar - alan yetkisiyle kirpilmis
            // kume degil, butun alanlar okunur ("Geri Al" eksik satir diriltmesin).
            await depo.SilAsync(tanim, id, tanim.Alanlar,
                baglam.Yazma, iptal);

            return Results.NoContent();
        });

        // GET /api/kart/{kaynak}/alanlar - form metasi (liste tarafindaki /kolonlar karsiligi)
        grup.MapGet("/{kaynak}/alanlar", async (
            string kaynak, BaglamCozucu cozucu, KartDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KartBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            var (okunabilir, gizli) = Alanlar(tanim, baglam);

            // KodTablosu (kendi tablosu) + KodListesi (kod_liste/kod_deger) alanlarinin
            //   TAM secenek listesi - kodAd yalniz kartta KULLANILAN tek degeri cozer.
            var tumAlanlar = (tanim.Detaylar ?? Array.Empty<DetayTanimi>())
                .SelectMany(d => d.Alanlar).Concat(okunabilir).ToList();
            // ARAMA EKRANINDAN secilen alanin TAM LISTESI CEKILMEZ (459):
            //   ICD-10 lookup'i 15.800, hasta lookup'i binlerce satir. Kart her
            //   acilista bunlari cekiyordu; ICD'de id METIN oldugu icin sorgu
            //   "operator does not exist: character varying = integer" ile
            //   dusuyor ve MUAYENE KARTI HIC ACILMIYORDU. Bu alanlarda secim
            //   zaten arama modalinden yapiliyor, dropdown doldurulmuyor.
            var aramaTablolari = tumAlanlar
                .Where(a => a.AramaKaynagi is not null && a.KodTablosu is not null)
                .Select(a => a.KodTablosu!).ToHashSet(StringComparer.Ordinal);
            var tabloGorevleri = tumAlanlar.Select(a => a.KodTablosu)
                .Where(t => t is not null && !aramaTablolari.Contains(t))
                .Distinct()
                .ToDictionary(t => t!, t => depo.KodTablosuSecenekleriAsync(t!, iptal));
            var listeGorevleri = tumAlanlar.Select(a => a.KodListesi).Where(t => t is not null).Distinct()
                .ToDictionary(t => t!, t => depo.KodListesiSecenekleriAsync(t!, iptal));
            // BAGLI alanlarin (Şube -> Banka) ust haritasi: arayuz secenekleri
            //   secili ust'e gore suzsun diye secenek id -> ust id.
            //   AGAC alanlari (484) da ayni haritayi kullanir: girintili
            //   cizim icin her secenegin ustunu bilmek gerekiyor.
            var ustGorevleri = tumAlanlar
                .Where(a => (a.BagliAlan is not null || a.Agac) && a.KodTablosu is not null)
                .Select(a => a.KodTablosu!).Distinct()
                .ToDictionary(t => t, t => depo.KodTablosuUstAsync(t, iptal));
            await Task.WhenAll(tabloGorevleri.Values.Concat(listeGorevleri.Values).Concat(ustGorevleri.Values));
            var tabloSecenekleri = tabloGorevleri.ToDictionary(kv => kv.Key, kv => kv.Value.Result);
            var listeSecenekleri = listeGorevleri.ToDictionary(kv => kv.Key, kv => kv.Value.Result);
            var ustHaritalari = ustGorevleri.ToDictionary(kv => kv.Key, kv => kv.Value.Result);

            // ENTEGRASYON KOD LISTESI URUN MODUNA GORE (342): ERP kurulumunda
            //   SKRS / e-Nabiz / MEDULA secilemez - kullanici secip kaydetse
            //   bile calisacak bir servis yok, listede durmasi gurultu.
            var entegrasyonKodlari = tanim.Ad == "entegrasyon-hesap"
                ? KartKatalogu.EntegrasyonKodlariMod(await depo.UrunModuAsync(baglam.SubeId ?? 0, iptal))
                : null;

            KartAlanMeta MetaOptions(KartAlani a) => a.Ad == "kod" && entegrasyonKodlari is not null
                ? Meta(a, tanim, baglam, entegrasyonKodlari)
                : Meta(a, tanim, baglam,
                a.KodTablosu is { } t && tabloSecenekleri.TryGetValue(t, out var tsec) ? tsec
                : a.KodListesi is { } l ? listeSecenekleri[l]
                : null,
                // AGAC alani da ust haritasini alir (484): girintili cizim
                //   her secenegin ustunu bilmeyi gerektiriyor.
                (a.BagliAlan is not null || a.Agac) && a.KodTablosu is { } bt
                    && ustHaritalari.TryGetValue(bt, out var ust) ? ust : null);

            // Yerel para birimi kartla birlikte gider: arayuz "TL disi mi" karari
            //   icin ayri bir istek yapmasin (kur kutusu bu karara gore acilir).
            DovizMetasi? dovizMeta = null;
            if (tanim.Doviz is { } dk)
                dovizMeta = new DovizMetasi(dk.CinsAlani, dk.KurAlani, dk.TutarAlani, dk.YerelAlani,
                    dk.TarihAlani, await depo.YerelParaAsync(iptal));

            return Results.Ok(new KartMetaYaniti
            {
                Kaynak = tanim.Ad,
                // Yeni kayit varsayilanlari ARAYUZE de gonderilir: kullanici
                //   formu acar acmaz dogru degerleri gorur ve zorunlu kod
                //   alanlari bos kalmaz (bkz. KartMetaYaniti.Varsayilanlar).
                // "@bugun" SEMBOLU BURADA COZULUR: katalogda sabit bir tarih
                //   yazilamaz (dosya bir kez derlenir, tarih donar) ama sembol
                //   HICBIR YERDE de cozulmuyordu - prim planinda "Yeni" karti
                //   Başlangıç alanina ham "@bugun" yaziyor ve kayit
                //   "tarih cozulemedi (@bugun)" ile reddediliyordu, yani yeni
                //   plan HIC acilamiyordu. Meta her istekte uretildigi icin
                //   tarih de her acilista gunceldir.
                Varsayilanlar = (tanim.YeniKayitVarsayilanlari
                    ?? new Dictionary<string, object?>())
                    .ToDictionary(x => x.Key, x => x.Value as string == "@bugun"
                        ? DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)
                        : x.Value),
                AcilistaTarafSecimi = tanim.AcilistaTarafSecimi,
                Doviz = dovizMeta,
                Alanlar = okunabilir.Select(MetaOptions).ToList(),
                Detaylar = (tanim.Detaylar ?? Array.Empty<DetayTanimi>())
                    .Select(d => new KartDetayMeta(d.Ad, d.Etiket, d.SaltOkunur,
                        d.Alanlar.Select(MetaOptions).ToList(), d.KosulAlani, d.TekSatir))
                    .ToList(),
                Yetki = new KartYetkisi
                {
                    Duzenle = baglam.Yetkiler.Var(tanim.YetkiKodu, Islem.Degistir),
                    Sil = baglam.Yetkiler.Var(tanim.YetkiKodu, Islem.Sil),
                    GizliAlanlar = gizli
                }
            });
        });

        // kullanicinin acabilecegi kartlar
        grup.MapGet("/", async (BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kartlar = KartKatalogu.Tumu
                .Where(k => baglam.Yetkiler.Var(k.YetkiKodu, Islem.Gor))
                .Select(k => new
                {
                    k.Ad,
                    ekle = baglam.Yetkiler.Var(k.YetkiKodu, Islem.Ekle),
                    degistir = baglam.Yetkiler.Var(k.YetkiKodu, Islem.Degistir),
                    sil = baglam.Yetkiler.Var(k.YetkiKodu, Islem.Sil)
                })
                .ToList();
            return Results.Ok(new { kartlar });
        });
    }

    /// <summary>
    /// Alan metasi. "Yazilabilir" hem katalogdaki bayrak hem ALAN YETKISI ile
    /// belirlenir: okuma izni olup yazma izni olmayan alan formda salt okunur gelir.
    /// </summary>
    private static KartAlanMeta Meta(KartAlani alan, KartTanimi tanim, IstekBaglami baglam,
        IReadOnlyDictionary<string, string>? kodTablosuSecenekleri = null,
        IReadOnlyDictionary<string, string>? ustHaritasi = null)
        => new(
            alan.Ad,
            alan.Etiket,
            alan.Tip,
            alan.Grup,
            alan.AltGrup,
            alan.EslesAlan,
            alan.Yazilabilir && baglam.Yetkiler.AlanYazilir(tanim.Ad, alan.Ad),
            alan.Zorunlu,
            alan.EnFazlaUzunluk,
            kodTablosuSecenekleri ?? alan.SabitKodlar,
            alan.Gizli,
            alan.BagliAlan,
            alan.AramaKaynagi,
            ustHaritasi,
            alan.Agac);


    /// <summary>
    /// SAGLIK ENTEGRASYONU KURALI (342): SKRS / e-Nabiz / MEDULA hesabi yalniz
    /// GenoTIP AI (HBYS) kurulumunda ACILABILIR. Liste zaten suzuluyor; kural
    /// burada da var cunku istek dogrudan API'ye gelebilir ve calisacak servisi
    /// olmayan hesap kaydi kullaniciyi "neden gonderilmiyor" diye aratirdi.
    ///
    /// YALNIZ YENI KAYITTA: modu sonradan ERP'ye cevrilmis (ya da HBYS'den
    /// klonlanmis) kurulumda MEVCUT saglik hesabinin duzenlenmesi/pasife
    /// alinmasi engellenmemeli - kullaniciyi kendi kaydini temizleyemez
    /// duruma dusururdu.
    /// </summary>
    private static async Task EntegrasyonModKuraliAsync(
        KartTanimi tanim, IDictionary<string, object?> degerler,
        KartDeposu depo, CancellationToken iptal)
    {
        if (tanim.Ad != "entegrasyon-hesap") return;
        if (!degerler.TryGetValue("kod", out var kod)) return;

        var metin = kod?.ToString() ?? "";
        if (!KartKatalogu.SaglikEntegrasyonlari.Contains(metin)) return;

        // Mod 3 ("ikisi") saglik kurulumu sayilir (492).
        if (await depo.UrunModuAsync(iptal) is not (2 or 3))
            throw GentegreHatasi.IsKurali(
                $"{metin} hesabı yalnız GenoTIP AI (sağlık) kurulumunda tanımlanır.");
    }

    private static KartTanimi KartBul(string ad)
        => KartKatalogu.Bul(ad) ?? throw GentegreHatasi.Bulunamadi($"Bilinmeyen kart: {ad}");

    /// <summary>Alan yetkisi: gizli alan gövdeye hiç girmez, adi bilgi olarak doner (§3.1).</summary>
    private static (List<KartAlani> Okunabilir, List<string> Gizli) Alanlar(
        KartTanimi tanim, IstekBaglami baglam)
    {
        var okunabilir = new List<KartAlani>();
        var gizli = new List<string>();

        foreach (var alan in tanim.Alanlar)
        {
            if (baglam.Yetkiler.AlanOkunur(tanim.Ad, alan.Ad)) okunabilir.Add(alan);
            else gizli.Add(alan.Ad);
        }

        return (okunabilir, gizli);
    }

    /// <summary>
    /// Istek govdesini dogrular ve DB degerlerine cevirir.
    /// Kurallar (§3.2): alan gondermemek "degistirme", null gondermek "bosalt".
    /// Yazilamayan ya da yetkisiz alan gelirse SESSIZCE YOK SAYILMAZ - hata verilir.
    /// </summary>
    private static Dictionary<string, object?> Degerler(KartTanimi tanim,
        Dictionary<string, JsonElement>? gelen, IstekBaglami baglam, bool yeni)
    {
        var sonuc = new Dictionary<string, object?>(StringComparer.Ordinal);
        if (gelen is null) return sonuc;

        foreach (var (ad, deger) in gelen)
        {
            if (ad is "surum" or "id") continue;

            var alan = tanim.Alan(ad)
                ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen alan: {ad}",
                       new AlanHatasi(ad, "Bu kartta boyle bir alan yok."));

            if (!alan.Yazilabilir)
                throw GentegreHatasi.Dogrulama($"{ad} alani degistirilemez.",
                    new AlanHatasi(ad, "Salt okunur alan."));

            if (!baglam.Yetkiler.AlanYazilir(tanim.Ad, alan.Ad))
                throw GentegreHatasi.Yasak($"{ad} alanini degistirme yetkiniz yok.");

            var cevrilmis = DegerCevirici.Cevir(deger, alan.Tip, ad, ad);
            DegerCevirici.UzunlukKontrol(alan, cevrilmis, ad);
            sonuc[ad] = cevrilmis;
        }

        if (yeni)
            foreach (var zorunlu in tanim.Alanlar.Where(a => a.Zorunlu))
                if (!sonuc.TryGetValue(zorunlu.Ad, out var d) || d is null ||
                    (d is string m && m.Trim().Length == 0))
                    throw GentegreHatasi.Dogrulama($"{zorunlu.Etiket} zorunlu.",
                        new AlanHatasi(zorunlu.Ad, $"{zorunlu.Etiket} boş bırakılamaz."));

        return sonuc;
    }

}
