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
  /**
   * Oda / cihaz doluluğu: pano HASTAYI değil KAYNAĞI sayar.
   * 976: kaynak artık tanımlı (`goz_kaynak`) ve BOŞ kaynak da satır üretir -
   * "HFA sırası dört kişiyken muayene odası boş duruyor" cümlesi ancak öyle
   * kurulabiliyor.
   */
  odalar: {
    kaynakId: number | null; kod: string; oda: string;
    tur: number; turAdi: string; sahip: string;
    sayi: number; hasta: string; istasyon: number;
    sureDk: number; enUzunDk: number; bos: boolean; tanimli: boolean;
  }[];
  /** Hekim (ve tekniker) yükü — ön tetkik ünitenin girişi. */
  hekimler: {
    personelId: number; personel: string; tamamlanan: number; bekleyen: number;
    ortDk: number; enUzunDk: number;
    /** Randevuya göre gecikme; randevusuz hastada ÖLÇÜLEMEZ (null). */
    gecikmeDk: number | null; randevulu: number;
  }[];
  /** Sol panel: kimde kaç açık satır var (liste süzgecinden geçmeden). */
  panelHekimler: { id: number; ad: string; sayi: number }[];
  /** Sol panel: hangi kaynakta kaç kişi. */
  panelKaynaklar: { kaynakId: number | null; ad: string; sayi: number }[];
  /** Vardiya aralığı çalışma planından (718) - panoya elle yazılmıyor. */
  vardiyalar: { id: number; vardiya: string }[];
  /** Gün özeti çıktısının kurum başlığı (v_sube_antet, 772). */
  antet: {
    unvan: string; adres: string; ilce: string; il: string;
    telefon: string; subeAd: string; logoDokumanId: number | null;
  } | null;
}

/**
 * BEKLEME SALONU EKRANI (976) — ad MASKELİ gelir, maskeleme sunucuda.
 * Ekran yalnız okur: çağırma / taşıma panoda kalıyor.
 */
