import type { YatanIcmali } from '../../api/uclar/yatanIcmal';
import { para, paraYaz } from '../../bilesenler/bicim';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { gunMetni } from './yatanIcmalOrtak';

/**
 * A4 YATAN HASTA DÖNEM İCMALİ. Servis tablosu (seçili servis varsa yalnız
 * onlar) ve özet. Hasta kimlik bilgisi basılmaz.
 */
export function YatanA4({ v, antet, duzenleyen, secili }: {
  v: YatanIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const p = (n: number) => para.format(n);
  const o = v.ozet;
  const servisler = secili.length ? v.servisler.filter(s => secili.includes(s.id)) : v.servisler;
  const yuzde = (d: number | null | undefined) => (d == null ? '—' : `%${d.toFixed(1).replace('.', ',')}`);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>YATAN HASTA DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Yatak: {v.toplamYatak} · {v.servisler.length} servis{secili.length ? ' (seçili)' : ''}</span>
        <span>Yatış / taburcu: {o.yatis} / {o.taburcu}</span><span>Hasta-gün: {o.hastaGun}</span>
      </div>
      <table className="a4-t yh-a4t">
        <thead><tr><th>Servis</th><th>Yatak</th><th>Yatış</th><th>Taburcu</th><th>Hasta-Gün</th><th>Doluluk</th><th>ALOS</th><th>Ciro</th><th>Açık Hesap</th></tr></thead>
        <tbody>
          {servisler.map(s => (
            <tr key={s.id}><td>{s.ad}</td><td>{s.ozet.yatak}</td><td>{s.ozet.yatis}</td><td>{s.ozet.taburcu}</td><td>{s.ozet.hastaGun}</td>
              <td>{yuzde(s.ozet.doluluk)}</td><td>{gunMetni(s.ozet.alos)}</td><td>{p(s.ozet.ciro)}</td><td>{p(s.ozet.acikTutar)}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Yatak doluluğu</td><td>{yuzde(o.doluluk)}</td></tr>
        <tr><td>Ortalama yatış günü (ALOS)</td><td>{gunMetni(o.alos)} gün</td></tr>
        <tr><td>Ciro (dönem hizmetleri)</td><td>{paraYaz(o.ciro)}</td></tr>
        <tr><td>Kurum payı / hasta payı</td><td>{p(o.kurum)} / {paraYaz(o.hasta)}</td></tr>
        <tr className="kalan ki-kalan"><td>AÇIK HESAP ({o.acikAdet} taburcu)</td><td>{paraYaz(o.acikTutar)}</td></tr>
      </tbody></table>
      <p className="a4-not">Yatak devir hızı {gunMetni(v.devirHizi)} · 30 gün içinde tekrar yatış {v.tekrarYatis} · 30+ gün yatan {v.uzunYatis} ·
        hâlâ yatan {o.yatiyor}. Kurum / hasta payı kesin değildir; SUT kapsamı provizyon / Medula ile kesinleşir. Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Hasta Hizmetleri · İmza</div><div>Onaylayan<br />Başhekim · İmza</div></div>
    </div>
  );
}
