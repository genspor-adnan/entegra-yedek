import { useState } from 'react';
import { api } from '../../api/istemci';
import { Modal } from '../Modal';
import { guvenli, mesaj } from '../mesaj';
import type { BekleyenIstem, BekleyenIstemYaniti } from '../../api/uclar/basvuruIstem';

/**
 * DOKTOR İSTEMİ — ÜCRETE EKLE (kullanıcı: "kategoriye göre gruplu seçilebilir
 * grid, iskonto gibi"). Hekimin muayenede açtığı bekleyen (serbest=0) lab/
 * radyoloji istemleri kategoriye göre gruplu listelenir; banko SEÇTİKLERİNİ
 * ücrete ekler (fiyat + iskonto + karşılama). Hasta pahalı tetkikten
 * vazgeçerse işareti kaldırılır - yalnız seçilenler laboratuvara/röntgene düşer.
 */
export function DoktorIstemModal({ belgeId, veri, onKapat, onTamam }: {
  belgeId: number;
  veri: BekleyenIstemYaniti;
  onKapat(): void;
  onTamam(): void;
}) {
  const hepsi: BekleyenIstem[] = [...veri.lab, ...veri.radyoloji];
  const anahtar = (x: BekleyenIstem) => `${x.tur}-${x.id}`;
  const [secili, setSecili] = useState<Set<string>>(() => new Set(hepsi.map(anahtar)));
  const [mesgul, setMesgul] = useState(false);

  // Kategoriye göre grupla (sıra: kategori adı).
  const gruplar = new Map<string, BekleyenIstem[]>();
  for (const x of hepsi) {
    const g = gruplar.get(x.kategori) ?? [];
    g.push(x); gruplar.set(x.kategori, g);
  }
  const kategoriler = [...gruplar.keys()].sort((a, b) => a.localeCompare(b, 'tr'));

  const tikla = (k: string) => setSecili(s => {
    const n = new Set(s); n.has(k) ? n.delete(k) : n.add(k); return n;
  });
  const grupTikla = (kat: string, ac: boolean) => setSecili(s => {
    const n = new Set(s);
    for (const x of gruplar.get(kat) ?? []) { const k = anahtar(x); ac ? n.add(k) : n.delete(k); }
    return n;
  });

  const ucretle = async () => {
    const lab = veri.lab.filter(x => secili.has(anahtar(x))).map(x => x.id);
    const rad = veri.radyoloji.filter(x => secili.has(anahtar(x))).map(x => x.id);
    if (lab.length + rad.length === 0) { mesaj('En az bir tetkik seçin.'); return }
    setMesgul(true);
    await guvenli(async () => {
      const y = await api.basvuruIstemUcretlendir(belgeId, { lab, radyoloji: rad });
      mesaj(y.mesaj);
      onTamam();
    });
    setMesgul(false);
  };

  return (
    <Modal baslik="🩺 Doktor İstemleri — Ücrete Ekle" onKapat={onKapat} dar
      alt={<>
        <button className="d bir" disabled={mesgul || secili.size === 0}
          onClick={() => void ucretle()}>✓ Seçilenleri Ücrete Ekle ({secili.size})</button>
        <button className="d" onClick={onKapat}>Kapat</button>
      </>}>
      <div style={{ padding: '4px 2px', fontSize: 12, color: '#667' }}>
        Hekimin istediği tetkikler. Hasta vazgeçtiyse işareti kaldır; yalnız seçilenler
        ücrete eklenir ve çalışma listesine düşer.
      </div>
      {kategoriler.map(kat => {
        const satirlar = gruplar.get(kat)!;
        const tumSecili = satirlar.every(x => secili.has(anahtar(x)));
        return (
          <div key={kat} style={{ margin: '8px 0' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: '#eef4fb',
              borderLeft: '4px solid #2b6cb0', padding: '4px 8px', borderRadius: '0 4px 4px 0',
              fontWeight: 700, fontSize: 13, color: '#1a365d' }}>
              <input type="checkbox" checked={tumSecili}
                onChange={e => grupTikla(kat, e.target.checked)} />
              {kat} <span style={{ marginLeft: 'auto', fontWeight: 400, opacity: 0.7 }}>{satirlar.length}</span>
            </div>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
              <tbody>
                {satirlar.map(x => {
                  const k = anahtar(x);
                  return (
                    <tr key={k} style={{ borderTop: '1px solid #eef' }}
                      onClick={() => tikla(k)} className="secilebilir">
                      <td style={{ width: 30, padding: '5px 8px' }}>
                        <input type="checkbox" checked={secili.has(k)} onChange={() => tikla(k)}
                          onClick={e => e.stopPropagation()} /></td>
                      <td style={{ width: 34, padding: '5px 4px' }}>{x.tur === 'lab' ? '🧪' : '📷'}</td>
                      <td style={{ padding: '5px 8px' }}>{x.tetkik}</td>
                      <td style={{ width: 70, padding: '5px 8px', textAlign: 'right' }}>
                        {x.oncelik >= 2 ? <span className="rz kir">Acil</span> : ''}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        );
      })}
    </Modal>
  );
}
