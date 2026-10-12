import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../../api/sozlesme';
import type { KysAyar } from '../../../api/uclar/kysAyar';
import { guvenli } from '../../../bilesenler/mesaj';
import { useOturum } from '../../../kimlik/OturumBaglami';
import { c } from '../../../dil/ceviri';
import { DuzenleSilDugmeleri, silOnayi } from '../kysSecim';

/**
 * KURUMSAL KALİTE — AYARLAR (1069, mockup Ekranlar/Kalite2/ayarlar.html).
 * İki sekme: Birim Sorumluları (Birim · Kalite sorumlusu · Yedek; kart generic
 * /kys-birim-sorumlu/:id) ve Genel (DÖF termini, risk renk eşikleri, genel
 * kalite sorumlusu, olay bildiriminde anonim seçeneği - /api/kys-ayar).
 * Yetki tek kod: kys.ayar.
 */
const GERI = `?geri=${encodeURIComponent('/kys-ayarlar')}`;

export function KysAyarlar() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [sekme, setSekme] = useState<'b' | 'g'>('b');
  const [satirlar, setSatirlar] = useState<ListeSatiri[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<ListeSatiri | null>(null);
  const [yenile, setYenile] = useState(0);

  useEffect(() => {
    api.liste('kys-birim-sorumlu', { boyut: 500 })
      .then(y => setSatirlar(y.satirlar)).catch(h => setHata(hataMetni(h)));
  }, [yenile]);

  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>⚙️ {c('Kalite Ayarları')}</h1>
        <span className="yol">Kalite › Ayarlar</span></div></div>

      <div className="katab">
        <div className={`kat${sekme === 'b' ? ' on' : ''}`} onClick={() => setSekme('b')}>{c('Birim Sorumluları')}<span className="b">{satirlar?.length ?? 0}</span></div>
        <div className={`kat${sekme === 'g' ? ' on' : ''}`} onClick={() => setSekme('g')}>{c('Genel')}</div>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {sekme === 'b' && (<>
        {yetki('kys.ayar', 'ekle') && (
          <div className="kys-ayar-arac"><button className="d bir" onClick={() => git(`/kys-birim-sorumlu/yeni${GERI}`)}>＋ {c('Ekle')}</button>
            <DuzenleSilDugmeleri secili={!!secili} duzenleYetki={yetki('kys.ayar', 'degistir')} silYetki={yetki('kys.ayar', 'sil')}
              duzenle={() => secili && git(`/kys-birim-sorumlu/${secili.id}${GERI}`)}
              sil={() => void guvenli(async () => {
                if (!secili || !await silOnayi(String(secili.departmanAdi ?? ''))) return;
                await api.kartSil('kys-birim-sorumlu', Number(secili.id)); setSecili(null); setYenile(t => t + 1);
              })} /></div>
        )}
        <table className="fm-tablo">
          <thead><tr><th>{c('Birim')}</th><th>{c('Kalite sorumlusu')}</th><th>{c('Yedek')}</th></tr></thead>
          <tbody>
            {(satirlar ?? []).map(s => (
              <tr key={String(s.id)} className={secili?.id === s.id ? 'kys-secili' : undefined} style={{ cursor: 'pointer' }}
                    onClick={() => setSecili(s)} onDoubleClick={() => git(`/kys-birim-sorumlu/${s.id}${GERI}`)}>
                <td>{String(s.departmanAdi ?? '')}</td><td>{String(s.sorumluAdi ?? '') || '—'}</td><td>{String(s.yedekAdi ?? '') || '—'}</td>
              </tr>
            ))}
            {satirlar && !satirlar.length && <tr><td colSpan={3} className="sonuk">{c('Birim sorumlusu tanımlanmamış - ＋ Ekle ile ekleyin.')}</td></tr>}
            {!satirlar && <tr><td colSpan={3} className="sonuk">{c('Yükleniyor…')}</td></tr>}
          </tbody>
        </table>
      </>)}

      {sekme === 'g' && <GenelAyarlar onKomiteler={() => git(`/kys-komite${GERI}`)} />}
    </div>
  );
}

