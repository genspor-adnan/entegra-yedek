import { useCallback, useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { type Kosul, type ListeSatiri, hataMetni } from '../api/sozlesme';
import { GenForm } from './GenForm';
import { aramaSirala } from './aramaSirasi';
import { ayarSayi } from '../api/ayarlar';
import { c } from '../dil/ceviri';
import { KimlikOkutPenceresi } from './kimlik/KimlikOkutPenceresi';
import { mrzBekleyenKoy } from './kimlik/mrzAktarim';
import { ekOnbellegiTemizle } from './cariArama';
import { TARAF_DUZENLERI } from './tarafDuzenleri';
import { OnizlemeBasligi } from './TarafAramaOrtak';
import { filtreBirlestir } from './gridSorgu';
import { type TarafBaglam, duzenKosulu, onizlemeOku, onizlemeYaz } from './tarafDuzeni';

interface TarafSatiri {
  kaynak: string;
  id: number;
  tip: string;
  kod: string;
  unvan: string;
  bagliKurum: string;
  gorevRol: string;
  bolum: string;
  /** HASTA duzeni (kayit kabul): kolonlar taraf yerine hasta bilgileri. */
  cinsiyet: string;
  yas: string;
  telefon: string;
  sonBasvuru: string;
  /** Son başvurunun bölümü (hasta listesi `sonBolum`). */
  sonBolum: string;
  /** DIS HEKIM duzeni (305): brans, kurum ve gonderdigi tetkik sayisi. */
  brans: string;
  kurum: string;
  istemSayisi: string;
  /** BASVURU HEKIMI duzeni (583): bolum ve hekimin BUGUNKU basvuru sayisi. */
  bolumAdi: string;
  bugunBasvuru: string;
  /** Son/Sik siralama anahtarlari - sunucudan gelir, ekranda gorunmez. */
  aramaSonTarih?: unknown;
  aramaSay?: unknown;
  /** Ham liste satırı - cari düzeni (TarafAramaCari) kolonlarını buradan çizer. */
  ham: ListeSatiri;
}

/**
 * KAYNAGA OZEL EK ARAMA ALANLARI: metin `kod`/`unvan`/telefonun yaninda bu
 * alanlarda da aranir. Basvuru hekimi (kullanici: "Doktor / Personel
 * aramasinda hem doktor hem bolum aransin"): "kardiyo" yazan o bolumun
 * hekimlerini bulur.
 */
const KAYNAK_EK_ARAMA: Record<string, string[]> = {
  'basvuru-hekim': ['bolumAdi'],
  // HASTA KİMLİK NO İLE (kullanıcı 16.10.2026): ham TCKN'de - maskeli kolonla aranmaz.
  hasta: ['vknoHam'],
  // Düzenli kaynaklar (cari / personel / kişi) ek alanlarını tarafDuzenleri.ts `ekArama`da taşır - tek liste.
};

/** Sayfa boyu: tek sayfa, daha fazlası "aramayı daraltın". */
const SAYFA_BOYU = 50;

const tipEtiketi = (kaynak: string, s: ListeSatiri): string => {
  if (kaynak === 'kisi') return 'Kişi';
  if (kaynak === 'personel') return 'Personel';
  if (kaynak === 'hasta') return 'Hasta';
  if (kaynak === 'dis-hekim') return 'Dış Hekim';
  if (kaynak === 'basvuru-hekim') return Number(s.disMi) === 1 ? 'Dış Hekim' : 'Hekim';
  const musteri = Number(s.musteri) === 1;
  const tedarikci = Number(s.tedarikci) === 1;
  if (musteri && tedarikci) return 'Müşteri/Tedarikçi';
  if (musteri) return 'Müşteri';
  if (tedarikci) return 'Tedarikçi';
  // Henuz musteri olmayan ADAY (122): tip sutununda "cari" yazmasi
  //   kullaniciya hicbir sey soylemiyordu.
  if (Number(s.aday) === 1) return 'Aday';
  return kaynak;
};

/** ISO tarihi gg.aa.yyyy (saat kismi varsa atilir). */
const gun = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '';
};

const satiraCevir = (kaynak: string, s: ListeSatiri): TarafSatiri => ({
  kaynak,
  id: Number(s.id),
  tip: tipEtiketi(kaynak, s),
  kod: String(s.kod ?? ''),
  // UNVAN YOKSA AD (kullanici: lab isteminde tetkik aramasi bos adlarla
  //   aciliyordu). Pencere taraf kaynaklari icin yazildi ve satiri hep
  //   `unvan`dan cizdi; ama `aramaKaynagi` taraf OLMAYAN listeleri de
  //   gosteriyor - stok, hizmet, tetkik. Onlarin adi `ad` / `kisaAd`
  //   kolonunda; unvan hic yok, yani pencere bos satirlar cizerdi.
  //   Uretim (dort yer), radyoloji ve randevu kartlari da ayni yoldan
  //   geciyor - duzeltme tek yerde.
  unvan: String(s.unvan ?? s.ad ?? s.kisaAd ?? ''),
  bagliKurum: String(s.bagliCari ?? ''),
  gorevRol: String(s.gorev ?? ''),
  bolum: String(s.departmanAdi ?? ''),
  cinsiyet: String(s.cinsiyetAdi ?? ''),
  // Görünen yaş (1214): 45y / 1y3a / 3a5g; eski sunucuda tam yıl + 'y'.
  yas: s.yasKisa ? String(s.yasKisa) : s.yas != null && s.yas !== '' ? `${String(s.yas)}y` : '',
  telefon: String(s.cepTel ?? ''),
  sonBasvuru: gun(s.sonBasvuru),
  sonBolum: String(s.sonBolum ?? ''),
  brans: String(s.bransAdi ?? ''),
  kurum: String(s.kurum ?? ''),
  istemSayisi: s.istemSayisi != null ? String(s.istemSayisi) : '',
  bolumAdi: String(s.bolumAdi ?? s.departmanAdi ?? ''),
  bugunBasvuru: s.bugunBasvuru != null ? String(s.bugunBasvuru) : '',
  // Son/Sik gorunumunun siralama anahtarlari (sunucu doner) - listede
  //   gosterilmez, yalniz birlesik siralamada kullanilir.
  aramaSonTarih: s.aramaSonTarih,
  aramaSay: s.aramaSay,
  ham: s,
});

