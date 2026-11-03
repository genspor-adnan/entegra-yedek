import { istek } from '../cekirdek';

/**
 * GÜNDEM (kullanıcı 03.11.2026: "prompt ekranını daha efektif ... kullanıcının rolüne göre yönlendirmesi gerek.. bugünkü işlerim
 * ... vadesi gelen ödemeler, çekler, kredi ..." - mockup Ekranlar/ana_sayfa_yz_komut.html, katman 1 ve 2).
 *
 * Kartlar SUNUCUDA hesaplanır ve yalnız oturumun YETKİLİ olduğu (ve modülü açık olan) kartlar döner - istemci gizlemez.
 * ERP / HBYS ayrımı yok: hangi kartın geleceğini rol + yetki belirler.
 */
export type GundemTonu = 'kir' | 'sar' | 'yes' | 'mav';

export interface GundemSatiri { ad: string; deger: string }
export interface GundemEylemi { ad: string; yol: string }
export interface GundemKarti {
  kod: string;
  baslik: string;
  ikon: string;
  /** Kartın büyük sayısı (adet, gün, tarih) - metin; boş olabilir. */
  sayi: string;
  ton: GundemTonu;
  satirlar: GundemSatiri[];
  /** Karta tıklanınca gidilen ekran. */
  yol: string;
  eylemler: GundemEylemi[];
}

/** Kayıt önerisi (aramada kayıt seçilince) - her öneri kendi yetkisiyle gelir. */
export interface KayitOzeti { etiket: string; deger: string; ton?: GundemTonu }
export interface KayitOnerisi { kod: string; ikon: string; ad: string; neden: string; eylemler: (GundemEylemi & { birincil?: boolean })[] }
export interface KayitOnerileri { ozet: KayitOzeti[]; oneriler: KayitOnerisi[] }

/** Ad ile kayıt araması (Ctrl+K): müşteri / tedarikçi / kişi / personel / hasta - yetkili türler. */
export type KayitTuru = 'musteri' | 'tedarikci' | 'kisi' | 'personel' | 'hasta';
export interface BulunanKayit { tur: KayitTuru; id: number; ad: string; kod: string; bilgi: string; musteri: boolean; tedarikci: boolean }

export const gundemUclari = {
  gundem: () => istek<{ kartlar: GundemKarti[] }>('/api/gundem'),
  kayitOnerileri: (tur: KayitTuru, id: number) =>
    istek<KayitOnerileri>(`/api/gundem/kayit?tur=${tur}&id=${id}`),
  /** Düz VKN / TCKN: numaraya kayıtlı müşteri / tedarikçi / kurum + o numaraya kesilmiş son satış belgeleri. */
  vergiNoAra: (q: string) => istek<{
    kayitlar: { tur: 'musteri' | 'tedarikci' | 'kurum'; id: number; ad: string; kod: string; durum: number; musteri: boolean; tedarikci: boolean }[];
    belgeler: { id: number; tur: number; no: string; tarih: string; unvan: string; tutar: number }[] }>(
    `/api/hizli-bul/vergi-no?q=${encodeURIComponent(q)}`),
  kayitAra: (q: string) => istek<{ kayitlar: BulunanKayit[] }>(`/api/hizli-bul/kayit-ad?q=${encodeURIComponent(q)}`),
};
