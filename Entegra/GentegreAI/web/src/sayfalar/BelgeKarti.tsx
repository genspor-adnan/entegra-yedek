import { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { mesaj, secimSor, type ParaSecimi } from '../bilesenler/mesaj';
import { type BelgeYaniti, URUN_GENOTIP, hataMetni } from '../api/sozlesme';
import { Modal } from '../bilesenler/Modal';
import { belgeTuruBilgisi, belgeKisaAdi, GIRILEBILIR_TURLER, VARSAYILAN_TUR,
         TAHAKKUK_TURLERI }
  from './belgeTuru';
import { DokumanGalerisi } from '../bilesenler/DokumanGalerisi';
import { useOturum } from '../kimlik/OturumBaglami';
import { para, yerelAnMetni, hamSayi } from '../bilesenler/bicim';
import { type SatirDurumu, yanittanSatirlar } from './belgeSatir';
import { type BelgeGirdisi } from './belgeKaydet';
import { belgeKaydetmeKur } from './belgeKarti/useBelgeKaydetme';
import { useBasvuruAlanlari, usePersonelAdi } from './belgeKarti/useBasvuruAlanlari';
import { useBelgeAyarlari } from './belgeKarti/useBelgeAyarlari';
import { useDagilimOnizleme } from './belgeKarti/useDagilimOnizleme';
import { YEREL_PARA_VARSAYILAN, KAPANMA_ETIKET } from './belgeSabitleri';
import {
  TasiyiciSekmesi, EBelgeSekmesi, FaturalamaSekmesi,
} from '../bilesenler/belge/BelgeSekmeleri';
import { KalemSekmesi, TahsilatSekmesi } from '../bilesenler/belge/KalemSekmesi';
import {
  BasvuruSekmesi, ProvizyonSekmesi, OncekiBasvurular, HastaSeridi,
  type BasvuruBilgi,
} from '../bilesenler/belge/BasvuruSekmesi';
import { BelgeAracCubugu } from '../bilesenler/belge/BelgeAracCubugu';
import { BelgeBaslik } from '../bilesenler/belge/BelgeBaslik';
import { useBelgeTahsilat, tahsilToplami } from './belgeTahsilat';
import { kartImzasi } from './belgeImza';
import { yanittanBaslik, yanittanBasvuruBilgi } from './belgeKarti/belgeOkuma';
import { useBasvuruKaynaklari } from './belgeKarti/useBasvuruKaynaklari';
import { useSevkiyatBilgisi, useTeklifBilgisi }
  from './belgeKarti/useSevkiyatBilgisi';
import { useBelgeDonusumleri } from './belgeKarti/useBelgeDonusumleri';
import { useKurumSecenekleri } from './belgeKarti/useKurumSecenekleri';
import { useBelgeAramalari } from './belgeKarti/useBelgeAramalari';
import { useKartKirliligi } from './belgeKarti/useKartKirliligi';
import { useParaAkislari, type ParaAkisRef } from './belgeKarti/useParaAkislari';
import { useBelgeFiyatlandirma } from './belgeKarti/useBelgeFiyatlandirma';
import { useIskontoTalepleri } from './belgeKarti/useIskontoTalepleri';
import { useBasvuruVarsayilanlari } from './belgeKarti/useBasvuruVarsayilanlari';
import { useSatirSecimi } from './belgeKarti/useSatirSecimi';
import { useKalemAkisi } from './belgeKarti/useKalemAkisi';
import {
  provizyonVarMi, gelisSekliKarari, acikBorcHesapla, acikBelgeHesapla, belgeOnizlemesi,
  acikTahsilatTaraflara, acikBelgeTaraflara, paylasimliKurum,
  dagilimRotasi,
} from './belgeKartiKurallari';
import { BelgeKartiModallari } from '../bilesenler/belge/BelgeKartiModallari';
import { BasvuruAsamaSeridi } from '../bilesenler/belge/BasvuruAsamaSeridi';

interface Props {
  /** Verilirse MEVCUT belge acilir (salt gorunum). Duzenleme F7'de gelecek. */
  id?: number;
  /** Acilis turu; verilmezse URL'deki ?tur= ya da satis faturasi (15). */
  tur?: number;
  /**
   * YENI belgede TARAF ON-DOLGU (hasta kartindan "＋ Yeni Başvuru"): pencere
   * cari aramasiyla degil, hasta SECILI olarak acilir. `id` verildiginde
   * (mevcut belge) yok sayilir - belgenin kendi tarafi gecerlidir.
   */
  tarafId?: number;
  /** On-dolgu tarafin ekranda gosterilecek unvani - ikinci bir istek atmamak icin. */
  tarafUnvan?: string;
  /** Liste icinden acildiginda: modal kapanisi cagirani ilgilendirir. */
  onKapat?(): void;
  /** Kayit sonrasi cagirani (grid) tazelemek icin. */
  onKaydedildi?(): void;
}

export function BelgeKarti({ id: belgeId, tur: acilisTuru, tarafId: onDolguTarafId,
                            tarafUnvan: onDolguUnvan, onKapat, onKaydedildi }: Props = {}) {
  const git = useNavigate();
  const [sorgu] = useSearchParams();
  const { yetki, kullanici, aksiyonDegeri } = useOturum();

  // SUNUCUDAN GELEN AYARLAR kendi kancasinda: tur adlari, tarih penceresi,
  //   yerel para ve POS aksiyonu acilista bir kez okunur, bir daha degismez.
  //   Kartin state'leri arasinda dagilmislardi; ortak yanlari SUNUCUNUN
  //   soyledigi, kullanicinin kart uzerinde degistirmedigi degerler olmalari.
  const { turAdi, geriGun, yerelPara, posAksiyon, setPosAksiyon } = useBelgeAyarlari();

  const [tur, setTur] = useState<number>(() => {
    const istenen = acilisTuru ?? Number(sorgu.get('tur'));
    return GIRILEBILIR_TURLER.includes(istenen as typeof GIRILEBILIR_TURLER[number])
      ? istenen : VARSAYILAN_TUR;
  });


  /**
   * HIZLI TAHSILAT (kullanici): banka/POS hesabi secim modali. Nakit modal
   * ACMAZ - varsayilan kasayla dogrudan satir eklenir.
   */
  const [hesapSecim, setHesapSecim] = useState<'B' | 'P' | null>(null);
  /**
   * ISKONTO TALEPLERI (662): ucret sekmesindeki durum rozeti. Talep acilinca
   * ve kart her acildiginda tazelenir - karar zilden verildigi icin banko
   * ekranindaki rozet ancak tazelemeyle guncellenir.
   */
  /* ISKONTO TALEPLERI kendi kancasinda (useIskontoTalepleri): yoklama
     kurali (yalniz bekleyen varken, 60 sn) ve karar sonrasi tazeleme orada. */

  /** Acilan hesap secimi IADE icin mi (tutar eksi ve neden sorulacak). */
  const [hesapSecimIade, setHesapSecimIade] = useState(false);
  /**
   * SECIMDEN ONCE SORULAN TUTAR (banka / POS). Para birimi tutarla birlikte
   * secildigi icin hesap ONDAN SONRA aranir - TL kasaya USD tahsilat
   * yazilamaz, sunucu reddeder; once hesap secilseydi kullanici dovizi
   * degistirdiginde secim gecersiz kalirdi.
   */
  const [hesapSecimPara, setHesapSecimPara] = useState<ParaSecimi | null>(null);
  /** Acik iskonto talep penceresi (mockup: iskonto_talep_penceresi.html). */
  const [iskontoTalebi, setIskontoTalebi] = useState<number[] | null>(null);
  /** POS tahsilatindan sonraki aksiyon (355 ayari): 0 yok / 1 otomatik / 2 sor. */
  /**
   * PROTOKOL NO ELLE MI (358): karar numaralandirma tablosunda
   * (numara_sablonu tur 19, `elle_girilir`) - ayri bir ayar yok. Elle ise kayit
   * kabul memuru numarayi kartta yazabilir; bos birakirsa sunucu yine uretir.
   */
  // ON-DOLGU: hasta kartindan acilan yeni basvuruda taraf HAZIR gelir.
  const [cari, setCari] = useState<{ id: number; unvan: string } | null>(
    !belgeId && onDolguTarafId ? { id: onDolguTarafId, unvan: onDolguUnvan ?? '' } : null);
  // Tarih SAATIYLE tutulur: ayni gun icindeki hareket sirasi buna gore.
  const [tarih, setTarih] = useState(() => yerelAnMetni(new Date()));
  const [seri, setSeri] = useState('WEB');
  /** Ayardan gelen geriye donuk gun siniri (0 = sinir yok). */
  /** Ayardan gelen yerel (defter) para birimi. */
  /**
   * RAPOR / EKSTRE DOVIZI (134): belge hangi para biriminde duzenlendi ve cari
   * hesaba hangi dovizde islenecek. Kur rapor dovizinden yerel paraya cevrimdir.
   */
  const [raporDovizi, setRaporDovizi] = useState(YEREL_PARA_VARSAYILAN);
  const [ekstreDovizi, setEkstreDovizi] = useState(YEREL_PARA_VARSAYILAN);
  const [belgeKuru, setBelgeKuru] = useState('1');
  /** Yalniz dis numarali turde (alis faturasi) kullanilir - tedarikcinin no'su. */
  const [belgeNo, setBelgeNo] = useState('');
  const [vadeGun, setVadeGun] = useState('30');
  /** Belge aciklamasi - basvuruda "Başvuru Notu" alani (300, mockup). */
  const [aciklama, setAciklama] = useState('');
  /**
   * YURURLUKTEKI KAMPANYA (274). Fiyat listesiyle YARISMAZ: liste BAZ fiyati,
   * kampanya INDIRIMI verir. Baslikta rozet olarak gorunur ve belgeye YAZILIR -
   * kurum sonradan kampanya degistirse eski belge kendi kampanyasini tasir.
   * Kayitli belgede COZULMEZ, kayittan okunur.
   */
  /**
   * ODEYEN KURUMUN PAY HESABI (291): 1 karsilama ORANI (ozel sigorta),
   * 2 KATILIM PAYI sabit tutar (SGK). Provizyon dugmesi buna gore davranir -
   * SGK'da oran sormak yanlis olurdu: SUT bedelinin tamami kuruma, hastadan
   * yalniz katilim payi alinir.
   */
  /**
   * FIYAT LISTESI (205). Acilista belge TURUNUN yonune gore cariden cozulur
   * (cari listesi > yonun varsayilani). Kullanici degistirince satirlar
   * yeniden fiyatlanir - kaydedilmis belgede sunucuda, kaydedilmemis belgede
   * satir satir listeden okunarak.
   */
  /** Teklif durumu (218): 1 Hazirlaniyor / 2 Sunuldu / 3 Kabul / 4 Red / 5 Iptal. */
  // TEKLIF BASLIGI (218) demet halinde: durum, revize no, konu, teslim.
  const teklif = useTeklifBilgisi();
  const [depo, setDepo] = useState<{ id: number; ad: string } | null>(null);
  /** Yalniz transferde (20): malin GIDECEGI depo. Tekil belgelerde kullanilmaz. */
  const [girisDepo, setGirisDepo] = useState<{ id: number; ad: string } | null>(null);
  /** Transferde sorumluluk devri: teslim EDEN (asagida, irsaliyeyle ortak) ve
      teslim ALAN personel - transferde ikisi de zorunlu. */
  /** Stok fisinde (3/4) fisin SEBEBI - belge.tipi. 0 = secilmedi. */
  const [fisTipi, setFisTipi] = useState(0);
  /** Hangi personel alani araniyor - ayni TarafArama iki alani da besler. */
  // Yeni kartta Satis Temsilcisi/Sorumlu VARSAYILANI oturum kullanicisi
  //   (kullanici) - KullaniciOzeti.Id zaten taraf_id. Kayit yuklenirken
  //   belgedeki deger bunu ezer; kullanici istedigiyle degistirebilir.
  const [satici, setSatici] = useState<{ id: number; ad: string } | null>(
    kullanici ? { id: kullanici.id, ad: kullanici.ad } : null);
  // IRSALIYE / SEVKIYAT alanlari (tasiyici · arac · sofor · teslim) demet
  //   halinde: Taşıyıcı sekmesine tek prop olarak gecer.
  const sevkiyat = useSevkiyatBilgisi();
  /* TASLAK kutusu arac cubugundan KALKTI (kullanici): kart kaydedince belge
     kesindir. Sunucu tarafi (durum 1) duruyor - gocten gelen eski taslaklar
     ve liste cipleri icin gerekli, ama kart artik hep KESIN yazar. */
  const taslak = false;
  // Yeni belge BOS grid ile acilir: "(stok seçilmedi)" yazan sahte satir
  //   kullaniciyi "burasi nasil doldurulur" diye ariyordu; satir "＋" ile eklenir.
  const [satirlar, setSatirlar] = useState<SatirDurumu[]>([]);

  const [kaydediyor, setKaydediyor] = useState(false);
  const [aciliyor, setAciliyor] = useState(!!belgeId);
  /** Termin (teslim tarihi) modali - siparis satirlarinin taahhudu (140). */
  const [terminAcik, setTerminAcik] = useState(false);
  /** Rezervasyon (142) islemi surerken dugme bekler. */
  const [rezerveCalisiyor, setRezerveCalisiyor] = useState(false);
  const [aktifSekme, setAktifSekme] = useState('kalem');
  /** Grid satir secimi (kirmizi Sil dugmesi bunlari siler). */
  /* SATIR SECIMI VE SILME kendi kancasinda (useSatirSecimi): grid davranisi
     (duz tik / Ctrl / Shift) ve kilitli satir korumasi orada. */
  /** Prim rolleri (324): kalem gridinden acilan modal - null iken kapali. */
  const [rolModali, setRolModali] = useState<{ satirId: number; ad: string } | null>(null);
  /**
   * ROL PENCERESI ICIN BEKLEYEN SATIR (kullanici: "ekleme yapıp rolleri görme
   * butonuna basarsam ücret satırlarını önce kaydetsin sonra orayı açsın").
   *
   * Kaydetme satirlari SUNUCUDAN tazeler; kimlik ancak o zaman olusur. Tiklama
   * anindaki satir NESNESI de degisir - elde kalan tek sabit satirin GRIDDEKI
   * SIRASIDIR. Kayit bitip satirlar yenilenince asagidaki efekt pencereyi acar.
   */
  const [rolBekleyenSira, setRolBekleyenSira] = useState<number | null>(null);
  /** Lot detayi KAPATILMIS kalemler. Lotlu kalem varsayilan ACIK gelir -
      kullanici bakmak icin ayrica tiklamasin; isteyen oku ile kapatir. */
  /** Lot/izlem detayi ACIK olan kalemler - varsayilan KAPALI (kullanici). */
  const [acikLotlar, setAcikLotlar] = useState<Set<number>>(new Set());
  /**
   * Kayitli belgede kalem DEGISTIRILDI mi (ekleme/silme/duzenleme). Dip toplam
   * sunucudan gelen degeri gosterir; kalem degisince o deger BAYATLAR -
   * kullanici satiri silince toplam eski haliyle duruyordu. Degisiklikten
   * sonra onizlemeye donulur, kaydedince yeniden sunucu degeri gecerlidir.
   */
  const [kalemDegisti, setKalemDegisti] = useState(false);
  const { seciliSatirlar, setSeciliSatirlar, sonTiklanan, satirTikla, secimDegis,
          seciliSil } = useSatirSecimi(satirlar, setSatirlar, setKalemDegisti);
  /** Shift ile ARALIK secimi icin son tiklanan satirin sirasi. */

  /** Acik kalem penceresi (adet / fiyat). Stok zaten secilmis olarak gelir. */
  const [kalem, setKalem] = useState<SatirDurumu | null>(null);
  // ARAMA / SECIM PENCERELERI (cari · hasta · satici · personel · stok ·
  //   iade · radyoloji istemi) tek kancada: belgeKarti/useBelgeAramalari.
  //
  // Cari secim modali YENI belgede acilista kendiliginden acilir: belgenin ilk
  //   sorusu "kime?" - kullaniciyi bos formda birakmak yerine dogrudan secim
  //   ekrani gelir. Cari YOKSA acilmaz (transfer 20, talep 105, stok fisi 3/4)
  //   ve ON-DOLGU varsa da acilmaz - taraf zaten belli.
  const arama = useBelgeAramalari(
    !belgeId && !onDolguTarafId && belgeTuruBilgisi(tur).cariVar);
  /** e-Fatura senaryosu (belge.senaryo) - GIB profilini belirler. */
  const [senaryo, setSenaryo] = useState(0);
  /** FATURA TIPI (130): faturanin cinsi - belge.tipi alaninda tutulur. */
  const [faturaTipi, setFaturaTipi] = useState(1);
  /** IADE mi - kalem secimi "onceki alinanlar"dan yapilir (132/133). */
  // IADE yalniz iadesi OLAN turlerde anlamli (301): siparis/basvuru turunde
  //   (19) iade yok - orada tipi baska bir sey anlatir. Sunucu ayni karari
  //   BelgeTuru.CikisMi(tur, tipi) icinde veriyor.
  const iadeMi = faturaTipi === 2 && tur !== 19;
  /** Rapor dovizi yerel disindaysa BELGE TARIHININ kuru cekilir; kullanici
   *  elle degistirebilir (kur pazarlikli olabiliyor). */
  const kurElleRef = useRef(false);
  useEffect(() => {
    if (raporDovizi === yerelPara) return;
    if (kurElleRef.current) return;
    void (async () => {
      try {
        const y = await api.dovizKur(raporDovizi, tarih.slice(0, 10));
        if (y?.kur) setBelgeKuru(String(y.kur));
      } catch { /* kur yoksa kullanici elle girer */ }
    })();
  }, [raporDovizi, tarih, yerelPara]);

  const [sonuc, setSonuc] = useState<BelgeYaniti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});

  const ekleyebilir = yetki('belge', 'ekle');


  const seciliTurAdi = turAdi(tur);
  /**
   * BASVURUDA (300, kullanici: "en basta basvuru acilacak, islemler
   * tamamlaninca kaydedilecek") kaydet KARTI KAPATMAZ: ilk kayit protokolu
   * verir, kart acik kalir, ucretlendirme/provizyon girildikten sonra ayni
   * yesil dugmeyle kaydedilir. Acilan basvurunun id'si burada tutulur -
   * kart boylece "kayitli belge" moduna gecer (kilit acilir, ikinci kayit
   * INSERT degil UPDATE olur).
   */
  const [acilanId, setAcilanId] = useState<number | null>(null);
  const etkinBelgeId = belgeId ?? acilanId;
  const mevcutBelge = !!etkinBelgeId;
  /**
   * DUZENLEME (135): kayitli belge, e-Belge GONDERILMEMIS ve faturalanmamissa
   * degistirilebilir (kullanici). Sunucu ayni kurallari + sure sinirini
   * (belge.duzenleme_gun) yeniden dogrular - burasi yalniz ekrani acar.
   */
  const eBelgeGonderildi = Number(sonuc?.belge.efaturaDurum ?? 0) > 0;
  const faturalandi = Number(sonuc?.belge.kapanmaDurum ?? 0) > 0;
  // SIPARIS donusmus olsa da acilir (kullanici): kapanmis siparise yeni satir
  //   eklenebilmeli, belge o zaman KISMI'ye doner. Donusmus SATIRLAR sunucuda
  //   korunur; fatura/irsaliyede kilit surer - kalemi degistirmek hedef belgeyi
  //   ve muhasebe fisini tutarsiz birakirdi.
  const siparisTuru = tur === 9 || tur === 19;
  const duzenlenebilir = mevcutBelge && !!sonuc && !eBelgeGonderildi
                         && (!faturalandi || siparisTuru);
  const kilitli = (mevcutBelge && !duzenlenebilir) || (!mevcutBelge && !!sonuc);
  // Turun EKRAN DAVRANISI tek yerden gelir (belgeTuru.ts): hangi alan cizilir,
  //   kalem satiri nasil gorunur, kayittan sonra ne olur. Eskiden bu kararlar
  //   dosyaya dagilmis "tur === 20" gibi 12 ayri bayraktaydi ve her yeni tur
  //   onlarca yeri elle yoklamayi gerektiriyordu.
  const bilgi = belgeTuruBilgisi(tur);

  /**
   * LAB / GORUNTULEME KURUMU (364): kurum profilinin verdigi hekim rolu
   * "Gönderen" (1) ise bu bir tetkik kurumudur - basvuru turu sabittir
   * (Laboratuvar / Görüntüleme = 5), poliklinik odasi yoktur ve hekim alani
   * hastayi GONDEREN dis doktordur.
   */
  const gonderenModu = (kullanici?.hekimRolu ?? 4) === 1;

  const {
    alis: alisMi, siparis: siparisMi, irsaliye: irsaliyeMi, fatura: faturaMi,
    tahakkuk: tahakkukMu, konsinye: konsinyeMi, transfer: transferMi,
    talep: talepMi, stokFisi: stokFisiMi, depoBelgesi,
    ad: belgeAdi, disNumara: disNumarali,
  } = bilgi;
  /** Satis teklifi (216): tur 18 - durum combosu, "Sipariş" sekmesi, tek hedef. */
  const teklifMi = tur === 18;
  /**
   * BASVURU (246/279): AYRI TUR DEGIL - HBYS kurulumunda satis siparisinin
   * kendisidir (kullanici: "basvurudaki islemler normal alinan
   * siparislerimizdir"). Ayrim URUN MODUNDAN gelir: GenoTIP'te siparis ekrani
   * basvuru olarak cizilir (Protokol No, Ödeyen Kurum; uretim ve termin yok),
   * ERP'de ayni belge normal satis siparisidir.
   */
  const basvuruMu = tur === 19 && kullanici?.urunModu === URUN_GENOTIP;

  // BASVURU ALANLARI KENDI KANCASINDA: odeyen kurum, bolum, personel ve
  //   basvuru sekmesi alanlari HBYS'ye ozgudur - ERP belgesinde hic
  //   kullanilmazlar. Kart yalniz deger ve setter alir; hangi alanin ne zaman
  //   dolacagi belge turune ve kullanici akisina bagli oldugu icin KARTTA
  //   kalir.
  const {
    odeyenKurumId, setOdeyenKurumId, bolumId, setBolumId,
    personelId, setPersonelId, personelAd, setPersonelAd,
    basvuruBilgi, setBasvuruBilgi,
  } = useBasvuruAlanlari({ basvuruMu, gonderenModu });

  /**
   * ILK SEKME (kullanici): YENI basvuruda "Başvuru" - once hasta, bolum,
   * gonderen ve odeyen kurum girilir. KAYITLI basvuruda "Ücretlendirme":
   * kayit zaten acilmis, memur karta islem eklemek icin doner.
   *
   * Effect ile veriliyor cunku `basvuruMu` OTURUMA bagli (urun modu) ve
   * oturum kart mount edilirken henuz yuklenmemis olabilir. Bayrak bir kez
   * doner - sonra kullanicinin sekme secimi ezilmez.
   */
  const ilkSekmeVerildi = useRef(false);
  useEffect(() => {
    if (ilkSekmeVerildi.current || !basvuruMu) return;
    ilkSekmeVerildi.current = true;
    setAktifSekme(belgeId ? 'kalem' : 'basvuru');
  }, [basvuruMu, belgeId]);

  // Basvuru combolarinin (kurum · bolum · depo · gorevli) ve protokol numara
  //   sablonunun yuklenmesi ayri dosyada: hepsi ayni desendeki bes effect'ti.
  const { kurumlar, bolumler, depolar, gorevliler, protokolElle } =
    useBasvuruKaynaklari(basvuruMu, bolumId, kullanici?.hekimRolu);

  usePersonelAdi(personelId, gorevliler, setPersonelAd);

  // Fiyat listesi · kampanya · pay modu · provizyon uygulamasi ayri dosyada:
  //   hepsi "bu satir kaca yazilacak" sorusunun parcasi (belgeKarti/
  //   useBelgeFiyatlandirma), karta dagilinca kural kaciyordu.
  const {
    fiyatListeleri, fiyatListesiId, setFiyatListesiId: setFiyatListesiIdHam, kurumListesiCoz,
    tarifeTipi,
    kampanyaId, setKampanyaId, kampanyaAdi, setKampanyaAdi,
    kampanyaCoz, satirlariYenidenFiyatla, listeDegisti,
  } = useBelgeFiyatlandirma({
    belgeId, tur, alisMi, cariId: cari?.id ?? null, odeyenKurumId, basvuruMu,
    // SECILI POLICE (588): kurumun birden fazla sozlesmesi varsa tarife
    //   ancak policeden cozulur - yoksa liste carinin listesine duser ve
    //   ÖSS hastasi hastanenin ÖZEL fiyatiyla ucretlendirilir.
    sozlesmeId: basvuruBilgi.sozlesmeId ?? null,
    // SGK ISARETI (601): yeniden fiyatlamada rota dogru cozulsun, satirlarin
    //   SUT bedeli silinmesin.
    sgkKullan: basvuruBilgi.sgkKullan ?? null,
    satirlar, setSatirlar,
  });

  /**
   * PROVIZYON SEKMESI yalniz ÖSS/SGK odeyen kurumda (kullanici,
   * taraf_kurum.tur: 1 Özel / 2 ÖSS / 3 SGK). Kurum secili degilse hasta kendi
   * oder - provizyon alinacak bir kurum yok.
   */
  const provizyonVar = provizyonVarMi(kurumlar, odeyenKurumId);

  // KURUM SOZLESMELERI (468): odeyen kurum secilince yuklenir. Tek sozlesme
  //   varsa secici pasif gelir; birden fazlaysa kullanici secer ve sunucu
  //   secilmeden kaydi kabul etmez.
  // ODEYEN KURUMA BAGLI SECENEKLER (sozlesme listesi + SGK alt kurumlari)
  //   kendi kancasinda: ikisi de yalniz kurum degisince cekiliyor.
  const { sozlesmeler, altKurumlar } = useKurumSecenekleri(
    odeyenKurumId, kurumlar.find(k => k.id === odeyenKurumId)?.tur);


  /**
   * IRSALIYE PILOTU (kullanici): 4 sutunlu baslik + arac cubugunda Taslak
   * yerine IADE kutusu. Basarili olursa diger turlere yayilacak.
   */
  const irsaliyePilot = irsaliyeMi && !depoBelgesi && !stokFisiMi && !konsinyeMi;
  const fisCikisMi = tur === 4;      // cikis fisi: stok DUSER, tip listesi ayri

  /**
   * TRANSFERDE ilk kalem eklenince BASLIK KILITLENIR (kullanici karari): depo ya
   * da teslim eden/alan sonradan degisirse gridde duran satirlar baska bir
   * transferin satirlari olur - stok yanlis depodan duser. Degistirmek isteyen
   * satirlari silip yeniden secer. Diger turlerde bu kisit yok.
   */
  const baslikKilitli = kilitli || (bilgi.kalemVarsaBaslikKilitli && satirlar.length > 0);

  /**
   * Transferde BASLIK ONCE doldurulur: iki depo ve teslim eden/alan secilmeden
   * kalem eklenemez (kullanici karari). Ilk kalem eklenince baslik kilitlendigi
   * icin sira zaten tersine cevrilemez - eksik baslikla girilen kalemler
   * duzeltilemez halde kalirdi.
   */
  const transferBaslikEksigi = stokFisiMi
    ? (!fisTipi ? 'fiş tipi' : !depo ? 'depo' : null)
    : !depoBelgesi ? null
    : talepMi
      // Talepte teslim eden YOK (mal henuz cikmadi) ve teslim deposu opsiyonel:
      //   talep eden kendi eline de alabilir.
      ? (!depo ? 'istenen depo'
        : !sevkiyat.teslimAlan ? 'talep eden'
        : girisDepo && depo.id === girisDepo.id ? 'farklı teslim deposu'
        : null)
      : (!depo ? 'çıkış deposu'
        : !girisDepo ? 'giriş deposu'
        : !sevkiyat.teslimEden ? 'teslim eden'
        : !sevkiyat.teslimAlan ? 'teslim alan'
        : depo.id === girisDepo.id ? 'farklı giriş/çıkış deposu'
        : sevkiyat.teslimEden.id === sevkiyat.teslimAlan.id
          ? 'farklı teslim eden/alan'
        : null);

  /** Kutunun izin verdigi araligin iki ucu - her render'da "simdi"ye gore. */
  const tarihEnGec = yerelAnMetni(new Date());
  const tarihEnErken = (() => {
    if (geriGun <= 0) return undefined;              // sinir yok
    const d = new Date();
    d.setDate(d.getDate() - geriGun);
    d.setHours(0, 0, 0, 0);
    return yerelAnMetni(d);
  })();
  /**
   * e-BELGE OLMAYAN turler: satis fisi (16 - perakende fis, GIB'e gitmez),
   * konsinye (109/119 - mal birakma, faturasi ayri kesilir) ve tahakkuk (17/13).
   * Bunlarda e-Belge sekmesi, baslik alani ve gonderim dugmeleri gosterilmez.
   */
  //   SIPARIS de e-Belge degil: hicbir siparis GIB'e gitmez.
  const eBelgeYok = !bilgi.eBelge;
  /** Kaydedilmis belgenin id'si (yeni kayittan ya da acilan belgeden). */
  const kayitliId = etkinBelgeId ?? (sonuc ? Number(sonuc.belge.id) : 0);

  /** Bu belge icin tahsilat islemi ac (cari ve tutar onyuklu). */
  /** Tahsilat MODAL acilir - belge kartindan cikmadan (kullanici istegi).
      Tur: 21 nakit, 22 banka/havale (modal icinden de degistirilebilir). */
  /**
   * KAYDEDILMEMIS belgede once KAYDEDER, sonra tahsilati acar (kullanici:
   * "yeni fatura actim, kalem ekledim, tahsilat ekleyemiyorum - disabled").
   * Tahsilat kasa islemi belgeye baglanir, dolayisiyla belge id'si sart;
   * kullaniciyi "once kaydet, listeden tekrar ac" dongusune sokmak yerine iki
   * adim tek dugmede yapilir. Kart ACIK kalir - tahsilat kapaninca belgeye
   * donulur. Kaydetme basarisizsa (dogrulama hatasi) tahsilat acilmaz.
   */
  /** Sipariste rezerve edilmis satir var mi (142) - dugme metnini belirler. */
  const rezerveVar = (sonuc?.satirlar ?? []).some(r => Number(r.rezerve ?? 0) > 0);

  /** Rezervasyonu ac/kapat; sunucu satirlari ve stok toplamini gunceller. */
  const rezerveDegistir = async (ac: boolean) => {
    if (!kayitliId) return;
    setHata(null);
    setRezerveCalisiyor(true);
    try {
      setSonuc(await api.belgeRezerve(kayitliId, ac));
      onKaydedildi?.();
    } catch (h) {
      setHata(hataMetni(h, true));
    } finally { setRezerveCalisiyor(false) }
  };

  /**
   * PARA AKISLARI ile KART arasindaki iki yonlu bag (useParaAkislari):
   *   akisRef  -> akislarin ihtiyaci: kes / kayitSart (kartin ILERISINDE) ve
   *               tahsilat kancasinin hizliTahsilat'i.
   *   paraRef  -> kartin ihtiyaci: posSonrasi (tahsilat kancasi ONCE kuruluyor).
   * Ref olmasalar tanim sirasi dongusu olusurdu.
   */
  const akisRef = useRef<ParaAkisRef>({
    kes: async () => 0, kayitSart: async () => false, hizliTahsilat: async () => {},
  });
  const paraRef = useRef<{
    posSonrasi(tur: number): Promise<void>;
    kurumTahakkuku(): Promise<void>;
    /** Id DISARIDAN verilebilir: yeni kaydedilen belgede state henuz eski. */
    satirlariTazele(id?: number): Promise<void>;
  }>({
    posSonrasi: async () => {}, kurumTahakkuku: async () => {},
    satirlariTazele: async () => {},
  });

  // Tahsilat sekmesinin tum durumu ve akisi ayri dosyada (belgeTahsilat.ts):
  //   liste, cek/senet karti, kasa islemi acilislari ve silme.
  const tahsilat = useBelgeTahsilat({ kayitliId, aktifSekme, cari, onKaydedildi, setHata,
                                     // Tahsilat aciklamasi belgenin cinsinden kurulur:
                                     //   "Fiş Tahsilatı" / "Fatura Tahsilatı" (kullanici).
                                     belgeAdi: belgeKisaAdi(tur, basvuruMu),
                                     onPencereKapandi: tur => { void (async () => {
                                       await paraRef.current.posSonrasi(tur);
                                       await paraRef.current.satirlariTazele();
                                     })() } });
  const { tahsilatAdimi } = tahsilat;
  // HER TAHSILATTAN SONRA KURUM TAHAKKUKU (kullanici): hizli banka/POS yolu
  //   kasa penceresini acmadan yaziyor - `posSonrasi` orada calismiyor. Sarma
  //   ile tek kapi: tahsilat yazildi mi, kurum payi varsa tahakkuk edilir.
  akisRef.current.hizliTahsilat = async (...a) => {
    await tahsilat.hizliTahsilat(...a);
    // POS SONRASI OTOMATIK FIS (355) BU YOLDA DA CALISIR (kullanici: "kredi
    //   kartı tahsilat yaptım ama otomatik fiş kesmedi"): kural kasa
    //   penceresinin KAPANISINA bagliydi; hizli POS/banka yolu pencere
    //   acmadigi icin hic tetiklenmiyordu. Tur ilk parametredir (25 = POS).
    await paraRef.current.posSonrasi(Number(a[0]));
    await paraRef.current.kurumTahakkuku();
    // SATIRLAR DA TAZELENIR: hasta/kurum kovalarinin TAHSIL sayaclari sunucuda
    //   guncellenir; okumazsak serit ve dipnot bayat kalir ("100 aldim, kalan
    //   hala 200 yaziyor").
    await paraRef.current.satirlariTazele();
  };


  const tahsilatAc = async (tahsilatTuru = 21) => {
    if (kayitliId) {
      // Bekleyen kalem degisikligi ONCE kaydedilir: tahsilat kartindan
      //   donuldugunde kart tazeleniyor ve kaydedilmemis satirlar kayboluyordu.
      if (kalemDegisti && !(await kayitSart())) return;
      tahsilatAdimi(tahsilatTuru, kayitliId);
      return;
    }

    // Belge kaydedilecegi icin KALEM sart. Kaydetmeye birakirsak kullanici
    //   "En az bir satırda stok ya da hizmet seçilmeli." gibi tahsilatla
    //   ilgisiz gorunen bir hata aliyordu - sebebini burada soyluyoruz.
    if (satirlar.filter(s => s.stokId || s.hizmetId).length === 0) {
      setHata('Tahsilat belgeye bağlanır: önce en az bir kalem ekleyin, '
            + 'belge kaydedilip tahsilat açılsın.');
      return;
    }
    const id = await kes(false);
    if (!id) return;
    tahsilatAdimi(tahsilatTuru, id);
  };

  /**
   * ARAMA EKRANINDAN hekim/gonderen secildi (kullanici): kimlik ve ad yazilir,
   * ardindan kisinin BOLUMU cozulup Bölüm alani doldurulur - memur ayni bilgiyi
   * ikinci kez secmesin. Bolumu olmayan (or. dis hekim) kiside alan degismez.
   */
  /**
   * "KENDI ISTEGI" ISARETI (370): gonderen zorunlu oldugu icin "hekim yok"
   * ancak boyle soylenebilir - alanin bosluğu bir cevap degildi.
   *
   * Isaret konunca gonderen TEMIZLENIR: hasta ya bir hekim tarafindan
   * gonderildi ya kendi geldi, ikisi birden olamaz (DB kisiti da bunu tutar).
   * Temizleme `personelSecildi(0)` uzerinden gider - gelis sekli ve bolum
   * kurallari orada tek yerde yaziyor.
   */
  const kendiIstegiDegisti = (v: boolean) => {
    setBasvuruBilgi(o => ({ ...o, kendiIstegi: v ? 1 : 0 }));
    if (v) personelSecildi(0, '');
  };

  /**
   * HEKIMDEN BOLUME (583): arama penceresi yalniz id ve adi verir; bolum
   * kaynaktan okunur. Kaynak `basvuru-hekim` - profil kuralini SUNUCU
   * uyguluyor (578), ekran hangi kumeye baktigini bilmek zorunda degil.
   * Eskiden `prim-rol-aday`di: prim rolu isaretlenmemis hekimde bolum hic
   * dolmuyordu.
   */
  const bolumuHekimdenDoldur = async (id: number) => {
    try {
      const y = await api.liste('basvuru-hekim', {
        sayfa: 1, boyut: 1,
        filtre: { op: 'and', kosullar: [{ alan: 'id', op: 'esit', deger: id }] },
      });
      const b = Number(y.satirlar[0]?.bolumId ?? 0);
      if (b) setBolumId(b);
    } catch { /* bolum cozulemezse alan elle secilir */ }
  };

  const personelSecildi = (id: number, ad: string) => {
    setPersonelId(id || null);
    setPersonelAd(ad);
    // ICERIDEKI HEKIM (583): tip merkezi/hastane akisinda secilen kisi
    //   hastayi GONDEREN degil, hastayi GORECEK hekimdir - "Kendi İsteği" ve
    //   "Sevkli" kurallari onun icin gecerli degil. Secimden tek cikan sonuc
    //   BOLUMUN dolmasidir; bunu asagidaki bolum cozumu yapar.
    if (!gonderenModu) {
      if (!id) { setBolumId(null); return }
      void bolumuHekimdenDoldur(id);
      return;
    }
    // HEKIM SECILDI = kendi istegi DEGIL: isaret kendiliginden kalkar, yoksa
    //   iki bilgi ayni anda dogru gorunur ve sunucu kisiti reddederdi.
    if (id) setBasvuruBilgi(o => (Number(o.kendiIstegi ?? 0) === 0
      ? o : { ...o, kendiIstegi: 0 }));
    if (!id) {
      // "Kendi İsteği" (gonderen yok, kullanici): hasta sevksiz gelmistir -
      //   gelis sekli "Kendi imkânıyla" (1) olur. Sevkli hasta seciminde bu
      //   alan ELLE degistirilebilir (ambulans, kurum araci...).
      setBasvuruBilgi(o => ({ ...o, gelisSekli: gelisSekliKarari(false) }));
      // BOLUM DE BOSALIR (kullanici): bolum gonderenin bolumunden doluyordu -
      //   gonderen kalkinca o bilgi de gecersiz. Bos bolum aramayi da
      //   genisletir (butun gonderenler gorunur).
      setBolumId(null);
      return;
    }
    // GONDEREN SECILDI = SEVKLI (kullanici): hastayi bir hekim gonderdiyse
    //   gelis sekli "Sevkli" (3) olur. Ikisi de ACIK eylemdir - kullanici
    //   sonra ambulans/kurum aracina cevirebilir.
    setBasvuruBilgi(o => ({ ...o, gelisSekli: gelisSekliKarari(true) }));
    void bolumuHekimdenDoldur(id);
  };


  /* BASVURUNUN KENDILIGINDEN DOLAN ALANLARI kendi kancasinda
     (useBasvuruVarsayilanlari): varsayilan odeyen kurum ve gelis sekli.
     Ikisi de yalniz YENI kartta ve yalniz BOS alanda calisir. */
  useBasvuruVarsayilanlari({
    basvuruMu, belgeId, hastaId: cari?.id, kurumlar, odeyenKurumId, personelId,
    onKurum: k => void odeyenKurumDegisti(k),
    // DOLU ALANA DOKUNMA: ayni nesne donunce React "degismedi" sayar -
    //   kosulsuz yazmak karti kullanici hic dokunmadan kirli gosterirdi.
    onGelisSekli: () => setBasvuruBilgi(o => (Number(o.gelisSekli ?? 0)
      ? o : { ...o, gelisSekli: gelisSekliKarari(false) })),
  });

  const iskontoTalepleri = useIskontoTalepleri(basvuruMu, belgeId, async () => {
    // Karar dustu: baslik ve satirlar sunucudan yeniden okunur - onay orani
    //   satirlara SUNUCUDA islendi ve satirlar kilitlendi.
    if (!belgeId) return;
    try { setSonuc(await api.belgeOku(belgeId)) } catch { /* yoksay */ }
    await paraRef.current.satirlariTazele(belgeId);
  });

  // Mevcut belgeyi ac: baslik + satirlar + dip toplam sunucudan gelir.
  useEffect(() => {
    if (!belgeId) return;
    void (async () => {
      try {
        const y = await api.belgeOku(belgeId);
        setSonuc(y);
        // Yanit -> kart durumu cevrimi SAF fonksiyonda (belgeKarti/belgeOkuma):
        //   40 alanin tarih/null/doviz kurallari burada setX yiginina
        //   karismasin, tek tek denenebilsin.
        const d = yanittanBaslik(y.belge, yerelPara);
        setTur(d.tur);
        setCari(d.cari);
        setTarih(d.tarih);
        setSeri(d.seri);
        setVadeGun(d.vadeGun);
        setAciklama(d.aciklama);
        setOdeyenKurumId(d.odeyenKurumId);
        setFiyatListesiIdHam(d.fiyatListesiId);
        setBolumId(d.bolumId);
        setPersonelId(d.personelId);
        setBasvuruBilgi(yanittanBasvuruBilgi(y.belge));
        setKampanyaId(d.kampanyaId);
        setKampanyaAdi(d.kampanyaAdi);
        teklif.setDurum(d.teklifDurum);
        teklif.setRevizeNo(d.revizeNo);
        teklif.setKonu(d.teklifKonusu);
        teklif.setTeslim(d.teklifTeslim);
        setDepo(d.depo);
        setGirisDepo(d.girisDepo);
        setSatici(d.satici);
        sevkiyat.setTeslimEden(d.teslimEden);
        sevkiyat.setTeslimAlan(d.teslimAlan);
        sevkiyat.setTeslimSekli(d.teslimSekli);
        setSenaryo(d.senaryo);
        sevkiyat.setSevkTarihi(d.sevkTarihi);
        sevkiyat.setSoforTckn(d.soforTckn);
        sevkiyat.setAracPlaka(d.aracPlaka);
        sevkiyat.setSoforAd(d.soforAd);
        setFisTipi(d.fisTipi);
        setFaturaTipi(d.faturaTipi);
        setRaporDovizi(d.raporDovizi);
        setEkstreDovizi(d.ekstreDovizi);
        setBelgeKuru(d.belgeKuru);
        setKalemDegisti(false);
        setSatirlar(yanittanSatirlar(y.satirlar, yerelPara));
      } catch (h) {
        setHata(hataMetni(h));
      } finally { setAciliyor(false) }
    })();
  }, [belgeId]);

  // YENI belgede cikis deposu ANA DEPO ile dolu gelir (depo.varsayilan = 1).
  //   Depo cogu belgede hep aynidir; kullaniciyi her seferinde secmeye zorlamak
  //   yerine varsayilani koyariz, isteyen degistirir. Kayitli belgede dokunulmaz.
  useEffect(() => {
    if (belgeId) return;
    void (async () => {
      try {
        const y = await api.liste('depo', {
          sayfa: 1, boyut: 1,
          filtre: { op: 'and', kosullar: [
            { alan: 'varsayilan', op: 'esit', deger: 1 },
            { alan: 'durum', op: 'esit', deger: 1 },
          ] },
        });
        const d = y.satirlar[0];
        if (d) setDepo(o => o ?? { id: Number(d.id), ad: String(d.ad ?? '') });
      } catch { /* varsayilan depo yoksa alan bos kalir - engelleyici degil */ }
    })();
  }, [belgeId]);

  // BELGE DONUSUMLERI (F8 zinciri): liste, olcu, acilan kart ve silme tek
  //   kancada - Faturalama sekmesinin tum durumu orada.
  const donusumler = useBelgeDonusumleri({
    kayitliId, aktifSekme, setHata, setSonuc,
  });

  // ÖSS (2) odeyen kurumda provizyonun "Sigorta Şirketi" alani ODEYEN KURUMDUR:
  //   memur ayni sirketi ikinci kez secmesin (farkliysa elle degistirilebilir).
  useEffect(() => {
    const k = kurumlar.find(x => x.id === odeyenKurumId);
    if (k?.tur === 2 && !basvuruBilgi.ossKurumId)
      setBasvuruBilgi(o => ({ ...o, ossKurumId: k.id }));
  }, [odeyenKurumId, kurumlar, basvuruBilgi.ossKurumId]);

  // Odeyen kurum ozele donunce Provizyon sekmesi cizilmez; uzerinde
  //   kalinmissa bos ekran gorunmesin diye Basvuru'ya donulur.
  useEffect(() => {
    if (!provizyonVar && aktifSekme === 'provizyon') setAktifSekme('basvuru');
  }, [provizyonVar, aktifSekme]);

  /** Yalniz ONIZLEME: gercek tutar sunucudan gelir (kural belgeKartiKurallari). */
  const onizleme = useMemo(() => belgeOnizlemesi(satirlar, stokFisiMi),
                           [satirlar, stokFisiMi]);

  /**
   * BASVURU ACIK BORCU (kullanici): ucretlendirme genel toplami - tahsilat
   * genel toplami. Kalem ya da tahsilat girildikce serit ANINDA degissin diye
   * kaydedilmemis satirlarda onizleme toplami kullanilir; satir yoksa
   * sunucunun kayitli genel toplami esas alinir.
   */
  const basvuruAcikBorc = useMemo(() => acikBorcHesapla(
      satirlar.length, onizleme.genel, Number(sonuc?.belge.genelToplam ?? 0),
      tahsilToplami(tahsilat.tahsilatlar)),
    [satirlar.length, onizleme.genel, sonuc, tahsilat.tahsilatlar]);

  /**
   * PAYLASIMLI KURUMDA TARAF AYRIMI (kullanici): ÖSS/SGK anlasmasinda acik
   * tahsilat ve acik belge iki satir olur - hastadan ve kurumdan. Kaynak
   * satirlarin SUNUCUDAN gelen dagitim kovalari; kovasi olmayan (henuz
   * kaydedilmemis) satir sifir sayilir, kayit sonrasi rakam yerine oturur.
   */
  /**
   * KAYDEDILMEMIS SATIRIN DAGILIM ONIZLEMESI (594, kullanici: "kaydetmeden
   * ücret satırının sağ tarafındaki + detay butonu gelmiyor, oysa ben
   * eklediğimde hemen detay ne diye görmek istiyorum").
   *
   * Kovalar `belge_satir_dagilim`de yasar ve ancak KAYITLA dogar; gride yeni
   * eklenen satirda dagilim yoktu, "＋" de cizilmiyordu. Sunucu ayni hesabi
   * (`fn_dagilim_coz`) kaydetmeden de calistirabiliyor - istemci yine kural
   * bilmez, yalniz satirin sayilarini gonderir. Hicbir sey yazilmaz.
   *
   * IMZA ile tetiklenir: satirin sayilari degismedikce sunucuya gidilmez,
   * yoksa her tusa basista istek yagardi.
   */
  // DAGILIM ONIZLEMESI kendi kancasinda: kaydedilmemis satirlarin kova
  //   dagilimi sunucudan sorulur ve serit/`+` dugmesi onu gosterir. Kart
  //   yalniz sonucu kullanir - sorgunun ne zaman tekrarlanacagi (imza) ve
  //   nasil susturulacagi (debounce) kancanin isi.
  const { dagilimOnizleme, seritSatirlari } = useDagilimOnizleme({
    basvuruMu, odeyenKurumId, satirlar, basvuruBilgi,
  });


  const seritTaraflari = useMemo(() => {
    if (!basvuruMu || !paylasimliKurum(kurumlar, odeyenKurumId)) return null;
    return {
      tahsilat: acikTahsilatTaraflara(seritSatirlari),
      belge: acikBelgeTaraflara(seritSatirlari),
    };
  }, [basvuruMu, kurumlar, odeyenKurumId, seritSatirlari]);

  /**
   * DONUSUM LISTESI - TAHAKKUK ADI TARAFA GORE (kullanici: "tahsilatta kurum
   * tahakkuku diye doğru geldi ama dönüşüm sekmesinde satış tahakkuku
   * kalmış").
   *
   * Sunucu belgenin TURUNU soyler ("Satış Tahakkuku"); basvuruda okunmasi
   * gereken ise KIME kesildigidir - hasta ve kurum tahakkuku yan yana
   * durunca tur adi ikisini ayirt etmiyor. Ad tek yerde turetilir, hem
   * Belgeye Dönüşüm listesi hem tahsilat seridi ayni metni gosterir.
   */
  const donusumListesi = useMemo(() => (
    // Liste HENUZ GELMEMIS olabilir (cagri ucusta): dizi degilse bos say -
    //   memo her cizimde calisiyor, yarim durumda patlamamali.
    Array.isArray(donusumler.liste) ? donusumler.liste : []).map(d => {
    if (!basvuruMu || !TAHAKKUK_TURLERI.has(Number(d.tur))) return d;
    const hastaMi = !!cari?.unvan && String(d.tarafUnvan ?? '') === cari.unvan;
    return { ...d, turAdi: hastaMi ? 'Hasta Tahakkuku' : 'Kurum Tahakkuku', hastaMi };
  }), [donusumler.liste, basvuruMu, cari?.unvan]);

  /** ACIK BELGE (495): ucret toplami - faturaya/tahakkuka donusen tutar. */
  const basvuruAcikBelge = useMemo(() => acikBelgeHesapla(
      satirlar.length, onizleme.genel, Number(sonuc?.belge.genelToplam ?? 0),
      Number((sonuc?.belge as { donusenBelgeTutari?: number } | undefined)
        ?.donusenBelgeTutari ?? 0)),
    [satirlar.length, onizleme.genel, sonuc]);


  /**
   * Kalem penceresinden donen satiri yazar (yeni ise ekler).
   *
   * PAKET (124): secilen stok bir paketse belgeye YALNIZ paket satiri degil,
   * ICERIGI de eklenir - "paket item + icerikleri tumuyle" (kullanici).
   * Icerik satirlari paketin adediyle CARPILIR (2 paket x 3 adet = 6) ve
   * FIYATSIZ gelir: tutar paket satirinda durur, icerikler ikinci kez
   * fiyatlanirsa belge toplami sisirdi. Icerik satirlari duzenlenebilir -
   * kullanici pakette olmayan bir sey cikarabilir/ekleyebilir.
   */
  /**
   * STOK / HIZMET SECILDI (arama penceresinden): kalem penceresini acar.
   *
   * FIYAT once cozulur, PENCERE sonra acilir: pencere `satir` prop'unu
   * acilista kopyalar (useState), sonradan gonderilen fiyat guncellemesi ona
   * ULASMAZ - once fiyat, sonra pencere.
   */
  /* KALEM AKISI kendi kancasinda (useKalemAkisi): secilen stogu kaleme
     cevirme, gride yazma, paket icerigi ve rapor dovizi kurallari orada. */
  const { stokSecildi, kalemKaydet } = useKalemAkisi({
    satirlar, setSatirlar, setKalem, setKalemDegisti, setHata,
    yerelPara, raporDovizi, setRaporDovizi, setBelgeKuru,
    cariId: cari?.id ?? null, odeyenKurumId, fiyatListesiId, kampanyaId,
    basvuruBilgi, alisMi: bilgi.alis,
  });

  /*
   * KALEM DEGISIMINDE OTOMATIK KAYIT GERI ALINDI (kullanici: "2. muayeneyi ben
   * eklemedim ki").
   *
   * Serit kovalardan hesaplandigi icin "ekle/sil aninda guncellensin" istegi
   * 500 ms gecikmeli otomatik kayitla karsilanmaya calisilmisti. Ama efekt
   * `satirlar` degisimini de dinliyor ve kayit satirlari SUNUCUDAN tazeliyor:
   * iki uc arasinda satir kimligi henuz oturmamisken efekt yeniden tetiklenince
   * ayni kalem IKINCI KEZ yazilabiliyor. Kullanicinin eklemedigi bir muayene
   * satiri boyle olustu. Kart artik yalnizca acik eylemlerde kaydeder
   * ("+", Kaydet, tahsilat, provizyon); serit o kayitlardan sonra tazelenir.
   */

  /** Secili satirlari siler - grid salt gorunum oldugu icin satir ici silme yok. */
  /**
   * Belgeyi kaydeder ve kaydedilen belgenin id'sini doner (0 = kaydedilemedi).
   *
   * `kapatilsin=false` yalnizca "kaydet ve devam et" akislarinda kullanilir
   * (Tahsilat dugmesi): kart acik kalir ki acilan tahsilat penceresi kapaninca
   * kullanici belgeye geri donsun.
   */
  /**
   * `otomatik` = kullanicinin "Kaydet"i degil, kartin KENDI kaydi (tahsilat /
   * ucret ekleme oncesi). Otomatik kayit BELGEYI BOSALTAMAZ: ekranda kalem
   * yokken sunucuda varsa PUT hic gonderilmez.
   */
  /**
   * Kart durumu tek nesnede: dogrulama ve istek govdesi SAF fonksiyonlarda
   * (belgeKaydet.ts) - ekran yalniz sonucu gosterir.
   */
  /**
   * Kaydetmeye giden basvuru alanlarindan SALT OKUNURLARI cikarir (608).
   * Sunucudan gelip karta yazilan ama geri gonderilmemesi gereken alanlar
   * burada tek yerde durur - yenisi eklenince liste buyur, cagri yerleri degil.
   */
  const saltOkunurlariAt = (b: BasvuruBilgi): BasvuruBilgi => {
    // `hastaUnvan` de sunucudan OKUNUR (kalem serit basligi icin): geri
    //   gonderilince "Bilinmeyen belge alani: hastaUnvan" ile kayit dusuyordu.
    //   Yazma beyaz listesine eklemek yanlis olurdu - hasta ADI belgede degil,
    //   hastanin kartinda durur.
    const { sysTakipNo: _atilan, hastaUnvan: _atilan2, ...kalan } = b;
    return kalan;
  };

  const girdiKur = (): BelgeGirdisi => (
    {
      tur, cari, tarih, tarihEnGec, tarihEnErken, geriGun, seri, belgeNo, vadeGun, faturaTipi,
      // Basvuruda vade yerine odeyen kurum gonderilir (249); bolum ve hekim
      //   de basvuruya ozgu (296) - hepsi belge_basvuru uzantisina yazilir.
      ...(basvuruMu
        ? { odeyenKurumId, bolumId, personelId,
            // SALT OKUNUR ALANLAR GOVDEYE GIRMEZ (608): `sysTakipNo` sunucudan
            //   OKUNUR (basvurunun USS kimligi), karttan yazilmaz - yazma
            //   beyaz listesinde olmadigi icin kaydetmeyi "Bilinmeyen belge
            //   alani: sysTakipNo" ile dusuruyordu. Listeye eklemek de yanlis
            //   olurdu: USS takip numarasi kullanicinin degistirebilecegi bir
            //   deger degil, gonderim yanitinin sonucudur.
            basvuruAlanlari: saltOkunurlariAt(basvuruBilgi) }
        : {}),
      fiyatListesiId,
      // Kampanya belgeye YAZILIR (274): kurum sonradan kampanya degistirse
      //   eski belgenin hangi anlasmayla kesildigi sabit kalir.
      kampanyaId,
      // Teklif durumu yalniz teklifte anlamli - baska turde gonderilmez.
      ...(teklifMi ? { teklifDurum: Number(teklif.durum) || 1,
                       revizeNo: teklif.revizeNo, teklifKonusu: teklif.konu,
                       teklifTeslim: teklif.teslim } : {}),
      aciklama,
      raporDovizi, ekstreDovizi, belgeKuru, yerelPara,
      senaryo, satici, depo, girisDepo,
      teslimEden: sevkiyat.teslimEden, teslimAlan: sevkiyat.teslimAlan,
      tasiyici: sevkiyat.tasiyici, aracPlaka: sevkiyat.aracPlaka,
      soforAd: sevkiyat.soforAd, soforTckn: sevkiyat.soforTckn,
      sevkTarihi: sevkiyat.sevkTarihi, teslimSekli: sevkiyat.teslimSekli,
      fisTipi, satirlar,
      subeId: kullanici?.subeId ?? undefined,
      alisMi, irsaliyeMi, faturaMi, depoBelgesi, stokFisiMi, fisCikisMi, transferMi,
      talepMi, disNumarali, basvuruMu, tahakkukMu,
      // Zorunluluk kurallari yalniz duzenlenebilir kartta (bkz. belgeDogrula).
      kilitli,
    }
  );

  // KAYDETME AKISI (dogrula -> yaz -> satirlari tazele -> kapat) kendi
  //   dosyasinda: belgeKarti/useBelgeKaydetme.
  const kesHam = belgeKaydetmeKur({
    girdiKur, satirlar, setSatirlar, taslak, yerelPara,
    kalemDegisti,
    etkinBelgeId: etkinBelgeId ?? null, duzenlenebilir, basvuruMu,
    sonuc, setSonuc, setHata, setAlanHatalari, setKaydediyor,
    setKalemDegisti, setAcilanId,
    // Ikisi de ASAGIDA tanimli - cagri aninda cozulsun diye sarmalandi.
    imzayiTemizle: () => imzayiTemizle(),
    onKaydedildi, kapat: (zorla?: boolean) => void kapat(zorla),
  });

  /**
   * UCRET EKLEMENIN ILK KAPISI (kullanici: "ücret ekleyeceği zaman kayıt
   * yapıp protokol no versin ve ondan sonra ücret eklemeye başlasın").
   *
   * Basvuru KAYDEDILMEDEN kalem eklenmiyor: protokolsuz bir belgeye islem
   * yazmak, sonradan "bu ucret hangi basvurunun" sorusunu cevapsiz birakiyordu.
   * Ustelik hizli fis/tahsilat akislarinin hepsi KAYITLI id ariyor - kalemi
   * once gride koyup kaydetmeyi sona birakmak o dugmeleri sessizce bozuyordu.
   *
   * Dogrulama gecmezse (bolum / gonderen / odeyen kurum bos) arama penceresi
   * ACILMAZ ve kart Başvuru sekmesine doner: eksik alanlar orada, memur kirmizi
   * yaziyi gordugu yerde duzeltsin.
   */
  const ucretEklemeAc = async (ac: boolean) => {
    if (!ac || !basvuruMu) { arama.setStok(ac); return }
    // HER ＋'DE KAYIT (kullanici: "ücretlendirme eklemek için ＋'ya
    //   bastığımda başvuruyu kaydet"): eskiden yalniz KAYDEDILMEMIS belgede
    //   kaydediyordu; kayitli belgede gride girilmis ama gonderilmemis
    //   satirlar ekranda kaliyor ve kart tazelenince kayboluyordu.
    //   `kayitSart` kayitli ve TEMIZ belgede hicbir sey yapmaz.
    if (!await kayitSart()) return;
    arama.setStok(true);
  };

  /**
   * BELGEYI KAYDETTIRIR, kaydedilene kadar isleme izin vermez.
   *
   * Kullanici: "ücretleme yaptım tahsilat sekmede nakit/banka/pos
   * basamıyorum" - dugmeler kaydedilmemis belgede PASIFTI ve "Önce belgeyi
   * kaydedin" diyordu. Tahsilat kasaya BELGE KIMLIGIYLE baglandigi icin kayit
   * gercekten sart; ama bunu kullaniciya IS olarak vermek gereksiz - kart
   * kendisi kaydeder, tipki ucret eklemede oldugu gibi.
   *
   * Dogrulama gecmezse basvuruda Başvuru sekmesine donulur: eksik alanlar
   * (bolum / gonderen / odeyen kurum) orada ve kirmizi yazi gorunur yerde
   * olsun.
   */
  // Para akislari (hizli donusum / POS sonrasi fis / tutar sorma / nakit).
  const { hizliTutar, tahsilatTutariSor, tahsilatParasiSor, hizliDonustur,
          posSonrasi, hizliNakit, iadeParasiSor, iadeYaz, nakitIadesi,
          kurumTahakkukuOtomatik } =
    useParaAkislari({
      ref: akisRef, basvuruMu, alisMi, kayitliId, donusumOlcusu: donusumler.olcu,
      posAksiyon, setPosAksiyon,
      // TAHSILAT TURLERI (nakit/POS/banka/cek/senet) HASTADAN alinir
      //   (kullanici): paylasimli basvuruda modal HASTA PAYINI onerir, belgenin
      //   tamamini degil - 1.000 TL'lik iste hastadan 200 alinacakken kutuya
      //   1.000 gelmesi, memurun kurumun payini da hastadan tahsil etmesine
      //   acik kapi birakiyordu. Kurum payi tahsil edilmez, TAHAKKUK edilir.
      acikBorc: seritTaraflari ? seritTaraflari.tahsilat.hasta : basvuruAcikBorc,
      kullaniciId: kullanici?.id ?? null, yerelPara,
      setHata, setSonuc, donusumleriYukle: donusumler.yukle,
      // Kovalarin sayaclari degisince satirlar yeniden okunur (serit/dipnot).
      satirlariTazele: (id?: number) => paraRef.current.satirlariTazele(id),
      // Dogrulama duserse eksik alanlarin oldugu sekmeye don ve SOYLE.
      kayitBasarisiz: () => {
        if (basvuruMu) setAktifSekme('basvuru');
        mesaj('Belge kaydedilemedi - kırmızı işaretli zorunlu alanları tamamlayın.');
      },
    });
  paraRef.current.posSonrasi = posSonrasi;
  paraRef.current.kurumTahakkuku = () => kurumTahakkukuOtomatik(kayitliId);
  /**
   * SATIRLARI SUNUCUDAN TAZELE - tahsilat/tahakkuk sonrasi (kullanici: dipnot
   * ve serit eski kaldi). Kovalarin tahsil/kapatma sayaclari sunucuda degisir;
   * hasta ve kurum acigi onlardan hesaplandigi icin satirlar da okunmali.
   */
  paraRef.current.satirlariTazele = async (id?: number) => {
    const hedef = id ?? kayitliId;
    if (!hedef) return;
    try {
      const okunan = await api.belgeOku(hedef);
      setSonuc(okunan);
      setSatirlar(yanittanSatirlar(okunan.satirlar ?? [], yerelPara));
    } catch { /* okunamazsa ekran eski rakamla kalir */ }
  };

  /**
   * KAYIT SONRASI KURUM TAHAKKUKU (kullanici: "kaydettiğim zaman eğer yoksa
   * kurum tahakkuk ilk satıra gelecek").
   *
   * Once yalniz TAHSILAT sonrasina baglanmisti; hasta payi tamamen tahsil
   * edilmis basvuruda yeni tahsilat girilemedigi icin tahakkuk HIC dogmuyordu
   * ve kurum payi acikta kaliyordu. Kayit ani daha dogru kapi: kurum payi
   * kaydedildigi anda belgelenir, `donusumPayi` kalani olmayan kovayi
   * atladigi icin ikinci kayitta tekrar kesilmez.
   */
  const kes = async (kapatilsin = true, otomatik = false): Promise<number> => {
    // DEGISIKLIK YOKSA TAHAKKUK DA YOK (kullanici: "＋'ya basınca 2 satır ve
    //   tahakkuk oluştu, hemen bir şey seçmeden"): kayit atlandiginda
    //   `kesHam` yine de belgenin id'sini donduruyor ve asagidaki blok
    //   "kaydedildi" sanip kurum tahakkuku kesiyordu. Tahakkuk KAYIT
    //   olayina baglidir - kayit olmadiysa olmaz.
    const degisiklikVardi = !kayitliId || kalemDegisti || kirli;
    const id = await kesHam(kapatilsin, otomatik);
    if (id && basvuruMu && degisiklikVardi) {
      await kurumTahakkukuOtomatik(id);
      // TAHAKKUK SONRASI SATIRLAR HER ZAMAN YENIDEN OKUNUR: kovalarin
      //   KAPATILAN sayaci sunucuda dolar - okumazsak kurum payi hala acik
      //   gorunur ("satış tahakkuk geldi ama açık tahsilat ve belge de 400
      //   görünüyor"). Kart kapaniyorsa da zararsiz: state kisa sure sonra
      //   sokuluyor.
      await paraRef.current.satirlariTazele(id);
    }
    return id;
  };
  akisRef.current.kes = kes;

  const kayitSart = async (): Promise<boolean> => {
    // KAYDEDILMEMIS KALEM DE KAYDEDILIR (kullanici: "114413 ücretler
    //   kaybolmuş ama tahsilat duruyor"): basvuru ilk ＋'de kaydedilip
    //   protokol aliyor, sonra ucret satirlari gride giriliyor. Nakit/POS'a
    //   basildiginda burasi "zaten kayitli" deyip DONUYORDU; tahsilat yazilip
    //   kart sunucudan tazelenince o satirlar (hic gonderilmedikleri icin)
    //   ekrandan siliniyordu - para duruyor, ucret yok.
    // KART KIRLIYSE DE KAYDEDILIR (kullanici: "ücret ＋'ya basıyorum ama
    //   başvuruyu kaydetmiyor"): `kalemDegisti` yalniz GRID satirlarini
    //   izliyordu - bolum, hekim, odeyen kurum gibi BASLIK degisiklikleri
    //   kaydedilmeden ucret ekleniyor, kart sunucudan tazelenince o
    //   degisiklikler geri aliniyordu. `kirli` kartin tamaminin imzasidir.
    if (kayitliId && !kalemDegisti && !kirli) return true;
    const id = await kes(false, true);
    if (!id) {
      // NEDEN OLMADIGI SOYLENIR (kullanici: "ücret ＋'ya basıyorum ama
      //   başvuruyu kaydetmiyor"): kayit sessizce dusuyordu - uyari yalniz
      //   alanin altinda kirmizi yaziydi ve kullanici ＋'nin calismadigini
      //   sanIyordu. Kart zaten eksik alanin oldugu sekmeye doner; mesaj
      //   "kaydedilemedi" oldugunu soyler.
      if (basvuruMu) setAktifSekme('basvuru');
      mesaj('Kaydedilemedi - kırmızı işaretli zorunlu alanları tamamlayın.');
      return false;
    }
    return true;
  };
  akisRef.current.kayitSart = kayitSart;

  /**
   * Kayit sonrasi ROL PENCERESI (kullanici): satirlar sunucudan gelince ayni
   * SIRADAKI satirin kimligiyle acilir. Kimlik yine yoksa (satir gonderilmemis
   * - or. stok/hizmet secilmemis bos satir) bekleme birakilir.
   */
  useEffect(() => {
    if (rolBekleyenSira === null) return;
    const s = satirlar[rolBekleyenSira];
    if (s?.satirId) setRolModali({ satirId: s.satirId, ad: s.stokAdi });
    else mesaj('Satır kaydedilemedi - rol penceresi açılamadı.');
    setRolBekleyenSira(null);
  }, [rolBekleyenSira, satirlar]);

  function yeniBelge() {
    setSonuc(null);
    setAcilanId(null);
    setCari(null);
    setSatirlar([]);
    setHata(null);
    // BASVURU (296): odeyen kurum ve personel SIFIRLANIR - siradaki hastanin
    //   odeyeni/gorevlisi bir onceki hastadan devralinirsa yanlis kuruma
    //   faturalanir. BOLUM KALIR: kayit kabul ayni poliklinikte ardisik hasta
    //   girer, her seferinde yeniden secmek yorar (kullanici akisi).
    setPersonelId(null);
    setOdeyenKurumId(null);
    setBasvuruBilgi({});
    // "Yeni" de bir YENI KAYITTIR: ilk sekme yine Başvuru olsun (kullanici) -
    //   ucretlendirmede kalmak, hastasi secilmemis karta islem ekletirdi.
    if (basvuruMu) setAktifSekme('basvuru');
  }

  /**
   * ODEYEN KURUM degisti (274): kampanya kurumun sozlesmesinden geldigi icin
   * once kampanya yeniden cozulur (listesi varsa belgenin listesi ona cekilir),
   * sonra satirlar o listeyle yeniden fiyatlanir. Kalemsiz belgede yalniz
   * baslik guncellenir - mesaj cikmaz.
   */
  /**
   * ÖDEME DAĞILIMINI YENİLE (478). Kural SUNUCUDA: rota sözleşmeden, fiyatlar
   * SUT/TTB listelerinden çözülür. İstemci yalnız "yeniden hesapla" der -
   * karşılama oranını burada hesaplamak, aynı formülü iki yerde tutmaktı.
   */
  async function dagilimYenile() {
    if (!kayitliId) {
      mesaj('Dağılım kayıtlı belgede hesaplanır - önce kaydedin.');
      return;
    }
    try {
      const y = await api.belgeDagit(kayitliId);
      // Satirlar YENIDEN OKUNUR: rota 3/5'te satir tutari da kovalardan
      //   dogar, ekranda eski rakam kalmasin.
      const okunan = await api.belgeOku(kayitliId);
      setSonuc(okunan);
      setSatirlar(yanittanSatirlar(okunan.satirlar ?? [], yerelPara));
      mesaj(y.mesaj);
    } catch (h) { mesaj(hataMetni(h)) }
  }

  async function odeyenKurumDegisti(yeni: number | null) {
    setOdeyenKurumId(yeni);
    // Kurum degisti: eski sozlesme ARTIK GECERSIZ. Bos birakilir - tek
    //   sozlesme varsa sunucu tetigi kendisi atar, birden fazlaysa kullanici
    //   secer (469). Eski degeri tasimak baska kurumun policesini yazardi.
    setBasvuruBilgi(o => ({ ...o, sozlesmeId: null, altKurum: null, sgkKullan: 1 }));
    if (kilitli) return;

    // Kampanya cozulemezse KURUMUN SOZLESME LISTESI (495), o da yoksa mevcut
    //   liste ile devam edilir. Kampanya once gelir: sozlesmenin ustune
    //   yazilan anlasmadir.
    const kampanyaListesi = await kampanyaCoz(yeni, true);
    const liste = kampanyaListesi ?? (await kurumListesiCoz(yeni)) ?? fiyatListesiId;
    // Ekranda da gorunsun: "Fiyat Listesi" kutusu kurumla birlikte degisir -
    //   ucret eklerken fiyatin nereden geldigi belli olur.
    if (liste !== fiyatListesiId) setFiyatListesiIdHam(liste);

    if (satirlar.some(r => r.stokId || r.hizmetId))
      await satirlariYenidenFiyatla(liste, yeni, 'ödeyen kuruma göre');
  }

  /** Modal icinde acildiysa cagiran kapatir; dogrudan URL ile acildiysa listeye doner. */
  /** Sag sutun hucreleri: e-Belge OLMAYAN turlerde sira Kapanma > Bagli Siparis
      > Doviz olur; e-Belgeli turlerde eski duzen korunur. */
  const kapanmaAlani = (
    <label className="alan">
      <span className="etiket">{irsaliyeMi ? 'Faturalama Durumu' : 'Kapanma'}</span>
      <span className="deger-serit">
        {(() => {
          const k = KAPANMA_ETIKET[Number(sonuc?.belge.kapanmaDurum ?? 0)];
          return (
            <>
              <span className={`rozet ${k?.sinif ?? ''}`}>{k?.ad ?? '—'}</span>
              {kayitliId > 0 && <span className="sonuk">{satirlar.length} kalem</span>}
            </>
          );
        })()}
      </span>
    </label>
  );

  const bagliSiparisAlani = (
    <label className="alan">
      <span className="etiket">{siparisMi ? 'Kaynak Belge' : 'Bağlı Sipariş'}</span>
      <span className="deger-serit">
        {sonuc?.belge.kaynakBelgeNo
          ? <>{String(sonuc.belge.kaynakTurAdi ?? '')} <b>{String(sonuc.belge.kaynakBelgeNo)}</b></>
          : <span className="sonuk">—</span>}
      </span>
    </label>
  );

  // Basvuru kendi listesine doner: tur 19'un varsayilan yolu /siparis ama
  //   GenoTIP menusunde o rota yok (279).
  /**
   * KAYDEDILMEMIS DEGISIKLIK IZI (kullanici: "başvuruya herhangi bir ekleme
   * veya değişim yaptığımda kaydetmeden kapat dersem uyarsın").
   *
   * Kartin ANLAMLI durumu tek bir metne cevrilir; kart acilirken ve her
   * BASARILI kayitta bu metin "temiz" kabul edilir. Kapatirken metin farkliysa
   * degisiklik var demektir. Alan alan bayrak tutmak yerine imza kullanildi:
   * yeni alan eklendiginde burasi kendiliginden kapsar.
   */
  //   Imza URETIMI saf fonksiyonda (belgeImza.ts) ve TESTLI: sahte fark
  //   uretirse kullanici hicbir sey degistirmeden uyari alirdi.
  const imza = kartImzasi({
    tarih, cariId: cari?.id ?? null, seri, belgeNo, vadeGun, faturaTipi, aciklama,
    satirlar, odeyenKurumId, bolumId, personelId, basvuruBilgi,
    fiyatListesiId, kampanyaId, depoId: depo?.id ?? null,
    raporDovizi, ekstreDovizi, belgeKuru, senaryo,
  });
  // Imza karsilastirmasi, acilis yarisi ve kayit sonrasi "temiz" damgasi
  //   kendi kancasinda: belgeKarti/useKartKirliligi.
  const { kirli, tazele: imzayiTemizle } =
    useKartKirliligi(imza, `${belgeId ?? 0}/${acilanId ?? 0}`);

  /**
   * Karti kapatir. Kaydedilmemis degisiklik varsa UC SECENEK sorulur
   * (kullanici): Kaydet · İptal (kaydetmeden cik) · Geri Dön (kartta kal).
   * Delphi'deki "KaydetmeSorusu" deseninin aynisi - "vazgec" iki anlama
   * gelmesin diye ucuncu dugme sart.
   *
   * `zorla` yalniz KAYIT SONRASI cagrida true gelir: orada soru sormak sacma
   * olurdu ve `temizImza` state'i henuz guncellenmemis oldugu icin kart hala
   * "kirli" gorunuyordu.
   */
  const kapat = async (zorla = false) => {
    const cik = () => { if (onKapat) onKapat(); else git(basvuruMu ? '/basvuru' : bilgi.liste) };
    if (zorla || !kirli) { cik(); return }

    const secim = await secimSor(
      'Bu kartta kaydedilmemiş değişiklikler var. Ne yapmak istiyorsunuz?',
      [
        { kod: 'kaydet', ad: '💾 Kaydet', sinif: 'bir' },
        { kod: 'iptal',  ad: '✖ İptal (kaydetme)', sinif: 'teh' },
        { kod: 'geri',   ad: '↩ Geri Dön' },
      ], 'geri');

    if (secim === 'geri') return;                 // kartta kal
    if (secim === 'iptal') { cik(); return }      // degisiklikleri at
    // Kaydet: hata varsa (zorunlu alan) kart ACIK kalir - kes() mesaji gosterir.
    const id = await kes(false);
    if (id) cik();
  };

  if (!ekleyebilir)
    return (
      <Modal baslik="Belge" onKapat={() => void kapat()}
             alt={<button className="d kapat-dugmesi" onClick={() => void kapat()}>Kapat</button>}>
        <div className="hata-kutusu">Belge ekleme yetkiniz yok.</div>
      </Modal>
    );

  return (
    <Modal
      // GenoTIP'te ayni tur "Başvuru" adiyla acilir (279): tur katalogundaki ad
      //   "Satış Siparişi" - hasta ekraninda o basligi gostermek yanlis olurdu.
      baslik={(() => {
        const ad = basvuruMu ? 'Başvuru' : seciliTurAdi;
        if (!mevcutBelge) return ad;
        // KAYIT ID'si BASLIKTA (kullanici): belge no is numarasidir (protokol,
        //   fatura no) ve seriye/yila gore tekrar edebilir; destek ya da kayit
        //   izi surerken aranan sey KAYIT ID'sidir. Ikisi birlikte durur -
        //   "#114377 — 2026-000000048".
        const no = sonuc?.belge.belgeNo ? ` — ${sonuc.belge.belgeNo}` : '';
        return `${ad} #${kayitliId}${no}`;
      })()}
      ustBilgi={kullanici?.subeYazma === false
        ? <span className="rozet uyari">salt okuma şubesi</span>
        : <span className="kapt">{kullanici?.subeler.find(s => s.id === kullanici?.subeId)?.ad}</span>}
      onKapat={() => void kapat()}
      // Arac cubugu TURE GORE degisir; duzen mockup'lardan birebir alindi:
      //   Ekranlar/satis_faturasi.html · satis_irsaliye_karti.html · satis_siparis_karti.html
      //   (Kaydet yesil, Sil kirmizi, e-Belge mavi, gruplar ayracla ayrilir.)
      // Ucu henuz olmayan islemler GORUNUR ama PASIF ve title'inda sebebi yazili -
      //   kullanici neyin gelecegini gorur, tikladiginda sessiz kalmaz.
      alt={
        <BelgeAracCubugu
          mevcutBelge={mevcutBelge} duzenlenebilir={duzenlenebilir}
          sonuc={sonuc} kaydediyor={kaydediyor}
          kilitli={kilitli}
          iadeKutusu={irsaliyePilot} iade={iadeMi}
          setIade={v => setFaturaTipi(v ? 2 : 1)}
          faturaTipi={faturaTipi} setFaturaTipi={setFaturaTipi}
          siparisMi={siparisMi} irsaliyeMi={irsaliyeMi} faturaMi={faturaMi} alisMi={alisMi}
          basvuruMu={basvuruMu}
          eBelgeYok={eBelgeYok} kayitliId={kayitliId}
          kes={kes} yeniBelge={yeniBelge} kapat={kapat}
          setDonusum={donusumler.setHedefTur} setTerminAcik={setTerminAcik}
          rezerveVar={rezerveVar} rezerveCalisiyor={rezerveCalisiyor}
          rezerveDegistir={rezerveDegistir}
          hastaVar={!!cari?.id}
          hastaKartiAc={() => { arama.setHastaKartId(cari?.id ?? null);
                                arama.setCari(true) }}
          radyolojiIstemi={() => arama.setIstem(true)}
          // Acil kapisi: tur "Acil" (2), gelis sekli "Ambulans" (2).
          acilBasvuru={() => setBasvuruBilgi(o => ({ ...o, basvuruTuru: 2, gelisSekli: 2 }))}
        />
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}

        {aciliyor && <div className="yukleniyor">Belge açılıyor…</div>}

        {sonuc && !mevcutBelge && (
        <div className="bilgi-kutusu">
          <b>Belge kaydedildi.</b>{' '}
          No: <b>{String(sonuc.belge.belgeNo || '(taslak — numara verilmedi)')}</b> ·
          Genel toplam: <b>{para.format(Number(sonuc.belge.genelToplam))}</b> ·
          <a href="#" onClick={e => { e.preventDefault(); void kapat() }}> listede gör</a>
          {sonuc.uyarilar && sonuc.uyarilar.length > 0 && (
            <ul className="uyari-liste">{sonuc.uyarilar.map((u, i) => <li key={i}>{u}</li>)}</ul>
          )}
        </div>
      )}

        {/* SECILI HASTA SERIDI (298, mockup): kartin EN USTUNDE - kabul memuru
            dogru hastada oldugunu surekli gorsun. Tamamlanma seridinin de
            ustunde (kullanici): once KIM, sonra ne eksik. */}
        {basvuruMu && (
          // HASTA SERIDI CARIDEN DEGIL HASTA ALANINDAN (658, kullanici:
          //   "hasta bilgi bandinda hasta bilgileri gelmedi"): dis kurum
          //   numunesinde belgenin carisi GONDEREN KURUMDUR; serit cariyi
          //   hasta sanip bos aciliyordu. Normal basvuruda ikisi ayni kisi.
          <HastaSeridi tarafId={Number(basvuruBilgi.hastaId ?? 0) || cari?.id}
                       kurumAdi={kurumlar.find(k => k.id === odeyenKurumId)?.ad}
                       acikBorc={basvuruAcikBorc}
                       mustehaklik={Number(basvuruBilgi.sgkMustehaklik ?? 0)}
                       protokolNo={belgeNo || String(sonuc?.belge.belgeNo ?? '')}
                       kilitli={kilitli}
                       acikBelge={basvuruAcikBelge}
                       // e-Nabiz SYS takip no (608): hasta adinin altinda.
                       sysTakipNo={String(basvuruBilgi.sysTakipNo ?? '')}
                       // ÖSS/SGK'da kimlik hucresi SYS takip no da gosterir;
                       //   ozel iste yalniz dosya no (608).
                       paylasimli={paylasimliKurum(kurumlar, odeyenKurumId)}
                       taraflar={seritTaraflari}
                       onAra={metin => { arama.setHastaMetni(metin);
                                         arama.setCari(true) }}
                       onYeniHasta={() => { arama.setHastaYeni(true);
                                            arama.setCari(true) }} />
        )}

        {/* TAMAMLANMA SERIDI (370, kullanici): "bu basvuruda daha ne eksik"
            sorusu sekmeler gezilerek cevaplaniyordu. Asama sirasi ODEYEN
            KURUMA gore degisir - hesap belgeKarti/basvuruAsamalari'nda.
            Hasta seridinin ALTINDA (kullanici). */}
        {basvuruMu && (
          <BasvuruAsamaSeridi
            kurumTuru={kurumlar.find(k => k.id === odeyenKurumId)?.tur}
            kayitliId={kayitliId}
            // Kaydedilmemis kalemler de sayilsin: serit ucret girildikce
            //   ANINDA dolsun (acik borc seridiyle ayni kural).
            ucretGenel={satirlar.length > 0
              ? onizleme.genel : Number(sonuc?.belge.genelToplam ?? 0)}
            tahsilToplam={tahsilToplami(tahsilat.tahsilatlar)}
            // Provizyon durumu ODEYENIN kendi alanindan: SGK'da sgkDurum,
            //   ozel sigortada ossDurum (299 - ikisi ayri tutulur).
            provizyonDurum={kurumlar.find(k => k.id === odeyenKurumId)?.tur === 3
              ? Number(basvuruBilgi.sgkDurum ?? 0)
              : Number(basvuruBilgi.ossDurum ?? 0)}
            kapanmaDurum={Number(sonuc?.belge.kapanmaDurum ?? 0)}
          />
        )}

        <BelgeBaslik
          aktifSekme={aktifSekme ?? ''}
          /* Sekme degisince onceki hata kutusu TEMIZLENIR: kalemsiz kartta
             Tahsilat'a basip hata alan kullanici, sekme degistirince ayni
             kutuyu gorunce hatanin o sekmeden geldigini saniyordu. */
          setAktifSekme={s => { setHata(null); setAlanHatalari({}); setAktifSekme(s) }}
          alanHatalari={alanHatalari} bilgi={bilgi} sonuc={sonuc}
          kilitli={kilitli} baslikKilitli={baslikKilitli} belgeAdi={belgeAdi}
          belgeNo={belgeNo} setBelgeNo={setBelgeNo}
          tarih={tarih} setTarih={setTarih}
          tarihEnGec={tarihEnGec} tarihEnErken={tarihEnErken}
          vadeGun={vadeGun} setVadeGun={setVadeGun}
          basvuruMu={basvuruMu}
          provizyonVar={provizyonVar}
          numaraElle={protokolElle}
          teklif={teklif}
          cari={cari} satici={satici}
          depo={depo} setDepo={setDepo} girisDepo={girisDepo} setGirisDepo={setGirisDepo}
          sevkiyat={sevkiyat}
          fisTipi={fisTipi} setFisTipi={setFisTipi}
          faturaTipi={faturaTipi} setFaturaTipi={setFaturaTipi}
          satirlar={satirlar} donusumler={donusumler.liste}
          setCariArama={arama.setCari} setSaticiArama={arama.setSatici}
          setPersonelArama={arama.setPersonel}
          kapanmaAlani={kapanmaAlani} bagliSiparisAlani={bagliSiparisAlani}
          alisMi={alisMi} irsaliyeMi={irsaliyeMi} faturaMi={faturaMi}
          siparisMi={siparisMi} konsinyeMi={konsinyeMi} tahakkukMu={tahakkukMu}
          depoBelgesi={depoBelgesi} stokFisiMi={stokFisiMi} fisCikisMi={fisCikisMi}
          transferMi={transferMi} talepMi={talepMi} disNumarali={disNumarali}
          eBelgeYok={eBelgeYok}
        />
        {aktifSekme === 'kalem' && (
          <KalemSekmesi
            satirlar={satirlar}
            dagilimOnizleme={dagilimOnizleme}
            seciliSatirlar={seciliSatirlar} setSeciliSatirlar={setSeciliSatirlar}
            acikLotlar={acikLotlar} setAcikLotlar={setAcikLotlar}
            kilitli={kilitli} bilgi={bilgi} onizleme={onizleme}
            sonuc={kalemDegisti ? null : sonuc}
            transferBaslikEksigi={transferBaslikEksigi}
            depoBelgesi={depoBelgesi} stokFisiMi={stokFisiMi} talepMi={talepMi}
            setStokArama={iadeMi ? arama.setIade : ucretEklemeAc}
            setKalem={setKalem} seciliSil={seciliSil}
            // PRIM ROLLERI (324): prim HBYS kavrami (hekim hakedisi) -
            //   ERP modunda dugme hic cizilmez.
            onRoller={kullanici?.urunModu === URUN_GENOTIP && yetki('prim', 'degistir')
              ? (satirId, ad, sira) => {
                  // Kalem kayitli ve bekleyen degisiklik yoksa dogrudan ac.
                  if (satirId > 0 && !kalemDegisti) { setRolModali({ satirId, ad }); return }
                  void (async () => {
                    if (!await kayitSart()) return;
                    setRolBekleyenSira(sira);
                  })();
                }
              : undefined}
            /* ISKONTO ONAYI (662): oran + gerekce sorulur, secili satirlar
               icin talep acilir. Satirlar ONCE KAYDEDILIR - talep satir
               kimligine baglanir, kaydedilmemis satirin kimligi yoktur. */
            /* ISKONTO PENCERESI: kalemler, oran, gerekce ve yetki tek
               ekranda. Satirlar ONCE KAYDEDILIR - talep satir kimligine
               baglanir, kaydedilmemis satirin kimligi yoktur. */
            onIskontoOnay={anahtarlar => void (async () => {
              if (!await kayitSart()) return;
              setIskontoTalebi(anahtarlar);
            })()}
            iskontoTalepleri={iskontoTalepleri}
            satirTikla={satirTikla} sonTiklanan={sonTiklanan} secimDegis={secimDegis}
            fiyatListesi={{ listeler: fiyatListeleri, seciliId: fiyatListesiId,
                            sec: v => void listeDegisti(v), kampanyaAdi }}
            basvuruMu={basvuruMu}
            // DEPO (296): basvuruda baslikta yer Doktor'a verildi, depo buraya.
            depoSecimi={basvuruMu ? {
              listeler: depolar,
              seciliId: depo?.id ?? null,
              sec: (v: number | null) => setDepo(
                v ? { id: v, ad: depolar.find(d => d.id === v)?.ad ?? '' } : null),
            } : undefined}
            // ODEME PAYLASIMI (289): yalniz ÖSS/SGK odeyen kurumda (kullanici:
            //   "ödeyen kurum özel ama ücret gridinde hasta/kurum payları var").
            //   "Özel (Ücretli)" de bir KURUMDUR ama hasta kendi oder - pay
            //   paylasimi, provizyon ve kurum payi kolonlari orada anlamsiz.
            paylasim={{ acik: basvuruMu && provizyonVar,
                        // Saf SGK'da "Kurum Payı" kolonu cizilmez (601).
                        rota: dagilimRotasi(kurumlar.find(k => k.id === odeyenKurumId)?.tur,
                                            basvuruBilgi.altKurum, basvuruBilgi.sgkKullan),
                        uygula: () => void dagilimYenile() }}
            doviz={{
              raporDovizi, setRaporDovizi: yeni => {
                setRaporDovizi(yeni);
                // Ekstre dovizi yalniz "rapor dovizi + yerel" olabilir: rapor
                //   degisince gecersiz kalmasin.
                setEkstreDovizi(e => (e === yerelPara ? e : yeni));
                if (yeni === yerelPara) setBelgeKuru('1');
              },
              ekstreDovizi, setEkstreDovizi,
              kur: belgeKuru,
              setKur: v => { kurElleRef.current = true; setBelgeKuru(v) },
              yerelPara,
            }}
          />
        )}

        {/* ========================================= TASIYICI / SEVKIYAT ==== */}
        {aktifSekme === 'tasiyici' && (
          <TasiyiciSekmesi
            kilitli={kilitli}
            sevkiyat={sevkiyat}
            belge={sonuc?.belge}
          />
        )}

        {aktifSekme === 'ebelge' && (
          <EBelgeSekmesi
            kilitli={kilitli} irsaliyeMi={irsaliyeMi} tur={tur}
            senaryo={senaryo} setSenaryo={setSenaryo}
            belge={sonuc?.belge}
          />
        )}

        {aktifSekme === 'fatura' && (
          <FaturalamaSekmesi
            donusumler={donusumListesi} kayitliId={kayitliId}
            setDonusum={donusumler.setHedefTur}
            teklifMi={teklifMi} teklifDurum={teklif.durum}
            donusumAc={donusumler.ac}
            // SILME SONRASI SERIT ANINDA (kullanici: "ücret/tahsilat ve dönüşüm
            //   değiştiği an üstteki açık tahsilat ve belge tutarları da anında
            //   güncellenmeli"): belge silinince kovalarin KAPATILAN sayaci
            //   sunucuda geri doner - satirlar okunmazsa serit eski kalir.
            donusumSil={async idler => {
              await donusumler.sil(idler);
              await paraRef.current.satirlariTazele();
            }}
            hizliDonustur={(t, taraf) => void hizliDonustur(t, taraf)}
            // KURUM TAHAKKUKU YALNIZ PAYLASIMLI KURUMDA (kullanici: "Kurum
            //   Tahakkuk butonu Özel hasta kurum tipinde görünmemeli"): özel
            //   (ücretli) başvuruda kurumun payı hep sıfırdır, düğme her zaman
            //   boş sonuç verirdi. Başvuru DIŞI belgelerde ayrım yok.
            kurumPayliMi={basvuruMu ? provizyonVar : undefined}
            olcu={donusumler.olcu} setOlcu={donusumler.setOlcu}
          />
        )}
        {aktifSekme === 'tahsilat' && (
          <TahsilatSekmesi sonuc={sonuc} tahsilatlar={tahsilat.tahsilatlar}
                           kayitliId={kayitliId} alisMi={alisMi} tahsilatAc={tahsilatAc}
                           basvuruMu={basvuruMu}
                           secili={tahsilat.seciliTahsilatlar}
                           setSecili={tahsilat.setSeciliTahsilatlar}
                           tahsilatAcKart={tahsilat.setTahsilatKayitId}
                           tahsilatSil={async idler => {
                             await tahsilat.tahsilatSil(idler);
                             // Tahsilat silinince kovalarin TAHSIL sayaci duser.
                             await paraRef.current.satirlariTazele();
                           }}
                           hizliNakit={() => void hizliNakit()}
                           hesapSecAc={(t, iade) => void (async () => {
                             if (!await kayitSart()) return;
                             const ad = t === 'B' ? 'Banka' : 'POS';
                             const s = iade ? await iadeParasiSor(ad)
                                            : await tahsilatParasiSor(ad);
                             if (!s) return;
                             setHesapSecimIade(!!iade);
                             setHesapSecimPara(s);
                             setHesapSecim(t);
                           })()}
                           acikBorc={hizliTutar()}
                           yerelPara={yerelPara}
                           /* IADE / IPTAL: arac neyse iade de o araçla -
                              karttan alinip nakit iade etmek veznede olmayan
                              parayi cikarir. Cek/senet iadesi kiymetin GERI
                              VERILMESIDIR: ters yondeki cek/senet turu acilir
                              (alinan 23/24 -> verilen 33/34). */
                           iadeAc={arac => {
                             if (arac === 'nakit') { void nakitIadesi(); return }
                             if (arac === 'pos' || arac === 'banka') {
                               const t = arac === 'banka' ? 'B' : 'P';
                               void (async () => {
                                 if (!await kayitSart()) return;
                                 const s = await iadeParasiSor(t === 'B' ? 'Banka' : 'POS');
                                 if (!s) return;
                                 setHesapSecimIade(true);
                                 setHesapSecimPara(s);
                                 setHesapSecim(t);
                               })();
                               return;
                             }
                             const cek = arac === 'cek';
                             void tahsilatAc(alisMi ? (cek ? 23 : 24) : (cek ? 33 : 34));
                           }}
                           // KURUM BELGELERI listenin BASINDA (kullanici):
                           //   kuruma kesilen tahakkuk/fatura tahsilat degildir
                           //   ama ayni tabloda okunur - "800 kuruma yazildi,
                           //   200 hastadan alindi".
                           kurumBelgeleri={donusumListesi
                             .filter(d => TAHAKKUK_TURLERI.has(Number(d.tur)))
                             .map(d => ({
                               id: Number(d.belgeId), belgeNo: String(d.belgeNo ?? ''),
                               tarih: String(d.belgeTarihi ?? ''),
                               turAdi: String(d.turAdi ?? ''),
                               cari: String(d.tarafUnvan ?? ''),
                               tutar: Number(d.tutar ?? 0),
                               hastaMi: !!d.hastaMi,
                             }))}
                           onYenile={() => { void paraRef.current.satirlariTazele() }}
                           // KURUM TAHAKKUKU (331): kurum payini Satış
                           //   Tahakkukuna (17) donusturur - tahsilat DEGIL.
                           //   KENDI ODEYENDE (Özel, tur 1) GORUNMEZ
                           //   (kullanici): hasta kendi odedigi icin kurum
                           //   payi hep 0'dir - dugme her zaman pasif duruyor
                           //   ve "neden basamiyorum" sorusu doguruyordu.
                           //   `provizyonVar` tam bu kumeyi veriyor: ÖSS/SGK.
                           kurumTahakkukAc={basvuruMu && provizyonVar
                             ? () => { donusumler.setPay(2); donusumler.setHedefTur(17) }
                             : undefined}
                           kurumKalan={satirlar.reduce((t, r) =>
                             t + Math.max(hamSayi(r.kurumTutar) - (r.kurumKapatilan ?? 0), 0), 0)} />
        )}
        {/* ============================================= IMZA / TESLIM ==== */}
        {aktifSekme === 'imza' && (
          <div className="kagrup">
            <h6>İmza / Teslim Alan</h6>
            <div className="not">
              Teslim alan kişi, TC, görev, teslim zamanı, nüsha sayısı ve teslim notu
              alanları henüz şemada yok — e-İrsaliye teslim onayı akışıyla gelecek.
              İmzalı teslim belgesi şimdilik Yorum / Medya sekmesine eklenebilir.
            </div>
          </div>
        )}

        {/* ============================================= YORUM / MEDYA ==== */}
        {/* BASVURU SEKMELERI (298) - mockup: Ekranlar/kayit_kabul_basvuru.html */}
        {aktifSekme === 'basvuru' && (
          <BasvuruSekmesi
            bilgi={basvuruBilgi}
            degistir={y => setBasvuruBilgi(x => ({ ...x, ...y }))}
            kilitli={kilitli}
            tarih={tarih} setTarih={setTarih}
            tarihEnGec={tarihEnGec} tarihEnErken={tarihEnErken}
            tarihHatasi={alanHatalari.belgeTarihi}
            bolumler={bolumler} bolumId={bolumId} setBolumId={setBolumId}
            gorevliler={gorevliler} personelId={personelId} setPersonelId={setPersonelId}
            kurumlar={kurumlar} odeyenKurumId={odeyenKurumId}
            // Emekli kutusu ODEYEN KURUMUN TURUNE bagli (591) - alt kurum tek
            //   basina yetmez, SGK'da alt kurum devredilen kurumdur.
            kurumTuru={kurumlar.find(k => k.id === odeyenKurumId)?.tur}
            setOdeyenKurumId={v => void odeyenKurumDegisti(v)}
            sozlesmeler={sozlesmeler} altKurumlar={altKurumlar}
            aciklama={aciklama} setAciklama={setAciklama}
            // LAB / GORUNTULEME kurumu (364): hekim rolu "Gönderen" (1) ise
            //   basvuru turu ve poliklinik odasi sorulmaz, hekim alani
            //   "Gönderen" olur.
            gonderenModu={gonderenModu}
            personelAd={personelAd} onPersonelSec={personelSecildi}
            kurumHatasi={alanHatalari.odeyenKurumId}
            bolumHatasi={alanHatalari.bolumId}
            personelHatasi={alanHatalari.personelId}
            kendiIstegi={Number(basvuruBilgi.kendiIstegi ?? 0) === 1}
            onKendiIstegi={kendiIstegiDegisti}
            randevuBilgi={sonuc?.belge.randevuOzet
              ? String(sonuc.belge.randevuOzet) : undefined}
          />
        )}

        {aktifSekme === 'provizyon' && (
          <ProvizyonSekmesi
            bilgi={basvuruBilgi}
            degistir={y => setBasvuruBilgi(x => ({ ...x, ...y }))}
            kilitli={kilitli}
            kurumAdi={kurumlar.find(k => k.id === odeyenKurumId)?.ad}
            kurumlar={kurumlar}
            kurumTuru={kurumlar.find(k => k.id === odeyenKurumId)?.tur}
            belgeId={kayitliId || undefined}
            tarafId={cari?.id}
            hekimId={personelId}
            // Provizyon sekmesinin baslangic degerleri bunlardan uretilir:
            //   sigorta sirketi odeyen kurumdan, karsilama orani
            //   sozlesmeden, provizyon/takip tarihi belge tarihinden.
            odeyenKurumId={odeyenKurumId}
            sozlesme={sozlesmeler.find(z => z.id === basvuruBilgi.sozlesmeId)}
            belgeTarihi={tarih}
            // Provizyon paylari belge SATIRLARINA yazildi: kart yeniden
            //   okunmazsa ekranda eski kurum/hasta payi kalir.
            // BEKLEYEN UCRET SATIRLARI ONCE KAYDEDILIR (kullanici): provizyon
            //   sunucudaki satirlardan hesaplanir; gride girilmis ama
            //   gonderilmemis kalem sorguya girmiyordu.
            kaydet={async () => (kayitliId && !kalemDegisti && !kirli
              ? kayitliId : await kes(false, true))}
            onTazele={() => { if (kayitliId) void api.belgeOku(kayitliId).then(setSonuc) }}
          />
        )}

        {aktifSekme === 'gecmis' && (
          <OncekiBasvurular tarafId={cari?.id} haricBelgeId={kayitliId || undefined} />
        )}

        {aktifSekme === 'yorum' && (
          <div className="kagrup">
            <h6>Yorum / Medya</h6>
            {kayitliId > 0
              ? <DokumanGalerisi kartAdi="belge" kaynakId={kayitliId} saltOkunur={false} />
              : <div className="not">Belge kaydedilince ek ve yorum eklenebilir.</div>}
          </div>
        )}

        {/* Kartin ustune acilan BUTUN pencereler (cari/stok/kalem/tahsilat/
            donusum/termin/prim/istem) tek bilesende: BelgeKartiModallari.
            Kart yalniz "hangisi acik" durumunu tutar. */}
        <BelgeKartiModallari
          kayitliId={kayitliId} tur={tur} bilgi={bilgi} basvuruMu={basvuruMu}
          alisMi={alisMi} irsaliyeMi={irsaliyeMi} siparisMi={siparisMi}
          stokFisiMi={stokFisiMi} depoBelgesi={depoBelgesi}
          yerelPara={yerelPara} tarih={tarih} odeyenKurumId={odeyenKurumId}
          // SUT SUTUNU (602): arama listesinde SGK'nin odedigi bedel de
          //   gorunsun - sozlesme olmadan cozulemez.
          sgkBaglami={{ sozlesmeId: basvuruBilgi.sozlesmeId ?? null,
                        kurumId: odeyenKurumId,
                        sgkKullan: basvuruBilgi.sgkKullan ?? null }}
          fiyatListesiId={fiyatListesiId}
          bolumId={bolumId}
          depo={depo} sonuc={sonuc} setSonuc={setSonuc}
          cari={cari} setCari={setCari}
          cariArama={arama.cari} setCariArama={arama.setCari}
          hastaAramaMetni={arama.hastaMetni} setHastaAramaMetni={arama.setHastaMetni}
          hastaAramaYeni={arama.hastaYeni} setHastaAramaYeni={arama.setHastaYeni}
          hastaKartId={arama.hastaKartId} setHastaKartId={arama.setHastaKartId}
          saticiArama={arama.satici} setSaticiArama={arama.setSatici} setSatici={setSatici}
          personelArama={arama.personel} setPersonelArama={arama.setPersonel}
          setTeslimEden={sevkiyat.setTeslimEden}
          setTeslimAlan={sevkiyat.setTeslimAlan}
          satirlar={satirlar} setSatirlar={setSatirlar}
          stokArama={arama.stok} setStokArama={arama.setStok}
          // Hizli tahsilatin SARMALANMIS surumu: ardina kurum tahakkuku ve
          //   satir tazelemesi eklenir (serit tahsilattan sonra guncel olsun).
          hizliTahsilat={(...a) => akisRef.current.hizliTahsilat(...a)}
          tarifeTipi={tarifeTipi}
          // ÖDEME ROTASI (595): kalem penceresi "Katkı Fiyatı"nı yalnız ek
          //   katkı kovası olan rotalarda sorar (TSS / SGK).
          rota={dagilimRotasi(kurumlar.find(k => k.id === odeyenKurumId)?.tur,
                              basvuruBilgi.altKurum, basvuruBilgi.sgkKullan)}
          aramaEklenen={arama.eklenen} setAramaEklenen={arama.setEklenen}
          stokSecildi={stokSecildi}
          kalem={kalem} setKalem={setKalem} kalemKaydet={kalemKaydet}
          iadeArama={arama.iade} setIadeArama={arama.setIade}
          tahsilat={tahsilat} tahsilatTutariSor={tahsilatTutariSor}
          posSonrasi={posSonrasi}
          hesapSecim={hesapSecim} setHesapSecim={setHesapSecim}
          hesapSecimIade={hesapSecimIade} setHesapSecimIade={setHesapSecimIade}
          hesapSecimPara={hesapSecimPara} setHesapSecimPara={setHesapSecimPara}
          /* Kalem penceresinin ust seridi: kart basligi pencerenin ALTINDA
             kalir, bu uc bilgi orada da okunabilmeli. */
          iskontoTalebi={iskontoTalebi}
          setIskontoTalebi={setIskontoTalebi}
          iskontoTavani={aksiyonDegeri('basvuru.iskonto')}
          kalemSeridi={{
            // HASTA ADI, CARI DEGIL (kullanici: "hasta adi yanlis, kurum adi
            //   gelmis"): dis kurum numunesinde belgenin carisi GONDEREN
            //   KURUMDUR - hasta ayri alanda durur (hasta seridiyle ayni kural).
            hasta: String(basvuruBilgi.hastaUnvan ?? '') || cari?.unvan || '',
            odeyen: kurumlar.find(k => k.id === odeyenKurumId)?.ad ?? '',
            liste: fiyatListeleri.find(l => l.id === fiyatListesiId)?.ad ?? '',
          }}
          iadeYaz={iadeYaz}
          donusum={donusumler.hedefTur} setDonusum={donusumler.setHedefTur}
          donusumPay={donusumler.pay} setDonusumPay={donusumler.setPay}
          acilanDonusum={donusumler.acilan} setAcilanDonusum={donusumler.setAcilan}
          donusumleriYukle={donusumler.yukle}
          terminAcik={terminAcik} setTerminAcik={setTerminAcik}
          rolModali={rolModali} setRolModali={setRolModali}
          istemModali={arama.istem} setIstemModali={arama.setIstem}
          onKaydedildi={onKaydedildi} git={git}
        />
      </>
    </Modal>
  );
}
