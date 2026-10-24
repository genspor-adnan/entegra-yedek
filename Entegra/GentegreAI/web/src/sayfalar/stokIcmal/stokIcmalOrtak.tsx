import { useCallback, useContext, useEffect, useState, type ReactNode } from 'react';
import { useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { para } from '../../bilesenler/bicim';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { useNavigate } from 'react-router-dom';

/**
 * STOK İCMALLERİNİN ORTAĞI (1173 - Stok Değer, SKT / Lot, Sayım Fark). Görünüm ve
 * süzgeç yardımcıları; rakamlar sunucudan (StokIcmalUclari), ekran hesap yapmaz.
 * Tasarım dili diğer icmallerle aynı (hasta / kurum icmal stilleri + aşağıdaki ekler).
 */
export const tl = (n: number) => para.format(n);
export const sayi = (n: number) => n.toLocaleString('tr-TR', { maximumFractionDigits: 3 });
export const kisaTl = (n: number) => (Math.abs(n) >= 1e6 ? `${(n / 1e6).toLocaleString('tr-TR', { maximumFractionDigits: 2 })} M ₺` : `${tl(n)} ₺`);
export const tarihT = (t: string | null | undefined) => (t ? new Date(t).toLocaleDateString('tr-TR') : '—');
export const ayYil = (t: string | null | undefined) => (t ? new Date(t).toLocaleDateString('tr-TR', { month: '2-digit', year: 'numeric' }) : '—');
export const IZLEME_ADI: Record<number, string> = {
  1: 'Seri No', 2: 'Lot No', 3: 'SKT', 4: 'Karekod', 5: 'Lot No + SKT', 6: 'Seri + Lot',
};

/** URL'deki süzgeçler: değişiklik adres çubuğuna yazılır (sekme yenilenince kalır). */
export function useSuzgec() {
  const [arama, setArama] = useSearchParams();
  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true });
  }, [arama, setArama]);
  return { arama, degistir };
}

/** Kurum anteti (A4). */
export function useAntet() {
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);
  return antet;
}

/** Stok kartını kendi sekmesinde açar (kart sekmesi deseni). */
export function useStokKarti() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  return (id: number) => { const yol = `/stok/${id}`; if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol) };
}

export const Kutu = ({ bas, deg, alt, sinif = '' }: { bas: string; deg: string; alt: string; sinif?: string }) => (
  <div className={'hi-kutu ' + sinif}><div className="bas">{bas}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
);

export function Sekmeler<T extends string>({ liste, secili, sec }: {
  liste: [T, string, number | null][]; secili: T; sec(k: T): void;
}) {
  return (
    <div className="katab">
      {liste.map(([k, ad, n]) => (
        <div key={k} className={'kat' + (secili === k ? ' on' : '')} onClick={() => sec(k)}>
          {ad}{n != null && <span className="b">{n}</span>}
        </div>
      ))}
    </div>
  );
}

/** Başlıklı kutu (dikkat / kırılım listeleri). */
export const Kutucuk = ({ baslik, not, children }: { baslik: string; not?: string; children: ReactNode }) => (
  <div className="si-kutu"><h4>{baslik}{not && <span>{not}</span>}</h4>{children}</div>
);

export const Cubuk = ({ yuzde, renk }: { yuzde: number; renk?: string }) => (
  <div className="si-cubuk"><i style={{ width: `${Math.max(0, Math.min(100, yuzde))}%`, ...(renk ? { background: renk } : {}) }} /></div>
);

export const STOK_ICMAL_STILI = `
.hi-serit select, .hi-serit input[type=date] { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:240px; }
.si-seg { display:flex; border:1px solid #cdd6e0; border-radius:13px; overflow:hidden; background:#fff; }
.si-seg button { border:0; border-right:1px solid #e3e9f0; background:none; padding:4px 12px; font-size:12px; color:#4d5d6e; cursor:pointer; }
.si-seg button:last-child { border-right:0; }
.si-seg button.on { background:linear-gradient(#4d8fd6,#2f6db3); color:#fff; font-weight:bold; }
.si-iki { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:12px; }
.si-kutu { border:1px solid #e3e9f0; border-radius:4px; overflow:hidden; background:#fff; margin-bottom:12px; }
.si-iki .si-kutu { margin-bottom:0; }
.si-kutu h4 { margin:0; padding:7px 10px; font-size:12px; background:linear-gradient(#f6f9fc,#eef3f9); border-bottom:1px solid #e3e9f0; color:#2c4a6b; display:flex; gap:8px; }
.si-kutu h4 span { margin-left:auto; font-weight:normal; font-size:11px; color:#6b7a8b; }
.si-cubuk { height:8px; border-radius:4px; background:#e7edf4; overflow:hidden; min-width:90px; }
.si-cubuk i { display:block; height:100%; background:linear-gradient(90deg,#4d8fd6,#2f6db3); }
.hi-tablo tr.si-grup td { background:#f1f5fa; font-weight:bold; color:#2c4a6b; }
.hi-tablo tr.si-det td { background:#f9fbfd; font-size:11px; color:#3a4c5e; padding-left:26px; white-space:normal; }
.hi-tablo .ok { cursor:pointer; display:inline-block; width:12px; color:#2f6db3; }
.hi-tablo .si-yesil, .si-yesil { color:#2e7d46; }
.hi-tablo td.si-isi { text-align:right; }
.si-not { margin:8px 2px; font-size:11px; line-height:1.6; }
.hi .lnk { color:#2f6db3; text-decoration:underline; cursor:pointer; }
.a4-t.si-a4t td:nth-child(n+2), .a4-t.si-a4t th:nth-child(n+2) { text-align:right; }
.a4-t.si-a4t td:first-child, .a4-t.si-a4t th:first-child { text-align:left; }
@media (max-width: 1000px) { .si-iki { grid-template-columns:1fr; } }
`;

/** Isı haritası hücresi rengi (değere göre 4 kademe). */
export const isiRengi = (deger: number, enBuyuk: number) => {
  if (enBuyuk <= 0 || deger <= 0) return undefined;
  const o = deger / enBuyuk;
  return o > 0.6 ? '#8fb8ea' : o > 0.3 ? '#b7d3f4' : o > 0.1 ? '#d7e7fb' : '#eef5fd';
};
