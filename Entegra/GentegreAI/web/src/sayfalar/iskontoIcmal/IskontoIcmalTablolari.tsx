import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { IskontoGrubu, IskontoIcmali } from '../../api/uclar/iskontoIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { kaynakRozeti, oranMetni } from './iskontoIcmalOrtak';

/** İskonto icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);

/**
 * İSKONTOLAR - başvuru başına. Tık tek, Ctrl / Shift çoklu seçer (A4'ü
 * süzer); ▸ kalemleri açar. Eşik üstü talepsiz iskonto kırmızı işaretlenir.
 */
export function IskontoTablosu({ v, secili, setSecili, hastaAc }: {
  v: IskontoIcmali; secili: number[]; setSecili(s: number[]): void; hastaAc(id: number): void;
}) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.basvurular.map(b => b.belgeId), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const hepsi = v.basvurular.length > 0 && v.basvurular.every(b => secili.includes(b.belgeId));
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.basvurular.map(b => b.belgeId))} /></th>
        <th>Tarih</th><th>Protokol No</th><th>Hasta</th><th>Bölüm / Doktor</th><th>Veren / İsteyen</th><th>Onaylayan</th>
        <th className="sag">Liste</th><th className="sag">Oran</th><th className="sag">İskonto</th><th>Gerekçe</th><th>Kaynak</th></tr></thead>
      <tbody>
        {v.basvurular.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde iskonto verilmedi.</td></tr>}
        {v.basvurular.map(b => {
          const r = kaynakRozeti(b.kaynak);
          const sec = secili.includes(b.belgeId);
          const ac = acik.includes(b.belgeId);
          return (
            <Fragment key={b.belgeId}>
              <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(b.belgeId, e)}
                  title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(b.belgeId, e)} /></td>
                <td><span className="ok" title="Kalemler" onClick={e => { e.stopPropagation(); setAcik(a => (ac ? a.filter(x => x !== b.belgeId) : [...a, b.belgeId])) }}>
                  {ac ? '▾' : '▸'}</span>{tarihKisa(b.tarih)}</td>
                <td>{b.protokolNo}</td>
                <td>{b.hastaId ? <a className="ki-lnk" onClick={e => { e.stopPropagation(); hastaAc(b.hastaId) }}>{b.hasta}</a> : b.hasta}</td>
                <td>{b.bolum || '—'}{b.hekim && ` · ${b.hekim}`}</td><td>{b.isteyen || '—'}</td><td>{b.onaylayan || '—'}</td>
                <td className="sag">{p(b.liste)}</td>
                <td className={'sag' + (b.esikUstu ? ' kir' : '')} title={b.esikUstu ? `Onay eşiği %${v.ozet.esik} üstü, talep yok` : undefined}>
                  {oranMetni(b.oran)}{b.esikUstu && ' ⚠'}</td>
                <td className="sag"><b>{p(b.iskonto)}</b></td><td>{b.gerekce || '—'}</td>
                <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
              </tr>
              {ac && (
                <tr className="det"><td colSpan={12}>
                  {b.kalemler.map(k => `${k.hizmet} · liste ${p(k.liste)} · iskonto ${p(k.iskonto)} (${kaynakRozeti(k.kaynak).ad})`).join('   |   ')}
                </td></tr>
              )}
            </Fragment>
          );
        })}
        {v.basvurular.length > 0 && (
          <tr className="top"><td /><td colSpan={6}>{v.ozet.basvuru} başvuru{v.ozet.esikUstu ? ` · ${v.ozet.esikUstu} eşik üstü talepsiz` : ''}</td>
            <td className="sag">{p(v.basvurular.reduce((t, b) => t + b.liste, 0))}</td><td className="sag">{oranMetni(v.ozet.ortOran)}</td>
            <td className="sag">{p(v.ozet.iskonto)}</td><td colSpan={2} /></tr>
        )}
      </tbody>
    </table>
  );
}

