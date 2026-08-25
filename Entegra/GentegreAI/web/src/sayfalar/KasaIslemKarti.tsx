import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import {
  ApiHatasi, KASA_DURUM,
  type KasaIslemTuru, type KasaIslemYaniti, type ListeSatiri,
} from '../api/sozlesme';
import { GenLookup } from '../bilesenler/GenLookup';
import { TarafSecici } from '../bilesenler/TarafArama';
import { FisOnizleme } from '../bilesenler/kasa/FisOnizleme';
import { useOturum } from '../kimlik/OturumBaglami';
import { Modal } from '../bilesenler/GenForm';
import { para } from '../bilesenler/bicim';
import { DOVIZ_KODLARI, YEREL_PARA_VARSAYILAN, yerelAnMetni } from './belgeSabitleri';


const LOOKUP_HESAP = [
  { ad: 'kod', baslik: 'Kod' },
  { ad: 'ad', baslik: 'Hesap Adı', genis: true },
  { ad: 'dovizCinsi', baslik: 'Döviz' },
];
const LOOKUP_KALEM = [
  { ad: 'kod', baslik: 'Kod' },
  { ad: 'ad', baslik: 'Ad', genis: true },
];
const LOOKUP_PROJE = [
  { ad: 'kod', baslik: 'Kod' },
  { ad: 'ad', baslik: 'Proje', genis: true },
];

const GRUP_ADI: Record<string, string> = {
  tahsilat: 'Tahsilat', odeme: 'Ödeme', virman: 'Virman', doviz: 'Döviz', plan: 'Plan',
  // Cek/senet turleri (23/24/33/34 + portfoy islemleri) ayni gruptan gelir.
  ceksenet: 'Çek / Senet', kredi: 'Kredi', kupon: 'Kupon', kurfarki: 'Kur Farkı',
};

/** Sayi girisi: "1.234,56" ve "1234.56" ikisini de kabul eder. */
const sayi = (metin: string) => Number(metin.replace(/\./g, '').replace(',', '.')) || 0;

/**
 * Disaridan (URL / belge karti) gelen HAM tutari ekran bicimine cevirir.
 * Ham deger JSON'dan gelir ve ondaligi NOKTAdir ("14579.97"); ekran Turkce
 * bicim bekler - cevirmezsek sayi() noktayi binlik ayraci sanip 1.457.997
 * yaziyordu (gercek vaka).
 */
const hamTutar = (ham: string | undefined | null): string => {
  if (!ham) return '';
  const n = Number(String(ham).replace(',', '.'));
  return Number.isFinite(n) ? n.toFixed(2).replace('.', ',') : '';
};

interface HesapSecimi { id: number; ad: string; doviz: string }
interface CariSecimi { id: number; unvan: string }

/**
 * Kasa islem karti — tahsilat / odeme (F2) + virman / doviz / plan (F3).
 *
 * BACAKLARI KULLANICI GIRMEZ. Ekran basligi doldurur; bacaklari ve muhasebe
 * fisini SUNUCU turun sablonundan uretir. Ekranda gorunen tutarlar kaydettikten
 * sonra sunucunun dondugu degerlerdir - iki taraf ayrisamaz.
 *
 * Tur SERIDI yalniz AKTIF GRUBUN turlerini gosterir (40 turun hepsi degil):
 * grup listedeki "+ Tahsilat / Virman / Döviz…" aksiyonundan ya da URL'deki
 * ?tur= parametresinden gelir.
 */
/**
 * Ekran hem ROTA (tam sayfa) hem MODAL olarak acilir. Modal kullanimda
 * (`onKapat` verilince) belge kartinin "Tahsilat" sekmesinden cagrilir ve
 * baslangic degerleri prop'tan gelir - kullanici faturadan cikmadan tahsilat
 * girer.
 */
