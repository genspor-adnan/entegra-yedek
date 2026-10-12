import { useEffect, useState, type CSSProperties } from 'react';
import { api } from '../../api/istemci';
import type { KysPolitika } from '../../api/uclar/kysPolitika';
import { guvenli } from '../../bilesenler/mesaj';

/**
 * POLİTİKA & KAPSAM ŞERİDİ (1059, mockup Ekranlar/Kalite2/hedefler.html
 * "Politika & Kapsam") - Politika & Hedefler listesinin üstünde.
 *
 * ISO 9001 4.3 / 5.2: politika ve kapsam AYRI EKRAN değil, hedeflerle aynı
 * sayfada tek metin (KOBİ sade set). Kapalı başlar - günlük iş hedef
 * tablosu; metin yılda bir değişir. Düzenleme kys.gosterge değiştir ister
 * (sunucu `duzenle` ile söyler, istemci kural yazmaz).
 */
export function KysPolitikaSeridi() {
  const [p, setP] = useState<(KysPolitika & { duzenle: boolean }) | null>(null);
  const [acik, setAcik] = useState(false);
  const [taslak, setTaslak] = useState<KysPolitika | null>(null);

  useEffect(() => {
    // Şerit zorunlu değil: hatası listeyi kesmemeli.
    api.kysPolitika().then(setP).catch(() => { /* sessiz */ });
  }, []);

  if (!p) return null;
  const bos = !p.politika && !p.kapsam;
  const onay = [p.onaylayan, p.tarih].filter(Boolean).join(' · ');

  const kaydet = async () => {
    if (!taslak) return;
    await guvenli(async () => { setP(await api.kysPolitikaYaz(taslak)); setTaslak(null) });
  };

  const kutu: CSSProperties = {
    border: '1px solid var(--cizgi)', borderRadius: 'var(--r)', background: 'var(--yuz)',
    margin: '0 0 8px', fontSize: 12.5,
  };
  const etiket: CSSProperties = { color: 'var(--soluk)', fontSize: 11.5, marginBottom: 2 };
  const metin: CSSProperties = { whiteSpace: 'pre-wrap', color: 'var(--yazi)' };

  return (
    <div style={kutu}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '5px 10px', cursor: 'pointer',
                    background: 'linear-gradient(var(--serit1), var(--serit2))' }}
           onClick={() => setAcik(a => !a)}>
        <b style={{ color: 'var(--yazi2)' }}>{acik ? '▾' : '▸'} 📜 Kalite Politikası & Kapsam</b>
        <span style={{ color: 'var(--soluk)' }}>
          ISO 9001 · 4.3 · 5.2{onay ? ` · Onay: ${onay}` : ''}{bos ? ' · henüz yazılmadı' : ''}
        </span>
        {acik && p.duzenle && !taslak && (
          <button type="button" style={{ marginLeft: 'auto' }}
                  onClick={e => {
                    e.stopPropagation();
                    setTaslak({ politika: p.politika, kapsam: p.kapsam, onaylayan: p.onaylayan, tarih: p.tarih });
                  }}>
            ✎ Düzenle
          </button>
        )}
      </div>
      {acik && (taslak ? (
        <div style={{ padding: 10, display: 'grid', gap: 8 }}>
          <label><div style={etiket}>Kalite politikası</div>
            <textarea rows={4} maxLength={4000} style={{ width: '100%' }} value={taslak.politika}
                      onChange={e => setTaslak({ ...taslak, politika: e.target.value })} /></label>
          <label><div style={etiket}>Kapsam (uygulanmayan maddeler ve gerekçesi)</div>
            <textarea rows={3} maxLength={2000} style={{ width: '100%' }} value={taslak.kapsam}
                      onChange={e => setTaslak({ ...taslak, kapsam: e.target.value })} /></label>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <label><div style={etiket}>Onaylayan</div>
              <input maxLength={120} value={taslak.onaylayan}
                     onChange={e => setTaslak({ ...taslak, onaylayan: e.target.value })} /></label>
            <label><div style={etiket}>Onay / yayın tarihi</div>
              <input maxLength={40} value={taslak.tarih}
                     onChange={e => setTaslak({ ...taslak, tarih: e.target.value })} /></label>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <button type="button" className="birincil" onClick={() => void kaydet()}>💾 Kaydet</button>
            <button type="button" onClick={() => setTaslak(null)}>Vazgeç</button>
          </div>
        </div>
      ) : (
        <div style={{ padding: 10, display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 12 }}>
          <div><div style={etiket}>Kalite politikası</div><div style={metin}>{p.politika || '—'}</div></div>
          <div><div style={etiket}>Kapsam</div><div style={metin}>{p.kapsam || '—'}</div></div>
        </div>
      ))}
    </div>
  );
}
