import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { EFaturaIcmali } from '../../api/uclar/efaturaIcmal';
import { para } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { BelgeKarti } from '../BelgeKarti';
import { EFaturaA4 } from './EFaturaA4';
import { gonderilebilir, yuzde } from './efaturaIcmalOrtak';
import { AliciSeriTablosu, IadeIptalTablosu, KdvTablosu, SorunluTablosu, TurTablosu } from './EFaturaTablolari';

/**
 * FATURA / e-BELGE İCMALİ `/efatura-icmal` - mockup Ekranlar/İcmal/fatura_ebelge_icmali.html
 * (kullanıcı 11.10.2026: "efatura icmalini mockup gibi yap").
 *
 * Dönemde kesilen e-belgeler türe / seriye göre; GİB'e gitmeyen, hata alan,
 * 7 günü aşan ve e-Belgesi hazırlanmamış faturalar (seçilip yeniden
 * gönderilir); KDV oran özeti; alıcı grubu / kurum / seri; iade ve iptaller;
 * A4 çıktı menüsünde. Rakamlar SUNUCUDAN (EFaturaIcmalUclari).
 */
type Sekme = 'tur' | 'sorunlu' | 'kdv' | 'alici' | 'iade';
const tl = (n: number) => `${para.format(n)} ₺`;

