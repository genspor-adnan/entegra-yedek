using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>Kurum tipi / modul katalog satiri (359).</summary>
public sealed record KurumTipiSatiri(string Kod, string Ad, int Sira);

/// <summary>Tip x modul varsayilani: 0 gizli · 1 acik · 2 opsiyonel.</summary>
public sealed record KurumTipiModul(string KurumTipi, string Modul, int Varsayilan);

/// <summary>
/// Kurum profili (359/364). SUBEYE GORE: sube_id = 0 kurum geneli, N o subenin
/// kendi profili. <c>Devralindi</c> = bu sube icin ayri satir YOK, kurum
/// genelinden okundu - ekran bunu yazar ve "bu sube icin ayri ayar" onerir.
/// </summary>
public sealed record KurumProfil(
    int UrunModu, string KurumTipi, string AltTip, string Basamak, string TesisKodu,
    int SubeYapisi, int HekimSayisi, int UniteSayisi, string Dil, string ParaBirimi,
    IReadOnlyDictionary<string, int> Moduller,
    int SubeId = 0,
    bool Devralindi = false);

/// <summary>
/// KURUM PROFILI (359) - Firma Bilgileri › Kurum Tipi &amp; Sistem Ayarlari.
///
/// Profil TEK SATIRDIR (id = 1): kurulumun kendisi bir kurum tipidir. Modul
/// gorunurlugu iki katmanli - once profildeki override (`moduller` jsonb),
/// yoksa tipin varsayilani (`kurum_tipi_modul`).
/// </summary>
public sealed class KurumProfilDeposu
{
    private readonly VeriKaynagi _veri;

    public KurumProfilDeposu(VeriKaynagi veri) => _veri = veri;

