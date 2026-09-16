using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ECZANE İŞ AKIŞI UÇLARI (722 tabloları).
///
/// Kart ve liste kaydı okuyup yazar; buradaki uçlar DURUMU ilerletir ve
/// ilerletmenin koşullarını uygular. Ayrı olmalarının sebebi, her birinin
/// kayıt yazmaktan fazlasını yapması: iade kararı üç ölçüte bakıp stoğa giriş
/// fişi kesiyor, imha çıkış fişi üretiyor, doz adımı "kontrol eden ile
/// hazırlayan aynı kişi olamaz" kuralını uyguluyor.
///
/// ÇİFT KONTROL GEÇİLEBİLİR AMA SESSİZCE DEĞİL. Ünite dozda ve kemoterapide
/// ikinci kişi kuralının geçilmesi (tek eczacılı gece nöbeti) `zorla` +
/// gerekçe ister ve işlem günlüğüne düşer. Sert engel koysaydık, kural
/// sistemin dışında işletilir ve hiç kayda geçmezdi; serbest bıraksaydık
/// koruma diye bir şey kalmazdı.
///
/// DOZ HESABI ÖNERİDİR, EMİR DEĞİL. `/doz-hesapla` yalnız `hesaplanan`
/// kolonunu yazar; `uygulanan_doz`u eczacı girer. İkisi aynı kolon olsaydı
/// flakon yuvarlaması ile hesabın kendisi birbirine karışır, "neden 875 değil
/// 870" sorusu sonradan yanıtlanamazdı.
/// </summary>
public static partial class EczaneUclari
{
    // islem_log.tablo_id - KartKatalogu.Eczane ile aynı.
    private const int LogKontrol = 1200;
    private const int LogHazirlama = 1201;
    private const int LogIade = 1203;
    private const int LogImha = 1204;
    private const int LogDoz = 1206;
    private const int LogSayim = 1207;
    /// <summary>Defterin kart karşılığı yok (satır silinmez) - kendi tablo kodu.</summary>
    private const int LogDefter = 1209;

    // ---------------------------------------------------------- istekler ----

    public sealed class KararIstegi
    {
        /// <summary>1 uygun · 2 öneri yapıldı · 3 durduruldu</summary>
        public short Karar { get; set; }
        public string? Oneri { get; set; }
        /// <summary>Uyarı gerçekten bir ilaç hatasını önlediyse (SKS göstergesi).</summary>
        public bool OnlenenHata { get; set; }
        public int? HekimId { get; set; }
        /// <summary>Yüksek düzey (geçilemez) uyarıyı "uygun" diye kapat.</summary>
        public bool Zorla { get; set; }
        public string? Gerekce { get; set; }
    }

    public sealed class HekimYanitIstegi
    {
        public string Yanit { get; set; } = "";
        /// <summary>Hekim yanıtı üzerine eczacı kararını da güncelle (isteğe bağlı).</summary>
        public short? Karar { get; set; }
    }

    public sealed class DozAdimIstegi
    {
        /// <summary>hazirla · kontrol · teslim · iade · imha</summary>
        public string Adim { get; set; } = "";
        public DateTime? Zaman { get; set; }
        public int? PersonelId { get; set; }
        public int? TeslimAlanId { get; set; }
        /// <summary>Çift kontrol kuralını geç (gerekçe zorunlu, günlüğe düşer).</summary>
        public bool Zorla { get; set; }
        public string? Gerekce { get; set; }
    }

    public sealed class HazirlamaAdimIstegi
    {
        /// <summary>hasta-geldi · hazirla · dogrula · teslim · iptal</summary>
        public string Adim { get; set; } = "";
        public DateTime? Zaman { get; set; }
        public int? PersonelId { get; set; }
        public int? TeslimAlanId { get; set; }
        public string? KabinKod { get; set; }
        public DateTime? SonKullanim { get; set; }
        public string? Saklama { get; set; }
        public bool Zorla { get; set; }
        public string? Gerekce { get; set; }
    }

