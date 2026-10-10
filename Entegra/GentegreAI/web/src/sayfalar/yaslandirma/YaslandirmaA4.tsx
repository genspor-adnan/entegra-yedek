import type { AlacakYaslandirma } from '../../api/uclar/alacakYaslandirma';
import { AntetLogo } from '../../bilesenler/AntetLogo';
import { para, paraYaz } from '../../bilesenler/bicim';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';

/**
 * A4 ALACAK YAŞLANDIRMA RAPORU - yönetime verilir. Ekranda önizleme
 * sekmesinde, yazdırınca yalnız bu basılır (hasta icmaliyle aynı `@media
 * print` kuralı). Seçili kurum / hasta varsa yalnız onlar; TC basılmaz.
 */
export function YaslandirmaA4({ v, antet, duzenleyen, seciliKurum, seciliHasta }: {
  v: AlacakYaslandirma; antet: Record<string, unknown> | null; duzenleyen: string;
  seciliKurum: number[]; seciliHasta: number[];
}) {
  const p = (n: number) => para.format(n);
  const secimVar = seciliKurum.length + seciliHasta.length > 0;
  const kurumlar = secimVar ? v.kurumlar.filter(k => seciliKurum.includes(k.id)) : v.kurumlar;
  const hastalar = secimVar ? v.hastalar.filter(h => seciliHasta.includes(h.id)) : v.hastalar;
  const satirlar = [
    // Yayılım ÖNCE: anahtar ve tür metni kaydın sayısal id / tur alanını ezmesin.
    ...kurumlar.map(k => ({ ...k, anahtar: `k${k.id}`, turMetni: 'Kurum' })),
    ...hastalar.map(h => ({ ...h, anahtar: `h${h.id}`, turMetni: `Hasta · ${h.dosyaNo || '—'}` })),
  ];
  const t = (f: (x: typeof satirlar[number]) => number) => satirlar.reduce((s, x) => s + f(x), 0);
  return (
    <div className="hi-a4">
      <div className="a4-bas">
        <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
        <div><div className="kurum">{String(antet?.unvan ?? '')}</div>
          <div className="kurum-alt">{[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), antet?.telefon]
            .filter(x => x && String(x).trim()).join(' · ')}</div></div>
        <div className="a4-tarih">Düzenleme: {new Date().toLocaleString('tr-TR')}<br />Düzenleyen: {duzenleyen}</div>
      </div>
      <h3>ALACAK YAŞLANDIRMA RAPORU</h3>
      <div className="a4-hasta">
        <span>Referans tarihi: <b>{tarihKisa(v.tarih)}</b></span>
        <span>Taraf: {kurumlar.length} kurum · {hastalar.length} hasta{secimVar ? ' (seçili)' : ''}</span>
        <span>En eski alacak: {v.ozet.enEskiGun} gün</span><span>Ortalama: {v.ozet.ortGun} gün</span>
      </div>
      <table className="a4-t yz-a4t">
        <thead><tr><th>Taraf</th><th>Tür</th><th>0–30</th><th>31–60</th><th>61–90</th><th>90+</th><th>Toplam</th></tr></thead>
        <tbody>
          {satirlar.map(x => (
            <tr key={x.anahtar}><td>{x.ad}</td><td>{x.turMetni}</td><td>{p(x.d0)}</td><td>{p(x.d30)}</td>
              <td>{p(x.d60)}</td><td>{p(x.d90)}</td><td>{p(x.toplam)}</td></tr>
          ))}
          <tr className="yz-top"><td colSpan={2}>Toplam</td><td>{p(t(x => x.d0))}</td><td>{p(t(x => x.d30))}</td>
            <td>{p(t(x => x.d60))}</td><td>{p(t(x => x.d90))}</td><td>{p(t(x => x.toplam))}</td></tr>
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Kurum alacağı</td><td>{paraYaz(kurumlar.reduce((s, k) => s + k.toplam, 0))}</td></tr>
        <tr><td>&nbsp;· faturalanmamış kurum payı</td><td>{paraYaz(kurumlar.reduce((s, k) => s + k.faturasiz, 0))}</td></tr>
        <tr><td>Hasta alacağı</td><td>{paraYaz(hastalar.reduce((s, h) => s + h.toplam, 0))}</td></tr>
        <tr className="kalan ki-kalan"><td>TOPLAM ALACAK</td><td>{paraYaz(t(x => x.toplam))}</td></tr>
      </tbody></table>
      <p className="a4-not">Gün = referans tarihi − açık belgenin tarihi. Kurum alacağı: ödenmemiş fatura / tahakkuk (tahsilat
        önce en eski belgeyi kapatır) + faturalanmamış kurum payı. Hasta alacağı: başvuru başına hasta payı − tahsilat.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali İşler<br />Kaşe · İmza</div></div>
    </div>
  );
}
