using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// e-NABIZ EKRANLARI (454) — kuyruk tek başına yetmiyordu.
///
/// Bu testler ekranların <b>sözleşmesini</b> tutuyor: kod eşleme listesi ile
/// kartı aynı tabloya bakmalı (yoksa liste bir şey gösterip kart başkasını
/// kaydeder), eşleme türü serbest metin olmamalı (aynı türün iki yazımı paket
/// üreticisine eşlemeyi kaybettirir) ve rehber kataloğu yeni ekranları
/// bilmeli (bilmezse asistan olmayan menüyü tarif eder).
/// </summary>
public class EnabizTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public EnabizTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    [Fact]
    public void Kod_esleme_LISTESI_ve_KARTI_ayni_tabloya_bakar()
    {
        var kaynak = KaynakKatalogu.Bul("enabiz-kod-esleme");
        var kart = KartKatalogu.Bul("enabiz-kod-esleme");
        Assert.NotNull(kaynak);
        Assert.NotNull(kart);

        Assert.Contains("enabiz_kod_esleme", kaynak!.Kaynak, StringComparison.Ordinal);
        Assert.Equal("public.enabiz_kod_esleme", kart!.Tablo);
        // Aynı yetki: listesi görünüp kartı açılamayan ekran, kullanıcıya
        //   "bozuk" görünür.
        Assert.Equal(kaynak.YetkiKodu, kart.YetkiKodu);
    }

    [Fact]
    public void Esleme_turu_SABIT_LISTEDEN_secilir()
    {
        // "klinik" ile "Klinik" iki ayrı tür sayılırsa paket üreticisi
        //   eşlemeyi bulamaz ve alan yine eksik kalır.
        var kart = KartKatalogu.Bul("enabiz-kod-esleme");
        var alan = kart!.Alanlar.FirstOrDefault(a => a.Ad == "eslemeTuru");
        Assert.NotNull(alan);
        Assert.Equal("kod", alan!.Tip);
        Assert.NotNull(alan.SabitKodlar);
        // Kodlar üreticinin aradığı anahtarla BİREBİR: küçük harfle yazılan
        //   bir tür hiçbir pakete dokunmazdı.
        Assert.Contains("KLINIK", alan.SabitKodlar!.Keys);
        Assert.Contains("BASVURU_TURU", alan.SabitKodlar!.Keys);
    }

    [Fact]
    public void Kod_esleme_ekraninin_AKSIYONLARI_var()
    {
        // Katalog ekranı yoksa araç çubuğu boş çizilir: kullanıcı kayıt
        //   ekleyemez ve bunu "yetkim yok" sanır.
        var aksiyonlar = AksiyonKatalogu.Ekran("enabiz-kod-esleme-liste");
        Assert.NotNull(aksiyonlar);
        Assert.Contains(aksiyonlar!, a => a.Kod == "enabiz-kod-esleme.yeni");
        Assert.Contains(aksiyonlar!, a => a.Kod == "enabiz-kod-esleme.duzenle");
    }

    [Fact]
    public async Task Rehber_katalogu_YENI_EKRANLARI_bilir()
    {
        if (!_olgu.Baglandi(nameof(Rehber_katalogu_YENI_EKRANLARI_bilir))) return;
        var veri = _olgu.Gerekli();

        // Menüye eklenen her ekran rehber kataloğuna da girmeli; girmezse
        //   asistan o ekranı hiç öneremez.
        foreach (var rota in new[] { "/enabiz-paket", "/enabiz-pano", "/enabiz-kod-esleme" })
        {
            var satir = await veri.TekAsync(
                "select yol, menu_grup from public.ai_rehber_ekran where rota = @p0",
                [rota], o => new { Yol = o.GetString(0), Grup = o.GetString(1) });
            Assert.True(satir is not null, $"rehber kataloğunda yok: {rota}");
            Assert.Equal("e-Nabız", satir!.Grup);
        }
    }

    [Fact]
    public async Task Enabiz_SURECI_rehberde_anlatilir()
    {
        if (!_olgu.Baglandi(nameof(Enabiz_SURECI_rehberde_anlatilir))) return;
        var veri = _olgu.Gerekli();

        // "e-Nabıza nasıl gidiyor" tek ekranla cevaplanmıyor: olay klinik
        //   ekranda, paket arka planda, gönderim zamanlı işte.
        var adim = await veri.TekDegerAsync<int>(
            "select jsonb_array_length(adimlar) from public.ai_rehber_konu "
            + "where kod = 'enabiz-surec'");
        Assert.True(adim >= 5, $"süreç konusu eksik ({adim} adım)");
    }

    // ------------------------------------------------- SKRS klinik (455) ---

    /// <summary>Kaynak dosyayı diskten okur (bin/Debug'dan yukarı çıkarak).</summary>
    private static string Kaynak(params string[] parcalar)
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        var yol = Path.Combine([dizin!.FullName, "src", .. parcalar]);
        Assert.True(File.Exists(yol), $"kaynak bulunamadı: {yol}");
        return File.ReadAllText(yol);
    }

    [Fact]
    public void SKRS_senkronu_KLINIKLER_listesini_de_ceker()
    {
        // Kodda "SKRS'de klinik listesi yok" notu duruyordu; katalog ASCII ile
        //   arandığı için bulunamamış. Liste adı Türkçe: "KLİNİKLER".
        var kaynak = Kaynak("Gentegre.Api", "Uclar", "EntegrasyonUclari.cs");
        Assert.Contains("\"KLİNİKLER\"", kaynak, StringComparison.Ordinal);
        Assert.Contains("skrs.klinik", kaynak, StringComparison.Ordinal);
    }

    [Fact]
    public void Klinik_kodu_BOLUM_KODUNDAN_okunur_ama_LISTEDE_ARANIR()
    {
        // Ayrı kolon yok (kullanıcı): SKRS klinik kodu bölümün kendi `kod`
        //   alanında durur.
        //
        // Tek şart: kod SKRS KLİNİKLER listesinde ARANIR. Kolonda bir süre
        //   PERSONEL BRANŞ kodları durdu ve her paket yanlış kliniği
        //   bildirdi ("Acil" bölümünün kodu 102, KLİNİKLER'de 102 = ADLI
        //   TIP). 619 kodları düzeltti; listede bulunmayan bir kod artık
        //   pakete hiç yazılmaz - yanlış klinik, boş klinikten kötüdür.
        var kaynak = Kaynak("Gentegre.Api", "Servisler", "EnabizPaketUretici.cs");
        Assert.Contains("d.kod ~ '^[0-9]+$'", kaynak, StringComparison.Ordinal);
        Assert.Contains("fn_skrs_kod('klinik.kod'", kaynak, StringComparison.Ordinal);
        Assert.DoesNotContain("skrs_klinik_kod", kaynak, StringComparison.Ordinal);
    }

    [Fact]
    public async Task SKRS_klinik_LOOKUPU_var()
    {
        if (!_olgu.Baglandi(nameof(SKRS_klinik_LOOKUPU_var))) return;
        // Liste boş olabilir (senkron çalışmamış olabilir) ama GÖRÜNÜM
        //   olmalı: kart lookup'ı olmayan görünüme bakarsa kart hiç açılmaz.
        var sayi = await _olgu.Gerekli().TekDegerAsync<int>(
            "select count(*) from public.v_skrs_klinik_lookup");
        Assert.True(sayi >= 0);
    }
}
