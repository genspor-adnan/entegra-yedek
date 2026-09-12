import { TarafSecici } from '../TarafArama';
import { KodSecim, KodSegment, MetinAlani } from './basvuru/alanlar';
import { dagilimRotasi } from '../../sayfalar/belgeKartiKurallari';

/**
 * BASVURU / PROVIZYON / ONCEKI BASVURULAR sekmeleri (298).
 *
 * Mockup: Ekranlar/kayit_kabul_basvuru.html. Kayit kabulun doldurdugu
 * bilgiler basligin degil BU sekmenin isi: baslik yalnizca "kim, hangi
 * bolum, hangi hekim, kim odeyecek" dortlusunu tutar (dar ve her turde
 * ayni), gerisi burada.
 *
 * MEDULA ENTEGRASYONU YOK: provizyon alanlari ELLE girilir. Sorgu servisine
 * baglanildiginda ayni alanlar otomatik dolacak - ekran degismeyecek.
 */

/**
 * belge_basvuru (298) alanlarinin ekran karsiligi - hepsi tek nesnede.
 * Index imzasi kayit hatti icin: govde ureticisi alanlari tek tek saymadan
 * (Object.entries ile) gecirir, yeni alan eklerken tek dosya degisir.
 */
export interface BasvuruBilgi {
  [alan: string]: string | number | null | undefined;
  /**
   * USS SYS TAKIP NO (608) - SALT OKUNUR. 101 gonderiminde doner, basvurunun
   * e-Nabiz kimligidir; hasta seridinde ad altinda gosterilir.
   */
  sysTakipNo?: string;
  basvuruTuru?: number | null;
  gelisSekli?: number | null;
  gelisNedeni?: number | null;
  oda?: number | null;
  siraNo?: string;
  refakatci?: string;
  // Ambulans (300) - odeyiciden bagimsiz, hastaya ait kimlik bilgisi.
  ambulansHastaNo?: string;
  ambulansBileklikNo?: string;
  /**
   * KENDI ISTEGIYLE GELDI (370): gonderen hekim YOK ama bu bir eksiklik degil,
   * bir SECIM. Gonderen zorunlulugu "hekim secili VEYA bu isaret" ile
   * karsilanir - yoksa "henuz secilmedi" ile "gonderen yok" ayirt edilemezdi.
   */
  kendiIstegi?: number | null;
  /**
   * SOZLESME / ALT KURUM / SGK KATKISI (469). Odeme rotasini bunlar belirler:
   * tek sozlesme varsa sunucu kendisi atar, birden fazlaysa SECILMELIDIR;
   * OSS'de police turu sozlesmeden gelir, SGK'da devredilen kurum secilir.
   */
  sozlesmeId?: number | null;
  altKurum?: number | null;
  sgkKullan?: number | null;
  /**
   * EMEKLI (590, kullanici: "sgk katılım sadece sut muayene eklenirse eklenir;
   * eğer hasta emekliyse eklenmez. Başvuruya Emekli check'i gelmeli").
   *
   * Emeklinin muayene katilim payi MAASINDAN kesilir; kurumda ikinci kez
   * tahsil edilmez. Basvurunun kendi bilgisidir - ayni hasta bir basvuruda
   * emekli, oncekinde calisan olabilir ve belge o gunun durumunu tasimali.
   */
  emekli?: number | null;
  // PROVIZYON (299) - belge_provizyon 1:1. SGK ve ozel sigorta AYNI ANDA
  // olabilir (SGK ana odeyici, tamamlayici police farki ustlenir), o yuzden
  // her odeyicinin kendi durumu/numarasi/orani var.
  sgkDurum?: number | null;
  sgkProvizyonNo?: string;
  sgkProvizyonTipi?: number | null;
  sgkProvizyonTarihi?: string | null;
  sgkGecerlilik?: string | null;
  sgkKarsilama?: number | string | null;
  sgkTutar?: number | string | null;
  sgkRedNedeni?: string;
  sgkSigortaTuru?: string;
  // SGK'da iki numara var: basvuru (muracaat) ve takip. Faturalama TAKIP
  // numarasi uzerinden yapilir - ikisi karistirilmamali (300).
  sgkBasvuruNo?: string;
  sgkTakipNo?: string;
  sgkTakipTarihi?: string | null;
  sgkTakipTuru?: number | null;
  sgkTesisKodu?: string;
  sgkMustehaklik?: number | null;
  sgkMustehaklikZaman?: string | null;  // salt okunur
  sgkSevkli?: number | null;
  sgkSevkKurum?: string;
  ossKurumId?: number | null;
  ossKurumAdi?: string;                 // salt okunur (join)
  ossDurum?: number | null;
  ossProvizyonNo?: string;
  ossProvizyonTarihi?: string | null;
  ossGecerlilik?: string | null;
  ossKarsilama?: number | string | null;
  ossTutar?: number | string | null;
  ossRedNedeni?: string;
  ossPoliceNo?: string;
  ossHasarNo?: string;
  ossBrans?: string;
  provizyonAciklama?: string;
}

