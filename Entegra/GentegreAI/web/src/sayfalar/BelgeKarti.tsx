import { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { ApiHatasi, type BelgeYaniti, type KasaIslemTuru, type ListeSatiri } from '../api/sozlesme';
import { Modal } from '../bilesenler/Modal';
import { StokAramaPenceresi } from '../bilesenler/StokAramaPenceresi';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { TarafArama } from '../bilesenler/TarafArama';
import { belgeTuruBilgisi, GIRILEBILIR_TURLER, VARSAYILAN_TUR } from './belgeTuru';
import { DokumanGalerisi } from '../bilesenler/DokumanGalerisi';
import { KasaIslemKarti } from './KasaIslemKarti';
import { useOturum } from '../kimlik/OturumBaglami';
import { para } from '../bilesenler/bicim';
import { type SatirDurumu, bosSatir, satirTutari } from './belgeSatir';
import { belgeDogrula, belgeGovdesi, doluSatirlar, type BelgeGirdisi } from './belgeKaydet';
import {
  YEREL_PARA_VARSAYILAN, GERIYE_GUN_VARSAYILAN, yerelAnMetni, KAPANMA_ETIKET,
} from './belgeSabitleri';
import { KalemPenceresi } from '../bilesenler/belge/KalemPenceresi';
import { TerminModali } from '../bilesenler/belge/TerminModali';
import {
  TasiyiciSekmesi, EBelgeSekmesi, FaturalamaSekmesi,
} from '../bilesenler/belge/BelgeSekmeleri';
import { KalemSekmesi, TahsilatSekmesi } from '../bilesenler/belge/KalemSekmesi';
import { IadeSatirPenceresi } from '../bilesenler/belge/IadeSatirPenceresi';
import { BelgeAracCubugu } from '../bilesenler/belge/BelgeAracCubugu';
import { BelgeBaslik } from '../bilesenler/belge/BelgeBaslik';

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
  const [satici, setSatici] = useState<{ id: number; ad: string } | null>(null);
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

  /** Bu belgeye baglanmis kasa islemleri (Tahsilat sekmesi). */
  const [tahsilatlar, setTahsilatlar] = useState<ListeSatiri[]>([]);
  /** Acik tahsilat modalinin TURU (null = kapali) - fatura arkada acik kalir. */
  const [tahsilatAcik, setTahsilatAcik] = useState<number | null>(null);
  /** Tahsilat kaydedilince listeyi tazelemek icin sayac. */
  const [tahsilatYenile, setTahsilatYenile] = useState(0);
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
  /** Mevcut belge SALT GORUNUM: duzenleme ucu (PUT /api/belge/{id}) henuz yok. */
  const mevcutBelge = !!belgeId;
  /**
   * DUZENLEME (135): kayitli belge, e-Belge GONDERILMEMIS ve faturalanmamissa
   * degistirilebilir (kullanici). Sunucu ayni kurallari + sure sinirini
   * (belge.duzenleme_gun) yeniden dogrular - burasi yalniz ekrani acar.
   */
  const eBelgeGonderildi = Number(sonuc?.belge.efaturaDurum ?? 0) > 0;
  const faturalandi = Number(sonuc?.belge.kapanmaDurum ?? 0) > 0;
  const duzenlenebilir = mevcutBelge && !!sonuc && !eBelgeGonderildi && !faturalandi;
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
  const kayitliId = belgeId ?? (sonuc ? Number(sonuc.belge.id) : 0);

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
  const tahsilatAc = async (tahsilatTuru = 21) => {
    if (kayitliId) { setTahsilatAcik(tahsilatTuru); return }

    // Belge kaydedilecegi icin KALEM sart. Kaydetmeye birakirsak kullanici
    //   "En az bir satırda stok ya da hizmet seçilmeli." gibi tahsilatla
    //   ilgisiz gorunen bir hata aliyordu - sebebini burada soyluyoruz.
    if (satirlar.filter(s => s.stokId || s.hizmetId).length === 0) {
      setHata('Tahsilat belgeye bağlanır: önce en az bir kalem ekleyin, '
            + 'belge kaydedilip tahsilat açılsın.');
      return;
    }
    const id = await kes(false);
    if (id) setTahsilatAcik(tahsilatTuru);
  };

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
        setSatirlar((y.satirlar ?? []).map((r, i) => ({
          anahtar: i + 1,
          // Sunucudaki satir kimligi: termin guncelleme gibi satir bazli
          //   islemler bunu kullanir (140).
          satirId: r.id ? Number(r.id) : undefined,
          satirTur: Number(r.tur ?? 1),
          stokId: r.stokId ? Number(r.stokId) : null,
          hizmetId: r.hizmetId ? Number(r.hizmetId) : null,
          stokKodu: String(r.stokKodu ?? ''),
          // "??" DEGIL "||": sunucu bos alani '' donduruyor ve nullish operatoru
          //   bos string'i gecerli sayip yedege dusmuyordu - hizmet satirinda
          //   kod/ad bos gorunuyordu (kullanici).
          stokAdi: String(r.stokAdi || r.hizmetAdi || r.masrafAdi || r.aciklama || ''),
          aciklama: String(r.aciklama ?? ''),
          izlemeKodu: String(r.izlemeKodu ?? ''),
          // Termin (140): sunucu tam tarih doner, ekran gun bekliyor.
          teslimTarihi: String(r.teslimTarihi ?? '').slice(0, 10),
          adet: String(r.miktar ?? r.adet ?? 0),
          birimFiyat: String(r.birimFiyat ?? 0),
          // SATIR BAZLI DOVIZ (kullanici): kalem kendi para biriminde girilmis
          //   olabilir - kayitli satirdan geri yuklenir, yoksa yerel sayilir.
          fiyatDovizi: String(r.dovizCinsi ?? '') || yerelPara,
          dovizFiyat: String(r.dovizBirimFiyat ?? r.birimFiyat ?? 0),
          kur: String(r.dovizKuru ?? 1),
          iskonto: String(r.iskonto ?? 0),
          iskonto2: String(r.iskonto2 ?? 0),
          kdv: String(r.kdv ?? 0),
          // Kayitli kalemin lot dagilimi (db/114) - kalem yeniden acilinca
          //   kullanici hangi lottan kac adet girdigini gormeli.
          izleme: Number(r.izleme ?? 0),
          izlemler: ((r.izlemler ?? []) as Record<string, unknown>[]).map(z => ({
            lotNo: String(z.lotNo ?? ''),
            seriNo: String(z.seriNo ?? ''),
            uretimTarihi: String(z.uretimTarihi ?? '').slice(0, 10),
            sonKullanmaTarihi: String(z.sonKullanmaTarihi ?? '').slice(0, 10),
            durum: Number(z.durum ?? 0),
            miktar: String(z.miktar ?? 0),
          })),
        })));
      } catch (h) {
        setHata(h instanceof ApiHatasi ? h.message : String(h));
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

  // Tahsilat sekmesi: bu belgeye bagli kasa islemleri (kasa_islem.belge_id).
  //   Iptal edilenler (durum 3) haric - odenmis gibi gorunmesinler.
  useEffect(() => {
    if (!kayitliId || aktifSekme !== 'tahsilat') return;
    void (async () => {
      try {
        const y = await api.liste('kasa-islem', {
          sayfa: 1, boyut: 50,
          // Iptal edilen islem (durum 3) ve onun TERS kaydi listeye girmez -
          //   ikisi de iptalIslemId tasir, toplami sisirmesinler.
          filtre: { op: 'and', kosullar: [
            { alan: 'belgeId', op: 'esit', deger: kayitliId },
            { alan: 'durum', op: 'esitDegil', deger: 3 },
            // Kolon NULL olabiliyor - '= 0' eslesmiyordu, 'bos' dogru kosul.
            { alan: 'iptalIslemId', op: 'bos' },
          ] },
        });
        setTahsilatlar(y.satirlar);
      } catch { setTahsilatlar([]) }
    })();
  }, [kayitliId, aktifSekme, tahsilatYenile]);

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
      const adet = Number(s.adet.replace(',', '.')) || 0;
      const fiyat = Number(s.birimFiyat.replace(',', '.')) || 0;
      // Stok fisi vergisizdir (asagida satir da 0 ile gonderilir).
      const oran = stokFisiMi ? 0 : Number(s.kdv.replace(',', '.')) || 0;
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
      const k = Number(String(satir.kur).replace(',', '.')) || 0;
      if (k > 0) setBelgeKuru(String(k));
    }

    if (!satir.paket || !satir.stokId) return;
    const adet = Number(satir.adet.replace(',', '.')) || 1;
    void api.paketIcerigi(satir.stokId, bilgi.alis)
      .then(icerik => {
        if (icerik.length === 0) return;
        setSatirlar(s => {
          // Ayni paketin ONCEKI icerik satirlari temizlenir (miktar degisince
          //   yeniden uretilir), sonra guncel icerik eklenir.
          const temiz = s.filter(x => x.paketAnahtar !== satir.anahtar);
          let anahtar = Math.max(0, ...temiz.map(x => x.anahtar));
          const yeniler = icerik.map(i => ({
            ...bosSatir(++anahtar),
            satirTur: 1,
            stokId: i.stokId,
            stokKodu: i.kod,
            stokAdi: i.ad,
            adet: String(i.adet * adet),
            kdv: String(i.kdv ?? 0),
            izleme: i.izleme ?? 0,
            // FIYAT: pakette girilmisse o, girilmemisse stogun kendi kart
            //   fiyati (sunucu karar verir - belge yonune gore alis/satis).
            birimFiyat: String(i.fiyat ?? 0),
            dovizFiyat: String(i.fiyat ?? 0),
            aciklama: `${satir.stokKodu} paketi içeriği`,
            paketAnahtar: satir.anahtar,
          }));
          // Icerik, paket satirinin HEMEN ALTINA girer.
          const yer = temiz.findIndex(x => x.anahtar === satir.anahtar);
          return yer < 0
            ? [...temiz, ...yeniler]
            : [...temiz.slice(0, yer + 1), ...yeniler, ...temiz.slice(yer + 1)];
        });
      })
      .catch(h => setHata(h instanceof ApiHatasi ? h.message : String(h)));
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
      raporDovizi, ekstreDovizi, belgeKuru, yerelPara,
      senaryo, satici, depo, girisDepo, teslimEden, teslimAlan, tasiyici,
      aracPlaka, soforAd, soforTckn, sevkTarihi, teslimSekli, fisTipi, satirlar,
      subeId: kullanici?.subeId ?? undefined,
      alisMi, irsaliyeMi, faturaMi, depoBelgesi, stokFisiMi, fisCikisMi, transferMi,
      talepMi, disNumarali,
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
      const yanit = duzenlenebilir && belgeId
        ? await api.belgeGuncelle(belgeId, govde)
        : await api.belgeEkle(govde);
      setSonuc(yanit);
      onKaydedildi?.();
      // GENEL KURAL (kullanici): Kaydet'e basilinca form KAPANIR. Belgeye sonradan
      //   yapilacak isler (e-Belge gonderimi, donusum) listeden belge yeniden
      //   acilarak surdurulur - kart acik birakmak "kaydettim mi?" belirsizligi
      //   yaratiyordu. Tek istisna "kaydet ve devam et" (kapatilsin=false).
      if (kapatilsin) kapat();
      return Number(yanit.belge.id ?? 0);
    } catch (h) {
      if (h instanceof ApiHatasi) {
        if (h.dogrulamaMi && h.hata.alanlar)
          setAlanHatalari(Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])));
        setHata(`${h.hata.kod}: ${h.message}`);
      } else setHata(String(h));
    } finally {
      setKaydediyor(false);
    }
    return 0;
  }

  function yeniBelge() {
    setSonuc(null);
    setCari(null);
    setSatirlar([]);
    setHata(null);
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

  const kapat = () => (onKapat ? onKapat() : git(bilgi.liste));

  if (!ekleyebilir)
    return (
      <Modal baslik="Belge" onKapat={kapat} alt={<button className="d kapat-dugmesi" onClick={kapat}>Kapat</button>}>
        <div className="hata-kutusu">Belge ekleme yetkiniz yok.</div>
      </Modal>
    );

  return (
    <Modal
      baslik={mevcutBelge
        ? `${seciliTurAdi}${sonuc?.belge.belgeNo ? ` — ${sonuc.belge.belgeNo}` : ''}`
        : seciliTurAdi}
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
          eBelgeYok={eBelgeYok} kayitliId={kayitliId}
          kes={kes} yeniBelge={yeniBelge} kapat={kapat}
          setDonusum={setDonusum} setTerminAcik={setTerminAcik}
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
          />
        )}
        {aktifSekme === 'tahsilat' && (
          <TahsilatSekmesi sonuc={sonuc} tahsilatlar={tahsilatlar}
                           kayitliId={kayitliId} alisMi={alisMi} tahsilatAc={tahsilatAc} />
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
          kaynaklar={['cari']}
          yerTutucu="Müşteri / tedarikçi ara…"
          onKapat={() => setCariArama(false)}
          onSec={sec => {
            setCari({ id: sec.id, unvan: sec.unvan });
            setCariArama(false);
          }}
        />

        {/* Tahsilat karti MODAL: cari, tutar ve belge bagi onyuklu gelir. */}
        {tahsilatAcik !== null && (
          <KasaIslemKarti
            acilis={{
              tur: tahsilatAcik,
              tarafId: cari?.id,
              tarafUnvan: cari?.unvan,
              belgeId: kayitliId,
              tutar: String(sonuc?.belge.genelToplam ?? ''),
            }}
            onKapat={() => { setTahsilatAcik(null); setTahsilatYenile(t => t + 1) }}
          />
        )}

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
              let anahtar = Math.max(0, ...satirlar.map(x => x.anahtar));
              const yeniler = secilenler.map(r => {
                anahtar += 1;
                return {
                  ...bosSatir(anahtar),
                  satirTur: r.hizmetId ? 2 : 1,
                  stokId: r.stokId ?? null,
                  hizmetId: r.hizmetId ?? null,
                  stokKodu: String(r.stokKodu ?? ''),
                  stokAdi: String(r.stokAdi ?? r.aciklama ?? ''),
                  adet: String(r.secilenMiktar ?? r.kalanMiktar),
                  birimFiyat: String(r.birimFiyat),
                  dovizFiyat: String(r.birimFiyat),
                  iskonto: String(r.iskonto ?? 0),
                  kdv: String(r.kdv ?? 0),
                  izleme: Number(r.izleme ?? 0),
                  izlemeKodu: String(r.izlemeKodu ?? ''),
                  // Kaynak satir bagi: iade edilen miktar bu bagdan hesaplanir.
                  kaynakSatirId: r.satirId,
                  aciklama: `İade — ${r.belgeNo}`,
                };
              });
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
            onSec={sec => {
              const hizmet = sec.tip === 'hizmet';
              // Secim "Son / Sik Aranan" sayacina islensin - listede oldugu gibi.
              void api.aramaIsaretle(hizmet ? 'hizmet' : 'stok', Number(sec.id));
              setKalem({
                ...bosSatir(Math.max(0, ...satirlar.map(x => x.anahtar)) + 1),
                satirTur: hizmet ? 2 : 1,
                stokId: hizmet ? null : Number(sec.id),
                hizmetId: hizmet ? Number(sec.id) : null,
                stokKodu: String(sec.kod ?? ''),
                stokAdi: String(sec.ad ?? ''),
                // Stok LOT/SERI izlemli mi - kalem penceresi buna gore izlem
                //   ekranini acar (db/114).
                izleme: hizmet ? 0 : Number(sec.izleme ?? 0),
                // Paket (124): kalem kaydedilince icerigi de belgeye eklenir.
                paket: !hizmet && Number(sec.paket ?? 0) === 1,
                kdv: sec.kdv !== undefined && sec.kdv !== null ? String(sec.kdv) : '20',
                // Kart fiyati onyuklenir - kullanici zaten listede gorup seciyor;
                //   pencerede degistirebilir. Fiyatin PARA BIRIMI de gelir: yerel
                //   degilse kalem penceresi kur + yerel karsilik satirini acar.
                fiyatDovizi: String(sec.fiyatDovizi ?? yerelPara) || yerelPara,
                dovizFiyat: sec.fiyat ? String(sec.fiyat) : '',
                birimFiyat: sec.fiyat ? String(sec.fiyat) : '',
              });
            }}
          />
        )}

        {/* 2) Adet / birim fiyat - Enter satiri gride ekler ve buraya doner. */}
        {kalem !== null && (
          <KalemPenceresi
            satir={kalem}
            transferMi={bilgi.kalem === 'miktar'}
            siparisMi={siparisMi}
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
