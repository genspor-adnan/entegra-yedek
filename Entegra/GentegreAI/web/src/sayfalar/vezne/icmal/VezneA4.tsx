import type { VezneIcmali } from '../../../api/uclar/vezneIcmal';
import { IcmalAntet } from '../../../bilesenler/cikti/IcmalAntet';
import { para, paraYaz } from '../../../bilesenler/bicim';
import { tarihKisa } from '../../hasta/icmal/icmalOrtak';
import { saat } from './vezneOrtak';

/**
 * A4 GÜNLÜK VEZNE İCMALİ - mali işlere verilir. Ekranda önizleme sekmesinde,
 * yazdırınca yalnız bu basılır (hasta icmaliyle aynı `@media print` kuralı).
 * Seçili oturumlar varsa yalnız onlar.
 */
export function VezneA4({ v, antet, duzenleyen, gunlu }: {
  v: VezneIcmali; antet: Record<string, unknown> | null; duzenleyen: string; gunlu: boolean;
}) {
  const o = v.ozet;
  const p = (n: number) => para.format(n);
  const satirlar = v.oturumlar.filter(x => !v.secili.length || v.secili.includes(x.id));
  const donem = v.donem.bas === v.donem.bit ? tarihKisa(v.donem.bas) : `${tarihKisa(v.donem.bas)} - ${tarihKisa(v.donem.bit)}`;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>GÜNLÜK VEZNE İCMALİ</h3>
      <div className="a4-hasta">
        <span>Tarih: <b>{donem}</b></span><span>Oturum: {satirlar.length} · {new Set(satirlar.map(x => x.bankoId)).size} banko</span>
        <span>Makbuz: {o.makbuz}</span>
        <span>Açık / onay bekleyen oturum: {o.acik} / {o.onayBekleyen}</span>
      </div>
      <table className="a4-t vz-a4t">
        <thead><tr><th>Banko</th><th>Görevli</th><th>Saat</th><th>Nakit</th><th>POS</th><th>Havale</th>
          <th>İade</th><th>Net</th><th>Sayım</th><th>Fark</th></tr></thead>
        <tbody>
          {satirlar.map(x => (
            <tr key={x.id}><td>{x.banko || x.bankoKod}</td><td>{x.gorevli}</td>
              <td>{saat(x.acilis, gunlu)}–{x.kapanis ? saat(x.kapanis, gunlu) : 'açık'}</td>
              <td>{p(x.nakit)}</td><td>{p(x.pos)}</td><td>{p(x.havale + x.diger)}</td>
              <td>{x.iade > 0.005 ? `−${p(x.iade)}` : '—'}</td><td>{p(x.net)}</td>
              <td>{x.sayim != null ? p(x.sayim) : '—'}</td><td>{x.fark != null ? p(x.fark) : '—'}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Nakit tahsilat</td><td>{paraYaz(o.nakit)}</td></tr>
        <tr><td>POS</td><td>{paraYaz(o.pos)}</td></tr>
        <tr><td>Havale / EFT ve diğer</td><td>{paraYaz(o.havale + o.diger)}</td></tr>
        <tr><td>İade</td><td>{o.iade > 0.005 ? `−${paraYaz(o.iade)}` : paraYaz(0)}</td></tr>
        <tr><td>Kasa sayım farkı</td><td>{paraYaz(o.kasaFarki)}</td></tr>
        <tr><td>POS farkı (cihaz − kasa)</td><td>{paraYaz(o.posFarki)}</td></tr>
        <tr><td>Merkez kasaya devredilen</td><td>{paraYaz(o.devredilen)}</td></tr>
        <tr className="kalan ki-kalan"><td>NET TAHSİLAT</td><td>{paraYaz(o.net)}</td></tr>
      </tbody></table>
      <p className="a4-not">POS ve havale kasada durmaz; merkez kasaya yalnız sayılan nakit devredilir.
        İptal makbuzlar ve fark fişleri toplamlara girmez.</p>
      <div className="a4-imza"><div>Vezne Sorumlusu<br />Ad Soyad · İmza</div><div>Mali İşler<br />Kaşe · İmza</div></div>
    </div>
  );
}
