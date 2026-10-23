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
  tedarikciGosterge: () => istek<{ gosterge: TedarikciGostergesi }>('/api/cari/tedarikci-gosterge'),
};

/** Tedarikçi Listesi Ver3 gösterge şeridi (1162). */
export interface TedarikciGostergesi {
  aktif: number; yeniBuAy: number; borclu: number; borc: number; vadeli: number; vadesiGecen: number;
  odenecekCari: number; odenecek30: number; uyuyan: number; alisBuYil: number; alisGecenYil: number; cekHafta: number;
}

/** Müşteri kartı Ver3 özeti (GET /api/cari/{id}/kart-ozet): şerit, sağ sütun, Finansal sekmesi. */
export interface CariKartOzeti {
  ozet: {
    id: number; bakiye: number; vadesiGecen: number; riskLimiti: number; vadeGun: number;
    riskYuzde: number | null; ciroBuYil: number; ciroGecenYil: number; ciro12Ay: number; ciroEgri: string;
    sonSatis: string | null; sonTahsilat: string | null; durum: number; notlar: string; notTarihi: string | null;
    acikSiparisAdet: number; acikSiparis: number; cekAdet: number; cekTutar: number; cekIlkVade: string | null;
    /** Sevk edilmiş, faturalanmamış satış irsaliyesi toplamı (Satış & Risk, 1152). */
    irsaliyeAcik?: number;
    // Tedarikçi gözü (1162).
    musteri: number; tedarikci: number;
    vadesiGecenOdeme: number; odenecek30: number; alisBuYil: number; alisGecenYil: number; alis12Ay: number; alisEgri: string;
    sonAlis: string | null; sonOdeme: string | null; tedVadeGun: number; krediLimiti: number; onayDurumu: number; tedarikSuresiGun: number;
    verilenCekAdet: number; verilenCekTutar: number; verilenCekIlkVade: string | null;
  };
  odemeYaslandirma: { gecen: number; d30: number; sonra: number };
  vadesiGecenOdemeler: { tarih: string; vade: string; belgeNo: string; turAdi: string; belgeId: number; gecikme: number; kalan: number }[];
  verilenCekler: { id: number; tur: number; seriNo: string; banka: string; vade: string; durum: number; tutar: number; doviz: string; dovizTutar: number }[];
  dovizler: { doviz: string; borc: number; alacak: number; bakiye: number; yerel: number }[];
  yaslandirma: { gelmemis: number; d30: number; d60: number; d90: number };
  vadesiGecenler: { tarih: string; vade: string; belgeNo: string; turAdi: string; belgeId: number; gecikme: number; kalan: number }[];
  cekler: { id: number; tur: number; seriNo: string; banka: string; vade: string; durum: number; tutar: number; doviz: string; dovizTutar: number }[];
  uyarilar: { seviye: 'kirmizi' | 'sari'; metin: string }[];
}

export const cariKartUclari = {
  cariKartOzet: (id: number) => istek<CariKartOzeti>(`/api/cari/${id}/kart-ozet`),
};
