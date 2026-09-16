import { gonder, istek } from '../cekirdek';

/**
 * MEDULA (SGK) — özel sayfa uçları (707). Her yazma çağrısı bir kuyruk
 * satırıdır; yanıt `kabul · bekliyor · kod · mesaj` taşır. Listeler
 * generic liste/kart üzerinden.
 */

export interface MedulaSonuc {
  kuyrukId: number; kabul: boolean; bekliyor: boolean; kod: string; mesaj: string;
  yanit?: Record<string, unknown> | null;
}

export interface MedulaTakip {
  belgeId: number; belgeNo: string; belgeTarihi: string;
  /** 0 alınmadı · 1 onaylı · 2 red · 3 kısmi · 4 iptal. */
  sgkDurum: number; takipNo: string; provizyonNo: string; takipTuru: number | null; provizyonTipi: number | null;
  sigortaTuru: string; mustehaklik: number; mustehaklikZaman: string | null; takipTarihi: string | null;
  gecerlilik: string | null; redNedeni: string; cikisZaman: string | null; bransKodu: string; hekim: string; bolum: string;
  kabulIslem: number; hataliIslem: number; satirSayisi: number; yerelTutar: number; medulaFaturaNo: string;
  medulaTutar: number | null; faturaDurum: number | null; hataSayisi: number; hekimId: number | null;
}

export interface MedulaHastaOzeti {
  hasta: { id: number; unvan: string; tckn: string; dogumTarihi: string | null; yas: number | null; cinsiyet: number; kurumTur: number | null; kurumAdi: string };
  takipler: MedulaTakip[];
  receteler: { id: number; receteNo: string; tarih: string; durum: number; medulaReceteNo: string; medulaSonuc: string; hekim: string; ilac: number }[];
  raporlar: { id: number; raporTuru: number; raporNo: string; icdKod: string; tani: string; baslangic: string; bitis: string | null; durum: number; medulaSonuc: string }[];
}

export interface MedulaKuyrukSatiri {
  id: number; servis: string; islem: string; kaynakTablo: string; kaynakId: number | null; hasta: string; belgeId: number | null;
  sonucKod: string; sonucMesaj: string; durum: number; deneme: number; sonrakiDeneme: string | null; gonderim: string | null;
  sureMs: number; kullanici: string; zaman: string; hastaId: number | null;
}

export interface MedulaHizmet {
  takip: MedulaTakip; hastaId: number; hasta: string;
  tanilar: { id: number; icdKod: string; ad: string; tur: number; disNo: number | null; muayeneId: number; medulaId: number | null; durum: number; sonucKod: string }[];
  satirlar: { satirId: number; sutKodu: string; islem: string; adet: number; yerelTutar: number; disNo: number | null; tetkik: boolean;
              medulaId: number | null; durum: number; sonucKod: string; sonucMesaj: string; medulaSira: number | null; medulaTutar: number | null; tarih: string | null }[];
  gunluk: MedulaKuyrukSatiri[];
}

export interface MedulaDonemOzeti {
  yil: number; ay: number; esik: number; uyariGun: number;
  ozet: { takip: number; faturali: number; faturaBekleyen: number; hizmetEksik: number; hatali: number; cikissiz: number; yerelTutar: number; medulaTutar: number; farkli: number } | null;
  donem: { id: number; faturaSayisi: number; toplam: number; kesinti: number; odenen: number; odemeTarihi: string | null; sonlandirma: string | null; icmalNo: string; evrakGonderim: string | null; durum: number; aciklama: string } | null;
  donemler: { id: number; yil: number; ay: number; faturaSayisi: number; toplam: number; kesinti: number; odenen: number; odemeTarihi: string | null; sonlandirma: string | null; icmalNo: string; evrakGonderim: string | null; durum: number }[];
  takipler: { belgeId: number; belgeNo: string; tarih: string; hastaId: number; hasta: string; hekim: string; takipNo: string; takipTuru: number | null; cikis: string | null;
              kabulIslem: number; hataliIslem: number; satirSayisi: number; yerelTutar: number; faturaId: number | null; faturaNo: string; medulaTutar: number | null; faturaDurum: number | null; katilim: number | null }[];
  kesintiler: { id: number; faturaId: number; faturaNo: string; hasta: string; takipNo: string; sutKodu: string; kesintiKodu: string; aciklama: string; tutar: number;
                itirazDurum: number; itirazZaman: string | null; sonucZaman: string | null; iadeTutar: number; yil: number | null; ay: number | null }[];
}

