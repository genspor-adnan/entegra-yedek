/**
 * YATAN HASTA KOD → ETİKET SÖZLÜKLERİ (`labKodlari.ts` deseni).
 *
 * <b>Neden tek yerde - ve bir tanesi gerçekten ayrışmıştı:</b> risk ölçekleri
 * iki ekranda iki ADLA yazılmıştı. Hemşire izleminde "İtaki düşme riski",
 * yatış şeridindeki açık işler listesinde "Düşme riski (İtaki)"; aynı ölçek,
 * iki isim. Hemşire "Braden bası yarası süresi geçti" diye arayıp şeritte
 * "Bası yarası (Braden)" görüyordu. Metinler artık kod listesinden
 * (<c>yatan.risk_olcek</c>) tek biçimde geliyor.
 *
 * İzolasyon sözlüğü iki dosyada birebir kopyaydı (yatak seçimi, yatış şeridi);
 * risk düzeyi ikisinde büyük / küçük harfle yazılmıştı - cümle içinde geçtiği
 * yer küçük harf istiyor, bu yüzden iki biçim KALDI ama tek kodtan türüyor.
 *
 * Order türü iki yerde tanımlıydı: tam liste renkleriyle
 * (<c>OrderPanelleri.ORDER_TURLERI</c>), icmalde yalnız üç türlük bir alt
 * küme. Alt küme kaldırıldı - tam liste buradan okunuyor.
 *
 * Metinler veritabanı kod listeleriyle (<c>yatan.risk_olcek</c>,
 * <c>yatan.risk_duzey</c>, <c>yatan.izolasyon</c>, <c>yatan.order_tur</c>)
 * aynı tutulur; sunucudan ad gelen yerlerde (<c>olcekAd</c>, <c>durumAdi</c>)
 * o ad önce gelir, buradakiler yedek.
 */

/** `yatan_risk.olcek` (kod listesi `yatan.risk_olcek`). */
export const YATAN_RISK_OLCEK: Record<number, string> = {
  1: 'İtaki düşme riski', 2: 'Braden bası yarası',
  3: 'NRS-2002 beslenme', 4: 'Glasgow koma skalası',
};

/** `yatan_risk.duzey` (kod listesi `yatan.risk_duzey`). */
export const YATAN_RISK_DUZEY: Record<number, string> = {
  1: 'Düşük', 2: 'Orta', 3: 'Yüksek',
};

/** Cümle içinde geçen küçük harfli biçim ("… riski yüksek"). */
export const YATAN_RISK_DUZEY_KUCUK: Record<number, string> =
  Object.fromEntries(Object.entries(YATAN_RISK_DUZEY)
    .map(([k, v]) => [Number(k), v.toLocaleLowerCase('tr-TR')])) as Record<number, string>;

/**
 * `yatis.izolasyon` (kod listesi `yatan.izolasyon`). Ekranda rozet / uyarı
 * cümlesi içinde geçtiği için küçük harfle ve "izolasyon" sözcüğüyle birlikte
 * yazılır ("🦠 temaslı izolasyon"); kod listesi yalnız türü tutuyor.
 */
export const YATAN_IZOLASYON: Record<number, string> = {
  1: 'temaslı izolasyon', 2: 'damlacık izolasyon',
  3: 'solunum izolasyonu', 4: 'koruyucu izolasyon',
};
