using Gentegre.Api.Uclar;
using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// ŞABLONA BAĞLI HEKİM TERCİHLERİ (931, kullanıcı: "sık tanılar, reçete
/// şablonları, istem panelleri, metin makroları, kurallar da branş/doktora
/// özel.. kartın içine al").
///
/// · Kart katalogunda beş detay var, log numaraları ayrı.
/// · Kapsam: muayenenin bölümündeki bölüm ortak şablon uygulanır, başka
///   doktorun kişisel şablonu uygulanmaz.
/// · Kural: aktif "zorunlu_hikaye" hikâye boşken tamamlamayı durdurur; pasif
///   kural ya da dolu hikâye durdurmaz.
/// Test kendi şablon ve muayene satırlarını açar ve siler. Veritabanı yoksa atlanır.
/// </summary>
public sealed class MuayeneSablonTercihTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [Fact]
    public void Sablon_kartinda_bes_tercih_detayi_var_ve_kurallar_denetlenen_kodlar()
    {
        var kart = KartKatalogu.Bul("muayene-sablon")!;
        var adlar = kart.Detaylar!.Select(d => d.Ad).ToArray();
        Assert.Equal(["alanlar", "tanilar", "receteler", "paneller", "makrolar", "kurallar"], adlar);
        Assert.Equal(kart.Detaylar!.Count, kart.Detaylar!.Select(d => d.LogTabloId).Distinct().Count());
        Assert.All(KartKatalogu.SablonKurallari.Keys, k => Assert.StartsWith("zorunlu_", k));
    }

    [VtFact]
    public async Task Bolum_ortak_sablonun_kurali_uygulanir_baska_doktorunki_uygulanmaz()
    {
        if (!_olgu.Baglandi(nameof(Bolum_ortak_sablonun_kurali_uygulanir_baska_doktorunki_uygulanmaz))) return;
        var veri = _olgu.Gerekli();
        var e = "T931" + Random.Shared.Next(10000, 99999);
        var bolum = await veri.TekDegerAsync<int>("select min(id) from public.departman", []);
        var hasta = await veri.TekDegerAsync<int>("select min(id) from public.taraf", []);
        var ortak = await veri.TekDegerAsync<int>(
            "insert into public.muayene_sablon (kod, ad, tur, bolum_id) values (@p0, 'Ortak', 1, @p1) returning id",
            [e + "O", bolum]);
        var baskasi = await veri.TekDegerAsync<int>(
            "insert into public.muayene_sablon (kod, ad, tur, bolum_id, hekim_id) values (@p0, 'Baskasi', 1, @p1, 99999) returning id",
            [e + "B", bolum]);
        var muayene = await veri.TekDegerAsync<int>(
            "insert into public.muayene (taraf_id, bolum_id, hikaye) values (@p0, @p1, '') returning id",
            [hasta, bolum]);
        try
        {
            await veri.CalistirAsync("""
                insert into public.muayene_sablon_kural (sablon_id, kod, aktif) values (@p0, 'zorunlu_vital', 0);
                insert into public.muayene_sablon_kural (sablon_id, kod, aktif) values (@p1, 'zorunlu_ek_tani', 1);
                """, [ortak, baskasi]);

            var kapsam = await veri.ListeAsync(
                "select sablon_id from public.fn_muayene_sablon_kapsami(@p0)", [muayene], o => o.GetInt32(0));
            Assert.Contains(ortak, kapsam);
            Assert.DoesNotContain(baskasi, kapsam);

            await using var b = await veri.AcAsync(CancellationToken.None);
            // Pasif kural ve başka doktorun kuralı durdurmaz.
            Assert.Empty(await MuayeneSablonUclari.KuralEksikleriAsync(b, null, muayene, CancellationToken.None));

            await veri.CalistirAsync(
                "insert into public.muayene_sablon_kural (sablon_id, kod, aktif) values (@p0, 'zorunlu_hikaye', 1)", [ortak]);
            var eksik = await MuayeneSablonUclari.KuralEksikleriAsync(b, null, muayene, CancellationToken.None);
            Assert.Equal("hikaye", Assert.Single(eksik).Alan);

            await veri.CalistirAsync("update public.muayene set hikaye = 'Iki gundur ates' where id = @p0", [muayene]);
            Assert.Empty(await MuayeneSablonUclari.KuralEksikleriAsync(b, null, muayene, CancellationToken.None));

            // 933: muayenenin DOKTORUNUN şablonu varsa tercihlerde yalnız o
            //   (bölüm ortak gizlenir); kurallarda bölüm ortak YİNE uygulanır.
            await veri.CalistirAsync(
                "update public.muayene set personel_id = 99999, hikaye = '' where id = @p0", [muayene]);
            kapsam = await veri.ListeAsync(
                "select sablon_id from public.fn_muayene_sablon_kapsami(@p0)", [muayene], o => o.GetInt32(0));
            Assert.Equal([baskasi], kapsam);
            var kural = await veri.ListeAsync(
                "select sablon_id from public.fn_muayene_sablon_kapsami(@p0, true) order by 1", [muayene], o => o.GetInt32(0));
            Assert.Contains(ortak, kural);      // bölümde başka ortak şablon da olabilir
            Assert.Contains(baskasi, kural);
            var eksik2 = await MuayeneSablonUclari.KuralEksikleriAsync(b, null, muayene, CancellationToken.None);
            Assert.Contains(eksik2, x => x.Alan == "hikaye");   // bölüm kuralı
            Assert.Contains(eksik2, x => x.Alan == "tanilar");  // doktorun kuralı
        }
        finally
        {
            await veri.CalistirAsync("delete from public.muayene where id = @p0", [muayene]);
            await veri.CalistirAsync("delete from public.muayene_sablon where id in (@p0, @p1)", [ortak, baskasi]);
        }
    }
}
