import { useMemo } from 'react';
import type { DokumKolonMeta, DokumTanimi, ListeYaniti, OzetYaniti } from '../../api/sozlesme';
import { bicimle } from '../../bilesenler/bicim';
import type { KolonMeta } from '../../api/sozlesme';
import {
  boyutDegerMetni, boyutEtiketi, delta, deltaMetni, kiyasAnahtari, listeyiGrupla,
  olcuBicimle, pivotla, toplanabilirMi,
} from './ortak';

/**
 * DÖKÜM SONUCU (686): liste çıktısını gruplu/ara toplamlı tablo, özet
 * çıktısını çapraz tablo (+ kıyas Δ) ve çubuk grafik olarak çizer.
 *
 * ÖNİZLEME ve BASKI aynı bileşeni kullanır (`baski` yalnız sınıf adlarını ve
 * satır tavanını değiştirir) - ekranda görülen rakam kâğıttakinden sapamaz.
 */

export const ozetMi = (y: ListeYaniti | OzetYaniti | null): y is OzetYaniti =>
  !!y && 'boyutlar' in y;

const kolonMeta = (k: DokumKolonMeta): KolonMeta => ({
  ad: k.ad, baslik: k.baslik, tip: k.tip, hizalama: k.tip === 'para' || k.tip === 'sayi' ? 'sag' : 'sol',
  bicim: k.tip === 'para' ? '#,##0.00' : null, varsayilan: true, siralanabilir: k.siralanabilir,
  filtrelenebilir: k.filtrelenebilir, kodlar: k.kodlar,
});

export function ListeSonucu({ yanit, tanim, kolonlar, baski, gizli }: {
  yanit: ListeYaniti; tanim: DokumTanimi; kolonlar: DokumKolonMeta[]; baski?: boolean;
  gizli?: string[];
}) {
  const secili = useMemo(() => {
    const adlar = (tanim.kolonlar?.length ? tanim.kolonlar : kolonlar.map(k => k.ad))
      .filter(a => !(gizli ?? []).includes(a));
    return adlar.map(a => kolonlar.find(k => k.ad === a)).filter((k): k is DokumKolonMeta => !!k);
  }, [tanim.kolonlar, kolonlar, gizli]);
  const toplam = useMemo(() => (tanim.toplam ?? []).filter(t => secili.some(k => k.ad === t)),
    [tanim.toplam, secili]);
  const araToplam = tanim.baski?.araToplam ?? true;
  const satirlar = useMemo(
    () => listeyiGrupla(yanit.satirlar, araToplam ? (tanim.grup ?? []) : [], toplam, kolonlar),
    [yanit.satirlar, tanim.grup, toplam, kolonlar, araToplam]);
  const sagMi = (k: DokumKolonMeta) => k.tip === 'para' || k.tip === 'sayi' || k.tip === 'ondalik';
  const ilkToplamIdx = secili.findIndex(k => toplam.includes(k.ad));
  const onKolon = ilkToplamIdx < 0 ? secili.length : ilkToplamIdx;

  // Toplam bicimi kolon TIPINDEN: sayi (test adedi) tam, para iki hane -
  //   "70,00 test" yaziliyordu.
  const bicim = (k: DokumKolonMeta) => (k.tip === 'para' || k.tip === 'ondalik') ? '#,##0.00' : '#,##0';
  const toplamHucreleri = (t: Record<string, number> | undefined) =>
    secili.slice(onKolon).map(k => (
      <td key={k.ad} className="sag">
        {toplam.includes(k.ad) && t ? olcuBicimle(t[k.ad], bicim(k)) : ''}
      </td>
    ));

  return (
    <table className={baski ? 'dk-kagit-tablo' : 'detay-tablo dk-sonuc'}>
      <thead><tr>
        {secili.map(k => <th key={k.ad} className={sagMi(k) ? 'sag' : ''}>{k.baslik}</th>)}
      </tr></thead>
      <tbody>
        {satirlar.map((s, i) => {
          if (s.tur === 'satir') {
            return (
              <tr key={i} className={i % 2 ? 'zebra' : ''}>
                {secili.map(k => (
                  <td key={k.ad} className={sagMi(k) ? 'sag' : ''}>
                    {bicimle(s.satir![k.ad], kolonMeta(k))}
                  </td>
                ))}
              </tr>
            );
          }
          const sinif = s.tur === 'grup' ? `g${s.seviye}` : 'ara';
          return (
            <tr key={i} className={sinif}>
              <td colSpan={onKolon || 1}>
                {s.tur === 'ara' ? `${s.etiket} ara toplam (${s.adet})` : `${s.etiket} — ${s.adet} kayıt`}
              </td>
              {toplamHucreleri(s.toplam)}
            </tr>
          );
        })}
        {satirlar.length === 0 && (
          <tr><td colSpan={secili.length || 1} className="bos">Koşullara uyan kayıt yok.</td></tr>
        )}
        {yanit.toplamlar && toplam.length > 0 && (
          <tr className="toplam">
            <td colSpan={onKolon || 1}>TOPLAM · {yanit.toplamKayit.toLocaleString('tr-TR')} kayıt</td>
            {secili.slice(onKolon).map(k => (
              <td key={k.ad} className="sag">
                {toplam.includes(k.ad) ? olcuBicimle(yanit.toplamlar![k.ad], bicim(k)) : ''}
              </td>
            ))}
          </tr>
        )}
      </tbody>
    </table>
  );
}

