import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { DisIcmali } from '../../api/uclar/disIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { dolulukRozeti, gunRozeti, marjRozeti, yuzde, yuzdeTam } from './disIcmalOrtak';

/** Diş icmalinin sekme tabloları. Rakamlar ve toplamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}

/** Tık tek, Ctrl / Shift çoklu seçim. */
function useSecim(idler: number[], secili: number[], setSecili: (x: number[]) => void) {
  const son = useRef<number | null>(null);
  return (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, idler, son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
}

/** HEKİMLER - ▸ işlem dağılımı; seçilenler A4'ü süzer. */
export function HekimTablosu({ v, secili, setSecili }: { v: DisIcmali; secili: number[]; setSecili(x: number[]): void }) {
  const tikla = useSecim(v.hekimler.map(h => h.id), secili, setSecili);
  const [acik, setAcik] = useState<number[]>([]);
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.hekimler.length > 0 && v.hekimler.every(h => secili.includes(h.id));
  const o = v.ozet;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.hekimler.map(h => h.id))} /></th>
          <th>Hekim</th><th>Uzmanlık</th><th className="sag">Seans</th><th className="sag">Hasta</th><th className="sag">İşlem</th>
          <th className="sag">Ciro</th><th className="sag">Sarf</th><th className="sag">Lab</th><th className="sag">Brüt Kâr</th><th>Marj</th>
          <th className="sag">Plan Kabul</th><th className="sag">Ort. Seans</th><th>Ciro Payı</th></tr></thead>
        <tbody>
          {v.hekimler.length === 0 && <tr><td colSpan={14} className="bos">Dönemde biten seans yok.</td></tr>}
          {v.hekimler.map(h => {
            const sec = secili.includes(h.id); const m = marjRozeti(h.marj);
            return (
              <Fragment key={h.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(h.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(h.id, e)} /></td>
                  <td><a className="ki-lnk" onClick={e => ac(h.id, e)}>{acik.includes(h.id) ? '▾' : '▸'}</a> <b>{h.ad}</b></td>
                  <td>{h.brans || '—'}</td><td className="sag">{h.seans}</td><td className="sag">{h.hasta}</td><td className="sag">{h.islem}</td>
                  <td className="sag">{p(h.ciro)}</td><td className="sag">{tire(h.sarf)}</td><td className="sag">{tire(h.lab)}</td>
                  <td className="sag"><b>{p(h.kar)}</b></td><td><span className={'bo-rz ' + m.renk}>{m.ad}</span></td>
                  <td className="sag">{yuzdeTam(h.planKabul)}</td><td className="sag">{h.ortSeansDk != null ? `${h.ortSeansDk} dk` : '—'}</td>
                  <td>{h.ciroPayi != null && <Cubuk oran={h.ciroPayi} />} {yuzde(h.ciroPayi)}</td>
                </tr>
                {acik.includes(h.id) && h.islemler.map(i => (
                  <tr key={i.ad} className="lb-alt"><td /><td colSpan={4}>{i.ad} · <span className="ki-soluk">{i.grup}</span></td>
                    <td className="sag">{i.adet}</td><td className="sag">{p(i.ciro)}</td><td className="sag">{tire(i.sarf)}</td><td className="sag">{tire(i.lab)}</td>
                    <td className="sag">{p(i.kar)}</td><td colSpan={4} /></tr>
                ))}
              </Fragment>
            );
          })}
          {v.hekimler.length > 0 && (
            <tr className="top"><td /><td colSpan={2}>Toplam · {v.hekimler.length} hekim</td><td className="sag">{o.seans}</td>
              <td className="sag">{o.hasta}{o.hekimHastaToplami !== o.hasta ? '*' : ''}</td><td className="sag">{o.islem}</td>
              <td className="sag">{p(o.ciro)}</td><td className="sag">{p(o.sarf)}</td><td className="sag">{p(o.lab)}</td><td className="sag">{p(o.kar)}</td>
              <td>{yuzde(o.marj)}</td><td className="sag">{yuzdeTam(o.kabulYuzde)}</td><td className="sag">{o.ortSeansDk != null ? `${o.ortSeansDk} dk` : '—'}</td><td /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">
        {o.hekimHastaToplami !== o.hasta && <>* tekil hasta: birden çok hekime giden hasta bir kez sayılır (hekim satırları toplamı {o.hekimHastaToplami}). </>}
        Seans = durumu "Bitti" olan seans; ciro = işlemin başvuru satırı tutarı{o.faturasiz ? ` - ${o.faturasiz} işlemin başvuru satırı yok, ciroya girmedi` : ''}.
        Sarf seansın işlemlerine ciro oranında dağıtılır; lab = dönemde teslim gelen iş emri bedeli.
      </div>
    </>
  );
}

/** TEDAVİ PLANI HUNİSİ + hekim kırılımı. */
export function PlanTablosu({ v }: { v: DisIcmali }) {
  const o = v.ozet;
  return (
    <>
      <div className="ds-huni">
        <span className="ds-adim"><b>{o.planSunulan}</b> sunulan · {p(o.planSunulanTutar)} ₺</span>›
        <span className="ds-adim"><b>{o.planKabul}</b> kabul · {p(o.planKabulTutar)} ₺ · {yuzdeTam(o.kabulYuzde)}</span>›
        <span className="ds-adim"><b>{o.planSuruyor}</b> sürüyor</span>›
        <span className="ds-adim iyi"><b>{o.planTamam}</b> tamamlandı · {yuzdeTam(o.tamamYuzde)}</span>
        <span className="ds-adim soluk"><b>{o.planBekliyor} / {o.planIptal}</b> yanıt bekliyor / iptal + süresi doldu</span>
      </div>
      <table className="hi-tablo">
        <thead><tr><th>Hekim</th><th className="sag">Sunulan</th><th className="sag">Tutar</th><th className="sag">Bekliyor</th><th className="sag">Kabul</th>
          <th className="sag">Kabul Tutarı</th><th className="sag">Kabul %</th><th className="sag">Sürüyor</th><th className="sag">Tamam</th>
          <th className="sag">Tamamlanma</th><th className="sag">İptal / Süre</th><th className="sag">Yapılan Tutar</th><th>İlerleme</th></tr></thead>
        <tbody>
          {v.planHekim.length === 0 && <tr><td colSpan={13} className="bos">Dönemde sunulan tedavi planı yok.</td></tr>}
          {v.planHekim.map(h => (
            <tr key={h.hekim}><td><b>{h.hekim}</b></td><td className="sag">{h.sunulan}</td><td className="sag">{p(h.tutar)}</td>
              <td className="sag">{h.bekliyor || '—'}</td><td className="sag">{h.kabul}</td><td className="sag">{p(h.kabulTutar)}</td>
              <td className="sag">{yuzdeTam(h.kabulYuzde)}</td><td className="sag">{h.suruyor || '—'}</td><td className="sag">{h.tamam || '—'}</td>
              <td className="sag">{yuzdeTam(h.tamamYuzde)}</td><td className="sag">{h.iptal || '—'}</td><td className="sag">{tire(h.yapilanTutar)}</td>
              <td>{h.kabulTutar > 0 && <Cubuk oran={100 * h.yapilanTutar / h.kabulTutar} />}</td></tr>
          ))}
          {v.planHekim.length > 0 && (
            <tr className="top"><td>Toplam</td><td className="sag">{o.planSunulan}</td><td className="sag">{p(o.planSunulanTutar)}</td>
              <td className="sag">{o.planBekliyor}</td><td className="sag">{o.planKabul}</td><td className="sag">{p(o.planKabulTutar)}</td>
              <td className="sag">{yuzdeTam(o.kabulYuzde)}</td><td className="sag">{o.planSuruyor}</td><td className="sag">{o.planTamam}</td>
              <td className="sag">{yuzdeTam(o.tamamYuzde)}</td><td className="sag">{o.planIptal}</td><td className="sag">{p(o.planYapilanTutar)}</td><td /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Dönemde açılan planlar (taslak hariç). Kabul = Onaylı + Sürüyor + Tamamlandı; tamamlanma = tamamlandı ÷ kabul.
        Yapılan tutar = kabul edilen planlarda "Yapıldı" satırların neti.</div>
    </>
  );
}

/** YARIM KALAN PLANLAR - onaylı / süren plan, son seanstan eşik gün geçti. */
export function YarimKalanTablosu({ v, secili, setSecili }: { v: DisIcmali; secili: number[]; setSecili(x: number[]): void }) {
  const tikla = useSecim(v.yarimKalan.map(y => y.id), secili, setSecili);
  const hepsi = v.yarimKalan.length > 0 && v.yarimKalan.every(y => secili.includes(y.id));
  const o = v.ozet;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.yarimKalan.map(y => y.id))} /></th>
          <th>Plan No</th><th>Son Protokol No</th><th>Hasta</th><th>Hekim</th><th className="sag">Plan Tutarı</th><th className="sag">Yapılan</th>
          <th className="sag">Kalan</th><th className="sag">Tahsil Edilen</th><th>Son Seans</th><th>Neden</th></tr></thead>
        <tbody>
          {v.yarimKalan.length === 0 && <tr><td colSpan={11} className="bos">Son seanstan {o.yarimGun}+ gün geçmiş onaylı / süren plan yok.</td></tr>}
          {v.yarimKalan.map(y => {
            const sec = secili.includes(y.id); const g = gunRozeti(y.gun);
            return (
              <tr key={y.id} className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(y.id, e)}>
                <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(y.id, e)} /></td>
                <td><b>{y.planNo}</b></td><td>{y.protokolNo || '—'}</td><td>{y.hasta}</td><td>{y.hekim}</td>
                <td className="sag">{p(y.tutar)}</td><td className="sag">{tire(y.yapilan)}</td><td className="sag"><b>{p(y.kalan)}</b></td>
                <td className="sag">{tire(y.tahsil)}</td>
                <td><span className={'bo-rz ' + g.renk}>{g.ad}</span> {y.seansYok ? <span className="ki-soluk">seans yok (onaydan)</span>
                  : y.sonSeans && <span className="ki-soluk">{tarihKisa(y.sonSeans)}</span>}</td>
                <td>{y.neden}</td>
              </tr>
            );
          })}
          {v.yarimKalan.length > 0 && (
            <tr className="top"><td /><td colSpan={4}>Toplam · {o.yarimAdet} plan</td><td className="sag">{p(o.yarimTutar)}</td>
              <td className="sag">{p(o.yarimYapilan)}</td><td className="sag">{p(o.yarimKalan)}</td><td className="sag">{p(o.yarimTahsil)}</td>
              <td colSpan={2}>tahsil − yapılan = <span className={o.yarimFark < 0 ? 'kir' : ''}>{p(o.yarimFark)} ₺</span></td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Kalan = plan neti − yapılan satırlar; tahsil = ödeme planı taksitlerinin ödenen kısmı. Neden planda tutulmuyor:
        açık lab işi › gecikmiş taksit › ertelenen satır sırasıyla çıkarılır, kalanı "Randevu almadı". Hastanın yalnız adı ve soyadının baş harfi gösterilir.</div>
    </>
  );
}

