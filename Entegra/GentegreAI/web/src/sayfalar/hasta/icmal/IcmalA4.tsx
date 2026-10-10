import type { HastaIcmali } from '../../../api/uclar/hastaIcmal';
import { AntetLogo } from '../../../bilesenler/AntetLogo';
import { para, paraYaz } from '../../../bilesenler/bicim';
import { tarihKisa } from './icmalOrtak';

/**
 * A4 HASTA HESAP İCMALİ - ekranda önizleme, yazdırınca yalnız bu basılır
 * (HastaIcmal stili `@media print`). Kurum payı bilgi amaçlı; hastaya
 * söylenen rakam "Ödenecek kalan".
 */
export function IcmalA4({ v, antet, duzenleyen }: {
  v: HastaIcmali; antet: Record<string, unknown> | null; duzenleyen: string;
}) {
  const o = v.ozet;
  const p = (n: number) => para.format(n);
  return (
    <div className="hi-a4">
      <div className="a4-bas">
        <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
        <div><div className="kurum">{String(antet?.unvan ?? '')}</div>
          <div className="kurum-alt">{[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), antet?.telefon]
            .filter(x => x && String(x).trim()).join(' · ')}</div></div>
        <div className="a4-tarih">Düzenleme: {new Date().toLocaleString('tr-TR')}<br />Düzenleyen: {duzenleyen}</div>
      </div>
      <h3>HASTA HESAP İCMALİ</h3>
      <div className="a4-hasta">
        <span>Hasta: <b>{v.hasta.ad}</b></span><span>Dosya No: {v.hasta.dosyaNo || '—'}</span>
        <span>T.C. Kimlik: {v.hasta.tc || '—'}</span><span>Dönem: {tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</span>
      </div>
      <table className="a4-t">
        <thead><tr><th>Tarih</th><th>Protokol No</th><th>Toplam</th><th>Kurum</th><th>Hasta</th><th>Tahsil</th><th>Kalan</th></tr></thead>
        <tbody>
          {v.basvurular.filter(b => !b.iptal).map(b => (
            <tr key={b.id}><td>{tarihKisa(b.tarih)}</td><td>{b.no}</td><td>{p(b.toplam)}</td>
              <td>{p(b.kurumPayi)}</td><td>{p(b.hastaPayi)}</td><td>{p(b.tahsil)}</td><td>{p(b.kalan)}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Toplam hizmet</td><td>{paraYaz(o.toplam)}</td></tr>
        <tr><td>Kurum payı</td><td>{paraYaz(o.kurumPayi)}</td></tr>
        <tr><td>Hasta payı</td><td>{paraYaz(o.hastaPayi)}</td></tr>
        <tr><td>Tahsil edilen</td><td>{paraYaz(o.tahsil - o.iade)}</td></tr>
        {o.avans > 0 && <tr><td>Avans (mahsup edilmedi)</td><td>{paraYaz(o.avans)}</td></tr>}
        <tr className="kalan"><td>ÖDENECEK KALAN</td><td>{paraYaz(o.kalan)}</td></tr>
      </tbody></table>
      <p className="a4-not">Kurum payı bilgi amaçlıdır; hastadan talep edilmez. Bu belge fatura yerine geçmez.</p>
      <div className="a4-imza"><div>Hasta / Yakını<br />Ad Soyad · İmza</div><div>Vezne Yetkilisi<br />Kaşe · İmza</div></div>
    </div>
  );
}
