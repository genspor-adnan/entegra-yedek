import { istek } from '../cekirdek';

/**
 * KDV İcmali (KdvIcmalUclari) - `/api/kdv-icmal`. Beyanname değildir: beyandan önce ön kontrol.
 * Rakamlar sunucuda (belgenin saklı matrah / KDV toplamından, oran kırılımına dağıtılmış);
 * ekran hesap yapmaz. Mükellef = şube VKN'si (aynı VKN'li şubeler tek icmal).
 */
type Secenek = { id: number; ad: string };

export type KdvOranSatiri = {
  oran: number; istisna: boolean; belge: number; matrah: number; kdv: number; tevkif: number;
  /** Hesaplanan / indirilecek içindeki payı; %0'da null. */
  pay: number | null; satirsiz: number;
};
export type KdvOranTablosu = {
  satirlar: KdvOranSatiri[];
  toplam: { belge: number; matrah: number; kdv: number; tevkif: number };
};

export type KdvMukellef = { anahtar: string; vkn: string; unvan: string; subeler: Secenek[] };

export type KdvDevredenKaydi = {
  id: number; vkn: string; donem: string; tutar: number; aciklama: string; degistirmeTarihi: string | null; surum: string;
};

export type KdvUyariSatiri = {
  tur: 'gib' | 'kdvsiz' | 'oran' | 'tarih' | 'iade' | 'babs' | 'subesiz' | 'aktarim' | 'taslak';
  seviye: 'kir' | 'sari' | 'mavi';
  belgeId: number | null; no: string; tarih: string | null; tarafId: number; taraf: string;
  aciklama: string; oneri: string; tutar: number | null;
};

export type KdvHesap = {
  hesaplanan: number; satisTevkif: number; satisIade: number; indirilecek: number; alisIade: number;
  kdv2: number; kdv2Indirim: number; devreden: number;
  /** Devreden düşülmeden önceki sonuç (eksi = indirim fazlası). */
  sonuc: number; odenecek: number; sonrakiDevreden: number;
  /** Kapanmış aya düşen, bu aya indirilecek alış KDV'si - bilgi, tahmine katılmaz. */
  kapanmisIndirilecek: number;
};

