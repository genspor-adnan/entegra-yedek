import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { GoruntulemeIcmali } from '../../api/uclar/goruntulemeIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { sure, yuzde } from '../labIcmal/labIcmalOrtak';
import { dolulukRozeti, grMarjRozeti } from './goruntulemeOrtak';

/** Görüntüleme icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}

/** MODALİTELER - tık tek, Ctrl / Shift çoklu; ▸ en çok çekilen 3 tetkik; seçilenler A4'ü süzer. */
export function ModaliteTablosu({ v, secili, setSecili }: {
  v: GoruntulemeIcmali; secili: number[]; setSecili(s: number[]): void;
}) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.modaliteler.map(m => m.modalite), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.modaliteler.length > 0 && v.modaliteler.every(m => secili.includes(m.modalite));
  const o = v.ozet;
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.modaliteler.map(m => m.modalite))} /></th>
        <th>Modalite</th><th className="sag">Çekim</th><th className="sag">Ciro</th><th className="sag">Kurum %</th>
        <th className="sag">Kontrastlı</th><th className="sag">Kontrast / Sarf</th><th className="sag">Telerad</th><th className="sag">Brüt Kâr</th>
        <th>Marj</th><th className="sag">Ort. Rapor</th><th className="sag">Hedef Aşan</th></tr></thead>
      <tbody>
        {v.modaliteler.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde çekim yok.</td></tr>}
        {v.modaliteler.map(m => {
          const sec = secili.includes(m.modalite); const mr = grMarjRozeti(m.marj, m.sarf + m.telerad); const a = acik.includes(m.modalite);
          return (
            <Fragment key={m.modalite}>
              <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(m.modalite, e)}
                  title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(m.modalite, e)} /></td>
                <td><a className="ki-lnk" onClick={e => ac(m.modalite, e)}>{a ? '▾' : '▸'}</a> <b>{m.ad}</b></td>
                <td className="sag">{m.cekim}</td><td className="sag"><b>{p(m.ciro)}</b></td><td className="sag">%{m.kurumYuzde}</td>
                <td className="sag">{m.kontrastli || '—'}</td><td className="sag">{tire(m.sarf)}</td><td className="sag">{tire(m.telerad)}</td>
                <td className="sag">{p(m.kar)}</td><td><span className={'bo-rz ' + mr.renk}>{mr.ad}</span></td>
                <td className="sag">{sure(m.ortRapor)}</td><td className="sag">{m.asan ? <span className="lb-asim">{m.asan}</span> : '—'}</td>
              </tr>
              {a && m.enCok.map((t, i) => (
                <tr key={i} className="lb-alt"><td /><td colSpan={2}>&nbsp;&nbsp;{i + 1}. {t.ad}</td><td className="sag">{t.adet} çekim · {p(t.ciro)}</td>
                  <td colSpan={8} /></tr>
              ))}
            </Fragment>
          );
        })}
        {v.modaliteler.length > 0 && (
          <tr className="top"><td /><td>Toplam · {v.modaliteler.length} modalite</td><td className="sag">{o.cekim}</td><td className="sag">{p(o.ciro)}</td>
            <td className="sag">{o.ciro > 0 ? `%${Math.round(100 * o.kurum / o.ciro)}` : '—'}</td><td className="sag">{o.kontrastli}</td>
            <td className="sag">{p(o.sarf)}</td><td className="sag">{p(o.teleradMaliyet)}</td><td className="sag">{p(o.kar)}</td>
            <td>{yuzde(o.marj)}</td><td className="sag">{sure(o.ortRapor)}</td><td className="sag">{o.asan}</td></tr>
        )}
      </tbody>
    </table>
  );
}

