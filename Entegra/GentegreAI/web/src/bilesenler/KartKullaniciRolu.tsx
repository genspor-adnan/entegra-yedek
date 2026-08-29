import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { KartRolBilgisi } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * Personel/kişi kartında KULLANICI ROLÜ (kullanıcı: "personel kartında rolü
 * görebilmem ve istersem değiştirebilmem lazım").
 *
 * Rol `taraf_kullanici` kaydında durur, kartın kendi alanı değildir - bu yüzden
 * kart kaydetmeye bağlı değil: combodan seçim ANINDA uygulanır (rol atama ayrı
 * bir yetkidir ve islem_log'a rol kartı üzerinden yazılır). Kartın kullanıcı
 * hesabı yoksa bölüm bilgi satırı olarak kalır.
 */
export function KartKullaniciRolu({ kartId, saltOkunur, sade }: {
  kartId: number;
  saltOkunur: boolean;
  /** Kimlik seridinde tek alan olarak cizilir (kutu/baslik yok). */
  sade?: boolean;
}) {
  const [bilgi, setBilgi] = useState<KartRolBilgisi | null>(null);
  const [hata, setHata] = useState('');
  const [islemde, setIslemde] = useState(false);
  const [mesaj, setMesaj] = useState('');

  useEffect(() => {
    let iptal = false;
    api.kartRol(kartId)
      .then(b => { if (!iptal) setBilgi(b) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [kartId]);

  const degistir = async (rolId: number) => {
    setIslemde(true); setHata(''); setMesaj('');
    try {
      const y = await api.kartRolDegistir(kartId, rolId);
      setBilgi(y);
      setMesaj(`Rol "${y.rolAdi}" olarak güncellendi.`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  // Yetkisi olmayan kullanici rol bolumunu hic gormesin (GET 403 -> sessiz).
  if (hata && !bilgi) return null;

  const combo = !bilgi ? null : !bilgi.kullaniciVar ? null : (
    <select value={bilgi.rolId} disabled={saltOkunur || islemde}
            onChange={e => void degistir(Number(e.target.value))}>
      {bilgi.roller.map(r => <option key={r.id} value={r.id}>{r.ad}</option>)}
    </select>
  );

  // SERIT modu: kimlik seridinde departmanin sagindaki tek alan.
  if (sade) {
    if (!combo) return null;
    return (
      <label className="alan tip-kod">
        <span className="etiket zorunlu-isaret">Rol</span>
        {combo}
      </label>
    );
  }

  return (
    <div className="kagrup">
      <h6>Kullanıcı Rolü</h6>
      <div className="alan-izgara tek-sutun">
        {!bilgi ? <div className="yukleniyor">Yükleniyor…</div>
         : !bilgi.kullaniciVar ? (
           <div className="not">Bu kartın kullanıcı hesabı yok.</div>
         ) : (
           <label className="alan tip-kod">
             <span className="etiket">Rol</span>
             <select value={bilgi.rolId} disabled={saltOkunur || islemde}
                     onChange={e => void degistir(Number(e.target.value))}>
               {bilgi.roller.map(r => (
                 <option key={r.id} value={r.id}>{r.ad}</option>
               ))}
             </select>
           </label>
         )}
        {hata && <div className="alan-hata">{hata}</div>}
        {mesaj && <div className="bilgi-kutusu">{mesaj}</div>}
      </div>
    </div>
  );
}
