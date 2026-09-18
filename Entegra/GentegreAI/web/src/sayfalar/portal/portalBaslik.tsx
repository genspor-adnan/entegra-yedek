import { createContext, useContext, useMemo, type ReactNode } from 'react';
import { portalBolumleri, type MenuKaynagi, type PortalTuru } from './portalMenu';

/**
 * PORTALDA EKRAN BAŞLIĞI = MENÜ ADI (796 V2).
 *
 * Liste ekranlarının başlığı liste tanımından geliyor ("Randevular", "Sonuç
 * Onay Kuyruğu"); portal menüsünde ise aynı ekran hastanın diliyle yazılıyor
 * ("Randevularım", "Lab sonuçlarım"). İkisi farklı kalınca kullanıcı menüde
 * tıkladığı adı sayfada bulamıyordu.
 *
 * <b>Liste tanımına ikinci bir ad kolonu EKLENMEDİ:</b> aynı ekran üç portalda
 * üç ayrı ad taşıyor (dış hekimin "Hastalarım"ı kurumun "Gönderdiğim
 * hastalar"ı) - tanıma tek bir "portal adı" yazmak üçünden ikisinde yanlış
 * olurdu. Ad zaten `portalMenu` tablosunda; başlık da oradan okunur.
 *
 * <b>Portal dışında hiçbir şey değişmez:</b> sağlayıcı yoksa kanca `undefined`
 * döner, ekran kendi başlığını kullanır.
 */

interface PortalBaslikDegeri {
  /** Yola karşılık gelen portal adı; eşleşme yoksa undefined. */
  ad(yol: string): string | undefined;
}

const Baglam = createContext<PortalBaslikDegeri | null>(null);

export function PortalBaslikSaglayici({ ogeler, portalTuru, portalKaynaklar, children }: {
  ogeler: MenuKaynagi[];
  portalTuru: PortalTuru;
  portalKaynaklar?: string[];
  children: ReactNode;
}) {
  const deger = useMemo<PortalBaslikDegeri>(() => {
    const tablo = new Map<string, string>();
    for (const b of portalBolumleri(ogeler, portalTuru, portalKaynaklar))
      for (const o of b.ogeler) tablo.set(o.yol, o.ad);
    return { ad: (yol: string) => tablo.get(yol) };
  }, [ogeler, portalTuru, portalKaynaklar]);

  return <Baglam.Provider value={deger}>{children}</Baglam.Provider>;
}

/**
 * Ekranın portaldaki adı. Portal dışında ya da eşleşme yoksa `undefined` -
 * çağıran kendi başlığını kullanır.
 */
export function usePortalBaslik(yol: string): string | undefined {
  return useContext(Baglam)?.ad(yol);
}

/** Portal kabuğunun içinde miyiz - kırıntı yolu gibi kurum içi öğeler için. */
export function usePortaldaMi(): boolean {
  return useContext(Baglam) !== null;
}
