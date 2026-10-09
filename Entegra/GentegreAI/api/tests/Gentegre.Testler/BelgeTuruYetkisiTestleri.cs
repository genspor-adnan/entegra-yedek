using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Testler;

/// <summary>
/// BELGE TÜRÜ YETKİ KISITI (998) — kullanıcı 09.10.2026: *"hasan aydın banko
/// görevlisi olarak login oldum ama yetki dışında menü geldi"*, ardından
/// *"o süzmeyi de yap"*.
///
/// <c>belge</c> tek kaynaktır: Başvurular, Satış Faturaları, Alış Siparişleri
/// aynı tabloya <c>tur</c> süzgeciyle bakar. Menü kodları bölündükten sonra
/// (belge.satis / belge.alis / belge.stok) ekran menüden düştü ama kaynak
/// yetkisi tek kod olduğundan adresi bilen kullanıcı listeyi yine açabiliyordu.
///
/// Bu testler üretilen SQL'i okur - veritabanı gerekmez, çünkü iddia
/// "sorguya hangi koşul girdi" sorusudur. Üç şeyi tutuyor:
///   1. Yetkisiz tür listede ARANMAZ (koşul türleri sınırlar).
///   2. Başvuru türle değil TÜR+TİP çiftiyle gelir (tür 19 iki anlamlı:
///      HBYS başvurusu tipi 30, ERP satış siparişi tipi 1).
///   3. Sayım ve toplam sorguları AYNI koşulu taşır - yoksa sayfa "12 kayıt"
///      der, grid 3 satır çizer.
/// </summary>
public sealed class BelgeTuruYetkisiTestleri
{
    private static KaynakTanimi Belge() => KaynakKatalogu.Bul("belge")!;

    private static SorguUretici Uretici(params string[] kumeler)
        => new(Belge()) { BelgeKumeleri = kumeler };

    private static string Satirlar(SorguUretici u)
        => u.Satirlar(new ListeIstegi(), Belge().Kolonlar.Take(3).ToList(), null, null, 1).Sql;

    [Fact]
    public void Yalniz_basvuru_yetkisi_satis_turlerini_getirmez()
    {
        var sql = Satirlar(Uretici(KaynakKatalogu.BelgeKumeBasvuru));

        // Başvuru dalı TİPE bakar: başvuru (19) ve ondan kesilen hasta fişi
        //   (16) / tahakkuku (17) aynı tipi taşır - yalnız tür 19 denseydi
        //   kayıt kabul kendi hastasının fişini göremezdi.
        Assert.Contains("b.tipi =", sql);
        // Satış/alış kümesinin tür listesi (any(...)) hiç girmemeli.
        Assert.DoesNotContain("b.tur = any(", sql);
    }

    [Fact]
    public void Satis_yetkisi_tur_listesini_baglar()
    {
        var sql = Satirlar(Uretici(KaynakKatalogu.BelgeKumeSatis));

        Assert.Contains("b.tur = any(", sql);
        // Başvuru dalı YOK: `belge` çekirdek yetkisi verilmedi.
        Assert.DoesNotContain("b.tipi =", sql);
        Assert.Equal(30, KaynakKatalogu.BelgeTipiBasvuru);
    }

    [Fact]
    public void Kume_yoksa_kapi_kapali()
    {
        // Yetki hesaplandı ama hiçbir küme çıkmadı: liste boş dönmeli.
        //   Açık bırakmak sızdırma olurdu.
        Assert.Contains("false", Satirlar(Uretici()));
    }

    [Fact]
    public void Kisit_verilmezse_sorgu_degismez()
    {
        // Bağlamsız çağrılar (döküm, özet, iç raporlar) bugünkü davranışını
        //   korur - `BelgeKumeleri` null ise koşul hiç eklenmez.
        var sql = Satirlar(new SorguUretici(Belge()));

        Assert.DoesNotContain("b.tur = any(", sql);
        Assert.DoesNotContain("false", sql);
    }

    [Fact]
    public void Sayim_ve_toplam_ayni_kosulu_tasir()
    {
        var kume = new[] { KaynakKatalogu.BelgeKumeSatis };
        var sayim = new SorguUretici(Belge()) { BelgeKumeleri = kume }
                        .Sayim(new ListeIstegi(), null, null, 1).Sql;
        // Toplam sorgusu yalnız istek toplanacak alan verince kurulur.
        var kolonlar = Belge().Kolonlar;
        var toplanan = kolonlar.First(k => k.Ad == "genelToplam");
        var toplam = new SorguUretici(Belge()) { BelgeKumeleri = kume }
                        .Toplamlar(new ListeIstegi { Toplam = [toplanan.Ad] },
                                   kolonlar, null, null, 1);

        Assert.Contains("b.tur = any(", sayim);
        Assert.NotNull(toplam);
        Assert.Contains("b.tur = any(", toplam!.Sql);
    }

    [Fact]
    public void Tur_kisiti_olmayan_kaynak_etkilenmez()
    {
        // Kısıt yalnız çok türlü `belge` kaynağını ilgilendirir; tek türlü
        //   kaynaklar kendi yetki kodunu taşır (irsaliye -> belge.satis),
        //   onlarda satır süzmesi gereksiz bir koşul olurdu.
        Assert.Null(KaynakKatalogu.BelgeKisitKolonu("irsaliye"));
        Assert.Null(KaynakKatalogu.BelgeKisitKolonu("hasta"));
        Assert.NotNull(KaynakKatalogu.BelgeKisitKolonu("belge"));
    }

    [Fact]
    public void Yetki_kodu_kumeye_cevrilir()
    {
        Assert.Equal(KaynakKatalogu.BelgeKumeBasvuru, KaynakKatalogu.BelgeKumesi("belge"));
        Assert.Equal(KaynakKatalogu.BelgeKumeSatis,   KaynakKatalogu.BelgeKumesi("belge.satis"));
        Assert.Equal(KaynakKatalogu.BelgeKumeAlis,    KaynakKatalogu.BelgeKumesi("belge.alis"));
        Assert.Equal(KaynakKatalogu.BelgeKumeStok,    KaynakKatalogu.BelgeKumesi("belge.stok"));
        Assert.Null(KaynakKatalogu.BelgeKumesi("hasta"));
    }

    [Fact]
    public void Satis_ve_alis_turleri_cakismaz()
    {
        // 1004 aşama 2: küme = ekran kodu; aile, kod önekinden toplanır.
        int[] Aile(params string[] onekler) => KaynakKatalogu.BelgeYetkiKodlari
            .Where(k => onekler.Any(o => k.StartsWith(o, StringComparison.Ordinal)))
            .SelectMany(k => KaynakKatalogu.BelgeKumesininTurleri(KaynakKatalogu.BelgeKumesi(k)!))
            .Distinct().ToArray();
        var satis = Aile("belge.satis", "belge.kurum_fatura");
        var alis  = Aile("belge.alis");
        var stok  = Aile("belge.stok");

        // Bir tür iki kümeye girerse yetkiyi daraltmak anlamını yitirir.
        Assert.Empty(satis.Intersect(alis));
        Assert.Empty(satis.Intersect(stok));
        Assert.Empty(alis.Intersect(stok));
        // Delphi'den gelen sabit kodlar: 15 satış faturası, 11 alış faturası.
        Assert.Contains(15, satis);
        Assert.Contains(11, alis);
    }
}
