import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';

/**
 * HEKIM UNVAN ONEKI (dis hekim karti): "Op.Dr." gibi onek AYRI bir combo'dan
 * secilir, kaydederken ad/soyadin onune eklenir. Boylece hekim her yerde
 * (arama, liste, rapor ciktisi) unvaniyla gorunur.
 *
 * Onek ayristirmasi AYRI bir etkide yapilir: kod listesi ASENKRON geliyor,
 * kart okunurken secenekler henuz bos oluyor ve combo bos kaliyordu.
 */
export function useUnvanOneki(kaynak: string) {
  const [onek, setOnek] = useState('');
  const [secenekler, setSecenekler] = useState<string[]>([]);
  /** Karttan okunan HAM unvan ("Op.Dr. Kerem ATALAY"). */
  const [ham, setHam] = useState('');

  useEffect(() => {
    if (kaynak !== 'dis-hekim' || !ham || secenekler.length === 0) return;
    setOnek(secenekler.find(o => ham.startsWith(o + ' ')) ?? '');
  }, [kaynak, ham, secenekler]);

  useEffect(() => {
    if (kaynak !== 'dis-hekim') return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe('hekim.unvan');
        if (!iptal) setSecenekler(y.degerler.filter(d => d.aktif === 1).map(d => d.ad));
      } catch { /* liste yoksa combo bos kalir - kayit engellenmez */ }
    })();
    return () => { iptal = true };
  }, [kaynak]);

  return { onek, setOnek, secenekler, setHam };
}