    public async Task<(KurumProfil Profil, List<KurumTipiSatiri> Tipler,
                       List<KurumTipiSatiri> Moduller, List<KurumTipiModul> Matris)>
        OkuAsync(int subeId = 0, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        var tipler = new List<KurumTipiSatiri>();
        await using (var k = baglanti.Komut(
            "select kod, ad, sira from public.kurum_tipi where durum = 1 order by sira, ad", null))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal))
                tipler.Add(new(o.GetString(0), o.GetString(1), o.GetInt16(2)));

        var moduller = new List<KurumTipiSatiri>();
        await using (var k = baglanti.Komut(
            "select kod, ad, sira from public.kurum_modul order by sira, ad", null))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal))
                moduller.Add(new(o.GetString(0), o.GetString(1), o.GetInt16(2)));

        var matris = new List<KurumTipiModul>();
        await using (var k = baglanti.Komut(
            "select kurum_tipi, modul, varsayilan from public.kurum_tipi_modul", null))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal))
                matris.Add(new(o.GetString(0), o.GetString(1), o.GetInt16(2)));

        return (await ProfilOkuAsync(baglanti, null, subeId, iptal), tipler, moduller, matris);
    }

    private static async Task<KurumProfil> ProfilOkuAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction? islem, int subeId, CancellationToken iptal)
    {
        // COZUM SIRASI DB'DE (364): once subenin satiri, yoksa kurum geneli.
        //   Ayni sira menu suzmesinde ve basvuru hekim rolunde de kullaniliyor -
        //   ikinci bir yerde tekrarlanmasin.
        await using var komut = baglanti.Komut("""
            select urun_modu, kurum_tipi, alt_tip, basamak, tesis_kodu,
                   sube_yapisi, hekim_sayisi, unite_sayisi, dil, para_birimi,
                   moduller::text, sube_id
              from public.fn_kurum_profil(@p0)
            """, islem, subeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            // Satir yoksa (kurulum yapilmamis) varsayilanla don - ekran acilsin.
            return new KurumProfil(2, "muayenehane", "", "", "", 1, 1, 1, "tr", "TL",
                                   new Dictionary<string, int>(), subeId, subeId != 0);

        var ham = o.GetString(10);
        var sozluk = new Dictionary<string, int>(StringComparer.Ordinal);
        foreach (var alan in JsonDocument.Parse(ham).RootElement.EnumerateObject())
            sozluk[alan.Name] = alan.Value.ValueKind == JsonValueKind.Number
                ? alan.Value.GetInt32()
                : int.TryParse(alan.Value.ToString(), out var s) ? s : 0;

        var okunanSube = o.GetInt16(11);
        return new KurumProfil(o.GetInt16(0), o.GetString(1), o.GetString(2), o.GetString(3),
            o.GetString(4), o.GetInt16(5), o.GetInt16(6), o.GetInt16(7), o.GetString(8),
            o.GetString(9), sozluk, subeId,
            // Istenen sube ile OKUNAN satirin subesi farkliysa deger kurum
            //   genelinden devralinmistir.
            Devralindi: okunanSube != subeId);
    }

    /// <summary>
    /// Profili yazar (tek satir upsert). Modul sozlugu OVERRIDE'lardir: tipin
    /// varsayilaniyla ayni olan anahtarlar da yazilabilir, okuma zaten override'i
    /// once alir.
    /// </summary>
    public async Task<KurumProfil> YazAsync(KurumProfil yeni, YazmaBaglami baglam,
        CancellationToken iptal = default)
        => await IsKuraliCevirAsync(async () =>
        {
            await using var baglanti = await _veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var moduller = JsonSerializer.Serialize(yeni.Moduller);
            // SUBE BAZLI (364): anahtar sube_id - 0 kurum geneli, N o sube.
            //   Bir subeye ilk kez yazildiginda kurum genelinden AYRILMIS olur.
            await using (var komut = baglanti.Komut("""
                insert into public.kurum_profil
                       (sube_id, urun_modu, kurum_tipi, alt_tip, basamak, tesis_kodu,
                        sube_yapisi, hekim_sayisi, unite_sayisi, dil, para_birimi,
                        moduller, ekleyen, degistiren, degistirme_tarihi)
                values (@p12, @p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9,
                        @p10::jsonb, @p11, @p11, now()::timestamp)
                on conflict (sube_id) do update
                   set urun_modu = excluded.urun_modu,
                       kurum_tipi = excluded.kurum_tipi,
                       alt_tip = excluded.alt_tip,
                       basamak = excluded.basamak,
                       tesis_kodu = excluded.tesis_kodu,
                       sube_yapisi = excluded.sube_yapisi,
                       hekim_sayisi = excluded.hekim_sayisi,
                       unite_sayisi = excluded.unite_sayisi,
                       dil = excluded.dil,
                       para_birimi = excluded.para_birimi,
                       moduller = excluded.moduller,
                       degistiren = excluded.degistiren,
                       degistirme_tarihi = now()::timestamp
                """, islem,
                (short)yeni.UrunModu, yeni.KurumTipi, yeni.AltTip, yeni.Basamak, yeni.TesisKodu,
                (short)yeni.SubeYapisi, (short)yeni.HekimSayisi, (short)yeni.UniteSayisi,
                yeni.Dil, yeni.ParaBirimi, moduller, baglam.KullaniciId, (short)yeni.SubeId))
                await komut.ExecuteNonQueryAsync(iptal);

            var sonuc = await ProfilOkuAsync(baglanti, islem, yeni.SubeId, iptal);
            await islem.CommitAsync(iptal);
            return sonuc;
        });

    /// <summary>
    /// URUN MODU (489): 1 ERP (Gentegre AI) · 2 HBYS (GenoTIP AI) · 3 ikisi.
    ///
    /// Kaynak SUBENIN PROFILI, referans anahtari degil (kullanici: "hbys
    /// moduna gecmiyor"): ekran modu `kurum_profil.urun_modu`ya yaziyordu,
    /// giris yaniti ise `referans genel.urun_modu`yu okuyordu - iki kaynak
    /// ayrilinca ekranda HBYS yazip menu ERP kaliyordu. Cozum sirasi DB'de
    /// (fn_urun_modu): subenin satiri > kurum geneli > referans.
    /// </summary>
    public async Task<int> UrunModuAsync(int subeId = 0, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await UrunModuAsync(baglanti, subeId, iptal);
    }

    public static async Task<int> UrunModuAsync(NpgsqlConnection baglanti,
        int subeId = 0, CancellationToken iptal = default)
    {
        await using var komut = baglanti.Komut(
            "select public.fn_urun_modu(@p0)", null, subeId);
        return Convert.ToInt32(await komut.ExecuteScalarAsync(iptal) ?? 1);
    }

    /// <summary>
    /// Bu kurulumda ACIK modullerin kodlari (359). Menu/rota suzmesi bunu
    /// kullanir; cozum sunucuda (profil override'i > tip varsayilani) yapilir ki
    /// istemci ayni kurali ikinci kez yazmasin.
    /// </summary>
    public async Task<List<string>> AcikModullerAsync(int subeId = 0,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await AcikModullerAsync(baglanti, subeId, iptal);
    }

    /// <summary>
    /// AKTIF SUBENIN acik modulleri (364): sube profili yoksa kurum geneli.
    /// Menu ve rotalar buna gore suzuldugu icin sube degisince ekran da degisir.
    /// </summary>
    public static async Task<List<string>> AcikModullerAsync(NpgsqlConnection baglanti,
        int subeId = 0, CancellationToken iptal = default)
    {
        var liste = new List<string>();
        await using var komut = baglanti.Komut(
            "select m.kod from public.kurum_modul m "
            + " where public.fn_kurum_modul_acik(m.kod, @p0) order by m.sira, m.kod",
            null, subeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal)) liste.Add(o.GetString(0));
        return liste;
    }

    /// <summary>
    /// AKTIF SUBEDE basvuruda sorulan hekim rolu (361/364) - kural DB'de
    /// (fn_basvuru_hekim_rolu), istemci yalnizca sonucu okur.
    /// </summary>
    public async Task<int> HekimRoluAsync(int subeId = 0, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await HekimRoluAsync(baglanti, subeId, iptal);
    }

    public static async Task<int> HekimRoluAsync(NpgsqlConnection baglanti,
        int subeId = 0, CancellationToken iptal = default)
    {
        await using var komut = baglanti.Komut(
            "select public.fn_basvuru_hekim_rolu(@p0)", null, subeId);
        return Convert.ToInt32(await komut.ExecuteScalarAsync(iptal) ?? 4);
    }

    /// <summary>PG hatasini (FK, check) is kurali mesajina cevirir.</summary>
    private static async Task<T> IsKuraliCevirAsync<T>(Func<Task<T>> is_)
    {
        try { return await is_(); }
        catch (PostgresException h) when (h.SqlState is "23503" or "23514")
        {
            throw GentegreHatasi.IsKurali("Bilinmeyen kurum tipi ya da geçersiz değer.");
        }
    }
}
