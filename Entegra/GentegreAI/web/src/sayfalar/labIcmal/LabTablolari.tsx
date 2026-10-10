import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { LabIcmali } from '../../api/uclar/labIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { gun, labMarjRozeti, sure, yuzde } from './labIcmalOrtak';

/** Laboratuvar icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}

/** TETKİKLER - tık tek, Ctrl / Shift çoklu; ▸ bölüm dağılımı; seçilenler A4'ü süzer. */
export function TetkikTablosu({ v, secili, setSecili }: {
  v: LabIcmali; secili: string[]; setSecili(s: string[]): void;
}) {
  const son = useRef<string | null>(null);
  const [acik, setAcik] = useState<string[]>([]);
  const tikla = (id: string, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.tetkikler.map(t => t.anahtar), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: string, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.tetkikler.length > 0 && v.tetkikler.every(t => secili.includes(t.anahtar));
  const o = v.ozet;
  const toplamMaliyet = v.tetkikler.reduce((t, x) => t + x.maliyet, 0);
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.tetkikler.map(t => t.anahtar))} /></th>
        <th>Kod</th><th>Tetkik</th><th>Grup</th><th className="sag">Adet</th><th className="sag">Birim Fiyat</th>
        <th className="sag">Ciro</th><th className="sag">Kurum %</th><th className="sag">Maliyet / Test</th><th className="sag">Maliyet</th>
        <th>Marj</th><th className="sag">Ort. TAT</th><th className="sag">Tekrar</th></tr></thead>
      <tbody>
        {v.tetkikler.length === 0 && <tr><td colSpan={13} className="bos">Bu dönemde laboratuvar istemi yok.</td></tr>}
        {v.tetkikler.map(t => {
          const sec = secili.includes(t.anahtar); const mr = labMarjRozeti(t.marj, t.maliyet); const a = acik.includes(t.anahtar);
          return (
            <Fragment key={t.anahtar}>
              <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(t.anahtar, e)}
                  title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(t.anahtar, e)} /></td>
                <td><a className="ki-lnk" onClick={e => ac(t.anahtar, e)}>{a ? '▾' : '▸'}</a> {t.kod}</td>
                <td><b>{t.ad}</b>{t.dis && <span className="bo-rz mavi lb-k">dış lab</span>}
                  {t.faturasiz > 0 && <span className="bo-rz sari lb-k" title="Başvuruda bu hizmetin satırı yok">{t.faturasiz} faturasız</span>}</td>
                <td>{t.grupAd}</td><td className="sag">{t.adet}</td><td className="sag">{p(t.birimFiyat)}</td>
                <td className="sag"><b>{p(t.ciro)}</b></td><td className="sag">%{t.kurumYuzde}</td>
                <td className="sag">{tire(t.testMaliyet)}</td><td className="sag">{tire(t.maliyet)}</td>
                <td><span className={'bo-rz ' + mr.renk}>{mr.ad}</span></td>
                <td className="sag">{t.dis ? gun(t.disGun) : sure(t.ortTat)}{t.asan > 0 && <span className="lb-asim"> · {t.asan} aşan</span>}</td>
                <td className="sag">{t.tekrar || '—'}</td>
              </tr>
              {a && (
                <tr className="lb-alt"><td /><td colSpan={12}>İsteyen bölüm dağılımı ({t.adet}):{' '}
                  {t.bolumler.map(b => `${b.ad} ${b.adet}`).join(' · ')}</td></tr>
              )}
            </Fragment>
          );
        })}
        {v.tetkikler.length > 0 && (
          <tr className="top"><td /><td colSpan={3}>Toplam · {v.tetkikler.length} tetkik</td><td className="sag">{o.tetkik}</td><td />
            <td className="sag">{p(o.ciro)}</td><td className="sag">{o.ciro > 0 ? `%${Math.round(100 * o.kurum / o.ciro)}` : '—'}</td><td />
            <td className="sag">{p(toplamMaliyet)}</td><td>{yuzde(o.marj)}</td><td className="sag">rutin {sure(o.ortTat)}</td>
            <td className="sag">{o.tekrar}</td></tr>
        )}
      </tbody>
    </table>
  );
}

