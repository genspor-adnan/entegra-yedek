import { gonder, istek } from '../cekirdek';

/**
 * BANKA MUTABAKAT İCMALİ (1178, BankaMutabakatUclari) - mockup Ekranlar/İcmal/banka_mutabakat_icmali.html.
 * Rakamlar sunucuda; ekran toplamaz. Sunucu null alanları göndermez - opsiyonel alanlar eksik gelebilir.
 * İşle / Bankadan Çek Banka Hareketleri'nin kendi uçlarıyla (bankaHareket.ts).
 */
type Secenek = { id: number; ad: string };

/** api · dosya · elle · ekstre · yok (bakiye girilmedi). */
export type BankaKaynagi = 'api' | 'dosya' | 'elle' | 'ekstre' | 'yok';
/** bakiye_yok · tutuyor · aciklandi · fark · onayli · bozuldu */
export type MutabakatDurumu = 'bakiye_yok' | 'tutuyor' | 'aciklandi' | 'fark' | 'onayli' | 'bozuldu';

export type MutabakatTablosu = {
  banka?: number;
  yoldaCikis: number; yoldaCikisAdet: number; yoldaCikisNot: string;
  yoldaGiris: number; yoldaGirisAdet: number; yoldaGirisNot: string;
  duzeltilmisBanka?: number;
  sistem: number;
  islenmemisGiris: number; islenmemisGirisAdet: number; islenmemisGirisNot: string;
  islenmemisCikis: number; islenmemisCikisAdet: number; islenmemisCikisNot: string;
  duzeltilmisSistem: number;
  aciklanmayan?: number;
};

export type MutabakatHesabi = {
  id: number; ad: string; tur: string; kod: string; doviz: string; iban: string;
  api: boolean; akisVar: boolean; akisBas?: string;
  kaynak: BankaKaynagi; bankaBakiye?: number; bakiyeZamani?: string; bakiyeNot?: string; bakiyeGiren?: string;
  elle?: { bakiye: number; kaynak: number; aciklama: string; giren: string; zaman?: string; surum: string };
  cekimEksik: boolean; sonCekim?: string;
  sistemBakiye: number; fark?: number;
  islenmemisAdet: number; islenmemisTutar: number; oneriHazir: number;
  yoldaAdet: number; yoldaTutar: number; yoldaGeciken: number;
  aciklanmayan?: number; valorBekleyen: number; kur?: number; yerelMi: boolean;
  durum: MutabakatDurumu;
  onay?: { durum: 'onayli' | 'bozuldu'; onaylayan: string; onayAn: string; banka: number; sistem: number; bozulmaNeden?: string };
  onaylanabilir: boolean; onayEngel?: string; hazirlayan?: string;
  tablo: MutabakatTablosu;
};

export type IslenmemisHareket = {
  id: number; hesapId: number; hesapAd: string; tarih: string; valor?: string; aciklama: string; karsiAd: string; karsiIban: string;
  tutar: number;
  /** 0 bekliyor · 1 öneri hazır · 2 işlendi (kasa işlemi günden sonra) · 3 yoksayıldı · 4 seçim bekliyor */
  durum: number;
  oneriTur: string; oneriHedef: string; guven: number; neden: string;
  valorBekleyen: boolean; sonraIslendi: boolean;
};

export type YoldaKayit = {
  kasaIslemId?: number; islemNo: string; tarih: string; hesapId: number; hesapAd: string; turAdi: string; karsi: string;
  aciklama: string; tutar: number;
  /** iş günü */
  gun: number; cek: boolean; vade?: string; gecikti: boolean; durumMetni: string;
};

export type MutabakatGecmisi = {
  gun: string; aySonu: boolean; onayli: number; bozuldu: number; toplamHesap: number; banka: number; sistem: number;
  aciklanmayan: number; onaylayan: string; onayAn: string;
  satirlar: { hesapId: number; hesapAd: string; banka: number; sistem: number; aciklanmayan: number; durum: 'onayli' | 'bozuldu';
              bozulmaNeden?: string; onaylayan: string; onayAn: string }[];
};

