import type { HekimPerformansIcmali } from '../../api/uclar/hekimPerformans';
import { AntetLogo } from '../../bilesenler/AntetLogo';
import { para, paraYaz } from '../../bilesenler/bicim';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';

/**
 * A4 HEKİM PERFORMANS İCMALİ - yönetime verilir. Ekranda önizleme sekmesinde,
 * yazdırınca yalnız bu basılır (icmallerle aynı `@media print` kuralı).
 * Seçili hekim varsa yalnız onlar.
 */
export function PerformansA4({ v, antet, duzenleyen }: {
  v: HekimPerformansIcmali; antet: Record<string, unknown> | null; duzenleyen: string;
}) {
  const p = (n: number) => para.format(n);
  const o = v.ozet;
  const hekimler = v.secili.length ? v.hekimler.filter(h => v.secili.includes(h.id)) : v.hekimler;
  return (
    <div className="hi-a4">
      <div className="a4-bas">
        <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
        <div><div className="kurum">{String(antet?.unvan ?? '')}</div>
          <div className="kurum-alt">{[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), antet?.telefon]
            .filter(x => x && String(x).trim()).join(' · ')}</div></div>
        <div className="a4-tarih">Düzenleme: {new Date().toLocaleString('tr-TR')}<br />Düzenleyen: {duzenleyen}</div>
      </div>
      <h3>DOKTOR PERFORMANS İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Karşılaştırma: {tarihKisa(v.donem.oncekiBas)} - {tarihKisa(v.donem.oncekiBit)}</span>
        <span>Doktor: {hekimler.length}{v.secili.length ? ' (seçili)' : ''}</span><span>Başvuru: {o.basvuru}</span>
      </div>
      <table className="a4-t pf-a4t">
        <thead><tr><th>Doktor</th><th>Bölüm</th><th>Başvuru</th><th>Ciro</th><th>Kurum</th><th>Hasta</th>
          <th>İskonto</th><th>Hakediş</th><th>Değişim</th></tr></thead>
        <tbody>
          {hekimler.map(h => (
            <tr key={h.id}><td>{h.ad}</td><td>{h.bolum}</td><td>{h.deger.basvuru}</td><td>{p(h.deger.ciro)}</td>
              <td>{p(h.deger.kurumPayi)}</td><td>{p(h.deger.hastaPayi)}</td><td>{p(h.deger.iskonto)}</td>
              <td>{p(h.deger.hakedis)}</td>
              <td>{h.deger.degisim != null ? `%${h.deger.degisim.toFixed(1).replace('.', ',')}` : '—'}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Ciro{v.secili.length ? ' (seçili doktorlar)' : ' (doktorsuz başvurular dahil)'}</td><td>{paraYaz(o.ciro)}</td></tr>
        <tr><td>Kurum payı (%{o.kurumOrani.toFixed(1).replace('.', ',')})</td><td>{paraYaz(o.kurumPayi)}</td></tr>
        <tr><td>Hasta payı</td><td>{paraYaz(o.hastaPayi)}</td></tr>
        <tr><td>İskonto</td><td>{paraYaz(o.iskonto)}</td></tr>
        <tr><td>Tahsil edilen</td><td>{paraYaz(o.tahsil)}</td></tr>
        <tr className="kalan ki-kalan"><td>HAKEDİŞ</td><td>{paraYaz(o.hakedis)}</td></tr>
      </tbody></table>
      <p className="a4-not">Ciro = başvuru genel toplamı (KDV dahil). Hakediş, dönem tarihli hakediş satırlarından
        (iptal hariç). Değişim, karşılaştırma dönemi cirosuna göredir.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Başhekim / Yönetim<br />Kaşe · İmza</div></div>
    </div>
  );
}
