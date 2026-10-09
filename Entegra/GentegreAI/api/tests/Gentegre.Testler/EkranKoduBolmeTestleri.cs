using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Testler;

/// <summary>
/// MENÜ YERİNE GÖRE BÖLÜNEN EKRAN KODLARI (1003) — kullanıcı 09.10.2026:
/// *"menü koduyla yetki matrisi kodları aynı olmalı"*, *"A grubunun hepsini böl"*.
///
/// Farklı menü gruplarındaki ekranları birlikte açan 8 kod bölündü. Testler
/// veritabanı istemez; iddialar yetki setinin kararıdır:
///   1. Ortak kaynaklı ekran kodu eski kodun SUNUCU kapısını açar
///      (Tedarikçiler `cari` kaynağını okur).
///   2. Ama belge KÜMESİ tam eşleşir: kurum faturası yetkisi başvuruyu açmaz.
///   3. Kendi kaynağı olan ekran eski koda dönmez (dış doktor `personel` açmaz).
///   4. Her bölünmüş kod bir kopya kaynağına bağlı (göç ve şablon bunu izler).
/// </summary>
public sealed class EkranKoduBolmeTestleri
{
    private static YetkiSeti Set(params string[] kodlar)
        => new(1, kodlar.Select(k => new YetkiKaydi(k, 0, true, true, true, false)), []);

    [Fact]
    public void Tedarikci_kodu_cari_kaynak_kapisini_acar()
    {
        var s = Set("cari.tedarikci");
        Assert.True(s.Var("cari", Islem.Gor));
        Assert.True(s.Var("cari", Islem.Degistir));
        Assert.False(s.Var("cari", Islem.Sil));      // kopyalanan hak kadar
        Assert.False(s.VarTam("cari", Islem.Gor));   // kodun kendisi verilmedi
    }

    [Fact]
    public void Grup_dokumu_dokum_kapisini_acar()
    {
        Assert.True(Set("dokum.finans").Var("dokum", Islem.Gor));
        Assert.True(Set("medula.kabul").Var("medula.provizyon", Islem.Ekle));
    }

    [Fact]
    public void Kurum_faturasi_belge_kaynagini_acar_basvuru_kumesini_acmaz()
    {
        var s = Set("belge.kurum_fatura");
        Assert.True(s.Var("belge", Islem.Gor));
        Assert.False(s.VarTam("belge", Islem.Gor));
        var kumeler = KaynakKatalogu.BelgeYetkiKodlari
            .Where(k => s.VarTam(k, Islem.Gor))
            .Select(KaynakKatalogu.BelgeKumesi).ToList();
        Assert.Equal([KaynakKatalogu.BelgeKumeKurumFatura], kumeler);
        Assert.Equal([15], KaynakKatalogu.BelgeKumesininTurleri(KaynakKatalogu.BelgeKumeKurumFatura));
        Assert.Equal([11], KaynakKatalogu.BelgeKumesininTurleri(KaynakKatalogu.BelgeKumeAlisFatura));
    }

    [Fact]
    public void Kendi_kaynagi_olan_ekran_eski_kodu_acmaz()
    {
        Assert.False(Set("dis_doktor").Var("personel", Islem.Gor));
        Assert.False(Set("eczane.miad").Var("stok", Islem.Gor));
        Assert.False(Set("kayit_kabul.ayar").Var("ayar", Islem.Degistir));
        Assert.Equal("dis_doktor", KaynakKatalogu.Bul("dis-hekim")!.YetkiKodu);
        Assert.Equal("eczane.miad", KaynakKatalogu.Bul("eczaneMiad")!.YetkiKodu);
    }

    [Fact]
    public void Her_bolunmus_kodun_kopya_kaynagi_var()
    {
        foreach (var k in new[] { "belge.kurum_fatura", "belge.alis_fatura", "eczane.miad",
                                  "kayit_kabul.ayar", "cari.tedarikci", "dis_doktor", "medula.kabul" })
            Assert.NotNull(EkranKodlari.KopyaKaynagi(k));
        Assert.Equal(28, EkranKodlari.DokumKodlari.Count);
        Assert.All(EkranKodlari.DokumKodlari, k => Assert.Equal("dokum", EkranKodlari.KopyaKaynagi(k)));
        Assert.Null(EkranKodlari.KopyaKaynagi("belge.satis"));
    }

