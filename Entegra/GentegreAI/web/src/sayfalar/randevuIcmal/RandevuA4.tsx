import type { RandevuIcmali } from '../../api/uclar/randevuIcmal';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { dakika, sayi, yuzde } from './randevuIcmalOrtak';

/**
 * A4 RANDEVU / POLİKLİNİK DÖNEM İCMALİ. Poliklinik tablosu (seçiliyse yalnız
 * onlar) ve dönem toplamları. Hasta bilgisi basılmaz.
 */
export function RandevuA4({ v, antet, duzenleyen, secili }: {
  v: RandevuIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const o = v.ozet;
  const satirlar = secili.length ? v.poliklinikler.filter(p => secili.includes(p.id)) : v.poliklinikler;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>RANDEVU / POLİKLİNİK DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Poliklinik: {o.poliklinik} · hekim: {o.hekim}</span>
        <span>Çalışma günü: {o.calismaGunu}</span><span>{secili.length ? `Seçili ${satirlar.length} poliklinik` : 'Tüm poliklinikler'}</span>
      </div>
      <table className="a4-t rp-a4t">
        <thead><tr><th>Poliklinik</th><th>Slot</th><th>Verilen</th><th>Doluluk</th><th>Gelen</th><th>Gelmeyen</th><th>No-show</th>
          <th>Randevusuz</th><th>Ort. Bekleme</th></tr></thead>
        <tbody>
          {satirlar.map(p => (
            <tr key={p.id}><td>{p.ad}</td><td>{sayi(p.deger.slot)}</td><td>{sayi(p.deger.verilen)}</td><td>{yuzde(p.deger.doluluk)}</td>
              <td>{sayi(p.deger.gelen)}</td><td>{sayi(p.deger.gelmeyen)}</td><td>{yuzde(p.deger.noShow)}</td><td>{sayi(p.deger.randevusuz)}</td>
              <td>{dakika(p.deger.ortBeklemeDk)}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Verilen randevu / slot</td><td>{sayi(o.verilen)} / {sayi(o.slot)} ({yuzde(o.doluluk)})</td></tr>
        <tr><td>Gelen / gelmeyen</td><td>{sayi(o.gelen)} / {sayi(o.gelmeyen)}</td></tr>
        <tr><td>İptal</td><td>{sayi(o.iptal)}</td></tr>
        <tr><td>Randevusuz muayene</td><td>{sayi(o.randevusuz)}</td></tr>
        <tr className="kalan ki-kalan"><td>NO-SHOW ORANI</td><td>{yuzde(o.noShow)}</td></tr>
      </tbody></table>
      <p className="a4-not">Ortalama bekleme {dakika(o.ortBeklemeDk)} · 30 dakikadan uzun bekleyen {sayi(o.uzunBekleme)} hasta · ilk muayene / kontrol
        {' '}{sayi(o.ilk)} / {sayi(o.kontrol)}. Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Hasta Hizmetleri · İmza</div><div>Onaylayan<br />Başhekim · İmza</div></div>
    </div>
  );
}
