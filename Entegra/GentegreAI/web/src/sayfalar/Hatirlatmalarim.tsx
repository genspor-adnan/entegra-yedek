import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import type { Hatirlatma, HatirlatmaOzeti } from '../api/uclar/hatirlatma';
import { guvenli, onay } from '../bilesenler/mesaj';
import { tarihSaat } from '../bilesenler/bicim';
import { HATIRLATMA_DEGISTI_OLAYI, erteleSecenekleri, hatirlatmaDegisti, hatirlatmaPenceresiAc, kalanMetni,
         kayitIkonu } from '../bilesenler/hatirlatma/hatirlatmaDeposu';
import { HATIRLATMA_STIL } from '../bilesenler/hatirlatma/hatirlatmaStil';

/**
 * HATIRLATMALARIM (1139, mockup Ekranlar/Kullanici/kisisel_hatirlatici.html (2)). Kullanıcı menüsü ›
 * Hatırlatmalarım ve zil › "Tümünü gör". Kayıt kişiye özel - liste sunucuda süzülür (sahip + paylaşılan);
 * yetki kodu yok. Sayaç kartı çipi açar; takvimde gün seçmek listeyi o güne daraltır.
 */
const CIPLER: [string, string][] = [
  ['acik', 'Açık'], ['gec', 'Gecikmiş'], ['bugun', 'Bugün'], ['hafta', 'Bu hafta'], ['tekrar', 'Tekrarlayan'],
  ['paylasilan', 'Benimle paylaşılan'], ['tam', 'Tamamlanan'], ['hep', 'Tümü'],
];
const ONCELIK_RENK = ['', 'var(--cizgi)', '#9fb2c6', 'var(--hata)'];
const RENK = ['', 'var(--hatazem)', 'var(--uyarizem)', 'var(--okzem)', '#eef4fc'];
const AYLAR = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
const uyariMetni = (dk: number) => dk === 0 ? 'zamanında' : dk < 60 ? `${dk} dk önce` : dk < 1440 ? `${Math.round(dk / 60)} sa önce` : `${Math.round(dk / 1440)} gün önce`;

const STIL = `
.ht-sayfa { padding: 10px 14px }
.ht-cipler { display: flex; gap: 6px; flex-wrap: wrap; align-items: center; margin: 8px 0 }
.ht-cip { border: 1px solid var(--cizgi); border-radius: 14px; padding: 3px 12px; background: var(--yuz); cursor: pointer; color: var(--yazi); font: inherit }
.ht-cip.on { background: var(--mor); border-color: var(--mor); color: #fff; font-weight: 700 }
.ht-ara { margin-left: auto; min-width: 240px }
.ht-govde { display: grid; grid-template-columns: minmax(0, 1fr) 300px; gap: 12px; align-items: start }
@media (max-width: 1000px) { .ht-govde { grid-template-columns: 1fr } .ht-ara { margin-left: 0; min-width: 0; width: 100% } }
.ht-tablo-sar { overflow-x: auto; border: 1px solid var(--cizgi); border-radius: 4px }
.ht-tablo-sar .hk-tablo { border: none }
.hk-tablo tr.ht-satir { cursor: pointer }
.hk-tablo tr.ht-satir.sec td { background: var(--secili, #d7e7fb) }
.hk-tablo tr.ht-satir.gec td { background: var(--hatazem) }
.hk-tablo tr.ht-satir.tam td { color: var(--soluk) } .hk-tablo tr.ht-satir.tam td.bs { text-decoration: line-through }
.ht-nokta { display: inline-block; width: 9px; height: 9px; border-radius: 50% }
.ht-takvim { display: grid; grid-template-columns: repeat(7, 1fr); gap: 2px; font-size: 11.5px; text-align: center }
.ht-takvim .g { padding: 4px 0; color: var(--soluk); font-weight: 700 }
.ht-takvim button { border: none; background: none; padding: 5px 0; border-radius: 3px; cursor: pointer; position: relative; font: inherit; color: var(--yazi) }
.ht-takvim button:hover { background: var(--kartzem) }
.ht-takvim button.bos { color: var(--cizgi); cursor: default }
.ht-takvim button.bugun { box-shadow: 0 0 0 1px var(--mor) inset; font-weight: 700 }
.ht-takvim button.sec { background: var(--mor); color: #fff; font-weight: 700 }
.ht-takvim button.var::after { content: ""; position: absolute; left: 50%; bottom: 1px; width: 4px; height: 4px; border-radius: 50%;
  background: var(--uyari); transform: translateX(-50%) }
.ht-takvim button.gecvar::after { background: var(--hata) }
.ht-tbas { display: flex; align-items: center; margin-bottom: 6px; font-weight: 700; color: var(--yazi2) }
.ht-tbas button { border: none; background: none; cursor: pointer; font-size: 14px; color: var(--soluk) }
.ht-alt { display: flex; gap: 14px; padding: 6px 2px; font-size: 11.5px; color: var(--soluk); flex-wrap: wrap }
@media print { .ht-govde { grid-template-columns: 1fr } .ht-yan, .ht-cipler, .kul-ozet, .ht-arac { display: none !important } }
`;