interface Props {
  acik: boolean;
  /** Aranacak taraf-tabanli kaynaklar (varsayilan: cari + kisi). */
  kaynaklar?: string[];
  /**
   * "＋ Yeni" hangi KARTI acsin (266): randevu ekraninda hasta aranirken tam
   * hasta karti degil sade ADAY HASTA karti acilir. Verilmezse aranan kaynak.
   */
  yeniKaynak?: string;
  /**
   * KART DÜĞMELERİ YOK (kullanıcı: "izin talebi kartında personel aramada yeni
   * ve düzenle butonları görünmesin"): yalnız seçim yapılan yerlerde Yeni /
   * Düzenle personel kartını açıp asıl işi bölüyordu.
   */
  kartYok?: boolean;
  /** Aramaya EKLENEN sabit kosul (ör. randevuda yalniz aktif/aday hastalar). */
  ekFiltre?: Kosul;
  yerTutucu?: string;
  /**
   * Acilista kutuya YAZILI gelen metin (300): kayit kabul seridinde memur
   * T.C./dosya no/ad yazip Ara'ya basiyor - pencere acilinca ayni metni bir
   * daha yazmasin, sonuc hazir gelsin.
   */
  baslangicMetni?: string;
  /**
   * Acilista dogrudan YENI KART acilsin mi ("＋ Yeni Hasta Kaydi" butonu):
   * arama listesinden gecmeden kart formu gelir.
   */
  baslangicYeni?: boolean;
  /**
   * COKLU ISARETLEME KIPI (375, kullanici alternatif 1): satirlar KUTUCUKLA
   * isaretlenir - arama degistirilse bile isaretler KORUNUR - ve "Seç"e
   * basilinca hepsi birden eklenip pencere kapanir.
   *
   * Once "her Enter aninda ekle, pencere acik kalsin" denenmisti; eklenen
   * satir pencerenin ARKASINDAKI gridde oldugu icin kullanici ne olup
   * bittigini goremiyordu. Isaretleme, kararin tamamini pencerede tutar:
   * ne ekleyecegini gorur, vazgecerse hicbiri yazilmaz.
   */
  cokluSecim?: boolean;
  /**
   * Coklu kipte "Seç": isaretlilerin TAMAMI tek seferde verilir.
   * Satirda GORUNEN alanlar da gecer (tip / bolum / gorev): cagiran, kayit
   * sunucudan geri okunmadan once gridi doldurabilsin - aksi halde yeni satir
   * yalniz adla, oteki hucreler bos gorunuyor (kullanici).
   */
  onSecCoklu?(secilenler: {
    kaynak: string; id: number; unvan: string;
    tip: string; bolum: string; gorev: string;
  }[]): void;
  /**
   * Secimi KABUL ETMEME sebebi. Bos/null donerse secim gecerlidir; bir metin
   * donerse secim ALINMAZ ve metin pencerede uyari olarak gosterilir
   * (ör. "zaten ekli", "bu kiside prim rolu isaretli degil").
   */
  secimDenetimi?(secilen: { kaynak: string; id: number; unvan: string }): string | null;
  onKapat(): void;
  /** `satir`: listedeki ham satır (bakiye, kod, roller) - akış ön dolumu için (paletNiyet); karttan dönüşte yok. */
  onSec(secilen: { kaynak: string; id: number; unvan: string; satir?: ListeSatiri }): void;
  /** "＋ Yeni" tam kart yerine ÇAĞIRANIN penceresini açar (randevu: küçük hasta aday ekranı, 16.10.2026);
      aranan metin verilir (ad / telefon ön dolsun). */
  onYeni?(aranan: string): void;
  /** "＋ Yeni" kartının ön değerleri (alış belgesinde tedarikçi, satışta müşteri rolü işaretli gelsin). */
  yeniVarsayilanlari?: Record<string, string | number | boolean>;
  /**
   * KİMLİĞİ OKUT (1255, mockup kimlik_mrz_okut.html ①): başvurunun hasta aramasında "📷 Kimliği Okut" düğmesi.
   * Okunan kimlikle kayıtlı hasta varsa SEÇİLİR (onSec); yoksa yeni hasta kartı alanlar dolu açılır (paket bekler,
   * HastaKimlikAraclari açılışta uygular). Yalnız tek kaynaklı hasta aramasında; ayar kapalıysa düğme yok.
   */
  kimlikOkut?: boolean;
}

/**
 * Genel taraf arama/secim modali - taraf-tabanli her kaynakta (cari, kisi, ileride
 * personel/hasta) kullanilabilir tek bilesen (kullanici: "bu arama ekrani genel olacak,
 * her yerde kullanilacak, jenerik yap"). GenLookup'tan farki: GenLookup TEK kaynakta arar
 * ve alan icine gomulu kucuk bir tetikleyicidir; TarafArama BIRDEN FAZLA kaynagi BIRLIKTE
 * arar (Tip/Bağlı Kurum/Görev-Rol gibi taraf-ortak kolonlarla) ve disaridan (ör. toolbar
 * butonu) acik/kapali kontrol edilir (`acik` prop) - kendi tetikleyicisi yok.
 */