export type BankaMutabakatIcmali = {
  gun: string; bugun: string; dun: string; aySonu: string; yerel: string; kart: boolean; hesap: number; sube: number;
  ayar: { tolerans: number; dortGoz: boolean; yoldaEsik: number };
  yetkiler: { onay: boolean; bakiyeGir: boolean; esles: boolean; isle: boolean; cek: boolean; hareketGor: boolean };
  secim: { hesaplar: { id: number; ad: string; tur: string; api: boolean }[]; subeler: Secenek[] };
  ozet: {
    hesap: number; bankaBakiye: number; sistemBakiye: number; fark: number; farkHesap: number;
    islenmemisAdet: number; islenmemisTutar: number; oneriHazir: number;
    yoldaAdet: number; yoldaTutar: number; yoldaGeciken: number;
    aciklanan: number; aciklanmayan: number; aciklananYuzde?: number; valorBekleyen: number;
    api: number; elle: number; bakiyesiz: number; onayli: number; bozuldu: number; onaylanabilir: number;
    sonCekim?: string; kurYok: string[];
    sonOnay?: { gun: string; onaylayan: string; onayli: number; toplamHesap: number };
  };
  hesaplar: MutabakatHesabi[];
  islenmemis: IslenmemisHareket[];
  yolda: YoldaKayit[];
  gecmis: MutabakatGecmisi[];
};

export type GunlukBakiye = {
  hesap: { id: number; ad: string; doviz: string; kaynak: number };
  gun: string;
  satirlar: { gun: string; banka?: number; kaynak: BankaKaynagi; eksik: boolean; sistem: number; fark?: number;
              onay?: { durum: 'onayli' | 'bozuldu'; onaylayan: string; onayAn: string; bozulmaNeden?: string } }[];
};

export type EslesmeAdaylari = {
  hareket: { id: number; hesapId: number; hesapAd: string; tarih: string; tutar: number; aciklama: string; karsiAd: string; durum: number };
  tolerans: number;
  adaylar: { kasaIslemId: number; islemNo: string; tarih: string; turAdi: string; karsi: string; aciklama: string; tutar: number; fark: number }[];
};

export type GunBakiyeKaydi = {
  id: number; hesapId: number; gun: string; bakiye: number; kaynak: number; aciklama: string; giren: string; zaman?: string; surum: string;
};

export const bankaMutabakatUclari = {
  bankaMutabakatIcmali: (q: URLSearchParams) => istek<BankaMutabakatIcmali>(`/api/banka-mutabakat?${q}`),
  bankaMutabakatGunluk: (hesapId: number, gun: string, n = 10) =>
    istek<GunlukBakiye>(`/api/banka-mutabakat/gunluk?hesapId=${hesapId}&gun=${gun}&n=${n}`),
  bankaMutabakatEslesAday: (hareketId: number) =>
    istek<EslesmeAdaylari>(`/api/banka-mutabakat/esles-aday?hareketId=${hareketId}`),
  bankaMutabakatEsles: (hareketId: number, kasaIslemId: number) =>
    gonder<{ tamam: boolean; kasaIslemId: number; islemNo: string; fark: number }>('/api/banka-mutabakat/esles', { hareketId, kasaIslemId }),
  bankaMutabakatBakiye: (g: { hesapId: number; gun: string; bakiye: number; kaynak: number; aciklama: string; surum?: string }) =>
    gonder<{ kayit?: GunBakiyeKaydi }>('/api/banka-mutabakat/bakiye', g),
  bankaMutabakatOnay: (gun: string, hesapIdler: number[]) =>
    gonder<{ gun: string; onaylanan: number[]; hatalar: { hesapId: number; ad: string; neden: string }[] }>(
      '/api/banka-mutabakat/onay', { gun, hesapIdler }),
};
