// Sunucu sozlesmesinin (dokuman/01_API_SOZLESMELERI.md) TypeScript karsiligi.
// Alan adlari sunucudakiyle BIREBIR ayni tutulur - cevrim katmani yok.

export type HataKodu =
  | 'DOGRULAMA' | 'YETKISIZ' | 'YASAK' | 'BULUNAMADI'
  | 'CAKISMA' | 'IS_KURALI' | 'SUNUCU'
  // Hesap var ama parolasi hic tanimlanmamis - giris ekrani parola belirleme
  //   adimina gecer.
  | 'ILK_PAROLA';

export interface AlanHatasi { alan: string; mesaj: string }

export interface HataGovdesi {
  kod: HataKodu;
  mesaj: string;
  izlemeNo: string;
  alanlar?: AlanHatasi[];
  cakisanAlanlar?: string[];
  guncelDeger?: Record<string, unknown>;
  engel?: { tablo: string; adet: number; ad?: string };
  /** Excel iceri alma (207): satir numarali dogrulama hatalari. */
  satirHatalari?: { satirNo: number; alan: string; mesaj: string }[];
  toplamHata?: number;
}

/** Sunucudan donen hata; istemcide bu tip firlatilir. */
export class ApiHatasi extends Error {
  durum: number;
  hata: HataGovdesi;

  constructor(durum: number, hata: HataGovdesi) {
    super(hata.mesaj);
    this.durum = durum;
    this.hata = hata;
  }
  get dogrulamaMi() { return this.hata.kod === 'DOGRULAMA' }
  get cakismaMi()   { return this.hata.kod === 'CAKISMA' }
}

/**
 * Yakalanan hatayi EKRANA yazilacak metne cevirir.
 *
 * Ayni ifade 24 dosyada tekrarliyordu; sunucu mesaji varsa oldugu gibi
 * gosterilir (kullaniciya donuk, Turkce), yoksa hatanin kendisi yazilir -
 * "[object Object]" cikmasin. `kodlu` hata kodunu one ekler (BELGE_KURALI: ...).
 */
export function hataMetni(h: unknown, kodlu = false): string {
  if (h instanceof ApiHatasi) {
    const metin = kodlu ? `${h.hata.kod}: ${h.message}` : h.message;
    // IZLEME NUMARASI BEKLENMEYEN HATADA GOSTERILIR: sunucu "izleme
    //   numarasini bildirin" diyor ama numara ekranda hic gorunmuyordu -
    //   kullanicinin bildirebilecegi bir sey yoktu. Is kurali / dogrulama
    //   hatalarinda GOSTERILMEZ: orada mesajin kendisi zaten yeterli,
    //   numara gurultu olur.
    return h.hata.kod === 'SUNUCU' && h.hata.izlemeNo
      ? `${metin} (izleme: ${h.hata.izlemeNo})` : metin;
  }
  return h instanceof Error ? h.message : String(h);
}

/** `hataAyristir` ciktisi - kartlarin durum kutularina birebir oturur. */
export interface HataCozumu {
  /** Kutuda gosterilecek metin. */
  mesaj: string;
  /** alan -> mesaj; alan bazli uyarilar icin. Yoksa bos nesne. */
  alanlar: Record<string, string>;
  /** Ilk hatali alan - kart o sekmeye atlayabilsin diye. */
  ilkAlan: string | null;
  /** 409 CAKISMA: baskasinin degistirdigi alanlar + guncel degerler. */
  cakisma: { alanlar: string[]; guncel: Record<string, unknown> } | null;
}

/**
 * KAYIT HATASINI EKRAN DURUMUNA CEVIRIR - tek yer.
 *
 * Uc kart (GenForm, BelgeKarti, KasaIslemKarti) bunu ayri ayri yaziyordu ve
 * kopyalar ayrismisti: `cakisma` (409) ve `engel` (silme engeli sayaci)
 * dallari YALNIZ GenForm'da vardi, oteki iki kart ayni sunucu yanitina daha
 * fakir tepki veriyordu. Tek cozumleyici uc kartin davranisini esitler.
 */
