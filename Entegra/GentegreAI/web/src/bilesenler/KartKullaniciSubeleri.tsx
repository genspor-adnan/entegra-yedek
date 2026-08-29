import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { KullaniciSubeSatiri } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * Personel kartında "Yetkili Şubeler" (kullanıcı: "fotoğrafın altına yetkili
 * şubeleri getir, rolden kaldır tekrar").
 *
 * Rol modül yetkisini taşır; kişinin hangi şubelerde çalıştığı BURADA
 * belirlenir - aynı roldeki iki kişi farklı şubelerde olabilir. "Vars."
 * açılışta gelen şube (tek), "Yazma" kapalıysa o şube salt okunur.
 */
export function KartKullaniciSubeleri({ kartId, saltOkunur, zorunluSubeId }: {
  kartId: number;
  saltOkunur: boolean;
  /** Kişinin ÇALIŞTIĞI şube: her zaman yetkili, işareti kaldırılamaz. */
  zorunluSubeId?: number;
}) {
  const [satirlar, setSatirlar] = useState<KullaniciSubeSatiri[] | null>(null);
  const [hata, setHata] = useState('');
  const [mesaj, setMesaj] = useState('');
  const [islemde, setIslemde] = useState(false);
  const [degisti, setDegisti] = useState(false);

  useEffect(() => {
    let iptal = false;
    api.kartSubeleri(kartId)
      .then(y => { if (!iptal) setSatirlar(y) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [kartId]);

  const degis = (subeId: number, yama: Partial<KullaniciSubeSatiri>) => {
    // Calistigi sube kilitli (kullanici): yetkisi kaldirilamaz.
    if (subeId === zorunluSubeId && yama.yetkili === false) return;
    setDegisti(true); setMesaj('');
    setSatirlar(s => s?.map(x => (x.subeId === subeId ? { ...x, ...yama } : x)) ?? s);
  };

  const kaydet = async () => {
    if (!satirlar) return;
    setIslemde(true); setHata(''); setMesaj('');
    try {
      setSatirlar(await api.kartSubeKaydet(kartId, satirlar.map(s => ({
        subeId: s.subeId,
        yetkili: s.yetkili || s.subeId === zorunluSubeId,
        // Varsayilan HER ZAMAN calistigi sube (kullanici) - ayri kolon yok.
        varsayilan: s.subeId === zorunluSubeId,
        yazma: s.yazma,
      }))));
      setDegisti(false);
      setMesaj('Şube yetkileri kaydedildi.');
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  if (hata && !satirlar) return null;   // yetkisi yoksa bolum hic cizilmez
  // TEK SUBELI kurulumda sube secimi anlamsiz (kullanici): bolum hic cizilmez,
  //   sunucu da rolun subesi yoksa o tek subeyi verir.
  if (satirlar && satirlar.length <= 1) return null;

  const secili = satirlar?.some(s => s.yetkili) ?? true;

  return (
    <div className="kagrup" style={{ marginTop: 12 }}>
      <div className="numaralama-bas bitisik">
        <h6>Yetkili Şubeler</h6>
        {!saltOkunur && (
          <button className="d bir" disabled={islemde || !degisti}
                  onClick={() => void kaydet()}>
            {islemde ? 'Kaydediliyor…' : 'Kaydet'}
          </button>
        )}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {mesaj && <div className="bilgi-kutusu">{mesaj}</div>}
      {!secili && (
        <div className="hata-kutusu">
          Şube seçilmedi - bu kullanıcı hiçbir şubeye giremez.
        </div>
      )}
      <table className="grid">
        <thead>
          <tr>
            <th style={{ width: 34 }}></th>
            <th>Şube</th>
            <th style={{ textAlign: 'center', width: 60 }} title="Kapalıysa şube salt okunur">Yazma</th>
          </tr>
        </thead>
        <tbody>
          {!satirlar && <tr><td colSpan={4}>Yükleniyor…</td></tr>}
          {satirlar?.map(s => (
            <tr key={s.subeId} className={s.yetkili ? 'secili' : undefined}
                style={{ cursor: saltOkunur || s.subeId === zorunluSubeId
                                 ? 'default' : 'pointer' }}
                onClick={() => { if (!saltOkunur) degis(s.subeId, { yetkili: !s.yetkili }) }}>
              <td style={{ textAlign: 'center' }}>
                <input type="checkbox" checked={s.yetkili || s.subeId === zorunluSubeId}
                       disabled={s.subeId === zorunluSubeId} readOnly />
              </td>
              <td title={s.subeId === zorunluSubeId
                         ? 'Çalıştığı şube - yetkisi kaldırılamaz' : undefined}>
                {s.subeAdi}
              </td>
              <td style={{ textAlign: 'center' }} onClick={e => e.stopPropagation()}>
                <input type="checkbox" checked={s.yazma}
                       disabled={saltOkunur || !s.yetkili}
                       onChange={e => degis(s.subeId, { yazma: e.target.checked })} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
