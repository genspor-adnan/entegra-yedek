import { useCallback, useContext, useEffect, useRef, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { gorunumKaydet, gorunumOku, type RadyolojiRaporDuzeni, type RadyolojiRaporGiris } from '../bilesenler/gorunum';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../bilesenler/mesaj';
import { tarihSaat } from '../bilesenler/bicim';
import { Modal } from '../bilesenler/Modal';
import { MuayeneHastaBandi, useMuayeneHastaBilgisi } from '../bilesenler/MuayeneSekmesiz';
import { c } from '../dil/ceviri';
import { EkranSekmesiBaglami, sekmeAdi } from '../bilesenler/sekmeBaglami';
import { TEK_BASLIK, bulguBolumuMu, sonucBolumuMu, tekMetneBolumYaz, tekParcaMi, yerTutucuDoldur } from './radyoloji/raporBicimi';
import { biradsGovdesi, durumOku, metinUret, modaliteKodundan, type BiradsDurumu } from './radyoloji/birads';
import { BiradsFormu } from './radyoloji/BiradsFormu';
import { BicimAracCubugu, BicimliAlan, bicimVarMi, duzdenHtml } from '../bilesenler/BicimliMetin';
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
                   modalite?: number; yapisalTur?: number }
interface Makro { kisayol: string; ad: string; metin: string; hedefBolum: string }
interface Skor { alanKod: string; alanAd: string; tip: number; secenekler: string;
                 zorunlu: number; raporaBas: number }
interface Gecmis { id: number; accessionNo: string; tetkikAdi: string; tarih: string;
                   raporlayan: string; ozet: string;
                   /** Kronolojik görünüm (27.10.2026): modalite adı, rapor durumu (0 yok, 1-3), BI-RADS. */
                   modaliteAdi?: string; raporDurum?: number; birads?: string }
interface Kritik { bulgu: string; bildirilenAd: string; yol: number;
                   bildirimZamani: string; geriBildirim: string }

type Kayit = Record<string, unknown>;

