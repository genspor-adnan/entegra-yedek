import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api, oturum } from '../api/istemci';
import { useOturum } from '../kimlik/OturumBaglami';
import {
  ApiHatasi,
  type KartMetaYaniti, type KartYetkisi,
} from '../api/sozlesme';
import { GenDetayTablo, type DetayDurumu, bosDetay, detayFarki } from './GenDetayTablo';
import { Modal } from './Modal';
import { PaketSekmesi } from './PaketSekmesi';
import { KartGrupSekmesi } from './kart/KartGrupSekmesi';
import { alanCizici, type Deger } from './kartAlanCizim';
import { kartDogrula } from './kartDogrulama';
import {
  alanGruplari, sekmeleriKur, detaySekmeAnahtari, grupSekmeAnahtari,
  KIMLIK_GRUP, TEK_SUTUN_KARTLAR, type SekmeTanimi,
} from './kartSekmeleri';
import { TekOzluk } from './TekOzluk';
import { TekKayit } from './TekKayit';
export { Modal };
import { RolYetkiMatrisi } from './RolYetkiMatrisi';
import { DokumanGalerisi } from './DokumanGalerisi';
import { StokDurumSekmesi } from './StokDurumSekmesi';
import { StokHareketSekmesi } from './StokHareketSekmesi';
import { TarafArama } from './TarafArama';
import { telefonAlaniMi } from './alanBicim';
import { telefonBicimle } from './bicim';

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
export function GenForm({ kaynak, id, baslik, onKapat, onKaydedildi, yerTutucuSekmeler,
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

  const gruplar = useMemo(
    () => alanGruplari(meta, { doviz, yerelParada, gizliAlanlar }),
    [meta, doviz, yerelParada, gizliAlanlar]);


  /**
   * "Kimlik" grubu sekme DEGIL — mockup'taki idstrip gibi ust seritte, her sekmede
   * sabit gorunur (kod/unvan/durum gibi karti tanimlayan alanlar).
   */
  const kimlikAlanlari = useMemo(
    () => gruplar.find(([ad]) => ad === KIMLIK_GRUP)?.[1] ?? [],
    [gruplar],
  );

  /** Mockup'taki gibi sekmeli kart: Kimlik disindaki her alan grubu + her detay tablosu ayri sekme. */
  const sekmeler = useMemo<SekmeTanimi[]>(
    () => sekmeleriKur({ gruplar, meta, kaynak, deger, yeniMi, personelGibiKart,
                         yerTutucuSekmeler, gizliSekmeler }),
    [gruplar, meta, kaynak, deger, yeniMi, personelGibiKart, yerTutucuSekmeler, gizliSekmeler]);

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

      {aktif?.tur === 'grup' && meta && (
        <KartGrupSekmesi
          aktif={aktif} kaynak={kaynak} id={id} yeniMi={yeniMi} meta={meta}
          salt={salt} personelGibiKart={personelGibiKart}
          deger={deger} setDeger={setDeger}
          detaylar={detaylar} setDetaylar={setDetaylar}
          alanHatalari={alanHatalari} gizliSekmeler={gizliSekmeler}
          resimYerTutucu={resimYerTutucu} gruplar={gruplar}
          altGruplaVar={altGruplaVar} renderAlanListesi={renderAlanListesi}
        />
      )}

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
        && !(kaynak === 'stok' && (aktif.detay.ad === 'uts' || aktif.detay.ad === 'paket')) && (
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
