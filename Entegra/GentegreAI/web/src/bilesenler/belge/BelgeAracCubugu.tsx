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
  siparisMi, irsaliyeMi, alisMi, eBelgeYok, kayitliId, cari,
  kes, yeniBelge, kapat, setDonusum, tahsilatAc,
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
  siparisMi: boolean;
  irsaliyeMi: boolean;
  alisMi: boolean;
  /** e-Belge (fatura/irsaliye) kavrami olmayan turler: fis, transfer, talep. */
  eBelgeYok: boolean;
  kayitliId: number;
  /** Cari secili mi - tahsilat/e-Belge dugmeleri carisiz calismaz. */
  cari: unknown;
  kes(): Promise<void>;
  yeniBelge(): void;
  kapat(): void;
  /** Donusum modalini acar; deger = ON SECILI hedef tur (0 = ilk hedef). */
  setDonusum(v: number | null): void;
  tahsilatAc(tur: number): void;
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
      ? <button className="d onay" onClick={yeniBelge}>＋ Yeni Belge</button>
      : <button className="d onay" disabled={kaydediyor} onClick={() => void kes()}>
          {kaydediyor ? '💾 Kaydediliyor…' : '💾 Kaydet'}
        </button>}
  <button className="d teh" disabled title="Belge iptali henüz bağlanmadı (F7).">
    🗑 Sil
  </button>

  <span className="ayrac" />

  {/* ---------------------------------------------------- SIPARIS ---- */}
  {siparisMi && (
    <>
      <button className="d bir" disabled title="Stok rezervasyonu henüz bağlanmadı.">
        🔒 Rezervasyon Yap
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
      <button className="d" disabled title="Üretim emri henüz bağlanmadı.">🏭 Üretime Aktar</button>
      <span className="ayrac" />
      <button className="d" disabled={!kayitliId || !cari}
              title={kayitliId
                ? `Bu sipariş için ön ödeme (${alisMi ? 'ödeme' : 'tahsilat'}) işlemi aç`
                : 'Önce siparişi kaydedin.'}
              onClick={() => tahsilatAc(alisMi ? 31 : 21)}>
        💵 {alisMi ? 'Ön Ödeme Yap' : 'Ön Ödeme Al'}
      </button>
      <button className="d" disabled title="Termin güncelleme henüz bağlanmadı.">📅 Termin Güncelle</button>
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
      <button className="d" disabled={!kayitliId || !cari}
              title={kayitliId ? 'Bu belge için tahsilat işlemi aç' : 'Önce belgeyi kaydedin.'}
              onClick={() => tahsilatAc(21)}>
        💵 {alisMi ? 'Ödeme' : 'Tahsilat'}
      </button>
      <button className="d" disabled title="İade belgesi henüz bağlanmadı.">↩ İade</button>
      <button className="d" disabled title="Yazdırma henüz bağlanmadı.">🖨️ Yazdır</button>
    </>
  )}

  <span className="ayrac" />

  <button className="d kapat-dugmesi" onClick={kapat}>✖ Kapat</button>

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
