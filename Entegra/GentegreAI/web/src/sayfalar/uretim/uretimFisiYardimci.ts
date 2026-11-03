import type { FisGrup, FisSatiri } from '../../api/uclar/uretimFisi';
import { para, sayi, yerelAnMetni } from '../../bilesenler/bicim';

/** ÜRETİM FİŞİ KARTI YARDIMCILARI (1253) - saf, bileşensiz; kart ve paneller paylaşır. */

export const GRUP_AD: Record<FisGrup, string> = {
  1: 'GİRDİ — Sarf (hammadde)', 2: 'GİRDİ — İşçilik / Gider', 3: 'FİRE', 4: 'ÇIKTI — Mamul / Yan ürün',
};

export const tl = (n: number) => para.format(n);
export const mk = (n: number) => sayi.format(n);
/** ISO an -> datetime-local kutusu ("YYYY-MM-DDTHH:mm"), boşsa "". */
export const anGirdi = (iso: string | null | undefined) => (iso ? yerelAnMetni(new Date(iso)) : '');

/** Boş satır; `depoKalan -1` = bilinmiyor (elle eklenen satır, eksik denetimine girmez). */
export const bosSatir = (grup: FisGrup, s: Partial<FisSatiri> = {}): FisSatiri => ({
  sira: 0, grup, stokId: null, stokKod: '', stokAd: '', izleme: 0, anaUrun: false, birimIhtiyac: 0, planMiktar: 0, miktar: 0,
  birim: 0, birimAdi: '', birimMaliyet: 0, tutar: 0, elleMaliyet: false, fireTuru: 1, izlemler: null, aciklama: '', depoKalan: -1, ...s,
});
export const satirTutar = (s: FisSatiri) => Math.round(s.miktar * s.birimMaliyet * 1e4) / 1e4;
/** Sarf satırı depodaki kalanı aşıyor mu (kalan biliniyorsa). */
export const eksikMi = (s: FisSatiri) => s.grup === 1 && s.depoKalan >= 0 && s.miktar > s.depoKalan + 0.0001;
/** stok.izleme kodu -> ad (0 yok · 1 Seri · 2 Lot · 3 SKT · 4 Karekod · 5 Lot + SKT · 6 Seri + Lot). */
export const izlemeAd = (k: number) => ['', 'Seri', 'Lot', 'SKT', 'Karekod', 'Lot + SKT', 'Seri + Lot'][k] ?? '';

/** Denetimli seviye "Standart liste" kalite kontrolleri (uretim_fisi_v2.html Kalite sekmesi). */
export const VARSAYILAN_KONTROLLER: { ad: string; kriter: string }[] = [
  { ad: 'Hat temizliği (line clearance)', kriter: 'önceki parti malzemesi yok' },
  { ad: 'İlk ürün onayı', kriter: 'teknik resim ölçüleri' },
  { ad: 'Boyutsal / görsel kontrol', kriter: 'spesifikasyon toleransı' },
  { ad: 'Etiket / lot kontrolü', kriter: 'etiket okunur, lot ve SKT doğru' },
];

/** Eldeki malzemeyle üretilebilecek en çok adet (ağaçtan gelen, kalanı bilinen sarf satırlarından); yoksa null. */
export function enCokUretilir(satirlar: FisSatiri[]): number | null {
  const l = satirlar.filter(s => s.grup === 1 && s.birimIhtiyac > 0 && s.depoKalan >= 0);
  if (!l.length) return null;
  return Math.max(0, Math.floor(Math.min(...l.map(s => s.depoKalan / s.birimIhtiyac))));
}
