import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { ArizaSecenekleri } from '../../api/uclar/ariza';
import { guvenli } from '../../bilesenler/mesaj';

/**
 * ARIZA BİLDİR `/ariza-bildir` (hizmet masası, 911).
 *
 * HERKESİN self-servis arıza bildirdiği tek ekran (yetki ariza.talep):
 * "klima çalışmıyor / pencere açılmıyor / masa kırık / PC açılmıyor".
 * Kategori seçilir, sistem SORUMLU EKİBE yönlendirir (fn_ariza_talep_ac);
 * kullanıcı ekibi bilmez, yalnız NE olduğunu söyler. Kart yok - tek amaç
 * kaydı açmak; takip "Arıza Talepleri" listesinde ekipte.
 */
export function ArizaBildir() {
  const git = useNavigate();
  const [sec, setSec] = useState<ArizaSecenekleri | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [kategori, setKategori] = useState(0);
  const [aciklama, setAciklama] = useState('');
  const [konum, setKonum] = useState('');
  const [oncelik, setOncelik] = useState(2);
  const [sonNo, setSonNo] = useState<string | null>(null);

  useEffect(() => {
    api.arizaSecenekler().then(setSec).catch(h => setHata(hataMetni(h)));
  }, []);

  const gonder = async () => {
    if (!kategori) { setHata('Arıza kategorisi seçin.'); return }
    if (!aciklama.trim()) { setHata('Ne olduğunu kısaca yazın.'); return }
    setHata(null);
    await guvenli(async () => {
      const y = await api.arizaTalepAc({
        kategori, aciklama: aciklama.trim(), konum: konum.trim() || undefined, oncelik,
      });
      setSonNo(y.talepNo);
      setKategori(0); setAciklama(''); setKonum(''); setOncelik(2);
    });
  };

  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow">
        <h1>🔧 Arıza Bildir</h1>
        <span className="yol">Teknik Servis › Arıza Bildir · {new Date().toLocaleDateString('tr-TR')}</span>
        <div className="sag">
          <button className="d" onClick={() => git('/ariza-talep')}>📋 Taleplerim / Ekip listesi</button>
        </div>
      </div></div>

      {sonNo && <div className="hata-kutusu" style={{ background: '#e6f7ec', color: '#0a7a3a', borderColor: '#0a7a3a' }}>
        ✅ Arıza kaydınız açıldı: <b>{sonNo}</b>. İlgili ekibe iletildi.
      </div>}
      {hata && <div className="hata-kutusu">{hata}</div>}

      <section className="fm-bolum" style={{ maxWidth: 640 }}>
        <div className="isg-frm">
          <div className="al g4">
            <span className="lb">Ne arızalandı? *</span>
            <select className="inp" value={kategori} onChange={e => setKategori(Number(e.target.value))}>
              <option value={0}>— Kategori seçin —</option>
              {sec?.kategoriler.map(k => <option key={k.deger} value={k.deger}>{k.ad}</option>)}
            </select>
          </div>
          <div className="al g4">
            <span className="lb">Açıklama *</span>
            <textarea className="inp" rows={3} value={aciklama} onChange={e => setAciklama(e.target.value)}
              placeholder="Örn: 2. kat koridordaki klima soğutmuyor, ses geliyor." />
          </div>
          <div className="al g2">
            <span className="lb">Konum (bina / kat / oda)</span>
            <input className="inp" value={konum} onChange={e => setKonum(e.target.value)}
              placeholder="B blok 2. kat 214" />
          </div>
          <div className="al g2">
            <span className="lb">Öncelik</span>
            <select className="inp" value={oncelik} onChange={e => setOncelik(Number(e.target.value))}>
              {sec?.oncelikler.map(o => <option key={o.deger} value={o.deger}>{o.ad}</option>)}
            </select>
          </div>
        </div>
        <div style={{ marginTop: 12 }}>
          <button className="d bir" onClick={() => void gonder()}>📨 Arıza Kaydı Aç</button>
        </div>
      </section>
    </div>
  );
}
