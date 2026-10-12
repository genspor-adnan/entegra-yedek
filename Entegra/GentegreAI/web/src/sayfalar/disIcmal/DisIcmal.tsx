import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { DisIcmali } from '../../api/uclar/disIcmal';
import { para } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { DisA4 } from './DisA4';
import { yuzde } from './disIcmalOrtak';
import { HekimTablosu, IslemTablosu, LabUniteTablosu, PlanTablosu, YarimKalanTablosu } from './DisTablolari';

/**
 * DİŞ İCMALİ `/dis-icmal` — mockup Ekranlar/İcmal/dis_icmali.html
 * (kullanıcı 12.10.2026: "icmalleri yap").
 *
 * Hekim başına seans / işlem / ciro / sarf / lab / brüt kâr; tedavi planı
 * hunisi; yarım kalan planlar; işlem türleri; laboratuvar ve ünite doluluğu;
 * A4 çıktı menüsünde. Rakamlar SUNUCUDAN (DisIcmalUclari).
 */
type Sekme = 'hekim' | 'plan' | 'yarim' | 'islem' | 'lab';

const p = (n: number) => para.format(n);

export function DisIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const hekim = Number(arama.get('hekim') ?? 0);
  const grup = Number(arama.get('grup') ?? 0);
  const [veri, setVeri] = useState<DisIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('hekim');
  const [secili, setSecili] = useState<number[]>([]);
  const [seciliPlan, setSeciliPlan] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]); setSeciliPlan([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.disIcmali(bas, bit, hekim, grup).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, hekim, grup]);
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
    ['hekim', 'Hekimler', veri.hekimler.length], ['plan', 'Tedavi Planları', veri.ozet.planSunulan], ['yarim', 'Yarım Kalanlar', veri.yarimKalan.length],
    ['islem', 'İşlem Türleri', veri.islemTurleri.length], ['lab', 'Lab / Ünite', veri.laboratuvarlar.length + veri.uniteler.length]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + DS_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Diş İcmali</h1>
          <span className="yol">Diş › Diş İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Diş İcmali" dosyaAdi={`Diş İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <DisA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} hekimi basar</span>}
        <span className="sp" />
        <button onClick={() => git('/dis-plan')}>🦷 Tedavi Planları</button>
        <button onClick={() => git('/dis-lab-isemri')}>🧪 Lab İş Emirleri</button>
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
          <div className="sel">🧑‍⚕️ Hekim:
            <select value={hekim} onChange={e => degistir({ hekim: e.target.value })}>
              <option value={0}>Tümü</option>{veri.hekimAdlari.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
            </select>
          </div>
          <div className="sel">🦷 İşlem Grubu:
            <select value={grup} onChange={e => degistir({ grup: e.target.value })}>
              <option value={0}>Tümü</option>{veri.gruplar.map(g => <option key={g.id} value={g.id}>{g.ad}</option>)}
            </select>
          </div>
          <span className="sp" />
          {o.yarimAdet > 0 && <span className="bo-rz kir">{o.yarimAdet} yarım kalan plan · {p(o.yarimKalan)} ₺</span>}
          {o.labGec > 0 && <span className="bo-rz sari">{o.labGec} lab işi geç</span>}
          {o.faturasiz > 0 && <span className="bo-rz sari">{o.faturasiz} işlem faturasız</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Seans', String(o.seans), `${o.hasta} hasta · ${o.islem} işlem`)}
          {kutu('Ciro', `${p(o.ciro)} ₺`, 'yapılan işlem tutarı', 'mor')}
          {kutu('Sarf + Lab', `${p(o.sarfLab)} ₺`, `sarf ${p(o.sarf)} · lab ${p(o.lab)}`)}
          {kutu('Brüt Kâr', `${p(o.kar)} ₺`, `marj ${yuzde(o.marj)}`, 'iyi')}
          {kutu('Plan Kabul', yuzde(o.kabulYuzde), `${o.planKabul} / ${o.planSunulan} sunulan plan`)}
          {kutu('Plan Tamamlanma', yuzde(o.tamamYuzde), `${o.planTamam} / ${o.planKabul} kabul edilen`)}
          {kutu('Yarım Kalan', `${p(o.yarimKalan)} ₺`, `${o.yarimAdet} plan · ${o.yarimGun}+ gün seans yok`, o.yarimAdet ? 'teh' : '')}
          {kutu('Ünite Doluluğu', yuzde(o.uniteDoluluk), `${o.uniteSayisi} ünite · ort. ${o.ortSeansDk ?? '—'} dk/seans`)}
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
            {sekme === 'hekim' && <HekimTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'plan' && <PlanTablosu v={veri} />}
            {sekme === 'yarim' && <YarimKalanTablosu v={veri} secili={seciliPlan} setSecili={setSeciliPlan} />}
            {sekme === 'islem' && <IslemTablosu v={veri} />}
            {sekme === 'lab' && <LabUniteTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const DS_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.lb-k { margin-left:6px; font-size:10px; }
.hi-tablo .bo-rz { white-space:nowrap; }
.bo-rz.mor { background:#f1ebfa; color:#6a3fb5; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-bar { display:inline-block; width:70px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-bas { font-weight:bold; margin:10px 0 4px; }
.ds-huni { display:flex; flex-wrap:wrap; align-items:center; gap:6px; margin:4px 0 10px; font-size:12px; color:var(--soluk,#5b6b7d); }
.ds-adim { background:var(--zemin-2,#eef3f8); border:1px solid var(--cizgi,#d6dee8); border-radius:4px; padding:4px 8px; color:var(--yazi,#1f2d3d); }
.ds-adim.iyi { background:#e7f5ec; border-color:#bfe3cb; }
.ds-adim.soluk { margin-left:auto; color:var(--soluk,#5b6b7d); }
.a4-t.ds-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.ds-a4t th:nth-child(1), .a4-t.ds-a4t td:nth-child(1) { text-align:left; width:26%; }
.a4-t.ds-a4t th:not(:first-child), .a4-t.ds-a4t td:not(:first-child) { text-align:right; }
`;

export default DisIcmal;
