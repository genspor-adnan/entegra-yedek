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
import { Modal } from './Modal';
import { KodListesiModali } from './KodListesiModali';
import { yerelAnMetni, bugunIso, hamSayi, kidemMetni } from './bicim';
import { useUnvanOneki } from './kart/useUnvanOneki';
import { KartKimlikSeridi } from './kart/KartKimlikSeridi';
import { KartDetaySekmesi } from './kart/KartDetaySekmesi';
import { KartGrupSarmalayici } from './kart/KartGrupSarmalayici';
import { kartGovdesiKur } from './kart/kartGovdesi';
import { PaketSekmesi } from './PaketSekmesi';
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
import { YatisSeridi } from './yatan/YatisSeridi';
import { GozMuayeneSeridi } from './goz/GozMuayeneSeridi';
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
  /** Yeni kartta ON DOLU arama alanlarinin (hastaId vb.) gorunen adi - ad
      lookup haritasinda yoksa kutu bos gorunurdu (708: seanstan lab is emri). */
  yeniSecilenAdlar?: Record<string, string>;
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
  ekSekmeler?: {
    anahtar: string; baslik: string;
    /**
     * Sekmeyi cizer. BAGLAM (kartin o anki degerleri, metasi ve detay satir
     * adetleri) ekranin elinde YOK - kart GenForm'un icinde yasiyor. Mikro
     * katalog kartlarinin "Tanım" ozeti bunlarin uzerine kurulu; baglamsiz
     * cizen eski sekmeler (muayene) parametreyi yok sayar.
     */
    ciz(baglam: EkSekmeBaglami): React.ReactNode;
  }[];
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
 * EK SEKMEYE VERILEN KART BAGLAMI: sekmeyi EKRAN tanimliyor ama kartin
 * degerleri GenForm'un icinde yasiyor. Ozet sekmeleri (mikro katalog
 * kartlarinin "Tanım"i) ikinci bir istek atmadan buradan beslenir.
 */
export interface EkSekmeBaglami {
  deger: Record<string, Deger>;
  meta: KartMetaYaniti | null;
  /** Detay sekmesindeki satir adedi (ör. panelde kac antibiyotik var). */
  detaySayisi(ad: string): number;
}

/**
 * Jenerik arama penceresi acilabilen TARAF kaynaklari. `hasta` ve `cari`
 * kendi dallarinda: onlarin ek kurallari var (aday karti, durum suzgeci).
 */
const TARAF_ARAMA_KAYNAKLARI = ['kurum', 'dis-hekim', 'personel', 'kisi'];

