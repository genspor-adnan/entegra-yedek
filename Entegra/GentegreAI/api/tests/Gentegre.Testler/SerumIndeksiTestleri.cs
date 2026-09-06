using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// SERUM İNDEKSİ (HIL) KURALI (444).
///
/// Hemolizli numunede potasyum yalancı yüksek çıkar; değer "panik" bile
/// görünebilir, oysa hasta normaldir. Tersine lipemi bazı yöntemlerde
/// yalancı düşüklük yapar ve gerçek bir anormallik normal görünür. İkisi de
/// tedaviyi yanlış yönlendirir - bu yüzden kural test bazlı.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class SerumIndeksiTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public SerumIndeksiTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private static async Task<(int HastaId, int IstemId, int NumuneId)> NumuneKurAsync(
        VeriKaynagi veri, short? hemoliz = null, short? lipemi = null, short? ikter = null)
    {
        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, ad, soyad, hasta, sube_id)
            values ('TEST HIL HASTA', 'TEST', 'HIL', 1,
                    (select min(id) from public.sube))
            returning id
            """);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, istem_no, bolum, durum)
            values (@p0, 'TEST-HIL', 1, 1) returning id
            """, [hastaId]);
        var barkod = await veri.TekDegerAsync<string>(
            "select public.fn_lab_barkod_uret(0)") ?? "";
        var numuneId = await veri.TekDegerAsync<int>("""
            insert into public.lab_numune (barkod, istem_id, hasta_id, numune_tipi,
                                           tup_tipi, durum, hemoliz_idx, lipemi_idx,
                                           ikter_idx)
            values (@p0, @p1, @p2, 1, 1, 3, @p3, @p4, @p5)
            returning id
            """, [barkod, istemId, hastaId, hemoliz, lipemi, ikter]);
        return (hastaId, istemId, numuneId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int hastaId, int istemId)
    {
        await veri.CalistirAsync("delete from public.lab_numune where istem_id = @p0",
                                 [istemId]);
        await veri.CalistirAsync("delete from public.lab_istem where id = @p0", [istemId]);
        await veri.CalistirAsync("delete from public.taraf where id = @p0", [hastaId]);
    }

    private static async Task<(short Durum, string Uyari)> EtkiAsync(
        VeriKaynagi veri, string tetkikKod, int numuneId)
    {
        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = @p0", [tetkikKod]);
        var s = await veri.TekAsync(
            "select durum, uyari from public.fn_lab_indeks_etki(@p0, @p1)",
            [tetkikId, numuneId],
            o => new { Durum = o.GetInt16(0), Uyari = o.GetString(1) });
        return (s!.Durum, s.Uyari);
    }

    [Fact]
    public async Task Hemoliz_POTASYUMU_etkiler_SODYUMU_etkilemez()
    {
        if (!_olgu.Baglandi(nameof(Hemoliz_POTASYUMU_etkiler_SODYUMU_etkilemez))) return;
        var veri = _olgu.Gerekli();

        // Hemoliz 45: potasyumun uyarı eşiği 20, ret eşiği 40 → RET.
        //   Sodyumun teste özel eşiği 400 → etkilenmez.
        var (hastaId, istemId, numuneId) = await NumuneKurAsync(veri, hemoliz: 45);
        try
        {
            var k = await EtkiAsync(veri, "K", numuneId);
            Assert.Equal(2, k.Durum);
            Assert.Contains("Hemoliz", k.Uyari);
            Assert.Contains("yalancı yükseklik", k.Uyari);

            // TEK BİR "numune hemolizli" bayrağıyla bütün paneli reddetmek,
            //   çalışılabilir 20 testi de çöpe atmak olurdu.
            var na = await EtkiAsync(veri, "NA", numuneId);
            Assert.Equal(0, na.Durum);
            Assert.Equal("", na.Uyari);
        }
        finally { await TemizleAsync(veri, hastaId, istemId); }
    }

    [Fact]
    public async Task Uyari_ile_RET_esikleri_ayri()
    {
        if (!_olgu.Baglandi(nameof(Uyari_ile_RET_esikleri_ayri))) return;
        var veri = _olgu.Gerekli();

        // Hemoliz 25: potasyumda uyarı (20) aşıldı, ret (40) aşılmadı.
        var (hastaId, istemId, numuneId) = await NumuneKurAsync(veri, hemoliz: 25);
        try
        {
            var k = await EtkiAsync(veri, "K", numuneId);
            Assert.Equal(1, k.Durum);
            Assert.DoesNotContain("RET", k.Uyari);

            // AST'nin uyarı eşiği 30: aynı numunede henüz etkilenmez.
            Assert.Equal(0, (await EtkiAsync(veri, "AST", numuneId)).Durum);
        }
        finally { await TemizleAsync(veri, hastaId, istemId); }
    }

    [Fact]
    public async Task Olculmemis_indeks_etki_uretmez()
    {
        if (!_olgu.Baglandi(nameof(Olculmemis_indeks_etki_uretmez))) return;
        var veri = _olgu.Gerekli();

        // İndeks YOK (cihaz göndermemiş): "0 = temiz" varsaymak yanlış olurdu
        //   ama kural da uyduramaz - etki yok.
        var (hastaId, istemId, numuneId) = await NumuneKurAsync(veri);
        try
        {
            Assert.Equal(0, (await EtkiAsync(veri, "K", numuneId)).Durum);
        }
        finally { await TemizleAsync(veri, hastaId, istemId); }
    }

    [Fact]
    public async Task Birden_cok_indeks_EN_AGIR_sonucu_verir()
    {
        if (!_olgu.Baglandi(nameof(Birden_cok_indeks_EN_AGIR_sonucu_verir))) return;
        var veri = _olgu.Gerekli();

        // Kreatinin: ikter eşiği 15/35 (Jaffe girişimi), lipemi varsayılanı
        //   200/600. İkter 40 → ret; lipemi 250 → uyarı. En ağırı kazanır.
        var (hastaId, istemId, numuneId) = await NumuneKurAsync(veri, lipemi: 250,
                                                                ikter: 40);
        try
        {
            var kre = await EtkiAsync(veri, "KRE", numuneId);
            Assert.Equal(2, kre.Durum);
            Assert.Contains("İkter", kre.Uyari);
            Assert.Contains("yalancı düşüklük", kre.Uyari);
            // Uyarı düzeyindeki lipemi de metinde görünür: hangi girişimlerin
            //   olduğu raporda tam yazmalı.
            Assert.Contains("Lipemi", kre.Uyari);
        }
        finally { await TemizleAsync(veri, hastaId, istemId); }
    }

    [Fact]
    public async Task Varsayilan_esik_teste_ozel_esikle_EZILIR()
    {
        if (!_olgu.Baglandi(nameof(Varsayilan_esik_teste_ozel_esikle_EZILIR))) return;
        var veri = _olgu.Gerekli();

        // Hemoliz 100: varsayılan uyarı eşiği 60 → GLU etkilenir (varsayılan),
        //   sodyum teste özel 400 eşikle korunur.
        var (hastaId, istemId, numuneId) = await NumuneKurAsync(veri, hemoliz: 100);
        try
        {
            Assert.Equal(1, (await EtkiAsync(veri, "GLU", numuneId)).Durum);
            Assert.Equal(0, (await EtkiAsync(veri, "NA", numuneId)).Durum);
            // Potasyumda ret eşiği (40) çoktan aşıldı.
            Assert.Equal(2, (await EtkiAsync(veri, "K", numuneId)).Durum);
        }
        finally { await TemizleAsync(veri, hastaId, istemId); }
    }
}
