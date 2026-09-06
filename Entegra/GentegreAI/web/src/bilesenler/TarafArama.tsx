import { useCallback, useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { type Kosul, type ListeSatiri, hataMetni } from '../api/sozlesme';
import { GenForm } from './GenForm';
import { aramaSirala } from './aramaSirasi';

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
  ilce: string;
  il: string;
  sonBasvuru: string;
  /** DIS HEKIM duzeni (305): brans, kurum ve gonderdigi tetkik sayisi. */
  brans: string;
  kurum: string;
  istemSayisi: string;
  /** Son/Sik siralama anahtarlari - sunucudan gelir, ekranda gorunmez. */
  aramaSonTarih?: unknown;
  aramaSay?: unknown;
}

const tipEtiketi = (kaynak: string, s: ListeSatiri): string => {
  if (kaynak === 'kisi') return 'Kişi';
  if (kaynak === 'personel') return 'Personel';
  if (kaynak === 'hasta') return 'Hasta';
  if (kaynak === 'dis-hekim') return 'Dış Hekim';
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
  unvan: String(s.unvan ?? ''),
  bagliKurum: String(s.bagliCari ?? ''),
  gorevRol: String(s.gorev ?? ''),
  bolum: String(s.departmanAdi ?? ''),
  cinsiyet: String(s.cinsiyetAdi ?? ''),
  yas: s.yas != null && s.yas !== '' ? String(s.yas) : '',
  telefon: String(s.cepTel ?? ''),
  ilce: String(s.ilce ?? ''),
  il: String(s.il ?? ''),
  sonBasvuru: gun(s.sonBasvuru),
  brans: String(s.bransAdi ?? ''),
  kurum: String(s.kurum ?? ''),
  istemSayisi: s.istemSayisi != null ? String(s.istemSayisi) : '',
  // Son/Sik gorunumunun siralama anahtarlari (sunucu doner) - listede
  //   gosterilmez, yalniz birlesik siralamada kullanilir.
  aramaSonTarih: s.aramaSonTarih,
  aramaSay: s.aramaSay,
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
   * Acilista dogrudan BU KAYDIN karti acilsin ("Hasta Kartini Ac" dugmesi):
   * arama penceresi arada gorunmez.
   */
  baslangicKartId?: number | null;
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
  onSec(secilen: { kaynak: string; id: number; unvan: string }): void;
}

/**
 * Genel taraf arama/secim modali - taraf-tabanli her kaynakta (cari, kisi, ileride
 * personel/hasta) kullanilabilir tek bilesen (kullanici: "bu arama ekrani genel olacak,
 * her yerde kullanilacak, jenerik yap"). GenLookup'tan farki: GenLookup TEK kaynakta arar
 * ve alan icine gomulu kucuk bir tetikleyicidir; TarafArama BIRDEN FAZLA kaynagi BIRLIKTE
 * arar (Tip/Bağlı Kurum/Görev-Rol gibi taraf-ortak kolonlarla) ve disaridan (ör. toolbar
 * butonu) acik/kapali kontrol edilir (`acik` prop) - kendi tetikleyicisi yok.
 */