export function hataAyristir(h: unknown): HataCozumu {
  if (!(h instanceof ApiHatasi))
    return { mesaj: hataMetni(h), alanlar: {}, ilkAlan: null, cakisma: null };

  if (h.dogrulamaMi && h.hata.alanlar?.length)
    return {
      mesaj: h.message,
      alanlar: Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])),
      ilkAlan: h.hata.alanlar[0].alan,
      cakisma: null,
    };

  if (h.cakismaMi)
    return {
      mesaj: h.message,
      alanlar: {},
      ilkAlan: null,
      cakisma: { alanlar: h.hata.cakisanAlanlar ?? [], guncel: h.hata.guncelDeger ?? {} },
    };

  // Silme/degistirme engeli: "hangi tabloda kac kayit" bilgisi mesaja eklenir,
  //   kullanici neyi temizleyecegini bilsin.
  // Kullaniciya TABLO ADI degil, Turkce karsiligi gosterilir (sunucu cozer).
  const engel = h.hata.engel
    ? ` (${h.hata.engel.ad || h.hata.engel.tablo}: ${h.hata.engel.adet} kayıt)` : '';
  // IS_KURALI mesaji ZATEN kullaniciya yazilmis Turkce bir cumledir ("... 
  //   silinemez, ... yapabilirsiniz") - basina teknik kod eklemek okumayi
  //   zorlastiriyordu. Oteki kodlar (SUNUCU, BULUNAMADI...) tani icin kalir.
  const onek = h.hata.kod === 'IS_KURALI' ? '' : `${h.hata.kod}: `;
  return { mesaj: `${onek}${h.message}${engel}`, alanlar: {}, ilkAlan: null, cakisma: null };
}

// --------------------------------------------------------------- kimlik ----
export interface SubeOzeti { id: number; ad: string; varsayilan: boolean; yazma: boolean }

export interface KullaniciOzeti {
  id: number; kod: string; ad: string;
  rolId: number; rolAdi: string;
  dil: number;
  yetkiSurumu: number;
  subeId?: number | null;
  subeYazma: boolean;
  subeler: SubeOzeti[];
  /** Urun modu (215): 1 Gentegre AI (ERP), 2 GenoTIP AI (HBYS). */
  urunModu?: number;
  /**
   * KURULUMDA ACIK MODULLER (359): kurum profilinden cozulur. Menu ve rotalar
   * bunlara gore suzulur; bos dizi = bilgi yok, hicbir sey suzulmez.
   */
  moduller?: string[];
  /**
   * AKTIF SUBEDE basvuruda sorulan hekim rolu (361/364): 1 "Gönderen"
   * (lab/goruntuleme subesi - dis doktor), 4 "Yapan" (digerleri - personel).
   */
  hekimRolu?: number;
}

/** Urun modlari (215). Ad sol ust marka, mesaj basligi ve menu suzmede kullanilir. */
export const URUN_GENOTIP = 2;
/** 3 = "ikisi" (tip merkezi + ticari): HER IKI urunun ekranlari acik. */
export const URUN_IKISI = 3;
export const urunAdi = (mod?: number) => (mod === URUN_GENOTIP ? 'GenoTIP AI' : 'Gentegre AI');

/**
 * Ekranin urun modu kurulumunkiyle uyuyor mu (492).
 *
 * TAM ESITLIK YETMEZ: karma kurulumda (mod 3) tam esitlik arayan suzgec hem
 * ERP'ye hem HBYS'ye ozgu ekranlari birden gizliyordu - kullanici "ikisi"
 * secmesine ragmen menude ne SKRS ne Uretim kaliyordu.
 */
export const modUyar = (ekranModu?: number, kurulumModu?: number) =>
  !ekranModu || (kurulumModu ?? 1) === URUN_IKISI || ekranModu === (kurulumModu ?? 1);

export interface GirisYaniti {
  accessToken: string;
  refreshToken: string;
  sonaErme: string;
  refreshSonaErme: string;
  parolaDegismeli: boolean;
  subeSecimiGerekli: boolean;
  kullanici: KullaniciOzeti;
}

export interface KaynakYetkisi {
  kod: string; gor: boolean; ekle: boolean; degistir: boolean; sil: boolean;
}

