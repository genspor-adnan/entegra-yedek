import type { ReactNode } from 'react';
import { c } from '../dil/ceviri';
import { metin } from './tarafDuzeni';

/**
 * TARAF ARAMASI ÖNİZLEME PARÇALARI (cari / kişi / personel düzenlerinin ortak yapı taşları).
 * Önizleme çerçevesi (başlık + kapat + "Satır seçin") TarafArama'da bir kez çizilir; düzenler yalnız içeriği verir.
 */

/** "—" (boş değer işareti). */
export const Bos = () => <span className="gh-sonuk">—</span>;

/** Değer boşsa "—". */
export const yoksaTire = (v: unknown): ReactNode => metin(v) || <Bos />;

/** Etiket · değer satırı; değer boşsa hiç çizilmez. */
export function Sat({ etiket, v, sinif }: { etiket: ReactNode; v: ReactNode; sinif?: string }) {
  if (v === '' || v === null || v === undefined || v === false) return null;
  return <div className="ta-sat"><span>{etiket}</span><span className={sinif}>{v}</span></div>;
}

/** İletişim bloğu: adres (opsiyonel) + telefon / cep / e-posta (+ ilgili kişi); hiçbiri yoksa "—". */
export function IletisimBlok({ s, adres, ilgiliKisi }: { s: Record<string, unknown>; adres?: string[]; ilgiliKisi?: boolean }) {
  const var_ = (adres?.length ?? 0) > 0 || metin(s.telefon) || metin(s.cepTel) || metin(s.eposta) || (ilgiliKisi && metin(s.ilgiliKisi));
  return (
    <div className="ta-blok"><h5>İletişim</h5>
      {adres && adres.length > 0 && (
        <Sat etiket="Adres" v={adres.map((x, i) => <span key={i}>{i > 0 && <br />}{x}</span>)} />)}
      <Sat etiket="Telefon" v={metin(s.telefon)} />
      <Sat etiket="Cep" v={metin(s.cepTel)} />
      <Sat etiket="E-posta" v={metin(s.eposta)} />
      {ilgiliKisi && <Sat etiket="İlgili kişi" v={metin(s.ilgiliKisi)} />}
      {!var_ && <Bos />}
    </div>
  );
}

/** Panel başlığı + kapat düğmesi. */
export function OnizlemeBasligi({ onKapat }: { onKapat(): void }) {
  return (
    <div className="ta-on-bas"><span>{c('Önizleme')}</span>
      <button type="button" title="Önizlemeyi kapat" onClick={onKapat}>◨</button></div>
  );
}
