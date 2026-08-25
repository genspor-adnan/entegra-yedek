/**
 * BELGE SATIRI - tip ve hesap yardimcilari.
 *
 * BelgeKarti tek dosyada 2478 satira ulasmisti: kart, kalem penceresi ve lot
 * penceresi ic ice duruyor, ayni yardimcilari paylasiyordu. Ortak olan her sey
 * burada; pencereler ayri dosyalarda (bilesenler/belge/*).
 *
 * KURAL: buradaki hesaplar ONIZLEMEDIR - kesin tutari sunucu (BelgeHesap)
 * hesaplar. Ikisi ayni sirayi izler ki ekran ile kayit uyusun.
 */

export interface SatirDurumu {
  anahtar: number;
  /** 1 stok · 2 hizmet · 3 masraf (belge_satir.tur). */
  satirTur: number;
  stokId: number | null;
  hizmetId: number | null;
  stokKodu: string;
  stokAdi: string;
  adet: string;
  /** YEREL para biriminde birim fiyat - belgeye kaydedilen ve gridde gorunen deger. */
  birimFiyat: string;
  /** Kartindan gelen fiyatin para birimi (ör. USD). Yerel ise donusum yok. */
  fiyatDovizi: string;
  /** Kart fiyati kendi doviziyle - kullanici bunu girer, yerel karsiligi hesaplanir. */
  dovizFiyat: string;
  /** fiyatDovizi -> yerel kur (gunluk kurdan gelir, elle degistirilebilir). */
  kur: string;
  /** 1. iskonto yuzdesi. */
  iskonto: string;
  /** 2. iskonto yuzdesi - birinciden SONRA, carpimsal uygulanir (BelgeHesap). */
  iskonto2: string;
  kdv: string;
  /** Satir aciklamasi (belge_satir.aciklama) - gridde stok adinin saginda. */
  aciklama: string;
  /** Seri / lot takibi (belge_satir.izleme_kodu) - irsaliyede gorunur. */
  izlemeKodu: string;
  /** Stok kartindaki izleme turu: 0 yok · 1 Seri · 2 Lot · 3 SKT · 5 Lot+SKT · 6 Seri+Lot. */
  izleme: number;
  /** Bu satir bir PAKET mi (124) - altina icerik satirlari acilir. */
  paket?: boolean;
  /** Icerik satirinda: bagli oldugu paket satirinin anahtari. */
  paketAnahtar?: number;
  /** Kalemin lot/seri dagilimi - bir kalem 1:n lottan gelebilir (db/114). */
  izlemler: IzlemSatiri[];
}
/**
 * Kalemin bir lot satiri. Miktarlarin TOPLAMI kalem miktarina esit olmali -
 * eksik dagitim depodaki miktarla lot toplamini ayirir, sonraki cikis lot
 * bulamaz. Sunucu da ayni kontrolu yapar (BelgeDeposu.IzlemYazAsync).
 */
export interface IzlemSatiri {
  /** CIKISTA: secilen lot kimligi (stok_seri_lot.id). Giriste yok. */
  seriLotId?: number;
  /** CIKISTA: o lottan stokta kalan - secim listesinde gosterilir. */
  kalan?: number;
  lotNo: string;
  seriNo: string;
  uretimTarihi: string;
  sonKullanmaTarihi: string;
  /** Izlem satirinin durumu - GIRISTE 0 ("Girişte"). */
  durum: number;
  miktar: string;
}
export const bosIzlem = (miktar = ''): IzlemSatiri => ({
  lotNo: '', seriNo: '', uretimTarihi: '', sonKullanmaTarihi: '', durum: 0, miktar,
});
/** Raf omru birimi (stok.raf_omru_birim): 1 Gün · 2 Ay · 3 Yıl. */
export const RAF_BIRIM = { 1: 'Gün', 2: 'Ay', 3: 'Yıl' } as const;
/** "2026-08-24" + raf omru -> SKT. Negatif adim ile ters yon (SKT'den ÜRT). */
export function tariheEkle(iso: string, sure: number, birim: number, yon: 1 | -1): string {
  if (!iso || sure <= 0 || birim <= 0) return '';
  const [y, a, g] = iso.slice(0, 10).split('-').map(Number);
  if (!y || !a || !g) return '';
  const t = new Date(y, a - 1, g);
  const adim = sure * yon;
  if (birim === 1) t.setDate(t.getDate() + adim);
  else if (birim === 2) t.setMonth(t.getMonth() + adim);
  else t.setFullYear(t.getFullYear() + adim);
  const p = (n: number) => String(n).padStart(2, '0');
  return `${t.getFullYear()}-${p(t.getMonth() + 1)}-${p(t.getDate())}`;
}
/** Bugunun ISO tarihi (yerel) - SKT gecmis mi kontrolu icin. */
export const bugunIso = () => {
  const t = new Date();
  const p = (n: number) => String(n).padStart(2, '0');
  return `${t.getFullYear()}-${p(t.getMonth() + 1)}-${p(t.getDate())}`;
};