export function TetkikTablosu({ v }: { v: GoruntulemeIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>SUT / Kod</th><th>Tetkik</th><th>Modalite</th><th className="sag">Adet</th><th className="sag">Ciro</th>
        <th className="sag">Ort. Fiyat</th><th className="sag">Sarf / Çekim</th><th className="sag">Maliyet</th><th>Marj</th></tr></thead>
      <tbody>
        {v.tetkikler.length === 0 && <tr><td colSpan={9} className="bos">Kayıt yok.</td></tr>}
        {v.tetkikler.map(t => {
          const mr = grMarjRozeti(t.marj, t.maliyet);
          return (
            <tr key={t.hizmetId}><td>{t.kod}</td><td><b>{t.ad}</b>
              {t.faturasiz > 0 && <span className="bo-rz sari lb-k" title="Başvuruda bu çekimin satırı yok">{t.faturasiz} faturasız</span>}</td>
              <td>{t.modalite}</td><td className="sag">{t.adet}</td><td className="sag">{p(t.ciro)}</td><td className="sag">{p(t.ortFiyat)}</td>
              <td className="sag">{tire(t.sarfCekim)}</td><td className="sag">{tire(t.maliyet)}</td>
              <td><span className={'bo-rz ' + mr.renk}>{mr.ad}</span></td></tr>
          );
        })}
        {v.tetkikler.length > 0 && (
          <tr className="top"><td colSpan={3}>Toplam · {v.tetkikler.length} tetkik</td><td className="sag">{v.ozet.cekim}</td>
            <td className="sag">{p(v.ozet.ciro)}</td><td /><td /><td className="sag">{p(v.ozet.sarf + v.ozet.teleradMaliyet)}</td>
            <td>{yuzde(v.ozet.marj)}</td></tr>
        )}
      </tbody>
    </table>
  );
}

export function RaporlayanTablosu({ v }: { v: GoruntulemeIcmali }) {
  const enCok = Math.max(1, ...v.raporlayanlar.map(r => r.rapor));
  return (
    <>
      <div className="ki-not">Rapor süresi = çekim → ilk onaylı rapor · hedef: rutin {sure(v.ozet.hedefRutin)}, acil {sure(v.ozet.hedefAcil)}
        (ayar), teleradyolojide sözleşme SLA'sı · revizyon = onaydan sonra eklenen ek rapor · ikinci okuma = konsültasyon.</div>
      <table className="hi-tablo">
        <thead><tr><th>Raporlayan</th><th>Tür</th><th className="sag">Rapor</th><th className="sag">Bekleyen</th><th className="sag">Ort. Süre</th>
          <th className="sag">Hedef Aşan</th><th className="sag">Aşım Oranı</th><th className="sag">Kritik Bulgu</th>
          <th className="sag">İkinci Okuma</th><th className="sag">Revizyon</th><th>İş Yükü</th></tr></thead>
        <tbody>
          {v.raporlayanlar.length === 0 && <tr><td colSpan={11} className="bos">Bu dönemde onaylı rapor yok.</td></tr>}
          {v.raporlayanlar.map(r => (
            <tr key={`${r.tur}-${r.id}`}><td><b>{r.ad}</b></td>
              <td><span className={'bo-rz ' + (r.tur === 'ic' ? 'ok' : 'mavi')}>{r.tur === 'ic' ? 'İç radyolog' : 'Teleradyoloji'}</span></td>
              <td className="sag">{r.rapor}</td><td className="sag">{r.bekleyen || '—'}</td><td className="sag">{sure(r.ortSure)}</td>
              <td className="sag">{r.asan ? <span className="lb-asim">{r.asan}</span> : '—'}</td>
              <td className="sag">{r.rapor ? yuzde(100 * r.asan / r.rapor) : '—'}</td><td className="sag">{r.kritik || '—'}</td>
              <td className="sag">{r.ikinciOkuma || '—'}</td><td className="sag">{r.revizyon || '—'}</td>
              <td><Cubuk oran={100 * r.rapor / enCok} /></td></tr>
          ))}
          {v.raporlayanlar.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {v.raporlayanlar.length} raporlayan</td>
              <td className="sag">{v.raporlayanlar.reduce((t, r) => t + r.rapor, 0)}</td><td className="sag">{v.ozet.bekleyen}</td>
              <td className="sag">{sure(v.ozet.ortRapor)}</td><td className="sag">{v.ozet.asan}</td><td />
              <td className="sag">{v.raporlayanlar.reduce((t, r) => t + r.kritik, 0)}</td>
              <td className="sag">{v.raporlayanlar.reduce((t, r) => t + r.ikinciOkuma, 0)}</td>
              <td className="sag">{v.raporlayanlar.reduce((t, r) => t + r.revizyon, 0)}</td><td /></tr>
          )}
        </tbody>
      </table>
      {v.hedefAsanlar.length > 0 && (<>
        <div className="lb-bas">Hedef Süreyi En Çok Aşan Çekimler</div>
        <table className="hi-tablo">
          <thead><tr><th>Tarih</th><th>Protokol No</th><th>Tetkik</th><th>Modalite</th><th className="sag">Hedef</th>
            <th className="sag">Gerçek</th><th className="sag">Aşım</th></tr></thead>
          <tbody>
            {v.hedefAsanlar.map((a, i) => (
              <tr key={i}><td>{tarihKisa(a.tarih)}</td><td>{a.protokolNo}</td><td>{a.tetkik}</td><td>{a.modalite}</td>
                <td className="sag">{sure(a.hedef)}</td><td className="sag">{sure(a.gercek)}</td><td className="sag lb-asim">+{sure(a.asim)}</td></tr>
            ))}
            {v.ozet.asan > v.hedefAsanlar.length && (
              <tr className="top"><td colSpan={7}>En çok aşan {v.hedefAsanlar.length} gösteriliyor · toplam {v.ozet.asan}</td></tr>
            )}
          </tbody>
        </table>
      </>)}
    </>
  );
}

