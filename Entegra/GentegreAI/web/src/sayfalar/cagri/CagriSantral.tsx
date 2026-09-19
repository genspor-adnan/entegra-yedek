import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CalismaSaati, IvrDali, SantralYaniti } from '../../api/uclar/cagri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { c as cev } from '../../dil/ceviri';

/**
 * SANTRAL · IVR · KANALLAR `/cagri-santral` (Çağrı Merkezi 839) — mockup
 * Ekranlar/CagriMerkezi/cagri_santral_ayarlar.html. Sekmeler: santral
 * bağlantısı (sağlayıcı, webhook URL + anahtar, dahili eşleşmesi), IVR ağacı,
 * kuyruklar & agentlar (listelere bağlantı), çalışma saatleri, kanallar
 * (WhatsApp / e-posta / bot), kayıt & KVKK. Şube başına bir ayar satırı.
 */
type Sekme = 'santral' | 'ivr' | 'kuyruk' | 'saat' | 'kanal' | 'kvkk';
const SAGLAYICILAR = [
  { kod: 'yok', ad: 'Santral yok (elle kayıt)' }, { kod: '3cx', ad: '3CX (HTTP API + webhook)' }, { kod: 'asterisk', ad: 'Asterisk / FreePBX (AMI + ARI)' },
  { kod: 'bulut', ad: 'Bulut santral (Netgsm / Bulutfon / Verimor webhook)' }, { kod: 'webrtc', ad: 'WebRTC softphone (sonraki adım)' },
];

