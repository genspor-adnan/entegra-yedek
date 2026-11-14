import type { CSSProperties } from 'react';

/**
 * RAPOR TİPOGRAFİSİ (1344, mockup Ekranlar/Radyoloji/radyoloji_rapor_tipografi.html).
 * Sunucudaki RaporTipografisi ile AYNI kural: kurum ayarı → şablon üst-seçimi (1 kurum · 2 özel · 3 özgün) →
 * raporun onay damgası. Ekran A4 editörü, çıktı/PDF ve e-imza belgesi aynı CSS değişkenleriyle çizilir
 * (ne görüyorsan onu imzalarsın). pt → px çevrimi ×4/3.
 */
export interface Tipografi {
  font: string; punto: number; satir: number; paragraf: number; hiza: 'sol' | 'iki'; kenar: number;
  baslikPunto: number; kaynak?: string;
}

export const TIPOGRAFI_VARSAYILAN: Tipografi = { font: 'arial', punto: 10.5, satir: 1.3, paragraf: 6, hiza: 'iki', kenar: 18, baslikPunto: 13, kaynak: 'kurum' };
/** Bugüne kadarki görünüm (uygulama fontu): eski onaylı raporlar ve "şablonun kendi biçimi". */
export const TIPOGRAFI_OZGUN: Tipografi = { font: 'trebuchet', punto: 9.75, satir: 1.65, paragraf: 0, hiza: 'sol', kenar: 14, baslikPunto: 12, kaynak: 'ozgun' };

export const FONTLAR: Record<string, { ad: string; css: string; not: string }> = {
  arial:     { ad: 'Arial / Helvetica',  css: 'Arial, Helvetica, "Liberation Sans", sans-serif', not: 'dünya pratiği, PACS/RIS çıktıları · önerilen' },
  calibri:   { ad: 'Calibri',            css: 'Calibri, Carlito, "Segoe UI", sans-serif',          not: 'Word şablonu geleneği (Türkiye\'de yaygın)' },
  times:     { ad: 'Times New Roman',    css: '"Times New Roman", Times, "Liberation Serif", serif', not: 'eski hastane / akademik' },
  segoe:     { ad: 'Segoe UI',           css: '"Segoe UI", Tahoma, sans-serif',                    not: 'ekran görünümüyle aynı' },
  trebuchet: { ad: 'Trebuchet MS',       css: '"Trebuchet MS", "Segoe UI", Tahoma, sans-serif',    not: 'özgün (bugüne kadarki görünüm)' },
};

const sayi = (v: unknown, yedek: number) => { const n = Number(v); return Number.isFinite(n) ? n : yedek };

/** Sunucudan gelen nesneyi güvenle okur (eksik / bozuk alan yedeğe düşer). */
export function tipografiOku(v: unknown, yedek: Tipografi = TIPOGRAFI_VARSAYILAN): Tipografi {
  if (!v || typeof v !== 'object') return { ...yedek };
  const o = v as Record<string, unknown>;
  const font = String(o.font ?? yedek.font).toLowerCase();
  return {
    font: FONTLAR[font] ? font : yedek.font,
    punto: Math.min(12, Math.max(9, sayi(o.punto, yedek.punto))),
    satir: Math.min(2, Math.max(1, sayi(o.satir, yedek.satir))),
    paragraf: Math.min(12, Math.max(0, sayi(o.paragraf, yedek.paragraf))),
    hiza: o.hiza === 'sol' ? 'sol' : 'iki',
    kenar: Math.min(25, Math.max(10, sayi(o.kenar, yedek.kenar))),
    baslikPunto: Math.min(16, Math.max(11, sayi(o.baslikPunto, yedek.baslikPunto))),
    kaynak: typeof o.kaynak === 'string' ? o.kaynak : yedek.kaynak,
  };
}

/** Şablon satırından (rapor ekranındaki sablonlar listesi) etkin tipografi - sunucu SablondanTuret ile aynı. */
/** Şablon satırının tipografi alanları (rapor ekranı Sablon tipi ve kart sözlüğü ikisi de uyar). */
export interface SablonTipografiAlanlari {
  tipografiKaynak?: unknown; tipFont?: unknown; tipPunto?: unknown; tipSatir?: unknown; tipParagraf?: unknown; tipHiza?: unknown;
}

export function sablonTipografisi(s: SablonTipografiAlanlari | null | undefined, kurum: Tipografi): Tipografi {
  const kaynak = Number(s?.tipografiKaynak ?? 1);
  if (kaynak === 3) return { ...TIPOGRAFI_OZGUN };
  if (kaynak !== 2 || !s) return { ...kurum, kaynak: 'kurum' };
  const font = String(s.tipFont ?? '').toLowerCase();
  return tipografiOku({
    font: FONTLAR[font] ? font : kurum.font,
    punto: s.tipPunto ?? kurum.punto, satir: s.tipSatir ?? kurum.satir,
    paragraf: s.tipParagraf ?? kurum.paragraf,
    hiza: s.tipHiza == null ? kurum.hiza : Number(s.tipHiza) === 1 ? 'sol' : 'iki',
    kenar: kurum.kenar, baslikPunto: kurum.baslikPunto, kaynak: 'sablon',
  }, kurum);
}

/** CSS değişkenleri: .rad-a4 / .rad-bolum textarea / .cikti-sayfa bunları okur (tema.css 1344 bloğu). */
export function tipografiStil(t: Tipografi): CSSProperties {
  return {
    '--rt-font': FONTLAR[t.font]?.css ?? FONTLAR.arial.css,
    '--rt-punto': `${(t.punto * 4 / 3).toFixed(2)}px`,
    '--rt-satir': String(t.satir),
    '--rt-paragraf': `${t.paragraf}pt`,
    '--rt-hiza': t.hiza === 'iki' ? 'justify' : 'left',
    '--rt-baslik': `${(t.baslikPunto * 4 / 3).toFixed(2)}px`,
    '--rt-kenar': `${t.kenar}mm`,
  } as CSSProperties;
}

const tr = (n: number, basamak: number) => n.toLocaleString('tr-TR', { maximumFractionDigits: basamak });

/** "Arial 10,5 · 1,3" */
export function tipografiOzeti(t: Tipografi): string {
  return `${FONTLAR[t.font]?.ad.split(' /')[0] ?? t.font} ${tr(t.punto, 2)} · ${tr(t.satir, 2)}`;
}

export function kaynakAdi(t: Tipografi, damgali: boolean): string {
  if (damgali) return 'onay damgası';
  return t.kaynak === 'sablon' ? 'şablon özel' : t.kaynak === 'ozgun' ? 'şablonun kendi biçimi' : 'kurum ayarı';
}
