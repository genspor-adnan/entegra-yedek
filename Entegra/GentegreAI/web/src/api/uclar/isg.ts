import { gonder, istek } from '../cekirdek';
import type { FormIstekSatiri } from './form';

/**
 * İŞYERİ HEKİMLİĞİ (741) — pano, firma kartı, çalışan kartı, Ek-2 muayene
 * açma/işleme, periyodik takvim, toplu gönderim, olay SGK bildirimi.
 */
export interface IsgFirmaSatiri {
  id: number; taraf_id: number; firma_adi: string; firma_kodu: string; sgk_sicil: string; nace: string; nace_ad: string;
  tehlike: number; tehlike_adi: string; calisan_sayisi: number; aktif_calisan: number;
  hekim_id?: number | null; hekim_adi: string; isg_uzman_id?: number | null; isg_uzman_adi: string; dsp_id?: number | null; dsp_adi: string;
  plan_dk: number; aylik_dk: number; sozlesme_bas?: string | null; sozlesme_bit?: string | null; ziyaret_sikligi: string;
  calisma: number; gece_calisan: number; isg_kurulu: number; yetkili: string; yetkili_tel: string; adres: string; aciklama: string;
  durum: number; durum_adi: string; kaza_yil: number; vade_yaklasan: number; ziyaret_dk_ay: number; muayene_dk_ay: number;
}
export interface IsgCalisanSatiri {
  id: number; hasta_id: number; calisan_adi: string; tckn: string; cep_tel: string; dogum_tarihi?: string | null; cinsiyet?: number | null;
  firma_id: number; firma_adi: string; tehlike: number; tehlike_adi: string; bolum_id?: number | null; bolum_adi: string; gorev: string;
  ise_giris?: string | null; isten_ayrilis?: string | null; calisma: number; calisma_adi: string; maruziyet: number[]; bolum_maruziyet: number[];
  tetkik_paketi: string; meslek_oykusu: string; kkd: string; egitim: string; riza_tarihi?: string | null; periyot_ay: number; periyot_hesap: number;
  son_muayene?: string | null; son_muayene_tur?: number | null; son_kanaat?: number | null; son_kanaat_adi?: string | null; son_kosul?: string | null; hekim_sonraki?: string | null;
  vade: string; kalan_gun: number; muayene_sayisi: number; olay_sayisi: number; acik_muayene: number; aciklama: string; durum: number; durum_adi: string;
}
export interface IsgMuayeneSatiri {
  id: number; calisan_id: number; hasta_id: number; calisan_adi: string; firma_id: number; firma_adi: string; bolum_adi: string; gorev: string;
  tur: number; tur_adi: string; tarih: string; hekim_id?: number | null; hekim_adi: string; muayene_id?: number | null; form_istek_id?: number | null;
  form_durum?: number | null; form_durum_adi?: string | null; kanaat: number; kanaat_adi?: string | null; kosul: string; tani: string; sevk: number;
  sonraki_tarih?: string | null; isveren_bildirim?: string | null; tetkik_ozet: string; sure_dk: number; durum: number; durum_adi: string; aciklama: string;
}
export interface IsgOlaySatiri {
  id: number; firma_id: number; firma_adi: string; calisan_id?: number | null; calisan_adi: string; tur: number; tur_adi: string; tarih: string; yer: string;
  aciklama: string; yaralanma: string; ilk_mudahale: string; gun_kaybi: number; taniklar: string; sgk_bildirim?: string | null; kok_neden: string; duzeltici: string;
  sgk_kalan_gun?: number | null; sgk_gecikti: number; durum: number; durum_adi: string;
}
export interface IsgZiyaretSatiri {
  id: number; firma_id: number; firma_adi: string; tarih: string; saat_bas: string; saat_bit: string; sure_dk: number; tur: number; tur_adi: string;
  hekim_adi: string; katilanlar: string; bolumler: string; gozlem: string; oneri: string; termin?: string | null; sorumlu: string; egitim: string;
  defter_sayfa: string; imza_sayisi: number; sonraki_ziyaret?: string | null; termin_gecti: number;
}
export interface IsgAsiSatiri { id: number; calisan_id: number; asi: number; asi_adi: string; doz: string; tarih: string; sonraki?: string | null; aciklama: string; vadesi_gecti: number }
export interface IsgPano {
  ozet: { firma: number; calisan: number; vadeGelen: number; vadeGecen: number; kazaAy: number; sgkGeciken: number; acikMuayene: number; planDk: number; gercekDk: number };
  firmalar: IsgFirmaSatiri[];
}
export interface IsgFirmaKarti {
  firma: IsgFirmaSatiri;
  bolumler: { id: number; ad: string; calisanSayisi: number; maruziyet: number[]; tetkikPaketi: string; periyotAy: number; aktif: number; vadeGecen: number }[];
  aylar: { ay: string; muayeneDk: number; ziyaretDk: number; egitimDk: number; kurulDk: number; muayene: number }[];
  ozet: { muayene: number; calisir: number; kosullu: number; calisamaz: number; vadeGecen: number; kaza: number; meslekHastaligi: number; terminGecen: number };
  ziyaretler: IsgZiyaretSatiri[];
}
export interface IsgCalisanKarti {
  calisan: IsgCalisanSatiri; muayeneler: IsgMuayeneSatiri[]; asilar: IsgAsiSatiri[]; olaylar: IsgOlaySatiri[]; formlar: FormIstekSatiri[];
  tibbi: { alerji: string; kronik: string; ilac: string }; maruziyetAdlari: { kod: number; ad: string }[];
}
export interface IsgTakvim { gecen: number; aylar: { ay: string; sayi: number }[]; satirlar: IsgCalisanSatiri[] }
export interface MuayeneAcYaniti { id: number; formIstekId?: number | null; kod?: string | null; baglanti?: string | null; bildirimId?: number | null; mevcut: boolean }

