import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { RandevuDeger, RandevuIcmali } from '../../api/uclar/randevuIcmal';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { dakika, dolulukRozeti, hucreYogunluk, noShowRozeti, sayi, yuzde } from './randevuIcmalOrtak';

/** Randevu / poliklinik icmalinin sekme tabloları. Rakamlar (toplamlar dahil) sunucudan gelir. */

function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}
const tire = (n: number) => (n ? sayi(n) : '—');
const tarihSaat = (t: string) => `${tarihKisa(t)} ${t.slice(11, 16)}`;

/** Poliklinik / hekim satırının ortak hücreleri (Slot … İlk / Kontrol). */
function DegerHucreleri({ d, kalin }: { d: RandevuDeger; kalin?: boolean }) {
  const dl = dolulukRozeti(d.doluluk); const ns = noShowRozeti(d.noShow);
  return (
    <>
      <td className="sag">{tire(d.slot)}</td><td className="sag">{kalin ? <b>{sayi(d.verilen)}</b> : sayi(d.verilen)}</td>
      <td>{d.doluluk != null && <Cubuk oran={d.doluluk} />} <span className={'bo-rz ' + dl.renk}>{dl.ad}</span></td>
      <td className="sag">{sayi(d.gelen)}</td><td className="sag">{tire(d.gelmeyen)}</td>
      <td><span className={'bo-rz ' + ns.renk}>{ns.ad}</span></td>
      <td className="sag">{tire(d.iptal)}</td><td className="sag">{tire(d.randevusuz)}</td>
      <td className="sag">{dakika(d.ortBeklemeDk)}</td><td className="sag">{d.ilk} / {d.kontrol}</td>
    </>
  );
}

