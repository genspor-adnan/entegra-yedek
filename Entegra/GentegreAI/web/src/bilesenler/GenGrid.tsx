import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { c as cev } from '../dil/ceviri';
import { mesaj } from './mesaj';
import { ayarSayi } from '../api/ayarlar';
import { type AksiyonYaniti, type Kosul, type ListeSatiri } from '../api/sozlesme';
import { bicimle } from './bicim';
import { GenKomutPaleti, GenSagTus, GenToolbar, hedefte, useAksiyonlar,
         type AltSecenek } from './Aksiyonlar';
import { Modal } from './Modal';
import { LogTablosu, GORUNUMLER } from './gridHucre';
import { GridTablo } from './grid/GridTablo';
import { agacDiz } from './grid/agacDizim';
import { TARIH_ON_AYARLAR, tarihAraligi, type TarihOnAyar }
  from '../sayfalar/liste/tarihAralik';
import {
  filtreSatiriKosulu, } from './gridSorgu';
import { GridMenu, gridMenuOgeleri } from './grid/GridMenu';
import { useGridTercihleri } from './grid/useGridTercihleri';
import { useTarihAraligi } from './grid/useTarihAraligi';
import { useGridSecimi } from './grid/useGridSecimi';
import { useListeVerisi } from './grid/useListeVerisi';
import { useKolonTercihi } from './grid/kolonTercihi';

