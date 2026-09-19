import { gonder, istek } from '../cekirdek';

/**
 * STERİLİZASYON (868) — pano, döngü (başlat / bitir / indikatör / serbest / iptal / kart),
 * birim olayları, paket okutma (kullanım), izlenebilirlik, geri çağırma, kayıt defteri,
 * kurallar, ayar. Alan adları sunucu görünümleriyle birebir (v_steril_*).
 */
export interface SterilCihaz {
  id: number; ad: string; tur: number; tur_adi: string; marka_model: string; seri_no: string; sinif?: number | null; sinif_adi: string; kapasite: string; sayac: number;
  veri_baglanti: string; konum: string; sorumlu_id?: number | null; sorumlu_adi: string; bakim_ay: number; son_bakim?: string | null; sonraki_bakim?: string | null;
  son_validasyon?: string | null; sonraki_validasyon?: string | null; durum: number; durum_adi: string; aciklama: string; sube_id: number;
  son_dongu_id?: number | null; son_dongu_durum?: number | null; bugun_dongu: number; bd_bugun: number; aktifDongu?: SterilDongu | null;
}
export interface SterilProgram { id: number; cihaz_id?: number | null; cihaz_adi: string; ad: string; sicaklik: number; plato_dk: number; kurutma_dk: number; uygun_yuk: string; test: number; varsayilan: number; aktif: number; aktif_adi: string }
export interface SterilSet { id: number; kod: string; ad: string; paket_tur: number; paket_tur_adi: string; raf_omru_ay: number; min_stok: number; dongu_esigi: number; implant: number; aciklama: string; aktif: number; aktif_adi: string; alet_sayisi: number; birim_sayisi: number; steril_depoda: number; hazirlikta: number; kullanimda: number; arizali: number }
export interface SterilBirim {
  id: number; barkod: string; tur: number; tur_adi: string; set_id?: number | null; set_adi: string; set_kodu: string; ad: string; durum: number; durum_adi: string; durum_zaman: string; durum_dk: number;
  dongu_sayisi: number; yaglama_sayisi: number; son_yaglama?: string | null; yaglama_gerekli: number; uretici_esigi: number; bakim_zamani: number; son_dongu_id?: number | null; son_dongu_no?: number | null;
  son_kullanim?: string | null; son_taraf_id?: number | null; son_hasta_adi: string; son_belge_id?: number | null; konum: string; aciklama: string; aktif: number; sube_id: number; skt?: string | null; paket_barkod?: string | null; implant: number;
}
export interface SterilDongu {
  id: number; cihaz_id: number; cihaz_adi: string; sayac_no: number; program_id?: number | null; program_adi: string; hedef_sicaklik?: number | null; hedef_plato_dk?: number | null;
  baslama: string; bitis?: string | null; sure_dk: number; operator_id?: number | null; operator_adi: string; durum: number; durum_adi: string;
  tepe_sicaklik?: number | null; plato_dk?: number | null; tepe_basinc?: number | null; kurutma_dk?: number | null; hata_kodu: string; bd_onay_notu: string; onaylayan_id?: number | null; onaylayan_adi: string; onay_zamani?: string | null; karar_notu: string; sube_id: number;
  paket_sayisi: number; yuk_ozeti?: string | null; implant_var?: number | null; bd_sonuc?: number | null; helix_sonuc?: number | null; kimyasal_sonuc?: number | null; bio_sonuc?: number | null; bio_bitis?: string | null; vakum_sonuc?: number | null; test_programi: number;
}
export interface SterilPaket {
  id: number; barkod: string; birim_id: number; birim_barkod: string; birim_adi: string; birim_tur: number; set_adi: string; implant: number; dongu_id: number; dongu_no: number; cihaz_adi: string; steril_tarihi?: string | null; dongu_durum: number;
  paket_tur: number; paket_tur_adi: string; paketleyen_id?: number | null; paketleyen_adi: string; paketleme_zamani: string; skt?: string | null; skt_kalan_gun?: number | null; raf: string; durum: number; durum_adi: string; kullanilabilir: number; sube_id: number;
  kullanim_zamani?: string | null; kullanan_hasta: string;
}
export interface SterilKullanim {
  id: number; paket_id: number; paket_barkod: string; birim_adi: string; set_adi: string; dongu_id: number; dongu_no: number; cihaz_adi: string; dongu_durum: number; taraf_id?: number | null; hasta_adi: string; dosya_no: string;
  belge_id?: number | null; belge_no: string; hekim_id?: number | null; hekim_adi: string; unite: string; okutan_id?: number | null; okutan_adi: string; zaman: string; notu: string; sube_id: number; bio_sonuc?: number | null; riskSinifi?: string; cepTel?: string;
}
export interface SterilIndikator { id: number; tur: number; turAdi: string; lot: string; konum: string; sonuc: number; okuyanAdi: string; okumaZamani?: string | null; inkubasyonBitis?: string | null; notu: string }
export interface SterilOlay { id: number; zaman: string; tur: number; turAdi: string; kullaniciAdi: string; aciklama: string; birimId?: number | null; paketId?: number | null; donguId?: number | null }
export interface SterilUyari { tur: string; seviye: 'kir' | 'sari'; mesaj: string; cihazId?: number; donguId?: number; birimId?: number }
export interface SterilKurallar {
  bdKurali: 'uyari' | 'onay' | 'engel'; bioGecikmeUyariGun: number; bioGecikmeEngelGun: number; karantinaKullanim: 'uyari' | 'engel'; seansOkutma: string; sktUyariGun: number;
  yaglamaZorunlu: number; donguEsigi: number; rafOmru: Record<string, number>; etiketYazici: string; bioSiklikGun: number;
}
export interface SterilPano {
  kpi: { bugunDongu: number; bugunSerbest: number; calisan: number; kirli: number; paketlemeBekleyen: number; sterilDepo: number; sktYakin: number; karantina: number; bugunKullanilan: number; bugunHasta: number; bloke: number };
  cihazlar: SterilCihaz[]; dongular: SterilDongu[]; birimler: SterilBirim[]; depo: SterilPaket[]; kullanilan: SterilKullanim[]; setler: SterilSet[]; uyarilar: SterilUyari[]; programlar: SterilProgram[]; kurallar: SterilKurallar;
}
export interface SterilDonguKart { dongu: SterilDongu; paketler: SterilPaket[]; indikatorler: SterilIndikator[]; olaylar: SterilOlay[]; kurallar: SterilKurallar }
export interface SterilEtiket { paketId: number; barkod: string; icerik: string; cihaz: string; donguNo: number; tarih: string; skt?: string | null; operatorAdi: string; raf: string }
export interface SterilIzleme { paket: SterilPaket | null; birim: SterilBirim | null; dongu?: SterilDongu | null; olaylar: SterilOlay[]; kullanimlar: SterilKullanim[] }
export interface SterilGeriCagirma { id: number; cihaz_id: number; cihaz_adi: string; tetik_dongu_id: number; tetik_dongu_no: number; etkilenen_dongu: number; etkilenen_paket: number; kullanilan_paket: number; hasta_sayisi: number; durum: number; durum_adi: string; aciklama: string; acan_adi: string; ekleme_tarihi: string; kapanis?: string | null }
export interface SterilAyar {
  kurallar: SterilKurallar; cihazlar: SterilCihaz[]; programlar: SterilProgram[];
  bakimlar: { id: number; cihaz_id: number; cihaz_adi: string; tur: number; tur_adi: string; tarih: string; yapan: string; sonraki_tarih?: string | null; kalan_gun?: number | null; sonuc: string; belge_no: string; aciklama: string }[];
  testler: { cihazId: number; cihazAdi: string; bdBugun: number; helixBugun: number; vakumBugun: number; sonBio?: string | null; sonBioSonuc?: number | null; bioBekleyen: number; sonrakiBakim?: string | null; sonrakiValidasyon?: string | null; son7gunBd: number; son7gunDonguGun: number }[];
  takvim: { gun: string; bd: number; bdKaldi: number; helix: number; bio: number; bioBekleyen: number; dongu: number }[];
}

