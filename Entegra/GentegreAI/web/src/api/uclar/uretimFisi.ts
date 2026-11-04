import { gonder, istek } from '../cekirdek';

/**
 * ÜRETİM FİŞİ + ÜRETİM SEVİYESİ (1253; mockuplar Ekranlar/Uretim/uretim_fisi*.html, uretim_basit.html).
 * Alan adları sunucuyla birebir (UretimFisiUclari).
 */

export type UretimSeviyesi = 'basit' | 'standart' | 'denetimli';

export interface UretimSeviyeYaniti { seviye: UretimSeviyesi; emirKullan: boolean }

/** Satır grubu: 1 sarf · 2 işçilik / gider · 3 fire · 4 çıktı. */
export type FisGrup = 1 | 2 | 3 | 4;

/** Lot / seri: sarf ve firede seçilen lot (seriLotId), çıktıda verilen yeni lot. Belge satırının izlemler biçimi. */
export interface FisIzlem {
  seriLotId?: number | null; lotNo?: string; seriNo?: string;
  uretimTarihi?: string | null; sonKullanmaTarihi?: string | null; durum?: number; miktar: number;
}

export interface FisSatiri {
  id?: number; sira: number; grup: FisGrup;
  stokId: number | null; stokKod: string; stokAd: string; izleme: number;
  masrafId?: number | null; ad?: string; anaUrun: boolean;
  birimIhtiyac: number; planMiktar: number; miktar: number; birim: number; birimAdi: string;
  birimMaliyet: number; tutar: number; elleMaliyet: boolean; fireTuru: 1 | 2;
  izlemler?: FisIzlem[] | null; aciklama: string;
  /** Sarf deposundaki kalan (sunucu) - eksik vurgusu buna bakar. */
  depoKalan: number; eksik?: number;
  isMerkeziId?: number | null;
}

export interface FisOperasyonu {
  id?: number; sira: number; ad: string; tarafId: number | null; personelAdi?: string;
  isMerkeziId: number | null; isMerkeziAdi?: string; bas: string | null; bit: string | null;
  molaDk: number; sureSaat: number; adet: number; saatUcreti: number; tutar?: number; durum: number; aciklama: string;
}

export interface FisKontrolu {
  id?: number; sira: number; ad: string; kriter: string; sonuc: number;
  yapanId?: number | null; yapanAdi?: string; zaman?: string | null; notu: string;
}

export interface FisBasligi {
  id: number; no: string; durum: number; seviye: string;
  stokId: number; stokKod: string; stokAd: string; izleme: number; birimAdi: string; kategori: string;
  rafOmruSure: number; rafOmruBirim: number;
  agacId: number | null; agacKod: string; agacSurum: number;
  emirId: number | null; miktar: number; uretilen: number; birim: number; bas: string | null; bit: string | null;
  sarfDepoId: number | null; sarfDepoAdi: string; girisDepoId: number | null; girisDepoAdi: string;
  isMerkeziId: number | null; isMerkeziAdi: string; sorumluId: number | null; sorumluAdi: string;
  onaylayanId: number | null; projeId: number | null; partiNo: string;
  maliyetYontemi: number; otomatikHesap: number; dovizCinsi: string;
  malzeme: number; iscilik: number; fireNormal: number; fireAnormal: number; yanUrun: number; toplam: number; birimMaliyet: number;
  sarfBelgeId: number | null; girisBelgeId: number | null; fireBelgeId: number | null;
  gerceklesmeAn: string | null; gerceklestirenAdi: string; serbestAn: string | null; serbestAdi: string; serbestGerekce: string;
  tersAn: string | null; tersAdi: string; tersNeden: string;
  aciklama: string; subeId: number; eklemeTarihi: string; ekleyenAdi: string; surum: number; girisDepoKalan: number;
}

export interface FisBelgesi { id: number; tur: number; turAdi: string; belgeTarihi: string; belgeNo: string | null; tutar: number; depoAdi: string }

export interface FisEmri { id: number; no: string; durum: number; adet: number; uretilenAdet: number; termin: string | null }

