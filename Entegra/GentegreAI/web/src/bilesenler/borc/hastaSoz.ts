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
  durum: 'bekliyor' | 'tutulmadi' | 'tutuldu';
  /** Söz sonrası tahsilattan (sunucu, 19.11.2026): ödenen, kalan, plan taksit durumu, sıradaki vade. */
  odenen?: number; kalan?: number; odenenTaksit?: number; gecikenTaksit?: number;
  sonrakiVade?: string | null; sonrakiTutar?: number | null;
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

/**
 * Kısa rozet - TUTULAN söz / plan için null (gösterilmez):
 *   söz: "🤝 Söz 25.11 · kalan 400 / 1.250" · plan: "📅 Plan 1/3 · sonraki 25.12 (300)" ·
 *   tutulmadı: "⚠ Söz tutulmadı (25.11) · kalan 400" / "⚠ Plan: 1 taksit gecikti".
 */
export function sozRozeti(s: HastaSoz): { ad: string; sinif: string; ipucu: string } | null {
  if (s.durum === 'tutuldu') return null;
  const plan = s.tur === 3;
  const tutar = s.tutar != null ? paraYaz(Number(s.tutar)) : '';
  const odenen = Number(s.odenen ?? 0), kalan = s.kalan != null ? Number(s.kalan) : Number(s.tutar ?? 0);
  const ipucu = [plan ? `Ödeme planı · ${s.taksitSayisi ?? '?'} taksit · ilk taksit ${gunAy(s.vade)}` : `Ödeme sözü · ${gunAy(s.vade)}`,
                 tutar && `tutar ${tutar}`, odenen > 0 && `söz sonrası ödenen ${paraYaz(odenen)}`,
                 s.aciklama, s.ekleyen && `kaydeden ${s.ekleyen}`].filter(Boolean).join(' · ');
  if (plan) {
    const n = s.taksitSayisi ?? 0, od = s.odenenTaksit ?? 0;
    if (s.durum === 'tutulmadi')
      return { ad: `⚠ Plan: ${s.gecikenTaksit ?? 1} taksit gecikti · ${od}/${n} ödendi`, sinif: 'hata', ipucu };
    return { ad: `📅 Plan ${od}/${n}${s.sonrakiVade ? ` · sonraki ${gunAy(s.sonrakiVade)}` : ''}`
                 + `${s.sonrakiTutar ? ` (${paraYaz(Number(s.sonrakiTutar))})` : ''}`, sinif: 'mor', ipucu };
  }
  const kalanMetni = odenen > 0 && tutar ? ` · kalan ${paraYaz(kalan)} / ${tutar}` : tutar ? ` · ${tutar}` : '';
  if (s.durum === 'tutulmadi')
    return { ad: `⚠ Söz tutulmadı (${gunAy(s.vade)})${odenen > 0 ? ` · kalan ${paraYaz(kalan)}` : ''}`, sinif: 'hata', ipucu };
  return { ad: `🤝 Söz ${gunAy(s.vade)}${kalanMetni}`, sinif: 'mor', ipucu };
}

/** Tahsilat penceresine eklenecek tek satır not ("Hastanın 25.11 vadeli 1.250 ₺ ödeme sözü var"). */
export function sozNotu(s: HastaSoz | null | undefined): string {
  if (!s || s.durum === 'tutuldu') return '';
  const kalan = s.kalan != null ? Number(s.kalan) : Number(s.tutar ?? 0);
  const tutar = kalan > 0 ? ` ${paraYaz(kalan)}` : '';
  const ne = s.tur === 3
    ? `ödeme planı (${s.odenenTaksit ?? 0}/${s.taksitSayisi ?? '?'} taksit ödendi${s.sonrakiVade ? `, sonraki ${gunAy(s.sonrakiVade)}${s.sonrakiTutar ? ` ${paraYaz(Number(s.sonrakiTutar))}` : ''}` : ''})`
    : `${gunAy(s.vade)} vadeli${tutar} ödeme sözü`;
  return s.durum === 'tutulmadi'
    ? `⚠ Hastanın ${ne} TUTULMADI.`
    : `🤝 Hastanın ${ne} var.`;
}
