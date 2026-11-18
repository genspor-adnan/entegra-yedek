import { Fragment, useCallback, useContext, useEffect, useRef, useState } from 'react';
import { ParolaPenceresi } from './radyoloji/ParolaPenceresi';
import { useOturum } from '../kimlik/OturumBaglami';
import { UsbCipIkon } from '../bilesenler/UsbCipIkon';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { gorunumKaydet, gorunumOku, type RadyolojiRaporDuzeni, type RadyolojiRaporGiris } from '../bilesenler/gorunum';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../bilesenler/mesaj';
import { tarihSaat, yasMetni } from '../bilesenler/bicim';
import { Modal } from '../bilesenler/Modal';
import { EImzaModal } from '../bilesenler/eimza/EImzaModal';
import { dosyaIndirUrl } from '../bilesenler/indir';
import { genSignerImzala, utf8Base64 } from '../bilesenler/eimza/genSigner';
import { raporBelgesiHtml } from '../bilesenler/eimza/raporBelgesiHtml';
import type { EImzaAyar, EImzaKart } from '../api/uclar/eimza';
import { HastaSeridi } from '../bilesenler/belge/basvuru/HastaSeridi';
import { c } from '../dil/ceviri';
import { EkranSekmesiBaglami, sekmeAdi } from '../bilesenler/sekmeBaglami';
import { tiradsPuani, tiradsUygula } from './radyoloji/tirads';
import { fleischnerOnerisi, fleischnerUygula } from './radyoloji/fleischner';
import { obstetrikUygula } from './radyoloji/obstetrik';
import { TEK_BASLIK, alanCumleleri, bulguBolumuMu, sonucBolumuMu, tekMetneBolumYaz, tekParcaMi, yerTutucuDoldur } from './radyoloji/raporBicimi';
import { biradsGovdesi, durumOku, metinUret, modaliteKodundan, type BiradsDurumu } from './radyoloji/birads';
import { BiradsFormu } from './radyoloji/BiradsFormu';
import { SablonSecModal, sablonTercihi } from './radyoloji/SablonSecModal';
import { TIPOGRAFI_VARSAYILAN, gomuluBicimTemizle, kaynakAdi, sablonTipografisi, tipografiOku, tipografiOzeti, tipografiStil, type Tipografi } from './radyoloji/tipografi';
import { BicimAracCubugu, BicimliAlan, bicimVarMi, duzdenHtml, htmldenDuz } from '../bilesenler/BicimliMetin';
import { CiktiMenusu } from '../bilesenler/cikti/CiktiMenusu';
import { RadyolojiRaporBelgesi, type RaporCiktiVerisi } from './RadyolojiRaporCikti';


/**
 * RADYOLOJİ RAPORU YAZMA (283/284).
 *
 * Generic karta sığmaz: bölümler ŞABLONDAN üretilir, makrolar imlecin
 * bulunduğu bölüme metin ekler, onay iki aşamalıdır ve onaydan sonra rapor
 * KİLİTLENİR. Düzen mockup ile aynı (Ekranlar/radyoloji_rapor_yaz.html):
 * solda hastanın geçmişi ve istem, ortada bölümler, sağda şablon/makro/skor.
 */
/** `html` (1195): editörün biçimli hali; yoksa düz metinden türetilir (htmlOf). */
interface Bolum { id?: number; sira: number; baslik: string; metin: string;
                  yazdir: number; zorunlu?: number; html?: string }
const htmlOf = (b: Bolum) => b.html ?? duzdenHtml(b.metin);
interface Sablon { id: number; kod: string; ad: string; surum: number;
                   varsayilan: number; tetkigeOzel: number;
                   /** rad.modalite kodu ve yapısal form türü (1194: 1 = BI-RADS). */
                   modalite?: number; yapisalTur?: number;
                   /** 1216: 1 = benim kişisel şablonum, 2 = genel (başkasının kişiseli sunucudan hiç gelmez). */
                   kapsam?: number; bolumSayisi?: number;
                   /** 1343: şablonun biçimi (1 tek, 2 parçalı) ve girişi (1 serbest, 2 yapısal) - uygulanınca ekran buna geçer. */
                   bicim?: number; giris?: number;
                   /** 1344: tipografi üst-seçimi (1 kurum · 2 özel · 3 özgün) ve özel alanlar. */
                   tipografiKaynak?: number; tipFont?: string; tipPunto?: number; tipSatir?: number; tipParagraf?: number; tipHiza?: number }
interface Makro { kisayol: string; ad: string; metin: string; hedefBolum: string }
interface Skor { alanKod: string; alanAd: string; tip: number; secenekler: string;
                 zorunlu: number; raporaBas: number;
                 /** 1217: başlık, metne yazılış kalıbı ({değer}), normal kalıbı, birim, hedef bölüm. */
                 grup?: string; kalip?: string; sifirKalip?: string; birim?: string; hedefBolum?: string }
interface Gecmis { id: number; accessionNo: string; tetkikAdi: string; tarih: string;
                   raporlayan: string; ozet: string;
                   /** Kronolojik görünüm (27.10.2026): modalite adı, rapor durumu (0 yok, 1-3), BI-RADS. */
                   modaliteAdi?: string; raporDurum?: number; birads?: string;
                   /** REVİZE (1374): raporun kaç eski (revize edilmiş) hâli var. */
                   revizeSayisi?: number }
interface Kritik { bulgu: string; bildirilenAd: string; yol: number;
                   bildirimZamani: string; geriBildirim: string; kapatmaZamani?: string | null }
/** Sağ panelde salt okunur açılan önceki tetkik raporu (kullanıcı 13.11.2026). */
interface OncekiGorunum { id: number; yukleniyor: boolean; hata: string; rapor: Record<string, unknown> | null; bolumler: Bolum[];
                         /** REVİZE (1374): raporun eski hâlleri ve panelde hangisi gösteriliyor (null = güncel rapor). */
                         revizeler?: { id: number; revizeNo: number; raporNo: string; revizeTarihi: string | null;
                                       neden: string; revizeEden: string }[];
                         surum?: number | null; guncel?: Bolum[];
                         /** BU TETKİKİN eski hâli (sol listede "Önceki Revizeler"): panel başlığı ve sürüm seçicisi yok. */
                         buTetkik?: boolean; etiket?: string }

type Kayit = Record<string, unknown>;

/**
 * TEK / PARÇALI (kullanıcı 27.10.2026: "daha önce programımızda radyoloji raporu tek parça halinde yazılıyordu..
 * bazı doktorlar o şekilde devam etmek istiyor", "onların şablonları da genelde A4 boyutunda tek sayfa idi").
 * Tek modda rapor TEK BÖLÜM olarak saklanır (başlık TEK_BASLIK, radyoloji/raporBicimi): şema, onay, çıktı, e-Nabız aynı yoldan geçer.
 * Şablon tek modda bölüm başlıkları + varsayılan metinlerle TEK A4 METNİNE birleşir. Onaydaki zorunlu bölüm
 * kuralı şablon bölüm adıyla eşleştiği için tek bölüme uygulanmaz.
 */
/**
 * YEREL TASLAK YEDEĞİ (kullanıcı 14.11.2026: "rapor ekranı zaman zaman refresh oluyor ve yaptığım değişiklikler
 * kayboluyor.. rapor yazımı için çok tehlikeli"): kaydedilmemiş her değişiklik ~1 sn içinde bu bilgisayarın tarayıcı
 * deposuna yazılır; sayfa yenilense / sekme kapansa / tarayıcı çökse de rapor açılınca "kaydedilmemiş taslak bulundu,
 * geri yüklensin mi?" sorulur. Kayıt geçince yedek silinir. Kilitli (onaylı) raporda yedek tutulmaz.
 */
const YEREL_TASLAK = (istemId: number) => `gentegre.rad.taslak.${istemId}`;
interface YerelTaslak {
  zaman: string; bolumler: Bolum[]; duzen: RadyolojiRaporDuzeni; giris: RadyolojiRaporGiris; sablonId: number | null;
  skorDeger: Record<string, string>; nedeniPuan: number; kalitePuan: number;
}
const tekBolum = (metin: string, html?: string): Bolum[] => [{ sira: 1, baslik: TEK_BASLIK, metin, yazdir: 1, zorunlu: 0, html }];
/** Bölümleri tek metne çevirir: basılan her bölüm "BAŞLIK:" satırı + metni, aralarında boş satır. */
const birlestir = (b: Bolum[]): string => b
  .filter(x => x.yazdir !== 0)
  .map(x => `${x.baslik.toLocaleUpperCase('tr')}:\n${x.metin.trim()}`)
  .join('\n\n');
/** Biçimli birleştirme: başlık kalın satır, bölümün biçimi korunur. */
const birlestirHtml = (b: Bolum[]): string => b
  .filter(x => x.yazdir !== 0)
  .map(x => `<div><b>${duzdenHtml(x.baslik.toLocaleUpperCase('tr'))}:</b></div><div>${htmlOf(x)}</div>`)
  .join('<div><br></div>');
/** Şablon iskeletini tek moda çevirir: zaten tek parçaysa (eski HBYS şablonu) olduğu gibi; biçimli bölüm varsa biçim korunur. */
const tekeCevir = (p: Bolum[]): Bolum[] => (tekParcaMi(p) ? p
  : tekBolum(birlestir(p), p.some(x => x.html) ? birlestirHtml(p) : undefined));

/** Sunucudan gelen zaman damgasini "30.08.2026 14:05" olarak yazar. */
function anMetni(d: unknown): string {
  const t = d ? new Date(String(d)) : null;
  if (!t || Number.isNaN(t.getTime())) return '—';
  const p = (n: number) => String(n).padStart(2, '0');
  return `${p(t.getDate())}.${p(t.getMonth() + 1)}.${t.getFullYear()} `
       + `${p(t.getHours())}:${p(t.getMinutes())}`;
}

const RAPOR_DURUM: Record<number, { ad: string; sinif: string }> = {
  1: { ad: 'Taslak',    sinif: 'uyari' },
  2: { ad: 'Ön Rapor',  sinif: 'bilgi' },
  3: { ad: 'Onaylı',    sinif: 'basari' },
};

/** "14:20" (bugün) ya da "27.10 14:20". */
const saatYaz = (t: unknown) => {
  const s = tarihSaat(t as string);
  const bugun = new Date().toLocaleDateString('tr-TR');
  return s.startsWith(bugun) ? s.slice(11) : `${s.slice(0, 5)} ${s.slice(11)}`;
};
/** Uzmana gönderilmeden bu yana: "25 dk", "3 sa", "2 gün". */
const sureYaz = (t: unknown) => {
  const dk = Math.max(0, Math.floor((Date.now() - new Date(String(t)).getTime()) / 60000));
  return dk < 60 ? `${dk} dk` : dk < 1440 ? `${Math.floor(dk / 60)} sa` : `${Math.floor(dk / 1440)} gün`;
};

const KRITIK_YOL: Record<number, string> = {
  1: 'Telefon', 2: 'SMS', 3: 'Yüz yüze', 4: 'e-Posta',
};

/** OBX-13 birinci deger (811) - 0 girilmedi. */
const ISTEM_NEDENI_PUAN = ['', 'Yok', 'Yetersiz', 'Orta', 'İyi', 'Mükemmel'];
/** OBX-13 ikinci deger (811). */
const CEKIM_KALITE_PUAN = ['', 'Çok kötü', 'Kötü', 'Orta', 'İyi', 'Çok iyi'];

