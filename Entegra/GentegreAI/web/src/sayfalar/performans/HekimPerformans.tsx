import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { HekimPerformansIcmali } from '../../api/uclar/hekimPerformans';
import { paraYaz } from '../../bilesenler/bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { PerformansA4 } from './PerformansA4';
import { BolumTablosu, GrupTablosu, HekimTablosu, TrendGrafigi } from './PerformansTablolari';
import { ayAraligi, degisimRozeti } from './performansOrtak';

/**
 * HEKİM / BÖLÜM PERFORMANS İCMALİ `/hekim-performans` — mockup Ekranlar/İcmal/
 * hekim_performans_icmali.html (kullanıcı 10.10.2026: "hekim performans
 * icmalini kodla").
 *
 * Dönemde hekim / bölüm başına başvuru, hizmet, ciro, kurum / hasta payı,
 * iskonto, tahsil, hakediş ve önceki döneme göre değişim; hizmet grupları,
 * 6 aylık trend, A4. Rakamlar SUNUCUDAN (HekimPerformansUclari). Hekim
 * seçimi (tık / Ctrl / Shift) grup, trend, özet ve A4'ü süzer.
 */
type Sekme = 'hekim' | 'bolum' | 'grup' | 'trend' | 'onizleme';

const KURUM_TURLERI: [number, string][] = [[0, 'Tümü'], [1, 'Ücretli'], [3, 'SGK'], [2, 'ÖSS'], [4, 'Kurumu öder']];

