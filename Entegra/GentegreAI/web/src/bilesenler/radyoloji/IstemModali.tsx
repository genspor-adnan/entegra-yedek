import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { TarafArama } from '../TarafArama';
import { mesaj } from '../mesaj';
import { para } from '../bicim';
import { KasaIslemKarti } from '../../sayfalar/KasaIslemKarti';

/**
 * RADYOLOJI ISTEM ACMA (304).
 *
 * Iki mockup'in ortak ekrani: radyoloji_hekim_istem.html (IC istem -
 * poliklinikteki hekim basvuruya tetkik ister) ve radyoloji_kayit_kabul.html
 * (DIS istem - baska kurumun hekiminden gelen hasta). Fark yalnizca
 * ISTEYENIN kim oldugu; tetkik secimi, klinik bilgi, ucret ve accession
 * uretimi ayni oldugu icin tek bilesen.
 *
 * Bir seferde COK TETKIK secilir: her biri AYRI istem (ayri accession) olur -
 * PACS ve raporlama accession bazlidir.
 */

interface Tetkik { id: number; kod: string; ad: string; modalite: number;
                   modaliteAdi: string; kdv: number;
                   /** Tetkikin protokol hazirligi, yoksa modalite varsayilani (311). */
                   hazirlik?: string }
interface Hekim { id: number; ad: string; bolumAdi: string }
interface Gecmis { hizmetId: number; tetkikAdi: string; tarih: string }

/** Secili tetkik: listedeki tetkik + isteme ozel secimler. */
interface Secim { tetkik: Tetkik; oncelik: number; kontrast: number }

/**
 * Kalem fiyati (mockup radyoloji_kayit_kabul: Liste / Indirim / Tutar).
 * Sunucudaki kuralin AYNISI (liste -> kampanya) - kabul masasi tutari
 * kaydetmeden once gormeli, hastaya soylenen rakam faturayla tutmali.
 */
interface KalemFiyati { liste: number; tutar: number; kdv: number }

const ONCELIK = [
  { deger: 1, ad: 'Normal' },
  { deger: 2, ad: 'Acil' },
  { deger: 3, ad: 'Çok Acil' },
];

const KONTRAST = [
  { deger: 0, ad: 'Verilmeyecek' },
  { deger: 1, ad: 'Verilecek' },
];

const gun = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '';
};

