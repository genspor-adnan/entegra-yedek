import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { FormKutuphaneSatiri } from '../../api/uclar/form';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';

/**
 * FORM KÜTÜPHANESİ `/form-kutuphane` (form motoru 740) — mockup
 * Ekranlar/Formlar/formlar.html › Kütüphane sekmesi. Bakanlık / SKS resmî
 * şablonları (resmi = 1, kilitli): kurum tipine göre süzülür, "kur" ile kurum
 * kopyası açılır (ust_sablon_id), resmî sürüm ilerlemişse "güncelle".
 */
const AILE: Record<number, [string, string]> = { 1: ['Onam', 'mor'], 2: ['Değerlendirme', 'mavi'], 3: ['Kontrol listesi', 'ok'], 4: ['Beyan', 'ok'], 5: ['Anket', 'uyari'] };
const KURUM: Record<string, string> = { hastane: 'Hastane', tip_merkezi: 'Tıp Mrk.', dis: 'ADSM', muayenehane: 'Muayenehane', dal_goz: 'Göz', dal_ftr: 'FTR', lab: 'Lab', goruntuleme: 'Görüntüleme', goruntuleme_lab: 'Gör.+Lab', osgb: 'OSGB' };

export function FormKutuphane() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [liste, setListe] = useState<FormKutuphaneSatiri[]>([]);
  const [kurumTipi, setKurumTipi] = useState('');
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<Set<string>>(new Set());
  const [kaynak, setKaynak] = useState('');
  const [yalnizTip, setYalnizTip] = useState(true);
  const [ara, setAra] = useState('');

  const yukle = useCallback(async () => {
    try { const y = await api.formKutuphane(); setListe(y.liste); setKurumTipi(y.kurumTipi); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  const kaynaklar = [...new Set(liste.map(x => x.kaynak))];
  const uygun = (x: FormKutuphaneSatiri) => !yalnizTip || !x.kurumTipleri || !kurumTipi || x.kurumTipleri.split(',').map(s => s.trim()).includes(kurumTipi);
  const gorunen = liste.filter(x => (!kaynak || x.kaynak === kaynak) && uygun(x) && (!ara || `${x.ad} ${x.kod} ${x.kaynakKod}`.toLocaleLowerCase('tr').includes(ara.toLocaleLowerCase('tr'))));
  const kur = async (kodlar: string[]) => {
    if (!kodlar.length) { mesaj('Şablon seçin.'); return }
    if (!await onay(`${kodlar.length} şablon kuruma kopyalansın / güncellensin mi?`)) return;
    await guvenli(async () => {
      const y = await api.formKutuphaneKur(kodlar);
      mesaj(`Kuruldu: ${y.kurulan.length} · güncellendi: ${y.guncellenen.length}`);
      setSecili(new Set()); await yukle();
    });
  };
  const sayac = (f: (x: FormKutuphaneSatiri) => boolean) => liste.filter(x => uygun(x) && f(x)).length;
  const gruplar = new Map<string, FormKutuphaneSatiri[]>();
  for (const x of gorunen) { const k = `${AILE[x.aile]?.[0] ?? ''} · ${x.kaynak}`; gruplar.set(k, [...(gruplar.get(k) ?? []), x]) }

  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>📚 Form Kütüphanesi (Bakanlık / SKS)</h1><span className="yol">Yönetim › Formlar › Kütüphane</span>
        <div className="sag"><button className="d" onClick={() => git('/form-sablon')}>Şablonlar</button></div></div></div>
      <div className="fm-doldur-arac">
        {yetki('form.sablon') && <>
          <button className="d bir" onClick={() => void kur([...secili])}>📦 Seçilenleri kur ({secili.size})</button>
          <button className="d" onClick={() => void kur(gorunen.filter(x => x.kuruluId == null).map(x => x.kod))}>Kurum tipine göre hepsini kur</button>
          <button className="d" onClick={() => void kur(gorunen.filter(x => x.kuruluId != null && (x.kuruluSurum ?? 0) < x.surum).map(x => x.kod))}>🔄 Sürüm güncelle ({sayac(x => x.kuruluId != null && (x.kuruluSurum ?? 0) < x.surum)})</button>
        </>}
        <span className="sonuk">Kaynak:</span>
        <button className={`d${!kaynak ? ' bir' : ''}`} onClick={() => setKaynak('')}>Tümü</button>
        {kaynaklar.map(k => <button key={k} className={`d${kaynak === k ? ' bir' : ''}`} onClick={() => setKaynak(k)}>{k}</button>)}
        <label className="fm-onay" style={{ margin: 0 }}><input type="checkbox" checked={yalnizTip} onChange={e => setYalnizTip(e.target.checked)} /><span>Kurum tipi: {(KURUM[kurumTipi] ?? kurumTipi) || "—"}</span></label>
        <span className="sp" />
        <input className="fm-giris" style={{ width: 200 }} placeholder="🔍 form ara" value={ara} onChange={e => setAra(e.target.value)} />
      </div>
      <div className="fm-kpis">
        <div className="fm-kpi"><div className="b">Kütüphanede</div><div className="d">{liste.length}</div></div>
        <div className="fm-kpi"><div className="b">Bu kurum tipinde</div><div className="d">{liste.filter(uygun).length}</div></div>
        <div className="fm-kpi"><div className="b">Kurulu</div><div className="d ok">{sayac(x => x.kuruluId != null)}</div></div>
        <div className="fm-kpi"><div className="b">Kurulabilir</div><div className="d">{sayac(x => x.kuruluId == null)}</div></div>
        <div className="fm-kpi"><div className="b">Yeni sürüm</div><div className={`d${sayac(x => x.kuruluId != null && (x.kuruluSurum ?? 0) < x.surum) ? ' sari' : ''}`}>{sayac(x => x.kuruluId != null && (x.kuruluSurum ?? 0) < x.surum)}</div></div>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {[...gruplar.entries()].map(([grup, satirlar]) => (
        <section key={grup} className="fm-bolum">
          <h3 className="fm-bolum-bas">{grup}</h3>
          <table className="fm-tablo">
            <thead><tr><th></th><th>Kod</th><th>Form</th><th>Aile</th><th>Kurum tipi</th><th>Kanal</th><th>Sürüm</th><th>Durum</th><th>Not</th><th></th></tr></thead>
            <tbody>
              {satirlar.map(x => {
                const kurulu = x.kuruluId != null; const guncel = kurulu && (x.kuruluSurum ?? 0) < x.surum;
                return (
                  <tr key={x.id}>
                    <td><input type="checkbox" checked={secili.has(x.kod)} onChange={e => setSecili(s => { const y = new Set(s); if (e.target.checked) y.add(x.kod); else y.delete(x.kod); return y })} /></td>
                    <td><code>{x.kaynakKod || x.kod}</code></td>
                    <td><b>{x.ad}</b></td>
                    <td><span className={`rozet ${AILE[x.aile]?.[1] ?? 'mor'}`}>{AILE[x.aile]?.[0]}</span></td>
                    <td>{x.kurumTipleri ? x.kurumTipleri.split(',').map(k => <span key={k} className="fm-kt">{KURUM[k.trim()] ?? k}</span>) : <span className="sonuk">hepsi</span>}</td>
                    <td>{['', 'İç ekran', 'Tablet', 'SMS', 'E-posta'][x.kanal] ?? ''}{x.tekrarSaat ? ` · ${x.tekrarSaat} s tekrar` : ''}{x.asamali ? ' · aşamalı' : ''}</td>
                    <td className="fm-sag">v{x.surum}</td>
                    <td>{guncel ? <span className="rozet uyari">Yeni sürüm var (kurulu v{x.kuruluSurum})</span> : kurulu ? <span className="rozet ok">Kurulu v{x.kuruluSurum}{x.kuruluDurum === 2 ? ' (pasif)' : ''}</span> : <span className="rozet mor">Kurulabilir</span>}</td>
                    <td className="fm-not">{x.aciklama}</td>
                    <td className="fm-sag">
                      {yetki('form.sablon') && (!kurulu || guncel) && <button className="d mini" onClick={() => void kur([x.kod])}>{kurulu ? 'Güncelle' : 'Kur'}</button>}
                      {kurulu && <button className="d mini" onClick={() => git(`/form-sablon/${x.kuruluId}`)}>Aç</button>}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </section>
      ))}
      <div className="sonuk fm-not" style={{ padding: 12 }}>
        Resmî kopya kilitlidir; "Kur" kurum kopyasını açar (kurum düzenler, imza / başlık ekler). Resmî sürüm ilerleyince "Güncelle" tanımı tazeler - dolduranlar kendi sürümüyle saklanır. Kanal, tekrar ve aşama şablondan gelir; tetikleyiciler Kurallar listesinden.
      </div>
    </div>
  );
}
