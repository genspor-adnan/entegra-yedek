import type { ReactNode } from 'react';

/**
 * BELGE İKONLARI (kullanıcı 26.10.2026): emoji setinde fatura ve kopya yok (🧾 fişle aynıydı), emoji de
 * renklendirilemiyor. CekIkon deseni - bağımsız SVG.
 *
 * YÖN RENGİ (kullanıcı 26.10.2026: "satış belgeleri ve tahsilat ikonlarını yeşil, alış belgeleri ve ödeme
 * ikonlarını kırmızı tonlarda yap.. sekmedeyken ikondan alış mı satış mı olduğu anlaşılır"): her belge türü
 * tek çizim, renk yönden gelir. Menüde `@b:<tür>:<s|a>` (MenuIkon) - kart sekmesi listenin ikonunu taşır.
 */
const STIL = { verticalAlign: '-3px', flex: 'none' } as const;

export type BelgeIkonTuru = 'fatura' | 'fis' | 'irsaliye' | 'tahakkuk' | 'siparis' | 'teklif' | 'konsinye'
  | 'tahsilat' | 'odeme';
/** s = satış / tahsilat (yeşil), a = alış / ödeme (kırmızı). */
export type BelgeYonu = 's' | 'a';

const RENK: Record<BelgeYonu, { koyu: string; acik: string; orta: string }> = {
  s: { koyu: '#2e7d46', acik: '#e6f4ea', orta: '#bfe3c9' },
  a: { koyu: '#c62828', acik: '#fdecec', orta: '#f5c2c2' },
};

/** Köşesi kıvrık sayfa (fatura / tahakkuk tabanı). */
const sayfa = (k: string, a: string, o: string) => (
  <>
    <path d="M5 2.5h10l4 4v15H5z" fill={a} stroke={k} strokeWidth="1.5" strokeLinejoin="round" />
    <path d="M15 2.5v4h4" fill={o} stroke={k} strokeWidth="1.3" strokeLinejoin="round" />
  </>
);
const cizgi = (k: string, y: number, x2 = 16, w = 1.1) =>
  <line x1="8" y1={y} x2={x2} y2={y} stroke={k} strokeWidth={w} strokeLinecap="round" />;

function cizim(tur: BelgeIkonTuru, k: string, a: string, o: string): ReactNode {
  switch (tur) {
    case 'fatura':
      return <>{sayfa(k, a, o)}{cizgi(k, 8, 12.5, 1.6)}{cizgi(k, 11.5)}{cizgi(k, 14)}
        <circle cx="16.5" cy="18.3" r="3.6" fill={k} />
        <text x="16.5" y="20.4" textAnchor="middle" fontSize="5.6" fontWeight="700" fontFamily="Arial, sans-serif" fill="#fff">₺</text></>;
    case 'fis':
      // Kasa fişi: alt kenarı tırtıklı dar kağıt.
      return <><path d="M6 2.5h12v18l-2-1.4-2 1.4-2-1.4-2 1.4-2-1.4-2 1.4z" fill={a} stroke={k} strokeWidth="1.5" strokeLinejoin="round" />
        <line x1="9" y1="7" x2="15" y2="7" stroke={k} strokeWidth="1.5" strokeLinecap="round" />
        <line x1="9" y1="10.5" x2="15" y2="10.5" stroke={k} strokeWidth="1.1" strokeLinecap="round" />
        <line x1="9" y1="13.5" x2="13" y2="13.5" stroke={k} strokeWidth="1.1" strokeLinecap="round" /></>;
    case 'irsaliye':
      // Kamyon.
      return <><rect x="1.5" y="6" width="13" height="10" rx="1.2" fill={a} stroke={k} strokeWidth="1.5" />
        <path d="M14.5 9h4.2l3.3 3.6V16h-7.5z" fill={o} stroke={k} strokeWidth="1.5" strokeLinejoin="round" />
        <circle cx="6" cy="17.5" r="2.2" fill="#fff" stroke={k} strokeWidth="1.5" />
        <circle cx="17.5" cy="17.5" r="2.2" fill="#fff" stroke={k} strokeWidth="1.5" /></>;
    case 'tahakkuk':
      // Sayfa + onay mührü (tahakkuk = borç/alacak kaydı).
      return <>{sayfa(k, a, o)}{cizgi(k, 8, 12.5, 1.6)}{cizgi(k, 11.5)}
        <circle cx="16" cy="17.5" r="3.8" fill="#fff" stroke={k} strokeWidth="1.4" />
        <path d="M14.2 17.6l1.3 1.3 2.4-2.6" fill="none" stroke={k} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" /></>;
    case 'siparis':
      // Pano (clipboard) + liste.
      return <><rect x="4.5" y="4" width="15" height="18" rx="1.6" fill={a} stroke={k} strokeWidth="1.5" />
        <rect x="8.5" y="2.3" width="7" height="3.6" rx="1" fill={k} />
        <line x1="8" y1="10.5" x2="16" y2="10.5" stroke={k} strokeWidth="1.2" strokeLinecap="round" />
        <line x1="8" y1="13.8" x2="16" y2="13.8" stroke={k} strokeWidth="1.2" strokeLinecap="round" />
        <line x1="8" y1="17.1" x2="13" y2="17.1" stroke={k} strokeWidth="1.2" strokeLinecap="round" /></>;
    case 'teklif':
      // İmzalı / mühürlü zarf (kullanıcı: "satış teklifi ikonu imzalı zarf").
      return <><rect x="1.5" y="5" width="21" height="14" rx="1.6" fill={a} stroke={k} strokeWidth="1.5" />
        <path d="M2 5.8l10 7 10-7" fill="none" stroke={k} strokeWidth="1.4" strokeLinejoin="round" />
        <path d="M4 17 q1.4 -2.4 2.8 0 t2.8 0" fill="none" stroke={k} strokeWidth="1.2" strokeLinecap="round" />
        <circle cx="18" cy="16" r="3" fill={k} />
        <circle cx="18" cy="16" r="1.4" fill="none" stroke="#fff" strokeWidth="0.9" /></>;
    case 'konsinye':
      // Koli.
      return <><path d="M3 7.5l9-4.5 9 4.5v9.5l-9 4.5-9-4.5z" fill={a} stroke={k} strokeWidth="1.5" strokeLinejoin="round" />
        <path d="M3 7.5l9 4.5 9-4.5M12 12v9.5" fill="none" stroke={k} strokeWidth="1.3" strokeLinejoin="round" /></>;
    case 'tahsilat':
    case 'odeme': {
      // Para + ok: tahsilat içeri (aşağı), ödeme dışarı (yukarı).
      const ok = tur === 'tahsilat' ? 'M12 1.5v6m-2.6-2.6L12 7.5l2.6-2.6' : 'M12 7.5v-6m-2.6 2.6L12 1.5l2.6 2.6';
      return <><circle cx="12" cy="15" r="7.5" fill={a} stroke={k} strokeWidth="1.5" />
        <text x="12" y="18.6" textAnchor="middle" fontSize="9.5" fontWeight="700" fontFamily="Arial, sans-serif" fill={k}>₺</text>
        <path d={ok} fill="none" stroke={k} strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" /></>;
    }
  }
}