export const sterilUclari = {
  sterilPano: () => istek<SterilPano>('/api/steril/pano'),
  sterilKurallar: () => istek<SterilKurallar>('/api/steril/kurallar'),
  sterilKurallarKaydet: (g: SterilKurallar) => gonder<SterilKurallar>('/api/steril/kurallar', g),
  sterilAyar: () => istek<SterilAyar>('/api/steril/ayar'),
  sterilDonguBaslat: (g: { cihazId: number; programId?: number | null; birimler: { birimId?: number; barkod?: string; paketTur?: number; raf?: string }[]; kimyasalLot?: string; bioLot?: string; bdOnayNotu?: string; notu?: string }) =>
    gonder<{ id: number; sayacNo: number; paketSayisi: number; test: boolean }>('/api/steril/dongu/baslat', g),
  sterilDonguBitir: (id: number, g: { tepeSicaklik?: number | null; platoDk?: number | null; tepeBasinc?: number | null; kurutmaDk?: number | null; hataKodu?: string }) =>
    gonder<{ id: number; durum: number }>(`/api/steril/dongu/${id}/bitir`, g),
  sterilIndikator: (id: number, g: { tur: number; lot?: string; konum?: string; sonuc: number; notu?: string; inkubasyonSaat?: number }) =>
    gonder<{ id: number; donguId: number; mesaj: string; geriCagirmaId?: number | null }>(`/api/steril/dongu/${id}/indikator`, g),
  sterilSerbest: (id: number, g: { karar: 'serbest' | 'karantina' | 'basarisiz'; notu?: string; bdOnayNotu?: string }) =>
    gonder<{ id: number; karar: string; etiketler: SterilEtiket[]; mesaj: string }>(`/api/steril/dongu/${id}/serbest`, g),
  sterilDonguIptal: (id: number, aciklama?: string) => gonder<{ id: number }>(`/api/steril/dongu/${id}/iptal`, { aciklama }),
  sterilDongu: (id: number) => istek<SterilDonguKart>(`/api/steril/dongu/${id}`),
  sterilBirimOlay: (g: { birimId?: number; barkod?: string; islem: 'kirli' | 'yikama' | 'sayim' | 'paketle' | 'yaglama' | 'ariza' | 'depo' | 'not'; sayilan?: number; toplam?: number; eksik?: string; notu?: string; tarafId?: number | null; belgeId?: number | null }) =>
    gonder<{ birimId: number; islem: string; mesaj: string }>('/api/steril/birim/olay', g),
  sterilOkut: (g: { barkod: string; tarafId?: number | null; belgeId?: number | null; hekimId?: number | null; unite?: string; zorla?: boolean; notu?: string }) =>
    gonder<{ id: number; paketId: number; barkod: string; icerik: string; karantina: boolean; mesaj: string }>('/api/steril/paket/okut', g),
  sterilPaketIzle: (barkod: string) => istek<SterilIzleme>(`/api/steril/paket/${encodeURIComponent(barkod)}`),
  sterilIzleme: (p: { tarafId?: number; belgeId?: number; bas?: string; bit?: string }) => {
    const q = new URLSearchParams(); if (p.tarafId) q.set('tarafId', String(p.tarafId)); if (p.belgeId) q.set('belgeId', String(p.belgeId)); if (p.bas) q.set('bas', p.bas); if (p.bit) q.set('bit', p.bit);
    return istek<{ satirlar: SterilKullanim[] }>(`/api/steril/izleme?${q}`);
  },
  sterilGeriCagirmaAc: (donguId: number, aciklama?: string) => gonder<{ id: number }>('/api/steril/geri-cagirma', { donguId, aciklama }),
  sterilGeriCagirma: (id: number) => istek<{ kayit: SterilGeriCagirma; dongular: SterilDongu[]; paketler: SterilPaket[]; hastalar: SterilKullanim[] }>(`/api/steril/geri-cagirma/${id}`),
  sterilGeriCagirmaKapat: (id: number, aciklama?: string) => gonder<{ id: number }>(`/api/steril/geri-cagirma/${id}/kapat`, { aciklama }),
  sterilGeriCagirmaBildir: (id: number, tarafIdleri: number[]) => gonder<{ gonderilen: number; hata: number }>(`/api/steril/geri-cagirma/${id}/bildir`, { tarafIdleri }),
  sterilKayitDefteri: (ay?: string, cihazId?: number) => {
    const q = new URLSearchParams(); if (ay) q.set('ay', ay); if (cihazId) q.set('cihazId', String(cihazId));
    return istek<{ ay: string; satirlar: SterilDongu[]; ozet: { dongu: number; basarisiz: number; test: number; paket: number; kullanilan: number; geriCagirma: number } }>(`/api/steril/kayit-defteri?${q}`);
  },
};
