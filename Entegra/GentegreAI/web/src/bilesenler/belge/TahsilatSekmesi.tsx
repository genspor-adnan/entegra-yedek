import { useEffect, useRef, useState } from 'react';
import type { AvansDurumu } from '../avansDurumu';
import { mesaj, paraSor } from '../mesaj';
import { para, tarihSaat, paraYaz } from '../bicim';
import type { BelgeYaniti } from '../../api/sozlesme';
import { c } from '../../dil/ceviri';

/**
 * TAHSILAT SEKMESI - belgeye bagli kasa islemleri ve kalan bakiye.
 * Kayit YOK: tahsilat kasa ekranindan girilir, burasi ozet gosterir.
 */
export function TahsilatSekmesi({ sonuc, tahsilatlar, kayitliId, alisMi, tahsilatAc,
                                  secili, setSecili, tahsilatAcKart, tahsilatSil,
                                  onYenile, kurumTahakkukAc, kurumKalan, kurumBelgeleri,
                                  basvuruMu,
                                  hizliNakit, hesapSecAc, acikBorc,
                                  iadeAc, avansAl, avansIadeAc, avans, kayitSart,
                                  yerelPara = 'TL' }: {
  /** Basvuru kartinda arac cubugu SADE: "＋" (tam ekran) cizilmez. */
  basvuruMu?: boolean;
  sonuc: BelgeYaniti | null;
  tahsilatlar: Record<string, unknown>[];
  kayitliId: number;
  /** Avans mahsubu satirlari degistirdiginde belgeyi tazelemek icin (322). */
  onYenile?(): void;
  /** Alis belgesinde "Tahsilat" degil "Ödeme" yazar. */
  alisMi: boolean;
  /** Kasa islem kartini acar (tur: tahsilat 21 / odeme 31); belge kayitli
      degilse ONCE kaydeder. */
  tahsilatAc(tur: number): Promise<void>;
  /** Listede SECILI kasa islemleri (satir onay kutulari, coklu secim). */
  secili: number[];
  setSecili(v: number[]): void;
  /** MEVCUT kasa islemini duzeltmek icin karti acar (cift tik da bunu cagirir). */
  tahsilatAcKart(id: number): void;
  /** Secili kasa islemlerini siler - silinemeyende sunucunun sebebi gosterilir (354). */
  tahsilatSil(idler: number[]): Promise<void>;
  /**
   * HIZLI TAHSILAT (kullanici): kasa karti ACILMADAN gride satir ekler.
   * Nakitte varsayilan kasa, banka/POS'ta modal aramadan secilen hesap.
   */
  hizliNakit?(): void;
  /** Banka/POS hesabi secim penceresi; `iade` true ise satir EKSI yazilir. */
  hesapSecAc?(tur: 'B' | 'P', iade?: boolean): void;
  /**
   * IADE / IPTAL: secilen araca gore iade satiri ekler (tutar penceresinde
   * neden combosu da sorulur). Verilmezse dugme cizilmez.
   */
  iadeAc?(arac: 'nakit' | 'pos' | 'banka' | 'cek' | 'senet'): void;
  /**
   * AVANS AL (781): hastadan ileriye donuk para alir - BU BELGEYE
   * BAGLANMAZ. Avans, henuz bir hizmete sayilmamis paradir; belgeye
   * baglamak onu "bu basvurunun tahsilati" yapar ve avans olmaktan cikarirdi.
   * Kasa karti avans damgasiyla acilir (779).
   */
  avansAl?(tur: number): void;
  /**
   * AVANS IADE (781): kalan avansi hastaya geri oder. Hangi avansin iade
   * edilecegi menude secilir - hastanin birden fazla acik avansi olabilir ve
   * iade TEK bir kasa islemine baglanir (780).
   */
  avansIadeAc?(avansId: number, tutar: number): void;
  /**
   * BEKLEYEN KALEM DEGISIKLIGINI KAYDETTIRIR (784, kullanici: "ücret girdim,
   * avans kullan dediğim zaman girdiğim ücreti sildi").
   *
   * Avans eylemleri sonunda satirlari SUNUCUDAN tazeliyor; gridde duran ama
   * daha kaydedilmemis ucret satirlari o tazelemede kayboluyordu. Tahsilat
   * araclari (Nakit/POS) ayni kapidan geciyor - avans da gecmeli.
   * `false` donerse eylem YAPILMAZ: kayit gecmeden satirlara dokunmak, memura
   * "kaydetmedim ama sildi" dedirtir.
   */
  kayitSart?(): Promise<boolean>;
  /**
   * HASTANIN AVANS DURUMU (781) - KART tutar, serit ve bu sekme AYNI nesneyi
   * okur. Sekme kendi sorsaydi, avans alindiginda serit bayat kalirdi
   * (kullanici: "avans aldım ama anında üstte görünmedi").
   */
  avans: AvansDurumu;
  /** Yerel para kodu - "dövizli tahsilat var mı" bunun disindakilerle olculur. */
  yerelPara?: string;
  /** Gridde tutar hucresine tiklaninca cagrilir (satir ici duzenleme). */
  /** Belgenin ACIK BORCU - yeni tahsilat satiri bu tutarla acilir. */
  acikBorc?: number;
  /**
   * KURUM TAHAKKUKU (331): basvuruda kurum payini kuruma kesilen belgeye
   * (Satış Tahakkuku) dönüştürür. TAHSILAT DEGILDIR - hastadan para alinmaz,
   * kasa hareketi olusmaz; alacak kurum carisine yazilir ve prim de dogmaz
   * (prim yalniz tahsilattan uretilir). Verilmezse dugme cizilmez.
   */
  kurumTahakkukAc?(): void;
  /** Henuz belgelesmemis kurum payi - dugme yalniz bu > 0 iken etkin. */
  kurumKalan?: number;
  /**
   * KURUM TAHAKKUKLARI (kullanici: "kaydettiğim zaman eğer yoksa kurum
   * tahakkuk ilk satıra gelecek (yani 800), altına da 200 nakit gelecek").
   *
   * Tahakkuk bir KASA ISLEMI DEGIL, kuruma kesilen belgedir - listeye SALT
   * OKUNUR satir olarak, tahsilatlarin USTUNE gelir: memur "800'ü kuruma
   * yazdım, 200'ü hastadan aldım" tablosunu tek yerde gorur. Secilemez ve
   * silinemez; duzeltmesi Belgeye Dönüşüm sekmesindedir.
   */
  kurumBelgeleri?: { id: number; belgeNo: string; tarih: string;
                     turAdi: string; cari: string; tutar: number;
                     /** Hastaya mi kesildi (ikon 👤) yoksa kuruma mi (🏛️). */
                     hastaMi?: boolean }[];
}) {
/* SECIM: faturalama gridiyle AYNI desen - duz tik tek satir secer, Ctrl/Cmd
   ekler-cikarir, Shift aralik secer; basliktaki kutu tumunu secer. */
/**
 * AVANS KULLANIM satiri DUZELTILEMEZ ama SECILEBILIR (785, kullanici: "avans
 * kullandım ama silmek istiyorum, enable değil"): duzeltilecek bir kasa islemi
 * yoktur (para avans gununde alindi), ama mahsup GERI ALINABILIR - satir
 * secilip 🗑'e basilinca avansa iade edilir.
 *
 * Kimligi NEGATIF (gorunumun ikinci dali): silme yolu bununla ayirt edilir.
 */
const avansMi = (k: Record<string, unknown>) => Number(k.avansKullanim ?? 0) === 1;
const idler = tahsilatlar.map(k => Number(k.id ?? 0)).filter(Boolean);
const hepsi = idler.length > 0 && secili.length === idler.length;
const cevir = (id: number) =>
  setSecili(secili.includes(id) ? secili.filter(x => x !== id) : [...secili, id]);
const tekSecili = secili.length === 1 ? secili[0] : 0;
const capa = useRef<number | null>(null);   // son tiklanan satirin sirasi
/**
 * "⋯" MENUSU (banka / cek / senet): seyrek kullanilan tahsilat araclari.
 * Disari tiklaninca kapanir - acik menu ekranda unutulmasin (GenToolbar ile
 * ayni desen).
 */
const [aracMenu, setAracMenu] = useState(false);
/** IADE arac menusu - "⋯" ile ayni desen, ayri acilir. */
const [iadeMenu, setIadeMenu] = useState(false);
/** AVANS AL arac menusu (781): nakit / banka / POS. */
const [avansMenu, setAvansMenu] = useState(false);
/** AVANS IADE menusu (781): hangi avans iade edilecek. */
const [avansIadeMenu, setAvansIadeMenu] = useState(false);
useEffect(() => {
  if (!aracMenu && !iadeMenu && !avansMenu && !avansIadeMenu) return;
  const kapat = () => { setAracMenu(false); setIadeMenu(false);
                        setAvansMenu(false); setAvansIadeMenu(false) };
  window.addEventListener('click', kapat);
  return () => window.removeEventListener('click', kapat);
}, [aracMenu, iadeMenu, avansMenu, avansIadeMenu]);
/** Avans durumu KARTTAN gelir (781): serit ve bu cubuk ayni sayiyi konusur. */
const hastaId = Number(sonuc?.belge.tarafId ?? 0);
const avansVar = avans.toplam > 0;

/**
 * KAYIT KAPISI - TAHSILAT ARAC CUBUGUNUN TAMAMI (784, kullanici: "herhangi
 * bir tahsilat (avans dahil) basıldıysa ücreti kaydetsin önce").
 *
 * Her tahsilat eylemi eninde sonunda satirlari SUNUCUDAN tazeliyor (kasa
 * penceresi kapaninca, mahsuptan sonra, hizli satir yazildiktan sonra);
 * gridde duran kaydedilmemis ucret o anda kayboluyordu. Kapi tek yerde: hangi
 * dugmeye basilirsa basilsin once kayit, sonra eylem. Kayit gecmezse eylem
 * HIC baslamaz - yarim is birakmak, memura "kaydetmedim ama sildi" dedirtir.
 *
 * Bekleyen degisiklik yoksa `kayitSart` zaten hicbir sey yazmadan `true`
 * doner; cagiran taraflarda (BelgeKarti) var olan kapilar da yerinde kalir -
 * iki kez kaydetmez.
 */
const kapidan = async (is?: () => void | Promise<void>) => {
  if (!is) return;
  if (kayitSart && !(await kayitSart())) return;
  await is();
};

/**
 * AVANS AL / IADE de ayni kapidan gecer (784): kasa penceresi kapaninca kart
 * satirlari SUNUCUDAN tazeliyor - kaydedilmemis ucret satiri orada da
 * kaybolurdu.
 */
const avansAlGuvenli = (tur: number) => kapidan(() => avansAl?.(tur));
const avansIadeGuvenli = (avansId: number, tutar: number) =>
  kapidan(() => avansIadeAc?.(avansId, tutar));

/**
 * "Avans Kullan": acik avansin BIR KISMINI (ya da tamamini) bu belgenin
 * satirlarina mahsup eder (322/783).
 *
 * TUTAR SORULUR (kullanici: "avans kullan dedigimde tutari sorsun, kismi
 * kullanabileyim"): hasta 2.000 birakip bugun 500'luk islem yaptirmis
 * olabilir; tamamini bu belgeye saymak kalan avansi yok eder ve sonraki
 * basvuruda para gorunmez. Onerilen deger ikisinin KUCUGU: avans kalani ve
 * belgenin acik borcu - ikisini de asmanin anlami yok (fazlasi zaten
 * dagitilamaz, sunucu acik satir kadarini yazar).
 */
const avansKullan = async () => {
  if (!kayitliId || !avansVar) return;
  // ONCE KAYIT (784): mahsup satirlari sunucuda tazeler, kaydedilmemis
  //   ucret satiri o anda kaybolurdu.
  if (kayitSart && !(await kayitSart())) return;
  const acik = kalan > 0 ? kalan : avans.toplam;
  const onerilen = Math.min(avans.toplam, acik);
  const secim = await paraSor('Avanstan ne kadar kullanılsın?', {
    varsayilan: onerilen > 0 ? String(onerilen) : '',
    // TAVAN avansin kalani: olmayan parayi belgeye saymak, sonradan
    //   kapatilamayan bir tahsilat gostergesi uretirdi.
    enCok: avans.toplam,
    yerelPara, doviz: yerelPara, dovizler: [yerelPara],
  });
  if (!secim || secim.tutar <= 0) return;
  const y = await avans.mahsupEt(kayitliId, secim.tutar);
  if (!y) return;
  mesaj(y.dagitilan > 0
    ? `${para.format(y.dagitilan)} avans bu belgenin satırlarına mahsup edildi.`
    : 'Mahsup edilecek açık satır kalmadı.');
  onYenile?.();
};
/* PARA USTU dugmesi yalniz dovizli tahsilat varken: yerel parada alinan tutar
   zaten net yazilir, "ustu" diye ayri bir satira gerek yok. */
const dovizliTahsilatVar = tahsilatlar.some(
  k => String(k.dovizCinsi ?? yerelPara) !== yerelPara);
const satirTikla = (e: React.MouseEvent, sira: number, id: number) => {
  if (!id) return;
  if (e.shiftKey && capa.current != null) {
    const [bas, son] = capa.current <= sira ? [capa.current, sira] : [sira, capa.current];
    setSecili(tahsilatlar.slice(bas, son + 1)
      .map(k => Number(k.id ?? 0)).filter(Boolean));
    return;
  }
  capa.current = sira;
  if (e.ctrlKey || e.metaKey) { cevir(id); return }
  setSecili(secili.length === 1 && secili[0] === id ? [] : [id]);
};
/**
 * DIP TOPLAM HASTA PAYI UZERINDEN (kullanici: "nakit, POS, banka, çek, senet
 * her zaman hastadan alacağımız tahsilatlar içindir").
 *
 * "Kalan" belgenin genel toplamindan hesaplanınca paylasimli basvuruda kurumun
 * payi da hastadan beklenen para gibi gorunuyordu: 1.000 TL'lik iste hastadan
 * 200 alinacakken dipnot "Kalan 1.000" yaziyordu. `acikBorc` kart tarafinda
 * zaten HASTA PAYINI tasir (paylasimli degilse belgenin tamami).
 */
const genel = Number(sonuc?.belge.genelToplam ?? 0);
const tahsil = tahsilatlar.reduce((t, k) => t + (Number(k.yerelTutar ?? k.tutar ?? 0) || 0), 0);
const kalan = acikBorc != null
  ? Math.round(acikBorc * 100) / 100
  : Math.round((genel - tahsil) * 100) / 100;
return (
  /* `tahsilat-kutu` (781): grubun varsayilan `overflow: hidden`i arac
     cubugundan acilan menuleri KIRPIYORDU - "⋯" menusune dorduncu oge
     (Avans Kullan) eklenince alt kenar kesiliyor, ayni sey bes ogeli
     "İade / İptal" menusunde de oluyordu. Kirpma yalniz BU grupta
     kaldiriliyor: menu kutunun disina tasabilsin. */
  <div className="kagrup tahsilat-kutu">
    {/* AVANS MAHSUBU (322): hasta once para yatirip ucret satiri sonra
        girildiyse o tahsilat hicbir satira bagli degildir - prim de dogmaz.
        Serit yalniz dagitilmamis tahsilat VARSA cizilir. */}
    {kayitliId > 0 && avansVar && (
      <div className="uyari-kutusu" style={{ display: 'flex', gap: 10,
                                             alignItems: 'center', flexWrap: 'wrap' }}>
        <span>
          Bu hastanın <b>{para.format(avans.toplam)}</b> kullanılmamış avansı var
          {avans.adet > 1 ? ` (${avans.adet} işlem)` : ''}.
          {' '}Mahsup edilmezse satırların tahsilatı görünmez ve <b>prim doğmaz</b>.
        </span>
        <button type="button" className="d" disabled={avans.calisiyor}
                style={{ marginLeft: 'auto' }}
                onClick={() => void avansKullan()}>
          {avans.calisiyor ? '⏳ Mahsup ediliyor…' : '⇄ Bu Belgeye Mahsup Et'}
        </button>
        {avans.hata && (
          <div className="hata-kutusu" style={{ flexBasis: '100%' }}>{avans.hata}</div>
        )}
      </div>
    )}
    {/* Tahsilat araclari: Nakit 21 / Banka 22 / POS 25 - hepsi ayni
        modali (kasa karti) cari + tutar onyuklu acar. Cek/Senet kasa
        planinin F5 fazinda (cek_senet tablosu) baglanacak. */}
    <div className="katoolbar" style={{ margin: 10 }}>
      {/* Tahsilat ARACI adiyla: yanindaki POS / Cek-Senet ile ayni
          dizide - bu dugme NAKIT tahsilat (tur 21) acar. */}
      {/* Alista ODEME turleri (31/32/35), satista tahsilat (21/22/25). */}
      {/* Kayitli olma sarti YOK: kaydedilmemis belgede kart once KAYDEDER,
          sonra tahsilati acar (tahsilatAc). */}
      {/* HIZLI TAHSILAT (kullanici): kart ACILMAZ - satir dogrudan gride
          duser. Nakitte VARSAYILAN KASA, banka/POS'ta modal aramadan secilen
          hesap kullanilir; tutar acik borcun tamami gelir ve gridde
          tiklanarak degistirilir. */}
      {/* KAYITLI OLMA SARTI YOK (kullanici: "ücretleme yaptım tahsilat
          sekmede nakit/banka/pos basamıyorum"): dugmeler kaydedilmemis
          belgede pasifti ve "Önce belgeyi kaydedin" diyordu - kullaniciyi
          karti birakip yesil dugmeye gitmeye zorluyordu. Tahsilat kasaya
          belge kimligiyle baglandigi icin kayit gercekten sart, ama kart
          KENDISI kaydediyor (BelgeKarti.kayitSart) - tipki ucret eklemede
          oldugu gibi. */}
      <button className="d bir"
              title={`Varsayılan kasaya nakit ${alisMi ? 'ödeme' : 'tahsilat'} satırı ekler`
                + (acikBorc && acikBorc > 0 ? ` (${paraYaz(acikBorc)})` : '')
                + (kayitliId ? '' : ' — belge önce kaydedilir')}
              onClick={() => void kapidan(() => hizliNakit?.())}>
        💵 Nakit
      </button>
      <button className="d bir"
              title={'POS hesabı seç ve satır ekle'
                     + (kayitliId ? '' : ' — belge önce kaydedilir')}
              onClick={() => void kapidan(() => hesapSecAc?.('P'))}>
        💳 POS
      </button>
      {/* SEYREK ARACLAR MENUDE (kullanici: "sağında ... şeklinde 3 nokta
          buton olsun basınca alta doğru menüde Banka/Çek/Senet"): kayit
          kabulde tahsilatin neredeyse tamami nakit ya da POS; banka havalesi
          ve cek/senet ayda birkac kez. Bes dugme yan yana durunca en cok
          kullanilan ikisi kalabaligin icinde kayboluyordu.
          Cek ve senet AYRI SECENEK: ikisi ayri kasa islem turu (23/24
          tahsilat, 33/34 odeme) ve portfoyde ayri izlenir. */}
      <span className="dugme-menu">
        <button className="d" title={c('Diğer tahsilat araçları')}
                onClick={e => { e.stopPropagation(); setAracMenu(v => !v) }}>⋯</button>
        {aracMenu && (
          <div className="dugme-menu-liste">
            <button type="button" className="mi"
                    onClick={() => { setAracMenu(false); void kapidan(() => hesapSecAc?.('B')) }}>
              🏦 Banka
            </button>
            <button type="button" className="mi"
                    onClick={() => { setAracMenu(false);
                                     void kapidan(() => tahsilatAc(alisMi ? 33 : 23)) }}>
              🧾 Çek
            </button>
            <button type="button" className="mi"
                    onClick={() => { setAracMenu(false);
                                     void kapidan(() => tahsilatAc(alisMi ? 34 : 24)) }}>
              📜 Senet
            </button>
            {/* AVANS KULLAN (781, kullanici: "senetten sonra separator Avans
                Kullan ekle... Avans alındığı zaman aktif olacak"): tahsilat
                ARACI DEGIL - para zaten kasada, burada yalnizca BU BELGENIN
                satirlarina sayilir. Ayrac bu farki gosteriyor.
                AVANSI YOKKEN PASIF ama GORUNUR: dugmeyi hic cizmemek
                "avans diye bir sey yok" izlenimi verirdi; title sebebini
                yaziyor. */}
            <div className="menu-ayrac" />
            <button type="button" className="mi" disabled={!avansVar || !kayitliId}
                    title={!kayitliId ? 'Önce belgeyi kaydedin.'
                           : avansVar
                             ? `Hastanın ${paraYaz(avans.toplam)} avansını bu belgeye mahsup eder`
                             : 'Bu hastanın kullanılmamış avansı yok.'}
                    onClick={() => { setAracMenu(false); void avansKullan() }}>
              💰 Avans Kullan
              {avansVar && <span className="mi-tutar">{paraYaz(avans.toplam)}</span>}
            </button>
          </div>
        )}
      </span>
      {/* AVANS AL (781, kullanici: "bu 3 nokta butonun sağında Avans Al
          butonu ekle... alta doğru tür açılsın ve avans kaydı yapılsın").

          Tahsilat araclarinin YANINDA ama onlardan ayri bir is: tahsilat bu
          belgenin borcunu kapatir, avans ise ileriye donuk paradir ve
          BELGEYE BAGLANMAZ - baglansaydi "bu basvurunun tahsilati" olur,
          avans olmaktan cikardi. Kullanilmasi ayri bir eylem: "⋯" icindeki
          Avans Kullan.

          HASTA SART: avans kimin parasi oldugu bilinmeden takip edilemez. */}
      {avansAl && (
        <span className="dugme-menu">
          <button className="d" disabled={!hastaId}
                  title={hastaId
                    ? 'Hastadan avans al (bu belgeye bağlanmaz)'
                    : 'Önce hasta seçin.'}
                  onClick={e => { e.stopPropagation(); setAvansMenu(v => !v) }}>{c('💰 Avans Al')}</button>
          {avansMenu && (
            <div className="dugme-menu-liste">
              <button type="button" className="mi"
                      onClick={() => { setAvansMenu(false); void avansAlGuvenli(21) }}>💵 Nakit</button>
              <button type="button" className="mi"
                      onClick={() => { setAvansMenu(false); void avansAlGuvenli(22) }}>🏦 Banka</button>
              <button type="button" className="mi"
                      onClick={() => { setAvansMenu(false); void avansAlGuvenli(25) }}>💳 POS</button>
            </div>
          )}
        </span>
      )}
      {/* AVANS İADE (781, kullanici: "eğer avans varsa görünecek şekilde Avans
          Al butonu sağında Avans İade butonu görünsün ve avansı iade etsin").

          AVANSI YOKSA HİÇ ÇİZİLMEZ (pasif değil): "Avans Kullan" menünün
          içinde olduğu için pasif dururken sebebini title'da söyleyebiliyor;
          araç çubuğunda ise iade edilecek parası olmayan hastada duran bir
          düğme, cubugu gereksiz kalabaliklastirirdi.

          HANGİ AVANS sorusu menüde sorulur: hastanın birden fazla açık avansı
          olabilir ve iade TEK kasa işlemine bağlanır (780) - "hepsini iade
          et" demek, hangi makbuzun geri verildiğini kaydetmemek olurdu. */}
      {avansIadeAc && avansVar && (
        <span className="dugme-menu">
          <button className="d" title={c('Kalan avansı hastaya geri öde')}
                  onClick={e => { e.stopPropagation(); setAvansIadeMenu(v => !v) }}>
            ↩ Avans İade
          </button>
          {avansIadeMenu && (
            <div className="dugme-menu-liste">
              {avans.satirlar.map(a => (
                <button key={a.kasaIslemId} type="button" className="mi"
                        onClick={() => { setAvansIadeMenu(false);
                                         void avansIadeGuvenli(a.kasaIslemId, a.kalan) }}>
                  {tarihSaat(a.islemTarihi).slice(0, 10)}
                  <span className="mi-tutar">{paraYaz(a.kalan)}</span>
                </button>
              ))}
            </div>
          )}
        </span>
      )}
      {/* IADE / IPTAL (kullanici: "3 nokta buton sağına ↩ İade / İptal
          butonu ekle, basınca alta doğru menü gelsin Nakit/Pos/Banka/Çek/
          Senet"). Arac menusu tahsilattaki ile AYNI: para hangi araçla
          alindiysa o araçla geri verilir - karttan alinip nakit iade etmek
          veznede olmayan parayi cikarir ve en bilinen suistimal yoludur.
          Secimden sonra tutar penceresi acilir; tutar EKSI islenir. */}
      {iadeAc && (
        <span className="dugme-menu">
          <button className="d" title={c('Seçilen araçla iade / iptal satırı ekler')}
                  disabled={!kayitliId}
                  onClick={e => { e.stopPropagation(); setIadeMenu(v => !v) }}>
            ↩ İade / İptal
          </button>
          {iadeMenu && (
            <div className="dugme-menu-liste">
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); void kapidan(() => iadeAc('nakit')) }}>💵 Nakit</button>
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); void kapidan(() => iadeAc('pos')) }}>💳 POS</button>
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); void kapidan(() => iadeAc('banka')) }}>🏦 Banka</button>
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); void kapidan(() => iadeAc('cek')) }}>🧾 Çek</button>
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); void kapidan(() => iadeAc('senet')) }}>📜 Senet</button>
            </div>
          )}
        </span>
      )}
      {/* KURUM TAHAKKUKU (331): tahsilat ARACI DEGIL - "tahsil edildi"
          saymaz; bu yuzden tahsilat araclarinin SONUNDA, Senet'in saginda
          durur (kullanici). Kurum payi
          kuruma kesilen Satış Tahakkuku belgesine doner; para kurumdan
          gelince normal tahsilat islenir ve prim O ZAMAN dogar. */}
      {kurumTahakkukAc && (
        <button className="d"
                disabled={!kayitliId || !(kurumKalan && kurumKalan > 0)}
                title={!kayitliId ? 'Önce belgeyi kaydedin'
                       : !(kurumKalan && kurumKalan > 0)
                       ? 'Belgelenmemiş kurum payı yok'
                       : 'Kurumdan alınacak payı belgeler: kuruma Satış Tahakkuku '
                         + 'kesilir. Para kurumdan gelince normal tahsilat işlenir.'}
                // Tahakkuk da satirlari degistiriyor (kurum payi belgeye
                //   cikar): bekleyen ucret once kaydedilir (784).
                onClick={() => void kapidan(kurumTahakkukAc)}>
          {/* "TAHSILAT" DEGIL "TAHAKKUK" (kullanici: "kurumun ödeyeceği ve
              kuruma yapacağım faturalama karşılığı olarak değil mi"): kurum
              payi iki asamalidir - once kuruma BELGE kesilir (alacak dogar),
              para geldiginde normal tahsilat islenir ve prim O ZAMAN dogar.
              Dugmeye "tahsilat" demek, para alinmis izlenimi verirdi. */}
          🏥 Kuruma Tahakkuk
        </button>
      )}
      <span className="ayrac" />
      {/* Secili satir uzerinde islem - kalem gridiyle ayni desen: yalniz ikon,
          secim yoksa pasif. Cift tik da duzeltmeyi acar. */}
      {/* "＋" BASVURUDA CIZILMEZ (kullanici): tam tahsilat ekranini acan
          ikinci bir yol, Nakit / POS / ⋯ araclari dururken yalniz karisiklik
          yaratiyordu - hangi dugmenin ne actigi belirsizlesiyordu. Kayit
          kabulde tahsilat araclardan biriyle baslar; ayrintili duzeltme
          mevcut satirin ✎ ikonundan. ERP belgelerinde (satis siparisi,
          fatura) tam ekran hala gerekli - orada duruyor. */}
      {!basvuruMu && (
        <button className="d" disabled={!kayitliId}
                title={kayitliId ? 'Tahsilat ekranını aç (tüm alanlarla)'
                                 : 'Önce belgeyi kaydedin'}
                onClick={() => void tahsilatAc(alisMi ? 31 : 21)}>＋</button>
      )}
      {/* DUZELTME yalniz KASA ISLEMINDE (785): avans kullaniminin duzeltilecek
          bir islemi yok - tutari degistirmek demek mahsubu geri alip yeniden
          yapmaktir. */}
      <button className="d" disabled={!tekSecili || tekSecili < 0}
              title={!secili.length ? 'Önce satır seçin'
                     : secili.length > 1 ? 'Düzeltme için tek satır seçin'
                     : tekSecili < 0
                       ? 'Avans kullanımı düzeltilemez - geri alıp yeniden kullanın.'
                       : 'Seçili işlemi düzelt'}
              onClick={() => tekSecili > 0 && tahsilatAcKart(tekSecili)}>✎</button>
      <button className="d teh" disabled={!secili.length}
              title={secili.length
                ? (secili.some(x => x < 0)
                    ? 'Seçili avans kullanımını geri alır (tutar avansa döner)'
                    : 'Seçili işlemleri sil')
                : 'Önce satır seçin'}
              onClick={() => { void tahsilatSil(secili) }}>🗑</button>
      {secili.length > 1 && <span className="kapt">{secili.length} işlem seçili</span>}
    </div>
    <table className="detay-tablo">
      <thead>
        <tr>
          <th className="check">
            <input type="checkbox" checked={hepsi} disabled={!idler.length}
                   title={c('Tümünü seç')}
                   onChange={() => setSecili(hepsi ? [] : idler)} />
          </th>
          <th style={{ width: 140 }}>Tarih / Saat</th>
          <th style={{ width: 120 }}>Makbuz No</th>
          <th style={{ width: 180 }}>Tür</th>
          <th>{c('Kasa / Banka')}</th>
          {/* DOVIZ SUTUNU yalniz dovizli tahsilat varsa (kullanici: "döviz
              tahsilat olursa tutar soluna alınan döviz de gelsin"): "Tutar"
              kolonu YEREL KARSILIKTIR, hastanin verdigi 100 USD orada hic
              gorunmuyordu. Yerel parada bu sutun bos yer harcar - cizilmez. */}
          {dovizliTahsilatVar && (
            <th className="hiza-sag" style={{ width: 120 }}
                title={c('Alınan döviz tutarı ve para birimi')}>{c('Alınan Döviz')}</th>
          )}
          <th className="hiza-sag" style={{ width: 130 }}
              title={`Yerel karşılık (${yerelPara})`}>Tutar</th>
        </tr>
      </thead>
      <tbody>
        {/* KURUM TAHAKKUKLARI EN USTTE (kullanici): tahsilattan once okunur -
            "kurumun payi belgelendi mi" sorusu listenin basinda cevaplanir. */}
        {(kurumBelgeleri ?? []).map(kb => (
          <tr key={`kb-${kb.id}`} className="kurum-belge" style={{ userSelect: 'none' }}>
            <td className="check">
              {/* IKON BELGENIN TARAFINA GORE (kullanici tahakkuku ikiye ayirdi):
                  hastaya kesilen 👤, kuruma kesilen 🏛️. Ikisi de TAHSILAT
                  DEGIL - alacagin belgelenmesidir. */}
              <span className="sonuk"
                    title={kb.hastaMi ? 'Hastaya kesilen belge - tahsilat değildir'
                                      : 'Kuruma kesilen belge - tahsilat değildir'}>
                {kb.hastaMi ? '👤' : '🏛️'}</span>
            </td>
            <td>{tarihSaat(kb.tarih)}</td>
            <td>{kb.belgeNo}</td>
            <td>{kb.turAdi}</td>
            <td>{kb.cari || <span className="sonuk">—</span>}</td>
            {dovizliTahsilatVar && <td className="hiza-sag sonuk">—</td>}
            <td className="hiza-sag">{para.format(kb.tutar)}</td>
          </tr>
        ))}
        {tahsilatlar.map((k, i) => {
          // AVANS KULLANIMI (781/785): kasa islemi DEGIL, mahsubun kendisi.
          //   Cift tikla kart ACILMAZ (duzeltilecek islem yok) ama satir
          //   SECILEBILIR: 🗑 mahsubu geri alir.
          const avansSatiri = avansMi(k);
          const kid = Number(k.id ?? 0);
          return (
          <tr key={i} className={kid && secili.includes(kid) ? 'secili' : ''}
              style={{ userSelect: 'none' }}
              onClick={e => satirTikla(e, i, kid)}
              onDoubleClick={() => { if (kid > 0) tahsilatAcKart(kid) }}>
            <td className="check" onClick={e => e.stopPropagation()}>
              <input type="checkbox" checked={!!kid && secili.includes(kid)} disabled={!kid}
                     title={avansSatiri
                       ? 'Avans kullanımı: seçip 🗑 ile geri alabilirsiniz (tutar avansa döner).'
                       : undefined}
                     onChange={() => { if (kid) { capa.current = i; cevir(kid) } }} />
            </td>
            {/* Tarih + saat: ayni gun birden fazla tahsilat olunca
                sira ancak saatle anlasiliyordu. */}
            <td>{tarihSaat(k.islemTarihi)}</td>
            <td>{String(k.islemNo ?? '')}</td>
            <td>{String(k.turAdi ?? '')}</td>
            <td>{String(k.hesapAdi ?? '') || <span className="sonuk">—</span>}</td>
            {/* TUTAR ARTIK GRIDDE DUZENLENMIYOR (kullanici): tutar tahsilat
                aracina basildigi anda MODALDE soruluyor (acik borc onyuklu,
                Enter kaydediyor). Iki ayri duzenleme yolu -hucre ici ve
                modal- ayni alani farkli kurallarla yaziyordu; girilen satir
                yanlissa ✎ ile tahsilat ekrani acilir. */}
            {dovizliTahsilatVar && (() => {
              const dvz = String(k.dovizCinsi ?? yerelPara) || yerelPara;
              return (
                <td className="hiza-sag">
                  {dvz === yerelPara
                    ? <span className="sonuk">—</span>
                    : <>{para.format(Number(k.tutar ?? 0))}{' '}
                        <span className="sonuk">{dvz}</span></>}
                </td>
              );
            })()}
            <td className="hiza-sag">
              {para.format(Number(k.yerelTutar ?? k.tutar ?? 0))}
            </td>
          </tr>
          );
        })}
        {tahsilatlar.length === 0 && (kurumBelgeleri ?? []).length === 0 && (
          <tr><td colSpan={dovizliTahsilatVar ? 7 : 6} className="bos">
            {kayitliId > 0
              ? `Bu belgeye bağlı ${alisMi ? 'ödeme' : 'tahsilat'} yok.`
              : 'Önce belgeyi kaydedin.'}
          </td></tr>
        )}
      </tbody>
      <tfoot>
        <tr className="genel">
          <td colSpan={dovizliTahsilatVar ? 6 : 5} className="hiza-sag">
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
}

