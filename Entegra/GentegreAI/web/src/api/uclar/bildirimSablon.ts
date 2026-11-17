import { gonder, istek } from '../cekirdek';

/** Bildirim şablonu kartı özeti (1354): değişkenler, gönderen başlığı, bu ayki gönderim. */
export interface BildirimSablonOzeti {
  kod: string; kanal: number; degiskenler: Record<string, string>; sistem: boolean;
  gonderen: string; hesap: string; buAy: number; hatali: number;
}

export const bildirimSablonUclari = {
  bildirimSablonOzet: (id: number) => istek<BildirimSablonOzeti>(`/api/bildirim-sablon/${id}/ozet`),
  /** DENEME GÖNDER: gerçek gönderim (kontör düşer); başvuruya / kayda bir şey yazılmaz. */
  bildirimSablonDeneme: (id: number, alici: string, degerler: Record<string, string>) =>
    gonder<{ bildirimId: number | null }>(`/api/bildirim-sablon/${id}/deneme`, { alici, degerler }),
};
