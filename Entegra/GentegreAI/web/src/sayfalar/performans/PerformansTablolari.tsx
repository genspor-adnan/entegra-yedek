import { useRef, type MouseEvent } from 'react';
import type { HekimPerformansIcmali, PerformansDegeri } from '../../api/uclar/hekimPerformans';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { AY_KISA, degisimRozeti } from './performansOrtak';

/** Hekim performans icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

/** Ortak değer sütunları (hekim ve bölüm tablosu aynı sırada). */
const BASLIKLAR = ['Başvuru', 'Hizmet', 'Ciro', 'Kurum %', 'Hasta Payı', 'İskonto', 'Tahsil', 'Hakediş', 'Değişim'];
function Degerler({ d }: { d: PerformansDegeri }) {
  const r = degisimRozeti(d.degisim);
  return (<>
    <td className="sag">{d.basvuru}</td><td className="sag">{d.hizmet}</td><td className="sag"><b>{p(d.ciro)}</b></td>
    <td className="sag">%{d.kurumOrani.toFixed(1).replace('.', ',')}</td><td className="sag">{p(d.hastaPayi)}</td>
    <td className={'sag' + (d.iskonto > 0.005 ? ' pf-uy' : '')}>{tire(d.iskonto)}</td>
    <td className="sag">{tire(d.tahsil)}</td><td className="sag">{tire(d.hakedis)}</td>
    <td title={`Önceki dönem cirosu: ${p(d.oncekiCiro)}`}><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
  </>);
}
function ToplamSatiri({ d, etiket, onBos, etiketSpan }: { d: PerformansDegeri; etiket: string; onBos: number; etiketSpan: number }) {
  return (
    <tr className="top">{Array.from({ length: onBos }, (_, i) => <td key={i} />)}<td colSpan={etiketSpan}>{etiket}</td>
      <td className="sag">{d.basvuru}</td><td className="sag">{d.hizmet}</td><td className="sag">{p(d.ciro)}</td>
      <td className="sag">%{d.kurumOrani.toFixed(1).replace('.', ',')}</td><td className="sag">{p(d.hastaPayi)}</td>
      <td className="sag">{p(d.iskonto)}</td><td className="sag">{p(d.tahsil)}</td><td className="sag">{p(d.hakedis)}</td>
      <td>{(() => { const r = degisimRozeti(d.degisim); return <span className={'bo-rz ' + r.renk}>{r.ad}</span> })()}</td></tr>
  );
}

/** HEKİMLER - tık tek, Ctrl / Shift çoklu (listeSecimi); seçim grup / trend / özeti süzer. */
export function HekimTablosu({ v, secili, setSecili }: {
  v: HekimPerformansIcmali; secili: number[]; setSecili(s: number[]): void;
}) {
  const son = useRef<number | null>(null);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.hekimler.map(h => h.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const hepsi = v.hekimler.length > 0 && v.hekimler.every(h => secili.includes(h.id));
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.hekimler.map(h => h.id))} /></th>
        <th>Hekim</th><th>Bölüm</th>{BASLIKLAR.map(b => <th key={b} className={b === 'Değişim' ? '' : 'sag'}>{b}</th>)}</tr></thead>
      <tbody>
        {v.hekimler.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde hekime bağlı başvuru yok.</td></tr>}
        {v.hekimler.map(h => {
          const sec = secili.includes(h.id);
          return (
            <tr key={h.id} className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(h.id, e)}
                title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
              <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(h.id, e)} /></td>
              <td><b>{h.ad}</b></td><td>{h.bolum || '—'}</td><Degerler d={h.deger} />
            </tr>
          );
        })}
        {v.hekimsiz.basvuru > 0 && (
          <tr className="pf-soluk"><td /><td colSpan={2}>Hekimi girilmemiş başvuru</td><td className="sag">{v.hekimsiz.basvuru}</td>
            <td /><td className="sag">{p(v.hekimsiz.ciro)}</td><td colSpan={7} /></tr>
        )}
        {v.hekimler.length > 0 && <ToplamSatiri d={v.ozet} etiket={secili.length ? `Seçili ${secili.length} hekim` : 'Toplam (hekimsiz dahil)'} onBos={1} etiketSpan={2} />}
      </tbody>
    </table>
  );
}

