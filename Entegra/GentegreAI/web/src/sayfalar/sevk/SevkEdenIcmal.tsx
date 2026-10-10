import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { SevkEdenIcmali } from '../../api/uclar/sevkEden';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi } from '../performans/performansOrtak';
import { SevkA4 } from './SevkA4';
import { BasvuruTablosu, DoktorTablosu, OdemeTablosu } from './SevkTablolari';

/**
 * SEVK EDEN / DIŞ DOKTOR İCMALİ `/sevk-eden` — mockup Ekranlar/İcmal/
 * sevk_eden_icmali.html (kullanıcı 10.10.2026: "mockup gibi kodla").
 *
 * Hasta gönderen dış doktor / kurum başına sevk, sevkli ciro, komisyon
 * (gönderen primi) ve ödeme durumu; sevkli başvurular; komisyon (prim)
 * satırları; A4. Rakamlar SUNUCUDAN (SevkEdenIcmalUclari). Komisyonu prim
 * motoru üretir; "Komisyonları Onayla" ve "Ödeme Listesi Oluştur" Prim
 * modülünün uçlarını çağırır (/api/prim/onayla, /api/prim/donem-kapat).
 */
type Sekme = 'doktor' | 'basvuru' | 'odeme';

export function SevkEdenIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const gecen = (() => { const d = new Date(); d.setMonth(d.getMonth() - 1); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? gecen.bas;
  const bit = arama.get('bit') ?? gecen.bit;
  const seciliAnahtar = arama.get('gonderenler') ?? '';
  const secili = seciliAnahtar.split(',').map(Number).filter(n => n > 0);
  const [veri, setVeri] = useState<SevkEdenIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('doktor');
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [tazele, setTazele] = useState(0);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v) yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true });
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.sevkEdenIcmali(bas, bit, seciliAnahtar ? seciliAnahtar.split(',').map(Number) : [])
      .then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, seciliAnahtar, tazele]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const ayKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`); const y = new Date(d.getFullYear(), d.getMonth() + n, 1);
    const a = ayAraligi(y.getFullYear(), y.getMonth() + 1); degistir({ bas: a.bas, bit: a.bit, gonderenler: '' });
  };

  // ONAY: yalnız "kesin" (2) satırlar - taslak satır onaylanamaz (fatura bekliyor, kural veritabanında).
  const onaylanacak = (veri?.odemeler ?? []).filter(x => x.durum === 2);
  const komisyonOnayla = () => void guvenli(async () => {
    if (!onaylanacak.length) return;
    if (!(await onay(`${onaylanacak.length} komisyon (gönderen primi) satırı onaylansın mı? `
          + `Toplam ${paraYaz(onaylanacak.reduce((t, x) => t + x.tutar, 0))}. Onaylı satır kilitlenir.`))) return;
    const r = await api.primOnayla({ satirlar: onaylanacak.map(x => x.id) });
    mesaj(`${r.satirSayisi} satır onaylandı.`); setTazele(t => t + 1);
  });

  // ÖDEME LİSTESİ: her gönderen için dönemin satırları hakediş başlığına bağlanır (geri alınamaz).
  const listeye = (veri?.doktorlar ?? []).filter(d => (secili.length === 0 || secili.includes(d.id))
    && (veri?.odemeler ?? []).some(x => x.gonderenId === d.id && !x.hakedisId && x.durum >= 2));
  const odemeListesi = () => void guvenli(async () => {
    if (!listeye.length) return;
    if (!(await onay(`${listeye.length} gönderen için ${bas} – ${bit} komisyonları ödeme listesine (hakediş) alınsın mı? `
          + 'Bu işlem geri alınamaz; satırlar dondurulur.', true))) return;
    let n = 0;
    for (const d of listeye) { await api.primDonemKapat({ tarafId: d.id, baslangic: bas, bitis: bit }); n++ }
    mesaj(`${n} gönderen için ödeme listesi oluşturuldu (Hakedişler).`); setTazele(t => t + 1);
  });

  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['doktor', 'Dış Doktorlar', veri.doktorlar.length], ['basvuru', 'Sevkli Başvurular', veri.basvurular.length],
    ['odeme', 'Komisyon Ödemeleri', veri.odemeler.length]] : [];
  const sevkDegisim = o && o.oncekiBasvuru > 0 ? Math.round(100 * (o.basvuru - o.oncekiBasvuru) / o.oncekiBasvuru) : null;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + SEVK_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Sevk Eden İcmali</h1>
          <span className="yol">İK › Sevk Eden İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <button className="hi-yesil" disabled={!onaylanacak.length} title={onaylanacak.length ? '' : 'Onay bekleyen (kesin) komisyon satırı yok'}
                onClick={komisyonOnayla}>✔ Komisyonları Onayla{onaylanacak.length ? ` (${onaylanacak.length})` : ''}</button>
        <button disabled={!listeye.length} title={listeye.length ? '' : 'Listeye alınacak komisyon yok'}
                onClick={odemeListesi}>🧾 Ödeme Listesi Oluştur{listeye.length ? ` (${listeye.length})` : ''}</button>
        <span className="ki-ayrac" />
        {/* ÇIKTI MENÜSÜ: Baskı Önizleme / Yazıcıya Yazdır / Gönder ▸ - A4 menünün içinde, ayrı önizleme sekmesi yok. */}
        <CiktiMenusu etiket="Sevk Eden İcmali" dosyaAdi={`Sevk Eden İcmali ${bas} - ${bit}`} devre={!veri}>
          {veri && <SevkA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
        </CiktiMenusu>
        <span className="sp" />
        <button onClick={() => git('/hakedis')}>💼 Hakedişler</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">📅 Dönem:
            <button className="ki-ok" title="Önceki ay" onClick={() => ayKaydir(-1)}>‹</button>
            <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value, gonderenler: '' })} />–
            <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value, gonderenler: '' })} />
            <button className="ki-ok" title="Sonraki ay" onClick={() => ayKaydir(1)}>›</button>
          </div>
          {secili.length > 0 && <div className="sel">☑ {secili.length} gönderen <a className="ki-lnk" onClick={() => degistir({ gonderenler: '' })}>temizle</a></div>}
          <span className="sp" />
          <span className="ki-soluk">karşılaştırma: {new Date(veri.donem.oncekiBas).toLocaleDateString('tr-TR')} – {new Date(veri.donem.oncekiBit).toLocaleDateString('tr-TR')}</span>
        </div>

        <div className="hi-ozet">
          {kutu('Sevk Eden', String(o.gonderen), `${o.disHekim} dış hekim · ${o.kurum} kurum`)}
          {kutu('Sevkli Başvuru', String(o.basvuru), sevkDegisim == null ? 'önceki dönem yok' : `önceki döneme göre %${sevkDegisim}`)}
          {kutu('Sevkli Ciro', paraYaz(o.ciro), 'gönderilen kalemler', 'mor')}
          {kutu('Ort. Başvuru', paraYaz(o.ortBasvuru), 'ciro / sevk')}
          {kutu('Komisyon', paraYaz(o.komisyon), 'gönderen primi', 'uy')}
          {kutu('Ödenen', paraYaz(o.odenen), 'hakedişte ödendi', 'iyi')}
          {kutu('Bekleyen', paraYaz(o.bekleyen), 'ödenmemiş komisyon', o.bekleyen > 0.005 ? 'teh' : '')}
          {kutu('Yeni Doktor', String(o.yeni), 'önceki dönemde sevki yok')}
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
            {sekme === 'doktor' && <DoktorTablosu v={veri} secili={secili} setSecili={s => degistir({ gonderenler: s.join(',') })} />}
            {sekme === 'basvuru' && <BasvuruTablosu v={veri} />}
            {sekme === 'odeme' && <OdemeTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const SEVK_STILI = `
.a4-t.sv-a4t { font-size:8.5px; }
.a4-t.sv-a4t th:nth-child(1) { width:30%; } .a4-t.sv-a4t th:nth-child(2) { width:14%; }
.a4-t.sv-a4t th:nth-child(-n+2), .a4-t.sv-a4t td:nth-child(-n+2) { text-align:left; }
`;

export default SevkEdenIcmal;
