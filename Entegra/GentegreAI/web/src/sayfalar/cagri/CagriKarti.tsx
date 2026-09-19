import { useCallback, useEffect, useState } from 'react';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CagriKart as Kart } from '../../api/uclar/cagri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { sureYaz } from './CagriOperator';

/**
 * ÇAĞRI KARTI `/cagri/:id` (Çağrı Merkezi 839) — mockup
 * Ekranlar/CagriMerkezi/cagri_kayit_karti.html. Başlık alanları + süre
 * kartları; sekmeler: ilgili kayıtlar, zaman çizelgesi (santral olayları),
 * ses kaydı & özet, kalite değerlendirme, kişinin geçmişi. Modal; düzenleme
 * gizli generic kart (/cagri-kart).
 */
type Sekme = 'ilgili' | 'zaman' | 'kayit' | 'kalite' | 'gecmis';
const OLCUTLER = [
  { ad: 'Karşılama ve kimlik doğrulama', agirlik: 15 }, { ad: 'Konuyu anlama / doğru yönlendirme', agirlik: 25 },
  { ad: 'Bilgi doğruluğu (KVKK dahil)', agirlik: 25 }, { ad: 'Ton / empati', agirlik: 15 }, { ad: 'Kapanış ve kayıt kalitesi', agirlik: 20 },
];
const KAYNAK_YOL: Record<string, string> = { randevu: '/randevu', gorev: '/gorev', belge: '/belge', form_istek: '/form-doldur', servis: '/servis', siparis: '/belge', lab_istem: '/lab-istem' };