export function BolumTablosu({ v }: { v: HekimPerformansIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Bölüm</th><th className="sag">Hekim</th>{BASLIKLAR.map(b => <th key={b} className={b === 'Değişim' ? '' : 'sag'}>{b}</th>)}</tr></thead>
      <tbody>
        {v.bolumler.length === 0 && <tr><td colSpan={11} className="bos">Bu dönemde başvuru yok.</td></tr>}
        {v.bolumler.map(b => (
          <tr key={b.id}><td><b>{b.ad}</b></td><td className="sag">{b.hekim}</td><Degerler d={b.deger} /></tr>
        ))}
      </tbody>
    </table>
  );
}

export function GrupTablosu({ v }: { v: HekimPerformansIcmali }) {
  const toplam = v.gruplar.reduce((t, g) => t + g.tutar, 0) || 1;
  return (
    <table className="hi-tablo">
      <thead><tr><th>Hizmet Grubu</th><th className="sag">Kalem</th><th className="sag">Tutar</th><th className="sag">Kurum Payı</th>
        <th className="sag">İskonto</th><th className="sag">Pay</th><th style={{ width: '30%' }} /></tr></thead>
      <tbody>
        {v.gruplar.length === 0 && <tr><td colSpan={7} className="bos">Hizmet satırı yok.</td></tr>}
        {v.gruplar.map(g => (
          <tr key={g.grup}><td>{g.grup}</td><td className="sag">{g.kalem}</td><td className="sag">{p(g.tutar)}</td>
            <td className="sag">{p(g.kurumPayi)}</td><td className="sag">{tire(g.iskonto)}</td>
            <td className="sag">%{(100 * g.tutar / toplam).toFixed(1).replace('.', ',')}</td>
            <td><div className="ki-cubuk"><i style={{ width: `${(100 * g.tutar) / toplam}%` }} /></div></td></tr>
        ))}
        {v.gruplar.length > 0 && (
          <tr className="top"><td>Toplam (KDV hariç satır tutarı)</td><td className="sag">{v.gruplar.reduce((t, g) => t + g.kalem, 0)}</td>
            <td className="sag">{p(v.gruplar.reduce((t, g) => t + g.tutar, 0))}</td>
            <td className="sag">{p(v.gruplar.reduce((t, g) => t + g.kurumPayi, 0))}</td>
            <td className="sag">{p(v.gruplar.reduce((t, g) => t + g.iskonto, 0))}</td><td className="sag">%100</td><td /></tr>
        )}
      </tbody>
    </table>
  );
}

/** AYLIK TREND: 6 ay ciro (kurum + hasta yığılmış) ve başvuru. */
export function TrendGrafigi({ v }: { v: HekimPerformansIcmali }) {
  const enBuyuk = Math.max(...v.trend.map(t => t.ciro), 1);
  return (
    <div className="pf-trend">
      <div className="pf-sutunlar">
        {v.trend.map(t => (
          <div key={`${t.yil}-${t.ay}`} className="pf-sutun" title={`${AY_KISA[t.ay - 1]} ${t.yil}: ${p(t.ciro)} · ${t.basvuru} başvuru`}>
            <div className="pf-deger">{t.ciro > 0 ? p(t.ciro) : '—'}</div>
            <div className="pf-cubuk" style={{ height: `${(160 * t.ciro) / enBuyuk}px` }}>
              <i style={{ height: t.ciro > 0 ? `${(100 * t.kurumPayi) / t.ciro}%` : 0 }} />
            </div>
            <div className="pf-ay">{AY_KISA[t.ay - 1]} {String(t.yil).slice(2)}</div>
            <div className="ki-soluk">{t.basvuru} başvuru</div>
          </div>
        ))}
      </div>
      <div className="ki-soluk">Sütun: ciro · koyu kısım kurum payı{v.secili.length ? ` · seçili ${v.secili.length} hekim` : ''}</div>
    </div>
  );
}
