import type { KurumIcmali } from '../../../api/uclar/kurumIcmal';
import { IcmalAntet } from '../../../bilesenler/cikti/IcmalAntet';
import { para, paraYaz } from '../../../bilesenler/bicim';
import { tarihKisa } from '../../hasta/icmal/icmalOrtak';

/**
 * A4 KURUM HİZMET İCMALİ - fatura ekine konur. Ekranda önizleme sekmesinde,
 * yazdırınca yalnız bu basılır (hasta icmaliyle aynı `@media print` kuralı).
 * Kurumdan istenen = kurum payı - kesinti; hasta payları dahil değildir.
 * Reddedilen provizyon (kurum payı 0) belgede yer almaz.
 */
export function KurumIcmalA4({ v, antet, duzenleyen, kurumAdi }: {
  v: KurumIcmali; antet: Record<string, unknown> | null; duzenleyen: string; kurumAdi: string;
}) {
  const o = v.ozet;
  const p = (n: number) => para.format(n);
  const satirlar = v.basvurular.filter(b => b.kurumPayi > 0.005);
  const fatura = v.icmaller.find(i => i.belgeId);
  const tekKurum = v.kurumId > 0;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>KURUM HİZMET İCMALİ</h3>
      <div className="a4-hasta">
        <span>Kurum: <b>{kurumAdi}</b></span><span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        {tekKurum && <span>Kurum VKN: {v.cari?.vkn || '—'}</span>}
        <span>Fatura: {fatura ? `${fatura.faturaNo} · ${tarihKisa(fatura.faturaTarihi)}` : 'kesilmedi'}</span>
        <span>Başvuru: {satirlar.length}{o.red ? ` (+${o.red} red, dahil değil)` : ''}</span>
      </div>
      <table className="a4-t ki-a4t">
        <thead><tr><th>Tarih</th><th>Protokol No</th><th>Hasta</th><th>Poliçe / Provizyon</th>
          {!tekKurum && <th>Kurum</th>}<th>Toplam</th><th>Kurum</th><th>Kesinti</th><th>Net</th></tr></thead>
        <tbody>
          {satirlar.map(b => (
            <tr key={b.id}><td>{tarihKisa(b.tarih)}</td><td>{b.protokolNo}</td><td>{b.hasta}</td>
              <td>{b.provizyonNo || '—'}</td>{!tekKurum && <td>{b.kurum}</td>}
              <td>{p(b.toplam)}</td><td>{p(b.kurumPayi)}</td><td>{b.kesinti > 0.005 ? p(b.kesinti) : '—'}</td><td>{p(b.net)}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Toplam hizmet</td><td>{paraYaz(satirlar.reduce((t, b) => t + b.toplam, 0))}</td></tr>
        <tr><td>Kurum payı</td><td>{paraYaz(o.kurumPayi)}</td></tr>
        <tr><td>Kesinti</td><td>{o.kesinti > 0.005 ? `−${paraYaz(o.kesinti)}` : paraYaz(0)}</td></tr>
        <tr className="kalan ki-kalan"><td>KURUMDAN TALEP EDİLEN</td><td>{paraYaz(o.net)}</td></tr>
      </tbody></table>
      <p className="a4-not">Hasta payları hastalardan ayrıca tahsil edilir ve bu icmale dahil değildir.
        Tutarlar KDV dahil başvuru toplamlarından hesaplanmıştır; faturadaki KDV dökümü esastır.</p>
      <div className="a4-imza"><div>Düzenleyen<br />Kurum İşleri · İmza</div><div>Mesul Müdür<br />Kaşe · İmza</div></div>
    </div>
  );
}
