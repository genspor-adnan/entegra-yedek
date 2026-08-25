import { Fragment, useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { ApiHatasi, type BelgeYaniti, type KasaIslemTuru, type ListeSatiri } from '../api/sozlesme';
import { GenLookup } from '../bilesenler/GenLookup';
import { Modal } from '../bilesenler/Modal';
import { StokAramaPenceresi } from '../bilesenler/StokAramaPenceresi';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { TarafArama, TarafSecici } from '../bilesenler/TarafArama';
import { belgeTuruBilgisi, GIRILEBILIR_TURLER, VARSAYILAN_TUR } from './belgeTuru';
import { DokumanGalerisi } from '../bilesenler/DokumanGalerisi';
import { KasaIslemKarti } from './KasaIslemKarti';
import { useOturum } from '../kimlik/OturumBaglami';
import { para } from '../bilesenler/bicim';
import { type SatirDurumu, bosSatir, tarihSaat, iskonatoMetni, satirTutari } from './belgeSatir';
import { KalemPenceresi } from '../bilesenler/belge/KalemPenceresi';


/**
 * Yerel para birimi. SIMDILIK sabit - opsiyona (kurulus ayari) baglanacak;
 * mali_hareket/muhasebe tarafinda da ayni kavram "yerel tutar" olarak geciyor.
 */
/**
 * Yerel (defter) para birimi VARSAYILANI. Gercek deger Genel Ayarlar'dan gelir
 * (`genel.yerel_para`, db/106) - ayar yuklenene kadar bu kullanilir. Kalem
 * penceresi "bu fiyat doviz mi" kararini buna gore verir.
 */
const YEREL_PARA_VARSAYILAN = 'TL';

/**
 * Belge tarihi penceresi (GENEL KURAL, tum belge turleri): ileri tarih YOK,
 * N gunden eski YOK. N = Yönetim › Ayarlar › Genel'deki "geriye dönük gün"
 * (db/102, varsayilan 7; 0 = sinir yok). Ayar yuklenene kadar bu varsayilan
 * kullanilir. Sunucu da ayni kurali uygular (BelgeDeposu.BelgeTarihiKontrolAsync) -
 * buradaki sinirlar yalniz kullaniciyi erken uyarmak icindir.
 */
const GERIYE_GUN_VARSAYILAN = 7;

/** datetime-local kutusunun bekledigi YEREL "YYYY-MM-DDTHH:mm" (UTC'ye kaymaz). */
const yerelAnMetni = (d: Date) => {
  const p = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`
       + `T${p(d.getHours())}:${p(d.getMinutes())}`;
};

/** Senaryo comboSU - SENARYO_ADI ile ayni kodlar, GIB profil sirasinda. */
const SENARYO_SECENEK = [
  { deger: 1, ad: 'Temel Fatura' },
  { deger: 2, ad: 'Ticari Fatura' },
  { deger: 3, ad: 'İhracat' },
  { deger: 7, ad: 'Kamu' },
  { deger: 8, ad: 'İlaç / Tıbbi Cihaz' },
];

/** Baslikta gosterilen e-Belge tipi: irsaliye / ihracat / normal fatura. */
function eBelgeTipi(tur: number, senaryo: number): string {
  if (tur === 10 || tur === 14) return 'e-İrsaliye';
  if (senaryo === 3) return 'e-Fatura (İhracat)';
  return 'e-Fatura (Mükellef)';
}






const LOOKUP_DEPO = [{ ad: 'ad', baslik: 'Depo', genis: true }];

/** Teslim sekli (088 kod listesi belge.teslim_sekli) - e-Irsaliye'de GIB bekler. */
const TESLIM_SEKLI: { deger: number; ad: string }[] = [
  { deger: 0, ad: 'Belirtilmemiş' },
  { deger: 1, ad: 'Alıcı adresine teslim' },
  { deger: 2, ad: 'Alıcı kendi aracıyla' },
  { deger: 3, ad: 'Kargo / nakliye firması' },
  { deger: 4, ad: 'Depoda teslim' },
  { deger: 5, ad: 'Yurt dışı sevk' },
];

/**
 * Stok fisi TIPLERI (db/101 kod_deger ile birebir). Fisin SEBEBI: muhasebe
 * hesabi buna gore secilecek (F7) - "Diğer" disindakiler ayri gider/gelir
 * hesabina gider.
 */
const GIRIS_FIS_TIPLERI = [
  { deger: 1, ad: 'Fire' },
  { deger: 2, ad: 'Sayım Fazlası' },
  { deger: 9, ad: 'Diğer' },
] as const;

const CIKIS_FIS_TIPLERI = [
  { deger: 1, ad: 'Sarf' },
  { deger: 2, ad: 'İmha (Bozuk / SKT Geçmiş)' },
  { deger: 3, ad: 'Kayıp' },
  { deger: 4, ad: 'Fire' },
  { deger: 5, ad: 'Sayım Eksiği' },
  { deger: 9, ad: 'Diğer' },
] as const;

const KAPANMA_ETIKET: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Faturalanmadı', sinif: 'uyari' },
  1: { ad: 'Kısmi faturalandı', sinif: '' },
  2: { ad: 'Faturalandı', sinif: 'olumlu' },
};

/** Kart sekmeleri (mockup satis_irsaliye_karti.html / satis_faturasi.html .tabs).
    `irsaliye:true` yalniz irsaliyede, `faturaYok:true` faturada GIZLENIR,
    `faturaMi:true` yalniz faturada gorunur. */
const SEKMELER: {
  anahtar: string; baslik: string;
  irsaliye?: boolean; faturaYok?: boolean; faturaMi?: boolean;
}[] = [
  { anahtar: 'kalem',    baslik: 'Kalemler' },
  { anahtar: 'tasiyici', baslik: 'Taşıyıcı / Sevkiyat', irsaliye: true },
  { anahtar: 'ebelge',   baslik: 'e-Belge' },
  // Faturada "Faturalama" (bu belgeden turetilenler) anlamsiz - fatura zincirin
  //   SONU. Mockup'ta (satis_faturasi.html) onun yerinde TAHSILAT var.
  { anahtar: 'fatura',   baslik: 'Faturalama', faturaYok: true },
  { anahtar: 'tahsilat', baslik: 'Tahsilat',   faturaMi: true },   // alista "Ödeme" olur
  { anahtar: 'imza',     baslik: 'İmza / Teslim', irsaliye: true },
  { anahtar: 'yorum',    baslik: 'Yorum / Medya' },
];

/**
 * TarafArama ile doldurulan baslik alani (cari, satis temsilcisi...).
 *
 * GenLookup DEGIL: secim her yerde AYNI arama ekranindan yapilsin diye alan
 * kendisi salt okunur, tiklayinca (ya da "…" dugmesiyle) modali cagirir.
 */
function TarafAlani({ etiket, deger, kilitli, ipucu, zorunlu, hata, onAc }: {
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
  const [taslak, setTaslak] = useState(false);
  // Yeni belge BOS grid ile acilir: "(stok seçilmedi)" yazan sahte satir
  //   kullaniciyi "burasi nasil doldurulur" diye ariyordu; satir "＋" ile eklenir.
  const [satirlar, setSatirlar] = useState<SatirDurumu[]>([]);

  const [kaydediyor, setKaydediyor] = useState(false);
  const [aciliyor, setAciliyor] = useState(!!belgeId);
  const [donusum, setDonusum] = useState(false);
  const [aktifSekme, setAktifSekme] = useState('kalem');
  /** Grid satir secimi (kirmizi Sil dugmesi bunlari siler). */
  const [seciliSatirlar, setSeciliSatirlar] = useState<Set<number>>(new Set());
  /** Lot detayi KAPATILMIS kalemler. Lotlu kalem varsayilan ACIK gelir -
      kullanici bakmak icin ayrica tiklamasin; isteyen oku ile kapatir. */
  const [kapaliLotlar, setKapaliLotlar] = useState<Set<number>>(new Set());
  /** Shift ile ARALIK secimi icin son tiklanan satirin sirasi. */
  const sonTiklanan = useRef<number | null>(null);
  /** Acik kalem penceresi (adet / fiyat). Stok zaten secilmis olarak gelir. */
  const [kalem, setKalem] = useState<SatirDurumu | null>(null);
  /** Ardisik giris: stok arama penceresi acik mi. Kalem eklendikten sonra
      KAPANMAZ - kullanici arka arkaya satir girer, isi bitince Kapat der. */
  const [stokArama, setStokArama] = useState(false);
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
  const kilitli = mevcutBelge || !!sonuc;
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
  const tahsilatAc = (tahsilatTuru = 21) => {
    if (kayitliId) setTahsilatAcik(tahsilatTuru);
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
        setTeslimAlan(y.belge.teslimAlanId
          ? { id: Number(y.belge.teslimAlanId), ad: String(y.belge.teslimAlanAdi ?? '') } : null);
        setSatirlar((y.satirlar ?? []).map((r, i) => ({
          anahtar: i + 1,
          satirTur: Number(r.tur ?? 1),
          stokId: r.stokId ? Number(r.stokId) : null,
          hizmetId: r.hizmetId ? Number(r.hizmetId) : null,
          stokKodu: String(r.stokKodu ?? ''),
          stokAdi: String(r.stokAdi ?? r.hizmetAdi ?? r.aciklama ?? ''),
          aciklama: String(r.aciklama ?? ''),
          izlemeKodu: String(r.izlemeKodu ?? ''),
          adet: String(r.miktar ?? r.adet ?? 0),
          birimFiyat: String(r.birimFiyat ?? 0),
          // Kayitli satir belgenin dovizinde saklanir; satir bazinda doviz/kur
          //   tutulmuyor - kalem yeniden acilirsa yerel giris olarak gelir.
          fiyatDovizi: yerelPara,
          dovizFiyat: String(r.birimFiyat ?? 0),
          kur: '1',
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

  async function kes() {
    setHata(null);
    setAlanHatalari({});
    setSonuc(null);

    // Transferde cari YOK (sunucu da katalogtan ayni karari veriyor).
    if (!cari && !depoBelgesi && !stokFisiMi) {
      setAlanHatalari({ tarafId: 'Cari seçilmeli.' }); return;
    }
    if (stokFisiMi) {
      if (!fisTipi) { setAlanHatalari({ tipi: 'Fiş tipi seçilmeli.' }); return }
      if (!depo) {
        setAlanHatalari({ [fisCikisMi ? 'cikisDepoId' : 'girisDepoId']: 'Depo seçilmeli.' }); return;
      }
    }
    // Tarih penceresi (tum belge turleri): ileri tarih ve 7 gunden eski yasak.
    if (tarih > tarihEnGec) {
      setAlanHatalari({ belgeTarihi: 'Belge ileri tarihli olamaz.' }); return;
    }
    if (tarihEnErken && tarih < tarihEnErken) {
      setAlanHatalari({ belgeTarihi: `Belge tarihi ${geriGun} günden eski olamaz.` }); return;
    }
    if (talepMi) {
      if (!depo) { setAlanHatalari({ cikisDepoId: 'İstenen depo seçilmeli.' }); return }
      if (!teslimAlan) { setAlanHatalari({ teslimAlanId: 'Talep eden seçilmeli.' }); return }
      if (girisDepo && girisDepo.id === depo.id) {
        setAlanHatalari({ girisDepoId: 'Teslim deposu istenen depo ile aynı olamaz.' }); return;
      }
    }
    if (transferMi) {
      if (!depo || !girisDepo) {
        setAlanHatalari({ [!depo ? 'cikisDepoId' : 'girisDepoId']: 'Depo seçilmeli.' }); return;
      }
      if (depo.id === girisDepo.id) {
        setAlanHatalari({ girisDepoId: 'Çıkış ve giriş deposu aynı olamaz.' }); return;
      }
      // Sorumluluk devri: mali kim verdi, kim aldi (sunucu da ayni kontrolu yapar).
      if (!teslimEden || !teslimAlan) {
        setAlanHatalari(!teslimEden
          ? { teslimEdenId: 'Teslim eden seçilmeli.' }
          : { teslimAlanId: 'Teslim alan seçilmeli.' }); return;
      }
      if (teslimEden.id === teslimAlan.id) {
        setAlanHatalari({ teslimAlanId: 'Teslim eden ve teslim alan aynı kişi olamaz.' }); return;
      }
    }
    if (disNumarali && belgeNo.trim() === '') {
      setAlanHatalari({ belgeNo: 'Tedarikçinin fatura numarası girilmeli.' }); return;
    }
    const dolu = satirlar.filter(s => s.stokId || s.hizmetId);
    if (dolu.length === 0) { setHata('En az bir satırda stok ya da hizmet seçilmeli.'); return }

    setKaydediyor(true);
    try {
      const govde = {
        belge: {
          tur,
          tarafId: cari?.id ?? 0,
          belgeTarihi: tarih,
          // Seri e-Belge kavrami: transferde YOK - yoksa numara "T20|SWEB" gibi
          //   ayri bir sayactan gelir ve eski transferlerle ayni seride olmaz.
          belgeSeri: depoBelgesi || stokFisiMi ? '' : seri,
          // Alis faturasinda numara tedarikciden gelir; digerlerinde sunucu verir.
          belgeNo: disNumarali ? belgeNo.trim() : undefined,
          belgeDovizi: 'TL',
          dovizKuru: 1,
          vadeGun: Number(vadeGun) || 0,
          subeId: kullanici?.subeId ?? undefined,
          // Depo ALANI ture gore: alista giris, satista cikis (stok yonu buradan).
          //   TRANSFERDE IKISI DE dolu - tek satir iki depoyu oynatir.
          // Stok fisinde depo yonu TURDEN gelir: giris fisi girise, cikis fisi
          //   cikisa yazar (cari yok, tek depo alani var).
          cikisDepoId: stokFisiMi ? (fisCikisMi ? depo?.id ?? null : null)
                     : depoBelgesi ? depo?.id ?? null
                     : alisMi ? null : depo?.id ?? null,
          girisDepoId: stokFisiMi ? (fisCikisMi ? null : depo?.id ?? null)
                     : depoBelgesi ? girisDepo?.id ?? null
                     : alisMi ? depo?.id ?? null : null,
          tipi: stokFisiMi ? fisTipi : undefined,
          // satici_id NOT NULL default 0 - "secilmedi" burada null degil 0
          //   (null gonderince sunucu "saticiId bos birakilamaz" ile reddediyordu).
          saticiId: satici?.id ?? 0,
          senaryo,
          // Teslim sekli e-Irsaliye'de GIB'in bekledigi alan.
          teslimSekli: irsaliyeMi ? teslimSekli : undefined,
          aracPlaka: irsaliyeMi ? aracPlaka : undefined,
          soforAd: irsaliyeMi ? soforAd : undefined,
          // Tasiyici / Sevkiyat sekmesindeki ek UBL alanlari
          irsaliyeTarihi: irsaliyeMi && sevkTarihi ? sevkTarihi : undefined,
          soforTckn: irsaliyeMi ? soforTckn : undefined,
          tasiyiciId: irsaliyeMi ? tasiyici?.id ?? null : undefined,
          // Teslim eden irsaliyede opsiyonel, TRANSFERDE zorunlu; teslim alan
          //   yalniz transferde var (sorumluluk devri).
          teslimEdenId: irsaliyeMi || transferMi ? teslimEden?.id ?? null : undefined,
          teslimAlanId: depoBelgesi ? teslimAlan?.id ?? null : undefined,

        },
        satirlar: dolu.map((s, i) => ({
          sira: i + 1,
          tur: s.satirTur,
          stokId: s.stokId,
          hizmetId: s.hizmetId,
          adet: Number(s.adet.replace(',', '.')) || 0,
          miktar: Number(s.adet.replace(',', '.')) || 0,
          birimFiyat: Number(s.birimFiyat.replace(',', '.')) || 0,
          iskonto: stokFisiMi ? 0 : Number(s.iskonto.replace(',', '.')) || 0,
          iskonto2: stokFisiMi ? 0 : Number(s.iskonto2.replace(',', '.')) || 0,
          // Stok fisi vergi dogurmaz: stok kartindan gelen KDV/iskonto sifirlanir
          //   (yoksa dip toplam vergili cikip muhasebe matrahini sisirir).
          kdv: stokFisiMi ? 0 : Number(s.kdv.replace(',', '.')) || 0,
          aciklama: s.aciklama,
          izlemeKodu: s.izlemeKodu,
          izleme: s.izleme || (s.izlemeKodu ? 1 : 0),
          // Lot dagilimi: bos dizi gonderilmez - izlemsiz stokta sunucu hata verir.
          izlemler: s.izlemler.length > 0
            ? s.izlemler.map(z => ({
                seriLotId: z.seriLotId,
                lotNo: z.lotNo.trim(),
                seriNo: z.seriNo.trim(),
                uretimTarihi: z.uretimTarihi || null,
                sonKullanmaTarihi: z.sonKullanmaTarihi || null,
                durum: z.durum,
                miktar: Number(z.miktar.replace(',', '.')) || 0,
              }))
            : undefined,
        })),
        secenekler: { taslak, stokKontrolu: true },
      };

      const yanit = await api.belgeEkle(govde);
      setSonuc(yanit);
      onKaydedildi?.();
      // TRANSFERDE kayittan sonra kartta yapilacak is yok (e-Belge, tahsilat,
      //   donusum yok) - kart kapanir, kullanici listeye doner. Diger belgelerde
      //   kart acik kalir: numara/e-Belge/tahsilat oradan surdurulur.
      if (bilgi.kaydedinceKapan) { kapat(); return }
    } catch (h) {
      if (h instanceof ApiHatasi) {
        if (h.dogrulamaMi && h.hata.alanlar)
          setAlanHatalari(Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])));
        setHata(`${h.hata.kod}: ${h.message}`);
      } else setHata(String(h));
    } finally {
      setKaydediyor(false);
    }
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
        <>
          {mevcutBelge
            ? <button className="d onay" disabled
                      title="Kesin belge düzenlenemez; değişiklik için iptal edip yeniden kesin (F7).">
                💾 Kaydet
              </button>
            : sonuc
              ? <button className="d onay" onClick={yeniBelge}>＋ Yeni Belge</button>
              : <button className="d onay" disabled={kaydediyor} onClick={() => void kes()}>
                  {kaydediyor ? '💾 Kaydediliyor…' : '💾 Kaydet'}
                </button>}
          <button className="d teh" disabled title="Belge iptali henüz bağlanmadı (F7).">
            🗑 Sil
          </button>

          <span className="ayrac" />

          {/* ---------------------------------------------------- SIPARIS ---- */}
          {siparisMi && (
            <>
              <button className="d bir" disabled title="Stok rezervasyonu henüz bağlanmadı.">
                🔒 Rezervasyon Yap
              </button>
              <button className="d" disabled={!kayitliId}
                      title={kayitliId ? 'Seçili satırları irsaliyeye aktar' : 'Önce siparişi kaydedin.'}
                      onClick={() => setDonusum(true)}>
                🚚 İrsaliyeye Dönüştür
              </button>
              <button className="d" disabled={!kayitliId}
                      title={kayitliId ? 'Seçili satırları faturaya aktar' : 'Önce siparişi kaydedin.'}
                      onClick={() => setDonusum(true)}>
                🧾 Faturaya Dönüştür
              </button>
              <button className="d" disabled title="Üretim emri henüz bağlanmadı.">🏭 Üretime Aktar</button>
              <span className="ayrac" />
              <button className="d" disabled={!kayitliId || !cari}
                      title={kayitliId
                        ? `Bu sipariş için ön ödeme (${alisMi ? 'ödeme' : 'tahsilat'}) işlemi aç`
                        : 'Önce siparişi kaydedin.'}
                      onClick={() => tahsilatAc(alisMi ? 31 : 21)}>
                💵 {alisMi ? 'Ön Ödeme Yap' : 'Ön Ödeme Al'}
              </button>
              <button className="d" disabled title="Termin güncelleme henüz bağlanmadı.">📅 Termin Güncelle</button>
              <button className="d" disabled title="Yazdırma henüz bağlanmadı.">🖨️ Yazdır</button>
            </>
          )}

          {/* --------------------------------------------------- IRSALIYE ---- */}
          {irsaliyeMi && (
            <>
              {/* Konsinyede e-Belge YOK: mal birakma GIB'e gitmez, faturasi
                  satildikca ayri kesilir. */}
              {!eBelgeYok && (
                <button className="d bir" disabled={!kayitliId}
                        title={kayitliId ? 'e-İrsaliye gönderimi henüz bağlanmadı.' : 'Önce irsaliyeyi kaydedin.'}>
                  ✉ e‑İrsaliye Gönder
                </button>
              )}
              <button className="d" disabled={!kayitliId}
                      title={kayitliId ? 'Sevk edilen satırları faturaya aktar' : 'Önce irsaliyeyi kaydedin.'}
                      onClick={() => setDonusum(true)}>
                🧾 Faturaya Dönüştür
              </button>
              <button className="d" disabled title="Sevk fişi yazdırma henüz bağlanmadı.">
                🖨️ Sevk Fişi Yazdır
              </button>
              <span className="ayrac" />
              <button className="d" disabled
                      title="Siparişten aktarım için Siparişler listesinden ilgili siparişi açıp Dönüştür deyin.">
                📋 Siparişten Aktar
              </button>
              {!eBelgeYok && (
                <button className="d" disabled title="GİB durum sorgusu henüz bağlanmadı.">
                  ⟳ GİB Durum Sorgula
                </button>
              )}
              <button className="d" disabled title="İade irsaliyesi henüz bağlanmadı.">
                ↩ İade İrsaliyesi
              </button>
            </>
          )}

          {/* ----------------------------------------------------- FATURA ---- */}
          {/* e-Belge olmayan turlerde (fis/konsinye/tahakkuk) gonderim dugmeleri YOK. */}
          {!siparisMi && !irsaliyeMi && !eBelgeYok && (
            <>
              <button className="d bir" disabled={!kayitliId}
                      title={kayitliId ? 'e-Belge gönderimi henüz bağlanmadı.' : 'Önce belgeyi kaydedin.'}>
                📤 e‑Fatura Gönder
              </button>
              <button className="d" disabled={!kayitliId || !cari}
                      title={kayitliId ? 'Bu belge için tahsilat işlemi aç' : 'Önce belgeyi kaydedin.'}
                      onClick={() => tahsilatAc(21)}>
                💵 {alisMi ? 'Ödeme' : 'Tahsilat'}
              </button>
              <button className="d" disabled title="İade belgesi henüz bağlanmadı.">↩ İade</button>
              <button className="d" disabled title="Yazdırma henüz bağlanmadı.">🖨️ Yazdır</button>
            </>
          )}

          <span className="ayrac" />

          <button className="d kapat-dugmesi" onClick={kapat}>✖ Kapat</button>

          <label className="satir-ici">
            <input type="checkbox" checked={taslak} disabled={kilitli}
                   onChange={e => setTaslak(e.target.checked)} />
            Taslak (numara tüketmez)
          </label>
        </>
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

        <div className="belge-hdr-sar">
          {/* Alan duzeni: Ekranlar/satis_irsaliye_karti.html .hdr + kullanici
              sirasi. BASLIKSIZ 3 sutunlu izgara; her alanda etiket EDITIN
              USTUNDE. Satirlar:
                1) Musteri . Belge No . e-Belge
                2) Vade . Belge Tarihi . Kapanma
                3) Satis Temsilcisi . Cikis Deposu . Doviz/Kur */}
          <div className="alan-izgara uc-sutun belge-hdr">
            {/* --- 1. satir --- */}
            {/* Cari alani GenLookup DEGIL: secim ayni TarafArama modalindan yapilir
                ki "yeni belge" akisiyla ayni ekran olsun (iki farkli cari secme
                bicimi kullaniciyi sasirtiyordu). */}
            {/* Transferde CARI YOK: mal firmanin kendi depolari arasinda gezer.
                Cari hucresinin yerini CIKIS DEPOSU alir, alt satirda giris deposu. */}
            {stokFisiMi ? (
              /* Fisin SEBEBI: muhasebe hesabini bu belirleyecek (F7), o yuzden
                 cari hucresinin yerinde ve zorunlu. */
              <label className="alan">
                <span className="etiket zorunlu-isaret">Tipi</span>
                {/* Yeni fiste ILK SORULAN budur (cari yok): kart acilinca imlec
                    burada, kullanici listeyi klavyeden acip secebilir. */}
                <select value={fisTipi} disabled={baslikKilitli}
                        autoFocus={!kilitli && !fisTipi}
                        onChange={e => setFisTipi(Number(e.target.value))}>
                  <option value={0}>Seçiniz…</option>
                  {(fisCikisMi ? CIKIS_FIS_TIPLERI : GIRIS_FIS_TIPLERI)
                    .map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
                </select>
                {alanHatalari.tipi && <span className="alan-hata">{alanHatalari.tipi}</span>}
              </label>
            ) : depoBelgesi ? (
              <GenLookup
                kaynak="depo"
                etiket={talepMi ? 'İstenen Depo' : 'Çıkış Deposu'}
                zorunlu
                sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
                alanlar={LOOKUP_DEPO}
                deger={depo?.ad}
                saltOkunur={baslikKilitli}
                hata={alanHatalari.cikisDepoId}
                onSec={x => setDepo(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)}
              />
            ) : (
            <TarafAlani
              etiket={alisMi ? 'Tedarikçi (Cari)'
                    : siparisMi || irsaliyeMi ? 'Müşteri (Cari)' : 'Cari'}
              zorunlu
              deger={cari?.unvan}
              kilitli={kilitli}
              ipucu="Cari ara"
              onAc={() => setCariArama(true)}
              hata={alanHatalari.tarafId}
            />
            )}

            {/* Alis faturasinda numara TEDARIKCININ: sayacimiz uretemez (harf
                icerebilir, bizim seriyle iliskisi yok), kullanici girer. Diger
                turlerde numarayi kayitta sunucu verir - alan salt-okunur. */}
            <label className="alan">
              <span className={`etiket${disNumarali && !kilitli ? ' zorunlu-isaret' : ''}`}>
                {disNumarali ? 'Tedarikçi Fatura No' : `${belgeAdi} No`}
              </span>
              {disNumarali && !kilitli ? (
                <input className="one-cikan" value={belgeNo} maxLength={20}
                       placeholder="örn. ABC2026000001234"
                       onChange={e => setBelgeNo(e.target.value)} />
              ) : (
                <input className="one-cikan"
                       value={String(sonuc?.belge.belgeNo ?? '') || (kilitli ? '' : '(kaydedince verilir)')}
                       readOnly />
              )}
              {alanHatalari.belgeNo && <span className="alan-hata">{alanHatalari.belgeNo}</span>}
            </label>

            {!eBelgeYok && (
            <label className="alan">
              <span className="etiket">e-Belge</span>
              <span className="deger-serit">
                <span className="rozet bilgi">
                  {konsinyeMi ? 'e-İrsaliye (konsinye)' : irsaliyeMi ? 'e-İrsaliye' : 'e-Fatura'}
                </span>
                {Number(sonuc?.belge.efaturaDurum ?? 0) > 0
                  ? <span className="rozet olumlu">✓ Gönderildi</span>
                  : <span className="rozet">gönderilmedi</span>}
              </span>
            </label>
            )}
            {/* e-Belge hucresi kalkinca 3 sutunlu izgara KAYIYORDU (Satis
                Temsilcisi 1. satirin 3. hucresine dusuyordu). Bos yer tutucu
                sutun duzenini korur: sol sutun Cari > Temsilci > Depo. */}
            {/* Transferde 3. sutun: Teslim Eden, altinda Teslim Alan (sorumluluk devri). */}
            {eBelgeYok && (stokFisiMi ? (
              <TarafAlani
                etiket="Sorumlu"
                deger={satici?.ad}
                kilitli={baslikKilitli}
                ipucu="Personel ara"
                onAc={() => setSaticiArama(true)}
              />
            ) : talepMi ? <span className="alan" aria-hidden />
              : transferMi ? (
              <TarafAlani
                etiket="Teslim Eden"
                zorunlu
                deger={teslimEden?.ad}
                kilitli={baslikKilitli}
                ipucu="Personel ara"
                onAc={() => setPersonelArama('eden')}
                hata={alanHatalari.teslimEdenId}
              />
            ) : kapanmaAlani)}

            {/* --- 2. satir: Satis Temsilcisi cari'nin ALTINDA --- */}
            {/* Satis temsilcisi PERSONEL'dir (cari degil) ve secim cari ile ayni
                TarafArama ekranindan yapilir - tek arama bicimi. */}
            {stokFisiMi ? (
              <GenLookup
                kaynak="depo"
                etiket={fisCikisMi ? 'Çıkış Deposu' : 'Giriş Deposu'}
                zorunlu
                sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
                alanlar={LOOKUP_DEPO}
                deger={depo?.ad}
                saltOkunur={baslikKilitli}
                hata={alanHatalari.cikisDepoId ?? alanHatalari.girisDepoId}
                onSec={x => setDepo(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)}
              />
            ) : depoBelgesi ? (
              <GenLookup
                kaynak="depo"
                etiket={talepMi ? 'Teslim Deposu' : 'Giriş Deposu'}
                zorunlu={!talepMi}
                sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
                alanlar={LOOKUP_DEPO}
                deger={girisDepo?.ad}
                saltOkunur={baslikKilitli}
                hata={alanHatalari.girisDepoId}
                onSec={x => setGirisDepo(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)}
              />
            ) : (
            <TarafAlani
              etiket={alisMi ? 'Sorumlu' : 'Satış Temsilcisi'}
              deger={satici?.ad}
              kilitli={kilitli}
              ipucu="Personel ara"
              onAc={() => setSaticiArama(true)}
            />
            )}

            <label className="alan">
              <span className="etiket zorunlu-isaret">{belgeAdi} Tarihi</span>
              <input type="datetime-local" value={tarih} disabled={baslikKilitli}
                     min={tarihEnErken} max={tarihEnGec}
                     onChange={e => setTarih(e.target.value)} />
              {alanHatalari.belgeTarihi && (
                <span className="alan-hata">{alanHatalari.belgeTarihi}</span>
              )}
            </label>

            {stokFisiMi ? <span className="alan" aria-hidden />
              : depoBelgesi ? (
              <TarafAlani
                etiket={talepMi ? 'Talep Eden' : 'Teslim Alan'}
                zorunlu
                deger={teslimAlan?.ad}
                kilitli={baslikKilitli}
                ipucu="Personel ara"
                onAc={() => setPersonelArama('alan')}
                hata={alanHatalari.teslimAlanId}
              />
            ) : eBelgeYok ? bagliSiparisAlani : kapanmaAlani}

            {/* --- 3. satir: Cikis Deposu temsilcinin ALTINDA ---
                Tahakkukta depo YOK: stok etkilemez (kasa_islem_turu.stok_etkiler=0). */}
            {!tahakkukMu && !depoBelgesi && !stokFisiMi && (
            <GenLookup
              kaynak="depo"
              etiket={siparisMi ? 'Depo' : alisMi ? 'Giriş Deposu' : 'Çıkış Deposu'}
              // Pasif depo secilemez: kapatilmis depoya belge kesilmesin.
              sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
              alanlar={LOOKUP_DEPO}
              deger={depo?.ad}
              saltOkunur={kilitli}
              onSec={s => setDepo(s ? { id: Number(s.id), ad: String(s.ad ?? '') } : null)}
            />
            )}
            {/* 3. satirin sutun duzeni korunsun: depo yoksa (tahakkuk) bos hucre.
                TRANSFERDE ayni yeri sorumluluk devri alanlari doldurur. */}
            {eBelgeYok && tahakkukMu && <span className="alan" aria-hidden />}

            {/* Irsaliyede/konsinyede Vade YOK (mal cikis tarihi belge tarihidir);
                e-Belgesiz turlerde yerine bos hucre - Doviz/Kur sag sutunda kalsin. */}
            {eBelgeYok && irsaliyeMi && !depoBelgesi && <span className="alan" aria-hidden />}
            {bilgi.vade && (
              <label className="alan">
                <span className="etiket">Vade (gün)</span>
                <input className="hiza-sag" value={vadeGun} disabled={kilitli}
                       onChange={e => setVadeGun(e.target.value)} />
              </label>
            )}

            {bilgi.doviz && (
            <label className="alan">
              <span className="etiket">Döviz / Kur</span>
              <input value={`${String(sonuc?.belge.belgeDovizi ?? 'TL')} · ${
                Number(sonuc?.belge.dovizKuru ?? 1).toLocaleString('tr-TR', { minimumFractionDigits: 6 })}`}
                     readOnly />
            </label>
            )}

            {/* Adres BASLIKTAN CIKTI: e-Belge sekmesinde (XML'e giden alanlarla
                birlikte) duruyor. Seri de basliktan kaldirildi - kullanici
                girmiyor, numara serisi zaten e-Belge sekmesinde gorunuyor.

                Vergi Dairesi/VKN kartta gosterilmiyor: cari kartindan gelen ve
                belgeye DONDURULAN bir bilgi, e-Belge XML'ine oradan gidiyor. */}
            {!eBelgeYok && bagliSiparisAlani}

            {/* Belge turu SECICISI YOK: tur ekranin kendisinden gelir (Siparisler
                19, Irsaliyeler 14, Faturalar 15) ve pencere basliginda zaten yazili.
                Kartta degistirilebilir olmasi, kaydedilen belgenin hangi listede
                cikacagini belirsizlestiriyordu. */}
          </div>
        </div>

        {/* Sekmeler BASLIK ALANLARININ ALTINDA, grid'in hemen ustunde -
            mockup duzeni (toolbar > hdr > tabs > pane). Tasiyici ve Imza/Teslim
            yalniz irsaliyede anlamli, o yuzden suzuluyor. */}
        <div className="katab">
          {SEKMELER
            .filter(x => (!x.irsaliye || irsaliyeMi)
                      && (!x.faturaYok || !(faturaMi || tahakkukMu))
                      // Tahsilat: fatura/fis VE tahakkuk (tahakkuk da tahsil edilir).
                      && (!x.faturaMi || faturaMi || tahakkukMu)
                      // Tahakkuk e-Belge DEGIL: GIB'e giden bir belge degil,
                      //   ic muhasebe/cari ara kaydi.
                      && !(eBelgeYok && x.anahtar === 'ebelge')
                      // Transferde cari/fatura zinciri yok: yalniz Kalemler + Yorum.
                      // "Faturalama" = bu belgeden turetilenler. Fatura zincirin
                      //   sonu (faturaYok), depo belgesi ve stok fisi ise hic
                      //   donusmez. Irsaliyede GORUNUR - kalem bicimine bakmak
                      //   yanlisti, irsaliyeyi de gizliyordu.
                      && !((bilgi.depoBelgesi || bilgi.stokFisi) && x.anahtar === 'fatura'))
            .map(x => (
            <div key={x.anahtar}
                 className={`kat${x.anahtar === aktifSekme ? ' on' : ''}`}
                 onClick={() => setAktifSekme(x.anahtar)}>
              {x.anahtar === 'tahsilat' && alisMi ? 'Ödeme' : x.baslik}
              {x.anahtar === 'kalem' && <span className="b">{satirlar.length}</span>}
              {x.anahtar === 'fatura' && donusumler.length > 0 && (
                <span className="b">{donusumler.length}</span>
              )}
            </div>
          ))}
        </div>

        {aktifSekme === 'kalem' && (
        <>
        <div className="kagrup">
          <h6>
            Kalemler
            {/* Ekle / Duzenle / Sil - YALNIZ IKON (yer kazanmak icin), ne
                yaptiklari title'da. Dugmeler kesin belgede de GORUNUR, yalnizca
                pasif: kaybolunca kullanici "nereye gitti" diye ariyordu. */}
            <button type="button" className="d bir ikon"
                    disabled={kilitli || transferBaslikEksigi !== null}
                    title={kilitli ? 'Kesin belgeye satır eklenemez (İptal edip yeniden kesin).'
                          : transferBaslikEksigi
                          ? `Önce başlıkta ${transferBaslikEksigi} seçin.`
                          : 'Satır ekle'}
                    onClick={() => setStokArama(true)}>
              ＋
            </button>
            <button type="button" className="d ikon"
                    disabled={kilitli || seciliSatirlar.size !== 1}
                    title={kilitli ? 'Kesin belge satırı düzenlenemez.'
                          : seciliSatirlar.size === 0 ? 'Önce bir satır seçin'
                          : seciliSatirlar.size > 1 ? 'Tek satır seçin' : 'Seçili satırı düzenle'}
                    onClick={() => {
                      const anahtar = [...seciliSatirlar][0];
                      const satir = satirlar.find(x => x.anahtar === anahtar);
                      if (satir) setKalem(satir);
                    }}>
              ✎
            </button>
            <button type="button" className="d teh ikon"
                    disabled={kilitli || seciliSatirlar.size === 0}
                    title={kilitli ? 'Kesin belgeden satır silinemez.'
                          : seciliSatirlar.size === 0 ? 'Önce satır seçin'
                          : `Seçili ${seciliSatirlar.size} satırı sil`}
                    onClick={seciliSil}>
              🗑
            </button>
          </h6>

          {/* Grid SALT GORUNUM (mockup deseni): hucre ici input yok, satir secimi
              onay kutusuyla, ekleme/duzenleme ayri kalem penceresinde. Boylece
              satirlar okunakli kalir ve yanlislikla ustune yazilmaz. */}
          <table className="detay-tablo secilebilir">
            <thead>
              <tr>
                <th style={{ width: 30 }} className="hiza-orta">
                  <input type="checkbox"
                         checked={satirlar.length > 0 && seciliSatirlar.size === satirlar.length}
                         onChange={e => setSeciliSatirlar(
                           e.target.checked ? new Set(satirlar.map(x => x.anahtar)) : new Set())} />
                </th>
                <th style={{ width: 34 }} className="hiza-orta">Tip</th>
                <th style={{ width: 110 }}>Kod</th>
                <th>Stok / Hizmet</th>
                <th style={{ width: 200 }}>Açıklama</th>
                <th className="hiza-sag" style={{ width: 90 }}>Miktar</th>
                {bilgi.kalem === 'tam' && <th className="hiza-sag" style={{ width: 80 }}>İskonto %</th>}
                {bilgi.kalem === 'tam' && <th className="hiza-sag" style={{ width: 70 }}>KDV %</th>}
                {/* Transferde FIYAT YOK: mal satilmiyor, depo degistiriyor. */}
                {bilgi.kalem !== 'miktar' && <th className="hiza-sag" style={{ width: 100 }}>Br. Fiyat</th>}
                {bilgi.kalem !== 'miktar' && <th className="hiza-sag" style={{ width: 120 }}>Tutar</th>}
              </tr>
            </thead>
            <tbody>
              {satirlar.map((r, sira) => {
                const adet = Number(r.adet.replace(',', '.')) || 0;
                const fiyat = Number(r.birimFiyat.replace(',', '.')) || 0;
                const tutar = satirTutari(adet, fiyat, r.iskonto, r.iskonto2);
                const secili = seciliSatirlar.has(r.anahtar);
                // Izlemli kalemin lotlari ALTINDA acilir (master-detail):
                //   hangi lottan kac adet oldugu kalemi acmadan gorunsun.
                const lotlar = r.izlemler ?? [];
                const acik = lotlar.length > 0 && !kapaliLotlar.has(r.anahtar);
                const kolonSayisi = bilgi.kalem === 'miktar' ? 6 : bilgi.kalem === 'sade' ? 8 : 10;
                return (
                  <Fragment key={r.anahtar}>
                  <tr className={secili ? 'secili' : ''}
                      onClick={e => satirTikla(sira, e)}
                      onDoubleClick={() => !kilitli && setKalem(r)}>
                    <td className="hiza-orta">
                      {/* Onay kutusu TEK satiri ekler/cikarir - satir tiklamasi
                          (duz tik = yalniz o satir) tetiklenmesin. */}
                      <input type="checkbox" checked={secili}
                             onClick={e => e.stopPropagation()}
                             onChange={() => { sonTiklanan.current = sira; secimDegis(r.anahtar) }} />
                    </td>
                    {/* Tip IKON: metin kolonu yer kapliyordu, anlami title'da. */}
                    <td className="hiza-orta" title={r.satirTur === 2 ? 'Hizmet' : 'Stok'}>
                      {r.satirTur === 2 ? '🛠️' : '📦'}
                    </td>
                    <td><code>{r.stokKodu}</code></td>
                    <td>
                      {/* Lotlu kalemde ac/kapa oku - detay satirlari onun altinda. */}
                      {lotlar.length > 0 && (
                        <button type="button" className="lot-ok"
                                title={acik ? 'Lotları gizle' : 'Lotları göster'}
                                onClick={e => {
                                  e.stopPropagation();
                                  setKapaliLotlar(k => {
                                    const y = new Set(k);
                                    if (y.has(r.anahtar)) y.delete(r.anahtar); else y.add(r.anahtar);
                                    return y;
                                  });
                                }}>
                          {acik ? '▾' : '▸'}
                        </button>
                      )}
                      {r.stokAdi || <span className="sonuk">(stok seçilmedi)</span>}
                    </td>
                    <td className="sonuk">{r.aciklama}</td>
                    <td className="hiza-sag">{adet.toLocaleString('tr-TR')}</td>
                    {/* Iki iskonto varsa ikisi de gorunsun: "%10 + %5". */}
                    {bilgi.kalem === 'tam' && <td className="hiza-sag">{iskonatoMetni(r)}</td>}
                    {bilgi.kalem === 'tam' && <td className="hiza-sag">%{r.kdv}</td>}
                    {bilgi.kalem !== 'miktar' && <td className="hiza-sag">{para.format(fiyat)}</td>}
                    {bilgi.kalem !== 'miktar' && <td className="hiza-sag"><b>{para.format(tutar)}</b></td>}
                  </tr>
                  {/* DETAY: kalemin lot dagilimi. Kalem satirinin bir parcasi -
                      ayri kolon basligi yok, kendi mini basligiyla gelir. */}
                  {acik && lotlar.length > 0 && (
                    <tr className="lot-detay">
                      <td />
                      <td colSpan={kolonSayisi - 1}>
                        <table className="lot-tablo">
                          <thead>
                            <tr>
                              <th>Lot No</th>
                              <th>Seri No</th>
                              <th>Ürt. Tarihi</th>
                              <th>SKT</th>
                              <th className="hiza-sag">Miktar</th>
                            </tr>
                          </thead>
                          <tbody>
                            {lotlar.map((z, li) => (
                              <tr key={z.seriLotId ?? li}>
                                <td><code>{z.lotNo || '—'}</code></td>
                                <td>{z.seriNo || '—'}</td>
                                <td>{z.uretimTarihi ? z.uretimTarihi.split('-').reverse().join('.') : '—'}</td>
                                <td>{z.sonKullanmaTarihi ? z.sonKullanmaTarihi.split('-').reverse().join('.') : '—'}</td>
                                <td className="hiza-sag">
                                  {(Number(String(z.miktar).replace(',', '.')) || 0).toLocaleString('tr-TR')}
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  )}
                  </Fragment>
                );
              })}
              {satirlar.length === 0 && (
                <tr><td colSpan={bilgi.kalem === 'miktar' ? 6 : bilgi.kalem === 'sade' ? 8 : 10} className="bos">
                  {transferBaslikEksigi
                    ? `Kalem eklemek için önce başlıkta ${transferBaslikEksigi} seçin.`
                    : 'Kalem yok — “＋” ile ekleyin.'}
                </td></tr>
              )}
            </tbody>
            <tfoot>
              <tr className="genel">
                <td colSpan={5} className="hiza-sag">TOPLAM</td>
                <td className="hiza-sag">
                  {satirlar.reduce((t, r) => t + (Number(r.adet.replace(',', '.')) || 0), 0)
                           .toLocaleString('tr-TR')}
                </td>
                {bilgi.kalem !== 'miktar' && <td colSpan={bilgi.kalem === 'sade' ? 1 : 3} />}
                {bilgi.kalem !== 'miktar' && <td className="hiza-sag">{para.format(onizleme.matrah)}</td>}
              </tr>
            </tfoot>
          </table>
          {!kilitli && satirlar.length > 0 && (
            <div className="not">
              Satırı düzenlemek için çift tıklayın.
              {(depoBelgesi || stokFisiMi) && ` Kalem eklendiği için başlık (${stokFisiMi ? 'tip, depo' : talepMi ? 'depolar, talep eden' : 'depolar, teslim eden/alan'}, tarih) kilitlendi — değiştirmek için kalemleri silin.`}
            </div>
          )}
        </div>

        {/* Transferde dip toplam YOK: para degil miktar hareketi. */}
        {bilgi.kalem !== 'miktar' && (
        <div className="kagrup dip-toplam">
          <h6>{sonuc ? 'Dip Toplam (sunucu)' : 'Dip Toplam (önizleme)'}</h6>
          {sonuc ? (
            <table className="dip-tablo">
              <tbody>
                {sonuc.dipToplam.map((d, i) => (
                  <tr key={i} className={d.tur === 20 ? 'genel' : ''}>
                    <td>{d.aciklama}</td>
                    <td className="hiza-sag">{para.format(d.deger)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <table className="dip-tablo">
              <tbody>
                <tr><td>Ara Toplam</td><td className="hiza-sag">{para.format(onizleme.matrah)}</td></tr>
                <tr><td>KDV</td><td className="hiza-sag">{para.format(onizleme.kdv)}</td></tr>
                <tr className="genel"><td>Genel Toplam</td><td className="hiza-sag">{para.format(onizleme.genel)}</td></tr>
              </tbody>
            </table>
          )}
          {!kilitli && <div className="not">Kesin tutar sunucuda hesaplanır; buradaki değerler önizlemedir.</div>}
        </div>
        )}
        </>
        )}

        {/* ========================================= TASIYICI / SEVKIYAT ==== */}
        {aktifSekme === 'tasiyici' && (
          <div className="kagrup">
            <h6>Taşıyıcı Bilgileri</h6>
            <div className="alan-izgara uc-sutun">
              <TarafSecici
                etiket="Taşıyıcı Ünvan"
                deger={tasiyici?.ad}
                kilitli={kilitli}
                yerTutucu="Taşıyıcı ara…"
                onSec={sec => setTasiyici({ id: sec.id, ad: sec.unvan })}
                onTemizle={() => setTasiyici(null)}
              />
              {/* Teslim eden PERSONEL de olabilir - iki kaynak birlikte aranir. */}
              <TarafSecici
                etiket="Teslim Eden"
                deger={teslimEden?.ad}
                kilitli={kilitli}
                kaynaklar={['personel', 'cari']}
                yerTutucu="Personel / cari ara…"
                onSec={sec => setTeslimEden({ id: sec.id, ad: sec.unvan })}
                onTemizle={() => setTeslimEden(null)}
              />
              <label className="alan">
                <span className="etiket">Teslim Şekli</span>
                <select value={teslimSekli} disabled={kilitli}
                        onChange={e => setTeslimSekli(Number(e.target.value))}>
                  {TESLIM_SEKLI.map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
                </select>
              </label>
              <label className="alan genis-2">
                <span className="etiket">Sevk Adresi</span>
                <input value={[sonuc?.belge.tarafAdres, sonuc?.belge.tarafIlce, sonuc?.belge.tarafIl]
                                .filter(Boolean).join(' / ')} readOnly
                       placeholder="Cari seçilince kartındaki varsayılan adres gelir" />
              </label>
              <label className="alan">
                <span className="etiket">Sevk Zamanı</span>
                <input type="datetime-local" value={sevkTarihi} disabled={kilitli}
                       onChange={e => setSevkTarihi(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Araç Plakası</span>
                <input value={aracPlaka} maxLength={20} disabled={kilitli}
                       placeholder="07 ABC 145"
                       onChange={e => setAracPlaka(e.target.value.toUpperCase())} />
              </label>
              <label className="alan">
                <span className="etiket">Şoför Adı</span>
                <input value={soforAd} maxLength={60} disabled={kilitli}
                       onChange={e => setSoforAd(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Şoför TC</span>
                <input value={soforTckn} maxLength={11} disabled={kilitli}
                       placeholder="11 hane"
                       onChange={e => setSoforTckn(e.target.value.replace(/\D/g, ''))} />
              </label>
            </div>
            <div className="not">
              Bu alanlar e-İrsaliye UBL'ine gider (TransportMeans/PlateID,
              DriverPerson, CarrierParty, ShipmentStage). Kap adedi, brüt ağırlık
              ve sevkiyat aşamaları (yola çıkış / teslim) henüz şemada yok.
            </div>
          </div>
        )}

        {/* ================================================== e-BELGE ==== */}
        {aktifSekme === 'ebelge' && (
          <div className="kagrup">
            {/* Alan sirasi Ekranlar/satis_faturasi.html "e-Belge" sekmesiyle AYNI:
                Belge Tipi · Alias (URN) · Senaryo · Durum · ETTN/Zarf No · XSLT.
                Adres mockup'ta yok, kullanici istegiyle burada duruyor. */}
            <h6>
              {irsaliyeMi ? 'e-İrsaliye' : 'e-Fatura / e-Arşiv'}
              <span className="kapt">belge.efatura* · e_belge</span>
            </h6>
            {/* Mockup'ta (.grid2) her alan KENDI SATIRINDA: etiket solda, deger
                sagda. Uc sutuna yayilinca sira okunmuyordu. */}
            <div className="alan-izgara tek-sutun">
              <label className="alan">
                <span className="etiket">Belge Tipi</span>
                <input value={eBelgeTipi(tur, senaryo)} readOnly />
              </label>
              <label className="alan">
                <span className="etiket">Alias (URN)</span>
                <input value={String(sonuc?.belge.gondericiAlias ?? '') || '—'} readOnly />
              </label>

              <label className="alan">
                <span className="etiket">Senaryo</span>
                <select value={senaryo} disabled={kilitli}
                        onChange={e => setSenaryo(Number(e.target.value))}>
                  {SENARYO_SECENEK.map(o => (
                    <option key={o.deger} value={o.deger}>{o.ad}</option>
                  ))}
                </select>
              </label>
              <label className="alan">
                <span className="etiket">Durum</span>
                <span className="deger-serit">
                  {Number(sonuc?.belge.efaturaDurum ?? 0) > 0
                    ? <span className="rozet ok">Gönderildi</span>
                    : <span className="rozet gri">Kâğıt / gönderilmedi</span>}
                  {sonuc?.belge.gibDurumAciklama
                    ? <span className="sonuk">{String(sonuc.belge.gibDurumAciklama)}</span>
                    : null}
                </span>
              </label>

              <label className="alan">
                <span className="etiket">ETTN / Zarf No</span>
                <input readOnly value={
                  [String(sonuc?.belge.ettn ?? ''), String(sonuc?.belge.zarfId ?? 0) !== '0'
                    ? String(sonuc?.belge.zarfId) : '']
                    .filter(Boolean).join(' / ') || '—'} />
              </label>
              <label className="alan">
                <span className="etiket">XSLT Tasarımı</span>
                {/* Tasarim listesi (DOKUMLER) henuz baglanmadi - combo GORUNUR
                    ama tek secenekli ve pasif; sahte secenek uretmiyoruz. */}
                <select disabled title="Tasarım listesi henüz bağlanmadı">
                  <option>Genel Fatura Tasarımı</option>
                </select>
              </label>

              {/* Adres basliktan buraya tasindi: e-Belge XML'ine giden alici
                  bilgisi, kesim sirasinda degil gonderim baglaminda okunuyor. */}
              <label className="alan genis-2">
                <span className="etiket">Adres</span>
                <input value={[sonuc?.belge.tarafAdres, sonuc?.belge.tarafIlce, sonuc?.belge.tarafIl]
                                .filter(Boolean).join(' / ')} readOnly
                       placeholder="Cari seçilince kartındaki varsayılan adres gelir" />
              </label>
            </div>

            {/* Mockup'taki dugme seridi. Gonderim/sorgulama UCLARI HENUZ YOK -
                dugmeler gorunur ama pasif (yalanci calisma yerine durust durum). */}
            <div className="katoolbar" style={{ margin: 10 }}>
              <button className="d" disabled title="Gönderim ucu henüz bağlanmadı">📤 Yeniden Gönder</button>
              <button className="d" disabled title="Önizleme henüz bağlanmadı">👁 Önizle (PDF)</button>
              <button className="d" disabled title="XML indirme henüz bağlanmadı">⬇ XML İndir</button>
              <button className="d" disabled title="GİB durum sorgulama henüz bağlanmadı">📋 Durum Sorgula</button>
            </div>

            <div className="not">
              ETTN / zarf no ve GİB yanıtı e-Belge kuyruğundan (e_belge) okunur;
              gönderim ucu henüz bağlanmadı. XSLT tasarım seçimi de dokümanlar
              tablosuna bağlanacak.
            </div>
          </div>
        )}

        {/* =============================================== FATURALAMA ==== */}
        {aktifSekme === 'fatura' && (
          <div className="kagrup">
            <h6>
              Faturalama
              {kayitliId > 0 && (
                <button type="button" className="d bir" onClick={() => setDonusum(true)}>
                  🧾 Faturaya Dönüştür
                </button>
              )}
            </h6>
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th style={{ width: 160 }}>Belge No</th>
                  <th style={{ width: 100 }}>Tarih</th>
                  <th>Tür</th>
                  <th className="hiza-sag" style={{ width: 100 }}>Miktar</th>
                  <th className="hiza-sag" style={{ width: 130 }}>Tutar</th>
                  <th style={{ width: 90 }}>Durum</th>
                </tr>
              </thead>
              <tbody>
                {donusumler.map((d, i) => (
                  <tr key={i}>
                    <td><b>{String(d.belgeNo ?? '')}</b></td>
                    <td>{String(d.belgeTarihi ?? '').slice(0, 10).split('-').reverse().join('.')}</td>
                    <td>{String(d.turAdi ?? '')}</td>
                    <td className="hiza-sag">{Number(d.miktar ?? 0).toLocaleString('tr-TR')}</td>
                    <td className="hiza-sag">{para.format(Number(d.tutar ?? 0))}</td>
                    <td>{String(d.durumAdi ?? '')}</td>
                  </tr>
                ))}
                {donusumler.length === 0 && (
                  <tr><td colSpan={6} className="bos">
                    {kayitliId > 0 ? 'Bu belgeden henüz belge türetilmemiş.' : 'Önce belgeyi kaydedin.'}
                  </td></tr>
                )}
              </tbody>
            </table>
          </div>
        )}

        {/* ================================================== TAHSILAT ==== */}
        {/* Ekranlar/satis_faturasi.html "Tahsilat" panosu: belgeye bagli kasa
            islemleri (kasa_islem.belge_id) + tahsil edilen / kalan. */}
        {aktifSekme === 'tahsilat' && (() => {
          const genel = Number(sonuc?.belge.genelToplam ?? 0);
          const tahsil = tahsilatlar.reduce((t, k) => t + (Number(k.yerelTutar ?? k.tutar ?? 0) || 0), 0);
          const kalan = Math.round((genel - tahsil) * 100) / 100;
          return (
            <div className="kagrup">
              {/* Tahsilat araclari: Nakit 21 / Banka 22 / POS 25 - hepsi ayni
                  modali (kasa karti) cari + tutar onyuklu acar. Cek/Senet kasa
                  planinin F5 fazinda (cek_senet tablosu) baglanacak. */}
              <div className="katoolbar" style={{ margin: 10 }}>
                {/* Tahsilat ARACI adiyla: yanindaki POS / Cek-Senet ile ayni
                    dizide - bu dugme NAKIT tahsilat (tur 21) acar. */}
                {/* Alista ODEME turleri (31/32/35), satista tahsilat (21/22/25). */}
                <button className="d bir" disabled={!kayitliId}
                        title={kayitliId ? `Nakit ${alisMi ? 'ödeme' : 'tahsilat'} işlemi aç` : 'Önce belgeyi kaydedin.'}
                        onClick={() => tahsilatAc(alisMi ? 31 : 21)}>
                  💵 Nakit
                </button>
                <button className="d bir" disabled={!kayitliId}
                        title={kayitliId ? `Banka (havale/EFT) ${alisMi ? 'ödeme' : 'tahsilat'} işlemi aç` : 'Önce belgeyi kaydedin.'}
                        onClick={() => tahsilatAc(alisMi ? 32 : 22)}>
                  🏦 Banka
                </button>
                <button className="d bir" disabled={!kayitliId}
                        title={kayitliId ? `Kredi kartı / POS ${alisMi ? 'ödeme' : 'tahsilat'} işlemi aç` : 'Önce belgeyi kaydedin.'}
                        onClick={() => tahsilatAc(alisMi ? 35 : 25)}>
                  💳 POS
                </button>
                <button className="d" disabled title="Çek/senet girişi F5'te bağlanacak">🧾 Çek/Senet Al</button>
              </div>
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th style={{ width: 140 }}>Tarih / Saat</th>
                    <th style={{ width: 120 }}>Makbuz No</th>
                    <th style={{ width: 180 }}>Tür</th>
                    <th>Kasa / Banka</th>
                    <th className="hiza-sag" style={{ width: 130 }}>Tutar</th>
                  </tr>
                </thead>
                <tbody>
                  {tahsilatlar.map((k, i) => (
                    <tr key={i}>
                      {/* Tarih + saat: ayni gun birden fazla tahsilat olunca
                          sira ancak saatle anlasiliyordu. */}
                      <td>{tarihSaat(k.islemTarihi)}</td>
                      <td>{String(k.islemNo ?? '')}</td>
                      <td>{String(k.turAdi ?? '')}</td>
                      <td>{String(k.hesapAdi ?? '') || <span className="sonuk">—</span>}</td>
                      <td className="hiza-sag">{para.format(Number(k.yerelTutar ?? k.tutar ?? 0))}</td>
                    </tr>
                  ))}
                  {tahsilatlar.length === 0 && (
                    <tr><td colSpan={5} className="bos">
                      {kayitliId > 0
                        ? `Bu belgeye bağlı ${alisMi ? 'ödeme' : 'tahsilat'} yok.`
                        : 'Önce belgeyi kaydedin.'}
                    </td></tr>
                  )}
                </tbody>
                <tfoot>
                  <tr className="genel">
                    <td colSpan={4} className="hiza-sag">
                      {alisMi ? 'Ödenen / Kalan' : 'Tahsil Edilen / Kalan'}
                    </td>
                    <td className="hiza-sag">
                      {para.format(tahsil)} /{' '}
                      <b style={{ color: kalan > 0 ? 'var(--hata)' : 'var(--ok)' }}>
                        {para.format(kalan)}
                      </b>
                    </td>
                  </tr>
                </tfoot>
              </table>

            </div>
          );
        })()}

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

        {/* 1) Stok/hizmet arama - satir eklemenin BASLANGICI. Secim yapilinca
               kapanmaz; kalem penceresi ustune acilir, o kapaninca buraya donulur
               ve siradaki stok secilir (ardisik hizli giris). */}
        {stokArama && (
          <StokAramaPenceresi
            etkin={kalem === null}
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
            irsaliyeMi={bilgi.kalem !== 'tam'}
            transferMi={bilgi.kalem === 'miktar'}
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
        {donusum && kayitliId > 0 && (
          <BelgeDonusumModali
            belgeId={kayitliId}
            belgeTur={tur}
            onKapat={() => setDonusum(false)}
            onTamam={() => onKaydedildi?.()}
          />
        )}
      </>
    </Modal>
  );
}