interface Props {
  /** Liste kaynagi: 'cari', 'belge', 'stok' ... */
  kaynak: string;
  baslik?: string;
  /** Ust satirdaki kirilma yolu: "Cari › Musteriler" */
  yol?: string;
  sabitFiltre?: Kosul;
  /** Toplami istenen kolon adlari (sunucu hesaplar). */
  toplam?: string[];
  boyut?: number;
  onSatirAc?(satir: ListeSatiri): void;
  /** Aksiyon katalogu ekrani ("cari-liste"); verilirse arac cubugu + sag tus + palet gelir. */
  aksiyonEkrani?: string;
  /**
   * AGAC KIPI (kullanici: "+ gibi alt dallar acilir yap"). Deger, ust kaydi
   * gosteren ALAN ADI ("ustbirimId"). Verilirse satirlar agac sirasinda
   * dizilir, cocugu olan satirda +/- dugmesi cikar ve kapali dalin altlari
   * gizlenir. Sunucu tarafi degismez - agac yalniz GORUNUM.
   */
  agacAlani?: string;
  /** e-Belge menusu kutusunun BASLIGI ("E-Fatura" / "E-İrsaliye"); verilmezse
      kutu cizilmez (yalniz satis faturasi ve satis irsaliyesi listeleri). */
  ebelgeMenusu?: string;
  onAksiyon?(kod: string, satir: ListeSatiri | null, secililer?: ListeSatiri[]): void;
  /** Ust cip filtreleri: { ad, filtre } — mockup'taki "Aktif / Pasif / Tumu" seridi. */
  /** `rota` verilen cip FILTRE degil GECIS'tir: tiklaninca o listeye gidilir
      (Alis Faturalari > "Gelen Kutusu"). Ayni serit, farkli kaynak. */
  /** `kosul: 'ebelge'` verilen cip YALNIZ e-Fatura mukellefinde cizilir
      (sunucu e-Belge aksiyonu donduruyorsa). */
  cipler?: { ad: string; filtre?: Kosul; rota?: string; kosul?: 'ebelge' }[];
  /** Kart icine gomulu kucuk grid (ör. cari kartinda İlgili Kişiler) - buyuk baslik/yol
      satiri (.sayfabas) gizlenir, geri kalan (arama/cipler/tablo/sayfalama) ayni kalir. */
  gomulu?: boolean;
  /** Verilirse cip seridine TARIH ARALIGI kutulari gelir; bu alan uzerinden
      'arasinda' filtresi kurulur (ör. ekstrede 'islemTarihi'). */
  tarihAlani?: string;
  /** Acilista dolu gelen tarih araligi (ör. ekstre: 1 Ocak - bugun). */
  tarihVarsayilan?: 'yilbasindanBugune' | 'buAy';
  /**
   * TARIH ARALIGI YERINE HAZIR COMBO (kullanici: "istemler listesi tarih
   * araligi yerine basvurudaki bugun/dun gibi tarih filtre combosu
   * gelsin"). Iki tarih kutusu doldurmak, gunluk calisilan ekranda her
   * seferinde dort tiklama demekti; combo tek tiklama.
   * Ayni on ayarlar basvuru seridindekiler (`tarihAralik.ts`).
   */
  tarihCombo?: boolean;
  /** Combo kipinin acilis secimi ('' = tum tarihler). */
  tarihComboVarsayilan?: TarihOnAyar | '';
  /** Tarih araligi degisince haber verir: serit suzgecleri (hakedis satirlari
      Prim Rolu / Kisi) seceneklerini ARALIGA gore yeniler. */
  onTarihAraligi?: (bas: string, bit: string) => void;
  /** Acilista secili gelecek satirin id'si (ör. ekstreden listeye donunce
      ayni hesap yine secili kalsin). */
  seciliBaslangicId?: number | null;
  /** Cip seridinin SONUNA eklenecek dugmeler (ör. "│ 📄 Ekstre"). */
  cipSonu?: React.ReactNode;
  /**
   * KOD KOLONUNA GORE SUZEN COMBO (492): ciplerin sagina cizilir, secim
   * sunucuya filtre olarak gider. Secenekler kolonun KENDI meta sozlugunden
   * (`kodlar`) gelir - istemci ikinci bir etiket listesi tutmaz.
   */
  kodSuzgeci?: { alan: string; etiket: string };
  /**
   * Kod suzgecinin DISARIDAN yonetilen degeri (492). Tetkik katalogunda ayni
   * secimi hem ustteki combo hem soldaki bolum agaci yapiyor; iki ayri durum
   * tutulsaydi biri "Hematoloji" digeri "Tümü" derken liste ikisinin
   * kesisimini gosterirdi.
   */
  kodSuzgecDeger?: string;
  onKodSuzgec?(deger: string): void;
  /**
   * Gridin SOLUNA cizilecek gezinme paneli (492: tetkik katalogunda bolum
   * agaci ve paneller). Yan panelle birlikte mockup'in uc kolonlu duzenini
   * (.ucPanel) verir.
   */
  solPanel?: React.ReactNode;
  /** Bos listede gosterilecek ek aciklama/dugme (ör. "Tüm tarihleri göster"). */
  bosEk?: React.ReactNode;
  /**
   * Acilista uygulanan gruplama kolonu (492: Tetkik Kataloğu bölüme göre).
   * Kullanici uc-nokta menusunden degistirebilir; bu yalnizca BASLANGIC.
   */
  varsayilanGrup?: string;
  /**
   * Gridin ALTINA, ayni kaydirma alaninin (.sahne) icine eklenecek panel -
   * randevu takvimi gibi. GenGrid'in DISINA kardes olarak konursa `.sahne`
   * flex:1 oldugu icin sifira kadar eziliyor, cip seridi ve grid kirpiliyordu
   * (kullanici: "tüm/sık/son ile başlayan butonlar kırpılmış").
   */
  altPanel?: React.ReactNode;
  /**
   * Gridin SAGINA, tam yuksekligi boyunca cizilecek panel - laboratuvar
   * istem ekraninin hasta karti gibi (mockup .ucPanel: solda tablo, sagda
   * hasta/etiket kutulari). Grid ve alt panel sol kolonda kalir; yan panel
   * yapiskan (sticky) durur, liste kaydirilirken hasta bilgisi kaybolmaz.
   * Dar ekranda tek kolona iner.
   */
  yanPanel?: React.ReactNode;
  /**
   * Ciplerin ALTINA, gridin USTUNE eklenecek serit - lab sonuc onay
   * ekraninin sayac seridi gibi (mockup'ta da tam bu sirada: arama seridi,
   * ozet kutulari, tablo).
   */
  ustPanel?: React.ReactNode;
  /**
   * Arama seridine (Liste/Grup/Analiz'in yanina) EK GORUNUM dugmesi: secilince
   * grid yerine `icerik` cizilir - randevu takvimi boyle acilir (kullanici:
   * "arama editi sagina takvim butonu, basinca takvim listeye bassin").
   */
  ekGorunum?: { ad: string; ik: string; icerik: React.ReactNode };
  /** Acilista secili gelecek cip (geri donuste onceki filtreyi korumak icin). */
  cipBaslangic?: number;
  /** Cip'e tiklanınca cagrilir - ekstre modundan listeye donmek gibi ekran
      disi davranislar icin (grid kendi filtresini yine uygular). */
  onCipSecildi?(indeks: number): void;
  /** Rotali cip (kaynak degistiren sekme) tiklandi. */
  onCipRota?(rota: string): void;
  /** Satir secimi degisince cagrilir - disaridaki dugmeler (Ekstre gibi) buna gore
      aktif/pasif olur. */
  onSecimDegisti?(satir: ListeSatiri | null): void;
  /** Arac cubugu dugmesine acilir alt menu (ör. "＋ Tahsilat" -> Nakit/Banka/...). */
  altSecenekler?: Record<string, AltSecenek[]>;
  /** Bu EKRANDA gizlenecek kolon adlari (katalogda varsayilan gelse bile).
      Ayni kaynak farkli ekranlarda kullaniliyor: Satis Faturalari'nda tur/turAdi
      gereksiz (hepsi ayni tur), Siparisler'de gerekli. */
  gizliKolonlar?: string[];
  /** Ekrana ozel kolon basligi (bkz. useKolonTercihi). */
  kolonBasliklari?: Record<string, string>;
  /** Bu ekranda ONE alinacak kolonlar (soldan saga). Verilmeyenler katalog
      sirasinda arkada kalir - kolon sirasi kaynak tanimina bagli olmasin. */
  kolonSirasi?: string[];
  /** Arama + Liste/Grup/Analiz + toplu aksiyon seridini hic cizme (ör. Stok Ayarlari >
      Depolar): birkac satirlik ayar listesinde bu serit bilgi degil gurultu. */
  seritGizli?: boolean;
  /** ☰/🕓/⭐ (Tum/Son/Sik) gorunum ikonlarini gizle (ör. ÜTS listeleri -
      kart acma aliskanligi olmayan ekranlarda anlamsizlar). */
  aramaGorunumGizli?: boolean;
  /** Liste / Grup / Analiz gorunum cipleri cizilmesin (kullanici): Grup ve
      Analiz backend'de yok - birkac satirlik ayar listesinde "yakinda" yer
      tutucu gostermek gurultu. */
  gorunumSecimGizli?: boolean;
  /** Seritteki hizli ARAMA kutusu cizilmesin (kullanici): birkac satirlik
      ayar listesinde arama kutusu yer kapliyor, cipler zaten yetiyor.
      `seritGizli`den farki: cipler ve toplu aksiyon serit olarak KALIR. */
  aramaGizli?: boolean;
  /** Gomulu gridin arac cubugu saga degil SOLA yaslanir (gridin sol ust kosesi). */
  aracCubuguSol?: boolean;
  /** Arac cubugu AYRI SATIR degil, cip seridinin SAGINDA cizilir (kullanici:
      "Yeni/Duzenle dugmeleri Tumu/Aktif cipleri hizasinda olsun"). Az satirli
      ayar listelerinde iki ayri serit bosuna yer kapliyordu. */
  aracCubuguSeritte?: boolean;
  /**
   * DOVIZSIZ EKRANDA GIZLENECEK kolonlar (ekstreler): yuklenen satirlarin
   * hicbirinde doviz hareketi yoksa (kur her satirda 1) bu kolonlar cizilmez -
   * "Borç" ile "Yerel Borç" ayni sayiyi iki kez gosteriyordu.
   */
  dovizsizGizle?: string[];
  /** Degisince (kart kaydedilince - ekleme ya da duzenleme) grid yeniden yuklenir. */
  yenile?: number;
  /** Degisince (yeni kart EKLENINCE) gorunum "Son Aranan"a gecer - yeni kayit sunucu
      sirasinda (son_tarih desc) zaten ilk sirada oldugu icin liste otomatik onu gosterir. */
  odaklaSonEklenen?: number;
  /** Verilirse (ör. islem-log'da "bilgi") satirin bu alani "Icerik" penceresinde
      gosterilebilir: ust cubukta secili satir icin "İçerik" dugmesi + satira cift-tik. */
  icerikAlani?: string;
  /** Icerik penceresinin basligi. */
  icerikBaslik?: string;
}

