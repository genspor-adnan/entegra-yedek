import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { FtrIcmali } from '../../api/uclar/ftrIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { FtrA4 } from './FtrA4';
import { ondalik, vasFark, yuzde } from './ftrIcmalOrtak';
import { FizyoterapistTablosu, KabinTablosu, KlinikTablosu, KurTablosu, OdeyenTablosu } from './FtrTablolari';

/**
 * FTR İCMALİ `/ftr-icmal` — mockup Ekranlar/İcmal/ftr_icmali.html
 * (kullanıcı 12.10.2026: "icmalleri yap").
 *
 * Dönemde kür / seans hacmi, devam, fizyoterapist iş yükü, ödeyen kırılımı,
 * klinik sonuç (VAS, ölçek, yanıt), ara değerlendirme, uygulama ve kabin
 * doluluğu; A4 çıktı menüsünde. Rakamlar SUNUCUDAN (FtrIcmalUclari).
 */
type Sekme = 'fzt' | 'kur' | 'odeyen' | 'klinik' | 'kabin';

const ODEYENLER: [string, string][] = [['', 'Tümü'], ['sgk', 'SGK (Medula)'], ['oss', 'ÖSS'], ['kurum', 'Kurum'], ['ozel', 'Özel']];

export function FtrIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const fzt = Number(arama.get('fzt') ?? 0);
  const bolge = Number(arama.get('bolge') ?? 0);
  const odeyen = arama.get('odeyen') ?? '';
  const [veri, setVeri] = useState<FtrIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('fzt');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.ftrIcmali(bas, bit, fzt, bolge, odeyen).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, fzt, bolge, odeyen]);
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
    ['fzt', 'Fizyoterapistler', veri.fizyoterapistler.length], ['kur', 'Kürler', veri.kurler.length], ['odeyen', 'Ödeyen', veri.odeyenler.length],
    ['klinik', 'Klinik Sonuç', veri.ozet.biten], ['kabin', 'Cihaz / Kabin', veri.uygulamalar.length]] : [];
  const fztSecili = veri ? veri.fizyoterapistler.filter(f => secili.includes(f.id)).map(f => f.ad) : [];
  const suzgec = [
    fzt && veri ? veri.fizyoterapistAdlari.find(f => f.id === fzt)?.ad : '',
    bolge && veri ? veri.bolgeAdlari.find(b => b.id === bolge)?.ad : '',
    odeyen ? ODEYENLER.find(x => x[0] === odeyen)?.[1] : '',
  ].filter(Boolean).join(' · ') || 'Tüm kürler';

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + FT_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>FTR İcmali</h1>
          <span className="yol">FTR › FTR İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="FTR İcmali" dosyaAdi={`FTR İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <FtrA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} suzgec={suzgec} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">Seçili {secili.length} fizyoterapist kürleri ve A4'ü süzer</span>}
        <span className="sp" />
        <button onClick={() => git('/ftr-pano')}>🗂 Ünite Panosu</button>
        <button onClick={() => git('/ftr-seans')}>📅 Seanslar</button>
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
          <div className="sel">🧑‍⚕️ Fizyoterapist:
            <select value={fzt} onChange={e => degistir({ fzt: e.target.value })}>
              <option value={0}>Tümü</option>{veri.fizyoterapistAdlari.map(f => <option key={f.id} value={f.id}>{f.ad}</option>)}
            </select>
          </div>
          <div className="sel">🦴 Bölge:
            <select value={bolge} onChange={e => degistir({ bolge: e.target.value })}>
              <option value={0}>Tümü</option>{veri.bolgeAdlari.map(b => <option key={b.id} value={b.id}>{b.ad}</option>)}
            </select>
          </div>
          <div className="sel">💳 Ödeyen:
            <select value={odeyen} onChange={e => degistir({ odeyen: e.target.value })}>
              {ODEYENLER.map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
            </select>
          </div>
          <span className="sp" />
          {o.araGecikti > 0 && <span className="bo-rz kir">{o.araGecikti} kürde ara değerlendirme gecikti</span>}
          {o.yarida > 0 && <span className="bo-rz sari">{o.yarida} kür yarıda bırakıldı</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Kür', String(o.kur), `${o.suren} süren · ${o.biten} biten · ${o.yarida} yarıda`)}
          {kutu('Seans', String(o.seans), `${o.yarim} yarım · ${o.planli} planlı`)}
          {kutu('Gelmedi / İptal', `${o.gelmedi} / ${o.iptal}`, `devam oranı ${yuzde(o.devam)}`, o.devam != null && o.devam < 80 ? 'teh' : '')}
          {kutu('Kür Başı Seans', ondalik(o.kurBasiSeans), 'tamamlanan kürlerde')}
          {kutu('Ciro', paraYaz(o.ciro), `kurum ${paraYaz(o.kurum)} · hasta ${paraYaz(o.hasta)}`, 'mor')}
          {kutu('Medula Payı', yuzde(o.medulaSeansPayi), `seansların · ciro ${yuzde(o.medulaCiroPayi)}`)}
          {kutu('İyi Yanıt', yuzde(o.iyiYanit), `VAS ort. ${vasFark(o.vasDusus)} puan`, o.iyiYanit != null ? 'iyi' : '')}
          {kutu('Kabin Doluluğu', yuzde(o.kabinDoluluk), `${o.kabin} kabin / salon`)}
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
            {sekme === 'fzt' && <FizyoterapistTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'kur' && <KurTablosu v={veri} fztSecili={fztSecili} />}
            {sekme === 'odeyen' && <OdeyenTablosu v={veri} />}
            {sekme === 'klinik' && <KlinikTablosu v={veri} />}
            {sekme === 'kabin' && <KabinTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const FT_STILI = `
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
.a4-t.ft-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.ft-a4t th:nth-child(1), .a4-t.ft-a4t td:nth-child(1) { text-align:left; width:30%; }
`;

export default FtrIcmal;
