import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { c } from '../dil/ceviri';
import { api, oturum } from '../api/istemci';
import { dokumanDosyaAdi, dosyaIndirUrl } from './indir';
import { useOturum } from '../kimlik/OturumBaglami';
import {
  ApiHatasi, hataAyristir, urunAdi,
  type KartMetaYaniti, type KartYetkisi, hataMetni } from '../api/sozlesme';
import { GenDetayTablo, type DetayDurumu, type Satir, bosDetay, detayFarki }
  from './GenDetayTablo';
import { KademeGridi } from './prim/KademeGridi';
import { Modal } from './Modal';
import { yerelAnMetni, bugunIso, hamSayi, kidemMetni } from './bicim';
import { PaketSekmesi } from './PaketSekmesi';
import { KartGrupSekmesi } from './kart/KartGrupSekmesi';
import { alanCizici, type Deger } from './kartAlanCizim';
import { kartDogrula } from './kartDogrulama';
import { guvenli, mesaj as bilgiMesaji, onay as onaySor } from './mesaj';
import {
  degisenAlanlar as degisenAlanlarHesapla, kartDegistiMi,
} from './kartDegisim';
import {
  alanGruplari, sekmeleriKur, detaySekmeAnahtari, grupSekmeAnahtari,
  KIMLIK_GRUP, TEK_SUTUN_KARTLAR, type SekmeTanimi,
} from './kartSekmeleri';
import { TekKayit } from './TekKayit';
import { GenGrid } from './GenGrid';
import { HekimGonderimOzeti } from './radyoloji/HekimGonderimOzeti';
import { IstemAkisi } from './radyoloji/IstemAkisi';
import { KontrolListesi } from './radyoloji/KontrolListesi';
export { Modal };
import { RolYetkiMatrisi } from './RolYetkiMatrisi';
import { ekKaydetleriCalistir, ekKaydetTemizle } from './kartEkKaydet';
import { DokumanGalerisi } from './DokumanGalerisi';
import { StokDurumSekmesi } from './StokDurumSekmesi';
import { StokHareketSekmesi } from './StokHareketSekmesi';
import { HizmetListeFiyatlari } from './HizmetListeFiyatlari';
import { TarafArama } from './TarafArama';
import { StokAramaPenceresi } from './StokAramaPenceresi';
import { KategoriSuzgeci } from './KategoriSuzgeci';
import { RandevuUygunSaatler } from './RandevuUygunSaatler';
import { RandevuOzetSeridi } from './RandevuOzetSeridi';
import { RandevuTetkikUyum } from './RandevuTetkikUyum';
import { telefonAlaniMi } from './alanBicim';
import { telefonBicimle } from './bicim';
import { OncekiBasvurular } from './belge/BasvuruSekmesi';
import { BelgeKarti } from '../sayfalar/BelgeKarti';

interface Props {
  kaynak: string;
  id: number | 'yeni';
  baslik?: string;
  onKapat?(): void;
  /** Bir GRUP sekmesinin icerigini sarmalar - ekran o sekmeye alt sekme cubugu
      ya da ek bolum ekleyebilir (Firma Bilgileri'nde e-Belge sekmesi: Genel /
      Seri / XSLT / tur ayarlari). Verilmezse sekme dogrudan cizilir. */
  sekmeSarmalayici?(sekmeBasligi: string, icerik: React.ReactNode,
                    deger: Record<string, Deger>,
                    /** Bir DETAYI (ör. vitaller) etiket+kutu ızgarası olarak
                        istenen yere çizer - anamnez sekmesinin sağ paneline
                        düzenlenebilir vital ızgarası koymak için. */
                    izgaraCiz?: (detayAd: string) => React.ReactNode): React.ReactNode;
  /** SERIDIN USTUNDE cizilen ekran-ozel baglam kutulari (or. muayene kartinda
      hasta/alerji/aktif ilac - mockup muayene_karti.html). Kart degerini alir
      cunku hangi hastanin gosterilecegi karttan cikar. */
  ustBaglam?(deger: Record<string, Deger>): React.ReactNode;
  /** Kart ARAC CUBUGUNUN sagina yaslanan durum ozeti (mockup .statusbar). */
  altBilgi?(deger: Record<string, Deger>): React.ReactNode;
  /** Kart BASLIGINDA (surum rozetinin yaninda) ekran-ozel rozet - or.
      muayene durumu. Kart alan izgarasinda ayri bir kutu tutmaktansa
      basligda durur (kullanici). */
  baslikEk?(deger: Record<string, Deger>): React.ReactNode;
  /** Kaydet/Sil'in yanina ekran-ozel EYLEM dugmeleri (mockup muayene kartinda
      "Muayeneye Al · Tamamla · Istem Ac · Sablon"). Dugmeler yalnizca ucu
      cagirir; kural sunucuda kalir. */
  ekAraclar?(deger: Record<string, Deger>): React.ReactNode;
  /**
   * KIMLIK SERIDINI EKRANIN ISTEDIGI YERE TASIR. Verilirse serit kartin
   * ustunde cizilmez; sarmalayici dondurdugu dugumu nereye koyacagina karar
   * verir (muayene karti: seridi bir modala alip baglam seridindeki "Bugun"
   * kutusundan aciyor - hekimin gunluk isi sekmelerde, kimlik alanlari
   * arada bir bakilan bilgi).
   */
  seritSarmalayici?(serit: React.ReactNode,
                    deger: Record<string, Deger>): React.ReactNode;
  /** Ust seritte kalacak alan adlari. Verilmezse "Kimlik" grubunun TAMAMI seritte
      (varsayilan davranis). Verilirse serit bunlarla sinirlanir, grubun kalani
      "Kimlik" sekmesine duser - kimlik alani cok olan kartlarda serit sismesin. */
  seritAlanlari?: string[];
  onKaydedildi?(id: number): void;
  /** Mockup'ta olup backend'i henuz olmayan sekmeler (or. "UTS Bilgileri") - "yakinda" gosterilir. */
  yerTutucuSekmeler?: string[];
  /** "Genel" sekmesinde alt-bolum kutularinin YANINA mockup'taki gibi bos "Resim" kutusu ekler. */
  resimYerTutucu?: boolean;
  /** TarafArama'nin kendi Yeni/Duzenle'siyle acilan ic-ice Kisi Karti'nda "Cariye Bağla"
      butonu GIZLENIR - yoksa TarafArama'nin icinden bir baska TarafArama acilir, tekrarli/
      kafa karistirici olur (kullanici). */
  cariyeBaglaGizli?: boolean;
  /** Yeni kayitta mantik alanlara EKRANA OZEL varsayilan (ör. Tedarikçi Listesi'nden
      "+Yeni" -> tedarikci:true, musteri:false) - ayni "cari" karti Musteri/Tedarikci
      ekranlarindan farkli varsayilanla acilsin diye. */
  /** Ekrana ozel varsayilan: mantik alan icin boolean, kod/sayi alani icin
      sayi (or. Cek Listesi'nden 'Yeni' -> tur=1). */
  yeniKayitVarsayilanlari?: Record<string, boolean | number | string>;
  /** Bu EKRANDA cizilmeyecek alanlar (ör. Aday kartinda "Kod"). Alan katalogda
      kalir; deger tasinir, form onu gostermez. */
  gizliAlanlar?: string[];
  /**
   * DETAYI GRUP SEKMESINE GOMER: `{ bulgular: { grup: 'Muayene' } }`. Detay
   * kendi sekmesini almaz; tablosu o grubun alanlarinin ALTINA cizilir.
   * Mockup "Fizik Muayene" boyle: ustte sablon, altinda sistem/bulgu tablosu.
   * `gizli` o gride cizilmeyecek alanlar, `etiket` ise kutu yerine DUZ METIN
   * cizilecek alanlar (satirin kimligi - sunucunun yazdigi degerler).
   */
  detayGrupta?: Record<string, { grup: string; gizli?: string[]; etiket?: string[];
                                 sinif?: string; ustte?: boolean; sade?: boolean;
                                 /** GenGrid gorunumu: satir ici kutu yok,
                                     hucreler duz metin (liste gridi gibi). */
                                 gridKipi?: boolean;
                                 /** Salt gorunum: duzenleme sekmenin arac
                                     cubugundaki uclardan yapilir. */
                                 salt?: boolean;
                                 /** Baslikta "＋" yok: satiri sunucu ucu acar. */
                                 ekleGizli?: boolean }>;
  /**
   * DETAY SEKMESI GRID YERINE TEK KAYIT IZGARASI: en ustteki satir (detayin
   * kendi siralamasina gore SONUNCU olcum) mockup'taki gibi etiket + kutu
   * izgarasinda duzenlenir; eski satirlar altta salt gorunum listede kalir.
   * Vital bulgular boyle: hekim "bu muayenenin olcumu"nu okur/duzeltir,
   * gecmis olcumler kayit tarihcesidir.
   */
  detayIzgara?: Record<string, { baslik?: string; sinif?: string;
                                 yeniDugmesi?: boolean; not?: string;
                                 /** Yalnız bu alanlar, verilen sırayla. */
                                 alanSirasi?: string[];
                                 /** Gecmis listesinde CIZILMEYECEK alanlar. */
                                 gecmisGizli?: string[] }>;
  /**
   * KENDI SEKMESINDE cizilen detaya ekran-ozel secenekler (gizli kolon, grid
   * kipi, sade cerceve). `detayGrupta` yalnizca bir GRUBA gomulen detaya
   * uygulanir; rapor gibi kendi sekmesi olan detaylar icin bu kullanilir.
   */
  detaySecenekleri?: Record<string, { gizli?: string[]; sinif?: string;
                                      sade?: boolean; gridKipi?: boolean;
                                      salt?: boolean; ekleGizli?: boolean;
                                      /** YALNIZ gridde gizli - modalde durur. */
                                      gridGizli?: string[] }>;
  /** Sekmesi acilmayacak detaylar (ekranda baska yerde ciziliyorsa). */
  gizliDetaylar?: string[];
  /**
   * EKRANA OZEL EK SEKMELER: baslik + icerigi cizen fonksiyon (mockup muayene
   * kartinin e-Recete / Rapor / Sevk / Islem & Ucret / Gecmis / Dosyalar
   * sekmeleri). Cerceve yalnizca sekmeyi acar; iceriginin verisini ve
   * kurallarini ekran (ve sunucu uclari) tasir. Yeni kayitta acilmaz.
   */
  ekSekmeler?: { anahtar: string; baslik: string; ciz(): React.ReactNode }[];
  /** Sekme sirasi (basliklara gore) - mockup sirasi. */
  sekmeSirasi?: string[];
  /** Bu EKRANDA acilmayacak sekmeler (ör. Aday kartinda "Fatura Bilgileri").
      Ayni kart farkli ekranlarda farkli genislikte kullanilabilsin diye. */
  gizliSekmeler?: string[];
  /**
   * DISARIDAN TAZELEME: sayi degisince kart sunucudan YENIDEN okunur. Ekranin
   * kendi dugmeleri (tani ekle, sablon uygula, tumu normal...) sunucuda satir
   * acar; kart o satirlari ancak yeniden okuyunca gorur - kullanici "eklendi
   * diyor ama goremiyorum" diyordu.
   */
  tazeleAnahtari?: number;
  /** Bu EKRANDA zorunlu sayilacak alanlar (ör. Aday kartinda "Temsilci").
      Katalogda zorunlu YAPILMAZ: ayni alan Musteri kartinda bos olabilir ve
      eski kayitlarin duzenlenmesini kilitlerdi. */
  zorunluAlanlar?: string[];
}

/** Modal sarmalayici — mockup'taki .kaperde / .kawin duzeni. */



// Telefon alanlari ADINDAN taninir (telefonAlaniMi) - sabit liste yeni bir
//   alanda (faks, gsm, 2. telefon...) unutuluyordu.


/**
 * Kart sozlesmesini (§3) tuketen genel form.
 *
 *  - Alan listesi, etiketler, zorunluluk ve uzunluk sinirlari SUNUCUDAN gelir
 *    (/alanlar). Yetkisiz alan hic donmedigi icin arayuzde gizleme mantigi yok.
 *  - Kaydetmede `surum` geri gonderilir; baskasi degistirmisse sunucu 409 doner ve
 *    kullaniciya "guncel hali al" secenegi sunulur (§1.3).
 *  - Alan hatalari (`alanlar[]`) ilgili girdinin altina yazilir.
 *  - Detaylar FARK olarak gonderilir (eklenen / degisen / silinen), tam liste degil.
 */
// SEKME IKONLARI KALDIRILDI (kullanici): on sekmeli kartta ikonlar seridi
// ikinci satira tasiriyordu; sekme adi zaten ayirt ediyor.


/**
 * FIYAT LISTESI SATIRINDA TARIFE TIPINE GORE GIZLENEN ALANLAR (518).
 * Tip 0 (genel) hicbir sey gizlemez - eski listeler oldugu gibi calisir.
 */
/**
 * SATIR ICI GIRIS YAPILACAK ALANLAR tarife tipine gore (533).
 *   Özel  : fiyat elle, katki elle
 *   TTB   : KATSAYI ve CARPAN elle - fiyat carpimdan doğar, yazilamaz
 *   SUT   : yalniz katki - fiyat SKRS'den kilitli
 * Fiyat kutusunu TTB/SUT'ta acik birakmak, kullaniciya tutmayacagi bir soz
 * vermekti: girilen sayi kaydedilirken tetik tarafindan yok sayiliyor.
 */
function tarifeHizli(tip: number): Set<string> {
  if (tip === 2) return new Set(['tabanFiyat', 'carpan', 'katkiTutar']);
  if (tip === 3) return new Set(['katkiTutar']);
  return new Set(['fiyat', 'katkiTutar']);
}

/**
 * TTB/HUV SATIRINDA FIYAT ANINDA DOGSUN (533, kullanici: "katsayi carpan
 * degisince fiyat aninda degissin"). Kural DB tetiginde de var (kaydeden kim
 * olursa olsun ayni sonuc); burasi EKRANIN aynasi - kullanici katsayiyi
 * yazarken fiyati gormek zorunda, kaydedip beklememeli.
 * Yuvarlama DB'de listenin kuralina gore yapilir; ekranda iki hane yeter -
 * kayittan sonra gelen deger son sozdur.
 */
function ttbFiyatTuret(durum: DetayDurumu): DetayDurumu {
  let degisti = false;
  const guncel = durum.guncel.map(s => {
    const katsayi = Number(s.tabanFiyat ?? 0);
    const carpan = Number(s.carpan ?? 0);
    if (!(katsayi > 0 && carpan > 0)) return s;
    const yeni = Math.round(katsayi * carpan * 100) / 100;
    if (Number(s.fiyat ?? 0) === yeni) return s;
    degisti = true;
    return { ...s, fiyat: yeni };
  });
  return degisti ? { ...durum, guncel } : durum;
}