export function RadyolojiRapor() {
  const { istemId } = useParams();
  const git = useNavigate();
  const id = Number(istemId) || 0;
  /** Kendi ekran sekmesinde açıldıysa (çalışma listesinden): başlık hasta adı, Kapat sekmeyi kapatır. */
  const ekranSekmesi = useContext(EkranSekmesiBaglami);

  const [istem, setIstem] = useState<Kayit | null>(null);
  const [rapor, setRapor] = useState<Kayit | null>(null);
  // YAZDIRMA BELGESİ: kayıtlı raporun çıktı verisi. Her kayıtta sürüm değişir - belge yeniden okunur,
  //   önizlenen metin kaydedilmiş metin olur.
  const [ciktiVeri, setCiktiVeri] = useState<RaporCiktiVerisi | null>(null);
  const ciktiRaporId = Number(rapor?.id ?? 0);
  const ciktiSurum = String(rapor?.surum ?? '');
  useEffect(() => {
    if (!ciktiRaporId) { setCiktiVeri(null); return }
    let iptal = false;
    api.radyolojiRaporCikti(ciktiRaporId)
      .then(v => { if (!iptal) setCiktiVeri(v as RaporCiktiVerisi) })
      .catch(() => { if (!iptal) setCiktiVeri(null) });
    return () => { iptal = true };
  }, [ciktiRaporId, ciktiSurum]);
  const [bolumler, setBolumler] = useState<Bolum[]>([]);
  /**
   * RAPOR YAZIMI GÖRÜNTÜLEME / DÜZENLEME KİPİ (kullanıcı 17.11.2026: "radyoloji rapor kartında ortadaki rapor yazım
   * kısmını view/edit mode desenine geçir"; ✎ Şablon etiketinin sağında): metni olan kayıtlı rapor
   * görüntülemede açılır, ✎ düzenlemeye alır; boş rapor / yeni şablon düzenlemede. Onaylı (kilitli) raporda ✎ pasif.
   */
  const [raporDuzenle, setRaporDuzenle] = useState(true);
  const [sablonlar, setSablonlar] = useState<Sablon[]>([]);
  const [makrolar, setMakrolar] = useState<Makro[]>([]);
  const [skorlar, setSkorlar] = useState<Skor[]>([]);
  const [skorDeger, setSkorDeger] = useState<Record<string, string>>({});
  const [gecmis, setGecmis] = useState<Gecmis[]>([]);
  // ÖNCEKİ RAPOR SAĞDA (kullanıcı 13.11.2026: "eski bir tetkik tıkladığımda o üste çıkıyor.. kafa karıştırıyor..
  //   liste olduğu gibi kalsın sadece renk highlight olsun ve sağda raporu göreyim"): tıklama kartı DEĞİŞTİRMEZ;
  //   seçili düğüm vurgulanır, raporu sağ panelde salt okunur açılır. Kendi sekmesinde açmak o paneldeki ↗ düğmesi.
  const [onceki, setOnceki] = useState<OncekiGorunum | null>(null);
  const [kritikler, setKritikler] = useState<Kritik[]>([]);
  /** REVİZE (1374): onay iptal engeli (dışarı çıkmış rapor) ve revize geçmişi. */
  const [iptalEngeli, setIptalEngeli] = useState('');
  const [revizeler, setRevizeler] = useState<NonNullable<Awaited<ReturnType<typeof api.radyolojiRapor>>['revizeler']>>([]);
  const [sablonId, setSablonId] = useState<number | null>(null);
  const [sablonModal, setSablonModal] = useState(false);
  /** Son sunucu durumu (yüklenen / kaydedilen) - yerel yedek yalnız bundan farklıysa yazılır. */
  const tabanImza = useRef('');
  const yedekZamanlayici = useRef<number | null>(null);
  // TİPOGRAFİ (1344): kurum ayarı + bu raporun etkin tipografisi; onaylı raporda damga (şablon değişse de kalır).
  const [kurumTipografi, setKurumTipografi] = useState<Tipografi>(TIPOGRAFI_VARSAYILAN);
  const [tipografi, setTipografi] = useState<Tipografi>(TIPOGRAFI_VARSAYILAN);
  const [tipografiDamga, setTipografiDamga] = useState(false);
  const [kritik, setKritik] = useState(false);
  /**
   * BAKANLIK OBX-13 (811): iki AYRI degerlendirme - istemin gerekcesi ve
   * cekimin kalitesi. Ayar kapaliysa alanlar hic gosterilmez.
   */
  const [bakanlikProfili, setBakanlikProfili] = useState(false);
  const [nedeniPuan, setNedeniPuan] = useState(0);
  const [kalitePuan, setKalitePuan] = useState(0);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState('');
  const [kritikModal, setKritikModal] = useState(false);
  // e-İMZA (1337): "e-İmzala" kart + PIN penceresinden geçer; "Onayla" e-imzasız onaydır (17.11.2026, ikisi ayrı düğme).
  const [eimzaModal, setEimzaModal] = useState(false);
  /** e-İmza başkası (seçilen radyolog) adına mı (17.11.2026); kendi adına ise undefined. */
  const [eimzaAdina, setEimzaAdina] = useState<number | undefined>(undefined);
  /** Radyolog şifresi penceresi (onay adına / onay iptali). */
  const [parolaIstek, setParolaIstek] = useState<{ kisi: string; amac: string; coz(p: string | null): void } | null>(null);
  const parolaSor = (kisi: string, amac: string) =>
    new Promise<string | null>(coz => setParolaIstek({ kisi, amac, coz }));
  const { kullanici } = useOturum();
  /** RADYOLOG = radyolog rolü + onay yetkisi (sunucu söyler; kullanıcı 17.11.2026: "sadece radyolog direkt onaylar" -
   *  yönetici de radyolog seçip şifre girer). Okunamazsa false: seçim sorulur, sunucu yine denetler. */
  const [radyologMu, setRadyologMu] = useState(false);
  useEffect(() => {
    let iptal = false;
    Promise.resolve().then(() => api.radyolojiOnayRadyologlari())
      .then(y => { if (!iptal) setRadyologMu(!!y.benRadyolog) }).catch(() => {});
    return () => { iptal = true };
  }, []);
  /** e-İmza hesabı aktif mi (1337): "e-İmzala" düğmesi buna bağlı; okunamazsa null (düğme açık, pencere söyler). */
  const [eimzaAktif, setEimzaAktif] = useState<boolean | null>(null);
  useEffect(() => {
    let iptal = false;
    Promise.resolve().then(() => api.eimzaAyar()).then(a => { if (!iptal) setEimzaAktif(!!a.aktif) }).catch(() => {});
    return () => { iptal = true };
  }, []);
  /**
   * KONSULTASYON (304): ikinci gorus. Istek ve DONEN GORUS ayni yerden
   * yazilir - gorus alanina yazip kaydetmek kaydi "dondu"ye gecirir.
   */
  const [konsultasyonlar, setKonsultasyonlar] = useState<Kayit[]>([]);
  const [konsModal, setKonsModal] = useState(false);
  const [konsForm, setKonsForm] = useState({ hekimId: '', gerekce: '' });
  const [gorusYaz, setGorusYaz] = useState<{ id: number; gorus: string } | null>(null);
  const [kritikForm, setKritikForm] = useState<{ bulgu: string; bildirilenAd: string; yol: number; geriBildirim: string; bildirenId: number | null }>(
    { bulgu: '', bildirilenAd: '', yol: 1, geriBildirim: '', bildirenId: null });
  /** Bildiren combosu (kullanıcı 15.11.2026): rapor yazma yetkili radyologlar, varsayılan oturum kullanıcısı. */
  const [radyologlar, setRadyologlar] = useState<{ id: number; ad: string; ben: number }[]>([]);
  useEffect(() => {
    if (!kritikModal) return;
    let iptal = false;
    // Liste sayfa ömründe değişmez: bir kez çekilir (kod inceleme 15.11.2026), her açılışta yalnız varsayılan atanır.
    const varsayilanAta = (l: { id: number; ad: string; ben: number }[]) =>
      setKritikForm(f => f.bildirenId ? f : { ...f, bildirenId: l.find(x => Number(x.ben) === 1)?.id ?? l[0]?.id ?? null });
    if (radyologlar.length > 0) { varsayilanAta(radyologlar); return }
    api.radyolojiRadyologlar().then(l => { if (iptal) return; setRadyologlar(l); varsayilanAta(l) })
      .catch(() => { if (!iptal) setRadyologlar([]) });
    return () => { iptal = true };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kritikModal]);
  /** Makro hangi bölüme eklenecek: en son dokunulan alan. */
  const sonBolum = useRef<number>(0);
  /** Tek / parçalı: kayıtlı rapor kendi biçiminde açılır; yeni raporda hekimin tercihi (gorunum). */
  const [duzen, setDuzenDurumu] = useState<RadyolojiRaporDuzeni>(() => gorunumOku().radyolojiRaporDuzeni);
  const duzenRef = useRef(duzen);
  const setDuzen = (d: RadyolojiRaporDuzeni) => { duzenRef.current = d; setDuzenDurumu(d) };
  /**
   * GİRİŞ (1194, mockup radyoloji_birads_v2): serbest = hekim yazar; yapısal = BI-RADS formu doldurulur,
   * BULGULAR + SONUÇ formdan üretilir. Yapısal yalnız şablonun formu varsa etkin; yoksa ekran serbest açılır,
   * hekimin tercihi bozulmaz. Kayıtlı rapor kendi girişiyle açılır.
   */
  const [giris, setGiris] = useState<RadyolojiRaporGiris>(() => gorunumOku().radyolojiRaporGiris);
  const [birads, setBiradsDurumu] = useState<BiradsDurumu | null>(null);
  /** Serbest girişte BI-RADS paneli kullanıldı mı - kullanılmadıysa kayda boş kategori yazılmaz (istatistik). */
  const [biradsKullanildi, setBiradsKullanildi] = useState(false);
  const setBirads = (d: BiradsDurumu) => { setBiradsDurumu(d); setBiradsKullanildi(true) };
  /** Yapısal girişte bölüm iskeleti (teknik / klinik / karşılaştırma şablondan); BULGULAR + SONUÇ formdan yazılır. */
  const [parcalar, setParcalar] = useState<Bolum[]>([]);

  // YÜKLEME SIRASI (kod inceleme 30.10.2026 K53): hızlı tetkik geçişinde eski yanıt yeniyi ezmesin -
  //   her yükleme bir sıra numarası alır, araya yeni yükleme girdiyse eski yanıt atılır.
  const yukleSira = useRef(0);
  const yukle = useCallback(async () => {
    const sira = ++yukleSira.current;
    setYukleniyor(true); setHata('');
    try {
      const y = await api.radyolojiRapor(id);
      if (sira !== yukleSira.current) return;
      setIstem(y.istem); setRapor(y.rapor);
      setSablonlar(y.sablonlar as unknown as Sablon[]);
      setMakrolar(y.makrolar as unknown as Makro[]);
      setSkorlar(y.skorlar as unknown as Skor[]);
      setGecmis(y.gecmis as unknown as Gecmis[]);
      setKritikler(y.kritikler as unknown as Kritik[]);
      setIptalEngeli(String(y.iptalEngeli ?? ''));
      setRevizeler(y.revizeler ?? []);
      const konsultasyonlar = await api.radyolojiKonsultasyonlar(id);
      if (sira !== yukleSira.current) return;
      setKonsultasyonlar(konsultasyonlar);
      setKritik(Number(y.istem?.kritik ?? 0) === 1);
      setBakanlikProfili(Boolean(y.bakanlikProfili));
      const kt = tipografiOku(y.kurumTipografi); setKurumTipografi(kt);
      setTipografi(tipografiOku(y.tipografi, kt)); setTipografiDamga(Boolean(y.tipografiDamga));
      setNedeniPuan(Number(y.rapor?.istemNedeniPuan ?? 0));
      setKalitePuan(Number(y.rapor?.cekimKalitePuan ?? 0));

      // AÇILIŞTA OTOMATİK ŞABLON YOK (kullanıcı 14.11.2026: "otomatik şablon gelmiş ama uygun değil.. rapor kısmı boş
      //   gelsin"): yalnız kayıtlı raporun şablonu; yeni rapor boş A4 + "Şablon Seç…" (SablonSecModal).
      const sec = (y.rapor?.sablonId as number | undefined) ?? null;
      setSablonId(sec);
      // BI-RADS: şablonun formu varsa kayıtlı veriden (yoksa boş form).
      const sb = (y.sablonlar as unknown as Sablon[]).find(s => s.id === sec);
      const biradsli = Number(sb?.yapisalTur ?? 0) === 1;
      setBiradsDurumu(biradsli ? durumOku(y.rapor, y.lezyonlar ?? [], modaliteKodundan(sb?.modalite)) : null);
      setBiradsKullanildi(String(y.rapor?.biradsKategori ?? '') !== '');
      const kayitliGiris: RadyolojiRaporGiris | null = y.bolumler.length > 0
        ? (Number(y.rapor?.giris ?? 1) === 2 ? 'yapisal' : 'serbest') : null;
      if (kayitliGiris) setGiris(kayitliGiris);
      const yapisalAcilis = biradsli && (kayitliGiris ?? gorunumOku().radyolojiRaporGiris) === 'yapisal';

      // Rapor varsa bölümleri ondan (biçimi de ondan: tek / parçalı); yoksa şablon iskeletinden.
      if (y.bolumler.length > 0) {
        setDuzen(tekParcaMi(y.bolumler as Kayit[]) ? 'tek' : 'parcali');
        const kb = (y.bolumler as Kayit[]).map(b => ({
          id: Number(b.id), sira: Number(b.sira), baslik: String(b.baslik ?? ''),
          metin: String(b.metin ?? ''), yazdir: Number(b.yazdir ?? 1),
          zorunlu: Number(b.zorunlu ?? 0), html: b.metinHtml ? String(b.metinHtml) : undefined,
        }));
        setBolumler(kb);
        setRaporDuzenle(!kb.some(b => b.metin.trim() !== ''));
        // Yapısal tek parça raporda iskelet şablondan (tek metin bölünemez).
        if (yapisalAcilis) setParcalar(!tekParcaMi(kb) ? kb : sec ? await sablonParcalari(sec, y.istem) : []);
      } else {
        setRaporDuzenle(true);
        if (sec) await sablonUygula(sec, true, y.istem);
      }

      const d: Record<string, string> = {};
      (y.alanlar as Kayit[]).forEach(a => { d[String(a.alanKod)] = String(a.deger ?? '') });
      setSkorDeger(d);
      // YEREL TASLAK: durum yerleşince taban alınır; sunucudan farklı bir yedek varsa sorulur.
      if (sira === yukleSira.current) {
        tabanImza.current = '';
        window.setTimeout(() => void yerelTaslakGeriYukle(Number(y.rapor?.kilit ?? 0) === 1), 50);
      }
    } catch (h) { if (sira === yukleSira.current) setHata(hataMetni(h)) }
    finally { if (sira === yukleSira.current) setYukleniyor(false) }
  // sablonUygula bilerek bagimlilikta degil: ilk yuklemede tek yon calisir.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => { setOnceki(null) }, [id]);

  /** Önceki tetkike tıklama: aynı tetkik ikinci kez tıklanırsa kapanır; değilse raporu sağ panele yükler. */
  const oncekiAc = useCallback(async (g: Gecmis) => {
    if (onceki?.id === g.id) { setOnceki(null); return; }
    setOnceki({ id: g.id, yukleniyor: true, hata: '', rapor: null, bolumler: [] });
    try {
      const y = await api.radyolojiRapor(g.id);
      // Araya başka tıklama girdiyse eski yanıt atılır (K53 ile aynı sebep).
      const bols = (y.bolumler as Kayit[]).map(b => ({
        sira: Number(b.sira), baslik: String(b.baslik ?? ''), metin: String(b.metin ?? ''),
        yazdir: Number(b.yazdir ?? 1), zorunlu: Number(b.zorunlu ?? 0),
        html: b.metinHtml ? String(b.metinHtml) : undefined,
      }));
      setOnceki(o => (o?.id !== g.id ? o : {
        id: g.id, yukleniyor: false, hata: '', rapor: y.rapor, bolumler: bols,
        revizeler: y.revizeler ?? [], surum: null, guncel: bols,
      }));
    } catch (h) {
      setOnceki(o => (o?.id !== g.id ? o : { ...o, yukleniyor: false, hata: hataMetni(h) }));
    }
  }, [onceki?.id]);

  /** BU TETKİKİN önceki revizesi: sol listeden tıklanır, sağ panelde salt okunur (kullanıcı 18.11.2026). */
  const buRevizeAc = useCallback(async (v: { id: number; raporNo: string; revizeTarihi: string | null; neden: string; revizeNo: number; revizeEden: string }) => {
    const pid = -v.id;
    if (onceki?.id === pid) { setOnceki(null); return }
    setOnceki({ id: pid, yukleniyor: true, hata: '', rapor: { raporNo: v.raporNo }, bolumler: [], revizeler: [v],
                surum: v.id, buTetkik: true, etiket: `${c('Bu tetkik')} · ${v.raporNo || `#${v.id}`}` });
    try {
      const y = await api.radyolojiRaporCikti(v.id) as unknown as { bolumler: Kayit[] };
      setOnceki(o => (o?.id !== pid ? o : {
        ...o, yukleniyor: false,
        bolumler: y.bolumler.map(b => ({
          sira: Number(b.sira), baslik: String(b.baslik ?? ''), metin: String(b.metin ?? ''),
          yazdir: 1, zorunlu: 0, html: b.metinHtml ? String(b.metinHtml) : undefined,
        })),
      }));
    } catch (h) {
      setOnceki(o => (o?.id !== pid ? o : { ...o, yukleniyor: false, hata: hataMetni(h) }));
    }
  }, [onceki?.id]);

  /** Önceki raporun ESKİ (revize edilmiş) hâlini panelde göster; null = güncel rapor (1374). */
  const oncekiSurum = useCallback(async (surumId: number | null) => {
    if (!onceki) return;
    if (surumId === null) { setOnceki(o => (o ? { ...o, surum: null, bolumler: o.guncel ?? o.bolumler, hata: '' } : o)); return }
    const oid = onceki.id;
    setOnceki(o => (o ? { ...o, surum: surumId, yukleniyor: true, hata: '' } : o));
    try {
      const v = await api.radyolojiRaporCikti(surumId) as unknown as { bolumler: Kayit[] };
      setOnceki(o => (o?.id !== oid || o.surum !== surumId ? o : {
        ...o, yukleniyor: false,
        bolumler: v.bolumler.map(b => ({
          sira: Number(b.sira), baslik: String(b.baslik ?? ''), metin: String(b.metin ?? ''),
          yazdir: 1, zorunlu: 0, html: b.metinHtml ? String(b.metinHtml) : undefined,
        })),
      }));
    } catch (h) {
      setOnceki(o => (o?.id !== oid ? o : { ...o, yukleniyor: false, hata: hataMetni(h) }));
    }
  }, [onceki]);
  const hastaAdi = String(istem?.hastaAdi ?? '').trim();
  useEffect(() => {
    if (ekranSekmesi && hastaAdi) ekranSekmesi.baslik(sekmeAdi(hastaAdi), `/radyoloji/rapor/${id}`);
  // ekranSekmesi bağlamı sekme ömrü boyunca aynı.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [hastaAdi, id]);

  /**
   * Şablonu uygular: bölüm iskeletini kurar. `ilk` değilse kullanıcıya sorar -
   * yazılmış metnin üstüne şablon basmak emeği siler.
   */
  async function sablonUygula(sId: number, ilk = false, ist: Kayit | null = istem) {
    if (!ilk && bolumler.some(b => b.metin.trim())) {
      if (!(await onay('Şablon yeniden uygulansın mı? Yazılmış bölüm metinleri '
                     + 'şablonun varsayılan metniyle değişir.'))) return;
    }
    const yeniParcalar = await sablonParcalari(sId, ist);
    const sb = sablonlar.find(s => s.id === sId);
    // ŞABLONUN BİÇİMİ VE GİRİŞİ EKRANA YANSIR (1343, kullanıcı 14.11.2026: "ekran biçim tek seçili ama seçtiğimiz şablon
    //   çok parçalı ise burası da çok parçalıya geçsin.. giriş de aynı şekilde"). Hekimin genel tercihi (gorunum)
    //   bozulmaz; yalnız bu rapor şablona uyar.
    const formlu = Number(sb?.yapisalTur ?? 0) === 1;
    const hedefDuzen: RadyolojiRaporDuzeni = Number(sb?.bicim ?? (yeniParcalar.length > 1 ? 2 : 1)) === 2 ? 'parcali' : 'tek';
    const hedefGiris: RadyolojiRaporGiris = Number(sb?.giris ?? 1) === 2 && formlu ? 'yapisal' : 'serbest';
    setParcalar(yeniParcalar);
    setDuzen(hedefDuzen);
    setBolumler(hedefDuzen === 'tek' ? tekeCevir(yeniParcalar) : yeniParcalar);
    setSablonId(sId);
    // Yeni şablonun BI-RADS formu varsa form (yoksa boş) hazırlanır; olmayan şablonda form durumu kalır, kullanılmaz.
    if (formlu && !birads) setBiradsDurumu(durumOku(null, [], modaliteKodundan(sb?.modalite)));
    setGiris(hedefGiris);
    setRaporDuzenle(true);
    if (hedefGiris === 'yapisal') setBiradsKullanildi(true);
    // Makro ve yapılandırılmış alanlar YENİ şablonun (1217) - girilmiş değerler aynı kodlu alanda kalır.
    const m = await api.radyolojiRapor(id, sId);
    setMakrolar(m.makrolar as unknown as Makro[]);
    setSkorlar(m.skorlar as unknown as Skor[]);
    sablonTercihi.sonKullanilanYaz(Number(ist?.hizmetId ?? 0), sId);
    if (!tipografiDamga) setTipografi(sablonTipografisi(sb, kurumTipografi));
    setSablonModal(false);
  }

  /** Şablonsuz serbest yazım (modal "Boş rapor" / boş durumdaki "Serbest yaz"): tek A4; makro / alan şablona ait, gelmez. */
  async function bosRapor() {
    if (bolumler.some(b => b.metin.trim())
        && !(await onay(c('Şablon kaldırılsın mı? Yazılmış metin tek A4 olarak kalır.')))) return;
    setSablonId(null);
    setParcalar([]);
    setRaporDuzenle(true);
    setBolumler(bolumler.length ? tekeCevir(bolumler) : tekBolum(''));
    const m = await api.radyolojiRapor(id);
    setMakrolar(m.makrolar as unknown as Makro[]);
    setSkorlar(m.skorlar as unknown as Skor[]);
    if (!tipografiDamga) setTipografi({ ...kurumTipografi, kaynak: 'kurum' });
    setSablonModal(false);
  }

  /** Modal önizlemesi: şablon iskeleti (yer tutucular bu istemle dolu). useCallback: modal önbelleği effect'e bağlı. */
  const sablonOnizleme = useCallback(async (sId: number) => {
    const y = await api.radyolojiSablonBolumleri(sId);
    return y.map(b => ({ baslik: String(b.baslik ?? ''), metin: yerTutucuDoldur(String(b.varsayilanMetin ?? ''), istem).trim() }));
  }, [istem]);

  /** Şablonun bölüm iskeleti (varsayılan metinlerle). `ist` açıkça verilir: ilk yüklemede state henüz boş. */
  async function sablonParcalari(sId: number, ist: Kayit | null): Promise<Bolum[]> {
    const klinik = String(ist?.klinikBilgi ?? '');
    const y = await api.radyolojiSablonBolumleri(sId);
    return y.map((b, i) => {
      const baslik = String(b.baslik ?? '');
      // KLINIK BILGI istemden dolar: hekim ayni metni ikinci kez yazmasin.
      //   Sablonun kendi varsayilani varsa ona dokunulmaz.
      // Yer tutucular ({istem.on_tani} ...) istemle doldurulur.
      const varsayilan = yerTutucuDoldur(String(b.varsayilanMetin ?? ''), ist).trim();
      const klinikMi = baslik.toLocaleLowerCase('tr').includes('klinik');
      // BİÇİMLİ VARSAYILAN (1216): eski HBYS Word şablonu tablo / resim / biçimiyle gelir.
      // GÖMÜLÜ FONT / PUNTO TEMİZLİĞİ (1344, kullanıcı 14.11.2026): kurum ya da şablon tipografisi geçerliyken Word'den
      //   gelen font-size / font-family / line-height şablon UYGULANIRKEN atılır; kalın, tablo, hizalama kalır. Hekimin
      //   sonradan araç çubuğuyla verdiği biçim dokunulmaz kalır. "Şablonun kendi biçimi" (özgün) seçiliyse olduğu gibi.
      const hamHtml = b.varsayilanHtml ? yerTutucuDoldur(String(b.varsayilanHtml), ist) : '';
      const html = hamHtml && sablonTipografisi(sablonlar.find(s => s.id === sId), kurumTipografi).kaynak !== 'ozgun'
        ? gomuluBicimTemizle(hamHtml) : hamHtml;
      return {
        sira: Number(b.sira ?? i + 1), baslik,
        metin: html ? htmldenDuz(html) : !varsayilan && klinikMi ? klinik : varsayilan,
        ...(html ? { html } : {}),
        yazdir: Number(b.yazdir ?? 1), zorunlu: Number(b.zorunlu ?? 0),
      };
    });
  }

  /**
   * Tek ⇄ parçalı geçiş. Parçalıdan teke bölümler tek metne birleşir (kayıp yok). Tekten parçalıya metin
   * bölünemez: şablonun iskeleti kurulur, metnin tamamı BULGULAR bölümüne (yoksa ilk bölüme) taşınır.
   * Seçim hekimin tercihi olarak saklanır - sonraki yeni raporlar o biçimde açılır.
   */
  const duzenDegistir = (yeni: RadyolojiRaporDuzeni) => guvenli(async () => {
    if (yeni === duzen) return;
    // Yapısal girişte metin formdan üretilir: biçim değişince yeniden kurulur (etki aşağıda).
    if (etkinGiris === 'yapisal') {
      setDuzen(yeni);
      void gorunumKaydet({ ...gorunumOku(), radyolojiRaporDuzeni: yeni }).catch(() => {});
      return;
    }
    if (yeni === 'tek') {
      setBolumler(b => (b.length === 0 || tekParcaMi(b) ? b : tekBolum(birlestir(b), birlestirHtml(b))));
    } else if (tekParcaMi(bolumler)) {
      const metin = bolumler[0].metin;
      if (!sablonId) throw new Error('Parçalı yazmak için önce sağdan bir şablon seçin.');
      const parcalar = await sablonParcalari(sablonId, istem);
      if (metin.trim()) {
        if (!(await onay('Tek parça metin bölünemez: şablonun bölümleri kurulur, yazdığınız metnin tamamı '
                         + 'Bulgular bölümüne taşınır. Devam edilsin mi?'))) return;
        const h = parcalar.findIndex(x => x.baslik.toLocaleLowerCase('tr').includes('bulgu'));
        const i = h >= 0 ? h : 0;
        if (parcalar[i]) parcalar[i] = { ...parcalar[i], metin, html: bolumler[0].html };
      }
      setBolumler(parcalar);
    }
    setDuzen(yeni);
    void gorunumKaydet({ ...gorunumOku(), radyolojiRaporDuzeni: yeni }).catch(() => {});
  });

  // ------------------------------------------------------------ yapısal giriş (BI-RADS) --
  const seciliSablon = sablonlar.find(s => s.id === sablonId);
  const biradsli = Number(seciliSablon?.yapisalTur ?? 0) === 1 && birads !== null;
  const modalite = modaliteKodundan(seciliSablon?.modalite);
  const etkinGiris: RadyolojiRaporGiris = giris === 'yapisal' && biradsli ? 'yapisal' : 'serbest';

  /** İskelette BULGULAR / SONUÇ formdan yazılır; bölüm yoksa eklenir. */
  const formdanParcalar = (p: Bolum[], d: BiradsDurumu): Bolum[] => {
    const u = metinUret(d, modalite);
    const r = p.map(b => (bulguBolumuMu(b.baslik) ? { ...b, metin: u.bulgular, html: undefined }
                        : sonucBolumuMu(b.baslik) ? { ...b, metin: u.sonuc, html: undefined } : b));
    if (!r.some(b => bulguBolumuMu(b.baslik))) r.push({ sira: r.length + 1, baslik: 'Bulgular', metin: u.bulgular, yazdir: 1 });
    if (!r.some(b => sonucBolumuMu(b.baslik))) r.push({ sira: r.length + 1, baslik: 'Sonuç', metin: u.sonuc, yazdir: 1 });
    return r;
  };

  // YAPISAL: form / iskelet / biçim değişince rapor metni yeniden üretilir.
  useEffect(() => {
    if (etkinGiris !== 'yapisal' || !birads) return;
    const p = formdanParcalar(parcalar, birads);
    setBolumler(duzen === 'tek' ? tekBolum(birlestir(p)) : p);
  // formdanParcalar her çizimde yeni; bağımlılıklar onun girdileri.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [etkinGiris, birads, parcalar, duzen, modalite]);

  /**
   * Giriş değişimi. Yapısala geçerken BULGULAR / SONUÇ elle değiştirilmişse sorulur (formdan yeniden üretilecek);
   * iskelet mevcut parçalı bölümlerden, tek parçada şablondan kurulur. Serbeste geçişte metin olduğu gibi kalır.
   */
  const girisDegistir = (yeni: RadyolojiRaporGiris) => guvenli(async () => {
    if (yeni === etkinGiris) return;
    if (yeni === 'yapisal') {
      if (!biradsli || !birads) return;
      const u = metinUret(birads, modalite);
      const mevcut = tekParcaMi(bolumler) ? bolumler[0].metin
        : bolumler.filter(b => bulguBolumuMu(b.baslik) || sonucBolumuMu(b.baslik)).map(b => b.metin.trim()).join('');
      const elle = tekParcaMi(bolumler)
        ? !(mevcut.includes(u.bulgular) && mevcut.includes(u.sonuc)) && /BULGULAR:\n\S/.test(mevcut)
        : mevcut !== '' && mevcut !== `${u.bulgular.trim()}${u.sonuc.trim()}`;
      if (elle && !(await onay('Bulgular / Sonuç elle yazılmış. Formdan yeniden üretilsin mi? Elle yazılan kaybolur.'))) return;
      setParcalar(!tekParcaMi(bolumler) && bolumler.length > 0 ? bolumler
                  : sablonId ? await sablonParcalari(sablonId, istem) : []);
      setBiradsKullanildi(true);
    }
    setGiris(yeni);
    void gorunumKaydet({ ...gorunumOku(), radyolojiRaporGiris: yeni }).catch(() => {});
  });

  /** Serbest girişte BI-RADS panelinden metne: BULGULAR + SONUÇ (tek parçada metnin ilgili kısmı) yazılır. */
  const biradsAktar = () => guvenli(async () => {
    if (!birads) return;
    const u = metinUret(birads, modalite);
    if (tekParcaMi(bolumler)) {
      // Tek parça metinde bölüm düz metin üzerinden yazılır - biçim varsa kaybolacağı sorulur.
      if (bicimVarMi(bolumler[0].html)
          && !(await onay('Metindeki biçimlendirme (font, renk...) kaldırılacak. BI-RADS metni aktarılsın mı?'))) return;
      const m = tekMetneBolumYaz(tekMetneBolumYaz(bolumler[0].metin, 'Bulgular', u.bulgular), 'Sonuç', u.sonuc);
      setBolumler([{ ...bolumler[0], metin: m, html: undefined }]);
    } else setBolumler(formdanParcalar(bolumler, birads));
    setBiradsKullanildi(true);
  });

  const bolumYaz = (i: number, metin: string, html?: string) =>
    setBolumler(b => b.map((x, k) => (k === i ? { ...x, metin, html } : x)));

  /**
   * YAPILANDIRILMIŞ ALANLAR -> METİN (1217): doldurulan alanların cümleleri hedef bölümün (alanın "Bölüm"ü, yoksa
   * Bulgular) SONUNA paragraf olarak eklenir; tek parça raporda metnin sonuna. Normal değerler normal kalıbıyla.
   */
  const alanlariMetneEkle = () => {
    const satirlar = alanCumleleri(skorlar, skorDeger);
    if (satirlar.length === 0) { mesaj(c('Doldurulmuş alan yok.')); return }
    // Bölümsüz rapor (şablonun metni yok): cümleler tek A4 bölüm olarak açılır.
    if (bolumler.length === 0) {
      setBolumler(tekBolum(satirlar.join('\n'), satirlar.map(s => `<p>${duzdenHtml(s)}</p>`).join('')));
      return;
    }
    const hedefAd = (skorlar.find(s => s.hedefBolum)?.hedefBolum ?? '').toLocaleLowerCase('tr');
    const i = tekParcaMi(bolumler) ? 0
      : Math.max(0, bolumler.findIndex(b => (hedefAd && b.baslik.toLocaleLowerCase('tr') === hedefAd) || bulguBolumuMu(b.baslik)));
    if (i >= bolumler.length) return;
    setBolumler(b => b.map((x, k) => (k === i
      ? { ...x, metin: `${x.metin.trimEnd()}${x.metin.trim() ? '\n' : ''}${satirlar.join('\n')}`,
          html: x.html === undefined ? undefined : `${x.html}${satirlar.map(s => `<p>${duzdenHtml(s)}</p>`).join('')}` }
      : x)));
    mesaj(`${satirlar.length} ${c('cümle')} "${bolumler[i].baslik}" ${c('bölümüne eklendi.')}`);
  };

  /** Alan değeri - TI-RADS (1218) / Fleischner (1221) / Obstetrik (1379) paketi varsa girdiler değişince kategori /
   *  öneri / tahmini ağırlık yeniden hesaplanır (her hesap kendi paketinin alanı yoksa dokunmaz). */
  const alanDegistir = (kod: string, v: string) =>
    setSkorDeger(d => obstetrikUygula(skorlar,
      fleischnerUygula(skorlar, tiradsUygula(skorlar, { ...d, [kod]: v }, kod), kod), kod));
  const fleischnerHesap = skorlar.some(s => s.alanKod === 'fleischner') && fleischnerOnerisi(skorlar, skorDeger) !== null;
  const tiradsPuan = skorlar.some(s => s.alanKod === 'tirads') ? tiradsPuani(skorlar, skorDeger) : null;

  /** Makro metnini hedef bölüme (yoksa son dokunulan bölüme) ekler. */
  const makroEkle = (m: Makro) => {
    const hedef = m.hedefBolum
      ? bolumler.findIndex(b => b.baslik.toLocaleLowerCase('tr') ===
                                m.hedefBolum.toLocaleLowerCase('tr'))
      : -1;
    const i = tekParcaMi(bolumler) ? 0 : hedef >= 0 ? hedef : sonBolum.current;
    if (i < 0 || i >= bolumler.length) return;
    const ek = yerTutucuDoldur(m.metin, istem);
    setBolumler(b => b.map((x, k) => (k === i
      ? { ...x, metin: x.metin ? `${x.metin.trimEnd()} ${ek}` : ek,
          html: x.html === undefined ? undefined : `${x.html} ${duzdenHtml(ek)}` }
      : x)));
  };

  const govde = () => ({
    sablonId,
    // SÜRÜM (kod inceleme raporu 28.10.2026 B04): başkası arada kaydettiyse / onayladıysa sunucu 409 döner.
    surum: rapor?.surum ? String(rapor.surum) : undefined,
    bolumler: bolumler.map(b => ({ id: b.id, sira: b.sira, baslik: b.baslik,
                                   metin: b.metin, yazdir: b.yazdir, metinHtml: b.html ?? null })),
    alanlar: skorlar.map(s => ({ alanKod: s.alanKod, alanAd: s.alanAd,
                                 deger: skorDeger[s.alanKod] ?? '' })),
    kritik: kritik ? 1 : 0,
    // GİRİŞ + BI-RADS (1194): serbest girişte panel hiç kullanılmadıysa BI-RADS gönderilmez (boş kategori yazılmaz).
    giris: etkinGiris === 'yapisal' ? 2 : 1,
    ...(birads && biradsli && (etkinGiris === 'yapisal' || biradsKullanildi)
      ? { birads: biradsGovdesi(birads, modalite) } : {}),
    // PUANLAR YALNIZ PROFIL ACIKKEN GONDERILIR: kapaliyken alan ekranda yok,
    //   0 gondermek daha once girilmis degeri silerdi.
    ...(bakanlikProfili ? { istemNedeniPuan: nedeniPuan, cekimKalitePuan: kalitePuan } : {}),
  });

  // ÇİFT TIK KORUMASI (K55): kaydet / uzmana gönder / onayla sürerken ikinci istek gitmez (ref anlık,
  //   state düğmeleri kapatır).
  const islemdeRef = useRef(false);
  const [islemde, setIslemde] = useState(false);
  // ---------------------------------------------------------------- yerel taslak yedeği ----
  const taslakImzasi = () => JSON.stringify({ bolumler, duzen, giris, sablonId, skorDeger, nedeniPuan, kalitePuan });
  const yerelTaslakSil = () => { try { localStorage.removeItem(YEREL_TASLAK(id)) } catch { /* yerel depo kapalı */ } };
  const kilitliMi = Number(rapor?.kilit ?? 0) === 1;   // `kilitli` aşağıda tanımlı; burada aynı hesap
  const kirli = tabanImza.current !== '' && !kilitliMi && taslakImzasi() !== tabanImza.current;
  const kirliRef = useRef(false); kirliRef.current = kirli;
  const yerelTaslakGeriYukle = async (kilit: boolean) => {
    // Taban: sunucunun verdiği hâl (yükleme bitti, state yerleşti).
    tabanImza.current = taslakImzasi();
    if (kilit) { yerelTaslakSil(); return }
    let yedek: YerelTaslak | null = null;
    try { const ham = localStorage.getItem(YEREL_TASLAK(id)); yedek = ham ? JSON.parse(ham) as YerelTaslak : null } catch { yedek = null }
    if (!yedek) return;
    const yedekImza = JSON.stringify({ bolumler: yedek.bolumler, duzen: yedek.duzen, giris: yedek.giris, sablonId: yedek.sablonId,
                                       skorDeger: yedek.skorDeger, nedeniPuan: yedek.nedeniPuan, kalitePuan: yedek.kalitePuan });
    if (yedekImza === tabanImza.current) { yerelTaslakSil(); return }
    const ne = new Date(yedek.zaman);
    const saat = Number.isNaN(ne.getTime()) ? '' : ` (${ne.toLocaleString('tr-TR')})`;
    if (await onay(c('Bu bilgisayarda kaydedilmemiş bir rapor taslağı bulundu') + saat + '. '
                   + c('Ekran yenilenmiş ya da kapanmış olabilir. Taslak geri yüklensin mi? Hayır derseniz yedek silinir.'))) {
      setBolumler(yedek.bolumler); setDuzen(yedek.duzen); setGiris(yedek.giris); setSablonId(yedek.sablonId); setRaporDuzenle(true);
      setSkorDeger(yedek.skorDeger ?? {}); setNedeniPuan(Number(yedek.nedeniPuan ?? 0)); setKalitePuan(Number(yedek.kalitePuan ?? 0));
      if (yedek.sablonId && yedek.sablonId !== sablonId) {
        const m = await api.radyolojiRapor(id, yedek.sablonId).catch(() => null);
        if (m) { setMakrolar(m.makrolar as unknown as Makro[]); setSkorlar(m.skorlar as unknown as Skor[]) }
      }
    } else yerelTaslakSil();
  };
  // Her değişiklikte (~1 sn gecikmeli) yedek; sunucuyla aynıysa yedek silinir.
  useEffect(() => {
    if (tabanImza.current === '' || kilitliMi) return;
    if (yedekZamanlayici.current) window.clearTimeout(yedekZamanlayici.current);
    yedekZamanlayici.current = window.setTimeout(() => {
      if (!kirliRef.current) { yerelTaslakSil(); return }
      const y: YerelTaslak = { zaman: new Date().toISOString(), bolumler, duzen, giris, sablonId, skorDeger, nedeniPuan, kalitePuan };
      try { localStorage.setItem(YEREL_TASLAK(id), JSON.stringify(y)) } catch { /* yerel depo dolu / kapalı */ }
    }, 800);
    return () => { if (yedekZamanlayici.current) window.clearTimeout(yedekZamanlayici.current) };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [bolumler, duzen, giris, sablonId, skorDeger, nedeniPuan, kalitePuan, kilitliMi]);
  // Sayfa yenileme / kapatma: kaydedilmemiş değişiklik varsa tarayıcı sorar.
  useEffect(() => {
    const uyar = (e: BeforeUnloadEvent) => { if (kirliRef.current) { e.preventDefault(); e.returnValue = '' } };
    window.addEventListener('beforeunload', uyar);
    return () => window.removeEventListener('beforeunload', uyar);
  }, []);

  const kaydet = async (sonra?: (k: { raporId: number; surum: string }) => Promise<void>) => {
    if (islemdeRef.current) return false;
    islemdeRef.current = true; setIslemde(true);
    try {
      return await guvenli(async () => {
        const k = await api.radyolojiRaporYaz(id, govde());
        yerelTaslakSil();   // sunucuda; yerel yedek gereksiz
        // Kayıt geçtiyse sürüm değişti: sonraki adım hata verse de yeni sürüm okunur (yoksa ikinci kayıt 409 alırdı).
        try { if (sonra) await sonra(k) } finally { await yukle() }
        if (!sonra) mesaj('Rapor taslağı kaydedildi.');
      });
    } finally { islemdeRef.current = false; setIslemde(false) }
  };

  // ONAY = EKRANDAKİ METİN: önce bu ekranın metni kaydedilir, onay KAYDIN döndürdüğü sürümle istenir. Rapor
  //   yeniden okunmaz - okunsaydı arada başkasının kaydettiği (uzmanın görmediği) metin onaylanırdı.
  // UZMANA GÖNDER (1199): onaylayacak uzman SEÇİLİR. Varsayılan: raporun önceki onaylayacağı, yoksa bu
  //   kullanıcının son seçtiği uzman (yerel). Seçim kayıttan ÖNCE sorulur - vazgeçilirse hiçbir şey yazılmaz.
  /**
   * RADYOLOG / UZMAN SEÇİMİ - TEK PENCERE (kullanıcı 17.11.2026: "uzmana gönderdeki radyolog seçimi ile aynı olmalı
   * onaylama için seçim"): Uzmana Gönder ve "kimin adına onay / e-imza" aynı listeyi (radyolog rolü + onay yetkisi +
   * bu şube, bekleyen sayısıyla) ve aynı "son seçilen"i kullanır.
   */
  const uzmanListesindenSec = async (baslik: string): Promise<{ id: number; ad: string } | null> => {
    const liste = await api.radyolojiOnayUzmanlari();
    if (liste.length === 0) { mesaj('Bu şubede rapor onaylama yetkisi olan radyolog yok.'); return null }
    let son = '';
    try { son = localStorage.getItem('rad.sonUzman') ?? '' } catch { /* yerel depo kapalı */ }
    const onceki = String(rapor?.onaylayacakId ?? '');
    const varsayilan = [onceki, son].find(k => k && liste.some(u => String(u.id) === k)) ?? String(liste[0].id);
    const secilen = await listeSor(baslik,
      liste.map(u => ({ kod: String(u.id), ad: `${u.ad} — ${u.bekleyen} onay bekliyor` })), varsayilan, 'Radyolog');
    if (!secilen) return null;
    try { localStorage.setItem('rad.sonUzman', secilen) } catch { /* yerel depo kapalı */ }
    const u = liste.find(x => String(x.id) === secilen)!;
    return { id: u.id, ad: u.ad };
  };

  const uzmanSec = async (): Promise<{ id: number; not: string } | null> => {
    const secim = await uzmanListesindenSec('Raporu onaylayacak uzmanı seçin.');
    if (!secim) return null;
    const secilen = String(secim.id);
    const not = await metinSor('Uzmana not (isteğe bağlı):', '', 'ör. Sol memedeki lezyona özellikle bakar mısınız?');
    if (not === null) return null;
    return { id: Number(secilen), not: not.trim() };
  };

  /**
   * ONAYLA / e-İMZALA AYRI (kullanıcı 17.11.2026: "Onayla imzala butonunu 2'ye böl: Onayla (e-imza olmadan doktorun
   * onayladığı), e-İmzala (e-imza ile onaylanan)"). 'onay' = e-imzasız onay; 'eimza' = kart penceresi (1337).
   */
  /** RADYOLOG SEÇİMİ (17.11.2026): kullanıcı radyologsa kendisi; değilse onay yetkili radyologlar arasından seçilir. */
  const radyologSec = async (): Promise<{ id: number; ad: string; kendisi: boolean } | null> => {
    // Kullanıcı radyologsa (radyolog rolü + onay yetkisi) seçim sorulmaz, kendi adına.
    if (radyologMu && kullanici) return { id: kullanici.id, ad: kullanici.ad, kendisi: true };
    let secim: { id: number; ad: string } | null = null;
    if (!await guvenli(async () => { secim = await uzmanListesindenSec('Rapor hangi radyolog adına onaylanacak?') })) return null;
    const s = secim as { id: number; ad: string } | null;
    return s ? { ...s, kendisi: s.id === kullanici?.id } : null;
  };

  /**
   * ONAY / e-İMZA İPTALİ (17.11.2026): yalnız onaylayan radyolog; başkası basarsa onaylayanın şifresi sorulur.
   * Teslim edilmiş / e-Nabız / Teletıp'a gitmiş raporda sunucu reddeder (düzeltme ek raporla).
   */
  /**
   * REVİZE (1374, kullanıcı 18.11.2026): rapor teslim edildiyse / e-Nabız'a / TeleRadyoloji'ye gittiyse onay geri
   * alınamaz - kullanıcıya söylenir; devam ederse raporun bu hâli "Revize" olarak saklanır, rapor düzeltme için
   * taslağa döner (numara -R ekiyle). Yetki onay iptaliyle aynı (onaylayan; başkası için onun şifresi).
   */
  const revizeEt = async (neden: string) => {
    const raporId = Number(rapor?.id ?? 0);
    if (!raporId) return;
    const no = String(rapor?.raporNo ?? '');
    if (!await onay(`⚠ ${neden}; onay geri alınamaz, ancak rapor REVİZE edilebilir.

Devam ederseniz raporun bu hâli${no ? ` (${no})` : ''} "Revize" olarak saklanır (teslim / gönderim izleriyle birlikte),
kopyası düzeltmek üzere taslak olarak açılır${no ? ` ve ${no.replace(/-R\d+$/, '')}-R${Number(rapor?.revizeNo ?? 0) + 1} numarasını alır` : ''}.
Yeniden onaylanınca düzeltilmiş rapor TeleRadyoloji / e-Nabız'a düzeltme olarak gider ve yeniden teslim edilmelidir.

Revize edilsin mi?`, true)) return;
    const gerekce = await metinSor('Revize nedeni (zorunlu):', '', 'ör. Bulgularda taraf yanlış yazılmış');
    if (!gerekce?.trim()) { mesaj('Revize nedeni yazılmadan revize yapılmaz.'); return }
    let parola: string | undefined;
    if (Number(rapor?.onaylayanId ?? 0) !== kullanici?.id) {
      const p = await parolaSor(String(rapor?.onaylayan ?? '') || c('Onaylayan radyolog'), c('raporu revize etmek'));
      if (!p) return;
      parola = p;
    }
    await guvenli(async () => {
      const y = await api.radyolojiRaporRevize(raporId, String(rapor?.surum ?? ''), { neden: gerekce.trim(), parola });
      await yukle();
      mesaj(`Rapor revize edildi: önceki hâl "Revize" olarak saklandı; düzeltilmiş rapor${y.raporNo ? ` (${y.raporNo})` : ''} taslak olarak açıldı.`);
    });
  };

  const onayIptal = async () => {
    const raporId = Number(rapor?.id ?? 0);
    if (!raporId) return;
    // Dışarı çıkmış rapor: iptal yerine revize (parola sorulmadan ÖNCE söylenir).
    if (iptalEngeli) { await revizeEt(iptalEngeli); return }
    const imzali = Number(rapor?.imzaDokumanId ?? 0) > 0;
    const ad = imzali ? 'e-İmza' : 'Onay';
    let parola: string | undefined;
    if (Number(rapor?.onaylayanId ?? 0) === kullanici?.id) {
      if (!await onay(`⚠ ${ad} iptal edilecek: rapor taslağa döner, kilidi açılır ve yeniden düzenlenebilir.

Devam edilsin mi?`, true)) return;
    } else {
      const p = await parolaSor(String(rapor?.onaylayan ?? '') || c('Onaylayan radyolog'),
                                imzali ? c('e-imzayı iptal etmek') : c('onayı iptal etmek'));
      if (!p) return;
      parola = p;
    }
    try {
      await api.radyolojiRaporOnayIptal(raporId, String(rapor?.surum ?? ''), parola);
      await yukle();
      mesaj(`${ad} iptal edildi; rapor taslağa döndü.`);
    } catch (h) {
      // Ekran açıldıktan sonra rapor dışarı çıktıysa sunucu revize önerir.
      const d = (h as { hata?: { engel?: { revize?: boolean; neden?: string } } })?.hata?.engel;
      if (d?.revize) { await yukle(); await revizeEt(String(d.neden ?? 'Rapor dışarı gönderildi')); return }
      await guvenli(async () => { throw h });
    }
  };

  const durumaGecir = async (hedef: 'on-rapor' | 'onay' | 'eimza') => {
    if (islemdeRef.current) return;
    // ONAY SORUSU (K55): onay geri alınamaz - kilitlemeden önce sorulur.
    if (hedef === 'onay') {
      if (!await onay('Rapor e-imza olmadan onaylanacak ve kilitlenecek. Devam edilsin mi?')) return;
      // KİMİN ADINA (17.11.2026): radyolog kendi adına; değilse radyolog seçilir + o radyoloğun şifresi.
      const sec = await radyologSec();
      if (!sec) return;
      let adina: { id: number; parola: string } | undefined;
      if (!sec.kendisi) {
        const parola = await parolaSor(sec.ad, c('raporu onaylamak'));
        if (!parola) return;
        adina = { id: sec.id, parola };
      }
      await kaydetVeGecir('onay', undefined, adina);
      return;
    }
    if (hedef === 'eimza') {
      let eimza = false;
      if (!await guvenli(async () => { eimza = (await api.eimzaAyar()).aktif })) return;
      if (!eimza) { mesaj('Bu kurumda e-imza hesabı tanımlı / aktif değil (Entegrasyonlar › e-İmza).'); return }
      if (!await onay('Rapor e-imza ile imzalanıp onaylanacak ve kilitlenecek. Devam edilsin mi?')) return;
      // Radyolog değilse radyolog seçilir; kimliği kartın kendisi (çip + PIN) kanıtlar.
      const sec = await radyologSec();
      if (!sec) return;
      setEimzaAdina(sec.kendisi ? undefined : sec.id);
      setEimzaModal(true);
      return;
    }
    let uzman: { id: number; not: string } | undefined;
    if (hedef === 'on-rapor') {
      // guvenli yalniz basari bayragi doner - secim disaridaki degiskene yazilir.
      let secilen: { id: number; not: string } | null = null;
      if (!await guvenli(async () => { secilen = await uzmanSec() }) || !secilen) return;
      uzman = secilen;
    }
    await kaydetVeGecir(hedef, uzman);
  };

  /**
   * e-İMZA AKIŞI (1337): rapor kaydedilir → çıktı verisi okunur → aynı A4 belge tek dosyalık HTML olur →
   * istemci kipinde bu bilgisayardaki GenSigner imzalar (PIN sunucuya gitmez), sunucu kipinde HTML + PIN API'ye →
   * API imzalı XML'i doğrular, dokümana yazar, raporu onaylar ve kilitler. Hata pencereyi açık bırakır.
   */
  const eimzaIleOnayla = async (ayar: EImzaAyar, kart: EImzaKart, pin: string) => {
    let hataMesaji = '';
    const tamam = await kaydet(async ({ raporId, surum }) => {
      if (!raporId) throw new Error('Rapor bulunamadı.');
      // Hata TEK YERDE gösterilir (imza penceresi): kaydet'in guvenli sarmalı ikinci bir uyarı açmasın diye
      //   burada yutulur, aşağıda pencereye fırlatılır.
      try {
        // 1) Hazırlık: kilit / sürüm / onaylanabilirlik + RESMİ RAPOR NO - imzalanan belge numarayı taşır.
        const hazir = await api.radyolojiRaporImzaHazirla(raporId, surum, eimzaAdina);
        const veri = await api.radyolojiRaporCikti(raporId) as unknown as Parameters<typeof raporBelgesiHtml>[0];
        const html = await raporBelgesiHtml(veri, `Radyoloji Raporu ${String(veri.rapor.hastaAdi ?? '')} ${hazir.raporNo}`.trim());
        const mimeType = 'text/html';
        const imzaBase64 = ayar.kip === 'istemci'
          ? await genSignerImzala(ayar.url, ayar.apiKey, kart, pin, utf8Base64(html), mimeType) : undefined;
        // 2) İmza + onay: hazırlığın verdiği sürümle (rapor no ataması sürümü ilerletti).
        await api.radyolojiRaporImzala(raporId, hazir.surum, { html, mimeType, sertifika: kart, imzaBase64, pin: ayar.kip === 'sunucu' ? pin : undefined, adinaId: eimzaAdina });
      } catch (h) { hataMesaji = hataMetni(h) }
    });
    if (!tamam || hataMesaji) throw new Error(hataMesaji || 'Rapor kaydedilemedi.');
    setEimzaModal(false);
    mesaj('Rapor e-imza ile imzalandı ve onaylandı; artık kilitlidir.');
  };

  const kaydetVeGecir = (hedef: 'on-rapor' | 'onay', uzman?: { id: number; not: string },
                         adina?: { id: number; parola: string }) => kaydet(async ({ raporId, surum }) => {
    if (!raporId) throw new Error('Rapor bulunamadı.');
    await api.radyolojiRaporDurum(raporId, hedef, surum, uzman?.id, uzman?.not, adina);
    mesaj(hedef === 'onay'
      ? 'Rapor onaylandı (e-imzasız); artık kilitlidir.'
      : 'Ön rapor uzman onayına gönderildi.');
  });

  const kritikKaydet = () => guvenli(async () => {
    await api.radyolojiKritikBulgu(id, kritikForm);
    setKritikModal(false);
    setKritikForm({ bulgu: '', bildirilenAd: '', yol: 1, geriBildirim: '', bildirenId: null });
    await yukle();
    mesaj('Kritik bulgu bildirimi kaydedildi.');
  });

  const addendum = () => guvenli(async () => {
    const raporId = Number(rapor?.id ?? 0);
    if (!raporId) return;
    await api.radyolojiAddendum(raporId);
    await yukle();
    mesaj('Ek rapor (addendum) açıldı; orijinal rapor değişmeden kalır.');
  });

  // HASTA BANDI (kullanıcı 27.10.2026: "radyoloji raporu için hasta bandı yap"): sevk / konsültasyondaki standart
  //   band - ad, yaş, kurum, dosya / protokol no, kan grubu, alerji, uyarılar. İstemde muayene yok: hastanın
  //   en son muayenesinden (yoksa hasta kaydından) okunur.

  if (yukleniyor) return <div className="yukleniyor">{c('Yükleniyor…')}</div>;
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!istem) return <div className="hata-kutusu">{c('İstem bulunamadı.')}</div>;

  const kilitli = Number(rapor?.kilit ?? 0) === 1;
  /** Rapor YAZIMI kilitli: onaylı rapor ya da görüntüleme kipi (✎). Araç çubuğu / skor / kritik bunu kullanmaz. */
  const yazimKilit = kilitli || !raporDuzenle;
  // ÇEKİMSİZ RAPOR YOK (kullanıcı 01.11.2026): sunucu da reddeder; ekran önceden uyarır, yazma düğmeleri kapalı.
  const cekimYok = Number(istem.cekildi ?? 1) === 0;
  // ONAYLAYACAK → ONAYLAYAN (1199): onaya kadar seçilen uzman + bekleme süresi, onaydan sonra imzalayan - hasta
  //   bandının son hücrelerinde (HastaSeridi sonHucreler).
  const durum = RAPOR_DURUM[Number(rapor?.durum ?? 1)] ?? RAPOR_DURUM[1];
  const yas = yasMetni(istem.dogumTarihi);

  return (
    <div className="sayfa rad-rapor">
      {revizeler.length > 0 && (
        <div className="bilgi-kutusu" data-testid="rapor-revize-gecmisi">
          🗂 <b>{c('Önceki Revizeler')}</b> ({revizeler.length}):{' '}
          {revizeler.map(v => (
            <span key={v.id} style={{ marginRight: 12 }}>
              <a href="#" onClick={e => { e.preventDefault(); git(`/radyoloji/cikti/${v.id}`) }}
                 title={`${v.neden}${v.revizeEden ? ` · ${v.revizeEden}` : ''}`}>
                {v.raporNo || `#${v.id}`} — {String(v.revizeTarihi ?? '').replace('T', ' ').slice(0, 16)}
              </a>
              {v.neden ? ` (${v.neden})` : ''}
            </span>
          ))}
        </div>
      )}
      <div className="sayfa-bas">
        {/* BAŞLIK SATIRI KALKTI (kullanıcı 27.10.2026): sekme başlığı hasta adı; accession no solda "Bu tetkik"te. */}
        <div className="sayfa-eylem">
          <button className="d bir" disabled={kilitli || islemde || cekimYok} onClick={() => void kaydet()}>{c('💾 Taslak Kaydet')}</button>
          <button className="d" disabled={kilitli || islemde || cekimYok}
                  onClick={() => void durumaGecir('on-rapor')}>➜ Uzmana Gönder</button>
          {/* ONAYLA / e-İMZALA (17.11.2026): e-imzasız onay ve kartla imzalı onay ayrı düğmeler. */}
          {/* ONAYLANDIYSA İPTAL (17.11.2026): e-imzasız onayda "Onay İptal", e-imzalıda "e-İmza İptal". */}
          {kilitli && Number(rapor?.imzaDokumanId ?? 0) === 0
            ? <button className="d teh" disabled={islemde} data-testid="rapor-onay-iptal"
                      title={iptalEngeli ? `${iptalEngeli}: onay geri alınamaz, revize edilebilir`
                                         : c('Onayı iptal eder; rapor taslağa döner (yalnız onaylayan radyolog)')}
                      onClick={() => void onayIptal()}>⟲ {iptalEngeli ? c('Revize Et') : c('Onay İptal')}</button>
            : <button className="d basari" disabled={kilitli || islemde || cekimYok} data-testid="rapor-onayla"
                      title={radyologMu ? c('Raporu e-imza olmadan onaylar ve kilitler') : c('Radyolog seçilir; onun şifresiyle e-imza olmadan onaylanır')}
                      onClick={() => void durumaGecir('onay')}>✔ {c('Onayla')}</button>}
          {kilitli && Number(rapor?.imzaDokumanId ?? 0) > 0
            ? <button className="d teh" disabled={islemde} data-testid="rapor-eimza-iptal"
                      title={iptalEngeli ? `${iptalEngeli}: onay geri alınamaz, revize edilebilir`
                                         : c('e-İmzayı ve onayı iptal eder; rapor taslağa döner (yalnız imzalayan radyolog)')}
                      onClick={() => void onayIptal()}><UsbCipIkon /> {iptalEngeli ? c('Revize Et') : c('e-İmza İptal')}</button>
            : <button className="d basari" disabled={kilitli || islemde || cekimYok || eimzaAktif === false} data-testid="rapor-eimzala"
                      title={eimzaAktif === false ? c('e-İmza hesabı tanımlı / aktif değil (Entegrasyonlar › e-İmza)')
                             : radyologMu ? c('Raporu e-imza (kart / USB token) ile imzalar ve onaylar') : c('Radyolog seçilir; onun e-imza çipiyle imzalanır')}
                      onClick={() => void durumaGecir('eimza')}><UsbCipIkon /> {c('e-İmzala')}</button>}
          <button className="d teh" disabled={kilitli}
                  onClick={() => setKritikModal(true)}>⚠ Kritik Bulgu Bildir</button>
          {kilitli && <button className="d" onClick={() => void addendum()}>＋ Ek Rapor</button>}
          {/* İSTEM (kullanıcı 27.10.2026): istem kartını kendi sekmesinde açar. */}
          <button className="d" title={c('Radyoloji istem kartını aç')}
                  onClick={() => (ekranSekmesi ? ekranSekmesi.kartaGit(`/radyoloji/${id}`) : git(`/radyoloji/${id}`))}>☢️ İstem</button>
          {/* GÖRÜNTÜ (kullanıcı 13.11.2026, istem kartındaki "Görüntüle" ile aynı): PACS çalışması OHIF'te yeni sekmede;
              study_uid yoksa sunucu accession ile arar. Çekim yoksa görüntü de yoktur - düğme gizli. */}
          {!cekimYok && <button className="d" title={c('DICOM görüntüleyici (OHIF)')}
                  onClick={() => void (async () => {
                    try { const y = await api.dicomGoruntule({ istemId: id }); window.open(y.url, '_blank', 'noopener') }
                    catch (h) { setHata(hataMetni(h)) }
                  })()}>🩻 Görüntü</button>}
          {/* KART ADI GÖRÜNTÜ'NÜN SAĞINDA (kullanıcı 17.11.2026): diğer kartlardaki "X Kartı" araç satırı başlığı deseni. */}
          <span className="rad-kart-baslik">{c('Radyoloji Raporu')}
            {/* RAPOR ID (kullanıcı 18.11.2026): etiketin sağında; henüz kaydedilmemiş raporda yok. */}
            {Number(rapor?.id ?? 0) > 0 && <span title={c('Rapor kimliği')} style={{ marginLeft: '0.5em' }}>#{Number(rapor?.id)}</span>}
          </span>
          {/* İMZALI BELGE (kullanıcı 13.11.2026): raporun XAdES imzalı XML'i (doküman deposu, kaynak radyoloji-rapor). */}
          {Number(rapor?.imzaDokumanId ?? 0) > 0 && <button className="d" title={c('e-İmzalı rapor belgesini (XAdES XML) indir')}
                  onClick={() => void (async () => {
                    try {
                      const url = await api.dokumanIcerikUrl(Number(rapor?.imzaDokumanId));
                      dosyaIndirUrl(url, `e-imza ${String(rapor?.raporNo ?? '') || `rapor-${String(rapor?.id ?? '')}`}.xml`, true);
                    } catch (h) { setHata(hataMetni(h)) }
                  })()}>🔏 İmzalı Belge</button>}
          {/* SAĞA YASLI (kullanıcı 28.10.2026): Çıktı ve Kapat satırın sağ ucunda. */}
          <span className="ck-bosluk" />
          {/* YAZDIR (kullanıcı 28.10.2026, icmallerdeki gibi): Baskı Önizleme / Yazıcıya Yazdır / Gönder (PDF,
              Word, Excel, HTML) - çıktı sayfasına gitmeden. Belge KAYITLI rapordan çizilir (303): kaydedilmemiş
              raporda menü kapalı; onaysız rapor basılabilir, hekim kontrol için alır. */}
          <CiktiMenusu etiket="Yazdır" dugmeSinifi="d" sagda devre={!ciktiVeri}
                       dosyaAdi={`Radyoloji Raporu ${String(ciktiVeri?.rapor.hastaAdi ?? '')} ${String(ciktiVeri?.rapor.raporNo ?? '')}`.trim()}>
            {ciktiVeri && <RadyolojiRaporBelgesi veri={ciktiVeri} />}
          </CiktiMenusu>
          <button className="d" onClick={() => (ekranSekmesi ? ekranSekmesi.kapat() : git('/radyoloji'))}>✖ Kapat</button>
        </div>
      </div>

      {cekimYok && (
        <div className="uyari-serit" style={{ margin: '6px 0', padding: '7px 10px', border: '1px solid #f0c7c2', background: '#fdf1ef',
                                              color: '#8f3d36', borderRadius: 4, display: 'flex', gap: 10, alignItems: 'center' }}>
          ⚠ {c('Çekim bilgisi girilmeden rapor yazılamaz.')}
          <button className="d" onClick={() => (ekranSekmesi ? ekranSekmesi.kartaGit(`/radyoloji/${id}`) : git(`/radyoloji/${id}`))}>
            ☢️ {c('İstem kartında çekim bilgisini gir')}</button>
        </div>
      )}
      {/* HASTA BANDI = İSTEM KARTI BANDI (kullanıcı 01.11.2026: "rapor kartındaki hasta bandı da istem kartı gibi
          olsun.. ama yazan/onay/durum hücreleri kalsın"): Kimlik · Tetkik · İsteyen · Kurum · Uyarı · Yazan · Onay · Durum. */}
      <HastaSeridi tarafId={Number(istem.hastaId ?? 0) || null} kurumAdi={String(istem.odeyenKurum ?? '')}
                   belgeId={Number(istem.belgeId ?? 0) || null} paraYok provizyonGizli durumGizli
                   yedek={{ ad: String(istem.hastaAdi ?? ''), alt: yas }}
                   tetkik={{ ad: String(istem.tetkikAdi ?? ''), kod: String(istem.tetkikKodu ?? '') }}
                   isteyen={{ ad: String(istem.isteyen ?? ''), bolum: String(istem.isteyenBolum ?? '') }}
                   sonHucreler={[
                     { k: `✍ ${c('Yazan')}`, v: String(rapor?.yazan ?? '') || '—',
                       alt: rapor?.yazan ? <>{Number(rapor.yazanAsistan) === 1 && <span className="rozet rad-asistan">{c('asistan')}</span>}
                         {rapor.yazmaTarihi ? ` ${saatYaz(rapor.yazmaTarihi)}` : ''}</> : undefined },
                     Number(rapor?.durum ?? 0) === 3
                       ? { k: `✔ ${c('Onaylayan')}`, v: String(rapor?.onaylayan ?? '') || '—',
                           alt: <>{rapor?.onaylayacakId && Number(rapor.onaylayacakId) !== Number(rapor.onaylayanId)
                                   ? `(${String(rapor.onaylayacak)} ${c('yerine')}) ` : ''}
                                 {rapor?.onayTarihi ? `${saatYaz(rapor.onayTarihi)}${rapor?.imzaZamani ? ' · e-imza' : ''}` : ''}</> }
                       : { k: `⏳ ${c('Onaylayacak')}`, v: String(rapor?.onaylayacak ?? '') || '—',
                           alt: String(rapor?.onaylayacak ?? '') && rapor?.onayaGonderme
                             ? <span className="rad-bekliyor">{c('bekliyor')} · {sureYaz(rapor.onayaGonderme)}</span>
                             : c('gönderirken seçilir') },
                     { k: c('Durum'),
                       v: <span className="hs3-roz"><span className={`rozet ${durum.sinif}`}>{durum.ad}</span>
                            {/* Dar Durum hücresinde kilit yalnız simge (kullanıcı 01.11.2026: "kilit gelecek"). */}
                            {kilitli && <span title={c('Kilitli - düzeltme ek raporla')} style={{ fontSize: 12 }}>🔒</span>}</span>,
                       alt: String(rapor?.raporNo ?? '') || undefined },
                   ]} />
      {/* UZMANA NOT (1200): ön rapor beklerken bandın altında sarı şerit - uzman raporu açınca ilk bunu görür. */}
      {Number(rapor?.durum ?? 0) === 2 && String(rapor?.onayNotu ?? '').trim() !== '' && (
        <div className="rad-onay-notu">📝 <b>{String(rapor?.yazan ?? '') || c('Gönderen')}:</b> {String(rapor?.onayNotu)}</div>
      )}
      <div className={`rad-govde${etkinGiris === 'yapisal' ? ' yapisal' : ''}`}>
        {/* --------------------------------------------------- SOL: geçmiş --- */}
        <div className="rad-yan">
          <h5>{c('Önceki Tetkikler')}</h5>

          {/* KRONOLOJİK GÖRÜNÜM (kullanıcı 27.10.2026): zaman çizgisi - en yeni üstte, yıl başlıkları,
              bu tetkik en üstte "şimdi" düğümü. Tıklayınca (13.11.2026) liste YERİNDE kalır, düğüm vurgulanır ve
              o tetkikin raporu sağ panelde salt okunur açılır; kendi sekmesinde açmak oradaki ↗ düğmesi. */}
          <div className="rad-zc">
              {/* BU TETKİK TIKLANIR (kullanıcı 18.11.2026): sağda önceki tetkik / revize açıksa kapanır, panel şablonlu
                  rapor hâline döner. */}
              <div className={`rad-zc-dugum simdi${onceki ? '' : ' secili'}`} role="button" tabIndex={0}
                   style={{ cursor: onceki ? 'pointer' : undefined }}
                   title={onceki ? c('Bu tetkikin raporuna dön') : undefined}
                   onClick={() => setOnceki(null)}
                   onKeyDown={e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); setOnceki(null) } }}>
                <div className="rad-zc-tarih">{c('Bu tetkik')}
                  {istem.tetkikKodu ? <span className="rad-zc-mod">{String(istem.tetkikKodu)}</span> : null}</div>
                {istem.accessionNo ? <div className="sonuk kucuk" title={c('Erişim numarası: PACS ve cihazlar görüntüyü bu numarayla istemle eşleştirir')}>
                  {c('Accession')}: <b>{String(istem.accessionNo)}</b></div> : null}
                <b>{String(istem.tetkikAdi ?? '')}</b>
                <div className="sonuk kucuk">{c('Çekim')}: {istem.cekimTarihi ? anMetni(istem.cekimTarihi) : '—'}
                  {istem.cihazAdi ? ` · ${String(istem.cihazAdi)}` : ''}</div>
              </div>
              {revizeler.length > 0 && (
                <>
                  <div className="rad-zc-yil">🗂 {c('Önceki Revizeler')}</div>
                  {revizeler.map(v => (
                    <button key={v.id} type="button" className={`rad-zc-dugum d3${onceki?.id === -v.id ? ' secili' : ''}`}
                            title={onceki?.id === -v.id ? c('Sağdaki raporu kapat') : c('Raporun bu eski hâlini sağda göster')}
                            aria-pressed={onceki?.id === -v.id}
                            onClick={() => void buRevizeAc(v)}>
                      <div className="rad-zc-tarih">
                        {v.revizeTarihi ? anMetni(v.revizeTarihi) : ''}
                        <span className="rad-zc-mod">{c('Revize')} {v.revizeNo}</span>
                      </div>
                      <b>{v.raporNo || `#${v.id}`}</b>
                      <div className="sonuk kucuk">{c('Revize eden')}: {v.revizeEden || '—'}</div>
                      {v.neden && <div className="kucuk rad-zc-ozet">{v.neden}</div>}
                    </button>
                  ))}
                </>
              )}
              {gecmis.length === 0 && <div className="sonuk kucuk rad-zc-bos">{c('Önceki tetkik yok.')}</div>}
              {gecmis.map((g, i) => {
                const yil = g.tarih ? new Date(g.tarih).getFullYear() : 0;
                const oncekiYil = i > 0 && gecmis[i - 1].tarih ? new Date(gecmis[i - 1].tarih).getFullYear() : null;
                const durumAd = ({ 0: 'Raporsuz', 1: 'Taslak', 2: 'Ön rapor', 3: 'Onaylı' } as Record<number, string>)[Number(g.raporDurum ?? 0)];
                return (
                  <div key={g.id}>
                    {yil > 0 && yil !== oncekiYil && <div className="rad-zc-yil">{yil}</div>}
                    <button type="button" className={`rad-zc-dugum d${Number(g.raporDurum ?? 0)}${onceki?.id === g.id ? ' secili' : ''}`}
                            title={onceki?.id === g.id ? c('Sağdaki raporu kapat') : c('Raporu sağda göster')}
                            aria-pressed={onceki?.id === g.id}
                            onClick={() => void oncekiAc(g)}>
                      <div className="rad-zc-tarih">
                        {anMetni(g.tarih)}
                        {g.modaliteAdi && <span className="rad-zc-mod">{g.modaliteAdi}</span>}
                        {g.birads && <span className={`brf-k k${g.birads[0]}`}>BI-RADS {g.birads}</span>}
                      </div>
                      <b>{g.tetkikAdi}</b>
                      <div className="sonuk kucuk">{durumAd}{g.raporlayan ? ` · ${g.raporlayan}` : ''}
                        {Number(g.revizeSayisi ?? 0) > 0 && (
                          <span className="rozet sari" style={{ marginLeft: 6 }}
                                title={c('Bu rapor revize edildi; eski hâlleri sağdaki panelde görülebilir')}>
                            🗂 {c('Revize')} ×{Number(g.revizeSayisi)}
                          </span>)}
                      </div>
                      {g.ozet && <div className="kucuk rad-zc-ozet">{g.ozet}…</div>}
                    </button>
                  </div>
                );
              })}
          </div>

          <h5>İstem Bilgisi</h5>
          <div className="rad-kart">
            <div><b>{c('Ön tanı:')}</b> {istem.onTani ? `${istem.onTani}${istem.onTaniAdi ? ` · ${istem.onTaniAdi}` : ''}` : '—'}</div>
            <div><b>{c('İstem Nedeni:')}</b> {String(istem.klinikBilgi ?? '—')}</div>
            <div><b>{c('İsteyen:')}</b> {String(istem.isteyen ?? '—')}</div>
            <div><b>{c('Ödeyen:')}</b> {String(istem.odeyenKurum ?? '—')}</div>
          </div>

          <h5>{c('Seri / Görüntü')}</h5>
          <div className="rad-kart">
            <b>{Number(istem.seriSayisi ?? 0)} seri · {Number(istem.goruntuSayisi ?? 0)} görüntü</b>
            {istem.studyUid ? <div className="sonuk kucuk">{String(istem.studyUid)}</div>
                            : <div className="sonuk kucuk">{c('PACS eşleşmesi yok.')}</div>}
          </div>

          {kritikler.length > 0 && (
            <>
              <h5>{c('Kritik Bulgu Bildirimleri')}</h5>
              {kritikler.map((k, i) => (
                <div className="rad-kart teh" key={i}>
                  <b>{k.bulgu}</b>
                  <div className="kucuk">{k.bildirilenAd} · {KRITIK_YOL[k.yol] ?? ''}</div>
                  <div className="sonuk kucuk">{anMetni(k.bildirimZamani)}</div>
                </div>
              ))}
            </>
          )}
        </div>

        {/* --------------------------------------------------- ORTA: rapor --- */}
        <div className={`rad-orta${yazimKilit ? ' rad-goster' : ''}`} style={tipografiStil(tipografi)}>
          {/* GÖRÜNTÜLEME KİPİNDE GİZLİ (kullanıcı 17.11.2026: "view modda iken rapor biçimi ile başlayan satır ve yazı
              tipi / punto aracı görünmesin"): biçim / giriş / tipografi satırı ve biçim çubuğu yalnız düzenlemede. */}
          {!yazimKilit && <div className="rad-duzen">
            <span>{c('Rapor biçimi')}</span>
            <span className="seg" role="group">
              {(['tek', 'parcali'] as const).map(d => (
                <button key={d} type="button" className={duzen === d ? 'on' : ''} disabled={yazimKilit}
                        onClick={() => void duzenDegistir(d)}>{d === 'tek' ? c('Tek') : c('Parçalı')}</button>
              ))}
            </span>
            <span>{c('Giriş')}</span>
            <span className="seg" role="group">
              {(['serbest', 'yapisal'] as const).map(g => (
                <button key={g} type="button" className={etkinGiris === g ? 'on' : ''}
                        disabled={yazimKilit || (g === 'yapisal' && !biradsli)}
                        title={g === 'yapisal' && !biradsli ? c('Bu şablonda yapısal form yok') : undefined}
                        onClick={() => void girisDegistir(g)}>{g === 'serbest' ? c('Serbest') : c('Yapısal')}</button>
              ))}
            </span>
            {giris === 'yapisal' && !biradsli && (
              <span className="sonuk kucuk">{c('tercih Yapısal - bu şablonda form yok')}</span>
            )}
            {duzen === 'tek' && bakanlikProfili && (
              <span className="uyari-yazi">{c('Bakanlık profili açık: onay dört parça ister - parçalı yazın.')}</span>
            )}
            {/* TİPOGRAFİ ROZETİ (1344): editör ve çıktı bu görünümle; onaylıda damga. */}
            <span className={`rad-tip-roz${tipografiDamga ? ' damga' : ''}`}
                  title={`${c('Rapor tipografisi')}: ${tipografiOzeti(tipografi)} · ${kaynakAdi(tipografi, tipografiDamga)}`
                         + (tipografiDamga && tipografiOzeti(kurumTipografi) !== tipografiOzeti(tipografi)
                            ? ` · ${c('güncel kurum ayarı')}: ${tipografiOzeti(kurumTipografi)} (${c('bu rapora uygulanmaz')})` : '')}>
              🖨 {tipografiOzeti(tipografi)} <small>· {c(kaynakAdi(tipografi, tipografiDamga))}</small>
            </span>
          </div>}
          {etkinGiris === 'yapisal' && birads ? (
            <BiradsFormu durum={birads} setDurum={setBirads} modalite={modalite} genis kilitli={yazimKilit} />
          ) : <>
          {/* BİÇİM ÇUBUĞU (1195): imlecin bulunduğu alanda çalışır (tek A4 ya da herhangi bir bölüm). */}
          {bolumler.length > 0 && !yazimKilit && <BicimAracCubugu pasif={yazimKilit} />}
          {bolumler.length === 0 && (
            <div className="rad-a4 rad-bos-a4">
              <div className="rad-bos-ic">
                <div className="rad-bos-ikon">📄</div>
                <p><b>{c('Rapor boş.')}</b><br />{c('Bir şablon seçin ya da doğrudan yazmaya başlayın. Açılışta şablon otomatik uygulanmaz.')}</p>
                <button type="button" className="d bir" disabled={yazimKilit} onClick={() => setSablonModal(true)}>📄 {c('Şablon Seç…')}</button>
                <button type="button" className="d" disabled={yazimKilit} onClick={() => void guvenli(bosRapor)}>✎ {c('Serbest yaz')}</button>
                {(() => { const son = sablonlar.find(s => s.id === sablonTercihi.sonKullanilan(Number(istem?.hizmetId ?? 0)));
                  return son ? <p className="kucuk">{c('Son kullandığınız')}: <a href="#" onClick={e => { e.preventDefault(); void guvenli(() => sablonUygula(son.id)) }}>{son.ad}{son.kod ? ` · ${son.kod}` : ''}</a></p> : null })()}
              </div>
            </div>
          )}
          {duzen === 'tek' && tekParcaMi(bolumler) ? (
            <BicimliAlan className="rad-a4" html={htmlOf(bolumler[0])} salt={yazimKilit}
                         onFocus={() => { sonBolum.current = 0 }}
                         onDegis={(h, d) => bolumYaz(0, d, h)} />
          ) : bolumler.map((b, i) => (
            <div className="rad-bolum" key={`${b.baslik}-${i}`}>
              <div className="rad-bolum-bas">
                {b.baslik}{b.zorunlu === 1 && <span className="zor"> *</span>}
                {b.yazdir === 0 && <span className="sonuk kucuk"> · çıktıya basılmaz</span>}
              </div>
              <BicimliAlan className={`rad-bolum-metin${bulguBolumuMu(b.baslik) ? ' uzun' : ''}`}
                           html={htmlOf(b)} salt={yazimKilit}
                           onFocus={() => { sonBolum.current = i }}
                           onDegis={(h, d) => bolumYaz(i, d, h)} />
            </div>
          ))}
          </>}
        </div>

        {/* -------------------------------------------- SAĞ: şablon / makro --- */}
        <div className="rad-yan">
          {onceki && (() => {
            const g = gecmis.find(x => x.id === onceki.id);
            const durumAd = ({ 0: 'Raporsuz', 1: 'Taslak', 2: 'Ön rapor', 3: 'Onaylı' } as Record<number, string>)[Number(onceki.rapor?.durum ?? g?.raporDurum ?? 0)];
            const yol = onceki.buTetkik ? `/radyoloji/cikti/${onceki.surum}` : `/radyoloji/rapor/${onceki.id}`;
            return (
              <div className="rad-oniz rad-onceki">
                <div className="rad-onceki-bas">
                  <b>{c('Önceki rapor')}</b>
                  <span className="sonuk kucuk">{onceki.etiket ?? (g ? `${anMetni(g.tarih)} · ${g.tetkikAdi}` : '')}</span>
                  <button type="button" className="d mini" title={c('Raporu kendi sekmesinde aç')}
                          onClick={() => (ekranSekmesi ? ekranSekmesi.kartaGit(yol) : git(yol))}>↗</button>
                  <button type="button" className="d mini" title={c('Önceki raporu kapat')} onClick={() => setOnceki(null)}>✕</button>
                </div>
                {onceki.yukleniyor ? <div className="sonuk kucuk">{c('Yükleniyor…')}</div>
                 : onceki.hata ? <div className="kucuk rad-onceki-hata">{onceki.hata}</div>
                 : onceki.bolumler.length === 0 ? <div className="sonuk kucuk">{c('Bu tetkikin raporu yok.')}</div>
                 : <>
                     {!onceki.buTetkik && (onceki.revizeler?.length ?? 0) > 0 && (
                       <div className="kucuk" style={{ display: 'flex', flexWrap: 'wrap', gap: 4, margin: '2px 0 4px', alignItems: 'center' }}>
                         <b>{c('Önceki Revizeler')}:</b>
                         <button type="button" className={`d mini${onceki.surum == null ? ' bir' : ''}`}
                                 onClick={() => void oncekiSurum(null)}>{c('Güncel')}{onceki.rapor?.raporNo ? ` · ${String(onceki.rapor.raporNo)}` : ''}</button>
                         {onceki.revizeler!.map(v => (
                           <button key={v.id} type="button" className={`d mini${onceki.surum === v.id ? ' bir' : ''}`}
                                   title={`${v.neden}${v.revizeEden ? ` · ${v.revizeEden}` : ''}`}
                                   onClick={() => void oncekiSurum(v.id)}>
                             🗂 {v.raporNo || `#${v.id}`}
                           </button>))}
                       </div>)}
                     {onceki.surum != null && (() => {
                       const v = onceki.revizeler?.find(x => x.id === onceki.surum);
                       return (
                         <div className="kucuk" style={{ border: '1px solid #c0392b', color: '#c0392b', padding: '3px 6px', margin: '2px 0 4px' }}>
                           {c('REVİZE EDİLDİ — eski hâl, geçerli rapor değildir')}
                           {v?.revizeTarihi ? ` · ${anMetni(v.revizeTarihi)}` : ''}{v?.neden ? ` · ${v.neden}` : ''}
                         </div>);
                     })()}
                     <div className="sonuk kucuk">{durumAd}{g?.raporlayan ? ` · ${g.raporlayan}` : ''}</div>
                     <div className="rad-onceki-metin">
                       {onceki.bolumler.filter(b => b.yazdir !== 0).map((b, i) => (
                         <div className="rad-bolum" key={`${b.baslik}-${i}`}>
                           {b.baslik !== TEK_BASLIK && <div className="rad-bolum-bas">{b.baslik}</div>}
                           <BicimliAlan className="rad-a4 rad-onceki-a4 kucuk" html={htmlOf(b)} salt onDegis={() => undefined} />
                         </div>))}
                     </div>
                   </>}
              </div>
            );
          })()}
          {etkinGiris === 'yapisal' ? (
            <div className="rad-oniz">
              <div className="rad-oniz-bas">
                <b>{duzen === 'tek' ? c('Rapor önizleme (A4)') : c('Rapor bölümleri')}</b>
                <span className="rad-canli">● {c('canlı')}</span>
                {!kilitli && <button type="button" className="d mini" title={c('Girişi Serbest yapar; metin olduğu gibi kalır')}
                                     onClick={() => void girisDegistir('serbest')}>✎ {c('Elle düzenle')}</button>}
              </div>
              {duzen === 'tek' ? (
                <textarea className="rad-a4 kucuk" readOnly value={bolumler[0]?.metin ?? ''} />
              ) : bolumler.map((b, i) => {
                const formdan = bulguBolumuMu(b.baslik) || sonucBolumuMu(b.baslik);
                return (
                  <div className="rad-bolum" key={`${b.baslik}-${i}`}>
                    <div className="rad-bolum-bas">{b.baslik}
                      {formdan && <span className="sonuk kucuk"> · 🧩 {c('formdan')}</span>}</div>
                    <textarea value={b.metin} readOnly={kilitli || formdan} className={formdan ? 'formdan' : ''}
                              rows={bulguBolumuMu(b.baslik) ? 7 : 2}
                              // Düz kutudan düzenleme şablonun biçimli halini bırakır: yoksa çıktı eski HTML'i, Bakanlık
                              //   yeni metni alırdı (sunucu HTML varsa düz metni ondan türetir - tek kaynak).
                              onChange={e => setParcalar(p => p.map(x => (x.baslik === b.baslik
                                ? { ...x, metin: e.target.value, html: undefined } : x)))} />
                  </div>
                );
              })}
            </div>
          ) : biradsli && birads && (
            <BiradsFormu durum={birads} setDurum={setBirads} modalite={modalite} genis={false} kilitli={kilitli}
                         onAktar={biradsAktar} />
          )}
          {/* ✎ ŞABLON ETİKETİNİN SAĞINDA (kullanıcı 17.11.2026; önce Serbest/Yapısal'ın sağındaydı): rapor yazımını
              düzenlemeye alır / kapatır. */}
          <h5 style={{ marginTop: 12 }}>{c('Şablon')}
            <button type="button" className={`bs-kalem${yazimKilit ? '' : ' acik'}`} disabled={kilitli}
                    data-testid="rapor-kalem"
                    title={kilitli ? c('Onaylı rapor - düzeltme ek raporla') : raporDuzenle ? c('Düzenlemeyi kapat') : c('Raporu düzenle')}
                    onClick={() => setRaporDuzenle(v => !v)}>✎</button></h5>
          {/* COMBO YERİNE MODAL (kullanıcı 14.11.2026; mockup radyoloji_rapor_sablon_secimi.html): seçili şablonun adı ·
              kodu · sürümü + "Şablon Seç… / Değiştir…". Gruplama / arama / önizleme SablonSecModal'da. */}
          <div className="rad-sablon-satir">
            {seciliSablon
              ? <span className="rad-sablon-ad" title={seciliSablon.ad}><b>{seciliSablon.ad}</b>
                  <small>{seciliSablon.kod ? `${seciliSablon.kod} · ` : ''}v{seciliSablon.surum}</small></span>
              : <span className="rad-sablon-ad sonuk">— {c('seçilmedi')} —</span>}
            <button type="button" className={seciliSablon ? 'd' : 'd bir'} disabled={yazimKilit} onClick={() => setSablonModal(true)}>
              📄 {seciliSablon ? c('Değiştir…') : c('Şablon Seç…')}</button>
          </div>

          <h5 style={{ marginTop: 12 }}>{c('Makrolar')}</h5>
          {makrolar.length === 0 && <div className="sonuk kucuk">{c('Bu şablonda makro yok.')}</div>}
          {makrolar.map(m => (
            <button type="button" className="rad-makro" key={m.kisayol} disabled={yazimKilit || etkinGiris === 'yapisal'}
                    title={m.metin} onClick={() => makroEkle(m)}>
              <span className="kis">{m.kisayol}</span>
              <span>{m.ad}</span>
            </button>
          ))}

          {skorlar.length > 0 && (
            <>
              <h5 style={{ marginTop: 12, display: 'flex', alignItems: 'center', gap: 6 }}>{c('Yapılandırılmış Alanlar')}
                <span style={{ flex: 1 }} />
                <button type="button" className="d" disabled={yazimKilit} onClick={alanlariMetneEkle}
                        title={c('Doldurulan alanları cümle olarak Bulgular bölümüne ekler')}>↧ {c('Metne ekle')}</button></h5>
              {skorlar.map((s, i) => (<Fragment key={s.alanKod}>
                {s.grup && s.grup !== skorlar[i - 1]?.grup && <div className="rad-alan-grup">{s.grup}</div>}
                <label className="alan">
                  <span className="etiket">{s.alanAd}{s.zorunlu === 1 ? ' *' : ''}
                    {s.alanKod === 'tirads' && tiradsPuan !== null && (
                      <small className="rad-otomatik" title={c('ACR TI-RADS: bileşen puanlarının toplamı; kategori ve öneri kendiliğinden seçilir, elle değiştirilebilir')}>
                        {c('otomatik')} · {tiradsPuan} {c('puan')}</small>)}
                    {s.alanKod === 'fleischner' && fleischnerHesap && (
                      <small className="rad-otomatik" title={c('Fleischner 2017: nodül sayısı, tipi, çapı, solid komponent ve risk grubundan seçildi; elle değiştirilebilir')}>
                        {c('otomatik')}</small>)}</span>
                  {s.secenekler ? (
                    <select value={skorDeger[s.alanKod] ?? ''} disabled={kilitli}
                            onChange={e => alanDegistir(s.alanKod, e.target.value)}>
                      <option value="">—</option>
                      {s.secenekler.split('|').map(x => <option key={x} value={x}>{x}</option>)}
                    </select>
                  ) : (
                    <input value={skorDeger[s.alanKod] ?? ''} readOnly={kilitli}
                           onChange={e => alanDegistir(s.alanKod, e.target.value)} />
                  )}
                </label>
              </Fragment>))}
            </>
          )}

          {bakanlikProfili && (
            <>
              {/* RADYOLOG DEĞERLENDİRMESİ (kullanıcı 14.11.2026, eski ad Bakanlık Değerlendirmesi): iki puan da onayda zorunlu (1342). */}
              {/* GÖRÜNTÜLEME KİPİNDE DEĞİŞMEZ (kullanıcı 17.11.2026): puanlar ve kritik bulgu rapor yazımının ✎'ine bağlı. */}
              <h5 style={{ marginTop: 12 }}>{c('Radyolog Değerlendirmesi')}</h5>
              <label className={`alan${yazimKilit ? ' rad-alan-goster' : ''}`}>
                <span className="etiket">{c('İstem Nedeni')}</span>
                <select value={nedeniPuan} disabled={yazimKilit}
                        onChange={e => setNedeniPuan(Number(e.target.value))}>
                  {ISTEM_NEDENI_PUAN.map((ad, i) => (
                    <option key={i} value={i}>{i === 0 ? '—' : `${i} · ${ad}`}</option>
                  ))}
                </select>
              </label>
              <label className={`alan${yazimKilit ? ' rad-alan-goster' : ''}`}>
                <span className="etiket">{c('Çekim Kalitesi')}</span>
                <select value={kalitePuan} disabled={yazimKilit}
                        onChange={e => setKalitePuan(Number(e.target.value))}>
                  {CEKIM_KALITE_PUAN.map((ad, i) => (
                    <option key={i} value={i}>{i === 0 ? '—' : `${i} · ${ad}`}</option>
                  ))}
                </select>
              </label>
              <div className="not kucuk">
                Bakanlık Teleradyoloji mesajında (OBX-13) gider. <b>İki puan da verilmeden</b>, <b>Bulgular en az
                50 karakter</b> ve <b>{c('Sonuç ve Öneriler')}</b> dolu olmadan rapor
                onaylanamaz.
              </div>
            </>
          )}

          <h5 style={{ marginTop: 12 }}>Kritik Bulgu</h5>
          <label className="alan yatay">
            {/* Açık (teyit bekleyen) bildirim varken işaret kaldırılamaz - sunucu da reddeder (15.11.2026). */}
            <input type="checkbox" checked={kritik} disabled={yazimKilit || (kritik && kritikler.some(k => !k.kapatmaZamani))}
                   title={kritik && kritikler.some(k => !k.kapatmaZamani) ? c('Açık bildirim var: önce Kritik Bulgular listesinde teyit alındı diye kapatın.') : undefined}
                   onChange={e => setKritik(e.target.checked)} />
            <span>{c('Bu tetkikte kritik bulgu var')}</span>
          </label>
          <div className="uyari-kutusu kucuk">
            İşaretliyse <b>bildirim kaydı olmadan rapor onaylanamaz</b>: kime, hangi yolla ve
            ne zaman haber verildiği kayda geçer.
          </div>

          {/* KONSULTASYON (304): supheli olguda ikinci gorus. Rapor kilitli
              olsa da istenebilir - gorus geldiginde addendum yazilir. */}
          <h5 style={{ marginTop: 12 }}>{c('Konsültasyon')}</h5>
          <button className="d mini" onClick={() => setKonsModal(true)}>
            ＋ İkinci Görüş İste
          </button>
          {konsultasyonlar.length === 0 && (
            <div className="not kucuk">{c('İstenmiş konsültasyon yok.')}</div>
          )}
          {konsultasyonlar.map(k => (
            <div className="kons-satir" key={String(k.id)}>
              <div>
                <b>{String(k.hekim ?? '') || String(k.kurum ?? '') || '—'}</b>
                <span className={`rozet ${Number(k.durum ?? 0) === 2 ? 'basari' : 'uyari'}`}>
                  {Number(k.durum ?? 0) === 2 ? 'Görüş geldi' : 'Bekliyor'}
                </span>
              </div>
              <div className="sonuk">{String(k.gerekce ?? '')}</div>
              {String(k.gorus ?? '').trim() !== '' && (
                <div className="kons-gorus">{String(k.gorus)}</div>
              )}
              {Number(k.durum ?? 0) !== 2 && (
                <button className="d mini"
                        onClick={() => setGorusYaz({ id: Number(k.id), gorus: '' })}>
                  ✎ Görüşü Gir
                </button>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Konsultasyon ISTEGI: hekim listesi rapor ekraninda zaten yok, bu
          yuzden serbest metin gerekce + (opsiyonel) hekim secimi yerine
          gerekce yeterli - gorusu YAZAN kisi kayittan belli olur. */}
      {konsModal && (
        <Modal baslik="İkinci Görüş İste" dar onKapat={() => setKonsModal(false)}
               alt={<>
                 <button className="d bir" onClick={() => void guvenli(async () => {
                   await api.radyolojiKonsultasyon(id, { gerekce: konsForm.gerekce,
                                                         hekimId: null, kurumId: null });
                   setKonsModal(false);
                   setKonsForm({ hekimId: '', gerekce: '' });
                   await yukle();
                   mesaj('Konsültasyon istendi.');
                 })}>Gönder</button>
                 <button className="d" onClick={() => setKonsModal(false)}>✖ Kapat</button>
               </>}>
          <div className="alan-izgara tek-sutun">
            <label className="alan">
              <span className="etiket zorunlu-isaret">Gerekçe</span>
              <textarea rows={3} value={konsForm.gerekce}
                        placeholder="örn. L4-L5 düzeyinde şüpheli lezyon; nöroradyoloji görüşü."
                        onChange={e => setKonsForm(f => ({ ...f, gerekce: e.target.value }))} />
            </label>
          </div>
        </Modal>
      )}

      {gorusYaz && (
        <Modal baslik="Konsültasyon Görüşü" dar onKapat={() => setGorusYaz(null)}
               alt={<>
                 <button className="d bir" onClick={() => void guvenli(async () => {
                   await api.radyolojiKonsultasyon(id, { gorus: gorusYaz.gorus, gerekce: '' },
                                                   gorusYaz.id);
                   setGorusYaz(null);
                   await yukle();
                   mesaj('Görüş kaydedildi.');
                 })}>Kaydet</button>
                 <button className="d" onClick={() => setGorusYaz(null)}>✖ Kapat</button>
               </>}>
          <div className="alan-izgara tek-sutun">
            <label className="alan">
              <span className="etiket zorunlu-isaret">{c('Görüş')}</span>
              <textarea rows={4} value={gorusYaz.gorus}
                        onChange={e => setGorusYaz(g => (g ? { ...g, gorus: e.target.value } : g))} />
            </label>
          </div>
          <div className="not">
            Gelen görüş raporu DEĞİŞTİRMEZ; onaylı raporda düzeltme gerekiyorsa
            “＋ Ek Rapor” ile addendum yazın.
          </div>
        </Modal>
      )}

      {sablonModal && (
        <SablonSecModal sablonlar={sablonlar} seciliId={sablonId} hizmetId={Number(istem?.hizmetId ?? 0)}
                        modalite={Number(istem?.modalite ?? 0)} raporDolu={bolumler.some(b => b.metin.trim())}
                        onizlemeGetir={sablonOnizleme}
                        onUygula={async sId => { await guvenli(() => sablonUygula(sId)) }}
                        onBos={() => void guvenli(bosRapor)}
                        onKapat={() => setSablonModal(false)} />
      )}
      {parolaIstek && (
        <ParolaPenceresi kisi={parolaIstek.kisi} amac={parolaIstek.amac}
          onTamam={p => { parolaIstek.coz(p); setParolaIstek(null) }}
          onKapat={() => { parolaIstek.coz(null); setParolaIstek(null) }} />
      )}
      {eimzaModal && (
        <EImzaModal baslik="e-İmza ile Onayla" onKapat={() => setEimzaModal(false)} onImzala={eimzaIleOnayla} />
      )}

      {kritikModal && (
        <Modal baslik="Kritik Bulgu Bildirimi" onKapat={() => setKritikModal(false)}
               alt={<>
                 {/* Boş bildirim kaydedilmez (K22): bulgu ve bildirilen kişi zorunlu - sunucu da reddeder. */}
                 <button className="d bir" disabled={!kritikForm.bulgu.trim() || !kritikForm.bildirilenAd.trim()}
                         onClick={() => void kritikKaydet()}>Kaydet</button>
                 <span className="ck-bosluk" />
                 {/* Kapat sağa yaslı (kullanıcı 15.11.2026). */}
                 <button className="d" onClick={() => setKritikModal(false)}>✖ Kapat</button>
               </>}>
          <div className="alan-izgara tek-sutun">
            <label className="alan"><span className="etiket">{c('Bildiren')}</span>
              <select value={kritikForm.bildirenId ?? ''}
                      onChange={e => setKritikForm(f => ({ ...f, bildirenId: Number(e.target.value) || null }))}>
                {radyologlar.length === 0 && <option value="">{c('Ben (oturum kullanıcısı)')}</option>}
                {radyologlar.map(r => <option key={r.id} value={r.id}>{r.ad}{Number(r.ben) === 1 ? ` · ${c('ben')}` : ''}</option>)}
              </select></label>
            <label className="alan"><span className="etiket">Bulgu</span>
              <input value={kritikForm.bulgu}
                     onChange={e => setKritikForm(f => ({ ...f, bulgu: e.target.value }))} /></label>
            <label className="alan"><span className="etiket">{c('Bildirilen kişi')}</span>
              <input value={kritikForm.bildirilenAd}
                     onChange={e => setKritikForm(f => ({ ...f, bildirilenAd: e.target.value }))} /></label>
            <label className="alan"><span className="etiket">Yol</span>
              <select value={kritikForm.yol}
                      onChange={e => setKritikForm(f => ({ ...f, yol: Number(e.target.value) }))}>
                {Object.entries(KRITIK_YOL).map(([k, v]) =>
                  <option key={k} value={k}>{v}</option>)}
              </select></label>
            <label className="alan"><span className="etiket">{c('Geri bildirim')}</span>
              <input value={kritikForm.geriBildirim}
                     onChange={e => setKritikForm(f => ({ ...f, geriBildirim: e.target.value }))} /></label>
          </div>
        </Modal>
      )}
    </div>
  );
}
