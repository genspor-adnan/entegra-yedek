import { gonder, istek } from '../cekirdek';

/**
 * TELETIP GÖNDERİMİ (1302-1304; Bakanlık Teleradyoloji, Mirth K1 üzerinden). Sunucu mesajı kurar, denetler, gönderir;
 * istemci yalnız izi gösterir, ham mesajı açar ve "yeniden gönder" der.
 * Durum: 0 kuyrukta · 1 gönderildi (AA) · 2 reddedildi (AE) · 3 gidemez (eksik) · 4 atlandı · 5 ulaşmadı (tekrar).
 * Emir: 1 NW (yeni istem) · 2 XO (güncelleme) · 3 CA (iptal) · 4 ORU (rapor, 1309).
 */
export interface TeletipSatir {
  id: number; kanal: number; emir: number; durum: number; denemeNo: number; ackKodu: string; hata: string;
  kontrolNo: string; accessionNo: string; eklemeTarihi: string; sonDeneme: string | null; sonrakiDeneme: string | null;
}
export interface TeletipIstemOzet {
  id: number; accessionNo: string; durum: number; hastaId: number; hastaAdi: string; tetkikAdi: string; modalite: string; kabul: string;
}

/** Teletıp panosu (mockup §2): günün özeti, son olaylar, Mirth kanal durumları. */
export interface TeletipPano {
  aktif: boolean; hl7Adres: string;
  ozet: { gun: string; nwToplam: number; nwGonderildi: number; xoCaToplam: number; xoCaGonderildi: number; oruToplam: number; oruGonderildi: number; reddedildi: number;
          gidemez: number; kuyrukta: number; enEskiDk: number; sorunluToplam: number };
  sonOlaylar: { id: number; istemId: number | null; accessionNo: string; emir: number; durum: number; ackKodu: string;
                hata: string; zaman: string; hastaAdi: string }[];
  mirth: { tanimli: boolean; erisilebilir: boolean; hata: string; surum: string;
           kanallar: { id: string; ad: string; durum: string; alinan: number; suzulen: number; kuyruk: number; gonderilen: number; hatali: number }[] };
}

/** Kurum Teletıp ayarları (mockup §5). Mirth bölümü yalnız görüntü. */
export interface TeletipAyar {
  aktif: boolean; kurumSkrs: string; medulaTesisKodu: string; subeNo: string; firmaKodu: string; encoding: string; hl7Adres: string;
  subeTesisleri: { subeId: number; subeAdi: string; tesisKodu: string }[];
  uyarilar: string[];
  mirth: { url: string; kullanici: string; parolaTanimli: boolean; sertifikaDogrula: boolean; harita: Record<string, string> };
}

export const teletipUclari = {
  teletipAyar: () => istek<TeletipAyar>('/api/teletip/ayar'),
  teletipAyarKaydet: (g: { aktif: boolean; kurumSkrs: string; medulaTesisKodu: string; subeNo: string; firmaKodu: string;
                           encoding: string; hl7Adres: string }) => gonder<TeletipAyar>('/api/teletip/ayar', g, 'PUT'),
  teletipPano: (gun?: string) => istek<TeletipPano>(`/api/teletip/pano${gun ? `?gun=${encodeURIComponent(gun)}` : ''}`),
  /** Teletıp HL7 hedefine (Mirth K1) TCP + Mirth REST girişi; mesaj göndermez. */
  teletipBaglantiTesti: () => gonder<{
    hl7: { adres: string; acik: boolean; hata: string; sureMs: number };
    mirth: { tanimli: boolean; erisilebilir: boolean; hata: string; surum: string; kanalSayisi: number };
  }>('/api/teletip/baglanti-testi', {}),
  /** Reddedilen / gidemez / ulaşmadı satırlarını şimdi yeniden dener. */
  teletipTopluGonder: () => gonder<{ denenen: number; gonderilen: number; sorunluKalan: number }>('/api/teletip/yeniden-gonder-toplu', {}),
  /** İstemin Teletıp mesaj izi (şerit + kart). `aktif` false ise kurumda Teletıp kapalı. */
  teletipIstem: (istemId: number) =>
    istek<{ aktif: boolean; istem: TeletipIstemOzet | null; satirlar: TeletipSatir[]; detayYetkisi: boolean }>(`/api/teletip/istem/${istemId}`),
  /** Ham HL7 mesajı ve ACK (hasta kimliği içerir - radyoloji.teletip). */
  teletipMesaj: (gonderimId: number) => istek<{ mesaj: string; yanit: string }>(`/api/teletip/gonderim/${gonderimId}/mesaj`),
  /** Reddedilen / gidemez / ulaşmadı satırını şimdi yeniden dener. */
  teletipDene: (gonderimId: number) =>
    gonder<{ gonderimId: number; durum: number; ackKodu: string; hata: string }>(`/api/teletip/gonderim/${gonderimId}/dene`, {}),
  /** Göndermeden: istemin şu anki verisiyle NW mesajı ve eksik listesi. */
  teletipOnizle: (istemId: number) => istek<{ eksikler: string[]; mesaj: string }>(`/api/teletip/istem/${istemId}/onizle`),
};

export const TELETIP_DURUM: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'kuyrukta', sinif: 'uyari' },
  1: { ad: 'gönderildi', sinif: 'olumlu' },
  2: { ad: 'reddedildi', sinif: 'hata' },
  3: { ad: 'gidemez', sinif: 'hata' },
  4: { ad: 'atlandı', sinif: 'gri' },
  5: { ad: 'ulaşmadı', sinif: 'uyari' },
};
export const TELETIP_EMIR: Record<number, string> = { 1: 'NW', 2: 'XO', 3: 'CA', 4: 'ORU' };
export const TELETIP_EMIR_ADI: Record<number, string> = { 1: 'Yeni istem', 2: 'Güncelleme', 3: 'İptal', 4: 'Rapor' };
