import { gonder, istek } from '../cekirdek';

/**
 * BANKO OTURUMU (987) — vardiya akışı sözleşmesi.
 * Alan adları sunucudakiyle birebir; çeviri katmanı yok.
 */
export type UygunBanko = {
  id: number; kod: string; ad: string; konum: string; tur: number; hesap: string;
  devir: number; acilisOnay: boolean; gunSonuOnay: boolean; kupurDokumu: boolean;
  /** Banko tanımındaki "kasada bırakılacak" hedefi - gün sonunda öneri olarak gelir. */
  birakilacak: number;
};

export type OturumOzeti = {
  id: number; bankoId: number; bankoKod: string; bankoAd: string;
  kullaniciId: number; vardiya: string;
  /** 1 açılış onayı bekliyor · 2 açık · 3 teslime gönderildi · 4 kapandı · 5 reddedildi */
  durum: number;
  devirTutar: number; acilisSayim: number; acilisFark: number; acilisNot: string;
  acilisTalepTs: string; acilisTs: string | null; acilisOnayId: number | null; acilisOnayTs: string | null;
  redNeden: string;
  nakitTahsilat: number; nakitIade: number; posTutar: number; bankaTutar: number;
  islemAdet: number; beklenenNakit: number;
  kapanisSayim: number; kapanisBeklenen: number; kapanisFark: number;
  farkNeden: number; farkAciklama: string;
  kasadaBirakilan: number; teslimEdilen: number; teslimAlanId: number | null;
  kapanisTalepTs: string | null; kapanisTs: string | null; kapanisOnayId: number | null;
  tutanakNo: string;
  acilisOnay: boolean; gunSonuOnay: boolean; kupurDokumu: boolean;
  bankoDevirHedef: number; gorevli: string;
};

export type KupurSatiri = { birim: number; adet: number };

export type OnaySatiri = {
  id: number; tur: 'acilis' | 'kapanis'; bankoKod: string; bankoAd: string;
  gorevli: string; kullaniciId: number; vardiya: string;
  beklenen: number; sayim: number; fark: number; not: string;
  talepTs: string; kapanisTalepTs: string | null; durum: number;
  nakit: number; pos: number; islemAdet: number; teslimEdilen: number;
  /** Kendi oturumu: sunucu da reddeder, düğme istemcide de kapalı gelir. */
  kendisi: boolean;
};

export type OturumYaniti = { oturum: OturumOzeti | null; mesaj?: string; tutanakNo?: string | null };
export type OturumDetay = { oturum: OturumOzeti; kupurler: { asama: number; birim: number; adet: number }[] };

export type AcIstegi = {
  bankoId: number; vardiya?: string; acilisSayim?: number; not?: string;
  kupurler?: KupurSatiri[];
};

export type GunSonuIstegi = {
  kapanisSayim: number; farkNeden?: number; farkAciklama?: string;
  kasadaBirakilan?: number; teslimAlanId?: number; kupurler?: KupurSatiri[];
};

/** Fark nedenleri - sunucudaki `fark_neden` kodları. */
export const FARK_NEDENLERI: { kod: number; ad: string }[] = [
  { kod: 1, ad: 'Para üstü hatası' },
  { kod: 2, ad: 'Eksik tahsilat' },
  { kod: 3, ad: 'Fazla tahsilat' },
  { kod: 4, ad: 'Kayıt dışı ödeme' },
  { kod: 5, ad: 'Sayım hatası' },
  { kod: 99, ad: 'Diğer' },
];

/** Sayım kupürleri: TL banknotları + bozuk para satırı (birim 1). */
export const KUPURLER: number[] = [200, 100, 50, 20, 10, 5, 1];


export const bankoOturumUclari = {
  bankoOturumUygun: () => istek<UygunBanko[]>('/api/banko-oturum/uygun-bankolar'),
  bankoOturumAktif: () => istek<OturumYaniti>('/api/banko-oturum/aktif'),
  bankoOturumGetir: (id: number) => istek<OturumDetay>(`/api/banko-oturum/${id}`),
  bankoOturumAc: (g: AcIstegi) => gonder<OturumYaniti>('/api/banko-oturum/ac', g),
  bankoOturumKuyruk: () => istek<OnaySatiri[]>('/api/banko-oturum/onay-kuyrugu'),
  bankoOturumOnayla: (id: number, not?: string) =>
    gonder<OturumYaniti>(`/api/banko-oturum/${id}/onayla`, { not: not ?? '' }),
  bankoOturumReddet: (id: number, not: string) =>
    gonder<OturumYaniti>(`/api/banko-oturum/${id}/reddet`, { not }),
  bankoOturumGunSonu: (id: number, g: GunSonuIstegi) =>
    gonder<OturumYaniti>(`/api/banko-oturum/${id}/gun-sonu`, g),
  bankoOturumYenidenAc: (id: number, not: string) =>
    gonder<OturumYaniti>(`/api/banko-oturum/${id}/yeniden-ac`, { not }),
};