    // ---------------------------------------------- tedarikçi satır süzgeci ---
    //   Kullanıcı 09.10.2026: "tedarikçi satır süzgecini de ekle".

    [Fact]
    public void Yalniz_tedarikci_kodu_cari_kaynagina_satir_kosulu_koyar()
    {
        var s = Set("cari.tedarikci");
        var k = EkranKodlari.Kisit("cari", kod => s.VarTam(kod, Islem.Gor));
        Assert.NotNull(k);
        Assert.Equal("(t.tedarikci = 1)", k!.Kosul);
        // Kişi listesi de yalnız tedarikçiye bağlı kişiler.
        Assert.Contains("u.tedarikci = 1", EkranKodlari.Kisit("kisi", kod => s.VarTam(kod, Islem.Gor))!.Kosul);
    }

    [Fact]
    public void Cari_yetkisi_olan_kisitlanmaz()
    {
        var s = Set("cari", "cari.tedarikci");
        Assert.Null(EkranKodlari.Kisit("cari", kod => s.VarTam(kod, Islem.Gor)));
        // Kısıtsız kaynak hiç etkilenmez.
        Assert.Null(EkranKodlari.Kisit("stok", kod => s.VarTam(kod, Islem.Gor)));
    }

    [Fact]
    public void Satir_kosulu_satir_ve_sayim_sorgusuna_girer()
    {
        var cari = KaynakKatalogu.Bul("cari")!;
        var u = new SorguUretici(cari) { EkranKosulu = "t.tedarikci = 1" };
        var satir = u.Satirlar(new Cekirdek.Sozlesme.ListeIstegi(), cari.Kolonlar.Take(3).ToList(), null, null, 1).Sql;
        var sayim = u.Sayim(new Cekirdek.Sozlesme.ListeIstegi(), null, null, null).Sql;
        Assert.Contains("(t.tedarikci = 1)", satir);
        Assert.Contains("(t.tedarikci = 1)", sayim);
    }

    // ------------------------------------------ 1004 aynı grup (aşama 1) ---
    //   Kullanıcı 09.10.2026: "B grubunu da böl", "1 ile başla, sonra 2".

    [Fact]
    public void Ayni_grup_ekran_kodu_eski_kapiyi_acar_ve_kopya_kaynagi_eski_kod()
    {
        Assert.Equal(117, EkranKodlari.AyniGrupEkranlari.Length);
        Assert.Equal(117, EkranKodlari.AyniGrupEkranlari.Select(x => x.Yeni).Distinct().Count());
        foreach (var (yeni, eski) in EkranKodlari.AyniGrupEkranlari)
        {
            Assert.Equal(eski, EkranKodlari.KopyaKaynagi(yeni));
            // Aşama 2'ye geçen ekran kendi kaynağına bağlı; eski kapıyı açmaz.
            Assert.Equal(!EkranKodlari.KendiKapisinda(yeni), Set(yeni).Var(eski, Islem.Gor));
        }
        // Ana ekran eski kodu korur; alt ekran kodu ana ekranın kapısını açar.
        Assert.True(Set("muayene.recete").Var("muayene", Islem.Gor));
        Assert.False(Set("muayene").Var("muayene.recete", Islem.Gor));
    }

    [Fact]
    public void Satis_faturasi_ekrani_yalniz_faturayi_acar_basvuruyu_acmaz()
    {
        var s = Set("belge.satis.fatura");
        Assert.True(s.Var("belge", Islem.Gor));                 // kaynak kapısı
        var kumeler = KaynakKatalogu.BelgeYetkiKodlari
            .Where(k => s.VarTam(k, Islem.Gor))
            .Select(KaynakKatalogu.BelgeKumesi).ToList();
        Assert.Equal(["belge.satis.fatura"], kumeler);
        Assert.True(KaynakKatalogu.BelgeKumesiIzinVerir("belge.satis.fatura", 15, 1));
        Assert.False(KaynakKatalogu.BelgeKumesiIzinVerir("belge.satis.fatura", 18, 1));   // teklif
        Assert.False(KaynakKatalogu.BelgeKumesiIzinVerir("belge.satis.fatura", 19, 30));  // başvuru
    }

