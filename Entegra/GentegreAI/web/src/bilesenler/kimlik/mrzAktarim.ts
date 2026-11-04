import type { MrzEslesen, MrzSonucu } from '../../api/uclar/kimlik';

/**
 * MRZ → HASTA KARTI AKTARIMI (1255, mockup kimlik_mrz_okut.html ②).
 *
 * Pencere sunucunun çözdüğü alanları karttaki / kayıtlı hastadaki değerlerle karşılaştırır; kullanıcı farkları tek tek
 * onaylar. Buradaki saf yardımcılar: karşılaştırma satırları, aktarım paketi, kart bileşenine uygulama ve "bekleyen
 * aktarım" (pencere başvuru aramasından açıldıysa yeni hasta kartı başka sekmede açılır - paket oraya burada taşınır).
 */

/** Karta yazılacak değerler: kart alanları (taraf) + özlük detayı (taraf_hasta). */
export interface MrzAktarim {
  kart: Record<string, string>;
  ozluk: Record<string, string>;
  /** Doğrulanmış T.C. kimlik no (TD1) - MERNİS ile gerçek harfler alınabilsin. */
  kimlikNo: string;
  /** Kayıtlı hasta (eşleşen) ya da null. */
  hastaId: number | null;
  /** Bilgi şeridi için ad soyad (MRZ ASCII ya da kayıtlı). */
  adSoyad: string;
}

export type SatirDurumu = 'ayni' | 'fark' | 'dolacak' | 'yok';

/** Karşılaştırma tablosunun bir satırı. `hedef` kart alanı mı özlük alanı mı. */
export interface KarsilastirmaSatiri {
  anahtar: string;
  hedef: 'kart' | 'ozluk';
  etiket: string;
  mrz: string;          // karta yazılacak değer
  mrzGoster: string;    // tabloda görünen
  mevcut: string;
  mevcutGoster: string;
  durum: SatirDurumu;
  /** Kontrol hanesi tutmayan alan - aktarılmaz. */
  bozuk: boolean;
  /** Varsayılan: alınsın mı. */
  al: boolean;
}

/** Türkçe harfleri ASCII büyük harfe indirger - MRZ ile kayıtlı adı karşılaştırmak için ("Yılmaz" ≈ "YILMAZ"). */
export function asciiKat(s: string): string {
  return s.replace(/ı/g, 'i').replace(/İ/g, 'I').replace(/ş/g, 's').replace(/Ş/g, 'S').replace(/ğ/g, 'g').replace(/Ğ/g, 'G')
    .replace(/ü/g, 'u').replace(/Ü/g, 'U').replace(/ö/g, 'o').replace(/Ö/g, 'O').replace(/ç/g, 'c').replace(/Ç/g, 'C')
    .replace(/â/g, 'a').replace(/î/g, 'i').replace(/û/g, 'u')
    .toUpperCase().replace(/\s+/g, ' ').trim();
}

const tarihGoster = (iso: string) => iso ? `${iso.slice(8, 10)}.${iso.slice(5, 7)}.${iso.slice(0, 4)}` : '';
const gun = (v: unknown) => (v == null ? '' : String(v).slice(0, 10));
const metin = (v: unknown) => (v == null ? '' : String(v).trim());
const CINSIYET: Record<string, string> = { '1': 'Erkek', '2': 'Kadın' };
export const BELGE_TURU: Record<string, string> = { '1': 'Kimlik Kartı', '2': 'Pasaport', '3': 'Diğer' };

/** Karşılaştırma tabanı: kayıtlı hasta ya da açık kartın değerleri. */
export interface MevcutDegerler { kart: Record<string, unknown>; ozluk: Record<string, unknown> }

export function eslesendenMevcut(e: MrzEslesen): MevcutDegerler {
  return {
    kart: { vkno: e.kimlikNo, ad: e.ad, soyad: e.soyad },
    ozluk: { dogumTarihi: e.dogumTarihi, cinsiyet: e.cinsiyet, uyruk: e.uyruk, pasaportNo: e.pasaportNo,
             belgeTuru: e.belgeTuru, belgeSeriNo: e.belgeSeriNo, belgeSonKullanma: e.belgeSonKullanma },
  };
}

/**
 * Satırları kurar. Ad / soyad: ASCII eşitse "Aynı" (gerçek harfler korunur, MRZ alınmaz); mevcut boşsa dolar;
 * gerçekten farklıysa varsayılan MRZ alınır (mockup: "Farklı → MRZ al"), kullanıcı kutuyu kaldırabilir.
 */
