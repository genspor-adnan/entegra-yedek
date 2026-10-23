import { istek } from '../cekirdek';

/** Müşteri Listesi Ver3 gösterge şeridi (CariListeUclari, 1150). Sayılar sunucuda. */
export interface MusteriGostergesi {
  aktif: number; yeniBuAy: number;
  borclu: number; alacak: number;
  vadeli: number; vadesiGecen: number;
  limitAsan: number;
  uyuyan: number; uyuyanCiro: number;
  ciroBuYil: number; ciroGecenYil: number;
}

export const cariListeUclari = {
  musteriGosterge: () => istek<{ gosterge: MusteriGostergesi }>('/api/cari/musteri-gosterge'),
};

/** Müşteri kartı Ver3 özeti (GET /api/cari/{id}/kart-ozet): şerit, sağ sütun, Finansal sekmesi. */
export interface CariKartOzeti {
  ozet: {
    id: number; bakiye: number; vadesiGecen: number; riskLimiti: number; vadeGun: number;
    riskYuzde: number | null; ciroBuYil: number; ciroGecenYil: number; ciro12Ay: number; ciroEgri: string;
    sonSatis: string | null; sonTahsilat: string | null; durum: number; notlar: string; notTarihi: string | null;
    acikSiparisAdet: number; acikSiparis: number; cekAdet: number; cekTutar: number; cekIlkVade: string | null;
  };
  dovizler: { doviz: string; borc: number; alacak: number; bakiye: number; yerel: number }[];
  yaslandirma: { gelmemis: number; d30: number; d60: number; d90: number };
  vadesiGecenler: { tarih: string; vade: string; belgeNo: string; turAdi: string; belgeId: number; gecikme: number; kalan: number }[];
  cekler: { id: number; tur: number; seriNo: string; banka: string; vade: string; durum: number; tutar: number; doviz: string; dovizTutar: number }[];
  uyarilar: { seviye: 'kirmizi' | 'sari'; metin: string }[];
}

export const cariKartUclari = {
  cariKartOzet: (id: number) => istek<CariKartOzeti>(`/api/cari/${id}/kart-ozet`),
};
