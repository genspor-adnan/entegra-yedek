import type { KurumIcmali } from '../../../api/uclar/kurumIcmal';
import { para } from '../../../bilesenler/bicim';
import { tarihKisa } from '../../hasta/icmal/icmalOrtak';
import { icmalRozeti, provizyonRozeti } from './kurumIcmalOrtak';

/** Kurum icmalinin sekme tabloları (KurumIcmal). Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

/**
 * DÖNEMDEKİ KURUMLAR - soldaki onay kutusu (kullanıcı) diğer sekmeleri süzer;
 * hiçbiri seçili değilse bütün kurumlar. Satıra tıklamak da seçer.
 */
export function KurumTablosu({ v, secili, setSecili }: {
  v: KurumIcmali; secili: number[]; setSecili(s: number[]): void;
}) {
  const hepsi = v.kurumlar.length > 0 && v.kurumlar.every(k => secili.includes(k.id));
  const degistir = (id: number) =>
    setSecili(secili.includes(id) ? secili.filter(x => x !== id) : [...secili, id]);
  const enBuyuk = Math.max(...v.kurumlar.map(k => k.kurumPayi), 1);
  const t = (f: (k: KurumIcmali['kurumlar'][number]) => number) => v.kurumlar.reduce((s, k) => s + f(k), 0);
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}>
          <input type="checkbox" checked={hepsi} title="Hepsini seç / bırak"
                 onChange={() => setSecili(hepsi ? [] : v.kurumlar.map(k => k.id))} />
        </th>
        <th>Kurum</th><th>Tür</th><th className="sag">Başvuru</th><th className="sag">Toplam Hizmet</th>
        <th className="sag">Kurum Payı</th><th className="sag">Kesinti</th><th className="sag">Net Alacak</th>
        <th>Pay</th><th>Dönem Durumu</th></tr></thead>
      <tbody>
        {v.kurumlar.length === 0 && <tr><td colSpan={10} className="bos">Bu dönemde kurum başvurusu yok.</td></tr>}
        {v.kurumlar.map(k => {
          const r = icmalRozeti(k.icmalDurum);
          const sec = secili.includes(k.id);
          return (
            <tr key={k.id} className={'ac' + (sec ? ' sec' : '')} onClick={() => degistir(k.id)}>
              <td><input type="checkbox" checked={sec} onClick={e => e.stopPropagation()}
                         onChange={() => degistir(k.id)} /></td>
              <td><b>{k.ad}</b></td><td>{k.turAdi}</td><td className="sag">{k.basvuru}</td>
              <td className="sag">{p(k.toplam)}</td><td className="sag">{p(k.kurumPayi)}</td>
              <td className={'sag' + (k.kesinti > 0.005 ? ' kir' : '')}>{tire(k.kesinti)}</td>
              <td className="sag">{p(k.net)}</td>
              <td><div className="ki-cubuk"><i style={{ width: `${Math.round(100 * k.kurumPayi / enBuyuk)}%` }} /></div></td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
            </tr>
          );
        })}
        {v.kurumlar.length > 0 && (
          <tr className="top"><td /><td colSpan={2}>{v.kurumlar.length} kurum</td>
            <td className="sag">{t(k => k.basvuru)}</td><td className="sag">{p(t(k => k.toplam))}</td>
            <td className="sag">{p(t(k => k.kurumPayi))}</td><td className="sag">{p(t(k => k.kesinti))}</td>
            <td className="sag">{p(t(k => k.net))}</td><td colSpan={2} /></tr>
        )}
      </tbody>
    </table>
  );
}

