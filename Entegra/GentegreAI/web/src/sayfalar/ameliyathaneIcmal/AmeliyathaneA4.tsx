import type { AmeliyathaneIcmali } from '../../api/uclar/ameliyathaneIcmal';
import { para, paraYaz } from '../../bilesenler/bicim';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { sureMetni, yuzde } from './ameliyathaneIcmalOrtak';

/**
 * A4 AMELİYATHANE DÖNEM İCMALİ. Salon tablosu (seçiliyse yalnız onlar),
 * ciro / sarf / implant / brüt kâr özeti. Hasta bilgisi basılmaz.
 */
export function AmeliyathaneA4({ v, antet, duzenleyen, secili }: {
  v: AmeliyathaneIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const o = v.ozet;
  const p = (n: number) => para.format(n);
  const salonlar = secili.length ? v.salonlar.filter(s => secili.includes(s.id)) : v.salonlar;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>AMELİYATHANE DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Ameliyat: {o.ameliyat} · plan dışı {o.planDisi}</span>
        <span>İptal / ertelenen: {o.iptal} / {o.ertelenen}</span>
        <span>{secili.length ? `Seçili ${salonlar.length} salon` : 'Tüm salonlar'}</span>
      </div>
      <table className="a4-t am-a4t">
        <thead><tr><th>Salon</th><th>Vaka</th><th>Doluluk</th><th>Ort. Süre</th><th>İlk Vaka</th><th>Ort. Devir</th><th>Ciro</th></tr></thead>
        <tbody>
          {salonlar.map(s => (
            <tr key={s.id}><td>{s.ad}{s.brans ? ` · ${s.brans}` : ''}</td><td>{s.vaka}</td><td>{yuzde(s.doluluk)}</td><td>{sureMetni(s.ortSureDk)}</td>
              <td>{s.ilkVaka ? `${s.ilkVakaZamaninda}/${s.ilkVaka}` : '—'}</td><td>{sureMetni(s.ortDevirDk)}</td><td>{p(s.ciro)}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Ciro</td><td>{paraYaz(o.ciro)}</td></tr>
        <tr><td>Sarf</td><td>{paraYaz(o.sarf)}</td></tr>
        <tr><td>İmplant</td><td>{paraYaz(o.implant)}</td></tr>
        <tr className="kalan ki-kalan"><td>BRÜT KÂR ({yuzde(o.marj)})</td><td>{paraYaz(o.brutKar)}</td></tr>
      </tbody></table>
      <p className="a4-not">Salon doluluğu {yuzde(o.doluluk)} (mesai içi) · ortalama süre {sureMetni(o.ortSureDk)}, plana göre {yuzde(o.sapma)} ·
        ilk vaka zamanında {yuzde(o.ilkVakaOrani)} · ortalama salon devri {sureMetni(o.ortDevirDk)} · faturaya girmeyen sarf {paraYaz(o.faturasizTutar)}.
        {' '}Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ameliyathane Sorumlusu · İmza</div><div>Onaylayan<br />Başhekim · İmza</div></div>
    </div>
  );
}
