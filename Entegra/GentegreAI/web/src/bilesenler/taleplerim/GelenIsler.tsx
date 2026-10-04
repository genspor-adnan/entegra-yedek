import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { IskontoTalebi } from '../../api/sozlesme';
import { IskontoOnayModali } from '../IskontoOnayModali';
import { useOturum } from '../../kimlik/OturumBaglami';
import type { ArizaGelen } from '../../api/uclar/ariza';
import type { OnayBekleyenSatiri } from '../../api/uclar/izin';
import { guvenli, listeSor, metinSor } from '../mesaj';
import { c } from '../../dil/ceviri';
import { talepleriYenile } from './useTaleplerimOzeti';

/**
 * BANA GELENLER (mockup Ekranlar/Taleplerim/gelen_talepler.html): talebi
 * ALAN kişinin işi - ekibine düşen arıza ve onayına gelen talep. 📨 paneli
 * ve Taleplerim'in "Bana gelenler" sekmesi aynı grupları ve aynı tek-tık
 * işlemleri kullanır.
 */
export type GelenOge =
  | { tip: 'ariza'; anahtar: string; a: ArizaGelen }
  | { tip: 'onay'; anahtar: string; o: OnayBekleyenSatiri }
  | { tip: 'iskonto'; anahtar: string; t: IskontoTalebi };

export interface GelenGrup { kod: 'acil' | 'atanmamis' | 'bende' | 'iskonto' | 'onay'; ad: string; ogeler: GelenOge[] }

/** Acil en üstte, sonra atanmamış, bende, onayımı bekleyen. Boş grup çizilmez. */
export function gelenGruplari(gelen: ArizaGelen[], onaylar: OnayBekleyenSatiri[], iskontolar: IskontoTalebi[] = []): GelenGrup[] {
  const ar = (a: ArizaGelen): GelenOge => ({ tip: 'ariza', anahtar: `ariza-${a.id}`, a });
  const g: GelenGrup[] = [
    { kod: 'acil', ad: '🚨 Acil', ogeler: gelen.filter(a => a.oncelik === 4 && a.durum !== 3).map(ar) },
    { kod: 'atanmamis', ad: 'Atanmamış · ekibime gelen', ogeler: gelen.filter(a => a.oncelik !== 4 && !a.benim).map(ar) },
    { kod: 'bende', ad: 'Bende', ogeler: gelen.filter(a => a.benim && !(a.oncelik === 4 && a.durum !== 3)).map(ar) },
    // İSKONTO (zil): hasta VEZNEDE bekliyor - genel onaylardan önce.
    { kod: 'iskonto', ad: 'İskonto onayı', ogeler: iskontolar.map(t => ({ tip: 'iskonto', anahtar: `iskonto-${t.id}`, t })) },
    { kod: 'onay', ad: 'Onayımı bekleyen', ogeler: onaylar.map(o => ({ tip: 'onay', anahtar: `onay-${o.kaynakTur}-${o.kaynakId}`, o })) },
  ];
  return g.filter(x => x.ogeler.length > 0);
}

/** Bekleme süresi: "4 dk" · "3 sa" · "2 gün". */
export function bekleme(t: string): string {
  const dk = Math.max(0, Math.floor((Date.now() - new Date(t).getTime()) / 60000));
  return dk < 60 ? `${dk} dk` : dk < 1440 ? `${Math.floor(dk / 60)} sa` : `${Math.floor(dk / 1440)} gün`;
}

const AKIS_IKON: Record<string, string> = {
  'personel.izin': '✈️', 'personel.avans': '💸', 'personel.masraf': '🧾', 'personel.belge_talep': '📄', 'demirbas.onarim': '🛠',
  'satinalma.talep': '📥', 'belge.iskonto': '％',
};
export const onayIkon = (o: OnayBekleyenSatiri) => AKIS_IKON[o.akisKod] ?? '⏳';

