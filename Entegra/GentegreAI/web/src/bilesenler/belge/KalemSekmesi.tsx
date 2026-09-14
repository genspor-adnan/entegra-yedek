import { Fragment, useState } from 'react';
import { para, say4, tarihSaat, hamSayi as sayi } from '../bicim';
import { iskonatoMetni, satirTutari, type SatirDurumu } from '../../sayfalar/belgeSatir';
import { DOVIZ_KODLARI } from '../../sayfalar/belgeSabitleri';
import { bruta, payBrute } from '../../sayfalar/belgeKarti/kdvModu';
import {
  KOVALAR, ROTA_ADI, kovaKullanilir,
} from '../../sayfalar/belgeKarti/dagilimKovalari';
import { SAF_SGK_ROTA } from '../../sayfalar/belgeKartiKurallari';
import type { BelgeYaniti, IskontoTalebi } from '../../api/sozlesme';

/**
 * KALEMLER SEKMESI - satir gridi (izlemli kalemlerde lot master-detail) ve
 * dip toplam panosu.
 *
 * Grid SALT GORUNUM: ekleme/duzenleme kalem penceresinden yapilir, buradaki
 * dugmeler yalnizca onu acar. Tutarlar ONIZLEME; kayitli belgede sunucunun
 * dondurdugu dip toplam gosterilir.
 */
