import type { DetayFarki } from '../api/sozlesme';

/** KART DETAY DURUMU (GenDetayTablo'dan ayrıldı, 22.10.2026) - saf: bileşen içe aktarmaz. */

export type Satir = Record<string, unknown> & { id?: number };

/**
 * Detay tablosunun duzenleme durumu. Sunucuya TAM LISTE degil FARK gonderilir
 * (§3.2), bu yuzden ilk hal ile guncel hal birlikte tutulur.
 */
export interface DetayDurumu {
  ilk: Satir[];        // karttan geldigi hali
  guncel: Satir[];     // ekranda duzenlenmis hali
  silinen: number[];   // kaldirilan mevcut satirlarin id'leri
}

export const bosDetay = (satirlar: Satir[] = []): DetayDurumu => ({
  ilk: satirlar.map(s => ({ ...s })),
  guncel: satirlar.map(s => ({ ...s })),
  silinen: [],
});

/**
 * Ekrandaki durumdan sunucunun bekledigi fark listesini uretir.
 *
 * `izinliAlanlar` verilirse satirdaki BASKA anahtarlar ELENIR: gride yalniz
 * gosterim icin konan alanlar (or. kampanya urun satirindaki `iskontoYeriAdi`)
 * sunucuya gidince "Bilinmeyen alan" hatasi veriyordu.
 */
export function detayFarki(durum: DetayDurumu,
                           izinliAlanlar?: readonly string[]): DetayFarki {
  const izinli = izinliAlanlar ? new Set([...izinliAlanlar, 'id']) : null;
  const suz = (s: Satir): Satir => (izinli
    ? Object.fromEntries(Object.entries(s).filter(([k]) => izinli.has(k))) as Satir
    : s);
  // YENI satirda BOS birakilan alan HIC GONDERILMEZ (GenForm'daki kuralin
  //   detay karsiligi): bos metin NOT NULL + varsayilanli kolonlarda
  //   "birim bos birakilamaz" gibi hatalara yol aciyordu. Gonderilmeyince
  //   veritabani varsayilani devreye girer.
  const eklenen = durum.guncel
    .filter(s => s.id === undefined || s.id === null)
    .map(s => Object.fromEntries(
      Object.entries(suz(s)).filter(([, v]) => v !== '' && v !== null && v !== undefined)) as Satir);

  const degisen = durum.guncel
    .filter(s => s.id !== undefined && s.id !== null)
    .map(s => {
      const eski = durum.ilk.find(i => i.id === s.id);
      if (!eski) return null;
      // Yalniz gercekten degisen alanlar gonderilir
      const fark: Satir = { id: s.id };
      let degisti = false;
      Object.keys(suz(s)).forEach(alan => {
        if (alan === 'id') return;
        if (String(s[alan] ?? '') !== String(eski[alan] ?? '')) { fark[alan] = s[alan]; degisti = true }
      });
      return degisti ? fark : null;
    })
    .filter(Boolean) as Satir[];

  return {
    eklenen: eklenen.length ? eklenen : undefined,
    degisen: degisen.length ? degisen : undefined,
    silinen: durum.silinen.length ? durum.silinen : undefined,
  };
}
