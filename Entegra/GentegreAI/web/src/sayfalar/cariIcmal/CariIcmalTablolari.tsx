import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { CariDilim, CariIcmal, CariIcmalSatiri } from '../../api/uclar/cariIcmal';
import { para } from '../../bilesenler/bicim';
import { dovizBakiyeMetni } from '../../bilesenler/grid/satirHucre';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';

/** Cari İcmalinin sekme tabloları. Rakamlar sunucudan gelir; burada yalnız gösterim. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');
/** Bakiye: + borç (B), - alacak (A) - mutlak değerle. */
export const bakiyeMetni = (n: number) => (Math.abs(n) < 0.005 ? p(0) : `${p(Math.abs(n))} ${n > 0 ? 'B' : 'A'}`);
const bakiyeSinifi = (n: number) => (n > 0.005 ? 'kir' : n < -0.005 ? 'ci-yesil' : '');

// ------------------------------------------------------------ cari bazında ----
export function CariTablosu({ satirlar, secili, setSecili, kartAc, ekstreAc }: {
  satirlar: CariIcmalSatiri[]; secili: number[]; setSecili(s: number[]): void;
  kartAc(id: number): void; ekstreAc(c: CariIcmalSatiri): void;
}) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const sira = satirlar.map(c => c.id);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, sira, son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const hepsi = satirlar.length > 0 && satirlar.every(c => secili.includes(c.id));
  const gruplar: [CariIcmalSatiri['grup'], string][] = [['musteri', '👥 Müşteriler'], ['tedarikci', '🚚 Tedarikçiler']];
  const t = (l: CariIcmalSatiri[], f: (c: CariIcmalSatiri) => number) => l.reduce((s, c) => s + f(c), 0);
  const ToplamSatiri = ({ l, ad, sinif }: { l: CariIcmalSatiri[]; ad: string; sinif: string }) => (
    <tr className={sinif}><td /><td colSpan={4}>{ad} ({l.length})</td>
      <td className="sag">{p(t(l, c => c.devir))}</td><td className="sag">{p(t(l, c => c.donemBorc))}</td>
      <td className="sag">{p(t(l, c => c.donemAlacak))}</td><td className="sag">{bakiyeMetni(t(l, c => c.bakiye))}</td>
      {/* Net satırında alacak - borç (işaretli); grup satırlarında tutar. */}
      <td className="sag">{sinif === 'top' ? bakiyeMetni(t(l, c => c.vadesiGecen)) : p(t(l, c => Math.abs(c.vadesiGecen)))}</td><td colSpan={3} /></tr>
  );
  return (
    <table className="hi-tablo ci-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : sira)} /></th>
        <th>Kod</th><th>Ünvan</th><th>Tür</th><th>Temsilci</th>
        <th className="sag">Devir</th><th className="sag">Dönem Borç</th><th className="sag">Dönem Alacak</th>
        <th className="sag">Bakiye</th><th className="sag">Vadesi Geçen</th><th className="sag">En Eski</th>
        <th>Son Hareket</th><th className="sag">Risk</th></tr></thead>
      <tbody>
        {satirlar.length === 0 && <tr><td colSpan={13} className="bos">Bu süzgeçte cari yok.</td></tr>}
        {gruplar.map(([g, ad]) => {
          const l = satirlar.filter(c => c.grup === g);
          if (l.length === 0) return null;
          return (
            <Fragment key={g}>
              <tr className="ci-grup"><td colSpan={13}>{ad} · {l.length} cari</td></tr>
              {l.map(c => {
                const sec = secili.includes(c.id);
                const dvz = dovizBakiyeMetni(c.doviz);
                return (
                  <Fragment key={c.id}>
                    <tr className={'ac' + (sec ? ' sec' : '') + (c.durum !== 1 ? ' ci-pasif' : '')}
                        onClick={e => tikla(c.id, e)} onDoubleClick={() => ekstreAc(c)}
                        title="Tıkla: seç (Ctrl / Shift çoklu) · Çift tık: cari ekstresi">
                      <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(c.id, e)} /></td>
                      <td>
                        <span className="ok" onClick={e => { e.stopPropagation(); setAcik(a => { const y = new Set(a); if (y.has(c.id)) y.delete(c.id); else y.add(c.id); return y }) }}>
                          {acik.has(c.id) ? '▾' : '▸'}</span>{c.kod}</td>
                      <td><a className="ki-lnk" title="Cari kartını aç" onClick={e => { e.stopPropagation(); kartAc(c.id) }}>{c.ad}</a></td>
                      <td>{c.musteri && <span className="bo-rz mavi">M</span>} {c.tedarikci && <span className="bo-rz pas">T</span>}</td>
                      <td>{c.temsilci || '—'}</td>
                      <td className="sag">{p(c.devir)}</td><td className="sag">{p(c.donemBorc)}</td><td className="sag">{p(c.donemAlacak)}</td>
                      <td className={'sag ' + bakiyeSinifi(c.bakiye)}><b>{bakiyeMetni(c.bakiye)}</b></td>
                      <td className={'sag' + (Math.abs(c.vadesiGecen) > 0.005 ? ' kir' : '')}>{tire(Math.abs(c.vadesiGecen))}</td>
                      <td className={'sag' + (c.enEskiGun > 60 ? ' kir' : '')}>{c.enEskiGun > 0 && Math.abs(c.vadesiGecen) > 0.005 ? `${c.enEskiGun} gün` : '—'}</td>
                      <td>{c.sonHareket ? tarihKisa(c.sonHareket) : '—'}</td>
                      <td className="sag">{c.riskYuzde == null ? '—'
                        : <span className={'bo-rz ' + (c.riskYuzde > 100 ? 'kir' : c.riskYuzde >= 70 ? 'sari' : 'ok')}>%{c.riskYuzde}</span>}</td>
                    </tr>
                    {acik.has(c.id) && (
                      <tr className="det"><td colSpan={13}>
                        {dvz ? <>Kendi para biriminde: <b>{dvz}</b> · </> : 'Tek para birimi (TL) · '}
                        yaşlandırma: gelmemiş {tire(Math.abs(c.gelmemis))} · 0–30 {tire(Math.abs(c.d30))} · 31–60 {tire(Math.abs(c.d60))}
                        {' '}· 61–90 {tire(Math.abs(c.d90))} · 90+ {tire(Math.abs(c.d90p))}
                        {c.kategori && <> · grup {c.kategori}</>}{c.il && <> · {c.il}</>}
                        {c.sonTahsilat && <> · son tahsilat {tarihKisa(c.sonTahsilat)}</>}
                      </td></tr>
                    )}
                  </Fragment>
                );
              })}
              <ToplamSatiri l={l} ad={g === 'musteri' ? 'Müşteriler toplamı' : 'Tedarikçiler toplamı'} sinif="ci-ara" />
            </Fragment>
          );
        })}
        {satirlar.length > 0 && <ToplamSatiri l={satirlar} ad="Net" sinif="top" />}
      </tbody>
    </table>
  );
}

