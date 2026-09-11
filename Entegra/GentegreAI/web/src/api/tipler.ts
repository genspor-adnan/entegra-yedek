/**
 * Sunucu sozlesmesinde (sozlesme.ts) yeri olmayan, yalniz istemci
 * sarmalayicilarinin dondurdugu zarflar.
 */
/** Personel kartinda sube yetkisi satiri (sube kisiti KISIDE). */
export interface KullaniciSubeSatiri {
  subeId: number; subeAdi: string;
  yetkili: boolean; varsayilan: boolean; yazma: boolean;
}

/** Personel/kisi kartinda kullanici rolu bolumu. */
export interface KartRolBilgisi {
  kullaniciVar: boolean; rolId: number; rolAdi: string;
  roller: { id: number; ad: string }[];
}

/** Rol > Kullanicilar sekmesi satiri. */
export interface RolKullanicisi {
  id: number; kod: string; unvan: string; eposta: string;
  departman: string; gorev: string; telefon: string; sube: string;
  aktif: boolean; sonGiris?: string | null; rolAdi: string;
}

/** ÜTS cevap zarflari (223). */
export interface UtsMesaji { tip?: string; met?: string; kod?: string }
export interface UtsSorguYaniti { basarili: boolean; sonuc?: unknown; mesajlar: UtsMesaji[] }
export interface UtsBildirimYaniti {
  bildirimId: number; basarili: boolean; utsBildirimId?: string;
  mesajlar: UtsMesaji[]; mesaj: string;
}
export interface UtsBelgeBildirimSatiri {
  stok: string; seriNo: string; lotNo: string; adet: number;
  islem: string; basarili: boolean; mesaj: string;
}
export interface UtsBelgeBildirimYaniti {
  belgeNo: string; toplam: number; basarili: number; hatali: number;
  sonuclar: UtsBelgeBildirimSatiri[]; mesaj: string;
}
/** Verme hazırla: hazırlanamayan satır (gridde gösterilir, CSV'ye gider). */
export interface UtsHazirlaAtlanan {
  belgeNo: string; tarih: string; cari: string; stok: string;
  urunNo: string; seriNo: string; lotNo: string; adet: number; sebep: string;
}
export interface UtsHazirlaYaniti {
  olusan: number; atlanan: UtsHazirlaAtlanan[]; atlananSayisi: number; mesaj: string;
}

