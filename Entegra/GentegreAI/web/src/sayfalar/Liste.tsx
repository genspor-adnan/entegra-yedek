import { useCallback, useEffect, useMemo, useState } from 'react';
import { c, cm } from '../dil/ceviri';
import { guvenli, mesaj, metinSor, onay } from '../bilesenler/mesaj';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { GenGrid } from '../bilesenler/GenGrid';
import { RandevuTakvimi } from '../bilesenler/RandevuTakvimi';
import { GenForm } from '../bilesenler/GenForm';
import {
  type EBelgeMesaji, type Kosul, type ListeSatiri, type RandevuBolumDugumu, hataMetni,
} from '../api/sozlesme';
import { kampanyaKalemFiyati } from './belgeKalem';
import { api } from '../api/istemci';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { IceriAlModali } from '../bilesenler/IceriAlModali';
import { IstemModali } from '../bilesenler/radyoloji/IstemModali';
import { TeslimModali } from '../bilesenler/radyoloji/TeslimModali';
import { RandevuModali } from '../bilesenler/radyoloji/RandevuModali';
import { RandevuBekleyenPanel, type BekleyenIstem }
  from '../bilesenler/radyoloji/RandevuBekleyenPanel';
import { KritikBildirimModali } from '../bilesenler/radyoloji/KritikBildirimModali';
import { KonsultasyonCevapModali }
  from '../bilesenler/radyoloji/KonsultasyonCevapModali';
import { CihazKapatmaModali } from '../bilesenler/radyoloji/CihazKapatmaModali';
import { SarfOnayModali } from '../bilesenler/radyoloji/SarfOnayModali';
import { TarafArama } from '../bilesenler/TarafArama';
import { KategoriSuzgeci } from '../bilesenler/KategoriSuzgeci';
import { BolumSuzgeci } from '../bilesenler/BolumSuzgeci';
import { TARIH_ON_AYARLAR, tarihAraligi, type TarihOnAyar }
  from './liste/tarihAralik';
import { useOturum } from '../kimlik/OturumBaglami';
import { KategoriAgacPaneli } from '../bilesenler/KategoriAgacPaneli';
import { UtsAlmaModali } from '../bilesenler/uts/UtsAlmaModali';
import { UtsKullanimModali } from '../bilesenler/uts/UtsBildirimModallari';
import { UtsGenelBildirimModali, type UtsBildirimTuru }
  from '../bilesenler/uts/UtsGenelBildirimModali';
import { UtsBelgeSonucModali } from '../bilesenler/uts/UtsBelgeSonucModali';
import { KalemRolModali } from '../bilesenler/prim/KalemRolModali';
import { DonemKapatModali } from '../bilesenler/prim/DonemKapatModali';
import { UtsHazirlaSonucModali } from '../bilesenler/uts/UtsHazirlaSonucModali';
import type { UtsBelgeBildirimYaniti, UtsHazirlaYaniti } from '../api/istemci';
import { ebelgeCiktisi } from './ebelgeIslem';
import { gelenBelgeAksiyonu } from './gelenBelgeIslem';
import { utsAksiyonu } from './liste/utsAksiyonlari';
import { kasaAksiyonu } from './liste/kasaAksiyonlari';
import { bildirimAksiyonu } from './liste/bildirimAksiyonlari';
import { zamanliIsAksiyonu } from './liste/zamanliIsAksiyonlari';
import { ilacAksiyonu } from './liste/ilacAksiyonlari';
import { muayeneAksiyonu } from './liste/muayeneAksiyonlari';
import { hekimListesiAksiyonu } from './liste/hekimListesiAksiyonlari';
import { enabizAksiyonu } from './liste/enabizAksiyonlari';
import { dokumanAksiyonu } from './liste/dokumanAksiyonlari';
import { DokumanKlasorPaneli, type KlasorSecimi } from '../bilesenler/DokumanKlasorPaneli';
import { fiyatListesiAksiyonu } from './liste/fiyatListesiAksiyonlari';
import { ebelgeAksiyonu } from './liste/ebelgeAksiyonlari';
import { Modal } from '../bilesenler/Modal';
import { BelgeKarti } from './BelgeKarti';
import { KasaIslemKarti } from './KasaIslemKarti';
import { DONUSUM_MENUSU, KASA_ARAC_MENUSU, LISTELER, type ListeTanimi }
  from './listeTanimlari';

// Tanimlar ayri dosyada (listeTanimlari); disaridan alisilmis yol bozulmasin
//   diye buradan da disa aktarilir (App.tsx / Kabuk.tsx LISTELER'i buradan alir).
export { LISTELER };

/** Kirilma yolu ("Satis › Satış Faturaları") parca parca cevrilir: ayrac
    korunur, her parca menu sozlugunden gecer. */
function yolCevir(yol: string | undefined): string | undefined {
  if (!yol) return yol;
  return yol.split('›').map(p => cm(p.trim())).join(' › ');
}
export type { ListeTanimi };

/**
 * Tek bilesen tum liste ekranlarini karsilar. Kolonlar, filtreler ve yetki
 * sunucudan geldigi icin ekran basina kod yazmaya gerek yok — yeni bir liste
 * eklemek katalogda kaynak tanimlamak + burada bir satir demek.
 */
/**
 * Yerel saat damgasi (yyyy-MM-ddTHH:mm). Date.toISOString() UTC verir;
 * TR'de kaydedilen saat 3 saat geriye duser.
 */
const yerelZamanDamgasi = () => {
  const d = new Date();
  return new Date(d.getTime() - d.getTimezoneOffset() * 60000)
    .toISOString().slice(0, 16);
};