export interface MedulaKuyrukOzeti {
  satirlar: MedulaKuyrukSatiri[];
  ozet: { bugun: number; bekleyen: number; hata: number; elle: number; bugunKabul: number; ortMs: number; sonraki: string | null; sonKabul: string | null } | null;
  servisler: { islem: string; cagri: number; kabul: number; hata: number; ortMs: number }[];
  hataKodlari: { kod: string; mesaj: string; adet: number }[];
  hesap: { id: number; tesisKodu: string; kullaniciAdi: string; url: string; testUrl: string; testMi: boolean; sonKullanim: string | null; sonSonuc: string; subeId: number | null } | null;
  ayarlar: { anahtar: string; deger: string; tip: string; aciklama: string }[];
}

const q = (o: Record<string, unknown>) => {
  const p = Object.entries(o).filter(([, v]) => v !== undefined && v !== null && v !== '').map(([k, v]) => `${k}=${encodeURIComponent(String(v))}`);
  return p.length ? '?' + p.join('&') : '';
};

export const medulaUclari = {
  medulaHastaOzeti: (hastaId: number) => istek<MedulaHastaOzeti>(`/api/medula/hasta/${hastaId}/ozet`),
  medulaMustehaklik: (g: { hastaId: number; belgeId?: number | null; provizyonTipi?: number }) => gonder<MedulaSonuc>('/api/medula/mustehaklik', g),
  medulaHastaKabul: (belgeId: number, g: { takipTipi?: number; provizyonTipi?: number; bransKodu?: string; hekimId?: number | null; sevkli?: boolean; sevkKurum?: string }) =>
    gonder<MedulaSonuc>(`/api/medula/basvuru/${belgeId}/hasta-kabul`, g),
  medulaHastaKabulIptal: (belgeId: number) => gonder<MedulaSonuc>(`/api/medula/basvuru/${belgeId}/hasta-kabul-iptal`, {}),
  medulaHastaCikis: (belgeId: number, cikisSekli = 1) => gonder<MedulaSonuc>(`/api/medula/basvuru/${belgeId}/hasta-cikis`, { cikisSekli }),
  medulaTakipAra: (qq: string, sadeceAcik = false) =>
    istek<{ takip: MedulaTakip; hastaId: number; hasta: string }[]>('/api/medula/takip-ara' + q({ q: qq, sadeceAcik: sadeceAcik ? 1 : 0 })),
  medulaHizmet: (belgeId: number) => istek<MedulaHizmet>(`/api/medula/basvuru/${belgeId}/hizmet`),
  medulaHizmetGonder: (belgeId: number, g: { satirIds?: number[]; tanilarDa?: boolean } = {}) =>
    gonder<{ gonderilen: number; kabul: number; hata: number; bekleyen: number }>(`/api/medula/basvuru/${belgeId}/hizmet-gonder`, g),
  medulaIslemIptal: (id: number) => gonder<{ kabul: boolean; kod: string; mesaj: string }>(`/api/medula/islem/${id}/iptal`, {}),
  medulaIslemYerel: (id: number) => gonder<{ durum: number }>(`/api/medula/islem/${id}/yerel`, {}),
  medulaReceteImzala: (id: number) => gonder<{ durum: number; imzaHash: string }>(`/api/medula/recete/${id}/imzala`, {}),
  medulaReceteGonder: (id: number) => gonder<MedulaSonuc>(`/api/medula/recete/${id}/gonder`, {}),
  medulaReceteSil: (id: number) => gonder<MedulaSonuc>(`/api/medula/recete/${id}/sil`, {}),
  medulaRaporGonder: (id: number) => gonder<MedulaSonuc>(`/api/medula/rapor/${id}/gonder`, {}),
  medulaDonem: (yil?: number, ay?: number) => istek<MedulaDonemOzeti>('/api/medula/donem' + q({ yil, ay })),
  medulaFaturaKaydet: (belgeId: number, faturaTuru?: number) => gonder<MedulaSonuc>(`/api/medula/basvuru/${belgeId}/fatura-kaydet`, { faturaTuru }),
  medulaFaturaToplu: (yil: number, ay: number) => gonder<{ denenen: number; kabul: number; hata: number }>('/api/medula/fatura/toplu', { yil, ay }),
  medulaFaturaIptal: (id: number) => gonder<{ kabul: boolean; kod: string; mesaj: string }>(`/api/medula/fatura/${id}/iptal`, {}),
  medulaDonemSonlandir: (yil: number, ay: number) => gonder<MedulaSonuc>(`/api/medula/donem/${yil}/${ay}/sonlandir`, {}),
  medulaKesintiEkle: (g: { medulaFaturaId: number; sutKodu?: string; kesintiKodu?: string; aciklama?: string; tutar: number }) => gonder<{ id: number }>('/api/medula/kesinti', g),
  medulaItiraz: (id: number, metin: string) => gonder<{ itirazDurum: number }>(`/api/medula/kesinti/${id}/itiraz`, { metin }),
  medulaItirazSonuc: (id: number, kabul: boolean, iadeTutar?: number) => gonder<{ itirazDurum: number; iade: number }>(`/api/medula/kesinti/${id}/sonuc`, { kabul, iadeTutar }),
  medulaKuyruk: (durum?: number, qq?: string) => istek<MedulaKuyrukOzeti>('/api/medula/kuyruk' + q({ durum, q: qq })),
  medulaKuyrukGovde: (id: number) => istek<{ istek: string; yanit: string; servis: string; islem: string }>(`/api/medula/kuyruk/${id}/govde`),
  medulaKuyrukGonder: (hatalilarDa = false) => gonder<{ denenen: number; kabul: number; bekleyen: number; hata: number; aciklama: string }>('/api/medula/kuyruk/gonder', { hatalilarDa }),
  medulaKuyrukTekrar: (id: number) => gonder<MedulaSonuc>(`/api/medula/kuyruk/${id}/tekrar`, {}),
  medulaKuyrukIptal: (id: number) => istek<void>(`/api/medula/kuyruk/${id}/iptal`, { method: 'POST' }),
  medulaHesapTest: () => gonder<{ acik: boolean; kod: string; mesaj: string; sureMs: number; simulasyon: boolean }>('/api/medula/hesap/test', {}),
};

