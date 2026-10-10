import { Fragment, useState } from 'react';
import type { HastaIcmali } from '../../../api/uclar/hastaIcmal';
import { para } from '../../../bilesenler/bicim';
import { basvuruDurumu, hareketleriKur, odemeRozeti, tarihKisa } from './icmalOrtak';

/** Hasta icmalinin sekme tabloları (HastaIcmal). Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);

export function BasvuruTablosu({ v }: { v: HastaIcmali }) {
  const [acik, setAcik] = useState<Record<number, boolean>>({});
  const o = v.ozet;
  const gecerli = v.basvurular.filter(b => !b.iptal);
  return (
    <table className="hi-tablo">
      <thead><tr><th>Tarih</th><th>Başvuru No</th><th>Bölüm / Hekim</th><th>Kurum</th>
        <th className="sag">Toplam</th><th className="sag">İskonto</th><th className="sag">Kurum Payı</th>
        <th className="sag">Hasta Payı</th><th className="sag">Tahsil</th><th className="sag">Kalan</th><th>Durum</th></tr></thead>
      <tbody>
        {v.basvurular.map(b => {
          const d = basvuruDurumu(b);
          return (
            <Fragment key={b.id}>
              <tr className={'ac' + (b.iptal ? ' iptal' : '') + (acik[b.id] ? ' sec' : '')}
                  onClick={() => setAcik(a => ({ ...a, [b.id]: !a[b.id] }))}>
                <td><span className="ok">{acik[b.id] ? '▾' : '▸'}</span>{tarihKisa(b.tarih)}</td>
                <td>{b.no}</td><td>{b.bolum || '—'}{b.hekim && ` · ${b.hekim}`}</td><td>{b.kurum}</td>
                <td className="sag">{p(b.toplam)}</td><td className="sag">{b.iskonto ? p(b.iskonto) : '—'}</td>
                <td className="sag">{p(b.kurumPayi)}</td><td className="sag">{p(b.hastaPayi)}</td>
                <td className="sag">{p(b.tahsil)}</td>
                <td className={'sag' + (b.kalan > 0.005 && !b.iptal ? ' kir' : '')}>{p(b.kalan)}</td>
                <td><span className={'bo-rz ' + d.renk}>{d.ad}</span></td>
              </tr>
              {acik[b.id] && (
                <tr className="det"><td colSpan={11}>
                  {v.hizmetler.filter(h => h.basvuruId === b.id)
                    .map(h => `${h.kod} ${h.ad} ${h.adet}×${p(h.birimFiyat)} = ${p(h.tutar)}`).join(' · ') || 'Hizmet satırı yok.'}
                </td></tr>
              )}
            </Fragment>
          );
        })}
        <tr className="top"><td colSpan={4}>Toplam (iptal hariç · {gecerli.length} başvuru)</td>
          <td className="sag">{p(o.toplam)}</td><td className="sag">{p(o.iskonto)}</td>
          <td className="sag">{p(o.kurumPayi)}</td><td className="sag">{p(o.hastaPayi)}</td>
          <td className="sag">{p(gecerli.reduce((t, b) => t + b.tahsil, 0))}</td>
          <td className="sag">{p(o.kalan)}</td><td /></tr>
      </tbody>
    </table>
  );
}

export function HizmetTablosu({ v }: { v: HastaIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Tarih</th><th>Başvuru</th><th>Kod</th><th>Hizmet</th><th className="sag">Adet</th>
        <th className="sag">Birim Fiyat</th><th className="sag">Tutar</th><th className="sag">Kurum</th><th className="sag">Hasta</th></tr></thead>
      <tbody>
        {v.hizmetler.map((h, i) => (
          <tr key={i}><td>{tarihKisa(h.tarih)}</td><td>{h.basvuruNo}</td><td>{h.kod}</td><td>{h.ad}</td>
            <td className="sag">{h.adet}</td><td className="sag">{p(h.birimFiyat)}</td><td className="sag">{p(h.tutar)}</td>
            <td className="sag">{p(h.kurumPayi)}</td><td className="sag">{p(h.hastaPayi)}</td></tr>
        ))}
      </tbody>
    </table>
  );
}

export function TahsilatTablosu({ v }: { v: HastaIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Makbuz No</th><th>Tarih</th><th>Banko</th><th>Ödeme</th><th>İşlem</th><th>Başvuru</th>
        <th className="sag">Tutar</th></tr></thead>
      <tbody>
        {v.tahsilatlar.length === 0 && <tr><td colSpan={7} className="bos">Bu dönemde tahsilat yok.</td></tr>}
        {v.tahsilatlar.map(t => {
          const r = odemeRozeti(t);
          return (
            <tr key={t.id} className={t.iptal ? 'iptal' : ''}>
              <td>{t.makbuzNo}</td><td>{tarihKisa(t.tarih)}</td><td>{t.banko || '—'}</td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td><td>{t.tur}</td><td>{t.basvuruNo || '—'}</td>
              <td className={'sag' + (t.iade ? ' kir' : '')}>{t.iade ? '−' : ''}{p(t.tutar)}</td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}

export function ProvizyonTablosu({ v }: { v: HastaIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Başvuru</th><th>Provizyon / Takip No</th><th className="sag">SGK</th>
        <th className="sag">Özel Sigorta</th><th className="sag">Satır</th><th>Durum</th></tr></thead>
      <tbody>
        {v.provizyonlar.length === 0 && <tr><td colSpan={6} className="bos">Kurum payı olan başvuru yok.</td></tr>}
        {v.provizyonlar.map((pr, i) => (
          <tr key={i}><td>{pr.basvuruNo}</td><td>{pr.provizyonNo || '—'}</td>
            <td className="sag">{p(pr.sgk)}</td><td className="sag">{p(pr.ozelSigorta)}</td>
            <td className="sag">{pr.satir}</td>
            <td>{pr.provizyonNo ? <span className="bo-rz ok">Provizyonlu</span> : <span className="bo-rz sari">Provizyon yok</span>}</td></tr>
        ))}
      </tbody>
    </table>
  );
}

export function HareketTablosu({ v }: { v: HastaIcmali }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Tarih</th><th>Belge</th><th>Açıklama</th><th className="sag">Borç</th>
        <th className="sag">Alacak</th><th className="sag">Bakiye</th></tr></thead>
      <tbody>
        {hareketleriKur(v).map((h, i) => (
          <tr key={i}><td>{tarihKisa(h.t)}</td><td>{h.belge}</td><td>{h.aciklama}</td>
            <td className="sag">{h.borc ? p(h.borc) : '—'}</td><td className="sag">{h.alacak ? p(h.alacak) : '—'}</td>
            <td className={'sag' + (h.bakiye > 0.005 ? ' kir' : '')}>{p(h.bakiye)}</td></tr>
        ))}
      </tbody>
    </table>
  );
}