export function TarafArama({ acik, kaynaklar = ['cari', 'kisi'], yeniKaynak, kartYok = false, ekFiltre, onYeni, yeniVarsayilanlari,
                             yerTutucu, baslangicMetni, baslangicYeni,
                             cokluSecim = false, onSecCoklu, secimDenetimi,
                             onKapat, onSec, kimlikOkut = false }: Props) {
  /** Kimliği Okut penceresi (1255) ve ayar kapısı (kayit.kimlik_okutma > 0). */
  const [okutAcik, setOkutAcik] = useState(false);
  const [okutmaAcik, setOkutmaAcik] = useState(false);
  useEffect(() => { if (kimlikOkut) void ayarSayi('kayit.kimlik_okutma', 3).then(v => setOkutmaAcik(v > 0)) }, [kimlikOkut]);
  /**
   * HASTA DUZENI (kullanici): yalniz hasta aranirken kolonlar kayit kabulun
   * ihtiyaci olan bilgiler olur - Dosya No, Ad Soyad, Cinsiyet, Yas, Telefon,
   * Ilce, Il, Son Basvuru. Karisik aramada (cari+kisi) taraf duzeni kalir.
   */
  const hastaDuzeni = kaynaklar.length === 1 && kaynaklar[0] === 'hasta';
  /**
   * DIS HEKIM DUZENI (305): sevk eden hekim aranirken kod/unvan/gorev degil
   * BRANS, KURUM ve gonderdigi tetkik sayisi gerekir - "hangi Ortopedi
   * hekimiydi" sorusu bu kolonlarla cevaplanir.
   */
  const disHekimDuzeni = kaynaklar.length === 1 && kaynaklar[0] === 'dis-hekim';
  /**
   * BASVURU HEKIMI DUZENI (583, kullanici: "başvuruda hekim listesi combo
   * değil, modal dr ve bölümün olduğu arama ekranı olsun, bir sütunda bugün
   * kaç başvuru olduğu bilgisi de olsun"): Hekim · Bölüm · Bugünkü Başvuru.
   * Combo yuzlerce hekimde okunmuyordu; gunluk yuk hicbir yerde gorunmuyordu.
   * Kaynak profile gore ic hekim ya da dis hekim dondurur (578) - ekran ayni.
   */
  const hekimDuzeni = kaynaklar.length === 1 && kaynaklar[0] === 'basvuru-hekim';
  /**
   * KAYNAĞA ÖZEL DÜZEN (mockup Ekranlar/taraf_arama.html, kullanıcı 05.11.2026; tarafDuzenleri.ts: cari, personel,
   * kisi): geniş pencere, sunucuya giden çipler, seçim süzgeçleri, kaynağın kolonları ve sağda açılır / kapanır
   * önizleme. Yalnız TEK kaynaklı aramada; karma aramada (cari + personel) genel taraf düzeni kalır.
   * Alış belgesinde (ekFiltre tedarikci) cari kolonları tedarikçi gözüyle okunur: Borcumuz / Vadesi Geçen Ödeme / Son Alım.
   */
  const duzen = kaynaklar.length === 1 ? TARAF_DUZENLERI[kaynaklar[0]] : undefined;
  const baglam: TarafBaglam = { tedarikci: ekFiltre?.alan === 'tedarikci', musteri: ekFiltre?.alan === 'musteri' };
  const cipListesi = duzen?.cipler?.(baglam) ?? [];

  /** Kutuda yazan metin (aninda) - `arama` bunun gecikmeli (debounce) hali. */
  const [metin, setMetin] = useState('');
  /**
   * Coklu kipte ISARETLILER. Anahtar "kaynak-id" - ayni id iki farkli
   * kaynakta (personel / dis hekim) cikabilir. ARAMA DEGISINCE SILINMEZ:
   * kullanici "kerem" arayip isaretler, "halil" arayip isaretler, sonra Seç.
   */
  const [isaretli, setIsaretli] = useState<TarafSatiri[]>([]);
  const [uyari, setUyari] = useState<string | null>(null);
  const [arama, setArama] = useState('');
  /** Tum Liste / Son Aranan / Sik Aranan - liste ekranlariyla ayni (kullanici_arama). */
  const [gorunum, setGorunum] = useState<'tum' | 'son' | 'sik'>('tum');
  const [satirlar, setSatirlar] = useState<TarafSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState(0);
  // Yeni/Duzenle - cari-liste'deki gibi. Sadece TEK kaynakla aranirken (ör. kaynaklar=['kisi'])
  // anlamli, kullanici hangi TIP olusturacagini secemeyecegi icin karisik aramada gizli.
  const [kartAcik, setKartAcik] = useState<{ kaynak: string; id: number | 'yeni' } | null>(null);
  const zamanlayici = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);
  // Düzenli arama: işaretli çipler, seçim süzgeçleri (alan -> değer), önizleme paneli (tercih tarayıcıda).
  const [cipler, setCipler] = useState<Set<string>>(() => new Set<string>());
  const [secimler, setSecimler] = useState<Record<string, string>>({});
  const [onizleme, setOnizleme] = useState<boolean>(onizlemeOku);
  const onizlemeDegis = () => setOnizleme(v => { onizlemeYaz(!v); return !v });
  const cipDegis = (kod: string) => setCipler(k => { const y = new Set(k); if (y.has(kod)) y.delete(kod); else y.add(kod); return y });

  const ara = useCallback(async (metin: string, gorunumSecimi: 'tum' | 'son' | 'sik' = 'tum') => {
    setYukleniyor(true);
    setHata(null);
    try {
      // TELEFONLA ARAMA (266, kullanici: "kullanici 5336657898 diye girebilir
      //   ama varsa bulmasi gerekir"): metindeki rakamlar ayiklanip normalize
      //   telefon kolonunda aranir - kayitli numara "+90 533 665 78 98" gibi
      //   bosluklu olsa da bulunur. En az 4 rakam: "12" gibi kisa parcalar
      //   butun listeyi getirmesin.
      const rakamlar = metin.replace(/\D/g, '');
      // KAYNAGA OZEL EK ARAMA ALANLARI (KAYNAK_EK_ARAMA): filtre kaynak basina
      //   kurulur - ek alan baska kaynakta yok, ortak filtreye koymak o
      //   kaynagi 400 DOGRULAMA ile dusururdu.
      const filtreOlustur = (k: string): Kosul | undefined => {
        const filtre = metin.trim()
          ? { op: 'or' as const, kosullar: [
              { alan: 'kod', op: 'icerir' as const, deger: metin.trim() },
              { alan: 'unvan', op: 'icerir' as const, deger: metin.trim() },
              ...(duzen?.ekArama ?? KAYNAK_EK_ARAMA[k] ?? []).map(alan =>
                ({ alan, op: 'icerir' as const, deger: metin.trim() })),
              ...(rakamlar.length >= 4
                ? [{ alan: 'telefonHam', op: 'icerir' as const, deger: rakamlar }]
                : []),
            ] }
          : undefined;
        // Cagiranin sabit kosulu (ör. "pasif ve vefat hastalar gelmesin") metin
        //   filtresiyle AND'lenir.
        // Düzenli aramada sabit koşul + çipler + seçimler de sunucu koşuludur (tarafDuzeni.duzenKosulu).
        return filtreBirlestir([ekFiltre, duzen && duzenKosulu(duzen, baglam, cipler, secimler), filtre]);
      };
      // gorunum: Son/Sik Aranan sunucuda kullanici_arama ile suzulur+siralanir.
      const gorunumParam = gorunumSecimi === 'tum' ? undefined : gorunumSecimi;
      // BIR KAYNAK DUSERSE OTEKILER GOSTERILIR (kullanici: "isteyen hekim
      //   aramada hata"). `Promise.all` ile tek bir 400/403 butun pencereyi
      //   bos birakiyordu - iki kaynakli aramada (dis hekim + personel) ya da
      //   kullanicinin yalniz birine yetkisi olan bir listede arama hic
      //   calismiyor gibi gorunuyordu. Hangi kaynagin dustugu de yazilir:
      //   "hicbir sey bulunamadi" ile "o liste okunamadi" ayri seylerdir.
      const sonuclar = await Promise.allSettled(
        kaynaklar.map(k => api.liste(k, { sayfa: 1, boyut: duzen ? SAYFA_BOYU : 20, filtre: filtreOlustur(k),
                                          gorunum: gorunumParam })));
      const dusenler = kaynaklar.filter((_, i) => sonuclar[i].status === 'rejected');
      if (dusenler.length === kaynaklar.length) {
        // Hepsi dustuyse gercek hata gosterilir - sessiz bos liste yaniltir.
        throw (sonuclar[0] as PromiseRejectedResult).reason;
      }
      setHata(dusenler.length
        ? `${dusenler.join(', ')} listesi okunamadı - kalan sonuçlar gösteriliyor.`
        : '');
      const yanitlar = sonuclar.map(r =>
        r.status === 'fulfilled' ? r.value : { satirlar: [] as ListeSatiri[] });
      // Kaynaklar (musteri / kisi / hasta) AYRI isteklerle gelir; Son/Sik
      //   gorunumunde birlesik listenin sirasi sunucunun anahtarlariyla
      //   yeniden kurulur - yoksa liste kaynak kaynak dizilir ve "en son
      //   secilen en ustte" kurali kaybolur (ortak: aramaSirasi.ts).
      const tumu = yanitlar.flatMap((y, i) => y.satirlar.map(s => satiraCevir(kaynaklar[i], s)));
      setSatirlar(gorunumSecimi === 'tum' ? tumu : aramaSirala(tumu, gorunumSecimi, 'unvan'));
      setSecili(0);
    } catch (h) {
      setHata(hataMetni(h));
      setSatirlar([]);
    } finally {
      setYukleniyor(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kaynaklar.join(','), ekFiltre, duzen, cipler, secimler, baglam.tedarikci]);

  useEffect(() => {
    if (!acik) return;
    void ara(arama, gorunum);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [acik, arama, gorunum, ara]);

  useEffect(() => {
    if (acik) {
      // Disaridan gelen metinle acilis (300): kutuya yazilir VE aramasi
      //   hemen tetiklenir - debounce beklemeden sonuc gelsin.
      if (baslangicMetni) { setMetin(baslangicMetni); setArama(baslangicMetni) }
      if (baslangicYeni) setKartAcik({ kaynak: yeniKaynak ?? kaynaklar[0], id: 'yeni' });
      setTimeout(() => kutu.current?.focus(), 0);
      return;
    }
    setMetin('');
    setArama('');
    setGorunum('tum');
    setSatirlar([]);
    setKartAcik(null);
    setIsaretli([]);
    setUyari(null);
    setCipler(new Set<string>());
    setSecimler({});
    ekOnbellegiTemizle();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [acik]);

  const yaz = (yeni: string) => {
    setMetin(yeni);
    window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => setArama(yeni), 300);
  };

  const anahtar = (x: { kaynak: string; id: number }) => `${x.kaynak}-${x.id}`;

  /**
   * COKLU KIPTE ISARETI ACAR/KAPATIR. Engel (mukerrer kayit) varsa isaret
   * KONULMAZ ve sebebi yazilir - kullanici "Seç"e bastiktan sonra degil,
   * isaretlerken ogrensin.
   */
  const isaretDegis = (satir: TarafSatiri) => {
    const k = anahtar(satir);
    if (isaretli.some(x => anahtar(x) === k)) {
      setIsaretli(l => l.filter(x => anahtar(x) !== k));
      setUyari(null);
      return;
    }
    const engel = secimDenetimi?.({ kaynak: satir.kaynak, id: satir.id, unvan: satir.unvan })
                  ?? null;
    if (engel) { setUyari(engel); return }
    setUyari(null);
    setIsaretli(l => [...l, satir]);
  };

  /** "Seç": isaretlilerin tamami eklenir, pencere kapanir. */
  const isaretliyiOnayla = () => {
    if (isaretli.length === 0) return;
    const secilenler = isaretli.map(x => ({
      kaynak: x.kaynak, id: x.id, unvan: x.unvan,
      tip: x.tip, bolum: x.bolum, gorev: x.gorevRol,
    }));
    secilenler.forEach(x => void api.aramaIsaretle(x.kaynak, x.id));
    // Tek cagriyla verilir: cagiran satirlari TEK state guncellemesiyle
    //   ekleyebilsin - tek tek `onSec` cagrilsaydi her cagri bir onceki
    //   state uzerinden calisir ve yalniz sonuncusu kalirdi.
    if (onSecCoklu) onSecCoklu(secilenler); else secilenler.forEach(onSec);
    onKapat();
  };

  const sec = (satir: TarafSatiri) => {
    if (cokluSecim) { isaretDegis(satir); return }
    const secilen = { kaynak: satir.kaynak, id: satir.id, unvan: satir.unvan, satir: satir.ham };
    // ENGEL VARSA HIC EKLENMEZ: sessizce yutmak yerine sebebi yazilir.
    const engel = secimDenetimi?.(secilen) ?? null;
    if (engel) { setUyari(engel); return }
    // Secim "Son / Sik Aranan" sayacina islensin - listede oldugu gibi.
    void api.aramaIsaretle(satir.kaynak, satir.id);
    onSec(secilen);
    onKapat();
  };


  const tus = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(s => Math.min(s + 1, satirlar.length - 1)) }
    else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(s => Math.max(s - 1, 0)) }
    else if (e.key === 'Enter' && satirlar[secili]) { e.preventDefault(); sec(satirlar[secili]) }
    else if (e.key === 'Escape') { onKapat() }
  };

  if (!acik) return null;

  /**
   * Kart penceresinden YENI kayit kaydedildi: aramaya geri donmek yerine o
   * kaydi DOGRUDAN SEC (kullanici: "yeni cari olusturduysam onu baz alip arama
   * listesi kapanmalidir"). Aradigini bulamayip yeni acan kullanici, kaydettigi
   * kaydi ikinci kez aramak zorunda kaliyordu.
   *
   * DUZENLEMEDE secim yapilmaz - kullanici belki baska bir kaydi arayacaktir;
   * yalniz liste tazelenir.
   */
  const kartKaydedildi = async (kaynak: string, yeniMi: boolean, id: number) => {
    setKartAcik(null);
    if (!yeniMi || !id) { void ara(arama); return }
    try {
      const y = await api.kartOku(kaynak, id);
      const kart = y.kart as Record<string, unknown>;
      // Cari/kisi kartinda ad alani "unvan"; bos donerse aramaya duseriz.
      const unvan = String(kart.unvan ?? kart.ad ?? '').trim();
      if (unvan === '') { void ara(arama); return }
      // Listeden secmekle ayni: kayit "Son / Sik Aranan" sayacina islensin.
      void api.aramaIsaretle(kaynak, id);
      onSec({ kaynak, id, unvan });
    } catch {
      // Kayit olustu ama okunamadi: kullaniciyi bos birakma, aramaya don.
      void ara(arama);
    }
  };

  // Kart acikken (Yeni/Duzenle) arama penceresi GIZLI ama state korunuyor - kart
  // KAPATILIRSA ayni aramaya donulur + liste yenilenir (degisen kayit gorunsun).
  if (kartAcik) {
    const yeniMi = kartAcik.id === 'yeni';
    const kaynak = kartAcik.kaynak;
    return (
      <GenForm
        kaynak={kaynak}
        id={kartAcik.id}
        // Kart basligi kaynak adindan uretiliyordu ("hasta-aday"); okunur ad.
        baslik={kaynak === 'hasta-aday' ? 'Aday Hasta' : undefined}
        cariyeBaglaGizli
        yeniKayitVarsayilanlari={yeniMi ? yeniVarsayilanlari : undefined}
        onKapat={() => { setKartAcik(null); void ara(arama) }}
        onKaydedildi={id => { void kartKaydedildi(kaynak, yeniMi, id) }}
        // Kimlik no kayıtlı hastaya aitse yeni kart yerine o hasta SEÇİLİR.
        onMevcutKayit={id => { void kartKaydedildi(kaynak, true, id) }}
      />
    );
  }

  // Seçim süzgeci seçenekleri yüklü satırlardan (+ seçili değer): ayrı bir lookup isteği yok.
  const secenekler = (alan: string): string[] => {
    const k = new Set<string>(satirlar.map(x => String(x.ham[alan] ?? '').trim()).filter(Boolean));
    const secili = secimler[alan]; if (secili) k.add(secili);
    return [...k].sort((a, b) => a.localeCompare(b, 'tr'));
  };
  const odak = satirlar[secili]?.ham;

  return (
    <>
      {/* z-index inline: kart modali (.kaperde) 320'de - GenLookup'in .perde/.lookup-pencere
          varsayilan z-index'i (20/21) bunun ICINDE acilinca modalin ARKASINDA kalirdi. */}
      <div className="perde" onClick={onKapat} style={{ zIndex: 400 }} />
      <div className={`lookup-pencere taraf-arama${duzen ? ' duzenli' : ''}`} onKeyDown={tus}
           style={{ width: duzen ? duzen.genislik : 'min(880px, 92vw)', zIndex: 401 }}>
        {/* Ust arac cubugu (cari-liste ile ayni desen): Yeni/Duzenle sadece tek-kaynakli
            aramada (kaynaklar.length===1) - kullanici hangi TIP olusturulacagini secemez.
            HEKIM ARAMASINDA IKISI DE YOK (kullanici): `basvuru-hekim` bir KART
            DEGIL, profile gore ic/dis hekimi birlestiren salt okunur kaynak
            (578) - acilacak bir "basvuru hekimi karti" yok. Kayit kabul zaten
            hekim tanimlamaz; hekim Personel / Dis Doktor ekranindan acilir. */}
        <div className="lookup-cubuk">
          {kaynaklar.length === 1 && !hekimDuzeni && !kartYok && (
            <>
              <button type="button" className="d"
                onClick={() => onYeni ? onYeni(arama) : setKartAcik({ kaynak: yeniKaynak ?? kaynaklar[0], id: 'yeni' })}>
                {duzen ? duzen.yeniEtiketi(baglam) : '＋ Yeni'}
              </button>
              {kimlikOkut && hastaDuzeni && okutmaAcik && (
                <button type="button" className="d" title={c('Kimlik kartı / pasaport MRZ\'sinden hastayı bul ya da yeni kart aç')}
                        onClick={() => setOkutAcik(true)}>📷 {c('Kimliği Okut')}</button>
              )}
              <button type="button" className="d" disabled={!satirlar[secili]}
                onClick={() => satirlar[secili] && setKartAcik({ kaynak: satirlar[secili].kaynak, id: satirlar[secili].id })}>
                ✎ Düzenle
              </button>
            </>
          )}
          <button type="button" className="d bir"
            disabled={cokluSecim ? isaretli.length === 0 : !satirlar[secili]}
            onClick={() => (cokluSecim
              ? isaretliyiOnayla()
              : satirlar[secili] && sec(satirlar[secili]))}>
            {cokluSecim ? `Seç (${isaretli.length})` : 'Seç'}
          </button>
          {/* Düzenin ek düğmeleri Seç'in SAĞINDA (cari: Ekstre; kullanıcı 05.11.2026); alt çubukta düğme yok, Kapat yeter. */}
          {duzen?.EkDugmeler && <duzen.EkDugmeler s={odak} />}
          {/* Kapat SAGA yaslanir (kullanici): kart modallerindeki duzenin ayni. */}
          <button type="button" className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                  onClick={onKapat}>✖ Kapat</button>
        </div>

        {/* Arama kutusu ve Liste/Son/Sik dugmeleri LISTE EKRANLARIYLA ayni
            (GenGrid deseni) - ayni arac her yerde ayni gorunsun. */}
        <div className="cipler" style={{ margin: 0 }}>
          <div className="ara-kutu">
            <span>🔍</span>
            <input type="search"
              ref={kutu}
              placeholder={yerTutucu ?? 'Ara…'}
              value={metin}
              onChange={e => yaz(e.target.value)}
            />
          </div>

          <div className="durumseg">
            <button type="button" className={`ikon-liste ${gorunum === 'tum' ? 'on' : ''}`}
                    title="Tüm Liste" onClick={() => setGorunum('tum')}>☰</button>
            <button type="button" className={`ikon-liste ${gorunum === 'son' ? 'on' : ''}`}
                    title="Son Aranan" onClick={() => setGorunum('son')}>🕓</button>
            <button type="button" className={`ikon-liste ${gorunum === 'sik' ? 'on' : ''}`}
                    title="Sık Aranan" onClick={() => setGorunum('sik')}>⭐</button>
          </div>
          {duzen && (
            <>
              {duzen.secimler.map(sc => (
                <label key={sc.alan} className="ta-secim">{sc.etiket}:
                  <select value={secimler[sc.alan] ?? ''} onChange={e => setSecimler(v => ({ ...v, [sc.alan]: e.target.value }))}>
                    <option value="">Tümü</option>
                    {secenekler(sc.alan).map(x => <option key={x} value={x}>{x}</option>)}
                  </select>
                </label>
              ))}
              {/* Çipler seçim combolarının SAĞINDA, ayraçla, aynı satırda (kullanıcı 05.11.2026). */}
              {cipListesi.length > 0 && (
                <>
                  <span className="durumseg-ayrac ta-ayrac" />
                  <span className="ta-cipler">
                    {cipListesi.map(x => (
                      <button key={x.kod} type="button" className={`cip ${cipler.has(x.kod) ? 'on' : ''}`} title={x.ipucu}
                              onClick={() => cipDegis(x.kod)}>{x.ad}</button>
                    ))}
                  </span>
                </>
              )}
            </>
          )}
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}

        {okutAcik && (
          <KimlikOkutPenceresi
            onKapat={() => setOkutAcik(false)}
            // Kayıt yok: yeni hasta kartı dolu açılır - paket 'yeni' kart için bekler.
            onAktar={p => { setOkutAcik(false); mrzBekleyenKoy(p, 'yeni');
                            if (onYeni) onYeni(p.adSoyad); else setKartAcik({ kaynak: yeniKaynak ?? kaynaklar[0], id: 'yeni' }) }}
            // Kayıtlı hasta: seçilir; farklar varsa kart açılınca uygulanmak üzere bekler (3 dk).
            onHastaAc={(hastaId, p, adSoyad) => { setOkutAcik(false);
                        if (Object.keys(p.kart).length || Object.keys(p.ozluk).length) mrzBekleyenKoy(p, hastaId);
                        onSec({ kaynak: 'hasta', id: hastaId, unvan: adSoyad }) }}
          />
        )}

        <div className={duzen ? `ta-govde${onizleme ? '' : ' kapali'}` : undefined}
             style={duzen ? undefined : { display: 'contents' }}>
        <div className="lookup-liste">
          <table>
            <thead>
              <tr>
                <th className="check"></th>
                {duzen ? (
                  <duzen.Basliklar b={baglam} />
                ) : hastaDuzeni ? (
                  // Genislikler ACIK: 'dar' sinifiyla telefon ve tarih
                  //   kirpiliyordu ("+90 5336…", "29.08.2…").
                  <>
                    <th style={{ width: 96 }}>Dosya No</th>
                    <th className="genis">Ad Soyad</th>
                    {/* Cinsiyet + yaş tek kolon "E 50y" (kullanıcı 16.10.2026). */}
                    <th style={{ width: 80 }}>Cins. / Yaş</th>
                    <th style={{ width: 132 }}>Telefon</th>
                    {/* İlçe / İl yerine son başvuru tarihi + bölümü (kullanıcı 16.10.2026). */}
                    <th style={{ width: 96 }}>Son Başvuru</th>
                    <th style={{ width: 190 }}>Son Bölüm</th>
                  </>
                ) : hekimDuzeni ? (
                  <>
                    <th className="genis">Hekim</th>
                    <th style={{ width: 230 }}>Bölüm</th>
                    <th style={{ width: 130 }} className="hiza-sag">Bugünkü Başvuru</th>
                  </>
                ) : disHekimDuzeni ? (
                  <>
                    <th className="genis">Ad Soyad</th>
                    <th style={{ width: 190 }}>Branş</th>
                    <th style={{ width: 210 }}>Kurum</th>
                    <th style={{ width: 132 }}>Cep</th>
                    <th style={{ width: 90 }} className="hiza-sag">Gönderdiği</th>
                  </>
                ) : (
                  <>
                    <th className="dar">Tip</th>
                    <th className="dar">Kod</th>
                    <th className="genis">Unvan</th>
                    {/* BAGLI KURUM EN SONDA (kullanici): kisiyi ayirt eden
                        bilgi bolum ve gorev; bagli kurum cogu personelde bos,
                        ortada durunca satiri bosluga bolüyordu. */}
                    <th className="dar">Bölüm</th>
                    <th className="dar">Görev</th>
                    <th className="bagli-kurum">Bağlı Kurum</th>
                  </>
                )}
              </tr>
            </thead>
            <tbody>
              {satirlar.map((satir, i) => (
                <tr
                  key={`${satir.kaynak}-${satir.id}`}
                  className={[i === secili ? 'secili' : '', duzen?.satirSinifi?.(satir.ham, baglam) ?? '']
                    .filter(Boolean).join(' ')}
                  onDoubleClick={() => sec(satir)}
                  // COKLU KIPTE TEK TIK ISARETLER (kullanici): kutucugu
                  //   tutturmaya calismak yerine satirin herhangi bir yeri.
                  onClick={() => { setSecili(i); if (cokluSecim) isaretDegis(satir) }}
                >
                  <td className="check">
                    <input type="checkbox" readOnly
                           checked={cokluSecim
                             ? isaretli.some(x => anahtar(x) === anahtar(satir))
                             : i === secili} />
                  </td>
                  {duzen ? (
                    <duzen.Hucreler s={satir.ham} b={baglam} />
                  ) : hastaDuzeni ? (
                    <>
                      <td>{satir.kod}</td>
                      <td>{satir.unvan}</td>
                      <td>{[satir.cinsiyet.slice(0, 1), satir.yas].filter(Boolean).join(' ')
                           || <span className="sonuk">—</span>}</td>
                      <td>{satir.telefon}</td>
                      <td>{satir.sonBasvuru || <span className="sonuk">—</span>}</td>
                      <td>{satir.sonBolum || <span className="sonuk">—</span>}</td>
                    </>
                  ) : hekimDuzeni ? (
                    <>
                      <td>{satir.unvan}</td>
                      <td>{satir.bolumAdi || <span className="sonuk">—</span>}</td>
                      <td className="hiza-sag">{satir.bugunBasvuru || '0'}</td>
                    </>
                  ) : disHekimDuzeni ? (
                    <>
                      <td>{satir.unvan}</td>
                      <td>{satir.brans || <span className="sonuk">—</span>}</td>
                      <td>{satir.kurum || <span className="sonuk">—</span>}</td>
                      <td>{satir.telefon}</td>
                      <td className="hiza-sag">{satir.istemSayisi}</td>
                    </>
                  ) : (
                    <>
                      <td>{satir.tip}</td>
                      <td>{satir.kod}</td>
                      <td>{satir.unvan}</td>
                      <td>{satir.bolum}</td>
                      <td>{satir.gorevRol}</td>
                      <td>{satir.bagliKurum}</td>
                    </>
                  )}
                </tr>
              ))}
              {/* Genel duzende kolon sayisi 7: isaret · Tip · Kod · Unvan ·
                  Bağlı Kurum · Bölüm · Görev. */}
              {!yukleniyor && satirlar.length === 0 && (
                <tr><td colSpan={duzen ? duzen.kolonSayisi : hastaDuzeni ? 9 : disHekimDuzeni ? 6 : hekimDuzeni ? 4 : 7}
                        className="bos">Kayıt yok</td></tr>
              )}
            </tbody>
          </table>
          {yukleniyor && <div className="yukleniyor">Araniyor…</div>}
        </div>
        {/* Önizleme aç / kapa düğmesi PANELİN ÜSTÜNDE (kullanıcı 05.11.2026); kapalıyken sağda ince şerit. */}
        {duzen && (onizleme
          ? <div className="ta-on">
              <OnizlemeBasligi onKapat={onizlemeDegis} />
              {odak ? <duzen.Onizleme s={odak} b={baglam} /> : <div className="gh-sonuk">{c('Satır seçin')}</div>}
            </div>
          : <button type="button" className="ta-on-serit" title="Önizlemeyi aç" onClick={onizlemeDegis}>
              ◧<span>Önizleme</span>
            </button>)}
        </div>

        {(uyari || isaretli.length > 0) && (
          <div className="lookup-eklenen">
            {uyari && <span className="lookup-uyari">{uyari}</span>}
            {isaretli.length > 0 && (
              <span className="lookup-eklenen-liste">
                <b>{isaretli.length} işaretli:</b> {isaretli.map(x => x.unvan).join(' · ')}
              </span>
            )}
          </div>
        )}
        <div className="lookup-alt">
          <span>
            {duzen ? (
              <>
                <b>{satirlar.length}</b> kayıt{satirlar.length >= SAYFA_BOYU ? ` (ilk ${SAYFA_BOYU} - aramayı daraltın)` : ''}
                {(duzen.lejant?.length ?? 0) > 0 && (
                  <span className="ta-lgnd">
                    {duzen.lejant!.map(l => <span key={l.ad}><i className="ta-sw" style={{ background: l.renk }} />{l.ad}</span>)}
                  </span>
                )}
                <span className="ta-kis">↑↓ gez · Enter seç · Esc kapat</span>
              </>
            ) : cokluSecim
              ? '↑↓ gez · tık/Enter işaretle · Seç ile hepsini ekle · Esc kapat'
              : '↑↓ gez · çift tık/Enter seç · Esc kapat'}
          </span>
        </div>
      </div>
    </>
  );
}

