/** API sozlesmesi - kart. Alan adlari sunucuyla birebir. */

import type { AlanTipi } from '../sozlesme';

// ----------------------------------------------------------------- kart ----
export interface KartYetkisi { duzenle: boolean; sil: boolean; gizliAlanlar: string[] }

export interface KartYaniti {
  kart: Record<string, unknown> & { id?: number; surum?: string };
  detaylar?: Record<string, Record<string, unknown>[]>;
  /**
   * SAYFALI detaylarda TOPLAM satir sayisi (525). Kartla yalniz ilk sayfa
   * gelir; serit bu sayiya gore cizilir, sonraki sayfalar `kartDetaySayfasi`
   * ile istenir. Sayfasiz detaylar burada YER ALMAZ.
   */
  detayToplam?: Record<string, number>;
  kodAd?: Record<string, Record<string, string>>;
  yetki: KartYetkisi;
  izlemeNo: string;
}

/** Cari kartı "İlgili Kişiler" (GenForm > Genel, /api/kart/cari/{id}/kisiler). */
export interface KisiKaydi {
  id: number;
  unvan: string;
  telefon?: string | null;
  eposta?: string | null;
  aktif: boolean;
  gorev?: string | null;
  departman?: number | null;
  bagli: boolean;
}

/** Kisi YAZMA istegi = kaydin sunucunun urettigi alanlari cikarilmis hali. */
export type KisiIstegi = Omit<KisiKaydi, 'id' | 'bagli' | 'aktif'> & { aktif?: boolean };

export interface YetkiSatiri {
  yetkiId: number;
  kod: string;
  ad: string;
  grup: string;
  /** 1 = aksiyon yetkisi (tek izin), 0 = modül yetkisi (Gör/Ekle/Değiştir/Sil). */
  tur: number;
  /** Eski Delphi MODULID'i - ağaçta prefix hiyerarşisini kurar ('' ise yeni yetki). */
  eskiModulId: string;
  gor: boolean;
  ekle: boolean;
  degistir: boolean;
  sil: boolean;
  /** Yetki SAYISAL bir sınır taşıyor mu (661) - taşıyorsa satırda kutu çizilir. */
  degerAlir?: boolean;
  /** Sınırın kendisi: `basvuru.iskonto` için iskonto tavanı (%). Boş = yok. */
  deger?: string;
}

/** Yetki YAZMA istegi = satirin salt-gosterim alanlari cikarilmis hali. */
export type YetkiSatiriIstegi =
  Omit<YetkiSatiri, 'kod' | 'ad' | 'grup' | 'tur' | 'eskiModulId' | 'degerAlir'>;

/** Iskonto onay talebi (662) - ucret sekmesi rozeti ve zil satiri. */
export interface IskontoTalebi {
  id: number;
  belgeId: number;
  /** Talep edilen oran. */
  oran: number;
  /** Kismi onayda talepten kucuk olabilir; ret ve bekleyende 0. */
  onaylananOran: number;
  gerekce: string;
  /** 0 bekliyor · 1 onaylandi · 2 reddedildi · 3 geri cekildi. */
  durum: number;
  isteyen: string;
  istekTs: string;
  onaylayan: string;
  onayTs: string | null;
  kararNotu: string;
  satirSayisi: number;
  tutar: number;
  hasta: string;
  belgeNo: string;
  /** Onay penceresinin hasta seridi (663): 1 erkek · 2 kadin · 0 bilinmiyor. */
  cinsiyet: number;
  yas: number;
  kurum: string;
  doktor: string;
  /** Talebe giren hizmetler; `oran` KALEM BAZLI istenen yuzde (664). */
  kalemler: { ad: string; tutar: number; oran: number }[];
}

/** Iskonto yetki tavani olan rol - onay ekraninin limit sekmesi (666). */
export interface IskontoLimiti {
  rolId: number;
  rolAd: string;
  tavan: number;
  kullaniciSayisi: number;
}

export interface DokumanSatiri {
  id: number;
  ad: string;
  belgeTuru: string;
  contentType: string;
  boyut: number;
  varsayilan: boolean;
  sira: number;
  eklemeTarihi: string;
  paylasimKodu?: string | null;
}

export interface DetayFarki {
  eklenen?: Record<string, unknown>[];
  degisen?: Record<string, unknown>[];
  silinen?: number[];
}

export interface KartYazmaIstegi {
  surum?: string;
  kart?: Record<string, unknown>;
  detaylar?: Record<string, DetayFarki>;
}

