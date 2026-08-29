import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { RolKullanicisi } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * Rol kartı "Kullanıcılar" sekmesi (kullanıcı: "rollerin içine kullanıcı
 * ekleyebileyim"). Bir kullanıcı TEK role bağlı olduğu için "ekleme" o
 * kullanıcının rolünü bu role çevirir - eski rolü satırda gösterilir ki
 * kimin nereden alındığı görünsün. "Çıkar" varsayılan sistem rolüne taşır.
 */
export function RolKullanicilari({ rolId, saltOkunur }: {
  rolId: number;
  saltOkunur: boolean;
}) {
  const [uyeler, setUyeler] = useState<RolKullanicisi[] | null>(null);
  const [adaylar, setAdaylar] = useState<RolKullanicisi[]>([]);
  const [arama, setArama] = useState('');
  const [ekleAcik, setEkleAcik] = useState(false);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [islemde, setIslemde] = useState(false);

  const yukle = useCallback(async () => {
    try { setUyeler(await api.rolKullanicilari(rolId)) }
    catch (h) { setHata(hataMetni(h)) }
  }, [rolId]);

  useEffect(() => { void yukle() }, [yukle]);

  // Aday listesi arama yazildikca tazelenir (bos arama = ilk 50).
  useEffect(() => {
    if (!ekleAcik) return;
    let iptal = false;
    const zaman = setTimeout(() => {
      api.rolKullaniciAdaylari(rolId, arama)
        .then(a => { if (!iptal) setAdaylar(a) })
        .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    }, 250);
    return () => { iptal = true; clearTimeout(zaman) };
  }, [ekleAcik, arama, rolId]);

  const ekle = async (k: RolKullanicisi) => {
    setIslemde(true); setHata(''); setBilgi('');
    try {
      setUyeler(await api.rolKullaniciEkle(rolId, k.id));
      setBilgi(`${k.unvan || k.kod} bu role eklendi.`);
      setAdaylar(a => a.filter(x => x.id !== k.id));
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  const cikar = async (k: RolKullanicisi) => {
    setIslemde(true); setHata(''); setBilgi('');
    try {
      const y = await api.rolKullaniciCikar(rolId, k.id);
      setUyeler(y.kullanicilar);
      setBilgi(`${k.unvan || k.kod}: ${y.mesaj}`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  return (
    <div className="kagrup">
      <h6>
        Kullanıcılar {uyeler && <span style={{ opacity: .6 }}>({uyeler.length})</span>}
        {!saltOkunur && (
          <button type="button" className="d bir" disabled={islemde}
                  onClick={() => setEkleAcik(a => !a)}>
            {ekleAcik ? 'Kapat' : '＋ Kullanıcı Ekle'}
          </button>
        )}
      </h6>

      {hata && <div className="alan-hata" style={{ margin: '0 10px' }}>{hata}</div>}
      {bilgi && <div className="bilgi-kutusu" style={{ margin: '0 10px 10px' }}>{bilgi}</div>}

      {ekleAcik && !saltOkunur && (
        <div style={{ margin: '0 10px 10px', padding: 8, border: '1px solid var(--cizgi)',
                      borderRadius: 4 }}>
          <input placeholder="Kullanıcı ara (ad, kod, e-posta)…" value={arama}
                 style={{ width: 300 }} onChange={e => setArama(e.target.value)} />
          <div style={{ maxHeight: 220, overflowY: 'auto', marginTop: 8 }}>
            <table className="detay-tablo">
              <tbody>
                {adaylar.map(k => (
                  <tr key={k.id}>
                    <td>{k.unvan || k.kod}</td>
                    <td style={{ opacity: .7 }}>{k.kod}</td>
                    <td style={{ opacity: .7 }}>{k.rolAdi}</td>
                    <td style={{ width: 90, textAlign: 'right' }}>
                      <button type="button" className="d" disabled={islemde}
                              onClick={() => void ekle(k)}>Ekle</button>
                    </td>
                  </tr>
                ))}
                {adaylar.length === 0 && (
                  <tr><td className="bos">Eklenebilecek kullanıcı bulunamadı.</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      <table className="detay-tablo">
        <thead>
          <tr>
            <th>Kullanıcı</th><th>Kod</th><th>E-posta</th>
            <th style={{ textAlign: 'center' }}>Durum</th>
            <th>Son Giriş</th>
            {!saltOkunur && <th style={{ width: 80 }}></th>}
          </tr>
        </thead>
        <tbody>
          {!uyeler && <tr><td colSpan={6}>Yükleniyor…</td></tr>}
          {uyeler?.length === 0 && (
            <tr><td colSpan={6} className="bos">Bu rolde kullanıcı yok.</td></tr>
          )}
          {uyeler?.map(k => (
            <tr key={k.id}>
              <td>{k.unvan || '—'}</td>
              <td>{k.kod}</td>
              <td>{k.eposta}</td>
              <td style={{ textAlign: 'center' }}>
                <span className={`rozet ${k.aktif ? 'ok' : 'gri'}`}>
                  {k.aktif ? 'Aktif' : 'Pasif'}
                </span>
              </td>
              <td>{k.sonGiris ? String(k.sonGiris).slice(0, 16).replace('T', ' ') : '—'}</td>
              {!saltOkunur && (
                <td style={{ textAlign: 'right' }}>
                  <button type="button" className="d" disabled={islemde}
                          title="Varsayılan role taşır"
                          onClick={() => void cikar(k)}>Çıkar</button>
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
