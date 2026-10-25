import { gonder, istek } from '../cekirdek';

/** Üretim İcmali (UretimIcmalUclari, 1176). Rakamlar sunucuda hesaplanır; ekran toplamaz. */
type Secenek = { id: number; ad: string };

export type UretimDurumSuzme = 'hepsi' | 'planli' | 'uretimde' | 'kismi' | 'tamam';

export type UretimEmriSatiri = {
  id: number; no: string; tur: number; turAd: string; durum: number; durumAd: string;
  stokId: number; mamulKod: string; mamul: string; birim: string;
  plan: number; uretilen: number; fire: number;
  /** plan − üretilen − fire (alt sınır 0). */
  kalan: number;
  planBas: string | null; termin: string | null;
  /** Gecikme günü: açık emirde bugün − termin, kapanmışta bitiş − termin; yoksa null. */
  gecikme: number | null;
  /** Açık emirde termine kalan gün. */
  kalanGun: number | null;
  /** Siparişe üretimde satış siparişi no, alt emirde ana emir no. */
  kaynak: string; kaynakBelgeId: number | null; ustEmirId: number | null;
  /** Girinti: 0 ana / kök, 1+ alt emir. Sıra sunucudan (ana emrin hemen altında). */
  derinlik: number; ana: boolean;
  /** Fason giriş belgesi gelmemiş açık fason emir (canlı maliyet gösterilmez). */
  fasonda: boolean;
  /** Süzgece kendisi uydu mu (false = yalnız ana emrin altı olarak geldi). */
  eslesti: boolean;
};

export type UretimSarfSatiri = {
  satirId: number; emirId: number; emirNo: string; stokId: number; kod: string; ad: string; birim: string;
  birimIhtiyac: number; fireYuzde: number; gerekli: number; sarfEdilen: number;
  /** gerekli × üretilen / plan; "sürüyor" ya da üretimsiz satırda null. */
  beklenen: number | null; fark: number | null; farkYuzde: number | null; farkTutar: number | null;
  durum: number; durumAd: string;
  /** Tek seferde sarf edilmiş, hâlâ üretimde: oran karşılaştırması anlamsız. */
  suruyor: boolean;
  /** |fark %| > uretim.sapma_sarf_yuzde. */
  esikAsti: boolean;
};

export type UretimFireSatiri = {
  stokId: number; kod: string; ad: string; birim: string; uretilen: number; fire: number;
  /** fire / (üretilen + fire) %. */
  oran: number | null;
  /** Emir satırlarının (ağaçtan donmuş) fire %'si, gerekliyle ağırlıklı. */
  hedef: number | null;
  /** oran > hedef × uretim.fire_hedef_kat. */
  esikAsti: boolean;
  tutar: number;
  /** Kapanışı olmayan emirde plan birim maliyetle. */
  tahmini: boolean;
  neden: string; depo: string; emir: number;
};

export type UretimMaliyetSatiri = {
  emirId: number; no: string; stokId: number; mamul: string; ana: boolean; derinlik: number;
  uretilen: number;
  /** "fasonda" satırda hepsi null. */
  malzeme: number | null; iscilik: number | null; gug: number | null; fason: number | null; toplam: number | null;
  /** Yalnız kapanan emirde; açıkta null (canlı). */
  birim: number | null; planBirim: number; sapma: number | null;
  kapanis: string | null;
  durum: 'kapandi' | 'acik' | 'fasonda';
  /** Kapanış fason yazmamış, fason giriş belgesinin tutarı eklendi. */
  fasonEklendi: boolean;
  /** GÜG ayrı dağıtılmadı (iş merkezi saat ücretine dahil). */
  gugYok: boolean;
  /** |sapma| > uretim.sapma_maliyet_yuzde. */
  esikAsti: boolean;
};

export type UretimMaliyetToplami = {
  malzeme: number; iscilik: number; gug: number; fason: number; toplam: number; fire: number;
  kapanan: number; acik: number; fasonda: number;
};

