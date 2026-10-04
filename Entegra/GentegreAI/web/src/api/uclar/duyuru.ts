import { gonder, istek } from '../cekirdek';

/**
 * DUYURU UÇLARI (957, mockup Ekranlar/Duyuru/duyuru.html).
 *
 * Okumak yetki istemez (hedefteki herkes); yayınlamak `duyuru`, herkese ve
 * SMS ile `duyuru.genel`. Metin sunucuda temizlenmiş HTML'dir.
 */

/** 1 bilgi · 2 önemli · 3 kritik */
export type DuyuruOnem = 1 | 2 | 3;

export interface DuyuruSatiri {
  id: number; baslik: string; ozet: string; onem: DuyuruOnem;
  sabit: number; okumaOnayi: number; yorumAcik: number; adina: string;
  yayinBas: string; yayinBit: string | null; guncelleme: string | null; surum: number;
  /** Görülmemiş ya da görüldükten sonra güncellenmiş. */
  yeni: boolean;
  okudu: boolean;
  eskiSurumOkundu: boolean;
  hedefOzet: string;
  ekSayisi: number;
}

/** Kime: 1 şube · 2 bölüm · 3 rol · 4 kişi */
export interface DuyuruHedef { tur: 1 | 2 | 3 | 4; id: number; ad: string }

export interface DuyuruAyrinti {
  id: number; baslik: string; metin: string; onem: DuyuruOnem; herkes: number;
  yayinBas: string | null; yayinBit: string | null; okumaOnayi: number; sabit: number;
  yorumAcik: number; eposta: number; sms: number; durum: number; surum: number;
  guncelleme: string | null; gonderim: string | null; adina: string; yayinlayan: number;
  adinaGorunen: string; hedefOzet: string; okudu: boolean;
  /** Yayın başlangıcı boşsa oluşturma anı (gösterim için). */
  gorunenBas: string;
}

export interface DuyuruYonetimSatiri {
  id: number; baslik: string; onem: DuyuruOnem; sabit: number; okumaOnayi: number;
  eposta: number; sms: number; durum: number; surum: number; guncelleme: string | null;
  gonderim: string | null; yayinBas: string; yayinBit: string | null;
  durumKod: 'taslak' | 'zamanlandi' | 'yayinda' | 'bitti';
  hedefOzet: string; kisi: number; okudu: number; gordu: number; adina: string;
}

export interface DuyuruKaydiIstegi {
  id?: number; baslik: string; metin: string; onem: DuyuruOnem; herkes: boolean;
  hedefler: { tur: number; id: number }[];
  yayinBas?: string | null; yayinBit?: string | null;
  okumaOnayi: boolean; sabit: boolean; yorumAcik: boolean; eposta: boolean; sms: boolean;
  adina?: string;
  islem: 'taslak' | 'yayinla';
}

export const duyuruUclari = {
  /** Zil › Duyurular: bana görünen, yayındaki duyurular. */
  duyuruBenim: () => istek<{ satirlar: DuyuruSatiri[] }>('/api/duyuru/benim'),
  duyuru: (id: number) => istek<{ duyuru: DuyuruAyrinti; hedefler: DuyuruHedef[] }>(`/api/duyuru/${id}`),
  duyuruGordu: (id: number) => gonder<{ id: number }>(`/api/duyuru/${id}/gordu`, {}),
  duyuruOkudum: (id: number) => gonder<{ id: number }>(`/api/duyuru/${id}/okudum`, {}),

  // ------------------------------------------------------ yönetim --
  duyuruYonetim: () => istek<{ satirlar: DuyuruYonetimSatiri[] }>('/api/duyuru/yonetim'),
  duyuruOkuma: (id: number) => istek<{
    satirlar: { id: number; ad: string; gordu: string | null; okudu: string | null; okuduSurum: number }[];
  }>(`/api/duyuru/${id}/okuma`),
  duyuruHedefAra: (q: string) =>
    istek<{ satirlar: DuyuruHedef[] }>(`/api/duyuru/hedef-ara?q=${encodeURIComponent(q)}`),
  duyuruHedefSay: (herkes: boolean, hedefler: { tur: number; id: number }[]) =>
    gonder<{ kisi: number }>('/api/duyuru/hedef-say', { herkes, hedefler }),
  duyuruKaydet: (g: DuyuruKaydiIstegi) =>
    gonder<{ id: number; gonderilen: number }>('/api/duyuru', g),
  duyuruKaldir: (id: number) => gonder<{ id: number }>(`/api/duyuru/${id}/kaldir`, {}),
  duyuruSil: (id: number) => istek<{ id: number }>(`/api/duyuru/${id}`, { method: 'DELETE' }),
  duyuruHatirlat: (id: number) =>
    gonder<{ id: number; okumayan: number; sifirlanan: number }>(`/api/duyuru/${id}/hatirlat`, {}),
};
