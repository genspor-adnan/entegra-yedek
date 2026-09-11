import { useEffect, useState } from 'react';
import type { SevkiyatBilgisi, TeklifBilgisi }
  from '../../sayfalar/belgeKarti/useSevkiyatBilgisi';
import { GenLookup } from '../GenLookup';
import { api } from '../../api/istemci';
import { KodListesiModali } from '../KodListesiModali';
import { yerelAnMetni } from '../bicim';
import { TarafAlani } from '../../sayfalar/BelgeKarti';
import {
  LOOKUP_DEPO, GIRIS_FIS_TIPLERI, CIKIS_FIS_TIPLERI, SEKMELER, TEKLIF_DURUMLARI,
} from '../../sayfalar/belgeSabitleri';
import type { SatirDurumu } from '../../sayfalar/belgeSatir';
import type { Secim } from '../../sayfalar/belgeKaydet';
import type { BelgeYaniti } from '../../api/sozlesme';
import type { BelgeTuruBilgisi } from '../../sayfalar/belgeTuru';

/**
 * BELGE KARTI BASLIGI - TEK 4 SUTUNLU izgara (kullanici). Once satis
 * irsaliyesinde denendi, sonra tum carili belgelere (fatura, siparis,
 * konsinye, tahakkuk), en son depo belgeleri ve stok fislerine yayildi -
 * artik her belge turu ayni duzeni kullaniyor.
 *
 * Hucre SIRASI sabit; bir tur icin anlamsiz olan hucre CIZILMEZ ve izgara
 * kendiliginden sarar (eski 3 sutunlu duzende sutun hizasini korumak icin
 * bos yer tutucu hucreler gerekiyordu, hepsi kalkti):
 *
 *   1) Kimlik  - cari / cikis deposu (depo belgesi) / fis tipi (stok fisi)
 *   2) Belge No
 *   3) Belge Tarihi
 *   4) e-Belge rozeti (kavrami olan turlerde)
 *   5) Kisi-1   - Satis Temsilcisi / Sorumlu / Teslim Eden
 *   6) Depo-2   - Giris Deposu / Teslim Deposu / fisin deposu
 *   7) Kisi-2   - Teslim Alan / Talep Eden (depo belgeleri)
 *   8) Fatura Tipi (yalniz fatura)
 *   9) Vade (gun)
 *  10) Bagli Siparis / Kaynak Belge
 *  11) Faturalama Durumu (kapanma)
 *
 * Doviz/Kur BASLIKTA DEGIL: kalem gridinin altindaki "Rapor Dövizi" kutusunda
 * hem secim hem kur var - iki yerde gostermek tekrar oluyordu (kullanici).
 * Belge turu SECICISI de yok: tur ekranin kendisinden gelir ve pencere
 * basliginda yazili; kartta degistirilebilmesi belgenin hangi listede
 * cikacagini belirsizlestiriyordu.
 */
