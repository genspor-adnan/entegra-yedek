import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { IsgIcmali } from '../../api/uclar/isgIcmal';
import { para } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { IsgA4 } from './IsgA4';
import { dk, yuzde } from './isgIcmalOrtak';
import { FirmaTablosu, HizmetTablosu, MuayeneTablosu, OlayTablosu, ZiyaretTablosu } from './IsgTablolari';

/**
 * İSG / OSGB İCMALİ `/isg-icmal` — mockup Ekranlar/İcmal/isg_osgb_icmali.html
 * (kullanıcı 12.10.2026: "icmalleri yap").
 *
 * Firma başına plan / gerçekleşen hizmet süresi, Ek-2 muayene türü ve kanaat,
 * geciken periyodik muayene, ziyaret ve defter imzası, olaylar ve SGK bildirim
 * süresi, hizmet bedeli / fatura / tahsil / sözleşme; A4 çıktı menüsünde.
 * Rakamlar ve toplamlar SUNUCUDAN (IsgIcmalUclari). Firma seçimi diğer
 * sekmeleri ve A4'ü süzer: seçili firmalar için sunucudan ayrı icmal istenir.
 */
type Sekme = 'firma' | 'muayene' | 'ziyaret' | 'olay' | 'hizmet';

export function IsgIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const hekim = Number(arama.get('hekim') ?? 0);
  const tehlike = Number(arama.get('tehlike') ?? 0);
  const [veri, setVeri] = useState<IsgIcmali | null>(null);
  const [secimVeri, setSecimVeri] = useState<IsgIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('firma');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.isgIcmali(bas, bit, hekim, tehlike).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, hekim, tehlike]);
  const seciliAnahtar = secili.join(',');
  useEffect(() => {
    if (!seciliAnahtar) { setSecimVeri(null); return }
    let iptal = false;
    api.isgIcmali(bas, bit, hekim, tehlike, seciliAnahtar.split(',').map(Number))
      .then(v => { if (!iptal) setSecimVeri(v) }).catch(h => setHata(hataMetni(h)));
    return () => { iptal = true };
  }, [bas, bit, hekim, tehlike, seciliAnahtar]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  // Firma sekmesi hep tüm küme; diğer sekmeler ve A4 seçim varsa seçilen firmalar.
  const alt = secili.length ? secimVeri : veri;
  const o = veri?.ozet;
  const ayKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`); const y = new Date(d.getFullYear(), d.getMonth() + n, 1);
    const a = ayAraligi(y.getFullYear(), y.getMonth() + 1); degistir({ bas: a.bas, bit: a.bit });
  };
  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri && alt ? [
    ['firma', 'Firmalar', veri.firmalar.length], ['muayene', 'Muayeneler', alt.ozet.muayene], ['ziyaret', 'Ziyaretler', alt.ozet.ziyaret],
    ['olay', 'Olaylar', alt.olaylar.length], ['hizmet', 'Hizmet Bedeli & Sözleşme', alt.ozet.sozlesme60 || null]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + ISG_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>İSG / OSGB İcmali</h1>
          <span className="yol">İşyeri Hekimliği › İSG / OSGB İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="İSG / OSGB İcmali" dosyaAdi={`İSG OSGB İcmali ${bas} - ${bit}`} devre={!alt}>
          {alt && <IsgA4 v={alt} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">Seçili {secili.length} firma: sekmeler ve A4 bu firmalarla</span>}
        <span className="sp" />
        <button onClick={() => git('/isg-firma')}>🏭 Firmalar</button>
        <button onClick={() => git('/isg-takvim')}>📅 Periyodik Takvim</button>
        <button onClick={() => git('/isg-pano')}>📊 Firma Panosu</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && alt && (<>
        <div className="hi-serit">
          <div className="sel">📅 Dönem:
            <button className="ki-ok" title="Önceki ay" onClick={() => ayKaydir(-1)}>‹</button>
            <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value })} />–
            <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
            <button className="ki-ok" title="Sonraki ay" onClick={() => ayKaydir(1)}>›</button>
          </div>
          <div className="sel">🩺 İşyeri hekimi:
            <select value={hekim} onChange={e => degistir({ hekim: e.target.value })}>
              <option value={0}>Tümü</option>{veri.hekimAdlari.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
            </select>
          </div>
          <div className="sel">⚠ Tehlike sınıfı:
            <select value={tehlike} onChange={e => degistir({ tehlike: e.target.value })}>
              <option value={0}>Tümü</option><option value={1}>Az tehlikeli</option><option value={2}>Tehlikeli</option><option value={3}>Çok tehlikeli</option>
            </select>
          </div>
          <span className="sp" />
          {o.geciken > 0 && <span className="bo-rz kir">{o.geciken} geciken periyodik muayene</span>}
          {o.sureEksikFirma > 0 && <span className="bo-rz sari">{o.sureEksikFirma} firmada süre eksik</span>}
          {o.sozlesme60 > 0 && <span className="bo-rz sari">{o.sozlesme60} sözleşme 60 gün içinde bitiyor</span>}
          {o.sgkGec > 0 && <span className="bo-rz kir">{o.sgkGec} SGK bildirimi geç</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Firma / Çalışan', `${o.firma} / ${o.calisan}`, `${o.cokTehlikeli} çok tehlikeli · ${o.hekim} işyeri hekimi`)}
          {kutu('Hizmet Süresi', yuzde(o.karsilama), `${dk(o.gercekDk)} / ${dk(o.planDk)} dk (plan)`,
                o.karsilama == null ? '' : o.karsilama >= 100 ? 'iyi' : o.karsilama < 85 ? 'teh' : 'uy')}
          {kutu('Muayene', String(o.muayene), `işe giriş ${o.iseGiris} · periyodik ${o.periyodik}`, 'mor')}
          {kutu('Geciken Periyodik', String(o.geciken), `${o.geciken90} çalışan 90+ gün`, o.geciken ? 'teh' : 'iyi')}
          {kutu('Ziyaret', String(o.ziyaret), `${dk(o.ziyaretDk)} dk · ${o.imzaEksik} defter imzası eksik`, o.imzaEksik ? 'uy' : '')}
          {kutu('İş Kazası / MH Şüphesi', `${o.kaza} / ${o.meslekHastaligi}`, `${o.gunKaybi} gün kayıp · ${o.ramakKala} ramak kala`, o.kaza ? 'teh' : '')}
          {kutu('Faturalanan / Tahsil', `${para.format(o.faturalanan)} ₺`, `tahsil ${para.format(o.tahsil)} · açık bakiye ${para.format(o.bakiye)} ₺`)}
          {kutu('Sözleşme Bitişi', String(o.sozlesme60), '60 gün içinde biten firma', o.sozlesme60 ? 'uy' : '')}
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
            {sekme === 'firma' && <FirmaTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'muayene' && <MuayeneTablosu v={alt} />}
            {sekme === 'ziyaret' && <ZiyaretTablosu v={alt} />}
            {sekme === 'olay' && <OlayTablosu v={alt} />}
            {sekme === 'hizmet' && <HizmetTablosu v={alt} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const ISG_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.hi-tablo .bo-rz { white-space:nowrap; }
.bo-rz.mor { background:#f1ebfa; color:#6a3fb5; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-kalite { display:grid; grid-template-columns:1.4fr 1fr; gap:12px; }
.lb-bas { font-weight:bold; margin:10px 0 4px; }
.lb-bas .ki-soluk { font-weight:normal; font-size:11px; }
@media (max-width: 1000px) { .lb-kalite { grid-template-columns:1fr; } }
.a4-t.isg-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.isg-a4t th:nth-child(1), .a4-t.isg-a4t td:nth-child(1) { text-align:left; width:26%; }
.a4-t.isg-a4t th:nth-child(2), .a4-t.isg-a4t td:nth-child(2) { text-align:left; }
`;

export default IsgIcmal;