export function OzetSonucu({ yanit, tanim, kolonlar, baski }: {
  yanit: OzetYaniti; tanim: DokumTanimi; kolonlar: DokumKolonMeta[]; baski?: boolean;
}) {
  const satirBoyut = tanim.boyut?.satir ?? [];
  const sutunBoyut = tanim.boyut?.sutun ?? null;
  const pivot = useMemo(() => pivotla(yanit, satirBoyut.length), [yanit, satirBoyut.length]);
  const kiyas = useMemo(() => {
    const m = new Map<string, Record<string, unknown>>();
    for (const r of yanit.kiyas ?? []) m.set(kiyasAnahtari(r, yanit.boyutlar), r);
    return m;
  }, [yanit]);
  const kiyasVar = !!yanit.kiyas && yanit.kiyas.length >= 0 && tanim.kiyas !== 'yok';
  // Çapraz tabloda ilk ölçü hücreye yazılır; diğer ölçüler satır sonunda
  //   (sütun boyutu yokken hepsi yan yana).
  const olculer = yanit.olculer;
  const ilk = olculer[0];
  const sutunlu = !!sutunBoyut && pivot.sutunlar.length > 0;
  const ilkKiyas = (r: Record<string, unknown>) => kiyas.get(kiyasAnahtari(r, yanit.boyutlar));

  return (
    <table className={baski ? 'dk-kagit-tablo' : 'detay-tablo dk-sonuc'}>
      <thead><tr>
        {satirBoyut.map(b => <th key={b}>{boyutEtiketi(b, kolonlar)}</th>)}
        {sutunlu
          ? pivot.sutunlar.map(s => <th key={s} className="sag">{boyutDegerMetni(s, sutunBoyut!, kolonlar)}</th>)
          : null}
        {sutunlu && ilk && toplanabilirMi(ilk) && <th className="sag">Toplam</th>}
        {sutunlu && ilk && toplanabilirMi(ilk) && <th className="sag">Pay</th>}
        {(sutunlu ? olculer.slice(1) : olculer).map(o => (
          <th key={o.ad} className="sag">{o.baslik}{o.fn === 'tekil' && sutunlu ? ' ≈' : ''}</th>
        ))}
        {kiyasVar && ilk && <th className="sag">{yanit.kiyasAraligi || 'Kıyas'}</th>}
        {kiyasVar && ilk && <th className="sag">Δ</th>}
      </tr></thead>
      <tbody>
        {pivot.satirlar.map((s, i) => {
          const tekHucre = !sutunlu ? s.hucre[''] : undefined;
          const satirIlk = ilk ? (sutunlu ? s.toplam[ilk.ad] : tekHucre?.[ilk.ad]) : undefined;
          // Kıyas: sütunlu tabloda satır toplamı ile kıyas satırlarının toplamı.
          let kiyasDeger: unknown;
          if (kiyasVar && ilk) {
            if (sutunlu) {
              // Eşleşen kıyas satırı hiç yoksa "—": sıfır yazmak "geçen yıl
              //   sıfırdı" der, oysa veri yoktu.
              let t = 0, var_ = false;
              for (const su of pivot.sutunlar) {
                const r = s.hucre[su]; if (!r) continue;
                const k = ilkKiyas(r); if (k) { t += Number(k[ilk.ad] ?? 0); var_ = true; }
              }
              kiyasDeger = var_ ? t : null;
            } else if (tekHucre) kiyasDeger = ilkKiyas(tekHucre)?.[ilk.ad];
          }
          return (
            <tr key={s.anahtar} className={i % 2 ? 'zebra' : ''}>
              {satirBoyut.map((b, j) => <td key={b}>{boyutDegerMetni(s.etiketler[j], b, kolonlar)}</td>)}
              {sutunlu && pivot.sutunlar.map(su => (
                <td key={su} className="sag">{ilk ? olcuBicimle(s.hucre[su]?.[ilk.ad], ilk.bicim) : ''}</td>
              ))}
              {sutunlu && ilk && toplanabilirMi(ilk) && <td className="sag"><b>{olcuBicimle(s.toplam[ilk.ad], ilk.bicim)}</b></td>}
              {sutunlu && ilk && toplanabilirMi(ilk) && (
                <td className="sag">{pivot.dip[ilk.ad] ? `%${Math.round((s.toplam[ilk.ad] ?? 0) / pivot.dip[ilk.ad] * 100)}` : ''}</td>
              )}
              {(sutunlu ? olculer.slice(1) : olculer).map(o => (
                <td key={o.ad} className="sag">
                  {sutunlu
                    ? (toplanabilirMi(o) ? olcuBicimle(s.toplam[o.ad], o.bicim) : '—')
                    : olcuBicimle(tekHucre?.[o.ad], o.bicim)}
                </td>
              ))}
              {kiyasVar && ilk && <td className="sag sonuk">{olcuBicimle(kiyasDeger, ilk.bicim)}</td>}
              {kiyasVar && ilk && (() => {
                const d = delta(satirIlk, kiyasDeger);
                return <td className={`sag ${d && d.fark < 0 ? 'dk-eksi' : 'dk-arti'}`}>{deltaMetni(d)}</td>;
              })()}
            </tr>
          );
        })}
        {pivot.satirlar.length === 0 && (
          <tr><td colSpan={satirBoyut.length + olculer.length + 1} className="bos">Koşullara uyan kayıt yok.</td></tr>
        )}
        {pivot.satirlar.length > 0 && ilk && (
          <tr className="toplam">
            <td colSpan={Math.max(1, satirBoyut.length)}>TOPLAM</td>
            {sutunlu && pivot.sutunlar.map(su => (
              <td key={su} className="sag">{toplanabilirMi(ilk) ? olcuBicimle(pivot.sutunToplam[su]?.[ilk.ad], ilk.bicim) : ''}</td>
            ))}
            {sutunlu && toplanabilirMi(ilk) && <td className="sag">{olcuBicimle(pivot.dip[ilk.ad], ilk.bicim)}</td>}
            {sutunlu && toplanabilirMi(ilk) && <td className="sag">%100</td>}
            {(sutunlu ? olculer.slice(1) : olculer).map(o => (
              <td key={o.ad} className="sag">{toplanabilirMi(o) ? olcuBicimle(pivot.dip[o.ad], o.bicim) : ''}</td>
            ))}
            {kiyasVar && <td className="sag sonuk">{toplanabilirMi(ilk)
              ? olcuBicimle((yanit.kiyas ?? []).reduce((t, r) => t + Number(r[ilk.ad] ?? 0), 0), ilk.bicim) : ''}</td>}
            {kiyasVar && <td className="sag">{toplanabilirMi(ilk)
              ? deltaMetni(delta(pivot.dip[ilk.ad], (yanit.kiyas ?? []).reduce((t, r) => t + Number(r[ilk.ad] ?? 0), 0))) : ''}</td>}
          </tr>
        )}
      </tbody>
    </table>
  );
}

