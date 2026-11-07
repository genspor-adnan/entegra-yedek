import { EFaturaBilgileri } from '../efatura/EFaturaBilgileri';
import { EFaturaMenusu } from '../efatura/EFaturaMenusu';
import { DonusumMenusu } from './DonusumMenusu';
import { useRef, useState } from 'react';
import { TarafSecici } from '../TarafArama';
import { TESLIM_SEKLI, SENARYO_SECENEK, eBelgeTipi } from '../../sayfalar/belgeSabitleri';
import type { BelgeYaniti } from '../../api/sozlesme';
import type { SevkiyatBilgisi }
  from '../../sayfalar/belgeKarti/useSevkiyatBilgisi';
import { para, tarihSaat } from '../bicim';
import { c } from '../../dil/ceviri';
import { gorunenBelgeNo } from '../../sayfalar/belgeKartiKurallari';

/**
 * BELGE KARTI SEKMELERI - Tasiyici / e-Belge / Faturalama.
 *
 * Uc sekme de yalniz baslik alanlarini gosterir; kalem, tahsilat ve yorum
 * sekmeleri kartin kendi durumuna daha sikca bagli oldugu icin kartta kaldi.
 */

export function TasiyiciSekmesi({ kilitli, sevkiyat, belge }: {
  kilitli: boolean;
  /** Sevkiyat alanlari DEMET halinde gelir (belgeKarti/useSevkiyatBilgisi):
      on dort ayri prop yerine tek nesne - yeni alan tek yerde eklenir. */
  sevkiyat: SevkiyatBilgisi;
  /** Kayitli belge - sevk adresi ve e-Belge durum alanlari buradan okunur. */
  belge?: BelgeYaniti['belge'];
}) {
  const {
    tasiyici, setTasiyici, teslimEden, setTeslimEden,
    aracPlaka, setAracPlaka, soforAd, setSoforAd, soforTckn, setSoforTckn,
    sevkTarihi, setSevkTarihi, teslimSekli, setTeslimSekli,
  } = sevkiyat;
  return (
  <div className="kagrup">
    <h6>{c('Taşıyıcı Bilgileri')}</h6>
    <div className="alan-izgara uc-sutun">
      <TarafSecici
        etiket="Taşıyıcı Ünvan"
        deger={tasiyici?.ad}
        kilitli={kilitli}
        yerTutucu="Taşıyıcı ara…"
        onSec={sec => setTasiyici({ id: sec.id, ad: sec.unvan })}
        onTemizle={() => setTasiyici(null)}
      />
      {/* Teslim eden PERSONEL de olabilir - iki kaynak birlikte aranir. */}
      <TarafSecici
        etiket="Teslim Eden"
        deger={teslimEden?.ad}
        kilitli={kilitli}
        kaynaklar={['personel', 'cari']}
        yerTutucu="Personel / cari ara…"
        onSec={sec => setTeslimEden({ id: sec.id, ad: sec.unvan })}
        onTemizle={() => setTeslimEden(null)}
      />
      <label className="alan">
        <span className="etiket">{c('Teslim Şekli')}</span>
        <select value={teslimSekli} disabled={kilitli}
                onChange={e => setTeslimSekli(Number(e.target.value))}>
          {TESLIM_SEKLI.map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
        </select>
      </label>
      <label className="alan genis-2">
        <span className="etiket">{c('Sevk Adresi')}</span>
        <input value={[belge?.tarafAdres, belge?.tarafIlce, belge?.tarafIl]
                        .filter(Boolean).join(' / ')} readOnly
               placeholder="Cari seçilince kartındaki varsayılan adres gelir" />
      </label>
      <label className="alan">
        <span className="etiket">{c('Sevk Zamanı')}</span>
        <input type="datetime-local" value={sevkTarihi} disabled={kilitli}
               onChange={e => setSevkTarihi(e.target.value)} />
      </label>
      <label className="alan">
        <span className="etiket">{c('Araç Plakası')}</span>
        <input value={aracPlaka} maxLength={20} disabled={kilitli}
               placeholder="07 ABC 145"
               onChange={e => setAracPlaka(e.target.value.toUpperCase())} />
      </label>
      <label className="alan">
        <span className="etiket">{c('Şoför Adı')}</span>
        <input value={soforAd} maxLength={60} disabled={kilitli}
               onChange={e => setSoforAd(e.target.value)} />
      </label>
      <label className="alan">
        <span className="etiket">Şoför Kimlik No</span>
        <input value={soforTckn} maxLength={11} disabled={kilitli}
               placeholder="11 hane"
               onChange={e => setSoforTckn(e.target.value.replace(/\D/g, ''))} />
      </label>
    </div>
    <div className="not">
      Bu alanlar e-İrsaliye UBL'ine gider (TransportMeans/PlateID,
      DriverPerson, CarrierParty, ShipmentStage). Kap adedi, brüt ağırlık
      ve sevkiyat aşamaları (yola çıkış / teslim) henüz şemada yok.
    </div>
  </div>
  );
}