    public sealed class DozHesapIstegi
    {
        public decimal? BoyCm { get; set; }
        public decimal? KiloKg { get; set; }
        /// <summary>Kreatinin klirensi (Calvert formülü karboplatin için ister).</summary>
        public decimal? Krkl { get; set; }
        /// <summary>Doz azaltma yüzdesi (böbrek/karaciğer/toksisite) - 0-100.</summary>
        public decimal? AzaltmaYuzde { get; set; }
    }

    public sealed class IadeKararIstegi
    {
        /// <summary>1 stoğa kabul · 2 imhaya · 3 kasaya (kontrollü)</summary>
        public short Karar { get; set; }
        public int? DepoId { get; set; }
        public long? ImhaId { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class ImhaOnayIstegi
    {
        public string Komisyon { get; set; } = "";
        public string? Aciklama { get; set; }
    }

    public sealed class ImhaEtIstegi
    {
        public int? DepoId { get; set; }
        public string? AtikTeslimNo { get; set; }
    }

    public sealed class DefterIstegi
    {
        /// <summary>1 giriş · 2 çıkış · 3 iade · 4 artık imha · 5 devir · 6 sayım</summary>
        public short Hareket { get; set; }
        public int? StokId { get; set; }
        public int? SeriLotId { get; set; }
        public string? Ad { get; set; }
        public decimal Miktar { get; set; }
        /// <summary>1 kırmızı (narkotik) · 2 yeşil (psikotrop)</summary>
        public short? ReceteRenk { get; set; }
        public string? ReceteNo { get; set; }
        public int? HastaId { get; set; }
        public int? DepartmanId { get; set; }
        public int? TeslimEdenId { get; set; }
        public int? TeslimAlanId { get; set; }
        public int? TanikId { get; set; }
        public int? BelgeId { get; set; }
        public string? Aciklama { get; set; }
        /// <summary>DÜZELTME: hatalı satır silinmez, ters satırla kapatılır.</summary>
        public long? DuzeltilenId { get; set; }
    }

    public sealed class SayimKapatIstegi
    {
        public string? Aciklama { get; set; }
        /// <summary>Fark varken kapat (tutanak açıldı). Gerekçe zorunlu.</summary>
        public bool FarklaKapat { get; set; }
    }

    // ============================================================= kayıt ==
    public static void EczaneUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/eczane").WithTags("Eczane").RequireAuthorization();

        KontrolUclari(grup);
        DozUclari(grup);
        HazirlamaUclari(grup);
        IadeImhaUclari(grup);
        KontrolluUclari(grup);
    }

