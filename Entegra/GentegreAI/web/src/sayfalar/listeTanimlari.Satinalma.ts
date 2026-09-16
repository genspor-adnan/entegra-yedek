import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * SATINALMA — db/724, mockup'lar `Ekranlar/Satinalma/*.html`.
 *
 * ALTI EKRAN, ALTI SORU:
 *   Talepler     "kim ne istedi, hangi basamakta bekliyor"
 *   Teklifler    "kaç firma davet edildi, kim kazandı, neden"
 *   Siparişler   "ne zaman gelecek, kaç gün gecikti, ceza işlendi mi"
 *   Fatura Kontrol "sipariş-irsaliye-fatura tuttu mu, ödeme verilir mi"
 *   Tedarikçiler "kimle çalışılır, kimin belgesi doldu"
 *   Bütçe        "kalem ne kadar yandı, taahhüt ne kadar"
 *
 * SİPARİŞ ve FATURA `belge` ÜZERİNDE (tür 9 / 11): ikinci bir sipariş tablosu
 * para matematiğini ikiye bölerdi. Listeler `belge`yi okur, `belge_satinalma`
 * 1:1 uzantısı yalnız süreci (taahhüt, gecikme, ceza) ekler.
 *
 * TEDARİKÇİ SKORU HESAPLANIR, GİRİLMEZ (`v_tedarikci_skor`): her gecikme,
 * uygunsuzluk ve fatura farkı bir olay satırıdır; skor son 12 aydan türer.
 *
 * ÜRÜN MODU YOK: satınalma ERP'de de HBYS'de de aynı iştir. Modül kapısı
 * `satinalma` - satınalma birimi olmayan kurumda grup çizilmez.
 */
