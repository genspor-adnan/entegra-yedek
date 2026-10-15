import { GenForm, type EkSekmeBaglami } from '../../bilesenler/GenForm';
import { Modal } from '../../bilesenler/Modal';
import { LabMikroOzet, labMikroOzetiVar } from '../../bilesenler/lab/LabMikroOzet';
import { LabCalismaTakvimi, type CalismaDuzeni }
  from '../../bilesenler/lab/LabCalismaTakvimi';
import { MuayeneBaglamSeridi, MuayeneBaslikNumaralari } from '../../bilesenler/MuayeneBaglamSeridi';
import { MuayeneOzetSekmesi } from '../../bilesenler/MuayeneOzetSekmesi';
import { VucutSemasi } from '../../bilesenler/VucutSemasi';
import { OlcumGrafigi } from '../../bilesenler/OlcumGrafigi';
import { MuayeneEpikrizSekmesi } from '../../bilesenler/MuayeneEpikrizSekmesi';
import { KendimeNotPenceresi } from '../../bilesenler/KendimeNot';
import { MuayeneHastaBandi, MuayeneSolMenu, MuayeneYanPanel, useMuayeneHastaBilgisi, type KontrolMaddesi } from '../../bilesenler/MuayeneSekmesiz';
import { gorunumOku, gorunumKaydet, type MuayeneDuzeni } from '../../bilesenler/gorunum';
import { MuayeneDurumSeridi } from '../../bilesenler/MuayeneDurumSeridi';
import { MuayeneIstemSonuc } from '../../bilesenler/MuayeneIstemSonuc';
import { PatolojiIstemModal } from '../../bilesenler/PatolojiIstemModal';
import { KipCercevesi } from '../../bilesenler/KipCercevesi';
import { tarihYaz } from '../../bilesenler/bicim';
import {
  useMuayeneSekmeVerisi, MuayeneReceteSekmesi, MuayeneKonsultasyonSekmesi, ReceteGosterim, gosterilenRecete,
  MuayeneUcretSekmesi, MuayeneGecmisSekmesi,
} from '../../bilesenler/MuayeneSekmeleri';
import { DokumanGalerisi } from '../../bilesenler/DokumanGalerisi';
import { AsiUygulaModali } from '../../bilesenler/AsiUygulaModali';
import { CocukIzlemModali } from '../../bilesenler/CocukIzlemModali';
import { GebeIzlemModali } from '../../bilesenler/GebeIzlemModali';
import { EnabizButonu } from '../../bilesenler/EnabizButonu';
import { MuayeneEnabizSekmesi } from '../../bilesenler/MuayeneEnabizSekmesi';
import { useOturum } from '../../kimlik/OturumBaglami';
import { EnabizMesajModali } from '../../bilesenler/EnabizMesajModali';
import { IstemSepetiModal } from '../../bilesenler/IstemSepetiModal';
import { MuayeneRaporModal } from '../../bilesenler/MuayeneRaporModal';
import { MuayeneOzetiModal } from '../../bilesenler/MuayeneOzetiModal';
import { MuayeneSablonRozeti } from '../../bilesenler/MuayeneSablonRozeti';
import { useContext, useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { EkranSekmesiBaglami, LISTE_TAZELE_OLAYI } from '../../bilesenler/sekmeBaglami';
import { makroTusu, type Makro } from '../../bilesenler/muayeneMakro';
import { MakroluMetin } from '../../bilesenler/MakroluMetin';
import { MakroIpucu } from '../../bilesenler/MakroIpucu';

/** Makro açılan muayene alanları (katalog MakroAlanKodlari ile aynı). */
const MAKRO_ALANLARI = new Set(['sikayet', 'hikaye', 'bulguOzet', 'karar']);
import { MuayeneDikte } from '../../bilesenler/MuayeneDikte';
import { c } from '../../dil/ceviri';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { GozMuayeneSeridi } from '../../bilesenler/goz/GozMuayeneSeridi';
import { GozlukHastaBandi, GozlukReceteFormu, gozlukYazdir, useGozlukKaynak } from '../goz/GozlukPanelleri';
import { GoruntulemeHastaBandi, GoruntulemeKarsilastirmaSekmesi, GoruntuOlcumSekmesi, useGoruntulemeOnizleme } from '../goz/GozGoruntulemePanelleri';
import { BaglantiAyarSekmesi, CihazYanPaneli, KalibrasyonSekmesi, MesajGunluguSekmesi,
         OlcumEslemeSekmesi, TetkikEslemeSekmesi } from '../goz/GozCihazSekmeleri';
import { useGozCihazOnizleme } from '../goz/GozCihazPanelleri';
import { GOZ_TARAF, GOZ_TETKIK } from '../../bilesenler/goz/gozKodlari';
import { MUAYENE_DURUM } from '../../bilesenler/muayeneKodlari';
import { GOZ_SEKME_GRUPLARI, GozKuralSeridi, GozOykuV4Sekmesi, GozOzetSekmesi, GozSagOzet, useGozKontrol } from '../goz/GozKartV4';
import { GozKartinaGit, GozReceteSekmesi, GozTaniSekmesi, GozUcretSekmesi } from '../goz/GozSurecSekmeleri';
import { GozGibEgilimi, GozGoruntulerSekmesi, GozKarsilastirmaSekmesi, GozTaniPlanPaneli } from '../goz/GozMuayenePanelleri';
import { OrderGecmisSekmesi, OrderGuvenlikSekmesi, OrderHastaSeridi, OrderOzetKutusu, OrderPlanSekmesi } from '../yatan/OrderPanelleri';
import { randevuTercihiYaz } from './randevuTercihi';
import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import type { ListeTanimi } from '../listeTanimlari';
import { kartAdi, kartSekmesiVar } from '../listeTanimlari.Ortak';
import { MetinMakroGovdesi } from '../../bilesenler/MetinMakroGovdesi';
import type { KartOzellestirme } from './kartOzellestirme';
import { DofAraclari, dofBaslikEk } from '../kys/dof/kysDofKarti';
import { BulguDofHucresi, DenetimAraclari, useBulguDoflari } from '../kys/denetim/kysDenetimKarti';
import { ToplantiAraclari } from '../kys/toplanti/KysToplantilar';
import { KayitSonraDolar, SablonKullanimSekmesi, SablonOnizlemeSekmesi, SablonSurumSekmesi, SmsOnizleme } from '../radyoloji/RadyolojiTanimPanelleri';
import { CihazDozSekmesi, CihazHaftaKapasite, CihazKapasite, CihazKapatModali, CihazKullanimSekmesi } from '../radyoloji/CihazPanelleri';



/** "Muayene" sekmesi (eski adları Fizik Muayene → Şablon Muayene - kullanıcı yeniden
    adlandırdı; eski adlar yeniden başlatılmamış API için tanınır). Yalnız muayene
    kartında çağrılır - İSG'nin "Muayene" grubu buraya gelmez. */
const sablonMuayeneMi = (baslik: string) =>
  baslik === 'Muayene' || baslik === 'Şablon Muayene' || baslik === 'Fizik Muayene';

export interface ListeKartiOzellikleri {
  tanim: ListeTanimi;
  /** null iken kart kapali; 'yeni' yeni kayit. */
  kartId: number | 'yeni' | null;
  kartOzel: KartOzellestirme;
  sekmeVerisi: ReturnType<typeof useMuayeneSekmeVerisi>;
  /** Karttaki eylem dugmeleri listedekiyle AYNI isleyiciye gider. */
  aksiyon(kod: string, satir?: ListeSatiri | null): void | Promise<void>;
  muayeneBilgiAcik: boolean;
  setMuayeneBilgiAcik(acik: boolean): void;
  setIcdAramaAcik(acik: boolean): void;
  /** ICD penceresi belirli bir muayeneye (göz kartı → genel muayene). */
  icdAc?(muayeneId: number): void;
  kartTazele: number;
  setKartTazele(f: (t: number) => number): void;
  sorgu: URLSearchParams;
  git(yol: string, secenek?: { replace?: boolean }): void;
  setYenile(f: (t: number) => number): void;
  /** Hasta kartındaki "＋ Yeni Başvuru": kart kapanır, başvuru açılır (782). */
  onBasvuruAc?(tarafId: number, unvan: string): void;
  setOdaklaSonEklenen(f: (t: number) => number): void;
}

/**
 * KART (modal GenForm) - liste ekraninin kart yuzu.
 *
 * `Liste` govdesinde duran ~280 satirlik GenForm cagrisi buraya alindi:
 * muayene kartinin sekme sarmalayicilari, baglam seridi, ek sekmeleri ve
 * eylem dugmeleri ile lab tetkik kartinin calisma takvimi burada yasiyor.
 * Davranis degismedi - yalniz yeri degisti.
 */
/**
 * Goz muayene kartindaki kisayollarin actigi kartlar (691). Bu uc
 * kaynak URL'den `hastaId` / `muayeneId` on dolgusu kabul eder.
 */
const HASTA_KAYIT_KAYNAKLARI = new Set(['hasta-alerji', 'hasta-kronik', 'hasta-ilac', 'hasta-gecmis', 'ftr-degerlendirme', 'ftr-program', 'ftr-olcek', 'isg-calisan']);
const GOZ_KISAYOL_KAYNAKLARI = new Set([
  'goz-gozluk-recete', 'goz-goruntuleme', 'goz-islem',
]);

/** Vital özet kutusu alanı → geçmiş grafiği anahtarı (grafiği olmayan alan tıklanmaz). */
/** Anamnez gösterim kipinin satırları (alan, etiket) - katalogdaki sırayla. */
const ANAMNEZ_ALANLARI: readonly (readonly [string, string])[] = [['sikayet', 'Şikâyet'], ['hikaye', 'Hikâye']];

const VITAL_ALAN_GRAFIK: Record<string, string> = {
  sistolik: 'ta', nabiz: 'nabiz', spo2: 'spo2', ates: 'ates', solunum: 'solunum', kiloKg: 'kilo', bki: 'bki',
};

/** Muayene vital ızgarasının altındaki geçmiş grafiği kısayolları (sunucu anahtarı, etiket). */
const VITAL_GRAFIKLERI: [string, string][] = [
  ['ta', 'Tansiyon'], ['nabiz', 'Nabız'], ['spo2', 'SpO₂'], ['ates', 'Ateş'],
  ['solunum', 'Solunum'], ['kilo', 'Kilo'], ['bki', 'BKİ'],
];

export function ListeKarti({
  tanim, kartId, kartOzel, sekmeVerisi, aksiyon,
  muayeneBilgiAcik, setMuayeneBilgiAcik, setIcdAramaAcik, icdAc,
  kartTazele, setKartTazele, sorgu, git, setYenile, setOdaklaSonEklenen,
  onBasvuruAc,
}: ListeKartiOzellikleri) {
  // KANCALAR ERKEN CIKISTAN ONCE: `kartId === null` dalinda da ayni sirada
  //   calismalari gerekir (React kanca kurali).
  const [enabizMesaj, setEnabizMesaj] = useState<
    { hastaId: number; hastaAdi: string; belgeId: number | null } | null>(null);
  // AŞI PENCERESİ (898): hasta kartından açılır.
  const [asiHasta, setAsiHasta] = useState<{ id: number; ad: string } | null>(null);
  const [izlemHasta, setIzlemHasta] = useState<{ id: number; ad: string } | null>(null);
  const [gebeHasta, setGebeHasta] = useState<{ id: number; ad: string } | null>(null);
  // CİHAZ KARTI "Kapat / bakıma al" penceresi (967).
  const [cihazKapat, setCihazKapat] = useState(false);
  // İÇ DENETİM (1061): bulgulardan açılmış DÖF'ler (Bulgular tablosunun DÖF kolonu).
  const bulguDoflari = useBulguDoflari(tanim.kaynak === 'kys-denetim' && typeof kartId === 'number' ? kartId : 0);
  const { kullanici } = useOturum();
  // BİRLEŞİK İSTEM SEPETİ (kullanici: "lab ve radyoloji tek istem ekranı,
  //   sekmeli"): muayeneId set olunca modal açılır.
  const [istem, setIstem] = useState<number | null>(null);
  /** DIKTE penceresi + kartin GUNCEL alan okuyucu/yazicisi. Ref her cizimde
      tazelenir: pencere acikken yapilan ekleme bir sonrakinde bayat degerle
      ezilmesin. */
  const [dikteAcik, setDikteAcik] = useState(false);
  const dikteKaynak = useRef<{ oku(ad: string): string;
                               yaz(ad: string, v: string): void } | null>(null);
  // RAPOR EKLE MODALI (kullanici: "eklerken direkt modal ön bilgilerle açılsın").
  const [raporModal, setRaporModal] = useState<{ muayeneId: number; tur: number } | null>(null);
  // MUAYENE ÖZETİ MODALI (kullanici: "muayene özeti ni mockup gibi yap").
  const [ozetModal, setOzetModal] = useState<number | null>(null);
  /** Kartın kaydedilmemiş değişikliğini yazan fonksiyon (GenForm.kaydetBagla). */
  const kartKaydetRef = useRef<(() => Promise<boolean>) | null>(null);
  /** Vucut semasi penceresi (Muayene sekmesi). */
  const [vucutAcik, setVucutAcik] = useState(false);
  /** Vital geçmiş grafiği (mockup v7): ta, nabiz, spo2, ates, solunum, kilo, bki. */
  const [vitalGrafik, setVitalGrafik] = useState<string | null>(null);
  /** MUAYENE DÜZENİ (kullanıcı tercihi gorunum.muayeneDuzeni): sekmeli / tek sayfa. */
  const [muayeneDuzeni, setMuayeneDuzeni] = useState<MuayeneDuzeni>(() => gorunumOku().muayeneDuzeni);
  const duzenDegis = (d: MuayeneDuzeni) => {
    setMuayeneDuzeni(d);
    void gorunumKaydet({ ...gorunumOku(), muayeneDuzeni: d }).catch(() => {});
  };
  /** Sekmesiz düzenin sol listesinden açılan Kendime Not penceresi. */
  const [notAcik, setNotAcik] = useState(false);
  /** MUAYENE EPİKRİZİ (1100): sekme kayıt varsa ya da istenince açılır. */
  const [epikrizDurum, setEpikrizDurum] = useState<'taslak' | 'imzali' | null>(null);
  const [epikrizIstendi, setEpikrizIstendi] = useState(false);
  const [epikrizGit, setEpikrizGit] = useState(0);
  useEffect(() => {
    setEpikrizDurum(null); setEpikrizIstendi(false);
    if (tanim.kaynak !== 'muayene' || typeof kartId !== 'number') return;
    let iptal = false;
    void api.muayeneEpikriz(kartId).then(v => {
      if (!iptal) setEpikrizDurum(!v.kayit ? null : v.kayit.imzaDurum === 1 ? 'imzali' : 'taslak');
    }).catch(() => {});
    return () => { iptal = true };
  }, [tanim.kaynak, kartId]);
  /** e-Recete sekmesine "ilac aramayi ac" istegi (ozet kontrol listesi);
      sekme acilip aramayi actiginda tuketilir. */
  const [receteIlacAra, setReceteIlacAra] = useState(false);
  /** Kart her KAYDEDILDIGINDE artar - ozet sekmesi (bulgu metni, kontrol
      listesi) kaydedilmis veriden tazelenir; karti yeniden yuklemez. */
  /** Kart KENDİ ekran sekmesinde mi (kartSekmesiVar + sekmeler açık): yeni ve düzenle. */
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const yeniSekmede = kartId !== null && kartSekmesiVar(tanim) && !!ekranSekmesi && !sorgu.get('geri');
  const [kayitSayaci, setKayitSayaci] = useState(0);
  /** SEKMESİZ DÜZEN (mockup v7): band, sol menü (tamamlama + işlemler), sağ sütun - yalnız bu düzende. */
  const sekmesiz = tanim.kaynak === 'muayene' && typeof kartId === 'number' && muayeneDuzeni === 'sekmesiz';
  const hastaBilgisi = useMuayeneHastaBilgisi(sekmesiz ? Number(kartId) : 0, kartTazele * 1000 + kayitSayaci);
  /** SEKMESİZ ÖZET / DETAY (kullanıcı 14.10.2026): seçilmediyse muayene tamamlandıysa özet, değilse detay. */
  const [sekmesizGorunum, setSekmesizGorunum] = useState<'ozet' | 'detay' | null>(null);
  useEffect(() => { setSekmesizGorunum(null) }, [kartId]);
  const etkinGorunum: 'ozet' | 'detay' = sekmesizGorunum
    ?? (Number(hastaBilgisi?.ust?.durum ?? 0) === 3 ? 'ozet' : 'detay');
  /** ANAMNEZ GÖSTERİM / DÜZENLEME (kullanıcı 14.10.2026, vital gibi): null = kendiliğinden -
      şikâyet ya da hikâye doluysa gösterim (yalnız etiketler), boşsa düzenleme. */
  const [anamnezDuzen, setAnamnezDuzen] = useState<boolean | null>(null);
  useEffect(() => { setAnamnezDuzen(null) }, [kartId]);
  /** Kendiliğinden kip YÜKLEMEDE bir kez belirlenir - yazarken alan dolunca gösterime atlamasın. */
  const anamnezIlk = useRef<{ id: unknown; duzen: boolean } | null>(null);
  /** FİZİK MUAYENE GÖSTERİM / DÜZENLEME (kullanıcı 15.10.2026, anamnez gibi): null = kendiliğinden -
      bulgu girilmiş satır varsa gösterim (mockup v7 sade tablo), yoksa düzenleme. */
  const [fizikDuzen, setFizikDuzen] = useState<boolean | null>(null);
  useEffect(() => { setFizikDuzen(null) }, [kartId]);
  const fizikIlk = useRef<{ id: unknown; duzen: boolean } | null>(null);
  /** TANI / İSTEM / REÇETE ÇERÇEVE KİPLERİ (kullanıcı 15.10.2026: "aynı deseni yap"): seçilmediyse
      açılışta bir kez - dolu bölüm gösterim, boş bölüm düzenleme. */
  const [kipler, setKipler] = useState<Record<string, boolean>>({});
  useEffect(() => { setKipler({}) }, [kartId]);
  const kipIlk = useRef<{ id: unknown; m: Record<string, boolean> }>({ id: null, m: {} });
  const kipOku = (ad: string, dolu: boolean | null) => {
    if (kipIlk.current.id !== kartId) kipIlk.current = { id: kartId, m: {} };
    if (dolu !== null && !(ad in kipIlk.current.m)) kipIlk.current.m[ad] = !dolu;
    return kipler[ad] ?? kipIlk.current.m[ad] ?? true;
  };
  const kipYaz = (ad: string) => (v: boolean) => setKipler(k => ({ ...k, [ad]: v }));
  /** SEKMESİZ GÖRÜNÜRLÜK (kullanıcı 15.10.2026): şikâyet/hikâye, tanı, değerlendirme her zaman
      ortada; diğerleri VERİSİ VARSA ortada, yoksa yalnız sol menüden açılınca. Açılan bölüm bu
      kart için açık kalır. Doluluk bölüm çizilirken öğrenilir (gizli bölüm de çizilir). */
  const [acikBolumler, setAcikBolumler] = useState<ReadonlySet<string>>(new Set());
  useEffect(() => { setAcikBolumler(new Set()) }, [kartId]);
  const bolumGorunur = (k: string, dolu: boolean) => dolu || acikBolumler.has(k);
  const bolumAc = (k: string) => setAcikBolumler(a => a.has(k) ? a : new Set(a).add(k));
  const dolulukRef = useRef<{ rapor: boolean; sevk: boolean }>({ rapor: false, sevk: false });
  const [doluluk, setDoluluk] = useState({ rapor: false, sevk: false });
  useEffect(() => {
    const d = dolulukRef.current;
    if (d.rapor !== doluluk.rapor || d.sevk !== doluluk.sevk) setDoluluk({ ...d });
  });
  /** Sol menüden açılan patoloji istemi (sekmesiz) ve kaydedilince istem listesinin tazelenmesi. */
  const [patolojiIstemAcik, setPatolojiIstemAcik] = useState(false);
  const [istemTazele, setIstemTazele] = useState(0);
  /** İstem sayısı (istem bölümü yüklenince) - açılış kipi için. */
  const [istemSayisi, setIstemSayisi] = useState<number | null>(null);
  useEffect(() => { setIstemSayisi(null) }, [kartId]);
  /** Reçete kartının dış kaydet bağlantısı (çerçeve 💾). */
  const receteKaydetRef = useRef<(() => Promise<void>) | null>(null);
  /** Kartı kapatmadan, değişiklik varsa kaydeder (istem / reçete çerçevesi 💾). */
  const kartiKaydetKal = () => { void kartKaydetRef.current?.() };
  /** Sekmesizde değerlendirme / sonuç çerçevesinin reçeteden sonraki yeri (portal hedefi). */
  const [degerlendirmeYeri, setDegerlendirmeYeri] = useState<HTMLDivElement | null>(null);
  const [kontrol, setKontrol] = useState<KontrolMaddesi[] | null>(null);
  useEffect(() => {
    if (!sekmesiz) return;
    let iptal = false;
    void api.muayeneTamamlamaKontrol(Number(kartId))
      .then(y => { if (!iptal) setKontrol(y.kontroller) }).catch(() => {});
    return () => { iptal = true };
  }, [sekmesiz, kartId, kartTazele, kayitSayaci]);
  // GÖZ KARTI v4: sol gezinti durumları + kontrol listesi (kayıt / tazeleme ile yenilenir).
  const gozKontrol = useGozKontrol(tanim.kaynak === 'goz-muayene' && typeof kartId === 'number' ? kartId : 0,
                                   kartTazele * 1000 + kayitSayaci);
  // GÖZ KARTI BAŞLIĞI (kullanıcı): kayıt numarası yerine hasta no + protokol no.
  const [gozBaslik, setGozBaslik] = useState<{ h: string; p: string; ad: string; dr: string } | null>(null);
  useEffect(() => {
    setGozBaslik(null);
    if (tanim.kaynak !== 'goz-muayene' || typeof kartId !== 'number') return;
    api.gozMuayeneSeridi(kartId).then(y => setGozBaslik({ h: y.kimlik.hastaNo, p: y.kimlik.protokol, ad: y.kimlik.hasta, dr: y.kimlik.hekim })).catch(() => {});
  }, [tanim.kaynak, kartId]);
  // GÖZLÜK REÇETESİ v2: kaynak (hasta bandı, başlık rozetleri, "değerleri al", önceki reçeteler).
  const gozlukKaynak = useGozlukKaynak(tanim.kaynak === 'goz-gozluk-recete',
    typeof kartId === 'number' ? { receteId: kartId }
      : { hastaId: Number(sorgu.get('hastaId') ?? 0) || undefined, muayeneId: Number(sorgu.get('muayeneId') ?? 0) || undefined },
    kartTazele * 1000 + kayitSayaci);
  // GÖZ GÖRÜNTÜLEME v2 (974): hasta bandı, rozetler, görüntü / ölçüm / karşılaştırma sekmeleri tek uçtan.
  const gorOnizleme = useGoruntulemeOnizleme(tanim.kaynak === 'goz-goruntuleme' && typeof kartId === 'number' ? kartId : null,
    kartTazele * 1000 + kayitSayaci);
  // GÖZ CİHAZI (978): mesaj günlüğü ve kalibrasyon sekmeleri tek uçtan beslenir
  //   (listedeki önizlemenin AYNI ucu - iki ayrı sorgu iki ayrı sayı üretirdi).
  const cihazOnizleme = useGozCihazOnizleme(
    tanim.kaynak === 'goz-cihaz' && typeof kartId === 'number' ? kartId : null,
    kartTazele * 1000 + kayitSayaci);
  /** Mesajı yeniden işler ve sekmeyi tazeler (ham kayıt değişmez, 703). */
  const cihazMesajIsle = async (mesajId: number) => {
    await aksiyon('goz.mesaj-isle', { id: mesajId } as ListeSatiri);
    setKartTazele(t => t + 1);
  };
  /** Bağlantı sınaması: sonuç cihaza yazılır, sekme tazelenir. */
  const cihazSina = async (id: number) => {
    await aksiyon('goz.cihaz-sina', { id } as ListeSatiri);
    setKartTazele(t => t + 1);
  };

  // GÖRÜNTÜ SONUÇLARI penceresi (göz kartı araç çubuğu): muayene id'si (goz görüntüleme / belge için).
  const [gozGoruntuModal, setGozGoruntuModal] = useState<number | null>(null);
  const gozTamamla = async () => {
    if (kartKaydetRef.current && !(await kartKaydetRef.current())) return;
    await aksiyon('goz.muayene-tamamla', { id: Number(kartId) } as ListeSatiri);
  };
  const { aksiyonVar } = useOturum();
  /** METİN MAKROLARI (931): bölüm/doktor şablonları + kurum makroları. Kart
      tazelenince yeniden okunur (şablon uygulanınca kapsam değişebilir). */
  const [makrolar, setMakrolar] = useState<Makro[]>([]);
  // Yeni / düzenlenen makro (kendi sekmesinde) kaydedilince muayenedeki liste tazelenir.
  const [makroTazele, setMakroTazele] = useState(0);
  useEffect(() => {
    const dinle = (e: Event) => { if ((e as CustomEvent<string>).detail === 'metin-makro') setMakroTazele(t => t + 1) };
    window.addEventListener(LISTE_TAZELE_OLAYI, dinle);
    return () => window.removeEventListener(LISTE_TAZELE_OLAYI, dinle);
  }, []);
  const muayeneKarti = tanim.kaynak === 'muayene' && kartId !== null && kartId !== 'yeni';
  useEffect(() => {
    if (!muayeneKarti) { setMakrolar([]); return }
    let iptal = false;
    void api.muayeneSablonTercihleri(Number(kartId))
      .then(y => { if (!iptal) setMakrolar(y.makrolar) })
      .catch(() => { /* makro yoksa kısayol açılmaz, yazım etkilenmez */ });
    return () => { iptal = true };
  }, [muayeneKarti, kartId, kartTazele, makroTazele]);

  if (kartId === null || !tanim.kartYolu || tanim.ozelKart) return null;

  return (
    <>
      {gozGoruntuModal !== null && typeof kartId === 'number' && (
        <Modal baslik={`🖼 ${c('Görüntü Sonuçları')}`} enUst onKapat={() => setGozGoruntuModal(null)}
               alt={<button type="button" className="d" onClick={() => setGozGoruntuModal(null)}>{c('Kapat')}</button>}>
          <GozGoruntulerSekmesi id={kartId} muayeneId={gozGoruntuModal} yenile={kartTazele} />
        </Modal>
      )}
      {cihazKapat && kartId !== null && kartId !== 'yeni' && (
        <CihazKapatModali id={Number(kartId)} onKapat={() => setCihazKapat(false)}
          onTamam={n => { setCihazKapat(false); setKartTazele(t => t + 1);
                          void mesaj(n > 0 ? `Kapatma eklendi. Bu aralıkta ${n} randevu var - taşınması gerekiyor.` : 'Kapatma eklendi.') }} />
      )}
      {gebeHasta && (
        <GebeIzlemModali hastaId={gebeHasta.id} hastaAdi={gebeHasta.ad}
                         onKapat={() => setGebeHasta(null)} />
      )}
      {izlemHasta && (
        <CocukIzlemModali hastaId={izlemHasta.id} cocukAdi={izlemHasta.ad}
                          onKapat={() => setIzlemHasta(null)} />
      )}
      {asiHasta && (
        <AsiUygulaModali hastaId={asiHasta.id} hastaAdi={asiHasta.ad}
                         onKapat={() => setAsiHasta(null)} />
      )}
      {enabizMesaj && (
        <EnabizMesajModali hastaId={enabizMesaj.hastaId} hastaAdi={enabizMesaj.hastaAdi}
                           belgeId={enabizMesaj.belgeId} onKapat={() => setEnabizMesaj(null)} />
      )}
      {istem !== null && (
        <IstemSepetiModal muayeneId={istem}
          baslangicSekme={tanim.kaynak === 'goz-muayene' ? 'goz' : undefined}
          onKapat={() => setIstem(null)}
          onBitti={() => setKartTazele(t => t + 1)} />
      )}
      {dikteAcik && (
        <MuayeneDikte
          hedefler={[{ ad: 'sikayet', baslik: 'Şikâyet' },
                     { ad: 'hikaye', baslik: 'Hikâye' },
                     { ad: 'karar', baslik: 'Değerlendirme / Sonuç' }]}
          degerOku={ad => dikteKaynak.current?.oku(ad) ?? ''}
          onYaz={(ad, v) => {
            // Muayene sekmesi hic cizilmediyse yazici yok (kart baska sekmede acildi).
            if (!dikteKaynak.current) { mesaj('Önce Muayene sekmesini açın.'); return }
            dikteKaynak.current.yaz(ad, v);
          }}
          onKapat={() => setDikteAcik(false)} />
      )}
      {raporModal && (
        <MuayeneRaporModal muayeneId={raporModal.muayeneId} ilkTur={raporModal.tur}
          onKapat={() => setRaporModal(null)}
          onKaydedildi={() => setKartTazele(t => t + 1)} />
      )}
      {ozetModal !== null && (
        <MuayeneOzetiModal muayeneId={ozetModal} onKapat={() => setOzetModal(null)} />
      )}
      <GenForm
        kaynak={tanim.kaynak}
        id={kartId}
        kaydetBagla={f => { kartKaydetRef.current = f }}
        // KART KENDİ SEKMESİNDE: çerçevesiz, ilk alana odak; sekme başlığı = kaydın adı.
        sayfaKipi={yeniSekmede}
        // HASTA KARTI: Sil ve Hesap İcmali kartta yok (kullanıcı 14.10.2026) - listede durur.
        silYok={tanim.kaynak === 'hasta'}
        onYuklendi={yeniSekmede ? d => {
          // SEKME BAŞLIĞI = kaydın adı: unvan, ad + soyad, sonra kaynakların ortak ad alanları;
          //   hiçbiri yoksa "Randevu Kartı #30" (kart adı + kayıt no).
          const metin = (x: unknown) => String(x ?? '').trim();
          const ad = metin(d.unvan) || [d.ad, d.soyad].map(metin).filter(Boolean).join(' ')
            || metin(d.hastaAdi) || metin(d.tarafUnvan) || metin(d.adi) || metin(d.baslik) || metin(d.konu)
            || metin(d.vakaNo) || metin(d.belgeNo) || metin(d.gonderimNo) || metin(d.kisayol) || metin(d.kod)
            || (kartId !== 'yeni' ? `${kartAdi(tanim)} #${kartId}` : '');
          if (ad) ekranSekmesi!.baslik(ad, `${tanim.kartYolu}/${kartId}`);
        } : undefined}
        // GÖZ KARTI v4 (mockup goz_muayene_karti_v4): solda aşamalı gezinti, sağda OD/OS
        //   özeti, altta tamamlama koşulları - yalnız kayıtlı kartta.
        sekmeGruplari={tanim.kaynak === 'goz-muayene' ? GOZ_SEKME_GRUPLARI : undefined}
        // Başlık rozetleri (kullanıcı): H hasta no · P protokol no.
        // DÖF (1050): başlıkta '#id' yok - numara baslikEk rozetinde.
        baslikRozet={(tanim.kaynak === 'kys-dof' || tanim.kaynak === 'kys-denetim') && kartId !== 'yeni' ? <></> : tanim.kaynak === 'goz-goruntuleme' && gorOnizleme ? (
          <>
            {String(gorOnizleme.kayit.hastaNo ?? '') && <span className="rozet gri" title={c('Hasta no')}>No {String(gorOnizleme.kayit.hastaNo)}</span>}
            {String(gorOnizleme.kayit.protokol ?? '') && <span className="rozet gri" title={c('Protokol no')}>Prt {String(gorOnizleme.kayit.protokol)}</span>}
            {String(gorOnizleme.kayit.istekHekim ?? '') && <span className="rozet gri" title={c('İsteyen hekim')}>{String(gorOnizleme.kayit.istekHekim)}</span>}
            <span className="rozet">{c(GOZ_TETKIK[Number(gorOnizleme.kayit.tetkik)] ?? '')} · {GOZ_TARAF[Number(gorOnizleme.kayit.goz)] ?? 'OU'}</span>
          </>
        ) : tanim.kaynak === 'goz-gozluk-recete' && gozlukKaynak ? (
          <>
            {gozlukKaynak.hasta?.hastaNo && <span className="rozet gri" title={c('Hasta no')}>No {gozlukKaynak.hasta.hastaNo}</span>}
            {gozlukKaynak.muayene?.protokol && <span className="rozet gri" title={c('Protokol no')}>Prt {gozlukKaynak.muayene.protokol}</span>}
            {gozlukKaynak.muayene?.hekim && <span className="rozet gri" title={c('Hekim')}>{gozlukKaynak.muayene.hekim}</span>}
          </>
        ) : tanim.kaynak === 'goz-muayene' && gozBaslik ? (
          <>
            {gozBaslik.h && <span className="rozet gri" title={c('Hasta no')}>No {gozBaslik.h}</span>}
            {gozBaslik.p && <span className="rozet gri" title={c('Protokol no')}>Prt {gozBaslik.p}</span>}
            {gozBaslik.dr && <span className="rozet gri" title={c('Hekim')}>{gozBaslik.dr}</span>}
          </>
        ) : undefined}
        sekmeDurumu={tanim.kaynak === 'goz-muayene' ? (bas => {
          // ÖZET bir bölüm değil, derleme: durum noktası yerine ikon (kullanıcı).
          if (bas === 'Özet') return { durum: '', ikon: '▤' };
          const d = gozKontrol?.bolumler.find(x => x.baslik === bas);
          return d ? { durum: d.durum, ipucu: d.ipucu } : undefined;
        }) : undefined}
        // İSTEM ROZETİ "3/5" (mockup muayene_karti_v7): sonuçlanan / toplam, iptal sayılmaz.
        detayRozeti={tanim.kaynak === 'muayene'
          ? (ad, satirlar) => {
              if (ad !== 'istemler') return undefined;
              const gecerli = satirlar.filter(r => Number(r.sonucDurum ?? 0) !== 3);
              return gecerli.length === 0 ? undefined
                : `${gecerli.filter(r => Number(r.sonucDurum ?? 0) === 2).length}/${gecerli.length}`;
            }
          : undefined}
        tekSayfa={tanim.kaynak === 'muayene' && muayeneDuzeni === 'sekmesiz'}
        // "Tanı (ICD-10)" ve "Muayene" BAŞLIKLARI YOK (kullanıcı 15.10.2026): çerçevelerin kendi
        //   başlıkları (Tanılar, Anamnez...) yeter.
        tekSayfaBaslikYok={sekmesiz ? b => b.startsWith('Tanı') || sablonMuayeneMi(b)
          // Çerçeveli bölümler (İstemler, Reçete, Raporlar) başlığını çerçevede taşır.
          || b.startsWith('İstem') || b === 'e-Reçete' || b === 'Rapor' : undefined}
        tekSayfaGizli={sekmesiz && etkinGorunum === 'detay' ? b =>
          b.startsWith('İstem') ? !bolumGorunur('istem', (istemSayisi ?? 0) > 0)
          : b === 'Rapor' ? !bolumGorunur('rapor', doluluk.rapor)
          : b.startsWith('Sevk') ? !bolumGorunur('sevk', doluluk.sevk)
          : b.startsWith('İşlem') ? !bolumGorunur('islem', (sekmeVerisi.veri?.islemler.length ?? 0) > 0)
          : b === 'Geçmiş' ? !bolumGorunur('gecmis', (sekmeVerisi.veri?.gecmis.length ?? 0) > 0)
          : b === 'Dosyalar' ? !bolumGorunur('dosyalar', false)
          : b === 'e-Nabız' ? !bolumGorunur('enabiz', false)
          : false : undefined}
        tekSayfaSuzgec={sekmesiz ? a => (a === 'ozel:ozet') === (etkinGorunum === 'ozet') : undefined}
        // SEKMESİZ SOL LİSTE ALTI (mockup v7): bölümü olmayan iki işlem. Rapor, Sevk...
        //   zaten bölüm olarak listede - ikinci kez konmaz.
        // SEKMESİZ SOL MENÜ (kullanıcı): tamamlama maddeleri hem menü hem kontrol, altında işlemler.
        gezintiOzel={sekmesiz
          ? git0 => {
              // Menüden basılan bölüm açılır (boş olsa da) ve oraya gidilir.
              const git = (b: string) => {
                const k = b.startsWith('İstem') ? 'istem' : b === 'e-Reçete' ? 'recete' : b === 'Rapor' ? 'rapor'
                  : b === 'Sevk' ? 'sevk' : b === 'İşlem' ? 'islem' : b === 'Geçmiş' ? 'gecmis'
                  : b === 'Dosyalar' ? 'dosyalar' : b === 'e-Nabız' ? 'enabiz' : null;
                if (k && !acikBolumler.has(k)) { bolumAc(k); setTimeout(() => git0(b), 60) } else git0(b);
              };
              // Bölümü olmayan çerçeveler (vital, fizik): açılır ve çerçeveye kaydırılır.
              const cerceveAc = (k: string) => {
                bolumAc(k);
                if (etkinGorunum === 'ozet') setSekmesizGorunum('detay');
                setTimeout(() => document.querySelector(`.es-govde:not([hidden]) [data-mfr="${k}"]`)
                  ?.scrollIntoView({ behavior: 'smooth', block: 'start' }), 120);
              };
              return (
              <>
                <MuayeneSolMenu kontrol={kontrol}
                  gorunum={etkinGorunum}
                  onGorunum={g => { setSekmesizGorunum(g); setTimeout(() => git(g === 'ozet' ? 'Özet' : 'Muayene'), 60) }}
                  // Özet görünümünde bir bölüme gidilirse önce Detay'a geçilir (bölüm orada).
                  git={b => { if (b !== 'Özet' && etkinGorunum === 'ozet') { setSekmesizGorunum('detay'); setTimeout(() => git(b), 60) } else git(b) }}
                  muayeneyeAl={() => void aksiyon('muayene.al', { id: Number(kartId) })}
                  islemler={[
                    { ad: 'Vital bulgular', ikon: '🫀', ac: () => cerceveAc('vital') },
                    // PATOLOJİK İSTEM (kullanıcı 15.10.2026): istem ikiye - tetkik istemi tamamlamada,
                    //   patolojik istem burada (modül açıksa).
                    ...((kullanici?.moduller ?? []).includes('patoloji')
                      ? [{ ad: 'Patolojik İstem', ikon: '🔬', ac: () => setPatolojiIstemAcik(true) }] : []),
                    { ad: 'Kendime Not', ikon: '📝', ac: () => setNotAcik(true) },
                    { ad: 'Rapor', ikon: '📄', ac: () => git('Rapor') },
                    { ad: 'Sevk', ikon: '↗', ac: () => git('Sevk') },
                    { ad: 'Konsültasyon', ikon: '🤝', ac: () => git('Sevk') },
                    { ad: 'İşlem & Ücret', ikon: '₺', ac: () => git('İşlem') },
                    { ad: 'Geçmiş', ikon: '🕘', ac: () => git('Geçmiş') },
                    { ad: 'Dosyalar', ikon: '📎', ac: () => git('Dosyalar') },
                    { ad: 'e-Nabız', ikon: '🌐', ac: () => git('e-Nabız') },
                    { ad: 'Epikriz', ikon: '📄',
                      bilgi: epikrizDurum === 'imzali' ? c('imzalı') : epikrizDurum === 'taslak' ? c('taslak') : undefined,
                      ac: () => { if (epikrizDurum !== null || epikrizIstendi) git('Epikriz');
                                  else { setEpikrizIstendi(true); setEpikrizGit(n => n + 1) } } },
                  ]} />
                {notAcik && <KendimeNotPenceresi muayeneId={Number(kartId)} onKapat={() => setNotAcik(false)} />}
                {patolojiIstemAcik && <PatolojiIstemModal muayeneId={Number(kartId)} onKapat={() => setPatolojiIstemAcik(false)}
                  onKaydedildi={() => { setPatolojiIstemAcik(false); bolumAc('istem'); setIstemTazele(t => t + 1); setKartTazele(t => t + 1) }} />}
              </>
              );
            }
          : undefined}
        yanPanel={tanim.kaynak === 'goz-muayene' && typeof kartId === 'number'
          ? <GozSagOzet id={kartId} yenile={kartTazele * 1000 + kayitSayaci} />
          : sekmesiz
          ? <MuayeneYanPanel muayeneId={Number(kartId)} bilgi={hastaBilgisi}
                             gecmis={(sekmeVerisi.veri?.gecmis ?? []) as Record<string, unknown>[]}
                             onKopyalandi={() => setKartTazele(t => t + 1)}
                             tazele={kartTazele * 1000 + kayitSayaci} />
          : undefined}
        altSerit={tanim.kaynak === 'goz-muayene'
          ? (git => <GozKuralSeridi kontrol={gozKontrol} sekmeyeGit={git} onTamamla={() => void gozTamamla()} />) : undefined}
        // MUAYENE > ISTEM & SONUCLAR (443): katalogdan gelen bag gridi
        //   "su istem acildi" der; hekimin ihtiyaci SONUCUN KENDISI.
        //   Sarmalayici o sekmenin ALTINA sonuc panelini koyar - gridi
        //   kaldirmadan, cunku "gorduм" isareti ve aciliyet orada duruyor.
        // ÇALIŞMA TAKVİMİ (487): tetkik kartinin "Çalışma Zamanları"
        //   sekmesinde, alanlarin ALTINDA haftalik tablo ve uc ozet kutusu.
        //   Alanlar girdi, takvim SONUC - ikisi ayni sekmede olmali ki
        //   kullanici "bu ayarla sonuc ne zaman cikar" sorusunu kaydetmeden
        //   gorebilsin. Hesap sunucuda.
        // MAKRO IPUCU (kullanici): makro alanlarinin altinda gecerli kisayollar.
        //   Yalniz makro katalogundaki metin alanlari (KartKatalogu
        //   MakroAlanKodlari) - vital/kod alanlarinda kisayol anlamsiz.
        // MAKRO ROZETLİ METİN (kullanıcı 14.10.2026): makro alanları rozet tutabilen kutu; değer düz metin.
        alanGirdisi={muayeneKarti
          ? (ad, d, yaz, salt) => MAKRO_ALANLARI.has(ad)
              ? <MakroluMetin alan={ad} deger={d} yaz={yaz} makrolar={makrolar} salt={salt} /> : undefined
          : undefined}
        alanIpucu={muayeneKarti
          ? (ad, yaz) => MAKRO_ALANLARI.has(ad)
              // ＋ YENİ MAKRO: kart kendi sekmesinde, alan seçili (kart içinden açılan kart yeni sekmede).
              ? <MakroIpucu alan={ad} makrolar={makrolar} yaz={yaz}
                           onYeni={a => git(`/metin-makro/yeni?alan=${encodeURIComponent(a)}`)}
                           // SAĞ TIK = DÜZENLE: kurum makrosu kendi kartında; şablon makrosu şablon kartında.
                           onDuzenle={m => m.kaynak === 'k' && m.id ? git(`/metin-makro/${m.id}`)
                             : mesaj(c('Bu makro bir muayene şablonuna ait - Muayene › Ayarlar › Muayene Şablonları’ndan düzenlenir.'))} /> : null
          : undefined}
        sekmeSarmalayici={tanim.kaynak === 'metin-makro' && kartId !== null
          // METİN MAKROSU KARTI (kullanıcı 14.10.2026): mockup düzeni - kaydet / yetki genel kartta.
          ? (_baslik, _icerik, deger, _izgara, parcalar) => (
              <MetinMakroGovdesi id={kartId} deger={deger} alanDegistir={(ad, v) => parcalar?.alanDegistir(ad, v)} />)
          : tanim.kaynak === 'goz-muayene' && kartId !== 'yeni' && kartId !== null
          // GÖZ MUAYENESİ (970): Tonometri sağında GİB eğilimi, Tanı & Plan sağında tanılar + işler.
          ? (baslik, icerik) => baslik === 'Tonometri & Pakimetri'
              ? <div className="gz-iki"><div>{icerik}</div><GozGibEgilimi id={Number(kartId)} yenile={kartTazele} /></div>
              : baslik === 'Tanı & Plan'
              ? <div className="gz-iki"><div>{icerik}</div><GozTaniPlanPaneli id={Number(kartId)} yenile={kartTazele} /></div>
              : icerik
          : tanim.kaynak === 'kys-dof'
          // DÖF (1050, mockup Kalite2/dof_karti.html): sorun / kök neden ->
          //   faaliyetler -> doğrulama. Varsayılan sıra tabloyu en alta koyardı.
          ? (_baslik, icerik, _d, _izgara, p) => p
              ? <><div className="kys-dof-yanyana">{p.altGrupCiz('Sorun')}</div>{p.tablolar.faaliyetler}<div className="kys-dof-yanyana">{p.altGrupCiz('Doğrulama')}</div></>
              : icerik
          : tanim.kaynak === 'yatis-order'
          // ORDER (968): Order sekmesinin sağında özet (toplam / verilen / sonraki doz).
          ? (baslik, icerik) => baslik === 'Order' && kartId !== 'yeni' && kartId !== null
              ? <div className="od-iki"><div>{icerik}</div><OrderOzetKutusu id={Number(kartId)} yenile={kartTazele} /></div>
              : icerik
          : tanim.kaynak === 'goz-cihaz' && typeof kartId === 'number'
          // GÖZ CİHAZI (978 mockup ③): sağ sütun - durum · son 24 saat ·
          //   tetkik dağılımı · hızlı işlem. GenForm'un `yanPanel`i yalnız
          //   DİKEY gezinti kipinde çiziliyor (sekmeGruplari şart), mockup ise
          //   yatay sekme şeridi istiyor; bu yüzden panel "Tanım" sekmesinin
          //   sağına konuyor. Sayılar listedeki önizlemenin AYNI ucundan gelir.
          ? (baslik, icerik) => baslik === 'Tanım'
              ? <div className="gc-iki"><div>{icerik}</div>
                  <CihazYanPaneli r={cihazOnizleme}
                                  onSina={() => void cihazSina(kartId)}
                                  onDemirbas={id => git(`/demirbas/${id}`)} /></div>
              : icerik
          : tanim.kaynak === 'radyoloji-cihaz'
          // CİHAZ (967): Randevu ayarları altında kapasite, sağında bu hafta ızgarası.
          // Bağlantı testi araç çubuğunda (tek yer).
          ? (baslik, icerik, deger) => baslik === 'Randevu ayarları'
              // SAĞDA "BU HAFTA KAPASİTE" (mockup, kullanıcı): gün x saat boş slot ızgarası.
              ? <div className="rc-randevu"><div>{icerik}<CihazKapasite deger={deger as Record<string, unknown>} /></div>
                  {kartId !== 'yeni' && kartId !== null && <CihazHaftaKapasite id={Number(kartId)} yenile={kartTazele} />}</div>
              : icerik
          : tanim.kaynak === 'radyoloji-protokol'
          // SMS ÖNİZLEME (965): hasta hazırlığı metni randevu SMS'inde nasıl görünür.
          ? (baslik, icerik, deger) => baslik === 'Hasta hazırlığı'
              ? <>{icerik}<SmsOnizleme deger={deger as Record<string, unknown>} /></> : icerik
          : tanim.kaynak === 'lab-tetkik'
          ? (baslik, icerik, deger) => (
              baslik.includes('Çalışma Zamanları')
                ? <>{icerik}<LabCalismaTakvimi deger={deger as CalismaDuzeni} /></>
                : icerik)
          : tanim.kaynak === 'muayene' && kartId !== 'yeni'
          ? (baslik, icerik, deger, izgaraCiz, parcalar, detay) => (
            // MAKRO: bütün muayene sekmelerinde kısayol + boşluk metne açılır.
            <div className="muayene-sekme-zemin"
                 onKeyDownCapture={e => makroTusu(e, makrolar, parcalar?.alanDegistir)}>{
              // "MUAYENE" SEKMESI KALDIRILDI (kullanici 02.10.2026): alanlari Sablon
              //   Muayene'de, tani Tani (ICD-10)'da, recete e-Recete'de, ozet ilk
              //   sekmede (MuayeneOzetSekmesi).
                // "Vital Bulgular" (eski adi "Tani (ICD-10)" - yeniden
                //   baslatilmamis API icin tanınır).
                // TANI (ICD-10) SEKMESI (kullanici: eski haline): tani gridi
                //   ustte + e-Nabiz gonderim bilgisi. Vital izgarasi Sablon
                //   Muayene sekmesinde. "Vital Bulgular" yeniden baslatilmamis
                //   API icin taninir.
                baslik.startsWith('Tanı') ? (() => {
                  // TANI ÇERÇEVESİ (kullanıcı 15.10.2026): gösterimde mockup v7 tablosu - kod · tanı · tür.
                  const veri = parcalar?.detayVerisi('tanilar');
                  const turler = veri?.meta.alanlar.find(a => a.ad === 'tur')?.kodlar ?? {};
                  const satirlar = veri?.satirlar ?? [];
                  return (
                    <KipCercevesi baslik="Tanılar" duzen={kipOku('tani', veri && deger.id != null ? satirlar.length > 0 : null)}
                                  onDuzen={kipYaz('tani')} onKaydet={() => parcalar?.kaydet()}
                                  gosterim={satirlar.length === 0 ? <div className="fm-bos">{c('Tanı girilmedi')}</div> : (
                                    <table className="fm-goster fm-tablo">
                                      <thead><tr><th>{c('Kod')}</th><th>{c('Tanı')}</th><th>{c('Tür')}</th></tr></thead>
                                      <tbody>{satirlar.map((s, i) => (
                                        <tr key={String(s.id ?? i)}>
                                          <td>{i === 0 ? <b>{String(s.icdKod ?? '')}</b> : String(s.icdKod ?? '')}</td>
                                          <td>{String(s.taniAd ?? '')}</td>
                                          <td>{turler[String(s.tur ?? '')] ? <span className="rozet">{turler[String(s.tur)]}</span> : ''}</td>
                                        </tr>))}</tbody>
                                    </table>)}>
                      {icerik}
                    </KipCercevesi>
                  );
                })()
                : baslik === 'Vital Bulgular' ? icerik
                : baslik === 'Rapor' ? (
                  // RAPOR ÇERÇEVESİ (kullanıcı 15.10.2026): ✎ düzenleme (araç çubuğu + grid),
                  //   💾 kaydet ve gösterim - tür · alt tür · başlangıç · süre · no · imza.
                  <KipCercevesi baslik="Raporlar"
                    duzen={kipOku('rapor', detay && deger.id != null ? detay.satirlar.length > 0 : null)}
                    onDuzen={kipYaz('rapor')} onKaydet={kartiKaydetKal}
                    gosterim={(() => {
                      const satirlar = detay?.satirlar ?? [];
                      dolulukRef.current.rapor = satirlar.length > 0;
                      if (satirlar.length === 0) return <div className="fm-bos">{c('Rapor yazılmadı')}</div>;
                      const kod = (ad: string, v: unknown) =>
                        detay?.meta.alanlar.find(a => a.ad === ad)?.kodlar?.[String(v ?? '')] ?? '';
                      return (
                        <table className="fm-goster fm-tablo">
                          <thead><tr><th>{c('Tür')}</th><th>{c('Alt tür')}</th><th>{c('Başlangıç')}</th>
                            <th className="hiza-orta">{c('Süre')}</th><th>{c('Rapor No')}</th><th>{c('İmza')}</th></tr></thead>
                          <tbody>{satirlar.map((s, i) => (
                            <tr key={String(s.id ?? i)}>
                              <td>{kod('tur', s.tur)}</td><td>{kod('altTur', s.altTur)}</td>
                              <td>{s.baslangic ? tarihYaz(String(s.baslangic)) : '—'}</td>
                              <td className="hiza-orta">{Number(s.gun) > 0 ? `${String(s.gun)} ${c('gün')}` : '—'}</td>
                              <td>{String(s.raporNo ?? '') || '—'}</td>
                              <td>{s.imzaZamani ? <span className="rozet olumlu">{c('İmzalı')}</span> : <span className="rozet uyari">{c('Taslak')}</span>}</td>
                            </tr>))}</tbody>
                        </table>
                      );
                    })()}>
                  <>
                    <div className="muayene-arac">
                      <button type="button" className="d"
                              onClick={() => setRaporModal({ muayeneId: Number(kartId), tur: 1 })}>
                        ＋ Rapor
                      </button>
                      <button type="button" className="d"
                              onClick={() => setRaporModal({ muayeneId: Number(kartId), tur: 1 })}>
                        📋 Rapor şablonu ▾
                      </button>
                      <button type="button" className="d sil" title="Rapor Sil"
                              onClick={() => void aksiyon('muayene.raporSil',
                                                          { id: Number(kartId) })}>
                        🗑
                      </button>
                      <button type="button" className="d bir"
                              onClick={() => void aksiyon('muayene.raporImza',
                                                          { id: Number(kartId) })}>
                        ✍ e-İmzala
                      </button>
                    </div>
                    {icerik}
                    <div className="not ic">
                      Türler: istirahat · sağlık durumu · ilaç kullanım (SUT) ·
                      iş göremezlik. Bitiş tarihi başlangıç + süreden hesaplanır;
                      imzalanan rapor değiştirilemez.
                    </div>
                  </>
                  </KipCercevesi>
                )
                : baslik.startsWith('Sevk') ? (
                  // Sevk alanlarinin ALTINDA bu muayeneden istenen
                  //   konsultasyonlar (mockup "Sevk / Konsultasyon").
                  <MuayeneKonsultasyonSekmesi veri={sekmeVerisi.veri}
                                              hata={sekmeVerisi.hata}
                                              icerik={icerik}
                                              // ＋ KONSÜLTASYON İSTE (1107): taslak istek açılır, kart kendi sekmesinde.
                                              onIste={() => void guvenli(async () => {
                                                const y = await api.muayenedenKonsultasyon(Number(kartId));
                                                git(`/konsultasyon/${y.id}`);
                                              })} />
                )
                : (
                  <>
                    {/* FIZIK MUAYENE ARAC CUBUGU (mockup): sablon uygula ve
                        "tumu normal" - ikisi de SUNUCU ucuna gider, satirlari
                        istemci degistirmez. */}
                    {/* TANI: ＋ (ICD ekle) + düzenle/sil TEK BARDA - grid
                        başlığında (kullanıcı). Ayrı üst araç çubuğu kaldırıldı;
                        ＋ artık grid başlığındaki onYeni ile ICD aramayı açar. */}
                    {/* FIZIK MUAYENE (kullanıcı): üstte butonlar; altında
                        "Muayene Şablonu" + "Muayene Bulguları" alanları TEK
                        SATIR (mfz-tek-satir), bulgu grid tam genişlik sola
                        yaslı. */}
                    {sablonMuayeneMi(baslik) && (
                      <>
                        {/* TUMU NORMAL · SABLON UYGULA · SABLON ROZETI artik bulgu
                            gridinin "Bulgu" basliginin SAGINDA (kullanici) -
                            detayGrupta.bulgular.kolonBaslikEk. */}
                        {/* VITAL SAGDA (kullanici: "vital bulgulari sablon
                            muayeneye al"; mockup muayene_karti_v2): solda
                            fizik muayene, sagda muayenenin SON olcumu -
                            duzenlenebilir izgara, gecmis olcumler altta. */}
                        {/* SIKAYET / HIKAYE / PLAN DA BURADA (kullanici: "sikayet/
                            hikayeyi de diger tarafa al"; mockup muayene_karti_v2):
                            solda Anamnez · fizik muayene · Degerlendirme, sagda
                            vital. Ilk sekme derlenmis "Özet". */}
                        {/* TEK SÜTUN, MOCKUP v7 SIRASI (kullanıcı 14.10.2026): şikâyet →
                            hikâye → vital (ölçüm yoksa kapalı) → fizik muayene →
                            değerlendirme. Eskiden vital ve değerlendirme sağ sütundaydı. */}
                        <div className="muayene-ikili msb-ikili msb-tek">
                          <div className="mi-sol">
                            {/* DIKTE KAYNAGI: basliktaki Dikte bu sekmenin GUNCEL
                                alan okuyucu/yazicisini kullanir. Cizime bir sey eklemez. */}
                            {(() => {
                              if (parcalar) dikteKaynak.current = {
                                oku: ad => String(deger[ad] ?? ''), yaz: parcalar.alanDegistir };
                              // Sevk bölümü doluluğu (sekmesiz görünürlük): karar, tesis ya da istenen konsültasyon.
                              dolulukRef.current.sevk = Number(deger.yonlendirme ?? 0) > 0
                                || String(deger.sevkTesisKodu ?? '').trim() !== ''
                                || (sekmeVerisi.veri?.konsultasyonlar.length ?? 0) > 0;
                              return null;
                            })()}
                            {(() => {
                              // ANAMNEZ: gösterimde etiket + düz metin (✎ düzenle); düzenlemede
                              //   alanlar ve 💾 (gösterime döner, değer kartın Kaydet'iyle yazılır).
                              const satirlar = ANAMNEZ_ALANLARI
                                .map(([ad, b]) => [b, String(deger[ad] ?? '').trim()] as const);
                              if (deger.id != null && anamnezIlk.current?.id !== kartId)
                                anamnezIlk.current = { id: kartId, duzen: !satirlar.some(([, v]) => v) };
                              const duzen = anamnezDuzen ?? anamnezIlk.current?.duzen ?? true;
                              if (duzen) return parcalar?.altGrupCiz('Anamnez', {
                                tikla: () => { setAnamnezDuzen(false); parcalar?.kaydet() },
                                ek: <span title={c('Kaydet ve gösterime dön')}>💾</span> });
                              return (
                                <div className="kasira"><div className="kagrup katlanir-kapali">
                                  <h6 className="katlanir-bas" onClick={() => setAnamnezDuzen(true)}>
                                    {c('Anamnez')}<span className="katlanir-sag" title={c('Düzenle')}>✎</span></h6>
                                  <div className="anm-goster">
                                    {satirlar.filter(([, v]) => v).map(([b, v]) => (
                                      <div key={b} className="anm-satir">
                                        <span className="anm-b">{c(b)}</span><span className="anm-d">{v}</span>
                                      </div>
                                    ))}
                                  </div>
                                </div></div>
                              );
                            })()}
                            {(() => {
                              // FİZİK MUAYENE ÇERÇEVESİ (kullanıcı 15.10.2026): sistem sorgusu (şablon
                              //   düğmeleri + bulgu gridi) "Fizik muayene" başlıklı çerçevede. ✎ düzenleme,
                              //   💾 gösterim: yalnız bulgu girilmiş satırlar, sistem + bulgu (mockup v7).
                              const veri = parcalar?.detayVerisi('bulgular');
                              const kodlar = veri?.meta.alanlar.find(a => a.ad === 'sablonAlanId')?.kodlar ?? {};
                              const satirlar = (veri?.satirlar ?? []).map(s => {
                                const metin = String(s.degerMetin ?? '').trim();
                                const sayi = s.degerSayi != null && s.degerSayi !== '' ? String(s.degerSayi) : '';
                                const bulgu = metin || sayi || (Number(s.normal) === 1 ? c('Normal') : '');
                                return { id: String(s.id ?? s.sablonAlanId), sistem: kodlar[String(s.sablonAlanId)] ?? String(s.sablonAlanId ?? ''), bulgu };
                              }).filter(s => s.bulgu);
                              if (veri && deger.id != null && fizikIlk.current?.id !== kartId)
                                fizikIlk.current = { id: kartId, duzen: satirlar.length === 0 };
                              const duzen = fizikDuzen ?? fizikIlk.current?.duzen ?? true;
                              return (
                                // FİZİK MUAYENE SABİT (kullanıcı 15.10.2026): şikâyet / hikâyenin hemen altında,
                                //   dolu da boş da orta alanda.
                                <div data-mfr="fizik">
                                <div className="kasira"><div className={`kagrup${duzen ? '' : ' katlanir-kapali'}`}>
                                  <h6 className="katlanir-bas" onClick={() => { if (duzen) parcalar?.kaydet(); setFizikDuzen(!duzen) }}>
                                    {c('Fizik muayene')}
                                    <span className="katlanir-sag" title={duzen ? c('Kaydet ve gösterime dön') : c('Düzenle')}>
                                      {duzen ? '💾' : '✎'}</span></h6>
                                  {duzen ? <div className="fm-duzen">
                            {/* FIZIK MUAYENE DUGMELERI GRIDIN HEMEN USTUNDE (kullanici). */}
                            <div className="muayene-arac mfz-arac">
                              <button type="button" className="d"
                                      onClick={() => void aksiyon('muayene.normal', { id: Number(kartId) })}>
                                ☑ {c('Tümü normal işaretle')}
                              </button>
                              <button type="button" className="d"
                                      onClick={() => void aksiyon('muayene.sablon', { id: Number(kartId) })}>
                                📋 {c('Şablon Uygula')}
                              </button>
                              {/* Bölüme uygun hazır şablon rozeti - basınca uygular. */}
                              <MuayeneSablonRozeti muayeneId={Number(kartId)}
                                onUygulandi={() => setKartTazele(t => t + 1)} />
                              {/* Vucut semasi SAGA YASLI (kullanici). */}
                              <button type="button" className="d" style={{ marginLeft: 'auto' }}
                                      onClick={() => setVucutAcik(true)}>
                                🧍 {c('Vücut şeması')}
                              </button>
                            </div>
                            <div className="mfz-tek-satir">{parcalar?.tablolar.bulgular ?? icerik}</div>
                                  </div> : satirlar.length > 0 ? (
                                    <table className="fm-goster"><tbody>
                                      {satirlar.map(s => <tr key={s.id}><td>{s.sistem}</td><td>{s.bulgu}</td></tr>)}
                                    </tbody></table>
                                  ) : <div className="fm-bos">{c('Bulgu girilmedi')}</div>}
                                </div></div></div>
                              );
                            })()}
                            {/* VİTAL: fizik muayenenin altında (kullanıcı 15.10.2026), katlanır - ölçüm yoksa kapalı, varsa açık. */}
                            <div className="mi-vital" data-mfr="vital"
                                 hidden={sekmesiz && !bolumGorunur('vital', (parcalar?.detayVerisi('vitaller')?.satirlar ?? [])
                                   .some(r => Object.entries(r).some(([k, v]) => k !== 'id' && !k.endsWith('Id') && v !== null && v !== '' && Number(v) !== 0)))}>
                              {/* Özet kutusuna tıklayınca o ölçünün geçmiş grafiği (kullanıcı 14.10.2026). */}
                              {/* GEÇMİŞ GRAFİĞİ kısayolları vital çerçevesinin İÇİNDE (kullanıcı 14.10.2026). */}
                              {izgaraCiz?.('vitaller', ad => { const k = VITAL_ALAN_GRAFIK[ad]; if (k) setVitalGrafik(k) },
                                <div className="olcum-kisayol">
                                  <span className="not">📈 {c('Geçmiş')}:</span>
                                  {VITAL_GRAFIKLERI.map(([k, ad]) => (
                                    <button key={k} type="button" className="baglanti"
                                            onClick={() => setVitalGrafik(k)}>{c(ad)}</button>
                                  ))}
                                </div>)}
                              {vitalGrafik && <OlcumGrafigi muayeneId={Number(kartId)} secim={{ vital: vitalGrafik }}
                                                            onKapat={() => setVitalGrafik(null)} />}
                            </div>
                            {vucutAcik && (
                              <VucutSemasi muayeneId={Number(kartId)}
                                onKapat={() => setVucutAcik(false)}
                                onKaydedildi={() => setKartTazele(t => t + 1)} />
                            )}
                            {/* DEĞERLENDİRME / SONUÇ EN ALTTA (mockup v7 sırası). SEKMESİZDE REÇETEDEN SONRA
                                (kullanıcı 15.10.2026): reçete ayrı (özel) bölüm - çerçeve oradaki yer
                                tutucuya portal ile çizilir; alanlar ve kayıt bu sekmenin aynısı. */}
                            {(() => {
                              // DEĞERLENDİRME / SONUÇ GÖSTERİM / DÜZENLEME (kullanıcı 15.10.2026, anamnez gibi):
                              //   gösterimde dolu alanlar etiket + değer (kod alanında seçeneğin adı).
                              const AG = 'Değerlendirme / Sonuç';
                              const satirlar = (parcalar?.altGrupAlanlari(AG) ?? []).map(a => {
                                const v = deger[a.ad];
                                const ham = v === null || v === undefined ? '' : String(v).trim();
                                const metin = a.tip === 'kod' ? (ham !== '' ? a.kodlar?.[ham] ?? '' : '')
                                  : a.tip === 'mantik' ? (Number(v) === 1 || v === true ? c('Evet') : '')
                                  : ham;
                                return [a.baslik ?? a.ad, metin] as const;
                              }).filter(([, m]) => m !== '' && m !== '—');
                              const dolu = satirlar.length > 0;
                              const duzen = kipOku('degerlendirme', deger.id != null ? dolu : null);
                              const govde = duzen
                                ? parcalar?.altGrupCiz(AG, {
                                    tikla: () => { kipYaz('degerlendirme')(false); parcalar?.kaydet() },
                                    ek: <span title={c('Kaydet ve gösterime dön')}>💾</span> })
                                : (
                                  <div className="kasira"><div className="kagrup katlanir-kapali">
                                    <h6 className="katlanir-bas" onClick={() => kipYaz('degerlendirme')(true)}>
                                      {c(AG)}<span className="katlanir-sag" title={c('Düzenle')}>✎</span></h6>
                                    {dolu ? (
                                      <div className="anm-goster">
                                        {satirlar.map(([b, m]) => (
                                          <div key={b} className="anm-satir"><span className="anm-b">{c(b)}</span><span className="anm-d">{m}</span></div>
                                        ))}
                                      </div>
                                    ) : <div className="fm-bos">{c('Değerlendirme girilmedi')}</div>}
                                  </div></div>
                                );
                              return sekmesiz && degerlendirmeYeri ? createPortal(govde, degerlendirmeYeri) : govde;
                            })()}
                          </div>
                        </div>
                      </>
                    )}
                    {/* ISTEM & SONUCLAR (mockup): BAG GRIDI CIZILMEZ - hedef
                        tablo/id teknik alanlar, hekime bir sey soylemiyor;
                        "gordum" isareti panelde dugme. Sekme mockup'taki
                        gibi arac cubugu + tek istem tablosu + ayrintilar. */}
                    {sablonMuayeneMi(baslik) ? null
                     : baslik.includes('Sonuç') ? (
                      <KipCercevesi baslik="İstemler" duzen={kipOku('istem', istemSayisi === null ? null : istemSayisi > 0)}
                                    onDuzen={kipYaz('istem')} onKaydet={kartiKaydetKal}
                                    gosterim={<MuayeneIstemSonuc muayeneId={Number(kartId)} gosterim onSayi={setIstemSayisi} tazele={istemTazele} />}>
                        <MuayeneIstemSonuc muayeneId={Number(kartId)} onSayi={setIstemSayisi}
                          tazele={istemTazele} patolojiDugmesiYok={sekmesiz}
                          onIstemAc={() => setIstem(Number(kartId))}
                          onDegisti={() => setKartTazele(t => t + 1)} />
                      </KipCercevesi>
                    ) : icerik}
                  </>
                )
            }</div>
            )
          : undefined}
        // MUAYENE BAGLAM SERIDI (461, mockup muayene_karti.html): hasta,
        //   alerji/kronik, aktif ilac ve bugunun notu her sekmenin ustunde
        //   durur - hekim ilac yazarken alerjiyi ayri sekmede aramamali.
        // DURUM BASLIKTA ROZET (kullanici): alan izgarasinda kutu tutmak
        //   yerine kartin ustunde - hasta/protokol/tarih bilgisi zaten
        //   baglam seridinde, izgara yalnizca YAZILAN alanlara kaliyor.
        // SURUM YERINE DOSYA + PROTOKOL NO (kullanici): numaralar hasta
        //   kutusundan basliga tasindi, teknik surum rozeti muayenede gizli.
        // Sürüm rozeti yok (kullanıcı): muayene + göz kartları; yerinde No / Prt / hekim rozetleri.
        surumGizli={['muayene', 'goz-muayene', 'goz-gozluk-recete', 'goz-goruntuleme'].includes(tanim.kaynak)}
        baslikEk={tanim.kaynak === 'kys-dof' || tanim.kaynak === 'kys-denetim' ? dofBaslikEk : tanim.kaynak === 'muayene'
          ? (d) => {
              const kod = String(d.durum ?? '');
              const ad = MUAYENE_DURUM[Number(kod)] ?? '';
              const sinif = kod === '3' ? 'olumlu' : kod === '0' ? 'gri'
                          : kod === '2' ? 'uyari' : 'mavi';
              return (
                <>
                  <MuayeneBaslikNumaralari muayeneId={Number(d.id ?? 0)} />
                  {ad && <span className={`rozet ${sinif}`}>{ad}</span>}
                  {/* DÜZEN ANAHTARI: seçim tercihe yazılır, sonraki muayeneler de böyle açılır. */}
                  <span className="duzen-anahtar" title={c('Muayene ekranı düzeni')}>
                    <button type="button" className={muayeneDuzeni === 'sekmeli' ? 'on' : ''}
                            onClick={() => duzenDegis('sekmeli')}>▤ {c('Sekmeli')}</button>
                    <button type="button" className={muayeneDuzeni === 'sekmesiz' ? 'on' : ''}
                            onClick={() => duzenDegis('sekmesiz')}>☰ {c('Sekmesiz')}</button>
                  </span>
                </>
              );
            }
          // LAB ISTEM NUMARASI BASLIKTA (kullanici: "kaydedince otomatik
          //   olsun, duzenle diye girince baslikta gorsun"). Numara artik
          //   yazilamiyor - tetikle uretiliyor (641) - ve kimlik seridindeki
          //   yerini Kaynak aldi. Yazilamayan bir numaraya alan izgarasinda
          //   kutu tutmak yerine basligda rozet: yeni kayitta hic cikmaz,
          //   kaydedilince gorunur.
          : tanim.kaynak === 'lab-istem'
          ? (d) => {
              const no = String(d.istemNo ?? '');
              return no ? <span className="rozet mavi">{no}</span> : null;
            }
          : undefined}
        // UYARI BANDI BAGLAM SERIDININ ALTINDA (kullanici): "ana tani
        //   girilmedi", "panik sonuc", "alerji kaydi var" hekim yazmaya
        //   baslamadan gorulmeli - kartin en altinda fark edilmiyordu.
        ustBaglam={sekmesiz
          // BAŞLIK = HASTA BANDI (mockup hasta_bandi / v7) - yalnız sekmesiz düzende.
          ? () => <MuayeneHastaBandi bilgi={hastaBilgisi} />
          : tanim.kaynak === 'muayene' && kartId !== 'yeni'
          ? () => (
            <>
              <MuayeneBaglamSeridi muayeneId={Number(kartId)}
                                   onBugun={() => setMuayeneBilgiAcik(true)} />
              <MuayeneDurumSeridi muayeneId={Number(kartId)} />
            </>
          )
          : undefined}
        // PENCEREDEKI ALAN SIRASI (kullanici): once hekimin sectikleri
        //   (bolum, hekim, tur, isteyen muayene), EN ALTTA sistemin yazdigi
        //   baslama/bitis damgalari. `seritAlanlari` hem listeyi hem SIRAYI
        //   belirler; katalogdaki tanim sirasi degismedi.
        // FIZIK MUAYENE TEK SEKME (mockup muayene_karti.html): "Bulgular"
        //   detayi ayri sekme degil, "Muayene" sekmesinde sablon alanlarinin
        //   ALTINDA - hekim sablonu secip ayni ekranda dolduruyor.
        //   Mockup tablosu UC KOLON (kullanici): Sistem (etiket) · Normal
        //   (kutu) · Bulgu (metin). Sistem satirin kimligidir - satirlar
        //   sablondan acilir, secim kutusu yanlis bir vaat olurdu; deger/taraf
        //   ise mockup'ta yok.
        tazeleAnahtari={kartTazele}
        detaySecenekleri={kartOzel.detaySecenekleri}
        sekmeSirasi={kartOzel.sekmeSirasi}
        // MOCKUP EK SEKMELERI (muayene_karti.html): e-Recete · Sevk /
        //   Konsultasyon · Islem & Ucret · Gecmis · Dosyalar. Icerik gercek
        //   kayitlardan gelir (tek uc: /api/muayene/{id}/sekme-verisi);
        //   yazma islemleri kendi ekranlarinda kalir.
        // MIKRO KATALOG KARTLARININ "Tanım" SEKMESI (mockup
        //   Ekranlar/Lab/besiyeri_karti.html · organizma_karti.html ·
        //   antibiyotik_karti.html): uc mockup'ta da ILK sekme okunur bir
        //   ozettir. Icerik kartin KENDI degerlerinden gelir - ikinci istek
        //   yok, kural yok.
        // RADYOLOJİ ŞABLONU (965): Önizleme · Sürümler · Kullanım (mockup sekmeleri).
        // YENİ KARTTA DA 7 SEKME (kullanıcı: "rapor şablonu mockup'ta 7 sekme var"):
        //   Önizleme girilen içerikle çalışır; Sürümler / Kullanım kayıttan sonra dolar.
        // RADYOLOJİ CİHAZI (967): Doz · Kullanım · Belgeler (kayıtlı cihazda).
        // GÖZLÜK REÇETESİ (972): tek "Reçete" sekmesi (yeni kayıtta da) - değerler kart alanlarına yazılır.
        // ORDER (968): Doz planı · Güvenlik kontrolleri · Geçmiş (kayıtlı order'da).
        // GÖZ MUAYENESİ (970): Karşılaştırma · Görüntüler & Belgeler.
        ekSekmeler={tanim.kaynak === 'goz-cihaz'
          // GÖZ CİHAZI (978 mockup): Tetkikler · Ölçüm eşlemesi (jsonb kolonları
          //   TABLO olarak düzenlenir - kullanıcıya JSON yazdırmak, bir virgül
          //   hatasında cihazın bütün ölçümlerini susturmak demekti) ·
          //   Mesaj günlüğü ve Kalibrasyon (kayıtlı cihazda, salt okuma).
          ? [
              // MOCKUP'TA TEK "Bağlantı" sekmesi var: katalog grubu gizlendi
              //   (gizliKartSekmeleri) ve protokol · adres · MWL alanları bu
              //   sekmede düzenleniyor - iki "Bağlantı" başlığı olsaydı
              //   kullanıcı hangisine bakacağını bilemezdi.
              { anahtar: 'ozel:gc-baglanti', baslik: 'Bağlantı', yenideDe: true,
                ciz: (b) => <BaglantiAyarSekmesi b={b}
                                                 onSina={typeof kartId === 'number'
                                                   ? () => void cihazSina(kartId) : undefined} /> },
              { anahtar: 'ozel:gc-tetkik', baslik: 'Tetkikler', yenideDe: true,
                ciz: (b) => <TetkikEslemeSekmesi b={b} /> },
              { anahtar: 'ozel:gc-esleme', baslik: 'Ölçüm eşlemesi', yenideDe: true,
                ciz: (b) => <OlcumEslemeSekmesi b={b}
                                                cihazId={typeof kartId === 'number' ? kartId : null} /> },
              ...(typeof kartId === 'number'
                ? [
                    { anahtar: 'ozel:gc-mesaj', baslik: 'Mesaj günlüğü',
                      ciz: () => <MesajGunluguSekmesi r={cihazOnizleme}
                                                      onIsle={id => void cihazMesajIsle(id)} /> },
                    { anahtar: 'ozel:gc-kalib', baslik: 'Kalibrasyon',
                      ciz: () => <KalibrasyonSekmesi r={cihazOnizleme}
                                                     onDemirbas={id => git(`/demirbas/${id}`)} /> },
                  ]
                : []),
            ]
          : tanim.kaynak === 'goz-goruntuleme' && typeof kartId === 'number'
          // GÖZ GÖRÜNTÜLEME (974 mockup): Görüntü & ölçümler · Karşılaştırma; Değerlendirme katalog grubu.
          ? [{ anahtar: 'ozel:gg-goruntu', baslik: 'Görüntü & ölçümler', ciz: (b) => <GoruntuOlcumSekmesi r={gorOnizleme} b={b} /> },
             { anahtar: 'ozel:gg-kars', baslik: 'Karşılaştırma', ciz: () => <GoruntulemeKarsilastirmaSekmesi r={gorOnizleme} /> }]
          : tanim.kaynak === 'goz-gozluk-recete'
          ? [{ anahtar: 'ozel:gl-recete', baslik: 'Reçete', yenideDe: true,
               ciz: (b) => <GozlukReceteFormu b={b} k={gozlukKaynak} kopyaId={Number(sorgu.get('kopya') ?? 0) || null} /> }]
          : tanim.kaynak === 'goz-muayene' && kartId !== 'yeni' && kartId !== null
          ? [
              // SÜREÇ v2 (goz_sureci_v2): genel muayenenin sekmeleri göz kartında - aynı veri.
              // v4: kart ÖZET ile açılır (genel muayenenin Özet sekmesinin göz karşılığı).
              { anahtar: 'ozel:gz-ozet', baslik: 'Özet',
                ciz: (b) => <GozOzetSekmesi id={Number(kartId)} kontrol={gozKontrol} yenile={kartTazele * 1000 + kayitSayaci}
                                            sekmeyeGit={b.sekmeyeGit} onTamamla={() => void gozTamamla()} /> },
              { anahtar: 'ozel:gz-oyku', baslik: 'Şikâyet & Öykü',
                ciz: (b) => <GozOykuV4Sekmesi id={Number(kartId)} hastaId={Number(b.deger.hastaId ?? 0)} yenile={kartTazele} /> },
              { anahtar: 'ozel:gz-tani', baslik: 'Tanılar',
                ciz: (b) => <GozTaniSekmesi id={Number(kartId)} muayeneId={Number(b.deger.muayeneId ?? 0)} yenile={kartTazele}
                                            icdAc={mid => (icdAc ? icdAc(mid) : setIcdAramaAcik(true))} /> },
              { anahtar: 'ozel:gz-recete', baslik: 'e-Reçete',
                ciz: (b) => <GozReceteSekmesi muayeneId={Number(b.deger.muayeneId ?? 0)} yenile={kartTazele}
                                              tazele={() => setKartTazele(t => t + 1)} /> },
              { anahtar: 'ozel:gz-istem', baslik: 'İstem & Sonuç',
                ciz: (b) => <MuayeneIstemSonuc muayeneId={Number(b.deger.muayeneId ?? 0)}
                                               onIstemAc={() => setIstem(Number(b.deger.muayeneId ?? 0))}
                                               onDegisti={() => setKartTazele(t => t + 1)} /> },
              { anahtar: 'ozel:gz-ucret', baslik: 'İşlem & Ücret', ciz: (b) => <GozUcretSekmesi muayeneId={Number(b.deger.muayeneId ?? 0)} yenile={kartTazele} /> },
              { anahtar: 'ozel:gz-kars', baslik: 'Karşılaştırma', ciz: () => <GozKarsilastirmaSekmesi id={Number(kartId)} yenile={kartTazele} /> },
              { anahtar: 'ozel:gz-gor', baslik: 'Görüntüler',
                ciz: (b) => <GozGoruntulerSekmesi id={Number(kartId)} muayeneId={Number(b.deger.muayeneId ?? 0)} yenile={kartTazele} /> },
            ]
          : tanim.kaynak === 'yatis-order' && kartId !== 'yeni' && kartId !== null
          ? [
              { anahtar: 'ozel:od-plan', baslik: 'Doz planı', ciz: () => <OrderPlanSekmesi id={Number(kartId)} yenile={kartTazele} /> },
              { anahtar: 'ozel:od-guv', baslik: 'Güvenlik kontrolleri', ciz: () => <OrderGuvenlikSekmesi id={Number(kartId)} yenile={kartTazele} /> },
              { anahtar: 'ozel:od-gecmis', baslik: 'Geçmiş', ciz: () => <OrderGecmisSekmesi id={Number(kartId)} yenile={kartTazele} /> },
            ]
          : tanim.kaynak === 'radyoloji-cihaz' && kartId !== 'yeni' && kartId !== null
          ? [
              { anahtar: 'ozel:rc-doz', baslik: 'Doz', ciz: () => <CihazDozSekmesi id={Number(kartId)} /> },
              { anahtar: 'ozel:rc-kul', baslik: 'Kullanım', ciz: () => <CihazKullanimSekmesi id={Number(kartId)} /> },
              { anahtar: 'ozel:rc-belge', baslik: 'Belgeler',
                ciz: () => <DokumanGalerisi kartAdi="radyoloji-cihaz" kaynakId={Number(kartId)} saltOkunur={false} /> },
            ]
          : tanim.kaynak === 'radyoloji-sablon' && kartId !== null
          ? [
              { anahtar: 'ozel:rt-oniz', baslik: 'Önizleme', yenideDe: true, ciz: baglam => <SablonOnizlemeSekmesi baglam={baglam} /> },
              { anahtar: 'ozel:rt-surum', baslik: 'Sürümler', yenideDe: true,
                ciz: () => kartId === 'yeni' ? <KayitSonraDolar /> : <SablonSurumSekmesi id={Number(kartId)} tazele={() => setKartTazele(t => t + 1)} /> },
              { anahtar: 'ozel:rt-kul', baslik: 'Kullanım', yenideDe: true,
                ciz: () => kartId === 'yeni' ? <KayitSonraDolar /> : <SablonKullanimSekmesi id={Number(kartId)} /> },
            ]
          : labMikroOzetiVar(tanim.kaynak)
            && kartId !== 'yeni' && kartId !== null
          ? [{ anahtar: 'ozel:tanim', baslik: 'Tanım',
               ciz: baglam => <LabMikroOzet kaynak={tanim.kaynak} baglam={baglam} /> }]
          : tanim.kaynak === 'muayene' && kartId !== 'yeni' && kartId !== null
          ? [
              // MUAYENE OZETI ILK SEKME (kullanici, mockup muayene_karti_v2):
              //   yazilanin derlenmis gorunumu + tamamlama kontrolu.
              { anahtar: 'ozel:ozet', baslik: 'Özet',
                ciz: baglam => (
                  <MuayeneOzetSekmesi baglam={baglam} muayeneId={Number(kartId)}
                    sekme={sekmeVerisi.veri} tazele={kartTazele * 1000 + kayitSayaci}
                    eylemler={{
                      muayeneyeAl: () => void aksiyon('muayene.al', { id: Number(kartId) }),
                      taniEkle: () => setIcdAramaAcik(true),
                      istemAc: () => setIstem(Number(kartId)),
                      ilacEkle: () => setReceteIlacAra(true),
                      epikrizAc: () => { setEpikrizIstendi(true); setEpikrizGit(n => n + 1) },
                    }}
                    epikrizDurum={epikrizDurum} epikrizGit={epikrizGit}
                    solMenude={muayeneDuzeni === 'sekmesiz'} />
                ) },
              // e-RECETE YINE AYRI SEKME (kullanici 02.10.2026: "recete
              //   sekmesini geri getir") - Muayene sekmesinden alindi.
              { anahtar: 'ozel:recete', baslik: 'e-Reçete',
                ciz: () => (<>
                  {/* REÇETE ÇERÇEVESİ (kullanıcı 15.10.2026): ✎ reçete kartı, 💾 reçete + muayene kaydı.
                      Sekmesizde reçete yoksa yalnız menüden açılınca görünür (değerlendirme aynı bölümde, hep görünür). */}
                  <div data-mfr="recete" hidden={sekmesiz && !bolumGorunur('recete', !!sekmeVerisi.veri && (() => {
                    const r = gosterilenRecete(sekmeVerisi.veri);
                    return !!r && sekmeVerisi.veri.receteSatirlari.some(s => Number(s.receteId) === Number(r.id)) })())}>
                  <KipCercevesi baslik="Reçete"
                    duzen={kipOku('recete', sekmeVerisi.veri ? (() => { const r = gosterilenRecete(sekmeVerisi.veri);
                      return !!r && sekmeVerisi.veri.receteSatirlari.some(s => Number(s.receteId) === Number(r.id)) })() : null)}
                    onDuzen={kipYaz('recete')}
                    onKaydet={() => void (async () => { await receteKaydetRef.current?.(); await kartKaydetRef.current?.() })()}
                    gosterim={<ReceteGosterim veri={sekmeVerisi.veri} />}>
                  <MuayeneReceteSekmesi
                    veri={sekmeVerisi.veri} hata={sekmeVerisi.hata}
                    muayeneId={Number(kartId)}
                    tazele={() => setKartTazele(t => t + 1)}
                    ilacAra={receteIlacAra} kaydetRef={receteKaydetRef}
                    onIlacAraTamam={() => setReceteIlacAra(false)} />
                  </KipCercevesi>
                  </div>
                  {/* Sekmesizde değerlendirme / sonuç çerçevesinin yeri (Muayene bölümünden portal). */}
                  {/* Muayene bölümünün yerleşimi (etiket üstte tek satır, makro çipleri kutunun altında). */}
                  {sekmesiz && <div className="muayene-ikili msb-ikili msb-tek"><div ref={setDegerlendirmeYeri} className="mi-sol" /></div>}
                </>) },
              { anahtar: 'ozel:ucret', baslik: 'İşlem & Ücret',
                ciz: () => <MuayeneUcretSekmesi veri={sekmeVerisi.veri}
                                                hata={sekmeVerisi.hata} /> },
              // e-NABIZ SEKMESI (mockup muayene_enabiz_paneli_v3): dis kurum
              //   kayitlarina ERISIM + hekimin gordugunu aktarmasi + KVKK izi.
              //   Veri bu ekrana GELMEZ; sayfa Bakanlikta acilir - bu yuzden
              //   sekmede tablo degil akis ve kisayollar var.
              { anahtar: 'ozel:enabiz', baslik: 'e-Nabız',
                ciz: baglam => (
                  <MuayeneEnabizSekmesi
                    // MUAYENEDE HASTA ALANI `tarafId` (hasta bir taraftır);
                    //   `hastaId` yalnız bazı kartlarda var.
                    hastaId={Number(baglam.deger.tarafId ?? baglam.deger.hastaId ?? 0)}
                    muayeneId={Number(kartId)}
                    eylemler={{
                      taniEkle: () => setIcdAramaAcik(true),
                      ilacEkle: () => setReceteIlacAra(true),
                    }} />
                ) },
              { anahtar: 'ozel:gecmis', baslik: 'Geçmiş',
                ciz: () => (
                  <MuayeneGecmisSekmesi veri={sekmeVerisi.veri} hata={sekmeVerisi.hata}
                                        muayeneId={Number(kartId)}
                                        tazele={() => setKartTazele(t => t + 1)} />
                ) },
              { anahtar: 'ozel:dosyalar', baslik: 'Dosyalar',
                ciz: () => <DokumanGalerisi kartAdi="muayene"
                                            kaynakId={Number(kartId)}
                                            saltOkunur={false} /> },
              // EPİKRİZ (1100): YALNIZ İSTENİNCE (kullanıcı) - kayıt varsa ya da
              //   Özet › İşlemler › Epikriz'e basıldıysa. Mevcut sekmelere dokunulmaz.
              ...(epikrizDurum !== null || epikrizIstendi ? [{
                anahtar: 'ozel:epikriz', baslik: 'Epikriz',
                ciz: (baglam: EkSekmeBaglami) => (
                  <MuayeneEpikrizSekmesi muayeneId={Number(kartId)} saltOkunur={baglam.saltOkunur}
                                         onDegisti={setEpikrizDurum} />
                ) }] : []),
            ]
          : undefined}
        // VITAL BULGULAR SEKMESI YOK (kullanici): olcum TANI sekmesinin
        //   sag panelinde duzenleniyor - ayni veriyi iki sekmede gostermek
        //   hangisinin gecerli oldugunu belirsiz birakiyordu.
        gizliDetaylar={kartOzel.gizliDetaylar}
        detayGrupta={tanim.kaynak === 'muayene' && kartOzel.detayGrupta?.tanilar
          ? { ...kartOzel.detayGrupta,
              // TANI ＋ = ICD arama (grid başlığında, düzenle/sil ile aynı bar).
              tanilar: { ...kartOzel.detayGrupta.tanilar,
                         yeni: () => setIcdAramaAcik(true) } }
          : tanim.kaynak === 'kys-denetim' && kartOzel.detayGrupta?.bulgular
          // İÇ DENETİM (1061 mockup): her bulgudan tek tıkla DÖF.
          ? { ...kartOzel.detayGrupta,
              bulgular: { ...kartOzel.detayGrupta.bulgular,
                          ekKolon: { baslik: 'DÖF', genislik: 140,
                                     ciz: s => <BulguDofHucresi satir={s} doflar={bulguDoflari} /> } } }
          : kartOzel.detayGrupta}
        detayIzgara={kartOzel.detayIzgara}
        seritAlanlari={kartOzel.seritAlanlari}
        // KIMLIK SERIDI MODALA TASINDI (kullanici): serit kart govdesinde
        //   cizilmez; "Bugun" kutusuna basilinca ayni GenForm alanlariyla
        //   (yani ayni deger/dogrulama/kaydetme yoluyla) pencerede acilir.
        seritSarmalayici={tanim.kaynak === 'goz-goruntuleme' && typeof kartId === 'number'
          ? (serit) => <><GoruntulemeHastaBandi r={gorOnizleme} />{serit}</>
          : tanim.kaynak === 'goz-gozluk-recete'
          // Hasta bandı kimlik şeridinin ÜSTÜNDE (göz kartıyla aynı düzen).
          ? (serit, d) => <><GozlukHastaBandi k={gozlukKaynak} durum={Number(d.durum ?? 1)} />{serit}</>
          : tanim.kaynak === 'goz-muayene' && kartId !== 'yeni' && kartId !== null
          // GÖZ KARTI v4 (kullanıcı): hasta bandı ÜSTTE, muayene türü / dilatasyon bandı altında.
          ? (serit) => <><GozMuayeneSeridi gozMuayeneId={Number(kartId)} yenile={kartTazele} />{serit}</>
          : tanim.kaynak === 'yatis-order' && kartId !== 'yeni' && kartId !== null
          // ORDER (968 mockup): kimlik şeridinin üstünde hasta şeridi (alerji, tanı...).
          ? (serit) => <><OrderHastaSeridi id={Number(kartId)} yenile={kartTazele} />{serit}</>
          : tanim.kaynak === 'muayene' && kartId !== 'yeni'
          ? (serit) => (muayeneBilgiAcik ? (
              <Modal baslik="Muayene bilgileri" dar enUst
                     onKapat={() => setMuayeneBilgiAcik(false)}
                     alt={<button type="button" className="d"
                                  onClick={() => setMuayeneBilgiAcik(false)}>Kapat</button>}>
                <div className="muayene-bilgi">{serit}</div>
              </Modal>
            ) : null)
          : undefined}

        // KART ARAC CUBUGU: muayene (461) ve goz muayenesi (691) kendi
        //   eylemlerini burada gosterir. DUGMELER LISTE AKSIYON KODLARINI
        //   cagirir - kural ve yetki tek yerde kalir; ayni kod hem sag tus
        //   menusunden hem karttan gecer.
        // e-NABIZ DÜĞMESİ HASTA KARTINDA DA (KTS H8): denetim "yer"i ayrıca
        //   soruyor - düğme yalnız muayenede olursa, hastayı kartından açan
        //   hekim aynı işlemi bulamıyor. Hasta kartında mesaj/erişim ikisi
        //   de aynı bileşenle, aynı yerde.
        // CİHAZ KARTI ARAÇ ÇUBUĞU (kullanıcı: "en üstte butonlar eksik", mockup):
        //   bağlantı testi · kapat / bakıma al · takvimde göster.
        // ORDER KARTI ARAÇ ÇUBUĞU (968 mockup): hekim onayı · durdur · doz değiştir · tekrarla.
        // GÖZLÜK REÇETESİ ARAÇ ÇUBUĞU (mockup): imzala · yazdır (A5) · optiğe ver · teslim.
        // GÖZ GÖRÜNTÜLEME ARAÇ ÇUBUĞU (974 mockup): çekildi (ödenmişse) · değerlendir ve imzala · yeniden çekim · yazdır.
        // DÖF (1050 mockup): kaynak kaydına git · DÖF formu (A4).
        ekAraclar={tanim.kaynak === 'kys-dof' ? (d) => <DofAraclari deger={d} />
          : tanim.kaynak === 'kys-denetim' ? (d) => <DenetimAraclari deger={d} />
          : tanim.kaynak === 'kys-toplanti' ? (d) => <ToplantiAraclari deger={d} />
          : tanim.kaynak === 'goz-goruntuleme' && typeof kartId === 'number'
          ? (d) => {
              const durum = Number(d.durum ?? 1), serbest = Number(d.serbest ?? 1);
              const islem = (f: () => Promise<unknown>) => void guvenli(async () => { await f(); setKartTazele(t => t + 1); setYenile(t => t + 1) });
              return (
                <>
                  {durum === 1 && serbest === 0 && <span className="rozet hata" title={c('Bankoda ücretlendirilip başvuru kaydedilmeden çekim yapılamaz')}>{c('Ödeme bekliyor')}</span>}
                  {durum === 1 && serbest === 1 && <button type="button" className="d" onClick={() => islem(async () => {
                    if (kartKaydetRef.current && !(await kartKaydetRef.current())) return;
                    await api.gozGoruntulemeCekildi(kartId);
                  })}>📷 {c('Çekildi')}</button>}
                  {durum === 2 && <button type="button" className="d bir" onClick={() => islem(async () => {
                    if (kartKaydetRef.current && !(await kartKaydetRef.current())) return;
                    if (!await onay(c('Değerlendirme imzalansın mı? İmzadan sonra sonuç değiştirilemez; muayene kartına düşer.'))) return;
                    await api.gozGoruntulemeDegerlendir(kartId);
                  })}>✍ {c('Değerlendir ve imzala')}</button>}
                  {durum === 2 && <button type="button" className="d" onClick={() => void guvenli(async () => {
                    if (!await onay(c('Yeniden çekim istensin mi? Bu çekim iptal edilir, yeni kayıt ücretsiz sıraya düşer.'))) return;
                    const y = await api.gozGoruntulemeYeniden(kartId);
                    git(`/goz-goruntuleme/${y.id}`, { replace: true });
                  })}>↻ {c('Yeniden çekim iste')}</button>}
                  <button type="button" className="d" onClick={() => window.print()}>🖨 {c('Rapor yazdır')}</button>
                </>
              );
            }
          : tanim.kaynak === 'goz-gozluk-recete' && typeof kartId === 'number'
          ? (d) => {
              const durum = Number(d.durum ?? 1);
              const islem = (f: () => Promise<unknown>) => void guvenli(async () => { await f(); setKartTazele(t => t + 1); setYenile(t => t + 1) });
              return (
                <>
                  {durum === 1 && <button type="button" className="d" onClick={() => islem(async () => {
                    if (kartKaydetRef.current && !(await kartKaydetRef.current())) return;
                    if (!await onay(c('Reçete imzalansın mı? İmzadan sonra değerler değiştirilemez.'))) return;
                    await api.gozlukImzala(kartId);
                  })}>✍ {c('İmzala')}</button>}
                  <button type="button" className="d" onClick={() => gozlukYazdir()}>🖨 {c('Yazdır (A5)')}</button>
                  {durum === 2 && <button type="button" className="d" onClick={() => islem(() => api.gozlukDurum(kartId, 3))}>🏪 {c('Optike gönder')}</button>}
                  {(durum === 2 || durum === 3) && <button type="button" className="d" onClick={() => islem(() => api.gozlukDurum(kartId, 4))}>✔ {c('Teslim edildi')}</button>}
                </>
              );
            }
          : kartId !== 'yeni' && kartId !== null && tanim.kaynak === 'yatis-order'
          ? (d) => {
              const id = Number(kartId);
              const dd = d as Record<string, unknown>;
              const aktif = Number(dd.durum) === 1;
              const imzasiz = (dd.sozelOrder === true || Number(dd.sozelOrder) === 1) && !dd.onayTarihi;
              const kopyala = (durdur: boolean) => void guvenli(async () => {
                if (durdur && !await onay('Bu order durdurulup aynı bilgilerle yeni order açılsın mı? Yeni order kartında dozu değiştirip kaydedin.')) return;
                const y = await api.orderKopyala(id, durdur);
                git(`/yatis-order/${y.id}`);
              });
              return (
                <>
                  {imzasiz && <button type="button" className="d" onClick={() => void guvenli(async () => {
                    await api.orderImzala(id); setKartTazele(t => t + 1); void mesaj('Sözel order onaylandı.');
                  })}>✔ Hekim onayı</button>}
                  {aktif && <button type="button" className="d" onClick={() => void guvenli(async () => {
                    if (!await onay('Order durdurulsun mu? Gelecekteki bekleyen dozlar düşer, uygulanmış dozlar kalır.')) return;
                    await api.orderDurdur(id); setKartTazele(t => t + 1);
                  })}>⏸ Durdur</button>}
                  {aktif && <button type="button" className="d" onClick={() => kopyala(true)}>✎ Doz değiştir</button>}
                  <button type="button" className="d" onClick={() => kopyala(false)}>⟳ Tekrarla</button>
                </>
              );
            }
          : kartId !== 'yeni' && tanim.kaynak === 'radyoloji-cihaz'
          ? () => (
              <>
                <button type="button" className="d" onClick={() => void guvenli(async () => {
                  const y = await api.radCihazBaglantiTest(Number(kartId));
                  await mesaj(y.acik ? `✅ ${y.ip}:${y.port} yanıt verdi (${y.ms} ms)` : `❌ ${y.ip}:${y.port} - ${y.hata ?? 'yanıt yok'}`);
                })}>🔌 Bağlantıyı test et</button>
                <button type="button" className="d" onClick={() => setCihazKapat(true)}>⛔ Kapat / bakıma al</button>
                <button type="button" className="d" onClick={() => {
                  randevuTercihiYaz(kullanici?.id, { liste: 'ek', gorunum: 'cihaz' });
                  git('/randevu');
                }}>📅 Takvimde göster</button>
              </>
            )
          : kartId !== 'yeni' && tanim.kaynak === 'hasta'
          ? (d) => {
              const hid = Number(kartId);
              return (
                <>
                  {/* AŞI UYGULAMA (898, KTS H10): doz numarasını sunucu
                      hesaplıyor, ekran yalnız aşıyı ve lotu soruyor. */}
                  {/* GEBE İZLEMİ (900, KTS H10): önce dosya, sonra izlem;
                      hafta sunucudan gelir. */}
                  {aksiyonVar('gebe.izlem') && (
                    <button type="button" className="d"
                            onClick={() => setGebeHasta({
                              id: hid, ad: String(d.unvan ?? d.ad ?? '') })}>
                      🤰 Gebe İzlemi
                    </button>
                  )}
                  {/* ÇOCUK İZLEMİ (899, KTS H10): izlem sırasını sunucu
                      söylüyor, persentil ölçümle birlikte görünüyor. */}
                  {aksiyonVar('cocuk.izlem') && (
                    <button type="button" className="d"
                            onClick={() => setIzlemHasta({
                              id: hid, ad: String(d.unvan ?? d.ad ?? '') })}>
                      👶 Çocuk İzlemi
                    </button>
                  )}
                  {aksiyonVar('asi') && (
                    <button type="button" className="d"
                            onClick={() => setAsiHasta({
                              id: hid, ad: String(d.unvan ?? d.ad ?? '') })}>
                      💉 Aşı Uygula
                    </button>
                  )}
                  <EnabizButonu tur="erisim" hastaId={hid} />
                  <EnabizButonu tur="mesaj" hastaId={hid}
                                onMesaj={() => setEnabizMesaj({
                                  hastaId: hid,
                                  hastaAdi: String(d.unvan ?? d.ad ?? ''),
                                  belgeId: null })} />
                </>
              );
            }
          : kartId !== 'yeni'
                   && (tanim.kaynak === 'muayene' || tanim.kaynak === 'goz-muayene')
          ? (d) => {
              const satir = {
                id: Number(kartId),
                hastaId: Number(d.hastaId ?? d.tarafId ?? 0),
                hastaAdi: String(d.tarafAdi ?? d.hastaAdi ?? gozBaslik?.ad ?? ''),
                // Kisayolla acilacak kayitlar bu muayeneye baglanir.
                muayeneId: Number(d.muayeneId ?? 0),
              };
              const dugme = (kod: string, ad: string, sinif = 'd') => (
                <button key={kod} type="button" className={sinif}
                        onClick={() => void aksiyon(kod, satir)}>{ad}</button>
              );
              return tanim.kaynak === 'muayene' ? (
                <>
                  {dugme('muayene.al', '▶ Muayeneye Al')}
                  {/* SÜREÇ v2: muayenenin göz kartı varsa ona geç. */}
                  <GozKartinaGit muayeneId={Number(kartId)} git={git} />
                  {/* DIKTE (kullanici: "Muayeneye Al sagina"): sikayet / hikaye /
                      degerlendirme serbest metnine ses ile yazim; metin hekim
                      onaylayinca alanin SONUNA eklenir, kayit Kaydet ile. */}
                  <button type="button" className="d" onClick={() => setDikteAcik(true)}>
                    🎤 {c('Dikte')}
                  </button>
                  {/* İstem açma İstem & Sonuçlar sekmesindeki grid başlığında
                      "＋ İstem"; Şablon Uygula da Şablon Muayene sekmesinde var -
                      üstteki tek düğmeler kaldırıldı (kullanıcı). */}
                  {/* MUAYENE ÖZETİ (kullanıcı: "mockup gibi"): sol özet metni +
                      sağ kaynaklar modalı (MuayeneOzetiModal). */}
                  <button type="button" className="d"
                          onClick={() => setOzetModal(Number(kartId))}>📖 Muayene Özeti</button>
                  {/* e-NABIZ MESAJI (877, KTS H7): hekim ekranından hastanın
                      e-Nabız profiline düz metin bilgilendirme. Aksiyon
                      kataloğuna girmiyor - liste satırında değil, KART
                      bağlamında anlamlı (hangi hasta, hangi başvuru). */}
                  {/* e-NABIZ DÜĞMELERİ (KTS H8): görünüm, konum ve ipucu
                      TEK BİLEŞENDE (`EnabizButonu`) - denetim "standarda
                      uygun mu" diye sorduğunda cevap iki ekranda aynı
                      olmalı. Erişim akışı (878) ve mesaj penceresi (877)
                      değişmedi, yalnız düğme ortaklaştı. */}
                  <EnabizButonu key="enabiz.erisim" tur="erisim"
                                hastaId={satir.hastaId} muayeneId={satir.muayeneId || null} />
                  <EnabizButonu key="enabiz.mesaj" tur="mesaj" hastaId={satir.hastaId}
                                belgeId={Number(d.belgeId ?? 0) || null}
                                onMesaj={() => setEnabizMesaj({
                                  hastaId: satir.hastaId, hastaAdi: satir.hastaAdi,
                                  belgeId: Number(d.belgeId ?? 0) || null })} />
                  {/* TAMAMLA ÖNCE KAYDEDER (kullanıcı: "şikayet hikaye girdiğim halde eksik
                      görünüyor"): tamamlama kuralı sunucuda KAYITLI veriye bakar -
                      formda yazılıp kaydedilmemiş alan "eksik" sayılırdı. Kayıt
                      başarısızsa (alan hatası, sürüm çakışması) Tamamla çalışmaz. */}
                  <button key="muayene.tamamla" type="button" className="d onay"
                          onClick={async () => {
                            if (kartKaydetRef.current && !(await kartKaydetRef.current())) return;
                            void aksiyon('muayene.tamamla', satir);
                          }}>✓ Tamamla</button>
                </>
              ) : (
                // GOZ MUAYENESI (mockup goz_detayli_muayene.html araç çubuğu):
                //   hekim ölçümü bitirince buradan çıkış yapıyor.
                <>
                  {/* v4: Tamamla alt şeritte ve Özet'te (koşullarla birlikte). */}
                  <button type="button" className="d"
                          onClick={() => setOzetModal(Number(d.muayeneId ?? 0) || null)}>📖 {c('Muayene özeti')}</button>
                  {/* "Genel muayene" düğmesi kaldırıldı (kullanıcı 05.10.2026). */}
                  {dugme('goz.gozluk-recete', '👓 Gözlük Reçetesi')}
                  {/* GÖRÜNTÜ (kullanıcı): istem yoksa "Görüntü İste" → istem sepeti Göz sekmesi;
                      istem varsa "Görüntü Sonuçları" → görüntü penceresi. */}
                  {(gozKontrol?.goruntuIstem ?? 0) > 0
                    ? <button type="button" className="d" onClick={() => setGozGoruntuModal(Number(d.muayeneId ?? 0))}>
                        🖼 {c('Görüntü Sonuçları')}<span className="b" style={{ marginLeft: 4 }}>{gozKontrol?.goruntuIstem}</span>
                      </button>
                    : <button type="button" className="d" disabled={!Number(d.muayeneId ?? 0)}
                              onClick={() => setIstem(Number(d.muayeneId ?? 0))}>📷 {c('Görüntü İste')}</button>}
                  {dugme('goz.islem-planla', '💉 İşlem Planla')}
                  {dugme('goz.onceki-kopyala', '📋 Önceki Muayeneden Kopyala')}
                  {dugme('goz.sema', '🖼 Göz Şeması')}
                  {dugme('goz.dikte', '🎙 Dikte')}
                </>
              );
            }
          : undefined}
        baslik={kartAdi(tanim)}
        yerTutucuSekmeler={tanim.yerTutucuSekmeler}
        gizliAlanlar={tanim.gizliKartAlanlari}
        gizliSekmeler={tanim.gizliKartSekmeleri}
        zorunluAlanlar={tanim.zorunluKartAlanlari}
        resimYerTutucu={tanim.resimYerTutucu}
        // Takvimden gelen saat/sure (251): URL parametreleri kart varsayilani
        //   olur - kart acilinca alanlar dolu gelir.
        //   Saat secilmeden "Yeni" de suzgecteki bolum / doktoru tasir.
        yeniKayitVarsayilanlari={tanim.kaynak === 'metin-makro' && kartId === 'yeni' && sorgu.get('alan') !== null
          // Muayenedeki ＋'dan: hangi alanın altından açıldıysa o alan seçili gelir.
          ? { ...tanim.yeniKayitVarsayilanlari, alan: sorgu.get('alan')!, durum: 1 }
          : tanim.kaynak === 'randevu' && (sorgu.get('baslangic') || sorgu.get('hekim') || sorgu.get('bolum') || sorgu.get('hastaId'))
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              ...(sorgu.get('baslangic') ? { baslangic: sorgu.get('baslangic')! } : {}),
              ...(sorgu.get('sure') ? { sureDk: Number(sorgu.get('sure')) } : {}),
              ...(sorgu.get('hekim') ? { hekimId: Number(sorgu.get('hekim')) } : {}),
              ...(sorgu.get('bolum') ? { bolum: Number(sorgu.get('bolum')) } : {}),
              ...(sorgu.get('cihaz') ? { cihazId: Number(sorgu.get('cihaz')) } : {}),
              // KONTROL RANDEVUSU (göz süreci v2): muayene Tamamla'dan hasta ön dolu.
              ...(sorgu.get('hastaId') ? { hastaId: Number(sorgu.get('hastaId')) } : {}),
            }
          // GOZ MUAYENESI KISAYOLLARI (691): recete / goruntuleme / islem
          //   karti muayeneden acildiysa hasta ve muayene bagi ON DOLGU
          //   gelir - hekim ayni bilgiyi ikinci kez secmesin, bag da
          //   unutulmasin. Parametre yoksa kart normal bos acilir.
          : GOZ_KISAYOL_KAYNAKLARI.has(tanim.kaynak) && sorgu.get('hastaId')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              hastaId: Number(sorgu.get('hastaId')),
              ...(sorgu.get('muayeneId')
                  ? { muayeneId: Number(sorgu.get('muayeneId')) } : {}),
            }
          // DIS LAB IS EMRI (708, kullanici: "seansta lab is emri basilinca o
          //   hasta adina acilsin"): seans kartindan hasta, hekim, plan satiri
          //   ve dis on dolgu gelir; kaydet/kapat `geri` ile seansa doner.
          : tanim.kaynak === 'dis-lab-isemri' && sorgu.get('hastaId')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              hastaId: Number(sorgu.get('hastaId')),
              ...(sorgu.get('hekimId') ? { hekimId: Number(sorgu.get('hekimId')) } : {}),
              ...(sorgu.get('planSatirId') ? { planSatirId: Number(sorgu.get('planSatirId')) } : {}),
              ...(sorgu.get('disNolar') ? { disNolar: sorgu.get('disNolar')! } : {}),
            }
          // DIS ODEME PLANI (kullanici: odontogramdaki dugme yoksa yeni plan acsin):
          //   plan ve toplam on dolu; kaydet/kapat `geri` ile odontograma doner.
          // HASTA KAYITLARI (alerji / kronik / ilac / gecmis): odontogram ya da baska
          //   ekrandan hasta on dolu acilir; kaydet/kapat `geri` ile doner.
          // CALISMA PLANI (711): plandan acilan istisna/sablon karti hekim on dolu.
          // ISG (741): olay / ziyaret firma ve calisan on dolu (calisan karti, pano).
          : tanim.kaynak.startsWith('isg-') && (sorgu.get('firmaId') || sorgu.get('calisanId'))
          ? { ...tanim.yeniKayitVarsayilanlari, ...(sorgu.get('firmaId') ? { firmaId: Number(sorgu.get('firmaId')) } : {}), ...(sorgu.get('calisanId') ? { calisanId: Number(sorgu.get('calisanId')) } : {}) }
          // KURUMSAL KALİTE (1050): olay / risk / denetim bulgusundan açılan DÖF kaynağı dolu.
          : tanim.kaynak === 'kys-dof' && sorgu.get('kaynakTur')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              kaynakTur: Number(sorgu.get('kaynakTur')),
              ...(sorgu.get('kaynakId') ? { kaynakId: Number(sorgu.get('kaynakId')) } : {}),
              ...(sorgu.get('kaynakNo') ? { kaynakNo: sorgu.get('kaynakNo')! } : {}),
              ...(sorgu.get('birimId') ? { departmanId: Number(sorgu.get('birimId')) } : {}),
              ...(sorgu.get('tanim') ? { tanim: sorgu.get('tanim')! } : {}),
            }
          // KURUMSAL KALİTE (1057): "Yeniden değerlendir" tedarikçi dolu.
          : tanim.kaynak === 'kys-tedarikci' && sorgu.get('tarafId')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              tarafId: Number(sorgu.get('tarafId')),
              ...(sorgu.get('neAliniyor') ? { neAliniyor: sorgu.get('neAliniyor')! } : {}),
            }
          : tanim.kaynak.startsWith('calisma-') && sorgu.get('hekimId')
          ? { ...tanim.yeniKayitVarsayilanlari, hekimId: Number(sorgu.get('hekimId')) }
          : HASTA_KAYIT_KAYNAKLARI.has(tanim.kaynak) && sorgu.get('hastaId')
          ? { ...tanim.yeniKayitVarsayilanlari, hastaId: Number(sorgu.get('hastaId')), ...(sorgu.get('programId') ? { programId: Number(sorgu.get('programId')) } : {}) }
          : tanim.kaynak === 'dis-odeme-plani' && sorgu.get('planId')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              planId: Number(sorgu.get('planId')),
              ...(sorgu.get('toplam') ? { toplam: Number(sorgu.get('toplam')) } : {}),
            }
          : tanim.yeniKayitVarsayilanlari}
        // `geri`: kart baska bir ekrandan (seans) acildiysa kaydet/kapat oraya
        //   doner - liste ekranina dusurmek hekimi seansi yeniden aramaya zorlardi.
        yeniSecilenAdlar={sorgu.get('hastaAd') ? { hastaId: sorgu.get('hastaAd')! } : undefined}
        onBasvuruAc={onBasvuruAc}
        onKapat={() => yeniSekmede ? ekranSekmesi!.kapat() : git(sorgu.get('geri') ?? tanim.kartYolu!)}
        // Hasta: kimlik no kayıtlıysa yeni kart yerine MEVCUT kart açılır (geri yolu korunur).
        onMevcutKayit={mevcutId => { setYenile(t => t + 1); git(`${tanim.kartYolu}/${mevcutId}${sorgu.get('geri') ? `?geri=${encodeURIComponent(sorgu.get('geri')!)}` : ''}`, { replace: true }) }}
        onKaydedildi={(yeniId, acikKal) => {
          // AÇIK KALARAK KAYIT (çerçeve 💾, kullanıcı 15.10.2026: "save etsin ama kapanmasın"):
          //   kart yerinde yeniden yüklenir; yalnız açık liste ve band tazelenir.
          if (acikKal) {
            window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: tanim.kaynak }));
            setKayitSayaci(t => t + 1);
            return;
          }
          // KART KENDİ SEKMESİNDE (yeniSekmede): kaydedince sekme kapanır, KOMŞU sekmeye
          //   dönülür (liste açık değilse açılmaz - kullanıcı); açık liste tazelenir.
          if (yeniSekmede) {
            window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: tanim.kaynak }));
            ekranSekmesi!.kapat();
            return;
          }
          setYenile(t => t + 1);
          setKayitSayaci(t => t + 1);
          // `geri` varsa (seanstan lab is emri) yeni kartta kalmaz, onKapat
          //   geldigi ekrana doner; kart yoluna ara gecis gereksiz gecmis birakirdi.
          // FTR programi (719): yeni kayit ozel karta (uygulama ekle / planla) gecer.
          // ISG (741): yeni calisan kaydedince ozel karta (muayene ac / form gonder).
          // GÖZLÜK REÇETESİ (kullanıcı): muayeneden açıldıysa Kaydet göz muayene kartına döner.
          if (tanim.kaynak === 'goz-gozluk-recete' && sorgu.get('geri')) { git(sorgu.get('geri')!, { replace: true }); return }
          if (kartId === 'yeni' && tanim.kaynak === 'isg-calisan') { git(`/isg-calisan/${yeniId}?geri=${encodeURIComponent(sorgu.get('geri') ?? '/isg-calisan')}`, { replace: true }); return }
          if (kartId === 'yeni' && tanim.kaynak === 'ftr-program') { git(`/ftr-program/${yeniId}?geri=${encodeURIComponent(sorgu.get('geri') ?? '/ftr-program')}`, { replace: true }); return }
          if (kartId === 'yeni' && !sorgu.get('geri')) {
            setOdaklaSonEklenen(t => t + 1);
            git(`${tanim.kartYolu}/${yeniId}`, { replace: true });
          }
        }}
      />
    </>
  );
}