export function BelgeBaslik(p: BelgeBaslikProps) {
  const {
    aktifSekme, setAktifSekme, alanHatalari, bilgi, sonuc, kilitli, baslikKilitli, belgeAdi,
    belgeNo, setBelgeNo, tarih, setTarih, tarihEnGec, tarihEnErken, vadeGun, setVadeGun,
    basvuruMu,
    cari, satici, depo, setDepo, girisDepo, setGirisDepo, sevkiyat, fisTipi,
    setFisTipi, satirlar, donusumler, setCariArama, setSaticiArama, setPersonelArama,
    kapanmaAlani, bagliSiparisAlani, alisMi, irsaliyeMi, faturaMi, siparisMi, konsinyeMi,
    tahakkukMu, depoBelgesi, stokFisiMi, fisCikisMi, transferMi, talepMi, disNumarali,
    eBelgeYok, teklif, provizyonVar,
    numaraElle,
  } = p;

  /** Teklif (216): katalog adi 'Teklif' - durum combosu ve sekme adi degisir. */
  const teklifMi = belgeAdi === 'Teklif';

  /**
   * Belge turunun adi - "İrsaliye No" / "Fatura No" / "Sipariş No". Depo
   * belgesi ve stok fisinde kartin kendi adi (Transfer, Talep, Giriş Fişi...)
   * kullanilir; `belgeAdi` zaten tur katalogundan geliyor.
   */
  // Katalog ozel bir ad verdiyse (Teklif) o kullanilir; 'Belge' generic'i
  //   fatura turlerinin adi olarak 'Fatura'ya cevrilir (216).
  // BASVURU (246): numara "Protokol No", tarih "Başvuru Tarihi" (kullanici) -
  //   siparis davranisini miras aliyor ama HBYS'de karsiligi protokoldur.
  //   Bayrak KARTTAN gelir (tur === 30); katalog adi degisse de kirilmaz.
  const belgeSozu = depoBelgesi || stokFisiMi ? belgeAdi
                  : basvuruMu ? 'Başvuru'
                  : irsaliyeMi ? 'İrsaliye' : siparisMi ? 'Sipariş'
                  : tahakkukMu ? 'Tahakkuk'
                  : belgeAdi !== 'Belge' ? belgeAdi : 'Fatura';
  /** Numara etiketi: basvuruda "Protokol No", digerlerinde "<tur> No". */
  const numaraSozu = basvuruMu ? 'Protokol' : belgeSozu;

  /** Tarih hucresi: basvuruda bolum/hekimden SONRA cizildigi icin degisken. */
  const tarihHucresi = (
    <label className="alan">
      {/* ZORUNLU (kullanici): belge/siparis tarihi bos kalamaz - kalem, prim ve
          numara serisi hep bu tarihe bagli. Alan temizlenirse SIMDIKI AN geri
          yazilir; kullanici gecmis bir tarih secmek isterse ustune yazar. */}
      <span className="etiket zorunlu-isaret">{belgeSozu} Tarihi</span>
      <input type="datetime-local" value={tarih} disabled={baslikKilitli}
             max={tarihEnGec} min={tarihEnErken}
             onChange={e => setTarih(e.target.value || yerelAnMetni(new Date()))} />
      {alanHatalari.belgeTarihi && <span className="alan-hata">{alanHatalari.belgeTarihi}</span>}
    </label>
  );

  /**
   * Kapanma ("bu belgeden ne kadari faturalandi") hangi turde ANLAMLI:
   * faturada ve tahakkukta zincirin sonundayiz, depo belgesi ve stok fisi ise
   * fatura zincirinde hic degil.
   */
  // Teklif fatura zincirinde degil (216) - "Faturalanmadı" rozeti yaniltirdi.
  const kapanmaGoster = !faturaMi && !tahakkukMu && !depoBelgesi && !stokFisiMi
                        && belgeAdi !== 'Teklif';

  return (
  <>
{/* BASVURUDA BASLIK SERIDI YOK (300, kullanici): kimlik hasta arama satiri
    ve hasta bandinda, tarih/bolum/hekim/odeyen kurum ise Basvuru sekmesinde.
    Basligi bosuna cizmek kart tepesinde iki kez ayni bilgiyi gosteriyordu. */}
{!basvuruMu && (
<div className="belge-hdr-sar">
  <div className="alan-izgara dort-sutun belge-hdr">
    {/* --- 1) KIMLIK --- */}
    {/* Transferde/talepte CARI YOK: mal firmanin kendi depolari arasinda
        gezer, cari hucresinin yerini cikis deposu alir. Stok fisinde ise
        fisin SEBEBI (tipi) ilk sorulan sey - muhasebe hesabini o belirleyecek
        (F7). Carili turlerde secim GenLookup degil TarafArama modali: "yeni
        belge" akisiyla ayni ekran olsun (iki farkli cari secme bicimi
        kullaniciyi sasirtiyordu). */}
    {stokFisiMi ? (
      <label className="alan">
        <span className="etiket zorunlu-isaret">Tipi</span>
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
        etiket={alisMi ? 'Tedarikçi (Cari)' : 'Müşteri (Cari)'}
        deger={cari?.unvan}
        kilitli={kilitli}
        zorunlu
        ipucu="Cari ara"
        hata={alanHatalari.tarafId}
        onAc={() => setCariArama(true)}
      />
    )}

    {/* --- 2) BELGE NO ---
        Alis faturasinda numara TEDARIKCININ: sayacimiz uretemez (harf
        icerebilir, bizim seriyle iliskisi yok), kullanici girer. Diger
        turlerde numarayi kayitta sunucu verir - alan salt-okunur.
        Teklifte hucre IKIYE BOLUNUR (220, kullanici): solda numara, sagda
        REVIZE NO - serbest kullanici editi, varsayilan bos. */}
    <label className="alan">
      <span className={`etiket${disNumarali && !kilitli ? ' zorunlu-isaret' : ''}`}>
        {disNumarali ? 'Tedarikçi Fatura No'
          : teklifMi ? `${belgeSozu} No / Revize No` : `${numaraSozu} No`}
      </span>
      {(disNumarali || numaraElle) && !kilitli ? (
        <input className="one-cikan" value={belgeNo} maxLength={20}
               placeholder={disNumarali ? 'örn. ABC2026000001234'
                                        : '(boş bırakılırsa sistem verir)'}
               onChange={e => setBelgeNo(e.target.value)} />
      ) : teklifMi ? (
        <span className="ikili">
          <input className="one-cikan"
                 value={String(sonuc?.belge.belgeNo ?? '') || (kilitli ? '' : '(kaydedince verilir)')}
                 readOnly />
          {/* Revize, NUMARASI OLAN teklife yazilir (kullanici): numara yokken
              revize kavrami yok - kaydedilince edit acilir. */}
          <input value={teklif.revizeNo} maxLength={20} placeholder="Revize"
                 style={{ flex: '0 0 76px' }}
                 disabled={kilitli || !String(sonuc?.belge.belgeNo ?? '')}
                 onChange={e => teklif.setRevizeNo(e.target.value)} />
        </span>
      ) : (
        <input className="one-cikan"
               value={String(sonuc?.belge.belgeNo ?? '') || (kilitli ? '' : '(kaydedince verilir)')}
               readOnly />
      )}
      {alanHatalari.belgeNo && <span className="alan-hata">{alanHatalari.belgeNo}</span>}
    </label>

    {/* --- 3) TARIH --- */}
    {tarihHucresi}

    {/* --- 3b) TEKLIF DURUMU (218) - tarih sagina (kullanici). */}
    {teklifMi && (
      <label className="alan">
        <span className="etiket">Durumu</span>
        <select value={teklif.durum} disabled={kilitli}
                onChange={e => teklif.setDurum(e.target.value)}>
          {Object.entries(TEKLIF_DURUMLARI).map(([k, v]) =>
            <option key={k} value={k}>{v}</option>)}
        </select>
      </label>
    )}

    {/* --- 4) e-BELGE ---
        Kavrami OLMAYAN turlerde (siparis, tahakkuk, depo belgesi, stok fisi)
        hucre cizilmez. Adres ve seri de basliktan cikti: e-Belge sekmesinde,
        XML'e giden alanlarla birlikte duruyorlar. Vergi Dairesi/VKN kartta
        gosterilmiyor - cari kartindan gelip belgeye DONDURULAN bilgi. */}
    {!eBelgeYok ? (
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
    ) : depoBelgesi || stokFisiMi || teklifMi || basvuruMu ? null : kapanmaGoster ? kapanmaAlani : (
      /* e-Belgesi de kapanmasi da olmayan tur (tahakkuk): hucre BOS BIRAKILIR.
         Yoksa temsilci yukari, 1. satirin sonuna kayardi - kullanici temsilciyi
         her turde CARININ ALTINDA istiyor. Teklifte yer tutucuya gerek yok:
         4. hucreyi zaten Durumu combosu dolduruyor - fazladan bos hucre
         2. sirayi bir saga kaydiriyordu (kullanici). */
      <span className="alan" aria-hidden />
    )}

    {/* --- 5) KISI-1 ---
        Transferde sorumluluk devri: Teslim Eden (zorunlu). Talepte bu hucre
        yok - talebi acan kisi 7. hucrede "Talep Eden" olarak sorulur.
        Satis temsilcisi PERSONEL'dir (cari degil) ve secim cari ile ayni
        TarafArama ekranindan yapilir - tek arama bicimi. */}
    {transferMi ? (
      <TarafAlani
        etiket="Teslim Eden"
        zorunlu
        deger={sevkiyat.teslimEden?.ad}
        kilitli={baslikKilitli}
        ipucu="Personel ara"
        onAc={() => setPersonelArama('eden')}
        hata={alanHatalari.teslimEdenId}
      />
    ) : talepMi ? null : (
      <TarafAlani
        etiket={stokFisiMi || alisMi ? 'Sorumlu' : 'Satış Temsilcisi'}
        deger={satici?.ad}
        kilitli={stokFisiMi ? baslikKilitli : kilitli}
        ipucu="Personel ara"
        onAc={() => setSaticiArama(true)}
      />
    )}

    {/* --- 6) DEPO-2 ---
        Depo belgesinde malin GITTIGI depo, stok fisinde fisin tek deposu,
        carili belgelerde mal cikis/giris deposu. Tahakkukta depo YOK: stok
        etkilemez (kasa_islem_turu.stok_etkiler=0). */}
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
    ) : teklifMi ? (
      /* Teklifte depo YOK (stok cikisi yapmaz, 222) - yerine 2. sira uclusu:
         Teklif Konusu (yazilabilir combo) | Teslim Sekli (salt combo).
         Ikisi de kod listesinden; ETIKETE tiklaninca jenerik modalda
         duzenlenir (AyarAlani listeKod deseni). Gecerlilik Suresi = vade. */
      <>
        <KodListeAlani etiket="Teklif Konusu" listeKod="belge.teklif_konusu"
                       deger={teklif.konu} onDeger={teklif.setKonu}
                       kilitli={kilitli} yazilabilir />
        <KodListeAlani etiket="Teslim Şekli" listeKod="belge.teslim_sekli"
                       deger={teklif.teslim} onDeger={teklif.setTeslim}
                       kilitli={kilitli} />
      </>
    ) : !tahakkukMu ? (
      <GenLookup
        kaynak="depo"
        etiket={siparisMi ? 'Depo' : alisMi ? 'Giriş Deposu' : 'Çıkış Deposu'}
        // Pasif depo secilemez: kapatilmis depoya belge kesilmesin.
        sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
        alanlar={LOOKUP_DEPO}
        deger={depo?.ad}
        saltOkunur={kilitli}
        onSec={x => setDepo(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)}
      />
    ) : null}

    {/* --- 7) KISI-2 (yalniz depo belgeleri) --- */}
    {depoBelgesi && (
      <TarafAlani
        etiket={talepMi ? 'Talep Eden' : 'Teslim Alan'}
        zorunlu
        deger={sevkiyat.teslimAlan?.ad}
        kilitli={baslikKilitli}
        ipucu="Personel ara"
        onAc={() => setPersonelArama('alan')}
        hata={alanHatalari.teslimAlanId}
      />
    )}

    {/* --- 8) FATURA TIPI (130) BASLIKTAN CIKTI (kullanici): arac cubugunda,
        dugmelerin saginda duruyor - irsaliyedeki IADE kutusuyla ayni yerde. */}

    {/* --- 9) VADE / ODEYEN KURUM ---
        Faturada / tahakkukta vade anlamli (irsaliyede mal cikis tarihi esas).
        BASVURUDA (249) vade YOK, yerine ODEYEN KURUM: hizmeti kim odeyecek
        (kullanici: "basvuruda vade yerine Ödeyen Kurum olsun ve taraf_kurum
        listelensin"). Bos birakilirsa hasta kendi oder. */}
    {bilgi.vade && (
      <label className="alan">
        <span className="etiket">{teklifMi ? 'Geçerlilik Süresi (gün)' : 'Vade (gün)'}</span>
        <input className="hiza-sag" value={vadeGun} disabled={kilitli}
               onChange={e => setVadeGun(e.target.value)} />
      </label>
    )}

    {/* Fiyat Listesi combosu ASAGIDA, Rapor Dovizi cercevesinin saginda
        (kullanici, 218) - KalemSekmesi cizer. */}

    {/* --- 10-11) ZINCIR HUCRELERI ---
        Bagli Siparis, Faturalama Durumu'nun SOLUNDA (kullanici).
        Kapanma burada YALNIZ e-Belgeli turlerde: e-Belgesizde 4. hucreyi zaten
        o dolduruyor (temsilci carinin altina insin diye).
        Teklifte "Bağlı Sipariş" cizilmez (kullanici) - teklif zincirin BASI. */}
    {!depoBelgesi && !stokFisiMi && !teklifMi && bagliSiparisAlani}
    {!eBelgeYok && kapanmaGoster && kapanmaAlani}
  </div>
</div>
)}

