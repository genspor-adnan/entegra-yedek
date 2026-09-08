/**
 * LABORATUVAR KOD → ETİKET SÖZLÜKLERİ (446).
 *
 * <b>Neden tek yerde:</b> tüp rengi etikette, numune kabul panelinde ve
 * sonuç ekranında aynı olmalı. Mor EDTA tüpü bir ekranda mor, diğerinde
 * gri görünürse teknisyen elindeki tüpü doğrulayamaz - renk burada
 * bilgidir, süs değil (mockup Ekranlar/Lab/lab_istem_numune_kabul.html:
 * "Sarı jel × 1", "Mor EDTA (aynı tüp)").
 *
 * Burada <b>iş kuralı yok</b>: hangi tüpün hangi tetkiğe gideceği,
 * bayrağın ne zaman konacağı sunucunun işidir. Bu dosya yalnızca sunucudan
 * gelen kodu ekranda okunur hâle getirir.
 */

export interface TupBilgisi { ad: string; kisa: string; renk: string; yazi?: string }

/** `lab_numune.tup_tipi` (433). Renkler piyasadaki kapak renkleridir. */
export const TUP: Record<number, TupBilgisi> = {
  1: { ad: 'SARI (jelli)',    kisa: 'Sarı jel',    renk: '#e8c33a' },
  2: { ad: 'MOR (EDTA)',      kisa: 'Mor EDTA',    renk: '#8d6bb5', yazi: '#fff' },
  3: { ad: 'MAVİ (sitrat)',   kisa: 'Mavi sitrat', renk: '#4d8fd6', yazi: '#fff' },
  4: { ad: 'GRİ (florür)',    kisa: 'Gri florür',  renk: '#9aa5b1' },
  5: { ad: 'YEŞİL (heparin)', kisa: 'Yeşil hep.',  renk: '#4e9e72', yazi: '#fff' },
  6: { ad: 'İDRAR KABI',      kisa: 'İdrar kabı',  renk: '#d9b871' },
  9: { ad: 'DİĞER',           kisa: 'Diğer',       renk: '#c9d6e5' },
};

export const tup = (kod: unknown): TupBilgisi => TUP[Number(kod ?? 9)] ?? TUP[9];

/** `lab_numune.numune_tipi`. */
export const NUMUNE: Record<number, string> = {
  1: 'Serum', 2: 'Plazma', 3: 'Tam kan', 4: 'İdrar', 5: 'Gaita',
  6: 'BOS', 7: 'Sürüntü', 9: 'Diğer',
};

/** `lab_tetkik.bolum`. */
export const BOLUM: Record<number, string> = {
  1: 'Biyokimya', 2: 'Hematoloji', 3: 'Hormon', 4: 'Mikrobiyoloji',
  5: 'Seroloji', 6: 'Koagülasyon', 7: 'İdrar', 9: 'Diğer',
};

/**
 * `lab_numune.kalite` = ret nedeni kod uzayı (db/433): kabul edilen tüpte
 * "Uygun", reddedilende neden reddedildiği. Tek liste olması bilinçli -
 * "hemolizli ama çalışıldı" ile "hemolizli, reddedildi" aynı gözlemdir.
 */
export const KALITE: Record<number, string> = {
  1: 'Uygun', 2: 'Hemolizli', 3: 'Lipemik', 4: 'İkterik', 5: 'Yetersiz miktar',
  6: 'Pıhtılı', 7: 'Yanlış tüp', 8: 'Etiketsiz', 9: 'Diğer',
};

/** `lab_numune.durum`. */
export const NUMUNE_DURUM: Record<number, string> = {
  0: 'Ret', 1: 'Etiketlendi', 2: 'Alındı', 3: 'Kabul', 4: 'Çalışıldı',
};

/**
 * `lab_istem_satir.durum`. 6 = tekrar numune bekliyor (serum indeksi ya da
 * dış lab reddi), 7 = dış laboratuvarda.
 */
export const SATIR_DURUM: Record<number, string> = {
  0: 'İptal', 1: 'Bekliyor', 2: 'Çalışılıyor', 3: 'Sonuçlandı',
  4: 'Teknik onay', 5: 'Onaylandı', 6: 'Tekrar numune', 7: 'Dış lab',
};

/** `lab_istem.durum`. */
export const ISTEM_DURUM: Record<number, string> = {
  1: 'İstendi', 2: 'Numune alındı', 3: 'Çalışılıyor', 4: 'Kısmi sonuç',
  5: 'Onaylandı', 9: 'İptal',
};

/** `lab_varyant.zigosite` (439). */
export const ZIGOSITE: Record<number, string> = {
  1: 'Heterozigot', 2: 'Homozigot', 3: 'Hemizigot', 4: 'Mozaik',
};

/** Mockup'ta bayrak oktur: "H ↑", "LL ↓↓" (lab_sonuc.bayrak). */
export const BAYRAK_OK: Record<string, string> = {
  LL: '↓↓', HH: '↑↑', L: '↓', H: '↑', N: '',
};

/**
 * Bayrağın rozet sınıfı: panik (LL/HH) kırmızı, tek yön sarı, normal nötr.
 * Mockup `.rz kir` / `.rz sari` karşılığı `.rozet hata` / `.rozet uyari`.
 */
export function bayrakSinifi(bayrak: unknown): string {
  const b = String(bayrak ?? '').toUpperCase();
  if (b === 'LL' || b === 'HH') return 'rozet hata';
  if (b === 'L' || b === 'H') return 'rozet uyari';
  return 'rozet gri';
}

/** Antibiyogram yorumu: S duyarlı (yeşil), I orta, R dirençli (kırmızı). */
export function sirSinifi(yorum: unknown): string {
  const y = String(yorum ?? '').trim().toUpperCase();
  if (y === 'S') return 'rozet olumlu';
  if (y === 'R') return 'rozet hata';
  if (y === 'I') return 'rozet uyari';
  return 'rozet gri';
}

/**
 * Referans aralığı metni: metin varsa o (">= 60", "negatif"), yoksa
 * alt–üst. İkisi de yoksa boş - "0 – 0" yazmak yanlış bilgidir.
 */
export function referansMetni(alt: unknown, ust: unknown, metin: unknown): string {
  const m = String(metin ?? '').trim();
  if (m !== '') return m;
  const s = (v: unknown) => (v === null || v === undefined || v === ''
    ? '' : Number(v).toLocaleString('tr-TR', { maximumFractionDigits: 3 }));
  const a = s(alt), u = s(ust);
  if (a === '' && u === '') return '';
  if (a === '') return `≤ ${u}`;
  if (u === '') return `≥ ${a}`;
  return `${a} – ${u}`;
}

/** Sayıyı ekrana yazarken: boş değer "—", sayı Türkçe biçimde. */
export function sayi(v: unknown, basamak = 2): string {
  if (v === null || v === undefined || v === '') return '—';
  const s = Number(v);
  return Number.isFinite(s)
    ? s.toLocaleString('tr-TR', { maximumFractionDigits: basamak })
    : String(v);
}
