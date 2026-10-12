import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { RandevuIcmali } from '../../api/uclar/randevuIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { RandevuA4 } from './RandevuA4';
import { dakika, sayi, yuzde } from './randevuIcmalOrtak';
import { GelmeyenTablosu, GunSaatTablosu, HekimTablosu, KanalTablosu, PoliklinikTablosu } from './RandevuTablolari';

/**
 * RANDEVU / POLİKLİNİK İCMALİ `/randevu-icmal` — mockup Ekranlar/İcmal/randevu_poliklinik_icmali.html
 * (kullanıcı 12.10.2026: "icmalleri yap").
 *
 * Verilen / gelen / gelmeyen / iptal randevu; poliklinik ve hekim başına slot
 * doluluğu (çalışma planı); kanallar; gün × saat; bekleme; gelmeyenler; A4 çıktı
 * menüsünde. Rakamlar SUNUCUDAN (RandevuIcmalUclari).
 */
type Sekme = 'poliklinik' | 'hekim' | 'kanal' | 'gunsaat' | 'gelmeyen';

export function RandevuIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const bolum = Number(arama.get('bolum') ?? 0);
  const hekim = Number(arama.get('hekim') ?? 0);
  const kanal = Number(arama.get('kanal') ?? 0);
  const tip = Number(arama.get('tip') ?? 0);
  const [veri, setVeri] = useState<RandevuIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('poliklinik');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.randevuIcmali(bas, bit, { bolum, hekim, kanal, tip }).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, bolum, hekim, kanal, tip]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const ayKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`); const y = new Date(d.getFullYear(), d.getMonth() + n, 1);
    const a = ayAraligi(y.getFullYear(), y.getMonth() + 1); degistir({ bas: a.bas, bit: a.bit });
  };
  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const secim = (ad: string, k: string, deger: number, liste: { id: number; ad: string }[]) => (
    <div className="sel">{ad}:
      <select value={deger} onChange={e => degistir({ [k]: e.target.value })}>
        <option value={0}>Tümü</option>{liste.map(x => <option key={x.id} value={x.id}>{x.ad}</option>)}
      </select>
    </div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['poliklinik', 'Poliklinikler', veri.poliklinikler.length], ['hekim', 'Hekimler', veri.hekimler.length], ['kanal', 'Kanallar', veri.kanallar.length],
    ['gunsaat', 'Gün / Saat', null], ['gelmeyen', 'Gelmeyenler', veri.ozet.gelmeyenToplam]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + RP_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Randevu / Poliklinik İcmali</h1>
          <span className="yol">Randevu › Randevu / Poliklinik İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Poliklinik İcmali" dosyaAdi={`Randevu Poliklinik İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <RandevuA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} polikliniği basar</span>}
        <span className="sp" />
        <button onClick={() => git('/randevu')}>📅 Randevular</button>
        <button onClick={() => git('/calisma-plani')}>🗓 Çalışma Planı</button>
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
          {secim('🏥 Poliklinik', 'bolum', bolum, veri.bolumAdlari)}
          {secim('🩺 Hekim', 'hekim', hekim, veri.hekimAdlari)}
          {secim('📲 Kanal', 'kanal', kanal, veri.kanalAdlari)}
          {secim('🔖 Tip', 'tip', tip, veri.tipAdlari)}
          <span className="sp" />
          {o.noShow != null && <span className={'bo-rz ' + (o.noShow > 10 ? 'sari' : 'ok')}>gelmeme {yuzde(o.noShow)}</span>}
          {o.ucuncuGelmeme > 0 && <span className="bo-rz kir">{o.ucuncuGelmeme} randevu: hasta 3. kez gelmedi</span>}
          {o.bekleyen > 0 && <span className="bo-rz sari">{o.bekleyen} randevu sonuçlanmamış</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Verilen Randevu', sayi(o.verilen), `${sayi(o.kayit)} kayıt · ${sayi(o.iptal)} iptal`)}
          {kutu('Gelen', sayi(o.gelen), `${yuzde(o.gelenOran)} geldi`, 'iyi')}
          {kutu('Gelmeyen', sayi(o.gelmeyen), `no-show ${yuzde(o.noShow)}`, o.noShow != null && o.noShow > 10 ? 'teh' : '')}
          {kutu('İptal', sayi(o.iptal), `${yuzde(o.iptalOran)} kayıt iptal edildi`)}
          {kutu('Slot Doluluğu', yuzde(o.doluluk), o.slot ? `${sayi(o.verilen)} / ${sayi(o.slot)} slot · ${sayi(o.bos)} boş` : 'çalışma planı yok', 'mor')}
          {kutu('Ort. Bekleme', dakika(o.ortBeklemeDk), `randevu saati → muayene · ${sayi(o.uzunBekleme)} kişi 30+ dk`, o.uzunBekleme ? 'uy' : '')}
          {kutu('Randevusuz Muayene', sayi(o.randevusuz), `toplam muayene ${sayi(o.muayene)}`)}
          {kutu('İlk / Kontrol', `${yuzde(o.ilkOran)} / ${yuzde(o.kontrolOran)}`, `${sayi(o.ilk)} ilk · ${sayi(o.kontrol)} kontrol`)}
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
            {sekme === 'poliklinik' && <PoliklinikTablosu v={veri} secili={secili} setSecili={setSecili} />}
            {sekme === 'hekim' && <HekimTablosu v={veri} />}
            {sekme === 'kanal' && <KanalTablosu v={veri} />}
            {sekme === 'gunsaat' && <GunSaatTablosu v={veri} />}
            {sekme === 'gelmeyen' && <GelmeyenTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const RP_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.hi-tablo .bo-rz { white-space:nowrap; }
.bo-rz.mor { background:#f1ebfa; color:#6a3fb5; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-bar { display:inline-block; width:70px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-kalite { display:grid; grid-template-columns:2fr 1fr; gap:12px; }
.lb-bas { font-weight:bold; margin:10px 0 4px; }
.hi-tablo td.orta, .hi-tablo th.orta { text-align:center; }
.rp-gs td { font-size:11.5px; }
@media (max-width: 1000px) { .lb-kalite { grid-template-columns:1fr; } }
.a4-t.rp-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.rp-a4t th:nth-child(1), .a4-t.rp-a4t td:nth-child(1) { text-align:left; width:24%; }
`;

export default RandevuIcmal;