export const MEDULA_TAKIP_DURUM: Record<number, [string, string]> = {
  0: ['Provizyon alınmadı', 'gri'], 1: ['Onaylı', 'ok'], 2: ['Reddedildi', 'hata'], 3: ['Kısmi', 'uyari'], 4: ['İptal', 'gri'],
};
export const MEDULA_KUYRUK_DURUM: Record<number, [string, string]> = {
  1: ['Bekliyor', 'gri'], 2: ['Gönderildi', 'mavi'], 3: ['Kabul', 'ok'], 4: ['Hata', 'hata'], 5: ['Elle müdahale', 'uyari'], 6: ['İptal', 'gri'],
};
export const MEDULA_ISLEM_DURUM: Record<number, [string, string]> = {
  0: ['Gönderilmedi', 'gri'], 1: ['Bekliyor', 'gri'], 2: ['Kabul', 'ok'], 3: ['Hata', 'hata'], 4: ['İptal', 'gri'], 5: ['Ücretli (yerel)', 'uyari'],
};
export const MEDULA_FATURA_DURUM: Record<number, [string, string]> = {
  1: ['Taslak', 'gri'], 2: ['Kaydedildi', 'mavi'], 3: ['Dönemde', 'ok'], 4: ['Dönem kapandı', 'ok'], 5: ['İncelendi', 'uyari'], 6: ['Ödendi', 'ok'], 7: ['İptal', 'gri'],
};
export const MEDULA_DONEM_DURUM: Record<number, [string, string]> = {
  1: ['Açık', 'uyari'], 2: ['Sonlandırıldı', 'mavi'], 3: ['İncelemede', 'mavi'], 4: ['Kapandı', 'ok'],
};
export const MEDULA_HATA_ONERI: Record<string, string> = {
  '1006': 'Var olan takibi bağlayın (Takip Ara)', '1013': 'Ücretli / ÖSS başvurusuna geçin', '1020': 'Personel kartı › tescil no',
  '1100': 'Hizmet kartı › SUT kodu', '1101': 'Önce provizyon alın', '1200': 'Önce hasta çıkışı verin', '1201': 'Önce hizmet kaydı gönderin',
  '2001': 'Kapı kapalı - kuyrukta bekler, otomatik tekrar', '3001': 'Reçeteyi imzalayın', '3002': 'Reçeteye ilaç ekleyin', '5001': 'Dönemde fatura yok',
};
