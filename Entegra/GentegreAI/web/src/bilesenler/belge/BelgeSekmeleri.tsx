import { useRef, useState } from 'react';
import { TarafSecici } from '../TarafArama';
import { TESLIM_SEKLI, SENARYO_SECENEK, eBelgeTipi } from '../../sayfalar/belgeSabitleri';
import type { BelgeYaniti } from '../../api/sozlesme';
import { para } from '../bicim';

/**
 * BELGE KARTI SEKMELERI - Tasiyici / e-Belge / Faturalama.
 *
 * Uc sekme de yalniz baslik alanlarini gosterir; kalem, tahsilat ve yorum
 * sekmeleri kartin kendi durumuna daha sikca bagli oldugu icin kartta kaldi.
 */

export function TasiyiciSekmesi({
  kilitli, tasiyici, setTasiyici, teslimEden, setTeslimEden,
  aracPlaka, setAracPlaka, soforAd, setSoforAd, soforTckn, setSoforTckn,
  sevkTarihi, setSevkTarihi, teslimSekli, setTeslimSekli, belge,
}: {
  kilitli: boolean;
  tasiyici: { id: number; ad: string } | null;
  setTasiyici(v: { id: number; ad: string } | null): void;
  teslimEden: { id: number; ad: string } | null;
  setTeslimEden(v: { id: number; ad: string } | null): void;
  aracPlaka: string; setAracPlaka(v: string): void;
  soforAd: string; setSoforAd(v: string): void;
  soforTckn: string; setSoforTckn(v: string): void;
  sevkTarihi: string; setSevkTarihi(v: string): void;
  teslimSekli: number; setTeslimSekli(v: number): void;
  /** Kayitli belge - sevk adresi ve e-Belge durum alanlari buradan okunur. */
  belge?: BelgeYaniti['belge'];
}) {
  return (
  <div className="kagrup">
    <h6>Taşıyıcı Bilgileri</h6>
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
        <span className="etiket">Teslim Şekli</span>
        <select value={teslimSekli} disabled={kilitli}
                onChange={e => setTeslimSekli(Number(e.target.value))}>
          {TESLIM_SEKLI.map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
        </select>
      </label>
      <label className="alan genis-2">
        <span className="etiket">Sevk Adresi</span>
        <input value={[belge?.tarafAdres, belge?.tarafIlce, belge?.tarafIl]
                        .filter(Boolean).join(' / ')} readOnly
               placeholder="Cari seçilince kartındaki varsayılan adres gelir" />
      </label>
      <label className="alan">
        <span className="etiket">Sevk Zamanı</span>
        <input type="datetime-local" value={sevkTarihi} disabled={kilitli}
               onChange={e => setSevkTarihi(e.target.value)} />
      </label>
      <label className="alan">
        <span className="etiket">Araç Plakası</span>
        <input value={aracPlaka} maxLength={20} disabled={kilitli}
               placeholder="07 ABC 145"
               onChange={e => setAracPlaka(e.target.value.toUpperCase())} />
      </label>
      <label className="alan">
        <span className="etiket">Şoför Adı</span>
        <input value={soforAd} maxLength={60} disabled={kilitli}
               onChange={e => setSoforAd(e.target.value)} />
      </label>
      <label className="alan">
        <span className="etiket">Şoför TC</span>
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
  kilitli, irsaliyeMi, tur, senaryo, setSenaryo, belge,
}: {
  kilitli: boolean;
  irsaliyeMi: boolean;
  tur: number;
  senaryo: number; setSenaryo(v: number): void;
  belge?: BelgeYaniti['belge'];
}) {
  return (
  <div className="kagrup">
    {/* Alan sirasi Ekranlar/satis_faturasi.html "e-Belge" sekmesiyle AYNI:
        Belge Tipi · Alias (URN) · Senaryo · Durum · ETTN/Zarf No · XSLT.
        Adres mockup'ta yok, kullanici istegiyle burada duruyor. */}
    <h6>
      {irsaliyeMi ? 'e-İrsaliye' : 'e-Fatura / e-Arşiv'}
      <span className="kapt">belge.efatura* · e_belge</span>
    </h6>
    {/* Mockup'ta (.grid2) her alan KENDI SATIRINDA: etiket solda, deger
        sagda. Uc sutuna yayilinca sira okunmuyordu. */}
    <div className="alan-izgara tek-sutun">
      <label className="alan">
        <span className="etiket">Belge Tipi</span>
        <input value={eBelgeTipi(tur, senaryo)} readOnly />
      </label>
      <label className="alan">
        <span className="etiket">Alias (URN)</span>
        <input value={String(belge?.gondericiAlias ?? '') || '—'} readOnly />
      </label>

      <label className="alan">
        <span className="etiket">Senaryo</span>
        <select value={senaryo} disabled={kilitli}
                onChange={e => setSenaryo(Number(e.target.value))}>
          {SENARYO_SECENEK.map(o => (
            <option key={o.deger} value={o.deger}>{o.ad}</option>
          ))}
        </select>
      </label>
      <label className="alan">
        <span className="etiket">Durum</span>
        <span className="deger-serit">
          {Number(belge?.efaturaDurum ?? 0) > 0
            ? <span className="rozet ok">Gönderildi</span>
            : <span className="rozet gri">Kâğıt / gönderilmedi</span>}
          {belge?.gibDurumAciklama
            ? <span className="sonuk">{String(belge.gibDurumAciklama)}</span>
            : null}
        </span>
      </label>

      <label className="alan">
        <span className="etiket">ETTN / Zarf No</span>
        <input readOnly value={
          [String(belge?.ettn ?? ''), String(belge?.zarfId ?? 0) !== '0'
            ? String(belge?.zarfId) : '']
            .filter(Boolean).join(' / ') || '—'} />
      </label>
      <label className="alan">
        <span className="etiket">XSLT Tasarımı</span>
        {/* Tasarim listesi (DOKUMLER) henuz baglanmadi - combo GORUNUR
            ama tek secenekli ve pasif; sahte secenek uretmiyoruz. */}
        <select disabled title="Tasarım listesi henüz bağlanmadı">
          <option>Genel Fatura Tasarımı</option>
        </select>
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

    {/* Mockup'taki dugme seridi. Gonderim/sorgulama UCLARI HENUZ YOK -
        dugmeler gorunur ama pasif (yalanci calisma yerine durust durum). */}
    <div className="katoolbar" style={{ margin: 10 }}>
      <button className="d" disabled title="Gönderim ucu henüz bağlanmadı">📤 Yeniden Gönder</button>
      <button className="d" disabled title="Önizleme henüz bağlanmadı">👁 Önizle (PDF)</button>
      <button className="d" disabled title="XML indirme henüz bağlanmadı">⬇ XML İndir</button>
      <button className="d" disabled title="GİB durum sorgulama henüz bağlanmadı">📋 Durum Sorgula</button>
    </div>

    <div className="not">
      ETTN / zarf no ve GİB yanıtı e-Belge kuyruğundan (e_belge) okunur;
      gönderim ucu henüz bağlanmadı. XSLT tasarım seçimi de dokümanlar
      tablosuna bağlanacak.
    </div>
  </div>
  );
}

export function FaturalamaSekmesi({ donusumler, kayitliId, setDonusum, teklifMi,
                                    teklifDurum, donusumAc, donusumSil,
                                    hizliDonustur, olcu = 'adet', setOlcu }: {
  donusumler: Record<string, unknown>[];
  kayitliId: number;
  /** Donusum modalini acar; 0 = hedefi modal secsin (ilk hedef). */
  setDonusum(v: number | null): void;
  /** Teklifte sekme "Sipariş"tir ve tek hedef siparis (216). */
  teklifMi?: boolean;
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
  hizliDonustur?(hedefTur: number): void;
  /** Donusum olcusu: 'adet' kalan MIKTAR, 'tutar' tahsil edilen/kalan TUTAR. */
  olcu?: 'adet' | 'tutar';
  setOlcu?(v: 'adet' | 'tutar'): void;
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
  <div className="kagrup">
    <h6>
      {/* Baslik degil ETIKET (kullanici): saginda duran Fiş / Fatura /
          Tahakkuk dugmelerini niteler - "hangi belgeyi keseyim". */}
      {teklifMi ? 'Sipariş' : 'Belge seç :'}

      {/* HIZLI DONUSUM (kullanici): modal ACMADAN hedef belgeyi uretir ve
          alttaki listeye ekler - tahsilat sekmesindeki hizli akisin aynisi.
          Ayrintili secim (satir/tutar/kismi) yine "Faturaya Dönüştür"de. */}
      {kayitliId > 0 && !teklifMi && (
        <>
          <button type="button" className="d bir" disabled={donusumKapali}
                  title={`Tüm açık satırları ${olcu === 'adet' ? 'kalan miktarla' : 'tahsil edilen tutarla'} satış FİŞİNE çevirir`}
                  onClick={() => hizliDonustur?.(16)}>🧾 Fiş</button>
          <button type="button" className="d bir" disabled={donusumKapali}
                  title={`Tüm açık satırları ${olcu === 'adet' ? 'kalan miktarla' : 'tahsil edilen tutarla'} FATURAYA çevirir`}
                  onClick={() => hizliDonustur?.(15)}>📄 Fatura</button>
          <button type="button" className="d bir" disabled={donusumKapali}
                  title="Tüm açık satırları TAHAKKUKA çevirir (kalanın tamamı)"
                  onClick={() => hizliDonustur?.(17)}>📑 Tahakkuk</button>
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
                onClick={() => setDonusum(0)}>
          📋 Siparişe Dönüştür
        </button>
      )}

      {/* DONUSUM OLCUSU (kullanici): varsayilan ADET - satirin kalan miktari
          cevrilir. TUTAR olcusunde fis/faturada TAHSIL EDILEN kadar,
          tahakkukta kalanin tamami cevrilir (352). */}
      {kayitliId > 0 && !teklifMi && (
        <span className="seg olcu" title="Hızlı dönüşümün ölçüsü">
          <span className={`s${olcu === 'adet' ? ' on' : ''}`}
                onClick={() => setOlcu?.('adet')}>Adet</span>
          <span className={`s${olcu === 'tutar' ? ' on' : ''}`}
                onClick={() => setOlcu?.('tutar')}>Tutar</span>
        </span>
      )}
      {/* Secili satir islemleri donusum dugmesinin SAGINDA (kullanici):
          yalniz ikon, secim yoksa pasif. Duzenleme TEK satirda calisir. */}
      <button type="button" className="d bir" disabled={!tekSecili}
              title={!secili.length ? 'Önce satır seçin'
                     : secili.length > 1 ? 'Düzenleme için tek satır seçin'
                     : 'Seçili belgenin kartını aç'}
              onClick={() => tekSecili && donusumAc?.(tekSecili)}>✎</button>
      <button type="button" className="d bir teh" disabled={!secili.length}
              title={secili.length ? 'Seçili belgeleri sil' : 'Önce satır seçin'}
              onClick={() => { void donusumSil?.(secili).then(() => setSecili([])) }}>🗑</button>
      {secili.length > 1 && (
        <span className="kapt">{secili.length} belge seçili</span>
      )}
    </h6>
    <table className="detay-tablo">
      <thead>
        <tr>
          <th className="check">
            <input type="checkbox" checked={hepsi} disabled={!idler.length}
                   title="Tümünü seç"
                   onChange={() => setSecili(hepsi ? [] : idler)} />
          </th>
          <th style={{ width: 160 }}>Belge No</th>
          <th style={{ width: 100 }}>Tarih</th>
          <th>Tür</th>
          <th className="hiza-sag" style={{ width: 100 }}>Miktar</th>
          <th className="hiza-sag" style={{ width: 130 }}>Tutar</th>
          <th style={{ width: 90 }}>Durum</th>
        </tr>
      </thead>
      <tbody>
        {donusumler.map((d, i) => {
          const bid = Number(d.belgeId ?? 0);
          return (
          <tr key={i} className={bid && secili.includes(bid) ? 'secili' : ''}
              /* Shift+tik metin secmesin - aralik secimi okunmaz oluyordu. */
              style={{ userSelect: 'none' }}
              onClick={e => satirTikla(e, i, bid)}
              onDoubleClick={() => bid && donusumAc?.(bid)}>
            <td className="check" onClick={e => e.stopPropagation()}>
              <input type="checkbox" checked={!!bid && secili.includes(bid)}
                     disabled={!bid}
                     onChange={() => { if (bid) { capa.current = i; cevir(bid) } }} />
            </td>
            <td><b>{String(d.belgeNo ?? '')}</b></td>
            <td>{String(d.belgeTarihi ?? '').slice(0, 10).split('-').reverse().join('.')}</td>
            <td>{String(d.turAdi ?? '')}</td>
            <td className="hiza-sag">{Number(d.miktar ?? 0).toLocaleString('tr-TR')}</td>
            <td className="hiza-sag">{para.format(Number(d.tutar ?? 0))}</td>
            <td>{String(d.durumAdi ?? '')}</td>
          </tr>
          );
        })}
        {donusumler.length === 0 && (
          <tr><td colSpan={7} className="bos">
            {kayitliId > 0 ? 'Bu belgeden henüz belge türetilmemiş.' : 'Önce belgeyi kaydedin.'}
          </td></tr>
        )}
      </tbody>
    </table>
  </div>
  );
}