{/* Sekmeler BASLIK ALANLARININ ALTINDA, grid'in hemen ustunde -
    mockup duzeni (toolbar > hdr > tabs > pane). Tasiyici ve Imza/Teslim
    yalniz irsaliyede anlamli, o yuzden suzuluyor. */}
<div className="katab">
  {SEKMELER
    // Basvuruya ozel sekmeler (298) yalniz basvuruda; diger turlerde cizilmez.
    .filter(x => (!x.basvuru || basvuruMu)
              && (!x.irsaliye || irsaliyeMi)
              && (!x.faturaYok || !(faturaMi || tahakkukMu))
              // Tahsilat: fatura/fis, tahakkuk VE SIPARIS (kullanici) - siparis
              //   avansi/on odemesi de bu sekmeden girilir, fatura kartindaki
              //   Nakit / Banka / POS / Çek / Senet dugmeleriyle ayni.
              && (!x.faturaMi || faturaMi || tahakkukMu || siparisMi)
              // Tahakkuk e-Belge DEGIL: GIB'e giden bir belge degil,
              //   ic muhasebe/cari ara kaydi.
              && !(eBelgeYok && x.anahtar === 'ebelge')
              // Transferde cari/fatura zinciri yok: yalniz Kalemler + Yorum.
              // "Faturalama" = bu belgeden turetilenler. Fatura zincirin
              //   sonu (faturaYok), depo belgesi ve stok fisi ise hic
              //   donusmez. Irsaliyede GORUNUR - kalem bicimine bakmak
              //   yanlisti, irsaliyeyi de gizliyordu.
              && !((bilgi.depoBelgesi || bilgi.stokFisi) && x.anahtar === 'fatura')
              // Teklifte Siparis sekmesi yalniz KABUL (3) durumunda (kullanici).
              && !(teklifMi && x.anahtar === 'fatura' && teklif.durum !== '3')
              // PROVIZYON yalniz ÖSS/SGK odeyen kurumda (kullanici): ozel
              //   kurumda ya da hasta kendi oderken alinacak provizyon yok,
              //   sekme bos duruyordu.
              && !(x.anahtar === 'provizyon' && !provizyonVar))
    .map(x => (
    <div key={x.anahtar}
         className={`kat${x.anahtar === aktifSekme ? ' on' : ''}`}
         onClick={() => setAktifSekme(x.anahtar)}>
      {/* BASVURUDA kalem sekmesi "Ücretlendirme" (kullanici): hastaya yazilan
          islem/tetkik ucretleri - "kalem" ERP sozu, kayit kabulde karsiligi yok. */}
      {x.anahtar === 'tahsilat' && alisMi ? 'Ödeme'
        : x.anahtar === 'fatura' && teklifMi ? 'Sipariş'
        : x.anahtar === 'kalem' && basvuruMu ? 'Ücretlendirme' : x.baslik}
      {x.anahtar === 'kalem' && <span className="b">{satirlar.length}</span>}
      {x.anahtar === 'fatura' && donusumler.length > 0 && (
        <span className="b">{donusumler.length}</span>
      )}
    </div>
  ))}