/** Yururlukteki ve gecmis KDV oranlari - eski belgeler %8/%18 tasiyor. */
export const KDV_ORANLARI = [0, 1, 8, 10, 18, 20] as const;

/** Stok kartindaki izleme turune gore hangi alan ZORUNLU. */
export function izlemKurali(izleme: number) {
  return {
    lot:  izleme === 2 || izleme === 5 || izleme === 6,
    seri: izleme === 1 || izleme === 6,
    skt:  izleme === 3 || izleme === 5,
  };
}
export const bosSatir = (anahtar: number): SatirDurumu => ({
  anahtar, satirTur: 1, stokId: null, hizmetId: null, stokKodu: '', stokAdi: '',
  adet: '1', birimFiyat: '', fiyatDovizi: '', dovizFiyat: '', kur: '1',
  iskonto: '0', iskonto2: '0', kdv: '20', aciklama: '', izlemeKodu: '',
  izleme: 0, izlemler: [],
});
/**
 * Satir tutari ONIZLEMESI - sunucudaki BelgeHesap.SatirTutari ile ayni sira:
 * once (adet x fiyat) yuvarlanir, sonra iki iskonto CARPIMSAL uygulanir.
 * Kesin tutar yine sunucudan gelir; bu yalniz ekranda anlik gosterim.
 */
/** "2026-08-23T14:05:00" -> "23.08.2026 14:05" (saat yoksa yalniz tarih). */
export function tarihSaat(ham: unknown): string {
  const metin = String(ham ?? '');
  if (!metin) return '';
  const gun = metin.slice(0, 10).split('-').reverse().join('.');
  const saat = metin.slice(11, 16);
  return saat && saat !== '00:00' ? `${gun} ${saat}` : gun;
}
/** Gridde iskonto gosterimi: tek iskonto "%10", iki kademeli "%10 + %5". */
export function iskonatoMetni(r: { iskonto: string; iskonto2: string }): string {
  const i1 = Number(r.iskonto.replace(',', '.')) || 0;
  const i2 = Number(r.iskonto2.replace(',', '.')) || 0;
  if (!i1 && !i2) return '';
  return i2 ? `%${i1} + %${i2}` : `%${i1}`;
}
export function satirTutari(adet: number, fiyat: number, iskonto: string, iskonto2: string): number {
  const i1 = Number(iskonto.replace(',', '.')) || 0;
  const i2 = Number(iskonto2.replace(',', '.')) || 0;
  return Math.round(adet * fiyat * 100) / 100 * ((100 - i1) / 100) * ((100 - i2) / 100);
}

/**
 * Adet / birim fiyat penceresi. Kalemler gridi SALT GORUNUM oldugu icin
 * ekleme/duzenleme buradan yapilir - hucre ici duzenlemede satir yanlislikla
 * ustune yaziliyor ve uzun stok adlari okunmuyordu.
 */
/**
 * "+/−" dugmeleri: 1 artirir/azaltir. Alt sinir 1 - eksi (ve sifir) miktar
 * belge satirinda anlamsiz, dugmeyle oraya inilemez.
 */
export function adetKaydir(deger: string, yon: number): string {
  const sayi = Number(deger.replace(',', '.')) || 0;
  const yeni = Math.max(1, sayi + yon);
  return Number.isInteger(yeni) ? String(yeni) : yeni.toFixed(2).replace('.', ',');
}
