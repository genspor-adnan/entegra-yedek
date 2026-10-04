import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { DemoAyar, DemoDurum } from '../api/uclar/demo';
import { onay } from '../bilesenler/mesaj';
import { tarihSaat } from '../bilesenler/bicim';
import { c } from '../dil/ceviri';

/**
 * DEMO VERİSİ `/demo-verisi` (964, mockup Ekranlar/Ayarlar/demo_tohum.html).
 *
 * Kurum profili + ölçek + modüller → tanıtım verisi üretilir; aynı tohum aynı
 * veriyi verir, tarihler bugüne göre kayar. Yalnız DEMO işaretli kurulumda
 * çalışır - değilse ekran kilitli açılır (bayrak ekrandan değiştirilmez).
 */
const PROFILLER: [string, string, string][] = [
  ['hastane', '🏥 Hastane', 'poliklinik + yatan + acil'],
  ['tip_merkezi', '🩺 Tıp merkezi', 'poliklinik + lab + görüntüleme'],
  ['dis', '🦷 Ağız-diş', 'diş hekimi + lab işleri'],
  ['lab', '🧫 Laboratuvar', 'numune + KK + rapor'],
];
const OLCEK: [DemoAyar['olcek'], string, string][] = [
  ['kucuk', 'Küçük', '30 personel · 100 hasta · ~400 randevu'],
  ['orta', 'Orta', '85 personel · 300 hasta · ~1.400 randevu'],
  ['buyuk', 'Büyük', '150 personel · 800 hasta · ~4.000 randevu'],
];
/** Modüller: [kod, ad, ne üretilir, hazır mı]. Hazır olmayanlar bir sonraki aşamada. */
const MODULLER: [string, string, string, boolean][] = [
  ['yapi', 'Kurum adı', 'şube ünvanı (antet, yazılar) demo kurum adı olur', true],
  ['personel', 'Personel', 'başhekim, hekim (klinik dağılımlı), hemşire, kayıt kabul, lab, eczane, İK, idari', true],
  ['kullanici', 'Demo kullanıcıları', 'rol başına hazır hesap - giriş ekranında "Demo olarak dene"', true],
  ['hasta', 'Hasta', 'kurgusal TC (99…), yaş / cinsiyet dağılımı; senaryo hastası Elif Demo', true],
  ['randevu', 'Randevu', 'geçmiş (geldi / gelmedi / iptal) + bugün + ileri, 20 dk slot', true],
  ['ik', 'İK talepleri', 'yıllık izin (geçmiş / planlı / taslak), avans, belge talebi', true],
  ['muayene', 'Başvuru / muayene', 'ICD-10 tanı, reçete', false],
  ['lab', 'Laboratuvar', 'istem → numune → sonuç (referans dışı, panik)', false],
  ['radyoloji', 'Radyoloji', 'istem + rapor', false],
  ['yatan', 'Yatan / acil / ameliyat', 'yatak doluluğu, triyaj, ameliyat planı', false],
  ['eczane', 'Eczane / stok', 'ilaç hareketleri, kritik stok', false],
  ['fatura', 'Fatura / Medula', 'provizyon + fatura (simülasyon)', false],
];

