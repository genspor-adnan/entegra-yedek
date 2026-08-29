import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { c } from '../dil/ceviri';
import { api, oturum } from '../api/istemci';
import { useOturum } from '../kimlik/OturumBaglami';
import {
  ApiHatasi, hataAyristir, urunAdi,
  type KartMetaYaniti, type KartYetkisi, hataMetni } from '../api/sozlesme';
import { GenDetayTablo, type DetayDurumu, bosDetay, detayFarki } from './GenDetayTablo';
import { Modal } from './Modal';
import { yerelAnMetni, bugunIso, hamSayi, kidemMetni } from './bicim';
import { PaketSekmesi } from './PaketSekmesi';
import { KartGrupSekmesi } from './kart/KartGrupSekmesi';
import { alanCizici, type Deger } from './kartAlanCizim';
import { kartDogrula } from './kartDogrulama';
import {
  degisenAlanlar as degisenAlanlarHesapla, kartDegistiMi,
} from './kartDegisim';
import {
  alanGruplari, sekmeleriKur, detaySekmeAnahtari, grupSekmeAnahtari,
  KIMLIK_GRUP, TEK_SUTUN_KARTLAR, type SekmeTanimi,
} from './kartSekmeleri';
import { TekKayit } from './TekKayit';
export { Modal };
import { RolYetkiMatrisi } from './RolYetkiMatrisi';
import { ekKaydetleriCalistir, ekKaydetTemizle } from './kartEkKaydet';
import { DokumanGalerisi } from './DokumanGalerisi';
import { StokDurumSekmesi } from './StokDurumSekmesi';
import { StokHareketSekmesi } from './StokHareketSekmesi';
import { HizmetListeFiyatlari } from './HizmetListeFiyatlari';
import { TarafArama } from './TarafArama';
import { telefonAlaniMi } from './alanBicim';
import { telefonBicimle } from './bicim';

interface Props {
  kaynak: string;
  id: number | 'yeni';
  baslik?: string;
  onKapat?(): void;
  /** Bir GRUP sekmesinin icerigini sarmalar - ekran o sekmeye alt sekme cubugu
      ya da ek bolum ekleyebilir (Firma Bilgileri'nde e-Belge sekmesi: Genel /
      Seri / XSLT / tur ayarlari). Verilmezse sekme dogrudan cizilir. */
  sekmeSarmalayici?(sekmeBasligi: string, icerik: React.ReactNode,
                    deger: Record<string, Deger>): React.ReactNode;
  /** Ust seritte kalacak alan adlari. Verilmezse "Kimlik" grubunun TAMAMI seritte
      (varsayilan davranis). Verilirse serit bunlarla sinirlanir, grubun kalani
      "Kimlik" sekmesine duser - kimlik alani cok olan kartlarda serit sismesin. */
  seritAlanlari?: string[];
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
  /** Bu EKRANDA cizilmeyecek alanlar (ör. Aday kartinda "Kod"). Alan katalogda
      kalir; deger tasinir, form onu gostermez. */
  gizliAlanlar?: string[];
  /** Bu EKRANDA acilmayacak sekmeler (ör. Aday kartinda "Fatura Bilgileri").
      Ayni kart farkli ekranlarda farkli genislikte kullanilabilsin diye. */
  gizliSekmeler?: string[];
  /** Bu EKRANDA zorunlu sayilacak alanlar (ör. Aday kartinda "Temsilci").
      Katalogda zorunlu YAPILMAZ: ayni alan Musteri kartinda bos olabilir ve
      eski kayitlarin duzenlenmesini kilitlerdi. */
  zorunluAlanlar?: string[];
}

/** Modal sarmalayici — mockup'taki .kaperde / .kawin duzeni. */



// Telefon alanlari ADINDAN taninir (telefonAlaniMi) - sabit liste yeni bir
//   alanda (faks, gsm, 2. telefon...) unutuluyordu.


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
/**
 * Sekme ikonlari (kullanici: "sekmelere ikon ekle"). Anahtar SEKME BASLIGI -
 * sekmeler katalogdan/alan gruplarindan uretildigi icin ayri bir ikon alani
 * yok; listede olmayan baslik notr simge alir.
 */
