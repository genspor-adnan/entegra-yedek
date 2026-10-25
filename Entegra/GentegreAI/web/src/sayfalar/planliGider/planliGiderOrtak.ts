import type { PlanliGiderDonemi, PlanliGiderKartAlanlari, PlanliGiderKategorisi } from '../../api/uclar/planliGider';

/**
 * PLANLI GİDER - ekranların ortak SAF yardımcıları (1177). Görünüm metinleri ve kart düzenleme
 * kuralları; iş rakamı (tutar, dönem tarihi, önizleme, özet) burada HESAPLANMAZ - sunucudan gelir.
 */

export const TUTAR_TURLERI: [number, string][] = [
  [1, 'Sabit'], [2, 'Son N dönem ortalaması'], [3, 'Geçen yıl aynı ay'], [4, 'Hesaplanan (KDV / SGK)'], [5, 'Elle (her dönem)'],
];
export const PERIYOTLAR: [number, string][] = [
  [1, 'Haftalık'], [2, 'Aylık'], [3, '3 aylık'], [4, '6 aylık'], [5, 'Yıllık'], [6, 'Tek sefer'],
];
export const TATIL_KURALLARI: [number, string][] = [[1, 'Önceki iş günü'], [2, 'Sonraki iş günü'], [0, 'Kaydırma']];
export const ODEME_YONTEMLERI: [number, string][] = [
  [1, 'Havale / EFT'], [2, 'Otomatik talimat'], [3, 'Kredi kartı'], [4, 'Nakit'], [5, 'Vergi tahsilatı'],
];
export const HESAP_KAYNAKLARI: [string, string][] = [['kdv', "KDV İcmali'nden (son kesin dönem ödenecek)"], ['sgk', 'SGK - son 3 ödemenin ortalaması']];
export const HAFTA_GUNLERI = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

export const adi = (liste: [number | string, string][], kod: number | string | null | undefined) =>
  liste.find(([k]) => k === kod)?.[1] ?? '';

/** Dönem durumu -> rozet (metin + renk sınıfı). Sunucu kodu bilinmiyorsa kodun kendisi. */
export function durumRozeti(durum: string, gun?: number | null): { ad: string; renk: '' | 'ok' | 'mavi' | 'sari' | 'kir' | 'mor' } {
  const g = gun ?? 0;
  switch (durum) {
    case 'odendi': return { ad: 'Ödendi', renk: 'ok' };
    case 'erken': return { ad: 'Ödendi · erken', renk: 'ok' };
    case 'gec': return { ad: g ? `Geç · +${g} gün` : 'Geç ödendi', renk: 'sari' };
    case 'planli': return { ad: g > 0 ? `Planlı · ${g} gün` : 'Planlı', renk: 'mavi' };
    case 'bugun': return { ad: 'Bugün', renk: '' };
    case 'gecikti': return { ad: g ? `Gecikti ${g} gün` : 'Gecikti', renk: 'kir' };
    case 'atlandi': return { ad: 'Atlandı', renk: '' };
    case 'faturalandi': return { ad: 'Faturalandı', renk: 'mor' };
    case 'beklemede': return { ad: 'Beklemede (banka)', renk: 'sari' };
    case 'pasif': return { ad: 'Pasif', renk: '' };
    default: return { ad: durum || '—', renk: '' };
  }
}

/** Ödeme günü metni: "Ayın 5'i", haftalıkta haftanın günü, yıllıkta gün. */
export function odemeGunuMetni(periyot: number, gun: number): string {
  if (periyot === 1) return HAFTA_GUNLERI[(gun - 1) % 7] ?? `${gun}. gün`;
  if (gun >= 29) return `Ayın ${gun}'${ek(gun)} (kısa ayda son gün)`;
  return `Ayın ${gun}'${ek(gun)}`;
}
/** Türkçe sayı eki (1'i, 2'si, 3'ü, 4'ü, 5'i, 6'sı, 9'u, 10'u, 20'si, 30'u...). */
export function ek(n: number): string {
  const son = n % 10, onlar = n % 100 - son;
  const sesli = son ? ({ 1: 'i', 2: 'si', 3: 'ü', 4: 'ü', 5: 'i', 6: 'sı', 7: 'si', 8: 'i', 9: 'u' } as Record<number, string>)[son]
    : ({ 10: 'u', 20: 'si', 30: 'u' } as Record<number, string>)[onlar] ?? 'ı';
  return sesli;
}

