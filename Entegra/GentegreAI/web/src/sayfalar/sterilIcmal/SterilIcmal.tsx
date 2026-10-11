import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { SterilIcmali } from '../../api/uclar/sterilIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { SterilA4 } from './SterilA4';
import { yuzde } from './sterilIcmalOrtak';
import { BolumTablosu, CihazTablosu, IndikatorTablosu, KarantinaTablosu, SetTablosu } from './SterilTablolari';

/**
 * STERİLİZASYON İCMALİ `/steril-icmal` — mockup Ekranlar/İcmal/sterilizasyon_icmali.html
 * (kullanıcı 11.10.2026: "sterilizasyon icmalini kodla").
 *
 * Cihaz başına döngü / doluluk / validasyon; set ömrü; indikatörler;
 * karantina, geri çağırma, süresi dolan paket; bölümler; A4 çıktı
 * menüsünde. Rakamlar SUNUCUDAN (SterilIcmalUclari).
 */
type Sekme = 'cihaz' | 'set' | 'indikator' | 'karantina' | 'bolum';

export function SterilIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const cihaz = Number(arama.get('cihaz') ?? 0);
  const set = Number(arama.get('set') ?? 0);
  const [veri, setVeri] = useState<SterilIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('cihaz');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.sterilIcmali(bas, bit, cihaz, set).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, cihaz, set]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const ayKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`); const y = new Date(d.getFullYear(), d.getMonth() + n, 1);
    const a = ayAraligi(y.getFullYear(), y.getMonth() + 1); degistir({ bas: a.bas, bit: a.bit });
  };
  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['cihaz', 'Cihazlar', veri.cihazlar.length], ['set', 'Setler', veri.setler.length], ['indikator', 'İndikatörler', veri.ozet.indikatorBasarisiz],
    ['karantina', 'Karantina / Geri Çağırma', veri.karantina.length + veri.geriCagirmalar.length + veri.suresiDolan.length],
    ['bolum', 'Bölümler', veri.bolumler.length]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + ST_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Sterilizasyon İcmali</h1>
          <span className="yol">Diş › Sterilizasyon › Sterilizasyon İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Sterilizasyon İcmali" dosyaAdi={`Sterilizasyon İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <SterilA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} cihazı basar</span>}
        <span className="sp" />
        <button onClick={() => git('/steril-pano')}>📊 Sterilizasyon Panosu</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">📅 Dönem:
            <button className="ki-ok" title="Önceki ay" onClick={() => ayKaydir(-1)}>‹</button>
            <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value })} />–
            <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
            <button className="ki-ok" title="Sonraki ay" onClick={() => ayKaydir(1)}>›</button>
          </div>
          <div className="sel">⚙ Cihaz:
            <select value={cihaz} onChange={e => degistir({ cihaz: e.target.value })}>
              <option value={0}>Tümü</option>{veri.cihazAdlari.map(c => <option key={c.id} value={c.id}>{c.ad}</option>)}
            </select>
          </div>
          <div className="sel">🧰 Set:
            <select value={set} onChange={e => degistir({ set: e.target.value })}>
              <option value={0}>Tümü</option>{veri.setAdlari.map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
            </select>
          </div>
          <span className="sp" />
          {o.indikatorBasarisiz > 0 && <span className="bo-rz kir">{o.indikatorBasarisiz} indikatör başarısız</span>}
          {(veri.geriCagirmalar.length > 0) && <span className={'bo-rz ' + (o.acikGeriCagirma ? 'kir' : 'sari')}>
            {veri.geriCagirmalar.length} geri çağırma{o.acikGeriCagirma ? ` (${o.acikGeriCagirma} açık)` : ' (kapandı)'}</span>}
          {o.karantina > 0 && <span className="bo-rz sari">{o.karantina} paket karantinada</span>}
          {o.validasyonGeciken.map(c => <span key={c} className="bo-rz kir">{c} validasyonu gecikti</span>)}
        </div>

        <div className="hi-ozet">
          {kutu('Sterilizasyon Döngüsü', String(o.sterilDongu), `${o.serbest} serbest · ${o.test} test · ${o.yikamaDongu} yıkama döngüsü`)}
          {kutu('Cihaz Doluluğu', yuzde(o.doluluk), o.kapasite ? `${o.yuklenen} paket / ${o.kapasite} kapasite` : 'yük kapasitesi tanımsız')}
          {kutu('Üretilen Paket', String(o.uretilen), `${o.setTuru} set türü · ${o.birim} birim`, 'mor')}
          {kutu('Kullanılan Paket', String(o.kullanilan), `${o.bolum} bölüm · ${o.depoda} steril depoda`)}
          {kutu('İndikatör Başarısız', String(o.indikatorBasarisiz), `${o.indikatorOkuma} okuma`, o.indikatorBasarisiz ? 'teh' : 'iyi')}
          {kutu('Karantina / Geri Çağırma', `${o.karantina} / ${o.geriCagrilanPaket}`, `geri çağrılan paket (${o.geriKullanilmis} kullanılmış)`,
                o.geriKullanilmis ? 'teh' : '')}
          {kutu('Süresi Dolan Paket', String(o.suresiDolan), o.islenmemis ? `${o.islenmemis} paket depoda, işlenmeli` : 'yeniden işlendi', o.islenmemis ? 'teh' : '')}
          {kutu('Eşiğe Yakın Birim', String(o.esigeYakin), 'ömür döngüsü eşiğin %90 üstünde', o.esigeYakin ? 'uy' : '')}
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <div className="katab">
              {sekmeler.map(([k, ad, n]) => (
                <div key={k} className={'kat' + (sekme === k ? ' on' : '')} onClick={() => setSekme(k)}>
                  {ad}{n != null && <span className="b">{n}</span>}
                </div>
              ))}
            </div>
            {sekme === 'cihaz' && <CihazTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'set' && <SetTablosu v={veri} />}
            {sekme === 'indikator' && <IndikatorTablosu v={veri} />}
            {sekme === 'karantina' && <KarantinaTablosu v={veri} />}
            {sekme === 'bolum' && <BolumTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const ST_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.lb-k { margin-left:6px; font-size:10px; }
.hi-tablo .bo-rz { white-space:nowrap; }
.bo-rz.mor { background:#f1ebfa; color:#6a3fb5; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-bar { display:inline-block; width:70px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-kalite { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.lb-bas { font-weight:bold; margin:10px 0 4px; }
@media (max-width: 1000px) { .lb-kalite { grid-template-columns:1fr; } }
.a4-t.st-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.st-a4t th:nth-child(1), .a4-t.st-a4t td:nth-child(1) { text-align:left; width:26%; }
.a4-t.st-a4t th:nth-child(2), .a4-t.st-a4t td:nth-child(2) { text-align:right; }
`;

export default SterilIcmal;