/** İŞLEM TÜRLERİ. */
export function IslemTablosu({ v }: { v: DisIcmali }) {
  const o = v.ozet;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>İşlem</th><th>Grup</th><th className="sag">Adet</th><th className="sag">Ciro</th><th className="sag">Ort. Fiyat</th>
          <th className="sag">Sarf</th><th className="sag">Lab</th><th>Marj</th><th className="sag">Hekim</th><th>Ciro Payı</th></tr></thead>
        <tbody>
          {v.islemTurleri.length === 0 && <tr><td colSpan={10} className="bos">Dönemde tamamlanan işlem yok.</td></tr>}
          {v.islemTurleri.map(t => {
            const m = marjRozeti(t.marj);
            return (
              <tr key={t.hizmetId}><td><b>{t.ad}</b>{t.faturasiz > 0 && <span className="bo-rz sari lb-k" title="Başvuru satırı yok">{t.faturasiz} faturasız</span>}</td>
                <td>{t.grup}</td><td className="sag">{t.adet}</td><td className="sag">{p(t.ciro)}</td><td className="sag">{tire(t.ortFiyat)}</td>
                <td className="sag">{tire(t.sarf)}</td><td className="sag">{tire(t.lab)}</td><td><span className={'bo-rz ' + m.renk}>{m.ad}</span></td>
                <td className="sag">{t.hekim || '—'}</td><td>{t.ciroPayi != null && <Cubuk oran={t.ciroPayi} />} {yuzde(t.ciroPayi)}</td></tr>
            );
          })}
          {v.islemTurleri.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {v.islemTurleri.length} işlem türü</td><td className="sag">{o.islem}</td>
              <td className="sag">{p(o.ciro)}</td><td /><td className="sag">{p(o.islemSarf)}</td><td className="sag">{p(o.islemLab)}</td>
              <td>{yuzde(o.marj)}</td><td colSpan={2} /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Seansta tamamlanan işlemler · sarf = seans sarf düşümü (işlemlere ciro oranında) · lab = plan satırına bağlı iş emrinin bedeli.</div>
    </>
  );
}

