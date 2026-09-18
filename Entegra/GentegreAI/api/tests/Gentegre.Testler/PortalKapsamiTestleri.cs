using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// PORTAL KAPSAMI (794) — dış doktor · dış kurum · hasta.
///
/// Kullanıcı: *"Dışardan hasta gönderen 'Dış Doktor' gönderdiği hastaların
/// sonuçlarını görecek… hasta rolü olan hastalar randevu alıp sonuçlarını…
/// görebilecekler"* ve *"kapsamla başla"*.
///
/// Bir role `lab.sonuc` yetkisi verildiği an, kapsam yoksa o kişi BÜTÜN
/// hastaların sonucunu görür. Bu testler kapsamın iki sözünü korur:
///
///  1. **Kural olmayan kaynak KAPALIDIR** - yarın eklenen bir ekran, kimse
///     fark etmeden portal kullanıcısının önüne düşmesin.
///  2. **Portal rolü başka rolle birleşemez** - yetki rollerin birleşimidir
///     (665); ikinci bir iç rol kapsamı sessizce deler.
/// </summary>
public sealed class PortalKapsamiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static SorguParcasi Uret(string kaynakAd, short portalTuru, int kullanici)
    {
        var kaynak = KaynakKatalogu.Bul(kaynakAd);
        Assert.NotNull(kaynak);
        var kolonlar = kaynak!.Kolonlar.Where(k => k.Varsayilan).Take(3).ToList();
        return new SorguUretici(kaynak, portalTuru, kullanici)
            .Satirlar(new ListeIstegi(), kolonlar, null, null, kullanici);
    }

    [Fact]
    public void Portal_kullanicisi_KENDI_kayitlarini_gorur()
    {
        // Hasta: kendi istemi. Sorgu metninde kural GÖRÜNMELİ ve değer
        //   PARAMETRE olmalı - id'yi SQL'e gömmek, istekten gelen bir sayıyla
        //   aynı kapıyı açardı.
        var sorgu = Uret("lab-istem", PortalKapsam.Hasta, 4242);
        Assert.Contains("i.taraf_id = @p", sorgu.Sql);
        Assert.Contains(4242, sorgu.Parametreler);
        Assert.DoesNotContain("4242", sorgu.Sql);
    }

    [Fact]
    public void Dis_doktor_GONDERDIGI_hastayi_gorur()
    {
        var sorgu = Uret("lab-sonuc", PortalKapsam.DisDoktor, 77);
        // "Gönderen" bağı belge_satir_rol'dedir (rol = 1).
        Assert.Contains("belge_satir_rol", sorgu.Sql);
        Assert.Contains("bsr.rol = 1", sorgu.Sql);
        Assert.Contains(77, sorgu.Parametreler);
    }

    [Fact]
    public void Dis_kurum_KENDI_istemini_gorur()
    {
        var sorgu = Uret("lab-sonuc", PortalKapsam.DisKurum, 88);
        Assert.Contains("i.dis_kurum_id = @p", sorgu.Sql);
        Assert.Contains(88, sorgu.Parametreler);
    }

    [Fact]
    public void Kurali_OLMAYAN_kaynak_portal_roluNE_KAPALI()
    {
        // Randevuda dış doktor/dış kurum kuralı YOK: randevu kurumun kendi
        //   takvimi. Kapalı kapı "hepsini göster" değil "hiç gösterme" olmalı -
        //   sorgu `false` taşır ve hiç satır dönmez.
        var sorgu = Uret("randevu", PortalKapsam.DisDoktor, 77);
        Assert.Contains("false", sorgu.Sql);

        // Aynı kaynakta HASTA kuralı var: kendi randevusu.
        var hasta = Uret("randevu", PortalKapsam.Hasta, 77);
        Assert.Contains("rv.hasta_id = @p", hasta.Sql);
        Assert.DoesNotContain(" false", hasta.Sql);
    }

    [Fact]
    public void Ic_kullanicida_kural_HIC_eklenmez()
    {
        // Portal türü 0 olan kullanıcı bugünkü davranışı görür: kapsam
        //   koşulu sorguya hiç girmez (mevcut ekranlar yavaşlamasın).
        var kaynak = KaynakKatalogu.Bul("lab-sonuc")!;
        var sorgu = new SorguUretici(kaynak)
            .Satirlar(new ListeIstegi(), kaynak.Kolonlar.Where(k => k.Varsayilan).Take(3).ToList(),
                      null, null, 5);
        Assert.DoesNotContain("belge_satir_rol", sorgu.Sql);
        Assert.DoesNotContain("dis_kurum_id = @p", sorgu.Sql);
    }

    [Fact]
    public async Task Portal_rolu_BASKA_rolle_birlesemez()
    {
        if (!_olgu.Baglandi(nameof(Portal_rolu_BASKA_rolle_birlesemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Deneme portal rolü (göç rolleri henüz işaretlemiyor - damga hazır).
        var portalRol = await b.TekDegerAsync<int>("""
            insert into public.rol (kod, ad, amac, sistem, aktif, portal_turu)
            values ('test_portal', 'Test Portal', 'test', 0, 1, 1) returning id
            """, t, [], CancellationToken.None);
        var icRol = await b.TekDegerAsync<int>(
            "select id from public.rol where kod = 'kayit_kabul'", t, [],
            CancellationToken.None);
        var kullanici = await b.TekDegerAsync<int>(
            "select id from public.taraf_kullanici where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);

        await b.CalistirAsync("update public.taraf_kullanici set rol_id = @p1 where id = @p0",
            t, [kullanici, portalRol], CancellationToken.None);

        // Ana rol portal iken İÇ rolü EK rol olarak eklemek reddedilir.
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync("""
            insert into public.kullanici_rol (kullanici_id, rol_id) values (@p0, @p1)
            """, t, [kullanici, icRol], CancellationToken.None));
        Assert.Equal("GK422", h.SqlState);
        Assert.Contains("Portal rolü", h.MessageText);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Portal_turu_ROLLERDEN_cozulur()
    {
        if (!_olgu.Baglandi(nameof(Portal_turu_ROLLERDEN_cozulur))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var kullanici = await b.TekDegerAsync<int>(
            "select id from public.taraf_kullanici where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);

        // Bugün herkes iç kullanıcı: damga var, rol işaretlenmedi.
        Assert.Equal((short)0, await b.TekDegerAsync<short>(
            "select public.fn_kullanici_portal_turu(@p0)", t, [kullanici],
            CancellationToken.None));

        var portalRol = await b.TekDegerAsync<int>("""
            insert into public.rol (kod, ad, amac, sistem, aktif, portal_turu)
            values ('test_portal2', 'Test Portal 2', 'test', 0, 1, 3) returning id
            """, t, [], CancellationToken.None);
        await b.CalistirAsync("update public.taraf_kullanici set rol_id = @p1 where id = @p0",
            t, [kullanici, portalRol], CancellationToken.None);

        Assert.Equal((short)3, await b.TekDegerAsync<short>(
            "select public.fn_kullanici_portal_turu(@p0)", t, [kullanici],
            CancellationToken.None));

        await t.RollbackAsync();
    }
}