export function EBelgeSekmesi({
  kilitli, irsaliyeMi, tur, senaryo, setSenaryo, senaryoGizli, belge, belgeYenile,
}: {
  kilitli: boolean;
  irsaliyeMi: boolean;
  tur: number;
  senaryo: number; setSenaryo(v: number): void;
  /** Senaryo kart başlığında (fatura - kullanıcı 26.10.2026). */
  senaryoGizli?: boolean;
  belge?: BelgeYaniti['belge'];
  belgeYenile?(): void;
}) {
  const belgeId = Number(belge?.id ?? 0);
  const efDurum = Number(belge?.efaturaDurum ?? 0);
  const faturaMi = tur === 15;
  return (
  <div className="kagrup">
    {/* Alan sirasi Ekranlar/satis_faturasi.html "e-Belge" sekmesiyle AYNI:
        Belge Tipi · Alias (URN) · Senaryo · Durum · ETTN/Zarf No.
        Adres mockup'ta yok, kullanici istegiyle burada duruyor. */}
    <h6>
      {irsaliyeMi ? 'e-İrsaliye' : 'e-Fatura / e-Arşiv'}
      {/* e-FATURA MENUSU (11.10.2026): Delphi e-Fatura menusu - eski pasif
          "henuz baglanmadi" dugmelerinin yerine. */}
      {faturaMi && belgeId > 0 && <EFaturaMenusu belgeId={belgeId} onDegisti={belgeYenile} />}
      {tur === 14 && belgeId > 0 && <EFaturaMenusu belgeId={belgeId} onDegisti={belgeYenile} etiket="İrsaliye İşlem" />}
    </h6>
    {/* Mockup'ta (.grid2) her alan KENDI SATIRINDA: etiket solda, deger
        sagda. Uc sutuna yayilinca sira okunmuyordu. */}
    <div className="alan-izgara tek-sutun">
      <label className="alan">
        <span className="etiket">{c('Belge Tipi')}</span>
        <input value={eBelgeTipi(tur, senaryo)} readOnly />
      </label>
      <label className="alan">
        <span className="etiket">{c('Alias (URN)')}</span>
        <input value={String(belge?.gondericiAlias ?? '') || '—'} readOnly />
      </label>

      {!senaryoGizli && <label className="alan">
        <span className="etiket">Senaryo</span>
        <select value={senaryo} disabled={kilitli}
                onChange={e => setSenaryo(Number(e.target.value))}>
          {SENARYO_SECENEK.map(o => (
            <option key={o.deger} value={o.deger}>{o.ad}</option>
          ))}
        </select>
      </label>}
      <label className="alan">
        <span className="etiket">Durum</span>
        <span className="deger-serit">
          {efDurum === 2 || efDurum === 12
            ? <span className="rozet ok">{efDurum === 12 ? 'e-Arşiv gönderildi' : 'e-Fatura gönderildi'}</span>
            : efDurum === 1 || efDurum === 11
              ? <span className={'rozet ' + (Number(belge?.efaturaSonuc ?? 0) === 3 ? 'hata' : 'uyari')}>
                  {efDurum === 11 ? 'e-Arşiv hazır' : 'e-Fatura hazır'}
                  {Number(belge?.efaturaSonuc ?? 0) === 3 ? ' · gönderim hatası' : ''}</span>
              : <span className="rozet gri">{c('Taslak')}</span>}
          {belge?.gibDurumAciklama
            ? <span className="sonuk">{String(belge.gibDurumAciklama)}</span>
            : null}
        </span>
      </label>

      <label className="alan">
        <span className="etiket">{c('ETTN / Zarf No')}</span>
        <input readOnly value={
          [String(belge?.ettn ?? ''), String(belge?.zarfId ?? 0) !== '0'
            ? String(belge?.zarfId) : '']
            .filter(Boolean).join(' / ') || '—'} />
      </label>

      {/* Adres basliktan buraya tasindi: e-Belge XML'ine giden alici
          bilgisi, kesim sirasinda degil gonderim baglaminda okunuyor. */}
      <label className="alan genis-2">
        <span className="etiket">Adres</span>
        <input value={[belge?.tarafAdres, belge?.tarafIlce, belge?.tarafIl]
                        .filter(Boolean).join(' / ')} readOnly
               placeholder="Cari seçilince kartındaki varsayılan adres gelir" />
      </label>
    </div>

    {faturaMi && (
      <EFaturaBilgileri belgeId={belgeId} tipi={Number(belge?.tipi ?? 0)} senaryo={senaryo} kilitli={kilitli} />
    )}
  </div>
  );
}