export function DemoVerisi() {
  const [d, setD] = useState<DemoDurum | null>(null);
  const [ayar, setAyar] = useState<DemoAyar | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);

  const yukle = useCallback(async () => {
    try {
      const y = await api.demoDurum();
      setD(y);
      setAyar(o => o ?? y.ayar);
    } catch (e) { setHata(hataMetni(e)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  // ÇALIŞIRKEN 1,5 sn'de bir ilerleme okunur.
  const calisiyor = d?.son?.durum === 0;
  useEffect(() => {
    if (!calisiyor) return;
    const t = window.setInterval(() => void yukle(), 1500);
    return () => window.clearInterval(t);
  }, [calisiyor, yukle]);

  if (!d || !ayar) return <div className="dv-sayfa"><div className="sonuk" style={{ padding: 24 }}>{hata ?? `${c('yükleniyor')}…`}</div></div>;

  const kilitli = !d.demo;
  const yaz = <K extends keyof DemoAyar>(k: K, v: DemoAyar[K]) => setAyar(o => o && ({ ...o, [k]: v }));
  const modulDegistir = (m: string) => yaz('moduller', ayar.moduller.includes(m) ? ayar.moduller.filter(x => x !== m) : [...ayar.moduller, m]);
  const ozet = (() => { try { return JSON.parse(d.son?.ozet ?? '{}') as Record<string, number> } catch { return {} } })();

  const calistir = async (temizleYalniz: boolean) => {
    const soru = temizleYalniz
      ? c('Demo verisi silinsin mi? (yalnız demo kayıtları ve demo kişilere bağlı randevu / talepler)')
      : c('Demo verisi silinip bu ayarla yeniden üretilsin mi?');
    if (!await onay(soru)) return;
    setMesgul(true); setHata(null);
    try {
      await api.demoAyarYaz(ayar);
      await api.demoUret(temizleYalniz);
      await yukle();
    } catch (e) { setHata(hataMetni(e)) } finally { setMesgul(false) }
  };
  const gece = async (aktif: boolean) => {
    try { await api.demoGece(aktif); await yukle() } catch (e) { setHata(hataMetni(e)) }
  };
  const sure = d.son?.bitis ? Math.round((new Date(d.son.bitis).getTime() - new Date(d.son.baslangic).getTime()) / 100) / 10 : null;

  return (
    <div className="dv-sayfa">
      <div className="sayfabas">
        <div className="basrow">
          <h1>🧪 {c('Demo Verisi')}</h1><span className="yol">{c('Yönetim › Kurulum › Demo verisi')}</span>
          <span className="ck-bosluk" />
          <button type="button" className="d bir" disabled={kilitli || mesgul || calisiyor} onClick={() => void calistir(false)}>▶ {c('Sıfırla ve üret')}</button>
          <button type="button" className="d tl-tehlike" disabled={kilitli || mesgul || calisiyor} onClick={() => void calistir(true)}>🗑 {c('Demo verisini temizle')}</button>
        </div>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {kilitli && (
        <div className="dv-kilit">🔒 {c('Bu kurulum DEMO değil.')} {c('Demo verisi yalnız tanıtım kurulumunda üretilir; canlı veriye yazılmaz, canlı veri silinmez.')}
          <br /><small>{c('Tanıtım kurulumunu açmak için sunucuda:')} <code>update public.referans set deger = '1' where anahtar = 'kurulum.demo';</code></small></div>
      )}

      <div className="dv-serit">
        <div><span>{c('Mod')}</span><b>{d.demo ? <span className="rozet uyari">DEMO</span> : <span className="rozet gri">{c('Canlı')}</span>}</b></div>
        <div><span>{c('Son üretim')}</span><b>{d.son ? `${tarihSaat(d.son.baslangic)} · ${d.son.tetik === 'gece' ? c('gece') : c('elle')}` : '—'}</b></div>
        <div><span>{c('Tohum')}</span><b>#{d.son?.tohum ?? ayar.tohum}</b></div>
        <div><span>{c('Dış gönderim')}</span><b>{d.demo ? <span className="rozet olumlu">{c('Kapalı (SMS / e-posta)')}</span> : <span className="rozet gri">{c('Normal')}</span>}</b></div>
        <div className="dv-sag"><span>{c('Gece yenileme')}</span><b>
          <label className="dv-anahtar"><input type="checkbox" disabled={kilitli} checked={d.gece?.aktif === 1} onChange={e => void gece(e.target.checked)} />
            {d.gece?.aktif === 1 ? c('Her gün 03:00') : c('Kapalı')}</label></b></div>
      </div>

      <div className="dv-govde">
        <div>
          <div className="ck-grp">
            <h6>{c('Kurum profili')}<span className="ck-ek">{c('ekranlar ve modüller profile göre')}</span></h6>
            <div className="ck-iz">
              <div className="ck-tam it-turler">
                {PROFILLER.map(([k, a, n]) => (
                  <button key={k} type="button" disabled={kilitli} className={ayar.profil === k ? 'it-on' : ''} onClick={() => yaz('profil', k)}>
                    <b>{c(a)}</b><span>{c(n)}</span></button>
                ))}
              </div>
              <label className="rk-fld"><span className="ck-etiket">{c('Kurum adı (antet)')}</span>
                <input value={ayar.kurumAdi} disabled={kilitli} maxLength={120} onChange={e => yaz('kurumAdi', e.target.value)} /></label>
              <label className="rk-fld"><span className="ck-etiket">{c('Şehir / ilçe')}</span>
                <input value={ayar.sehir} disabled={kilitli} maxLength={80} onChange={e => yaz('sehir', e.target.value)} /></label>
              <label className="rk-fld"><span className="ck-etiket">{c('Tohum')} <span className="sonuk">({c('aynı tohum = aynı veri')})</span></span>
                <input type="number" min={1} max={999999} value={ayar.tohum} disabled={kilitli} onChange={e => yaz('tohum', Number(e.target.value) || 1)} /></label>
              <div className="rk-fld"><span className="ck-etiket">{c('Tarih ekseni')}</span>
                <input disabled value={c('Bugüne göre (geçmiş + bugün + ileri)')} /></div>
            </div>
          </div>

          <div className="ck-grp">
            <h6>{c('Ölçek ve modüller')}<span className="ck-ek">{c('kapalı modül üretilmez')}</span></h6>
            <div className="dv-olcek">
              <span className="sonuk">{c('Ölçek')}</span>
              {OLCEK.map(([k, a, n]) => (
                <button key={k} type="button" disabled={kilitli} title={c(n)} className={`ck-cip${ayar.olcek === k ? ' on' : ''}`} onClick={() => yaz('olcek', k)}>{c(a)}</button>
              ))}
              <span className="sonuk">{c(OLCEK.find(x => x[0] === ayar.olcek)?.[2] ?? '')}</span>
            </div>
            <table className="dv-tablo">
              <thead><tr><th /><th>{c('Modül')}</th><th>{c('Ne üretilir')}</th><th className="sag">{c('Son üretim')}</th></tr></thead>
              <tbody>
                {MODULLER.map(([k, a, n, hazir]) => (
                  <tr key={k} className={hazir ? undefined : 'dv-sonra'}>
                    <td><input type="checkbox" disabled={kilitli || !hazir} checked={hazir && ayar.moduller.includes(k)} onChange={() => modulDegistir(k)} /></td>
                    <td><b>{c(a)}</b></td>
                    <td>{c(n)}{!hazir && <span className="rozet gri dv-rozet">{c('sonraki aşama')}</span>}</td>
                    <td className="sag">{ozet[k] != null ? ozet[k].toLocaleString('tr-TR') : '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <div className="tl-uyari" style={{ margin: 12 }}>⚠ {c('Bütün kişiler kurgusal: TC kimlik numarası 99 ile başlar (algoritmaya uyar, kimseye ait değil), telefonlar 0500 000 xx xx, e-postalar @ornek.test.')}</div>
          </div>

          <div className="ck-grp">
            <h6>{c('Demo kullanıcıları')}<span className="ck-ek">{c('giriş ekranında "Demo olarak dene"')}</span></h6>
            <table className="dv-tablo">
              <thead><tr><th>{c('Rol')}</th><th>{c('Kullanıcı')}</th><th>{c('Parola')}</th><th>{c('Kişi')}</th><th>{c('Açılış')}</th></tr></thead>
              <tbody>
                {d.tanimli.map(t => {
                  const k = d.kullanicilar.find(x => x.kod === t.kod);
                  return (
                    <tr key={t.kod} className={k ? undefined : 'dv-sonra'}>
                      <td>{c(t.baslik)}</td><td><code>{t.kod}</code></td><td><code>{d.parola}</code></td>
                      <td>{k?.ad ?? <span className="sonuk">{c('üretilmedi')}</span>}</td><td className="sonuk">{c(t.acilis)}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
            <div className="sonuk" style={{ padding: '6px 12px 10px' }}>{c('Demo kullanıcıları parolalarını değiştiremez; yetkileri rollerinden gelir (ayar / yetki yönetimi yok).')}</div>
          </div>
        </div>

        <div>
          <div className="ck-grp">
            <h6>{c('Üretim')}<span className="ck-ek">{calisiyor ? c('çalışıyor') : d.son?.durum === 1 ? `${c('tamamlandı')}${sure != null ? ` · ${sure} sn` : ''}` : d.son?.durum === 2 ? c('hata') : ''}</span></h6>
            {!d.son ? <div className="sonuk" style={{ padding: 12 }}>{c('Henüz üretilmedi.')}</div> : (
              <div className="it-akis">
                <div>{c(d.son.adim)}<small>{tarihSaat(d.son.baslangic)}</small></div>
                {Object.entries(ozet).map(([k, v]) => (
                  <div key={k}>{c(k === 'silinen' ? 'Silinen kayıt' : k === 'baglidanKalan' ? 'Başka kayda bağlı kalan kişi' : MODULLER.find(m => m[0] === k)?.[1] ?? k)}
                    <small>{Number(v).toLocaleString('tr-TR')}</small></div>
                ))}
                {d.son.hata && <div className="tl-gec">{d.son.hata}</div>}
              </div>
            )}
          </div>

          <div className="ck-grp">
            <h6>{c('Bugünün sahnesi')}<span className="ck-ek">{c('demo başında görünen')}</span></h6>
            <div className="it-akis">
              <div>{c('Bugünkü randevu')}<small>{d.sahne?.bugunRandevu ?? 0}</small></div>
              <div>{c('Bugün sırada bekleyen')}<small>{d.sahne?.bekleyen ?? 0}</small></div>
              <div>{c('Demo hasta / personel')}<small>{d.sahne?.hasta ?? 0} / {d.sahne?.personel ?? 0}</small></div>
              <div>{c('Senaryo hastası')}<small>{d.sahne?.senaryo ?? '—'}</small></div>
            </div>
          </div>

          <div className="ck-grp">
            <h6>{c('Gece yenileme')}</h6>
            <div className="it-akis">
              <div>{c('Zamanlama')}<small>{d.gece?.aktif === 1 ? c('Her gün 03:00') : c('Kapalı')}</small></div>
              <div>{c('Ne yapar')}<small>{c('temizle + aynı tohumla üret; ziyaretçi kayıtları da gider')}</small></div>
              <div>{c('Son 7 gün')}<small>{d.gece7 ? `${d.gece7.basarili} / ${d.gece7.toplam} ${c('başarılı')}` : '—'}</small></div>
            </div>
          </div>

          <div className="dv-guvenlik">🔒 {c('Bu ekran yalnız DEMO işaretli kurulumda yazar (kurulum.demo = 1). Canlı kurulumda üretim / temizlik uçları 403 döner.')}</div>
        </div>
      </div>
    </div>
  );
}
