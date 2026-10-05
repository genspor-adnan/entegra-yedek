/**
 * MUAYENE KOD → ETİKET SÖZLÜKLERİ (`labKodlari.ts` deseni).
 *
 * <b>Neden tek yerde:</b> muayene durumu iki ekranda ayrı yazılmıştı ve
 * **ayrışmıştı**: muayene sekmeleri "Sonuç bekliyor" diyor ve 4 numaralı
 * durumu (ek not eklendi) hiç tanımıyordu - o muayenenin rozeti boş
 * görünüyordu; liste kartı "Sonuç Bekliyor" yazıyordu. Metinler sunucudaki
 * kart kodlarıyla (<c>KartKatalogu.Saglik</c>) birebir aynı tutuluyor, çünkü
 * aynı kaydın durumu gridde sunucudan, kartta buradan geliyor.
 *
 * Rapor türleri de burada: özet penceresi türü ada çevirmek için bir sözlük,
 * rapor penceresi seçim kutusu için bir liste tutuyordu; ikisi aynı kodları
 * iki biçimde yazmak demekti.
 *
 * Burada <b>iş kuralı yok</b>: durum geçişleri (tamamlama kilidi, ek not)
 * ve rapor imzası sunucunun işidir.
 */

/** `muayene.durum` — sunucudaki kart kodlarıyla AYNI metinler. */
export const MUAYENE_DURUM: Record<number, string> = {
  0: 'İptal', 1: 'Açık', 2: 'Sonuç Bekliyor', 3: 'Tamamlandı',
  4: 'Ek Not Eklendi',
};

/** `muayene_rapor.tur`. Parantezli açıklama yalnız seçim kutusunda gösterilir. */
export const RAPOR_TUR: Record<number, string> = {
  1: 'İstirahat', 2: 'Sağlık durumu', 3: 'İlaç kullanım', 4: 'İş göremezlik',
};

/** Rapor penceresinin tür kutusu: sözlükten türetilir, ikinci liste tutulmaz. */
export const RAPOR_TUR_SECENEK: { k: number; ad: string }[] =
  Object.entries(RAPOR_TUR).map(([k, ad]) => ({
    k: Number(k),
    // SUT kısaltması yalnız seçim kutusunda: tabloda sütunu taşırıyordu.
    ad: Number(k) === 3 ? `${ad} (SUT)` : ad,
  }));

/** `muayene_rapor.alt_tur` — istirahat raporunun alt kırılımı. */
export const RAPOR_ALT_TUR: { k: number; ad: string }[] = [
  { k: 0, ad: '—' }, { k: 1, ad: 'İş göremezlik' }, { k: 2, ad: 'Refakat' },
  { k: 3, ad: 'Doğum öncesi' }, { k: 4, ad: 'Doğum sonrası' }, { k: 5, ad: 'Diğer' },
];
