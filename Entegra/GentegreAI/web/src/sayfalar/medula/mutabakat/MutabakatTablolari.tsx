import type { MedulaMutabakati } from '../../../api/uclar/medulaMutabakat';
import { para } from '../../../bilesenler/bicim';
import { tarihKisa } from '../../hasta/icmal/icmalOrtak';
import { huniYuzde, itirazRozeti, nedenRozeti } from './mutabakatOrtak';

/** Medula mutabakat icmalinin sekme tabloları (MedulaMutabakat). Rakamlar sunucudan. */

const p = (n: number) => para.format(n);
const tire = (n: number | null | undefined) => (n != null && Math.abs(n) > 0.005 ? p(n) : '—');

/** HUNİ: her adımda kaç takip kaldı, bir öncekinden kaç düştü. */
export function Huni({ v }: { v: MedulaMutabakati }) {
  const ilk = v.huni[0]?.adet ?? 0;
  return (
    <table className="hi-tablo">
      <thead><tr><th>Adım</th><th className="sag">Takip</th><th className="sag">Tutar (HBYS)</th>
        <th className="sag">Düşen</th><th style={{ width: '40%' }}>Oran</th></tr></thead>
      <tbody>
        {v.huni.map((a, i) => {
          const dusen = i > 0 ? v.huni[i - 1].adet - a.adet : 0;
          const y = huniYuzde(a.adet, ilk);
          return (
            <tr key={a.kod}><td><b>{i + 1}. {a.ad}</b></td><td className="sag">{a.adet}</td><td className="sag">{p(a.tutar)}</td>
              <td className={'sag' + (dusen > 0 ? ' kir' : '')}>{dusen > 0 ? `−${dusen}` : '—'}</td>
              <td><div className="ki-cubuk mm-huni"><i style={{ width: `${y}%` }} /></div><span className="ki-soluk"> %{y}</span></td></tr>
          );
        })}
        {v.huni.length === 0 && <tr><td colSpan={5} className="bos">Bu dönemde SGK takibi yok.</td></tr>}
      </tbody>
    </table>
  );
}

/**
 * FATURASIZ TAKİPLER - soldaki onay kutusu yalnız "Faturaya hazır" satırlarda:
 * engeli olan takip faturalanamaz, seçilmesi yanıltır.
 */
export function FaturasizTablosu({ v, secili, setSecili, hastaAc }: {
  v: MedulaMutabakati; secili: number[]; setSecili(s: number[]): void; hastaAc(id: number): void;
}) {
  const hazirlar = v.faturasiz.filter(t => t.neden === 'hazir').map(t => t.belgeId);
  const hepsi = hazirlar.length > 0 && hazirlar.every(id => secili.includes(id));
  const degistir = (id: number) => setSecili(secili.includes(id) ? secili.filter(x => x !== id) : [...secili, id]);
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} disabled={!hazirlar.length}
               title="Faturaya hazırların hepsi" onChange={() => setSecili(hepsi ? [] : hazirlar)} /></th>
        <th>Tarih</th><th>Takip No</th><th>Protokol No</th><th>Hasta</th><th>Bölüm / Hekim</th>
        <th className="sag">Tutar</th><th>Neden</th><th>Yapılacak</th></tr></thead>
      <tbody>
        {v.faturasiz.length === 0 && <tr><td colSpan={9} className="bos">Faturasız takip yok - dönem tamam.</td></tr>}
        {v.faturasiz.map(t => {
          const r = nedenRozeti(t.neden);
          const hazir = t.neden === 'hazir';
          const sec = secili.includes(t.belgeId);
          return (
            <tr key={t.belgeId} className={(hazir ? 'ac' : '') + (sec ? ' sec' : '')} onClick={() => hazir && degistir(t.belgeId)}>
              <td><input type="checkbox" checked={sec} disabled={!hazir} onClick={e => e.stopPropagation()}
                         onChange={() => degistir(t.belgeId)} /></td>
              <td>{tarihKisa(t.tarih)}</td><td>{t.takipNo || '—'}</td><td>{t.protokolNo}</td>
              <td><a className="ki-lnk" title="Hasta icmalini aç" onClick={e => { e.stopPropagation(); hastaAc(t.hastaId) }}>{t.hasta}</a></td>
              <td>{t.bolum || '—'}{t.hekim && ` · ${t.hekim}`}</td>
              <td className="sag">{p(t.yerelTutar)}</td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td><td className="ki-soluk">{r.yapilacak}</td>
            </tr>
          );
        })}
        {v.faturasiz.length > 0 && (
          <tr className="top"><td /><td colSpan={5}>{v.ozet.faturasiz} takip · {v.ozet.hazir} faturaya hazır</td>
            <td className="sag">{p(v.ozet.faturasizTutar)}</td><td colSpan={2} /></tr>
        )}
      </tbody>
    </table>
  );
}

