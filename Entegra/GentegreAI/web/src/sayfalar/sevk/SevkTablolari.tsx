import { useRef, type MouseEvent } from 'react';
import type { SevkEdenIcmali } from '../../api/uclar/sevkEden';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { SATIR_DURUM, odemeRozeti, sevkDegisimi, turRozeti } from './sevkOrtak';

/** Sevk eden icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

/** DIŞ DOKTORLAR - tık tek, Ctrl / Shift çoklu (listeSecimi); seçim diğer sekmeleri, A4'ü ve işlemleri süzer. */
export function DoktorTablosu({ v, secili, setSecili }: {
  v: SevkEdenIcmali; secili: number[]; setSecili(s: number[]): void;
}) {
  const son = useRef<number | null>(null);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.doktorlar.map(d => d.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const hepsi = v.doktorlar.length > 0 && v.doktorlar.every(d => secili.includes(d.id));
  const o = v.ozet;
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.doktorlar.map(d => d.id))} /></th>
        <th>Doktor / Kurum</th><th>Tür</th><th>Uzmanlık</th><th className="sag">Sevk</th><th className="sag">Sevkli Ciro</th>
        <th className="sag">Ort. Başvuru</th><th className="sag">Komisyon %</th><th className="sag">Komisyon</th>
        <th>Ödeme Durumu</th><th>Önceki Döneme Göre</th></tr></thead>
      <tbody>
        {v.doktorlar.length === 0 && <tr><td colSpan={11} className="bos">Bu dönemde gönderen rolüyle gelen başvuru yok.</td></tr>}
        {v.doktorlar.map(d => {
          const sec = secili.includes(d.id);
          const od = odemeRozeti(d.odemeDurumu); const tr = turRozeti(d.tur); const dg = sevkDegisimi(d);
          return (
            <tr key={d.id} className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(d.id, e)}
                title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
              <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(d.id, e)} /></td>
              <td><b>{d.ad}</b>{d.telefon && <div className="ki-soluk">{d.telefon}</div>}</td>
              <td><span className={'bo-rz ' + tr.renk}>{tr.ad}</span></td><td>{d.brans || '—'}</td>
              <td className="sag">{d.basvuru}</td><td className="sag"><b>{p(d.ciro)}</b></td><td className="sag">{p(d.ortBasvuru)}</td>
              <td className="sag">{d.komisyon > 0.005 ? `%${d.oran.toFixed(1).replace('.', ',')}` : '—'}</td>
              <td className="sag">{tire(d.komisyon)}</td>
              <td><span className={'bo-rz ' + od.renk}>{od.ad}</span></td>
              <td title={`Önceki dönem: ${d.oncekiBasvuru} sevk · ${p(d.oncekiCiro)}`}><span className={'bo-rz ' + dg.renk}>{dg.ad}</span></td>
            </tr>
          );
        })}
        {v.doktorlar.length > 0 && (
          <tr className="top"><td /><td colSpan={3}>{o.gonderen} gönderen{secili.length ? ' (seçili)' : ''} · {o.yeni} yeni</td>
            <td className="sag">{o.basvuru}</td><td className="sag">{p(o.ciro)}</td><td className="sag">{p(o.ortBasvuru)}</td><td />
            <td className="sag">{p(o.komisyon)}</td><td colSpan={2} className="ki-soluk">ödenen {p(o.odenen)} · bekleyen {p(o.bekleyen)}</td></tr>
        )}
      </tbody>
    </table>
  );
}

export function BasvuruTablosu({ v, hastaYok }: { v: SevkEdenIcmali; hastaYok?: boolean }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Tarih</th><th>Protokol No</th>{!hastaYok && <th>Hasta</th>}<th>Gönderen</th><th>Bölüm</th>
        <th className="sag">Sevkli Tutar</th></tr></thead>
      <tbody>
        {v.basvurular.length === 0 && <tr><td colSpan={6} className="bos">Sevkli başvuru yok.</td></tr>}
        {v.basvurular.map((b, i) => (
          <tr key={`${b.belgeId}-${b.gonderenId}-${i}`}><td>{tarihKisa(b.tarih)}</td><td>{b.protokolNo}</td>
            {!hastaYok && <td>{b.hasta}</td>}<td>{b.gonderen}</td><td>{b.bolum || '—'}</td><td className="sag">{p(b.tutar)}</td></tr>
        ))}
        {v.basvurular.length > 0 && (
          <tr className="top"><td colSpan={hastaYok ? 4 : 5}>{v.basvurular.length} kayıt</td>
            <td className="sag">{p(v.basvurular.reduce((t, b) => t + b.tutar, 0))}</td></tr>
        )}
      </tbody>
    </table>
  );
}

export function OdemeTablosu({ v }: { v: SevkEdenIcmali }) {
  return (
    <>
      <div className="ki-not">Komisyon <b>gönderen primidir</b>: prim planına göre Prim modülü üretir, bu ekran okur.
        Onay satırı kilitler; "Ödeme Listesi Oluştur" dönemin satırlarını hakediş başlığına bağlar (Hakedişler).</div>
      <table className="hi-tablo">
        <thead><tr><th>Tarih</th><th>Gönderen</th><th>Protokol No</th><th className="sag">Matrah</th><th className="sag">Oran / Tutar</th>
          <th className="sag">Komisyon</th><th>Durum</th><th>Hakediş</th></tr></thead>
        <tbody>
          {v.odemeler.length === 0 && <tr><td colSpan={8} className="bos">Bu dönemde gönderen primi yok (plan tanımlı değil ya da kurum adına sevk).</td></tr>}
          {v.odemeler.map(x => {
            const r = SATIR_DURUM[x.durum] ?? { ad: String(x.durum), renk: 'pas' };
            return (
              <tr key={x.id}><td>{tarihKisa(x.tarih)}</td><td>{x.gonderen}</td><td>{x.protokolNo || '—'}</td>
                <td className="sag">{p(x.taban)}</td><td className="sag">{x.oranTipi === 2 ? p(x.deger) : `%${x.deger}`}</td>
                <td className="sag"><b>{p(x.tutar)}</b></td><td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
                <td>{x.hakedisId ? `#${x.hakedisId}` : '—'}</td></tr>
            );
          })}
          {v.odemeler.length > 0 && (
            <tr className="top"><td colSpan={5}>{v.odemeler.length} prim satırı</td>
              <td className="sag">{p(v.odemeler.reduce((t, x) => t + x.tutar, 0))}</td><td colSpan={2} /></tr>
          )}
        </tbody>
      </table>
    </>
  );
}
