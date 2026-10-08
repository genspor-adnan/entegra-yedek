/**
 * API SOZLESMESI — yeniden-ihrac (barrel).
 *
 * Dosya 1196 satira dayanmisti; tipler konu bazli parcalara ayrildi
 * (sozlesme/kimlik.ts, liste.ts, kart.ts, kasa.ts ...). Cagri yerleri
 * `from '../api/sozlesme'` olarak KALDI - tek bir ic yapi degisikligi
 * yuzunden 200 import satiri degistirmek gereksiz gurultu olurdu.
 */
export * from './sozlesme/ortak';
export * from './sozlesme/kimlik';
export * from './sozlesme/liste';
export * from './sozlesme/kart';
export * from './sozlesme/belge';
export * from './sozlesme/belgeDonusum';
export * from './sozlesme/referans';
export * from './sozlesme/kasa';
export * from './sozlesme/stok';
export * from './sozlesme/anaSayfa';
export * from './sozlesme/kurumProfil';
export * from './sozlesme/dokum';
