import type { SatirDurumu } from './belgeSatir';

/**
 * KART IMZASI - "kaydedilmemis degisiklik var mi" sorusunun tek kaynagi.
 *
 * Alan alan "degisti" bayragi tutmak yerine kartin ANLAMLI durumu tek metne
 * cevrilir: yeni alan eklendiginde kontrol kendiliginden kapsar, kimse bayrak
 * koymayi unutmaz.
 *
 * SAHTE FARK TUZAGI (kartDegisim.ts ile ayni ders): ayni deger farkli
 * yazimlarla gelebiliyor - sunucudan "1500.0000", ekrandan "1500"; bos alan
 * kimi yerde null kimi yerde ''. Imza bu yuzden HAM state'i degil
 * NORMALLESTIRILMIS degerleri yazar, yoksa kullanici hicbir sey degistirmeden
 * "kaydedilmemis degisiklik" uyarisi alirdi.
 */
export interface KartImzaDurumu {
  tarih: string;
  cariId: number | null;
  seri: string;
  belgeNo: string;
  vadeGun: string;
  faturaTipi: number;
  aciklama: string;
  satirlar: SatirDurumu[];
  odeyenKurumId: number | null;
  bolumId: number | null;
  personelId: number | null;
  basvuruBilgi: Record<string, unknown>;
  fiyatListesiId: number | null;
  kampanyaId: number | null;
  depoId: number | null;
  raporDovizi: string;
  ekstreDovizi: string;
  belgeKuru: string;
  senaryo: number;
}

/** Sayi/metin karisikligini tek yazima indirger ("1500.00" ve "1500" ayni). */
function sayiMetni(v: unknown): string {
  if (v === null || v === undefined || v === '') return '';
  const n = Number(String(v).replace(',', '.'));
  return Number.isFinite(n) ? String(n) : String(v);
}

/** Kimlik alanlari: null / 0 / '' hepsi "secim yok" demektir. */
const kimlik = (v: unknown): number => Number(v ?? 0) || 0;

/** Metin alanlari: bos yazimlar ayni, bas/son bosluk onemsiz. */
const metin = (v: unknown): string => String(v ?? '').trim();

/** Satirin imzaya giren alanlari - anahtar ve gecici alanlar disarida. */
function satirImzasi(s: SatirDurumu) {
  return [
    kimlik(s.stokId), kimlik(s.hizmetId), s.satirTur,
    sayiMetni(s.adet), sayiMetni(s.birimFiyat), sayiMetni(s.dovizFiyat),
    metin(s.fiyatDovizi), sayiMetni(s.kur),
    sayiMetni(s.iskonto), sayiMetni(s.iskonto2), sayiMetni(s.kdv),
    metin(s.aciklama), metin(s.teslimTarihi), kimlik(s.satirId),
    // Pay tutarlari (289): provizyon uygulanınca degisir, kullanici degisikligidir.
    sayiMetni((s as { hastaTutar?: unknown }).hastaTutar),
    sayiMetni((s as { kurumTutar?: unknown }).kurumTutar),
  ].join('|');
}

/** Basvuru uzantisi: bos ve dolu alanlar ayni yazimla, ANAHTAR SIRASI SABIT. */
function basvuruImzasi(b: Record<string, unknown>): string {
  return Object.keys(b).sort()
    .map(k => `${k}=${metin(b[k])}`)
    .filter(x => !x.endsWith('='))          // bos alanlar imzaya girmez
    .join('|');
}

export function kartImzasi(d: KartImzaDurumu): string {
  return [
    metin(d.tarih), kimlik(d.cariId), metin(d.seri), metin(d.belgeNo),
    sayiMetni(d.vadeGun), d.faturaTipi, metin(d.aciklama),
    kimlik(d.odeyenKurumId), kimlik(d.bolumId), kimlik(d.personelId),
    kimlik(d.fiyatListesiId), kimlik(d.kampanyaId), kimlik(d.depoId),
    metin(d.raporDovizi), metin(d.ekstreDovizi), sayiMetni(d.belgeKuru), d.senaryo,
    basvuruImzasi(d.basvuruBilgi),
    d.satirlar.map(satirImzasi).join(';'),
  ].join('~');
}