/** yyyy-MM-dd ya da yyyy-MM -> kısa ay adı ("Kas"). */
export const ayKisa = (t: string) => {
  const [y, a] = t.split('-').map(Number);
  return new Date(y, (a || 1) - 1, 1).toLocaleDateString('tr-TR', { month: 'short' });
};
/** yyyy-MM-dd -> "Kasım 2026". */
export const ayUzun = (t: string) => {
  const [y, a] = t.split('-').map(Number);
  return new Date(y, (a || 1) - 1, 1).toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' });
};
/** yyyy-MM-dd -> gg.aa.yyyy (saat dilimi kaydırmadan). */
export const gunT = (t: string | null | undefined) => {
  const m = String(t ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '—';
};

/** Kategori kodu vergi / SGK ise ödenecek yer (tedarikçi) zorunlu DEĞİL (karar 25.10.2026). */
export const tedarikciZorunlu = (kategoriKod: string | null | undefined) => kategoriKod !== 'vergi_sgk';

/**
 * KATEGORİ ÖNTANIMI (karar 25.10.2026): kategori seçilince öntanım YALNIZ BOŞ alanlara yazılır;
 * kullanıcının değiştirdiği alan ezilmez. "Boş": masrafta seçim yok; varsayılanı olan alanlarda
 * (tutar türü, tatil, hatırlatma) kullanıcı o alana bu oturumda dokunmamış VE kayıt yeni
 * (kayıtlı kartta saklı değer kullanıcınındır). Dönen nesne yalnız değişen alanlar.
 */
export function kategoriOntanimi(kart: Pick<PlanliGiderKartAlanlari, 'id' | 'masrafId' | 'tutarTur' | 'hesapKaynak' | 'tatilKural' | 'hatirlatmaGun'>,
                                 kat: PlanliGiderKategorisi, dokunulan: ReadonlySet<string>): Partial<PlanliGiderKartAlanlari> {
  const d: Partial<PlanliGiderKartAlanlari> = {};
  const yeni = !kart.id;
  const serbest = (alan: string) => yeni && !dokunulan.has(alan);
  if (!kart.masrafId && kat.masrafId) { d.masrafId = kat.masrafId; d.masraf = kat.masraf }
  if (serbest('tutarTur') && kat.tutarTur && kat.tutarTur !== kart.tutarTur) d.tutarTur = kat.tutarTur;
  if ((d.tutarTur ?? kart.tutarTur) === 4 && !kart.hesapKaynak && kat.hesapKaynak && !dokunulan.has('hesapKaynak')) d.hesapKaynak = kat.hesapKaynak;
  if (serbest('tatilKural') && kat.tatilKural !== kart.tatilKural) d.tatilKural = kat.tatilKural;
  if (serbest('hatirlatmaGun') && !kart.hatirlatmaGun && kat.hatirlatmaGun) d.hatirlatmaGun = kat.hatirlatmaGun;
  return d;
}

/** Bitiş seçimi: süresiz / tarihte / N dönem sonra (iki alandan türetilen görünüm). */
export type BitisTuru = 'suresiz' | 'tarih' | 'donem';
export const bitisTuru = (k: Pick<PlanliGiderKartAlanlari, 'bitis' | 'donemSayisi'>): BitisTuru =>
  k.donemSayisi ? 'donem' : k.bitis ? 'tarih' : 'suresiz';

/** DÖNEMLER ÇİPLERİ - sunucunun türettiği dönem listesini görünüm için ayırır (rakam hesaplamaz). */
export type DonemCipi = 'tumu' | 'yakin' | 'odendi' | 'gec' | 'atlandi' | 'planli' | 'gecikti';
export const DONEM_CIPLERI: [DonemCipi, string][] = [
  ['tumu', 'Tümü'], ['yakin', 'Son 6 + gelecek 6'], ['odendi', 'Ödendi'], ['gec', 'Geç ödendi'],
  ['gecikti', 'Gecikti'], ['atlandi', 'Atlandı'], ['planli', 'Planlı'],
];
const ODENMIS = new Set(['odendi', 'erken', 'gec', 'faturalandi']);
const GELECEK = new Set(['planli', 'bugun']);

export function donemSuz(donemler: PlanliGiderDonemi[], cip: DonemCipi): PlanliGiderDonemi[] {
  switch (cip) {
    case 'tumu': return donemler;
    case 'odendi': return donemler.filter(d => ODENMIS.has(d.durum));
    case 'gec': return donemler.filter(d => d.durum === 'gec');
    case 'gecikti': return donemler.filter(d => d.durum === 'gecikti' || d.durum === 'beklemede');
    case 'atlandi': return donemler.filter(d => d.durum === 'atlandi');
    case 'planli': return donemler.filter(d => GELECEK.has(d.durum));
    case 'yakin': {
      // Gelecek dönemlerin ilki eksen: ondan önceki 6 + kendisi ve sonraki 5 (gecikmişler geçmiş sayılır).
      let i = donemler.findIndex(d => GELECEK.has(d.durum));
      if (i < 0) i = donemler.length;
      return donemler.slice(Math.max(0, i - 6), i + 6);
    }
  }
}
export const donemCipSayisi = (donemler: PlanliGiderDonemi[], cip: DonemCipi) =>
  cip === 'yakin' ? null : donemSuz(donemler, cip).length;

/** Dönem satırında hangi işlemler anlamlı (sunucu son sözü söyler; bu yalnız düğmeyi açar/kapar). */
export function donemIslemleri(d: PlanliGiderDonemi | null) {
  if (!d) return { esles: false, atla: false, tutar: false, geriAl: false, kaldir: false, odeme: false };
  const eslesmis = !!d.eslesen;
  const atlandi = d.durum === 'atlandi';
  return {
    esles: !eslesmis && !atlandi,
    atla: !eslesmis && !atlandi,
    tutar: !eslesmis && !atlandi,
    geriAl: atlandi || d.elleTutar != null,
    kaldir: eslesmis,
    odeme: !eslesmis && !atlandi,
  };
}

/** Sonraki ödenecek dönem (Ödeme Oluştur'un varsayılan hedefi): ilk eşleşmemiş + atlanmamış geçmiş/gelecek dönem. */
export function odenecekDonem(donemler: PlanliGiderDonemi[]): PlanliGiderDonemi | null {
  return donemler.find(d => d.durum === 'gecikti')
    ?? donemler.find(d => d.durum === 'bugun' || d.durum === 'planli') ?? null;
}

/** Mini çubuk yüksekliği (piksel) - en büyüğe göre oran; görünüm ölçeği, iş rakamı değil. */
export const cubukBoyu = (deger: number, enBuyuk: number, tavan: number) =>
  enBuyuk > 0 && deger > 0 ? Math.max(2, Math.round((deger / enBuyuk) * tavan)) : 0;
