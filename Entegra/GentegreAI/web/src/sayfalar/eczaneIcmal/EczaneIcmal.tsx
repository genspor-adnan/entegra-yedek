import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { EczaneIcmali } from '../../api/uclar/eczaneIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { EczaneA4 } from './EczaneA4';
import { adet, yuzde } from './eczaneIcmalOrtak';
import { FaturasizTablosu, IlacTablosu, ItsTablosu, MiadIadeTablosu, ServisTablosu } from './EczaneTablolari';

/**
 * ECZANE / İLAÇ TÜKETİM İCMALİ `/eczane-icmal` — mockup Ekranlar/İcmal/eczane_ilac_icmali.html
 * (kullanıcı 12.10.2026: "icmalleri yap").
 *
 * Servis ve ilaç başına tüketim / maliyet / faturalanan / faturalanmayan;
 * miad ve iade; İTS bildirimleri; A4 çıktı menüsünde. Rakamlar ve toplamlar
 * SUNUCUDAN (EczaneIcmalUclari). Hasta adı gösterilmez, protokol no gösterilir.
 */
type Sekme = 'servis' | 'ilac' | 'faturasiz' | 'miad' | 'its';

export function EczaneIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const servis = Number(arama.get('servis') ?? 0);
  const depo = Number(arama.get('depo') ?? 0);
  const [veri, setVeri] = useState<EczaneIcmali | null>(null);
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
    api.eczaneIcmali(bas, bit, servis, depo).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, servis, depo]);
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
    ['servis', 'Servisler', veri.servisler.length], ['ilac', 'İlaçlar', veri.ilaclar.length],
    ['faturasiz', 'Faturalanmayan', veri.faturasiz.length], ['miad', 'Miad / İade', veri.miad.length + veri.iadeler.length],
    ['its', 'İTS Bildirimleri', veri.ozet.itsHatali]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + EC_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Eczane / İlaç Tüketim İcmali</h1>
          <span className="yol">Eczane › Eczane / İlaç İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="İlaç Tüketim İcmali" dosyaAdi={`İlaç Tüketim İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <EczaneA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} servisi basar</span>}
        <span className="sp" />
        <button onClick={() => git('/eczane-miad')}>📦 Miad & Tüketim</button>
        <button onClick={() => git('/its-bildirim')}>🔗 İTS Bildirimleri</button>
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
          <div className="sel">🛏 Servis:
            <select value={servis} onChange={e => degistir({ servis: e.target.value })}>
              <option value={0}>Tümü</option>{veri.servisAdlari.map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
            </select>
          </div>
          <div className="sel" title="Miad listesini depoya süzer">💊 Depo:
            <select value={depo} onChange={e => degistir({ depo: e.target.value })}>
              <option value={0}>Tümü</option>{veri.depoAdlari.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}
            </select>
          </div>
          <span className="sp" />
          {o.faturalanmayan > 0 && <span className="bo-rz kir">{paraYaz(o.faturalanmayan)} faturalanmamış ilaç</span>}
          {o.miadDolmus > 0 && <span className="bo-rz kir">{o.miadDolmus} lot miadı doldu</span>}
          {o.itsHatali > 0 && <span className="bo-rz sari">{o.itsHatali} İTS hatası</span>}
        </div>

        <div className="hi-ozet">
          {kutu('İlaç Çıkışı', adet(o.cikis), `${o.kalem} servis × ilaç kalemi · ${o.ilac} ilaç`)}
          {kutu('Maliyet', paraYaz(o.maliyet), 'çıkış × stok maliyeti', 'mor')}
          {kutu('Faturalanan', paraYaz(o.faturalanan), `${yuzde(o.faturaAdetOrani)} adet faturada`)}
          {kutu('Faturalanmayan (Kaçak)', paraYaz(o.faturalanmayan), `${adet(o.faturalanmayanAdet)} adet · ${o.faturalanmayanKayit} kayıt`,
                o.faturalanmayan > 0 ? 'teh' : 'iyi')}
          {kutu('Hasta Başı İlaç', paraYaz(o.hastaBasi), `maliyet / ${o.hasta} hasta`)}
          {kutu('Miad', `${o.miadDolmus} / ${o.miad30}`, `dolmuş ${paraYaz(o.miadDolmusTutar)} · 30 gün içinde ${paraYaz(o.miad30Tutar)}`,
                o.miadDolmus ? 'teh' : o.miad30 ? 'uy' : '')}
          {kutu('İTS Bildirimi', String(o.itsBildirim), `${o.itsHatali} hatalı · ${o.itsBekleyen} bekliyor`, o.itsHatali ? 'uy' : '')}
          {kutu('İade', paraYaz(o.iade), `${adet(o.iadeAdet)} adet · imha ${paraYaz(o.imha)}`)}
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
            {sekme === 'ilac' && <IlacTablosu v={veri} />}
            {sekme === 'faturasiz' && <FaturasizTablosu v={veri} basvuruAc={id => git(`/basvuru/${id}?geri=${encodeURIComponent('/eczane-icmal')}`)} />}
            {sekme === 'miad' && <MiadIadeTablosu v={veri} />}
            {sekme === 'its' && <ItsTablosu v={veri} itsAc={() => git('/its-bildirim')} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const EC_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.lb-k { margin-left:6px; font-size:10px; }
.hi-tablo .bo-rz { white-space:nowrap; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-bar { display:inline-block; width:70px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-kalite { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.lb-bas { font-weight:bold; margin:10px 0 4px; }
@media (max-width: 1000px) { .lb-kalite { grid-template-columns:1fr; } }
.a4-t.ec-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.ec-a4t th:nth-child(1), .a4-t.ec-a4t td:nth-child(1) { text-align:left; width:30%; }
.a4-t.ec-a4t th:not(:first-child), .a4-t.ec-a4t td:not(:first-child) { text-align:right; }
`;

export default EczaneIcmal;
