import { gonder, istek } from '../cekirdek';

/**
 * YATAN HASTA — yatış kartının üst şeridi ve "açık işler" kutusu (695).
 *
 * Tek uç, çünkü şeridin dört parçası (kimlik · son vital · sıvı dengesi ·
 * açık iş sayaçları) aynı anda görünür: ayrı isteklere bölmek, kart açılırken
 * şeridin yarısını boş gösterirdi.
 */

export interface YatisOzetSatiri {
  hasta: string;
  yas: number | null;
  /** 1 erkek · 2 kadın (taraf_hasta.cinsiyet). */
  cinsiyet: number;
  yatak: string;
  oda: string;
  /** 0 yok · 1 temaslı · 2 damlacık · 3 solunum · 4 koruyucu. */
  izolasyon: number;
  klinik: string;
  hekim: string;
  odeyen: string;
  provizyonNo: string;
  girisTarihi: string;
  cikisTarihi: string | null;
  gun: number;
  durum: number;
  yatisTuru: number;
  gelisSekli: number;
  yatisTani: string;
  cikisTani: string;
  refakatci: string;
  tahminiCikis: string | null;
  /** Son izlem satırı - yoksa alanlar boş gelir. */
  vitalZaman: string | null;
  sistolik: number | null;
  diyastolik: number | null;
  nabiz: number | null;
  ates: number | null;
  spo2: number | null;
  solunum: number | null;
  erkenUyari: number | null;
  /** Taburcunun beklediği açık işler. */
  gecikenDoz: number;
  imzasizOrder: number;
  bekleyenTetkik: number;
  bekleyenKonsultasyon: number;
  /** Şeritte görünmez; nakil ekranının yatak listesi hastanın cinsiyetine bağlı. */
  hastaId: number;
  yatakId: number | null;
}

export interface YatisRiskSatiri {
  /** 1 İtaki · 2 Braden · 3 NRS-2002 · 4 GKS. */
  olcek: number;
  puan: number | null;
  duzey: number | null;
  zaman: string;
  onlem: string;
}

export interface YatisOzeti {
  ozet: YatisOzetSatiri;
  riskler: YatisRiskSatiri[];
  /** Bugünün sıvı toplamları - denge HESAPLANIR, elle yazılmaz. */
  sivi: { aldi: number; cikardi: number } | null;
}

/**
 * YATAK SEÇENEĞİ — kabul ve nakil ekranının kutu dizisi.
 *
 * UYGUN OLMAYAN YATAK DA GELİR (`uygun: false` + `engel`): mockup'ın kuralı,
 * yatağı gizlemek yerine SOLUK gösterip nedenini yazmak. Gizlenen yatak
 * "neden yer yok" sorusunu telefona taşır; neden görününce "temizliği öne
 * alalım" denebiliyor.
 */
export interface YatakSecenegi {
  id: number;
  yatak: string;
  tip: number;
  durum: number;
  durumNotu: string;
  odaId: number;
  oda: string;
  odaAd: string;
  odaTur: number;
  cinsiyetKurali: number;
  izolasyon: number;
  bina: string;
  kat: string;
  departmanId: number | null;
  klinik: string;
  /** Odanın yatak ücreti hizmeti — nakilde sınıf değişimi uyarısının girdisi. */
  ucretHizmet: string;
  uygun: boolean;
  engel: string;
}

/** Çıkış kontrol maddesi: `engel` taburcuyu durdurur, diğeri uyarıdır. */
export interface CikisKontrolMaddesi {
  kod: string;
  ad: string;
  sayi: number;
  engel: boolean;
  tamam: boolean;
  not: string;
}

export interface YatisKabulIstegi {
  hastaId: number;
  yatakId: number;
  departmanId?: number | null;
  hekimId?: number | null;
  yatisTuru?: number;
  gelisSekli?: number;
  yatisTaniKodu?: string;
  odeyenKurumId?: number | null;
  provizyonNo?: string;
  refakatciAd?: string;
  refakatciTckn?: string;
  tahminiCikis?: string | null;
  belgeId?: number | null;
}

