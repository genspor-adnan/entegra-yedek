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
export const GOZ_ISARETLERI = {
  dilate: 'Dilate', glokom: 'Glokom takibi', retina: 'Retina / anti-VEGF',
} as const;
export type GozIsaretKodu = keyof typeof GOZ_ISARETLERI;

/** Şeridin durumu - süzgeç kancaları bunu kendi filtre zincirine ekler. */
export function useGozIsaretleri() {
  const [isaretler, setIsaretler] = useState<Record<GozIsaretKodu, boolean>>(
    { dilate: false, glokom: false, retina: false });
  const isaretCevir = (k: GozIsaretKodu) => setIsaretler(o => ({ ...o, [k]: !o[k] }));
  /** Açık işaretleri koşul listesine ekler (kolon adı = işaret kodu). */
  const isaretKosullari = (ekle: (alan: string, deger: number) => void) =>
    (Object.keys(isaretler) as GozIsaretKodu[]).forEach(k => { if (isaretler[k]) ekle(k, 1) });
  return { isaretler, isaretCevir, isaretKosullari };
}
export type GozIsaretDurumu = ReturnType<typeof useGozIsaretleri>;

export function GozIsaretSeridi({ s }: { s: GozIsaretDurumu }) {
  return (
    <div className="gg-isaret">
      {(Object.keys(GOZ_ISARETLERI) as GozIsaretKodu[]).map(k => (
        <button key={k} type="button" className={`pl-k gg-cip${s.isaretler[k] ? ' on' : ''}`}
                onClick={() => s.isaretCevir(k)}>{c(GOZ_ISARETLERI[k])}</button>
      ))}
    </div>
  );
}
