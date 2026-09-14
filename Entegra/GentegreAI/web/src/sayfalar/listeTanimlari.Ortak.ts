import type { Kosul } from '../api/sozlesme';

/**
 * LİSTE TANIMININ ORTAK PARÇALARI — tip ve paylaşılan sabitler.
 *
 * Kendi dosyasında, çünkü `listeTanimlari.ts` parçalarını import eder ve
 * parçalar da bu üçünü ister: aynı dosyada dursalardı DÖNGÜSEL import
 * olurdu. Döngü derlemeyi geçer (tsc ve vite build sorunsuz kurar) ama
 * tarayıcıda çalışma anında patlar - modül henüz değerlendirilmemişken
 * sabite erişilir ve uygulama boş ekranla açılır.
 */
export interface ListeTanimi {
  /**
   * Ciplerin sagina KATEGORI AGACI combosu koyar (kullanici): deger kategori
   * TURUdur (1 stok / 2 hizmet, 346). Secilen dal ALT AGACIYLA birlikte suzer.
   */
  kategoriSuzgeci?: number;
  /**
   * Kategori suzgecinin SUZDUGU alan. Varsayilan 'kategori' (hizmet listesi);
   * stok listesinde gorunen kolon YOL metni oldugu icin id kolonu verilir.
   */
  kategoriSuzgecAlani?: string;
  /**
   * Ciplerin sagina BOLUM AGACI combosu koyar (kullanici, personel listesi):
   * secilen dal ALT BIRIMLERIYLE birlikte suzer. Suzulen alan `departmanId`.
   */
  bolumSuzgeci?: boolean;
  /**
   * Ciplerin sagindaki KOD COMBOSU (492): hangi kolona gore suzecegi ve bos
   * secenegin yazisi. Secenekler sunucudan (kolon metasindaki `kodlar`).
   */
  kodSuzgeci?: { alan: string; etiket: string };
  /** Acilista uygulanan gruplama kolonu (492: tetkik katalogu -> bolum). */
  varsayilanGrup?: string;
  /**
   * Ciplerin sagina ROL combosu koyar: kullanici hesabinin yetki rolu
   * (taraf_kullanici.rol_id). Rol listesi `rol` yetkisi ister - yetkisi
   * olmayan kullanicida combo hic cizilmez, liste calismaya devam eder.
   */
  rolSuzgeci?: boolean;
  /**
   * Tarih araliginin ACILIS degeri. 'buAy' = bulunulan ayin 1'i - son gunu
   * (kullanici, hakedis satirlari); 'yilbasindanBugune' = 1 Ocak - bugun.
   * Verilmezse aralik BOS acilir (sinir yok).
   */
  tarihVarsayilan?: 'yilbasindanBugune' | 'buAy';
  /**
   * Tarih araligi kutulari yerine HAZIR ARALIK COMBOSU (Bugun / Dun / Son 3
   * Gun ...) - basvuru seridindekinin aynisi. Gunluk calisilan ekranlarda
   * iki tarih kutusu doldurmak yerine tek secim (kullanici).
   */
  tarihCombo?: boolean;
  /**
   * Ciplerin sagina PRIM ROLU + KISI combolari koyar (kullanici, hakedis
   * satirlari). Kisi listesi secili role gore daralir.
   */
  primSuzgeci?: boolean;
  /**
   * Ciplerin sagina BASVURU suzgecleri koyar (kullanici): hazir tarih
   * araligi, Odeyen kurum, Bolum agaci ve Doktor. Hepsi sunucuda suzer.
   */
  basvuruSuzgeci?: boolean;
  /**
   * EKRANA OZEL kolon basliklari: ayni kaynagi paylasan listelerde
   * katalogdaki basligi degistirmeden bu ekranda baska ad gosterir
   * (kullanici: basvuruda "Belge No" degil "Protokol No").
   */
  kolonBasliklari?: Record<string, string>;
  kaynak: string;
  baslik: string;
  yol: string;
  /** Yalniz bu urun modunda gorunur (215): 2 = GenoTIP AI (HBYS). Bos = ortak. */
  urunModu?: number;
  /**
   * Bagli oldugu MODUL kodu (359, public.kurum_modul). Modul kurum profilinde
   * kapaliysa liste menude cizilmez ve rotasi acilmaz. Verilmezse menu grubunun
   * varsayilan modulu (MENU_GRUP_MODUL) kullanilir; ikisi de yoksa liste her
   * kurulumda gorunur (Yonetim ekranlari gibi).
   */
  modul?: string;
  /** Kart ekrani olan kaynaklarda cift tik karta gider. */
  kartYolu?: string;
  /**
   * Kart baslıgı. Verilmezse liste basligindan turetilir (sondaki -ler/-lar
   * atilir). "Radyoloji Çalışma Listesi" gibi baslikta bu turetme ise yaramaz:
   * kart tek bir ISTEM'i gosterir, listenin adini tasimamali.
   */
  kartBaslik?: string;
  aksiyonEkrani?: string;
  /** e-Belge menusu KUTUSUNUN basligi ("E-Fatura" / "E-İrsaliye"). Verilmezse
      kutu cizilmez. Ekran adi ayirt etmiyor: 'belge-liste' satis fisi /
      tahakkuk / alis faturasi listelerinde de kullaniliyor. */
  ebelgeMenusu?: string;
  toplam?: string[];
  /** `rota` verilen cip FILTRE degil GECIS'tir: tiklaninca o listeye gidilir
      (Alis Faturalari > "Gelen Kutusu"). Ayni serit, farkli kaynak. */
  /** `kosul: 'ebelge'` verilen cip YALNIZ e-Fatura mukellefinde cizilir
      (sunucu e-Belge aksiyonu donduruyorsa). */
  cipler?: { ad: string; filtre?: Kosul; rota?: string; kosul?: 'ebelge' }[];
  /** Rotasi var ama MENUDE gorunmez (baska bir listenin sekmesinden girilir). */
  menuGizli?: boolean;
  /** Mockup'ta olup backend'i henuz olmayan kart sekmeleri (or. stok: "ÜTS Bilgileri"). */
  yerTutucuSekmeler?: string[];
  /** Mockup'taki "Genel" sekmesindeki bos "Resim" kutusu (IMAJ→DOSYA hic baglanmadi). */
  resimYerTutucu?: boolean;
  /** Verilirse (ör. islem-log > "bilgi") satir bu alaniyla "İçerik" penceresinde gosterilir. */
  icerikAlani?: string;
  icerikBaslik?: string;
  /** Kosulsuz sunucu filtresi (ör. Tedarikci Listesi: tedarikci=1) - cip/arama filtreleriyle
      AND'lenir. Ayni kaynagi (ör. 'cari') farkli görünümlerde tekrar kullanmak icin. */
  sabitFiltre?: Kosul;
  /** Verilirse rota (URL/route path) `kaynak` yerine bunu kullanir - ayni kaynagi
      ("cari") birden fazla ekranda (Musteri/Tedarikci) farkli URL'lerle kullanmak icin. */
  rota?: string;
  /** Yeni kayitta mantik alanlara ekrana ozel varsayilan (ör. Tedarikci Listesi ->
      tedarikci:true, musteri:false) - GenForm'a gecirilir. */
  yeniKayitVarsayilanlari?: Record<string, boolean | number | string>;
  /** Ekstre ekranlari: URL'deki ?<alan>=<id> sorgu parametresi sunucu filtresine
      cevrilir (ör. /hesap-ekstre?hesapId=12). Parametre yoksa liste TUM kayitlari
      gosterir - bos ekran yerine "hepsi" daha kullanisli. */
  urlFiltreAlani?: string;
  /** Kart generic GenForm degil, kendi sayfasi (ör. kasa-islem): Liste modal ACMAZ,
      rotayi App.tsx kendisi tanimlar. Cift tik yine kartYolu'na gider. */
  ozelKart?: boolean;
  /** Bu ekranda kart uzerinde CIZILMEYECEK alanlar (ör. Aday kartinda "Kod"). */
  gizliKartAlanlari?: string[];
  /** Bu ekranda acilmayacak kart sekmeleri (ör. Aday kartinda "Fatura Bilgileri"). */
  gizliKartSekmeleri?: string[];
  /** Bu ekranda ONE alinacak kolon sirasi (soldan saga). */
  kolonSirasi?: string[];
  /** Bu ekranda zorunlu sayilacak kart alanlari (ör. Aday: Temsilci). */
  zorunluKartAlanlari?: string[];
  /** Menude grup ICINDEKI sira (kucuk once). Verilmeyen ogeler sonda, tanim
      sirasinda kalir - menu sirasi tanim dosyasindaki yere bagli olmasin. */
  menuSira?: number;
  /** "Yeni" aksiyonunda belge kartinin acilacagi tur (ör. Siparisler -> 19).
      Verilmezse kart kendi varsayilanini (satis faturasi) kullanir. */
  yeniBelgeTuru?: number;
  /** Menude grubun ICINDE ikinci bir kirilim (ör. Yönetim › Ayarlar › Stok Ayarları). */
  menuAltGrup?: string;
  /** Cip seridine "📄 Ekstre" dugmesi ekler: secili satirin ekstresi AYNI
      ekranda acilir (grid ekstre kaynagina doner), cip'e basinca liste geri gelir. */
  ekstre?: {
    kaynak: string; alan: string; baslik: string; tarihAlani?: string;
    /** Ekstre gridinde ekrana ozel kolon basliklari (bkz. kolonBasliklari):
        hasta ekstresinde "Belge No" PROTOKOL NUMARASIDIR. */
    kolonBasliklari?: Record<string, string>;
  };
  /** Liste ekraninda tarih araligi filtresi (cip seridinde iki tarih kutusu). */
  tarihAlani?: string;
  /** Bu ekranda gizlenecek kolonlar (ör. Satis Faturalari'nda tur / turAdi). */
  gizliKolonlar?: string[];
  /** ☰/🕓/⭐ (Tum/Son/Sik) ikonlarini gizle (ÜTS listeleri). */
  aramaGorunumGizli?: boolean;
  /** Arac cubugu dugmesine acilir alt menu: aksiyon kodu -> secenekler. */
  altSecenekler?: Record<string, { kod: string; ad: string }[]>;
  /** Liste DEGIL, kendi sayfasi olan menu ogesi (ör. Stok Ayarları: sekmeli ekran).
      App.tsx rotayi kendisi tanimlar; buradaki `kaynak` yalnizca anahtar/rota icindir. */
  ozelSayfa?: boolean;
}

/**
 * Menü girdisi olan liste tanımı - `LISTELER` dizisinin eleman tipi.
 * Parça dosyaları da bunu kullanır.
 */
export type ListeGirdisi = ListeTanimi & {
  menuAd: string; ic: string; yetkiKodu: string; menuGrup?: string;
};

export const DURUM_CIPLERI: ListeTanimi['cipler'] = [
  { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
  { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
  { ad: 'Tumu' },
];