export interface FisYaniti {
  fis: FisBasligi; satirlar: FisSatiri[]; operasyonlar: FisOperasyonu[]; kontroller: FisKontrolu[];
  belgeler: FisBelgesi[]; emir: FisEmri | null;
}

export interface MamulBilgisi {
  id: number; kod: string; ad: string; birimKodu: number; birimAdi: string; izleme: number;
  rafOmruSure: number; rafOmruBirim: number; kategori: string;
  agacId: number | null; agacKod: string | null; agacSurum: number | null; agacCikti: number | null;
  sarfDepoId: number | null; mamulDepoId: number | null; agacSayisi: number;
  /** JSON metni: [{depoId, depoAdi, kalan}]. */
  depolar: string;
}

export interface FisIstegi {
  stokId: number; agacId: number | null; emirId: number | null; miktar: number; bas: string | null; bit: string | null;
  sarfDepoId: number | null; girisDepoId: number | null; isMerkeziId: number | null; sorumluId: number | null;
  onaylayanId: number | null; projeId: number | null; partiNo: string; maliyetYontemi: number; otomatikHesap: boolean;
  aciklama: string;
  satirlar: {
    grup: FisGrup; stokId: number | null; masrafId: number | null; ad: string; anaUrun: boolean; birimIhtiyac: number;
    planMiktar: number; miktar: number; birim: number; birimMaliyet: number; elleMaliyet: boolean; fireTuru: number;
    izlemler: FisIzlem[] | null; aciklama: string;
  }[];
  operasyonlar: Omit<FisOperasyonu, 'id' | 'personelAdi' | 'isMerkeziAdi' | 'tutar'>[];
  kontroller: { ad: string; kriter: string; sonuc: number; notu: string }[];
  gerceklestir: boolean; eksiyeIzin: boolean; surum: number | null;
}

export interface OnKontrol { kod: string; ad: string; kural: string; sonuc: number }

/** Emir listesi özet şeridi (1254, GET /api/uretim/emri/ozet) - kurum geneli, şubeye süzülü. */
export interface EmirOzeti {
  acik: number; taslak: number; onayli: number; serbest: number; uretimde: number;
  plan: number; uretilen: number; geciken: number; gecikenNo: string | null; gecikenGun: number | null;
  malzemeEksik: number; malzemeHazirlik: number; karantinaParti: number; karantinaAdet: number;
}

/** Fiş listesi özet şeridi (1254, GET /api/uretim/fis/ozet) - dönem bu ay; karantina / taslak dönemden bağımsız. */
export interface FisOzeti {
  fis: number; taslak: number; tersKayit: number; uretilen: number; mamul: number; yanUrun: number;
  malzeme: number; iscilik: number; toplam: number; karantinaParti: number; karantinaAdet: number; reddedilen: number;
}

