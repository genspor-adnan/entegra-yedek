import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { BorcIslemi, BorcTakibi } from '../../api/uclar/hastaBorc';
import { paraYaz } from '../../bilesenler/bicim';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { BorcMektubu } from './BorcMektubu';
import { BorcluTablosu, GecmisTablosu, SozTablosu } from './BorcTablolari';
import { CIPLER, type Cip, kanalaUygun } from './borcOrtak';

/**
 * HASTA BORÇ TAKİBİ `/hasta-borc-takibi` — mockup Ekranlar/İcmal/
 * hasta_borc_takibi.html (kullanıcı 10.10.2026: "hasta borç takibini kodla").
 *
 * Açık borcu olan hastalar (borç SUNUCUDAN - hasta icmali / alacak
 * yaşlandırmayla aynı kural), toplu SMS / e-posta hatırlatma (bildirim
 * kuyruğu), ödeme sözü / planı, tahsilata çağır işareti, not, hatırlatma
 * geçmişi ve A4 borç bildirim mektubu. Seçim tık / Ctrl / Shift.
 * Görünüm icmallerle ortak.
 */
type Sekme = 'borclu' | 'gecmis' | 'soz' | 'onizleme';

const bugun = () => { const d = new Date(); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}` };

export function HastaBorcTakibi() {
  const git = useNavigate();
  const { kullanici } = useOturum();
  const [veri, setVeri] = useState<BorcTakibi | null>(null);
  const [gecmis, setGecmis] = useState<BorcIslemi[]>([]);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('borclu');
  const [cip, setCip] = useState<Cip>('hepsi');
  const [minTutar, setMinTutar] = useState(0);
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [tazele, setTazele] = useState(0);
  const [calisiyor, setCalisiyor] = useState(false);
  // ÖDEME SÖZÜ / PLANI formu (tek hasta seçiliyken).
  const [sozForm, setSozForm] = useState<{ tur: 2 | 3; tutar: string; vade: string; taksit: string; aciklama: string } | null>(null);

  useEffect(() => {
    setHata('');
    api.hastaBorcTakibi().then(setVeri).catch(h => setHata(hataMetni(h)));
    api.hastaBorcGecmisi().then(r => setGecmis(r.islemler)).catch(() => setGecmis([]));
  }, [tazele]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const liste = (veri?.borclular ?? []).filter(b => (cip === 'hepsi' || b.durum === cip) && b.borc >= minTutar);
  const seciliHastalar = (veri?.borclular ?? []).filter(b => secili.includes(b.id));
  const tek = seciliHastalar.length === 1 ? seciliHastalar[0] : null;
  const yenile = () => setTazele(t => t + 1);

  // TOPLU HATIRLATMA: sunucu telefonu / e-postası olmayanı ve son 24 saatte
  //   aynı kanaldan hatırlatılanı atlar, nedenini döner.
  const hatirlat = (kanal: 1 | 2) => void guvenli(async () => {
    const uygun = kanalaUygun(veri?.borclular ?? [], secili, kanal);
    if (!uygun.length) { mesaj(`Seçili hastalarda ${kanal === 1 ? 'cep telefonu' : 'e-posta'} yok.`); return }
    if (!(await onay(`${uygun.length} hastaya ${kanal === 1 ? 'SMS' : 'e-posta'} ile borç hatırlatması GÖNDERİLECEK `
          + `(toplam ${paraYaz(uygun.reduce((t, b) => t + b.borc, 0))}). Onaylıyor musunuz?`, true))) return;
    setCalisiyor(true);
    try {
      const r = await api.hastaBorcHatirlat(secili, kanal);
      mesaj(`${r.kuyruga} hatırlatma gönderim kuyruğuna kondu.`
        + (r.atlanan.length ? ` Atlanan ${r.atlanan.length}: ${r.atlanan.slice(0, 4).map(a => `${a.ad} (${a.neden})`).join(', ')}` : ''));
    } finally { setCalisiyor(false); yenile() }
  });

  const isaretle = () => void guvenli(async () => {
    if (!(await onay(`Seçili ${secili.length} hasta "tahsilata çağrılacak" olarak işaretlensin mi?`))) return;
    const r = await api.hastaBorcIsaret(secili);
    mesaj(`${r.isaretlenen} hasta işaretlendi.`); yenile();
  });

  const sozKaydet = () => void guvenli(async () => {
    if (!tek || !sozForm) return;
    const tutar = Number(sozForm.tutar.replace(',', '.'));
    await api.hastaBorcSoz({ hastaId: tek.id, tur: sozForm.tur, tutar, vade: sozForm.vade,
      taksitSayisi: sozForm.tur === 3 ? Number(sozForm.taksit) : undefined, aciklama: sozForm.aciklama });
    mesaj(sozForm.tur === 3 ? 'Ödeme planı kaydedildi.' : 'Ödeme sözü kaydedildi.');
    setSozForm(null); yenile();
  });

  const notEkle = () => void guvenli(async () => {
    if (!tek) return;
    const metin = (await metinSor(`${tek.ad} için not:`, '', 'ör. telefonla arandı, ay sonunda ödeyecek'))?.trim();
    if (!metin) return;
    await api.hastaBorcNot(tek.id, metin); yenile();
  });

  const kaldir = (id: number) => void guvenli(async () => {
    if (!(await onay('Kayıt kaldırılsın mı? (Geçmişte "kaldırıldı" olarak görünür.)'))) return;
    await api.hastaBorcKaldir(id); yenile();
  });

  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['borclu', 'Borçlular', liste.length], ['gecmis', 'Hatırlatma Geçmişi', gecmis.length],
    ['soz', 'Ödeme Sözleri / Planları', veri.borclular.filter(b => b.soz).length], ['onizleme', '🖨️ Borç Mektubu (A4)', null]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + BORC_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Hasta Borç Takibi</h1>
          <span className="yol">Kayıt Kabul › Hasta Borç Takibi</span>
        </div>
      </div>

      <div className="hi-arac">
        <button className="hi-yesil" disabled={!secili.length || calisiyor} onClick={() => hatirlat(1)}>📱 SMS Hatırlat</button>
        <button disabled={!secili.length || calisiyor} onClick={() => hatirlat(2)}>✉ E-posta Hatırlat</button>
        <button disabled={!secili.length} onClick={isaretle}>📞 Tahsilata Çağır</button>
        <button disabled={!tek} title={tek ? '' : 'Tek hasta seçin'}
                onClick={() => setSozForm({ tur: 2, tutar: String(tek?.borc ?? ''), vade: bugun(), taksit: '3', aciklama: '' })}>🤝 Ödeme Sözü / Plan</button>
        <button disabled={!tek} title={tek ? '' : 'Tek hasta seçin'} onClick={notEkle}>📝 Not</button>
        <span className="ki-ayrac" />
        <button className="hi-ana" disabled={!seciliHastalar.length} title="Seçili hastalara borç bildirim mektubu"
                onClick={() => { setSekme('onizleme'); setTimeout(() => window.print(), 200) }}>🖨️ Mektup Yazdır</button>
        <span className="sp" />
        {secili.length > 0 && <span className="ki-soluk">{secili.length} hasta seçili</span>}
        <button onClick={() => git('/alacak-yaslandirma?taraf=hasta')}>⏳ Alacak Yaşlandırma</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {sozForm && tek && (
        <div className="ki-secim bt-form">
          <b>{tek.ad}</b> · açık borç {paraYaz(tek.borc)} ·
          <select value={sozForm.tur} onChange={e => setSozForm({ ...sozForm, tur: Number(e.target.value) as 2 | 3 })}>
            <option value={2}>Ödeme sözü</option><option value={3}>Ödeme planı</option>
          </select>
          tutar <input value={sozForm.tutar} onChange={e => setSozForm({ ...sozForm, tutar: e.target.value })} style={{ width: 90 }} />
          {sozForm.tur === 3 ? 'ilk taksit' : 'vade'} <input type="date" value={sozForm.vade} min={bugun()}
            onChange={e => setSozForm({ ...sozForm, vade: e.target.value })} />
          {sozForm.tur === 3 && <>taksit <input type="number" min={2} max={36} value={sozForm.taksit} style={{ width: 54 }}
            onChange={e => setSozForm({ ...sozForm, taksit: e.target.value })} /></>}
          <input placeholder="açıklama" value={sozForm.aciklama} style={{ width: 200 }}
                 onChange={e => setSozForm({ ...sozForm, aciklama: e.target.value })} />
          <button className="hi-yesil" onClick={sozKaydet}>Kaydet</button>
          <button onClick={() => setSozForm(null)}>Vazgeç</button>
          {tek.soz && <span className="ki-soluk">Mevcut söz / plan kaydedince kaldırılır.</span>}
        </div>
      )}

      {veri && o && (<>
        <div className="hi-serit">
          {CIPLER.map(([c, ad]) => {
            const n = c === 'hepsi' ? veri.borclular.length : veri.borclular.filter(b => b.durum === c).length;
            return <span key={c} className={'ki-cip' + (cip === c ? ' on' : '')} onClick={() => { setCip(c); setSecili([]) }}>{ad} <b>{n}</b></span>;
          })}
          <span className="sp" />
          <div className="sel">En az borç:
            <input type="number" min={0} step={100} value={minTutar} style={{ width: 80 }}
                   onChange={e => { setMinTutar(Number(e.target.value) || 0); setSecili([]) }} /> ₺</div>
        </div>

        <div className="hi-ozet">
          {kutu('Borçlu Hasta', String(o.borclu), `${o.tahsilata} tahsilata çağrılacak`)}
          {kutu('Toplam Açık', paraYaz(o.toplam), 'hasta payı − tahsilat', 'teh')}
          {kutu('30+ Gün', paraYaz(o.gun30), `${o.gun30Hasta} hasta`, o.gun30 > 0.005 ? 'teh' : '')}
          {kutu('Hatırlatma Bekleyen', String(o.hatirlatmaBekleyen), 'son 7 günde hatırlatılmadı', 'uy')}
          {kutu('Bu Ay Tahsil', paraYaz(o.buAyTahsil), 'borçlu hastalardan', 'iyi')}
          {kutu('Söz Verilen', paraYaz(o.sozTutar), 'vadesi gelmemiş', 'mor')}
          {kutu('Ödeme Planı', paraYaz(o.planTutar), 'vadesi gelmemiş', 'mor')}
          {kutu('Tutulmayan Söz', String(o.tutulmayan), 'vade geçti, borç açık', o.tutulmayan ? 'teh' : 'iyi')}
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
            {sekme === 'borclu' && (
              <BorcluTablosu liste={liste} secili={secili} setSecili={setSecili}
                             hastaAc={id => git(`/hasta-icmal/${id}?geri=${encodeURIComponent('/hasta-borc-takibi')}`)} />
            )}
            {sekme === 'gecmis' && <GecmisTablosu islemler={gecmis} kaldir={kaldir} />}
            {sekme === 'soz' && <SozTablosu liste={veri.borclular} kaldir={kaldir} />}
            <div className={'hi-onizleme' + (sekme === 'onizleme' ? '' : ' gizli')}>
              <BorcMektubu hastalar={seciliHastalar} antet={antet} duzenleyen={kullanici?.ad ?? ''} />
            </div>
          </div>
        </div>
      </>)}
    </div>
  );
}

/** Borç takibine özgü: söz formu, mektup sayfaları. */
const BORC_STILI = `
.bt-form { margin:8px 12px 0; }
.bt-form input, .bt-form select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:2px 4px; }
.hi-serit input[type=number] { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; }
.bm-a4 p { margin:8px 0; line-height:1.55; }
.a4-t.bm-t th:nth-child(1) { width:18%; } .a4-t.bm-t th:nth-child(2) { width:14%; } .a4-t.bm-t th:nth-child(3) { width:22%; }
.a4-t.bm-t th:nth-child(-n+3), .a4-t.bm-t td:nth-child(-n+3) { text-align:left; }
@media print { .bm-yeni { page-break-before:always; } }
@media screen { .bm-yeni { margin-top:28px; padding-top:18px; border-top:2px dashed #cdd6e0; } }
`;

export default HastaBorcTakibi;
