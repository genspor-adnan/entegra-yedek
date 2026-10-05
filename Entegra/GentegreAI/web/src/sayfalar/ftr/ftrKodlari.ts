import type { FtrEgzersiz } from '../../api/uclar/ftr';

/**
 * FTR KOD → ETİKET SÖZLÜKLERİ ve AŞAMA MANTIĞI.
 *
 * <b>Sözlükler neden burada:</b> egzersiz yeri (klinik / ev) iki kartta ayrı
 * yazılmıştı; kabin türü ve tedavi yanıtı birer yerde ama veritabanındaki kod
 * listelerinin (<c>ftr.egzersiz_yer</c>, <c>ftr.kabin_tur</c>,
 * <c>ftr.yanit</c>) elle kopyası. Metinler o listelerle AYNI tutulmalı: aynı
 * kaydın yeri kart motorunda sunucudan, bu özel ekranlarda buradan geliyor.
 * Liste kataloğu bu ekranlara metadata vermiyor (kür panosu ve seans kartı
 * kendi düzenlerini çiziyor), bu yüzden kopya kaçınılmaz - ama <b>bir</b>
 * kopya.
 *
 * <b>Aşama mantığı neden burada:</b> "bu egzersiz bu seansta var mı" kuralı
 * iki kartta ayrı yazılmıştı - biri satırı soluklaştırmak, öteki "· bu seans"
 * etiketi için. Aynı kuralın iki ifadesi, birinin sessizce sapması demek:
 * aşama aralığı değişirse biri soluk gösterirken öteki "bu seans" der.
 *
 * Burada <b>iş kuralı yok</b>: aşama aralığının kendisi programda tanımlı,
 * seansın açılması / kapanması sunucunun işi (<c>FtrUclari</c>).
 */

/** `ftr_program_egzersiz.yer` (kod listesi `ftr.egzersiz_yer`). */
export const FTR_EGZERSIZ_YER: Record<number, string> = {
  1: 'Klinik', 2: 'Ev', 3: 'Klinik + ev',
};

/** `ftr_program.yanit` (kod listesi `ftr.yanit`) - kür sonunda yazılır. */
export const FTR_YANIT: Record<number, string> = {
  1: 'İyi yanıt', 2: 'Kısmi yanıt', 3: 'Yanıtsız',
};

/** `ftr_kabin.tur` (kod listesi `ftr.kabin_tur`). */
export const FTR_KABIN_TUR: Record<number, string> = {
  1: 'Kabin', 2: 'Egzersiz salonu', 3: 'Hidroterapi',
  4: 'Manuel terapi', 5: 'Robotik', 6: 'Grup',
};

/**
 * Seans durumunun rozet sınıfı (`ftr.seans_durum`). Durumun ADI sunucudan
 * gelir (<c>durumAdi</c>); burada yalnız rengi var - metni iki yerde tutmak,
 * kod listesi düzenlenince ekranın eski adı göstermesi olurdu.
 */
export const FTR_SEANS_ROZET: Record<number, string> = {
  1: 'gri', 2: 'mavi', 3: 'ok', 4: 'hata', 5: 'gri', 6: 'uyari',
};

/** Egzersiz bu sıradaki seansta uygulanıyor mu (aşama aralığı kapsıyor mu). */
export const egzersizSeanstaVar = (e: FtrEgzersiz, sira: number): boolean =>
  sira >= e.asamaBas && (e.asamaBit === null || e.asamaBit === undefined || sira <= e.asamaBit);

/**
 * Aşama aralığı metni: bitişi olmayan egzersiz kür sonuna kadar sürer.
 * Program kartında kürün seans sayısı yazılır ("3–10"), seans kartında kür
 * uzunluğu elde olmadığı için üç nokta ("3–…").
 */
export const ftrAsamaAraligi = (e: FtrEgzersiz, seansSayisi?: number): string =>
  `${e.asamaBas}–${e.asamaBit ?? (seansSayisi ?? '…')}`;
