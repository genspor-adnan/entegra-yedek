import type { ReactNode } from 'react';
import { useCariSatiri } from './cariSatiri';
import { para } from './bicim';
import { Avatar, dovizBakiyeMetni } from './grid/satirHucre';
import { c } from '../dil/ceviri';

/**
 * CARİ BİLGİ BANDI (kullanıcı 26.10.2026: "tahsilat/ödeme/ekstre kartına firma için ince bilgi kartı yap" →
 * "bilgi bandı olacaktı", "avatarlı falan"): hasta kartı bandı (HastaKartBandi) deseninde tek satır - avatar,
 * ünvan, kod · VKN · telefon · il · temsilci · e-Fatura; sağda bakiye / vadesi geçen / risk rozetleri.
 * Veri cari listesinin satırından (aynı kaynak, yetki ve şube kuralı); `bakiyesiz` ekstrede (kutular zaten var).
 */
const STIL = `
.cbb { display: flex; gap: 10px; align-items: center; padding: 5px 12px; margin: 0 0 8px; background: var(--yuz, #fff);
  border: 1px solid var(--cizgi2, #e3e9f0); border-radius: 6px }
.cbb .gh-av.buyuk { width: 34px; height: 34px; font-size: 13px; flex: none }
.cbb-govde { flex: 1; min-width: 0 }
.cbb-ad { font-size: 14px; font-weight: bold; color: var(--lacivert, #14315a); white-space: nowrap; overflow: hidden; text-overflow: ellipsis }
.cbb-kalem { border: 0; background: none; padding: 0 4px; margin-left: 4px; cursor: pointer; color: var(--soluk, #6b7a8b);
  font-size: 13px; line-height: 1; vertical-align: baseline }
.cbb-kalem:hover, .cbb-kalem[aria-pressed="true"] { color: var(--mor, #3b5bdb) }
.cbb-ac { cursor: pointer; display: inline-flex }
.cbb-ad .cbb-ac:hover { text-decoration: underline }
.cbb-alt { color: var(--soluk, #6b7a8b); font-size: 11.5px; margin-top: 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis }
.cbb-alt b { color: var(--yazi, #1f2d3a); font-weight: normal }
.cbb-alt .cbb-rozet { margin-left: 8px; padding: 1px 7px; font-size: 10.5px; vertical-align: 1px }
.cbb-rz { display: flex; gap: 6px; flex-wrap: wrap; justify-content: flex-end; flex: none }
.cbb-rz span { border-radius: 10px; padding: 2px 9px; font-size: 11.5px; background: #eef4fb; color: #2c4a6b; white-space: nowrap }
.cbb-rz span.kir { background: #fdecec; color: #b3261e }
.cbb-rz span.yes { background: #e2f3e8; color: #2e7d46 }
`;

const isaret = (n: number) => (n > 0.005 ? ' B' : n < -0.005 ? ' A' : '');