/** Yönle renklenen belge ikonu. */
export function BelgeIkon({ tur, yon, boyut = 16 }: { tur: BelgeIkonTuru; yon: BelgeYonu; boyut?: number }) {
  const r = RENK[yon];
  return (
    <svg viewBox="0 0 24 24" width={boyut} height={boyut} aria-hidden="true" style={STIL}>
      {cizim(tur, r.koyu, r.acik, r.orta)}
    </svg>
  );
}

/** Menü kodu `@b:<tür>:<s|a>` çözümü (MenuIkon); tanınmazsa null. */
export function belgeIkonKodu(ic: string): { tur: BelgeIkonTuru; yon: BelgeYonu } | null {
  const m = /^@b:(fatura|fis|irsaliye|tahakkuk|siparis|teklif|konsinye|tahsilat|odeme):([sa])$/.exec(ic);
  return m ? { tur: m[1] as BelgeIkonTuru, yon: m[2] as BelgeYonu } : null;
}

/** Fatura (eski `@fatura` kodu - satış yeşili). */
export function FaturaIkon({ boyut = 16 }: { boyut?: number }) {
  return <BelgeIkon tur="fatura" yon="s" boyut={boyut} />;
}

/** Kopya: üst üste iki sayfa - arkadaki gri, öndeki mavi çerçeveli. */
export function KopyaIkon({ boyut = 16 }: { boyut?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={boyut} height={boyut} aria-hidden="true" style={STIL}>
      <rect x="3" y="2.5" width="12" height="15" rx="1.6" fill="#f1f4f8" stroke="#7d8b99" strokeWidth="1.4" />
      <rect x="8.5" y="6.5" width="12" height="15" rx="1.6" fill="#fff" stroke="#2b579a" strokeWidth="1.6" />
      <line x1="11.5" y1="11" x2="17.5" y2="11" stroke="#2b579a" strokeWidth="1.2" strokeLinecap="round" />
      <line x1="11.5" y1="14" x2="17.5" y2="14" stroke="#2b579a" strokeWidth="1.2" strokeLinecap="round" />
      <line x1="11.5" y1="17" x2="15.5" y2="17" stroke="#2b579a" strokeWidth="1.2" strokeLinecap="round" />
    </svg>
  );
}
