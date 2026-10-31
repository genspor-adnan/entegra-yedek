using System.Net;
using System.Net.Http.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K36 (çok adımlı yazmalar transaction'sız). Üç akış, üçü de
/// ikinci / sonraki adımda düşürülür ve ilk adımın yazdığı satırın KALMADIĞI doğrulanır:
///
///   * ICD dosya yüklemesi: ilk satır geçerli, ikinci satırın cinsiyeti sayı değil → ikinci INSERT
///     düşer; eskiden ilk kod katalogda kalıyordu (yarı dolu katalog + "hiç yüklenmedi" diyen izleme).
///   * İSG Ek-2 muayene açma: muayene satırı yazılır, ardından form isteği telefonu olmayan çalışan
///     için 422 verir; eskiden muayene satırı formsuz, yetim kalıyordu (ikinci açma "mevcut" diyordu).
///   * Gebelik sonucu: fn_gebelik_sonucla sonucu yazıp dosyayı kapatır, ikinci adımdaki ayrıntı
///     güncellemesi CHECK'e takılır (canlı bebek &lt; 0); eskiden dosya kapanmış, sonuç yarım kalıyordu.
///
/// Fikstürler kendi satırlarını açar ve siler; Merkez şube (1) kullanılır.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K36TransactionTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    /// <summary>KatalogUclari.LogKatalog / IsgUclari.LogMuayene / GebeIzlemUclari.LogGebelik, LogSonuc.</summary>
    private const int LogKatalog = 1795, LogMuayene = 1299, LogGebelik = 1790, LogSonuc = 1792;

    /// <summary>Son açılan istemcinin kullanıcısı (log satırları bu kimlikle sorgulanır).</summary>
    private int _kullanici;

    private async Task<HttpClient> IstemciAsync(TestDunyasi d, params string[] yetkiler)
    {
        var rol = await d.RolAsync("k36", yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        d.Temizle($"delete from public.islem_log where kullanici_id = {u}");
        _kullanici = u;
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private Task<int> LogSayisiAsync(int tabloId)
        => api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.islem_log where tablo_id = @p0 and kullanici_id = @p1", [tabloId, _kullanici]);

    private Task<int> HastaAsync(TestDunyasi d, string ek, string cepTel = "")
        => api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id, cep_tel) values (@p0, 1, @p1, @p2) returning id",
            [d.Onek + " " + ek, Merkez, cepTel]);

    // ------------------------------------------------------------ katalog ----
    [VtFact]
    public async Task Icd_yukle_bozuk_satirda_onceki_satirlar_da_geri_alinir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var k1 = (d.Onek + "1").ToUpperInvariant();
        var k2 = (d.Onek + "2").ToUpperInvariant();
        d.Temizle($"delete from public.icd where kod in ('{k1}', '{k2}')");
        using var h = await IstemciAsync(d, "katalog:d");

        // Önce geçerli tek satır: yol gerçekten çalışıyor (fikstür sorunu değil).
        var saglam = await h.PostAsJsonAsync("/api/katalog/icd-yukle",
            new { icerik = $"kod;ad;ust_kod;cinsiyet\n{k1};K36 deneme tanısı;;0", baslikVar = true });
        Assert.Equal(HttpStatusCode.OK, saglam.StatusCode);
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.icd where kod = @p0", [k1]));
        Assert.Equal(1, await LogSayisiAsync(LogKatalog));   // yükleme başına tek log (K33)
        await api.Veri.CalistirAsync("delete from public.icd where kod = @p0", [k1]);

        // Şimdi iki satır: ilki geçerli, ikincisinin cinsiyeti 'abc' -> ::smallint düşer.
        var bozuk = await h.PostAsJsonAsync("/api/katalog/icd-yukle",
            new { icerik = $"kod;ad;ust_kod;cinsiyet\n{k1};K36 deneme tanısı;;0\n{k2};K36 bozuk satır;;abc", baslikVar = true });
        Assert.False(bozuk.IsSuccessStatusCode, "bozuk satır yüklemeyi düşürmeli");

        // K36: ilk satır da yok - yükleme bütündür.
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.icd where kod in (@p0, @p1)", [k1, k2]));
        // Başarısız yüklemenin logu da yok (log aynı işlemde): sayaç ilk, sağlam yüklemenin 1'inde kalır.
        Assert.Equal(1, await LogSayisiAsync(LogKatalog));
    }

    // ---------------------------------------------------------------- İSG ----
    [VtFact]
    public async Task Isg_muayene_ac_form_istegi_dusunce_muayene_satiri_kalmaz()
    {
        await using var d = new TestDunyasi(api.Veri);
        var firmaTaraf = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, sube_id) values (@p0, @p1) returning id", [d.Onek + " İSG firma", Merkez]);
        d.Temizle($"delete from public.taraf where id = {firmaTaraf}");
        var firma = await api.Veri.TekDegerAsync<int>(
            "insert into public.isg_firma (taraf_id, sube_id, ekleyen) values (@p0, @p1, 0) returning id", [firmaTaraf, Merkez]);
        d.Temizle($"delete from public.isg_firma where id = {firma}");
        // Telefonu OLMAYAN çalışan: SMS kanalı (3) form isteğinde "iletişim bilgisi yok" ile düşer.
        var hasta = await HastaAsync(d, "İSG çalışan", cepTel: "");
        d.Temizle($"delete from public.taraf where id = {hasta}");
        var calisan = await api.Veri.TekDegerAsync<int>(
            "insert into public.isg_calisan (hasta_id, firma_id, sube_id, ekleyen) values (@p0, @p1, @p2, 0) returning id", [hasta, firma, Merkez]);
        // Temizlik LIFO değil, sıra önemli: önce bağımlılar.
        d.Temizle($"delete from public.islem_log where tablo_id = {LogMuayene} and kayit_id in (select id from public.isg_muayene where calisan_id = {calisan})");
        d.Temizle($"delete from public.bildirim where taraf_id = {hasta}");
        d.Temizle($"delete from public.form_istek where hasta_id = {hasta}");
        d.Temizle($"delete from public.isg_muayene where calisan_id = {calisan}");
        d.Temizle($"delete from public.isg_calisan where id = {calisan}");
        using var h = await IstemciAsync(d, "isg.muayene:e", "isg.calisan:g");

        var y = await h.PostAsJsonAsync($"/api/isg/calisan/{calisan}/muayene-ac", new { tur = 2, kanal = 3 });
        Assert.False(y.IsSuccessStatusCode, "telefonsuz çalışana SMS kanalı açılamamalı");

        // K36: muayene satırı da, form isteği de, kuyruk da, log da yok.
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.isg_muayene where calisan_id = @p0", [calisan]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.form_istek where hasta_id = @p0", [hasta]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.bildirim where taraf_id = @p0", [hasta]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.islem_log where tablo_id = @p0 and taraf_id = @p1", [LogMuayene, hasta]));
    }

    // ------------------------------------------------------------ gebelik ----
    [VtFact]
    public async Task Gebelik_sonuc_ayrinti_dusunce_dosya_acik_kalir_ve_sonuc_satiri_yok()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d, "gebe");
        d.Temizle($"delete from public.taraf where id = {hasta}");
        var gebelik = await api.Veri.TekDegerAsync<int>(
            "insert into public.gebelik (taraf_id, sat, gebelik_no, sube_id, ekleyen) values (@p0, current_date - 200, 1, @p1, 0) returning id",
            [hasta, Merkez]);
        d.Temizle($"delete from public.islem_log where tablo_id in ({LogGebelik}, {LogSonuc}) and taraf_id = {hasta}");
        d.Temizle($"delete from public.gebelik_sonuc where gebelik_id = {gebelik}");
        d.Temizle($"delete from public.gebelik where id = {gebelik}");
        using var h = await IstemciAsync(d, "gebe.sonuc:e");

        // canliBebek < 0: fn_gebelik_sonucla geçer (sonuç satırı + dosya kapanır), ikinci adımdaki
        //   ayrıntı güncellemesi CHECK'e (coalesce(canli_bebek,0) >= 0) takılır.
        var y = await h.PostAsJsonAsync($"/api/gebelik/{gebelik}/sonuc", new { sonuc = 1, canliBebek = -1 });
        Assert.False(y.IsSuccessStatusCode, "geçersiz ayrıntı sonucu düşürmeli");

        // K36: dosya hâlâ AÇIK, sonuç satırı yok, log yok.
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select durum::int from public.gebelik where id = @p0", [gebelik]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.gebelik_sonuc where gebelik_id = @p0", [gebelik]));
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.islem_log where tablo_id = @p0 and taraf_id = @p1", [LogSonuc, hasta]));

        // Aynı istek geçerli ayrıntıyla: tek sonuç satırı, dosya kapalı, log var - yol gerçekten çalışıyor.
        var saglam = await h.PostAsJsonAsync($"/api/gebelik/{gebelik}/sonuc", new { sonuc = 1, canliBebek = 1 });
        Assert.Equal(HttpStatusCode.OK, saglam.StatusCode);
        Assert.Equal(2, await api.Veri.TekDegerAsync<int>("select durum::int from public.gebelik where id = @p0", [gebelik]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.gebelik_sonuc where gebelik_id = @p0", [gebelik]));
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select count(*)::int from public.islem_log where tablo_id = @p0 and taraf_id = @p1", [LogSonuc, hasta]));
    }
}
