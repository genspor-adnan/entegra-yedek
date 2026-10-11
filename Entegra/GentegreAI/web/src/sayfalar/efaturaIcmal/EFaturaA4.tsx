import type { EFaturaIcmali } from '../../api/uclar/efaturaIcmal';
import { para } from '../../bilesenler/bicim';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { yuzde } from './efaturaIcmalOrtak';

const tl = (n: number) => para.format(n);

/**
 * A4 e-BELGE İCMALİ: tür tablosu (seçiliyse yalnız seçilen türler), KDV özeti,
 * sorunlu belge sayıları. Hasta kimlik no basılmaz.
 */
export function EFaturaA4({ v, antet, duzenleyen, secili }: {
  v: EFaturaIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: string[];
}) {
  const o = v.ozet;
  const turler = secili.length ? v.turler.filter(t => secili.includes(t.tur)) : v.turler;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>FATURA / e-BELGE DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Kesilen: {o.kesilen} belge · {o.kayit} kayıt · {o.iptal} iptal</span>
        <span>GİB'e ulaşan: {yuzde(o.ulasan)}</span>
        <span>{secili.length ? `Seçili türler: ${turler.map(t => t.tur).join(', ')}` : 'Tüm türler'}</span>
      </div>
      <table className="a4-t ef-a4t">
        <thead><tr><th>Tür</th><th>Belge</th><th>Matrah</th><th>KDV</th><th>Toplam</th><th>İade</th><th>İptal</th><th>Sorunlu</th></tr></thead>
        <tbody>
          {turler.map(t => (
            <tr key={t.tur}><td>{t.tur}</td><td>{t.ozet.belge}</td><td>{tl(t.ozet.matrah)}</td><td>{tl(t.ozet.kdv)}</td>
              <td>{tl(t.ozet.toplam)}</td><td>{t.ozet.iade}</td><td>{t.ozet.iptal}</td><td>{t.ozet.sorunlu}</td></tr>
          ))}
        </tbody>
      </table>
      {v.kdvOzet.length > 0 && (
        <table className="a4-t ef-a4t">
          <thead><tr><th>KDV Oranı</th><th>Belge</th><th>e-Fatura Matrah</th><th>e-Arşiv Matrah</th><th>Matrah</th><th>KDV</th><th>Pay</th></tr></thead>
          <tbody>
            {v.kdvOzet.map(k => (
              <tr key={k.oran}><td>{k.oran ? `%${k.oran}` : 'İstisna (%0)'}</td><td>{k.belge}</td><td>{tl(k.eFatura)}</td><td>{tl(k.eArsiv)}</td>
                <td>{tl(k.matrah)}</td><td>{tl(k.kdv)}</td><td>{yuzde(k.pay)}</td></tr>
            ))}
          </tbody>
        </table>
      )}
      <table className="a4-toplam"><tbody>
        <tr><td>Toplam matrah</td><td>{tl(o.matrah)}</td></tr>
        <tr><td>Toplam KDV (fatura KDV {tl(o.faturaKdv)})</td><td>{tl(o.kdv)}</td></tr>
        <tr><td>GİB'e gitmeyen / gönderim hatası</td><td>{o.gitmedi} / {o.hata}</td></tr>
        <tr><td>7 gün kuralını aşan</td><td>{o.yediGun}</td></tr>
        <tr className="kalan ki-kalan"><td>TOPLAM TUTAR</td><td>{tl(o.toplam)}</td></tr>
      </tbody></table>
      <p className="a4-not">Tutarlar geçerli satış belgeleridir (iptal hariç, iade ayrı). e-İrsaliye KDV'si beyana girmez.
        Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Muhasebe · İmza</div><div>Onaylayan<br />Mali İşler Sorumlusu · İmza</div></div>
    </div>
  );
}
