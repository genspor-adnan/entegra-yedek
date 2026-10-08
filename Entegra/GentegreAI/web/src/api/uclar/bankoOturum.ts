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

/**
 * Vardiya seçeneği (994): kod sabit, saatler kurum ayarından
 * (`banko.vardiya<kod>`). Mesai her kurumda aynı değil.
 */
export type VardiyaSecenek = {
  kod: number; ad: string; bas: string; bit: string;
  /** Hazır metin: "18:00-08:00". Biçim istemcide yeniden kurulmasın. */
  aralik: string;
};

/** `uygun-bankolar` yanıtı: bankolar + vardiya seçenekleri. */
export type UygunYanit = { bankolar: UygunBanko[]; vardiyalar: VardiyaSecenek[] };

export type OturumOzeti = {
  id: number; bankoId: number; bankoKod: string; bankoAd: string;
  kullaniciId: number; vardiya: string;
  vardiyaKod: number; vardiyaBas: string; vardiyaBit: string;
  /** 1 açılış onayı bekliyor · 2 açık · 3 teslime gönderildi · 4 kapandı · 5 reddedildi */
  durum: number;
  devirTutar: number; acilisSayim: number; acilisFark: number; acilisNot: string;
  acilisTalepTs: string; acilisTs: string | null; acilisOnayId: number | null; acilisOnayTs: string | null;
  redNeden: string;
  nakitTahsilat: number; nakitIade: number; posTutar: number; bankaTutar: number;
  islemAdet: number; beklenenNakit: number;
  kapanisSayim: number; kapanisBeklenen: number; kapanisFark: number;
  farkNeden: number; farkAciklama: string; farkIslemId: number | null;
  cekTutar: number;
  kasadaBirakilan: number; teslimEdilen: number; teslimAlanId: number | null;
  kapanisTalepTs: string | null; kapanisTs: string | null; kapanisOnayId: number | null;
  tutanakNo: string;
  acilisOnay: boolean; gunSonuOnay: boolean; kupurDokumu: boolean;
  bankoDevirHedef: number; gorevli: string;
};

export type KupurSatiri = { birim: number; adet: number };

/**
 * Ödeme türü dökümü (989) — mockup tablosu: Tür / Adet / Tahsilat / İade /
 * Net / Kasada durur? / Teslim-eşleşme.
 *
 * `kasaDurumu`: 1 kasada sayılır (nakit) · 2 kasaya girmez (POS, havale) ·
 * 3 fiziken var ama sayıma girmez (çek/senet, portföye alınır) · 4 nakit
 * akışı yok (kupon/indirim).
 */
export type TurOzeti = {
  tur: number; turAdi: string; turGrup: string; hesapTuru: string;
  kasaDurumu: number; adet: number; tahsilat: number; iade: number; net: number;
};

export type OnaySatiri = {
  id: number; tur: 'acilis' | 'kapanis'; bankoKod: string; bankoAd: string;
  gorevli: string; kullaniciId: number; vardiya: string;
  beklenen: number; sayim: number; fark: number; not: string;
  talepTs: string; kapanisTalepTs: string | null; durum: number;
  nakit: number; pos: number; islemAdet: number; teslimEdilen: number;
  /** Kendi oturumu: sunucu da reddeder, düğme istemcide de kapalı gelir. */
  kendisi: boolean;
};

/**
 * Onay kuyruğu yanıtı. `kendiOnay`: kullanıcı KENDİ oturumunu onaylayabilir mi
 * - yönetici (ayar yetkisi) ya da `banko.kendi_onay` açıkken true.
 */
/**
 * Tahsilat ekranının POS seçeneği (997): açık oturumun bankosundaki çalışan
 * terminal. `hesapAdi` terminalin tahsilat hesabı - seçim iki soruyu birden
 * yanıtlıyor.
 */
export type PosSecenek = {
  id: number; hesapAdi: string; hesapId: number; terminalNo: string;
  varsayilan: boolean; oturumId: number; bankoId: number; bankoAd: string;
};

export type OnayKuyrugu = { satirlar: OnaySatiri[]; kendiOnay: boolean };

export type OturumYaniti = { oturum: OturumOzeti | null; mesaj?: string; tutanakNo?: string | null };
/**
 * POS gün sonu eşleşmesi (990). `eslesmeDurum`: 1 eşleşti · 2 fark var ·
 * 3 cihaza ulaşılamadı. `cihazToplam` null ise henüz girilmemiş.
 */
export type PosEslesme = {
  bankoPosId: number; hesapAdi: string; terminalNo: string; posDurum: number;
  sistemToplam: number; cihazToplam: number | null; fark: number | null;
  eslesmeDurum: number | null; eslesmeNot: string;
};

/**
 * Çek teslim listesi (991). Çek kasada para değil: fiziken çekmecede durur,
 * nakit sayımına girmez ve gün sonunda elden teslim edilir.
 * `durum` 10 = portföyde.
 */
export type OturumCek = {
  cekId: number; tur: number; seriNo: string; bankaAdi: string; kesideci: string;
  vade: string | null; kalanGun: number | null; tutar: number; durum: number;
  tarafUnvan: string;
};

export type OturumDetay = {
  oturum: OturumOzeti;
  kupurler: { asama: number; birim: number; adet: number }[];
  turler: TurOzeti[];
  pos: PosEslesme[];
  /** Terminale bağlanmamış POS tahsilatı (tahsilat ekranı POS'u yazmıyorsa). */
  posAtanmamis: { toplam: number; adet: number } | null;
  cekler: OturumCek[];
};

export type AcIstegi = {
  bankoId: number; vardiyaKod?: number; vardiyaAralik?: string;
  acilisSayim?: number; not?: string; kupurler?: KupurSatiri[];
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
  bankoOturumUygun: () => istek<UygunYanit>('/api/banko-oturum/uygun-bankolar'),
  bankoOturumAktif: () => istek<OturumYaniti>('/api/banko-oturum/aktif'),
  bankoOturumGetir: (id: number) => istek<OturumDetay>(`/api/banko-oturum/${id}`),
  bankoOturumAc: (g: AcIstegi) => gonder<OturumYaniti>('/api/banko-oturum/ac', g),
  bankoOturumKuyruk: () => istek<OnayKuyrugu>('/api/banko-oturum/onay-kuyrugu'),
  bankoOturumOnayla: (id: number, not?: string) =>
    gonder<OturumYaniti>(`/api/banko-oturum/${id}/onayla`, { not: not ?? '' }),
  bankoOturumReddet: (id: number, not: string) =>
    gonder<OturumYaniti>(`/api/banko-oturum/${id}/reddet`, { not }),
  bankoOturumGunSonu: (id: number, g: GunSonuIstegi) =>
    gonder<OturumYaniti>(`/api/banko-oturum/${id}/gun-sonu`, g),
  bankoOturumPosEslestir: (id: number, satirlar: {
    bankoPosId: number; cihazToplam?: number; ulasilamadiMi?: boolean; aciklama?: string;
  }[]) => gonder<{ pos: PosEslesme[] }>(`/api/banko-oturum/${id}/pos-eslestir`, { satirlar }),
  bankoOturumPosSecenekleri: () => istek<PosSecenek[]>('/api/banko-oturum/pos-secenekleri'),
  bankoOturumSil: (id: number) =>
    istek<void>(`/api/banko-oturum/${id}`, { method: 'DELETE' }),
  bankoOturumYenidenAc: (id: number, not: string) =>
    gonder<OturumYaniti>(`/api/banko-oturum/${id}/yeniden-ac`, { not }),
};
