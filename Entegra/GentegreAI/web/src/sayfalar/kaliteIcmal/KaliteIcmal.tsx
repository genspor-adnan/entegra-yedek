import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { KaliteIcmali } from '../../api/uclar/kaliteIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { KaliteA4 } from './KaliteA4';
import { sonucMetni } from './kaliteIcmalOrtak';
import { BildirimTablosu, GostergeTablosu, GrsTablosu, GuvenlikTablosu, MemnuniyetTablosu } from './KaliteTablolari';

/**
 * KALİTE / SKS İCMALİ `/kalite-icmal` — mockup Ekranlar/İcmal/kalite_sks_icmali.html
 * (kullanıcı 12.10.2026: "icmalleri yap").
 *
 * Göstergeler (SKS kayıtlardan + Klinik Kalite dönem sonuçları), kritik / panik
 * bildirim süreleri, GRS olayları, servis düşme / bası yarası, el hijyeni,
 * memnuniyet; A4 çıktı menüsünde. Rakamlar SUNUCUDAN (KaliteIcmalUclari).
 * ISO kalite modülü (DÖF, olay takibi, şikâyet) henüz yok: o veriler "kaynak yok".
 */
type Sekme = 'gosterge' | 'bildirim' | 'grs' | 'guvenlik' | 'memnuniyet';
type GostergeSeti = 'tum' | 'SKS' | 'Klinik';

