import { useSesliGiris } from './sesliGiris';
import { MikrofonIkon } from './MikrofonIkon';
import { c } from '../dil/ceviri';

/**
 * SESLE YAZ DÜĞMESİ (kullanıcı 19.10.2026: "stok hizmet ekleme aramasında edit içinde sağda mic olsun,
 * hasta listesi aramada mic olsun", "muayenede şikâyet ve hikâyede mikrofon"). Arama kutularının ve
 * metin alanlarının içinde, sağda; söyleneni `onMetin` ile verir. `surekli`: konuşma bitince durmaz
 * (uzun metin diktesi), yeniden basınca durur. Tarayıcı ses tanımayı desteklemiyorsa hiç çizilmez.
 */
export function SesDugmesi({ onMetin, onBasla, surekli, baslik, sinif }: {
  onMetin(metin: string): void;
  /** Her yeni dinleme başlarken (dikte tabanını o anki metne almak için). */
  onBasla?(): void;
  surekli?: boolean;
  baslik?: string;
  sinif?: string;
}) {
  const ses = useSesliGiris(onMetin, { surekli });
  if (!ses.destek) return null;
  return (
    <button type="button" className={`ses-dugme${ses.dinliyor ? ' acik' : ''}${ses.hata ? ' hatali' : ''}${sinif ? ` ${sinif}` : ''}`}
            title={ses.hata ? c(ses.hata) : ses.dinliyor ? c('Dinlemeyi durdur') : c(baslik ?? 'Sesle ara')}
            aria-pressed={ses.dinliyor}
            // Odak kutuda kalsın (kutunun içindeki düğme odağı almasın).
            onMouseDown={e => e.preventDefault()}
            onClick={e => { e.stopPropagation(); if (ses.dinliyor) ses.durdur(); else { onBasla?.(); ses.baslat() } }}>
      <MikrofonIkon boyut={16} />
    </button>
  );
}
