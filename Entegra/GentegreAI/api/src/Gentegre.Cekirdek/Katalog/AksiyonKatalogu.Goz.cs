using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Goz (691): muayene, cizim, gozluk recetesi, protokol ve cihaz ayarlari.
///
/// Katalog 3240 satirlik tek dosyaydi; konu bazli partial parcalara ayrildi
/// (KartKatalogu / KaynakKatalogu ile ayni desen). Girdiler TASINDI, icerigi
/// degismedi.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleGoz(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {

        // ===================================================== GOZ (691) ==
        // Goz modulunun kayit ekranlari SIRADAN KARTLARDIR: muayene,
        //   goruntuleme, islem, recete, takip. Hepsinde ekle/duzenle var;
        //   SILME SAG TUSTA ve dar: klinik kayit silinmez, DURUMU degisir.
        //   Silmeyi tamamen kapatmadik - yanlis acilan bos kaydi temizlemek
        //   gerekiyor; ama arac cubugunda durmasi, silmeyi siradan bir
        //   isleme cevirirdi.
        // MUAYENE KARTININ ARAC CUBUGU (mockup goz_detayli_muayene.html):
        //   hekim olcumu bitirince buradan cikis yapiyor - recete, istem,
        //   islem plani, tamamlama. AYNI KODLAR hem listede hem kartta
        //   kullanilir (ListeKarti `ekAraclar`): kural ve yetki tek yerde.
        //
        //   "Goz semasi" ve "dikte" mockupta var ama BURADA YOK: ikisi de
        //   bu üründe henüz olmayan yetenekler (cizim yuzeyi, ses).
        //   Calismayacak dugme koymak, olmayan bir yetenegi vaat etmektir.
        s["goz-muayene-liste"] =
        [
            // "YENİ" YOK (kullanıcı 05.10.2026): hasta başvurudan gelir, kart
            //   Hekim Listesi / pano "Muayeneye Al" ile açılır - başvurusuz
            //   göz muayenesi açılmaz (göz süreci v2).
            .. Crud("goz-muayene", "goz", "goz.muayene",
                    silIpucu: "Ölçümü olan muayene silinmez; "
                            + "yanlış açılan boş kayıt için").Where(a => a.Kod != "goz-muayene.yeni"),
            new("goz.muayene-tamamla", "✔ Muayeneyi Tamamla", "goz",
                KaynakKodu: "goz.muayene", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 15, UrunModu: 2, Bicim: "onay",
                Ipucu: "Ölçümsüz muayene tamamlanamaz"),
            new("goz.gozluk-recete", "👓 Gözlük Reçetesi", "goz",
                KaynakKodu: "goz.recete", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 40, UrunModu: 2),
            // 974: "Görüntüleme İste" YOK - istem İstem & Sepet'ten (başvuru → ödeme).
            new("goz.islem-planla", "💉 İşlem Planla", "goz",
                KaynakKodu: "goz.islem", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 50, UrunModu: 2,
                Ipucu: "Enjeksiyon · lazer · ameliyat"),
            // MOCKUP ARAÇ ÇUBUĞU: "🖼 Görüntüleme İste" - hekim muayeneyi
            //   kapatmadan OCT / görme alanı ister (istem muayeneye yazılır).
            new("goz.goruntuleme-istem", "🖼 Görüntüleme İste", "goz",
                KaynakKodu: "goz.goruntuleme", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 44, UrunModu: 2,
                Ipucu: "Seçili muayeneye OCT / görme alanı / biyometri istemi"),
            new("goz.onceki-kopyala", "📋 Önceki Muayeneden Kopyala", "goz",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "goz.muayene", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 55, UrunModu: 2,
                Ipucu: "Metinsel bulgular gelir; ölçümler kopyalanmaz"),
            // ÇİZİM VE DİKTE (705): ikisi de bulgu yazmanın başka bir
            //   yolu - bu yüzden ayrı yetkileri yok, "goz.muayene"
            //   değiştirme yetkisine bağlılar.
            new("goz.sema", "🖼 Göz Şeması", "goz",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "goz.muayene", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 60, UrunModu: 2,
                Ipucu: "Fundus / ön segment çizimi; bulgunun yeri"),
            new("goz.dikte", "🎙 Dikte", "goz",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "goz.muayene", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 65, UrunModu: 2,
                Ipucu: "Sesle metin bulgu; ölçüm alanları kapalı"),
        ];
        s["goz-goruntuleme-liste"] =
        [
            // 974: "Yeni" YOK - kayıt hekimin istem sepetinden doğar (başvuru → ödeme).
            .. Crud("goz-goruntuleme", "goz", "goz.goruntuleme", silIpucu: "Ölçüm satırı olan çekim silinmez").Where(a => a.Kod != "goz-goruntuleme.yeni"),
            new("goz.gor-degerlendir", "✍ Değerlendir", "goz", KaynakKodu: "goz.goruntuleme", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 22, UrunModu: 2),
            new("goz.gor-cekildi", "📷 Çekildi", "goz", KaynakKodu: "goz.goruntuleme", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 40, UrunModu: 2, Ipucu: "Ödemesi yapılmamış istem çekilemez"),
            new("goz.gor-yeniden", "↻ Yeniden Çekim İste", "goz", KaynakKodu: "goz.goruntuleme", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 42, UrunModu: 2),
            new("goz.gor-muayene", "👁 Muayeneye Git", "goz", KaynakKodu: "goz.muayene", Islem: Islem.Gor,
                KayitGerekir: true, Sira: 46, UrunModu: 2),
        ];
        s["goz-islem-liste"] = Crud("goz-islem", "goz", "goz.islem",
                                   ekleAdi: "＋ Yeni İşlem",
                                   silIpucu: "Uygulanmış işlem silinmez; iptal edin");
        // GÖZLÜK REÇETELERİ (972): "Yeni" YOK - reçete göz muayene kartından (hasta ve muayene
        //   bağıyla) açılır. Akış düğmeleri ikinci satırda (aracCubuguAltSatir).
        s["goz-gozluk-recete-liste"] =
        [
            .. Crud("goz-gozluk-recete", "goz", "goz.recete",
                    silIpucu: "Hastaya verilmiş reçete silinmez").Where(a => a.Kod != "goz-gozluk-recete.yeni"),
            new("goz.gozluk-imzala", "✍ İmzala", "goz", KaynakKodu: "goz.recete", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 22, UrunModu: 2, Ipucu: "Değerler kilitlenir"),
            // MOCKUP ARAÇ ÇUBUĞU: "📱 SMS / e-posta" - hastaya reçetenin
            //   hazır olduğunu bildirir (değerleri DEĞİL, bkz. 977).
            new("goz.gozluk-bildir", "📱 SMS / e-posta", "goz",
                KaynakKodu: "goz.recete", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 38, UrunModu: 2,
                Ipucu: "İmzalı reçetenin hazır olduğunu hastaya bildirir"),
            new("goz.gozluk-optik", "🏪 Optike Gönder", "goz", KaynakKodu: "goz.recete", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 40, UrunModu: 2),
            new("goz.gozluk-teslim", "✔ Teslim Edildi", "goz", KaynakKodu: "goz.recete", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 42, UrunModu: 2),
            new("goz.gozluk-kopyala", "⧉ Yeni Reçeteye Kopyala", "goz", KaynakKodu: "goz.recete", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 44, UrunModu: 2, Ipucu: "Aynı hastanın muayenesinden açın"),
        ];
        s["goz-kontakt-lens-liste"] = Crud("goz-kontakt-lens", "goz", "goz.recete",
                                          ekleAdi: "＋ Yeni Lens Kaydı");
        s["goz-takip-liste"] = Crud("goz-takip", "goz", "goz.takip",
                                   ekleAdi: "＋ Yeni Takip",
                                   silIpucu: "Takip kapatılır, silinmez");

        // AYARLAR: protokol ve cihaz TANIMDIR - kurulum isi, tam CRUD.
        s["goz-islem-protokol-liste"] = Crud("goz-islem-protokol", "goz", "goz.islem",
                                            ekleAdi: "＋ Yeni Protokol");
        // DİKTE SÖZLÜĞÜ (705): terim/komut/sık cümle VERİDİR - yeni bir
        //   kısaltma için sürüm çıkmak gerekmesin diye ekrandan yönetilir.
        s["dikte-terim-liste"] = Crud("dikte-terim", "goz", "goz.dikte_sozluk",
                                     ekleAdi: "＋ Yeni Terim",
                                     silIpucu: "Kurum sözlüğünden silmek "
                                             + "herkesin diktesini etkiler");
        // CIHAZLAR (978, mockup goz_goruntuleme_cihazlar_v2): tanim +
        //   baglanti sinamasi + mesaj kuyrugu. Kalibrasyon eylemi YOK -
        //   kayit demirbas kartinda tutulur, buradan oraya gidilir.
        s["goz-cihaz-liste"] =
        [
            .. Crud("goz-cihaz", "goz", "goz.cihaz",
                    ekleAdi: "＋ Yeni Cihaz",
                    silIpucu: "Mesajı olan cihaz silinmez; pasife alın"),
            new("goz.cihaz-sina", "🔌 Bağlantıyı Sına", "goz",
                KaynakKodu: "goz.cihaz", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 30, UrunModu: 2,
                Ipucu: "Adrese TCP bağlantısı dener (DICOM doğrulaması değil); sonucu kaydeder"),
            new("goz.cihaz-mesajlar", "📨 Mesaj Kuyruğu", "goz",
                KaynakKodu: "goz.cihaz", Islem: Islem.Gor,
                KayitGerekir: true, Sira: 32, UrunModu: 2,
                Ipucu: "Bu cihazın eşlenmeyen ve hatalı mesajları"),
            new("goz.cihaz-demirbas", "↗ Demirbaş Kartı", "goz",
                KaynakKodu: "goz.cihaz", Islem: Islem.Gor,
                KayitGerekir: true, Sira: 34, UrunModu: 2,
                Ipucu: "Kalibrasyon ve bakım kaydı demirbaş kartında tutulur"),
        ];

        // CIHAZ MESAJLARI: cihazin gonderdigi HAM KAYIT. Elle eklenmez
        //   (kaynagi cihaz), duzeltilmez ve silinmez - olcumun nereden
        //   geldiginin kanitidir.
        //
        // YENIDEN ISLE (703): surucu duzeltildiginde ya da hasta sonradan
        //   eslestiginde mesaj tekrar ayristirilir. Olcum satiri mesajin
        //   kimligini tasidigi icin mukerrer yazim veritabaninda engelli -
        //   dugmeye iki kez basmak ikinci bir olcum uretmez.
        s["goz-cihaz-mesaj-liste"] = new AksiyonTanimi[]
        {
            new("goz.mesaj-isle",   "🔁 Yeniden İşle", "goz",
                KaynakKodu: "goz.cihaz", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10, UrunModu: 2,
                Ipucu: "Mesajı tekrar ayrıştırır; ölçüm mükerrer yazılmaz"),
            new("goz.mesaj-kuyruk", "⏩ Kuyruğu İşle", "goz",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "goz.cihaz", Islem: Islem.Degistir, Sira: 20, UrunModu: 2,
                Ipucu: "Bekleyen ve sahipsiz bütün mesajları dener"),
            Yazdir(),
        };

        // UNITE AKISI ve HASTA OZETI: ikisi de GORUNUMDUR, kayit degil.
        //   Akistaki satir bir gorunumun (v_goz_unite_akis) satiri; ozet
        //   ise hastanin son olcumlerinden hesaplaniyor. Ikisinde de
        //   ekle/duzenle/sil yok - kayit kendi ekraninda acilir.
        // UNITE AKISI: pano YAZMAZ, TASIR. Dugmeler hastayi bir sonraki
        //   istasyona alir, dilatasyon baslatir, oda atar. Klinik kayit
        //   (olcum, tani, islem) kendi kartinda girilir - panoya form
        //   koymak, ayakta doldurulan yarim kayitlar uretirdi.
        //
        // "Siradakini Cagir" KAYIT ISTEMEZ: secili satir yoksa en uzun
        //   bekleyen cagrilir. Numaraya gore cagirmak, arada dilatasyona
        //   giren hastayi sonsuza kadar geride birakir.
        //
        // HICBIRINDE KayitGerekir YOK: bu ekranda secim KANBAN KARTINDAN
        //   yapiliyor, gridden degil. Kayit sarti konsaydi kullanici karta
        //   tikladiktan sonra bir de gridden ayni satiri secmek zorunda
        //   kalirdi; secili kart yoksa ucun kendisi anlasilir bir cumleyle
        //   reddediyor.
        s["goz-akis-liste"] = new AksiyonTanimi[]
        {
            new("goz.cagir",       "📢 Sıradakini Çağır", "goz",
                KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 10, UrunModu: 2,
                Bicim: "onay", Ipucu: "Seçili hasta yoksa en uzun bekleyeni çağırır"),
            // SÜREÇ v2: başvuru panoya (Kabul) alınır - panoya ilk satırı açan tek yol.
            new("goz.panoya-al", "＋ Başvuruyu Panoya Al", "goz",
                KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 5, UrunModu: 2,
                Ipucu: "Bugünün başvurusunu göz ünitesine (Kabul) alır"),
            new("goz.istasyona-al", "➡ İstasyona Al", "goz",
                KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 20, UrunModu: 2, Bicim: "bir",
                Ipucu: "Mevcut istasyon kapanır, yenisi açılır (geçmiş korunur)"),
            new("goz.dilatasyon",  "💧 Dilatasyon Başlat", "goz",
                KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 30, UrunModu: 2, Ipucu: "20 dakikalık sayaç başlar"),
            new("goz.oda-ata",     "🚪 Oda Ata", "goz",
                KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 40, UrunModu: 2),
            new("goz.muayene-ac",  "👁 Muayeneyi Aç", "goz",
                KaynakKodu: "goz.muayene", Islem: Islem.Gor, Sira: 50, UrunModu: 2),
            new("goz.ziyaret-kapat", "✔ Ziyareti Tamamla", "goz",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 60, UrunModu: 2,
                Ipucu: "Açık istasyon kapanır, hasta panodan düşer"),
            // 976 (mockup araç çubuğu): istem panodan AÇILIR ama panoda
            //   YAZILMAZ - sepet muayene kaydına yazıyor, kural orada.
            new("goz.goruntuleme-istem", "📷 Görüntüleme İstemi", "goz",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "goz.goruntuleme", Islem: Islem.Ekle, Sira: 70, UrunModu: 2,
                Ipucu: "İstem sepetini Göz sekmesinde açar (başvuruya ücretlendirilir)"),
            // BEKLEME EKRANI ayrı pencere: salon TV'sinde açık kalacak, ad
            //   maskeli. Yetki panoyu görmekle aynı.
            new("goz.bekleme-ekrani", "🖥 Bekleme Ekranı", "goz",
                Hedef: "araccubugu2,palet",
                KaynakKodu: "goz", Islem: Islem.Gor, Sira: 80, UrunModu: 2,
                Ipucu: "Bekleme salonu ekranını yeni sekmede açar"),
            new("goz.gun-ozeti", "🖨 Gün Özeti", "goz",
                Hedef: "araccubugu2,palet",
                KaynakKodu: "goz", Islem: Islem.Gor, Sira: 90, UrunModu: 2,
                Ipucu: "Sayaçlar, darboğaz, kaynak ve hekim yükü - yazdırılabilir özet"),
            Yazdir(),
        };
        // 976: oda / cihaz tanımı - ayar ekranı (crud).
        s["goz-kaynak-liste"] =
        [
            .. Crud("goz-kaynak", "goz", "goz.kaynak", ekleAdi: "＋ Yeni Oda / Cihaz"),
        ];
        s["goz-hasta-ozet-liste"] = new AksiyonTanimi[] { Yazdir() };
    }
}
