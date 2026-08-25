import type { BelgeYaniti } from '../api/sozlesme';
import type { SatirDurumu } from './belgeSatir';

/** Kart uzerinde secilen bir kayit (cari, depo, tasiyici, personel...). */
export interface Secim { id: number; ad: string }

/**
 * Kaydetmeye giden KART DURUMU. Dogrulama ve istek govdesi bunun uzerinden
 * uretilir - ikisi de SAF fonksiyon, ekran durumuna dokunmaz.
 */
export interface BelgeGirdisi {
  tur: number;
  cari: { id: number; unvan: string } | null;
  tarih: string;
  tarihEnGec: string;
  tarihEnErken: string | undefined;
  geriGun: number;
  seri: string;
  belgeNo: string;
  vadeGun: string;
  senaryo: number;
  satici: Secim | null;
  depo: Secim | null;
  girisDepo: Secim | null;
  teslimEden: Secim | null;
  teslimAlan: Secim | null;
  tasiyici: Secim | null;
  aracPlaka: string;
  soforAd: string;
  soforTckn: string;
  sevkTarihi: string;
  teslimSekli: number;
  fisTipi: number;
  /** Fatura tipi (130) - faturada belge.tipi olarak gider. */
  faturaTipi: number;
  /** Rapor dovizi (belgenin duzenlendigi birim) ve yerel paraya kur (134). */
  raporDovizi: string;
  ekstreDovizi: string;
  belgeKuru: string;
  /** Yerel (defter) para birimi - tutarlarin girildigi birim. */
  yerelPara: string;
  satirlar: SatirDurumu[];
  subeId?: number;
  // belgeTuru.ts davranis bayraklari
  alisMi: boolean;
  irsaliyeMi: boolean;
  /** Fatura (ya da tahakkuk) mu - fatura tipi yalniz bu turlerde yazilir. */
  faturaMi: boolean;
  depoBelgesi: boolean;
  stokFisiMi: boolean;
  fisCikisMi: boolean;
  transferMi: boolean;
  talepMi: boolean;
  disNumarali: boolean;
}

/**
 * KAYDETMEDEN ONCEKI KONTROLLER - alan adi -> mesaj (alan yoksa 'genel').
 *
 * Sunucu ayni kurallari kendi tarafinda da uygular; burasi kullaniciyi erken
 * uyarmak ve hatali alanin sekmesine goturmek icindir.
 */
export function belgeDogrula(g: BelgeGirdisi): Record<string, string> | null {
  const { cari, depoBelgesi, stokFisiMi, fisTipi, fisCikisMi, depo, tarih,
          tarihEnGec, tarihEnErken, geriGun, talepMi, teslimAlan, girisDepo,
          transferMi, teslimEden, disNumarali, belgeNo, satirlar } = g;

  // Transferde cari YOK (sunucu da katalogtan ayni karari veriyor).
  if (!cari && !depoBelgesi && !stokFisiMi) {
    return { tarafId: 'Cari seçilmeli.' };
  }
  if (stokFisiMi) {
    if (!fisTipi) { return { tipi: 'Fiş tipi seçilmeli.' } }
    if (!depo) {
      return { [fisCikisMi ? 'cikisDepoId' : 'girisDepoId']: 'Depo seçilmeli.' };
    }
  }
  // Tarih penceresi (tum belge turleri): ileri tarih ve 7 gunden eski yasak.
  if (tarih > tarihEnGec) {
    return { belgeTarihi: 'Belge ileri tarihli olamaz.' };
  }
  if (tarihEnErken && tarih < tarihEnErken) {
    return { belgeTarihi: `Belge tarihi ${geriGun} gün` + 'den eski olamaz.' };
  }
  if (talepMi) {
    if (!depo) { return { cikisDepoId: 'İstenen depo seçilmeli.' } }
    if (!teslimAlan) { return { teslimAlanId: 'Talep eden seçilmeli.' } }
    if (girisDepo && girisDepo.id === depo.id) {
      return { girisDepoId: 'Teslim deposu istenen depo ile aynı olamaz.' };
    }
  }
  if (transferMi) {
    if (!depo || !girisDepo) {
      return { [!depo ? 'cikisDepoId' : 'girisDepoId']: 'Depo seçilmeli.' };
    }
    if (depo.id === girisDepo.id) {
      return { girisDepoId: 'Çıkış ve giriş deposu aynı olamaz.' };
    }
    // Sorumluluk devri: mali kim verdi, kim aldi (sunucu da ayni kontrolu yapar).
    if (!teslimEden || !teslimAlan) {
      return !teslimEden ? { teslimEdenId: 'Teslim eden seçilmeli.' } : { teslimAlanId: 'Teslim alan seçilmeli.' };
    }
    if (teslimEden.id === teslimAlan.id) {
      return { teslimAlanId: 'Teslim eden ve teslim alan aynı kişi olamaz.' };
    }
  }
  if (disNumarali && belgeNo.trim() === '') {
    return { belgeNo: 'Tedarikçinin fatura numarası girilmeli.' };
  }
  if (satirlar.filter(s => s.stokId || s.hizmetId).length === 0)
    return { genel: 'En az bir satırda stok ya da hizmet seçilmeli.' };

  return null;
}

