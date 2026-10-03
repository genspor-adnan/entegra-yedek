import { telefonAlaniMi } from '../alanBicim';
import { telefonBicimle } from '../bicim';
import { detayFarki, type DetayDurumu } from '../GenDetayTablo';
import type { Deger } from '../kartAlanCizim';
import type { KartMetaYaniti } from '../../api/sozlesme';

/**
 * KART YAZMA GOVDESI (§3.2): yalniz DEGISEN alanlar + detay FARKI.
 *
 * Saf fonksiyon - `GenForm`'un `kaydet()` govdesinden ayrildi: burada kural
 * var, orada akis (yukleniyor bayragi, hata gosterimi, sekmeye atlama). Kural
 * tek basina okunabilir ve test edilebilir olmali; uc alan turetmesi sessizce
 * degisirse fatura/kart alanlari yanlis yazilirdi.
 */
export function kartGovdesiKur(g: {
  kaynak: string;
  meta: KartMetaYaniti | null;
  deger: Record<string, Deger>;
  /** Ilk hale gore degisen kart alanlari (GenForm hesaplar). */
  degisenAlanlar: Record<string, unknown>;
  detaylar: Record<string, DetayDurumu>;
  surum?: string;
  personelGibiKart: boolean;
  /** Hekim unvan oneki - ad/soyadin ONUNE gelir ("Prof.Dr. Halil GÜNEŞ"). */
  unvanOneki: string;
  /**
   * Bir detayin SUNUCUYA GONDERILEBILIR alan adlari. Grid, satirda gosterim
   * icin ek anahtar tutabiliyor (kampanya urun satirinda secilen urunun adi);
   * bunlar katalogda alan olmadigindan sunucu "Bilinmeyen alan" der.
   */
  detayAlanlari(m: KartMetaYaniti | null, ad: string): string[] | undefined;
}) {
  const { kaynak, meta, deger, degisenAlanlar, detaylar,
          surum, personelGibiKart, unvanOneki, detayAlanlari } = g;

  // Telefon TEK BICIMDE saklanir: kullanici gruplu da yazsa gruplamadan da
  //   yazsa DB'ye "+90 532 418 77 20" gider. Aksi halde ayni numara iki farkli
  //   metinle durup arama/mukerrer kontrolu kaciriyordu.
  const kart: Record<string, unknown> = { ...degisenAlanlar };
  Object.keys(kart).forEach(ad => {
    if (telefonAlaniMi(ad) && typeof kart[ad] === 'string' && kart[ad])
      kart[ad] = telefonBicimle(kart[ad] as string);
  });

  const govde = {
    surum,
    kart,
    detaylar: Object.fromEntries(
      Object.entries(detaylar)
        .map(([ad, durum]) => [ad, detayFarki(durum, detayAlanlari(meta, ad))])
        .filter(([, fark]) => {
          const f = fark as ReturnType<typeof detayFarki>;
          return (f.eklenen?.length ?? 0) + (f.degisen?.length ?? 0)
               + (f.silinen?.length ?? 0) > 0;
        })),
  };

  // PERSONEL / DIS DOKTOR: unvan YALNIZ ONEK (940, kullanici: "personelde
  //   unvan tam adi tutmasin, sadece Dr. veya Prof.Dr. gibi olsun"). Unvansiz
  //   kiside BOS gonderilir - eski tam ad kalmasin; gorunen ad sunucuda
  //   fn_taraf_ad(unvan, ad, soyad).
  if (kaynak === 'personel' || kaynak === 'dis-hekim') {
    govde.kart.unvan = unvanOneki;
  } else if (personelGibiKart || kaynak === 'hasta-aday') {
    // HASTA: unvan TAM AD - DB'de NOT NULL, ad+soyad'dan birlestirilir.
    const ad = String(deger.ad ?? '').trim();
    const soyad = String(deger.soyad ?? '').trim();
    const unvanMetni = [ad, soyad].filter(Boolean).join(' ');
    if (unvanMetni) govde.kart.unvan = unvanMetni;
  }
  // ADAY HASTA (266): DOSYA NO = CEP NUMARASI (kullanici). Kullanicidan ayrica
  //   dosya no istemek yerine turetiliyor; elle girilmis kod varsa ona
  //   dokunulmaz.
  if (kaynak === 'hasta-aday' && !String(deger.kod ?? '').trim()) {
    const cep = String(deger.cepTel ?? '').trim();
    if (cep) govde.kart.kod = cep;
  }

  return govde;
}