export function KalemSekmesi(p: KalemSekmesiProps) {
  const {
    satirlar, seciliSatirlar, setSeciliSatirlar, acikLotlar, setAcikLotlar,
    kilitli, bilgi, onizleme, sonuc, transferBaslikEksigi,
    depoBelgesi, stokFisiMi, talepMi,
    setStokArama, setKalem, seciliSil, satirTikla, sonTiklanan, secimDegis, doviz,
    fiyatListesi, paylasim, basvuruMu, depoSecimi, onRoller, onIskontoOnay,
    iskontoTalepleri, dagilimOnizleme,
  } = p;

  /** Tarih kolonu KOD'un solunda mi (basvuru) yoksa miktarin solunda mi. */
  const tarihSolda = !!basvuruMu && bilgi.siparis;

  // DAGILIM ALT SATIRI (470, kullanici: "ucret satirlarinda + ile acilan alt
  //   satir olup dagilimi orada gorsem, yoksa 1 satir cok sikisir"). Lot
  //   detayiyla ayni desen; ikisi birlikte de acilabilir. Varsayilan KAPALI:
  //   kalem listesi kisa kalsin.
  const [acikDagilimlar, setAcikDagilimlar] = useState<Set<number>>(new Set());

  /* SON TALEP (662): liste sunucudan yeniden eskiye gelir, ilki en gunceli.
     Belgede birden cok talep olabilir - baslikta okunan SONUNCUSUDUR, cunku
     onaylanan oran satirda zaten duruyor. */
  const sonTalep = iskontoTalepleri?.[0];

  const yerelPara = doviz?.yerelPara ?? 'TL';

  /**
   * DOVIZ KOLONLARI (kullanici kurali):
   *   1) Tum satirlar yerel parada VE rapor dovizi yerel ise kolonlar GIZLI.
   *   2) Rapor dovizi secilince gorunur - yerel tutar KURA BOLUNEREK gosterilir.
   *   3) Bir satir kendi dovizinde girildiyse (100 USD) o satirda kendi
   *      degerleri; yerel karsiligi zaten "Birim Fiyat (TL)" kolonunda.
   */
  const raporKur = sayi(doviz?.kur);
  const raporDovizli = !!doviz && doviz.raporDovizi !== yerelPara && raporKur > 0;
  //   Kolonlar YALNIZ rapor dovizi secilince cikar (kullanici): hic doviz
  //   girilmemisse her sey yerel paradadir, fazladan kolon gosterilmez.
  //   Dovizli fiyatli bir kalem eklenince rapor dovizi ZATEN otomatik o doviz
  //   olur (BelgeKarti.kalemKaydet), yani kolonlar kendiliginden gelir.
  const dovizKolon = raporDovizli;
  const dovizAdi = raporDovizli ? doviz!.raporDovizi : '';

  /** Bir satirin doviz karsiligi: kendi dovizi varsa o, yoksa rapor kuruyla. */
  const satirDoviz = (r: SatirDurumu, yerelTutar: number, yerelFiyat: number) => {
    if (r.fiyatDovizi && r.fiyatDovizi !== yerelPara) {
      const birim = sayi(r.dovizFiyat);
      return { cins: r.fiyatDovizi, birim,
               tutar: satirTutari(sayi(r.adet), birim, r.iskonto, r.iskonto2) };
    }
    if (raporDovizli)
      return { cins: doviz!.raporDovizi, birim: yerelFiyat / raporKur, tutar: yerelTutar / raporKur };
    return null;
  };

  /** Hicbir satirda aciklama yoksa kolon HIC cizilmez (kullanici) - bos bir
   *  sutun gridi daraltiyordu. */
  const aciklamaVar = satirlar.some(x => String(x.aciklama ?? '').trim() !== '');

  /**
   * SAF SGK: grid de fiyat penceresiyle AYNI dizilir (602, kullanici: "gridi de
   * aynı yap"). O rotada satirin iki bedeli vardir ve kolonlar sunu okutur:
   *
   *     Hasta Katkısı 1.500,00 | SUT 85,73 | Tutar 1.585,73 | Hasta Payı 1.600,00
   *
   * "Birim Fiyat" kolonu HASTA KATKISINI gosterir (iskonto ona isler), SUT ise
   * kendi kolonunda durur - toplam gozle dogrulanabilsin.
   */
  const safSgk = Number(paylasim?.rota ?? 0) === SAF_SGK_ROTA;
  /**
   * KURUM PAYI KOLONU. 601'de saf SGK'da KAPATILMISTI: o sirada birim fiyat
   * SUT'u gosterdigi icin kolon tutarin kopyasiydi. 602'de birim fiyat hasta
   * katkisina gecince SUT hicbir kolonda gorunmez oldu - kolon geri acildi,
   * basligi saf SGK'da "SUT". Oteki rotalarda eskisi gibi "Kurum Payı".
   */
  const kurumPayiKolonu = !!paylasim?.acik;
  /**
   * TUTAR KOLONU SAF SGK'DA CIZILMEZ (602, kullanici: "tutar sütunu da
   * kaldır"). O rotada tutar iki komsu kolonun TOPLAMIDIR
   * (Hasta Katkısı + SUT); ucuncu kolon ayni sayiyi tekrar yaziyordu.
   * Dip toplam ve kovalar degismedi - yalniz gorunum sadelesti.
   */
  const tutarKolonu = bilgi.kalem !== 'miktar' && !safSgk;
  const kurumPayiBasligi = safSgk ? 'SUT' : 'Kurum Payı';
  const fiyatBasligi = safSgk ? 'Hasta Katkısı' : 'Birim Fiyat';

  /**
   * SECIMDE ONAYLI (KILITLI) SATIR VAR MI (681, kullanici: "kilitlenmiş
   * satırların silme/değişme yapılamaması lazım").
   *
   * Sunucu zaten reddediyor; dugmeyi kapatmak kullaniciyi hata almaya
   * gondermemek icindir - satirdaki 🔒 neden kapali oldugunu soyler.
   */
  const kilitliSecili = satirlar.some(x => x.iskontoKilit && seciliSatirlar.has(x.anahtar));

  /**
   * DOVIZ CERCEVESI (kullanici): dovizli islem YOKSA "Rapor Dövizi / Sipariş
   * Dövizi" kutusu HIC cizilmez - basvuru/HBYS gibi tamamen yerel akislarda
   * bos yer kapliyordu. Bir kalemde doviz fiyat girilince (ya da rapor dovizi
   * yerelden farkli bir belgede) kutu kendiliginden geri gelir.
   */
  const dovizliIslem = raporDovizli
    || !!doviz?.ekstreDovizi && doviz.ekstreDovizi !== yerelPara
    || satirlar.some(r => !!r.fiyatDovizi && r.fiyatDovizi !== yerelPara);

  /** Dip toplam / TOPLAM satiri icin yerel -> rapor dovizi. */
  const dovizeCevir = (yerel: number) => (raporDovizli ? yerel / raporKur : yerel);

  /**
   * BASVURU DIP TOPLAMI KDV DAHIL SUTUNDAN (371/372): iskontosuz brut, iskonto
   * ve iskontolu genel toplam. Matrahtan turetmek kurus kaydiriyordu - hastaya
   * soylenen rakam saklanan bruttur.
   */
  const brutSatir = (r: SatirDurumu) => sayi(r.birimFiyatKdvli) || bruta(sayi(r.birimFiyat), r.kdv);
  const brutHam = satirlar.reduce((t, r) => t + sayi(r.adet) * brutSatir(r), 0);
  const brutGenel = satirlar.reduce(
    (t, r) => t + satirTutari(sayi(r.adet), brutSatir(r), r.iskonto, r.iskonto2), 0);
  const brutIskonto = Math.round((brutHam - brutGenel) * 100) / 100;
  /**
   * ISKONTO ORANI (kullanici): satirlarin orani AYNI OLMAYABILIR (her satirin
   * kendi iskontosu var, ustelik iki kademeli) - bu yuzden tek bir satirin
   * orani degil ETKIN oran yazilir: iskonto / iskontosuz toplam. Tek oranli
   * belgede zaten o oranin kendisi cikar; karma belgede de dogru olan budur.
   */
  const brutIskontoOran = brutHam > 0
    ? Math.round(brutIskonto / brutHam * 10000) / 100 : 0;
  /** Ayni oran SUNUCU dip toplami icin (kayitli belge): iskonto / Toplam. */
  const dipToplamHam = sonuc?.dipToplam.find(d => d.tur === 1)?.deger ?? 0;
  const dipIskonto = sonuc?.dipToplam.find(d => d.tur === 3)?.deger ?? 0;
  const dipIskontoOran = dipToplamHam > 0
    ? Math.round(dipIskonto / dipToplamHam * 10000) / 100 : 0;
  /** Belgede gercekten iskonto var mi - Iskonto (3) ve Ara Toplam (4) buna bagli. */
  const iskontoVar = () => Math.abs(dipIskonto) > 0.004;
  /**
   * KAC FARKLI KDV ORANI VAR (dip toplamda her oran ayri satir: tur 5).
   * Tek oran varsa "kdv Toplam" (15) o satirin AYNISIDIR - kullanici:
   * "tek kdv varsa kdv toplama da gerek yok".
   */
  const kdvSatirSayisi = (sonuc?.dipToplam ?? []).filter(d => d.tur === 5).length;
  return (
    <>
<div className="kagrup">
  <h6>
    {basvuruMu ? 'Ücretlendirme' : 'Kalemler'}
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
            disabled={kilitli || kilitliSecili || seciliSatirlar.size !== 1}
            title={kilitli ? 'Kesin belge satırı düzenlenemez.'
                  : kilitliSecili ? 'İskontosu onaylanmış satır değiştirilemez - '
                                  + 'değişiklik için yeni bir iskonto onayı alın.'
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
            disabled={kilitli || kilitliSecili || seciliSatirlar.size === 0}
            title={kilitli ? 'Kesin belgeden satır silinemez.'
                  : kilitliSecili ? 'İskontosu onaylanmış satır silinemez - '
                                  + 'önce iskonto onayını kaldırın.'
                  : seciliSatirlar.size === 0 ? 'Önce satır seçin'
                  : `Seçili ${seciliSatirlar.size} satırı sil`}
            onClick={seciliSil}>
      🗑
    </button>
    {/* AYRAC (kullanici): SATIR duzenleme dugmeleri (ekle/duzenle/sil) ile
        SATIRIN EKLERI (prim rolleri, dagilim, iskonto onayi) ayri isler -
        yan yana dizilince hepsi tek kume gibi okunuyordu. */}
    {onRoller && <span className="ayrac" />}
    {/* PRIM ROLLERI (324): primi kim hak ediyor - isteyen/uygulayan/
        raporlayan. Kalem KAYITLI olmali: rol satirin kimligine baglanir.
        Kilitli belgede de acilir (salt gorunum degil - rol duzeltmesi
        kesin belgede de gerekebilir; kesinlesmis prim zaten donuktur). */}
    {onRoller && (
      <button type="button" className="d ikon"
              disabled={seciliSatirlar.size !== 1}
              title={seciliSatirlar.size !== 1
                ? 'Rolleri düzenlemek için tek satır seçin'
                : 'Prim rollerini düzenle (isteyen / uygulayan / raporlayan)'}
              onClick={() => {
                const anahtar = [...seciliSatirlar][0];
                const sira = satirlar.findIndex(x => x.anahtar === anahtar);
                const satir = satirlar[sira];
                // Kaydedilmemis satirda da cagrilir: kart kaydeder ve
                //   pencereyi kendisi acar (satirId 0 = "kimligi yok").
                onRoller(satir?.satirId ?? 0, satir?.stokAdi ?? '', sira);
              }}>
        👥
      </button>
    )}
    {/* DAGILIMI YENILE (478): rota ve fiyatlar SUNUCUDA cozulur - ekran
        oran sormaz, "yeniden hesapla" der. Yalniz odeyen kurumlu basvuruda. */}
    {paylasim?.acik && (
      <button type="button" className="d ikon" disabled={kilitli}
              title="Ödeme dağılımını sözleşmeye göre yeniden hesapla"
              onClick={() => paylasim.uygula()}>
        ↻
      </button>
    )}
    {/* ISKONTO ONAYI (662, kullanici: "işaretli işlemler için onay istesin").
        Talep ACMAK yetki istemez - yetki gereken sey indirimi VERMEKtir;
        banko istemeyi bilir, verecek olan yetkilidir. Yalniz basvuruda:
        ERP belgesinde iskonto zaten satirda serbest. */}
    {basvuruMu && onIskontoOnay && (
      <button type="button" className="d ikon"
              disabled={kilitli || seciliSatirlar.size === 0}
              title={kilitli ? 'Kesin belgede iskonto onayı istenemez.'
                    : seciliSatirlar.size === 0
                    ? 'Önce iskonto istenecek satırları işaretleyin'
                    : `Seçili ${seciliSatirlar.size} satır için iskonto onayı iste`}
              onClick={() => onIskontoOnay([...seciliSatirlar])}>
        ✅
      </button>
    )}
    {/* DURUM ROZETI: son talebin akibeti. Bekleyende sari, onayda yesil
        (verilen oranla - istenen degil), rette kirmizi ve gerekce ipucunda:
        banko hastaya onu soyleyecek. */}
    {basvuruMu && sonTalep && (
      <span className={`rozet ${sonTalep.durum === 1 ? 'olumlu'
                       : sonTalep.durum === 2 ? 'hata' : 'uyari'}`}
            style={{ marginLeft: 6 }}
            title={sonTalep.durum === 0
              ? `İstenen %${sonTalep.oran} · ${sonTalep.satirSayisi} satır · `
                + `isteyen ${sonTalep.isteyen}
“${sonTalep.gerekce}”`
              : sonTalep.durum === 1
              ? `Onaylayan ${sonTalep.onaylayan} · istenen %${sonTalep.oran}`
                + (sonTalep.kararNotu ? `
“${sonTalep.kararNotu}”` : '')
              : `Reddeden ${sonTalep.onaylayan}
“${sonTalep.kararNotu}”`}>
        {/* Rozet ikonu MENUDEKIYLE AYNI (kullanici): ekranda ayni isin iki
            farkli sembolu olmasin. */}
        {sonTalep.durum === 0 ? `✅ İskonto onayı bekliyor (%${sonTalep.oran})`
         : sonTalep.durum === 1 ? `✅ İskonto onaylandı %${sonTalep.onaylananOran}`
         : '✅ İskonto reddedildi'}
      </span>
    )}
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
        {/* BASVURUDA tarih en solda (kullanici): islem tarihi kalemin kimligi. */}
        {tarihSolda && <th className="hiza-orta" style={{ width: 111 }}>Tarih</th>}
        <th style={{ width: 94 }}>Kod</th>
        <th>Stok / Hizmet</th>
        {aciklamaVar && <th style={{ width: 200 }}>Açıklama</th>}
        {/* TESLIM TARIHI (140) miktarin SOLUNDA, yalniz sipariste: satirin
            termini - "ne kadar"dan once "ne zaman" okunuyor. */}
        {bilgi.siparis && !tarihSolda && (
          <th className="hiza-orta" style={{ width: 92 }}>Teslim Tarihi</th>
        )}
        {/* Miktar / iskonto / KDV DAR (kullanici): ikisi de en fazla birkac
            hane; genis birakinca stok adi sikisiyordu. */}
        {/* Miktar · İsk.% · KDV % AYNI GENISLIKTE (kullanici): ucu de kisa
            sayi tasiyor, farkli genislikte olmalari gride duzensiz gorunum
            veriyordu. */}
        <th className="hiza-sag" style={{ width: 52 }}>Miktar</th>
        {/* Kisa basliklar (kullanici): iki kolon da dar - "İskonto %" tam
            sigmiyordu, KDV kolonu da gereginden genisti. */}
        {bilgi.kalem === 'tam' && <th className="hiza-sag" style={{ width: 52 }}>İsk.%</th>}
        {bilgi.kalem === 'tam' && <th className="hiza-sag" style={{ width: 52 }}>KDV %</th>}
        {/* Transferde FIYAT YOK: mal satilmiyor, depo degistiriyor. */}
        {/* Basvuruda deger KDV DAHILDIR ama baslikta yazmiyor (kullanici):
            kayit kabulde fiyat zaten hep KDV dahil konusuluyor - her satirda
            hatirlatmak yer kapliyordu. */}
        {/* Saf SGK'da baslik "Hasta Katkısı" - para birimi eki YOK (602,
            kullanici): kolon zaten yerel parada, ek yalniz basligi uzatiyordu.
            Oteki rotalarda "Birim Fiyat (TL)" eskisi gibi. */}
        {bilgi.kalem !== 'miktar' && (
          <th className="hiza-sag" style={{ width: 99 }}>
            {fiyatBasligi}{safSgk ? '' : ` (${yerelPara})`}</th>
        )}
        {/* SAF SGK'DA SUT, TUTARDAN ONCE (602, kullanici: "tutar ile SUT yer
            değiştir"): satirin iki bedeli once yan yana okunur, tutar da
            ikisinin toplami olarak ARKALARINDAN gelir -
            Hasta Katkısı + SUT = Tutar. */}
        {safSgk && kurumPayiKolonu && (
          <th className="hiza-sag" style={{ width: 110 }}>{kurumPayiBasligi}</th>
        )}
        {tutarKolonu && (
          <th className="hiza-sag" style={{ width: 108 }}>Tutar ({yerelPara})</th>
        )}
        {/* PAYLASIM (289): kurum ve hasta payi - yalniz odeyen kurumlu
            basvuruda. Provizyon degisince tutarlar burada okunur. Saf SGK'da
            kurum kolonu ("SUT") YUKARIDA, tutarin solunda cizildi. */}
        {!safSgk && kurumPayiKolonu && (
          <th className="hiza-sag" style={{ width: 110 }}>{kurumPayiBasligi}</th>
        )}
        {paylasim?.acik && <th className="hiza-sag" style={{ width: 110 }}>Hasta Payı</th>}
        {/* Doviz kolonlari: satir kendi dovizinde girildiyse ya da rapor dovizi
            secildiyse cizilir; hepsi yerel ve rapor yoksa GIZLI. */}
        {bilgi.kalem !== 'miktar' && dovizKolon && (
          <th className="hiza-sag" style={{ width: 120 }}>
            Döviz Birim{dovizAdi ? ` (${dovizAdi})` : ''}
          </th>
        )}
        {bilgi.kalem !== 'miktar' && dovizKolon && (
          <th className="hiza-sag" style={{ width: 120 }}>
            Döviz Tutar{dovizAdi ? ` (${dovizAdi})` : ''}
          </th>
        )}
      </tr>
    </thead>
    <tbody>
      {satirlar.map((r, sira) => {
        const adet = sayi(r.adet);
        const fiyat = sayi(r.birimFiyat);
        const tutar = satirTutari(adet, fiyat, r.iskonto, r.iskonto2);
        // DAGILIM: KAYITLI satirda sunucunun yazdigi kovalar, KAYDEDILMEMIS
        //   satirda ONIZLEME (594, kullanici: "kaydetmeden ücret satırının
        //   sağ tarafındaki + detay butonu gelmiyor, oysa ben eklediğimde
        //   hemen detay ne diye görmek istiyorum"). Ikisi de sunucudaki AYNI
        //   fonksiyondan gelir - onizlemede gorulen rakam kaydedince degismez.
        //   TUTAR ve PAY kolonlari da bundan okunur (602) - kolonlarin ustunde
        //   kullanildigi icin burada, en basta cozulur.
        const dagilimi = r.dagilim ?? dagilimOnizleme?.[r.anahtar];
        // BASVURUDA FIYAT KDV DAHIL GORUNUR (kullanici: "hbys'de fiyatlar hep
        //   kdv dahil veriliyor, ücretlemede o görülmek isteniyor"). Saklanan
        //   deger MATRAHTIR - satir matematigi, dip toplam ve e-Belge onun
        //   uzerinden yurur; burada yalniz GOSTERIM brute cevrilir. Fis/fatura
        //   dogal olarak matrahla kesilir, tahakkuk brut toplami tasir.
        //   SAKLANAN brut varsa O kullanilir (371) - turetmek kurus kaydiriyor;
        //   eski satirda kolon bos, o zaman matrahtan uretilir.
        const brutFiyat = sayi(r.birimFiyatKdvli) || bruta(fiyat, r.kdv);
        /**
         * SAF SGK'DA FIYAT KOLONU HASTA KATKISIDIR (602) - fiyat penceresiyle
         * ayni. Satirin SUT bedeli kendi kolonunda ("SUT") durur; burada
         * hastanin odedigi katki gorunur, cunku iskonto ona isler ve kullanici
         * indirimi bu kolonda takip eder. Katki MATRAH saklanir, basvuruda
         * kolonlar brut gosterilir.
         */
        const katkiMatrah = sayi(r.katkiTutar ?? '0');
        const gosterFiyat = safSgk
          ? (basvuruMu ? bruta(katkiMatrah, r.kdv) : katkiMatrah)
          : (basvuruMu ? brutFiyat : fiyat);
        /**
         * SATIR TUTARI DAGILIMDAN (602, kullanici: "br fiyat 85,73 doğru,
         * tutara iskonto uygulanmış - yanlış").
         *
         * `satirTutari` iskontoyu BIRIM FIYATA uygular; SGK/TSS'de birim fiyat
         * SUT bedelidir ve SUT iskontolanmaz - indirim yalniz hasta katkisina
         * isler (fn_dagilim_coz). Satirin gercek tutarini sunucu zaten
         * hesapliyor (`fn_belge_satir_dagit`: SGK payi + ek katki); dagilim
         * varken EKRAN DA ONU gostermeli, yoksa grid ile kayit farkli rakam
         * soyler. Dagilim yoksa (ozel is, dagilimsiz belge) eski hesap kalir.
         */
        //   Tutar KOVALARIN TOPLAMIDIR - SGK katilim payi HARIC: o, SGK adina
        //   alinan ciro disi emanettir, satirin tutarina girmez
        //   (fn_belge_satir_dagit her rotada boyle yaziyor).
        const dagilimTutari = dagilimi
          ? sayi(String(dagilimi.sgk ?? 0)) + sayi(String(dagilimi.oss ?? 0))
          + sayi(String(dagilimi.hastaProvizyon ?? 0))
          + sayi(String(dagilimi.hastaEkKatki ?? 0))
          : 0;
        const matrahTutar = dagilimi && dagilimTutari > 0 ? dagilimTutari : tutar;
        // SATIRIN BRUTU: KDV ORANIYLA DEGIL, SATIRIN KENDI ORANIYLA
        //   (kullanici: "500 girdim, 500,01 göründü").
        //
        //   `bruta(dagilimTutari)` matrahi KDV oraniyla yeniden carpiyordu:
        //   454,55 x 1,10 = 500,005 -> 500,01. Oysa satirin brutu KULLANICININ
        //   YAZDIGI sayidir (`birimFiyatKdvli`), matrah ondan turetildi -
        //   ters yone gidince kurus geri gelmiyor.
        //
        //   Sunucu da ayni kurali kullanir: dip toplamda KDV "brut tutar -
        //   matrah tutar"dir, orandan hesaplanmaz (`BelgeDeposu.Yazma`).
        //   Dagilim kovalari matrah oldugu icin brute `payBrute` ile
        //   olceklenir - paylarda zaten oyle yapiliyordu.
        const satirBrut = satirTutari(adet, brutFiyat, r.iskonto, r.iskonto2);
        const gosterTutar = basvuruMu
          ? (dagilimi && dagilimTutari > 0
              ? payBrute(dagilimTutari, tutar, satirBrut)
              : satirBrut)
          : matrahTutar;
        /** Matrah pay -> gosterim birimi (basvuruda brut, digerinde aynen). */
        const payGoster = (deger: number) =>
          basvuruMu ? payBrute(deger, matrahTutar, gosterTutar) : deger;
        /**
         * PAYLAR DAGILIMDAN (602, kullanici: "hasta payı hala 0 - yanlış").
         *
         * `r.kurumTutar`/`r.hastaTutar` sunucunun KAYITLI satira yazdigi
         * alanlardir; yeni eklenen satirda bos olduklari icin kolon 0
         * gosteriyordu - oysa "＋" detayi ayni satirda dolu rakam veriyordu
         * (o `dagilimi`den okuyor). Tek kaynak: dagilim.
         *
         * KATILIM PAYI HASTAYA DAHIL: hastanin kasada odeyecegi tutar budur
         * (ciro disi emanet olmasi TAHSILATI degil MUHASEBEYI ilgilendirir).
         * Acik tahsilat seridi de boyle topluyor (acikTahsilatTaraflara).
         */
        const kurumPayi = dagilimi
          ? sayi(String(dagilimi.sgk ?? 0)) + sayi(String(dagilimi.oss ?? 0))
          : sayi(r.kurumTutar ?? '0');
        /**
         * KATILIM PAYI BRUTLESTIRILMEZ (602, kullanici: "hasta payı 1610 gelmiş,
         * 1600 olmalı") - 593 kurali: SABIT EMANET TUTARIDIR, matrah degildir.
         * Oteki paylar matrahtir ve basvuruda KDV'li gosterilir; katilim payi
         * ayni islemden gecerse %10 KDV'de 100 TL 110 olup toplami 10 TL
         * sisiriyordu. Acik tahsilat seridi de boyle ayiriyor
         * (belgeKartiKurallari: `topla` fonksiyonunun `ham` parametresi).
         *
         * Dagilim yoksa `r.hastaTutar` tek sayidir, ayrilamaz - orada eski
         * davranis surer (kayitli satirda dagilim her zaman vardir).
         */
        const hastaPayiMatrah = dagilimi
          ? sayi(String(dagilimi.hastaProvizyon ?? 0))
          + sayi(String(dagilimi.hastaEkKatki ?? 0))
          : sayi(r.hastaTutar ?? '0');
        const katilimPayi = dagilimi ? sayi(String(dagilimi.sgkKatilimPayi ?? 0)) : 0;
        const secili = seciliSatirlar.has(r.anahtar);
        // Izlemli kalemin lotlari ALTINDA acilir (master-detail):
        //   hangi lottan kac adet oldugu kalemi acmadan gorunsun.
        const lotlar = r.izlemler ?? [];
        // IZLEM (lot/seri) satirlari VARSAYILAN KAPALI (kullanici): kalem
        //   listesi kisa kalsin, isteyen okla acsin.
        const acik = lotlar.length > 0 && acikLotlar.has(r.anahtar);
        const onizlemeDagilimi = !r.dagilim && !!dagilimi;
        const dagilimAcik = !!dagilimi && acikDagilimlar.has(r.anahtar);
        const kolonSayisi = (bilgi.kalem === 'miktar' ? 6 : bilgi.kalem === 'sade' ? 8 : 10)
                          // Tutar kolonu saf SGK'da yok (602).
                          - (bilgi.kalem !== 'miktar' && !tutarKolonu ? 1 : 0)
                          - (aciklamaVar ? 0 : 1)
                          + (dovizKolon && bilgi.kalem !== 'miktar' ? 2 : 0)
                          + (bilgi.siparis ? 1 : 0)    // teslim tarihi (140)
                          // Hasta payi + (saf SGK degilse) kurum payi (289/601).
                          + (paylasim?.acik ? 1 : 0)
                          + (kurumPayiKolonu ? 1 : 0);
        return (
          <Fragment key={r.anahtar}>
          <tr className={secili ? 'secili' : ''}
              onClick={e => satirTikla(sira, e)}
              onDoubleClick={() => !kilitli && !r.iskontoKilit && setKalem(r)}>
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
            {tarihSolda && (
              <td className="hiza-orta">
                {r.teslimTarihi
                  ? tarihSaat(r.teslimTarihi)
                  : <span className="sonuk">—</span>}
              </td>
            )}
            <td><code>{r.stokKodu}</code></td>
            <td>
              {/* Lotlu kalemde ac/kapa oku - detay satirlari onun altinda. */}
              {lotlar.length > 0 && (
                <button type="button" className="lot-ok"
                        title={acik ? 'Lotları gizle' : 'Lotları göster'}
                        onClick={e => {
                          e.stopPropagation();
                          setAcikLotlar(k => {
                            const y = new Set(k);
                            if (y.has(r.anahtar)) y.delete(r.anahtar); else y.add(r.anahtar);
                            return y;
                          });
                        }}>
                  {acik ? '▾' : '▸'}
                </button>
              )}
              {/* ONAYLI ISKONTO KILIDI (662): satirin iskontosu onaylandi,
                  degistirilemez - ikon satirda dursun ki kullanici duzenlemeye
                  girip hata almadan once gorsun. */}
              {r.iskontoKilit && (
                <span title="İskontosu onaylanmış satır - değiştirilemez ve silinemez"
                      style={{ marginRight: 4 }}>🔒</span>
              )}
              {r.stokAdi || <span className="sonuk">(stok seçilmedi)</span>}
            </td>
            {aciklamaVar && <td className="sonuk">{r.aciklama}</td>}
            {bilgi.siparis && !tarihSolda && (
              <td className="hiza-orta">
                {r.teslimTarihi
                  ? tarihSaat(r.teslimTarihi)
                  : <span className="sonuk">—</span>}
              </td>
            )}
            <td className="hiza-sag">{adet.toLocaleString('tr-TR')}</td>
            {/* Iki iskonto varsa ikisi de gorunsun: "%10 + %5". */}
            {bilgi.kalem === 'tam' && <td className="hiza-sag">{iskonatoMetni(r)}</td>}
            {bilgi.kalem === 'tam' && <td className="hiza-sag">%{r.kdv}</td>}
            {bilgi.kalem !== 'miktar' && <td className="hiza-sag">{para.format(gosterFiyat)}</td>}
            {/* SUT, TUTARIN SOLUNDA (602) - basliklarla ayni sira:
                Hasta Katkısı + SUT = Tutar. */}
            {safSgk && kurumPayiKolonu && (
              <td className={`hiza-sag${(r.kurumKapatilan ?? 0) > 0 ? ' basari' : ''}`}>
                {para.format(payGoster(kurumPayi))}
              </td>
            )}
            {tutarKolonu && (
              <td className="hiza-sag"><b>{para.format(gosterTutar)}</b></td>
            )}
            {/* Pay hucreleri (289): kapanan pay YESIL - hangi payin
                faturalandigi listeye bakinca gorunsun. */}
            {/* PAYLAR DA GOSTERIM BIRIMINDE (kullanici): saklanan pay MATRAHTIR
                ama basvuruda fiyat ve tutar KDV DAHIL gorunuyor - ayni satirda
                2.200 TL tutar ile 1.600 + 400 pay yan yana durunca toplam
                tutmuyordu. Brute cevrilirken satirin KENDI tutar orani
                kullanilir (tutar -> gosterTutar), boylece kurus artigi paylar
                arasinda kaymaz. */}
            {!safSgk && kurumPayiKolonu && (
              <td className={`hiza-sag${(r.kurumKapatilan ?? 0) > 0 ? ' basari' : ''}`}>
                {para.format(payGoster(kurumPayi))}
              </td>
            )}
            {paylasim?.acik && (
              <td className={`hiza-sag${(r.hastaKapatilan ?? 0) > 0 ? ' basari' : ''}`}>
                {para.format(payGoster(hastaPayiMatrah) + katilimPayi)}
                {/* DAGILIM: bes kova tek satira sigmaz - "+" ile ALT SATIRDA
                    acilir (kullanici). Dagilim henuz hesaplanmamis satirda
                    dugme cizilmez: acilinca bos kutu gostermek yaniltirdi. */}
                {dagilimi && (
                  <button type="button" className="lot-ok dagilim-ok"
                          title={dagilimAcik ? 'Dağılımı gizle' : 'Ödeme dağılımını göster'}
                          onClick={e => {
                            e.stopPropagation();
                            setAcikDagilimlar(k => {
                              const y = new Set(k);
                              if (y.has(r.anahtar)) y.delete(r.anahtar);
                              else y.add(r.anahtar);
                              return y;
                            });
                          }}>
                    {dagilimAcik ? '−' : '＋'}
                  </button>
                )}
              </td>
            )}
            {bilgi.kalem !== 'miktar' && dovizKolon && (() => {
              const d = satirDoviz(r, tutar, fiyat);
              return (
                <>
                  <td className="hiza-sag sonuk">{d ? para.format(d.birim) : '—'}</td>
                  <td className="hiza-sag sonuk">{d ? para.format(d.tutar) : '—'}</td>
                </>
              );
            })()}
          </tr>
          {/* DETAY: satirin ODEME DAGILIMI (470). Bes kova, kapatilan ve
              tahsil edilen sayaclariyla. Kalanlar SUNUCUDAN gelir - ekran
              cikarma yapmaz, yoksa iki yerde iki sonuc olurdu. */}
          {dagilimAcik && dagilimi && (() => {
            const d = dagilimi;
            // HANGI KOVA CIZILIR (kullanici: "TSS'de + ile açılan detayda hasta
            //   payı ve hasta ek katkısı satırları olmasın"): rotanin
            //   UREBILECEGI kovalar + degeri olan her kova. Rotada dogabilen
            //   ama BU SATIRDA SIFIR kalan kova da cizilmez - TSS'de hastane
            //   farki yoksa "Hasta ek katkısı 0,00" satiri bos yer kapliyordu.
            //   Hareketi olan (kapatilan/tahsil) kova her zaman gorunur:
            //   tutari sifirlanmis olsa da parasi gecmistir.
            const kovaDeger = (k: typeof KOVALAR[number]) =>
              Number(d[k.alan] ?? 0)
              + Number((d as unknown as Record<string, number>)[
                  k.kod === 5 ? 'sgkKatilimTahsil' : `${k.alan}Tahsil`] ?? 0)
              + (k.kod === 5 ? 0 : Number((d as unknown as Record<string, number>)[
                  `${k.alan}Kapatilan`] ?? 0));
            const kovalar = KOVALAR.filter(k => kovaKullanilir(d.rota, k.kod)
                                             && kovaDeger(k) > 0);
            /**
             * KOVALAR KDV DAHIL GOSTERILIR (kullanici: "sgk ve sigorta kdv
             * dahil olmalı").
             *
             * Kovalar ve KAPATILAN sayaclari MATRAH tutulur (kurum icmali ve
             * hakedis matrah uzerinden calisir); tahsil sayaclari BRUT'tur.
             * Ekranda okunan rakam faturadaki/kasadaki tutar olmali - 909,09
             * yerine 1.000,00. SGK KATILIM PAYI istisna: sabit tutardir,
             * vergi disi emanettir - oldugu gibi yazilir.
             */
            const kdvCarpani = 1 + (Number(r.kdv) || 0) / 100;
            const brut = (kod: number, deger: number) =>
              Math.round((kod === 5 ? deger : deger * kdvCarpani) * 100) / 100;
            const kapatilan = (k: typeof KOVALAR[number]) =>
              k.kod === 5 ? 0 : brut(k.kod, Number(
                (d as unknown as Record<string, number>)[`${k.alan}Kapatilan`] ?? 0));
            const tahsil = (k: typeof KOVALAR[number]) => Number(
              (d as unknown as Record<string, number>)[
                k.kod === 5 ? 'sgkKatilimTahsil' : `${k.alan}Tahsil`] ?? 0);
            // Ciro ve "hastadan tahsil edilecek" de ayni dilde (KDV dahil);
            //   katilim payi brutlestirilmez.
            const kdvC = 1 + (Number(r.kdv) || 0) / 100;
            const ciro = Math.round((Number(d.sgk) + Number(d.oss)
                       + Number(d.hastaProvizyon) + Number(d.hastaEkKatki))
                       * kdvC * 100) / 100;
            const hastadan = Math.round(
              ((Number(d.hastaProvizyon) + Number(d.hastaEkKatki)) * kdvC
               + Number(d.sgkKatilimPayi)
               - Number(d.hastaProvizyonTahsil)
               - Number(d.hastaEkKatkiTahsil) - Number(d.sgkKatilimTahsil)) * 100) / 100;
            return (
              <tr className="lot-detay dagilim-detay">
                <td />
                <td colSpan={kolonSayisi - 1}>
                  <table className="lot-tablo">
                    <thead>
                      <tr>
                        <th>Pay ({ROTA_ADI[d.rota] ?? '—'})
                          {/* Kaydedilmemis satirda rakam ONIZLEMEDIR (594):
                              kural aynidir ama satir henuz kayitli degil. */}
                          {onizlemeDagilimi && (
                            <span className="ipucu"> · önizleme</span>)}
                        </th>
                        <th className="hiza-sag">Tutar</th>
                        <th className="hiza-sag">Kapatılan</th>
                        <th className="hiza-sag">Tahsil</th>
                        <th className="hiza-sag">Kalan</th>
                        <th>Provizyon / Not</th>
                      </tr>
                    </thead>
                    <tbody>
                      {kovalar.map(k => {
                        const tutarK = brut(k.kod, Number(d[k.alan] ?? 0));
                        const kalanK = Math.max(tutarK - kapatilan(k) - tahsil(k), 0);
                        return (
                          <tr key={k.kod}>
                            <td>{k.ad}</td>
                            <td className="hiza-sag">
                              {kovaKullanilir(d.rota, k.kod) || tutarK > 0
                                ? para.format(tutarK) : <span className="sonuk">—</span>}
                            </td>
                            <td className="hiza-sag sonuk">
                              {k.kod === 5 ? '—' : para.format(kapatilan(k))}
                            </td>
                            <td className="hiza-sag sonuk">{para.format(tahsil(k))}</td>
                            <td className="hiza-sag">{para.format(kalanK)}</td>
                            <td className="sonuk">
                              {k.kod === 2 && d.sgkProvizyonNo ? d.sgkProvizyonNo
                               : k.not ?? ''}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                    <tfoot>
                      <tr>
                        <td>Ciro</td>
                        <td className="hiza-sag">{para.format(ciro)}</td>
                        <td colSpan={2} className="sonuk">Hastadan tahsil edilecek</td>
                        <td className="hiza-sag">{para.format(Math.max(hastadan, 0))}</td>
                        <td className="sonuk">
                          {d.elle === 1 ? 'elle sabitlendi' : ''}
                        </td>
                      </tr>
                    </tfoot>
                  </table>
                </td>
              </tr>
            );
          })()}
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
                          {(sayi(z.miktar)).toLocaleString('tr-TR')}
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
        <tr><td colSpan={(bilgi.kalem === 'miktar' ? 6 : bilgi.kalem === 'sade' ? 8 : 10)
                       + (bilgi.kalem !== 'miktar' ? 1 : 0)
                          + (dovizKolon && bilgi.kalem !== 'miktar' ? 2 : 0)} className="bos">
          {transferBaslikEksigi
            ? `Kalem eklemek için önce başlıkta ${transferBaslikEksigi} seçin.`
            : 'Kalem yok — “＋” ile ekleyin.'}
        </td></tr>
      )}
    </tbody>
    {/* GRIDIN KENDI TOPLAM SATIRI KALKTI (kullanici): hemen altinda dip
        toplam tablosu duruyor - ayni rakami iki kez, ustelik biri MATRAH
        digeri BRUT olarak gostermek "hangisi dogru" sorusunu doguruyordu.
        Miktar toplami da bununla birlikte gitti; kalem sayisi grid basliginda
        ("N kalem") yaziyor. */}
  </table>
  {/* "Satırı düzenlemek için çift tıklayın." KALKTI (kullanici): her belgede,
      her zaman duran bir ipucu satiriydi - ogrenildikten sonra yalniz yer
      kapliyor. Cift tik da ✎ dugmesi de yerinde. BASLIK KILIDI notu KALIR:
      o, kullanicinin o an karsilastigi bir DURUMU acikliyor. */}
  {!kilitli && satirlar.length > 0 && (depoBelgesi || stokFisiMi) && (
    <div className="not">
      {`Kalem eklendiği için başlık (${stokFisiMi ? 'tip, depo' : talepMi ? 'depolar, talep eden' : 'depolar, teslim eden/alan'}, tarih) kilitlendi — değiştirmek için kalemleri silin.`}
    </div>
  )}
</div>

{/* Doviz kutusu SOLDA, dip toplam SAGDA - ayni hizada (kullanici). */}
{bilgi.kalem !== 'miktar' && (
<div className="grid-alt-serit">
{doviz && dovizliIslem && (
  /* RAPOR / EKSTRE DOVIZI (134) - gridin ALTINDA SOLDA (kullanici).
     Rapor dovizi yerel para disindaysa yaninda KUR editi cikar ve dip toplam
     ikinci bir kolonda yerel karsiligiyla gosterilir. Ekstre dovizi cari
     hesaba hangi dovizde islenecegidir: rapor dovizi ya da yerel para. */
  <div className="kagrup belge-doviz">
    <div className="alan-izgara tek-sutun">
      <label className="alan">
        <span className="etiket">Rapor Dövizi</span>
        <div className="ikili">
          <select value={doviz.raporDovizi} disabled={kilitli}
                  onChange={e => doviz.setRaporDovizi(e.target.value)}>
            {DOVIZ_KODLARI.map(k => <option key={k} value={k}>{k}</option>)}
          </select>
          {doviz.raporDovizi !== doviz.yerelPara && (
            <input className="kur hiza-sag" value={doviz.kur} disabled={kilitli}
                   title={`1 ${doviz.raporDovizi} = ? ${doviz.yerelPara}`}
                   onChange={e => doviz.setKur(e.target.value)} />
          )}
        </div>
      </label>
      <label className="alan">
        {/* "Ekstre Dövizi" = cari hesaba hangi dovizde islenecegi. SIPARISTE
            cari hareketi YOK (henuz mal/fatura cikmadi), o yuzden orada alan
            "Sipariş Dövizi" adiyla cikar (kullanici) - siparis onaylanip
            irsaliye/faturaya donunce ekstre dovizi olarak tasinir. */}
        <span className="etiket">{bilgi.siparis ? 'Sipariş Dövizi' : 'Ekstre Dövizi'}</span>
        <select value={doviz.ekstreDovizi} disabled={kilitli}
                onChange={e => doviz.setEkstreDovizi(e.target.value)}>
          {/* Rapor dovizi + yerel para (ayni ise tek secenek). */}
          {[...new Set([doviz.raporDovizi, doviz.yerelPara])]
            .map(k => <option key={k} value={k}>{k}</option>)}
        </select>
      </label>
    </div>
    {doviz.raporDovizi !== doviz.yerelPara && (
      <div className="not">
        Tutarlar {doviz.yerelPara} girilir; {doviz.raporDovizi} karşılığı kura
        bölünerek gösterilir.
        {/* Siparis cari hesabi ETKILEMEZ - "cari hesaba islenir" cumlesi orada
            yaniltici olurdu. */}
        {!bilgi.siparis && <> Cari hesaba <b>{doviz.ekstreDovizi}</b> işlenir.</>}
      </div>
    )}
  </div>
)}

{/* FIYAT LISTESI (218): basliktan buraya tasindi - doviz cercevesinin
    SAGINDA (kullanici). Degistirilince satirlar yeniden fiyatlanir. */}
{fiyatListesi && fiyatListesi.listeler.length > 0 && (
  // marginRight:auto - kutu SOLDAKI doviz cercevesine yanasik durur,
  //   dip toplam sagda kalir (kullanici).
  <div className="kagrup belge-doviz" style={{ marginRight: 'auto' }}>
    <div className="alan-izgara tek-sutun">
      <label className="alan">
        <span className="etiket">Fiyat Listesi</span>
        <select value={fiyatListesi.seciliId ?? ''} disabled={kilitli}
                onChange={e => fiyatListesi.sec(e.target.value ? Number(e.target.value) : null)}>
          <option value="">(liste yok)</option>
          {fiyatListesi.listeler.map(l => <option key={l.id} value={l.id}>{l.ad}</option>)}
        </select>
      </label>
      {/* DEPO (296): basvuruda baslikta Doktor'a yer acildi, depo buraya indi.
          Diger turlerde baslikta kaldigi icin burada CIZILMEZ. */}
      {depoSecimi && (
        <label className="alan">
          <span className="etiket">Depo</span>
          <select value={depoSecimi.seciliId ?? ''} disabled={kilitli}
                  onChange={e => depoSecimi.sec(e.target.value ? Number(e.target.value) : null)}>
            <option value="">(depo yok)</option>
            {depoSecimi.listeler.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}
          </select>
        </label>
      )}
      {/* KAMPANYA ROZETI (274): SALT OKUNUR - kampanya kurumun sozlesmesinden
          (ya da cariden) gelir, belgede elle secilmez; kullanici yanlislikla
          anlasmadan cikmasin. Liste bazi, kampanya indirimi verir. */}
      {fiyatListesi.kampanyaAdi && (
        <label className="alan">
          <span className="etiket">Kampanya</span>
          <span className="deger-serit">
            <span className="rozet bilgi">{fiyatListesi.kampanyaAdi}</span>
          </span>
        </label>
      )}
    </div>
  </div>
)}

{(
<div className="kagrup dip-toplam">
  {/* BASLIK YOK (kullanici): cerceve ve kolon basliklari zaten neyin ne
      oldugunu soyluyor; "Dip Toplam" satiri yer kapliyordu. */}
  {/* BASVURUDA SUNUCU DIP TOPLAMI KULLANILMAZ (kullanici: "birim fiyat 2200,
      paylar 1600+400, alt toplam 2000 - bu nasil olur"). Sunucu toplami
      MATRAH konusur (Toplam 2000), ekranin geri kalani ise KDV DAHIL (2200) -
      ayni tabloda iki ayri birim yan yana duruyordu. Basvuruda her rakam
      brut: asagidaki dal zaten brut hesaplar. */}
  {sonuc && !basvuruMu ? (
    <table className="dip-tablo">
      {raporDovizli && (
        <thead>
          {/* Dip toplamda SOLDA yerel, SAGDA doviz (kullanici). */}
          <tr><th /><th className="hiza-sag">{yerelPara}</th>
              <th className="hiza-sag">{doviz!.raporDovizi}</th></tr>
        </thead>
      )}
      <tbody>
        {/* BASVURUDA SUNUCU DIP TOPLAMI DA SADE (kullanici): fiyatlar KDV
            dahil konusuldugu icin Ara Toplam / KDV kirilimi hastayi
            ilgilendirmiyor - o kirilim fatura kesilirken dogar. Iskonto (3) ve
            Genel Toplam (20) kalir; iskonto YOKSA sunucu o satiri zaten
            uretmez, tek satir gorunur. */}
        {sonuc.dipToplam
          // SIFIR ISKONTO YAZILMAZ (kullanici: "fişe girdim, iskonto 0 olduğu
          //   halde dip toplamda görünüyor"): indirimsiz belgede "İskonto 0,00"
          //   satiri bilgi vermez, dip toplami uzatir. Diger satirlar (Toplam /
          //   KDV / Genel Toplam) sifir da olsa kalir - belgenin iskeleti.
          // ARA TOPLAM da ISKONTOYA baglidir (kullanici: "belge içinde iskonto
          //   yoksa ara toplama gerek yok"): Ara Toplam = Toplam - Iskonto,
          //   indirimsiz belgede Toplam ile AYNI sayidir - ayni rakam ust uste
          //   iki satir olarak yaziliyordu.
          .filter(d => (d.tur !== 3 && d.tur !== 4) || iskontoVar())
          // Tek KDV oraninda toplam satiri tekrar: "kdv%10" ile "kdv Toplam"
          //   ayni rakam. Birden cok oranda (8 + 20) toplam ANLAMLI, kalir.
          .filter(d => d.tur !== 15 || kdvSatirSayisi > 1)
          .filter(d => !basvuruMu
            // ISKONTO YOKSA "Toplam" da cizilmez: Genel Toplam ile ayni
            //   rakami iki kez gostermek olurdu. Iskonto varsa uclu kalir.
            || (d.tur === 1 && iskontoVar())
            || d.tur === 3 || d.tur === 20)
          .map((d, i) => (
          <tr key={i} className={d.tur === 20 ? 'genel' : ''}>
            {/* ISKONTO SATIRINDA ORAN DA (kullanici): tutarin yaninda "%10".
                Satirlarin orani farkli olabildigi icin ETKIN oran yazilir -
                iskonto / iskontosuz toplam. */}
            <td>{d.aciklama}{d.tur === 3 && dipIskontoOran > 0 && (
              <span className="sonuk"> %{say4.format(dipIskontoOran)}</span>)}</td>
            <td className="hiza-sag">{para.format(d.deger)}</td>
            {/* Dovizli belgede IKINCI kolon: kur ile yerel karsilik (kullanici). */}
            {raporDovizli && (
              <td className="hiza-sag sonuk">{para.format(dovizeCevir(d.deger))}</td>
            )}
          </tr>
        ))}
      </tbody>
    </table>
  ) : (
    <table className="dip-tablo">
      {raporDovizli && (
        <thead>
          {/* Dip toplamda SOLDA yerel, SAGDA doviz (kullanici). */}
          <tr><th /><th className="hiza-sag">{yerelPara}</th>
              <th className="hiza-sag">{doviz!.raporDovizi}</th></tr>
        </thead>
      )}
      <tbody>
        {/* BASVURUDA KDV SATIRI YOK (kullanici): fiyatlar zaten KDV DAHIL
            konusuluyor - matrah/KDV kirilimi hastayi ilgilendirmiyor, fatura
            kesilirken dogar. Iskonto varsa uc satir kalir: Toplam · İskonto ·
            Genel Toplam. Rakamlar KDV DAHIL SUTUNDAN gelir (371) - matrahtan
            turetmek kurus kaydiriyordu. */}
        {basvuruMu ? (
          <>
            {brutIskonto > 0.004 && (
              <>
                <tr>
                  <td>Toplam</td>
                  <td className="hiza-sag">{para.format(brutHam)}</td>
                  {raporDovizli && <td className="hiza-sag sonuk" />}
                </tr>
                <tr>
                  <td>İskonto <span className="sonuk">%{say4.format(brutIskontoOran)}</span></td>
                  <td className="hiza-sag ind">−{para.format(brutIskonto)}</td>
                  {raporDovizli && <td className="hiza-sag sonuk" />}
                </tr>
              </>
            )}
            <tr className="genel">
              <td>Genel Toplam</td>
              <td className="hiza-sag">{para.format(brutGenel)}</td>
              {raporDovizli && <td className="hiza-sag sonuk" />}
            </tr>
          </>
        ) : (
        <>
        <tr>
          <td>Ara Toplam</td><td className="hiza-sag">{para.format(onizleme.matrah)}</td>
          {raporDovizli && <td className="hiza-sag sonuk">{para.format(dovizeCevir(onizleme.matrah))}</td>}
        </tr>
        <tr>
          <td>KDV</td><td className="hiza-sag">{para.format(onizleme.kdv)}</td>
          {raporDovizli && <td className="hiza-sag sonuk">{para.format(dovizeCevir(onizleme.kdv))}</td>}
        </tr>
        <tr className="genel">
          <td>Genel Toplam</td><td className="hiza-sag">{para.format(onizleme.genel)}</td>
          {raporDovizli && <td className="hiza-sag sonuk">{para.format(dovizeCevir(onizleme.genel))}</td>}
        </tr>
        </>
        )}
      </tbody>
    </table>
  )}
  {/* "Kesin tutar sunucuda hesaplanir" notu kaldirildi (kullanici): kayittan
      sonra zaten sunucunun dondurdugu tutar gosteriliyor. */}
</div>
)}
</div>
)}
    </>
  );
}

export interface KalemSekmesiProps {
  /**
   * KAYDEDILMEMIS satirlarin dagilim onizlemesi (594) - satir anahtari -> kovalar.
   * Kayitli satirin kendi `dagilim`i onceliklidir.
   */
  dagilimOnizleme?: Record<string, import('../../sayfalar/belgeSatir').SatirDagilimi>;
  satirlar: SatirDurumu[];
  seciliSatirlar: Set<number>;
  setSeciliSatirlar(v: Set<number>): void;
  /** Lot detayi ACIK olan kalemler (varsayilan KAPALI). */
  acikLotlar: Set<number>;
  setAcikLotlar(v: Set<number> | ((o: Set<number>) => Set<number>)): void;
  kilitli: boolean;
  /** belgeTuru.ts davranis tablosu: kalem bicimi (tam | sade | miktar) vb. */
  bilgi: { kalem: 'tam' | 'sade' | 'miktar'; alis: boolean; siparis: boolean };
  onizleme: { matrah: number; kdv: number; genel: number };
  sonuc: BelgeYaniti | null;
  /** Transferde eksik baslik alani (varsa kalem eklenemez). */
  transferBaslikEksigi: string | null;
  depoBelgesi: boolean;
  stokFisiMi: boolean;
  talepMi: boolean;
  setStokArama(v: boolean): void;
  setKalem(v: SatirDurumu | null): void;
  seciliSil(): void;
  /** Satir tiklama (Shift ile aralik secimi kartta yonetiliyor). */
  satirTikla(sira: number, e: React.MouseEvent): void;
  /** Son tiklanan satirin SIRASI - Shift araligi bunun uzerinden hesaplanir. */
  sonTiklanan: React.MutableRefObject<number | null>;
  secimDegis(anahtar: number): void;
  /**
   * PRIM ROLLERI (324): secili kalemin rollerini acar. Verilmezse dugme hic
   * cizilmez - prim yetkisi olmayan kullanicida ya da prim kullanilmayan
   * kurulumda gereksiz. satirId 0 gelirse kalem henuz KAYITLI degildir.
   */
  /**
   * PRIM ROLLERI. `sira` satirin GRIDDEKI sirasidir (0 tabanli): kalem henuz
   * kaydedilmemisse kart once kaydeder, sonra AYNI SIRADAKI satirin sunucudan
   * gelen kimligiyle pencereyi acar (kullanici: "ekleme yapıp rolleri görme
   * butonuna basarsam ücret satırlarını önce kaydetsin sonra orayı açsın").
   */
  onRoller?(satirId: number, kalemAdi: string, sira: number): void;
  /**
   * ISKONTO ONAYI (662): isaretli satirlar icin onay talebi acar. Satir
   * ANAHTARLARI gelir (kimlik degil) - satir henuz kaydedilmemis olabilir,
   * kart once kaydeder sonra kimlikleri cozer.
   */
  onIskontoOnay?(anahtarlar: number[]): void;
  /**
   * Belgenin ISKONTO TALEPLERI (662) - en yenisi baslikta rozet olur.
   * Banko talebi gonderdikten sonra "ne oldu" sorusunu burada okur; sonucu
   * yalniz zilde birakmak, isteyeni haberden tamamen dislardi.
   */
  iskontoTalepleri?: IskontoTalebi[];
  /**
   * ODEME PAYLASIMI (289): basvuruda odeyen kurum varsa satirin KURUM ve HASTA
   * payi kolon olarak gorunur. Verilmezse kolonlar hic cizilmez - normal
   * fatura/irsaliyede paylasim kavrami yoktur.
   */
  /**
   * BASVURU (279): kalem tarihi kolonu KOD'un soluna alinir ve basligi
   * "Tarih" olur - hastanin islem tarihi bir TERMIN degil, satirin kendi
   * tarihidir (kullanici). Normal sipariste kolon eski yerinde ("Teslim
   * Tarihi", miktarin solunda) kalir.
   */
  basvuruMu?: boolean;
  paylasim?: {
    acik: boolean;
    /**
     * Basvurunun odeme rotasi (601). SAF SGK'da "Kurum Payı" kolonu CIZILMEZ:
     * o rotada satirin tutari zaten SGK'nin odedigi SUT bedelidir (birim fiyat
     * = SUT), yani kolon birim fiyatin/tutarin kopyasi oluyordu. Kullanici
     * (SGK hastalari icin): "birim fiyat tutar hasta payı olsun ama kurum
     * payını gösterme sütun olarak."
     *
     * TSS/Karma/ÖSS'de kolon DURUR - orada kurumun odedigi tutar satirin
     * tutarindan gercekten farklidir.
     */
    rota?: number | null;
    /** Dagilimi SUNUCUDA yeniden hesaplatir (478). */
    uygula(): void;
  };
  /**
   * DEPO SECIMI (296): basvuruda baslikta yer DOKTORA verildi, depo buraya -
   * fiyat listesinin altina - indi (kullanici). Verilmezse cizilmez.
   */
  depoSecimi?: {
    listeler: { id: number; ad: string }[];
    seciliId: number | null;
    sec(v: number | null): void;
  };
  /** Fiyat listesi (205/218): doviz cercevesinin SAGINDA cizilir (kullanici).
      Liste hic kurulmamissa verilmez, kutu cizilmez. */
  fiyatListesi?: {
    listeler: { id: number; ad: string }[];
    seciliId: number | null;
    sec(v: number | null): void;
    /** Yururlukteki kampanya adi (274) - listenin altinda ROZET, salt okunur. */
    kampanyaAdi?: string;
  };
  /** Rapor / ekstre dovizi kutusu (134). Verilmezse kutu cizilmez. */
  doviz?: {
    raporDovizi: string;
    setRaporDovizi(v: string): void;
    ekstreDovizi: string;
    setEkstreDovizi(v: string): void;
    kur: string;
    setKur(v: string): void;
    yerelPara: string;
  };
}


// Tahsilat sekmesi kendi dosyasinda; cagri yeri (BelgeKarti) ayni
//   import satirini kullanmaya devam etsin diye buradan aktarilir.
export { TahsilatSekmesi } from './TahsilatSekmesi';
