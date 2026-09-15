import { mesaj } from '../../bilesenler/mesaj';

/**
 * KAYIT KAPISI — kartın kendi kendine kaydettiği yerler.
 *
 * Ücret eklemek, tahsilat almak ve prim rolü açmak KAYITLI bir belge ister
 * (protokol numarası, satır kimliği, kasa bağı). Bunu kullanıcıya İŞ olarak
 * vermek ("önce Kaydet'e basın") gereksizdi: kart o anda kendisi kaydeder.
 *
 * Üç kural bir arada durmalı, çünkü üçü de aynı hatadan doğdu:
 *
 *  · KAYDEDİLMEMİŞ KALEM DE KAYDEDİLİR (kullanıcı: "114413 ücretler kaybolmuş
 *    ama tahsilat duruyor") - "zaten kayıtlı" deyip dönmek, gride girilmiş ama
 *    gönderilmemiş satırları kart tazelenince siliyordu: para duruyor, ücret yok.
 *  · KART KİRLİYSE DE KAYDEDİLİR - `kalemDegisti` yalnız grid satırlarını
 *    izler; bölüm/hekim/ödeyen kurum gibi BAŞLIK değişiklikleri kaydedilmeden
 *    ücret eklenince kart tazelendiğinde geri alınıyordu.
 *  · DEĞİŞİKLİK YOKSA TAHAKKUK DA YOK (kullanıcı: "＋'ya basınca 2 satır ve
 *    tahakkuk oluştu, hemen bir şey seçmeden") - kayıt atlandığında alttaki
 *    yazıcı yine belge kimliğini döndürüyor, çağıran "kaydedildi" sanıp kurum
 *    tahakkuku kesiyordu. Tahakkuk KAYIT olayına bağlıdır.
 */
export function useKayitKapisi({
  kesHam, kayitliId, kalemDegisti, kirliMi, basvuruMu,
  kurumTahakkukuOtomatik, satirlariTazele, onEksikAlan, aramaAc,
}: {
  /** Asıl kaydetme akışı (doğrula → yaz → satırları tazele → kapat). */
  kesHam(kapatilsin: boolean, otomatik: boolean): Promise<number>;
  kayitliId: number;
  /** Gridde kaydedilmemiş satır var mı. */
  kalemDegisti: boolean;
  /**
   * Kartın tamamının imzası - başlık alanları da dahil. FONKSİYON olarak
   * geçilir: imza kancası kartta AŞAĞIDA kurulur, değeri çağrı anında okunmalı.
   */
  kirliMi(): boolean;
  basvuruMu: boolean;
  kurumTahakkukuOtomatik(belgeId: number): Promise<unknown>;
  satirlariTazele(belgeId?: number): Promise<void>;
  /** Kayıt düşerse: eksik alanların olduğu sekmeye dön. */
  onEksikAlan(): void;
  /** Ücret arama penceresini aç/kapat. */
  aramaAc(ac: boolean): void;
}) {
  /** Kaydeder; başvuruda kayıt GERÇEKLEŞTİYSE kurum tahakkukunu da keser. */
  const kes = async (kapatilsin = true, otomatik = false): Promise<number> => {
    const degisiklikVardi = !kayitliId || kalemDegisti || kirliMi();
    const id = await kesHam(kapatilsin, otomatik);
    if (id && basvuruMu && degisiklikVardi) {
      await kurumTahakkukuOtomatik(id);
      // TAHAKKUK SONRASI SATIRLAR HER ZAMAN YENİDEN OKUNUR: kovaların
      //   KAPATILAN sayacı sunucuda dolar - okumazsak kurum payı hâlâ açık
      //   görünür ("satış tahakkuk geldi ama açık tahsilat ve belge de 400
      //   görünüyor").
      await satirlariTazele(id);
    }
    return id;
  };

  /** Belgeyi kaydettirir; kaydedilene kadar işleme izin vermez. */
  const kayitSart = async (): Promise<boolean> => {
    if (kayitliId && !kalemDegisti && !kirliMi()) return true;
    const id = await kes(false, true);
    if (!id) {
      // NEDEN OLMADIĞI SÖYLENİR (kullanıcı: "ücret ＋'ya basıyorum ama
      //   başvuruyu kaydetmiyor"): kayıt sessizce düşüyordu, uyarı yalnız
      //   alanın altındaki kırmızı yazıydı.
      onEksikAlan();
      void mesaj('Kaydedilemedi - kırmızı işaretli zorunlu alanları tamamlayın.');
      return false;
    }
    return true;
  };

  /**
   * ÜCRET EKLEMENİN İLK KAPISI (kullanıcı: "ücret ekleyeceği zaman kayıt yapıp
   * protokol no versin, ondan sonra ücret eklemeye başlasın").
   *
   * Doğrulama geçmezse arama penceresi AÇILMAZ ve kart eksik alanın olduğu
   * sekmeye döner - memur kırmızı yazıyı gördüğü yerde düzeltsin.
   */
  const ucretEklemeAc = async (ac: boolean) => {
    if (!ac || !basvuruMu) { aramaAc(ac); return }
    // `kayitSart` kayıtlı ve TEMİZ belgede hiçbir şey yapmaz.
    if (!await kayitSart()) return;
    aramaAc(true);
  };

  return { kes, kayitSart, ucretEklemeAc };
}