export function GrupTablosu({ v }: { v: LabIcmali }) {
  const ciro = v.gruplar.reduce((t, g) => t + g.ciro, 0);
  return (
    <table className="hi-tablo">
      <thead><tr><th>Grup</th><th className="sag">Tetkik Çeşidi</th><th className="sag">Adet</th><th className="sag">Ciro</th>
        <th className="sag">Kurum Payı</th><th className="sag">Hasta Payı</th><th className="sag">Maliyet</th><th className="sag">Brüt Kâr</th>
        <th>Marj</th><th className="sag">Tekrar</th><th>Ciro Payı</th></tr></thead>
      <tbody>
        {v.gruplar.length === 0 && <tr><td colSpan={11} className="bos">Kayıt yok.</td></tr>}
        {v.gruplar.map(g => {
          const mr = labMarjRozeti(g.marj, g.maliyet); const pay = ciro > 0 ? 100 * g.ciro / ciro : 0;
          return (
            <tr key={g.grup}><td><b>{g.ad}</b></td><td className="sag">{g.cesit}</td><td className="sag">{g.adet}</td>
              <td className="sag">{p(g.ciro)}</td><td className="sag">{p(g.kurum)}</td><td className="sag">{p(g.hasta)}</td>
              <td className="sag">{tire(g.maliyet)}</td><td className="sag">{p(g.kar)}</td>
              <td><span className={'bo-rz ' + mr.renk}>{mr.ad}</span></td><td className="sag">{g.tekrar || '—'}</td>
              <td><Cubuk oran={pay} /> %{pay.toFixed(1).replace('.', ',')}</td></tr>
          );
        })}
        {v.gruplar.length > 0 && (
          <tr className="top"><td>Toplam · {v.gruplar.length} grup</td><td className="sag">{v.gruplar.reduce((t, g) => t + g.cesit, 0)}</td>
            <td className="sag">{v.ozet.tetkik}</td><td className="sag">{p(v.ozet.ciro)}</td><td className="sag">{p(v.ozet.kurum)}</td>
            <td className="sag">{p(v.ozet.hastaPayi)}</td><td className="sag">{p(v.ozet.reaktif + v.ozet.disMaliyet)}</td>
            <td className="sag">{p(v.ozet.kar)}</td><td>{yuzde(v.ozet.marj)}</td><td className="sag">{v.ozet.tekrar}</td><td /></tr>
        )}
      </tbody>
    </table>
  );
}

export function CihazTablosu({ v }: { v: LabIcmali }) {
  const t = v.cihazlar.reduce((a, c) => ({ test: a.test + c.test, qc: a.qc + c.qc, ariza: a.ariza + c.arizaGun, reaktif: a.reaktif + c.reaktif }),
                              { test: 0, qc: 0, ariza: 0, reaktif: 0 });
  return (
    <>
      <div className="ki-not">Test = iç lab tetkik + tekrar · QC = dönemdeki kalite kontrol ölçümü · arıza = "arıza" cihaz olayı olan gün ·
        cihazı belli olmayan kalem tetkik kartındaki varsayılan cihaza yazılır.</div>
      <table className="hi-tablo">
        <thead><tr><th>Cihaz / Tezgâh</th><th>Bölüm</th><th className="sag">Test</th><th className="sag">QC / Kalibrasyon</th>
          <th className="sag">QC Oranı</th><th className="sag">Arıza</th><th className="sag">Reaktif</th><th className="sag">Test Başı Maliyet</th></tr></thead>
        <tbody>
          {v.cihazlar.length === 0 && <tr><td colSpan={8} className="bos">İç lab testi yok.</td></tr>}
          {v.cihazlar.map(c => (
            <tr key={c.id}><td><b>{c.ad}</b><div className="ki-soluk">{c.tetkikler}</div></td><td>{c.grup}</td>
              <td className="sag">{c.test}</td><td className="sag">{c.qc || '—'}</td><td className="sag">{c.qc ? yuzde(c.qcOrani) : '—'}</td>
              <td className="sag">{c.arizaGun ? `${c.arizaGun} gün` : '—'}</td><td className="sag">{tire(c.reaktif)}</td>
              <td className="sag">{tire(c.testBasi)}</td></tr>
          ))}
          {v.cihazlar.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {v.cihazlar.length} cihaz / tezgâh</td><td className="sag">{t.test}</td>
              <td className="sag">{t.qc}</td><td className="sag">{t.test ? yuzde(100 * t.qc / t.test) : '—'}</td>
              <td className="sag">{t.ariza ? `${t.ariza} gün` : '—'}</td><td className="sag">{p(t.reaktif)}</td>
              <td className="sag">{t.test ? p(t.reaktif / t.test) : '—'}</td></tr>
          )}
        </tbody>
      </table>
    </>
  );
}