// ------------------------------------------------------------- yaşlandırma ----
const DILIM_RENK = ['#9cc4ee', '#e0a33a', '#d9783a', '#c96a3a', '#c0413d'];

function DilimTablosu({ baslik, not, d }: { baslik: string; not: string; d: CariDilim[] }) {
  const top = d.reduce((s, x) => s + x.tutar, 0);
  const cari = d.reduce((s, x) => s + x.cari, 0);
  return (
    <div className="ci-kutu">
      <h4>{baslik} <span>{not}</span></h4>
      <div className="ci-cubuk">{d.map((x, i) => top > 0 && x.tutar > 0
        ? <i key={i} title={`${x.ad}: ${p(x.tutar)}`} style={{ width: `${(100 * x.tutar) / top}%`, background: DILIM_RENK[i] }} /> : null)}</div>
      <table className="hi-tablo">
        <thead><tr><th>Dilim</th><th className="sag">Tutar</th><th className="sag">Cari</th><th className="sag">Pay</th><th>En büyük</th></tr></thead>
        <tbody>
          {d.map((x, i) => (
            <tr key={x.ad}><td><i className="ci-nokta" style={{ background: DILIM_RENK[i] }} />{x.ad}</td>
              <td className={'sag' + (i === 4 && x.tutar > 0.005 ? ' kir' : '')}>{tire(x.tutar)}</td>
              <td className="sag">{x.cari}</td><td className="sag">{top > 0 && x.tutar > 0 ? `%${((100 * x.tutar) / top).toFixed(1)}` : '—'}</td>
              <td>{x.enBuyuk ? `${x.enBuyuk} · ${p(x.enBuyukTutar)}` : ''}</td></tr>
          ))}
          <tr className="top"><td>Toplam</td><td className="sag">{p(top)}</td><td className="sag">{cari}</td><td className="sag">%100</td><td /></tr>
        </tbody>
      </table>
    </div>
  );
}

