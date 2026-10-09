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
        Assert.Equal("t.tedarikci = 1", k!.Kosul);
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
            Assert.True(Set(yeni).Var(eski, Islem.Gor), yeni);
        }
        // Ana ekran eski kodu korur; alt ekran kodu ana ekranın kapısını açar.
        Assert.True(Set("muayene.recete").Var("muayene", Islem.Gor));
        Assert.False(Set("muayene").Var("muayene.recete", Islem.Gor));
    }

    [Fact]
    public void Bolunmus_satis_ekrani_satis_kumesini_acar_basvuruyu_acmaz()
    {
        var s = Set("belge.satis.fatura");
        var kumeler = KaynakKatalogu.BelgeYetkiKodlari
            .Where(k => s.VarTam(k, Islem.Gor))
            .Select(KaynakKatalogu.BelgeKumesi).ToList();
        Assert.Equal([KaynakKatalogu.BelgeKumeSatis], kumeler);
    }
}
