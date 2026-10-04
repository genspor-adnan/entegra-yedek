import { gonder, istek } from '../cekirdek';

/**
 * RADYOLOJİ ŞABLON / PROTOKOL TANIM UÇLARI (965, mockup
 * Ekranlar/Radyoloji/radyoloji_sablon_*_v2.html · radyoloji_protokol_*.html).
 */
export interface SablonOzet {
  bolumler: { sira: number; baslik: string; varsayilanMetin: string; zorunlu: number; yazdir: number; bakanlikParca: number }[];
  alanlar: { alanKod: string; alanAd: string; tip: number; hedefBolum: string }[];
  makrolar: { kisayol: string; ad: string }[];
  kullanim: { rapor: number; enCok: string | null } | null;
}
export interface SablonSurumleri {
  guncel: number;
  satirlar: { surum: number; tarih: string | null; kim: string; notu: string; guncel: number; rapor: number }[];
}
export interface SablonKullanim {
  hekimler: { hekim: string; rapor: number; ortDk: number | null; onayli: number }[];
  dagilim: { alan: string; deger: string; adet: number }[];
}
export interface ProtokolOzet {
  protokol: { tetkik: string; seriKodu: string; sureDk: number; kontrast: number; kontrastAjan: string; kontrastDoz: string;
              hazirlikMetni: string; ozelUyari: string; hazirlikOnceDk: number | null };
  seriler: { ad: string; faz: string }[];
  kontroller: { ad: string; kural: string; engel: number }[];
  malzeme: { ad: string; miktar: number | null }[];
  cihazlar: { kod: string; ad: string; sureDk: number | null }[];
}

export interface CihazGostergeYaniti {
  gosterge: { aktif: number; calisiyor: number; bakim: number; ariza: number; qaGecikti: number; baglanti: number };
  konumlar: { oda: string; sayi: number }[];
}
export interface CihazOzet {
  cihaz: { kod: string; ad: string; model: string; oda: string; sorumlu: string; mesai: string; suAn: string; suAnKod: number;
           kapaliBitis: string | null; bugunCekim: number; bugunRandevu: number; sirada: number; qaGecikenAd: string | null;
           goruntuEksik: number };
  saatlik: { saat: number; adet: number }[];
  bosSlot: string | null;
  kapatma: { baslangic: string; bitis: string; nedenTur: number; aciklama: string; etkilenen: number } | null;
  dozUstu: number;
}
export interface CihazKullanim {
  ozet: { cekim: number; randevu: number; gelmediIptal: number; ortSure: number | null; arizaSaat: number | null; haftaKapasite: number | null };
  gunluk: { gun: string; hgun: number; adet: number }[];
}
export interface CihazDoz {
  satirlar: { tetkik: string; adet: number; ctdiOrt: number | null; ctdiHedef: number | null; dlpOrt: number | null;
              dlpHedef: number | null; drl: number | null; drlUstu: number }[];
}

export interface CihazHafta {
  randevulu: boolean; pazartesi?: string; toplam?: number; dolu?: number;
  satirlar: { saat: string; gunler: { tur: 'acik' | 'ogle' | 'kapali' | 'ariza' | 'yok'; kapasite: number; dolu: number; bos: number }[] }[];
}

export const radyolojiTanimUclari = {
  radCihazHafta: (id: number) => istek<CihazHafta>(`/api/radyoloji/cihaz/${id}/hafta`),
  radCihazKapat: (id: number, g: { nedenTur: number; baslangic: string; bitis: string; aciklama?: string }) =>
    gonder<{ id: number; etkilenen: number }>(`/api/radyoloji/cihaz/${id}/kapat`, g),
  radCihazGosterge: () => istek<CihazGostergeYaniti>('/api/radyoloji/cihaz-gosterge'),
  radCihazOzet: (id: number) => istek<CihazOzet>(`/api/radyoloji/cihaz/${id}/ozet`),
  radCihazKullanim: (id: number) => istek<CihazKullanim>(`/api/radyoloji/cihaz/${id}/kullanim`),
  radCihazDoz: (id: number) => istek<CihazDoz>(`/api/radyoloji/cihaz/${id}/doz`),
  radCihazBaglantiTest: (id: number) =>
    gonder<{ acik: boolean; ip: string; port: number; ms: number; hata?: string }>(`/api/radyoloji/cihaz/${id}/baglanti-test`, {}),
  radSablonOzet: (id: number) => istek<SablonOzet>(`/api/radyoloji/sablon/${id}/ozet`),
  radSablonSurumleri: (id: number) => istek<SablonSurumleri>(`/api/radyoloji/sablon/${id}/surumler`),
  radSablonYeniSurum: (id: number, notu: string) => gonder<{ surum: number }>(`/api/radyoloji/sablon/${id}/surum`, { notu }),
  radSablonGeriYukle: (id: number, surum: number) => gonder<unknown>(`/api/radyoloji/sablon/${id}/geri-yukle/${surum}`, {}),
  radSablonKullanim: (id: number) => istek<SablonKullanim>(`/api/radyoloji/sablon/${id}/kullanim`),
  radProtokolOzet: (id: number) => istek<ProtokolOzet>(`/api/radyoloji/protokol/${id}/ozet`),
};
