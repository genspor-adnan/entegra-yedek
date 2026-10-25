import { useContext, type ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import type { FaturasizIrsaliye, ParaTablosu } from '../../api/uclar/ticariIcmal';
import { para } from '../../bilesenler/bicim';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { Kutucuk } from '../stokIcmal/stokIcmalOrtak';

/**
 * SATIŞ / ALIŞ İCMALİNİN ORTAĞI - görünüm yardımcıları. Rakamlar sunucudan
 * (TicariIcmalUclari); bu dosya yalnız biçimler ve gezinir, hesap yapmaz.
 */
export const tl = (n: number) => para.format(n);
export const sayi = (n: number | null | undefined) => (n == null ? '—' : n.toLocaleString('tr-TR', { maximumFractionDigits: 3 }));
export const kur = (n: number | null | undefined) => (n == null ? '—' : n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 4 }));
export const tarihT = (t: string | null | undefined) => (t ? new Date(t).toLocaleDateString('tr-TR') : '—');
export const yuzde = (n: number | null | undefined, isaret = false) =>
  n == null ? '—' : `${isaret && n > 0 ? '+' : n < 0 ? '−' : ''}%${Math.abs(n).toLocaleString('tr-TR', { maximumFractionDigits: 1 })}`;
/** Para birimi simgesi: TL karşılığında ₺, tek döviz seçiliyse ISO kodu. */
export const simge = (p: string) => (!p || p === 'TL' || p === 'TRY' ? '₺' : p === 'EUR' ? '€' : p === 'USD' ? '$' : p === 'GBP' ? '£' : p);
export const kisa = (n: number, p: string) =>
  `${Math.abs(n) >= 1e6 ? `${(n / 1e6).toLocaleString('tr-TR', { maximumFractionDigits: 2 })} M` : tl(n)} ${simge(p)}`;
export const eksi = (n: number) => (Math.abs(n) < 0.005 ? '—' : `−${tl(Math.abs(n))}`);
export const ayAdi = (t: string) => new Date(t).toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' });

/** Değişim rozeti: artış iyi (satış) / kötü (alış) - yon ile. */
export function DegisimRozeti({ d, yeni, ters }: { d: number | null; yeni?: boolean; ters?: boolean }) {
  if (yeni) return <span className="bo-rz mavi">yeni</span>;
  if (d == null) return <span className="ki-soluk">—</span>;
  const iyi = ters ? d <= 0 : d >= 0;
  const sinif = Math.abs(d) < 0.05 ? 'pas' : ters && d > 0 && d < 10 ? 'sari' : iyi ? 'ok' : 'kir';
  return <span className={'bo-rz ' + sinif}>{yuzde(d, true)}</span>;
}

export const DovizRozetleri = ({ l }: { l: { para: string; tutar: number }[] }) => (
  <>{l.map(x => <span key={x.para} className="bo-rz mavi" style={{ marginLeft: 4 }}>{simge(x.para)} {tl(x.tutar)}</span>)}</>
);

/** Cari kartı, cari ekstresi ve belge kartı (kart sekmesi deseni: kendi sekmesinde). */
export function useGezinti() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  const kart = (yol: string) => { if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol) };
  return {
    git,
    cariKarti: (id: number, yalnizTedarikci = false) => id > 0 && kart(`${yalnizTedarikci ? '/tedarikci' : '/cari'}/${id}`),
    ekstre: (id: number) => id > 0 && git(`/ekstre?tur=cari&id=${id}`),
    belgeKarti: (id: number) => id > 0 && kart(`/belge/${id}`),
    stokKarti: (id: number) => id > 0 && kart(`/stok/${id}`),
  };
}

