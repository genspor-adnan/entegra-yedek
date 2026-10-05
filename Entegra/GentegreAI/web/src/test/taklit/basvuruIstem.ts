import type { basvuruIstemUclari, BekleyenIstemYaniti } from '../../api/uclar/basvuruIstem';

/**
 * BAŞVURU → İSTEM UÇLARININ ORTAK TAKLİDİ (denetim 28.09.2026 #12).
 *
 * Başvuru kartı açılışta `basvuruBekleyenIstem` çağırıyor (912). Kartı çizen
 * iki test dosyası kendi `api` taklidini elle yazıyordu ve bu uç eklendiğinde
 * ikisi de geride kaldı: 21 test "api.basvuruBekleyenIstem is not a function"
 * ile düştü - üretimde fonksiyon vardı, taklitte yoktu.
 *
 * Taklit, gerçek uç nesnesinin ANAHTARLARINA ve İMZALARINA bağlanır
 * (`satisfies`): uca yeni fonksiyon eklenir ya da dönüş biçimi değişirse
 * bu dosya DERLENMEZ ve eksik taklit sessizce çalışma anına kalmaz.
 */
export const bosBekleyenIstem = (): BekleyenIstemYaniti => ({ lab: [], radyoloji: [], toplam: 0 });

type Uclar = typeof basvuruIstemUclari;

export const basvuruIstemTaklidi = {
  basvuruBekleyenIstem: () => Promise.resolve(bosBekleyenIstem()),
  basvuruIstemSerbest: () => Promise.resolve({ lab: 0, radyoloji: 0, goz: 0, toplam: 0, mesaj: '' }),
  basvuruIstemUcretlendir: () => Promise.resolve({ eklenen: 0, mesaj: '' }),
} satisfies { [K in keyof Uclar]: (...a: Parameters<Uclar[K]>) => ReturnType<Uclar[K]> };
