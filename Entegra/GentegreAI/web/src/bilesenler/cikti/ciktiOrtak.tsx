import type { ReactNode } from 'react';
import { Karekod } from '../Karekod';
import { gunNokta } from '../bicim';
import { c } from '../../dil/ceviri';

/**
 * ÇIKTI SAYFALARININ ORTAK PARÇALARI (refaktör 20.11.2026, dokuman/REFAKTOR_RAPORU_2026-11-20.md B6).
 *
 * Laboratuvar, radyoloji ve göz şeması çıktılarında aynı üç parça kopyaydı: araç çubuğu (Yazdır / PDF / Kapat),
 * bağlantı karekodu ve kurum adres satırı. Antet işaretlemesi sayfalar arasında farklı (kendi düzenleri var) - o
 * sayfalarında kaldı.
 */

/** Kurumun tek satır adresi: "Örnek Cad. No:1 · Kadıköy / İstanbul". Boş parçalar atlanır. */
export function kurumAdresSatiri(kurum: Record<string, unknown> | null | undefined): string {
  const k = kurum ?? {};
  return [k.adres, [k.ilce, k.il].filter(Boolean).join(' / ')]
    .filter(x => String(x ?? '').trim() !== '').join(' · ');
}

/**
 * Araç çubuğu: Yazdır · PDF · (sayfaya özel düğmeler) · sağda uyarı rozeti ve kapat. YAZDIRILMAZ (@media print) -
 * kâğıtta yalnız belge kalır.
 */
export function CiktiAracCubugu({ onKapat, kapatMetni, uyari, children }: {
  onKapat(): void;
  /** Kapat düğmesinin yazısı (varsayılan "✖ Kapat"). */
  kapatMetni?: ReactNode;
  /** Sağda gösterilen uyarı (ör. "onaylanmadı - bu çıktı taslaktır"); boşsa çıkmaz. */
  uyari?: ReactNode;
  /** PDF'ten sonra gelen sayfaya özel düğmeler. */
  children?: ReactNode;
}) {
  const sagaYasli = uyari !== undefined;
  return (
    <div className="cikti-arac">
      <button className="d bir" onClick={() => window.print()}>🖨 Yazdır</button>
      <button className="d" onClick={() => window.print()}
              title="Yazdırma penceresinde “PDF olarak kaydet” seçin.">
        📄 PDF
      </button>
      {children}
      {sagaYasli && <span style={{ marginLeft: 'auto' }} />}
      {uyari && <span className="rozet uyari" style={{ marginRight: 8 }}>{uyari}</span>}
      <button className="d" onClick={onKapat}>{kapatMetni ?? <>✖ {c('Kapat')}</>}</button>
    </div>
  );
}

/** Basılı çıktıdaki bağlantı karekodu (1389 / 1396): karekod + "telefonda görün" metni + adres + geçerlilik. */
export function BaglantiKarekodu({ adres, karekodBasligi, ustMetin, sonGecerli, testId }: {
  adres: string;
  karekodBasligi: string;
  ustMetin: ReactNode;
  sonGecerli?: string | null;
  testId: string;
}) {
  return (
    <div className="rapor-karekod" data-testid={testId}>
      <Karekod deger={adres} baslik={karekodBasligi} />
      <div>
        <b>{ustMetin}</b>
        {c('Karekodu telefonunuzun kamerasıyla okutun ya da')}<br />
        <span className="rk-adres">{adres.replace(/^https?:\/\//, '')}</span>
        {sonGecerli && <><br />{gunNokta(sonGecerli)} {c('tarihine kadar geçerlidir.')}</>}
      </div>
    </div>
  );
}
