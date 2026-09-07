import { useEffect, useState } from 'react';
import { Modal } from './Modal';
import { StokAramaPenceresi } from './StokAramaPenceresi';
import { TarafArama } from './TarafArama';
import { tarafSecimEngeli } from './tarafSecimEngeli';
import { detayHucreMetni } from './detayGorunum';
import { api } from '../api/istemci';
import { GridMenu, type MenuOgesi } from './grid/GridMenu';
import { dosyaIndirUrl } from './indir';
import type { DetayFarki, KartAlanMeta, KartDetayMeta } from '../api/sozlesme';
import { useYerler, VARSAYILAN_ULKE } from './yerlerHook';
import { TelefonGirdi } from './TelefonGirdi';
import { telefonAlaniMi, telefonGecerliMi } from './alanBicim';

export type Satir = Record<string, unknown> & { id?: number };

/**
 * Detay tablosunun duzenleme durumu. Sunucuya TAM LISTE degil FARK gonderilir
 * (§3.2), bu yuzden ilk hal ile guncel hal birlikte tutulur.
 */
export interface DetayDurumu {
  ilk: Satir[];        // karttan geldigi hali
  guncel: Satir[];     // ekranda duzenlenmis hali
  silinen: number[];   // kaldirilan mevcut satirlarin id'leri
}

export const bosDetay = (satirlar: Satir[] = []): DetayDurumu => ({
  ilk: satirlar.map(s => ({ ...s })),
  guncel: satirlar.map(s => ({ ...s })),
  silinen: [],
});

/**
 * Ekrandaki durumdan sunucunun bekledigi fark listesini uretir.
 *
 * `izinliAlanlar` verilirse satirdaki BASKA anahtarlar ELENIR: gride yalniz
 * gosterim icin konan alanlar (or. kampanya urun satirindaki `iskontoYeriAdi`)
 * sunucuya gidince "Bilinmeyen alan" hatasi veriyordu.
 */
export function detayFarki(durum: DetayDurumu,
                           izinliAlanlar?: readonly string[]): DetayFarki {
  const izinli = izinliAlanlar ? new Set([...izinliAlanlar, 'id']) : null;
  const suz = (s: Satir): Satir => (izinli
    ? Object.fromEntries(Object.entries(s).filter(([k]) => izinli.has(k))) as Satir
    : s);
  // YENI satirda BOS birakilan alan HIC GONDERILMEZ (GenForm'daki kuralin
  //   detay karsiligi): bos metin NOT NULL + varsayilanli kolonlarda
  //   "birim bos birakilamaz" gibi hatalara yol aciyordu. Gonderilmeyince
  //   veritabani varsayilani devreye girer.
  const eklenen = durum.guncel
    .filter(s => s.id === undefined || s.id === null)
    .map(s => Object.fromEntries(
      Object.entries(suz(s)).filter(([, v]) => v !== '' && v !== null && v !== undefined)) as Satir);

  const degisen = durum.guncel
    .filter(s => s.id !== undefined && s.id !== null)
    .map(s => {
      const eski = durum.ilk.find(i => i.id === s.id);
      if (!eski) return null;
      // Yalniz gercekten degisen alanlar gonderilir
      const fark: Satir = { id: s.id };
      let degisti = false;
      Object.keys(suz(s)).forEach(alan => {
        if (alan === 'id') return;
        if (String(s[alan] ?? '') !== String(eski[alan] ?? '')) { fark[alan] = s[alan]; degisti = true }
      });
      return degisti ? fark : null;
    })
    .filter(Boolean) as Satir[];

  return {
    eklenen: eklenen.length ? eklenen : undefined,
    degisen: degisen.length ? degisen : undefined,
    silinen: durum.silinen.length ? durum.silinen : undefined,
  };
}

interface Props {
  meta: KartDetayMeta;
  durum: DetayDurumu;
  saltOkunur: boolean;
  hatalar: Record<string, string>;
  onDegis(yeni: DetayDurumu): void;
  /** Kutuya eklenecek ek sinif (yerlesim ince ayari; ör. daha dar ust bosluk). */
  kutuSinif?: string;
  /**
   * KART DEGERINE GORE gizlenen detay alanlari (ör. prim zamani
   * "Faturalamada" ise satirdaki Tahsilat Türü). Alan katalogda duruyor ve
   * kayitli degeri korunuyor - yalniz cizilmiyor: o kriterin ANLAMSIZ oldugu
   * durumda kullaniciya sorulmasi, uygulanmayan bir ayar uretir.
   */
  gizliAlanlar?: ReadonlySet<string>;
  /**
   * DUZ METIN cizilen alanlar: kutu/combo yerine degerin kendisi. Satirin
   * KIMLIGINI tasiyan ve sunucunun yazdigi alanlar icindir (ör. fizik muayene
   * satirindaki "Sistem" - satirlar sablondan acilir, hekim yalniz normal
   * isaretini ve bulgu metnini girer). Kapali combo da ayni isi gorurdu ama
   * "burasi degistirilebilir" izlenimi birakiyordu.
   */
  etiketAlanlari?: ReadonlySet<string>;
  /**
   * SADE GRID: cerceve, baslik seridi ("+ Satır" dahil) ve satir sonundaki
   * silme dugmesi CIZILMEZ - satirlarin nereden geldigi ekranin isi degilse
   * (fizik muayene satirlari sablondan acilir) bunlar yanlis vaat ve
   * kalabalik. Hucreler yine duzenlenebilir.
   */
  sadeGrid?: boolean;
  /**
   * SATIR EKLEME KAPALI: başlıktaki "＋" çizilmez. Satırın anahtarını ekran
   * değil SUNUCU koyuyorsa (tanıda ICD kodu "＋ ICD-10 Ekle" ucundan gelir)
   * boş satır açmak yarım kayıt üretirdi.
   */
  ekleGizli?: boolean;
  /**
   * Arama pencerelerinin KAYNAKLARINI daraltir (ör. prim planinin rolu
   * "Gönderen" degilse dis hekimler hic listelenmesin). Alanin kendi
   * `aramaKaynagi` degerini EZER; verilmezse o kullanilir.
   */
  aramaKaynaklari?: readonly string[];
  /** Arama penceresine EKLENEN sabit kosul (ör. prim planinin rolu). */
  aramaEkFiltre?: { alan: string; op: 'esit'; deger: string | number };
  /**
   * SATIR MODALININ ALTINA cizilen ek bilesen (388: prim satirinin
   * KADEMELERI). Detayin DETAYI icindir - kart cercevesi torun seviyesini
   * baglamaz, ama kullanici o satiri duzenlerken cocugunu da gormeli.
   * Satir henuz kaydedilmemisse `null` gelir; bilesen buna gore uyarir.
   */
  modalAltBilesen?: (satirId: number | null) => React.ReactNode;
  /** Baslik ve satir eylemleri IKON olarak cizilir (＋ / ✎ / 🗑) - seri ve XSLT
      gridleriyle ayni gorunum (kullanici). Metin dugmeler dar gridlerde
      satiri tasiriyordu. */
  ikonlu?: boolean;
  /** GRID SALT GORUNUM, duzenleme MODALDE (kullanici). Satir ici duzenlemede
      hangi hucrenin degistigi kaybolabiliyordu; modal alanlari etiketleriyle
      birlikte gosterir. Veri akisi degismez - degisiklik yine kartin
      Kaydet'iyle gider. */
  modalDuzenle?: boolean;
  /** Modal taslaginda bir alan degisince EKRAN kurali calistirir: donen
      alanlar taslagin ustune yazilir (ör. fiyat listesi satirinda carpan
      degisince fiyat = taban x carpan ve Yazim = Manuel). Boylece turetilen
      alanlar da Kaydet'le sunucuya gider ve islem loguna girer; DB tetigi
      ayni kurali son otorite olarak yine uygular. */
  taslakKural?: (alan: string, deger: unknown,
                 taslak: Record<string, unknown>) => Record<string, unknown> | null;
  /** Baslik seridine suzme cipleri (listelerin Aktif/Pasif cipleri gibi).
      Ilk cip varsayilan seciliyor; suzme yalniz gorunumu daraltir. */
  cipler?: { ad: string; suz: (satir: Record<string, unknown>) => boolean }[];
}