function tarifeGizli(tip: number): string[] {
  // Ek katki alanlari 532'de fiyat listesinden kalkti - listede yok.
  if (tip === 1) return ['tabanFiyat', 'carpan', 'katkiTutar'];
  if (tip === 2) return [];                       // katsayi · carpan · fiyat · katki
  if (tip === 3) return ['tabanFiyat', 'carpan']; // fiyat SKRS'den, katsayi yok
  return [];
}

export function GenForm({ kaynak, id, baslik, onKapat, seritAlanlari, seritSarmalayici, sekmeSarmalayici, detayGrupta, detayIzgara, detaySecenekleri, gizliDetaylar, ekSekmeler, sekmeSirasi, tazeleAnahtari, onKaydedildi, yerTutucuSekmeler,
                          ustBaglam, altBilgi, ekAraclar, baslikEk,
                          resimYerTutucu, cariyeBaglaGizli, yeniKayitVarsayilanlari,
                          gizliAlanlar, gizliSekmeler, zorunluAlanlar }: Props) {
  const { kullanici } = useOturum();
  const yeniMi = id === 'yeni';
  // Dis hekim (305) de ad/soyad ile calisir: unvan gosterilmez, ad+soyaddan
  //   turetilir - personel/hasta kartlariyla ayni kural.
  const personelGibiKart = kaynak === 'personel' || kaynak === 'hasta'
                        || kaynak === 'dis-hekim';
  /**
   * HEKIM UNVANI (306, kullanici: "unvan alanında tutabilirsin"): Dr./Prof.Dr...
   * AYRI KOLON YOK - onek taraf.unvan icinde saklanir ("Prof.Dr. Halil GÜNEŞ").
   * Kart acilirken unvanin basindaki bilinen onek ayristirilip comboya konur,
   * kaydederken ad/soyadin onune eklenir. Boylece hekim her yerde (arama,
   * liste, rapor ciktisi) unvaniyla gorunur.
   */
  const [unvanOnek, setUnvanOnek] = useState('');
  const [unvanSecenek, setUnvanSecenek] = useState<string[]>([]);
  /**
   * Karttan okunan HAM unvan ("Op.Dr. Kerem ATALAY"). Onek ayristirmasi ayri
   * bir etkide yapilir: kod listesi ASENKRON geliyor, kart okunurken
   * secenekler henuz bos oluyor ve combo bos kaliyordu.
   */
  const [unvanHam, setUnvanHam] = useState('');
  useEffect(() => {
    if (kaynak !== 'dis-hekim' || !unvanHam || unvanSecenek.length === 0) return;
    setUnvanOnek(unvanSecenek.find(o => unvanHam.startsWith(o + ' ')) ?? '');
  }, [kaynak, unvanHam, unvanSecenek]);
  useEffect(() => {
    if (kaynak !== 'dis-hekim') return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe('hekim.unvan');
        if (!iptal) setUnvanSecenek(y.degerler.filter(d => d.aktif === 1).map(d => d.ad));
      } catch { /* liste yoksa combo bos kalir - kayit engellenmez */ }
    })();
    return () => { iptal = true };
  }, [kaynak]);

  const [meta, setMeta] = useState<KartMetaYaniti | null>(null);
  const [deger, setDeger] = useState<Record<string, Deger>>({});
  const [ilkDeger, setIlkDeger] = useState<Record<string, Deger>>({});
  const [surum, setSurum] = useState<string | undefined>();
  const [yetki, setYetki] = useState<KartYetkisi>({ duzenle: false, sil: false, gizliAlanlar: [] });
  const [detaylar, setDetaylar] = useState<Record<string, DetayDurumu>>({});
  /**
   * SAYFALI DETAY (525, kullanici: "fiyat listesinde satirlar cok fazla
   * oldugu icin yavas, paging yapsan"). Kartla yalniz ilk sayfa geliyor;
   * burada acik sayfa, sunucudaki toplam ve istek bayragi tutulur.
   */
  const [detaySayfa, setDetaySayfa] = useState<Record<string, number>>({});
  const [detayToplam, setDetayToplam] = useState<Record<string, number>>({});
  const [detaySayfaYuk, setDetaySayfaYuk] = useState<string | null>(null);
  /** Satir gridinde secili satirlar (534) - toplu islem dugmesi ust arac
      cubugunda, secim ise gridde yasiyor. */
  const [seciliSatirlar, setSeciliSatirlar] = useState<ReadonlySet<number>>(new Set());
  /** Acik toplu deger penceresi (534). */
  const [topluCarpan, setTopluCarpan] = useState(false);
  const [topluCarpanDeger, setTopluCarpanDeger] = useState('');
  /** "Durum Değiştir" acilir menusu (534). */
  const [durumMenusu, setDurumMenusu] = useState(false);

  /** Secili satirlarin DURUMUNU topluca yazar (534). 1 Aktif · 0 Pasif. */
  const topluDurum = (yeni: number) => {
    setDetaylar(t => {
      const d = t.satirlar ?? bosDetay();
      const guncel = d.guncel.map((s2, i) =>
        seciliSatirlar.has(i) ? { ...s2, durum: yeni } : s2);
      return { ...t, satirlar: { ...d, guncel } };
    });
    setDurumMenusu(false);
  };

  /**
   * SAYFALI DETAYDA SAYFA DEGISIMI (525).
   *
   * Sayfa degisince o detayin `ilk`/`guncel` dizileri YENI SAYFAYLA
   * DEGISIR - yani ekranda kaydedilmemis satir degisikligi varsa kaybolur.
   * Bu yuzden once soruluyor: sessizce yutmak, kullanicinin girdigi fiyati
   * bir daha goremeyecegi bir kayip olurdu.
   */
  /** Sayfali detayin ACIK SUZGECI (526) - sayfa degisiminde de korunur. */
  const detaySuzgec = useRef<Record<string,
    { ara?: string; cip?: string; kategori?: number }>>({});

  /** Sayfali detayin bir sayfasini SUZGECLE birlikte ceker (525/526). */
  const detaySayfaCek = async (ad: string, sayfaNo: number) => {
    if (typeof id !== 'number') return;
    setDetaySayfaYuk(ad);
    try {
      const boyu = meta?.detaylar.find(d => d.ad === ad)?.sayfaBoyu ?? 0;
      const s = detaySuzgec.current[ad] ?? {};
      const sayfa = await api.kartDetaySayfasi(kaynak, id, ad, sayfaNo, boyu || 200,
                                               s.ara, s.kategori, s.cip);
      setDetaylar(t => ({ ...t, [ad]: bosDetay(sayfa.satirlar as Satir[]) }));
      setDetaySayfa(t => ({ ...t, [ad]: sayfa.sayfa }));
      setDetayToplam(t => ({ ...t, [ad]: sayfa.toplam }));
    } catch (h) {
      await bilgiMesaji(hataMetni(h));
    } finally {
      setDetaySayfaYuk(null);
    }
  };

  /**
   * SUZGEC DEGISTI (526, kullanici: "fiyat listesi satirlardaki arama ve
   * filtreler AKTIF OLAN TUM SATIRLAR uzerinden olmali"). Suzgec sunucuda
   * uygulanir ve her zaman ILK SAYFAYA doner - 3. sayfadayken arama yapinca
   * sonucun 3. sayfasini gostermek bos grid demekti.
   */
  const detaySuzgecUygula = async (
    ad: string, suz: { ara?: string; cip?: string; kategori?: number }) => {
    detaySuzgec.current[ad] = { ...detaySuzgec.current[ad], ...suz };
    await detaySayfaCek(ad, 1);
  };

  const detaySayfaDegis = async (ad: string, yeniSayfa: number) => {
    if (typeof id !== 'number' || detaySayfaYuk) return;
    const durum = detaylar[ad];
    if (durum) {
      const fark = detayFarki(durum);
      if (fark.eklenen || fark.degisen || fark.silinen) {
        const devam = await onaySor(
          'Bu sayfada kaydedilmemiş satır değişiklikleri var. '
          + 'Sayfa değiştirilirse bu değişiklikler kaybolur. Devam edilsin mi?');
        if (!devam) return;
      }
    }
    await detaySayfaCek(ad, yeniSayfa);
  };
  /**
   * FIYAT LISTESI SATIRLARI - KATEGORI SUZGECI (kullanici: "satirlar
   * sekmesinde arama editinin sagina kategori agac combo ekle"). Secilen dal
   * ALT AGACIYLA birlikte suzer; durum burada cunku grid suzgeci cizmez,
   * yalnizca yerini verir.
   */
  const [satirKategori, setSatirKategori] =
    useState<{ id: number; agac: number[] } | null>(null);
  // Kart degisince suzgec sifirlanir: onceki listenin dali yeni listede yok.
  useEffect(() => { setSatirKategori(null) }, [kaynak, id]);
  /** Combo yalnizca SATIRLARDA GECEN kategorileri (ve ustlerini) listeler. */
  const satirKategorileri = useMemo(() => {
    if (kaynak !== 'fiyat-listesi') return undefined;
    const kume = new Set<number>();
    (detaylar['satirlar']?.guncel ?? []).forEach(r => {
      const k = Number(r.kategoriId);
      if (Number.isFinite(k) && k > 0) kume.add(k);
    });
    return kume;
  }, [kaynak, detaylar]);

  const [yukleniyor, setYukleniyor] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});
  const [cakisma, setCakisma] = useState<{ alanlar: string[]; guncel: Record<string, unknown> } | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);
  const [cariyeBaglaAcik, setCariyeBaglaAcik] = useState(false);
  /**
   * JENERIK ARAMA EKRANI ile secilen alanlar (260): hangi alan icin hangi
   * arama acik + secilen kaydin adi. Ad, lookup haritasinda olmayabilir
   * (yeni secim) - o yuzden ayri tutulur.
   */
  // uygula: secimin NEREYE yazilacagi. Bos birakilirsa kartin kendi alanina
  //   (alanDegistir) yazilir; 1:1 uzanti formu (TekKayit) kendi satirina
  //   yazmak icin kendi setter'ini gonderir - yoksa secim kart alanina
  //   dusup DETAY kaydedilmeden kaybolur.
  /** Hasta kartindan acilan basvuru: 0 = yeni, >0 = mevcut, null = kapali. */
  const [acilanBasvuru, setAcilanBasvuru] = useState<number | null>(null);
  const [aramaAlani, setAramaAlani] =
    useState<{ alan: string; kaynak: string; uygula?: (deger: string) => void } | null>(null);
  const [secilenAdlar, setSecilenAdlar] = useState<Record<string, string>>({});
  /** Katalogdaki AcilistaTarafSecimi ile acilan cari secimi (yeni kayitta). */
  const [tarafSecimAcik, setTarafSecimAcik] = useState(false);
  const [kapatmaUyarisi, setKapatmaUyarisi] = useState(false);
  // TarafArama'dan bir KISI secilirse "public.v_cari_lookup" (KodTablosu) onu bilmiyor -
  // secim sonrasi ad gorunsun diye adini ayrica burada tutuyoruz (server'a etkisi yok).
  const [bagliTarafAdi, setBagliTarafAdi] = useState<string | null>(null);
  /** Kur otomatik cekilirken / cekilemediginde alan altinda gosterilen not. */
  const [kurNotu, setKurNotu] = useState<string | null>(null);
  /** En son kuru cekilen "cins|tarih" - kayitli kartin kuru acilista ezilmesin. */
  const sonKurAnahtari = useRef<string | null>(null);

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    setHata(null);
    try {
      const ham = await api.kartAlanlari(kaynak);
      // Ekrana ozel zorunluluk: katalog degismez, bu ekranda alan yildizli
      //   gelir ve bos birakilirsa kayit engellenir.
      const zorunlulu: KartMetaYaniti = zorunluAlanlar?.length
        ? { ...ham, alanlar: ham.alanlar.map(a =>
            zorunluAlanlar.includes(a.ad) ? { ...a, zorunlu: true } : a) }
        : ham;
      // RANDEVU alanlari YALNIZ HBYS modunda (252, kullanici): ERP kurulumunda
      //   personelin "randevu verilebilir" olmasi ve randevu duzeni anlamsiz -
      //   kart hic gostermez. Urun modu 2 = HBYS (referans genel.urun_modu).
      let m: KartMetaYaniti = kullanici?.urunModu === 2 ? zorunlulu : {
        ...zorunlulu,
        alanlar: zorunlulu.alanlar.filter(a => a.ad !== 'randevuVerilebilir'),
        detaylar: zorunlulu.detaylar.filter(d => d.ad !== 'randevuAyar'),
      };
      setMeta(m);
      setYetki(m.yetki);

      const bosDetaylar: Record<string, DetayDurumu> = {};
      m.detaylar.forEach(d => { bosDetaylar[d.ad] = bosDetay() });

      if (yeniMi) {
        const baslangic: Record<string, Deger> = {};
        // Yeni kayitta Durum her zaman "Aktif" gelsin (kullanici: "yeni kart kaydında
        // varsa durum hep aktif gelsin") - DurumKodlari'nde 1 = Aktif (KartKatalogu.cs).
        m.alanlar.forEach(a => {
          baslangic[a.ad] = a.ad === 'durum' ? '1'
            // TEMSILCI varsayilani: karti acan kullanici. Cogu kayitta dogru
            //   cevap budur; farkliysa listeden degistirilir.
            : a.ad === 'temsilci' && kullanici?.id ? String(kullanici.id)
            : a.ad === 'subeId' && oturum.subeId ? String(oturum.subeId)
            : a.tip === 'mantik' ? false : '';
        });
        // Ekrana ozel mantik varsayilan (ör. Tedarikçi Listesi -> tedarikci:true) -
        // yukaridaki genel "false" varsayilaninin UZERINE yazar.
        // ONCE katalog varsayilanlari (sunucudan), SONRA ekrana ozel olanlar -
        //   ekran (or. Cek Listesi'nden "Yeni" -> tur=1) katalogu ezebilsin.
        Object.entries(m.varsayilanlar ?? {}).forEach(([ad, deger]) => {
          // "@simdi" DINAMIK varsayilan (151): kart o anki tarih+saatle acilir.
          //   Sunucu ayni isareti kayitta cozer - istemci saati bozuksa bile
          //   kaydedilen deger kurulus saatinden gelir.
          // TARIH alaninda gune kirpilir: input[type=date] dakikali degeri
          //   kabul etmez, alan BOS gorunurdu.
          const tamAn = yerelAnMetni(new Date());
          const an = m.alanlar.find(a => a.ad === ad)?.tip === 'tarih'
            ? tamAn.slice(0, 10) : tamAn;
          baslangic[ad] = deger === '@simdi' ? an : deger as Deger;
        });
        if (yeniKayitVarsayilanlari) {
          Object.entries(yeniKayitVarsayilanlari).forEach(([ad, deger]) => { baslangic[ad] = deger });
        }
        setDeger(baslangic);
        setIlkDeger(baslangic);
        sonKurAnahtari.current = null;   // yeni kartta kur cekilsin
        // Katalog istiyorsa (cek/senet) kart acilir acilmaz CARI secimi gelsin -
        //   yeni kayitta ilk is odur; kullanici kapatip alandan da secebilir.
        // Cari ZATEN geldiyse (belge kartindan acilan cek/senet: siparisin
        //   carisi onyuklu) secim ekrani ACILMAZ - kullaniciya bildigi seyi
        //   ikinci kez sormak akisi kesiyordu.
        if (m.acilistaTarafSecimi
            && !(baslangic[m.acilistaTarafSecimi] as Deger | undefined))
          setTarafSecimAcik(true);
        setSurum(undefined);
        setDetaylar(bosDetaylar);
      } else {
        const k = await api.kartOku(kaynak, id as number);
        const gelen: Record<string, Deger> = {};
        m.alanlar.forEach(a => {
          const d = k.kart[a.ad];
          gelen[a.ad] = a.tip === 'mantik' ? Number(d) === 1 : (d === null || d === undefined ? '' : String(d));
        });
        if (kaynak === 'dis-hekim') setUnvanHam(String(k.kart.unvan ?? '').trim());
        // SECILI kodun adi listede yoksa EKLE: kod tablolari yalniz AKTIF
        //   satirlari gonderir; kayitta pasiflesmis bir deger (or. pasif
        //   personel temsilci olarak duruyorsa) comboda bos gorunur ve kayit
        //   dogru degeri tasidigi halde "bos" izlenimi verirdi. Sunucu bu tek
        //   degerin adini zaten kodAd ile gonderiyor.
        if (k.kodAd) {
          const eksikli = m.alanlar.map(a => {
            const ek = k.kodAd?.[a.ad];
            if (!ek) return a;
            const yeni = { ...(a.kodlar ?? {}) };
            let degisti = false;
            Object.entries(ek).forEach(([anahtar, ad]) => {
              if (!(anahtar in yeni)) { yeni[anahtar] = ad; degisti = true }
            });
            return degisti ? { ...a, kodlar: yeni } : a;
          });
          m = { ...m, alanlar: eksikli };
          setMeta(m);
        }
        setDeger(gelen);
        setIlkDeger(gelen);
        // KAYITLI kur tarihseldir - acilista bugunun kuruyla EZILMEMELI. Yuklenen
        //   cins/tarih "zaten cekilmis" sayilir; kullanici birini degistirirse
        //   anahtar degisir ve kur o zaman yenilenir.
        sonKurAnahtari.current = m.doviz
          ? `${String(gelen[m.doviz.cinsAlani] ?? '')}|` +
            `${m.doviz.tarihAlani ? String(gelen[m.doviz.tarihAlani] ?? '').slice(0, 10) : ''}`
          : null;
        setSurum(k.kart.surum as string | undefined);
        setYetki(k.yetki);
        m.detaylar.forEach(d => {
          bosDetaylar[d.ad] = bosDetay(k.detaylar?.[d.ad] ?? []);
        });
        setDetaylar(bosDetaylar);
        // Sayfali detaylar ilk sayfadan baslar; toplam sunucudan gelir (525).
        setDetaySayfa({});
        setDetayToplam(k.detayToplam ?? {});
      }
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setYukleniyor(false);
    }
  }, [kaynak, id, yeniMi, yeniKayitVarsayilanlari, zorunluAlanlar, tazeleAnahtari]);

  useEffect(() => { void yukle() }, [yukle]);

  // ------------------------------------------------------------ doviz ------
  // Kartta para birimi/kur/tutar ucgeni varsa (katalog: DovizKurali), yerel para
  //   disinda bir birim SECILDIGINDE kur o tarihin kurundan cekilir ve yerel
  //   karsilik gosterilir. Kayitli bir kartin kuru ACILISTA EZILMEZ - kur, belge
  //   gunune ait tarihsel bir degerdir; onu bugunun kuruyla degistirmek gecmis
  //   kaydin anlamini bozardi (asagidaki sonKurAnahtari nobeti).
  const doviz = meta?.doviz ?? null;
  const dovizCinsi = doviz ? String(deger[doviz.cinsAlani] ?? '') : '';
  const dovizTarihi = doviz?.tarihAlani ? String(deger[doviz.tarihAlani] ?? '').slice(0, 10) : '';
  const yerelParada = !doviz || dovizCinsi === '' || dovizCinsi === doviz.yerelPara;

  useEffect(() => {
    if (!doviz || !dovizCinsi) return;
    const anahtar = `${dovizCinsi}|${dovizTarihi}`;
    if (sonKurAnahtari.current === anahtar) return;   // acilis ya da tekrar render
    sonKurAnahtari.current = anahtar;

    if (dovizCinsi === doviz.yerelPara) {
      setDeger(d => ({ ...d, [doviz.kurAlani]: '1' }));
      setKurNotu(null);
      return;
    }
    let iptal = false;
    const tarih = dovizTarihi || bugunIso();
    setKurNotu('Kur alınıyor…');
    api.dovizKur(dovizCinsi, tarih)
      .then(y => {
        if (iptal) return;
        if (y.kur && y.kur > 0) {
          setDeger(d => ({ ...d, [doviz.kurAlani]: String(y.kur) }));
          // Kurun GERCEK gunu yazilir: istenen tarihe kur yoksa onceki en yakin
          //   gun kullanilir, "bugunun kuru" demek yanlis olurdu.
          const gun = (y.kurTarihi ?? tarih).slice(0, 10).split('-').reverse().join('.');
          setKurNotu(`${gun} kuru — gerekirse değiştirin`);
        } else {
          setKurNotu('Bu tarihe kur girilmemiş, elle yazın.');
        }
      })
      .catch(() => { if (!iptal) setKurNotu('Kur alınamadı, elle yazın.') });
    return () => { iptal = true };
  }, [doviz, dovizCinsi, dovizTarihi]);

  /** Yerel karsilik ONIZLEMESI - kaydederken sunucu yeniden hesaplar. */
  const yerelTutar = useMemo(() => {
    if (!doviz) return 0;
    const tutar = hamSayi(deger[doviz.tutarAlani] ?? '0');
    const kur = hamSayi(deger[doviz.kurAlani] ?? '1') || 1;
    return tutar * kur;
  }, [doviz, deger]);

  /**
   * Alan degisimi. BAGLI alanlari (or. Şube -> Banka) TEMIZLER: banka degisince
   * eski bankanin subesi secili kalirsa "Ziraat + Akbank subesi" gibi tutarsiz
   * kayit olusur.
   */
  const alanDegistir = useCallback((ad: string, v: Deger) => {
    setDeger(d => {
      const yeni = { ...d, [ad]: v };
      meta?.alanlar.forEach(x => { if (x.bagliAlan === ad) yeni[x.ad] = '' });
      // TETKİK ÇALIŞMA DÜZENİ "SERİ" DEĞİLSE gün/saat TEMİZLENİR: kayıtta
      //   duran ama hesapta yok sayılan değer, veriyi yalancı yapar - liste
      //   "Sürekli" derken kartta üç gün seçili görünüyordu (gerçek vaka:
      //   "CRP'yi değiştirdim ama listeye yansımadı").
      if (kaynak === 'lab-tetkik' && ad === 'calismaDuzeni' && Number(v) !== 2) {
        yeni.calismaGunleri = 0;
        yeni.calismaSaatleri = '';
      }
      return yeni;
    });
  }, [meta, kaynak]);

  /**
   * Arama modalindan donen secimi YERINE yazar: alan kartin kendi alaniysa
   * alanDegistir, 1:1 uzanti (TekKayit) alaniysa onun gonderdigi uygula.
   * Gosterim adi her iki durumda da ortak sozlukte tutulur - kutu id degil
   * ad gosterir.
   */
  const aramaYaz = useCallback(
    (hedef: { alan: string; uygula?: (deger: string) => void },
     deger: string, ad: string) => {
      if (hedef.uygula) hedef.uygula(deger);
      else alanDegistir(hedef.alan, deger);
      setSecilenAdlar(o => ({ ...o, [hedef.alan]: ad }));
      setAramaAlani(null);
    }, [alanDegistir]);

  const gruplar = useMemo(
    () => alanGruplari(meta, { doviz, yerelParada, gizliAlanlar }),
    [meta, doviz, yerelParada, gizliAlanlar]);


  /**
   * "Kimlik" grubu sekme DEGIL — mockup'taki idstrip gibi ust seritte, her sekmede
   * sabit gorunur (kod/unvan/durum gibi karti tanimlayan alanlar).
   */
  /**
   * HASTA SERIDINDEKI "Doğum Tarihi / Yaş" hucresi (kullanici): uc bilgi tek
   * yerde - "14.03.1979 ♂ E 47 y". Cinsiyet IKON + TEK HARF (hasta seridiyle
   * ayni desen): "Erkek"/"Kadın" hucrede yer kapliyor, ikon tek bakista
   * okunuyor. Kayitsiz alanlar sessizce atlanir - "— / — / —" yazmak bos
   * hucreden daha kotu.
   */
  const dogumYasMetni = useMemo(() => {
    const o = detaylar.ozluk?.guncel[0] ?? {};
    const gun = String((o.dogumTarihi as string | undefined) ?? '').slice(0, 10);
    const parcalar: string[] = [];
    if (gun) parcalar.push(gun.split('-').reverse().join('.'));
    const c = String((o.cinsiyet as string | number | undefined) ?? '');
    if (c === '1') parcalar.push('♂ E'); else if (c === '2') parcalar.push('♀ K');
    if (gun) {
      const d = new Date(gun);
      if (!Number.isNaN(d.getTime())) {
        const b = new Date();
        let y = b.getFullYear() - d.getFullYear();
        const ayFark = b.getMonth() - d.getMonth();
        if (ayFark < 0 || (ayFark === 0 && b.getDate() < d.getDate())) y--;
        if (y >= 0 && y < 130) parcalar.push(`${y} y`);
      }
    }
    return parcalar.join('   ');
  }, [detaylar.ozluk]);

  const kimlikAlanlari = useMemo(
    () => {
      const grup = gruplar.find(([ad]) => ad === KIMLIK_GRUP)?.[1] ?? [];
      // Serit listesi verildiyse SIRA da ondan gelir (unvan, kisa ad, durum).
      return seritAlanlari
        ? seritAlanlari.map(ad => grup.find(a => a.ad === ad)).filter(Boolean) as typeof grup
        : grup;
    },
    [gruplar, seritAlanlari],
  );

  /** Dokuman seridinde TEK HUCREDE toplanan gecerlilik alanlari (mockup). */
