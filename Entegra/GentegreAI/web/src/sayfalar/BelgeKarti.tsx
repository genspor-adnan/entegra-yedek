import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { mesaj, metinSor, onay, secimSor } from '../bilesenler/mesaj';
import { type BelgeYaniti, type KasaIslemTuru, URUN_GENOTIP, hataMetni, hataAyristir } from '../api/sozlesme';
import { Modal } from '../bilesenler/Modal';
import { belgeTuruBilgisi, GIRILEBILIR_TURLER, VARSAYILAN_TUR } from './belgeTuru';
import { DokumanGalerisi } from '../bilesenler/DokumanGalerisi';
import { useOturum } from '../kimlik/OturumBaglami';
import { para, yerelAnMetni, hamSayi } from '../bilesenler/bicim';
import { type SatirDurumu, satirTutari, yanittanSatirlar } from './belgeSatir';
import { belgeDogrula, belgeGovdesi, doluSatirlar, type BelgeGirdisi } from './belgeKaydet';
import {
  YEREL_PARA_VARSAYILAN, GERIYE_GUN_VARSAYILAN, KAPANMA_ETIKET,
} from './belgeSabitleri';
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
import { useBelgeFiyatlandirma } from './belgeKarti/useBelgeFiyatlandirma';
import {
  provizyonVarMi, donusumSatirlari, posFisiSecimi, kasaAramaSirasi,
  gelisSekliKarari, acikBorcHesapla,
} from './belgeKartiKurallari';
import {
  kampanyaFiyatiUygula, paketIcerigiUygula, sonAnahtar, stokSecimindenKalem,
} from './belgeKalem';
import { BelgeKartiModallari } from '../bilesenler/belge/BelgeKartiModallari';

/**
 * TarafArama ile doldurulan baslik alani (cari, satis temsilcisi...).
 *
 * GenLookup DEGIL: secim her yerde AYNI arama ekranindan yapilsin diye alan
 * kendisi salt okunur, tiklayinca (ya da "…" dugmesiyle) modali cagirir.
 */
export function TarafAlani({ etiket, deger, kilitli, ipucu, zorunlu, hata, onAc }: {
  etiket: string;
  deger?: string;
  kilitli: boolean;
  ipucu: string;
  zorunlu?: boolean;
  hata?: string;
  onAc(): void;
}) {
  return (
    <label className="alan">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <span className="lookup-kutu">
        <input readOnly value={deger ?? ''} placeholder="Seçiniz…" disabled={kilitli}
               onMouseDown={e => { if (!kilitli) { e.preventDefault(); onAc() } }} />
        {!kilitli && (
          <button type="button" className="mini" title={ipucu} onClick={onAc}>…</button>
        )}
      </span>
      {hata && <span className="alan-hata">{hata}</span>}
    </label>
  );
}

/**
 * Belge kesme ekrani (satis faturasi, siparis, irsaliye…).
 *
 * TUR URL'DEN GELIR (?tur=19). Ekran eskiden 15'e (satis faturasi) SABITTI;
 * Siparisler listesinden "Yeni" denince yine fatura ekrani aciliyordu.
 *
 * Ekran MODAL acilir (diger kartlarla ayni desen): liste arkada kalir.
 *
 * TUTAR HESABI SUNUCUDA. Ekranda gosterilen satir tutari yalnizca ONIZLEMEDIR;
 * kaydedilen degerler her zaman sunucudan donen belgeden okunur. Delphi ile kurusu
 * kurusuna ayni olmasi gereken formul (ic yuvarlama + carpimsal iskonto + banker's)
 * tek yerde, sunucuda durur — istemciye kopyalanirsa iki formul birbirinden kayar.
 */
interface Props {
  /** Verilirse MEVCUT belge acilir (salt gorunum). Duzenleme F7'de gelecek. */
  id?: number;
  /** Acilis turu; verilmezse URL'deki ?tur= ya da satis faturasi (15). */
  tur?: number;
  /** Liste icinden acildiginda: modal kapanisi cagirani ilgilendirir. */
  onKapat?(): void;
  /** Kayit sonrasi cagirani (grid) tazelemek icin. */
  onKaydedildi?(): void;
}

