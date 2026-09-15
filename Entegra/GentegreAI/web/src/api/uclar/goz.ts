import { gonder, istek } from '../cekirdek';

/**
 * GÖZ MODÜLÜ — liste/kart dışı iki sorgu (691): hasta özeti ve ölçüm trendi.
 *
 * Geri kalan her şey generic liste/kart üzerinden gider; burada yalnız
 * "birden çok tabloyu tek soruda toplayan" uçlar var.
 */

/** Bir gözün son ölçümleri (`/api/goz/hasta/{id}/ozet` → olcumler). */
export interface GozOlcumOzeti {
  /** 1 OD · 2 OS. */
  goz: number;
  gozAd: string;
  bcva: number | null;
  bcvaSnellen: string;
  bcvaZaman: string | null;
  gib: number | null;
  cct: number | null;
  hedefGib: number | null;
  /** 0 normal · 1 yüksek (>21) · 2 panik (>30) - ölçümde hesaplanır. */
  gibBayrak: number;
  gibZaman: string | null;
  sph: number | null;
  cyl: number | null;
  aks: number | null;
  cdDikey: number | null;
  drEvre: number | null;
  amdEvre: number | null;
  /** Son ve ONDAN ÖNCEKİ RNFL: tek değer "inceliyor mu"yu göstermez. */
  rnflSon: number | null;
  rnflZaman: string | null;
  rnflOnceki: number | null;
  rnflOncekiZaman: string | null;
}

export interface GozTakipOzeti {
  id: number;
  goz: number;
  hastalik: number;
  evre: string;
  hedefGib: number | null;
  sonrakiKontrol: string | null;
  progresyon: number;
  /** Bugün - sonraki kontrol; negatifse henüz zamanı gelmemiş. */
  gecikmeGun: number | null;
}

export interface GozZiyaretOzeti {
  id: number; tarih: string; tur: number; hekim: string; dilate: boolean;
}

export interface GozIslemOzeti {
  id: number; goz: number; tur: number; durum: number; zaman: string | null;
  dozNo: number; ilac: number; ameliyatTur: number; lazerTur: number;
}

export interface GozReceteOzeti {
  id: number; receteNo: string; tur: number; durum: number; tarih: string;
  odSph: number | null; odCyl: number | null; odAks: number | null; odAdd: number | null;
  osSph: number | null; osCyl: number | null; osAks: number | null; osAdd: number | null;
}

export interface GozHastaOzeti {
  olcumler: GozOlcumOzeti[];
  takipler: GozTakipOzeti[];
  ziyaretler: GozZiyaretOzeti[];
  islemler: GozIslemOzeti[];
  receteler: GozReceteOzeti[];
}

/** Ayrıştırılmış ölçümün zaman serisi (RNFL, MD, CMT, AL…). */
export interface GozTrendNoktasi {
  zaman: string;
  goz: number;
  deger: number | null;
  birim: string;
  bayrak: number;
  tetkik: number;
  /** Düşük sinyalli çekimin "incelmesi" gerçek incelme değildir. */
  kalite: number | null;
}

/**
 * ÜNİTE PANOSU SAYAÇLARI (mockup goz_unite_panosu.html üst şeridi).
 *
 * Kanban yalnız AÇIK istasyonları görüyor; "bugün kaç hasta geldi, kaçı
 * tamamlandı, ortalama ziyaret kaç dakika" o kümede yok — sayılar sunucuda
 * hesaplanır, ekran ikinci bir tanım üretmez.
 */