function GenelAyarlar({ onKomiteler }: { onKomiteler(): void }) {
  const [a, setA] = useState<KysAyar | null>(null);
  const [ilk, setIlk] = useState<KysAyar | null>(null);
  const [duzenle, setDuzenle] = useState(false);
  const [personel, setPersonel] = useState<Record<string, string>>({});
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    api.kysAyar().then(y => { setA(y); setIlk(y); setDuzenle(y.duzenle) }).catch(h => setHata(hataMetni(h)));
    // Personel seçenekleri: birim sorumlusu kartının "sorumlu" alanıyla aynı liste.
    api.kartAlanlari('kys-birim-sorumlu')
      .then(m => setPersonel(m.alanlar.find(x => x.ad === 'sorumluId')?.kodlar ?? {})).catch(() => { /* seçim boş kalır */ });
  }, []);
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!a || !ilk) return <div className="sonuk">{c('Yükleniyor…')}</div>;

  const sayi = (k: keyof KysAyar) => (e: { target: { value: string } }) => setA(x => x && ({ ...x, [k]: Number(e.target.value) || 0 }));
  const degisti = JSON.stringify(a) !== JSON.stringify(ilk);
  const kaydet = () => void guvenli(async () => {
    const y = await api.kysAyarYaz(a);
    // Ayrı onay penceresi yok: Kaydet düğmesi pasifleşir, değerler sunucudan döner.
    setA(y); setIlk(y);
  });

  return (
    <div className="kys-politika">
      <div className="kys-politika-iki">
        <label className="alan"><span className="etiket">{c('DÖF varsayılan termini (gün)')}</span>
          <input type="number" min={1} max={365} value={a.dofTerminGun} disabled={!duzenle} onChange={sayi('dofTerminGun')} /></label>
        <label className="alan"><span className="etiket">{c('Risk skoru renk eşikleri')}</span>
          <span className="kys-ayar-esik">
            ≤ <input type="number" value={a.riskDusuk} disabled={!duzenle} onChange={sayi('riskDusuk')} /> {c('düşük')} ·
            ≤ <input type="number" value={a.riskOrta} disabled={!duzenle} onChange={sayi('riskOrta')} /> {c('orta')} ·
            ≤ <input type="number" value={a.riskYuksek} disabled={!duzenle} onChange={sayi('riskYuksek')} /> {c('yüksek')} · {c('üstü çok yüksek')}
          </span></label>
        <label className="alan"><span className="etiket">{c('Kalite sorumlusu (genel)')}</span>
          <select value={a.genelSorumluId ?? ''} disabled={!duzenle}
                  onChange={e => setA(x => x && ({ ...x, genelSorumluId: e.target.value ? Number(e.target.value) : null }))}>
            <option value="">—</option>
            {Object.entries(personel).sort((p, q) => p[1].localeCompare(q[1], 'tr')).map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
          </select></label>
        <label className="alan"><span className="etiket">{c('Olay bildiriminde anonim seçeneği')}</span>
          <select value={a.olayAnonim ? '1' : '0'} disabled={!duzenle} onChange={e => setA(x => x && ({ ...x, olayAnonim: e.target.value === '1' }))}>
            <option value="1">{c('Açık')}</option><option value="0">{c('Kapalı')}</option>
          </select></label>
      </div>
      {duzenle && <div><button className="d bir" disabled={!degisti} onClick={kaydet}>💾 {c('Kaydet')}</button></div>}
      <div className="sonuk">
        {c('Komiteler (toplantıda seçilir):')}{' '}
        <a href="#" onClick={e => { e.preventDefault(); onKomiteler() }}>👥 {c('Komiteler')}</a>
      </div>
    </div>
  );
}
