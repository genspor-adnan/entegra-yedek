import { istek, gonder } from '../cekirdek';

/** e-Fatura menü maddesi kodları - Delphi e-Fatura menüsünün giden fatura maddeleri. */
export type EFaturaKodu = 'ebelge.hazirla' | 'ebelge.onizle' | 'ebelge.gonder' | 'ebelge.pdf' | 'ebelge.html'
  | 'ebelge.xml' | 'ebelge.seri' | 'ebelge.sifirla' | 'ebelge.mesajlar';

/** Belgenin e-Fatura durumu + menü maddelerinin pasiflik sebepleri (sunucu kuralı, EFaturaKodlari). */
export type EFaturaDurumu = {
  belgeId: number; tur: number; efaturaDurum: number; efaturaSonuc: number;
  kullanimda: boolean; testMi: boolean; turAdi: string; durumAdi: string;
  belgeNo: string; ettn: string; aliciAlias: string; dosyaAdi: string;
  engeller: Partial<Record<EFaturaKodu, string | null>>;
};

/**
 * Hazırla cevabı. `soru` doluysa hiçbir şey yazılmadı: arayüz soruyu sorup
 * cevabıyla yeniden çağırır (tur · eposta · alias · numara).
 */
export type EFaturaHazirlaSonucu = {
  soru?: 'tur' | 'eposta' | 'alias' | 'numara' | null;
  mesaj: string; belgeNo: string; turAdi: string; varsayilan?: string; secenekler?: string[] | null;
};

export type EFaturaHazirlaIstegi = {
  tur?: 'efatura' | 'earsiv'; eposta?: string; alias?: string; ikinciSeri?: boolean; baslangicNo?: number;
};

export type EFaturaMesaji = {
  tarih: string; islem: string; tip: string; mesaj: string; httpKodu: number; servis: string; kullanici: string;
};

export type EFaturaBilgiBaslik = {
  tipi: number; senaryo: number; efaturaDurum: number; tevkifatKodu: number; istisnaKodu: number;
  navlun: number; sigorta: number; sgkTip: string; sgkMukellefKod: string; sgkMukellefAd: string;
  sgkDosyaNo: string; sgkDonemBas?: string | null; sgkDonemBit?: string | null; kamuHesapId?: number | null;
};

export type EFaturaBilgiSatiri = {
  satirId: number; ad: string; gtip: string; teslimSarti: string; tasimaSekli: number;
  kapCinsi: string; kapNo: string; kapAdet: number; kdv: number;
};

type Kod = { deger: number; ad: string };
type MetinKod = { kod: string; ad: string };
export type EFaturaKodlari = {
  tevkifat: Kod[]; istisna: Kod[]; ihracKayitli: Kod[]; teslimSartlari: MetinKod[];
  tasimaSekilleri: Kod[]; kapCinsleri: MetinKod[]; sgkTipleri: MetinKod[];
  hesaplar: { id: number; ad: string; iban: string }[];
};

/** Giden e-Fatura / e-Arşiv (EFaturaUclari). */
export const efaturaUclari = {
  efaturaDurum: (id: number) => istek<EFaturaDurumu>(`/api/efatura/${id}/durum`),
  efaturaHazirla: (id: number, g: EFaturaHazirlaIstegi = {}) =>
    gonder<EFaturaHazirlaSonucu>(`/api/efatura/${id}/hazirla`, g),
  efaturaGonder: (id: number) => gonder<{ mesaj: string }>(`/api/efatura/${id}/gonder`, {}),
  efaturaSifirla: (id: number) => gonder<{ mesaj: string }>(`/api/efatura/${id}/sifirla`, {}),
  efaturaSeriler: (id: number) =>
    istek<{ hazir: boolean; simdiki: string; seriler: string[] }>(`/api/efatura/${id}/seriler`),
  efaturaSeriDegistir: (id: number, seri: string) =>
    gonder<{ mesaj: string }>(`/api/efatura/${id}/seri`, { seri }),
  /** GİB görüntüsü (XSLT). filigran: gönderilmemişse TASLAK (PDF / HTML Kaydet). */
  efaturaHtml: (id: number, filigran = false) =>
    istek<{ html: string; dosyaAdi: string }>(`/api/efatura/${id}/html?filigran=${filigran}`),
  efaturaXml: (id: number) => istek<{ xml: string; dosyaAdi: string }>(`/api/efatura/${id}/xml`),
  efaturaMesajlar: (id: number) => istek<{ mesajlar: EFaturaMesaji[] }>(`/api/efatura/${id}/mesajlar`),
  efaturaBilgi: (id: number) =>
    istek<{ baslik: EFaturaBilgiBaslik; satirlar: EFaturaBilgiSatiri[] }>(`/api/efatura/${id}/bilgi`),
  efaturaBilgiKaydet: (id: number, g: { baslik: Partial<EFaturaBilgiBaslik>; satirlar: Partial<EFaturaBilgiSatiri>[] }) =>
    gonder<{ mesaj: string }>(`/api/efatura/${id}/bilgi`, g, 'PUT'),
  efaturaKodlari: () => istek<EFaturaKodlari>('/api/efatura/kodlar'),
};
