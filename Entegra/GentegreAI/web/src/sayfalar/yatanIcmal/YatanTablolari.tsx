import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { YatanIcmali, YatanOzet } from '../../api/uclar/yatanIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { DURUM, beklemeRozeti, dolulukRozeti, gunMetni } from './yatanIcmalOrtak';

/** Yatan hasta icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}

/** SERVİSLER - tık tek, Ctrl / Shift çoklu; ▸ doktor dağılımı; seçim diğer sekmeleri ve A4'ü süzer. */
export function ServisTablosu({ v, secili, setSecili }: { v: YatanIcmali; secili: number[]; setSecili(s: number[]): void }) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.servisler.map(s => s.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.servisler.length > 0 && v.servisler.every(s => secili.includes(s.id));
  const o = v.ozet;
  const hucreler = (z: YatanOzet, yatakli: boolean) => {
    const d = dolulukRozeti(z.doluluk);
    return (<>
      <td className="sag">{yatakli ? z.yatak || '—' : ''}</td>
      <td className="sag">{z.yatis}</td><td className="sag">{z.taburcu}</td><td className="sag">{z.hastaGun}</td>
      <td>{yatakli && <><Cubuk oran={z.doluluk ?? 0} /> <span className={'bo-rz ' + d.renk}>{d.ad}</span></>}</td>
      <td className="sag">{gunMetni(z.alos)}</td><td className="sag"><b>{p(z.ciro)}</b></td>
      <td className="sag">{tire(z.gunBasi)}</td><td className="sag">{p(z.kurum)}</td>
      <td className="sag">{z.acikAdet ? <span className="lb-asim">{p(z.acikTutar)} ({z.acikAdet})</span> : '—'}</td>
    </>);
  };
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.servisler.map(s => s.id))} /></th>
        <th>Servis</th><th className="sag">Yatak</th><th className="sag">Yatış</th><th className="sag">Taburcu</th><th className="sag">Hasta-Gün</th>
        <th>Doluluk</th><th className="sag">ALOS</th><th className="sag">Ciro</th><th className="sag">Gün Başı</th><th className="sag">Kurum Payı</th>
        <th className="sag">Açık Hesap</th></tr></thead>
      <tbody>
        {v.servisler.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde yatış yok.</td></tr>}
        {v.servisler.map(s => {
          const sec = secili.includes(s.id); const a = acik.includes(s.id);
          return (
            <Fragment key={s.id}>
              <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(s.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(s.id, e)} /></td>
                <td><a className="ki-lnk" onClick={e => ac(s.id, e)}>{a ? '▾' : '▸'}</a> <b>{s.ad}</b>
                  {s.kapaliYatak > 0 && <span className="bo-rz pas lb-k" title="Bugün kapalı (arıza / tadilat) yatak">{s.kapaliYatak} kapalı yatak</span>}</td>
                {hucreler(s.ozet, true)}
              </tr>
              {a && s.doktorlar.map(d => (
                <tr key={d.id} className="lb-alt"><td /><td>&nbsp;&nbsp;{d.ad}</td>{hucreler(d.ozet, false)}</tr>
              ))}
            </Fragment>
          );
        })}
        {v.servisler.length > 0 && (
          <tr className="top"><td /><td>Toplam · {v.servisler.length} servis</td>{hucreler(o, true)}</tr>
        )}
      </tbody>
    </table>
  );
}

