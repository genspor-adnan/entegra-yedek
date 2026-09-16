import { gonder, istek } from '../cekirdek';

/**
 * DİŞ KLİNİĞİ — liste/kart dışı uçlar (706). Hasta kartı tek soruda
 * (odontogram + plan + geçmiş + lab), günlük akış, plan satırı yazımları,
 * seans açma/bitirme, lab aşaması. Sıradan CRUD/listeler generic
 * `liste.ts` / `kart.ts` üzerinden gider.
 */

/** Odontogram satırı: diş × yüzey × durum × katman (1 mevcut · 2 planlanan · 3 tamamlanan). */
export interface DisOdontogramSatiri {
  id: number; disNo: number; yuzeyler: string; durumKod: number; katman: number;
  kaynak: number; tarih: string; planSatirId: number | null; notMetin: string; dentisyon: number;
}

export interface DisPlanSatiri {
  id: number; faz: number; sira: number; disNo: number; disNolar: string; yuzeyler: string;
  hizmetId: number; islem: string; hekim: string; seansSayisi: number; yapilanSeans: number;
  listeFiyat: number; iskonto: number; net: number; ucretKurali: number; labGerekir: boolean;
  labIsemriId: number | null;
  /** 1 planlı · 2 sürüyor · 3 yapıldı · 4 iptal · 5 ertelendi. */
  durum: number; tamamlanma: string | null; aciklama: string;
  ilkSeans: string | null; randevu: string | null;
}

export interface DisPlanOzeti {
  id: number; planNo: string; durum: number; varyant: string; toplam: number; indirim: number;
  net: number; hekim: string; tarih: string; hastaOnayZamani: string | null; proformaNo: string;
  gecerlilikBitis: string | null; fiyatListesiId: number | null; yapilan: number; tahsil: number;
  satirSayisi: number; yapilanSayisi: number; odemePlaniId: number | null; oncekiPlanNo: string;
}

/** Tedavi planı kartı (710) — mockup dis_tedavi_plani_karti.html; tek soruda tüm sekmeler. */
export interface DisPlanKartVerisi {
  plan: {
    id: number; planNo: string; hastaId: number; hasta: string; tckn: string; yas: number | null; cinsiyet: number;
    hekimId: number | null; hekim: string; muayeneId: number | null; muayeneTarih: string | null;
    varyant: string; anaPlanId: number | null; anaPlanNo: string; durum: number;
    fiyatListesiId: number | null; fiyatListesi: string; odeyenKurumId: number | null; odeyenKurum: string;
    toplam: number; indirim: number; net: number; odemeSecenegi: string; taksitSayisi: number; proformaNo: string;
    gecerlilikBitis: string | null; hastaOnayZamani: string | null; onayYontemi: string; aciklama: string;
    eklemeTarihi: string; oncekiPlan: string; alerji: string;
  };
  ozet: { yapilan: number; yapilanSayisi: number; satirSayisi: number; tahsil: number; odemePlaniId: number | null;
          labSayisi: number; labdaSayisi: number; labBekleyen: number; seansSayisi: number; bitenSeans: number };
  satirlar: DisPlanSatiri[];
  seanslar: { id: number; baslangic: string; bitis: string | null; sureDk: number; durum: number; unit: string; hekim: string; islemler: string; randevuId: number | null }[];
  randevular: { id: number; baslangic: string; sureDk: number; durum: number; planSatirId: number; unit: string; hekim: string }[];
  odemePlani?: { id: number; toplam: number; pesinat: number; taksitSayisi: number; taksitTutar: number; ilkVade: string | null; odemeYontemi: number; durum: number; aciklama: string } | null;
  taksitler: { id: number; sira: number; vade: string; tutar: number; odenen: number; odemeTarihi: string | null; durum: number; maliHareketId: number | null }[];
  labIsleri: { id: number; isemriNo: string; planSatirId: number; planSira: number; lab: string; disNolar: string; isTuru: number; malzeme: string; renk: string;
               gonderim: string | null; beklenen: string | null; teslim: string | null; asama: number; labFiyat: number; kaliteKontrol: number; randevu: string | null }[];
  varyantlar: { id: number; planNo: string; varyant: string; durum: number; toplam: number; indirim: number; net: number; satirSayisi: number; hastaOnayZamani: string | null }[];
  varyantSatirlari: { planId: number; disNo: number; yuzeyler: string; islem: string; net: number; durum: number }[];
  gunluk: { tarih: string; kullanici: string; islemTipi: number; tabloId: number; kayitId: number; bilgi: string }[];
  secenekler: { hekimler: { id: number; ad: string }[]; fiyatListeleri: { id: number; ad: string }[]; kurumlar: { id: number; ad: string }[] };
}

