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
import { hamSayi } from '../bilesenler/bicim';

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
  /**
   * Satirin TESLIM (termin) tarihi - siparislerde (140). Bos = termin
   * verilmemis. Odeme vadesiyle (baslikta `vadeGun`) ilgisi yok: bu malin ne
   * zaman cikacagi, o paranin ne zaman odenecegi.
   */
  teslimTarihi?: string;
  /**
   * KAYITLI satirin sunucudaki kimligi (belge_satir.id). Yeni satirda YOKTUR -
   * termin guncelleme gibi satir bazli islemler yalniz kayitli satirda calisir.
   */
  satirId?: number;
  /** Girilen birim (kod_liste 'stok.ana_birim' degeri) - 143. */
  birim?: number;
  /**
   * Girilen birimin ANA BIRIM carpani (1 kutu = 12 adet -> 12). Stok her zaman
   * ana birimde hareket eder: miktar = adet x birimCarpan.
   */
  birimCarpan?: number;
  /** Stok kartinin ana birim adi - gridde "2 Kutu" yazabilmek icin. */
  birimAdi?: string;
  /** Bu satir bir PAKET mi (124) - altina icerik satirlari acilir. */
  paket?: boolean;
  /** Icerik satirinda: bagli oldugu paket satirinin anahtari. */
  paketAnahtar?: number;
  /**
   * IADE satirinda kaynak fatura satiri (belge_satir.id). Iade edilen miktar
   * bu bagdan hesaplanir (132) - kolon degil, tureme.
   */
  kaynakSatirId?: number;
  /**
   * Kalemi fiyatlayan KAMPANYA SATIRI (274) - denetim izi. Kampanya kurali
   * sonradan degistirilse ya da silinse bile belgede hangi kuralin uygulandigi
   * kalir; iade/iptalde ayni fiyat yeniden uretilebilir.
   */
  kampanyaSatirId?: number | null;
  /**
   * ODEME PAYLASIMI (289). Basvuruda satir tutari iki paya bolunur: kurum
   * (SGK/OSS provizyonu) ve hasta (katilim payi / fark). Satir FIZIKSEL
   * BOLUNMEZ - provizyon revize olunca burada tutar guncellenir.
   */
  kurumTutar?: string;
  hastaTutar?: string;
  /** Karsilama orani % - tutarlar bundan hesaplanir, elle de girilebilir. */
  karsilama?: string;
  /** Payin ne kadari belgeye donustu (sunucudan gelir, salt okunur). */
  kurumKapatilan?: number;
  hastaKapatilan?: number;
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
// bugunIso / tarihSaat `bilesenler/bicim.ts`e tasindi (tek bicim evi).

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
/** Gridde iskonto gosterimi: tek iskonto "%10", iki kademeli "%10 + %5". */
export function iskonatoMetni(r: { iskonto: string; iskonto2: string }): string {
  const i1 = hamSayi(r.iskonto);
  const i2 = hamSayi(r.iskonto2);
  if (!i1 && !i2) return '';
  return i2 ? `%${i1} + %${i2}` : `%${i1}`;
}
export function satirTutari(adet: number, fiyat: number, iskonto: string, iskonto2: string): number {
  const i1 = hamSayi(iskonto);
  const i2 = hamSayi(iskonto2);
  return Math.round(adet * fiyat * 100) / 100 * ((100 - i1) / 100) * ((100 - i2) / 100);
}

/**
 * Sunucudan gelen belge satirlarini kart durumuna cevirir.
 *
 * SAF fonksiyon: BelgeKarti'nin acilis efektinde 45 satir suren bu esleme,
 * kartin geri kalaniyla hicbir sey paylasmiyordu. Alan adlari sunucu
 * sozlesmesine bagli oldugu icin degistigi yer tek olsun.
 */
export function yanittanSatirlar(
  satirlar: readonly Record<string, unknown>[] | undefined,
  yerelPara: string,
): SatirDurumu[] {
  return (satirlar ?? []).map((r, i) => ({
    anahtar: i + 1,
    // Sunucudaki satir kimligi: termin guncelleme gibi satir bazli islemler
    //   bunu kullanir (140).
    satirId: r.id ? Number(r.id) : undefined,
    satirTur: Number(r.tur ?? 1),
    stokId: r.stokId ? Number(r.stokId) : null,
    hizmetId: r.hizmetId ? Number(r.hizmetId) : null,
    stokKodu: String(r.stokKodu ?? ''),
    // Odeme paylasimi (289): tutarlar ve kapanma sayaclari.
    kurumTutar: r.kurumTutar != null ? String(r.kurumTutar) : undefined,
    hastaTutar: r.hastaTutar != null ? String(r.hastaTutar) : undefined,
    karsilama: r.karsilama != null ? String(r.karsilama) : undefined,
    kurumKapatilan: r.kurumKapatilan != null ? Number(r.kurumKapatilan) : undefined,
    hastaKapatilan: r.hastaKapatilan != null ? Number(r.hastaKapatilan) : undefined,
    // "??" DEGIL "||": sunucu bos alani '' donduruyor ve nullish operatoru bos
    //   string'i gecerli sayip yedege dusmuyordu - hizmet satirinda kod/ad bos
    //   gorunuyordu (kullanici).
    stokAdi: String(r.stokAdi || r.hizmetAdi || r.masrafAdi || r.aciklama || ''),
    aciklama: String(r.aciklama ?? ''),
    izlemeKodu: String(r.izlemeKodu ?? ''),
    // Termin (140): sunucu tam tarih doner, ekran gun bekliyor.
    teslimTarihi: String(r.teslimTarihi ?? '').slice(0, 10),
    // Ambalaj (143): GIRILEN miktar `adet`tir; `miktar` ana birim karsiligidir
    //   (2 kutu / 24 adet) - kart girileni gosterir.
    birim: Number(r.birim ?? 0),
    birimCarpan: Number(r.birimCarpan ?? 1) || 1,
    adet: String(r.adet ?? r.miktar ?? 0),
    birimFiyat: String(r.birimFiyat ?? 0),
    // SATIR BAZLI DOVIZ (kullanici): kalem kendi para biriminde girilmis
    //   olabilir - kayitli satirdan geri yuklenir, yoksa yerel sayilir.
    fiyatDovizi: String(r.dovizCinsi ?? '') || yerelPara,
    dovizFiyat: String(r.dovizBirimFiyat ?? r.birimFiyat ?? 0),
    kur: String(r.dovizKuru ?? 1),
    iskonto: String(r.iskonto ?? 0),
    iskonto2: String(r.iskonto2 ?? 0),
    kdv: String(r.kdv ?? 0),
    // Kayitli kalemin lot dagilimi (db/114) - kalem yeniden acilinca kullanici
    //   hangi lottan kac adet girdigini gormeli.
    izleme: Number(r.izleme ?? 0),
    izlemler: ((r.izlemler ?? []) as Record<string, unknown>[]).map(z => ({
      lotNo: String(z.lotNo ?? ''),
      seriNo: String(z.seriNo ?? ''),
      uretimTarihi: String(z.uretimTarihi ?? '').slice(0, 10),
      sonKullanmaTarihi: String(z.sonKullanmaTarihi ?? '').slice(0, 10),
      durum: Number(z.durum ?? 0),
      miktar: String(z.miktar ?? 0),
    })),
  }));
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
  const sayi = hamSayi(deger);
  const yeni = Math.max(1, sayi + yon);
  return Number.isInteger(yeni) ? String(yeni) : yeni.toFixed(2).replace('.', ',');
}
