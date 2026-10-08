/** API sozlesmesi - dokum. Alan adlari sunucuyla birebir. */

import type { AlanTipi, Kosul, Siralama } from '../sozlesme';

// ---------------------------------------------------------------- döküm ----
/**
 * DÖKÜM TANIMI (686) - sunucu Cekirdek/Sozlesme/Dokum.cs ile birebir.
 * SQL yok: alan adlari katalogdan, sorguyu SorguUretici uretir.
 */
export interface DokumBoyut { satir: string[]; sutun?: string | null }
export interface DokumOlcu { fn: string; alan?: string | null; bolen?: string | null; baslik?: string | null }
export interface DokumParametre { ad: string; kural: string }
export interface DokumBaski {
  yon: 'dikey' | 'yatay';
  kurumBasligi: boolean; parametreKutusu: boolean; sayfaNo: boolean;
  damga: boolean; imza: boolean; dipnot: string;
  ozetGostergeler: boolean; araToplam: boolean; capraz: boolean;
  satirTavani: number; gizliKolonlar?: string[] | null;
}
export interface DokumTanimi {
  kaynak: string;
  cikti: 'liste' | 'ozet';
  filtre?: Kosul | null;
  kolonlar?: string[] | null;
  sirala?: Siralama[] | null;
  toplam?: string[] | null;
  grup?: string[] | null;
  boyut?: DokumBoyut | null;
  olcu?: DokumOlcu[] | null;
  kiyas: 'yok' | 'oncekiDonem' | 'oncekiYil';
  esik: number;
  parametreler?: Record<string, DokumParametre> | null;
  baski?: DokumBaski | null;
}
export interface DokumKaydi {
  id: number; kod: string; ad: string; aciklama: string; kaynak: string;
  tanim: DokumTanimi; surum: number; sahipId: number; sahip: string;
  gorunurluk: number; roller: number[];
  sonCalisma?: string | null; calismaSayisi: number;
  duzenlenebilir: boolean; calistirilabilir?: boolean;
  /** Standart döküm (688): salt okunur, kopyalanır; kurum profiline göre süzülmüş gelir. */
  sistem?: boolean; urunModu?: number; modul?: string;
  /** Dökümün ait olduğu MENÜ GRUBU (690); boş = gruba bağlı değil. */
  menuGrup?: string;
}
export interface OzetOlcu { ad: string; baslik: string; fn: string; bicim: string }
export interface OzetYaniti {
  boyutlar: string[]; olculer: OzetOlcu[];
  satirlar: Record<string, unknown>[];
  kiyas?: Record<string, unknown>[] | null;
  kiyasAraligi: string; sureMs: number; izlemeNo: string;
}
export interface DokumKolonMeta {
  ad: string; baslik: string; tip: AlanTipi; filtrelenebilir: boolean; siralanabilir: boolean;
  gruplanabilir: boolean; olculebilir: boolean; kodlar?: Record<string, string> | null;
}
export interface DokumKaynakMeta { ad: string; yetkiKodu: string; baslik: string; kolonlar: DokumKolonMeta[] }
export interface DokumKatalogu {
  kaynaklar: DokumKaynakMeta[]; fnler: string[]; kesmeler: string[]; kurallar: string[];
}
export interface DokumAntet {
  kurum: Record<string, unknown> | null; kullanici: number;
}

/**
 * MENÜ DÜZENİ FARKI (979). Menü ağacı KODDADIR; sunucu yalnız kurumun yaptığı
 * değişikliği saklar. Tip burada durur: uç dosyası menü kodundan tip çekerse
 * `api → sayfalar → Liste → api` döngüsü oluşuyor (donguselImport testi).
 */
export interface MenuDuzenSatiri {
  /** 1 bölge · 2 grup · 3 alt başlık · 4 ekran. */
  dugumTur: number;
  /** Değişmez kimlik: ekranda liste kaynağı, grup/bölgede çevrilmemiş ad. */
  sistemKod: string;
  ustKod?: string | null;
  sira?: number | null;
  gorunenAd?: string;
  ikon?: string;
  gizli: number;
  acilistaAcik: number;
  disBaglanti?: string;
  subeyeOzel?: number;
}
