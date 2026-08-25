import { GenLookup } from '../GenLookup';
import { TarafAlani } from '../../sayfalar/BelgeKarti';
import {
  LOOKUP_DEPO, GIRIS_FIS_TIPLERI, CIKIS_FIS_TIPLERI, FATURA_TIPLERI,
  SEKMELER,
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
    cari, satici, depo, setDepo, girisDepo, setGirisDepo, teslimEden, teslimAlan, fisTipi,
    faturaTipi, setFaturaTipi,
    setFisTipi, satirlar, donusumler, setCariArama, setSaticiArama, setPersonelArama,
    kapanmaAlani, bagliSiparisAlani, alisMi, irsaliyeMi, faturaMi, siparisMi, konsinyeMi,
    tahakkukMu, depoBelgesi, stokFisiMi, fisCikisMi, transferMi, talepMi, disNumarali,
    eBelgeYok,
  } = p;

  /**
   * Belge turunun adi - "İrsaliye No" / "Fatura No" / "Sipariş No". Depo
   * belgesi ve stok fisinde kartin kendi adi (Transfer, Talep, Giriş Fişi...)
   * kullanilir; `belgeAdi` zaten tur katalogundan geliyor.
   */
  const belgeSozu = depoBelgesi || stokFisiMi ? belgeAdi
                  : irsaliyeMi ? 'İrsaliye' : siparisMi ? 'Sipariş'
                  : tahakkukMu ? 'Tahakkuk' : 'Fatura';

  return (
  <>
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
        turlerde numarayi kayitta sunucu verir - alan salt-okunur. */}
    <label className="alan">
      <span className={`etiket${disNumarali && !kilitli ? ' zorunlu-isaret' : ''}`}>
        {disNumarali ? 'Tedarikçi Fatura No' : `${belgeSozu} No`}
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

    {/* --- 3) TARIH --- */}
    <label className="alan">
      <span className="etiket">{belgeSozu} Tarihi</span>
      <input type="datetime-local" value={tarih} disabled={baslikKilitli}
             max={tarihEnGec} min={tarihEnErken}
             onChange={e => setTarih(e.target.value)} />
      {alanHatalari.belgeTarihi && <span className="alan-hata">{alanHatalari.belgeTarihi}</span>}
    </label>

    {/* --- 4) e-BELGE ---
        Kavrami OLMAYAN turlerde (siparis, tahakkuk, depo belgesi, stok fisi)
        hucre cizilmez. Adres ve seri de basliktan cikti: e-Belge sekmesinde,
        XML'e giden alanlarla birlikte duruyorlar. Vergi Dairesi/VKN kartta
        gosterilmiyor - cari kartindan gelip belgeye DONDURULAN bilgi. */}
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

    {/* --- 5) KISI-1 ---
        Transferde sorumluluk devri: Teslim Eden (zorunlu). Talepte bu hucre
        yok - talebi acan kisi 7. hucrede "Talep Eden" olarak sorulur.
        Satis temsilcisi PERSONEL'dir (cari degil) ve secim cari ile ayni
        TarafArama ekranindan yapilir - tek arama bicimi. */}
    {transferMi ? (
      <TarafAlani
        etiket="Teslim Eden"
        zorunlu
        deger={teslimEden?.ad}
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
        deger={teslimAlan?.ad}
        kilitli={baslikKilitli}
        ipucu="Personel ara"
        onAc={() => setPersonelArama('alan')}
        hata={alanHatalari.teslimAlanId}
      />
    )}

    {/* --- 8) FATURA TIPI (130) ---
        Yalniz faturada: faturanin cinsi hem muhasebe fisini hem e-Belge
        senaryosunu etkiler, belge.tipi alaninda tutulur (iade zaten 2 idi).
        Irsaliyede tek anlamli secim "iade mi" - o da arac cubugundaki IADE
        kutusu (kullanici); siparis/tahakkukta tip kavrami yok. */}
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

    {/* --- 9) VADE ---
        Faturada / tahakkukta anlamli (irsaliyede mal cikis tarihi esas). */}
    {bilgi.vade && (
      <label className="alan">
        <span className="etiket">Vade (gün)</span>
        <input className="hiza-sag" value={vadeGun} disabled={kilitli}
               onChange={e => setVadeGun(e.target.value)} />
      </label>
    )}

    {/* --- 10-11) ZINCIR HUCRELERI ---
        Bagli Siparis, Faturalama Durumu'nun SOLUNDA (kullanici).
        Kapanma = "bu belgeden ne kadari faturalandi": faturada ve tahakkukta
        anlamsiz (zincirin sonu, Faturalama sekmesi de bu turlerde gizli).
        Depo belgesi ve stok fisi fatura zincirinde degil - ikisi de yok. */}
    {!depoBelgesi && !stokFisiMi && bagliSiparisAlani}
    {!depoBelgesi && !stokFisiMi && !faturaMi && !tahakkukMu && kapanmaAlani}
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
