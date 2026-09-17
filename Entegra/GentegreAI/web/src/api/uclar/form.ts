import { TABAN, gonder, istek } from '../cekirdek';

/**
 * FORM MOTORU (740) — şablon tanımı, istek (doldurma), açık (anonim) uçlar.
 * Mockuplar Ekranlar/Formlar/*.html + Ekranlar/ISG/isg_calisan_formu.html.
 */
export type FormAlanTipi = 'metin' | 'uzunmetin' | 'sayi' | 'tarih' | 'secim' | 'coklu' | 'evethayir' | 'onay' | 'olcek' | 'skor' | 'imza' | 'metinblok';
export interface FormSkorSecenek { ad: string; puan: number }
export interface FormSkorSatiri { kod: string; etiket: string; secenek: FormSkorSecenek[] }
export interface FormAlan {
  kod: string; tip: FormAlanTipi; etiket?: string; zorunlu?: boolean;
  secenek?: string[]; satirlar?: FormSkorSatiri[]; max?: number;
  kosul?: { alan: string; deger: unknown }; aciklamaEvetse?: boolean;
  hedefAlan?: string; metin?: string; yardim?: string;
}
export type FormSahip = 'hasta' | 'calisan' | 'hekim' | 'hemsire' | 'anestezi' | 'cerrah';
export interface FormBolum { kod: string; ad: string; sahip: FormSahip; asama?: number; alanlar: FormAlan[] }
export interface FormEsik { min: number; max: number; ad: string; renk?: string; gorev?: string }
export interface FormImzaTanimi { rol: string; yontem: number[]; zorunlu?: boolean; asama?: number }
export interface FormTanimi {
  bolumler: FormBolum[];
  hesap?: { kaynak?: string; ortalama?: boolean; esikler?: FormEsik[] };
  imzalar?: FormImzaTanimi[];
}
export type FormCevap = Record<string, unknown>;
export interface FormImza { rol: string; ad: string; yontem: number; zaman: string; veri?: string; ip?: string }

export interface FormSablonSatiri {
  id: number; kod: string; ad: string; aile: number; aile_adi: string; baglam: number; baglam_adi: string; kanal: number; kanal_adi: string;
  imza_yontem: number; kaynak: string; kaynak_kod: string; kurum_tipleri: string; resmi: number; ust_sablon_id?: number | null; surum: number;
  tanim: FormTanimi; gecerlilik_saat: number; saklama_yil: number; tekrar_saat: number; asamali: number; durum: number; durum_adi: string;
  aciklama: string; kullanim: number; bekleyen: number; resmi_surum: number;
}
export interface FormIstekSatiri {
  id: number; sablon_id: number; sablon_kod: string; sablon_adi: string; aile: number; aile_adi: string; surum: number;
  hasta_id?: number | null; hasta_adi: string; kaynak_tur: number; kaynak_adi: string; kaynak_id?: number | null; kanal: number; kanal_adi: string;
  son_gecerlilik?: string | null; gonderim?: string | null; acilis?: string | null; riza_zamani?: string | null; asama: number;
  skor?: number | null; sonuc: string; tamamlanma?: string | null; dolduran_adi: string; aktarim_zamani?: string | null;
  durum: number; durum_adi: string; imza_sayisi: number; aciklama: string; ekleme_tarihi: string; gonderen_adi: string; suresi_gecti: number;
}
export interface FormIstekKarti {
  istek: FormIstekSatiri; tanim: FormTanimi; taslak: FormCevap; cevap: FormCevap; imzalar: FormImza[];
  imzaYontem: number; asamali: number; parametreler: Record<string, string>;
}
export interface FormKutuphaneSatiri {
  id: number; kod: string; ad: string; aile: number; baglam: number; kanal: number; kaynak: string; kaynakKod: string; kurumTipleri: string;
  surum: number; aciklama: string; tekrarSaat: number; asamali: number; imzaYontem: number;
  kuruluId?: number | null; kuruluSurum?: number | null; kuruluDurum?: number | null; gecerlilikSaat: number; saklamaYil: number;
}
export interface HastaFormlari {
  hasta: { id: number; ad: string; cepTel: string; eposta: string };
  istekler: FormIstekSatiri[];
  sablonlar: { id: number; kod: string; ad: string; aile: number; baglam: number; kanal: number; imzaYontem: number; tekrarSaat: number; asamali: number }[];
}
export interface GonderYaniti { id: number; kod?: string | null; baglanti?: string | null; bildirimId?: number | null }

