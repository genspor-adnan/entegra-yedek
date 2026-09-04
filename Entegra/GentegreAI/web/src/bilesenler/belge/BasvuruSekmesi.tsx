import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { para, tarihSaat } from '../bicim';
import { TarafSecici } from '../TarafArama';

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
  basvuruTuru?: number | null;
  gelisSekli?: number | null;
  gelisNedeni?: number | null;
  oda?: number | null;
  siraNo?: string;
  refakatci?: string;
  // Ambulans (300) - odeyiciden bagimsiz, hastaya ait kimlik bilgisi.
  ambulansHastaNo?: string;
  ambulansBileklikNo?: string;
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

/** Kod listesi combosu - deger kod_deger.deger, gosterim ad. */
function KodSecim({ etiket, listeKod, deger, onDeger, kilitli, zorunlu }: {
  etiket: string; listeKod: string; deger?: number | null;
  onDeger(v: number | null): void; kilitli?: boolean; zorunlu?: boolean;
}) {
  const [secenekler, setSecenekler] = useState<{ deger: number; ad: string }[]>([]);
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe(listeKod);
        if (!iptal) setSecenekler(y.degerler.filter(d => d.aktif === 1));
      } catch { /* liste yoksa combo bos kalir - kayit engellenmez */ }
    })();
    return () => { iptal = true };
  }, [listeKod]);

  return (
    <label className="alan">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <select value={deger ?? ''} disabled={kilitli}
              onChange={e => onDeger(e.target.value ? Number(e.target.value) : null)}>
        <option value="">— Seçiniz —</option>
        {secenekler.map(x => <option key={x.deger} value={x.deger}>{x.ad}</option>)}
      </select>
    </label>
  );
}

/**
 * SEGMENT SECIM (mockup .seg): kod listesini combo yerine yan yana dugmelerle
 * gosterir - az secenekli, sik kullanilan alanlar icin (Başvuru Türü). Liste
 * beklenenden uzun gelirse (5'ten fazla) combo'ya duser: 10 dugme satiri
 * tasirirdi.
 */
function KodSegment({ etiket, listeKod, deger, onDeger, kilitli, zorunlu, vurgu }: {
  etiket: string; listeKod: string; deger?: number | null;
  onDeger(v: number | null): void; kilitli?: boolean; zorunlu?: boolean;
  /** Bu degerdeki secenek secilince KIRMIZI cizilir (ör. Acil). */
  vurgu?: number;
}) {
  const [secenekler, setSecenekler] = useState<{ deger: number; ad: string }[]>([]);
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe(listeKod);
        if (!iptal) setSecenekler(y.degerler.filter(d => d.aktif === 1));
      } catch { /* liste yoksa segment bos kalir - kayit engellenmez */ }
    })();
    return () => { iptal = true };
  }, [listeKod]);

  if (secenekler.length > 5) {
    return <KodSecim etiket={etiket} listeKod={listeKod} deger={deger}
                     onDeger={onDeger} kilitli={kilitli} zorunlu={zorunlu} />;
  }
  return (
    <label className="alan genis-4">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <span className={`seg${kilitli ? ' kilitli' : ''}`}>
        {secenekler.map(s => (
          <span key={s.deger}
                className={`s${s.deger === vurgu ? ' acil' : ''}`
                           + (Number(deger ?? 0) === s.deger ? ' on' : '')}
                onClick={() => { if (!kilitli) onDeger(s.deger) }}>
            {s.ad}
          </span>
        ))}
      </span>
    </label>
  );
}

/** Kisa metin alani. */
function MetinAlani({ etiket, deger, onDeger, kilitli, ipucu }: {
  etiket: string; deger?: string; onDeger(v: string): void;
  kilitli?: boolean; ipucu?: string;
}) {
  return (
    <label className="alan">
      <span className="etiket">{etiket}</span>
      <input value={deger ?? ''} disabled={kilitli} placeholder={ipucu}
             onChange={e => onDeger(e.target.value)} />
    </label>
  );
}

