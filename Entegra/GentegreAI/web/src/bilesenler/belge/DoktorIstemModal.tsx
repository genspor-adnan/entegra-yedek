import { useState } from 'react';
import { api } from '../../api/istemci';
import { Modal } from '../Modal';
import { guvenli, mesaj } from '../mesaj';
import { paraYaz } from '../bicim';
import type { BekleyenIstem, BekleyenIstemYaniti } from '../../api/uclar/basvuruIstem';

/**
 * DOKTOR İSTEMİ — ÜCRETE EKLE. Hekimin muayenede açtığı bekleyen (serbest=0)
 * lab/radyoloji istemleri GRID olarak listelenir (kullanıcı): Laboratuvar ve
 * Görüntüleme diye iki grup, varsayılan HEPSİ seçili. Banko seçtiklerini
 * ücrete ekler; hasta pahalı tetkikten vazgeçerse işareti kaldırılır - yalnız
 * seçilenler laboratuvara/röntgene düşer.
 *
 * FİYATLAR sağda, HASTANIN KURUMUNA göre: başvurunun fiyat listesi +
 * sözleşme iskontosu. Rakamlar sunucudan gelir (ücretlendirmeyle aynı
 * kural); ekran yalnızca seçili satırların tutarlarını grup ve genel toplam
 * olarak toplar. Asıl belge toplamı ücrete eklendikten sonra dip toplamdadır.
 */
const GRUPLAR: { tur: BekleyenIstem['tur']; ad: string; ic: string }[] = [
  { tur: 'lab', ad: 'Laboratuvar', ic: '🧪' },
  { tur: 'radyoloji', ad: 'Görüntüleme', ic: '📷' },
];

const sag: React.CSSProperties = { textAlign: 'right', padding: '5px 8px', whiteSpace: 'nowrap' };
const hucre: React.CSSProperties = { padding: '5px 8px' };

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

  const grupSatirlari = (tur: BekleyenIstem['tur']) => hepsi.filter(x => x.tur === tur);
  const seciliToplam = (satirlar: BekleyenIstem[]) =>
    satirlar.filter(x => secili.has(anahtar(x))).reduce((t, x) => t + (x.tutar ?? 0), 0);

  // Satıra tıklamak ANINDA seçer/kaldırır.
  const tikla = (k: string) => setSecili(s => {
    const n = new Set(s); n.has(k) ? n.delete(k) : n.add(k); return n;
  });
  const grupTikla = (tur: BekleyenIstem['tur'], ac: boolean) => setSecili(s => {
    const n = new Set(s);
    for (const x of grupSatirlari(tur)) { const k = anahtar(x); ac ? n.add(k) : n.delete(k); }
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

  const genelToplam = seciliToplam(hepsi);

  return (
    <Modal baslik="🩺 Doktor İstemleri — Ücrete Ekle" onKapat={onKapat}
      alt={<>
        <button className="d bir" disabled={mesgul || secili.size === 0}
          onClick={() => void ucretle()}>✓ Seçilenleri Ücrete Ekle ({secili.size})</button>
        <button className="d" onClick={onKapat}>Kapat</button>
      </>}>
      <div style={{ display: 'flex', gap: 12, padding: '4px 2px', fontSize: 12, color: '#667' }}>
        <span>Hekimin istediği tetkikler. Hasta vazgeçtiyse işareti kaldır; yalnız seçilenler
          ücrete eklenir ve çalışma listesine düşer.</span>
        <span style={{ marginLeft: 'auto', whiteSpace: 'nowrap' }} title="Fiyatların dayanağı">
          Kurum: <b>{veri.kurum || 'Ücretli (kurum yok)'}</b>
          {veri.sozlesme ? <> · {veri.sozlesme}</> : null}
        </span>
      </div>

      <table className="doktor-istem-grid"
             style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
        <thead>
          <tr style={{ background: '#f4f6fa', color: '#445', textAlign: 'left' }}>
            <th style={{ width: 30 }} />
            <th style={hucre}>Tetkik</th>
            <th style={hucre}>Kategori</th>
            <th style={{ ...hucre, width: 60 }}>Öncelik</th>
            <th style={{ ...sag, width: 100 }}>Fiyat</th>
            <th style={{ ...sag, width: 60 }}>İsk. %</th>
            <th style={{ ...sag, width: 110 }}>Tutar</th>
          </tr>
        </thead>
        {GRUPLAR.map(g => {
          const satirlar = grupSatirlari(g.tur);
          if (satirlar.length === 0) return null;
          const seciliSayi = satirlar.filter(x => secili.has(anahtar(x))).length;
          return (
            <tbody key={g.tur}>
              <tr style={{ background: '#eef4fb', color: '#1a365d', fontWeight: 700 }}>
                <td style={hucre}>
                  <input type="checkbox" checked={seciliSayi === satirlar.length}
                    ref={el => { if (el) el.indeterminate = seciliSayi > 0 && seciliSayi < satirlar.length }}
                    onChange={e => grupTikla(g.tur, e.target.checked)} />
                </td>
                <td style={hucre} colSpan={5}>
                  {g.ic} {g.ad}{' '}
                  <span style={{ fontWeight: 400, opacity: 0.7 }}>{seciliSayi}/{satirlar.length}</span>
                </td>
                <td style={sag}>{paraYaz(seciliToplam(satirlar))}</td>
              </tr>
              {satirlar.map(x => {
                const k = anahtar(x);
                const sec = secili.has(k);
                return (
                  <tr key={k} onClick={() => tikla(k)} className="secilebilir"
                      style={{ borderTop: '1px solid #eef', cursor: 'pointer',
                               background: sec ? undefined : '#fafafa',
                               color: sec ? undefined : '#999' }}>
                    <td style={hucre}>
                      <input type="checkbox" checked={sec} onChange={() => tikla(k)}
                        onClick={e => e.stopPropagation()} />
                    </td>
                    <td style={hucre}>
                      {x.tetkik}
                      {x.ucrette && <span className="rz" style={{ marginLeft: 6 }}
                        title="Bu hizmet başvuruda zaten ücretli; tekrar eklenmez">ücrette</span>}
                      {x.hizmetYok && <span className="rz kir" style={{ marginLeft: 6 }}
                        title="Tetkiğin hizmet kartı tanımsız; fiyatlanamaz">hizmet yok</span>}
                    </td>
                    <td style={hucre}>{x.kategori}</td>
                    <td style={hucre}>{x.oncelik >= 2 ? <span className="rz kir">Acil</span> : ''}</td>
                    <td style={sag}>{paraYaz(x.fiyat)}</td>
                    <td style={sag}>{x.iskonto ? `%${x.iskonto}` : ''}</td>
                    <td style={{ ...sag, fontWeight: 600 }}>{paraYaz(x.tutar)}</td>
                  </tr>
                );
              })}
            </tbody>
          );
        })}
        <tfoot>
          {GRUPLAR.filter(g => grupSatirlari(g.tur).length > 0).map(g => (
            <tr key={g.tur} style={{ color: '#445' }}>
              <td />
              <td colSpan={5} style={{ ...sag }}>{g.ic} {g.ad} (seçili)</td>
              <td style={sag}>{paraYaz(seciliToplam(grupSatirlari(g.tur)))}</td>
            </tr>
          ))}
          <tr style={{ borderTop: '2px solid #2b6cb0', fontWeight: 700, color: '#1a365d' }}>
            <td />
            <td colSpan={5} style={sag}>Seçilenlerin toplamı ({secili.size})</td>
            <td style={sag}>{paraYaz(genelToplam)}</td>
          </tr>
        </tfoot>
      </table>
    </Modal>
  );
}
