import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { IsgFirmaSatiri, IsgTakvim as Takvim } from '../../api/uclar/isg';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay, secimSor } from '../../bilesenler/mesaj';

/**
 * PERİYODİK MUAYENE TAKVİMİ `/isg-takvim` (İSG 741) — mockup
 * Ekranlar/ISG/isg_periyodik_takvim.html. Vade kuralı hesaplanır, elle
 * girilmez (tehlike sınıfı → gece → hekim kısaltması → portör). Seçilenlere
 * toplu Ek-2 açma + SMS; süzgeçler firma / dönem / tür.
 */
export function IsgTakvim() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [firmalar, setFirmalar] = useState<IsgFirmaSatiri[]>([]);
  const [firmaId, setFirmaId] = useState(0);
  const [gun, setGun] = useState(30);
  const [tur, setTur] = useState<'' | 'gecen' | 'giris'>('');
  const [t, setT] = useState<Takvim | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<Set<number>>(new Set());

  useEffect(() => { api.isgPano().then(p => setFirmalar(p.firmalar)).catch(() => {}) }, []);
  const yukle = useCallback(async () => {
    try { setT(await api.isgTakvim({ firmaId: firmaId || undefined, gun, tur: tur || undefined })); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, [firmaId, gun, tur]);
  useEffect(() => { void yukle() }, [yukle]);

  const toplu = async () => {
    if (!secili.size) { mesaj('Çalışan seçin.'); return }
    const mtur = await secimSor('Muayene türü', [{ kod: '2', ad: 'Periyodik' }, { kod: '1', ad: 'İşe giriş' }]); if (!mtur) return;
    if (!await onay(`${secili.size} çalışana Ek-2 muayenesi açılıp çalışan bölümü SMS ile gönderilsin mi?`)) return;
    await guvenli(async () => {
      const y = await api.isgToplu([...secili], Number(mtur), 3);
      mesaj(`Açılan: ${y.acilan}${y.hatalar.length ? `\nHata: ${y.hatalar.join(' · ')}` : ''}`);
      setSecili(new Set()); await yukle();
    });
  };
  const tarih = (d?: string | null) => d ? new Date(d).toLocaleDateString('tr-TR') : '—';
  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>📅 Periyodik Muayene Takvimi</h1><span className="yol">İşyeri Hekimliği › Periyodik Takvim{t ? ` · vadesi geçen ${t.gecen}` : ''}</span>
        <div className="sag"><button className="d" onClick={() => git('/isg-pano')}>🏭 Firma panosu</button></div></div></div>
      <div className="fm-doldur-arac">
        <span className="sonuk">Firma:</span>
        <select className="fm-giris" value={firmaId} onChange={e => setFirmaId(Number(e.target.value))}><option value={0}>Tümü</option>{firmalar.map(f => <option key={f.id} value={f.id}>{f.firma_adi}</option>)}</select>
        <span className="sonuk">Dönem:</span>
        <button className={`d${tur === 'gecen' ? ' bir' : ''}`} onClick={() => setTur(tur === 'gecen' ? '' : 'gecen')}>Vadesi geçen</button>
        {[30, 90, 365].map(g => <button key={g} className={`d${!tur && gun === g ? ' bir' : ''}`} onClick={() => { setTur(''); setGun(g) }}>{g === 365 ? 'Yıl' : `${g} gün`}</button>)}
        <button className={`d${tur === 'giris' ? ' bir' : ''}`} onClick={() => setTur(tur === 'giris' ? '' : 'giris')}>İşe giriş bekleyen</button>
        <span className="sp" />
        {yetki('isg.muayene', 'ekle') && <button className="d bir" onClick={() => void toplu()}>📱 Seçilenlere Ek-2 aç + SMS ({secili.size})</button>}
      </div>
      {t && (
        <div className="isg-aylar">
          <div className={`isg-ay${tur === 'gecen' ? ' on' : ''}`} onClick={() => setTur('gecen')}><b>Vadesi geçen</b><div className="sy k">{t.gecen}</div></div>
          {t.aylar.map(a => <div key={a.ay} className="isg-ay"><b>{new Date(a.ay + '-01').toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' })}</b><div className="sy">{a.sayi}</div></div>)}
        </div>
      )}
      {hata && <div className="hata-kutusu">{hata}</div>}
      <section className="fm-bolum">
        <table className="fm-tablo">
          <thead><tr>
            <th><input type="checkbox" checked={!!t?.satirlar.length && secili.size === t.satirlar.length} onChange={e => setSecili(e.target.checked ? new Set(t?.satirlar.map(x => x.id)) : new Set())} /></th>
            <th>Çalışan</th><th>Firma</th><th>Bölüm / görev</th><th>Tehlike</th><th>Son muayene</th><th>Vade</th><th>Kalan</th><th>Tetkik paketi</th><th>Açık</th><th>Durum</th><th></th>
          </tr></thead>
          <tbody>
            {t?.satirlar.map(c => (
              <tr key={c.id}>
                <td><input type="checkbox" checked={secili.has(c.id)} onChange={e => setSecili(s => { const y = new Set(s); if (e.target.checked) y.add(c.id); else y.delete(c.id); return y })} /></td>
                <td><b>{c.calisan_adi}</b></td><td>{c.firma_adi}</td><td>{c.bolum_adi}{c.gorev ? ` · ${c.gorev}` : ''}</td>
                <td><span className={`isg-teh isg-teh-${c.tehlike === 1 ? 'az' : c.tehlike === 2 ? 't' : 'ct'}`}>{c.tehlike_adi}</span></td>
                <td>{tarih(c.son_muayene)}{c.son_kanaat === 2 ? ' (koşullu)' : ''}</td><td>{c.muayene_sayisi ? tarih(c.vade) : 'işe giriş'}</td>
                <td>{c.kalan_gun < 0 ? <span className="rozet hata">{c.kalan_gun} gün</span> : <span className={c.kalan_gun <= 7 ? 'isg-kir' : ''}>{c.kalan_gun} gün</span>}</td>
                <td className="fm-not">{c.tetkik_paketi}</td>
                <td>{c.acik_muayene ? <span className="rozet mor">Açık</span> : '—'}</td>
                <td>{c.acik_muayene ? <span className="rozet mor">Form gönderildi</span> : c.kalan_gun < 0 ? <span className="rozet hata">Vadesi geçti</span> : c.muayene_sayisi === 0 ? <span className="rozet mor">İşe giriş bekliyor</span> : <span className="rozet uyari">Bekliyor</span>}</td>
                <td className="fm-sag"><button className="d mini" onClick={() => git(`/isg-calisan/${c.id}?geri=%2Fisg-takvim`)}>Kart</button></td>
              </tr>
            ))}
            {t && !t.satirlar.length && <tr><td colSpan={12} className="sonuk">Bu dönemde vadesi gelen çalışan yok.</td></tr>}
          </tbody>
        </table>
      </section>
      <div className="sonuk fm-not" style={{ padding: '0 4px' }}>Vade = son muayene + periyot (tehlike sınıfı 5/3/1 yıl → gece 2 yıl → hekimin Ek-2'de yazdığı sonraki tarih → portör 6 ay). Toplu gönderim: her çalışana Ek-2 muayenesi açılır, çalışan bölümü SMS bağlantısıyla gider; hekim bölümü iç ekranda tamamlanır. Firma Yetkilisi bu listeyi görür (sağlık verisi yok).</div>
    </div>
  );
}