export function YatisTablosu({ v }: { v: YatanIcmali }) {
  return (
    <>
      <div className="ki-not">Dönemde kabul edilen yatışlar · tutar = dönem tarihli hizmetler (yatak / refakat tahakkuku, ilaç, tetkik)</div>
      <table className="hi-tablo">
        <thead><tr><th>Protokol No</th><th>Hasta</th><th>Servis</th><th>Doktor</th><th>Yatış</th><th>Taburcu</th>
          <th className="sag">Gün</th><th>Ödeyen</th><th className="sag">Tutar</th><th>Durum</th></tr></thead>
        <tbody>
          {v.yatislar.length === 0 && <tr><td colSpan={10} className="bos">Dönemde kabul edilen yatış yok.</td></tr>}
          {v.yatislar.map(y => {
            const r = DURUM[y.durum];
            return (
              <tr key={y.id}><td>{y.protokolNo}</td><td>{y.hasta}{y.tekrar && <span className="bo-rz sari lb-k" title="30 gün içinde tekrar yatış">tekrar</span>}</td>
                <td>{y.servis}</td><td>{y.doktor || '—'}</td><td>{tarihKisa(y.giris)}</td><td>{y.cikis ? tarihKisa(y.cikis) : '—'}</td>
                <td className="sag">{y.gun}</td><td>{y.odeyen}</td><td className="sag">{p(y.ciro)}</td>
                <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>
            );
          })}
          {v.yatislar.length > 0 && (
            <tr className="top"><td colSpan={8}>{v.yatislar.length} yatış · {v.yatislar.filter(y => y.durum === 'yatiyor').length} hâlâ yatıyor ·
              {' '}{v.yatislar.filter(y => y.durum === 'acik').length} hesap açık</td>
              <td className="sag">{p(v.yatislar.reduce((t, y) => t + y.ciro, 0))}</td><td /></tr>
          )}
        </tbody>
      </table>
    </>
  );
}

export function AcikHesapTablosu({ v }: { v: YatanIcmali }) {
  const nedenler = v.acikHesaplar.reduce<Record<string, number>>((a, x) => ({ ...a, [x.neden]: (a[x.neden] ?? 0) + 1 }), {});
  return (
    <>
      <div className="ki-not">Dönemde taburcu edilmiş, faturası kesilmemiş ya da (kurumlu yatışta) provizyonu alınmamış yatışlar ·
        bekleme = taburcudan bugüne. Tahsilat yatışa bağlı tutulmadığı için "hasta payı tahsil edilmedi" ayrımı yapılamıyor.</div>
      <table className="hi-tablo">
        <thead><tr><th>Protokol No</th><th>Hasta</th><th>Servis</th><th>Ödeyen</th><th>Taburcu</th><th>Bekleme</th>
          <th className="sag">Yatış Toplamı</th><th className="sag">Faturalanmamış</th><th>Neden</th></tr></thead>
        <tbody>
          {v.acikHesaplar.length === 0 && <tr><td colSpan={9} className="bos">Açık hesap yok.</td></tr>}
          {v.acikHesaplar.map(x => {
            const b = beklemeRozeti(x.bekleme);
            return (
              <tr key={x.id}><td>{x.protokolNo}</td><td>{x.hasta}</td><td>{x.servis}</td><td>{x.odeyen}</td><td>{tarihKisa(x.cikis)}</td>
                <td><span className={'bo-rz ' + b.renk}>{b.ad}</span></td><td className="sag">{p(x.toplam)}</td>
                <td className="sag"><b>{tire(x.faturasiz)}</b></td><td>{x.neden}</td></tr>
            );
          })}
          {v.acikHesaplar.length > 0 && (
            <tr className="top"><td colSpan={6}>{v.acikHesaplar.length} açık hesap · {Object.entries(nedenler).map(([n, k]) => `${n} ${k}`).join(' · ')}</td>
              <td className="sag">{p(v.acikHesaplar.reduce((t, x) => t + x.toplam, 0))}</td>
              <td className="sag">{p(v.acikHesaplar.reduce((t, x) => t + x.faturasiz, 0))}</td><td /></tr>
          )}
        </tbody>
      </table>
    </>
  );
}

