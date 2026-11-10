import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { KodListesiModali } from '../KodListesiModali';
import { c } from '../../dil/ceviri';

/**
 * SEÇİMLİ ROZETLER (kullanıcı 10.11.2026, ziyaret kartı "görüşülen konular"): kod listesindeki değerler rozet olarak
 * dizilir, tıklanan seçilir / bırakılır; değer virgüllü kod listesi ("1,3,5"). "＋ liste" kod listesi penceresini
 * açar (etikete tıklama deseniyle aynı modal), kapanınca rozetler tazelenir. Salt kipte yalnız seçili rozetler.
 */
export function KonuRozetleri({ listeKod, baslik, deger, yaz, salt }: {
  listeKod: string; baslik: string; deger: string; yaz(v: string): void; salt: boolean;
}) {
  const [degerler, setDegerler] = useState<{ deger: number; ad: string }[]>([]);
  const [duzenle, setDuzenle] = useState(false);
  const [surum, setSurum] = useState(0);
  useEffect(() => {
    let iptal = false;
    api.kodListe(listeKod).then(l => { if (!iptal) setDegerler(l.degerler.filter(d => d.aktif !== 0).sort((a, b) => a.sira - b.sira || a.deger - b.deger)) })
      .catch(() => { if (!iptal) setDegerler([]) });
    return () => { iptal = true };
  }, [listeKod, surum]);

  const secili = new Set(deger.split(',').map(s => s.trim()).filter(Boolean));
  const degistir = (kod: number) => {
    if (salt) return;
    const k = String(kod);
    if (secili.has(k)) secili.delete(k); else secili.add(k);
    yaz([...secili].map(Number).sort((a, b) => a - b).join(','));
  };
  const gorunen = salt ? degerler.filter(d => secili.has(String(d.deger))) : degerler;

  return (
    <div className="konu-rozetler" data-testid={`rozetler-${listeKod}`}>
      {gorunen.map(d => (
        <button type="button" key={d.deger} className={`rozet konu-rozet${secili.has(String(d.deger)) ? ' secili' : ''}`}
                disabled={salt} onClick={() => degistir(d.deger)}>{d.ad}</button>
      ))}
      {gorunen.length === 0 && <span className="sonuk">{salt ? '—' : c('Liste boş')}</span>}
      {!salt && <button type="button" className="rozet konu-rozet ekle" title={c('Kod listesini düzenle')} onClick={() => setDuzenle(true)}>＋ {c('liste')}</button>}
      {duzenle && (
        <KodListesiModali kod={listeKod} baslik={baslik} onKapat={() => { setDuzenle(false); setSurum(s => s + 1) }} />
      )}
    </div>
  );
}
