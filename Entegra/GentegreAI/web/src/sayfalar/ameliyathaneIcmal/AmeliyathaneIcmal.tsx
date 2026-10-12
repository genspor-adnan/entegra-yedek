import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { AmeliyathaneIcmali } from '../../api/uclar/ameliyathaneIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { AmeliyathaneA4 } from './AmeliyathaneA4';
import { saatMetni, sureMetni, yuzde } from './ameliyathaneIcmalOrtak';
import { AmeliyatTablosu, CerrahTablosu, IptalTablosu, SalonTablosu, SarfTablosu } from './AmeliyathaneTablolari';

/**
 * AMELİYATHANE İCMALİ `/ameliyathane-icmal` — mockup Ekranlar/İcmal/ameliyathane_icmali.html
 * (kullanıcı 12.10.2026: "icmalleri yap").
 *
 * Salon kullanımı / doluluk, süre disiplini (plan-gerçek, ilk vaka, devir),
 * cerrah ve anestezi iş yükü, ameliyat türü sarf / marj, faturaya girmeyen
 * sarf, iptal / ertelenen; A4 çıktı menüsünde. Rakamlar SUNUCUDAN
 * (AmeliyathaneIcmalUclari). Hasta kimliği yok.
 */
type Sekme = 'salon' | 'cerrah' | 'ameliyat' | 'sarf' | 'iptal';

export function AmeliyathaneIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const salon = Number(arama.get('salon') ?? 0);
  const brans = arama.get('brans') ?? '';
  const [veri, setVeri] = useState<AmeliyathaneIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('salon');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.ameliyathaneIcmali(bas, bit, salon, brans).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, salon, brans]);
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
    ['salon', 'Salonlar', veri.salonlar.length], ['cerrah', 'Cerrah / Anestezi', veri.ozet.cerrah],
    ['ameliyat', 'Ameliyatlar', veri.ameliyatlar.length], ['sarf', 'Sarf / Marj', veri.turler.length],
    ['iptal', 'İptal / Ertelenen', veri.iptaller.length]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + AM_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Ameliyathane İcmali</h1>
          <span className="yol">Ameliyathane › Ameliyathane İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Ameliyathane İcmali" dosyaAdi={`Ameliyathane İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <AmeliyathaneA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} salonu basar</span>}
        <span className="sp" />
        <button onClick={() => git('/ameliyat-cizelge')}>🗓 Masa Çizelgesi</button>
        <button onClick={() => git('/ameliyat')}>🔪 Ameliyat Planı</button>
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
          <div className="sel">🚪 Salon:
            <select value={salon} onChange={e => degistir({ salon: e.target.value })}>
              <option value={0}>Tümü</option>{veri.salonAdlari.map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
            </select>
          </div>
          <div className="sel">🩺 Branş:
            <select value={brans} onChange={e => degistir({ brans: e.target.value })}>
              <option value="">Tümü</option>{veri.branslar.map(b => <option key={b} value={b}>{b}</option>)}
            </select>
          </div>
          <span className="sp" />
          {o.faturasizVaka > 0 && <span className="bo-rz kir">{o.faturasizVaka} vakada faturalanmamış sarf</span>}
          {o.gecIlkVaka > 0 && <span className="bo-rz sari">{o.gecIlkVaka} ilk vaka geç başladı</span>}
          {o.ertelenen > 0 && <span className="bo-rz sari">{o.ertelenen} ertelenen</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Ameliyat', String(o.ameliyat), `${o.planDisi} plan dışı (acil) · ${o.salon} salon`)}
          {kutu('Salon Doluluğu', yuzde(o.doluluk), o.kapasiteDk ? `${saatMetni(o.kullanimDk)} / ${saatMetni(o.kapasiteDk)} · mesai içi` : 'salon tanımlı değil')}
          {kutu('Ort. Süre / Plan', sureMetni(o.ortSureDk), `plan ${sureMetni(o.ortPlanDk)} · sapma ${yuzde(o.sapma)}`,
                (o.sapma ?? 0) > 10 ? 'uy' : '')}
          {kutu('İlk Vaka Zamanında', yuzde(o.ilkVakaOrani), o.ilkVaka ? `${o.ilkVakaZamaninda} / ${o.ilkVaka} · ≤10 dk gecikme` : 'planlı ilk vaka yok',
                o.ilkVakaOrani != null && o.ilkVakaOrani < 70 ? 'uy' : '')}
          {kutu('Ort. Salon Devri', sureMetni(o.ortDevirDk), `${o.devir} devir`)}
          {kutu('Ciro', `${paraYaz(o.ciro)}`, 'ameliyat başvuru satırları', 'mor')}
          {kutu('Sarf + İmplant', `${paraYaz(o.sarf + o.implant)}`, `brüt kâr ${paraYaz(o.brutKar)} · marj ${yuzde(o.marj)}`)}
          {kutu('İptal / Ertelenen', `${o.iptal} / ${o.ertelenen}`, `iptal oranı ${yuzde(o.iptalOrani)}`, o.iptal ? 'teh' : 'iyi')}
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
            {sekme === 'salon' && <SalonTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'cerrah' && <CerrahTablosu v={veri} />}
            {sekme === 'ameliyat' && <AmeliyatTablosu v={veri} />}
            {sekme === 'sarf' && <SarfTablosu v={veri} />}
            {sekme === 'iptal' && <IptalTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const AM_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.lb-k { margin-left:6px; font-size:10px; }
.hi-tablo .bo-rz { white-space:nowrap; }
.bo-rz.mor { background:#f1ebfa; color:#6a3fb5; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-bar { display:inline-block; width:70px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-bas { font-weight:bold; margin:10px 0 4px; }
.a4-t.am-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.am-a4t th:nth-child(1), .a4-t.am-a4t td:nth-child(1) { text-align:left; width:30%; }
`;

export default AmeliyathaneIcmal;
