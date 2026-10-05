/**
 * GÖZ ÜNİTE PANOSU SABİTLERİ (976) — istasyon sözlüğü ve eşikler TEK YERDE.
 *
 * <b>Neden ayrı dosya:</b> aynı altı istasyon adı panonun beş parçasında
 * (sayaç şeridi, kanban, alt tablolar, sol panel, bekleme ekranı, gün özeti
 * çıktısı) ayrı ayrı yazılmıştı. Bir istasyon adı değiştiğinde beş dosyadan
 * dördünü güncellemek, panonun yarısında eski adın kalması demekti.
 *
 * <b>Eşikler de burada:</b> "30 dakikayı geçen bekleme kırmızı" kuralı üç
 * bileşende üç sabit olarak duruyordu; kurum ayarı geldiğinde tek yer
 * değişsin.
 *
 * Sunucu tarafındaki karşılıkları `v_goz_unite_akis` (gecikti = 30 dk) ve
 * <c>GozUclari.Akis.cs</c> (dilatasyon 20 dk) içindedir: eşik iki tarafta
 * birden değişmeli, yoksa ekran sarıya boyadığı satırı sunucu "geciken"
 * saymaz.
 */

/** 1 kabul · 2 ön tetkik · 3 muayene · 4 görüntüleme · 5 karar · 6 tamamlandı. */
export const GOZ_ISTASYON: Record<number, string> = {
  1: 'Kabul', 2: 'Ön tetkik', 3: 'Muayene',
  4: 'Görüntüleme', 5: 'Karar / işlem', 6: 'Tamamlandı',
};

/** Kanban sütunları: 6 (tamamlandı) sütun DEĞİL, hedeftir - hasta panodan düşer. */
export const GOZ_KANBAN_SUTUNLARI = [
  { kod: 1, ad: '1 · Kabul / bekleme' },
  { kod: 2, ad: '2 · Ön tetkik' },
  { kod: 3, ad: '3 · Hekim muayenesi' },
  { kod: 4, ad: '4 · Görüntüleme' },
  { kod: 5, ad: '5 · Karar / işlem' },
] as const;

export const GOZ_PANO_ESIK = {
  /** Bekleme hedefi (dk): üstü sarı. Kurum ayarı olana kadar tek yerde. */
  beklemeHedefDk: 15,
  /** Bu süreyi geçen bekleme kırmızı: hasta "unutuldum" demeden önceki eşik. */
  beklemeKritikDk: 30,
  /** Sıra bu sayıyı geçince kaynak "tıkalı" sayılır (mockup: HFA 4 kişi). */
  siraUyari: 3,
  /** Randevu saatine göre bu kadar geciken hekim sarı (mockup "+12 dk"). */
  gecikmeUyariDk: 10,
  /** Damla 20 dakikada etki eder - sunucudaki eşikle AYNI olmalı. */
  dilatasyonDk: 20,
  /** Pano kendini bu sıklıkta tazeler (mockup: 30 sn). */
  tazelemeSn: 30,
  /** Salon ekranı panodan sık tazelenir: çağrı gecikmesi orada işe yaramaz. */
  beklemeEkraniMs: 15000,
} as const;
