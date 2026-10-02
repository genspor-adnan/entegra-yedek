using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// İSTEK ÜZERİNDE YAZIŞMA (806).
///
/// Kullanıcı: *"mesajlaşmayla devam et"*. Tasarım notu (797) bunu baştan
/// söylemişti: ayrı `telerad_mesaj` tablosu yerine
/// `mesaj_sohbet.kaynak_tur/kaynak_id`. Mesajlaşma modülü okunmamış sayacını,
/// üyeliği, yanıtlamayı ve arşivi zaten çözüyor - ikinci bir yazışma
/// altyapısı, bunların ikincisini yazmak (ve birini unutmak) olurdu.
/// </summary>
public sealed class TeleradSohbetTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>
    /// TEST KENDİ İSTEĞİNİ AÇAR: "en eskisini" ödünç almak, ekrandan açılmış
    /// gerçek bir sohbetle benzersizlik kısıtında çakışıyordu (çakıştı da).
    /// </summary>
    private static async Task<int> IstekAcAsync(NpgsqlConnection b, NpgsqlTransaction t)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);
        var taraf = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('TELERAD SOHBET TEST KURUMU', 'TRSHB', 1, @p0) returning id",
            t, [sube], CancellationToken.None);
        var kurum = await b.TekDegerAsync<int>(
            "insert into public.telerad_kurum (taraf_id, yon, dicom_ae_title, sube_id) "
            + "values (@p0, 1, '', @p1) returning id",
            t, [taraf, sube], CancellationToken.None);
        return await b.TekDegerAsync<int>(
            "insert into public.telerad_istek "
            + "(kurum_id, dis_erisim_no, oncelik, modalite, goruntu_durum, "
            + " cekim_zamani, gelis_zamani, sube_id) "
            + "values (@p0, @p2, 1, 1, 1, now(), now(), @p1) returning id",
            t, [kurum, sube, Guid.NewGuid().ToString("N")[..10]], CancellationToken.None);
    }

    private static Task<int> SohbetAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int istekId, string baslik = "deneme")
        => b.TekDegerAsync<int>("""
            insert into public.mesaj_sohbet
                   (tip, ad, olusturan, son_mesaj_tarihi, kaynak_tur, kaynak_id)
            values (3, @p1, 1, (now())::timestamp, 'telerad-istek', @p0)
            returning id
            """, t, [istekId, baslik], CancellationToken.None);

    [VtFact]
    public async Task Ayni_is_icin_TEK_sohbet()
    {
        if (!_olgu.Baglandi(nameof(Ayni_is_icin_TEK_sohbet))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // İkinci sohbet açılsaydı yazışma iki listeye bölünür ve "yazdım ama
        //   görmedi" durumu doğardı - kişi sohbetindeki kuralın aynısı (341).
        var istek = await IstekAcAsync(b, t);
        await SohbetAcAsync(b, t, istek);

        await b.CalistirAsync("savepoint sp_ikinci", t, [], CancellationToken.None);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => SohbetAcAsync(b, t, istek, "ikinci"));
        Assert.Equal("23505", h.SqlState);
        await b.CalistirAsync("rollback to savepoint sp_ikinci", t, [], CancellationToken.None);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Serbest_sohbetler_KAYNAKSIZ_kalabilir()
    {
        if (!_olgu.Baglandi(nameof(Serbest_sohbetler_KAYNAKSIZ_kalabilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Benzersizlik yalnız KAYDA BAĞLI sohbetler için (kısmi indeks):
        //   kişi ve grup sohbetleri kaynaksız açılır, ikisi birden
        //   engellenseydi mesajlaşma modülü çalışmaz olurdu.
        for (var i = 0; i < 2; i++)
            await b.CalistirAsync("""
                insert into public.mesaj_sohbet (tip, ad, olusturan, son_mesaj_tarihi)
                values (2, 'kaynaksiz deneme', 1, (now())::timestamp)
                """, t, [], CancellationToken.None);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Is_sohbetinin_basligi_KAYITTAN_gelir()
    {
        if (!_olgu.Baglandi(nameof(Is_sohbetinin_basligi_KAYITTAN_gelir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // İki kişilik bir iş sohbetinde karşı tarafın adını başlık yapmak,
        //   hangi işe ait olduğunu gizlerdi - tip 3 başlığı kaydın kendisinden
        //   alır (v_mesaj_sohbet, 806).
        var istek = await IstekAcAsync(b, t);
        var sohbet = await SohbetAcAsync(b, t, istek, "TR-2026/00001 · KURUM");

        var kullanici = await b.TekDegerAsync<int>(
            "select id from public.taraf_kullanici where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);
        await b.CalistirAsync("""
            insert into public.mesaj_uye (sohbet_id, kullanici_id, rol)
            values (@p0, @p1, 2)
            """, t, [sohbet, kullanici], CancellationToken.None);

        var satir = await b.ListeAsync("""
            select v.baslik, v.tip, v.kaynak_tur as "kaynakTur", v.kaynak_id as "kaynakId"
              from public.v_mesaj_sohbet v
             where v.id = @p0 and v.kullanici_id = @p1
            """, t, [sohbet, kullanici],
            o => (Baslik: o.GetString(0), Tip: o.GetInt16(1),
                  Tur: o.GetString(2), Kayit: o.GetInt32(3)),
            CancellationToken.None);

        Assert.Single(satir);
        Assert.Equal("TR-2026/00001 · KURUM", satir[0].Baslik);
        Assert.Equal((short)3, satir[0].Tip);
        Assert.Equal("telerad-istek", satir[0].Tur);
        Assert.Equal(istek, satir[0].Kayit);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Dis_kurum_rolu_MESAJLASABILIR_ama_duzenleyemez()
    {
        if (!_olgu.Baglandi(nameof(Dis_kurum_rolu_MESAJLASABILIR_ama_duzenleyemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // 795'te `mesaj` yetkisi BİLEREK kaldırılmıştı: kapsam kuralı yoktu.
        //   Şimdi kapsam ÜYELİK - sohbet listesi `v_mesaj_sohbet.kullanici_id`
        //   ile süzülüyor, her uç `mesaj_uye` kontrolünden geçiyor.
        //   Değiştir/sil YOK: başkasının mesajını düzenlemez.
        var y = await b.ListeAsync("""
            select ry.gor, ry.ekle, ry.degistir, ry.sil
              from public.rol_yetki ry
              join public.rol r on r.id = ry.rol_id
              join public.yetki yt on yt.id = ry.yetki_id
             where r.kod = 'dis_istem_kurumu' and yt.kod = 'mesaj'
            """, t, [], o => (Gor: o.GetInt16(0), Ekle: o.GetInt16(1),
                              Degistir: o.GetInt16(2), Sil: o.GetInt16(3)),
            CancellationToken.None);

        Assert.Single(y);
        Assert.Equal((short)1, y[0].Gor);
        Assert.Equal((short)1, y[0].Ekle);
        Assert.Equal((short)0, y[0].Degistir);
        Assert.Equal((short)0, y[0].Sil);

        await t.RollbackAsync();
    }

    [Fact]
    public void Yazisma_dugmesi_calisma_listesinde()
    {
        var ekran = AksiyonKatalogu.Ekran("telerad-istek-liste");
        var mesaj = ekran!.FirstOrDefault(a => a.Kod == "telerad.mesaj");
        Assert.True(mesaj is not null, "Yazışma düğmesi yok.");
        Assert.True(mesaj!.KayitGerekir, "Yazışma bir İŞİN üzerinde açılır.");
        // MESAJ YETKİSİNE BAĞLI: yazışma mesajlaşma modülünün işidir,
        //   teleradyolojinin ikinci bir sohbet altyapısı yok.
        Assert.Equal("mesaj", mesaj.KaynakKodu);
    }
}
