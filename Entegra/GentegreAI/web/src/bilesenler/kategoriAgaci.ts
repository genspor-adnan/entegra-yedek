/** Agac kaydinin bu hesaplamada gereken iki alani. */
export interface AgacDugumu { id: number; ustId?: number | null }

/**
 * SECILEN DALIN KENDISI + TUM ALTLARI.
 *
 * Kategori suzgeci "K5 Dental El Aletleri"ni secince "K5-1 Frezeler"i de
 * kapsamali; sunucuya `icinde [id...]` olarak gider. Ayni genisleme hem
 * combo hem de sol agac panelinde gerekiyordu - iki kopya vardi.
 */
export function altAgac(id: number, kayitlar: readonly AgacDugumu[]): number[] {
  const sonuc = [id];
  const kuyruk = [id];
  while (kuyruk.length) {
    const ust = kuyruk.shift()!;
    kayitlar.filter(k => k.ustId === ust)
      .forEach(k => { sonuc.push(k.id); kuyruk.push(k.id) });
  }
  return sonuc;
}