export function GenForm({ kaynak, id, baslik, onKapat, seritAlanlari, seritSarmalayici, sekmeSarmalayici, detayGrupta, detayIzgara, detaySecenekleri, gizliDetaylar, ekSekmeler, sekmeSirasi, tazeleAnahtari, onKaydedildi, yerTutucuSekmeler,
                          ustBaglam, altBilgi, ekAraclar, baslikEk,
                          resimYerTutucu, cariyeBaglaGizli, yeniKayitVarsayilanlari, yeniSecilenAdlar,
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
  const unvanOneki = useUnvanOneki(kaynak);

  const [meta, setMeta] = useState<KartMetaYaniti | null>(null);
  /**
   * LISTE DUZENLEME PENCERESI (544): kod_liste'den beslenen alanin etiketine
   * tiklaninca acilir. Bagli listede (model -> marka) YALNIZ secili ustun
   * satirlari duzenlenir; yeni satir da ona baglanir - "Bilimplant'in
   * modelleri" listesi baska hicbir ekrandan girilemiyordu.
   */
  const [listeDuzenlenen, setListeDuzenlenen] =
    useState<{ kod: string; baslik: string; ustDeger?: number } | null>(null);

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
  /** Toplu "Katkı Gir" penceresi (541). */
  const [topluKatki, setTopluKatki] = useState(false);
  const [topluKatkiOran, setTopluKatkiOran] = useState('');
  /** Toplu "Fiyat Güncelle" penceresi (kullanici, Özel tarife). */
  const [fiyatGuncelle, setFiyatGuncelle] = useState(false);
  const [fiyatYonu, setFiyatYonu] = useState<'artir' | 'azalt'>('artir');
  const [fiyatYuzde, setFiyatYuzde] = useState('');
  /** SKRS tazeleme surerken dugme kilitli (535). */
  const [skrsCalisiyor, setSkrsCalisiyor] = useState(false);

  /**
   * SUT LISTESINI SKRS AMBARINDAN TAZELE (535). Kaydedilmemis satir
   * degisikligi varsa once sorulur: tazeleme sunucuda yapiliyor ve kart
   * yeniden okunuyor - ekrandaki duzenleme kaybolurdu.
   */
  const skrsGuncelle = async () => {
    if (typeof id !== 'number') return;
    const durum = detaylar.satirlar;
    if (durum) {
      const fark = detayFarki(durum);
      if (fark.eklenen || fark.degisen || fark.silinen) {
        const devam = await onaySor(
          'Kaydedilmemiş satır değişiklikleri var. SKRS güncellemesi kartı '
          + 'yeniden okur ve bu değişiklikler kaybolur. Devam edilsin mi?');
        if (!devam) return;
      }
    }
    setSkrsCalisiyor(true);
    try {
      const s2 = await api.fiyatSutGuncelle(id);
      await bilgiMesaji(s2.mesaj);
      await yukle();
    } catch (h) {
      await bilgiMesaji(hataMetni(h));
    } finally {
      setSkrsCalisiyor(false);
    }
  };

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
    useState<{ id: number; agac: number[]; ad: string } | null>(null);
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

  /** Toplu uygulama sunucuya giderken dugmeler kilitli. */
  const [topluCalisiyor, setTopluCalisiyor] = useState(false);

  /**
   * TOPLU SATIR DEGERI - SUNUCUDA (kullanici: "modalde 3 buton: seçili
   * satıra uygula · <kategori> uygula · tüm listeye uygula").
   *
   * NEDEN SUNUCUDA: satir gridi 200'erlik sayfalarla geliyor (526). Kategori
   * ve "tüm liste" kapsamlari ekranda YUKLU OLMAYAN satirlari da kapsiyor -
   * istemcide yapilsaydi 14 bin satirlik listede yalnizca gorunen sayfa
   * degisir, kullanici "uygulandi" mesajini gorup eksik listeyle devam
   * ederdi. Seçili kapsam da ayni yoldan gider: uc dugmenin biri kaydedilmis,
   * ikisi kaydedilmemis degisiklik uretseydi "Kaydet" belirsizlesirdi.
   */
  const topluUygula = async (
    islem: 'carpan' | 'katki' | 'fiyat-yuzde',
    deger: number,
    kapsam: 'secili' | 'kategori' | 'tumu',
    yon?: 'artir' | 'azalt',
  ): Promise<boolean> => {
    if (typeof id !== 'number' || !Number.isFinite(deger) || deger <= 0) return false;
    const durum = detaylar['satirlar'];
    // Sunucuda yazip kartI yeniden okuyoruz: ekrandaki kaydedilmemis
    //   duzenleme kaybolur - once sorulur (SKRS tazelemesiyle ayni kural).
    if (durum) {
      const fark = detayFarki(durum);
      if (fark.eklenen || fark.degisen || fark.silinen) {
        const devam = await onaySor(
          'Kaydedilmemiş satır değişiklikleri var. Toplu uygulama satırları '
          + 'sunucuda günceller ve bu değişiklikler kaybolur. Devam edilsin mi?');
        if (!devam) return false;
      }
    }
    if (kapsam === 'tumu') {
      const devam = await onaySor(
        `Listenin TAMAMINA uygulanacak (${(detayToplam['satirlar']
          ?? durum?.guncel.length ?? 0).toLocaleString('tr')} satır). Devam edilsin mi?`);
      if (!devam) return false;
    }
    const satirIdler = kapsam === 'secili'
      ? [...seciliSatirlar].map(i => Number(durum?.guncel[i]?.id)).filter(x => x > 0)
      : undefined;
    if (kapsam === 'secili' && !satirIdler?.length) {
      await bilgiMesaji('Seçili satırların henüz kaydedilmemiş olanları toplu '
                        + 'uygulamaya giremez - önce Kaydet.');
      return false;
    }
    setTopluCalisiyor(true);
    try {
      const s2 = await api.fiyatTopluDeger(id, {
        islem, deger, kapsam, satirIdler,
        kategoriId: kapsam === 'kategori' ? satirKategori?.id : undefined, yon,
      });
      await bilgiMesaji(s2.mesaj);
      setSeciliSatirlar(new Set());
      await detaySayfaCek('satirlar', detaySayfa['satirlar'] ?? 1);
      return true;
    } catch (h) {
      await bilgiMesaji(hataMetni(h));
      return false;
    } finally {
      setTopluCalisiyor(false);
    }
  };

  /**
   * TOPLU PENCERELERIN ARAC CUBUGU: uc kapsam dugmesi sola, Kapat saga
   * (kullanici). Hangi dugmeye basildiysa kapsam odur - pencerede ayrica
   * "kapsam" secmek gerekmiyor.
   */
  const topluButonlar = (gecerli: boolean,
                         calistir: (kapsam: 'secili' | 'kategori' | 'tumu') => void,
                         kapat: () => void) => {
    // DEGER BOSKEN DUGMELER PASIF DEGIL (kullanici: "butonlar da pasif
    //   geliyor"): pencere acildiginda kutu zaten bos oluyordu ve UC dugme
    //   birden gri geliyor, ekran bozuk gorunuyordu. Eksik deger tiklanınca
    //   SOYLENIR - kapsam dugmesi yalniz KENDI on kosulu yoksa kilitlenir
    //   (satir secilmemis / kategori secilmemis).
    const dogrula = (kapsam: 'secili' | 'kategori' | 'tumu') => {
      if (!gecerli) { void bilgiMesaji('Önce geçerli bir değer girin.'); return }
      if (kapsam === 'secili' && seciliSatirlar.size === 0) {
        void bilgiMesaji('Önce satırlar sekmesinden satır seçin.'); return;
      }
      if (kapsam === 'kategori' && !satirKategori) {
        void bilgiMesaji('Önce satırlar sekmesindeki kategori combosundan bir dal seçin.');
        return;
      }
      calistir(kapsam);
    };
    return (
    <>
      <button type="button" className="d bir"
              disabled={topluCalisiyor}
              title={seciliSatirlar.size === 0 ? 'Gridde satır seçilmedi' : undefined}
              onClick={() => dogrula('secili')}>
        {seciliSatirlar.size} satıra uygula
      </button>
      <button type="button" className="d"
              disabled={topluCalisiyor}
              title={satirKategori
                     ? `"${satirKategori.ad}" ve alt kategorilerindeki tüm satırlar`
                     : 'Satırlar sekmesinde kategori seçin'}
              onClick={() => dogrula('kategori')}>
        {satirKategori ? `${satirKategori.ad} uygula` : 'Kategoriye uygula'}
      </button>
      <button type="button" className="d" disabled={topluCalisiyor}
              title="Listedeki bütün satırlar (ekranda görünmeyenler dâhil)"
              onClick={() => dogrula('tumu')}>
        Tüm listeye uygula
      </button>
      <button type="button" className="d kapat-dugmesi" onClick={kapat}>Kapat</button>
    </>
    );
  };

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

  /** Duzenlenen kod listesinin seceneklerini kart metasina geri yazar (544). */
  const listeSecenekleriTazele = useCallback(async (kod: string) => {
    try {
      const y = await api.kodListe(kod);
      const kodlar: Record<string, string> = {};
      const ust: Record<string, string> = {};
      for (const d of y.degerler) {
        if (d.aktif !== 1) continue;
        kodlar[String(d.deger)] = d.ad;
        if (d.ustDeger) ust[String(d.deger)] = String(d.ustDeger);
      }
      setMeta(m => m && ({
        ...m,
        alanlar: m.alanlar.map(a => a.kodListesi === kod
          ? { ...a, kodlar, kodUst: a.bagliAlan ? ust : a.kodUst } : a),
      }));
    } catch { /* liste tazelenemezse eski secenekler kalir */ }
  }, []);

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
        if (yeniSecilenAdlar) setSecilenAdlar(s => ({ ...s, ...yeniSecilenAdlar }));
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
        if (kaynak === 'dis-hekim') unvanOneki.setHam(String(k.kart.unvan ?? '').trim());
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

  
/** Mikrobiyoloji katalog kartlari - serit duzeni mockup'la ayni (dort sutun). */

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

  /**
   * LAB ISTEMI CALISILIYOR ISE "Tetkikler" ACIK GELIR (kullanici: "istem
   * karti, eger durum calisiliyor ise aktif sekme tetkikler olsun").
   * O asamada kartta yapilacak tek is sonuc girmektir; Kimlik sekmesiyle
   * acilmak teknisyene her seferinde bir tiklama fazladan yaptiriyordu.
   *
   * Karar KAYIT BASINA BIR KEZ: kullanici baska sekmeye gecince geri
   * ziplamasin. `durum` kayit yuklenince dolar - bos iken karar verilmez.
   */
  const acilisKarari = useRef('');
  useEffect(() => {
    if (yeniMi || kaynak !== 'lab-istem') return;
    if (acilisKarari.current === kayitAnahtari) return;
    const durum = Number(deger.durum ?? 0);
    if (!durum) return;
    acilisKarari.current = kayitAnahtari;
    if (durum !== 3) return;
    const hedef = detaySekmeAnahtari('satirlar');
    if (sekmeler.some(x => x.anahtar === hedef)) setAktifSekme(hedef);
  }, [kaynak, kayitAnahtari, yeniMi, deger.durum, sekmeler]);

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

    // LAB İSTEMİ "Sonuçlandı" / "Onaylandı" (kullanıcı: "kullanıcı sonuçlandı
    //   yaparsa sonuç girilmemiş tetkik varsa uyar ama yine de izin ver").
    //   Durum normalde satırlardan TÜRETİLİR; elle işaretleme o türetmeyi
    //   ezer - eksik tetkik varsa istem listede bitmiş görünür ve kimse
    //   dönüp bakmaz. ENGEL DEĞİL UYARI: dış laboratuvara giden, iptal
    //   edilemeyen ya da hastanın vazgeçtiği tetkik yüzünden istemi kapatmak
    //   meşru bir karardır; kararı veren bilerek versin.
    if (kaynak === 'lab-istem'
        && (Number(deger.durum) === 4 || Number(deger.durum) === 5)) {
      const eksikler = (detaylar.satirlar?.guncel ?? [])
        .filter(r => Number(r.durum ?? 0) !== 0
                     && String(r.sonuc ?? '').trim() === '');
      if (eksikler.length > 0) {
        const adlar = eksikler.slice(0, 5)
          .map(r => String(r.kod || r.ad || '?')).join(', ');
        const devam = await onaySor(
          `${eksikler.length} tetkikte sonuç girilmemiş: ${adlar}`
          + (eksikler.length > 5 ? ' …' : '')
          + `

İstem yine de "${Number(deger.durum) === 5 ? 'Onaylandı' : 'Sonuçlandı'}"`
          + ' olarak kaydedilsin mi?');
        if (!devam) return;
      }
    }

    setKaydediyor(true);
    setHata(null);
    setAlanHatalari({});
    setCakisma(null);
    setBilgi(null);
    try {
      // Govde kurma KURALI saf fonksiyonda (kart/kartGovdesi): telefon
      //   tekillestirme, unvan birlestirme ve aday hastanin dosya no turetimi.
      const govde = kartGovdesiKur({
        kaynak, meta, deger, degisenAlanlar: degisenAlanlar(), detaylar, surum,
        personelGibiKart, unvanOneki: unvanOneki.onek, detayAlanlari,
      });

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
    listeDuzenle: a => {
      if (!a.kodListesi) return;
      // Bagli listede ust SECILMIS olmali: markasiz "model ekle" hangi
      //   markaya yazilacagi belirsiz bir satir uretirdi.
      const ust = a.bagliAlan ? Number(deger[a.bagliAlan] ?? 0) : undefined;
      if (a.bagliAlan && !ust) {
        bilgiMesaji(`Önce ${meta?.alanlar.find(x => x.ad === a.bagliAlan)?.baslik
                      ?? a.bagliAlan} seçin.`);
        return;
      }
      setListeDuzenlenen({ kod: a.kodListesi, baslik: a.baslik, ustDeger: ust });
    },
  });

  return (
    <Modal
      baslik={`${baslik ?? kaynak} ${yeniMi ? '— Yeni' : `#${id}`}`}
      dar={TEK_SUTUN_KARTLAR.has(kaynak)}
        // Kart KAYNAK ADINI sinif olarak tasir (`kart-lab-istem`): ekrana
        //   ozel duzen kurallari CSS'te o kartla sinirli kalsin - alan adi
        //   sinifi tek basina her kartin "durum" alanini etkilerdi.
        ekSinif={`kart-${kaynak}${kaynak === 'randevu' ? ' kart-orta' : ''}`}
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
        {kimlikAlanlari.length > 0 && (
          <KartKimlikSeridi
            yeniMi={yeniMi}
            kaynak={kaynak} deger={deger} meta={meta} salt={salt}
            detaylar={detaylar} setDetaylar={setDetaylar}
            kimlikAlanlari={kimlikAlanlari}
            renderAlanListesi={renderAlanListesi}
            seritSarmalayici={seritSarmalayici}
            personelGibiKart={personelGibiKart} dogumYasMetni={dogumYasMetni}
            unvanOneki={unvanOneki}
          />
        )}
        {/* RADYOLOJI ISTEMI (310): akis seridi + ozet KIMLIK SERIDININ ALTINDA,
            sekmelerin USTUNDE - hangi sekmede olursan ol "istem nerede"
            gorunmeli (mockup radyoloji_istem_karti.html). Yeni kayitta yok. */}
        {kaynak === 'radyoloji-istem' && !yeniMi && <IstemAkisi istemId={id as number} />}
        {/* YATIS KARTI (695, mockup yatis_karti.html): kimlik + son vital
            seridi SEKMELERIN DISINDA - yatan hastada "kim, nerede, kacinci
            gun, nasil" her kararin onkosulu; sekmeye gomulurse hekim her
            seferinde tiklar. */}
        {kaynak === 'yatan' && !yeniMi && <YatisSeridi yatisId={id as number} />}
        {/* GOZ MUAYENESI (691, mockup goz_detayli_muayene.html): kimlik +
            baglam kutulari (sikayet, sistemik/ilac, on tetkik, aile) +
            tamamlanma cubugu SEKMELERIN USTUNDE - hekim olcume baslamadan
            once bu dordunu okuyor; sekmeye gomulurse her muayenede iki kez
            gezinilir. Yeni kayitta yok: henuz muayene numarasi bile olusmadi. */}
        {kaynak === 'goz-muayene' && !yeniMi && (
          <GozMuayeneSeridi gozMuayeneId={id as number} />
        )}
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
          {/* FIYAT GUNCELLE (kullanici: "özel fiyat tipinde Sil butonu
              sağına Fiyat Güncelle; modalde Artır/Azalt combosu ve yüzde
              editi"). Yalniz OZEL tarifede: TTB fiyati katsayi x carpan'dan,
              SUT fiyati SKRS ambarindan dogar - orada fiyata elle yuzde
              uygulamak bir sonraki turetmede geri alinirdi. Secili satirlara
              calisir, oteki toplu dugmelerle ayni kural. */}
          {!yeniMi && kaynak === 'fiyat-listesi' && Number(deger.tarifeTipi) === 1 && (
            <button type="button" className="d"
                    disabled={seciliSatirlar.size === 0}
                    title={seciliSatirlar.size === 0
                           ? 'Önce satırlardan seçim yapın'
                           : `Seçili ${seciliSatirlar.size} satırın fiyatını yüzdeyle güncelle`}
                    onClick={() => { setFiyatYuzde(''); setFiyatYonu('artir');
                                     setFiyatGuncelle(true) }}>
              ↕ Fiyat Güncelle{seciliSatirlar.size > 0 ? ` (${seciliSatirlar.size})` : ''}
            </button>
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
          {/* KATKI GIR (541, kullanici: "TTB ve SUT turlerinde durum degis
              butonu soluna Katkı Gir ekle; gelen modalde girilen orani fiyat
              ile carpip hasta katkiyi guncelle"). Hastadan alinacak tutar
              tarifeye gore fiyatin sabit bir orani oluyor (TSS hastasinda
              TTB'nin, SGK'da SUT'un) - 14 bin satirda tek tek yazilmaz.
              Ozel tarifede YOK: orada hastanin odedigi zaten fiyatin
              kendisidir, ayrica bir katki alinmaz. */}
          {!yeniMi && kaynak === 'fiyat-listesi'
            && [2, 3].includes(Number(deger.tarifeTipi)) && (
            <button type="button" className="d"
                    disabled={seciliSatirlar.size === 0}
                    title={seciliSatirlar.size === 0
                           ? 'Önce satırlardan seçim yapın'
                           : `Seçili ${seciliSatirlar.size} satıra katkı yaz`}
                    onClick={() => { setTopluKatkiOran(''); setTopluKatki(true) }}>
              ◈ Katkı Gir{seciliSatirlar.size > 0 ? ` (${seciliSatirlar.size})` : ''}
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
          {/* SKRS'DEN GUNCELLE (535, kullanici: "SUT fiyat tipi icin durum
              degis saginda 'SKRS'den Güncelle' ekle, basinca SKRS'den
              guncellesin"): SUT fiyati elle degismez (518/533) - tek mesru
              yazma yolu bu. Ambardan okur (520), servise gitmez. */}
          {!yeniMi && kaynak === 'fiyat-listesi' && Number(deger.tarifeTipi) === 3 && (
            <button type="button" className="d" disabled={skrsCalisiyor}
                    title="SUT fiyatlarını SKRS ambarından tazele"
                    onClick={() => { void skrsGuncelle() }}>
              {skrsCalisiyor ? '⏳ Güncelleniyor…' : '⭳ SKRS’den Güncelle'}
            </button>
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

      {aktif?.tur === 'grup' && meta && (
        <KartGrupSarmalayici
          aktif={aktif} kaynak={kaynak} id={id} yeniMi={yeniMi} meta={meta}
          salt={salt} personelGibiKart={personelGibiKart}
          deger={deger} setDeger={setDeger} alanDegistir={alanDegistir}
          detaylar={detaylar} setDetaylar={setDetaylar}
          alanHatalari={alanHatalari} gizliSekmeler={gizliSekmeler}
          resimYerTutucu={resimYerTutucu} gruplar={gruplar}
          altGruplaVar={altGruplaVar} renderAlanListesi={renderAlanListesi}
          setAramaAlani={setAramaAlani} secilenAdlar={secilenAdlar}
          detayGrupta={detayGrupta} detayIzgara={detayIzgara}
          sekmeSarmalayici={sekmeSarmalayici}
        />
      )}

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
        && !detayIzgara?.[aktif.detay.ad] && (
        <KartDetaySekmesi
          aktif={aktif} kaynak={kaynak} salt={salt}
          deger={deger} alanHatalari={alanHatalari}
          detaylar={detaylar} setDetaylar={setDetaylar}
          detaySayfa={detaySayfa} detayToplam={detayToplam}
          detaySayfaYuk={detaySayfaYuk} detaySayfaDegis={detaySayfaDegis}
          detaySuzgecUygula={detaySuzgecUygula}
          detaySecenekleri={detaySecenekleri}
          satirKategori={satirKategori} setSatirKategori={setSatirKategori}
          satirKategorileri={satirKategorileri}
          setSeciliSatirlar={setSeciliSatirlar}
          sekmeSarmalayici={sekmeSarmalayici}
        />
      )}

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
        && ekSekmeler?.find(e => e.anahtar === aktif.anahtar)?.ciz({
             deger, meta,
             detaySayisi: ad => detaylar[ad]?.guncel.length ?? 0,
           })}

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

      {/* Katalogdaki AcilistaTarafSecimi: yeni kayitta taraf secim ekrani.
          Secim ilgili alana yazilir; kullanici kapatip alandan da secebilir.

          ARANAN KAYNAK ALANIN KENDI KAYNAGIDIR (`aramaKaynagi`), kosulsuz
          'cari' DEGIL. Dis modulunde bu alan HASTA'dir (plan, seans, lab is
          emri): kosulsuz cari acildiginda pencere musteri/tedarikci listesi
          gosteriyordu ve secilen SIRKET hasta alanina yaziliyordu - uctan uca
          testte lab is emri "CEMRE ELEKTRİK ... LİMİTED ŞİRKETİ" hastasiyla
          acildi. Alan zaten katalogda `AramaKaynagi: "hasta"` diyor. */}
      {meta?.acilistaTarafSecimi && (
        <TarafArama
          acik={tarafSecimAcik}
          kaynaklar={(meta.alanlar.find(a => a.ad === meta.acilistaTarafSecimi)
                        ?.aramaKaynagi ?? 'cari')
                       .split(',').map(x => x.trim()).filter(Boolean)}
          yerTutucu={(meta.alanlar.find(a => a.ad === meta.acilistaTarafSecimi)
                        ?.aramaKaynagi ?? 'cari') === 'hasta'
                       ? 'Hasta ara…' : 'Cari (müşteri/tedarikçi) ara…'}
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
      {/* TARAF TABANLI OTEKI KAYNAKLAR (637): kurum, dis hekim, personel…
          Her yeni kaynak icin ayri bir dal yazmak, ucuncusunde kopyala-
          yapistir olurdu; `TarafArama` zaten kaynak adini aliyor. Kaynak
          adi VIRGULLU olabilir - lab isteminde "İsteyen Hekim" hem dis
          doktoru hem ic personeli arar (`dis-hekim,personel`): karttan
          acilan istem genelde dis numunedir ama ic istem de girilebiliyor.
          Yukaridaki hasta/cari dallari KENDI kurallarini tasidiklari icin
          (aday karti, pasif/vefat suzgeci) burada tekrarlanmaz. */}
      {aramaAlani && TARAF_ARAMA_KAYNAKLARI.some(
          k => aramaAlani.kaynak.split(',').includes(k)) && (
        <TarafArama
          acik
          kaynaklar={aramaAlani.kaynak.split(',').map(x => x.trim()).filter(Boolean)}
          yerTutucu="Ara…"
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

      {/* LISTE DUZENLE (544): kart alaninin etiketinden acilan jenerik
          kod listesi penceresi. Kapaninca kart metasi tazelenir - yeni
          eklenen deger combo'da hemen gorunsun. */}
      {listeDuzenlenen && (
        <KodListesiModali
          kod={listeDuzenlenen.kod}
          baslik={listeDuzenlenen.baslik}
          ustDeger={listeDuzenlenen.ustDeger}
          onKapat={() => {
            const kod = listeDuzenlenen.kod;
            setListeDuzenlenen(null);
            // YALNIZ O LISTENIN SECENEKLERI tazelenir; kartin tamamini
            //   yeniden yuklemek kaydedilmemis degisiklikleri silerdi.
            void listeSecenekleriTazele(kod);
          }} />
      )}

      {/* KATKI PENCERESI (541): oran x fiyat = hastadan alinacak katki.
          Oran CARPAN olarak okunur (0,80 -> fiyatin %80'i) - 518'deki
          `fn_fiyat_katki_uret` ile ayni dil, iki yerde iki anlam olmasin. */}
      {topluKatki && (
        <Modal baslik={`Katkı — ${seciliSatirlar.size} satır`} dar enUst ekSinif="mesaj-pencere toplu-pencere" buyutmeYok
               onKapat={() => setTopluKatki(false)}
               alt={topluButonlar(
                 Number.isFinite(Number(topluKatkiOran.replace(',', '.')))
                 && topluKatkiOran.trim() !== '',
                 kapsam => {
                   const oran = Number(topluKatkiOran.replace(',', '.'));
                   void topluUygula('katki', oran, kapsam)
                     .then(oldu => { if (oldu) setTopluKatki(false) });
                 },
                 () => setTopluKatki(false))}>
          <div className="toplu-kutu">
            <label className="alan tip-para">
              <span className="etiket">Fiyatın Oranını Girin</span>
              <input autoFocus inputMode="decimal" value={topluKatkiOran}
                     onChange={e => setTopluKatkiOran(e.target.value)} />
            </label>
            <div className="ic sonuk">
              Hasta katkısı = fiyat × oran. Örnek: <b>0,80</b> girilirse
              fiyatın %80'i katkı olarak yazılır.
            </div>
          </div>
        </Modal>
      )}

      {/* FIYAT GUNCELLE PENCERESI (kullanici): yon (artir/azalt) + yuzde.
          Fiyat = fiyat x (1 ± yuzde/100), kurusa yuvarlanir. Katki/carpan
          ELLENMEZ: Ozel tarifede katki kullanilmiyor, carpan ise TTB'nin. */}
      {fiyatGuncelle && (() => {
        const yuzde = Number(fiyatYuzde.replace(',', '.'));
        const gecerli = fiyatYuzde.trim() !== '' && Number.isFinite(yuzde) && yuzde > 0;
        return (
        <Modal baslik={`Fiyat Güncelle — ${seciliSatirlar.size} satır`} dar enUst
               ekSinif="mesaj-pencere toplu-pencere" buyutmeYok
               onKapat={() => setFiyatGuncelle(false)}
               alt={topluButonlar(gecerli, kapsam => {
                 void topluUygula('fiyat-yuzde', yuzde, kapsam, fiyatYonu)
                   .then(oldu => { if (oldu) setFiyatGuncelle(false) });
               }, () => setFiyatGuncelle(false))}>
          <div className="toplu-kutu">
            <label className="alan">
              <span className="etiket">İşlem</span>
              <select value={fiyatYonu}
                      onChange={e => setFiyatYonu(e.target.value as 'artir' | 'azalt')}>
                <option value="artir">Artır</option>
                <option value="azalt">Azalt</option>
              </select>
            </label>
            <label className="alan tip-para">
              <span className="etiket">% giriniz</span>
              <input autoFocus inputMode="decimal" value={fiyatYuzde}
                     onChange={e => setFiyatYuzde(e.target.value)} />
            </label>
            <div className="ic sonuk">
              Yeni fiyat = fiyat {fiyatYonu === 'azalt' ? '−' : '+'} %{fiyatYuzde || '…'}.
              Örnek: 100,00 fiyat <b>10</b> ile{' '}
              <b>{fiyatYonu === 'azalt' ? '90,00' : '110,00'}</b> olur.
              Kuruşa yuvarlanır; kaydedene kadar sunucuya yazılmaz.
            </div>
          </div>
        </Modal>
        );
      })()}

      {/* TOPLU CARPAN PENCERESI (534): tek sayi, secilen kapsamdaki
          satirlara yazilir; fiyat = katsayi x carpan olarak SUNUCUDA
          yeniden dogar (uc de ayni kurali isletir). */}
      {topluCarpan && (
        <Modal baslik={`Çarpan — ${seciliSatirlar.size} satır`} dar enUst ekSinif="mesaj-pencere toplu-pencere" buyutmeYok
               onKapat={() => setTopluCarpan(false)}
               alt={topluButonlar(
                 Number.isFinite(Number(topluCarpanDeger.replace(',', '.')))
                 && topluCarpanDeger.trim() !== '',
                 kapsam => {
                   const sayi = Number(topluCarpanDeger.replace(',', '.'));
                   void topluUygula('carpan', sayi, kapsam)
                     .then(oldu => { if (oldu) setTopluCarpan(false) });
                 },
                 () => setTopluCarpan(false))}>
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