export function FaturalamaSekmesi({ donusumler, kayitliId, setDonusum, teklifMi, kurumPayliMi,
                                    teklifDurum, donusumAc, donusumSil,
                                    hizliDonustur, olcu = 'adet', setOlcu, donusumYenile, hizliYok, sekmedeAc, kaynakTur }: {
  donusumler: Record<string, unknown>[];
  /** İRSALİYE (kullanıcı 07.11.2026): Fiş / Fatura / Kurum-Hasta Tahakkuk / Adet-Tutar / Fatura İşlem / ✎ / 🗑 ve seçim
      kutusu YOK; sekme yalnız türetilmiş belge listesi, Tür'e tıklayınca belge YENİ SEKMEDE (sekmedeAc). Dönüşüm araç
      çubuğundaki hedef menüsünden. */
  hizliYok?: boolean;
  /** Türetilmiş belgeyi kendi sekmesinde açar (hizliYok ile); `tur` yol için (türün liste rotası). */
  sekmedeAc?(id: number, tur: number): void;
  /** hizliYok: "Belge Dönüştür" hedef menüsünün kaynak türü (10 alış / 14 satış irsaliyesi) - araç çubuğundan taşındı. */
  kaynakTur?: number;

  kayitliId: number;
  /** Donusum modalini acar; 0 = hedefi modal secsin (ilk hedef). */
  setDonusum(v: number | null): void;
  /** Teklifte sekme "Sipariş"tir ve tek hedef siparis (216). */
  teklifMi?: boolean;
  /**
   * ODEYEN KURUM PAY ALIYOR MU (ÖSS/SGK). Özel (ücretli) başvuruda kurumun
   * payı hep sıfırdır - "Kurum Tahakkuk" düğmesi orada her zaman boş sonuç
   * verir ve "neden çalışmıyor" sorusu doğurur (kullanıcı). Verilmezse düğme
   * ÇİZİLİR: ERP belgelerinde tahakkuk tek taraflıdır.
   */
  kurumPayliMi?: boolean;
  /** Teklif YALNIZ Kabul (3) durumundayken donusur (kullanici) - sunucu da
      ayni kurali dogrular. */
  teklifDurum?: string;
  /** Turetilmis belgenin kartini USTTE acar (cift tik ve ✎ dugmesi). */
  donusumAc?(belgeId: number): void;
  /** Secili turetilmis belgeleri siler; kaynak satirin kalani geri doner. */
  donusumSil?(idler: number[]): Promise<void>;
  /**
   * HIZLI DONUSUM (kullanici): modal ACMADAN hedef belgeyi uretir ve alttaki
   * listeye ekler - tahsilat sekmesindeki hizli akisin aynisi.
   * hedefTur: 16 Fiş · 15 Fatura · 17 Tahakkuk.
   */
  hizliDonustur?(hedefTur: number, taraf?: 'hasta' | 'kurum'): void;
  /** Donusum olcusu: 'adet' kalan MIKTAR, 'tutar' tahsil edilen/kalan TUTAR. */
  olcu?: 'adet' | 'tutar';
  setOlcu?(v: 'adet' | 'tutar'): void;
  /** Listeyi yeniden oku (e-Fatura menusunden sonra). */
  donusumYenile?(): void;
}) {
  const donusumKapali = !!teklifMi && teklifDurum !== '3';
  /* COKLU SECIM (kullanici): bir basvurudan birden cok belge turuyor
     (kismi fis + kalan tahakkuk) - yanlis dogan iki belgeyi tek tek
     silmek yerine isaretleyip birlikte silmek gerekiyor. */
  const [secili, setSecili] = useState<number[]>([]);
  const idler = donusumler.map(d => Number(d.belgeId ?? 0)).filter(Boolean);
  const hepsi = idler.length > 0 && secili.length === idler.length;
  const cevir = (id: number) =>
    setSecili(o => (o.includes(id) ? o.filter(x => x !== id) : [...o, id]));
  const tekSecili = secili.length === 1 ? secili[0] : 0;
  // e-FATURA HEDEFI: secili tek fatura; secim yoksa ve basvurudan TEK fatura
  //   dogduysa o (kullanici: "efatura ya tıklıyorum menü çıkmıyor" - satir
  //   secilmeden dugme pasif kaliyordu).
  const faturalar = donusumler.filter(d => Number(d.tur) === 15).map(d => Number(d.belgeId));
  // e-Fatura HAZIR / GONDERILMIS fatura silinemez (kullanici 11.10.2026; sunucu
  //   fn_belge_silinebilir de reddeder - dugme bastan pasif).
  const eKilitli = donusumler.some(d => secili.includes(Number(d.belgeId)) && Number(d.efaturaDurum ?? 0) > 0);
  const tekFatura = tekSecili ? (faturalar.includes(tekSecili) ? tekSecili : 0)
                   : secili.length === 0 && faturalar.length === 1 ? faturalar[0] : 0;

  /* SATIR TIKLAMA GRID DAVRANISI (kullanici): duz tik TEK satir secer -
     onceki isaretler kalkar; Ctrl (Cmd) tek satir ekler/cikarir; Shift son
     tiklanan satirdan buraya kadar ARALIK secer. Onay kutusunun kendisi her
     zaman ekle/cikar yapar (fare ile tek tek isaretlemenin yolu). */
  const capa = useRef<number | null>(null);   // son tiklanan satirin sirasi
  const satirTikla = (e: React.MouseEvent, sira: number, id: number) => {
    if (!id) return;
    if (e.shiftKey && capa.current != null) {
      const [bas, son] = capa.current <= sira ? [capa.current, sira] : [sira, capa.current];
      const aralik = donusumler.slice(bas, son + 1)
        .map(d => Number(d.belgeId ?? 0)).filter(Boolean);
      // Shift SECIMI YENILER (grid deseni): capa sabit kalir ki aralik
      //   ayni noktadan buyuyup kuculsun.
      setSecili(aralik);
      return;
    }
    capa.current = sira;
    if (e.ctrlKey || e.metaKey) { cevir(id); return }
    // Duz tik: yalniz bu satir. Zaten tek basina seciliyse secim kalkar.
    setSecili(o => (o.length === 1 && o[0] === id ? [] : [id]));
  };

  return (
  // `tasar`: açılır menüler (Belge Dönüştür ▾ / Fatura İşlem ▾) grubun altından taşabilsin - kagrup overflow:hidden,
  //   boş listede menü alttan kırpılıyordu (kullanıcı 07.11.2026).
  <div className="kagrup tasar">
    <h6>
      {/* Baslik degil ETIKET (kullanici): saginda duran Fiş / Fatura /
          Tahakkuk dugmelerini niteler - "hangi belgeyi keseyim". */}
      {teklifMi ? 'Sipariş' : hizliYok ? c('Türetilen belgeler') : 'Belge seç :'}

      {/* İRSALİYE (kullanıcı 07.11.2026 "belgeye dönüştür ve siparişten aktar butonlarını sekmeye taşı"): hedef
          menüsü seçilen türle dönüşüm penceresini açar (satır / adet seçimi orada). Siparişten Aktar henüz bağlı
          değil - yol Siparişler listesinden. */}
      {hizliYok && kaynakTur && (
        <>
          {/* "Siparişten / Tekliften Aktar" Kalemler sekmesinde (kullanıcı 07.11.2026, KalemSekmesi.aktarSecenekleri). */}
          <DonusumMenusu kaynakTur={kaynakTur} devre={!kayitliId}
                         devreSebep={kaynakTur === 9 || kaynakTur === 19 ? 'Önce siparişi kaydedin.' : 'Önce irsaliyeyi kaydedin.'}
                         title={kaynakTur === 9 || kaynakTur === 19
                           ? 'Satırları irsaliyeye / faturaya / fişe / tahakkuka aktar'
                           : 'Sevk edilen satırları faturaya / fişe / tahakkuka aktar'}
                         // ÜRETİME AKTAR menünün EN ÜSTÜNDE + ayraç (kullanıcı 07.11.2026); yalnız sipariş. Üretim emri
                         //   bağlantısı henüz yok (uretim_emri.kaynak_belge_id hazır) - pasif, sebep söylenir.
                         ustMadde={kaynakTur === 9 || kaynakTur === 19
                           ? { ad: 'Üretime Aktar', ikon: '🏭', pasif: true, sebep: 'Üretim emri henüz bağlanmadı.' }
                           : undefined}
                         onSec={setDonusum} />
        </>
      )}

      {/* HIZLI DONUSUM (kullanici): modal ACMADAN hedef belgeyi uretir ve
          alttaki listeye ekler - tahsilat sekmesindeki hizli akisin aynisi.
          Ayrintili secim (satir/tutar/kismi) yine "Faturaya Dönüştür"de. */}
      {kayitliId > 0 && !teklifMi && !hizliYok && (
        <>
          <button type="button" className="d bir" disabled={donusumKapali}
                  title={`Tüm açık satırları ${olcu === 'adet' ? 'kalan miktarla' : 'tahsil edilen tutarla'} satış FİŞİNE çevirir`}
                  onClick={() => hizliDonustur?.(16)}>🧾 Fiş</button>
          <button type="button" className="d bir" disabled={donusumKapali}
                  title={`Tüm açık satırları ${olcu === 'adet' ? 'kalan miktarla' : 'tahsil edilen tutarla'} FATURAYA çevirir`}
                  onClick={() => hizliDonustur?.(15)}>📄 Fatura</button>
          {kurumPayliMi !== false && (
          <button type="button" className="d bir" disabled={donusumKapali}
                  title="Kurum payını TAHAKKUKA çevirir (kalanın tamamı) - alacak kurum carisine yazılır"
                  onClick={() => hizliDonustur?.(17, 'kurum')}>📑 Kurum Tahakkuk</button>
          )}
          {/* HASTA TAHAKKUKU (kullanici: "tahakkukları ikiye ayıralım: Kurum
              Tahakkuku ve Hasta Tahakkuku"): hastanin payi da pesin tahsil
              edilmeden belgelenebilir - sonra tahsilat yapilir. Dugme hangi
              tarafi belgeledigini soyler; pay ZORLANIR, "hangi kova aciksa"
              tahminine birakilmaz. */}
          <button type="button" className="d bir" disabled={donusumKapali}
                  title="Hasta payını TAHAKKUKA çevirir (kalanın tamamı) - alacak hasta carisine yazılır"
                  onClick={() => hizliDonustur?.(17, 'hasta')}>
            📑 Hasta Tahakkuk</button>
        </>
      )}

      {/* "Faturaya Dönüştür" KALKTI (kullanici): ayrintili secim modalini acan
          ikinci yol, yanindaki Fiş / Fatura / Tahakkuk dugmeleriyle ayni isi
          yapiyormus gibi duruyordu - hangisinin ne yaptigi belirsizdi. Modal
          yine arac cubugundaki "Belge Kes" ile aciliyor.
          TEKLIFTE KALIR: teklif -> siparis donusumunun BASKA yolu yok (hizli
          dugmeler teklifte hic cizilmiyor). */}
      {kayitliId > 0 && teklifMi && (
        <button type="button" className="d bir" disabled={donusumKapali}
                title={donusumKapali
                  ? 'Yalnız KABUL durumundaki teklif siparişe dönüştürülebilir.' : undefined}
                onClick={() => setDonusum(0)}>{c('📋 Siparişe Dönüştür')}</button>
      )}

      {/* DONUSUM OLCUSU (kullanici): varsayilan ADET - satirin kalan miktari
          cevrilir. TUTAR olcusunde fis/faturada TAHSIL EDILEN kadar,
          tahakkukta kalanin tamami cevrilir (352). */}
      {kayitliId > 0 && !teklifMi && !hizliYok && (
        <span className="seg olcu" title={c('Hızlı dönüşümün ölçüsü')}>
          <span className={`s${olcu === 'adet' ? ' on' : ''}`}
                onClick={() => setOlcu?.('adet')}>Adet</span>
          <span className={`s${olcu === 'tutar' ? ' on' : ''}`}
                onClick={() => setOlcu?.('tutar')}>Tutar</span>
        </span>
      )}
      {/* Secili satir islemleri donusum dugmesinin SAGINDA (kullanici):
          yalniz ikon, secim yoksa pasif. Duzenleme TEK satirda calisir. */}
      {!hizliYok && (<>
      <button type="button" className="d bir" disabled={!tekSecili}
              title={!secili.length ? 'Önce satır seçin'
                     : secili.length > 1 ? 'Düzenleme için tek satır seçin'
                     : 'Seçili belgenin kartını aç'}
              onClick={() => tekSecili && donusumAc?.(tekSecili)}>✎</button>
      <button type="button" className="d bir teh" disabled={!secili.length || eKilitli}
              title={eKilitli ? 'e-Fatura hazırlanmış / gönderilmiş fatura silinemez'
                     : secili.length ? 'Seçili belgeleri sil' : 'Önce satır seçin'}
              onClick={() => { void donusumSil?.(secili).then(() => setSecili([])) }}>🗑</button>
      </>)}
      {/* e-FATURA (kullanici 11.10.2026: "bu sekmedeyken hastanın faturasını
          gönderebileyim.. e-Fatura butonu olacak"): secili TEK fatura icin
          Delphi e-Fatura menusu. Fiş / tahakkuk e-Fatura degildir. */}
      {kayitliId > 0 && !teklifMi && !hizliYok && (
        <EFaturaMenusu belgeId={tekFatura} devre={!tekFatura}
                       devreSebep={faturalar.length === 0 ? 'Bu başvurudan henüz fatura kesilmemiş; önce "Fatura" ile fatura oluşturun.'
                                   : secili.length > 1 ? 'e-Fatura için listeden tek bir fatura seçin.'
                                   : secili.length === 1 ? 'Seçili belge fatura değil (fiş / tahakkuk e-Fatura olmaz).'
                                   : 'Listeden e-Fatura işlemi yapılacak faturayı seçin.'}
                       onDegisti={donusumYenile} />
      )}
      {secili.length > 1 && (
        <span className="kapt">{secili.length} belge seçili</span>
      )}
    </h6>
    <table className="detay-tablo">
      <thead>
        <tr>
          {!hizliYok && (
          <th className="check">
            <input type="checkbox" checked={hepsi} disabled={!idler.length}
                   title={c('Tümünü seç')}
                   onChange={() => setSecili(hepsi ? [] : idler)} />
          </th>)}
          <th style={{ width: 160 }}>Belge No</th>
          <th style={{ width: 130 }}>Tarih</th>
          <th>Tür</th>
          <th className="hiza-sag" style={{ width: 100 }}>Miktar</th>
          <th className="hiza-sag" style={{ width: 130 }}>Tutar</th>
          {/* KOLONLAR (kullanici 11.10.2026): e-Belge turu, e-Belge durumu,
              belge Durum'u en sonda. */}
          <th style={{ width: 90 }}>e-Belge</th>
          <th style={{ width: 130 }}>e-Belge Durum</th>
          <th style={{ width: 80 }}>Durum</th>
        </tr>
      </thead>
      <tbody>
        {donusumler.map((d, i) => {
          const bid = Number(d.belgeId ?? 0);
          return (
          <tr key={i} className={bid && secili.includes(bid) ? 'secili' : ''}
              /* Shift+tik metin secmesin - aralik secimi okunmaz oluyordu. */
              style={{ userSelect: 'none' }}
              onClick={e => { if (!hizliYok) satirTikla(e, i, bid) }}
              onDoubleClick={() => { if (!bid) return; if (hizliYok) sekmedeAc?.(bid, Number(d.tur ?? 0)); else donusumAc?.(bid) }}>
            {!hizliYok && (
            <td className="check" onClick={e => e.stopPropagation()}>
              <input type="checkbox" checked={!!bid && secili.includes(bid)}
                     disabled={!bid}
                     onChange={() => { if (bid) { capa.current = i; cevir(bid) } }} />
            </td>)}
            {/* "0" OLDUĞU GİBİ (kullanıcı 07.11.2026): e-Belge bekleyen faturanın numarası henüz yok - Delphi gibi 0 yazılır,
                "—" yerine (— "kayıt yok" sanılıyordu). */}
            <td><b>{String(d.belgeNo ?? '').trim() === '0' ? '0' : (gorunenBelgeNo(d.belgeNo) || '—')}</b></td>
            {/* SAAT DE (kullanıcı 07.11.2026): fiş / fatura kesim anı. */}
            <td>{tarihSaat(d.belgeTarihi)}</td>
            <td>{hizliYok && bid
              ? <a href={`/belge/${bid}`} title={c('Belgeyi kendi sekmesinde aç')}
                   onClick={e => { e.preventDefault(); e.stopPropagation(); sekmedeAc?.(bid, Number(d.tur ?? 0)) }}>{String(d.turAdi ?? '')}</a>
              : String(d.turAdi ?? '')}</td>
            <td className="hiza-sag">{Number(d.miktar ?? 0).toLocaleString('tr-TR')}</td>
            <td className="hiza-sag">{para.format(Number(d.tutar ?? 0))}</td>
            <td>{eBelgeTuru(Number(d.efaturaDurum ?? 0), Number(d.tur ?? 0))}</td>
            <td>{eBelgeDurumu(Number(d.efaturaDurum ?? 0), Number(d.efaturaSonuc ?? 0), Number(d.tur ?? 0))}</td>
            <td>{durumRozeti(String(d.durumAdi ?? ''))}</td>
          </tr>
          );
        })}
        {donusumler.length === 0 && (
          <tr><td colSpan={9} className="bos">
            {kayitliId > 0 ? 'Bu belgeden henüz belge türetilmemiş.' : 'Önce belgeyi kaydedin.'}
          </td></tr>
        )}
      </tbody>
    </table>
  </div>
  );
}

