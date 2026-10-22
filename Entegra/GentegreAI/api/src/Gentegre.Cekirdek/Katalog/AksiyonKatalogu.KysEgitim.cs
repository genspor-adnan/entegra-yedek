using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1056) — eğitim listelerinin aksiyonları. Eğitim kaydı
/// özel kartta silinir (grup = birden çok personel_egitim satırı; generic
/// kart silme tek satırı bilir), listede Sil yok.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysEgitim(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-egitim-liste"] = Crud("kys-egitim", "kys", "kys.egitim", ekleAdi: "＋ Eğitim Kaydı", sil: false);
        s["kys-zorunlu-egitim-liste"] = Crud("kys-zorunlu-egitim", "kys", "kys.egitim", ekleAdi: "＋ Zorunlu Eğitim", yazdir: false, silHedef: null);
        // PERSONEL BELGE TAKİBİ (1135): belge türü tanımları. Mockup personel_belge_turu.html (1):
        //   Yeni · Aç · Kopyala · Pasife al · Sırayı düzenle · Yazdır. Kullanımdaki tür silinemez
        //   (personel belgesi bağlı) - pasife alınır; Sil yalnız sağ tıkta.
        s["personel-belge-turu-liste"] =
        [
            .. Crud("personel-belge-turu", "ik", "ik.belge_takip", ekleAdi: "＋ Yeni", silHedef: "sagtus,palet",
                    silIpucu: "Yalnız hiç kullanılmamış tür silinir; kullanımdakini pasife alın"),
            new("personel-belge-turu.kopyala", "⧉ Kopyala", "ik", KaynakKodu: "ik.belge_takip",
                Islem: Islem.Ekle, KayitGerekir: true, Sira: 22, Ipucu: "Seçili türü kapsamıyla birlikte kopyala"),
            new("personel-belge-turu.durum", "⏸ Pasife al / Aktif et", "ik", KaynakKodu: "ik.belge_takip",
                Islem: Islem.Degistir, KayitGerekir: true, Sira: 24, Ipucu: "Pasif tür kapsam hesabına girmez"),
            new("personel-belge-turu.sira", "↕ Sırayı düzenle", "ik", KaynakKodu: "ik.belge_takip",
                Islem: Islem.Degistir, Sira: 26, Ipucu: "Grup içindeki sırayı yukarı / aşağı taşıyarak düzenle"),
        ];
        // İK takip listesi (mockup (2)): seçili personele eksik belge hatırlatması + yazdır / CSV.
        s["personel-belge-ozet-liste"] =
        [
            new("personel-belge.hatirlat", "📤 Seçililere hatırlat", "ik", KaynakKodu: "ik.belge_takip",
                Islem: Islem.Degistir, KayitGerekir: true, Sira: 10,
                Ipucu: "Eksik / süresi dolan / yaklaşan belgeleri personele e-posta (yoksa SMS) ile bildir"),
            Yazdir(),
        ];
    }
}
