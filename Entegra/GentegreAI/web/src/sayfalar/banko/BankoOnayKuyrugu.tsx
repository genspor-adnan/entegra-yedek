import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { OnaySatiri } from '../../api/uclar/bankoOturum';
import { guvenli, mesaj, metinSor } from '../../bilesenler/mesaj';

/**
 * BANKO ONAY KUYRUĞU `/banko-onay` (987) — mockup penceresi 2
 * (Ekranlar/Kayıt Kabul/banko_oturum_akisi_v2.html).
 *
 * Açılış ve kapanış bekleyenler TEK kuyrukta: sorumlunun işi "bekleyen imza",
 * türü `tür` sütunu ayırt eder. İki ayrı ekran, sabah açılışıyla akşam
 * teslimini iki yerden takip etmek demekti.
 *
 * SORUMLU KENDİ OTURUMUNU ONAYLAMAZ: satır `kendisi` ise düğmeler kapalı
 * gelir (sunucu da reddeder) - karşılıklı imza değil denetim olması için.
 *
 * FARKLI AÇILIŞ/KAPANIŞ AYRI ANLAM TAŞIR: devir ya da sayım tutmuyorsa
 * onaylayan kişi farkı da onaylamış olur; fark satırı bu yüzden kırmızı
 * vurgulanır ve notu listede görünür.
 */
const para = (n: number) =>
  n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const saat = (t: string | null) =>
  t ? new Date(t).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' }) : '—';

