import type { IskontoIcmali } from '../../api/uclar/iskontoIcmal';
import { AntetLogo } from '../../bilesenler/AntetLogo';
import { para, paraYaz } from '../../bilesenler/bicim';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { kaynakRozeti, oranMetni } from './iskontoIcmalOrtak';

/**
 * A4 İSKONTO VE ÜCRETSİZ HİZMET İCMALİ - yönetim / iç denetim için. Ekranda
 * önizleme sekmesinde, yazdırınca yalnız bu basılır. Seçili başvuru varsa
 * yalnız onlar. TC basılmaz.
 */
export function IskontoIcmalA4({ v, antet, duzenleyen, secili }: {
  v: IskontoIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const p = (n: number) => para.format(n);
  const o = v.ozet;
  const satirlar = secili.length ? v.basvurular.filter(b => secili.includes(b.belgeId)) : v.basvurular;
  return (
    <div className="hi-a4">
      <div className="a4-bas">
        <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
        <div><div className="kurum">{String(antet?.unvan ?? '')}</div>
          <div className="kurum-alt">{[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), antet?.telefon]
            .filter(x => x && String(x).trim()).join(' · ')}</div></div>
        <div className="a4-tarih">Düzenleme: {new Date().toLocaleString('tr-TR')}<br />Düzenleyen: {duzenleyen}</div>
      </div>
      <h3>İSKONTO VE ÜCRETSİZ HİZMET İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Başvuru: {satirlar.length}{secili.length ? ' (seçili)' : ''}</span>
        <span>Onay eşiği: %{o.esik}</span><span>Eşik üstü talepsiz: {o.esikUstu}</span>
      </div>
      <table className="a4-t ii-a4t">
        <thead><tr><th>Tarih</th><th>Protokol No</th><th>Hasta</th><th>Veren / Onaylayan</th><th>Kaynak</th>
          <th>Oran</th><th>İskonto</th></tr></thead>
        <tbody>
          {satirlar.map(b => (
            <tr key={b.belgeId}><td>{tarihKisa(b.tarih)}</td><td>{b.protokolNo}</td><td>{b.hasta}</td>
              <td>{b.onaylayan ? `${b.isteyen} / ${b.onaylayan}` : b.isteyen}</td><td>{kaynakRozeti(b.kaynak).ad}</td>
              <td>{oranMetni(b.oran)}{b.esikUstu ? ' ⚠' : ''}</td><td>{p(b.iskonto)}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Onaylı talep iskontosu</td><td>{paraYaz(o.talepli)}</td></tr>
        <tr><td>Kampanya iskontosu</td><td>{paraYaz(o.kampanya)}</td></tr>
        <tr><td>Banko (talepsiz) iskontosu</td><td>{paraYaz(o.banko)}</td></tr>
        <tr><td>Ücretsiz hizmet ({o.ucretsizKalem} kalem, liste fiyatı)</td><td>{paraYaz(o.ucretsiz)}</td></tr>
        <tr><td>Reddedilen talep ({o.red}, toplama girmez)</td><td>{paraYaz(o.redTutar)}</td></tr>
        <tr className="kalan ki-kalan"><td>TOPLAM İNDİRİM (iskonto + ücretsiz)</td><td>{paraYaz(o.iskonto + o.ucretsiz)}</td></tr>
      </tbody></table>
      <p className="a4-not">İskonto = satır liste tutarı (adet × birim fiyat) − satır tutarı; Doktor Performans İcmali ile
        aynı formül. ⚠: bankonun talepsiz verdiği ve onay eşiğini aşan iskonto. Ciroya oranı %{o.ciroOrani.toFixed(2).replace('.', ',')}.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Başhekim / İç Denetim<br />Kaşe · İmza</div></div>
    </div>
  );
}