export type IsMerkeziYukSatiri = {
  id: number; kod: string; ad: string;
  /** Haftalık kapasite saati (günlük × iş günü). */
  kapasite: number; fason: boolean;
  /** Saat ücreti tanımsız: işçilik (ve GÜG) 0 yazılır. */
  ucretYok: boolean;
  /** Bu ay duruş saati (uretim_zaman tür 2). */
  durus: number;
  /** HaftaSayisi + 1 hücre; sonuncusu "sonrası". */
  hucreler: { saat: number; oran: number | null; operasyon: number }[];
  toplamSaat: number;
};

export type MalzemeIhtiyacSatiri = {
  stokId: number; kod: string; ad: string; birim: string; depoId: number; depo: string;
  /** Açık emir satırlarında gerekli − sarf edilen. */
  ihtiyac: number;
  /** Bu emirlerin kendi rezervi (eldekinden düşülmez). */
  rezerve: number;
  /** kalan − SKT'si geçmiş lot − başka rezerv. */
  eldeki: number; sktGecmis: number; baskaRezerv: number;
  /** Açık alış siparişi. */
  yoldaki: number;
  eksik: number; karsilanmayan: number;
  ilkGereken: string;
  emirler: { id: number; no: string; eksik: number }[];
  /** Açık satınalma talebi no'ları (varsa talep açılmaz). */
  talep: string;
  birimMaliyet: number; eksikTutar: number;
};

export type UretimIcmali = {
  bas: string; bit: string; durum: UretimDurumSuzme; tur: number; sube: number; depo: number; isMerkezi: number; mamul: number;
  bugun: string;
  esikler: { maliyet: number; sarf: number; fireKat: number };
  ozet: {
    emir: number; siparise: number; stoga: number; fason: number; altEmir: number;
    acik: number; uretimde: number; kismi: number; planli: number; tamamlanan: number;
    plan: number; uretilen: number; gerceklesme: number | null;
    fire: number; fireOran: number | null; fireTutar: number;
    maliyetSapma: number | null; kapanan: number; doluluk: number | null;
    terminGecen: number; enEskiGecikme: number | null; eksikKalem: number; eksikTutar: number;
    fasonda: number; isMerkezi: number;
  };
  emirler: UretimEmriSatiri[];
  sinirli: boolean;
  sarf: UretimSarfSatiri[];
  fire: UretimFireSatiri[];
  fireToplam: { uretilen: number; fire: number; oran: number | null; tutar: number };
  maliyet: UretimMaliyetSatiri[];
  maliyetToplam: UretimMaliyetToplami;
  yuk: {
    haftalar: { bas: string; bit: string }[];
    merkezler: IsMerkeziYukSatiri[];
    operasyonlar: { id: number; emirId: number; emirNo: string; ad: string; isMerkeziId: number; saat: number;
      bas: string; bit: string; haftalar: number[] }[];
    kapasiteGun: number;
  };
  malzeme: MalzemeIhtiyacSatiri[];
  a4: {
    mamuller: { stokId: number; kod: string; ad: string; plan: number; uretilen: number; fireOran: number | null;
      birim: number | null; sapma: number | null }[];
    dip: UretimMaliyetToplami;
  };
  secim: { subeler: Secenek[]; depolar: Secenek[]; isMerkezleri: Secenek[]; mamuller: Secenek[] };
  yetkiler: { talep: boolean; emir: boolean };
};

export const uretimIcmalUclari = {
  uretimIcmali: (q: URLSearchParams) => istek<UretimIcmali>(`/api/uretim-icmal?${q}`),
  uretimIcmalTalepAc: (depoId: number, satirlar: { stokId: number; miktar: number; emirId?: number | null }[], aciklama?: string) =>
    gonder<{ id: number; talepNo: string; kalem: number; atlanan: number; atlananlar: number[] }>('/api/uretim-icmal/talep', { depoId, satirlar, aciklama }),
};
