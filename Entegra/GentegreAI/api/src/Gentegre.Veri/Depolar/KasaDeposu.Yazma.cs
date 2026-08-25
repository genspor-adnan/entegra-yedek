using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Kasa isleminin YAZILMASI: baslik ekle/guncelle, bacaklar, taraf snapshot'i ve doviz alanlarinin doldurulmasi. Akis (KaydetAsync/GuncelleAsync) ana dosyada.
/// </summary>
public sealed partial class KasaDeposu
{
    private static readonly Dictionary<string, string> Kolonlar = new(StringComparer.Ordinal)
    {
        ["tur"] = "tur", ["islemNo"] = "islem_no", ["makbuzNo"] = "makbuz_no",
        ["islemTarihi"] = "islem_tarihi", ["planTarihi"] = "plan_tarihi", ["durum"] = "durum",
        ["tarafId"] = "taraf_id", ["karsiTarafId"] = "karsi_taraf_id",
        ["tarafUnvan"] = "taraf_unvan", ["hesapId"] = "hesap_id",
        ["karsiHesapId"] = "karsi_hesap_id", ["dovizCinsi"] = "doviz_cinsi",
        ["tutar"] = "tutar", ["dovizKuru"] = "doviz_kuru", ["yerelTutar"] = "yerel_tutar",
        ["karsiDovizCinsi"] = "karsi_doviz_cinsi", ["karsiTutar"] = "karsi_tutar",
        ["karsiKur"] = "karsi_kur", ["masrafTutar"] = "masraf_tutar",
        ["masrafId"] = "masraf_id", ["hizmetId"] = "hizmet_id", ["projeId"] = "proje_id",
        ["merkezId"] = "merkez_id", ["cekSenetId"] = "cek_senet_id",
        ["krediTaksitId"] = "kredi_taksit_id", ["kuponTuruId"] = "kupon_turu_id",
        ["belgeId"] = "belge_id", ["planIslemId"] = "plan_islem_id",
        ["aciklama"] = "aciklama", ["subeId"] = "sube_id", ["girisKaynak"] = "giris_kaynak"
    };

    private async Task<int> BaslikEkleAsync(NpgsqlConnection baglanti, NpgsqlTransaction tx,
        IDictionary<string, object?> islem, YazmaBaglami baglam, CancellationToken iptal)
    {
        var kolonlar = new List<string>();
        var parametreler = new List<object?>();

        foreach (var (ad, deger) in islem)
        {
            if (!Kolonlar.TryGetValue(ad, out var kolon)) continue;
            kolonlar.Add(kolon);
            parametreler.Add(deger);
        }
        kolonlar.Add("ekleyen");
        parametreler.Add(baglam.KullaniciId);

        var yer = Enumerable.Range(0, parametreler.Count).Select(i => "@p" + i);
        var sql = $"insert into public.kasa_islem ({string.Join(", ", kolonlar)}) " +
                  $"values ({string.Join(", ", yer)}) returning id";

        await using var komut = Komut(baglanti, tx, sql, parametreler);
        return Convert.ToInt32(await CalistirAsync(komut, iptal));
    }

    private async Task BaslikGuncelleAsync(NpgsqlConnection baglanti, NpgsqlTransaction tx,
        int id, IDictionary<string, object?> islem, YazmaBaglami baglam, CancellationToken iptal)
    {
        var atamalar = new List<string>();
        var parametreler = new List<object?> { id };

        foreach (var (ad, deger) in islem)
        {
            if (!Kolonlar.TryGetValue(ad, out var kolon)) continue;
            parametreler.Add(deger);
            atamalar.Add($"{kolon} = @p{parametreler.Count - 1}");
        }
        if (atamalar.Count == 0) return;

        parametreler.Add(baglam.KullaniciId);
        atamalar.Add($"degistiren = @p{parametreler.Count - 1}");

        await using var komut = Komut(baglanti, tx,
            $"update public.kasa_islem set {string.Join(", ", atamalar)} where id = @p0", parametreler);
        await CalistirAsync(komut, iptal, satirSayisi: true);
    }

    /// <summary>
    /// Serbest mod bacak yazimi. Yerel tutar ISTEMCIDEN ALINMAZ - kur x tutar
    /// burada hesaplanir (sozlesme §9: ekran ile muhasebe ayni sayiyi gormeli).
    /// </summary>

