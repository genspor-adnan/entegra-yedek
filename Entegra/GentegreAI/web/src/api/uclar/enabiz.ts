import { gonder, istek } from '../cekirdek';

/**
 * e-NABIZ HASTA MESAJI (877 — KTS denetim maddesi H7 / D14).
 *
 * Uclar yalniz KUYRUGA alir; gonderimi zamanli is (`enabiz.mesaj`) yapar.
 * Paket gonderimi ve veri kalitesi uclari `lab.ts` icinde duruyor (454) -
 * burasi hekimin hastaya yazdigi mesaj icin.
 */
export interface EnabizMesaji {
  id: number;
  hastaId: number; hasta: string;
  hekimId: number | null; hekim: string;
  kaynak: number; kaynakAdi: string;
  metin: string;
  /** 0 kuyrukta · 1 gonderildi · 2 hata · 3 vazgecildi. */
  durum: number; durumAdi: string;
  deneme: number;
  gonderim: string | null;
  yanitKod: string; yanitMesaj: string; sonHata: string;
  eklemeTarihi: string;
  belgeId: number | null;
  /** SKRS HASTA MESAJLARI turu (881) - 411 paketinin zorunlu alani. */
  mesajTuru: number; mesajTuruAdi: string;
  /** Uretilen 411 paketi; gonderim durumu PAKETIN durumudur. */
  paketNo: string; paketDurum: number | null;
}

/** Gonderim kapisi: hesap acik mi, servis metodu tanimli mi. */
export interface EnabizMesajKapisi {
  /** 411 paket turu acik mi (881). */
  paketAcik: boolean;
  /** USS gonderim hesabi (ENABIZ) tanimli mi. */
  hesapAcik: boolean;
  /** `enabiz.gonder` zamanli isi acik mi - kapaliysa paket kuyrukta bekler. */
  gonderimIsi: boolean;
  acik: boolean;
}

export const enabizUclari = {
  enabizMesajListe: (hastaId: number) =>
    istek<{ mesajlar: EnabizMesaji[]; kapi: EnabizMesajKapisi | null }>(
      `/api/enabiz/mesaj?hastaId=${hastaId}`),

  enabizMesajYaz: (g: {
    hastaId: number; metin: string; hekimId?: number | null;
    belgeId?: number | null; kaynak?: number; kaynakId?: number | null;
  }) => gonder<{ id: number; mesaj: EnabizMesaji }>('/api/enabiz/mesaj', g),

  enabizMesajVazgec: (id: number) =>
    gonder<{ durum: number }>(`/api/enabiz/mesaj/${id}/vazgec`, {}),

  /**
   * HEKIM ERISIMI (878, KTS H6): `DoktorEHRErisimi` cagrilir, donen gecici
   * anahtarla acilacak ADRES doner. Ekran adresi yeni sekmede acar - hekim
   * orada e-Devlet ile girer, hasta verisini gizlemisse SMS onayi ister.
   */
  enabizErisimAc: (g: { hastaId: number; hekimId?: number | null; muayeneId?: number | null; belgeId?: number | null }) =>
    gonder<{ kayitId: number; adres: string; mesaj: string }>('/api/enabiz/erisim', g),

  /** Hastanin erisim gecmisi (KVKK izi). */
  enabizErisimGecmisi: (hastaId: number) =>
    istek<{ erisimler: EnabizErisimi[] }>(`/api/enabiz/erisim?hastaId=${hastaId}`),

  // ------------------------------------------- gun sonu / oran (884) ----
  /** Gun sonu kayitlari + paket gonderim orani (KTS H13). */
  enabizGunSonuPano: () => istek<GunSonuPanosu>('/api/enabiz/gun-sonu'),
  enabizGunSonuDetay: (id: number) =>
    istek<{ satirlar: { skrsKod: number; ad: string; sayi: number }[] }>(
      `/api/enabiz/gun-sonu/${id}`),
  /** Gunu yeniden hesaplar ve 407 paketini uretir. */
  enabizGunSonuHesapla: (tarih: string, subeId?: number) =>
    gonder<{ gunSonuId: number; tarih: string; olcutSayisi: number; toplamSayi: number;
             paketNo: string | null; mesaj: string }>(
      '/api/enabiz/gun-sonu/hesapla', { tarih, subeId }),

  /** Ay sonu (408, 885): klinik kirilimli aylik ozetler. */
  enabizAySonuListe: (yil?: number) =>
    istek<{ aylar: AySonuSatiri[];
            kodsuzBolumler: { ad: string; muayene: number }[] }>(
      `/api/enabiz/gun-sonu/ay${yil ? `?yil=${yil}` : ''}`),
  enabizAySonuDetay: (id: number) =>
    istek<{ satirlar: { klinikKodu: string; klinik: string; skrsKod: number;
                        ad: string; sayi: number }[] }>(`/api/enabiz/gun-sonu/ay/${id}`),
  enabizAySonuHesapla: (yil: number, ay: number) =>
    gonder<{ aySonuId: number; yil: number; ay: number; klinikSayisi: number;
             satirSayisi: number; paketNo: string | null; mesaj: string }>(
      '/api/enabiz/gun-sonu/ay/hesapla', { yil, ay }),

  /** Kuyrugu elle calistir (zamanli is 15 dakikada bir zaten calisir). */
  enabizMesajKuyruk: (mesajId?: number) =>
    gonder<{ gonderildi: number; hata: number; bekleyen: number; aciklama: string }>(
      `/api/enabiz/mesaj/kuyruk${mesajId ? `?mesajId=${mesajId}` : ''}`, {}),
};

/** e-Nabiz erisim izi - `v_enabiz_erisim` (878). */
export interface EnabizErisimi {
  id: number; hekim: string; zaman: string;
  /** 0 istendi · 1 anahtar alindi · 2 servis reddetti · 3 hata. */
  sonuc: number; sonucAdi: string;
  anahtarOnek: string; servisMesaji: string;
}

/** Gun sonu panosu (884): gunluk ozetler + paket gonderim orani. */
export interface GunSonuPanosu {
  baslangic: string; bitis: string;
  gunler: { id: number; tarih: string; subeId: number; durum: number; hesapZamani: string;
            paketNo: string; paketDurum: number | null; olcut: number; toplam: number }[];
  oranlar: { tarih: string; paketKodu: string; uretilen: number; gonderilen: number;
             bekleyen: number; hatali: number; oran: number }[];
  ozet: { toplamUretilen: number; toplamGonderilen: number; genelOran: number;
          altSinir: number; ustSinir: number; aralikta: boolean };
}

/** Ay sonu ozeti (885): klinik kirilimli aylik satirlar. */
export interface AySonuSatiri {
  id: number; yil: number; ay: number; durum: number; hesapZamani: string;
  paketNo: string; paketDurum: number | null; klinik: number; satir: number;
}
