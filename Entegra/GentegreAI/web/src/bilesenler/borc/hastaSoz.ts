import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { paraYaz } from '../bicim';

/**
 * HASTANIN AÇIK ÖDEME SÖZÜ / PLANI - ortak okuma ve metin (kullanıcı 19.11.2026: "hepsini yap" - başvuru hasta bandı,
 * tahsilat tutarı sorulurken, hasta icmali, randevu kartı). Kaynak: `GET /api/hasta-borc/hasta/{id}` (borç takibiyle
 * aynı kural: vadesi geçti ve borç açık -> "tutulmadi").
 *
 * Yeni söz kaydedilince `SOZ_OLAYI` yayınlanır; açık ekranlar yeniden okur.
 */
export interface HastaSoz {
  id: number;
  /** 2 söz · 3 plan */
  tur: number;
  tutar?: number | null;
  vade?: string | null;
  taksitSayisi?: number | null;
  aciklama?: string;
  zaman?: string;
  ekleyen?: string;
  durum: 'bekliyor' | 'tutulmadi';
}
export interface HastaBorcOzeti { borc: number; soz: HastaSoz | null }

export const SOZ_OLAYI = 'gentegre:hasta-soz-degisti';
export const sozDegistiYayinla = (hastaId: number) =>
  window.dispatchEvent(new CustomEvent(SOZ_OLAYI, { detail: { hastaId } }));

/** Hastanın borcu + açık sözü; okunamazsa (yetki / ağ) null - ekranlar hiçbir şey göstermez. */
export function useHastaBorcOzeti(hastaId: number | null | undefined): HastaBorcOzeti | null {
  const [ozet, setOzet] = useState<HastaBorcOzeti | null>(null);
  const [surum, setSurum] = useState(0);
  useEffect(() => {
    const dinle = (e: Event) => {
      const id = (e as CustomEvent<{ hastaId: number }>).detail?.hastaId;
      if (!id || id === hastaId) setSurum(s => s + 1);
    };
    window.addEventListener(SOZ_OLAYI, dinle);
    return () => window.removeEventListener(SOZ_OLAYI, dinle);
  }, [hastaId]);
  useEffect(() => {
    if (!hastaId || hastaId <= 0) { setOzet(null); return }
    let iptal = false;
    // Senkron hata da (okunamayan uç / test sahtesi) yakalansın: bilgi amaçlı, ekranı düşürmemeli.
    Promise.resolve().then(() => api.hastaBorcOzeti(hastaId))
      .then(y => { if (!iptal) setOzet(y) })
      .catch(() => { if (!iptal) setOzet(null) });
    return () => { iptal = true };
  }, [hastaId, surum]);
  return ozet;
}

const gunAy = (g?: string | null) => {
  const s = String(g ?? '').slice(0, 10);
  return s ? `${s.slice(8, 10)}.${s.slice(5, 7)}` : '—';
};

/** Kısa rozet metni + sınıfı: "🤝 Söz 25.11 · 1.250,00" / "📅 Plan 3 taksit · ilk 25.11" / "⚠ Söz tutulmadı (25.11)". */
export function sozRozeti(s: HastaSoz): { ad: string; sinif: string; ipucu: string } {
  const plan = s.tur === 3;
  const tutar = s.tutar != null ? paraYaz(Number(s.tutar)) : '';
  const ipucu = [plan ? `Ödeme planı · ${s.taksitSayisi ?? '?'} taksit · ilk taksit ${gunAy(s.vade)}` : `Ödeme sözü · ${gunAy(s.vade)}`,
                 tutar && `tutar ${tutar}`, s.aciklama, s.ekleyen && `kaydeden ${s.ekleyen}`].filter(Boolean).join(' · ');
  if (s.durum === 'tutulmadi')
    return { ad: `⚠ ${plan ? 'Plan' : 'Söz'} tutulmadı (${gunAy(s.vade)})`, sinif: 'hata', ipucu };
  return plan
    ? { ad: `📅 Plan ${s.taksitSayisi ?? '?'} taksit · ilk ${gunAy(s.vade)}`, sinif: 'mor', ipucu }
    : { ad: `🤝 Söz ${gunAy(s.vade)}${tutar ? ` · ${tutar}` : ''}`, sinif: 'mor', ipucu };
}

/** Tahsilat penceresine eklenecek tek satır not ("Hastanın 25.11 vadeli 1.250 ₺ ödeme sözü var"). */
export function sozNotu(s: HastaSoz | null | undefined): string {
  if (!s) return '';
  const tutar = s.tutar != null ? ` ${paraYaz(Number(s.tutar))}` : '';
  const ne = s.tur === 3 ? `ödeme planı (${s.taksitSayisi ?? '?'} taksit, ilk ${gunAy(s.vade)})` : `${gunAy(s.vade)} vadeli${tutar} ödeme sözü`;
  return s.durum === 'tutulmadi'
    ? `⚠ Hastanın ${ne} TUTULMADI.`
    : `🤝 Hastanın ${ne} var.`;
}
