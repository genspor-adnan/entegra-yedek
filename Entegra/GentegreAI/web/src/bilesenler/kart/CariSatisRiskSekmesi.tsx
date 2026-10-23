import { useEffect, useState, type ReactNode } from 'react';
import { api } from '../../api/istemci';
import type { CariKartOzeti } from '../../api/uclar/cariListe';
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
 *  · RİSK / LİMİT - limit, aşımda davranış, teminat, risk durumu ve RİSK KALEMLERİ dökümü
 *    (cari bakiye, açık sipariş, portföydeki müşteri çeki, faturalanmamış irsaliye - kart özeti).
 *
 * Kalemler ve tutarlar sunucudan (GET /api/cari/{id}/kart-ozet); burada yalnız toplanıp limitle
 * karşılaştırılır.
 */
const SATIS = ['iskontoOrani', 'vadeGun', 'odemeSekli', 'dovizCinsi', 'sevkSekli', 'kdvDurumu', 'tevkifat'];
const RISK = ['riskLimiti', 'riskAsim', 'teminat'];

export function CariSatisRiskSekmesi({ id, yeniMi, detay, durum, salt, onDegis, anaAlanlar, tedarikci }: {
  id: number | 'yeni'; yeniMi: boolean; detay: KartDetayMeta; durum: DetayDurumu; salt: boolean;
  onDegis(y: DetayDurumu): void;
  /** Cari kartının kendi alanlarını (fiyat listeleri) kartın çiziciyle çizer. */
  anaAlanlar?(adlar: string[]): ReactNode;
  /** Tedarikçiyse alış fiyat listesi de. */
  tedarikci: boolean;
}) {
  const [ozet, setOzet] = useState<CariKartOzeti['ozet'] | null>(null);
  // Limit kutuda değişince tablo yeniden hesaplanır - kalemler sunucudan bir kez.
  useEffect(() => {
    if (yeniMi || typeof id !== 'number') return;
    let iptal = false;
    api.cariKartOzet(id).then(v => { if (!iptal) setOzet(v.ozet) }, () => { if (!iptal) setOzet(null) });
    return () => { iptal = true };
  }, [id, yeniMi]);

  const kayit = (durum.guncel[0] ?? {}) as Record<string, unknown>;
  const limit = Number(kayit.riskLimiti ?? 0) || 0;
  const kalemler: [string, number][] = ozet ? [
    [c('Cari bakiye (borç)'), Math.max(Number(ozet.bakiye) || 0, 0)],
    [c('Açık sipariş (sevk edilmemiş)'), Number(ozet.acikSiparis) || 0],
    [c('Portföydeki müşteri çeki'), Number(ozet.cekTutar) || 0],
    [c('İrsaliyeli, faturalanmamış'), Number(ozet.irsaliyeAcik) || 0],
  ] : [];
  const toplam = kalemler.reduce((t, [, v]) => t + v, 0);
  const yuzde = limit > 0 ? Math.round(toplam * 100 / limit) : null;
  const rozet = limit <= 0 ? ['gri', c('Limitsiz')]
    : yuzde! > 100 ? ['hata', c('Aşıldı')]
    : yuzde! >= 80 ? ['uyari', c('Yaklaşıyor')] : ['ok', c('Uygun')];
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
          <TekKayit {...ortak} alanSirasi={RISK} />
          <label className="alan tip-metin">
            <span className="etiket">{c('Risk Durumu')}</span>
            <span><span className={`rozet ${rozet[0]}`}>{rozet[1]}</span></span>
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
                  <td className={`s${yuzde !== null && yuzde > 100 ? ' borc' : ''}`}>
                    {tl(toplam)} / {limit > 0 ? `${para.format(limit)} · %${yuzde}` : c('limitsiz')}
                  </td></tr></tfoot>
              )}
            </table>
            <div className="not">
              {c('Risk limiti 0 ise limitsiz. Toplam dört kalemi sayar; özet şeritteki risk yüzdesi yalnız cari bakiyeyi sayar.')}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
