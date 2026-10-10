import type { Borclu } from '../../api/uclar/hastaBorc';
import { AntetLogo } from '../../bilesenler/AntetLogo';
import { para, paraYaz } from '../../bilesenler/bicim';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';

/**
 * A4 BORÇ BİLDİRİM MEKTUBU - seçili hastaya (birden çok seçiliyse her biri
 * ayrı sayfada). Yazdırınca yalnız bu basılır (icmallerle aynı `@media print`
 * kuralı). TC basılmaz: ad + dosya no.
 */
export function BorcMektubu({ hastalar, antet, duzenleyen }: {
  hastalar: Borclu[]; antet: Record<string, unknown> | null; duzenleyen: string;
}) {
  const p = (n: number) => para.format(n);
  const kurum = String(antet?.unvan ?? '');
  const tel = String(antet?.telefon ?? '');
  if (hastalar.length === 0) return <div className="ki-not">Mektup için Borçlular sekmesinde hasta seçin.</div>;
  return (
    <div className="hi-a4 bm-a4">
      {hastalar.map((h, i) => (
        <div key={h.id} className={'bm-sayfa' + (i > 0 ? ' bm-yeni' : '')}>
          <div className="a4-bas">
            <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
            <div><div className="kurum">{kurum}</div>
              <div className="kurum-alt">{[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), tel]
                .filter(x => x && String(x).trim()).join(' · ')}</div></div>
            <div className="a4-tarih">Tarih: {new Date().toLocaleDateString('tr-TR')}<br />Düzenleyen: {duzenleyen}</div>
          </div>
          <h3>BORÇ BİLDİRİM MEKTUBU</h3>
          <p>Sayın <b>{h.ad}</b>{h.dosyaNo && ` (Dosya No: ${h.dosyaNo})`},</p>
          <p>Kurumumuzda aldığınız sağlık hizmetlerine ait aşağıdaki tutarlar henüz ödenmemiştir. Toplam
            <b> {paraYaz(h.borc)}</b> tutarındaki bakiyenin ödenmesini ya da ödeme planı için bizimle
            iletişime geçmenizi rica ederiz.</p>
          <table className="a4-t bm-t">
            <thead><tr><th>Protokol No</th><th>Tarih</th><th>Bölüm</th><th>Hasta Payı</th><th>Ödenen</th><th>Kalan</th></tr></thead>
            <tbody>
              {h.protokoller.map(x => (
                <tr key={x.belgeId}><td>{x.protokolNo}</td><td>{tarihKisa(x.tarih)}</td><td>{x.bolum || '—'}</td>
                  <td>{p(x.hastaPayi)}</td><td>{p(x.tahsil)}</td><td>{p(x.kalan)}</td></tr>
              ))}
            </tbody>
          </table>
          <table className="a4-toplam"><tbody>
            <tr className="kalan"><td>ÖDENECEK TOPLAM</td><td>{paraYaz(h.borc)}</td></tr>
          </tbody></table>
          <p className="a4-not">Ödemenizi kurumumuz veznesinden yapabilirsiniz{tel ? `; bilgi için ${tel}` : ''}.
            Bu mektup gönderildiği tarihte ödeme yaptıysanız lütfen dikkate almayınız.</p>
          <div className="a4-imza"><div>Hasta / Yakını<br />Tebellüğ · İmza</div><div>{kurum || 'Kurum'}<br />Vezne · Kaşe · İmza</div></div>
        </div>
      ))}
    </div>
  );
}
