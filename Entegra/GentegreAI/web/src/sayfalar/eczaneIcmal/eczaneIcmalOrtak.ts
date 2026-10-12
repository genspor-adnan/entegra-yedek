/** Eczane / ilaç icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

export const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toFixed(1).replace('.', ',')}`);

/** Adet: tam sayıysa ondalıksız, değilse iki hane (doz miktarı 0,5 olabilir). */
export const adet = (n: number) => (Number.isInteger(n) ? String(n) : n.toFixed(2).replace('.', ','));

/** Kaçak oranı: faturalanmayan / (faturalanan + faturalanmayan); %3 üstü kırmızı, %1 üstü sarı. */
export function kacakRozeti(oran: number | null | undefined): Rozet {
  if (oran == null) return { ad: '—', renk: 'pas' };
  const m = yuzde(oran);
  return oran > 3 ? { ad: m, renk: 'kir' } : oran > 1 ? { ad: m, renk: 'sari' } : { ad: m, renk: 'ok' };
}

/** Miad durumu: dolmuş = imha, ≤ 30 gün kırmızıya yakın, ≤ 90 gün izlenir; tüketim hızı yetiyorsa "tüketilir". */
export function miadRozeti(m: { durum: string; tuketilir: boolean }): Rozet {
  if (m.durum === 'dolmuş') return { ad: 'miadı doldu · imha', renk: 'kir' };
  if (m.tuketilir) return { ad: 'tüketim hızı yetiyor', renk: 'ok' };
  return m.durum === '30' ? { ad: '≤ 30 gün', renk: 'sari' } : { ad: '≤ 90 gün', renk: 'pas' };
}

/** İTS hata sınıfı: veri = kullanıcı düzeltir · servis = otomatik tekrar · yetki = GLN / sözleşme. */
export function itsSinifRozeti(sinif: string): Rozet {
  return sinif === 'veri' ? { ad: 'veri', renk: 'sari' } : sinif === 'servis' ? { ad: 'servis', renk: 'mavi' }
    : sinif === 'yetki' ? { ad: 'yetki', renk: 'kir' } : { ad: sinif || '—', renk: 'pas' };
}
