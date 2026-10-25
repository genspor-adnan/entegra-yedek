import { useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { tl } from '../stokIcmal/stokIcmalOrtak';

/**
 * FİNANS İCMALLERİNİN ORTAĞI (Tahsilat / Ödeme, Nakit Akış). Görünüm yardımcıları;
 * rakamlar sunucudan (FinansIcmalUclari), ekran hesap yapmaz. Kutu / sekme / ısı
 * yardımcıları stok icmalleriyle ortak (stokIcmalOrtak).
 */

/** İşaretli tutar: +1.234,00 / −1.234,00. */
export const isaretli = (n: number) => (n > 0 ? '+' : n < 0 ? '−' : '') + tl(Math.abs(n));

/** Ödeme aracı ikonu (sunucu anahtarından - yalnız görünüm). */
export const ARAC_IKON: Record<string, string> = {
  havale: '🏦', pos: '💳', kart: '💳', cek: '🧾', senet: '📜', ciro: '↪', nakit: '💵', kupon: '🎟', diger: '•',
};

/** Hesap türü ikonu. */
export const HESAP_IKON: Record<string, string> = { K: '💵', B: '🏦', P: '💳', V: '💳' };

/** Cari kartını kendi sekmesinde açar (kart sekmesi deseni); yalnız tedarikçi olan Tedarikçi kartında. */
export function useCariKarti() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  return (id: number, tedarikci = false) => {
    if (!id) return;
    const yol = `${tedarikci ? '/tedarikci' : '/cari'}/${id}`;
    if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol);
  };
}

/** Belge / çek kartı (kart sekmesi deseni). */
export function useKartAc() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  return (yol: string) => { if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol) };
}

export const FINANS_ICMAL_STILI = `
.fi-chk { display:flex; align-items:center; gap:4px; font-size:12px; color:#4d5d6e; white-space:nowrap; }
.hi-tablo tr.fi-eksi td { background:#fbe9e7; }
.hi-tablo tr.fi-alt td { background:#f9fbfd; font-size:11px; color:#3a4c5e; }
.hi-tablo tr.fi-alt td:first-child { padding-left:22px; }
.hi-tablo tr.fi-sec td { background:#d7e7fb; }
.fi-ipucu { padding:6px 10px; font-size:11px; color:#6b7a8b; background:#fff; border-top:1px solid #e3e9f0; line-height:1.55; }
.fi-senaryo td:last-child { white-space:nowrap; }
.fi-senaryo select, .fi-senaryo input[type=number] { border:1px solid #cdd6e0; border-radius:3px; font-size:12px; padding:1px 4px; }
.fi-hesaplar { position:relative; }
.fi-hesaplar .fi-acilir { position:absolute; z-index:20; top:100%; left:0; background:#fff; border:1px solid #cdd6e0; border-radius:4px;
  box-shadow:0 4px 14px rgba(20,40,70,.16); padding:6px 8px; max-height:320px; overflow:auto; min-width:280px; }
.fi-hesaplar .fi-acilir label { display:flex; gap:6px; align-items:center; padding:2px 0; font-size:12px; white-space:nowrap; }
`;
