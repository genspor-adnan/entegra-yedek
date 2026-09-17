namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// RESMÎ TATİL LİSTESİ (749).
///
/// LİSTE "BU YIL NE ZAMAN KAPALIYIZ" SORUSUNU YANITLAR. Gün adı ve hafta
/// sonuna denk gelme bilgisi sütun: köprü tatil tartışması ve vardiya
/// planlaması bu ikisinden çıkar - tarihe bakıp günü kafada hesaplamak
/// hataya açık.
/// </summary>
public static partial class KaynakKatalogu
{
    internal static readonly Dictionary<string, string> TatilTuruKodlari = new()
    {
        ["1"] = "Millî", ["2"] = "Dinî", ["3"] = "İdarî",
    };

    private static KaynakTanimi ResmiTatilKaynagi() => new(
        Ad: "resmiTatil",
        YetkiKodu: "ik.tatil",
        Kaynak: "public.v_resmi_tatil v",
        // ŞUBE SÜZMESİ YOK: tatil kurum genelidir; yerel tatil (kurtuluş
        //   günü) şubeye bağlanır ama merkez de onu görmeli - süzseydik
        //   kurum geneli satırlar (sube_id null) hiç görünmezdi.
        SubeKolonu: null,
        VarsayilanSirala: "v.tarih",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("tarih", "v.tarih", "tarih", "Tarih", Hizalama: "orta", Genislik: 110),
            new("gunAdi", "v.gun_adi", "metin", "Gün", Hizalama: "orta", Genislik: 100,
                Filtrelenebilir: false),
            new("ad", "v.ad", "metin", "Tatil", Genislik: 280),
            new("turAdi",
                "case v.tur when 1 then 'Millî' when 2 then 'Dinî'" +
                " when 3 then 'İdarî' else '' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Filtrelenebilir: false),
            new("tur", "v.tur", "kod", "Tür Kodu", Varsayilan: false,
                Kodlar: TatilTuruKodlari),
            new("yarimGun", "v.yarim_gun", "mantik", "Yarım gün", Hizalama: "orta",
                Genislik: 100),
            // ÇALIŞMA VAR MI: sağlık kurumunda tatil "kapalı" demek değildir -
            //   acil, yatan ve nöbet sürer. Sütun bunu görünür kılıyor.
            new("calismaVar", "v.calisma_var", "mantik", "Çalışma sürer",
                Hizalama: "orta", Genislik: 110),
            // HAFTA SONUNA DENK GELEN tatil kurum için "kayıp" değildir ama
            //   planlamada bilinmeli.
            new("haftaSonu", "v.hafta_sonu", "sayi", "Hafta sonu", Hizalama: "orta",
                Genislik: 100),
            // DOĞRULANDI: dinî bayram tohumu kontrol bekliyor.
            new("dogrulandi", "v.dogrulandi", "mantik", "Doğrulandı",
                Hizalama: "orta", Genislik: 100),
            // YEREL: şubesi olan tatil yalnız o şubeyi bağlar.
            new("yerel", "v.yerel", "sayi", "Yerel", Hizalama: "orta", Genislik: 80),
            new("subeAd", "v.sube_ad", "metin", "Şube", Genislik: 150),
            new("yil", "v.yil::text", "metin", "Yıl", Hizalama: "orta", Genislik: 70),
            new("aktif", "v.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 80),
            new("aciklama", "v.aciklama", "metin", "Açıklama", Genislik: 240,
                Varsayilan: false),
        });
}