    // ------------------------------------------ 1004 aşama 2: Satış / Alış ---

    [Fact]
    public void Her_belge_ekrani_kendi_turunu_acar()
    {
        var beklenen = new Dictionary<string, int[]>
        {
            ["belge.satis"] = [18, 119], ["belge.satis.siparis"] = [19], ["belge.satis.irsaliye"] = [14],
            ["belge.satis.fatura"] = [15], ["belge.satis.fis"] = [16], ["belge.satis.tahakkuk"] = [17],
            ["belge.alis"] = [9], ["belge.alis.irsaliye"] = [10], ["belge.alis_fatura"] = [11],
            ["belge.alis.fis"] = [12], ["belge.alis.tahakkuk"] = [13], ["belge.alis.konsinye"] = [109],
            ["belge.stok"] = [105], ["belge.stok.transfer"] = [20], ["belge.stok.giris"] = [3], ["belge.stok.cikis"] = [4],
        };
        foreach (var (kod, turler) in beklenen)
            Assert.Equal(turler, KaynakKatalogu.BelgeKumesininTurleri(KaynakKatalogu.BelgeKumesi(kod)!));
    }

    [Fact]
    public void Siparis_basvuruyu_gormez_sorguda_da()
    {
        // Sipariş (19) başvuruyla aynı tür; ekranın süzgeci gibi tipi 30 dışarıda.
        Assert.True(KaynakKatalogu.BelgeKumesiIzinVerir("belge.satis.siparis", 19, 1));
        Assert.False(KaynakKatalogu.BelgeKumesiIzinVerir("belge.satis.siparis", 19, 30));
        var belge = KaynakKatalogu.Bul("belge")!;
        var sql = new SorguUretici(belge) { BelgeKumeleri = ["belge.satis.siparis"] }
            .Satirlar(new Cekirdek.Sozlesme.ListeIstegi(), belge.Kolonlar.Take(3).ToList(), null, null, 1).Sql;
        Assert.Contains("and b.tipi <>", sql);
    }

    [Fact]
    public void Tek_turlu_belge_kaynaklari_kendi_kodunda()
    {
        Assert.Equal("belge.satis.irsaliye", KaynakKatalogu.Bul("irsaliye")!.YetkiKodu);
        Assert.Equal("belge.satis.acik_satir", KaynakKatalogu.Bul("belge-acik-satir")!.YetkiKodu);
        Assert.Equal("belge.alis_fatura", KaynakKatalogu.Bul("gelen-belge")!.YetkiKodu);
        Assert.Equal("belge.stok.transfer", KaynakKatalogu.Bul("stok-transfer")!.YetkiKodu);
        Assert.Equal("belge.stok.giris", KaynakKatalogu.Bul("giris-fis")!.YetkiKodu);
        Assert.Equal("belge.stok.cikis", KaynakKatalogu.Bul("cikis-fis")!.YetkiKodu);
        Assert.False(Set("belge.satis.irsaliye").Var("belge.satis", Islem.Gor));
        Assert.Equal("belge.satis.ayar", EkranKodlari.AyarAnahtariKodu["belge.satis.vade_gun"]);
    }

    // ----------------------------------------------- 1004 aşama 2: Finans ---

    private static string? Kosul(string kaynak, YetkiSeti s)
        => EkranKodlari.Kisit(kaynak, k => s.VarTam(k, Islem.Gor))?.Kosul;

