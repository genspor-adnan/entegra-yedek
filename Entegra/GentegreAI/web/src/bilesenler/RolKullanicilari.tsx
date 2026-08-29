import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import type { RolKullanicisi } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { Modal } from './Modal';

/**
 * Rol kartı Genel sekmesindeki "Kullanıcılar" gridi (kullanıcı: "kullanıcıları
 * genel sekmesine al", "standart GenGrid deseni, üstte ekle/düzenle/sil ikonu").
 *
 * Bir kullanıcı TEK role bağlı olduğu için "ekleme" o kullanıcının rolünü bu
 * role çevirir (eski rolü aday listesinde görünür); 🗑 rolden çıkarır -
 * kullanıcıyı SİLMEZ, varsayılan sistem rolüne taşır. ✎ kullanıcının kartını
 * açar.
 */
export function RolKullanicilari({ rolId, saltOkunur }: {
  rolId: number;
  saltOkunur: boolean;
}) {
  const git = useNavigate();
  const [uyeler, setUyeler] = useState<RolKullanicisi[] | null>(null);
  const [secili, setSecili] = useState<number | null>(null);
  const [adaylar, setAdaylar] = useState<RolKullanicisi[]>([]);
  // Aday listesinde COKLU isaretleme (kullanici): secilenler tek "Ekle" ile girer.
  const [adaySecim, setAdaySecim] = useState<Set<number>>(new Set());
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

  const ekle = async () => {
    if (adaySecim.size === 0) return;
    setIslemde(true); setHata(''); setBilgi('');
    try {
      let sonListe = uyeler ?? [];
      for (const id of adaySecim) sonListe = await api.rolKullaniciEkle(rolId, id);
      setUyeler(sonListe);
      setBilgi(`${adaySecim.size} kullanıcı bu role eklendi.`);
      setAdaylar(a => a.filter(x => !adaySecim.has(x.id)));
      setAdaySecim(new Set());
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  const adayIsaretle = (id: number) => setAdaySecim(t => {
    const y = new Set(t);
    if (y.has(id)) y.delete(id); else y.add(id);
    return y;
  });

  const cikar = async () => {
    const k = uyeler?.find(x => x.id === secili);
    if (!k) return;
    setIslemde(true); setHata(''); setBilgi('');
    try {
      const y = await api.rolKullaniciCikar(rolId, k.id);
      setUyeler(y.kullanicilar);
      setSecili(null);
      setBilgi(`${k.unvan || k.kod}: ${y.mesaj}`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  return (
    <div className="kagrup" style={{ marginTop: 12 }}>
      <div className="numaralama-bas bitisik">
        <h6>Kullanıcılar {uyeler && <span style={{ opacity: .6 }}>({uyeler.length})</span>}</h6>
        {/* Ekle / Duzenle / Sil IKON olarak ustte - sube gridiyle ayni desen. */}
        <button className="d bir" title="Role kullanıcı ekle" disabled={saltOkunur || islemde}
                onClick={() => setEkleAcik(true)}>＋</button>
        <button className="d" title="Kullanıcı kartını aç" disabled={secili === null}
                onClick={() => secili !== null && git(`/personel/${secili}`)}>✎</button>
        <button className="d" title="Rolden çıkar (kullanıcı silinmez)"
                disabled={saltOkunur || islemde || secili === null}
                onClick={() => void cikar()}>🗑</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      <table className="grid">
        <thead>
          <tr>
            <th style={{ width: 34 }}></th>
            <th>Kullanıcı</th><th>Kod</th><th>E-posta</th>
            <th style={{ textAlign: 'center' }}>Durum</th>
            <th>Son Giriş</th>
          </tr>
        </thead>
        <tbody>
          {!uyeler && <tr><td colSpan={6}>Yükleniyor…</td></tr>}
          {uyeler?.length === 0 && (
            <tr><td colSpan={6} className="bos">Bu rolde kullanıcı yok.</td></tr>
          )}
          {uyeler?.map(k => (
            /* Tek tik SATIRI ISARETLER, cift tik kullanici kartini acar. */
            <tr key={k.id} className={secili === k.id ? 'secili' : undefined}
                style={{ cursor: 'pointer' }}
                onClick={() => setSecili(t => (t === k.id ? null : k.id))}
                onDoubleClick={() => git(`/personel/${k.id}`)}>
              <td style={{ textAlign: 'center' }}>
                <input type="checkbox" checked={secili === k.id} readOnly />
              </td>
              <td>{k.unvan || '—'}</td>
              <td>{k.kod}</td>
              <td>{k.eposta}</td>
              <td style={{ textAlign: 'center' }}>
                <span className={`rozet ${k.aktif ? 'ok' : 'gri'}`}>
                  {k.aktif ? 'Aktif' : 'Pasif'}
                </span>
              </td>
              <td>{k.sonGiris ? String(k.sonGiris).slice(0, 16).replace('T', ' ') : '—'}</td>
            </tr>
          ))}
        </tbody>
      </table>

      {ekleAcik && (
        <Modal baslik="Role Kullanıcı Ekle" dar onKapat={() => { setEkleAcik(false); setAdaySecim(new Set()) }}
          /* Ekle, Kapat ile AYNI arac cubugunda (kullanici) - kart/modal deseni. */
          alt={<>
            <button className="d bir" disabled={islemde || adaySecim.size === 0}
                    onClick={() => void ekle()}>
              {islemde ? 'Ekleniyor…' : `Ekle${adaySecim.size > 0 ? ` (${adaySecim.size})` : ''}`}
            </button>
            <button className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                    onClick={() => { setEkleAcik(false); setAdaySecim(new Set()) }}>Kapat</button>
          </>}>
          <div style={{ padding: 10 }}>
            {/* Listelerdeki oval arama kutusu. */}
            <div className="ara" style={{
              maxWidth: 260, margin: '0 0 8px', height: 23, borderRadius: 12,
              background: 'var(--yuz)', color: 'var(--yazi)', border: '1px solid var(--cizgi)',
            }}>
              <span>🔍</span>
              <input autoFocus value={arama}
                     style={{ border: 0, background: 'transparent', outline: 'none',
                              width: '100%', color: 'inherit' }}
                     placeholder="Kullanıcı ara (ad, kod, e-posta)…"
                     onChange={e => setArama(e.target.value)} />
            </div>
            <div style={{ maxHeight: 320, overflowY: 'auto' }}>
              <table className="grid">
                <thead>
                  <tr>
                    <th style={{ width: 34 }}></th>
                    <th>Kullanıcı</th><th>Kod</th><th>Şu anki rolü</th>
                  </tr>
                </thead>
                <tbody>
                  {adaylar.map(k => (
                    <tr key={k.id} className={adaySecim.has(k.id) ? 'secili' : undefined}
                        style={{ cursor: 'pointer' }}
                        onClick={() => adayIsaretle(k.id)}
                        onDoubleClick={() => { adayIsaretle(k.id); void ekle() }}>
                      <td style={{ textAlign: 'center' }}>
                        <input type="checkbox" checked={adaySecim.has(k.id)} readOnly />
                      </td>
                      <td>{k.unvan || '—'}</td>
                      <td>{k.kod}</td>
                      <td style={{ opacity: .7 }}>{k.rolAdi}</td>
                    </tr>
                  ))}
                  {adaylar.length === 0 && (
                    <tr><td colSpan={4} className="bos">Eklenebilecek kullanıcı bulunamadı.</td></tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}
