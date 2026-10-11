import type { CagriIcmali } from '../../api/uclar/cagriIcmal';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { sureMetni, yuzde } from './cagriIcmalOrtak';

/**
 * A4 ÇAĞRI MERKEZİ DÖNEM İCMALİ. Kuyruk (seçiliyse yalnız onlar) ve
 * temsilci tabloları, özet. Arayan kimliği ve telefon basılmaz.
 */
export function CagriA4({ v, antet, duzenleyen, secili }: {
  v: CagriIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const o = v.ozet;
  const kuyruklar = secili.length ? v.kuyruklar.filter(k => secili.includes(k.id)) : v.kuyruklar;
  const kampanyaKisi = v.kampanyalar.reduce((t, k) => t + k.kisi, 0);
  const kampanyaOnay = v.kampanyalar.reduce((t, k) => t + k.onay, 0);
  const kampanyaUlasilan = v.kampanyalar.reduce((t, k) => t + k.ulasilan, 0);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>ÇAĞRI MERKEZİ DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Gelen: {o.gelen} · Cevaplanan: {o.cevaplanan}</span>
        <span>Giden: {o.giden} · Temsilci: {o.temsilci}</span><span>{secili.length ? `Seçili ${kuyruklar.length} kuyruk` : 'Tüm kuyruklar'}</span>
      </div>
      <table className="a4-t cm-a4t">
        <thead><tr><th>Kuyruk</th><th>Gelen</th><th>Cevaplanan</th><th>Terk</th><th>Sesli</th><th>SLA</th><th>Ort. Bekleme</th><th>Randevu</th></tr></thead>
        <tbody>
          {kuyruklar.map(k => (
            <tr key={k.id}><td>{k.ad}</td><td>{k.ozet.gelen}</td><td>{k.ozet.cevaplanan}</td><td>{k.ozet.terk}</td><td>{k.ozet.sesli}</td>
              <td>{yuzde(k.ozet.sla)}</td><td>{sureMetni(k.ozet.ortBekleme)}</td><td>{k.ozet.randevu}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-t cm-a4t">
        <thead><tr><th>Temsilci</th><th>Gelen</th><th>Giden</th><th>Ort. Görüşme</th><th>Randevu</th><th>Geri Arama Zamanında</th><th>Kalite</th></tr></thead>
        <tbody>
          {v.temsilciler.map(t => {
            const ist = t.geriZamaninda + t.geriGec + t.geriYok;
            return (
              <tr key={t.id}><td>{t.ad}</td><td>{t.gelen}</td><td>{t.giden}</td><td>{sureMetni(t.ortGorusme)}</td><td>{t.randevu}</td>
                <td>{ist ? yuzde(100 * t.geriZamaninda / ist) : '—'}</td><td>{t.kalite != null ? t.kalite.toLocaleString('tr-TR') : '—'}</td></tr>
            );
          })}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Cevaplanma oranı</td><td>{yuzde(o.cevapOrani)}</td></tr>
        <tr><td>SLA (hedef %{o.slaHedef})</td><td>{yuzde(o.sla)}</td></tr>
        <tr><td>Ortalama bekleme / görüşme</td><td>{sureMetni(o.ortBekleme)} / {sureMetni(o.ortGorusme)}</td></tr>
        <tr><td>Geri arama zamanında</td><td>{yuzde(o.geriOran)}</td></tr>
        <tr className="kalan ki-kalan"><td>RANDEVUYA DÖNÜŞME</td><td>{yuzde(o.donusum)}</td></tr>
      </tbody></table>
      <p className="a4-not">Kampanya: {kampanyaKisi} kişi, {kampanyaOnay} onay ({yuzde(kampanyaUlasilan ? 100 * kampanyaOnay / kampanyaUlasilan : null)} başarı).
        Arayan kimliği ve telefon numarası bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Çağrı Merkezi Sorumlusu · İmza</div><div>Onaylayan<br />Hasta Hizmetleri Müdürü · İmza</div></div>
    </div>
  );
}