</div>
  </>
  );
}

export interface BelgeBaslikProps {
  aktifSekme: string;
  setAktifSekme(v: string): void;
  alanHatalari: Record<string, string>;
  bilgi: BelgeTuruBilgisi;
  sonuc: BelgeYaniti | null;
  kilitli: boolean;
  /** Kalem girildikten sonra baslikta kilitlenen alanlar (depo, tip, tarih). */
  baslikKilitli: boolean;
  belgeAdi: string;
  belgeNo: string;
  setBelgeNo(v: string): void;
  tarih: string;
  setTarih(v: string): void;
  tarihEnGec: string;
  tarihEnErken?: string;
  /**
   * Provizyon sekmesi cizilsin mi (kullanici): yalniz odeyen kurumun turu
   * ÖSS (2) ya da SGK (3) iken. Özel kurumda / hasta kendi oderken alinacak
   * provizyon yoktur.
   */
  provizyonVar?: boolean;
  /**
   * Numarayi KULLANICI yazar (358, numara_sablonu.elle_girilir): numara alani
   * duzenlenebilir gelir. Bos birakilirsa sunucu yine uretir - belge numarasiz
   * kalmaz.
   */
  numaraElle?: boolean;
  /** Teklif basligi DEMET halinde (218/220/222): durum, revize no, konu,
      teslim sekli - sekiz ayri prop yerine tek nesne. */
  teklif: TeklifBilgisi;
  vadeGun: string;
  setVadeGun(v: string): void;
  /** Basvuru (249): vade yerine odeyen kurum combosu cizilir. */
  /**
   * Basvuru mu (246): baslik seridi HIC cizilmez - kimlik hasta bandinda,
   * tarih/bolum/hekim/odeyen kurum Basvuru sekmesinde (300). Bayrak yalniz
   * sekme suzgeci ve sekme adlari icin duruyor ("Kalemler" -> "Ücretlendirme").
   */
  basvuruMu?: boolean;
  cari: { id: number; unvan: string } | null;
  satici: Secim | null;
  depo: Secim | null;
  setDepo(v: Secim | null): void;
  girisDepo: Secim | null;
  setGirisDepo(v: Secim | null): void;
  /** Sevkiyat alanlari demeti - baslikta yalniz teslim eden/alan okunur. */
  sevkiyat: SevkiyatBilgisi;
  fisTipi: number;
  setFisTipi(v: number): void;
  /** Fatura tipi (130) - yalniz faturada gorunur. */
  faturaTipi: number;
  setFaturaTipi(v: number): void;
  satirlar: SatirDurumu[];
  donusumler: Record<string, unknown>[];
  /** Secim modallarini acan tetikleyiciler (kartta yasiyor). */
  setCariArama(v: boolean): void;
  setSaticiArama(v: boolean): void;
  setPersonelArama(v: 'eden' | 'alan' | null): void;
  /** Sag sutunda ture gore degisen hazir hucreler. */
  kapanmaAlani: React.ReactNode;
  bagliSiparisAlani: React.ReactNode;
  // belgeTuru.ts davranis bayraklari
  alisMi: boolean;
  irsaliyeMi: boolean;
  faturaMi: boolean;
  siparisMi: boolean;
  konsinyeMi: boolean;
  tahakkukMu: boolean;
  depoBelgesi: boolean;
  stokFisiMi: boolean;
  fisCikisMi: boolean;
  transferMi: boolean;
  talepMi: boolean;
  disNumarali: boolean;
  eBelgeYok: boolean;
}