const SEKME_IKON: Record<string, string> = {
  'Genel': '📋', 'Kimlik': '🪪', 'İletişim': '📞', 'Adresler': '📍',
  'Notlar': '📝', 'Mali': '💰', 'Fatura Bilgileri': '🧾', 'Banka': '🏦',
  'Depolar': '🏬', 'Logo & Kaşe': '🖼️', 'e-Belge': '📨', 'ÜTS': '🩺',
  'İzinler': '🌴', 'Eğitimler': '🎓', 'Resim / Doküman': '📎',
  'Yorum / Medya': '💬', 'Yetki Matrisi': '🛡️', 'Kullanıcılar': '👥',
  'Stok Durumu': '📦', 'Hareketler': '🔄', 'Fiyatlar': '🏷️',
  'Ek Alanlar': '➕', 'Reçete': '🧪', 'Paket İçeriği': '🧺',
  'Satırlar': '📄', 'Sevkiyat': '🚚', 'Özlük': '🗂️', 'Ayarlar': '⚙️',
};
const sekmeIkonu = (baslik: string) => SEKME_IKON[baslik] ?? '▫️';

export function GenForm({ kaynak, id, baslik, onKapat, seritAlanlari, sekmeSarmalayici, onKaydedildi, yerTutucuSekmeler,
                          resimYerTutucu, cariyeBaglaGizli, yeniKayitVarsayilanlari,
                          gizliAlanlar, gizliSekmeler, zorunluAlanlar }: Props) {
  const { kullanici } = useOturum();
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
      const ham = await api.kartAlanlari(kaynak);
      // Ekrana ozel zorunluluk: katalog degismez, bu ekranda alan yildizli
      //   gelir ve bos birakilirsa kayit engellenir.
      const m: KartMetaYaniti = zorunluAlanlar?.length
        ? { ...ham, alanlar: ham.alanlar.map(a =>
            zorunluAlanlar.includes(a.ad) ? { ...a, zorunlu: true } : a) }
        : ham;
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
            // TEMSILCI varsayilani: karti acan kullanici. Cogu kayitta dogru
            //   cevap budur; farkliysa listeden degistirilir.
            : a.ad === 'temsilci' && kullanici?.id ? String(kullanici.id)
            : a.ad === 'subeId' && oturum.subeId ? String(oturum.subeId)
            : a.tip === 'mantik' ? false : '';
        });
        // Ekrana ozel mantik varsayilan (ör. Tedarikçi Listesi -> tedarikci:true) -
        // yukaridaki genel "false" varsayilaninin UZERINE yazar.
        // ONCE katalog varsayilanlari (sunucudan), SONRA ekrana ozel olanlar -
        //   ekran (or. Cek Listesi'nden "Yeni" -> tur=1) katalogu ezebilsin.
        Object.entries(m.varsayilanlar ?? {}).forEach(([ad, deger]) => {
          // "@simdi" DINAMIK varsayilan (151): kart o anki tarih+saatle acilir.
          //   Sunucu ayni isareti kayitta cozer - istemci saati bozuksa bile
          //   kaydedilen deger kurulus saatinden gelir.
          // TARIH alaninda gune kirpilir: input[type=date] dakikali degeri
          //   kabul etmez, alan BOS gorunurdu.
          const tamAn = yerelAnMetni(new Date());
          const an = m.alanlar.find(a => a.ad === ad)?.tip === 'tarih'
            ? tamAn.slice(0, 10) : tamAn;
          baslangic[ad] = deger === '@simdi' ? an : deger as Deger;
        });
        if (yeniKayitVarsayilanlari) {
          Object.entries(yeniKayitVarsayilanlari).forEach(([ad, deger]) => { baslangic[ad] = deger });
        }
        setDeger(baslangic);
        setIlkDeger(baslangic);
        sonKurAnahtari.current = null;   // yeni kartta kur cekilsin
        // Katalog istiyorsa (cek/senet) kart acilir acilmaz CARI secimi gelsin -
        //   yeni kayitta ilk is odur; kullanici kapatip alandan da secebilir.
        // Cari ZATEN geldiyse (belge kartindan acilan cek/senet: siparisin
        //   carisi onyuklu) secim ekrani ACILMAZ - kullaniciya bildigi seyi
        //   ikinci kez sormak akisi kesiyordu.
        if (m.acilistaTarafSecimi
            && !(baslangic[m.acilistaTarafSecimi] as Deger | undefined))
          setTarafSecimAcik(true);
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
      setHata(hataMetni(h));
    } finally {
      setYukleniyor(false);
    }
  }, [kaynak, id, yeniMi, yeniKayitVarsayilanlari, zorunluAlanlar]);

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
    const tarih = dovizTarihi || bugunIso();
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
    const tutar = hamSayi(deger[doviz.tutarAlani] ?? '0');
    const kur = hamSayi(deger[doviz.kurAlani] ?? '1') || 1;
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

  const gruplar = useMemo(
    () => alanGruplari(meta, { doviz, yerelParada, gizliAlanlar }),
    [meta, doviz, yerelParada, gizliAlanlar]);


  /**
   * "Kimlik" grubu sekme DEGIL — mockup'taki idstrip gibi ust seritte, her sekmede
   * sabit gorunur (kod/unvan/durum gibi karti tanimlayan alanlar).
   */
  const kimlikAlanlari = useMemo(
    () => {
      const grup = gruplar.find(([ad]) => ad === KIMLIK_GRUP)?.[1] ?? [];
      // Serit listesi verildiyse SIRA da ondan gelir (unvan, kisa ad, durum).
      return seritAlanlari
        ? seritAlanlari.map(ad => grup.find(a => a.ad === ad)).filter(Boolean) as typeof grup
        : grup;
    },
    [gruplar, seritAlanlari],
  );

  /** Mockup'taki gibi sekmeli kart: Kimlik disindaki her alan grubu + her detay tablosu ayri sekme. */
  const sekmeler = useMemo<SekmeTanimi[]>(
    () => sekmeleriKur({ gruplar, meta, kaynak, deger, yeniMi, personelGibiKart,
                         yerTutucuSekmeler, gizliSekmeler, seritAlanlari }),
    [gruplar, meta, kaynak, deger, yeniMi, personelGibiKart, yerTutucuSekmeler,
     gizliSekmeler, seritAlanlari]);

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

  // Govde ve "degisti mi" karari saf fonksiyonlarda (kartDegisim.ts).
  const degisenAlanlar = useCallback(
    () => degisenAlanlarHesapla({
      alanlar: meta?.alanlar, deger, ilkDeger, yeniMi,
      varsayilanlar: yeniKayitVarsayilanlari,
    }),
    [meta, deger, ilkDeger, yeniMi, yeniKayitVarsayilanlari]);

  const kaydedilmemisDegisiklikVar = useMemo(() => {
    // GENEL KURAL (kullanici): hicbir sey degistirmeden kapatan kullaniciya
    //   "kaydedilsin mi?" sorulmaz - karsilastirma alan tipine gore normalize
    //   edilir (kartDegisim.alanEsit), yoksa "1.000000" ile '1' fark sayilirdi.
    if (kartDegistiMi(meta?.alanlar, deger, ilkDeger)) return true;

    return Object.values(detaylar).some(durum => {
      const fark = detayFarki(durum);
      return (fark.eklenen?.length ?? 0) + (fark.degisen?.length ?? 0)
           + (fark.silinen?.length ?? 0) > 0;
    });
  }, [meta, deger, ilkDeger, detaylar]);

  const kapatIstendi = useCallback(() => {
    if (kaydedilmemisDegisiklikVar) {
      setKapatmaUyarisi(true);
      return;
    }
    onKapat?.();
  }, [kaydedilmemisDegisiklikVar, onKapat]);

  // Kart acildiginda/kapatildiginda bekleyen ek kayit isleri temizlenir -
  //   baska kartin degisikligi buraya sizmasin.
  useEffect(() => { ekKaydetTemizle(); return () => ekKaydetTemizle() }, [kaynak, id]);

  async function kaydet() {
    // Kaydetmeden onceki alan kontrolleri TEK YERDE (kartDogrulama): e-posta,
    //   ekrana ozel zorunluluk ve telefon. Ilk hatada ilgili sekmeye atlanir.
    const alanHatasi = kartDogrula(meta, deger, zorunluAlanlar);
    if (alanHatasi) {
      setAlanHatalari(h => ({ ...h, [alanHatasi.alan]: alanHatasi.mesaj }));
      const hedefSekme = sekmeBul(alanHatasi.alan);
      if (hedefSekme) setAktifSekme(hedefSekme);
      return;
    }

    setKaydediyor(true);
    setHata(null);
    setAlanHatalari({});
    setCakisma(null);
    setBilgi(null);
    try {
      // Telefon TEK BICIMDE saklanir: kullanici gruplu da yazsa gruplamadan da
      //   yazsa DB'ye "+90 532 418 77 20" gider. Aksi halde ayni numara iki
      //   farkli metinle durup arama/mukerrer kontrolu kaciriyordu.
      const kartGovdesi = degisenAlanlar();
      Object.keys(kartGovdesi).forEach(ad => {
        if (telefonAlaniMi(ad) && typeof kartGovdesi[ad] === 'string' && kartGovdesi[ad])
          kartGovdesi[ad] = telefonBicimle(kartGovdesi[ad]);
      });

      const govde = {
        surum,
        kart: kartGovdesi,
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

      // Kartin AYRI uca yazan bolumleri (personel > yetkili subeler) tek
      //   Kaydet'e baglidir: kart yazildiktan sonra kuyruk calisir.
      await ekKaydetleriCalistir();

      onKaydedildi?.(Number(yanit.kart.id));
      onKapat?.();
      return;
    } catch (h) {
      const c = hataAyristir(h);
      if (c.cakisma) {
        setCakisma(c.cakisma);
      } else {
        setAlanHatalari(c.alanlar);
        setHata(c.mesaj);
        // Hatali alan baska sekmedeyse oraya atla - kullanici bos ekranda
        //   "nerede hata var" diye aramasin.
        const hedefSekme = c.ilkAlan ? sekmeBul(c.ilkAlan) : null;
        if (hedefSekme) setAktifSekme(hedefSekme);
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

  /**
   * FIYAT LISTESI SATIR MODALI EKRAN KURALI (kullanici):
   *  - Carpan degisince fiyat = taban fiyat x carpan (yuvarlama satirdan,
   *    bossa basligin kuralindan) ve Yazim MANUEL olur - uretim artik ezmez.
   *  - Yazim HESAP'a cevrilince fiyat basligin kuralindan yeniden hesaplanir,
   *    carpan basligin carpanina doner.
   * Ayni kural DB tetiginde son otorite olarak da durur; buradaki kopya
   * kullanicinin sonucu KAYDETMEDEN gormesi ve fiyat/yazim'in istekle
   * birlikte gidip ISLEM LOGUNA yazilmasi icindir.
   */
  function fiyatSatirKurali(alan: string, v: unknown, taslak: Record<string, unknown>) {
    const yuvarla = (tutar: number, yonHam: unknown, adimHam: unknown) => {
      const yon = Number(yonHam ?? 0);
      const adim = hamSayi(adimHam) || 1;
      if (!yon || adim <= 0) return tutar;
      if (yon === 1) return Math.ceil(tutar / adim) * adim;
      if (yon === 2) return Math.floor(tutar / adim) * adim;
      if (yon === 3) return Math.round(tutar / adim) * adim;
      return tutar;
    };
    // Fiyat 4, carpan 6 hane (kolon numeric(18,6) - 7,0092 gibi degerler).
    const metin = (s: number, hane = 4) => {
      const k = 10 ** hane;
      return String(Math.round(s * k) / k);
    };
    const taban = hamSayi(taslak.tabanFiyat);

    if (alan === 'carpan') {
      const carpan = hamSayi(v);
      if (carpan <= 0 || taban <= 0) return { yazim: '1' };
      const bos = (d: unknown) => d === '' || d === null || d === undefined;
      const yon  = bos(taslak.yuvarlama)      ? deger.yuvarlama      : taslak.yuvarlama;
      const adim = bos(taslak.yuvarlamaBirim) ? deger.yuvarlamaBirim : taslak.yuvarlamaBirim;
      return { fiyat: metin(yuvarla(taban * carpan, yon, adim)), yazim: '1' };
    }
    // FIYAT elle degisti: satir Manuel olur; zincirli satirda carpan fiyattan
    //   GERIYE hesaplanir (taban degismez). Koksuz/manuel listede carpan
    //   anlamsiz - dokunulmaz.
    if (alan === 'fiyat') {
      const f = hamSayi(v);
      if (taslak.tabanListeId && taban > 0 && f > 0)
        return { yazim: '1', carpan: metin(f / taban, 6) };
      return { yazim: '1' };
    }
    if (alan === 'yazim' && String(v) === '2' && taban > 0) {
      const carpan = hamSayi(deger.carpan) || 1;
      return {
        fiyat: metin(yuvarla(taban * carpan, deger.yuvarlama, deger.yuvarlamaBirim)),
        carpan: metin(carpan, 6),
      };
    }
    return null;
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

  // Alan cizimi ayri dosyada (kartAlanCizim): govde uzunlugu okunabilirligi
  //   bozuyordu. Cagri bicimi degismedi - renderAlan/renderAlanListesi.
  const { altGruplaVar, renderAlanListesi } = alanCizici({
    kaynak, salt, meta, deger, setDeger, alanDegistir, alanHatalari, setAlanHatalari,
    doviz, yerelTutar, kurNotu, bagliTarafAdi, setBagliTarafAdi,
  });

  return (
    <Modal
      baslik={`${baslik ?? kaynak} ${yeniMi ? '— Yeni' : `#${id}`}`}
      dar={TEK_SUTUN_KARTLAR.has(kaynak)}
      ustBilgi={
        <>
          {/* Personel durumu BASLIKTA rozet (kullanici): aktif yesil, isten
              cikis tarihi girilmisse pasif kirmizi - cikis tarihi olan biri
              "aktif" gorunmesin. Serit alani olarak ayrica cizilmez. */}
          {personelGibiKart && !yeniMi && (() => {
            const ozluk = detaylar.ozluk?.guncel[0];
            const cikis = String((ozluk?.istenCikisTarihi as string | undefined) ?? '');
            const pasif = cikis.length > 0 || Number(deger.durum) === 0;
            // Kidem rozetin SAGINDA duz yazi (kullanici; "Özet" kutusu kalkti).
            const kidem = kidemMetni(
              String((ozluk?.iseGirisTarihi as string | undefined) ?? ''), cikis || null);
            return (
              <span style={{ margin: '0 auto', display: 'flex', gap: 8,
                             alignItems: 'center' }}>
                <span className={`rozet ${pasif ? 'hata' : 'ok'}`}
                      title={cikis ? `İşten çıkış: ${cikis}` : undefined}>
                  {pasif ? 'Pasif' : 'Aktif'}
                </span>
                {kidem && (
                  <span style={{ fontWeight: 400, fontSize: 11.5, opacity: .9 }}>
                    Kıdem {kidem}
                  </span>
                )}
              </span>
            );
          })()}
          {surum && <span className="rozet gri">surum {surum}</span>}
          {salt && <span className="rozet uyari">salt okunur</span>}
        </>
      }
      ustSerit={kimlikAlanlari.length > 0 && (
        <div className="kaid">
          {/* Kisi'ye ozel: Kisi Kodu dar, Unvan genis (kullanici: "kod edit yariya dussun,
              onu unvana ekle") - idstrip'in 4 sabit alani (Kod/Unvan/Departman/Gorev). */}
          {/* Personelde ROL kimlik seridinde, DEPARTMANIN SAGINDA (kullanici);
              serit 5 sutunlu akar. Diger kartlarda serit eskisi gibi. */}
          {personelGibiKart && !yeniMi ? (
            <div className="alan-izgara"
                 style={{ gridTemplateColumns: 'repeat(5, minmax(0, 1fr))' }}>
              {renderAlanListesi(kimlikAlanlari.filter(a =>
                ['kod', 'ad', 'soyad', 'departman'].includes(a.ad)))}
              {/* Serit'in 5. alani GÖREV (kullanici: rol ile yer degistirdi);
                  Rol combosu Kimlik Bilgileri kutusunda. */}
              {renderAlanListesi(
                (meta?.alanlar ?? []).filter(a => a.ad === 'gorevId'))}
              {/* "durum" seritte YOK - baslikta rozet olarak gosteriliyor. */}
              {renderAlanListesi(kimlikAlanlari.filter(a =>
                !['kod', 'ad', 'soyad', 'departman', 'durum'].includes(a.ad)))}
            </div>
          ) : (
            <div className={`alan-izgara${kaynak === 'kisi' ? ' kaid-kisi' : ''}`}>
              {renderAlanListesi(kimlikAlanlari)}
            </div>
          )}
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
              {sekmeIkonu(s.baslik)} {c(s.baslik)}
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
          {/* Cek/senede ozel: YON (alinan / verilen) arac cubugunda, Kaydet'in
              saginda (kullanici). Tek secimlik ve kagidin tum anlamini
              belirleyen alan - kimlik seridinde yer kaplamasin diye buraya
              alindi; karttaki alan Gizli, deger buradan yazilir. */}
          {kaynak === 'cek-senet' && meta.alanlar.some(a => a.ad === 'yon') && (
            <label className="satir-ici" style={{ fontSize: 13, gap: 8 }}
                   title="Alınan: müşteriden geldi · Verilen: tedarikçiye verildi">
              Yön
              {/* Arac cubugundaki tek secim - kutu ve yazi biraz daha buyuk
                  (kullanici): kagidin yonunu belirleyen alan goze carpsin. */}
              <select value={String(deger.yon ?? 1)} disabled={salt}
                      style={{ width: 150, height: 28, fontSize: 13 }}
                      onChange={e => setDeger(d => ({ ...d, yon: Number(e.target.value) }))}>
                <option value={1}>Alınan</option>
                <option value={2}>Verilen</option>
              </select>
            </label>
          )}
          <button className="d kapat-dugmesi" onClick={kapatIstendi}>Kapat</button>
          {/* Cari'ye ozel: Musteri/Tedarikci rolleri hizlı erisim icin arac cubuguna,
              Kaydet/Sil ile ayni satira, saga yanasik olarak da tasindi (Roller sekmesindeki
              alanlarla AYNI deger - ikisi de senkron, tekrar degil). */}
          {/* Musteri/Tedarikci kutulari: ADAY ekraninda YOK (kullanici karari) -
              aday henuz ne musteri ne tedarikci; rolu donusumde belirlenir. */}
          {kaynak === 'cari' && !gizliAlanlar?.includes('musteri')
            && meta.alanlar.some(a => a.ad === 'musteri') && (
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

      {aktif?.tur === 'grup' && meta && (() => {
        const govde = (
        <KartGrupSekmesi
          aktif={aktif} kaynak={kaynak} id={id} yeniMi={yeniMi} meta={meta}
          salt={salt} personelGibiKart={personelGibiKart}
          deger={deger} setDeger={setDeger}
          detaylar={detaylar} setDetaylar={setDetaylar}
          alanHatalari={alanHatalari} gizliSekmeler={gizliSekmeler}
          resimYerTutucu={resimYerTutucu} gruplar={gruplar}
          altGruplaVar={altGruplaVar} renderAlanListesi={renderAlanListesi}
        />
        );
        return sekmeSarmalayici ? sekmeSarmalayici(aktif.baslik, govde, deger) : govde;
      })()}

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

      {/* Şube > ÜTS: uts_hesap 1:1 uzanti (223) - grid degil TEK kayit formu.
          Bir subenin bir ÜTS hesabi olur; token buraya kullanici yapistirir. */}
      {aktif?.tur === 'detay' && kaynak === 'sube' && aktif.detay.ad === 'uts' && (
        <TekKayit
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
          // SOLDA canli hesap, SAGDA test cercevesi (kullanici).
          gruplar={[
            { baslik: 'ÜTS Hesabı', alanlar: ['aktif', 'kurumNo', 'token'] },
            { baslik: 'ÜTS Hesabı Test',
              alanlar: ['testOrtami', 'testKurumNo', 'testToken'] },
          ]}
          // Canli/test SECIMDIR (kullanici): biri isaretlenince digeri kalkar.
          dislar={{ aktif: ['testOrtami'], testOrtami: ['aktif'] }}
          // Baz sube IKI cerceveyi de yonetir - kutularin USTUNDE durur.
          ustAlanlar={['bazSubeId']}
        />
      )}

      {/* Stok > Paket: icerik satiri stok arama penceresinden gelir (grid salt
          gorunum) - baslik/cerceve yok, sekmenin adi zaten "Paket". */}
      {aktif?.tur === 'detay' && kaynak === 'stok' && aktif.detay.ad === 'paket' && (
        <PaketSekmesi
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
        />
      )}

      {aktif?.tur === 'detay' && !(personelGibiKart && aktif.detay.ad === 'ozluk')
        && !(kaynak === 'stok' && (aktif.detay.ad === 'uts' || aktif.detay.ad === 'paket'))
        && !(kaynak === 'sube' && aktif.detay.ad === 'uts')
        // Hizmet > Fiyatlar: kartin kendi fiyat gridi KALKTI (kullanici) -
        //   sekme yalniz fiyat listelerindeki fiyatlari gosterir (asagida).
        && !(kaynak === 'hizmet' && aktif.detay.ad === 'fiyatlar') && (
        <GenDetayTablo
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          hatalar={alanHatalari}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
          // Fiyat listesi satirlari SALT GORUNUM + modal duzenleme: satir ici
          //   kipte her satir stok (5.000+) ve hizmet (3.700+) lookup'unu ayri
          //   <select> olarak cizer - 1.438 satirlik listede ~12 MILYON DOM
          //   dugumu sekmeyi donduruyordu ("Satirlar acilmiyor").
          modalDuzenle={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'}
          ikonlu={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'}
          taslakKural={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? fiyatSatirKurali : undefined}
          // Tumu / Stok / Hizmet cipleri (kullanici) - karma listede tek tur gorunur.
          cipler={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? [{ ad: 'Tümü', suz: () => true },
               { ad: '📦 Stok', suz: s => s.stokId != null && s.stokId !== '' },
               { ad: '🛠️ Hizmet', suz: s => s.hizmetId != null && s.hizmetId !== '' }]
            : undefined}
        />
      )}

      {/* Hizmet > Fiyatlar: kalemin gectigi fiyat listesi satirlari
          (kullanici: "bu hizmete ait tum fiyatlar gelsin"; kartin kendi
          hizmet_fiyat gridi kaldirildi). */}
      {aktif?.tur === 'detay' && kaynak === 'hizmet' && aktif.detay.ad === 'fiyatlar' && (
        yeniMi
          ? <div className="not" style={{ marginTop: 12 }}>
              Fiyatlar kart kaydedildikten sonra fiyat listelerinden gelir.
            </div>
          : <HizmetListeFiyatlari hizmetId={id as number} />
      )}

      {aktif?.tur === 'ozel' && kaynak === 'rol' && aktif.anahtar === 'ozel:yetkiler' && (
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
            <h3>{`${urunAdi(kullanici?.urunModu)} Mesajı`}</h3>
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