export function BelgeKarti({ id: belgeId, tur: acilisTuru, onKapat, onKaydedildi }: Props = {}) {
  const git = useNavigate();
  const [sorgu] = useSearchParams();
  const { yetki, kullanici } = useOturum();

  const [tur, setTur] = useState<number>(() => {
    const istenen = acilisTuru ?? Number(sorgu.get('tur'));
    return GIRILEBILIR_TURLER.includes(istenen as typeof GIRILEBILIR_TURLER[number])
      ? istenen : VARSAYILAN_TUR;
  });
  const [turler, setTurler] = useState<KasaIslemTuru[]>([]);

  // Tarih penceresi ayardan gelir; ulasilamazsa varsayilan (7) ile devam edilir -
  //   sunucu zaten ayni kurali uyguluyor, buradaki sinir sadece erken uyari.
  useEffect(() => {
    void api.ayarlar()
      .then(a => {
        const s = a.find(x => x.anahtar === 'belge.geri_gun_siniri')?.deger;
        if (s !== undefined && s !== '' && Number.isFinite(Number(s))) setGeriGun(Number(s));
        const p = a.find(x => x.anahtar === 'genel.yerel_para')?.deger;
        if (p) setYerelPara(p);
        // POS aksiyonu (355): 0 yok / 1 otomatik fis / 2 sor.
        const pa = a.find(x => x.anahtar === 'basvuru.pos_aksiyon')?.deger;
        if (pa !== undefined && pa !== '') setPosAksiyon(Number(pa) || 0);
      })
      .catch(() => { /* varsayilan kalir */ });
  }, []);

  /**
   * HIZLI TAHSILAT (kullanici): banka/POS hesabi secim modali. Nakit modal
   * ACMAZ - varsayilan kasayla dogrudan satir eklenir.
   */
  const [hesapSecim, setHesapSecim] = useState<'B' | 'P' | null>(null);
  /** POS tahsilatindan sonraki aksiyon (355 ayari): 0 yok / 1 otomatik / 2 sor. */
  const [posAksiyon, setPosAksiyon] = useState(0);
  /**
   * PROTOKOL NO ELLE MI (358): karar numaralandirma tablosunda
   * (numara_sablonu tur 19, `elle_girilir`) - ayri bir ayar yok. Elle ise kayit
   * kabul memuru numarayi kartta yazabilir; bos birakirsa sunucu yine uretir.
   */
  const [cari, setCari] = useState<{ id: number; unvan: string } | null>(null);
  // Tarih SAATIYLE tutulur: ayni gun icindeki hareket sirasi buna gore.
  const [tarih, setTarih] = useState(() => yerelAnMetni(new Date()));
  const [seri, setSeri] = useState('WEB');
  /** Ayardan gelen geriye donuk gun siniri (0 = sinir yok). */
  const [geriGun, setGeriGun] = useState(GERIYE_GUN_VARSAYILAN);
  /** Ayardan gelen yerel (defter) para birimi. */
  const [yerelPara, setYerelPara] = useState(YEREL_PARA_VARSAYILAN);
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
  // BASVURU (249): vade yerine "Ödeyen Kurum" - hizmeti kim odeyecek
  //   (anlasmali kurum / sigorta / SGK). Bos = hasta kendi oder.
  const [odeyenKurumId, setOdeyenKurumId] = useState<number | null>(null);
  /**
   * BASVURU BASLIGI (296/297): basvurulan BOLUM ve karsilayan PERSONEL.
   * Personel HEKIM OLMAK ZORUNDA DEGIL (kullanici): diyetisyen,
   * fizyoterapist, teknisyen de basvuru karsilar - kisit "randevu verilebilir
   * personel" + secili bolum. Ikisi de belge_basvuru uzantisinda saklanir.
   */
  const [bolumId, setBolumId] = useState<number | null>(null);
  const [personelId, setPersonelId] = useState<number | null>(null);
  /** Secili hekim/gonderen ADI: arama ekranindan gelen kisi combo listesinde
      olmayabilir (or. isareti kaldirilmis dis hekim), ad ayrica tutulur. */
  const [personelAd, setPersonelAd] = useState('');
  /**
   * BASVURU SEKMESI (298) alanlari TEK NESNEDE: on kadar alan icin ayri ayri
   * state tutmak karti sisiriyordu; hepsi belge_basvuru uzantisina gider.
   */
  const [basvuruBilgi, setBasvuruBilgi] = useState<BasvuruBilgi>({});
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
  const [teklifDurum, setTeklifDurum] = useState('1');
  const [revizeNo, setRevizeNo] = useState('');
  const [teklifKonusu, setTeklifKonusu] = useState('');
  const [teklifTeslim, setTeklifTeslim] = useState('');
  const [depo, setDepo] = useState<{ id: number; ad: string } | null>(null);
  /** Yalniz transferde (20): malin GIDECEGI depo. Tekil belgelerde kullanilmaz. */
  const [girisDepo, setGirisDepo] = useState<{ id: number; ad: string } | null>(null);
  /** Transferde sorumluluk devri: teslim EDEN (asagida, irsaliyeyle ortak) ve
      teslim ALAN personel - transferde ikisi de zorunlu. */
  const [teslimAlan, setTeslimAlan] = useState<{ id: number; ad: string } | null>(null);
  /** Stok fisinde (3/4) fisin SEBEBI - belge.tipi. 0 = secilmedi. */
  const [fisTipi, setFisTipi] = useState(0);
  /** Hangi personel alani araniyor - ayni TarafArama iki alani da besler. */
  const [personelArama, setPersonelArama] = useState<'eden' | 'alan' | null>(null);
  // Yeni kartta Satis Temsilcisi/Sorumlu VARSAYILANI oturum kullanicisi
  //   (kullanici) - KullaniciOzeti.Id zaten taraf_id. Kayit yuklenirken
  //   belgedeki deger bunu ezer; kullanici istedigiyle degistirebilir.
  const [satici, setSatici] = useState<{ id: number; ad: string } | null>(
    kullanici ? { id: kullanici.id, ad: kullanici.ad } : null);
  const [teslimSekli, setTeslimSekli] = useState(0);
  const [sevkTarihi, setSevkTarihi] = useState('');
  const [soforTckn, setSoforTckn] = useState('');
  const [tasiyici, setTasiyici] = useState<{ id: number; ad: string } | null>(null);
  const [aracPlaka, setAracPlaka] = useState('');
  const [soforAd, setSoforAd] = useState('');
  const [teslimEden, setTeslimEden] = useState<{ id: number; ad: string } | null>(null);
  /* TASLAK kutusu arac cubugundan KALKTI (kullanici): kart kaydedince belge
     kesindir. Sunucu tarafi (durum 1) duruyor - gocten gelen eski taslaklar
     ve liste cipleri icin gerekli, ama kart artik hep KESIN yazar. */
  const taslak = false;
  // Yeni belge BOS grid ile acilir: "(stok seçilmedi)" yazan sahte satir
  //   kullaniciyi "burasi nasil doldurulur" diye ariyordu; satir "＋" ile eklenir.
  const [satirlar, setSatirlar] = useState<SatirDurumu[]>([]);

  const [kaydediyor, setKaydediyor] = useState(false);
  const [aciliyor, setAciliyor] = useState(!!belgeId);
  /** Donusum modali: null = kapali, sayi = ON SECILI hedef tur (0 = ilk hedef). */
  const [donusum, setDonusum] = useState<number | null>(null);
  /**
   * KURUM TAHAKKUKU (331): donusum modali PAY secili acilir (2 = kurum payi).
   * Normal F8 donusumunde pay secimi kullaniciya birakilir (0).
   */
  const [donusumPay, setDonusumPay] = useState(0);
  /** Termin (teslim tarihi) modali - siparis satirlarinin taahhudu (140). */
  const [terminAcik, setTerminAcik] = useState(false);
  /** Rezervasyon (142) islemi surerken dugme bekler. */
  const [rezerveCalisiyor, setRezerveCalisiyor] = useState(false);
  const [aktifSekme, setAktifSekme] = useState('kalem');
  /** Grid satir secimi (kirmizi Sil dugmesi bunlari siler). */
  const [seciliSatirlar, setSeciliSatirlar] = useState<Set<number>>(new Set());
  /** Prim rolleri (324): kalem gridinden acilan modal - null iken kapali. */
  const [rolModali, setRolModali] = useState<{ satirId: number; ad: string } | null>(null);
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
  /** Shift ile ARALIK secimi icin son tiklanan satirin sirasi. */
  const sonTiklanan = useRef<number | null>(null);
  /** Acik kalem penceresi (adet / fiyat). Stok zaten secilmis olarak gelir. */
  const [kalem, setKalem] = useState<SatirDurumu | null>(null);
  /** Ardisik giris: stok arama penceresi acik mi. Kalem eklendikten sonra
      KAPANMAZ - kullanici arka arkaya satir girer, isi bitince Kapat der. */
  const [stokArama, setStokArama] = useState(false);
  /** Arama penceresi acikken eklenen kalem sayaci (pencere kapaninca sifirlanir). */
  const [aramaEklenen, setAramaEklenen] = useState({ sayi: 0, son: '' });
  /** IADE faturasi (tipi 2): kalem eklemede stok arama yerine "onceki alinanlar". */
  const [iadeArama, setIadeArama] = useState(false);
  /** Cari secim modali. YENI belgede acilista kendiliginden acilir: belgenin
      ilk sorusu "kime?" - kullaniciyi bos formda birakip aramaya zorlamak yerine
      dogrudan secim ekrani gelir (kisi kartindaki "Cariye Bağla" deseni). */
  // Yeni belgede kart acilir acilmaz cari arama gelir - TRANSFERDE cari yok,
  //   acilmaz (kullanici: "yeni dediginde cari sormasin").
  // Cari YOKSA arama da acilmaz: transfer (20), talep (105), stok fisleri (3/4).
  // Cari YOKSA arama da acilmaz (transfer/talep/stok fisi) - tablodan.
  const [cariArama, setCariArama] = useState(!belgeId && belgeTuruBilgisi(tur).cariVar);
  /**
   * Hasta arama seridinden (300) gelen acilis istegi: kutuya yazilan metin
   * pencereye ON-DOLGU gecer, "＋ Yeni Hasta Kaydi" ise dogrudan kart acar.
   * Pencere kapaninca ikisi de temizlenir - sonraki acilis temiz baslasin.
   */
  const [hastaAramaMetni, setHastaAramaMetni] = useState('');
  const [hastaAramaYeni, setHastaAramaYeni] = useState(false);
  /** "Hasta Kartını Aç" (300): pencere arama listesi yerine kartla acilir. */
  const [hastaKartId, setHastaKartId] = useState<number | null>(null);
  /** Basvurudan RADYOLOJI ISTEMI (304) - ic istem: hasta ve protokol hazir. */
  const [istemModali, setIstemModali] = useState(false);
  /** Satis temsilcisi (personel) secim modali - cari ile ayni ekran. */
  const [saticiArama, setSaticiArama] = useState(false);
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

  const [donusumler, setDonusumler] = useState<Record<string, unknown>[]>([]);
  const [sonuc, setSonuc] = useState<BelgeYaniti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});

  const ekleyebilir = yetki('belge', 'ekle');

  // Tur adlari katalogtan gelir (istemcide ikinci bir liste tutulmaz).
  useEffect(() => {
    void (async () => {
      try { setTurler(await api.kasaIslemTurleri()) } catch { /* ad yoksa kod gosterilir */ }
    })();
  }, []);

  const turAdi = (kod: number) => turler.find(t => t.kod === kod)?.ad ?? `Belge (${kod})`;
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

  // Basvuru combolarinin (kurum · bolum · depo · gorevli) ve protokol numara
  //   sablonunun yuklenmesi ayri dosyada: hepsi ayni desendeki bes effect'ti.
  const { kurumlar, bolumler, depolar, gorevliler, protokolElle } =
    useBasvuruKaynaklari(basvuruMu, bolumId, kullanici?.hekimRolu);

  // Fiyat listesi · kampanya · pay modu · provizyon uygulamasi ayri dosyada:
  //   hepsi "bu satir kaca yazilacak" sorusunun parcasi (belgeKarti/
  //   useBelgeFiyatlandirma), karta dagilinca kural kaciyordu.
  const {
    fiyatListeleri, fiyatListesiId, setFiyatListesiId: setFiyatListesiIdHam,
    kampanyaId, setKampanyaId, kampanyaAdi, setKampanyaAdi, paylasimModu,
    kampanyaCoz, satirlariYenidenFiyatla, listeDegisti, provizyonUygula,
  } = useBelgeFiyatlandirma({
    belgeId, tur, alisMi, cariId: cari?.id ?? null, odeyenKurumId, satirlar, setSatirlar,
  });

  /**
   * PROVIZYON SEKMESI yalniz ÖSS/SGK odeyen kurumda (kullanici,
   * taraf_kurum.tur: 1 Özel / 2 ÖSS / 3 SGK). Kurum secili degilse hasta kendi
   * oder - provizyon alinacak bir kurum yok.
   */
  const provizyonVar = provizyonVarMi(kurumlar, odeyenKurumId);

  // Tur SORULMADIGI icin kayitta bos kalmasin: lab/goruntuleme kurumunda
  //   basvuru turu 5 ("Laboratuvar / Görüntüleme") olarak damgalanir.
  useEffect(() => {
    if (!basvuruMu || !gonderenModu) return;
    setBasvuruBilgi(o => (Number(o.basvuruTuru ?? 0) === 5 ? o : { ...o, basvuruTuru: 5 }));
  }, [basvuruMu, gonderenModu]);


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
        : !teslimAlan ? 'talep eden'
        : girisDepo && depo.id === girisDepo.id ? 'farklı teslim deposu'
        : null)
      : (!depo ? 'çıkış deposu'
        : !girisDepo ? 'giriş deposu'
        : !teslimEden ? 'teslim eden'
        : !teslimAlan ? 'teslim alan'
        : depo.id === girisDepo.id ? 'farklı giriş/çıkış deposu'
        : teslimEden.id === teslimAlan.id ? 'farklı teslim eden/alan'
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

  // Tahsilat sekmesinin tum durumu ve akisi ayri dosyada (belgeTahsilat.ts):
  //   liste, cek/senet karti, kasa islemi acilislari ve silme.
  const tahsilat = useBelgeTahsilat({ kayitliId, aktifSekme, cari, onKaydedildi, setHata,
                                     onPencereKapandi: tur => { void posSonrasi(tur) } });
  const { tahsilatAdimi } = tahsilat;

  const tahsilatAc = async (tahsilatTuru = 21) => {
    if (kayitliId) { tahsilatAdimi(tahsilatTuru, kayitliId); return }

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
  const personelSecildi = (id: number, ad: string) => {
    setPersonelId(id || null);
    setPersonelAd(ad);
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
    void (async () => {
      try {
        const y = await api.liste('prim-rol-aday', {
          sayfa: 1, boyut: 1,
          filtre: { op: 'and', kosullar: [{ alan: 'id', op: 'esit', deger: id }] },
        });
        const b = Number(y.satirlar[0]?.bolumId ?? 0);
        if (b) setBolumId(b);
      } catch { /* bolum cozulemezse alan elle secilir */ }
    })();
  };

  // Secili kisinin adi: liste yuklendiginde ya da belge acildiginda cozulur.
  useEffect(() => {
    if (!personelId) { setPersonelAd(''); return }
    const g = gorevliler.find(x => x.id === personelId);
    if (g) { setPersonelAd(g.ad); return }
    void (async () => {
      try {
        const y = await api.liste('prim-rol-aday', {
          sayfa: 1, boyut: 1,
          filtre: { op: 'and', kosullar: [{ alan: 'id', op: 'esit', deger: personelId }] },
        });
        setPersonelAd(String(y.satirlar[0]?.ad ?? ''));
      } catch { /* ad okunamazsa kutu bos gorunur, kimlik korunur */ }
    })();
  }, [personelId, gorevliler]);

  /**
   * VARSAYILAN ODEYEN KURUM (kullanici: "default kurum seçili varsa o gelir"):
   * hasta secilince onun KAYITLI kurumu (taraf_hasta.kurum_id) basvuruya gecer.
   * Hastanin kurumu yoksa kurum listesindeki "Özel" (tur 1) satiri secilir -
   * "hasta kendi öder" de bir kurumdur ve alan ZORUNLUDUR.
   *
   * YALNIZ YENI KARTTA: kayitli belgede kullanicinin secimi ezilmez.
   */
  useEffect(() => {
    if (!basvuruMu || belgeId || !cari?.id || odeyenKurumId != null || kurumlar.length === 0) return;
    let iptal = false;
    void (async () => {
      let secilen: number | null = null;
      try {
        const y = await api.liste('hasta', {
          sayfa: 1, boyut: 1,
          filtre: { alan: 'id', op: 'esit', deger: cari.id },
        });
        const k = Number(y.satirlar[0]?.kurumId ?? 0);
        if (k && kurumlar.some(x => x.id === k)) secilen = k;
      } catch { /* okunamazsa asagidaki varsayilana duser */ }
      if (secilen === null) secilen = kurumlar.find(x => x.tur === 1)?.id ?? null;
      if (!iptal && secilen != null) void odeyenKurumDegisti(secilen);
    })();
    return () => { iptal = true };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [basvuruMu, belgeId, cari?.id, kurumlar.length]);

  // Gonderen HIC secilmemisse gelis sekli bos kalmasin: basvuru "kendi
  //   isteğiyle" acilmis demektir (kullanici). Kullanici degistirirse
  //   dokunulmaz - yalniz BOS alan doldurulur.
  useEffect(() => {
    if (!basvuruMu || personelId) return;
    setBasvuruBilgi(o => (Number(o.gelisSekli ?? 0)
      ? o : { ...o, gelisSekli: gelisSekliKarari(false) }));
  }, [basvuruMu, personelId]);

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
        setTeklifDurum(d.teklifDurum);
        setRevizeNo(d.revizeNo);
        setTeklifKonusu(d.teklifKonusu);
        setTeklifTeslim(d.teklifTeslim);
        setDepo(d.depo);
        setGirisDepo(d.girisDepo);
        setSatici(d.satici);
        setTeslimEden(d.teslimEden);
        setTeslimAlan(d.teslimAlan);
        setTeslimSekli(d.teslimSekli);
        setSenaryo(d.senaryo);
        setSevkTarihi(d.sevkTarihi);
        setSoforTckn(d.soforTckn);
        setAracPlaka(d.aracPlaka);
        setSoforAd(d.soforAd);
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

  // Faturalama sekmesi: bu belgeden turetilmis belgeler (F8 zinciri).
  const donusumleriYukle = useCallback(async (id?: number) => {
    // Id DISARIDAN verilebilir: yeni kaydedilen belgede `kayitliId` state'i
    //   henuz guncellenmemis olur (setAcilanId asenkron) - hizli donusum
    //   listesi bos kalmasin.
    const hedef = id ?? kayitliId;
    if (!hedef) { setDonusumler([]); return }
    try { setDonusumler(await api.belgeDonusumler(hedef)) } catch { setDonusumler([]) }
  }, [kayitliId]);

  useEffect(() => {
    if (!kayitliId || aktifSekme !== 'fatura') return;
    void donusumleriYukle();
  }, [kayitliId, aktifSekme, donusumleriYukle]);

  /** Hizli donusum olcusu (kullanici): 'adet' kalan miktar · 'tutar' tahsil edilen. */
  const [donusumOlcusu, setDonusumOlcusu] = useState<'adet' | 'tutar'>('adet');

  /**
   * HIZLI DONUSUM (kullanici): modal ACMADAN hedef belgeyi uretir ve Faturalama
   * listesine ekler - tahsilat sekmesindeki hizli akisin aynisi.
   *
   * OLCU:
   *   adet  -> her acik satirin KALAN MIKTARI (klasik siparis -> fatura)
   *   tutar -> fis/faturada TAHSIL EDILEN kadar, tahakkukta kalanin TAMAMI
   *            (352 tutar bazli donusum; ortak hesap `belgeDonusumHesap`)
   *
   * Cevrilecek bir sey yoksa (kapanmis belge, tahsilat yok) kullaniciya
   * sebebi soylenir - sessizce durmasin.
   */
  async function hizliDonustur(hedefTur: number) {
    // ONCE KAYDET (kullanici: "fiş butonuna bastım, ücret ve tahsilat
    //   satırlarını henüz kayıtlı olmadığı için göremedi"): acik satirlar
    //   SUNUCUDAN okunuyor - ekrandaki kalemler yazilmadan donusum bos kalir.
    //   `kes(false)` karti KAPATMAZ; hata varsa 0 doner ve mesaji zaten gosterir.
    const id = await kes(false);
    if (!id) return;
    try {
      const acik = await api.belgeAcikSatirlar(id);
      const gonderilecek = donusumSatirlari(acik, hedefTur, donusumOlcusu);

      if (gonderilecek.length === 0) {
        mesaj(donusumOlcusu === 'tutar'
          ? 'Dönüştürülecek tutar yok: bu belgede tahsil edilmiş ve henüz belgelenmemiş tutar bulunmuyor.'
          : 'Dönüştürülecek açık satır yok.');
        return;
      }

      const yeni = await api.belgeDonustur(id, hedefTur, gonderilecek,
                                           undefined, false, undefined,
                                           donusumOlcusu === 'tutar' ? 1 : 0, false);
      await donusumleriYukle(id);
      try { setSonuc(await api.belgeOku(id)) } catch { /* yoksay */ }
      mesaj(`Belge oluşturuldu: ${String(yeni.belge.belgeNo ?? yeni.belge.id)}`);
    } catch (h) { const m = hataMetni(h); setHata(m); mesaj(m) }
  }

  /**
   * POS TAHSILATI SONRASI AKSIYON (355 ayari `basvuru.pos_aksiyon`):
   *   0 Aksiyon yok · 1 Otomatik fis · 2 "Fiş kesilsin mi?" diye sor.
   *
   * Fis TAHSIL EDILEN KADAR kesilir (tutar bazli donusum, 352): her acik
   * satirda hasta payinin kalani ile o satira DAGITILMIS tahsilatin kucugu
   * alinir - donusum modalinin onerdigi tutarin aynisi (ortak hesap dosyasi).
   * Kalan tutar basvuruda acik kalir; tahakkuk istenirse elle cevrilir.
   *
   * Pencere kaydedilmeden kapatildiysa dagitilacak yeni tahsilat olmaz, tutar
   * sifir cikar ve sessizce cikilir.
   */
  async function posSonrasi(tur: number) {
    if (tur !== 25 || !basvuruMu || !kayitliId || posAksiyon === 0) return;
    try {
      const acik = await api.belgeAcikSatirlar(kayitliId);
      const { satirlar: secim, toplamDahil: toplam } = posFisiSecimi(acik);
      if (secim.length === 0) return;
      if (posAksiyon === 2 && !(await onay(
            `POS tahsilatı için ${para.format(toplam)} ₺ tutarında satış fişi kesilsin mi?`)))
        return;

      const yeni = await api.belgeDonustur(kayitliId, 16, secim,
        undefined, false, undefined, 1, false);

      await donusumleriYukle();
      try { setSonuc(await api.belgeOku(kayitliId)) } catch { /* yoksay */ }
      mesaj(`Satış fişi oluşturuldu: ${String(yeni.belge.belgeNo ?? yeni.belge.id)}`
            + ` · ${para.format(toplam)} ₺`);
    } catch (h) {
      setHata(hataMetni(h));
    }
  }

  /**
   * HIZLI TAHSILAT TUTARI: belgenin ACIK BORCU (ucretlendirme - tahsilat).
   * Eksiye dusmez; kapanmis belgede 0 gelir ve sunucu tahsilati reddeder.
   */
  const hizliTutar = () => Math.max(0, Math.round(basvuruAcikBorc * 100) / 100);

  /**
   * Hizli tahsilat TUTARI: acik borc varsa o, YOKSA kullaniciya sorulur
   * (kullanici: "banka / pos seçtim ama satıra eklenmedi" - belge tam tahsil
   * edilmisti, tutar 0 cikiyor ve islem sessizce duruyordu). Iptal edilirse
   * 0 doner ve satir eklenmez.
   */
  const tahsilatTutariSor = async (baslik: string) => {
    const kalan = hizliTutar();
    if (kalan > 0) return kalan;
    const metin = await metinSor(
      `${baslik}: bu belgede açık borç yok. Tahsilat tutarını yazın (₺)`, '');
    const t = metin === null ? 0 : hamSayi(metin);
    if (metin !== null && !(t > 0)) mesaj('Tutar sıfırdan büyük olmalı.');
    return t;
  };

  /**
   * NAKIT: kart ACILMADAN kasaya satir ekler. Kasa secimi KASA TANIMINDAKI
   * ATAMA sutunundan gelir (200, kullanici - ayri bir ayar yok):
   *     1) oturumu acan kullaniciya ATANMIS kasa (hesap.atama = kullanici id)
   *     2) yoksa ATAMASI "Ana Kasa" olan kasa (hesap.atama = -1)
   *     3) o da yoksa kod sirasindaki ilk aktif yerel para kasasi
   * Boylece veznedar kendi kasasina, oteki kullanicilar ana kasaya yazar.
   */
  const hizliNakit = async () => {
    try {
      const tutar = await tahsilatTutariSor('Nakit');
      if (!(tutar > 0)) return;
      // Kasa secim SIRASI kural dosyasinda (atama > ana kasa > herhangi biri).
      let h: Record<string, unknown> | null = null;
      for (const filtre of kasaAramaSirasi(kullanici?.id ?? null, yerelPara)) {
        const y = await api.liste('hesap', {
          sayfa: 1, boyut: 1, sirala: [{ alan: 'kod', yon: 'asc' }], filtre,
        });
        if (y.satirlar[0]) { h = y.satirlar[0]; break }
      }
      if (!h) { mesaj('Aktif kasa hesabı bulunamadı - Kasa tanımlarından bir kasa açın.'); return }
      await tahsilat.hizliTahsilat(alisMi ? 31 : 21, Number(h.id), tutar,
                                   String(h.ad ?? ''));
    } catch (e) { setHata(hataMetni(e)) }
  };

  /**
   * Turetilmis belgenin kartini acar - USTTE IKINCI KART olarak.
   *
   * Once turun liste rotasina (`/satis-fisi/114347`) gidiliyordu; o rotalar
   * KAYITLI DEGIL (belge listelerinde `kartYolu` yok, App yalniz `/<rota>`
   * uretiyor) - tiklayinca hicbir sey acilmiyordu. Kart zaten `id` + `onKapat`
   * ile tek basina calisiyor: fis/tahakkuk basvurunun USTUNDE acilir, kapaninca
   * donusum listesi tazelenir.
   */
  const [acilanDonusum, setAcilanDonusum] = useState<number | null>(null);
  const donusumAc = (id: number) => setAcilanDonusum(id);

  /**
   * Secili turetilmis belgeleri siler. Kaynak satirin kapatilan/kalan sayaci
   * DB tarafinda silme tetigiyle geri doner - bu yuzden belge de tazelenir.
   * Silinemeyen belgede (kasa islemi bagli, e-Belge gonderilmis...) sunucunun
   * sebebi gosterilir ve digerlerinin silinmesi surer.
   */
  const donusumSil = async (idler: number[]) => {
    if (!idler.length) return;
    if (!await onay(idler.length === 1
        ? 'Seçili belge silinecek. Onaylıyor musunuz?'
        : `Seçili ${idler.length} belge silinecek. Onaylıyor musunuz?`, true)) return;
    setHata(null);
    const hatalar: string[] = [];
    for (const id of idler) {
      try { await api.belgeSil(id) } catch (h) { hatalar.push(hataMetni(h)) }
    }
    await donusumleriYukle();
    if (kayitliId) { try { setSonuc(await api.belgeOku(kayitliId)) } catch { /* yoksay */ } }
    if (hatalar.length) setHata(hatalar.join(' | '));
  };

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

  /** Yalniz ONIZLEME: gercek tutar sunucudan gelir. */
  const onizleme = useMemo(() => {
    let matrah = 0, kdv = 0;
    satirlar.forEach(s => {
      const adet = hamSayi(s.adet);
      const fiyat = hamSayi(s.birimFiyat);
      // Stok fisi vergisizdir (asagida satir da 0 ile gonderilir).
      const oran = stokFisiMi ? 0 : hamSayi(s.kdv);
      const tutar = stokFisiMi ? adet * fiyat
                               : satirTutari(adet, fiyat, s.iskonto, s.iskonto2);
      matrah += tutar;
      kdv += tutar * oran / 100;
    });
    return { matrah, kdv, genel: matrah + kdv };
  }, [satirlar, stokFisiMi]);

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
  async function stokSecildi(sec: Record<string, unknown>) {
    // Secim "Son / Sik Aranan" sayacina islensin - listede oldugu gibi.
    void api.aramaIsaretle(sec.tip === 'hizmet' ? 'hizmet' : 'stok', Number(sec.id));
    let yeni = stokSecimindenKalem(sec, sonAnahtar(satirlar) + 1, yerelPara);

    // FIYAT LISTESI ONCELIKLI (205/207): belgenin listesi varsa fiyat ORADAN
    //   gelir; kartin kendi fiyati yalniz listede kalem yoksa kalir.
    if (fiyatListesiId || kampanyaId) {
      try {
        // Fiyat LISTE + KAMPANYA (274): baz listeden, indirim kampanyadan.
        //   Kampanya yoksa uc liste fiyatini doner.
        const f = await api.fiyatKalem(
          sec.tip === 'hizmet' ? { hizmetId: Number(sec.id) } : { stokId: Number(sec.id) },
          { tarafId: cari?.id ?? null, kurumId: odeyenKurumId, listeId: fiyatListesiId });
        yeni = kampanyaFiyatiUygula(yeni, f);
      } catch { /* liste fiyati alinamazsa kart fiyati kalir */ }
    }
    setKalem(yeni);
  }

  const kalemKaydet = (satir: SatirDurumu) => {
    // PAKET SATIRI FIYATSIZ: icerik satirlari kendi fiyatlariyla geldigi icin
    //   pakete de fiyat yazilsa belge toplami IKI KEZ sayardi. Paket satiri
    //   basliktir; tutar icerikte toplanir.
    const yazilacak = satir.paket
      ? { ...satir, birimFiyat: '0', dovizFiyat: '0' }
      : satir;
    setSatirlar(s => s.some(x => x.anahtar === yazilacak.anahtar)
      ? s.map(x => (x.anahtar === yazilacak.anahtar ? yazilacak : x))
      : [...s, yazilacak]);
    setKalemDegisti(true);

    // RAPOR DOVIZI ILK DOVIZLI KALEMDEN gelir (kullanici): dovizli fiyatla
    //   kalem eklenince belge o dovizde raporlanir, kur da kalemin kurudur.
    //   Sonraki kalemler rapor dovizini DEGISTIRMEZ - kullanici isterse
    //   asagidaki kutudan kendisi secer.
    if (satir.fiyatDovizi && satir.fiyatDovizi !== yerelPara && raporDovizi === yerelPara) {
      setRaporDovizi(satir.fiyatDovizi);
      const k = hamSayi(satir.kur);
      if (k > 0) setBelgeKuru(String(k));
    }

    if (!satir.paket || !satir.stokId) return;
    void api.paketIcerigi(satir.stokId, bilgi.alis)
      .then(icerik => {
        if (icerik.length === 0) return;
        setSatirlar(s => paketIcerigiUygula(s, satir, icerik));
      })
      .catch(h => setHata(hataMetni(h)));
  };

  /** Secili satirlari siler - grid salt gorunum oldugu icin satir ici silme yok. */
  const seciliSil = () => {
    if (seciliSatirlar.size === 0) return;
    // Paket satiri silinince ICERIGI de gider - yoksa sahipsiz icerik
    //   satirlari belgede kalirdi.
    setSatirlar(s => s.filter(x =>
      !seciliSatirlar.has(x.anahtar)
      && !(x.paketAnahtar !== undefined && seciliSatirlar.has(x.paketAnahtar))));
    setSeciliSatirlar(new Set());
    setKalemDegisti(true);
  };

  /**
   * Satira tiklama - liste gridleriyle ayni davranis:
   *   duz tik = yalniz o satir · Ctrl/Cmd = ekle-cikar · Shift = aralik.
   */
  const satirTikla = (sira: number, e: React.MouseEvent) => {
    const anahtarlar = satirlar.map(x => x.anahtar);
    if (e.shiftKey && sonTiklanan.current !== null) {
      const [bas, son] = [sonTiklanan.current, sira].sort((a, b) => a - b);
      setSeciliSatirlar(k => new Set([...k, ...anahtarlar.slice(bas, son + 1)]));
      return;
    }
    sonTiklanan.current = sira;
    if (e.ctrlKey || e.metaKey) { secimDegis(anahtarlar[sira]); return }
    setSeciliSatirlar(new Set([anahtarlar[sira]]));
  };

  const secimDegis = (anahtar: number) =>
    setSeciliSatirlar(k => {
      const y = new Set(k);
      if (y.has(anahtar)) y.delete(anahtar); else y.add(anahtar);
      return y;
    });

  /**
   * Belgeyi kaydeder ve kaydedilen belgenin id'sini doner (0 = kaydedilemedi).
   *
   * `kapatilsin=false` yalnizca "kaydet ve devam et" akislarinda kullanilir
   * (Tahsilat dugmesi): kart acik kalir ki acilan tahsilat penceresi kapaninca
   * kullanici belgeye geri donsun.
   */
  async function kes(kapatilsin = true): Promise<number> {
    setHata(null);
    setAlanHatalari({});
    // `sonuc` BURADA SIFIRLANMAZ (kullanici: "ödeyen kurum dolu olmalı diyor
    //   ama her taraf donmuş"): `duzenlenebilir` hesabi `!!sonuc`a bagli -
    //   dogrulama hatasi verdiginde sonuc null kalinca KART KILITLENIYOR ve
    //   kullanici hatayi duzeltemiyordu. Basarili kayitta zaten yeni yanit
    //   yaziliyor (setSonuc(yanit)).

    // Kart durumu tek nesnede: dogrulama ve istek govdesi SAF fonksiyonlarda
    //   (belgeKaydet.ts) - ekran yalniz sonucu gosterir.
    const girdi: BelgeGirdisi = {
      tur, cari, tarih, tarihEnGec, tarihEnErken, geriGun, seri, belgeNo, vadeGun, faturaTipi,
      // Basvuruda vade yerine odeyen kurum gonderilir (249); bolum ve hekim
      //   de basvuruya ozgu (296) - hepsi belge_basvuru uzantisina yazilir.
      ...(basvuruMu
        ? { odeyenKurumId, bolumId, personelId, basvuruAlanlari: basvuruBilgi }
        : {}),
      fiyatListesiId,
      // Kampanya belgeye YAZILIR (274): kurum sonradan kampanya degistirse
      //   eski belgenin hangi anlasmayla kesildigi sabit kalir.
      kampanyaId,
      // Teklif durumu yalniz teklifte anlamli - baska turde gonderilmez.
      ...(teklifMi ? { teklifDurum: Number(teklifDurum) || 1, revizeNo,
                       teklifKonusu, teklifTeslim } : {}),
      aciklama,
      raporDovizi, ekstreDovizi, belgeKuru, yerelPara,
      senaryo, satici, depo, girisDepo, teslimEden, teslimAlan, tasiyici,
      aracPlaka, soforAd, soforTckn, sevkTarihi, teslimSekli, fisTipi, satirlar,
      subeId: kullanici?.subeId ?? undefined,
      alisMi, irsaliyeMi, faturaMi, depoBelgesi, stokFisiMi, fisCikisMi, transferMi,
      talepMi, disNumarali, basvuruMu,
      // Zorunluluk kurallari yalniz duzenlenebilir kartta (bkz. belgeDogrula).
      kilitli,
    };
    const hatalar = belgeDogrula(girdi);
    if (hatalar) {
      if (hatalar.genel) setHata(hatalar.genel);
      else setAlanHatalari(hatalar);
      return 0;
    }
    const dolu = doluSatirlar(satirlar);
    setKaydediyor(true);
    try {
      const govde = belgeGovdesi(girdi, dolu, taslak);

      // DUZENLEME (135): kayitli belge PUT ile yeniden yazilir - numara korunur,
      //   eski stok/cari etkisi sunucuda geri alinip yenisi uygulanir.
      // IKINCI kayit UPDATE olmali: basvuru kartta acik kaldigi icin ayni
      //   dugmeye tekrar basiliyor - etkinBelgeId olmasa her basis yeni belge
      //   uretirdi.
      const yanit = duzenlenebilir && etkinBelgeId
        ? await api.belgeGuncelle(etkinBelgeId, govde)
        : await api.belgeEkle(govde);
      setSonuc(yanit);
      // Kayit sonrasi kart TEMIZ sayilir (kaydedilmemis degisiklik uyarisi).
      setImzaTazele(n => n + 1);
      onKaydedildi?.();
      // GENEL KURAL (kullanici): Kaydet'e basilinca form KAPANIR. Belgeye sonradan
      //   yapilacak isler (e-Belge gonderimi, donusum) listeden belge yeniden
      //   acilarak surdurulur - kart acik birakmak "kaydettim mi?" belirsizligi
      //   yaratiyordu. Tek istisna "kaydet ve devam et" (kapatilsin=false).
      const yeniId = Number(yanit.belge.id ?? 0);
      // BASVURU akisi (300): ilk kayit KAPATMAZ - protokol verilir, kart acik
      //   kalir; ucretlendirme ve provizyon girildikten sonra ayni dugmeyle
      //   kaydedilip kapatilir. Diger turlerde genel kural surer.
      if (basvuruMu && !etkinBelgeId && yeniId) { setAcilanId(yeniId); return yeniId }
      if (kapatilsin) void kapat(true);
      return yeniId;
    } catch (h) {
      const c = hataAyristir(h);
      setAlanHatalari(c.alanlar);
      setHata(c.mesaj);
    } finally {
      setKaydediyor(false);
    }
    return 0;
  }

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
  }

  /**
   * ODEYEN KURUM degisti (274): kampanya kurumun sozlesmesinden geldigi icin
   * once kampanya yeniden cozulur (listesi varsa belgenin listesi ona cekilir),
   * sonra satirlar o listeyle yeniden fiyatlanir. Kalemsiz belgede yalniz
   * baslik guncellenir - mesaj cikmaz.
   */
  async function odeyenKurumDegisti(yeni: number | null) {
    setOdeyenKurumId(yeni);
    if (kilitli) return;

    // Kampanya cozulemezse mevcut liste ile devam edilir (kampanyaCoz yutar).
    const liste = (await kampanyaCoz(yeni, true)) ?? fiyatListesiId;

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
  const [temizImza, setTemizImza] = useState<string | null>(null);
  const [imzaTazele, setImzaTazele] = useState(0);
  /**
   * ACILIS YARISI (kullanici korumasi): kart acilirken bazi alanlar EFEKTLE
   * doluyor - gelis sekli, odeyen kurum varsayilani, fiyat listesi, depo. Bir
   * kismi API cagrisiyla geldigi icin imza hemen alinirsa kart, kullanici hic
   * dokunmadan "kirli" gorunur. Bu yuzden acilistan sonra kisa bir sure imza
   * SUREKLI tazelenir; pencere bitince kullanici degisiklikleri sayilir.
   */
  const [acilisPenceresi, setAcilisPenceresi] = useState(true);
  useEffect(() => {
    setAcilisPenceresi(true);
    const z = window.setTimeout(() => setAcilisPenceresi(false), 1500);
    return () => window.clearTimeout(z);
  }, [belgeId, acilanId]);
  useEffect(() => { if (acilisPenceresi) setTemizImza(imza) }, [acilisPenceresi, imza]);
  // Her BASARILI kayittan sonra da "temiz" durum yeniden alinir.
  useEffect(() => { setTemizImza(imza) },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [imzaTazele]);
  const kirli = temizImza !== null && temizImza !== imza;

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
        return mevcutBelge
          ? `${ad}${sonuc?.belge.belgeNo ? ` — ${sonuc.belge.belgeNo}` : ''}`
          : ad;
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
          setDonusum={setDonusum} setTerminAcik={setTerminAcik}
          rezerveVar={rezerveVar} rezerveCalisiyor={rezerveCalisiyor}
          rezerveDegistir={rezerveDegistir}
          hastaVar={!!cari?.id}
          hastaKartiAc={() => { setHastaKartId(cari?.id ?? null); setCariArama(true) }}
          radyolojiIstemi={() => setIstemModali(true)}
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

        {/* SECILI HASTA SERIDI (298, mockup): basligin USTUNDE - kabul memuru
            dogru hastada oldugunu surekli gorsun. */}
        {basvuruMu && (
          <HastaSeridi tarafId={cari?.id}
                       kurumAdi={kurumlar.find(k => k.id === odeyenKurumId)?.ad}
                       acikBorc={basvuruAcikBorc}
                       mustehaklik={Number(basvuruBilgi.sgkMustehaklik ?? 0)}
                       protokolNo={belgeNo || String(sonuc?.belge.belgeNo ?? '')}
                       kilitli={kilitli}
                       kapanma={KAPANMA_ETIKET[Number(sonuc?.belge.kapanmaDurum ?? 0)]}
                       onAra={metin => { setHastaAramaMetni(metin); setCariArama(true) }}
                       onYeniHasta={() => { setHastaAramaYeni(true); setCariArama(true) }} />
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
          teklifDurum={teklifDurum} setTeklifDurum={setTeklifDurum}
          revizeNo={revizeNo} setRevizeNo={setRevizeNo}
          teklifKonusu={teklifKonusu} setTeklifKonusu={setTeklifKonusu}
          teklifTeslim={teklifTeslim} setTeklifTeslim={setTeklifTeslim}
          cari={cari} satici={satici}
          depo={depo} setDepo={setDepo} girisDepo={girisDepo} setGirisDepo={setGirisDepo}
          teslimEden={teslimEden} teslimAlan={teslimAlan}
          fisTipi={fisTipi} setFisTipi={setFisTipi}
          faturaTipi={faturaTipi} setFaturaTipi={setFaturaTipi}
          satirlar={satirlar} donusumler={donusumler}
          setCariArama={setCariArama} setSaticiArama={setSaticiArama}
          setPersonelArama={setPersonelArama}
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
            seciliSatirlar={seciliSatirlar} setSeciliSatirlar={setSeciliSatirlar}
            acikLotlar={acikLotlar} setAcikLotlar={setAcikLotlar}
            kilitli={kilitli} bilgi={bilgi} onizleme={onizleme}
            sonuc={kalemDegisti ? null : sonuc}
            transferBaslikEksigi={transferBaslikEksigi}
            depoBelgesi={depoBelgesi} stokFisiMi={stokFisiMi} talepMi={talepMi}
            setStokArama={iadeMi ? setIadeArama : setStokArama}
            setKalem={setKalem} seciliSil={seciliSil}
            // PRIM ROLLERI (324): prim HBYS kavrami (hekim hakedisi) -
            //   ERP modunda dugme hic cizilmez.
            onRoller={kullanici?.urunModu === URUN_GENOTIP && yetki('prim', 'degistir')
              ? (satirId, ad) => (satirId > 0
                  ? setRolModali({ satirId, ad })
                  : mesaj('Rol tanımlamak için önce belgeyi kaydedin.'))
              : undefined}
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
                        katkiModu: paylasimModu === 2,
                        uygula: () => void provizyonUygula() }}
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
            tasiyici={tasiyici} setTasiyici={setTasiyici}
            teslimEden={teslimEden} setTeslimEden={setTeslimEden}
            aracPlaka={aracPlaka} setAracPlaka={setAracPlaka}
            soforAd={soforAd} setSoforAd={setSoforAd}
            soforTckn={soforTckn} setSoforTckn={setSoforTckn}
            sevkTarihi={sevkTarihi} setSevkTarihi={setSevkTarihi}
            teslimSekli={teslimSekli} setTeslimSekli={setTeslimSekli}
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
            donusumler={donusumler} kayitliId={kayitliId} setDonusum={setDonusum}
            teklifMi={teklifMi} teklifDurum={teklifDurum}
            donusumAc={donusumAc} donusumSil={donusumSil}
            hizliDonustur={t => void hizliDonustur(t)}
            olcu={donusumOlcusu} setOlcu={setDonusumOlcusu}
          />
        )}
        {aktifSekme === 'tahsilat' && (
          <TahsilatSekmesi sonuc={sonuc} tahsilatlar={tahsilat.tahsilatlar}
                           kayitliId={kayitliId} alisMi={alisMi} tahsilatAc={tahsilatAc}
                           secili={tahsilat.seciliTahsilatlar}
                           setSecili={tahsilat.setSeciliTahsilatlar}
                           tahsilatAcKart={tahsilat.setTahsilatKayitId}
                           tahsilatSil={tahsilat.tahsilatSil}
                           hizliNakit={() => void hizliNakit()}
                           hesapSecAc={t => setHesapSecim(t)}
                           tutarGuncelle={tahsilat.tutarGuncelle}
                           acikBorc={hizliTutar()}
                           onYenile={() => { if (kayitliId) void api.belgeOku(kayitliId)
                                              .then(setSonuc).catch(() => {}) }}
                           // KURUM TAHAKKUKU (331): yalniz odeyen kurumlu
                           //   basvuruda; kurum payini Satış Tahakkukuna (17)
                           //   donusturur - tahsilat DEGIL.
                           kurumTahakkukAc={basvuruMu && odeyenKurumId
                             ? () => { setDonusumPay(2); setDonusum(17) }
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
            setOdeyenKurumId={v => void odeyenKurumDegisti(v)}
            aciklama={aciklama} setAciklama={setAciklama}
            // LAB / GORUNTULEME kurumu (364): hekim rolu "Gönderen" (1) ise
            //   basvuru turu ve poliklinik odasi sorulmaz, hekim alani
            //   "Gönderen" olur.
            gonderenModu={gonderenModu}
            personelAd={personelAd} onPersonelSec={personelSecildi}
            kurumHatasi={alanHatalari.odeyenKurumId}
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
          depo={depo} sonuc={sonuc} setSonuc={setSonuc}
          cari={cari} setCari={setCari}
          cariArama={cariArama} setCariArama={setCariArama}
          hastaAramaMetni={hastaAramaMetni} setHastaAramaMetni={setHastaAramaMetni}
          hastaAramaYeni={hastaAramaYeni} setHastaAramaYeni={setHastaAramaYeni}
          hastaKartId={hastaKartId} setHastaKartId={setHastaKartId}
          saticiArama={saticiArama} setSaticiArama={setSaticiArama} setSatici={setSatici}
          personelArama={personelArama} setPersonelArama={setPersonelArama}
          setTeslimEden={setTeslimEden} setTeslimAlan={setTeslimAlan}
          satirlar={satirlar} setSatirlar={setSatirlar}
          stokArama={stokArama} setStokArama={setStokArama}
          aramaEklenen={aramaEklenen} setAramaEklenen={setAramaEklenen}
          stokSecildi={stokSecildi}
          kalem={kalem} setKalem={setKalem} kalemKaydet={kalemKaydet}
          iadeArama={iadeArama} setIadeArama={setIadeArama}
          tahsilat={tahsilat} tahsilatTutariSor={tahsilatTutariSor}
          hesapSecim={hesapSecim} setHesapSecim={setHesapSecim}
          donusum={donusum} setDonusum={setDonusum}
          donusumPay={donusumPay} setDonusumPay={setDonusumPay}
          acilanDonusum={acilanDonusum} setAcilanDonusum={setAcilanDonusum}
          donusumleriYukle={donusumleriYukle}
          terminAcik={terminAcik} setTerminAcik={setTerminAcik}
          rolModali={rolModali} setRolModali={setRolModali}
          istemModali={istemModali} setIstemModali={setIstemModali}
          onKaydedildi={onKaydedildi} git={git}
        />
      </>
    </Modal>
  );
}
