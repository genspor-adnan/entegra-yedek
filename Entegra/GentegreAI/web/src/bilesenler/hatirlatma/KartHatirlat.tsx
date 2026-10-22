import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { Hatirlatma } from '../../api/uclar/hatirlatma';
import { guvenli } from '../mesaj';
import { yerelAnMetni } from '../bicim';
import { HATIRLATMA_DEGISTI_OLAYI, hatirlatmaDegisti, hatirlatmaPenceresiAc, hizliZamanlar, kisaZaman } from './hatirlatmaDeposu';

/**
 * KAYITTAN HIZLI HATIRLATMA (mockup kisisel_hatirlatici.html (4)): her kartın araç çubuğunda
 * "⏰ Hatırlat" - küçük pencere: başlık + hızlı zaman + Kaydet / Ayrıntılı…. Yanındaki "⏰ N" rozeti bu
 * kayda bağlı AÇIK hatırlatmalarım (yalnız bana); tıklayınca listesi.
 * Bağlı kayıt = kartın rotası (ör. "cari") + id + görünen ad; "Kaydı aç" aynı rotaya döner.
 */
export function KartHatirlat({ kaynak, id, ad }: { kaynak: string; id: number; ad: string }) {
  const [acik, setAcik] = useState(false);
  const [liste, setListe] = useState(false);
  const [baslik, setBaslik] = useState('');
  const [secim, setSecim] = useState(1);
  const [bagli, setBagli] = useState<Hatirlatma[]>([]);
  const zamanlar = hizliZamanlar().slice(0, 4);

  useEffect(() => {
    let iptal = false;
    // Rozet zorunlu değil: uç yoksa / hata verirse kart etkilenmez (birim testlerinde api kısmi taklittir).
    const yukle = () => Promise.resolve().then(() => api.hatirlatmaKayit(kaynak, id))
      .then(y => { if (!iptal && Array.isArray(y)) setBagli(y) }, () => {});
    void yukle();
    window.addEventListener(HATIRLATMA_DEGISTI_OLAYI, yukle);
    return () => { iptal = true; window.removeEventListener(HATIRLATMA_DEGISTI_OLAYI, yukle) };
  }, [kaynak, id]);
  useEffect(() => {
    if (!acik && !liste) return;
    const kapat = () => { setAcik(false); setListe(false) };
    window.addEventListener('click', kapat);
    return () => window.removeEventListener('click', kapat);
  }, [acik, liste]);

  const kaydet = () => void guvenli(async () => {
    await api.hatirlatmaEkle({
      baslik: baslik.trim() || ad, notu: '', zaman: yerelAnMetni(zamanlar[secim]?.zaman ?? zamanlar[0].zaman),
      uyarDk: 0, oncelik: 2, renk: 0, etiket: '', tekrar: 0, tekrarAralik: 1, tekrarGunler: 0, tekrarBitis: null,
      kanalUygulama: true, kanalSms: false, kanalEposta: false, kaynak, kaynakId: id, kaynakAd: ad,
      paylasim: 0, paylasimDepartmanId: null, herkesKapatir: true, paylasilanDuzenler: false, paylasilanlar: [],
    });
    setAcik(false); setBaslik('');
    hatirlatmaDegisti();
  });

  return (
    <span style={{ position: 'relative', display: 'inline-flex', gap: 4, alignItems: 'center' }} onClick={e => e.stopPropagation()}>
      <button type="button" className="d" title="Bu kayıt için hatırlatma kur" onClick={() => { setListe(false); setAcik(a => !a) }}>⏰ Hatırlat</button>
      {bagli.length > 0 && (
        <button type="button" className="rozet uyari" style={{ cursor: 'pointer', border: 'none' }} title="Bu kayda bağlı açık hatırlatmalarınız"
                onClick={() => { setAcik(false); if (bagli.length === 1) hatirlatmaPenceresiAc({ id: bagli[0].id }); else setListe(l => !l) }}>⏰ {bagli.length}</button>
      )}
      {liste && (
        <div className="hk-menu asagi" style={{ minWidth: 260 }}>
          {bagli.map(h => <button type="button" key={h.id} onClick={() => { setListe(false); hatirlatmaPenceresiAc({ id: h.id }) }}>
            {kisaZaman(new Date(h.zaman))} · {h.baslik}</button>)}
        </div>
      )}
      {acik && (
        <div className="hk-menu asagi" style={{ width: 320, padding: 10, gap: 6, left: 0 }}>
          <b style={{ fontSize: 12 }}>⏰ Hatırlat — {ad}</b>
          <input autoFocus value={baslik} maxLength={200} placeholder={ad} onChange={e => setBaslik(e.target.value)}
                 onKeyDown={e => { if (e.key === 'Enter') kaydet() }} />
          <div className="hk-hizli" style={{ gridTemplateColumns: '1fr 1fr' }}>
            {zamanlar.map((z, i) => <button type="button" key={z.ad} className={i === secim ? 'on' : ''} onClick={() => setSecim(i)}>
              {z.ad}<small>{kisaZaman(z.zaman)}</small></button>)}
          </div>
          <div style={{ display: 'flex', gap: 4, alignItems: 'center' }}>
            <button type="button" className="d bir mini" onClick={kaydet}>Kaydet</button>
            <button type="button" className="d mini" onClick={() => {
              setAcik(false);
              hatirlatmaPenceresiAc({ kaynak, kaynakId: id, kaynakAd: ad, baslik: baslik.trim() || undefined,
                                      zaman: yerelAnMetni(zamanlar[secim]?.zaman ?? zamanlar[0].zaman) });
            }}>Ayrıntılı…</button>
            <span className="hk-soluk" style={{ marginLeft: 'auto', fontSize: 10.5 }}>Enter = kaydet</span>
          </div>
        </div>
      )}
    </span>
  );
}