export function FarkTablosu({ v }: { v: MedulaMutabakati }) {
  return (
    <>
      <div className="ki-not">HBYS tutarı ile Medula'nın kabul ettiği tutar arasındaki fark eşiği:
        <b> {p(v.esik)}</b> (Medula ayarı). Fark çoğunlukla SUT fiyatı, paket ya da eksik gönderilen hizmettir.</div>
      <table className="hi-tablo">
        <thead><tr><th>Protokol No</th><th>Hasta</th><th>Takip No</th><th>Fatura No</th><th className="sag">HBYS</th>
          <th className="sag">Medula</th><th className="sag">Fark</th><th className="sag">Katılım</th></tr></thead>
        <tbody>
          {v.farklar.length === 0 && <tr><td colSpan={8} className="bos">Eşiği aşan tutar farkı yok.</td></tr>}
          {v.farklar.map(f => (
            <tr key={f.belgeId}><td>{f.protokolNo}</td><td>{f.hasta}</td><td>{f.takipNo}</td><td>{f.faturaNo}</td>
              <td className="sag">{p(f.yerelTutar)}</td><td className="sag">{p(f.medulaTutar)}</td>
              <td className="sag kir">{p(f.fark)}</td><td className="sag">{tire(f.katilim)}</td></tr>
          ))}
          {v.farklar.length > 0 && (
            <tr className="top"><td colSpan={6}>{v.ozet.farkli} faturada fark</td>
              <td className="sag">{p(v.ozet.farkTutari)}</td><td /></tr>
          )}
        </tbody>
      </table>
    </>
  );
}

export function KesintiTablosu({ v }: { v: MedulaMutabakati }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Protokol No</th><th>Hasta</th><th>Fatura No</th><th>SUT Kodu</th><th>Kesinti Kodu</th><th>Açıklama</th>
        <th className="sag">Kesinti</th><th className="sag">İade</th><th className="sag">Net</th><th>İtiraz</th></tr></thead>
      <tbody>
        {v.kesintiler.length === 0 && <tr><td colSpan={10} className="bos">Bu dönemin faturalarında kesinti yok.</td></tr>}
        {v.kesintiler.map(k => {
          const r = itirazRozeti(k);
          return (
            <tr key={k.id}><td>{k.protokolNo}</td><td>{k.hasta}</td><td>{k.faturaNo}</td><td>{k.sutKodu || '—'}</td>
              <td>{k.kod || '—'}</td><td>{k.aciklama || '—'}</td><td className="sag kir">{p(k.tutar)}</td>
              <td className="sag">{tire(k.iade)}</td><td className="sag">{p(k.net)}</td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>
          );
        })}
        {v.kesintiler.length > 0 && (
          <tr className="top"><td colSpan={8}>{v.ozet.kesintiKalem} kalem · itirazda {p(v.ozet.itirazBekleyen)}</td>
            <td className="sag">{p(v.ozet.kesinti)}</td><td /></tr>
        )}
      </tbody>
    </table>
  );
}
