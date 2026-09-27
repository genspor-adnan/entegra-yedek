import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { Modal } from './Modal';
import { guvenli, mesaj } from './mesaj';
import { hataMetni } from '../api/sozlesme';

/**
 * MUAYENE ÖZETİ (mockup Ekranlar/Muayene/muayene_ozeti.html). Solda derlenen
 * ÖZET METNİ (düzenlenebilir; rapora/e-Nabız'a giden), sağda metni besleyen
 * kaynaklar: tanılar, istem/sonuç, reçete, rapor. "Yeniden Derle" bulgulardan
 * metni tazeler (muayeneOzetDerle); hekim düzeltip kaydeder.
 */
type Satir = Record<string, unknown>;
const m = (v: unknown) => String(v ?? '').trim();

const ISTEM_DURUM: Record<number, string> = {
  1: 'İstendi', 2: 'Numune alındı', 3: 'Çalışılıyor', 4: 'Sonuçlandı', 5: 'Onaylandı', 9: 'İptal',
};
const RAPOR_TUR: Record<number, string> = { 1: 'İstirahat', 2: 'Sağlık durumu', 3: 'İlaç kullanım', 4: 'İş göremezlik' };

export function MuayeneOzetiModal({ muayeneId, onKapat }: { muayeneId: number; onKapat(): void }) {
  const [ozet, setOzet] = useState('');
  const [tanilar, setTanilar] = useState('');
  const [istemler, setIstemler] = useState<Satir[]>([]);
  const [radyoloji, setRadyoloji] = useState<Satir[]>([]);
  const [receteSatir, setReceteSatir] = useState<Satir[]>([]);
  const [raporlar, setRaporlar] = useState<Satir[]>([]);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [mesgul, setMesgul] = useState(false);

  useEffect(() => {
    let iptal = false;
    void (async () => {
      setYukleniyor(true);
      try {
        const [derle, sonuc, sekme, rapor] = await Promise.all([
          api.muayeneOzetDerle(muayeneId).catch(() => ({ bulguOzet: '' })),
          api.muayeneSonuclari(muayeneId).catch(() => null),
          api.muayeneSekmeVerisi(muayeneId).catch(() => null) as Promise<any>,
          api.muayeneRaporlari(muayeneId).catch(() => ({ raporlar: [] })),
        ]);
        if (iptal) return;
        setOzet(derle.bulguOzet ?? '');
        setIstemler((sonuc?.istemler ?? []) as Satir[]);
        setRadyoloji((sonuc?.radyoloji ?? []) as Satir[]);
        setTanilar(m(sekme?.tanilar));
        setReceteSatir((sekme?.receteSatirlari ?? []) as Satir[]);
        setRaporlar((rapor.raporlar ?? []) as Satir[]);
      } catch (h) { if (!iptal) mesaj(hataMetni(h)) }
      if (!iptal) setYukleniyor(false);
    })();
    return () => { iptal = true };
  }, [muayeneId]);

  const yenidenDerle = () => guvenli(async () => {
    const y = await api.muayeneOzetDerle(muayeneId);
    setOzet(y.bulguOzet ?? '');
    mesaj('Özet bulgulardan yeniden derlendi.');
  });
  const kopyala = () => guvenli(async () => {
    await navigator.clipboard.writeText(ozet);
    mesaj('Özet panoya kopyalandı.');
  });
  const kaydet = async () => {
    setMesgul(true);
    await guvenli(async () => {
      await api.kartGuncelle('muayene', muayeneId, { kart: { bulguOzet: ozet } });
      mesaj('Özet kaydedildi.');
    });
    setMesgul(false);
  };

  const blok = (baslik: string, ic: React.ReactNode) => (
    <div className="ozet-blk"><h6>{baslik}</h6>{ic}</div>
  );

  return (
    <Modal baslik="📖 Muayene Özeti" onKapat={onKapat}
      alt={<>
        <button className="d bir" onClick={() => void yenidenDerle()}>🔄 Yeniden Derle</button>
        <button className="d" onClick={() => void kopyala()}>📋 Kopyala</button>
        <button className="d onay" disabled={mesgul} onClick={() => void kaydet()}>💾 Kaydet</button>
        <button className="d" onClick={onKapat}>Kapat</button>
      </>}>
      {yukleniyor ? <div style={{ padding: 16, color: '#889' }}>Yükleniyor…</div> : (
      <div className="ozet-gvd">
        {/* SOL: derlenen özet metni (düzenlenebilir) */}
        <div className="ozet-sol">
          <h6>Muayene Özeti <span className="not">bulgulardan derlendi · düzenlenebilir</span></h6>
          <textarea className="ozet-metin" value={ozet} onChange={e => setOzet(e.target.value)}
            placeholder="Şablon, bulgular, tanı ve istem/sonuçlardan derlenen özet…" />
          <div className="not ic">Rapora ve e-Nabız paketine (USS 106) giden özet budur; elle düzeltilebilir.</div>
        </div>

        {/* SAĞ: besleyen kaynaklar */}
        <div className="ozet-sag">
          {blok('Tanılar (ICD-10)', tanilar
            ? <p style={{ margin: 0 }}>{tanilar}</p>
            : <p className="not" style={{ margin: 0 }}>Tanı girilmemiş.</p>)}

          {blok('İstemler & Sonuçlar', (istemler.length + radyoloji.length) === 0
            ? <p className="not" style={{ margin: 0 }}>İstem yok.</p>
            : <table className="ozet-mini">
                <tbody>
                  {istemler.map((i, n) => (
                    <tr key={`l${n}`}><td>🧪 {m(i.istemNo) || 'Lab'}</td>
                      <td className="sag">{ISTEM_DURUM[Number(i.durum ?? 1)] ?? ''}</td></tr>
                  ))}
                  {radyoloji.map((r, n) => (
                    <tr key={`r${n}`}><td>📷 {m(r.tetkik)}</td>
                      <td className="sag">{r.onayTarihi ? 'raporlandı' : r.cekimTarihi ? 'çekildi' : 'sırada'}</td></tr>
                  ))}
                </tbody>
              </table>)}

          {blok('Reçete', receteSatir.length === 0
            ? <p className="not" style={{ margin: 0 }}>Reçete yok.</p>
            : <table className="ozet-mini">
                <tbody>
                  {receteSatir.slice(0, 12).map((r, n) => (
                    <tr key={n}><td>{m(r.ilacAd) || m(r.ad)}</td>
                      <td className="sag">{m(r.kullanim) || m(r.doz)}</td></tr>
                  ))}
                </tbody>
              </table>)}

          {blok('Rapor', raporlar.length === 0
            ? <p className="not" style={{ margin: 0 }}>Rapor yok.</p>
            : <table className="ozet-mini">
                <tbody>
                  {raporlar.map((r, n) => (
                    <tr key={n}>
                      <td>{RAPOR_TUR[Number(r.tur ?? 0)] ?? 'Rapor'}
                        {Number(r.gun ?? 0) > 0 ? ` · ${m(r.gun)} gün` : ''}</td>
                      <td className="sag">{Number(r.durum ?? 1) === 2 ? 'onaylı'
                        : Number(r.durum ?? 1) === 1 ? 'taslak' : ''}</td></tr>
                  ))}
                </tbody>
              </table>)}
        </div>
      </div>)}
    </Modal>
  );
}
