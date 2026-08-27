import { type SatirDurumu, bosSatir } from './belgeSatir';
import type { IadeSatiri } from '../bilesenler/belge/IadeSatirPenceresi';
import { hamSayi } from '../bilesenler/bicim';

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

/**
 * LISTE FIYATINI satira isler (205). Fiyat yoksa/0 ise satir AYNEN doner -
 * cagiran kimlik karsilastirmasiyla (sonuc === satir) "bulunamadi" sayabilir.
 * dovizFiyat da yazilir: kaydetme hatti yerel fiyati dovizden turetir, eski
 * doviz fiyati kalirsa Kaydet yeni fiyati sessizce geri alir.
 */
export function listeFiyatiUygula(
  satir: SatirDurumu, f: { fiyat: number | null; dovizCinsi?: string | null },
): SatirDurumu {
  if (f.fiyat === null || f.fiyat <= 0) return satir;
  const metin = String(f.fiyat);
  return { ...satir, birimFiyat: metin, dovizFiyat: metin,
           fiyatDovizi: f.dovizCinsi || satir.fiyatDovizi };
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
