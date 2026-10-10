import type { LabIcmali } from '../../api/uclar/labIcmal';
import { AntetLogo } from '../../bilesenler/AntetLogo';
import { para, paraYaz } from '../../bilesenler/bicim';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { sure, yuzde } from './labIcmalOrtak';

/**
 * A4 LABORATUVAR DÖNEM İCMALİ. Grup tablosu; tetkik seçiliyse seçili
 * tetkikler de listelenir. Hasta kimlik bilgisi basılmaz.
 */
export function LabA4({ v, antet, duzenleyen, secili, suzgec }: {
  v: LabIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: string[]; suzgec: string;
}) {
  const p = (n: number) => para.format(n);
  const o = v.ozet;
  const tetkikler = v.tetkikler.filter(t => secili.includes(t.anahtar));
  return (
    <div className="hi-a4">
      <div className="a4-bas">
        <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
        <div><div className="kurum">{String(antet?.unvan ?? '')}</div>
          <div className="kurum-alt">{[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), antet?.telefon]
            .filter(x => x && String(x).trim()).join(' · ')}</div></div>
        <div className="a4-tarih">Düzenleme: {new Date().toLocaleString('tr-TR')}<br />Düzenleyen: {duzenleyen}</div>
      </div>
      <h3>LABORATUVAR DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Tetkik: {o.tetkik} · {o.hasta} hasta</span><span>{suzgec}</span>
      </div>
      <table className="a4-t lb-a4t">
        <thead><tr><th>Tetkik Grubu</th><th>Adet</th><th>Ciro</th><th>Kurum Payı</th><th>Hasta Payı</th><th>Maliyet</th><th>Brüt Kâr</th></tr></thead>
        <tbody>
          {v.gruplar.map(g => (
            <tr key={g.grup}><td>{g.ad}</td><td>{g.adet}</td><td>{p(g.ciro)}</td><td>{p(g.kurum)}</td><td>{p(g.hasta)}</td>
              <td>{p(g.maliyet)}</td><td>{p(g.kar)}</td></tr>
          ))}
        </tbody>
      </table>
      {tetkikler.length > 0 && (
        <table className="a4-t lb-a4t">
          <thead><tr><th>Seçili Tetkik</th><th>Adet</th><th>Ciro</th><th>Maliyet</th><th>Ort. TAT</th><th>Tekrar</th><th>Aşan</th></tr></thead>
          <tbody>
            {tetkikler.map(t => (
              <tr key={t.anahtar}><td>{t.kod} {t.ad}</td><td>{t.adet}</td><td>{p(t.ciro)}</td><td>{p(t.maliyet)}</td>
                <td>{t.dis ? '—' : sure(t.ortTat)}</td><td>{t.tekrar}</td><td>{t.asan}</td></tr>
            ))}
          </tbody>
        </table>
      )}
      <table className="a4-toplam"><tbody>
        <tr><td>Ciro</td><td>{paraYaz(o.ciro)}</td></tr>
        <tr><td>Reaktif / kit (iç lab)</td><td>{paraYaz(o.reaktif)}</td></tr>
        <tr><td>Dış laboratuvar maliyeti</td><td>{paraYaz(o.disMaliyet)}</td></tr>
        <tr className="kalan ki-kalan"><td>BRÜT KÂR ({yuzde(o.marj)})</td><td>{paraYaz(o.kar)}</td></tr>
      </tbody></table>
      <p className="a4-not">Ort. sonuç süresi (rutin): {sure(o.ortTat)} · Hedef aşan tetkik: {o.asan} · Tekrar: {o.tekrar} ({yuzde(o.tekrarOrani)}) ·
        Numune ret: {o.ret} / {o.numune} ({yuzde(o.retOrani)}). QC / kalibrasyon sarfı brüt kâra dahil değildir.
        {o.maliyetsiz > 0 && ` ${o.maliyetsiz} iç lab kaleminde test başı maliyet tanımsızdır (maliyet 0 sayıldı).`} Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Laboratuvar Sorumlusu · İmza</div><div>Onaylayan<br />Mesul Müdür · İmza</div></div>
    </div>
  );
}
