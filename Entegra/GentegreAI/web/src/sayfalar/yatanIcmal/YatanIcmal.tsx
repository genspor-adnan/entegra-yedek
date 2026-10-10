import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { YatanIcmali } from '../../api/uclar/yatanIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { YatanA4 } from './YatanA4';
import { gunMetni } from './yatanIcmalOrtak';
import { AcikHesapTablosu, ServisTablosu, TaniDoktorTablosu, YatakKullanimTablosu, YatisTablosu } from './YatanTablolari';

/**
 * YATAN HASTA / SERVİS DÖNEM İCMALİ `/yatan-icmal` — mockup Ekranlar/İcmal/
 * yatan_hasta_icmali.html (kullanıcı 10.10.2026: "yatan hasta icmalini kodla").
 *
 * Servis başına yatış, taburcu, hasta-gün, doluluk, ALOS, ciro; açık
 * hesaplar; haftalık doluluk; tanı / doktor; A4 çıktı menüsünde. Rakamlar
 * SUNUCUDAN (YatanDonemIcmalUclari) - tutarlar yatış hizmet icmaliyle aynı kural.
 */
type Sekme = 'servis' | 'yatis' | 'acik' | 'yatak' | 'tani';

export function YatanIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const servis = Number(arama.get('servis') ?? 0);
  const [veri, setVeri] = useState<YatanIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('servis');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.yatanIcmali(bas, bit, servis).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, servis]);
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
    ['servis', 'Servisler', veri.servisler.length], ['yatis', 'Yatışlar', veri.yatislar.length],
    ['acik', 'Açık Hesaplar', veri.acikHesaplar.length], ['yatak', 'Yatak Kullanımı', null], ['tani', 'Tanı / Doktor', null]] : [];
  const yuzde = (d: number | null | undefined) => (d == null ? '—' : `%${d.toFixed(1).replace('.', ',')}`);

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + YH_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Yatan Hasta İcmali</h1>
          <span className="yol">Yatan Hasta › Dönem İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Yatan Hasta İcmali" dosyaAdi={`Yatan Hasta İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <YatanA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} servisi basar</span>}
        <span className="sp" />
        <button onClick={() => git('/yatak')}>🗺️ Yatak Panosu</button>
        <button onClick={() => git('/yatan')}>🛏️ Yatan Hastalar</button>
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
          <div className="sel">🏥 Servis:
            <select value={servis} onChange={e => degistir({ servis: e.target.value })}>
              <option value={0}>Tümü</option>
              {veri.servisAdlari.map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
            </select>
          </div>
          <span className="sp" />
          {o.acikAdet > 0 && <span className="bo-rz kir">{o.acikAdet} açık hesaplı taburcu</span>}
          {veri.uzunYatis > 0 && <span className="bo-rz sari">{veri.uzunYatis} yatış 30+ gün</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Yatış / Taburcu', `${o.yatis} / ${o.taburcu}`, `dönemde kabul / çıkış · ${o.yatiyor} yatıyor`)}
          {kutu('Yatak Doluluğu', yuzde(o.doluluk), `${o.hastaGun} hasta-gün / ${v_yatakGun(veri)} yatak-gün`, (o.doluluk ?? 0) >= 85 ? 'teh' : '')}
          {kutu('Ort. Yatış Günü', `${gunMetni(o.alos)} gün`, `ALOS · ${o.taburcu} taburcu`)}
          {kutu('Hasta-Gün', String(o.hastaGun), `${veri.toplamYatak} yatak · ${veri.donem.gun} gün`)}
          {kutu('Ciro', paraYaz(o.ciro), `dönem hizmetleri · gün başı ${paraYaz(o.gunBasi)}`, 'mor')}
          {kutu('Kurum / Hasta Payı', paraYaz(o.kurum), `hasta payı ${paraYaz(o.hasta)}`)}
          {kutu('Açık Hesap', paraYaz(o.acikTutar), `${o.acikAdet} taburcu · hesap kapanmadı`, o.acikAdet ? 'teh' : 'iyi')}
          {kutu('Yatak Devir Hızı', gunMetni(veri.devirHizi), `taburcu / yatak · ${veri.tekrarYatis} tekrar yatış (30 gün)`)}
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
            {sekme === 'servis' && <ServisTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'yatis' && <YatisTablosu v={veri} />}
            {sekme === 'acik' && <AcikHesapTablosu v={veri} />}
            {sekme === 'yatak' && <YatakKullanimTablosu v={veri} />}
            {sekme === 'tani' && <TaniDoktorTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

/** Yatak-gün = aktif yatak × dönem günü (doluluğun paydası). */
const v_yatakGun = (v: YatanIcmali) => v.toplamYatak * v.donem.gun;

const YH_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.lb-k { margin-left:6px; font-size:10px; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-asim { color:#b42318; }
.lb-bar { display:inline-block; width:70px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-kalite { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.lb-bas { font-weight:bold; margin:6px 0 4px; }
@media (max-width: 900px) { .lb-kalite { grid-template-columns:1fr; } }
.hi-tablo td.yk-kir { background:#f8d7d4; color:#8c1d14; font-weight:bold; }
.hi-tablo td.yk-sari { background:#fdf1d8; }
.hi-tablo td.yk-yesil { background:#e6f4ea; }
.a4-t.yh-a4t { font-size:8.5px; }
.a4-t.yh-a4t th:nth-child(1), .a4-t.yh-a4t td:nth-child(1) { text-align:left; width:22%; }
.a4-t.yh-a4t th:nth-child(2), .a4-t.yh-a4t td:nth-child(2) { text-align:right; width:8%; }
`;

export default YatanIcmal;