export interface GozUniteOzeti {
  gun: string;
  gunOzet: {
    ziyaret: number; tamamlanan: number; unitede: number; ortZiyaretDk: number;
  } | null;
  acik: {
    bekleyen: number; ortBeklemeDk: number; enUzunDk: number;
    dilatasyonda: number; dilatasyonHazir: number;
  } | null;
  /** En uzun bekleyen hasta — sayının yanında adı da durmalı. */
  enUzun: { hasta: string; istasyon: number; dk: number } | null;
  istasyonlar: { istasyon: number; sayi: number; enUzunDk: number }[];
  /** En uzun bekleyen istasyon: "ünite yoğun" değil, nerede tıkalı. */
  darbogaz: { istasyon: number; sayi: number; enUzunDk: number } | null;
  /** Oda / cihaz doluluğu: pano HASTAYI değil KAYNAĞI sayar. */
  odalar: {
    oda: string; sayi: number; hasta: string; istasyon: number;
    sureDk: number; enUzunDk: number;
  }[];
  /** Hekim (ve tekniker) yükü — ön tetkik ünitenin girişi. */
  hekimler: {
    personel: string; tamamlanan: number; bekleyen: number;
    ortDk: number; enUzunDk: number;
  }[];
}

/**
 * Muayene kartı üst şeridi (mockup goz_detayli_muayene.html başlık + bağlam).
 * Hekimin ölçümden ÖNCE okuduğu dört şey + tamamlanma sayaçları.
 */
export interface GozMuayeneSeridiYaniti {
  kimlik: {
    hasta: string; yas: number | null; cinsiyet: number; hastaNo: string;
    protokol: string; tarih: string; hekim: string; bolum: string;
    sikayet: string; ozgecmis: string; sistem: string; soygecmis: string;
    dilate: boolean; dilatasyonIlac: string; muayeneTuru: number;
    tamamlandi: boolean; oda: string;
  };
  /** Kaynağı CİHAZ olan ölçümler: "Otoref ✔ 10:02". */
  onTetkik: { ad: string; zaman: string | null; sayi: number }[];
  durum: {
    va: number; ref_: number; gib: number; onSegment: number;
    fundus: number; tani: number;
  };
}

/* ------------------------------------------------- göz şeması (çizim, 705) */

/** Şema üzerindeki tek işaret. Konum 0-1 arası ORAN: ekran boyu değişir, kayıt değişmez. */
export interface GozCizimIsareti {
  id?: number;
  /** 1 damga · 2 serbest çizgi · 3 alan · 4 etiket. */
  sekil: number;
  /** `damgalar` paletindeki tür. */
  tur: number;
  x: number | null;
  y: number | null;
  /** Saat kadranı SUNUCUDA hesaplanır (OD saat yönünde, OS ters). */
  saat?: number | null;
  boyutDd?: number | null;
  renk: string;
  /** Serbest çizim yolu (SVG path "d"); damgada boş. */
  yol: string;
  aciklama: string;
  sira?: number;
}

export interface GozCizimi {
  id: number;
  goz: number;
  semaTuru: number;
  surum: number;
  kilitli: boolean;
  svg: string;
  uretilenMetin: string;
  aciklama: string;
  zaman: string;
  kullanici: string;
  isaretler: GozCizimIsareti[];
}

export interface GozDamgasi {
  tur: number; ad: string; simge: string; renk: string; semalar: number[];
}

export interface GozBulguHedefi { kod: string; ad: string; gozGerekir: boolean }

export interface GozCizimYaniti {
  muayeneKapali: boolean;
  hasta: string;
  hastaId: number;
  dilate: boolean;
  tarih: string;
  semalar: GozCizimi[];
  gecmis: { id: number; goz: number; semaTuru: number; surum: number;
            kilitli: boolean; zaman: string; kullanici: string }[];
  damgalar: GozDamgasi[];
  semaAdlari: { tur: number; ad: string }[];
  hedefler: GozBulguHedefi[];
}

/* -------------------------------------------------------- dikte (705) */

export interface DikteTerimi {
  id: number;
  /** 1 kurum · 2 kullanıcı. */
  kapsam: number;
  soylenen: string;
  yazilan: string;
  /** 1 terim · 2 komut · 3 sık cümle. */
  tur: number;
  /** Komutun ne yaptığı: "goz:1" · "hedef:fundus.disk" · "noktalama:." · "sil". */
  eylem: string;
  sira: number;
}

