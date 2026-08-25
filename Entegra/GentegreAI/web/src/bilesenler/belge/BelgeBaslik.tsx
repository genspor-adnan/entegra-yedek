import { GenLookup } from '../GenLookup';
import { TarafAlani } from '../../sayfalar/BelgeKarti';
import {
  LOOKUP_DEPO, GIRIS_FIS_TIPLERI, CIKIS_FIS_TIPLERI, FATURA_TIPLERI, SEKMELER,
} from '../../sayfalar/belgeSabitleri';
import type { SatirDurumu } from '../../sayfalar/belgeSatir';
import type { Secim } from '../../sayfalar/belgeKaydet';
import type { BelgeYaniti } from '../../api/sozlesme';
import type { BelgeTuruBilgisi } from '../../sayfalar/belgeTuru';

/**
 * BELGE KARTI BASLIGI - mockup'taki .hdr izgarasi: cari/tip, belge no, e-Belge,
 * tarih, depo(lar), vade, doviz ve tur ozel alanlar (fis tipi, teslim eden/alan,
 * bagli siparis, kapanma durumu).
 *
 * Alan SIRASI ve hangi turde hangi hucrenin gorunecegi burada; kartin veri
 * akisiyla ilgisi yok. 250 satirlik bu izgara kart govdesinde dururken
 * kaydetme/yukleme mantigini okumak zorlasiyordu.
 */
export function BelgeBaslik(p: BelgeBaslikProps) {
  const {
    aktifSekme, setAktifSekme, alanHatalari, bilgi, sonuc, kilitli, baslikKilitli, belgeAdi,
    belgeNo, setBelgeNo, tarih, setTarih, tarihEnGec, tarihEnErken, vadeGun, setVadeGun,
    cari, satici, depo, setDepo, girisDepo, setGirisDepo, teslimEden, teslimAlan, fisTipi,
    faturaTipi, setFaturaTipi,
    setFisTipi, satirlar, donusumler, setCariArama, setSaticiArama, setPersonelArama,
    kapanmaAlani, bagliSiparisAlani, alisMi, irsaliyeMi, faturaMi, siparisMi, konsinyeMi,
    tahakkukMu, depoBelgesi, stokFisiMi, fisCikisMi, transferMi, talepMi, disNumarali,
    eBelgeYok,
  } = p;
  return (
  <>
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

    {/* FATURA TIPI (130) - yalniz faturada, ust baslikta (kullanici). Faturanin
        cinsi hem muhasebe fisini hem e-Belge senaryosunu etkiler; belge.tipi
        alaninda tutulur (iade zaten 2 idi). */}
    {faturaMi && (
      <label className="alan">
        <span className="etiket">Fatura Tipi</span>
        <select value={faturaTipi} disabled={kilitli}
                onChange={e => setFaturaTipi(Number(e.target.value))}>
          {FATURA_TIPLERI.map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
          {/* Gocten gelen tanimsiz tip (or. 17) listede yok: secenek olarak
              EKLENIR, yoksa kart acilinca ilk tipe duser ve kaydedince
              belgenin gercek tipi sessizce degisirdi. */}
          {!FATURA_TIPLERI.some(t => t.deger === faturaTipi) && (
            <option value={faturaTipi}>Tanımsız ({faturaTipi})</option>
          )}
        </select>
      </label>
    )}

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
  vadeGun: string;
  setVadeGun(v: string): void;
  cari: { id: number; unvan: string } | null;
  satici: Secim | null;
  depo: Secim | null;
  setDepo(v: Secim | null): void;
  girisDepo: Secim | null;
  setGirisDepo(v: Secim | null): void;
  teslimEden: Secim | null;
  teslimAlan: Secim | null;
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