    /// <summary>
    /// Serbest mod bacak yazimi. Yerel tutar ISTEMCIDEN ALINMAZ - kur x tutar
    /// burada hesaplanir (sozlesme §9: ekran ile muhasebe ayni sayiyi gormeli).
    /// </summary>
    private async Task BacakYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction tx,
        int id, List<Dictionary<string, JsonElement>> bacaklar,
        IDictionary<string, object?> baslik, YazmaBaglami baglam, CancellationToken iptal)
    {
        var baslikDoviz = Metin(baslik, "dovizCinsi");
        if (baslikDoviz.Length == 0) baslikDoviz = KasaHesap.YerelDoviz;
        var baslikKur = Ondalik(baslik, "dovizKuru");
        if (baslikKur <= 0) baslikKur = 1m;

        var sira = 0;
        foreach (var bacak in bacaklar)
        {
            sira++;
            var alan = $"bacaklar[{sira - 1}]";

            if (bacak.ContainsKey("yerelBorc") || bacak.ContainsKey("yerelAlacak"))
                throw GentegreHatasi.Dogrulama(
                    "Yerel tutar sunucuda hesaplanır, istekte gönderilemez.",
                    new AlanHatasi(alan, "yerelBorc / yerelAlacak gönderilemez."));

            var hesapId  = JsonSayiNull(bacak, "hesapId");
            var tarafId  = JsonSayiNull(bacak, "tarafId");
            var masrafId = JsonSayiNull(bacak, "masrafId");
            var hizmetId = JsonSayiNull(bacak, "hizmetId");

            var bagAdedi = (hesapId is not null ? 1 : 0) + (tarafId is not null ? 1 : 0) +
                           (masrafId is not null ? 1 : 0) + (hizmetId is not null ? 1 : 0);
            if (bagAdedi != 1)
                throw GentegreHatasi.Dogrulama($"{sira}. bacakta tam bir bağ olmalı.",
                    new AlanHatasi(alan, "hesapId / tarafId / masrafId / hizmetId - yalnız biri."));

            var yon = JsonMetin(bacak, "yon").ToLowerInvariant();
            if (yon is not ("borc" or "alacak"))
                throw GentegreHatasi.Dogrulama($"{sira}. bacağın yönü geçersiz.",
                    new AlanHatasi($"{alan}.yon", "'borc' veya 'alacak' olmalı."));

            var tutar = JsonOndalik(bacak, "tutar", 0);
            if (tutar <= 0)
                throw GentegreHatasi.Dogrulama($"{sira}. bacağın tutarı sıfırdan büyük olmalı.",
                    new AlanHatasi($"{alan}.tutar", "Sıfırdan büyük olmalı."));

            var doviz = JsonMetin(bacak, "dovizCinsi");
            if (doviz.Length == 0) doviz = baslikDoviz;
            var kur = JsonOndalik(bacak, "dovizKuru", 0);
            if (kur <= 0) kur = KasaHesap.YerelMi(doviz) ? 1m : baslikKur;
            if (KasaHesap.YerelMi(doviz)) kur = 1m;

            var yerel = KasaHesap.YerelTutar(tutar, kur);
            var borc  = yon == "borc" ? tutar : 0m;
            var alacak = yon == "alacak" ? tutar : 0m;

            var hesapTuru = JsonMetin(bacak, "hesapTuru");
            if (hesapTuru.Length == 0)
                hesapTuru = tarafId is not null ? "C"
                          : (masrafId is not null || hizmetId is not null) ? "M" : "-";

            await using var komut = new NpgsqlCommand("""
                insert into public.mali_hareket
                    (kasa_islem_id, sira, rol, tur, hesap_turu, hesap_id, taraf_id,
                     islem_tarihi, plan_tarihi, borc, alacak, yerel_borc, yerel_alacak,
                     doviz_cinsi, doviz_kuru, durum, masraf_id, hizmet_id, proje_id, merkez_id,
                     belge_id, aciklama, sube_id, giris_kaynak, ekleyen)
                select @p0, @p1, @p2, ki.tur,
                       case when @p3 is not null
                            then coalesce((select h.tur from public.hesap h where h.id = @p3), @p4)
                            else @p4 end,
                       @p3, @p5, ki.islem_tarihi::timestamp, ki.plan_tarihi,
                       @p6, @p7, @p8, @p9, @p10, @p11, ki.durum, @p12, @p13,
                       coalesce(@p14, ki.proje_id), ki.merkez_id, ki.belge_id,
                       @p15, ki.sube_id, coalesce(ki.giris_kaynak, 1), @p16
                  from public.kasa_islem ki where ki.id = @p0
                """, baglanti, tx);

            komut.Parameters.AddWithValue("p0", id);
            komut.Parameters.AddWithValue("p1", (short)sira);
            komut.Parameters.AddWithValue("p2", JsonMetin(bacak, "rol"));
            komut.Parameters.AddWithValue("p3", (object?)hesapId ?? DBNull.Value);
            komut.Parameters.AddWithValue("p4", hesapTuru);
            komut.Parameters.AddWithValue("p5", (object?)tarafId ?? DBNull.Value);
            komut.Parameters.AddWithValue("p6", borc);
            komut.Parameters.AddWithValue("p7", alacak);
            komut.Parameters.AddWithValue("p8", yon == "borc" ? yerel : 0m);
            komut.Parameters.AddWithValue("p9", yon == "alacak" ? yerel : 0m);
            komut.Parameters.AddWithValue("p10", doviz);
            komut.Parameters.AddWithValue("p11", kur);
            komut.Parameters.AddWithValue("p12", (object?)masrafId ?? DBNull.Value);
            komut.Parameters.AddWithValue("p13", (object?)hizmetId ?? DBNull.Value);
            komut.Parameters.AddWithValue("p14", (object?)JsonSayiNull(bacak, "projeId") ?? DBNull.Value);
            komut.Parameters.AddWithValue("p15", Kirp(JsonMetin(bacak, "aciklama"), 100));
            komut.Parameters.AddWithValue("p16", baglam.KullaniciId);

            await CalistirAsync(komut, iptal, satirSayisi: true);
        }
    }

    /// <summary>Cari unvanini DONDUR: kart sonradan degisse de makbuz degismez.</summary>

    /// <summary>Cari unvanini DONDUR: kart sonradan degisse de makbuz degismez.</summary>
    private async Task TarafSnapshotAsync(NpgsqlConnection baglanti, NpgsqlTransaction tx,
        IDictionary<string, object?> islem, CancellationToken iptal)
    {
        var tarafId = SayiNull(islem, "tarafId");
        if (tarafId is null or <= 0) return;
        if (Metin(islem, "tarafUnvan").Length > 0) return;

        await using var komut = new NpgsqlCommand(
            "select coalesce(nullif(fatura_unvan, ''), unvan) as unvan from public.taraf where id = @p0",
            baglanti, tx);
        komut.Parameters.AddWithValue("p0", tarafId.Value);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.Dogrulama("Cari kayıt bulunamadı.", new AlanHatasi("tarafId", "Geçersiz."));
        islem["tarafUnvan"] = Kirp(o.Metin("unvan"), 200);
    }

    /// <summary>
    /// Doviz/kur/yerel tutar doldurma. Kur once istekten, yoksa hesabin
    /// dovizine gore kur tablosundan (tahsilat SATIS, odeme ALIS kuru) alinir.
    /// </summary>

    /// <summary>
    /// Doviz/kur/yerel tutar doldurma. Kur once istekten, yoksa hesabin
    /// dovizine gore kur tablosundan (tahsilat SATIS, odeme ALIS kuru) alinir.
    /// </summary>
    private async Task DovizDoldurAsync(NpgsqlConnection baglanti, NpgsqlTransaction tx,
        IDictionary<string, object?> islem, KasaSecenekleri secenekler,
        List<string> uyarilar, CancellationToken iptal)
    {
        var doviz = Metin(islem, "dovizCinsi");

        // Doviz belirtilmediyse ana hesabin para birimi esastir.
        var hesapId = SayiNull(islem, "hesapId");
        if (doviz.Length == 0 && hesapId is > 0)
        {
            await using var komut = new NpgsqlCommand(
                "select doviz_cinsi from public.hesap where id = @p0", baglanti, tx);
            komut.Parameters.AddWithValue("p0", hesapId.Value);
            doviz = (await komut.ExecuteScalarAsync(iptal))?.ToString() ?? "";
        }
        if (doviz.Length == 0) doviz = KasaHesap.YerelDoviz;
        islem["dovizCinsi"] = doviz;

        var kur = Ondalik(islem, "dovizKuru");
        if (KasaHesap.YerelMi(doviz))
        {
            kur = 1m;
        }
        else if (kur <= 0)
        {
            var tarih = Tarih(islem, "islemTarihi") ?? DateTime.Today;
            var yon = (short)(Sayi(islem, "tur") is 21 or 22 or 23 or 24 or 25 or 26 or 87 ? 1 : 2);

            await using var komut = new NpgsqlCommand(
                "select public.fn_doviz_kur_getir(@p0, @p1::date, @p2::smallint)", baglanti, tx);
            komut.Parameters.AddWithValue("p0", doviz);
            komut.Parameters.AddWithValue("p1", tarih.Date);
            komut.Parameters.AddWithValue("p2", yon);
            var sonuc = await komut.ExecuteScalarAsync(iptal);

            if (sonuc is null or DBNull)
            {
                if (secenekler.KurKontrolu)
                    throw GentegreHatasi.IsKurali(
                        $"{doviz} için {tarih:dd.MM.yyyy} tarihine kur bulunamadı. Kuru elle girin.");
                kur = 1m;
                uyarilar.Add($"{doviz} kuru bulunamadı, 1 kabul edildi.");
            }
            else kur = Convert.ToDecimal(sonuc);
        }
        islem["dovizKuru"] = kur;

        var tutar = Ondalik(islem, "tutar");
        islem["yerelTutar"] = KasaHesap.YerelTutar(tutar, kur);

        // Karsi taraf (doviz donusumu) - kur verilmediyse capraz kurdan turetilir.
        var karsiTutar = Ondalik(islem, "karsiTutar");
        if (karsiTutar > 0 && Ondalik(islem, "karsiKur") <= 0)
            islem["karsiKur"] = KasaHesap.CaprazKur(KasaHesap.YerelTutar(tutar, kur), karsiTutar);
    }
}
