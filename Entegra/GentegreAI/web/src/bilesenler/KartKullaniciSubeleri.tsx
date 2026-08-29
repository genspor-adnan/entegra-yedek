import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { KullaniciSubeSatiri } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * Personel/kişi kartında ŞUBE YETKİSİ (kullanıcı: "rolün yetkili olduğu
 * şubeleri nasıl seçerim?").
 *
 * Modelde şube yetkisi role değil KULLANICIYA bağlıdır: rol "ne yapabilir"i,
 * bu tablo "nerede çalışır"ı söyler. Grid tüm aktif şubeleri listeler; işaretli
 * olanlar kullanıcının girebildiği şubelerdir. "Vars." kullanıcının açılışta
 * geldiği şube (tek), "Yazma" kapalıysa o şube salt okunur.
 */
export function KartKullaniciSubeleri({ kartId, saltOkunur }: {
  kartId: number;
  saltOkunur: boolean;
}) {
  const [satirlar, setSatirlar] = useState<KullaniciSubeSatiri[] | null>(null);
  const [kullaniciVar, setKullaniciVar] = useState(true);
  const [hata, setHata] = useState('');
  const [mesaj, setMesaj] = useState('');
  const [islemde, setIslemde] = useState(false);
  const [degisti, setDegisti] = useState(false);

  useEffect(() => {
    let iptal = false;
    api.kartSubeleri(kartId)
      .then(y => { if (!iptal) { setSatirlar(y.satirlar); setKullaniciVar(y.kullaniciVar) } })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [kartId]);

  const degis = (subeId: number, yama: Partial<KullaniciSubeSatiri>) => {
    setDegisti(true); setMesaj('');
    setSatirlar(s => s?.map(x => {
      if (x.subeId !== subeId) {
        // Varsayilan TEK olabilir: baskasi varsayilan yapilinca digeri duser.
        return yama.varsayilan ? { ...x, varsayilan: false } : x;
      }
      const yeni = { ...x, ...yama };
      // Yetki kalkarsa varsayilan/yazma da anlamsiz.
      if (yama.yetkili === false) return { ...yeni, varsayilan: false };
      if (yama.varsayilan) return { ...yeni, yetkili: true };
      return yeni;
    }) ?? s);
  };

  const kaydet = async () => {
    if (!satirlar) return;
    setIslemde(true); setHata(''); setMesaj('');
    try {
      const y = await api.kartSubeKaydet(kartId, satirlar.map(s => ({
        subeId: s.subeId, yetkili: s.yetkili, varsayilan: s.varsayilan, yazma: s.yazma,
      })));
      setSatirlar(y.satirlar);
      setDegisti(false);
      setMesaj('Şube yetkileri kaydedildi.');
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  if (hata && !satirlar) return null;   // yetkisi yoksa bolum hic cizilmez
  if (!kullaniciVar) return null;       // kullanici hesabi olmayan kartta anlamsiz

  return (
    <div className="kagrup">
      <div className="numaralama-bas bitisik">
        <h6>Yetkili Olduğu Şubeler</h6>
        {!saltOkunur && (
          <button className="d bir" disabled={islemde || !degisti}
                  onClick={() => void kaydet()}>
            {islemde ? 'Kaydediliyor…' : 'Kaydet'}
          </button>
        )}
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {mesaj && <div className="bilgi-kutusu">{mesaj}</div>}
      <table className="grid">
        <thead>
          <tr>
            <th style={{ width: 34 }}></th>
            <th>Şube</th>
            <th style={{ textAlign: 'center', width: 60 }} title="Açılışta gelen şube">Vars.</th>
            <th style={{ textAlign: 'center', width: 60 }} title="Kapalıysa şube salt okunur">Yazma</th>
          </tr>
        </thead>
        <tbody>
          {!satirlar && <tr><td colSpan={4}>Yükleniyor…</td></tr>}
          {satirlar?.map(s => (
            <tr key={s.subeId} className={s.yetkili ? 'secili' : undefined}
                style={{ cursor: saltOkunur ? 'default' : 'pointer' }}
                onClick={() => { if (!saltOkunur) degis(s.subeId, { yetkili: !s.yetkili }) }}>
              <td style={{ textAlign: 'center' }}>
                <input type="checkbox" checked={s.yetkili} readOnly />
              </td>
              <td>{s.subeAdi}</td>
              <td style={{ textAlign: 'center' }} onClick={e => e.stopPropagation()}>
                <input type="radio" name={`vars-${kartId}`} checked={s.varsayilan}
                       disabled={saltOkunur || !s.yetkili}
                       onChange={() => degis(s.subeId, { varsayilan: true })} />
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
