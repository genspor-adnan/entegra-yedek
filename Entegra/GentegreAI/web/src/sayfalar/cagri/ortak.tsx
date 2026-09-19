import type { ReactNode } from 'react';

/** Çağrı Merkezi (839) ekranlarının ortak parçaları. */

/** cagri.sonuc kod listesi - kapatma formu ve giden arama sonucu aynı seçenekleri kullanır. */
export const SONUCLAR: { kod: number; ad: string }[] = [
  { kod: 1, ad: 'Çözüldü' }, { kod: 7, ad: 'Randevu verildi' }, { kod: 6, ad: 'Bilgi verildi' }, { kod: 2, ad: 'Geri aranacak' },
  { kod: 3, ad: 'Görev açıldı' }, { kod: 5, ad: 'Yönlendirildi' }, { kod: 4, ad: 'Ulaşılamadı' }, { kod: 8, ad: 'Vazgeçti' },
];

/** Saniye → "d:ss". */
export const sureYaz = (sn: number) => `${Math.floor(sn / 60)}:${String(Math.max(0, sn) % 60).padStart(2, '0')}`;

/** ISO zaman → "HH:MM" (boşsa ''). */
export const saat = (d?: string | null) => d ? new Date(d).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }) : '';

/** Salt okunur etiket + değer satırı (form dili). */
export function Al({ lb, v }: { lb: string; v: ReactNode }) {
  return <div className="al"><span className="lb">{lb}</span><span className="inp ro">{v}</span></div>;
}
