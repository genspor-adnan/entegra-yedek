import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { MedulaMutabakati } from '../../api/uclar/medulaMutabakat';
import { paraYaz } from '../../bilesenler/bicim';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { MutabakatA4 } from './mutabakat/MutabakatA4';
import { FarkTablosu, FaturasizTablosu, Huni, KesintiTablosu } from './mutabakat/MutabakatTablolari';
import { AY_ADLARI, donemDurumRozeti, gecenAyYilAy } from './mutabakat/mutabakatOrtak';

/**
 * MEDULA MUTABAKAT İCMALİ `/medula-mutabakat` — mockup Ekranlar/İcmal/
 * medula_mutabakat.html (kullanıcı 10.10.2026: "medula mutabakat icmalini
 * kodla").
 *
 * SGK döneminin hunisi (takip → hizmet → çıkış → fatura → dönem → ödeme),
 * faturasız takipler nedeniyle, HBYS - Medula tutar farkları ve kesintiler;
 * A4 dönem mutabakat tutanağı. Rakamlar SUNUCUDAN (MedulaUclari.Mutabakat),
 * Fatura & Dönem ekranıyla aynı kaynaktan. Faturalama o ekranın uçlarıyla:
 * "Eksikleri Faturala" toplu, onay kutusuyla seçilenler tek tek.
 * Görünüm hasta / kurum icmaliyle ortak.
 */
type Sekme = 'huni' | 'faturasiz' | 'fark' | 'kesinti' | 'onizleme';