/** API §4 istek govdesi. `dolu` = stok/hizmet secilmis satirlar. */
export function belgeGovdesi(g: BelgeGirdisi, dolu: SatirDurumu[], taslak: boolean) {
  const { tur, cari, tarih, depoBelgesi, stokFisiMi, seri, disNumarali, belgeNo,
          vadeGun, subeId, fisCikisMi, depo, girisDepo, alisMi, faturaMi, fisTipi, faturaTipi,
          raporDovizi, ekstreDovizi, belgeKuru, yerelPara, satici,
          senaryo, irsaliyeMi, teslimSekli, aracPlaka, soforAd, sevkTarihi,
          soforTckn, tasiyici, transferMi, teslimEden, teslimAlan } = g;

return {
  belge: {
    tur,
    tarafId: cari?.id ?? 0,
    belgeTarihi: tarih,
    // Seri e-Belge kavrami: transferde YOK - yoksa numara "T20|SWEB" gibi
    //   ayri bir sayactan gelir ve eski transferlerle ayni seride olmaz.
    belgeSeri: depoBelgesi || stokFisiMi ? '' : seri,
    // Alis faturasinda numara tedarikciden gelir; digerlerinde sunucu verir.
    belgeNo: disNumarali ? belgeNo.trim() : undefined,
    // TUTARLAR YEREL PARADA yazilir (kalem fiyatlari yerel girilir): belge
    //   dovizi yerel, RAPOR DOVIZI ayri kolon. Kur = 1 rapor dovizi kac yerel
    //   para eder; doviz karsiligi sunucuda genel_toplam / kur olarak hesaplanir.
    belgeDovizi: yerelPara,
    raporDovizi,
    ekstreDovizi,
    dovizKuru: Number(String(belgeKuru).replace(',', '.')) || 1,
    vadeGun: Number(vadeGun) || 0,
    subeId,
    // Depo ALANI ture gore: alista giris, satista cikis (stok yonu buradan).
    //   TRANSFERDE IKISI DE dolu - tek satir iki depoyu oynatir.
    // Stok fisinde depo yonu TURDEN gelir: giris fisi girise, cikis fisi
    //   cikisa yazar (cari yok, tek depo alani var).
    cikisDepoId: stokFisiMi ? (fisCikisMi ? depo?.id ?? null : null)
               : depoBelgesi ? depo?.id ?? null
               : alisMi ? null : depo?.id ?? null,
    girisDepoId: stokFisiMi ? (fisCikisMi ? null : depo?.id ?? null)
               : depoBelgesi ? girisDepo?.id ?? null
               : alisMi ? depo?.id ?? null : null,
    // belge.tipi UC anlamda kullanilir: stok fisinde fisin SEBEBI, faturada
    //   FATURA TIPI (130), irsaliyede NORMAL/IADE (133). Siparis, transfer ve
    //   talepte anlami yok - gonderilmez, alan 0 kalir.
    tipi: stokFisiMi ? fisTipi : (faturaMi || irsaliyeMi) ? faturaTipi : undefined,
    // satici_id NOT NULL default 0 - "secilmedi" burada null degil 0
    //   (null gonderince sunucu "saticiId bos birakilamaz" ile reddediyordu).
    saticiId: satici?.id ?? 0,
    senaryo,
    // Teslim sekli e-Irsaliye'de GIB'in bekledigi alan.
    teslimSekli: irsaliyeMi ? teslimSekli : undefined,
    aracPlaka: irsaliyeMi ? aracPlaka : undefined,
    soforAd: irsaliyeMi ? soforAd : undefined,
    // Tasiyici / Sevkiyat sekmesindeki ek UBL alanlari
    irsaliyeTarihi: irsaliyeMi && sevkTarihi ? sevkTarihi : undefined,
    soforTckn: irsaliyeMi ? soforTckn : undefined,
    tasiyiciId: irsaliyeMi ? tasiyici?.id ?? null : undefined,
    // Teslim eden irsaliyede opsiyonel, TRANSFERDE zorunlu; teslim alan
    //   yalniz transferde var (sorumluluk devri).
    teslimEdenId: irsaliyeMi || transferMi ? teslimEden?.id ?? null : undefined,
    teslimAlanId: depoBelgesi ? teslimAlan?.id ?? null : undefined,

  },
  satirlar: dolu.map((s, i) => ({
    sira: i + 1,
    tur: s.satirTur,
    stokId: s.stokId,
    hizmetId: s.hizmetId,
    // `adet` GIRILEN miktardir (2 kutu); ANA BIRIM karsiligini (24 adet)
    //   sunucu carpandan hesaplar - iki yerde hesaplamak iki farkli sonuc
    //   demekti, o yuzden `miktar` GONDERILMEZ (143).
    adet: Number(s.adet.replace(',', '.')) || 0,
    birimFiyat: Number(s.birimFiyat.replace(',', '.')) || 0,
    // SATIR BAZLI DOVIZ: bir kalem 100 USD, digeri 100 TL olabilir (kullanici).
    //   Yerel birim fiyat her zaman yazilir; doviz alanlari yalniz satir kendi
    //   para biriminde girildiyse gider (sunucu ikisini birbirinden turetiyor).
    dovizCinsi: s.fiyatDovizi || undefined,
    dovizBirimFiyat: s.fiyatDovizi && s.fiyatDovizi !== yerelPara
      ? Number(String(s.dovizFiyat).replace(',', '.')) || 0
      : undefined,
    dovizKuru: s.fiyatDovizi && s.fiyatDovizi !== yerelPara
      ? Number(String(s.kur).replace(',', '.')) || 1
      : undefined,
    iskonto: stokFisiMi ? 0 : Number(s.iskonto.replace(',', '.')) || 0,
    iskonto2: stokFisiMi ? 0 : Number(s.iskonto2.replace(',', '.')) || 0,
    // Stok fisi vergi dogurmaz: stok kartindan gelen KDV/iskonto sifirlanir
    //   (yoksa dip toplam vergili cikip muhasebe matrahini sisirir).
    kdv: stokFisiMi ? 0 : Number(s.kdv.replace(',', '.')) || 0,
    aciklama: s.aciklama,
    // IADE satiri kaynak fatura satirina baglanir (kaynak_tur 30): iade edilen
    //   miktar bu bagdan turetilir, ayni kalem iki kez iade edilemez (132).
    kaynakTur: s.kaynakSatirId ? 30 : undefined,
    kaynakId: s.kaynakSatirId,
    izlemeKodu: s.izlemeKodu,
    izleme: s.izleme || (s.izlemeKodu ? 1 : 0),
    // Termin (140): bos string DEGIL null gider - sunucu tarih bekliyor.
    teslimTarihi: s.teslimTarihi || null,
    // Ambalaj birimi (143): girilen birim + ana birim carpani. Sunucu
    //   miktar = adet x carpan hesaplar; stok ANA BIRIMDE hareket eder.
    birim: s.birim ?? 0,
    birimCarpan: s.birimCarpan ?? 1,
    // Lot dagilimi: bos dizi gonderilmez - izlemsiz stokta sunucu hata verir.
    izlemler: s.izlemler.length > 0
      ? s.izlemler.map(z => ({
          seriLotId: z.seriLotId,
          lotNo: z.lotNo.trim(),
          seriNo: z.seriNo.trim(),
          uretimTarihi: z.uretimTarihi || null,
          sonKullanmaTarihi: z.sonKullanmaTarihi || null,
          durum: z.durum,
          miktar: Number(z.miktar.replace(',', '.')) || 0,
        }))
      : undefined,
  })),
  secenekler: { taslak, stokKontrolu: true },
};
}

/** Kaydetmeye giden satirlar - stok ya da hizmet secilmis olanlar. */
export const doluSatirlar = (satirlar: SatirDurumu[]) =>
  satirlar.filter(s => s.stokId || s.hizmetId);

export type BelgeKayitYaniti = BelgeYaniti;