/**
 * KOD LISTELI KART ALANI (222): degeri kod listesinden onerilen combo.
 * `yazilabilir` ise input+datalist (kullanici listede olmayani da yazar),
 * degilse salt select. Etiket TIKLANINCA jenerik KodListesiModali acilir -
 * liste icerigi (Teklif Konusu, Teslim Sekli...) oradan yonetilir; modal
 * kapaninca oneriler tazelenir (AyarAlani listeKod deseniyle ayni).
 */
function KodListeAlani({ etiket, listeKod, deger, onDeger, kilitli, yazilabilir }: {
  etiket: string;
  listeKod: string;
  deger: string;
  onDeger(v: string): void;
  kilitli: boolean;
  yazilabilir?: boolean;
}) {
  const [secenekler, setSecenekler] = useState<string[]>([]);
  const [modal, setModal] = useState(false);
  const [surum, setSurum] = useState(0);
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe(listeKod);
        if (!iptal)
          setSecenekler(y.degerler.filter(d => d.aktif === 1).map(d => d.ad));
      } catch { /* liste yoksa oneriler bos kalir */ }
    })();
    return () => { iptal = true };
  }, [listeKod, surum]);
  return (
    <label className="alan">
      <span className="etiket" role="button" tabIndex={0}
            title="Liste içeriğini düzenle" style={{ cursor: 'pointer' }}
            onClick={e => { e.preventDefault(); setModal(true) }}>
        {etiket} ✎
      </span>
      {yazilabilir ? (
        /* HEM EDIT HEM COMBO (kullanici): solda serbest metin, sagda dar
           liste - secim editi doldurur, kullanici uzerine yazabilir. */
        <span className="ikili">
          <input value={deger} maxLength={100} disabled={kilitli}
                 onChange={e => onDeger(e.target.value)} />
          <select value="" disabled={kilitli} aria-label={`${etiket} listesi`}
                  onChange={e => { if (e.target.value) onDeger(e.target.value) }}>
            <option value="" />
            {secenekler.map(a => <option key={a} value={a}>{a}</option>)}
          </select>
        </span>
      ) : (
        <select value={deger} disabled={kilitli}
                onChange={e => onDeger(e.target.value)}>
          <option value="">Seçiniz…</option>
          {/* Kayitli deger listeden silinmisse yine gorunsun. */}
          {deger && !secenekler.includes(deger) && <option value={deger}>{deger}</option>}
          {secenekler.map(a => <option key={a} value={a}>{a}</option>)}
        </select>
      )}
      {modal && (
        <KodListesiModali kod={listeKod} baslik={etiket}
                          onKapat={() => { setModal(false); setSurum(x => x + 1) }} />
      )}
    </label>
  );
}