export function IstemModali({ acik, hastaId, hastaAdi, belgeId, disIstem, onKapat, onTamam }: {
  acik: boolean;
  hastaId: number;
  hastaAdi: string;
  /** Basvuru (protokol) - ucret satirlari buraya eklenir. */
  belgeId?: number | null;
  /** DIS istem mi: disaridan gelen hastanin istem kagidi (hekim/kurum adi elle). */
  disIstem?: boolean;
  onKapat(): void;
  onTamam?(accessionlar: string[]): void;
}) {
  const [tetkikler, setTetkikler] = useState<Tetkik[]>([]);
  const [hekimler, setHekimler] = useState<Hekim[]>([]);
  /** Kayitli dis hekim secildiyse id; "listede yok" ise serbest metin. */
  const [disHekimId, setDisHekimId] = useState<number | null>(null);
  const [disHekimSecim, setDisHekimSecim] = useState('');
  const [hekimArama, setHekimArama] = useState(false);
  const [gecmis, setGecmis] = useState<Gecmis[]>([]);
  const [ara, setAra] = useState('');
  const [secili, setSecili] = useState<Secim[]>([]);
  const [istekHekimId, setIstekHekimId] = useState<number | null>(null);
  const [disHekimAd, setDisHekimAd] = useState('');
  const [istekKurumId, setIstekKurumId] = useState<number | null>(null);
  /** Secili kurumun ADI - kutuda id degil ad gorunur. */
  const [istekKurumAd, setIstekKurumAd] = useState('');
  const [kurumArama, setKurumArama] = useState(false);
  const [onTani, setOnTani] = useState('');
  const [klinikBilgi, setKlinikBilgi] = useState('');
  const [ucretEkle, setUcretEkle] = useState(true);
  /** KABUL modu (mockup radyoloji_kayit_kabul): basvurusu olmayan dis hasta. */
  const kabulMu = !!disIstem && !belgeId;
  const [basvuruAc, setBasvuruAc] = useState(true);
  const [odeyenKurumId, setOdeyenKurumId] = useState<number | null>(null);
  const [odeyenKurumAd, setOdeyenKurumAd] = useState('');
  const [odeyenArama, setOdeyenArama] = useState(false);
  const [policeNo, setPoliceNo] = useState('');
  const [fiyatlar, setFiyatlar] = useState<Record<number, KalemFiyati>>({});
  /** Kabul sonrasi ozet: protokol no ve tutarlar (mockup ozet seridi). */
  const [sonuc, setSonuc] = useState<{ belgeId: number; belgeNo: string;
    genelToplam: number; kurumTutar: number; hastaTutar: number } | null>(null);
  /**
   * HASTADAN TAHSIL EDILECEK tutar. Pay bolusumu (289) KDV'SIZ net uzerinden
   * yapilir; kasadan tahsil edilen ise KDV DAHIL tutardir - hastanin payini
   * net oraniyla genel toplama tasiyoruz, yoksa KDV kadar eksik tahsilat
   * acilirdi (800 yerine 880).
   */
  const hastaTahsil = sonuc
    ? (() => {
        const net = sonuc.kurumTutar + sonuc.hastaTutar;
        if (net <= 0) return sonuc.genelToplam;
        return Math.round((sonuc.genelToplam * sonuc.hastaTutar / net) * 100) / 100;
      })()
    : 0;
  const [tahsilatAcik, setTahsilatAcik] = useState(false);
  /**
   * ISTEM KAGIDI (mockup: "📷 İstem Kâğıdını Tara"). Tarayici donanimina
   * erisim YOK; kabul masasi ya tarayicidan gelen dosyayi secer ya da
   * telefon/tablette kamerayi acar (capture). Dosya kabul BITINCE yuklenir -
   * once istem id'si olmali.
   */
  const [kagit, setKagit] = useState<File | null>(null);
  const kagitGirdi = useRef<HTMLInputElement | null>(null);
  const [kagitDurum, setKagitDurum] = useState('');
  /**
   * KABUL SONRASI (311, mockup sag alt kutusu). MWL ve SMS entegrasyonu YOK -
   * secim kayda ISTEK olarak gecer; entegrasyon gelince ayni bayraklar
   * tetikleyici olur. Hazirlik talimati ise bugun de calisir: metni kabul
   * masasi hastaya okur/verir.
   */
  const [mwl, setMwl] = useState(true);
  const [sms, setSms] = useState(true);
  const [hazirlik, setHazirlik] = useState(true);
  const [cd, setCd] = useState(false);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    try {
      const y = await api.radyolojiIstemSecenekleri(hastaId);
      setTetkikler(y.tetkikler as unknown as Tetkik[]);
      setHekimler(y.hekimler as unknown as Hekim[]);
      setGecmis(y.gecmis as unknown as Gecmis[]);
    } catch (h) { setHata(hataMetni(h)) }
  }, [hastaId]);

  useEffect(() => { if (acik) void yukle() }, [acik, yukle]);

  // HASTANIN AKTIF POLICESI (248): kabul masasi police numarasini elle
  //   yazmasin - hasta kartinda duruyorsa oradan gelir, gerekirse duzeltilir.
  useEffect(() => {
    if (!acik || !kabulMu) return;
    void (async () => {
      try {
        const y = await api.liste('hasta-kurum', {
          sayfa: 1, boyut: 1,
          filtre: { op: 'and', kosullar: [
            { alan: 'hastaId', op: 'esit', deger: hastaId },
          ] },
        });
        const k = y.satirlar[0];
        if (!k) return;
        if (k.kurumId) {
          setOdeyenKurumId(Number(k.kurumId));
          setOdeyenKurumAd(String(k.kurumAdi ?? ''));
        }
        if (k.policeNo) setPoliceNo(String(k.policeNo));
      } catch { /* police yoksa alanlar bos kalir - kabul yine yapilir */ }
    })();
  }, [acik, kabulMu, hastaId]);

  // FIYAT: secili tetkikler / odeyen kurum degistikce yeniden cozulur.
  //   Kurum degisince kampanya ve sozlesme listesi de degisir (302) -
  //   ekrandaki tutar kaydedilecek tutarla ayni kalmali.
  useEffect(() => {
    if (!acik) return;
    let birak = false;
    void (async () => {
      // BAZ LISTE: kampanya -> SOZLESME -> cari -> varsayilan sirasi (302)
      //   yalniz bu ucta cozuluyor; kalem fiyatina listeyi VERMEZSEK kurum
      //   sozlesmesindeki liste devreye girmez ve ekran 0 gosterirdi.
      let listeId: number | null = null;
      try {
        listeId = (await api.belgeVarsayilanListe(19, hastaId, odeyenKurumId)).listeId;
      } catch { /* liste cozulemezse kalem kendi kuralina duser */ }
      const yeni: Record<number, KalemFiyati> = {};
      for (const sec of secili) {
        try {
          const f = await api.fiyatKalem({ hizmetId: sec.tetkik.id },
                                         { tarafId: hastaId, kurumId: odeyenKurumId,
                                           listeId });
          yeni[sec.tetkik.id] = {
            liste: Number(f.bazFiyat ?? 0),
            tutar: Number(f.fiyat ?? f.bazFiyat ?? 0),
            kdv: Number(sec.tetkik.kdv ?? 0),
          };
        } catch { /* fiyat cozulemezse satir 0 gorunur, kabul engellenmez */ }
      }
      if (!birak) setFiyatlar(yeni);
    })();
    return () => { birak = true };
  }, [acik, secili, odeyenKurumId, hastaId]);

  /** Mockup'taki tutar kutusu: liste, indirim, KDV, genel toplam. */
  const toplam = useMemo(() => {
    let liste = 0, net = 0, kdv = 0;
    secili.forEach(sec => {
      const f = fiyatlar[sec.tetkik.id];
      if (!f) return;
      liste += f.liste;
      net += f.tutar;
      kdv += (f.tutar * f.kdv) / 100;
    });
    return { liste, net, kdv, indirim: liste - net, genel: net + kdv };
  }, [secili, fiyatlar]);

  /** Secili tetkiklerin hazirlik talimatlari - AYNI metin tekrar edilmez. */
  const talimatlar = useMemo(() => {
    const gorulen = new Set<string>();
    const liste: { baslik: string; metin: string }[] = [];
    secili.forEach(sec => {
      const metin = (sec.tetkik.hazirlik ?? '').trim();
      if (!metin || gorulen.has(metin)) return;
      gorulen.add(metin);
      liste.push({ baslik: sec.tetkik.modaliteAdi || sec.tetkik.ad, metin });
    });
    return liste;
  }, [secili]);

  /** Modaliteye gore gruplu, aramayla suzulmus tetkik agaci. */
  const agac = useMemo(() => {
    const k = ara.trim().toLocaleLowerCase('tr');
    const suz = k
      ? tetkikler.filter(t => t.ad.toLocaleLowerCase('tr').includes(k)
                           || t.kod.toLocaleLowerCase('tr').includes(k))
      : tetkikler;
    const gruplar = new Map<string, Tetkik[]>();
    suz.forEach(t => {
      const g = t.modaliteAdi || 'Diğer';
      if (!gruplar.has(g)) gruplar.set(g, []);
      gruplar.get(g)!.push(t);
    });
    return [...gruplar.entries()];
  }, [tetkikler, ara]);

  const ekle = (t: Tetkik) => {
    if (secili.some(s => s.tetkik.id === t.id)) return;
    setSecili(x => [...x, { tetkik: t, oncelik: 1, kontrast: 0 }]);
  };
  const cikar = (id: number) => setSecili(x => x.filter(s => s.tetkik.id !== id));
  const degistir = (id: number, y: Partial<Secim>) =>
    setSecili(x => x.map(s => (s.tetkik.id === id ? { ...s, ...y } : s)));

  /** Son 12 ayda ayni tetkik cekilmis mi (mockup mukerrer tetkik uyarisi). */
  const mukerrer = secili
    .map(s => gecmis.find(g => g.hizmetId === s.tetkik.id))
    .filter(Boolean) as Gecmis[];

  const kaydet = async (tahsilatla = false) => {
    setHata('');
    if (secili.length === 0) { setHata('En az bir tetkik seçilmeli.'); return }
    if (!klinikBilgi.trim()) {
      setHata('Klinik bilgi / istem gerekçesi yazılmalı — radyolog raporu buradan yazar.');
      return;
    }
    setKaydediyor(true);
    try {
      const y = await api.radyolojiIstemAc({
        hastaId, belgeId: belgeId ?? null,
        // DIS istemde de istekHekimId dolabilir: kayitli dis hekim secildiyse
        //   kayit ona baglanir (kart "gonderdigi tetkik" sayaci bundan besleniyor),
        //   secilmediyse serbest metin yazilir.
        istekHekimId: disIstem ? disHekimId : istekHekimId,
        disHekimAd: disIstem && !disHekimId ? disHekimAd : '',
        istekKurumId: disIstem ? istekKurumId : null,
        onTani, klinikBilgi,
        oncelik: 1,
        // Basvuru ACILIYORSA ucret de yazilir: kabul masasinin urettigi
        //   kayit "tetkik var ama tutari yok" halinde kalmamali.
        ucretEkle: ucretEkle && (!!belgeId || (kabulMu && basvuruAc)),
        basvuruAc: kabulMu && basvuruAc,
        mwlIstendi: mwl ? 1 : 0,
        smsIstendi: sms ? 1 : 0,
        hazirlikVerildi: hazirlik ? 1 : 0,
        cdIstendi: cd ? 1 : 0,
        odeyenKurumId: kabulMu ? odeyenKurumId : null,
        policeNo: kabulMu ? policeNo : '',
        tetkikler: secili.map(s => ({ hizmetId: s.tetkik.id, oncelik: s.oncelik,
                                      kontrast: s.kontrast })),
      });
      // ISTEM KAGIDI uretilen HER isteme eklenir: rapor yazan radyolog hangi
      //   accession'i acarsa acsin kagidi gormeli; tek isteme baglamak
      //   digerlerini "kagitsiz" gosterirdi.
      if (kagit && y.idler.length > 0) {
        setKagitDurum('İstem kâğıdı yükleniyor…');
        try {
          for (const istemId of y.idler)
            await api.dokumanYukle('radyoloji-istem', istemId, kagit, false);
          setKagitDurum(`İstem kâğıdı eklendi: ${kagit.name}`);
        } catch (h) { setKagitDurum(`İstem kâğıdı eklenemedi: ${hataMetni(h)}`) }
      }
      mesaj(`${y.idler.length} istem açıldı: ${y.accessionlar.join(', ')}`);
      onTamam?.(y.accessionlar);
      // Basvuru acildiysa modal KAPANMAZ: protokol numarasi ve tahsil
      //   edilecek tutar gosterilir (mockup ozet seridi) - kabul masasi
      //   hastaya soyleyecegi rakami burada gorur.
      if (y.basvuru) {
        setSonuc({
          belgeId: Number(y.basvuru.id),
          belgeNo: String(y.basvuru.belgeNo ?? ''),
          genelToplam: Number(y.basvuru.genelToplam ?? 0),
          kurumTutar: Number(y.basvuru.kurumTutar ?? 0),
          hastaTutar: Number(y.basvuru.hastaTutar ?? 0),
        });
        if (tahsilatla) setTahsilatAcik(true);
        return;
      }
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  if (!acik) return null;

  return (
    <Modal baslik={`Radyoloji İstemi — ${hastaAdi}`} onKapat={onKapat}
           alt={
             sonuc ? (
               <>
                 {/* Kabul bitti: kayit uretildi, kalan is TAHSILAT. */}
                 {hastaTahsil > 0 && (
                   <button className="d onay" onClick={() => setTahsilatAcik(true)}>
                     💵 Tahsilat Al ({para.format(hastaTahsil)} ₺)
                   </button>
                 )}
                 <button className="d" onClick={onKapat}>Kapat</button>
               </>
             ) : (
               <>
                 <button className="d onay" disabled={kaydediyor} onClick={() => void kaydet()}>
                   {kaydediyor ? '⏳ Açılıyor…' : `✔ İstemi Aç (${secili.length})`}
                 </button>
                 {/* Mockup'taki tek dugmelik kabul: basvuru + istem + tahsilat.
                     Tahsilat penceresi kayit BITINCE acilir - once kayit, sonra
                     para; ters sirada "tahsil edildi ama istem yok" kalirdi. */}
                 {/* Mockup toolbar: istem kagidini tara/yukle. */}
                 <button className="d" onClick={() => kagitGirdi.current?.click()}>
                   📷 {kagit ? 'İstem Kâğıdı ✓' : 'İstem Kâğıdını Tara'}
                 </button>
                 {kabulMu && basvuruAc && (
                   <button className="d" disabled={kaydediyor}
                           onClick={() => void kaydet(true)}>
                     💵 Tahsilat Al ve Kabul Et
                   </button>
                 )}
                 <button className="d" onClick={onKapat}>✖ Vazgeç</button>
               </>
             )
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="istem-duzen">
        {/* --- SOL: tetkik agaci --- */}
        <div className="kagrup istem-agac">
          <h6>Tetkik Seçimi</h6>
          <div className="kagov">
            <input value={ara} placeholder="🔍 Tetkik ara (kod / ad)…"
                   onChange={e => setAra(e.target.value)} />
            {agac.length === 0 && (
              <div className="not">
                Modalitesi tanımlı tetkik yok. Hizmet kartında “Modalite” alanı
                doldurulan hizmetler burada listelenir.
              </div>
            )}
            {agac.map(([grup, liste]) => (
              <div className="agac-grup" key={grup}>
                <div className="agac-baslik">{grup}</div>
                {liste.map(t => (
                  <div className="agac-satir" key={t.id} onClick={() => ekle(t)}>
                    <span className="sonuk">{t.kod}</span> {t.ad}
                  </div>
                ))}
              </div>
            ))}
          </div>
        </div>

        {/* --- SAG: secilenler + istem bilgisi --- */}
        <div className="istem-sag">
          <div className="kagrup">
            <h6>Seçilen Tetkikler ({secili.length})</h6>
            <table className="detay-tablo">
              <thead>
                <tr><th>Kod</th><th>Tetkik</th><th>Öncelik</th><th>Kontrast</th>
                    <th className="sag">Liste</th><th className="sag">İndirim</th>
                    <th className="sag">Tutar</th><th /></tr>
              </thead>
              <tbody>
                {secili.length === 0 && (
                  <tr><td colSpan={8} className="bos">Soldaki listeden tetkik seçin.</td></tr>
                )}
                {secili.map(s => (
                  <tr key={s.tetkik.id}>
                    <td className="sonuk">{s.tetkik.kod}</td>
                    <td>{s.tetkik.ad}</td>
                    <td>
                      <select value={s.oncelik}
                              onChange={e => degistir(s.tetkik.id,
                                                      { oncelik: Number(e.target.value) })}>
                        {ONCELIK.map(o => <option key={o.deger} value={o.deger}>{o.ad}</option>)}
                      </select>
                    </td>
                    <td>
                      <select value={s.kontrast}
                              onChange={e => degistir(s.tetkik.id,
                                                      { kontrast: Number(e.target.value) })}>
                        {KONTRAST.map(o => <option key={o.deger} value={o.deger}>{o.ad}</option>)}
                      </select>
                    </td>
                    {/* FIYAT (mockup): liste, indirim ve odenecek tutar satir
                        satir gorunur - kabul masasi toplami kaydetmeden once
                        hastaya soyleyebilmeli. */}
                    <td className="sag">
                      {fiyatlar[s.tetkik.id]
                        ? para.format(fiyatlar[s.tetkik.id].liste) : '—'}
                    </td>
                    <td className="sag ind">
                      {fiyatlar[s.tetkik.id]
                       && fiyatlar[s.tetkik.id].liste > fiyatlar[s.tetkik.id].tutar
                        ? '−' + para.format(fiyatlar[s.tetkik.id].liste
                                            - fiyatlar[s.tetkik.id].tutar)
                        : '—'}
                    </td>
                    <td className="sag"><b>
                      {fiyatlar[s.tetkik.id]
                        ? para.format(fiyatlar[s.tetkik.id].tutar) : '—'}
                    </b></td>
                    <td>
                      <button className="d mini teh" title="Listeden çıkar"
                              onClick={() => cikar(s.tetkik.id)}>✕</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* MUKERRER TETKIK: engel degil UYARI - hekim gerekcelendirsin. */}
          {mukerrer.length > 0 && (
            <div className="uyari-kutusu">
              Son 12 ayda aynı tetkik yapılmış:{' '}
              {mukerrer.map(m => `${m.tetkikAdi} (${gun(m.tarih)})`).join(' · ')}.
              Yeni istemi klinik bilgide gerekçelendirin.
            </div>
          )}

          <div className="kagrup">
            <h6>İstem Bilgisi</h6>
            <div className="alan-izgara dort-sutun">
              {disIstem ? (
                <>
                  {/* Kayitli dis hekim (305) JENERIK ARAMA EKRANINDAN secilir
                      (kullanici): combo, hekim sayisi artinca kullanilmaz hale
                      gelirdi - arama ekraninda brans/kurum kolonlariyla
                      "hangi Ortopedi hekimiydi" sorusu cevaplanabiliyor.
                      Secilen hekim istemin istek_hekim_id'sine yazilir ve
                      hekim kartindaki "gonderdigi tetkik" sayaci isler. */}
                  {/* genis-2: arama kutusu + iki dugme dort-sutunluk dar hucreye
                      sigmiyor, secili ad "Öz…" diye kirpiliyordu. */}
                  <label className="alan genis-2">
                    <span className="etiket">İsteyen Hekim (dış)</span>
                    <span className="ikili">
                      <input value={disHekimSecim} readOnly
                             placeholder="Kayıtlı hekim seç…"
                             onClick={() => setHekimArama(true)} />
                      <button type="button" className="d mini"
                              title="Dış hekim ara"
                              onClick={() => setHekimArama(true)}>…</button>
                      {disHekimId != null && (
                        <button type="button" className="d mini" title="Seçimi kaldır"
                                onClick={() => { setDisHekimId(null); setDisHekimSecim('') }}>
                          ✕
                        </button>
                      )}
                    </span>
                  </label>
                  {/* Kayitli hekim SECILMEDIYSE serbest metin - bir kerelik
                      gelen, kaydedilmeye degmeyen hekim icin. */}
                  {!disHekimId && (
                    <label className="alan">
                      <span className="etiket">Hekim Adı (kayıtsız)</span>
                      <input value={disHekimAd} placeholder="örn. Op. Dr. Kerem ATALAY"
                             onChange={e => setDisHekimAd(e.target.value)} />
                    </label>
                  )}
                  {/* ISTEYEN KURUM da JENERIK ARAMA (kullanici): combo yalniz
                      ilk 200 cariyi tasiyordu - sevk eden hastane listede
                      yoksa alan bos birakiliyordu. Arama ekraninda "+ Yeni"
                      ile kurum aninda cari olarak acilabiliyor. */}
                  <label className="alan genis-2">
                    <span className="etiket">İsteyen Kurum</span>
                    <span className="ikili">
                      <input value={istekKurumAd} readOnly
                             placeholder="Kurum seç…"
                             onClick={() => setKurumArama(true)} />
                      <button type="button" className="d mini" title="Kurum ara"
                              onClick={() => setKurumArama(true)}>…</button>
                      {istekKurumId != null && (
                        <button type="button" className="d mini" title="Seçimi kaldır"
                                onClick={() => { setIstekKurumId(null); setIstekKurumAd('') }}>
                          ✕
                        </button>
                      )}
                    </span>
                  </label>
                </>
              ) : (
                <label className="alan genis-2">
                  <span className="etiket">İsteyen Hekim</span>
                  <select value={istekHekimId ?? ''}
                          onChange={e => setIstekHekimId(
                            e.target.value ? Number(e.target.value) : null)}>
                    <option value="">— Seçiniz —</option>
                    {hekimler.map(h => (
                      <option key={h.id} value={h.id}>
                        {h.ad}{h.bolumAdi ? ` · ${h.bolumAdi}` : ''}
                      </option>
                    ))}
                  </select>
                </label>
              )}
              <label className="alan">
                <span className="etiket">Ön Tanı (ICD-10)</span>
                <input value={onTani} maxLength={20} placeholder="örn. M51.1"
                       onChange={e => setOnTani(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Ücret</span>
                <span className="deger-serit">
                  {/* Kabul modunda basvuru BU EKRANDA acildigi icin ucret de
                      yazilabilir; ic istemde mevcut basvuru sarttir. */}
                  <input type="checkbox" checked={ucretEkle}
                         disabled={!belgeId && !(kabulMu && basvuruAc)}
                         onChange={e => setUcretEkle(e.target.checked)} />
                  <span className={belgeId || (kabulMu && basvuruAc) ? '' : 'sonuk'}>
                    {belgeId ? 'Başvuruya ücret satırı ekle'
                     : kabulMu && basvuruAc ? 'Açılacak başvuruya ücret yazılır'
                     : 'Başvuru yok — ücret eklenmez'}
                  </span>
                </span>
              </label>

              <label className="alan genis-4">
                <span className="etiket zorunlu-isaret">Klinik Bilgi / İstem Gerekçesi</span>
                <textarea rows={3} value={klinikBilgi}
                          placeholder="örn. 3 aydır süren bel ağrısı, sağ bacağa yayılım. Konservatif tedaviye yanıtsız."
                          onChange={e => setKlinikBilgi(e.target.value)} />
              </label>
            </div>
            <div className="not">
              Klinik bilgi radyoloğun raporunda “Klinik Bilgi” bölümüne düşer —
              boş istem radyologa “neden çekildi” sorusunu bıraktığı için zorunludur.
              Kaydedince her tetkik için ayrı istem (accession no) üretilir ve
              çalışma listesine düşer.
            </div>
          </div>

          {/* KABUL SONRASI ve ODEME YAN YANA (kullanici): kabul masasi
              secenekleri solda, tutar/tahsilat sagda - biri otekinin
              altina dusunce ekran uzuyor ve tutar gozden kaciyordu. */}
          <div className="kabul-satir">
            {/* KABUL SONRASI (mockup radyoloji_kayit_kabul sag alt kutusu).
                Ic istemde de anlamli (hazirlik/CD), o yuzden kabul moduna
                baglanmadi - MWL/SMS entegrasyonu gelene kadar niyet kaydi. */}
            <div className="kagrup kabul-sonrasi">
              <h6>Kabul Sonrası</h6>
              <div className="secenekler">
                <label className="onay">
                  <input type="checkbox" checked={mwl}
                         onChange={e => setMwl(e.target.checked)} />
                  Cihaz listesine (MWL) gönder
                </label>
                <label className="onay">
                  <input type="checkbox" checked={sms}
                         onChange={e => setSms(e.target.checked)} />
                  Randevu / hazırlık SMS'i yolla
                </label>
                <label className="onay">
                  <input type="checkbox" checked={hazirlik}
                         onChange={e => setHazirlik(e.target.checked)} />
                  Hazırlık talimatı ver
                </label>
                <label className="onay">
                  <input type="checkbox" checked={cd}
                         onChange={e => setCd(e.target.checked)} />
                  Sonuç için CD hazırla
                </label>
              </div>

              {/* HAZIRLIK METNI seçili tetkiklerden gelir: tetkikin kendi
                  protokolü varsa o, yoksa modalite varsayılanı (311). */}
              {hazirlik && talimatlar.length > 0 && (
                <div className="hazirlik-metin">
                  {talimatlar.map(t => (
                    <div key={t.baslik}>
                      <b>{t.baslik}</b> — {t.metin}
                    </div>
                  ))}
                </div>
              )}

              <div className="not">
                MWL (cihaz çalışma listesi) ve SMS gönderimi henüz bağlı değil —
                işaret kayda <b>istek</b> olarak yazılır, entegrasyon eklendiğinde
                aynı bayraklar tetikler. Hazırlık talimatı ve CD isteği bugün de
                istem kartında görünür.
              </div>
            </div>
            {/* ÖDEME (mockup radyoloji_kayit_kabul): disaridan gelen hastanin
                basvurusu burada acilir - odeyen kurum fiyati ve pay bolusumunu
                belirler, kalan tutar hastadan tahsil edilir. */}
            {kabulMu && (
              <div className="kagrup kabul-odeme">
                <h6>Ödeme / Kabul</h6>
                <div className="alan-izgara dort-sutun">
                  <label className="alan genis-2">
                    <span className="etiket">Ödeyen Kurum</span>
                    <span className="ikili">
                      <input value={odeyenKurumAd} readOnly placeholder="Hasta kendi öder…"
                             onClick={() => setOdeyenArama(true)} />
                      <button type="button" className="d mini" title="Kurum ara"
                              onClick={() => setOdeyenArama(true)}>…</button>
                      {odeyenKurumId != null && (
                        <button type="button" className="d mini" title="Seçimi kaldır"
                                onClick={() => { setOdeyenKurumId(null); setOdeyenKurumAd('') }}>
                          ✕
                        </button>
                      )}
                    </span>
                  </label>
                  <label className="alan">
                    <span className="etiket">Poliçe No</span>
                    <input value={policeNo} maxLength={40}
                           onChange={e => setPoliceNo(e.target.value)} />
                  </label>
                  <label className="alan">
                    <span className="etiket">Başvuru</span>
                    <span className="deger-serit">
                      <input type="checkbox" checked={basvuruAc}
                             onChange={e => setBasvuruAc(e.target.checked)} />
                      <span>Başvuru aç ve ücretlendir</span>
                    </span>
                  </label>
                </div>

                <div className="kabul-tutar">
                  <div className="tut"><span>Liste tutarı</span>
                    <span>{para.format(toplam.liste)} ₺</span></div>
                  <div className="tut"><span>İndirim</span>
                    <span className="ind">−{para.format(toplam.indirim)} ₺</span></div>
                  <div className="tut"><span>KDV</span>
                    <span>{para.format(toplam.kdv)} ₺</span></div>
                  <div className="tut buyuk"><span>Genel Toplam</span>
                    <span>{para.format(toplam.genel)} ₺</span></div>
                </div>

                {/* KAYIT SONRASI ozet: protokol ve pay bolusumu SUNUCUDAN gelir -
                    kurum/hasta payi sozlesmeye gore orada hesaplanir (289). */}
                {sonuc && (
                  <div className="kabul-sonuc">
                    <span>Protokol: <b>{sonuc.belgeNo || '—'}</b></span>
                    <span>Genel toplam: <b>{para.format(sonuc.genelToplam)} ₺</b></span>
                    <span>Kurumdan: <b>{para.format(
                      Math.round((sonuc.genelToplam - hastaTahsil) * 100) / 100)} ₺</b></span>
                    {/* KDV DAHIL: kasada tahsil edilecek olan bu tutardir. */}
                    <span>Hastadan: <b>{para.format(hastaTahsil)} ₺</b></span>
                  </div>
                )}

                {/* Secili kagit: kayit BITINCE yuklenir; burada yalniz izlenir. */}
                {(kagit || kagitDurum) && (
                  <div className="kabul-kagit">
                    📎 {kagitDurum || `İstem kâğıdı: ${kagit?.name}`}
                    {kagit && !kagitDurum && (
                      <button type="button" className="d mini" title="Kaldır"
                              onClick={() => setKagit(null)}>✕</button>
                    )}
                  </div>
                )}

                <div className="not">
                  Kaydedince tek işlemde üç kayıt üretilir: <b>başvuru</b> (protokol),
                  tetkik başına <b>istem</b> (accession no) ve seçilirse <b>tahsilat</b>.
                  Kurum payı sözleşmeye göre ayrılır; kalan tutar hastadan tahsil edilir.
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* ISTEM KAGIDI dosya girdisi: capture ile telefonda dogrudan kamera,
          masaustunde tarayicinin kaydettigi dosya secilir. */}
      <input ref={kagitGirdi} type="file" hidden
             accept="image/*,application/pdf"
             capture="environment"
             onChange={e => {
               const d = e.target.files?.[0] ?? null;
               setKagit(d);
               setKagitDurum('');
               e.target.value = '';
             }} />

      {/* Odeyen kurum aramasi - kurum listesi (249). */}
      <TarafArama
        acik={odeyenArama}
        kaynaklar={['kurum']}
        yerTutucu="Ödeyen kurum ara…"
        onKapat={() => setOdeyenArama(false)}
        onSec={sec => {
          setOdeyenKurumId(sec.id);
          setOdeyenKurumAd(sec.unvan);
          setOdeyenArama(false);
        }}
      />

      {/* TAHSILAT: kasa islem karti, hasta payi ve basvuru onyuklu (mockup
          "Tahsilat Al ve Kabul Et"). Ayri bir tahsilat ekrani yazmak ayni
          kaydin iki yoldan uretilmesi olurdu. */}
      {tahsilatAcik && sonuc && (
        <KasaIslemKarti
          acilis={{
            tur: 21,
            tarafId: hastaId,
            tarafUnvan: hastaAdi,
            belgeId: sonuc.belgeId,
            tutar: String(hastaTahsil || sonuc.genelToplam),
          }}
          onKapat={() => setTahsilatAcik(false)}
        />
      )}

      {/* Dis hekim arama - jenerik taraf arama ekrani, kaynak 'dis-hekim'.
          enUst: bu modalin uzerinde acilmali. */}
      <TarafArama
        acik={hekimArama}
        kaynaklar={['dis-hekim']}
        yerTutucu="Dış hekimi ad / kurum ile ara…"
        onKapat={() => setHekimArama(false)}
        onSec={sec => {
          setDisHekimId(sec.id);
          setDisHekimSecim(sec.unvan);
          setDisHekimAd('');
          setHekimArama(false);
        }}
      />

      {/* Isteyen kurum - jenerik cari aramasi (hekim aramasiyla ayni desen). */}
      <TarafArama
        acik={kurumArama}
        kaynaklar={['cari']}
        yerTutucu="Kurum / cari ara…"
        onKapat={() => setKurumArama(false)}
        onSec={sec => {
          setIstekKurumId(sec.id);
          setIstekKurumAd(sec.unvan);
          setKurumArama(false);
        }}
      />
    </Modal>
  );
}
