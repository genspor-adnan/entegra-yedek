import { useState } from 'react';

/**
 * MUAYENE / GÖZ KARTI PENCERELERİ - tek yerde toplanan durum (refaktör 20.11.2026, dokuman/REFAKTOR_RAPORU_2026-11-20.md B5).
 *
 * `ListeKarti` jenerik kart kabuğudur; içinde yan yana duran muayene ve göz muayenesine özel pencere durumları buraya
 * taşındı (`useRadyolojiModallari` / `useUtsModallari` ile aynı desen). Yalnız DURUM taşındı: etkiye (useEffect) ya da
 * ref'e bağlı olanlar (epikriz, dikte kaynağı, kart kaydet ref'i) kartta kaldı - sıraları ve bağımlılıkları değişmesin.
 * Adlar aynı; kart bunları açarak (destructure) kullanır.
 */
export function useMuayeneKartModallari() {
  /** BİRLEŞİK İSTEM SEPETİ (kullanıcı: "lab ve radyoloji tek istem ekranı, sekmeli"): muayeneId set olunca modal açılır. */
  const [istem, setIstem] = useState<number | null>(null);
  /** DİKTE penceresi (kartın güncel alan okuyucu / yazıcısı `dikteKaynak` ref'i kartta). */
  const [dikteAcik, setDikteAcik] = useState(false);
  /** RAPOR EKLE MODALI (kullanıcı: "eklerken direkt modal ön bilgilerle açılsın"). */
  const [raporModal, setRaporModal] = useState<{ muayeneId: number; tur: number; rapor?: Record<string, unknown> } | null>(null);
  /** MUAYENE ÖZETİ MODALI (kullanıcı: "muayene özeti ni mockup gibi yap"). */
  const [ozetModal, setOzetModal] = useState<number | null>(null);
  /** Vücut şeması penceresi (Muayene sekmesi). */
  const [vucutAcik, setVucutAcik] = useState(false);
  /** Vital geçmiş grafiği (mockup v7): ta, nabiz, spo2, ates, solunum, kilo, bki. */
  const [vitalGrafik, setVitalGrafik] = useState<string | null>(null);
  /** Sekmesiz düzenin sol listesinden açılan Kendime Not penceresi. */
  const [notAcik, setNotAcik] = useState(false);
  /** e-Reçete sekmesine "ilaç aramayı aç" isteği (özet kontrol listesi); sekme açılıp aramayı açtığında tüketilir. */
  const [receteIlacAra, setReceteIlacAra] = useState(false);
  /**
   * KONSÜLTASYON İSTEĞİ PENCERESİ (kullanıcı 15.10.2026: "soldaki menüden konsültasyon seçersem yeni konsültasyon
   * isteği ekranı açılmalı.. kaydedince ortada olmalı.. edit moda alırsam düzenlenebilmeli"): açık isteğin id'si;
   * sunucu taslağı hasta + isteyen hekimle açar.
   */
  const [konsPencere, setKonsPencere] = useState<number | null>(null);
  /** SEVK PENCERESİ (1110, mockup sevk_karti_v2): sekmesizde sol menü "Sevk" taslak açar, kart pencerede. */
  const [sevkPencere, setSevkPencere] = useState<number | null>(null);
  /** Sol menüden açılan patoloji istemi (sekmesiz) ve kaydedilince istem listesinin tazelenmesi. */
  const [patolojiIstemAcik, setPatolojiIstemAcik] = useState(false);
  const [istemTazele, setIstemTazele] = useState(0);
  /** GÖRÜNTÜ SONUÇLARI penceresi (göz kartı araç çubuğu): muayene id'si (göz görüntüleme / belge için). */
  const [gozGoruntuModal, setGozGoruntuModal] = useState<number | null>(null);

  return {
    istem, setIstem, dikteAcik, setDikteAcik, raporModal, setRaporModal, ozetModal, setOzetModal,
    vucutAcik, setVucutAcik, vitalGrafik, setVitalGrafik, notAcik, setNotAcik, receteIlacAra, setReceteIlacAra,
    konsPencere, setKonsPencere, sevkPencere, setSevkPencere, patolojiIstemAcik, setPatolojiIstemAcik,
    istemTazele, setIstemTazele, gozGoruntuModal, setGozGoruntuModal,
  };
}
