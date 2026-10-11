import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CagriIcmali } from '../../api/uclar/cagriIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { CagriA4 } from './CagriA4';
import { dkMetni, sureMetni, yuzde } from './cagriIcmalOrtak';
import { GeriAramaTablosu, KampanyaTablosu, KuyrukTablosu, TemsilciTablosu, YogunlukTablosu } from './CagriTablolari';

/**
 * ÇAĞRI MERKEZİ İCMALİ `/cagri-icmal` — mockup Ekranlar/İcmal/cagri_merkezi_icmali.html
 * (kullanıcı 11.10.2026: "çağrı merkezi icmalini kodla").
 *
 * Kuyruk başına hacim / SLA / bekleme / görüşme / randevuya dönüşme;
 * temsilciler; saat ve gün yoğunluğu; geri arama zamanlaması; kampanyalar;
 * A4 çıktı menüsünde. Rakamlar SUNUCUDAN (CagriIcmalUclari).
 */
type Sekme = 'kuyruk' | 'temsilci' | 'yogunluk' | 'geri' | 'kampanya';

export function CagriIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const kuyruk = Number(arama.get('kuyruk') ?? 0);
  const kanal = Number(arama.get('kanal') ?? 0);
  const [veri, setVeri] = useState<CagriIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('kuyruk');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.cagriIcmali(bas, bit, kuyruk, kanal).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, kuyruk, kanal]);
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
    ['kuyruk', 'Kuyruklar', veri.kuyruklar.length], ['temsilci', 'Temsilciler', veri.temsilciler.length],
    ['yogunluk', 'Saat Yoğunluğu', veri.saatler.length], ['geri', 'Geri Aramalar', veri.ozet.geriGec + veri.ozet.geriYok],
    ['kampanya', 'Kampanyalar', veri.kampanyalar.length]] : [];
  const n = (x: number) => x.toLocaleString('tr-TR');

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + CM_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Çağrı Merkezi İcmali</h1>
          <span className="yol">Çağrı Merkezi › Çağrı Merkezi İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Çağrı Merkezi İcmali" dosyaAdi={`Çağrı Merkezi İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <CagriA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} kuyruğu basar</span>}
        <span className="sp" />
        <button onClick={() => git('/cagri-supervizor')}>📡 Süpervizör Panosu</button>
        <button onClick={() => git('/cagri')}>📋 Çağrılar</button>
        <button onClick={() => git('/cagri-kampanya')}>📣 Kampanyalar</button>
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
          <div className="sel">📥 Kuyruk:
            <select value={kuyruk} onChange={e => degistir({ kuyruk: e.target.value })}>
              <option value={0}>Tümü</option>
              {veri.kuyrukAdlari.map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
            </select>
          </div>
          <div className="sel">☎ Kanal:
            <select value={kanal} onChange={e => degistir({ kanal: e.target.value })}>
              <option value={0}>Tümü</option><option value={1}>Telefon</option><option value={2}>WhatsApp</option>
              <option value={3}>SMS</option><option value={4}>Web formu</option><option value={5}>E-posta</option>
            </select>
          </div>
          <span className="sp" />
          <span className={'bo-rz ' + ((o.sla ?? 0) >= o.slaHedef ? 'ok' : 'kir')}>SLA {yuzde(o.sla)} (hedef %{o.slaHedef})</span>
          {(o.geriGec + o.geriYok) > 0 && <span className="bo-rz sari">{o.geriGec} geri arama gecikti · {o.geriYok} yapılmadı</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Gelen Arama', n(o.gelen), `telefon ${n(o.telefon)} · WhatsApp ${n(o.whatsapp)}${o.digerKanal ? ` · diğer ${o.digerKanal}` : ''}`)}
          {kutu('Cevaplanan', n(o.cevaplanan), `${yuzde(o.cevapOrani)} · SLA ${yuzde(o.sla)}`, (o.sla ?? 0) >= o.slaHedef ? 'iyi' : 'teh')}
          {kutu('Terk / Sesli', `${o.terk} / ${o.sesli}`, `terk ${yuzde(o.gelen ? 100 * o.terk / o.gelen : null)} · sesli mesaj / mesai dışı`, o.terk ? 'uy' : '')}
          {kutu('Ort. Bekleme', sureMetni(o.ortBekleme), `en uzun ${sureMetni(o.enUzunBekleme)}`)}
          {kutu('Ort. Görüşme', sureMetni(o.ortGorusme), `işlem sonrası ort. ${sureMetni(o.ortIslemSonrasi)}`)}
          {kutu('Randevuya Dönüşme', yuzde(o.donusum), `${o.randevu} randevu / ${n(o.cevaplanan)} cevaplanan`, 'mor')}
          {kutu('Geri Arama Zamanında', yuzde(o.geriOran), `${o.geriZamaninda} / ${o.geriIstek} istek · hedef ${dkMetni(o.hedefDk)}`, o.geriYok ? 'teh' : '')}
          {kutu('Giden Arama', n(o.giden), `geri arama ${o.gidenGeriArama} · kampanya ${o.gidenKampanya}`)}
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <div className="katab">
              {sekmeler.map(([k, ad, x]) => (
                <div key={k} className={'kat' + (sekme === k ? ' on' : '')} onClick={() => setSekme(k)}>
                  {ad}{x != null && <span className="b">{x}</span>}
                </div>
              ))}
            </div>
            {sekme === 'kuyruk' && <KuyrukTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'temsilci' && <TemsilciTablosu v={veri} />}
            {sekme === 'yogunluk' && <YogunlukTablosu v={veri} />}
            {sekme === 'geri' && <GeriAramaTablosu v={veri} />}
            {sekme === 'kampanya' && <KampanyaTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const CM_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-bar { display:inline-block; width:90px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-kalite { display:grid; grid-template-columns:3fr 2fr; gap:12px; }
.lb-bas { font-weight:bold; margin:10px 0 4px; }
@media (max-width: 1000px) { .lb-kalite { grid-template-columns:1fr; } }
.a4-t.cm-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.cm-a4t th:nth-child(1), .a4-t.cm-a4t td:nth-child(1) { text-align:left; width:24%; }
.a4-t.cm-a4t th:nth-child(2), .a4-t.cm-a4t td:nth-child(2) { text-align:right; }
`;

export default CagriIcmal;