/** Gruplu özet tablosu (onaylayana / verene / gerekçeye göre). */
export function GrupTablosu({ baslik, gruplar, bos }: { baslik: string; gruplar: IskontoGrubu[]; bos: string }) {
  const toplam = gruplar.reduce((t, g) => t + g.iskonto, 0) || 1;
  return (
    <table className="hi-tablo">
      <thead><tr><th>{baslik}</th><th className="sag">Başvuru</th><th className="sag">Kalem</th><th className="sag">Liste</th>
        <th className="sag">İskonto</th><th className="sag">Ort. Oran</th><th className="sag">Pay</th><th style={{ width: '22%' }} /></tr></thead>
      <tbody>
        {gruplar.length === 0 && <tr><td colSpan={8} className="bos">{bos}</td></tr>}
        {gruplar.map(g => (
          <tr key={g.ad}><td><b>{g.ad}</b></td><td className="sag">{g.basvuru}</td><td className="sag">{g.kalem}</td>
            <td className="sag">{p(g.liste)}</td><td className="sag">{p(g.iskonto)}</td><td className="sag">{oranMetni(g.oran)}</td>
            <td className="sag">{oranMetni(100 * g.iskonto / toplam)}</td>
            <td><div className="ki-cubuk"><i style={{ width: `${(100 * g.iskonto) / toplam}%` }} /></div></td></tr>
        ))}
      </tbody>
    </table>
  );
}

export function UcretsizTablosu({ v }: { v: IskontoIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Tarih</th><th>Protokol No</th><th>Hasta</th><th>Bölüm / Doktor</th><th>Hizmet</th>
        <th className="sag">Liste Fiyatı</th><th>Kaynak</th><th>Gerekçe</th><th>Onaylayan</th></tr></thead>
      <tbody>
        {v.ucretsizler.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde ücretsiz verilen hizmet yok.</td></tr>}
        {v.ucretsizler.map((u, i) => {
          const r = kaynakRozeti(u.kaynak);
          return (
            <tr key={i}><td>{tarihKisa(u.tarih)}</td><td>{u.protokolNo}</td><td>{u.hasta}</td>
              <td>{u.bolum || '—'}{u.hekim && ` · ${u.hekim}`}</td><td>{u.hizmet}</td><td className="sag">{p(u.liste)}</td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td><td>{u.gerekce || '—'}</td><td>{u.onaylayan || '—'}</td></tr>
          );
        })}
        {v.ucretsizler.length > 0 && (
          <tr className="top"><td colSpan={5}>{v.ozet.ucretsizKalem} hizmet (liste fiyatıyla)</td>
            <td className="sag">{p(v.ozet.ucretsiz)}</td><td colSpan={3} /></tr>
        )}
      </tbody>
    </table>
  );
}

export function RedTablosu({ v }: { v: IskontoIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Tarih</th><th>Protokol No</th><th>İsteyen</th><th>Reddeden</th><th className="sag">İstenen Oran</th>
        <th className="sag">İstenen Tutar</th><th>Gerekçe</th><th>Karar Notu</th></tr></thead>
      <tbody>
        {v.redler.length === 0 && <tr><td colSpan={8} className="bos">Bu dönemde reddedilen iskonto talebi yok.</td></tr>}
        {v.redler.map(r => (
          <tr key={r.id}><td>{tarihKisa(r.tarih)}</td><td>{r.protokolNo}</td><td>{r.isteyen || '—'}</td><td>{r.reddeden || '—'}</td>
            <td className="sag">{oranMetni(r.oran)}</td><td className="sag">{p(r.istenen)}</td><td>{r.gerekce || '—'}</td><td>{r.not || '—'}</td></tr>
        ))}
        {v.redler.length > 0 && (
          <tr className="top"><td colSpan={5}>{v.ozet.red} talep (toplamlara girmez)</td><td className="sag">{p(v.ozet.redTutar)}</td><td colSpan={2} /></tr>
        )}
      </tbody>
    </table>
  );
}
