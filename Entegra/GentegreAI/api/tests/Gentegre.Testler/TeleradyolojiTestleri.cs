using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// TELERADYOLOJİ ÇEKİRDEĞİ (797).
///
/// Kullanıcı: *"teleradyolojiyi yap"* · tasarım
/// `Ekranlar/Teleradyoloji/telerad_sureci.html`.
///
/// Okuma işi iç akışın aynısıdır; teleradyolojiye özel olan işin ÇEVRESİDİR -
/// hangi kurum, hangi sözleşme, SLA ne zaman doluyor, kime atandı. Bu testler
/// o çevrenin kurallarını korur; hepsi VERİTABANINDA (tetik), çünkü istek
/// ekrandan da, DICOM alımından da, içe aktarımdan da açılabilir.
/// </summary>
public sealed class TeleradyolojiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Kendi kurumunu ve sözleşmesini açan deneme kurulumu.</summary>
    private static async Task<(int Kurum, int Sozlesme)> KurulumAsync(
        NpgsqlConnection b, NpgsqlTransaction t, int slaAcil = 30, int slaRutin = 1440)
    {
        // TEST KENDI CARISINI ACAR: var olan bir cariyi odunc almak iki
        //   tuzak birden uretti - "en yenisi" baska sinifin geri aldigi satir
        //   olup FK ihlali verdi, "en eskisi" ise dev verisindeki gercek
        //   telerad kurumuyla unique (taraf_id) catisti. Kendi satirimiz
        //   geri alinca iz birakmaz.
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);
        var taraf = await b.TekDegerAsync<int>("""
            insert into public.taraf (unvan, kod, musteri, sube_id)
            values ('TELERAD TEST KURUMU', 'TRTEST', 1, @p0) returning id
            """, t, [sube], CancellationToken.None);
        var kurum = await b.TekDegerAsync<int>("""
            insert into public.telerad_kurum (taraf_id, yon, dicom_ae_title)
            values (@p0, 1, '') returning id
            """, t, [taraf], CancellationToken.None);
        var sozlesme = await b.TekDegerAsync<int>("""
            insert into public.telerad_sozlesme
                   (kurum_id, baslangic, ucret_modeli, sla_acil_dk, sla_oncelikli_dk,
                    sla_rutin_dk, durum)
            values (@p0, current_date - 10, 1, @p1, 240, @p2, 1) returning id
            """, t, [kurum, slaAcil, slaRutin], CancellationToken.None);
        return (kurum, sozlesme);
    }

    private static Task<int> IstekAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int kurum, short oncelik, string erisim, int gecenDk = 0, short goruntu = 1)
        => b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, goruntu_durum, cekim_zamani, gelis_zamani)
            values (@p0, @p1, @p2, @p3, now() - make_interval(mins => @p4),
                    now() - make_interval(mins => @p4))
            returning id
            """, t, [kurum, erisim, oncelik, goruntu, gecenDk], CancellationToken.None);

    [Fact]
    public async Task Istek_numarasi_ve_SOZLESME_kendiliginden()
    {
        if (!_olgu.Baglandi(nameof(Istek_numarasi_ve_SOZLESME_kendiliginden))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, sozlesme) = await KurulumAsync(b, t);
        var id = await IstekAcAsync(b, t, kurum, 3, "T-001");

        var satir = await b.ListeAsync(
            "select istek_no, sozlesme_id, sla_dk from public.telerad_istek where id = @p0",
            t, [id], o => (No: o.GetString(0), Sozlesme: o.GetInt32(1), Sla: o.GetInt32(2)),
            CancellationToken.None);

        // TR-yyyy/nnnnn · sözleşme kurumun O TARİHTE aktif olanından çözülür.
        Assert.StartsWith("TR-" + DateTime.Today.Year + "/", satir[0].No);
        Assert.Equal(sozlesme, satir[0].Sozlesme);
        // SLA ÖNCELİĞE GÖRE sözleşmeden kopyalanır: acil 30 dk.
        Assert.Equal(30, satir[0].Sla);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task SLA_GORUNTU_geldigi_an_baslar()
    {
        if (!_olgu.Baglandi(nameof(SLA_GORUNTU_geldigi_an_baslar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kurum isteği akşam açıp görüntüyü sabah gönderebilir; söz verdiğimiz
        //   süre OKUMAYA BAŞLAYABİLDİĞİMİZ andan işler.
        var (kurum, _) = await KurulumAsync(b, t);
        var id = await IstekAcAsync(b, t, kurum, 3, "T-002", gecenDk: 35);

        var satir = await b.ListeAsync(
            "select kalan_dk, sla_riskli, durum from public.v_telerad_istek where id = @p0",
            t, [id], o => (Kalan: o.GetInt32(0), Riskli: o.GetInt16(1), Durum: o.GetInt16(2)),
            CancellationToken.None);

        Assert.True(satir[0].Kalan < 0, "35 dakika geçmiş acil istek SLA'yı aşmış olmalı.");
        Assert.Equal((short)1, satir[0].Riskli);
        // Görüntü tamam -> "sırada" (1 -> 2): durumu ekran değil tetik yürütür.
        Assert.Equal((short)2, satir[0].Durum);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Atama_GECMISI_kendiliginden_yazilir()
    {
        if (!_olgu.Baglandi(nameof(Atama_GECMISI_kendiliginden_yazilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, _) = await KurulumAsync(b, t);
        var id = await IstekAcAsync(b, t, kurum, 1, "T-003");
        var radyolog = await b.TekDegerAsync<int>(
            "select id from public.taraf where personel = 1 order by id limit 1",
            t, [], CancellationToken.None);
        Assert.True(radyolog > 0, "Denemede kullanilacak personel kaydi yok.");

        await b.CalistirAsync(
            "update public.telerad_istek set atanan_radyolog_id = @p1, degistiren = 7 where id = @p0",
            t, [id, radyolog], CancellationToken.None);

        var durum = await b.TekDegerAsync<short>(
            "select durum from public.telerad_istek where id = @p0", t, [id],
            CancellationToken.None);
        Assert.Equal((short)3, durum);              // sırada -> atandı

        var iz = await b.ListeAsync(
            "select radyolog_id, atayan_id, neden from public.telerad_atama where istek_id = @p0",
            t, [id], o => (Radyolog: o.GetInt32(0), Atayan: o.GetInt32(1), Neden: o.GetInt16(2)),
            CancellationToken.None);
        Assert.Single(iz);
        Assert.Equal(radyolog, iz[0].Radyolog);
        Assert.Equal(7, iz[0].Atayan);
        Assert.Equal((short)2, iz[0].Neden);        // elle atama

        // ATAMA KALKINCA SIRAYA DÖNER: "atandı" ama kimsede olmayan iş,
        //   çalışma listesinde görünmeyen iştir.
        await b.CalistirAsync(
            "update public.telerad_istek set atanan_radyolog_id = null where id = @p0",
            t, [id], CancellationToken.None);
        Assert.Equal((short)2, await b.TekDegerAsync<short>(
            "select durum from public.telerad_istek where id = @p0", t, [id],
            CancellationToken.None));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Onayda_SLA_asimi_KARARI_verilir()
    {
        if (!_olgu.Baglandi(nameof(Onayda_SLA_asimi_KARARI_verilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, _) = await KurulumAsync(b, t);
        var gec = await IstekAcAsync(b, t, kurum, 3, "T-004", gecenDk: 45);   // acil, 30 dk
        var zamaninda = await IstekAcAsync(b, t, kurum, 1, "T-005");          // rutin, 1440 dk

        foreach (var id in new[] { gec, zamaninda })
            await b.CalistirAsync("update public.telerad_istek set durum = 6 where id = @p0",
                t, [id], CancellationToken.None);

        // Onay zamanı ve aşım kararı TEK yerde (tetik) veriliyor.
        Assert.Equal((short)1, await b.TekDegerAsync<short>(
            "select sla_asildi from public.telerad_istek where id = @p0", t, [gec],
            CancellationToken.None));
        Assert.Equal((short)0, await b.TekDegerAsync<short>(
            "select sla_asildi from public.telerad_istek where id = @p0", t, [zamaninda],
            CancellationToken.None));

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Okuma_ve_teslim_ZAMANLARI_tetikte_dogar()
    {
        if (!_olgu.Baglandi(nameof(Okuma_ve_teslim_ZAMANLARI_tetikte_dogar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // 798 KARTI BU UC ALANI "salt okunur - tetik yaziyor" diye isaretledi
        //   ama 797 tetigi yalnizca onay zamanini damgaliyordu: alanlari YAZAN
        //   KIMSE YOKTU. 799 damgalari tetige tasidi.
        var (kurum, _) = await KurulumAsync(b, t);
        var id = await IstekAcAsync(b, t, kurum, 1, "T-006");

        await b.CalistirAsync("update public.telerad_istek set durum = 4 where id = @p0",
            t, [id], CancellationToken.None);
        var okuma = await b.ListeAsync(
            "select okuma_bas from public.telerad_istek where id = @p0", t, [id],
            o => o.IsDBNull(0) ? (DateTime?)null : o.GetDateTime(0), CancellationToken.None);
        Assert.NotNull(okuma[0]);

        // OKUMA BASLANGICI ILK ANDIR: is taslaga/ek goruntuye donup geri
        //   gelirse damga degismemeli - yoksa bekleme suresi silinir.
        var ilk = okuma[0];
        await b.CalistirAsync("update public.telerad_istek set durum = 8 where id = @p0",
            t, [id], CancellationToken.None);
        await b.CalistirAsync("update public.telerad_istek set durum = 4 where id = @p0",
            t, [id], CancellationToken.None);
        Assert.Equal(ilk, (await b.ListeAsync(
            "select okuma_bas from public.telerad_istek where id = @p0", t, [id],
            o => (DateTime?)o.GetDateTime(0), CancellationToken.None))[0]);

        // TESLIM: durum 7 damgayi ve teslim durumunu birlikte dogurur -
        //   "teslim edildi" yazip zamani bos birakmak cevapsiz soru uretirdi.
        await b.CalistirAsync("update public.telerad_istek set durum = 7 where id = @p0",
            t, [id], CancellationToken.None);
        var teslim = await b.ListeAsync("""
            select teslim_durum, teslim_zamani is not null
              from public.telerad_istek where id = @p0
            """, t, [id], o => (Durum: o.GetInt16(0), Damga: o.GetBoolean(1)),
            CancellationToken.None);
        Assert.Equal((short)1, teslim[0].Durum);
        Assert.True(teslim[0].Damga, "Teslim zamani damgalanmadi.");

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Ayni_erisim_numarasi_IKI_KEZ_girilemez()
    {
        if (!_olgu.Baglandi(nameof(Ayni_erisim_numarasi_IKI_KEZ_girilemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kurumun PACS'i aynı çalışmayı tekrar gönderirse ikinci KAYIT değil
        //   aynı istek güncellenmeli - yoksa çalışma listesi ikizlenir ve iş
        //   iki radyologa düşer.
        var (kurum, _) = await KurulumAsync(b, t);
        await IstekAcAsync(b, t, kurum, 1, "ACC-9");

        await b.CalistirAsync("savepoint sp_ikiz", t, [], CancellationToken.None);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => IstekAcAsync(b, t, kurum, 1, "ACC-9"));
        Assert.Equal("23505", h.SqlState);          // unique ihlali
        await b.CalistirAsync("rollback to savepoint sp_ikiz", t, [], CancellationToken.None);

        await t.RollbackAsync();
    }

    [Fact]
    public void Calisma_listesi_ACIL_ve_SLA_sirasinda()
    {
        // Çalışma listesinin sırası bir tercih değil işin kendisidir: radyolog
        //   listenin başından alır. Acil önce, sonra SLA'sı dolmak üzere olan.
        var kaynak = KaynakKatalogu.Bul("telerad-istek");
        Assert.NotNull(kaynak);
        Assert.Contains("oncelik desc", kaynak!.VarsayilanSirala);
        Assert.Contains("sla_bitis", kaynak.VarsayilanSirala);

        // Kalan dakika SUNUCUDA hesaplanır (görünümden gelir): iki ekran iki
        //   farklı "şimdi" kullanırsa liste kendi içinde çelişir.
        Assert.Contains(kaynak.Kolonlar, k => k.Ad == "kalanDk");
        Assert.Contains(kaynak.Kolonlar, k => k.Ad == "slaRiskli");
    }

    [Fact]
    public void Portal_kurumu_KENDI_isteklerini_gorur()
    {
        // Gönderen kurum portalı (794/795): kurum bağı `telerad_kurum.taraf_id`
        //   üzerinden - portal kullanıcısı kurumun CARİ kaydıdır.
        var kaynak = KaynakKatalogu.Bul("telerad-istek")!;
        Assert.NotNull(kaynak.PortalKosullari);
        Assert.Contains("kurum_taraf_id", kaynak.PortalKosullari![PortalKapsam.DisKurum]);
        // Hasta bu listede işi yok: portal türü 3 açıkça KAPALI.
        Assert.Equal("false", kaynak.PortalKosullari[PortalKapsam.Hasta]);
    }
}

/// <summary>
/// TELERADYOLOJİ İSTEK KARTI (798).
///
/// Kullanıcı: *"teleradyoloji istek kartını da yap"* - listede çift tık hiçbir
/// şey açmıyordu.
///
/// Kart işin ÇEVRESİNİ düzenler (kurum, tetkik, görüntü, atama, teslim);
/// rapor mevcut radyoloji ekranıyla yazılır. Hesaplanan alanlar salt okunur:
/// ekrandan yazılabilir olsalardı aynı sayıyı tetik ve ekran iki ayrı yerden
/// hesaplardı.
/// </summary>
public sealed class TeleradyolojiKartTestleri
{
    private static KartTanimi Kart()
    {
        var k = KartKatalogu.Bul("telerad-istek");
        Assert.NotNull(k);
        return k!;
    }

    [Fact]
    public void Hesaplanan_alanlar_SALT_OKUNUR()
    {
        var kart = Kart();
        foreach (var ad in new[] { "istekNo", "slaDk", "slaBitis", "slaAsildi",
                                   "okumaBas", "onayZamani", "teslimZamani",
                                   "teslimDurum", "teslimHata", "sozlesmeId" })
        {
            var alan = kart.Alanlar.FirstOrDefault(a => a.Ad == ad);
            Assert.True(alan is not null, $"Kartta \"{ad}\" alani yok.");
            Assert.False(alan!.Yazilabilir, $"\"{ad}\" tetikle yaziliyor, ekrandan degil.");
        }
    }

    [Fact]
    public void Kurum_secimi_CARI_listesi_degil()
    {
        // Her cari teleradyoloji kurumu degildir; cari listesinden sectirmek
        //   sessizce kirik kayit uretirdi (798 lookup).
        var alan = kart_kurum();
        Assert.Equal("public.v_telerad_kurum_lookup", alan.KodTablosu);
        Assert.True(alan.Zorunlu, "Kurum olmadan istek anlamsiz.");

        static KartAlani kart_kurum()
        {
            var a = Kart().Alanlar.FirstOrDefault(x => x.Ad == "kurumId");
            Assert.NotNull(a);
            return a!;
        }
    }

    [Fact]
    public void Atama_gecmisi_SALT_OKUNUR_detay()
    {
        // Satirlari tetik yaziyor (tg_telerad_atama_izi); elle satir eklemek
        //   "kim atadi" sorusunun cevabini uydurulabilir kilardi.
        var detay = Kart().Detaylar.FirstOrDefault(d => d.Ad == "atamalar");
        Assert.NotNull(detay);
        Assert.True(detay!.SaltOkunur);
        Assert.Equal("public.telerad_atama", detay.Tablo);
        Assert.All(detay.Alanlar, a => Assert.False(a.Yazilabilir));
    }

    [Fact]
    public void Kart_PORTAL_kapsamini_tasir()
    {
        // Liste suzulup kart serbest kalirsa kapsam bir gorunum suslemesine
        //   doner: id'yi bilen portal kullanicisi baskasinin istegini acardi.
        var kart = Kart();
        Assert.NotNull(kart.PortalKosullari);
        Assert.Contains("telerad_kurum", kart.PortalKosullari![PortalKapsam.DisKurum]);
        Assert.Contains("atanan_radyolog_id", kart.PortalKosullari[PortalKapsam.DisDoktor]);
        Assert.Equal("false", kart.PortalKosullari[PortalKapsam.Hasta]);
    }

    [Fact]
    public void Her_alan_bir_gruba_ait()
    {
        // GRUPSUZ ALAN KENDINE SEKME ACAR: web kartSekmeleri.ts grupsuz
        //   alanlari "Genel" kovasina atiyor - ekleyen/ekleme tarihi kartta
        //   dururken kullanicinin gordugu sey iki denetim alanindan ibaret
        //   bos bir sekmeydi. Alan ya bir gruba girer ya karttan cikar.
        var grupsuz = Kart().Alanlar
            .Where(a => a.Ad != "id" && string.IsNullOrEmpty(a.Grup))
            .Select(a => a.Ad).ToArray();
        Assert.True(grupsuz.Length == 0,
            "Grupsuz alan(lar) bos \"Genel\" sekmesi acar: " + string.Join(", ", grupsuz));
    }

    [Fact]
    public void Yon_kartta_secilebilir()
    {
        // Gelen is bizim SLA'miz ve bizim faturamiz, giden is onlarin;
        //   listede iki is ayni satir gibi durdugu icin kartta ayrilmali.
        var alan = Kart().Alanlar.FirstOrDefault(a => a.Ad == "yon");
        Assert.True(alan is not null, "Kartta \"yon\" alani yok.");
        Assert.True(alan!.Yazilabilir);
        Assert.NotNull(alan.SabitKodlar);
        Assert.True(alan.SabitKodlar!.ContainsKey("1") && alan.SabitKodlar.ContainsKey("2"));
    }

    [Fact]
    public void Kart_ve_liste_AYNI_yetkide()
    {
        // Kart serbest kalirsa liste suzmesi anlamsizlasir.
        Assert.Equal(KaynakKatalogu.Bul("telerad-istek")!.YetkiKodu, Kart().YetkiKodu);
    }

    [Fact]
    public void Calisma_listesinin_ARAC_CUBUGU_var()
    {
        // 797'de `telerad.ata` / `telerad.teslim` yetkileri rollere dagitildi
        //   ama hicbir aksiyon onlari kullanmiyordu: ekranda arac cubugu yoktu,
        //   istek ne acilabiliyor ne de akis ilerletilebiliyordu (799).
        var ekran = AksiyonKatalogu.Ekran("telerad-istek-liste");
        Assert.True(ekran is not null, "Teleradyoloji calisma listesinin aksiyon ekrani yok.");
        foreach (var kod in new[] { "telerad.yeni", "telerad.duzenle", "telerad.ata",
                                    "telerad.oku", "telerad.teslim", "telerad.sil" })
            Assert.Contains(ekran!, a => a.Kod == kod);

        // DAGITIM VE TESLIM AYRI YETKI: okuyan herkes isi dagitamaz.
        Assert.Equal("telerad.ata",
            ekran!.First(a => a.Kod == "telerad.ata").AksiyonYetkisi);
        Assert.Equal("telerad.teslim",
            ekran.First(a => a.Kod == "telerad.teslim").AksiyonYetkisi);

        // Akis dugmeleri KAYIT ISTER: secim olmadan "teslim et" anlamsiz.
        Assert.All(ekran.Where(a => a.Kod != "telerad.yeni" && a.Grup == "telerad"),
                   a => Assert.True(a.KayitGerekir, a.Kod + " kayit secilmeden calisiyor."));
    }
}

/// <summary>
/// TELERADYOLOJİ KURUM VE SÖZLEŞME KARTLARI (800).
///
/// Kullanıcı: *"kurum ve sözleşme kartlarını da yap"*. 797'de iki liste ekranı
/// vardı ama kartı yoktu: iş ilişkisi ekrandan hiç kurulamıyordu.
///
/// İstek kartı işin KENDİSİ, bu ikisi ŞARTLARI: kurum "kiminle, hangi kanalla",
/// sözleşme "hangi dönem, hangi ücret, ne kadar sürede".
/// </summary>
public sealed class TeleradyolojiSartKartlariTestleri
{
    private static KartTanimi Kart(string ad)
    {
        var k = KartKatalogu.Bul(ad);
        Assert.True(k is not null, $"\"{ad}\" karti yok.");
        return k!;
    }

    [Fact]
    public void Iki_kart_da_LISTEYLE_ayni_yetkide()
    {
        // Kart serbest kalirsa liste suzmesi anlamsizlasir.
        foreach (var ad in new[] { "telerad-kurum", "telerad-sozlesme" })
            Assert.Equal(KaynakKatalogu.Bul(ad)!.YetkiKodu, Kart(ad).YetkiKodu);
    }

    [Fact]
    public void Her_alan_bir_gruba_ait()
    {
        // Grupsuz alan kendine bos bir "Genel" sekmesi acar (799).
        foreach (var ad in new[] { "telerad-kurum", "telerad-sozlesme" })
        {
            var grupsuz = Kart(ad).Alanlar
                .Where(a => a.Ad != "id" && string.IsNullOrEmpty(a.Grup))
                .Select(a => a.Ad).ToArray();
            Assert.True(grupsuz.Length == 0,
                $"{ad}: grupsuz alan(lar) {string.Join(", ", grupsuz)}");
        }
    }

    [Fact]
    public void Kurum_CARIYE_baglanir()
    {
        // Teleradyoloji kurumu ayri bir "musteri" DEGIL, carinin bir
        //   ozelligidir (797): fatura, tahsilat ve bakiye zaten orada.
        var kart = Kart("telerad-kurum");
        var taraf = kart.Alanlar.First(a => a.Ad == "tarafId");
        Assert.True(taraf.Zorunlu, "Carisi olmayan kurum kaydi anlamsiz.");
        Assert.Equal("public.v_cari_lookup", taraf.KodTablosu);
        // Yeni kayit cari secimiyle baslar - once "hangi cari" sorulur.
        Assert.Equal("tarafId", kart.AcilistaTarafSecimi);
    }

    [Fact]
    public void Kurumun_SOZLESMELERI_salt_okunur()
    {
        // Yazma yeri sozlesme kartidir: iki yerden yazilabilseydi ayni donem
        //   iki farkli SLA ile kaydedilebilirdi. Burada durmasi "kurum var ama
        //   sozlesmesi yok" eksikligini kurumun kartinda gorunur kiliyor.
        var detay = Kart("telerad-kurum").Detaylar!.First(d => d.Ad == "sozlesmeler");
        Assert.True(detay.SaltOkunur);
        Assert.Equal("public.telerad_sozlesme", detay.Tablo);
        Assert.All(detay.Alanlar, a => Assert.False(a.Yazilabilir));
    }

    [Fact]
    public void Sozlesme_SUBESIZ_ve_SLA_varsayilanli()
    {
        var kart = Kart("telerad-sozlesme");
        // Sozlesme kurumun sozlesmesidir, subenin degil - tabloda sube_id de
        //   yok (797). Sube kolonu yazmak var olmayan kolona INSERT ederdi.
        Assert.Null(kart.SubeKolonu);

        // BOS SOZLESME "0 DAKIKA" SOZU VERMESIN: 0 SLA'yi tumden kapatir
        //   (tetik `sla_dk = 0` iken sozlesmeden kopyalar), yani sure sozu
        //   olmayan bir sozlesme sessizce dogardi.
        // ANAHTAR ALAN ADI, KOLON ADI DEGIL: varsayilanlar `degerler`
        //   sozlugune alan adiyla yaziliyor (KartDeposu.EkleAsync) - kolon
        //   adiyla yazilan varsayilan hicbir alana denk gelmez, sessizce
        //   kaybolurdu.
        var v = kart.YeniKayitVarsayilanlari!;
        Assert.All(v.Keys, k => Assert.True(kart.Alan(k) is not null,
            $"Varsayilan \"{k}\" kartta bir alan degil."));
        Assert.Equal(30, v["slaAcilDk"]);
        Assert.Equal(240, v["slaOncelikliDk"]);
        Assert.Equal(1440, v["slaRutinDk"]);
        // Yeni sozlesme TASLAK dogar: aktif olan istege kopyalanir (797),
        //   yarim doldurulmus sozlesme fiyat ve SLA sozu vermemeli.
        Assert.Equal((short)0, v["durum"]);

        // Kurum secimi CARI listesi degil - her cari telerad kurumu degildir.
        Assert.Equal("public.v_telerad_kurum_lookup",
                     kart.Alanlar.First(a => a.Ad == "kurumId").KodTablosu);
    }

    [Fact]
    public void Iki_listenin_de_ARAC_CUBUGU_var()
    {
        foreach (var (ekranAd, onEk) in new[]
                 { ("telerad-kurum-liste", "telerad-kurum"),
                   ("telerad-sozlesme-liste", "telerad-sozlesme") })
        {
            var ekran = AksiyonKatalogu.Ekran(ekranAd);
            Assert.True(ekran is not null, $"{ekranAd} aksiyon ekrani yok.");
            foreach (var son in new[] { ".yeni", ".duzenle", ".sil" })
                Assert.Contains(ekran!, a => a.Kod == onEk + son);
        }
    }
}
