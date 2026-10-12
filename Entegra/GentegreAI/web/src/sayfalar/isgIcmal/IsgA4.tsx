import type { IsgIcmali } from '../../api/uclar/isgIcmal';
import { para } from '../../bilesenler/bicim';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { dk } from './isgIcmalOrtak';

/**
 * A4 İŞYERİ HEKİMLİĞİ DÖNEM HİZMET İCMALİ. Firma başına süre, muayene,
 * geciken, kaza ve fatura; özet. ÇALIŞAN BİLGİSİ BASILMAZ (yalnız sayılar).
 * Firma seçiliyse veri zaten seçime göre sunucudan gelir.
 */
export function IsgA4({ v, antet, duzenleyen }: { v: IsgIcmali; antet: Record<string, unknown> | null; duzenleyen: string }) {
  const o = v.ozet;
  const fatura = new Map(v.hizmet.map(h => [h.id, h.faturalanan]));
  const p = (n: number) => para.format(n);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>İŞYERİ HEKİMLİĞİ DÖNEM HİZMET İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Firma: {o.firma} · çalışan {o.calisan}</span><span>İşyeri hekimi: {o.hekim}</span>
        <span>{v.secimli ? `Seçili ${o.firma} firma` : 'Tüm firmalar'}</span>
      </div>
      <table className="a4-t isg-a4t">
        <thead><tr><th>Firma</th><th>Tehlike</th><th>Çalışan</th><th>Plan dk</th><th>Gerçekleşen dk</th><th>Muayene</th><th>Geciken</th><th>Kaza</th><th>Fatura</th></tr></thead>
        <tbody>
          {v.firmalar.map(f => (
            <tr key={f.id}><td>{f.ad}</td><td>{f.tehlikeAdi}</td><td>{f.calisan}</td><td>{dk(f.planDk)}</td><td>{dk(f.gercekDk)}</td>
              <td>{f.muayene}</td><td>{f.geciken}</td><td>{f.kaza}</td><td>{p(fatura.get(f.id) ?? 0)}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Hizmet süresi (gerçekleşen / plan)</td><td>{dk(o.gercekDk)} / {dk(o.planDk)} dk</td></tr>
        <tr><td>Muayene / geciken periyodik</td><td>{o.muayene} / {o.geciken}</td></tr>
        <tr><td>İş kazası / meslek hastalığı şüphesi</td><td>{o.kaza} / {o.meslekHastaligi}</td></tr>
        <tr><td>Faturalanan / tahsil edilen</td><td>{p(o.faturalanan)} / {p(o.tahsil)}</td></tr>
        <tr className="kalan ki-kalan"><td>AÇIK BAKİYE</td><td>{p(o.bakiye)} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Süreler İSG-KATİP'e bildirilen ziyaret ve muayene dakikalarıdır. Bu belgede çalışan kimlik bilgisi yer almaz.</p>
      <div className="a4-imza"><div>İşyeri Hekimi<br />Ad Soyad · İmza</div><div>OSGB Sorumlu Müdürü<br />Kaşe · İmza</div></div>
    </div>
  );
}
