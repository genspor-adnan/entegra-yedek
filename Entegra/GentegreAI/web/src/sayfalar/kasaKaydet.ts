import { sayiOku as sayi } from './belgeSabitleri';

/**
 * KASA ISLEMI - dogrulama ve istek govdesi (SAF).
 *
 * `belgeKaydet.ts` ile ayni desen: ekran yalnizca durumu tutar ve sonucu
 * gosterir; "ne gonderiliyor" ve "neyi engelliyoruz" kararlari burada, tek
 * yerde. Sunucu ayni kurallari YENIDEN dogrular - buradaki kontroller erken
 * uyaridir, guvenlik siniri degil.
 */

export interface KasaGirdisi {
  tur: number;
  grup: string;
  tarih: string;
  planTarihi: string;
  cari: { id: number; unvan: string } | null;
  karsiCari: { id: number; unvan: string } | null;
  hesap: { id: number; ad: string; doviz: string } | null;
  karsiHesap: { id: number; ad: string; doviz: string } | null;
  tutar: string;
  doviz: string;
  ekstreDovizi: string;
  kur: string;
  karsiTutar: string;
  masrafTutar: string;
  kalem: { id: number; ad: string } | null;
  proje: { id: number; ad: string } | null;
  aciklama: string;
  /** Cek/senet alanlari - yalniz kiymetli turlerde gonderilir. */
  csVade: string;
  csSeriNo: string;
  csKesideci: string;
  csBanka: string;
  csSube: string;
  /** Kart disaridan MEVCUT bir kiymetle acildiysa onun kimligi. */
  mevcutKiymet: number;
  /** Tahsilatin kapatacagi belge (kasa_islem.belge_id). */
  belgeBagi?: number;
  /** Turun cari zorunlulugu: 1 zorunlu · 0 serbest · -1 yasak (katalogdan). */
  cariZorunlu?: number;
}

/** Turun sekil kurallari - hem dogrulama hem govde ayni yerden okusun. */
export function kasaTurBilgisi(tur: number, grup: string) {
  return {
    planMi: grup === 'plan',
    karsiHesapli: grup === 'virman' || grup === 'doviz',
    /** Doviz alis/satis: iki tutar ve capraz kur. */
    donusum: grup === 'doviz',
    cariVirman: tur === 49,
    /** Cek/senet ile tahsilat-odeme (23/24 alinan, 33/34 verilen). */
    cekSenetMi: tur === 23 || tur === 24 || tur === 33 || tur === 34,
    senetMi: tur === 24 || tur === 34,
  };
}

/** Alan hatalari (bos nesne = gecerli). */
export function kasaDogrula(g: KasaGirdisi, plan: boolean): Record<string, string> {
  const { planMi, karsiHesapli, donusum, cariVirman, cekSenetMi } =
    kasaTurBilgisi(g.tur, g.grup);
  const hatalar: Record<string, string> = {};
  // Cek/senette hesap SECILMEZ: kiymet portfoye girer (sanal hesap), para
  //   bankaya ancak tahsil edilince gecer.
  if (!planMi && !cariVirman && !cekSenetMi && !g.hesap) hatalar.hesapId = 'Hesap seçilmeli.';
  if (cekSenetMi && !g.mevcutKiymet && !g.csVade) hatalar['cekSenet.vade'] = 'Vade zorunlu.';
  if (karsiHesapli && !g.karsiHesap) hatalar.karsiHesapId = 'Karşı hesap seçilmeli.';
  if (cariVirman && !g.karsiCari) hatalar.karsiTarafId = 'Karşı cari seçilmeli.';
  if (sayi(g.tutar) <= 0) hatalar.tutar = 'Sıfırdan büyük olmalı.';
  if (donusum && sayi(g.karsiTutar) <= 0) hatalar.karsiTutar = 'Sıfırdan büyük olmalı.';
  if (g.cariZorunlu === 1 && !g.cari) hatalar.tarafId = 'Cari zorunlu.';
  if (plan && !g.planTarihi) hatalar.planTarihi = 'Vade zorunlu.';
  return hatalar;
}

export function kasaGovdesi(g: KasaGirdisi, taslak: boolean, plan: boolean) {
  const { karsiHesapli, donusum, cariVirman, cekSenetMi, senetMi } =
    kasaTurBilgisi(g.tur, g.grup);
  const dovizli = g.doviz !== 'TL';
  return {
    islem: {
      tur: g.tur,
      islemTarihi: g.tarih,
      planTarihi: plan && g.planTarihi ? g.planTarihi : null,
      tarafId: g.cari?.id ?? null,
      karsiTarafId: cariVirman ? g.karsiCari?.id ?? null : null,
      hesapId: g.hesap?.id ?? null,
      karsiHesapId: karsiHesapli ? g.karsiHesap?.id ?? null : null,
      tutar: sayi(g.tutar),
      dovizCinsi: g.doviz,
      // Ekstre dovizi (139): yerel islemde anlamsiz - bos gider, sunucu islem
      //   dovizini kullanir.
      ekstreDovizi: dovizli ? g.ekstreDovizi : '',
      dovizKuru: Number(g.kur.replace(',', '.')) || 1,
      karsiDovizCinsi: donusum ? g.karsiHesap?.doviz ?? '' : '',
      karsiTutar: donusum ? sayi(g.karsiTutar) : 0,
      masrafTutar: sayi(g.masrafTutar),
      masrafId: g.kalem?.id ?? null,
      projeId: g.proje?.id ?? null,
      aciklama: g.aciklama,
      ...(g.mevcutKiymet ? { cekSenetId: g.mevcutKiymet } : {}),
    },
    // Cek/senet turlerinde kiymetin kendisi de gonderilir: sunucu once
    //   cek_senet kaydini acar, kimligini basliga baglar (tek cagri). MEVCUT
    //   kiymete baglaniyorsak (kart onceden dolduruldu) yeni kayit ACILMAZ -
    //   yalnizca kimlik gider, yoksa ayni cek iki kez portfoye girerdi.
    ...(cekSenetMi && !g.mevcutKiymet ? {
      cekSenet: {
        vade: g.csVade || null,
        tarih: g.tarih,
        seriNo: g.csSeriNo,
        kesideci: g.csKesideci || g.cari?.unvan || '',
        bankaAdi: senetMi ? '' : g.csBanka,
        bankaSubesi: senetMi ? '' : g.csSube,
        aciklama: g.aciklama,
      },
    } : {}),
    // belgeId: tahsilat bu belgeyi kapatir (kasa_islem.belge_id) - belge
    //   kartinin Tahsilat sekmesi bu bagla listeliyor.
    secenekler: { taslak, plan, kurKontrolu: true,
                  ...(g.belgeBagi ? { belgeId: g.belgeBagi } : {}) },
  };
}
