import { gonder, istek } from '../cekirdek';

/**
 * ÇAĞRI MERKEZİ (839) — operatör panosu, arayan tanıma, çağrı akışı, çağrı
 * kartı, geri arama listesi, kampanya, süpervizör, santral ayarı. Alan adları
 * sunucu görünümleriyle birebir (v_cagri, v_cagri_agent, v_cagri_kuyruk...).
 */
export interface CagriSatiri {
  id: number; kanal: number; kanal_adi: string; yon: number; yon_adi: string; arayan_no: string; aranan_no: string;
  taraf_id?: number | null; taraf_adi: string; hasta: number; musteri: number; personel: number;
  kuyruk_id?: number | null; kuyruk_adi: string; agent_id?: number | null; agent_adi: string; dis_ref: string;
  baslama: string; cevap?: string | null; bitis?: string | null; bekleme_sn: number; sure_sn: number; islem_sonrasi_sn: number;
  konu_id?: number | null; konu_adi: string; alt_konu_id?: number | null; alt_konu_adi: string; sonuc: number; sonuc_adi: string;
  oncelik: number; notu: string; kayit_url: string; durum: number; durum_adi: string; kampanya_id?: number | null; kampanya_adi: string;
  kampanya_kisi_id?: number | null; geri_arama?: string | null; geri_arama_tamam: number; gorev_id?: number | null; memnuniyet: number;
  kalite_puan?: number | null; sla_icinde: number; ilgili_sayisi: number; sube_id: number;
}
export interface CagriAgentSatiri {
  id: number; kullanici_id: number; agent_adi: string; dahili: string; softphone: number; softphone_adi: string; kuyruklar: string; kuyruk_adlari?: string | null;
  durum: number; durum_adi: string; durum_zaman: string; durum_sn: number; mola_sebep: number; aktif: number; aktif_adi: string;
  cagri_bugun: number; ort_sure_sn: number; aktif_cagri_id?: number | null;
}
export interface CagriKuyrukSatiri {
  id: number; ad: string; santral_kodu: string; beceri: string; sla_sn: number; sla_hedef: number; max_bekleme_sn: number; tasma_kuyruk_id?: number | null; tasma_adi: string;
  bekleme_mesaji: string; kanal: number; kanal_adi: string; sira: number; aktif: number; aktif_adi: string; bekleyen: number; en_uzun_bekleme_sn: number;
  hazir_agent: number; cevaplanan_bugun: number; kacan_bugun: number; agent_sayisi: number;
}
export interface CagriKonuSatiri {
  id: number; ust_id?: number | null; ust_adi: string; ad: string; tam_ad: string; sla_dk: number; hizli_islem: number; hizli_islem_adi?: string | null;
  sonuclar: string; betik: string; sira: number; aktif: number; alt_sayisi: number; cagri_30g: number;
}
export interface CagriPano {
  agent: CagriAgentSatiri | null; kuyruklar: CagriKuyrukSatiri[]; bekleyen: CagriSatiri[]; bugun: CagriSatiri[]; aktif: CagriSatiri | null;
  ozet: { cagri: number; ortSureSn: number; kacan: number; bekleyen: number; gunCevaplanan: number; gunSla: number };
  konular: CagriKonuSatiri[];
}
export interface ArayanAdayi { taraf_id: number; ad: string; hasta: number; musteri: number; personel: number; kurum: number; cep_tel: string; telefon: string; son_cagri?: string | null }
export interface KisiOzeti {
  tarafId: number; ad: string; kod: string; tckn: string; cepTel: string; telefon: string; hasta: number; musteri: number; personel: number; kurum: number;
  dogumTarihi?: string | null; cinsiyet?: number | null; sonZiyaret: string; yaklasanRandevu?: { id: number; metin: string } | null;
  bekleyenSonuc: number; hazirSonuc: number; bakiye: number; acikGorev: number;
}
export interface ArayanYaniti { adaylar: ArayanAdayi[]; tarafId?: number | null; ozet: KisiOzeti | null; sonCagrilar: CagriSatiri[] }
export interface CagriOlay { id: number; tur: number; turAdi: string; zaman: string; agentId?: number | null; agentAdi: string; aciklama: string }
export interface CagriIlgili { id: number; kaynakTur: string; kaynakId: number; aciklama: string; zaman: string }
export interface CagriKalite { id: number; cagri_id: number; puan: number; olcutler: string; notu: string; ozet_ai: string; transkript: string; degerlendiren_adi: string; ekleme_tarihi: string }
export interface CagriKart { cagri: CagriSatiri; olaylar: CagriOlay[]; ilgili: CagriIlgili[]; kalite: CagriKalite | null; gecmis: CagriSatiri[]; ozet: KisiOzeti | null }
export interface KapatIstegi {
  konuId: number; altKonuId?: number | null; sonuc: number; notu?: string; oncelik?: number; tarafId?: number | null;
  geriArama?: string | null; gorevKonu?: string | null; memnuniyet?: number | null;
}
export interface GeriAramaSatiri {
  kaynak: 'soz' | 'kacan' | 'kampanya'; kaynakAdi: string; cagriId?: number | null; kisiId?: number | null; kampanyaId?: number | null; tarafId?: number | null; ad: string; telefon: string;
  konu: string; notu: string; zaman: string; agentId?: number | null; agentAdi: string; gecikmis: number; gorevId?: number | null;
}
export interface GeriAramaYaniti { ozet: { aranacak: number; arandi: number; ulasilamadi: number; soz: number; kacan: number }; satirlar: GeriAramaSatiri[] }
export interface KampanyaSatiri {
  id: number; ad: string; tur: number; tur_adi: string; kaynak: string; parametre: string; sablon_kodu: string; kuyruk_id?: number | null; kuyruk_adi: string;
  ikinci_adim_dk: number; deneme: number; deneme_ara_dk: number; zamanlama: string; baslama?: string | null; bitis?: string | null; durum: number; durum_adi: string;
  aciklama: string; hedef: number; ulasilan: number; basarili: number; bekleyen: number;
}
export interface KampanyaKisiSatiri {
  id: number; kampanya_id: number; kampanya_adi: string; taraf_id?: number | null; ad: string; telefon: string; kaynak_tur: string; kaynak_id: number; ozet: string;
  durum: number; durum_adi: string; deneme: number; son_deneme?: string | null; bildirim_id?: number | null; bildirim_durum: number; cagri_id?: number | null; sonuc: string; aranacak: number;
}
export interface Supervizor {
  kpi: { bekleyen: number; enUzunBeklemeSn: number; gelen: number; cevaplanan: number; kacan: number; slaIcinde: number; ortKonusmaSn: number; memnuniyet: number; whatsappAcik: number };
  agentlar: CagriAgentSatiri[];
  kuyruklar: { id: number; ad: string; bekleyen: number; enUzunSn: number; hazirAgent: number; cevaplanan: number; kacan: number; slaSn: number; slaHedef: number; tasmaAdi: string; slaYuzde: number; ortBeklemeSn: number; ortKonusmaSn: number }[];
  saatlik: { saat: number; gelen: number; kacan: number }[];
  konular: { konu: string; bugun: number; hafta: number; cozum: number; geriArama: number; gorev: number; ortSureSn: number }[];
  kalite: { hafta: string; sayi: number; ortPuan: number; enDusuk: number }[];
  aktif: CagriSatiri[];
  agentGun: { agentId: number; ad: string; cagri: number; cevaplanan: number; ortKonusmaSn: number; ortIslemSn: number; randevu: number; geriArama: number; gorev: number; kalite?: number | null }[];
}
export interface IvrDali { tus: string; ad: string; kuyruk?: string; hedef?: string; self?: string; anons?: string }
export interface CalismaSaati { gun: string; bas: string; bit: string }
export interface SantralAyar {
  subeId: number; saglayici: string; apiAdres: string; kimlik: string; gizliVar: boolean; webhookAnahtar: string; kayitKaynak: string; kvkkAnons: number; kayitSaklamaAy: number;
  ivr: IvrDali[]; calisma: CalismaSaati[]; mesaiDisiMesaj: string; whatsappNo: string; whatsappTokenVar: boolean; botIlkYanit: string; epostaAdres: string; islemSonrasiSn: number;
  durum: number; sonOlay?: string | null;
}
export interface SantralYaniti { ayar: SantralAyar; agentlar: CagriAgentSatiri[]; kuyruklar: CagriKuyrukSatiri[]; webhookUrl: string }

