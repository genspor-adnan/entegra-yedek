import { useRef } from 'react';
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
 *  · KAYITLAR SIRAYLA (kullanıcı 16.11.2026: "son eklediğim başvuru için 2 tane istem açılmış"; KOSUYOLU
 *    başvuru 000012): iki kayıt 0,3 sn arayla üst üste gitti (kartın ara kaydı + POS tahsilatı öncesi kayıt).
 *    İkincisi birincinin satır kimliklerini görmeden yazdığı için aynı ücret satırı İKİ KEZ eklendi, her
 *    satır kendi radyoloji istemini açtı. Artık süren kayıt bitmeden ikincisi başlamaz; bittiğinde kartın
 *    GÜNCEL hâli okunur - ara kayıt isteyen için yazılacak bir şey kalmadıysa yeniden yazılmaz.
 */
export function useKayitKapisi({
  kesHam, kayitliId, kalemDegisti, kirliMi, basvuruMu,
  kurumTahakkukuOtomatik, satirlariTazele, onEksikAlan, aramaAc,
}: {
  /** Asıl kaydetme akışı (doğrula → yaz → satırları tazele → kapat). */
  kesHam(kapatilsin: boolean, otomatik: boolean, kullanici?: boolean): Promise<number>;
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
  /** Son çizimin değerleri: sıra bekleyen kayıt, önceki kayıttan SONRAKİ kart hâliyle yazar. */
  const son = useRef({ kesHam, kayitliId, kalemDegisti, kirliMi });
  son.current = { kesHam, kayitliId, kalemDegisti, kirliMi };
  const suren = useRef<Promise<number> | null>(null);

  /** Kaydeder; başvuruda kayıt GERÇEKLEŞTİYSE kurum tahakkukunu da keser. */
  const kes = async (kapatilsin = true, otomatik = false, kullanici?: boolean): Promise<number> => {
    const kullaniciKaydi = kullanici ?? (kapatilsin && !otomatik);
    while (suren.current) {
      const id = await suren.current.catch(() => 0);
      // Önceki kaydın sonucu (satır kimlikleri, protokol) karta çizilsin.
      await new Promise(coz => setTimeout(coz, 0));
      const g = son.current;
      if (!suren.current && id && !kullaniciKaydi && g.kayitliId && !g.kalemDegisti && !g.kirliMi()) return id;
    }
    const is = (async () => {
      const g = son.current;
      const degisiklikVardi = !g.kayitliId || g.kalemDegisti || g.kirliMi();
      const id = await g.kesHam(kapatilsin, otomatik, kullanici);
      if (id && basvuruMu && degisiklikVardi) {
        await kurumTahakkukuOtomatik(id);
        // TAHAKKUK SONRASI SATIRLAR HER ZAMAN YENİDEN OKUNUR: kovaların
        //   KAPATILAN sayacı sunucuda dolar - okumazsak kurum payı hâlâ açık
        //   görünür ("satış tahakkuk geldi ama açık tahsilat ve belge de 400
        //   görünüyor").
        await satirlariTazele(id);
      }
      return id;
    })();
    suren.current = is;
    try { return await is }
    finally { if (suren.current === is) suren.current = null }
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
