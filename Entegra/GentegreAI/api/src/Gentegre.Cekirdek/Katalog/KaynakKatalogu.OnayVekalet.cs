namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ONAY VEKÂLETİ LİSTESİ (741).
///
/// "AKTİF" İLE "YÜRÜRLÜKTE" AYRI: aktif kullanıcının bayrağı, yürürlükte
/// tarihin cevabı. Tek kolonda birleştirseydik ileri tarihli bir vekâlet
/// pasif görünür ve kullanıcı onu ikinci kez tanımlardı.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi OnayVekaletKaynagi() => new(
        Ad: "onayVekalet",
        YetkiKodu: "kullanici",
        Kaynak: "public.v_onay_vekalet v",
        // ŞUBE SÜZMESİ YOK: vekâlet KİŞİNİNDİR, şubenin değil. Devreden
        //   başka şubede çalışıyor olabilir; süzmek vekâleti görünmez kılardı.
        SubeKolonu: null,
        // YÜRÜRLÜKTEKİ ÖNCE: listenin sorusu "şu an kim kimin yerine bakıyor".
        VarsayilanSirala: "v.yururlukte desc, v.baslangic desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("devredenAd", "v.devreden_ad", "metin", "Devreden", Genislik: 220),
            new("devralanAd", "v.devralan_ad", "metin", "Vekil", Genislik: 220),
            new("baslangic", "v.baslangic", "tarih", "Başlangıç", Hizalama: "orta",
                Genislik: 110),
            new("bitis", "v.bitis", "tarih", "Bitiş", Hizalama: "orta", Genislik: 110),
            new("akisAd", "v.akis_ad", "metin", "Yalnız Bu Akış", Genislik: 180),
            new("durumAdi",
                "case when v.yururlukte = 1 then 'Yürürlükte'" +
                " when v.aktif = 0 then 'Pasif'" +
                " when v.baslangic > current_date then 'Bekliyor' else 'Süresi doldu' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("yururlukte", "v.yururlukte", "sayi", "Yürürlükte", Varsayilan: false),
            // BEKLEYEN = başlangıcı gelecekte. Çipin tarih karşılaştırmasını
            //   istemciye bırakmıyoruz: süzgeç değerleri parametre olarak
            //   gidiyor, "bugün" diye bir değer yok - sunucuda kolon olur.
            new("bekliyor",
                "case when v.baslangic > current_date and v.aktif = 1 then 1 else 0 end",
                "sayi", "Bekleyen", Varsayilan: false),
            new("aktif", "v.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 80),
            new("aciklama", "v.aciklama", "metin", "Açıklama", Genislik: 240,
                Varsayilan: false),
            new("devredenId", "v.devreden_id", "sayi", "Devreden Id", Varsayilan: false),
            new("devralanId", "v.devralan_id", "sayi", "Vekil Id", Varsayilan: false),
        });
}