export function HekimPerformans() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const kurumTuru = Number(arama.get('kurumTuru') ?? 0);
  const bolum = Number(arama.get('bolum') ?? 0);
  const seciliAnahtar = arama.get('hekimler') ?? '';
  const secili = seciliAnahtar.split(',').map(Number).filter(n => n > 0);
  const [veri, setVeri] = useState<HekimPerformansIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('hekim');
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true });
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.hekimPerformans(bas, bit, kurumTuru, bolum, seciliAnahtar ? seciliAnahtar.split(',').map(Number) : [])
      .then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, kurumTuru, bolum, seciliAnahtar]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const ayKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`);
    const y = new Date(d.getFullYear(), d.getMonth() + n, 1);
    const a = ayAraligi(y.getFullYear(), y.getMonth() + 1);
    degistir({ bas: a.bas, bit: a.bit, hekimler: '' });
  };
  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['hekim', 'Hekimler', veri.hekimler.length], ['bolum', 'Bölümler', veri.bolumler.length],
    ['grup', 'Hizmet Grupları', veri.gruplar.length], ['trend', 'Aylık Trend', null], ['onizleme', '🖨️ Önizleme (A4)', null]] : [];
  const dr = o ? degisimRozeti(o.degisim) : null;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + PERFORMANS_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Hekim Performans İcmali</h1>
          <span className="yol">İK › Hekim Performans İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <button className="hi-ana" disabled={!veri} onClick={() => window.print()}>🖨️ Yazdır (A4 Performans)</button>
        {secili.length > 0 && <span className="ki-soluk">Seçili {secili.length} hekim: özet, gruplar, trend ve A4 süzülü</span>}
        <span className="sp" />
        <button onClick={() => git('/hakedis')}>💼 Hakedişler</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">📅 Dönem:
            <button className="ki-ok" title="Önceki ay" onClick={() => ayKaydir(-1)}>‹</button>
            <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value, hekimler: '' })} />–
            <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value, hekimler: '' })} />
            <button className="ki-ok" title="Sonraki ay" onClick={() => ayKaydir(1)}>›</button>
          </div>
          <div className="sel">🏥 Bölüm:
            <select value={bolum} onChange={e => degistir({ bolum: e.target.value, hekimler: '' })}>
              <option value={0}>Tümü</option>
              {veri.bolumAdlari.map(b => <option key={b.id} value={b.id}>{b.ad}</option>)}
            </select>
          </div>
          <div className="sel">🏢 Ödeyen:
            <select value={kurumTuru} onChange={e => degistir({ kurumTuru: e.target.value, hekimler: '' })}>
              {KURUM_TURLERI.map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
            </select>
          </div>
          {secili.length > 0 && <div className="sel">☑ {secili.length} hekim <a className="ki-lnk" onClick={() => degistir({ hekimler: '' })}>temizle</a></div>}
          <span className="sp" />
          <span className="ki-soluk">karşılaştırma: {new Date(veri.donem.oncekiBas).toLocaleDateString('tr-TR')} – {new Date(veri.donem.oncekiBit).toLocaleDateString('tr-TR')}</span>
        </div>

        <div className="hi-ozet">
          {kutu('Başvuru', String(o.basvuru), `${veri.hekimler.length} hekim · ${veri.hekimsiz.basvuru} hekimsiz`)}
          {kutu('Hizmet', String(o.hizmet), 'kalem')}
          {kutu('Ciro', paraYaz(o.ciro), dr ? `önceki döneme göre ${dr.ad}` : '', 'mor')}
          {kutu('Kurum Payı', paraYaz(o.kurumPayi), `%${o.kurumOrani.toFixed(1).replace('.', ',')}`)}
          {kutu('Hasta Payı', paraYaz(o.hastaPayi), `tahsil ${paraYaz(o.tahsil)}`, 'iyi')}
          {kutu('İskonto', paraYaz(o.iskonto), o.ciro > 0 ? `ciroya oranı %${(100 * o.iskonto / o.ciro).toFixed(2).replace('.', ',')}` : '', 'uy')}
          {kutu('Hakediş', paraYaz(o.hakedis), 'dönem hakediş satırları')}
          {kutu('Ort. Başvuru', paraYaz(o.ortBasvuru), 'ciro / başvuru')}
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <div className="katab">
              {sekmeler.map(([k, ad, n]) => (
                <div key={k} className={'kat' + (sekme === k ? ' on' : '')} onClick={() => setSekme(k)}>
                  {ad}{n != null && <span className="b">{n}</span>}
                </div>
              ))}
            </div>
            {sekme === 'hekim' && <HekimTablosu v={veri} secili={secili} setSecili={s => degistir({ hekimler: s.join(',') })} />}
            {sekme === 'bolum' && <BolumTablosu v={veri} />}
            {sekme === 'grup' && <GrupTablosu v={veri} />}
            {sekme === 'trend' && <TrendGrafigi v={veri} />}
            <div className={'hi-onizleme' + (sekme === 'onizleme' ? '' : ' gizli')}>
              <PerformansA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />
            </div>
          </div>
        </div>
      </>)}
    </div>
  );
}

/** Performansa özgü: trend sütunları, A4 tablo genişliği. */
const PERFORMANS_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.hi-tablo .pf-uy { color:#8a6218; }
.hi-tablo tr.pf-soluk td { color:var(--soluk,#6b7a8b); font-style:italic; }
.pf-trend { padding:10px 4px; }
.pf-sutunlar { display:flex; gap:18px; align-items:flex-end; height:240px; padding:0 8px 8px; border-bottom:1px solid var(--cizgi,#cdd6e0); }
.pf-sutun { flex:1; display:flex; flex-direction:column; align-items:center; justify-content:flex-end; gap:3px; font-size:11px; }
.pf-cubuk { width:60%; min-height:2px; background:#2f6db3; border-radius:4px 4px 0 0; display:flex; flex-direction:column; justify-content:flex-end; overflow:hidden; }
.pf-cubuk i { display:block; width:100%; background:#6a3fb5; }
.pf-deger { font-weight:bold; color:#14315a; }
.pf-ay { font-weight:bold; }
.a4-t.pf-a4t { font-size:8.5px; }
.a4-t.pf-a4t th:nth-child(1) { width:20%; } .a4-t.pf-a4t th:nth-child(2) { width:16%; }
`;

export default HekimPerformans;
