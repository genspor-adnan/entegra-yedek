import type { EczaneIcmali } from '../../api/uclar/eczaneIcmal';
import { para } from '../../bilesenler/bicim';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { adet, yuzde } from './eczaneIcmalOrtak';

const p = (n: number) => para.format(n);

/**
 * A4 İLAÇ TÜKETİM İCMALİ. Servis (seçiliyse yalnız onlar) ve en çok tüketilen
 * ilaç tabloları, miad / iade / İTS özeti. Hasta bilgisi basılmaz.
 */
export function EczaneA4({ v, antet, duzenleyen, secili }: {
  v: EczaneIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const o = v.ozet;
  const servisler = secili.length ? v.servisler.filter(s => secili.includes(s.id)) : v.servisler;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>İLAÇ TÜKETİM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Çıkış: {adet(o.cikis)} adet · {o.ilac} ilaç</span>
        <span>Hasta: {o.hasta}</span><span>{secili.length ? `Seçili ${servisler.length} servis` : 'Tüm servisler'}</span>
      </div>
      <table className="a4-t ec-a4t">
        <thead><tr><th>Servis</th><th>Hasta</th><th>Çıkış</th><th>Maliyet</th><th>Faturalanan</th><th>Faturalanmayan</th><th>Hasta Başı</th></tr></thead>
        <tbody>
          {servisler.map(s => (
            <tr key={s.id}><td>{s.ad}</td><td>{s.ozet.hasta}</td><td>{adet(s.ozet.miktar)}</td><td>{p(s.ozet.maliyet)}</td>
              <td>{p(s.ozet.faturalanan)}</td><td>{p(s.ozet.faturalanmayan)}</td><td>{p(s.ozet.hastaBasi)}</td></tr>
          ))}
        </tbody>
      </table>
      {v.ilaclar.length > 0 && (
        <table className="a4-t ec-a4t">
          <thead><tr><th>En Çok Tüketilen İlaç</th><th>Adet</th><th>Maliyet</th><th>Faturalanmayan</th></tr></thead>
          <tbody>
            {v.ilaclar.slice(0, 10).map(i => (
              <tr key={`${i.stokId}-${i.ad}`}><td>{i.ad}</td><td>{adet(i.miktar)}</td><td>{p(i.maliyet)}</td><td>{i.faturalanmayan ? p(i.faturalanmayan) : '—'}</td></tr>
            ))}
          </tbody>
        </table>
      )}
      <table className="a4-toplam"><tbody>
        <tr><td>Toplam maliyet</td><td>{p(o.maliyet)}</td></tr>
        <tr><td>Faturalanan (adet oranı)</td><td>{p(o.faturalanan)} ({yuzde(o.faturaAdetOrani)})</td></tr>
        <tr><td>Faturalanmayan ({adet(o.faturalanmayanAdet)} adet)</td><td>{p(o.faturalanmayan)}</td></tr>
        <tr><td>Servisten iade / imha</td><td>{p(o.iade)} / {p(o.imha)}</td></tr>
        <tr><td>Miadı dolan lot / 30 gün içinde</td><td>{o.miadDolmus} ({p(o.miadDolmusTutar)}) / {o.miad30} ({p(o.miad30Tutar)})</td></tr>
        <tr><td>İTS bildirimi (hatalı / bekleyen)</td><td>{o.itsBildirim} ({o.itsHatali} / {o.itsBekleyen})</td></tr>
        <tr className="kalan ki-kalan"><td>HASTA BAŞI İLAÇ MALİYETİ</td><td>{p(o.hastaBasi)}</td></tr>
      </tbody></table>
      <p className="a4-not">Maliyet = adet × stok maliyeti. Faturalanmayan = uygulanıp başvuruya girmeyen ilaç (kontrol listesi).
        {' '}Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Sorumlu Eczacı · İmza</div><div>Onaylayan<br />Başhekim / İdari Mali İşler · İmza</div></div>
    </div>
  );
}