export interface BenYaniti {
  kullanici: KullaniciOzeti;
  aksiyonlar: string[];
  kaynaklar: KaynakYetkisi[];
}

// ---------------------------------------------------------------- liste ----
export type KosulOp =
  | 'esit' | 'esitDegil' | 'icerir' | 'baslar' | 'biter'
  | 'buyuk' | 'buyukEsit' | 'kucuk' | 'kucukEsit'
  | 'arasinda' | 'bos' | 'bosDegil' | 'icinde';

export interface Kosul {
  alan?: string;
  op: KosulOp | 'and' | 'or';
  deger?: unknown;
  kosullar?: Kosul[];
}

export interface Siralama { alan: string; yon: 'asc' | 'desc' }

/** Belgenin e-Belge gecmisi satiri (178). */
export interface EBelgeMesaji {
  sira: number;
  tarih: string | null;
  olay: string;
  durum: string;
  kod: string;
  aciklama: string;
}

/** Toplu e-Belge isleminde satir basina sonuc (183). */
export interface TopluEBelgeSonucu {
  belgeId: number;
  basarili: boolean;
  belgeNo: string;
  mesaj: string;
}

export interface ListeIstegi {
  sayfa?: number;
  boyut?: number;
  sirala?: Siralama[];
  filtre?: Kosul;
  grup?: string[];
  toplam?: string[];
  gorunum?: string;
}

export type ListeSatiri = Record<string, unknown>;

export interface ListeYaniti {
  satirlar: ListeSatiri[];
  toplamKayit: number;
  toplamlar?: Record<string, unknown>;
  /** Gruplu liste (ekstre: para birimi basina). Toplamlar TUM suzulmus kume icin. */
  gruplar?: { anahtar: string; ad: string; adet: number; toplamlar?: Record<string, unknown> }[];
  /** Satirlarin hangi kolona gore obeklendigi ("dovizCinsi"). */
  grupKolonu?: string | null;
  sureMs: number;
  izlemeNo: string;
}

/**
 * Cikis belgesinde secilebilecek lot (114). "kalan" o lottan geriye ne kaldigi -
 * cikista bundan fazlasi secilemez.
 */
export interface StokLotSatiri {
  seriLotId: number;
  lotNo: string;
  seriNo: string;
  uretimTarihi?: string | null;
  sonKullanmaTarihi?: string | null;
  kalan: number;
  /** Lotun bulundugu depo - gocmus hareketlerde bilinmiyor (null). */
  depoId?: number | null;
  depoAdi?: string;
}

/** Paket icerigi satiri (124). */
export interface PaketIcerikSatiri {
  stokId: number;
  kod: string;
  ad: string;
  birim: number;
  adet: number;
  kdv: number;
  fiyat: number;
  izleme: number;
}

/**
 * Bir alanin/kolonun VERI TIPI. Liste kolonu (KolonMeta) ve kart alani
 * (KartAlanMeta) ayni kumeyi kullanir - iki yerde ayri yazilinca sunucuya yeni
 * bir tip eklendiginde birinde unutuluyordu.
 */
/** "ondalik" = olculen kesirli deger (ates 36,6 · BKI 30,4); "sayi" tam sayi. */
export type AlanTipi = 'metin' | 'sayi' | 'ondalik' | 'para' | 'tarih' | 'zaman'
                     | 'kod' | 'mantik';

/** §2.4 kolon metasi. Yetkisiz kolon bu listede HIC donmez. */
export interface KolonMeta {
  ad: string;
  baslik: string;
  tip: AlanTipi;
  hizalama: 'sol' | 'orta' | 'sag';
  bicim?: string | null;
  varsayilan: boolean;
  siralanabilir: boolean;
  filtrelenebilir: boolean;
  genislik?: number | null;
  /** Yalniz grup ara toplaminda toplanir (ekstrede doviz tutarlari). */
  sadeceGrupToplami?: boolean;
  /** Kod kolonunun deger-etiket sozlugu (492) - ust serit suzgec combosu. */
  kodlar?: Record<string, string> | null;
}

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
}