export function CagriSantral() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [y, setY] = useState<SantralYaniti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('santral');
  const [f, setF] = useState<Record<string, string | number>>({});
  const [ivr, setIvr] = useState<IvrDali[]>([]);
  const [calisma, setCalisma] = useState<CalismaSaati[]>([]);
  const [gizli, setGizli] = useState(''); const [waToken, setWaToken] = useState('');
  const yukle = useCallback(async () => {
    try {
      const s = await api.cagriSantral(); setY(s); setHata(null);
      const a = s.ayar;
      setF({ saglayici: a.saglayici, apiAdres: a.apiAdres, kimlik: a.kimlik, kayitKaynak: a.kayitKaynak, kvkkAnons: a.kvkkAnons, kayitSaklamaAy: a.kayitSaklamaAy, mesaiDisiMesaj: a.mesaiDisiMesaj,
             whatsappNo: a.whatsappNo, botIlkYanit: a.botIlkYanit, epostaAdres: a.epostaAdres, islemSonrasiSn: a.islemSonrasiSn });
      setIvr(Array.isArray(a.ivr) ? a.ivr : []); setCalisma(Array.isArray(a.calisma) ? a.calisma : []);
    } catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);
  const duzenleyebilir = yetki('cagri.ayar', 'degistir');
  const g = (k: string, v: string | number) => setF(x => ({ ...x, [k]: v }));
  const kaydet = async () => {
    await guvenli(async () => {
      await api.cagriSantralKaydet({ saglayici: String(f.saglayici), apiAdres: String(f.apiAdres ?? ''), kimlik: String(f.kimlik ?? ''), gizli: gizli || undefined, kayitKaynak: String(f.kayitKaynak ?? ''),
        kvkkAnons: Number(f.kvkkAnons ?? 1), kayitSaklamaAy: Number(f.kayitSaklamaAy ?? 24), ivr, calisma, mesaiDisiMesaj: String(f.mesaiDisiMesaj ?? ''), whatsappNo: String(f.whatsappNo ?? ''),
        whatsappToken: waToken || undefined, botIlkYanit: String(f.botIlkYanit ?? ''), epostaAdres: String(f.epostaAdres ?? ''), islemSonrasiSn: Number(f.islemSonrasiSn ?? 45) });
      mesaj('Ayarlar kaydedildi.'); setGizli(''); setWaToken(''); await yukle();
    });
  };
  const sina = async () => { await guvenli(async () => { const r = await api.cagriSantralSina(); mesaj(r.bagli ? `✔ ${r.not_}${r.sonOlay ? ` Son olay: ${new Date(r.sonOlay).toLocaleString('tr-TR')}` : ''}` : `Eksik: ${r.eksik.join(', ')}`); await yukle() }) };
  const anahtarYenile = async () => { if (!await onay('Webhook anahtarı yenilensin mi? Santraldeki webhook adresi de güncellenmeli.', true)) return; await guvenli(async () => { await api.cagriSantralAnahtar(); await yukle() }) };

  if (hata && !y) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!y) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;
  const a = y.ayar;
  const webhook = y.webhookUrl.replace('{saglayici}', String(f.saglayici || 'santral')).replace('…', a.webhookAnahtar);
  const In = ({ k, lb, tip = 'text', g4 = false, ph = '' }: { k: string; lb: string; tip?: string; g4?: boolean; ph?: string }) =>
    <div className={`al${g4 ? ' g4' : ''}`}><span className="lb">{lb}</span><input className="inp" type={tip} value={String(f[k] ?? '')} placeholder={ph} onChange={e => g(k, tip === 'number' ? Number(e.target.value) : e.target.value)} disabled={!duzenleyebilir} /></div>;
  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>⚙️ Çağrı Merkezi Ayarları</h1><span className="yol">Çağrı Merkezi › Ayarlar › Santral · IVR · Kanallar · şube {a.subeId}</span>
        <div className="sag">
          {duzenleyebilir && <button className="d bir" onClick={() => void kaydet()}>💾 Kaydet</button>}
          {duzenleyebilir && <button className="d" onClick={() => void sina()}>🔌 Bağlantıyı sına</button>}
          <button className="d" onClick={() => git('/cagri-supervizor')}>📊 Süpervizör</button>
        </div></div></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="ka-sekmeler" style={{ padding: '0 0 8px' }}>
        {(['santral', 'ivr', 'kuyruk', 'saat', 'kanal', 'kvkk'] as Sekme[]).map(s => <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{{ santral: '🔌 Santral Bağlantısı', ivr: '🎛 IVR Menüsü', kuyruk: '👥 Kuyruklar & Agentlar', saat: '🕒 Çalışma Saatleri', kanal: '💬 Kanallar', kvkk: '🔐 Kayıt & KVKK' }[s]}</div>)}
      </div>
      {sekme === 'santral' && (
        <section className="fm-bolum">
          <div className="isg-frm">
            <div className="al g2"><span className="lb">Sağlayıcı</span><select className="inp" value={String(f.saglayici ?? 'yok')} onChange={e => g('saglayici', e.target.value)} disabled={!duzenleyebilir}>{SAGLAYICILAR.map(s => <option key={s.kod} value={s.kod}>{s.ad}</option>)}</select></div>
            <div className="al"><span className="lb">Durum</span><span className={`inp ro ${a.durum ? 'cg-ok' : ''}`}>{a.durum ? '● Bağlı' : '○ Bağlı değil'}{a.sonOlay ? ` · son olay ${new Date(a.sonOlay).toLocaleString('tr-TR')}` : ''}</span></div>
            <In k="apiAdres" lb="API adresi (3CX xapi / Asterisk ARI)" ph="https://pbx.kurum.local:5001/xapi/v1" />
            <In k="kimlik" lb="Kimlik (client id / AMI user)" />
            <div className="al"><span className="lb">Gizli anahtar {a.gizliVar ? '(kayıtlı)' : ''}</span><input className="inp" type="password" value={gizli} placeholder={a.gizliVar ? '••••••••' : ''} onChange={e => setGizli(e.target.value)} disabled={!duzenleyebilir} /></div>
            <In k="kayitKaynak" lb="Ses kaydı kaynağı (URL kökü)" ph="https://pbx…/recordings" />
            <div className="al g4"><span className="lb">{cev('Webhook (santral bu adrese olay gönderir)')}</span><span className="inp ro" style={{ fontFamily: 'Consolas, monospace', fontSize: 11 }}>{webhook}</span></div>
            <div className="al g2"><span className="lb">{cev('Webhook anahtarı')}</span><span className="inp ro" style={{ fontFamily: 'Consolas, monospace' }}>{a.webhookAnahtar} {duzenleyebilir && <button className="d mini" style={{ marginLeft: 'auto' }} onClick={() => void anahtarYenile()}>↻ Yenile</button>}</span></div>
            <div className="al g2"><span className="lb">{cev('Olay gövdesi (JSON)')}</span><span className="inp ro" style={{ fontFamily: 'Consolas, monospace', fontSize: 11 }}>{'{"olay":"ringing|answered|hold|unhold|transfer|hangup|voicemail","ref":"…","arayan":"05…","aranan":"…","kuyruk":"Q-801","dahili":"201","sureSn":0,"kayitUrl":"","hedef":""}'}</span></div>
          </div>
          <h3 className="fm-bolum-bas" style={{ marginTop: 8 }}>{cev('Dahili ↔ kullanıcı eşleşmesi')}<span className="sp" /><button className="d mini" onClick={() => git('/cagri-agent')}>✎ Agentlar</button></h3>
          <table className="fm-tablo"><thead><tr><th>{cev('Dahili')}</th><th>Kullanıcı</th><th>Kuyruklar</th><th>{cev('Softphone')}</th><th>Durum</th><th>Aktif</th></tr></thead>
            <tbody>{y.agentlar.map(x => <tr key={x.id} onDoubleClick={() => git(`/cagri-agent/${x.id}?geri=%2Fcagri-santral`)}><td>{x.dahili || <span className="cg-sari">boş</span>}</td><td>{x.agent_adi}</td><td>{x.kuyruk_adlari || '—'}</td><td>{x.softphone_adi}</td><td>{x.durum_adi}</td><td>{x.aktif_adi}</td></tr>)}
              {!y.agentlar.length && <tr><td colSpan={6} className="sonuk">Agent yok — kullanıcı operatör panosunu açınca otomatik satır oluşur; dahili buradan yazılır.</td></tr>}</tbody></table>
          <div className="sonuk" style={{ fontSize: 11, marginTop: 6 }}>Sağlayıcılar: 3CX (webhook + MakeCall), Asterisk/FreePBX (AMI/ARI, ChanSpy), bulut santral (webhook), WebRTC (sonraki adım). Bağlantı sınama şimdilik yapılandırma doğrulamasıdır; sürücü eklenince gerçek ağ çağrısı yapar.</div>
        </section>
      )}
      {sekme === 'ivr' && (
        <section className="fm-bolum">
          <div className="cg-ivr"><b>📞 Gelen arama</b> → <span className="hd">{Number(f.kvkkAnons) ? 'KVKK anonsu: "Görüşmeniz kalite amacıyla kaydedilmektedir"' : 'KVKK anonsu kapalı'}</span> → <span className="hd">{cev('Çalışma saati kontrolü')}</span></div>
          <table className="fm-tablo"><thead><tr><th style={{ width: 60 }}>{cev('Tuş')}</th><th>{cev('Menü metni')}</th><th>Kuyruk</th><th>{cev('Hedef (nöbetçi dahili / self-servis)')}</th><th>{cev('Anons')}</th><th /></tr></thead>
            <tbody>{ivr.map((d, i) => <tr key={i}>
              <td><input className="inp" style={{ width: 50 }} value={d.tus} onChange={e => setIvr(x => x.map((r, j) => j === i ? { ...r, tus: e.target.value } : r))} disabled={!duzenleyebilir} /></td>
              <td><input className="inp" value={d.ad} onChange={e => setIvr(x => x.map((r, j) => j === i ? { ...r, ad: e.target.value } : r))} disabled={!duzenleyebilir} /></td>
              <td><select className="inp" value={d.kuyruk ?? ''} onChange={e => setIvr(x => x.map((r, j) => j === i ? { ...r, kuyruk: e.target.value } : r))} disabled={!duzenleyebilir}><option value="">—</option>{y.kuyruklar.map(q => <option key={q.id} value={q.ad}>{q.ad}</option>)}</select></td>
              <td><input className="inp" value={d.hedef ?? d.self ?? ''} placeholder="nobetci / sonuc" onChange={e => setIvr(x => x.map((r, j) => j === i ? { ...r, hedef: e.target.value } : r))} disabled={!duzenleyebilir} /></td>
              <td><input className="inp" value={d.anons ?? ''} placeholder="ses dosyası / TTS metni" onChange={e => setIvr(x => x.map((r, j) => j === i ? { ...r, anons: e.target.value } : r))} disabled={!duzenleyebilir} /></td>
              <td>{duzenleyebilir && <button className="d mini" onClick={() => setIvr(x => x.filter((_, j) => j !== i))}>🗑</button>}</td></tr>)}</tbody></table>
          <div className="fm-doldur-arac">{duzenleyebilir && <button className="d" onClick={() => setIvr(x => [...x, { tus: '', ad: '', kuyruk: '' }])}>➕ Dal ekle</button>}
            <span className="sonuk">Self-servis "sonuc": TC son 4 + doğum yılı ile sonuç hazır anonsu ve WhatsApp bağlantısı (sürücü ile). Arayan tanınırsa randevu onay/değiştir dalı santral tarafında sunulur.</span></div>
          <div className="isg-frm" style={{ marginTop: 8 }}><div className="al g4"><span className="lb">{cev('Mesai dışı mesajı')}</span><textarea className="inp" rows={2} value={String(f.mesaiDisiMesaj ?? '')} onChange={e => g('mesaiDisiMesaj', e.target.value)} disabled={!duzenleyebilir} /></div></div>
        </section>
      )}
      {sekme === 'kuyruk' && (
        <section className="fm-bolum">
          <div className="fm-doldur-arac"><button className="d" onClick={() => git('/cagri-kuyruk')}>✎ Kuyruklar & SLA</button><button className="d" onClick={() => git('/cagri-agent')}>✎ Agentlar</button><button className="d" onClick={() => git('/cagri-konu')}>✎ Konu ağacı</button>
            <span className="sp sonuk">Agent durumları: hazır · çağrıda · işlem sonrası (otomatik {String(f.islemSonrasiSn ?? 45)} sn) · mola (sebep zorunlu) · çıkış</span></div>
          <table className="fm-tablo"><thead><tr><th>Kuyruk</th><th>{cev('Santral kodu')}</th><th>Kanal</th><th>{cev('Beceri')}</th><th className="fm-sag">Agent</th><th>SLA</th><th className="fm-sag">{cev('Max bekleme')}</th><th>{cev('Taşma')}</th><th>Durum</th></tr></thead>
            <tbody>{y.kuyruklar.map(q => <tr key={q.id} onDoubleClick={() => git(`/cagri-kuyruk/${q.id}?geri=%2Fcagri-santral`)}><td><b>{q.ad}</b></td><td>{q.santral_kodu || '—'}</td><td>{q.kanal_adi}</td><td>{q.beceri}</td><td className="fm-sag">{q.agent_sayisi}</td><td>{q.sla_sn} sn · %{q.sla_hedef}</td><td className="fm-sag">{q.max_bekleme_sn ? `${q.max_bekleme_sn} sn` : '—'}</td><td>{q.tasma_adi || '—'}</td><td>{q.aktif_adi}</td></tr>)}</tbody></table>
        </section>
      )}
      {sekme === 'saat' && (
        <section className="fm-bolum">
          <table className="fm-tablo"><thead><tr><th>Gün</th><th>Başlangıç</th><th>Bitiş</th><th /></tr></thead>
            <tbody>{calisma.map((c, i) => <tr key={i}>
              <td><input className="inp" value={c.gun} placeholder={cev('Pzt-Cum / Cmt / Pazar')} onChange={e => setCalisma(x => x.map((r, j) => j === i ? { ...r, gun: e.target.value } : r))} disabled={!duzenleyebilir} /></td>
              <td><input className="inp" type="time" value={c.bas} onChange={e => setCalisma(x => x.map((r, j) => j === i ? { ...r, bas: e.target.value } : r))} disabled={!duzenleyebilir} /></td>
              <td><input className="inp" type="time" value={c.bit} onChange={e => setCalisma(x => x.map((r, j) => j === i ? { ...r, bit: e.target.value } : r))} disabled={!duzenleyebilir} /></td>
              <td>{duzenleyebilir && <button className="d mini" onClick={() => setCalisma(x => x.filter((_, j) => j !== i))}>🗑</button>}</td></tr>)}</tbody></table>
          <div className="fm-doldur-arac">{duzenleyebilir && <button className="d" onClick={() => setCalisma(x => [...x, { gun: '', bas: '08:00', bit: '18:00' }])}>➕ Satır</button>}
            <span className="sonuk">Resmî tatiller kurumun tatil takvimiyle ortak (İzin modülü); tatilde mesai dışı anonsu çalar. Acil (0) 7/24 nöbetçi dahiliye gider.</span></div>
        </section>
      )}
      {sekme === 'kanal' && (
        <section className="fm-bolum">
          <div className="isg-frm">
            <In k="whatsappNo" lb="WhatsApp Business numarası (Meta Cloud API)" ph="+90 850 …" />
            <div className="al"><span className="lb">WhatsApp token {a.whatsappTokenVar ? '(kayıtlı)' : ''}</span><input className="inp" type="password" value={waToken} placeholder={a.whatsappTokenVar ? '••••••••' : ''} onChange={e => setWaToken(e.target.value)} disabled={!duzenleyebilir} /></div>
            <div className="al g2"><span className="lb">{cev('WhatsApp webhook')}</span><span className="inp ro" style={{ fontFamily: 'Consolas, monospace', fontSize: 11 }}>{webhook.replace(String(f.saglayici || 'santral'), 'wa')}</span></div>
            <div className="al g4"><span className="lb">{cev('Bot ilk yanıtı (sohbet kuyruğu)')}</span><input className="inp" value={String(f.botIlkYanit ?? '')} onChange={e => g('botIlkYanit', e.target.value)} disabled={!duzenleyebilir} /></div>
            <In k="epostaAdres" lb="E-posta kutusu (IMAP → Genel kuyruğu)" ph="info@kurum.com" g4 />
          </div>
          <div className="sonuk" style={{ fontSize: 11 }}>SMS: mevcut bildirim sağlayıcısı (Ayarlar › Bildirim). WhatsApp 24 saat penceresi dışında yalnız Meta onaylı şablon gider; bot iki adımda çözemezse sohbet Genel kuyruğuna devredilir.</div>
        </section>
      )}
      {sekme === 'kvkk' && (
        <section className="fm-bolum">
          <div className="isg-frm">
            <div className="al"><span className="lb">{cev('KVKK anonsu (IVR başı)')}</span><select className="inp" value={Number(f.kvkkAnons ?? 1)} onChange={e => g('kvkkAnons', Number(e.target.value))} disabled={!duzenleyebilir}><option value={1}>{cev('Zorunlu (açık)')}</option><option value={0}>{cev('Kapalı')}</option></select></div>
            <In k="kayitSaklamaAy" lb="Ses kaydı saklama (ay)" tip="number" />
            <In k="islemSonrasiSn" lb="İşlem sonrası süre (sn)" tip="number" />
            <div className="al"><span className="lb">{cev('Erişim')}</span><span className="inp ro">{cev('Süpervizör · Kalite · agent kendi çağrısı')}</span></div>
            <div className="al g2"><span className="lb">{cev('Arama izni')}</span><span className="inp ro">İletişim izni olmayan kişi kampanyaya girmez (taraf kartı)</span></div>
            <div className="al g2"><span className="lb">{cev('Silme talebi')}</span><span className="inp ro">Kişi kartı › KVKK › ses kayıtlarını sil (log'lu)</span></div>
            <div className="al g4"><span className="lb">{cev('Yetkiler')}</span><span className="inp ro">cagri.pano · cagri.kayit · cagri.giden · cagri.kampanya · cagri.supervizor · cagri.kalite · cagri.ayar</span></div>
          </div>
        </section>
      )}
    </div>
  );
}
