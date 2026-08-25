using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Kasa (mali) islem kaydetme - API §9. HEPSI YA DA HICBIRI: baslik, bacaklar,
/// muhasebe fisi, yan etkiler ve islem_log TEK TRANSACTION icinde yazilir.
///
/// IS KURALLARI BURADA DEGIL, MOTORDA (076_fn_kasa.sql): bacak uretimi, denge,
/// fisleme ve iptal veritabani fonksiyonlaridir. Bu sinif sadece istegi
/// dogrular, kur/snapshot doldurur ve motoru cagirir. Kurali iki yerde
/// tutmak, iki farkli sonuc demektir.
///
/// MAKBUZ NUMARASI EN SON: fn_kasa_islem_kesinlestir once dogrular ve fisler,
/// numarayi en sonda satir kilidi altinda uretir - rollback numarayi harcamaz.
/// </summary>
public sealed partial class KasaDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;

    /// <summary>islem_log tablo kodu (078 seed): 908 = kasa_islem.</summary>
    private const int LogTabloKasa = 908;

    /// <summary>Motorun is-kurali hatalari bu SQLSTATE ile gelir (076).</summary>
    private const string IsKuraliKodu = "GK422";

    public KasaDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    // ================================================================ yazma ====
    public async Task<(int Id, List<string> Uyarilar)> KaydetAsync(
        IDictionary<string, object?> islem,
        List<Dictionary<string, JsonElement>>? bacaklar,
        KasaSecenekleri secenekler,
        YazmaBaglami baglam,
        CancellationToken iptal = default,
        CekSenetGirisi? cekSenet = null)
    {
        var uyarilar = new List<string>();

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        var tur = (int)Sayi(islem, "tur");
        if (tur <= 0)
            throw GentegreHatasi.Dogrulama("İşlem türü seçilmeli.", new AlanHatasi("tur", "Zorunlu."));

        var katalog = await TurOkuAsync(baglanti, tx, tur, iptal)
            ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen işlem türü: {tur}",
                   new AlanHatasi("tur", "Katalogda yok."));

        // Kasa islemi bir SUBEYE baglanir (kasa/banka hesabi da subelidir).
        //   Sube yoksa `sube_id` 0 yazilip veritabaninda FK ihlaliyle
        //   patliyordu - kullanici "Beklenmeyen bir hata" goruyordu. Artik ne
        //   yapilmasi gerektigini soyleyen dogrulama hatasi doner.
        islem["subeId"] = baglam.SubeZorunlu();

        IleriTarihKontrol(islem);

        await TarafSnapshotAsync(baglanti, tx, islem, iptal);
        await DovizDoldurAsync(baglanti, tx, islem, secenekler, uyarilar, iptal);

        // Durum: plan > taslak > (gerceklesecek). Gerceklesme kesinlestirmede olur.
        islem["durum"] = secenekler.Plan ? KasaDurum.Planli : KasaDurum.Taslak;
        islem["islemNo"] = "";
        if (secenekler.BelgeId is { } bId) islem["belgeId"] = bId;

        // CEK/SENET: kiymet basliktan ONCE acilir - motor bacagi uretirken
        //   cek_senet_id'yi hazir bulmali (yoksa 422 "kiymet secilmeli").
        //   Plan/taslak dahil her durumda acilir: plan da belirli bir cekin
        //   vadesidir. Kiymetsiz gelen cek/senet turu erken ve okunur biter.
        var cekSenetId = 0;
        if (KasaHesap.CekSenetTuru(tur))
        {
            // MEVCUT kiymete baglanma: kullanici cek/senet KARTINI doldurmus ve
            //   kaydetmis olabilir (kasa listesindeki "Çek" secimi o karti acar).
            //   O zaman burada yeni kayit ACILMAZ, gelen kimlik kullanilir -
            //   yoksa ayni cek iki kez portfoye girerdi.
            var mevcut = (int)Sayi(islem, "cekSenetId");
            if (mevcut > 0)
            {
                cekSenetId = mevcut;
            }
            else
            {
                if (cekSenet is null)
                    throw GentegreHatasi.Dogrulama(
                        "Çek/senet bilgileri girilmeli (vade zorunlu).",
                        new AlanHatasi("cekSenet", "Zorunlu."));
                cekSenetId = await CekSenetEkleAsync(baglanti, tx, tur, cekSenet, islem, baglam, iptal);
                islem["cekSenetId"] = cekSenetId;
            }
        }

        var id = await BaslikEkleAsync(baglanti, tx, islem, baglam, iptal);

        if (cekSenetId > 0)
            await CekSenetBaglaAsync(baglanti, tx, cekSenetId, id, islem, baglam, iptal);

        // Bacaklar: istemci vermediyse sablondan uretilir (normal akis).
        if (bacaklar is { Count: > 0 })
            await BacakYazAsync(baglanti, tx, id, bacaklar, islem, baglam, iptal);
        else
            await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_bacak_uret(@p0)",
                             new object?[] { id }, iptal);

        if (!secenekler.Taslak && !secenekler.Plan)
            await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_kesinlestir(@p0, @p1)",
                             new object?[] { id, baglam.KullaniciId }, iptal);

        await _log.YazAsync(baglanti, tx, LogIslemi.Ekle, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["tur"] = tur.ToString(CultureInfo.InvariantCulture),
                ["turAdi"] = katalog.Ad,
                ["tutar"] = Ondalik(islem, "tutar").ToString(CultureInfo.InvariantCulture),
                ["dovizCinsi"] = Metin(islem, "dovizCinsi"),
                ["durum"] = (secenekler.Taslak || secenekler.Plan ? "taslak" : "gerceklesti")
            },
            tarafId: SayiNull(islem, "tarafId"), iptal: iptal);

        await tx.CommitAsync(iptal);
        return (id, uyarilar);
    }

    /// <summary>
    /// ILERI TARIH YASAGI (146): para henuz el degistirmeden tahsilat yazilamaz.
    /// Saat de denetlenir - `islem_tarihi` artik timestamp. Kuruluşun saat
    /// dilimi esas alinir (Saat.Simdi); sunucunun UTC saati degil, yoksa
    /// Turkiye'de ogleden sonra girilen tahsilat "ileri tarihli" sayilirdi.
    ///
    /// PLAN tarihi bunun DISINDA: plan zaten gelecege yazilir.
    /// </summary>
    private static void IleriTarihKontrol(IDictionary<string, object?> islem)
    {
        if (islem.TryGetValue("islemTarihi", out var ham) && ham is DateTime t)
        {
            // Dakika toleransi: istemcinin saati birkac saniye ileri olabilir.
            if (t > Saat.Simdi.AddMinutes(1))
                throw GentegreHatasi.Dogrulama(
                    "İleri tarihli işlem kaydedilemez.",
                    new AlanHatasi("islemTarihi", "Bugünden ileri olamaz."));
        }
    }

    /// <summary>
    /// DUZELTME SINIRI (149): gerceklesmis islem `kasa.duzenleme_gun` gun sonra
    /// KILITLENIR - gecmis ay kasasi geriye donuk oynanmasin.
    ///
    ///     0  duzeltme kapali (eski davranis: iptal edip yeniden gir)
    ///     N  islem tarihinden N gun sonra kilit
    ///    -1  sinirsiz (yalniz donem kilidi ve iptal engeli)
    ///
    /// Ayar Yönetim > Ayarlar > Kasa Ayarlari ekranindan degistirilir.
    /// </summary>
    private static async Task DuzeltmeSiniriKontrolAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction tx, int id, CancellationToken iptal)
    {
        var gun = await AyarDeposu.SayiAsync(baglanti, tx, "kasa.duzenleme_gun", iptal);
        if (gun < 0) return;                                   // sinirsiz
        if (gun == 0)
            throw GentegreHatasi.IsKurali(
                "Gerçekleşmiş işlem düzeltme kapalı (Ayarlar > Kasa > düzeltme gün sayısı) - "
              + "İptal edip yeniden girin.");

        await using var komut = new NpgsqlCommand(
            "select islem_tarihi from public.kasa_islem where id = @p0", baglanti, tx);
        komut.Parameters.AddWithValue("p0", id);
        if (await komut.ExecuteScalarAsync(iptal) is not DateTime tarih) return;

        if (Saat.Bugun > tarih.Date.AddDays(gun))
            throw GentegreHatasi.IsKurali(
                $"İşlem tarihinden {gun} gün geçti; kayıt kilitlendi - İptal edip yeniden girin.");
    }

    /// <summary>Taslak/plan duzenleme. Gerceklesmis islem degistirilemez - iptal edilir.</summary>
    public async Task<List<string>> GuncelleAsync(
        int id, IDictionary<string, object?> islem,
        List<Dictionary<string, JsonElement>>? bacaklar,
        KasaSecenekleri secenekler, string? surum,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        var uyarilar = new List<string>();

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        int durum;
        string mevcutSurum;
        await using (var komut = new NpgsqlCommand(
            "select durum, xmin::text as surum from public.kasa_islem where id = @p0 for update",
            baglanti, tx))
        {
            komut.Parameters.AddWithValue("p0", id);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
            durum = o.Sayi("durum");
            mevcutSurum = o.Metin("surum");
        }

        if (!string.IsNullOrEmpty(surum) && surum != mevcutSurum)
            throw GentegreHatasi.Cakisma(new { id, surum = mevcutSurum });

        if (durum == KasaDurum.Iptal)
            throw GentegreHatasi.IsKurali(
                "İptal edilmiş işlem değiştirilemez - yeni işlem girin.");

        // GERCEKLESMIS ISLEM DUZELTILEBILIR (148) - belge tarafindaki kararla
        //   (135) ayni: kullanici bir tahsilatin tutarini duzeltmek icin islemi
        //   iptal edip bastan girmek zorunda kalmasin. Sunucu eski etkiyi geri
        //   alir: bacaklar ve fis SATIRLARI silinir, durum taslaga cekilir;
        //   asagidaki normal akis yeniden uretir. Fis NUMARASI korunur -
        //   yevmiye sirasi bozulmasin. Kapanmis donem motorda reddedilir.
        if (durum >= KasaDurum.Gerceklesti)
        {
            await DuzeltmeSiniriKontrolAsync(baglanti, tx, id, iptal);
            await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_duzelt_hazirla(@p0)",
                             new object?[] { id }, iptal);
            uyarilar.Add("Gerçekleşmiş işlem düzeltildi: muhasebe fişi yeniden yazıldı.");
        }

        await TarafSnapshotAsync(baglanti, tx, islem, iptal);
        await DovizDoldurAsync(baglanti, tx, islem, secenekler, uyarilar, iptal);
        islem.Remove("durum");
        islem.Remove("islemNo");

        IleriTarihKontrol(islem);

        await BaslikGuncelleAsync(baglanti, tx, id, islem, baglam, iptal);

        if (bacaklar is { Count: > 0 })
        {
            await using var sil = new NpgsqlCommand(
                "delete from public.mali_hareket where kasa_islem_id = @p0", baglanti, tx);
            sil.Parameters.AddWithValue("p0", id);
            await sil.ExecuteNonQueryAsync(iptal);

            var tam = await BaslikSozlukAsync(baglanti, tx, id, iptal);
            await BacakYazAsync(baglanti, tx, id, bacaklar, tam, baglam, iptal);
        }
        else
        {
            await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_bacak_uret(@p0)",
                             new object?[] { id }, iptal);
        }

        if (!secenekler.Taslak && !secenekler.Plan)
            await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_kesinlestir(@p0, @p1)",
                             new object?[] { id, baglam.KullaniciId }, iptal);

        await _log.YazAsync(baglanti, tx, LogIslemi.Degistir, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["alanSayisi"] = islem.Count.ToString(CultureInfo.InvariantCulture) },
            tarafId: SayiNull(islem, "tarafId"), iptal: iptal);

        await tx.CommitAsync(iptal);
        return uyarilar;
    }

    public async Task KesinlestirAsync(int id, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        await MotorAsync(baglanti, tx, "select public.fn_kasa_islem_kesinlestir(@p0, @p1)",
                         new object?[] { id, baglam.KullaniciId }, iptal);

        await _log.YazAsync(baglanti, tx, LogIslemi.Degistir, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["aksiyon"] = "kesinlestir" }, iptal: iptal);

        await tx.CommitAsync(iptal);
    }

    /// <summary>Iptal = ters baslik + ters fis. Kayit SILINMEZ (izlenebilirlik).</summary>
    public async Task<int> IptalAsync(int id, string sebep, DateTime? tarih,
                                      YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        int yeniId;
        await using (var komut = new NpgsqlCommand(
            "select public.fn_kasa_islem_iptal(@p0, @p1, @p2, @p3)", baglanti, tx))
        {
            komut.Parameters.AddWithValue("p0", id);
            komut.Parameters.AddWithValue("p1", baglam.KullaniciId);
            komut.Parameters.AddWithValue("p2", (object?)tarih?.Date ?? DBNull.Value);
            komut.Parameters.AddWithValue("p3", sebep ?? "");
            yeniId = Convert.ToInt32(await CalistirAsync(komut, iptal));
        }

        await _log.YazAsync(baglanti, tx, LogIslemi.Degistir, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "iptal",
                ["sebep"] = sebep ?? "",
                ["tersIslemId"] = yeniId.ToString(CultureInfo.InvariantCulture)
            }, iptal: iptal);

        await tx.CommitAsync(iptal);
        return yeniId;
    }

    /// <summary>
    /// Plan gerceklesmesi (K10): plan DEGISMEZ, yeni bir islem basligi acilir ve
    /// plandan yalniz `gerceklesen_tutar` birikir. Kismi gerceklesme dogaldir.
    /// </summary>
    public async Task<int> PlanGerceklestirAsync(int planId, int hesapId, decimal? tutar,
        DateTime? tarih, int? tur, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        int yeniId;
        await using (var komut = new NpgsqlCommand(
            "select public.fn_plan_gerceklestir(@p0, @p1, @p2, @p3::date, @p4, @p5)", baglanti, tx))
        {
            komut.Parameters.AddWithValue("p0", planId);
            komut.Parameters.AddWithValue("p1", hesapId);
            komut.Parameters.AddWithValue("p2", (object?)tutar ?? DBNull.Value);
            komut.Parameters.AddWithValue("p3", (object?)tarih?.Date ?? DBNull.Value);
            komut.Parameters.AddWithValue("p4", (object?)tur ?? DBNull.Value);
            komut.Parameters.AddWithValue("p5", baglam.KullaniciId);
            yeniId = Convert.ToInt32(await CalistirAsync(komut, iptal));
        }

        await _log.YazAsync(baglanti, tx, LogIslemi.Ekle, LogTabloKasa, yeniId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "plan-gerceklestir",
                ["planId"] = planId.ToString(CultureInfo.InvariantCulture),
                ["tutar"] = (tutar ?? 0).ToString(CultureInfo.InvariantCulture)
            }, iptal: iptal);

        await tx.CommitAsync(iptal);
        return yeniId;
    }

    public async Task SilAsync(int id, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        // Gerceklesmis/fislenmis kayit DB trigger'i ile korunur (076) - burada
        //   tekrar kontrol etmiyoruz; tek kural kaynagi motor.
        await _log.YazAsync(baglanti, tx, LogIslemi.Sil, LogTabloKasa, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["aksiyon"] = "sil" }, iptal: iptal);

        await using (var komut = new NpgsqlCommand(
            "delete from public.kasa_islem where id = @p0", baglanti, tx))
        {
            komut.Parameters.AddWithValue("p0", id);
            if (Convert.ToInt32(await CalistirAsync(komut, iptal, satirSayisi: true)) == 0)
                throw GentegreHatasi.Bulunamadi();
        }

        await tx.CommitAsync(iptal);
    }

    private static string JsonMetin(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var v) && v.ValueKind == JsonValueKind.String ? v.GetString() ?? "" : "";

    private static decimal JsonOndalik(Dictionary<string, JsonElement> d, string ad, decimal varsayilan)
        => d.TryGetValue(ad, out var v) && v.ValueKind == JsonValueKind.Number ? v.GetDecimal() : varsayilan;

    private static int? JsonSayiNull(Dictionary<string, JsonElement> d, string ad)
        => d.TryGetValue(ad, out var v) && v.ValueKind == JsonValueKind.Number ? v.GetInt32() : null;
}