/**
 * Tarih-saat alani. Bos deger `null` gider: bos metin ('') gonderilirse
 * sunucu onu gecersiz tarih sayip "bos birakilamaz" hatasi verir.
 */
function ZamanAlani({ etiket, deger, onDeger, kilitli }: {
  etiket: string; deger?: string | null; onDeger(v: string | null): void;
  kilitli?: boolean;
}) {
  return (
    <label className="alan">
      <span className="etiket">{etiket}</span>
      <input type="datetime-local" value={String(deger ?? '').slice(0, 16)}
             disabled={kilitli}
             onChange={e => onDeger(e.target.value || null)} />
    </label>
  );
}

// ====================================================== HASTA SERIDI ====
/**
 * SECILI HASTA SERIDI (298, mockup "hasta" bloku): kabul boyunca ekranda
 * kalir - memur hastayi dogruladigini her an gorsun. Alanlar hasta
 * kaynagindan (taraf + taraf_hasta + varsayilan adres) tek istekle gelir.
 *
 * Mockup'taki ALERJI / KRONIK uyari cubugu YOK: o veriyi tutan bir tablo
 * henuz yok, uydurma bilgi gostermek yaniltici olurdu. Yerine gercek veriden
 * "son basvuru" uyarisi cizilir.
 */
export function HastaSeridi({ tarafId, mustehaklik, protokolNo, kilitli, kapanma,
                              kurumAdi, acikBorc, onAra, onYeniHasta }: {
  tarafId?: number | null;
  /** BELGENIN odeyen kurumu (kullanici): serit hastanin sigortasini degil,
      bu basvuruyu odeyecek kurumu gosterir - ikisi farkli olabilir. */
  kurumAdi?: string;
  /** Bu BASVURUNUN acik borcu = ucretlendirme genel toplami - tahsilat.
      Verilmezse hastanin genel acik bakiyesi gosterilir. */
  acikBorc?: number;
  /** Belgenin kapanma rozeti (KAPANMA_ETIKET) - seridin en saginda. */
  kapanma?: { ad: string; sinif?: string } | null;
  /** Belgenin SGK mustehaklik durumu (299) - sigortanin yanina rozet. */
  mustehaklik?: number | null;
  /** Belge numarasi - mockupta arama satirinin son alani. */
  protokolNo?: string;
  kilitli?: boolean;
  /** Arama penceresini acar; kutulara yazilan metin ON-DOLGU olarak gecer. */
  onAra?(metin: string): void;
  onYeniHasta?(): void;
}) {
  const [h, setH] = useState<Record<string, unknown> | null>(null);
  /**
   * ARAMA SATIRI kutulari (mockup, kullanici: "butonlarin altinda tcno, hasta
   * no, ad soyad, protokolno, ara buton, yeni hasta kaydi buton"). Secili hasta
   * varsa onun bilgileriyle dolu gelir; memur uzerine yazip Ara'ya (ya da
   * Enter'a) basinca BASKA hastayi arar.
   */
  const [tc, setTc] = useState('');
  const [dosyaNo, setDosyaNo] = useState('');
  const [adSoyad, setAdSoyad] = useState('');

  useEffect(() => {
    if (!tarafId) { setH(null); setTc(''); setDosyaNo(''); setAdSoyad(''); return }
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('hasta', {
          sayfa: 1, boyut: 1,
          filtre: { alan: 'id', op: 'esit', deger: tarafId },
        });
        if (iptal) return;
        const s = y.satirlar[0] ?? null;
        setH(s);
        setTc(String(s?.vkno ?? ''));
        setDosyaNo(String(s?.kod ?? ''));
        setAdSoyad(String(s?.unvan ?? ''));
      } catch { if (!iptal) setH(null) }
    })();
    return () => { iptal = true };
  }, [tarafId]);

  const ad = String(h?.unvan ?? '');
  const bas = ad.split(/\s+/).filter(Boolean).slice(0, 2)
                .map(x => x[0]?.toLocaleUpperCase('tr') ?? '').join('');
  /* Cinsiyet seritte IKON + TEK HARF (kullanici): "Erkek"/"Kadın" hucrede
     yer kapliyordu, ikon tek bakista okunuyor. Kayitsizsa hic yazilmaz. */
  const cinsiyetAdi = String(h?.cinsiyetAdi ?? '');
  const cinsiyet = cinsiyetAdi.startsWith('E') ? '♂ E'
                 : cinsiyetAdi.startsWith('K') ? '♀ K' : '';
  const borc = acikBorc != null ? acikBorc : Number(h?.acikBorc ?? 0);
  const dogum = String(h?.dogumTarihi ?? '').slice(0, 10);
  const yas = h?.yas != null && h.yas !== '' ? `${h.yas} y` : '';

  /**
   * Ara: memurun DEGISTIRDIGI kutuyla arar (T.C. > dosya no > ad). Kutular
   * secili hastanin bilgileriyle dolu geldigi icin dokunulmamis degeri arama
   * metni saymak yanlis olurdu - ustelik T.C. MASKELI gosterilir
   * ("111******10"), onunla arama hicbir sey bulmaz. Hicbiri degismemisse
   * pencere bos acilir (tum liste).
   */
  const ara = () => {
    const degisen = [[tc, h?.vkno], [dosyaNo, h?.kod], [adSoyad, h?.unvan]]
      .map(([kutu, kayitli]) => String(kutu ?? '').trim() === String(kayitli ?? '').trim()
        ? '' : String(kutu ?? '').trim())
      .find(Boolean);
    onAra?.(degisen ?? '');
  };
  const enter = (e: React.KeyboardEvent) => { if (e.key === 'Enter') { e.preventDefault(); ara() } };

  // F3 = Ara (mockup butonunun etiketi). Tarayicinin "sayfada bul-sonraki"
  //   davranisi engellenir; kilitli belgede kisayol da calismaz.
  useEffect(() => {
    if (kilitli) return;
    const tus = (e: KeyboardEvent) => {
      if (e.key !== 'F3') return;
      e.preventDefault();
      ara();
    };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kilitli, tc, dosyaNo, adSoyad, h]);

  return (
    <>
      {/* 1) HASTA ARAMA SATIRI (mockup): arac cubugunun altinda, bandin
             ustunde. PROTOKOL VERILINCE KAYBOLUR (kullanici): basvuru
             acildiktan sonra hasta degismez - degismesi gerekiyorsa basvuru
             iptal edilip yenisi acilir, satir o zaman geri gelir. */}
      {!protokolNo && (
      <div className="hasta-arama">
        <label className="alan">
          <span className="etiket">T.C. Kimlik No</span>
          <input value={tc} disabled={kilitli} onKeyDown={enter}
                 onChange={e => setTc(e.target.value)} />
        </label>
        <label className="alan">
          <span className="etiket">Hasta No</span>
          <input value={dosyaNo} disabled={kilitli} onKeyDown={enter}
                 onChange={e => setDosyaNo(e.target.value)} />
        </label>
        <label className="alan genis">
          <span className="etiket">Ad Soyad</span>
          <input value={adSoyad} disabled={kilitli} onKeyDown={enter}
                 onChange={e => setAdSoyad(e.target.value)} />
        </label>
        {/* Protokol no BELGENIN numarasi - aranmaz, kayitta atanir. Satir
            zaten yalniz protokol YOKKEN cizildigi icin hep bos gorunur;
            numara verilince alan Basvuru sekmesinde okunur. */}
        <label className="alan">
          <span className="etiket">Protokol No</span>
          <input value="" readOnly placeholder="(kaydedince atanacak)" />
        </label>
        <button type="button" className="d bir" onClick={ara}
                disabled={kilitli}>🔍 Ara (F3)</button>
        <button type="button" className="d" onClick={() => onYeniHasta?.()}
                disabled={kilitli}>✚ Yeni Hasta Kaydı</button>
      </div>
      )}

      {/* 2) SECILI HASTA BANDI - hasta secilene kadar cizilmez. */}
      {tarafId ? (
    <div className="hasta-serit">
      <span className="avatar">{bas || '—'}</span>
      <span className="hs">
        <span className="k">Hasta</span>
        <span className="v">{ad || '—'}</span>
      </span>
      <span className="hs">
        <span className="k">T.C. / Dosya No</span>
        <span className="v">{String(h?.vkno ?? '—')} · {String(h?.kod ?? '—')}</span>
      </span>
      <span className="hs">
        <span className="k">Doğum / Cinsiyet</span>
        <span className="v">
          {[dogum ? dogum.split('-').reverse().join('.') : '',
            cinsiyet, yas].filter(Boolean).join(' · ') || '—'}
        </span>
      </span>
      {/* ODEYEN KURUM (kullanici): eski "Sigorta" hucresi hastanin kayitli
          sigortasini yaziyordu; kabul memurunun gormesi gereken bu basvuruyu
          ODEYECEK kurum. Mustehaklik BELGEYE ait (her basvuruda yeniden
          sorgulanir), kuruma degil - o yuzden rozet disaridan gelir. */}
      <span className="hs">
        <span className="k">Ödeyen Kurum</span>
        <span className="v">
          {kurumAdi || String(h?.sigortaAdi ?? '') || '—'}
          {mustehaklik != null && mustehaklik > 0 && (
            <span className={`rozet ${MUSTEHAKLIK[mustehaklik]?.sinif ?? ''}`}>
              {MUSTEHAKLIK[mustehaklik]?.ad}
            </span>
          )}
        </span>
      </span>
      {/* Telefon ve son basvuru seritte YOK (kullanici): hasta zaten secilmis
          durumda - ikisi de arama penceresinde ise yarar, kabul ekraninda yer
          kaplar. Kalan hucreler seride esit araliklarla dagitilir. */}
      {/* ACIK BORC saga yaslanir (mockup): kabul memuru "tahsilat gerekiyor
          mu" sorusunu tek bakista gorsun. Deger BU BASVURUNUN farkidir
          (ucretlendirme genel toplami - tahsilat, kullanici) ve ucret/tahsilat
          girildikce ANINDA degisir; disaridan gelmezse hastanin genel acik
          bakiyesine duser. */}
      <span className="hs sag">
        {/* Isaret hucrenin ADINI da degistirir (kullanici): ucret > tahsilat
            ise KIRMIZI "Açık Borç", tahsilat > ucret ise YESIL "Alacaklı"
            (hasta lehine bakiye - iade/mahsup gerekir), esitse notr siyah. */}
        <span className="k">{borc < 0 ? 'Alacaklı' : 'Açık Borç'}</span>
        <span className={`v ${borc > 0 ? 'teh' : borc < 0 ? 'olumlu' : ''}`}>
          {para.format(Math.abs(borc))} ₺
        </span>
      </span>
      {/* Kapanma ("Faturalanmadı" / "Kısmi" / "Kapandı") rozeti seridin en
          saginda (kullanici): arac cubugundan buraya alindi - basvurunun
          parasal durumu acik borcun yaninda okunsun. */}
      {kapanma && (
        <span className={`rozet ${kapanma.sinif ?? ''}`}>{kapanma.ad}</span>
      )}
    </div>
      ) : null}
    </>
  );
}