// Adresler grid'ine ozel kolon genislikleri (kullanici: "Adres geniş, İl/İlçe aynı
// genişlik, Ülke ... dar, PK çok dar"). Diger detay tablolari (stok_izleme vb.) bundan
// etkilenmez - sadece meta.ad==='adresler' iken colgroup basılır.
const ADRES_GENISLIK: Record<string, string> = {
  tur: '12%', adres: '30%', il: '13%', ilce: '13%', ulke: '10%',
  postaKodu: '7%', varsayilan: '7%', aktif: '7%',
};

const DIPLOMA_ADLARI = [
  'İlkokul',
  'Ortaokul',
  'Lise',
  'Ön Lisans (Yüksek Okul)',
  'Lisans',
  'Yüksek Lisans (Master)',
  'Doktora',
];

const EGITIM_GECERLILIK = ['Süresiz', 'Süreli'];

const tarihYilTemizle = (deger: string) => deger.replace(/[^0-9./-]/g, '').slice(0, 10);

/** Iki tarih arasi GUN (iki uc dahil): 01.09 - 05.09 => 5 gun. */
function gunFarki(bas: string, bit: string): number | null {
  if (!bas || !bit) return null;
  const b = new Date(bas.slice(0, 10)); const s = new Date(bit.slice(0, 10));
  if (Number.isNaN(b.getTime()) || Number.isNaN(s.getTime())) return null;
  const fark = Math.round((s.getTime() - b.getTime()) / 86400000) + 1;
  return fark > 0 ? fark : null;
}