export function Hatirlatmalarim() {
  const git = useNavigate();
  const [cip, setCip] = useState('acik');
  const [ara, setAra] = useState('');
  const [satirlar, setSatirlar] = useState<Hatirlatma[] | null>(null);
  const [ozet, setOzet] = useState<HatirlatmaOzeti | null>(null);
  const [secId, setSecId] = useState<number | null>(null);
  const [gun, setGun] = useState<string | null>(null);
  const [ay, setAy] = useState(() => { const d = new Date(); return new Date(d.getFullYear(), d.getMonth(), 1) });
  const [takvim, setTakvim] = useState<{ gun: number; adet: number; gecikmis: number }[]>([]);
  const [yenile, setYenile] = useState(0);
  const [erteleAcik, setErteleAcik] = useState(false);

  const ayAnahtar = `${ay.getFullYear()}-${String(ay.getMonth() + 1).padStart(2, '0')}`;
  const yukle = useCallback(() => setYenile(t => t + 1), []);
  useEffect(() => {
    const f = () => yukle();
    window.addEventListener(HATIRLATMA_DEGISTI_OLAYI, f);
    return () => window.removeEventListener(HATIRLATMA_DEGISTI_OLAYI, f);
  }, [yukle]);
  useEffect(() => {
    let iptal = false;
    const t = setTimeout(() => {
      api.hatirlatmalar(cip, ara).then(y => { if (!iptal) setSatirlar(y) }, () => { if (!iptal) setSatirlar([]) });
    }, ara ? 250 : 0);
    return () => { iptal = true; clearTimeout(t) };
  }, [cip, ara, yenile]);
  useEffect(() => { api.hatirlatmaOzet().then(setOzet, () => {}) }, [yenile]);
  useEffect(() => { api.hatirlatmaTakvim(ayAnahtar).then(setTakvim, () => setTakvim([])) }, [ayAnahtar, yenile]);

  const gorunen = useMemo(() => (satirlar ?? []).filter(s => !gun || s.zamanYerel.slice(0, 10) === gun), [satirlar, gun]);
  const sec = gorunen.find(s => s.id === secId) ?? null;
  const eylem = (f: () => Promise<unknown>) => void guvenli(async () => { await f(); hatirlatmaDegisti() });

  const kartlar: { c: string; e: string; v: number; s?: string }[] = ozet ? [
    { c: 'gec', e: 'Gecikmiş', v: ozet.gecikmis, s: ozet.gecikmis ? 'hata' : '' },
    { c: 'bugun', e: 'Bugün', v: ozet.bugun, s: ozet.bugun ? 'uyari' : '' },
    { c: 'hafta', e: 'Bu hafta', v: ozet.hafta },
    { c: 'tekrar', e: 'Tekrarlayan', v: ozet.tekrar },
    { c: 'tam', e: 'Bu ay tamamlanan', v: ozet.tamamAy },
  ] : [];

  // Takvim ızgarası: pazartesi başlar.
  const ilkGun = (ay.getDay() + 6) % 7;
  const gunSayisi = new Date(ay.getFullYear(), ay.getMonth() + 1, 0).getDate();
  const bugunIso = (() => { const d = new Date(); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}` })();
  const gunIso = (g: number) => `${ayAnahtar}-${String(g).padStart(2, '0')}`;

  const sil = async (h: Hatirlatma) => { if (await onay(`"${h.baslik}" silinsin mi?`, true)) eylem(() => api.hatirlatmaSil(h.id)) };

  return (
    <div className="ht-sayfa">
      <style>{HATIRLATMA_STIL}{STIL}</style>
      <div className="sayfa-baslik" style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
        <h2 style={{ margin: 0 }}>⏰ Hatırlatmalarım</h2><span className="hk-soluk">Kullanıcı › Hatırlatmalarım · çift tık = kartı aç</span>
        <span className="ht-arac" style={{ marginLeft: 'auto', display: 'flex', gap: 4, flexWrap: 'wrap' }}>
          <button type="button" className="d bir" onClick={() => hatirlatmaPenceresiAc()}>＋ Yeni</button>
          <button type="button" className="d" disabled={!sec?.acik} onClick={() => sec && eylem(() => api.hatirlatmaTamamla(sec.id))}>✓ Tamamlandı</button>
          <span className="hk-ertele-sar">
            <button type="button" className="d" disabled={!sec} onClick={() => setErteleAcik(a => !a)}>⏱ Ertele ▾</button>
            {erteleAcik && sec && <div className="hk-menu asagi">{erteleSecenekleri().map(e => (
              <button type="button" key={e.ad} onClick={() => { setErteleAcik(false); eylem(() => api.hatirlatmaErtele(sec.id, { dakika: e.dakika, zaman: e.zaman })) }}>{e.ad}</button>
            ))}</div>}
          </span>
          <button type="button" className="d" disabled={!sec} onClick={() => sec && eylem(() => api.hatirlatmaKopyala(sec.id))}>⧉ Kopyala</button>
          <button type="button" className="d" disabled={!sec?.benim} onClick={() => sec && void sil(sec)}>🗑 Sil</button>
          <button type="button" className="d" onClick={() => window.print()}>🖨 Yazdır</button>
        </span>
      </div>

      {kartlar.length > 0 && (
        <div className="kul-ozet" style={{ gridTemplateColumns: `repeat(${kartlar.length}, 1fr)`, marginTop: 10 }}>
          {kartlar.map(k => (
            <button type="button" key={k.c} className="k" onClick={() => { setCip(k.c); setGun(null) }}>
              <span className="bas">{k.e}</span><span className={`deg${k.s ? ` ${k.s}` : ''}`}>{k.v}</span>
              <span className="alt">{cip === k.c ? 'gösteriliyor' : 'listele'}</span>
            </button>
          ))}
        </div>
      )}

      <div className="ht-cipler">
        {CIPLER.map(([k, a]) => <button type="button" key={k} className={`ht-cip${cip === k ? ' on' : ''}`}
                                         onClick={() => { setCip(k); setGun(null) }}>{a}</button>)}
        <input className="ht-ara" value={ara} onChange={e => setAra(e.target.value)} placeholder="🔍 Başlık, not ya da bağlı kayıt ara…" />
      </div>

      <div className="ht-govde">
        <div>
          <div className="ht-tablo-sar"><table className="hk-tablo">
            <thead><tr><th /><th>Zaman</th><th>Başlık</th><th>Bağlı kayıt</th><th>Tekrar</th><th>Uyarı</th><th>Kanal</th><th>Kimden</th><th>Durum</th></tr></thead>
            <tbody>
              {satirlar === null && <tr><td colSpan={9} className="hk-soluk">Yükleniyor…</td></tr>}
              {satirlar !== null && gorunen.length === 0 && <tr><td colSpan={9} className="hk-soluk">Hatırlatma yok.
                {' '}<button type="button" className="d mini" onClick={() => hatirlatmaPenceresiAc()}>＋ Yeni</button></td></tr>}
              {gorunen.map(s => {
                const k = kalanMetni(s.zaman);
                return (
                  <tr key={s.id} className={`ht-satir${s.id === secId ? ' sec' : ''}${s.gecikmis ? ' gec' : ''}${!s.acik ? ' tam' : ''}`}
                      onClick={() => setSecId(s.id)} onDoubleClick={() => hatirlatmaPenceresiAc({ id: s.id })}>
                    <td><span className="ht-nokta" style={{ background: s.renk ? RENK[s.renk] : ONCELIK_RENK[s.oncelik],
                      border: s.renk ? '1px solid var(--cizgi)' : undefined }} title={['', 'Düşük', 'Normal', 'Yüksek'][s.oncelik]} /></td>
                    <td className={s.gecikmis ? 'bt-hata' : ''} style={s.gecikmis ? { color: 'var(--hata)', fontWeight: 700 } : undefined}>{tarihSaat(s.zaman)}</td>
                    <td className="bs">{s.oncelik === 3 ? <b>{s.baslik}</b> : s.baslik}{s.etiket && <span className="hk-soluk"> · 🏷 {s.etiket}</span>}</td>
                    <td>{s.kaynakAd ? <span className="hk-bag">{kayitIkonu(s.kaynak)} {s.kaynakAd}</span> : <span className="hk-soluk">—</span>}</td>
                    <td>{s.tekrar > 0 ? `🔁 ${s.tekrarMetni}` : <span className="hk-soluk">—</span>}</td>
                    <td>{uyariMetni(s.uyarDk)}</td>
                    <td title={[s.kanalUygulama && 'uygulama', s.kanalSms && 'SMS', s.kanalEposta && 'e-posta'].filter(Boolean).join(', ')}>
                      {s.kanalUygulama && '🔔'}{s.kanalSms && ' 📱'}{s.kanalEposta && ' ✉'}</td>
                    <td className="hk-soluk">{s.benim ? 'kendim' : s.sahip}</td>
                    <td>{!s.acik ? <span className="hk-rz ok">✓ {s.tamamlanma ? tarihSaat(s.tamamlanma) : 'tamam'}</span>
                      : <span className={`hk-rz ${k.sinif}`}>{k.metin}</span>}</td>
                  </tr>
                );
              })}
            </tbody>
          </table></div>
          <div className="ht-alt">
            <span>{gorunen.length} hatırlatma gösteriliyor{gun ? ` · ${gun.split('-').reverse().join('.')}` : ''}</span>
            {gun && <button type="button" className="d mini" onClick={() => setGun(null)}>✕ Gün süzgecini kaldır</button>}
            <span>Yalnız kendi hatırlatmalarınız ve sizinle paylaşılanlar görünür</span>
          </div>
        </div>

        <div className="ht-yan">
          <div className="hk-kutu"><div className="hk-ic">
            <div className="ht-tbas">
              <button type="button" onClick={() => setAy(new Date(ay.getFullYear(), ay.getMonth() - 1, 1))}>‹</button>
              <span style={{ flex: 1, textAlign: 'center' }}>{AYLAR[ay.getMonth()]} {ay.getFullYear()}</span>
              <button type="button" onClick={() => setAy(new Date(ay.getFullYear(), ay.getMonth() + 1, 1))}>›</button>
            </div>
            <div className="ht-takvim">
              {['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'].map(g => <div key={g} className="g">{g}</div>)}
              {Array.from({ length: ilkGun }, (_, i) => <button type="button" key={`b${i}`} className="bos" disabled> </button>)}
              {Array.from({ length: gunSayisi }, (_, i) => {
                const g = i + 1, iso = gunIso(g), t = takvim.find(x => x.gun === g);
                return <button type="button" key={g} title={t ? `${t.adet} hatırlatma` : undefined}
                               className={[iso === bugunIso && 'bugun', iso === gun && 'sec', t && (t.gecikmis ? 'gecvar' : 'var')].filter(Boolean).join(' ')}
                               onClick={() => { setGun(gun === iso ? null : iso); if (cip === 'tam' || cip === 'gec') setCip('acik') }}>{g}</button>;
              })}
            </div>
          </div></div>

          {sec && (
            <div className="hk-kutu"><h6>Seçili: {sec.baslik}</h6><div className="hk-ic">
              <div className="hk-kv">
                <b>Zaman</b><span>{tarihSaat(sec.zaman)} · {kalanMetni(sec.zaman).metin}</span>
                <b>Uyarı</b><span>{uyariMetni(sec.uyarDk)} · {[sec.kanalUygulama && 'zil', sec.kanalSms && 'SMS', sec.kanalEposta && 'e-posta'].filter(Boolean).join(' + ')}</span>
                {sec.kaynakAd && <><b>Bağlı kayıt</b><span className="hk-bag" style={{ cursor: 'pointer' }}
                  onClick={() => sec.kaynakId && git(`/${sec.kaynak}/${sec.kaynakId}`)}>{kayitIkonu(sec.kaynak)} {sec.kaynakAd} ↗</span></>}
                {sec.notu && <><b>Not</b><span style={{ whiteSpace: 'pre-wrap' }}>{sec.notu}</span></>}
                {sec.tekrar > 0 && <><b>Tekrar</b><span>{sec.tekrarMetni}</span></>}
                {sec.erteleSayisi > 0 && <><b>Ertelendi</b><span>{sec.erteleSayisi} kez</span></>}
                {!sec.benim && <><b>Paylaşan</b><span>{sec.sahip}</span></>}
              </div>
              <div style={{ display: 'flex', gap: 4, marginTop: 8, flexWrap: 'wrap' }}>
                {sec.acik && <button type="button" className="d yesil mini" onClick={() => eylem(() => api.hatirlatmaTamamla(sec.id))}>✓ Tamam</button>}
                <button type="button" className="d mini" onClick={() => eylem(() => api.hatirlatmaErtele(sec.id, { dakika: 15 }))}>⏱ 15 dk</button>
                <button type="button" className="d mini" onClick={() => eylem(() => api.hatirlatmaErtele(sec.id, { dakika: 60 }))}>⏱ 1 saat</button>
                <button type="button" className="d mini" onClick={() => {
                  const y = erteleSecenekleri().find(e => e.ad === 'Yarın 09:00');
                  if (y) eylem(() => api.hatirlatmaErtele(sec.id, { zaman: y.zaman }));
                }}>⏱ Yarın</button>
                <button type="button" className="d mini" onClick={() => hatirlatmaPenceresiAc({ id: sec.id })}>✎ Düzenle</button>
              </div>
            </div></div>
          )}
        </div>
      </div>
    </div>
  );
}