export function DisLabTablosu({ v }: { v: LabIcmali }) {
  const [acik, setAcik] = useState<number[]>([]);
  const t = v.disLablar.reduce((a, d) => ({ adet: a.adet + d.adet, ciro: a.ciro + d.ciro, maliyet: a.maliyet + d.maliyet }), { adet: 0, ciro: 0, maliyet: 0 });
  const farkRz = (f: number) => f < 0 ? <span className="bo-rz kir">zarar {p(-f)}</span> : <span className="bo-rz ok">kâr {p(f)}</span>;
  return (
    <>
      <div className="ki-not">Maliyet = gönderim satırındaki fiyat, yoksa dış lab fiyat listesi · satıra tıkla: tetkik kırılımı · zarar edenler kırmızı.</div>
      <table className="hi-tablo">
        <thead><tr><th>Dış Laboratuvar</th><th className="sag">Tetkik Çeşidi</th><th className="sag">Gönderilen</th>
          <th className="sag">Bizim Faturaladığımız</th><th className="sag">Dış Lab Maliyeti</th><th className="sag">Fark</th><th>Durum</th>
          <th className="sag">Ort. Sonuç</th></tr></thead>
        <tbody>
          {v.disLablar.length === 0 && <tr><td colSpan={8} className="bos">Bu dönemde dış laboratuvara gönderilen tetkik yok.</td></tr>}
          {v.disLablar.map(d => (
            <Fragment key={d.id}>
              <tr className={'ac' + (d.fark < 0 ? ' lb-zarar' : '')} onClick={() => setAcik(a => a.includes(d.id) ? a.filter(x => x !== d.id) : [...a, d.id])}>
                <td>{acik.includes(d.id) ? '▾' : '▸'} <b>{d.ad}</b></td><td className="sag">{d.cesit}</td><td className="sag">{d.adet}</td>
                <td className="sag">{p(d.ciro)}</td><td className="sag">{p(d.maliyet)}</td><td className="sag"><b>{p(d.fark)}</b></td>
                <td>{farkRz(d.fark)}</td><td className="sag">{gun(d.ortGun)}</td></tr>
              {acik.includes(d.id) && d.tetkikler.map(x => (
                <tr key={x.kod} className={'lb-alt' + (x.fark < 0 ? ' lb-zarar' : '')}><td>&nbsp;&nbsp;{x.kod} {x.ad}</td><td />
                  <td className="sag">{x.adet}</td><td className="sag">{p(x.ciro)}</td>
                  <td className="sag">{p(x.maliyet)} ({p(x.adet ? x.maliyet / x.adet : 0)}/test)</td><td className="sag">{p(x.fark)}</td>
                  <td>{x.fark < 0 ? 'fiyat listesi altında' : ''}</td><td className="sag">{gun(x.ortGun)}</td></tr>
              ))}
            </Fragment>
          ))}
          {v.disLablar.length > 0 && (
            <tr className="top"><td>Toplam · {v.disLablar.length} dış laboratuvar</td><td /><td className="sag">{t.adet}</td>
              <td className="sag">{p(t.ciro)}</td><td className="sag">{p(t.maliyet)}</td><td className="sag">{p(t.ciro - t.maliyet)}</td>
              <td>{t.ciro > 0 ? yuzde(100 * (t.ciro - t.maliyet) / t.ciro) : '—'}</td><td /></tr>
          )}
        </tbody>
      </table>
    </>
  );
}

