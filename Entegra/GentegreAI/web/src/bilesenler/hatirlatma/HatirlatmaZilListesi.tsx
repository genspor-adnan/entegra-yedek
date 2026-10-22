import { api } from '../../api/istemci';
import type { Hatirlatma } from '../../api/uclar/hatirlatma';
import { guvenli } from '../mesaj';
import { hatirlatmaDegisti, hatirlatmaPenceresiAc, kalanMetni, kayitIkonu, kisaZaman } from './hatirlatmaDeposu';

/**
 * ZİL › ⏰ HATIRLATMALARIM sekmesi (mockup kisisel_hatirlatici.html (1)): gecikmiş · bugün · yarın grupları,
 * satırda Tamam · Ertele · Kaydı aç. Veri kabuk deposundan (HatirlatmaYoneticisi dakikada bir tazeler).
 */
export function HatirlatmaZilListesi({ satirlar, sonra, git }: {
  satirlar: Hatirlatma[];
  /** Paneli kapatır (kart / kayıt açılınca). */
  sonra(): void;
  git(yol: string): void;
}) {
  const simdi = new Date();
  const bugun = simdi.toDateString();
  const grup = (h: Hatirlatma) => new Date(h.zaman) < simdi ? 'Gecikmiş'
    : new Date(h.zaman).toDateString() === bugun ? 'Bugün' : 'Yarın';
  const gruplar = ['Gecikmiş', 'Bugün', 'Yarın'].map(g => ({ g, l: satirlar.filter(h => grup(h) === g) })).filter(x => x.l.length);
  const eylem = (f: () => Promise<unknown>) => void guvenli(async () => { await f(); hatirlatmaDegisti() });
  const yarin = () => {
    const y = new Date(); y.setDate(y.getDate() + 1);
    const p = (n: number) => String(n).padStart(2, '0');
    return `${y.getFullYear()}-${p(y.getMonth() + 1)}-${p(y.getDate())}T09:00`;
  };

  return (
    <ul className="tl-son tl-gelen hk-zil">
      {gruplar.length === 0 && <li className="tl-bos">Yaklaşan hatırlatmanız yok. ✔</li>}
      {gruplar.map(({ g, l }) => [
        <li key={g} className="tl-grpb">{g}</li>,
        ...l.map(h => {
          const k = kalanMetni(h.zaman);
          return (
            <li key={h.id} className={g === 'Gecikmiş' ? 'hk-gec' : ''} onClick={() => { sonra(); hatirlatmaPenceresiAc({ id: h.id }) }}>
              <span>{h.tekrar > 0 ? '🔁' : '⏰'}</span>
              <span><b>{h.baslik}</b>
                <small className="hk-zb">{kisaZaman(new Date(h.zaman))} · {k.metin}{h.tekrarMetni ? ` · ${h.tekrarMetni}` : ''}</small>
                {h.kaynakAd && <small className="hk-bag">{kayitIkonu(h.kaynak)} {h.kaynakAd}</small>}
                <span className="hk-eyl" onClick={e => e.stopPropagation()}>
                  <button type="button" className="d mini" onClick={() => eylem(() => api.hatirlatmaTamamla(h.id))}>✓ Tamam</button>
                  <button type="button" className="d mini" onClick={() => eylem(() => api.hatirlatmaErtele(h.id, { dakika: 60 }))}>⏱ 1 saat</button>
                  <button type="button" className="d mini" onClick={() => eylem(() => api.hatirlatmaErtele(h.id, { zaman: yarin() }))}>⏱ Yarın 09:00</button>
                  {h.kaynak && h.kaynakId && <button type="button" className="d mini"
                    onClick={() => { sonra(); git(`/${h.kaynak}/${h.kaynakId}`) }}>↗ Kaydı aç</button>}
                </span>
              </span>
            </li>
          );
        }),
      ])}
    </ul>
  );
}
