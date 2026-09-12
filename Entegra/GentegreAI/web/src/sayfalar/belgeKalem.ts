import { type SatirDurumu, bosSatir } from './belgeSatir';
import type { IadeSatiri } from '../bilesenler/belge/IadeSatirPenceresi';
import { hamSayi } from '../bilesenler/bicim';
import { matraha } from './belgeKarti/kdvModu';

/**
 * KALEM URETIMI - secimden belge satirina.
 *
 * Uc yoldan kalem gelir: stok/hizmet aramasi, paket icerigi ve iade secimi.
 * Ucu de ayni SatirDurumu'nu uretir; alan esleme kurallari (fiyat dovizi,
 * ambalaj birimi, izleme) tek yerde dursun diye BelgeKarti'dan ayrildi.
 *
 * SAF: state'e dokunmaz, yalniz satir uretir.
 */

/** Listedeki en buyuk anahtar - yeni satirlar bunun ustunden numaralanir. */
export const sonAnahtar = (satirlar: readonly SatirDurumu[]) =>
  Math.max(0, ...satirlar.map(x => x.anahtar));

/** Stok/hizmet arama penceresinden secilen kayittan KALEM taslagi. */
export function stokSecimindenKalem(
  sec: Record<string, unknown>, anahtar: number, yerelPara: string,
): SatirDurumu {
  const hizmet = sec.tip === 'hizmet';
  return {
    ...bosSatir(anahtar),
    satirTur: hizmet ? 2 : 1,
    stokId: hizmet ? null : Number(sec.id),
    hizmetId: hizmet ? Number(sec.id) : null,
    stokKodu: String(sec.kod ?? ''),
    stokAdi: String(sec.ad ?? ''),
    // Stok LOT/SERI izlemli mi - kalem penceresi buna gore izlem ekranini
    //   acar (db/114).
    izleme: hizmet ? 0 : Number(sec.izleme ?? 0),
    // Ambalaj (143): kalem ANA BIRIMLE acilir; kullanici pencerede kutu/koli
    //   secerse carpan oradan gelir.
    birim: hizmet ? 0 : Number(sec.anaBirimKod ?? 0),
    birimCarpan: 1,
    birimAdi: hizmet ? '' : String(sec.anaBirim ?? ''),
    // Paket (124): kalem kaydedilince icerigi de belgeye eklenir.
    paket: !hizmet && Number(sec.paket ?? 0) === 1,
    kdv: sec.kdv !== undefined && sec.kdv !== null ? String(sec.kdv) : '20',
    // Kart fiyati onyuklenir - kullanici zaten listede gorup seciyor; pencerede
    //   degistirebilir. Fiyatin PARA BIRIMI de gelir: yerel degilse kalem
    //   penceresi kur + yerel karsilik satirini acar.
    fiyatDovizi: String(sec.fiyatDovizi ?? yerelPara) || yerelPara,
    dovizFiyat: sec.fiyat ? String(sec.fiyat) : '',
    birimFiyat: sec.fiyat ? String(sec.fiyat) : '',
  };
}

/** /api/fiyat/kalem cevabi (274) - liste fiyati + kampanya kurali. */
export interface KalemFiyati {
  fiyat?: number | null;
  bazFiyat?: number | null;
  dovizCinsi?: string | null;
  satirId?: number | null;
  iskontoTipi?: number | null;
  iskonto?: number | null;
  /** Katilim payi (291) - SGK modunda hastadan alinacak sabit tutar. */
  katki?: number | null;
  /**
   * Listenin fiyati KDV DAHIL mi (`fiyat_listesi.kdv_dahil`). Sunucu bunu
   * bastan beri donuyordu ama ekran yok sayiyordu: dahil bir listenin brut
   * fiyati dogrudan MATRAH olarak yaziliyor, kalem KDV orani kadar pahali
   * kaydediliyordu.
   */
  kdvDahil?: number | null;
  /**
   * ÖDEME ROTASI (483): 1 Özel · 2 ÖSS · 3 TSS · 4 Karma · 5 SGK. Sözleşmeden
   * çıkar; ekran "bu satırda SGK payı var mı" sorusunu buradan öğrenir.
   */
  rota?: number | null;
  /** TSS/Karma/SGK rotalarında satırın bir de SGK (SUT) bedeli olmalı. */
  sgkGerekli?: boolean | null;
  /**
   * Sözleşmenin SUT listesinden çözülen SGK bedeli. **null ise listede yok** -
   * ekran bedeli kullanıcıdan ister. Bulunamayınca sessizce 0 yazmak, tutarın
   * tamamını sigortaya/hastaya yükler (kullanıcı: "sgk sut fiyatını da bulup
   * atması gerekirdi, eğer yoksa ekrandan onu alması gerekir").
   */
  sgkFiyat?: number | null;
  /** SUT listesinin fiyatı KDV dahil mi. */
  sgkKdvDahil?: number | null;
}

