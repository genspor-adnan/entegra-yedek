import { yerelAnMetni } from '../../bilesenler/bicim';
import type { BasvuruBilgi } from '../../bilesenler/belge/BasvuruSekmesi';

/**
 * SUNUCU YANITINI KART DURUMUNA CEVIRME - saf fonksiyonlar.
 *
 * Belge acilis effect'i 113 satirdi ve icinde 40'a yakin `setX(...)` cagrisi
 * vardi; her alanin cevrimi (tarih kirpma, null/0 ayrimi, doviz zinciri, depo
 * takasi) o yiginin arasinda kayboluyordu. Cevrim buraya alindi: effect artik
 * yalniz "oku, cevir, yaz" yapiyor.
 *
 * Neden onemli: cevrim hatalari SESSIZ. Yanlis kirpilmis bir tarih ya da
 * `null` yerine `0` yazilmis bir kimlik ekranda dogru gorunur, hata ancak
 * belge yeniden kaydedilince (yanlis kurum, kaymis saat) ortaya cikar.
 */

/** Kaynak: `BelgeYaniti.belge` - sunucudan ham gelen sozluk. */
type Belge = Record<string, unknown>;

const metin = (v: unknown): string => String(v ?? '');
/** Bos/`null` KIMLIGI 0'a degil `null`'a cevirir - 0 gecerli bir id degil. */
const kimlik = (v: unknown): number | null => (v != null ? Number(v) : null);
/** `datetime-local` kutusu 16 karakter ister ("2026-09-04T10:00"). */
const dakika = (v: unknown): string | null => (v ? String(v).slice(0, 16) : null);
const kisi = (id: unknown, ad: unknown) =>
  (id ? { id: Number(id), ad: metin(ad) } : null);

/**
 * BASVURU + PROVIZYON alanlari (296/299/300).
 *
 * Sayisal alanlar `null` korur (secilmemis), DURUM alanlari 0'a duser: SGK/OSS
 * durumu "provizyon alinmadi" (0) olarak baslar, bos birakilmaz - provizyon
 * sekmesindeki rozet ancak boyle dogru renk verir.
 */
export function yanittanBasvuruBilgi(b: Belge): BasvuruBilgi {
  return {
    basvuruTuru: kimlik(b.basvuruTuru),
    gelisSekli: kimlik(b.gelisSekli),
    gelisNedeni: kimlik(b.gelisNedeni),
    oda: kimlik(b.oda),
    siraNo: metin(b.siraNo),
    refakatci: metin(b.refakatci),
    ambulansHastaNo: metin(b.ambulansHastaNo),
    ambulansBileklikNo: metin(b.ambulansBileklikNo),

    // PROVIZYON (299) - belge_provizyon 1:1; SGK ve ozel sigorta ayri.
    sgkDurum: b.sgkDurum != null ? Number(b.sgkDurum) : 0,
    sgkProvizyonNo: metin(b.sgkProvizyonNo),
    sgkProvizyonTipi: kimlik(b.sgkProvizyonTipi),
    sgkProvizyonTarihi: dakika(b.sgkProvizyonTarihi),
    sgkGecerlilik: dakika(b.sgkGecerlilik),
    sgkKarsilama: b.sgkKarsilama != null ? String(b.sgkKarsilama) : '',
    sgkTutar: b.sgkTutar != null ? String(b.sgkTutar) : '',
    sgkRedNedeni: metin(b.sgkRedNedeni),
    sgkSigortaTuru: metin(b.sgkSigortaTuru),
    sgkBasvuruNo: metin(b.sgkBasvuruNo),
    sgkTakipNo: metin(b.sgkTakipNo),
    sgkTakipTarihi: dakika(b.sgkTakipTarihi),
    sgkTakipTuru: kimlik(b.sgkTakipTuru),
    sgkTesisKodu: metin(b.sgkTesisKodu),
    sgkMustehaklik: b.sgkMustehaklik != null ? Number(b.sgkMustehaklik) : 0,
    // Mustehaklik ZAMANI salt okunur - kirpilmaz, sunucunun yazdigi gibi durur.
    sgkMustehaklikZaman: b.sgkMustehaklikZaman ? String(b.sgkMustehaklikZaman) : null,
    sgkSevkli: b.sgkSevkli != null ? Number(b.sgkSevkli) : 0,
    sgkSevkKurum: metin(b.sgkSevkKurum),

    ossKurumId: kimlik(b.ossKurumId),
    ossKurumAdi: metin(b.ossKurumAdi),
    ossDurum: b.ossDurum != null ? Number(b.ossDurum) : 0,
    ossProvizyonNo: metin(b.ossProvizyonNo),
    ossProvizyonTarihi: dakika(b.ossProvizyonTarihi),
    ossGecerlilik: dakika(b.ossGecerlilik),
    ossKarsilama: b.ossKarsilama != null ? String(b.ossKarsilama) : '',
    ossTutar: b.ossTutar != null ? String(b.ossTutar) : '',
    ossRedNedeni: metin(b.ossRedNedeni),
    ossPoliceNo: metin(b.ossPoliceNo),
    ossHasarNo: metin(b.ossHasarNo),
    ossBrans: metin(b.ossBrans),
    provizyonAciklama: metin(b.provizyonAciklama),
  };
}

