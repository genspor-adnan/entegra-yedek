import { useContext, useEffect, useState, type ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import type { KartMetaYaniti } from '../../api/sozlesme';
import { basHarfler } from '../basHarfler';
import { c } from '../../dil/ceviri';
import type { Deger } from '../kartAlanCizim';
import { KartKipBaglami } from './KipKalemi';

/**
 * ÇEK / SENET KARTI BAŞLIĞI (mockup Ekranlar/cek_senet_baslik.html; kullanıcı 20.11.2026: "uygula.. view/edit deseni
 * de yap", "çekin içinde cari arama editi olmasın").
 *
 *  * Solda CARİ BANDI: avatar (carinin baş harfleri; sağ altında yön - ⬇ yeşil alınan, ⬆ turuncu verilen), ad + kod +
 *    "↗ cari kartı", altında Çek/Senet · Alınan/Verilen etiketleri, keşideci, banka · şube, hesap no. KARTTA CARİ ARAMA
 *    KUTUSU YOK: cari yeni kayıtta açılışta gelen pencereden, sonra AVATARA tıklayınca aynı pencereden değişir
 *    (görüntülemedeyse kart düzenlemeye geçer; portföyden çıkmış kıymette değişmez).
 *  * Sağda ✎ + üç kutu: TUTAR (büyük, altında seri no), VADE (kalan gün; 30 günden az sarı, geçtiyse kırmızı), DURUM
 *    (renkli rozet + bulunduğu hesap). Sol kenar çizgisi durumun rengi.
 *  * ✎ tüm kartı açar / kapatır (GenForm kipli kart). Tutar / para birimi / vade / seri no yalnız düzenlemede, bandın
 *    altında. Portföyden çıkmış kıymet (ciro, tahsil, iade, karşılıksız…) kilitli: ✎ pasif, iz şeridi son durumu söyler.
 */
const DURUM_RENK: Record<number, string> = {
  10: 'var(--mavi, #2f6db3)', 20: 'var(--mor, #6d4aff)', 30: '#a9791a', 40: '#5b6b7c',
  50: 'var(--ok, #2e7d46)', 60: 'var(--hata, #c0392b)', 70: '#8a96a3', 0: '#8a96a3',
};
const PARA_SIMGE: Record<string, string> = { TL: '₺', TRY: '₺', USD: '$', EUR: '€', GBP: '£' };

/** Cari listesinin tek satırı (bant bilgisi). Cari yetkisi yoksa boş döner - bant katalog adıyla çizilir. */
function useCariSatiri(id: number) {
  const [s, setS] = useState<Record<string, unknown> | null>(null);
  useEffect(() => {
    if (!(id > 0)) { setS(null); return }
    let iptal = false;
    Promise.resolve().then(() => api.liste('cari', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: id } }))
      .then(y => { if (!iptal) setS(y.satirlar[0] ?? null) })
      .catch(() => { if (!iptal) setS(null) });
    return () => { iptal = true };
  }, [id]);
  return s;
}

/** Vade kutusu: gün + kalan / geçen gün; 30 günden az sarı, geçtiyse kırmızı. */
export function vadeBilgisi(vade: unknown, bugun = new Date()): { gun: string; alt: string; sinif: '' | 'sari' | 'kir' } | null {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(vade ?? ''));
  if (!m) return null;
  const [y, a, g] = [Number(m[1]), Number(m[2]), Number(m[3])];
  const b = new Date(bugun); b.setHours(0, 0, 0, 0);
  const fark = Math.round((new Date(y, a - 1, g).getTime() - b.getTime()) / 86400000);
  return {
    gun: `${m[3]}.${m[2]}.${m[1]}`,
    alt: fark === 0 ? c('bugün') : fark > 0 ? `${fark} ${c('gün kaldı')}` : `${-fark} ${c('gün geçti')}`,
    sinif: fark < 0 ? 'kir' : fark <= 30 ? 'sari' : '',
  };
}