/** eMAR çizelgesinin order satırı (698). */
export interface EmarOrder {
  id: number;
  tur: number;
  ad: string;
  doz: number | null;
  birim: string;
  yol: number | null;
  siklik: string;
  /** jsonb metin olarak gelir: ["08:00","20:00"]. */
  saatler: string;
  baslangic: string;
  bitis: string | null;
  durum: number;
  sozelOrder: boolean;
  imzali: boolean;
  hekim: string;
  yolAd: string;
  turAd: string;
  sonUygulayan: string;
}

/** Çizelgenin hücresi: PLANLANAN doz (önceden üretilir, 698). */
export interface EmarDoz {
  id: number;
  orderId: number;
  planlanan: string;
  uygulanan: string | null;
  /** 1 bekliyor · 2 uygulandı · 3 atlandı · 4 hasta reddetti · 5 gecikti. */
  durum: number;
  atlamaNedeni: string;
  gecikmeNedeni: string;
  miktar: number | null;
  barkod: string;
  elleDogrulandi: boolean;
  uygulayan: string;
}

export interface EmarYaniti {
  gun: string;
  orderlar: EmarOrder[];
  dozlar: EmarDoz[];
  ozet: {
    toplam: number; uygulanan: number; bekleyen: number; geciken: number;
    atlanan: number; barkodsuz: number; imzasizSozel: number;
  };
}

/** Hemşire izlem ekranının tek yanıtı (699). */
export interface IzlemVital {
  id: number;
  zaman: string;
  sistolik: number | null; diyastolik: number | null;
  nabiz: number | null; solunum: number | null;
  ates: number | null; spo2: number | null;
  agriVas: number | null; gks: number | null; kanSekeri: number | null;
  /** NEWS; ölçülmeyen parametre puana katılmaz (699). */
  erkenUyari: number | null;
  bildirimZamani: string | null;
  not_: string;
  olcen: string;
}

export interface IzlemSivi {
  id: number; zaman: string; yon: number; tur: number;
  miktarMl: number; aciklama: string; kaydeden: string; turAd: string;
}

export interface IzlemRisk {
  id: number; zaman: string; olcek: number; puan: number | null;
  duzey: number | null; onlem: string; degerlendiren: string;
  olcekAd: string; saatOnce: number;
}

export interface IzlemYaniti {
  pencereSaat: number;
  vitaller: IzlemVital[];
  sivilar: IzlemSivi[];
  denge: {
    aldi: number; cikardi: number; fark: number; idrar: number;
    kilo: number | null;
    /** mL/kg/sa — kilo ölçümü yoksa null (uydurma kiloyla hesaplanmaz). */
    idrarOrani: number | null;
  };
  riskler: IzlemRisk[];
  gozlemler: { id: number; zaman: string; not_: string; olcen: string }[];
}

/** Yatan hasta hizmet icmali (700) — satırlar KAYNAKTAN düşer, elle girilmez. */
export interface IcmalYaniti {
  yatis: {
    dosyaNo: string; hasta: string; girisTarihi: string; cikisTarihi: string | null;
    gun: number; klinik: string; hekim: string; odeyen: string;
    odeyenKurumId: number | null; provizyonNo: string; cikisTani: string; durum: number;
  };
  /** Gün sonu tahakkuku: kaynak 1 yatak · 2 refakatçi. */
  yatak: {
    kaynak: number; hizmetId: number | null; ad: string; sut: string;
    adet: number; ilk: string; son: string; birim: number; tutar: number;
    faturasiz: number;
  }[];
  ilac: {
    ad: string; sut: string; hizmetId: number | null; adet: number;
    ilk: string | null; son: string | null; birim: number; tutar: number;
    barkodsuz: number;
  }[];
  tetkik: {
    tur: number; ad: string; sut: string; hizmetId: number | null;
    tarih: string; durum: number; birim: number;
  }[];
  toplam: {
    hizmet: number; kurum: number; hasta: number; faturalanmamis: number;
    kurumVar: boolean; provizyonVar: boolean;
  };
}

/** Çıkış reçetesi satırı: kaynak 1 yatış tedavisinin devamı · 2 yeni · 3 evde kullandığı. */
export interface CikisIlaci {
  ad: string; doz: string; yol: string; sure: string; not: string; kaynak: number;
}

