import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { AlacakYaslandirma as Veri } from '../../api/uclar/alacakYaslandirma';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { YaslandirmaA4 } from './YaslandirmaA4';
import { DilimGrafigi, HastaTablosu, KurumTablosu } from './YaslandirmaTablolari';
import { bugunYerel } from './yaslandirmaOrtak';

/**
 * ALACAK YAŞLANDIRMA `/alacak-yaslandirma` — mockup Ekranlar/İcmal/
 * alacak_yaslandirma.html (kullanıcı 10.10.2026: "alacak yaşlandırmayı kodla").
 *
 * Hasta ve kurum açık bakiyeleri 0-30 / 31-60 / 61-90 / 90+ gün dilimlerinde.
 * Rakamlar SUNUCUDAN (AlacakYaslandirmaUclari): kurumda açık fatura +
 * faturalanmamış kurum payı, hastada hasta payı - tahsilat (hasta icmaliyle
 * aynı kural). Ad tıklanınca ilgili icmal açılır. Listelerde tık / Ctrl /
 * Shift seçimi A4'ü süzer. Görünüm icmallerle ortak.
 */
type Sekme = 'kurum' | 'hasta' | 'grafik';

const KURUM_TURLERI: [number, string][] = [[0, 'Tümü'], [3, 'SGK'], [2, 'ÖSS'], [4, 'Kurumu öder']];