export function YaslandirmaSekmesi({ v }: { v: CariIcmal }) {
  return (<>
    <div className="ci-iki">
      <DilimTablosu baslik="Alacak Yaşlandırma (borçlu cariler)" not="tahsilat önce vadesi en eski borcu kapatır" d={v.yaslandirma.alacak} />
      <DilimTablosu baslik="Borç Yaşlandırma (alacaklı cariler)" not="ödememiz önce vadesi en eski alacağı kapatır" d={v.yaslandirma.borc} />
    </div>
    <div className="ci-kutu">
      <h4>Nakit beklentisi — önümüzdeki 8 hafta <span>vadesi gelecek açık alacak / borç ve çek vadeleri</span></h4>
      <table className="hi-tablo">
        <thead><tr><th>Hafta</th><th className="sag">Beklenen tahsilat</th><th className="sag">Yapılacak ödeme</th><th className="sag">Fark</th>
          <th className="sag">Alınan çek vadesi</th><th className="sag">Verilen çek vadesi</th></tr></thead>
        <tbody>{v.nakit.map(n => {
          const f = n.tahsilat - n.odeme;
          return (
            <tr key={n.bas}><td>{tarihKisa(n.bas)} – {tarihKisa(n.bit)}</td><td className="sag">{tire(n.tahsilat)}</td>
              <td className="sag">{tire(n.odeme)}</td>
              <td className={'sag ' + (f < -0.005 ? 'kir' : f > 0.005 ? 'ci-yesil' : '')}>{Math.abs(f) > 0.005 ? `${f > 0 ? '+' : '−'}${p(Math.abs(f))}` : '—'}</td>
              <td className="sag">{tire(n.cekAlinan)}</td><td className="sag">{tire(n.cekVerilen)}</td></tr>
          );
        })}</tbody>
      </table>
    </div>
  </>);
}

// --------------------------------------------------------------- kırılımlar ----
export function KirilimSekmesi({ v }: { v: CariIcmal }) {
  const k = v.kirilim;
  return (
    <div className="ci-iki">
      <div className="ci-kutu"><h4>Temsilci bazında <span>müşteriler</span></h4>
        <table className="hi-tablo"><thead><tr><th>Temsilci</th><th className="sag">Cari</th><th className="sag">Dönem satış</th>
          <th className="sag">Tahsilat</th><th className="sag">Bakiye</th><th className="sag">Vadesi geçen</th></tr></thead>
          <tbody>{k.temsilci.length === 0 ? <tr><td colSpan={6} className="bos">Müşteri yok.</td></tr> : k.temsilci.map(x => (
            <tr key={x.ad}><td>{x.ad || <span className="ki-soluk">(temsilcisiz)</span>}</td><td className="sag">{x.cari}</td>
              <td className="sag">{tire(x.satis)}</td><td className="sag">{tire(x.tahsilat)}</td>
              <td className="sag">{bakiyeMetni(x.bakiye)}</td><td className={'sag' + (x.vadesiGecen > 0.005 ? ' kir' : '')}>{tire(x.vadesiGecen)}</td></tr>
          ))}</tbody></table></div>
      <div className="ci-kutu"><h4>Para birimi bazında <span>kendi para biriminde ve TL karşılığı (hareket kuru)</span></h4>
        <table className="hi-tablo"><thead><tr><th>Para</th><th className="sag">Cari</th><th className="sag">Alacak</th>
          <th className="sag">Borç</th><th className="sag">Net (kendi)</th><th className="sag">TL karşılığı</th></tr></thead>
          <tbody>{k.para.map(x => (
            <tr key={x.doviz}><td>{x.doviz}</td><td className="sag">{x.cari}</td><td className="sag">{tire(x.alacak)}</td>
              <td className="sag">{tire(x.borc)}</td><td className="sag">{bakiyeMetni(x.alacak - x.borc)}</td><td className="sag">{bakiyeMetni(x.yerel)}</td></tr>
          ))}</tbody></table></div>
      <div className="ci-kutu"><h4>Grup (kategori) bazında</h4>
        <table className="hi-tablo"><thead><tr><th>Grup</th><th className="sag">Cari</th><th className="sag">Bakiye</th><th className="sag">Vadesi geçen</th></tr></thead>
          <tbody>{k.kategori.map(x => (
            <tr key={x.ad}><td>{x.ad || <span className="ki-soluk">(grupsuz)</span>}</td><td className="sag">{x.cari}</td>
              <td className="sag">{bakiyeMetni(x.bakiye)}</td><td className={'sag' + (x.vadesiGecen > 0.005 ? ' kir' : '')}>{tire(x.vadesiGecen)}</td></tr>
          ))}</tbody></table></div>
      <div className="ci-kutu"><h4>İl bazında <span>bakiyeye göre ilk 10</span></h4>
        <table className="hi-tablo"><thead><tr><th>İl</th><th className="sag">Cari</th><th className="sag">Bakiye</th><th className="sag">Dönem satış</th></tr></thead>
          <tbody>{k.il.map(x => (
            <tr key={x.ad}><td>{x.ad || <span className="ki-soluk">(adres yok)</span>}</td><td className="sag">{x.cari}</td>
              <td className="sag">{bakiyeMetni(x.bakiye)}</td><td className="sag">{tire(x.satis)}</td></tr>
          ))}</tbody></table></div>
    </div>
  );
}