export const uretimFisiUclari = {
  uretimEmirOzet: () => istek<{ ozet: EmirOzeti }>('/api/uretim/emri/ozet').then(y => y.ozet),
  uretimFisOzet: () => istek<{ ozet: FisOzeti; bas: string; bit: string }>('/api/uretim/fis/ozet'),
  uretimSeviye: () => istek<UretimSeviyeYaniti>('/api/uretim/seviye'),
  uretimSeviyeYaz: (seviye: UretimSeviyesi, emirKullan: boolean) =>
    gonder<UretimSeviyeYaniti>('/api/uretim/seviye', { seviye, emirKullan }, 'PUT'),

  uretimMamul: (stokId: number) => istek<{ mamul: MamulBilgisi }>(`/api/uretim/fis/mamul/${stokId}`).then(y => y.mamul),

  /** Ürün ağacından satır önerisi - yazmaz. */
  uretimFisDoldur: (g: { stokId: number; agacId?: number | null; miktar: number; sarfDepoId?: number | null; maliyetYontemi?: number }) =>
    gonder<{ agac: { id: number; kod: string; surum: number; cikti: number; sarfDepoId: number | null; mamulDepoId: number | null };
             satirlar: FisSatiri[] }>('/api/uretim/fis/doldur', g),

  uretimFisOku: (id: number) => istek<FisYaniti>(`/api/uretim/fis/${id}`),
  uretimFisEkle: (g: FisIstegi) => gonder<{ id: number; no: string; uyarilar: string[]; mesaj: string }>('/api/uretim/fis', g),
  uretimFisGuncelle: (id: number, g: FisIstegi) =>
    gonder<{ id: number; no: string; uyarilar: string[]; mesaj: string }>(`/api/uretim/fis/${id}`, g, 'PUT'),
  uretimFisGerceklestir: (id: number, eksiyeIzin = false) =>
    gonder<{ id: number; uyarilar: string[]; fis: FisBasligi; mesaj: string }>(`/api/uretim/fis/${id}/gerceklestir`, { eksiyeIzin }),
  uretimFisTersKayit: (id: number, neden: string) =>
    gonder<{ id: number; durum: number; mesaj: string }>(`/api/uretim/fis/${id}/ters-kayit`, { neden }),
  uretimFisSil: (id: number) => istek<{ silindi: boolean }>(`/api/uretim/fis/${id}`, { method: 'DELETE' }),
  uretimFisOperasyonYaz: (id: number, satirlar: FisIstegi['operasyonlar']) =>
    gonder<{ operasyonlar: FisOperasyonu[] }>(`/api/uretim/fis/${id}/operasyon`, satirlar, 'PUT'),
  uretimFisKontrolYaz: (id: number, satirlar: FisIstegi['kontroller']) =>
    gonder<{ kontroller: FisKontrolu[] }>(`/api/uretim/fis/${id}/kontrol`, satirlar, 'PUT'),
  /** Kalite serbest bırakma (1) / ret (2) - e-imza: parola + gerekçe. */
  uretimFisSerbest: (id: number, karar: 1 | 2, gerekce: string, parola: string) =>
    gonder<{ id: number; durum: number; mesaj: string }>(`/api/uretim/fis/${id}/serbest`, { karar, gerekce, parola }),
  uretimFisGecmis: (id: number) =>
    istek<{ satirlar: { tarih: string; kullanici: string; islemTipi: number; bilgi: string }[] }>(`/api/uretim/fis/${id}/gecmis`),
  uretimFisIzlenebilirlik: (id: number) =>
    istek<{
      girdiler: LotIzi[]; fireler: LotIzi[]; ciktilar: LotIzi[];
      ileri: { belgeId: number; tur: number; turAdi: string; tarih: string; belgeNo: string; taraf: string; miktar: number; lotNo: string; seriNo: string }[];
      personel: { personel: string; isMerkezi: string; operasyon: string }[];
    }>(`/api/uretim/fis/${id}/izlenebilirlik`),

  // ---- emir (1253 ekleri)
  /** Basit seviye "▶ Üret…": emirden fiş keser. */
  uretimEmriUret: (id: number, g: { adet: number; tarih?: string | null; fireStokId?: number | null; fireAdet?: number | null;
                                    fireNeden?: string; eksiyeIzin?: boolean; aciklama?: string }) =>
    gonder<{ id: number; fisId: number; fisNo: string; uyarilar: string[]; uretilen: number; adet: number; durum: number; mesaj: string }>(
      `/api/uretim/emri/${id}/uret`, g),
  uretimEmriOnKontrol: (id: number) =>
    istek<{ kontroller: OnKontrol[]; serbestOlur: boolean }>(`/api/uretim/emri/${id}/on-kontrol`),
  uretimEmriSerbestBirak: (id: number, gerekce?: string, parola?: string) =>
    gonder<{ id: number; durum: number; mesaj: string }>(`/api/uretim/emri/${id}/serbest-birak`, { gerekce, parola }),
  uretimEmriFisleri: (id: number) =>
    istek<{ fisler: { id: number; no: string; durum: number; tarih: string | null; uretilen: number; birimMaliyet: number;
                      toplam: number; partiNo: string; fire: number }[] }>(`/api/uretim/emri/${id}/fisler`),
};

export interface LotIzi { belgeId: number; stokKod: string; stokAd: string; lotNo: string; seriNo: string; skt: string | null; miktar: number; tedarikci: string }