export function BankoOnayKuyrugu() {
  const [satirlar, setSatirlar] = useState<OnaySatiri[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);

  const yukle = useCallback(async () => {
    try { setSatirlar(await api.bankoOturumKuyruk()); setHata(null) }
    catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, []);

  useEffect(() => { void yukle(); const t = setInterval(() => void yukle(), 20000); return () => clearInterval(t) }, [yukle]);

  const onayla = (s: OnaySatiri) => guvenli(async () => {
    const y = await api.bankoOturumOnayla(s.id);
    mesaj(y.oturum?.durum === 4 ? 'Oturum kapandı.' : 'Oturum açıldı.');
    await yukle();
  });

  const reddet = (s: OnaySatiri) => guvenli(async () => {
    const not = await metinSor(
      s.tur === 'acilis' ? 'Açılış reddi — gerekçe' : 'Teslim reddi — gerekçe (görevli yeniden sayar)');
    if (!not?.trim()) return;
    await api.bankoOturumReddet(s.id, not);
    mesaj(s.tur === 'acilis' ? 'Açılış reddedildi.' : 'Teslim reddedildi; oturum açık kaldı.');
    await yukle();
  });

  if (yukleniyor) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;

  return (
    <div className="fm-sayfa bok-sayfa">
      <style>{stil}</style>
      <div className="bok-baslik">
        <h2>✅ Banko Onay Kuyruğu</h2>
        <span className="bok-ust">{satirlar.length} bekleyen</span>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {satirlar.length === 0 ? (
        <div className="bok-bos">Bekleyen onay yok.</div>
      ) : (
        <table className="bok-tablo">
          <thead>
            <tr>
              <th>Saat</th><th>Tür</th><th>Banko</th><th>Görevli</th><th>Vardiya</th>
              <th className="sag">Beklenen / Sayım</th><th className="sag">Fark</th>
              <th>Not</th><th className="orta">İşlem</th>
            </tr>
          </thead>
          <tbody>
            {satirlar.map(s => (
              <tr key={s.id} className={s.fark !== 0 ? 'farkli' : ''}>
                <td>{saat(s.tur === 'acilis' ? s.talepTs : s.kapanisTalepTs)}</td>
                <td><span className={'bok-rz ' + (s.tur === 'acilis' ? 'mavi' : 'mor')}>
                  {s.tur === 'acilis' ? 'açılış' : 'kapanış'}</span></td>
                <td>{s.bankoKod} · {s.bankoAd}</td>
                <td>{s.gorevli}{s.kendisi && <> <span className="bok-rz sari">siz</span></>}</td>
                <td>{s.vardiya || '—'}</td>
                <td className="sag tek">{para(s.beklenen)} / {para(s.sayim)}</td>
                <td className="sag tek">
                  {s.fark === 0 ? '0,00' : <span className="bok-rz kir">{para(s.fark)}</span>}
                </td>
                <td className="sar">{s.not || '—'}</td>
                <td className="orta">
                  <button className="bok-ok" disabled={s.kendisi} onClick={() => onayla(s)}>✔ Onayla</button>
                  <button className="bok-red" disabled={s.kendisi} onClick={() => reddet(s)}>✖ Reddet</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <div className="bok-not">
        <b>Farklı açılış/kapanış ayrı onay ister:</b> devir ya da sayım tutmuyorsa
        onaylayan kişi farkı da onaylamış olur - fark fişi onun adına düşer. Onay kaydı
        kim, ne zaman, hangi tutarı onayladı olarak durur.
        {' '}<b>Kendi oturumunuzu onaylayamazsınız.</b> Teslim reddi oturumu kapatmaz,
        açık durumuna döndürür - görevli yeniden sayar.
      </div>
    </div>
  );
}

const stil = `
.bok-sayfa { padding: 14px 16px 24px; }
.bok-baslik { display:flex; align-items:baseline; gap:12px; margin-bottom:10px; }
.bok-baslik h2 { margin:0; font-size:17px; }
.bok-ust { color: var(--ikincil-metin, #6b7a8b); font-size:12px; }
.bok-tablo { border-collapse:collapse; width:100%; font-size:12px;
  background: var(--kart, #fff); border:1px solid var(--cizgi, #cdd6e0); border-radius:6px; }
.bok-tablo th { background: var(--baslik-arka, #f3f6fa); text-align:left; padding:6px 8px;
  border-bottom:1px solid var(--cizgi, #cdd6e0); font-size:11px; white-space:nowrap; }
.bok-tablo td { padding:5px 8px; border-bottom:1px solid var(--cizgi-ince, #e3e9f0); }
.bok-tablo tr.farkli td { background: rgba(179,38,30,.06); }
.bok-tablo .sag { text-align:right; } .bok-tablo .orta { text-align:center; white-space:nowrap; }
.bok-tablo .tek { font-family: Consolas, monospace; }
.bok-tablo .sar { max-width:280px; }
.bok-rz { display:inline-block; border-radius:9px; padding:0 7px; font-size:10.5px; margin-left:4px;
  border:1px solid var(--cizgi, #cdd6e0); }
.bok-rz.mavi { background:#eef4fc; color:#2f6db3; border-color:#cfe0f5; }
.bok-rz.mor { background:#f1ecfa; color:#6a3fb5; border-color:#ddd0f2; }
.bok-rz.sari { background:#fdf6e3; color:#8a6218; border-color:#f2ddbf; }
.bok-rz.kir { background:#fbe9e7; color:#b3261e; border-color:#f3c4bf; }
.bok-tablo button { border:1px solid var(--cizgi, #cdd6e0); border-radius:3px; padding:2px 8px;
  font-size:11px; cursor:pointer; margin:0 2px; background: var(--kart, #fff); }
.bok-tablo button:disabled { opacity:.4; cursor:default; }
.bok-ok { border-color:#3f9a5e !important; color:#2e7d46; }
.bok-red { border-color:#c9766f !important; color:#b3261e; }
.bok-bos { border:1px dashed var(--cizgi, #cdd6e0); border-radius:6px; padding:16px;
  color: var(--ikincil-metin, #6b7a8b); font-size:12.5px; }
.bok-not { margin-top:10px; color: var(--ikincil-metin, #6b7a8b); font-size:11px; line-height:1.7; }
`;

export default BankoOnayKuyrugu;
