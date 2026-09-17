using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ONAY UÇLARI (738/739) — modülden bağımsız.
///
/// ============ KARAR NEREDE VERİLİR ===================================
/// Kaydın kendi ucu da (satınalmanın `/talep/{id}/karar`ı gibi) karar
/// yazabilir, bu uç da. Fark: modülün ucu KENDİ yetkisini ve kendi durum
/// alanını bilir; bu uç genel kutudan gelen kararı alır ve kaydın durumunu
/// AKIŞ TANIMINDAN öğrenir. Kutudan karar verilebilmesi şart - kullanıcıyı
/// her tür için ayrı ekrana yollamak, tek kutunun anlamını ortadan kaldırırdı.
///
/// ============ DURUM EŞLEMESİ MODÜLE AİTTİR ===========================
/// Zincir bitince kaydın durumunu yazmak modülün işi. Burada bunu akış
/// koduna bakarak yapıyoruz (`satinalma.talep` → satınalma talebinin durum
/// kodları). Yeni tür eklendiğinde buraya bir dal gelir - motorun içine
/// değil: motor sırayı yürütür, "onaylandı ne demek" sorusunu modül yanıtlar.
/// </summary>
public static class OnayUclari
{
    private const int LogOnay = 1243;

    /// <summary>Akış deneme isteği - kayıt üretmez, kuru çalıştırma.</summary>
    public sealed class AkisDenemeIstegi
    {
        public decimal Olcu { get; set; }
        /// <summary>Sayıya sığmayan koşullar ("butce", "butce_asildi").</summary>
        public string[]? Bayraklar { get; set; }
    }

    public sealed class OnayKararIstegi
    {
        /// <summary>onayla · reddet · bilgi-iste · sozlu-onay</summary>
        public string? Karar { get; set; }
        public string? Gerekce { get; set; }
        public decimal? YaziliSaat { get; set; }
        /// <summary>
        /// KISMİ ONAY: kararla birlikte ölçüyü DÜŞÜRMEK (iskontoda "%20
        /// istendi, %10 verildi"). Verilirse yalnız "onayla" ile anlamlıdır;
        /// yükseltilemez. Ölçü düşünce gerekmeyen ileri basamaklar atlanır.
        /// </summary>
        public decimal? Olcu { get; set; }
    }

    public static void OnayUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/onay").WithTags("Onay").RequireAuthorization();