    [Fact]
    public void Hesap_ekrani_yalniz_kendi_turunu_gorur_cekirdek_hepsini()
    {
        var banka = Set("hesap.tanim.banka");
        Assert.True(banka.Var("hesap", Islem.Gor));          // kaynak kapısı açılır
        Assert.Equal("(h.tur = 'B')", Kosul("hesap", banka));
        Assert.Equal("(h.tur = 'K') or (h.tur = 'B')", Kosul("hesap", Set("hesap.tanim", "hesap.tanim.banka")));
        Assert.Null(Kosul("hesap", Set("hesap", "hesap.tanim.banka")));   // banko / muhasebe
        // Liste içi ekstre de kendi türüyle; Hesap Ekstresi ekranı tümünü.
        Assert.True(banka.Var("hesap.tanim.ekstre", Islem.Gor));
        Assert.Contains("eh.tur = 'B'", Kosul("hesap-ekstre", banka));
        Assert.Null(Kosul("hesap-ekstre", Set("hesap.tanim.ekstre")));
    }

    [Fact]
    public void Cek_ve_senet_ayri_ekran()
    {
        Assert.Equal("(c.tur = 1)", Kosul("cek-senet", Set("cek_senet")));
        Assert.Equal("(c.tur = 2)", Kosul("cek-senet", Set("cek_senet.senet")));
        Assert.Equal("(c.tur = 1) or (c.tur = 2)", Kosul("cek-senet", Set("cek_senet", "cek_senet.senet")));
        Assert.True(Set("cek_senet.senet").Var("cek_senet", Islem.Gor));
    }

    [Fact]
    public void Kendi_kaynagina_gecen_finans_ekrani_eski_kapiyi_acmaz()
    {
        Assert.Equal("hesap.tanim.banka_tanim", KaynakKatalogu.Bul("banka")!.YetkiKodu);
        Assert.Equal("hesap.tanim.ekstre", KaynakKatalogu.Bul("hesap-ekstre")!.YetkiKodu);
        Assert.Equal("kasa.finans.vade", KaynakKatalogu.Bul("plan-vade")!.YetkiKodu);
        Assert.False(Set("kasa.finans.vade").Var("kasa.finans", Islem.Gor));
        Assert.False(Set("hesap.tanim.banka_tanim").Var("hesap.tanim", Islem.Gor));
        Assert.False(Set("hesap.tanim.ekstre").Var("hesap.tanim", Islem.Gor));
        Assert.Equal("kasa.finans.ayar", EkranKodlari.AyarAnahtariKodu["kasa.duzenleme_gun"]);
        // Kopya kaynağı kalır: göç ve şablon hâlâ eski kodun hakkını izler.
        Assert.Equal("kasa.finans", EkranKodlari.KopyaKaynagi("kasa.finans.vade"));
    }

    // --------------------------------------------- 1004 aşama 2: Muayene ---

    [Fact]
    public void Makro_yonetimi_ayrildi_klinik_kaynaklar_koprude()
    {
        Assert.Equal("muayene.makro", KaynakKatalogu.Bul("metin-makro")!.YetkiKodu);
        Assert.False(Set("muayene").Var("muayene.makro", Islem.Gor));
        Assert.False(Set("muayene.makro").Var("muayene", Islem.Gor));
        // Bilinçli köprü: reçete/muayene/şablon klinik akışta da kullanılır,
        //   ekran kodu çekirdek klinik kapıyı açmaya devam eder.
        Assert.Equal("muayene", KaynakKatalogu.Bul("recete")!.YetkiKodu);
        Assert.True(Set("muayene.recete").Var("muayene", Islem.Gor));
        Assert.True(Set("muayene.liste").Var("muayene", Islem.Gor));
    }

    // ------------------------------------------- 1004 aşama 2: Radyoloji ---

    [Fact]
    public void Cekim_protokolu_ayrildi_akis_ekranlari_koprude()
    {
        Assert.Equal("radyoloji.protokol", KaynakKatalogu.Bul("radyoloji-protokol")!.YetkiKodu);
        Assert.False(Set("radyoloji.protokol").Var("radyoloji", Islem.Gor));
        Assert.False(Set("radyoloji").Var("radyoloji.protokol", Islem.Gor));
        // Bilinçli köprü: rapor şablonu ve kritik bulgu iş akışı çekirdekte.
        Assert.True(Set("radyoloji.sablon").Var("radyoloji", Islem.Gor));
        Assert.True(Set("radyoloji.kritik").Var("radyoloji", Islem.Gor));
    }
}
