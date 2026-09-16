import { gonder, istek } from '../cekirdek';

/**
 * FTR MODÜLÜ (719) — liste/kart dışı uçlar: program kartı (tek soruda),
 * seans açma/bitirme/gelmedi, seansları planlama, ünite panosu, uygulama arama.
 */
export interface FtrProgramOzeti {
  id: number; program_no: string; hasta_id: number; hasta_adi: string; degerlendirme_id?: number | null;
  hekim_id?: number | null; hekim_adi: string; fizyoterapist_id?: number | null; fizyoterapist_adi: string;
  unite_id?: number | null; unite_adi: string; kabin_id?: number | null; kabin_adi: string;
  bolge: number; bolge_adi: string; icd_kod: string; tani_ad: string;
  seans_sayisi: number; siklik_haftalik: number; seans_sure_dk: number; saat: string;
  baslangic: string; bitis_tahmini?: string | null; bitis?: string | null;
  rapor_no: string; rapor_seans_hakki: number; kalan_hak: number; odeyen_kurum_id?: number | null; odeyen_adi: string; belge_id?: number | null;
  ara_degerlendirme_seans: number; yapilan_seans: number; devamsiz: number; durum: number; durum_adi: string;
  yanit?: number | null; sonuc_notu: string; aciklama: string;
  sonraki_seans?: string | null; vas_ilk?: number | null; vas_son?: number | null; uygulama_sayisi: number; ekleme_tarihi: string;
}
export interface FtrUygulama { id: number; sira: number; hizmetId?: number | null; ad: string; sutKodu: string; bolgeMetin: string; sureDk: number; parametre: string; cihazAd: string; seansBas: number; seansBit?: number | null; notMetin: string }
export interface FtrEgzersiz { id: number; sira: number; ad: string; setTekrar: string; yer: number; asamaBas: number; asamaBit?: number | null; notMetin?: string }
export interface FtrSeansOzeti { id: number; sira: number; tarih: string; saat: string; fizyoterapist: string; kabin: string; vasOnce?: number | null; vasSonra?: number | null; durum: number; durumAdi: string; uygulamaSayisi: number; yapilanUygulama: number; sureDk: number; kabinId?: number | null; fizyoterapistId?: number | null }
export interface FtrOlcekSatiri { id: number; tarih: string; olcek: number; olcekAdi: string; asama: number; asamaAdi: string; skor: number; hedef?: number | null; notMetin: string }
export interface FtrProgramKarti {
  program: FtrProgramOzeti; uygulamalar: FtrUygulama[]; egzersizler: FtrEgzersiz[]; seanslar: FtrSeansOzeti[]; olcekler: FtrOlcekSatiri[];
  kabinler: { id: number; ad: string }[];
  gunluk: { tarih: string; kullanici: string; islemTipi: number; tabloId: number; bilgi: string }[];
}
export interface FtrSeansSatiri {
  id: number; program_id: number; program_no: string; hasta_id: number; hasta_adi: string; bolge: number; bolge_adi: string;
  sira: number; seans_sayisi: number; tarih: string; saat: string; baslangic?: string | null; bitis?: string | null;
  fizyoterapist_id?: number | null; fizyoterapist_adi: string; kabin_id?: number | null; kabin_adi: string;
  vas_once?: number | null; vas_sonra?: number | null; ev_uyum: string; durum: number; durum_adi: string;
  uygulama_sayisi: number; yapilan_uygulama: number; sure_dk: number; uygulama_notu: string; komplikasyon: string; imza: number;
}
export interface FtrSeansUygulama { id: number; ad: string; sureDk: number; parametre: string; cihazAd: string; yapildi: boolean; baslangic?: string | null; bitis?: string | null; neden: string; programUygulamaId?: number | null }
export interface FtrSeansKarti {
  seans: FtrSeansSatiri; program: FtrProgramOzeti | null; uygulamalar: FtrSeansUygulama[]; egzersizler: FtrEgzersiz[];
  onceki?: { sira: number; tarih: string; vasOnce?: number | null; vasSonra?: number | null; not: string } | null;
  kabinler: { id: number; ad: string }[]; simdi: string;
}
export interface FtrPano {
  gun: string; uniteId: number; uniteler: { id: number; kod: string; ad: string }[];
  kabinler: { id: number; kod: string; ad: string; tur: number; kapasite: number; cihazlar: string; aktif: boolean }[];
  seanslar: { id: number; programId: number; programNo: string; hastaId: number; hasta: string; bolge: string; sira: number; seansSayisi: number; saat: string;
              baslangic?: string | null; bitis?: string | null; fizyoterapistId?: number | null; fizyoterapist: string; kabinId?: number | null; kabin: string;
              durum: number; durumAdi: string; uygulamaSayisi: number; yapilanUygulama: number; vasOnce?: number | null; sonrakiUygulama: string; yapilanlar: string }[];
  fizyoterapistler: { id: number; ad: string; bugun: number; yapilan: number; suren: number }[]; simdi: string;
}