export function karsilastir(s: MrzSonucu, mevcut: MevcutDegerler | null, uyrukAdlari?: Record<string, string>): KarsilastirmaSatiri[] {
  const pasaport = s.bicim !== 'TD1';
  const satir = (anahtar: string, hedef: 'kart' | 'ozluk', etiket: string, mrz: string, mrzGoster: string,
                 mevcutHam: unknown, mevcutGoster: string, bozuk = false, adMi = false): KarsilastirmaSatiri => {
    const mevcutDeger = metin(mevcutHam);
    let durum: SatirDurumu;
    if (!mrz) durum = 'yok';
    else if (!mevcut || !mevcutDeger) durum = 'dolacak';
    else if (adMi ? asciiKat(mevcutDeger) === asciiKat(mrz) : mevcutDeger === mrz) durum = 'ayni';
    else durum = 'fark';
    return { anahtar, hedef, etiket, mrz, mrzGoster, mevcut: mevcutDeger, mevcutGoster, durum, bozuk,
             al: !bozuk && (durum === 'dolacak' || durum === 'fark') };
  };
  const k = mevcut?.kart ?? {}; const o = mevcut?.ozluk ?? {};
  const uyrukAd = (kod: unknown) => (kod == null || kod === '' ? '' : uyrukAdlari?.[String(kod)] ?? String(kod));
  const satirlar: KarsilastirmaSatiri[] = [];
  if (!pasaport)
    satirlar.push(satir('vkno', 'kart', 'Kimlik No', s.kimlikNo ?? '', s.kimlikNo ?? '', k.vkno, metin(k.vkno),
                        !s.kimlikNo && !!(s.hatalar?.some(h => h.includes('T.C.')))));
  satirlar.push(satir('soyad', 'kart', 'Soyad', s.soyad ?? '', s.soyad ?? '', k.soyad, metin(k.soyad), false, true));
  satirlar.push(satir('ad', 'kart', 'Ad', s.ad ?? '', s.ad ?? '', k.ad, metin(k.ad), false, true));
  const dogum = gun(s.dogumTarihi);
  satirlar.push(satir('dogumTarihi', 'ozluk', 'Doğum Tarihi', dogum, tarihGoster(dogum), gun(o.dogumTarihi), tarihGoster(gun(o.dogumTarihi)),
                      s.dogumTamam === false));
  satirlar.push(satir('cinsiyet', 'ozluk', 'Cinsiyet', s.cinsiyet ?? '', CINSIYET[s.cinsiyet ?? ''] ?? '', o.cinsiyet,
                      CINSIYET[metin(o.cinsiyet)] ?? metin(o.cinsiyet)));
  satirlar.push(satir('uyruk', 'ozluk', 'Uyruk', s.uyrukKod ?? '', `${s.uyruk ?? ''}${s.uyrukAdi ? ` (${s.uyrukAdi})` : ''}`
                      + (s.uyruk && !s.uyrukKod ? ' - listede bulunamadı, elle seçin' : ''), o.uyruk, uyrukAd(o.uyruk)));
  if (pasaport)
    satirlar.push(satir('pasaportNo', 'ozluk', 'Pasaport No', s.belgeNo ?? '', s.belgeNo ?? '', o.pasaportNo, metin(o.pasaportNo),
                        s.belgeNoTamam === false));
  satirlar.push(satir('belgeTuru', 'ozluk', 'Kimlik Belgesi', s.belgeTuru ? String(s.belgeTuru) : '',
                      BELGE_TURU[String(s.belgeTuru ?? '')] ?? '', o.belgeTuru, BELGE_TURU[metin(o.belgeTuru)] ?? metin(o.belgeTuru)));
  satirlar.push(satir('belgeSeriNo', 'ozluk', 'Belge No', s.belgeNo ?? '', s.belgeNo ?? '', o.belgeSeriNo, metin(o.belgeSeriNo),
                      s.belgeNoTamam === false));
  const skt = gun(s.sonKullanma);
  satirlar.push(satir('belgeSonKullanma', 'ozluk', 'Belge Geçerlilik', skt, tarihGoster(skt) + (s.suresiDolmus ? ' (dolmuş)' : ''),
                      gun(o.belgeSonKullanma), tarihGoster(gun(o.belgeSonKullanma)), s.sonKullanmaTamam === false));
  return satirlar;
}

/** İşaretli satırlardan aktarım paketi. */
export function aktarimPaketi(s: MrzSonucu, satirlar: KarsilastirmaSatiri[], hastaId: number | null): MrzAktarim {
  const kart: Record<string, string> = {}; const ozluk: Record<string, string> = {};
  for (const r of satirlar) if (r.al && r.mrz) (r.hedef === 'kart' ? kart : ozluk)[r.anahtar] = r.mrz;
  const adSoyad = hastaId && s.eslesen ? `${s.eslesen.ad} ${s.eslesen.soyad}`.trim() : `${s.ad ?? ''} ${s.soyad ?? ''}`.trim();
  return { kart, ozluk, kimlikNo: s.kimlikNo ?? '', hastaId, adSoyad };
}

/** Kart bileşenine uygular (GenForm `alanDegistir` + özlük detayı güncel[0]). Mernis getir ile aynı yol. */
export interface AktarimHedefi {
  alanDegistir(ad: string, v: string): void;
  ozlukYaz(degisiklik: Record<string, string>): void;
}

export function aktarimiUygula(hedef: AktarimHedefi, a: MrzAktarim) {
  for (const [ad, v] of Object.entries(a.kart)) hedef.alanDegistir(ad, v);
  if (Object.keys(a.ozluk).length) hedef.ozlukYaz(a.ozluk);
}

// ------------------------------------------------------------ bekleyen aktarım ----
// Başvuru araması → "Yeni Hasta (dolu)": kart kendi sekmesinde açılır; paket burada bekler, hasta kartının araç
//   grubu (HastaKimlikAraclari) açılışta alır ve uygular. Tek kullanımlık, 3 dakika ömürlü - bayat paket ilgisiz
//   bir yeni karta düşmesin.
let bekleyen: { paket: MrzAktarim; hedefId: number | 'yeni'; zaman: number } | null = null;
const OMUR_MS = 3 * 60 * 1000;

export function mrzBekleyenKoy(paket: MrzAktarim, hedefId: number | 'yeni') {
  bekleyen = { paket, hedefId, zaman: Date.now() };
}

/** Bu kart için bekleyen paket varsa verir ve siler. */
export function mrzBekleyenAl(kartId: number | 'yeni'): MrzAktarim | null {
  if (!bekleyen || Date.now() - bekleyen.zaman > OMUR_MS) { bekleyen = null; return null }
  if (bekleyen.hedefId !== kartId) return null;
  const p = bekleyen.paket; bekleyen = null; return p;
}
