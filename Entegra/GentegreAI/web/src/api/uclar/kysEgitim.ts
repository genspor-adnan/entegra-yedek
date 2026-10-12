import { gonder, istek } from '../cekirdek';

/**
 * KURUMSAL KALİTE — EĞİTİM KAYDI (db/1056, api/KysEgitimUclari).
 * Eğitim = personel_egitim satırlarının grubu; id grubun en küçük satırı.
 * Kaydet grubu bütün olarak yazar ve YENİ id döner (ilk satır silinmiş olabilir).
 */
export interface KysEgitimKatilimci { id: number; tarafId: number; ad: string; birim: string }
export interface KysEgitim {
  id: number; ad: string; tur: number; egitmen: string; tarih: string; gecerlilik: string;
  katilimcilar: KysEgitimKatilimci[];
}
export interface KysEgitimIstegi {
  ad: string; tur: number; egitmen: string; tarih: string; gecerlilik: string; katilimcilar: number[];
}

export const kysEgitimUclari = {
  kysEgitim: (id: number) => istek<KysEgitim>(`/api/kys-egitim/${id}`),
  kysEgitimKaydet: (id: number, g: KysEgitimIstegi) => gonder<{ id: number }>(`/api/kys-egitim/${id}`, g, 'PUT'),
  kysEgitimSil: (id: number) => istek<{ silinen: number }>(`/api/kys-egitim/${id}`, { method: 'DELETE' }),
  kysEgitimPersonel: (q: string) =>
    istek<{ satirlar: { id: number; ad: string; birim: string }[] }>(`/api/kys-egitim/personel?q=${encodeURIComponent(q)}`),
};