export function BasvuruTablosu({ v, kurumSutunu, hastaAc }: {
  v: KurumIcmali; kurumSutunu: boolean; hastaAc(id: number): void;
}) {
  const o = v.ozet;
  const sutun = kurumSutunu ? 12 : 11;
  return (
    <table className="hi-tablo">
      <thead><tr><th>Tarih</th><th>Protokol No</th><th>Hasta</th>{kurumSutunu && <th>Kurum</th>}
        <th>Poliçe / Provizyon No</th><th>Bölüm</th>
        <th className="sag">Toplam</th><th className="sag">Kurum Payı</th><th className="sag">Hasta Payı</th>
        <th className="sag">Kesinti</th><th className="sag">Net</th><th>Provizyon</th></tr></thead>
      <tbody>
        {v.basvurular.length === 0 && <tr><td colSpan={sutun} className="bos">Seçili kurumlarda başvuru yok.</td></tr>}
        {v.basvurular.map(b => {
          const r = provizyonRozeti(b.provizyon);
          return (
            <tr key={b.id} className={b.provizyon === 2 ? 'red' : ''}>
              <td>{tarihKisa(b.tarih)}</td><td>{b.protokolNo}</td>
              <td>{b.hastaId
                ? <a className="ki-lnk" title="Hasta icmalini aç" onClick={() => hastaAc(b.hastaId!)}>{b.hasta}</a>
                : b.hasta}</td>
              {kurumSutunu && <td>{b.kurum}</td>}
              <td>{b.provizyonNo || '—'}</td><td>{b.bolum || '—'}</td>
              <td className="sag">{p(b.toplam)}</td><td className="sag">{p(b.kurumPayi)}</td>
              <td className="sag">{p(b.hastaPayi)}</td>
              <td className={'sag' + (b.kesinti > 0.005 ? ' kir' : '')}>{tire(b.kesinti)}</td>
              <td className="sag">{p(b.net)}</td>
              <td>{r ? <span className={'bo-rz ' + r.renk}>{r.ad}</span> : '—'}
                {b.icmalde && <span className="bo-rz mavi" style={{ marginLeft: 4 }}>icmalde</span>}</td>
            </tr>
          );
        })}
        {v.basvurular.length > 0 && (
          <tr className="top"><td colSpan={kurumSutunu ? 6 : 5}>Toplam · {o.basvuru} başvuru{o.red ? ` (${o.red} red)` : ''}</td>
            <td className="sag">{p(o.toplam)}</td><td className="sag">{p(o.kurumPayi)}</td>
            <td className="sag">{p(o.hastaPayi)}</td><td className="sag">{p(o.kesinti)}</td>
            <td className="sag">{p(o.net)}</td><td /></tr>
        )}
      </tbody>
    </table>
  );
}

export function HizmetGrubuTablosu({ v }: { v: KurumIcmali }) {
  const g = v.hizmetGruplari;
  const kurum = g.reduce((t, x) => t + x.kurumPayi, 0) || 1;
  return (
    <table className="hi-tablo">
      <thead><tr><th>Hizmet Grubu</th><th className="sag">Kalem</th><th className="sag">Tutar</th>
        <th className="sag">Kurum Payı</th><th className="sag">Hasta Payı</th><th>Kurum Payı Dağılımı</th></tr></thead>
      <tbody>
        {g.length === 0 && <tr><td colSpan={6} className="bos">Hizmet satırı yok.</td></tr>}
        {g.map(x => (
          <tr key={x.grup}><td>{x.grup}</td><td className="sag">{x.kalem}</td><td className="sag">{p(x.toplam)}</td>
            <td className="sag">{p(x.kurumPayi)}</td><td className="sag">{p(x.hastaPayi)}</td>
            <td><div className="ki-cubuk"><i style={{ width: `${Math.round(100 * x.kurumPayi / kurum)}%` }} /></div></td></tr>
        ))}
        {g.length > 0 && (
          <tr className="top"><td>Toplam (KDV hariç satır tutarı)</td><td className="sag">{g.reduce((t, x) => t + x.kalem, 0)}</td>
            <td className="sag">{p(g.reduce((t, x) => t + x.toplam, 0))}</td>
            <td className="sag">{p(g.reduce((t, x) => t + x.kurumPayi, 0))}</td>
            <td className="sag">{p(g.reduce((t, x) => t + x.hastaPayi, 0))}</td><td /></tr>
        )}
      </tbody>
    </table>
  );
}

const ITIRAZ = ['İtiraz yok', 'İtiraz edildi', 'Kabul edildi', 'Reddedildi'];

