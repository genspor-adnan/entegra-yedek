import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { Modal } from './Modal';
import { guvenli, mesaj } from './mesaj';
import { c } from '../dil/ceviri';

/**
 * VÜCUT ŞEMASI (kullanıcı: Şablon Muayene'de "Vücut şeması" düğmesi; seçim
 * "bölge seç, bulguya yaz").
 *
 * Ön ve arka figür; tıklanan bölge işaretlenir, isteğe bağlı kısa not.
 * Kaydet sunucuya bölge ADLARINI gönderir - sunucu şablonun vücut şeması
 * satırına yazar (metin özete/rapora, liste deger_json'a). Ekran kural
 * içermez; bölge adları yalnız etikettir.
 *
 * <b>Taraf:</b> ön görünümde hastanın SAĞI ekranın SOLUNDADIR (karşıdan
 * bakış); arka görünümde aynı yöndedir. Ad her bölgede açıkça yazar.
 */
type Bolge = { ad: string; e?: [number, number, number, number]; r?: [number, number, number, number] };

// Koordinatlar 200 x 410 figür içinde. e = elips (cx, cy, rx, ry), r = dikdörtgen (x, y, w, h).
const ON: Bolge[] = [
  { ad: 'Baş / yüz', e: [100, 30, 21, 25] },
  { ad: 'Boyun (ön)', r: [90, 55, 20, 14] },
  { ad: 'Sağ omuz', r: [50, 69, 25, 19] },
  { ad: 'Sol omuz', r: [125, 69, 25, 19] },
  { ad: 'Göğüs sağ', r: [75, 69, 25, 45] },
  { ad: 'Göğüs sol', r: [100, 69, 25, 45] },
  { ad: 'Karın sağ üst', r: [75, 114, 25, 34] },
  { ad: 'Karın sol üst', r: [100, 114, 25, 34] },
  { ad: 'Karın sağ alt', r: [75, 148, 25, 34] },
  { ad: 'Karın sol alt', r: [100, 148, 25, 34] },
  { ad: 'Kasık / genital', r: [78, 182, 44, 22] },
  { ad: 'Sağ üst kol (ön)', r: [48, 88, 22, 55] },
  { ad: 'Sol üst kol (ön)', r: [130, 88, 22, 55] },
  { ad: 'Sağ ön kol', r: [42, 143, 20, 54] },
  { ad: 'Sol ön kol', r: [138, 143, 20, 54] },
  { ad: 'Sağ el', r: [37, 197, 22, 26] },
  { ad: 'Sol el', r: [141, 197, 22, 26] },
  { ad: 'Sağ uyluk (ön)', r: [77, 204, 22, 76] },
  { ad: 'Sol uyluk (ön)', r: [101, 204, 22, 76] },
  { ad: 'Sağ diz', r: [77, 280, 22, 20] },
  { ad: 'Sol diz', r: [101, 280, 22, 20] },
  { ad: 'Sağ bacak (ön)', r: [78, 300, 20, 80] },
  { ad: 'Sol bacak (ön)', r: [102, 300, 20, 80] },
  { ad: 'Sağ ayak', r: [72, 380, 26, 16] },
  { ad: 'Sol ayak', r: [102, 380, 26, 16] },
];

// Arka görünümde hastanın SOLU ekranın solunda.
const ARKA: Bolge[] = [
  { ad: 'Baş (arka)', e: [100, 30, 21, 25] },
  { ad: 'Ense', r: [90, 55, 20, 14] },
  { ad: 'Sol omuz (arka)', r: [50, 69, 25, 19] },
  { ad: 'Sağ omuz (arka)', r: [125, 69, 25, 19] },
  { ad: 'Sırt sol üst', r: [75, 69, 25, 45] },
  { ad: 'Sırt sağ üst', r: [100, 69, 25, 45] },
  { ad: 'Bel sol', r: [75, 114, 25, 68] },
  { ad: 'Bel sağ', r: [100, 114, 25, 68] },
  { ad: 'Sakrum', r: [88, 168, 24, 14] },
  { ad: 'Sol kalça', r: [76, 182, 24, 26] },
  { ad: 'Sağ kalça', r: [100, 182, 24, 26] },
  { ad: 'Sol üst kol (arka)', r: [48, 88, 22, 55] },
  { ad: 'Sağ üst kol (arka)', r: [130, 88, 22, 55] },
  { ad: 'Sol dirsek / ön kol (arka)', r: [42, 143, 20, 54] },
  { ad: 'Sağ dirsek / ön kol (arka)', r: [138, 143, 20, 54] },
  { ad: 'Sol el sırtı', r: [37, 197, 22, 26] },
  { ad: 'Sağ el sırtı', r: [141, 197, 22, 26] },
  { ad: 'Sol uyluk (arka)', r: [77, 208, 22, 72] },
  { ad: 'Sağ uyluk (arka)', r: [101, 208, 22, 72] },
  { ad: 'Sol diz arkası', r: [77, 280, 22, 20] },
  { ad: 'Sağ diz arkası', r: [101, 280, 22, 20] },
  { ad: 'Sol baldır', r: [78, 300, 20, 80] },
  { ad: 'Sağ baldır', r: [102, 300, 20, 80] },
  { ad: 'Sol topuk', r: [72, 380, 26, 16] },
  { ad: 'Sağ topuk', r: [102, 380, 26, 16] },
];