/**
 * Liste ekrani — ana mockup (gentegre_v4_web.html) duzeni:
 *   sayfa basligi + kirilma yolu + aksiyon dugmeleri
 *   cip filtreleri + hizli arama
 *   kutu icinde grid + alt bilgi seridi
 *
 * Kolonlar SUNUCUDAN gelir (/kolonlar): yetkisiz kolon listede hic donmedigi icin
 * arayuzde gizleme mantigi YOKTUR. Filtre, siralama ve sayfalama da sunucuda calisir.
 */
export function GenGrid({ kaynak, baslik, yol, sabitFiltre, toplam, boyut, onSatirAc,
                          aksiyonEkrani, ebelgeMenusu, onAksiyon, cipler, gomulu, seritGizli, aracCubuguSol,
                          dovizsizGizle,
                          gizliKolonlar, kolonBasliklari, kolonSirasi, altSecenekler,
                          tarihAlani, tarihVarsayilan, tarihCombo, tarihComboVarsayilan,
                          onTarihAraligi,
                          aramaGorunumGizli, gorunumSecimGizli, aramaGizli,
                          aracCubuguSeritte,
                          seciliBaslangicId, cipSonu, kodSuzgeci, kodSuzgecDeger: kodDisDeger,
                          onKodSuzgec, varsayilanGrup, solPanel, bosEk,
                          cipBaslangic, altPanel, ustPanel, yanPanel, ekGorunum,
                          onCipSecildi, onCipRota, onSecimDegisti, yenile, odaklaSonEklenen,
                          icerikAlani, icerikBaslik, agacAlani }: Props) {
  // Sayfa boyu: cagiran acikca verdiyse o, yoksa Genel Ayarlar'daki
  //   `liste.sayfa_boyu` (varsayilan 50). Ayar gelene kadar 50 ile calisir.
  const [ayarBoyut, setAyarBoyut] = useState(50);
  const sayfaBoyu = boyut ?? ayarBoyut;
  useEffect(() => { void ayarSayi('liste.sayfa_boyu', 50).then(setAyarBoyut) }, []);


  /**
   * KULLANICI GRUPLAMASI (uc nokta > Gruplama). Sunucudan gelen `grupKolonu`
   * kaynagin KENDI gruplamasidir (ör. ekstrede para birimi); kullanici secince
   * onun yerine bu gecer. Gruplanan kolon ayni zamanda ILK SIRALAMA olur -
   * yoksa ayni grubun satirlari listeye dagilir ve baslik defalarca cizilir.
   */
  const [kullaniciGrup, setKullaniciGrup] = useState<string | null>(varsayilanGrup ?? null);
  /** Kod suzgeci combosunun secimi ('' = tumu). Disaridan verilmisse o gecer. */
  const [kodIcDeger, setKodIcDeger] = useState('');
  const kodSuzgecDeger = kodDisDeger ?? kodIcDeger;
  const setKodSuzgecDeger = (v: string) => (onKodSuzgec ? onKodSuzgec(v) : setKodIcDeger(v));
  // Tarayicida saklanan tercihler (satir yuksekligi + yan panel) kendi
  //   kancasinda: grid/useGridTercihleri.
  const { satirBoyu, satirBoyuSec, yanKapali, setYanKapali } =
    useGridTercihleri(kaynak, !!solPanel);
  const [cipIndeks, setCipIndeks] = useState(cipBaslangic ?? 0);
  /**
   * DISARIDAN GELEN CIP degisince ic state de gecmeli.
   *
   * `useState` baslatici yalniz ILK render'da calisir; cagiran (Liste) SPA
   * ici gecişte cipi degistirdiginde grid eski cipte kaliyordu. Somut vaka:
   * Hakedişler > "Satırları Gör" -> /hakedis-satir?hakedisId=4 - URL filtresi
   * kayit kumesini zaten daraltmisken ustune "Kesin" cipi biniyor ve
   * kapatilmis hakedisin ONAYLI satirlari icin grid "Kayıt yok" gosteriyordu.
   */
  useEffect(() => {
    if (cipBaslangic !== undefined) setCipIndeks(cipBaslangic);
  }, [cipBaslangic]);
  /** Tarih araligi (bos = sinir yok). Tek uc verilmesi de gecerli.
      'yilbasindanBugune': 1 Ocak - bugun. Ust sinir SUNUCUDA gun sonuna kadar
      kapsanir (SorguUretici 'arasinda' + 1 gun), yani bugun 23:59'daki hareket
      de listeye girer. */
  // Tarih araligi (hazir secenek + disari bildirim) kendi kancasinda.
  /** Combo kipinde secili on ayar; aralik kutulari bundan turetilir. */
  const [tarihOn, setTarihOn] = useState<TarihOnAyar | ''>(
    tarihCombo ? (tarihComboVarsayilan ?? 'bugun') : '');
  /* Combo kipinin ACILIS araligi: state baslangicinda kurulamaz - aralik
     `useTarihAraligi` icinde yasiyor. Bir kez uygulanir. */
  const tarihIlkKurulum = useRef(false);
  const { bas: tarihBas, setBas: setTarihBas,
          bit: tarihBit, setBit: setTarihBit } =
    useTarihAraligi(tarihVarsayilan, onTarihAraligi);

  useEffect(() => {
    if (!tarihCombo || tarihIlkKurulum.current || tarihOn === '') return;
    tarihIlkKurulum.current = true;
    const a = tarihAraligi(tarihOn);
    setTarihBas(a.bas); setTarihBit(a.bit);
  }, [tarihCombo, tarihOn, setTarihBas, setTarihBit]);
  // Mockup: Liste/Grup/Analiz gorunum secimi. Grup/Analiz backend'de HENUZ YOK -
  //   grid yerine "yakinda" yer tutucu gosterilir (aksiyon stub'lariyla ayni durustluk).
  const [gorunum, setGorunum] = useState<'liste' | 'grup' | 'analiz' | 'ek'>('liste');
  // Kolon gorunurlugu/sirasi ve tercihin saklanmasi grid/kolonTercihi.ts'te.
  //   Kolon tercihi hatasi AYRI durumda: liste verisi kancasi kolonlara
  //   ihtiyac duyuyor, kolon kancasi da hata yazacak bir yer istiyor - ikisi
  //   ayni state'i paylasirsa dairesel bagimlilik olurdu. Ekranda ikisi de
  //   ayni kutuda gosterilir.
  const [kolonHatasi, setKolonHatasi] = useState<string | null>(null);
  const { kolonlar, tumKolonlar, kolonTasi, kolonDegistir, kolonlariSifirla } =
    useKolonTercihi({ kaynak, gizliKolonlar, kolonBasliklari, kolonSirasi,
                      setHata: setKolonHatasi });

  const [filtreAcik, setFiltreAcik] = useState(false);
  const [filtreDeger, setFiltreDeger] = useState<Record<string, string>>({});
  const filtreZamanlayici = useRef<number | undefined>(undefined);
  const [gridMenuKonum, setGridMenuKonum] = useState<{ x: number; y: number } | null>(null);

  // Kosul kurma SAF fonksiyonlarda (gridSorgu): listeleme ve disa aktarma ayni
  //   mantigi kullansin diye tek yerde.
  const filtreSatiriFiltresi = useCallback(
    () => filtreSatiriKosulu(filtreDeger, kolonlar), [filtreDeger, kolonlar]);

  // LISTE VERISI (yukleme · sayfalama · siralama · arama · CSV) kendi
  //   kancasinda: grid/useListeVerisi.
  const { satirlar, toplamKayit, toplamlar, gruplar, grupKolonu,
          sayfa, setSayfa, sirala, setSirala, siralamaDegistir, siraIsareti,
          arama, setArama, aramaDegisti, aramaGorunumu, setAramaGorunumu,
          yukleniyor, hata, sureMs,
          yukle, csvIndir, sonSayfa } =
    useListeVerisi({
      kaynak, baslik, kolonlar, sabitFiltre, toplam, sayfaBoyu, cipler, cipIndeks,
      kodSuzgeci, kodSuzgecDeger, tarihAlani, tarihBas, tarihBit, varsayilanGrup,
      yenile, odaklaSonEklenen, filtreSatiriFiltresi,
    });

  /**
   * AGAC KIPI DURUMU (kullanici: "+ gibi alt dallar acilir yap").
   *
   * Kapali dugumler EKRANDA tutulur - sunucuya gitmez ve sayfa degisince
   * sifirlanmaz; kullanici bir dali kapattiysa listede gezinirken kapali
   * kalmali. Varsayilan ACIK: liste ilk acilista tam gorunsun, kullanici
   * daraltmak isterse kendisi kapatsin.
   */
  const [kapaliDallar, setKapaliDallar] = useState<ReadonlySet<string>>(new Set());
  const agacDegistir = useCallback((id: string) => {
    setKapaliDallar(k => {
      const y = new Set(k);
      if (!y.delete(id)) y.add(id);
      return y;
    });
  }, []);
  const agacSatirlari = useMemo(
    () => (agacAlani ? agacDiz(satirlar, agacAlani, kapaliDallar) : satirlar),
    [agacAlani, satirlar, kapaliDallar]);

  /**
   * Ekranda doviz hareketi var mi (kur 1'den farkli tek satir yeter). Yoksa
   * `dovizsizGizle` kolonlari cizilmez - yerel karsilik kolonu, ana tutarin
   * birebir kopyasi olurdu.
   */
  const dovizVarMi = useMemo(
    () => satirlar.some(s => Number(s.dovizKuru ?? 1) !== 1),
    [satirlar]);
  const [sagTusKonumu, setSagTusKonumu] = useState<{ x: number; y: number } | null>(null);
  // "İçerik" penceresi (ör. islem-log > bilgi JSON'u) - satira cift-tik ya da ust
  //   cubuktaki "İçerik" dugmesi ayni pencereyi acar.
  const [icerikAcikSatir, setIcerikAcikSatir] = useState<ListeSatiri | null>(null);
  const satirTiklaninca = (satir: ListeSatiri) => {
    if (icerikAlani) setIcerikAcikSatir(satir);
    else onSatirAc?.(satir);
  };

  // Ilk sutun: onay kutusu (coklu secim, su an icin sadece yuklu sayfa) + "3 nokta" grid menusu.
  // SATIR SECIMI (onay kutulari · tek satir hedefi · Ctrl/Shift kurallari)
  //   kendi kancasinda: grid/useGridSecimi.
  const { secili, secimiUygula, seciliSatir, setSeciliSatir,
          satirSecimiDegistir, satirTiklandi, sayfaIdleri,
          hepsiSecili, hepsiRef } =
    useGridSecimi({ satirlar, kaynak, sayfa, seciliBaslangicId, onSecimDegisti });

  // Aksiyonlar secili kayda gore yeniden cozulur: "belge zaten gonderilmis" gibi
  //   kosullar sunucuda degerlendirilir, istemci kural yazmaz.
  const { aksiyonlar } = useAksiyonlar(
    aksiyonEkrani ?? 'cari-liste',
    seciliSatir?.id != null ? Number(seciliSatir.id) : null);

  const aksiyonCalistir = (kod: string) => {
    // CSV disariya CIKMAZ: veri (satirlar, kolonlar, filtre) burada, disarida degil.
    if (kod === 'genel.csv') { void csvIndir(); return }
    // Secili ID listesi de gider: bir aksiyon (or. e-Belge hazirla/gonder)
    //   coklu secimde TOPLU calisabilsin. Tek secimde liste tek elemanlidir.
    onAksiyon?.(kod === 'genel.yazdir.dogrudan' ? 'genel.yazdir' : kod, seciliSatir,
                satirlar.filter((sr, i) => secili.has(String(sr.id ?? i))));
  };

  /** "🖨️ Yazdır" dugmesi acilir menu: CSV Kaydet + Yazdir. Disaridan gelen
      alt menuler (ör. kasa tahsilat araclari) korunur. */
  const toolbarAltSecenekler = useMemo(() => ({
    ...(altSecenekler ?? {}),
    'genel.yazdir': [
      { kod: 'genel.csv', ad: '📄 CSV Kaydet' },
      { kod: 'genel.yazdir.dogrudan', ad: '🖨️ Yazdır' },
    ],
  }), [altSecenekler]);

  // GENEL aksiyonlar ile e-BELGE menusu AYRI kutularda (kullanici): e-Belge'nin
  //   dokuz adimi genel listeye karisinca "Aç / Yeni / Sil" arasinda kayboluyordu.
  //   e-Belge kutusu, sunucu bu aksiyonlari donduruyorsa cizilir - donmesi
  //   subenin e-Fatura mukellefiyetine bagli (179).
  // AYRI KUTU YALNIZ SATIS FATURA LISTESINDE (kullanici): e-Belge menusunun
  //   dokuz adimi orada anlamli. Ekran ADI yetmez - 'belge-liste' satis fisi,
  //   tahakkuk ve alis faturasi listelerinde de kullaniliyor; karari liste
  //   tanimi verir. Diger ekranlarda (or. irsaliye listesindeki tek
  //   "e-İrsaliye Gönder") aksiyon genel kutuda kalir.
  const ebelgeKutusuVar = !!ebelgeMenusu;
  const ebelgeGrubu = (a: AksiyonYaniti) => a.grup === 'ebelge';
  // e-BELGE KOMUTLARI GENEL KUTUDA HIC GORUNMEZ (kullanici): kendi "E-Fatura"
  //   kutusuna aitler; genel listede "Aç / Yeni / Sil" arasina karisinca hem
  //   uzuyor hem hangi komutun hangi akisa ait oldugu kayboluyordu. Sag tus
  //   menusu ve komut paleti onlari GOSTERMEYE devam eder - oralarda gruplu.
  // Kutu yalniz satis fatura listesinde cizilir (liste tanimindaki bayrak).
  const ebelgeKombo = useMemo(
    () => (ebelgeKutusuVar ? aksiyonlar.filter(a => hedefte(a, 'sagtus') && ebelgeGrubu(a)) : []),
    [aksiyonlar, ebelgeKutusuVar]);
  /** Sube e-Fatura mukellefi mi: sunucu e-Belge aksiyonu donduruyorsa evet
      (AksiyonUclari mukellef olmayan subede bu grubu HIC gondermez). Kutu
      bayragindan BAGIMSIZ - Alis Faturalari'nda kutu yok ama "Gelen Kutusu"
      sekmesi mukellefiyete bagli. */
  const ebelgeMukellef = useMemo(
    () => aksiyonlar.some(a => ebelgeGrubu(a) || a.grup === 'gelen'), [aksiyonlar]);
  const [ebelgeSecim, setEbelgeSecim] = useState('');

  const filtreSatiriDegisti = (alan: string, deger: string) => {
    window.clearTimeout(filtreZamanlayici.current);
    filtreZamanlayici.current = window.setTimeout(() => {
      setSayfa(1);
      setFiltreDeger(f => ({ ...f, [alan]: deger }));
    }, 350);
  };

  const satirSinifi = (satir: ListeSatiri) => {
    const islemRengi = kaynak === 'islem-log'
      ? String(satir.islemTipi ?? '').toLocaleLowerCase('tr-TR').includes('ekle') ? 'satir-log-ekle'
        : String(satir.islemTipi ?? '').toLocaleLowerCase('tr-TR').includes('değiş') ? 'satir-log-degisiklik'
        : String(satir.islemTipi ?? '').toLocaleLowerCase('tr-TR').includes('sil') ? 'satir-log-sil'
        : ''
      : '';
    const renk = satir.satirRengi === 'kritik' ? 'satir-kritik'
      : satir.satirRengi === 'uyari' ? 'satir-uyari'
      : satir.satirRengi === 'pasif' ? 'satir-pasif' : '';
    return `${renk} ${islemRengi} ${seciliSatir?.id === satir.id ? 'secili' : ''}`.trim();
  };

  /**
   * AKTIF gridi CSV olarak indirir: ekranda hangi kaynak/filtre/kolonlar varsa
   * onlar. Sunucu sayfa boyutunu 500'le siniladigi icin sayfa sayfa cekilir
   * (ust sinir 10.000 satir - daha buyugu tarayicida donma demek).
   */
  const gorunenToplamlar = useMemo(() => Object.entries(toplamlar ?? {}), [toplamlar]);
  // Alt toplam seridi yalniz GORUNEN bir kolonun toplami varsa cizilir. Gruplu
  //   ekstrede para birimine bagli kolonlar genel toplama girmez; o kolonlardan
  //   baskasi gorunmuyorsa serit bos "GENEL TOPLAM" satiri olarak kalirdi.
  const toplamSeridiVar = useMemo(
    () => gorunenToplamlar.some(([ad]) => kolonlar.some(k => k.ad === ad)),
    [gorunenToplamlar, kolonlar]);

  const filtreVar = arama.trim() !== '' || Object.values(filtreDeger).some(v => v.trim() !== '');

  /**
   * UC NOKTA MENUSU - gridle ilgili NE varsa burada (kullanici istegi).
   * Ogeler ve cizim grid/GridMenu.tsx'te; burasi yalniz gridin durumunu ve
   * eylemlerini verir.
   */
  const menuOgeleri = gridMenuOgeleri({
    kolonlar, tumKolonlar,
    satirSayisi: satirlar.length, seciliSayisi: secili.size,
    sirala, filtreAcik, filtreVar, sayfaBoyu, boyutSabit: !!boyut,
    kullaniciGrup, satirBoyu,
    yukle: () => { void yukle() },
    csvIndir: () => { void csvIndir() },
    // Filtre satiri kapatilinca girilen degerler de silinir.
    setFiltreAcik: f => setFiltreAcik(acikMi => {
      const yeniDurum = f(acikMi);
      if (!yeniDurum) { setFiltreDeger({}); setSayfa(1) }
      return yeniDurum;
    }),
    filtreleriTemizle: () => { setArama(''); setFiltreDeger({}); setSayfa(1) },
    siralamayiTemizle: () => { setSirala([]); setSayfa(1) },
    tumunuSec: () => secimiUygula(new Set(sayfaIdleri())),
    secimiTemizle: () => secimiUygula(new Set()),
    secimiTersineCevir: () => {
      const yeni = new Set(secili);
      sayfaIdleri().forEach(id => { yeni.has(id) ? yeni.delete(id) : yeni.add(id) });
      secimiUygula(yeni);
    },
    sayfaBoyuSec: n => { setAyarBoyut(n); setSayfa(1) },
    gruplaSec: ad => {
      setKullaniciGrup(ad);
      setSirala(ad ? [{ alan: ad, yon: 'asc' as const }] : []);
      setSayfa(1);
    },
    satirBoyuSec,
    kolonDegistir, kolonTasi,
    kolonlariSifirla: () => { kolonlariSifirla(); setKullaniciGrup(null) },
  });

  return (
    <>
      {!gomulu && (
        <div className="sayfabas">
          <div className="basrow">
            <h1>{baslik ?? kaynak}</h1>
            {yol && <span className="yol">{yol}</span>}
            <div className="sag">
              {aksiyonEkrani && <GenToolbar aksiyonlar={aksiyonlar} calistir={aksiyonCalistir} altSecenekler={toolbarAltSecenekler} />}
            </div>
          </div>
        </div>
      )}
      {gomulu && aksiyonEkrani && !aracCubuguSeritte && (
        <div style={aracCubuguSol
          // Sola yaslidayken sekme cubuguna yapismasin: biraz asagi ve iceri.
          ? { display: 'flex', justifyContent: 'flex-start',
              marginTop: 10, marginLeft: 14, marginBottom: 8 }
          : { display: 'flex', justifyContent: 'flex-end', marginBottom: 6 }}>
          <GenToolbar aksiyonlar={aksiyonlar} calistir={aksiyonCalistir} altSecenekler={toolbarAltSecenekler} />
        </div>
      )}

      {!seritGizli && (
      <div className="cipler">
        {!aramaGizli && (
        <div className="ara-kutu dar">
          <span>🔍</span>
          <input type="search"
            placeholder={cev('Bu listede ara…')}
            onChange={e => aramaDegisti(e.target.value)}
          />
        </div>
        )}

        {ekGorunum && (
          <button className={`cip ${gorunum === 'ek' ? 'on' : ''}`}
                  onClick={() => setGorunum(gorunum === 'ek' ? 'liste' : 'ek')}>
            {ekGorunum.ik} {ekGorunum.ad}
          </button>
        )}
        {!gorunumSecimGizli && GORUNUMLER.map(g => (
          <button
            key={g.v}
            className={`cip ${gorunum === g.v ? 'on' : ''}`}
            onClick={() => setGorunum(g.v)}
          >
            {g.ik} {cev(g.ad)}
          </button>
        ))}

        {/* ARAC CUBUGU cip seridinin dogrudan cocugu (kullanici: "Tümü/Aktif
            cipleriyle ayni hizada, saga yanasik"). Ayri bir sarmalayici span
            icinde dururken iki ic ice flex + iki `margin-left:auto` cakisip
            dugmeleri kaydiriyordu. */}
        {aracCubuguSeritte && aksiyonEkrani && (
          <GenToolbar aksiyonlar={aksiyonlar} calistir={aksiyonCalistir}
                      altSecenekler={toolbarAltSecenekler} />
        )}

        {/* Sag blok YALNIZ icerigi varken cizilir: bos bir `margin-left:auto`
            span, arac cubuguyla bosluğu paylasip onu tam saga yanasmaktan
            alikoyuyordu. */}
        {/* AKSIYON SEC + UYGULA KUTUSU KALDIRILDI (kullanici): ayni komutlar
            arac cubugunda, sag tus menusunde ve komut paletinde zaten var;
            dorduncu bir tetikleme yolu seridi doldurup hangi komutun nereden
            calistigini belirsizlestiriyordu. */}
        {icerikAlani && (
        <span className="cipsag">

          {icerikAlani && (
            <button
              type="button"
              className="d icerik-dugmesi"
              disabled={!seciliSatir}
              title={seciliSatir ? '' : 'Once bir satir secin'}
              onClick={() => { if (seciliSatir) setIcerikAcikSatir(seciliSatir) }}
            >
              İçerik
            </button>
          )}
        </span>
        )}
      </div>
      )}

      <div className="sahne">
        {(hata ?? kolonHatasi) && (
          <div className="hata-kutusu">{hata ?? kolonHatasi}</div>
        )}

        {/* Serit, CIP OLMASA DA cizilir: basvuru listesinde cipler yerini
            combolara birakti (kullanici) ve kosul yalniz ciplere baksaydi
            "Tum Liste / Son / Sik" dugmeleriyle birlikte o combolar da
            kaybolurdu. */}
        {((cipler && cipler.length > 0) || ebelgeKombo.length > 0 || !!cipSonu) && (
          // Kutu varken serit tam genislik: `width: fit-content` saga yanasmayi
          //   engelliyordu (kullanici: "Tümü/Sık/Son hizasinda saga yanasik").
          <div className={`durumseg${ebelgeKombo.length > 0 ? ' genis' : ''}`}>
            {/* Delphi'deki "Tum Liste / Son Aranan / Sik Aranan" (KULLANICI_ARAMA) -
                kart acilis/ekleme sikligina gore sunucuda filtrelenir+siralanir. */}
            {!aramaGorunumGizli && (<>
            <button
              className={`ikon-liste ${aramaGorunumu === 'tum' ? 'on' : ''}`}
              title={cev('Tüm Liste')}
              onClick={() => { setAramaGorunumu('tum'); setSayfa(1) }}
            >
              ☰
            </button>
            <button
              className={`ikon-liste ${aramaGorunumu === 'son' ? 'on' : ''}`}
              title="Son Aranan"
              onClick={() => { setAramaGorunumu('son'); setSayfa(1) }}
            >
              🕓
            </button>
            <button
              className={`ikon-liste ${aramaGorunumu === 'sik' ? 'on' : ''}`}
              title="Sık Aranan"
              onClick={() => { setAramaGorunumu('sik'); setSayfa(1) }}
            >
              ⭐
            </button>
            </>)}
            <span className="durumseg-ayrac" />
            {/* e-BELGEYE BAGLI CIPLER: sunucu ebelge aksiyonu dondurmuyorsa
                (sube mukellef degil) hic cizilmez - tiklaninca bos ekran
                acan sekme gostermeyelim. Indeksler ciplerin KENDI dizisinden
                gelir; suzme yalniz cizimi etkiler. */}
            {(cipler ?? []).map((c, i) => ({ c, i }))
              .filter(({ c }) => c.kosul !== 'ebelge' || ebelgeMukellef)
              .map(({ c, i }) => (
              <button
                key={c.ad}
                className={i === cipIndeks ? 'on' : ''}
                onClick={() => {
                  // Rotali cip: kendi listesine gider, secili cip DEGISMEZ -
                  //   geri donuldugunde onceki filtre korunur.
                  if (c.rota) { onCipRota?.(c.rota); return }
                  // Cip DEGISINCE secim temizlenir: isaretli satirlar yeni
                  //   filtrede genellikle listede degildir; kalinca sayac
                  //   ("Secili: 3") gorunenle uyusmuyor ve toplu aksiyon
                  //   ekranda OLMAYAN satiri isliyordu.
                  secimiUygula(new Set());
                  setCipIndeks(i); setSayfa(1); onCipSecildi?.(i);
                }}
              >
                {cev(c.ad)}
              </button>
            ))}
            {/* e-BELGE KUTUSU: Tüm Liste / Son / Sık dugmeleriyle AYNI seritte,
                saga yanasik (kullanici). Yalniz sunucu bu aksiyonlari
                donduruyorsa cizilir - sube e-Fatura mukellefi degilse hic
                gelmez (179). Secilen islem ANINDA calisir; kutu sonra bosalir
                ki yanlislikla ikinci kez tetiklenmesin. */}
            {aksiyonEkrani && ebelgeKombo.length > 0 && (
              <select
                className="ebk"
                // Islemlerin tamami SECILI BELGEYE uygulanir (kullanici):
                //   satir yokken kutu pasif - secim yapmadan menuyu acip
                //   "neden calismiyor" demek yerine sebebi title'da yaziyor.
                // Coklu secimde `seciliSatir` null olur ama TOPLU islem
                //   yapilabilir - kutu secim VARSA aktif.
                disabled={secili.size === 0}
                title={secili.size === 0 ? 'Önce bir satır seçin' : ''}
                value={ebelgeSecim}
                onChange={e => {
                  const kod = e.target.value;
                  setEbelgeSecim('');
                  if (!kod) return;
                  const a = ebelgeKombo.find(x => x.kod === kod);
                  if (!a) return;
                  if (!a.aktif) { mesaj(a.pasifSebep ?? 'Bu işlem şu an yapılamaz.'); return }
                  aksiyonCalistir(kod);
                }}
              >
                <option value="">— {ebelgeMenusu} —</option>
                {ebelgeKombo.map(a => (
                  a.kod.includes('.ayrac')
                    ? <option key={a.kod} value="" disabled>──────────</option>
                    : <option key={a.kod} value={a.kod}>{cev(a.ad)}</option>
                ))}
              </select>
            )}
            {tarihAlani && tarihCombo && (
              <>
                <span className="durumseg-ayrac" />
                <select className="kat-suzgec" value={tarihOn}
                        title="Tarih aralığı"
                        onChange={e => {
                          const v = e.target.value as TarihOnAyar | '';
                          setTarihOn(v);
                          const a = v === '' ? { bas: '', bit: '' } : tarihAraligi(v);
                          setTarihBas(a.bas); setTarihBit(a.bit); setSayfa(1);
                        }}>
                  <option value="">Tüm tarihler</option>
                  {TARIH_ON_AYARLAR.map(t => (
                    <option key={t.deger} value={t.deger}>{t.ad}</option>
                  ))}
                </select>
              </>
            )}
            {tarihAlani && !tarihCombo && (
              <>
                <span className="durumseg-ayrac" />
                <span className="tarih-araligi">
                  <input type="date" value={tarihBas} title="Başlama tarihi"
                         onChange={e => { setTarihBas(e.target.value); setSayfa(1) }} />
                  <span className="ayrac-metin">–</span>
                  <input type="date" value={tarihBit} title="Bitiş tarihi"
                         onChange={e => { setTarihBit(e.target.value); setSayfa(1) }} />
                  {(tarihBas || tarihBit) && (
                    <button type="button" className="kapat" title="Tarih filtresini kaldır"
                            onClick={() => { setTarihBas(''); setTarihBit(''); setSayfa(1) }}>×</button>
                  )}
                </span>
              </>
            )}
            {/* KOD SUZGECI (492, kullanici: "tümü sağına filtre için Bölüm
                combosu"): secenekler kolon metasindaki kod sozlugunden gelir,
                secim SUNUCUDA suzer - sayfali listede istemci ayiklamasi
                yanlis sonuc verirdi. */}
            {kodSuzgeci && (() => {
              // TUM kolonlarda aranir: suzgec kolonu (bolum kodu) gridde
              //   GORUNMEZ olabilir - gorunen kolon listesinde bulunamazdi.
              const kodlar = tumKolonlar.find(k => k.ad === kodSuzgeci.alan)?.kodlar;
              if (!kodlar) return null;
              return (
                <>
                  <span className="durumseg-ayrac" />
                  <select className="kat-suzgec" value={kodSuzgecDeger}
                          title={kodSuzgeci.etiket}
                          onChange={e => { setKodSuzgecDeger(e.target.value); setSayfa(1) }}>
                    <option value="">{kodSuzgeci.etiket}</option>
                    {Object.entries(kodlar).map(([k, v]) => (
                      <option key={k} value={k}>{v}</option>
                    ))}
                  </select>
                  {kodSuzgecDeger !== '' && (
                    <button type="button" className="kapat" title="Filtreyi kaldır"
                            onClick={() => { setKodSuzgecDeger(''); setSayfa(1) }}>×</button>
                  )}
                </>
              );
            })()}
            {cipSonu && <><span className="durumseg-ayrac" />{cipSonu}</>}
          </div>
        )}

        {gorunum === 'liste' && ustPanel}

        {/* YAN PANEL varsa grid + alt panel ORTA kolona girer (mockup
            .ucPanel); SOL PANEL varsa onun solunda bir kolon daha acilir.
            Ikisi de yoksa fazladan kap konmaz - eski duzen aynen kalir. */}
        <div className={gorunum === 'liste' && (yanPanel || solPanel)
          ? `grid-yan-duzen${solPanel ? ' sollu' : ''}${yanKapali ? ' kapali' : ''}`
          : undefined}>
        {gorunum === 'liste' && solPanel && (
          <aside className="grid-sol-panel">{solPanel}</aside>
        )}
        <div>
        {gorunum === 'ek' && ekGorunum ? (
          ekGorunum.icerik
        ) : gorunum !== 'liste' ? (
          <div className="kutu" style={{ padding: 48, textAlign: 'center', color: 'var(--soluk)' }}>
            {GORUNUMLER.find(g => g.v === gorunum)?.ik}{' '}
            {cev(GORUNUMLER.find(g => g.v === gorunum)?.ad)} görünümü yakında.
          </div>
        ) : (
        <div className="kutu dolgusuz">
          <div className="gridwrap">
            <div className="gridkaydir">
              <GridTablo
                agacAlani={agacAlani}
                agacDegistir={agacDegistir}
                bosEk={bosEk}
                kolonlar={dovizsizGizle?.length && !dovizVarMi
                  ? kolonlar.filter(k => !dovizsizGizle.includes(k.ad))
                  : kolonlar}
                satirlar={agacSatirlari} yukleniyor={yukleniyor}
                gruplar={gruplar} grupKolonu={kullaniciGrup ?? grupKolonu}
                satirBoyu={satirBoyu}
                gorunenToplamlar={gorunenToplamlar} toplamSeridiVar={toplamSeridiVar}
                sayfa={sayfa} sonSayfa={sonSayfa}
                secili={secili} sayfaIdleri={sayfaIdleri} secimiUygula={secimiUygula}
                satirSecimiDegistir={satirSecimiDegistir}
                hepsiSecili={hepsiSecili} hepsiRef={hepsiRef}
                satirTiklandi={satirTiklandi} satirTiklaninca={satirTiklaninca}
                satirSinifi={satirSinifi} setSeciliSatir={setSeciliSatir}
                setSagTusKonumu={setSagTusKonumu}
                siraIsareti={siraIsareti} siralamaDegistir={siralamaDegistir}
                filtreAcik={filtreAcik} filtreSatiriDegisti={filtreSatiriDegisti}
                gridMenuKonum={gridMenuKonum} setGridMenuKonum={setGridMenuKonum}
                aksiyonEkrani={aksiyonEkrani}
              />
            </div>
            {yukleniyor && <div className="yukleniyor">Yukleniyor…</div>}
          </div>

          <div className="altbilgi">
            <span>{cev('Kayıt')}: <b>{toplamKayit.toLocaleString('tr-TR')}</b>{sureMs > 0 && ` · ${sureMs} ms`}</span>
            {secili.size > 0 ? (
              <span>Secili: <b>{secili.size}</b></span>
            ) : seciliSatir && (
              <span>Secili: <b>{String(seciliSatir.unvan ?? seciliSatir.ad ?? seciliSatir.belgeNo ?? seciliSatir.id)}</b></span>
            )}
            <span className="sag">
              <button className="d" disabled={sayfa <= 1} onClick={() => setSayfa(s => s - 1)}>‹ Önceki</button>
              <span>{sayfa} / {sonSayfa}</span>
              <button className="d" disabled={sayfa >= sonSayfa} onClick={() => setSayfa(s => s + 1)}>{cev('Sonraki')} ›</button>
            </span>
          </div>
        </div>
        )}

        {altPanel}
        </div>
        {gorunum === 'liste' && yanPanel && (
          <aside className={`grid-yan-panel${yanKapali ? ' kapali' : ''}`}>
            <button className="d yan-katla" type="button"
                    title={yanKapali ? 'Paneli aç' : 'Paneli kapat'}
                    onClick={() => setYanKapali(k => !k)}>
              {yanKapali ? '‹' : '›'}
            </button>
            {!yanKapali && yanPanel}
          </aside>
        )}
        </div>
      </div>

      <GridMenu konum={gridMenuKonum} ogeler={menuOgeleri}
                onKapat={() => setGridMenuKonum(null)} />

      {aksiyonEkrani && (
        <>
          <GenSagTus
            aksiyonlar={aksiyonlar}
            calistir={aksiyonCalistir}
            konum={sagTusKonumu}
            onKapat={() => setSagTusKonumu(null)}
          />
          <GenKomutPaleti aksiyonlar={aksiyonlar} calistir={aksiyonCalistir} />
        </>
      )}

      {icerikAlani && icerikAcikSatir && (
        <Modal
          baslik={icerikBaslik ?? 'İçerik'}
          alt={<button className="d kapat-dugmesi" onClick={() => setIcerikAcikSatir(null)}>Kapat</button>}
          onKapat={() => setIcerikAcikSatir(null)}
        >
          <div style={{ padding: 12 }}>
            <table className="grid" style={{ marginBottom: 12 }}>
              <tbody>
                {kolonlar.filter(k => k.ad !== icerikAlani).map(k => (
                  <tr key={k.ad}>
                    <td style={{ fontWeight: 600, width: 140 }}>{cev(k.baslik)}</td>
                    <td>{bicimle(icerikAcikSatir[k.ad], k)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <LogTablosu deger={icerikAcikSatir[icerikAlani]} />
          </div>
        </Modal>
      )}
    </>
  );
}