/**
 * GENEL KURAL (kullanici): cari/kisi/personel secimi UYGULAMANIN HER YERINDE
 * ayni ekrandan yapilir. Bu bilesen alan + TarafArama modalini birlikte verir:
 * salt-okunur kutu, sagindaki "…" dugmesi ve modal. GenLookup'un kucuk kendi
 * penceresi yerine bunu kullanin.
 */
export function TarafSecici({
  etiket, deger, kilitli, zorunlu, hata, kaynaklar = ['cari'], yerTutucu, ipucu,
  otomatikAc = false, ekFiltre, bosMetin, onSec, onTemizle,
}: {
  etiket: string;
  deger?: string;
  kilitli?: boolean;
  zorunlu?: boolean;
  hata?: string;
  kaynaklar?: string[];
  yerTutucu?: string;
  ipucu?: string;
  /** Acilista modali kendiliginden ac (ör. yeni belgede "kime?" sorusu). */
  otomatikAc?: boolean;
  /** Aramayi daraltan sabit kosul (ör. secili bolumun hekimleri, 367). */
  ekFiltre?: Kosul;
  /**
   * Secim YOKKEN kutuda gorunen metin. Bos secim bir ANLAM tasiyorsa yazilir -
   * ör. basvuruda gonderen yoksa "Kendi İsteği" (kullanici).
   */
  bosMetin?: string;
  onSec(secilen: { kaynak: string; id: number; unvan: string }): void;
  /** Verilirse "×" dugmesi cikar ve secimi bosaltir. */
  onTemizle?(): void;
}) {
  const [acik, setAcik] = useState(otomatikAc);

  return (
    <label className="alan">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <span className="lookup-kutu">
        <input readOnly value={deger ?? ''} placeholder={bosMetin ?? 'Seçiniz…'}
               disabled={kilitli}
               onMouseDown={e => { if (!kilitli) { e.preventDefault(); setAcik(true) } }} />
        {!kilitli && onTemizle && deger && (
          <button type="button" className="mini" title="Boşalt"
                  onClick={onTemizle}>×</button>
        )}
        {!kilitli && (
          <button type="button" className="mini" title={ipucu ?? `${etiket} ara`}
                  onClick={() => setAcik(true)}>…</button>
        )}
      </span>
      {hata && <span className="alan-hata">{hata}</span>}

      <TarafArama
        acik={acik}
        kaynaklar={kaynaklar}
        ekFiltre={ekFiltre}
        yerTutucu={yerTutucu}
        onKapat={() => setAcik(false)}
        onSec={sec => { onSec(sec); setAcik(false) }}
      />
    </label>
  );
}
