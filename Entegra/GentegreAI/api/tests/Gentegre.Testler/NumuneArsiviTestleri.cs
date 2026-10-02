using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// NUMUNE ARŞİVİ (890 — KTS denetim maddesi L13).
///
/// Arşivin işi tüpü BULDURMAK ve süresi dolanı göstermek; kuralları SQL
/// fonksiyonlarında yaşıyor (<c>fn_lab_arsiv_koy</c> / <c>_cikar</c> /
/// <c>_saklama_gun</c>). Bu kurallar okunarak değil çalıştırılarak
/// doğrulanır: "dolu göze ikinci tüp" ya da "ızgara dışı göz" ancak
/// denenince ortaya çıkar.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class NumuneArsiviTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Testin kendi dondurucusu + 3×3 kutusu ve iki numunesi.</summary>
    private static async Task<(int UniteId, int KutuId, int IstemId, int N1, int N2)>
        DuzenekKurAsync(VeriKaynagi veri)
    {
        var ek = Random.Shared.Next(100000).ToString();
        var uniteId = await veri.TekDegerAsync<int>("""
            insert into public.lab_arsiv_konum (tur, kod, ad, sicaklik)
            values (1, 'TARS-U' || @p0, 'Test dondurucu', -20) returning id
            """, [ek], CancellationToken.None);
        var kutuId = await veri.TekDegerAsync<int>("""
            insert into public.lab_arsiv_konum (ust_id, tur, kod, ad, sicaklik, satir, sutun)
            values (@p0, 3, 'TARS-K' || @p1, 'Test kutu', -20, 3, 3) returning id
            """, [uniteId, ek], CancellationToken.None);

        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_hasta order by id limit 1", null,
            CancellationToken.None);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, 0, 'TEST-ARS-' || @p1, 1, 2, 3, 1) returning id
            """, [hastaId, ek], CancellationToken.None);

        async Task<int> NumuneAsync(string son)
            => await veri.TekDegerAsync<int>("""
                insert into public.lab_numune (barkod, istem_id, hasta_id, numune_tipi,
                                               tup_tipi, durum)
                values ('TARS' || @p0 || @p1, @p2, @p3, 1, 6, 3) returning id
                """, [ek, son, istemId, hastaId], CancellationToken.None);

        return (uniteId, kutuId, istemId, await NumuneAsync("A"), await NumuneAsync("B"));
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int uniteId, int kutuId,
                                           int istemId)
    {
        await veri.CalistirAsync("""
            delete from public.lab_numune_arsiv where konum_id = @p0
            """, [kutuId], CancellationToken.None);
        await veri.CalistirAsync("""
            delete from public.lab_numune_hareket where numune_id in
                   (select id from public.lab_numune where istem_id = @p0)
            """, [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_numune where istem_id = @p0",
                                 [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_istem where id = @p0", [istemId],
                                 CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_arsiv_konum where id = @p0",
                                 [kutuId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_arsiv_konum where id = @p0",
                                 [uniteId], CancellationToken.None);
    }

    private static Task KoyAsync(VeriKaynagi veri, int numuneId, int kutuId, string goz) =>
        veri.TekDegerAsync<int>("select public.fn_lab_arsiv_koy(@p0, @p1, @p2, 1)",
                                [numuneId, kutuId, goz], CancellationToken.None);

    [VtFact]
    public async Task Ayni_goze_IKINCI_tup_konulamaz_ve_izgara_disi_goz_reddedilir()
    {
        if (!_olgu.Baglandi(nameof(Ayni_goze_IKINCI_tup_konulamaz_ve_izgara_disi_goz_reddedilir)))
            return;
        var veri = _olgu.Gerekli();

        var (uniteId, kutuId, istemId, n1, n2) = await DuzenekKurAsync(veri);
        try
        {
            await KoyAsync(veri, n1, kutuId, "b2");   // küçük harf de kabul (A5 = a5)

            // AYNI TÜP İKİ YERDE OLAMAZ.
            var h1 = await Assert.ThrowsAsync<Npgsql.PostgresException>(
                () => KoyAsync(veri, n1, kutuId, "C1"));
            Assert.Contains("zaten arşivde", h1.MessageText, StringComparison.Ordinal);

            // BİR GÖZDE BİR TÜP: ızgara kaydı, gerçekte olmayan bir yerleşimi
            //   anlatamamalı.
            var h2 = await Assert.ThrowsAsync<Npgsql.PostgresException>(
                () => KoyAsync(veri, n2, kutuId, "B2"));
            Assert.Contains("dolu", h2.MessageText, StringComparison.Ordinal);

            // IZGARA DIŞI: 3×3 kutuda D4 yok.
            var h3 = await Assert.ThrowsAsync<Npgsql.PostgresException>(
                () => KoyAsync(veri, n2, kutuId, "D4"));
            Assert.Contains("böyle bir göz değil", h3.MessageText, StringComparison.Ordinal);

            // KUTU OLMAYAN KONUMA TÜP KONMAZ: ünite bir raf/kutu değildir.
            var h4 = await Assert.ThrowsAsync<Npgsql.PostgresException>(
                () => KoyAsync(veri, n2, uniteId, "A1"));
            Assert.Contains("kutu değil", h4.MessageText, StringComparison.Ordinal);

            // DOLULUK: 9 gözün 1'i dolu.
            var kutu = await veri.TekAsync("""
                select goz_sayisi, dolu, bos from public.v_lab_arsiv_kutu where konum_id = @p0
                """, [kutuId],
                o => new { Toplam = o.GetInt32(0), Dolu = o.GetInt64(1), Bos = o.GetInt64(2) },
                CancellationToken.None);
            Assert.Equal(9, kutu!.Toplam);
            Assert.Equal(1, kutu.Dolu);
            Assert.Equal(8, kutu.Bos);

            // KONUM YOLU okunur olmalı: "Test dondurucu / Test kutu".
            var yol = await veri.TekDegerAsync<string>(
                "select public.fn_lab_arsiv_yol(@p0)", [kutuId], CancellationToken.None);
            Assert.Equal("Test dondurucu / Test kutu", yol);
        }
        finally { await TemizleAsync(veri, uniteId, kutuId, istemId); }
    }

    [VtFact]
    public async Task Cikarma_ZINCIRE_yazar_ve_goz_bosalir()
    {
        if (!_olgu.Baglandi(nameof(Cikarma_ZINCIRE_yazar_ve_goz_bosalir))) return;
        var veri = _olgu.Gerekli();

        var (uniteId, kutuId, istemId, n1, n2) = await DuzenekKurAsync(veri);
        try
        {
            await KoyAsync(veri, n1, kutuId, "A1");
            await veri.TekDegerAsync<int>(
                "select public.fn_lab_arsiv_cikar(@p0, 1::smallint, 1, 'tekrar')",
                [n1], CancellationToken.None);

            // Kayıt SİLİNMEZ, tarihe döner: "arşivde değil" ile "çıkarıldı"
            //   farklı iki cevaptır.
            var kayit = await veri.TekAsync("""
                select durum, cikis_neden from public.lab_numune_arsiv where numune_id = @p0
                """, [n1], o => new { Durum = o.GetInt16(0), Neden = o.GetInt16(1) },
                CancellationToken.None);
            Assert.Equal(2, kayit!.Durum);
            Assert.Equal(1, kayit.Neden);

            // Göz boşaldığı için AYNI göze başka tüp konabilir.
            await KoyAsync(veri, n2, kutuId, "A1");

            // ZİNCİR 433'ün kendi kodlarıyla: 6 saklamaya · 2 taşındı.
            var olaylar = await veri.ListeAsync("""
                select olay from public.lab_numune_hareket
                 where numune_id = @p0 order by id
                """, [n1], o => (int)o.GetInt16(0), CancellationToken.None);
            Assert.Equal([6, 2], olaylar);
        }
        finally { await TemizleAsync(veri, uniteId, kutuId, istemId); }
    }

    [VtFact]
    public async Task Saklama_suresi_TETKIKE_ozel_kurali_kullanir_ve_imha_listesi_dolar()
    {
        if (!_olgu.Baglandi(nameof(Saklama_suresi_TETKIKE_ozel_kurali_kullanir_ve_imha_listesi_dolar)))
            return;
        var veri = _olgu.Gerekli();

        var (uniteId, kutuId, istemId, n1, _) = await DuzenekKurAsync(veri);
        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'GLU' limit 1", null,
            CancellationToken.None);
        // Numuneye tetkik bağla: saklama süresi numunenin TESTİNDEN okunuyor.
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, numune_id, durum, sira)
            values (@p0, @p1, @p2, 1, 10) returning id
            """, [istemId, tetkikId, n1], CancellationToken.None);
        var genelId = 0; var tetkikPolId = 0;
        try
        {
            genelId = await veri.TekDegerAsync<int>("""
                insert into public.lab_saklama_politika (numune_tipi, gun, dayanak)
                values (1, 3, 'test genel') returning id
                """, null, CancellationToken.None);

            Assert.Equal(3, await veri.TekDegerAsync<int?>(
                "select public.fn_lab_arsiv_saklama_gun(@p0)", [n1], CancellationToken.None));

            // TETKİKE ÖZEL KURAL GENEL KURALI EZER: moleküler numune ile
            //   rutin biyokimya tüpü aynı süre saklanmaz.
            tetkikPolId = await veri.TekDegerAsync<int>("""
                insert into public.lab_saklama_politika (tetkik_id, gun, dayanak)
                values (@p0, 30, 'test tetkik') returning id
                """, [tetkikId], CancellationToken.None);

            Assert.Equal(30, await veri.TekDegerAsync<int?>(
                "select public.fn_lab_arsiv_saklama_gun(@p0)", [n1], CancellationToken.None));

            await KoyAsync(veri, n1, kutuId, "A1");
            var hedef = await veri.TekDegerAsync<DateTime?>("""
                select imha_hedef from public.lab_numune_arsiv where numune_id = @p0
                """, [n1], CancellationToken.None);
            Assert.Equal(DateTime.Today.AddDays(30), hedef);

            // SÜRE DOLUNCA İMHA LİSTESİNE DÜŞER; imhayı SİSTEM YAPMAZ, liste
            //   yalnız gösterir.
            await veri.CalistirAsync("""
                update public.lab_numune_arsiv set imha_hedef = current_date - 1
                 where numune_id = @p0
                """, [n1], CancellationToken.None);
            Assert.Equal(1, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.v_lab_arsiv_imha_bekleyen where numune_id = @p0
                """, [n1], CancellationToken.None));

            // İmha kaydı kapatılınca listeden düşer ve tüp "imha edildi" olur.
            await veri.TekDegerAsync<int>(
                "select public.fn_lab_arsiv_cikar(@p0, 3::smallint, 1, 'test imha')",
                [n1], CancellationToken.None);
            Assert.Equal(0, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.v_lab_arsiv_imha_bekleyen where numune_id = @p0
                """, [n1], CancellationToken.None));
            Assert.Equal(3, await veri.TekDegerAsync<short>("""
                select durum from public.lab_numune_arsiv where numune_id = @p0
                """, [n1], CancellationToken.None));
        }
        finally
        {
            if (tetkikPolId > 0)
                await veri.CalistirAsync("delete from public.lab_saklama_politika where id = @p0",
                                         [tetkikPolId], CancellationToken.None);
            if (genelId > 0)
                await veri.CalistirAsync("delete from public.lab_saklama_politika where id = @p0",
                                         [genelId], CancellationToken.None);
            await veri.CalistirAsync("delete from public.lab_istem_satir where id = @p0",
                                     [satirId], CancellationToken.None);
            await TemizleAsync(veri, uniteId, kutuId, istemId);
        }
    }
}
