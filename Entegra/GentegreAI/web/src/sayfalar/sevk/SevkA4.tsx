import type { SevkEdenIcmali } from '../../api/uclar/sevkEden';
import { AntetLogo } from '../../bilesenler/AntetLogo';
import { para, paraYaz } from '../../bilesenler/bicim';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { odemeRozeti, turRozeti } from './sevkOrtak';

/**
 * A4 SEVK EDEN HEKİM DÖNEM İCMALİ. Seçili gönderen varsa yalnız onlar.
 * Hasta adı BASILMAZ (sevk sayısı ve tutar yeter - kişisel veri dışarı
 * verilen belgeye girmez); başvurular protokol no ile.
 */
export function SevkA4({ v, antet, duzenleyen }: {
  v: SevkEdenIcmali; antet: Record<string, unknown> | null; duzenleyen: string;
}) {
  const p = (n: number) => para.format(n);
  const o = v.ozet;
  const doktorlar = v.secili.length ? v.doktorlar.filter(d => v.secili.includes(d.id)) : v.doktorlar;
  return (
    <div className="hi-a4">
      <div className="a4-bas">
        <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
        <div><div className="kurum">{String(antet?.unvan ?? '')}</div>
          <div className="kurum-alt">{[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), antet?.telefon]
            .filter(x => x && String(x).trim()).join(' · ')}</div></div>
        <div className="a4-tarih">Düzenleme: {new Date().toLocaleString('tr-TR')}<br />Düzenleyen: {duzenleyen}</div>
      </div>
      <h3>SEVK EDEN HEKİM DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Gönderen: {doktorlar.length}{v.secili.length ? ' (seçili)' : ''}</span>
        <span>Sevkli başvuru: {o.basvuru}</span><span>Önceki dönem: {o.oncekiBasvuru}</span>
      </div>
      <table className="a4-t sv-a4t">
        <thead><tr><th>Gönderen</th><th>Tür</th><th>Sevk</th><th>Sevkli Ciro</th><th>Komisyon</th><th>Ödeme</th></tr></thead>
        <tbody>
          {doktorlar.map(d => (
            <tr key={d.id}><td>{d.ad}</td><td>{turRozeti(d.tur).ad}</td><td>{d.basvuru}</td><td>{p(d.ciro)}</td>
              <td>{p(d.komisyon)}</td><td>{odemeRozeti(d.odemeDurumu).ad}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Sevkli ciro</td><td>{paraYaz(o.ciro)}</td></tr>
        <tr><td>Komisyon (gönderen primi)</td><td>{paraYaz(o.komisyon)}</td></tr>
        <tr><td>Ödenen</td><td>{paraYaz(o.odenen)}</td></tr>
        <tr className="kalan ki-kalan"><td>ÖDENECEK KOMİSYON</td><td>{paraYaz(o.bekleyen)}</td></tr>
      </tbody></table>
      <p className="a4-not">Komisyon prim planına göre hesaplanmış gönderen primidir; kurum adına gelen sevklerde hekime prim
        yazılmaz. Ödeme kişisel değil, hak sahibinin düzenlediği fatura / makbuz karşılığında yapılır.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali İşler / Yönetim<br />Kaşe · İmza</div></div>
    </div>
  );
}
