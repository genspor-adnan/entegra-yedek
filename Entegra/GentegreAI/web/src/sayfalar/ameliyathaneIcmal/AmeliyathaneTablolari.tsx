import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { AmeliyathaneIcmali } from '../../api/uclar/ameliyathaneIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { dkFark, dolulukRozeti, ilkVakaMetni, marjRozeti, saatMetni, sapmaRozeti, sureMetni, yuzde } from './ameliyathaneIcmalOrtak';

/** Ameliyathane icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (n ? String(n) : '—');
function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}
function Rz({ r }: { r: { ad: string; renk: string } }) { return <span className={'bo-rz ' + r.renk}>{r.ad}</span> }

/** SALONLAR - tık tek, Ctrl / Shift çoklu; ▸ cerrah dağılımı; seçilenler A4'ü süzer. */
export function SalonTablosu({ v, secili, setSecili }: { v: AmeliyathaneIcmali; secili: number[]; setSecili(x: number[]): void }) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.salonlar.map(s => s.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.salonlar.length > 0 && v.salonlar.every(s => secili.includes(s.id));
  const o = v.ozet;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.salonlar.map(s => s.id))} /></th>
          <th>Salon</th><th className="sag">Vaka</th><th className="sag">Plan Dışı</th><th className="sag">Kullanım</th><th className="sag">Kapasite</th>
          <th>Doluluk</th><th className="sag">Ort. Süre</th><th className="sag">Plan</th><th>Sapma</th><th>İlk Vaka Zamanında</th>
          <th className="sag">Ort. Devir</th><th className="sag">İptal</th><th className="sag">Ciro</th></tr></thead>
        <tbody>
          {v.salonlar.length === 0 && <tr><td colSpan={14} className="bos">Tanımlı salon yok.</td></tr>}
          {v.salonlar.map(s => {
            const sec = secili.includes(s.id);
            return (
              <Fragment key={s.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(s.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(s.id, e)} /></td>
                  <td><a className="ki-lnk" onClick={e => ac(s.id, e)}>{acik.includes(s.id) ? '▾' : '▸'}</a> <b>{s.ad}</b>
                    {s.brans && <span className="ki-soluk"> · {s.brans}</span>}</td>
                  <td className="sag">{s.vaka}</td><td className="sag">{tire(s.planDisi)}</td>
                  <td className="sag">{saatMetni(s.kullanimDk)}</td><td className="sag">{s.kapasiteDk ? saatMetni(s.kapasiteDk) : '—'}</td>
                  <td>{s.doluluk != null && <Cubuk oran={s.doluluk} />} <Rz r={dolulukRozeti(s.doluluk)} /></td>
                  <td className="sag">{sureMetni(s.ortSureDk)}</td><td className="sag">{sureMetni(s.ortPlanDk)}</td>
                  <td><Rz r={sapmaRozeti(s.sapma)} /></td><td>{ilkVakaMetni(s.ilkVakaZamaninda, s.ilkVaka)}</td>
                  <td className="sag">{sureMetni(s.ortDevirDk)}</td><td className={'sag' + (s.iptal ? ' kir' : '')}>{tire(s.iptal)}</td>
                  <td className="sag">{p(s.ciro)}</td>
                </tr>
                {acik.includes(s.id) && (
                  <tr className="lb-alt"><td /><td colSpan={13}>Cerrah dağılımı ({s.vaka}): {s.cerrahlar.map(c => `${c.ad} ${c.adet}`).join('  ·  ') || '—'}</td></tr>
                )}
              </Fragment>
            );
          })}
          {v.salonlar.length > 0 && (
            <tr className="top"><td /><td>Toplam · {v.salonlar.length} salon</td><td className="sag">{o.ameliyat}</td><td className="sag">{o.planDisi}</td>
              <td className="sag">{saatMetni(o.kullanimDk)}</td><td className="sag">{saatMetni(o.kapasiteDk)}</td><td>{yuzde(o.doluluk)}</td>
              <td className="sag">{sureMetni(o.ortSureDk)}</td><td className="sag">{sureMetni(o.ortPlanDk)}</td><td>{yuzde(o.sapma)}</td>
              <td>{ilkVakaMetni(o.ilkVakaZamaninda, o.ilkVaka)}</td><td className="sag">{sureMetni(o.ortDevirDk)}</td>
              <td className="sag">{o.iptal}</td><td className="sag">{p(o.ciro)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Kullanım = mesai içi masa süresi (salona alma → salondan çıkış) · kapasite = {o.isGunu} iş günü × salon mesaisi (salon kartında,
        varsayılan 08:00–17:00) · sapma = (gerçek − plan) / plan, plan dışı (acil) vakalar hariç · ilk vaka zamanında = günün ilk planlı vakası plandan en
        çok 10 dk sonra salonda · devir = aynı salonda çıkış → sonraki vakanın alınması.</div>
    </>
  );
}

export function CerrahTablosu({ v }: { v: AmeliyathaneIcmali }) {
  const o = v.ozet;
  const cerrahT = v.cerrahlar.reduce((a, c) => ({ vaka: a.vaka + c.vaka, masa: a.masa + c.masaDk, gec: a.gec + c.gecIlkVaka, iptal: a.iptal + c.iptal }),
    { vaka: 0, masa: 0, gec: 0, iptal: 0 });
  const anesteziT = v.anestezi.reduce((a, x) => ({ vaka: a.vaka + x.vaka, sure: a.sure + x.sureDk }), { vaka: 0, sure: 0 });
  const enCok = Math.max(1, ...v.anestezi.map(a => a.sureDk));
  return (
    <>
      <div className="lb-bas">Cerrahlar <span className="ki-soluk">ciro sırasıyla · ilk vaka gecikmesi &gt;10 dk</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Cerrah</th><th>Branş</th><th className="sag">Vaka</th><th className="sag">Masa Süresi</th><th>Sapma</th>
          <th className="sag">Geç İlk Vaka</th><th className="sag">İptal</th><th className="sag">Ciro</th><th>Marj</th></tr></thead>
        <tbody>
          {v.cerrahlar.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde biten ameliyat yok.</td></tr>}
          {v.cerrahlar.map(c => (
            <tr key={c.id}><td><b>{c.ad}</b></td><td>{c.brans}</td><td className="sag">{c.vaka}</td><td className="sag">{saatMetni(c.masaDk)}</td>
              <td><Rz r={sapmaRozeti(c.sapma)} /></td><td className="sag">{tire(c.gecIlkVaka)}</td><td className={'sag' + (c.iptal ? ' kir' : '')}>{tire(c.iptal)}</td>
              <td className="sag">{p(c.ciro)}</td><td><Rz r={marjRozeti(c.marj)} /></td></tr>
          ))}
          {v.cerrahlar.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {o.cerrah} cerrah</td><td className="sag">{cerrahT.vaka}</td><td className="sag">{saatMetni(cerrahT.masa)}</td>
              <td>{yuzde(o.sapma)}</td><td className="sag">{cerrahT.gec}</td><td className="sag">{cerrahT.iptal}</td><td className="sag">{p(o.ciro)}</td>
              <td>{yuzde(o.marj)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="lb-bas">Anestezi <span className="ki-soluk">masa süresi = salona alma → salondan çıkış</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Anestezi Uzmanı</th><th className="sag">Vaka</th><th className="sag">Süre</th><th>İş Yükü</th></tr></thead>
        <tbody>
          {v.anestezi.length === 0 && <tr><td colSpan={4} className="bos">Anestezi uzmanı yazılmış biten ameliyat yok.</td></tr>}
          {v.anestezi.map(a => (
            <tr key={a.id}><td><b>{a.ad}</b></td><td className="sag">{a.vaka}</td><td className="sag">{saatMetni(a.sureDk)}</td>
              <td><Cubuk oran={100 * a.sureDk / enCok} /></td></tr>
          ))}
          {v.anestezi.length > 0 && (
            <tr className="top"><td>Toplam</td><td className="sag">{anesteziT.vaka}</td><td className="sag">{saatMetni(anesteziT.sure)}</td><td /></tr>
          )}
        </tbody>
      </table>
      {o.anestezisiz > 0 && <div className="ki-not">{o.anestezisiz} ameliyatta anestezi uzmanı yazılmamış (lokal / sedasyon ya da eksik kayıt).</div>}
    </>
  );
}

/** AMELİYATLAR - ilk 25, "tümü" ile hepsi; toplam satırı dönemin tamamı. */
export function AmeliyatTablosu({ v }: { v: AmeliyathaneIcmali }) {
  const [tumu, setTumu] = useState(false);
  const satirlar = tumu ? v.ameliyatlar : v.ameliyatlar.slice(0, 25);
  const plan = v.ameliyatlar.reduce((t, a) => t + (a.planDk ?? 0), 0);
  const gercek = v.ameliyatlar.reduce((t, a) => t + (a.gercekDk ?? 0), 0);
  const sarf = v.ameliyatlar.reduce((t, a) => t + a.sarf, 0);
  return (
    <>
      <div className="lb-bas">Ameliyatlar <span className="ki-soluk">
        {v.ameliyatlar.length > 25 && !tumu ? `ilk 25 gösteriliyor · toplam satırı dönemin tamamı (${v.ameliyatlar.length})` : `${v.ameliyatlar.length} ameliyat`}
      </span>{v.ameliyatlar.length > 25 && <a className="ki-lnk lb-k" onClick={() => setTumu(!tumu)}>{tumu ? 'ilk 25' : 'tümünü göster'}</a>}</div>
      <table className="hi-tablo">
        <thead><tr><th>Tarih</th><th>Protokol No</th><th>Salon</th><th>Ameliyat</th><th>Cerrah</th><th className="sag">Plan</th><th className="sag">Gerçek</th>
          <th className="sag">Sapma</th><th className="sag">Ciro</th><th className="sag">Sarf + İmplant</th><th>Marj</th></tr></thead>
        <tbody>
          {v.ameliyatlar.length === 0 && <tr><td colSpan={11} className="bos">Bu dönemde biten ameliyat yok.</td></tr>}
          {satirlar.map(a => (
            <tr key={a.id}><td>{a.tarih ? tarihKisa(a.tarih) : '—'}</td><td>{a.protokol || '—'}</td><td>{a.salon}</td>
              <td>{a.ameliyat}{a.acil && <span className="bo-rz kir lb-k">acil</span>}{a.faturasizSarf && <span className="bo-rz sari lb-k">faturasız sarf</span>}</td>
              <td>{a.cerrah}</td><td className="sag">{a.planDk != null ? `${a.planDk} dk` : '—'}</td><td className="sag">{a.gercekDk != null ? `${a.gercekDk} dk` : '—'}</td>
              <td className={'sag' + ((a.sapmaDk ?? 0) > 20 ? ' kir' : '')}>{dkFark(a.sapmaDk)}</td><td className="sag">{p(a.ciro)}</td>
              <td className="sag">{a.sarf ? p(a.sarf) : '—'}</td><td><Rz r={marjRozeti(a.marj)} /></td></tr>
          ))}
          {v.ameliyatlar.length > 0 && (
            <tr className="top"><td colSpan={5}>Toplam · {v.ameliyatlar.length} ameliyat (dönemin tamamı)</td>
              <td className="sag">{plan.toLocaleString('tr-TR')} dk</td><td className="sag">{gercek.toLocaleString('tr-TR')} dk</td><td className="sag">{yuzde(v.ozet.sapma)}</td>
              <td className="sag">{p(v.ozet.ciro)}</td><td className="sag">{p(sarf)}</td><td>{yuzde(v.ozet.marj)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Protokol No = başvuru belge numarası (başvurusuz ameliyatta ameliyat no). Hasta kimliği bu ekranda gösterilmez.</div>
    </>
  );
}

export function SarfTablosu({ v }: { v: AmeliyathaneIcmali }) {
  const o = v.ozet;
  return (
    <>
      <div className="lb-bas">Ameliyat Türü Bazında Sarf ve Marj <span className="ki-soluk">en düşük marj üstte · maliyet = ameliyat sarfı × stok maliyeti</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Ameliyat</th><th>Branş</th><th className="sag">Adet</th><th className="sag">Ciro</th><th className="sag">Sarf</th><th className="sag">İmplant</th>
          <th className="sag">Vaka Başı Maliyet</th><th className="sag">Brüt Kâr</th><th>Marj</th><th className="sag">Ort. Süre</th></tr></thead>
        <tbody>
          {v.turler.length === 0 && <tr><td colSpan={10} className="bos">Bu dönemde biten ameliyat yok.</td></tr>}
          {v.turler.map(t => (
            <tr key={t.ad}><td><b>{t.ad}</b></td><td>{t.brans}</td><td className="sag">{t.adet}</td><td className="sag">{p(t.ciro)}</td>
              <td className="sag">{t.sarf ? p(t.sarf) : '—'}</td><td className="sag">{t.implant ? p(t.implant) : '—'}</td><td className="sag">{p(t.vakaBasi)}</td>
              <td className={'sag' + (t.brutKar < 0 ? ' kir' : '')}>{p(t.brutKar)}</td><td><Rz r={marjRozeti(t.marj)} /></td>
              <td className="sag">{sureMetni(t.ortSureDk)}</td></tr>
          ))}
          {v.turler.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {v.turler.length} ameliyat türü</td><td className="sag">{o.ameliyat}</td><td className="sag">{p(o.ciro)}</td>
              <td className="sag">{p(o.sarf)}</td><td className="sag">{p(o.implant)}</td>
              <td className="sag">{p(o.ameliyat ? Math.round(100 * (o.sarf + o.implant) / o.ameliyat) / 100 : 0)}</td>
              <td className="sag">{p(o.brutKar)}</td><td>{yuzde(o.marj)}</td><td className="sag">{sureMetni(o.ortSureDk)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="lb-bas">Faturaya Girmeyen Sarf <span className="ki-soluk">faturaya işaretli ama başvuruda ücret satırı yok · kaçak riski</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Tarih</th><th>Protokol No</th><th>Ameliyat</th><th>Cerrah</th><th className="sag">Toplam Sarf</th><th className="sag">Faturasız Sarf</th><th>Durum</th></tr></thead>
        <tbody>
          {v.faturasizSarf.length === 0 && <tr><td colSpan={7} className="bos">Faturaya girmeyen sarf yok.</td></tr>}
          {v.faturasizSarf.map(f => (
            <tr key={f.id}><td>{f.tarih ? tarihKisa(f.tarih) : '—'}</td><td>{f.protokol || '—'}</td><td>{f.ameliyat}</td><td>{f.cerrah}</td>
              <td className="sag">{p(f.toplamSarf)}</td><td className="sag kir">{p(f.faturasiz)}</td>
              <td><span className="bo-rz kir">{f.kalem} kalem faturaya eklenmedi</span></td></tr>
          ))}
          {v.faturasizSarf.length > 0 && (
            <tr className="top"><td colSpan={5}>Toplam · {v.faturasizSarf.length} ameliyat</td><td className="sag">{p(o.faturasizTutar)}</td><td /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Ciro = ameliyatın işlem ve sarf satırlarının başvurudaki ücret tutarı (iptal belge hariç). Maliyet = sarf miktarı × stok maliyeti
        (giriş belgelerinden); implant ayrı sütun. Faturasız sarf tutarı maliyet üzerinden.</div>
    </>
  );
}

export function IptalTablosu({ v }: { v: AmeliyathaneIcmali }) {
  const o = v.ozet;
  return (
    <>
      <div className="lb-bas">İptal / Ertelenen Ameliyatlar <span className="ki-soluk">ertelenen = iptal + aynı talepten yeni plan</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Tarih</th><th>Protokol No</th><th>Salon</th><th>Ameliyat</th><th>Cerrah</th><th>Neden</th><th>Tür</th></tr></thead>
        <tbody>
          {v.iptaller.length === 0 && <tr><td colSpan={7} className="bos">Bu dönemde iptal edilen ameliyat yok.</td></tr>}
          {v.iptaller.map(i => (
            <tr key={i.id}><td>{i.tarih ? tarihKisa(i.tarih) : '—'}</td><td>{i.protokol || '—'}</td><td>{i.salon}</td><td>{i.ameliyat}</td><td>{i.cerrah}</td>
              <td>{i.neden}</td><td><span className={'bo-rz ' + (i.ertelendi ? 'sari' : 'kir')}>{i.ertelendi ? 'ertelendi' : 'iptal'}</span></td></tr>
          ))}
          {v.iptaller.length > 0 && (
            <tr className="top"><td colSpan={5}>Toplam · {o.iptal} vaka</td><td colSpan={2}>{o.ertelenen} ertelenen · {o.iptal - o.ertelenen} iptal</td></tr>
          )}
        </tbody>
      </table>
      <div className="lb-bas">Neden Dağılımı</div>
      <table className="hi-tablo">
        <thead><tr><th>Neden</th><th className="sag">Adet</th><th>Pay</th></tr></thead>
        <tbody>
          {v.iptalNedenleri.length === 0 && <tr><td colSpan={3} className="bos">—</td></tr>}
          {v.iptalNedenleri.map(n => (
            <tr key={n.neden}><td>{n.neden}</td><td className="sag">{n.adet}</td><td><Cubuk oran={n.pay} /> {yuzde(n.pay)}</td></tr>
          ))}
          {v.iptalNedenleri.length > 0 && (
            <tr className="top"><td>Toplam</td><td className="sag">{o.iptal}</td><td>iptal oranı {yuzde(o.iptalOrani)}</td></tr>
          )}
        </tbody>
      </table>
    </>
  );
}
