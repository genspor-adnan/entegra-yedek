/** API sozlesmesi - belgeDonusum. Alan adlari sunucuyla birebir. */

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