export const ftrUclari = {
  ftrProgramKart: (id: number) => istek<FtrProgramKarti>(`/api/ftr/program/${id}`),
  ftrUygulamaEkle: (programId: number, g: { hizmetId?: number | null; ad?: string; sureDk?: number; parametre?: string; cihazAd?: string; bolgeMetin?: string; seansBas?: number; seansBit?: number | null }) =>
    gonder<{ id: number }>(`/api/ftr/program/${programId}/uygulama`, g),
  ftrUygulamaSil: (id: number) => istek<void>(`/api/ftr/program/uygulama/${id}`, { method: 'DELETE' }),
  ftrPlanla: (programId: number, g: { saat?: string; kabinId?: number | null; fizyoterapistId?: number | null; mevcutlariSil?: boolean } = {}) =>
    gonder<{ eklenen: number }>(`/api/ftr/program/${programId}/planla`, g),
  ftrSonlandir: (programId: number, g: { yanit?: number | null; not?: string } = {}) =>
    gonder<{ durum: number; iptalSeans: number }>(`/api/ftr/program/${programId}/sonlandir`, g),
  ftrSeansAc: (programId: number, g: { kabinId?: number | null; fizyoterapistId?: number | null } = {}) =>
    gonder<{ id: number; mevcut: boolean }>(`/api/ftr/program/${programId}/seans-ac`, g),
  ftrSeansKart: (id: number) => istek<FtrSeansKarti>(`/api/ftr/seans/${id}`),
  ftrSeansGuncelle: (id: number, g: Record<string, unknown>) => gonder<{ id: number }>(`/api/ftr/seans/${id}`, g, 'PATCH'),
  ftrSeansUygulamaGuncelle: (id: number, g: { yapildi?: boolean; sureDk?: number; neden?: string; parametre?: string; cihazAd?: string }) =>
    gonder<{ id: number }>(`/api/ftr/seans/uygulama/${id}`, g, 'PATCH'),
  ftrSeansBitir: (id: number) => gonder<{ yapilan: number; seansSayisi: number; programDurum: number; uyari: string | null }>(`/api/ftr/seans/${id}/bitir`, {}),
  ftrSeansGelmedi: (id: number) => gonder<{ devamsiz: number; uyari: string | null }>(`/api/ftr/seans/${id}/gelmedi`, {}),
  ftrSeansYarim: (id: number, neden: string) => gonder<{ id: number }>(`/api/ftr/seans/${id}/yarim`, { neden }),
  ftrPano: (uniteId?: number | null, gun?: string) => istek<FtrPano>(`/api/ftr/pano?${uniteId ? `uniteId=${uniteId}&` : ''}${gun ? `gun=${gun}` : ''}`),
  ftrUygulamaAra: (q: string) => istek<{ satirlar: { id: number; sutKodu: string; kod: string; ad: string; standartSeans: number }[] }>(`/api/ftr/uygulamalar?q=${encodeURIComponent(q)}`),
};
