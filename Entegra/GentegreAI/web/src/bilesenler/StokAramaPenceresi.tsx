import { useCallback, useEffect, useRef, useState } from 'react';
import { Modal } from './Modal';
import { api } from '../api/istemci';
import { KategoriSuzgeci } from './KategoriSuzgeci';
import { type Kosul, type ListeSatiri, URUN_GENOTIP, hataMetni } from '../api/sozlesme';
import { para } from './bicim';
import { aramaSirala } from './aramaSirasi';
import { useOturum } from '../kimlik/OturumBaglami';


/** Satir turu: yalniz ikon gosterilir, adi baslikta (title) kalir. */
const TUR_IKONU: Record<string, string> = { stok: '📦', hizmet: '🧾', ilac: '💊' };
const TUR_ADI: Record<string, string> = { stok: 'Stok', hizmet: 'Hizmet', ilac: 'İlaç' };

/**
 * Stok / hizmet arama penceresi - satir eklemenin ilk adimi.
 *
 * Secim yapilinca KAPANMAZ: cagiran uzerine kalem (adet/fiyat) penceresini acar,
 * o kapaninca kullanici buradan siradaki stogu secer. Boylece on kalemlik bir
 * irsaliye tek arama penceresiyle girilir.
 */
/**
 * KISA AD SIRA ANAHTARI (549): 0 kisa adiyla basliyor · 1 kisa adinda geciyor
 * · 2 oteki. Kucuk sayi = uste.
 */
function kisaAdSirasi(satir: Record<string, unknown>, aranan: string): number {
  const kisa = String(satir.kisaAd ?? '').toLocaleLowerCase('tr');
  if (!kisa) return 2;
  if (kisa.startsWith(aranan)) return 0;
  return kisa.includes(aranan) ? 1 : 2;
}

