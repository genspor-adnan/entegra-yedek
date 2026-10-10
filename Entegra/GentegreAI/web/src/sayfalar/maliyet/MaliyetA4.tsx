import type { MaliyetIcmali } from '../../api/uclar/maliyetIcmal';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { para, paraYaz } from '../../bilesenler/bicim';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';

/**
 * A4 HASTA BAŞI MALİYET İCMALİ - yönetime verilir. Seçili başvuru varsa
 * yalnız onlar, yoksa bölüm özeti + zarar eden başvurular. TC basılmaz.
 */
export function MaliyetA4({ v, antet, duzenleyen, secili }: {
  v: MaliyetIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const p = (n: number) => para.format(n);
  const o = v.ozet;
  const basvurular = secili.length ? v.basvurular.filter(b => secili.includes(b.id)) : v.basvurular.filter(b => b.kar < 0);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>HASTA BAŞI MALİYET İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Başvuru: {o.basvuru} · maliyetli {o.maliyetliBasvuru}</span>
        <span>Hasta başı maliyet: {paraYaz(o.hastaBasi)}</span><span>Zarar eden: {o.zarar}</span>
      </div>
      <table className="a4-t ml-a4t">
        <thead><tr><th>Bölüm</th><th>Başvuru</th><th>Ciro</th><th>Sarf</th><th>İlaç</th><th>Kâr</th><th>Marj</th></tr></thead>
        <tbody>
          {v.bolumler.map(b => (
            <tr key={b.id}><td>{b.ad}</td><td>{b.basvuru}</td><td>{p(b.ciro)}</td><td>{p(b.sarf)}</td><td>{p(b.ilac)}</td>
              <td>{p(b.kar)}</td><td>{b.marj != null ? `%${b.marj.toFixed(1).replace('.', ',')}` : '—'}</td></tr>
          ))}
        </tbody>
      </table>
      {basvurular.length > 0 && (<>
        <div className="ml-alt">{secili.length ? 'Seçili başvurular' : 'Zarar eden başvurular'}</div>
        <table className="a4-t ml-a4t">
          <thead><tr><th>Protokol No</th><th>Hasta</th><th>Tarih</th><th>Ciro</th><th>Maliyet</th><th>Kâr</th><th>Marj</th></tr></thead>
          <tbody>
            {basvurular.map(b => (
              <tr key={b.id}><td>{b.protokolNo}</td><td>{b.hasta}</td><td>{tarihKisa(b.tarih)}</td><td>{p(b.ciro)}</td>
                <td>{p(b.sarf + b.ilac)}</td><td>{p(b.kar)}</td><td>{b.marj != null ? `%${b.marj.toFixed(1).replace('.', ',')}` : '—'}</td></tr>
            ))}
          </tbody>
        </table>
      </>)}
      <table className="a4-toplam"><tbody>
        <tr><td>Ciro</td><td>{paraYaz(o.ciro)}</td></tr>
        <tr><td>Sarf maliyeti</td><td>{paraYaz(o.sarf)}</td></tr>
        <tr><td>İlaç maliyeti</td><td>{paraYaz(o.ilac)}</td></tr>
        <tr><td>Faturalanmamış sarf ({o.faturasizKalem} kalem, maliyet)</td><td>{paraYaz(o.faturasizMaliyet)}</td></tr>
        <tr className="kalan ki-kalan"><td>BRÜT KÂR {o.marj != null ? `(%${o.marj.toFixed(1).replace('.', ',')})` : ''}</td><td>{paraYaz(o.kar)}</td></tr>
      </tbody></table>
      <p className="a4-not">Maliyet: düşülen sarf (radyoloji, diş seansı, ameliyat) + faturalı stok satırları; birim maliyet
        giriş belgelerinden ağırlıklı ortalama. Personel, amortisman ve genel giderler dahil değildir.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali İşler / Yönetim<br />Kaşe · İmza</div></div>
    </div>
  );
}
