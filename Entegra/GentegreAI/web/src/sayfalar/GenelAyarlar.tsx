import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type AyarSatiri } from '../api/sozlesme';

const SEKMELER = [
  { anahtar: 'genel', baslik: 'Genel' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/**
 * Genel Ayarlar (Yönetim › Ayarlar › Genel) — firma geneli DAVRANIS ayarlari.
 *
 * Ayarlar `public.referans` tablosunda, sunucuda BEYAZ LISTE ile korunuyor
 * (AyarDeposu): ekran yalnizca tanimli anahtarlari gorur. Kayit ANINDA yapilir
 * (blur / Enter) - tek alanlik bir form icin ayrica "Kaydet" dugmesi koymak
 * kullaniciyi bekletmekten baska ise yaramiyordu.
 */
export function GenelAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  const [ayarlar, setAyarlar] = useState<AyarSatiri[]>([]);
  const [taslak, setTaslak] = useState<Record<string, string>>({});
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      setAyarlar(await api.ayarlar());
      setHata(null);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally { setYukleniyor(false) }
  }, []);

  useEffect(() => { void yukle() }, [yukle]);

  const deger = (anahtar: string) =>
    taslak[anahtar] ?? ayarlar.find(a => a.anahtar === anahtar)?.deger ?? '';

  async function yaz(anahtar: string, yeni: string) {
    const eski = ayarlar.find(a => a.anahtar === anahtar)?.deger ?? '';
    setTaslak(t => { const y = { ...t }; delete y[anahtar]; return y });
    if (yeni.trim() === eski) return;

    try {
      setAyarlar(await api.ayarYaz(anahtar, yeni.trim()));
      setHata(null);
      setBilgi('Ayar kaydedildi.');
      setTimeout(() => setBilgi(null), 2500);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
      void yukle();
    }
  }

  const geriGun = deger('belge.geri_gun_siniri');

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Genel Ayarlar</h1>
          <span className="yol">Yönetim › Ayarlar › Genel</span>
        </div>
      </div>

      <div className="katab">
        {SEKMELER.map(s => (
          <div key={s.anahtar}
               className={`kat${s.anahtar === aktif ? ' on' : ''}`}
               onClick={() => setAktif(s.anahtar)}>
            {s.baslik}
          </div>
        ))}
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <div className="kagrup">
            <h6>Belge Girişi</h6>
            <div className="alan-izgara tek-sutun ayar-formu">
              <label className="alan">
                <span className="etiket">Belgeler geriye dönük kaç güne kadar girilebilir</span>
                <input className="hiza-sag" value={geriGun} inputMode="numeric"
                       onChange={e => setTaslak(t => ({ ...t, 'belge.geri_gun_siniri': e.target.value }))}
                       onBlur={e => void yaz('belge.geri_gun_siniri', e.target.value)}
                       onKeyDown={e => { if (e.key === 'Enter') (e.target as HTMLInputElement).blur() }} />
              </label>
            </div>
            <div className="not">
              Belge tarihi bugünden bu kadar gün öncesine kadar seçilebilir; daha
              eskisi kaydedilmez. <b>0</b> yazılırsa geriye dönük sınır kalkar.
              İleri tarihli belge her durumda engellenir (GİB zaten kabul etmez).
              Kural tüm belge türlerinde geçerlidir ve sunucuda uygulanır.
            </div>
          </div>
        )}
      </div>
    </>
  );
}
