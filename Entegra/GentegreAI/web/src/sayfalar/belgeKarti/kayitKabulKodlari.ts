/**
 * KAYIT KABUL / BAŞVURU KOD SABİTLERİ.
 *
 * <b>Neden ayrı dosya:</b> ödeyen kurumun türü (özel · ÖSS · SGK) başvuru
 * ekranlarında satır içi sayıyla karşılaştırılıyordu - `kurumTuru !== 2`,
 * `kurumTuru === 2 || kurumTuru === 3`, `k.tur === 3`, `(k.tur ?? 0) === 2` -
 * ve bu karşılaştırmalar MEDULA alanlarının çizilip çizilmeyeceği gibi
 * kararları veriyordu. Sabitler <c>basvuruAsamalari.ts</c> içinde vardı ama
 * yalnız orada kullanılıyordu; aşama hesabı tek müşterisi değil.
 *
 * <b>Türün ne anlama geldiği tek yerde:</b> TSS ve Karma ARTIK KURUM TÜRÜ
 * DEĞİL (467); aynı sigorta şirketiyle ÖSS / TSS / Karma ayrı şartlarla
 * çalışıldığı için poliçe türü sözleşmenin alt kurumudur
 * (<c>belge_basvuru.alt_kurum</c>, 468/469).
 */

/** `taraf_kurum.tur` — kurum (ödeyen) türü. */
export const KURUM_OZEL = 1;
export const KURUM_OSS = 2;
export const KURUM_SGK = 3;

/** `kurum.alt_kurum` (468): tur * 100 + kod. */
export const ALT_OSS = 201;
export const ALT_TSS = 202;
export const ALT_KARMA = 203;

/**
 * MEDULA (SGK) alanları çizilir mi? SGK ve TSS'de asıl ödeyici SGK'dır;
 * yalnız ÖSS'de MEDULA alanları hiç çizilmez.
 */
export const sgkKapsamiVar = (kurumTuru: number | null | undefined): boolean =>
  Number(kurumTuru ?? KURUM_OZEL) !== KURUM_OSS;

/**
 * Özel sigorta (ÖSS) alanları çizilir mi? ÖSS'de tek başına, SGK/TSS'de
 * tamamlayıcı poliçe olarak - ikisi birlikte açık olabilir.
 */
export const ozelSigortaKapsamiVar = (kurumTuru: number | null | undefined): boolean => {
  const t = Number(kurumTuru ?? KURUM_OZEL);
  return t === KURUM_OSS || t === KURUM_SGK;
};

/** Alt kurum (poliçe türü) seçimi yalnız SGK sözleşmesinde sorulur. */
export const altKurumSorulur = (kurumTuru: number | null | undefined): boolean =>
  Number(kurumTuru ?? 0) === KURUM_SGK;