export const isgUclari = {
  isgPano: (hekimId?: number) => istek<IsgPano>(`/api/isg/pano${hekimId ? `?hekimId=${hekimId}` : ''}`),
  isgFirmaKart: (id: number) => istek<IsgFirmaKarti>(`/api/isg/firma/${id}`),
  isgCalisanKart: (id: number) => istek<IsgCalisanKarti>(`/api/isg/calisan/${id}`),
  isgMuayeneAc: (calisanId: number, g: { tur?: number; kanal?: number; hekimId?: number | null; telefon?: string } = {}) =>
    gonder<MuayeneAcYaniti>(`/api/isg/calisan/${calisanId}/muayene-ac`, g),
  isgMuayeneIsle: (id: number) => gonder<{ muayeneId: number; kanaat: number; kanaatMetin: string }>(`/api/isg/muayene/${id}/isle`, {}),
  isgMuayeneIptal: (id: number) => gonder<{ id: number; durum: number }>(`/api/isg/muayene/${id}/iptal`, {}),
  isgTakvim: (g: { firmaId?: number; bolumId?: number; gun?: number; tur?: string } = {}) => {
    const q = new URLSearchParams();
    if (g.firmaId) q.set('firmaId', String(g.firmaId)); if (g.bolumId) q.set('bolumId', String(g.bolumId));
    if (g.gun) q.set('gun', String(g.gun)); if (g.tur) q.set('tur', g.tur);
    return istek<IsgTakvim>(`/api/isg/takvim?${q}`);
  },
  isgToplu: (calisanIds: number[], tur?: number, kanal?: number) => gonder<{ acilan: number; hatalar: string[] }>('/api/isg/takvim/toplu', { calisanIds, tur, kanal }),
  isgOlaySgk: (id: number, tarih?: string) => gonder<{ id: number }>(`/api/isg/olay/${id}/sgk`, { tarih }),
  isgOlayKapat: (id: number) => gonder<{ id: number }>(`/api/isg/olay/${id}/kapat`, {}),
};
