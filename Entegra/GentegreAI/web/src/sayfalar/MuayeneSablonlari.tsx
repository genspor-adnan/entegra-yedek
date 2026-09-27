import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { ListeSatiri } from '../api/sozlesme';

/**
 * MUAYENE ŞABLONLARI & HEKİM TERCİHLERİ (mockup Ekranlar/Muayene/
 * muayene_sablonlari.html). Altı sekme:
 *  1) Fizik Muayene Şablonları — sol şablon listesi + sağ seçili şablonun alan
 *     tablosu (gerçek: muayene-sablon + kartOku alanlar).
 *  2) Sık Tanılar — sunucu kaynağı henüz yok (bilgi paneli).
 *  3) Reçete Şablonları — sunucu kaynağı henüz yok (bilgi paneli).
 *  4) İstem Panelleri — gerçek: lab-panel.
 *  5) Metin Makroları — gerçek: metin-makro.
 *  6) Kurallar — statik yapılandırma özeti (mockup).
 */
const SEKMELER = ['Fizik Muayene Şablonları', 'Sık Tanılar', 'Reçete Şablonları',
                  'İstem Panelleri', 'Metin Makroları', 'Kurallar'];

const TIP: Record<string, string> = {
  '1': 'metin', '2': 'metin + normal', '3': 'sayı', '4': 'seçenekli',
  '5': 'çoklu seçim', '6': 'tarih', '7': 'vücut şeması', '8': 'skor', '9': 'alt şablon',
};
const m = (v: unknown) => String(v ?? '').trim();
const bayrak = (v: unknown) => Number(v ?? 0) === 1;