/** Tek tık işlem düğmeleri. `sonra` işlem bitince (panel kapat vb.). */
export function GelenEylemler({ oge, sonra, ata = true }: { oge: GelenOge; sonra?(): void; ata?: boolean }) {
  const yap = (is: () => Promise<unknown>) => guvenli(async () => { await is(); talepleriYenile(); sonra?.() });

  if (oge.tip === 'iskonto') {
    // KARAR PENCEREDE (663): hizmetler, hasta, doktor görünmeden oran verilmez.
    return (
      <span className="tl-ey">
        <button type="button" className="d bir" onClick={e => { e.stopPropagation(); sonra?.(); iskontoKararAc(oge.t) }}>
          ％ {c('İncele ve karar ver')}</button>
      </span>
    );
  }

  if (oge.tip === 'onay') {
    const o = oge.o;
    return (
      <span className="tl-ey">
        <button type="button" className="d tl-ok" title={c('Onayla')}
                onClick={e => { e.stopPropagation(); void yap(() => api.onayKarar(o.kaynakTur, o.kaynakId, { karar: 'onayla' })) }}>✔ {c('Onayla')}</button>
        <button type="button" className="d tl-tehlike" title={c('Reddet')}
                onClick={async e => {
                  e.stopPropagation();
                  const g = await metinSor(c('Red gerekçesi (talep edene gider)'), '', c('Gerekçe'));
                  if (g) await yap(() => api.onayKarar(o.kaynakTur, o.kaynakId, { karar: 'reddet', gerekce: g }));
                }}>✕ {c('Reddet')}</button>
      </span>
    );
  }

  const a = oge.a;
  return (
    <span className="tl-ey">
      {!a.benim || a.durum !== 3
        ? <button type="button" className="d bir" onClick={e => { e.stopPropagation(); void yap(() => api.arizaDevral(a.id)) }}>✋ {c('Devral')}</button>
        : <button type="button" className="d tl-ok" onClick={async e => {
            e.stopPropagation();
            const n = await metinSor(c('Ne yapıldı? (bildirene gider)'), '', c('Çözüm notu'));
            if (n) await yap(() => api.arizaCoz(a.id, n));
          }}>✔ {c('Çözüldü')}</button>}
      {ata && (
        <button type="button" className="d" title={c('Ekipten birine ata')} onClick={async e => {
          e.stopPropagation();
          const l = await api.arizaAtanabilir(a.id).catch(() => ({ satirlar: [] }));
          if (l.satirlar.length === 0) return;
          const k = await listeSor(c('Kime atansın?'), l.satirlar.map(x => ({ kod: String(x.id), ad: `${x.ad}${x.nobetci ? ' · nöbetçi' : ''}` })), '', c('Kişi'));
          if (k) await yap(() => api.arizaAta(a.id, Number(k)));
        }}>👤 {c('Ata')}…</button>
      )}
      {a.telefon && <a className="d" href={`tel:${a.telefon.replace(/[^\d+]/g, '')}`} title={`☎ ${a.telefon}`} onClick={e => e.stopPropagation()}>☎</a>}
    </span>
  );
}

// ------------------------------------------------ iskonto karar penceresi --
//  Panel dışarı tıklanınca kapanır; pencere panelin içinde çizilseydi onunla
//  birlikte kaybolurdu. Kabukta tek katman, olayla açılır.
const ISKONTO_OLAY = 'gentegre:iskonto-karar';
export const iskontoKararAc = (t: IskontoTalebi) =>
  window.dispatchEvent(new CustomEvent<IskontoTalebi>(ISKONTO_OLAY, { detail: t }));

export function IskontoKararKatmani() {
  const { aksiyonDegeri } = useOturum();
  const [t, setT] = useState<IskontoTalebi | null>(null);
  useEffect(() => {
    const dinle = (e: Event) => setT((e as CustomEvent<IskontoTalebi>).detail);
    window.addEventListener(ISKONTO_OLAY, dinle);
    return () => window.removeEventListener(ISKONTO_OLAY, dinle);
  }, []);
  if (!t) return null;
  return <IskontoOnayModali talep={t} tavan={aksiyonDegeri('basvuru.iskonto')}
                            onKapat={() => setT(null)} onSonuc={talepleriYenile} />;
}
