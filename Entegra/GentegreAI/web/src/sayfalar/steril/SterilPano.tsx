import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni, ApiHatasi } from '../../api/sozlesme';
import type { SterilBirim, SterilCihaz, SterilPano as Pano } from '../../api/uclar/steril';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { DurumRozeti, SonucRozeti, zaman } from './ortak';

/**
 * STERİLİZASYON PANOSU `/steril-pano` (868) — mockup Ekranlar/Dis Klinigi/dis_steril_panosu.html.
 * Üstte KPI + uyarılar, cihaz kartları (aktif döngü, faz, Bowie-Dick), altta sekmeler:
 * günün döngüleri · hazırlanan birimler (kirli → yıkama → sayım → paketle) · steril depo ·
 * uyarılar · bugün kullanılan. "Yeni döngü": cihaz + program + barkod okutma (yük) →
 * Bowie-Dick kuralı (onay notu) → döngü kartı. Barkod okut kutusu: kirli toplama /
 * kullanım kaydı için tek giriş.
 */
type Sekme = 'dongu' | 'hazirlik' | 'depo' | 'uyari' | 'kullanim';
const BIRIM_ADIM: Record<number, { sonraki: 'yikama' | 'sayim' | 'paketle' | null; etiket: string }> = {
  1: { sonraki: 'yikama', etiket: '🧼 Yıkamaya al' }, 2: { sonraki: 'sayim', etiket: '🔢 Sayım' }, 3: { sonraki: 'paketle', etiket: '📦 Paketle' },
  10: { sonraki: 'yikama', etiket: '🧼 Yeniden işle' }, 4: { sonraki: null, etiket: 'Döngüye hazır' }, 9: { sonraki: null, etiket: 'Bakımda' },
};

