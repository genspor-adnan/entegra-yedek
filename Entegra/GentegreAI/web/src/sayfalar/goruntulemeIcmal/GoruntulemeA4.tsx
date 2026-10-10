import type { GoruntulemeIcmali } from '../../api/uclar/goruntulemeIcmal';
import { AntetLogo } from '../../bilesenler/AntetLogo';
import { para, paraYaz } from '../../bilesenler/bicim';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { sure, yuzde } from '../labIcmal/labIcmalOrtak';

/**
 * A4 GÖRÜNTÜLEME DÖNEM İCMALİ. Modalite tablosu (seçili modalite varsa
 * yalnız onlar). Hasta bilgisi basılmaz.
 */
export function GoruntulemeA4({ v, antet, duzenleyen, secili, suzgec }: {
  v: GoruntulemeIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[]; suzgec: string;
}) {
  const p = (n: number) => para.format(n);
  const o = v.ozet;
  const modaliteler = secili.length ? v.modaliteler.filter(m => secili.includes(m.modalite)) : v.modaliteler;
  return (
    <div className="hi-a4">
      <div className="a4-bas">
        <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
        <div><div className="kurum">{String(antet?.unvan ?? '')}</div>
          <div className="kurum-alt">{[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), antet?.telefon]
            .filter(x => x && String(x).trim()).join(' · ')}</div></div>
        <div className="a4-tarih">Düzenleme: {new Date().toLocaleString('tr-TR')}<br />Düzenleyen: {duzenleyen}</div>
      </div>
      <h3>GÖRÜNTÜLEME DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Çekim: {o.cekim} · {o.hasta} hasta</span><span>{suzgec}{secili.length ? ' · seçili modaliteler' : ''}</span>
      </div>
      <table className="a4-t lb-a4t">
        <thead><tr><th>Modalite</th><th>Çekim</th><th>Ciro</th><th>Kurum Payı</th><th>Kontrast / Sarf</th><th>Telerad</th><th>Brüt Kâr</th><th>Ort. Rapor</th></tr></thead>
        <tbody>
          {modaliteler.map(m => (
            <tr key={m.modalite}><td>{m.ad}</td><td>{m.cekim}</td><td>{p(m.ciro)}</td><td>{p(m.kurum)}</td><td>{p(m.sarf)}</td>
              <td>{p(m.telerad)}</td><td>{p(m.kar)}</td><td>{sure(m.ortRapor)}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Ciro</td><td>{paraYaz(o.ciro)}</td></tr>
        <tr><td>Kontrast / sarf</td><td>{paraYaz(o.sarf)}</td></tr>
        <tr><td>Teleradyoloji (giden)</td><td>{paraYaz(o.teleradMaliyet)}</td></tr>
        <tr className="kalan ki-kalan"><td>BRÜT KÂR ({yuzde(o.marj)})</td><td>{paraYaz(o.kar)}</td></tr>
      </tbody></table>
      <p className="a4-not">Ort. rapor süresi: {sure(o.ortRapor)} · hedef aşan: {o.asan} · rapor bekleyen: {o.bekleyen} ·
        cihaz doluluğu: {yuzde(o.doluluk)} · gelen teleradyoloji: {o.gelen} çekim, {paraYaz(o.gelenGelir)} (ciroya dahil değildir).
        Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Radyoloji Sorumlusu · İmza</div><div>Onaylayan<br />Mesul Müdür · İmza</div></div>
    </div>
  );
}
