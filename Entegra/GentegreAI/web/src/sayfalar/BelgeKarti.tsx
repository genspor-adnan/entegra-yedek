import { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { guvenli, mesaj, metinSor } from '../bilesenler/mesaj';
import { type BelgeYaniti, type KasaIslemTuru, URUN_GENOTIP, hataMetni, hataAyristir } from '../api/sozlesme';
import { Modal } from '../bilesenler/Modal';
import { StokAramaPenceresi } from '../bilesenler/StokAramaPenceresi';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { TarafArama } from '../bilesenler/TarafArama';
import { belgeTuruBilgisi, GIRILEBILIR_TURLER, VARSAYILAN_TUR } from './belgeTuru';
import { DokumanGalerisi } from '../bilesenler/DokumanGalerisi';
import { useOturum } from '../kimlik/OturumBaglami';
import { para, yerelAnMetni, hamSayi } from '../bilesenler/bicim';
import { type SatirDurumu, satirTutari, yanittanSatirlar } from './belgeSatir';
import { belgeDogrula, belgeGovdesi, doluSatirlar, type BelgeGirdisi } from './belgeKaydet';
import {
  YEREL_PARA_VARSAYILAN, GERIYE_GUN_VARSAYILAN, KAPANMA_ETIKET,
} from './belgeSabitleri';
import { KalemPenceresi } from '../bilesenler/belge/KalemPenceresi';
import { TerminModali } from '../bilesenler/belge/TerminModali';
import {
  TasiyiciSekmesi, EBelgeSekmesi, FaturalamaSekmesi,
} from '../bilesenler/belge/BelgeSekmeleri';
import { KalemSekmesi, TahsilatSekmesi } from '../bilesenler/belge/KalemSekmesi';
import {
  BasvuruSekmesi, ProvizyonSekmesi, OncekiBasvurular, HastaSeridi,
  type BasvuruBilgi,
} from '../bilesenler/belge/BasvuruSekmesi';
import { IadeSatirPenceresi } from '../bilesenler/belge/IadeSatirPenceresi';
import { BelgeAracCubugu } from '../bilesenler/belge/BelgeAracCubugu';
import { BelgeBaslik } from '../bilesenler/belge/BelgeBaslik';
import { useBelgeTahsilat } from './belgeTahsilat';
import {
  iadeSatirlari, kampanyaFiyatiUygula, paketIcerigiUygula, sonAnahtar, stokSecimindenKalem,
} from './belgeKalem';
import { BelgeTahsilatModallari } from '../bilesenler/belge/BelgeTahsilatModallari';

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
      })
      .catch(() => { /* varsayilan kalir */ });
  }, []);

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
  // BASVURU (249): vade yerine "Ödeyen Kurum" - hizmeti kim odeyecek
  //   (anlasmali kurum / sigorta / SGK). Bos = hasta kendi oder.
  const [odeyenKurumId, setOdeyenKurumId] = useState<number | null>(null);
  const [kurumlar, setKurumlar] = useState<{ id: number; ad: string; tur: number }[]>([]);
  /**
   * BASVURU BASLIGI (296/297): basvurulan BOLUM ve karsilayan PERSONEL.
   * Personel HEKIM OLMAK ZORUNDA DEGIL (kullanici): diyetisyen,
   * fizyoterapist, teknisyen de basvuru karsilar - kisit "randevu verilebilir
   * personel" + secili bolum. Ikisi de belge_basvuru uzantisinda saklanir.
   */
  const [bolumId, setBolumId] = useState<number | null>(null);
  const [personelId, setPersonelId] = useState<number | null>(null);
  /**
   * BASVURU SEKMESI (298) alanlari TEK NESNEDE: on kadar alan icin ayri ayri
   * state tutmak karti sisiriyordu; hepsi belge_basvuru uzantisina gider.
   */
  const [basvuruBilgi, setBasvuruBilgi] = useState<BasvuruBilgi>({});
  const [bolumler, setBolumler] = useState<{ id: number; ad: string }[]>([]);
  /** Basvuruda depo combosu dip bolumde cizilir - liste burada tutulur. */
  const [depolar, setDepolar] = useState<{ id: number; ad: string }[]>([]);
  const [gorevliler, setGorevliler] = useState<{ id: number; ad: string }[]>([]);
  /**
   * YURURLUKTEKI KAMPANYA (274). Fiyat listesiyle YARISMAZ: liste BAZ fiyati,
   * kampanya INDIRIMI verir. Baslikta rozet olarak gorunur ve belgeye YAZILIR -
   * kurum sonradan kampanya degistirse eski belge kendi kampanyasini tasir.
   * Kayitli belgede COZULMEZ, kayittan okunur.
   */
  const [kampanyaId, setKampanyaId] = useState<number | null>(null);
  const [kampanyaAdi, setKampanyaAdi] = useState('');
  /**
   * ODEYEN KURUMUN PAY HESABI (291): 1 karsilama ORANI (ozel sigorta),
   * 2 KATILIM PAYI sabit tutar (SGK). Provizyon dugmesi buna gore davranir -
   * SGK'da oran sormak yanlis olurdu: SUT bedelinin tamami kuruma, hastadan
   * yalniz katilim payi alinir.
   */
  const [paylasimModu, setPaylasimModu] = useState(1);
  /**
   * FIYAT LISTESI (205). Acilista belge TURUNUN yonune gore cariden cozulur
   * (cari listesi > yonun varsayilani). Kullanici degistirince satirlar
   * yeniden fiyatlanir - kaydedilmis belgede sunucuda, kaydedilmemis belgede
   * satir satir listeden okunarak.
   */
  const [fiyatListesiId, setFiyatListesiIdHam] = useState<number | null>(null);
  /** Teklif durumu (218): 1 Hazirlaniyor / 2 Sunuldu / 3 Kabul / 4 Red / 5 Iptal. */
  const [teklifDurum, setTeklifDurum] = useState('1');
  const [revizeNo, setRevizeNo] = useState('');
  const [teklifKonusu, setTeklifKonusu] = useState('');
  const [teklifTeslim, setTeklifTeslim] = useState('');
  const [fiyatListeleri, setFiyatListeleri] = useState<{ id: number; ad: string }[]>([]);
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
  /** Termin (teslim tarihi) modali - siparis satirlarinin taahhudu (140). */
  const [terminAcik, setTerminAcik] = useState(false);
  /** Rezervasyon (142) islemi surerken dugme bekler. */
  const [rezerveCalisiyor, setRezerveCalisiyor] = useState(false);
  const [aktifSekme, setAktifSekme] = useState('kalem');
  /** Grid satir secimi (kirmizi Sil dugmesi bunlari siler). */
  const [seciliSatirlar, setSeciliSatirlar] = useState<Set<number>>(new Set());
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
  /** Satis temsilcisi (personel) secim modali - cari ile ayni ekran. */
  const [saticiArama, setSaticiArama] = useState(false);
  /** e-Fatura senaryosu (belge.senaryo) - GIB profilini belirler. */
  const [senaryo, setSenaryo] = useState(0);
  /** FATURA TIPI (130): faturanin cinsi - belge.tipi alaninda tutulur. */
  const [faturaTipi, setFaturaTipi] = useState(1);
  /** IADE mi - kalem secimi "onceki alinanlar"dan yapilir (132/133). */
  const iadeMi = faturaTipi === 2;
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
   * konsinye (109/119 - mal birakma, faturasi ayri kesilir) ve tahakkuk (13/17).
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
  const tahsilat = useBelgeTahsilat({ kayitliId, aktifSekme, cari, onKaydedildi, setHata });
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

  // BASVURU (249): odeyen kurum combosu - yalniz anlasmali kurumlar
  //   (taraf.kurum = 1), tum cariler degil.
  useEffect(() => {
    if (!basvuruMu || kurumlar.length > 0) return;
    void (async () => {
      try {
        const y = await api.liste('kurum', {
          sayfa: 1, boyut: 500, sirala: [{ alan: 'unvan', yon: 'asc' }],
          filtre: { op: 'and', kosullar: [{ alan: 'durum', op: 'esit', deger: 1 }] },
        });
        setKurumlar(y.satirlar.map(r => ({
          id: Number(r.id), ad: String(r.unvan ?? ''), tur: Number(r.tur ?? 0) })));
      } catch { /* kurum listesi okunamazsa combo bos kalir, kayit engellenmez */ }
    })();
  }, [basvuruMu, kurumlar.length]);

  // BASVURU (296): randevu verilebilen BOLUMLER - basvurunun yapildigi
  //   poliklinik/klinik. Randevu ekraniyla ayni kume.
  useEffect(() => {
    if (!basvuruMu || bolumler.length > 0) return;
    void (async () => {
      try {
        const y = await api.liste('departman', {
          sayfa: 1, boyut: 300, sirala: [{ alan: 'ad', yon: 'asc' }],
          filtre: { op: 'and', kosullar: [
            { alan: 'durum', op: 'esit', deger: 1 },
            { alan: 'randevuVerilebilir', op: 'esit', deger: 1 },
          ] },
        });
        // Departman kaynagi alt birimleri "— Dahiliye" gibi GIRINTILI dondurur
        //   (257, Bölüm/Görev ekranindaki agac gorunumu icin). Combo'da agac
        //   yok - onek kirpilir, yoksa her bolum tire ile basliyormus gibi durur.
        setBolumler(y.satirlar.map(r => ({
          id: Number(r.id), ad: String(r.ad ?? '').replace(/^—\s*/, '') })));
      } catch { /* bolum listesi okunamazsa combo bos kalir, kayit engellenmez */ }
    })();
  }, [basvuruMu, bolumler.length]);

  // Basvuruda depo combosu (296) icin aktif depolar.
  useEffect(() => {
    if (!basvuruMu || depolar.length > 0) return;
    void (async () => {
      try {
        const y = await api.liste('depo', {
          sayfa: 1, boyut: 200, sirala: [{ alan: 'ad', yon: 'asc' }],
          filtre: { alan: 'durum', op: 'esit', deger: 1 },
        });
        setDepolar(y.satirlar.map(r => ({ id: Number(r.id), ad: String(r.ad ?? '') })));
      } catch { /* depo listesi okunamazsa combo bos kalir */ }
    })();
  }, [basvuruMu, depolar.length]);

  /**
   * PERSONEL listesi (297): bolum SECILIYSE o bolumle sinirli, BOS ise TUM
   * randevu verilebilir personel (kullanici: "bolum secilmeden dr listesine
   * tum doktorlar gelir"). Her satir kendi bolumunu tasir - personel secilince
   * bolum ondan doldurulur.
   */
  useEffect(() => {
    if (!basvuruMu) { setGorevliler([]); return }
    let iptal = false;
    void (async () => {
      try {
        const kosullar = [
          { alan: 'durum', op: 'esit' as const, deger: 1 },
          { alan: 'randevuVerilebilir', op: 'esit' as const, deger: 1 },
          ...(bolumId ? [{ alan: 'departmanId', op: 'esit' as const, deger: bolumId }] : []),
        ];
        const y = await api.liste('personel', {
          sayfa: 1, boyut: 500, sirala: [{ alan: 'unvan', yon: 'asc' }],
          filtre: { op: 'and', kosullar },
        });
        if (!iptal) setGorevliler(y.satirlar.map(r => ({
          id: Number(r.id), ad: String(r.unvan ?? ''),
          bolumId: r.departmanId != null ? Number(r.departmanId) : null })));
      } catch { if (!iptal) setGorevliler([]) }
    })();
    return () => { iptal = true };
  }, [basvuruMu, bolumId]);

  // Mevcut belgeyi ac: baslik + satirlar + dip toplam sunucudan gelir.
  useEffect(() => {
    if (!belgeId) return;
    void (async () => {
      try {
        const y = await api.belgeOku(belgeId);
        setSonuc(y);
        setTur(Number(y.belge.tur));
        setCari({ id: Number(y.belge.tarafId), unvan: String(y.belge.tarafUnvan ?? '') });
        setTarih(String(y.belge.belgeTarihi ?? '').slice(0, 16));
        setSeri(String(y.belge.belgeSeri ?? ''));
        setVadeGun(String(y.belge.vadeGun ?? 0));
        setOdeyenKurumId(y.belge.odeyenKurumId != null ? Number(y.belge.odeyenKurumId) : null);
        setFiyatListesiIdHam(Number(y.belge.fiyatListesiId) || null);
        setBolumId(y.belge.bolumId != null ? Number(y.belge.bolumId) : null);
        setPersonelId(y.belge.personelId != null ? Number(y.belge.personelId) : null);
        setBasvuruBilgi({
          basvuruTuru: y.belge.basvuruTuru != null ? Number(y.belge.basvuruTuru) : null,
          gelisSekli: y.belge.gelisSekli != null ? Number(y.belge.gelisSekli) : null,
          gelisNedeni: y.belge.gelisNedeni != null ? Number(y.belge.gelisNedeni) : null,
          oda: y.belge.oda != null ? Number(y.belge.oda) : null,
          siraNo: String(y.belge.siraNo ?? ''),
          refakatci: String(y.belge.refakatci ?? ''),
          ambulansHastaNo: String(y.belge.ambulansHastaNo ?? ''),
          ambulansBileklikNo: String(y.belge.ambulansBileklikNo ?? ''),
          // PROVIZYON (299) - belge_provizyon 1:1; SGK ve ozel sigorta ayri.
          sgkDurum: y.belge.sgkDurum != null ? Number(y.belge.sgkDurum) : 0,
          sgkProvizyonNo: String(y.belge.sgkProvizyonNo ?? ''),
          sgkProvizyonTipi: y.belge.sgkProvizyonTipi != null
            ? Number(y.belge.sgkProvizyonTipi) : null,
          sgkProvizyonTarihi: y.belge.sgkProvizyonTarihi
            ? String(y.belge.sgkProvizyonTarihi).slice(0, 16) : null,
          sgkGecerlilik: y.belge.sgkGecerlilik
            ? String(y.belge.sgkGecerlilik).slice(0, 16) : null,
          sgkKarsilama: y.belge.sgkKarsilama != null ? String(y.belge.sgkKarsilama) : '',
          sgkTutar: y.belge.sgkTutar != null ? String(y.belge.sgkTutar) : '',
          sgkRedNedeni: String(y.belge.sgkRedNedeni ?? ''),
          sgkSigortaTuru: String(y.belge.sgkSigortaTuru ?? ''),
          sgkBasvuruNo: String(y.belge.sgkBasvuruNo ?? ''),
          sgkTakipNo: String(y.belge.sgkTakipNo ?? ''),
          sgkTakipTarihi: y.belge.sgkTakipTarihi
            ? String(y.belge.sgkTakipTarihi).slice(0, 16) : null,
          sgkTakipTuru: y.belge.sgkTakipTuru != null ? Number(y.belge.sgkTakipTuru) : null,
          sgkTesisKodu: String(y.belge.sgkTesisKodu ?? ''),
          sgkMustehaklik: y.belge.sgkMustehaklik != null
            ? Number(y.belge.sgkMustehaklik) : 0,
          sgkMustehaklikZaman: y.belge.sgkMustehaklikZaman
            ? String(y.belge.sgkMustehaklikZaman) : null,
          sgkSevkli: y.belge.sgkSevkli != null ? Number(y.belge.sgkSevkli) : 0,
          sgkSevkKurum: String(y.belge.sgkSevkKurum ?? ''),
          ossKurumId: y.belge.ossKurumId != null ? Number(y.belge.ossKurumId) : null,
          ossKurumAdi: String(y.belge.ossKurumAdi ?? ''),
          ossDurum: y.belge.ossDurum != null ? Number(y.belge.ossDurum) : 0,
          ossProvizyonNo: String(y.belge.ossProvizyonNo ?? ''),
          ossProvizyonTarihi: y.belge.ossProvizyonTarihi
            ? String(y.belge.ossProvizyonTarihi).slice(0, 16) : null,
          ossGecerlilik: y.belge.ossGecerlilik
            ? String(y.belge.ossGecerlilik).slice(0, 16) : null,
          ossKarsilama: y.belge.ossKarsilama != null ? String(y.belge.ossKarsilama) : '',
          ossTutar: y.belge.ossTutar != null ? String(y.belge.ossTutar) : '',
          ossRedNedeni: String(y.belge.ossRedNedeni ?? ''),
          ossPoliceNo: String(y.belge.ossPoliceNo ?? ''),
          ossHasarNo: String(y.belge.ossHasarNo ?? ''),
          ossBrans: String(y.belge.ossBrans ?? ''),
          provizyonAciklama: String(y.belge.provizyonAciklama ?? ''),
        });
        setKampanyaId(y.belge.kampanyaId != null ? Number(y.belge.kampanyaId) : null);
        setKampanyaAdi(String(y.belge.kampanyaAdi ?? ''));
        setTeklifDurum(String(y.belge.teklifDurum ?? '1'));
        setRevizeNo(String(y.belge.revizeNo ?? ''));
        setTeklifKonusu(String(y.belge.teklifKonusu ?? ''));
        setTeklifTeslim(String(y.belge.teklifTeslim ?? ''));
        // Alis belgesi GIRIS deposunu, satis CIKIS deposunu kullanir.
        // Transferde "depo" CIKIS deposudur, girisDepo ayri alanda tutulur;
        //   digerlerinde hangisi doluysa o tek depo alanina yansir.
        const cikisD = y.belge.cikisDepoId
          ? { id: Number(y.belge.cikisDepoId), ad: String(y.belge.cikisDepoAdi ?? '') } : null;
        const girisD = y.belge.girisDepoId
          ? { id: Number(y.belge.girisDepoId), ad: String(y.belge.girisDepoAdi ?? '') } : null;
        setDepo(Number(y.belge.tur) === 20 ? cikisD : girisD ?? cikisD);
        setGirisDepo(Number(y.belge.tur) === 20 ? girisD : null);
        setSatici(y.belge.saticiId
          ? { id: Number(y.belge.saticiId), ad: String(y.belge.saticiAdi ?? '') } : null);
        setTeslimSekli(Number(y.belge.teslimSekli ?? 0));
        setSenaryo(Number(y.belge.senaryo ?? 0));
        setSevkTarihi(y.belge.irsaliyeTarihi ? String(y.belge.irsaliyeTarihi).slice(0, 16) : '');
        setSoforTckn(String(y.belge.soforTckn ?? ''));
        setAracPlaka(String(y.belge.aracPlaka ?? ''));
        setSoforAd(String(y.belge.soforAd ?? ''));
        setTeslimEden(y.belge.teslimEdenId
          ? { id: Number(y.belge.teslimEdenId), ad: String(y.belge.teslimEdenAdi ?? '') } : null);
        setFisTipi(Number(y.belge.tipi ?? 0));
        // Faturada ayni alan FATURA TIPI'dir (130); eski kayitlarda 0 ise
        //   varsayilan "Alış / Satış" (1) gosterilir.
        setFaturaTipi(Number(y.belge.tipi) || 1);
        setRaporDovizi(String(y.belge.raporDovizi ?? y.belge.belgeDovizi ?? '') || yerelPara);
        setEkstreDovizi(String(y.belge.ekstreDovizi ?? y.belge.raporDovizi ?? '') || yerelPara);
        setBelgeKuru(String(y.belge.dovizKuru ?? 1));
        setKalemDegisti(false);
        setTeslimAlan(y.belge.teslimAlanId
          ? { id: Number(y.belge.teslimAlanId), ad: String(y.belge.teslimAlanAdi ?? '') } : null);
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
  useEffect(() => {
    if (!kayitliId || aktifSekme !== 'fatura') return;
    void (async () => {
      try { setDonusumler(await api.belgeDonusumler(kayitliId)) } catch { setDonusumler([]) }
    })();
  }, [kayitliId, aktifSekme]);

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
   * Kalem penceresinden donen satiri yazar (yeni ise ekler).
   *
   * PAKET (124): secilen stok bir paketse belgeye YALNIZ paket satiri degil,
   * ICERIGI de eklenir - "paket item + icerikleri tumuyle" (kullanici).
   * Icerik satirlari paketin adediyle CARPILIR (2 paket x 3 adet = 6) ve
   * FIYATSIZ gelir: tutar paket satirinda durur, icerikler ikinci kez
   * fiyatlanirsa belge toplami sisirdi. Icerik satirlari duzenlenebilir -
   * kullanici pakette olmayan bir sey cikarabilir/ekleyebilir.
   */
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
    setSonuc(null);

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
      raporDovizi, ekstreDovizi, belgeKuru, yerelPara,
      senaryo, satici, depo, girisDepo, teslimEden, teslimAlan, tasiyici,
      aracPlaka, soforAd, soforTckn, sevkTarihi, teslimSekli, fisTipi, satirlar,
      subeId: kullanici?.subeId ?? undefined,
      alisMi, irsaliyeMi, faturaMi, depoBelgesi, stokFisiMi, fisCikisMi, transferMi,
      talepMi, disNumarali, basvuruMu,
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
      if (kapatilsin) kapat();
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

  // --------------------------------------------------------- fiyat listesi ----
  /**
   * Belge YONUNDEKI listeler + acilista gelecek liste. Cari ya da tur
   * degisince yeniden cozulur: alis belgesinde alis listeleri, satista satis.
   */
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        // YON SUZMESI SART: alis belgesinde satis listesi secilememeli -
        //   satis fiyatiyla mal girisi yapmak maliyeti bozar.
        const y = await api.liste('fiyat-listesi', {
          sayfa: 1, boyut: 200,
          filtre: { op: 'and', kosullar: [
            // 'durum' HAM KOD kolonudur (sayi) - metin 'Aktif' gondermek
            //   sunucuda tip hatasiyla 500 veriyordu, kutu hic dolmuyordu.
            { alan: 'durum',   op: 'esit', deger: 1 },
            { alan: 'yonKodu', op: 'esit', deger: alisMi ? 1 : 2 },
          ] },
        });
        if (iptal) return;
        setFiyatListeleri(y.satirlar.map(r => ({ id: Number(r.id), ad: String(r.ad ?? '') })));
      } catch { if (!iptal) setFiyatListeleri([]) }
    })();
    return () => { iptal = true };
  }, [alisMi]);

  // Acilista / cari degisince belgenin listesi cariden cozulur. KAYITLI
  //   belgede DOKUNULMAZ: belge hangi listeyle kesildiyse onu tasir.
  useEffect(() => {
    if (belgeId || !cari?.id) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.belgeVarsayilanListe(tur, cari.id, odeyenKurumId);
        if (!iptal) setFiyatListesiIdHam(y.listeId ?? null);
      } catch { /* liste kurulmamis olabilir - fiyatlar kart fiyatindan gelir */ }
    })();
    return () => { iptal = true };
  }, [belgeId, tur, cari?.id, odeyenKurumId]);

  /**
   * KAMPANYAYI COZ ve baslik alanlarina isle (274/291). Uc yerden cagrilir
   * (yeni belge acilisi, kayitli belgede pay modu, odeyen kurum degisimi);
   * uceye ayri ayri yazilinca "modu da set etmeyi unutma" hatasi kacinilmazdi.
   *
   * @param kampanyaYaz kampanya kimligini/listesini de yaz. KAYITLI belgede
   *   FALSE gecilir: belge hangi kampanyayla kesildiyse onu tasir, yalniz
   *   PAY MODU tazelenir (mod kampanyanin degil KURUMUN ozelligi, belgeye
   *   yazilmaz - kayitli basvuruda provizyon dugmesi de dogru davranmali).
   * @returns kampanyanin fiyat listesi (varsa) - cagiran satirlari o listeyle
   *   yeniden fiyatlayabilsin.
   */
  async function kampanyaCoz(
    kurumId: number | null, kampanyaYaz: boolean,
  ): Promise<number | null> {
    try {
      const y = await api.fiyatKampanya({
        tarafId: kampanyaYaz ? cari?.id ?? null : null, kurumId,
      });
      setPaylasimModu(y.paylasimModu ?? 1);
      if (!kampanyaYaz) return null;

      setKampanyaId(y.kampanyaId);
      setKampanyaAdi(y.kampanyaId ? `${y.kod ? y.kod + ' · ' : ''}${y.ad}` : '');
      // Kampanyanin kendi fiyat listesi varsa belgenin listesi ONA cekilir:
      //   baslik neyle fiyatlandigini dogru gostersin (kullanici degistirebilir).
      if (y.fiyatListesiId) { setFiyatListesiIdHam(y.fiyatListesiId); return y.fiyatListesiId }
      return null;
    } catch {
      if (kampanyaYaz) { setKampanyaId(null); setKampanyaAdi('') } else setPaylasimModu(1);
      return null;
    }
  }

  /**
   * KAMPANYA COZUMU (274). Odeyen kurum varsa kampanya ONUN sozlesmesinden
   * gelir - odemeyi yapan taraf fiyati belirler; yoksa carinin kendi
   * kampanyasi, o da yoksa genel kampanya.
   *
   * KAYITLI belgede kampanya DEGISMEZ; o durumda yalniz pay modu okunur.
   */
  useEffect(() => {
    const kampanyaYaz = !belgeId;
    if (kampanyaYaz && !cari?.id && !odeyenKurumId) {
      setKampanyaId(null); setKampanyaAdi(''); setPaylasimModu(1); return;
    }
    if (!kampanyaYaz && !odeyenKurumId) { setPaylasimModu(1); return }
    void kampanyaCoz(odeyenKurumId, kampanyaYaz);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [belgeId, cari?.id, odeyenKurumId]);

  /**
   * Liste DEGISTI: butun satirlar EKRANDA yeniden fiyatlanir (kullanici
   * kurali); Kaydet kalicilastirir. Kayitli belgede de ayni yol - sunucuda
   * fiyatlayan fn_belge_fiyatlandir KALDIRILDI: durum=0 butun normal
   * belgelerde "Kesin" oldugundan hepsini reddediyordu, ustelik yalniz
   * birim_fiyat yazip tutar/matrah/genel_toplami bayat birakiyordu (satir
   * matematigi banker's rounding ile BelgeHesap'ta - PG round'u farkli
   * yuvarlar, kurus paritesi DB'de tutturulamaz). Kaydetme hatti zaten tum
   * toplamlari satirlardan yeniden hesaplar.
   */
  /**
   * Butun satirlari verilen liste + gecerli kampanya ile yeniden fiyatlar.
   * Liste degisimi ve ODEYEN KURUM degisimi ayni yolu kullanir: kurum degisince
   * gecerli kampanya da degisir - satirlar eski kurumun fiyatinda kalirsa belge
   * "SGK anlasmasi" fiyatiyla Ozel Yasam'a kesilirdi.
   */
  async function satirlariYenidenFiyatla(
    listeId: number | null, kurumId: number | null, kaynakAdi: string,
  ) {
    if (!listeId) return;
    await guvenli(async () => {
      let degisen = 0, bulunamayan = 0;
      const yeniSatirlar = await Promise.all(satirlar.map(async r => {
        if (!r.stokId && !r.hizmetId) return r;
        const f = await api.fiyatKalem(
          r.stokId ? { stokId: r.stokId } : { hizmetId: r.hizmetId! },
          { tarafId: cari?.id ?? null, kurumId, listeId });
        const y = kampanyaFiyatiUygula(r, f);
        if (y === r) bulunamayan++; else degisen++;
        return y;
      }));
      setSatirlar(yeniSatirlar);
      mesaj(`${degisen} satırın fiyatı ${kaynakAdi} güncellendi.`
          + (bulunamayan ? ` ${bulunamayan} kalem listede bulunamadı, fiyatı DEĞİŞMEDİ.` : '')
          + (belgeId && degisen ? ' Kaydet ile kalıcı olur.' : ''));
    });
  }

  async function listeDegisti(yeni: number | null) {
    setFiyatListesiIdHam(yeni);
    await satirlariYenidenFiyatla(yeni, odeyenKurumId, 'listeden');
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

  /**
   * PROVIZYON UYGULA (289): kurumun karsilama oranini butun satirlara isler.
   * Tutarlar EKRANDA hesaplanir, Kaydet kalicilastirir - liste degisiminde
   * oldugu gibi. Oran 0 verilirse tamami hastaya yazilir (kendi oder).
   */
  async function provizyonUygula() {
    // KATILIM PAYI MODU (291, SGK): oran sorulmaz. Her satir KENDI katilim
    //   payiyla bolunur (fiyat listesinden kalemle birlikte gelir); kullanici
    //   tek tip bir tutar dayatmak isterse kutuya yazar.
    if (paylasimModu === 2) {
      const cevapKatki = await metinSor(
        'Katılım payı (TL) — boş bırakılırsa her satırın kendi katılım payı uygulanır',
        '', 'Katılım payı');
      if (cevapKatki === null) return;
      const elle = cevapKatki.trim() === '' ? null : Math.max(0, hamSayi(cevapKatki));

      // Yeni satirlar ONCE hesaplanir: toplami setSatirlar geri cagriminda
      //   biriktirmek mesaji "0.00" gosteriyordu (state guncellemesi ertelenir).
      const yeniler = satirlar.map(r => {
        const tutar = satirTutari(hamSayi(r.adet), hamSayi(r.birimFiyat), r.iskonto, r.iskonto2);
        const katki = Math.min(elle ?? hamSayi(r.katkiTutar ?? '0'), tutar);
        return { ...r, karsilama: '0', katkiTutar: String(katki),
                 kurumTutar: (tutar - katki).toFixed(2), hastaTutar: katki.toFixed(2) };
      });
      const toplamHasta = yeniler.reduce((t, r) => t + hamSayi(r.hastaTutar ?? '0'), 0);
      setSatirlar(yeniler);
      mesaj(`Katılım payı uygulandı: hastadan ${toplamHasta.toFixed(2)} TL, `
          + 'kalanı kuruma. Kaydet ile kalıcı olur.');
      return;
    }

    // Varsayilan olarak KURUMUN sozlesmedeki orani gelir - hekim/kayit
    //   gorevlisi provizyon farkliysa degistirir.
    const cevap = await metinSor(
      'Kurumun karşılama oranı (%) — 0 girilirse tamamı hastaya yazılır',
      String(satirlar.find(r => hamSayi(r.karsilama ?? '0') > 0)?.karsilama ?? ''),
      'Karşılama %');
    if (cevap === null || cevap.trim() === '') return;
    const oran = Math.min(100, Math.max(0, hamSayi(cevap)));

    setSatirlar(eski => eski.map(r => {
      const tutar = satirTutari(hamSayi(r.adet), hamSayi(r.birimFiyat), r.iskonto, r.iskonto2);
      const kurum = Math.round(tutar * oran) / 100;
      return { ...r, karsilama: String(oran),
               kurumTutar: kurum.toFixed(2), hastaTutar: (tutar - kurum).toFixed(2) };
    }));
    mesaj(`Karşılama oranı %${oran} uygulandı. Kaydet ile kalıcı olur.`);
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
  const kapat = () => (onKapat ? onKapat() : git(basvuruMu ? '/basvuru' : bilgi.liste));

  if (!ekleyebilir)
    return (
      <Modal baslik="Belge" onKapat={kapat} alt={<button className="d kapat-dugmesi" onClick={kapat}>Kapat</button>}>
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
      onKapat={kapat}
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
          <a href="#" onClick={e => { e.preventDefault(); kapat() }}> listede gör</a>
          {sonuc.uyarilar && sonuc.uyarilar.length > 0 && (
            <ul className="uyari-liste">{sonuc.uyarilar.map((u, i) => <li key={i}>{u}</li>)}</ul>
          )}
        </div>
      )}

        {/* SECILI HASTA SERIDI (298, mockup): basligin USTUNDE - kabul memuru
            dogru hastada oldugunu surekli gorsun. */}
        {basvuruMu && (
          <HastaSeridi tarafId={cari?.id}
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
          basvuruMu={basvuruMu} kurumlar={kurumlar}
          odeyenKurumId={odeyenKurumId}
          setOdeyenKurumId={v => void odeyenKurumDegisti(v)}
          bolumler={bolumler} bolumId={bolumId} setBolumId={setBolumId}
          gorevliler={gorevliler} personelId={personelId} setPersonelId={setPersonelId}
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
            // ODEME PAYLASIMI (289): yalniz odeyen kurumlu basvuruda.
            paylasim={{ acik: basvuruMu && !!odeyenKurumId,
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
          />
        )}
        {aktifSekme === 'tahsilat' && (
          <TahsilatSekmesi sonuc={sonuc} tahsilatlar={tahsilat.tahsilatlar}
                           kayitliId={kayitliId} alisMi={alisMi} tahsilatAc={tahsilatAc}
                           secili={tahsilat.seciliTahsilat}
                           setSecili={tahsilat.setSeciliTahsilat}
                           tahsilatAcKart={tahsilat.setTahsilatKayitId}
                           tahsilatSil={tahsilat.tahsilatSil} />
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
            protokolNo={String(sonuc?.belge.belgeNo ?? '')}
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

        {/* Kalem penceresi: grid salt gorunum oldugu icin ekleme/duzenleme burada.
            Alanlar ture gore degisir (irsaliyede seri/lot, faturada iskonto/KDV). */}
        {/* 0) Cari secimi - yeni belgenin ilk adimi. */}
        <TarafArama
          acik={cariArama}
          // BASVURUDA yalniz HASTALAR (kullanici): basvurunun tarafi hastadir,
          //   tedarikci/kurum bu pencerede cikmamali. Kaynak 'hasta' sunucuda
          //   grup = 101 ile suzuluyor; "＋ Yeni" de hasta karti acar.
          kaynaklar={basvuruMu ? ['hasta'] : ['cari']}
          yerTutucu={basvuruMu
            ? 'Hastayı isim/tel ile ara…' : 'Müşteri / tedarikçi ara…'}
          baslangicMetni={hastaAramaMetni}
          baslangicYeni={hastaAramaYeni}
          baslangicKartId={hastaKartId}
          onKapat={() => {
            setCariArama(false);
            setHastaAramaMetni('');
            setHastaAramaYeni(false);
            setHastaKartId(null);
          }}
          onSec={sec => {
            setCari({ id: sec.id, unvan: sec.unvan });
            setCariArama(false);
            setHastaAramaMetni('');
            setHastaAramaYeni(false);
            setHastaKartId(null);
          }}
        />

        {/* Tahsilat pencereleri (duzeltme · cek/senet · dogrudan kasa islemi)
            ayri dosyada: BelgeTahsilatModallari. */}
        <BelgeTahsilatModallari
          tahsilat={tahsilat} cari={cari} genelToplam={sonuc?.belge.genelToplam}
        />

        {/* 0b) Satis temsilcisi - ayni ekran, kaynak personel. */}
        <TarafArama
          acik={saticiArama}
          kaynaklar={['personel']}
          yerTutucu="Personel ara…"
          onKapat={() => setSaticiArama(false)}
          onSec={sec => {
            setSatici({ id: sec.id, ad: sec.unvan });
            setSaticiArama(false);
          }}
        />

        {/* 0c) Transferde teslim eden / teslim alan - ayni personel ekrani,
               hangi alanin doldurulacagi personelArama ile secilir. */}
        <TarafArama
          acik={personelArama !== null}
          kaynaklar={['personel']}
          yerTutucu="Personel ara…"
          onKapat={() => setPersonelArama(null)}
          onSec={sec => {
            const kayit = { id: sec.id, ad: sec.unvan };
            if (personelArama === 'eden') setTeslimEden(kayit); else setTeslimAlan(kayit);
            setPersonelArama(null);
          }}
        />

        {/* IADE (tipi 2): kalem stok aramadan degil, carinin ONCEKI faturalarindan
               secilir - fiyat/iskonto/KDV kaynaktan gelir ve ayni kalem iki kez
               iade edilemez (132). */}
        {iadeArama && cari && (
          <IadeSatirPenceresi
            tarafId={cari.id}
            tarafUnvan={cari.unvan}
            /* Iade IRSALIYESI irsaliyelerden, iade FATURASI faturalardan (133). */
            turler={irsaliyeMi ? (alisMi ? [10, 109] : [14, 119])
                               : (alisMi ? [11, 12] : [15, 16])}
            onKapat={() => setIadeArama(false)}
            onSec={secilenler => {
              const yeniler = iadeSatirlari(secilenler, sonAnahtar(satirlar));
              setSatirlar(s => [...s, ...yeniler]);
              setIadeArama(false);
            }}
          />
        )}

        {/* 1) Stok/hizmet arama - satir eklemenin BASLANGICI. Secim yapilinca
               kapanmaz; kalem penceresi ustune acilir, o kapaninca buraya donulur
               ve siradaki stok secilir (ardisik hizli giris). */}
        {stokArama && (
          <StokAramaPenceresi
            etkin={kalem === null}
            // Belgenin yonu (141): satista yalniz "Satılan", alista yalniz
            //   "Alınan" isaretli stoklar listelenir. Transfer/talep gibi
            //   yonsuz belgelerde suzme yok.
            yon={depoBelgesi || stokFisiMi ? undefined : alisMi ? 'alis' : 'satis'}
            onKapat={() => setStokArama(false)}
            onSec={sec => void (async () => {
              // Secim "Son / Sik Aranan" sayacina islensin - listede oldugu gibi.
              void api.aramaIsaretle(
                sec.tip === 'hizmet' ? 'hizmet' : 'stok', Number(sec.id));
              let yeni = stokSecimindenKalem(sec, sonAnahtar(satirlar) + 1, yerelPara);
              // FIYAT LISTESI ONCELIKLI (205/207): belgenin listesi varsa fiyat
              //   ORADAN gelir; kartin kendi fiyati yalniz listede kalem yoksa
              //   kalir. Fiyat kalem penceresi ACILMADAN once beklenir - pencere
              //   `satir` prop'unu acilista kopyalar (useState), sonradan
              //   gonderilen guncelleme pencereye ulasmaz.
              if (fiyatListesiId || kampanyaId) {
                try {
                  // Fiyat LISTE + KAMPANYA (274): baz listeden, indirim
                  //   kampanyadan. Kampanya yoksa uc liste fiyatini doner.
                  const f = await api.fiyatKalem(
                    sec.tip === 'hizmet' ? { hizmetId: Number(sec.id) } : { stokId: Number(sec.id) },
                    { tarafId: cari?.id ?? null, kurumId: odeyenKurumId,
                      listeId: fiyatListesiId });
                  yeni = kampanyaFiyatiUygula(yeni, f);
                } catch { /* liste fiyati alinamazsa kart fiyati kalir */ }
              }
              setKalem(yeni);
            })()}
          />
        )}

        {/* 2) Adet / birim fiyat - Enter satiri gride ekler ve buraya doner. */}
        {kalem !== null && (
          <KalemPenceresi
            satir={kalem}
            transferMi={bilgi.kalem === 'miktar'}
            siparisMi={siparisMi}
            paylasimli={basvuruMu && !!odeyenKurumId}
            anaBirimKod={kalem?.birim ?? 0}
            anaBirimAdi={kalem?.birimAdi ?? ''}
            vergisiz={bilgi.kalem === 'sade' && stokFisiMi}
            yerelPara={yerelPara}
            girisIzlemi={bilgi.girisIzlemi}
            cikisIzlemi={bilgi.cikisIzlemi}
            cikisDepoId={depo?.id ?? null}
            belgeTarihi={tarih}
            onKapat={() => setKalem(null)}
            onKaydet={r => { kalemKaydet(r); setKalem(null) }}
          />
        )}

        {/* Donusum modali bu kartin USTUNDE acilir: hedef turu ve satir miktarlari
            orada secilir, kalan bu belgede kalir (F8). */}
        {/* Termin modali (140): satirlarin teslim tarihini toplu gunceller.
            Sunucu belgeyi yeniden yazmaz - yalniz tarih kolonu degisir. */}
        {terminAcik && kayitliId > 0 && (
          <TerminModali
            belgeId={kayitliId}
            satirlar={satirlar}
            onKapat={() => setTerminAcik(false)}
            onTamam={y => {
              setSonuc(y);
              // Gridin termin kolonu tazelensin: satirlar sunucudan geldi.
              setSatirlar(s => s.map(x => {
                const yeni = (y.satirlar ?? []).find(r => Number(r.id) === x.satirId);
                return yeni
                  ? { ...x, teslimTarihi: String(yeni.teslimTarihi ?? '').slice(0, 10) }
                  : x;
              }));
              onKaydedildi?.();
            }}
          />
        )}

        {donusum !== null && kayitliId > 0 && (
          <BelgeDonusumModali
            belgeId={kayitliId}
            belgeTur={tur}
            varsayilanHedef={donusum}
            onKapat={() => setDonusum(null)}
            onTamam={() => onKaydedildi?.()}
          />
        )}
      </>
    </Modal>
  );
}
