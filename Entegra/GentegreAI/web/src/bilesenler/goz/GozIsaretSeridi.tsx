import { useState } from 'react';
import { c } from '../../dil/ceviri';

/**
 * İŞARET ŞERİDİ - göz listelerinin sol panelinin üstündeki bağımsız süzgeçler
 * (mockup `goz_muayene_listesi_v2` ② ve `goz_goruntuleme_listesi_v2` ②:
 * "Dilate · Glokom takibi · Retina / anti-VEGF").
 *
 * <b>Dönem / durum çiplerinden ayrı durmasının sebebi:</b> o çipler TEK SEÇİM
 * (bir satır ya taslak ya tamamlandı), bunlar ise birbirinden bağımsız açılıp
 * kapanır. "Bugün + dilate + glokom takibi" gerçek bir soru - damlalı hasta
 * bekletilemez, glokom izlemi aynı gün görme alanı ister. Tek seçimli çip
 * şeridinde bu kombinasyon kurulamıyordu.
 *
 * Etiketler burada, süzülecek KOLON ADLARI çağıran ekranda değil: iki listede
 * de kolonlar aynı adı taşıyor (`dilate`, `glokom`, `retina`), tek fark
 * görüntülemede takibin hastadan okunması.
 */
/** Muayene ve görüntüleme listesinin işaretleri (aynı üç soru). */
export const GOZ_TAKIP_ISARETLERI = {
  dilate: 'Dilate', glokom: 'Glokom takibi', retina: 'Retina / anti-VEGF',
};

/** Gözlük reçetesi listesinin işaretleri (mockup ② şeridi). */
export const GOZLUK_ISARETLERI = {
  sgkHak: 'SGK’lı', cocuk: 'Çocuk (< 18)',
};

/**
 * Şeridin durumu. İşaret tanımı PARAMETRE: kodlar süzülecek KOLON ADLARI,
 * etiketler ekran metni. Üç listede işaretler farklı (göz muayenesinde takip,
 * gözlükte SGK / çocuk) ama davranış aynı - bağımsız aç/kapa.
 */
export function useGozIsaretleri(tanim: Record<string, string> = GOZ_TAKIP_ISARETLERI) {
  const [isaretler, setIsaretler] = useState<Record<string, boolean>>({});
  const isaretCevir = (k: string) => setIsaretler(o => ({ ...o, [k]: !o[k] }));
  /** Açık işaretleri koşul listesine ekler (kolon adı = işaret kodu). */
  const isaretKosullari = (ekle: (alan: string, deger: number) => void) =>
    Object.keys(tanim).forEach(k => { if (isaretler[k]) ekle(k, 1) });
  return { tanim, isaretler, isaretCevir, isaretKosullari };
}
export type GozIsaretDurumu = ReturnType<typeof useGozIsaretleri>;

export function GozIsaretSeridi({ s }: { s: GozIsaretDurumu }) {
  return (
    <div className="gg-isaret">
      {Object.entries(s.tanim).map(([k, etiket]) => (
        <button key={k} type="button" className={`pl-k gg-cip${s.isaretler[k] ? ' on' : ''}`}
                onClick={() => s.isaretCevir(k)}>{c(etiket)}</button>
      ))}
    </div>
  );
}
