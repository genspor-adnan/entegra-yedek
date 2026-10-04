import { c } from '../../dil/ceviri';

/** Duyuru önemi: 1 bilgi · 2 önemli · 3 kritik (957). */
export const ONEM: Record<number, { ad: string; ic: string; sinif: string }> = {
  1: { ad: 'Bilgi', ic: 'ℹ️', sinif: 'dy-o-b' },
  2: { ad: 'Önemli', ic: '📣', sinif: 'dy-o-o' },
  3: { ad: 'Kritik', ic: '🚨', sinif: 'dy-o-k' },
};

export function OnemEtiketi({ onem }: { onem: number }) {
  return <span className={`dy-onem ${ONEM[onem]?.sinif ?? ''}`}>{c(ONEM[onem]?.ad ?? '')}</span>;
}

