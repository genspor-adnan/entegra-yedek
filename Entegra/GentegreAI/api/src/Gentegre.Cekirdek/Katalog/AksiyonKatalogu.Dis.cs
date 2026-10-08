using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Dis (706): hasta, seans, tedavi plani, dis lab.
///
/// Katalog 3240 satirlik tek dosyaydi; konu bazli partial parcalara ayrildi
/// (KartKatalogu / KaynakKatalogu ile ayni desen). Girdiler TASINDI, icerigi
/// degismedi.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleDis(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {

        // ===================================================== DIS (706) ==
        // Hasta listesi: satir HASTA, kart ozel sayfa (odontogram + plan).
        //   Ekle/sil yok - hasta kaydi Kayit Kabul'de acilir.
        s["dis-hasta-liste"] = new AksiyonTanimi[]
        {
            new("dis.hasta-karti", "🦷 Diş Hasta Kartı", "dis",
                KaynakKodu: "dis.hasta", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
            new("dis.plan-ac", "📋 Yeni Tedavi Planı", "dis",
                KaynakKodu: "dis.plan", Islem: Islem.Ekle, KayitGerekir: true, Sira: 20, UrunModu: 2),
            Yazdir(),
        };
        // Tedavi plani: crud + onay/sunum. Onay AYRI AKSIYON YETKISI
        //   (dis.plan.onayla): fiyati hekim yazar, onayi hasta danismani alir.
        s["dis-plan-liste"] =
        [
            .. Crud("dis-plan", "dis", "dis.plan",
                    ekleAdi: "＋ Yeni Plan", silHedef: null, yazdir: false,
                    silIpucu: "Onaylı plan silinmez; durumu İptal yapılır"),
            new("dis.plan-sun", "📤 Hastaya Sun", "dis",
                KaynakKodu: "dis.plan", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2,
                Ipucu: "Taslak → Sunuldu; proforma numarası üretilir"),
            new("dis.plan-onayla", "✍ Hasta Onayı", "dis",
                KaynakKodu: "dis.plan", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50, UrunModu: 2,
                AksiyonYetkisi: "dis.plan.onayla", Bicim: "onay",
                Ipucu: "Sunulan plan onaylanır; onaylı satır fiyatı değişmez"),
            new("dis.hasta-karti", "🦷 Diş Hasta Kartı", "dis",
                KaynakKodu: "dis.hasta", Islem: Islem.Gor, KayitGerekir: true, Sira: 60, UrunModu: 2),
            new("dis.odeme-plani-uret", "💳 Ödeme Planı Üret", "dis",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "dis.odeme", Islem: Islem.Ekle, KayitGerekir: true, Sira: 70, UrunModu: 2,
                Ipucu: "Plan netinden peşinat + taksit satırları üretir"),
            Yazdir(),
        ];
        // Seans: bitirme AYRI KARAR (dis.seans.bitir) - ucret satiri o anda dogar.
        s["dis-seans-liste"] =
        [
            .. Crud("dis-seans", "dis", "dis.seans", ekleAdi: "＋ Seans Aç", yazdir: false, silHedef: null, silIpucu: "Bitmiş seans silinmez"),
            new("dis.seans-bitir", "✔ Seansı Bitir", "dis",
                KaynakKodu: "dis.seans", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2,
                AksiyonYetkisi: "dis.seans.bitir", Bicim: "onay",
                Ipucu: "Tamamlanan işlemler başvuruya ücret satırı olarak düşer, odontogram güncellenir"),
            new("dis.hasta-karti", "🦷 Diş Hasta Kartı", "dis",
                KaynakKodu: "dis.hasta", Islem: Islem.Gor, KayitGerekir: true, Sira: 60, UrunModu: 2),
            Yazdir(),
        ];
        // Lab is emri: asama ilerletme tek dugme - hangi asamaya gececegi
        //   uc tarafinda sirayla belirlenir (olcu → gonderildi → ... → teslim).
        s["dis-lab-isemri-liste"] =
        [
            .. Crud("dis-lab-isemri", "dis", "dis.lab", ekleAdi: "＋ İş Emri", yazdir: false, silHedef: null, silIpucu: "Teslim edilmiş iş emri silinmez"),
            new("dis.lab-asama", "➡ Aşamayı İlerlet", "dis",
                KaynakKodu: "dis.lab", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2, Bicim: "bir",
                Ipucu: "Gönderildi / geldi / prova / teslim - her adım zaman damgalı"),
            new("dis.lab-geri", "🔁 Geri Gönder", "dis",
                Hedef: "sagtus,palet",
                KaynakKodu: "dis.lab", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50, UrunModu: 2,
                Ipucu: "Prova sonrası düzeltme için laba geri"),
            Yazdir(),
        ];
        s["dis-odeme-plani-liste"] = Crud("dis-odeme-plani", "dis", "dis.odeme", ekleAdi: "＋ Ödeme Planı", silHedef: null, silIpucu: "Tahsilatı olan ödeme planı silinmez");
    }
}