export function SterilPano() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [sorgu] = useSearchParams();
  const [p, setP] = useState<Pano | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('dongu');
  const [yeniAcik, setYeniAcik] = useState(sorgu.get('yeni') === '1');
  const [cihazId, setCihazId] = useState(0); const [programId, setProgramId] = useState(0);
  const [yuk, setYuk] = useState<SterilBirim[]>([]); const [barkod, setBarkod] = useState('');
  const [kimyasalLot, setKimyasalLot] = useState(''); const [bioLot, setBioLot] = useState('');
  const [okut, setOkut] = useState('');

  const yukle = useCallback(async () => {
    try { const y = await api.sterilPano(); setP(y); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle(); const t = setInterval(() => void yukle(), 10000); return () => clearInterval(t) }, [yukle]);
  useEffect(() => {
    if (!p) return;
    if (!cihazId) { const o = p.cihazlar.find(c => c.tur === 1 && c.durum === 1 && !c.aktifDongu) ?? p.cihazlar.find(c => c.tur === 1); if (o) setCihazId(o.id) }
    if (!programId) { const pr = p.programlar.find(x => x.varsayilan === 1) ?? p.programlar[0]; if (pr) setProgramId(pr.id) }
  }, [p, cihazId, programId]);

  const yukeEkle = () => {
    const kod = barkod.trim(); if (!kod || !p) return;
    const b = p.birimler.find(x => x.barkod.toLowerCase() === kod.toLowerCase());
    if (!b) { mesaj(`${kod}: hazırlık listesinde böyle bir birim yok (kirli / yıkamada / sayım / paketlendi). Steril depodan yeniden sterilizasyon için Setler listesini kullanın.`); return }
    if (yuk.some(x => x.id === b.id)) { mesaj('Bu birim yükte.'); return }
    setYuk(x => [...x, b]); setBarkod('');
  };
  const baslat = async () => {
    if (!cihazId || !programId) { mesaj('Cihaz ve program seçin.'); return }
    const program = p?.programlar.find(x => x.id === programId);
    const test = program?.test === 1;
    if (!test && yuk.length === 0) { mesaj('Yük boş: birim barkodu okutun.'); return }
    const dene = async (bdOnayNotu?: string) => api.sterilDonguBaslat({ cihazId, programId, birimler: test ? [] : yuk.map(b => ({ birimId: b.id })), kimyasalLot: kimyasalLot || undefined, bioLot: bioLot || undefined, bdOnayNotu });
    await guvenli(async () => {
      let y;
      try { y = await dene() }
      catch (h) {
        if (h instanceof ApiHatasi && h.hata.engel && (h.hata.engel as { kod?: string }).kod === 'BD_ONAY') {
          const n = await metinSor(`${h.message}\n\nSorumlu onay notu:`, '', 'Onay notu'); if (n === null || !n.trim()) return;
          y = await dene(n.trim());
        } else throw h;
      }
      mesaj(y.test ? `Test döngüsü #${y.sayacNo} başladı; bitince Bowie-Dick / Helix sonucunu girin.` : `Döngü #${y.sayacNo} başladı · ${y.paketSayisi} paket.`);
      setYeniAcik(false); setYuk([]); setKimyasalLot(''); setBioLot('');
      await yukle(); git(`/steril-dongu/${y.id}?geri=%2Fsteril-pano`);
    });
  };
  const birimOlay = async (b: SterilBirim, islem: 'yikama' | 'sayim' | 'paketle' | 'yaglama' | 'ariza' | 'kirli') => {
    let sayilan: number | undefined, eksik: string | undefined, notu: string | undefined;
    if (islem === 'sayim') {
      const s = await metinSor(`${b.ad}: sayılan alet (boş = tam)`, '', 'Sayılan'); if (s === null) return;
      if (s.trim() !== '') { sayilan = Number(s); const e = await metinSor('Eksik / hasarlı alet', '', 'Eksik'); if (e === null) return; eksik = e }
    }
    if (islem === 'ariza') { const n = await metinSor('Arıza açıklaması', '', 'Açıklama'); if (n === null) return; notu = n }
    await guvenli(async () => { const y = await api.sterilBirimOlay({ birimId: b.id, islem, sayilan, eksik, notu }); mesaj(y.mesaj); await yukle() });
  };
  const barkodOkut = async () => {
    const kod = okut.trim(); if (!kod) return;
    // Paket barkodu (P-…) → kullanım kaydı; birim barkodu → kirli toplama.
    if (/^p-/i.test(kod)) {
      const unite = await metinSor('Ünite / oda', '', 'Ünite'); if (unite === null) return;
      await guvenli(async () => {
        try { const y = await api.sterilOkut({ barkod: kod, unite }); mesaj(y.mesaj) }
        catch (h) {
          if (h instanceof ApiHatasi && (h.hata.engel as { kod?: string } | undefined)?.kod === 'KARANTINA' && await onay('Paket karantinada (biyolojik sonuç bekleniyor). Yine de kullanılsın mı?')) { const y = await api.sterilOkut({ barkod: kod, unite, zorla: true }); mesaj(y.mesaj) }
          else throw h;
        }
        setOkut(''); await yukle();
      });
    } else {
      await guvenli(async () => { const y = await api.sterilBirimOlay({ barkod: kod, islem: 'kirli' }); mesaj(y.mesaj); setOkut(''); await yukle() });
    }
  };
  const bdSonuc = async (c: SterilCihaz) => {
    const d = p?.dongular.find(x => x.cihaz_id === c.id && x.test_programi === 1 && x.durum === 8 && (x.bd_sonuc ?? 0) !== 1);
    if (!d) { mesaj(`${c.ad}: bugün açılmış test döngüsü yok. "Yeni döngü" ile Bowie-Dick test programını çalıştırın.`); return }
    git(`/steril-dongu/${d.id}?geri=%2Fsteril-pano`);
  };

  if (hata && !p) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!p) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;
  const k = p.kpi; const duzenle = yetki('steril.dongu', 'ekle');
  const kirmizi = p.uyarilar.filter(u => u.seviye === 'kir');
  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>🧪 Sterilizasyon Panosu</h1><span className="yol">Sterilizasyon › Pano · {new Date().toLocaleDateString('tr-TR', { weekday: 'long', day: '2-digit', month: '2-digit' })} · 10 sn'de bir yenilenir</span>
        <div className="sag">
          {duzenle && <button className="d bir" onClick={() => setYeniAcik(x => !x)}>♨️ Yeni Döngü</button>}
          <button className="d" onClick={() => git('/steril-birim')}>🧰 Setler</button>
          <button className="d" onClick={() => git('/steril-izleme')}>🔍 İzlenebilirlik</button>
          {yetki('steril.ayar') && <button className="d" onClick={() => git('/steril-ayar')}>📅 Test takvimi · Kurallar</button>}
        </div></div></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {kirmizi.map((u, i) => <div key={i} className="hata-kutusu" style={{ margin: '0 20px' }}>⚠ {u.mesaj} {u.tur === 'bd' && u.cihazId && <button className="d mini" onClick={() => { const c = p.cihazlar.find(x => x.id === u.cihazId); if (c) void bdSonuc(c) }}>Test sonucu gir</button>}</div>)}
      <div className="st-okut">
        <span>📷</span><input className="inp" placeholder="Barkod okut: paket (P-…) → kullanım kaydı · set / döner alet → kirli toplama" value={okut} onChange={e => setOkut(e.target.value)} onKeyDown={e => { if (e.key === 'Enter') void barkodOkut() }} />
        <button className="d" onClick={() => void barkodOkut()}>Kaydet</button>
      </div>
      <div className="fm-kpis" style={{ padding: '0 20px' }}>
        <div className="fm-kpi"><div className="b">Bugünkü döngü</div><div className="d">{k.bugunDongu} <small className="sonuk">· {k.bugunSerbest} serbest · {k.calisan} çalışıyor</small></div></div>
        <div className="fm-kpi"><div className="b">Kirli / yıkamada</div><div className={`d${k.kirli ? ' st-sari' : ''}`}>{k.kirli}</div></div>
        <div className="fm-kpi"><div className="b">Sayım / paketleme bekleyen</div><div className="d">{k.paketlemeBekleyen}</div></div>
        <div className="fm-kpi"><div className="b">Steril depo</div><div className="d st-ok">{k.sterilDepo} <small className="sonuk">paket · {k.sktYakin} SKT ≤ {p.kurallar.sktUyariGun} gün</small></div></div>
        <div className="fm-kpi"><div className="b">Karantina (bio bekliyor)</div><div className={`d${k.karantina ? ' st-sari' : ''}`}>{k.karantina}{k.bloke ? <small className="st-kir"> · {k.bloke} bloke</small> : null}</div></div>
        <div className="fm-kpi"><div className="b">Bugün kullanılan</div><div className="d">{k.bugunKullanilan} <small className="sonuk">paket · {k.bugunHasta} hasta</small></div></div>
      </div>
      {yeniAcik && (
        <section className="fm-bolum" style={{ margin: '0 20px', borderColor: 'var(--vurgu)' }}>
          <h3 className="fm-bolum-bas">♨️ Yeni döngü — yükleme<span className="sp" /><button className="d mini" onClick={() => setYeniAcik(false)}>✖</button></h3>
          <div className="isg-frm">
            <div className="al"><span className="lb">Cihaz (otoklav)</span><select className="inp" value={cihazId} onChange={e => setCihazId(Number(e.target.value))}>{p.cihazlar.filter(c => c.tur === 1).map(c => <option key={c.id} value={c.id} disabled={c.durum !== 1}>{c.ad}{c.durum !== 1 ? ' (kullanım dışı)' : c.aktifDongu ? ' (çalışıyor)' : ''}{c.bd_bugun ? ' · BD ✓' : ' · BD yok'}</option>)}</select></div>
            <div className="al"><span className="lb">Program</span><select className="inp" value={programId} onChange={e => setProgramId(Number(e.target.value))}>{p.programlar.map(x => <option key={x.id} value={x.id}>{x.ad}{x.test ? ' (test)' : ` · ${x.sicaklik}°C / ${x.plato_dk} dk`}</option>)}</select></div>
            <div className="al"><span className="lb">Sınıf 5 entegratör lotu</span><input className="inp" value={kimyasalLot} onChange={e => setKimyasalLot(e.target.value)} placeholder="23K7" /></div>
            <div className="al"><span className="lb">Biyolojik indikatör lotu (haftalık / implant)</span><input className="inp" value={bioLot} onChange={e => setBioLot(e.target.value)} placeholder="boş = yok" /></div>
            <div className="al g2"><span className="lb">Yük: birim barkodu okut (paketlenmiş / sayılmış)</span><div style={{ display: 'flex', gap: 6 }}><input className="inp" value={barkod} onChange={e => setBarkod(e.target.value)} onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); yukeEkle() } }} placeholder="S-M01 · A-11" /><button className="d" onClick={yukeEkle}>➕</button></div></div>
            <div className="al g2"><span className="lb">Hazır birimler (tıkla → yüke ekle)</span><div className="st-cipler">{p.birimler.filter(b => (b.durum === 4 || b.durum === 3) && !yuk.some(y => y.id === b.id)).map(b => <span key={b.id} className="chip" onClick={() => setYuk(x => [...x, b])}>{b.barkod} {b.ad}</span>)}{!p.birimler.some(b => b.durum === 4 || b.durum === 3) && <span className="sonuk">paketlenmiş birim yok</span>}</div></div>
          </div>
          <table className="fm-tablo"><thead><tr><th>#</th><th>Barkod</th><th>İçerik</th><th>Durum</th><th>Paket türü (set)</th><th /></tr></thead>
            <tbody>{yuk.map((b, i) => <tr key={b.id}><td>{i + 1}</td><td>{b.barkod}</td><td>{b.ad}{b.implant ? <span className="st-rz sari" style={{ marginLeft: 6 }}>implant · bio zorunlu</span> : null}</td><td><DurumRozeti durum={b.durum} ad={b.durum_adi} /></td><td>{b.set_adi || 'döner alet'}</td><td><button className="d mini" onClick={() => setYuk(x => x.filter(y => y.id !== b.id))}>✖</button></td></tr>)}
              {!yuk.length && <tr><td colSpan={6} className="sonuk">Yük boş. Test programı (Bowie-Dick / vakum) boş kazanla çalışır.</td></tr>}</tbody></table>
          <div className="fm-doldur-arac"><button className="d bir" onClick={() => void baslat()}>▶ Döngüyü başlat</button><span className="sonuk">Bowie-Dick bugün yoksa kurum kuralı: <b>{p.kurallar.bdKurali}</b> (uyari / onay notu / engel). Döner alet yağlanmadan yüklenemez.</span></div>
        </section>
      )}
      <div className="st-cihazlar">
        {p.cihazlar.map(c => {
          const d = c.aktifDongu;
          const cls = c.durum === 2 ? 'bak' : d ? 'cal' : c.durum === 0 ? 'pas' : 'haz';
          return (
            <div key={c.id} className={`c ${c.durum === 2 ? 'kir' : ''}`} onClick={() => d ? git(`/steril-dongu/${d.id}?geri=%2Fsteril-pano`) : undefined}>
              <span className={`du ${cls}`}>{c.durum === 2 ? 'BAKIM' : d ? (d.durum === 2 ? 'ÇALIŞIYOR' : 'İNDİKATÖR BEKLİYOR') : c.durum === 0 ? 'PASİF' : 'HAZIR'}</span>
              <div className="ad2">{c.ad}</div><div className="tip">{c.marka_model}{c.sinif_adi ? ` · ${c.sinif_adi} sınıfı` : ''}{c.kapasite ? ` · ${c.kapasite}` : ''}</div>
              {d ? <>
                <div className="prog">Döngü #{d.sayac_no} · {d.program_adi}</div>
                <div className="alt2"><span>{d.durum === 2 ? `çalışıyor · ${d.sure_dk} dk` : 'bitti · indikatör / serbest bırakma bekliyor'}</span><span>{d.paket_sayisi} paket</span></div>
                <div className="alt2"><span>Op: {d.operator_adi || '—'}</span><span>{zaman(d.baslama)}</span></div>
              </> : c.tur === 1 ? <>
                <div className="prog">Sayaç {c.sayac} · bugün {c.bugun_dongu} döngü</div>
                <div className="alt2"><span>Bowie-Dick bugün: {c.bd_bugun ? <b className="st-ok">GEÇTİ</b> : <b className="st-kir">yok</b>}</span>{duzenle && !c.bd_bugun && <button className="d mini" onClick={e => { e.stopPropagation(); void bdSonuc(c) }}>Sonuç gir</button>}</div>
                <div className="alt2"><span>Bakım: {c.sonraki_bakim ? new Date(c.sonraki_bakim).toLocaleDateString('tr-TR') : '—'}</span><span>Validasyon: {c.sonraki_validasyon ? new Date(c.sonraki_validasyon).toLocaleDateString('tr-TR') : '—'}</span></div>
              </> : <>
                <div className="prog">{c.tur_adi}</div>
                <div className="alt2"><span>{c.durum === 2 ? c.aciklama || 'bakım gerekli' : c.konum}</span><span>{c.sonraki_bakim ? `bakım ${new Date(c.sonraki_bakim).toLocaleDateString('tr-TR')}` : ''}</span></div>
              </>}
            </div>
          );
        })}
      </div>
      <div className="ka-sekmeler" style={{ padding: '0 20px 8px' }}>
        {(['dongu', 'hazirlik', 'depo', 'uyari', 'kullanim'] as Sekme[]).map(s => <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{{ dongu: `Günün döngüleri (${p.dongular.length})`, hazirlik: `Hazırlanan birimler (${p.birimler.length})`, depo: `Steril depo · raf ömrü (${p.depo.length})`, uyari: `Uyarılar (${p.uyarilar.length})`, kullanim: `Bugün kullanılan (${p.kullanilan.length})` }[s]}</div>)}
      </div>
      {sekme === 'dongu' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <table className="fm-tablo"><thead><tr><th>Döngü</th><th>Cihaz</th><th>Program</th><th>Başlangıç</th><th>Bitiş</th><th>Yük</th><th>BD</th><th>Helix</th><th>Sınıf 5</th><th>Biyolojik</th><th>Durum</th><th>Operatör</th><th>Onay</th></tr></thead>
            <tbody>{p.dongular.map(d => <tr key={d.id} className="tik" onDoubleClick={() => git(`/steril-dongu/${d.id}?geri=%2Fsteril-pano`)}>
              <td><b>#{d.sayac_no}</b></td><td>{d.cihaz_adi}</td><td>{d.program_adi}</td><td>{zaman(d.baslama)}</td><td>{zaman(d.bitis)}</td><td>{d.test_programi ? 'test' : `${d.paket_sayisi} paket`}</td>
              <td><SonucRozeti s={d.bd_sonuc} /></td><td><SonucRozeti s={d.helix_sonuc} /></td><td><SonucRozeti s={d.kimyasal_sonuc} /></td><td><SonucRozeti s={d.bio_sonuc} /></td>
              <td><DurumRozeti durum={d.durum} ad={d.durum_adi} /></td><td>{d.operator_adi}</td><td>{d.onaylayan_adi || '—'}</td></tr>)}
              {!p.dongular.length && <tr><td colSpan={13} className="sonuk">Bugün döngü yok.</td></tr>}</tbody></table>
        </section>
      )}
      {sekme === 'hazirlik' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="st-zin">{['Kirli', 'Yıkama / dezenfeksiyon', 'Sayım', 'Paketleme', 'Sterilde', 'Steril depo', 'Kullanım'].map(a => <span key={a}>{a}</span>)}</div>
          <table className="fm-tablo"><thead><tr><th>Birim</th><th>Barkod</th><th>Tür / set</th><th>Durum</th><th>Bekleme</th><th>Son kullanım</th><th>Son hasta</th><th>İşlem</th></tr></thead>
            <tbody>{p.birimler.map(b => { const adim = BIRIM_ADIM[b.durum]; const yagla = b.yaglama_gerekli === 1 && (!b.son_yaglama || (b.son_kullanim && b.son_yaglama < b.son_kullanim)); return (
              <tr key={b.id}><td><b>{b.ad}</b>{b.bakim_zamani ? <span className="st-rz sari" style={{ marginLeft: 6 }}>bakım zamanı</span> : null}</td><td>{b.barkod}</td><td>{b.tur_adi}{b.set_adi ? ` · ${b.set_adi}` : ''}</td>
                <td><DurumRozeti durum={b.durum} ad={b.durum_adi} /></td><td>{b.durum_dk} dk</td><td>{zaman(b.son_kullanim)}</td><td>{b.son_hasta_adi || '—'}</td>
                <td style={{ whiteSpace: 'nowrap' }}>
                  {yagla && duzenle && <button className="d mini" onClick={() => void birimOlay(b, 'yaglama')}>🛢 Yağlandı</button>}
                  {adim?.sonraki && duzenle && <button className="d mini" onClick={() => void birimOlay(b, adim.sonraki!)}>{adim.etiket}</button>}
                  {!adim?.sonraki && <span className="sonuk">{adim?.etiket ?? ''}</span>}
                  {duzenle && b.durum !== 9 && <button className="d mini" title="Arıza / bakım" onClick={() => void birimOlay(b, 'ariza')}>🔧</button>}
                </td></tr>) })}
              {!p.birimler.length && <tr><td colSpan={8} className="sonuk">Hazırlıkta birim yok; seans bitince paket okutulunca set kirli havuzuna düşer.</td></tr>}</tbody></table>
        </section>
      )}
      {sekme === 'depo' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <table className="fm-tablo"><thead><tr><th>Paket</th><th>İçerik</th><th>Paket türü</th><th>Döngü</th><th>Steril tarihi</th><th>SKT</th><th>Kalan</th><th>Raf</th><th>Durum</th></tr></thead>
            <tbody>{p.depo.map(x => <tr key={x.id} className="tik" onDoubleClick={() => git(`/steril-izleme?barkod=${encodeURIComponent(x.barkod)}`)}>
              <td>{x.barkod}</td><td>{x.birim_adi}{x.implant ? ' 🔩' : ''}</td><td>{x.paket_tur_adi}</td><td>{x.cihaz_adi} #{x.dongu_no}</td><td>{zaman(x.steril_tarihi)}</td>
              <td>{x.skt ? new Date(x.skt).toLocaleDateString('tr-TR') : 'olay bazlı'}</td><td className={x.skt_kalan_gun !== null && x.skt_kalan_gun !== undefined && x.skt_kalan_gun <= p.kurallar.sktUyariGun ? 'st-kir' : ''}>{x.skt_kalan_gun ?? '—'}</td><td>{x.raf}</td><td><DurumRozeti durum={x.durum === 3 ? 4 : x.durum === 7 || x.durum === 5 ? 6 : 5} ad={x.durum_adi} /></td></tr>)}
              {!p.depo.length && <tr><td colSpan={9} className="sonuk">Steril depoda paket yok.</td></tr>}</tbody></table>
        </section>
      )}
      {sekme === 'uyari' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <ul className="st-uyari">{p.uyarilar.map((u, i) => <li key={i} className={u.seviye}><span className="k">{u.seviye === 'kir' ? '!' : '·'}</span><span>{u.mesaj}</span>
            {u.donguId && <button className="d mini" onClick={() => git(`/steril-dongu/${u.donguId}?geri=%2Fsteril-pano`)}>Döngü</button>}
            {u.tur === 'bd' && u.cihazId && duzenle && <button className="d mini" onClick={() => { const c = p.cihazlar.find(x => x.id === u.cihazId); if (c) void bdSonuc(c) }}>Sonuç gir</button>}
            {u.tur === 'skt' && <button className="d mini" onClick={() => setSekme('depo')}>Depo</button>}
            {(u.tur === 'bakim' || u.tur === 'validasyon' || u.tur === 'cihaz') && u.cihazId && <button className="d mini" onClick={() => git(`/steril-cihaz/${u.cihazId}?geri=%2Fsteril-pano`)}>Cihaz</button>}</li>)}
            {!p.uyarilar.length && <li className="ok"><span className="k">✓</span><span>Uyarı yok.</span></li>}</ul>
        </section>
      )}
      {sekme === 'kullanim' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <table className="fm-tablo"><thead><tr><th>Saat</th><th>Ünite</th><th>Hasta</th><th>Başvuru / seans</th><th>Hekim</th><th>Paket</th><th>İçerik</th><th>Döngü</th><th>Okutan</th></tr></thead>
            <tbody>{p.kullanilan.map(x => <tr key={x.id} className="tik" onDoubleClick={() => git(`/steril-izleme?barkod=${encodeURIComponent(x.paket_barkod)}`)}><td>{zaman(x.zaman)}</td><td>{x.unite}</td><td>{x.hasta_adi || '—'}</td><td>{x.belge_no || '—'}</td><td>{x.hekim_adi || '—'}</td><td>{x.paket_barkod}</td><td>{x.birim_adi}</td><td>{x.cihaz_adi} #{x.dongu_no}</td><td>{x.okutan_adi}</td></tr>)}
              {!p.kullanilan.length && <tr><td colSpan={9} className="sonuk">Bugün paket okutulmadı.</td></tr>}</tbody></table>
        </section>
      )}
      <div className="fm-doldur-arac sonuk" style={{ padding: '0 20px', fontSize: 11 }}>Setler: {p.setler.map(s => `${s.ad} ${s.steril_depoda}/${s.birim_sayisi}`).join(' · ')}</div>
    </div>
  );
}
