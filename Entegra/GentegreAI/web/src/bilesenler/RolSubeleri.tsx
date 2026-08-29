import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { RolSubeSatiri } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * Rol kartı "Şubeler" bölümü (kullanıcı kararı: "şube kısıtını personel değil
 * role ata, personel yetkiyi her zaman rolden alır").
 *
 * Rol hem ne yapılabileceğini (yetki matrisi) hem nerede çalışılacağını (bu
 * liste) belirler: bu roldeki her kullanıcı giriş yaptığında işaretli şubeleri
 * görür. "Vars." açılışta gelen şube (tek), "Yazma" kapalıysa o şube salt
 * okunur - kullanıcı görür ama kayıt değiştiremez.
 */
export function RolSubeleri({ rolId, saltOkunur }: {
  rolId: number;
  saltOkunur: boolean;
}) {
  const [satirlar, setSatirlar] = useState<RolSubeSatiri[] | null>(null);
  const [hata, setHata] = useState('');
  const [mesaj, setMesaj] = useState('');
  const [islemde, setIslemde] = useState(false);
  const [degisti, setDegisti] = useState(false);

  useEffect(() => {
    let iptal = false;
    api.rolSubeleri(rolId)
      .then(y => { if (!iptal) setSatirlar(y) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [rolId]);

  const degis = (subeId: number, yama: Partial<RolSubeSatiri>) => {
    setDegisti(true); setMesaj('');
    setSatirlar(s => s?.map(x => {
      // Varsayilan TEK olabilir: baskasi varsayilan yapilinca digeri duser.
      if (x.subeId !== subeId) return yama.varsayilan ? { ...x, varsayilan: false } : x;
      const yeni = { ...x, ...yama };
      if (yama.yetkili === false) return { ...yeni, varsayilan: false };
      if (yama.varsayilan) return { ...yeni, yetkili: true };
      return yeni;
    }) ?? s);
  };

  const kaydet = async () => {
    if (!satirlar) return;
    setIslemde(true); setHata(''); setMesaj('');
    try {
      setSatirlar(await api.rolSubeKaydet(rolId, satirlar.map(s => ({
        subeId: s.subeId, yetkili: s.yetkili, varsayilan: s.varsayilan, yazma: s.yazma,
      }))));
      setDegisti(false);
      setMesaj('Rolün şubeleri kaydedildi.');
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
        <h6>Şubeler</h6>
        {!saltOkunur && (
          <button className="d bir" disabled={islemde || !degisti}
                  onClick={() => void kaydet()}>
            {islemde ? 'Kaydediliyor…' : 'Kaydet'}
          </button>
        )}
      </div>
      <div className="not" style={{ margin: '0 10px 8px' }}>
        Bu roldeki kullanıcılar işaretli şubelerde çalışır; şube yetkisi kişiye
        değil role verilir.
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {mesaj && <div className="bilgi-kutusu">{mesaj}</div>}
      {!secili && (
        <div className="hata-kutusu">
          Şube seçilmedi - bu roldeki kullanıcılar hiçbir şubeye giremez.
        </div>
      )}
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
                <input type="radio" name={`rolvars-${rolId}`} checked={s.varsayilan}
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
