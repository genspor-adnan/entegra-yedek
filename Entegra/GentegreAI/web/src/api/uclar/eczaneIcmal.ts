import { istek } from '../cekirdek';

/** Servis / dönem toplamı (EczaneIcmalUclari.Topla). */
export type EczaneTopla = {
  hasta: number; kalem: number; miktar: number; maliyet: number; faturalanan: number; faturalanmayan: number;
  faturalanmayanAdet: number; kacakOrani?: number | null; hastaBasi: number;
};

/** Eczane / ilaç tüketim icmali (EczaneIcmalUclari). Rakamlar ve toplamlar sunucuda hesaplanır. */
export type EczaneIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    cikis: number; kalem: number; ilac: number; servis: number; maliyet: number; faturalanan: number; faturaAdetOrani?: number | null;
    faturalanmayan: number; faturalanmayanAdet: number; faturalanmayanKayit: number; eslesmeyen: number; hasta: number; hastaBasi: number;
    miadDolmus: number; miad30: number; miad90: number; miadDolmusTutar: number; miad30Tutar: number; miadTutar: number;
    itsBildirim: number; itsHatali: number; itsBekleyen: number; itsBasarili: number; itsBasari?: number | null;
    iade: number; iadeAdet: number; iadeKayit: number; imha: number; imhaTutanak: number; bugun: string;
  };
  toplam: EczaneTopla;
  servisler: { id: number; ad: string; ozet: EczaneTopla; iade: number; pay?: number | null; maliyet: number;
               enCok: { ad: string; miktar: number; maliyet: number }[] }[];
  ilaclar: { stokId: number; ad: string; etken: string; servis: number; miktar: number; birimMaliyet: number; maliyet: number;
             faturalanan: number; faturalanmayan: number; faturalanmayanAdet: number; eslesmez: boolean }[];
  ilacToplam: { miktar: number; maliyet: number; faturalanan: number; faturalanmayan: number };
  faturasiz: { tarih?: string | null; protokol: string; servis: string; ilac: string; adet: number; uygulanan: number; faturada: number;
               tutar: number; fiyatYok: boolean; kaynak: string; belgeId: number; neden: string }[];
  miad: { ad: string; lot: string; depo: string; skt: string; kalanGun: number; miktar: number; tutar: number; gunluk: number;
          durum: 'dolmuş' | '30' | '90'; tuketilir: boolean }[];
  iadeler: { tarih: string; servis: string; ilac: string; miktar: number; tutar: number; karar: string; kararKod: number; gerekce: string }[];
  itsOzet: { tur: string; bildirim: number; basarili: number; hatali: number; bekleyen: number; basari?: number | null }[];
  itsHatali: { id: number; tarih: string; tur: string; protokol: string; ilac: string; seri: string; kalem: number; hataKodu: string;
               mesaj: string; sinif: string; deneme: number }[];
  servisAdlari: { id: number; ad: string }[];
  depoAdlari: { id: number; ad: string }[];
};

export const eczaneIcmalUclari = {
  eczaneIcmali: (bas: string, bit: string, servis: number, depo: number) => {
    const q = new URLSearchParams({ bas, bit });
    if (servis) q.set('servis', String(servis));
    if (depo) q.set('depo', String(depo));
    return istek<EczaneIcmali>(`/api/eczane-icmal?${q}`);
  },
};