/** İlk ölçünün satır boyutuna göre çubuk grafiği - mockup .cubuk deseni. */
export function CubukGrafik({ yanit, tanim, kolonlar, enCok = 12 }: {
  yanit: OzetYaniti; tanim: DokumTanimi; kolonlar: DokumKolonMeta[]; enCok?: number;
}) {
  const satirBoyut = tanim.boyut?.satir ?? [];
  const pivot = useMemo(() => pivotla(yanit, satirBoyut.length), [yanit, satirBoyut.length]);
  const ilk = yanit.olculer[0];
  if (!ilk || satirBoyut.length === 0) return null;
  const deger = (s: typeof pivot.satirlar[number]) =>
    toplanabilirMi(ilk) ? (s.toplam[ilk.ad] ?? 0) : Number(s.hucre['']?.[ilk.ad] ?? 0);
  const sirali = [...pivot.satirlar].sort((a, b) => deger(b) - deger(a)).slice(0, enCok);
  const tavan = Math.max(...sirali.map(deger), 0) || 1;
  return (
    <div className="dk-cubuklar">
      {sirali.map(s => (
        <div key={s.anahtar} className="dk-cubuk-satir">
          <span className="et">{s.etiketler.map((e, j) => boyutDegerMetni(e, satirBoyut[j], kolonlar)).join(' · ')}</span>
          <div className="cubuk"><i style={{ width: `${Math.max(2, deger(s) / tavan * 100)}%` }} /></div>
          <b>{olcuBicimle(deger(s), ilk.bicim)}</b>
        </div>
      ))}
    </div>
  );
}

