/**
 * Kaynak turden hangi hedeflere donusulebilir (belge turu kod uzayi, 073
 * katalogu).
 *
 * Siparis ve irsaliye YALNIZ faturaya/irsaliyeye degil; FIS ve TAHAKKUK da
 * hedef olabilir (kullanici):
 *   - Fis (12/16): fatura kesilmeden stok/cari hareketi yazilan ic belge
 *     (perakende satis, numune cikisi gibi) - e-Belge'ye gitmez.
 *   - Tahakkuk (17 satis / 13 alis): mal hareketi olmayan alacak/borc kaydi; siparis ya da
 *     irsaliye tutari faturalanmadan cari hesaba islenmek istendiginde.
 * Yon KAYNAKTAN gelir: alis zincirinde alis hedefleri, satista satis.
 */
export const HEDEFLER: Record<number, { kod: number; ad: string }[]> = {
  // Satis teklifi (216): teklif YALNIZ siparise donusur (kullanici) -
  //   taahhut zinciri teklif -> siparis -> irsaliye/fatura sirasiyla yurur.
  18: [{ kod: 19, ad: 'Satış Siparişi' }],
  // Alis siparisi
  9:  [{ kod: 10, ad: 'Alış İrsaliyesi' }, { kod: 11, ad: 'Alış Faturası' },
       { kod: 12, ad: 'Alış Fişi' }, { kod: 13, ad: 'Alış Tahakkuku' }],
  // Satis siparisi
  // BASVURU (246, kullanici): fatura / fis / tahakkuk.
  30: [{ kod: 15, ad: 'Satış Faturası' }, { kod: 16, ad: 'Satış Fişi' },
       { kod: 17, ad: 'Satış Tahakkuku' }],
  19: [{ kod: 14, ad: 'Satış İrsaliyesi' }, { kod: 15, ad: 'Satış Faturası' },
       { kod: 16, ad: 'Satış Fişi' }, { kod: 17, ad: 'Satış Tahakkuku' }],
  // Irsaliyeler (konsinye dahil): mal zaten cikti/girdi, sirada belgelenmesi var
  10:  [{ kod: 11, ad: 'Alış Faturası' }, { kod: 12, ad: 'Alış Fişi' },
        { kod: 13, ad: 'Alış Tahakkuku' }],
  14:  [{ kod: 15, ad: 'Satış Faturası' }, { kod: 16, ad: 'Satış Fişi' },
        { kod: 17, ad: 'Satış Tahakkuku' }],
  109: [{ kod: 11, ad: 'Alış Faturası' }, { kod: 12, ad: 'Alış Fişi' },
        { kod: 13, ad: 'Alış Tahakkuku' }],
  119: [{ kod: 15, ad: 'Satış Faturası' }, { kod: 16, ad: 'Satış Fişi' },
        { kod: 17, ad: 'Satış Tahakkuku' }],
};

/** Hedef türün ikonu - kart menüsü (DonusumMenusu) ve liste menüsü (donusumMenusu) aynı ikonu gösterir. */
export const DONUSUM_IKON: Record<number, string> = { 10: '🚚', 14: '🚚', 11: '🧾', 15: '🧾', 12: '🧮', 16: '🧮', 13: '📑', 17: '📑', 19: '📋' };