export const formUclari = {
  formSablon: (id: number) => istek<FormSablonSatiri>(`/api/form/sablon/${id}`),
  formTanimKaydet: (id: number, tanim: FormTanimi, yayinla?: boolean, surumNotu?: string) =>
    gonder<{ id: number; surum: number }>(`/api/form/sablon/${id}/tanim`, { tanim, yayinla, surumNotu }, 'PUT'),
  formSablonKopyala: (id: number) => gonder<{ id: number }>(`/api/form/sablon/${id}/kopyala`, {}),
  formGonder: (g: { sablonKod?: string; sablonId?: number; hastaId: number; kaynakTur?: number; kaynakId?: number | null; kanal?: number; telefon?: string; eposta?: string; gecerlilikSaat?: number; not?: string }) =>
    gonder<GonderYaniti>('/api/form/gonder', g),
  formIstek: (id: number) => istek<FormIstekKarti>(`/api/form/istek/${id}`),
  formCevap: (id: number, g: { cevap: FormCevap; imzalar?: FormImza[]; tamamla?: boolean }) =>
    gonder<{ id: number; durum: number; asama: number; skor?: number | null; sonuc: string }>(`/api/form/istek/${id}/cevap`, g, 'PUT'),
  formHatirlat: (id: number) => gonder<{ bildirimId: number }>(`/api/form/istek/${id}/hatirlat`, {}),
  formYeniden: (id: number) => gonder<GonderYaniti>(`/api/form/istek/${id}/yeniden`, {}),
  formIptal: (id: number) => gonder<{ id: number; durum: number }>(`/api/form/istek/${id}/iptal`, {}),
  formAktar: (id: number) => gonder<{ yazilan: string[]; atlanan: string[] }>(`/api/form/istek/${id}/aktar`, {}),
  hastaFormlari: (hastaId: number, kaynakTur?: number, kaynakId?: number) =>
    istek<HastaFormlari>(`/api/form/hasta/${hastaId}${kaynakTur ? `?kaynakTur=${kaynakTur}&kaynakId=${kaynakId ?? ''}` : ''}`),
  formKutuphane: () => istek<{ kurumTipi: string; liste: FormKutuphaneSatiri[] }>('/api/form/kutuphane'),
  formKutuphaneKur: (kodlar: string[]) => gonder<{ kurulan: string[]; guncellenen: string[] }>('/api/form/kutuphane/kur', { kodlar }),
};

// ---------------------------------------------------------------- açık ----
/** Anonim uçlar: token yok, `/f/{kod}` sayfası. Hata gövdesi {hata:{mesaj}}. */
async function acik<T>(yol: string, govde?: unknown): Promise<T> {
  const y = await fetch(`${TABAN}/api/acik/form/${yol}`, {
    method: govde === undefined ? 'GET' : 'POST',
    headers: { 'content-type': 'application/json' },
    body: govde === undefined ? undefined : JSON.stringify(govde),
  });
  const metin = await y.text();
  let veri: unknown = null;
  try { veri = metin ? JSON.parse(metin) : null } catch { veri = null }
  if (!y.ok) {
    const h = (veri as { hata?: { mesaj?: string } } | null)?.hata;
    throw new Error(h?.mesaj ?? `Sunucu hatası (${y.status})`);
  }
  return veri as T;
}
export interface AcikOzet { gecerli: boolean; neden?: string; form?: string; aile?: number; kurum?: string; hasta?: string; gonderim?: string; son?: string; dogrulamaGerekli?: boolean; kalanDeneme?: number }
export interface AcikOturum { oturum: string; dakika: number; form: string; aile: number; kurum: string; hasta: string; tanim: FormTanimi; taslak: FormCevap; parametreler: Record<string, string>; rizaVar: boolean }
export const formAcik = {
  ozet: (kod: string) => acik<AcikOzet>(kod),
  dogrula: (kod: string, tcknSon4: string, dogumYili: string) => acik<AcikOturum>(`${kod}/dogrula`, { tcknSon4, dogumYili }),
  taslak: (kod: string, oturum: string, taslak: FormCevap) => acik<{ kaydedildi: string }>(`${kod}/taslak`, { oturum, taslak }),
  gonder: (kod: string, oturum: string, cevap: FormCevap, imzalar?: FormImza[]) =>
    acik<{ durum: number; tamamlanma?: string; skor?: number | null; sonuc?: string }>(`${kod}/gonder`, { oturum, cevap, imzalar, riza: true }),
  reddet: (kod: string, oturum: string) => acik<{ durum: number }>(`${kod}/gonder`, { oturum, reddetti: true }),
};
