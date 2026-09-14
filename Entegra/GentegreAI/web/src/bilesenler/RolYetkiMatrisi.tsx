import { useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import type { YetkiSatiri } from '../api/sozlesme';
import { hataMetni } from '../api/sozlesme';
import { LISTELER } from '../sayfalar/listeTanimlari';
import { useOturum } from '../kimlik/OturumBaglami';
import { ekKaydetKaydol } from './kartEkKaydet';

type Sutun = 'gor' | 'ekle' | 'degistir' | 'sil';
const SUTUNLAR: { ad: Sutun; baslik: string }[] = [
  { ad: 'gor', baslik: 'Gör' },
  { ad: 'ekle', baslik: 'Ekle' },
  { ad: 'degistir', baslik: 'Değiştir' },
  { ad: 'sil', baslik: 'Sil' },
];

/**
 * Menüde karşılığı olmayan yetkilerin toplandığı başlıklar (yetki.grup).
 *
 * 675'den sonra `yetki.grup` ZATEN menü grubudur; bu harita yalnız eski
 * kurulumlardan (betik uygulanmamış veritabanı) gelen kısa kodları çevirir -
 * tanımadığı bir grup gelirse grubun kendisi başlık olur.
 */
const GRUP_ADI: Record<string, string> = {
  kart: 'Kartlar', stok: 'Stok & Hizmet', belge: 'Belgeler', mali: 'Kasa & Muhasebe',
  ebelge: 'e-Belge', yonetim: 'Yönetim', genel: 'Genel',
};

/**
 * AKSIYON ONEKI -> MODUL KODU (676). Aksiyon yetkisi normalde kodunun
 * noktadan onceki parcasiyla modulune baglanir (lab.onay -> lab); bir grupta
 * onek modul koduyla ayni degildir (kasa.kapat -> kasa_islem). Bu satirlar
 * eslenmezse agacta modulun altina giremez, grubun dibinde tek basina durur.
 * Sunucudaki 669 betigi ayni esleseyi kullanir.
 */
const UST_KOD: Record<string, string> = {
  rad: 'radyoloji', kasa: 'kasa_islem', ebelge: 'e_belge', ceksenet: 'cek_senet',
  muhasebe: 'muhasebe_fis', fis: 'muhasebe_fis', basvuru: 'belge',
  veri: 'ayar', log: 'islem_log',
};

/** Menude listesi olmayan ama yetkisi olan ekranlar (kod -> agac grubu). */
const EK_GRUP: Record<string, string> = { panel: 'Ana Sayfa' };
const ANA_SAYFA = 'Ana Sayfa';

interface Dugum {
  anahtar: string;
  ad: string;
  /** Fare ustunde gorunen aciklama - yetki birden cok ekrani kapsiyorsa listesi. */
  ipucu?: string;
  ic?: string;
  /** Dolu ise yaprak: gerçek yetki satırı. Düğüm hem yaprak hem üst olabilir
      (ör. "ÜTS" modülü + altındaki uts.bildir / uts.iptal aksiyonları). */
  satir?: YetkiSatiri;
  cocuklar: Dugum[];
}

/**
 * Yetki kodu → menüdeki yeri: ekran ağacı ile yetki ağacı aynı görünsün.
 * ÜRÜN MODU (232) burada da geçerli: ERP'de "Kayıt Kabul" gibi HBYS'e özgü
 * ekranlar menüde yok, yetki ağacında da başlık açmazlar.
 */
function menuHaritasi(urunModu: number) {
  const harita = new Map<string, {
    grup: string; altGrup?: string; ic: string; ekranlar: string[];
    /** Ekran adları GRUBUYLA: aynı kod farklı gruplarda farklı ad taşır
        (`belge` = Kayıt Kabul'de "Başvurular", Satış'ta "Satış Faturaları"). */
    gruplu: { grup: string; ad: string }[];
  }>();
  /** Menü grubunun ikonu - grubun ilk ekranından. */
  const grupIkonu = new Map<string, string>();
  const grupSirasi: string[] = [];
  for (const l of LISTELER) {
    if (l.urunModu && l.urunModu !== urunModu) continue;
    if (l.menuGizli) continue;
    if (l.menuGrup && !grupSirasi.includes(l.menuGrup)) grupSirasi.push(l.menuGrup);
    if (l.menuGrup && l.ic && !grupIkonu.has(l.menuGrup)) grupIkonu.set(l.menuGrup, l.ic);
    if (!l.menuGrup) continue;
    // Ayni yetki kodu birden cok ekranda olabilir (belge -> teklif/siparis/
    //   fatura...): ILK ekranin yeri esas alinir, ekran ADLARININ hepsi
    //   toplanir - tek ekransa yaprak o adla cizilir (kullanici: "modul
    //   adlari menudeki adlarla ayni olsun").
    const v = harita.get(l.yetkiKodu);
    if (v) { v.ekranlar.push(l.menuAd); v.gruplu.push({ grup: l.menuGrup, ad: l.menuAd }) }
    else harita.set(l.yetkiKodu, {
      grup: l.menuGrup, altGrup: l.menuAltGrup, ic: l.ic, ekranlar: [l.menuAd],
      gruplu: [{ grup: l.menuGrup, ad: l.menuAd }],
    });
  }
  return { harita, grupSirasi, grupIkonu };
}

/** Düz yetki listesinden menü düzeninde ağaç kurar. */
function agacKur(satirlar: YetkiSatiri[], urunModu: number): Dugum[] {
  const { harita, grupSirasi, grupIkonu } = menuHaritasi(urunModu);
  const kokler: Dugum[] = [];
  const kokBul = (ad: string, ic?: string) => {
    let d = kokler.find(k => k.ad === ad);
    if (!d) { d = { anahtar: `g:${ad}`, ad, ic, cocuklar: [] }; kokler.push(d) }
    return d;
  };
  const altBul = (ust: Dugum, ad: string) => {
    let d = ust.cocuklar.find(k => k.ad === ad && !k.satir);
    if (!d) { d = { anahtar: `${ust.anahtar}/${ad}`, ad, cocuklar: [] }; ust.cocuklar.push(d) }
    return d;
  };

  // Alanlar savunmaci okunur: eski API surumu tur/grup gondermeyebilir.
  const guvenli = satirlar.map(s => ({ ...s, tur: s.tur ?? 0, grup: s.grup ?? '' }));
  // Delphi (eski program) yetkileri agacta GOSTERILMEZ - web urununde karsiligi yok.
  const yeni = guvenli.filter(s => !s.grup.startsWith('eski'));

  // 1) Modul yetkileri (kodunda '.' yok) grubuna yerlesir.
  //
  // GRUP SUNUCUDAN (684): sunucu grubu ZATEN menuden hesapliyor (682) ve ayni
  //   kod birden cok menu grubunda gecebiliyor - `personel` hem Cari > Dis
  //   Doktorlar hem IK > Personel Listesi ekranlarinin yetkisi. Ekran kendi
  //   kuralini uygulayinca (menude ilk gordugu yer) sunucuyla ayrisiyor ve
  //   yetki IK'da beklenirken Cari altinda cikiyordu. Tek karar yeri: sunucu.
  const modulDugumu = new Map<string, Dugum>();
  for (const s of yeni.filter(x => !x.kod.includes('.'))) {
    const yer = harita.get(s.kod);
    const grupAdi = EK_GRUP[s.kod] ?? GRUP_ADI[s.grup] ?? s.grup ?? yer?.grup ?? 'Diğer';
    const kok = kokBul(grupAdi,
                       grupIkonu.get(grupAdi) ?? yer?.ic
                       ?? (EK_GRUP[s.kod] ? '🏠' : undefined));
    const ust = yer?.altGrup ? altBul(kok, yer.altGrup) : kok;
    // AD, SATIRIN DURDUGU GRUPTAKI EKRANDAN (kullanici: "Kayıt Kabul altına
    //   sırayla Hasta Listesi, Başvurular ve İskonto Onayı gelmeli"): `belge`
    //   yetkisi hem basvurunun hem satis belgelerinin yetkisi; Kayit Kabul
    //   dalinda "Belgeler" degil BASVURULAR yazmali - kullanici oradaki
    //   ekranin adini arar. Grupta birden cok ekran varsa yetki adi kalir.
    const buGrupta = (yer?.gruplu ?? []).filter(x => x.grup === grupAdi);
    const d: Dugum = {
      anahtar: `y:${s.yetkiId}`,
      ad: buGrupta.length === 1 ? buGrupta[0].ad
        : yer?.ekranlar.length === 1 ? yer.ekranlar[0] : s.ad,
      ipucu: yer && yer.ekranlar.length > 1 ? `Ekranlar: ${yer.ekranlar.join(', ')}` : undefined,
      ic: yer?.ic, satir: s, cocuklar: [],
    };
    ust.cocuklar.push(d);
    modulDugumu.set(s.kod, d);
  }
  // 2) Aksiyon yetkileri (belge.kesinlestir, uts.bildir...) ait olduklari
  //    modulun ALTINA girer; modul yoksa kendi grubunda durur.
  for (const s of yeni.filter(x => x.kod.includes('.'))) {
    const onek = s.kod.slice(0, s.kod.indexOf('.'));
    const ustKod = UST_KOD[onek] ?? onek;
    const d: Dugum = { anahtar: `y:${s.yetkiId}`, ad: s.ad, satir: s, cocuklar: [] };
    const ustDugum = modulDugumu.get(ustKod);
    if (ustDugum) ustDugum.cocuklar.push(d);
    else kokBul(GRUP_ADI[s.grup] ?? s.grup ?? 'Diğer').cocuklar.push(d);
  }

  // Kokler menu sirasiyla; menude olmayan basliklar sonda.
  kokler.sort((a, b) => sira(a) - sira(b));
  function sira(d: Dugum) {
    if (d.ad === ANA_SAYFA) return -1;      // en basta (kullanici)
    const i = grupSirasi.indexOf(d.ad);
    return i >= 0 ? i : 1000 + kokler.indexOf(d);
  }
  return kokler;
}

/** Düğümün altındaki tüm yetki satırları (toplu işaretleme ve üç durumlu kutu için). */
function yapraklar(d: Dugum, biriktir: YetkiSatiri[] = []): YetkiSatiri[] {
  if (d.satir) biriktir.push(d.satir);
  for (const c of d.cocuklar) yapraklar(c, biriktir);
  return biriktir;
}

/**
 * Rol kartı "Yetki Matrisi" sekmesi. Kullanıcı: "menü yapımız gibi ağaç" -
 * yetkiler artık 900 satırlık düz liste değil, ekran menüsüyle AYNI düzende
 * (grup › alt grup › modül › aksiyon) katlanabilir ağaç. Grup satırındaki
 * kutu o dalın tamamını açar/kapatır (üç durumlu: hepsi / bazısı / hiç).
 * Kaydet YALNIZ değişen satırları gönderir.
 */
export function RolYetkiMatrisi({ rolId, saltOkunur }: { rolId: number; saltOkunur: boolean }) {
  const { kullanici } = useOturum();
  const [satirlar, setSatirlar] = useState<YetkiSatiri[] | null>(null);
  const [ilk, setIlk] = useState<Map<number, YetkiSatiri>>(new Map());
  const [yukleniyor, setYukleniyor] = useState(false);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);
  // Kullanici: matris VARSAYILAN KAPALI acilsin - istenen dal elle acilir.
  const [kapali, setKapali] = useState<Set<string>>(new Set());
  const [arama, setArama] = useState('');

  const yerlestir = (liste: YetkiSatiri[]) => {
    setSatirlar(liste);
    setIlk(new Map(liste.map(s => [s.yetkiId, s])));
  };

  useEffect(() => {
    setYukleniyor(true);
    setHata(null);
    api.rolYetkileri(rolId)
      .then(yerlestir)
      .catch(h => setHata(hataMetni(h)))
      .finally(() => setYukleniyor(false));
  }, [rolId]);

  // Agac aktif urun moduna gore kurulur (232).
  const agac = useMemo(() => (satirlar ? agacKur(satirlar, kullanici?.urunModu ?? 1) : []),
                       [satirlar, kullanici?.urunModu]);

  // Ilk yuklemede TUM dallar kapali (kullanici) - 900 satirlik agac acik
  //   gelirse ekran okunmuyordu.
  useEffect(() => {
    if (agac.length > 0) setKapali(new Set(agac.flatMap(k => tumAnahtarlar(k))));
  }, [agac]);

  /** Arama: eşleşen yaprakların id kümesi (atalar açık çizilir). */
  const suzgec = useMemo(() => {
    const q = arama.trim().toLocaleLowerCase('tr');
    if (!q || !satirlar) return null;
    return new Set(satirlar
      .filter(s => s.ad.toLocaleLowerCase('tr').includes(q)
                || s.kod.toLocaleLowerCase('tr').includes(q))
      .map(s => s.yetkiId));
  }, [arama, satirlar]);

  const degistir = (idler: Set<number>, sutun: Sutun, deger: boolean) => {
    setSatirlar(s => s?.map(satir => {
      if (!idler.has(satir.yetkiId)) return satir;
      // "Gör" kapatilirsa Ekle/Degistir/Sil de anlamsiz - birlikte kapanir.
      if (sutun === 'gor' && !deger)
        return { ...satir, gor: false, ekle: false, degistir: false, sil: false };
      // Ekle/Degistir/Sil acilirsa Gor otomatik acilir (gormeden islem olmaz).
      if (sutun !== 'gor' && deger) return { ...satir, gor: true, [sutun]: true };
      return { ...satir, [sutun]: deger };
    }) ?? s);
  };

  /**
   * SAYISAL SINIR (661): `deger_alir` yetkilerde satirin sonunda kucuk bir
   * kutu cizilir - 'basvuru.iskonto' icin iskonto tavani. Deger girilmis ama
   * izin kapaliysa sinir ise yaramaz; bu yuzden deger yazilinca "Gör" de
   * acilir (izin = yetkiyi kullanabilme).
   */
  const degerDegistir = (yetkiId: number, deger: string) => {
    setSatirlar(s => s?.map(satir => satir.yetkiId === yetkiId
      ? { ...satir, deger, gor: satir.gor || deger.trim() !== '' }
      : satir) ?? s);
  };

  /**
   * DEGISEN SATIRLAR: yalniz bunlar gider - 900+ satirin tamamini yollamak
   * hem gereksiz hem de her kaydette butun matrisi yeniden yazmak demekti.
   */
  const degisenler = useMemo(() => (satirlar ?? []).filter(s => {
    const o = ilk.get(s.yetkiId);
    return !o || o.gor !== s.gor || o.ekle !== s.ekle
        || o.degistir !== s.degistir || o.sil !== s.sil
        || (o.deger ?? '') !== (s.deger ?? '');
  }), [satirlar, ilk]);

  /**
   * KARTIN UST "Kaydet"INE BAGLAN (kullanici: "yetki matrisinde kayit kabul
   * isaretliyorum ama kayit olmuyor").
   *
   * Matrisin kendi Kaydet dugmesi vardi; kullanici kutulari isaretleyip
   * kartin ust Kaydet'ine basinca yalniz KART yaziliyor, matris sessizce
   * gidiyordu. "Yetkili Subeler" bolumunde ayni sorun ayni yoldan cozulmustu:
   * bolum degisikligini kuyruga birakir, kart Kaydet'i kuyrugu calistirir.
   */
  useEffect(() => {
    if (saltOkunur || degisenler.length === 0) return;
    ekKaydetKaydol(`rolYetki:${rolId}`, async () => {
      const guncel = await api.rolYetkiKaydet(rolId, degisenler.map(s => ({
        yetkiId: s.yetkiId, gor: s.gor, ekle: s.ekle, degistir: s.degistir,
        sil: s.sil, deger: s.deger ?? '',
      })));
      yerlestir(guncel);
    });
    return () => ekKaydetKaydol(`rolYetki:${rolId}`, null);
  }, [degisenler, rolId, saltOkunur]);

  const kaydet = async () => {
    if (!satirlar) return;
    setKaydediyor(true); setHata(null); setBilgi(null);
    try {
      const degisen = degisenler;
      if (degisen.length === 0) { setBilgi('Değişiklik yok.'); return }
      const guncel = await api.rolYetkiKaydet(rolId, degisen.map(s => ({
        yetkiId: s.yetkiId, gor: s.gor, ekle: s.ekle, degistir: s.degistir, sil: s.sil,
        deger: s.deger ?? '',
      })));
      yerlestir(guncel);
      setBilgi(`${degisen.length} yetki satırı kaydedildi.`);
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setKaydediyor(false);
    }
  };

  const ac = (anahtar: string) => setKapali(t => {
    const y = new Set(t);
    if (y.has(anahtar)) y.delete(anahtar); else y.add(anahtar);
    return y;
  });

  /** Bir düğümü ve altını çizer (arama varken eşleşmeyen dallar atlanır). */
  const cizDugum = (d: Dugum, derinlik: number): React.ReactNode[] => {
    const altSatirlar = yapraklar(d);
    if (suzgec && !altSatirlar.some(s => suzgec.has(s.yetkiId))) return [];
    const acik = !kapali.has(d.anahtar) || !!suzgec;
    const cocukVar = d.cocuklar.length > 0;
    const aksiyon = d.satir?.tur === 1;

    const kutu = (s: Sutun) => {
      // Yaprakta kendi degeri; ust dugumde daldaki TUM satirlarin ozeti.
      const hedef = d.satir && !cocukVar ? [d.satir] : altSatirlar;
      // Aksiyon yetkisinde yalniz izin (gor) anlamli.
      const uygun = hedef.filter(x => x.tur !== 1 || s === 'gor');
      if (uygun.length === 0) return <span style={{ opacity: .3 }}>–</span>;
      const acikSayi = uygun.filter(x => x[s]).length;
      const hepsi = acikSayi === uygun.length;
      return (
        <input type="checkbox" checked={hepsi} disabled={saltOkunur}
               ref={el => { if (el) el.indeterminate = acikSayi > 0 && !hepsi }}
               onChange={e => degistir(new Set(uygun.map(x => x.yetkiId)), s,
                                       e.target.checked)} />
      );
    };

    const satirlarJsx: React.ReactNode[] = [
      <tr key={d.anahtar} className={d.satir ? undefined : 'grup-satiri'}>
        <td style={{ paddingLeft: 6 + derinlik * 18 }}>
          {cocukVar ? (
            <button type="button" onClick={() => ac(d.anahtar)}
                    style={{ border: 0, background: 'transparent', cursor: 'pointer',
                             padding: '0 4px 0 0', fontSize: 11 }}>
              {acik ? '▾' : '▸'}
            </button>
          ) : <span style={{ display: 'inline-block', width: 15 }} />}
          {d.ic ? `${d.ic} ` : ''}
          <span style={{ fontWeight: d.satir ? 400 : 600 }} title={d.ipucu}>{d.ad}</span>
          {aksiyon && <span className="rozet gri" style={{ marginLeft: 6 }}>aksiyon</span>}
          {!d.satir && (
            <span style={{ opacity: .55, marginLeft: 6, fontSize: 12 }}>
              ({altSatirlar.length})
            </span>
          )}
        </td>
        {SUTUNLAR.map(s => (
          <td key={s.ad} style={{ textAlign: 'center' }}>{kutu(s.ad)}</td>
        ))}
        {/* SINIR: yalniz deger alan yetkide kutu; otekilerde bos hucre - ayri
            bir satir turu acmak agaci bozardi. */}
        <td style={{ textAlign: 'center' }}>
          {d.satir?.degerAlir ? (
            <input className="hiza-sag" style={{ width: 64 }}
                   value={d.satir.deger ?? ''} disabled={saltOkunur}
                   placeholder="—"
                   title={`${d.satir.ad} - sayısal sınır (boş / 0 = yetki yok)`}
                   onChange={e => degerDegistir(d.satir!.yetkiId, e.target.value)} />
          ) : <span style={{ opacity: .3 }}>–</span>}
        </td>
      </tr>,
    ];
    if (acik && cocukVar)
      for (const c of d.cocuklar) satirlarJsx.push(...cizDugum(c, derinlik + 1));
    return satirlarJsx;
  };

  return (
    <div className="kagrup">
      <h6>
        Yetki Matrisi
        {/* Degisiklik kartin UST Kaydet'ine baglidir; buradaki dugme yalniz
            "simdi yaz" kisayolu - kart kapatilmadan sonuc gorulsun. */}
        {!saltOkunur && degisenler.length > 0 && (
          <>
            <span className="rozet uyari">
              {degisenler.length} satır kaydedilmedi
            </span>
            <button type="button" className="d" disabled={kaydediyor || !satirlar}
                    onClick={() => void kaydet()}>
              {kaydediyor ? 'Kaydediliyor…' : 'Şimdi Kaydet'}
            </button>
          </>
        )}
      </h6>
      <div style={{ display: 'flex', gap: 8, alignItems: 'center', margin: '0 10px 8px' }}>
        {/* Listelerdeki oval arama kutusuyla ayni gorunum (kullanici). */}
        <div className="ara-kutu dar">
          <span>🔍</span>
          <input type="search"
            placeholder="Yetki ara…" value={arama}
            onChange={e => setArama(e.target.value)} />
        </div>
        <button type="button" className="d" onClick={() => setKapali(new Set())}>
          Tümünü Aç
        </button>
        <button type="button" className="d"
                onClick={() => setKapali(new Set(agac.flatMap(k => tumAnahtarlar(k))))}>
          Tümünü Kapat
        </button>
      </div>
      {hata && <div className="alan-hata" style={{ margin: '0 10px' }}>{hata}</div>}
      {bilgi && <div className="bilgi-kutusu" style={{ margin: '0 10px 10px' }}>{bilgi}</div>}
      <table className="detay-tablo">
        <thead>
          <tr>
            <th>Yetki</th>
            {SUTUNLAR.map(s => <th key={s.ad} style={{ textAlign: 'center', width: 80 }}>{s.baslik}</th>)}
            {/* SINIR (661): sayisal deger alan yetkiler icin - ornegin
                "Başvuruda iskonto" tavani. Otekilerde hucre bos kalir. */}
            <th style={{ textAlign: 'center', width: 90 }}
                title="Sayısal sınır - yalnız değer alan yetkilerde (ör. iskonto tavanı %)">
              Sınır
            </th>
          </tr>
        </thead>
        <tbody>
          {yukleniyor && <tr><td colSpan={5}>Yükleniyor…</td></tr>}
          {!yukleniyor && satirlar?.length === 0 && (
            <tr><td colSpan={5} className="bos">Tanımlı yetki yok.</td></tr>
          )}
          {agac.flatMap(k => cizDugum(k, 0))}
        </tbody>
      </table>
    </div>
  );
}

function tumAnahtarlar(d: Dugum, biriktir: string[] = []): string[] {
  if (d.cocuklar.length > 0) { biriktir.push(d.anahtar); d.cocuklar.forEach(c => tumAnahtarlar(c, biriktir)) }
  return biriktir;
}