/** POLİKLİNİKLER - satır ▸ hekim kırılımı; onay kutusu: tık tek, Ctrl / Shift çoklu; seçilenler A4'ü süzer. */
export function PoliklinikTablosu({ v, secili, setSecili }: { v: RandevuIcmali; secili: number[]; setSecili(x: number[]): void }) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.poliklinikler.map(p => p.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.poliklinikler.length > 0 && v.poliklinikler.every(p => secili.includes(p.id));
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.poliklinikler.map(p => p.id))} /></th>
          <th>Poliklinik</th><th className="sag">Hekim</th><th className="sag">Slot</th><th className="sag">Verilen</th><th>Doluluk</th>
          <th className="sag">Gelen</th><th className="sag">Gelmeyen</th><th>No-show</th><th className="sag">İptal</th><th className="sag">Randevusuz</th>
          <th className="sag">Ort. Bekleme</th><th className="sag">İlk / Kontrol</th></tr></thead>
        <tbody>
          {v.poliklinikler.length === 0 && <tr><td colSpan={13} className="bos">Dönemde randevu ya da çalışma planı yok.</td></tr>}
          {v.poliklinikler.map(p => {
            const sec = secili.includes(p.id);
            return (
              <Fragment key={p.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(p.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(p.id, e)} /></td>
                  <td><a className="ki-lnk" onClick={e => ac(p.id, e)}>{acik.includes(p.id) ? '▾' : '▸'}</a> <b>{p.ad}</b></td>
                  <td className="sag">{p.hekimSayisi}</td>
                  <DegerHucreleri d={p.deger} kalin />
                </tr>
                {acik.includes(p.id) && p.hekimler.map(h => (
                  <tr key={h.hekim} className="lb-alt">
                    <td /><td>{h.hekimAd} <span className="ki-soluk">{h.gun} gün{h.izin ? ` · ${h.izin} izin` : ''}</span></td><td />
                    <DegerHucreleri d={h.deger} />
                  </tr>
                ))}
              </Fragment>
            );
          })}
          {v.poliklinikler.length > 0 && (
            <tr className="top"><td /><td>Toplam · {v.poliklinikler.length} poliklinik</td><td className="sag">{v.ozet.hekim}</td>
              <DegerHucreleri d={v.toplam} /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Verilen = iptal edilmemiş randevu (planlandı / geldi / gelmedi). No-show = gelmedi / verilen; iptal doluluğa girmez.
        Slot = çalışma planı blokları ÷ slot süresi; izin / kongre / kapalı gün slot üretmez. Kanal ve tip süzgeci slota ve randevusuz muayeneye uygulanmaz.
        {v.toplam.bekleyen ? ` ${v.toplam.bekleyen} randevu hâlâ "planlandı" durumunda (sonuçlanmamış).` : ''}</div>
    </>
  );
}

/** HEKİMLER - doluluğa göre sıralı (sunucu). */
export function HekimTablosu({ v }: { v: RandevuIcmali }) {
  const t = v.toplam;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Hekim</th><th>Poliklinik</th><th className="sag">Gün</th><th className="sag">Slot</th><th className="sag">Dolu</th>
          <th className="sag">Boş</th><th>Doluluk</th><th>No-show</th><th className="sag">Muayene</th><th className="sag">Gün Başı</th>
          <th className="sag">Ort. Bekleme</th><th className="sag">30+ dk</th></tr></thead>
        <tbody>
          {v.hekimler.length === 0 && <tr><td colSpan={12} className="bos">Dönemde hekim randevusu ya da planı yok.</td></tr>}
          {v.hekimler.map(h => {
            const d = h.deger; const dl = dolulukRozeti(d.doluluk); const ns = noShowRozeti(d.noShow);
            return (
              <tr key={`${h.bolum}-${h.hekim}`}>
                <td><b>{h.hekimAd}</b>{h.izin > 0 && <span className="ki-soluk"> · {h.izin} izin</span>}</td><td>{h.bolumAd}</td>
                <td className="sag">{h.gun || '—'}</td><td className="sag">{tire(d.slot)}</td><td className="sag">{sayi(d.verilen)}</td>
                <td className="sag">{tire(d.bos)}</td><td><span className={'bo-rz ' + dl.renk}>{dl.ad}</span></td>
                <td><span className={'bo-rz ' + ns.renk}>{ns.ad}</span></td><td className="sag">{tire(d.muayene)}</td>
                <td className="sag">{h.gunBasi != null ? String(h.gunBasi).replace('.', ',') : '—'}</td>
                <td className="sag">{dakika(d.ortBeklemeDk)}</td><td className={'sag' + (d.uzunBekleme ? ' kir' : '')}>{tire(d.uzunBekleme)}</td>
              </tr>
            );
          })}
          {v.hekimler.length > 0 && (
            <tr className="top"><td colSpan={2}>{v.hekimler.length} hekim</td><td className="sag">{v.ozet.calismaGunu}</td><td className="sag">{sayi(t.slot)}</td>
              <td className="sag">{sayi(t.verilen)}</td><td className="sag">{sayi(t.bos)}</td><td>{yuzde(t.doluluk)}</td><td>{yuzde(t.noShow)}</td>
              <td className="sag">{sayi(t.muayene)}</td><td /><td className="sag">{dakika(t.ortBeklemeDk)}</td><td className="sag">{sayi(t.uzunBekleme)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Slot = çalışma planı (hekim × şube × bölüm şablonu ve istisnaları) × çalışılan gün; izin günü slot üretmez.
        Muayene = dönemde hekimin açtığı muayene (randevulu + randevusuz). Toplam satırındaki gün, planda çalışılan takvim günü sayısıdır.</div>
    </>
  );
}

/** KANALLAR (randevu.kaynak) - öne alma = randevunun verildiği gün → randevu günü. */
export function KanalTablosu({ v }: { v: RandevuIcmali }) {
  const t = v.kanalToplam;
  const gun = (n: number | null | undefined) => (n == null ? '—' : `${String(n).replace('.', ',')} gün`);
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Kanal</th><th className="sag">Kayıt</th><th className="sag">Pay</th><th className="sag">Verilen</th><th className="sag">Gelen</th>
          <th className="sag">Gelmeyen</th><th>No-show</th><th className="sag">İptal</th><th className="sag">Ort. Öne Alma</th></tr></thead>
        <tbody>
          {v.kanallar.length === 0 && <tr><td colSpan={9} className="bos">Dönemde randevu yok.</td></tr>}
          {v.kanallar.map(k => {
            const ns = noShowRozeti(k.noShow);
            return (
              <tr key={k.id}><td><b>{k.ad}</b></td><td className="sag">{sayi(k.kayit)}</td><td className="sag">{yuzde(k.pay)}</td>
                <td className="sag">{sayi(k.verilen)}</td><td className="sag">{sayi(k.gelen)}</td><td className="sag">{tire(k.gelmeyen)}</td>
                <td><span className={'bo-rz ' + ns.renk}>{ns.ad}</span></td><td className="sag">{tire(k.iptal)}</td><td className="sag">{gun(k.ortOneAlmaGun)}</td></tr>
            );
          })}
          {v.kanallar.length > 0 && (
            <tr className="top"><td>Toplam · {v.kanallar.length} kanal</td><td className="sag">{sayi(t.kayit)}</td><td /><td className="sag">{sayi(t.verilen)}</td>
              <td className="sag">{sayi(t.gelen)}</td><td className="sag">{sayi(t.gelmeyen)}</td><td>{yuzde(t.noShow)}</td><td className="sag">{sayi(t.iptal)}</td>
              <td className="sag">{gun(t.ortOneAlmaGun)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Kayıt = iptal dahil tüm randevular; verilen = iptal dışı. Kanal randevu kartındaki "Kaynak" alanıdır.</div>
    </>
  );
}

/** GÜN × SAAT - hücre: verilen / o gün-saatin slotu, altında gelmeme; bekleme dağılımı yanda. */
export function GunSaatTablosu({ v }: { v: RandevuIcmali }) {
  const g = v.gunSaat;
  return (
    <div className="lb-kalite">
      <div>
        <div className="lb-bas">Gün × Saat Doluluğu <span className="ki-soluk">hücre: verilen randevu / o gün-saat diliminin slotu · altında gelmeme oranı</span></div>
        <table className="hi-tablo rp-gs">
          <thead><tr><th>Saat</th>{g.gunler.map(d => <th key={d.dow} className="orta">{d.ad} <span className="ki-soluk">({d.gunSayisi} gün)</span></th>)}
            <th className="sag">Toplam</th></tr></thead>
          <tbody>
            {g.satirlar.length === 0 && <tr><td colSpan={g.gunler.length + 2} className="bos">Dönemde slot ya da randevu yok.</td></tr>}
            {g.satirlar.map(s => (
              <tr key={s.saat}>
                <td>{s.saat}</td>
                {s.hucreler.map((h, i) => {
                  const y = hucreYogunluk(h.doluluk);
                  return (
                    <td key={i} className="orta" style={y != null ? { background: `rgba(59,130,196,${(0.08 + y * 0.42).toFixed(2)})` } : undefined}>
                      {h.slot || h.verilen ? <><b>{yuzde(h.doluluk)}</b> <span className="ki-soluk">{h.verilen}</span>
                        {h.gelmeme ? <div className="ki-soluk">gelmeme {yuzde(h.gelmeme)}</div> : null}</> : '—'}
                    </td>
                  );
                })}
                <td className="sag">{sayi(s.verilen)}</td>
              </tr>
            ))}
            {g.satirlar.length > 0 && (
              <tr className="top"><td>Toplam</td>{g.gunler.map(d => <td key={d.dow} className="orta">{sayi(d.verilen)}</td>)}<td className="sag">{sayi(g.toplam)}</td></tr>
            )}
          </tbody>
        </table>
        <div className="ki-not">Slotlar çalışma planından saat saat sayılır (izinli gün düşülmüş). Toplam satırı verilen randevu sayısıdır.</div>
      </div>
      <div>
        <div className="lb-bas">Bekleme Süresi Dağılımı <span className="ki-soluk">randevu saati → muayene başlangıcı · yalnız gelenler</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Bekleme</th><th className="sag">Hasta</th><th>Pay</th></tr></thead>
          <tbody>
            {v.beklemeDagilimi.map(b => (
              <tr key={b.ad}><td>{b.ad}</td><td className="sag">{sayi(b.hasta)}</td>
                <td>{b.pay != null && <Cubuk oran={b.pay} />} {yuzde(b.pay)}</td></tr>
            ))}
            <tr className="top"><td>Toplam · ort. {dakika(v.ozet.ortBeklemeDk)}</td>
              <td className="sag">{sayi(v.ozet.beklemeOlculen)}</td><td /></tr>
          </tbody>
        </table>
        <div className="ki-not">Muayenesi randevuya bağlı (muayene.randevu_id) ve başlama saati girilmiş gelenler sayılır; erken başlayan 0 dk.</div>
      </div>
    </div>
  );
}

/** GELMEYENLER - daha önce de gelmeyen hasta önce (sunucu sırası). TC gösterilmez. */
export function GelmeyenTablosu({ v }: { v: RandevuIcmali }) {
  const o = v.ozet;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Randevu</th><th>Tarih / Saat</th><th>Hasta</th><th>Poliklinik</th><th>Hekim</th><th>Kanal</th><th>Tip</th>
          <th className="sag">Önceki Gelmeme</th><th>Verilme</th></tr></thead>
        <tbody>
          {v.gelmeyenler.length === 0 && <tr><td colSpan={9} className="bos">Dönemde gelmeyen randevu yok.</td></tr>}
          {v.gelmeyenler.map(g => (
            <tr key={g.id}>
              <td>{g.no}</td><td>{tarihSaat(g.tarih)}</td><td>{g.hasta}</td><td>{g.poliklinik}</td><td>{g.hekim}</td><td>{g.kanal}</td><td>{g.tip}</td>
              <td className="sag">{g.onceki ? <span className={'bo-rz ' + (g.onceki >= 2 ? 'kir' : 'sari')}>{g.onceki}</span> : '—'}</td>
              <td>{tarihKisa(g.verilme)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="ki-not">Dönemde {sayi(o.gelmeyenToplam)} gelmeyen randevu{v.gelmeyenler.length < o.gelmeyenToplam ? ` · ilk ${v.gelmeyenler.length} gösteriliyor` : ''}
        {o.ucuncuGelmeme ? ` · ${o.ucuncuGelmeme} randevuda hasta en az 3. kez gelmedi` : ''}. Önceki gelmeme = aynı hastanın son 6 ayda gelmediği randevu.
        Gelmeyen randevuda başvuru açılmadığı için Protokol No yoktur; satır randevu numarasıyla izlenir. Hasta TC'si gösterilmez.</div>
    </>
  );
}
