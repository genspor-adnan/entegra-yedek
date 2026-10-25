import { gonder, istek } from '../cekirdek';

/**
 * Sipariş İcmali (SiparisIcmalUclari) - `GET /api/siparis-icmal?yon=satis|alis…`, `POST /api/siparis-icmal/kapat`.
 * Rakamlar sunucuda (sipariş dip toplamı satırlara dağıtılır); ekran hesap yapmaz. Açıklık Açık Satır
 * Listesi'nin kuralıdır; teslim = siparişten türeyen KESİN irsaliye / fatura / fiş.
 */
type Secenek = { id: number; ad: string };
export type SiparisYon = 'satis' | 'alis';
/** acikkismi varsayılan · iptal = "Kalanı kapat" ile kapatılan. */
export type SiparisDurumSuzgeci = 'acikkismi' | 'acik' | 'kismi' | 'kapali' | 'iptal' | 'tumu';
export type SiparisTerminSuzgeci = '' | 'gecen' | 'hafta' | 'ay' | 'yok';
export type SiparisSatirDurumu = 'acik' | 'kismi' | 'kapali' | 'iptal';
/** Stok karşılama: var · rezerve (kendi rezervesiyle) · yolda (açık alış siparişiyle) · eksik · hizmet. '' = alış / hesaplanmadı. */
export type StokDurumu = '' | 'var' | 'rezerve' | 'yolda' | 'eksik' | 'hizmet';
export type TerminKovasi = '' | 'gecen' | 'h1' | 'h2' | 'h3' | 'h4' | 'sonra' | 'yok';

export type SiparisSatiri = {
  satirId: number; belgeId: number; tur: number; no: string; tarih: string; tarafId: number; cari: string;
  stokId: number; kod: string; urun: string; hizmet: boolean; kategori: string;
  miktar: number; teslim: number; kalan: number; taslak: number; kapanan: number;
  tutar: number; kalanTutar: number;
  termin: string | null; terminSatirda: boolean;
  /** Bugün − termin (gün): artı = gecikme, eksi = kalan gün. Açık olmayan / terminsiz satırda null. */
  gun: number | null; kova: TerminKovasi;
  stokDurum: StokDurumu; eksik: number;
  durum: SiparisSatirDurumu; konsinye: boolean; para: string;
  /** TL karşılığı kipinde dövizli satırın kalan döviz tutarı. */
  doviz: number | null;
  temsilci: string; depo: string;
  kapanis: { neden: string; tarih: string | null; kapatan: string } | null;
  donusebilir: boolean;
};

export type SiparisCariSatiri = {
  id: number; ad: string; musteri: boolean; tedarikci: boolean; temsilci: string;
  siparis: number; acikSatir: number; siparisTutar: number; teslimTutar: number; kalanTutar: number; gecenTutar: number;
  otif: number | null; pay: number; cubuk: number; doviz: { para: string; tutar: number }[];
  konsinyeTutar: number; skor: number | null;
  acikSatirlar: SiparisSatiri[]; acikSatirSayisi: number;
};

export type PerformansDegeri = {
  kapanan: number; zamaninda: number; gec: number; eksik: number; terminsiz: number; otif: number | null;
  ortGecikme: number | null; ortTeslim: number | null;
};

export type SiparisIcmali = {
  yon: SiparisYon; bas: string; bit: string; bugun: string; durum: SiparisDurumSuzgeci; termin: SiparisTerminSuzgeci;
  sube: number; depo: number; temsilci: number; kategori: number; para: string; yerelPara: string; konsinye: boolean;
  ozet: {
    acikTutar: number; acikSiparis: number; acikSatir: number; kismiSatir: number;
    gecenSatir: number; gecenTutar: number; enEskiGecikme: number;
    otif: number | null; kapananSatir: number; terminsizKapanan: number; otifGecenAy: number | null;
    ortTeslim: number | null; donusum: number | null; karsilanamayan: number;
    gelecekTutar: number; gelecekKalem: number; iptalTutar: number; iptalSatir: number; terminsizAcik: number;
    siparisTutar: number; teslimTutar: number; siparis: number; konsinyeSatir: number; konsinyeTutar: number; taslakSatir: number;
  };
  cariler: SiparisCariSatiri[];
  cariToplam: {
    cari: number; siparis: number; acikSatir: number; siparisTutar: number; teslimTutar: number; kalanTutar: number;
    gecenTutar: number; otif: number | null;
  };
  satirSayisi: number; satirlar: SiparisSatiri[];
  takvim: { kova: TerminKovasi; ad: string; bas: string | null; bit: string | null; satir: number; miktar: number; tutar: number;
    hazir: number | null; eksik: number | null; hizmet: number; cubuk: number }[];
  performans: { id: number; ad: string; musteri: boolean; tedarikci: boolean; deger: PerformansDegeri; say: number;
    skor: number | null; skorGecikme: number | null }[];
  performansToplam: PerformansDegeri;
  /** Satış yönünde: eksik ya da yoldakiyle karşılanan stok × depo. */
  karsilama: {
    stokId: number; kod: string; ad: string; depoId: number; depo: string; acik: number; eldeki: number; rezerve: number;
    yoldaki: number; yoldakiNo: string; yoldanAlinan: number; eksik: number; ilkTermin: string | null; gecti: boolean;
    satir: number; oneri: 'talep' | 'yolda'; talepAcilir: boolean;
  }[];
  /** Alış yönünde: açık alış siparişlerinden gelecek mal (stok bazında). */
  gelecek: {
    stokId: number; kod: string; ad: string; kategori: string; kalan: number; tutar: number; ilkTermin: string | null;
    geciken: number; tedarikciler: string; siparisler: string; eldeki: number; satisBekleyen: number; bekleniyor: boolean;
  }[];
  trend: { aylar: { ay: string; siparis: number; sevk: number; aySonuAcik: number; otif: number | null; kapanan: number;
    ortTeslim: number | null; kismiGun: number | null; cubuk: number }[] };
  kirilim: {
    temsilci: { id: number; ad: string; acikTutar: number; gecenTutar: number; otif: number | null; cari: number }[];
    kategori: { ad: string; acikTutar: number; pay: number; eksikKalem: number | null }[];
    subeDepo: { ad: string; acikTutar: number; satir: number }[];
    para: {
      satirlar: { para: string; yerel: boolean; siparis: number; siparisTl: number; acikDoviz: number | null; siparisKuru: number | null;
        acikTl: number; bugunkuKur: number | null; acikBugun: number | null }[];
      toplam: { siparis: number; siparisTl: number; acikTl: number };
    };
  };
  secim: { subeler: Secenek[]; depolar: Secenek[]; temsilciler: Secenek[]; paralar: string[]; kategoriler: Secenek[] };
  yetkiler: { donustur: boolean; kapat: boolean; talep: boolean };
  izlemeNo: string;
};

export type KapatYaniti = { kapatilan: number; belgeler: { id: number; no: string; satir: number }[]; izlemeNo: string };

export const siparisIcmalUclari = {
  siparisIcmali: (q: URLSearchParams) => istek<SiparisIcmali>(`/api/siparis-icmal?${q}`),
  /**
   * Seçili açık satırların kalanını kapatır (neden zorunlu, loglu; sipariş belgesi değişmez).
   * `kalan` istemcinin gördüğü kalan: arada teslim girdiyse 409 (CAKISMA) + güncel kalanlar.
   */
  siparisKalanKapat: (satirlar: { satirId: number; kalan: number }[], neden: string) =>
    gonder<KapatYaniti>('/api/siparis-icmal/kapat', { satirlar, neden }),
};