/** Karta yazilacak baslik alanlari - effect bunlari tek tek setX'e dagitir. */
export interface BaslikDurumu {
  tur: number;
  cari: { id: number; unvan: string };
  tarih: string;
  seri: string;
  vadeGun: string;
  aciklama: string;
  odeyenKurumId: number | null;
  fiyatListesiId: number | null;
  bolumId: number | null;
  personelId: number | null;
  kampanyaId: number | null;
  kampanyaAdi: string;
  teklifDurum: string;
  revizeNo: string;
  teklifKonusu: string;
  teklifTeslim: string;
  depo: { id: number; ad: string } | null;
  girisDepo: { id: number; ad: string } | null;
  satici: { id: number; ad: string } | null;
  teslimEden: { id: number; ad: string } | null;
  teslimAlan: { id: number; ad: string } | null;
  teslimSekli: number;
  senaryo: number;
  sevkTarihi: string;
  soforTckn: string;
  aracPlaka: string;
  soforAd: string;
  fisTipi: number;
  faturaTipi: number;
  raporDovizi: string;
  ekstreDovizi: string;
  belgeKuru: string;
}

/** TRANSFER belgesi (20): "depo" CIKIS deposudur, giris ayri alanda tutulur. */
const TRANSFER = 20;

/**
 * Belge basligini karta cevirir.
 *
 * @param yerelPara kullanicinin yerel para birimi - belgede doviz yoksa
 *   rapor/ekstre dovizi buna duser (bos string ekranda anlamsiz gorunur).
 */
export function yanittanBaslik(b: Belge, yerelPara: string): BaslikDurumu {
  const tur = Number(b.tur);
  // Alis belgesi GIRIS deposunu, satis CIKIS deposunu kullanir. Transferde
  //   ikisi de dolu; digerlerinde hangisi doluysa tek depo alanina yansir.
  const cikis = kisi(b.cikisDepoId, b.cikisDepoAdi);
  const giris = kisi(b.girisDepoId, b.girisDepoAdi);

  return {
    tur,
    cari: { id: Number(b.tarafId), unvan: metin(b.tarafUnvan) },
    // Bos tarihle kayitli (eski/dis kaynakli) belgede alan bos kalmasin:
    //   zorunlu alan, simdiki an ile acilir (kullanici).
    tarih: dakika(b.belgeTarihi) || yerelAnMetni(new Date()),
    seri: metin(b.belgeSeri),
    vadeGun: String(b.vadeGun ?? 0),
    aciklama: metin(b.aciklama),
    odeyenKurumId: kimlik(b.odeyenKurumId),
    // Fiyat listesi 0 ise "liste yok" demektir - combo bos gorunmeli.
    fiyatListesiId: Number(b.fiyatListesiId) || null,
    bolumId: kimlik(b.bolumId),
    personelId: kimlik(b.personelId),
    kampanyaId: kimlik(b.kampanyaId),
    kampanyaAdi: metin(b.kampanyaAdi),
    teklifDurum: String(b.teklifDurum ?? '1'),
    revizeNo: metin(b.revizeNo),
    teklifKonusu: metin(b.teklifKonusu),
    teklifTeslim: metin(b.teklifTeslim),
    depo: tur === TRANSFER ? cikis : giris ?? cikis,
    girisDepo: tur === TRANSFER ? giris : null,
    satici: kisi(b.saticiId, b.saticiAdi),
    teslimEden: kisi(b.teslimEdenId, b.teslimEdenAdi),
    teslimAlan: kisi(b.teslimAlanId, b.teslimAlanAdi),
    teslimSekli: Number(b.teslimSekli ?? 0),
    senaryo: Number(b.senaryo ?? 0),
    sevkTarihi: dakika(b.irsaliyeTarihi) ?? '',
    soforTckn: metin(b.soforTckn),
    aracPlaka: metin(b.aracPlaka),
    soforAd: metin(b.soforAd),
    // AYNI KOLON (belge.tipi) iki ekranda farkli okunur: stok fisinde fis tipi
    //   0 olabilir (tipsiz fis), FATURADA ise 0 anlamsizdir - eski kayitlarda
    //   varsayilan "Alış / Satış" (1) gosterilir (130).
    fisTipi: Number(b.tipi ?? 0),
    faturaTipi: Number(b.tipi) || 1,
    // Doviz zinciri: kendi alani > bir ustteki > yerel para.
    raporDovizi: metin(b.raporDovizi ?? b.belgeDovizi) || yerelPara,
    ekstreDovizi: metin(b.ekstreDovizi ?? b.raporDovizi) || yerelPara,
    belgeKuru: String(b.dovizKuru ?? 1),
  };
}
