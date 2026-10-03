/**
 * RANDEVU EKRANI SON SECIMLERI (kullanici: "randevu listesinde kullanici en
 * son ne butonlar sectiyse acildiginda onlar gelsin · kaldigi yerden devam
 * etsin"): durum cipi, bolum, doktor ve takvim gorunumu.
 *
 * Tarayici basina, KULLANICI basina (`localStorage`) - ayni bilgisayari
 * kullanan iki kisi birbirinin secimini gormez. Tarih araligi BILEREK yok:
 * ertesi sabah dunun araligiyla acilan randevu ekrani bos gorunur.
 *
 * Okuma/yazma her zaman try/catch icinde: gizli sekmede ya da depolama
 * kapaliyken ekran varsayilanla acilir (useGridTercihleri ile ayni kural).
 */
export interface RandevuTercihi {
  cip?: number;
  bolum?: number | '';
  hekim?: number | '';
  gorunum?: 'gun' | 'hafta' | 'hekim' | 'cihaz';
  /** Liste mi takvim mi (GenGrid gorunumu; takvim = 'ek'). */
  liste?: 'liste' | 'grup' | 'analiz' | 'ek';
}

const anahtar = (kullaniciId?: number) => `randevu.secim.${kullaniciId ?? 0}`;

export function randevuTercihiOku(kullaniciId?: number): RandevuTercihi {
  try {
    const ham = localStorage.getItem(anahtar(kullaniciId));
    return ham ? JSON.parse(ham) as RandevuTercihi : {};
  } catch {
    return {};
  }
}

export function randevuTercihiYaz(kullaniciId: number | undefined, degisen: RandevuTercihi) {
  try {
    const yeni = { ...randevuTercihiOku(kullaniciId), ...degisen };
    localStorage.setItem(anahtar(kullaniciId), JSON.stringify(yeni));
  } catch { /* depolama yok - secim bu oturumla sinirli kalir */ }
}
