import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * e-NABIZ VERİ KALİTESİ / UYUM PANOSU (454) —
 * mockup <code>Ekranlar/E-Nabız/enabiz_veri_kalitesi.html</code>.
 *
 * <b>Bildirim yükümlülüğü ölçülemezse yerine getirilemez.</b> Kuyruk ekranı
 * "şu an ne bekliyor" der; bu pano "bu ay ne kadarını gönderebildik, neden
 * gönderemedik" sorusunu cevaplar. Her sayı bir işe götürür: eksik alan
 * kuyruğa, eşlenmemiş kod eşleme ekranına.
 *
 * Sayılar TEK uçtan gelir (<code>/api/enabiz/veri-kalitesi</code>) - altı ayrı
 * istek ekranın yarısını dolu yarısını boş gösterirdi (radyoloji panosu deseni).
 */

interface Sayac {
  uretilen: number; gonderilen: number; ilkDenemede: number;
  suredeGiden: number; sureOlculen: number; hatali: number;
  eksikAlanli: number; bekleyen: number;
}
interface TurSatiri {
  kod: string; ad: string; ussPaket: string;
  uretilen: number; gonderilen: number; hatali: number; eksik: number;
}
interface HataSatiri { kod: string; mesaj: string; sinif: number; adet: number }
interface EksikAlan { ussAlan: string; kaynakAlan: string; sorun: string; paket: number }
interface EslemeEksik { skrsListe: string; adet: number }
interface HekimSatiri { hekim: string; paket: number; eksik: number; gonderilen: number }
interface GunSatiri { gun: string; uretilen: number; gonderilen: number; hatali: number }

interface PanoYaniti {
  donem: string; sayac: Sayac; turler: TurSatiri[]; hatalar: HataSatiri[];
  eksikAlanlar: EksikAlan[]; eslemeEksik: EslemeEksik[]; hekimler: HekimSatiri[];
  gunluk: GunSatiri[];
}

/** Oran: payda 0 ise "—" (sıfıra bölüp %NaN yazmak sayıyı çöpe atar). */
const oran = (pay: number, payda: number) =>
  payda > 0 ? `%${(pay * 100 / payda).toFixed(1).replace('.', ',')}` : '—';

const HATA_SINIFI: Record<number, string> = {
  1: 'veri (kullanıcı düzeltir)', 2: 'servis (otomatik tekrar)', 3: 'yetki',
};

const buAy = () => new Date().toISOString().slice(0, 7);
const gunAd = (iso: string) => iso.slice(8, 10) + '.' + iso.slice(5, 7);