export function MedulaMutabakat() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const vars = gecenAyYilAy();
  const yil = Number(arama.get('yil') ?? vars.yil);
  const ay = Number(arama.get('ay') ?? vars.ay);
  const [veri, setVeri] = useState<MedulaMutabakati | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('huni');
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [secili, setSecili] = useState<number[]>([]);
  const [tazele, setTazele] = useState(0);
  const [calisiyor, setCalisiyor] = useState(false);

  const donemDegistir = useCallback((y: number, a: number) => {
    const yeni = new URLSearchParams(arama);
    yeni.set('yil', String(y)); yeni.set('ay', String(a));
    setArama(yeni, { replace: true });
    setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.medulaMutabakat(yil, ay).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [yil, ay, tazele]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const ayKaydir = (n: number) => { const d = new Date(yil, ay - 1 + n, 1); donemDegistir(d.getFullYear(), d.getMonth() + 1) };
  const buYol = () => `/medula-mutabakat?${arama.toString()}`;

  // EKSİKLERİ FATURALA: Fatura & Dönem'in toplu ucu - engeli olmayan
  //   (çıkışı verilmiş, hizmeti kabul) bütün faturasız takipler.
  const topluFaturala = () => void guvenli(async () => {
    if (!o) return;
    if (!(await onay(`${AY_ADLARI[ay - 1]} ${yil}: faturaya hazır ${o.hazir} takip Medula'ya faturalansın mı?`))) return;
    setCalisiyor(true);
    try {
      const r = await api.medulaFaturaToplu(yil, ay);
      mesaj(`${r.denenen} takip denendi: ${r.kabul} kabul, ${r.hata} hata.`);
    } finally { setCalisiyor(false); setSecili([]); setTazele(t => t + 1) }
  });

  const seciliFaturala = () => void guvenli(async () => {
    if (!secili.length) return;
    if (!(await onay(`Seçili ${secili.length} takip Medula'ya faturalansın mı?`))) return;
    setCalisiyor(true);
    let kabul = 0; const hatalar: string[] = [];
    try {
      for (const id of secili) {
        const r = await api.medulaFaturaKaydet(id);
        if (r.kabul) kabul++; else hatalar.push(r.mesaj || r.kod);
      }
      mesaj(`${kabul} fatura kabul` + (hatalar.length ? `, ${hatalar.length} hata: ${hatalar.slice(0, 3).join(' · ')}` : '.'));
    } finally { setCalisiyor(false); setSecili([]); setTazele(t => t + 1) }
  });

  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, string | null, string][] = veri && o ? [
    ['huni', 'Huni', null, ''],
    ['faturasiz', 'Faturasız Takipler', String(o.faturasiz), o.faturasiz ? ' kir' : ''],
    ['fark', 'Tutar Farkları', String(o.farkli), o.farkli ? ' kir' : ''],
    ['kesinti', 'Kesintiler', String(o.kesintiKalem), ''],
    ['onizleme', '🖨️ Önizleme (A4)', null, '']] : [];
  const dr = veri?.donem ? donemDurumRozeti(veri.donem.durum) : null;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + MUTABAKAT_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Medula Mutabakat İcmali</h1>
          <span className="yol">Medula › Mutabakat İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <button className="hi-yesil" disabled={!o || o.hazir === 0 || calisiyor}
                title={o && o.hazir === 0 ? 'Faturaya hazır takip yok' : 'Engeli olmayan bütün faturasız takipler'}
                onClick={topluFaturala}>🧾 Eksikleri Faturala{o && o.hazir > 0 ? ` (${o.hazir})` : ''}</button>
        <button disabled={!secili.length || calisiyor} onClick={seciliFaturala}>
          ☑ Seçilileri Faturala{secili.length ? ` (${secili.length})` : ''}</button>
        <span className="ki-ayrac" />
        <button className="hi-ana" disabled={!veri} onClick={() => window.print()}>🖨️ Yazdır (A4 Tutanak)</button>
        <span className="sp" />
        <button onClick={() => git('/medula-fatura-donem')}>🧮 Fatura &amp; Dönem</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">📅 Dönem:
            <button className="ki-ok" title="Önceki ay" onClick={() => ayKaydir(-1)}>‹</button>
            <select value={ay} onChange={e => donemDegistir(yil, Number(e.target.value))}>
              {AY_ADLARI.map((a, i) => <option key={a} value={i + 1}>{a}</option>)}
            </select>
            <input type="number" value={yil} min={2020} max={2100} style={{ width: 64 }}
                   onChange={e => Number(e.target.value) > 2000 && donemDegistir(Number(e.target.value), ay)} />
            <button className="ki-ok" title="Sonraki ay" onClick={() => ayKaydir(1)}>›</button>
          </div>
          <div className="sel">🗂 Dönem durumu: {dr ? <span className={'bo-rz ' + dr.renk}>{dr.ad}</span> : <span className="ki-soluk">dönem oluşturulmadı</span>}
            {veri.donem?.icmalNo && <span className="ki-soluk"> · icmal {veri.donem.icmalNo}</span>}</div>
          <span className="sp" />
          {o.faturasiz > 0 && <span className="bo-rz kir">{o.faturasiz} faturasız takip · {paraYaz(o.faturasizTutar)}</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Takip', String(o.takip), `${paraYaz(o.yerelTutar)} HBYS`)}
          {kutu('Faturalanan', String(o.faturali), paraYaz(o.faturaliYerel), 'iyi')}
          {kutu('Faturasız Takip', String(o.faturasiz), `${o.hazir} hazır · ${paraYaz(o.faturasizTutar)}`, o.faturasiz ? 'teh' : 'iyi')}
          {kutu('Medula Tutarı', paraYaz(o.medulaTutar), `${o.farkli} faturada fark ${paraYaz(o.farkTutari)}`, 'mor')}
          {kutu('Kesinti', paraYaz(o.kesinti), `${o.kesintiKalem} kalem · iade düşülmüş`, 'uy')}
          {kutu('İtiraz Bekleyen', paraYaz(o.itirazBekleyen), `${o.itirazBekleyenKalem} kalem`)}
          {kutu('Ödenen', paraYaz(o.odenen), veri.donem?.odemeTarihi ? `ödeme ${new Date(veri.donem.odemeTarihi).toLocaleDateString('tr-TR')}` : 'ödeme girilmedi', 'iyi')}
          {kutu('Açık Alacak', paraYaz(o.acik), 'Medula − kesinti − ödenen', o.acik > 0.005 ? 'teh' : 'iyi')}
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <div className="katab">
              {sekmeler.map(([k, ad, n, renk]) => (
                <div key={k} className={'kat' + (sekme === k ? ' on' : '')} onClick={() => setSekme(k)}>
                  {ad}{n != null && <span className={'b' + renk}>{n}</span>}
                </div>
              ))}
            </div>
            {sekme === 'huni' && <Huni v={veri} />}
            {sekme === 'faturasiz' && (
              <FaturasizTablosu v={veri} secili={secili} setSecili={setSecili}
                                hastaAc={id => git(`/hasta-icmal/${id}?geri=${encodeURIComponent(buYol())}`)} />
            )}
            {sekme === 'fark' && <FarkTablosu v={veri} />}
            {sekme === 'kesinti' && <KesintiTablosu v={veri} />}
            <div className={'hi-onizleme' + (sekme === 'onizleme' ? '' : ' gizli')}>
              <MutabakatA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />
            </div>
          </div>
        </div>
      </>)}
    </div>
  );
}

/** Mutabakata özgü: dönem seçicisi, huni çubuğu, A4 tablo genişliği. */
const MUTABAKAT_STILI = `
.hi-serit select, .hi-serit input[type=number] { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; }
.katab .kat .b.kir { background:#fbe9e7; color:#b3261e; }
.ki-cubuk.mm-huni { display:inline-block; width:75%; height:10px; vertical-align:middle; }
.a4-t.mm-a4t { width:70%; } .a4-t.mm-a4t th:nth-child(1) { width:60%; } .a4-t.mm-a4t th:nth-child(2) { width:15%; }
`;

export default MedulaMutabakat;
