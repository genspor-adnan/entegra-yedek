import { useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { Modal } from '../Modal';
import { guvenli, mesaj } from '../mesaj';
import type { ListeSatiri, Kosul } from '../../api/sozlesme';

/**
 * HEKİM GÖRÜNTÜLEME (RADYOLOJİ) İSTEM EKRANI — lab istem sepetiyle AYNI desen
 * (kullanici: "görüntü istem de lab istem gibi desende olsun"). Sol kolonda
 * modaliteler, üstte arama, sağda o modalitenin radyoloji hizmetleri; tıkla →
 * sepete eklenir/çıkar, pencere kapanmaz; "İstem Aç" seçilenlerin HER BİRİ için
 * radyoloji istemi açar, "Kapat" ile kapanır. (Radyoloji tetkiği modalitesi
 * olan HİZMET kartıdır.)
 */
const MODALITELER = [
  { kod: '', ad: 'Tümü', ikon: '📷' },
  { kod: '1', ad: 'BT', ikon: '🖥' },
  { kod: '2', ad: 'MR', ikon: '🧲' },
  { kod: '3', ad: 'USG', ikon: '🔊' },
  { kod: '4', ad: 'Röntgen', ikon: '📸' },
  { kod: '5', ad: 'Mamografi', ikon: '🎗' },
  { kod: '6', ad: 'DEXA', ikon: '🦴' },
  { kod: '7', ad: 'Anjiyo', ikon: '🩸' },
  { kod: '8', ad: 'Skopi', ikon: '📹' },
];

type Kalem = { id: number; kod: string; ad: string };

export function RadyolojiIstemSepetiModal({ muayeneId, onKapat, onBitti }: {
  muayeneId: number;
  onKapat(): void;
  onBitti(): void;
}) {
  const [modalite, setModalite] = useState('');
  const [arama, setArama] = useState('');
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [sepet, setSepet] = useState<Map<number, Kalem>>(new Map());
  const [acil, setAcil] = useState(false);
  const [mesgul, setMesgul] = useState(false);
  const zaman = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    window.clearTimeout(zaman.current);
    zaman.current = window.setTimeout(() => void yukle(), 200);
    return () => window.clearTimeout(zaman.current);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [modalite, arama]);

  useEffect(() => { kutu.current?.focus() }, [modalite]);

  async function yukle() {
    setYukleniyor(true);
    try {
      const metin = arama.trim();
      const metinFiltre: Kosul | undefined = metin
        ? { op: 'or', kosullar: ['kod', 'ad', 'kisaAd'].map(alan => ({
            alan, op: 'icerir' as const, deger: metin })) }
        : undefined;
      // Modalitesi OLAN hizmetler = radyoloji tetkikleri. Belirli modalite
      //   seçiliyse ona eşit, yoksa >0 (tüm radyoloji).
      const modFiltre: Kosul = modalite
        ? { alan: 'modalite', op: 'esit', deger: Number(modalite) }
        : { alan: 'modalite', op: 'buyuk', deger: 0 };
      const filtre: Kosul = metinFiltre
        ? { op: 'and', kosullar: [metinFiltre, modFiltre] } : modFiltre;
      const t = await api.liste('hizmet', { sayfa: 1, boyut: 200, filtre });
      const sirali = [...t.satirlar].sort((a, b) =>
        String(a.ad ?? '').localeCompare(String(b.ad ?? ''), 'tr'));
      setSatirlar(sirali);
    } catch { /* liste bos kalir */ }
    setYukleniyor(false);
  }

  const ekleCikar = (r: ListeSatiri) => {
    const id = Number(r.id);
    setSepet(s => {
      const n = new Map(s);
      n.has(id) ? n.delete(id)
        : n.set(id, { id, kod: String(r.kod ?? ''), ad: String(r.ad ?? '') });
      return n;
    });
  };

  const istemAc = async () => {
    const kalemler = [...sepet.values()];
    if (kalemler.length === 0) { mesaj('En az bir tetkik seçin.'); return }
    setMesgul(true);
    await guvenli(async () => {
      let basari = 0;
      const hatalar: string[] = [];
      for (const k of kalemler) {
        try {
          await api.muayeneIstemAc(muayeneId, { tur: 2, hizmetId: k.id, aciliyet: acil ? 2 : 1 });
          basari++;
        } catch { hatalar.push(k.ad || k.kod); }
      }
      mesaj(hatalar.length === 0
        ? `${basari} görüntüleme istemi açıldı.`
        : `${basari} istem açıldı; başarısız: ${hatalar.join(', ')}.`);
      if (basari > 0) { onBitti(); onKapat(); }
    });
    setMesgul(false);
  };

  const sepetListe = useMemo(() => [...sepet.entries()], [sepet]);

  return (
    <Modal baslik="📷 Görüntüleme (Radyoloji) İstemi" onKapat={onKapat}
      alt={<>
        <label style={{ marginRight: 'auto', display: 'flex', alignItems: 'center', gap: 6, fontSize: 13 }}>
          <input type="checkbox" checked={acil} onChange={e => setAcil(e.target.checked)} /> Acil
        </label>
        <button className="d bir" disabled={mesgul || sepet.size === 0}
          onClick={() => void istemAc()}>✓ İstem Aç ({sepet.size})</button>
        <button className="d" onClick={onKapat}>Kapat</button>
      </>}>
      <div style={{ display: 'flex', gap: 10, minHeight: 420 }}>
        {/* SOL: modaliteler */}
        <ul style={{ listStyle: 'none', margin: 0, padding: 0, width: 168, flex: '0 0 168px',
          borderRight: '1px solid #e5eaf0', overflowY: 'auto', maxHeight: 460 }}>
          {MODALITELER.map(m => (
            <li key={m.kod}>
              <button type="button" onClick={() => setModalite(m.kod)}
                style={{ display: 'flex', alignItems: 'center', gap: 8, width: '100%',
                  border: 0, background: modalite === m.kod ? '#2b6cb0' : 'transparent',
                  color: modalite === m.kod ? '#fff' : '#243', textAlign: 'left',
                  padding: '7px 10px', cursor: 'pointer', fontSize: 13, borderRadius: 5,
                  fontWeight: modalite === m.kod ? 700 : 400 }}>
                <span>{m.ikon}</span>{m.ad}
              </button>
            </li>
          ))}
        </ul>

        {/* SAĞ: arama + tetkik listesi */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
          <input ref={kutu} value={arama} onChange={e => setArama(e.target.value)}
            placeholder="Tetkik ara (kod / ad)…"
            style={{ padding: '8px 10px', fontSize: 14, border: '1px solid #cbd5e0',
              borderRadius: 6, marginBottom: 8 }} />
          <div style={{ flex: 1, overflowY: 'auto', border: '1px solid #eef', borderRadius: 6,
            maxHeight: 360 }}>
            {yukleniyor && <div style={{ padding: 12, color: '#889' }}>Yükleniyor…</div>}
            {!yukleniyor && satirlar.length === 0 &&
              <div style={{ padding: 12, color: '#889' }}>Sonuç yok.</div>}
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
              <tbody>
                {satirlar.map(r => {
                  const id = Number(r.id);
                  const secili = sepet.has(id);
                  return (
                    <tr key={id} onClick={() => ekleCikar(r)}
                      className="secilebilir" style={{ borderTop: '1px solid #f0f3f7',
                        background: secili ? '#eaf6ec' : undefined, cursor: 'pointer' }}>
                      <td style={{ width: 28, padding: '5px 6px', textAlign: 'center' }}>
                        <input type="checkbox" checked={secili} readOnly tabIndex={-1} /></td>
                      <td style={{ width: 90, padding: '5px 6px', color: '#667', fontFamily: 'monospace' }}>
                        {String(r.kod ?? '')}</td>
                      <td style={{ padding: '5px 6px' }}>{String(r.ad ?? '')}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          {/* ALT: sepet */}
          <div style={{ marginTop: 8, borderTop: '2px solid #e5eaf0', paddingTop: 6 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: '#1a365d', marginBottom: 4 }}>
              Seçilen İstemler ({sepet.size})</div>
            {sepet.size === 0
              ? <div style={{ fontSize: 12, color: '#9aa', padding: '2px 0' }}>
                  Soldan modalite seç, tetkiğe tıkla — burada birikir.</div>
              : <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, maxHeight: 90, overflowY: 'auto' }}>
                  {sepetListe.map(([id, k]) => (
                    <span key={id} style={{ display: 'inline-flex', alignItems: 'center', gap: 6,
                      background: '#eef4fb', border: '1px solid #cdddef', borderRadius: 14,
                      padding: '3px 6px 3px 10px', fontSize: 12 }}>
                      {k.ad || k.kod}
                      <button type="button" onClick={() =>
                        setSepet(s => { const n = new Map(s); n.delete(id); return n })}
                        style={{ border: 0, background: 'none', cursor: 'pointer', color: '#c33',
                          fontSize: 14, lineHeight: 1, padding: 0 }}>×</button>
                    </span>
                  ))}
                </div>}
          </div>
        </div>
      </div>
    </Modal>
  );
}