export const SATINALMA_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'satinalmaTalep', rota: 'satinalma-talep',
    baslik: 'Satınalma Talepleri',
    yol: 'Satınalma › Talepler',
    kartYolu: '/satinalma-talep', kartBaslik: 'Satınalma Talebi',
    aksiyonEkrani: 'satinalma-talep-liste',
    tarihAlani: 'tarih',
    // İLK ÇİP AÇILIŞ SÜZGECİDİR: listenin günlük iş kümesiyle açılması gerekir.
    //   "Onayda" ile açsaydık yeni açılan (taslak) talep hiç görünmez ve tam da
    //   ona basılacak "Onaya Gönder" düğmesi erişilemez olurdu.
    cipler: [
      { ad: 'Açık',      filtre: { alan: 'durum', op: 'kucukEsit', deger: 1 } },
      { ad: 'Taslak',    filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Onayda',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Onaylandı', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Acil',      filtre: { alan: 'oncelik', op: 'esit', deger: 1 } },
      // KRİTİK STOKTAN DOĞAN TALEP ayrı çip: gerekçesi kaydında, elle
      //   yazılmasını beklemek tekrar olurdu.
      { ad: 'Kritik stok', filtre: { alan: 'kaynak', op: 'esit', deger: 2 } },
      // BİRLEŞTİRİLEBİLİR: aynı kalemi ayrı ayrı sipariş etmek pazarlık
      //   gücünü de kargo parasını da harcar.
      { ad: 'Birleştirilebilir', filtre: { alan: 'birlestirilebilir', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Satınalma', menuAd: 'Talepler', ic: '📝',
    yetkiKodu: 'satinalma.talep', menuSira: 10,
  },
  {
    kaynak: 'satinalmaTeklif', rota: 'satinalma-teklif',
    baslik: 'Teklif / İhale',
    yol: 'Satınalma › Teklifler',
    kartYolu: '/satinalma-teklif', kartBaslik: 'Teklif',
    aksiyonEkrani: 'satinalma-teklif-liste',
    cipler: [
      { ad: 'Sonuçlanmamış', filtre: { alan: 'durum', op: 'kucukEsit', deger: 2 } },
      { ad: 'Hazırlık',    filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Davet gitti', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Açıldı',      filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Karar verildi', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      // EN DÜŞÜK ALINMADI: denetimin ilk sorusu. Gerekçesi kartta durur.
      { ad: 'En düşük alınmadı', filtre: { alan: 'enDusukAlindi', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Satınalma', menuAd: 'Teklifler', ic: '⚖️',
    yetkiKodu: 'satinalma.teklif', menuSira: 20,
  },
  {
    kaynak: 'satinalmaSiparis', rota: 'satinalma-siparis',
    baslik: 'Sipariş Takibi',
    yol: 'Satınalma › Siparişler',
    aksiyonEkrani: 'satinalma-siparis-liste',
    // KART YOK, BELGE MODALI VAR: sipariş `belge` tür 9'dur ve satır kimliği
    //   belge id'sidir - çift tık Liste.tsx'te belge kartını modal açar.
    tarihAlani: 'belgeTarihi',
    cipler: [
      { ad: 'Açık',         filtre: { alan: 'takipDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi teslim', filtre: { alan: 'takipDurum', op: 'esit', deger: 1 } },
      { ad: 'Geciken',      filtre: { alan: 'gecikmeGun', op: 'buyuk', deger: 0 } },
      // CEZA HESAPLANDI AMA İŞLENMEDİ: sözleşmede yazan ceza kendiliğinden
      //   tahsil olmaz; işlenmeyen ceza sözleşmeyi tavsiyeye çevirir.
      { ad: 'Cezası işlenmedi', filtre: { alan: 'cezaIslendi', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Satınalma', menuAd: 'Siparişler', ic: '📦',
    yetkiKodu: 'satinalma.siparis', menuSira: 30,
  },
  {
    kaynak: 'satinalmaKabul', rota: 'satinalma-kabul',
    baslik: 'Mal Kabul (muayene tutanağı)',
    yol: 'Satınalma › Mal Kabul',
    kartYolu: '/satinalma-kabul', kartBaslik: 'Mal Kabul Tutanağı',
    aksiyonEkrani: 'satinalma-kabul-liste',
    tarihAlani: 'tarih',
    // AÇILIŞ ÇİPİ "AÇIK": muayenesi bitmemiş tutanak bekleyen iştir. Sonuca
    //   göre açsaydık (ör. "Ret") ekran çoğu gün boş gelir ve karar düğmeleri
    //   basılacak satırı bulamazdı.
    cipler: [
      { ad: 'Açık',        filtre: { alan: 'sonuc', op: 'esit', deger: 0 } },
      { ad: 'Kısmi kabul', filtre: { alan: 'sonuc', op: 'esit', deger: 2 } },
      { ad: 'Ret',         filtre: { alan: 'sonuc', op: 'esit', deger: 3 } },
      // SOĞUK ZİNCİR UYGUNSUZ: kabul edilmiş olsa bile ayrı görünür -
      //   tedarikçiyle konuşulması gereken şey budur.
      { ad: 'Soğuk zincir uygunsuz',
        filtre: { alan: 'sogukZincirUygun', op: 'esit', deger: 2 } },
      // KAREKOD EKSİK: ilaç kalemi okutulmadan tutanak kapanmamalı - "8/12"
      //   sütunu gösteriyor ama süzgeç ölçülebilir alana bakar (734).
      { ad: 'Karekod eksik',
        filtre: { alan: 'karekodEksik', op: 'buyuk', deger: 0 } },
      // İTS BİLDİRİLMEDİ: kutusu okutulmuş ama bildirimi kuyruğa alınmamış
      //   tutanak unutulmuş bir yükümlülüktür (736). `-1` "hiç bildirim yok".
      { ad: 'İTS bildirilmedi',
        filtre: { alan: 'itsDurum', op: 'kucukEsit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Satınalma', menuAd: 'Mal Kabul', ic: '🚚',
    yetkiKodu: 'satinalma.kabul', menuSira: 35,
  },
  {
    kaynak: 'satinalmaFatura', rota: 'satinalma-fatura',
    baslik: 'Fatura Kontrolü (üçlü eşleştirme)',
    yol: 'Satınalma › Fatura Kontrolü',
    aksiyonEkrani: 'satinalma-fatura-liste',
    cipler: [
      { ad: 'Kontrol edilmedi', filtre: { alan: 'sonuc', op: 'esit', deger: 0 } },
      { ad: 'Fark var',         filtre: { alan: 'sonuc', op: 'buyukEsit', deger: 2 } },
      { ad: 'Ödeme durduruldu', filtre: { alan: 'odemeDurum', op: 'esit', deger: 2 } },
      { ad: 'İtiraz edildi',    filtre: { alan: 'odemeDurum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Satınalma', menuAd: 'Fatura Kontrolü', ic: '🧾',
    yetkiKodu: 'satinalma.fatura', menuSira: 40,
  },
  {
    kaynak: 'satinalmaTedarikci', rota: 'satinalma-tedarikci',
    baslik: 'Tedarikçi Performansı',
    yol: 'Satınalma › Tedarikçiler',
    kartYolu: '/cari', kartBaslik: 'Tedarikçi',
    aksiyonEkrani: 'satinalma-tedarikci-liste',
    // DURUM ROZETİ SQL'DE HESAPLANIR ama metindir, süzülemez: çipler skorun
    //   kendisine bakar ve rozetle AYNI eşikleri (50 / 70) kullanır - ekran
    //   ikinci bir eşik tanımlamasın.
    cipler: [
      { ad: 'Askı eşiği',     filtre: { alan: 'skor', op: 'kucuk', deger: 50 } },
      { ad: 'İzlemde',        filtre: { alan: 'skor', op: 'kucuk', deger: 70 } },
      // SÜRESİ DOLMUŞ BELGE: borcu yoktur yazısı aylıktır, bir kez alınıp
      //   dosyaya konulmaz.
      { ad: 'Belgesi doldu',  filtre: { alan: 'belgeSuresiDoldu', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Satınalma', menuAd: 'Tedarikçiler', ic: '🤝',
    yetkiKodu: 'satinalma.tedarikci', menuSira: 50,
  },
  {
    kaynak: 'satinalmaButce', rota: 'satinalma-butce',
    baslik: 'Bütçe Durumu',
    yol: 'Satınalma › Bütçe',
    kartYolu: '/satinalma-butce', kartBaslik: 'Bütçe Kalemi',
    aksiyonEkrani: 'satinalma-butce-liste',
    // BÜTÇE LİSTESİ KALEMLERİYLE AÇILIR: "Aşıldı" ile açsaydık sağlıklı bir
    //   kurumda ekran boş gelir ve kullanıcı bütçesini hiç göremezdi. Aşım
    //   çipleri hemen yanında.
    cipler: [
      { ad: 'Tümü' },
      // TAAHHÜT DE HARCAMADIR: açık sipariş kalandan düşülür, yoksa aynı para
      //   iki kez harcanır. Yüzde o hesabın üstünden gelir.
      { ad: 'Aşıldı',   filtre: { alan: 'kullanimYuzde', op: 'buyukEsit', deger: 100 } },
      { ad: '%90 üstü', filtre: { alan: 'kullanimYuzde', op: 'buyukEsit', deger: 90 } },
    ],
    menuGrup: 'Satınalma', menuAd: 'Bütçe', ic: '💰',
    yetkiKodu: 'satinalma.butce', menuSira: 60,
  },
];
