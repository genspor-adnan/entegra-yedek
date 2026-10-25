/**
 * Kartı KENDİ EKRAN SEKMESİNDE açılan özel kart rotaları (kullanıcı 15.10.2026, reçete): kart yolu ->
 * sekme başlığı. Kabuk kart sekmesi haritasına girer; "yeni" yolu yok, palete eklenmez.
 * Ayrı modülde: Kabuk -> OzelKartSayfalari importu döngü kuruyordu.
 */
export const OZEL_KART_SEKME_YOLLARI: Record<string, string> = { '/recete': 'Reçete', '/medula-recete': 'Reçete', '/stok-sayim': 'Yeni Sayım', '/planli-gider': 'Yeni Planlı Gider' };
