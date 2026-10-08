/** API sozlesmesi - kasa. Alan adlari sunucuyla birebir. */

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