export function CekSenetBasligi({ deger, meta, yeniMi, duzenAlanlari, cariAra }: {
  deger: Record<string, Deger>;
  meta: KartMetaYaniti | null | undefined;
  yeniMi: boolean;
  /** Tutar, para birimi, vade, seri no - yalnız düzenlemede. */
  duzenAlanlari: ReactNode;
  /** Cari arama penceresini açar (GenForm) - avatar tıklaması. */
  cariAra?(): void;
}) {
  const kip = useContext(KartKipBaglami);
  const git = useNavigate();
  const gosterKipi = kip ? !kip.acik || kip.pasif : true;
  const ad = (alan: string) => {
    const v = String(deger[alan] ?? '');
    return v ? meta?.alanlar.find(a => a.ad === alan)?.kodlar?.[v] ?? '' : '';
  };
  const tarafId = Number(deger.tarafId) || 0;
  const cari = useCariSatiri(tarafId);
  const cariAd = String(cari?.unvan ?? '') || ad('tarafId');
  const durum = Number(deger.durum ?? 10);
  const kilitli = !yeniMi && durum !== 10;
  const senet = Number(deger.tur ?? 1) === 2;
  const verilen = Number(deger.yon ?? 1) === 2;
  const para = String(deger.dovizCinsi ?? '') || 'TL';
  const simge = PARA_SIMGE[para] ?? para;
  const tutar = Number(deger.tutar);
  const tutarMetni = String(deger.tutar ?? '') !== '' && Number.isFinite(tutar)
    ? `${tutar.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} ${simge}`
    : `— ${simge}`;
  const vade = vadeBilgisi(deger.vade);
  // Vade uyarısı yalnız henüz tahsil edilmemiş kıymette (portföy / tahsilde / teminat).
  const vadeSinif = vade && [10, 30, 40].includes(durum) ? vade.sinif : '';
  const banka = [ad('bankaId'), ad('bankaSubeId')].filter(Boolean).join(' · ');
  const kesideci = String(deger.kesideci ?? '').trim();
  const hesapNo = String(deger.hesapNo ?? '').trim();
  const avatarTik = !cariAra || (kip?.pasif ?? true) || kilitli ? undefined : () => {
    // Görüntülemedeyse önce düzenlemeye geç - değişen cari Kaydet'le yazılır.
    if (kip && !kip.acik) kip.degistir();
    cariAra();
  };
  const ciroAd = ad('ciroTarafId');
  const renk = tarafId ? DURUM_RENK[durum] ?? DURUM_RENK[10] : '#c9d3de';

  return (
    <div className="rv-baslik cs-baslik" style={{ ['--rvd' as string]: renk }} data-testid="cek-senet-basligi">
      <div className="rv-bant">
        <div className="rv-hasta" data-testid="cek-senet-cari-bandi">
          <span className={`rv-avatar cs-avatar${tarafId ? '' : ' bos'}${avatarTik ? ' degisir' : ''}`}
                role={avatarTik ? 'button' : undefined} data-testid="cek-senet-avatar" onClick={avatarTik}
                title={avatarTik ? (tarafId ? c('Cariyi değiştir') : c('Cari seçin')) : undefined}>
            {tarafId ? (basHarfler(cariAd, true) || '?') : '🏢'}
            <span className={`cs-yon${verilen ? ' ver' : ''}`} title={verilen ? c('Verilen') : c('Alınan')}>{verilen ? '⬆' : '⬇'}</span>
          </span>
          <div className="rv-kim">
            <div className="rv-ad">
              {tarafId
                ? (cariAd || '—')
                : <span className="cs-cari-yok" role={avatarTik ? 'button' : undefined} onClick={avatarTik}>{c('Cari seçilmedi')}</span>}
              {String(cari?.kod ?? '') && <span className="rv-kod">{String(cari?.kod)}</span>}
              {tarafId > 0 && (
                <a href={`/cari/${tarafId}`} onClick={e => { e.preventDefault(); git(`/cari/${tarafId}`) }}>↗ {c('cari kartı')}</a>
              )}
            </div>
            <div className="rv-hasta-alt">
              <span className="cs-etk tur">{senet ? c('Senet') : c('Çek')}</span>
              <span className={`cs-etk ${verilen ? 'ver' : 'al'}`}>{verilen ? c('Verilen') : c('Alınan')}</span>
              {kesideci && <span>{c('Keşideci')}: {kesideci}</span>}
              {banka && <span>{banka}</span>}
              {hesapNo && <span>{c('Hs.')} {hesapNo}</span>}
            </div>
          </div>
        </div>
        <div className="rv-kutular">
          <span className="rv-kalem-grup">
            {kip && (
              <button type="button" className={`bs-kalem rv-kalem kip-kalemi${kip.acik ? ' acik' : ''}`}
                      data-testid="cek-senet-kalem" disabled={kip.pasif || kilitli}
                      title={kip.pasif ? c('Düzenleme yetkisi yok')
                             : kilitli ? c('Portföyden çıkmış çek / senet değiştirilemez')
                             : kip.acik ? c('Düzenlemeyi kapat') : c('Çek / senet bilgilerini düzenle')}
                      onClick={e => { e.stopPropagation(); kip.degistir() }}>✎</button>
            )}
            <div className="rv-kutu rv-kutu-zaman">
              <small>{c('Tutar')}</small>
              <b data-testid="cek-senet-tutar">{tutarMetni}</b>
              <i>{String(deger.seriNo ?? '') ? `${c('Seri No')} ${String(deger.seriNo)}` : c('seri no girilmedi')}</i>
            </div>
          </span>
          <div className="rv-kutu">
            <small>{c('Vade')}</small>
            <b>{vade?.gun ?? '—'}</b>
            <i className={vadeSinif ? `cs-${vadeSinif}` : undefined}>{vade?.alt ?? c('girilecek')}</i>
          </div>
          <div className="rv-kutu">
            <small>{c('Durum')}</small>
            <b><span className="rv-rozet" data-testid="cek-senet-durum">{ad('durum') || c('Portföyde')}</span></b>
            <i>{ad('hesapId') || (yeniMi ? c('kayıtta') : ' ')}</i>
          </div>
        </div>
      </div>
      {!yeniMi && durum === 20 && (
        <div className="rv-iz">➡ {c('Ciro edildi')}{ciroAd ? <>: <b>{ciroAd}</b></> : null}</div>
      )}
      {!yeniMi && durum === 60 && (
        <div className="rv-iz cs-iz-kir">⚠ <b>{c('Karşılıksız')}</b> · {c('portföyden çıktı, değiştirilemez')}</div>
      )}
      {!gosterKipi && (
        <div className="alan-izgara rv-alt-alanlar cs-alt-alanlar">{duzenAlanlari}</div>
      )}
    </div>
  );
}
