/**
 * GÖZ KOD → ETİKET SÖZLÜKLERİ (`labKodlari.ts` deseni).
 *
 * <b>Neden tek yerde:</b> göz tetkik adları üç ekranda ayrı ayrı yazılmıştı
 * (istem sepeti, muayenenin İstem & Sonuç sekmesi, göz görüntüleme panelleri)
 * ve ikisi 9 numaralı tetkiğe "Topografi", biri "Kornea topografisi" diyordu.
 * Hekim sepetten istediği tetkiği sonuç ekranında başka adla görüyordu.
 *
 * Adlar sunucudaki <c>goz.tetkik</c> kod listesinin KISALTILMIŞ hâlidir:
 * kod listesi "OCT — maküla", "Pakimetri haritası" gibi uzun adlar tutuyor,
 * ekranlarda sütun genişliği o kadar değil. Kod listesine yeni tetkik
 * eklenirse buraya da kısa adı yazılmalı - eşlenmeyen kod ekranda ham sayı
 * değil, çağıran yerin yedek metni ("Göz tetkiki") olarak görünür.
 *
 * Burada <b>iş kuralı yok</b>: hangi tetkiğin hangi hizmetle ücretlendiği,
 * ödenmeden çekim yapılamayacağı sunucunun işidir (974/975).
 */

/** `goz_goruntuleme.tetkik` → kısa ad (sunucu: `goz.tetkik` kod listesi). */
export const GOZ_TETKIK: Record<number, string> = {
  1: 'OCT maküla', 2: 'OCT RNFL / GCC', 3: 'OCT ön segment', 4: 'OCT-A',
  5: 'FAF', 6: 'FA / ICGA', 7: 'Fundus foto', 8: 'Görme alanı',
  9: 'Kornea topografisi', 10: 'Pakimetri', 11: 'Biyometri', 12: 'Endotel',
  13: 'UBM', 14: 'B-scan USG', 15: 'ERG / VEP',
};

/** Göz tarafı: her ölçüm ve istem satırında aynı üç kısaltma. */
export const GOZ_TARAF: Record<number, string> = { 1: 'OD', 2: 'OS', 3: 'OU' };

/** `goz_goruntuleme.sonuc` — hekimin değerlendirme kararı. */
export const GOZ_SONUC: Record<number, string> = {
  1: 'Normal', 2: 'Sınırda', 3: 'Anormal', 4: 'Değerlendirilemez',
};

/**
 * CİHAZ KODLARI (978) - DB kod listeleriyle BİREBİR: `goz.cihaz_tur` ve
 * `goz.cihaz_protokol`. Liste kataloğu adları SQL `case` ile üretiyor, bu
 * sözlük sol panel / önizleme gibi KOD taşıyan uçlar için - ikisi aynı metni
 * yazmak zorunda.
 */
export const GOZ_CIHAZ_TUR: Record<number, string> = {
  1: 'Otorefraktometre / keratometre', 2: 'Tonometre (NCT)', 3: 'Pakimetre',
  4: 'OCT', 5: 'Görme alanı', 6: 'Fundus kamera', 7: 'Topografi',
  8: 'Biyometri', 9: 'Endotel', 10: 'USG',
};

export const GOZ_CIHAZ_PROTOKOL: Record<number, string> = {
  1: 'DICOM', 2: 'Seri metin (RS-232)', 3: 'Dosya (XML/CSV/PDF)', 4: 'API',
};

/**
 * CİHAZ DURUMU sol ağaçta: üç ayrı alandan türetilir (aktif · dinleyici_durum ·
 * uyarı). Kodlar sunucudaki `cihaz-gosterge` sorgusuyla aynı sırayı taşır.
 */
export const GOZ_CIHAZ_DURUM: Record<number, string> = {
  0: 'Dinliyor', 1: 'Çalışıyor (dinleyici yok)', 2: 'Bağlantı yok', 3: 'Pasif',
};
