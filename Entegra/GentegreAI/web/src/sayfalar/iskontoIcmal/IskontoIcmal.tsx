import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { IskontoIcmali } from '../../api/uclar/iskontoIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { IskontoIcmalA4 } from './IskontoIcmalA4';
import { GrupTablosu, IskontoTablosu, RedTablosu, UcretsizTablosu } from './IskontoIcmalTablolari';
import { KAYNAKLAR, oranMetni } from './iskontoIcmalOrtak';

/**
 * İSKONTO VE ÜCRETSİZ HİZMET İCMALİ `/iskonto-icmali` — mockup Ekranlar/İcmal/
 * iskonto_icmali.html (kullanıcı 10.10.2026: "iskonto İcmali ayrı olsun",
 * "iskonto icmalini kodla"). İskonto Onayı'ndan AYRI ekran: o kuyruk ve
 * karar içindir, bu dönem sonu denetim raporudur.
 *
 * Dönemde verilen bütün iskontolar (onaylı talep, kampanya, bankonun
 * talepsiz verdiği), ücretsiz hizmetler, reddedilen talepler; onaylayana /
 * verene / gerekçeye göre; eşik üstü talepsiz iskonto uyarısı; A4.
 * Rakamlar SUNUCUDAN (IskontoIcmalUclari).
 */
type Sekme = 'isk' | 'onaylayan' | 'veren' | 'gerekce' | 'ucretsiz' | 'red';

export function IskontoIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const kaynak = arama.get('kaynak') ?? 'hepsi';
  const [veri, setVeri] = useState<IskontoIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('isk');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== 'hepsi') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.iskontoIcmali(bas, bit, kaynak, 0).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, kaynak]);
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
    ['isk', 'İskontolar', veri.basvurular.length], ['onaylayan', 'Onaylayana Göre', veri.onaylayanaGore.length],
    ['veren', 'Verene Göre', veri.verenGore.length], ['gerekce', 'Gerekçeye Göre', veri.gerekceGore.length],
    ['ucretsiz', 'Ücretsiz Hizmetler', veri.ucretsizler.length], ['red', 'Reddedilen Talepler', veri.redler.length]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + ISKONTO_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>İskonto İcmali</h1>
          <span className="yol">Kayıt Kabul › İskonto İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        {/* ÇIKTI MENÜSÜ (test, 10.10.2026): Baskı Önizleme / Yazıcıya Yazdır / Gönder ▸ -
              A4 belgesi menünün içinde yaşar, ayrı "Önizleme" sekmesi yok. */}
        <CiktiMenusu etiket="İskonto İcmali" dosyaAdi={`İskonto İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <IskontoIcmalA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 yalnız seçili {secili.length} başvuruyu basar</span>}
        <span className="sp" />
        <button onClick={() => git('/iskonto-onay')}>✅ İskonto Onayı</button>
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
          <div className="sel">🏷 Kaynak:
            <select value={kaynak} onChange={e => degistir({ kaynak: e.target.value })}>
              {KAYNAKLAR.map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
            </select>
          </div>
          <span className="sp" />
          {o.esikUstu > 0 && <span className="bo-rz kir" title="Bankonun talepsiz verdiği, onay eşiğini aşan iskonto">⚠ {o.esikUstu} başvuruda eşik (%{o.esik}) üstü talepsiz iskonto</span>}
          <span className="ki-soluk">Onay eşiği %{o.esik} (Kayıt Kabul ayarı)</span>
        </div>

        <div className="hi-ozet">
          {kutu('İskontolu Başvuru', String(o.basvuru), `${o.red} talep reddedildi`)}
          {kutu('Toplam İskonto', paraYaz(o.iskonto), `ort. ${oranMetni(o.ortOran)}`, 'uy')}
          {kutu('Onaylı Talep', paraYaz(o.talepli), 'İskonto Onayı\'ndan', 'iyi')}
          {kutu('Banko (Talepsiz)', paraYaz(o.banko), o.esikUstu ? `⚠ ${o.esikUstu} eşik üstü` : 'eşik içinde', o.esikUstu ? 'teh' : '')}
          {kutu('Kampanya', paraYaz(o.kampanya), 'kampanya satırları', 'mor')}
          {kutu('Ücretsiz Hizmet', paraYaz(o.ucretsiz), `${o.ucretsizKalem} kalem · liste fiyatı`)}
          {kutu('Personel / Yakın', paraYaz(o.personel), 'gerekçesi personel olan')}
          {kutu('Ciroya Oranı', `%${o.ciroOrani.toFixed(2).replace('.', ',')}`, `${paraYaz(o.iskonto + o.ucretsiz)} / ${paraYaz(o.ciro)}`, 'teh')}
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
            {sekme === 'isk' && <IskontoTablosu v={veri} secili={secili} setSecili={setSecili}
                                                hastaAc={id => git(`/hasta-icmal/${id}?geri=${encodeURIComponent(`/iskonto-icmali?${arama.toString()}`)}`)} />}
            {sekme === 'onaylayan' && <GrupTablosu baslik="Onaylayan" gruplar={veri.onaylayanaGore} bos="Bu dönemde onaylı iskonto talebi yok." />}
            {sekme === 'veren' && <GrupTablosu baslik="Veren / İsteyen" gruplar={veri.verenGore} bos="Bu dönemde iskonto yok." />}
            {sekme === 'gerekce' && <GrupTablosu baslik="Gerekçe" gruplar={veri.gerekceGore} bos="Bu dönemde iskonto yok." />}
            {sekme === 'ucretsiz' && <UcretsizTablosu v={veri} />}
            {sekme === 'red' && <RedTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const ISKONTO_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; }
.a4-t.ii-a4t { font-size:8.5px; }
.a4-t.ii-a4t th:nth-child(1) { width:10%; } .a4-t.ii-a4t th:nth-child(2) { width:14%; } .a4-t.ii-a4t th:nth-child(3) { width:20%; }
.a4-t.ii-a4t th:nth-child(4) { width:24%; }
.a4-t.ii-a4t th:nth-child(-n+5), .a4-t.ii-a4t td:nth-child(-n+5) { text-align:left; }
`;

export default IskontoIcmal;