export function KasaIslemKarti({ acilis, kayitIdProp, onKapat, onKaydedildi }: {
  acilis?: { tur?: number; tarafId?: number; tarafUnvan?: string; belgeId?: number; tutar?: string };
  /** MODAL kullanimda MEVCUT kaydi acmak icin (ör. ekstre satirina cift tik).
      Rota kullanimda id URL'den gelir. */
  kayitIdProp?: number;
  onKapat?(): void;
  onKaydedildi?(): void;
} = {}) {
  const git = useNavigate();
  const { id } = useParams();
  const [sorgu] = useSearchParams();
  const modalMi = typeof onKapat === 'function';
  const { yetki, kullanici } = useOturum();

  const kayitId = kayitIdProp ?? (id && id !== 'yeni' ? Number(id) : null);

  const [turler, setTurler] = useState<KasaIslemTuru[]>([]);
  const [tur, setTur] = useState<number>(
    acilis?.tur ?? (Number(sorgu.get('tur')) || 21));
  // Islem tarihi SAATIYLE birlikte (146): gun icinde hangi tahsilatin once
  //   alindigi kasa sayiminda ve ekstre siralamasinda onemli. Yerel an -
  //   toISOString() UTC verir, aksam saatlerinde bir sonraki gunu yazardi.
  const [tarih, setTarih] = useState(yerelAnMetni(new Date()));
  const [planTarihi, setPlanTarihi] = useState('');
  // Belgeden gelen cari/tutar onyuklenir - kullanici ayni bilgiyi ikinci kez
  //   girmesin (URL parametreleri tam sayfa acilista ayni isi gorur).
  const [cari, setCari] = useState<CariSecimi | null>(() => {
    const tarafId = acilis?.tarafId ?? (Number(sorgu.get('tarafId')) || 0);
    return tarafId ? { id: tarafId, unvan: acilis?.tarafUnvan ?? '' } : null;
  });
  const [karsiCari, setKarsiCari] = useState<CariSecimi | null>(null);
  const [hesap, setHesap] = useState<HesapSecimi | null>(null);
  const [karsiHesap, setKarsiHesap] = useState<HesapSecimi | null>(null);
  /** Islemin para birimi - hesap secilince onun dovizine gecer, elle degisir. */
  const [doviz, setDoviz] = useState(YEREL_PARA_VARSAYILAN);
  /** Cari hesaba hangi dovizde islenecek (139): islem dovizi ya da yerel para. */
  const [ekstreDovizi, setEkstreDovizi] = useState(YEREL_PARA_VARSAYILAN);
  const [tutar, setTutar] = useState(hamTutar(acilis?.tutar ?? sorgu.get('tutar')));
  /** Tahsilatin kapatacagi belge (kasa_islem.belge_id). */
  const belgeBagi = acilis?.belgeId ?? (Number(sorgu.get('belgeId')) || 0);
  const [kur, setKur] = useState('1');
  const [karsiTutar, setKarsiTutar] = useState('');
  const [masrafTutar, setMasrafTutar] = useState('');
  const [kalem, setKalem] = useState<{ id: number; ad: string } | null>(null);
  const [proje, setProje] = useState<{ id: number; ad: string } | null>(null);
  const [aciklama, setAciklama] = useState('');

  // Cek / senet (23/24/33/34): kiymetin kendisi. Vade ZORUNLU - portfoyun ve
  //   vade raporunun tasiyicisi odur; digerleri kiymetin uzerindeki bilgiler.
  const [csVade, setCsVade] = useState('');
  const [csSeriNo, setCsSeriNo] = useState('');
  const [csKesideci, setCsKesideci] = useState('');
  const [csBanka, setCsBanka] = useState('');
  const [csSube, setCsSube] = useState('');

  // Plan gerceklestirme paneli
  const [gHesap, setGHesap] = useState<HesapSecimi | null>(null);
  const [gTutar, setGTutar] = useState('');
  const [gTarih, setGTarih] = useState(new Date().toISOString().slice(0, 10));

  const [sonuc, setSonuc] = useState<KasaIslemYaniti | null>(null);
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});

  const secili = useMemo(() => turler.find(t => t.kod === tur), [turler, tur]);
  const grup = secili?.grup ?? 'tahsilat';
  const durum = sonuc ? Number(sonuc.islem.durum ?? 0) : null;
  const kilitli = durum !== null && durum >= 2;      // gerceklesmis / iptal: salt gorunum
  const planMi = grup === 'plan';
  const karsiHesapli = grup === 'virman' || grup === 'doviz';
  const donusum = grup === 'doviz';
  const cariVirman = tur === 49;
  /** Cek/senet ile tahsilat-odeme: kiymet kaydi da acilir (23/24 al, 33/34 ver). */
  const cekSenetMi = tur === 23 || tur === 24 || tur === 33 || tur === 34;
  const senetMi = tur === 24 || tur === 34;
  // Cek/senette hesap SECILMEZ: kiymet portfoye girer (sanal hesap), para
  //   bankaya ancak tahsil edilince gecer. Doviz o yuzden basliktan gelir.
  /**
   * PARA BIRIMI SECILEBILIR (kullanici). Hesap secilince hesabin dovizine
   * gecer - dovizli kasadan TL tahsilat yazilmasin; ama kullanici sonradan
   * degistirebilir (cek/senette hesap yok, kiymet USD olabilir). Uyusmazlik
   * SUNUCUDA denetlenir; burada engellemek dogru kaydi da imkansiz kilardi.
   */
  /** Ileri tarih yasagi icin ust sinir - dakikada bir tazelenmesine gerek yok. */
  const enGecAn = yerelAnMetni(new Date());
  const anaDoviz = doviz;
  const dovizli = anaDoviz !== 'TL';
  const ekleyebilir = yetki('kasa_islem', 'ekle');

  // Turler bir kez yuklenir (katalog degismez, 5 dk cache sunucuda).
  useEffect(() => {
    void (async () => {
      try { setTurler(await api.kasaIslemTurleri()) }
      catch (h) { setHata(h instanceof ApiHatasi ? h.message : String(h)) }
    })();
  }, []);

  const yaniti = useCallback((y: KasaIslemYaniti) => {
    setSonuc(y);
    // Modal kullanimda cagiran (belge karti) tahsilat listesini tazelesin.
    onKaydedildi?.();
    const i = y.islem;
    setTur(Number(i.tur));
    if (i.islemTarihi) setTarih(String(i.islemTarihi).slice(0, 16));
    setPlanTarihi(i.planTarihi ? String(i.planTarihi).slice(0, 10) : '');
    setTutar(String(i.tutar ?? ''));
    setKur(String(i.dovizKuru ?? 1));
    setDoviz(String(i.dovizCinsi ?? YEREL_PARA_VARSAYILAN) || YEREL_PARA_VARSAYILAN);
    setEkstreDovizi(String(i.ekstreDovizi ?? '') ||
                    String(i.dovizCinsi ?? YEREL_PARA_VARSAYILAN) || YEREL_PARA_VARSAYILAN);
    setKarsiTutar(Number(i.karsiTutar) ? String(i.karsiTutar) : '');
    setMasrafTutar(Number(i.masrafTutar) ? String(i.masrafTutar) : '');
    setAciklama(String(i.aciklama ?? ''));
    setCari(i.tarafId ? { id: Number(i.tarafId), unvan: String(i.tarafUnvan ?? '') } : null);
    setKarsiCari(i.karsiTarafId ? { id: Number(i.karsiTarafId), unvan: '' } : null);
    setHesap(i.hesapId ? {
      id: Number(i.hesapId), ad: String(i.hesapAdi ?? ''), doviz: String(i.dovizCinsi ?? 'TL'),
    } : null);
    setKarsiHesap(i.karsiHesapId ? {
      id: Number(i.karsiHesapId), ad: String(i.karsiHesapAdi ?? ''),
      doviz: String(i.karsiDovizCinsi || 'TL'),
    } : null);
    setProje(i.projeId ? { id: Number(i.projeId), ad: String(i.projeAdi ?? '') } : null);
    setGTutar(Number(i.kalanTutar) ? String(i.kalanTutar) : '');
  }, []);

  // Mevcut kaydi ac
  useEffect(() => {
    if (kayitId === null) return;
    void (async () => {
      try { yaniti(await api.kasaOku(kayitId)) }
      catch (h) { setHata(h instanceof ApiHatasi ? h.message : String(h)) }
    })();
  }, [kayitId, yaniti]);

  // Hesap ya da tarih degisince kuru tazele (yalniz dovizli hesapta, kilitli degilse).
  useEffect(() => {
    if (kilitli || anaDoviz === 'TL') { if (!kilitli && anaDoviz === 'TL') setKur('1'); return }
    const yon = grup === 'tahsilat' ? 1 : 2;      // giris satis, cikis alis kuru
    void (async () => {
      try {
        const k = await api.dovizKur(anaDoviz, tarih, yon);
        if (k.kur) setKur(String(k.kur));
      } catch { /* kur yoksa kullanici elle girer */ }
    })();
  }, [anaDoviz, tarih, grup, kilitli]);

  const yerelOnizleme = sayi(tutar) * (Number(kur.replace(',', '.')) || 1);
  // Doviz donusumunde efektif kur: verilen yerel tutar / alinan doviz tutari.
  const caprazKur = donusum && sayi(karsiTutar) > 0 ? yerelOnizleme / sayi(karsiTutar) : 0;

  function govde(taslak: boolean, plan: boolean) {
    return {
      islem: {
        tur,
        islemTarihi: tarih,
        planTarihi: plan && planTarihi ? planTarihi : null,
        tarafId: cari?.id ?? null,
        karsiTarafId: cariVirman ? karsiCari?.id ?? null : null,
        hesapId: hesap?.id ?? null,
        karsiHesapId: karsiHesapli ? karsiHesap?.id ?? null : null,
        tutar: sayi(tutar),
        dovizCinsi: anaDoviz,
        // Ekstre dovizi (139): yerel islemde anlamsiz - bos gider, sunucu islem
        //   dovizini kullanir.
        ekstreDovizi: dovizli ? ekstreDovizi : '',
        dovizKuru: Number(kur.replace(',', '.')) || 1,
        karsiDovizCinsi: donusum ? karsiHesap?.doviz ?? '' : '',
        karsiTutar: donusum ? sayi(karsiTutar) : 0,
        masrafTutar: sayi(masrafTutar),
        masrafId: kalem?.id ?? null,
        projeId: proje?.id ?? null,
        aciklama,
      },
      // Cek/senet turlerinde kiymetin kendisi de gonderilir: sunucu once
      //   cek_senet kaydini acar, kimligini basliga baglar (tek cagri).
      ...(cekSenetMi ? {
        cekSenet: {
          vade: csVade || null,
          tarih: tarih,
          seriNo: csSeriNo,
          kesideci: csKesideci || cari?.unvan || '',
          bankaAdi: senetMi ? '' : csBanka,
          bankaSubesi: senetMi ? '' : csSube,
          aciklama,
        },
      } : {}),
      // belgeId: tahsilat bu belgeyi kapatir (kasa_islem.belge_id) - belge
      //   kartinin Tahsilat sekmesi bu bagla listeliyor.
      secenekler: { taslak, plan, kurKontrolu: true,
                    ...(belgeBagi ? { belgeId: belgeBagi } : {}) },
    };
  }

  async function kaydet(taslak: boolean, plan = planMi) {
    setHata(null);
    setAlanHatalari({});

    const hatalar: Record<string, string> = {};
    if (!planMi && !cariVirman && !cekSenetMi && !hesap) hatalar.hesapId = 'Hesap seçilmeli.';
    if (cekSenetMi && !csVade) hatalar['cekSenet.vade'] = 'Vade zorunlu.';
    if (karsiHesapli && !karsiHesap) hatalar.karsiHesapId = 'Karşı hesap seçilmeli.';
    if (cariVirman && !karsiCari) hatalar.karsiTarafId = 'Karşı cari seçilmeli.';
    if (sayi(tutar) <= 0) hatalar.tutar = 'Sıfırdan büyük olmalı.';
    if (donusum && sayi(karsiTutar) <= 0) hatalar.karsiTutar = 'Sıfırdan büyük olmalı.';
    if (secili?.cariZorunlu === 1 && !cari) hatalar.tarafId = 'Cari zorunlu.';
    if (plan && !planTarihi) hatalar.planTarihi = 'Vade zorunlu.';
    if (Object.keys(hatalar).length) { setAlanHatalari(hatalar); return }

    setCalisiyor(true);
    try {
      const y = kayitId === null
        ? await api.kasaEkle(govde(taslak, plan))
        : await api.kasaGuncelle(kayitId, { ...govde(taslak, plan), surum: String(sonuc?.islem.surum ?? '') });
      yaniti(y);
      // GENEL KURAL (kullanici): Kaydet'e basilinca form KAPANIR. Modalde cagiran
      //   kapatir (belge kartinin Tahsilat sekmesi), tam sayfada listeye donulur.
      if (modalMi) onKapat?.();
      else git('/kasa-islem');
    } catch (h) { hataYaz(h) } finally { setCalisiyor(false) }
  }

  async function kesinlestir() {
    if (!kayitId) return;
    setHata(null);
    setCalisiyor(true);
    try {
      yaniti(await api.kasaKesinlestir(kayitId));
      // Kesinlestirme de bir "kaydet": islem bitti, form kapanir.
      if (modalMi) onKapat?.(); else git('/kasa-islem');
    }
    catch (h) { hataYaz(h) } finally { setCalisiyor(false) }
  }

  async function iptalEt() {
    if (!kayitId) return;
    const sebep = window.prompt('İptal sebebi:');
    if (!sebep) return;
    setHata(null);
    setCalisiyor(true);
    try {
      await api.kasaIptal(kayitId, sebep);
      yaniti(await api.kasaOku(kayitId));
    } catch (h) { hataYaz(h) } finally { setCalisiyor(false) }
  }

  /** Plandan tahsilat/odeme uretir; plan kaydi DEGISMEZ, yeni islem acilir. */
  async function gerceklestir() {
    if (!kayitId || !gHesap) { setAlanHatalari({ gHesapId: 'Hesap seçilmeli.' }); return }
    setHata(null);
    setCalisiyor(true);
    try {
      const y = await api.kasaGerceklestir(kayitId, gHesap.id, sayi(gTutar) || undefined, gTarih);
      if (modalMi) yaniti(y); else git(`/kasa-islem/${y.islem.id}`);
    } catch (h) { hataYaz(h) } finally { setCalisiyor(false) }
  }

  function hataYaz(h: unknown) {
    if (h instanceof ApiHatasi) {
      if (h.hata.alanlar)
        setAlanHatalari(Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])));
      setHata(h.message);
    } else setHata(String(h));
  }

  if (!ekleyebilir && kayitId === null)
    return <div className="sahne"><div className="hata-kutusu">Kasa işlemi ekleme yetkiniz yok.</div></div>;

  const anaEtiket = grup === 'odeme' ? 'Ödenen Hesap'
                  : grup === 'virman' || grup === 'doviz' ? 'Kaynak Hesap'
                  : 'Tahsil Edilen Hesap';

  /** Baslik cubugu dugmeleri - hem sayfa hem modal duzeninde AYNI. */
  const dugmeler = (
          <>
            {modalMi
              ? <button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>
              : <button className="d" onClick={() => git(planMi ? '/plan-vade' : '/kasa-islem')}>
                  Listeye Dön
                </button>}
            {/* TASLAK KAYDET KALKTI (kullanici): kasa islemi kaydedilince
                kesindir - belge kartindaki kuralla ayni. Taslak (durum 0)
                sunucuda duruyor, gocten gelen kayitlar ve API icin. */}
            {!kilitli && durum !== 1 && (
              planMi
                ? <button className="d bir" disabled={calisiyor} onClick={() => void kaydet(false, true)}>
                    {calisiyor ? 'Kaydediliyor…' : 'Planı Kaydet'}
                  </button>
                : <button className="d bir" disabled={calisiyor} onClick={() => void kaydet(false, false)}>
                    {calisiyor ? 'Kaydediliyor…' : 'Kaydet'}
                  </button>
            )}
            {kayitId !== null && durum === 0 && (
              <button className="d bir" disabled={calisiyor} onClick={() => void kesinlestir()}>
                Kesinleştir
              </button>
            )}
            {durum === 2 && (
              <button className="d teh" disabled={calisiyor} onClick={() => void iptalEt()}>
                İptal Et
              </button>
            )}
          </>
  );

  const govdeIcerik = (
      <div className={modalMi ? '' : 'sahne'}>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {sonuc?.uyarilar?.length ? (
          <ul className="uyari-liste">{sonuc.uyarilar.map((u, i) => <li key={i}>{u}</li>)}</ul>
        ) : null}

        <div className="kutu" style={{ padding: 14 }}>
          {/* TUR SERIDI KALKTI (kullanici): islem turu zaten bu karti acan
              dugmeden gelir (Nakit / Banka / POS / Çek / Senet) ve pencere
              basliginda yazili; kartta ikinci kez sormak gereksizdi. */}

          {/* BASLIK - fatura kartiyla AYNI duzen (kullanici): 4 sutunlu izgara,
              sirasiyla Cari · Tutar (+ para birimi) · Tahsil Hesabi · Islem
              Tarihi. Kalan alanlar (masraf, proje, aciklama) altta akar. */}
          <div className="alan-izgara dort-sutun belge-hdr">
              {secili?.cariZorunlu !== -1 && (
                <TarafSecici
                  etiket={cariVirman ? 'Kaynak Cari' : 'Cari'}
                  zorunlu={secili?.cariZorunlu === 1}
                  deger={cari?.unvan}
                  hata={alanHatalari.tarafId}
                  kilitli={kilitli}
                  yerTutucu="Müşteri / tedarikçi ara…"
                  onSec={sec => setCari({ id: sec.id, unvan: sec.unvan })}
                  onTemizle={() => setCari(null)}
                />
              )}

              {cariVirman && (
                <TarafSecici
                  etiket="Hedef Cari"
                  zorunlu
                  deger={karsiCari?.unvan}
                  hata={alanHatalari.karsiTarafId}
                  kilitli={kilitli}
                  yerTutucu="Müşteri / tedarikçi ara…"
                  onSec={sec => setKarsiCari({ id: sec.id, unvan: sec.unvan })}
                  onTemizle={() => setKarsiCari(null)}
                />
              )}

              {/* Tutar ve PARA BIRIMI yan yana: para birimi hesabin dovizidir,
                  hesap secilince kilitlenir - kasa TL ise USD tahsilat olamaz. */}
              <label className="alan">
                <span className="etiket zorunlu-isaret">
                  {donusum ? 'Verilen Tutar' : 'Tutar'}
                </span>
                <span className="ikili">
                  <input className="hiza-sag" value={tutar} disabled={kilitli}
                         onChange={e => setTutar(e.target.value)} />
                  {/* Para birimi SECILEBILIR (kullanici): hesap secilince onun
                      dovizi gelir, gerekirse degistirilir (cek/senette hesap
                      yok - kiymet dovizli olabilir). */}
                  <select className="birim" value={anaDoviz} disabled={kilitli}
                          title="İşlemin para birimi"
                          onChange={e => setDoviz(e.target.value)}>
                    {DOVIZ_KODLARI.map(k => <option key={k} value={k}>{k}</option>)}
                    {!DOVIZ_KODLARI.includes(anaDoviz as typeof DOVIZ_KODLARI[number]) && (
                      <option value={anaDoviz}>{anaDoviz}</option>
                    )}
                  </select>
                </span>

                {/* DOVIZ SECILINCE ikinci satir (kullanici): para birimi
                    combosunun TAM ALTINDA kur, kurun SOLUNDA yerel karsilik -
                    ust satirla ayni hizada, ne girildigi ve ne ettigi tek
                    hucrede okunur. */}
                {dovizli && (
                  <>
                    <span className="ikili">
                      <input className="hiza-sag onizleme" readOnly
                             title={`${anaDoviz} tutarın ${YEREL_PARA_VARSAYILAN} karşılığı`}
                             value={`${para.format(yerelOnizleme)} ${YEREL_PARA_VARSAYILAN}`} />
                      <input className="hiza-sag birim-alti" value={kur} disabled={kilitli}
                             title={`1 ${anaDoviz} = ? ${YEREL_PARA_VARSAYILAN}`}
                             onChange={e => setKur(e.target.value)} />
                    </span>
                    {/* EKSTRE DOVIZI ucuncu satirda, ayni hucrede (kullanici):
                        cari hesaba hangi birimde islenecegi (139) - secenekler
                        islem dovizi ve yerel para. */}
                    <span className="ikili">
                      <span className="alan-notu hiza-sag">Ekstre dövizi</span>
                      <select className="birim-alti" value={ekstreDovizi} disabled={kilitli}
                              title="Cari hesaba hangi para biriminde işlenecek"
                              onChange={e => setEkstreDovizi(e.target.value)}>
                        {[...new Set([anaDoviz, YEREL_PARA_VARSAYILAN])].map(k => (
                          <option key={k} value={k}>{k}</option>
                        ))}
                      </select>
                    </span>
                  </>
                )}
                {alanHatalari.tutar && <span className="alan-hata">{alanHatalari.tutar}</span>}
              </label>

              {!planMi && !cariVirman && !cekSenetMi && (
                <GenLookup
                  kaynak="hesap"
                  etiket={anaEtiket}
                  zorunlu
                  alanlar={LOOKUP_HESAP}
                  // Hesap listesi hem TURE hem PARA BIRIMINE gore suzulur
                  //   (kullanici): USD tahsilatta yalniz USD banka/kasa cikar -
                  //   TL kasaya USD yazip sonra "hesabin dovizi tutmuyor"
                  //   hatasi almak yerine dogru secenek bastan gorunur.
                  sabitFiltre={{
                    op: 'and',
                    kosullar: [
                      ...(secili?.anaHesapTuru
                        ? [{ alan: 'tur', op: 'esit' as const, deger: secili.anaHesapTuru }]
                        : []),
                      { alan: 'dovizCinsi', op: 'esit' as const, deger: anaDoviz },
                    ],
                  }}
                  deger={hesap?.ad}
                  hata={alanHatalari.hesapId}
                  saltOkunur={kilitli}
                  onSec={(s: ListeSatiri | null) => {
                    const h = s ? {
                      id: Number(s.id), ad: String(s.ad ?? ''),
                      doviz: String(s.dovizCinsi ?? 'TL'),
                    } : null;
                    setHesap(h);
                    // Hesabin dovizi isleme tasinir: TL kasadan USD tahsilat
                    //   yazilmasin. Kullanici gerekirse combodan degistirir.
                    if (h) setDoviz(h.doviz);
                  }}
                />
              )}

              <label className="alan">
                <span className="etiket">İşlem Tarihi</span>
                {/* ILERI TARIH YASAK (kullanici): para el degistirmeden tahsilat
                    yazilamaz. `max` tarayicida engeller, sunucu da ayrica
                    dogrular (KasaDeposu.IleriTarihKontrol). */}
                <input type="datetime-local" value={tarih} disabled={kilitli}
                       max={enGecAn}
                       onChange={e => setTarih(e.target.value)} />
              </label>

              {karsiHesapli && (
                <GenLookup
                  kaynak="hesap"
                  etiket="Hedef Hesap"
                  zorunlu
                  alanlar={LOOKUP_HESAP}
                  sabitFiltre={secili?.karsiHesapTuru
                    ? { alan: 'tur', op: 'esit', deger: secili.karsiHesapTuru }
                    : undefined}
                  deger={karsiHesap?.ad}
                  hata={alanHatalari.karsiHesapId}
                  saltOkunur={kilitli}
                  onSec={s => setKarsiHesap(s ? {
                    id: Number(s.id), ad: String(s.ad ?? ''), doviz: String(s.dovizCinsi ?? 'TL'),
                  } : null)}
                />
              )}

              {/* CEK / SENET (23/24/33/34): kiymetin kendisi. Vade zorunlu -
                  portfoy ve vade raporlarinin tasiyicisi odur. */}
              {cekSenetMi && (
                <>
                  <label className="alan">
                    <span className="etiket zorunlu-isaret">Vade</span>
                    <input type="date" value={csVade} disabled={kilitli}
                           onChange={e => setCsVade(e.target.value)} />
                    {alanHatalari['cekSenet.vade'] && (
                      <span className="alan-hata">{alanHatalari['cekSenet.vade']}</span>
                    )}
                  </label>
                  <label className="alan">
                    <span className="etiket">{senetMi ? 'Senet No' : 'Çek No'}</span>
                    <input value={csSeriNo} maxLength={30} disabled={kilitli}
                           onChange={e => setCsSeriNo(e.target.value)} />
                  </label>
                  <label className="alan">
                    <span className="etiket">Keşideci</span>
                    <input value={csKesideci} maxLength={150} disabled={kilitli}
                           placeholder={cari?.unvan ?? ''}
                           onChange={e => setCsKesideci(e.target.value)} />
                  </label>
                  {!senetMi && (
                    <label className="alan">
                      <span className="etiket">Banka / Şube</span>
                      <span className="ikili">
                        <input value={csBanka} maxLength={60} disabled={kilitli}
                               placeholder="Banka" onChange={e => setCsBanka(e.target.value)} />
                        <input value={csSube} maxLength={60} disabled={kilitli}
                               placeholder="Şube" onChange={e => setCsSube(e.target.value)} />
                      </span>
                    </label>
                  )}
                </>
              )}
          </div>

          <div className="kagrup">
            <h6>Bilgiler</h6>
            <div className="alan-izgara">
              {planMi && (
                <label className="alan">
                  <span className="etiket">Vade *</span>
                  <input type="date" value={planTarihi} disabled={kilitli || durum === 1}
                         onChange={e => setPlanTarihi(e.target.value)} />
                  {alanHatalari.planTarihi && <span className="alan-hata">{alanHatalari.planTarihi}</span>}
                </label>
              )}

              {/* Kur ve TL karsiligi BASLIKTA, tutarin altinda (kullanici) -
                  burada ikinci kez gostermek tekrar oluyordu. */}

              {donusum && (
                <>
                  <label className="alan">
                    <span className="etiket">
                      Alınan Tutar{karsiHesap ? ` (${karsiHesap.doviz})` : ''}
                    </span>
                    <input className="hiza-sag" value={karsiTutar} disabled={kilitli}
                           onChange={e => setKarsiTutar(e.target.value)} />
                    {alanHatalari.karsiTutar && <span className="alan-hata">{alanHatalari.karsiTutar}</span>}
                  </label>
                  <label className="alan">
                    <span className="etiket">Efektif Kur (önizleme)</span>
                    <input className="hiza-sag onizleme"
                           value={caprazKur ? caprazKur.toFixed(6) : ''} readOnly />
                  </label>
                </>
              )}

              {secili?.kalemTuru !== 0 && (
                <>
                  <label className="alan">
                    <span className="etiket">Masraf Tutarı</span>
                    <input className="hiza-sag" value={masrafTutar} disabled={kilitli}
                           placeholder="0,00"
                           onChange={e => setMasrafTutar(e.target.value)} />
                  </label>
                  <GenLookup
                    kaynak="masraf"
                    etiket="Gider Kalemi"
                    alanlar={LOOKUP_KALEM}
                    deger={kalem?.ad}
                    saltOkunur={kilitli}
                    onSec={s => setKalem(s ? { id: Number(s.id), ad: String(s.ad ?? '') } : null)}
                  />
                </>
              )}

              <GenLookup
                kaynak="proje"
                etiket="Proje"
                alanlar={LOOKUP_PROJE}
                sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
                deger={proje?.ad}
                saltOkunur={kilitli}
                onSec={s => setProje(s ? { id: Number(s.id), ad: String(s.ad ?? '') } : null)}
              />

              <label className="alan genis">
                <span className="etiket">Açıklama</span>
                <input value={aciklama} maxLength={200} disabled={kilitli}
                       onChange={e => setAciklama(e.target.value)} />
              </label>
            </div>
          </div>

          {/* Acik plan: gerceklestirme paneli. Plan kaydi degismez (K10), yeni
              bir tahsilat/odeme islemi acilir ve plandan kalan dusulur. */}
          {durum === 1 && (
            <div className="kagrup">
              <h6>
                Planı Gerçekleştir
                <span className="rozet">
                  kalan {para.format(Number(sonuc?.islem.kalanTutar ?? 0))} {String(sonuc?.islem.dovizCinsi ?? '')}
                </span>
              </h6>
              <div className="alan-izgara">
                <GenLookup
                  kaynak="hesap"
                  etiket="Tahsilat / Ödeme Hesabı"
                  zorunlu
                  alanlar={LOOKUP_HESAP}
                  deger={gHesap?.ad}
                  hata={alanHatalari.gHesapId}
                  onSec={s => setGHesap(s ? {
                    id: Number(s.id), ad: String(s.ad ?? ''), doviz: String(s.dovizCinsi ?? 'TL'),
                  } : null)}
                />
                <label className="alan">
                  <span className="etiket">Tutar (boş = kalanın tamamı)</span>
                  <input className="hiza-sag" value={gTutar}
                         onChange={e => setGTutar(e.target.value)} />
                </label>
                <label className="alan">
                  <span className="etiket">Tarih</span>
                  <input type="date" value={gTarih} onChange={e => setGTarih(e.target.value)} />
                </label>
                <label className="alan">
                  <span className="etiket">&nbsp;</span>
                  <button className="d bir" disabled={calisiyor} onClick={() => void gerceklestir()}>
                    {calisiyor ? 'İşleniyor…' : '✔ Gerçekleştir'}
                  </button>
                </label>
              </div>
            </div>
          )}

          {/* HAREKET BACAKLARI BOLUMU KALKTI (kullanici): muhasebe kaydinin ham
              hali gunluk tahsilat ekraninda yer kapliyordu. Fis onizlemesi
              (asagida) zaten ayni bilgiyi hesap adlariyla gosteriyor. */}
          {sonuc?.fis && <FisOnizleme fis={sonuc.fis} />}

          {!kilitli && (
            <div className="not">
              Muhasebe kaydı sunucuda işlem türünün şablonundan üretilir;
              buradaki TL karşılığı yalnızca önizlemedir.
              {donusum && ' Verilen ve alınan tutarın TL karşılığı tutmazsa fark kambiyo kâr/zararı olarak yazılır.'}
            </div>
          )}
        </div>
      </div>
  );

  // MODAL: belge kartinin Tahsilat sekmesinden acilinca fatura arkada kalir.
  if (modalMi)
    return (
      <Modal
        baslik={`${secili?.ad ?? 'Kasa İşlemi'}${sonuc?.islem.islemNo ? ` — ${sonuc.islem.islemNo}` : ''}`}
        ustBilgi={durum !== null
          ? <span className={`rozet ${durum === 2 ? 'ok' : durum === 3 ? 'uyari' : 'gri'}`}>
              {KASA_DURUM[durum] ?? durum}
            </span>
          : undefined}
        onKapat={onKapat}
        alt={dugmeler}
      >
        {govdeIcerik}
      </Modal>
    );

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{secili?.ad ?? 'Kasa İşlemi'}</h1>
          <span className="yol">
            Kasa › {GRUP_ADI[grup] ?? grup}
            {sonuc?.islem.islemNo ? ` · ${sonuc.islem.islemNo}` : ''}
          </span>
          {durum !== null && (
            <span className={`rozet ${durum === 2 ? 'olumlu' : durum === 3 ? 'uyari' : ''}`}>
              {KASA_DURUM[durum] ?? durum}
            </span>
          )}
          {kullanici?.subeYazma === false && <span className="rozet uyari">salt okuma şubesi</span>}
          <div className="sag">{dugmeler}</div>
        </div>
      </div>
      {govdeIcerik}
    </>
  );
}