export function YatakKullanimTablosu({ v }: { v: YatanIcmali }) {
  const hucre = (d: number | null | undefined) => {
    const renk = d == null ? '' : d >= 85 ? 'yk-kir' : d >= 70 ? 'yk-sari' : d > 0 ? 'yk-yesil' : '';
    return <td className={'sag ' + renk}>{d == null ? '—' : `%${d.toFixed(1).replace('.', ',')}`}</td>;
  };
  return (
    <>
      <div className="ki-not">Haftalık doluluk = hasta-gün / (yatak × gün) · koyu kırmızı ≥ %85 (sıkışık) · boş yatak-gün = yatak-gün − hasta-gün ·
        yatak durum geçmişi tutulmadığı için kapalı yatak yalnız bugünkü durumdur.</div>
      <table className="hi-tablo">
        <thead><tr><th>Servis</th>{v.donem.haftalar.map(h => <th key={h.bas} className="sag">{tarihKisa(h.bas).slice(0, 5)}–{tarihKisa(h.bit).slice(0, 5)}</th>)}
          <th className="sag">Dönem</th><th className="sag">Boş Yatak-Gün</th><th className="sag">Bugün Kapalı</th></tr></thead>
        <tbody>
          {v.haftalik.length === 0 && <tr><td colSpan={v.donem.haftalar.length + 4} className="bos">Kayıt yok.</td></tr>}
          {v.haftalik.map(s => (
            <tr key={s.id}><td><b>{s.ad}</b> <span className="ki-soluk">{s.yatak} yatak</span></td>
              {s.haftalar.map((d, i) => <Fragment key={i}>{hucre(d)}</Fragment>)}{hucre(s.donem)}
              <td className="sag">{s.bosYatakGun}</td><td className="sag">{s.kapaliYatak || '—'}</td></tr>
          ))}
        </tbody>
      </table>
    </>
  );
}

export function TaniDoktorTablosu({ v }: { v: YatanIcmali }) {
  return (
    <div className="lb-kalite">
      <div>
        <div className="lb-bas">En Sık Yatış Tanıları <span className="ki-soluk">ICD-10 · dönemde kabul edilen</span></div>
        <table className="hi-tablo">
          <thead><tr><th>ICD</th><th>Tanı</th><th className="sag">Yatış</th><th className="sag">ALOS</th><th className="sag">Ort. Tutar</th></tr></thead>
          <tbody>
            {v.tanilar.length === 0 && <tr><td colSpan={5} className="bos">Tanı yazılmış yatış yok.</td></tr>}
            {v.tanilar.map(t => (
              <tr key={t.kod}><td>{t.kod}</td><td>{t.ad || '—'}</td><td className="sag">{t.adet}</td>
                <td className="sag">{gunMetni(t.alos)}</td><td className="sag">{p(t.ortTutar)}</td></tr>
            ))}
          </tbody>
        </table>
      </div>
      <div>
        <div className="lb-bas">Doktorlar <span className="ki-soluk">yatıran / sorumlu doktor</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Doktor</th><th>Servis</th><th className="sag">Yatış</th><th className="sag">Taburcu</th>
            <th className="sag">Hasta-Gün</th><th className="sag">ALOS</th><th className="sag">Ciro</th></tr></thead>
          <tbody>
            {v.doktorlar.map((d, i) => (
              <tr key={i}><td>{d.ad}</td><td>{d.servis}</td><td className="sag">{d.ozet.yatis}</td><td className="sag">{d.ozet.taburcu}</td>
                <td className="sag">{d.ozet.hastaGun}</td><td className="sag">{gunMetni(d.ozet.alos)}</td><td className="sag">{p(d.ozet.ciro)}</td></tr>
            ))}
            {v.doktorlar.length > 0 && (
              <tr className="top"><td colSpan={2}>{v.doktorlar.length} doktor</td><td className="sag">{v.ozet.yatis}</td>
                <td className="sag">{v.ozet.taburcu}</td><td className="sag">{v.ozet.hastaGun}</td><td className="sag">{gunMetni(v.ozet.alos)}</td>
                <td className="sag">{p(v.ozet.ciro)}</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
