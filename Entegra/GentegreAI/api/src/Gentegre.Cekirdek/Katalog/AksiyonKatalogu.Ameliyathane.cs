using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Ameliyathane (715/719) ve cizelge.
///
/// Katalog 3240 satirlik tek dosyaydi; konu bazli partial parcalara ayrildi
/// (KartKatalogu / KaynakKatalogu ile ayni desen). Girdiler TASINDI, icerigi
/// degismedi.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleAmeliyathane(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {

        // ===================================================== AMELİYATHANE (715/719) ==
        // AKIŞ DÜĞMELERİ ARAÇ ÇUBUĞUNDA, AMA HEPSİ DEĞİL. Altı zaman damgası
        //   var; altısını da birinci sıraya koysaydık çubuk, o an yalnız biri
        //   geçerli olan altı düğmeyle dolardı. Birinci sıra AMELİYATIN
        //   OMURGASI (salona alma - kesi - bitiş); anestezi, kapanış ve
        //   salondan çıkış ikinci sırada - kaydedilirler ama akışı onlar
        //   taşımaz (lokal anestezide anestezi damgası hiç olmaz).
        //
        // KESİ AYRI DURUR (Bicim "bir"): time-out tamamlanmadan sunucu
        //   reddeder. Düğmeyi gizlemek yerine reddetmeyi seçtik - gizli
        //   düğme "neden yok" sorusu üretir, red ise NEYİN eksik olduğunu
        //   söyler.
        s["ameliyat-liste"] = new AksiyonTanimi[]
        {
            new("ameliyat.duzenle", "✎ Ameliyat Kartı", "ameliyathane", Kisayol: "Enter",
                KaynakKodu: "ameliyathane.ameliyat", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("ameliyat.salona-al", "🚪 Salona Alındı", "ameliyathane",
                AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                Sira: 20, UrunModu: 2,
                Ipucu: "Masa süresi buradan başlar (plana göre sapma hesaplanır)"),
            new("ameliyat.kesi", "🔪 Kesi", "ameliyathane",
                AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                Sira: 30, UrunModu: 2, Bicim: "bir",
                Ipucu: "Time-out (aşama 2) tamamlanmadan kaydedilmez"),
            new("ameliyat.bitis", "✅ Ameliyat Bitti", "ameliyathane",
                AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                Sira: 40, UrunModu: 2, Bicim: "onay",
                Ipucu: "Cerrahi süre burada kapanır; sayım uyuşmazlığı uyarı verir"),
            // GÜVENLİ CERRAHİ LİSTESİ kartta SALT OKUNUR (madde metni kopya,
            //   işaretleyen/zaman elle yazılmamalı) - işaretleme buradan geçer.
            new("ameliyat.kontrol", "☑ Güvenli Cerrahi Listesi", "ameliyathane",
                KaynakKodu: "ameliyathane.ameliyat", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 50, UrunModu: 2),

            // FATURA ve STOK TEK DÜĞMEDE AÇILIR, tek işte DEĞİL: modal
            //   ikisini ayrı düğmeyle yapar. Ücret hasta başvurusuna, malzeme
            //   stok çıkış fişine gider - ayrı defter, ayrı yetki. Tek tıkla
            //   ikisi birden olsaydı faturayı onaylayan kişi farkında olmadan
            //   depo sayımını da değiştirirdi.
            new("ameliyat.fatura", "🧾 Fatura & Stok", "ameliyathane",
                KaynakKodu: "ameliyathane.ameliyat", Islem: Islem.Gor,
                KayitGerekir: true, Sira: 55, UrunModu: 2,
                Ipucu: "İşlemleri hasta başvurusuna aktarır, malzemeyi stoktan düşer"),

            new("ameliyat.anestezi", "💉 Anestezi Başladı", "ameliyathane",
                Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                Sira: 60, UrunModu: 2),
            new("ameliyat.kapanis", "🧵 Kapanış Başladı", "ameliyathane",
                Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                Sira: 70, UrunModu: 2),
            new("ameliyat.cikis", "🚪 Salondan Çıktı", "ameliyathane",
                Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                Sira: 80, UrunModu: 2,
                Ipucu: "Salon bir sonraki vakaya hazır sayılır"),
            new("ameliyat.not-imzala", "✒ Ameliyat Notunu İmzala", "ameliyathane",
                Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "ameliyathane.not_imzala", KayitGerekir: true,
                Sira: 85, UrunModu: 2,
                Ipucu: "İmzadan sonra not değişmez; yalnız ek not yazılabilir"),
            // AMELİYAT SİLİNMEZ, İPTAL EDİLİR: sarf, ekip ve kontrol satırları
            //   ona bağlı ve "planlandı, olmadı" bilgisi masa kullanımı
            //   raporunun girdisi. Kesi yapılmışsa sunucu iptali reddeder.
            new("ameliyat.iptal", "✖ Ameliyatı İptal Et", "ameliyathane",
                Hedef: "sagtus,palet", AksiyonYetkisi: "ameliyathane.iptal",
                KayitGerekir: true, Sira: 90, UrunModu: 2, Bicim: "ret",
                Ipucu: "Kayıt silinmez; talep bekleyen listesine geri döner"),
            Yazdir(),
        };

        // BEKLEYEN TALEPLER - tek gerçek iş "planla". Talep ameliyata
        //   dönüşmez, ameliyat DOĞURUR: bekleme geçmişi talepte kalır ve
        //   ameliyat iptal olursa geri döneceği yer orasıdır.
        s["ameliyat-talep-liste"] = new AksiyonTanimi[]
        {
            new("ameliyat-talep.yeni", "＋ Yeni Talep", "ameliyathane", Kisayol: "Ctrl+N",
                KaynakKodu: "ameliyathane.talep", Islem: Islem.Ekle, Sira: 10, UrunModu: 2),
            new("ameliyat-talep.duzenle", "✎ Düzenle", "ameliyathane", Kisayol: "Enter",
                KaynakKodu: "ameliyathane.talep", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("ameliyat-talep.planla", "📅 Ameliyata Planla", "ameliyathane",
                KaynakKodu: "ameliyathane.plan", Islem: Islem.Ekle,
                KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "bir",
                Ipucu: "Salon ve saat sorulur; eksik hazırlık ve salon çakışması uyarılır"),
            new("ameliyat-talep.sil", "🗑 Sil", "ameliyathane",
                Kisayol: "Del", KaynakKodu: "ameliyathane.talep", Islem: Islem.Sil,
                KayitGerekir: true, Sira: 40, UrunModu: 2,
                Ipucu: "Planlanmış talep silinemez; önce ameliyatı iptal edin"),
            Yazdir(),
        };

        s["ameliyat-salon-liste"] = new AksiyonTanimi[]
        {
            new("ameliyat-salon.yeni", "＋ Yeni Salon", "ameliyathane", Kisayol: "Ctrl+N",
                KaynakKodu: "ameliyathane.salon", Islem: Islem.Ekle, Sira: 10, UrunModu: 2),
            new("ameliyat-salon.duzenle", "✎ Düzenle", "ameliyathane", Kisayol: "Enter",
                KaynakKodu: "ameliyathane.salon", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 20, UrunModu: 2),
            new("ameliyat-salon.sil", "🗑 Sil", "ameliyathane",
                Kisayol: "Del", KaynakKodu: "ameliyathane.salon", Islem: Islem.Sil,
                KayitGerekir: true, Sira: 30, UrunModu: 2,
                Ipucu: "Ameliyat geçmişi olan salon silinemez; pasife alın"),
            Yazdir(),
        };
    }
}