/** Yetki YAZMA istegi = satirin salt-gosterim alanlari cikarilmis hali. */
export type YetkiSatiriIstegi =
  Omit<YetkiSatiri, 'kod' | 'ad' | 'grup' | 'tur' | 'eskiModulId'>;

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
  /** Bagli alanda secenek id -> ust id (sube id -> banka id). */
  kodUst?: Record<string, string> | null;
  /**
   * Secim kaynagi HIYERARSIK (484, kategori): secenekler AGAC SIRASINDA ve
   * girintili cizilir. Ust baglari `kodUst`ten okunur; deger yine tek id.
   */
  agac?: boolean;
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
}

export interface AksiyonListesi {
  ekran: string;
  kayitId?: number | null;
  aksiyonlar: AksiyonYaniti[];
}

// ---------------------------------------------------------------- belge ----
export interface DipToplamSatiri {
  tur: number; aciklama: string; deger: number;
  dovizTutari: number; kur: string; belgeDovizi: string;
}

export interface BelgeYaniti {
  belge: Record<string, unknown>;
  satirlar: Record<string, unknown>[];
  dipToplam: DipToplamSatiri[];
  uyarilar?: string[];
  izlemeNo: string;
}

// ------------------------------------------------------- belge donusumu ----
/** v_belge_acik_satir: donusturulmeyi bekleyen satir (F8). */
export interface AcikSatir {
  satirId: number;
  sira: number;
  satirTur: number;
  stokId?: number | null;
  stokKodu?: string | null;
  stokAdi?: string | null;
  /** Kalemin kimligi (293): stok > hizmet > masraf sirasiyla ilk dolu olan. */
  kalemKodu?: string | null;
  kalemAdi?: string | null;
  hizmetId?: number | null;
  masrafId?: number | null;
  aciklama: string;
  miktar: number;
  kapatilanMiktar: number;
  kalanMiktar: number;
  /** Odeme paylasimi (289): satirin kurum/hasta payi ve kalanlari. */
  kurumTutar?: number;
  hastaTutar?: number;
  kurumKalan?: number;
  hastaKalan?: number;
  /**
   * INCE KOVA KALANLARI (470): 1 hasta provizyon · 2 SGK · 3 sigorta/anlasmali
   * kurum · 4 hasta ek katkisi. Donusum bu kodlarla calisir; ustteki
   * kurum/hasta ikilisi ozet gorunumdur.
   */
  sgkKalan?: number;
  ossKalan?: number;
  hastaProvizyonKalan?: number;
  hastaEkKatkiKalan?: number;
  /** 352: satır matrahı, tahsil edilen matrah ve açık kalan TUTAR (tutar bazlı dönüşüm). */
  tutar?: number;
  hastaTahsilMatrah?: number;
  kurumTahsilMatrah?: number;
  tutarKalan?: number;
  birim: number;
  birimFiyat: number;
  iskonto: number;
  kdv: number;
  belgeTur: number;
  belgeTurAdi?: string | null;
  belgeNo: string;
  tarafUnvan: string;
  belgeDovizi: string;
  kapanmaDurum: number;
  /** Faturaya/tahakkuka DONUSMUS tutar, KDV dahil (495). Serit bunu ucret
      toplamindan duserek "Açık Belge"yi yazar. */
  donusenBelgeTutari?: number | null;
}

// belge.kapanma_durum etiketleri BURADA DEGIL: `sayfalar/belgeSabitleri.ts`
//   icindeki KAPANMA_ETIKET tek kaynak (rozet sinifini da tasir). Burada
//   ikinci bir kopya duruyordu ve hic cagrilmiyordu.

// -------------------------------------------------------------- referans ----
/** Il/Ilce/Ulke (039_il_ilce_ulke.sql) - Adresler grid'inde il->ilce cascading secim. */
export interface YerlerYaniti {
  iller: { id: number; ad: string }[];
  ilceler: { id: number; ilId: number; ad: string }[];
  ulkeler: { id: number; ad: string }[];
}

// ----------------------------------------------------------------- kasa ----
/** Bacak sablonu (kasa_islem_turu.sablon) - ekran alanlarini bundan cizer. */
export interface BacakSablonu {
  rol: string;
  yon: 'B' | 'A';
  tutar: string;          // '@tutar' | '@masraf_tutar' | '@karsi_tutar'
}