export function KesintiTablosu({ v }: { v: KurumIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Protokol No</th><th>Hasta</th><th>SUT Kodu</th><th>Kesinti Kodu</th><th>Açıklama</th>
        <th className="sag">Kesinti</th><th className="sag">İade</th><th>İtiraz</th></tr></thead>
      <tbody>
        {v.kesintiler.length === 0 && <tr><td colSpan={8} className="bos">
          Bu dönemde kurum kesintisi yok. (SGK kesintileri Medula fatura sonucundan gelir.)</td></tr>}
        {v.kesintiler.map(k => (
          <tr key={k.id}><td>{k.protokolNo}</td><td>{k.hasta}</td><td>{k.sutKodu || '—'}</td><td>{k.kod || '—'}</td>
            <td>{k.aciklama || '—'}</td><td className="sag kir">{p(k.tutar)}</td><td className="sag">{tire(k.iade)}</td>
            <td><span className={'bo-rz ' + (k.itirazDurum === 1 ? 'mavi' : k.itirazDurum === 2 ? 'ok' : k.itirazDurum === 3 ? 'kir' : 'pas')}>
              {ITIRAZ[k.itirazDurum] ?? k.itirazDurum}</span></td></tr>
        ))}
      </tbody>
    </table>
  );
}

export function FaturaTablolari({ v, faturaAc }: { v: KurumIcmali; faturaAc(id: number): void }) {
  const c = v.cari;
  let bakiye = c?.devreden ?? 0;
  return (
    <div className="ki-ikili">
      <div>
        <div className="ki-baslik">Dönem İcmalleri ve Faturaları</div>
        <table className="hi-tablo">
          <thead><tr><th>Kurum</th><th>Dönem</th><th>Fatura No</th><th>Tarih</th>
            <th className="sag">Fatura</th><th className="sag">Tahsil</th><th>Durum</th></tr></thead>
          <tbody>
            {v.icmaller.length === 0 && <tr><td colSpan={7} className="bos">Bu dönem için icmal oluşturulmadı.</td></tr>}
            {v.icmaller.map(i => {
              const r = icmalRozeti(i.durum);
              return (
                <tr key={i.id}><td>{i.kurum}</td><td>{tarihKisa(i.donemBas)} – {tarihKisa(i.donemBit)}</td>
                  <td>{i.belgeId ? <a className="ki-lnk" onClick={() => faturaAc(i.belgeId!)}>{i.faturaNo}</a> : '—'}</td>
                  <td>{tarihKisa(i.faturaTarihi)}</td>
                  <td className="sag">{i.belgeId ? p(i.faturaTutari) : p(i.toplam)}</td><td className="sag">{tire(i.tahsil)}</td>
                  <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>
              );
            })}
          </tbody>
        </table>
      </div>
      <div>
        <div className="ki-baslik">Kurum Cari Hareketleri</div>
        {!c ? <div className="bos ki-not">Cari hareketler tek kurum seçiliyken görünür.</div> : (
          <table className="hi-tablo">
            <thead><tr><th>Tarih</th><th>Belge</th><th>Açıklama</th><th className="sag">Borç</th>
              <th className="sag">Alacak</th><th className="sag">Bakiye</th></tr></thead>
            <tbody>
              <tr><td>{tarihKisa(v.donem.bas)}</td><td /><td className="ki-soluk">Devreden</td><td /><td />
                <td className="sag">{p(c.devreden)}</td></tr>
              {c.hareketler.map((h, i) => {
                bakiye += h.borc - h.alacak;
                return (
                  <tr key={i}><td>{tarihKisa(h.tarih)}</td><td>{h.belge}</td><td>{h.tur}{h.aciklama && ` · ${h.aciklama}`}</td>
                    <td className="sag">{tire(h.borc)}</td><td className="sag">{tire(h.alacak)}</td>
                    <td className={'sag' + (bakiye > 0.005 ? ' kir' : '')}>{p(bakiye)}</td></tr>
                );
              })}
              <tr className="top"><td colSpan={5}>Kurum bakiyesi (borçlu)</td><td className="sag">{p(c.bakiye)}</td></tr>
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