const GECERLILIK_ALANLARI = ['gecerliBas', 'gecerliBit'];

/** Mockup'taki gibi sekmeli kart: Kimlik disindaki her alan grubu + her detay tablosu ayri sekme. */
  const sekmeler = useMemo<SekmeTanimi[]>(
    () => sekmeleriKur({ gruplar, meta, kaynak, deger, yeniMi, personelGibiKart,
                         yerTutucuSekmeler, gizliSekmeler, seritAlanlari, detayGrupta,
                         gizliDetaylar,
                         ekSekmeler: ekSekmeler?.map(e => ({ anahtar: e.anahtar,
                                                             baslik: e.baslik })),
                         sekmeSirasi,
                         // Kosullu sekme DETAY alanina da bakabilir (ör. personelde
                         //   "Prim Rolleri" yalniz ozluk.calismaSekli = 3 iken):
                         //   isaret degisince sekme ANINDA gorunur/kaybolur.
                         detaySatirlari: ad => detaylar[ad]?.guncel ?? [] }),
    [gruplar, meta, kaynak, deger, yeniMi, personelGibiKart, yerTutucuSekmeler,
     gizliSekmeler, seritAlanlari, detayGrupta, gizliDetaylar, ekSekmeler,
     sekmeSirasi, detaylar]);

  const [aktifSekme, setAktifSekme] = useState<string | null>(null);
  const kayitAnahtari = `${kaynak}:${id}`;
  const ilkSekmeAnahtari = sekmeler[0]?.anahtar ?? null;
  useEffect(() => {
    if (ilkSekmeAnahtari) setAktifSekme(ilkSekmeAnahtari);
  }, [kayitAnahtari, ilkSekmeAnahtari]);

  /** Hangi alan hangi sekmede — hata gelince o sekmeye atlamak icin. Kimlik her zaman gorunur, atlamaya gerek yok. */
  const sekmeBul = useCallback((alanAdi: string): string | null => {
    if (alanAdi.includes('.')) {
      const detayAd = alanAdi.split('.')[0];
      if (kaynak === 'cari' && detayAd === 'adresler') return grupSekmeAnahtari('Adres / Fatura Bilgisi');
      if (kaynak === 'hasta' && detayAd === 'adresler') return grupSekmeAnahtari('Adres / Fatura Bilgisi');
      if (kaynak === 'kisi' && detayAd === 'adresler') return grupSekmeAnahtari('Genel');
      if (personelGibiKart && detayAd === 'adresler') return grupSekmeAnahtari('İletişim');
      if (personelGibiKart && detayAd === 'egitimler') return grupSekmeAnahtari('Genel');
      return detaySekmeAnahtari(detayAd);
    }
    const alan = meta?.alanlar.find(a => a.ad === alanAdi);
    const grup = alan?.grup ?? 'Genel';
    if (kaynak === 'hasta' && grup === 'İletişim') return grupSekmeAnahtari('Genel');
    return grup === KIMLIK_GRUP ? null : grupSekmeAnahtari(grup);
  }, [meta, kaynak, personelGibiKart]);

  /**
   * Bir detayin SUNUCUYA GONDERILEBILIR alan adlari. Grid, satirda gosterim
   * icin ek anahtar tutabiliyor (kampanya urun satirinda secilen urunun adi);
   * bunlar katalogda alan olmadigindan sunucu "Bilinmeyen alan" der.
   */
  const detayAlanlari = (m: typeof meta, ad: string) =>
    m?.detaylar.find(d => d.ad === ad)?.alanlar.map(a => a.ad);

  // Govde ve "degisti mi" karari saf fonksiyonlarda (kartDegisim.ts).
  const degisenAlanlar = useCallback(
    () => degisenAlanlarHesapla({
      alanlar: meta?.alanlar, deger, ilkDeger, yeniMi,
      varsayilanlar: yeniKayitVarsayilanlari,
    }),
    [meta, deger, ilkDeger, yeniMi, yeniKayitVarsayilanlari]);

  const kaydedilmemisDegisiklikVar = useMemo(() => {
    // GENEL KURAL (kullanici): hicbir sey degistirmeden kapatan kullaniciya
    //   "kaydedilsin mi?" sorulmaz - karsilastirma alan tipine gore normalize
    //   edilir (kartDegisim.alanEsit), yoksa "1.000000" ile '1' fark sayilirdi.
    if (kartDegistiMi(meta?.alanlar, deger, ilkDeger)) return true;

    return Object.entries(detaylar).some(([ad, durum]) => {
      const fark = detayFarki(durum, detayAlanlari(meta, ad));
      return (fark.eklenen?.length ?? 0) + (fark.degisen?.length ?? 0)
           + (fark.silinen?.length ?? 0) > 0;
    });
  }, [meta, deger, ilkDeger, detaylar]);

  const kapatIstendi = useCallback(() => {
    if (kaydedilmemisDegisiklikVar) {
      setKapatmaUyarisi(true);
      return;
    }
    onKapat?.();
  }, [kaydedilmemisDegisiklikVar, onKapat]);

  // Kart acildiginda/kapatildiginda bekleyen ek kayit isleri temizlenir -
  //   baska kartin degisikligi buraya sizmasin.
  useEffect(() => { ekKaydetTemizle(); return () => ekKaydetTemizle() }, [kaynak, id]);

  async function kaydet() {
    // ADAY HASTA (266): dosya no CEP NUMARASI, unvan ad+soyad. Ikisi de kartta
  //   gosterilmez; kullanicidan iki alan daha istemek yerine turetiliyor.
  // Kaydetmeden onceki alan kontrolleri TEK YERDE (kartDogrulama): e-posta,
    //   ekrana ozel zorunluluk ve telefon. Ilk hatada ilgili sekmeye atlanir.
    const alanHatasi = kartDogrula(meta, deger, zorunluAlanlar,
      Object.fromEntries(Object.entries(detaylar).map(([ad, d]) => [ad, d.guncel])));
    if (alanHatasi) {
      setAlanHatalari(h => ({ ...h, [alanHatasi.alan]: alanHatasi.mesaj }));
      const hedefSekme = sekmeBul(alanHatasi.alan);
      if (hedefSekme) setAktifSekme(hedefSekme);
      // HATA HER ZAMAN GORUNSUN (484): alan hatasi yalniz alanin yanina
      //   yaziliyordu; alan bir DETAYA ait olunca (kurum turu ->
      //   "kurumRolu.tur") ne sekme bulunuyor ne de kutu o anahtari taniyor -
      //   kullanici Kaydet'e basiyor, hicbir sey olmuyordu. Ust bant sebebi
      //   her durumda soyler.
      setHata(alanHatasi.mesaj);
      return;
    }

    setKaydediyor(true);
    setHata(null);
    setAlanHatalari({});
    setCakisma(null);
    setBilgi(null);
    try {
      // Telefon TEK BICIMDE saklanir: kullanici gruplu da yazsa gruplamadan da
      //   yazsa DB'ye "+90 532 418 77 20" gider. Aksi halde ayni numara iki
      //   farkli metinle durup arama/mukerrer kontrolu kaciriyordu.
      const kartGovdesi = degisenAlanlar();
      Object.keys(kartGovdesi).forEach(ad => {
        if (telefonAlaniMi(ad) && typeof kartGovdesi[ad] === 'string' && kartGovdesi[ad])
          kartGovdesi[ad] = telefonBicimle(kartGovdesi[ad]);
      });

      const govde = {
        surum,
        kart: kartGovdesi,
        detaylar: Object.fromEntries(
          Object.entries(detaylar)
            .map(([ad, durum]) => [ad, detayFarki(durum, detayAlanlari(meta, ad))])
            .filter(([, fark]) => {
              const f = fark as ReturnType<typeof detayFarki>;
              return (f.eklenen?.length ?? 0) + (f.degisen?.length ?? 0) + (f.silinen?.length ?? 0) > 0;
            })),
      };

      // Personel'de "unvan" hic gosterilmiyor/duzenlenmiyor (kullanici: ad/soyad kullanilsin)
      // - DB'de NOT NULL oldugu icin Kaydet'te ad+soyad'dan burada birlestirilip eklenir.
      if (personelGibiKart || kaynak === 'hasta-aday') {
        const ad = String(deger.ad ?? '').trim();
        const soyad = String(deger.soyad ?? '').trim();
        // Hekim unvani (306) adin ONUNE gelir: "Prof.Dr. Halil GÜNEŞ".
        const unvan = [unvanOnek, ad, soyad].filter(Boolean).join(' ');
        if (unvan) govde.kart.unvan = unvan;
      }
      // ADAY HASTA (266): DOSYA NO = CEP NUMARASI (kullanici). Kullanicidan
      //   ayrica dosya no istemek yerine turetiliyor; elle girilmis kod varsa
      //   ona dokunulmaz.
      if (kaynak === 'hasta-aday' && !String(deger.kod ?? '').trim()) {
        const cep = String(deger.cepTel ?? '').trim();
        if (cep) govde.kart.kod = cep;
      }

      const yanit = yeniMi
        ? await api.kartEkle(kaynak, govde)
        : await api.kartGuncelle(kaynak, id as number, govde);

      // Kartin AYRI uca yazan bolumleri (personel > yetkili subeler) tek
      //   Kaydet'e baglidir: kart yazildiktan sonra kuyruk calisir.
      await ekKaydetleriCalistir();

      onKaydedildi?.(Number(yanit.kart.id));
      onKapat?.();
      return;
    } catch (h) {
      const c = hataAyristir(h);
      if (c.cakisma) {
        setCakisma(c.cakisma);
      } else {
        setAlanHatalari(c.alanlar);
        setHata(c.mesaj);
        // Hatali alan baska sekmedeyse oraya atla - kullanici bos ekranda
        //   "nerede hata var" diye aramasin.
        const hedefSekme = c.ilkAlan ? sekmeBul(c.ilkAlan) : null;
        if (hedefSekme) setAktifSekme(hedefSekme);
      }
    } finally {
      setKaydediyor(false);
    }
  }

  async function sil() {
    setHata(null);
    try {
      await api.kartSil(kaynak, id as number);
      onKapat?.();
    } catch (h) {
      if (h instanceof ApiHatasi) {
        setHata(h.hata.engel
          ? `${h.message} (${h.hata.engel.ad || h.hata.engel.tablo}: `
            + `${h.hata.engel.adet} kayıt)`
          : `${h.hata.kod}: ${h.message}`);
      }
    }
  }

  /**
   * FIYAT LISTESI SATIR MODALI EKRAN KURALI (kullanici):
   *  - Carpan degisince fiyat = taban fiyat x carpan (yuvarlama satirdan,
   *    bossa basligin kuralindan) ve Yazim MANUEL olur - uretim artik ezmez.
   *  - Yazim HESAP'a cevrilince fiyat basligin kuralindan yeniden hesaplanir,
   *    carpan basligin carpanina doner.
   * Ayni kural DB tetiginde son otorite olarak da durur; buradaki kopya
   * kullanicinin sonucu KAYDETMEDEN gormesi ve fiyat/yazim'in istekle
   * birlikte gidip ISLEM LOGUNA yazilmasi icindir.
   */
  function fiyatSatirKurali(alan: string, v: unknown, taslak: Record<string, unknown>) {
    const yuvarla = (tutar: number, yonHam: unknown, adimHam: unknown) => {
      const yon = Number(yonHam ?? 0);
      const adim = hamSayi(adimHam) || 1;
      if (!yon || adim <= 0) return tutar;
      if (yon === 1) return Math.ceil(tutar / adim) * adim;
      if (yon === 2) return Math.floor(tutar / adim) * adim;
      if (yon === 3) return Math.round(tutar / adim) * adim;
      return tutar;
    };
    // Fiyat 4, carpan 6 hane (kolon numeric(18,6) - 7,0092 gibi degerler).
    const metin = (s: number, hane = 4) => {
      const k = 10 ** hane;
      return String(Math.round(s * k) / k);
    };
    const taban = hamSayi(taslak.tabanFiyat);

    if (alan === 'carpan') {
      const carpan = hamSayi(v);
      if (carpan <= 0 || taban <= 0) return { yazim: '1' };
      const bos = (d: unknown) => d === '' || d === null || d === undefined;
      const yon  = bos(taslak.yuvarlama)      ? deger.yuvarlama      : taslak.yuvarlama;
      const adim = bos(taslak.yuvarlamaBirim) ? deger.yuvarlamaBirim : taslak.yuvarlamaBirim;
      return { fiyat: metin(yuvarla(taban * carpan, yon, adim)), yazim: '1' };
    }
    // FIYAT elle degisti: satir Manuel olur; zincirli satirda carpan fiyattan
    //   GERIYE hesaplanir (taban degismez). Koksuz/manuel listede carpan
    //   anlamsiz - dokunulmaz.
    if (alan === 'fiyat') {
      const f = hamSayi(v);
      if (taslak.tabanListeId && taban > 0 && f > 0)
        return { yazim: '1', carpan: metin(f / taban, 6) };
      return { yazim: '1' };
    }
    if (alan === 'yazim' && String(v) === '2' && taban > 0) {
      const carpan = hamSayi(deger.carpan) || 1;
      return {
        fiyat: metin(yuvarla(taban * carpan, deger.yuvarlama, deger.yuvarlamaBirim)),
        carpan: metin(carpan, 6),
      };
    }
    return null;
  }

  if (yukleniyor)
    return (
      <Modal baslik={baslik ?? kaynak} dar={TEK_SUTUN_KARTLAR.has(kaynak)}
        ekSinif={kaynak === 'randevu' ? 'kart-orta' : undefined} alt={<button className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>} onKapat={onKapat}>
        <div className="yukleniyor-satir">Yukleniyor…</div>
      </Modal>
    );

  if (!meta)
    return (
      <Modal baslik={baslik ?? kaynak} dar={TEK_SUTUN_KARTLAR.has(kaynak)}
        ekSinif={kaynak === 'randevu' ? 'kart-orta' : undefined} alt={<button className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>} onKapat={onKapat}>
        <div className="hata-kutusu">{hata}</div>
      </Modal>
    );

  const salt = !yeniMi && !yetki.duzenle;
  const aktif = sekmeler.find(s => s.anahtar === aktifSekme) ?? sekmeler[0];

  // Alan cizimi ayri dosyada (kartAlanCizim): govde uzunlugu okunabilirligi
  //   bozuyordu. Cagri bicimi degismedi - renderAlan/renderAlanListesi.
  const { altGruplaVar, renderAlanListesi } = alanCizici({
    kaynak, salt, meta, deger, setDeger, alanDegistir, alanHatalari, setAlanHatalari,
    doviz, yerelTutar, kurNotu, bagliTarafAdi, setBagliTarafAdi,
    secilenAdlar,
    aramaAc: (alanAdi, kaynakAdi, uygula) =>
      setAramaAlani({ alan: alanAdi, kaynak: kaynakAdi, uygula }),
  });

  return (
    <Modal
      baslik={`${baslik ?? kaynak} ${yeniMi ? '— Yeni' : `#${id}`}`}
      dar={TEK_SUTUN_KARTLAR.has(kaynak)}
        ekSinif={kaynak === 'randevu' ? 'kart-orta' : undefined}
      ustBilgi={
        <>
          {/* Personel durumu BASLIKTA rozet (kullanici): aktif yesil, isten
              cikis tarihi girilmisse pasif kirmizi - cikis tarihi olan biri
              "aktif" gorunmesin. Serit alani olarak ayrica cizilmez. */}
          {/* DIS HEKIMDE baslik rozeti YOK (kullanici): durum seritte combo -
              ayni bilgiyi iki yerde gostermek gereksiz. */}
          {/* HASTADA BASLIK ROZETI YOK (kullanici): durum artik SERITTE combo
              (dort degerli: Aktif/Pasif/Aday/Vefat) - ayni bilgiyi iki yerde
              gostermek gereksiz. Yerine DOSYA NO yaziyor: kartin kimligi
              "Hasta #123" degil hastanenin verdigi dosya numarasidir. */}
          {kaynak === 'hasta' && !yeniMi && (
            <span style={{ margin: '0 auto', fontWeight: 400, fontSize: 12 }}>
              Dosya No : <b>{String(deger.kod ?? '') || '—'}</b>
            </span>
          )}
          {personelGibiKart && kaynak !== 'hasta' && kaynak !== 'dis-hekim' && !yeniMi && (() => {
            const ozluk = detaylar.ozluk?.guncel[0];
            const cikis = String((ozluk?.istenCikisTarihi as string | undefined) ?? '');
            const pasif = cikis.length > 0 || Number(deger.durum) === 0;
            // Kidem rozetin SAGINDA duz yazi (kullanici; "Özet" kutusu kalkti).
            const kidem = kidemMetni(
              String((ozluk?.iseGirisTarihi as string | undefined) ?? ''), cikis || null);
            return (
              <span style={{ margin: '0 auto', display: 'flex', gap: 8,
                             alignItems: 'center' }}>
                <span className={`rozet ${pasif ? 'hata' : 'ok'}`}
                      title={cikis ? `İşten çıkış: ${cikis}` : undefined}>
                  {pasif ? 'Pasif' : 'Aktif'}
                </span>
                {/* Görev de basliktan gorunsun (kullanici): kod -> ad. */}
                {(() => {
                  const kod = String(deger.gorevId ?? '');
                  const ad = kod
                    ? meta?.alanlar.find(a => a.ad === 'gorevId')?.kodlar?.[kod]
                    : null;
                  return ad ? <span className="rozet gri">{ad}</span> : null;
                })()}
                {kidem && (
                  <span style={{ fontWeight: 400, fontSize: 11.5, opacity: .9 }}>
                    Kıdem {kidem}
                  </span>
                )}
              </span>
            );
          })()}
          {/* DOKUMAN DURUM ROZETI UST BASLIKTA (kullanici): "Yayında v1"
              kartin kimligidir - hangi sekmede olursan ol gorunmeli. Arac
              cubugunda dururken Kaydet/Kapat dugmelerinin arasinda kayboluyordu.
              HASH GOSTERILMEZ (kullanici): 64 haneli ozet kullaniciya bir sey
              anlatmiyor; icerik kimligi gerektiginde Icerik sekmesinde. */}
          {kaynak === 'dokuman' && !yeniMi && (
            <span style={{ margin: '0 auto', display: 'flex', gap: 6,
                           alignItems: 'center' }}>
              <span className={`rozet ${Number(deger.durum) === 3 ? 'ok'
                                : Number(deger.durum) === 2 ? 'mavi'
                                : Number(deger.durum) === 4 ? 'gri' : 'uyari'}`}>
                {meta?.alanlar.find(a => a.ad === 'durum')?.kodlar?.[String(deger.durum ?? '')]
                 ?? 'Taslak'} v{String(deger.surumNo ?? 1)}
              </span>
              {Number(deger.onaydakiSurum) > 0 && (
                <span className="rozet mavi">v{String(deger.onaydakiSurum)} onayda</span>
              )}
            </span>
          )}
          {surum && <span className="rozet gri">surum {surum}</span>}
          {baslikEk?.(deger)}
          {salt && <span className="rozet uyari">salt okunur</span>}
        </>
      }
      ustSerit={(
        <>
        {/* EKRAN-OZEL BAGLAM (461): kimlik seridinin USTUNDE. Muayenede
            alerji/kronik/aktif ilac hekimin yazarken gormesi gereken bilgi -
            ayri sekmede durursa bakilmaz. */}
        {ustBaglam?.(deger)}
        {kimlikAlanlari.length > 0 && (() => {
        const kimlikSeridi = (
        <div className="kaid">
          {/* AVATAR (305, kullanici: "ad soyadin soluna avatar ekle"): ad ve
              soyadin bas harfleri. Kisi kartlarinda kimin karti oldugunu tek
              bakista gosterir - hasta seridindeki desenle ayni. */}
          {kaynak === 'dis-hekim' && (() => {
            const bas = [String(deger.ad ?? ''), String(deger.soyad ?? '')]
              .map(x => x.trim()[0] ?? '').join('').toLocaleUpperCase('tr');
            return <span className="kart-avatar">{bas || '—'}</span>;
          })()}
          {/* Kisi'ye ozel: Kisi Kodu dar, Unvan genis (kullanici: "kod edit yariya dussun,
              onu unvana ekle") - idstrip'in 4 sabit alani (Kod/Unvan/Departman/Gorev). */}
          {/* Personelde ROL kimlik seridinde, DEPARTMANIN SAGINDA (kullanici);
              serit 5 sutunlu akar. Diger kartlarda serit eskisi gibi. */}
          {/* YENI kayitta da gecerli: Görev ZORUNLU ama serit yalniz mevcut
              kartta cizilince alan hic gorunmuyordu ("Görev zorunlu" hatasi
              alinip duzeltilemiyordu). */}
          {/* ADAY HASTA (266): kimlik seridinde Durum yerine KURUM - durum arac
              cubugunda rozet. Kurum taraf_hasta detayinda oldugu icin serit
              alanlarindan degil, detay durumundan besleniyor. */}
          {kaynak === 'hasta-aday' ? (() => {
            const ozluk = meta?.detaylar.find(d => d.ad === 'ozluk');
            const kurumAlan = ozluk?.alanlar.find(a => a.ad === 'kurumId');
            const satir = detaylar[ozluk?.ad ?? '']?.guncel[0] ?? {};
            return (
              <div className="alan-izgara"
                   style={{ gridTemplateColumns: 'repeat(4, minmax(0, 1fr))' }}>
                {renderAlanListesi(kimlikAlanlari)}
                {kurumAlan && ozluk && (
                  <label className="alan tip-kod">
                    <span className="etiket">{kurumAlan.baslik}</span>
                    <select value={String(satir.kurumId ?? '')} disabled={salt}
                            onChange={e => setDetaylar(t => {
                              const d = t[ozluk.ad] ?? { ilk: [], guncel: [] };
                              const yeni = { ...(d.guncel[0] ?? {}), kurumId: e.target.value };
                              return { ...t, [ozluk.ad]: { ...d, guncel: [yeni, ...d.guncel.slice(1)] } };
                            })}>
                      <option value="">—</option>
                      {kurumAlan.kodlar && Object.entries(kurumAlan.kodlar)
                        .map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                    </select>
                  </label>
                )}
              </div>
            );
          })() : kaynak === 'dis-hekim' ? (
            /* DIS HEKIM (305/306) serit duzeni: avatar · Ünvan · Ad · Soyad ·
               Kod · Temsilci · Durum. Departman/gorev YOK - dis hekim bizim
               kadromuzda degil; Temsilci ise BIZIM personelimiz (bu hekimle
               ilgilenen kisi). */
            /* Ünvan ve Kod YARIM sutun (kullanici): kisa degerler - "Prof.Dr."
               ve "DR-0042" tam sutunda bos yer birakiyordu. Ad/Soyad ve
               Temsilci tam sutun kalir. */
            <div className="alan-izgara"
                 style={{ gridTemplateColumns: '0.5fr 1fr 1fr 0.5fr 1fr 0.5fr' }}>
              <label className="alan tip-kod">
                <span className="etiket">Ünvan</span>
                <select value={unvanOnek} disabled={salt}
                        onChange={e => setUnvanOnek(e.target.value)}>
                  <option value="">—</option>
                  {unvanSecenek.map(o => <option key={o} value={o}>{o}</option>)}
                </select>
              </label>
              {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'ad'))}
              {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'soyad'))}
              {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'kod'))}
              {renderAlanListesi((meta?.alanlar ?? []).filter(a => a.ad === 'temsilci'))}
              {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'durum'))}
            </div>
          ) : personelGibiKart ? (
            <div className="alan-izgara"
                 style={{ gridTemplateColumns: 'repeat(5, minmax(0, 1fr))' }}>
              {/* HASTADA "Dosya No" EDITI HIC YOK (kullanici): numara
                  OTOMATIK verilir - yeni kayitta da sorulmaz. Kayitli kartta
                  numara basliktan okunur; duzenlenecek bir alan degil,
                  seritte yer kapliyordu. */}
              {renderAlanListesi(kimlikAlanlari.filter(a =>
                ['kod', 'ad', 'soyad', 'departman'].includes(a.ad)
                && !(kaynak === 'hasta' && a.ad === 'kod')))}
              {/* GOREV seritte YALNIZ PERSONELDE (kullanici: "hasta kartında en
                  üstte görev kaldır"): hastanin gorevi yoktur - alan katalogda
                  zaten GIZLI, buraya ACIKCA cizildigi icin o gizlemeyi
                  atliyordu. Personelde serit'in 5. alani odur (rol ile yer
                  degistirdi; Rol combosu Kimlik Bilgileri kutusunda). */}
              {kaynak !== 'hasta' && renderAlanListesi(
                (meta?.alanlar ?? []).filter(a => a.ad === 'gorevId'))}
              {/* DURUM: personelde seritte YOK (baslikta rozet), HASTADA VAR ve
                  TC No'nun SAGINDA (kullanici) - hasta durumu dort degerli
                  (Aktif/Pasif/Aday/Vefat), rozet tek basina yetmiyor. */}
              {/* DURUM burada DEGIL, seridin EN SAGINDA (kullanici) - once
                  kimlik alanlari okunur, durum kartin ozeti olarak sona kalir. */}
              {renderAlanListesi(kimlikAlanlari.filter(a =>
                !['kod', 'ad', 'soyad', 'departman', 'durum'].includes(a.ad)))}
              {/* DOGUM TARIHI / YAS - TC No'nun saginda, SALT OKUNUR
                  (kullanici): uc bilgi tek hucrede "14.03.1979 ♂ E 47 y".
                  Kaynak ozluk detayi; duzenlemesi Kimlik Bilgileri kutusunda -
                  ayni alani iki yerde yazdirmak ikisini ayirmaya calismak
                  demekti. */}
              {kaynak === 'hasta' && (
                <label className="alan tip-metin">
                  <span className="etiket">Doğum Tarihi / Yaş</span>
                  <input readOnly tabIndex={-1} value={dogumYasMetni}
                         title="Doğum bilgileri Kimlik Bilgileri kutusundan girilir" />
                </label>
              )}
              {/* DURUM yalniz HASTADA seritte (dort degerli: Aktif/Pasif/Aday/
                  Vefat); personelde baslikta rozet. */}
              {kaynak === 'hasta'
                && renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'durum'))}
            </div>
          ) : kaynak === 'dokuman' ? (
            /* DOKUMAN SERIDI (mockup dokuman_karti.html): DORT SUTUN sabit -
               otomatik akista alanlar ekran genisligine gore 2-6 sutun
               arasinda ziplayip mockup duzenini bozuyordu.
               GECERLILIK TEK HUCREDE: mockupta "28.08.2026 — 01.09.2027 ·
               gozden gecirme 12 ay" tek satir; uc ayri kutu ucte bir satir
               kaplayip ilgisiz alanlari birbirinden ayiriyordu. */
            <div className="alan-izgara kaid-dokuman">
              {/* GECERLILIK HUCRESI KENDI YERINDE kalir (mockup 3. satirin
                  BASI): alanlari filtreleyip hucreyi sona eklemek, Gecerlilik'i
                  Aciklama'nin arkasina atiyordu. Once ondan ONCEKI alanlar,
                  sonra hucre, sonra kalanlar cizilir. */}
              {renderAlanListesi(kimlikAlanlari.slice(
                0, kimlikAlanlari.findIndex(a => GECERLILIK_ALANLARI.includes(a.ad))))}
              <label className="alan tip-metin gecerlilik-hucre">
                <span className="etiket">Geçerlilik</span>
                <span className="gecerlilik-kutu">
                  {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'gecerliBas'))}
                  <span className="ayrac">—</span>
                  {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'gecerliBit'))}
                </span>
              </label>
              {renderAlanListesi(kimlikAlanlari.slice(
                kimlikAlanlari.findIndex(a => GECERLILIK_ALANLARI.includes(a.ad)))
                .filter(a => !GECERLILIK_ALANLARI.includes(a.ad)))}
            </div>
          ) : kaynak === 'kurum' ? (() => {
            /* KURUM SERIDI (484, kullanici: "temsilci ile kurum turunu yer
               degistir"): Kod · Kurum Adi · KURUM TURU · Durum. Kurum turu
               kurumun en temel bilgisidir - hangi anlasma kurallarinin
               isleyecegini o belirler (Ozel / OSS / SGK); temsilci ise satis
               takibi alani, Tanımlama kutusuna indi.
               Deger `taraf_kurum.tur`da (1:1 uzanti), kartin kendi tablosunda
               degil - o yuzden renderAlanListesi ile cizilemez; TekKayit
               cercevesiz kipte seridin bir hucresi olur. */
            const rol = meta?.detaylar.find(d => d.ad === 'kurumRolu');
            return (
              <div className="alan-izgara">
                {renderAlanListesi(kimlikAlanlari.filter(a => a.ad !== 'durum'))}
                {rol && (
                  <TekKayit
                    meta={rol}
                    durum={detaylar[rol.ad] ?? bosDetay()}
                    saltOkunur={salt || rol.saltOkunur}
                    onDegis={y => setDetaylar(t => ({ ...t, [rol.ad]: y }))}
                    cerceveSiz
                  />
                )}
                {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'durum'))}
              </div>
            );
          })() : (
            <div className={`alan-izgara${kaynak === 'kisi' ? ' kaid-kisi' : ''}`
                            + (kaynak === 'randevu' ? ' kaid-randevu' : '')
                            + (kaynak === 'prim-plani' ? ' kaid-prim' : '')
                            + (kaynak === 'kampanya' ? ' kaid-kampanya' : '')
                            // FIYAT LISTESI SERIDI BES SUTUN (532, kullanici:
                            //   "1. sira: ad, tarife, yon, kdv, durum" ·
                            //   "2. sira: baslama, bitis, aciklama,
                            //   varsayilan"). Otomatik akista kutular ekran
                            //   genisligine gore ziplayip bu ayrimi bozuyordu.
                            + (kaynak === 'fiyat-listesi' ? ' kaid-fiyat' : '')}>
              {renderAlanListesi(kimlikAlanlari)}
            </div>
          )}
        </div>
        );
        return seritSarmalayici ? seritSarmalayici(kimlikSeridi, deger) : kimlikSeridi;
        })()}
        {/* RADYOLOJI ISTEMI (310): akis seridi + ozet KIMLIK SERIDININ ALTINDA,
            sekmelerin USTUNDE - hangi sekmede olursan ol "istem nerede"
            gorunmeli (mockup radyoloji_istem_karti.html). Yeni kayitta yok. */}
        {kaynak === 'radyoloji-istem' && !yeniMi && <IstemAkisi istemId={id as number} />}
        </>
      )}
      sekmeBar={sekmeler.length > 1 && (
        <div className="katab">
          {sekmeler.map(s => (
            <div
              key={s.anahtar}
              className={`kat${s.anahtar === aktif?.anahtar ? ' on' : ''}`}
              onClick={() => setAktifSekme(s.anahtar)}
            >
              {/* IKON YOK (kullanici): on sekmeli kartta ikonlar seridi
                  ikinci satira tasiriyordu; sekme adi zaten ayirt ediyor. */}
              {c(s.baslik)}
              {/* SAYFALI DETAYDA ROZET TOPLAMI GOSTERIR (525): ekranda 200
                  satir duruyor olsa da sekmenin sordugu "kac tane var". */}
              {s.tur === 'detay' && <span className="b">{
                (detayToplam[s.detay.ad]
                  ?? (detaylar[s.detay.ad] ?? bosDetay()).guncel.length).toLocaleString('tr')
              }</span>}
            </div>
          ))}
        </div>
      )}
      onKapat={kapatIstendi}
      alt={
        <>
          {/* DURUM OZETI (461): mockup'ta kartin altinda bir serit - "neyim
              eksik" sorusu Tamamla'ya basmadan once cevaplanmali. */}
          {altBilgi && <span className="kart-alt-bilgi">{altBilgi(deger)}</span>}
          {!salt && (
            <button className="d bir" disabled={kaydediyor} onClick={() => void kaydet()}>
              {kaydediyor ? 'Kaydediliyor…' : 'Kaydet'}
            </button>
          )}
          {!yeniMi && yetki.sil && (
            <button className="d teh" onClick={() => void sil()}>Sil</button>
          )}
          {/* TOPLU CARPAN (534, kullanici: "sil butonu sagina Çarpan Gir
              butonu ekle, sadece TTB/HUV'da gorunsun" · "carpan butonu
              ustteki silin sagina al"): donem carpani binlerce satirda ayni -
              tek tek yazmak is degil. Secim gridde, dugme burada. */}
          {!yeniMi && kaynak === 'fiyat-listesi' && Number(deger.tarifeTipi) === 2 && (
            <button type="button" className="d"
                    disabled={seciliSatirlar.size === 0}
                    title={seciliSatirlar.size === 0
                           ? 'Önce satırlardan seçim yapın'
                           : `Seçili ${seciliSatirlar.size} satıra çarpan yaz`}
                    onClick={() => { setTopluCarpanDeger(''); setTopluCarpan(true) }}>
              ✖ Çarpan Gir{seciliSatirlar.size > 0 ? ` (${seciliSatirlar.size})` : ''}
            </button>
          )}
          {/* DURUM DEGISTIR (534, kullanici: "ustteki sil sagina 'Durum
              Değiştir' butonu gir, altina menu gelsin Aktif ve Pasif,
              secince isaretli satirlari aktif/pasif yapsin"). Fiyat listesi
              buyuk (14 bin satir): kalemi tek tek acip durum kutusunu
              cevirmek is degil - kategori kapatmadan da bir grup satir
              gecici olarak kapatilabilmeli. */}
          {!yeniMi && kaynak === 'fiyat-listesi' && (
            <span className="durum-sec">
              <button type="button" className="d"
                      disabled={seciliSatirlar.size === 0}
                      title={seciliSatirlar.size === 0
                             ? 'Önce satırlardan seçim yapın'
                             : `Seçili ${seciliSatirlar.size} satırın durumu`}
                      onClick={() => setDurumMenusu(a => !a)}>
                ◐ Durum Değiştir{seciliSatirlar.size > 0 ? ` (${seciliSatirlar.size})` : ''} ▾
              </button>
              {durumMenusu && (
                <span className="durum-menu">
                  <button type="button" className="durum-oge"
                          onClick={() => topluDurum(1)}>✓ Aktif</button>
                  <button type="button" className="durum-oge"
                          onClick={() => topluDurum(0)}>⊘ Pasif</button>
                </span>
              )}
            </span>
          )}
          {/* EKRAN-OZEL EYLEMLER (461): mockup'ta bunlar kartin arac
              cubugunda - hekim listeye donup satir secmeden isini bitirmeli. */}
          {!yeniMi && ekAraclar?.(deger)}
          {/* HASTA KARTI EYLEM DUGMELERI (kullanici) - Sil'in saginda.
              MERNIS ve provizyon/mustehaklik sorgusu DIS SERVISE gider; o
              servisler henuz bagli DEGIL, dugmeler yerlesimde duruyor ve
              basilinca bunu acikca soyluyor - sessizce hicbir sey yapmayan
              bir dugme, bozuk bir dugmeden daha kotu. */}
          {kaynak === 'hasta' && !yeniMi && (
            <>
              <button className="d" type="button"
                      title="Kimlik bilgilerini MERNİS'ten günceller"
                      onClick={() => setHata('MERNİS servisi henüz bağlı değil.')}>
                MERNİS'ten getir
              </button>
              <button className="d" type="button"
                      title="SGK provizyon / müstehaklık sorgusu"
                      onClick={() => setHata('Provizyon/müstehaklık servisi henüz bağlı değil.')}>
                Provizyon/Müstehaklık Sorgula
              </button>
              <button className="d yesil" type="button" onClick={() => setAcilanBasvuru(0)}>
                ＋ Yeni Başvuru
              </button>
            </>
          )}
          {/* Kisi'ye ozel: "Bagli Cari" alani artik salt-okunur gorunum (asagida renderGirdi),
              tek degistirme yolu bu buton + TarafArama modali. Kisi zaten bagliysa (bagId
              dolu) buton GORUNMEZ (kullanici) - once "x" ile bag bosaltilmali. */}
          {kaynak === 'kisi' && !salt && !cariyeBaglaGizli && !deger.bagId && (
            <button className="d" onClick={() => setCariyeBaglaAcik(true)}>🔗 Cariye Bağla</button>
          )}
          {/* Cek/senede ozel: YON (alinan / verilen) arac cubugunda, Kaydet'in
              saginda (kullanici). Tek secimlik ve kagidin tum anlamini
              belirleyen alan - kimlik seridinde yer kaplamasin diye buraya
              alindi; karttaki alan Gizli, deger buradan yazilir. */}
          {kaynak === 'cek-senet' && meta.alanlar.some(a => a.ad === 'yon') && (
            <label className="satir-ici" style={{ fontSize: 13, gap: 8 }}
                   title="Alınan: müşteriden geldi · Verilen: tedarikçiye verildi">
              Yön
              {/* Arac cubugundaki tek secim - kutu ve yazi biraz daha buyuk
                  (kullanici): kagidin yonunu belirleyen alan goze carpsin. */}
              <select value={String(deger.yon ?? 1)} disabled={salt}
                      style={{ width: 150, height: 28, fontSize: 13 }}
                      onChange={e => setDeger(d => ({ ...d, yon: Number(e.target.value) }))}>
                <option value={1}>Alınan</option>
                <option value={2}>Verilen</option>
              </select>
            </label>
          )}
          {/* ADAY HASTA (266): durum arac cubugunda ROZET - Kaydet ile Kapat
              arasinda (kullanici). Aday yesil degil MAVI: henuz gercek hasta
              degil, basvuruya donusunce Aktif olur. */}
          {kaynak === 'hasta-aday' && (
            <span className={`rozet ${Number(deger.durum) === 1 ? 'ok'
                              : Number(deger.durum) === 2 ? 'mavi'
                              : Number(deger.durum) === 3 ? 'hata' : 'gri'}`}
                  style={{ alignSelf: 'center' }}>
              {meta.alanlar.find(a => a.ad === 'durum')?.kodlar?.[String(deger.durum ?? '')]
               ?? 'Aday'}
            </span>
          )}
          {/* RANDEVU akis dugmeleri (mockup): durum comboyla degil bu
              dugmelerle degisir. Kaydet'e basilinca yazilir - kart
              standardindan sapmamak icin ayri bir istek yapilmaz. */}
          {kaynak === 'randevu' && !salt && (
            <>
              <button className="d" disabled={Number(deger.durum) === 2}
                      onClick={() => alanDegistir('durum', '2')}>✔ Geldi İşaretle</button>
              <button className="d" disabled={Number(deger.durum) === 3}
                      onClick={() => alanDegistir('durum', '3')}>✖ Gelmedi</button>
              <button className="d" disabled={Number(deger.durum) === 4}
                      onClick={() => alanDegistir('durum', '4')}>⊘ İptal</button>
            </>
          )}
          {/* DOKUMAN KART ARAC CUBUGU (419, mockup dokuman_karti.html).
              Surum/onay dongusu KARTTAN yurumeli: kullanici dosyayi acip
              inceledikten sonra listeye donup aksiyon aramasin.

              "Yeni Surum Yukle" BURADA YOK: dosya secimi ve icerik yukleme
              kart galerisinin isi; buraya ikinci bir yukleme yolu koymak ayni
              dosyayi iki akistan gecirmek olurdu. */}
          {kaynak === 'dokuman' && !yeniMi && (
            <>
              <button className="d" onClick={() => void guvenli(async () => {
                // Icerik ucu KIMLIK ister; adresi yeni sekmede acmak token
                //   tasimadigi icin 401 doner - blob olarak cekilir.
                const url = await api.dokumanIcerikUrl(Number(id));
                window.open(url, '_blank');
              })}>📂 Aç / Önizle</button>

              <button className="d" onClick={() => void guvenli(async () => {
                const url = await api.dokumanIcerikUrl(Number(id));
                // DOKUMAN ADIYLA iner; ad uzantisizsa icerik tipinden
                //   tamamlanir (uzantisiz dosya acilamiyor).
                dosyaIndirUrl(url, dokumanDosyaAdi(String(deger.ad ?? ''),
                                                   String(deger.contentType ?? '')), true);
              })}>⬇ İndir</button>

              {/* ONAYA GONDERILEN SURUMDUR, dokuman degil: taslak surum yoksa
                  gonderilecek bir sey de yok. */}
              {Number(deger.surumlu) === 1 && (
                <button className="d" onClick={() => void guvenli(async () => {
                  const k = await api.kartOku('dokuman', Number(id));
                  const taslak = (k.detaylar?.surumler ?? [])
                    .find(x => Number(x.durum) === 1);
                  if (!taslak) {
                    bilgiMesaji('Onaya gönderilecek taslak sürüm yok. '
                              + 'Önce yeni sürüm yükleyin.');
                    return;
                  }
                  const y = await api.dokumanOnayaGonder(Number(taslak.id));
                  bilgiMesaji(y.mesaj);
                })}>✔ Onaya Gönder</button>
              )}

              {/* PAYLASIM LINKI (424): sureli ve sayacli. Ozel nitelikli
                  dokumanda ayri yetki gerekir - sunucu reddeder. */}
              <button className="d" onClick={() => void guvenli(async () => {
                const y = await api.dokumanPaylasimUret(Number(id), { gunSayisi: 30 });
                // Kod PANOYA kopyalanir: kullanicidan 32 haneli bir dizeyi
                //   ekrandan elle yazmasini beklemek gercekci degil.
                const adres = `${location.origin}/api/dokuman-paylasim/${y.kod}`;
                try { await navigator.clipboard.writeText(adres) } catch { /* yoksay */ }
                bilgiMesaji(`Paylaşım linki üretildi (30 gün):\n\n${adres}\n\n`
                          + 'Adres panoya kopyalandı.');
              })}>🔗 Paylaş</button>

              <button className="d" onClick={() => void guvenli(async () => {
                const d = await api.dokumanDepo();
                const mb = (b: number) => (b / 1024 / 1024).toFixed(1) + ' MB';
                bilgiMesaji(`Depo kullanımı\n\nFiziksel: ${mb(d.fizikselBayt)}\n`
                          + `Mantıksal: ${mb(d.mantikselBayt)}\n`
                          + `Dedup tasarrufu: ${mb(d.tasarrufBayt)}`);
              })}>📊 Depo</button>
            </>
          )}

          {/* ENTEGRASYON HESABI (336-340) - mockup'taki kart arac cubugu:
              hesap kaydedildikten sonra AYNI ekrandan sinanabilsin, kullanici
              listeye donmek zorunda kalmasin. SKRS senkronu yalniz SKRS
              hesabinda anlamli. */}
          {kaynak === 'entegrasyon-hesap' && !yeniMi && (
            <>
              <button className="d" onClick={() => void guvenli(async () => {
                const y = await api.entegrasyonSina(Number(id));
                bilgiMesaji(y.mesaj);
              })}>🔌 Bağlantıyı Sına</button>
              {/* SKRS senkronu YALNIZ HBYS kurulumunda (345): ERP'de eski bir
                  SKRS satiri duruyor olsa da dugme gosterilmez. */}
              {String(deger.kod ?? '') === 'SKRS' && kullanici?.urunModu === 2 && (
                <button className="d" onClick={() => void guvenli(async () => {
                  if (!await onaySor('SKRS kod listeleri servisten çekilip yerel '
                                     + 'listeler güncellenecek. Devam edilsin mi?')) return;
                  const y = await api.skrsListeSenkron(Number(id));
                  bilgiMesaji(y.mesaj);
                })}>⟳ SKRS Listelerini Güncelle</button>
              )}
            </>
          )}
          <button className="d kapat-dugmesi" onClick={kapatIstendi}>Kapat</button>
          {/* Cari'ye ozel: Musteri/Tedarikci rolleri hizlı erisim icin arac cubuguna,
              Kaydet/Sil ile ayni satira, saga yanasik olarak da tasindi (Roller sekmesindeki
              alanlarla AYNI deger - ikisi de senkron, tekrar degil). */}
          {/* Musteri/Tedarikci kutulari: ADAY ekraninda YOK (kullanici karari) -
              aday henuz ne musteri ne tedarikci; rolu donusumde belirlenir. */}
          {kaynak === 'cari' && !gizliAlanlar?.includes('musteri')
            && meta.alanlar.some(a => a.ad === 'musteri') && (
            <span style={{ marginLeft: 'auto', display: 'flex', gap: 12, alignItems: 'center' }}>
              <label className="satir-ici">
                <input
                  type="checkbox"
                  checked={Boolean(deger.musteri)}
                  disabled={salt}
                  onChange={e => setDeger(d => ({ ...d, musteri: e.target.checked }))}
                />
                Müşteri
              </label>
              <label className="satir-ici">
                <input
                  type="checkbox"
                  checked={Boolean(deger.tedarikci)}
                  disabled={salt}
                  onChange={e => setDeger(d => ({ ...d, tedarikci: e.target.checked }))}
                />
                Tedarikçi
              </label>
            </span>
          )}
        </>
      }
    >
      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      {cakisma && (
        <div className="cakisma-kutusu">
          <b>Bu kaydi baska bir kullanici degistirdi.</b>
          {cakisma.alanlar.length > 0 && <div>Cakisan alanlar: {cakisma.alanlar.join(', ')}</div>}
          <div className="cakisma-arac">
            <button className="d" onClick={() => { setCakisma(null); void yukle() }}>Güncel Hâli Al (Değişikliklerim Gider)</button>
            <button className="d" onClick={() => {
              // Sunucudaki guncel surumu alip kendi degisikliklerimi UZERINE yaz
              setSurum(String(cakisma.guncel.surum ?? ''));
              setCakisma(null);
            }}>Benim Değişikliklerimi Uygula</button>
          </div>
        </div>
      )}

      {aktif?.tur === 'grup' && meta && (() => {
        const govde = (
        <KartGrupSekmesi
          aktif={aktif} kaynak={kaynak} id={id} yeniMi={yeniMi} meta={meta}
          salt={salt} personelGibiKart={personelGibiKart}
          deger={deger} setDeger={setDeger}
          detaylar={detaylar} setDetaylar={setDetaylar}
          alanHatalari={alanHatalari} gizliSekmeler={gizliSekmeler}
          resimYerTutucu={resimYerTutucu} gruplar={gruplar}
          altGruplaVar={altGruplaVar} renderAlanListesi={renderAlanListesi}
          aramaAc={(alan, kaynak, uygula) => setAramaAlani({ alan, kaynak, uygula })}
          secilenAdlar={secilenAdlar}
        />
        );
        const tam = kaynak === 'randevu' ? (
          <>
            {govde}
            {/* TETKİK-CİHAZ uyumu ve protokol süresi (317): hasta gelmeden
                randevu alındığı için yanlış cihaz ancak hasta geldiğinde fark
                edilirdi. Engelleme veritabanı tetiğinde, bu erken uyarı. */}
            <RandevuTetkikUyum
              hizmetId={Number(deger.hizmetId) || null}
              cihazId={Number(deger.cihazId) || null}
              sureDk={Number(deger.sureDk) || 0}
              onSure={dk => alanDegistir('sureDk', String(dk))}
            />
            {/* UYGUN SAATLER (mockup): secili hekim + tarih icin o gunun
                slotlari; bos saate tiklamak kartin baslangicini tasir. */}
            <RandevuUygunSaatler
              hekimId={Number(deger.hekimId) || null}
              hekimAdi={meta.alanlar.find(a => a.ad === 'hekimId')
                            ?.kodlar?.[String(deger.hekimId ?? '')]}
              bolum={Number(deger.bolum) || null}
              tarih={String(deger.baslangic ?? '').slice(0, 10)}
              sureDk={Number(deger.sureDk) || 0}
              seciliSaat={String(deger.baslangic ?? '').slice(11, 16)}
              hariçId={yeniMi ? null : Number(id)}
              onSec={saat => alanDegistir(
                'baslangic', `${String(deger.baslangic ?? '').slice(0, 10)}T${saat}`)}
            />
            {/* Ozet serit EN ALTTA (mockup .ozet): hasta no, son randevu,
                acik bakiye, olusturma. */}
            <RandevuOzetSeridi
              hastaId={Number(deger.hastaId) || null}
              hariçId={yeniMi ? null : Number(id)}
              olusturan={String(deger.eklemeTarihi ?? '')}
            />
          </>
        ) : govde;
        // GRUBA GOMULU DETAY (mockup "Fizik Muayene"): sablon alanlarinin
        //   ALTINDA sistem/normal/bulgu tablosu - ayri sekme degil.
        const gomulu = (meta?.detaylar ?? [])
          .filter(d => detayGrupta?.[d.ad]?.grup === aktif.baslik);
        const tablolar = gomulu.map(d => (
              <GenDetayTablo
                key={d.ad}
                meta={d}
                durum={detaylar[d.ad] ?? bosDetay()}
                saltOkunur={salt || d.saltOkunur || !!detayGrupta?.[d.ad]?.salt}
                modalDuzenle={detayGrupta?.[d.ad]?.gridKipi}
                ikonlu={detayGrupta?.[d.ad]?.gridKipi}
                hatalar={alanHatalari}
                kutuSinif={detayGrupta?.[d.ad]?.sinif}
                sadeGrid={detayGrupta?.[d.ad]?.sade}
                ekleGizli={detayGrupta?.[d.ad]?.ekleGizli}
                gizliAlanlar={detayGrupta?.[d.ad]?.gizli
                  ? new Set(detayGrupta[d.ad].gizli) : undefined}
                etiketAlanlari={detayGrupta?.[d.ad]?.etiket
                  ? new Set(detayGrupta[d.ad].etiket) : undefined}
                onDegis={yeni => setDetaylar(t => ({ ...t, [d.ad]: yeni }))}
              />
        ));
        // USTTE: tanida tablo ONCE gelir (mockup) - hekim once ICD girer,
        //   sevk/takip alanlari karari yazarken doldurulur.
        const ustte = gomulu.some(d => detayGrupta?.[d.ad]?.ustte);
        const tumu = gomulu.length === 0 ? tam
          : ustte ? <>{tablolar}{tam}</> : <>{tam}{tablolar}</>;
        // IZGARA CIZICI: ekran bir DETAYI (or. vitaller) istedigi yere
        //   etiket+kutu izgarasi olarak koyabilsin - anamnez sekmesinin sag
        //   paneli boyle: hekim sikayeti yazarken vitali AYNI ekranda girer.
        const izgaraCiz = (detayAd: string) => {
          const d = (meta?.detaylar ?? []).find(x => x.ad === detayAd);
          if (!d) return null;
          const ayar = detayIzgara?.[detayAd] ?? {};
          return (
            <div className={ayar.sinif}>
              <TekKayit
                meta={d}
                durum={detaylar[d.ad] ?? bosDetay()}
                saltOkunur={salt || d.saltOkunur}
                onDegis={yeni => setDetaylar(t => ({ ...t, [d.ad]: yeni }))}
                baslik={ayar.baslik ?? d.baslik}
                alanSirasi={ayar.alanSirasi}
                not={ayar.not}
              />
            </div>
          );
        };
        return sekmeSarmalayici
          ? sekmeSarmalayici(aktif.baslik, tumu, deger, izgaraCiz) : tumu;
      })()}

      {/* Stok > ÜTS: stok_uts 1:1 uzanti (119) - grid degil TEK kayit formu.
          Bir stokun bir ÜTS kaydi olur; "satir ekle" yanlis bir vaat olurdu. */}
      {/* DIS HEKIM "Hekim Bilgisi" (305): 1:1 uzanti - satir ekle/sil'li grid
          degil TEK KAYIT formu (kullanici: "mockup gibi label ve edit olsun").
          Ikinci satir DB'de zaten yazilamaz; grid yanlis bir vaat. */}
      {aktif?.tur === 'detay' && kaynak === 'dis-hekim' && aktif.detay.ad === 'hekim' && (
        <TekKayit
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
          baslik="Hekim Bilgisi"
        />
      )}

      {aktif?.tur === 'detay' && kaynak === 'stok' && aktif.detay.ad === 'uts' && (
        <TekKayit
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
          baslik="ÜTS / Medikal Bilgileri"
          not={<>ÜTS REF ve GTIN, ÜTS bildiriminde ürün eşleştirmesinde kullanılır.
               Menşei ülke listesi ülke tablosundan gelir.</>}
        />
      )}

      {/* Stok > Paket: icerik satiri stok arama penceresinden gelir (grid salt
          gorunum) - baslik/cerceve yok, sekmenin adi zaten "Paket". */}
      {aktif?.tur === 'detay' && kaynak === 'stok' && aktif.detay.ad === 'paket' && (
        <PaketSekmesi
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
        />
      )}

      {aktif?.tur === 'detay' && !(personelGibiKart && aktif.detay.ad === 'ozluk')
        && !(kaynak === 'stok' && (aktif.detay.ad === 'uts' || aktif.detay.ad === 'paket'))
        // Dis hekim "Hekim Bilgisi" TekKayit ile cizildi (305) - generic grid
        //   ayrica cizilirse ayni detay iki kez gorunur.
        && !(kaynak === 'dis-hekim' && aktif.detay.ad === 'hekim')
        // Hizmet > Fiyatlar: kartin kendi fiyat gridi KALKTI (kullanici) -
        //   sekme yalniz fiyat listelerindeki fiyatlari gosterir (asagida).
        && !(kaynak === 'hizmet' && aktif.detay.ad === 'fiyatlar')
        && !detayIzgara?.[aktif.detay.ad] && (() => {
        /**
         * GRID KIPI: satir ici duzenleme yerine SECIM KUTUSU + ust satirda
         * ekle/duzenle/sil + grid menusu (kolonlar / CSV) - liste
         * ekranlarindaki grid davranisi.
         *   - fiyat listesi satirlari: satir ici kip 1.400 satirda milyonlarca
         *     DOM dugumu uretiyordu,
         *   - aramayla dolan detaylar (375): alanlarin cogu salt okunur,
         *   - prim plani detaylari (kullanici): kod/oran alanlari satir ici
         *     kutularda okunaksizdi.
         */
        const ayar = detaySecenekleri?.[aktif.detay.ad];
        const gridKipi = ayar?.gridKipi
          || (kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar')
          || kaynak === 'prim-plani'
          // DOKUMAN (419, kullanici: "gridleri gengrid readonly yap"): tum
          //   detaylari SALT GORUNUM + grid kipi. Surum, onay, baglanti,
          //   paylasim ve gunluk zaten elle duzenlenmez - satir ici kutular
          //   yanlis bir "burayi degistirebilirsin" izlenimi veriyordu.
          //   Grid kipi ayrica kolon menusu ve CSV'yi getirir: liste
          //   ekranlarindaki grid ile ayni davranis.
          || kaynak === 'dokuman'
          || aktif.detay.alanlar.some(a => a.tip === 'kod' && a.aramaKaynagi);
        const grid = (
        <GenDetayTablo
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          // DOKUMAN: en dis cerceve YOK (kullanici) - sekme zaten bir
          //   cercevedir, grid'in kendi baslik seridiyle cift cizgi olusuyordu.
          kutuSinif={ayar?.sinif ?? (kaynak === 'dokuman' ? 'kutu-cercevesiz' : undefined)}
          sadeGrid={ayar?.sade}
          ekleGizli={ayar?.ekleGizli}
          saltOkunur={salt || aktif.detay.saltOkunur || !!ayar?.salt}
          hatalar={alanHatalari}
          onDegis={yeni => setDetaylar(t => ({
            ...t,
            [aktif.detay.ad]:
              kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
                && Number(deger.tarifeTipi) === 2
                ? ttbFiyatTuret(yeni) : yeni,
          }))}
          // Fiyat listesi satirlari SALT GORUNUM + modal duzenleme: satir ici
          //   kipte her satir stok (5.000+) ve hizmet (3.700+) lookup'unu ayri
          //   <select> olarak cizer - 1.438 satirlik listede ~12 MILYON DOM
          //   dugumu sekmeyi donduruyordu ("Satirlar acilmiyor").
          // ARAMAYLA DOLAN DETAY (375) da SALT GORUNUM + ikonlu baslik: satirin
          //   tek yazilabilir alani aciklama, geri kalani tarafin kendi
          //   kaydindan okunuyor - satir ici duzenleme kutulari yanlis bir
          //   "burayi degistirebilirsin" izlenimi veriyordu. Ikonlu baslik
          //   ayrica secim kutusunu, sil ikonunu ve grid menusunu (kolonlar /
          //   CSV) getirir - liste ekranlarindaki grid ile ayni davranis.
          // GRID KIPI (secim kutusu, ust satirda ekle/duzenle/sil, grid menusu):
          //   fiyat listesi satirlari, aramayla dolan detaylar ve PRIM PLANI
          //   detaylari. Prim satirinda alanlarin cogu kod/oran - satir ici
          //   kutular yerine modal duzenleme daha okunakli (kullanici).
          modalDuzenle={gridKipi}
          ikonlu={gridKipi}
          // SAYFALI DETAY (525): serit yalniz katalog sayfa boyu verdiginde
          //   cizilir; sayfasiz detaylarda bu proplarin hicbir etkisi yok.
          sayfa={detaySayfa[aktif.detay.ad] ?? 1}
          toplam={detayToplam[aktif.detay.ad]}
          sayfaYukleniyor={detaySayfaYuk === aktif.detay.ad}
          onSayfa={n => { void detaySayfaDegis(aktif.detay.ad, n) }}
          // Secim yukari akar (534): toplu "Çarpan Gir" dugmesi kartin UST
          //   arac cubugunda, Sil'in saginda duruyor.
          onSecim={setSeciliSatirlar}
          // Satir ici giris tarife tipine gore (533): TTB'de katsayi/carpan,
          //   SUT'ta yalniz katki - fiyat ikisinde de turetilmis degerdir.
          hizliAlanlar={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? tarifeHizli(Number(deger.tarifeTipi) || 0) : undefined}
          // SUZGEC SUNUCUDA yalniz SAYFALI detayda (526); sayfasiz detaylar
          //   bugunku istemci suzmesini surdurur.
          onSuzgec={aktif.detay.sayfaBoyu
            ? suz => { void detaySuzgecUygula(aktif.detay.ad, suz) } : undefined}
          // PRIM ZAMANI "Faturalamada" ISE TAHSILAT TURU SORULMAZ (kullanici):
          //   fatura kesilirken paranin hangi araçla tahsil edilecegi HENUZ
          //   BELLI DEGIL. Eslestirme zaten bu kriteri o kipte yok sayiyor;
          //   alani ekranda tutmak, uygulanmayan bir ayar uretiyordu.
          // kategoriId SUZGEC ANAHTARI (asagida): gridde de modalde de
          //   gorunmez - kullaniciya "Kategori" zaten yol metniyle gosteriliyor.
          // TARIFE TIPINE GORE SUTUN (518, kullanici: "bu listede sutunlar
          //   tipe gore gorunur/gorunmez olacak"):
          //     1 Özel : yalniz Fiyat (hasta oder) - katsayi/carpan/katki yok
          //     2 TTB  : Katsayi x Carpan = Fiyat + Katki (TSS hastasi)
          //     3 SUT  : Fiyat (SKRS'den, elle degismez) + Katki (hasta)
          //   Anlamsiz kolonu gostermek, doldurulmasi gereken bir alan
          //   izlenimi veriyordu.
          gizliAlanlar={ayar?.gizli ? new Set(ayar.gizli)
            : kaynak === 'prim-plani' && Number(deger.primZamani) === 2
            ? new Set(['tahsilatTuru'])
            : kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? new Set(['kategoriId', 'kalemAdi', ...tarifeGizli(Number(deger.tarifeTipi) || 0)])
            : undefined}
          // Tabloyu sadelestirir, DUZENLEMEYI kisitlamaz: modal tam kalir.
          gridGizliAlanlar={ayar?.gridGizli ? new Set(ayar.gridGizli) : undefined}
          // ARAMA PLANIN ROLUNE BAGLI (383, kullanici): yalnizca O ROLDE ADAY
          //   olan kisiler listelenir. Rolu isaretlenmemis birine yazilan
          //   satir `belge_satir_rol`'de hic gorunmez, hakedis HIC dogmaz ve
          //   eksik prim ancak ay sonunda fark edilir.
          //   "Dis hekim yalniz Gönderen planina" kurali bundan KENDILIGINDEN
          //   cikar: aday gorunumunde dis hekimin tek rolu Gönderen.
          // KADEMELER (388): plan SATIRININ cocugu - satir modalinin altinda.
          //   Ayri sekme yapilamiyor cunku cerceve detayi kartin id'siyle
          //   baglar, kademe ise satir_id'ye bagli (torun).
          modalAltBilesen={kaynak === 'prim-plani' && aktif.detay.ad === 'satirlar'
            ? (satirId => <KademeGridi planSatirId={satirId} />) : undefined}
          aramaEkFiltre={kaynak === 'prim-plani' && aktif.detay.ad === 'taraflar'
            ? { alan: 'rol', op: 'esit' as const, deger: Number(deger.rol) || 1 }
            : undefined}
          taslakKural={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? fiyatSatirKurali : undefined}
          // Tumu / Stok / Hizmet cipleri (kullanici) - karma listede tek tur gorunur.
          cipler={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            // `kod`: SAYFALI DETAYDA sunucuya giden cip anahtari (526) -
            //   katalogdaki SQL kosuluyla eslesir.
            // PASIF KALEM GIZLI (531): "Tümü" bile pasif kalemi getirmez -
            //   kategorisi kapatilan (527) kalem kurumun yapmadigi islemdir.
            //   Fiyati kaybolmaz, "Pasif" cipiyle gorulur.
            ? [{ ad: 'Tümü', kod: 'aktif', suz: () => true },
               { ad: '📦 Stok', kod: 'stok',
                 suz: s => s.stokId != null && s.stokId !== '' },
               { ad: '🛠️ Hizmet', kod: 'hizmet',
                 suz: s => s.hizmetId != null && s.hizmetId !== '' },
               { ad: '🚫 Pasif', kod: 'pasif', suz: () => true }]
            : undefined}
          // KATEGORI AGAC COMBOSU (kullanici) - arama kutusunun saginda.
          //   Secenekler SATIRLARDA GECEN dallarla sinirli: 5.000 stok
          //   kategorisinin tamamini listelemek, cogu secimde bos grid verirdi.
          ekSuzgec={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? {
                cizim: (
                  <KategoriSuzgeci
                    tur={[1, 2]}
                    baslik="🌳 Tüm Kategoriler"
                    sinirla={satirKategorileri}
                    deger={satirKategori?.id ?? null}
                    onDegis={(id, agac) => {
                      setSatirKategori(id === null ? null : { id, agac });
                      // SAYFALI DETAYDA SUZGEC SUNUCUDA (526): dal secimi
                      //   ekrandaki 200 satiri degil listenin TAMAMINI suzer.
                      if (aktif.detay.sayfaBoyu)
                        void detaySuzgecUygula(aktif.detay.ad, { kategori: id ?? undefined });
                    }}
                  />
                ),
                deger: satirKategori?.id ?? undefined,
                suz: satirKategori
                  ? (s: Record<string, unknown>) =>
                      satirKategori.agac.includes(Number(s.kategoriId))
                  : undefined,
              }
            : undefined}
        />
        );
        // SARMALAYICI DETAY SEKMESINDE DE CALISIR (461): muayenenin
        //   "Istem & Sonuclar" paneli bir DETAY sekmesinin altina giriyor;
        //   sarmalayici yalniz grup sekmelerinde cagrildigi icin panel hic
        //   cizilmiyordu (grid "satir yok" derken sonuclar duruyordu).
        return sekmeSarmalayici ? sekmeSarmalayici(aktif.baslik, grid, deger) : grid;
      })()}

      {/* DETAY IZGARASI (mockup vital bulgular): en ustteki satir etiket+kutu
          izgarasinda duzenlenir, gecmis satirlar altta salt gorunum. */}
      {aktif?.tur === 'detay' && detayIzgara?.[aktif.detay.ad] && (() => {
        const ayar = detayIzgara[aktif.detay.ad];
        const durum = detaylar[aktif.detay.ad] ?? bosDetay();
        const gecmis = durum.guncel.slice(1);
        return (
          <div className={ayar.sinif}>
            {ayar.yeniDugmesi && !salt && (
              <div className="muayene-arac">
                <button type="button" className="d"
                        onClick={() => setDetaylar(t => {
                          const d = t[aktif.detay.ad] ?? bosDetay();
                          // Yeni olcum EN USTE: izgara hep en son olcumu gosterir.
                          const yeniSatir: Record<string, unknown> = {
                            zaman: new Date().toISOString().slice(0, 16) };
                          return { ...t, [aktif.detay.ad]:
                            { ...d, guncel: [yeniSatir, ...d.guncel] } };
                        })}>
                  ＋ Yeni ölçüm
                </button>
              </div>
            )}
            <TekKayit
              meta={aktif.detay}
              durum={durum}
              saltOkunur={salt || aktif.detay.saltOkunur}
              onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
              baslik={ayar.baslik ?? aktif.detay.baslik}
              alanSirasi={ayar.alanSirasi}
              not={ayar.not}
            />
            {gecmis.length > 0 && (
              <GenDetayTablo
                meta={{ ...aktif.detay, baslik: `Önceki ölçümler (${gecmis.length})` }}
                durum={{ ...durum, guncel: gecmis }}
                saltOkunur
                hatalar={alanHatalari}
                gizliAlanlar={ayar.gecmisGizli ? new Set(ayar.gecmisGizli) : undefined}
                onDegis={() => {}}
              />
            )}
          </div>
        );
      })()}

      {/* Hizmet > Fiyatlar: kalemin gectigi fiyat listesi satirlari
          (kullanici: "bu hizmete ait tum fiyatlar gelsin"; kartin kendi
          hizmet_fiyat gridi kaldirildi). */}
      {aktif?.tur === 'detay' && kaynak === 'hizmet' && aktif.detay.ad === 'fiyatlar' && (
        yeniMi
          ? <div className="not" style={{ marginTop: 12 }}>
              Fiyatlar kart kaydedildikten sonra fiyat listelerinden gelir.
            </div>
          : <HizmetListeFiyatlari hizmetId={id as number} />
      )}

      {/* EKRANA OZEL EK SEKME (mockup muayene karti): icerigi ekran cizer. */}
      {aktif?.tur === 'ozel'
        && ekSekmeler?.find(e => e.anahtar === aktif.anahtar)?.ciz()}

      {aktif?.tur === 'ozel' && kaynak === 'rol' && aktif.anahtar === 'ozel:yetkiler' && (
        <RolYetkiMatrisi rolId={id as number} saltOkunur={salt} />
      )}


      {/* HASTA "Başvurular" (mockup hasta_kimlik_karti.html): hastanin
          basvuru gecmisi. Cift tik basvuruyu KARTIN USTUNDE acar - liste
          ekranina gitmek hasta kartindan kopmak demekti. */}
      {aktif?.tur === 'ozel' && aktif.anahtar === 'ozel:basvurular' && (
        <OncekiBasvurular tarafId={id as number} baslik="Başvuru Geçmişi"
                          onAc={b => setAcilanBasvuru(b)}
                          onYeni={() => setAcilanBasvuru(0)} />
      )}
      {/* 0 = YENI basvuru (bu hastayla acilir), >0 = mevcut basvuru. */}
      {acilanBasvuru !== null && (
        <BelgeKarti
          {...(acilanBasvuru > 0
               ? { id: acilanBasvuru }
               // YENI basvuru bu hastayla acilir - cari aramasi cikmaz.
               : { tur: 19, tarafId: id as number,
                   tarafUnvan: String(deger.unvan
                     ?? `${deger.ad ?? ''} ${deger.soyad ?? ''}`.trim()) })}
          onKapat={() => setAcilanBasvuru(null)}
        />
      )}

      {aktif?.tur === 'ozel' && aktif.anahtar === 'ozel:dokuman' && (
        <DokumanGalerisi kartAdi={kaynak} kaynakId={id as number} saltOkunur={salt} />
      )}

      {aktif?.tur === 'ozel' && aktif.anahtar === 'ozel:stokDurum' && (
        <StokDurumSekmesi stokId={id as number} duzenlenebilir={!salt} />
      )}

      {aktif?.tur === 'ozel' && aktif.anahtar === 'ozel:stokHareket' && (
        <StokHareketSekmesi stokId={id as number} />
      )}

      {/* DIS HEKIM "Gönderim Geçmişi" (305): kart DETAYI degil - baska bir
          ekranin kayitlari (radyoloji istemleri). Duzenlenebilir satir gridi
          yerine liste ekranlarindaki GenGrid, SALT OKUNUR ve hekim filtreli.
          Sekme yer tutucu olarak aciliyor, icini burasi dolduruyor. */}
      {/* Cekim oncesi kontrol listesi (310) - yer tutucu sekme. */}
      {aktif?.tur === 'yerTutucu' && kaynak === 'radyoloji-istem'
       && aktif.baslik === 'Kontrol Listesi' && (
        yeniMi ? (
          <div className="not" style={{ padding: 20 }}>
            İstem kaydedildikten sonra kontrol listesi doldurulur.
          </div>
        ) : (
          <KontrolListesi istemId={id as number} saltOkunur={salt} />
        )
      )}

      {aktif?.tur === 'yerTutucu' && kaynak === 'dis-hekim'
       && aktif.baslik === 'Gönderim Geçmişi' && (
        yeniMi ? (
          <div className="not" style={{ padding: 20 }}>
            Hekim kaydedildikten sonra gönderdiği tetkikler burada listelenir.
          </div>
        ) : (
          <>
            {/* Ozet + modalite dagilimi GRIDIN USTUNDE: satirlar "hangi
                tetkik", ozet "ne kadar / hangi cihaz" sorusunu cevaplar. */}
            <HekimGonderimOzeti hekimId={id as number} />
            <GenGrid
              kaynak="radyoloji-istem"
              gomulu
              seritGizli
              boyut={25}
              sabitFiltre={{ alan: 'istekHekimId', op: 'esit', deger: id as number }}
            />
          </>
        )
      )}

      {aktif?.tur === 'yerTutucu'
       && !(kaynak === 'dis-hekim' && aktif.baslik === 'Gönderim Geçmişi')
       && !(kaynak === 'radyoloji-istem' && aktif.baslik === 'Kontrol Listesi') && (
        <div style={{ padding: 40, textAlign: 'center', color: 'var(--soluk)' }}>
          {aktif.baslik} sekmesi yakında.
        </div>
      )}

      {kaynak === 'kisi' && (
        <TarafArama
          acik={cariyeBaglaAcik}
          kaynaklar={['cari']}
          yerTutucu="Cari (müşteri/tedarikçi) ara…"
          onKapat={() => setCariyeBaglaAcik(false)}
          onSec={secilen => {
            setDeger(d => ({ ...d, bagId: String(secilen.id) }));
            setBagliTarafAdi(secilen.unvan);
          }}
        />
      )}

      {/* Katalogdaki AcilistaTarafSecimi: yeni kayitta cari secim ekrani.
          Secim ilgili alana yazilir; kullanici kapatip alandan da secebilir. */}
      {meta?.acilistaTarafSecimi && (
        <TarafArama
          acik={tarafSecimAcik}
          kaynaklar={['cari']}
          yerTutucu="Cari (müşteri/tedarikçi) ara…"
          onKapat={() => setTarafSecimAcik(false)}
          onSec={secilen => {
            setDeger(d => ({ ...d, [meta.acilistaTarafSecimi!]: String(secilen.id) }));
            setTarafSecimAcik(false);
          }}
        />
      )}

      {/* Jenerik arama ekranlari (260): hasta -> taraf aramasi (yalniz hasta
          kaynagi), hizmet -> stok/hizmet aramasi (yalniz hizmet). */}
      {aramaAlani?.kaynak === 'hasta' && (
        <TarafArama
          acik
          kaynaklar={['hasta']}
          // Bulunamayan hasta icin SADE aday karti (266) - tam hasta karti
          //   kayit kabul masasinda fazla agir.
          yeniKaynak="hasta-aday"
          // Pasif ve VEFAT hastalar randevu aramasinda cikmaz (kullanici):
          //   yalniz AKTIF (1) ve ADAY (2). Durum kodlari 266'da.
          ekFiltre={{ op: 'or', kosullar: [
            { alan: 'durum', op: 'esit', deger: 1 },
            { alan: 'durum', op: 'esit', deger: 2 },
          ] }}
          yerTutucu="Hasta ara…"
          onKapat={() => setAramaAlani(null)}
          onSec={secilen => {
            aramaYaz(aramaAlani, String(secilen.id), secilen.unvan);
          }}
        />
      )}
      {/* CARI aramasi (305): dis hekimin calistigi kurum - kurum listesi
          binlerce cari icerdiginden combo kullanilmaz hale geliyordu. */}
      {aramaAlani?.kaynak === 'cari' && (
        <TarafArama
          acik
          kaynaklar={['cari']}
          yerTutucu="Kurum / cari ara…"
          onKapat={() => setAramaAlani(null)}
          onSec={secilen => {
            aramaYaz(aramaAlani, String(secilen.id), secilen.unvan);
          }}
        />
      )}
      {aramaAlani?.kaynak === 'hizmet' && (
        <StokAramaPenceresi
          etkin
          yalnizHizmet
          onKapat={() => setAramaAlani(null)}
          onSec={satir => {
            aramaYaz(aramaAlani, String(satir.id), String(satir.ad ?? satir.kod ?? ''));
          }}
        />
      )}

      {/* TOPLU CARPAN PENCERESI (534): tek sayi, secili satirlara yazilir;
          fiyat `ttbFiyatTuret` ile aninda yeniden dogar. */}
      {topluCarpan && (
        <Modal baslik={`Çarpan — ${seciliSatirlar.size} satır`} dar enUst
               onKapat={() => setTopluCarpan(false)}
               alt={(
                 <>
                   <button type="button" className="d" onClick={() => setTopluCarpan(false)}>
                     Vazgeç
                   </button>
                   <button type="button" className="d bir"
                           disabled={topluCarpanDeger.trim() === ''}
                           onClick={() => {
                             const sayi = Number(topluCarpanDeger.replace(',', '.'));
                             if (!Number.isFinite(sayi)) return;
                             setDetaylar(t => {
                               const d = t.satirlar ?? bosDetay();
                               const guncel = d.guncel.map((s2, i) =>
                                 seciliSatirlar.has(i) ? { ...s2, carpan: sayi } : s2);
                               return { ...t, satirlar: ttbFiyatTuret({ ...d, guncel }) };
                             });
                             setTopluCarpan(false);
                           }}>
                     {seciliSatirlar.size} satıra uygula
                   </button>
                 </>
               )}>
          <div className="toplu-kutu">
            <label className="alan tip-para">
              <span className="etiket">Çarpan</span>
              <input autoFocus inputMode="decimal" value={topluCarpanDeger}
                     onChange={e => setTopluCarpanDeger(e.target.value)} />
            </label>
            <div className="ic sonuk">
              Fiyat = katsayı × çarpan olarak yeniden hesaplanır.
            </div>
          </div>
        </Modal>
      )}

      {kapatmaUyarisi && (
        <div className="mesaj-perde" onMouseDown={e => e.stopPropagation()}>
          <div className="mesaj-kutu">
            <h3>{`${urunAdi(kullanici?.urunModu)} Mesajı`}</h3>
            <p>Kaydedilmemiş değişiklikler var.</p>
            <div className="mesaj-dugme">
              <button className="d bir" disabled={kaydediyor} onClick={() => { setKapatmaUyarisi(false); void kaydet(); }}>Kaydet</button>
              <button className="d" onClick={() => { setKapatmaUyarisi(false); onKapat?.(); }}>İptal</button>
              <button className="d" onClick={() => setKapatmaUyarisi(false)}>Geri Dön</button>
            </div>
          </div>
        </div>
      )}
    </Modal>
  );
}