/**
 * TEK / PARÇALI (kullanıcı 27.10.2026: "daha önce programımızda radyoloji raporu tek parça halinde yazılıyordu..
 * bazı doktorlar o şekilde devam etmek istiyor", "onların şablonları da genelde A4 boyutunda tek sayfa idi").
 * Tek modda rapor TEK BÖLÜM olarak saklanır (başlık TEK_BASLIK, radyoloji/raporBicimi): şema, onay, çıktı, e-Nabız aynı yoldan geçer.
 * Şablon tek modda bölüm başlıkları + varsayılan metinlerle TEK A4 METNİNE birleşir. Onaydaki zorunlu bölüm
 * kuralı şablon bölüm adıyla eşleştiği için tek bölüme uygulanmaz.
 */
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
  const [sablonlar, setSablonlar] = useState<Sablon[]>([]);
  const [makrolar, setMakrolar] = useState<Makro[]>([]);
  const [skorlar, setSkorlar] = useState<Skor[]>([]);
  const [skorDeger, setSkorDeger] = useState<Record<string, string>>({});
  const [gecmis, setGecmis] = useState<Gecmis[]>([]);
  const [kritikler, setKritikler] = useState<Kritik[]>([]);
  const [sablonId, setSablonId] = useState<number | null>(null);
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
  /**
   * KONSULTASYON (304): ikinci gorus. Istek ve DONEN GORUS ayni yerden
   * yazilir - gorus alanina yazip kaydetmek kaydi "dondu"ye gecirir.
   */
  const [konsultasyonlar, setKonsultasyonlar] = useState<Kayit[]>([]);
  const [konsModal, setKonsModal] = useState(false);
  const [konsForm, setKonsForm] = useState({ hekimId: '', gerekce: '' });
  const [gorusYaz, setGorusYaz] = useState<{ id: number; gorus: string } | null>(null);
  const [kritikForm, setKritikForm] = useState({ bulgu: '', bildirilenAd: '', yol: 1,
                                                 geriBildirim: '' });
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
      const konsultasyonlar = await api.radyolojiKonsultasyonlar(id);
      if (sira !== yukleSira.current) return;
      setKonsultasyonlar(konsultasyonlar);
      setKritik(Number(y.istem?.kritik ?? 0) === 1);
      setBakanlikProfili(Boolean(y.bakanlikProfili));
      setNedeniPuan(Number(y.rapor?.istemNedeniPuan ?? 0));
      setKalitePuan(Number(y.rapor?.cekimKalitePuan ?? 0));

      const sec = (y.rapor?.sablonId as number | undefined)
               ?? (y.sablonlar as unknown as Sablon[])[0]?.id ?? null;
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
        // Yapısal tek parça raporda iskelet şablondan (tek metin bölünemez).
        if (yapisalAcilis) setParcalar(!tekParcaMi(kb) ? kb : sec ? await sablonParcalari(sec, y.istem) : []);
      } else if (sec) {
        await sablonUygula(sec, true, y.istem);
      }

      const d: Record<string, string> = {};
      (y.alanlar as Kayit[]).forEach(a => { d[String(a.alanKod)] = String(a.deger ?? '') });
      setSkorDeger(d);
    } catch (h) { if (sira === yukleSira.current) setHata(hataMetni(h)) }
    finally { if (sira === yukleSira.current) setYukleniyor(false) }
  // sablonUygula bilerek bagimlilikta degil: ilk yuklemede tek yon calisir.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  useEffect(() => { void yukle() }, [yukle]);
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
    setParcalar(yeniParcalar);
    setBolumler(duzenRef.current === 'tek' ? tekBolum(birlestir(yeniParcalar)) : yeniParcalar);
    setSablonId(sId);
    // Yeni şablonun BI-RADS formu varsa form (yoksa boş) hazırlanır; olmayan şablonda form durumu kalır, kullanılmaz.
    const sb = sablonlar.find(s => s.id === sId);
    if (Number(sb?.yapisalTur ?? 0) === 1 && !birads) setBiradsDurumu(durumOku(null, [], modaliteKodundan(sb?.modalite)));
    const m = await api.radyolojiRapor(id);
    setMakrolar(m.makrolar as unknown as Makro[]);
  }

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
      return {
        sira: Number(b.sira ?? i + 1), baslik,
        metin: !varsayilan && klinikMi ? klinik : varsayilan,
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
  const kaydet = async (sonra?: (k: { raporId: number; surum: string }) => Promise<void>) => {
    if (islemdeRef.current) return false;
    islemdeRef.current = true; setIslemde(true);
    try {
      return await guvenli(async () => {
        const k = await api.radyolojiRaporYaz(id, govde());
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
  const uzmanSec = async (): Promise<{ id: number; not: string } | null> => {
    const liste = await api.radyolojiOnayUzmanlari();
    if (liste.length === 0) { mesaj('Bu şubede rapor onaylama yetkisi olan uzman yok.'); return null }
    let son = '';
    try { son = localStorage.getItem('rad.sonUzman') ?? '' } catch { /* yerel depo kapalı */ }
    const onceki = String(rapor?.onaylayacakId ?? '');
    const varsayilan = [onceki, son].find(k => k && liste.some(u => String(u.id) === k)) ?? String(liste[0].id);
    const secilen = await listeSor('Raporu onaylayacak uzmanı seçin.',
      liste.map(u => ({ kod: String(u.id), ad: `${u.ad} — ${u.bekleyen} onay bekliyor` })), varsayilan, 'Onaylayacak uzman');
    if (!secilen) return null;
    try { localStorage.setItem('rad.sonUzman', secilen) } catch { /* yerel depo kapalı */ }
    // NOT (1200): isteğe bağlı; uzman raporu açınca bandın altında sarı şerit. Vazgeç = gönderim iptal.
    const not = await metinSor('Uzmana not (isteğe bağlı):', '', 'ör. Sol memedeki lezyona özellikle bakar mısınız?');
    if (not === null) return null;
    return { id: Number(secilen), not: not.trim() };
  };

  const durumaGecir = async (hedef: 'on-rapor' | 'onay') => {
    if (islemdeRef.current) return;
    // ONAY SORUSU (K55): imza geri alınamaz - kilitlemeden önce sorulur.
    if (hedef === 'onay' && !await onay('Rapor onaylanıp imzalanacak ve kilitlenecek. Devam edilsin mi?')) return;
    let uzman: { id: number; not: string } | undefined;
    if (hedef === 'on-rapor') {
      // guvenli yalniz basari bayragi doner - secim disaridaki degiskene yazilir.
      let secilen: { id: number; not: string } | null = null;
      if (!await guvenli(async () => { secilen = await uzmanSec() }) || !secilen) return;
      uzman = secilen;
    }
    await kaydetVeGecir(hedef, uzman);
  };

  const kaydetVeGecir = (hedef: 'on-rapor' | 'onay', uzman?: { id: number; not: string }) => kaydet(async ({ raporId, surum }) => {
    if (!raporId) throw new Error('Rapor bulunamadı.');
    await api.radyolojiRaporDurum(raporId, hedef, surum, uzman?.id, uzman?.not);
    mesaj(hedef === 'onay'
      ? 'Rapor onaylandı ve imzalandı; artık kilitlidir.'
      : 'Ön rapor uzman onayına gönderildi.');
  });

  const kritikKaydet = () => guvenli(async () => {
    await api.radyolojiKritikBulgu(id, kritikForm);
    setKritikModal(false);
    setKritikForm({ bulgu: '', bildirilenAd: '', yol: 1, geriBildirim: '' });
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
  const bant = useMuayeneHastaBilgisi(0, 0, Number(istem?.hastaId ?? 0));

  if (yukleniyor) return <div className="yukleniyor">{c('Yükleniyor…')}</div>;
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!istem) return <div className="hata-kutusu">{c('İstem bulunamadı.')}</div>;

  const kilitli = Number(rapor?.kilit ?? 0) === 1;
  // ONAYLAYACAK → ONAYLAYAN (1199): onaya kadar seçilen uzman + bekleme süresi, onaydan sonra imzalayan.
  //   Başka bir uzman onayladıysa (izin / nöbet) "(X yerine)". Kendi onaylayan akışta onaylayacak hiç yok.
  const onayBlogu = () => {
    if (!rapor) return null;
    const onayli = Number(rapor.durum ?? 0) === 3;
    if (onayli) return <>
      <div className="hbnd-b">✔ {c('Onaylayan')}</div>
      <div><b>{String(rapor.onaylayan ?? '') || '—'}</b></div>
      <div className="hbnd-alt">
        {rapor.onaylayacakId && Number(rapor.onaylayacakId) !== Number(rapor.onaylayanId)
          ? `(${String(rapor.onaylayacak)} ${c('yerine')}) ` : ''}
        {rapor.onayTarihi ? `${saatYaz(rapor.onayTarihi)} · e-imza` : ''}</div>
    </>;
    return <>
      <div className="hbnd-b">⏳ {c('Onaylayacak')}</div>
      {String(rapor.onaylayacak ?? '')
        ? <><div><b>{String(rapor.onaylayacak)}</b></div>
            {rapor.onayaGonderme && <div className="hbnd-alt rad-bekliyor">{c('bekliyor')} · {sureYaz(rapor.onayaGonderme)}</div>}</>
        : <div className="hbnd-alt">— {c('gönderirken seçilir')}</div>}
    </>;
  };
  const durum = RAPOR_DURUM[Number(rapor?.durum ?? 1)] ?? RAPOR_DURUM[1];
  const yas = istem.dogumTarihi
    ? Math.floor((Date.now() - new Date(String(istem.dogumTarihi)).getTime())
                 / 31557600000)
    : null;

  return (
    <div className="sayfa rad-rapor">
      <div className="sayfa-bas">
        {/* BAŞLIK SATIRI KALKTI (kullanıcı 27.10.2026): sekme başlığı hasta adı; accession no solda "Bu tetkik"te. */}
        <div className="sayfa-eylem">
          <button className="d bir" disabled={kilitli || islemde} onClick={() => void kaydet()}>{c('💾 Taslak Kaydet')}</button>
          <button className="d" disabled={kilitli || islemde}
                  onClick={() => void durumaGecir('on-rapor')}>➜ Uzmana Gönder</button>
          <button className="d basari" disabled={kilitli || islemde}
                  onClick={() => void durumaGecir('onay')}>✍ Onayla ve İmzala</button>
          <button className="d teh" disabled={kilitli}
                  onClick={() => setKritikModal(true)}>⚠ Kritik Bulgu Bildir</button>
          {kilitli && <button className="d" onClick={() => void addendum()}>＋ Ek Rapor</button>}
          {/* İSTEM (kullanıcı 27.10.2026): istem kartını kendi sekmesinde açar. */}
          <button className="d" title={c('Radyoloji istem kartını aç')}
                  onClick={() => (ekranSekmesi ? ekranSekmesi.kartaGit(`/radyoloji/${id}`) : git(`/radyoloji/${id}`))}>☢️ İstem</button>
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

      {/* RADYOLOJİ BANDI (kullanıcı 27.10.2026): kan grubu yok, raporun DURUMU bandın sonunda. */}
      {bant && <MuayeneHastaBandi bilgi={bant} kanGrubuYok
        suAnYerine={<>
          <div className="hbnd-b">🩺 {c('İsteyen')}</div>
          <div><b>{String(istem.isteyen ?? '') || '—'}</b></div>
          {String(istem.isteyenBolum ?? '') && <div className="hbnd-alt">{String(istem.isteyenBolum)}</div>}
        </>}
        sonBlok={[
          // YAZAN · ONAYLAYACAK/ONAYLAYAN · DURUM (kullanıcı 28.10.2026, mockup seçenek C).
          rapor?.yazan ? <>
            <div className="hbnd-b">✍ {c('Yazan')}</div>
            <div><b>{String(rapor.yazan)}</b></div>
            <div className="hbnd-alt">{Number(rapor.yazanAsistan) === 1 && <span className="rozet rad-asistan">{c('asistan')}</span>}
              {rapor.yazmaTarihi ? ` ${saatYaz(rapor.yazmaTarihi)}` : ''}</div>
          </> : null,
          onayBlogu(),
          <>
            <div className="hbnd-b">{c('Durum')}</div>
            <div className="hbnd-rozetler"><span className={`rozet ${durum.sinif}`}>{durum.ad}</span>
              {kilitli && <span className="rozet">🔒 {c('Kilitli')}</span>}</div>
            {String(rapor?.raporNo ?? '') && <div className="hbnd-alt">{String(rapor?.raporNo)}</div>}
          </>,
        ]} />}
      {/* UZMANA NOT (1200): ön rapor beklerken bandın altında sarı şerit - uzman raporu açınca ilk bunu görür. */}
      {Number(rapor?.durum ?? 0) === 2 && String(rapor?.onayNotu ?? '').trim() !== '' && (
        <div className="rad-onay-notu">📝 <b>{String(rapor?.yazan ?? '') || c('Gönderen')}:</b> {String(rapor?.onayNotu)}</div>
      )}
      {/* KİMLİK ŞERİDİ KALKTI (kullanıcı 27.10.2026: "hasta bandının altındaki banttaki bilgileri soldaki önceki
          tetkiklere taşı ve bu bandı kaldır"): tetkik ve çekim solda "Bu tetkik" düğümünde, hasta ve durum bantta.
          Bant okunamazsa (yedek) yalnız hasta + durum şeridi kalır. */}
      {!bant && (
        <div className="kaid">
          <div className="alan-izgara rad-kimlik bantsiz">
            <label className="alan"><span className="etiket">Hasta</span>
              <span className="deger-serit">
                <b>{String(istem.hastaAdi ?? '')}</b>
                {yas !== null && <span className="sonuk">{yas} y</span>}
              </span></label>
            <label className="alan"><span className="etiket">Durum</span>
              <span className="deger-serit"><span className={`rozet ${durum.sinif}`}>{durum.ad}</span>
                {kilitli && <span className="rozet">🔒 Kilitli</span>}
              </span></label>
          </div>
        </div>
      )}

      <div className={`rad-govde${etkinGiris === 'yapisal' ? ' yapisal' : ''}`}>
        {/* --------------------------------------------------- SOL: geçmiş --- */}
        <div className="rad-yan">
          <h5>{c('Önceki Tetkikler')}</h5>

          {/* KRONOLOJİK GÖRÜNÜM (kullanıcı 27.10.2026): zaman çizgisi - en yeni üstte, yıl başlıkları,
              bu tetkik en üstte "şimdi" düğümü. Tıklayınca o tetkikin raporu kendi sekmesinde açılır. */}
          <div className="rad-zc">
              <div className="rad-zc-dugum simdi">
                <div className="rad-zc-tarih">{c('Bu tetkik')}
                  {istem.tetkikKodu ? <span className="rad-zc-mod">{String(istem.tetkikKodu)}</span> : null}</div>
                {istem.accessionNo ? <div className="sonuk kucuk" title={c('Erişim numarası: PACS ve cihazlar görüntüyü bu numarayla istemle eşleştirir')}>
                  {c('Accession')}: <b>{String(istem.accessionNo)}</b></div> : null}
                <b>{String(istem.tetkikAdi ?? '')}</b>
                <div className="sonuk kucuk">{c('Çekim')}: {istem.cekimTarihi ? anMetni(istem.cekimTarihi) : '—'}
                  {istem.cihazAdi ? ` · ${String(istem.cihazAdi)}` : ''}</div>
              </div>
              {gecmis.length === 0 && <div className="sonuk kucuk rad-zc-bos">{c('Önceki tetkik yok.')}</div>}
              {gecmis.map((g, i) => {
                const yil = g.tarih ? new Date(g.tarih).getFullYear() : 0;
                const oncekiYil = i > 0 && gecmis[i - 1].tarih ? new Date(gecmis[i - 1].tarih).getFullYear() : null;
                const durumAd = ({ 0: 'Raporsuz', 1: 'Taslak', 2: 'Ön rapor', 3: 'Onaylı' } as Record<number, string>)[Number(g.raporDurum ?? 0)];
                return (
                  <div key={g.id}>
                    {yil > 0 && yil !== oncekiYil && <div className="rad-zc-yil">{yil}</div>}
                    <button type="button" className={`rad-zc-dugum d${Number(g.raporDurum ?? 0)}`}
                            title={c('Raporu kendi sekmesinde aç')}
                            onClick={() => (ekranSekmesi ? ekranSekmesi.kartaGit(`/radyoloji/rapor/${g.id}`) : git(`/radyoloji/rapor/${g.id}`))}>
                      <div className="rad-zc-tarih">
                        {anMetni(g.tarih)}
                        {g.modaliteAdi && <span className="rad-zc-mod">{g.modaliteAdi}</span>}
                        {g.birads && <span className={`brf-k k${g.birads[0]}`}>BI-RADS {g.birads}</span>}
                      </div>
                      <b>{g.tetkikAdi}</b>
                      <div className="sonuk kucuk">{durumAd}{g.raporlayan ? ` · ${g.raporlayan}` : ''}</div>
                      {g.ozet && <div className="kucuk rad-zc-ozet">{g.ozet}…</div>}
                    </button>
                  </div>
                );
              })}
          </div>

          <h5>İstem Bilgisi</h5>
          <div className="rad-kart">
            <div><b>{c('Ön tanı:')}</b> {String(istem.onTani ?? '—')}</div>
            <div><b>{c('Klinik:')}</b> {String(istem.klinikBilgi ?? '—')}</div>
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
        <div className="rad-orta">
          <div className="rad-duzen">
            <span>{c('Rapor biçimi')}</span>
            <span className="seg" role="group">
              {(['tek', 'parcali'] as const).map(d => (
                <button key={d} type="button" className={duzen === d ? 'on' : ''} disabled={kilitli}
                        onClick={() => void duzenDegistir(d)}>{d === 'tek' ? c('Tek') : c('Parçalı')}</button>
              ))}
            </span>
            <span>{c('Giriş')}</span>
            <span className="seg" role="group">
              {(['serbest', 'yapisal'] as const).map(g => (
                <button key={g} type="button" className={etkinGiris === g ? 'on' : ''}
                        disabled={kilitli || (g === 'yapisal' && !biradsli)}
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
          </div>
          {etkinGiris === 'yapisal' && birads ? (
            <BiradsFormu durum={birads} setDurum={setBirads} modalite={modalite} genis kilitli={kilitli} />
          ) : <>
          {/* BİÇİM ÇUBUĞU (1195): imlecin bulunduğu alanda çalışır (tek A4 ya da herhangi bir bölüm). */}
          {bolumler.length > 0 && <BicimAracCubugu pasif={kilitli} />}
          {bolumler.length === 0 && (
            <div className="bilgi-kutusu">
              Şablon seçilmemiş. Sağdan bir şablon seçip uygulayın.
            </div>
          )}
          {duzen === 'tek' && tekParcaMi(bolumler) ? (
            <BicimliAlan className="rad-a4" html={htmlOf(bolumler[0])} salt={kilitli}
                         onFocus={() => { sonBolum.current = 0 }}
                         onDegis={(h, d) => bolumYaz(0, d, h)} />
          ) : bolumler.map((b, i) => (
            <div className="rad-bolum" key={`${b.baslik}-${i}`}>
              <div className="rad-bolum-bas">
                {b.baslik}{b.zorunlu === 1 && <span className="zor"> *</span>}
                {b.yazdir === 0 && <span className="sonuk kucuk"> · çıktıya basılmaz</span>}
              </div>
              <BicimliAlan className={`rad-bolum-metin${bulguBolumuMu(b.baslik) ? ' uzun' : ''}`}
                           html={htmlOf(b)} salt={kilitli}
                           onFocus={() => { sonBolum.current = i }}
                           onDegis={(h, d) => bolumYaz(i, d, h)} />
            </div>
          ))}
          </>}
        </div>

        {/* -------------------------------------------- SAĞ: şablon / makro --- */}
        <div className="rad-yan">
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
                              onChange={e => setParcalar(p => p.map(x => (x.baslik === b.baslik ? { ...x, metin: e.target.value } : x)))} />
                  </div>
                );
              })}
            </div>
          ) : biradsli && birads && (
            <BiradsFormu durum={birads} setDurum={setBirads} modalite={modalite} genis={false} kilitli={kilitli}
                         onAktar={biradsAktar} />
          )}
          <h5 style={{ marginTop: 12 }}>Şablon</h5>
          <select value={sablonId ?? ''} disabled={kilitli}
                  onChange={e => { const v = Number(e.target.value); if (v > 0) void sablonUygula(v) }}>
            <option value="">— seçiniz —</option>
            {sablonlar.map(s => (
              <option key={s.id} value={s.id}>
                {s.kod ? `${s.kod} · ` : ''}{s.ad}{s.tetkigeOzel === 1 ? ' ★' : ''}
              </option>
            ))}
          </select>

          <h5 style={{ marginTop: 12 }}>{c('Makrolar')}</h5>
          {makrolar.length === 0 && <div className="sonuk kucuk">{c('Bu şablonda makro yok.')}</div>}
          {makrolar.map(m => (
            <button type="button" className="rad-makro" key={m.kisayol} disabled={kilitli || etkinGiris === 'yapisal'}
                    title={m.metin} onClick={() => makroEkle(m)}>
              <span className="kis">{m.kisayol}</span>
              <span>{m.ad}</span>
            </button>
          ))}

          {skorlar.length > 0 && (
            <>
              <h5 style={{ marginTop: 12 }}>{c('Yapılandırılmış Alanlar')}</h5>
              {skorlar.map(s => (
                <label className="alan" key={s.alanKod}>
                  <span className="etiket">{s.alanAd}{s.zorunlu === 1 ? ' *' : ''}</span>
                  {s.secenekler ? (
                    <select value={skorDeger[s.alanKod] ?? ''} disabled={kilitli}
                            onChange={e => setSkorDeger(d => ({ ...d, [s.alanKod]: e.target.value }))}>
                      <option value="">—</option>
                      {s.secenekler.split('|').map(x => <option key={x} value={x}>{x}</option>)}
                    </select>
                  ) : (
                    <input value={skorDeger[s.alanKod] ?? ''} readOnly={kilitli}
                           onChange={e => setSkorDeger(d => ({ ...d, [s.alanKod]: e.target.value }))} />
                  )}
                </label>
              ))}
            </>
          )}

          {bakanlikProfili && (
            <>
              <h5 style={{ marginTop: 12 }}>{c('Bakanlık Değerlendirmesi')}</h5>
              <label className="alan">
                <span className="etiket">{c('İstem Nedeni')}</span>
                <select value={nedeniPuan} disabled={kilitli}
                        onChange={e => setNedeniPuan(Number(e.target.value))}>
                  {ISTEM_NEDENI_PUAN.map((ad, i) => (
                    <option key={i} value={i}>{i === 0 ? '—' : `${i} · ${ad}`}</option>
                  ))}
                </select>
              </label>
              <label className="alan">
                <span className="etiket">{c('Çekim Kalitesi')}</span>
                <select value={kalitePuan} disabled={kilitli}
                        onChange={e => setKalitePuan(Number(e.target.value))}>
                  {CEKIM_KALITE_PUAN.map((ad, i) => (
                    <option key={i} value={i}>{i === 0 ? '—' : `${i} · ${ad}`}</option>
                  ))}
                </select>
              </label>
              <div className="not kucuk">
                Bakanlık Teleradyoloji mesajında (OBX-13) gider. <b>Bulgular en az
                50 karakter</b> ve <b>{c('Sonuç ve Öneriler')}</b> dolu olmadan rapor
                onaylanamaz.
              </div>
            </>
          )}

          <h5 style={{ marginTop: 12 }}>Kritik Bulgu</h5>
          <label className="alan yatay">
            <input type="checkbox" checked={kritik} disabled={kilitli}
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

      {kritikModal && (
        <Modal baslik="Kritik Bulgu Bildirimi" onKapat={() => setKritikModal(false)}
               alt={<>
                 {/* Boş bildirim kaydedilmez (K22): bulgu ve bildirilen kişi zorunlu - sunucu da reddeder. */}
                 <button className="d bir" disabled={!kritikForm.bulgu.trim() || !kritikForm.bildirilenAd.trim()}
                         onClick={() => void kritikKaydet()}>Kaydet</button>
                 <button className="d" onClick={() => setKritikModal(false)}>✖ Kapat</button>
               </>}>
          <div className="alan-izgara tek-sutun">
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