export interface DikteSozlugu {
  terimler: DikteTerimi[];
  komutlar: DikteTerimi[];
  cumleler: DikteTerimi[];
  hedefler: GozBulguHedefi[];
  kapali: { ad: string; neden: string }[];
  /** Bunun altındaki tanıma parçası YAZILMAZ - kural sunucudan gelir. */
  guvenEsigi: number;
}

export interface GozCizimKarsilastirma {
  oncekiId: number;
  oncekiTarih: string | null;
  semalar: { goz: number; semaTuru: number; isaretler: GozCizimIsareti[] }[];
  /** Fark SUNUCUDA hesaplanır: tür + saat eşleşmesi. */
  degisim: { goz: number; semaTuru: number; tur: number; saat: number | null;
             durum: 'yeni' | 'duruyor' | 'kayboldu' }[];
  aciklama: string;
}

/** Yazdırılacak belge: antet + kimlik + şemalar + işaret dökümü. */
export interface GozCizimCiktisi {
  muayene: Record<string, unknown>;
  kurum: Record<string, unknown> | null;
  semalar: {
    id: number; goz: number; semaTuru: number; surum: number; kilitli: number;
    uretilenMetin: string; zaman: string; kullanici: string;
  }[];
  isaretler: (GozCizimIsareti & { goz: number; semaTuru: number })[];
  damgalar: GozDamgasi[];
  semaAdlari: { tur: number; ad: string }[];
}

