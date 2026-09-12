import { useRef } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type BelgeYaniti } from '../../api/sozlesme';
import { mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { para, tutarOku } from '../../bilesenler/bicim';
import { belgeKisaAdi } from '../belgeTuru';
import { KOVA_SGK, KOVA_OSS } from './dagilimKovalari';
import {
  donusumSatirlari, posFisiSecimi, sinirliDonusumSecimi, donusumPayi, tarafPayi,
  kasaAramaSirasi,
  type DonusumOlcusu,
} from '../belgeKartiKurallari';

/**
 * BELGE KARTININ PARA AKISLARI - hizli donusum, POS sonrasi otomatik fis,
 * tutar sorma ve hizli nakit tahsilat.
 *
 * Kart 1.700 satirdi ve bu bes islev onun ortasinda, birbirinden uzak yerlerde
 * duruyordu; hepsi AYNI soruyu cevapliyor: "bu belgede ne kadar para hareket
 * edecek ve karsiliginda hangi belge kesilecek". Bir gunde cikan uc hata da
 * (kaybolan ucret, bos donen tutar kutusu, sessizce atlanan POS fisi) tam bu
 * bandin icindeydi - tek dosyada olunca kural bir kez okunup dogrulanabiliyor.
 *
 * SIRA BAGIMLILIGI: `kes` / `kayitSart` kartin ILERISINDE tanimli, tahsilat
 * kancasi da `posSonrasi`yi ister. Ikisi de REF uzerinden gecer - kanca kartin
 * neresinde cagrilirsa cagrilsin dogru fonksiyonu bulur.
 */
export interface ParaAkisRef {
  /** Belgeyi kaydeder; `otomatik` kartin kendi kaydidir (satir silmez). */
  kes(kapatilsin?: boolean, otomatik?: boolean): Promise<number>;
  /** Kayit sart: kaydedilmemis belge / bekleyen kalem varsa kaydeder. */
  kayitSart(): Promise<boolean>;
  /** Hizli tahsilat (kasa karti acmadan) - tahsilat kancasindan gelir. */
  hizliTahsilat(tur: number, hesapId: number, tutar: number, hesapAdi: string): Promise<void>;
}

export interface ParaAkisGirdisi {
  ref: React.MutableRefObject<ParaAkisRef>;
  basvuruMu: boolean;
  alisMi: boolean;
  kayitliId: number;
  donusumOlcusu: DonusumOlcusu;
  /** POS sonrasi aksiyon (355): 0 yok / 1 otomatik fis / 2 sor. */
  posAksiyon: number;
  setPosAksiyon(v: number): void;
  /** Belgenin acik borcu (ucretlendirme - tahsilat). */
  acikBorc: number;
  /** Satirlari SUNUCUDAN tazeler (kovalarin sayaclari degisince sart). */
  satirlariTazele(id?: number): Promise<void>;
  kullaniciId: number | null;
  yerelPara: string;
  setHata(m: string | null): void;
  /**
   * Kayit DOGRULAMADAN gectiyse cagrilmaz; gecmediyse kart eksik alanlarin
   * oldugu sekmeye doner ve kullaniciya sebebi soylenir.
   */
  kayitBasarisiz(): void;
  setSonuc(y: BelgeYaniti): void;
  donusumleriYukle(id?: number): Promise<void>;
}

export function useParaAkislari(g: ParaAkisGirdisi) {
  // Girdi her renderda tazelenir; akislar cagrildiklari ANDA guncel degeri
  //   okumali - yoksa eski kapanisla (stale closure) calisirlar.
  const gRef = useRef(g);
  gRef.current = g;

  /**
   * HIZLI TAHSILAT TUTARI: belgenin ACIK BORCU (ucretlendirme - tahsilat).
   * Eksiye dusmez; kapanmis belgede 0 gelir ve sunucu tahsilati reddeder.
   */
  const hizliTutar = () => Math.max(0, Math.round(gRef.current.acikBorc * 100) / 100);

  /**
   * TUTAR SORAN MODAL (kullanici): varsayilan deger onerilen tutardir,
   * kullanici azaltabilir. Iptalde null doner - cagiran islemi durdurur.
   */
  const tutarSor = async (baslik: string, varsayilan: number): Promise<number | null> => {
    const metin = await metinSor(baslik, para.format(varsayilan));
    if (metin === null) return null;
    // KUTUDAKI METIN EKRAN BICIMINDE ("50.000,00", bazen "50.000,00 TL"):
    //   binlik ayraci, para isareti ve bosluk hosgorulur. hamSayi yalniz JSON
    //   bicimini (binliksiz) cozup 0 donduruyordu - kullanici onerilen tutari
    //   degistirmeden Enter'a bastiginda "Tutar sifirdan buyuk olmali" hatasi
    //   aliyordu.
    const t = tutarOku(metin);
    if (!(t > 0)) { mesaj('Tutar sıfırdan büyük olmalı.'); return null }
    if (t > varsayilan + 0.005) {
      mesaj(`En fazla ${para.format(varsayilan)} ₺ girilebilir.`);
      return null;
    }
    return t;
  };

  /**
   * Hizli tahsilat TUTARI: acik borc varsa o, YOKSA kullaniciya sorulur
   * (kullanici: "banka / pos seçtim ama satıra eklenmedi" - belge tam tahsil
   * edilmisti, tutar 0 cikiyor ve islem sessizce duruyordu). Iptal edilirse
   * 0 doner ve satir eklenmez.
   */
  const tahsilatTutariSor = async (baslik: string) => {
    const kalan = hizliTutar();
    // BASVURUDA HER ZAMAN SORULUR (kullanici): kismi tahsilat alinabilsin.
    if (kalan > 0 && gRef.current.basvuruMu)
      return await tutarSor(`${baslik} tutarı (₺)`, kalan) ?? 0;
    if (kalan > 0) return kalan;
    const metin = await metinSor(
      `${baslik}: bu belgede açık borç yok. Tahsilat tutarını yazın (₺)`, '');
    // Kullanici "50.000,00", "50000" ya da "50.000,00 ₺" yazabilir.
    const t = metin === null ? 0 : tutarOku(metin);
    if (metin !== null && !(t > 0)) mesaj('Tutar sıfırdan büyük olmalı.');
    return t;
  };

  /**
   * HIZLI DONUSUM (kullanici): modal ACMADAN hedef belgeyi uretir ve Dönüşüm
   * listesine ekler - tahsilat sekmesindeki hizli akisin aynisi.
   *
   * OLCU:
   *   adet  -> her acik satirin KALAN MIKTARI (klasik siparis -> fatura)
   *   tutar -> fis/faturada TAHSIL EDILEN kadar, tahakkukta kalanin TAMAMI
   *            (352 tutar bazli donusum; ortak hesap `belgeDonusumHesap`)
   *
   * Cevrilecek bir sey yoksa (kapanmis belge, tahsilat yok) kullaniciya
   * sebebi soylenir - sessizce durmasin.
   */
  const hizliDonustur = async (hedefTur: number, taraf?: 'hasta' | 'kurum') => {
    const { ref, basvuruMu, donusumOlcusu, setHata, donusumleriYukle } = gRef.current;
    // ONCE KAYDET (kullanici: "fiş butonuna bastım, ücret ve tahsilat
    //   satırlarını henüz kayıtlı olmadığı için göremedi"): acik satirlar
    //   SUNUCUDAN okunuyor - ekrandaki kalemler yazilmadan donusum bos kalir.
    //   `kes(false)` karti KAPATMAZ; hata varsa 0 doner ve mesaji zaten gosterir.
    const id = await ref.current.kes(false);
    // KAYIT DUSERSE SESSIZ KALMA (kullanici: "fişi sildim, hiçbir belge
    //   ekleyemiyorum - Faturaya Dönüştür çalışıyor"): hizli donusum once
    //   belgeyi kaydeder; dogrulama duserse (basvuruda bolum / gonderen /
    //   odeyen kurum bos) buradan sessizce donuluyordu. Modal yol kaydetmedigi
    //   icin calisiyor gorunuyor, hizli dugmeler "hicbir sey yapmiyor"du.
    if (!id) { gRef.current.kayitBasarisiz(); return }
    try {
      const acik = await api.belgeAcikSatirlar(id);
      // BASVURUDA TUTAR SORULUR (kullanici: "dönüşüm ve tahsilat seçildiğinde
      //   modal olarak tutar sorsun, o miktar kadar eklesin"): kabul memuru
      //   kismi fis/fatura kesebilsin. Onerilen deger olcunun tamami;
      //   iptal edilirse islem durur. Diger belgelerde eski davranis surer.
      // PAY: hangi kova aciksa (kurum tahakkuku / hasta fisi) - bkz.
      //   donusumPayi. Sabit hasta payi, "Kurumu Öder" basvurusunda hicbir
      //   satir secmiyordu.
      // TARAF SECILEBILIR (kullanici: "tahakkukları ikiye ayıralım: Kurum
      //   Tahakkuku ve Hasta Tahakkuku"): dugme hangi tarafi belgeleyecegini
      //   soyler. Kova NUMARASI degil TARAF gecer - "hasta" özel iste ek katki
      //   (4), ÖSS/SGK'da provizyon (1) kovasidir; sabit numara özel hastada
      //   bos sonuc veriyordu. Kalani olmayan tarafta asagida sebep soylenir.
      const pay = taraf ? tarafPayi(acik, taraf) : donusumPayi(acik, hedefTur);
      if (taraf && pay === 0) {
        mesaj(taraf === 'hasta'
          ? 'Hastanın belgelenecek payı kalmadı.'
          : 'Kurumun belgelenecek payı kalmadı.');
        return;
      }
      let gonderilecek = donusumSatirlari(acik, hedefTur, donusumOlcusu, pay);
      if (basvuruMu && gonderilecek.length > 0) {
        // MODALDE ACIK BELGE TUTARI ONERILIR (kullanici) ve girilen rakam
        //   KDV DAHIL islenir (sinirliDonusumSecimi matraha cevirir).
        const tamami = sinirliDonusumSecimi(acik, hedefTur, undefined, 'kalan', pay)
          .toplamDahil;
        if (tamami < 0.01) {
          mesaj('Belgeye dönüşecek tutar kalmadı — bu başvurunun ücretleri '
                + 'zaten belgeye çevrilmiş.');
          return;
        }
        const sinir = await tutarSor(`${belgeKisaAdi(hedefTur)} tutarı (₺)`, tamami);
        if (sinir === null) return;
        gonderilecek = sinirliDonusumSecimi(acik, hedefTur, sinir, 'kalan', pay).satirlar;
      }

      if (gonderilecek.length === 0) {
        // ACIK TUTAR YOKSA SEBEBI SOYLE (kullanici): "0 ise Belgeye
        //   dönüşecek tutar kalmadı uyarısı versin".
        mesaj('Belgeye dönüşecek tutar kalmadı — bu başvurunun ücretleri '
              + 'zaten belgeye çevrilmiş.');
        return;
      }

      // PAY sunucuya da gider: kurum payinda hedef belgenin CARISI odeyen
      //   kurumdur (hasta degil).
      const yeni = await api.belgeDonustur(id, hedefTur, gonderilecek,
                                           undefined, false, undefined,
                                           pay, false);
      await donusumleriYukle(id);
      // SATIRLAR DA TAZELENIR (kullanici: "satış tahakkuku ekledim ama açık
      //   belge değişmedi"): kovalarin KAPATILAN sayaci sunucuda doldu; kart
      //   yalniz basligi okursa serit eski rakamda kalir.
      await gRef.current.satirlariTazele(id);
      mesaj(`Belge oluşturuldu: ${String(yeni.belge.belgeNo ?? yeni.belge.id)}`);
    } catch (h) { const m = hataMetni(h); setHata(m); mesaj(m) }
  };

  /**
   * KURUM PAYI TAHSIL EDILMEZ, TAHAKKUK EDILIR (kullanici: "nakit, POS, banka,
   * çek, senet her zaman hastadan alacağımız tahsilatlar içindir… kaydettiğim
   * zaman eğer yoksa kurum tahakkuku ilk satıra gelecek").
   *
   * Hastadan tahsilat alinir alinmaz kurumun payi icin Satış Tahakkuku (17)
   * kesilir - yoksa. "Yoksa" kontrolu ayrica yapilmaz: `donusumPayi` yalnizca
   * KALANI olan kovayi secer, tamami tahakkuk edilmisse kalan 0'dir ve islem
   * sessizce atlanir. Boylece 100 nakit + 100 POS gibi parcali tahsilatta
   * tahakkuk BIR KEZ dogar, kurum payi hep 800 kalir.
   *
   * SESSIZ: akisi bolmemek icin kullaniciya "belge olusturuldu" denmez -
   * tahakkuk listede zaten gorunur. Hata olursa soylenir.
   */
  const kurumTahakkukuOtomatik = async (belgeId: number) => {
    const { basvuruMu, setHata, donusumleriYukle } = gRef.current;
    if (!basvuruMu || !belgeId) return;
    try {
      const acik = await api.belgeAcikSatirlar(belgeId);
      const pay = donusumPayi(acik, 17);
      // Kurum kovasi degilse (hasta kovasi dondu) tahakkuk edilecek kurum payi
      //   yok demektir - ozel hastada da buradan sessizce cikilir.
      if (pay !== KOVA_SGK && pay !== KOVA_OSS) return;
      const satirlar = donusumSatirlari(acik, 17, 'tutar', pay);
      if (satirlar.length === 0) return;
      await api.belgeDonustur(belgeId, 17, satirlar, undefined, false, undefined,
                              pay, false);
      await donusumleriYukle(belgeId);
      // SATIRLARI DA TAZELE: kovalarin KAPATILAN sayaci sunucuda doldu; kart
      //   yalniz basligi okursa serit kurum payini hala ACIK gosterir.
      await gRef.current.satirlariTazele(belgeId);
    } catch (h) { const m = hataMetni(h); setHata(m); mesaj(m) }
  };

  /**
   * POS TAHSILATI SONRASI AKSIYON (355 ayari `basvuru.pos_aksiyon`):
   *   0 Aksiyon yok · 1 Otomatik fis · 2 "Fiş kesilsin mi?" diye sor.
   *
   * Fis TAHSIL EDILEN KADAR kesilir (tutar bazli donusum, 352): her acik
   * satirda hasta payinin kalani ile o satira DAGITILMIS tahsilatin kucugu
   * alinir - donusum modalinin onerdigi tutarin aynisi (ortak hesap dosyasi).
   * Kalan tutar basvuruda acik kalir; tahakkuk istenirse elle cevrilir.
   *
   * Pencere kaydedilmeden kapatildiysa dagitilacak yeni tahsilat olmaz, tutar
   * sifir cikar ve sessizce cikilir.
   */
  const posSonrasi = async (tur: number) => {
    const { basvuruMu, kayitliId, posAksiyon, setPosAksiyon,
            setHata, setSonuc, donusumleriYukle } = gRef.current;
    // KASA PENCERESI HANGI TURDE KAPANIRSA KAPANSIN kurum payi tahakkuk edilir
    //   (kullanici): nakit, POS, banka, cek, senet - hepsi HASTADAN alinir;
    //   kurumun payi ayni anda kuruma kesilen belgeye doner.
    if (basvuruMu && kayitliId) await kurumTahakkukuOtomatik(kayitliId);
    if (tur !== 25 || !basvuruMu || !kayitliId) return;
    // AYAR OKUNAMAMISSA SESSIZCE VAZGECME (kullanici: "POS girdim ama fiş
    //   oluşmadı"): 355 ayari kart acilirken bir kez cekiliyor; o istek
    //   duserse (sunucu yeniden baslamis olabilir) posAksiyon 0 kalir ve
    //   kural hic isletilmez - hicbir belirti de vermez. Burada bir kez daha
    //   sorulur, yine 0 ise kural gercekten kapalidir.
    let aksiyon = posAksiyon;
    if (aksiyon === 0) {
      try {
        const a = await api.ayarlar();
        const pa = a.find(x => x.anahtar === 'basvuru.pos_aksiyon')?.deger;
        aksiyon = pa === undefined || pa === '' ? 0 : (Number(pa) || 0);
        if (aksiyon !== 0) setPosAksiyon(aksiyon);
      } catch { /* ayar yine okunamadi - kural kapali sayilir */ }
    }
    if (aksiyon === 0) return;
    try {
      const acik = await api.belgeAcikSatirlar(kayitliId);
      // TETIKLEYEN POS TUTARI ust sinir (kullanici): fis o cekimden fazlasini
      //   belgelemesin. Kasa islemi pencerede kaydedildigi icin tutari
      //   listeden okuyoruz - en son POS (25) hareketi.
      const posListe = await api.liste('kasa-islem', {
        sayfa: 1, boyut: 1, sirala: [{ alan: 'id', yon: 'desc' }],
        filtre: { op: 'and', kosullar: [
          { alan: 'belgeId', op: 'esit', deger: kayitliId },
          { alan: 'tur', op: 'esit', deger: 25 },
          { alan: 'durum', op: 'esit', deger: 2 },
        ] },
      });
      const posTutar = Number(posListe.satirlar?.[0]?.tutar ?? 0);
      // Tutar okunamazsa eski davranisa DUSMEYIZ: fis kesmeyip kullaniciyi
      //   Tahsilat ekranina birakmak, fazla belge kesmekten iyidir.
      if (!(posTutar > 0)) return;
      const { satirlar: secim, toplamDahil: toplam, pay: posPay } =
        posFisiSecimi(acik, posTutar);
      // SESSIZ CIKMA YOK (kullanici): tahsilat dagitilmamis ya da belgelenecek
      //   tutar kalmamis olabilir - sebebi soylenir, yoksa "fiş oluşmadı" diye
      //   aranıyordu.
      if (secim.length === 0) {
        mesaj('POS tahsilatı için fiş kesilmedi: belgelenecek açık tutar yok '
              + '(tahsilat başvuruya dağıtılmamış olabilir).');
        return;
      }
      if (aksiyon === 2 && !(await onay(
            `POS tahsilatı için ${para.format(toplam)} ₺ tutarında satış fişi kesilsin mi?`)))
        return;

      const yeni = await api.belgeDonustur(kayitliId, 16, secim,
        undefined, false, undefined, posPay, false);

      await donusumleriYukle();
      try { setSonuc(await api.belgeOku(kayitliId)) } catch { /* yoksay */ }
      mesaj(`Satış fişi oluşturuldu: ${String(yeni.belge.belgeNo ?? yeni.belge.id)}`
            + ` · ${para.format(toplam)} ₺`);
    } catch (h) {
      setHata(hataMetni(h));
    }
  };

  /**
   * NAKIT: kart ACILMADAN kasaya satir ekler. Kasa secimi KASA TANIMINDAKI
   * ATAMA sutunundan gelir (200, kullanici - ayri bir ayar yok):
   *     1) oturumu acan kullaniciya ATANMIS kasa (hesap.atama = kullanici id)
   *     2) yoksa ATAMASI "Ana Kasa" olan kasa (hesap.atama = -1)
   *     3) o da yoksa kod sirasindaki ilk aktif yerel para kasasi
   * Boylece veznedar kendi kasasina, oteki kullanicilar ana kasaya yazar.
   */
  const hizliNakit = async () => {
    const { ref, alisMi, kullaniciId, yerelPara, setHata } = gRef.current;
    // Tahsilat kasaya BELGE KIMLIGIYLE baglanir - kayit sart; kart kendisi
    //   kaydeder, kullanici once yesil dugmeye gitmek zorunda kalmasin.
    if (!await ref.current.kayitSart()) return;
    try {
      const tutar = await tahsilatTutariSor('Nakit');
      if (!(tutar > 0)) return;
      // Kasa secim SIRASI kural dosyasinda (atama > ana kasa > herhangi biri).
      let h: Record<string, unknown> | null = null;
      for (const filtre of kasaAramaSirasi(kullaniciId, yerelPara)) {
        const y = await api.liste('hesap', {
          sayfa: 1, boyut: 1, sirala: [{ alan: 'kod', yon: 'asc' }], filtre,
        });
        if (y.satirlar[0]) { h = y.satirlar[0]; break }
      }
      if (!h) { mesaj('Aktif kasa hesabı bulunamadı - Kasa tanımlarından bir kasa açın.'); return }
      await ref.current.hizliTahsilat(alisMi ? 31 : 21, Number(h.id), tutar,
                                      String(h.ad ?? ''));
      // Hastadan tahsilat alindi: kurum payi varsa TAHAKKUK edilir (yoksa).
      await kurumTahakkukuOtomatik(gRef.current.kayitliId);
    } catch (e) { setHata(hataMetni(e)) }
  };

  return { hizliTutar, tutarSor, tahsilatTutariSor, hizliDonustur, posSonrasi, hizliNakit,
           kurumTahakkukuOtomatik };
}
