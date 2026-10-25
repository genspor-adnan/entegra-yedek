import { istek } from '../cekirdek';

/**
 * Finans icmalleri (FinansIcmalUclari) - Tahsilat / Ödeme ve Nakit Akış (Vade).
 * Rakamlar sunucuda hesaplanır; ekran toplamaz. Çek / Senet İcmali ayrı modülde (cekSenetIcmal.ts).
 */
type Secenek = { id: number; ad: string };

// ============================================================ TAHSİLAT / ÖDEME ===

export type TahsilatAraci = {
  /** havale · pos · cek · senet · nakit · kupon · ciro · kart · diger */
  anahtar: string; ad: string; islem: number; tutar: number; pay: number;
  /** Aracın içindeki iade toplamı (eksi). */
  iade: number;
};

export type TahsilatCariIslemi = {
  tarih: string; yon: 'tahsilat' | 'odeme'; arac: string; aracAnahtar: string; tutar: number; belgeNo: string; hesap: string;
  /** Çek / senet: banka · vade. */
  cek: string;
  /** Dağıtıldığı (ya da FIFO ile kapattığı) faturalar. */
  faturalar: string; dagitimli: boolean;
};

export type TahsilatCari = {
  /** 0 = carisiz (gelir / gider kalemi). */
  id: number; ad: string; kod: string; tur: 'musteri' | 'tedarikci' | 'carisiz';
  tahsilat: number; odeme: number; islem: number;
  /** Müşteride dönem satış, tedarikçide dönem alış faturası. */
  donemFatura: number; tahsilOrani: number | null; ortGun: number | null;
  dagitilmamis: number; bakiye: number | null;
  islemler: TahsilatCariIslemi[];
};

export type TahsilatPosOzeti = {
  brut: number; komisyonCekim: number; aktarilan: number; hesabaGecen: number; komisyonAktarim: number;
  /** Kayıtlı komisyon (çekimde + aktarımda). */
  komisyon: number;
  /** Kayıt yoksa kart oranıyla tahmin. */
  tahminiKomisyon: number; oran: number; valor: number;
  /** Henüz bankaya aktarılmamış POS bakiyesi. */
  bekleyen: number;
};

export type TahsilatHesapSatiri = {
  id: number; ad: string; tur: 'K' | 'B' | 'P'; doviz: string; banka: string; iban: string;
  hucreler: number[]; giris: number; cikis: number; net: number;
  transferHucreler: number[]; transferGiris: number; transferCikis: number;
  normalVar: boolean; pos: TahsilatPosOzeti | null;
};

export type TahsilatOdemeIcmali = {
  bas: string; bit: string; yon: 'tahsilat' | 'odeme' | 'ikisi'; sube: number; kisi: number; para: string; virman: boolean;
  ozet: {
    tahsilat: number; tahsilatIslem: number; tahsilatCari: number;
    odeme: number; odemeIslem: number; odemeCari: number; net: number;
    satis: number; alis: number; tahsilatSatis: number | null;
    ortTahsilGun: number | null; oncekiOrtTahsilGun: number | null; ortOdemeGun: number | null;
    dagitilmamis: number; dagitilmamisAdet: number; aktarimTahsilat: number;
    cekSenet: number; cekSenetOran: number; cari: number; islem: number; gun: number;
  };
  araclar: {
    tahsilat: TahsilatAraci[]; odeme: TahsilatAraci[];
    /** Bilgi: dönemde faturalara dağıtılan avans (toplama girmez). */
    avansMahsup: { islem: number; tutar: number } | null;
    /** Yalnız "Virmanları göster" işaretliyse. */
    virmanlar: { tur: number; ad: string; islem: number; tutar: number }[] | null;
  };
  cariler: TahsilatCari[];
  gunHesap: { donemler: { bas: string; bit: string; ad: string }[]; hesaplar: TahsilatHesapSatiri[] };
  kisiler: {
    id: number; ad: string; islem: number; tahsilat: number; nakit: number; pos: number; havale: number; cekSenet: number;
    gunSonuFarki: number | null;
  }[];
  dikkat: {
    dagitilmamis: { tarih: string; id: number; cari: string; arac: string; tutar: number; avans: boolean; acikFatura: number; acikTutar: number }[];
    dagitilmamisAdet: number; dagitilmamisTutar: number;
    iadeIptal: { tarih: string; cari: string; arac: string; yon: 'tahsilat' | 'odeme'; tutar: number; neden: string }[];
    odemesiz: { id: number; ad: string; bakiye: number; sonTahsilat: string | null; gun: number | null }[];
    gecmisOdeme: { id: number; ad: string; belgeNo: string; belgeId: number; vade: string; gun: number; tutar: number; doviz: string; dovizTutar: number }[];
  };
  a4: { arac: string; tahsilat: number; odeme: number; net: number }[];
  secim: { subeler: Secenek[]; kisiler: Secenek[]; paralar: string[] };
};

