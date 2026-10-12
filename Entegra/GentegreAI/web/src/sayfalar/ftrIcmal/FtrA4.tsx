import type { FtrIcmali } from '../../api/uclar/ftrIcmal';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { para, paraYaz } from '../../bilesenler/bicim';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { ondalik, vasFark, yuzde } from './ftrIcmalOrtak';

/**
 * A4 FİZİK TEDAVİ DÖNEM İCMALİ. Fizyoterapist (seçiliyse yalnız onlar) ve
 * ödeyen tabloları, ciro / kurum / hasta payı. Hasta bilgisi basılmaz.
 */
export function FtrA4({ v, antet, duzenleyen, secili, suzgec }: {
  v: FtrIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[]; suzgec: string;
}) {
  const p = (n: number) => para.format(n);
  const o = v.ozet;
  const fztler = secili.length ? v.fizyoterapistler.filter(f => secili.includes(f.id)) : v.fizyoterapistler;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>FİZİK TEDAVİ DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Kür: {o.kur} · seans: {o.seans}</span><span>Devam oranı: {yuzde(o.devam)}</span>
        <span>{suzgec}{secili.length ? ` · seçili ${fztler.length} fizyoterapist` : ''}</span>
      </div>
      <table className="a4-t ft-a4t">
        <thead><tr><th>Fizyoterapist</th><th>Kür</th><th>Seans</th><th>Gelmedi</th><th>Devam</th><th>Ciro</th></tr></thead>
        <tbody>
          {fztler.map(f => (
            <tr key={f.id}><td>{f.ad}</td><td>{f.kur}</td><td>{f.seans}</td><td>{f.gelmedi}</td><td>{yuzde(f.devam)}</td><td>{p(f.ciro)}</td></tr>
          ))}
        </tbody>
      </table>
      {v.odeyenler.length > 0 && (
        <table className="a4-t ft-a4t">
          <thead><tr><th>Ödeyen</th><th>Kür</th><th>Seans</th><th>Ciro</th><th>Kurum Payı</th><th>Hasta Payı</th></tr></thead>
          <tbody>
            {v.odeyenler.map(x => (
              <tr key={x.kod}><td>{x.ad}</td><td>{x.kur}</td><td>{x.seans}</td><td>{p(x.ciro)}</td><td>{p(x.kurum)}</td><td>{p(x.hasta)}</td></tr>
            ))}
          </tbody>
        </table>
      )}
      <table className="a4-toplam"><tbody>
        <tr><td>Ciro</td><td>{paraYaz(o.ciro)}</td></tr>
        <tr><td>Kurum payı</td><td>{paraYaz(o.kurum)}</td></tr>
        <tr className="kalan ki-kalan"><td>HASTA PAYI</td><td>{paraYaz(o.hasta)}</td></tr>
      </tbody></table>
      <p className="a4-not">Tamamlanan {o.biten} kürde iyi yanıt {yuzde(o.iyiYanit)}, ortalama VAS değişimi {vasFark(o.vasDusus)} puan;
        kür başı ortalama {ondalik(o.kurBasiSeans)} seans. Yarıda bırakılan kür: {o.yarida}. Kabin doluluğu: {yuzde(o.kabinDoluluk)}.
        {' '}Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />FTR Sorumlusu · İmza</div><div>Onaylayan<br />Mesul Müdür · İmza</div></div>
    </div>
  );
}
