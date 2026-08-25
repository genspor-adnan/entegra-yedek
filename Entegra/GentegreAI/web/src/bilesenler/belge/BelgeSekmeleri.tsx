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

export function FaturalamaSekmesi({ donusumler, kayitliId, setDonusum }: {
  donusumler: Record<string, unknown>[];
  kayitliId: number;
  /** Donusum modalini acar; 0 = hedefi modal secsin (ilk hedef). */
  setDonusum(v: number | null): void;
}) {
  return (
  <div className="kagrup">
    <h6>
      Faturalama
      {kayitliId > 0 && (
        <button type="button" className="d bir" onClick={() => setDonusum(0)}>
          🧾 Faturaya Dönüştür
        </button>
      )}
    </h6>
    <table className="detay-tablo">
      <thead>
        <tr>
          <th style={{ width: 160 }}>Belge No</th>
          <th style={{ width: 100 }}>Tarih</th>
          <th>Tür</th>
          <th className="hiza-sag" style={{ width: 100 }}>Miktar</th>
          <th className="hiza-sag" style={{ width: 130 }}>Tutar</th>
          <th style={{ width: 90 }}>Durum</th>
        </tr>
      </thead>
      <tbody>
        {donusumler.map((d, i) => (
          <tr key={i}>
            <td><b>{String(d.belgeNo ?? '')}</b></td>
            <td>{String(d.belgeTarihi ?? '').slice(0, 10).split('-').reverse().join('.')}</td>
            <td>{String(d.turAdi ?? '')}</td>
            <td className="hiza-sag">{Number(d.miktar ?? 0).toLocaleString('tr-TR')}</td>
            <td className="hiza-sag">{para.format(Number(d.tutar ?? 0))}</td>
            <td>{String(d.durumAdi ?? '')}</td>
          </tr>
        ))}
        {donusumler.length === 0 && (
          <tr><td colSpan={6} className="bos">
            {kayitliId > 0 ? 'Bu belgeden henüz belge türetilmemiş.' : 'Önce belgeyi kaydedin.'}
          </td></tr>
        )}
      </tbody>
    </table>
  </div>
  );
}