export function EnabizPanosu() {
  const git = useNavigate();
  const [ay, setAy] = useState(buAy);
  const [veri, setVeri] = useState<PanoYaniti | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try { setVeri(await api.enabizVeriKalitesi(ay)) }
    catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [ay]);

  useEffect(() => { void yukle() }, [yukle]);

  const s = veri?.sayac;
  const enBuyukGun = Math.max(1, ...(veri?.gunluk ?? []).map(g => g.uretilen));

  const kutular: { ik: string; deger: string; etiket: string; yol?: string;
                   vurgu?: 'teh' | 'uy' }[] = [
    { ik: '📤', deger: oran(s?.gonderilen ?? 0, s?.uretilen ?? 0),
      etiket: `Gönderim oranı (${s?.gonderilen ?? 0}/${s?.uretilen ?? 0})` },
    { ik: '🎯', deger: oran(s?.ilkDenemede ?? 0, s?.gonderilen ?? 0),
      etiket: 'İlk denemede başarı' },
    { ik: '⏱️', deger: oran(s?.suredeGiden ?? 0, s?.sureOlculen ?? 0),
      etiket: 'Süre sınırı içinde' },
    { ik: '⛔', deger: String(s?.hatali ?? 0), etiket: 'Açık hatalı paket',
      yol: '/enabiz-paket', vurgu: (s?.hatali ?? 0) > 0 ? 'teh' : undefined },
    { ik: '📝', deger: String(s?.eksikAlanli ?? 0), etiket: 'Eksik alanlı paket',
      yol: '/enabiz-paket', vurgu: (s?.eksikAlanli ?? 0) > 0 ? 'uy' : undefined },
    { ik: '🔗', deger: String((veri?.eslemeEksik ?? []).reduce((t, e) => t + e.adet, 0)),
      etiket: 'Eşlenmemiş kod', yol: '/enabiz-kod-esleme' },
  ];

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>e-Nabız Veri Kalitesi</h1>
          <span className="yol">e-Nabız › Veri Kalitesi</span>
        </div>
        <div className="basarac">
          <input type="month" value={ay} onChange={e => setAy(e.target.value)} />
          <button className="d" onClick={() => setAy(buAy())}>Bu ay</button>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
          {yukleniyor && <span className="sonuk">Yükleniyor…</span>}
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="pano-sayaclar">
          {kutular.map(k => (
            <button key={k.etiket} type="button"
                    className={`pano-kutu${k.vurgu ? ` ${k.vurgu}` : ''}`}
                    onClick={() => k.yol && git(k.yol)}
                    title={k.yol ? 'Listeyi aç' : undefined}>
              <span className="ik">{k.ik}</span>
              <span className="s">{k.deger}</span>
              <span className="e">{k.etiket}</span>
            </button>
          ))}
        </div>

      <div className="pano-satir">
        {/* PAKET TÜRÜNE GÖRE: hangi olay hattı tıkanmış? */}
        <div className="kagrup">
          <h6>Paket türüne göre ({veri?.donem ?? ay})</h6>
          <table className="detay-tablo">
            <thead><tr>
              <th>Paket</th><th className="orta">USS</th><th className="sag">Üretilen</th>
              <th className="sag">Gönderildi</th><th className="sag">Hatalı</th>
              <th className="sag">Eksik</th><th className="sag">Oran</th>
            </tr></thead>
            <tbody>
              {(veri?.turler ?? []).map(t => (
                <tr key={t.kod}>
                  <td>{t.ad}</td>
                  <td className="orta">{t.ussPaket}</td>
                  <td className="sag">{t.uretilen}</td>
                  <td className="sag">{t.gonderilen}</td>
                  <td className="sag">{t.hatali > 0
                    ? <span className="rozet hata">{t.hatali}</span> : '—'}</td>
                  <td className="sag">{t.eksik > 0
                    ? <span className="rozet uyari">{t.eksik}</span> : '—'}</td>
                  <td className="sag">{oran(t.gonderilen, t.uretilen)}</td>
                </tr>
              ))}
              {(veri?.turler ?? []).length === 0 && !yukleniyor && (
                <tr><td colSpan={7} className="bos">Bu dönemde paket üretilmemiş.</td></tr>
              )}
            </tbody>
          </table>
        </div>

        {/* EN SIK HATA: kök neden burada görünür - aynı hata yüz paketi
            düşürüyorsa düzeltilecek tek yer vardır. */}
        <div className="kagrup">
          <h6>En sık hata (son 30 gün)</h6>
          <table className="detay-tablo">
            <thead><tr>
              <th>Hata</th><th>Sınıf</th><th className="sag">Adet</th>
            </tr></thead>
            <tbody>
              {(veri?.hatalar ?? []).map(h => (
                <tr key={h.kod}>
                  <td title={h.mesaj}><b>{h.kod}</b> · {h.mesaj || '—'}</td>
                  <td className="sonuk">{HATA_SINIFI[h.sinif] ?? '—'}</td>
                  <td className="sag">{h.adet}</td>
                </tr>
              ))}
              {(veri?.hatalar ?? []).length === 0 && !yukleniyor && (
                <tr><td colSpan={3} className="bos">Hatalı paket yok.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className="pano-satir">
        {/* ALAN BAZINDA EKSİK: "neyi düzeltirsem kaç paket kurtulur". */}
        <div className="kagrup">
          <h6>Eksik alanlar</h6>
          <table className="detay-tablo">
            <thead><tr>
              <th>USS Alanı</th><th>Kaynak</th><th className="sag">Paket</th>
            </tr></thead>
            <tbody>
              {(veri?.eksikAlanlar ?? []).map(a => (
                <tr key={a.ussAlan}>
                  <td><b>{a.ussAlan}</b>{a.sorun ? <div className="sonuk">{a.sorun}</div> : null}</td>
                  <td className="sonuk">{a.kaynakAlan || '—'}</td>
                  <td className="sag">{a.paket}</td>
                </tr>
              ))}
              {(veri?.eksikAlanlar ?? []).length === 0 && !yukleniyor && (
                <tr><td colSpan={3} className="bos">Eksik alan yok.</td></tr>
              )}
            </tbody>
          </table>
        </div>

        <div className="kagrup">
          <h6>Eksik alanlı paketi olan hekimler</h6>
          <table className="detay-tablo">
            <thead><tr>
              <th>Hekim</th><th className="sag">Paket</th><th className="sag">Eksik</th>
              <th className="sag">Gönderilen</th>
            </tr></thead>
            <tbody>
              {(veri?.hekimler ?? []).map(h => (
                <tr key={h.hekim}>
                  <td>{h.hekim}</td>
                  <td className="sag">{h.paket}</td>
                  <td className="sag"><span className="rozet uyari">{h.eksik}</span></td>
                  <td className="sag">{h.gonderilen}</td>
                </tr>
              ))}
              {(veri?.hekimler ?? []).length === 0 && !yukleniyor && (
                <tr><td colSpan={4} className="bos">Eksik alanlı paket yok.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* GÜNLÜK SERİ: kesinti günleri buradan görünür (hepsi bir günde hatalıysa
          sorun kurumda değil serviste olabilir). */}
      <div className="kagrup">
        <h6>Son 14 gün</h6>
        <div className="pano-seri">
          {(veri?.gunluk ?? []).map(g => (
            <div key={g.gun} className="sutun"
                 title={`${gunAd(g.gun)} · üretilen ${g.uretilen} · gönderilen ${g.gonderilen}`
                        + ` · hatalı ${g.hatali}`}>
              <div className="cubuk" style={{ height: `${(g.uretilen / enBuyukGun) * 60 + 2}px` }}>
                {g.hatali > 0 && (
                  <i style={{ height: `${(g.hatali / Math.max(1, g.uretilen)) * 100}%` }} />
                )}
              </div>
              <div className="gun">{gunAd(g.gun)}</div>
            </div>
          ))}
        </div>
        </div>
      </div>
    </>
  );
}