/** Lab kanban panosu (711) - kolon = aşama. */
export interface DisLabPanoKarti {
  id: number; isemriNo: string; hastaId: number; hasta: string; hekim: string; hekimId: number | null; labId: number; lab: string; slaGun: number;
  disNolar: string; isTuru: number; malzeme: string; renk: string; olcuTipi: number; ekIstek: string;
  gonderim?: string | null; beklenen?: string | null; teslim?: string | null; asama: number; kaliteKontrol: number; labFiyat: number; hastaFiyat: number;
  planSatirId?: number | null; planNo: string; planSira: number; islem: string; randevu?: string | null; sonAsamaZamani?: string | null;
  gecikti: boolean; geriSayisi: number;
}
export interface DisLabPano {
  kartlar: DisLabPanoKarti[];
  lablar: { id: number; ad: string; slaGun: number; kuryeGunleri: string }[];
  hekimler: { id: number; ad: string }[];
  bugun: string;
}

export interface DisHastaKarti {
  hasta: {
    id: number; unvan: string; cepTel: string; dogumTarihi: string | null; yas: number | null;
    cinsiyet: number; alerji: string; kronik: string; ilac: string; sonMuayene: string | null; sonHekim: string;
    dentalAnamnez: string; seansSayisi: number;
  };
  odontogram: DisOdontogramSatiri[];
  plan: DisPlanOzeti | null;
  satirlar: DisPlanSatiri[];
  gecmis: {
    id: number; tarih: string; hekim: string; disNo: number; yuzeyler: string; islem: string;
    seansNo: number; seansSayisi: number; tamamlandi: boolean; planNo: string; ucret: number;
  }[];
  labIsleri: {
    id: number; isemriNo: string; lab: string; disNolar: string; isTuru: number; malzeme: string;
    renk: string; gonderim: string | null; beklenen: string | null; asama: number; labFiyat: number;
  }[];
  perio: {
    id: number; tarih: string; plakIndeksi: number | null; bopOran: number | null;
    cep5Sayisi: number; ortCal: number | null; evre: number; derece: string;
  } | null;
  perioCep: { disNo: number; cep: number }[];
  disMuayene: {
    okluzyonSinif: number; tmeBulgu: string; bruksizm: boolean; sigara: boolean;
    hijyenDurum: string; dmftD: number; dmftM: number; dmftF: number; dentisyon: number;
  } | null;
  fiyatListesi: number | null;
}

export interface DisIslemSecenegi {
  id: number; kod: string; ad: string; fiyat: number; standartSeans: number; labGerekir: boolean;
  ucretKurali: number; disBazli: boolean; yuzeyBazli: boolean; islemGrubu: number;
}

export interface DisAkisSatiri {
  id: number; baslangic: string; sureDk: number;
  /** 1 planlandı · 2 geldi · 3 gelmedi · 4 iptal. */
  randevuDurum: number;
  hastaId: number; hasta: string; yas: number | null; hekimId: number | null; hekim: string;
  unitId: number | null; unitKod: string; planSatirId: number | null; planId: number | null;
  planNo: string; planSira: number | null; planliIslem: string; disNo: number | null;
  seansSayisi: number | null; yapilanSeans: number | null; labIsemriId: number | null;
  labAsama: number | null; planDurum: number | null; planYapilan: number; planToplamSatir: number;
  bakiye: number; seansId: number | null; seansBaslangic: string | null; seansDurum: number | null;
  belgeId: number | null; alerji: string;
}