export function EFaturaIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const subeAdi = kullanici?.subeler.find(s => s.id === kullanici?.subeId)?.ad ?? '';
  const [acikBelge, setAcikBelge] = useState<number | null>(null);
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const tur = arama.get('tur') ?? '';
  const seri = arama.get('seri') ?? '';
  const alici = arama.get('alici') ?? '';
  const [veri, setVeri] = useState<EFaturaIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>((arama.get('sekme') as Sekme) || 'tur');
  const [seciliTur, setSeciliTur] = useState<string[]>([]);
  const [seciliBelge, setSeciliBelge] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [yenile, setYenile] = useState(0);
  const [gonderiyor, setGonderiyor] = useState(false);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v) yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true }); setSeciliTur([]); setSeciliBelge([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.efaturaIcmali(bas, bit, tur, seri, alici).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, tur, seri, alici, yenile]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const ayKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`); const y = new Date(d.getFullYear(), d.getMonth() + n, 1);
    const a = ayAraligi(y.getFullYear(), y.getMonth() + 1); degistir({ bas: a.bas, bit: a.bit });
  };
  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );

  /** SEÇİLENLERİ YENİDEN GÖNDER: yalnız hazır belgeler, sırayla (sıra kuralı sunucuda). */
  const yenidenGonder = async () => {
    if (!veri) return;
    const secilen = veri.sorunlu.filter(s => seciliBelge.includes(s.id));
    const gidecek = secilen.filter(gonderilebilir);
    if (gidecek.length === 0) {
      mesaj(secilen.length ? 'Seçilenler arasında gönderilebilir (hazırlanmış) belge yok. Hazırlanmamış faturayı çift tıklayıp e-Fatura menüsünden hazırlayın.'
                           : 'Önce Sorunlu Belgeler sekmesinden belge seçin.');
      return;
    }
    if (!await onay(`${gidecek.length} belge GİB'e GÖNDERİLECEK${secilen.length > gidecek.length ? ` (${secilen.length - gidecek.length} hazırlanmamış belge atlanır)` : ''}.\n\n`
                  + 'Gönderilen belge geri alınamaz. Onaylıyor musunuz?', true)) return;
    setGonderiyor(true);
    const sonuc: string[] = [];
    for (const s of [...gidecek].sort((a, b) => a.belgeNo.localeCompare(b.belgeNo))) {
      try { await api.efaturaGonder(s.id); sonuc.push(`✓ ${s.belgeNo}`) }
      catch (h) { sonuc.push(`✗ ${s.belgeNo}: ${hataMetni(h)}`) }
    }
    setGonderiyor(false);
    mesaj(sonuc.join('\n'));
    setSeciliBelge([]); setYenile(y => y + 1);
  };

  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['tur', 'Belge Türleri', veri.turler.length], ['sorunlu', 'Sorunlu Belgeler', veri.sorunlu.length],
    ['kdv', 'KDV Özeti', veri.kdvOzet.length], ['alici', 'Alıcı / Seri', veri.alicilar.length + veri.seriler.length],
    ['iade', 'İade / İptal', veri.iadeler.length + veri.iptaller.length]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + EF_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Fatura / e-Belge İcmali</h1>
          <span className="yol">Finans › Fatura / e-Belge İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Fatura / e-Belge İcmali" dosyaAdi={`Fatura e-Belge İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <EFaturaA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={seciliTur} />}
        </CiktiMenusu>
        <button disabled={gonderiyor || seciliBelge.length === 0} onClick={() => void yenidenGonder()}
                title={seciliBelge.length ? 'Seçili sorunlu belgelerden hazırlanmış olanları GİB\'e gönderir' : 'Sorunlu Belgeler sekmesinden belge seçin'}>
          📤 {gonderiyor ? 'Gönderiliyor…' : `Seçilenleri Yeniden Gönder${seciliBelge.length ? ` (${seciliBelge.length})` : ''}`}
        </button>
        {seciliTur.length > 0 && <span className="ki-soluk">A4 seçili {seciliTur.length} türü basar</span>}
        <span className="sp" />
        <button onClick={() => git('/fatura')}>🧾 Faturalar</button>
        <button onClick={() => git('/gelen-belge')}>📮 e-Belge Gelen Kutusu</button>
        <button onClick={() => git(-1)}>↩ Geri Dön</button>
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
          <div className="sel">🏢 Şube: <b>{subeAdi || 'Aktif şube'}</b></div>
          <div className="sel">📄 Tür:
            <select value={tur} onChange={e => degistir({ tur: e.target.value })}>
              <option value="">Tümü</option><option>e-Fatura</option><option>e-Arşiv</option><option>e-İrsaliye</option>
              <option value="hazirlanmadi">Hazırlanmamış</option>
            </select>
          </div>
          <div className="sel">🔢 Seri:
            <select value={seri} onChange={e => degistir({ seri: e.target.value })}>
              <option value="">Tümü</option>{veri.seriAdlari.map(s => <option key={s}>{s}</option>)}
            </select>
          </div>
          <div className="sel">👥 Alıcı:
            <select value={alici} onChange={e => degistir({ alici: e.target.value })}>
              <option value="">Tümü</option><option>Kurum</option><option>Hasta</option><option>Firma</option>
            </select>
          </div>
          <span className="sp" />
          {o.gitmedi > 0 && <span className="bo-rz kir">{o.gitmedi} belge GİB'e gitmedi</span>}
          {o.hata > 0 && <span className="bo-rz kir">{o.hata} gönderim hatası</span>}
          {o.yediGun > 0 && <span className="bo-rz kir">{o.yediGun} belge 7 günü aştı</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Kesilen Belge', String(o.kesilen), `${o.kayit} kayıt · ${o.iptal} iptal`)}
          {kutu('Toplam Tutar', tl(o.toplam), `matrah ${para.format(o.matrah)}`, 'mor')}
          {kutu('KDV', tl(o.kdv), `fatura KDV ${para.format(o.faturaKdv)}`)}
          {kutu('e-Fatura', String(o.eFatura), `${tl(o.eFaturaTutar)} · ${o.eFaturaIade} iade`)}
          {kutu('e-Arşiv', String(o.eArsiv), tl(o.eArsivTutar))}
          {kutu('e-İrsaliye', String(o.eIrsaliye), tl(o.eIrsaliyeTutar))}
          {kutu('Sorunlu Belge', String(o.sorunlu), `${o.gitmedi} GİB'e gitmedi · ${o.hata} hata`, o.sorunlu ? 'teh' : 'iyi')}
          {kutu('7 Gün Kuralı', String(o.yediGun), `geç gönderilen / bekleyen · ulaşan ${yuzde(o.ulasan)}`, o.yediGun ? 'uy' : '')}
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
            {sekme === 'tur' && <TurTablosu v={veri} secili={seciliTur} setSecili={setSeciliTur} />}
            {sekme === 'sorunlu' && <SorunluTablosu v={veri} secili={seciliBelge} setSecili={setSeciliBelge}
                                                    belgeAc={setAcikBelge} />}
            {sekme === 'kdv' && <KdvTablosu v={veri} />}
            {sekme === 'alici' && <AliciSeriTablosu v={veri} />}
            {sekme === 'iade' && <IadeIptalTablosu v={veri} />}
          </div>
        </div>
        <div className="ki-not">{tarihAraligi(bas, bit)} · {o.kesilen} belge · {tl(o.toplam)} · fatura KDV {tl(o.faturaKdv)} ·
          {' '}{o.sorunlu} sorunlu · {o.yediGun} geç</div>
      </>)}
      {/* Sorunlu belgeye cift tik: fatura karti (e-Fatura menusu orada). */}
      {acikBelge !== null && (
        <BelgeKarti id={acikBelge} onKapat={() => { setAcikBelge(null); setYenile(y => y + 1) }} />
      )}
    </div>
  );
}

const tarihAraligi = (bas: string, bit: string) =>
  `${bas.split('-').reverse().join('.')} – ${bit.split('-').reverse().join('.')}`;

const EF_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; max-width:200px; }
.hi-tablo .bo-rz { white-space:nowrap; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.lb-bar { display:inline-block; width:70px; height:8px; background:#e6ebf1; border-radius:4px; vertical-align:middle; overflow:hidden; }
.lb-bar span { display:block; height:100%; background:#3b82c4; }
.lb-bas { font-weight:bold; margin:12px 0 4px; }
.a4-t.ef-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.ef-a4t th:nth-child(1), .a4-t.ef-a4t td:nth-child(1) { text-align:left; }
.a4-t.ef-a4t td { text-align:right; }
`;

export default EFaturaIcmal;
