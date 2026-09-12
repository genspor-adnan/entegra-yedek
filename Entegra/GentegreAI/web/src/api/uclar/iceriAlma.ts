import { istek, gonder, dosyaYukle } from '../cekirdek';

/** Sihirbazin hedef listesi - alanlar sunucudaki KART TANIMINDAN gelir (548). */
export interface IceriAlmaAlani {
  ad: string; baslik: string; tip: string; zorunlu: boolean; anahtar: boolean;
}
export interface IceriAlmaHedefi {
  ad: string; baslik: string; ikon: string;
  /** kart · fiyat-listesi · belge - sihirbazin hangi ek soruyu soracagini belirler. */
  tur: string;
  /** Fiyat listesi hedefinde hangi listeye yazilacagi sorulur (548). */
  listeGerekli: boolean;
  anahtarlar: string[]; alanlar: IceriAlmaAlani[];
}
export interface EslemeSatiri {
  kolon: string; alan: string; guven: number; ornek: string;
}
export interface CozumSonucu {
  dosyaAdi: string;
  basliklar: string[];
  satirSayisi: number;
  baslikImzasi: string;
  kural: { id: number; ad: string } | null;
  esleme: EslemeSatiri[];
  ornekler: { satirNo: number; hucreler: Record<string, string> }[];
}
export interface OnizlemeSatiri {
  satirNo: number; durum: 'yeni' | 'degisecek' | 'sorunlu';
  anahtar: string; ozet: string; not: string;
}
export interface OnizlemeSonucu {
  toplam: number; yeni: number; degisecek: number; sorunlu: number;
  satirlar: OnizlemeSatiri[];
}
export interface YuklemeKaydi {
  id: number; hedef: string; dosyaAdi: string; satirSayisi: number;
  eklenen: number; guncellenen: number; atlanan: number; durum: number;
  mesaj: string; tarih: string; kullanici: string;
}
export interface EslemeKurali {
  id: number; ad: string; hedef: string; basliklar: string;
  alanSayisi: number; aktif: number; sonKullanim: string | null; tarih: string;
}

/** Dosya her adimda yeniden gonderilir - sunucuda gecici dosya deposu yok. */
function form(dosya: File, hedef: string,
              esleme?: Record<string, string>, sayiBicimi?: string, listeId?: number) {
  const f = new FormData();
  f.append('dosya', dosya);
  f.append('hedef', hedef);
  if (esleme) f.append('esleme', JSON.stringify(esleme));
  if (sayiBicimi) f.append('sayiBicimi', sayiBicimi);
  if (listeId) f.append('listeId', String(listeId));
  return f;
}

/** Excel'den içeri alma (548) - Ayarlar › Veri Aktarımı. */
export const iceriAlmaUclari = {
  iceriAlmaHedefleri: () =>
    istek<{ hedefler: IceriAlmaHedefi[] }>('/api/iceri-alma/hedefler')
      .then(y => y.hedefler),

  /** Adim 1: dosyayi coz, esleme onerisini al. */
  iceriAlmaCoz: (dosya: File, hedef: string) =>
    dosyaYukle<CozumSonucu>('/api/iceri-alma/coz', form(dosya, hedef)),

  /** Adim 3: hicbir sey yazilmaz - satir satir durum. */
  iceriAlmaOnizle: (dosya: File, hedef: string,
                    esleme: Record<string, string>, sayiBicimi: string, listeId?: number) =>
    dosyaYukle<OnizlemeSonucu>('/api/iceri-alma/onizle',
                               form(dosya, hedef, esleme, sayiBicimi, listeId)),

  /** Adim 4: yaz. Kart ve fiyat listesi TEK islemde; faturada atom birimi
      her bir FATURADIR (belge yazma kendi islemini acar). */
  iceriAlmaUygula: (dosya: File, hedef: string,
                    esleme: Record<string, string>, sayiBicimi: string, listeId?: number) =>
    dosyaYukle<{ yuklemeNo: number; eklenen: number; guncellenen: number;
                 atlanan: number; toplam: number; mesaj: string }>(
      '/api/iceri-alma/uygula', form(dosya, hedef, esleme, sayiBicimi, listeId)),

  iceriAlmaGecmisi: (limit = 50) =>
    istek<{ kayitlar: YuklemeKaydi[] }>(`/api/iceri-alma/gecmis?limit=${limit}`)
      .then(y => y.kayitlar),

  iceriAlmaKurallari: () =>
    istek<{ kurallar: EslemeKurali[] }>('/api/iceri-alma/kurallar')
      .then(y => y.kurallar),

  iceriAlmaKuralYaz: (govde: { ad: string; hedef: string; baslikImzasi: string;
                               esleme: Record<string, string> }) =>
    gonder<{ id: number; mesaj: string }>('/api/iceri-alma/kural', govde),

  iceriAlmaKuralSil: (id: number) =>
    gonder<{ id: number }>(`/api/iceri-alma/kural/${id}`, {}, 'DELETE'),
};