export function BasvuruSekmesi({ bilgi, degistir, kilitli, randevuBilgi,
                                 tarih, setTarih, tarihEnGec, tarihEnErken, tarihHatasi,
                                 bolumler, bolumId, setBolumId,
                                 gorevliler, personelId, setPersonelId,
                                 kurumlar, kurumTuru, odeyenKurumId, setOdeyenKurumId,
                                 sozlesmeler, altKurumlar,
                                 aciklama, setAciklama, gonderenModu,
                                 personelAd, onPersonelSec, kurumHatasi,
                                 bolumHatasi, personelHatasi,
                                 kendiIstegi, onKendiIstegi }: {
  bilgi: BasvuruBilgi;
  /**
   * LAB / GORUNTULEME KURUMU (364, kullanici): bu kurumlarda basvuru zaten
   * "Laboratuvar / Görüntüleme"dir - tur sorulmaz, poliklinik odasi yoktur ve
   * hekim alani hastayi GONDEREN dis doktordur. Bayrak kurum profilinden gelir
   * (fn_basvuru_hekim_rolu = 1 -> Gönderen).
   */
  gonderenModu?: boolean;
  /** Odeyen kurum secilmediyse kaydetmede donen hata (zorunlu alan). */
  kurumHatasi?: string;
  /** Bolum ve hekim de ZORUNLU (kullanici) - hata alanin altinda yazar. */
  bolumHatasi?: string;
  personelHatasi?: string;
  /** "Kendi İsteği" isareti (370) - gonderen zorunlulugunu bu da karsilar. */
  kendiIstegi?: boolean;
  onKendiIstegi?(v: boolean): void;
  /** Secili hekim/gonderen adi - arama ekranindan gelen kisi listede olmayabilir. */
  personelAd?: string;
  /**
   * Arama ekranindan hekim/gonderen secildi. Bolumu de KART cozer (secilen
   * kisinin bolumu varsa Bölüm alani doldurulur) - burada tek is secimi
   * yukari bildirmek.
   */
  onPersonelSec?(id: number, ad: string): void;
  degistir(y: Partial<BasvuruBilgi>): void;
  kilitli: boolean;
  /** Belgeye bagli randevu varsa ozeti (tarih · kaynak) - salt okunur. */
  randevuBilgi?: string;
  /**
   * BASLIKTAN BURAYA TASINAN alanlar (300, kullanici): basvurunun basligi
   * artik yalniz hasta arama satiri + hasta bandi; tarih, bolum, hekim ve
   * odeyen kurum bu sekmede - hepsi kayit kabulun doldurdugu bilgiler.
   */
  tarih: string;
  setTarih(v: string): void;
  tarihEnGec?: string;
  tarihEnErken?: string;
  tarihHatasi?: string;
  /**
   * Bolum ve basvuruyu KARSILAYAN PERSONEL - hekim olmak zorunda degil. Iki
   * alan BIRBIRINI doldurur (kullanici): bolum secilince liste o bolumle
   * sinirlanir, personel secilince bolum ONUN bolumune gecer; bolum bosken
   * TUM randevu verilebilir personel listelenir.
   */
  bolumler?: { id: number; ad: string }[];
  bolumId?: number | null;
  setBolumId?(v: number | null): void;
  gorevliler?: { id: number; ad: string; bolumId?: number | null }[];
  personelId?: number | null;
  setPersonelId?(v: number | null): void;
  /** Anlasmali kurumlar - bos ise hasta kendi oder. */
  kurumlar?: { id: number; ad: string }[];
  /**
   * ODEYEN KURUMUN TURU (591): 1 Özel · 2 Sigorta · 3 SGK. Emekli kutusunun
   * gorunurlugu buna bagli - alt kurum tek basina yetmiyor (SGK'da alt kurum
   * DEVREDILEN KURUM'dur, police turu degildir).
   */
  kurumTuru?: number | null;
  odeyenKurumId?: number | null;
  setOdeyenKurumId?(v: number | null): void;
  /**
   * Odeyen kurumun YURURLUKTEKI sozlesmeleri (468). Bir tane varsa secici
   * pasif gelir (deger zaten belli), birden fazlaysa SECIM ZORUNLU - sunucu
   * hangi policenin gecerli oldugunu tahmin edemez.
   */
  sozlesmeler?: {
    id: number; ad: string; altKurum: number; altKurumAdi: string;
    rota: number; tur: number;
  }[];
  /** SGK'da devredilen kurum secenekleri (SSK / Bag-Kur / ES / Yesil Kart). */
  altKurumlar?: { id: number; ad: string }[];
  /** Basvuru notu - belgenin aciklama alani (mockup "Başvuru Notu"). */
  aciklama?: string;
  setAciklama?(v: string): void;
}) {
  /**
   * SGK ODEYEN MI (591) - emekli kutusunun kapisi. Sunucudaki
   * `fn_dagilim_rota` ile AYNI mantik: SGK kurumu (tür 3) her zaman, sigortada
   * yalniz TSS (202) ve SGK katkisi ACIK karma (203). Saf ÖSS'de ve özel
   * hastada SGK katilim payi kavrami yoktur.
   */
  const sgkOdeyen = [3, 4, 5].includes(
    dagilimRotasi(kurumTuru, bilgi.altKurum, bilgi.sgkKullan));

  return (
    <div className="kagrup">
      <h6>Başvuru Bilgileri</h6>
      {/* PROTOKOL NO BURADA YOK (kullanici): kartin BASLIK seridinde zaten
          "Protokol No" hucresi var - ayni salt okunur numarayi iki yerde
          gostermek sekmede bos yer harciyordu. */}
      <div className="alan-izgara uc-sutun">
        {/* ILK SATIR (kullanici): Bölüm · Gönderen · Ödeyen Kurum · Başvuru
            Tarihi. Kayit kabul memurunun sirasiyla sordugu dort alan; tur,
            gelis sekli ve oda arkaya duser. */}
        <label className="alan">
          {/* Lab/goruntulemede "Başvurulan Bölüm" degil sadece "Bölüm"
              (kullanici): hasta bir poliklinige basvurmuyor, tetkik yaptiriyor. */}
          {/* KENDI ISTEGIYLE gelen hastada bolum ZORUNLU DEGIL ve
              ISARETLENMEZ (kullanici): bolum "hangi bolume gonderildi"
              demektir - gonderen yoksa dayanagi da yok. Alan kilitlenir ve
              bos kalir, zorunluluk yildizi da duser. */}
          <span className={'etiket' + (kendiIstegi ? '' : ' zorunlu-isaret')}>
            {gonderenModu ? 'Bölüm' : 'Başvurulan Bölüm'}</span>
          <select value={bolumId ?? ''} disabled={kilitli || kendiIstegi}
                  onChange={e => {
                    const y = e.target.value ? Number(e.target.value) : null;
                    setBolumId?.(y);
                    // Secili personel YENI BOLUME AIT DEGILSE birakilir; ait
                    //   ise korunur (personelden bolume dogru doldurmada secim
                    //   kendini iptal etmesin).
                    const g = (gorevliler ?? []).find(x => x.id === personelId);
                    if (y && g && (g.bolumId ?? null) !== y) setPersonelId?.(null);
                  }}>
            <option value="">{kendiIstegi ? '— Gerekmiyor —' : '— Seçiniz —'}</option>
            {(bolumler ?? []).map(b => (
              <option key={b.id} value={b.id}>{b.ad}</option>
            ))}
          </select>
          {bolumHatasi && <span className="alan-hata">{bolumHatasi}</span>}
        </label>
        {/* GONDEREN: JENERIK ARAMA EKRANI (kullanici) - dis hekim sayisi
            combo'ya sigmaz; arama penceresinde brans, kurum ve gonderdigi
            tetkik sayisi da gorunur (305 dis hekim duzeni). Secilince Bölüm de
            kisinin bolumunden doldurulur. */}
        {gonderenModu ? (
          <div className="alan gonderen-alani">
          <TarafSecici etiket="Gönderen" kaynaklar={['dis-hekim']}
                       deger={personelAd}
                       kilitli={kilitli || kendiIstegi}
                       zorunlu hata={personelHatasi}
                       /* ONCE BOLUM SECILDIYSE (kullanici): arama O BOLUME
                          gonderen hekimlerle sinirlanir; bolum bosken hepsi
                          gelir. Hekim once secilirse bolum ondan dolar - iki
                          yon de calisir. */
                       ekFiltre={bolumId
                         ? { alan: 'departman', op: 'esit', deger: bolumId }
                         : undefined}
                       /* GONDEREN YOKSA "Kendi İsteği" (kullanici): hasta
                          sevksiz gelmistir - alan bos degil, ANLAMLI bostur.
                          "×" ile bu duruma donulur. */
                       bosMetin="Kendi İsteği (sevksiz)"
                       yerTutucu={bolumId ? 'Bu bölüme gönderen hekim ara…'
                                          : 'Gönderen hekim ara…'}
                       onSec={sec => onPersonelSec?.(sec.id, sec.unvan)}
                       onTemizle={() => onPersonelSec?.(0, '')} />
          {/* KENDI ISTEGI (370) bir SECIMDIR, alanin bosluğu degil: gonderen
              zorunlu oldugu icin "hekim yok" ancak boyle soylenebilir. Isaret
              konunca gonderen alani kilitlenir ve temizlenir - hasta ya
              gonderildi ya kendi geldi, ikisi birden olmaz. */}
          <label className="kendi-istegi">
            <input type="checkbox" checked={kendiIstegi} disabled={kilitli}
                   onChange={e => onKendiIstegi?.(e.target.checked)} />
            Kendi isteğiyle geldi (gönderen yok)
          </label>
          </div>
        ) : (
        /* HEKIM DE ARAMA EKRANINDAN (583, kullanici: "başvuruda hekim
           listesi combo değil, modal dr ve bölümün olduğu arama ekranı olsun,
           bir sütunda bugün kaç başvuru olduğu bilgisi de olsun"): yuzlerce
           hekimde combo okunmuyordu ve hekimin O GUN kac hasta aldigi hicbir
           yerde gorunmuyordu - memur yuku dengeleyemiyordu. Pencere
           Hekim · Bölüm · Bugünkü Başvuru kolonlariyla acilir. */
        <TarafSecici etiket="Hekim / Personel" kaynaklar={['basvuru-hekim']}
                     deger={personelAd}
                     kilitli={kilitli}
                     zorunlu hata={personelHatasi}
                     /* Bolum SECILIYSE arama o bolumle sinirlanir, bosken
                        hepsi gelir (297). Hekim once secilirse bolum ondan
                        dolar - iki yon de calisir (BelgeKarti). */
                     ekFiltre={bolumId
                       ? { op: 'and', kosullar: [
                           { alan: 'durum', op: 'esit', deger: 1 },
                           { alan: 'bolumId', op: 'esit', deger: bolumId }] }
                       : { alan: 'durum', op: 'esit', deger: 1 }}
                     yerTutucu={bolumId ? 'Bu bölümün hekimlerinde ara…'
                                        : 'Hekim ara…'}
                     onSec={sec => onPersonelSec?.(sec.id, sec.unvan)}
                     onTemizle={() => onPersonelSec?.(0, '')} />
        )}
        <label className="alan">
          <span className="etiket zorunlu-isaret">Başvuru Tarihi / Saati</span>
          <input type="datetime-local" value={tarih} disabled={kilitli}
                 max={tarihEnGec} min={tarihEnErken}
                 onChange={e => setTarih(e.target.value)} />
          {tarihHatasi && <span className="alan-hata">{tarihHatasi}</span>}
        </label>

        {/* 2. SIRA (kullanici): Ödeyen Kurum · Geliş Şekli · Geliş Nedeni. */}
        <label className="alan">
          {/* ZORUNLU (kullanici): "hasta kendi öder" de bir KURUMDUR - kurum
              listesinde karsiligi secilir. Bos birakilinca fiyat listesi, pay
              dagilimi (289) ve provizyon sekmesi hangi kurala gore calisacagini
              bilemiyordu. */}
          <span className="etiket zorunlu-isaret">Ödeyen Kurum</span>
          <select value={odeyenKurumId ?? ''} disabled={kilitli}
                  onChange={e => setOdeyenKurumId?.(
                    e.target.value ? Number(e.target.value) : null)}>
            <option value="">— Seçiniz —</option>
            {(kurumlar ?? []).map(k => (
              <option key={k.id} value={k.id}>{k.ad}</option>
            ))}
          </select>
          {kurumHatasi && <span className="alan-hata">{kurumHatasi}</span>}
        </label>

        {/* SOZLESME (468): ayni sigorta sirketiyle OSS / TSS / Karma police
            ayri sartlarla calisilir. TEK sozlesme varsa secici PASIF gelir -
            karar yok, bilgi var; birden fazlaysa secim ZORUNLU. */}
        {(sozlesmeler?.length ?? 0) > 0 && (
          <label className="alan">
            <span className={`etiket${(sozlesmeler?.length ?? 0) > 1
                                      ? ' zorunlu-isaret' : ''}`}>Sözleşme</span>
            <select value={bilgi.sozlesmeId ?? ''}
                    disabled={kilitli || (sozlesmeler?.length ?? 0) === 1}
                    onChange={e => degistir({
                      sozlesmeId: e.target.value ? Number(e.target.value) : null,
                      // Police turu sozlesmeden gelir: kullanici ayrica
                      //   secmesin, sunucu tetigi de ayni degeri yazar.
                      altKurum: sozlesmeler?.find(x => x.id === Number(e.target.value))
                                  ?.altKurum ?? null,
                    })}>
              <option value="">— Seçiniz —</option>
              {(sozlesmeler ?? []).map(z => (
                <option key={z.id} value={z.id}>
                  {z.altKurumAdi || z.ad}
                </option>
              ))}
            </select>
          </label>
        )}

        {/* DEVREDILEN KURUM: yalniz SGK'da sorulur (kullanici: "basvuruda
            kurum SGK ise alt kurum secmem gerekiyor"). Hasta kaydinda varsa
            oradan gelir; yoksa sunucu kayda izin vermez. */}
        {(altKurumlar?.length ?? 0) > 0 && (
          <label className="alan">
            <span className="etiket zorunlu-isaret">Devredilen Kurum</span>
            <select value={bilgi.altKurum ?? ''} disabled={kilitli}
                    onChange={e => degistir({
                      altKurum: e.target.value ? Number(e.target.value) : null })}>
              <option value="">— Seçiniz —</option>
              {(altKurumlar ?? []).map(a => (
                <option key={a.id} value={a.id}>{a.ad}</option>
              ))}
            </select>
          </label>
        )}

        {/* SGK KATKISI - TSS ve KARMA policede kapatilabilir (597, kullanici:
            "hasta SGK kullanılmasın deme hakkına sahip… TSS'de SGK
            kullanılmasın check'i ekle"). Isaret kalkinca rota ÖSS'ye duser:
            SGK payi dogmaz, tarife bedeli sigorta/hasta arasinda bolunur.
            ÖSS'de SGK zaten yok; saf SGK hastasinda karsiligi odeyen kurumu
            Özel secmektir - orada soru sorulmaz.

            Karar POLICENIN degil BASVURUNUN bilgisidir: ayni hasta ertesi
            hafta SGK'yi kullanmak isteyebilir, policesi degismez - bu yuzden
            alt kurum listesi ikiye bolunmedi. */}
        {/* EMEKLI - YALNIZ SGK'NIN ODEDIGI ROTALARDA (591, kullanici:
            "ödeyen kurum SGK ise emekli check'i çıkacak; ÖSS'de - alt kurum
            ÖSS ise - çıkmayacak, TSS ve karmada çıkacak; özel fiyatta da hiç
            çıkmayacak").

            Kural sunucudaki `fn_dagilim_rota` ile AYNI: SGK kurumu (tür 3),
            sigortada TSS (202) ve SGK katkısı açık karma (203). Saf ÖSS'de ve
            özel hastada SGK katılım payı kavramı yoktur - 590'daki
            `altKurum >= 202` kontrolü SGK'nın DEVREDİLEN KURUM kodlarını
            (alt kurum listesi) da yakalıyor, tür Özel iken bile kutu
            çizilebiliyordu. */}
        {sgkOdeyen && (
          <label className="alan onay-alan">
            <span className="etiket">Emekli</span>
            <span className="onay-satir">
              <input type="checkbox" disabled={kilitli}
                     checked={Number(bilgi.emekli ?? 0) === 1}
                     onChange={e => degistir({ emekli: e.target.checked ? 1 : 0 })} />
              <span>Emekli - SGK katılım payı alınmaz</span>
            </span>
          </label>
        )}

        {[202, 203].includes(Number(bilgi.altKurum ?? 0)) && (
          <label className="alan onay-alan">
            <span className="etiket">SGK Katkısı</span>
            <span className="onay-satir">
              <input type="checkbox" disabled={kilitli}
                     checked={Number(bilgi.sgkKullan ?? 1) === 1}
                     onChange={e => degistir({ sgkKullan: e.target.checked ? 1 : 0 })} />
              <span>SGK katkısı kullanılsın</span>
            </span>
          </label>
        )}


        <KodSecim etiket="Geliş Şekli" listeKod="basvuru.gelis_sekli"
                  deger={bilgi.gelisSekli} kilitli={kilitli}
                  onDeger={v => degistir({ gelisSekli: v })} />
        <KodSecim etiket="Geliş Nedeni" listeKod="basvuru.gelis_nedeni"
                  deger={bilgi.gelisNedeni} kilitli={kilitli}
                  onDeger={v => degistir({ gelisNedeni: v })} />

        {/* Basvuru turu SEGMENT (mockup): etiketten sonra TAM SATIR - besinci
            secenek ("Laboratuvar / Görüntüleme") iki sutuna sigmiyordu.
            LAB / GORUNTULEME kurumunda HIC SORULMAZ (kullanici): tur zaten
            "Laboratuvar / Görüntüleme"dir, kayitta 5 olarak yazilir. */}
        {!gonderenModu && (
          <KodSegment etiket="Başvuru Türü" listeKod="basvuru.tur" zorunlu vurgu={2}
                      deger={bilgi.basvuruTuru} kilitli={kilitli}
                      onDeger={v => degistir({ basvuruTuru: v })} />
        )}

        {/* Poliklinik odasi lab/goruntulemede YOK (kullanici): numune alma /
            cekim birimi ayri kavram, "oda" alani bos duruyordu. */}
        {!gonderenModu && (
          <KodSecim etiket="Poliklinik Odası" listeKod="basvuru.oda"
                    deger={bilgi.oda} kilitli={kilitli}
                    onDeger={v => degistir({ oda: v })} />
        )}
        <MetinAlani etiket="Sıra No" deger={bilgi.siraNo} kilitli={kilitli}
                    ipucu="örn. A-037" onDeger={v => degistir({ siraNo: v })} />
        {/* Randevu SALT OKUNUR: bag randevu tarafinda kurulur (randevu.belge_id),
            burada yalnizca "hangi randevudan geldi" okunur. Mockup sirasi:
            Oda · Sıra No · Randevu · Refakatçi. */}
        <label className="alan">
          <span className="etiket">Randevu</span>
          <input value={randevuBilgi || '—'} readOnly />
        </label>
        <MetinAlani etiket="Refakatçi" deger={bilgi.refakatci} kilitli={kilitli}
                    onDeger={v => degistir({ refakatci: v })} />

        {/* AMBULANS (300): yalniz gelis sekli Ambulans iken sorulur - ama
            DOLU ise her zaman gorunur, yoksa gelis sekli sonradan
            degistirildiginde kayitli numara ekranda kaybolurdu. */}
        {(Number(bilgi.gelisSekli ?? 0) === 2
          || (bilgi.ambulansHastaNo ?? '') !== ''
          || (bilgi.ambulansBileklikNo ?? '') !== '') && (
          <>
            <MetinAlani etiket="Ambulans Hasta No" deger={bilgi.ambulansHastaNo}
                        kilitli={kilitli} ipucu="112 kayıt no"
                        onDeger={v => degistir({ ambulansHastaNo: v })} />
            <MetinAlani etiket="Bileklik No" deger={bilgi.ambulansBileklikNo}
                        kilitli={kilitli}
                        onDeger={v => degistir({ ambulansBileklikNo: v })} />
          </>
        )}

        {/* BASVURU NOTU (mockup): tam genislikte serbest metin. Belgenin
            kendi aciklama alanina yazilir - ayri bir kolon acmaya gerek yok,
            alan bugune kadar basvuru kartinda hic kullanilmiyordu. */}
        <label className="alan genis-4">
          <span className="etiket">Başvuru Notu</span>
          <textarea rows={2} value={aciklama ?? ''} disabled={kilitli}
                    placeholder="örn. Tansiyon takibi; son tetkik sonuçları ile geldi."
                    onChange={e => setAciklama?.(e.target.value)} />
        </label>
      </div>
    </div>
  );
}

// ========================================================== PROVIZYON ====

// Ekran bilesenleri kendi dosyalarinda (belge/basvuru); cagri yerleri
//   degismesin diye buradan da disa aktarilir.
export { HastaSeridi } from './basvuru/HastaSeridi';
export { ProvizyonSekmesi } from './basvuru/ProvizyonSekmesi';
export { OncekiBasvurular } from './basvuru/OncekiBasvurular';