/** Fiş durum adı; 2 seviyeye göre (denetimlide karantina). */
export function fisDurumAdi(durum: number, seviye: string): string {
  switch (durum) {
    case 0: return 'Ters kayıt';
    case 1: return 'Taslak';
    case 2: return seviye === 'denetimli' ? 'Karantina' : 'Stoğa işlendi';
    case 3: return 'Serbest';
    case 4: return 'Reddedildi';
    default: return String(durum);
  }
}

/**
 * MALİYET ÖNİZLEMESİ (IAS 2, sunucudaki GerceklestirAsync ile aynı formül): ana ürün maliyeti = malzeme + işçilik / gider +
 * normal fire − yan ürün; anormal fire mamule yüklenmez. Ekran kaydetmeden önce aynı rakamı göstersin.
 */
export function fisMaliyeti(satirlar: FisSatiri[]) {
  const t = (s: FisSatiri) => Math.round(s.miktar * s.birimMaliyet * 10000) / 10000;
  const topla = (f: (s: FisSatiri) => boolean) => satirlar.filter(f).reduce((a, s) => a + t(s), 0);
  const malzeme = topla(s => s.grup === 1);
  const iscilik = topla(s => s.grup === 2);
  const fireNormal = topla(s => s.grup === 3 && s.fireTuru !== 2);
  const fireAnormal = topla(s => s.grup === 3 && s.fireTuru === 2);
  const yanUrun = topla(s => s.grup === 4 && !s.anaUrun);
  const ana = satirlar.find(s => s.grup === 4 && s.anaUrun);
  const toplam = malzeme + iscilik + fireNormal;
  const anaMaliyet = Math.max(0, toplam - yanUrun);
  const birim = ana && ana.miktar > 0 ? Math.round(anaMaliyet / ana.miktar * 10000) / 10000 : 0;
  return { malzeme, iscilik, fireNormal, fireAnormal, yanUrun, toplam, anaMaliyet, birim, anaMiktar: ana?.miktar ?? 0 };
}

/**
 * Miktar değişince ağaçtan gelen satırlar oranlanır (basit: "miktarı değiştirince malzemeler kendiliğinden oranlanır").
 * Sarf: birim ihtiyaç × yeni miktar (lot seçimi sıfırlanır). Ağaçtan gelen işçilik (açıklaması "operasyon…") eski ana ürün
 * miktarına oranla ölçeklenir: standartta saat (miktar), basitte tek tutar (birim maliyet). Hazırlık süresi parti başına
 * olduğundan bu bir yaklaşımdır; kesin değer "Ürün Ağacından Doldur" ile yenilenir. Elle eklenen satırlar dokunulmaz.
 */
export function fisSatirlariniOranla(satirlar: FisSatiri[], yeniMiktar: number): FisSatiri[] {
  const eski = satirlar.find(s => s.grup === 4 && s.anaUrun)?.miktar ?? 0;
  const oran = eski > 0 ? yeniMiktar / eski : 1;
  const y4 = (n: number) => Math.round(n * 1e4) / 1e4;
  return satirlar.map(s => {
    if (s.grup === 4 && s.anaUrun) return { ...s, miktar: yeniMiktar, planMiktar: yeniMiktar };
    if (s.grup === 1 && s.birimIhtiyac > 0) {
      const m = Math.round(s.birimIhtiyac * yeniMiktar * 1e6) / 1e6;
      return { ...s, miktar: m, planMiktar: m, tutar: y4(m * s.birimMaliyet), izlemler: null };
    }
    if (s.grup === 2 && s.aciklama.startsWith('operasyon') && oran !== 1) {
      // Tek tutar (miktar 1): tutar ölçeklenir; saat satırı: saat ölçeklenir.
      const yeni = s.miktar === 1 && s.birimAdi !== 'Saat'
        ? { ...s, birimMaliyet: y4(s.birimMaliyet * oran) }
        : { ...s, miktar: Math.round(s.miktar * oran * 1e3) / 1e3, planMiktar: Math.round(s.planMiktar * oran * 1e3) / 1e3 };
      return { ...yeni, tutar: y4(yeni.miktar * yeni.birimMaliyet) };
    }
    return s;
  });
}
