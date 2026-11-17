import { createContext, useContext } from 'react';
import { c } from '../../dil/ceviri';

/**
 * KART KİPİ BAĞLAMI (kullanıcı 17.11.2026, hasta kartı: "ad soyadın sağına çerçevesiz kalem ekle.. edite geçirsin..
 * aynı kalemden genel sekmesinde iletişim label sağına da ekle"): kipli kartta (KIPLI_GOVDE_KARTLAR) görüntüleme /
 * düzenleme kipi GenForm'da tek durum; kartın herhangi bir yerine konan ✎ aynı durumu değiştirir.
 */
export interface KartKipi { acik: boolean; degistir(): void; pasif: boolean }
export const KartKipBaglami = createContext<KartKipi | null>(null);

/** Çerçevesiz ✎ (.bs-kalem). Kipli kart dışında hiçbir şey çizmez. */
export function KipKalemi({ testId }: { testId?: string }) {
  const k = useContext(KartKipBaglami);
  if (!k) return null;
  return (
    <button type="button" className={`bs-kalem kip-kalemi${k.acik ? ' acik' : ''}`} disabled={k.pasif}
            data-testid={testId}
            title={k.pasif ? c('Düzenleme yetkisi yok') : k.acik ? c('Düzenlemeyi kapat') : c('Düzenle')}
            onClick={e => { e.stopPropagation(); k.degistir() }}>✎</button>
  );
}