export interface GozBeklemeEkrani {
  zaman: string;
  cagrilanlar: {
    id: number; ad: string; kaynak: string; istasyon: number;
    hekim: string; cagriDk: number; dilatasyon: number;
  }[];
  bekleyenler: {
    id: number; ad: string; istasyon: number; kaynak: string;
    beklemeDk: number; siraNo: number; hekim: string;
    dilatasyon: number; cagrildi: boolean;
  }[];
  dilatasyonda: number;
  dilatasyonHazir: number;
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
  /** 970 hasta şeridi: alerji, göz ilaçları, hedef GİB, önceki muayene. */
  ek?: {
    alerji: string; tedavi: string; hedefOd: number | null; hedefOs: number | null; takip: string;
    oncekiTarih: string | null; oncekiGibOd: number | null; oncekiGibOs: number | null;
  } | null;
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

/** GÖZ MUAYENE LİSTESİ + KARTI (970). */
export interface GozMuayeneGostergeYaniti {
  gosterge: { bugun: number; dilatasyon: number; gibYuksek: number; gormeDusus: number; kontrolGecikmis: number; taslak: number };
  turler: { tur: number; sayi: number }[];
  hekimler: { id: number | null; ad: string; sayi: number }[];
}
export interface GozGecmisSatiri {
  id: number; tarih: string; tur: number; bu: boolean;
  bcvaOd: number | null; bcvaOs: number | null; gibOd: number | null; gibOs: number | null;
  hedefOd: number | null; hedefOs: number | null; cdOd: number | null; cdOs: number | null;
  rnflOd: number | null; rnflOs: number | null; md: number | null; plan: string;
}
export interface GozMuayeneOnizleme {
  muayene: {
    id: number; hastaId: number; hasta: string; yas: number | null; cinsiyet: number; takip: string;
    alerji: string; tedavi: string; bcvaOd: number | null; bcvaOs: number | null; gormeDusus: number;
    gibOd: number | null; gibOs: number | null; hedefOd: number | null; hedefOs: number | null; gibYuksek: number;
    cctOd: number | null; cctOs: number | null; cdOd: number | null; cdOs: number | null;
    tani: string; plan: string; kontrolTarihi: string | null; tamamlandi: boolean; hekimId: number | null;
  };
  gecmis: GozGecmisSatiri[];
}
export interface GozMuayeneIsleri {
  tanilar: { id: number; kod: string; ad: string; taraf: number; kesinlik: number; tur: number }[];
  isler: { tur: string; ad: string; zaman: string | null; ayrinti: string; id: number }[];
}
export interface GozGoruntuSatiri { zaman: string | null; tur: string; goz: string; kaynak: string; durum: string; buMuayene: boolean; nesne: string; id: number }

/** GÖZ SÜRECİ v2 (goz_sureci_v2.html). */
export interface GozBasvuru { id: number; hasta: string; bolum: string; zaman: string; hekim: string }
export interface GozOyku { muayeneId: number; sikayet: string; hikaye: string; ozgecmis: string; soygecmis: string; kapali: boolean }

/** GÖZ KARTI v4. */
export interface GozKontrol {
  /** Bu muayenede istenmiş göz görüntüleme sayısı (974). */
  goruntuIstem?: number;
  bolumler: { baslik: string; durum: string; ipucu: string }[];
  kontrol: { kod: string; ad: string; durum: 'ok' | 'yok' | 'uyari'; zorunlu: boolean; mesaj: string; bolum: string }[];
}
export interface GozHastaOyku {
  veri: Record<string, unknown>; zaman: string | null; kim: string;
  kronik: { kod: string; ad: string; baslangic: string | null }[];
  ilaclar: string[]; riskler: { ilac: string; risk: string }[];
}

/** GÖZLÜK REÇETESİ v2 (972-973). */
export interface GozlukRefraksiyon { tur: number; goz: number; sph: number | null; cyl: number | null; aks: number | null;
  add: number | null; va: number | null; pdUzak: number | null; pdYakin: number | null }
export interface GozlukOnceki { id: number; tarih: string; tur: number; durum: number; receteNo: string; sgk: number;
  odSph: number | null; odCyl: number | null; odAks: number | null; osSph: number | null; osCyl: number | null; osAks: number | null;
  add: number | null; odPd: number | null; osPd: number | null; pdYakin: number | null; camMalzeme: number | null; kaplamalar: string; tasarim: string }
export interface GozlukKaynak {
  hasta: { ad: string; hastaNo: string; yas: number | null; cinsiyet: number } | null;
  muayene: { id: number; protokol: string; tarih: string; hekimId: number | null; hekim: string; dilate: number; gozMuayeneId: number | null } | null;
  refraksiyon: GozlukRefraksiyon[]; oncekiler: GozlukOnceki[];
  sonSgk: string | null; sgkHakVar: boolean; sgkHakTarihi: string | null;
}
export interface GozlukGostergeYaniti {
  gosterge: { bugun: number; taslak: number; optikte: number; bitecek: number; sgkErken: number; sgkHakDogdu: number };
  turler: { tur: number; sayi: number }[]; durumlar: { durum: number; sayi: number }[]; optikler: { id: number | null; ad: string; sayi: number }[];
  /** Reçeteyi yazan hekimler (mockup ② şeridi "Hekim: Tümü"). */
  hekimler: { id: number; ad: string; sayi: number }[];
}
export type GozlukOnizleme = Record<string, unknown>;

// 978 GÖZ CİHAZLARI v2
export interface GozCihazGostergeYaniti {
  gosterge: {
    tanimli: number; aktif: number; bugunCekim: number; bekleyen: number;
    eslenmeyen: number; hatali: number; kalibrasyonGecikmis: number;
  };
  turler: { tur: number; sayi: number }[];
  protokoller: { protokol: number; sayi: number }[];
  durumlar: { durum: number; sayi: number }[];
}
export interface GozCihazOnizleme {
  cihaz: Record<string, unknown>;
  mesajlar: { id: number; zaman: string; hastaEslesme: string; durum: number; hata: string; dosyaYolu: string; ham: string }[];
  tetkikler: { tetkik: number; sayi: number }[];
  /** Demirbaştan SALT OKUMA (kullanıcı kararı 05.10.2026); bağ yoksa boş. */
  kalibrasyonlar: { id: number; tarih: string; kayitNo: string; tur: number; sonuc: number;
                    gecerlilik: string | null; referansCihaz: string; referansSertifika: string;
                    belirsizlik: number | null; belirsizlikBirim: string; yapan: string; firma: string }[];
  isEmirleri: { id: number; isEmriNo: string; tur: number; oncelik: number; durum: number;
                bildirimZamani: string; tamamlanma: string | null; planlanan: string | null;
                arizaMetni: string; yapilanIs: string; hastaEtkilendi: number }[];
}

// 974 GÖZ GÖRÜNTÜLEME v2
export interface GozGoruntulemeGostergeYaniti {
  gosterge: { bugun: number; sirada: number; odemeBekliyor: number; degerlendirmeBekleyen: number; kaliteDusuk: number; esikDisi: number; yzDikkat: number };
  tetkikler: { tetkik: number; sayi: number }[]; cihazlar: { id: number; ad: string; sayi: number }[];
  degerlendirenler: { id: number; ad: string; sayi: number }[];
}
export interface GozGoruntulemeOlcum { goz: number; olcum: string; deger: number | null; birim: string; normalPct: number | null; bayrak: number; onceki: number | null }
export interface GozGoruntulemeOnizleme {
  kayit: Record<string, unknown>;
  olcumler: GozGoruntulemeOlcum[];
  egilim: { zaman: string; id: number; bu: boolean; od: number | null; os: number | null }[];
}

export const gozUclari = {
  gozlukKaynak: (q: { receteId?: number; hastaId?: number; muayeneId?: number }) => {
    const p = new URLSearchParams();
    if (q.receteId) p.set('receteId', String(q.receteId));
    if (q.hastaId) p.set('hastaId', String(q.hastaId));
    if (q.muayeneId) p.set('muayeneId', String(q.muayeneId));
    return istek<GozlukKaynak>(`/api/goz/gozluk/kaynak?${p.toString()}`);
  },
  gozlukImzala: (id: number) => gonder<{ id: number; durum: number; receteNo: string }>(`/api/goz/gozluk/${id}/imzala`, {}),
  gozlukDurum: (id: number, durum: 3 | 4) => gonder<{ id: number; durum: number }>(`/api/goz/gozluk/${id}/durum/${durum}`, {}),
  gozlukGosterge: () => istek<GozlukGostergeYaniti>('/api/goz/gozluk-gosterge'),
  // 978 cihazlar: gösterge · önizleme · bağlantı sınaması
  gozCihazGosterge: () => istek<GozCihazGostergeYaniti>('/api/goz/cihaz-gosterge'),
  gozCihazOnizleme: (id: number) => istek<GozCihazOnizleme>(`/api/goz/cihaz/${id}/onizleme`),
  /** Örnek mesajla eşleme denemesi - HİÇBİR ŞEY YAZMAZ (kart "Ölçüm eşlemesi"). */
  gozCihazEslemeSina: (id: number, ham: string, esleme?: string) =>
    gonder<{ satirlar: { goz: number; gozAd: string; olcum: string; deger: number }[]; bulunan: number }>(
      `/api/goz/cihaz/${id}/esleme-sina`, { ham, esleme }),
  gozCihazSina: (id: number) =>
    istek<{ basarili: boolean; sonuc: string }>(`/api/goz/cihaz/${id}/sina`, { method: 'POST' }),
  gozlukOnizleme: (id: number) => istek<{ recete: GozlukOnizleme }>(`/api/goz/gozluk/${id}/onizleme`),
  /** Reçetenin hazır olduğunu hastaya bildirir (SMS / e-posta kuyruğu). */
  gozlukBildir: (id: number) =>
    istek<{ kanal: string; alici: string; kuyrukId: number | null }>(
      `/api/goz/gozluk/${id}/bildir`, { method: 'POST' }),
  gozTetkikHizmet: () => istek<{ satirlar: { tetkik: number; hizmetId: number; kod: string; hizmetAd: string }[] }>('/api/goz/tetkik-hizmet'),
  gozGoruntulemeGosterge: () => istek<GozGoruntulemeGostergeYaniti>('/api/goz/goruntuleme-gosterge'),
  gozGoruntulemeOnizleme: (id: number) => istek<GozGoruntulemeOnizleme>(`/api/goz/goruntuleme/${id}/onizleme`),
  gozGoruntulemeCekildi: (id: number) => gonder<{ id: number; durum: number }>(`/api/goz/goruntuleme/${id}/cekildi`, {}),
  gozGoruntulemeDegerlendir: (id: number) => gonder<{ id: number; durum: number }>(`/api/goz/goruntuleme/${id}/degerlendir`, {}),
  gozGoruntulemeIptal: (id: number) => gonder<{ id: number; mesaj: string }>(`/api/goz/goruntuleme/${id}/iptal`, {}),
  gozGoruntulemeYeniden: (id: number) => gonder<{ id: number; eskiId: number }>(`/api/goz/goruntuleme/${id}/yeniden`, {}),
  gozKontrol: (id: number) => istek<GozKontrol>(`/api/goz/muayene/${id}/kontrol`),
  gozOzetMetin: (id: number) => istek<{ bolumler: { baslik: string; metin: string }[] }>(`/api/goz/muayene/${id}/ozet-metin`),
  gozHastaOyku: (hastaId: number) => istek<GozHastaOyku>(`/api/goz/hasta/${hastaId}/oyku`),
  gozHastaOykuYaz: (hastaId: number, veri: Record<string, unknown>) => gonder<{ hastaId: number }>(`/api/goz/hasta/${hastaId}/oyku`, veri),
  gozAkisBasvurular: () => istek<{ satirlar: GozBasvuru[] }>('/api/goz/akis/basvurular'),
  gozAkisEkle: (belgeId: number) => gonder<{ id: number }>('/api/goz/akis/ekle', { belgeId }),
  /** Panodan: kayıt yoksa genel muayene + göz uzantısı açılır. */
  gozAkisMuayene: (istasyonId: number) =>
    gonder<{ gozMuayeneId: number; muayeneId: number; yeni: boolean }>(`/api/goz/akis/${istasyonId}/muayene`, {}),
  gozMuayeneUzantiBul: (muayeneId: number) => istek<{ gozMuayeneId: number | null }>(`/api/goz/muayene-uzanti/${muayeneId}`),
  /** Başvuru göz ünitesindeyse uzantıyı açar, değilse yalnız bulur. */
  gozMuayeneUzantiAc: (muayeneId: number) =>
    gonder<{ gozMuayeneId: number | null; yeni?: boolean }>(`/api/goz/muayene-uzanti/${muayeneId}`, {}),
  gozOyku: (id: number) => istek<GozOyku>(`/api/goz/muayene/${id}/oyku`),
  gozOykuYaz: (id: number, g: { sikayet: string; hikaye: string }) => gonder<{ id: number }>(`/api/goz/muayene/${id}/oyku`, g),
  gozSonrakiIstasyon: (id: number) => gonder<{ istasyon: number | null; ad?: string }>(`/api/goz/muayene/${id}/sonraki-istasyon`, {}),
  gozMuayeneGosterge: () => istek<GozMuayeneGostergeYaniti>('/api/goz/muayene-gosterge'),
  gozMuayeneOnizleme: (id: number) => istek<GozMuayeneOnizleme>(`/api/goz/muayene/${id}/onizleme`),
  gozMuayeneKarsilastirma: (id: number) => istek<{ satirlar: GozGecmisSatiri[] }>(`/api/goz/muayene/${id}/karsilastirma`),
  gozMuayeneIsleri: (id: number) => istek<GozMuayeneIsleri>(`/api/goz/muayene/${id}/isler`),
  gozMuayeneGoruntuler: (id: number) => istek<{ satirlar: GozGoruntuSatiri[] }>(`/api/goz/muayene/${id}/goruntuler`),
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
  /** Eksik (tanı / iki göz görme / GİB) varsa sunucu GOZ_EKSIK der; gerekçeyle geçilir (970). */
  gozMuayeneTamamla: (id: number, gerekce?: string) =>
    gonder<{ id: number; tamamlandi: boolean; uyari: string }>(
      `/api/goz/muayene/${id}/tamamla`, gerekce ? { gerekce } : {}),

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
                 tamamlandi: boolean; uyari: string;
                 /** Süreç v2: Ön tetkik / Hekim muayenesine geçişte açılan (ya da var olan) kayıt. */
                 gozMuayeneId?: number | null; muayeneYeni?: boolean }>(
    `/api/goz/akis/${id}/istasyon`, govde),

  /** Dilatasyon başlat — 20 dakikalık sayaç; ikinci kez başlatılamaz. */
  gozDilatasyon: (id: number, ilac?: string) =>
    gonder<{ id: number; hazirDk: number }>(`/api/goz/akis/${id}/dilatasyon`, { ilac }),

  /**
   * Oda / cihaz atama. 976: `kaynakId` verilirse oda metnini SUNUCU tanımdan
   * yazar - ekranın gönderdiği serbest metin "OCT-1 / OCT1" ikiliğini geri
   * getirirdi.
   */
  gozOdaAta: (id: number, oda: string, personelId?: number | null, kaynakId?: number | null) =>
    gonder<{ id: number; oda: string }>(`/api/goz/akis/${id}/oda`, { oda, personelId, kaynakId }),

  /** Bekleme salonu ekranı: çağrılanlar + kuyruk (ad maskeli). */
  gozBeklemeEkrani: () => istek<GozBeklemeEkrani>('/api/goz/bekleme-ekrani'),

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
