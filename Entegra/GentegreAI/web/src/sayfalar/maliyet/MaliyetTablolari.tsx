import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { MaliyetIcmali } from '../../api/uclar/maliyetIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { KAYNAK_ADI, marjRozeti } from './maliyetOrtak';

/** Hasta başı maliyet icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

/** BAŞVURULAR - en düşük marj üstte; tık / Ctrl / Shift seçim (A4), ▸ kalemler. */
export function BasvuruTablosu({ v, secili, setSecili, hastaAc }: {
  v: MaliyetIcmali; secili: number[]; setSecili(s: number[]): void; hastaAc(id: number): void;
}) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.basvurular.map(b => b.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const hepsi = v.basvurular.length > 0 && v.basvurular.every(b => secili.includes(b.id));
  const o = v.ozet;
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.basvurular.map(b => b.id))} /></th>
        <th>Tarih</th><th>Protokol No</th><th>Hasta</th><th>Bölüm / Doktor</th>
        <th className="sag">Ciro</th><th className="sag">Sarf</th><th className="sag">İlaç</th><th className="sag">Kâr</th><th>Marj</th></tr></thead>
      <tbody>
        {v.basvurular.length === 0 && <tr><td colSpan={10} className="bos">Bu dönemde başvuru yok.</td></tr>}
        {v.basvurular.map(b => {
          const r = marjRozeti(b.marj, b.sarf + b.ilac > 0);
          const sec = secili.includes(b.id);
          const ac = acik.includes(b.id);
          return (
            <Fragment key={b.id}>
              <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(b.id, e)}
                  title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(b.id, e)} /></td>
                <td>{b.kalemler.length > 0
                  ? <span className="ok" title="Düşülen kalemler" onClick={e => { e.stopPropagation(); setAcik(a => (ac ? a.filter(x => x !== b.id) : [...a, b.id])) }}>{ac ? '▾' : '▸'}</span>
                  : <span className="ok" />}{tarihKisa(b.tarih)}</td>
                <td>{b.protokolNo}</td>
                <td>{b.hastaId ? <a className="ki-lnk" onClick={e => { e.stopPropagation(); hastaAc(b.hastaId) }}>{b.hasta}</a> : b.hasta}</td>
                <td>{b.bolum || '—'}{b.hekim && ` · ${b.hekim}`}</td>
                <td className="sag">{p(b.ciro)}</td><td className="sag">{tire(b.sarf)}</td><td className="sag">{tire(b.ilac)}</td>
                <td className={'sag' + (b.kar < 0 ? ' kir' : '')}><b>{p(b.kar)}</b></td>
                <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
              </tr>
              {ac && (
                <tr className="det"><td colSpan={10}>
                  {b.kalemler.map(k => `${k.ad} × ${k.miktar} · ${p(k.maliyet)} (${KAYNAK_ADI[k.kaynak] ?? k.kaynak}${k.ilac ? ', ilaç' : ''}${k.kaynak !== 'fatura' && !k.faturali ? ', faturada yok' : ''})`).join('   |   ')}
                </td></tr>
              )}
            </Fragment>
          );
        })}
        {v.basvurular.length > 0 && (
          <tr className="top"><td /><td colSpan={4}>{o.basvuru} başvuru · {o.maliyetliBasvuru} maliyetli · {o.zarar} zarar eden</td>
            <td className="sag">{p(o.ciro)}</td><td className="sag">{p(o.sarf)}</td><td className="sag">{p(o.ilac)}</td>
            <td className="sag">{p(o.kar)}</td><td /></tr>
        )}
      </tbody>
    </table>
  );
}

export function HizmetTablosu({ v }: { v: MaliyetIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Hizmet</th><th className="sag">Adet</th><th className="sag">Ciro</th><th className="sag">Ort. Fiyat</th>
        <th className="sag">Dağıtılan Maliyet</th><th className="sag">Ort. Maliyet</th><th className="sag" title="Hizmetin standart sarf setinin birim maliyeti">Standart Sarf</th><th>Marj</th></tr></thead>
      <tbody>
        {v.hizmetler.length === 0 && <tr><td colSpan={8} className="bos">Hizmet satırı yok.</td></tr>}
        {v.hizmetler.map(h => {
          const r = marjRozeti(h.marj, h.maliyet > 0);
          return (
            <tr key={`${h.hizmetId}-${h.ad}`}><td>{h.ad}</td><td className="sag">{h.adet}</td><td className="sag">{p(h.ciro)}</td>
              <td className="sag">{p(h.ortFiyat)}</td><td className="sag">{tire(h.maliyet)}</td><td className="sag">{tire(h.ortMaliyet)}</td>
              <td className="sag">{tire(h.standartSarf)}</td><td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>
          );
        })}
      </tbody>
    </table>
  );
}

export function FaturasizTablosu({ v }: { v: MaliyetIcmali }) {
  return (
    <>
      <div className="ki-not">Düşülmüş ama başvuruda aynı stok satırı olmayan kalemler - <b>kaçak gelir adayı</b>.
        Her sarf faturalanmaz (ör. kontrast fiyata dahilse); liste kontrol içindir.</div>
      <table className="hi-tablo">
        <thead><tr><th>Tarih</th><th>Protokol No</th><th>Hasta</th><th>Bölüm</th><th>Kalem</th><th className="sag">Miktar</th>
          <th className="sag">Maliyet</th><th>Kaynak</th></tr></thead>
        <tbody>
          {v.faturasizSarf.length === 0 && <tr><td colSpan={8} className="bos">Faturaya girmemiş sarf yok.</td></tr>}
          {v.faturasizSarf.map((f, i) => (
            <tr key={i}><td>{tarihKisa(f.tarih)}</td><td>{f.protokolNo}</td><td>{f.hasta}</td><td>{f.bolum || '—'}</td>
              <td>{f.ad}{f.ilac && <span className="bo-rz mavi" style={{ marginLeft: 4 }}>ilaç</span>}</td>
              <td className="sag">{f.miktar}</td><td className="sag">{p(f.maliyet)}</td><td>{KAYNAK_ADI[f.kaynak] ?? f.kaynak}</td></tr>
          ))}
          {v.faturasizSarf.length > 0 && (
            <tr className="top"><td colSpan={6}>{v.ozet.faturasizKalem} kalem</td><td className="sag">{p(v.ozet.faturasizMaliyet)}</td><td /></tr>
          )}
        </tbody>
      </table>
    </>
  );
}

export function BolumTablosu({ v }: { v: MaliyetIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Bölüm</th><th className="sag">Başvuru</th><th className="sag">Ciro</th><th className="sag">Sarf</th>
        <th className="sag">İlaç</th><th className="sag">Kâr</th><th className="sag">Hasta Başı Maliyet</th><th>Marj</th></tr></thead>
      <tbody>
        {v.bolumler.length === 0 && <tr><td colSpan={8} className="bos">Bu dönemde başvuru yok.</td></tr>}
        {v.bolumler.map(b => {
          const r = marjRozeti(b.marj, b.sarf + b.ilac > 0);
          return (
            <tr key={b.id}><td><b>{b.ad}</b></td><td className="sag">{b.basvuru}</td><td className="sag">{p(b.ciro)}</td>
              <td className="sag">{tire(b.sarf)}</td><td className="sag">{tire(b.ilac)}</td><td className="sag">{p(b.kar)}</td>
              <td className="sag">{tire(b.hastaBasi)}</td><td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>
          );
        })}
      </tbody>
    </table>
  );
}
