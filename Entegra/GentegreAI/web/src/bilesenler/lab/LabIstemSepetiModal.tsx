import { useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { Modal } from '../Modal';
import { guvenli, mesaj } from '../mesaj';
import { akilciEngelKodu, akilciUyariAkisi, type AkilciKarar } from '../../sayfalar/liste/akilciIstem';
import type { ListeSatiri, Kosul } from '../../api/sozlesme';

/**
 * HEKİM LAB İSTEM EKRANI (kullanici: "dr istem yaparken her istemde kapanmasin,
 * secildikce arka gride eklensin, kapat deyince kapansin; en uste arama, solda
 * kategoriler, kategoriye basinca sagda en cok istenen ustte tetkikler").
 *
 * Tek-tek `secimSor` yerine SEPET mantigi: sol kolonda laboratuvar bolumleri +
 * Paneller, ust kutuda arama, sag listede o bolumun tetkikleri (en cok istenen
 * — `istemSay` — ustte). Satira basinca sepete eklenir/cikar; "İstem Aç" tum
 * sepeti TEK istemde gonderir (akilci uyari dongusuyle). Kapat penceres kapatir.
 */
const BOLUMLER = [
  { kod: '', ad: 'Tümü', ikon: '📋' },
  { kod: 'P', ad: 'Paneller', ikon: '📦' },
  { kod: '1', ad: 'Biyokimya', ikon: '🧪' },
  { kod: '2', ad: 'Hematoloji', ikon: '🩸' },
  { kod: '3', ad: 'Hormon', ikon: '🧬' },
  { kod: '4', ad: 'Mikrobiyoloji', ikon: '🦠' },
  { kod: '5', ad: 'Seroloji', ikon: '🧫' },
  { kod: '6', ad: 'Koagülasyon', ikon: '🩸' },
  { kod: '7', ad: 'İdrar', ikon: '💧' },
  { kod: '9', ad: 'Diğer', ikon: '🔬' },
];

type Kalem = { id: number; kod: string; ad: string; tur: 'tetkik' | 'panel' };
const anahtar = (tur: string, id: number) => `${tur[0]}${id}`;

export function LabIstemSepetiModal({ muayeneId, hastaId, onKapat, onBitti }: {
  muayeneId: number;
  hastaId?: number;
  onKapat(): void;
  /** İstem başarıyla açıldıktan sonra kartı tazele. */
  onBitti(): void;
}) {
  const [bolum, setBolum] = useState('');
  const [arama, setArama] = useState('');
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [sepet, setSepet] = useState<Map<string, Kalem>>(new Map());
  const [acil, setAcil] = useState(false);
  const [mesgul, setMesgul] = useState(false);
  const zaman = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);

  // Bölüm / arama değişince (debounce) sağ listeyi tazele.
  useEffect(() => {
    window.clearTimeout(zaman.current);
    zaman.current = window.setTimeout(() => void yukle(), 200);
    return () => window.clearTimeout(zaman.current);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [bolum, arama]);

  useEffect(() => { kutu.current?.focus() }, [bolum]);

  async function yukle() {
    setYukleniyor(true);
    try {
      const metin = arama.trim();
      const metinFiltre: Kosul | undefined = metin
        ? { op: 'or', kosullar: ['kod', 'ad', 'kisaAd'].map(alan => ({
            alan, op: 'icerir' as const, deger: metin })) }
        : undefined;
      if (bolum === 'P') {
        const p = await api.liste('lab-panel', { sayfa: 1, boyut: 100, filtre: metinFiltre });
        setSatirlar(p.satirlar);
      } else {
        const bolFiltre: Kosul | undefined = bolum
          ? { alan: 'bolum', op: 'esit', deger: Number(bolum) } : undefined;
        const filtre: Kosul | undefined = metinFiltre && bolFiltre
          ? { op: 'and', kosullar: [metinFiltre, bolFiltre] }
          : (metinFiltre ?? bolFiltre);
        const t = await api.liste('lab-tetkik', { sayfa: 1, boyut: 200, filtre });
        // EN ÇOK İSTENEN ÜSTTE (kullanici): istemSay'e göre azalan; eşitlikte kod.
        const sirali = [...t.satirlar].sort((a, b) =>
          Number(b.istemSay ?? 0) - Number(a.istemSay ?? 0)
          || String(a.kod ?? '').localeCompare(String(b.kod ?? ''), 'tr'));
        setSatirlar(sirali);
      }
    } catch { /* liste bos kalir */ }
    setYukleniyor(false);
  }

  const panelModu = bolum === 'P';
  const sepetKalem = (r: ListeSatiri): Kalem => ({
    id: Number(r.id), kod: String(r.kod ?? ''), ad: String(r.ad ?? ''),
    tur: panelModu ? 'panel' : 'tetkik',
  });
  const ekleCikar = (r: ListeSatiri) => {
    const k = sepetKalem(r);
    const a = anahtar(k.tur, k.id);
    setSepet(s => { const n = new Map(s); n.has(a) ? n.delete(a) : n.set(a, k); return n });
  };

  const istemAc = async () => {
    const kalemler = [...sepet.values()];
    if (kalemler.length === 0) { mesaj('En az bir tetkik seçin.'); return }
    setMesgul(true);
    await guvenli(async () => {
      const istek = {
        tur: 1, aciliyet: acil ? 2 : 1,
        tetkikIdler: kalemler.filter(k => k.tur === 'tetkik').map(k => k.id),
        panelIdler: kalemler.filter(k => k.tur === 'panel').map(k => k.id),
        akilci: [] as AkilciKarar[],
      };
      for (let deneme = 0; deneme < 4; deneme++) {
        try {
          const y = await api.muayeneIstemAc(muayeneId, istek);
          mesaj(y.mesaj); onBitti(); onKapat(); return;
        } catch (h) {
          if (!akilciEngelKodu(h)) throw h;
          const karar = await akilciUyariAkisi(h, hastaId);
          if (!karar) return;
          istek.akilci = [...istek.akilci, ...karar.akilci];
          if (karar.cikar.length > 0) {
            if (istek.panelIdler.length > 0) {
              mesaj('Panelin bir tetkiğinden vazgeçildi; paneli tek tek tetkik olarak isteyin.');
              return;
            }
            istek.tetkikIdler = istek.tetkikIdler.filter(t => !karar.cikar.includes(t));
            if (istek.tetkikIdler.length === 0) { mesaj('İstemde tetkik kalmadı; istem açılmadı.'); return }
          }
        }
      }
    });
    setMesgul(false);
  };

  const sepetListe = useMemo(() => [...sepet.entries()], [sepet]);

  return (
    <Modal baslik="🧪 Laboratuvar İstemi" onKapat={onKapat}
      alt={<>
        <label style={{ marginRight: 'auto', display: 'flex', alignItems: 'center', gap: 6, fontSize: 13 }}>
          <input type="checkbox" checked={acil} onChange={e => setAcil(e.target.checked)} /> Acil
        </label>
        <button className="d bir" disabled={mesgul || sepet.size === 0}
          onClick={() => void istemAc()}>✓ İstem Aç ({sepet.size})</button>
        <button className="d" onClick={onKapat}>Kapat</button>
      </>}>
      <div style={{ display: 'flex', gap: 10, minHeight: 420 }}>
        {/* SOL: kategoriler */}
        <ul style={{ listStyle: 'none', margin: 0, padding: 0, width: 168, flex: '0 0 168px',
          borderRight: '1px solid #e5eaf0', overflowY: 'auto', maxHeight: 460 }}>
          {BOLUMLER.map(b => (
            <li key={b.kod}>
              <button type="button" onClick={() => setBolum(b.kod)}
                style={{ display: 'flex', alignItems: 'center', gap: 8, width: '100%',
                  border: 0, background: bolum === b.kod ? '#2b6cb0' : 'transparent',
                  color: bolum === b.kod ? '#fff' : '#243', textAlign: 'left',
                  padding: '7px 10px', cursor: 'pointer', fontSize: 13, borderRadius: 5,
                  fontWeight: bolum === b.kod ? 700 : 400 }}>
                <span>{b.ikon}</span>{b.ad}
              </button>
            </li>
          ))}
        </ul>

        {/* SAĞ: arama + tetkik listesi */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
          <input ref={kutu} value={arama} onChange={e => setArama(e.target.value)}
            placeholder={panelModu ? 'Panel ara…' : 'Tetkik ara (kod / ad)…'}
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
                  const k = sepetKalem(r);
                  const secili = sepet.has(anahtar(k.tur, k.id));
                  return (
                    <tr key={`${k.tur}${k.id}`} onClick={() => ekleCikar(r)}
                      className="secilebilir" style={{ borderTop: '1px solid #f0f3f7',
                        background: secili ? '#eaf6ec' : undefined, cursor: 'pointer' }}>
                      <td style={{ width: 28, padding: '5px 6px', textAlign: 'center' }}>
                        <input type="checkbox" checked={secili} readOnly tabIndex={-1} /></td>
                      <td style={{ width: 88, padding: '5px 6px', color: '#667', fontFamily: 'monospace' }}>
                        {String(r.kod ?? '')}</td>
                      <td style={{ padding: '5px 6px' }}>{String(r.ad ?? '')}</td>
                      {!panelModu && (
                        <td style={{ width: 56, padding: '5px 8px', textAlign: 'right', color: '#9aa' }}
                          title="Bugüne kadar istenme sayısı">{Number(r.istemSay ?? 0) || ''}</td>
                      )}
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          {/* ALT: sepet (arka grid) */}
          <div style={{ marginTop: 8, borderTop: '2px solid #e5eaf0', paddingTop: 6 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: '#1a365d', marginBottom: 4 }}>
              Seçilen İstemler ({sepet.size})</div>
            {sepet.size === 0
              ? <div style={{ fontSize: 12, color: '#9aa', padding: '2px 0' }}>
                  Soldan bölüm seç, tetkiğe tıkla — burada birikir.</div>
              : <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, maxHeight: 90, overflowY: 'auto' }}>
                  {sepetListe.map(([a, k]) => (
                    <span key={a} style={{ display: 'inline-flex', alignItems: 'center', gap: 6,
                      background: '#eef4fb', border: '1px solid #cdddef', borderRadius: 14,
                      padding: '3px 6px 3px 10px', fontSize: 12 }}>
                      {k.tur === 'panel' ? '📦 ' : ''}{k.ad || k.kod}
                      <button type="button" onClick={() =>
                        setSepet(s => { const n = new Map(s); n.delete(a); return n })}
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