export function CihazTablosu({ v }: { v: GoruntulemeIcmali }) {
  const t = v.cihazlar.reduce((a, c) => ({ cekim: a.cekim + c.cekim, kul: a.kul + c.kullanimSaat, kap: a.kap + c.kapasiteSaat, kapali: a.kapali + c.kapaliGun, sarf: a.sarf + c.sarf }),
                              { cekim: 0, kul: 0, kap: 0, kapali: 0, sarf: 0 });
  return (
    <>
      <div className="ki-not">Kapasite = çalışma günleri × (mesai − öğle arası) − arıza / bakım kapatmaları · kullanım = çekim × cihazın
        varsayılan çekim süresi · çalışma saatleri Radyoloji › Ayarlar › Cihazlar'dan.
        {v.ozet.cihazsiz > 0 && ` ${v.ozet.cihazsiz} çekimde cihaz yazılı değil - dolulukta sayılmadı.`}</div>
      <table className="hi-tablo">
        <thead><tr><th>Cihaz</th><th>Modalite</th><th className="sag">Çekim</th><th className="sag">Kullanım</th><th className="sag">Kapasite</th>
          <th>Doluluk</th><th className="sag">Arıza / Bakım</th><th className="sag">Sarf</th><th className="sag">Sarf / Çekim</th></tr></thead>
        <tbody>
          {v.cihazlar.length === 0 && <tr><td colSpan={9} className="bos">Tanımlı cihaz yok.</td></tr>}
          {v.cihazlar.map(c => {
            const d = dolulukRozeti(c.doluluk);
            return (
              <tr key={c.id}><td><b>{c.ad}</b></td><td>{c.modalite}</td><td className="sag">{c.cekim}</td>
                <td className="sag">{c.kullanimSaat.toFixed(1).replace('.', ',')} sa</td><td className="sag">{c.kapasiteSaat.toFixed(1).replace('.', ',')} sa</td>
                <td><Cubuk oran={c.doluluk} /> <span className={'bo-rz ' + d.renk}>{d.ad}</span></td>
                <td className="sag">{c.kapaliGun ? `${c.kapaliGun} gün` : '—'}</td><td className="sag">{tire(c.sarf)}</td>
                <td className="sag">{tire(c.sarfCekim)}</td></tr>
            );
          })}
          {v.cihazlar.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {v.cihazlar.length} cihaz</td><td className="sag">{t.cekim}</td>
              <td className="sag">{t.kul.toFixed(1).replace('.', ',')} sa</td><td className="sag">{t.kap.toFixed(1).replace('.', ',')} sa</td>
              <td>{yuzde(v.ozet.doluluk)}</td><td className="sag">{t.kapali ? `${t.kapali} gün` : '—'}</td><td className="sag">{p(t.sarf)}</td><td /></tr>
          )}
        </tbody>
      </table>
    </>
  );
}

