import { useRef, type MouseEvent } from 'react';
import type { AlacakYaslandirma } from '../../api/uclar/alacakYaslandirma';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { DILIM_RENK, dilimYuzdeleri, yasRozeti } from './yaslandirmaOrtak';

/** Alacak yaşlandırmanın sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

/** Tık tek satır, Ctrl / Shift çoklu (listeSecimi); kutu da aynı kuralla. */
function useSecim(sira: number[], secili: number[], setSecili: (s: number[]) => void) {
  const son = useRef<number | null>(null);
  return (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, sira, son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
}

function DilimHucreleri({ x }: { x: { d0: number; d30: number; d60: number; d90: number } }) {
  return (<>
    <td className="sag">{tire(x.d0)}</td><td className="sag">{tire(x.d30)}</td>
    <td className={'sag' + (x.d60 > 0.005 ? ' yz-sari' : '')}>{tire(x.d60)}</td>
    <td className={'sag' + (x.d90 > 0.005 ? ' kir' : '')}>{tire(x.d90)}</td>
  </>);
}

export function KurumTablosu({ v, secili, setSecili, kurumAc }: {
  v: AlacakYaslandirma; secili: number[]; setSecili(s: number[]): void; kurumAc(id: number): void;
}) {
  const tikla = useSecim(v.kurumlar.map(k => k.id), secili, setSecili);
  const hepsi = v.kurumlar.length > 0 && v.kurumlar.every(k => secili.includes(k.id));
  const t = (f: (k: AlacakYaslandirma['kurumlar'][number]) => number) => v.kurumlar.reduce((s, k) => s + f(k), 0);
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.kurumlar.map(k => k.id))} /></th>
        <th>Kurum</th><th>Tür</th><th className="sag">Açık Belge</th>
        <th className="sag">0 – 30</th><th className="sag">31 – 60</th><th className="sag">61 – 90</th><th className="sag">90+</th>
        <th className="sag">Toplam</th><th className="sag" title="Henüz faturalanmamış kurum payı">Faturasız</th>
        <th className="sag">En Eski</th><th>Son Tahsilat</th><th>Durum</th></tr></thead>
      <tbody>
        {v.kurumlar.length === 0 && <tr><td colSpan={13} className="bos">Açık kurum alacağı yok.</td></tr>}
        {v.kurumlar.map(k => {
          const r = yasRozeti(k);
          const sec = secili.includes(k.id);
          return (
            <tr key={k.id} className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(k.id, e)}
                title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
              <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(k.id, e)} /></td>
              <td><a className="ki-lnk" title="Kurum icmalini aç" onClick={e => { e.stopPropagation(); kurumAc(k.id) }}>{k.ad}</a></td>
              <td>{k.turAdi}</td><td className="sag">{k.acikBelge}</td>
              <DilimHucreleri x={k} />
              <td className="sag"><b>{p(k.toplam)}</b></td><td className="sag">{tire(k.faturasiz)}</td>
              <td className="sag">{k.enEskiGun} gün</td><td>{k.sonTahsilat ? tarihKisa(k.sonTahsilat) : '—'}</td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
            </tr>
          );
        })}
        {v.kurumlar.length > 0 && (
          <tr className="top"><td /><td colSpan={2}>{v.kurumlar.length} kurum</td><td className="sag">{t(k => k.acikBelge)}</td>
            <td className="sag">{p(t(k => k.d0))}</td><td className="sag">{p(t(k => k.d30))}</td>
            <td className="sag">{p(t(k => k.d60))}</td><td className="sag">{p(t(k => k.d90))}</td>
            <td className="sag">{p(v.ozet.kurum)}</td><td className="sag">{p(v.ozet.faturasizKurumPayi)}</td><td colSpan={3} /></tr>
        )}
      </tbody>
    </table>
  );
}

