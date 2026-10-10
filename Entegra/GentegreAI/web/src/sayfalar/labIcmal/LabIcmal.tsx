import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { LabIcmali } from '../../api/uclar/labIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { LabA4 } from './LabA4';
import { sure, yuzde } from './labIcmalOrtak';
import { CihazTablosu, DisLabTablosu, GrupTablosu, KaliteTablosu, TetkikTablosu } from './LabTablolari';

/**
 * LABORATUVAR İCMALİ `/lab-icmal` — mockup Ekranlar/İcmal/laboratuvar_icmali.html
 * (kullanıcı 10.10.2026: "laboratuvar icmalini kodla").
 *
 * Tetkik başına adet, ciro, kurum / hasta payı, reaktif maliyeti, marj;
 * tetkik grupları, cihazlar, dış laboratuvar kârlılığı, sonuç süresi ve
 * numune ret; A4. Rakamlar SUNUCUDAN (LabIcmalUclari). Reaktif maliyeti
 * tetkik kartındaki "Test Başı Maliyet" alanından gelir.
 */
type Sekme = 'tetkik' | 'grup' | 'cihaz' | 'dis' | 'kalite';

export function LabIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const grup = Number(arama.get('grup') ?? 0);
  const bolum = Number(arama.get('bolum') ?? 0);
  const [veri, setVeri] = useState<LabIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('tetkik');
  const [secili, setSecili] = useState<string[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.labIcmali(bas, bit, grup, bolum).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, grup, bolum]);
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
    ['tetkik', 'Tetkikler', veri.tetkikler.length], ['grup', 'Tetkik Grupları', veri.gruplar.length],
    ['cihaz', 'Cihazlar', veri.cihazlar.length], ['dis', 'Dış Laboratuvar', veri.disLablar.length],
    ['kalite', 'Kalite / Süre', veri.ozet.asan]] : [];
  const suzgec = [grup ? veri?.grupAdlari.find(g => g.id === grup)?.ad : '', bolum ? veri?.bolumAdlari.find(b => b.id === bolum)?.ad : '']
    .filter(Boolean).join(' · ') || 'Tüm tetkikler';

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + LAB_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Laboratuvar İcmali</h1>
          <span className="yol">Laboratuvar › Laboratuvar İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        {/* ÇIKTI MENÜSÜ: Baskı Önizleme / Yazıcıya Yazdır / Gönder ▸ - A4 menünün içinde, ayrı önizleme sekmesi yok. */}
        <CiktiMenusu etiket="Laboratuvar İcmali" dosyaAdi={`Laboratuvar İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <LabA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} suzgec={suzgec} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} tetkiki de listeler</span>}
        <span className="sp" />
        <button onClick={() => git('/lab-tetkik')}>📚 Tetkik Kataloğu</button>
        <button onClick={() => git('/lab-dis-gonderim')}>🏍️ Dış Lab Gönderimleri</button>
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
          <div className="sel">🏥 İsteyen Bölüm:
            <select value={bolum} onChange={e => degistir({ bolum: e.target.value })}>
              <option value={0}>Tümü</option>
              {veri.bolumAdlari.map(b => <option key={b.id} value={b.id}>{b.ad}</option>)}
            </select>
          </div>
          <div className="sel">🧪 Tetkik Grubu:
            <select value={grup} onChange={e => degistir({ grup: e.target.value })}>
              <option value={0}>Tümü</option>
              {veri.grupAdlari.map(g => <option key={g.id} value={g.id}>{g.ad}</option>)}
            </select>
          </div>
          <span className="sp" />
          {o.maliyetsiz > 0 && (
            <span className="bo-rz sari" title="Tetkik kartında 'Test Başı Maliyet' boş - bu kalemlerin maliyeti 0 sayıldı, marj yüksek görünür">
              {o.maliyetsiz} kalemde test başı maliyet tanımsız</span>
          )}
          {o.zarardaDisLab > 0 && <span className="bo-rz kir">{o.zarardaDisLab} dış lab zarar ediyor</span>}
          {o.asan > 0 && <span className="bo-rz sari">{o.asan} tetkik hedef süreyi aştı</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Tetkik', String(o.tetkik), `${o.hasta} hasta · ${o.istem} istem`)}
          {kutu('Ciro', paraYaz(o.ciro), o.faturasiz ? `${o.faturasiz} kalem faturasız` : 'başvuru satır tutarı', 'mor')}
          {kutu('Kurum / Hasta Payı', paraYaz(o.kurum), `hasta payı ${paraYaz(o.hastaPayi)}`)}
          {kutu('Reaktif / Kit', paraYaz(o.reaktif), 'iç lab · tekrarlar dahil', 'uy')}
          {kutu('Brüt Kâr', paraYaz(o.kar), `marj ${yuzde(o.marj)}`, o.kar < 0 ? 'teh' : 'iyi')}
          {kutu('Dış Lab', `${o.disAdet} test`, `maliyet ${paraYaz(o.disMaliyet)} · fatura ${paraYaz(o.disCiro)}`)}
          {kutu('Tekrar / Ret', `${yuzde(o.tekrarOrani)} / ${yuzde(o.retOrani)}`, `${o.tekrar} tekrar · ${o.ret} ret numune`)}
          {kutu('Ort. Sonuç Süresi', sure(o.ortTat), `rutin · ${o.asan} tetkik hedefi aştı`, o.asan ? 'teh' : '')}
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
            {sekme === 'tetkik' && <TetkikTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'grup' && <GrupTablosu v={veri} />}
            {sekme === 'cihaz' && <CihazTablosu v={veri} />}
            {sekme === 'dis' && <DisLabTablosu v={veri} />}
            {sekme === 'kalite' && <KaliteTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const LAB_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.lb-k { margin-left:6px; font-size:10px; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-zarar td { color:#b42318; }
.lb-asim { color:#b42318; }
.lb-bar { display:inline-block; width:110px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-kalite { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.lb-kalite .lb-genis { grid-column:1 / -1; }
.lb-bas { font-weight:bold; margin:6px 0 4px; }
@media (max-width: 900px) { .lb-kalite { grid-template-columns:1fr; } }
.a4-t.lb-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.lb-a4t th:nth-child(1), .a4-t.lb-a4t td:nth-child(1) { text-align:left; width:30%; }
`;

export default LabIcmal;
