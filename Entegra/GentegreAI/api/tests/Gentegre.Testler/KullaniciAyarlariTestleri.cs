using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Testler;

/// <summary>
/// KULLANICI AYARLARI (669) ve ÇOK ROLLÜLÜK (665).
///
/// İki şey test ediliyor, ikisi de sessizce yanlış çalışabilecek türden:
///  · OTURUM SAHİPLİĞİ — "oturumu kapat" başkasının oturumunu kapatamamalı.
///    Sahiplik kontrolü SQL'in içinde (`kullanici_id = @p0`); bir gün WHERE
///    kaybolursa test kırmızıya döner, kimse fark etmeden yayına gitmez.
///  · YETKİ BİRLEŞİMİ — ek rol eklemek yetkiyi ARTIRIR, azaltmaz; sayısal
///    sınırda en yüksek tavan kazanır.
/// </summary>
public class KullaniciAyarlariTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public KullaniciAyarlariTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    [Fact]
    public async Task Baskasinin_oturumu_kapatilamaz()
    {
        if (!_olgu.Baglandi(nameof(Baskasinin_oturumu_kapatilamaz))) return;
        var veri = _olgu.Veri!;
        var depo = new OturumDeposu(veri);

        var (a, b) = await IkiKullaniciAsync(veri);
        if (a == 0 || b == 0) return;                 // tek kullanicili kurulum

        var (oturumId, _) = await depo.AcAsync(a, Ozet(), DateTime.Now.AddDays(1),
            null, null, null, "10.0.0.1", "test-tarayici");
        try
        {
            // B, A'nin oturum kimligini tahmin edip kapatmaya calisiyor.
            var kapanan = await depo.KendiOturumunuKapatAsync(b, oturumId);
            Assert.Equal(0, kapanan);

            var hala = await veri.TekDegerAsync<int>(
                "select count(*)::int from public.oturum where id = @p0 and iptal_tarihi is null",
                new object?[] { oturumId });
            Assert.Equal(1, hala);

            // Sahibi kapatinca kapanir.
            Assert.True(await depo.KendiOturumunuKapatAsync(a, oturumId) >= 1);
        }
        finally
        {
            await veri.CalistirAsync("delete from public.oturum where id = @p0",
                new object?[] { oturumId });
        }
    }

    [Fact]
    public async Task Ek_rol_yetkiyi_artirir_ve_en_yuksek_tavan_kazanir()
    {
        if (!_olgu.Baglandi(nameof(Ek_rol_yetkiyi_artirir_ve_en_yuksek_tavan_kazanir))) return;
        var veri = _olgu.Veri!;

        var kullanici = await veri.TekDegerAsync<int>("""
            select k.id from public.taraf_kullanici k
             where k.aktif = 1
               and not exists (select 1 from public.kullanici_rol kr where kr.kullanici_id = k.id)
             order by k.id limit 1
            """, null);
        var rol = await veri.TekDegerAsync<int>(
            "select id from public.rol where kod = 'iskonto_onay'", null);
        if (kullanici == 0 || rol == 0) return;

        var anaRol = await veri.TekDegerAsync<int>(
            "select rol_id from public.taraf_kullanici where id = @p0",
            new object?[] { kullanici });
        if (anaRol == rol) return;                    // zaten onay rolunde

        var once = await YetkiSayisiAsync(veri, kullanici);
        var surumOnce = await veri.TekDegerAsync<long>(
            "select public.fn_kullanici_yetki_surumu(@p0)", new object?[] { kullanici });

        await veri.CalistirAsync(
            "insert into public.kullanici_rol (kullanici_id, rol_id) values (@p0, @p1)",
            new object?[] { kullanici, rol });
        try
        {
            var sonra = await YetkiSayisiAsync(veri, kullanici);
            Assert.True(sonra >= once, "Ek rol yetkiyi azaltmamali.");

            // Ek rol tavani %100; kisinin kendi rolu daha dusuk olsa bile en
            //   yuksek deger gecerli olmali (ve '100' olarak, '100.0' degil).
            var tavan = await veri.TekDegerAsync<string>("""
                select deger from public.fn_kullanici_yetkileri(@p0)
                 where yetki_kod = 'basvuru.iskonto'
                """, new object?[] { kullanici });
            Assert.Equal("100", tavan);

            // Rol kumesi degisti: onbellek damgasi da degismeli, yoksa yeni
            //   yetki bir sonraki oturuma kadar etkisiz kalirdi.
            var surumSonra = await veri.TekDegerAsync<long>(
                "select public.fn_kullanici_yetki_surumu(@p0)", new object?[] { kullanici });
            Assert.NotEqual(surumOnce, surumSonra);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.kullanici_rol where kullanici_id = @p0 and rol_id = @p1",
                new object?[] { kullanici, rol });
        }
    }

    [Fact]
    public async Task Sistem_rolu_silinemez()
    {
        if (!_olgu.Baglandi(nameof(Sistem_rolu_silinemez))) return;
        var veri = _olgu.Veri!;

        var var_ = await veri.TekDegerAsync<int>(
            "select count(*)::int from public.rol where kod = 'iskonto_onay' and sistem = 1", null);
        if (var_ == 0) return;                        // 664 uygulanmamis

        var hata = await Assert.ThrowsAnyAsync<Exception>(() =>
            veri.CalistirAsync("delete from public.rol where kod = 'iskonto_onay'", null));
        Assert.Contains("sistem rol", hata.Message, StringComparison.OrdinalIgnoreCase);
    }

    private static string Ozet() => Guid.NewGuid().ToString("N") + Guid.NewGuid().ToString("N");

    private static Task<int> YetkiSayisiAsync(VeriKaynagi veri, int kullanici)
        => veri.TekDegerAsync<int>(
            "select count(*)::int from public.fn_kullanici_yetkileri(@p0)",
            new object?[] { kullanici });

    private static async Task<(int A, int B)> IkiKullaniciAsync(VeriKaynagi veri)
    {
        var liste = await veri.ListeAsync(
            "select id from public.taraf_kullanici where aktif = 1 order by id limit 2",
            null, o => o.GetInt32(0));
        return liste.Count < 2 ? (0, 0) : (liste[0], liste[1]);
    }
}
