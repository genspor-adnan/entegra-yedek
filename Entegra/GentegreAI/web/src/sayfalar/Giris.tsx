import { useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type SubeOzeti } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';

/**
 * Giris ekrani. Cok subeli kullanicida sube secimi giris akisinin parcasidir:
 * kullanici/parola dogrulanip subeler ogrenilir, sube secilince oturum acilir.
 * (Sunucu sube secilmeden de token verir; burada secim once sorulur ki
 * kullanici hangi subede calistigini bilerek girsin.)
 */
export function Giris() {
  const { girisYap } = useOturum();
  const [kod, setKod] = useState('admin');
  const [parola, setParola] = useState('');
  const [subeler, setSubeler] = useState<SubeOzeti[] | null>(null);
  const [subeId, setSubeId] = useState<number | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [bekliyor, setBekliyor] = useState(false);

  async function gonder(e: React.FormEvent) {
    e.preventDefault();
    setHata(null);
    setBekliyor(true);
    try {
      if (subeler === null) {
        // 1. adim: kimlik dogrulama - sube secimi gerekiyorsa listeyi goster
        const yanit = await api.giris(kod, parola);
        if (yanit.subeSecimiGerekli) {
          setSubeler(yanit.kullanici.subeler);
          setSubeId(yanit.kullanici.subeler.find(s => s.varsayilan)?.id ?? yanit.kullanici.subeler[0]?.id ?? null);
          return;
        }
        await girisYap(kod, parola);
      } else {
        // 2. adim: secilen sube ile giris
        await girisYap(kod, parola, subeId ?? undefined);
      }
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
      setSubeler(null);
    } finally {
      setBekliyor(false);
    }
  }

  return (
    <div className="giris-sayfa">
      <form className="giris-kart" onSubmit={gonder}>
        <h1>Gentegre</h1>
        <p className="alt-baslik">
          {subeler === null ? 'Kullanici adi ve parola' : 'Calisacaginiz subeyi secin'}
        </p>

        {subeler === null ? (
          <>
            <label>
              Kullanici
              <input value={kod} onChange={e => setKod(e.target.value)} autoFocus autoComplete="username" />
            </label>
            <label>
              Parola
              <input type="password" value={parola} onChange={e => setParola(e.target.value)} autoComplete="current-password" />
            </label>
          </>
        ) : (
          <label>
            Sube
            <select value={subeId ?? ''} onChange={e => setSubeId(Number(e.target.value))}>
              {subeler.map(s => (
                <option key={s.id} value={s.id}>
                  {s.ad}{s.varsayilan ? ' (varsayilan)' : ''}{s.yazma ? '' : ' — salt okuma'}
                </option>
              ))}
            </select>
          </label>
        )}

        {hata && <div className="hata-kutusu">{hata}</div>}

        <button type="submit" disabled={bekliyor}>
          {bekliyor ? 'Bekleyin…' : subeler === null ? 'Giris' : 'Devam'}
        </button>
      </form>
    </div>
  );
}
