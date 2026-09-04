import { FATURA_TIPLERI } from '../../sayfalar/belgeSabitleri';

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
  iadeKutusu, iade, setIade, faturaTipi, setFaturaTipi,
  siparisMi, irsaliyeMi, faturaMi, alisMi, basvuruMu, eBelgeYok, kayitliId,
  kes, yeniBelge, kapat, setDonusum, setTerminAcik,
  rezerveVar, rezerveCalisiyor, rezerveDegistir,
  hastaKartiAc, acilBasvuru, hastaVar, radyolojiIstemi,
}: {
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
  faturaTipi: number;
  setFaturaTipi(v: number): void;
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
  kes(): Promise<number>;
  yeniBelge(): void;
  kapat(): void;
  /** Donusum modalini acar; deger = ON SECILI hedef tur (0 = ilk hedef). */
  setDonusum(v: number | null): void;
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
  /** Basvurudan RADYOLOJI ISTEMI acar (304) - ic istem. */
  radyolojiIstemi?(): void;
  /* TAHSILAT arac cubugundan kalkti - tahsilat kendi sekmesinden aciliyor. */
}) {
  return (
  <>
  {mevcutBelge
    ? (duzenlenebilir
        ? <button className="d onay" disabled={kaydediyor} onClick={() => void kes()}>
            {kaydediyor ? '💾 Kaydediliyor…' : '💾 Değişiklikleri Kaydet'}
          </button>
        : <button className="d onay" disabled
                  title="e-Belge gönderilmiş ya da faturalanmış belge değiştirilemez; iptal edip yeniden kesin.">
            💾 Kaydet
          </button>)
    : sonuc
      ? <button className="d onay" onClick={yeniBelge}>
          {basvuruMu ? '＋ Yeni Başvuru' : '＋ Yeni Belge'}
        </button>
      : <button className="d onay" disabled={kaydediyor} onClick={() => void kes()}>
          {/* BASVURUDA kaydetmek "protokol vermek"tir (mockup): numara kayitla
              atanir, o yuzden dugme isini soyluyor. */}
          {kaydediyor ? '💾 Kaydediliyor…'
            : basvuruMu ? '✔ Başvuruyu Aç (Protokol Ver)' : '💾 Kaydet'}
        </button>}
  {/* Basvuruda IPTAL en SONDA (mockup) - dugme grubunun sonunda durur. */}
  {!basvuruMu && (
    <button className="d teh" disabled title="Belge iptali henüz bağlanmadı (F7).">
      🗑 Sil
    </button>
  )}

  <span className="ayrac" />

  {/* ---------------------------------------------------- BASVURU ---- */}
  {/* Basvuru da tur 19'dur (satis siparisi), ama arac cubugu HBYS mockupunun
      dugmeleridir: rezervasyon/termin/uretim kayit kabulde anlamsiz.
      "Faturaya Dönüştür" mockupta yok ama KORUNDU: kurum payinin faturaya
      cikisi bu dugmeden geciyor, kaldirmak akisi keserdi. */}
  {basvuruMu && (
    <>
      {/* "Provizyon Al" arac cubugundan KALKTI (kullanici): Provizyon
          sekmesinde her odeyicinin kendi grup basliginda duruyor. */}
      <button className="d" disabled title="Protokol fişi yazdırma henüz bağlanmadı.">
        🖨️ Protokol Fişi
      </button>

      <span className="ayrac" />

      <button className="d" disabled={!hastaVar}
              title={hastaVar ? 'Seçili hastanın kartını aç' : 'Önce hasta seçin.'}
              onClick={() => hastaKartiAc?.()}>
        👤 Hasta Kartını Aç
      </button>
      <button className="d" disabled title="Randevudan başvuru açma henüz bağlanmadı.">
        📅 Randevudan Getir
      </button>
      {/* RADYOLOJI ISTEMI (304): coklu tetkik secer, her biri ayri accession
          alir ve ucretleri BU basvuruya eklenir. */}
      <button className="d" disabled={!hastaVar || kilitli}
              title={hastaVar ? 'Bu başvuruya radyoloji tetkiki iste'
                              : 'Önce hasta seçin.'}
              onClick={() => radyolojiIstemi?.()}>
        ☢️ Radyoloji İstemi
      </button>
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

      <button className="d teh" disabled title="Başvuru iptali henüz bağlanmadı (F7).">
        ✕ Başvuruyu İptal Et
      </button>
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
      {/* Dugmeler modali ON SECILI hedefle acar; modaldaki combodan fis ya da
          tahakkuka cevrilebilir (kullanici). */}
      <button className="d" disabled={!kayitliId}
              title={kayitliId ? 'Seçili satırları irsaliyeye aktar' : 'Önce siparişi kaydedin.'}
              onClick={() => setDonusum(alisMi ? 10 : 14)}>
        🚚 İrsaliyeye Dönüştür
      </button>
      <button className="d" disabled={!kayitliId}
              title={kayitliId ? 'Seçili satırları faturaya / fişe / tahakkuka aktar'
                               : 'Önce siparişi kaydedin.'}
              onClick={() => setDonusum(alisMi ? 11 : 15)}>
        🧾 Faturaya Dönüştür
      </button>
      {!basvuruMu &&
        <button className="d" disabled title="Üretim emri henüz bağlanmadı.">🏭 Üretime Aktar</button>}
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
      <button className="d" disabled title="Yazdırma henüz bağlanmadı.">🖨️ Yazdır</button>
    </>
  )}

  {/* --------------------------------------------------- IRSALIYE ---- */}
  {irsaliyeMi && (
    <>
      {/* Konsinyede e-Belge YOK: mal birakma GIB'e gitmez, faturasi
          satildikca ayri kesilir. */}
      {!eBelgeYok && (
        <button className="d bir" disabled={!kayitliId}
                title={kayitliId ? 'e-İrsaliye gönderimi henüz bağlanmadı.' : 'Önce irsaliyeyi kaydedin.'}>
          ✉ e‑İrsaliye Gönder
        </button>
      )}
      <button className="d" disabled={!kayitliId}
              title={kayitliId ? 'Sevk edilen satırları faturaya / fişe / tahakkuka aktar'
                               : 'Önce irsaliyeyi kaydedin.'}
              onClick={() => setDonusum(alisMi ? 11 : 15)}>
        🧾 Faturaya Dönüştür
      </button>
      <button className="d" disabled title="Sevk fişi yazdırma henüz bağlanmadı.">
        🖨️ Sevk Fişi Yazdır
      </button>
      <span className="ayrac" />
      <button className="d" disabled
              title="Siparişten aktarım için Siparişler listesinden ilgili siparişi açıp Dönüştür deyin.">
        📋 Siparişten Aktar
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
      <button className="d bir" disabled={!kayitliId}
              title={kayitliId ? 'e-Belge gönderimi henüz bağlanmadı.' : 'Önce belgeyi kaydedin.'}>
        📤 e‑Fatura Gönder
      </button>
      {/* TAHSILAT ve IADE dugmeleri arac cubugundan KALKTI (kullanici):
          tahsilat kendi SEKMESINDEN aciliyor (Nakit / Banka / POS / Çek /
          Senet dugmeleriyle, arac aracina gore), iade ise faturanin TIPI -
          sagdaki "Fatura Tipi" listesinden secilir. */}
      <button className="d" disabled title="Yazdırma henüz bağlanmadı.">🖨️ Yazdır</button>
    </>
  )}

  <span className="ayrac" />

  {/* BASVURUDA arac cubugunda ROZET YOK (kullanici): protokol no hasta arama
      satirinda, kapanma ("Faturalanmadı") rozeti ise hasta bandinda acik
      borcun saginda duruyor. */}
  {/* ARGUMANSIZ cagrilir: `onClick={kapat}` yazilirsa React MouseEvent'i ilk
      parametreye verir - kartin `kapat(zorla = false)` imzasinda o event
      `zorla = true` demek olur ve kaydedilmemis degisiklik uyarisi HIC
      cikmadan kart kapanirdi (kullanici: "değişiklik yaptım kapat deyince
      uyarı gelmedi"). */}
  <button className="d kapat-dugmesi" onClick={() => kapat()}>✖ Kapat</button>

  {/* FATURA TIPI (130) burada, DUGMELERIN SAGINDA (kullanici): basliktan
      alindi - irsaliyedeki IADE kutusuyla ayni yeri kullanir. Faturanin cinsi
      hem muhasebe fisini hem e-Belge senaryosunu etkiler; belge.tipi alaninda
      tutulur (iade zaten 2 idi). */}
  {faturaMi && (
    <label className="satir-ici" title="Faturanın cinsi (e-Belge senaryosu ve muhasebe fişi buna bağlı)">
      Fatura Tipi
      <select value={faturaTipi} disabled={kilitli} style={{ width: 150 }}
              onChange={e => setFaturaTipi(Number(e.target.value))}>
        {/* Tip 1 KATALOGTA "Alış / Satış" (tek kod, iki yon): ekranda belgenin
            kendi yonuyle yazilir - satis faturasinda "Satış", alista "Alış". */}
        {FATURA_TIPLERI.map(t => (
          <option key={t.deger} value={t.deger}>
            {t.deger === 1 ? (alisMi ? 'Alış' : 'Satış') : t.ad}
          </option>
        ))}
        {/* Gocten gelen tanimsiz tip (or. 17) listede yok: secenek olarak
            EKLENIR, yoksa kart acilinca ilk tipe duser ve kaydedince belgenin
            gercek tipi sessizce degisirdi. */}
        {!FATURA_TIPLERI.some(t => t.deger === faturaTipi) && (
          <option value={faturaTipi}>Tanımsız ({faturaTipi})</option>
        )}
      </select>
    </label>
  )}

  {/* TASLAK KUTUSU KALDIRILDI (kullanici): belge kaydedilince kesindir.
      Numara tuketmeyen "taslak" hali kullanilmiyordu, arac cubugunda yer
      kapliyor ve yanlislikla isaretlenince belge numarasiz kaliyordu.
      Sunucu tarafi duruyor (durum 1) - liste cipleri ve gocten gelen eski
      taslaklar icin gerekli. */}
  {iadeKutusu && (
    <label className="satir-ici" title="İade: mal geri gelir - stok girer, cari alacaklanır.">
      <input type="checkbox" checked={iade} disabled={kilitli}
             onChange={e => setIade(e.target.checked)} />
      İade
    </label>
  )}
</>
  );
}
