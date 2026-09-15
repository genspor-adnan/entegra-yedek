/**
 * KULLANICI AYARLARI penceresinin saf kuralları (React'siz, test edilebilir):
 * şifre gücü, avatar baş harfleri, "N gün önce".
 *
 * Şifre kuralları SUNUCUYLA aynı tabandan: en az 8 karakter (ParolaKurali)
 * ve son 3 şifreden farklı (687, sunucu denetler - listede • ile gösterilir,
 * istemci eski hash'leri bilemez).
 */
/** `tamam = null`: sunucu denetler (son 3 parola) - ekranda ✔/✖ yerine • çizilir. */
export interface SifreKurali { ad: string; tamam: boolean | null }
export interface SifreGucu { puan: number; kurallar: SifreKurali[] }

/** Türkçe karakterleri düşürüp küçültür - ad/soyad karşılaştırması için. */
const sade = (s: string) => s.toLocaleLowerCase('tr-TR')
  .replace(/ı/g, 'i').replace(/ğ/g, 'g').replace(/ü/g, 'u').replace(/ş/g, 's')
  .replace(/ö/g, 'o').replace(/ç/g, 'c');

/** Puan 0-4: uzunluk · büyük/küçük · rakam · ad-soyad içermiyor. */
export function sifreGucu(sifre: string, adSoyad = ''): SifreGucu {
  const parcalar = sade(adSoyad).split(/\s+/).filter(p => p.length >= 3);
  const s = sade(sifre);
  const kurallar: SifreKurali[] = [
    { ad: 'En az 8 karakter', tamam: sifre.length >= 8 },
    { ad: 'Büyük/küçük harf', tamam: /[a-zçğıöşü]/.test(sifre) && /[A-ZÇĞİÖŞÜ]/.test(sifre) },
    { ad: 'Rakam', tamam: /\d/.test(sifre) },
    { ad: 'Ad-soyad içermiyor', tamam: sifre.length > 0 && !parcalar.some(p => s.includes(p)) },
    // Sunucu kurali (687): eski hashlerle karsilastirma istemcide yapilamaz.
    { ad: 'Son 3 şifreden farklı', tamam: null },
  ];
  return { puan: kurallar.filter(k => k.tamam === true).length, kurallar };
}

/** "Dr. Osman AKAR" → "OA"; tek kelime → ilk iki harf; boş → "?". */
export function basHarfler(ad: string): string {
  const p = ad.replace(/\b(dr|prof|doç|op|uzm|dt)\.?\s*/gi, '').trim().split(/\s+/).filter(Boolean);
  if (p.length === 0) return '?';
  if (p.length === 1) return p[0].slice(0, 2).toLocaleUpperCase('tr-TR');
  return (p[0][0] + p[p.length - 1][0]).toLocaleUpperCase('tr-TR');
}

/** ISO tarih → "62 gün önce" / "bugün" / "dün". */
export function gunOnce(iso: string, c: (m: string) => string = m => m, simdi = new Date()): string {
  const t = new Date(iso);
  if (Number.isNaN(t.getTime())) return c('bilinmiyor');
  const gun = Math.floor((Date.UTC(simdi.getFullYear(), simdi.getMonth(), simdi.getDate())
    - Date.UTC(t.getFullYear(), t.getMonth(), t.getDate())) / 86400000);
  if (gun <= 0) return c('bugün');
  if (gun === 1) return c('dün');
  return `${gun} ${c('gün önce')}`;
}