export function GenDetayTablo({ meta, durum, saltOkunur, hatalar, onDegis, ikonlu,
                               modalDuzenle, taslakKural, cipler, kutuSinif,
                               gizliAlanlar, etiketAlanlari, sadeGrid, ekleGizli,
                               aramaKaynaklari, aramaEkFiltre,
                               modalAltBilesen }: Props) {
  /**
   * KAMPANYA SATIRI (268): "Kapsam" TEK kolondur (iskonto_yeri_id) ama
   * anlami satirin TIPINE gore degisir - Liste'de 0, Kategori'de kategori id,
   * Ürün'de stok/hizmet id. Bu yuzden hucre tipe gore cizilir: kategoride
   * combo, urunde stok/hizmet arama penceresi, listede kapali.
   * Kategoriler az sayida (15) - bir kez cekilip bellekte tutulur; stok/hizmet
   * binlerce oldugu icin ORADA combo degil arama penceresi kullanilir.
   */
  const kampanyaSatiri = meta.ad === 'satirlar' && meta.alanlar.some(a => a.ad === 'iskontoYeriId');

  /**
   * PRIM PLAN SATIRI (327): hedef UC ayri alandir - hizmet, kategori,
   * modalite. Kategori/modalite az sayida oldugu icin combo (alanin kendi
   * kodlariyla), HIZMET binlerce oldugu icin arama penceresiyle secilir -
   * kampanya urun satiriyla ayni gerekce.
   */
  // TESPIT 'rol' ALANINA BAGLANMAZ (379): rol satirdan plan basligina tasindi
  //   ve bu kontrol sessizce yanlisa dondu - prim satiri gridi kendini FIYAT
  //   LISTESI sanip Tip/Kategori/Kod/Adı kolonlarini cizmeye basladi.
  //   Satirin kendi alanlari kullanilir: hedef + oran.
  const primSatiri = meta.ad === 'satirlar'
                     && meta.alanlar.some(a => a.ad === 'hedefId')
                     && meta.alanlar.some(a => a.ad === 'oranTipi');

  /**
   * KAYITLI urun satirinda ad (268): sunucu yalniz id tasir, kart acilinca
   * hucrede "4262" gorunuyordu - hangi hizmet oldugu okunamiyordu. Adlar
   * id -> ad sozlugunde tutulur; secim aninda satira yazilan `iskontoYeriAdi`
   * onceliklidir (yeni secim hemen gorunur).
   */
  const [urunAdlari, setUrunAdlari] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!kampanyaSatiri) return;
    // Adi bilinmeyen URUN satirlari: stok ve hizmet ayri kaynaklardan gelir.
    const eksik = durum.guncel
      .filter(r => Number(r.tip) === 3 && r.iskontoYeriId && !r.iskontoYeriAdi
                   && !urunAdlari[String(r.iskontoYeriId)])
      .map(r => ({ id: Number(r.iskontoYeriId), hizmet: Number(r.kalemTuru) === 2 }));
    if (eksik.length === 0) return;

    let iptal = false;
    void (async () => {
      const yeni: Record<string, string> = {};
      for (const kaynak of ['stok', 'hizmet'] as const) {
        const idler = eksik.filter(e => (kaynak === 'hizmet') === e.hizmet).map(e => e.id);
        if (idler.length === 0) continue;
        try {
          const y = await api.liste(kaynak, {
            sayfa: 1, boyut: idler.length,
            filtre: { op: 'or', kosullar: idler.map(id => ({ alan: 'id', op: 'esit', deger: id })) },
          });
          y.satirlar.forEach(r => {
            yeni[String(r.id)] = `${String(r.kod ?? '')} ${String(r.ad ?? '')}`.trim();
          });
        } catch { /* ad cozulemezse id gorunur - satir yine calisir */ }
      }
      if (!iptal && Object.keys(yeni).length) setUrunAdlari(m => ({ ...m, ...yeni }));
    })();
    return () => { iptal = true };
  // urunAdlari bilerek bagimlilikta degil: sozluk buyudukce dongu olurdu.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kampanyaSatiri, durum.guncel]);

  // PRIM (328): URUN kapsamli satirda kalemin ADI - hucrede id okunmaz.
  useEffect(() => {
    if (!primSatiri) return;
    const eksik = durum.guncel
      .filter(r => Number(r.tip) === 3 && Number(r.hedefId) > 0
                   && !urunAdlari[String(r.hedefId)])
      .map(r => ({ id: Number(r.hedefId), hizmet: Number(r.kalemTuru) !== 1 }));
    if (eksik.length === 0) return;

    let iptal = false;
    void (async () => {
      const yeni: Record<string, string> = {};
      for (const kaynak of ['stok', 'hizmet'] as const) {
        const idler = eksik.filter(e => (kaynak === 'hizmet') === e.hizmet).map(e => e.id);
        if (idler.length === 0) continue;
        try {
          const y = await api.liste(kaynak, {
            sayfa: 1, boyut: idler.length,
            filtre: { op: 'or', kosullar: idler.map(id => ({ alan: 'id', op: 'esit', deger: id })) },
          });
          y.satirlar.forEach(r => {
            yeni[String(r.id)] = `${String(r.kod ?? '')} ${String(r.ad ?? '')}`.trim();
          });
        } catch { /* ad cozulemezse id gorunur */ }
      }
      if (!iptal && Object.keys(yeni).length) setUrunAdlari(m => ({ ...m, ...yeni }));
    })();
    return () => { iptal = true };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [primSatiri, durum.guncel]);

  /**
   * KATEGORI SECENEKLERI (328, kullanici: "kategori combo hizmet/stok
   * secimine gore"). Kategori tablosu stok ve hizmet icin ORTAK; hangisinde
   * kullanildigi ancak SAYIMLA anlasilir - kategori LISTESI bu iki sayimi
   * zaten donduruyor, o yuzden kod tablosu yerine liste ucundan cekilir.
   */
  const [kategoriler, setKategoriler] = useState<
    { id: number; ad: string; stok: number; hizmet: number }[]>([]);

  useEffect(() => {
    if (!primSatiri) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('kategori', { sayfa: 1, boyut: 500 });
        if (!iptal) setKategoriler(y.satirlar.map(r => ({
          id: Number(r.id),
          // Kod + ad: kampanyadaki kategori combosuyla ayni okunus ("K1 - Genel").
          ad: `${String(r.kod ?? '')} ${String(r.ad ?? '')}`.trim(),
          stok: Number(r.stokSayisi ?? 0), hizmet: Number(r.hizmetSayisi ?? 0),
        })));
      } catch { /* liste alinamazsa kategori combosu bos kalir */ }
    })();
    return () => { iptal = true };
  }, [primSatiri]);

  /**
   * KAMPANYA (268, kullanici): "İskonto Tipi yüzde ise başlıkta İskonto %,
   * tutar ise Tutar yazacak". Baslik kolon basinadir, satir basina degil -
   * satirlarin HEPSI ayni tipteyse ona gore yazilir, karisikta genel ad kalir.
   */
  const kolonBasligi = (a: KartAlanMeta) => {
    if (!kampanyaSatiri || a.ad !== 'iskonto') return a.baslik;
    const tipler = new Set(durum.guncel.map(x => Number(x.iskontoTipi) || 0));
    if (tipler.size === 1 && tipler.has(1)) return 'İskonto %';
    if (tipler.size === 1 && tipler.has(2)) return 'Tutar';
    return a.baslik;
  };
  const [urunAramaSatiri, setUrunAramaSatiri] = useState<number | null>(null);
  /**
   * TARAF ARAMASIYLA SATIR EKLEME (375). Detayda `aramaKaynagi` tanimli bir
   * KOD alani varsa (ör. prim planinin "Prim Alanlar" sekmesindeki Kişi),
   * grid basligina bir arama dugmesi gelir: pencere ACIK KALIR, her Enter
   * yeni bir satir ekler. Combo ile 30 kisi eklemek her seferinde listeyi
   * acip kaydirmak demekti.
   */
  const [tarafAramaAcik, setTarafAramaAcik] = useState(false);
  const alanlar = meta.alanlar.filter(a => a.ad !== 'id' && !gizliAlanlar?.has(a.ad));
  const yerler = useYerler(meta.ad === 'adresler');
  const adresGrid = meta.ad === 'adresler';
  const acilKisiGrid = meta.ad === 'acilKisiler';
  const ilAdIdHarita = new Map((yerler?.iller ?? []).map(i => [i.ad, i.id]));

  /** Secili satir (modalDuzenle kipinde): ustteki ✎ / 🗑 buna uygulanir. */
  const [secili, setSecili] = useState<number | null>(null);
  /** Modalde acik satirin indeksi ("yeni" = eklenecek satir). */
  const [modalSatir, setModalSatir] = useState<number | 'yeni' | null>(null);
  /** Modalde duzenlenen taslak - Tamam'a basilana kadar tabloya yazilmaz. */
  const [taslak, setTaslak] = useState<Record<string, unknown>>({});
  /** Grid ici arama (listedeki "Bu listede ara" gibi) - buyuk detay gridleri. */
  const [arama, setArama] = useState('');
  /** Aktif suzme cipi (cipler verilmisse; 0 = ilk cip). */
  const [aktifCip, setAktifCip] = useState(0);
  /** Uc nokta menusu (satirlar gridi): konum + gizlenen kolonlar (oturumluk). */
  const [menuKonum, setMenuKonum] = useState<{ x: number; y: number } | null>(null);
  const [gizliKolonlar, setGizliKolonlar] = useState<Set<string>>(new Set());

  /** Salt gorunum hucresi - kural `detayGorunum.ts`'te (saf, testli). */
  const gorunum = (satir: Record<string, unknown>, a: typeof alanlar[number]) =>
    detayHucreMetni(satir, a);


  const modalAc = (i: number | 'yeni') => {
    setTaslak(i === 'yeni' ? bosSatir() : { ...durum.guncel[i] });
    setModalSatir(i);
  };

  /** Modal taslagina yazar; varsa ekran kuralinin turettigi alanlari da isler. */
  const taslakYaz = (alan: string, deger: unknown) =>
    setTaslak(t => {
      const yeni = { ...t, [alan]: deger };
      return { ...yeni, ...(taslakKural?.(alan, deger, yeni) ?? {}) };
    });

  const modalKaydet = () => {
    if (modalSatir === null) return;
    const guncel = modalSatir === 'yeni'
      ? [...durum.guncel, taslak]
      : durum.guncel.map((s, i) => (i === modalSatir ? taslak : s));
    onDegis({ ...durum, guncel });
    setModalSatir(null);
  };

  /**
   * Satirda BIR ya da BIRDEN COK alani birlikte gunceller.
   *
   * Coklu yazim SART: hucreDegis'i arka arkaya iki kez cagirmak ikinci
   * cagrida hala ESKI `durum`u okur (state bu render'da degismez) ve ilk
   * yazimi ezer - kampanya urun secimi (id + kalem turu) bu yuzden satira
   * hic islenmiyordu.
   */
  const satirDegis = (satirIndeks: number, degisiklikler: Record<string, unknown>) => {
    const [alan, deger] = Object.entries(degisiklikler)[0] ?? ['', undefined];
    const guncel = durum.guncel.map((s, i) => {
      if (meta.ad === 'acilKisiler' && alan === 'varsayilan' && (deger === true || Number(deger) === 1)) {
        return { ...s, varsayilan: i === satirIndeks ? 1 : 0 };
      }
      if (i !== satirIndeks) return s;
      const yeni = { ...s, ...degisiklikler };
      // IZINLERDE gun sayisi elle girilmez: baslangic/bitis degisince
      //   (iki uc dahil) hesaplanir.
      if (meta.ad === 'izinler' && (alan === 'baslangicTarihi' || alan === 'bitisTarihi')) {
        const g = gunFarki(String(yeni.baslangicTarihi ?? ''), String(yeni.bitisTarihi ?? ''));
        if (g !== null) yeni.gun = g;
      }
      // KAMPANYA (268, kullanici): iskonto tipi TUTAR ise doviz varsayilan
      //   YEREL PARA; YÜZDE ise doviz anlamsizdir (yuzde birimsizdir) - alan
      //   temizlenir ve hucre "%" gosterir.
      if (kampanyaSatiri && 'iskontoTipi' in degisiklikler) {
        yeni.dovizCinsi = Number(degisiklikler.iskontoTipi) === 2
          ? (yeni.dovizCinsi || 'TL') : '';
      }
      return yeni;
    });
    onDegis({ ...durum, guncel });
  };

  const hucreDegis = (satirIndeks: number, alan: string, deger: unknown) =>
    satirDegis(satirIndeks, { [alan]: deger });

  // Adresler'de acik (Adres Tipi secilmemis) satir varken yeni satir eklenemez (kullanici:
  // "adres te fatura tipi seçilmeden yeni satır açılmasın" - Adres Tipi kastediliyor).
  const acikAdresSatiriVar = adresGrid && durum.guncel.some(s => !s.tur);
  // 1:1 detayda (249, ör. kurum sozlesme basligi) tek satir: PK ust kayitla
  //   ayni oldugu icin ikinci satir DB'ye yazilamaz - dugmeyi hic acmayalim.
  const tekSatirDolu = !!meta.tekSatir && durum.guncel.length >= 1;
  const satirEklenebilir = !saltOkunur && !acikAdresSatiriVar && !tekSatirDolu;

  // Detayin "arama ile secilen" alani: tipi kod + aramaKaynagi dolu.
  const tarafAlani = alanlar.find(a => a.tip === 'kod' && a.aramaKaynagi);

  /** Yeni satirin baslangic degerleri - satir ici ve modal ekleme ayni kumeyi kullanir. */
  const bosSatir = (): Record<string, unknown> => Object.fromEntries(
    alanlar.map(a => [a.ad, a.tip === 'mantik' ? 0 : '']));

  const satirEkle = () => {
    if (acikAdresSatiriVar) return;
    const yeni: Satir = {};
    // "aktif"/"durum" alani yeni satirda ACIK baslar: kullanici bir kayit
    //   eklerken onu pasif olsun diye eklemez. Kapali baslayinca (banka subesi
    //   ornegi) satir kaydediliyor ama secim listelerinde HIC gorunmuyordu.
    //   Iki ad da ayni isi yapiyor - kampanya satirinda kolon "durum" oldugu
    //   icin eski kontrol kaciriyor, her satirda elle isaretlemek gerekiyordu.
    alanlar.forEach(a => {
      yeni[a.ad] = a.tip === 'mantik' ? (a.ad === 'aktif' || a.ad === 'durum' ? 1 : 0) : '';
    });
    if (meta.ad === 'adresler') {
      yeni.ulke = VARSAYILAN_ULKE;
      // Ilk satir (henuz hic adres yok) - Adres Tipi varsayilan "Fatura" (kullanici:
      // "cari kart adres eklemede ilk satır ise adres tipi Fatura olsun"). Bu grid SADECE
      // Cari'de kullaniliyor (Kisi'nin adresi TekAdres.tsx, ayri bilesen) - 1="Fatura"
      // guvenli (AdresTurKodlari).
      if (durum.guncel.length === 0) yeni.tur = '1';
    }
    if (meta.ad === 'egitimler') {
      yeni.tur = '1'; // Diploma
      yeni.gecerlilik = 'Süresiz';
    }
    if (meta.ad === 'acilKisiler' && durum.guncel.length === 0) {
      yeni.varsayilan = 1;
    }
    // KAMPANYA satiri (268): en sik kurulan satir "tum listeye yuzde indirim".
    //   Zorunlu iki kod alani bos aciliyor ve Kaydet'te hata veriyordu.
    if (kampanyaSatiri) {
      yeni.tip = '1';          // Liste
      yeni.kalemTuru = '0';    // Farketmez (stok + hizmet)
      yeni.iskontoTipi = '1';  // Yuzde - doviz alani "%" olarak cizilir
    }
    onDegis({ ...durum, guncel: [...durum.guncel, yeni] });
  };

  const satirSil = (satirIndeks: number) => {
    const satir = durum.guncel[satirIndeks];
    const guncel = durum.guncel.filter((_, i) => i !== satirIndeks);
    const silinen = satir.id != null ? [...durum.silinen, satir.id] : durum.silinen;
    onDegis({ ...durum, guncel, silinen });
  };

  // Suzme YALNIZ gorunumu daraltir: indeksler ORIJINAL diziden gider ki
  //   duzenle/sil dogru satira uygulansin. Buyuk gridlerde (fiyat listesi
  //   satirlari) bu kutu listedeki "Bu listede ara"nin karsiligidir.
  // FIYAT LISTESI SATIRLARI gridi (meta.ad 'satirlar', modal kip): Stok ve
  //   Hizmet lookup'lari iki ayri kolon yerine TIP IKONU + tek "Adı" kolonu
  //   (kullanici) - belge kalem gridiyle ayni okuma. Modal duzenlemede iki
  //   secim kutusu ayri durur; yalniz GRID gorunumu birlesir.
  /**
   * FIYAT LISTESI SATIRLARI gridi. "satirlar" adini PRIM ve KAMPANYA detaylari
   * da tasiyor; bu bayrak fiyat listesine OZEL cizimi (Tip/Kategori/Kod/Adı
   * kolonlari, hizli fiyat hucreleri, KDV-durum rozetleri) actigi icin
   * onlari DISARIDA birakir - yoksa prim satiri gridine ait olmayan dort
   * kolon eklenirdi.
   */
  const satirlarGrid = !!modalDuzenle && meta.ad === 'satirlar'
                       && !primSatiri && !kampanyaSatiri;
  const stokAlani   = alanlar.find(a => a.ad === 'stokId');
  const hizmetAlani = alanlar.find(a => a.ad === 'hizmetId');
  const tumGridAlanlari = satirlarGrid
    ? alanlar.filter(a => a.ad !== 'stokId' && a.ad !== 'hizmetId'
                          // Kategori ve Kod, Tip'in hemen saginda ELLE cizilir
                          //   (kullanici) - listenin sonunda tekrar cikmasin.
                          && a.ad !== 'kategoriYolu' && a.ad !== 'kalemKodu')
    : alanlar;
  const gridAlanlari = tumGridAlanlari.filter(a => !gizliKolonlar.has(a.ad));
  /** Rozet cizilecek kolonlar (satirlar gridi): KDV ve Durum. */
  const rozetHucresi = (ad: string) =>
    satirlarGrid && (ad === 'kdvDahil' || ad === 'durum');

  /** Rozet rengi: Aktif/Dahil yesil, Pasif gri, oteki notr. */
  const rozetSinifi = (ad: string, metin: string) => {
    const m = metin.toLocaleLowerCase('tr');
    if (ad === 'durum') return m.startsWith('aktif') ? 'ok' : 'gri';
    return m.includes('dahil') ? 'mor' : 'gri';
  };

  const kalemAdi = (satir: Record<string, unknown>) =>
    satir.stokId != null && satir.stokId !== '' && stokAlani
      ? gorunum(satir, stokAlani)
      : hizmetAlani ? gorunum(satir, hizmetAlani) : '';

  // UC NOKTA MENUSU (satirlar gridi): kolon goster/gizle (oturumluk) + CSV.
  //   Listelerin menusuyle ayni cizim (GridMenu); ogeler grid'e ozgu.
  const csvIndir = () => {
    const b = [
      ...(satirlarGrid ? ['Tip', 'Kategori', 'Kod', 'Adı'] : []),
      ...gridAlanlari.map(a => a.baslik),
    ].join(';');
    const govde = gorunurler.map(({ satir }) => [
      ...(satirlarGrid
        ? [satir.stokId != null && satir.stokId !== '' ? 'Stok' : 'Hizmet',
           String(satir.kategoriYolu ?? ''), String(satir.kalemKodu ?? ''), kalemAdi(satir)]
        : []),
      ...gridAlanlari.map(a => gorunum(satir, a).replace(/;/g, ',')),
    ].join(';')).join('\n');
    const url = URL.createObjectURL(new Blob(['﻿' + b + '\n' + govde],
      { type: 'text/csv;charset=utf-8' }));
    dosyaIndirUrl(url, `${meta.baslik}.csv`, true);
  };
  const menuOgeleri: MenuOgesi[] = [
    { ik: '📄', ad: 'CSV Kaydet', fn: csvIndir },
    ...tumGridAlanlari.map((a, i) => ({
      ik: gizliKolonlar.has(a.ad) ? '☐' : '☑',
      ad: a.baslik, secili: !gizliKolonlar.has(a.ad), ayrac: i === 0,
      fn: () => setGizliKolonlar(t => {
        const y = new Set(t);
        if (y.has(a.ad)) y.delete(a.ad); else y.add(a.ad);
        return y;
      }),
    })),
    { ik: '↺', ad: 'Tüm Kolonlar', fn: () => setGizliKolonlar(new Set()) },
  ];

  /**
   * HIZLI FIYAT GIRISI (kullanici): satirlar gridinde Fiyat hucresi satir ici
   * kutudur - Enter/asagi ok degeri isler ve BIR ALT gorunur satirin fiyatina
   * gecer (Excel akisi). Deger islenirken ekran kurali da kosar (taslakKural
   * 'fiyat' dali: Manuel + carpan geri hesabi); kayit yine kartin Kaydet'iyle.
   */
  const fiyatHucreIsle = (satirIndeks: number, metin: string, alan = 'fiyat') => {
    const eski = durum.guncel[satirIndeks];
    const yeni = metin.trim().replace(',', '.');
    if (yeni === '' || String(eski[alan] ?? '') === yeni) return;
    const n = Number(yeni);
    if (!Number.isFinite(n) || n < 0) return;
    // Ekran kurali YALNIZ fiyata bagli (Manuel + carpan geri hesabi); katilim
    //   payi (291) fiyatlama zincirine girmez, dogrudan yazilir.
    const kural = alan === 'fiyat'
      ? taslakKural?.('fiyat', yeni, { ...eski, fiyat: yeni }) ?? {}
      : {};
    onDegis({
      ...durum,
      guncel: durum.guncel.map((s, x) => (x === satirIndeks ? { ...s, [alan]: yeni, ...kural } : s)),
    });
  };

  /** Satir ici hizli giris yapilan kolonlar: fiyat ve katilim payi (291). */
  const hizliHucre = (ad: string) => ad === 'fiyat' || ad === 'katkiTutar';

  const aramaAnahtari = arama.trim().toLocaleLowerCase('tr');
  const cipSuz = cipler?.[aktifCip]?.suz;
  const gorunurler = durum.guncel
    .map((satir, i) => ({ satir, i }))
    .filter(({ satir }) => !cipSuz || cipSuz(satir))
    .filter(({ satir }) => !aramaAnahtari
      || alanlar.some(a => gorunum(satir, a).toLocaleLowerCase('tr').includes(aramaAnahtari)));
  const aramaVar = modalDuzenle && (durum.guncel.length > 20 || arama !== '');

  return (
    <div className={`kagrup${sadeGrid ? ' kutu-cercevesiz' : ''}`
                    + `${kutuSinif ? ` ${kutuSinif}` : ''}`}>
      {!sadeGrid && (
      <h6>
        {meta.baslik}
        {!saltOkunur && (
          ikonlu ? (
            <span className="baslik-eylem">
              {/* ARAMALI DETAYDA "＋" DOGRUDAN ARAMAYI ACAR (kullanici): satirin
                  tek anlamli alani secilecek KISI - once bos satir acip sonra
                  hucreden arama penceresini actirmak fazladan bir adimdi.
                  Ayri bir arama dugmesi de yok: iki dugme ayni isi yapiyordu. */}
              {!ekleGizli && (
              <button type="button" className="d bir ikon-dugme"
                      title={tarafAlani ? `${tarafAlani.baslik} ara ve ekle` : 'Yeni satır'}
                      disabled={!satirEklenebilir}
                      onClick={() => {
                        if (tarafAlani) { setTarafAramaAcik(true); return }
                        if (modalDuzenle) modalAc('yeni'); else satirEkle();
                      }}>＋</button>
              )}
              {/* Duzenle / Sil USTTE (kullanici): satir sonunda her satirda
                  tekrar edip gridi kalabaliklastiriyordu. Secim yoksa pasif ve
                  sebebi title'da - seri/XSLT gridleriyle ayni desen. */}
              {modalDuzenle && (
                <>
                  <button type="button" className="d ikon-dugme" disabled={secili === null}
                          title={secili === null ? 'Önce satır seçin' : 'Seçili satırı düzenle'}
                          onClick={() => secili !== null && modalAc(secili)}>✎</button>
                  <button type="button" className="d teh ikon-dugme" disabled={secili === null}
                          title={secili === null ? 'Önce satır seçin' : 'Seçili satırı sil'}
                          onClick={() => { if (secili !== null) { satirSil(secili); setSecili(null); } }}>🗑</button>
                </>
              )}
              {/* Suzme cipleri (kullanici: Tumu / Stok / Hizmet) - listelerin
                  durum cipleriyle ayni gorunum, yalniz gorunumu daraltir. */}
              {cipler && cipler.map((cip, ci) => (
                <button key={cip.ad} type="button"
                        className={`d ${ci === aktifCip ? 'bir' : ''}`}
                        style={{ marginLeft: ci === 0 ? 10 : 4 }}
                        onClick={() => { setAktifCip(ci); setSecili(null); }}>
                  {cip.ad}
                </button>
              ))}
              {aramaVar && (
                // Listedeki "Bu listede ara" kutusuyla AYNI oval gorunum.
                <span className="ara-kutu satir-arasi">
                  <span>🔍</span>
                  <input value={arama} placeholder="Satırlarda ara…"
                         onChange={e => { setArama(e.target.value); setSecili(null); }} />
                </span>
              )}
              {satirlarGrid && (
                <button type="button" className="d ikon-dugme" title="Grid menüsü"
                        style={{ marginLeft: 6 }}
                        onClick={e => {
                          e.stopPropagation();
                          const r = e.currentTarget.getBoundingClientRect();
                          setMenuKonum(menuKonum ? null : { x: r.left, y: r.bottom + 4 });
                        }}>⋮</button>
              )}
            </span>
          ) : (
            // IKONSUZ BASLIKTA DA AYNI KURAL: aramali detayda dugme dogrudan
            //   arama penceresini acar. Prim Alanlar bu daldan ciziliyordu -
            //   yalniz ikonlu dali degistirmek yetmedi (kullanici: "+ satır
            //   basınca arama açılmıyor").
            <button type="button" className="d bir" disabled={!satirEklenebilir}
                    onClick={() => (tarafAlani ? setTarafAramaAcik(true) : satirEkle())}>
              {tarafAlani ? `＋ ${tarafAlani.baslik} Ekle`
                          : acilKisiGrid ? '＋ Kişi Ekle' : '+ Satir'}
            </button>
          )
        )}
      </h6>
      )}

      {/* KOLONU COK OLAN DETAY GRIDI (prim satirlari): tablo modal genisligini
          asinca en sagdaki kolonlar (satir silme ✖ dahil) ERISILEMEZ oluyordu.
          Yatay kaydirma sarmalayicisi - sigan gridlerde cubuk hic cikmaz. */}
      {/* SATIRLAR gridi (fiyat listesi) YUZLERCE satir olabiliyor: kendi dikey
          kaydirma alani - modal govdesi tasip alt satirlar ekranin altinda
          kirpiliyordu (kullanici). Baslik satiri sabit kalir. */}
      <div className={`detay-kaydir${satirlarGrid ? ' detay-uzun' : ''}`}>
      <table className={`detay-tablo${adresGrid ? ' adres-tablo' : ''}`} style={adresGrid ? { tableLayout: 'fixed' } : undefined}>
        {adresGrid && (
          <colgroup>
            {alanlar.map(a => <col key={a.ad} style={{ width: ADRES_GENISLIK[a.ad] }} />)}
            {!saltOkunur && <col style={{ width: '6%' }} />}
          </colgroup>
        )}
        <thead>
          <tr>
            {modalDuzenle && !saltOkunur && <th style={{ width: 30 }} />}
            {satirlarGrid && (
              <>
                <th style={{ width: 36 }}>Tip</th>
                {/* Kullanici: kategori ve kod kolonlari yarisi kadar dar -
                    asil okunan "Adı" ve fiyat, bunlar destek bilgisi. */}
                <th style={{ width: '9%' }}>Kategori</th>
                <th style={{ width: '6%' }}>Kod</th>
                <th>Adı</th>
              </>
            )}
            {gridAlanlari.map(a => (
              <th key={a.ad}>{kolonBasligi(a)}{a.zorunlu && ' *'}</th>
            ))}
            {!modalDuzenle && !saltOkunur && <th />}
          </tr>
        </thead>
        <tbody>
          {gorunurler.map(({ satir, i }) => (
            <tr key={satir.id ?? `yeni-${i}`}
                className={modalDuzenle && secili === i ? 'secili' : undefined}
                onDoubleClick={() => modalDuzenle && !saltOkunur && modalAc(i)}>
              {/* Tek satir secimi: yeni kutu isaretlenince oncekinin isareti kalkar -
                  duzenle/sil tek satira uygulanir. */}
              {modalDuzenle && !saltOkunur && (
                <td className="hiza-orta">
                  <input type="checkbox" checked={secili === i}
                         onChange={e => setSecili(e.target.checked ? i : null)} />
                </td>
              )}
              {satirlarGrid && (
                <>
                  <td className="hiza-orta" title={satir.stokId != null && satir.stokId !== '' ? 'Stok' : 'Hizmet'}>
                    {satir.stokId != null && satir.stokId !== '' ? '📦' : '🛠️'}
                  </td>
                  <td className="sonuk" title={String(satir.kategoriYolu ?? '')}
                      style={{ maxWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis',
                               whiteSpace: 'nowrap' }}>
                    {String(satir.kategoriYolu ?? '')}
                  </td>
                  <td className="sonuk" title={String(satir.kalemKodu ?? '')}
                      style={{ maxWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis',
                               whiteSpace: 'nowrap' }}>
                    {String(satir.kalemKodu ?? '')}
                  </td>
                  <td>{kalemAdi(satir)}</td>
                </>
              )}
              {modalDuzenle && gridAlanlari.map(a => (
                <td key={a.ad} className={a.tip === 'mantik' ? 'hiza-orta' : undefined}>
                  {satirlarGrid && hizliHucre(a.ad) && !saltOkunur && a.yazilabilir ? (
                    <input
                      // Disaridan (modal/kural) fiyat degisince kutu tazelensin;
                      //   kullanici yazarken prop degismedigi icin remount olmaz.
                      key={`${satir.id ?? i}-${a.ad}-${String(satir[a.ad] ?? '')}`}
                      defaultValue={String(satir[a.ad] ?? '')}
                      data-fiyat-satir={i}
                      data-fiyat-alan={a.ad}
                      inputMode="decimal"
                      style={{ width: 90, textAlign: 'right' }}
                      // Cift tik SATIR MODALINI acmasin; odaklaninca tumu
                      //   secilsin - hizli giriste dogrudan yazilir.
                      onDoubleClick={e => e.stopPropagation()}
                      onFocus={e => e.currentTarget.select()}
                      onKeyDown={e => {
                        if (e.key !== 'Enter' && e.key !== 'ArrowDown' && e.key !== 'ArrowUp') return;
                        e.preventDefault();
                        (e.target as HTMLInputElement).blur();   // blur -> isle
                        const sirada = gorunurler.findIndex(g => g.i === i);
                        const hedef = gorunurler[e.key === 'ArrowUp' ? sirada - 1 : sirada + 1]?.i;
                        if (hedef !== undefined)
                          requestAnimationFrame(() =>
                            document.querySelector<HTMLInputElement>(
                              `input[data-fiyat-satir="${hedef}"]`
                              + `[data-fiyat-alan="${a.ad}"]`)?.select());
                      }}
                      onBlur={e => fiyatHucreIsle(i, e.target.value, a.ad)}
                    />
                  ) : rozetHucresi(a.ad) ? (
                    // KDV ve DURUM ROZET (kullanici): iki degerli/az degerli
                    //   kolonlar duz metinde satir arasinda kayboluyordu.
                    <span className={`rozet ${rozetSinifi(a.ad, gorunum(satir, a))}`}>
                      {gorunum(satir, a)}
                    </span>
                  ) : gorunum(satir, a)}
                </td>
              ))}
              {!modalDuzenle && alanlar.map(a => (
                <td key={a.ad}>
                  {/* TELEFON her yerde ayni (genel kural): gride de ulke kodlu,
                      gruplu kutu gelir; gecersiz numara kirmizi cerceve alir. */}
                  {etiketAlanlari?.has(a.ad) ? (
                    <span className="hucre-etiket">{gorunum(satir, a)}</span>
                  ) : telefonAlaniMi(a.ad) ? (
                    <span className={telefonGecerliMi(String(satir[a.ad] ?? '')) ? '' : 'tel-gecersiz'}>
                      <TelefonGirdi
                        value={String(satir[a.ad] ?? '')}
                        disabled={saltOkunur || !a.yazilabilir}
                        onChange={(v: string) => hucreDegis(i, a.ad, v)}
                      />
                    </span>
                  ) : a.tip === 'mantik' ? (
                    acilKisiGrid && a.ad === 'varsayilan' ? (
                      <button
                        type="button"
                        className="d"
                        title="Varsayılan"
                        disabled={saltOkunur || !a.yazilabilir}
                        onClick={() => hucreDegis(i, a.ad, Number(satir[a.ad]) === 1 || satir[a.ad] === true ? 0 : 1)}
                        style={{ minWidth: 24, height: 22, padding: 0 }}
                      >
                        {Number(satir[a.ad]) === 1 || satir[a.ad] === true ? '★' : ''}
                      </button>
                    ) : (
                      <input
                        type="checkbox"
                        checked={Number(satir[a.ad]) === 1 || satir[a.ad] === true}
                        disabled={saltOkunur || !a.yazilabilir}
                        onChange={e => hucreDegis(i, a.ad, e.target.checked)}
                      />
                    )
                  ) : meta.ad === 'adresler' && a.ad === 'il' && yerler ? (
                    <select
                      value={String(satir.il ?? '')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => {
                        const guncel = durum.guncel.map((s, ix) =>
                          ix === i ? { ...s, il: e.target.value, ilce: '' } : s);
                        onDegis({ ...durum, guncel });
                      }}
                    >
                      <option value="">—</option>
                      {yerler.iller.map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
                    </select>
                  ) : meta.ad === 'adresler' && a.ad === 'ulke' && yerler ? (
                    <select
                      value={String(satir.ulke ?? '')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      <option value="">—</option>
                      {yerler.ulkeler.map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
                    </select>
                  ) : meta.ad === 'adresler' && a.ad === 'ilce' && yerler ? (
                    <select
                      value={String(satir.ilce ?? '')}
                      disabled={saltOkunur || !a.yazilabilir || !satir.il}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      <option value="">—</option>
                      {yerler.ilceler
                        .filter(y => y.ilId === ilAdIdHarita.get(String(satir.il ?? '')))
                        .map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
                    </select>
                  ) : meta.ad === 'egitimler' && a.ad === 'ad' && String(satir.tur ?? '') === '1' ? (
                    <select
                      value={String(satir.ad ?? '')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      <option value="">—</option>
                      {DIPLOMA_ADLARI.map(ad => <option key={ad} value={ad}>{ad}</option>)}
                    </select>
                  ) : meta.ad === 'egitimler' && a.ad === 'tarih' ? (
                    <input
                      value={String(satir.tarih ?? '')}
                      maxLength={10}
                      inputMode="numeric"
                      placeholder="YYYY veya GG.AA.YYYY"
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, tarihYilTemizle(e.target.value))}
                    />
                  ) : meta.ad === 'egitimler' && a.ad === 'gecerlilik' ? (
                    <select
                      value={String(satir.gecerlilik ?? 'Süresiz')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      {EGITIM_GECERLILIK.map(ad => <option key={ad} value={ad}>{ad}</option>)}
                    </select>
                  ) : kampanyaSatiri && a.ad === 'dovizCinsi'
                        && Number(satir.iskontoTipi) !== 2 ? (
                    // Yuzde satirinda doviz yok: birim "%" (kullanici).
                    <input readOnly disabled value="%" style={{ textAlign: 'center' }} />
                  ) : kampanyaSatiri && a.ad === 'iskontoYeriId' ? (
                    Number(satir.tip) === 2 ? (
                      <select
                        value={String(satir[a.ad] ?? '')}
                        disabled={saltOkunur || !a.yazilabilir}
                        onChange={e => hucreDegis(i, a.ad, e.target.value)}
                      >
                        <option value="">— kategori —</option>
                        {Object.entries(a.kodlar ?? {}).map(([k, v]) => (
                          <option key={k} value={k}>{v}</option>
                        ))}
                      </select>
                    ) : Number(satir.tip) === 3 ? (
                      <span className="ikili"
                            style={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                        <input readOnly
                               style={{ flex: '1 1 auto', minWidth: 150 }}
                               value={String(satir.iskontoYeriAdi
                                             ?? urunAdlari[String(satir[a.ad] ?? '')]
                                             ?? satir[a.ad] ?? '')}
                               placeholder="— ürün —"
                               disabled={saltOkunur || !a.yazilabilir}
                               onClick={() => !saltOkunur && setUrunAramaSatiri(i)} />
                        <button type="button" className="d mini" title="Ürün ara"
                                disabled={saltOkunur || !a.yazilabilir}
                                onClick={() => setUrunAramaSatiri(i)}>…</button>
                      </span>
                    ) : (
                      // Liste satirinda hedef yok: kolon 0 kalir.
                      <input readOnly value="tüm liste" disabled />
                    )
                  ) : primSatiri && a.ad === 'tip' && a.kodlar ? (
                    // Tip degisince KAPSAM temizlenir: "Kategori" secilip urun
                    //   id'si kalirsa satir yanlis kalemlere prim yazar.
                    //   Kapsamli tipe gecerken kalem turu de belirlenir - "Farketmez"
                    //   kalirsa kategori listesi ve urun aramasi SUZULEMEZ.
                    <select
                      value={String(Number(satir.tip) || 1)}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => satirDegis(i, {
                        tip: e.target.value, hedefId: '',
                        ...(Number(e.target.value) !== 1 && !Number(satir.kalemTuru)
                            ? { kalemTuru: '2' } : {}),
                      })}
                    >
                      {Object.entries(a.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                    </select>
                  ) : primSatiri && a.ad === 'kalemTuru' && a.kodlar ? (
                    // Kalem turu kapsamin ANLAMINI degistirir (stok kategorisi
                    //   mi hizmet kategorisi mi) - degisince kapsam sifirlanir.
                    //   "Farketmez" KAPSAMLI satirda gizli: secilirse kategori
                    //   listesi ve urun aramasi suzulemez, kullanici da hangi
                    //   taraftan sectigini goremez. Liste (tumu) satirinda kalem
                    //   turu zaten anlamsizdir - orada secim kapalidir.
                    <select
                      value={String(Number(satir.tip) === 3 || Number(satir.tip) === 2
                                    ? (Number(satir.kalemTuru) || 2)
                                    : (Number(satir.kalemTuru) || 0))}
                      disabled={saltOkunur || !a.yazilabilir
                                || (Number(satir.tip) || 1) === 1}
                      onChange={e => satirDegis(i, { kalemTuru: e.target.value, hedefId: '' })}
                    >
                      {Object.entries(a.kodlar)
                        .filter(([k]) => (Number(satir.tip) || 1) === 1 || Number(k) !== 0)
                        .map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                    </select>
                  ) : primSatiri && a.ad === 'hedefId' ? (
                    Number(satir.tip) === 2 ? (
                      // KATEGORI: kalem turune gore suzulur - stok secilmisse
                      //   stokta, hizmet secilmisse hizmette kullanilan
                      //   kategoriler ("Farketmez"te hepsi).
                      <select
                        value={String(satir.hedefId ?? '')}
                        disabled={saltOkunur || !a.yazilabilir}
                        onChange={e => hucreDegis(i, 'hedefId', e.target.value)}
                      >
                        <option value="">— kategori —</option>
                        {kategoriler
                          .filter(k => (Number(satir.kalemTuru) === 1 ? k.stok > 0
                                        : Number(satir.kalemTuru) === 2 ? k.hizmet > 0
                                        : true))
                          .map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
                      </select>
                    ) : Number(satir.tip) === 3 ? (
                      // URUN: stok/hizmet binlerce - jenerik arama penceresi.
                      <span className="ikili"
                            style={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                        <input readOnly
                               style={{ flex: '1 1 auto', minWidth: 150 }}
                               value={urunAdlari[String(satir.hedefId ?? '')]
                                      ?? String(satir.hedefId ?? '')}
                               placeholder="— ürün seç —"
                               disabled={saltOkunur || !a.yazilabilir}
                               onClick={() => !saltOkunur && setUrunAramaSatiri(i)} />
                        <button type="button" className="d mini" title="Ürün ara"
                                disabled={saltOkunur || !a.yazilabilir}
                                onClick={() => setUrunAramaSatiri(i)}>…</button>
                      </span>
                    ) : (
                      // LISTE: kapsam yok - satir tum kalemlerde gecerli.
                      <input readOnly value="tüm liste" disabled />
                    )
                  ) : a.kodlar ? (
                    <select
                      value={String(satir[a.ad] ?? '')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      <option value="">—</option>
                      {Object.entries(a.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                    </select>
                  ) : a.tip === 'zaman' ? (
                    // Zaman alani (randevu baslangici) ham "2026-09-01T10:00:00"
                    //   metni olarak cizilyordu; datetime-local saniyeyi atar.
                    <input type="datetime-local"
                      value={String(satir[a.ad] ?? '').slice(0, 16)}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    />
                  ) : a.tip === 'tarih' ? (
                    // Detay gridlerinde tarih alanlari DUZ METIN kutusuydu
                    //   (izin baslangic/bitis) - takvim secici yoktu.
                    <input type="date"
                      value={String(satir[a.ad] ?? '').slice(0, 10)}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    />
                  ) : (
                    <input
                      className={a.tip === 'sayi' || a.tip === 'para' || a.tip === 'ondalik'
                                 ? 'hiza-sag' : undefined}
                      value={String(satir[a.ad] ?? '')}
                      maxLength={a.enFazlaUzunluk ?? undefined}
                      inputMode={a.tip === 'sayi' ? 'numeric' : undefined}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    />
                  )}
                  {hatalar[`${meta.ad}.${a.ad}`] && (
                    <span className="alan-hata">{hatalar[`${meta.ad}.${a.ad}`]}</span>
                  )}
                </td>
              ))}
              {!modalDuzenle && !saltOkunur && !sadeGrid && (
                <td className="hiza-orta">
                  <button type="button" className={`d teh${ikonlu ? ' ikon-dugme' : ''}`}
                          title={ikonlu ? 'Satırı sil' : undefined}
                          onClick={() => satirSil(i)}>{ikonlu ? '🗑' : '×'}</button>
                </td>
              )}
            </tr>
          ))}
          {gorunurler.length === 0 && (
            <tr><td colSpan={gridAlanlari.length + (satirlarGrid ? 2 : 0) + 1} className="bos">
              {durum.guncel.length === 0 ? 'Satır yok' : 'Eşleşen satır yok'}
            </td></tr>
          )}
        </tbody>
      </table>
      </div>

      {satirlarGrid && (
        <GridMenu konum={menuKonum} ogeler={menuOgeleri}
                  onKapat={() => setMenuKonum(null)} />
      )}

      {/* Satir duzenleme modali: alanlar etiketleriyle alt alta. "Tamam" yalniz
          TABLOYA yazar - kayit kartin kendi Kaydet'iyle sunucuya gider. */}
      {modalSatir !== null && (
        <Modal
          baslik={modalSatir === 'yeni' ? `${meta.baslik} — Yeni` : meta.baslik}
          dar
          onKapat={() => setModalSatir(null)}
          alt={<>
            <button type="button" className="d kapat-dugmesi"
                    onClick={() => setModalSatir(null)}>Vazgeç</button>
            <button type="button" className="d bir" onClick={modalKaydet}>Tamam</button>
          </>}
        >
          <>
          <div className="kagrup">
            <div className="alan-izgara tek-sutun ayar-formu">
              {alanlar.map(a => (
                <label className={`alan${a.tip === 'mantik' ? ' ayar-onay' : ''}`} key={a.ad}>
                  {a.tip === 'mantik' ? (
                    <>
                      <input type="checkbox" disabled={!a.yazilabilir}
                             checked={Number(taslak[a.ad]) === 1 || taslak[a.ad] === true}
                             onChange={e => taslakYaz(a.ad, e.target.checked ? 1 : 0)} />
                      <span className="etiket">{a.baslik}</span>
                    </>
                  ) : (
                    <>
                      <span className={`etiket${a.zorunlu ? ' zorunlu-isaret' : ''}`}>{a.baslik}</span>
                      <span className="ikili">
                        {/* ARAMAYLA SECILEN ALAN DEGISTIRILEMEZ (kullanici):
                            satirin KIMLIGI odur - baskasiyla degistirmek
                            "ayni satir, baska kisi" demek olurdu; dogrusu
                            satiri silip yenisini eklemek. Combo yerine duz
                            metin: kapali bir combo "acilmiyor mu" diye
                            tiklatir. */}
                        {/* KODLU METIN ALANI (prim satirinda Belge Türleri):
                            kolon VIRGULLU LISTE tasir ("15,16") ama secenek
                            sayisi az ve birbirini disliyor - kullanici combo
                            istedi. Anahtarlar kolona yazilan degerin KENDISI;
                            bos = tumu. */}
                        {a.tip === 'metin' && a.kodlar ? (
                          <select value={String(taslak[a.ad] ?? '')} disabled={!a.yazilabilir}
                                  onChange={e => taslakYaz(a.ad, e.target.value)}>
                            <option value="">Tümü</option>
                            {Object.entries(a.kodlar).map(([k, v]) => (
                              <option key={k} value={k}>{v}</option>
                            ))}
                          </select>
                        ) : a.aramaKaynagi ? (
                          <span className="sonuk">
                            {a.kodlar?.[String(taslak[a.ad] ?? '')] ?? String(taslak[a.ad] ?? '')}
                          </span>
                        ) : a.kodlar ? (
                          <select value={String(taslak[a.ad] ?? '')} disabled={!a.yazilabilir}
                                  onChange={e => taslakYaz(a.ad, e.target.value)}>
                            <option value="">—</option>
                            {Object.entries(a.kodlar).map(([k, v]) => (
                              <option key={k} value={k}>{v}</option>
                            ))}
                          </select>
                        ) : (
                          <input className="genis-deger" value={String(taslak[a.ad] ?? '')}
                                 maxLength={a.enFazlaUzunluk ?? undefined}
                                 disabled={!a.yazilabilir}
                                 onChange={e => taslakYaz(a.ad, e.target.value)} />
                        )}
                      </span>
                    </>
                  )}
                </label>
              ))}
            </div>
          </div>
          {/* SATIRIN COCUGU (388: kademeler) - kart cercevesi torun detayi
              baglamaz, ama kullanici satiri duzenlerken cocugunu da gormeli.
              Yeni satirda id yok: bilesen "once satiri kaydedin" der. */}
          {modalAltBilesen?.(
            modalSatir !== 'yeni' && modalSatir !== null
              ? (Number(durum.guncel[modalSatir]?.id) || null)
              : null)}
          </>
        </Modal>
      )}

      {/* TARAF ARAMASIYLA EKLEME (375, kullanici alternatif 2): pencere secimde
          KAPANMAZ - "dr" arayip Enter, sonra baska ad arayip Enter... Kapatmayi
          kullanici yapar. Zaten ekli olan ya da kod listesinde bulunmayan kisi
          ALINMAZ ve sebebi pencerede yazar. */}
      {tarafAlani && tarafAramaAcik && (
        <TarafArama
          acik
          cokluSecim
          // aramaKaynagi VIRGULLU olabilir: prim alan kisi ic personel de
          //   olabilir dis hekim de, ikisi ayri liste kaynagi. Cagiran
          //   daraltabilir (382: dis hekim yalniz "Gönderen" planinda).
          kaynaklar={aramaKaynaklari
            ? [...aramaKaynaklari]
            : tarafAlani.aramaKaynagi!.split(',').map(x => x.trim()).filter(Boolean)}
          yerTutucu={`${tarafAlani.baslik} ara…`}
          ekFiltre={aramaEkFiltre}
          secimDenetimi={secilen =>
            tarafSecimEngeli(durum.guncel, tarafAlani.ad, secilen)}
          onSec={() => { /* coklu kipte kullanilmaz - onSecCoklu calisir */ }}
          onSecCoklu={secilenler => {
            // TEK STATE GUNCELLEMESI: her secilen icin ayri `onDegis`
            //   cagrilsaydi hepsi AYNI `durum` uzerinden turetilir ve yalniz
            //   sonuncusu kalirdi.
            // ARAMADAN GELEN GORUNUR DEGERLER de yazilir: yeni satir yalniz
            //   adla, oteki hucreler bos gorunuyordu (kullanici). Bunlar
            //   SALT OKUNUR alanlar - sunucuya gitmez, kayit sonrasi kart
            //   yeniden okununca ayni degerler kaynagindan gelir; buradaki
            //   yazim sadece "kaydetmeden once de dolu gorunsun" icindir.
            //   Eslesme ALAN ADIYLA: detayda 'tipi' / 'bolum' / 'gorev' varsa
            //   doldurulur, yoksa dokunulmaz.
            const aramaKarsiliklari: Record<string, (x: typeof secilenler[number]) => string> = {
              tipi: x => x.tip, bolum: x => x.bolum, gorev: x => x.gorev,
            };
            const yeniler = secilenler.map(secilen => {
              const satir: Satir = {};
              alanlar.forEach(a => { satir[a.ad] = a.tip === 'mantik' ? 0 : '' });
              satir[tarafAlani.ad] = String(secilen.id);
              alanlar.forEach(a => {
                const cevir = aramaKarsiliklari[a.ad];
                if (cevir && !a.yazilabilir) satir[a.ad] = cevir(secilen);
              });
              return satir;
            });
            onDegis({ ...durum, guncel: [...durum.guncel, ...yeniler] });
          }}
          onKapat={() => setTarafAramaAcik(false)}
        />
      )}

      {/* KAMPANYA (268): urun satirinda hedef stok/hizmet jenerik arama
          penceresinden secilir - binlerce kayit combo'ya sigmaz. Secilen id
          iskonto_yeri_id'ye, adi ekranda gostermek icin satira yazilir. */}
      {urunAramaSatiri !== null && primSatiri && (
        <StokAramaPenceresi
          etkin
          // Kalem turu secilmisse arama da ONA gore suzulur: "Hizmet" deyip
          //   stok secilmesi kapsami sessizce bosa dusururdu.
          yalnizStok={Number(durum.guncel[urunAramaSatiri]?.kalemTuru) === 1}
          yalnizHizmet={Number(durum.guncel[urunAramaSatiri]?.kalemTuru) === 2}
          onKapat={() => setUrunAramaSatiri(null)}
          onSec={secilen => {
            // Kalem turu de secimden yazilir - kullanici ayrica isaretlemesin.
            satirDegis(urunAramaSatiri, {
              hedefId: String(secilen.id),
              kalemTuru: String(secilen.tip) === 'hizmet' ? '2' : '1',
            });
            setUrunAdlari(m => ({
              ...m,
              [String(secilen.id)]: `${String(secilen.kod ?? '')} ${String(secilen.ad ?? '')}`.trim(),
            }));
            setUrunAramaSatiri(null);
          }}
        />
      )}

      {urunAramaSatiri !== null && !primSatiri && (
        <StokAramaPenceresi
          etkin
          onKapat={() => setUrunAramaSatiri(null)}
          onSec={secilen => {
            // Id ve kalem turu TEK yazimda: iki ayri cagri birbirini ezer.
            //   Ad da satirda tutulur - ekranda id degil ad gorunsun.
            satirDegis(urunAramaSatiri, {
              iskontoYeriId: String(secilen.id),
              kalemTuru: String(secilen.tip) === 'hizmet' ? '2' : '1',
              iskontoYeriAdi: `${secilen.kod ?? ''} ${secilen.ad ?? ''}`.trim(),
            });
            setUrunAramaSatiri(null);
          }}
        />
      )}
    </div>
  );
}
