using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// MİKROBİYOLOJİ KURALLARI (436) — kademeli bildirim ve kültür özeti.
///
/// Kademeli bildirim (Akılcı Antibiyotik Kullanımı) hasta güvenliği kadar
/// halk sağlığı konusudur: geniş spektrumlu ajanı gereksiz yere raporlamak
/// klinisyeni karbapeneme yönlendirir ve direnç seçilimini hızlandırır.
/// Kural SQL'de yaşıyor; okumakla değil, çalıştırmakla doğrulanır.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class MikroTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public MikroTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    /// <summary>Testin kendi kültürünü kurar; id'leri geri verir.</summary>
    private static async Task<(int HastaId, int IstemId, int SatirId, int NumuneId,
                              int KulturId, int UremeId)>
        KurAsync(VeriKaynagi veri, short numuneTipi, CancellationToken iptal = default)
    {
        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'KIDR'", null, iptal);
        var organizmaId = await veri.TekDegerAsync<int>(
            "select id from public.lab_organizma where kod = 'ECOLI'", null, iptal);

        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, ad, soyad, hasta, sube_id)
            values ('TEST MIKRO HASTA', 'TEST', 'MIKRO', 1,
                    (select min(id) from public.sube))
            returning id
            """, null, iptal);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, istem_no, bolum, durum)
            values (@p0, 'TEST-MIKRO', 4, 1) returning id
            """, [hastaId], iptal);
        var barkod = await veri.TekDegerAsync<string>(
            "select public.fn_lab_barkod_uret(0)", null, iptal) ?? "";
        var numuneId = await veri.TekDegerAsync<int>("""
            insert into public.lab_numune (barkod, istem_id, hasta_id, numune_tipi,
                                           tup_tipi, durum)
            values (@p0, @p1, @p2, @p3, 6, 3) returning id
            """, [barkod, istemId, hastaId, numuneTipi], iptal);
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, numune_id,
                                                kod, ad, durum, sira)
            values (@p0, @p1, @p2, 'KIDR', 'İdrar kültürü', 2, 10) returning id
            """, [istemId, tetkikId, numuneId], iptal);
        var kulturId = await veri.TekDegerAsync<int>("""
            insert into public.lab_kultur (istem_satir_id, istem_id, numune_id,
                                           tetkik_id, hasta_id, durum)
            values (@p0, @p1, @p2, @p3, @p4, 3) returning id
            """, [satirId, istemId, numuneId, tetkikId, hastaId], iptal);
        var uremeId = await veri.TekDegerAsync<int>("""
            insert into public.lab_kultur_ureme (kultur_id, izolat_no, organizma_id,
                                                 koloni_sayisi, koloni_birim)
            values (@p0, 1, @p1, 100000, 'CFU/mL') returning id
            """, [kulturId, organizmaId], iptal);

        return (hastaId, istemId, satirId, numuneId, kulturId, uremeId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int hastaId, int istemId,
                                           int kulturId)
    {
        await veri.CalistirAsync("delete from public.lab_kultur where id = @p0", [kulturId]);
        await veri.CalistirAsync("delete from public.lab_istem_satir where istem_id = @p0",
                                 [istemId]);
        await veri.CalistirAsync("delete from public.lab_numune where istem_id = @p0",
                                 [istemId]);
        await veri.CalistirAsync("delete from public.lab_istem where id = @p0", [istemId]);
        await veri.CalistirAsync("delete from public.taraf where id = @p0", [hastaId]);
    }

    private static async Task AntibiyogramAsync(VeriKaynagi veri, int uremeId,
                                                params (string Kod, string Yorum)[] satirlar)
    {
        foreach (var (kod, yorum) in satirlar)
            await veri.CalistirAsync("""
                insert into public.lab_antibiyogram (ureme_id, antibiyotik_id, yorum,
                                                     standart, standart_surum)
                select @p0, a.id, @p2, 'EUCAST', '2026 v16'
                  from public.lab_antibiyotik a where upper(a.kod) = @p1
                """, [uremeId, kod, yorum]);
    }

    private static async Task<Dictionary<string, bool>> BildirimAsync(VeriKaynagi veri,
                                                                      int uremeId)
    {
        await veri.CalistirAsync("select public.fn_lab_antibiyogram_bildirim(@p0)",
                                 [uremeId]);
        var satirlar = await veri.ListeAsync("""
            select a.kod, g.bildir from public.lab_antibiyogram g
              join public.lab_antibiyotik a on a.id = g.antibiyotik_id
             where g.ureme_id = @p0
            """, [uremeId], o => (Kod: o.GetString(0), Bildir: o.GetInt16(1) == 1));
        return satirlar.ToDictionary(x => x.Kod, x => x.Bildir, StringComparer.Ordinal);
    }

    [Fact]
    public async Task Birinci_basamakta_duyarli_VARSA_genis_spektrum_GIZLENIR()
    {
        if (!_olgu.Baglandi(nameof(Birinci_basamakta_duyarli_VARSA_genis_spektrum_GIZLENIR)))
            return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, _, kulturId, uremeId) = await KurAsync(veri, 4);
        try
        {
            await AntibiyogramAsync(veri, uremeId,
                ("AMP", "R"), ("AMC", "S"), ("NIT", "S"),   // 1. basamak
                ("CIP", "R"), ("CRO", "S"),                 // 2. basamak
                ("MEM", "S"));                              // 3. basamak (karbapenem)

            var b = await BildirimAsync(veri, uremeId);

            Assert.True(b["AMP"]);
            Assert.True(b["AMC"]);
            Assert.True(b["NIT"]);
            // 1. basamakta duyarlı seçenek var: klinisyeni karbapeneme
            //   yönlendirmemek için üst basamaklar raporlanmaz.
            Assert.False(b["CIP"]);
            Assert.False(b["CRO"]);
            Assert.False(b["MEM"]);
        }
        finally { await TemizleAsync(veri, hastaId, istemId, kulturId); }
    }

    [Fact]
    public async Task Birinci_basamak_TAMAMEN_direncliyse_ikinci_basamak_ACILIR()
    {
        if (!_olgu.Baglandi(nameof(Birinci_basamak_TAMAMEN_direncliyse_ikinci_basamak_ACILIR)))
            return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, _, kulturId, uremeId) = await KurAsync(veri, 4);
        try
        {
            await AntibiyogramAsync(veri, uremeId,
                ("AMP", "R"), ("AMC", "R"), ("NIT", "R"), ("SXT", "R"),
                ("CIP", "R"), ("CRO", "S"),
                ("MEM", "S"));

            var b = await BildirimAsync(veri, uremeId);

            Assert.True(b["CRO"]);   // 2. basamak açıldı
            Assert.True(b["CIP"]);
            // 2. basamakta duyarlı (CRO) var: kısıtlı ajan hâlâ gizli.
            Assert.False(b["MEM"]);
        }
        finally { await TemizleAsync(veri, hastaId, istemId, kulturId); }
    }

    [Fact]
    public async Task Iki_basamak_da_direncliyse_KISITLI_ajan_raporlanir()
    {
        if (!_olgu.Baglandi(nameof(Iki_basamak_da_direncliyse_KISITLI_ajan_raporlanir)))
            return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, _, kulturId, uremeId) = await KurAsync(veri, 4);
        try
        {
            await AntibiyogramAsync(veri, uremeId,
                ("AMP", "R"), ("AMC", "R"), ("NIT", "R"),
                ("CIP", "R"), ("CRO", "R"), ("TZP", "R"),
                ("MEM", "S"));

            var b = await BildirimAsync(veri, uremeId);

            // Başka seçenek kalmadı: karbapenem artık raporlanmalı.
            Assert.True(b["MEM"]);
        }
        finally { await TemizleAsync(veri, hastaId, istemId, kulturId); }
    }

    [Fact]
    public async Task Kombinasyon_ajani_UST_BASAMAGI_KAPATMAZ()
    {
        if (!_olgu.Baglandi(nameof(Kombinasyon_ajani_UST_BASAMAGI_KAPATMAZ))) return;
        var veri = _olgu.Gerekli();

        // MRSA bakteriyemisi: tüm 1. basamak dirençli, 2. basamakta yalnız
        //   GENTAMİSİN duyarlı. Aminoglikozid tek başına bakteriyemi tedavisi
        //   DEĞİLDİR - vankomisin gizlenirse hasta tedavisiz kalır (db/437).
        var (hastaId, istemId, _, _, kulturId, uremeId) = await KurAsync(veri, 1);
        try
        {
            await AntibiyogramAsync(veri, uremeId,
                ("PEN", "R"), ("OXA", "R"), ("ERY", "R"), ("CLI", "R"),
                ("GEN", "S"),
                ("VAN", "S"), ("LNZ", "S"));

            var b = await BildirimAsync(veri, uremeId);

            Assert.True(b["GEN"]);   // kendi basamağında raporlanır
            Assert.True(b["VAN"]);   // ama üst basamağı kapatmaz
            Assert.True(b["LNZ"]);
        }
        finally { await TemizleAsync(veri, hastaId, istemId, kulturId); }
    }

    [Fact]
    public async Task Uriner_ajan_IDRAR_DISI_numunede_raporlanmaz()
    {
        if (!_olgu.Baglandi(nameof(Uriner_ajan_IDRAR_DISI_numunede_raporlanmaz))) return;
        var veri = _olgu.Gerekli();

        // Numune tipi 1 = serum/kan: nitrofurantoin idrar dışında etkisizdir,
        //   raporlanması tedaviyi yanlış yönlendirir.
        var (hastaId, istemId, _, _, kulturId, uremeId) = await KurAsync(veri, 1);
        try
        {
            await AntibiyogramAsync(veri, uremeId,
                ("NIT", "S"), ("FOS", "S"), ("AMC", "S"));

            var b = await BildirimAsync(veri, uremeId);

            Assert.False(b["NIT"]);
            Assert.False(b["FOS"]);
            Assert.True(b["AMC"]);
        }
        finally { await TemizleAsync(veri, hastaId, istemId, kulturId); }
    }

    [Fact]
    public async Task Uzman_karari_kademeli_bildirimi_EZMEZ()
    {
        if (!_olgu.Baglandi(nameof(Uzman_karari_kademeli_bildirimi_EZMEZ))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, _, kulturId, uremeId) = await KurAsync(veri, 4);
        try
        {
            await AntibiyogramAsync(veri, uremeId, ("NIT", "S"), ("MEM", "S"));

            // Uzman karbapenemi bilinçli olarak raporlamak istedi (kaynak 4).
            await veri.CalistirAsync("""
                update public.lab_antibiyogram g
                   set kaynak = 4, bildir = 1, degistirme_neden = 'Klinik istek'
                  from public.lab_antibiyotik a
                 where a.id = g.antibiyotik_id and g.ureme_id = @p0
                   and upper(a.kod) = 'MEM'
                """, [uremeId]);

            var b = await BildirimAsync(veri, uremeId);

            // Kural klinik kararın yerine geçmez: uzmanın açtığı satır kapanmaz.
            Assert.True(b["MEM"]);
            Assert.True(b["NIT"]);
        }
        finally { await TemizleAsync(veri, hastaId, istemId, kulturId); }
    }

    [Fact]
    public async Task Kultur_ozeti_UREME_YOKU_da_yazar()
    {
        if (!_olgu.Baglandi(nameof(Kultur_ozeti_UREME_YOKU_da_yazar))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, istemId, _, _, kulturId, uremeId) = await KurAsync(veri, 4);
        try
        {
            var ozet = await veri.TekDegerAsync<string>(
                "select public.fn_lab_kultur_ozet(@p0)", [kulturId]);
            // Sayı biçimi kurulumdan bağımsız olmalı: "100.000 CFU/mL".
            Assert.Equal("Escherichia coli — 100.000 CFU/mL", ozet);

            // İzolat yoksa "Üreme yok": kültür sonuçsuz kapanmamalı.
            await veri.CalistirAsync(
                "delete from public.lab_kultur_ureme where id = @p0", [uremeId]);
            Assert.Equal("Üreme yok", await veri.TekDegerAsync<string>(
                "select public.fn_lab_kultur_ozet(@p0)", [kulturId]));
        }
        finally { await TemizleAsync(veri, hastaId, istemId, kulturId); }
    }
}