/**
 * KAMPANYALI FIYATIN SATIR KARSILIGI (274). Belge kartI ve randevu->basvuru
 * donusumu ayni kurali isletmeli, o yuzden karar TEK YERDE:
 *
 *   YUZDE  -> birim fiyat LISTE fiyati kalir, indirim SATIR ISKONTOSUNA gider.
 *             Faturada "liste 1.000 · %20 iskonto · net 800" gorunur; kuruma
 *             karsi indirimin gerekcesi belgenin uzerinde durur.
 *   TUTAR  -> paket/sabit anlasma fiyati; dogrudan birim fiyat olur, iskonto
 *             alanina dokunulmaz.
 *
 * Kampanya kalemi vurmadiysa (satirId yok) sonuc duz liste fiyatidir.
 * `null` doner: fiyat cozulemedi - cagiran kendi varsayilanini korur.
 */
export function kampanyaKalemFiyati(f: KalemFiyati):
    { birimFiyat: number; iskonto?: number; dovizCinsi?: string | null;
      kampanyaSatirId?: number } | null {
  if (!f.satirId) {
    return f.fiyat != null && f.fiyat > 0
      ? { birimFiyat: f.fiyat, dovizCinsi: f.dovizCinsi } : null;
  }
  const yuzde = f.iskontoTipi !== 2;
  const taban = yuzde ? f.bazFiyat : f.fiyat;
  if (taban == null || taban <= 0) return null;

  return {
    birimFiyat: taban,
    dovizCinsi: f.dovizCinsi,
    kampanyaSatirId: f.satirId,
    ...(yuzde ? { iskonto: Number(f.iskonto) || 0 } : {}),
  };
}

/**
 * SGK (SUT) TARAFINI SATIRA ISLER - 483.
 *
 * Tarife fiyatindan AYRI yurur: TSS'de satirda iki fiyat vardir ve tarife
 * cozulemese bile SGK bedeli sorulmalidir. `sgkGerekli` kutuyu acar,
 * `sgkListe` bos kalirsa ekran uyarir - eskiden bedel bulunamayinca sessizce
 * 0 yaziliyor, tutarin tamami sigortaya/hastaya yukleniyordu.
 */
export function sgkBedeliUygula(satir: SatirDurumu, f: KalemFiyati): SatirDurumu {
  const gerekli = !!f.sgkGerekli;
  if (!gerekli) {
    // Rota degisti ve artik SGK payi yok: eski bedel satirda kalmasin.
    return satir.sgkGerekli ? { ...satir, sgkGerekli: false, sgkListe: '' } : satir;
  }
  // SUT listesi BRUT tutuluyorsa matraha inilir - kovalar KDV haric saklanir.
  const dahil = Number(f.sgkKdvDahil ?? 0) === 1;
  const bulundu = f.sgkFiyat != null && f.sgkFiyat > 0;
  return {
    ...satir,
    rota: f.rota ?? satir.rota,
    sgkGerekli: true,
    sgkListeBulundu: bulundu,
    // Kullanicinin ELLE girdigi bedel korunur: liste sonradan sorulsa da
    //   ekranda yazilan kaybolmasin.
    sgkListe: bulundu
      ? String(dahil ? matraha(f.sgkFiyat!, satir.kdv ?? 0) : f.sgkFiyat)
      : (satir.sgkListe ?? ''),
  };
}

