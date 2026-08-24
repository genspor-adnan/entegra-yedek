import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api, oturum } from '../api/istemci';
import {
  ApiHatasi,
  type DokumanSatiri, type KartAlanMeta, type KartDetayMeta, type KartMetaYaniti, type KartYetkisi,
} from '../api/sozlesme';
import { GenDetayTablo, type DetayDurumu, bosDetay, detayFarki } from './GenDetayTablo';
import { IlgiliKisiler } from './IlgiliKisiler';
import { TekAdres } from './TekAdres';
import { TekOzluk } from './TekOzluk';
import { TekKayit } from './TekKayit';
import { PersonelKimlikOzet } from './PersonelKimlikOzet';
import { RolYetkiMatrisi } from './RolYetkiMatrisi';
import { DokumanGalerisi } from './DokumanGalerisi';
import { StokDurumSekmesi } from './StokDurumSekmesi';
import { StokHareketSekmesi } from './StokHareketSekmesi';
import { TarafArama } from './TarafArama';
import { epostaGecerliMi } from './alanBicim';
import { TelefonGirdi } from './TelefonGirdi';

interface Props {
  kaynak: string;
  id: number | 'yeni';
  baslik?: string;
  onKapat?(): void;
  onKaydedildi?(id: number): void;
  /** Mockup'ta olup backend'i henuz olmayan sekmeler (or. "UTS Bilgileri") - "yakinda" gosterilir. */
  yerTutucuSekmeler?: string[];
  /** "Genel" sekmesinde alt-bolum kutularinin YANINA mockup'taki gibi bos "Resim" kutusu ekler. */
  resimYerTutucu?: boolean;
  /** TarafArama'nin kendi Yeni/Duzenle'siyle acilan ic-ice Kisi Karti'nda "Cariye Bağla"
      butonu GIZLENIR - yoksa TarafArama'nin icinden bir baska TarafArama acilir, tekrarli/
      kafa karistirici olur (kullanici). */
  cariyeBaglaGizli?: boolean;
  /** Yeni kayitta mantik alanlara EKRANA OZEL varsayilan (ör. Tedarikçi Listesi'nden
      "+Yeni" -> tedarikci:true, musteri:false) - ayni "cari" karti Musteri/Tedarikci
      ekranlarindan farkli varsayilanla acilsin diye. */
  /** Ekrana ozel varsayilan: mantik alan icin boolean, kod/sayi alani icin
      sayi (or. Cek Listesi'nden 'Yeni' -> tur=1). */
  yeniKayitVarsayilanlari?: Record<string, boolean | number | string>;
}

/** Modal sarmalayici — mockup'taki .kaperde / .kawin duzeni. */
export function Modal({ baslik, ustBilgi, ustSerit, sekmeBar, alt, dar, onKapat, children }: {
  baslik: string;
  ustBilgi?: React.ReactNode;
  ustSerit?: React.ReactNode;
  sekmeBar?: React.ReactNode;
  alt: React.ReactNode;
  /** Az alanli kartlar icin yarim genislik (1080 -> 560): bos beyaz alan kalmasin. */
  dar?: boolean;
  onKapat?(): void;
  children: React.ReactNode;
}) {
  useEffect(() => {
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') onKapat?.() };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
  }, [onKapat]);

  return (
    <div className="kaperde" onMouseDown={e => { if (e.target === e.currentTarget) onKapat?.() }}>
      <div className={`kawin${dar ? '' : ' genis'}`} onMouseDown={e => e.stopPropagation()}>
        <div className="kabas">
          <span>{baslik}</span>
          {ustBilgi}
          <span className="kapt">Esc ile kapanır</span>
        </div>
        {/* Mockup: Kaydet/Sil/Yazdir/Kapat baslikla idstrip ARASINDA arac cubugu (alt degil). */}
        <div className="katoolbar">{alt}</div>
        {ustSerit}
        {sekmeBar}
        <div className="kagov">{children}</div>
      </div>
    </div>
  );
}

function KartResimKutusu({ kartAdi, kaynakId, saltOkunur, baslik = 'Resim' }: {
  kartAdi: string;
  kaynakId?: number;
  saltOkunur: boolean;
  baslik?: string;
}) {
  const [url, setUrl] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const dosyaRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    if (!kaynakId) {
      setUrl(null);
      return;
    }
    let iptal = false;
    let blobUrl: string | null = null;
    api.dokumanlar(kartAdi, kaynakId)
      .then((satirlar: DokumanSatiri[]) => {
        const resimler = satirlar.filter(s => s.contentType.startsWith('image/'));
        const resim = resimler.find(s => s.varsayilan) ?? resimler[0];
        if (!resim) {
          setUrl(null);
          return null;
        }
        return api.dokumanIcerikUrl(resim.id);
      })
      .then(u => {
        if (!u || iptal) return;
        blobUrl = u;
        setUrl(u);
      })
      .catch(() => setUrl(null));
    return () => {
      iptal = true;
      if (blobUrl) URL.revokeObjectURL(blobUrl);
    };
  }, [kartAdi, kaynakId]);

  const dosyaSecildi = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const dosya = e.target.files?.[0];
    e.target.value = '';
    if (!dosya || !kaynakId) return;
    setYukleniyor(true);
    setHata(null);
    try {
      const satirlar = await api.dokumanYukle(kartAdi, kaynakId, dosya, true);
      const resimler = satirlar.filter(s => s.contentType.startsWith('image/'));
      const resim = resimler.find(s => s.varsayilan) ?? resimler[0];
      setUrl(resim ? await api.dokumanIcerikUrl(resim.id) : null);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally {
      setYukleniyor(false);
    }
  };

  return (
    <div className="kagrup kagrup-resim">
      <h6>{baslik}</h6>
      {!saltOkunur && kaynakId && (
        <input ref={dosyaRef} type="file" style={{ display: 'none' }}
          accept="image/jpeg,image/png,image/webp,image/gif" onChange={e => void dosyaSecildi(e)} />
      )}
      <div
        className="resim-kutusu"
        title={!kaynakId ? 'Kart kaydedilmeden resim eklenemez' : saltOkunur ? undefined : 'Resim eklemek için tıklayın'}
        style={{ cursor: !saltOkunur && kaynakId ? 'pointer' : 'default', overflow: 'hidden' }}
        onClick={() => { if (!saltOkunur && kaynakId) dosyaRef.current?.click() }}
      >
        {yukleniyor ? '…' : url ? <img src={url} alt={baslik} style={{ width: '100%', height: '100%', objectFit: 'contain' }} /> : '🖼️'}
      </div>
      {hata && <div className="alan-hata" style={{ margin: '4px 10px 0' }}>{hata}</div>}
    </div>
  );
}

/** Kart ici sekme: alan grubu, detay tablosu, ya da henuz baglanmamis yer tutucu. */
type SekmeTanimi =
  | { tur: 'grup'; anahtar: string; baslik: string; alanlar: KartAlanMeta[] }
  | { tur: 'detay'; anahtar: string; baslik: string; detay: KartDetayMeta }
  | { tur: 'yerTutucu'; anahtar: string; baslik: string }
  // Generic Detay mekanizmasina uymayan kaynaga-ozel sekmeler (ör. Rol > Yetki Matrisi).
  | { tur: 'ozel'; anahtar: string; baslik: string };

const detaySekmeAnahtari = (detayAd: string) => `d:${detayAd}`;
const grupSekmeAnahtari = (grupAd: string) => `g:${grupAd}`;

/** Sekme DEGIL, ust seritte sabit gorunen grup (mockup idstrip). */
const KIMLIK_GRUP = 'Kimlik';

type Deger = string | number | boolean | null;

// "epostaWeb"/"aliasEposta" DAHIL DEGIL - role gore URL/GIB-URN-alias de tutabiliyor
// (taraf.eposta_web/alias_eposta yorumlari), sadece duz "eposta" alani her zaman e-posta.
const EPOSTA_ALANLARI = new Set(['eposta']);
const TELEFON_ALANLARI = new Set(['telefon', 'cepTel']);

