/**
 * ÇALIŞMA PLANI / RANDEVU KOD SÖZLÜKLERİ.
 *
 * <b>İstisna türü üç yerde ayrı yazılmıştı</b> ve üçü de farklıydı: istisna
 * kartı (kod · ad · ikon · açıklama), istisna listesi (ikon · ad · CSS sınıfı)
 * ve randevu takvimi - takvimde yalnız ÜÇ tür tanınıyordu
 * (<c>{1:'İzin',2:'Kongre',5:'Kapalı'}</c>), saat değişikliği (3) ve ek mesai
 * (4) için "Kapalı" yazılıyordu. Oysa kısmi kapanış satırı tam olarak o iki
 * türden de doğabiliyor: hekimin saatini değiştirdiği bir gün takvimde
 * "Kapalı" görünüyordu.
 *
 * Tek kaynak: kod, tam ad, takvim için KISA ad, ikon, liste CSS sınıfı ve
 * türün davranışı (günü kapatır mı, saat ister mi). Metinler veritabanı kod
 * listesiyle (<c>calisma.istisna_tur</c>) aynı tutulur.
 *
 * <b>Davranış da burada tanımlı:</b> hangi türün günü kapattığı
 * (<c>kapatir</c>) ve hangisinin saat aralığı istediği (<c>saatli</c>) kuralı
 * iki kartta ayrı ayrı yazılmış iki tek satırlık fonksiyondu.
 */

export interface IstisnaTuru {
  kod: number;
  /** Kart ve liste metni (kod listesiyle aynı). */
  ad: string;
  /** Takvim hücresi metni - orada satır 11 karakter (saat aralığı da yazılıyor). */
  kisa: string;
  ic: string;
  /** Liste rozetinin CSS sınıfı. */
  sinif: string;
  /** Gün boyu kapatır (saat verilmezse). */
  kapatir: boolean;
  /** Saat aralığı ZORUNLU (o günler başka saat / ek blok). */
  saatli: boolean;
  /** Kartta seçilemez, yalnız eski kayıtta görünür. */
  eski?: boolean;
  /** Kart kutusunda türün altına yazılan kısa açıklama. */
  ne?: string;
}

/** `calisma_istisna.tur` (kod listesi `calisma.istisna_tur`). */
export const ISTISNA_TURLERI: IstisnaTuru[] = [
  // 1 (izin) artık İK'dan girilir; eski kayıt açılabilsin diye listede durur.
  { kod: 1, ad: 'İzin', kisa: 'İzin', ic: '✈️', sinif: 't-izin',
    kapatir: true, saatli: false, eski: true, ne: "artık İK'dan girilir" },
  { kod: 2, ad: 'Kongre / eğitim', kisa: 'Kongre', ic: '🎓', sinif: 't-kongre',
    kapatir: true, saatli: false, ne: 'gün boyu ya da saatli' },
  { kod: 3, ad: 'Saat değişikliği', kisa: 'Saat değ.', ic: '🕘', sinif: 't-saat',
    kapatir: false, saatli: true, ne: 'o günler başka saat' },
  { kod: 4, ad: 'Ek mesai', kisa: 'Ek mesai', ic: '➕', sinif: 't-ek',
    kapatir: false, saatli: true, ne: 'ek çalışma bloğu' },
  { kod: 5, ad: 'Kapalı', kisa: 'Kapalı', ic: '⛔', sinif: 't-kapali',
    kapatir: true, saatli: false, ne: 'bölüm / gün kapalı' },
];

/** İK izni (`kaynak = 4`) istisna türü DEĞİL - listede ayrı satır olarak görünür. */
export const IK_IZNI = { kod: 0, ad: 'İK izni', ic: '🌴', sinif: 't-ik' };

const BUL = new Map(ISTISNA_TURLERI.map(t => [t.kod, t]));

export const istisnaTuru = (kod: number | null | undefined): IstisnaTuru | undefined =>
  BUL.get(Number(kod ?? 0));

export const istisnaAdi = (kod: number | null | undefined): string =>
  istisnaTuru(kod)?.ad ?? '';

/** Takvim hücresinde: tanınmayan kod "Kapalı" sayılır (gün kapanmış durumda). */
export const istisnaKisaAdi = (kod: number | null | undefined): string =>
  istisnaTuru(kod)?.kisa ?? 'Kapalı';

/** Gün boyu kapatan tür (saat verilmezse randevu verilmez). */
export const istisnaKapatir = (kod: number | null | undefined): boolean =>
  istisnaTuru(kod)?.kapatir ?? false;

/** Saat aralığı zorunlu tür (saat değişikliği / ek mesai). */
export const istisnaSaatli = (kod: number | null | undefined): boolean =>
  istisnaTuru(kod)?.saatli ?? false;