/** Kampanyali fiyati BELGE SATIRINA isler. Fiyat cozulemezse satir aynen doner. */
export function kampanyaFiyatiUygula(satir: SatirDurumu, f: KalemFiyati): SatirDurumu {
  // SGK bedeli tarife fiyatindan BAGIMSIZ islenir: tarife listede yoksa da
  //   SUT kutusu acilmali (TSS satirinda iki fiyat vardir).
  satir = sgkBedeliUygula(satir, f);
  const y = kampanyaKalemFiyati(f);
  if (!y) return satir;

  // KDV DAHIL LISTE: liste fiyati BRUTTUR, belgede saklanan ise MATRAH.
  //   Cevrim yapilmazsa %20 KDV'li bir kalem dogrudan %20 pahali yazilir ve
  //   hata ancak faturada goze carpar. Mod satirda saklanir - fiyat penceresi
  //   "Dahil/Hariç" combosunu bununla acar (kullanici degistirebilir).
  const dahil = Number(f.kdvDahil ?? 0) === 1;
  const kdvOrani = dahil ? (satir.kdv ?? 0) : 0;
  const metin = String(dahil ? matraha(y.birimFiyat, kdvOrani) : y.birimFiyat);
  return {
    ...satir,
    kdvDahil: dahil ? 1 : 0,
    birimFiyat: metin, dovizFiyat: metin,
    fiyatDovizi: y.dovizCinsi || satir.fiyatDovizi,
    iskonto: y.iskonto !== undefined ? String(y.iskonto) : satir.iskonto,
    kampanyaSatirId: y.kampanyaSatirId ?? satir.kampanyaSatirId,
    // Katilim payi fiyatla BIRLIKTE gelir (291): SGK modunda sunucu bundan
    //   paylastirir, oran modunda alan yok sayilir.
    //
    // KDV DAHIL LISTEDE KATKI DA BRUTTUR (591, kullanici: "hasta katkı 750
    //   KDV dahildi, sen tekrar KDV eklemişsin"): birim fiyat matraha
    //   cevriliyordu, katki cevrilmiyordu - 750 TL dahil katki satira matrah
    //   yazilip %10 KDV eklenince 825 TL oluyordu.
    katkiTutar: f.katki != null && f.katki > 0
      ? String(matraha(f.katki, kdvOrani)) : satir.katkiTutar,
  };
}

/**
 * PAKET (124) icerigini satirlara acar ve paket satirinin HEMEN ALTINA yazar.
 *
 * Icerik adetleri paketin adediyle CARPILIR (2 paket x 3 adet = 6). Ayni
 * paketin onceki icerik satirlari once temizlenir - miktar degisince yeniden
 * uretilir, yoksa eski dagilim gride birikirdi.
 */
export function paketIcerigiUygula(
  mevcut: readonly SatirDurumu[],
  paket: SatirDurumu,
  icerik: readonly { stokId: number; kod: string; ad: string; adet: number;
                     kdv?: number; izleme?: number; fiyat?: number }[],
): SatirDurumu[] {
  const temiz = mevcut.filter(x => x.paketAnahtar !== paket.anahtar);
  const adet = hamSayi(paket.adet) || 1;
  let anahtar = sonAnahtar(temiz);
  const yeniler = icerik.map(i => ({
    ...bosSatir(++anahtar),
    satirTur: 1,
    stokId: i.stokId,
    stokKodu: i.kod,
    stokAdi: i.ad,
    adet: String(i.adet * adet),
    kdv: String(i.kdv ?? 0),
    izleme: i.izleme ?? 0,
    // FIYAT: pakette girilmisse o, girilmemisse stogun kendi kart fiyati
    //   (sunucu karar verir - belge yonune gore alis/satis).
    birimFiyat: String(i.fiyat ?? 0),
    dovizFiyat: String(i.fiyat ?? 0),
    aciklama: `${paket.stokKodu} paketi içeriği`,
    paketAnahtar: paket.anahtar,
  }));
  const yer = temiz.findIndex(x => x.anahtar === paket.anahtar);
  return yer < 0
    ? [...temiz, ...yeniler]
    : [...temiz.slice(0, yer + 1), ...yeniler, ...temiz.slice(yer + 1)];
}

/**
 * IADE (132) satirlari: kalem stok aramadan degil, carinin ONCEKI
 * belgelerinden secilir - fiyat/iskonto/KDV kaynaktan gelir ve kaynak satir
 * bagi (kaynakSatirId) korunur; iade edilen miktar o bagdan hesaplanir.
 */
export function iadeSatirlari(
  secilenler: readonly IadeSatiri[], baslangicAnahtar: number,
): SatirDurumu[] {
  let anahtar = baslangicAnahtar;
  return secilenler.map(r => ({
    ...bosSatir(++anahtar),
    satirTur: r.hizmetId ? 2 : 1,
    stokId: r.stokId ?? null,
    hizmetId: r.hizmetId ?? null,
    stokKodu: String(r.stokKodu ?? ''),
    stokAdi: String(r.stokAdi ?? r.aciklama ?? ''),
    adet: String(r.secilenMiktar ?? r.kalanMiktar),
    birimFiyat: String(r.birimFiyat),
    dovizFiyat: String(r.birimFiyat),
    iskonto: String(r.iskonto ?? 0),
    kdv: String(r.kdv ?? 0),
    izleme: Number(r.izleme ?? 0),
    izlemeKodu: String(r.izlemeKodu ?? ''),
    // Kaynak satir bagi: iade edilen miktar bu bagdan hesaplanir.
    kaynakSatirId: r.satirId,
    aciklama: `İade — ${r.belgeNo}`,
  }));
}