export function StokAramaPenceresi({ etkin, onSec, onKapat, yalnizStok, yalnizHizmet, yon,
                                    eklenen, fiyatListesiId, sgkBaglami, bolumId,
                                    hizmetEkFiltre }: {
  /** Ustunde kalem penceresi acikken false olur; true'ya donunce arama
      kutusuna odak GERI GELIR (ardisik girişte fare gerekmesin). */
  etkin: boolean;
  onSec(satir: ListeSatiri): void;
  onKapat(): void;
  /**
   * Bu pencere acikken EKLENEN kalemler (kullanici): arama penceresi ard arda
   * giris icin acik kaldigindan, satirin gride dustugu buradan gorunmeli -
   * yoksa "eklendi mi?" diye pencereyi kapatip bakmak gerekiyordu.
   */
  eklenen?: { sayi: number; son: string };
  /**
   * BELGENIN FIYAT LISTESI (495, kullanici: "arama ekranında fiyatları
   * göreyim"): verilirse Fiyat sutunu KART fiyatini degil bu listenin
   * fiyatini gosterir - kalem penceresinde cikacak rakam neyse listede de o
   * gorunur. Fiyatlar TEK istekte cozulur (toplu uc).
   */
  fiyatListesiId?: number | null;
  /**
   * SUT BEDELI ICIN SOZLESME (602, kullanici: "stok hizmet arama listesinde
   * Katkı ve sut fiyatı da göster"). "Fiyat" kolonu BELGENIN listesinden gelir;
   * TSS'de o TTB tarifesidir ve SGK'nin odedigi bedel listede hic gorunmezdi.
   * Verilmezse SUT kolonu cizilmez - normal fatura/irsaliyede SUT kavrami yok.
   */
  sgkBaglami?: { sozlesmeId?: number | null; kurumId?: number | null;
                 sgkKullan?: number | null };
  /**
   * BASVURUNUN BOLUMU (550): verilirse hizmetler o poliklinigin KULLANIM
   * PUANINA gore siralanir - kurumun o bolumde gercekten istedigi tetkikler
   * one gelir, 10 bin kalemlik katalogun gerisi arkada kalir. Puan sayaci
   * kendiliginden dolar (belge kalemi = kullanim); kimse liste bakimi yapmaz.
   */
  bolumId?: number | null;
  /** Yalniz STOK aranir (paket icerigi gibi hizmet kabul etmeyen yerler). */
  yalnizStok?: boolean;
  /** Yalniz HIZMET aranir (260: randevunun konusu bir hizmettir, stok degil). */
  yalnizHizmet?: boolean;
  /**
   * HIZMET aramasina eklenen sabit kosul - or. lab isteminde yalniz
   * laboratuvar karsiligi OLAN hizmetler (`labVarMi = 1`). Suzgec cagirandan
   * gelir: pencere hangi ekrandan acildigini bilmemeli.
   */
  hizmetEkFiltre?: Kosul;
  /**
   * BELGENIN YONU (141): 'satis' ise yalniz `satilan`, 'alis' ise yalniz
   * `alinan` isaretli stoklar listelenir - kendi urettigimiz mamul alis
   * siparisinde, satin alinan ambalaj satis faturasinda cikmasin. Verilmezse
   * (stok karti icerigi, transfer gibi yonsuz yerler) suzme YOK.
   * HIZMETLERE uygulanmaz: hizmetin alis/satis ayrimi yok.
   */
  yon?: 'satis' | 'alis';
}) {
  const { kullanici } = useOturum();
  /**
   * HBYS'de ILAC da aranir (kullanici: "mod hbys ise ilaç da eklenecek").
   *
   * Ilac bir STOK DEGIL, TITCK referans katalogudur: 23 bin satir. Arama
   * sonucunda gorunur, secilince arka planda stok karti uretilip belgeye o
   * stok girer - boylece ne katalog stok listesini bogar, ne de eczane
   * cikisi icin memurun once elle stok karti acmasi gerekir.
   */
  const ilacAranir = kullanici?.urunModu === URUN_GENOTIP && !yalnizHizmet;
  const [arama, setArama] = useState('');
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  /**
   * KATKI KOLONU (602, kullanici: "stok hizmet arama listesinde Katkı fiyatı
   * da göster"). TTB/SUT tarifesinde satirin iki bedeli vardir - listede yalniz
   * kurumun odedigi gorunuyordu, hastanin cebinden cikacak tutar ancak kalem
   * secilince ortaya cikiyordu.
   *
   * Kolon SARTA BAGLI cizilir: sonucta katkisi olan tek bir satir bile yoksa
   * (ozel tarife, ya da katki tanimlanmamis liste) hic gosterilmez - bos bir
   * kolon zaten dar olan arama gridini daraltirdi.
   */
  const katkiKolonu = satirlar.some(r => Number(r.katki ?? 0) > 0);
  /**
   * SUT KOLONU YALNIZ "Fiyat"TAN FARKLIYSA (602, kullanici: "fiyat ve sut
   * aynı, birini kaldır").
   *
   * "Fiyat" BELGENIN listesinden gelir. Saf SGK'da belgenin listesi ZATEN SUT
   * listesidir (601) - iki kolon ayni sayiyi yazar, biri gereksiz yer kaplar.
   * TSS/Karma'da ise "Fiyat" TTB tarifesidir ve SGK'nin odedigi bedel
   * ondan farklidir; kolon orada gerekli.
   *
   * Karar SATIR SATIR degil LISTE geneli: tek bir satirda bile fark varsa
   * kolon cizilir - yoksa kolonlar satir aralarinda belirip kaybolurdu.
   * Kurus toleransi: ayni bedelin iki ayri listeden gelen kopyasi 0,004
   * kadar ayrisabilir.
   */
  const sutKolonu = satirlar.some(r => Number(r.sgkFiyat ?? 0) > 0
    && Math.abs(Number(r.sgkFiyat) - Number(r.fiyat ?? 0)) > 0.004);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState(0);
  /** Liste / Son Aranan / Sik Aranan - GenGrid ile ayni (kullanici_arama). */
  const [aramaGorunumu, setAramaGorunumu] = useState<'tum' | 'son' | 'sik'>('tum');
  /**
   * KATEGORI SUZGECI (kullanici: "sık kullanılan sağına filtre kategori combo
   * ağacı ekle"): katalog 10 bin kalem; memur adini tam bilmediginde daldan
   * daraltir ("Laboratuvar > Biyokimya"). Secilen dal ALT AGACIYLA suzer -
   * liste ekranlarindaki suzgecin aynisi (346).
   */
  const [kategoriId, setKategoriId] = useState<number | null>(null);
  const [kategoriAltlari, setKategoriAltlari] = useState<number[]>([]);
  const zamanlayici = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);

  // STOK ve HIZMET birlikte aranir: belge satiri ikisinden birine baglanabilir,
  //   kullanicinin once "hangi listede acayim" diye dusunmesi gereksiz. Iki
  //   kaynak paralel cekilir ve tip alaniyla isaretlenir.
  const ara = useCallback(async (metin: string, gorunumSecimi: 'tum' | 'son' | 'sik' = 'tum') => {
    setYukleniyor(true);
    setHata(null);
    try {
      const metinFiltresi = metin.trim()
        ? { op: 'or' as const, kosullar: ['kisaAd', 'kod', 'ad'].map(alan => ({
            alan, op: 'icerir' as const, deger: metin.trim() })) }
        : undefined;
      // HIZMETTE KISA AD DA ARANIR (549, kullanici: "başvuruda ücretlemede
      //   stok/hizmet ara listesinde de görünecek ve aranacak"). Stokta
      //   boyle bir alan yok - filtre kaynaga gore ayrilir.
      const hizmetFiltresi = metin.trim()
        ? { op: 'or' as const, kosullar: ['kisaAd', 'kod', 'ad'].map(alan => ({
            alan, op: 'icerir' as const, deger: metin.trim() })) }
        : undefined;
      // KATEGORI KOSULU (dal + alt dallari). Kolon adi kaynaga gore degisir:
      //   stok/ilacta `kategoriId`, hizmette `kategori`.
      const kategoriKosulu = (alan: string) => (kategoriAltlari.length
        ? { alan, op: 'icinde' as const, deger: kategoriAltlari }
        : null);
      const veIle = (a: unknown, b: unknown) => {
        const par = [a, b].filter(Boolean) as Kosul[];
        return par.length === 0 ? undefined
             : par.length === 1 ? par[0]
             : { op: 'and' as const, kosullar: par };
      };
      // Stok tarafinda belgenin yonune gore satilan/alinan bayragi eklenir (141).
      const yonKosulu = yon
        ? { alan: yon === 'alis' ? 'alinan' : 'satilan', op: 'esit' as const, deger: 1 }
        : null;
      const filtre = veIle(veIle(hizmetFiltresi, kategoriKosulu('kategori')),
                           hizmetEkFiltre);
      const stokFiltresi = veIle(
        yonKosulu
          ? (metinFiltresi ? { op: 'and' as const, kosullar: [metinFiltresi, yonKosulu] }
                           : yonKosulu)
          : metinFiltresi,
        kategoriKosulu('kategoriId'));

      // gorunum: Son/Sik Aranan sunucuda kullanici_arama ile suzulur+siralanir.
      const gorunum = gorunumSecimi === 'tum' ? undefined : gorunumSecimi;
      // Ilac barkodla da aranir: eczane cikisinda memur kutunun ustundeki
      //   barkodu okutur, adini yazmaz.
      const ilacFiltresi = veIle(
        metin.trim()
          ? { op: 'or' as const,
              kosullar: ['kisaAd', 'barkod', 'ad', 'etkenMadde'].map(alan => ({
                alan, op: 'icerir' as const, deger: metin.trim() })) }
          : undefined,
        // Ilacin kategorisi BAGLI STOK KARTINDAN gelir; stok karti henuz
        //   uretilmemis ilac kategori suzgecinde gorunmez - dogrusu da bu:
        //   dal secen kullanici o dalda TANIMLI kalemleri istiyor.
        kategoriKosulu('kategoriId'));

      const [stoklar, hizmetler, ilaclar] = await Promise.all([
        yalnizHizmet ? Promise.resolve({ satirlar: [] as ListeSatiri[] })
                     // KULLANIM SIRASI (552): stok da bolumun gecmisine gore.
                     : api.liste('stok', gorunum
                         ? { sayfa: 1, boyut: 25, filtre: stokFiltresi, gorunum }
                         : { sayfa: 1, boyut: 25, filtre: stokFiltresi,
                             gorunum: 'kullanim', bolum: bolumId ?? 0 }),
        yalnizStok ? Promise.resolve({ satirlar: [] as ListeSatiri[] })
                   // KULLANIM SIRASI (550): "Tüm Liste"de hizmetler bolumun
                   //   gecmisine gore siralanir. Son/Sik gorunumu secildiyse
                   //   kullanicinin kendi gecmisi kazanir - kisisel secim
                   //   kurumun ortalamasindan once gelir.
                   : api.liste('hizmet', gorunum
                       ? { sayfa: 1, boyut: 25, filtre, gorunum }
                       : { sayfa: 1, boyut: 25, filtre,
                           gorunum: 'kullanim', bolum: bolumId ?? 0 }),
        ilacAranir ? api.liste('ilac', gorunum
                       ? { sayfa: 1, boyut: 25, filtre: ilacFiltresi, gorunum }
                       // Ilacin puani STOK KARTINDAN gelir (552).
                       : { sayfa: 1, boyut: 25, filtre: ilacFiltresi,
                           gorunum: 'kullanim', bolum: bolumId ?? 0 })
                   : Promise.resolve({ satirlar: [] as ListeSatiri[] }),
      ]);

      // SIRA GORUNUME GORE (ortak kural, aramaSirasi.ts): "Tüm Liste"de ada
      //   gore, Son/Sik'ta sunucunun verdigi anahtarlarla. Iki kaynak AYRI
      //   istekle geldigi icin siralama birlestirmeden SONRA yapilmali -
      //   alfabetik siralama sunucunun sirasini eziyor ve en son secilen kayit
      //   en uste gelmiyordu (kullanici).
      // SUNUCUNUN SIRASI KORUNUR (550): kullanim gorunumunde hizmetler zaten
      //   puana gore geldi; alfabetik yeniden siralamak onu bozardi. Stok ve
      //   ilac kendi icinde ada gore, hizmet sunucunun verdigi sirada.
      // BASVURU BAGLAMINDA (bolumId verilmis) HIZMETLER ONCE ve SUNUCUNUN
      //   PUAN SIRASINDA durur; alfabetik birlestirme onlari 10 bin kalemin
      //   arasina dagitirdi. Malzeme/ilac altta, kendi aralarinda ada gore.
      //   Bolum yoksa (stok fisi, paket icerigi) eski davranis: tek A-Z liste.
      // KATEGORI TEK ALANDA (kullanici: "kod un soluna Kategori ekle"):
      //   kaynaklarin kolon adi ayni degil - stokta kategori YOLU `kategori`
      //   alaninda (sayisal id `kategoriId`), hizmette tam tersi. Satirlar
      //   birlestirilmeden once `kategoriAdi`ya normallenir, tablo tek alan
      //   okur. Ilac kendi kategorisini tasimaz; bagli stok kartindan gelir.
      const stokSatiri = (r: ListeSatiri, tip: string): ListeSatiri => ({
        ...r, tip, kategoriAdi: r.kategoriAdi ?? r.kategori ?? '',
      });
      const hizmetSatirlari = hizmetler.satirlar.map(
        (r): ListeSatiri => ({ ...r, tip: 'hizmet' }));
      const puanSirasi = bolumId != null && gorunumSecimi === 'tum';

      const birlesik = puanSirasi
        ? [...hizmetSatirlari, ...aramaSirala<ListeSatiri>([
            ...stoklar.satirlar.map(r => stokSatiri(r, 'stok')),
            ...ilaclar.satirlar.map((r): ListeSatiri => ({
              ...stokSatiri(r, 'ilac'), kod: r.barkod, izlemeAdi: 'Karekod',
            })),
          ], gorunumSecimi)]
        : aramaSirala<ListeSatiri>([
        ...stoklar.satirlar.map(r => stokSatiri(r, 'stok')),
        ...hizmetSatirlari,
        // Ilac satiri stok satiri gibi gorunsun: kod = barkod (ilacin kimligi
        //   barkodudur), izleme karekod (ITS).
        ...ilaclar.satirlar.map((r): ListeSatiri => ({
          ...stokSatiri(r, 'ilac'), kod: r.barkod, izlemeAdi: 'Karekod',
        })),
      ], gorunumSecimi);

      // KISA AD ONCELIGI (549, kullanici: "aramada öncelik ona olsun").
      //   Kullanici kurumun gunluk adini yaziyor ("HEMOGRAM"); resmi adinda
      //   ayni harfler gecen 30 tetkik arasinda o kalem alfabetik sirada
      //   kayboluyordu. Kisa adiyla BASLAYAN once, iceren sonra, otekiler
      //   sunucunun verdigi sirada. Yalniz "Tüm Liste" gorunumunde: Son/Sik
      //   siralamasi kullanicinin kendi gecmisidir, ezilmemeli.
      const aranan = metin.trim().toLocaleLowerCase('tr');
      const sirali = aranan && gorunumSecimi === 'tum'
        ? [...birlesik].sort((a, b) => kisaAdSirasi(a, aranan) - kisaAdSirasi(b, aranan))
        : birlesik;

      setSatirlar(sirali);
      setSecili(0);

      // LISTE FIYATLARI (495): arama sonucu geldikten sonra tek istekte
      //   cozulur; liste yoksa kart fiyati gosterilmeye devam eder.
      if (fiyatListesiId && sirali.length) {
        try {
          const y = await api.fiyatListesiFiyatlar(fiyatListesiId, sirali
            .filter(r => r.tip !== 'ilac')
            .map(r => (r.tip === 'hizmet'
              ? { hizmetId: Number(r.id) } : { stokId: Number(r.id) })),
            sgkBaglami);
          const anahtar = (t: unknown, id: unknown) => `${t}:${id}`;
          const harita = new Map(y.satirlar.map(x => [
            anahtar(x.hizmetId ? 'hizmet' : 'stok', x.hizmetId ?? x.stokId), x]));
          setSatirlar(sirali.map(r => {
            const f = harita.get(anahtar(r.tip, r.id));
            // KATKI DA TASINIR (602): fiyat cozulemese bile katki gelebilir
            //   (SUT listesinde fiyat yok ama katki tanimli olabilir), bu
            //   yuzden iki alan AYRI yazilir.
            const katki = f?.katki != null && f.katki > 0 ? { katki: f.katki } : {};
            const sut = f?.sgkFiyat != null && f.sgkFiyat > 0 ? { sgkFiyat: f.sgkFiyat } : {};
            return f && f.fiyat != null
              ? { ...r, fiyat: f.fiyat, fiyatDovizi: f.dovizCinsi || r.fiyatDovizi,
                  listeFiyati: 1, ...katki, ...sut }
              : { ...r, ...katki, ...sut };
          }));
        } catch { /* liste fiyati cozulemedi - kart fiyati kalir */ }
      }
    } catch (h) {
      setHata(hataMetni(h));
      setSatirlar([]);
    } finally { setYukleniyor(false) }
  // Kategori secimi ARAMANIN PARCASI: degisince liste yeniden cekilir
  //   (dizi her cizimde yeni referans olmasin diye anahtar metin).
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [yalnizStok, yalnizHizmet, yon, ilacAranir, fiyatListesiId,
      kategoriAltlari.join(',')]);

  useEffect(() => { void ara(arama, aramaGorunumu) }, [ara, aramaGorunumu]);  // eslint-disable-line react-hooks/exhaustive-deps

  /**
   * Pencere one gelince (acilista ve kalem penceresi kapaninca) imlec aramada.
   *
   * KALEM PENCERESI KAPANINCA ARAMA KUTUSU BOSALIR (kullanici: "fiyat ekranı
   * kapandığında hizmet arama editi boşalmalı"): ard arda ucret girerken eski
   * arama metni kaliyordu, memur her seferinde elle siliyordu. Bosalinca liste
   * de basa doner (tum / son aranan gorunumu).
   */
  const oncekiEtkin = useRef(etkin);
  /**
   * PENCERE ONE GELDIGI AN (kullanici: "ücret tek seçtim çift ekledi").
   *
   * Kalem penceresinde ENTER'a basili tutmak (ya da hizlica iki kez basmak)
   * tus TEKRARI uretiyor: ilk tus kalemi kaydedip pencereyi kapatiyor, hemen
   * ardindan gelen tekrar ARAMA kutusuna dusuyor ve listenin ilk satirini -
   * "son aranan" siralamasi yuzunden az once eklenen kalemi - yeniden
   * seciyordu. Ikinci kalem boylece kullanici istemeden gride giriyordu.
   * Pencere one geldikten sonraki ilk anda gelen Enter yok sayilir.
   */
  const oneGelis = useRef(0);
  useEffect(() => {
    if (etkin) {
      if (!oncekiEtkin.current) {
        setArama('');
        setSecili(0);
        void ara('', aramaGorunumu);
        oneGelis.current = Date.now();
      }
      kutu.current?.focus();
    }
    oncekiEtkin.current = etkin;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [etkin]);

  const yaz = (metin: string) => {
    setArama(metin);
    window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => void ara(metin, aramaGorunumu), 250);
  };

  /**
   * ILAC SECIMI STOK SATIRINA CEVRILIR.
   *
   * Belge satiri daima bir stoga baglanir; ilac referans katalogudur. Secilince
   * stok karti (yoksa) uretilir ve gride O STOK duser - kullanici arada bir
   * "stok karti ac" adimi gormez. Uretim SUNUCUDA tek islemde yapilir, bu
   * yuzden ard arda ayni ilaca basmak ikinci kart acmaz.
   */
  const [uretiliyor, setUretiliyor] = useState(false);
  const sec = async (r: ListeSatiri) => {
    if (r.tip !== 'ilac') { onSec(r); return }
    if (uretiliyor) return;
    setUretiliyor(true);
    setHata(null);
    try {
      const { stokId, fiyat } = await api.ilacStokKarti(Number(r.id));
      const stok = await api.liste('stok', { sayfa: 1, boyut: 1,
        filtre: { alan: 'id', op: 'esit', deger: stokId } });
      // Stok satiri bulunamazsa (yetki suzmesi) ilac satiriyla devam etmek
      //   yanlis olurdu: satir stok kimligi tasimadan gride dusemez.
      if (!stok.satirlar[0]) throw new Error('İlaç için stok kartı okunamadı.');
      // Fiyat kart satirindan gelir; uc de kartin GUNCEL satis fiyatini
      //   dondurur (ayni islemde yazmis olabilir - liste sorgusu onu
      //   gormeden okunursa kalem penceresi bos acilirdi).
      onSec({ ...stok.satirlar[0], tip: 'stok',
              fiyat: Number(stok.satirlar[0].fiyat ?? 0) > 0
                     ? stok.satirlar[0].fiyat : (fiyat || undefined) });
    } catch (h) {
      setHata(hataMetni(h));
    } finally { setUretiliyor(false) }
  };

  const tus = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(i => Math.min(i + 1, satirlar.length - 1)) }
    else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(i => Math.max(i - 1, 0)) }
    else if (e.key === 'Enter' && satirlar[secili]) {
      e.preventDefault();
      // Basili tutulan Enter'in TEKRARI secim sayilmaz.
      if (e.repeat) return;
      // Kalem penceresi yeni kapandiysa bu Enter ona aitti - 400 ms sus.
      if (Date.now() - oneGelis.current < 400) return;
      void sec(satirlar[secili]);
    }
  };

  return (
    <Modal
      baslik={yalnizHizmet ? "Hizmet Ara"
              : ilacAranir ? (yalnizStok ? "Stok / İlaç Ara" : "Stok / Hizmet / İlaç Ara")
              : yalnizStok ? "Stok Ara" : "Stok / Hizmet Ara"}
      onKapat={onKapat}
      /* SABIT YUKSEKLIK (kullanici): satir sayisi her aramada degisiyor;
         pencere icerige gore buyuyup kuculunce de kirpisma suruyordu. Govde
         sabit, liste kendi icinde kayar. */
      ekSinif="stok-arama"
      /* Liste her tusta yeniden ciziliyor: yukseklik kilidinin olcumu
         pencereyi kirpistiriyordu (kullanici). Bu pencerenin yuksekligi
         CSS'ten gelir, kilide gerek yok. */
      olcumYok
      alt={
        <>
          {eklenen && eklenen.sayi > 0 && (
            <span className="kapt" style={{ marginRight: 'auto' }}>
              ✓ {eklenen.sayi} kalem eklendi{eklenen.son ? ` · son: ${eklenen.son}` : ''}
            </span>
          )}
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>
        </>
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="kagrup">
          {/* Arama kutusu ve Liste/Son/Sik dugmeleri LISTE EKRANLARIYLA ayni
              (GenGrid deseni) - kullanici ayni araci iki farkli bicimde
              ogrenmek zorunda kalmasin. */}
          <div className="cipler" style={{ margin: 10 }}>
            <div className="ara-kutu cok-genis">
              <span>🔍</span>
              <input type="search"
                ref={kutu}
                autoFocus
                placeholder={ilacAranir ? "Stok, hizmet ya da ilaç (barkod) ara…"
                                        : "Stok ya da hizmet ara…"}
                value={arama}
                onChange={e => yaz(e.target.value)}
                onKeyDown={tus}
              />
            </div>

            {yukleniyor && <span className="arama-bekliyor">Aranıyor…</span>}

            <div className="durumseg">
              <button className={`ikon-liste ${aramaGorunumu === 'tum' ? 'on' : ''}`}
                      title="Tüm Liste" onClick={() => setAramaGorunumu('tum')}>☰</button>
              <button className={`ikon-liste ${aramaGorunumu === 'son' ? 'on' : ''}`}
                      title="Son Aranan" onClick={() => setAramaGorunumu('son')}>🕓</button>
              <button className={`ikon-liste ${aramaGorunumu === 'sik' ? 'on' : ''}`}
                      title="Sık Aranan" onClick={() => setAramaGorunumu('sik')}>⭐</button>
            </div>

            {/* KATEGORI AGACI - Sık Aranan'ın SAĞINDA (kullanici). Aranan
                turler neyse o agac(lar) gosterilir: yalniz hizmet aranirken
                stok dallari secenek olarak durmasin. */}
            <KategoriSuzgeci
              tur={yalnizHizmet ? [2] : yalnizStok ? [1] : [1, 2]}
              deger={kategoriId}
              onDegis={(id, altlar) => { setKategoriId(id); setKategoriAltlari(altlar) }} />
          </div>
          <table className="detay-tablo secilebilir">
            <thead>
              <tr>
                <th style={{ width: 34 }} className="hiza-orta" title="Tür"></th>
                {/* KATEGORI KODUN SOLUNDA (kullanici): ayni ad birden fazla
                    kalemde gecebiliyor ("MUAYENE"); hangi daldan oldugu kodu
                    okumadan once secilir. Yol bicimi "Üst > Alt". */}
                <th style={{ width: 170 }}>Kategori</th>
                {/* KOD · KISA AD · KALAN · IZLEME YARIYA (kullanici): dordu de
                    kisa deger tasiyor, genis kolonlar ADI sikistiriyordu -
                    kalemi ayirt eden asil bilgi odur. Ad'a acik genislik
                    verilmez; kalan yeri o alir. */}
                <th style={{ width: 65 }}>Kod</th>
                {/* KISA AD (549): yalniz hizmette dolu - stok/ilacta bos gecer. */}
                <th style={{ width: 75 }}>Kısa Ad</th>
                <th>Ad</th>
                <th className="hiza-sag" style={{ width: 45 }}>Kalan</th>
                <th className="hiza-sag" style={{ width: 80 }}>Fiyat</th>
                {/* KATKI (602, kullanici: "stok hizmet arama listesinde
                    Katkı fiyatı da göster"): hicbir satirda katki yoksa
                    kolon HIC cizilmez - ozel tarifede bos yer kaplardi. */}
                {katkiKolonu && (
                  <th className="hiza-sag" style={{ width: 80 }}>Katkı</th>
                )}
                {sutKolonu && (
                  <th className="hiza-sag" style={{ width: 80 }}>SUT</th>
                )}
                <th style={{ width: 60 }} className="hiza-orta">Döviz</th>
                {/* KDV IZLEMENIN SOLUNDA (kullanici): KDV fiyatin devami -
                    ikisi yan yana okunur; izleme (karekod/seri) ayri bir
                    konudur, sona duser. */}
                <th className="hiza-sag" style={{ width: 40 }}>KDV</th>
                <th style={{ width: 55 }} className="hiza-orta">İzleme</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map((r, i) => (
                <tr key={`${r.tip}-${r.id}`} className={i === secili ? 'secili' : ''}
                    onMouseEnter={() => setSecili(i)}
                    onClick={() => void sec(r)}>
                  {/* TUR YALNIZ IKON (kullanici): uc satir tipini ayirmak icin
                      rozet metni gereksiz genislik yiyordu. Ad yine erisilebilir
                      - imlec ustune gelince baslik cikar. */}
                  <td className="hiza-orta" title={TUR_ADI[String(r.tip)] ?? 'Stok'}
                      aria-label={TUR_ADI[String(r.tip)] ?? 'Stok'}>
                    <span style={{ fontSize: 15 }}>{TUR_IKONU[String(r.tip)] ?? '📦'}</span>
                  </td>
                  <td className="sonuk" title={String(r.kategoriAdi ?? '')}>
                    {String(r.kategoriAdi ?? '') || '—'}</td>
                  <td><code>{String(r.kod ?? '')}</code></td>
                  <td>{String(r.kisaAd ?? '') || <span className="sonuk">—</span>}</td>
                  <td>{String(r.ad ?? '')}</td>
                  {/* Kalan ve izleme yalniz STOKTA anlamli - hizmette stok bakiyesi yok. */}
                  <td className="hiza-sag">
                    {r.tip !== 'stok' ? <span className="sonuk">—</span>
                      : Number(r.kalan ?? 0).toLocaleString('tr-TR')}
                  </td>
                  <td className="hiza-sag"
                      title={r.listeFiyati ? 'Belgenin fiyat listesinden' : 'Kart fiyatı'}>
                    {r.fiyat ? para.format(Number(r.fiyat)) : <span className="sonuk">—</span>}
                  </td>
                  {katkiKolonu && (
                    <td className="hiza-sag" title="Hastanın ödeyeceği katkı">
                      {Number(r.katki ?? 0) > 0
                        ? para.format(Number(r.katki))
                        : <span className="sonuk">—</span>}
                    </td>
                  )}
                  {sutKolonu && (
                    <td className="hiza-sag" title="SGK'nın ödediği SUT bedeli">
                      {Number(r.sgkFiyat ?? 0) > 0
                        ? para.format(Number(r.sgkFiyat))
                        : <span className="sonuk">—</span>}
                    </td>
                  )}
                  <td className="hiza-orta sonuk">{String(r.fiyatDovizi ?? '') || '—'}</td>
                  <td className="hiza-sag">%{String(r.kdv ?? 0)}</td>
                  <td className="hiza-orta">
                    {r.tip === 'hizmet' ? <span className="sonuk">—</span>
                      : String(r.izlemeAdi ?? 'Yok') === 'Yok'
                        ? <span className="sonuk">Yok</span>
                        : <span className="rozet bilgi">{String(r.izlemeAdi)}</span>}
                  </td>
                </tr>
              ))}
              {!yukleniyor && satirlar.length === 0 && (
                <tr><td colSpan={10} className="bos">Kayıt yok</td></tr>
              )}
            </tbody>
          </table>
          {/* ARAMA GOSTERGESI LISTEYI KAPATMAZ (kullanici: "her harf girildikçe
              ekran beyaz olup tekrar eski haline geliyor, göz kırpması gibi").
              `.yukleniyor` `position:absolute; inset:0` ve OPAK bir katman -
              grid ekraninda tek seferlik yuklemede dogru, burada her tusa
              basista listenin ustune beyaz perde cekiyordu. Onceki sonuc
              ekranda kalir, arama kutusunun yaninda kucuk bir not doner. */}
        </div>
      </>
    </Modal>
  );
}

