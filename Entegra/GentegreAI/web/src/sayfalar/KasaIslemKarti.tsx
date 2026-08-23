import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import {
  ApiHatasi, KASA_DURUM,
  type KasaIslemTuru, type KasaIslemYaniti, type ListeSatiri,
} from '../api/sozlesme';
import { GenLookup } from '../bilesenler/GenLookup';
import { TarafSecici } from '../bilesenler/TarafArama';
import { BacakListesi } from '../bilesenler/kasa/BacakSatiri';
import { FisOnizleme } from '../bilesenler/kasa/FisOnizleme';
import { useOturum } from '../kimlik/OturumBaglami';
import { Modal } from '../bilesenler/GenForm';

const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

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
  const [tarih, setTarih] = useState(new Date().toISOString().slice(0, 10));
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
  const [tutar, setTutar] = useState(hamTutar(acilis?.tutar ?? sorgu.get('tutar')));
  /** Tahsilatin kapatacagi belge (kasa_islem.belge_id). */
  const belgeBagi = acilis?.belgeId ?? (Number(sorgu.get('belgeId')) || 0);
  const [kur, setKur] = useState('1');
  const [karsiTutar, setKarsiTutar] = useState('');
  const [masrafTutar, setMasrafTutar] = useState('');
  const [kalem, setKalem] = useState<{ id: number; ad: string } | null>(null);
  const [proje, setProje] = useState<{ id: number; ad: string } | null>(null);
  const [aciklama, setAciklama] = useState('');

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
  const anaDoviz = hesap?.doviz ?? (planMi ? 'TL' : 'TL');
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
    if (i.islemTarihi) setTarih(String(i.islemTarihi).slice(0, 10));
    setPlanTarihi(i.planTarihi ? String(i.planTarihi).slice(0, 10) : '');
    setTutar(String(i.tutar ?? ''));
    setKur(String(i.dovizKuru ?? 1));
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
        dovizKuru: Number(kur.replace(',', '.')) || 1,
        karsiDovizCinsi: donusum ? karsiHesap?.doviz ?? '' : '',
        karsiTutar: donusum ? sayi(karsiTutar) : 0,
        masrafTutar: sayi(masrafTutar),
        masrafId: kalem?.id ?? null,
        projeId: proje?.id ?? null,
        aciklama,
      },
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
    if (!planMi && !cariVirman && !hesap) hatalar.hesapId = 'Hesap seçilmeli.';
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
      // Modalde rota DEGISMEZ: kasa karti fatura kartinin ustunde acik kalir
      //   (rotayi degistirmek arkadaki faturayi kapatiyordu).
      if (kayitId === null && !modalMi) git(`/kasa-islem/${y.islem.id}`, { replace: true });
    } catch (h) { hataYaz(h) } finally { setCalisiyor(false) }
  }

  async function kesinlestir() {
    if (!kayitId) return;
    setHata(null);
    setCalisiyor(true);
    try { yaniti(await api.kasaKesinlestir(kayitId)) }
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

  const gruptakiTurler = turler.filter(t => t.grup === grup);
  const anaEtiket = grup === 'odeme' ? 'Ödenen Hesap'
                  : grup === 'virman' || grup === 'doviz' ? 'Kaynak Hesap'
                  : 'Tahsil Edilen Hesap';

  /** Baslik cubugu dugmeleri - hem sayfa hem modal duzeninde AYNI. */
  const dugmeler = (
          <>
            {modalMi
              ? <button className="d" onClick={onKapat}>✖ Kapat</button>
              : <button className="d" onClick={() => git(planMi ? '/plan-vade' : '/kasa-islem')}>
                  Listeye Dön
                </button>}
            {!kilitli && durum !== 1 && (
              <>
                <button className="d" disabled={calisiyor} onClick={() => void kaydet(true, false)}>
                  Taslak Kaydet
                </button>
                {planMi
                  ? <button className="d bir" disabled={calisiyor} onClick={() => void kaydet(false, true)}>
                      {calisiyor ? 'Kaydediliyor…' : 'Planı Kaydet'}
                    </button>
                  : <button className="d bir" disabled={calisiyor} onClick={() => void kaydet(false, false)}>
                      {calisiyor ? 'Kaydediliyor…' : 'Kaydet ve Kesinleştir'}
                    </button>}
              </>
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
          {/* Tur seridi: yalniz AKTIF GRUP. Kaydedildikten sonra tur degistirilemez -
              bacak sablonu ve fis buna baglidir. */}
          <div className="kagrup">
            <h6>{GRUP_ADI[grup] ?? grup} Türü</h6>
            <div className="cip-serit">
              {gruptakiTurler.map(t => (
                <button
                  key={t.kod}
                  type="button"
                  className={`cip ${t.kod === tur ? 'secili' : ''}`}
                  disabled={sonuc !== null}
                  onClick={() => setTur(t.kod)}
                >
                  {t.ad}
                </button>
              ))}
            </div>
          </div>

          <div className="kagrup">
            <h6>Bilgiler</h6>
            <div className="alan-izgara">
              <label className="alan">
                <span className="etiket">İşlem Tarihi</span>
                <input type="date" value={tarih} disabled={kilitli}
                       onChange={e => setTarih(e.target.value)} />
              </label>

              {planMi && (
                <label className="alan">
                  <span className="etiket">Vade *</span>
                  <input type="date" value={planTarihi} disabled={kilitli || durum === 1}
                         onChange={e => setPlanTarihi(e.target.value)} />
                  {alanHatalari.planTarihi && <span className="alan-hata">{alanHatalari.planTarihi}</span>}
                </label>
              )}

              {!planMi && !cariVirman && (
                <GenLookup
                  kaynak="hesap"
                  etiket={anaEtiket}
                  zorunlu
                  alanlar={LOOKUP_HESAP}
                  sabitFiltre={secili?.anaHesapTuru
                    ? { alan: 'tur', op: 'esit', deger: secili.anaHesapTuru }
                    : undefined}
                  deger={hesap?.ad}
                  hata={alanHatalari.hesapId}
                  saltOkunur={kilitli}
                  onSec={(s: ListeSatiri | null) => setHesap(s ? {
                    id: Number(s.id), ad: String(s.ad ?? ''), doviz: String(s.dovizCinsi ?? 'TL'),
                  } : null)}
                />
              )}

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

              <label className="alan">
                <span className="etiket">
                  {donusum ? `Verilen Tutar (${anaDoviz})` : `Tutar${dovizli ? ` (${anaDoviz})` : ''}`}
                </span>
                <input className="hiza-sag" value={tutar} disabled={kilitli}
                       onChange={e => setTutar(e.target.value)} />
                {alanHatalari.tutar && <span className="alan-hata">{alanHatalari.tutar}</span>}
              </label>

              {dovizli && (
                <>
                  <label className="alan">
                    <span className="etiket">Kur</span>
                    <input className="hiza-sag" value={kur} disabled={kilitli}
                           onChange={e => setKur(e.target.value)} />
                  </label>
                  <label className="alan">
                    <span className="etiket">TL Karşılığı (önizleme)</span>
                    <input className="hiza-sag onizleme" value={para.format(yerelOnizleme)} readOnly />
                  </label>
                </>
              )}

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

          {/* Bacaklar: sunucunun urettigi muhasebe kaydinin ham hali. */}
          <div className="kagrup">
            <h6>Hareket Bacakları</h6>
            <BacakListesi bacaklar={sonuc?.bacaklar ?? []} dovizCinsi={anaDoviz} />
          </div>

          {sonuc?.fis && <FisOnizleme fis={sonuc.fis} />}

          {!kilitli && (
            <div className="not">
              Bacaklar ve muhasebe fişi sunucuda işlem türünün şablonundan üretilir;
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