export function KaliteTablosu({ v }: { v: LabIcmali }) {
  const o = v.ozet;
  const rutin = v.tatDagilimi.reduce((t, d) => t + d.adet, 0);
  const ret = v.retNedenleri.reduce((t, r) => t + r.adet, 0);
  return (
    <div className="lb-kalite">
      <div>
        <div className="lb-bas">Sonuç Süresi (TAT) Dağılımı <span className="ki-soluk">numune kabul → sonuç onayı · rutin iç lab</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Süre</th><th className="sag">Tetkik</th><th className="sag">Oran</th><th>Dağılım</th></tr></thead>
          <tbody>
            {v.tatDagilimi.map(d => {
              const oran = rutin ? 100 * d.adet / rutin : 0;
              return <tr key={d.ad}><td>{d.ad}</td><td className="sag">{d.adet}</td><td className="sag">{yuzde(oran)}</td><td><Cubuk oran={oran} /></td></tr>;
            })}
            <tr className="top"><td>Toplam · ort. {sure(o.ortTat)}</td><td className="sag">{rutin}</td><td colSpan={2} /></tr>
          </tbody>
        </table>
      </div>
      <div>
        <div className="lb-bas">Numune Ret Nedenleri <span className="ki-soluk">numune bazında</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Neden</th><th className="sag">Adet</th><th className="sag">Pay</th><th>En Çok</th></tr></thead>
          <tbody>
            {v.retNedenleri.length === 0 && <tr><td colSpan={4} className="bos">Reddedilen numune yok.</td></tr>}
            {v.retNedenleri.map(r => (
              <tr key={r.ad}><td>{r.ad}</td><td className="sag">{r.adet}</td><td className="sag">{ret ? yuzde(100 * r.adet / ret) : '—'}</td>
                <td>{r.enCok || '—'}</td></tr>
            ))}
            <tr className="top"><td>Toplam ret · {o.numune} numune</td><td className="sag">{o.ret}</td><td className="sag">{yuzde(o.retOrani)}</td><td /></tr>
          </tbody>
        </table>
      </div>
      <div className="lb-genis">
        <div className="lb-bas">Hedef Süreyi En Çok Aşan İstemler <span className="ki-soluk">hedef tetkik tanımından (acil istemde acil hedef)</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Tarih</th><th>Protokol No</th><th>Tetkik</th><th>İsteyen Bölüm</th><th className="sag">Hedef</th>
            <th className="sag">Gerçek</th><th className="sag">Aşım</th></tr></thead>
          <tbody>
            {v.asanlar.length === 0 && <tr><td colSpan={7} className="bos">Hedef süreyi aşan tetkik yok.</td></tr>}
            {v.asanlar.map((a, i) => (
              <tr key={i}><td>{tarihKisa(a.tarih)}</td><td>{a.protokolNo}</td><td>{a.tetkik}</td><td>{a.bolum || '—'}</td>
                <td className="sag">{sure(a.hedef)}</td><td className="sag">{sure(a.gercek)}</td><td className="sag lb-asim">+{sure(a.asim)}</td></tr>
            ))}
            {o.asan > v.asanlar.length && (
              <tr className="top"><td colSpan={7}>En çok aşan {v.asanlar.length} gösteriliyor · dönemde toplam {o.asan} tetkik hedefi aştı</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