// ============================================================ BASVURU ====
export function BasvuruSekmesi({ bilgi, degistir, kilitli, randevuBilgi,
                                 tarih, setTarih, tarihEnGec, tarihEnErken, tarihHatasi,
                                 bolumler, bolumId, setBolumId,
                                 gorevliler, personelId, setPersonelId,
                                 kurumlar, odeyenKurumId, setOdeyenKurumId,
                                 aciklama, setAciklama, gonderenModu,
                                 personelAd, onPersonelSec, kurumHatasi,
                                 bolumHatasi, personelHatasi }: {
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
  odeyenKurumId?: number | null;
  setOdeyenKurumId?(v: number | null): void;
  /** Basvuru notu - belgenin aciklama alani (mockup "Başvuru Notu"). */
  aciklama?: string;
  setAciklama?(v: string): void;
}) {
  // Hekim listesi bolume gore SUZULUR; bolum bosken hepsi gelir.
  const hekimler = (gorevliler ?? [])
    .filter(g => !bolumId || (g.bolumId ?? null) === bolumId);

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
          <span className="etiket zorunlu-isaret">
            {gonderenModu ? 'Bölüm' : 'Başvurulan Bölüm'}</span>
          <select value={bolumId ?? ''} disabled={kilitli}
                  onChange={e => {
                    const y = e.target.value ? Number(e.target.value) : null;
                    setBolumId?.(y);
                    // Secili personel YENI BOLUME AIT DEGILSE birakilir; ait
                    //   ise korunur (personelden bolume dogru doldurmada secim
                    //   kendini iptal etmesin).
                    const g = (gorevliler ?? []).find(x => x.id === personelId);
                    if (y && g && (g.bolumId ?? null) !== y) setPersonelId?.(null);
                  }}>
            <option value="">— Seçiniz —</option>
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
          <TarafSecici etiket="Gönderen" kaynaklar={['dis-hekim']}
                       deger={personelAd}
                       kilitli={kilitli}
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
        ) : (
        <label className="alan">
          <span className="etiket zorunlu-isaret">Hekim / Personel</span>
          <select value={personelId ?? ''} disabled={kilitli}
                  onChange={e => {
                    const y = e.target.value ? Number(e.target.value) : null;
                    setPersonelId?.(y);
                    // PERSONELDEN BOLUME (kullanici): once doktor secilirse
                    //   bolum onun bolumune gecer.
                    const g = (gorevliler ?? []).find(x => x.id === y);
                    if (g?.bolumId) setBolumId?.(g.bolumId);
                  }}>
            <option value="">— Seçiniz —</option>
            {hekimler.map(g => (
              <option key={g.id} value={g.id}>{g.ad}</option>
            ))}
          </select>
          {personelHatasi && <span className="alan-hata">{personelHatasi}</span>}
        </label>
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
const MUSTEHAKLIK: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Sorgulanmadı', sinif: '' },
  1: { ad: 'Müstehak',     sinif: 'olumlu' },
  2: { ad: 'Müstehak değil', sinif: 'teh' },
};