/** Kart alan metasi (/api/kart/{kaynak}/alanlar) - liste tarafindaki KolonMeta karsiligi. */
export interface KartAlanMeta {
  ad: string;
  baslik: string;
  tip: AlanTipi;
  grup?: string | null;
  altGrup?: string | null;
  eslesAlan?: string | null;
  yazilabilir: boolean;
  zorunlu: boolean;
  enFazlaUzunluk?: number | null;
  kodlar?: Record<string, string> | null;
  /** Formda cizilmez ama degeri tasinir (arka plan alani - or. cek/senet "Tür"). */
  gizli?: boolean;
  /** Doluysa secenekler bu alanin degerine gore suzulur (Şube -> Banka). */
  bagliAlan?: string | null;
  /** Doluysa alan combo degil JENERIK ARAMA EKRANI ile secilir (260):
      'hasta' -> kisi/hasta aramasi, 'hizmet' -> stok/hizmet aramasi. */
  aramaKaynagi?: string | null;
  /**
   * YALNIZ YENI KAYITTA YAZILABILIR (840): ilk kayitta girilir, mevcut
   * kayitta KILITLI cizilir. Karar ekranda verilir cunku meta kayittan
   * bagimsiz cekiliyor (`/alanlar`).
   */
  yalnizYeniKayitta?: boolean;
  /** Kilitli alanin yaninda gosterilen kisa aciklama. */
  ipucu?: string | null;
  /** Bagli alanda secenek id -> ust id (sube id -> banka id). */
  kodUst?: Record<string, string> | null;
  /**
   * SECENEK BASLIGI (848): secenek id -> baslik. Dolu ise combo `optgroup`
   * ile cizilir - yonetici listesi bolume gore toplanir. Baslik AYRI bir
   * varliktir, secilemez (agactan farki budur).
   */
  kodGrup?: Record<string, string> | null;
  /** Secenekler kod_liste'den geliyorsa listenin kodu (544, "stok.model") -
      kartta etiket tiklanınca o liste duzenlenir. */
  kodListesi?: string | null;
  /**
   * Secim kaynagi HIYERARSIK (484, kategori): secenekler AGAC SIRASINDA ve
   * girintili cizilir. Ust baglari `kodUst`ten okunur; deger yine tek id.
   */
  agac?: boolean;
  /**
   * ALAN BICIM KURALI (bugun 'tckn'). Sunucu kuralin sahibi; ekran AYNI
   * kurali anlik uygular ki kullanici kaydetmeyi beklemesin.
   */
  dogrulama?: string | null;
}

/**
 * Karttaki para birimi / kur / tutar ucgeni. Yerel para disinda bir birim
 * secilirse kur tarih kurundan cekilir, yerel karsilik gosterilir. Yerel tutari
 * KAYDEDERKEN sunucu yeniden hesaplar - buradaki yalniz onizleme.
 */
export interface DovizMetasi {
  cinsAlani: string;
  kurAlani: string;
  tutarAlani: string;
  yerelAlani: string;
  tarihAlani?: string | null;
  yerelPara: string;
}

export interface KartDetayMeta {
  ad: string; baslik: string; saltOkunur: boolean; alanlar: KartAlanMeta[];
  /** Doluysa sekme yalniz bu mantik alan isaretliyken acilir (stok "Paket"). */
  kosulAlani?: string | null;
  /** 1:1 detay (249): en fazla tek satir - ikinci satir DB'de zaten yazilamaz. */
  tekSatir?: boolean;
  /** Sayfa boyu (525); 0/bos ise detay tek seferde gelir. */
  sayfaBoyu?: number;
}

/** Sayfali detayin bir sayfasi (525). */
export interface DetaySayfasi {
  satirlar: Record<string, unknown>[];
  toplam: number;
  sayfa: number;
  boyut: number;
}

export interface KartMetaYaniti {
  /** Yeni kayitta doldurulacak alanlar (katalogdaki varsayilanlar). */
  varsayilanlar?: Record<string, unknown>;
  /** Doluysa yeni kayitta taraf secim ekrani acilir; deger yazilacak alan adi. */
  acilistaTarafSecimi?: string | null;
  /** Doluysa kartta doviz ucgeni var (kur otomatik + yerel tutar). */
  doviz?: DovizMetasi | null;
  kaynak: string;
  alanlar: KartAlanMeta[];
  detaylar: KartDetayMeta[];
  yetki: KartYetkisi;
}

/** API §7 — aksiyon katalogu. Yetkisiz aksiyon HIC donmez. */
export interface AksiyonYaniti {
  kod: string;
  ad: string;
  grup: string;
  hedef: string;              // "araccubugu,sagtus,palet"
  kisayol?: string | null;
  kayitGerekir: boolean;
  aktif: boolean;
  pasifSebep?: string | null;
  /** Düğme vurgusu: 'onay' yeşil · 'ret' kırmızı · 'bir' birincil. Renk
      kararı SUNUCUDA - istemcinin kod adına bakıp renk uydurması, aynı
      aksiyonu iki ekranda iki türlü göstermeye açık kapı bırakırdı. */
  bicim?: string | null;
  /** Fare ipucu (543): adi IKON olan dugmelerde ne yaptigini yalniz bu soyler. */
  ipucu?: string | null;
}

export interface AksiyonListesi {
  ekran: string;
  kayitId?: number | null;
  aksiyonlar: AksiyonYaniti[];
}