/** LABORATUVARLAR + ÜNİTELER. */
export function LabUniteTablosu({ v }: { v: DisIcmali }) {
  const o = v.ozet;
  return (
    <>
      <div className="lb-bas">Protez / Ortodonti Laboratuvarları</div>
      <table className="hi-tablo">
        <thead><tr><th>Laboratuvar</th><th>Ana İş</th><th className="sag">İş Emri</th><th className="sag">Lab Bedeli</th><th className="sag">Hastaya Yansıyan</th>
          <th className="sag">Fark</th><th className="sag">Söz. Süre</th><th className="sag">Ort. Süre</th><th>Teslim</th></tr></thead>
        <tbody>
          {v.laboratuvarlar.length === 0 && <tr><td colSpan={9} className="bos">Dönemde laboratuvar iş emri yok.</td></tr>}
          {v.laboratuvarlar.map(l => (
            <tr key={l.id}><td><b>{l.ad}</b></td><td>{l.anaIs || '—'}</td>
              <td className="sag">{l.isAdet}{l.acik > 0 && <span className="ki-soluk"> +{l.acik} açık</span>}</td>
              <td className="sag">{tire(l.labBedeli)}</td><td className="sag">{tire(l.hastaya)}</td><td className="sag">{tire(l.fark)}</td>
              <td className="sag">{l.slaGun ? `${l.slaGun} gün` : '—'}</td>
              <td className="sag">{l.ortSureGun != null ? `${String(l.ortSureGun).replace('.', ',')} gün` : '—'}</td>
              <td>{l.gec ? <span className="bo-rz kir">{l.gec} geç</span> : l.isAdet ? <span className="bo-rz ok">zamanında</span> : '—'}</td></tr>
          ))}
          {v.laboratuvarlar.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {v.laboratuvarlar.length} lab</td><td className="sag">{o.labIs}</td><td className="sag">{p(o.lab)}</td>
              <td className="sag">{p(o.labHastaya)}</td><td className="sag">{p(o.labFark)}</td><td colSpan={2} /><td>{o.labGec ? `${o.labGec} geç` : ''}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">İş emri = dönemde teslim gelen iş (açık = henüz gelmeyen) · geç = beklenen tarihten sonra gelen ya da beklenen tarihi geçip gelmeyen.</div>

      <div className="lb-bas">Ünite Doluluğu</div>
      <table className="hi-tablo">
        <thead><tr><th>Ünite</th><th>Çalışan Hekim</th><th className="sag">Seans</th><th className="sag">Kullanım</th><th className="sag">Kapasite</th><th>Doluluk</th></tr></thead>
        <tbody>
          {v.uniteler.length === 0 && <tr><td colSpan={6} className="bos">Tanımlı ünite yok.</td></tr>}
          {v.uniteler.map(u => {
            const d = dolulukRozeti(u.doluluk);
            return (
              <tr key={u.id}><td><b>{u.ad}</b></td><td>{u.hekimler.join(', ') || '—'}</td><td className="sag">{u.seans}</td>
                <td className="sag">{String(u.kullanimSaat).replace('.', ',')} sa</td><td className="sag">{u.kapasiteSaat != null ? `${u.kapasiteSaat} sa` : '—'}</td>
                <td>{u.doluluk != null && <Cubuk oran={u.doluluk} />} <span className={'bo-rz ' + d.renk}>{d.ad}</span></td></tr>
            );
          })}
          {v.uniteler.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {o.uniteSayisi} ünite</td><td className="sag">{o.seans}</td>
              <td className="sag">{String(o.uniteKullanim).replace('.', ',')} sa</td><td className="sag">{o.uniteKapasite} sa</td><td>{yuzde(o.uniteDoluluk)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Kapasite = {o.isGunu} iş günü (Pzt-Cmt) × {o.uniteSaat} saat (ünitede çalışma saati alanı yok, kurum mesaisi 09:00-18:00)
        · kullanım = seans süresi toplamı.</div>
    </>
  );
}