    // =================================================== eczacı kontrolü ==
    private static void KontrolUclari(RouteGroupBuilder grup)
    {
        // ECZACI KARARI. Karar order satırını DEĞİŞTİRMEZ - eczacı önerir,
        //   hekim karar verir. Burada saklanan, eczacının ne gördüğü ve ne
        //   dediğidir; order'ı doğrudan değiştirseydik hekimin tedavi kararı
        //   sistemde sahipsiz kalırdı.
        grup.MapPost("/kontrol/{id:long}/karar", async (
            long id, KararIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.order", Islem.Degistir);
            baglam.AksiyonIste("eczane.onay");

            if (istek.Karar is < 1 or > 3)
                throw GentegreHatasi.Dogrulama("Geçersiz karar.",
                    new AlanHatasi("karar", "1 uygun · 2 öneri yapıldı · 3 durduruldu"));

            // ÖNERİ ZORUNLU: "durduruldu" ya da "öneri yapıldı" derken ne
            //   önerildiği yazılmazsa hekim neye göre karar verecek?
            if (istek.Karar is 2 or 3 && string.IsNullOrWhiteSpace(istek.Oneri))
                throw GentegreHatasi.Dogrulama("Öneri zorunlu.",
                    new AlanHatasi("oneri", "Bu kararda öneri metni zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.duzey, k.karar, k.tur, k.bulgu, k.hekim_id as "hekimId"
                  from public.eczane_kontrol k where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Eczacı kontrolü bulunamadı.");

            // YÜKSEK DÜZEY = GEÇİLEMEZ (722 kod listesi). "Uygun" diyerek
            //   kapatmak mümkün ama gerekçesiz değil: geçilen bir alerji ya da
            //   yüksek riskli ilaç etkileşimi, kurumun sonradan hesabını
            //   vereceği bir olaydır.
            var duzey = Convert.ToInt16(k["duzey"] ?? (short)0);
            if (duzey == 3 && istek.Karar == 1)
            {
                if (!istek.Zorla)
                    throw GentegreHatasi.IsKurali(
                        "Yüksek düzey (geçilemez) uyarı 'uygun' olarak kapatılamaz.",
                        new { duzey, bulgu = k["bulgu"] });
                if (string.IsNullOrWhiteSpace(istek.Gerekce))
                    throw GentegreHatasi.Dogrulama("Geçilen yüksek uyarıda gerekçe zorunlu.",
                        new AlanHatasi("gerekce", "Gerekçe zorunlu."));
            }

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // BİLDİRİM ZAMANI YALNIZ İLK KEZ YAZILIR: hekime kaç kez söylendiği
            //   değil, NE ZAMAN söylendiği izlenir - yanıt süresi ondan hesaplanır.
            await baglanti.CalistirAsync("""
                update public.eczane_kontrol
                   set karar = @p1, oneri = coalesce(nullif(@p2, ''), oneri),
                       eczaci_id = @p3, karar_zamani = @p4,
                       onlenen_hata = @p5,
                       hekim_id = coalesce(@p6, hekim_id),
                       bildirim_zamani = case
                            when @p6 is not null and bildirim_zamani is null then @p4
                            else bildirim_zamani end,
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem,
                [id, istek.Karar, istek.Oneri ?? "", baglam.KullaniciId, simdi,
                 (short)(istek.OnlenenHata ? 1 : 0), istek.HekimId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogKontrol, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    karar = istek.Karar, oneri = istek.Oneri,
                    onlenenHata = istek.OnlenenHata,
                    hekimeBildirildi = istek.HekimId,
                    gecilenYuksekUyari = duzey == 3 && istek.Karar == 1 ? istek.Gerekce : null
                }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { karar = istek.Karar, kararZamani = simdi, izlemeNo = baglam.IzlemeNo });
        });

        // HEKİM YANITI. "Okundu" damgası yanıttan AYRI: hekimin uyarıyı
        //   görmesi ile yanıtlaması aynı şey değil; kaç uyarının okunup da
        //   yanıtsız kaldığı kalite göstergesidir.
        grup.MapPost("/kontrol/{id:long}/hekim-yanit", async (
            long id, HekimYanitIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.order", Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.Yanit))
                throw GentegreHatasi.Dogrulama("Yanıt zorunlu.",
                    new AlanHatasi("yanit", "Hekim yanıtı boş olamaz."));

            await using var baglanti = await veri.AcAsync(iptal);
            var simdi = DateTime.Now;

            var etkilenen = await baglanti.CalistirAsync("""
                update public.eczane_kontrol
                   set hekim_yaniti = @p1,
                       okundu_zamani = coalesce(okundu_zamani, @p2),
                       karar = coalesce(@p3::smallint, karar),
                       degistiren = @p4, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, null, [id, istek.Yanit, simdi, istek.Karar, baglam.KullaniciId], iptal);

            if (etkilenen == 0) throw GentegreHatasi.Bulunamadi("Eczacı kontrolü bulunamadı.");

            await log.YazAsync(LogIslemi.Degistir, LogKontrol, id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { hekimYaniti = istek.Yanit, karar = istek.Karar }, iptal: iptal);

            return Results.Ok(new { okunduZamani = simdi, izlemeNo = baglam.IzlemeNo });
        });
    }

    // ========================================================= ünite doz ==
    private static void DozUclari(RouteGroupBuilder grup)
    {
        // DOZ AKIŞI. Sıra zorunlu: hazırlanmadan kontrol, kontrol edilmeden
        //   teslim yok. Ünite doz sisteminin tek koruması bu sıra ve ikinci
        //   kişidir - atlanırsa sistem yalnız bir kayıt defterine dönüşür.
        grup.MapPost("/doz/{id:long}/adim", async (
            long id, DozAdimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.doz", Islem.Degistir);

            var adim = (istek.Adim ?? "").Trim().ToLowerInvariant();
            // durum: 0 bekliyor · 1 hazırlandı · 2 kontrol edildi · 3 teslim
            //        4 uygulandı · 8 iade · 9 imha
            var hedef = adim switch
            {
                "hazirla" => (short)1,
                "kontrol" => (short)2,
                "teslim" => (short)3,
                "iade" => (short)8,
                "imha" => (short)9,
                _ => throw GentegreHatasi.Dogrulama("Bilinmeyen doz adımı.",
                        new AlanHatasi("adim", "hazirla · kontrol · teslim · iade · imha"))
            };

            await using var baglanti = await veri.AcAsync(iptal);

            var d = await baglanti.TekAsync("""
                select z.durum, z.hazirlayan_id as "hazirlayanId",
                       z.kontrol_eden_id as "kontrolEdenId", z.stok_id as "stokId",
                       z.seri_lot_id as "seriLotId",
                       (select l.son_kullanma_tarihi from public.stok_seri_lot l
                        where l.id = z.seri_lot_id) as skt
                  from public.eczane_doz z where z.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Doz kaydı bulunamadı.");

            var durum = Convert.ToInt16(d["durum"] ?? (short)0);
            if (durum is 8 or 9)
                throw GentegreHatasi.IsKurali("İade/imha edilmiş dozda akış ilerletilemez.");

            // SIRA. İade ve imha her aşamadan yapılabilir (doz düşürüldü,
            //   hasta çıktı) - onları sıraya sokmak gerçek olayı engellerdi.
            if (adim is "kontrol" or "teslim")
            {
                var gerekli = adim == "kontrol" ? (short)1 : (short)2;
                if (durum < gerekli)
                    throw GentegreHatasi.IsKurali(adim == "kontrol"
                        ? "Hazırlanmamış doz kontrol edilemez."
                        : "Kontrol edilmemiş doz teslim edilemez.");
            }

            var kisi = istek.PersonelId ?? baglam.KullaniciId;
            var uyarilar = new List<string>();

            // İKİNCİ KİŞİ. Hazırlayan kendi hazırladığını kontrol edemez -
            //   kontrolün bütün anlamı başka bir gözün bakması.
            if (adim == "kontrol" && d["hazirlayanId"] is { } hz
                && Convert.ToInt32(hz) == kisi)
            {
                if (!istek.Zorla)
                    throw GentegreHatasi.IsKurali(
                        "Dozu hazırlayan kişi kendi hazırladığını kontrol edemez.");
                if (string.IsNullOrWhiteSpace(istek.Gerekce))
                    throw GentegreHatasi.Dogrulama("Çift kontrol geçiliyorsa gerekçe zorunlu.",
                        new AlanHatasi("gerekce", "Gerekçe zorunlu."));
                uyarilar.Add("Çift kontrol geçildi - aynı kişi hazırladı ve kontrol etti.");
            }

            // MİADI GEÇMİŞ LOT ENGELDİR, uyarı değil: miadı geçmiş ilacın
            //   hastaya gitmesi ile stok bakiyesinin yanlış olması aynı ağırlıkta
            //   sayılamaz.
            if (adim is "hazirla" or "kontrol" or "teslim"
                && d["skt"] is DateTime skt && skt.Date < DateTime.Today)
                throw GentegreHatasi.IsKurali(
                    $"Lotun miadı geçmiş ({skt:dd.MM.yyyy}) - bu doz verilemez.");

            var zaman = istek.Zaman ?? DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // Her adım kendi damgasını yazar; durum GERİ GİTMEZ (iade/imha
            //   hariç - onlar bilerek sonlandırıcı).
            var sql = adim switch
            {
                "hazirla" => """
                    update public.eczane_doz
                       set durum = greatest(durum, @p1), hazirlayan_id = @p2,
                           hazirlama_zamani = @p3, degistiren = @p2,
                           degistirme_tarihi = (now())::timestamp
                     where id = @p0 returning durum
                    """,
                "kontrol" => """
                    update public.eczane_doz
                       set durum = greatest(durum, @p1), kontrol_eden_id = @p2,
                           kontrol_zamani = @p3, degistiren = @p2,
                           degistirme_tarihi = (now())::timestamp
                     where id = @p0 returning durum
                    """,
                "teslim" => """
                    update public.eczane_doz
                       set durum = greatest(durum, @p1), teslim_zamani = @p3,
                           teslim_alan_id = coalesce(@p4, teslim_alan_id),
                           degistiren = @p2, degistirme_tarihi = (now())::timestamp
                     where id = @p0 returning durum
                    """,
                _ => """
                    update public.eczane_doz
                       set durum = @p1, degistiren = @p2,
                           degistirme_tarihi = (now())::timestamp
                     where id = @p0 returning durum
                    """
            };

            var sonDurum = await baglanti.TekDegerAsync<int>(sql, islem,
                [id, hedef, kisi, zaman, istek.TeslimAlanId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogDoz, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    adim, zaman, personel = kisi,
                    ciftKontrolGecildi = uyarilar.Count > 0 ? istek.Gerekce : null
                }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { adim, zaman, durum = sonDurum, uyarilar, izlemeNo = baglam.IzlemeNo });
        });
    }

    // ========================================================= hazırlama ==
    private static void HazirlamaUclari(RouteGroupBuilder grup)
    {
        // KEMOTERAPİ / TPN AKIŞI.
        //
        // HASTA GELMEDEN HAZIRLANMAZ. Hazırlanıp iptal edilen kemoterapi çöpe
        //   gider (ve sitotoksik atık olarak imha edilir). `zorla` var çünkü
        //   bazı protokoller hasta gelmeden hazırlık ister - ama gerekçesiyle.
        grup.MapPost("/hazirlama/{id:long}/adim", async (
            long id, HazirlamaAdimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.hazirlama", Islem.Degistir);

            var adim = (istek.Adim ?? "").Trim().ToLowerInvariant();
            // durum: 0 sırada · 1 ön koşul · 2 doz onayı · 3 hazırlanıyor
            //        4 hazır · 5 teslim · 8 iptal
            if (adim is not ("hasta-geldi" or "hazirla" or "dogrula" or "teslim" or "iptal"))
                throw GentegreHatasi.Dogrulama("Bilinmeyen hazırlama adımı.",
                    new AlanHatasi("adim", "hasta-geldi · hazirla · dogrula · teslim · iptal"));

            if (adim == "iptal" && string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("İptal nedeni zorunlu.",
                    new AlanHatasi("gerekce", "İptal nedeni zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            var h = await baglanti.TekAsync("""
                select p.durum, p.tur, p.hazirlayan_id as "hazirlayanId",
                       p.dogrulayan_id as "dogrulayanId",
                       p.hasta_geldi_zamani as "hastaGeldi",
                       p.hazirlama_zamani as "hazirlamaZamani",
                       p.dogrulama_zamani as "dogrulamaZamani",
                       (select count(*) from public.eczane_hazirlama_kalem m
                         where m.hazirlama_id = p.id) as "kalemSayisi",
                       (select count(*) from public.eczane_hazirlama_kalem m
                         where m.hazirlama_id = p.id
                           and coalesce(m.uygulanan_doz, 0) <= 0) as "dozsuzKalem",
                       (select count(*) from public.eczane_hazirlama_kalem m
                         where m.hazirlama_id = p.id
                           and coalesce(m.kumulatif_sinir, 0) > 0
                           and coalesce(m.kumulatif, 0) > m.kumulatif_sinir) as "sinirAsan"
                  from public.eczane_hazirlama p where p.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Hazırlama kaydı bulunamadı.");

            var durum = Convert.ToInt16(h["durum"] ?? (short)0);
            if (durum == 8)
                throw GentegreHatasi.IsKurali("İptal edilmiş hazırlamada akış ilerletilemez.");

            var kisi = istek.PersonelId ?? baglam.KullaniciId;
            var uyarilar = new List<string>();

            if (adim == "hazirla")
            {
                if (Convert.ToInt32(h["kalemSayisi"] ?? 0) == 0)
                    throw GentegreHatasi.IsKurali("Kalemi olmayan hazırlama başlatılamaz.");
                if (Convert.ToInt32(h["dozsuzKalem"] ?? 0) > 0)
                    throw GentegreHatasi.IsKurali(
                        "Uygulanacak dozu girilmemiş kalem var - hazırlama başlatılamaz.");

                if (h["hastaGeldi"] is null)
                {
                    if (!istek.Zorla)
                        throw GentegreHatasi.IsKurali(
                            "Hasta gelmeden hazırlama başlatılamaz (hazırlanıp iptal edilen "
                            + "kemoterapi imha edilir).");
                    if (string.IsNullOrWhiteSpace(istek.Gerekce))
                        throw GentegreHatasi.Dogrulama("Hasta gelmeden hazırlanıyorsa gerekçe zorunlu.",
                            new AlanHatasi("gerekce", "Gerekçe zorunlu."));
                    uyarilar.Add("Hasta gelmeden hazırlama başlatıldı.");
                }

                // KÜMÜLATİF SINIR UYARIDIR, ENGEL DEĞİL: aşan dozu hekim
                //   bilerek verebilir (antrasiklin kardiyotoksisitesi kabul
                //   edilerek). Engelleseydik karar eczanede alınmış olurdu.
                if (Convert.ToInt32(h["sinirAsan"] ?? 0) > 0)
                    uyarilar.Add("Kümülatif sınırı aşan kalem var - hekim onayı alınmalı.");
            }

            if (adim == "dogrula" && h["hazirlamaZamani"] is null)
                throw GentegreHatasi.IsKurali("Hazırlanmamış karışım doğrulanamaz.");

            // İKİNCİ ECZACI. Kemoterapide yanlış doz geri alınamaz; bu yüzden
            //   doğrulayan, hazırlayandan BAŞKASI olmalı.
            if (adim == "dogrula" && h["hazirlayanId"] is { } hz && Convert.ToInt32(hz) == kisi)
            {
                if (!istek.Zorla)
                    throw GentegreHatasi.IsKurali(
                        "Karışımı hazırlayan kişi kendi hazırladığını doğrulayamaz.");
                if (string.IsNullOrWhiteSpace(istek.Gerekce))
                    throw GentegreHatasi.Dogrulama("Çift kontrol geçiliyorsa gerekçe zorunlu.",
                        new AlanHatasi("gerekce", "Gerekçe zorunlu."));
                uyarilar.Add("İkinci eczacı kuralı geçildi.");
            }

            if (adim == "teslim" && h["dogrulamaZamani"] is null)
                throw GentegreHatasi.IsKurali("Doğrulanmamış karışım teslim edilemez.");

            var zaman = istek.Zaman ?? DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var sql = adim switch
            {
                "hasta-geldi" => """
                    update public.eczane_hazirlama
                       set hasta_geldi_zamani = @p2, durum = greatest(durum, 2),
                           degistiren = @p1, degistirme_tarihi = (now())::timestamp
                     where id = @p0 returning durum
                    """,
                "hazirla" => """
                    update public.eczane_hazirlama
                       set hazirlayan_id = @p1, hazirlama_zamani = @p2,
                           kabin_kod = coalesce(nullif(@p3, ''), kabin_kod),
                           durum = greatest(durum, 3),
                           degistiren = @p1, degistirme_tarihi = (now())::timestamp
                     where id = @p0 returning durum
                    """,
                "dogrula" => """
                    update public.eczane_hazirlama
                       set dogrulayan_id = @p1, dogrulama_zamani = @p2,
                           son_kullanim = coalesce(@p4, son_kullanim),
                           saklama = coalesce(nullif(@p5, ''), saklama),
                           durum = greatest(durum, 4),
                           degistiren = @p1, degistirme_tarihi = (now())::timestamp
                     where id = @p0 returning durum
                    """,
                "teslim" => """
                    update public.eczane_hazirlama
                       set teslim_zamani = @p2,
                           teslim_alan_id = coalesce(@p6, teslim_alan_id),
                           durum = greatest(durum, 5),
                           degistiren = @p1, degistirme_tarihi = (now())::timestamp
                     where id = @p0 returning durum
                    """,
                _ => """
                    update public.eczane_hazirlama
                       set durum = 8, iptal_neden = @p7,
                           degistiren = @p1, degistirme_tarihi = (now())::timestamp
                     where id = @p0 returning durum
                    """
            };

            var sonDurum = await baglanti.TekDegerAsync<int>(sql, islem,
                [id, kisi, zaman, istek.KabinKod ?? "", istek.SonKullanim,
                 istek.Saklama ?? "", istek.TeslimAlanId, istek.Gerekce ?? ""], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogHazirlama, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { adim, zaman, personel = kisi, uyarilar, gerekce = istek.Gerekce },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { adim, zaman, durum = sonDurum, uyarilar, izlemeNo = baglam.IzlemeNo });
        });

        // DOZ HESABI (mockup "🧮 Doz Hesapla").
        //
        // NE HESAPLANIR: VYA (Mosteller: √(boy×kilo/3600)) ve protokol dozundan
        //   kalem başına HESAPLANAN doz. Üç biçim tanınır - "mg/m²" (VYA ile),
        //   "mg/kg" (kilo ile), "AUC n" (Calvert: doz = AUC × (KrKl + 25)).
        //   Tanınmayan biçim ATLANIR, uydurulmaz: yanlış bir doz önerisi hiç
        //   öneri olmamasından kötüdür.
        //
        // YAZILAN KOLON `hesaplanan`. Uygulanacak doz eczacının kararıdır
        //   (flakon yuvarlaması, doz azaltma) ve ayrı kolonda durur; ikisini
        //   tek kolona yazsaydık "bu doz nasıl çıktı" sorusu yanıtsız kalırdı.
        grup.MapPost("/hazirlama/{id:long}/doz-hesapla", async (
            long id, DozHesapIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.hazirlama", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var h = await baglanti.TekAsync("""
                select p.durum, p.boy_cm as "boyCm", p.kilo_kg as "kiloKg",
                       p.vya_m2 as "vyaM2", p.krkl
                  from public.eczane_hazirlama p where p.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Hazırlama kaydı bulunamadı.");

            // HAZIRLANMIŞ KARIŞIMIN DOZU YENİDEN HESAPLANMAZ: hesap girdisi
            //   değişince kayıt ile şişedeki sıvı ayrışır.
            if (Convert.ToInt16(h["durum"] ?? (short)0) >= 3)
                throw GentegreHatasi.IsKurali(
                    "Hazırlanmış karışımın dozu yeniden hesaplanamaz.");

            var boy = istek.BoyCm ?? (h["boyCm"] is { } b ? Convert.ToDecimal(b) : 0m);
            var kilo = istek.KiloKg ?? (h["kiloKg"] is { } g ? Convert.ToDecimal(g) : 0m);
            var krkl = istek.Krkl ?? (h["krkl"] is { } c ? Convert.ToDecimal(c) : 0m);

            if (boy <= 0 || kilo <= 0)
                throw GentegreHatasi.Dogrulama("Boy ve kilo zorunlu.",
                    new AlanHatasi("kiloKg", "VYA hesabı için boy ve kilo gerekli."));

            // MOSTELLER: en yaygın kullanılan formül, tek satır ve kaynağı açık.
            var vya = Math.Round((decimal)Math.Sqrt((double)(boy * kilo) / 3600d), 2);
            var azalt = Math.Clamp(istek.AzaltmaYuzde ?? 0m, 0m, 100m);
            var carpan = (100m - azalt) / 100m;

            var kalemler = await baglanti.ListeAsync("""
                select m.id, m.ad, m.protokol_doz as "protokolDoz", m.birim
                  from public.eczane_hazirlama_kalem m
                 where m.hazirlama_id = @p0 order by m.sira, m.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.eczane_hazirlama
                   set boy_cm = @p1, kilo_kg = @p2, vya_m2 = @p3,
                       krkl = case when @p4 > 0 then @p4 else krkl end,
                       degistiren = @p5, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, boy, kilo, vya, krkl, baglam.KullaniciId], iptal);

            var sonuc = new List<object>();
            foreach (var m in kalemler)
            {
                var kalemId = Convert.ToInt64(m["id"]);
                var metin = (m["protokolDoz"] as string ?? "").Trim();
                var (deger, yontem) = ProtokolDozCoz(metin, vya, kilo, krkl);

                if (deger is null)
                {
                    sonuc.Add(new { id = kalemId, ad = m["ad"], protokolDoz = metin,
                                    hesaplanan = (decimal?)null,
                                    not = "Protokol dozu çözülemedi - elle girilmeli." });
                    continue;
                }

                var hesap = Math.Round(deger.Value * carpan, 2);
                await baglanti.CalistirAsync("""
                    update public.eczane_hazirlama_kalem
                       set hesaplanan = @p1, degistiren = @p2,
                           degistirme_tarihi = (now())::timestamp
                     where id = @p0 and hazirlama_id = @p3
                    """, islem, [kalemId, hesap, baglam.KullaniciId, id], iptal);

                sonuc.Add(new { id = kalemId, ad = m["ad"], protokolDoz = metin,
                                hesaplanan = hesap, yontem, birim = m["birim"] });
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogHazirlama, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { boy, kilo, vya, krkl, azaltmaYuzde = azalt }, iptal: iptal);

            await islem.CommitAsync(iptal);

            return Results.Ok(new
            {
                vyaM2 = vya, boyCm = boy, kiloKg = kilo, krkl,
                azaltmaYuzde = azalt, kalemler = sonuc,
                not = "Hesaplanan doz ÖNERİDİR; uygulanacak dozu eczacı girer.",
                izlemeNo = baglam.IzlemeNo
            });
        });
    }

    /// <summary>
    /// "75 mg/m2" · "2 mg/kg" · "AUC 5" biçimlerini çözer. Tanınmayan biçimde
    /// null döner - uydurulmuş bir doz, hiç doz önerilmemesinden kötüdür.
    /// </summary>
    private static (decimal? Deger, string? Yontem) ProtokolDozCoz(
        string metin, decimal vya, decimal kilo, decimal krkl)
    {
        if (string.IsNullOrWhiteSpace(metin)) return (null, null);
        var d = metin.Replace(',', '.').ToLowerInvariant();

        // CALVERT (karboplatin): doz = AUC × (KrKl + 25). KrKl yoksa hesap yok.
        if (d.Contains("auc"))
        {
            var sayi = SayiAl(d.Replace("auc", " "));
            if (sayi is null || krkl <= 0) return (null, null);
            return (Math.Round(sayi.Value * (krkl + 25m), 2), "Calvert (AUC)");
        }

        var m2 = d.Contains("/m2") || d.Contains("/m²");
        var kg = d.Contains("/kg");
        if (!m2 && !kg) return (null, null);

        var taban = SayiAl(d);
        if (taban is null) return (null, null);
        return m2
            ? (Math.Round(taban.Value * vya, 2), "mg/m² × VYA")
            : (Math.Round(taban.Value * kilo, 2), "mg/kg × kilo");
    }

    private static decimal? SayiAl(string metin)
    {
        var e = System.Text.RegularExpressions.Regex.Match(metin, @"\d+(\.\d+)?");
        return e.Success && decimal.TryParse(e.Value,
                   System.Globalization.NumberStyles.Any,
                   System.Globalization.CultureInfo.InvariantCulture, out var s)
            ? s : null;
    }
}