// Az alanli ayar kartlari: alanlar yan yana degil ALT ALTA (tek sutun) - 4-5 alan
//   genis izgaraya yayilinca form dagilmis gorunuyor, sira da okunmuyordu.
const TEK_SUTUN_KARTLAR = new Set(['depo']);

/**
 * Kart sozlesmesini (§3) tuketen genel form.
 *
 *  - Alan listesi, etiketler, zorunluluk ve uzunluk sinirlari SUNUCUDAN gelir
 *    (/alanlar). Yetkisiz alan hic donmedigi icin arayuzde gizleme mantigi yok.
 *  - Kaydetmede `surum` geri gonderilir; baskasi degistirmisse sunucu 409 doner ve
 *    kullaniciya "guncel hali al" secenegi sunulur (§1.3).
 *  - Alan hatalari (`alanlar[]`) ilgili girdinin altina yazilir.
 *  - Detaylar FARK olarak gonderilir (eklenen / degisen / silinen), tam liste degil.
 */
export function GenForm({ kaynak, id, baslik, onKapat, onKaydedildi, yerTutucuSekmeler, resimYerTutucu, cariyeBaglaGizli, yeniKayitVarsayilanlari }: Props) {
  const yeniMi = id === 'yeni';
  const personelGibiKart = kaynak === 'personel' || kaynak === 'hasta';

  const [meta, setMeta] = useState<KartMetaYaniti | null>(null);
  const [deger, setDeger] = useState<Record<string, Deger>>({});
  const [ilkDeger, setIlkDeger] = useState<Record<string, Deger>>({});
  const [surum, setSurum] = useState<string | undefined>();
  const [yetki, setYetki] = useState<KartYetkisi>({ duzenle: false, sil: false, gizliAlanlar: [] });
  const [detaylar, setDetaylar] = useState<Record<string, DetayDurumu>>({});

  const [yukleniyor, setYukleniyor] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});
  const [cakisma, setCakisma] = useState<{ alanlar: string[]; guncel: Record<string, unknown> } | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);
  const [cariyeBaglaAcik, setCariyeBaglaAcik] = useState(false);
  /** Katalogdaki AcilistaTarafSecimi ile acilan cari secimi (yeni kayitta). */
  const [tarafSecimAcik, setTarafSecimAcik] = useState(false);
  const [kapatmaUyarisi, setKapatmaUyarisi] = useState(false);
  // TarafArama'dan bir KISI secilirse "public.v_cari_lookup" (KodTablosu) onu bilmiyor -
  // secim sonrasi ad gorunsun diye adini ayrica burada tutuyoruz (server'a etkisi yok).
  const [bagliTarafAdi, setBagliTarafAdi] = useState<string | null>(null);
  /** Kur otomatik cekilirken / cekilemediginde alan altinda gosterilen not. */
  const [kurNotu, setKurNotu] = useState<string | null>(null);
  /** En son kuru cekilen "cins|tarih" - kayitli kartin kuru acilista ezilmesin. */
  const sonKurAnahtari = useRef<string | null>(null);

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    setHata(null);
    try {
      const m = await api.kartAlanlari(kaynak);
      setMeta(m);
      setYetki(m.yetki);

      const bosDetaylar: Record<string, DetayDurumu> = {};
      m.detaylar.forEach(d => { bosDetaylar[d.ad] = bosDetay() });

      if (yeniMi) {
        const baslangic: Record<string, Deger> = {};
        // Yeni kayitta Durum her zaman "Aktif" gelsin (kullanici: "yeni kart kaydında
        // varsa durum hep aktif gelsin") - DurumKodlari'nde 1 = Aktif (KartKatalogu.cs).
        m.alanlar.forEach(a => {
          baslangic[a.ad] = a.ad === 'durum' ? '1'
            : a.ad === 'subeId' && oturum.subeId ? String(oturum.subeId)
            : a.tip === 'mantik' ? false : '';
        });
        // Ekrana ozel mantik varsayilan (ör. Tedarikçi Listesi -> tedarikci:true) -
        // yukaridaki genel "false" varsayilaninin UZERINE yazar.
        // ONCE katalog varsayilanlari (sunucudan), SONRA ekrana ozel olanlar -
        //   ekran (or. Cek Listesi'nden "Yeni" -> tur=1) katalogu ezebilsin.
        Object.entries(m.varsayilanlar ?? {}).forEach(([ad, deger]) => {
          baslangic[ad] = deger as Deger;
        });
        if (yeniKayitVarsayilanlari) {
          Object.entries(yeniKayitVarsayilanlari).forEach(([ad, deger]) => { baslangic[ad] = deger });
        }
        setDeger(baslangic);
        setIlkDeger(baslangic);
        sonKurAnahtari.current = null;   // yeni kartta kur cekilsin
        // Katalog istiyorsa (cek/senet) kart acilir acilmaz CARI secimi gelsin -
        //   yeni kayitta ilk is odur; kullanici kapatip alandan da secebilir.
        if (m.acilistaTarafSecimi) setTarafSecimAcik(true);
        setSurum(undefined);
        setDetaylar(bosDetaylar);
      } else {
        const k = await api.kartOku(kaynak, id as number);
        const gelen: Record<string, Deger> = {};
        m.alanlar.forEach(a => {
          const d = k.kart[a.ad];
          gelen[a.ad] = a.tip === 'mantik' ? Number(d) === 1 : (d === null || d === undefined ? '' : String(d));
        });
        setDeger(gelen);
        setIlkDeger(gelen);
        // KAYITLI kur tarihseldir - acilista bugunun kuruyla EZILMEMELI. Yuklenen
        //   cins/tarih "zaten cekilmis" sayilir; kullanici birini degistirirse
        //   anahtar degisir ve kur o zaman yenilenir.
        sonKurAnahtari.current = m.doviz
          ? `${String(gelen[m.doviz.cinsAlani] ?? '')}|` +
            `${m.doviz.tarihAlani ? String(gelen[m.doviz.tarihAlani] ?? '').slice(0, 10) : ''}`
          : null;
        setSurum(k.kart.surum as string | undefined);
        setYetki(k.yetki);
        m.detaylar.forEach(d => {
          bosDetaylar[d.ad] = bosDetay(k.detaylar?.[d.ad] ?? []);
        });
        setDetaylar(bosDetaylar);
      }
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally {
      setYukleniyor(false);
    }
  }, [kaynak, id, yeniMi, yeniKayitVarsayilanlari]);

  useEffect(() => { void yukle() }, [yukle]);

  // ------------------------------------------------------------ doviz ------
  // Kartta para birimi/kur/tutar ucgeni varsa (katalog: DovizKurali), yerel para
  //   disinda bir birim SECILDIGINDE kur o tarihin kurundan cekilir ve yerel
  //   karsilik gosterilir. Kayitli bir kartin kuru ACILISTA EZILMEZ - kur, belge
  //   gunune ait tarihsel bir degerdir; onu bugunun kuruyla degistirmek gecmis
  //   kaydin anlamini bozardi (asagidaki sonKurAnahtari nobeti).
  const doviz = meta?.doviz ?? null;
  const dovizCinsi = doviz ? String(deger[doviz.cinsAlani] ?? '') : '';
  const dovizTarihi = doviz?.tarihAlani ? String(deger[doviz.tarihAlani] ?? '').slice(0, 10) : '';
  const yerelParada = !doviz || dovizCinsi === '' || dovizCinsi === doviz.yerelPara;

  useEffect(() => {
    if (!doviz || !dovizCinsi) return;
    const anahtar = `${dovizCinsi}|${dovizTarihi}`;
    if (sonKurAnahtari.current === anahtar) return;   // acilis ya da tekrar render
    sonKurAnahtari.current = anahtar;

    if (dovizCinsi === doviz.yerelPara) {
      setDeger(d => ({ ...d, [doviz.kurAlani]: '1' }));
      setKurNotu(null);
      return;
    }
    let iptal = false;
    const tarih = dovizTarihi || new Date().toISOString().slice(0, 10);
    setKurNotu('Kur alınıyor…');
    api.dovizKur(dovizCinsi, tarih)
      .then(y => {
        if (iptal) return;
        if (y.kur && y.kur > 0) {
          setDeger(d => ({ ...d, [doviz.kurAlani]: String(y.kur) }));
          // Kurun GERCEK gunu yazilir: istenen tarihe kur yoksa onceki en yakin
          //   gun kullanilir, "bugunun kuru" demek yanlis olurdu.
          const gun = (y.kurTarihi ?? tarih).slice(0, 10).split('-').reverse().join('.');
          setKurNotu(`${gun} kuru — gerekirse değiştirin`);
        } else {
          setKurNotu('Bu tarihe kur girilmemiş, elle yazın.');
        }
      })
      .catch(() => { if (!iptal) setKurNotu('Kur alınamadı, elle yazın.') });
    return () => { iptal = true };
  }, [doviz, dovizCinsi, dovizTarihi]);

  /** Yerel karsilik ONIZLEMESI - kaydederken sunucu yeniden hesaplar. */
  const yerelTutar = useMemo(() => {
    if (!doviz) return 0;
    const tutar = Number(String(deger[doviz.tutarAlani] ?? '0').replace(',', '.')) || 0;
    const kur = Number(String(deger[doviz.kurAlani] ?? '1').replace(',', '.')) || 1;
    return tutar * kur;
  }, [doviz, deger]);

  /**
   * Alan degisimi. BAGLI alanlari (or. Şube -> Banka) TEMIZLER: banka degisince
   * eski bankanin subesi secili kalirsa "Ziraat + Akbank subesi" gibi tutarsiz
   * kayit olusur.
   */
  const alanDegistir = useCallback((ad: string, v: Deger) => {
    setDeger(d => {
      const yeni = { ...d, [ad]: v };
      meta?.alanlar.forEach(x => { if (x.bagliAlan === ad) yeni[x.ad] = '' });
      return yeni;
    });
  }, [meta]);

  const gruplar = useMemo(() => {
    const harita = new Map<string, KartAlanMeta[]>();
    meta?.alanlar.forEach(a => {
      if (a.ad === 'id') return;
      // ARKA PLAN alani: degeri tasinir (kaydetmede gonderilir) ama CIZILMEZ.
      if (a.gizli) return;
      // Yerel parada Kur (hep 1) ve Yerel Tutar (= Tutar) alanlari GORUNMEZ -
      //   tekrar bilgi, formu uzatmaktan baska ise yaramaz.
      if (yerelParada && doviz && (a.ad === doviz.kurAlani || a.ad === doviz.yerelAlani)) return;
      const g = a.grup ?? 'Genel';
      harita.set(g, [...(harita.get(g) ?? []), a]);
    });
    return [...harita.entries()];
  }, [meta, doviz, yerelParada]);

  /**
   * "Kimlik" grubu sekme DEGIL — mockup'taki idstrip gibi ust seritte, her sekmede
   * sabit gorunur (kod/unvan/durum gibi karti tanimlayan alanlar).
   */
  const kimlikAlanlari = useMemo(
    () => gruplar.find(([ad]) => ad === KIMLIK_GRUP)?.[1] ?? [],
    [gruplar],
  );

  /** Mockup'taki gibi sekmeli kart: Kimlik disindaki her alan grubu + her detay tablosu ayri sekme. */
  const sekmeler = useMemo<SekmeTanimi[]>(() => {
    const dokumanliKart = personelGibiKart || kaynak === 'kisi' || kaynak === 'cari' || kaynak === 'stok';
    const yorumMedyaSekmesiVar = (yerTutucuSekmeler ?? []).includes('Yorum / Medya');
    const s: SekmeTanimi[] = gruplar
      .filter(([ad]) => ad !== KIMLIK_GRUP)
      .filter(([ad]) => !(kaynak === 'hasta' && ad === 'İletişim'))
      .map(([ad, alanlar]) => ({ tur: 'grup', anahtar: grupSekmeAnahtari(ad), baslik: ad, alanlar }));
    if (kaynak === 'cari' || kaynak === 'hasta') {
      const genel = s.findIndex(sekme => sekme.tur === 'grup' && sekme.baslik === 'Genel');
      const fatura = s.findIndex(sekme => sekme.tur === 'grup' && sekme.baslik === 'Fatura Bilgileri');
      if (genel >= 0 && fatura >= 0 && fatura !== genel + 1) {
        const [sekme] = s.splice(fatura, 1);
        const yeniGenel = s.findIndex(x => x.tur === 'grup' && x.baslik === 'Genel');
        s.splice(yeniGenel + 1, 0, sekme);
      }
    }
    meta?.detaylar.forEach(d => {
      // Cari/Kisi/Personel'e ozel: Adresler mockup'ta ayri sekme DEGIL, ilgili grup
      //   sekmesinin icine gomulu bir tek-satir form - kendi sekmesi acilmasin (bkz.
      //   asagida grup render'i - Personel'de İletişim sekmesine gomulu, ik_karti.html).
      if ((kaynak === 'cari' || kaynak === 'kisi' || personelGibiKart) && d.ad === 'adresler') return;
      // Personel'de Eğitim/Sertifika artık Genel sekmesinde Kimlik Bilgileri'nin altında
      //   gömülü grid; ayrı sekme açılmasın.
      if (personelGibiKart && d.ad === 'egitimler') return;
      // Hasta'da kimlik/hasta bilgisi Genel sekmesindeki özetin içinde kalır; izinler
      // hasta kartında kullanılmaz, ayrı sekme olarak gösterilmez.
      if (kaynak === 'hasta' && (d.ad === 'ozluk' || d.ad === 'izinler')) return;
      // Personel'de acil kişiler ik_karti.html mockup'ta İletişim sekmesinin altında
      // gömülü grid; ayrı sekme açılmasın.
      if (personelGibiKart && d.ad === 'acilKisiler') return;
      s.push({ tur: 'detay', anahtar: detaySekmeAnahtari(d.ad), baslik: d.baslik, detay: d });
    });
    (yerTutucuSekmeler ?? []).forEach(baslik => {
      if (dokumanliKart && !yeniMi && baslik === 'Yorum / Medya') {
        s.push({ tur: 'ozel', anahtar: 'ozel:dokuman', baslik: 'Resim / Doküman' });
      } else if (kaynak === 'stok' && !yeniMi && baslik === 'Hareketler') {
        // Salt okunur hareket dokumu (stok_karti.html "Hareketler").
        s.push({ tur: 'ozel', anahtar: 'ozel:stokHareket', baslik });
      } else if (kaynak === 'stok' && !yeniMi && baslik === 'Stok Durumu') {
        // Artik yer tutucu degil: depo bazli miktar/rezerve gercek veriden gelir
        //   (stok_karti.html "Stok Durumu"). Yeni kayitta stok_id yok - kart once
        //   kaydedilmeli, o yuzden yeniMi'de yer tutucu olarak kalir.
        s.push({ tur: 'ozel', anahtar: 'ozel:stokDurum', baslik });
      } else {
        s.push({ tur: 'yerTutucu', anahtar: `y:${baslik}`, baslik });
      }
    });
    // Rol'e ozel: Yetki Matrisi generic Detay degil (satir ekle/sil yok, sabit yetki
    //   listesi x Gor/Ekle/Degistir/Sil checkbox'lari) - ayri "ozel" sekme. Yeni kayitta
    //   henuz rolId yok, kart once kaydedilmeli (Kisi'nin İlgili Kişiler'iyle ayni kural).
    if (kaynak === 'rol' && !yeniMi) {
      s.push({ tur: 'ozel', anahtar: 'ozel:yetkiler', baslik: 'Yetki Matrisi' });
    }
    // Personel'e ozel: Resim/Doküman galerisi (057_dokuman.sql, generic DokumanGalerisi -
    // Kişi/Cari/Stok'ta da aynı bileşen kullanılabilir). Yeni kayıtta henüz id yok.
    if (dokumanliKart && !yeniMi && !yorumMedyaSekmesiVar) {
      s.push({ tur: 'ozel', anahtar: 'ozel:dokuman', baslik: 'Resim / Doküman' });
    }
    return s;
  }, [gruplar, meta, yerTutucuSekmeler, kaynak, yeniMi, personelGibiKart]);

  const [aktifSekme, setAktifSekme] = useState<string | null>(null);
  const kayitAnahtari = `${kaynak}:${id}`;
  const ilkSekmeAnahtari = sekmeler[0]?.anahtar ?? null;
  useEffect(() => {
    if (ilkSekmeAnahtari) setAktifSekme(ilkSekmeAnahtari);
  }, [kayitAnahtari, ilkSekmeAnahtari]);

  /** Hangi alan hangi sekmede — hata gelince o sekmeye atlamak icin. Kimlik her zaman gorunur, atlamaya gerek yok. */
  const sekmeBul = useCallback((alanAdi: string): string | null => {
    if (alanAdi.includes('.')) {
      const detayAd = alanAdi.split('.')[0];
      if (kaynak === 'cari' && detayAd === 'adresler') return grupSekmeAnahtari('Fatura Bilgileri');
      if (kaynak === 'hasta' && detayAd === 'adresler') return grupSekmeAnahtari('Fatura Bilgileri');
      if (kaynak === 'kisi' && detayAd === 'adresler') return grupSekmeAnahtari('Genel');
      if (personelGibiKart && detayAd === 'adresler') return grupSekmeAnahtari('İletişim');
      if (personelGibiKart && detayAd === 'egitimler') return grupSekmeAnahtari('Genel');
      return detaySekmeAnahtari(detayAd);
    }
    const alan = meta?.alanlar.find(a => a.ad === alanAdi);
    const grup = alan?.grup ?? 'Genel';
    if (kaynak === 'hasta' && grup === 'İletişim') return grupSekmeAnahtari('Genel');
    return grup === KIMLIK_GRUP ? null : grupSekmeAnahtari(grup);
  }, [meta, kaynak, personelGibiKart]);

  /**
   * Yalniz DEGISEN alanlar gonderilir (§3.2: alan gondermemek "degistirme" demektir).
   *
   * YENI kayitta bos birakilan alan HIC GONDERILMEZ - null gondermek NOT NULL +
   * varsayilanli kolonlarda (durum, bayraklar) kaydi patlatiyordu. Bos gonderilmeyince
   * veritabani varsayilani devreye girer.
   * DUZENLEMEDE ise bos deger anlamlidir: kullanici alani temizlemis olabilir -> null.
   */
  const degisenAlanlar = useCallback(() => {
    const govde: Record<string, unknown> = {};
    meta?.alanlar.forEach(a => {
      if (!a.yazilabilir || a.ad === 'id') return;
      const yeni = deger[a.ad];

      if (yeniMi) {
        if (a.tip === 'mantik') {
          if (yeni) { govde[a.ad] = true; return }
          // EKRAN varsayilani alani acikca FALSE yaptiysa bunu SUNUCUYA SOYLE:
          //   sessizce atlanirsa katalog varsayilani devreye girer ve Aday
          //   Musterisi "musteri" olarak, Tedarikci de "musteri+tedarikci"
          //   olarak kaydedilirdi (rol bayraklari birbirine karisiyordu).
          if (yeniKayitVarsayilanlari && a.ad in yeniKayitVarsayilanlari) govde[a.ad] = false;
          return;
        }
        if (yeni === '' || yeni === null || yeni === undefined) return;
        govde[a.ad] = yeni;
        return;
      }

      if (yeni === ilkDeger[a.ad]) return;
      govde[a.ad] = a.tip === 'mantik' ? Boolean(yeni) : (yeni === '' ? null : yeni);
    });
    return govde;
  }, [meta, deger, ilkDeger, yeniMi, yeniKayitVarsayilanlari]);

  const kaydedilmemisDegisiklikVar = useMemo(() => {
    const kartDegisti = meta?.alanlar.some(a => {
      if (!a.yazilabilir || a.ad === 'id') return false;
      return deger[a.ad] !== ilkDeger[a.ad];
    }) ?? false;
    if (kartDegisti) return true;

    return Object.values(detaylar).some(durum => {
      const fark = detayFarki(durum);
      return (fark.eklenen?.length ?? 0) + (fark.degisen?.length ?? 0) + (fark.silinen?.length ?? 0) > 0;
    });
  }, [meta, deger, ilkDeger, detaylar]);

  const kapatIstendi = useCallback(() => {
    if (kaydedilmemisDegisiklikVar) {
      setKapatmaUyarisi(true);
      return;
    }
    onKapat?.();
  }, [kaydedilmemisDegisiklikVar, onKapat]);

  async function kaydet() {
    // Client-side eposta kontrolu - sunucuya hic gitmeden dur, ilgili sekmeye atla.
    const gecersizEposta = meta?.alanlar.find(a => {
      const v = deger[a.ad];
      return EPOSTA_ALANLARI.has(a.ad) && typeof v === 'string' && v !== '' && !epostaGecerliMi(v);
    });
    if (gecersizEposta) {
      setAlanHatalari(h => ({ ...h, [gecersizEposta.ad]: 'Gecerli bir e-posta adresi girin.' }));
      const hedefSekme = sekmeBul(gecersizEposta.ad);
      if (hedefSekme) setAktifSekme(hedefSekme);
      return;
    }

    setKaydediyor(true);
    setHata(null);
    setAlanHatalari({});
    setCakisma(null);
    setBilgi(null);
    try {
      const govde = {
        surum,
        kart: degisenAlanlar(),
        detaylar: Object.fromEntries(
          Object.entries(detaylar)
            .map(([ad, durum]) => [ad, detayFarki(durum)])
            .filter(([, fark]) => {
              const f = fark as ReturnType<typeof detayFarki>;
              return (f.eklenen?.length ?? 0) + (f.degisen?.length ?? 0) + (f.silinen?.length ?? 0) > 0;
            })),
      };

      // Personel'de "unvan" hic gosterilmiyor/duzenlenmiyor (kullanici: ad/soyad kullanilsin)
      // - DB'de NOT NULL oldugu icin Kaydet'te ad+soyad'dan burada birlestirilip eklenir.
      if (personelGibiKart) {
        const ad = String(deger.ad ?? '').trim();
        const soyad = String(deger.soyad ?? '').trim();
        const unvan = [ad, soyad].filter(Boolean).join(' ');
        if (unvan) govde.kart.unvan = unvan;
      }

      const yanit = yeniMi
        ? await api.kartEkle(kaynak, govde)
        : await api.kartGuncelle(kaynak, id as number, govde);

      onKaydedildi?.(Number(yanit.kart.id));
      onKapat?.();
      return;
    } catch (h) {
      if (h instanceof ApiHatasi) {
        if (h.dogrulamaMi && h.hata.alanlar) {
          setAlanHatalari(Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])));
          setHata(h.message);
          const hedefSekme = h.hata.alanlar[0] ? sekmeBul(h.hata.alanlar[0].alan) : null;
          if (hedefSekme) setAktifSekme(hedefSekme);
        } else if (h.cakismaMi) {
          setCakisma({
            alanlar: h.hata.cakisanAlanlar ?? [],
            guncel: h.hata.guncelDeger ?? {},
          });
        } else {
          setHata(`${h.hata.kod}: ${h.message}${h.hata.engel ? ` (${h.hata.engel.tablo}: ${h.hata.engel.adet})` : ''}`);
        }
      } else {
        setHata(String(h));
      }
    } finally {
      setKaydediyor(false);
    }
  }

  async function sil() {
    setHata(null);
    try {
      await api.kartSil(kaynak, id as number);
      onKapat?.();
    } catch (h) {
      if (h instanceof ApiHatasi) {
        setHata(h.hata.engel
          ? `${h.message} (${h.hata.engel.tablo}: ${h.hata.engel.adet} kayit)`
          : `${h.hata.kod}: ${h.message}`);
      }
    }
  }

  if (yukleniyor)
    return (
      <Modal baslik={baslik ?? kaynak} dar={TEK_SUTUN_KARTLAR.has(kaynak)} alt={<button className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>} onKapat={onKapat}>
        <div className="yukleniyor-satir">Yukleniyor…</div>
      </Modal>
    );

  if (!meta)
    return (
      <Modal baslik={baslik ?? kaynak} dar={TEK_SUTUN_KARTLAR.has(kaynak)} alt={<button className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>} onKapat={onKapat}>
        <div className="hata-kutusu">{hata}</div>
      </Modal>
    );

  const salt = !yeniMi && !yetki.duzenle;
  const aktif = sekmeler.find(s => s.anahtar === aktifSekme) ?? sekmeler[0];

  /** Sekme icinde mockup'taki gibi alt-bolumler (or. Genel -> Tanım/Sınıflandırma). */
  const altGruplaVar = (alanlar: KartAlanMeta[]) => {
    const harita = new Map<string, KartAlanMeta[]>();
    alanlar.forEach(a => {
      const g = a.altGrup ?? '';
      harita.set(g, [...(harita.get(g) ?? []), a]);
    });
    return [...harita.entries()];
  };

  const renderGirdi = (a: KartAlanMeta) => (
    a.tip === 'mantik' ? (
      <input
        key={a.ad}
        type="checkbox"
        checked={Boolean(deger[a.ad])}
        disabled={salt || !a.yazilabilir}
        onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.checked }))}
      />
    ) : kaynak === 'kisi' && a.ad === 'bagId' ? (
      // "Cariye Bağla" butonu + TarafArama modaliyla degistiriliyor - burada duz salt-okunur
      // gorunum (kullanici: "bagli cari readonly edit olsun"). Yazilabilir hala TRUE (kaydet
      // payload'una girsin), sadece render FARKLI - select degil, disabled text input.
      <div key={a.ad} className="tel-girdi">
        <input
          readOnly
          disabled
          value={bagliTarafAdi ?? (a.kodlar && a.kodlar[String(deger[a.ad] ?? '')]) ?? ''}
          placeholder="Bağlanmadı"
        />
        {!salt && deger[a.ad] && (
          <button type="button" className="mini" title="Boşalt"
            onClick={() => { setDeger(d => ({ ...d, [a.ad]: '' })); setBagliTarafAdi(null) }}>
            ×
          </button>
        )}
      </div>
    ) : doviz && a.ad === doviz.yerelAlani ? (
      // Yerel karsilik: HESAPLANIR, yazilamaz (sunucu da ayni carpimi yapar).
      <input
        key={a.ad}
        readOnly
        disabled
        value={yerelTutar.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
               + ' ' + doviz.yerelPara}
      />
    ) : a.kodlar ? (() => {
      // BAGLI liste (Şube -> Banka): yalniz secili ust'un altindakiler.
      const ustDegeri = a.bagliAlan ? String(deger[a.bagliAlan] ?? '') : '';
      const secenekler = Object.entries(a.kodlar).filter(
        ([k]) => !a.bagliAlan || (a.kodUst?.[k] ?? '') === ustDegeri);
      const ustBos = Boolean(a.bagliAlan) && ustDegeri === '';
      return (
        <select
          key={a.ad}
          value={String(deger[a.ad] ?? '')}
          disabled={salt || !a.yazilabilir || ustBos}
          onChange={e => alanDegistir(a.ad, e.target.value)}
        >
          {/* Bos secenek yalniz ZORUNLU OLMAYAN alanlarda: zorunlu bir kod alaninda
              (ör. Depo > Durum) "—" secilebilir gorunmesi yaniltici. */}
          {!a.zorunlu && (
            <option value="">
              {/* Bagli listede bos secenek NEDEN bos oldugunu soylesin: kullanici
                  "sube gelmedi" diye ariyordu - once banka secilmesi ya da o
                  bankaya hic sube girilmemis olmasi bilgisi ekranda yok. */}
              {ustBos ? `— önce ${meta?.alanlar.find(x => x.ad === a.bagliAlan)?.baslik ?? 'üst'} seçin`
                : a.bagliAlan && secenekler.length === 0 ? '— tanımlı kayıt yok'
                : '—'}
            </option>
          )}
          {secenekler.map(([k, v]) => <option key={k} value={k}>{v}</option>)}
        </select>
      );
    })() : TELEFON_ALANLARI.has(a.ad) ? (
      <TelefonGirdi
        key={a.ad}
        value={String(deger[a.ad] ?? '')}
        disabled={salt || !a.yazilabilir}
        onChange={v => setDeger(d => ({ ...d, [a.ad]: v }))}
      />
    ) : (
      <input
        key={a.ad}
        // Tarih alani TAKVIM kutusu olur; deger ham ISO gelir ("2026-08-24T00:00:00")
        //   ve type=date bunu GOSTEREMEZ - 10 karaktere kirpilir. Eskiden duz metin
        //   kutusuydu ve kullanici ISO damgasini goruyordu.
        type={a.tip === 'tarih' ? 'date' : EPOSTA_ALANLARI.has(a.ad) ? 'email' : 'text'}
        value={a.tip === 'tarih' ? String(deger[a.ad] ?? '').slice(0, 10)
                                 : String(deger[a.ad] ?? '')}
        maxLength={a.enFazlaUzunluk ?? undefined}
        disabled={salt || !a.yazilabilir}
        onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.value }))}
        onBlur={e => {
          if (EPOSTA_ALANLARI.has(a.ad)) {
            const gecerli = epostaGecerliMi(e.target.value);
            setAlanHatalari(h => {
              if (gecerli) { const { [a.ad]: _cikar, ...kalan } = h; return kalan }
              return { ...h, [a.ad]: 'Gecerli bir e-posta adresi girin.' };
            });
          }
        }}
      />
    )
  );

  const renderAlan = (a: KartAlanMeta) => (
    <label key={a.ad} className={`alan tip-${a.tip}`}>
      <span className="etiket">
        {a.baslik}{a.zorunlu && <b className="zorunlu"> *</b>}
      </span>
      {renderGirdi(a)}
      {/* Kur kutusunun altinda kurun NEREDEN geldigi (tarih kuru / bulunamadi) -
          otomatik gelen bir sayiyi kullanicinin sorgusuz kabul etmesi beklenmez. */}
      {doviz && a.ad === doviz.kurAlani && kurNotu && (
        <span className="alan-notu">{kurNotu}</span>
      )}
      {alanHatalari[a.ad] && <span className="alan-hata">{alanHatalari[a.ad]}</span>}
    </label>
  );

  /**
   * Mockup'taki ".ikili" (or. Raf Ömrü: sayi + birim combo TEK etiket altinda yan yana).
   * `eslesAlan` ile baska bir alani gosteren alan, o alani kendi satirina EKLER; hedef alan
   * ayri satir olarak TEKRAR RENDER EDILMEZ.
   */
  const renderAlanListesi = (alanlar: KartAlanMeta[]) => {
    const eslesenler = new Set(alanlar.map(a => a.eslesAlan).filter(Boolean));
    return alanlar
      .filter(a => !eslesenler.has(a.ad))
      .map(a => {
        const hedef = a.eslesAlan ? alanlar.find(x => x.ad === a.eslesAlan) : undefined;
        if (!hedef) return renderAlan(a);
        return (
          <label key={a.ad} className={`alan tip-${a.tip}`}>
            <span className="etiket">
              {a.baslik}{a.zorunlu && <b className="zorunlu"> *</b>}
            </span>
            <div className="ikili">{renderGirdi(a)}{renderGirdi(hedef)}</div>
            {(alanHatalari[a.ad] || alanHatalari[hedef.ad]) && (
              <span className="alan-hata">{alanHatalari[a.ad] || alanHatalari[hedef.ad]}</span>
            )}
          </label>
        );
      });
  };

  return (
    <Modal
      baslik={`${baslik ?? kaynak} ${yeniMi ? '— Yeni' : `#${id}`}`}
      dar={TEK_SUTUN_KARTLAR.has(kaynak)}
      ustBilgi={
        <>
          {surum && <span className="rozet gri">surum {surum}</span>}
          {salt && <span className="rozet uyari">salt okunur</span>}
        </>
      }
      ustSerit={kimlikAlanlari.length > 0 && (
        <div className="kaid">
          {/* Kisi'ye ozel: Kisi Kodu dar, Unvan genis (kullanici: "kod edit yariya dussun,
              onu unvana ekle") - idstrip'in 4 sabit alani (Kod/Unvan/Departman/Gorev). */}
          <div className={`alan-izgara${kaynak === 'kisi' ? ' kaid-kisi' : ''}`}>
            {renderAlanListesi(kimlikAlanlari)}
          </div>
        </div>
      )}
      sekmeBar={sekmeler.length > 1 && (
        <div className="katab">
          {sekmeler.map(s => (
            <div
              key={s.anahtar}
              className={`kat${s.anahtar === aktif?.anahtar ? ' on' : ''}`}
              onClick={() => setAktifSekme(s.anahtar)}
            >
              {s.baslik}
              {s.tur === 'detay' && <span className="b">{(detaylar[s.detay.ad] ?? bosDetay()).guncel.length}</span>}
            </div>
          ))}
        </div>
      )}
      onKapat={kapatIstendi}
      alt={
        <>
          {!salt && (
            <button className="d bir" disabled={kaydediyor} onClick={() => void kaydet()}>
              {kaydediyor ? 'Kaydediliyor…' : 'Kaydet'}
            </button>
          )}
          {!yeniMi && yetki.sil && (
            <button className="d teh" onClick={() => void sil()}>Sil</button>
          )}
          {/* Kisi'ye ozel: "Bagli Cari" alani artik salt-okunur gorunum (asagida renderGirdi),
              tek degistirme yolu bu buton + TarafArama modali. Kisi zaten bagliysa (bagId
              dolu) buton GORUNMEZ (kullanici) - once "x" ile bag bosaltilmali. */}
          {kaynak === 'kisi' && !salt && !cariyeBaglaGizli && !deger.bagId && (
            <button className="d" onClick={() => setCariyeBaglaAcik(true)}>🔗 Cariye Bağla</button>
          )}
          <button className="d kapat-dugmesi" onClick={kapatIstendi}>Kapat</button>
          {/* Cari'ye ozel: Musteri/Tedarikci rolleri hizlı erisim icin arac cubuguna,
              Kaydet/Sil ile ayni satira, saga yanasik olarak da tasindi (Roller sekmesindeki
              alanlarla AYNI deger - ikisi de senkron, tekrar degil). */}
          {kaynak === 'cari' && meta.alanlar.some(a => a.ad === 'musteri') && (
            <span style={{ marginLeft: 'auto', display: 'flex', gap: 12, alignItems: 'center' }}>
              <label className="satir-ici">
                <input
                  type="checkbox"
                  checked={Boolean(deger.musteri)}
                  disabled={salt}
                  onChange={e => setDeger(d => ({ ...d, musteri: e.target.checked }))}
                />
                Müşteri
              </label>
              <label className="satir-ici">
                <input
                  type="checkbox"
                  checked={Boolean(deger.tedarikci)}
                  disabled={salt}
                  onChange={e => setDeger(d => ({ ...d, tedarikci: e.target.checked }))}
                />
                Tedarikçi
              </label>
            </span>
          )}
        </>
      }
    >
      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      {cakisma && (
        <div className="cakisma-kutusu">
          <b>Bu kaydi baska bir kullanici degistirdi.</b>
          {cakisma.alanlar.length > 0 && <div>Cakisan alanlar: {cakisma.alanlar.join(', ')}</div>}
          <div className="cakisma-arac">
            <button className="d" onClick={() => { setCakisma(null); void yukle() }}>Guncel hali al (degisikliklerim gider)</button>
            <button className="d" onClick={() => {
              // Sunucudaki guncel surumu alip kendi degisikliklerimi UZERINE yaz
              setSurum(String(cakisma.guncel.surum ?? ''));
              setCakisma(null);
            }}>Benim degisikliklerimi uygula</button>
          </div>
        </div>
      )}

      {aktif?.tur === 'grup' && (() => {
        const gruplanmis = altGruplaVar(aktif.alanlar);
        const adli = gruplanmis.filter(([b]) => b);
        // musteri/tedarikci toolbar'da (kaydet/sil yaninda) checkbox olarak zaten var,
        // ad/soyad kart'ta hic gosterilmiyor - burada tekrarlanmasin (cari'ya ozel). "kisi"
        // check'i de KALDIRILDI (kullanici) - artik ayri "Kişi Kartı" + "İlgili Kişiler"
        // akisi var, cari uzerinde dogrudan kisi bayragi degistirmek gereksiz/kafa karistirici.
        const gizli = kaynak === 'cari' ? new Set(['ad', 'soyad', 'musteri', 'tedarikci', 'kisi'])
          : kaynak === 'kisi' ? new Set(['kisi'])
          // Personel: "unvan" ad+soyad'dan Kaydet'te turetiliyor, ayrica gosterilmez/
          //   duzenlenmez (kullanici: "ad soyad kullan"); "personel" bayragi Kisi'nin
          //   "kisi" bayragiyla ayni sebeple gizli. "vkno"/"gorev" de gizli - normal
          //   adsiz akistan CIKARILIP PersonelKimlikOzet.tsx'e props olarak geciyor
          //   (ik_karti.html: TCKN "Kimlik Bilgileri" kutusunda, Görev "Özet" kutusunda).
          : kaynak === 'personel' ? new Set(['personel', 'unvan', 'vkno', 'gorev'])
          : kaynak === 'hasta' ? new Set(['hasta', 'grup', 'unvan', 'gorev'])
          : new Set<string>();
        const adsiz = (gruplanmis.find(([b]) => !b)?.[1] ?? []).filter(a => !gizli.has(a.ad));
        // Cari'ya ozel: Iletisim + Notlar ayni (sol) sutunda ust-alt, Tanımlama sagda.
        const iletisim = adli.find(([b]) => b === 'İletişim');
        const notlar = adli.find(([b]) => b === 'Notlar');
        const digerAdli = adli.filter(([b]) => b !== 'İletişim' && b !== 'Notlar');
        const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
        const acilDetay = meta.detaylar.find(d => d.ad === 'acilKisiler');
        const iletisimAlanAdlari = new Set(['telefon', 'cepTel', 'eposta', 'epostaWeb']);
        const personelIletisimSekmesi = personelGibiKart
          && (iletisim !== undefined || aktif.alanlar.some(a => iletisimAlanAdlari.has(a.ad)));
        if (personelIletisimSekmesi) {
          const iletisimAlanlari = iletisim?.[1] ?? aktif.alanlar.filter(a => !gizli.has(a.ad));
          return (
            <div className="personel-iletisim-yerlesim">
              <div className="kasira">
                <div className="kagrup">
                  <h6>İletişim</h6>
                  <div className="alan-izgara tek-sutun">{renderAlanListesi(iletisimAlanlari)}</div>
                </div>
                {adresDetay && (
                  <TekAdres
                    meta={adresDetay}
                    durum={detaylar[adresDetay.ad] ?? bosDetay()}
                    saltOkunur={salt || adresDetay.saltOkunur}
                    onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
                    baslik="Ev Adresi"
                    turGizli
                    sabitTur="1"
                  />
                )}
              </div>
              {acilDetay && (
                <GenDetayTablo
                  meta={acilDetay}
                  durum={detaylar[acilDetay.ad] ?? bosDetay()}
                  saltOkunur={salt || acilDetay.saltOkunur}
                  hatalar={alanHatalari}
                  onDegis={yeni => setDetaylar(t => ({ ...t, [acilDetay.ad]: yeni }))}
                />
              )}
            </div>
          );
        }
        const adliBlok = (
          <>
            {/* Mockup: Tanım/Sınıflandırma · Vergi & Ana Birim ... AYNI SATIRDA yan yana (.row > .col > .grp).
                Personel'de bu sarmalayici, AltGrup'lu (adli) alan olmasa BILE acik kalmali -
                PersonelKimlikOzet/TekAdres gibi ozel bilesenler AltGrup'a bagli DEGIL, asagida
                bu blogun icinde render ediliyor (bug: "genel sekmesinde sadece 2 alan var" -
                adli.length===0 oldugu icin butun kasira hic acilmiyordu). */}
            {(adli.length > 0 || personelGibiKart) && (
              <div className="kasira">
                {iletisim && (
                  <div className="kasutun">
                    <div className="kagrup">
                      <h6>{iletisim[0]}</h6>
                      <div className="alan-izgara tek-sutun">{renderAlanListesi(iletisim[1])}</div>
                    </div>
                    {notlar && kaynak !== 'cari' && (
                      <div className="kagrup">
                        <h6>{notlar[0]}</h6>
                        <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
                      </div>
                    )}
                  </div>
                )}
                {digerAdli.map(([altBaslik, alanlar]) => {
                  // Cari'ye ozel: Tanımlama kutusunda dort cift AYNI SATIRDA yan yana,
                  // sirayla (kullanici): Kategori/İlk Temas, Sektör/Alt Sektör, Sınıf/Bölge,
                  // Temsilci/Özel Kod.
                  const ciftler = kaynak === 'cari' && altBaslik === 'Tanımlama'
                    ? [['kategori', 'ilkTemas'], ['sektor', 'altSektor'], ['sinif', 'bolge'], ['temsilci', 'ozelKod']]
                    : [];
                  const ciftliAlanlar = ciftler.map(cift =>
                    cift.map(ad => alanlar.find(a => a.ad === ad)).filter(a => a !== undefined));
                  const digerAlanlar = alanlar.filter(a => !ciftliAlanlar.flat().includes(a));
                  const hastaVergiNoAlan = kaynak === 'hasta' && aktif.baslik === 'Fatura Bilgileri' && altBaslik === 'Fatura / Vergi Kimligi'
                    ? meta.alanlar.find(a => a.ad === 'vkno')
                    : undefined;
                  return (
                    <div className="kagrup" key={altBaslik}>
                      <h6>{altBaslik}</h6>
                      <div className="alan-izgara tek-sutun">
                        {ciftliAlanlar.map((cift, i) => cift.length > 0 && (
                          <div className="adres-satir" key={i}>{renderAlanListesi(cift)}</div>
                        ))}
                        {renderAlanListesi(digerAlanlar)}
                        {hastaVergiNoAlan && (
                          <label className="alan tip-metin">
                            <span className="etiket">Vergi No{hastaVergiNoAlan.zorunlu && <b className="zorunlu"> *</b>}</span>
                            <input
                              value={String(deger.vkno ?? '')}
                              maxLength={hastaVergiNoAlan.enFazlaUzunluk ?? undefined}
                              disabled={salt}
                              onChange={e => setDeger(d => ({ ...d, vkno: e.target.value }))}
                            />
                            {alanHatalari.vkno && <span className="alan-hata">{alanHatalari.vkno}</span>}
                          </label>
                        )}
                      </div>
                    </div>
                  );
                })}
                {/* Kisi'ye ozel: kisi_karti.html'deki "Adres" kutusu - GRID DEGIL, TEK adres
                    (kullanici: "grid olmasin tek adres"). Iletisim kutusuyla AYNI satirda
                    (kasira icinde) - genislik esitlensin diye (kullanici: "iletisim kutusu
                    kadar olsun"). Ayni taraf_adres tablosu, sadece tek satir gosterilir. */}
                {kaynak === 'kisi' && aktif.baslik === 'Genel' && (() => {
                  const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
                  if (!adresDetay) return null;
                  return (
                    <>
                      <TekAdres
                        meta={adresDetay}
                        durum={detaylar[adresDetay.ad] ?? bosDetay()}
                        saltOkunur={salt || adresDetay.saltOkunur}
                        onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
                      />
                      <KartResimKutusu
                        kartAdi="kisi"
                        kaynakId={yeniMi ? undefined : (id as number)}
                        saltOkunur={salt}
                      />
                    </>
                  );
                })()}
                {/* Personel'e ozel: ik_karti.html mockup'ta Genel sekmesinde "Kimlik
                    Bilgileri" (TCKN + Ozluk'ten dogum/cinsiyet/vb) + "Özet" (Pozisyon +
                    İşe Giriş) kutulari - iki farkli veri kaynagini (taraf + personel_ozluk)
                    BIRLESTIRDIGI icin ozel bilesen (PersonelKimlikOzet.tsx). */}
                {personelGibiKart && aktif.baslik === 'Genel' && (() => {
                  const ozlukDetay = meta.detaylar.find(d => d.ad === 'ozluk');
                  const egitimDetay = meta.detaylar.find(d => d.ad === 'egitimler');
                  const vknoAlan = meta.alanlar.find(a => a.ad === 'vkno');
                  const gorevAlan = meta.alanlar.find(a => a.ad === 'gorev');
                  if (!ozlukDetay || !vknoAlan || !gorevAlan) return null;
                  const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
                  const hastaIletisimAlanlari = kaynak === 'hasta'
                    ? (gruplar.find(([ad]) => ad === 'İletişim')?.[1] ?? [])
                    : [];
                  return (
                    <PersonelKimlikOzet
                      kartAdi={kaynak}
                      vknoAlan={vknoAlan}
                      vkno={String(deger.vkno ?? '')}
                      onVknoDegis={v => setDeger(d => ({ ...d, vkno: v }))}
                      gorevAlan={gorevAlan}
                      gorev={String(deger.gorev ?? '')}
                      onGorevDegis={v => setDeger(d => ({ ...d, gorev: v }))}
                      ozlukMeta={ozlukDetay}
                      ozlukDurum={detaylar[ozlukDetay.ad] ?? bosDetay()}
                      saltOkunur={salt}
                      onOzlukDegis={yeni => setDetaylar(t => ({ ...t, [ozlukDetay.ad]: yeni }))}
                      kaynakId={yeniMi ? undefined : (id as number)}
                      ozetGizli={kaynak === 'hasta'}
                      vknoGizli={kaynak === 'hasta'}
                      kimlikSutunGenisligi={kaynak === 'hasta' ? '420px' : undefined}
                      fotoSolEkOnce={kaynak === 'hasta'}
                      fotoSolEk={hastaIletisimAlanlari.length > 0 && (
                        <div className="kasutun" style={{ flex: '1 1 260px' }}>
                          <div className="kagrup">
                            <h6>İletişim</h6>
                            <div className="alan-izgara tek-sutun">{renderAlanListesi(hastaIletisimAlanlari)}</div>
                          {kaynak === 'hasta' && adresDetay && (
                            <TekAdres
                              meta={adresDetay}
                              durum={detaylar[adresDetay.ad] ?? bosDetay()}
                              saltOkunur={salt || adresDetay.saltOkunur}
                              onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
                              baslik="Ev Adresi"
                              turGizli
                              sabitTur="1"
                              grupYok
                              ilIlceAyniSatir
                              baslikGizli
                            />
                          )}
                          </div>
                        </div>
                      )}
                      egitimler={kaynak !== 'hasta' && egitimDetay && (
                        <GenDetayTablo
                          meta={egitimDetay}
                          durum={detaylar[egitimDetay.ad] ?? bosDetay()}
                          saltOkunur={salt || egitimDetay.saltOkunur}
                          hatalar={alanHatalari}
                          onDegis={yeni => setDetaylar(t => ({ ...t, [egitimDetay.ad]: yeni }))}
                        />
                      )}
                    />
                  );
                })()}
                {!iletisim && notlar && kaynak !== 'cari' && (
                  <div className="kagrup" key="Notlar">
                    <h6>{notlar[0]}</h6>
                    <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
                  </div>
                )}
                {(resimYerTutucu || kaynak === 'cari') && aktif.baslik === 'Genel' && (
                  <KartResimKutusu
                    kartAdi={kaynak}
                    kaynakId={yeniMi ? undefined : (id as number)}
                    saltOkunur={salt}
                  />
                )}
              </div>
            )}
          </>
        );
        // SubeId/EklemeTarihi (salt-okunur meta alanlar) EN ALTTA (kullanici: kisi kartinda
        //   sonra cari kartinda da "şube id ve ekleme tarihi en alta gelsin") - Kisi'de Bagli
        //   Cari/Rol/Durum'dan AYRI (o idstrip'in hemen altinda kaliyor); Cari'de zaten baska
        //   adsiz alan kalmadi (kisi/ad/soyad/musteri/tedarikci gizli), direkt en alta duser.
        const enAltAd = new Set(['subeId', 'eklemeTarihi']);
        const adsizUst = adsiz.filter(a => !enAltAd.has(a.ad));
        const adsizAlt = adsiz.filter(a => enAltAd.has(a.ad));
        {/* Kisi'ye ozel: Rol/Durum saga yanasik, aradaki bosluk Bagli Cari editi buyuyerek
            doldurur (kullanici: "rol ve durum saga yanasik, aradaki bosluk bagli cari editi
            doldursun"). Alan sirasi katalogda Bagli Cari, Rol, Durum. */}
        const adsizBlok = adsizUst.length > 0 && (
          <div className={`alan-izgara${kaynak === 'kisi' ? ' kisi-ust-satir' : ''}` +
                          (TEK_SUTUN_KARTLAR.has(kaynak) ? ' tek-sutun ayar-formu' : '')}>
            {renderAlanListesi(adsizUst)}
          </div>
        );
        const adsizAltBlok = adsizAlt.length > 0 && <div className="alan-izgara">{renderAlanListesi(adsizAlt)}</div>;
        return (
          <>
            {/* Kisi'ye ozel: Bagli Cari/Rol/Durum (adsiz) idstrip'in HEMEN ALTINDA, 2. sirada
                (kullanici: "onun altinda 2.sirada Bagli Cari/Rol/Durum olsun") - Iletisim/Adres
                kutularindan ONCE. Diger kaynaklar (Cari) eski sirada: kutular sonra adsiz. */}
            {kaynak === 'kisi' ? (
              <>
                {adsizBlok}
                {adliBlok}
              </>
            ) : (
              <>
                {adliBlok}
                {adsizBlok}
              </>
            )}
            {/* Cari'ye ozel: mockup'ta Genel'in altinda "İlgili Kişiler" tablosu (ayri
                uclar - /api/kart/cari/{id}/kisiler, kartin diger alanlari gibi Kaydet'i
                beklemez). Yeni kayitta henuz id yok, kart once kaydedilmeli. */}
            {kaynak === 'cari' && aktif.baslik === 'Genel' && !yeniMi && (
              <IlgiliKisiler tarafId={id as number} saltOkunur={salt} />
            )}
            {/* Kullanici: "notlar ilgili kişiler altına gelsin" - Cari'de Notlar kutusu
                artik İletişim'in yaninda degil, İlgili Kişiler tablosunun altinda. */}
            {kaynak === 'cari' && aktif.baslik === 'Genel' && notlar && (
              <div className="kasira">
                <div className="kagrup" key="Notlar">
                  <h6>{notlar[0]}</h6>
                  <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
                </div>
              </div>
            )}
            {/* Cari'ye ozel: Adresler mockup'ta ayri sekme degil, Fatura Bilgileri'nin icine
                gomulu GRID (birden fazla adres - fatura/sevkiyat/vb). */}
            {(kaynak === 'cari' || kaynak === 'hasta') && aktif.baslik === 'Fatura Bilgileri' && (() => {
              const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
              if (!adresDetay) return null;
              return (
                <GenDetayTablo
                  meta={adresDetay}
                  durum={detaylar[adresDetay.ad] ?? bosDetay()}
                  saltOkunur={salt || adresDetay.saltOkunur}
                  hatalar={alanHatalari}
                  onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
                />
              );
            })()}
            {/* SubeId/EklemeTarihi GERCEKTEN EN ALTTA - Kisi/Ilgili Kisiler/Adresler
                kutularindan da SONRA (kullanici iki kez duzeltti: onceki yer "ortada"
                kaliyordu, İlgili Kişiler grid'inden ONCE geliyordu). */}
            {adsizAltBlok}
          </>
        );
      })()}

      {/* Personel'e ozel: "Özlük" kendi sekmesi ama TEK SATIR form (TekOzluk.tsx) -
          personel_ozluk 1:1, generic coklu-satir grid'e uymuyor (ik_karti.html). */}
      {aktif?.tur === 'detay' && personelGibiKart && aktif.detay.ad === 'ozluk' && (
        <TekOzluk
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
        />
      )}

      {/* Stok > ÜTS: stok_uts 1:1 uzanti (119) - grid degil TEK kayit formu.
          Bir stokun bir ÜTS kaydi olur; "satir ekle" yanlis bir vaat olurdu. */}
      {aktif?.tur === 'detay' && kaynak === 'stok' && aktif.detay.ad === 'uts' && (
        <TekKayit
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
          baslik="ÜTS / Medikal Bilgileri"
          not={<>ÜTS REF ve GTIN, ÜTS bildiriminde ürün eşleştirmesinde kullanılır.
               Menşei ülke listesi ülke tablosundan gelir.</>}
        />
      )}

      {aktif?.tur === 'detay' && !(personelGibiKart && aktif.detay.ad === 'ozluk')
        && !(kaynak === 'stok' && aktif.detay.ad === 'uts') && (
        <GenDetayTablo
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          hatalar={alanHatalari}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
        />
      )}

      {aktif?.tur === 'ozel' && kaynak === 'rol' && (
        <RolYetkiMatrisi rolId={id as number} saltOkunur={salt} />
      )}

      {aktif?.tur === 'ozel' && aktif.anahtar === 'ozel:dokuman' && (
        <DokumanGalerisi kartAdi={kaynak} kaynakId={id as number} saltOkunur={salt} />
      )}

      {aktif?.tur === 'ozel' && aktif.anahtar === 'ozel:stokDurum' && (
        <StokDurumSekmesi stokId={id as number} duzenlenebilir={!salt} />
      )}

      {aktif?.tur === 'ozel' && aktif.anahtar === 'ozel:stokHareket' && (
        <StokHareketSekmesi stokId={id as number} />
      )}

      {aktif?.tur === 'yerTutucu' && (
        <div style={{ padding: 40, textAlign: 'center', color: 'var(--soluk)' }}>
          {aktif.baslik} sekmesi yakında.
        </div>
      )}

      {kaynak === 'kisi' && (
        <TarafArama
          acik={cariyeBaglaAcik}
          kaynaklar={['cari']}
          yerTutucu="Cari (müşteri/tedarikçi) ara…"
          onKapat={() => setCariyeBaglaAcik(false)}
          onSec={secilen => {
            setDeger(d => ({ ...d, bagId: String(secilen.id) }));
            setBagliTarafAdi(secilen.unvan);
          }}
        />
      )}

      {/* Katalogdaki AcilistaTarafSecimi: yeni kayitta cari secim ekrani.
          Secim ilgili alana yazilir; kullanici kapatip alandan da secebilir. */}
      {meta?.acilistaTarafSecimi && (
        <TarafArama
          acik={tarafSecimAcik}
          kaynaklar={['cari']}
          yerTutucu="Cari (müşteri/tedarikçi) ara…"
          onKapat={() => setTarafSecimAcik(false)}
          onSec={secilen => {
            setDeger(d => ({ ...d, [meta.acilistaTarafSecimi!]: String(secilen.id) }));
            setTarafSecimAcik(false);
          }}
        />
      )}

      {kapatmaUyarisi && (
        <div className="mesaj-perde" onMouseDown={e => e.stopPropagation()}>
          <div className="mesaj-kutu">
            <h3>Gentegre AI Mesajı</h3>
            <p>Kaydedilmemiş değişiklikler var.</p>
            <div className="mesaj-dugme">
              <button className="d bir" disabled={kaydediyor} onClick={() => { setKapatmaUyarisi(false); void kaydet(); }}>Kaydet</button>
              <button className="d" onClick={() => { setKapatmaUyarisi(false); onKapat?.(); }}>İptal</button>
              <button className="d" onClick={() => setKapatmaUyarisi(false)}>Geri Dön</button>
            </div>
          </div>
        </div>
      )}
    </Modal>
  );
}