/** Özet göstergeler (mockup .gosterge): liste için kayıt + Σ; özet için dip toplamlar. */
export function OzetGostergeler({ yanit, tanim, kolonlar, baski }: {
  yanit: ListeYaniti | OzetYaniti; tanim: DokumTanimi; kolonlar: DokumKolonMeta[]; baski?: boolean;
}) {
  if (ozetMi(yanit)) {
    const pivot = pivotla(yanit, tanim.boyut?.satir.length ?? 0);
    const kutular = yanit.olculer.filter(toplanabilirMi).slice(0, 4).map(o => ({
      e: o.baslik, s: olcuBicimle(pivot.dip[o.ad], o.bicim),
    }));
    if (kutular.length === 0) kutular.push({ e: 'Grup', s: String(pivot.satirlar.length) });
    return <Kutular kutular={kutular} baski={baski} />;
  }
  const kutular = [{ e: 'Kayıt', s: yanit.toplamKayit.toLocaleString('tr-TR') }];
  for (const t of (tanim.toplam ?? []).slice(0, 3)) {
    const k = kolonlar.find(x => x.ad === t);
    kutular.push({ e: `Σ ${k?.baslik ?? t}`,
      s: olcuBicimle(yanit.toplamlar?.[t], k?.tip === 'para' || k?.tip === 'ondalik' ? '#,##0.00' : '#,##0') });
  }
  return <Kutular kutular={kutular} baski={baski} />;
}

function Kutular({ kutular, baski }: { kutular: { e: string; s: string }[]; baski?: boolean }) {
  return (
    <div className={`dk-gostergeler${baski ? ' dk-kagit-g' : ''}`}>
      {kutular.map(k => (
        <div key={k.e}><span>{k.e}</span><b>{k.s}</b></div>
      ))}
    </div>
  );
}
