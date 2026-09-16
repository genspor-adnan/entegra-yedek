import { gonder, istek } from '../cekirdek';

/**
 * Ameliyathane iş akışı uçları (api/AmeliyathaneUclari, db 715/719).
 *
 * ŞUBE GÖNDERİLMEZ: sunucu oturumun aktif şubesini kullanır.
 *
 * ZORLAMA BAYRAKLARI (`eksigeRagmen` · `cakismayaRagmen` · `zorla`) İSTEMCİDEN
 * KENDİLİĞİNDEN GİTMEZ. Sunucu önce reddeder, ekran kullanıcıya NEYİN eksik
 * olduğunu söyler, kullanıcı ısrar ederse bayrak ikinci istekte gider ve
 * gerekçe işlem günlüğüne yazılır. Baştan gönderseydik kural hiç işlemezdi.
 */
export interface AmeliyatPlanIstegi {
  salonId: number;
  planBaslangic: string;
  planSureDk?: number;
  cerrahId?: number | null;
  anesteziId?: number | null;
  anesteziTipi?: number | null;
  planDisi?: number;
  eksigeRagmen?: boolean;
  cakismayaRagmen?: boolean;
  gerekce?: string;
}

/** salona-alma · anestezi · kesi · kapanis · bitis · cikis */
export type AmeliyatAdimi =
  'salona-alma' | 'anestezi' | 'kesi' | 'kapanis' | 'bitis' | 'cikis';

export interface AmeliyatKontrolSatiri {
  id: number;
  asama: number;
  sira: number;
  maddeMetin: string;
  isaretli: number;
  zorunlu: number;
  notMetni: string;
  isaretZamani: string | null;
  isaretleyen: string;
}

/** Çizelge satırı: salon. */
export interface CizelgeSalonu {
  id: number; kod: string; ad: string; ozellik: string;
  acilAyrilmis: number; departmanAd: string;
}

/**
 * Çizelge bloğu. `bas`/`bit` GERÇEK aralıktır: başlamış vaka salona alma →
 * çıkış (bitmediyse şimdi), başlamamış vaka planı. Ekran bunları yeniden
 * hesaplamaz - plan ile gerçeğin hangisinin çizileceği sunucunun kararı.
 */
export interface CizelgeBloku {
  id: number; ameliyatNo: string; salonId: number | null;
  durum: number; planDisi: number;
  planBaslangic: string | null; planSureDk: number;
  salonaAlma: string | null; kesiZamani: string | null;
  bitisZamani: string | null; salondanCikis: string | null;
  hastaAd: string; cerrahAd: string; islemAd: string | null;
  iptalNeden: string; gecikmeNeden: string;
  bas: string | null; bit: string | null;
  gecikmeDk: number | null; timeoutEksik: number;
}

export interface CizelgeYaniti {
  gun: string;
  saatBas: string;
  saatSon: string;
  salonlar: CizelgeSalonu[];
  ameliyatlar: CizelgeBloku[];
  ozet: {
    planlanan: number; tamamlanan: number; suren: number; gecikmeli: number;
    iptal: number; planDisi: number; bekleyenTalep: number; kullanimYuzde: number;
  };
}

/** Fatura/stok durumu satırı - işlem ya da sarf. */
export interface FaturaKalemi {
  id: number; ad: string; fiyat: number;
  belgeSatirId: number | null;
  /** Yalnız sarfta: stok çıkış fişi ve depo. */
  cikisBelgeId?: number | null; depoId?: number | null;
  stokId?: number | null; miktar?: number; faturaya?: number;
  implant?: number; utsDurum?: number; lot?: string; seriNo?: string;
  hizmetId?: number | null; sutKodu?: string; taraf?: number;
}

export interface FaturaDurumu {
  ameliyat: Record<string, unknown>;
  islemler: FaturaKalemi[];
  sarflar: FaturaKalemi[];
  ozet: {
    faturasizIslem: number; faturasizSarf: number;
    dusulmemisSarf: number; stoksuzSarf: number;
    /** Düşüldü ama ÜTS'ye geçmemiş (ya da reddedilmiş) implant sayısı. */
    utsBekleyen: number;
  };
}

