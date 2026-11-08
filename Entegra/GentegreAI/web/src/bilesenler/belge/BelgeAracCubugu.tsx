import { c } from '../../dil/ceviri';

/**
 * BELGE KARTI ARAC CUBUGU - Kaydet / Sil ve ture ozel eylemler (siparisten
 * aktar, faturaya donustur, e-Belge gonder, tahsilat, sevk fisi...).
 *
 * Kart govdesinden AYRI: 110 satirlik dugme dizisi, kartin veri akisiyla
 * ilgisi olmayan bir yuzeydi. Dugmelerin ETKIN/PASIF kurallari burada durur -
 * hangi turde ne yapilabilecegi tek bakista okunsun.
 */
export function BelgeAracCubugu({
  mevcutBelge, duzenlenebilir, sonuc, kaydediyor, kilitli,
  iadeKutusu, iade, setIade,
  siparisMi, irsaliyeMi, basvuruMu, eBelgeYok, kayitliId,
  kes, yeniBelge, kapat, setTerminAcik,
  rezerveVar, rezerveCalisiyor, rezerveDegistir,
  hastaKartiAc, acilBasvuru, hastaVar, doktorIstemi, doktorIstemVar, doktorIstemSayi,
  basvuruIptalGorunur, baslik, kapatSolu, onSil,
}: {
  /** Belge başlığını yeniden oku (e-Fatura menüsünden sonra). */
  belgeYenile?(): void;
  /** Sekme (sayfa) kipinde kart başlığı - pencere başlık şeridi yok, ayracın sağında (kullanıcı 26.10.2026). */
  baslik?: React.ReactNode;
  /** Kapat'ın hemen solunda (ör. teklifte "Teklif" çıktı menüsü). */
  kapatSolu?: React.ReactNode;
  /** Kartın kalem sayısı. */
  satirSayisi?: number;
  /** Kayıtlı belgeyi sil (yetki varsa verilir). */
  onSil?(): void;
  mevcutBelge: boolean;
  /** Kayitli belge degistirilebilir mi (135). */
  duzenlenebilir: boolean;
  sonuc: unknown;
  kaydediyor: boolean;
  kilitli: boolean;
  /** IADE kutusu gosterilsin mi - mal geri donusu olabilen turlerde. */
  iadeKutusu?: boolean;
  iade: boolean;
  setIade(v: boolean): void;
  /** Fatura tipi (130) - yalniz faturada, dugmelerin saginda. */
  siparisMi: boolean;
  irsaliyeMi: boolean;
  faturaMi: boolean;
  alisMi: boolean;
  /** Basvuru (246): uretim ve termin dugmeleri gizlenir - HBYS belgesi. */
  basvuruMu?: boolean;
  /** e-Belge (fatura/irsaliye) kavrami olmayan turler: fis, transfer, talep. */
  eBelgeYok: boolean;
  kayitliId: number;
  /** Belgeyi kaydeder; kaydedilen id'yi doner (0 = kaydedilemedi). */
  kes(kapatilsin?: boolean): Promise<number>;
  yeniBelge(): void;
  kapat(): void;
  /** Termin (teslim tarihi) modalini acar - 140. */
  setTerminAcik(v: boolean): void;
  /** Sipariste rezerve edilmis satir var mi (142). */
  rezerveVar: boolean;
  rezerveCalisiyor: boolean;
  /** true = rezerve et, false = birak. */
  rezerveDegistir(ac: boolean): Promise<void>;
  /** Basvuru dugmeleri (300, mockup): hasta karti / acil basvuru. */
  hastaKartiAc?(): void;
  acilBasvuru?(): void;
  /** Hasta secili mi - "Hasta Kartını Aç" ona bagli. */
  hastaVar?: boolean;
  /** DOKTOR İSTEMİ: hekimin muayenede açtığı bekleyen lab/radyoloji istemlerini
   *  ücretlendirir (belge_satir). Yalnız bekleyen istem varsa aktif. */
  doktorIstemi?(): void;
  doktorIstemVar?: boolean;
  doktorIstemSayi?: number;
  /** Başvuru İptal düğmesi görünür mü: yalnız başvuru sekmesi doluyken (ücret
   *  kalemi / doktor istemi yoksa). Diğer sekmelerde veri varsa iptal gizlenir. */
  basvuruIptalGorunur?: boolean;
  /* TAHSILAT arac cubugundan kalkti - tahsilat kendi sekmesinden aciliyor. */
}) {
  return (
  <>
  {mevcutBelge
    ? (duzenlenebilir
        ? <button className="d onay" disabled={kaydediyor} onClick={() => void kes()}>
            {kaydediyor ? '💾 Kaydediliyor…' : '💾 Kaydet'}
          </button>
        : <button className="d onay" disabled
                  title="e-Belge gönderilmiş ya da faturalanmış belge değiştirilemez; iptal edip yeniden kesin.">
            💾 Kaydet
          </button>)
    // "＋ Yeni Belge" yalnız başvuruda (kullanıcı 26.10.2026: "kayıtlı fatura kartında +yeni belge butonu ...
    //   görünmesin") - kayıtlı ERP belgesi mevcutBelge dalında Kaydet gösterir.
    : sonuc && basvuruMu
      ? <button className="d onay" onClick={yeniBelge}>
          {basvuruMu ? '＋ Yeni Başvuru' : '＋ Yeni Belge'}
        </button>
      : <button className="d onay" disabled={kaydediyor} onClick={() => void kes()}>
          {/* BASVURUDA kaydetmek "protokol vermek"tir (mockup): numara kayitla
              atanir, o yuzden dugme isini soyluyor. "Aç" yerine KAYDET
              (782, kullanici): dugme bir kayit islemi yapiyor, ekran acmiyor -
              "Aç" kelimesi yeni bir pencere bekletiyordu. */}
          {kaydediyor ? '💾 Kaydediliyor…'
            : basvuruMu ? '💾 Kaydet (Protokol Ver)' : '💾 Kaydet'}
        </button>}
  {/* Basvuruda IPTAL en SONDA (mockup) - dugme grubunun sonunda durur. */}
  {/* KARTTA SİL (kullanıcı 02.11.2026: "kartta da sil butonu olsun") - kayıtlı belgede, silme yetkisi olana; listedeki
      Sil ile aynı uç (fn_belge_sil). 26.10'daki "kalemli belgede sil yok" kuralının yerini aldı. */}
  {!basvuruMu && onSil && (
    <button className="d teh" disabled={!kayitliId || kaydediyor} title={kayitliId ? c('Belgeyi sil') : c('Önce kaydedin.')}
            onClick={() => onSil()}>
      🗑 Sil
    </button>
  )}

  <span className="ayrac" />

  {/* Fiş "⇩ Aktar ▾" Kalemler sekmesinde, Sil'in sağında (kullanıcı 07.11.2026) - KalemSekmesi.aktarAc. */}

  {/* ---------------------------------------------------- BASVURU ---- */}
  {/* Basvuru da tur 19'dur (satis siparisi), ama arac cubugu HBYS mockupunun
      dugmeleridir: rezervasyon/termin/uretim kayit kabulde anlamsiz.
      "Faturaya Dönüştür" mockupta yok ama KORUNDU: kurum payinin faturaya
      cikisi bu dugmeden geciyor, kaldirmak akisi keserdi. */}
  {basvuruMu && (
    <>
      {/* "Provizyon Al" arac cubugundan KALKTI (kullanici): Provizyon
          sekmesinde her odeyicinin kendi grup basliginda duruyor. */}
      <button className="d" disabled title={c('Protokol fişi yazdırma henüz bağlanmadı.')}>
        🖨️ Protokol Fişi
      </button>

      <span className="ayrac" />

      <button className="d" disabled={!hastaVar}
              title={hastaVar ? 'Seçili hastanın kartını aç' : 'Önce hasta seçin.'}
              onClick={() => hastaKartiAc?.()}>
        👤 Hasta Kartını Aç
      </button>
      <button className="d" disabled title={c('Randevudan başvuru açma henüz bağlanmadı.')}>
        📅 Randevudan Getir
      </button>
      {/* DOKTOR İSTEMİ: hekimin muayenede açtığı bekleyen istemleri ücretlendirir.
          Yalnız bekleyen doktor istemi varsa görünür/aktif olur (kullanıcı kuralı).
          İstem YALNIZ başvurudan/muayeneden açılır; buradan boş kart açılmaz. */}
      {doktorIstemVar && (
        <button className="d bir" disabled={kilitli}
                title="Doktorun istediği tetkikleri ücretlendir ve çalışma listesine düşür"
                onClick={() => doktorIstemi?.()}>
          🩺 Doktor İstemi{doktorIstemSayi ? ` (${doktorIstemSayi})` : ''}
        </button>)}
      {/* Acil basvuru: turu Acil, gelis seklini Ambulans yapar - kayit kabul
          memuru acil kapisinda iki combo yerine tek dugmeye bassin. */}
      <button className="d" disabled={kilitli}
              title="Başvuru türünü Acil, geliş şeklini Ambulans yapar"
              onClick={() => acilBasvuru?.()}>
        🚑 Acil Başvuru
      </button>

      <span className="ayrac" />

      {/* "Yatışa Çevir" KALDIRILDI (kullanici): yatan hasta modulu yok,
          pasif dugme yer kapliyordu. Modul gelince geri konur. */}
      {/* TAHSILAT ve FATURAYA DONUSTUR arac cubugunda YOK (kullanici):
          tahsilat kendi sekmesinden yapiliyor, faturaya donusum ise
          Basvurular listesindeki "→ Dönüştür" aksiyonundan - kayit kabul
          memurunun ekraninda durmasi gerekmiyor. */}

      <span className="ayrac" />

      {/* İPTAL yalnız BAŞVURU SEKMESİ doluyken görünür (kullanıcı): ücret
          kalemi ya da doktor istemi girildiyse - yani diğer sekmelerde veri
          varsa - başvuru iptal edilemez, düğme gizlenir. */}
      {basvuruIptalGorunur && (
        <button className="d teh" disabled title={c('Başvuru iptali henüz bağlanmadı (F7).')}>
          ✕ Başvuruyu İptal Et
        </button>)}
    </>
  )}

  {/* ---------------------------------------------------- SIPARIS ---- */}
  {siparisMi && !basvuruMu && (
    <>
      {/* REZERVASYON (142): satirlarin KALAN miktarini depoda ayirir - stok
          dusmez, ama stok aramasinda "kullanilabilir" miktardan dusulur, ayni
          mal ikinci musteriye satilamaz. Sevk edildikce kendiliginden cozulur. */}
      <button className="d bir" disabled={!kayitliId || rezerveCalisiyor}
              title={kayitliId
                ? (rezerveVar ? 'Ayrılan miktarı serbest bırak'
                              : 'Kalan miktarı depoda ayır (stok düşmez)')
                : 'Önce siparişi kaydedin.'}
              onClick={() => void rezerveDegistir(!rezerveVar)}>
        {rezerveCalisiyor ? '⏳ İşleniyor…' : rezerveVar ? '🔓 Rezervi Kaldır' : '🔒 Rezervasyon Yap'}
      </button>
      {/* "İrsaliyeye Dönüştür" / "Belge Dönüştür" BELGEYE DÖNÜŞÜM SEKMESİNDE (kullanıcı 07.11.2026: irsaliye deseni
          siparişte de) - hedef menüsü (irsaliye / fatura / fiş / tahakkuk) oradan açılır. */}
      {/* "Üretime Aktar" Belgeye Dönüşüm sekmesindeki Belge Dönüştür menüsünün en üstünde (kullanıcı 07.11.2026). */}
      <span className="ayrac" />
      {/* ON ODEME dugmesi kalkti (kullanici): avans/on odeme artik siparisin
          kendi Tahsilat sekmesinden giriliyor - fatura kartiyla ayni yer,
          arac (nakit/banka/POS/çek/senet) orada secilir. */}
      {/* TERMIN (140): satirlarin teslim tarihini toplu gunceller. Tutar/stok/
          cari etkilemedigi icin KESIN sipariste de calisir - gecikince siparisi
          iptal edip yeniden kesmeye gerek yok. */}
      {!basvuruMu &&
        <button className="d" disabled={!kayitliId}
                title={kayitliId ? 'Satırların teslim tarihini güncelle'
                                 : 'Önce siparişi kaydedin.'}
                onClick={() => setTerminAcik(true)}>
          📅 Termin Güncelle
        </button>}
      <button className="d" disabled title={c('Yazdırma henüz bağlanmadı.')}>🖨️ Yazdır</button>
    </>
  )}

  {/* --------------------------------------------------- IRSALIYE ---- */}
  {irsaliyeMi && (
    <>
      {/* Konsinyede e-Belge YOK: mal birakma GIB'e gitmez, faturasi
          satildikca ayri kesilir. */}
      {/* e-İRSALİYE MENÜSÜ DE ARAÇ ÇUBUĞUNDAN KALKTI (kullanıcı 08.11.2026: "irsaliye kartında da 2 tane İrsaliye
          İşlem var, üst başlıktakini kaldır"): tek menü e-Belge sekmesinde (BelgeSekmeleri, tur 14). */}
      {/* HEDEF MENÜSÜ ("Belge Dönüştür") ve "Siparişten Aktar" BELGEYE DÖNÜŞÜM SEKMESİNDE (kullanıcı 07.11.2026) -
          FaturalamaSekmesi hizliYok. */}
      <button className="d" disabled title={c('Sevk fişi yazdırma henüz bağlanmadı.')}>
        🖨️ Sevk Fişi Yazdır
      </button>
      {/* GIB DURUM SORGULA kaldirildi (kullanici): gonderim ucu baglanana kadar
          arac cubugunda yer kapliyordu; durum e-Belge sekmesinde zaten yazili.
          IADE IRSALIYESI dugmesi de kalkti - iade artik arac cubugundaki
          "İade" kutusuyla ayni kart uzerinden kesiliyor (133). */}
    </>
  )}

  {/* ----------------------------------------------------- FATURA ---- */}
  {/* e-Belge olmayan turlerde (fis/konsinye/tahakkuk) gonderim dugmeleri YOK. */}
  {!siparisMi && !irsaliyeMi && !eBelgeYok && (
    <>
      {/* e-FATURA MENÜSÜ ARAÇ ÇUBUĞUNDAN KALKTI (kullanıcı 08.11.2026: "fatura kartında 2 tane Fatura İşlem var,
          üst başlıktakini kaldır"): tek menü e-Belge sekmesinde (BelgeSekmeleri), kayıtlı belgede. */}
      {/* TAHSILAT ve IADE dugmeleri arac cubugundan KALKTI (kullanici):
          tahsilat kendi SEKMESINDEN aciliyor (Nakit / Banka / POS / Çek /
          Senet dugmeleriyle, arac aracina gore), iade ise faturanin TIPI -
          basliktaki "Fatura Tipi" listesinden secilir. */}
      <button className="d" disabled title={c('Yazdırma henüz bağlanmadı.')}>🖨️ Yazdır</button>
    </>
  )}

  <span className="ayrac" />
  {baslik && <span className="belge-ara-baslik">{baslik}</span>}

  {/* BASVURUDA arac cubugunda ROZET YOK (kullanici): protokol no hasta arama
      satirinda, kapanma ("Faturalanmadı") rozeti ise hasta bandinda acik
      borcun saginda duruyor. */}
  {/* ARGUMANSIZ cagrilir: `onClick={kapat}` yazilirsa React MouseEvent'i ilk
      parametreye verir - kartin `kapat(zorla = false)` imzasinda o event
      `zorla = true` demek olur ve kaydedilmemis degisiklik uyarisi HIC
      cikmadan kart kapanirdi (kullanici: "değişiklik yaptım kapat deyince
      uyarı gelmedi"). */}
  {kapatSolu && <span className="kapat-solu">{kapatSolu}</span>}
  <button className="d kapat-dugmesi" onClick={() => kapat()}>✖ {c('Kapat')}</button>

  {/* TASLAK KUTUSU KALDIRILDI (kullanici): belge kaydedilince kesindir.
      Numara tuketmeyen "taslak" hali kullanilmiyordu, arac cubugunda yer
      kapliyor ve yanlislikla isaretlenince belge numarasiz kaliyordu.
      Sunucu tarafi duruyor (durum 1) - liste cipleri ve gocten gelen eski
      taslaklar icin gerekli. */}
  {iadeKutusu && (
    <label className="satir-ici" title="İade: mal geri gelir - stok girer, cari alacaklanır.">
      <input type="checkbox" checked={iade} disabled={kilitli}
             onChange={e => setIade(e.target.checked)} />{c('İade')}</label>
  )}
</>
  );
}