export interface KasaIslemTuru {
  kod: number;
  ad: string;
  grup: string;           // tahsilat | odeme | virman | doviz | ceksenet | kredi | plan | ...
  yon: number;
  anaHesapTuru: string;   // K/B/P/V/R/H - ana hesap lookup'ini bu suzer
  karsiHesapTuru: string;
  cariZorunlu: number;    // 1 zorunlu, 0 opsiyonel, -1 yasak
  kalemTuru: number;      // 0 yok, 1 masraf, 2 hizmet, 3 ikisi
  planMi: boolean;
  fisMi: boolean;
  fisTuru: number;
  makbuzBasligi: string;
  sablon: BacakSablonu[];
}

export interface KasaBacagi {
  id?: number;
  sira: number;
  rol?: string;
  hesapTuru?: string;
  hesapId?: number | null;
  hesapAdi?: string | null;
  tarafId?: number | null;
  tarafUnvan?: string | null;
  masrafId?: number | null;
  masrafAdi?: string | null;
  hizmetId?: number | null;
  hizmetAdi?: string | null;
  projeId?: number | null;
  borc: number;
  alacak: number;
  yerelBorc: number;
  yerelAlacak: number;
  dovizCinsi: string;
  dovizKuru: number;
  aciklama?: string;
}

export interface FisSatiriOzeti {
  sira: number;
  hesapKodu: string;
  hesapAdi: string;
  borc: number;
  alacak: number;
  dovizCinsi: string;
  dovizBorc: number;
  dovizAlacak: number;
  aciklama: string;
}

export interface FisOzeti {
  id: number;
  fisNo: string;
  fisTarihi: string;
  tur: number;
  durum: number;
  toplamBorc: number;
  toplamAlacak: number;
  satirlar: FisSatiriOzeti[];
}

export interface KasaIslemYaniti {
  islem: Record<string, unknown>;
  bacaklar: KasaBacagi[];
  fis?: FisOzeti | null;
  uyarilar?: string[];
  izlemeNo: string;
}

export interface KasaSecenekleri {
  taslak?: boolean;
  plan?: boolean;
  kurKontrolu?: boolean;
  belgeId?: number | null;
}

export interface KasaIslemYazmaIstegi {
  surum?: string;
  /** Baslik alanlari (camelCase, sunucu beyaz listesi). yerelTutar GONDERILMEZ. */
  islem: Record<string, unknown>;
  /** Bos birakilirsa bacaklari sunucu turun sablonundan uretir (normal akis). */
  bacaklar?: Record<string, unknown>[];
  secenekler?: KasaSecenekleri;
}

/** kasa_islem.durum (DB check ile ayni). */
export const KASA_DURUM: Record<number, string> = {
  0: 'Taslak', 1: 'Planlı', 2: 'Gerçekleşti', 3: 'İptal', 4: 'Plan Kapandı',
};

// ------------------------------------------------ stok kartı: Stok Durumu ----
/** Depo bazlı stok satırı (stok_karti.html "Stok Durumu" sekmesi). */
export interface StokDurumSatiri {
  depoId: number;
  depoAdi: string;
  miktar: number;
  /** Açık SATIŞ siparişlerinde söz verilmiş miktar. */
  rezerve: number;
  /** miktar − rezerve. Kritik uyarısı bu değere bakar. */
  kullanilabilir: number;
  /** Açık ALIŞ siparişlerinde beklenen miktar. */
  yolda: number;
  /** null = bu depo için ayrı limit yok, stok.min_stok geçerli. */
  minStok: number | null;
  maxStok: number | null;
  /** 'yeterli' | 'kritik' | 'yok' */
  durum: string;
}

export interface StokDurumOzeti {
  toplam: number;
  rezerve: number;
  kullanilabilir: number;
  yolda: number;
  depoSayisi: number;
}

export interface StokDurumYaniti {
  ozet: StokDurumOzeti;
  satirlar: StokDurumSatiri[];
  /** Stokun ana birimi ("Adet", "Kg"...) - KPI kutularında miktarın yanına yazılır. */
  birim: string;
}