function Figur({ baslik, bolgeler, secili, sec }: {
  baslik: string; bolgeler: Bolge[]; secili: Set<string>; sec(ad: string): void;
}) {
  return (
    <figure className="vs-figur">
      <figcaption>{baslik}</figcaption>
      <svg viewBox="0 0 200 410" role="group" aria-label={baslik}>
        {bolgeler.map(b => {
          const on = secili.has(b.ad);
          const ortak = {
            className: `vs-bolge${on ? ' on' : ''}`,
            role: 'checkbox' as const, 'aria-checked': on, 'aria-label': b.ad, tabIndex: 0,
            onClick: () => sec(b.ad),
            onKeyDown: (e: React.KeyboardEvent) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); sec(b.ad) } },
          };
          return b.e
            ? <ellipse key={b.ad} {...ortak} cx={b.e[0]} cy={b.e[1]} rx={b.e[2]} ry={b.e[3]}><title>{b.ad}</title></ellipse>
            : <rect key={b.ad} {...ortak} x={b.r![0]} y={b.r![1]} width={b.r![2]} height={b.r![3]} rx={6}><title>{b.ad}</title></rect>;
        })}
      </svg>
    </figure>
  );
}

export function VucutSemasi({ muayeneId, onKapat, onKaydedildi }: {
  muayeneId: number; onKapat(): void; onKaydedildi(): void;
}) {
  const [secili, setSecili] = useState<Set<string>>(new Set());
  const [not, setNot] = useState('');
  const [yuklendi, setYuklendi] = useState(false);

  useEffect(() => {
    let iptal = false;
    void api.muayeneVucutSemasi(muayeneId).then(y => {
      if (iptal) return;
      setSecili(new Set(y.bolgeler)); setNot(y.not); setYuklendi(true);
    }).catch(() => setYuklendi(true));
    return () => { iptal = true };
  }, [muayeneId]);

  const sec = (ad: string) => setSecili(s => {
    const y = new Set(s);
    if (y.has(ad)) y.delete(ad); else y.add(ad);
    return y;
  });

  // Seçim sırası figür sırasıdır (önce ön, sonra arka) - metin hep aynı düzende.
  const sirali = [...ON, ...ARKA].map(b => b.ad).filter(ad => secili.has(ad));

  const kaydet = () => guvenli(async () => {
    const y = await api.muayeneVucutSemasiKaydet(muayeneId, { bolgeler: sirali, not });
    mesaj(y.mesaj);
    onKaydedildi();
    onKapat();
  });

  return (
    <Modal baslik={c('Vücut şeması')} onKapat={onKapat} buyutmeYok
      alt={<>
        <button type="button" className="d bir" disabled={!yuklendi} onClick={() => void kaydet()}>
          💾 {c('Bulguya yaz')}
        </button>
        <button type="button" className="d" onClick={() => setSecili(new Set())}>{c('Seçimi temizle')}</button>
        <span style={{ marginLeft: 'auto' }} />
        <button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>
      </>}>
      <div className="vs-gvd">
        <div className="vs-figurler">
          <Figur baslik={c('Ön')} bolgeler={ON} secili={secili} sec={sec} />
          <Figur baslik={c('Arka')} bolgeler={ARKA} secili={secili} sec={sec} />
        </div>
        <div className="vs-sag">
          <h6>{c('Seçilen bölgeler')} <span className="not">({sirali.length})</span></h6>
          <div className="vs-cipler">
            {sirali.length === 0 && <span className="not">{c('Figür üzerinde bölgeye tıklayın.')}</span>}
            {sirali.map(ad => (
              <button key={ad} type="button" className="rozet mavi vs-cip" title={c('Kaldır')}
                      onClick={() => sec(ad)}>{ad} ✕</button>
            ))}
          </div>
          <label className="vs-not">{c('Not (lezyon, boyut, özellik)')}
            <textarea value={not} maxLength={500} rows={4} onChange={e => setNot(e.target.value)}
                      placeholder={c('ör. 2 cm eritemli plak, kaşıntılı')} />
          </label>
          <p className="not">{c('Ön görünümde hastanın sağı ekranın solundadır. Yazılan metin şablondaki "Vücut şeması" bulgusuna ve muayene özetine geçer.')}</p>
        </div>
      </div>
    </Modal>
  );
}