export const gozUclari = {
  /** Öncekiyle karşılaştır: önceki çizim + yeni/kaybolan işaret farkı (705). */
  gozCizimKarsilastir: (gozMuayeneId: number) =>
    istek<GozCizimKarsilastirma>(`/api/goz/muayene/${gozMuayeneId}/cizim/karsilastir`),

  /** Şema çıktısı: kurum anteti, kimlik, çizimler ve işaret dökümü. */
  gozCizimCikti: (gozMuayeneId: number) =>
    istek<GozCizimCiktisi>(`/api/goz/muayene/${gozMuayeneId}/cizim/cikti`),

  /** Muayenenin çizimleri + damga paleti + yazılabilir hedefler (705). */
  gozCizimOku: (gozMuayeneId: number) =>
    istek<GozCizimYaniti>(`/api/goz/muayene/${gozMuayeneId}/cizim`),

  /** Bir gözün bir şemasını kaydeder; saat ve üretilen cümle SUNUCUDA hesaplanır. */
  gozCizimKaydet: (gozMuayeneId: number, govde: {
    goz: number; semaTuru: number; svg: string; aciklama?: string;
    isaretler: GozCizimIsareti[];
  }) =>
    gonder<{ cizimId: number; isaret: number; uretilenMetin: string }>(
      `/api/goz/muayene/${gozMuayeneId}/cizim`, govde),

  /** Önceki muayenenin çizimlerinden başla; bugün çizilmiş şema EZİLMEZ. */
  gozCizimOncekiKopyala: (gozMuayeneId: number) =>
    gonder<{ id: number; oncekiId: number; kopyalanan: number; aciklama: string }>(
      `/api/goz/muayene/${gozMuayeneId}/cizim/onceki-kopyala`, {}),

  /** Dikte sözlüğü: terim · komut · sık cümle · hedef alanlar · kapalı alanlar. */
  gozDikteSozluk: () => istek<DikteSozlugu>('/api/goz/dikte/sozluk'),

  /** Terim ekle/güncelle. Kişisel terim muayene yetkisiyle, kurum terimi ayrı yetkiyle. */
  gozDikteTerim: (govde: {
    soylenen: string; yazilan: string; tur: number; eylem?: string; kisisel: boolean;
  }) =>
    gonder<{ id: number; soylenen: string; yazilan: string; kisisel: boolean }>(
      '/api/goz/dikte/terim', govde),

  /**
   * Bulgu METNİ yaz (dikte ve çizim aynı kapıdan geçer): alan beyaz listede
   * değilse sunucu reddeder, mevcut metin ezilmez sonuna eklenir.
   * `yontem`: 1 dikte · 2 çizim.
   */
  gozBulguMetni: (gozMuayeneId: number, govde: {
    hedef: string; goz: number; metin: string; yontem: number;
  }) =>
    gonder<{ id: number; hedef: string; hedefAdi: string; sonHali: string;
             aciklama: string }>(
      `/api/goz/muayene/${gozMuayeneId}/bulgu-metni`, govde),

  /** Muayeneyi tamamla — ölçümsüz muayene kapanmaz (kural sunucuda). */
  gozMuayeneTamamla: (id: number) =>
    gonder<{ id: number; tamamlandi: boolean; uyari: string }>(
      `/api/goz/muayene/${id}/tamamla`, {}),

  /** Önceki muayeneden METİNSEL bulguları getir; ölçüm kopyalanmaz. */
  gozOncekiKopyala: (id: number) =>
    gonder<{ id: number; oncekiId: number; kopyalanan: number; aciklama: string }>(
      `/api/goz/muayene/${id}/onceki-kopyala`, {}),

  /** Muayene kartı üst şeridi: kimlik + bağlam + ön tetkik + tamamlanma. */
  gozMuayeneSeridi: (gozMuayeneId: number) =>
    istek<GozMuayeneSeridiYaniti>(`/api/goz/muayene/${gozMuayeneId}/serit`),

  /** Cihaz mesajını yeniden ayrıştır (ölçüm mükerrer yazılmaz). */
  gozMesajIsle: (id: number) =>
    gonder<{ islenen: number; sahipsiz: number; hatali: number; aciklama: string }>(
      `/api/goz/cihaz-mesaj/${id}/isle`, {}),

  /** Bekleyen + sahipsiz bütün mesajları dener. */
  gozMesajKuyruk: () =>
    gonder<{ okunan: number; islenen: number; sahipsiz: number; hatali: number;
             aciklama: string }>('/api/goz/cihaz-mesaj/kuyruk', {}),

  /** Sıradakini çağır: kayıt verilmezse en uzun bekleyen çağrılır. */
  gozCagir: (istasyonId?: number | null) =>
    gonder<{ id: number; hasta: string; istasyon: string; oda: string; tekrar: boolean }>(
      '/api/goz/akis/cagir' + (istasyonId ? `?istasyonId=${istasyonId}` : ''), {}),

  /** İstasyona al: mevcut satır kapanır, yenisi açılır (geçmiş korunur). */
  gozIstasyonaAl: (id: number, govde: {
    istasyon: number; oda?: string; personelId?: number | null; not?: string;
  }) => gonder<{ id: number | null; hasta: string; istasyon: string;
                 tamamlandi: boolean; uyari: string }>(
    `/api/goz/akis/${id}/istasyon`, govde),

  /** Dilatasyon başlat — 20 dakikalık sayaç; ikinci kez başlatılamaz. */
  gozDilatasyon: (id: number, ilac?: string) =>
    gonder<{ id: number; hazirDk: number }>(`/api/goz/akis/${id}/dilatasyon`, { ilac }),

  gozOdaAta: (id: number, oda: string, personelId?: number | null) =>
    gonder<{ id: number; oda: string }>(`/api/goz/akis/${id}/oda`, { oda, personelId }),

  /** Ünite panosu sayaçları — bugün, ünitede, bekleme, dilatasyon, darboğaz. */
  gozUniteOzeti: (gun?: string) =>
    istek<GozUniteOzeti>('/api/goz/unite-ozet' + (gun ? `?gun=${gun}` : '')),

  /** Hastanın göz özeti: OD/OS son değerler + takip + ziyaret + işlem + reçete. */
  gozHastaOzeti: (hastaId: number) =>
    istek<GozHastaOzeti>(`/api/goz/hasta/${hastaId}/ozet`),
  /** Tek ölçümün zaman serisi - progresyon eğrisi. */
  gozTrend: (hastaId: number, olcum: string, goz?: number) =>
    istek<GozTrendNoktasi[]>(
      `/api/goz/hasta/${hastaId}/trend?olcum=${encodeURIComponent(olcum)}`
      + (goz ? `&goz=${goz}` : '')),
};
