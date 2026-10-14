import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { GostergeIcerik } from '../bilesenler/GostergeIcerik';
import { c } from '../dil/ceviri';
import { Panel } from './Panel';

/**
 * GÖSTERGE PANELİ `/gosterge/:kod` (1103, mockup Ekranlar/Dashboard/gosterge_panelleri.html).
 * Ctrl+K ("gösterge") ya da Başlangıç'ın ilk kutucuğundan açılır, kendi sekmesinde durur.
 * "genel" = önceki Ana Sayfa paneli (kurum profilinin paneli) - aynen korunur.
 * Kim görür: rol yetki matrisi (gosterge.<kod>); yetkisiz panel sunucuda 403.
 */
export function GostergePaneli() {
  const { kod = '' } = useParams();
  const git = useNavigate();
  const [veri, setVeri] = useState<Awaited<ReturnType<typeof api.gostergePaneli>> | null>(null);
  const [liste, setListe] = useState<Awaited<ReturnType<typeof api.gostergeler>>>([]);
  const [hata, setHata] = useState('');
  const [zaman, setZaman] = useState<Date | null>(null);

  const yukle = useCallback(() => {
    if (kod === 'genel') return;
    api.gostergePaneli(kod).then(v => { setVeri(v); setHata(''); setZaman(new Date()) }).catch(h => setHata(hataMetni(h)));
  }, [kod]);
  useEffect(() => { setVeri(null); yukle(); const t = setInterval(yukle, 60000); return () => clearInterval(t) }, [yukle]);
  useEffect(() => { void api.gostergeler().then(setListe).catch(() => {}) }, []);

  const secici = (
    <select value={kod} onChange={e => git(`/gosterge/${e.target.value}`)} title={c('Başka gösterge paneli')}>
      {liste.map(p => <option key={p.kod} value={p.kod}>{p.ikon} {c(p.ad)}</option>)}
    </select>
  );

  if (kod === 'genel') return (
    <>
      <div className="gosterge-ust">{secici}</div>
      <Panel />
    </>
  );

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{veri ? `${veri.ikon} ${c(veri.ad)}` : c('Gösterge Paneli')}</h1>
          <span className="yol">{c('Gösterge Panelleri')}{veri?.aciklama ? ` · ${c(veri.aciklama)}` : ''}</span>
          <span className="sag">
            <span className="sonuk">{c('Yenileme 60 sn')}{zaman ? ` · ${zaman.toLocaleTimeString('tr-TR')}` : ''}</span>
            <button type="button" className="d" onClick={yukle}>⟳</button>
            {secici}
          </span>
        </div>
      </div>
      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {!veri && !hata && <div className="yukleniyor">{c('Yükleniyor…')}</div>}
        {veri && <GostergeIcerik kutular={veri.kutular} bloklar={veri.bloklar} />}
      </div>
    </>
  );
}
