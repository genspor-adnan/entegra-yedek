import { useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { Modal } from './Modal';
import { guvenli, mesaj } from './mesaj';
import { akilciEngelKodu, akilciUyariAkisi, type AkilciKarar } from '../sayfalar/liste/akilciIstem';
import { hataMetni, type ListeSatiri, type Kosul } from '../api/sozlesme';

/**
 * BİRLEŞİK İSTEM EKRANI (kullanici: "lab ve radyoloji istemi birleştir, tek
 * istem ekranı olsun; soldaki kategori için Laboratuvar ve Radyoloji sekmesi").
 *
 * Üstte iki sekme (Laboratuvar / Radyoloji). Sekme LABsa sol kategori =
 * laboratuvar bölümleri + Paneller, sağ liste lab-tetkik/lab-panel; RADsa sol
 * kategori = modaliteler, sağ liste modalitesi olan HİZMET. Tetkiğe tıkla →
 * ortak SEPETE eklenir (sekme değişse de durur). "İstem Aç" sepetteki lab
 * tetkik/panellerini TEK lab isteminde, radyoloji tetkiklerini ayrı ayrı
 * radyoloji isteminde açar; "Kapat" ile kapanır.
 *
 * ŞABLON PANELLERİ (931, kullanıcı: "panelleri istem ekranına bağla"):
 * muayenenin bölüm/doktor şablonlarında tanımlı paneller Laboratuvar'ın en
 * üstünde "⭐ Şablon Panelleri" kategorisidir; varsa ekran o kategoriyle açılır.
 */
type Sekme = 'lab' | 'radyoloji';
type KalemTur = 'tetkik' | 'panel' | 'radyoloji';
type Kalem = { grup: Sekme; tur: KalemTur; id: number; kod: string; ad: string };
const anahtar = (k: { tur: KalemTur; id: number }) => `${k.tur[0]}${k.id}`;

/** Şablon panelleri kategorisi (yalnız muayenenin şablonunda panel varsa çıkar). */
const SABLON = 'S';
/** YZ önerisi kategorisi (iki sekmede de; lab + görüntüleme birlikte). */
const YZ = 'YZ';
const LAB_BOLUMLER = [
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

export function IstemSepetiModal({ muayeneId, hastaId, baslangicSekme = 'lab', onKapat, onBitti }: {
  muayeneId: number;
  hastaId?: number;
  baslangicSekme?: Sekme;
  onKapat(): void;
  onBitti(): void;
}) {
  const [sekme, setSekme] = useState<Sekme>(baslangicSekme);
  const [kategori, setKategori] = useState('');   // lab bölüm/'P' veya modalite
  const [arama, setArama] = useState('');
  const [satirlar, setSatirlar] = useState<{ satir: ListeSatiri; tur: KalemTur }[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [sepet, setSepet] = useState<Map<string, Kalem>>(new Map());
  const [acil, setAcil] = useState(false);
  const [mesgul, setMesgul] = useState(false);
  const zaman = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);
  /** Bölüm/doktor şablonlarının panelleri (931). */
  const [sablonPanel, setSablonPanel] = useState<ListeSatiri[]>([]);
  /** Kullanıcı kategori seçtiyse şablon yanıtı onu ezmez. */
  const elleSecti = useRef(false);
  /** YZ tetkik önerisi: kategori ilk seçilince BİR KEZ istenir (kontör). */
  const [yz, setYz] = useState<{ satirlar: { satir: ListeSatiri; tur: KalemTur }[]; notlar: string[]; uyari: string } | null>(null);
  const [yzHata, setYzHata] = useState<string | null>(null);
  const yzIstendi = useRef(false);

  useEffect(() => {
    let iptal = false;
    void api.muayeneSablonTercihleri(muayeneId).then(y => {
      if (iptal) return;
      const p = y.paneller.map(x => ({ id: x.id, kod: x.kod, ad: x.ad }) as ListeSatiri);
      setSablonPanel(p);
      if (p.length > 0 && !elleSecti.current && baslangicSekme === 'lab') setKategori(SABLON);
    }).catch(() => { /* şablon paneli yoksa kategori çıkmaz */ });
    return () => { iptal = true };
  }, [muayeneId, baslangicSekme]);

  // Sekme değişince kategori sıfırlanır (Tümü).
  const sekmeSec = (s: Sekme) => { elleSecti.current = true; setSekme(s); setKategori(''); setArama('') };

  useEffect(() => {
    window.clearTimeout(zaman.current);
    zaman.current = window.setTimeout(() => void yukle(), 200);
    return () => window.clearTimeout(zaman.current);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sekme, kategori, arama, sablonPanel]);

  useEffect(() => { kutu.current?.focus() }, [sekme, kategori]);

  async function yukle() {
    setYukleniyor(true);
    try {
      const metin = arama.trim();
      const metinFiltre: Kosul | undefined = metin
        ? { op: 'or', kosullar: ['kod', 'ad', 'kisaAd'].map(alan => ({
            alan, op: 'icerir' as const, deger: metin })) }
        : undefined;

      if (sekme === 'radyoloji') {
        // Modalitesi olan hizmetler = radyoloji tetkikleri.
        const modFiltre: Kosul = kategori
          ? { alan: 'modalite', op: 'esit', deger: Number(kategori) }
          : { alan: 'modalite', op: 'buyuk', deger: 0 };
        const filtre: Kosul = metinFiltre ? { op: 'and', kosullar: [metinFiltre, modFiltre] } : modFiltre;
        const t = await api.liste('hizmet', { sayfa: 1, boyut: 200, filtre });
        const sirali = [...t.satirlar].sort((a, b) =>
          String(a.ad ?? '').localeCompare(String(b.ad ?? ''), 'tr'));
        setSatirlar(sirali.map(s => ({ satir: s, tur: 'radyoloji' as const })));
        return;
      }

      // LAB. lab-panel'de kisaAd yok - panel araması kod/ad.
      const panelFiltre: Kosul | undefined = metin
        ? { op: 'or', kosullar: ['kod', 'ad'].map(alan => ({ alan, op: 'icerir' as const, deger: metin })) }
        : undefined;
      if (kategori === YZ) {
        if (!yzIstendi.current) {
          yzIstendi.current = true;
          try {
            const y = await api.muayeneYzTetkikOnerisi(muayeneId);
            const satirlar = y.oneriler.map(o => ({
              satir: { id: o.id, kod: o.kod, ad: o.ad, gerekce: o.gerekce } as ListeSatiri, tur: o.tur as KalemTur }));
            const notlar = [y.not, y.atilan > 0 ? `${y.atilan} öneri katalogda bulunamadığı için gösterilmedi.` : '',
                            satirlar.length === 0 ? 'YZ bu bilgilerle tetkik önermedi.' : ''].filter(Boolean);
            setYz({ satirlar, notlar, uyari: y.uyari });
            setYzHata(null);
          } catch (h) { setYzHata(hataMetni(h)); yzIstendi.current = false }
        }
        return;
      }
      if (kategori === SABLON) {
        const k = metin.toLocaleLowerCase('tr');
        setSatirlar(sablonPanel
          .filter(r => !k || `${String(r.kod ?? '')} ${String(r.ad ?? '')}`.toLocaleLowerCase('tr').includes(k))
          .map(s => ({ satir: s, tur: 'panel' as const })));
        return;
      }
      if (kategori === 'P') {
        const p = await api.liste('lab-panel', { sayfa: 1, boyut: 100, filtre: panelFiltre });
        setSatirlar(p.satirlar.map(s => ({ satir: s, tur: 'panel' as const })));
        return;
      }
      // Paneller aramada VEYA "Tümü"de üstte gösterilir (Hemogram/TİT panel'dir).
      const panelIster = kategori === '' || !!metin;
      const [t, p] = await Promise.all([
        api.liste('lab-tetkik', {
          sayfa: 1, boyut: 200,
          filtre: metinFiltre && kategori
            ? { op: 'and', kosullar: [metinFiltre, { alan: 'bolum', op: 'esit', deger: Number(kategori) }] }
            : (metinFiltre ?? (kategori ? { alan: 'bolum', op: 'esit', deger: Number(kategori) } : undefined)),
        }),
        panelIster
          ? api.liste('lab-panel', { sayfa: 1, boyut: 100, filtre: panelFiltre })
          : Promise.resolve({ satirlar: [] as ListeSatiri[] }),
      ]);
      const tetkikler = [...t.satirlar].sort((a, b) =>
        Number(b.istemSay ?? 0) - Number(a.istemSay ?? 0)
        || String(a.kod ?? '').localeCompare(String(b.kod ?? ''), 'tr'));
      setSatirlar([
        ...p.satirlar.map(s => ({ satir: s, tur: 'panel' as const })),
        ...tetkikler.map(s => ({ satir: s, tur: 'tetkik' as const })),
      ]);
    } catch { /* liste bos kalir */ }
    // FINALLY: dallar erken donuyor (panel / radyoloji / sablon); "Yükleniyor…"
    //   yazisi liste gelse de ekranda kaliyordu.
    finally { setYukleniyor(false) }
  }

  // GRUP TÜRDEN: YZ kategorisi lab ve görüntülemeyi birlikte listeler; sekmeden
  //   alınsaydı lab sekmesinde önerilen görüntüleme lab istemine karışırdı.
  const kalemYap = (r: ListeSatiri, tur: KalemTur): Kalem => ({
    grup: tur === 'radyoloji' ? 'radyoloji' : 'lab', tur, id: Number(r.id), kod: String(r.kod ?? ''), ad: String(r.ad ?? ''),
  });
  const ekleCikar = (r: ListeSatiri, tur: KalemTur) => {
    const k = kalemYap(r, tur);
    const a = anahtar(k);
    setSepet(s => { const n = new Map(s); n.has(a) ? n.delete(a) : n.set(a, k); return n });
  };

  const istemAc = async () => {
    const kalemler = [...sepet.values()];
    if (kalemler.length === 0) { mesaj('En az bir tetkik seçin.'); return }
    const aciliyet = acil ? 2 : 1;
    const labTetkik = kalemler.filter(k => k.tur === 'tetkik').map(k => k.id);
    const labPanel = kalemler.filter(k => k.tur === 'panel').map(k => k.id);
    const radyoloji = kalemler.filter(k => k.tur === 'radyoloji');

    setMesgul(true);
    await guvenli(async () => {
      let acildi = 0;
      const hatalar: string[] = [];

      // LAB: tek istem (tetkik + panel), akılcı uyarı döngüsüyle.
      if (labTetkik.length + labPanel.length > 0) {
        const istek = { tur: 1, aciliyet, tetkikIdler: [...labTetkik], panelIdler: [...labPanel],
                        akilci: [] as AkilciKarar[] };
        for (let deneme = 0; deneme < 4; deneme++) {
          try { await api.muayeneIstemAc(muayeneId, istek); acildi++; break; }
          catch (h) {
            if (!akilciEngelKodu(h)) { hatalar.push('laboratuvar'); break; }
            const karar = await akilciUyariAkisi(h, hastaId);
            if (!karar) break;
            istek.akilci = [...istek.akilci, ...karar.akilci];
            if (karar.cikar.length > 0) {
              if (istek.panelIdler.length > 0) { mesaj('Panelin bir tetkiğinden vazgeçildi; paneli tek tek isteyin.'); break }
              istek.tetkikIdler = istek.tetkikIdler.filter(t => !karar.cikar.includes(t));
              if (istek.tetkikIdler.length === 0) break;
            }
          }
        }
      }

      // RADYOLOJİ: her hizmet ayrı istem.
      for (const k of radyoloji) {
        try { await api.muayeneIstemAc(muayeneId, { tur: 2, hizmetId: k.id, aciliyet }); acildi++; }
        catch { hatalar.push(k.ad || k.kod); }
      }

      mesaj(hatalar.length === 0
        ? `${acildi} istem açıldı.`
        : `${acildi} istem açıldı; başarısız: ${hatalar.join(', ')}.`);
      if (acildi > 0) { onBitti(); onKapat(); }
    });
    setMesgul(false);
  };

  const yzKategori = { kod: YZ, ad: 'YZ Önerisi', ikon: '🤖' };
  const kategoriler = [yzKategori, ...(sekme === 'lab'
    ? (sablonPanel.length > 0
        ? [{ kod: SABLON, ad: `Şablon Panelleri (${sablonPanel.length})`, ikon: '⭐' }, ...LAB_BOLUMLER]
        : LAB_BOLUMLER)
    : MODALITELER)];
  // YZ kategorisinde liste YZ yanıtından (arama metniyle süzülür).
  const gorunenSatirlar = kategori === YZ
    ? (yz?.satirlar ?? []).filter(({ satir: r }) => !arama.trim()
        || `${String(r.kod ?? '')} ${String(r.ad ?? '')}`.toLocaleLowerCase('tr').includes(arama.trim().toLocaleLowerCase('tr')))
    : satirlar;
  const sepetListe = useMemo(() => [...sepet.entries()], [sepet]);
  const labSay = useMemo(() => [...sepet.values()].filter(k => k.grup === 'lab').length, [sepet]);
  const radSay = sepet.size - labSay;

  const sekmeDug = (s: Sekme): React.CSSProperties => ({
    flex: 1, border: 0, padding: '8px 6px', cursor: 'pointer', fontSize: 13,
    fontWeight: sekme === s ? 700 : 500,
    background: sekme === s ? '#2b6cb0' : '#eef2f7',
    color: sekme === s ? '#fff' : '#33506e',
    borderRadius: s === 'lab' ? '6px 0 0 0' : '0 6px 0 0',
  });

  return (
    <Modal baslik="🧾 Tetkik İstemi (Lab + Radyoloji)" onKapat={onKapat}
      alt={<>
        <label style={{ marginRight: 'auto', display: 'flex', alignItems: 'center', gap: 6, fontSize: 13 }}>
          <input type="checkbox" checked={acil} onChange={e => setAcil(e.target.checked)} /> Acil
        </label>
        <button className="d bir" disabled={mesgul || sepet.size === 0}
          onClick={() => void istemAc()}>✓ İstem Aç ({sepet.size})</button>
        <button className="d" onClick={onKapat}>Kapat</button>
      </>}>
      <div style={{ display: 'flex', gap: 10, minHeight: 430 }}>
        {/* SOL: sekme + kategoriler */}
        <div style={{ width: 176, flex: '0 0 176px', display: 'flex', flexDirection: 'column' }}>
          <div style={{ display: 'flex' }}>
            <button type="button" style={sekmeDug('lab')}
              onClick={() => sekmeSec('lab')}>🧪 Laboratuvar{labSay > 0 ? ` (${labSay})` : ''}</button>
            <button type="button" style={sekmeDug('radyoloji')}
              onClick={() => sekmeSec('radyoloji')}>📷 Radyoloji{radSay > 0 ? ` (${radSay})` : ''}</button>
          </div>
          <ul style={{ listStyle: 'none', margin: 0, padding: 0, overflowY: 'auto', maxHeight: 400,
            border: '1px solid #e5eaf0', borderTop: 0, borderRadius: '0 0 6px 6px', flex: 1 }}>
            {kategoriler.map(k => (
              <li key={k.kod}>
                <button type="button" onClick={() => { elleSecti.current = true; setKategori(k.kod) }}
                  style={{ display: 'flex', alignItems: 'center', gap: 8, width: '100%',
                    border: 0, background: kategori === k.kod ? '#dbe8f7' : 'transparent',
                    color: '#243', textAlign: 'left', padding: '7px 10px', cursor: 'pointer',
                    fontSize: 13, fontWeight: kategori === k.kod ? 700 : 400 }}>
                  <span>{k.ikon}</span>{k.ad}
                </button>
              </li>
            ))}
          </ul>
        </div>

        {/* SAĞ: arama + liste + sepet */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
          <input ref={kutu} value={arama} onChange={e => setArama(e.target.value)}
            placeholder={sekme === 'lab' ? 'Tetkik / panel ara (Hemogram, TİT, kod…)' : 'Tetkik ara (kod / ad)…'}
            style={{ padding: '8px 10px', fontSize: 14, border: '1px solid #cbd5e0',
              borderRadius: 6, marginBottom: 8 }} />
          <div style={{ flex: 1, overflowY: 'auto', border: '1px solid #eef', borderRadius: 6, maxHeight: 340 }}>
            {kategori === YZ && yzHata && <div className="hata-kutusu" style={{ margin: 8 }}>{yzHata}</div>}
            {kategori === YZ && yz && (
              <div className="rk-bant mavi yz-not" style={{ margin: 8 }}>
                <b>🤖 {yz.uyari}</b>
                {yz.notlar.map(n => <div key={n}>{n}</div>)}
              </div>
            )}
            {yukleniyor && <div style={{ padding: 12, color: '#889' }}>{kategori === YZ ? 'YZ öneriyor…' : 'Yükleniyor…'}</div>}
            {!yukleniyor && gorunenSatirlar.length === 0 && !(kategori === YZ && (yzHata || yz)) &&
              <div style={{ padding: 12, color: '#889' }}>Sonuç yok.</div>}
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
              <tbody>
                {gorunenSatirlar.map(({ satir: r, tur }) => {
                  const k = kalemYap(r, tur);
                  const secili = sepet.has(anahtar(k));
                  return (
                    <tr key={`${tur}${r.id}`} onClick={() => ekleCikar(r, tur)}
                      className="secilebilir" style={{ borderTop: '1px solid #f0f3f7',
                        background: secili ? '#eaf6ec' : undefined, cursor: 'pointer' }}>
                      <td style={{ width: 26, padding: '5px 4px', textAlign: 'center' }}>
                        <input type="checkbox" checked={secili} readOnly tabIndex={-1} /></td>
                      <td style={{ width: 28, padding: '5px 2px', textAlign: 'center' }}>
                        {tur === 'panel' ? '📦' : tur === 'radyoloji' ? '📷' : ''}</td>
                      <td style={{ width: 84, padding: '5px 6px', color: '#667', fontFamily: 'monospace' }}>
                        {String(r.kod ?? '')}</td>
                      <td style={{ padding: '5px 6px' }}>{String(r.ad ?? '')}
                        {r.gerekce ? <div className="yz-gerekce">{String(r.gerekce)}</div> : null}</td>
                      <td style={{ width: 52, padding: '5px 8px', textAlign: 'right', color: '#9aa' }}
                        title="Bugüne kadar istenme sayısı">
                        {tur === 'tetkik' ? (Number(r.istemSay ?? 0) || '') : ''}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          {/* ALT: ortak sepet (lab + radyoloji) */}
          <div style={{ marginTop: 8, borderTop: '2px solid #e5eaf0', paddingTop: 6 }}>
            <div style={{ fontSize: 12, fontWeight: 700, color: '#1a365d', marginBottom: 4 }}>
              Seçilen İstemler ({sepet.size}) · Lab {labSay} · Radyoloji {radSay}</div>
            {sepet.size === 0
              ? <div style={{ fontSize: 12, color: '#9aa', padding: '2px 0' }}>
                  Sekme + kategori seç, tetkiğe tıkla — burada birikir (lab ve radyoloji birlikte).</div>
              : <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, maxHeight: 88, overflowY: 'auto' }}>
                  {sepetListe.map(([a, k]) => (
                    <span key={a} style={{ display: 'inline-flex', alignItems: 'center', gap: 6,
                      background: k.grup === 'radyoloji' ? '#f3eefb' : '#eef4fb',
                      border: `1px solid ${k.grup === 'radyoloji' ? '#d9cdef' : '#cdddef'}`,
                      borderRadius: 14, padding: '3px 6px 3px 10px', fontSize: 12 }}>
                      {k.tur === 'panel' ? '📦 ' : k.tur === 'radyoloji' ? '📷 ' : ''}{k.ad || k.kod}
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