// ------------------------------------------------------------------- dikkat ----
export function DikkatSekmesi({ v, kartAc }: { v: CariIcmal; kartAc(id: number): void }) {
  const d = v.dikkat;
  const ad = (id: number, s: string) => <a className="ki-lnk" onClick={() => kartAc(id)}>{s}</a>;
  return (
    <div className="ci-iki">
      <div className="ci-kutu"><h4>⛔ Risk limiti aşanlar <span>bakiye / risk limiti</span></h4>
        <table className="hi-tablo"><thead><tr><th>Cari</th><th className="sag">Bakiye</th><th className="sag">Limit</th><th className="sag">Kullanım</th></tr></thead>
          <tbody>{d.limit.length === 0 ? <tr><td colSpan={4} className="bos">Limiti aşan cari yok.</td></tr> : d.limit.map(x => (
            <tr key={x.id}><td>{ad(x.id, x.ad)}</td><td className="sag">{p(x.bakiye)}</td><td className="sag">{p(x.riskLimiti)}</td>
              <td className="sag"><span className="bo-rz kir">%{x.yuzde}</span></td></tr>
          ))}</tbody></table></div>
      <div className="ci-kutu"><h4>⏱ 90 gündür tahsilat yok <span>borçlu müşteri, son tahsilat 90+ gün önce</span></h4>
        <table className="hi-tablo"><thead><tr><th>Cari</th><th className="sag">Bakiye</th><th>Son tahsilat</th><th>Temsilci</th></tr></thead>
          <tbody>{d.tahsilatsiz.length === 0 ? <tr><td colSpan={4} className="bos">Yok.</td></tr> : d.tahsilatsiz.map(x => (
            <tr key={x.id}><td>{ad(x.id, x.ad)}</td><td className="sag">{p(x.bakiye)}</td>
              <td className="kir">{x.sonTahsilat ? `${tarihKisa(x.sonTahsilat)} · ${x.gun} gün` : 'hiç yok'}</td><td>{x.temsilci || '—'}</td></tr>
          ))}</tbody></table></div>
      <div className="ci-kutu"><h4>↩ Alacak bakiyesi veren müşteriler <span>fazla ödeme / iade / avans</span></h4>
        <table className="hi-tablo"><thead><tr><th>Cari</th><th className="sag">Alacak bakiye</th><th>Son hareket</th></tr></thead>
          <tbody>{d.alacakli.length === 0 ? <tr><td colSpan={3} className="bos">Yok.</td></tr> : d.alacakli.map(x => (
            <tr key={x.id}><td>{ad(x.id, x.ad)}</td><td className="sag ci-yesil">{bakiyeMetni(x.bakiye)}</td>
              <td>{x.sonHareket ? tarihKisa(x.sonHareket) : '—'}</td></tr>
          ))}</tbody></table></div>
      <div className="ci-kutu"><h4>📆 7 gün içinde vadesi gelen ödemelerimiz</h4>
        <table className="hi-tablo"><thead><tr><th>Cari</th><th>Vade</th><th>Belge</th><th className="sag">Tutar</th></tr></thead>
          <tbody>{d.odemeler.length === 0 ? <tr><td colSpan={4} className="bos">Yok.</td></tr> : d.odemeler.map((x, i) => (
            <tr key={i}><td>{ad(x.id, x.ad)}</td><td>{tarihKisa(x.vade)}</td><td>{x.turAdi} {x.belgeNo}</td><td className="sag">{p(x.tutar)}</td></tr>
          ))}</tbody></table></div>
    </div>
  );
}
