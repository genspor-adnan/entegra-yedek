import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { Supervizor } from '../../api/uclar/cagri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, secimSor } from '../../bilesenler/mesaj';
import { sureYaz } from './CagriOperator';

/**
 * SÜPERVİZÖR PANOSU `/cagri-supervizor` (Çağrı Merkezi 839) — mockup
 * Ekranlar/CagriMerkezi/cagri_supervizor.html. KPI kartları, agent durum
 * kartları, sekmeler: canlı kuyruk (agent ekle), gün özeti (saatlik grafik +
 * agent performansı), konu dağılımı, kalite (haftalık), aktif çağrılar
 * (dinle/fısılda santral sürücüsü ile). 5 sn'de bir yenilenir.
 */
type Sekme = 'kuyruk' | 'gun' | 'konu' | 'kalite' | 'aktif';
const DUR: Record<number, string> = { 1: 'h', 2: 'm', 3: 's', 4: 'mo', 5: 'c' };

export function CagriSupervizor() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [s, setS] = useState<Supervizor | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('kuyruk');
  const yukle = useCallback(async () => { try { setS(await api.cagriSupervizor()); setHata(null) } catch (h) { setHata(hataMetni(h)) } }, []);
  useEffect(() => { void yukle(); const t = setInterval(() => void yukle(), 5000); return () => clearInterval(t) }, [yukle]);

  const agentEkle = async (kuyrukId: number, kuyrukAd: string) => {
    if (!s) return;
    const a = await secimSor(`"${kuyrukAd}" kuyruğuna agent ekle`, s.agentlar.map(x => ({ kod: String(x.kullanici_id), ad: `${x.agent_adi} (${x.dahili || '—'}) · ${x.durum_adi}` }))); if (!a) return;
    await guvenli(async () => { await api.cagriSupervizorAgent(Number(a), { kuyrukId }); mesaj('Agent kuyruğa eklendi.'); await yukle() });
  };
  const agentDurum = async (kullaniciId: number, ad: string) => {
    const d = await secimSor(`${ad} — durum`, [{ kod: '1', ad: '✔ Hazır' }, { kod: '4', ad: '☕ Mola' }, { kod: '5', ad: '⏻ Çıkış' }]); if (!d) return;
    await guvenli(async () => { await api.cagriSupervizorAgent(kullaniciId, { durum: Number(d) }); await yukle() });
  };

  if (hata && !s) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!s) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;
  const k = s.kpi;
  const cevapOran = k.gelen ? Math.round(100 * k.cevaplanan / k.gelen) : 0;
  const slaOran = k.cevaplanan ? Math.round(100 * k.slaIcinde / k.cevaplanan) : 0;
  const maxSaat = Math.max(1, ...s.saatlik.map(x => x.gelen));
  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>📊 Süpervizör Panosu</h1><span className="yol">Çağrı Merkezi › Süpervizör · canlı, 5 sn</span>
        <div className="sag">
          <button className="d" onClick={() => git('/cagri-pano')}>🎧 Operatör panosu</button>
          <button className="d" onClick={() => git('/cagri-kalite')}>⭐ Kalite listesi</button>
          {yetki('cagri.ayar') && <button className="d" onClick={() => git('/cagri-santral')}>⚙️ Ayarlar</button>}
          <button className="d" onClick={() => git('/dokumler?grup=%C3%87a%C4%9Fr%C4%B1%20Merkezi')}>📊 Dökümler</button>
        </div></div></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="fm-kpis">
        <div className="fm-kpi"><div className="b">Bekleyen</div><div className={`d${k.bekleyen ? ' kir' : ''}`}>{k.bekleyen}</div></div>
        <div className="fm-kpi"><div className="b">En uzun bekleme</div><div className={`d${k.enUzunBeklemeSn > 120 ? ' kir' : k.enUzunBeklemeSn > 60 ? ' sari' : ''}`}>{sureYaz(k.enUzunBeklemeSn)}</div></div>
        <div className="fm-kpi"><div className="b">Cevaplama (bugün)</div><div className={`d${cevapOran >= 90 ? ' ok' : cevapOran >= 80 ? ' sari' : ' kir'}`}>{cevapOran}% <small>{k.cevaplanan}/{k.gelen}</small></div></div>
        <div className="fm-kpi"><div className="b">SLA (kuyruk hedefi)</div><div className={`d${slaOran >= 90 ? ' ok' : slaOran >= 80 ? ' sari' : ' kir'}`}>{slaOran}%</div></div>
        <div className="fm-kpi"><div className="b">Kaçan</div><div className={`d${k.kacan ? ' sari' : ''}`}>{k.kacan}</div></div>
        <div className="fm-kpi"><div className="b">Ort. konuşma</div><div className="d">{sureYaz(k.ortKonusmaSn)}</div></div>
        <div className="fm-kpi"><div className="b">Memnuniyet</div><div className={`d${Number(k.memnuniyet) >= 4 ? ' ok' : ''}`}>{k.memnuniyet ? `${Number(k.memnuniyet).toFixed(1)} / 5` : '—'}</div></div>
        <div className="fm-kpi"><div className="b">WhatsApp açık</div><div className="d">{k.whatsappAcik}</div></div>
      </div>
      <div className="cg-aj">
        {s.agentlar.map(a => <div key={a.id} className="a" onClick={() => yetki('cagri.supervizor', 'degistir') && void agentDurum(a.kullanici_id, a.agent_adi)} title="Durum değiştir">
          <div className="ad2">{a.agent_adi}<span className="sonuk"> · {a.dahili || '—'}</span></div>
          <div className={`du ${DUR[a.durum] ?? 'c'}`}>{a.durum_adi}</div>
          <div className="sr2">{sureYaz(a.durum_sn)}</div>
          <div className="sonuk">{a.kuyruk_adlari || '—'}</div>
          <div>{a.cagri_bugun} çağrı · ort {sureYaz(a.ort_sure_sn)}</div>
        </div>)}
        {!s.agentlar.length && <div className="sonuk">Agent tanımlı değil — Ayarlar › Agentlar.</div>}
      </div>
      <div className="ka-sekmeler" style={{ padding: '0 0 8px' }}>
        {(['kuyruk', 'gun', 'konu', 'kalite', 'aktif'] as Sekme[]).map(x => <div key={x} className={`ka-sekme${sekme === x ? ' on' : ''}`} onClick={() => setSekme(x)}>{{ kuyruk: '🔴 Canlı Kuyruk', gun: '📈 Gün Özeti', konu: '🗂 Konu Dağılımı', kalite: '⭐ Kalite', aktif: `🎧 Aktif Çağrılar (${s.aktif.length})` }[x]}</div>)}
      </div>
      {sekme === 'kuyruk' && (
        <section className="fm-bolum">
          <table className="fm-tablo"><thead><tr><th>Kuyruk</th><th className="fm-sag">Bekleyen</th><th className="fm-sag">En uzun</th><th className="fm-sag">Hazır agent</th><th className="fm-sag">Cevaplanan</th><th className="fm-sag">Kaçan</th><th>SLA</th><th className="fm-sag">Ort. bekleme</th><th className="fm-sag">Ort. konuşma</th><th>Taşma</th><th /></tr></thead>
            <tbody>{s.kuyruklar.map(q => <tr key={q.id}><td><b>{q.ad}</b></td><td className={`fm-sag${q.bekleyen ? ' cg-kir' : ''}`}>{q.bekleyen}</td><td className={`fm-sag${q.enUzunSn > 120 ? ' cg-kir' : ''}`}>{q.enUzunSn ? sureYaz(q.enUzunSn) : '—'}</td>
              <td className="fm-sag">{q.hazirAgent}</td><td className="fm-sag">{q.cevaplanan}</td><td className="fm-sag">{q.kacan}</td>
              <td><span className={`cg-sla ${q.slaYuzde >= q.slaHedef ? 'ok' : q.slaYuzde >= q.slaHedef - 10 ? 'uy' : 'gec'}`}>{q.cevaplanan ? `%${q.slaYuzde}` : '—'}</span> <span className="sonuk">hedef %{q.slaHedef} / {q.slaSn} sn</span></td>
              <td className="fm-sag">{sureYaz(q.ortBeklemeSn)}</td><td className="fm-sag">{sureYaz(q.ortKonusmaSn)}</td><td>{q.tasmaAdi || '—'}</td>
              <td>{yetki('cagri.supervizor', 'degistir') && <button className="d mini" onClick={() => void agentEkle(q.id, q.ad)}>➕ Agent</button>}</td></tr>)}
              {!s.kuyruklar.length && <tr><td colSpan={11} className="sonuk">Kuyruk yok.</td></tr>}</tbody></table>
          <div className="sonuk" style={{ fontSize: 11, marginTop: 4 }}>Uyarı eşiği: bekleyen ≥ 5 ya da en uzun ≥ 3:00. Taşma kuyruğu Ayarlar › Kuyruklar'dan.</div>
        </section>
      )}
      {sekme === 'gun' && (
        <>
          <section className="fm-bolum"><h3 className="fm-bolum-bas">Saatlik gelen / kaçan</h3>
            <div className="cg-grafik">{s.saatlik.map(x => <i key={x.saat} className={x.kacan > 0 && x.kacan * 4 >= x.gelen ? 'k' : ''} style={{ height: `${Math.max(2, Math.round(100 * x.gelen / maxSaat))}%` }} title={`${x.saat}:00 · ${x.gelen} gelen · ${x.kacan} kaçan`}><span>{String(x.saat).padStart(2, '0')}</span></i>)}</div>
          </section>
          <section className="fm-bolum"><h3 className="fm-bolum-bas">Agent performansı (bugün)</h3>
            <table className="fm-tablo"><thead><tr><th>Agent</th><th className="fm-sag">Çağrı</th><th className="fm-sag">Cevaplanan</th><th className="fm-sag">Ort. konuşma</th><th className="fm-sag">İşlem sonrası</th><th className="fm-sag">Randevu verdi</th><th className="fm-sag">Geri arama</th><th className="fm-sag">Görev</th><th className="fm-sag">Kalite (hafta)</th></tr></thead>
              <tbody>{s.agentGun.map(a => <tr key={a.agentId}><td>{a.ad}</td><td className="fm-sag">{a.cagri}</td><td className="fm-sag">{a.cevaplanan}</td><td className="fm-sag">{sureYaz(a.ortKonusmaSn)}</td><td className="fm-sag">{sureYaz(a.ortIslemSn)}</td><td className="fm-sag">{a.randevu}</td><td className="fm-sag">{a.geriArama}</td><td className="fm-sag">{a.gorev}</td><td className="fm-sag">{a.kalite ?? '—'}</td></tr>)}</tbody></table>
          </section>
        </>
      )}
      {sekme === 'konu' && (
        <section className="fm-bolum">
          <table className="fm-tablo"><thead><tr><th>Konu</th><th className="fm-sag">Bugün</th><th className="fm-sag">7 gün</th><th>Pay</th><th className="fm-sag">Çağrıda çözüm</th><th className="fm-sag">Geri arama</th><th className="fm-sag">Görev</th><th className="fm-sag">Ort. süre</th></tr></thead>
            <tbody>{(() => { const top = s.konular.reduce((a, x) => a + x.hafta, 0) || 1; return s.konular.map(x => <tr key={x.konu}><td>{x.konu}</td><td className="fm-sag">{x.bugun}</td><td className="fm-sag">{x.hafta}</td>
              <td><span className="isg-bar" style={{ width: 120 }}><i style={{ width: `${Math.round(100 * x.hafta / top)}%` }} /></span> {Math.round(100 * x.hafta / top)}%</td>
              <td className="fm-sag">{x.hafta ? Math.round(100 * x.cozum / x.hafta) : 0}%</td><td className="fm-sag">{x.geriArama}</td><td className="fm-sag">{x.gorev}</td><td className="fm-sag">{sureYaz(x.ortSureSn)}</td></tr>) })()}
              {!s.konular.length && <tr><td colSpan={8} className="sonuk">Son 7 günde çağrı yok.</td></tr>}</tbody></table>
        </section>
      )}
      {sekme === 'kalite' && (
        <section className="fm-bolum">
          <table className="fm-tablo"><thead><tr><th>Hafta</th><th className="fm-sag">Değerlendirilen</th><th className="fm-sag">Ort. puan</th><th className="fm-sag">En düşük</th></tr></thead>
            <tbody>{s.kalite.map(x => <tr key={x.hafta}><td>{x.hafta}</td><td className="fm-sag">{x.sayi}</td><td className="fm-sag">{x.ortPuan}</td><td className="fm-sag">{x.enDusuk}</td></tr>)}
              {!s.kalite.length && <tr><td colSpan={4} className="sonuk">Son 4 haftada değerlendirme yok — çağrı kartı › Kalite sekmesinden puanlanır.</td></tr>}</tbody></table>
          <div className="fm-doldur-arac"><button className="d" onClick={() => git('/cagri?cip=Bug%C3%BCn')}>🎲 Bugünün çağrılarından örnekle</button><span className="sonuk">Öneri: agent başına haftada 5 çağrı; puan &lt; 70 → eğitim görevi.</span></div>
        </section>
      )}
      {sekme === 'aktif' && (
        <section className="fm-bolum">
          <table className="fm-tablo"><thead><tr><th>Agent</th><th>Arayan</th><th>Kuyruk</th><th className="fm-sag">Süre</th><th /></tr></thead>
            <tbody>{s.aktif.map(c => <tr key={c.id}><td>{c.agent_adi || '—'}</td><td>{c.taraf_adi || 'Tanınmıyor'} · {c.arayan_no}</td><td>{c.kuyruk_adi}</td><td className="fm-sag">{sureYaz(Math.floor((Date.now() - new Date(c.cevap ?? c.baslama).getTime()) / 1000))}</td>
              <td><button className="d mini" disabled title="Santral sürücüsü (3CX / Asterisk ChanSpy) bağlanınca">🎧 Dinle</button> <button className="d mini" disabled>🗣 Fısılda</button> <button className="d mini" onClick={() => git(`/cagri/${c.id}?geri=%2Fcagri-supervizor`)}>Kart</button></td></tr>)}
              {!s.aktif.length && <tr><td colSpan={5} className="sonuk">Aktif çağrı yok.</td></tr>}</tbody></table>
          <div className="sonuk" style={{ fontSize: 11, marginTop: 4 }}>Dinleme/fısıldama santral desteğiyle gelir; dinleme olayı log'a yazılır ve agent'a bildirilir (kurum politikası).</div>
        </section>
      )}
    </div>
  );
}