export function MuayeneSablonlari() {
  const [sekme, setSekme] = useState(0);
  const [sablonlar, setSablonlar] = useState<ListeSatiri[]>([]);
  const [seciliId, setSeciliId] = useState<number | null>(null);
  const [alanlar, setAlanlar] = useState<Record<string, unknown>[]>([]);
  const [paneller, setPaneller] = useState<ListeSatiri[]>([]);
  const [makrolar, setMakrolar] = useState<ListeSatiri[]>([]);

  useEffect(() => {
    void (async () => {
      try {
        const y = await api.liste('muayene-sablon', { sayfa: 1, boyut: 200 });
        setSablonlar(y.satirlar);
        if (y.satirlar[0]) setSeciliId(Number(y.satirlar[0].id));
      } catch { /* boş kalır */ }
    })();
  }, []);

  useEffect(() => {
    if (seciliId == null) { setAlanlar([]); return }
    let iptal = false;
    void (async () => {
      try {
        const k = await api.kartOku('muayene-sablon', seciliId);
        if (!iptal) setAlanlar((k.detaylar?.alanlar ?? []) as Record<string, unknown>[]);
      } catch { if (!iptal) setAlanlar([]) }
    })();
    return () => { iptal = true };
  }, [seciliId]);

  useEffect(() => {
    if (sekme === 3 && paneller.length === 0)
      void api.liste('lab-panel', { sayfa: 1, boyut: 200 }).then(y => setPaneller(y.satirlar)).catch(() => {});
    if (sekme === 4 && makrolar.length === 0)
      void api.liste('metin-makro', { sayfa: 1, boyut: 200 }).then(y => setMakrolar(y.satirlar)).catch(() => {});
  }, [sekme, paneller.length, makrolar.length]);

  const kapsam = (r: ListeSatiri) =>
    m(r.hekimAdi) ? 'Kişisel' : m(r.bolumAdi) ? 'Branş' : 'Kurum';

  return (
    <div className="msb-win">
      <div className="msb-title">📋 Muayene Şablonları &amp; Hekim Tercihleri
        <span className="msb-sp">branş şablonları · sık tanı · reçete/rapor şablonları · makrolar</span></div>

      <div className="msb-sekmeler">
        {SEKMELER.map((s, i) => (
          <button key={s} type="button" className={`msb-sekme${sekme === i ? ' on' : ''}`}
            onClick={() => setSekme(i)}>{s}</button>
        ))}
      </div>

      {/* 1) FİZİK MUAYENE ŞABLONLARI — iki panel */}
      {sekme === 0 && (
        <div className="msb-iki">
          <div className="msb-sol">
            <div className="msb-arac">Şablonlar <span className="msb-not">{sablonlar.length}</span></div>
            <table className="msb-dg"><thead><tr>
              <th>Şablon</th><th>Branş</th><th className="orta">Kapsam</th><th className="orta">Durum</th>
            </tr></thead><tbody>
              {sablonlar.map(r => {
                const id = Number(r.id);
                return (
                  <tr key={id} className={seciliId === id ? 'sel' : ''}
                    style={{ cursor: 'pointer' }} onClick={() => setSeciliId(id)}>
                    <td>{m(r.ad)}</td>
                    <td>{m(r.bolumAdi) || m(r.branch) || 'Tümü'}</td>
                    <td className="orta">{kapsam(r)}</td>
                    <td className="orta"><span className={`msb-rz ${bayrak(r.durum) ? 'ok' : 'pas'}`}>
                      {bayrak(r.durum) ? 'Aktif' : 'Pasif'}</span></td>
                  </tr>
                );
              })}
              {sablonlar.length === 0 && <tr><td colSpan={4} className="msb-bos">Şablon yok.</td></tr>}
            </tbody></table>
          </div>
          <div className="msb-sag">
            <div className="msb-arac">Alanlar <span className="msb-not">{alanlar.length}</span></div>
            <table className="msb-dg"><thead><tr>
              <th className="orta">Sıra</th><th>Alan</th><th>Tip</th>
              <th>Birim</th><th className="orta">Zorunlu</th><th>Normal metni</th>
            </tr></thead><tbody>
              {alanlar.map((a, n) => (
                <tr key={n}>
                  <td className="orta">{m(a.sira)}</td>
                  <td>{m(a.ad)}{m(a.grup) ? <span className="msb-alt"> · {m(a.grup)}</span> : null}</td>
                  <td>{TIP[m(a.tip)] ?? m(a.tip)}</td>
                  <td>{m(a.birim) || '—'}</td>
                  <td className="orta">{bayrak(a.zorunlu) ? '✔' : '—'}</td>
                  <td>{m(a.normalMetni) ? `"${m(a.normalMetni)}"` : '—'}</td>
                </tr>
              ))}
              {alanlar.length === 0 && <tr><td colSpan={6} className="msb-bos">
                {seciliId == null ? 'Soldan şablon seçin.' : 'Bu şablonda alan yok.'}</td></tr>}
            </tbody></table>
            <div className="msb-ic">Alan tipleri: metin, metin+normal, sayı (birim/aralık), seçenekli, çoklu seçim,
              tarih, vücut şeması, skor (BKİ/GRACE/CHA₂DS₂-VASc), alt şablon. Değerler <code>muayene_bulgu</code>'ya
              alan bazlı; raporlama ve USS eşlemesi.</div>
          </div>
        </div>
      )}

      {/* 2) SIK TANILAR — kaynak yok */}
      {sekme === 1 && (
        <div className="msb-bilgi">
          <b>Sık Tanılar (hekim tercihleri)</b> — hekimin/branşın sık kullandığı ICD-10 tanıları,
          varsayılan tür (ana/ek·kronik) ve bağlı reçete/istem şablonuyla. Bu bölümün sunucu kaynağı
          henüz tanımlı değil; hazır olduğunda kullanım sıklığından öneri ile burada listelenecek.
        </div>
      )}

      {/* 3) REÇETE ŞABLONLARI — kaynak yok */}
      {sekme === 2 && (
        <div className="msb-bilgi">
          <b>Reçete Şablonları</b> — sık yazılan ilaç kümeleri (kapsam: kişisel/branş/kurum), bağlı tanı ile.
          Şablon uygulanınca doz/periyot/süre hasta kilo-yaş kurallarıyla, alerji ve etkileşim kontrolüyle
          çalışır. Bu bölümün sunucu kaynağı henüz tanımlı değil.
        </div>
      )}

      {/* 4) İSTEM PANELLERİ — lab-panel */}
      {sekme === 3 && (
        <div className="msb-pnl">
          <div className="msb-arac">İstem Panelleri <span className="msb-not">{paneller.length}</span></div>
          <table className="msb-dg"><thead><tr>
            <th>Kod</th><th>Panel</th><th className="orta">Tetkik</th><th className="orta">Durum</th>
          </tr></thead><tbody>
            {paneller.map(r => (
              <tr key={Number(r.id)}>
                <td>{m(r.kod)}</td><td>{m(r.ad)}</td>
                <td className="orta">{m(r.tetkikSayisi)}</td>
                <td className="orta"><span className={`msb-rz ${Number(r.durum ?? 0) === 1 ? 'pas' : 'ok'}`}>
                  {Number(r.durum ?? 0) === 1 ? 'Pasif' : 'Aktif'}</span></td>
              </tr>
            ))}
            {paneller.length === 0 && <tr><td colSpan={4} className="msb-bos">Panel yok.</td></tr>}
          </tbody></table>
        </div>
      )}

      {/* 5) METİN MAKROLARI — metin-makro */}
      {sekme === 4 && (
        <div className="msb-pnl">
          <div className="msb-arac">Metin Makroları <span className="msb-not">{makrolar.length}</span></div>
          <table className="msb-dg"><thead><tr>
            <th>Kısayol</th><th>Metin</th><th className="orta">Kullanım</th><th className="orta">Durum</th>
          </tr></thead><tbody>
            {makrolar.map(r => (
              <tr key={Number(r.id)}>
                <td>{m(r.kisayol)}</td>
                <td className="msb-metin">{m(r.metin)}</td>
                <td className="orta">{m(r.kullanim)}</td>
                <td className="orta"><span className={`msb-rz ${bayrak(r.durum) ? 'ok' : 'pas'}`}>
                  {bayrak(r.durum) ? 'Aktif' : 'Pasif'}</span></td>
              </tr>
            ))}
            {makrolar.length === 0 && <tr><td colSpan={4} className="msb-bos">Makro yok.</td></tr>}
          </tbody></table>
          <div className="msb-ic">Dikte (ses→metin) çıktısı da makro gibi alana düşer; AI özet taslağı hekim onayıyla.</div>
        </div>
      )}

      {/* 6) KURALLAR — statik */}
      {sekme === 5 && (
        <div className="msb-kural">
          {[
            ['Tamamlama için zorunlu', 'Ana tanı · Şikâyet · En az 1 sistem bulgusu (yüz yüze) · Karar'],
            ['Muayene süresi', 'Başlangıç = "Muayeneye Al" · bitiş = "Tamamla" · USS Başlangıç/Bitiş'],
            ['Tamamlanmış muayene düzenleme', 'Salt okunur + "ek not" (24 saat içinde, gerekçeli)'],
            ['Kronik tanı otomatik', '"Kronik" tanı tıbbi özete düşer; sonraki muayenede ek tanı önerilir'],
            ['Aynı gün aynı branş', 'Uyarı (SUT: 10 gün içinde kontrol ücretsiz)'],
            ['Konsültasyon yanıt süresi', 'Acil 30 dk · rutin 24 s · hatırlatma'],
            ['e-Nabız', 'Tamamla → 103 (ve 106 sevk/çıkışta) otomatik'],
            ['Hasta portalı', 'Muayene özeti + reçete + rapor paylaşılır (hekim notu hariç)'],
          ].map(([k, v]) => (
            <div className="msb-fld" key={k}><label>{k}</label><div className="msb-inp">{v}</div></div>
          ))}
          <div className="msb-ic" style={{ gridColumn: '1 / -1' }}>
            Kurallar şimdilik bilgilendirme amaçlı gösterilir; yapılandırma kaynağı bağlandığında düzenlenebilir olacak.
          </div>
        </div>
      )}
    </div>
  );
}