export function CariBilgiBandi({ id, tazele = 0, bakiyesiz, tedarikci, adYani, durumlu, sagEk, sonEk, bakiyeKutu, onBakiye, onKartAc }: {
  id: number; tazele?: number; bakiyesiz?: boolean;
  /** Tedarikçi gözü: bakiye "borcumuz" (A = biz borçluyuz) okunur. */
  tedarikci?: boolean;
  /** Ünvanın hemen sağında (ör. cari kartında kimlik alanlarını açan kalem). */
  adYani?: ReactNode;
  /** Cari kartı: Temsilci (boşsa —) ve Durum (Aktif / Pasif) her zaman yazılır - combolar düzenlemede açılır. */
  durumlu?: boolean;
  /** Bakiyenin SOLUNDA ek kutular (belge kartı: e-Belge / Faturalama durumu, kullanıcı 02.11.2026). */
  sagEk?: ReactNode;
  /** Bakiyenin SAĞINDA, bandın en sonunda (fatura başlığı ✎ düğmesi, 08.11.2026). */
  sonEk?: ReactNode;
  /** Bakiye rozet yerine KUTU (belge kartı, mockup alis_faturasi_cari_baslik.html): Borcumuz / Bakiye + vadesi geçen. */
  bakiyeKutu?: boolean;
  /** Bakiye kutusuna tıklanınca (ör. cari ekstresi). */
  onBakiye?(): void;
  /** Avatar / ünvana tıklanınca cari kartı (belge kartı, cari görme yetkisi varsa; kullanıcı 02.11.2026). */
  onKartAc?(): void;
}) {
  const s = useCariSatiri(id, tazele);
  if (!s) return null;

  const ad = String(s.unvan ?? '');
  const tel = String(s.cepTel || s.telefon || '');
  const bakiye = Number(s.bakiye ?? 0), vade = Number(s.vadesiGecen ?? 0);
  const risk = s.riskYuzde == null ? null : Number(s.riskYuzde);
  const doviz = dovizBakiyeMetni(s.dovizBakiye);
  const ted = tedarikci ?? (Number(s.tedarikci) === 1 && Number(s.musteri) !== 1);
  // ETİKETSİZ ALT SATIR (kullanıcı 08.11.2026: "kod vkn il gibi labelleri kaldır, aktif ve e-faturayı rozet yap"):
  //   yalnız değerler · ile; temsilci adı tek başına okunmaz diye "Temsilci" öneki kalır. Durum ve e-Fatura/e-Arşiv rozet.
  const temsilci = String(s.temsilci ?? '');
  const alt: string[] = [
    String(s.kod ?? ''), String(s.vkno ?? ''), tel, String(s.il ?? ''),
    temsilci || durumlu ? `${c('Temsilci')} ${temsilci || '—'}` : '',
  ].filter(v => v.trim() !== '');
  const aktif = Number(s.durum ?? 1) === 1;

  return (
    <div className="cbb">
      <style>{STIL}</style>
      <span className={onKartAc ? 'cbb-ac' : undefined} onClick={onKartAc} title={onKartAc ? c('Cari kartını aç') : undefined}>
        <Avatar ad={ad} buyuk kurumsal soluk={Number(s.durum ?? 1) !== 1} /></span>
      <div className="cbb-govde">
        <div className="cbb-ad" title={onKartAc ? c('Cari kartını aç') : ad}>
          {onKartAc ? <span className="cbb-ac" onClick={onKartAc}>{ad}</span> : ad}{adYani}</div>
        <div className="cbb-alt">
          {alt.map((v, i) => <span key={i}>{i > 0 ? ' · ' : ''}<b>{v}</b></span>)}
          {(durumlu || !aktif) && <span className={`rozet cbb-rozet ${aktif ? 'ok' : 'gri'}`}>{aktif ? c('Aktif') : c('Pasif')}</span>}
          <span className="rozet cbb-rozet bilgi">{Number(s.efatura) === 1 ? 'e-Fatura' : 'e-Arşiv'}</span>
        </div>
      </div>
      {sagEk}
      {!bakiyesiz && bakiyeKutu && (
        <div className={`bdk${vade > 0.005 ? ' hata' : ''}`} title={onBakiye ? c('Cari ekstresini aç') : undefined}
             onClick={onBakiye}>
          <span className="bdk-e">{ted ? c('Borcumuz') : c('Bakiye')}</span>
          <span className={`bdk-v${ted ? (bakiye < -0.005 ? ' bdk-kir' : '') : (bakiye > 0.005 ? ' bdk-kir' : bakiye < -0.005 ? ' bdk-yes' : '')}`}
                title={doviz || undefined}>{para.format(Math.abs(bakiye))}{isaret(bakiye)}</span>
          <span className="bdk-a">{doviz || (vade > 0.005 ? `${c('vadesi geçen')} ${para.format(vade)}`
            : !ted && risk !== null ? `${c('risk')} %${Math.round(risk)}` : c('cari bakiye'))}</span>
        </div>)}
      {!bakiyesiz && !bakiyeKutu && (
        <div className="cbb-rz">
          <span className={ted ? (bakiye < -0.005 ? 'kir' : '') : (bakiye > 0.005 ? 'kir' : bakiye < -0.005 ? 'yes' : '')}
                title={doviz || undefined}>
            {ted ? c('Borcumuz') : c('Bakiye')} {para.format(Math.abs(bakiye))}{isaret(bakiye)}{doviz ? ` · ${doviz}` : ''}</span>
          {!ted && vade > 0.005 && <span className="kir">{c('Vadesi geçen')} {para.format(vade)}</span>}
          {!ted && risk !== null && <span className={risk > 100 ? 'kir' : ''}>{c('Risk')} %{Math.round(risk)}</span>}
        </div>)}
      {sonEk}
    </div>
  );
}
