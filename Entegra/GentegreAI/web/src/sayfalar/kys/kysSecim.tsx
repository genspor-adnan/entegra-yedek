import { onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';

/**
 * KURUMSAL KALİTE ÖZEL SAYFALARI — DÜZENLE / SİL (kullanıcı 12.10.2026:
 * "kalite listelerinde ekleme butonu olan yerlerin yanına düzenle ve sil de
 * ekle"). Satır tek tıkla SEÇİLİR, çift tıkla kartı açar; araç çubuğunda
 * "＋ Ekle" yanında Düzenle ve Sil seçili satıra uygulanır. Silme kural ve
 * logu sunucuda (generic kart ucu / kendi ucu); burada yalnız onay.
 */
export function DuzenleSilDugmeleri({ secili, duzenle, sil, duzenleYetki, silYetki }: {
  secili: boolean;
  duzenle(): void;
  sil(): void;
  duzenleYetki: boolean;
  silYetki: boolean;
}) {
  return <>
    {duzenleYetki && <button className="d" disabled={!secili} onClick={duzenle}>✎ {c('Düzenle')}</button>}
    {silYetki && <button className="d" disabled={!secili} onClick={sil}>🗑 {c('Sil')}</button>}
  </>;
}

/** Silme onayı - metin kaydın kendi adıyla. */
export const silOnayi = (ad: string) => onay(`"${ad}" silinsin mi?`, true);
