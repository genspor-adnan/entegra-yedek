import { gonder, istek } from '../cekirdek';

/** Konsültasyon özet kutuları (sekmenin kapsamında) + sekme süzgeci için kullanıcı ve bölümleri. */
export interface KonsultasyonOzet {
  ben: number;
  bolumler: number[];
  ozet: {
    suresiGecen: number; yanitBekleyen: number; yanitladiklarim: number; bugunYanitlanan: number;
    ortalamaDk: number; enabizGonderilen: number; enabizToplam: number; disMerkez: number; acik: number;
  };
}

export interface KonsultasyonOnizleme {
  id: number;
  k: {
    no: string; soru: string; isteyen: string; sorumlu: string; istekZamani: string; aciliyet: number;
    karsilamaYeri: number; basvuruNo: string; istekBolum: string; tarafId: number; isteyenMuayeneId?: number | null;
    durum: number; hedefBolumId?: number | null; hedefBolum: string; sonuc: number;
    yanitlamaZamani?: string | null; hastadaZamani?: string | null; yanitZamani?: string | null; gorduZamani?: string | null;
    yanitMuayeneId?: number | null; yanitlayan: string; retGerekce: string; yonlendirmeNotu: string;
    hasta?: string; hastaKod?: string;
  };
  tanilar: string[]; lab: string[]; ilaclar: string[]; alerjiler: string[];
  gecmis: { id: number; yanitlayan: string; zaman: string; yanit: string; bolum: string }[];
  akis: { tur: number; zaman: string; aciklama: string; kim: string }[];
  enabiz: boolean;
}

type Mesaj = { id: number; mesaj: string };

/** KONSÜLTASYON (1107) - istek akışı. Terim "yanıtla" (üstlen yok). */
export const konsultasyonUclari = {
  konsultasyonOzet: (kapsam: 'gelen' | 'istedigim' | 'bolum') =>
    istek<KonsultasyonOzet>(`/api/konsultasyon/ozet?kapsam=${kapsam}`),
  konsultasyonOnizleme: (id: number) => istek<KonsultasyonOnizleme>(`/api/konsultasyon/${id}/onizleme`),
  konsultasyonYanitMuayenesi: (muayeneId: number) => istek<{ id?: number | null }>(`/api/konsultasyon/yanit/${muayeneId}`),
  konsultasyonYanitla: (id: number) => gonder<Mesaj & { yanitMuayeneId: number }>(`/api/konsultasyon/${id}/yanitla`, {}),
  konsultasyonHastada: (id: number) => gonder<Mesaj>(`/api/konsultasyon/${id}/hastada`, {}),
  konsultasyonSonuc: (id: number, sonuc: number) => gonder<Mesaj>(`/api/konsultasyon/${id}/sonuc`, { sonuc }),
  konsultasyonYonlendir: (id: number, hedefBolumId: number, hedefHekimId: number | null, gerekce: string) =>
    gonder<Mesaj>(`/api/konsultasyon/${id}/yonlendir`, { hedefBolumId, hedefHekimId, gerekce }),
  konsultasyonReddet: (id: number, gerekce: string) => gonder<Mesaj>(`/api/konsultasyon/${id}/reddet`, { gerekce }),
  konsultasyonGordum: (id: number) => gonder<Mesaj>(`/api/konsultasyon/${id}/gordum`, {}),
  muayenedenKonsultasyon: (muayeneId: number) => gonder<Mesaj>(`/api/muayene/${muayeneId}/konsultasyon`, {}),
};
