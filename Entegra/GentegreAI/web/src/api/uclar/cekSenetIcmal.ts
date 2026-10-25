import { istek } from '../cekirdek';

/**
 * ÇEK / SENET İCMALİ (FinansIcmalUclari.CekSenet, `GET /api/finans-icmal/cek-senet`).
 * Durum kodları Çek / Senet Listesi ile aynı (10 Portföyde, 20 Ciro Edildi, 30 Tahsilde,
 * 40 Teminatta, 60 Karşılıksız). Rakamlar sunucuda; `deger` para birimi seçili değilse
 * bugünkü kurla TL, seçiliyse evrakın kendi tutarı.
 */
export type CekSenetHareket = {
  tarih: string; islem: number; ad: string; eskiDurum: number; yeniDurum: number;
  cari: string; hesap: string; aciklama: string; islemNo: string;
};

export type CekSenetEvrak = {
  id: number; tur: 1 | 2; yon: 1 | 2; durum: number; durumAdi: string; durumEk: string;
  seriNo: string; kesideci: string; ucuncuKisi: boolean; cari: string; cariId: number | null; ciroCari: string;
  banka: string; bankaSube: string; hesapId: number | null; hesap: string; hesapDoviz: string; hesapTahmini: boolean;
  tarih: string; vade: string; kalanGun: number;
  tutar: number; doviz: string; alisKuru: number; bugunKur: number | null; kurYok: boolean;
  alisDeger: number; deger: number; kurFarki: number;
  makbuzNo: string; girisIslemNo: string; aciklama: string;
  secilebilir: boolean;
  hareketler: CekSenetHareket[];
  /** Yalnız verilen: vade günündeki hesap bakiyesi (hesabın para biriminde). */
  vadeBakiye: number | null; yetersiz: boolean; hesapsiz: boolean;
};

type Kume = { adet: number; tutar: number };

export type CekSenetIcmali = {
  tarih: string; para: string; tur: number; vade: string; banka: string;
  ozet: {
    portfoy: { tutar: number; adet: number; ortVade: number | null };
    tahsilde: { tutar: number; adet: number; hesaplar: { ad: string; adet: number }[] };
    teminat: Kume; ciro: Kume; gun30: Kume; gecmis: Kume;
    karsiliksiz: { tutar: number; adet: number; cek: number; senet: number };
    verilen: { tutar: number; adet: number; gun60: number; gecmis: number };
    /** Portföy + tahsilde + teminat (A4 "toplam alınan"). */
    elde: Kume;
    dovizli: number; kurFarki: number; kurYok: number; ucuncuKisi: Kume;
  };
  toplam: { alinan: Kume; verilen: Kume; ikisi: Kume };
  durumlar: { kod: number; ad: string; adet: number; tutar: number }[];
  donem: {
    bas: string; bit: string;
    alinan: { ad: string; islem: number; adet: number; tutar: number }[];
    verilen: { ad: string; islem: number; adet: number; tutar: number }[];
  };
  alinan: CekSenetEvrak[];
  verilen: CekSenetEvrak[];
  takvim: {
    ad: string; bas: string | null; bit: string | null; gecmis: boolean;
    alinan: number; alinanAdet: number; verilen: number; verilenAdet: number; net: number;
  }[];
  takvimToplam: { alinan: number; alinanAdet: number; verilen: number; verilenAdet: number; net: number };
  kesideciler: {
    ad: string; adet: number; tutar: number; pay: number; ucuncuKisi: boolean; cariler: string[];
    karsiliksiz: number; karsiliksizYil: number | null;
  }[];
  bankaDagilim: { ad: string; adet: number; tutar: number; pay: number }[];
  riskToplam: number;
  hesaplar: {
    hesapId: number; ad: string; doviz: string; tahmini: boolean; bakiye: number;
    odenecek30: number; adet30: number; giris30: number; odenecekToplam: number; adet: number;
    kalan30: number; yeterli: boolean; yetersizEvrak: number;
  }[];
  hesapsizVerilen: number;
  secim: { bankalar: string[]; paralar: string[] };
};

export const cekSenetIcmalUclari = {
  /** q: tur (1 çek / 2 senet), para (boş = TL karşılığı), banka, vade (gecmis / 7 / 30 / 60 / 90 / sonra), bas, bit (dönem hareketleri). */
  cekSenetIcmali: (q: URLSearchParams) => istek<CekSenetIcmali>(`/api/finans-icmal/cek-senet?${q}`),
};
