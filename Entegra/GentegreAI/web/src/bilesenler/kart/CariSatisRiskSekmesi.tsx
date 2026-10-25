import { useEffect, useState, type ReactNode } from 'react';
import { musteriRiskIcmalUclari, type MusteriRiskOzeti } from '../../api/uclar/musteriRiskIcmal';
import type { KartDetayMeta } from '../../api/sozlesme';
import { c } from '../../dil/ceviri';
import { para } from '../bicim';
import type { DetayDurumu } from '../detayDurumu';
import { TekKayit } from '../TekKayit';

/**
 * MÜŞTERİ KARTI "SATIŞ & RİSK" (mockup Ekranlar/musteri_karti_ver3.html, kullanıcı 23.10.2026:
 * "kartta satış & risk sekmesini karşılaştır ve mockup gibi yap"). İki kutu yan yana:
 *
 *  · SATIŞ KOŞULLARI - fiyat listeleri (cari kartının KENDİ alanları, `anaAlanlar`) + taraf_musteri
 *    uzantısındaki iskonto / vade / ödeme / para birimi / sevk / KDV / tevkifat (1152).
 *  · RİSK / LİMİT (1178) - cari kartının kendi alanları: risk limiti (null = tanımsız) + dövizi, risk grubu,
 *    sevk blokesi, teminat özeti - KARTTA SALT OKUNUR, Müşteri Risk / Limit İcmali'nden değişir (cari.risk_limit,
 *    neden zorunlu, loglu). RİSK KALEMLERİ dökümü satış belgesi limit kontrolüyle AYNI hesaptan
 *    (GET /api/musteri-risk-icmal/taraf/{id}): toplam ve limit durumu sunucuda, burada yalnız gösterilir.
 */
const SATIS = ['iskontoOrani', 'vadeGun', 'odemeSekli', 'dovizCinsi', 'sevkSekli', 'kdvDurumu', 'tevkifat'];
const RISK = ['riskLimit', 'riskLimitDoviz', 'riskGrubu', 'sevkBlokesi', 'sevkBlokesiNeden', 'teminatOzeti'];
const DURUM: Record<MusteriRiskOzeti['durum'], [string, string]> = {
  tanimsiz: ['gri', 'Tanımsız'], kurYok: ['uyari', 'Kur yok'], asim: ['hata', 'Aşıldı'], yaklasiyor: ['uyari', 'Yaklaşıyor'], uygun: ['ok', 'Uygun'],
};

export function CariSatisRiskSekmesi({ id, yeniMi, detay, durum, salt, onDegis, anaAlanlar, tedarikci }: {
  id: number | 'yeni'; yeniMi: boolean; detay: KartDetayMeta; durum: DetayDurumu; salt: boolean;
  onDegis(y: DetayDurumu): void;
  /** Cari kartının kendi alanlarını (fiyat listeleri) kartın çiziciyle çizer. */
  anaAlanlar?(adlar: string[]): ReactNode;
  /** Tedarikçiyse alış fiyat listesi de. */
  tedarikci: boolean;
}) {
  const [ozet, setOzet] = useState<MusteriRiskOzeti | null>(null);
  useEffect(() => {
    if (yeniMi || typeof id !== 'number') return;
    let iptal = false;
    musteriRiskIcmalUclari.musteriRiskOzeti(id).then(v => { if (!iptal) setOzet(v) }, () => { if (!iptal) setOzet(null) });
    return () => { iptal = true };
  }, [id, yeniMi]);

  const kalemler: [string, number][] = ozet ? [
    [c('Cari bakiye'), ozet.bakiye],
    [c('Açık sipariş (sevk edilmemiş)'), ozet.siparis],
    [c('Portföydeki müşteri çeki'), ozet.cek],
    [c('İrsaliyeli, faturalanmamış'), ozet.irsaliye],
  ] : [];
  const rozet = ozet ? DURUM[ozet.durum] : ['gri', '…'];
  const tl = (n: number) => `₺ ${para.format(n)}`;
  const ortak = { meta: detay, durum, saltOkunur: salt || detay.saltOkunur, onDegis, cerceveSiz: true } as const;

  return (
    <div className="cari-sr">
      <div className="kagrup">
        <h6>{c('Satış Koşulları')}</h6>
        <div className="alan-izgara cari-sr-k2">
          {anaAlanlar?.(tedarikci ? ['satisFiyatListesiId', 'alisFiyatListesiId'] : ['satisFiyatListesiId'])}
          <TekKayit {...ortak} alanSirasi={SATIS} />
        </div>
      </div>
      <div className="kagrup">
        <h6>{c('Risk / Limit')}</h6>
        <div className="alan-izgara cari-sr-k2">
          {anaAlanlar?.(RISK)}
          <label className="alan tip-metin">
            <span className="etiket">{c('Risk Durumu')}</span>
            <span><span className={`rozet ${rozet[0]}`}>{c(rozet[1])}</span></span>
          </label>
        </div>
        {yeniMi ? (
          <div className="not" style={{ margin: 10 }}>{c('Risk kalemleri kart kaydedildikten sonra hesaplanır.')}</div>
        ) : (
          <div className="cari-sr-tablo">
            <table>
              <thead><tr><th>{c('Risk kalemi')}</th><th className="s">{c('Tutar')}</th></tr></thead>
              <tbody>
                {!ozet && <tr><td colSpan={2} className="soluk">{c('Yükleniyor…')}</td></tr>}
                {kalemler.map(([ad, v]) => <tr key={ad}><td>{ad}</td><td className="s">{tl(v)}</td></tr>)}
              </tbody>
              {ozet && (
                <tfoot><tr><td>{c('Toplam risk / limit')}</td>
                  <td className={`s${ozet.durum === 'asim' ? ' borc' : ''}`}>
                    {tl(ozet.toplam)} / {ozet.limit == null ? c('tanımsız')
                      : `${para.format(ozet.limit)}${ozet.limitDoviz !== 'TL' ? ' ' + ozet.limitDoviz : ''}${ozet.kullanim != null ? ` · %${ozet.kullanim}` : ''}`}
                  </td></tr></tfoot>
              )}
            </table>
            <div className="not">
              {c("Limit boşsa TANIMSIZ (limitsiz değil). Toplam dört kalemi bugünkü kurla sayar; irsaliye ve sipariş KDV hariç. Limit, teminat ve sevk blokesi Müşteri Risk / Limit İcmali'nden değiştirilir.")}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