/** Stok kartı "Hareketler" sekmesi — bir hareket satırı. */
export interface StokHareketSatiri {
  belgeId: number;
  tarih: string;
  belgeTur: number;
  belgeTurAdi: string;
  belgeNo: string;
  tarafUnvan: string;
  /** Tek depo ya da transferde "Çıkış → Giriş". */
  depo: string;
  /** 'giris' | 'cikis' | 'transfer' (suzgecsiz gorunumde iki depoyu birden oynatir) */
  yon: string;
  giris: number;
  cikis: number;
  /** Devirden başlayıp satır satır yürüyen bakiye. */
  kalan: number;
  aciklama: string;
}

export interface StokHareketYaniti {
  /** Başlama tarihinden önceki net toplam. */
  devir: number;
  kapanis: number;
  satirlar: StokHareketSatiri[];
  birim: string;
}

/** Genel Ayarlar satiri (public.referans, sunucuda beyaz listeli). */
export interface AyarSatiri {
  anahtar: string;
  deger: string;
  tip: string;
  aciklama: string;
  /** public.help'ten gelen "?" metni - bos ise ikon gosterilmez (db/103). */
  yardimBaslik: string;
  yardim: string;
}

/** public.help satiri - alan/opsiyon yanindaki "?" ikonunun icerigi. */
export interface YardimKaydi {
  anahtar: string;
  baslik: string;
  metin: string;
}

// ------------------------------------------------------------- ana sayfa ----
/** Panel ust seridindeki kutu. `vurgu`: '', 'olumlu', 'uyari', 'hata'. */
export interface PanelKutusu {
  anahtar: string;
  baslik: string;
  deger: number;
  /** '₺' ise para bicimlenir, degilse adet/kalem gibi sayilir. */
  birim: string;
  alt: string;
  /** Tiklaninca gidilecek liste; bos ise kutu tiklanmaz. */
  yol: string;
  vurgu: string;
}

export interface PanelSatiri {
  id: number;
  ana: string;
  yan: string;
  deger: string;
  yol: string;
}

/** Kurum profiline ozel panel kutusu (508) - icerigi SUNUCU belirler. */
export interface ProfilKutusu {
  kod: string; baslik: string; deger: number; alt: string;
  /** 'normal' | 'uyari' | 'tehlike' | 'olumlu' */
  vurgu: string;
  /** 'para' verilirse tutar olarak bicimlenir. */
  bicim?: string;
  rota?: string;
}

/** Kurum profiline ozel panel blogu: baslik + kolonlar + satirlar. */
export interface ProfilBloku {
  kod: string; baslik: string; ipucu?: string;
  kolonlar: string[];
  /** Kolon basina bicim: 'metin' | 'sayi' | 'para'. */
  bicimler?: string[];
  satirlar: string[][];
}

/** Kurum profili paneli (508): bos `kutular` = genel (ERP) duzen cizilir. */
export interface PanelProfili {
  kurumTipi: string; baslik: string;
  kutular: ProfilKutusu[];
  bloklar: ProfilBloku[];
}

export interface PanelYaniti {
  /** Kurum profiline ozel panel (508); yoksa genel duzen. */
  profil?: PanelProfili | null;
  kutular: PanelKutusu[];
  sonBelgeler: PanelSatiri[];
  kritikStok: PanelSatiri[];
  buyukBakiyeler: PanelSatiri[];
  /** Kullanicinin bitmemis gorevleri - once GECIKENLER. */
  gorevler: PanelSatiri[];
  /** Onumuzdeki 14 gunun takvimi (baslangici olan kayitlar). */
  takvim: PanelSatiri[];
}

/** Randevu Ayarlari > Bolumler (251) - bolum ya da hekim satiri. */
export interface RandevuAyarSatiri {
  id: number | null;
  departmanId: number;
  hekimId: number | null;
  /** Bolum ya da hekim adi (ekranda gosterilir). */
  ad: string;
  baslangicSaat: string;
  bitisSaat: string;
  ogleBaslangic: string;
  ogleBitis: string;
  slotDk: number | null;
  varsayilanSure: number | null;
  calismaGunleri: string;
  aktif: number;
  aciklama: string;
}

/** Sol agacin bir dugumu: bolum + altindaki hekimler. */
export interface RandevuBolumDugumu {
  departmanId: number;
  ad: string;
  ayar: RandevuAyarSatiri;
  hekimler: RandevuAyarSatiri[];
}

