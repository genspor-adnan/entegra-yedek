import type { Satir } from './GenDetayTablo';

/**
 * ARAMAYLA SATIR EKLEMEDE SECIM DENETIMI (375/377).
 *
 * TEK ENGEL MUKERRER KAYITTIR. Pencere secimde kapanmadigi icin kullanici
 * hizli hizli Enter'lar; ayni kisiyi iki kez eklemek an meselesi.
 * Veritabaninda `unique(plan_id, taraf_id)` zaten var ama o KAYIT ANINDA,
 * anlamsiz bir kisit hatasiyla konusur - kullanici o ana kadar on kisi daha
 * eklemis olur.
 *
 * KOD LISTESI ARTIK ENGEL DEGIL (377). Once "listede olmayan kisi eklenemez"
 * kurali vardi; jenerik arama 159 personel gosterirken liste 21 kisi tasidigi
 * icin secimlerin cogu SESSIZCE dusuyordu (kullanici: "enter dedim
 * eklemedi"). Engel yanlis yerdeydi - prim rolu ayri bir kartta isaretlenir ve
 * sonradan da doldurulabilir. Rol eksikligi artik gridin "Prim Rolü"
 * kolonunda GORUNUR; karari kullanici verir.
 *
 * @returns engel sebebi, ya da secim gecerliyse null.
 */
export function tarafSecimEngeli(
  satirlar: readonly Satir[],
  alanAd: string,
  secilen: { id: number; unvan: string },
): string | null {
  const id = String(secilen.id);
  if (satirlar.some(x => String(x[alanAd] ?? '') === id))
    return `${secilen.unvan} zaten ekli.`;
  return null;
}
