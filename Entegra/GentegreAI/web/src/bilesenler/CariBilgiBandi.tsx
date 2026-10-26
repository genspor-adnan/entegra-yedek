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
.cbb-alt { color: var(--soluk, #6b7a8b); font-size: 11.5px; margin-top: 1px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis }
.cbb-alt b { color: var(--yazi, #1f2d3a); font-weight: normal }
.cbb-rz { display: flex; gap: 6px; flex-wrap: wrap; justify-content: flex-end; flex: none }
.cbb-rz span { border-radius: 10px; padding: 2px 9px; font-size: 11.5px; background: #eef4fb; color: #2c4a6b; white-space: nowrap }
.cbb-rz span.kir { background: #fdecec; color: #b3261e }
.cbb-rz span.yes { background: #e2f3e8; color: #2e7d46 }
`;

const isaret = (n: number) => (n > 0.005 ? ' B' : n < -0.005 ? ' A' : '');

export function CariBilgiBandi({ id, tazele = 0, bakiyesiz, tedarikci }: {
  id: number; tazele?: number; bakiyesiz?: boolean;
  /** Tedarikçi gözü: bakiye "borcumuz" (A = biz borçluyuz) okunur. */
  tedarikci?: boolean;
}) {
  const s = useCariSatiri(id, tazele);
  if (!s) return null;

  const ad = String(s.unvan ?? '');
  const tel = String(s.cepTel || s.telefon || '');
  const bakiye = Number(s.bakiye ?? 0), vade = Number(s.vadesiGecen ?? 0);
  const risk = s.riskYuzde == null ? null : Number(s.riskYuzde);
  const doviz = dovizBakiyeMetni(s.dovizBakiye);
  const ted = tedarikci ?? (Number(s.tedarikci) === 1 && Number(s.musteri) !== 1);
  const alt: [string, string][] = ([
    [c('Kod'), String(s.kod ?? '')],
    [c('VKN / TCKN'), String(s.vkno ?? '')],
    [c('Tel'), tel],
    [c('İl'), String(s.il ?? '')],
    [c('Temsilci'), String(s.temsilci ?? '')],
  ] as [string, string][]).filter(([, v]) => v.trim() !== '');

  return (
    <div className="cbb">
      <style>{STIL}</style>
      <Avatar ad={ad} buyuk soluk={Number(s.durum ?? 1) !== 1} />
      <div className="cbb-govde">
        <div className="cbb-ad" title={ad}>{ad}</div>
        <div className="cbb-alt">
          {alt.map(([e, v], i) => <span key={e}>{i > 0 ? ' · ' : ''}{e} <b>{v}</b></span>)}
          {alt.length ? ' · ' : ''}{Number(s.efatura) === 1 ? 'e-Fatura' : 'e-Arşiv'}
          {Number(s.durum ?? 1) !== 1 ? ` · ${c('Pasif')}` : ''}
        </div>
      </div>
      {!bakiyesiz && (
        <div className="cbb-rz">
          <span className={ted ? (bakiye < -0.005 ? 'kir' : '') : (bakiye > 0.005 ? 'kir' : bakiye < -0.005 ? 'yes' : '')}
                title={doviz || undefined}>
            {ted ? c('Borcumuz') : c('Bakiye')} {para.format(Math.abs(bakiye))}{isaret(bakiye)}{doviz ? ` · ${doviz}` : ''}</span>
          {!ted && vade > 0.005 && <span className="kir">{c('Vadesi geçen')} {para.format(vade)}</span>}
          {!ted && risk !== null && <span className={risk > 100 ? 'kir' : ''}>{c('Risk')} %{Math.round(risk)}</span>}
        </div>)}
    </div>
  );
}
