import type { MedulaMutabakati } from '../../../api/uclar/medulaMutabakat';
import { IcmalAntet } from '../../../bilesenler/cikti/IcmalAntet';
import { paraYaz } from '../../../bilesenler/bicim';
import { tarihKisa } from '../../hasta/icmal/icmalOrtak';
import { AY_ADLARI, donemDurumRozeti } from './mutabakatOrtak';

/**
 * A4 SGK DÖNEM MUTABAKAT TUTANAĞI - mali işler / SGK mutabakatı için.
 * Ekranda önizleme sekmesinde, yazdırınca yalnız bu basılır (hasta icmaliyle
 * aynı `@media print` kuralı). Hasta adı yok: tutanak dönem toplamıdır.
 */
export function MutabakatA4({ v, antet, duzenleyen }: {
  v: MedulaMutabakati; antet: Record<string, unknown> | null; duzenleyen: string;
}) {
  const o = v.ozet;
  const d = v.donem;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>SGK DÖNEM MUTABAKAT TUTANAĞI</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{AY_ADLARI[v.ay - 1]} {v.yil}</b></span>
        <span>Dönem durumu: {d ? donemDurumRozeti(d.durum).ad : 'oluşturulmadı'}</span>
        <span>İcmal No: {d?.icmalNo || '—'}</span>
        <span>Sonlandırma: {d?.sonlandirma ? tarihKisa(d.sonlandirma) : '—'}</span>
      </div>
      <table className="a4-t mm-a4t">
        <thead><tr><th>Adım</th><th>Takip</th><th>Tutar (HBYS)</th></tr></thead>
        <tbody>
          {v.huni.map((a, i) => <tr key={a.kod}><td>{i + 1}. {a.ad}</td><td>{a.adet}</td><td>{paraYaz(a.tutar)}</td></tr>)}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Faturalanan (HBYS tutarı)</td><td>{paraYaz(o.faturaliYerel)}</td></tr>
        <tr><td>Medula'nın kabul ettiği</td><td>{paraYaz(o.medulaTutar)}</td></tr>
        <tr><td>HBYS - Medula farkı ({o.farkli} fatura)</td><td>{paraYaz(o.farkTutari)}</td></tr>
        <tr><td>Kesinti (iade düşülmüş)</td><td>{o.kesinti > 0.005 ? `−${paraYaz(o.kesinti)}` : paraYaz(0)}</td></tr>
        <tr><td>Ödenen{d?.odemeTarihi ? ` (${tarihKisa(d.odemeTarihi)})` : ''}</td><td>{paraYaz(o.odenen)}</td></tr>
        <tr><td>Faturasız takip ({o.faturasiz})</td><td>{paraYaz(o.faturasizTutar)}</td></tr>
        <tr className="kalan ki-kalan"><td>SGK'DAN AÇIK ALACAK</td><td>{paraYaz(o.acik)}</td></tr>
      </tbody></table>
      <p className="a4-not">Açık alacak = Medula'nın kabul ettiği tutar − kesinti − ödenen. Faturasız takipler ve
        HBYS - Medula farkı alacağa dahil değildir; tahsil edilemeyen gelir riskidir.</p>
      <div className="a4-imza"><div>Medula Sorumlusu<br />Ad Soyad · İmza</div><div>Mali İşler<br />Kaşe · İmza</div></div>
    </div>
  );
}