export function AlacakYaslandirma() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const tarih = arama.get('tarih') ?? bugunYerel();
  const taraf = arama.get('taraf') ?? 'hepsi';
  const kurumTuru = Number(arama.get('kurumTuru') ?? 0);
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>(taraf === 'hasta' ? 'hasta' : 'kurum');
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [seciliKurum, setSeciliKurum] = useState<number[]>([]);
  const [seciliHasta, setSeciliHasta] = useState<number[]>([]);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0' && v !== 'hepsi') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true });
    setSeciliKurum([]); setSeciliHasta([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.alacakYaslandirma(tarih, taraf, kurumTuru).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [tarih, taraf, kurumTuru]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const buYol = () => `/alacak-yaslandirma?${arama.toString()}`;
  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ...(taraf !== 'hasta' ? [['kurum', 'Kurumlar', veri.kurumlar.length] as [Sekme, string, number]] : []),
    ...(taraf !== 'kurum' ? [['hasta', 'Hastalar', veri.hastalar.length] as [Sekme, string, number]] : []),
    ['grafik', 'Dilim Grafiği', null]] : [];
  const yuzde = (n: number) => (o && o.toplam > 0 ? `%${Math.round((100 * n) / o.toplam)}` : '');

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + YASLANDIRMA_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Alacak Yaşlandırma</h1>
          <span className="yol">Finans › Alacak Yaşlandırma</span>
        </div>
      </div>

      <div className="hi-arac">
        {/* ÇIKTI MENÜSÜ: Baskı Önizleme / Yazıcıya Yazdır / Gönder ▸ - A4 menünün içinde, ayrı önizleme sekmesi yok. */}
        <CiktiMenusu etiket="Alacak Yaşlandırma" dosyaAdi={`Alacak Yaşlandırma ${tarih}`} devre={!veri}>
          {veri && <YaslandirmaA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} seciliKurum={seciliKurum} seciliHasta={seciliHasta} />}
        </CiktiMenusu>
        {seciliKurum.length + seciliHasta.length > 0 && (
          <span className="ki-soluk">A4 yalnız seçili {seciliKurum.length} kurum · {seciliHasta.length} hastayı basar</span>
        )}
        <span className="sp" />
        <button onClick={() => git('/hasta-borc-takibi')}>📞 Hasta Borç Takibi</button>
        <button onClick={() => git('/kurum-icmali')}>🏢 Kurum İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">👥 Taraf:
            <select value={taraf} onChange={e => { degistir({ taraf: e.target.value }); setSekme(e.target.value === 'hasta' ? 'hasta' : 'kurum') }}>
              <option value="hepsi">Tümü (hasta + kurum)</option><option value="kurum">Kurum</option><option value="hasta">Hasta</option>
            </select>
          </div>
          <div className="sel">📅 Referans tarihi:
            <input type="date" value={tarih} onChange={e => e.target.value && degistir({ tarih: e.target.value })} />
          </div>
          {taraf !== 'hasta' && (
            <div className="sel">🏢 Kurum türü:
              <select value={kurumTuru} onChange={e => degistir({ kurumTuru: e.target.value })}>
                {KURUM_TURLERI.map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
              </select>
            </div>
          )}
          <div className="sel ki-soluk">📐 Gün = referans tarihi − belge tarihi</div>
          <span className="sp" />
          {o.d90 > 0.005 && <span className="bo-rz kir">90+ gün: {paraYaz(o.d90)}</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Toplam Alacak', paraYaz(o.toplam), `kurum ${paraYaz(o.kurum)} · hasta ${paraYaz(o.hasta)}`, 'teh')}
          {kutu('0 – 30 Gün', paraYaz(o.d0), yuzde(o.d0), 'iyi')}
          {kutu('31 – 60 Gün', paraYaz(o.d30), yuzde(o.d30))}
          {kutu('61 – 90 Gün', paraYaz(o.d60), yuzde(o.d60), 'uy')}
          {kutu('90+ Gün', paraYaz(o.d90), yuzde(o.d90), o.d90 > 0.005 ? 'teh' : '')}
          {kutu('En Eski Alacak', `${o.enEskiGun} gün`, 'en eski açık belge')}
          {kutu('Ortalama Gün', `≈ ${o.ortGun} gün`, 'tutar ağırlıklı')}
          {kutu('Taraf', String(o.kurumSayisi + o.hastaSayisi), `${o.kurumSayisi} kurum · ${o.hastaSayisi} hasta`, 'mor')}
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
            {sekme === 'kurum' && (
              <KurumTablosu v={veri} secili={seciliKurum} setSecili={setSeciliKurum}
                            kurumAc={id => git(`/kurum-icmali?kurumlar=${id}&geri=${encodeURIComponent(buYol())}`)} />
            )}
            {sekme === 'hasta' && (
              <HastaTablosu v={veri} secili={seciliHasta} setSecili={setSeciliHasta}
                            hastaAc={id => git(`/hasta-icmal/${id}?geri=${encodeURIComponent(buYol())}`)} />
            )}
            {sekme === 'grafik' && <DilimGrafigi v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

/** Yaşlandırmaya özgü: dilim çubukları, A4 tablo genişliği. */
const YASLANDIRMA_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; }
.hi-tablo .yz-sari { color:#8a6218; font-weight:bold; }
.yz-grafik { display:flex; flex-direction:column; gap:12px; }
.yz-yigin { display:flex; height:26px; border-radius:5px; overflow:hidden; background:#e7edf4; }
.yz-yigin i { display:flex; align-items:center; justify-content:center; color:#fff; font-size:11px; font-style:normal; font-weight:bold; }
.yz-nokta { display:inline-block; width:10px; height:10px; border-radius:2px; margin-right:6px; vertical-align:-1px; }
.yz-cubuk { display:flex; height:10px; border-radius:4px; overflow:hidden; background:#e7edf4; }
.yz-cubuk i { display:block; height:100%; }
.a4-t.yz-a4t th:nth-child(1) { width:30%; } .a4-t.yz-a4t th:nth-child(2) { width:18%; }
.a4-t.yz-a4t tr.yz-top td { font-weight:bold; border-top:1px solid #333; }
/* Toplam satırında ilk hücre 2 sütun kaplar - tutarlar sağa (genel kural 2. hücreyi sola yaslıyor). */
.a4-t.yz-a4t tr.yz-top td:nth-child(n+2) { text-align:right; }
`;

export default AlacakYaslandirma;
