import type { DisIcmali } from '../../api/uclar/disIcmal';
import { para } from '../../bilesenler/bicim';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { yuzde, yuzdeTam } from './disIcmalOrtak';

const p = (n: number) => para.format(n);

/**
 * A4 DİŞ DÖNEM İCMALİ. Hekim tablosu (seçiliyse yalnız onlar), ciro / sarf /
 * lab / brüt kâr toplamı, plan özeti. Hasta bilgisi basılmaz.
 */
export function DisA4({ v, antet, duzenleyen, secili }: {
  v: DisIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const o = v.ozet;
  const hekimler = secili.length ? v.hekimler.filter(h => secili.includes(h.id)) : v.hekimler;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>DİŞ DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Seans: {o.seans} · {o.hasta} hasta</span>
        <span>Ünite doluluğu: {yuzde(o.uniteDoluluk)}</span><span>{secili.length ? `Seçili ${hekimler.length} hekim` : 'Tüm hekimler'}</span>
      </div>
      <table className="a4-t ds-a4t">
        <thead><tr><th>Hekim</th><th>Seans</th><th>İşlem</th><th>Ciro</th><th>Sarf + Lab</th><th>Brüt Kâr</th><th>Plan Kabul</th></tr></thead>
        <tbody>
          {hekimler.map(h => (
            <tr key={h.id}><td>{h.ad}</td><td>{h.seans}</td><td>{h.islem}</td><td>{p(h.ciro)}</td><td>{p(h.sarfLab)}</td><td>{p(h.kar)}</td>
              <td>{yuzdeTam(h.planKabul)}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Ciro</td><td>{p(o.ciro)} ₺</td></tr>
        <tr><td>Sarf</td><td>{p(o.sarf)} ₺</td></tr>
        <tr><td>Laboratuvar</td><td>{p(o.lab)} ₺</td></tr>
        <tr className="kalan ki-kalan"><td>BRÜT KÂR ({yuzde(o.marj)})</td><td>{p(o.kar)} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Tedavi planı: {o.planSunulan} sunulan, {o.planKabul} kabul ({yuzdeTam(o.kabulYuzde)}), {o.planTamam} tamamlandı.
        {' '}Yarım kalan: {o.yarimAdet} plan, kalan tutar {p(o.yarimKalan)} ₺. Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Klinik Sorumlusu · İmza</div><div>Onaylayan<br />Mesul Müdür · İmza</div></div>
    </div>
  );
}