export interface EpikrizYaniti {
  epikriz: {
    id: number; sikayet: string; hikaye: string; bulgular: string; tetkikOzet: string;
    tedavi: string; seyir: string; oneriler: string;
    /** jsonb metin olarak gelir. */
    cikisIlaclari: string;
    kontrolTarihi: string | null; kontrolBolumId: number | null;
    imzaDurum: number; imzaZamani: string | null; kontrolBolum: string;
  } | null;
  /** Lab/görüntüleme order'larından DERLENMİŞ taslak — hekim düzenlemeden geçerli sayılmaz. */
  tetkikTaslak: string;
  ilacAdaylari: {
    ad: string; doz: string; yol: string; siklik: string; durum: number; verilen: number;
  }[];
}

export const yatanUclari = {
  /** Yatış kartının üst şeridi: kimlik + son vital + açık işler + risk. */
  yatisOzeti: (yatisId: number) => istek<YatisOzeti>(`/api/yatan/${yatisId}/ozet`),

  /** Kabul/nakil yatak dizisi — uygunluk KARARI SUNUCUDA verilir. */
  yatakSecenekleri: (hastaId: number, departmanId?: number | null) =>
    istek<{ hastaCinsiyet: number; yataklar: YatakSecenegi[] }>(
      `/api/yatan/yatak-secenekleri?hastaId=${hastaId}`
      + (departmanId ? `&departmanId=${departmanId}` : '')),

  yatisKabul: (istek_: YatisKabulIstegi) =>
    gonder<{ id: number; dosyaNo: string; yatak: string; oda: string }>(
      '/api/yatan/kabul', istek_),

  /** Kabul ile "hasta yatağında" ayrı adımdır: yatak ücreti burada başlar. */
  yatistaYatakta: (id: number) =>
    gonder<{ id: number; durum: number }>(`/api/yatan/${id}/yatakta`, {}),

  yatisNakil: (id: number, govde: {
    yatakId: number; neden?: number; aciklama?: string;
    departmanId?: number | null; hekimId?: number | null;
  }) => gonder<{ id: number; yatak: string; oda: string; ucretDegisti: boolean; uyari: string }>(
    `/api/yatan/${id}/nakil`, govde),

  yatisTaburcuPlanla: (id: number, tahminiCikis: string | null) =>
    gonder<{ id: number; durum: number }>(`/api/yatan/${id}/taburcu-planla`, { tahminiCikis }),

  /** Taburcu ekranı ile yatış kartının "açık işler" kutusu AYNI listeyi okur. */
  yatisCikisKontrol: (id: number) =>
    istek<{ maddeler: CikisKontrolMaddesi[]; engelVar: boolean }>(
      `/api/yatan/${id}/cikis-kontrol`),

  yatisTaburcu: (id: number, govde: {
    cikisSekli: number; cikisTaniKodu?: string; cikisTarihi?: string | null;
    /** Sonuç bekleyen tetkik varsa ZORUNLU: sahipsiz sonuç, bulunmamış sonuçtur. */
    takipHekimId?: number | null;
  }) => gonder<{ id: number; durum: number; kontrolRandevusu: number | null;
                uyarilar: CikisKontrolMaddesi[] }>(
    `/api/yatan/${id}/taburcu`, govde),

  /** eMAR: günün çizelgesi (order satırları + dozlar + özet) tek istekte. */
  emar: (yatisId: number, gun?: string) =>
    istek<EmarYaniti>(`/api/yatan/emar?yatisId=${yatisId}`
                      + (gun ? `&gun=${gun}` : '')),

  /** Doz uygulandı. Barkod yoksa kayıt "elle doğrulandı" işaretlenir. */
  dozUygula: (id: number, govde: {
    barkod?: string; elleDogrulandi?: boolean; miktar?: number | null;
    gecikmeNedeni?: string; uygulananZaman?: string | null;
  }) => gonder<{ id: number; durum: number; elleDogrulandi: boolean; gecikti: boolean }>(
    `/api/yatan/doz/${id}/uygula`, govde),

  /** Doz atlandı — sebep ZORUNLU, satır silinmez. */
  dozAtla: (id: number, govde: { atlamaNedeni: string; hastaReddetti?: boolean }) =>
    gonder<{ id: number; durum: number }>(`/api/yatan/doz/${id}/atla`, govde),

  /** Sözel order imzalama (ayrı yetki: yatan.order.imza). */
  orderImzala: (id: number) =>
    gonder<{ id: number; imzali: boolean }>(`/api/yatan/order/${id}/imzala`, {}),

  /** Nöbet ekranı: vital serisi + sıvı + risk + gözlem tek istekte. */
  izlem: (yatisId: number, saat?: number) =>
    istek<IzlemYaniti>(`/api/yatan/izlem?yatisId=${yatisId}`
                       + (saat ? `&saat=${saat}` : '')),

  /** Ölçüm kaydı. Erken uyarı skorunu SUNUCU hesaplar (699 tetikleyicisi). */
  izlemKaydet: (govde: {
    yatisId: number; zaman?: string | null;
    sistolik?: number | null; diyastolik?: number | null; nabiz?: number | null;
    solunum?: number | null; ates?: number | null; spo2?: number | null;
    agriVas?: number | null; gks?: number | null; kanSekeri?: number | null;
    not?: string;
  }) => gonder<{ id: number; erkenUyari: number | null; bildirimGerek: boolean }>(
    '/api/yatan/izlem', govde),

  /** "Hekime bildirildi" ölçümün SATIRINDA durur. */
  izlemBildirildi: (id: number) =>
    gonder<{ id: number; bildirildi: boolean }>(`/api/yatan/izlem/${id}/bildirildi`, {}),

  siviKaydet: (govde: {
    yatisId: number; zaman?: string | null; yon: number; tur: number;
    miktarMl: number; aciklama?: string;
  }) => gonder<{ id: number }>('/api/yatan/sivi', govde),

  /** Risk değerlendirmesi — orta/yüksek riskte önlem ZORUNLU (sunucu ister). */
  riskKaydet: (govde: {
    yatisId: number; olcek: number; puan?: number | null;
    riskDuzeyi?: number | null; onlem?: string;
  }) => gonder<{ id: number }>('/api/yatan/risk', govde),

  /** Gözlem notu — silinmez, düzeltilmez; düzeltme yeni satırdır. */
  gozlemKaydet: (yatisId: number, not: string) =>
    gonder<{ id: number }>('/api/yatan/gozlem', { yatisId, not }),

  /** Epikriz + tetkik taslağı + çıkış reçetesi adayları. */
  epikriz: (yatisId: number) => istek<EpikrizYaniti>(`/api/yatan/${yatisId}/epikriz`),

  epikrizKaydet: (yatisId: number, govde: {
    sikayet?: string; hikaye?: string; bulgular?: string; tetkikOzet?: string;
    tedavi?: string; seyir?: string; oneriler?: string;
    kontrolTarihi?: string | null; kontrolBolumId?: number | null;
    cikisIlaclari?: CikisIlaci[];
  }) => gonder<{ id: number }>(`/api/yatan/${yatisId}/epikriz`, govde),

  epikrizImzala: (yatisId: number) =>
    gonder<{ yatisId: number; imzali: boolean }>(`/api/yatan/${yatisId}/epikriz/imzala`, {}),

  /** Hizmet icmali — hesaplanır, saklanmaz (kaynak kayıtlar zaten duruyor). */
  yatisIcmal: (yatisId: number) => istek<IcmalYaniti>(`/api/yatan/${yatisId}/icmal`),

  /** Yatış İPTAL edilir, silinmez: kayıt kalır, yatak serbest kalır. */
  yatisIptal: (id: number) =>
    gonder<{ id: number; durum: number }>(`/api/yatan/${id}/iptal`, {}),

  /** Order durdurulur: gelecekteki bekleyen dozlar düşer, geçmiş kalır. */
  orderDurdur: (id: number) =>
    gonder<{ id: number; durum: number }>(`/api/yatan/order/${id}/durdur`, {}),

  /** Gün sonu tahakkukunu yeniden üretir (mükerrer yazmaz). */
  tahakkukHesapla: (gun: string) =>
    gonder<{ gun: string; mesaj: string }>(
      `/api/yatan/tahakkuk-hesapla?gun=${gun}`, {}),

  /** Temizliği biten yatak BOŞ'a döner — kim yaptığı loglanır. */
  yatakTemizlendi: (id: number) =>
    gonder<{ id: number; durum: number }>(`/api/yatan/yatak/${id}/temizlendi`, {}),
};