export function Liste({ tanim }: { tanim: ListeTanimi }) {
  const git = useNavigate();
  const { id } = useParams();
  const [sorgu] = useSearchParams();

  // Kart MODAL acilir (mockup deseni): liste arkada kalir, URL yine /cari/4911.
  const kartId = id === undefined ? null : (id === 'yeni' ? 'yeni' as const : Number(id));

  // Ekstre ekranlari: /hesap-ekstre?hesapId=12 -> sunucu filtresi. Tanimdaki
  //   sabitFiltre ile birlikte gelirse ikisi AND'lenir.
  const urlDegeri = tanim.urlFiltreAlani ? sorgu.get(tanim.urlFiltreAlani) : null;
  const sabitFiltre = useMemo<Kosul | undefined>(() => {
    if (!tanim.urlFiltreAlani || !urlDegeri) return tanim.sabitFiltre;
    const urlKosul: Kosul = { alan: tanim.urlFiltreAlani, op: 'esit', deger: Number(urlDegeri) };
    return tanim.sabitFiltre
      ? { op: 'and', kosullar: [tanim.sabitFiltre, urlKosul] }
      : urlKosul;
  }, [tanim.urlFiltreAlani, tanim.sabitFiltre, urlDegeri]);

  // Kart kaydedilince (ekleme ya da duzenleme) grid'i yeniden yukletmek icin - GenForm
  //   onKaydedildi'de bir arttirilir, GenGrid bu degisimi izleyip yukle() cagirir.
  const [yenile, setYenile] = useState(0);
  /** Kategori suzgeci (kullanici): secilen dal + alt agaci. */
  const [kategoriDal, setKategoriDal] = useState<{ id: number; agac: number[] } | null>(null);
  /** Sol kategori AGAC paneli acik mi (kullanici: "acilir kapanir olsun"). */
  const [kategoriPaneli, setKategoriPaneli] = useState(false);
  /**
   * RADYOLOJI ISTEM ACMA (304): listeden acilinca once HASTA secilir
   * (istem hastaya aittir), sonra tetkik modali gelir.
   */
  const [istemHastaArama, setIstemHastaArama] = useState(false);
  const [istemModali, setIstemModali] = useState<
    { hastaId: number; hastaAdi: string; disIstem: boolean;
      /** Randevudan kabul (317): istem randevuya bağlanır, tetkik ön seçili gelir. */
      randevuId?: number; hizmetId?: number } | null>(null);
  /** Sonuc teslimi (304) - film/CD/rapor kime verildi. */
  /** Radyoloji: secili isteme randevu verme (316). */
  const [randevuModali, setRandevuModali] = useState<
    { istemId: number; accessionNo: string; tetkikAdi: string;
      modalite: number; sureDk: number } | null>(null);
  /**
   * Takvimin yan panelinde (316) seçili bekleyen istem: takvimde boş saate
   * tıklanınca yeni randevu formu yerine BU isteme randevu verilir.
   */
  const [bekleyenSecili, setBekleyenSecili] = useState<BekleyenIstem | null>(null);
  const [teslimModali, setTeslimModali] = useState<
    { istemId: number; accessionNo: string; cdIstendi?: boolean } | null>(null);
  /** Kritik bulgu bildirimi (318) - takip listesinden acilir. */
  const [kritikModali, setKritikModali] = useState<
    { istemId: number; accessionNo: string; hasta: string; tetkik: string;
      bulgu: string; bildirilenAd: string } | null>(null);
  /** Cekim sonrasi sarf onayi (320) - protokol malzemesi onerilir. */
  const [sarfModali, setSarfModali] = useState<
    { istemId: number; accessionNo: string; tetkikAdi: string } | null>(null);
  /** Takvimden cihaz kapatma (318): isaretli aralik + cihaz. */
  const [kapatmaModali, setKapatmaModali] = useState<
    { cihazId: number; cihazAdi: string; baslangic: string; bitis: string } | null>(null);
  /** Konsultasyon cevabi (318). */
  const [konsultasyonModali, setKonsultasyonModali] = useState<
    { istemId: number; konsultasyonId: number; accessionNo: string; hasta: string;
      tetkik: string; soru: string; gorus: string } | null>(null);
  // Yeni kart EKLENINCE (duzenlemede degil) grid "Son Aranan"a gecsin - kullanici
  //   az once ekledigi kaydi listede otomatik en ustte gorsun.
  const [odaklaSonEklenen, setOdaklaSonEklenen] = useState(0);
  /** Prim rolleri (324): hakedis satirindan kalemin rollerine gecis. */
  const [rolModali, setRolModali] = useState<
    { satirId: number; ad: string } | null>(null);
  /** Hakedis donemi kapatma (324) - secili satirin kisisi on dolu gelir. */
  const [donemModali, setDonemModali] = useState<
    { tarafId?: number; kisi?: string } | null>(null);
  /** Excel'den iceri alma modali (207) - fiyat listesi; null iken kapali. */
  const [iceriAl, setIceriAl] = useState<{ listeId: number; ad: string } | null>(null);
  // ÜTS alma bildirimi (223): askidaki envanter satirindan modal.
  const [utsAlma, setUtsAlma] = useState<{ envanterId: number; urunNo: string;
    kurumUnvan: string; askiAdet: number; seriNo: string } | null>(null);
  const [utsKullanim, setUtsKullanim] = useState(false);
  const [utsGenel, setUtsGenel] = useState<UtsBildirimTuru | null>(null);
  // Verme hazirlama raporu (atlananlar gridi + CSV).
  const [utsHazirla, setUtsHazirla] = useState<UtsHazirlaYaniti | null>(null);
  // Belge koprusu sonucu (226): satir satir verme/alma raporu.
  const [utsBelgeSonuc, setUtsBelgeSonuc] = useState<UtsBelgeBildirimYaniti | null>(null);
  // Donusum modali (F8): siparis/irsaliye satirlarindan yeni belge uretir.
  /** Mesaj gecmisi penceresi (178) - null iken kapali. */
  const [eBelgeMesajlari, setEBelgeMesajlari] =
    useState<{ belgeNo: string; satirlar: EBelgeMesaji[] } | null>(null);
  const [donusum, setDonusum] =
    useState<{ belgeId: number; belgeTur: number; hedef?: number } | null>(null);
  // Belge (fatura/siparis) karti da MODAL: liste arkada kalir, rota degismez.
  const [yeniBelgeTuru, setYeniBelgeTuru] = useState<number | null>(null);
  // Mevcut belgeyi ac (salt gorunum) - ayni modal, id ile.
  const [acikBelgeId, setAcikBelgeId] = useState<number | null>(null);
  // Kasa islem karti MODAL (tahsilat/odeme): liste arkada acik kalir.
  const [kasaTuru, setKasaTuru] = useState<number | null>(null);
  // Ekstre satirindan acilan MEVCUT kasa islemi (salt gorunum/duzenleme).
  const [acikKasaId, setAcikKasaId] = useState<number | null>(null);
  /** Cek/senet ile tahsilat-odemede once acilan KIYMET KARTININ turu (23/24/33/34). */
  const [cekTuru, setCekTuru] = useState<number | null>(null);
  /** Kiymet kaydedildikten sonra acilan kasa islemi (ayni kiymete bagli). */
  const [kasaAcilis, setKasaAcilis] = useState<{
    tur: number; tarafId?: number; tarafUnvan?: string; tutar?: string; cekSenetId?: number;
  } | null>(null);

  /**
   * Kiymet karti kaydedildi: ayni bilgilerle kasa islemini ac. Kart SUNUCUDAN
   * yeniden okunur - tutar/cari/doviz kullanicinin kartta girdigi son hali
   * olsun (formdaki ara degerler degil).
   */
  async function cekKartKaydedildi(tur: number, id: number) {
    setCekTuru(null);
    setYenile(t => t + 1);
    try {
      const k = await api.kartOku('cek-senet', id);
      const kart = k.kart as Record<string, unknown>;
      setKasaAcilis({
        tur,
        tarafId: Number(kart.tarafId) || undefined,
        tarafUnvan: String(k.kodAd?.tarafId?.[String(kart.tarafId)] ?? ''),
        tutar: String(kart.tutar ?? ''),
        cekSenetId: id,
      });
    } catch {
      // Kiymet kaydedildi ama okunamadi: kasa islemi kartini bos acmaktansa
      //   kullaniciyi listeye birak - kiymet portfoyde duruyor.
      setKasaTuru(tur);
    }
  }
  // "Ekstre" modu (A secenegi): ayni grid ekstre kaynagina doner. null = liste.
  const [ekstre, setEkstre] = useState<{ id: number; ad: string } | null>(null);
  /** Ekstre gridinde SECILI satir - "Başvuru Aç" bunu kullanir. */
  const [ekstreSatir, setEkstreSatir] = useState<ListeSatiri | null>(null);
  useEffect(() => { setEkstreSatir(null) }, [ekstre?.id]);
  /**
   * Ekstre satirindan onu URETEN kayda gider: once kasa islemi, yoksa belge.
   * `yalnizBelge` (Başvuru Aç) tahsilat kartini degil DOGRUDAN belgeyi acar -
   * dugmenin adi belge vaat ediyor. Acilacak kayit yoksa false doner.
   */
  const ekstreSatirinaGit = (satir: ListeSatiri, yalnizBelge = false): boolean => {
    const kasaId = Number(satir.kasaIslemId ?? 0);
    const belgeId = Number(satir.belgeId ?? 0);
    if (belgeId && (yalnizBelge || !kasaId)) { setAcikBelgeId(belgeId); return true }
    if (!yalnizBelge && kasaId) { setAcikKasaId(kasaId); return true }
    return false;
  };
  // Ekstre dugmesinin aktifligi icin gridden gelen secili satir.
  const [seciliSatir, setSeciliSatir] = useState<ListeSatiri | null>(null);
  // Ekstreden donunce ayni satiri yeniden isaretlemek icin - grid unmount
  //   olurken secim null'a duser, o yuzden SON DOLU deger ayrica saklanir.
  const [sonSeciliId, setSonSeciliId] = useState<number | null>(null);
  /**
   * Ekstreden donunce ayni cip (Aktif/Pasif/Tumu) secili kalsin.
   *
   * URL FILTRESIYLE gelindiyse (ör. /hakedis-satir?hakedisId=7) kayit kumesi
   * ZATEN daraltilmistir; ustune bir durum cipi (Acik/Aktif) binince grid
   * bos gorunuyordu. Boyle bir acilista suzgecsiz SON cip ("Tümü") secilir -
   * son cipin filtresi yoksa, yani gercekten hepsini gosteriyorsa.
   */
  const cipler = tanim.cipler;
  const suzgecsizCip = cipler && cipler.length > 1 && !cipler[cipler.length - 1].filtre
    ? cipler.length - 1 : null;
  const [cipIndeks, setCipIndeks] = useState(() => (
    urlDegeri && suzgecsizCip !== null ? suzgecsizCip : 0));

  /**
   * URL FILTRESI SONRADAN GELIRSE de suzgecsiz cipe gec.
   *
   * Yukaridaki `useState` baslatici YALNIZ ILK RENDER'da calisir; oysa bu
   * ekranlara cogunlukla SPA ICI gecisle gelinir (Hakedişler > "Satırları
   * Gör" -> /hakedis-satir?hakedisId=4). O gecişte bilesen ayakta kaliyor,
   * cip eski degerinde ("Kesin") duruyordu ve kapatilmis hakedisin satirlari
   * ONAYLI oldugu icin grid "Kayıt yok" gosteriyordu: kullanici hakedisi
   * kapatir, satirlarina bakar ve HICBIR SEY GOREMEZ.
   */
  useEffect(() => {
    if (urlDegeri && suzgecsizCip !== null) setCipIndeks(suzgecsizCip);
  }, [urlDegeri, suzgecsizCip]);

  // RANDEVU TAKVIMI (243) ayarlari: takvim saat araligi/calisma gunleri
  //   Randevu Ayarlari ekranindan (referans) gelir.
  const [randevuAyarlari, setRandevuAyarlari] = useState<{
    baslangicSaat?: string; bitisSaat?: string; slotDk?: number; calismaGunleri?: number[];
  }>({});
  // RANDEVU (251, kullanici: "bu bölüm ve hekimler randevu listesi üst tarafta
  //   tarih sağında listelenip filtrelensin"): tek uctan hem bolum hem hekim
  //   listesi gelir (Randevu Ayarlari > Bölümler ile ayni kaynak).
  const [randevuAgaci, setRandevuAgaci] = useState<RandevuBolumDugumu[]>([]);
  const [bolumSuzgec, setBolumSuzgec] = useState<number | ''>('');
  /**
   * PERSONEL SERIT SUZGECLERI (kullanici: "aktif/pasif/durum saginda Bolum
   * agac combo ve Rol combo"). Randevununkinden AYRI durum: o ekranda secim
   * takvimi de suruyor, buradaki yalniz gridi suzer.
   */
  const [personelBolum, setPersonelBolum] = useState<{ id: number; agac: number[] } | null>(null);
  const [personelRol, setPersonelRol] = useState<number | ''>('');
  const [roller, setRoller] = useState<{ id: number; ad: string }[]>([]);
  const { yetki } = useOturum();
  // Rol listesi `rol` yetkisi ister; yetkisi olmayanda combo hic cizilmez -
  //   403 alip bos combo gostermektense sormuyoruz.
  const rolSuzgeciVar = !!tanim.rolSuzgeci && yetki('rol');
  useEffect(() => {
    if (!rolSuzgeciVar) { setRoller([]); return }
    void guvenli(async () => {
      const y = await api.liste('rol', { sayfa: 1, boyut: 500 });
      setRoller((y.satirlar ?? [])
        .filter(r => Number(r.aktif ?? 1) === 1)
        .map(r => ({ id: Number(r.id), ad: String(r.ad ?? '') })));
    });
  }, [rolSuzgeciVar]);
  // Liste degisince secimler sifirlanir: yeni kaynakta o alanlar yok.
  useEffect(() => { setPersonelBolum(null); setPersonelRol('') }, [tanim.kaynak]);

  /**
   * HAKEDIS SATIRLARI SERIT SUZGECLERI (kullanici: "tarihin sagina Prim Rolu
   * combo ve onun da sagina Kisi filtre"). Kisi listesi SECILI ROLE gore
   * daralir - "Raporlayan" secildiginde raporlamayan kisiyi listelemek,
   * secilince bos grid vermekten baska ise yaramaz.
   */
  const [primRol, setPrimRol] = useState<number | ''>('');
  const [primKisi, setPrimKisi] = useState<number | ''>('');
  const [primRolleri, setPrimRolleri] = useState<{ id: number; ad: string; adet: number }[]>([]);
  const [primKisiler, setPrimKisiler] = useState<{ id: number; ad: string; adet: number }[]>([]);
  /** Griddeki tarih araligi (GenGrid bildirir) - secenekler buna gore uretilir. */
  const [primAralik, setPrimAralik] = useState<{ bas: string; bit: string }>({ bas: '', bit: '' });
  const primAraligiBildir = useCallback((bas: string, bit: string) => {
    setPrimAralik(o => (o.bas === bas && o.bit === bit ? o : { bas, bit }));
  }, []);
  // Secenekler ARALIKTAKI SATIRLARDAN gelir (kullanici: "tum kisiler ve tum
  //   roller listesine o tarihler arasinda olanlar gelsin") - rol/aday
  //   tanimlarindan degil. Boylece combo'da secilince bos grid veren secenek
  //   olmaz. Kisi listesi ayrica secili role gore daralir.
  useEffect(() => {
    if (!tanim.primSuzgeci) return;
    void guvenli(async () => {
      const y = await api.hakedisSuzgecSecenekleri(
        primAralik.bas || undefined, primAralik.bit || undefined,
        primRol === '' ? undefined : primRol);
      setPrimRolleri(y.roller ?? []);
      setPrimKisiler(y.kisiler ?? []);
    });
  }, [tanim.primSuzgeci, primAralik.bas, primAralik.bit, primRol]);
  // Aralik/rol degisince secim listede kalmayabilir: filtre sessizce bos grid
  //   verirdi - secimi birakmak yerine temizliyoruz.
  useEffect(() => {
    if (primKisi !== '' && primKisiler.length > 0 && !primKisiler.some(k => k.id === primKisi))
      setPrimKisi('');
  }, [primKisiler, primKisi]);
  useEffect(() => {
    if (primRol !== '' && primRolleri.length > 0 && !primRolleri.some(r => r.id === primRol))
      setPrimRol('');
  }, [primRolleri, primRol]);
  useEffect(() => { setPrimRol(''); setPrimKisi('') }, [tanim.kaynak]);

  /**
   * BASVURU SERIT SUZGECLERI (kullanici): hazir tarih araligi, Odeyen kurum,
   * Bolum agaci ve Doktor. Dordu de sunucuda suzer ve sabit filtreye AND'lenir.
   *
   * Tarih HAZIR ARALIK olarak secilir (Bugun / Son 3 gun / Bu yil...): kabul
   * ekraninda iki tarih kutusu doldurmak yerine tek tiklama.
   */
  // Acilista BUGUN (kullanici): kabul ekraninda gunun basvurulari beklenir,
  //   tum gecmis bir arada anlamsizdi.
  const [bvTarih, setBvTarih] = useState<TarihOnAyar | ''>('bugun');
  const [bvOdeyen, setBvOdeyen] = useState<number | ''>('');
  const [bvBolum, setBvBolum] = useState<{ id: number; agac: number[] } | null>(null);
  const [bvDoktor, setBvDoktor] = useState<number | ''>('');
  // CIPLERIN YERINE UC COMBO (kullanici): Tamamlanma, Tahsilat, Donusum.
  //   Donusum'un secenekleri eski ciplerin ta kendisi (kapanma_durum).
  const [bvTamamlanma, setBvTamamlanma] = useState<'' | 'tamam' | 'devam'>('');
  const [bvTahsilat, setBvTahsilat] = useState<'' | '0' | '1' | '2'>('');
  const [bvDonusum, setBvDonusum] = useState<'' | '0' | '1' | '2'>('');
  const [bvKurumlar, setBvKurumlar] = useState<{ id: number; ad: string; adet: number }[]>([]);
  const [bvBolumler, setBvBolumler] = useState<{ id: number; ad: string; adet: number }[]>([]);
  const [bvDoktorlar, setBvDoktorlar] = useState<{ id: number; ad: string; adet: number }[]>([]);
  // Secenekler ARALIKTAKI BASVURULARDAN gelir (kullanici: "bu filtrelere o
  //   tarih araligindaki yer alan item'lar gelsin") - tanim tablolarindan
  //   degil. Tarih secimi degisince listeler yenilenir.
  useEffect(() => {
    if (!tanim.basvuruSuzgeci) return;
    const aralik = bvTarih === '' ? undefined : tarihAraligi(bvTarih);
    void guvenli(async () => {
      const y = await api.basvuruSuzgecSecenekleri(aralik?.bas, aralik?.bit);
      setBvKurumlar(y.odeyenler ?? []);
      setBvBolumler(y.bolumler ?? []);
      setBvDoktorlar(y.doktorlar ?? []);
    });
  }, [tanim.basvuruSuzgeci, bvTarih]);
  // Aralik degisince listede kalmayan secim temizlenir: filtre sessizce bos
  //   liste verirdi.
  useEffect(() => {
    if (bvOdeyen !== '' && bvKurumlar.length > 0 && !bvKurumlar.some(k => k.id === bvOdeyen))
      setBvOdeyen('');
  }, [bvKurumlar, bvOdeyen]);
  useEffect(() => {
    if (bvDoktor !== '' && bvDoktorlar.length > 0 && !bvDoktorlar.some(d => d.id === bvDoktor))
      setBvDoktor('');
  }, [bvDoktorlar, bvDoktor]);
  useEffect(() => {
    setBvTarih('bugun'); setBvOdeyen(''); setBvBolum(null); setBvDoktor('');
    setBvTamamlanma(''); setBvTahsilat(''); setBvDonusum('');
  }, [tanim.kaynak]);
  /** Takvimde fareyle secilen aralik (251): "＋ Yeni" bunu karta tasir. */
  /** Belge olusturmada sube: oturumun calisma subesi. */
  const oturumSubeId = Number(localStorage.getItem('gentegre.sube')) || undefined;
  const [takvimAralik, setTakvimAralik] =
    useState<{ baslangic: string; sureDk: number; hekimId?: number;
               cihazId?: number } | null>(null);
  /**
   * RADYOLOJI CIHAZLARI (316): takvimin "Cihaz" gorunumunun sutunlari.
   * Radyoloji kurulu degilse liste bos doner, buton da cikmaz.
   */
  const [cihazSecenekleri, setCihazSecenekleri] =
    useState<{ id: number; ad: string }[]>([]);
  const [hekimSuzgec, setHekimSuzgec] = useState<number | ''>('');
  useEffect(() => {
    if (tanim.kaynak !== 'randevu') return;
    let iptal = false;
    api.randevuBolumleri()
      .then(y => { if (!iptal) setRandevuAgaci(y) })
      .catch(() => { /* bolum listesi okunamazsa suzgecler bos kalir */ });
    return () => { iptal = true };
  }, [tanim.kaynak]);

  useEffect(() => {
    if (tanim.kaynak !== 'randevu') return;
    let iptal = false;
    api.ayarlar().then(liste => {
      if (iptal) return;
      const bul = (a: string) => liste.find(x => x.anahtar === a)?.deger ?? '';
      const gunler = bul('randevu.calisma_gunleri')
        .split(',').map(x => Number(x.trim())).filter(x => x >= 1 && x <= 7);
      setRandevuAyarlari({
        baslangicSaat: bul('randevu.baslangic_saat') || undefined,
        bitisSaat: bul('randevu.bitis_saat') || undefined,
        slotDk: Number(bul('randevu.slot_dk')) || undefined,
        calismaGunleri: gunler.length ? gunler : undefined,
      });
    }).catch(() => { /* ayar okunamazsa takvim varsayilanla calisir */ });
    return () => { iptal = true };
  }, [tanim.kaynak]);

  /**
   * Randevu suzgecleri (251) gride ve takvime AYNI kosulu verir: ust seritte
   * ne seciliyse alttaki takvim de onu gosterir - iki ayri suzgec kafa karistirir.
   */
  /** Kategori secimi sabit filtreye AND'lenir - cip ve arama ile birlikte. */
  const kategoriliFiltre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    if (!kategoriDal || kategoriDal.agac.length === 0) return temel;
    const kosul: Kosul = {
      alan: tanim.kategoriSuzgecAlani ?? 'kategori',
      op: 'icinde', deger: kategoriDal.agac,
    };
    return temel ? { op: 'and', kosullar: [temel, kosul] } : kosul;
  }, [kategoriDal, tanim.kategoriSuzgecAlani]);

  /** Bolum/rol secimleri de sabit filtreye AND'lenir (cip ve arama ile birlikte). */
  const personelliFiltre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    if (!tanim.bolumSuzgeci && !tanim.rolSuzgeci) return temel;   // bkz. basvuruluFiltre
    const kosullar: Kosul[] = [];
    if (temel) kosullar.push(temel);
    // Bolum: secilen dal + TUM ALT BIRIMLERI.
    if (personelBolum && personelBolum.agac.length > 0)
      kosullar.push({ alan: 'departmanId', op: 'icinde', deger: personelBolum.agac });
    if (personelRol !== '')
      kosullar.push({ alan: 'rolId', op: 'esit', deger: personelRol });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [tanim.bolumSuzgeci, tanim.rolSuzgeci, personelBolum, personelRol]);

  /** Prim rolu / kisi secimi de sabit filtreye AND'lenir. */
  const primliFiltre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    if (!tanim.primSuzgeci) return temel;          // bkz. basvuruluFiltre
    const kosullar: Kosul[] = [];
    if (temel) kosullar.push(temel);
    if (primRol !== '') kosullar.push({ alan: 'rol', op: 'esit', deger: primRol });
    if (primKisi !== '') kosullar.push({ alan: 'tarafId', op: 'esit', deger: primKisi });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [tanim.primSuzgeci, primRol, primKisi]);

  /**
   * DOKUMAN SOL PANELI (419): secilen klasor listeye SABIT FILTRE olarak gecer.
   *
   * Kurumsal klasor `klasorId` ile, KAYNAK klasoru `kaynak` ile suzulur -
   * ikisi ayri alan cunku kaynak klasoru SANALDIR (tablo kaydi yok, dokumanin
   * kaynak alanindan turer).
   */
  const [klasorSecim, setKlasorSecim] = useState<KlasorSecimi>({ tur: 'tum', ad: 'Tümü' });

  const klasorluFiltre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    if (tanim.kaynak !== 'dokuman' || klasorSecim.tur === 'tum') return temel;
    const kosul: Kosul = klasorSecim.tur === 'klasor'
      ? { alan: 'klasorId', op: 'esit', deger: klasorSecim.id ?? 0 }
      : { alan: 'kaynak', op: 'esit', deger: klasorSecim.kod ?? '' };
    return temel ? { op: 'and', kosullar: [temel, kosul] } : kosul;
  }, [tanim.kaynak, klasorSecim]);

  /** Basvuru suzgecleri: tarih araligi + odeyen + bolum agaci + doktor. */
  const basvuruluFiltre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    // SUZGEC KAPALI EKRANDA HIC KOSUL EKLENMEZ: durumlar Liste bileseninde
    //   yasadigi icin baska bir listeye gecildiginde de doluydu ve tarih
    //   varsayilani 'bugun' oldugu icin KOSUL HEP VARDI - hasta listesi
    //   "Bilinmeyen alan: belgeTarihi" ile 400 donuyordu.
    if (!tanim.basvuruSuzgeci) return temel;
    const kosullar: Kosul[] = [];
    if (temel) kosullar.push(temel);
    if (bvTarih !== '') {
      const { bas, bit } = tarihAraligi(bvTarih);
      kosullar.push({ alan: 'belgeTarihi', op: 'arasinda', deger: [bas, bit] });
    }
    if (bvOdeyen !== '') kosullar.push({ alan: 'odeyenKurumId', op: 'esit', deger: bvOdeyen });
    // Bolum: secilen dal + TUM ALT BIRIMLERI (agac combosu).
    if (bvBolum && bvBolum.agac.length > 0)
      kosullar.push({ alan: 'bolumId', op: 'icinde', deger: bvBolum.agac });
    if (bvDoktor !== '') kosullar.push({ alan: 'doktorId', op: 'esit', deger: bvDoktor });
    // Tamamlanma: %100 tamamlandi ya da altindaki her sey "devam ediyor".
    if (bvTamamlanma === 'tamam')
      kosullar.push({ alan: 'tamamlanma', op: 'esit', deger: 100 });
    if (bvTamamlanma === 'devam')
      kosullar.push({ alan: 'tamamlanma', op: 'kucuk', deger: 100 });
    if (bvTahsilat !== '')
      kosullar.push({ alan: 'tahsilatDurum', op: 'esit', deger: Number(bvTahsilat) });
    if (bvDonusum !== '')
      kosullar.push({ alan: 'kapanmaDurum', op: 'esit', deger: Number(bvDonusum) });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [tanim.basvuruSuzgeci, bvTarih, bvOdeyen, bvBolum, bvDoktor,
      bvTamamlanma, bvTahsilat, bvDonusum]);

  const randevuFiltresi = useMemo<Kosul | undefined>(() => {
    if (tanim.kaynak !== 'randevu') return sabitFiltre;
    const kosullar: Kosul[] = [];
    if (sabitFiltre) kosullar.push(sabitFiltre);
    if (bolumSuzgec !== '') kosullar.push({ alan: 'bolum', op: 'esit', deger: bolumSuzgec });
    if (hekimSuzgec !== '') kosullar.push({ alan: 'hekimId', op: 'esit', deger: hekimSuzgec });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [tanim.kaynak, sabitFiltre, bolumSuzgec, hekimSuzgec]);

  /**
   * BEKLEYEN İSTEME RANDEVU (316): panelden sürükle-bırak ve "seç + boş saate
   * tıkla" yollarının ortak ucu. Süre istemin çekim protokolünden (314) gelir;
   * çakışma/kapasite/cihaz kapatma kuralları veritabanı tetiğindedir - buradan
   * tekrar kontrol edilmez, hata mesajı olduğu gibi gösterilir.
   */
  const bekleyeneRandevuVer = async (
    istem: BekleyenIstem, baslangic: string, cihazId?: number,
  ) => {
    if (!cihazId) {
      mesaj('Randevu cihaza verilir - takvimde bir cihaz sütunu seçin.');
      return;
    }
    const ok = await guvenli(() => api.radyolojiRandevuVer(istem.id, {
      cihazId, baslangic,
      sureDk: istem.sureDk > 0 ? istem.sureDk : undefined,
    }));
    if (!ok) return;
    mesaj(`Randevu verildi: ${istem.hasta} · ${baslangic.slice(11)} `
          + `(${istem.accessionNo})`);
    setBekleyenSecili(null);
    setYenile(t => t + 1);
  };

  /**
   * Takvimin kullanacagi ayar: HEKIM -> BÖLÜM -> Genel Ayarlar sirasiyla
   * miras alinir (251). Hekim ogle arasini degistirdiyse takvim o hekim
   * secildiginde onu gostermeli - yoksa bolum duzeni sanilir.
   */
  const takvimAyarlari = useMemo(() => {
    const bolumDugum = bolumSuzgec === '' ? undefined
      : randevuAgaci.find(d => d.departmanId === bolumSuzgec);
    const hekimAyar = hekimSuzgec === ''
      ? undefined
      : (bolumDugum ?? randevuAgaci.find(d => d.hekimler.some(h => h.hekimId === hekimSuzgec)))
          ?.hekimler.find(h => h.hekimId === hekimSuzgec);
    const oncelikli = (...adaylar: (string | number | null | undefined)[]) =>
      adaylar.find(v => v !== '' && v !== null && v !== undefined);
    const gunler = String(oncelikli(hekimAyar?.calismaGunleri, bolumDugum?.ayar.calismaGunleri) ?? '')
      .split(',').map(x => Number(x.trim())).filter(x => x >= 1 && x <= 7);
    return {
      ...randevuAyarlari,
      baslangicSaat: oncelikli(hekimAyar?.baslangicSaat, bolumDugum?.ayar.baslangicSaat) as string
                     ?? randevuAyarlari.baslangicSaat,
      bitisSaat: oncelikli(hekimAyar?.bitisSaat, bolumDugum?.ayar.bitisSaat) as string
                 ?? randevuAyarlari.bitisSaat,
      slotDk: (oncelikli(hekimAyar?.slotDk, bolumDugum?.ayar.slotDk) as number)
              ?? randevuAyarlari.slotDk,
      calismaGunleri: gunler.length ? gunler : randevuAyarlari.calismaGunleri,
    };
  }, [randevuAgaci, randevuAyarlari, bolumSuzgec, hekimSuzgec]);

  /** Bolum secilince hekim listesi o bolume daralir. */
  const hekimSecenekleri = useMemo(() => {
    const dugumler = bolumSuzgec === ''
      ? randevuAgaci
      : randevuAgaci.filter(d => d.departmanId === bolumSuzgec);
    // Hekimin BOLUMU de tasinir: takvimde bir hekim sutununda saat secilince
    //   kartta bolum de dolu gelsin (kullanici: "dr bolumu belli, kartta
    //   bolumu doldursun").
    return dugumler.flatMap(d =>
      d.hekimler.map(h => ({ id: h.hekimId ?? 0, ad: h.ad, bolum: d.departmanId })));
  }, [randevuAgaci, bolumSuzgec]);

  // Cihaz listesi randevu ekraninda bir kez cekilir; yetki/veri yoksa sessiz
  //   gecilir - poliklinik kurulumunda cihaz olmamasi hata degildir.
  useEffect(() => {
    if (tanim.kaynak !== 'randevu') return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('radyoloji-cihaz', {
          sayfa: 1, boyut: 50,
          filtre: { op: 'and', kosullar: [
            { alan: 'durum', op: 'esit', deger: 1 },
            { alan: 'randevuVerilir', op: 'esit', deger: 1 },
          ] },
        });
        if (!iptal)
          setCihazSecenekleri(y.satirlar.map(r => ({
            id: Number(r.id), ad: String(r.ad ?? r.kod ?? ''),
          })));
      } catch { /* radyoloji yok ya da yetki yok - cihaz gorunumu cikmaz */ }
    })();
    return () => { iptal = true };
  }, [tanim.kaynak]);

  /** Hekimin bolumu (takvim sutunundan gelen hekim icin). */
  const hekimBolumu = (hekim?: number) =>
    hekim ? hekimSecenekleri.find(h => h.id === hekim)?.bolum : undefined;

  /**
   * AKSIYON YONLENDIRME - grid arac cubugu ve sag tus menusu buraya duser.
   *
   * Fonksiyon 950 satira ve 44 case'e ulasmisti; konu bazli bloklar AYRI
   * dosyalara alindi (refactor) ve burada sirayla deneniyor:
   *     liste/utsAksiyonlari · liste/kasaAksiyonlari
   *     liste/fiyatListesiAksiyonlari · liste/ebelgeAksiyonlari
   * Her modul "ele aldim mi" doner; ele aldiysa burada isimiz biter. e-Belge
   * CIKTILARI (onizleme/XML/PDF) ve gelen belge adimlari zaten ayriydi
   * (ebelgeIslem / gelenBelgeIslem) - ayni desen surduruldu.
   *
   * Burada kalanlar: belge/kart acma, silme, donusum, randevu akisi, radyoloji
   * ve listeye ozel tek tuk isler - hepsi ekranin kendi state'ine sikica bagli.
   */
  async function aksiyon(kod: string, satir?: ListeSatiri | null,
                         secililer?: ListeSatiri[]) {
    const kartaGit = (kayitId: unknown) => git(`${tanim.kartYolu}/${kayitId}`);

    try {
      // TOPLU ISLEM (183): birden fazla satir seciliyken Hazırla/Gönder tek
      //   istekte calisir. Sonuc satir satir raporlanir - bir belgenin hatasi
      //   digerlerini durdurmaz.
      if (secililer && secililer.length > 1
          && (kod === 'ebelge.hazirla' || kod === 'ebelge.gonder')) {
        const islem = kod === 'ebelge.hazirla' ? 'hazirla' : 'gonder';
        const ad = islem === 'hazirla' ? 'hazırlanacak' : 'GÖNDERİLECEK';
        if (!await onay(`${secililer.length} belge ${ad}.\n\n`
                      + (islem === 'gonder'
                         ? 'Gönderilen belge geri alınamaz. Onaylıyor musunuz?'
                         : 'Her belgeye seri ve e-Belge numarası verilir. Onaylıyor musunuz?'),
                        islem === 'gonder')) return;
        await guvenli(async () => {
          const y = await api.belgeEBelgeToplu(secililer.map(x => Number(x.id)), islem);
          const olan = y.sonuclar.filter(r => r.basarili).length;
          const olmayan = y.sonuclar.filter(r => !r.basarili);
          mesaj(`${olan} belge tamam, ${olmayan.length} hata.`
              + (olmayan.length
                 ? '\n\n' + olmayan.slice(0, 10)
                     .map(r => `#${r.belgeId}: ${r.mesaj}`).join('\n')
                   + (olmayan.length > 10 ? `\n… ve ${olmayan.length - 10} tane daha` : '')
                 : ''));
          setYenile(t => t + 1);
        });
        return;
      }

      // e-BELGE CIKTILARI (Ön İzle / PDF / HTML / XML / Mesaj Geçmişi) ayri
      //   modulde (180 refaktor): hepsi tek belge id'si alip cikti uretiyor,
      //   listeden bagimsiz. Ele aldiysa switch'e hic girmeyiz.
      // GELEN KUTUSU once: oradaki id e_belge kaydidir, belge id'si degil -
      //   ayni "ebelge.*" kodlari farkli uclara gider.
      if (tanim.kaynak === 'gelen-belge'
          && await gelenBelgeAksiyonu(kod, satir ?? null, () => setYenile(t => t + 1),
                                      setEBelgeMesajlari)) return;

      if (satir && await ebelgeCiktisi(kod, satir, setEBelgeMesajlari,
                                       () => setYenile(t => t + 1))) return;

      // DONUSUM ALT MENUSU: "belge.donustur.15" gibi kodlarda hedef tur
      //   kodun icinde gelir ve karta KILITLI gecer.
      if (kod.startsWith('belge.donustur.') && satir) {
        setDonusum({
          belgeId: Number(satir.id),
          belgeTur: Number(satir.tur),
          hedef: Number(kod.slice('belge.donustur.'.length)),
        });
        return;
      }

      // KONU BAZLI AKSIYONLAR ayri dosyalarda (refactor): `aksiyon()` 950
      //   satira ve 44 case'e ulasmisti. Her modul "ele aldim mi" doner;
      //   ele aldiysa burada isimiz biter. e-Belge ve gelen belge zaten
      //   ayriydi (ebelgeIslem / gelenBelgeIslem) - ayni desen surduruldu.
      if (await utsAksiyonu(kod, satir, secililer, {
        tazele: () => setYenile(t => t + 1),
        setUtsHazirla, setUtsKullanim, setUtsGenel, setUtsAlma,
      })) return;

      if (await zamanliIsAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await dokumanAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await enabizAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await hekimListesiAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await muayeneAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await ilacAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await bildirimAksiyonu(kod, satir, secililer, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await kasaAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        setKasaTuru, setCekTuru, setAcikKasaId,
      })) return;

      if (await fiyatListesiAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        setIceriAl,
      })) return;

      if (await ebelgeAksiyonu(kod, satir, { tazele: () => setYenile(t => t + 1) })) return;

      switch (kod) {
        // Grup basina bir giris: kart tur seridini o grubun turleriyle acar.
        case 'belge.yeni': setYeniBelgeTuru(tanim.yeniBelgeTuru ?? 15); return;
        case 'belge.ac':
          if (satir) setAcikBelgeId(Number(satir.id));
          return;
        // e-BELGE HAZIRLA (163): numara/seri verir ve kuyruga alir. Sonuc
        //   mesaji sunucudan gelir (hangi tur, hangi numara) - istemci karar
        //   uretmez, yalniz gosterir.
        // MUHASEBE FISI (190): belgenin fis satirlarini acar. Fis kartı ayri
        //   bir ekran degil - "Fiş Satırları" listesi fisId ile filtrelenir.
        case 'belge.fis-gor': {
          if (!satir) return;
          const fisId = Number(satir.fisId ?? 0);
          if (!fisId) { mesaj('Belgenin muhasebe fişi yok.'); return }
          git(`/muhasebe-fis-satir?fisId=${fisId}`);
          return;
        }
        // DONUSUM ZINCIRI (F8): kaynak ve hedef belge ayni modal kartta acilir.
        case 'belge.kaynak-ac':
        case 'belge.hedef-ac': {
          if (!satir) return;
          const hedef = Number(kod === 'belge.kaynak-ac' ? satir.kaynakId : satir.hedefId) || 0;
          if (!hedef) {
            mesaj(kod === 'belge.kaynak-ac'
              ? 'Bu belge bir dönüşümden gelmiyor.'
              : 'Bu belgeden üretilmiş bir belge yok.');
            return;
          }
          setAcikBelgeId(hedef);
          return;
        }
        // BELGE SIL (181): izi olmayan belgede mumkun; kesin/izli belgede
        //   aksiyon zaten pasif ve sebebi title'da. Sunucu son sozu soyler.
        case 'belge.sil': {
          if (!satir) return;
          const no = String(satir.belgeNo ?? satir.id);
          if (!await onay(`"${no}" silinecek.

Bu işlem geri alınamaz. `
                        + 'Onaylıyor musunuz?', true)) return;
          await guvenli(async () => {
            const y = await api.belgeSil(Number(satir.id));
            mesaj(y.mesaj || 'Belge silindi.');
            setYenile(t => t + 1);
          });
          return;
        }
        // CARI MUKELLEFIYET SORGUSU (183): entegratore sorar, bayragi isler.
        //   Gelen unvan/adres YALNIZ GOSTERILIR - musterinin kendi kaydi
        //   entegratorun yazimiyla ezilmemeli.
        case 'cari.ebelge-mukellef': {
          if (!satir) return;
          await guvenli(async () => {
            const y = await api.cariEBelgeMukellef(Number(satir.id));
            const satirlar = [
              String(y.kayitli.unvan || satir.unvan || ''),
              '',
              'GİB kaydı: ' + (y.mukellef
                ? 'e-Fatura MÜKELLEFİ' : 'kayıtlı değil (e-Arşiv kesilir)') + ' — ' + y.durum,
            ];
            if (y.degisti) satirlar.push('Cari kartındaki bayrak güncellendi.');
            // GIB'den gelen unvan/adres YALNIZ GOSTERILIR: musterinin kendi
            //   kaydi entegratorun yazimiyla ezilmemeli.
            if (y.gelen.unvan) {
              satirlar.push('', 'GİB’deki bilgiler:', y.gelen.unvan);
              if (y.gelen.vergiDairesi) satirlar.push(y.gelen.vergiDairesi);
              if (y.gelen.il) satirlar.push(`${y.gelen.adres} ${y.gelen.ilce} / ${y.gelen.il}`);
            }
            mesaj(satirlar.join('\n'));
            setYenile(t => t + 1);
          });
          return;
        }
        case 'belge.donustur':
          if (!satir) return;
          // Teklif (18) yalniz KABUL (3) durumundayken donusur - sunucu da
          //   ayni kurali dogrular, burasi erken/anlasilir uyari.
          if (Number(satir.tur) === 18 && Number(satir.teklifDurum ?? 1) !== 3) {
            mesaj('Teklif yalnız KABUL durumundayken siparişe dönüştürülebilir.');
            return;
          }
          setDonusum({ belgeId: Number(satir.id), belgeTur: Number(satir.tur) });
          return;
        // Secili hesabin ekstresi - ayni ekran, hesapId sorgu parametresiyle.
        case 'hesap.ekstre':
          if (satir) git(`/hesap-ekstre?hesapId=${satir.id}`);
          return;
        // ADAY -> MÜŞTERİ (122): kayit TASINMAZ, yalniz rol bayragi degisir.
        //   Boylece firsat/gorev/adres/ilgili kisi gecmisi ayni kayitta kalir;
        //   yeni bir cari acilsaydi butun bu baglar kirilirdi.
        case 'aday.donustur': {
          if (!satir) return;
          const ad = String(satir.unvan ?? satir.ad ?? satir.id);
          if (!await onay(`"${ad}" müşteriye dönüştürülsün mü?

` +
                       "Kayıt Müşteri Listesi'ne geçer; fırsat, görev ve adres geçmişi aynı kalır.")) return;
          void guvenli(async () => {
            const k = await api.kartOku('cari', Number(satir.id));
            await api.kartGuncelle('cari', Number(satir.id),
              { surum: k.kart.surum as string | undefined,
                kart: { musteri: true, aday: false } });
            setYenile(y => y + 1);
          });
          return;
        }
        // STOK KARTI KOPYALA (126): kopya olusur ve HEMEN acilir - kullanici
        //   zaten degistirmek icin kopyaliyor, listeye donup aramasi gereksiz.
        case 'stok.kopyala': {
          if (!satir) return;
          const ad = String(satir.ad ?? satir.kod ?? satir.id);
          if (!await onay(`"${ad}" kartı kopyalanacak.\n\n`
                     + 'Kod sonuna "_K1", ad sonuna " kopya" eklenir; paket ise içeriği de kopyalanır.\n'
                     + 'Fiyat ve barkod kopyalanmaz.')) return;
          const yeniId = await api.stokKopyala(Number(satir.id));
          setYenile(t => t + 1);
          kartaGit(yeniId);
          return;
        }
        // FIYAT LISTESI URETIMI (202): kurali yeniden isletip satirlari yazar.
        //   Onay ISTENIR - binlerce satiri degistirir ve taban fiyat degistiyse
        //   liste fiyatlari toptan degisir.
        // ÜTS (223): senkron + alma + iptal + yeniden gonder + detay.
        case 'belge.uts-bildir': {
          // COKLU SECIM desteklenir (230): isaretli belgeler sirayla bildirilir.
          const hedefler = (secililer && secililer.length > 0 ? secililer
                            : satir ? [satir] : []);
          if (hedefler.length === 0) return;
          const adlar = hedefler.length === 1
            ? `"${String(hedefler[0].belgeNo ?? hedefler[0].id)}" belgesinin`
            : `${hedefler.length} belgenin`;
          if (!await onay(`${adlar} seri/lot satırları ÜTS'ye bildirilecek.

Satışta VERME, alışta askıdakilerle eşleşip ALMA yapılır. Onaylıyor musunuz?`)) return;
          await guvenli(async () => {
            let son: Awaited<ReturnType<typeof api.utsBelgedenBildir>> | null = null;
            const ozet: string[] = [];
            for (const h of hedefler) {
              son = await api.utsBelgedenBildir(Number(h.id));
              ozet.push(son.mesaj);
            }
            if (hedefler.length === 1 && son) setUtsBelgeSonuc(son);
            else mesaj(ozet.join('\n'));
            setYenile(t => t + 1);
          });
          return;
        }
      }

      // RANDEVU durum akisi (243) ve BASVURUYA DONUSUM (265). Durum
      //   dugmeleri simdiye kadar bagli DEGILDI - tiklaninca hicbir sey
      //   olmuyordu.
      // KURUM ICMALI (289): SGK payi donem sonu TEK faturaya doner.
      if (kod === 'icmal.yeni') {
        await guvenli(async () => {
          // Soru METINDE, kutu BOS: ikinci parametre varsayilan DEGERDIR -
          //   soruyu oraya yazmak kutuyu hazir doldurup aramayi bozuyordu.
          const kurumAd = await metinSor(
            'İcmal hangi kuruma kesilecek? (ör. SGK)', '', 'Kurum kodu ya da adı');
          if (!kurumAd) return;
          // Kurum kaynaginda ad kolonu 'unvan' ('kurumAdi' icmal kaynaginin
          //   kolonu) - yanlis alan sunucuda "Bilinmeyen alan" hatasi veriyordu.
          // KOD YA DA AD: soru ikisini de kabul ediyor ("SGK" ya da "Sosyal
          //   Güvenlik Kurumu") - yalniz unvana bakinca kodla arayan kullanici
          //   "Kurum bulunamadı" aliyordu.
          const k = await api.liste('kurum', {
            sayfa: 1, boyut: 5,
            filtre: { op: 'or', kosullar: [
              { alan: 'unvan', op: 'icerir', deger: kurumAd },
              { alan: 'kod',   op: 'icerir', deger: kurumAd },
            ] },
          });
          if (k.satirlar.length === 0) { mesaj('Kurum bulunamadı.'); return }
          const kurumId = Number(k.satirlar[0].id);
          const kurumUnvan = String(k.satirlar[0].unvan ?? kurumAd);

          // Donem = icinde bulunulan AY. toISOString UTC'ye cevirdigi icin
          //   yerel gece yarisi bir onceki gune kayiyordu (1 Agustos ->
          //   "07-31"): ayin ilk gunu onceki aya dusup satirlari kacirirdi.
          const bugun = new Date();
          const gun = (t: Date) => `${t.getFullYear()}-`
            + `${String(t.getMonth() + 1).padStart(2, '0')}-`
            + `${String(t.getDate()).padStart(2, '0')}`;
          const bas = gun(new Date(bugun.getFullYear(), bugun.getMonth(), 1));
          const bit = gun(new Date(bugun.getFullYear(), bugun.getMonth() + 1, 0));

          // ONIZLEME: kullanici neyi faturaladigini gormeden icmal acmasin.
          const on = await api.icmalOnizleme(kurumId, bas, bit);
          if (on.satirlar.length === 0) {
            mesaj(`${kurumUnvan} için bu dönemde açık kurum payı yok.`);
            return;
          }
          if (!(await onay(
                `${kurumUnvan} · ${bas} – ${bit}: `
                + `${on.satirlar.length} satır, toplam ${on.toplam.toFixed(2)}. `
                + 'İcmal oluşturulsun mu?'))) return;

          const y = await api.icmalOlustur({ kurumId, donemBas: bas, donemBit: bit });
          setYenile(t => t + 1);
          mesaj(`İcmal oluşturuldu: ${y.satir} satır. "Faturala" ile tek fatura kesilir.`);
        });
        return;
      }

      if (kod === 'icmal.faturala') {
        if (!satir) return;
        if (Number(satir.durum) !== 1) { mesaj('Yalnız hazırlanan icmal faturalanabilir.'); return }
        if (!(await onay(`${satir.kurumAdi} icmali faturalansın mı? `
              + `Toplam ${Number(satir.toplam ?? 0).toFixed(2)} tutarında TEK fatura kesilir `
              + 've satırların kurum payı kapanır.'))) return;
        await guvenli(async () => {
          const y = await api.icmalFaturala(Number(satir.id));
          setYenile(t => t + 1);
          mesaj(`Fatura kesildi (${y.satir} kalem).`);
          setAcikBelgeId(y.belgeId);
        });
        return;
      }

      if (kod === 'icmal.belge') {
        if (!satir?.belgeId) { mesaj('Bu icmal henüz faturalanmamış.'); return }
        setAcikBelgeId(Number(satir.belgeId));
        return;
      }

      // SARF DUSUMU (320): cekim tamamlaninca protokoldeki malzeme onerilir.
      //   Ayri aksiyon olarak da cagrilabilir - cekim sirasinda atlanmis ya da
      //   sonradan duzeltilmesi gereken dusum icin.
      if (kod === 'radyoloji.sarf') {
        if (!satir) return;
        setSarfModali({
          istemId: Number(satir.istemId ?? satir.id),
          accessionNo: String(satir.accessionNo ?? ''),
          tetkikAdi: String(satir.tetkikAdi ?? satir.tetkik ?? ''),
        });
        return;
      }

      // RANDEVU VER (316): istem cihaza baglanir - kayit public.randevu'ya
      //   gider, kaynagi cihazdir. Sure tetkikin protokolunden gelir.
      if (kod === 'radyoloji.randevu') {
        if (!satir) return;
        setRandevuModali({
          istemId: Number(satir.id),
          accessionNo: String(satir.accessionNo ?? ''),
          tetkikAdi: String(satir.tetkikAdi ?? ''),
          modalite: Number(satir.modalite ?? 0),
          sureDk: Number(satir.protokolSure ?? 0),
        });
        return;
      }

      // RADYOLOJI (283): worklist durum akisi. "Cekildi" teknisyenin islemi -
      //   cekim zamani da yazilir, cunku bekleme suresi (kalite gostergesi)
      //   oradan hesaplanir. Iptal onay ister: cekilmis istem iptal edilirse
      //   goruntu ortada kalir.
      if (kod === 'radyoloji.cekildi' || kod === 'radyoloji.iptal') {
        if (!satir) return;
        const iptalMi = kod === 'radyoloji.iptal';
        if (iptalMi && !(await onay(
              `${String(satir.accessionNo ?? '')} istemi iptal edilsin mi? `
              + 'Çekim yapıldıysa görüntü ve rapor kaydı yerinde kalır.'))) return;
        await guvenli(async () => {
          const mevcut = await api.kartOku('radyoloji-istem', Number(satir.id));
          await api.kartGuncelle('radyoloji-istem', Number(satir.id), {
            surum: mevcut.kart.surum,
            kart: iptalMi
              ? { durum: 0 }
              // ÇEKIM ZAMANI YEREL saat: toISOString UTC verir, TR'de kayit
              //   3 saat GERIYE dusuyordu - bekleme suresi (istem->cekim)
              //   kalite gostergesi buradan hesaplaniyor, negatif bile cikabilir.
              : { durum: 2, cekimTarihi: yerelZamanDamgasi() },
          });
          setYenile(t => t + 1);
          mesaj(iptalMi ? 'İstem iptal edildi.' : 'İstem "Çekildi" olarak işaretlendi.');
          // SARF DUSUMU (320): cekim tamamlandi - protokolde malzeme tanimliysa
          //   onay penceresi acilir. Iptalde acilmaz; sarf ayari kapaliysa ya da
          //   liste bossa modal kendi kendini "tanimli degil" diye anlatir.
          if (!iptalMi) {
            try {
              const sarf = await api.radyolojiSarf(Number(satir.id));
              if (sarf.aktif && (sarf.satirlar ?? []).length > 0)
                setSarfModali({
                  istemId: Number(satir.id),
                  accessionNo: String(satir.accessionNo ?? ''),
                  tetkikAdi: String(satir.tetkikAdi ?? satir.tetkik ?? ''),
                });
            } catch { /* sarf okunamazsa cekim isaretlemesi yine gecerli */ }
          }
        });
        return;
      }

      // YENI ISTEM (304): generic kart TEK tetkik acardi; istem ekrani coklu
      //   tetkik secer, klinik bilgiyi hepsine gecer ve basvuruya ucret
      //   satirlarini ekler. Listeden acildiginda DIS istem varsayilir -
      //   hastanin kendi hekimi yoksa disaridan gelmistir; ic istem basvuru
      //   kartindan acilir.
      if (kod === 'radyoloji.yeni') {
        setIstemHastaArama(true);
        return;
      }

      // KRITIK BULGU TAKIBI (318): bildirim ve kapatma AYRI islemdir -
      //   kapatma "karsi taraf teyit etti" demektir, bildirim yoksa kapatilacak
      //   bir sey de yoktur (sunucu da reddeder).
      if (kod === 'radyoloji.kritik-bildir') {
        if (!satir) return;
        setKritikModali({
          istemId: Number(satir.istemId ?? satir.id),
          accessionNo: String(satir.accessionNo ?? ''),
          hasta: String(satir.hasta ?? ''),
          tetkik: String(satir.tetkik ?? ''),
          bulgu: String(satir.bulgu ?? ''),
          bildirilenAd: String(satir.bildirilen ?? ''),
        });
        return;
      }

      if (kod === 'radyoloji.kritik-kapat') {
        if (!satir) return;
        if (!await onay('Kritik bulgu takibi kapatılsın mı? Kapatma, bildirimin '
                        + 'yapıldığı ve karşı tarafın teyit ettiği anlamına gelir.'))
          return;
        await guvenli(async () => {
          await api.radyolojiKritikKapat(Number(satir.istemId ?? satir.id));
          mesaj('Kritik bulgu takibi kapatıldı.');
          setYenile(t => t + 1);
        });
        return;
      }

      // KONSULTASYON CEVABI (318): cevabi cogunlukla BASKA biri yazar - istek
      //   rapor ekranindan, cevap bu listeden gelir.
      if (kod === 'radyoloji.konsultasyon-cevap') {
        if (!satir) return;
        setKonsultasyonModali({
          istemId: Number(satir.istemId),
          konsultasyonId: Number(satir.id),
          accessionNo: String(satir.accessionNo ?? ''),
          hasta: String(satir.hasta ?? ''),
          tetkik: String(satir.tetkik ?? ''),
          soru: String(satir.gerekce ?? ''),
          gorus: String(satir.gorus ?? ''),
        });
        return;
      }

      // ------------------------------------------------------- PRIM (324) --
      // Hakedis satiri TAHSILATTAN dogar, elle eklenmez: buradaki aksiyonlar
      //   satirin kaynagina gitmek ve donemi kapatmak icindir.
      if (kod === 'hakedis.donem-kapat') {
        setDonemModali(satir
          ? { tarafId: Number(satir.tarafId) || undefined,
              kisi: String(satir.kisi ?? '') }
          : {});
        return;
      }

      // ONAY (330): satiri kilitler. Toplu secim varsa hepsi islenir.
      if (kod === 'hakedis.onayla' || kod === 'hakedis.onay-kaldir') {
        const geriAl = kod === 'hakedis.onay-kaldir';
        const idler = (secililer && secililer.length > 0 ? secililer
                       : satir ? [satir] : []).map(x => Number(x.id));
        if (idler.length === 0) return;
        if (!await onay(geriAl
          ? `${idler.length} prim satırının onayı kaldırılacak. Onaylıyor musunuz?`
          : `${idler.length} prim satırı ONAYLANACAK. Onaylanan satır kilitlenir: `
            + 'rol ya da belge türü sonradan değişse bile prim yeniden hesaplanmaz.'))
          return;
        await guvenli(async () => {
          const y = await api.primOnayla({ satirlar: idler, geriAl });
          mesaj(geriAl
            ? `${y.satirSayisi} satırın onayı kaldırıldı.`
            : `${y.satirSayisi} satır onaylandı (kilitlendi).`);
          setYenile(t => t + 1);
        });
        return;
      }

      if (kod === 'hakedis.roller') {
        if (!satir) return;
        const sid = Number(satir.belgeSatirId ?? 0);
        if (!sid) { mesaj('Satırın kalem bağı yok.'); return }
        setRolModali({ satirId: sid, ad: String(satir.kalem ?? '') });
        return;
      }

      // Belgenin AYRI ROTASI YOK: kart modal olarak bu listenin ustunde acilir
      //   (donusum zincirindeki "kaynak/hedef belgeyi ac" ile ayni desen).
      if (kod === 'hakedis.kalem') {
        if (!satir) return;
        const bid = Number(satir.belgeId ?? 0);
        if (!bid) { mesaj('Satırın belge bağı yok.'); return }
        setAcikBelgeId(bid);
        return;
      }

      // Baslikta "Satirlari Gor": ayni donemin satirlarina hakedis
      //   filtresiyle gecilir.
      if (kod === 'hakedis.satirlar') {
        if (!satir) return;
        git(`/hakedis-satir?hakedisId=${Number(satir.id)}`);
        return;
      }

      // Takip listelerinde satirin kimligi ISTEM'dir: istemi ac.
      if (kod === 'radyoloji.istem-ac') {
        if (!satir) return;
        git(`/radyoloji/${Number(satir.istemId ?? satir.id)}`);
        return;
      }

      if (kod === 'radyoloji.teslim') {
        if (!satir) return;
        setTeslimModali({ istemId: Number(satir.istemId ?? satir.id),
                          accessionNo: String(satir.accessionNo ?? ''),
                          cdIstendi: Number(satir.cdIstendi) === 1 });
        return;
      }

      // Rapor yazma AYRI EKRAN (283): bolumler sablondan uretilir, onay iki
      //   asamalidir - generic karta sigmaz.
      if (kod === 'radyoloji.rapor') {
        if (!satir) return;
        git(`/radyoloji/rapor/${Number(satir.id)}`);
        return;
      }

      /**
       * RADYOLOJI RANDEVUSUNDA "GELDI" = KABUL (317).
       *
       * Hasta cogunlukla kuruma GELMEDEN randevu alir: o an ne basvuru ne
       * odeme ne istem vardir - yalniz plan. Geldigi an kabul edilmeli:
       * basvuru acilir, ucret/tahsilat alinir, ISTEM dogar; cihazin calisma
       * listesine (MWL) dusecek kayit da budur. Bu yuzden cihazli randevuda
       * "Geldi" durumu tek basina yazmak yerine kabul ekranini acar.
       */
      const radyolojiKabulu = (s: ListeSatiri) => {
        setIstemModali({
          hastaId: Number(s.hastaId), hastaAdi: String(s.hasta ?? ''),
          // Isteyen hekim disaridan olabilir - kabul ekraninin tam hali acilir.
          disIstem: true,
          randevuId: Number(s.id),
          hizmetId: Number(s.hizmetId) || undefined,
        });
      };

      if (kod === 'randevu.geldi' && satir && Number(satir.cihazId) > 0
          && !satir.belgeId) {
        if (!Number(satir.hastaId)) { mesaj('Randevuda hasta yok.'); return }
        radyolojiKabulu(satir);
        return;
      }

      if (kod === 'randevu.geldi' || kod === 'randevu.gelmedi' || kod === 'randevu.iptal') {
        if (!satir) return;
        const yeniDurum = kod === 'randevu.geldi' ? 2 : kod === 'randevu.gelmedi' ? 3 : 4;
        await guvenli(async () => {
          const mevcut = await api.kartOku('randevu', Number(satir.id));
          await api.kartGuncelle('randevu', Number(satir.id),
                                 { surum: mevcut.kart.surum, kart: { durum: yeniDurum } });
          setYenile(t => t + 1);
        });
        return;
      }

      if (kod === 'randevu.basvuru') {
        if (!satir) return;
        // CIHAZLI (radyoloji) randevu: duz basvuru yerine kabul ekrani (317) -
        //   basvuru orada da acilir, ustune ISTEM ve accession uretilir.
        if (Number(satir.cihazId) > 0 && !satir.belgeId) {
          if (!Number(satir.hastaId)) { mesaj('Randevuda hasta yok.'); return }
          radyolojiKabulu(satir);
          return;
        }
        await guvenli(async () => {
          const hastaId = Number(satir.hastaId) || 0;
          const hizmetId = Number(satir.hizmetId) || 0;
          if (!hastaId) { mesaj('Randevuda hasta yok.'); return }
          // Basvuru en az bir kalemle acilir (sunucu bos belgeyi reddediyor):
          //   randevunun hizmeti yoksa once o secilmeli.
          if (!Number(satir.hizmetId)) {
            mesaj('Randevuda hizmet seçili değil — başvuru kalemi oluşturulamıyor. '
                + 'Randevu kartından "Hizmet / İşlem" seçip tekrar deneyin.');
            git(`/randevu/${Number(satir.id)}`);
            return;
          }
          if (satir.belgeId) {
            // Zaten donusmus: yeni belge acmak yerine mevcut basvuruyu ac -
            //   ayni randevudan iki basvuru cikmasin.
            setAcikBelgeId(Number(satir.belgeId));
            return;
          }
          // HASTANIN KURUMU (266) basvurunun ODEYENI olur ve FIYATI belirler
          //   (274): hasta basvurusu her zaman kurum + kampanya uzerinden.
          //   Kart okunamazsa donusum yine yapilir - kurumsuz, hasta kendi oder.
          let hastaKart: { surum?: string; durum?: unknown } | null = null;
          let odeyenKurumId: number | null = null;
          try {
            const hk = await api.kartOku('hasta', hastaId);
            hastaKart = hk.kart;
            // Kurum kartin KENDI alani degil "ozluk" detayindadir (taraf_hasta,
            //   266): kart kokunden okunursa hep bos gelir - basvuru odeyensiz
            //   ve kampanyasiz aciliyordu.
            odeyenKurumId = Number(hk.detaylar?.ozluk?.[0]?.kurumId) || null;
          } catch { /* hasta okunamazsa kurumsuz devam */ }

          // FIYAT: liste BAZ, kampanya INDIRIM (274). Baz liste belge kartinin
          //   kuralindan gelir (205: carinin listesi > varsayilan satis);
          //   kampanyanin kendi listesi varsa uc onu kullanir. Fiyat cikmazsa
          //   hizmet kartindaki fiyata dusulur.
          // Odeyen kurumun kendi listesi hastaninkini ezer (278).
          const varsayilanListe = await api.belgeVarsayilanListe(19, hastaId, odeyenKurumId);
          let fiyatListesiId = varsayilanListe.listeId ?? null;
          // KAMPANYANIN KENDI LISTESI bazi belirler (kurum sozlesmesi "TTB2018
          //   uzerinden %40" der): varsayilan satis listesi acikca gonderilirse
          //   uc onu baz alir ve kampanyanin listesi devre disi kalirdi. Belge
          //   karti da acilista ayni sirayi izliyor (BelgeKarti kampanya cozumu).
          try {
            const kmp = await api.fiyatKampanya({ tarafId: hastaId, kurumId: odeyenKurumId });
            if (kmp.fiyatListesiId) fiyatListesiId = kmp.fiyatListesiId;
          } catch { /* kampanya cozulemezse varsayilan liste kalir */ }
          const h = await api.liste('hizmet', {
            sayfa: 1, boyut: 1,
            filtre: { alan: 'id', op: 'esit', deger: hizmetId },
          });
          const kdv = Number(h.satirlar[0]?.kdv) || 0;
          let birimFiyat = Number(h.satirlar[0]?.fiyat) || 0;
          let iskonto = 0;
          let kampanyaId: number | null = null;
          let kampanyaSatirId: number | null = null;
          try {
            const f = await api.fiyatKalem({ hizmetId },
              { tarafId: hastaId, kurumId: odeyenKurumId, listeId: fiyatListesiId });
            kampanyaId = f.kampanyaId;
            if (f.listeId) fiyatListesiId = f.listeId;
            // Yuzde/tutar karari BELGE KARTIYLA AYNI yerden (belgeKalem.ts):
            //   iki yerde yazilirsa donusumdeki fatura kartta gorunenden
            //   farkli fiyatlanir.
            const y = kampanyaKalemFiyati(f);
            if (y) {
              birimFiyat = y.birimFiyat;
              iskonto = y.iskonto ?? 0;
              kampanyaSatirId = y.kampanyaSatirId ?? null;
            }
          } catch { /* fiyat cozulemezse hizmet kartindaki fiyat kalir */ }

          const y = await api.belgeEkle({
            belge: {
              // Basvuru = SATIS SIPARISI (279): ayri tur yok.
              tur: 19,
              tarafId: hastaId,
              odeyenKurumId,
              kampanyaId,
              // Basvuru BUGUNUN tarihiyle acilir: hasta simdi geldi. Randevu
              //   ileri tarihliyse sunucu "belge tarihi ileri tarihli olamaz"
              //   diyordu; randevunun kendi tarihi aciklamada duruyor.
              // YEREL an (kullanici): toISOString UTC verdigi icin belge
              //   saati TR'de 3 saat geriye kayiyordu; basvuru saatinin
              //   dogru olmasi kayit kabul icin sart.
              belgeTarihi: yerelZamanDamgasi(),
              subeId: oturumSubeId,
              fiyatListesiId,
              aciklama: `Randevu #${satir.id}`
                        + (satir.bolumAdi ? ` · ${String(satir.bolumAdi)}` : ''),
            },
            // tur = 2 (hizmet): sunucu tur ile urun bagini karsilastiriyor
            //   (1 stok / 2 hizmet / 3 masraf).
            satirlar: [{ sira: 1, tur: 2, hizmetId, adet: 1, birimFiyat, kdv,
                         iskonto, kampanyaSatirId }],
          });
          const belgeId = Number((y as { belge?: { id?: number } }).belge?.id) || 0;
          // ADAY hasta (266) basvuruya donusunce AKTIF olur: randevu sirasinda
          //   hizli acilmis kayit, hasta gelince gercek hastaya doner.
          try {
            if (hastaKart && Number(hastaKart.durum) === 2) {
              await api.kartGuncelle('hasta', hastaId,
                                     { surum: hastaKart.surum, kart: { durum: 1 } });
            }
          } catch { /* durum guncellenemezse donusum yine de tamamlanir */ }
          // Randevu artik basvuruya bagli ve "Geldi" - hasta muayeneye alindi.
          //   Kart guncellemesi SURUM ister (iyimser kilit): once oku.
          const mevcut = await api.kartOku('randevu', Number(satir.id));
          await api.kartGuncelle('randevu', Number(satir.id),
                                 { surum: mevcut.kart.surum, kart: { belgeId, durum: 2 } });
          setYenile(t => t + 1);
          // Basvuru kartI MODAL acilir (belge kartinin rotasi yok, her listede
          //   bu bilesenle aciliyor).
          if (belgeId) setAcikBelgeId(belgeId);
        });
        return;
      }

      if (kod.endsWith('.yeni') && tanim.kartYolu) {
        // RANDEVU (251): takvimde fareyle isaretlenen aralik varsa saat ve sure
        //   karta tasinir - kullanici "yukaridan asagi isaretleyip Yeni'ye
        //   basinca" formda o araligi gormek istiyor.
        // Cihaz sutunundan secildiyse bolum/hekim TASINMAZ - kaynak cihazdir (316).
        const arBolum = takvimAralik?.cihazId
          ? undefined
          : hekimBolumu(takvimAralik?.hekimId) ?? (bolumSuzgec || undefined);
        const ek = tanim.kaynak === 'randevu' && takvimAralik
          ? `?baslangic=${encodeURIComponent(takvimAralik.baslangic)}`
            + `&sure=${takvimAralik.sureDk}`
            + (takvimAralik.hekimId ? `&hekim=${takvimAralik.hekimId}` : '')
            + (takvimAralik.cihazId ? `&cihaz=${takvimAralik.cihazId}` : '')
            + (arBolum ? `&bolum=${arBolum}` : '')
          : '';
        git(`${tanim.kartYolu}/yeni${ek}`);
      }
      // SIL gercekten SILER: eskiden karti aciyordu ve kullanici "sildim" sanip
      //   ekranda kaydi gorunce sasiriyordu. Onay sorulur; silme engelleri
      //   (SilmeEngeli) sunucuda, 422 mesaji kullaniciya aynen gosterilir.
      else if (kod.endsWith('.sil') && satir && tanim.kartYolu) {
        const ad = String(satir.ad ?? satir.konu ?? satir.unvan ?? satir.kod ?? satir.id);
        if (!await onay(`"${ad}" silinecek. Onaylıyor musunuz?`)) return;
        // Kart adi KAYNAK'tir, rota degil: Cek/Senet listelerinin rotasi '/cek'
        //   ama kart 'cek-senet'. Yoldan turetmek yanlis karta giderdi.
        await api.kartSil(tanim.kaynak, Number(satir.id));
        setYenile(t => t + 1);
      }
      else if ((kod.endsWith('.duzenle') || kod.endsWith('.ac')) && satir && tanim.kartYolu)
        kartaGit(satir.id);
      else if (satir) mesaj(`"${kod}" aksiyonu henuz baglanmadi.`);
    } catch (h) {
      mesaj(hataMetni(h));
    }
  }

  return (
    <>
    {/* EKSTRE MODU (A): grid ekstre kaynagina doner. Ust cip seridinden
        Aktif/Pasif/Tumu'ye basmak listeye geri getirir. */}
    {ekstre && tanim.ekstre ? (
      <GenGrid
        key={`${tanim.ekstre.kaynak}-${ekstre.id}`}
        kaynak={tanim.ekstre.kaynak}
        baslik={`${c(tanim.ekstre.baslik)} — ${ekstre.ad}`}
        yol={yolCevir(tanim.yol)}
        sabitFiltre={{ alan: tanim.ekstre.alan, op: 'esit', deger: ekstre.id }}
        // DOVIZSIZ ekstrede yerel karsilik kolonlari CIZILMEZ (kullanici):
        //   hepsi TL ise "Borç" ile "Yerel Borç" ayni sayiyi iki kez gosterir.
        //   Kur kolonu da ayni sebeple gizlenir (her satirda 1).
        dovizsizGizle={['dovizKuru', 'yerelBorc', 'yerelAlacak', 'yerelBakiye']}
        kolonBasliklari={tanim.ekstre.kolonBasliklari}
        // Cari ekstresinde kolonlar borc/alacak, hesap ekstresinde giris/cikis;
        //   ikisinin de yerel karsiligi toplanir (genel toplam yerel parada).
        toplam={tanim.ekstre.kaynak === 'cari-ekstre'
          ? ['borc', 'alacak', 'yerelBorc', 'yerelAlacak']
          : ['giris', 'cikis', 'yerelBorc', 'yerelAlacak']}
        // Cipler ekstre modunda YALNIZ "geri don" gorevi gorur: filtreleri
        //   birlikte gondermek ekstre kaynagina "Bilinmeyen alan: durum" 400'u
        //   verdiriyordu (ekstre goruntusunde durum kolonu yok).
        cipler={tanim.cipler?.map(c => ({ ad: c.ad }))}
        tarihAlani={tanim.ekstre.tarihAlani}
        tarihVarsayilan="yilbasindanBugune"
        // Ekstrede yalniz cikti aksiyonlari (Yazdir ▾ = CSV Kaydet / Yazdir);
        //   Ekle/Duzenle/Sil hesap listesine ait. HASTA ekstresinde ustune
        //   "Başvuru Aç" gelir (kullanici) - satir secilmeden pasif, sebebi
        //   sunucudan (KayitGerekir).
        aksiyonEkrani={tanim.kaynak === 'hasta' ? 'hasta-ekstre' : 'cikti-liste'}
        // Cift tik: satiri URETEN kayda git - once kasa islemi, yoksa belge.
        onSatirAc={satir => ekstreSatirinaGit(satir)}
        onSecimDegisti={s => setEkstreSatir(s)}
        onAksiyon={kod => {
          if (kod === 'genel.yazdir') { mesaj('Yazdirma henuz baglanmadi.'); return }
          // "Başvuru Aç": secili satirin belgesini acar. Ekstre satiri
          //   tahsilattan gelmis olabilir - o zaman belge, tahsilatin bagli
          //   oldugu belgedir; ikisi de yoksa acilacak kayit yok.
          if (kod === 'basvuru.ac') {
            if (!ekstreSatir) { mesaj('Önce bir satır seçin.'); return }
            if (!ekstreSatirinaGit(ekstreSatir, true))
              mesaj('Bu satırın bağlı olduğu bir belge yok.');
          }
        }}
        cipBaslangic={cipIndeks}
        // Cip'e basmak = listeye don (secilen filtreyle).
        onCipSecildi={i => { setCipIndeks(i); setEkstre(null) }}
        cipSonu={
          <>
            <button className="on" disabled title="Ekstre gösteriliyor">
              📄 {ekstre.ad}
            </button>
            {/* EKSTREDEN CIKIS (kullanici): ad dugmesi pasif oldugu icin
                ekstreyi kapatmanin tek yolu bir cipe basmakti - filtreyi de
                degistiriyordu. Bu dugme YALNIZ ekstreyi kapatir, secili cip
                oldugu gibi kalir. */}
            <button className="kapat" title="Ekstreyi kapat"
                    onClick={() => setEkstre(null)}>×</button>
          </>
        }
      />
    ) : (
    <>
    {/* KATEGORI AGACI PANELI (kullanici): acikken listenin SOLUNDA durur ve
        secilen dal listeyi suzer. Kapali varsayilan - her listede yer
        kaplamasin. */}
    <div className={(tanim.kategoriSuzgeci && kategoriPaneli) || tanim.kaynak === 'dokuman'
                    ? 'kat-duzen' : undefined}>
      {/* DOKUMAN KLASOR PANELI (419): listenin SOLUNDA durur - kat-duzen flex
          oldugu icin panel `kat-duzen-ic`in KARDESI olmali; icine konunca
          blok akista gridin USTUNDE kaliyordu. */}
      {tanim.kaynak === 'dokuman' && (
        <DokumanKlasorPaneli secim={klasorSecim} onSecim={setKlasorSecim} yenile={yenile} />
      )}
      {tanim.kategoriSuzgeci && kategoriPaneli && (
        <KategoriAgacPaneli
          tur={tanim.kategoriSuzgeci}
          secili={kategoriDal?.id ?? null}
          sayacAlani={tanim.kategoriSuzgeci === 1 ? 'stokSayisi' : 'hizmetSayisi'}
          onSec={(id, agac) => setKategoriDal(id === null ? null : { id, agac })}
        />
      )}
      <div className="kat-duzen-ic">
    <GenGrid
      // key: kaynak degisince (baska liste ekranina gecince) GenGrid TAMAMEN yeniden
      //   kurulsun - Route ayni tree konumunda kaldigi icin React bilesen orneğini
      //   REUSE ediyordu, onceki ekranin state'i (aramaGorunumu, sirala, arama, sayfa...)
      //   yeni ekrana sizip yanlis/bos sonuc gosteriyordu (ör. Cari'de "Son Aranan"
      //   secilince Islem Gunlugu'ne gecince orada da "son" gonderiliyordu).
      key={tanim.rota ?? tanim.kaynak}
      kaynak={tanim.kaynak}
      baslik={cm(tanim.baslik)}
      yol={tanim.yol}
      toplam={tanim.toplam}
      cipler={tanim.cipler}
      sabitFiltre={klasorluFiltre(basvuruluFiltre(
        primliFiltre(personelliFiltre(kategoriliFiltre(randevuFiltresi)))))}
      tarihVarsayilan={tanim.tarihVarsayilan}
      onTarihAraligi={tanim.primSuzgeci ? primAraligiBildir : undefined}
      aksiyonEkrani={tanim.aksiyonEkrani}
      ebelgeMenusu={tanim.ebelgeMenusu}
      gizliKolonlar={tanim.gizliKolonlar}
      kolonBasliklari={tanim.kolonBasliklari}
      aramaGorunumGizli={tanim.aramaGorunumGizli}
      kolonSirasi={tanim.kolonSirasi}
      altSecenekler={{ ...KASA_ARAC_MENUSU, ...DONUSUM_MENUSU,
                       ...(tanim.altSecenekler ?? {}) }}
      yenile={yenile}
      odaklaSonEklenen={odaklaSonEklenen}
      icerikAlani={tanim.icerikAlani}
      icerikBaslik={tanim.icerikBaslik}
      onSatirAc={satir => {
        // Belge listelerinde kart MODAL acilir (rota yok); digerlerinde kartYolu.
        if (tanim.kaynak === 'belge' || tanim.kaynak === 'irsaliye'
            || tanim.kaynak === 'stok-transfer' || tanim.kaynak === 'stok-talep'
            || tanim.kaynak === 'giris-fis' || tanim.kaynak === 'cikis-fis')
          setAcikBelgeId(Number(satir.id));
        // Kasa islemi de MODAL (kullanici) - "Aç" aksiyonuyla ayni davranis.
        else if (tanim.kaynak === 'kasa-islem') setAcikKasaId(Number(satir.id));
        // Gelen belgenin KARTI YOK: cift tik gonderenin goruntusunu acar.
        else if (tanim.kaynak === 'gelen-belge')
          void gelenBelgeAksiyonu('gelen.goruntule', satir, () => setYenile(t => t + 1));
        else if (tanim.kartYolu) git(`${tanim.kartYolu}/${satir.id}`);
      }}
      onAksiyon={(kod, satir, secililer) => { void aksiyon(kod, satir, secililer) }}
      tarihAlani={tanim.tarihAlani}
      // Ekstreden donunce ayni hesap secili kalsin.
      seciliBaslangicId={sonSeciliId}
      cipBaslangic={cipIndeks}
      onCipSecildi={setCipIndeks}
      onCipRota={r => git(`/${r}`)}
      onSecimDegisti={s => { setSeciliSatir(s); if (s) setSonSeciliId(Number(s.id)) }}
      cipSonu={tanim.kategoriSuzgeci ? (
        // Ciplerin SAGINDA: agac panelini acan dugme + (panel kapaliyken)
        //   ayni suzgecin combo hali. Panel acikken combo cizilmez - ayni
        //   secim iki yerde durursa hangisinin gecerli oldugu belirsizlesir.
        <>
          <button className={kategoriPaneli ? 'on' : ''}
                  title="Kategori ağacını aç / kapat"
                  onClick={() => setKategoriPaneli(a => !a)}>
            🌳 Kategoriler
          </button>
          {!kategoriPaneli && (
            <KategoriSuzgeci
              tur={tanim.kategoriSuzgeci}
              deger={kategoriDal?.id ?? null}
              onDegis={(id, agac) => setKategoriDal(id === null ? null : { id, agac })}
            />
          )}
        </>
      ) : tanim.kaynak === 'randevu' ? (
        // Bolum/hekim suzgeci TARIH ARALIGININ SAGINDA (kullanici) - grid ve
        //   altindaki takvim ayni secimi kullanir.
        <>
          <select value={bolumSuzgec} title="Bölüm"
                  onChange={e => { setBolumSuzgec(e.target.value ? Number(e.target.value) : '');
                                   setHekimSuzgec('') }}>
            <option value="">Tüm Bölümler</option>
            {randevuAgaci.map(d => (
              <option key={d.departmanId} value={d.departmanId}>{d.ad}</option>
            ))}
          </select>
          <select value={hekimSuzgec} title="Hekim"
                  onChange={e => setHekimSuzgec(e.target.value ? Number(e.target.value) : '')}>
            <option value="">Tüm Hekimler</option>
            {hekimSecenekleri.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
          </select>
          {(bolumSuzgec !== '' || hekimSuzgec !== '') && (
            <button type="button" className="kapat" title="Bölüm/hekim filtresini kaldır"
                    onClick={() => { setBolumSuzgec(''); setHekimSuzgec('') }}>×</button>
          )}
        </>
      ) : tanim.basvuruSuzgeci ? (
        // BASVURU (kullanici): "Tumu"nun saginda ayracla tarih araligi,
        //   Odeyen, Bolum agaci, Doktor. Ayraci serit zaten cipSonu'ndan
        //   once koyuyor.
        <>
          <select className="kat-suzgec" value={bvTamamlanma} title="Tamamlanmaya göre süz"
                  onChange={e => setBvTamamlanma(e.target.value as '' | 'tamam' | 'devam')}>
            <option value="">Tamamlanma: Tümü</option>
            <option value="tamam">Tamamlandı (%100)</option>
            <option value="devam">Devam Ediyor</option>
          </select>
          <select className="kat-suzgec" value={bvTahsilat} title="Tahsilat durumuna göre süz"
                  onChange={e => setBvTahsilat(e.target.value as '' | '0' | '1' | '2')}>
            <option value="">Tahsilat: Tümü</option>
            <option value="2">Tahsil Edildi</option>
            <option value="1">Kısmi Tahsilat</option>
            <option value="0">Tahsilat Yok</option>
          </select>
          {/* Eski cipler: belgenin fis/faturaya DONUSUM durumu. */}
          <select className="kat-suzgec" value={bvDonusum} title="Dönüşüm durumuna göre süz"
                  onChange={e => setBvDonusum(e.target.value as '' | '0' | '1' | '2')}>
            <option value="">Dönüşüm: Tümü</option>
            <option value="0">Açık</option>
            <option value="1">Kısmi</option>
            <option value="2">Kapanan</option>
          </select>
          <span className="durumseg-ayrac" />
          <select className="kat-suzgec" value={bvTarih} title="Tarih aralığı"
                  onChange={e => setBvTarih(e.target.value as TarihOnAyar | '')}>
            <option value="">Tüm Tarihler</option>
            {TARIH_ON_AYARLAR.map(t => (
              <option key={t.deger} value={t.deger}>{t.ad}</option>
            ))}
          </select>
          <select className="kat-suzgec" value={bvOdeyen} title="Ödeyen kuruma göre süz"
                  onChange={e => setBvOdeyen(e.target.value ? Number(e.target.value) : '')}>
            <option value="">Tüm Kurumlar</option>
            {bvKurumlar.map(k => (
              <option key={k.id} value={k.id}>{k.ad} ({k.adet})</option>
            ))}
          </select>
          <BolumSuzgeci
            deger={bvBolum?.id ?? null}
            izinliIdler={bvBolumler.map(x => x.id)}
            onDegis={(id, agac) => setBvBolum(id === null ? null : { id, agac })}
          />
          <select className="kat-suzgec" value={bvDoktor} title="Doktora göre süz"
                  onChange={e => setBvDoktor(e.target.value ? Number(e.target.value) : '')}>
            <option value="">Tüm Doktorlar</option>
            {bvDoktorlar.map(d => (
              <option key={d.id} value={d.id}>{d.ad} ({d.adet})</option>
            ))}
          </select>
          {(bvTarih !== 'bugun' || bvOdeyen !== '' || bvBolum !== null || bvDoktor !== ''
            || bvTamamlanma !== '' || bvTahsilat !== '' || bvDonusum !== '') && (
            <button type="button" className="kapat" title="Başvuru filtrelerini kaldır (tarih bugüne döner)"
                    onClick={() => { setBvTarih('bugun'); setBvOdeyen('');
                                     setBvBolum(null); setBvDoktor('');
                                     setBvTamamlanma(''); setBvTahsilat('');
                                     setBvDonusum('') }}>×</button>
          )}
        </>
      ) : tanim.primSuzgeci ? (
        // HAKEDIS SATIRLARI (kullanici): tarih araliginin SAGINDA once Prim
        //   Rolu, onun saginda Kisi. Suzme sunucuda; kisi listesi secili role
        //   gore daralir.
        <>
          <select className="kat-suzgec" value={primRol} title="Prim rolüne göre süz"
                  onChange={e => setPrimRol(e.target.value ? Number(e.target.value) : '')}>
            <option value="">Tüm Prim Rolleri</option>
            {primRolleri.map(r => (
              <option key={r.id} value={r.id}>{r.ad} ({r.adet})</option>
            ))}
          </select>
          <select className="kat-suzgec" value={primKisi} title="Kişiye göre süz"
                  onChange={e => setPrimKisi(e.target.value ? Number(e.target.value) : '')}>
            <option value="">Tüm Kişiler</option>
            {primKisiler.map(k => (
              <option key={k.id} value={k.id}>{k.ad} ({k.adet})</option>
            ))}
          </select>
          {(primRol !== '' || primKisi !== '') && (
            <button type="button" className="kapat" title="Prim rolü/kişi filtresini kaldır"
                    onClick={() => { setPrimRol(''); setPrimKisi('') }}>×</button>
          )}
        </>
      ) : (tanim.bolumSuzgeci || rolSuzgeciVar) ? (
        // PERSONEL (kullanici): ciplerin SAGINDA bolum agac combosu + rol
        //   combosu. Ikisi de sunucuda suzer - istemci listeyi kendi
        //   sirasindan ayiklamaz, sayfali listede yanlis olurdu.
        <>
          {tanim.bolumSuzgeci && (
            <BolumSuzgeci
              deger={personelBolum?.id ?? null}
              onDegis={(id, agac) => setPersonelBolum(id === null ? null : { id, agac })}
            />
          )}
          {rolSuzgeciVar && (
            <select className="kat-suzgec" value={personelRol}
                    title="Kullanıcı rolüne göre süz"
                    onChange={e => setPersonelRol(e.target.value ? Number(e.target.value) : '')}>
              <option value="">Tüm Roller</option>
              {roller.map(r => <option key={r.id} value={r.id}>{r.ad}</option>)}
            </select>
          )}
          {(personelBolum !== null || personelRol !== '') && (
            <button type="button" className="kapat" title="Bölüm/rol filtresini kaldır"
                    onClick={() => { setPersonelBolum(null); setPersonelRol('') }}>×</button>
          )}
        </>
      ) : tanim.ekstre && (
        <button
          disabled={!seciliSatir}
          title={seciliSatir ? 'Seçili hesabın ekstresi' : 'Önce bir satır seçin'}
          onClick={() => seciliSatir && setEkstre({
            id: Number(seciliSatir.id),
            ad: String(seciliSatir.ad ?? seciliSatir.unvan ?? seciliSatir.id),
          })}
        >
          📄 Ekstre
        </button>
      )}
      // RANDEVU (251, kullanici: "arama editi sagina takvim butonu, basinca
      //   randevu takvimi listeye bassin"): takvim artik listenin ALTINDA
      //   degil, Liste/Grup/Analiz yanindaki "Takvim" dugmesiyle onun YERINE
      //   cizilir - ust serit (arama, cipler, bolum/hekim suzgeci) ortak kalir.
      ekGorunum={tanim.kaynak === 'randevu' ? {
        ad: 'Takvim', ik: '📅',
        icerik: (
          <RandevuTakvimi
            ayarlar={takvimAyarlari}
            bolum={bolumSuzgec === '' ? undefined : bolumSuzgec}
            hekimId={hekimSuzgec === '' ? undefined : hekimSuzgec}
            yenile={yenile}
            // Hekim gorunumunde sutunun hekimi de karta gecer (251).
            hekimler={hekimSecenekleri}
            // CIHAZ gorunumu (316): radyolojide randevu cihaza verilir.
            cihazlar={cihazSecenekleri}
            // RANDEVU BEKLEYEN ISTEMLER (316): panel yalniz radyoloji cihazi
            //   tanimliysa cizilir - poliklinik kurulumunda hic gorunmez.
            yanPanel={cihazSecenekleri.length > 0 ? (
              <RandevuBekleyenPanel
                secili={bekleyenSecili}
                onSecim={setBekleyenSecili}
                yenile={yenile}
                onRandevuModali={i => setRandevuModali({
                  istemId: i.id, accessionNo: i.accessionNo,
                  tetkikAdi: i.tetkik, modalite: i.modalite, sureDk: i.sureDk,
                })}
              />
            ) : undefined}
            onKapatmaIste={(cihazId, bas, bit) => setKapatmaModali({
              cihazId, baslangic: bas, bitis: bit,
              cihazAdi: cihazSecenekleri.find(c => c.id === cihazId)?.ad ?? '',
            })}
            onBirak={(veri, bas, cih) => {
              // Yuk istemin kendisi (panel JSON yazar) - secili satira bakmayiz.
              try { void bekleyeneRandevuVer(JSON.parse(veri) as BekleyenIstem, bas, cih) }
              catch { /* taninmayan surukleme yuku - yok say */ }
            }}
            onYeni={(bas, hek, cih) => {
              // Panelde istem SECILIYSE bos saate tiklamak yeni randevu formu
              //   degil, o isteme randevu demektir (dokunmatik/erisilebilir yol).
              if (bekleyenSecili) { void bekleyeneRandevuVer(bekleyenSecili, bas, cih); return }
              // Cihaz sutunundan aciliyorsa bolum/hekim ARANMAZ - kaynak cihaz.
              const bol = cih ? undefined : (hekimBolumu(hek) ?? (bolumSuzgec || undefined));
              git(`/randevu/yeni?baslangic=${encodeURIComponent(bas)}`
                  + (hek ? `&hekim=${hek}` : '')
                  + (cih ? `&cihaz=${cih}` : '')
                  + (bol ? `&bolum=${bol}` : ''));
            }}
            onAc={id => git(`/randevu/${id}`)}
            onAralik={(bas, sure, hek, cih) =>
              setTakvimAralik(bas
                ? { baslangic: bas, sureDk: sure, hekimId: hek, cihazId: cih } : null)}
          />
        ),
      } : undefined}
    />
      </div>
    </div>
    </>
    )}

    {acikKasaId !== null && (
      <KasaIslemKarti
        kayitIdProp={acikKasaId}
        onKapat={() => { setAcikKasaId(null); setYenile(t => t + 1) }}
      />
    )}

    {/* CEK/SENET: kiymet karti. Kaydedilince ayni bilgilerle kasa islemi
        (23/24/33/34) acilir ve kiymete baglanir - cari o anda alacaklanir /
        borclanir, kagit portfoye girer. */}
    {cekTuru !== null && (
      <GenForm
        kaynak="cek-senet"
        id="yeni"
        baslik={cekTuru === 24 || cekTuru === 34 ? 'Senet' : 'Çek'}
        yeniKayitVarsayilanlari={{
          tur: cekTuru === 24 || cekTuru === 34 ? 2 : 1,
          yon: cekTuru === 33 || cekTuru === 34 ? 2 : 1,
        }}
        onKapat={() => setCekTuru(null)}
        onKaydedildi={id => { void cekKartKaydedildi(cekTuru, id) }}
      />
    )}

    {kasaTuru !== null && (
      <KasaIslemKarti
        acilis={{ tur: kasaTuru }}
        onKapat={() => { setKasaTuru(null); setYenile(t => t + 1) }}
      />
    )}

    {kasaAcilis !== null && (
      <KasaIslemKarti
        acilis={kasaAcilis}
        onKapat={() => { setKasaAcilis(null); setYenile(t => t + 1) }}
      />
    )}

    {acikBelgeId !== null && (
      <BelgeKarti id={acikBelgeId} onKapat={() => setAcikBelgeId(null)} />
    )}

    {yeniBelgeTuru !== null && (
      <BelgeKarti
        tur={yeniBelgeTuru}
        onKapat={() => setYeniBelgeTuru(null)}
        onKaydedildi={() => setYenile(t => t + 1)}
      />
    )}

    {/* MESAJ GECMISI (178): belgenin e-Belge yolculugu - hazirlama, gonderim
        denemeleri ve GIB yanitlari tek pencerede. */}
    {eBelgeMesajlari && (
      <Modal
        baslik={`e-Belge Mesaj Geçmişi — ${eBelgeMesajlari.belgeNo}`}
        onKapat={() => setEBelgeMesajlari(null)}
        alt={<button className="d kapat-dugmesi"
                     onClick={() => setEBelgeMesajlari(null)}>Kapat</button>}
      >
        <div className="kagrup">
          {eBelgeMesajlari.satirlar.length === 0 ? (
            <div className="not" style={{ padding: 10 }}>
              Bu belge için henüz e-Belge işlemi yapılmamış.
            </div>
          ) : (
            <table className="grid">
              <thead>
                <tr><th style={{ width: 40 }}>#</th><th style={{ width: 140 }}>Tarih</th>
                    <th>Olay</th><th>Durum</th><th style={{ width: 90 }}>Kod</th>
                    <th>Açıklama</th></tr>
              </thead>
              <tbody>
                {eBelgeMesajlari.satirlar.map(m => (
                  <tr key={m.sira}>
                    <td>{m.sira}</td>
                    <td>{m.tarih ? new Date(m.tarih).toLocaleString('tr-TR') : '—'}</td>
                    <td>{m.olay}</td>
                    <td>{m.durum}</td>
                    <td>{m.kod}</td>
                    <td>{m.aciklama}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </Modal>
    )}

    {iceriAl && (
      <IceriAlModali
        baslik={iceriAl.ad}
        sablonIndir={(dolu: boolean) => api.fiyatListesiSablon(iceriAl.listeId, dolu)}
        yukle={(dosya: File) => api.fiyatListesiIceriAl(iceriAl.listeId, dosya)}
        onKapat={() => setIceriAl(null)}
        onAlindi={() => setYenile(t => t + 1)}
      />
    )}
    {/* RADYOLOJI ISTEM (304): once hasta, sonra tetkikler. Listeden acilan
        istem DIS istemdir - ic istem basvuru kartindan acilir. */}
    <TarafArama
      acik={istemHastaArama}
      kaynaklar={['hasta']}
      yerTutucu="Hastayı isim/tel ile ara…"
      onKapat={() => setIstemHastaArama(false)}
      onSec={sec => {
        setIstemHastaArama(false);
        setIstemModali({ hastaId: sec.id, hastaAdi: sec.unvan, disIstem: true });
      }}
    />
    {rolModali && (
      <KalemRolModali
        belgeSatirId={rolModali.satirId}
        kalemAdi={rolModali.ad}
        onKapat={() => setRolModali(null)}
        onTamam={() => setYenile(x => x + 1)}
      />
    )}
    {donemModali && (
      <DonemKapatModali
        tarafId={donemModali.tarafId}
        kisi={donemModali.kisi}
        onKapat={() => setDonemModali(null)}
        onTamam={() => setYenile(x => x + 1)}
      />
    )}
    {istemModali && (
      <IstemModali
        acik
        hastaId={istemModali.hastaId}
        hastaAdi={istemModali.hastaAdi}
        disIstem={istemModali.disIstem}
        randevuId={istemModali.randevuId ?? null}
        onSeciliHizmetId={istemModali.hizmetId ?? null}
        onKapat={() => setIstemModali(null)}
        onTamam={(_a, sonuc) => {
          // RANDEVUDAN KABUL (317): acilan basvuru randevuya baglanir, randevu
          //   "Geldi"ye cekilir - takvim, basvuru ve istem ayni olayi gosterir.
          const rid = istemModali.randevuId;
          if (rid && sonuc?.belgeId) {
            void guvenli(async () => {
              const mevcut = await api.kartOku('randevu', rid);
              await api.kartGuncelle('randevu', rid, {
                surum: mevcut.kart.surum,
                kart: { belgeId: sonuc.belgeId, durum: 2 },
              });
            });
          }
          setYenile(t => t + 1);
        }}
      />
    )}
    {sarfModali && (
      <SarfOnayModali
        istemId={sarfModali.istemId}
        accessionNo={sarfModali.accessionNo}
        tetkikAdi={sarfModali.tetkikAdi}
        onKapat={() => setSarfModali(null)}
        onTamam={() => setYenile(t => t + 1)}
      />
    )}

    {kapatmaModali && (
      <CihazKapatmaModali
        cihazId={kapatmaModali.cihazId}
        cihazAdi={kapatmaModali.cihazAdi}
        baslangic={kapatmaModali.baslangic}
        bitis={kapatmaModali.bitis}
        onKapat={() => setKapatmaModali(null)}
        onTamam={() => setYenile(t => t + 1)}
      />
    )}

    {kritikModali && (
      <KritikBildirimModali
        istemId={kritikModali.istemId}
        accessionNo={kritikModali.accessionNo}
        hasta={kritikModali.hasta}
        tetkik={kritikModali.tetkik}
        bulgu={kritikModali.bulgu}
        bildirilenAd={kritikModali.bildirilenAd}
        onKapat={() => setKritikModali(null)}
        onTamam={() => setYenile(t => t + 1)}
      />
    )}

    {konsultasyonModali && (
      <KonsultasyonCevapModali
        istemId={konsultasyonModali.istemId}
        konsultasyonId={konsultasyonModali.konsultasyonId}
        accessionNo={konsultasyonModali.accessionNo}
        hasta={konsultasyonModali.hasta}
        tetkik={konsultasyonModali.tetkik}
        soru={konsultasyonModali.soru}
        mevcutGorus={konsultasyonModali.gorus}
        onKapat={() => setKonsultasyonModali(null)}
        onTamam={() => setYenile(t => t + 1)}
      />
    )}

    {randevuModali && (
      <RandevuModali
        istemId={randevuModali.istemId}
        accessionNo={randevuModali.accessionNo}
        tetkikAdi={randevuModali.tetkikAdi}
        modalite={randevuModali.modalite}
        sureDk={randevuModali.sureDk}
        onKapat={() => setRandevuModali(null)}
        onTamam={() => setYenile(t => t + 1)}
      />
    )}

    {teslimModali && (
      <TeslimModali
        istemId={teslimModali.istemId}
        accessionNo={teslimModali.accessionNo}
        cdIstendi={teslimModali.cdIstendi}
        onKapat={() => setTeslimModali(null)}
        onTamam={() => setYenile(t => t + 1)}
      />
    )}
    {utsBelgeSonuc && (
      <UtsBelgeSonucModali sonuc={utsBelgeSonuc} onKapat={() => setUtsBelgeSonuc(null)} />
    )}
    {utsHazirla && (
      <UtsHazirlaSonucModali sonuc={utsHazirla} onKapat={() => setUtsHazirla(null)} />
    )}
    {utsGenel && (
      <UtsGenelBildirimModali
        tur={utsGenel}
        onKapat={() => setUtsGenel(null)}
        onTamam={m => { setUtsGenel(null); mesaj(m); setYenile(t => t + 1) }}
      />
    )}
    {utsKullanim && (
      <UtsKullanimModali
        onKapat={() => setUtsKullanim(false)}
        onTamam={m => { setUtsKullanim(false); mesaj(m); setYenile(t => t + 1) }}
      />
    )}
    {utsAlma && (
      <UtsAlmaModali
        envanterId={utsAlma.envanterId}
        urunNo={utsAlma.urunNo}
        kurumUnvan={utsAlma.kurumUnvan}
        askiAdet={utsAlma.askiAdet}
        seriNo={utsAlma.seriNo}
        onKapat={() => setUtsAlma(null)}
        onTamam={m => { setUtsAlma(null); mesaj(m); setYenile(t => t + 1) }}
      />
    )}
    {donusum && (
      <BelgeDonusumModali
        belgeId={donusum.belgeId}
        belgeTur={donusum.belgeTur}
        varsayilanHedef={donusum.hedef}
        // Hedef LISTEDE secildiyse kartta degistirilemez (kullanici): karar
        //   zaten verilmis, ikinci kez sormak hata kapisi acar.
        hedefKilitli={donusum.hedef != null}
        onKapat={() => setDonusum(null)}
        // Modal KAPANMAZ: sonucu (yeni belge no + tutar) kendi icinde gosterir.
        //   mesaj() kullanmak tarayici diyalogu acar ve sayfayi kilitler.
        onTamam={() => setYenile(t => t + 1)}
      />
    )}

    {kartId !== null && tanim.kartYolu && !tanim.ozelKart && (
      <GenForm
        kaynak={tanim.kaynak}
        id={kartId}
        baslik={tanim.kartBaslik ?? tanim.baslik.replace(/ler$|lar$/, '')}
        yerTutucuSekmeler={tanim.yerTutucuSekmeler}
        gizliAlanlar={tanim.gizliKartAlanlari}
        gizliSekmeler={tanim.gizliKartSekmeleri}
        zorunluAlanlar={tanim.zorunluKartAlanlari}
        resimYerTutucu={tanim.resimYerTutucu}
        // Takvimden gelen saat/sure (251): URL parametreleri kart varsayilani
        //   olur - kart acilinca alanlar dolu gelir.
        yeniKayitVarsayilanlari={tanim.kaynak === 'randevu' && sorgu.get('baslangic')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              baslangic: sorgu.get('baslangic')!,
              ...(sorgu.get('sure') ? { sureDk: Number(sorgu.get('sure')) } : {}),
              ...(sorgu.get('hekim') ? { hekimId: Number(sorgu.get('hekim')) } : {}),
              ...(sorgu.get('bolum') ? { bolum: Number(sorgu.get('bolum')) } : {}),
              ...(sorgu.get('cihaz') ? { cihazId: Number(sorgu.get('cihaz')) } : {}),
            }
          : tanim.yeniKayitVarsayilanlari}
        onKapat={() => git(tanim.kartYolu!)}
        onKaydedildi={yeniId => {
          setYenile(t => t + 1);
          if (kartId === 'yeni') {
            setOdaklaSonEklenen(t => t + 1);
            git(`${tanim.kartYolu}/${yeniId}`, { replace: true });
          }
        }}
      />
    )}
    </>
  );
}