export interface DisGunlukAkis {
  gun: string;
  unitler: { id: number; kod: string; ad: string; tur: number; hekim: string }[];
  satirlar: DisAkisSatiri[];
  ozet: {
    randevu: number; randevusuz: number; randevuDk: number; unitSayisi: number; ortSeansDk: number;
    ciro: number; labBekleyen: number; labGecikti: number; onayBekleyen: number; unitte: number;
    tamamlanan: number;
  } | null;
  doluluk: number;
  simdi: string;
}

export interface DisSeansIslem {
  id: number; planSatirId: number | null; hizmetId: number; islem: string; disNo: number; yuzeyler: string; seansNo: number;
  tamamlandi: boolean; seansSayisi: number; yapilanSeans: number; ucretKurali: number; net: number; satirDurum: number; planSira: number;
  planNo: string; uygulamaNotu: string; calismaBoyu: string; komplikasyon: string; sonrakiPlan: string; notMetin: string; ucret: number;
  sutKodu: string; kod: string; labGerekir: boolean;
}
export interface DisSeansKarti {
  seans: {
    id: number; hastaId: number; hasta: string; yas: number | null; hekimId: number | null; hekim: string; asistanId: number | null; asistan: string;
    unitId: number | null; unit: string; planId: number | null; planNo: string; randevuId: number | null; belgeId: number | null; belgeNo: string;
    baslangic: string; bitis: string | null; sureDk: number; durum: number; anesteziTur: string; anesteziIlac: string; anesteziDoz: string;
    anesteziSaat: string | null; uygulamaNotu: string; komplikasyon: string; hastayaTalimat: string; sonrakiPlan: string; sterilizasyonPaket: string;
    alerji: string; oncekiNot: string; oncekiSeans: number;
  };
  islemler: DisSeansIslem[];
  acikSatirlar: { id: number; disNo: number; yuzeyler: string; islem: string; seansSayisi: number; yapilanSeans: number; net: number; durum: number; planNo: string; sira: number; faz: number }[];
  sarf: { id: number; malzeme: string; miktar: number; birim: string; kaynak: number; maliyet: number }[];
  planOzet: { net: number; yapilan: number; tahsil: number; odemePlaniId: number | null } | null;
  simdi: string;
}

