/**
 * ÖDEME DAĞILIMI - KOVA SABİTLERİ (470).
 *
 * Kodlar SUNUCUYLA BİREBİR (`belge.pay` kod listesi): satır dağılımı,
 * tahsilat dağıtımı, dönüşüm ve hakediş hepsi bu uzayı kullanır. Ekranda
 * ikinci bir numaralandırma tutmak, bir tarafta 2 "kurum" iken öbür tarafta
 * "SGK" olduğu an sessiz bir hataya dönerdi.
 *
 * <b>Burada iş kuralı yok:</b> hangi kovaya ne yazılacağını sunucu
 * (`fn_belge_satir_dagit`) söyler; bu dosya yalnız kodu ada çevirir.
 */
export const KOVA_HASTA_PROVIZYON = 1;
export const KOVA_SGK = 2;
export const KOVA_OSS = 3;
export const KOVA_HASTA_EK_KATKI = 4;
export const KOVA_KATILIM = 5;

export interface KovaTanimi {
  kod: number;
  /** Satır dağılımındaki alan adı (API ile aynı). */
  alan: 'hastaProvizyon' | 'sgk' | 'oss' | 'hastaEkKatki' | 'sgkKatilimPayi';
  ad: string;
  /** Parayı kim öder: hasta mı, kurum mu. */
  hedef: 'hasta' | 'kurum';
  /** Ciro dışı: tahsil edilir ama hastanenin geliri değildir. */
  ciroDisi?: boolean;
  not?: string;
}

/** Ekranda gösterim sırası: önce kurum payları, sonra hastanınkiler. */
export const KOVALAR: KovaTanimi[] = [
  { kod: KOVA_SGK, alan: 'sgk', ad: 'SGK', hedef: 'kurum' },
  { kod: KOVA_OSS, alan: 'oss', ad: 'Sigorta', hedef: 'kurum' },
  { kod: KOVA_HASTA_PROVIZYON, alan: 'hastaProvizyon', ad: 'Hasta payı',
    hedef: 'hasta' },
  { kod: KOVA_HASTA_EK_KATKI, alan: 'hastaEkKatki', ad: 'Hasta ek katkısı',
    hedef: 'hasta' },
  { kod: KOVA_KATILIM, alan: 'sgkKatilimPayi', ad: 'SGK katılım payı',
    hedef: 'hasta', ciroDisi: true, not: 'ciro dışı · SGK emaneti' },
];

/** Kova kodu -> açık satırdaki KALAN alanı (AcikSatir, 470). */
export const KOVA_KALAN_ALANI: Record<number,
  'hastaProvizyonKalan' | 'sgkKalan' | 'ossKalan' | 'hastaEkKatkiKalan'> = {
  [KOVA_HASTA_PROVIZYON]: 'hastaProvizyonKalan',
  [KOVA_SGK]: 'sgkKalan',
  [KOVA_OSS]: 'ossKalan',
  [KOVA_HASTA_EK_KATKI]: 'hastaEkKatkiKalan',
};

/**
 * Dönüşümde kovaların DENENME SIRASI: tahakkuk önce kurum paylarını
 * (SGK, sigorta), fiş/fatura önce hasta paylarını arar. Katılım payı (5)
 * listede YOK - ciro dışı emanet, belgeye dönüşmez.
 */
export const DONUSUM_KOVA_SIRASI = {
  kurumOnce: [KOVA_SGK, KOVA_OSS, KOVA_HASTA_PROVIZYON, KOVA_HASTA_EK_KATKI],
  hastaOnce: [KOVA_HASTA_PROVIZYON, KOVA_HASTA_EK_KATKI, KOVA_OSS, KOVA_SGK],
};

/** Dönüşüm modalindeki "Dönüştürülecek Pay" seçenekleri (0 = tümü). */
export const DONUSUM_PAY_SECENEKLERI = [
  { kod: KOVA_HASTA_PROVIZYON, ad: 'Hasta payı' },
  { kod: KOVA_HASTA_EK_KATKI, ad: 'Hasta ek katkısı' },
  { kod: KOVA_OSS, ad: 'Sigorta / anlaşmalı kurum → kuruma faturalanır' },
  { kod: KOVA_SGK, ad: "SGK payı → SGK'ya tahakkuk" },
];

/** `fn_dagilim_rota` sonucu: hangi kural işledi. */
export const ROTA_OZEL = 1;
export const ROTA_OSS = 2;
export const ROTA_TSS = 3;
export const ROTA_KARMA = 4;
export const ROTA_SGK = 5;

export const ROTA_ADI: Record<number, string> = {
  [ROTA_OZEL]: 'Özel', [ROTA_OSS]: 'ÖSS', [ROTA_TSS]: 'TSS',
  [ROTA_KARMA]: 'Karma', [ROTA_SGK]: 'SGK',
};

/** Rotada bu kova hiç kullanılmaz mı - "—" gösterilecek satırlar. */
export function kovaKullanilir(rota: number, kod: number): boolean {
  if (kod === KOVA_SGK || kod === KOVA_KATILIM)
    return rota === ROTA_TSS || rota === ROTA_KARMA || rota === ROTA_SGK;
  if (kod === KOVA_OSS)
    return rota === ROTA_OSS || rota === ROTA_TSS || rota === ROTA_KARMA;
  if (kod === KOVA_HASTA_PROVIZYON)
    return rota === ROTA_OSS || rota === ROTA_KARMA;
  return true;   // ek katkı her rotada olabilir
}
