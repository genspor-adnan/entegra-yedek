/**
 * KART EK KAYDET KUYRUGU (kullanıcı: "yetkili şubelerdeki Kaydet'i kaldır,
 * üstteki tek Kaydet burayı da kaydetsin").
 *
 * Kartın kendi alanları/detayları tek istekte gider; ama kartın içinde AYRI
 * uca yazan bölümler var (personel > yetkili şubeler gibi). Bu bölümler
 * değiştikçe kendi kaydetme işini buraya bırakır, GenForm Kaydet'te kart
 * yazıldıktan sonra kuyruğu çalıştırır. Kart kapanırken kuyruk temizlenir.
 *
 * Anahtar bölüm başına benzersizdir (ör. "subeler:4354"): aynı bölüm birden
 * çok kez değişse de tek iş kalır - son hali yazılır.
 */
type Is = () => Promise<void>;

const isler = new Map<string, Is>();

/** İş bırakır; `is` null ise (değişiklik geri alındıysa) kuyruktan siler. */
export function ekKaydetKaydol(anahtar: string, is: Is | null) {
  if (is) isler.set(anahtar, is);
  else isler.delete(anahtar);
}

/** Bekleyen işleri sırayla çalıştırır; biri patlarsa hata yukarı gider. */
export async function ekKaydetleriCalistir() {
  const kuyruk = [...isler.entries()];
  isler.clear();
  for (const [, is] of kuyruk) await is();
}

export function ekKaydetTemizle() {
  isler.clear();
}
