/**
 * KART SONUCU SEKMELER ARASI (kullanıcı 16.11.2026: "başvuru oluştur butonuna basınca hasta kartı modal
 * geliyor.. sekme olarak gelmeli"). Bir akış (randevu → başvuru) kartı KENDİ SEKMESİNDE açar ve sonucunu
 * bekler: kart sekmesi kaydedince / mevcut karta geçince / vazgeçince anahtarla bildirir.
 * Sekme X ile kapatılırsa söz çözülmez - akış yarıda kalır, yan etkisi yoktur.
 */
export type KartSonucu = { id: number; mevcut?: boolean } | null;

const bekleyen = new Map<string, (s: KartSonucu) => void>();

export function kartSonucuBekle(anahtar: string): Promise<KartSonucu> {
  bekleyen.get(anahtar)?.(null);
  return new Promise(coz => bekleyen.set(anahtar, coz));
}

export function kartSonucuBildir(anahtar: string | null | undefined, sonuc: KartSonucu) {
  if (!anahtar) return;
  const coz = bekleyen.get(anahtar);
  if (!coz) return;
  bekleyen.delete(anahtar);
  coz(sonuc);
}