export const disUclari = {
  disSeansKart: (id: number) => istek<DisSeansKarti>(`/api/dis/seans/${id}`),
  disSeansGuncelle: (id: number, g: Record<string, unknown>) => gonder<void>(`/api/dis/seans/${id}`, g, 'PATCH'),
  disSeansIslemEkle: (id: number, g: { planSatirId?: number; hizmetId?: number; disNo?: number; yuzeyler?: string; tamamlandi?: boolean }) =>
    gonder<{ id: number }>(`/api/dis/seans/${id}/islem`, g),
  disSeansIslemGuncelle: (id: number, g: Record<string, unknown>) => gonder<void>(`/api/dis/seans/islem/${id}`, g, 'PATCH'),
  disSeansIslemSil: (id: number) => istek<void>(`/api/dis/seans/islem/${id}`, { method: 'DELETE' }),
  disMuayeneGuncelle: (hastaId: number, g: { dentalAnamnez?: string; bruksizm?: boolean; sigara?: boolean; hijyenDurum?: string; tmeBulgu?: string; okluzyonSinif?: number }) =>
    gonder<{ id: number }>(`/api/dis/hasta/${hastaId}/dis-muayene`, g, 'PATCH'),
  disHastaKarti: (hastaId: number) => istek<DisHastaKarti>(`/api/dis/hasta/${hastaId}/kart`),
  disIslemAra: (q: string, listeId?: number | null) =>
    istek<{ listeId: number | null; satirlar: DisIslemSecenegi[] }>(
      `/api/dis/islemler?q=${encodeURIComponent(q)}${listeId ? `&listeId=${listeId}` : ''}`),
  disBulguYaz: (hastaId: number, g: { disNo: number; yuzeyler?: string; durumKod: number; kaynak?: number; not?: string }) =>
    gonder<{ id: number }>(`/api/dis/hasta/${hastaId}/bulgu`, g),
  disBulguSil: (id: number) => istek<void>(`/api/dis/odontogram/${id}`, { method: 'DELETE' }),
  disPlanSatirEkle: (hastaId: number, g: {
    planId?: number | null; disNo: number; yuzeyler?: string; hizmetId: number;
    seansSayisi?: number; iskonto?: number; faz?: number; hekimId?: number | null; aciklama?: string;
  }) => gonder<{ planId: number; planNo: string; satirId: number; satirlar: DisPlanSatiri[] }>(
    `/api/dis/hasta/${hastaId}/plan-satir`, g),
  disPlanSatirIptal: (id: number) =>
    gonder<{ satirlar: DisPlanSatiri[] }>(`/api/dis/plan-satir/${id}/iptal`, {}),
  disPlanSatirYapildi: (id: number, g: { seansId?: number | null; belgeId?: number | null } = {}) =>
    gonder<{ uyari: string | null; ucret: number; satirlar: DisPlanSatiri[] }>(`/api/dis/plan-satir/${id}/yapildi`, g),
  disPlanKart: (id: number) => istek<DisPlanKartVerisi>(`/api/dis/plan/${id}`),
  disPlanAc: (g: { hastaId: number; hekimId?: number | null; muayeneId?: number | null }) =>
    gonder<{ id: number; planNo: string }>('/api/dis/plan', g),
  disPlanGuncelle: (id: number, g: Record<string, unknown>) => gonder<{ id: number }>(`/api/dis/plan/${id}`, g, 'PATCH'),
  disPlanIptal: (id: number) => gonder<{ durum: number; iptalSatir: number }>(`/api/dis/plan/${id}/iptal`, {}),
  disPlanAlternatif: (id: number) => gonder<{ id: number; planNo: string; varyant: string }>(`/api/dis/plan/${id}/alternatif`, {}),
  disPlanAnaYap: (id: number) => gonder<{ id: number }>(`/api/dis/plan/${id}/ana-yap`, {}),
  disPlanSun: (id: number) => gonder<{ durum: number }>(`/api/dis/plan/${id}/sun`, {}),
  disPlanOnayla: (id: number) => gonder<{ durum: number }>(`/api/dis/plan/${id}/onayla`, {}),
  disOdemePlaniUret: (id: number, g: { pesinat?: number; taksitSayisi?: number; ilkVade?: string; odemeYontemi?: number }) =>
    gonder<{ id: number; taksit: number; taksitTutar: number; pesinat: number }>(`/api/dis/plan/${id}/odeme-plani`, g),
  disGunlukAkis: (gun?: string) => istek<DisGunlukAkis>('/api/dis/gunluk-akis' + (gun ? `?gun=${gun}` : '')),
  disYenidenPlanla: (randevuId: number, g: { baslangic: string; unitId?: number | null; hekimId?: number | null; sureDk?: number }) =>
    gonder<{ id: number; hasta: string }>(`/api/dis/randevu/${randevuId}/yeniden-planla`, g),
  disSeansAc: (g: { randevuId?: number; hastaId?: number; unitId?: number | null; hekimId?: number | null; planId?: number | null; planSatirId?: number | null }) =>
    gonder<{ id: number; mevcut: boolean; belgeId?: number | null; basvuruAcildi?: boolean; basvuruNo?: string | null; odeyen?: string | null; provizyonBekliyor?: boolean }>('/api/dis/seans/ac', g),
  disSeansBitir: (id: number) =>
    gonder<{ yapilan: number; ilerleyen: number; ucret: number; uyari: string | null }>(`/api/dis/seans/${id}/bitir`, {}),
  disLabPano: (g: { labId?: number | null; hekimId?: number | null } = {}) =>
    istek<DisLabPano>(`/api/dis/lab-pano?${g.labId ? `labId=${g.labId}&` : ''}${g.hekimId ? `hekimId=${g.hekimId}` : ''}`),
  disLabAsamalar: (id: number) => istek<{ asamalar: { asama: number; zaman: string; kullanici: string; not_: string }[] }>(`/api/dis/lab-isemri/${id}/asamalar`),
  disLabAsama: (id: number, g: { asama?: number; not?: string } = {}) =>
    gonder<{ asama: number }>(`/api/dis/lab-isemri/${id}/asama`, g),
};
