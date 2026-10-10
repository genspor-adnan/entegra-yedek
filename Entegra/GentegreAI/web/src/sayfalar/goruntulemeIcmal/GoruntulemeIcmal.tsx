import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { GoruntulemeIcmali } from '../../api/uclar/goruntulemeIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { sure, yuzde } from '../labIcmal/labIcmalOrtak';
import { ayAraligi } from '../performans/performansOrtak';
import { GoruntulemeA4 } from './GoruntulemeA4';
import { CihazTablosu, ModaliteTablosu, RaporlayanTablosu, TeleradTablosu, TetkikTablosu } from './GoruntulemeTablolari';

/**
 * GÖRÜNTÜLEME (RADYOLOJİ) İCMALİ `/goruntuleme-icmal` — mockup Ekranlar/İcmal/
 * goruntuleme_icmali.html (kullanıcı 10.10.2026: "görüntüleme icmalini kodla").
 *
 * Modalite / tetkik başına çekim, ciro, kontrast / sarf maliyeti, marj;
 * raporlayanlar ve rapor süresi; cihaz doluluğu; teleradyoloji giden / gelen;
 * A4. Rakamlar SUNUCUDAN (GoruntulemeIcmalUclari).
 */
type Sekme = 'modalite' | 'tetkik' | 'raporlayan' | 'cihaz' | 'telerad' | 'onizleme';

export function GoruntulemeIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const modalite = Number(arama.get('modalite') ?? 0);
  const raporlayan = Number(arama.get('raporlayan') ?? 0);
  const [veri, setVeri] = useState<GoruntulemeIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('modalite');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.goruntulemeIcmali(bas, bit, modalite, raporlayan).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, modalite, raporlayan]);
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
    ['modalite', 'Modaliteler', veri.modaliteler.length], ['tetkik', 'Tetkikler', veri.tetkikler.length],
    ['raporlayan', 'Raporlayanlar', veri.raporlayanlar.length], ['cihaz', 'Cihazlar', veri.cihazlar.length],
    ['telerad', 'Teleradyoloji', veri.teleradGiden.length + veri.teleradGelen.length], ['onizleme', '🖨️ Önizleme (A4)', null]] : [];
  const suzgec = [modalite ? veri?.modaliteAdlari.find(m => m.id === modalite)?.ad : '',
                  raporlayan === 1 ? 'İç raporlanan' : raporlayan === 2 ? 'Teleradyoloji' : ''].filter(Boolean).join(' · ') || 'Tüm modaliteler';

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + GR_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Görüntüleme İcmali</h1>
          <span className="yol">Radyoloji › Görüntüleme İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <button className="hi-ana" disabled={!veri} onClick={() => window.print()}>🖨️ Yazdır (A4 Görüntüleme İcmali)</button>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} modaliteyi listeler</span>}
        <span className="sp" />
        <button onClick={() => git('/radyoloji-pano')}>📊 Radyoloji Pano</button>
        <button onClick={() => git('/telerad-fatura')}>🧾 Teleradyoloji Dönem Faturası</button>
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
          <div className="sel">🩻 Modalite:
            <select value={modalite} onChange={e => degistir({ modalite: e.target.value })}>
              <option value={0}>Tümü</option>
              {veri.modaliteAdlari.map(m => <option key={m.id} value={m.id}>{m.ad}</option>)}
            </select>
          </div>
          <div className="sel">👤 Raporlayan:
            <select value={raporlayan} onChange={e => degistir({ raporlayan: e.target.value })}>
              <option value={0}>Tümü</option><option value={1}>İç radyolog</option><option value={2}>Teleradyoloji</option>
            </select>
          </div>
          <span className="sp" />
          {o.bekleyen > 0 && <span className="bo-rz sari">{o.bekleyen} çekim rapor bekliyor</span>}
          {o.asan > 0 && <span className="bo-rz kir">{o.asan} rapor hedef süreyi aştı</span>}
          {o.cekim > 0 && o.sarfsiz === o.cekim && (
            <span className="bo-rz pas" title="Bu dönemde radyoloji sarf düşümü yok - marj ciroya eşit görünür">sarf düşümü yok</span>
          )}
        </div>

        <div className="hi-ozet">
          {kutu('Çekim', String(o.cekim), `${o.hasta} hasta${o.faturasiz ? ` · ${o.faturasiz} faturasız` : ''}`)}
          {kutu('Ciro', paraYaz(o.ciro), 'başvuru satır tutarı', 'mor')}
          {kutu('Kurum / Hasta Payı', paraYaz(o.kurum), `kurum %${o.ciro > 0 ? Math.round(100 * o.kurum / o.ciro) : 0} · hasta ${paraYaz(o.hastaPayi)}`)}
          {kutu('Kontrast + Sarf', paraYaz(o.sarf), `${o.kontrastli} kontrastlı çekim`, 'uy')}
          {kutu('Brüt Kâr', paraYaz(o.kar), `marj ${yuzde(o.marj)}`, o.kar < 0 ? 'teh' : 'iyi')}
          {kutu('Ort. Rapor Süresi', sure(o.ortRapor), `${o.asan} hedef aşan · hedef ${sure(o.hedefRutin)}`, o.asan ? 'teh' : '')}
          {kutu('Teleradyoloji', `${o.teleradNet < 0 ? '−' : ''}${paraYaz(Math.abs(o.teleradNet))}`,
                `giden ${o.giden} · gelen ${o.gelen} çekim`, o.teleradNet < 0 ? 'teh' : '')}
          {kutu('Cihaz Doluluğu', yuzde(o.doluluk), o.cihazsiz ? `${o.cihazsiz} çekimde cihaz yok` : 'kullanım / kapasite')}
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
            {sekme === 'modalite' && <ModaliteTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'tetkik' && <TetkikTablosu v={veri} />}
            {sekme === 'raporlayan' && <RaporlayanTablosu v={veri} />}
            {sekme === 'cihaz' && <CihazTablosu v={veri} />}
            {sekme === 'telerad' && <TeleradTablosu v={veri} />}
            <div className={'hi-onizleme' + (sekme === 'onizleme' ? '' : ' gizli')}>
              <GoruntulemeA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} suzgec={suzgec} />
            </div>
          </div>
        </div>
      </>)}
    </div>
  );
}

const GR_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.lb-k { margin-left:6px; font-size:10px; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-asim { color:#b42318; }
.lb-bar { display:inline-block; width:110px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-kalite { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.lb-bas { font-weight:bold; margin:10px 0 4px; }
@media (max-width: 900px) { .lb-kalite { grid-template-columns:1fr; } }
.a4-t.lb-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.lb-a4t th:nth-child(1), .a4-t.lb-a4t td:nth-child(1) { text-align:left; width:18%; }
`;

export default GoruntulemeIcmal;