/** Para birimi tablosu (TL karşılığı belge kuruyla; kur farkı yalnız açık alacak / borç). */
export function ParaTablosuGorunumu({ t, satis }: { t: ParaTablosu; satis: boolean }) {
  const farkSinif = (n: number | null) => (n == null || Math.abs(n) < 0.005 ? 'ki-soluk' : (satis ? n > 0 : n < 0) ? 'si-yesil' : 'kir');
  return (
    <table className="hi-tablo">
      <thead><tr><th>Para birimi</th><th className="sag">Belge</th><th className="sag">Döviz tutarı</th>
        <th className="sag">Ort. {satis ? 'satış' : 'alış'} kuru</th><th className="sag">TL karşılığı</th><th className="sag">Pay</th>
        <th className="sag">Açık {satis ? 'alacak' : 'borç'} (döviz)</th><th className="sag">Bugünkü kur</th>
        <th className="sag">Açığın bugünkü değeri</th><th className="sag">Kur farkı</th></tr></thead>
      <tbody>
        {t.satirlar.length === 0 && <tr><td colSpan={10} className="bos">Bu dönemde belge yok.</td></tr>}
        {t.satirlar.map(s => (
          <tr key={s.para}>
            <td>{s.para}</td><td className="sag">{s.belge}</td>
            <td className="sag">{s.doviz == null ? '—' : `${simge(s.para)} ${tl(s.doviz)}`}</td>
            <td className="sag">{kur(s.ortKur)}</td><td className="sag">{tl(s.tl)}</td><td className="sag">%{sayi(s.pay)}</td>
            <td className="sag">{s.acikDoviz == null ? '—' : `${simge(s.para)} ${tl(s.acikDoviz)}`}</td>
            <td className="sag">{kur(s.bugunkuKur)}</td>
            <td className="sag">{s.acikBugun == null ? '—' : tl(s.acikBugun)}</td>
            <td className={'sag ' + farkSinif(s.kurFarki)}>{s.kurFarki == null ? '—' : `${s.kurFarki > 0 ? '+' : ''}${tl(s.kurFarki)}`}</td>
          </tr>
        ))}
        <tr className="top"><td>Toplam</td><td className="sag">{t.toplam.belge}</td><td /><td /><td className="sag">{tl(t.toplam.tl)}</td>
          <td className="sag">%100</td><td /><td /><td className="sag">{tl(t.toplam.acikBugun)}</td>
          <td className={'sag ' + farkSinif(t.toplam.kurFarki)}>{`${t.toplam.kurFarki > 0 ? '+' : ''}${tl(t.toplam.kurFarki)}`}</td></tr>
      </tbody>
    </table>
  );
}

export function FaturasizKutusu({ v, baslik, belgeAc }: { v: FaturasizIrsaliye; baslik: string; belgeAc(id: number): void }) {
  return (
    <Kutucuk baslik={baslik} not={`${v.sayi} irsaliye · ${tl(v.tutar)} ₺ · KDV hariç, açık kısım`}>
      <table className="hi-tablo"><thead><tr><th>İrsaliye</th><th>Cari</th><th>Tarih</th><th className="sag">Tutar</th><th className="orta">Gün</th></tr></thead>
        <tbody>
          {v.liste.length === 0 && <tr><td colSpan={5} className="bos">Faturası bekleyen irsaliye yok.</td></tr>}
          {v.liste.map(x => (
            <tr key={x.id} className="ac" onDoubleClick={() => belgeAc(x.id)}>
              <td>{x.no || `#${x.id}`}</td><td>{x.cari}</td><td>{tarihT(x.tarih)}</td><td className="sag">{tl(x.tutar)}</td>
              <td className="orta"><span className={'bo-rz ' + (x.gun > 15 ? 'kir' : x.gun > 7 ? 'sari' : 'pas')}>{x.gun}</span></td></tr>
          ))}
          {v.sayi > v.liste.length && <tr><td colSpan={5} className="bos">… {v.sayi - v.liste.length} irsaliye daha</td></tr>}
        </tbody></table>
    </Kutucuk>
  );
}

/** Ekrandaki A4 sekmesi: yazdırmada gizli (yazdırma CiktiMenusu'nun kendi kopyasından). */
export const EkranA4 = ({ children }: { children: ReactNode }) => (
  <div className="ti-onz"><div className="ti-ekran-a4">{children}</div></div>
);

export const TICARI_ICMAL_STILI = `
.ti-onz { background:#dfe5ec; padding:16px; display:flex; justify-content:center; }
.ti-ekran-a4 { width:100%; max-width:794px; }
@media print { .ti-ekran-a4, .ti-onz { display:none !important; } }
.hi-tablo tr.ti-sec td { background:#eef4fc; }
.hi-tablo td.ti-ad { white-space:nowrap; }
.ti-dip { margin-left:auto; width:55%; margin-top:6px; }
.ti-dip div { display:flex; justify-content:space-between; border-bottom:1px dotted #c9d2dc; padding:1px 0; }
.ti-dip .b { font-weight:bold; font-size:12px; color:#14315a; border-bottom:none; }
.ti-dip .not { font-size:9px; color:#6b7a8b; border-bottom:none; }
.a4-t.ti-a4t td:nth-child(n+2), .a4-t.ti-a4t th:nth-child(n+2) { text-align:right; }
.a4-t.ti-a4t td:first-child, .a4-t.ti-a4t th:first-child { text-align:left; }
.hi-serit .ti-chk { display:flex; align-items:center; gap:4px; font-size:12px; color:#4d5d6e; }
`;