export function HastaTablosu({ v, secili, setSecili, hastaAc }: {
  v: AlacakYaslandirma; secili: number[]; setSecili(s: number[]): void; hastaAc(id: number): void;
}) {
  const tikla = useSecim(v.hastalar.map(h => h.id), secili, setSecili);
  const hepsi = v.hastalar.length > 0 && v.hastalar.every(h => secili.includes(h.id));
  const t = (f: (h: AlacakYaslandirma['hastalar'][number]) => number) => v.hastalar.reduce((s, h) => s + f(h), 0);
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.hastalar.map(h => h.id))} /></th>
        <th>Hasta</th><th>Dosya No</th><th className="sag">Açık Protokol</th>
        <th className="sag">0 – 30</th><th className="sag">31 – 60</th><th className="sag">61 – 90</th><th className="sag">90+</th>
        <th className="sag">Toplam</th><th className="sag">En Eski</th><th>Son Tahsilat</th><th>Durum</th></tr></thead>
      <tbody>
        {v.hastalar.length === 0 && <tr><td colSpan={12} className="bos">Açık hasta alacağı yok.</td></tr>}
        {v.hastalar.map(h => {
          const r = yasRozeti(h);
          const sec = secili.includes(h.id);
          return (
            <tr key={h.id} className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(h.id, e)}
                title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
              <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(h.id, e)} /></td>
              <td><a className="ki-lnk" title="Hasta icmalini aç" onClick={e => { e.stopPropagation(); hastaAc(h.id) }}>{h.ad}</a></td>
              <td>{h.dosyaNo || '—'}</td><td className="sag">{h.acikProtokol}</td>
              <DilimHucreleri x={h} />
              <td className="sag"><b>{p(h.toplam)}</b></td>
              <td className="sag">{h.enEskiGun} gün</td><td>{h.sonTahsilat ? tarihKisa(h.sonTahsilat) : '—'}</td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
            </tr>
          );
        })}
        {v.hastalar.length > 0 && (
          <tr className="top"><td /><td colSpan={2}>{v.hastalar.length} hasta</td><td className="sag">{t(h => h.acikProtokol)}</td>
            <td className="sag">{p(t(h => h.d0))}</td><td className="sag">{p(t(h => h.d30))}</td>
            <td className="sag">{p(t(h => h.d60))}</td><td className="sag">{p(t(h => h.d90))}</td>
            <td className="sag">{p(v.ozet.hasta)}</td><td colSpan={3} /></tr>
        )}
      </tbody>
    </table>
  );
}

/** DİLİM GRAFİĞİ: dilim başına kurum + hasta, yığılmış çubuk ve tablo. */
export function DilimGrafigi({ v }: { v: AlacakYaslandirma }) {
  const enBuyuk = Math.max(...v.dilimler.map(d => d.toplam), 1);
  const yuzde = dilimYuzdeleri(v.ozet);
  return (
    <div className="yz-grafik">
      <div className="yz-yigin" title="Toplam alacağın dilimlere dağılımı">
        {yuzde.map((y, i) => y > 0 && <i key={i} style={{ width: `${y}%`, background: DILIM_RENK[i] }}>{y >= 8 ? `%${Math.round(y)}` : ''}</i>)}
      </div>
      <table className="hi-tablo">
        <thead><tr><th>Dilim</th><th className="sag">Kurum</th><th className="sag">Hasta</th><th className="sag">Toplam</th>
          <th className="sag">Pay</th><th style={{ width: '38%' }} /></tr></thead>
        <tbody>
          {v.dilimler.map((d, i) => (
            <tr key={d.ad}><td><span className="yz-nokta" style={{ background: DILIM_RENK[i] }} />{d.ad}</td>
              <td className="sag">{p(d.kurum)}</td><td className="sag">{p(d.hasta)}</td><td className="sag"><b>{p(d.toplam)}</b></td>
              <td className="sag">%{yuzde[i].toFixed(1).replace('.', ',')}</td>
              <td><div className="yz-cubuk">
                <i style={{ width: `${(100 * d.kurum) / enBuyuk}%`, background: '#6a3fb5' }} title="Kurum" />
                <i style={{ width: `${(100 * d.hasta) / enBuyuk}%`, background: '#2f6db3' }} title="Hasta" />
              </div></td></tr>
          ))}
          <tr className="top"><td>Toplam</td><td className="sag">{p(v.ozet.kurum)}</td><td className="sag">{p(v.ozet.hasta)}</td>
            <td className="sag">{p(v.ozet.toplam)}</td><td className="sag">%100</td><td className="ki-soluk">mor: kurum · mavi: hasta</td></tr>
        </tbody>
      </table>
    </div>
  );
}