export const ameliyathaneUclari = {
  /** Ne faturalanacak / ne faturalandı / ne stoktan düştü - tek istekte. */
  ameliyatFatura: (id: number) =>
    istek<FaturaDurumu>(`/api/ameliyathane/ameliyat/${id}/fatura`),

  /**
   * İşlem ve malzemeyi hasta başvurusuna (tür 19) aktarır. TEKRAR ÇALIŞTIRMAK
   * GÜVENLİ: yalnız belge satırı olmayan kalemler eklenir.
   */
  ameliyatFaturala: (id: number, g: { odeyenKurumId?: number | null; malzemeDahil?: boolean } = {}) =>
    gonder<{ belgeId: number; yeniBasvuru: boolean; islemSatiri: number;
             malzemeSatiri: number; uyarilar: string[] }>(
      `/api/ameliyathane/ameliyat/${id}/faturala`, g),

  /**
   * Sarfı stok çıkış fişiyle (tür 4) düşer. Faturaya yansıyan malzeme DE
   * düşer - iki işlem farklı defterlere yazıyor, aynı olayı iki kez saymıyor.
   */
  ameliyatStokDus: (id: number, g: {
    depoId?: number | null; satirIdler?: number[];
    /** İmplant ÜTS KULLANIM bildirimi de denensin mi (varsayılan sunucuda evet). */
    utsBildir?: boolean;
  } = {}) =>
    gonder<{ fisId: number; depoId: number; dusulen: number; izlemsiz: number;
             uyarilar: string[]; utsBekleyen: number;
             kritik: { ad: string; kalan: number; minStok: number }[];
             /** Satır satır ÜTS sonucu - biri hata verse de düşüm geçerlidir. */
             uts: { sarfId: number; ad: string; lot: string | null;
                    seriNo: string | null; basarili: boolean; mesaj: string }[];
             /** ÜTS hiç denenemediyse sebebi (hesap/token tanımlı değil). */
             utsMesaj: string }>(
      `/api/ameliyathane/ameliyat/${id}/stok-dus`, g),

  /**
   * Bildirilememiş implantların ÜTS KULLANIM bildirimini TEKRAR dener.
   * Düşüm bir daha çalışmaz (malzeme zaten düştü), bildirimin kendi kapısı.
   */
  ameliyatUtsBildir: (id: number) =>
    gonder<{ uts: { sarfId: number; ad: string; lot: string | null;
                    seriNo: string | null; basarili: boolean; mesaj: string }[];
             utsMesaj: string }>(
      `/api/ameliyathane/ameliyat/${id}/uts-bildir`, {}),

  /** Günlük masa çizelgesi (salon × saat). Şube oturumdan gelir. */
  ameliyatCizelge: (gun: string, salonId?: number | null) =>
    istek<CizelgeYaniti>(`/api/ameliyathane/cizelge?gun=${gun}`
      + (salonId ? `&salonId=${salonId}` : '')),

  /** Bekleyen talepten ameliyat doğurur; talep "planlandı" olur. */
  ameliyatPlanla: (talepId: number, g: AmeliyatPlanIstegi) =>
    gonder<{ ameliyatId: number; ameliyatNo: string; eksikler: string[]; cakisan: number }>(
      `/api/ameliyathane/talep/${talepId}/planla`, g),

  /** Tek uç, altı zaman damgası - sıra ve time-out kuralı sunucuda. */
  ameliyatAdim: (id: number, adim: AmeliyatAdimi,
                 g: { zaman?: string; duzelt?: boolean; zorla?: boolean; gerekce?: string } = {}) =>
    gonder<{ adim: string; zaman: string; durum: number; uyarilar: string[] }>(
      `/api/ameliyathane/ameliyat/${id}/adim`, { adim, ...g }),

  ameliyatIptal: (id: number, neden: string, talebiGeriAl = true) =>
    gonder<{ durum: number; talepGeriAlindi: boolean }>(
      `/api/ameliyathane/ameliyat/${id}/iptal`, { neden, talebiGeriAl }),

  ameliyatNotImzala: (id: number) =>
    gonder<{ imzalandi: boolean }>(`/api/ameliyathane/ameliyat/${id}/not-imzala`, {}),

  /** Kart başlığındaki şerit: damgalar, kontrol ilerlemesi, sayım, ÜTS. */
  ameliyatAkis: (id: number) =>
    istek<Record<string, unknown>>(`/api/ameliyathane/ameliyat/${id}/akis`),

  /** Liste ilk okumada yoksa doğar (aktif maddeler kopyalanır). */
  ameliyatKontrolListesi: (id: number) =>
    istek<{ maddeler: AmeliyatKontrolSatiri[] }>(
      `/api/ameliyathane/ameliyat/${id}/kontrol`),

  /** TOPLU yazılır: yarım işaretlenmiş time-out bırakmamak için. */
  ameliyatKontrolYaz: (id: number, yanitlar: {
    id?: number; asama?: number; sira?: number; isaretli: number; notMetni?: string;
  }[]) =>
    gonder<{ kaydedildi: number }>(
      `/api/ameliyathane/ameliyat/${id}/kontrol`, { yanitlar }),
};
