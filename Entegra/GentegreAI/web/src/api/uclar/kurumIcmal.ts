import { istek } from '../cekirdek';

/** Kurum icmali ekranı (KurumIcmalOzetUclari). Rakamlar sunucuda hesaplanır. */
export type KurumOzeti = {
  id: number; ad: string; tur: number; turAdi: string; basvuru: number;
  toplam: number; kurumPayi: number; kesinti: number; net: number;
  /** 0 açık (icmal yok), 1 icmal hazırlandı, 2 faturalandı. */
  icmalDurum: number;
};
export type KurumBasvurusu = {
  id: number; protokolNo: string; tarih: string | null; hasta: string; bolum: string;
  kurumId: number; kurum: string; toplam: number; kurumPayi: number; hastaPayi: number;
  kesinti: number; net: number; kalem: number;
  /** -1 provizyon gerekmez; 0 alınmadı, 1 onay, 2 red, 3 kısmi, 4 iptal. */
  provizyon: number; provizyonNo: string; icmalde: boolean; hastaId: number | null;
};
export type KurumHizmetGrubu = { grup: string; kalem: number; toplam: number; kurumPayi: number; hastaPayi: number };
export type KurumKesintisi = {
  id: number; protokolNo: string; hasta: string; sutKodu: string; kod: string; aciklama: string;
  tutar: number; itirazDurum: number; iade: number;
};
export type KurumDonemIcmali = {
  id: number; kurumId: number; kurum: string; donemBas: string; donemBit: string; durum: number;
  toplam: number; belgeId: number | null; faturaNo: string; faturaTarihi: string | null;
  faturaTutari: number; tahsil: number;
};
export type KurumCariHareketi = { tarih: string | null; belge: string; tur: string; aciklama: string; borc: number; alacak: number };
export type KurumIcmali = {
  donem: { bas: string; bit: string };
  /** Tek kurum seçiliyse onun id'si, değilse 0. */
  kurumId: number; secili: number[];
  ozet: {
    basvuru: number; hasta: number; provizyonlu: number; red: number; kalem: number;
    toplam: number; kurumPayi: number; hastaPayi: number; kesinti: number; kesintiBasvuru: number;
    net: number; faturalanan: number; tahsil: number; acikKurumPayi: number;
  };
  kurumlar: KurumOzeti[]; basvurular: KurumBasvurusu[]; hizmetGruplari: KurumHizmetGrubu[];
  kesintiler: KurumKesintisi[]; icmaller: KurumDonemIcmali[];
  cari: { vkn: string; devreden: number; bakiye: number; hareketler: KurumCariHareketi[] } | null;
};

/** İcmaller sekmesi (ver2): dönemden bağımsız icmal kayıtları. */
export type KurumIcmalKaydi = {
  id: number; kurumId: number; kurum: string; donemBas: string; donemBit: string;
  /** 1 hazırlanıyor, 2 faturalandı (kurum_icmal.durum). */
  durum: number; durumKod: 'hazirlaniyor' | 'faturalandi' | 'tahsil';
  kurumPayi: number; aciklama: string; satir: number; basvuru: number; kesinti: number;
  belgeId?: number | null; faturaNo: string; faturaTarihi?: string | null; faturaTutari: number;
  tahsil: number; vade?: string | null; vadesiGecti: boolean;
};
export type KurumIcmalSatiri = { protokolNo: string; tarih?: string | null; hasta: string; kalem: string; tutar: number };

export const kurumIcmalUclari = {
  kurumIcmali: (kurumlar: number[], bas: string, bit: string) => {
    const q = new URLSearchParams({ bas, bit });
    if (kurumlar.length) q.set('kurumlar', kurumlar.join(','));
    return istek<KurumIcmali>(`/api/kurum-icmal/ozet?${q}`);
  },
  kurumIcmalKayitlari: (kurumlar: number[]) =>
    istek<{ kayitlar: KurumIcmalKaydi[] }>(`/api/kurum-icmal/kayitlar${kurumlar.length ? `?kurumlar=${kurumlar.join(',')}` : ''}`),
  kurumIcmalSatirlari: (id: number) => istek<{ satirlar: KurumIcmalSatiri[] }>(`/api/kurum-icmal/${id}/satirlar`),
};