export function TeleradTablosu({ v }: { v: GoruntulemeIcmali }) {
  const gidenT = v.teleradGiden.reduce((t, g) => t + g.maliyet, 0);
  const gelenT = v.teleradGelen.reduce((t, g) => t + g.gelir, 0);
  const net = gelenT - gidenT;
  return (
    <>
      <div className="ki-not">Giden = bizim çekimlerimizi dışarıda raporlatmanın maliyeti (sözleşme ücreti, çekimin maliyetine dahil) ·
        gelen = bize raporlatan kurumların işi; gelir ciroya katılmaz, kendi dönem faturasıyla izlenir.</div>
      <div className="lb-kalite">
        <div>
          <div className="lb-bas">Giden · dışarıya raporlatılan</div>
          <table className="hi-tablo">
            <thead><tr><th>Kurum</th><th className="sag">Çekim</th><th className="sag">Birim Ücret</th><th className="sag">Maliyet</th></tr></thead>
            <tbody>
              {v.teleradGiden.length === 0 && <tr><td colSpan={4} className="bos">Dışarıya raporlatılan çekim yok.</td></tr>}
              {v.teleradGiden.map(g => (
                <tr key={g.kurumId}><td>{g.ad}</td><td className="sag">{g.cekim}</td><td className="sag">{p(g.birimUcret)}</td><td className="sag">{p(g.maliyet)}</td></tr>
              ))}
              <tr className="top"><td>Toplam</td><td className="sag">{v.ozet.giden}</td><td /><td className="sag">{p(gidenT)}</td></tr>
            </tbody>
          </table>
        </div>
        <div>
          <div className="lb-bas">Gelen · bize raporlatan</div>
          <table className="hi-tablo">
            <thead><tr><th>Kurum</th><th className="sag">Çekim</th><th className="sag">Raporlanan</th><th className="sag">SLA Aşan</th><th className="sag">Gelir</th></tr></thead>
            <tbody>
              {v.teleradGelen.length === 0 && <tr><td colSpan={5} className="bos">Gelen teleradyoloji işi yok.</td></tr>}
              {v.teleradGelen.map(g => (
                <tr key={g.kurumId}><td>{g.ad}</td><td className="sag">{g.cekim}</td><td className="sag">{g.raporlanan}</td>
                  <td className="sag">{g.slaAsan ? <span className="lb-asim">{g.slaAsan}</span> : '—'}</td><td className="sag">{p(g.gelir)}</td></tr>
              ))}
              <tr className="top"><td>Toplam</td><td className="sag">{v.ozet.gelen}</td><td className="sag">{v.teleradGelen.reduce((t, g) => t + g.raporlanan, 0)}</td>
                <td className="sag">{v.teleradGelen.reduce((t, g) => t + g.slaAsan, 0)}</td><td className="sag">{p(gelenT)}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
      <p>Teleradyoloji net: <span className={'bo-rz ' + (net < 0 ? 'kir' : 'ok')}>{net < 0 ? '−' : '+'}{p(Math.abs(net))}</span>
        <span className="ki-soluk"> (gelen gelir − giden maliyet)</span></p>
    </>
  );
}