/** Belgeye Dönüşüm: e-Belge türü (fatura dışı belgede boş; hazırlanmamışta "—"). */
function eBelgeTuru(durum: number, tur: number) {
  if (tur !== 15) return null;
  if (durum === 11 || durum === 12) return <span className="rozet bilgi">e-Arşiv</span>;
  if (durum === 1 || durum === 2) return <span className="rozet bilgi">e-Fatura</span>;
  return <span className="rozet gri">—</span>;
}

/** Belgeye Dönüşüm: belge durumu rozeti (kullanıcı 11.10.2026: "ebelge ve durum rozet olsun"). */
function durumRozeti(ad: string) {
  if (!ad) return null;
  const sinif = ad === 'Kesin' ? 'ok' : ad === 'İptal' ? 'hata' : ad === 'Taslak' ? 'uyari' : 'gri';
  return <span className={'rozet ' + sinif}>{ad}</span>;
}

/** Belgeye Dönüşüm: e-Belge durumu rozeti. */
function eBelgeDurumu(durum: number, sonuc: number, tur: number) {
  if (tur !== 15) return null;
  if (durum === 2 || durum === 12) return <span className="rozet ok">Gönderildi</span>;
  if (durum === 1 || durum === 11)
    return sonuc === 3 ? <span className="rozet hata">Gönderim hatası</span>
                       : <span className="rozet uyari">Hazır</span>;
  return <span className="rozet gri">Taslak</span>;
}
