/**
 * İŞ SAĞLIĞI VE GÜVENLİĞİ (İSG) KOD SÖZLÜKLERİ.
 *
 * <b>Neden ayrı dosya:</b> maruziyet sözlüğü <c>IsgPano.tsx</c>'in içinde
 * tanımlanıp dışa veriliyordu ve çalışan kartı onu <b>pano ekranından</b>
 * import ediyordu - kart, görünümü için başka bir ekrana bağlıydı. Sözlük
 * ikisinin de altında durmalı.
 *
 * <b>Kanaat rengi iki yerde iki ifadeyle</b> yazılmıştı: tabloda sözlükten
 * (<c>uyari</c> / <c>hata</c>), KPI kutusunda satır içi üçlü koşuldan
 * (<c>sari</c> / <c>kir</c>). İki CSS ailesi gerçekten ayrı
 * (<c>.rozet.uyari</c> ile <c>.fm-kpi .d.sari</c>), ama <b>hangi kanaatin
 * hangi şiddette olduğu</b> tek karar: o karar burada bir kez verilir, iki
 * eşleme ondan türer.
 *
 * Buradaki kodlar veritabanı kod listelerinin (<c>isg.maruziyet</c>,
 * <c>isg.kanaat</c>, <c>isg.tehlike</c>) ekran karşılığıdır; kanaat ve tehlike
 * ADI sunucudan gelir (<c>kanaat_adi</c>, <c>tehlikeAdi</c>) - burada yalnız
 * renk ve eşik var.
 */

export interface IsgKodAdi { kisa: string; ad: string }

const kisalar = (k: Record<number, IsgKodAdi>) =>
  Object.fromEntries(Object.entries(k).map(([kod, v]) => [Number(kod), v.kisa])) as Record<number, string>;

/**
 * `isg_calisan.maruziyet` / `isg_firma_bolum.maruziyet` (jsonb kod dizisi);
 * kod listesi `isg.maruziyet`.
 *
 * EKRANDA KISA ad kullanılır: bölüm satırında ve kartta maruziyetler yan yana
 * çip olarak diziliyor, "Ergonomik / ağır kaldırma" çipi satırı taşırıyordu.
 * Kod listesinin kendi metni `ad` alanında duruyor - kısaltmanın neyi
 * kısalttığı burada görünsün (ikisi birlikte güncellenir).
 */
const MARUZIYET: Record<number, IsgKodAdi> = {
  1: { kisa: 'Gürültü', ad: 'Gürültü' },
  2: { kisa: 'Toz', ad: 'Toz' },
  3: { kisa: 'Kimyasal', ad: 'Kimyasal / solvent' },
  4: { kisa: 'Ekranlı araç', ad: 'Ekranlı araç' },
  5: { kisa: 'Yüksekte', ad: 'Yüksekte çalışma' },
  6: { kisa: 'Gece', ad: 'Gece çalışması' },
  7: { kisa: 'Biyolojik', ad: 'Biyolojik' },
  8: { kisa: 'Ergonomik', ad: 'Ergonomik / ağır kaldırma' },
  9: { kisa: 'Sıcak/soğuk', ad: 'Sıcak / soğuk ortam' },
  10: { kisa: 'Titreşim', ad: 'Titreşim' },
  11: { kisa: 'Radyasyon', ad: 'Radyasyon' },
  12: { kisa: 'Gıda (portör)', ad: 'Gıda (portör)' },
  13: { kisa: 'Metal dumanı', ad: 'Metal dumanı / kaynak' },
  14: { kisa: 'Ağır metal', ad: 'Ağır metal (kurşun vb.)' },
};
export const ISG_MARUZIYET = kisalar(MARUZIYET);

/**
 * `isg_muayene.tur` (kod listesi `isg.muayene_tur`). Kart şeridinde küçük
 * puntoyla yazıldığı için kısa biçim var ("erken"), kod listesinin kendi
 * metni "Erken kontrol".
 *
 * Satır içi dizi olarak yazılmıştı (`['', 'işe giriş', …][tur]`): kod listesine
 * altıncı tür eklendiğinde dizi sessizce `undefined` döndürürdü.
 */
const MUAYENE_TUR: Record<number, IsgKodAdi> = {
  1: { kisa: 'işe giriş', ad: 'İşe giriş' },
  2: { kisa: 'periyodik', ad: 'Periyodik' },
  3: { kisa: 'işe dönüş', ad: 'İşe dönüş' },
  4: { kisa: 'erken', ad: 'Erken kontrol' },
  5: { kisa: 'iş değişikliği', ad: 'İş değişikliği' },
};
export const ISG_MUAYENE_TUR_KISA = kisalar(MUAYENE_TUR);

/** `isg.kanaat`: 1 çalışır · 2 şu koşulla çalışır · 3 çalışamaz. */
type Siddet = 'iyi' | 'uyari' | 'kotu';
const KANAAT_SIDDET: Record<number, Siddet> = { 1: 'iyi', 2: 'uyari', 3: 'kotu' };

/** Tablo rozeti: `.rozet.ok / .uyari / .hata`. */
export const isgKanaatRozeti = (kanaat: unknown): string => {
  switch (KANAAT_SIDDET[Number(kanaat ?? 0)]) {
    case 'iyi': return 'ok';
    case 'uyari': return 'uyari';
    case 'kotu': return 'hata';
    default: return '';
  }
};

/** KPI kutusu: `.fm-kpi .d.ok / .sari / .kir` (başka bir CSS ailesi). */
export const isgKanaatKpiSinifi = (kanaat: unknown): string => {
  switch (KANAAT_SIDDET[Number(kanaat ?? 0)]) {
    case 'iyi': return ' ok';
    case 'uyari': return ' sari';
    case 'kotu': return ' kir';
    default: return '';
  }
};

/** Firma tehlike sınıfının rozet rengi: 1 az tehlikeli · 2 tehlikeli · 3 çok tehlikeli. */
export const ISG_TEHLIKE_ROZET: Record<number, string> = {
  1: 'isg-teh-az', 2: 'isg-teh-t', 3: 'isg-teh-ct',
};

/**
 * Tehlike sınıfına göre periyodik muayene aralığı (ay): az tehlikeli 5 yıl,
 * tehlikeli 3 yıl, çok tehlikeli 1 yıl (6331 sayılı kanun).
 *
 * <b>Asıl hesap sunucuda</b> (<c>fn_isg_periyot_ay</c>): çalışanın ya da
 * bölümün kendi periyodu, gece çalışması (24 ay) ve portör (6 ay) orada
 * birlikte değerlendirilir. Buradaki eşik yalnız "bölümün kendi periyodu yok,
 * sınıftan geliyor" satırını yazmak için - sayı iki yerde aynı kalmalı.
 */
export const ISG_SINIF_PERIYOT_AY: Record<number, number> = { 1: 60, 2: 36, 3: 12 };

/** Bölüm satırındaki periyot metni: kendi periyodu varsa o, yoksa sınıftan. */
export const isgPeriyotMetni = (bolumPeriyotAy: number | null | undefined,
                                tehlike: number | null | undefined): string =>
  (bolumPeriyotAy
    ? `${bolumPeriyotAy} ay`
    : `sınıf (${ISG_SINIF_PERIYOT_AY[Number(tehlike ?? 3)] ?? ISG_SINIF_PERIYOT_AY[3]} ay)`);
