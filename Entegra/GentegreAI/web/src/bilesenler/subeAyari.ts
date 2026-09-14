import type { SubeOzeti } from '../api/sozlesme';

/**
 * AKTİF ŞUBENİN YEREL AYARLARI (666).
 *
 * Ülke, telefon kodu, saat dilimi ve para birimi ŞUBEDEN gelir: Berlin şubesi
 * avro tahsil eder, Almanya saatiyle çalışır ve orada T.C. kimlik numarası
 * yoktur.
 *
 * Neden modül değişkeni: biçimlendiriciler (`bicim.ts`) ve doğrulama
 * (`kartDogrulama.ts`) React ağacının DIŞINDA, saf fonksiyon olarak çağrılıyor -
 * oraya bir hook geçirmenin yolu yok. Oturum bağlamı şube değiştiğinde burayı
 * günceller, geri kalan her yer okur.
 */

export interface SubeAyari {
  ulkeKod: string;
  telefonKodu: string;
  zamanDilimi: string;
  paraBirimi: string;
}

/** Şube bilgisi gelmeden önceki güvenli varsayılan: Türkiye. */
const VARSAYILAN: SubeAyari = {
  ulkeKod: 'TR',
  telefonKodu: '+90',
  zamanDilimi: 'Europe/Istanbul',
  paraBirimi: 'TRY',
};

let mevcut: SubeAyari = { ...VARSAYILAN };

export function subeAyari(): SubeAyari { return mevcut }

/** Oturum açılışında ve şube değişiminde çağrılır. */
export function subeAyariniKur(sube: SubeOzeti | undefined | null) {
  mevcut = sube
    ? {
        ulkeKod: sube.ulkeKod || VARSAYILAN.ulkeKod,
        telefonKodu: sube.telefonKodu || VARSAYILAN.telefonKodu,
        zamanDilimi: sube.zamanDilimi || VARSAYILAN.zamanDilimi,
        paraBirimi: sube.paraBirimi || VARSAYILAN.paraBirimi,
      }
    : { ...VARSAYILAN };
}

/**
 * TCKN ve Türkiye telefon biçimi kontrolü bu şubede uygulanır mı?
 *
 * Şube bilgisi YOKSA `true`: doğrulamanın sessizce kapanması, gereksiz yere
 * açık kalmasından kötüdür.
 */
export function yerelTurkiye(): boolean {
  return (mevcut.ulkeKod || 'TR').toUpperCase() === 'TR';
}

/** Para biriminin simgesi - tutarın yanında gösterilir (₺ / € / $). */
export function paraSimgesi(kod = mevcut.paraBirimi): string {
  const s: Record<string, string> = {
    TRY: '₺', EUR: '€', USD: '$', GBP: '£', AZN: '₼', RUB: '₽', AFN: '؋',
  };
  return s[kod?.toUpperCase()] ?? kod ?? '';
}