export function ProvizyonSekmesi({ bilgi, degistir, kilitli, kurumAdi, kurumlar,
                                  kurumTuru }: {
  bilgi: BasvuruBilgi;
  degistir(y: Partial<BasvuruBilgi>): void;
  kilitli: boolean;
  /** Odeyen kurumun turu (taraf_kurum.tur): 1 Özel / 2 ÖSS / 3 SGK. */
  kurumTuru?: number;
  /** Belgenin odeyen kurumu - SGK bloÄunda bilgi olarak gosterilir. */
  kurumAdi?: string;
  /** Anlasmali kurumlar: ozel sigorta sirketi buradan secilir (tur 2). */
  kurumlar?: { id: number; ad: string; tur?: number }[];
}) {
  const m = MUSTEHAKLIK[Number(bilgi.sgkMustehaklik ?? 0)] ?? MUSTEHAKLIK[0];

  /*
   * ALANLAR KURUM TURUNE GORE (kullanici): eskiden iki provizyon grubu da her
   * zaman ciziliyordu; ÖSS hastasinda MEDULA alanlari, SGK hastasinda police
   * alanlari bos duruyordu.
   *   SGK (3)  : MEDULA grubu. Hastanin TAMAMLAYICI policesi de olabilir -
   *              o grup istege bagli acilir (kayitli police varsa acik gelir).
   *   ÖSS (2)  : yalniz ozel sigorta grubu; MEDULA alanlari hic cizilmez.
   */
  const sgkVar = kurumTuru !== 2;
  const [tamamlayici, setTamamlayici] = useState(false);
  const ossVar = kurumTuru === 2 || tamamlayici
                 || (bilgi.ossKurumId ?? null) !== null
                 || !!bilgi.ossProvizyonNo || !!bilgi.ossPoliceNo;

  return (
    <>
      {sgkVar && (
      <div className="kagrup">
        {/* "Provizyon Al" dugmesi GRUP BASLIGINDA saga yasli (kullanici):
            arac cubugundan alindi - hangi odeyiciden provizyon alindigi
            dugmenin yerinden anlasilsin (SGK ayri, ozel sigorta ayri). */}
        <h6>
          SGK / MEDULA Provizyonu
          <button type="button" className="d bir sag" disabled
                  title="MEDULA provizyon sorgusu henüz bağlı değil - alanlar elle doldurulur.">
            🧾 Provizyon Al
          </button>
        </h6>
        <div className="alan-izgara dort-sutun">
          <label className="alan">
            <span className="etiket">Kurum</span>
            <input value={kurumAdi || "—"} readOnly />
          </label>
          <KodSecim etiket="Durum" listeKod="provizyon.durum"
                    deger={bilgi.sgkDurum} kilitli={kilitli}
                    onDeger={v => degistir({ sgkDurum: v })} />
          <MetinAlani etiket="Provizyon No" deger={bilgi.sgkProvizyonNo}
                      kilitli={kilitli} ipucu="örn. P2026-0083471"
                      onDeger={v => degistir({ sgkProvizyonNo: v })} />
          <ZamanAlani etiket="Provizyon Tarihi" deger={bilgi.sgkProvizyonTarihi}
                      kilitli={kilitli}
                      onDeger={v => degistir({ sgkProvizyonTarihi: v })} />

          <KodSecim etiket="Provizyon Tipi" listeKod="basvuru.provizyon_tipi"
                    deger={bilgi.sgkProvizyonTipi} kilitli={kilitli}
                    onDeger={v => degistir({ sgkProvizyonTipi: v })} />
          <MetinAlani etiket="Sigorta Türü" deger={bilgi.sgkSigortaTuru}
                      kilitli={kilitli} ipucu="4/a · 4/b · 4/c"
                      onDeger={v => degistir({ sgkSigortaTuru: v })} />
          {/* Basvuru (muracaat) no ile takip no AYRI numaralardir; faturalama
              takip numarasi uzerinden yapilir. */}
          <MetinAlani etiket="Başvuru No" deger={bilgi.sgkBasvuruNo} kilitli={kilitli}
                      onDeger={v => degistir({ sgkBasvuruNo: v })} />
          <MetinAlani etiket="Takip No" deger={bilgi.sgkTakipNo} kilitli={kilitli}
                      onDeger={v => degistir({ sgkTakipNo: v })} />

          <ZamanAlani etiket="Takip Tarihi" deger={bilgi.sgkTakipTarihi}
                      kilitli={kilitli}
                      onDeger={v => degistir({ sgkTakipTarihi: v })} />
          <KodSecim etiket="Takip Türü" listeKod="provizyon.takip_turu"
                    deger={bilgi.sgkTakipTuru} kilitli={kilitli}
                    onDeger={v => degistir({ sgkTakipTuru: v })} />
          <MetinAlani etiket="Tesis Kodu" deger={bilgi.sgkTesisKodu} kilitli={kilitli}
                      onDeger={v => degistir({ sgkTesisKodu: v })} />
          <ZamanAlani etiket="Geçerlilik" deger={bilgi.sgkGecerlilik}
                      kilitli={kilitli}
                      onDeger={v => degistir({ sgkGecerlilik: v })} />

          <label className="alan">
            <span className="etiket">Karşılama %</span>
            <input className="hiza-sag" value={String(bilgi.sgkKarsilama ?? "")}
                   disabled={kilitli}
                   onChange={e => degistir({ sgkKarsilama: e.target.value })} />
          </label>
          <label className="alan">
            <span className="etiket">Onaylanan Tutar</span>
            <input className="hiza-sag" value={String(bilgi.sgkTutar ?? "")}
                   disabled={kilitli}
                   onChange={e => degistir({ sgkTutar: e.target.value })} />
          </label>
          <label className="alan">
            <span className="etiket">Müstehaklık</span>
            <span className="deger-serit">
              <span className={`rozet ${m.sinif}`}>{m.ad}</span>
              {bilgi.sgkMustehaklikZaman && (
                <span className="sonuk">{tarihSaat(bilgi.sgkMustehaklikZaman)}</span>
              )}
            </span>
          </label>

          <label className="alan">
            <span className="etiket">Sevkli mi?</span>
            <select value={Number(bilgi.sgkSevkli ?? 0)} disabled={kilitli}
                    onChange={e => degistir({ sgkSevkli: Number(e.target.value) })}>
              <option value={0}>Hayır</option>
              <option value={1}>Evet</option>
            </select>
          </label>
          <MetinAlani etiket="Sevk Eden Kurum" deger={bilgi.sgkSevkKurum}
                      kilitli={kilitli || Number(bilgi.sgkSevkli ?? 0) === 0}
                      onDeger={v => degistir({ sgkSevkKurum: v })} />
          {/* Red nedeni yalniz REDDEDILDI durumunda anlamli. */}
          <MetinAlani etiket="Red Nedeni" deger={bilgi.sgkRedNedeni}
                      kilitli={kilitli || Number(bilgi.sgkDurum ?? 0) !== 2}
                      onDeger={v => degistir({ sgkRedNedeni: v })} />
        </div>
        <div className="not">
          Provizyon alınmadan başvuru açılabilir; kurum payı ancak provizyon
          numarası girildikten sonra faturalanmalıdır. Müstehaklık sorgusu
          (MEDULA) henüz bağlı değil — alanlar elle doldurulur.
        </div>
        {/* TAMAMLAYICI SIGORTA: SGK'li hastada police de olabilir - SGK'nin
            karsilamadigi farki ozel sigorta ustlenir. Grup istege bagli acilir. */}
        {!ossVar && (
          <div className="katoolbar" style={{ borderTop: '1px solid var(--cizgi)' }}>
            <button type="button" className="d" disabled={kilitli}
                    title="Hastanın tamamlayıcı/özel sigorta poliçesi varsa alanları aç"
                    onClick={() => setTamamlayici(true)}>
              ＋ Tamamlayıcı Sigorta Provizyonu
            </button>
          </div>
        )}
      </div>
      )}

      {ossVar && (
      <div className="kagrup">
        <h6>
          {kurumTuru === 2 ? 'Özel Sigorta Provizyonu'
                           : 'Tamamlayıcı Sigorta Provizyonu'}
          <button type="button" className="d bir sag" disabled
                  title="Sigorta şirketi provizyon servisi henüz bağlı değil - alanlar elle doldurulur.">
            🧾 Provizyon Al
          </button>
        </h6>
        <div className="alan-izgara dort-sutun">
          {/* Sirket belgenin odeyen kurumundan FARKLI olabilir. */}
          <label className="alan">
            <span className="etiket">Sigorta Şirketi</span>
            <select value={bilgi.ossKurumId ?? ""} disabled={kilitli}
                    onChange={e => degistir({
                      ossKurumId: e.target.value ? Number(e.target.value) : null })}>
              <option value="">— Yok —</option>
              {(kurumlar ?? []).filter(k => (k.tur ?? 0) === 2)
                .map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
            </select>
          </label>
          <KodSecim etiket="Durum" listeKod="provizyon.durum"
                    deger={bilgi.ossDurum} kilitli={kilitli}
                    onDeger={v => degistir({ ossDurum: v })} />
          <MetinAlani etiket="Provizyon No" deger={bilgi.ossProvizyonNo} kilitli={kilitli}
                      onDeger={v => degistir({ ossProvizyonNo: v })} />
          <ZamanAlani etiket="Provizyon Tarihi" deger={bilgi.ossProvizyonTarihi}
                      kilitli={kilitli}
                      onDeger={v => degistir({ ossProvizyonTarihi: v })} />

          <MetinAlani etiket="Poliçe No" deger={bilgi.ossPoliceNo} kilitli={kilitli}
                      onDeger={v => degistir({ ossPoliceNo: v })} />
          <MetinAlani etiket="Hasar / Dosya No" deger={bilgi.ossHasarNo} kilitli={kilitli}
                      onDeger={v => degistir({ ossHasarNo: v })} />
          <MetinAlani etiket="Branş" deger={bilgi.ossBrans} kilitli={kilitli}
                      ipucu="örn. Yatarak Tedavi"
                      onDeger={v => degistir({ ossBrans: v })} />
          <ZamanAlani etiket="Geçerlilik" deger={bilgi.ossGecerlilik}
                      kilitli={kilitli}
                      onDeger={v => degistir({ ossGecerlilik: v })} />

          <label className="alan">
            <span className="etiket">Karşılama %</span>
            <input className="hiza-sag" value={String(bilgi.ossKarsilama ?? "")}
                   disabled={kilitli}
                   onChange={e => degistir({ ossKarsilama: e.target.value })} />
          </label>

          <label className="alan">
            <span className="etiket">Onaylanan Tutar</span>
            <input className="hiza-sag" value={String(bilgi.ossTutar ?? "")}
                   disabled={kilitli}
                   onChange={e => degistir({ ossTutar: e.target.value })} />
          </label>
          <MetinAlani etiket="Red Nedeni" deger={bilgi.ossRedNedeni}
                      kilitli={kilitli || Number(bilgi.ossDurum ?? 0) !== 2}
                      onDeger={v => degistir({ ossRedNedeni: v })} />
        </div>
      </div>
      )}
    </>
  );
}

// ================================================== ONCEKI BASVURULAR ====
export function OncekiBasvurular({ tarafId, haricBelgeId }: {
  tarafId?: number | null;
  /** Acik olan basvuru listede tekrar gosterilmez. */
  haricBelgeId?: number;
}) {
  const [satirlar, setSatirlar] = useState<Record<string, unknown>[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    if (!tarafId) { setSatirlar([]); return }
    let iptal = false;
    setYukleniyor(true);
    void (async () => {
      try {
        const y = await api.liste('belge', {
          sayfa: 1, boyut: 50,
          sirala: [{ alan: 'belgeTarihi', yon: 'desc' }],
          filtre: { op: 'and', kosullar: [
            { alan: 'tur', op: 'esit', deger: 19 },
            { alan: 'tarafId', op: 'esit', deger: tarafId },
          ] },
        });
        if (!iptal) setSatirlar(y.satirlar.filter(r => Number(r.id) !== haricBelgeId));
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
      finally { if (!iptal) setYukleniyor(false) }
    })();
    return () => { iptal = true };
  }, [tarafId, haricBelgeId]);

  if (!tarafId) return <div className="not">Önce hasta seçin.</div>;

  return (
    <div className="kagrup">
      <h6>Önceki Başvurular {satirlar.length > 0 && <span className="b">{satirlar.length}</span>}</h6>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <table className="detay-tablo">
        <thead>
          <tr>
            <th style={{ width: 130 }}>Protokol</th>
            <th style={{ width: 140 }}>Tarih</th>
            <th>Bölüm</th>
            <th>Hekim / Personel</th>
            <th>Ödeyen Kurum</th>
            <th className="hiza-sag" style={{ width: 120 }}>Tutar</th>
            <th style={{ width: 110 }}>Kapanma</th>
          </tr>
        </thead>
        <tbody>
          {satirlar.map(r => (
            <tr key={String(r.id)}>
              <td><code>{String(r.belgeNo ?? '')}</code></td>
              <td>{tarihSaat(String(r.belgeTarihi ?? ''))}</td>
              <td>{String(r.poliklinik ?? '') || <span className="sonuk">—</span>}</td>
              <td>{String(r.doktor ?? '') || <span className="sonuk">—</span>}</td>
              <td>{String(r.odeyenKurumAdi ?? '') || <span className="sonuk">kendi öder</span>}</td>
              <td className="hiza-sag">{para.format(Number(r.genelToplam ?? 0))}</td>
              <td>{String(r.kapanmaAdi ?? '')}</td>
            </tr>
          ))}
          {!yukleniyor && satirlar.length === 0 && (
            <tr><td colSpan={7} className="bos">Bu hastanın başka başvurusu yok.</td></tr>
          )}
        </tbody>
      </table>
      {yukleniyor && <div className="yukleniyor">Yükleniyor…</div>}
    </div>
  );
}