export function CagriKarti() {
  const { id: param } = useParams();
  const id = Number(param ?? 0);
  const git = useNavigate();
  const konum = useLocation();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const durumS = konum.state as { geri?: string } | null;
  const geri = durumS?.geri ?? sorgu.get('geri') ?? '/cagri';
  const kapat = useCallback(() => git(geri), [git, geri]);
  useEffect(() => { const f = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() }; window.addEventListener('keydown', f); return () => window.removeEventListener('keydown', f) }, [kapat]);
  const [k, setK] = useState<Kart | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('ilgili');
  const [puanlar, setPuanlar] = useState<number[]>(OLCUTLER.map(o => o.agirlik));
  const [notlar, setNotlar] = useState<string[]>(OLCUTLER.map(() => ''));
  const [kaliteNot, setKaliteNot] = useState('');
  const yukle = useCallback(async () => {
    try {
      const y = await api.cagriKart(id); setK(y); setHata(null);
      if (y.kalite?.olcutler) { try { const o = JSON.parse(y.kalite.olcutler) as { puan: number; not: string }[]; if (Array.isArray(o) && o.length === OLCUTLER.length) { setPuanlar(o.map(x => x.puan)); setNotlar(o.map(x => x.not ?? '')) } } catch { /* eski kayıt */ } }
      if (y.kalite) setKaliteNot(y.kalite.notu ?? '');
    } catch (h) { setHata(hataMetni(h)) }
  }, [id]);
  useEffect(() => { if (id) void yukle() }, [id, yukle]);

  const buradan = `/cagri/${id}?geri=${encodeURIComponent(geri)}`;
  const toplam = puanlar.reduce((a, b) => a + b, 0);
  const kaliteKaydet = async () => {
    await guvenli(async () => {
      await api.cagriKalite(id, { puan: toplam, olcutler: OLCUTLER.map((o, i) => ({ ad: o.ad, agirlik: o.agirlik, puan: puanlar[i], not: notlar[i] })), notu: kaliteNot });
      mesaj(`Değerlendirme kaydedildi: ${toplam} / 100`); await yukle();
    });
  };
  const ozetUret = async () => { await guvenli(async () => { const y = await api.cagriOzet(id); mesaj(`Özet üretildi (${y.kaynak === 'kural' ? 'kural tabanlı; model bağlı değil' : 'model'}).`); await yukle() }) };
  const geriAramaTamam = async () => { if (!await onay('Geri arama yapıldı olarak işaretlensin mi?')) return; await guvenli(async () => { await api.cagriGeriAramaTamam(id); await yukle() }) };

  if (param === 'yeni') return <Perde baslik="📞 Çağrı" kapat={kapat}><div className="fm-kagov">Elle çağrı kaydı <b>Çağrı Kayıtları › ＋ Elle çağrı kaydı</b> ya da operatör panosundan <b>📞 Ara</b> ile açılır.</div></Perde>;
  if (hata) return <Perde baslik="📞 Çağrı" kapat={kapat}><div className="hata-kutusu">{hata}</div></Perde>;
  if (!k) return <Perde baslik="📞 Çağrı" kapat={kapat}><span className="sonuk">Yükleniyor…</span></Perde>;
  const c = k.cagri; const o = k.ozet;
  const zaman = (d?: string | null) => d ? new Date(d).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' }) : '—';
  const baslik = <>📞 Çağrı Kartı — #C-{c.id}<span className="kapt">{c.yon_adi} · {c.kanal_adi} · {zaman(c.baslama)} · {c.agent_adi || '—'} · <span className="rz mavi">{c.durum_adi}</span></span></>;
  return (
    <Perde baslik={baslik} kapat={kapat}>
      <div className="fm-doldur-arac">
        {yetki('cagri.kayit', 'degistir') && c.durum <= 4 && <button className="d bir" onClick={() => git(`/cagri-pano?cagri=${c.id}`)}>🎧 Panoda aç / kaydet</button>}
        {yetki('cagri.kayit', 'degistir') && <button className="d" onClick={() => git(`/cagri-kart/${c.id}?geri=${encodeURIComponent(buradan)}`)}>✎ Düzenle</button>}
        {c.sonuc === 2 && !c.geri_arama_tamam && yetki('cagri.giden', 'degistir') && <button className="d" onClick={() => void geriAramaTamam()}>✔ Geri arama yapıldı</button>}
        {c.taraf_id && <button className="d" onClick={() => git(`${c.hasta ? '/hasta' : '/cari'}/${c.taraf_id}?geri=${encodeURIComponent(buradan)}`)}>👤 Kişi kartı</button>}
        {c.gorev_id && <button className="d" onClick={() => git(`/gorev/${c.gorev_id}?geri=${encodeURIComponent(buradan)}`)}>📌 Görev #{c.gorev_id}</button>}
        <span className="sp" />
        {c.kayit_url && <a className="d" href={c.kayit_url} target="_blank" rel="noopener noreferrer">▶ Kaydı aç</a>}
        {yetki('cagri.kalite') && <button className="d" onClick={() => void ozetUret()}>🤖 Özet üret</button>}
      </div>
      <div className="isg-frm">
        <Al lb="Kanal / Yön" v={`${c.kanal_adi} · ${c.yon_adi}`} /><Al lb="Numara" v={c.arayan_no || '—'} /><Al lb="Kuyruk" v={c.kuyruk_adi || '—'} /><Al lb="Agent" v={c.agent_adi || '—'} />
        <Al lb="Kişi" v={c.taraf_adi ? <>{c.taraf_adi} {c.hasta ? <span className="rz mavi">Hasta</span> : null}{c.musteri ? <span className="rz mor">Cari</span> : null}</> : 'Tanınmıyor'} />
        <Al lb="Konu" v={c.konu_adi ? `${c.konu_adi}${c.alt_konu_adi ? ' › ' + c.alt_konu_adi : ''}` : '—'} /><Al lb="Sonuç" v={c.sonuc_adi || '—'} /><Al lb="Öncelik" v={String(c.oncelik)} />
        <div className="al g4"><span className="lb">Not</span><span className="inp ro" style={{ minHeight: 40, whiteSpace: 'pre-wrap' }}>{c.notu || '—'}</span></div>
      </div>
      <div className="fm-kpis">
        <div className="fm-kpi"><div className="b">Bekleme</div><div className={`d${c.bekleme_sn > 60 ? ' kir' : ''}`}>{sureYaz(c.bekleme_sn)}</div></div>
        <div className="fm-kpi"><div className="b">Konuşma</div><div className="d">{sureYaz(c.sure_sn)}</div></div>
        <div className="fm-kpi"><div className="b">İşlem sonrası</div><div className="d">{sureYaz(c.islem_sonrasi_sn)}</div></div>
        <div className="fm-kpi"><div className="b">SLA</div><div className={`d ${c.cevap ? (c.sla_icinde ? 'ok' : 'kir') : ''}`}>{c.cevap ? (c.sla_icinde ? 'İçinde' : 'Aşıldı') : '—'}</div></div>
        <div className="fm-kpi"><div className="b">Memnuniyet</div><div className="d">{c.memnuniyet ? '★'.repeat(c.memnuniyet) : '—'}</div></div>
        <div className="fm-kpi"><div className="b">Kalite</div><div className="d">{c.kalite_puan ?? '—'}</div></div>
        {c.geri_arama && <div className="fm-kpi"><div className="b">Geri arama</div><div className={`d${c.geri_arama_tamam ? ' ok' : ' sari'}`}>{zaman(c.geri_arama)}{c.geri_arama_tamam ? ' ✔' : ''}</div></div>}
      </div>
      <div className="ka-sekmeler" style={{ padding: '0 0 8px' }}>
        {(['ilgili', 'zaman', 'kayit', 'kalite', 'gecmis'] as Sekme[]).map(s => <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>
          {{ ilgili: `🔗 İlgili Kayıtlar (${k.ilgili.length})`, zaman: '🕒 Zaman Çizelgesi', kayit: '🎙️ Ses Kaydı & Özet', kalite: '⭐ Kalite', gecmis: `📜 Kişinin Geçmişi (${k.gecmis.length})` }[s]}</div>)}
      </div>
      {sekme === 'ilgili' && (
        <table className="fm-tablo"><thead><tr><th>Tür</th><th>Kayıt</th><th>Açıklama</th><th>Zaman</th><th /></tr></thead>
          <tbody>{k.ilgili.map(i => <tr key={i.id}><td>{i.kaynakTur}</td><td>#{i.kaynakId}</td><td>{i.aciklama}</td><td>{zaman(i.zaman)}</td>
            <td>{KAYNAK_YOL[i.kaynakTur] && <button className="d mini" onClick={() => git(`${KAYNAK_YOL[i.kaynakTur]}/${i.kaynakId}?geri=${encodeURIComponent(buradan)}`)}>Aç</button>}</td></tr>)}
            {!k.ilgili.length && <tr><td colSpan={5} className="sonuk">Bu çağrıda açılan kayıt yok.</td></tr>}</tbody></table>
      )}
      {sekme === 'zaman' && (
        <div className="cg-zc">{k.olaylar.map(e => <div key={e.id} className="z"><span className="t">{new Date(e.zaman).toLocaleTimeString('tr-TR')}</span><span className="ik">{{ 1: '☎', 2: '👤', 3: '⏸', 4: '▶', 5: '↪', 6: '📵', 7: '📝', 8: '💬', 9: '🔗' }[e.tur] ?? '•'}</span>
          <div className="ic2"><b>{e.turAdi}</b> {e.aciklama}{e.agentAdi ? <span className="sonuk"> · {e.agentAdi}</span> : null}</div></div>)}
          {!k.olaylar.length && <div className="sonuk">Olay yok (santral bağlı değil ya da elle kayıt).</div>}</div>
      )}
      {sekme === 'kayit' && (
        <>
          {c.kayit_url ? <audio controls src={c.kayit_url} style={{ width: '100%' }} /> : <div className="sonuk">Ses kaydı bağlantısı yok — santral hangup olayında <code>kayitUrl</code> gelir ya da kartta elle yazılır.</div>}
          <div className="cg-aiozet"><b>🤖 Özet:</b> {k.kalite?.ozet_ai || <span className="sonuk">Henüz üretilmedi — "Özet üret" (kural tabanlı; model bağlanınca aynı alan).</span>}</div>
          {k.kalite?.transkript && <div className="cg-trk">{k.kalite.transkript}</div>}
        </>
      )}
      {sekme === 'kalite' && (
        <>
          <table className="fm-tablo"><thead><tr><th>Ölçüt</th><th className="fm-sag">Ağırlık</th><th className="fm-sag">Puan</th><th>Not</th></tr></thead>
            <tbody>{OLCUTLER.map((ol, i) => <tr key={ol.ad}><td>{ol.ad}</td><td className="fm-sag">{ol.agirlik}</td>
              <td className="fm-sag"><input type="number" className="inp" style={{ width: 70 }} min={0} max={ol.agirlik} value={puanlar[i]} onChange={e => setPuanlar(p => p.map((x, j) => j === i ? Math.min(ol.agirlik, Math.max(0, Number(e.target.value))) : x))} disabled={!yetki('cagri.kalite', 'ekle')} /></td>
              <td><input className="inp" value={notlar[i]} onChange={e => setNotlar(n => n.map((x, j) => j === i ? e.target.value : x))} disabled={!yetki('cagri.kalite', 'ekle')} /></td></tr>)}
              <tr><td><b>Toplam</b></td><td className="fm-sag">100</td><td className="fm-sag"><b className={toplam >= 85 ? 'cg-ok' : toplam >= 70 ? 'cg-sari' : 'cg-kir'}>{toplam}</b></td><td><input className="inp" placeholder="Genel not" value={kaliteNot} onChange={e => setKaliteNot(e.target.value)} disabled={!yetki('cagri.kalite', 'ekle')} /></td></tr></tbody></table>
          <div className="fm-doldur-arac">
            {yetki('cagri.kalite', 'ekle') && <button className="d bir" onClick={() => void kaliteKaydet()}>💾 Değerlendirmeyi kaydet</button>}
            <span className="sonuk">{k.kalite ? `Son: ${k.kalite.degerlendiren_adi || '—'} · ${zaman(k.kalite.ekleme_tarihi)} · ${k.kalite.puan}/100` : 'Değerlendirilmemiş'}</span>
          </div>
        </>
      )}
      {sekme === 'gecmis' && (
        <table className="fm-tablo"><thead><tr><th>Tarih</th><th>Kanal</th><th>Yön</th><th>Konu</th><th>Sonuç</th><th>Agent</th><th className="fm-sag">Süre</th></tr></thead>
          <tbody>{k.gecmis.map(g => <tr key={g.id} onDoubleClick={() => git(`/cagri/${g.id}?geri=${encodeURIComponent(buradan)}`)}><td>{zaman(g.baslama)}</td><td>{g.kanal_adi}</td><td>{g.yon_adi}</td><td>{g.konu_adi}{g.alt_konu_adi ? ` › ${g.alt_konu_adi}` : ''}</td><td>{g.sonuc_adi || g.durum_adi}</td><td>{g.agent_adi}</td><td className="fm-sag">{sureYaz(g.sure_sn)}</td></tr>)}
            {!k.gecmis.length && <tr><td colSpan={7} className="sonuk">{o ? 'Bu kişinin başka çağrısı yok.' : 'Kişi bağlı değil; aynı numaradan başka çağrı yok.'}</td></tr>}</tbody></table>
      )}
    </Perde>
  );
}

function Al({ lb, v }: { lb: string; v: React.ReactNode }) { return <div className="al"><span className="lb">{lb}</span><span className="inp ro">{v}</span></div> }
function Perde({ baslik, kapat, children }: { baslik: React.ReactNode; kapat: () => void; children: React.ReactNode }) {
  return (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">{baslik}<button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button></div>
        <div className="kagov fm-kagov">{children}</div>
      </div>
    </div>
  );
}