export function KaliteIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const set = (arama.get('set') ?? 'tum') as GostergeSeti;
  const [veri, setVeri] = useState<KaliteIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('gosterge');
  const [secili, setSecili] = useState<string[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== 'tum') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.kaliteIcmali(bas, bit).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const ayKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`); const y = new Date(d.getFullYear(), d.getMonth() + n, 1);
    const a = ayAraligi(y.getFullYear(), y.getMonth() + 1); degistir({ bas: a.bas, bit: a.bit });
  };
  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const gostergeler = veri ? veri.gostergeler.filter(g => set === 'tum' || g.kaynak === set) : [];
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['gosterge', 'Göstergeler', gostergeler.length], ['bildirim', 'Kritik / Panik Bildirim', veri.ozet.bildirim],
    ['grs', 'Güvenlik Raporlama', veri.ozet.grs], ['guvenlik', 'Hasta Güvenliği', veri.servisler.length],
    ['memnuniyet', 'Memnuniyet', veri.memnuniyetBirim.length]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + KL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Kalite / SKS İcmali</h1>
          <span className="yol">Klinik Kalite › Kalite / SKS İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Kalite Raporu" dosyaAdi={`Kalite Raporu ${bas} - ${bit}`} devre={!veri}>
          {veri && <KaliteA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        {secili.length > 0 && <span className="ki-soluk">A4 seçili {secili.length} göstergeyi basar</span>}
        <span className="sp" />
        <button onClick={() => git('/klinik-gosterge-donem')}>📈 Klinik Göstergeler</button>
        <button onClick={() => git('/form-istek')}>🛡 Doldurulan Formlar</button>
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
          <div className="sel">📚 Gösterge seti:
            <select value={set} onChange={e => degistir({ set: e.target.value })}>
              <option value="tum">SKS + Klinik</option><option value="SKS">SKS</option><option value="Klinik">Klinik</option>
            </select>
          </div>
          <span className="sp" />
          {o.hedefDisi > 0 && <span className="bo-rz kir">{o.hedefDisi} gösterge hedef dışı</span>}
          {o.bildirimAsan > 0 && <span className="bo-rz kir">{o.bildirimAsan} bildirim hedef süreyi aştı</span>}
          {o.grsCiddi > 0 && <span className="bo-rz kir">{o.grsCiddi} ciddi GRS olayı</span>}
          {o.kaynakYok > 0 && <span className="bo-rz pas" title="Kalite modülü (olay takibi, DÖF, gözlem) kurulunca dolar">{o.kaynakYok} gösterge kaynaksız</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Göstergeler', `${o.hedefte} / ${o.gosterge}`, `hedefte · ${o.hedefDisi} hedef dışı${o.veriYok ? ` · ${o.veriYok} veri yok` : ''}`,
                o.hedefDisi ? 'teh' : 'iyi')}
          {kutu('Kritik / Panik Bildirim', String(o.bildirim), `hedef sürede ${sonucMetni(o.bildirimOran, '%')} · ${o.bildirimAsan} aşan`, o.bildirimAsan ? 'teh' : '')}
          {kutu('Ort. Bildirim Süresi', o.ortSure != null ? `${o.ortSure} dk` : '—',
                `lab ${o.labOrt ?? '—'} dk (hedef ${o.panikHedef}) · rad ${o.radOrt ?? '—'} dk (hedef ${o.kritikHedef})`)}
          {kutu('GRS Olay Bildirimi', String(o.grs), `${o.grsCiddi} ciddi / ölüm · önceki dönem ${o.grsOnceki}`, o.grsCiddi ? 'teh' : 'mor')}
          {kutu('Düşme', String(o.dusme), `${sonucMetni(o.dusmeBinde, '‰')} hasta-gün · hedef ≤ 2,50‰`,
                o.dusmeBinde != null && o.dusmeBinde > 2.5 ? 'teh' : '')}
          {kutu('Bası Yarası', String(o.basi), `hastanede gelişen · ${sonucMetni(o.basiOran, '%')} (hedef ≤ %5)`,
                o.basiOran != null && o.basiOran > 5 ? 'teh' : '')}
          {kutu('El Hijyeni Uyum', sonucMetni(o.elOran, '%'), `${o.elUyulan} / ${o.elFirsat} fırsat (hedef %85)`,
                o.elOran != null && o.elOran < 85 ? 'uy' : '')}
          {kutu('Hasta Memnuniyeti', sonucMetni(o.memnuniyetOran, '%'),
                `ort. ${o.ortPuan != null ? o.ortPuan.toFixed(2).replace('.', ',') : '—'} / 5 · ${o.anket} anket`,
                o.memnuniyetOran != null && o.memnuniyetOran < 85 ? 'uy' : '')}
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
            {sekme === 'gosterge' && <GostergeTablosu liste={gostergeler} secili={secili} setSecili={setSecili} />}
            {sekme === 'bildirim' && <BildirimTablosu v={veri} />}
            {sekme === 'grs' && <GrsTablosu v={veri} />}
            {sekme === 'guvenlik' && <GuvenlikTablosu v={veri} />}
            {sekme === 'memnuniyet' && <MemnuniyetTablosu v={veri} />}
          </div>
        </div>
        {o.klinikOlculmeyen > 0 && <div className="ki-not">Bu dönemi kapsayan periyotta {o.klinikOlculmeyen} klinik gösterge ölçülmemiş
          (paydası 0) - listede yok; Klinik Kalite › Dönem Sonuçları'ndan hesaplanır.</div>}
      </>)}
    </div>
  );
}

const KL_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.lb-k { margin-left:6px; font-size:10px; }
.hi-tablo .bo-rz { white-space:nowrap; }
.bo-rz.mor { background:#f1ebfa; color:#6a3fb5; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-kalite { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.lb-bas { font-weight:bold; margin:10px 0 4px; }
.kl-tr { white-space:nowrap; font-size:11.5px; }
.kl-tr.iyi { color:#2e7d46; } .kl-tr.kotu { color:#b3261e; } .kl-tr.notr { color:var(--soluk,#5b6b7d); }
@media (max-width: 1000px) { .lb-kalite { grid-template-columns:1fr; } }
.a4-t.kl-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.kl-a4t th:nth-child(2), .a4-t.kl-a4t td:nth-child(2) { text-align:left; width:46%; }
`;

export default KaliteIcmal;
