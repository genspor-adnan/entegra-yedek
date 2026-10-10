import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { MaliyetIcmali } from '../../api/uclar/maliyetIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { MaliyetA4 } from './MaliyetA4';
import { BasvuruTablosu, BolumTablosu, FaturasizTablosu, HizmetTablosu } from './MaliyetTablolari';

/**
 * HASTA BAŞI MALİYET / SARF İCMALİ `/maliyet-icmali` — mockup Ekranlar/İcmal/
 * hasta_basi_maliyet_icmali.html (kullanıcı 10.10.2026: "hasta başı maliyet
 * icmalini kodla").
 *
 * Başvuru başına ciro ile düşülen sarf / ilaç maliyeti, kâr ve marj; hizmet
 * ve bölüm kârlılığı; faturaya girmemiş sarf; A4. Rakamlar SUNUCUDAN
 * (MaliyetIcmalUclari). Başvuru seçimi tık / Ctrl / Shift (A4'ü süzer).
 */
type Sekme = 'basvuru' | 'hizmet' | 'faturasiz' | 'bolum' | 'onizleme';

export function MaliyetIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const bolum = Number(arama.get('bolum') ?? 0);
  const [veri, setVeri] = useState<MaliyetIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('basvuru');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.maliyetIcmali(bas, bit, bolum).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, bolum]);
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
    ['basvuru', 'Başvurular', veri.basvurular.length], ['hizmet', 'Hizmetler', veri.hizmetler.length],
    ['faturasiz', 'Faturalanmamış Sarf', veri.faturasizSarf.length], ['bolum', 'Bölümler', veri.bolumler.length],
    ['onizleme', '🖨️ Önizleme (A4)', null]] : [];
  const marj = o?.marj != null ? `%${o.marj.toFixed(1).replace('.', ',')}` : '—';

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + MALIYET_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Hasta Başı Maliyet İcmali</h1>
          <span className="yol">Finans › Hasta Başı Maliyet</span>
        </div>
      </div>

      <div className="hi-arac">
        <button className="hi-ana" disabled={!veri} onClick={() => window.print()}>🖨️ Yazdır (A4 Maliyet İcmali)</button>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} başvuruyu listeler</span>}
        <span className="sp" />
        <button onClick={() => git('/hekim-performans')}>🩺 Doktor Performans</button>
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
          <div className="sel">🏥 Bölüm:
            <select value={bolum} onChange={e => degistir({ bolum: e.target.value })}>
              <option value={0}>Tümü</option>
              {veri.bolumAdlari.map(b => <option key={b.id} value={b.id}>{b.ad}</option>)}
            </select>
          </div>
          <span className="sp" />
          {o.maliyetliBasvuru === 0 && o.basvuru > 0 && (
            <span className="bo-rz sari" title="Radyoloji / diş / ameliyat sarf düşümü ya da başvuruda stok satırı yok">
              Bu dönemde sarf / ilaç düşümü yok - marj ciroya eşit görünür</span>
          )}
          {o.zarar > 0 && <span className="bo-rz kir">{o.zarar} başvuru zarar ediyor ({paraYaz(o.zararTutar)})</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Başvuru', String(o.basvuru), `${o.maliyetliBasvuru} maliyetli`)}
          {kutu('Ciro', paraYaz(o.ciro), 'başvuru genel toplamı', 'mor')}
          {kutu('Sarf Maliyeti', paraYaz(o.sarf), 'düşülen malzeme', 'uy')}
          {kutu('İlaç Maliyeti', paraYaz(o.ilac), 'ilaç kataloğuna bağlı stok', 'uy')}
          {kutu('Brüt Kâr', paraYaz(o.kar), `marj ${marj}`, o.kar < 0 ? 'teh' : 'iyi')}
          {kutu('Hasta Başı Maliyet', paraYaz(o.hastaBasi), 'maliyet / başvuru')}
          {kutu('Zarar Eden', String(o.zarar), paraYaz(o.zararTutar), o.zarar ? 'teh' : 'iyi')}
          {kutu('Faturalanmamış Sarf', String(o.faturasizKalem), `maliyet ${paraYaz(o.faturasizMaliyet)}`, o.faturasizKalem ? 'teh' : '')}
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
            {sekme === 'basvuru' && <BasvuruTablosu v={veri} secili={secili} setSecili={setSecili}
                                                    hastaAc={id => git(`/hasta-icmal/${id}?geri=${encodeURIComponent(`/maliyet-icmali?${arama.toString()}`)}`)} />}
            {sekme === 'hizmet' && <HizmetTablosu v={veri} />}
            {sekme === 'faturasiz' && <FaturasizTablosu v={veri} />}
            {sekme === 'bolum' && <BolumTablosu v={veri} />}
            <div className={'hi-onizleme' + (sekme === 'onizleme' ? '' : ' gizli')}>
              <MaliyetA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />
            </div>
          </div>
        </div>
      </>)}
    </div>
  );
}

const MALIYET_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.ml-alt { font-weight:bold; margin:8px 0 2px; }
.a4-t.ml-a4t { font-size:8.5px; margin-bottom:4px; }
.a4-t.ml-a4t th:nth-child(1) { width:24%; } .a4-t.ml-a4t th:nth-child(2) { width:18%; }
`;

export default MaliyetIcmal;