export const cagriUclari = {
  cagriPano: () => istek<CagriPano>('/api/cagri/pano'),
  cagriAgentDurum: (durum: number, molaSebep?: number) => gonder<{ durum: number }>('/api/cagri/agent/durum', { durum, molaSebep }),
  cagriArayan: (telefon?: string, tarafId?: number) => {
    const q = new URLSearchParams(); if (telefon) q.set('telefon', telefon); if (tarafId) q.set('tarafId', String(tarafId));
    return istek<ArayanYaniti>(`/api/cagri/arayan?${q}`);
  },
  cagriBaslat: (g: { kanal?: number; yon?: number; arayanNo?: string; tarafId?: number | null; kuyrukId?: number | null; kampanyaKisiId?: number | null }) =>
    gonder<{ id: number; tarafId?: number | null }>('/api/cagri/baslat', g),
  cagriUstlen: (id: number) => gonder<{ id: number }>(`/api/cagri/${id}/ustlen`, {}),
  cagriKapat: (id: number, g: KapatIstegi) => gonder<{ id: number; gorevId?: number | null; durum: number }>(`/api/cagri/${id}/kapat`, g),
  cagriIlgili: (id: number, g: { kaynakTur: string; kaynakId: number; aciklama?: string }) => gonder<{ id: number }>(`/api/cagri/${id}/ilgili`, g),
  cagriNot: (id: number, metin: string) => gonder<{ id: number }>(`/api/cagri/${id}/not`, { metin }),
  cagriMesaj: (id: number, g: { sablon: 'odeme_linki' | 'yol_tarifi' | 'anket' | 'geri_arama'; telefon?: string; tutar?: string; baglanti?: string; saat?: string }) =>
    gonder<{ bildirimId?: number | null }>(`/api/cagri/${id}/mesaj`, g),
  cagriKart: (id: number) => istek<CagriKart>(`/api/cagri/${id}`),
  cagriKalite: (id: number, g: { puan: number; olcutler: unknown; notu?: string }) => gonder<{ id: number; puan: number }>(`/api/cagri/${id}/kalite`, g),
  cagriOzet: (id: number) => gonder<{ ozet: string; kaynak: string }>(`/api/cagri/${id}/ozet`, {}),
  cagriGeriArama: (tur: 'bugun' | 'gecikmis' | 'benim' | 'tumu' = 'bugun') => istek<GeriAramaYaniti>(`/api/cagri/geri-arama?tur=${tur}`),
  cagriGeriAramaTamam: (cagriId: number) => gonder<{ cagriId: number }>(`/api/cagri/geri-arama/${cagriId}/tamam`, {}),
  cagriKampanyalar: () => istek<KampanyaSatiri[]>('/api/cagri/kampanyalar'),
  cagriKampanya: (id: number) => istek<{ kampanya: KampanyaSatiri; kisiler: KampanyaKisiSatiri[] }>(`/api/cagri/kampanya/${id}`),
  cagriKampanyaUret: (id: number) => gonder<{ eklenen: number; atlanan: number; not_: string }>(`/api/cagri/kampanya/${id}/uret`, {}),
  cagriKampanyaCalistir: (id: number) => gonder<{ gonderilen: number; hata: number; dogrudanArama: boolean }>(`/api/cagri/kampanya/${id}/calistir`, {}),
  cagriKampanyaDurdur: (id: number) => gonder<{ id: number }>(`/api/cagri/kampanya/${id}/durdur`, {}),
  cagriKisiSonuc: (id: number, g: { durum: number; sonuc?: string; cagriId?: number | null }) => gonder<{ id: number }>(`/api/cagri/kampanya-kisi/${id}/sonuc`, g),
  cagriSupervizor: () => istek<Supervizor>('/api/cagri/supervizor'),
  cagriSupervizorAgent: (kullaniciId: number, g: { durum?: number; kuyrukId?: number }) => gonder<{ kullaniciId: number }>(`/api/cagri/supervizor/agent/${kullaniciId}`, g),
  cagriSantral: () => istek<SantralYaniti>('/api/cagri/santral'),
  cagriSantralKaydet: (g: Partial<Omit<SantralAyar, 'gizliVar' | 'whatsappTokenVar' | 'durum' | 'sonOlay' | 'subeId'>> & { gizli?: string; whatsappToken?: string }) =>
    gonder<{ subeId: number }>('/api/cagri/santral', g),
  cagriSantralSina: () => gonder<{ bagli: boolean; eksik: string[]; sonOlay?: string | null; not_: string }>('/api/cagri/santral/sina', {}),
  cagriSantralAnahtar: () => gonder<{ webhookAnahtar: string }>('/api/cagri/santral/anahtar-yenile', {}),
};
