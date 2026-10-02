using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// TEST SEVİYESİNDE YETKİ KISITI (889 — KTS denetim maddesi L7).
///
/// <para>Yetki modül seviyesindeydi: <c>lab.sonuc</c> yetkisi olan herkes HER
/// tetkiki isteyebiliyor, görebiliyor ve onaylayabiliyordu. HIV, adli
/// toksikoloji, genetik, evlilik öncesi tarama gibi testlerde bu yetmez.</para>
///
/// <para><b>Karar tek yerde:</b> <c>fn_lab_tetkik_izin_roller</c> (923 - GÜNCEL rol kümesi, ana + ek). Liste süzgeçleri
/// de (SorguUretici) buradaki çağrılar da aynı fonksiyonu sorar; iki yerde
/// ayrı yazılsaydı ekran ile rapor sessizce ayrışırdı.</para>
///
/// <para><b>Kısıtı olmayan tetkik herkese açıktır</b> — kural tanımlanana
/// kadar hiçbir davranış değişmez.</para>
/// </summary>
public sealed partial class LabServisi
{
    /// <summary>İstemcinin ayırt edebilmesi için: akılcı engelinden farklı.</summary>
    public const string TestYetkiKodu = "TEST_YETKI";

    /// <summary>Rolün bu işlemi YAPAMADIĞI tetkikler (kod + ad ile).</summary>
    private static Task<List<(int TetkikId, string Kod, string Ad)>> YetkisizTetkiklerAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, IReadOnlyList<int> tetkikIdler,
        IReadOnlyList<int> roller, string islemAdi, CancellationToken iptal)
        => baglanti.ListeAsync("""
            select t.id, t.kod, t.ad
              from public.lab_tetkik t
             where t.id = any(@p0)
               and not public.fn_lab_tetkik_izin_roller(t.id, @p1, @p2)
             order by t.ad
            """, islem, [tetkikIdler.ToArray(), roller.ToArray(), islemAdi],
            o => (o.GetInt32(0), o.GetString(1), o.GetString(2)), iptal);

    /// <summary>
    /// İSTEM YOLU: yetkisiz tetkikleri ayıklar.
    ///
    /// <para>Etkileşimli istemde <b>hata verir</b> — kullanıcı ne istediğini
    /// biliyor, sessizce eksik istem açmak "istedim ama çalışılmamış"
    /// durumunu üretirdi. Başvuru ücretinden açılan sessiz istemde ise
    /// yetkisiz tetkik atlanır ve istem geri kalanla açılır; orada hata
    /// fırlatmak hasta kaydını düşürürdü.</para>
    /// </summary>
    private static async Task<HashSet<int>> TestYetkisiUygulaAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, IReadOnlyList<int> tetkikIdler,
        IstekBaglami baglam, bool sessiz, CancellationToken iptal)
    {
        var yetkisiz = await YetkisizTetkiklerAsync(baglanti, islem, tetkikIdler,
                                                    baglam.RolIdleri, "iste", iptal);
        if (yetkisiz.Count == 0) return [];

        if (!sessiz)
            throw GentegreHatasi.Yasak(
                yetkisiz.Count == 1
                    ? $"\"{yetkisiz[0].Ad}\" tetkikini isteme yetkiniz yok."
                    : $"{yetkisiz.Count} tetkiki isteme yetkiniz yok: "
                      + string.Join(", ", yetkisiz.Select(y => y.Ad)),
                new { kod = TestYetkiKodu,
                      tetkikler = yetkisiz.Select(y => new { y.TetkikId, y.Kod, y.Ad }) });

        return [.. yetkisiz.Select(y => y.TetkikId)];
    }

    /// <summary>
    /// SONUÇ YOLU: bu sonucun tetkiki rolün <paramref name="islemAdi"/>
    /// iznine kapalıysa fırlatır. Tetkik id'si sonuçtan okunur - çağıran
    /// taşırsa yanlış tetkik gönderilebilirdi.
    /// </summary>
    private async Task SonucTestYetkisiIsteAsync(long sonucId, IstekBaglami baglam,
                                                 string islemAdi, CancellationToken iptal)
    {
        var izin = await _veri.TekDegerAsync<bool?>("""
            select public.fn_lab_tetkik_izin_roller(ls.tetkik_id, @p1, @p2)
              from public.lab_sonuc ls where ls.id = @p0
            """, [sonucId, baglam.RolIdleri.ToArray(), islemAdi], iptal);

        // Sonuç yoksa burada karar verilmez: çağıranın kendi "bulunamadı"
        //   hatası daha doğru bir cevaptır.
        if (izin is false)
            throw GentegreHatasi.Yasak(
                islemAdi == "onayla"
                    ? "Bu tetkiki onaylama yetkiniz yok."
                    : "Bu tetkikin sonucunu görme yetkiniz yok.",
                new { kod = TestYetkiKodu });
    }

    /// <summary>İstem satırının tetkiki için izin kontrolü (sonuç girişi).</summary>
    private async Task SatirTestYetkisiIsteAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction? islem, int satirId, IstekBaglami baglam, CancellationToken iptal)
    {
        var izin = await baglanti.TekDegerAsync<bool?>("""
            select public.fn_lab_tetkik_izin_roller(s.tetkik_id, @p1, @p2)
              from public.lab_istem_satir s where s.id = @p0
            """, islem, [satirId, baglam.RolIdleri.ToArray(), "gor"], iptal);

        // GÖREMEYEN YAZAMAZ: sonucu girip sonra göremeyen kullanıcı, yazdığı
        //   değeri doğrulayamaz - yarım yetki, yetkisizlikten kötüdür.
        if (izin is false)
            throw GentegreHatasi.Yasak("Bu tetkike sonuç girme yetkiniz yok.",
                                       new { kod = TestYetkiKodu });
    }
}
