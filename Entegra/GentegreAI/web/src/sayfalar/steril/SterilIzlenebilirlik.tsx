import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { SterilDongu, SterilGeriCagirma, SterilIzleme, SterilKullanim, SterilPaket } from '../../api/uclar/steril';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { DurumRozeti, SonucRozeti, zaman } from './ortak';

/**
 * İZLENEBİLİRLİK · GERİ ÇAĞIRMA · KAYIT DEFTERİ `/steril-izleme` (868) — mockup
 * dis_steril_izlenebilirlik.html. Sekmeler: paket zinciri (barkod → kirli / yıkama /
 * paket / döngü / kullanım), hasta bazlı sorgu, geri çağırma panosu (biyolojik pozitif:
 * etkilenen döngü / paket / hasta; bloke; hekim değerlendirmesi; bildirim; kapat), SKS
 * sterilizasyon kayıt defteri (ay), raporlar.
 */
type Sekme = 'paket' | 'hasta' | 'geri' | 'defter';

export function SterilIzlenebilirlik() {
  const git = useNavigate(); const [sorgu, setSorgu] = useSearchParams();
  const { yetki } = useOturum();
  const [sekme, setSekme] = useState<Sekme>(sorgu.get('geriCagirma') ? 'geri' : sorgu.get('tarafId') ? 'hasta' : 'paket');
  const [barkod, setBarkod] = useState(sorgu.get('barkod') ?? '');
  const [iz, setIz] = useState<SterilIzleme | null>(null);
  const [tarafId, setTarafId] = useState(sorgu.get('tarafId') ?? ''); const [hastaSatirlar, setHastaSatirlar] = useState<SterilKullanim[] | null>(null);
  const [gc, setGc] = useState<{ kayit: SterilGeriCagirma; dongular: SterilDongu[]; paketler: SterilPaket[]; hastalar: SterilKullanim[] } | null>(null);
  const [gcListe, setGcListe] = useState<SterilGeriCagirma[]>([]);
  const [secili, setSecili] = useState<number[]>([]);
  const [ay, setAy] = useState(new Date().toISOString().slice(0, 7));
  const [defter, setDefter] = useState<{ ay: string; satirlar: SterilDongu[]; ozet: { dongu: number; basarisiz: number; test: number; paket: number; kullanilan: number; geriCagirma: number } } | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const izle = useCallback(async (b: string) => {
    if (!b.trim()) return;
    try { setIz(await api.sterilPaketIzle(b.trim())); setHata(null); setSorgu(s => { s.set('barkod', b.trim()); return s }, { replace: true }) } catch (h) { setHata(hataMetni(h)); setIz(null) }
  }, [setSorgu]);
  const hastaSorgula = useCallback(async () => {
    const t = Number(tarafId); if (!t) { setHastaSatirlar(null); return }
    try { setHastaSatirlar((await api.sterilIzleme({ tarafId: t })).satirlar); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, [tarafId]);
  const gcYukle = useCallback(async (id: number) => { try { setGc(await api.sterilGeriCagirma(id)); setHata(null) } catch (h) { setHata(hataMetni(h)) } }, []);
  const gcListeYukle = useCallback(async () => {
    try { const y = await api.liste('steril-geri-cagirma', { sayfa: 1, boyut: 50 }); setGcListe((y.satirlar as unknown as Record<string, unknown>[]).map(s => ({ id: Number(s.id), cihaz_id: 0, cihaz_adi: String(s.cihazAdi ?? ''), tetik_dongu_id: 0, tetik_dongu_no: Number(s.tetikDonguNo ?? 0), etkilenen_dongu: Number(s.etkilenenDongu ?? 0), etkilenen_paket: Number(s.etkilenenPaket ?? 0), kullanilan_paket: Number(s.kullanilanPaket ?? 0), hasta_sayisi: Number(s.hastaSayisi ?? 0), durum: Number(s.durum ?? 1), durum_adi: String(s.durumAdi ?? ''), aciklama: '', acan_adi: String(s.acanAdi ?? ''), ekleme_tarihi: String(s.ekleme_tarihi ?? '') }))) } catch { /* liste yetkisi yoksa boş */ }
  }, []);
  const defterYukle = useCallback(async () => { try { setDefter(await api.sterilKayitDefteri(ay)); setHata(null) } catch (h) { setHata(hataMetni(h)) } }, [ay]);
  useEffect(() => { if (sorgu.get('barkod')) void izle(sorgu.get('barkod')!) }, []); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => { if (sorgu.get('tarafId')) void hastaSorgula() }, []); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => { if (sekme === 'geri') { void gcListeYukle(); const g = Number(sorgu.get('geriCagirma')); if (g) void gcYukle(g) } if (sekme === 'defter') void defterYukle() }, [sekme, sorgu, gcListeYukle, gcYukle, defterYukle]);

  const geriCagirmaAc = async () => {
    const d = await metinSor('Biyolojik POZİTİF döngü no (id)', sorgu.get('donguId') ?? '', 'Döngü id'); if (d === null || !Number(d)) return;
    if (!await onay('Geri çağırma açılsın mı? Aynı cihazda son negatif biyolojikten bu yana depodaki tüm paketler BLOKE olur, cihaz kullanım dışı kalır.')) return;
    await guvenli(async () => { const y = await api.sterilGeriCagirmaAc(Number(d), 'Ekrandan açıldı'); await gcYukle(y.id); await gcListeYukle(); setSorgu(s => { s.set('geriCagirma', String(y.id)); return s }, { replace: true }) });
  };
  const bildir = async () => {
    if (!gc || !secili.length) { mesaj('Bilgilendirilecek hastaları seçin.'); return }
    if (!await onay(`${secili.length} hastaya SMS bilgilendirmesi gönderilsin mi? (Hekim değerlendirmesi tamamlanmış olmalı.)`)) return;
    await guvenli(async () => { const y = await api.sterilGeriCagirmaBildir(gc.kayit.id, secili); mesaj(`${y.gonderilen} bildirim kuyruğa alındı${y.hata ? `, ${y.hata} gönderilemedi (telefon yok)` : ''}.`) });
  };
  const kapat = async () => {
    if (!gc) return; const n = await metinSor('Kapanış notu (DÖF no, tekrar biyolojik test sonucu)', '', 'Not'); if (n === null) return;
    await guvenli(async () => { await api.sterilGeriCagirmaKapat(gc.kayit.id, n); await gcYukle(gc.kayit.id); await gcListeYukle() });
  };
  const duzenle = yetki('steril.izleme', 'degistir');

  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>🔍 İzlenebilirlik · Geri Çağırma · Kayıt Defteri</h1><span className="yol">Sterilizasyon › İzlenebilirlik</span>
        <div className="sag"><button className="d" onClick={() => git('/steril-pano')}>🧪 Pano</button><button className="d" onClick={() => git('/steril-kullanim')}>🦷 Kullanım kayıtları</button></div></div></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="ka-sekmeler" style={{ padding: '0 20px 8px' }}>
        {(['paket', 'hasta', 'geri', 'defter'] as Sekme[]).map(s => <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{{ paket: '📦 Paket zinciri', hasta: '👤 Hasta bazlı', geri: '🚨 Geri çağırma', defter: '📒 Kayıt defteri' }[s]}</div>)}
      </div>
      {sekme === 'paket' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="st-okut"><span>📷</span><input className="inp" placeholder="Paket barkodu (P-…) ya da birim barkodu (S-M01, A-11)" value={barkod} onChange={e => setBarkod(e.target.value)} onKeyDown={e => { if (e.key === 'Enter') void izle(barkod) }} /><button className="d bir" onClick={() => void izle(barkod)}>Sorgula</button></div>
          {iz && (
            <>
              {iz.paket ? <div className="kutu-bilgi" style={{ margin: '8px 0' }}><b>{iz.paket.barkod}</b> · {iz.paket.birim_adi} · {iz.paket.cihaz_adi} #{iz.paket.dongu_no} · steril {zaman(iz.paket.steril_tarihi)} · SKT {iz.paket.skt ? new Date(iz.paket.skt).toLocaleDateString('tr-TR') : '—'} · <DurumRozeti durum={iz.paket.durum === 3 ? 4 : iz.paket.durum === 4 ? 8 : iz.paket.durum >= 5 ? 6 : 5} ad={iz.paket.durum_adi} />
                {iz.kullanimlar[0] && <> · kullanıldı {zaman(iz.kullanimlar[0].zaman)} {iz.kullanimlar[0].unite} · <b>{iz.kullanimlar[0].hasta_adi || '—'}</b> · {iz.kullanimlar[0].hekim_adi}</>}</div>
                : iz.birim && <div className="kutu-bilgi" style={{ margin: '8px 0' }}><b>{iz.birim.barkod}</b> · {iz.birim.ad} · {iz.birim.durum_adi} · döngü sayısı {iz.birim.dongu_sayisi} · son kullanım {zaman(iz.birim.son_kullanim)} {iz.birim.son_hasta_adi}</div>}
              {iz.paket && <div className="st-iz">
                {[{ b: '1 · Kirli toplama', o: iz.olaylar.find(o => o.tur === 1) }, { b: '2 · Yıkama / sayım', o: iz.olaylar.find(o => o.tur === 3) ?? iz.olaylar.find(o => o.tur === 2) }, { b: '3 · Paketleme', o: iz.olaylar.find(o => o.tur === 4) }, { b: '4 · Sterilizasyon', o: iz.olaylar.find(o => o.tur === 8 && o.paketId) ?? iz.olaylar.find(o => o.tur === 5 && o.paketId), on: true }, { b: '5 · Kullanım', o: iz.olaylar.find(o => o.tur === 11) }].map((n, i) => (
                  <div key={i} className={`n${n.on ? ' on' : ''}`}><b>{n.b}</b>{n.o ? <>{zaman(n.o.zaman)} · {n.o.kullaniciAdi || 'sistem'}<br />{n.o.aciklama}</> : <span className="sonuk">kayıt yok</span>}</div>))}
                {iz.dongu && <div className="n"><b>Döngü #{iz.dongu.sayac_no}</b>{iz.dongu.cihaz_adi} · {iz.dongu.program_adi}<br />BD <SonucRozeti s={iz.dongu.bd_sonuc} /> Helix <SonucRozeti s={iz.dongu.helix_sonuc} /> S5 <SonucRozeti s={iz.dongu.kimyasal_sonuc} /> Bio <SonucRozeti s={iz.dongu.bio_sonuc} /><br />{iz.dongu.tepe_sicaklik ? `${iz.dongu.tepe_sicaklik}°C · ${iz.dongu.plato_dk} dk` : ''} · <button className="d mini" onClick={() => git(`/steril-dongu/${iz.dongu!.id}?geri=%2Fsteril-izleme%3Fbarkod%3D${encodeURIComponent(barkod)}`)}>kart</button></div>}
              </div>}
              <table className="fm-tablo"><thead><tr><th>Zaman</th><th>Olay</th><th>Kim</th><th>Ayrıntı</th></tr></thead>
                <tbody>{iz.olaylar.map(o => <tr key={o.id}><td>{zaman(o.zaman)}</td><td>{o.turAdi}</td><td>{o.kullaniciAdi || 'sistem'}</td><td>{o.aciklama}</td></tr>)}{!iz.olaylar.length && <tr><td colSpan={4} className="sonuk">Olay yok.</td></tr>}</tbody></table>
              {iz.kullanimlar.length > 0 && <table className="fm-tablo" style={{ marginTop: 8 }}><thead><tr><th>Kullanım</th><th>Ünite</th><th>Hasta</th><th>Başvuru / seans</th><th>Hekim</th><th>Okutan</th><th>Not</th></tr></thead>
                <tbody>{iz.kullanimlar.map(u => <tr key={u.id}><td>{zaman(u.zaman)}</td><td>{u.unite}</td><td>{u.taraf_id ? <a href="#" onClick={e => { e.preventDefault(); git(`/hasta/${u.taraf_id}`) }}>{u.hasta_adi}</a> : '—'}</td><td>{u.belge_no || '—'}</td><td>{u.hekim_adi || '—'}</td><td>{u.okutan_adi}</td><td>{u.notu}</td></tr>)}</tbody></table>}
            </>
          )}
          {!iz && <div className="sonuk" style={{ padding: 8 }}>Barkod okutun ya da girin. Paket: kirli → yıkama → paketleme → döngü → kullanım zinciri; birim: son olaylar.</div>}
        </section>
      )}
      {sekme === 'hasta' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="st-okut"><span>👤</span><input className="inp" placeholder="Hasta id (hasta kartından: Sterilizasyon sekmesi)" value={tarafId} onChange={e => setTarafId(e.target.value)} onKeyDown={e => { if (e.key === 'Enter') void hastaSorgula() }} /><button className="d bir" onClick={() => void hastaSorgula()}>Sorgula</button><button className="d" onClick={() => git('/steril-kullanim')}>Tüm kullanım listesi</button></div>
          <table className="fm-tablo"><thead><tr><th>Zaman</th><th>Hasta</th><th>Başvuru / seans</th><th>Hekim</th><th>Ünite</th><th>Paket</th><th>İçerik</th><th>Döngü</th><th>Biyolojik</th></tr></thead>
            <tbody>{(hastaSatirlar ?? []).map(u => <tr key={u.id} className="tik" onDoubleClick={() => { setBarkod(u.paket_barkod); setSekme('paket'); void izle(u.paket_barkod) }}><td>{zaman(u.zaman)}</td><td>{u.hasta_adi} {u.dosya_no && <span className="sonuk">({u.dosya_no})</span>}</td><td>{u.belge_no || '—'}</td><td>{u.hekim_adi || '—'}</td><td>{u.unite}</td><td>{u.paket_barkod}</td><td>{u.birim_adi}</td><td>{u.cihaz_adi} #{u.dongu_no}</td><td><SonucRozeti s={u.bio_sonuc} yok="n/a" /></td></tr>)}
              {hastaSatirlar && !hastaSatirlar.length && <tr><td colSpan={9} className="sonuk">Bu hastada paket kullanımı yok.</td></tr>}</tbody></table>
        </section>
      )}
      {sekme === 'geri' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="fm-doldur-arac">{duzenle && <button className="d kir" onClick={() => void geriCagirmaAc()}>🚨 Geri çağırma aç (biyolojik pozitif)</button>}<span className="sonuk">Biyolojik POZİTİF girildiğinde döngü kartından otomatik açılır. Kapsam: aynı cihazda son negatif biyolojikten sonraki tüm döngüler.</span></div>
          <table className="fm-tablo"><thead><tr><th>Açılış</th><th>Cihaz</th><th>Pozitif döngü</th><th>Döngü</th><th>Paket</th><th>Kullanılmış</th><th>Hasta</th><th>Durum</th><th>Açan</th></tr></thead>
            <tbody>{gcListe.map(g => <tr key={g.id} className={`tik${gc?.kayit.id === g.id ? ' sel' : ''}`} onClick={() => void gcYukle(g.id)}><td>{zaman(g.ekleme_tarihi)}</td><td>{g.cihaz_adi}</td><td>#{g.tetik_dongu_no}</td><td>{g.etkilenen_dongu}</td><td>{g.etkilenen_paket}</td><td>{g.kullanilan_paket}</td><td>{g.hasta_sayisi}</td><td><DurumRozeti durum={g.durum === 1 ? 6 : 4} ad={g.durum_adi} /></td><td>{g.acan_adi}</td></tr>)}
              {!gcListe.length && <tr><td colSpan={9} className="sonuk">Geri çağırma yok.</td></tr>}</tbody></table>
          {gc && (
            <>
              <div className={`kutu-${gc.kayit.durum === 1 ? 'hata' : 'bilgi'}`} style={{ margin: '10px 0' }}><b>GERİ ÇAĞIRMA #{gc.kayit.id} · {gc.kayit.durum_adi}</b> — {gc.kayit.cihaz_adi} döngü #{gc.kayit.tetik_dongu_no} biyolojik pozitif. Etkilenen: <b>{gc.kayit.etkilenen_dongu} döngü · {gc.kayit.etkilenen_paket} paket</b>; <b>{gc.kayit.kullanilan_paket} paket {gc.kayit.hasta_sayisi} hastada kullanıldı</b>, kalanı depoda bloke. {gc.kayit.aciklama}</div>
              <div className="st-adim">{['1 · Pozitif sonuç', '2 · Etkilenen döngüler', '3 · Depodakiler bloke', '4 · Hasta listesi', '5 · Hekim değerlendirmesi / bildirim', '6 · Cihaz tekrar test', '7 · DÖF & kapanış'].map((a, i) => <span key={i} className={i < 4 ? 'ok' : gc.kayit.durum === 2 ? 'ok' : i === 4 ? 'on' : ''}>{a}</span>)}</div>
              <div className="fm-doldur-arac">
                {duzenle && gc.kayit.durum === 1 && <button className="d" onClick={() => void bildir()}>📨 Seçili hastalara bilgilendirme SMS'i</button>}
                {duzenle && gc.kayit.durum === 1 && <button className="d" onClick={() => git(`/steril-cihaz/${gc.kayit.cihaz_id}?geri=%2Fsteril-izleme%3FgeriCagirma%3D${gc.kayit.id}`)}>🧪 Cihaz kartı (tekrar test / bakım)</button>}
                {duzenle && gc.kayit.durum === 1 && <button className="d ok" onClick={() => void kapat()}>✔ Kapat (DÖF)</button>}
              </div>
              <h3 className="fm-bolum-bas">Kullanılan paketler · hastalar ({gc.hastalar.length})</h3>
              <table className="fm-tablo"><thead><tr><th><input type="checkbox" checked={secili.length > 0 && secili.length === new Set(gc.hastalar.map(h => h.taraf_id ?? 0)).size} onChange={e => setSecili(e.target.checked ? [...new Set(gc.hastalar.map(h => h.taraf_id ?? 0).filter(Boolean))] : [])} /></th><th>Hasta</th><th>Telefon</th><th>İşlem</th><th>Tarih</th><th>Hekim</th><th>Paket</th><th>Risk sınıfı</th></tr></thead>
                <tbody>{gc.hastalar.map(h => <tr key={h.id}><td><input type="checkbox" disabled={!h.taraf_id} checked={!!h.taraf_id && secili.includes(h.taraf_id)} onChange={e => setSecili(x => e.target.checked ? [...new Set([...x, h.taraf_id!])] : x.filter(t => t !== h.taraf_id))} /></td><td>{h.hasta_adi || '—'}</td><td>{h.cepTel || '—'}</td><td>{h.belge_no || h.unite}</td><td>{zaman(h.zaman)}</td><td>{h.hekim_adi || '—'}</td><td>{h.birim_adi}</td><td><span className={`st-rz ${h.riskSinifi === 'kritik' ? 'kir' : 'sari'}`}>{h.riskSinifi}</span></td></tr>)}
                  {!gc.hastalar.length && <tr><td colSpan={8} className="sonuk">Etkilenen paketlerden hiçbiri kullanılmamış.</td></tr>}</tbody></table>
              <h3 className="fm-bolum-bas" style={{ marginTop: 10 }}>Etkilenen döngüler ({gc.dongular.length}) · paketler ({gc.paketler.length})</h3>
              <table className="fm-tablo"><thead><tr><th>Döngü</th><th>Başlangıç</th><th>Program</th><th>Paket</th><th>Biyolojik</th><th>Durum</th></tr></thead>
                <tbody>{gc.dongular.map(d => <tr key={d.id} className="tik" onDoubleClick={() => git(`/steril-dongu/${d.id}?geri=%2Fsteril-izleme%3FgeriCagirma%3D${gc.kayit.id}`)}><td>#{d.sayac_no}</td><td>{zaman(d.baslama)}</td><td>{d.program_adi}</td><td>{d.paket_sayisi}</td><td><SonucRozeti s={d.bio_sonuc} /></td><td><DurumRozeti durum={d.durum} ad={d.durum_adi} /></td></tr>)}</tbody></table>
            </>
          )}
        </section>
      )}
      {sekme === 'defter' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="fm-doldur-arac"><input className="inp" type="month" value={ay} onChange={e => setAy(e.target.value)} style={{ width: 150 }} /><button className="d" onClick={() => void defterYukle()}>Getir</button><button className="d" onClick={() => window.print()}>🖨 Yazdır (SKS formatı)</button>
            {defter && <span className="sonuk">Döngü {defter.ozet.dongu} · başarısız {defter.ozet.basarisiz} · test {defter.ozet.test} · paket {defter.ozet.paket} · kullanılan {defter.ozet.kullanilan} · geri çağırma {defter.ozet.geriCagirma}</span>}</div>
          <table className="fm-tablo"><thead><tr><th>Tarih</th><th>Cihaz</th><th>Döngü no</th><th>Program</th><th>Başl.</th><th>Bitiş</th><th>Yük</th><th>Tepe °C</th><th>Plato</th><th>Bowie-Dick</th><th>Helix</th><th>Sınıf 5</th><th>Biyolojik</th><th>Sonuç</th><th>Operatör</th><th>Onaylayan</th></tr></thead>
            <tbody>{(defter?.satirlar ?? []).map(d => <tr key={d.id} className="tik" onDoubleClick={() => git(`/steril-dongu/${d.id}?geri=%2Fsteril-izleme`)}><td>{new Date(d.baslama).toLocaleDateString('tr-TR')}</td><td>{d.cihaz_adi}</td><td>{d.sayac_no}</td><td>{d.program_adi}</td><td>{new Date(d.baslama).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}</td><td>{d.bitis ? new Date(d.bitis).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }) : '—'}</td><td>{d.test_programi ? 'test' : d.paket_sayisi}</td><td>{d.tepe_sicaklik ?? '—'}</td><td>{d.plato_dk ?? '—'}</td><td><SonucRozeti s={d.bd_sonuc} /></td><td><SonucRozeti s={d.helix_sonuc} /></td><td><SonucRozeti s={d.kimyasal_sonuc} /></td><td><SonucRozeti s={d.bio_sonuc} /></td><td><DurumRozeti durum={d.durum} ad={d.durum_adi} /></td><td>{d.operator_adi}</td><td>{d.onaylayan_adi || '—'}</td></tr>)}
              {defter && !defter.satirlar.length && <tr><td colSpan={16} className="sonuk">Bu ay kayıt yok.</td></tr>}</tbody></table>
          <div className="sonuk" style={{ fontSize: 11, marginTop: 6 }}>Defter satırı döngü serbest bırakılınca / sonuçlanınca kendiliğinden oluşur; elle satır eklenemez, düzeltme yalnız not + ISLEMLOG ile.</div>
        </section>
      )}
    </div>
  );
}