        // ------------------------------------------------ gelen kutusu ----
        // KUTU KİŞİYE GÖRE SÜZÜLÜR: rol basamağı o role sahip herkese,
        //   kişiye atanan basamak yalnız o kişiye (ve vekiline) düşer.
        //   Süzmeyi listeye bırakmıyoruz - "hepsini gör, kendininkini bul"
        //   kuyruğun kendisini işe çevirirdi.
        grup.MapGet("/kutum", async (
            BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select v.id, v.onay_id as "onayId", v.kaynak_tur as "kaynakTur",
                       v.kaynak_id as "kaynakId", v.kayit_no as "kayitNo", v.konu,
                       v.talep_eden as "talepEden", v.birim, v.olcu,
                       v.olcu_adi as "olcuAdi", v.adim_ad as "adimAd", v.sira, v.rol,
                       v.durum, v.gerekce, v.baslama, v.termin,
                       v.gecikme_gun as "gecikmeGun", v.akis_kod as "akisKod",
                       v.akis_ad as "akisAd",
                       v.atanan_kullanici_id as "atananKullaniciId"
                  from public.v_onay_kutusu v
                 where (@p1::int is null or v.sube_id = @p1)
                   and (
                        -- KİŞİYE ATANMIŞ basamak: sahibi ya da vekili
                        (v.atanan_kullanici_id is not null
                         and (v.atanan_kullanici_id = @p0
                              or exists (select 1 from public.onay_vekalet k
                                          where k.devreden_id = v.atanan_kullanici_id
                                            and k.devralan_id = @p0 and k.aktif = 1
                                            and current_date between k.baslangic and k.bitis)))
                        -- ROL basamağı: yetkisi olan görür. Yetki kontrolü
                        --   karar ucunda yapılır; burada kutuyu boş bırakmamak
                        --   için rol basamakları listelenir.
                        or v.atanan_kullanici_id is null)
                 order by v.gecikme_gun desc, v.baslama
                 limit 500
                """, null, [baglam.KullaniciId, baglam.SubeId],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ kaydın zinciri ----
        grup.MapGet("/kayit/{kaynakTur:int}/{kaynakId:long}", async (
            int kaynakTur, long kaynakId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var baglanti = await veri.AcAsync(iptal);

            var n = await baglanti.TekAsync("""
                select o.id, o.durum, o.olcu, o.bayraklar, o.baslama, o.bitis,
                       k.kod as "akisKod", k.ad as "akisAd", k.olcu_adi as "olcuAdi"
                  from public.onay o
                  left join public.onay_akis k on k.id = o.akis_id
                 where o.kaynak_tur = @p0 and o.kaynak_id = @p1
                 order by o.id desc limit 1
                """, null, [kaynakTur, kaynakId], OkuyucuGenisletmeleri.Sozluk, iptal);

            if (n is null)
                return Results.Ok(new { onay = (object?)null, adimlar = Array.Empty<object>(),
                                        izlemeNo = baglam.IzlemeNo });

            var adimlar = await baglanti.ListeAsync("""
                select a.id, a.sira, a.ad, a.rol, a.durum,
                       a.karar_veren_id as "kararVerenId", a.karar_zamani as "kararZamani",
                       a.gerekce, a.yazili_son as "yaziliSon", a.termin
                  from public.onay_adim a where a.onay_id = @p0 order by a.sira
                """, null, [Convert.ToInt64(n["id"])], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { onay = n, adimlar, izlemeNo = baglam.IzlemeNo });
        });

        // -------------------------------------------------- akışı dene ----
        // KURU ÇALIŞTIRMA: kayıt üretmez. Eşiği değiştiren kişi sonucunu
        //   gerçek bir talep açmadan görmeli - yoksa akışın doğru kurulup
        //   kurulmadığı ancak ilk gerçek talepte, yanlış kişiye düşünce
        //   anlaşılırdı.
        //
        //   ZİNCİR KURMAYLA AYNI METOT (`SecilenAdimlarAsync`): ikisi ayrı
        //   yazılsaydı deneme ekranı gerçekte kurulacaktan başka bir şey
        //   gösterebilirdi ve kimse farkı görmezdi.
        grup.MapPost("/akis/{akisId:int}/dene", async (
            int akisId, AkisDenemeIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var akis = await baglanti.TekAsync("""
                select k.kod, k.ad, k.olcu_adi as "olcuAdi", k.aktif,
                       (select count(*) from public.onay_akis_adim a
                         where a.akis_id = k.id and a.aktif = 1) as "tanimli"
                  from public.onay_akis k where k.id = @p0
                """, null, [akisId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Onay akışı bulunamadı.");

            var bayrak = string.Join(",", istek.Bayraklar ?? []);
            var secilen = await Servisler.OnayMotoru.SecilenAdimlarAsync(
                baglanti, null, akisId, istek.Olcu, bayrak, iptal);

            // BOŞ ZİNCİR SESSİZ GEÇMEZ: hiçbir basamağı çıkmayan akış, o
            //   kaydın imzasız onaylanması demektir. Denemenin asıl işi bunu
            //   göstermek.
            var uyarilar = new List<string>();
            if (secilen.Count == 0)
                uyarilar.Add("Bu ölçüde HİÇ BASAMAK ÇIKMIYOR - kayıt imzasız onaylanır. "
                             + "Eşiksiz bir taban basamak tanımlayın.");
            if (Convert.ToInt16(akis["aktif"] ?? (short)0) != 1)
                uyarilar.Add("Akış pasif - bu hâliyle hiçbir kayıtta çalışmaz.");
            if (secilen.Any(a => a.SahipTuru == 3))
                uyarilar.Add("Âmir bazlı basamak var; âmir bağı henüz kurulu değil "
                             + "(organizasyon şeması) - o basamak kimseye düşmez.");

            return Results.Ok(new
            {
                akis = akis["kod"], akisAd = akis["ad"], olcuAdi = akis["olcuAdi"],
                olcu = istek.Olcu, bayraklar = istek.Bayraklar ?? [],
                tanimliBasamak = Convert.ToInt32(akis["tanimli"] ?? 0),
                adimlar = secilen.Select(a => new
                {
                    sira = a.Sira, ad = a.Ad, sahipTuru = a.SahipTuru, rol = a.Rol,
                    kullaniciId = a.KullaniciId, sureGun = a.SureGun,
                    esikAlt = a.EsikAlt, bayrak = a.Bayrak, eImza = a.EImza,
                }),
                uyarilar, izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------- karar ----
        grup.MapPost("/kayit/{kaynakTur:int}/{kaynakId:long}/karar", async (
            int kaynakTur, long kaynakId, OnayKararIstegi istek, BaglamCozucu cozucu,
            VeriKaynagi veri, Servisler.OnayMotoru onay, LogDeposu log,
            Servisler.OnayBildirimi haber,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);

            var karar = (istek.Karar ?? "").Trim().ToLowerInvariant();
            var kararKodu = karar switch
            {
                "onayla" => Servisler.OnayMotoru.Onaylandi,
                "reddet" => Servisler.OnayMotoru.Reddedildi,
                "bilgi-iste" => Servisler.OnayMotoru.BilgiIstendi,
                "sozlu-onay" => Servisler.OnayMotoru.SozluOnay,
                _ => throw GentegreHatasi.Dogrulama("Bilinmeyen karar.",
                        new AlanHatasi("karar", "onayla · reddet · bilgi-iste · sozlu-onay"))
            };

            await using var baglanti = await veri.AcAsync(iptal);

            var b = await baglanti.TekAsync("""
                select v.rol, v.akis_kod as "akisKod", v.adim_ad as "adimAd",
                       v.onay_id as "onayId", v.olcu
                  from public.v_onay_bekleyen v
                 where v.kaynak_tur = @p0 and v.kaynak_id = @p1
                 order by v.sira limit 1
                """, null, [kaynakTur, kaynakId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.IsKurali("Bu kayıtta bekleyen onay basamağı yok.");

            var akisKod = b["akisKod"] as string ?? "";
            var rol = Convert.ToInt16(b["rol"] ?? (short)0);
            var onayId = Convert.ToInt64(b["onayId"]);
            var mevcutOlcu = Convert.ToDecimal(b["olcu"] ?? 0m);

            // YETKİ AKIŞIN KENDİ MODÜLÜNDEN: basamağın rolü satınalmanın
            //   yetki koduysa satınalmanınkini isteriz. Motorun içine
            //   taşımadık - her modülün yetki haritası motora dolardı.
            baglam.AksiyonIste(AksiyonKodu(akisKod, rol));

            // ÖLÇÜ SINIRI AKIŞIN KENDİ MODÜLÜNDEN: "en çok kaç verebilirsin"
            //   sorusu yetki koduyla değil, yetkinin DEĞERİYLE cevaplanır ve
            //   yalnız bazı modüllerde vardır. Karar yazılmadan önce sorulur.
            var etkinOlcu = istek.Olcu ?? mevcutOlcu;
            if (kararKodu is Servisler.OnayMotoru.Onaylandi
                          or Servisler.OnayMotoru.SozluOnay)
                OlcuSiniriDogrula(akisKod, etkinOlcu, baglam);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // KISMİ ONAY KARARDAN ÖNCE: ölçü düşürülünce gerekmeyen ileri
            //   basamaklar atlanır, sonra karar yazılır. Ters sırada olsaydı
            //   karar "sıradaki basamak" olarak az sonra atlanacak bir
            //   basamağı gösterir, bildirim de oraya giderdi.
            Servisler.OnayMotoru.OlcuSonucu? olcuSonucu = null;
            if (istek.Olcu is not null
                && kararKodu is Servisler.OnayMotoru.Onaylandi
                             or Servisler.OnayMotoru.SozluOnay)
                olcuSonucu = await onay.OlcuDusurAsync(baglanti, islem, onayId,
                    istek.Olcu.Value, baglam, iptal);

            var sonuc = await onay.KararAsync(baglanti, islem, kaynakTur, kaynakId,
                kararKodu, istek.Gerekce, baglam, istek.YaziliSaat ?? 24, iptal);

            // KAYDIN DURUMU: akışa göre. Zincir bitmediyse kayda dokunulmaz.
            var kayitDurum = await KayitDurumYazAsync(baglanti, islem, akisKod,
                kaynakId, sonuc.ZincirDurum, istek.Gerekce, baglam, iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogOnay,
                sonuc.OnayId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    karar, basamak = sonuc.Sira, rol = sonuc.Rol, adim = sonuc.AdimAd,
                    akis = akisKod, gerekce = istek.Gerekce, kayitDurum,
                    olcu = olcuSonucu is null ? null
                         : $"{olcuSonucu.EskiOlcu:0.##} -> {olcuSonucu.YeniOlcu:0.##}",
                    atlanan = olcuSonucu?.AtlananAdim
                }, iptal: iptal);

            await islem.CommitAsync(iptal);

            // BİLDİRİM COMMIT'TEN SONRA (741): işlem içinde yazsaydık, karar
            //   geri alındığında gönderilmiş bir "onayınız bekleniyor"
            //   mesajının karşılığı veritabanında olmazdı. Sırası gelen
            //   basamağa haber, zincir bittiyse talebi açana sonuç.
            //   BİLDİRİM KARARI DÜŞÜRMEZ: karar zaten yazıldı. Bildirim
            //   yolunda bir hata (şablon, alıcı, sağlayıcı) kullanıcıya
            //   "onay verilemedi" diye görünseydi, imzalanmış bir kararı
            //   ikinci kez vermeye çalışırdı.
            int haberler;
            try
            {
                haberler = sonuc.ZincirDurum == Servisler.OnayMotoru.ZincirYuruyor
                    ? await haber.SiradakiniBildirAsync(baglanti, sonuc.OnayId,
                          baglam.KullaniciId, baglam.SubeId, iptal)
                    : await haber.SonucBildirAsync(baglanti, sonuc.OnayId, sonuc.ZincirDurum,
                          istek.Gerekce, baglam.KullaniciId, baglam.SubeId, iptal);
            }
            catch (Exception) { haberler = -1; }

            return Results.Ok(new
            {
                karar, basamak = sonuc.Sira, adim = sonuc.AdimAd, bildirim = haberler,
                zincirDurum = sonuc.ZincirDurum, sonrakiBasamak = sonuc.SonrakiSira,
                kayitDurum, yaziliSon = sonuc.YaziliSon,
                olcu = olcuSonucu?.YeniOlcu, atlananBasamak = olcuSonucu?.AtlananAdim,
                izlemeNo = baglam.IzlemeNo
            });
        });
    }

    /// <summary>
    /// Basamağın rolü hangi aksiyon yetkisini ister. Akış kodu modülü,
    /// rol de basamağı söyler - ikisi birlikte olmadan "birim sorumlusu"
    /// hangi modülün birim sorumlusu belli olmaz.
    /// </summary>
    private static string AksiyonKodu(string akisKod, short rol) => akisKod switch
    {
        "satinalma.talep" => rol switch
        {
            1 => "satinalma.onay_birim",
            2 or 4 => "satinalma.onay_satinalma",
            _ => "satinalma.onay_ust",
        },
        // İZİN (743): âmir basamağı KİŞİYE atanır (rol 0) - yetkisi olan
        //   herkes değil, yalnız o kişi ve vekili imzalayabilir; motor
        //   zaten atananı kontrol ediyor, burada âmir yetkisi isteniyor.
        "personel.izin" => rol switch
        {
            0 => "ik.izin_onay_amir",
            6 => "ik.izin_onay_ik",
            _ => "ik.izin_onay_ust",
        },
        // MASRAFLI ONARIM (752). Rol 6 burada TEKNİK MÜDÜR - izin akışında
        //   aynı kod İK'yı gösteriyor. Rol kodları akışın kendi dilidir;
        //   tek bir "rol 6 = şu yetki" haritası kursaydık iki modül
        //   birbirinin imza düzenini belirlerdi.
        "demirbas.onarim" => rol switch
        {
            6 => "demirbas.onarim_onay_teknik",
            4 => "demirbas.onarim_onay_mali",
            _ => "demirbas.onarim_onay_ust",
        },
        // DOKÜMAN (758). Akış kodu `dokuman.<akisId>` - kurum birden çok
        //   doküman akışı tanımlayabilir, hepsi aynı karar yetkisini ister.
        //   Basamak rolüne göre ayrı yetki ÜRETİLMİYOR: doküman akış
        //   adımlarında rol bugün hiç kullanılmıyor (hepsi boş).
        var _ when akisKod.StartsWith("dokuman.", StringComparison.Ordinal)
            => "dokuman.onay",
        // İSKONTO (754). Rol 1 birim, 4 mali, 5 üst yönetim - satınalmadaki
        //   rol düzeniyle aynı, çünkü ikisi de kurumun parasına dokunur ve
        //   aynı imza hiyerarşisinden geçer.
        "belge.iskonto" => rol switch
        {
            1 => "belge.iskonto_onay_birim",
            4 => "belge.iskonto_onay_mali",
            _ => "belge.iskonto_onay_ust",
        },
        "personel.avans" => rol switch
        {
            0 => "ik.avans_onay_amir",
            6 => "ik.avans_onay_ik",
            4 => "ik.avans_onay_mali",
            _ => "ik.avans_onay_ust",
        },
        _ => throw GentegreHatasi.IsKurali(
            $"Bu akışın karar yetkisi tanımlı değil: {akisKod}."),
    };

    /// <summary>
    /// ÖLÇÜ TAVANI (754) — bazı akışlarda onaylayanın verebileceği en büyük
    /// değer yetkinin DEĞERİNDE saklıdır ("bu kişi en çok %10 iskonto
    /// verebilir"). Bu yetki kodunun kendisiyle sorulamaz: kod "sıra sende
    /// mi" sorusunu, değer "en çok kaç" sorusunu cevaplar.
    ///
    /// Tavansız akışlar buradan sessizce geçer - her modüle tavan uydurmak,
    /// olmayan bir sınırı varmış gibi göstermek olurdu.
    /// </summary>
    private static void OlcuSiniriDogrula(string akisKod, decimal olcu,
                                          IstekBaglami baglam)
    {
        if (akisKod != "belge.iskonto") return;

        // 661'den beri iskonto tavanı `basvuru.iskonto` yetkisinin sayısal
        //   değeridir; 754 basamak yetkilerini eklerken onu KALDIRMADI,
        //   çünkü basamağı hak etmek ile oranı hak etmek ayrı şeylerdir.
        var tavan = baglam.Yetkiler.AksiyonDegeri("basvuru.iskonto");
        if (tavan <= 0)
            throw GentegreHatasi.IsKurali(
                "İskonto onay tavanınız tanımlı değil; bu kararı veremezsiniz.");
        if (olcu > tavan)
            throw GentegreHatasi.Dogrulama(
                $"Onaylanan oran yetkinizin üstünde (en çok %{tavan:0.##}).",
                new AlanHatasi("olcu", $"En çok %{tavan:0.##}."));
    }

    /// <summary>
    /// Zincir bitince kaydın kendi durumunu yazar. Zincir yürüyorsa kayda
    /// dokunulmaz - ara basamakta durumu değiştirmek, "onaylandı" demenin
    /// eşiğini düşürürdü.
    /// </summary>
    private static async Task<short?> KayitDurumYazAsync(
        Npgsql.NpgsqlConnection baglanti, Npgsql.NpgsqlTransaction islem,
        string akisKod, long kaynakId, short zincirDurum, string? gerekce,
        IstekBaglami baglam, CancellationToken iptal)
    {
        if (zincirDurum == Servisler.OnayMotoru.ZincirYuruyor) return null;

        switch (akisKod)
        {
            case "satinalma.talep":
                // 2 onaylandı · 3 reddedildi (satinalma_talep.durum).
                short yeni = zincirDurum == Servisler.OnayMotoru.ZincirOnaylandi
                           ? (short)2 : (short)3;
                await baglanti.CalistirAsync("""
                    update public.satinalma_talep
                       set durum = @p1,
                           red_neden = case when @p1 = 3 then @p2 else red_neden end,
                           degistiren = @p3, degistirme_tarihi = (now())::timestamp
                     where id = @p0
                    """, islem, [kaynakId, yeni, gerekce ?? "", baglam.KullaniciId], iptal);
                return yeni;

            case "personel.avans":
                // 2 onaylandı · 3 reddedildi (personel_avans.durum).
                //   ÖDEME AYRI ADIM: onay parayı çıkarmaz, çıkarma iznini
                //   verir - kasa işlemi ayrı bir kararla yazılır.
                short avansDurum = zincirDurum == Servisler.OnayMotoru.ZincirOnaylandi
                                 ? (short)2 : (short)3;
                await baglanti.CalistirAsync("""
                    update public.personel_avans
                       set durum = @p1,
                           red_neden = case when @p1 = 3 then @p2 else red_neden end,
                           degistiren = @p3, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [(int)kaynakId, avansDurum, gerekce ?? "",
                                 baglam.KullaniciId], iptal);
                return avansDurum;

            case "demirbas.onarim":
                // 2 onaylandı · 3 reddedildi (demirbas_is_emri.onay_durum).
                //   İŞ EMRİNİN KENDİ DURUMUNA DOKUNULMAZ: onay parayı
                //   onaylar, işi ilerletmez - cihaz hâlâ teknisyende.
                short onarimDurum = zincirDurum == Servisler.OnayMotoru.ZincirOnaylandi
                                  ? (short)2 : (short)3;
                await baglanti.CalistirAsync("""
                    update public.demirbas_is_emri
                       set onay_durum = @p1,
                           degistiren = @p2, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [kaynakId, onarimDurum, baglam.KullaniciId], iptal);
                return onarimDurum;

            case "belge.iskonto":
                // SATIRA YAZAN TEK YER `fn_iskonto_talep_karar` (662): oranı
                //   satırlara yazmak ve satırları kilitlemek ayrılamaz iki
                //   iştir. Zincir bitince onu çağırıyoruz; onaylanan oran
                //   `onay.olcu`dur - kısmi onayda düşürülmüş hâli.
                short iskontoDurum = zincirDurum == Servisler.OnayMotoru.ZincirOnaylandi
                                   ? (short)1 : (short)2;
                var olcu = await baglanti.TekDegerAsync<decimal>("""
                    select olcu from public.onay
                     where kaynak_tur = 1256 and kaynak_id = @p0
                     order by id desc limit 1
                    """, islem, [kaynakId], iptal);
                await baglanti.CalistirAsync(
                    "select public.fn_iskonto_talep_karar(@p0, @p1, @p2, @p3, @p4)",
                    islem, [(int)kaynakId, iskontoDurum,
                            iskontoDurum == 1 ? olcu : 0m,
                            gerekce ?? "", baglam.KullaniciId], iptal);
                return iskontoDurum;

            case var _ when akisKod.StartsWith("dokuman.", StringComparison.Ordinal):
                // SÜRÜMÜ YAYINLAYAN / REDDEDEN TEK YER `fn_dokuman_onay_sonuc`
                //   (758): önceki yayını arşive düşürmek ile bu sürümü
                //   yayınlamak ayrılamaz iki iştir. Kaynak id = sürüm id.
                short dokumanSonuc = zincirDurum == Servisler.OnayMotoru.ZincirOnaylandi
                                   ? (short)1 : (short)0;
                await baglanti.CalistirAsync(
                    "select public.fn_dokuman_onay_sonuc(@p0, @p1, @p2, @p3)",
                    islem, [(int)kaynakId, dokumanSonuc, gerekce ?? "",
                            baglam.KullaniciId], iptal);
                return dokumanSonuc;

            case "personel.izin":
                // 2 onaylı · 3 reddedildi (personel_izin.durum).
                short izinDurum = zincirDurum == Servisler.OnayMotoru.ZincirOnaylandi
                                ? (short)2 : (short)3;
                await baglanti.CalistirAsync("""
                    update public.personel_izin
                       set durum = @p1,
                           red_neden = case when @p1 = 3 then @p2 else red_neden end,
                           degistiren = @p3, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [(int)kaynakId, izinDurum, gerekce ?? "",
                                 baglam.KullaniciId], iptal);
                return izinDurum;

            default:
                // TANIMSIZ AKIŞ SESSİZCE GEÇMEZ: zincir bitti ama kaydın
                //   durumu yazılmadıysa kayıt "onayda" görünmeye devam eder.
                throw GentegreHatasi.IsKurali(
                    $"Bu akışın kayıt durumu eşlemesi tanımlı değil: {akisKod}.");
        }
    }
}