export function TarafArama({ acik, kaynaklar = ['cari', 'kisi'], yeniKaynak, ekFiltre,
                             yerTutucu, baslangicMetni, baslangicYeni, baslangicKartId,
                             cokluSecim = false, onSecCoklu, secimDenetimi,
                             onKapat, onSec }: Props) {
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
      const filtre = metin.trim()
        ? { op: 'or' as const, kosullar: [
            { alan: 'kod', op: 'icerir' as const, deger: metin.trim() },
            { alan: 'unvan', op: 'icerir' as const, deger: metin.trim() },
            ...(rakamlar.length >= 4
              ? [{ alan: 'telefonHam', op: 'icerir' as const, deger: rakamlar }]
              : []),
          ] }
        : undefined;
      // Cagiranin sabit kosulu (ör. "pasif ve vefat hastalar gelmesin") metin
      //   filtresiyle AND'lenir.
      const tamFiltre: Kosul | undefined = ekFiltre
        ? (filtre ? { op: 'and' as const, kosullar: [ekFiltre, filtre] } : ekFiltre)
        : filtre;
      // gorunum: Son/Sik Aranan sunucuda kullanici_arama ile suzulur+siralanir.
      const gorunumParam = gorunumSecimi === 'tum' ? undefined : gorunumSecimi;
      const yanitlar = await Promise.all(
        kaynaklar.map(k => api.liste(k, { sayfa: 1, boyut: 20, filtre: tamFiltre,
                                          gorunum: gorunumParam })));
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
  }, [kaynaklar.join(','), ekFiltre]);

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
      else if (baslangicKartId) setKartAcik({ kaynak: kaynaklar[0], id: baslangicKartId });
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
    const secilen = { kaynak: satir.kaynak, id: satir.id, unvan: satir.unvan };
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
        onKapat={() => { setKartAcik(null); void ara(arama) }}
        onKaydedildi={id => { void kartKaydedildi(kaynak, yeniMi, id) }}
      />
    );
  }

  return (
    <>
      {/* z-index inline: kart modali (.kaperde) 320'de - GenLookup'in .perde/.lookup-pencere
          varsayilan z-index'i (20/21) bunun ICINDE acilinca modalin ARKASINDA kalirdi. */}
      <div className="perde" onClick={onKapat} style={{ zIndex: 400 }} />
      <div className="lookup-pencere taraf-arama" onKeyDown={tus} style={{ width: 'min(880px, 92vw)', zIndex: 401 }}>
        {/* Ust arac cubugu (cari-liste ile ayni desen): Yeni/Duzenle sadece tek-kaynakli
            aramada (kaynaklar.length===1) - kullanici hangi TIP olusturulacagini secemez. */}
        <div className="lookup-cubuk">
          {kaynaklar.length === 1 && (
            <>
              <button type="button" className="d"
                onClick={() => setKartAcik({ kaynak: yeniKaynak ?? kaynaklar[0], id: 'yeni' })}>
                ＋ Yeni
              </button>
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
          {/* Kapat SAGA yaslanir (kullanici): kart modallerindeki duzenin ayni. */}
          <button type="button" className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                  onClick={onKapat}>Kapat</button>
        </div>

        {/* Arama kutusu ve Liste/Son/Sik dugmeleri LISTE EKRANLARIYLA ayni
            (GenGrid deseni) - ayni arac her yerde ayni gorunsun. */}
        <div className="cipler" style={{ margin: 0 }}>
          <div className="ara-kutu">
            <span>🔍</span>
            <input
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
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="lookup-liste">
          <table>
            <thead>
              <tr>
                <th className="check"></th>
                {hastaDuzeni ? (
                  // Genislikler ACIK: 'dar' sinifiyla telefon ve tarih
                  //   kirpiliyordu ("+90 5336…", "29.08.2…").
                  <>
                    <th style={{ width: 96 }}>Dosya No</th>
                    <th className="genis">Ad Soyad</th>
                    <th style={{ width: 74 }}>Cinsiyet</th>
                    <th style={{ width: 46 }} className="hiza-sag">Yaş</th>
                    <th style={{ width: 132 }}>Telefon</th>
                    <th style={{ width: 104 }}>İlçe</th>
                    <th style={{ width: 104 }}>İl</th>
                    <th style={{ width: 96 }}>Son Başvuru</th>
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
                  className={i === secili ? 'secili' : ''}
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
                  {hastaDuzeni ? (
                    <>
                      <td>{satir.kod}</td>
                      <td>{satir.unvan}</td>
                      <td>{satir.cinsiyet}</td>
                      <td className="hiza-sag">{satir.yas}</td>
                      <td>{satir.telefon}</td>
                      <td>{satir.ilce}</td>
                      <td>{satir.il}</td>
                      <td>{satir.sonBasvuru || <span className="sonuk">—</span>}</td>
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
                <tr><td colSpan={hastaDuzeni ? 9 : disHekimDuzeni ? 6 : 7} className="bos">Kayıt yok</td></tr>
              )}
            </tbody>
          </table>
          {yukleniyor && <div className="yukleniyor">Araniyor…</div>}
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
            {cokluSecim
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