export type KdvIcmali = {
  donem: string; donemAd: string; bas: string; bit: string; donemKapali: boolean; acikDonemBasi: string;
  vkn: string; sube: number; ebelge: 'hepsi' | 'efatura' | 'earsiv' | 'kagit'; tur: 'tumu' | 'fatura' | 'fis'; taslak: boolean;
  /** Şube / e-Belge türü / belge türü süzgeci açık: tahmin mükellefin bütün belgeleri değildir. */
  suzgecli: boolean;
  /** Kullanıcının cari kayıt kapsamı sınırlı: yalnız erişebildiği carilerin belgeleri. */
  kapsamli: boolean;
  yerelPara: string;
  mukellef: KdvMukellef;
  ozet: {
    hesaplanan: number; hesaplananMatrah: number; indirilecek: number; indirilecekMatrah: number;
    tevkifat: number; tevkifatBelge: number; satisTevkif: number;
    odenecek: number; sonrakiDevreden: number; devreden: number; devredenKaynak: 'muhasebe' | 'elle' | 'yok';
    istisnaMatrah: number; istisnaKodlar: number[];
    iadeKdv: number; alisIadeKdv: number; iadeBelge: number; satisIadeBelge: number;
    belge: number; satisBelge: number; alisBelge: number;
    uyari: number; uyariKir: number; bilgi: number; uyariSayilari: Record<string, number>; kapanmisIndirilecek: number;
  };
  hesap: KdvHesap;
  oran: { satis: KdvOranTablosu; alis: KdvOranTablosu };
  devreden: {
    kaynak: 'muhasebe' | 'elle' | 'yok'; tutar: number; muhasebeKullaniliyor: boolean; bakiye190: number | null;
    elle: KdvDevredenKaydi | null; duzenlenebilir: boolean;
  };
  taslakSayisi: number;
  /** Yalnız "taslak=1" ile: taslakların ayrı sonucu - ödenecek KDV'ye eklenmez. */
  taslakBlok: {
    belge: number; satisBelge: number; alisBelge: number;
    hesaplanan: number; satisTevkif: number; satisIade: number; indirilecek: number; alisIade: number; kdv2: number;
    /** Taslaklar kesinleşirse sonuca etkisi (hesaplanan − iade − indirilecek ...). */
    etki: number;
    satis: KdvOranTablosu; alis: KdvOranTablosu;
  } | null;
  tevkifat: {
    satirlar: {
      belgeId: number; no: string; tarih: string; tarafId: number; taraf: string; yon: 'satis' | 'alis';
      kod: string; kodAdi: string; /** Yüzde (70 = 7/10). */ oran: number;
      matrah: number; kdv: number; tevkif: number; odenen: number;
    }[];
    toplam: { belge: number; matrah: number; kdv: number; tevkif: number; odenen: number };
  };
  istisna: {
    satirlar: { kod: number; ad: string; belge: number; matrah: number; doviz: { para: string; tutar: number }[] }[];
    toplam: { belge: number; matrah: number };
    kodsuzSatir: number; kodsuzMatrah: number;
  };
  iade: {
    satirlar: {
      belgeId: number; no: string; tarih: string; tarafId: number; taraf: string; yon: 'satis' | 'alis';
      iadeEdilenId: number | null; iadeEdilenNo: string; matrah: number; kdv: number; bagsiz: boolean;
    }[];
    toplam: { belge: number; satisKdv: number; alisKdv: number; bagsiz: number };
  };
  babs: {
    sinir: number;
    satirlar: { form: 'Ba' | 'Bs'; tarafId: number; taraf: string; vkn: string; belge: number; tutar: number; durum: 'tamam' | 'eksik' | 'hatali' }[];
    bs: number; ba: number; eksik: number;
  };
  uyarilar: KdvUyariSatiri[]; uyariToplam: number;
  muhasebe: {
    kullaniliyor: boolean;
    satirlar: { hesap: string; ad: string; icmal: number; muhasebe: number; diger: number; fark: number; durum: 'tutuyor' | 'fark' }[];
    fislenmemisSayi: number;
    fislenmemis: { belgeId: number; no: string; tarih: string; tarafId: number; taraf: string; yon: string; kdv: number }[];
  };
  /** Müşavir dökümü (en çok 5.000 belge; toplam belgeToplam). */
  belgeler: {
    id: number; no: string; tarih: string; tur: number; tipi: number; yon: 'satis' | 'satis-iade' | 'alis' | 'alis-iade';
    tarafId: number; taraf: string; vkn: string; eTur: 'efatura' | 'earsiv' | 'kagit';
    matrah: number; kdv: number; tevkif: number; oranlar: string; para: string; fisli: boolean;
  }[];
  belgeToplam: number;
  secim: { mukellefler: KdvMukellef[]; donemler: { donem: string; ad: string; kapali: boolean }[] };
  yetkiler: { devredenDuzenle: boolean };
  izlemeNo: string;
};

export type KdvDevredenYaniti = { vkn: string; donem: string; kayit: KdvDevredenKaydi | null; kapanmisDonem?: boolean; izlemeNo: string };

export const kdvIcmalUclari = {
  kdvIcmali: (q: URLSearchParams) => istek<KdvIcmali>(`/api/kdv-icmal?${q}`),
  kdvDevreden: (vkn: string, donem: string) =>
    istek<KdvDevredenYaniti>(`/api/kdv-icmal/devreden?${new URLSearchParams({ vkn, donem })}`),
  /** Elle devreden (muhasebe kullanılmıyorsa). surum: okunan kaydın sürümü (409 = başkası değiştirdi). */
  kdvDevredenYaz: (g: { vkn: string; donem: string; tutar: number; aciklama: string; surum?: string }) =>
    istek<KdvDevredenYaniti>('/api/kdv-icmal/devreden', { method: 'PUT', body: JSON.stringify(g) }),
};