/** Bolum/hekim ayar yazma istegi - bos alan ust seviyeden miras alinir. */
export type RandevuAyarYazma = Omit<RandevuAyarSatiri, 'id' | 'ad'>;

// ------------------------------------------------------- kurum profili ----
/** Kurum tipi / modul katalog satiri (359). */
export interface KurumKatalogSatiri { kod: string; ad: string; sira: number }

/** Tip x modul varsayilani: 0 gizli · 1 acik · 2 opsiyonel. */
export interface KurumTipiModul { kurumTipi: string; modul: string; varsayilan: number }

/** Kurulumun kurum profili - tek satir (kurum_profil.id = 1). */
export interface KurumProfil {
  urunModu: number;
  kurumTipi: string;
  altTip: string;
  basamak: string;
  tesisKodu: string;
  subeYapisi: number;
  hekimSayisi: number;
  uniteSayisi: number;
  dil: string;
  paraBirimi: string;
  /** Modul OVERRIDE'lari: {"lab": 1, "teletip": 0} - yoksa tipin varsayilani. */
  moduller: Record<string, number>;
  /** Profilin subesi (364): 0 = kurum geneli, N = o sube. */
  subeId?: number;
  /**
   * Bu sube icin AYRI SATIR YOK, deger kurum genelinden geldi (364). Ekran
   * "devralindi" der ve "bu sube icin ayri ayar" onerir.
   */
  devralindi?: boolean;
}

/**
 * Kurulum adimi (490) - "Özet & Kurulum" sekmesindeki kontrol listesi.
 * Durum ve aciklama SUNUCUDAN gelir; ekran sayim/kontrol yapmaz.
 */
export interface KurumKurulumAdimi {
  sira: number;
  kod: string;
  ad: string;
  /** 1 tamam · 0 bekliyor. */
  durum: number;
  /** Kisa gerekce ("6 liste · 3702 hizmet", "tesis kodu (ÇKYS) boş"). */
  bilgi: string;
  /** Adimi tamamlayacak ekranin rotasi ("/fiyat-listesi"). */
  rota: string;
  /** Dugme yazisi ("Fiyat Listeleri"). */
  aksiyon: string;
}

/**
 * Entegrasyon satiri (491) - "5 · Entegrasyonlar" sekmesi. Gereklilik ve
 * durum SUNUCUDAN: ekran hesap tablosunu kendisi yorumlamaz.
 */
export interface KurumEntegrasyonDurumu {
  sira: number;
  kod: string;
  ad: string;
  /** 2 zorunlu · 1 önerilen · 0 opsiyonel. */
  gereklilik: number;
  /** Neden gerekli ("SGK'lı hasta kabul ediliyorsa zorunlu"). */
  gerekce: string;
  /** 2 canlı hesap · 1 test hesabı · 0 hesap yok. */
  durum: number;
  /** Bulunan hesabın adı. */
  hesap: string;
  /** Hesabın son bağlantı sonucu (kısaltılmış). */
  sonSonuc: string;
}

/**
 * Kurum profilinde acilip kapanan hizmet/stok kategorisi (527).
 * `aktif` kurulumun bugunku durumu, `onerilen` secili tipin varsayilani.
 */
export interface KurumKategoriSatiri {
  id: number; kod: string; ad: string;
  /** 1 stok · 2 hizmet. */
  tur: number;
  aktif: number; onerilen: number;
  /** Kategoriye bagli hizmet ya da stok adedi - kapatmanin etkisi. */
  adet: number;
}

export interface KurumProfilYaniti {
  profil: KurumProfil;
  tipler: KurumKatalogSatiri[];
  moduller: KurumKatalogSatiri[];
  matris: KurumTipiModul[];
  /** Kurulum adimlarinin canli durumu (490). */
  kurulum: KurumKurulumAdimi[];
  /** Entegrasyonlarin gerekliligi ve hesap durumu (491). */
  entegrasyonlar: KurumEntegrasyonDurumu[];
  /** Hizmet/stok kategorileri ve tipin onerisi (527). */
  kategoriler: KurumKategoriSatiri[];
}