// ============================================================= NAKİT AKIŞ ===

export type NakitKolon = 'fatura' | 'cek' | 'plan' | 'tedarikci' | 'verilenCek' | 'planli';

export type NakitKalemi = {
  vade: string; kolon: NakitKolon; kaynak: string; tarafId: number; taraf: string; belge: string; belgeId: number; cekId: number;
  doviz: string; tutar: number; tl: number; gecmis: boolean;
  /** cikis: ertelenemez · pazarlik */
  esneklik: '' | 'ertelenemez' | 'pazarlik';
  /** giris: yüksek · orta · düşük · bilinmiyor · 3. kişi çek */
  guven: string;
  /** Carinin son 6 aydaki ortalama tahsilat gecikmesi (gün). */
  gecikme: number | null; hesap: string; ucuncu: boolean;
  /** Seçili senaryoda beklenen tarih / TL; akış dışıysa null. */
  beklenen: string | null; beklenenTl: number | null; akista: boolean;
};

export type NakitHaftasi = {
  bas: string; bit: string; acilis: number;
  fatura: number; cek: number; plan: number; giris: number;
  tedarikci: number; verilenCek: number; planli: number; cikis: number;
  kapanis: number; gecmisDahil: boolean;
};

export type NakitAkisIcmali = {
  bugun: string; son: string; ufuk: number; periyot: 'hafta' | 'ay'; hesaplar: number[]; sube: number;
  ilkHafta: boolean; planli: boolean;
  senaryo: { gecikme: boolean; oran: number; gecmisOran: number | null; karsiliksiz: number; ertele: number };
  ozet: {
    acilis: number; kasa: number; banka: number; pos: number; hesapAdet: number;
    giris: number; girisFatura: number; girisCek: number; girisPlan: number;
    cikis: number; cikisTedarikci: number; cikisCek: number; cikisPlanli: number;
    sonBakiye: number; fark: number; enDusuk: number; enDusukBas: string; enDusukSira: number;
    vadesiGecmisAlacak: number; gecmisOran: number | null; oran: number; ortGecikme: number | null;
    kmh: number; kmhHesaplar: { ad: string; limit: number; bosta: number }[];
    girisKalem: number; cikisKalem: number;
  };
  haftalar: NakitHaftasi[];
  senaryolar: { ad: string; secili: boolean; enDusuk: number; hafta: string; sonBakiye: number }[];
  doviz: { doviz: string; girecek: number; cikacak: number; acik: number; kur: number | null; kurYok: boolean; tl: number | null }[];
  /** durum: akista · tanimsiz · kapali */
  tanimlar: { gider: string; kaynak: string; durum: 'akista' | 'tanimsiz' | 'kapali' }[];
  girisler: NakitKalemi[]; cikislar: NakitKalemi[];
  secim: { subeler: Secenek[]; hesaplar: { id: number; ad: string; tur: string; doviz: string; bakiye: number; tl: number }[] };
};

export const finansIcmalUclari = {
  tahsilatOdemeIcmali: (q: URLSearchParams) => istek<TahsilatOdemeIcmali>(`/api/finans-icmal/tahsilat-odeme?${q}`),
  nakitAkisIcmali: (q: URLSearchParams) => istek<NakitAkisIcmali>(`/api/finans-icmal/nakit-akis?${q}`),
};
