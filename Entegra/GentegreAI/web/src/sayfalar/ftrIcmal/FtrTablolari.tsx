import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { FtrIcmali } from '../../api/uclar/ftrIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { devamRozeti, dolulukRozeti, durumRozeti, ondalik, saat, vasFark, yanitRozeti, yuzde } from './ftrIcmalOrtak';

/** FTR icmalinin sekme tabloları. Rakamlar ve toplamlar sunucudan gelir. */

function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}
const tire = (n: number) => (n ? String(n) : '—');
const p = (n: number) => para.format(n);

/** FİZYOTERAPİSTLER - tık tek, Ctrl / Shift çoklu; ▸ bölge dağılımı; seçilenler kürleri ve A4'ü süzer. */
export function FizyoterapistTablosu({ v, secili, setSecili }: { v: FtrIcmali; secili: number[]; setSecili(x: number[]): void }) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.fizyoterapistler.map(f => f.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.fizyoterapistler.length > 0 && v.fizyoterapistler.every(f => secili.includes(f.id));
  const enCok = Math.max(1, ...v.fizyoterapistler.map(f => f.seans));
  const o = v.ozet;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.fizyoterapistler.map(f => f.id))} /></th>
          <th>Fizyoterapist</th><th className="sag">Kür</th><th className="sag">Aktif</th><th className="sag">Seans</th><th className="sag">Yarım</th>
          <th className="sag">Gelmedi</th><th>Devam</th><th className="sag">Süre</th><th className="sag">Ciro</th><th className="sag">Biten Kür</th>
          <th className="sag">VAS Düşüşü</th><th>İş Yükü</th></tr></thead>
        <tbody>
          {v.fizyoterapistler.length === 0 && <tr><td colSpan={13} className="bos">Dönemde seans yok.</td></tr>}
          {v.fizyoterapistler.map(f => {
            const sec = secili.includes(f.id); const d = devamRozeti(f.devam);
            return (
              <Fragment key={f.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(f.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(f.id, e)} /></td>
                  <td><a className="ki-lnk" onClick={e => ac(f.id, e)}>{acik.includes(f.id) ? '▾' : '▸'}</a> <b>{f.ad}</b></td>
                  <td className="sag">{f.kur}</td><td className="sag">{tire(f.aktif)}</td><td className="sag">{f.seans}</td>
                  <td className="sag">{tire(f.yarim)}</td><td className="sag">{tire(f.gelmedi)}</td>
                  <td><span className={'bo-rz ' + d.renk}>{d.ad}</span></td>
                  <td className="sag">{saat(f.sureSaat)}</td><td className="sag">{p(f.ciro)}</td><td className="sag">{tire(f.bitenKur)}</td>
                  <td className="sag">{vasFark(f.vasDusus)}</td>
                  <td><Cubuk oran={100 * f.seans / enCok} /></td>
                </tr>
                {acik.includes(f.id) && (
                  <tr className="lb-alt"><td /><td colSpan={12}>Bölge dağılımı ({f.kur} kür): {f.bolgeler.map(b => `${b.ad} ${b.adet}`).join(' · ') || '—'}</td></tr>
                )}
              </Fragment>
            );
          })}
          {v.fizyoterapistler.length > 0 && (
            <tr className="top"><td /><td>Toplam · {v.fizyoterapistler.length} fizyoterapist</td><td className="sag">{o.kur}</td><td className="sag">{o.suren}</td>
              <td className="sag">{o.seans}</td><td className="sag">{o.yarim}</td><td className="sag">{o.gelmedi}</td><td>{yuzde(o.devam)}</td>
              <td className="sag">{saat(o.sureSaat)}</td><td className="sag">{p(o.ciro)}</td><td className="sag">{o.biten}</td>
              <td className="sag">{vasFark(o.vasDusus)}</td><td /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Seans = Yapıldı + Yarım; devam = yapılan ÷ (yapılan + gelmedi), merkez kaynaklı iptal devama girmez.
        Fizyoterapist seanstan, girilmemişse programdan. VAS düşüşü dönemde biten kürlerde (ilk seans öncesi → son seans sonrası).</div>
    </>
  );
}

/** KÜRLER - dönemde seansı olan programlar; hasta kimliği yok (Program / Protokol No). */
export function KurTablosu({ v, fztSecili }: { v: FtrIcmali; fztSecili: string[] }) {
  const liste = fztSecili.length ? v.kurler.filter(k => fztSecili.includes(k.fizyoterapist)) : v.kurler;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Program No</th><th>Protokol No</th><th>Bölge / Tanı</th><th>Ödeyen</th><th>Fizyoterapist</th>
          <th className="sag">Seans</th><th className="sag">Dönem</th><th className="sag">Gelmedi</th><th className="sag">Kalan Hak</th>
          <th>Durum</th><th>Yanıt</th><th className="sag">Ciro</th></tr></thead>
        <tbody>
          {liste.length === 0 && <tr><td colSpan={12} className="bos">Dönemde kür yok.</td></tr>}
          {liste.map(k => {
            const d = durumRozeti(k.durumKod, k.durum); const y = yanitRozeti(k.yanit);
            return (
              <tr key={k.id}>
                <td><b>{k.programNo}</b></td><td>{k.protokolNo || '—'}</td>
                <td>{k.bolge} <span className="ki-soluk">{k.icd || k.tani}</span></td>
                <td>{k.odeyen}{k.kurum && k.odeyenKod !== 'ozel' && <div className="ki-soluk">{k.kurum}</div>}</td>
                <td>{k.fizyoterapist}</td>
                <td className="sag">{k.yapilanToplam} / {k.plan}</td><td className="sag">{k.donem}</td><td className="sag">{tire(k.gelmedi)}</td>
                <td className="sag">{k.kalanHak ?? '—'}</td>
                <td><span className={'bo-rz ' + d.renk}>{d.ad}</span>{k.araGecikti && <span className="bo-rz kir lb-k">ara değ. gecikti</span>}</td>
                <td>{y && <span className={'bo-rz ' + y.renk}>{y.ad}</span>}</td>
                <td className="sag">{p(k.ciro)}</td>
              </tr>
            );
          })}
          {liste.length > 0 && !fztSecili.length && (
            <tr className="top"><td colSpan={5}>Toplam · {v.ozet.kur} kür</td><td /><td className="sag">{v.ozet.seans}</td><td className="sag">{v.ozet.gelmedi}</td>
              <td colSpan={3} /><td className="sag">{p(v.ozet.ciro)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Seans = toplam yapılan / plan · Dönem = dönemde yapılan · Kalan hak yalnız SGK (Medula) kürlerinde
        (rapor seans hakkı). Ciro seansın başvuru satırından{v.ozet.ciroluSeans < v.ozet.seans
          ? ` - ${v.ozet.seans - v.ozet.ciroluSeans} seans başvuru satırına bağlı değil, cirosu 0 sayıldı` : ''}.</div>
    </>
  );
}

export function OdeyenTablosu({ v }: { v: FtrIcmali }) {
  const t = v.odeyenToplam;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Ödeyen</th><th className="sag">Kür</th><th className="sag">Seans</th><th className="sag">Seans Ücreti</th><th className="sag">Ciro</th>
          <th className="sag">Kurum Payı</th><th className="sag">Hasta Payı</th><th className="sag">Rapor Hakkı</th><th>Ciro Payı</th></tr></thead>
        <tbody>
          {v.odeyenler.length === 0 && <tr><td colSpan={9} className="bos">Dönemde kür yok.</td></tr>}
          {v.odeyenler.map(o => (
            <tr key={o.kod}>
              <td><b>{o.ad}</b></td><td className="sag">{o.kur}</td><td className="sag">{o.seans}</td><td className="sag">{p(o.seansUcreti)}</td>
              <td className="sag">{p(o.ciro)}</td><td className="sag">{p(o.kurum)}</td><td className="sag">{p(o.hasta)}</td>
              <td className="sag">{o.raporHak != null ? `${o.raporKullanilan} / ${o.raporHak}` : '—'}</td>
              <td>{o.ciroPayi != null && <Cubuk oran={o.ciroPayi} />} {yuzde(o.ciroPayi)}</td>
            </tr>
          ))}
          {v.odeyenler.length > 0 && (
            <tr className="top"><td>Toplam</td><td className="sag">{t.kur}</td><td className="sag">{t.seans}</td><td /><td className="sag">{p(t.ciro)}</td>
              <td className="sag">{p(t.kurum)}</td><td className="sag">{p(t.hasta)}</td><td colSpan={2} /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Ödeyen = programın ödeyen kurumunun türü (SGK / ÖSS / kurumu öder); kurum yoksa Özel. Kurum payı satır dağılımından.
        Medula seansı rapor hakkından düşer (kullanılan / hak).</div>
    </>
  );
}

export function KlinikTablosu({ v }: { v: FtrIcmali }) {
  const a = v.araDegerlendirme;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Bölge</th><th>Ölçek</th><th className="sag">Kür</th><th className="sag">VAS</th><th className="sag">Ölçek Skoru</th>
          <th className="sag">İyileşme</th><th className="sag">İyi</th><th className="sag">Kısmi</th><th className="sag">Yanıtsız</th><th>İyi Yanıt Oranı</th></tr></thead>
        <tbody>
          {v.klinik.length === 0 && <tr><td colSpan={10} className="bos">Dönemde tamamlanan kür yok.</td></tr>}
          {v.klinik.map(k => (
            <tr key={k.bolge}>
              <td><b>{k.bolge}</b></td><td>{k.olcek || <span className="ki-soluk">kür başı / sonu ölçeği yok</span>}</td><td className="sag">{k.kur}</td>
              <td className="sag">{k.vasBas != null ? `${ondalik(k.vasBas)} → ${ondalik(k.vasSon)}` : '—'}</td>
              <td className="sag">{k.olcekBas != null ? `${ondalik(k.olcekBas)} → ${ondalik(k.olcekSon)}` : '—'}</td>
              <td className="sag">{yuzde(k.iyilesme)}</td><td className="sag">{tire(k.iyi)}</td><td className="sag">{tire(k.kismi)}</td>
              <td className="sag">{tire(k.yanitsiz)}</td><td>{k.iyiOran != null && <Cubuk oran={k.iyiOran} />} {yuzde(k.iyiOran)}</td>
            </tr>
          ))}
          {v.klinik.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {v.klinik.length} bölge</td><td className="sag">{v.ozet.biten}</td>
              <td className="sag">VAS {vasFark(v.ozet.vasDusus)}</td><td colSpan={5} /><td>{yuzde(v.ozet.iyiYanit)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Yalnız dönemde Tamamlanan kürler: kür başı (ölçek aşama 1) → kür sonu (aşama 3) ortalaması, bölgenin en çok
        kullanılan ölçeği; iyileşme = değişim ÷ başlangıç (Constant, Barthel, Berg, KOOS, Lysholm, SF-12'de yükselme iyidir). Yanıt programın kür sonu yanıtıdır.</div>
      <div className="lb-bas">Ara Değerlendirme</div>
      <table className="hi-tablo">
        <thead><tr><th>Durum</th><th className="sag">Kür</th><th>Not</th></tr></thead>
        <tbody>
          <tr><td>Yapıldı</td><td className="sag">{a.yapildi}</td><td className="ki-soluk">ara (aşama 2) ölçek kaydı var</td></tr>
          <tr><td className={a.gecikti ? 'kir' : ''}>Gecikti</td><td className="sag">{a.gecikti}</td><td className="ki-soluk">ara değerlendirme seansı geçti, ara ölçek girilmedi</td></tr>
          <tr className="top"><td>Gereken</td><td className="sag">{a.gereken}</td><td /></tr>
        </tbody>
      </table>
    </>
  );
}

export function KabinTablosu({ v }: { v: FtrIcmali }) {
  return (
    <div className="lb-kalite">
      <div>
        <div className="lb-bas">Uygulama / Cihaz Kullanımı</div>
        <table className="hi-tablo">
          <thead><tr><th>Uygulama</th><th>Cihaz</th><th>Yer</th><th className="sag">Uygulama</th><th className="sag">Süre</th><th className="sag">Toplam</th><th>Pay</th></tr></thead>
          <tbody>
            {v.uygulamalar.length === 0 && <tr><td colSpan={7} className="bos">Dönemde yapıldı işaretli uygulama yok.</td></tr>}
            {v.uygulamalar.map(u => (
              <tr key={u.ad + '|' + u.cihaz}><td><b>{u.ad}</b></td><td>{u.cihaz || '—'}</td><td>{u.yer || '—'}</td><td className="sag">{u.adet}</td>
                <td className="sag">{u.ortDk} dk</td><td className="sag">{saat(u.sureSaat)}</td><td>{yuzde(u.pay)}</td></tr>
            ))}
            {v.uygulamalar.length > 0 && (
              <tr className="top"><td colSpan={3}>Toplam · {v.uygulamalar.length} uygulama</td><td className="sag">{v.uygulamaToplam.adet}</td><td />
                <td className="sag">{saat(v.uygulamaToplam.sureSaat)}</td><td /></tr>
            )}
          </tbody>
        </table>
      </div>
      <div>
        <div className="lb-bas">Kabin / Salon Doluluğu</div>
        <table className="hi-tablo">
          <thead><tr><th>Kabin</th><th>Tür</th><th className="sag">Seans</th><th className="sag">Kullanım</th><th className="sag">Kapasite</th><th>Doluluk</th></tr></thead>
          <tbody>
            {v.kabinler.length === 0 && <tr><td colSpan={6} className="bos">Tanımlı kabin yok.</td></tr>}
            {v.kabinler.map(k => {
              const d = dolulukRozeti(k.doluluk);
              return (
                <tr key={k.id}><td><b>{k.ad}</b>{k.cihazlar && <div className="ki-soluk">{k.cihazlar}</div>}</td><td>{k.tur}</td>
                  <td className="sag">{tire(k.seans)}</td><td className="sag">{saat(k.kullanimSaat)}</td><td className="sag">{saat(k.kapasiteSaat)}</td>
                  <td>{k.doluluk != null && <Cubuk oran={k.doluluk} />} <span className={'bo-rz ' + d.renk}>{d.ad}</span></td></tr>
              );
            })}
            {v.kabinler.length > 0 && (
              <tr className="top"><td colSpan={2}>Toplam · {v.kabinler.length}</td><td /><td className="sag">{saat(v.kabinToplam.kullanimSaat)}</td>
                <td className="sag">{saat(v.kabinToplam.kapasiteSaat)}</td><td>{yuzde(v.kabinToplam.doluluk)}</td></tr>
            )}
          </tbody>
        </table>
        <div className="ki-not">Kullanım = seans süresi (seansın kabini, yoksa programın); kapasite = {v.ozet.isGunu} iş günü (Pzt–Cmt) × 9 saat × kabin kapasitesi.
          {v.ozet.kabinsizSeans ? ` ${v.ozet.kabinsizSeans} seansın kabini yok, doluluğa girmedi.` : ''}</div>
      </div>
    </div>
  );
}
