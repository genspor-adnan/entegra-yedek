import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { DisAkisSatiri, DisGunlukAkis as Akis } from '../../api/uclar/dis';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor } from '../../bilesenler/mesaj';
import { bugunIso, gunNokta, para } from '../../bilesenler/bicim';

/**
 * DİŞ KLİNİĞİ GÜNLÜK AKIŞ — mockup `Ekranlar/Dis Klinigi/dis_gunluk_akis.html`.
 *
 * Ünit × saat çizelgesi + liste, ikisi de aynı sunucu cevabından. Ayrı bir
 * randevu takvimi DEĞİLDİR: Randevu modülünün diş görünümü; randevu verme /
 * iptal genel kartta. Burada üç iş var: seans aç (hasta ünite oturdu),
 * gelmeyene yeniden planla, hasta kartına geç.
 *
 * Ünitteki hastada KALAN SÜRE çubuğu: seans başlangıcı + planlı süre; aşınca
 * kırmızı. Sunucu saatiyle (`simdi`) hesaplanır - tarayıcı saati şaşan masada
 * hasta "aştı" görünmesin.
 */

const SAAT_BAS = 8, SAAT_SON = 19;
const RD: Record<number, [string, string]> = { 1: ['Planlı', 'gri'], 2: ['Ünitte', 'mavi'], 3: ['Gelmedi', 'hata'], 4: ['İptal', 'gri'] };
const PD: Record<number, string> = { 1: 'Taslak', 2: 'Proforma bekliyor', 3: 'Plan onaylı', 4: 'Plan onaylı', 5: 'Tamamlandı' };
const LAB: Record<number, string> = { 1: 'ölçü', 2: 'labda', 3: 'labda', 4: 'labda', 5: 'lab ✔ geldi', 6: 'prova', 7: 'labda', 8: 'teslim' };

function saatMetni(iso: string) {
  const d = new Date(iso);
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

export function DisGunlukAkis() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [gun, setGun] = useState(bugunIso());
  const [veri, setVeri] = useState<Akis | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [suzgec, setSuzgec] = useState<'bugun' | 'bekleyen' | 'unitte' | 'tamamlanan' | 'gelmedi'>('bugun');
  const [ara, setAra] = useState('');
  const [secili, setSecili] = useState<number | null>(null);
  const [tik, setTik] = useState(0);

  const yukle = useCallback(async () => {
    try { setVeri(await api.disGunlukAkis(gun)); setHata(null) }
    catch (h) { setHata(hataMetni(h)) }
  }, [gun]);
  useEffect(() => { void yukle() }, [yukle]);
  // Kalan süre çubuğu dakikada bir ilerler.
  useEffect(() => { const t = setInterval(() => setTik(x => x + 1), 60000); return () => clearInterval(t) }, []);

  const simdi = useMemo(() => {
    if (!veri) return Date.now();
    return new Date(veri.simdi).getTime() + tik * 60000;
  }, [veri, tik]);

  const satirlar = useMemo(() => {
    let s = veri?.satirlar ?? [];
    if (suzgec === 'bekleyen') s = s.filter(x => x.randevuDurum === 1 && !x.seansId);
    else if (suzgec === 'unitte') s = s.filter(x => x.seansDurum === 1);
    else if (suzgec === 'tamamlanan') s = s.filter(x => x.seansDurum === 2);
    else if (suzgec === 'gelmedi') s = s.filter(x => x.randevuDurum === 3);
    if (ara.trim()) { const q = ara.trim().toLocaleLowerCase('tr'); s = s.filter(x => x.hasta.toLocaleLowerCase('tr').includes(q)) }
    return s;
  }, [veri, suzgec, ara]);

  const sayac = useMemo(() => {
    const t = veri?.satirlar ?? [];
    return {
      bugun: t.length, bekleyen: t.filter(x => x.randevuDurum === 1 && !x.seansId).length,
      unitte: t.filter(x => x.seansDurum === 1).length, tamamlanan: t.filter(x => x.seansDurum === 2).length,
      gelmedi: t.filter(x => x.randevuDurum === 3).length,
    };
  }, [veri]);

  const seansAc = async (s: DisAkisSatiri) => {
    await guvenli(async () => {
      const y = await api.disSeansAc({ randevuId: s.id });
      if (y.basvuruAcildi) mesaj(`Başvuru ${y.basvuruNo} açıldı (ödeyen: ${y.odeyen})${y.provizyonBekliyor ? ' - Medula provizyonu bekliyor' : ''}; seans başvuruya bağlandı.`);
      git(`/dis-seans/${y.id}`, { state: { geri: '/dis-akis' } });
    });
  };
  const yenidenPlanla = async (s: DisAkisSatiri) => {
    const varsayilan = `${gun}T${saatMetni(s.baslangic)}`;
    const m = await metinSor('Yeni randevu zamanı (yyyy-aa-ggTss:dd)', varsayilan);
    if (!m) return;
    const d = new Date(m);
    if (Number.isNaN(d.getTime())) { mesaj('Tarih anlaşılamadı.'); return }
    await guvenli(async () => {
      const y = await api.disYenidenPlanla(s.id, { baslangic: d.toISOString() });
      mesaj(`${y.hasta} için yeni randevu verildi.`);
      await yukle();
    });
  };

  const unitler = veri?.unitler ?? [];
  const saatler = Array.from({ length: (SAAT_SON - SAAT_BAS) * 2 }, (_, i) => SAAT_BAS * 60 + i * 30);
  const hucre = (unitId: number, dk: number) =>
    (veri?.satirlar ?? []).filter(s => {
      if (s.unitId !== unitId) return false;
      const d = new Date(s.baslangic); const bas = d.getHours() * 60 + d.getMinutes();
      return bas >= dk && bas < dk + 30;
    });
  const unitsiz = (veri?.satirlar ?? []).filter(s => !s.unitId);
  const o = veri?.ozet;

  const kalan = (s: DisAkisSatiri) => {
    if (!s.seansBaslangic || s.seansDurum !== 1) return null;
    const gecen = Math.round((simdi - new Date(s.seansBaslangic).getTime()) / 60000);
    const plan = s.sureDk || 30;
    return { gecen, plan, oran: Math.min(100, Math.round(100 * gecen / plan)), asti: gecen > plan };
  };

  const satirKutusu = (s: DisAkisSatiri) => {
    const k = kalan(s);
    const sinif = s.randevuDurum === 3 ? 'gelmedi' : s.seansDurum === 1 ? 'geldi' : s.seansDurum === 2 ? 'bitti'
      : s.labAsama && s.labAsama >= 5 && s.labAsama < 8 ? 'lab' : 'dolu';
    return (
      <div key={s.id} className={`ds-r ${sinif}${secili === s.id ? ' sec' : ''}`} onClick={() => setSecili(s.id)}
           onDoubleClick={() => git(`/dis-hasta/${s.hastaId}`, { state: { geri: '/dis-akis' } })}>
        <b>{s.hasta}{s.yas != null ? ` · ${s.yas}` : ''}</b>
        {s.planliIslem}{s.disNo ? ` · ${s.disNo}` : ''}{s.seansSayisi ? ` · ${(s.yapilanSeans ?? 0) + 1}. seans` : ''}
        {s.planNo && <span className="ds-plan-kod"><code>{s.planNo.replace('TP-', 'TP-').slice(0, 12)} / {s.planSira}</code></span>}
        {s.labAsama && <span className="rozet uyari" style={{ marginLeft: 4 }}>{LAB[s.labAsama]}</span>}
        {k && <><div className={`ds-sure${k.asti ? ' gec' : ''}`}><i style={{ width: `${k.oran}%` }} /></div>
          <span className={`sonuk${k.asti ? ' ds-kir' : ''}`}>{k.gecen} / {k.plan} dk{k.asti ? ` · ${k.gecen - k.plan} dk aştı` : ` · kalan ${k.plan - k.gecen}`}</span></>}
      </div>
    );
  };

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>🦷 Diş Kliniği — Günlük Akış</h1>
          <span className="yol">Diş › Günlük Akış</span>
          <span className="sonuk">{gunNokta(gun)} · {unitler.length} ünit</span>
        </div>
        <div className="basarac">
          <input type="date" value={gun} onChange={e => setGun(e.target.value)} />
          <button className="d" onClick={() => setGun(bugunIso())}>Bugün</button>
          {yetki('dis.seans') && <button className="d bir" onClick={() => { const s = (veri?.satirlar ?? []).find(x => x.id === secili); if (!s) { mesaj('Çizelgeden bir hasta seçin.'); return } void seansAc(s) }}>🪑 Muayene / Seans Aç</button>}
          <button className="d" onClick={() => { const s = (veri?.satirlar ?? []).find(x => x.id === secili); if (!s) { mesaj('Önce bir hasta seçin.'); return } git(`/dis-hasta/${s.hastaId}`, { state: { geri: '/dis-akis' } }) }}>👤 Hasta Kartı</button>
          {yetki('randevu') && <button className="d" onClick={() => git('/randevu/yeni')}>📅 Randevu Ver</button>}
          {yetki('dis.lab') && <button className="d" onClick={() => git('/dis-lab-isemri')}>🧪 Lab Teslimleri{o?.labBekleyen ? ` (${o.labBekleyen})` : ''}</button>}
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        </div>
      </div>

      <div className="sahne ds-sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="ds-arac">
          <input placeholder="Hasta ara…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 220 }} />
          {([['bugun', `Bugün (${sayac.bugun})`], ['bekleyen', `Bekleyen (${sayac.bekleyen})`], ['unitte', `Ünitte (${sayac.unitte})`],
             ['tamamlanan', `Tamamlanan (${sayac.tamamlanan})`], ['gelmedi', `Gelmedi (${sayac.gelmedi})`]] as [typeof suzgec, string][])
            .map(([k, ad]) => <span key={k} className={`cip${suzgec === k ? ' on' : ''}`} onClick={() => setSuzgec(k)}>{ad}</span>)}
        </div>

        <div className="ds-ozet6" style={{ padding: '8px 0' }}>
          <div><span>Randevu</span><b>{o?.randevu ?? 0}</b><i>{o?.randevusuz ?? 0} randevusuz</i></div>
          <div><span>Ünit doluluk</span><b>%{veri?.doluluk ?? 0}</b><i>{o?.unitSayisi ?? 0} ünit · 9 saat</i></div>
          <div><span>Ort. seans</span><b>{o?.ortSeansDk ?? 0} dk</b><i>{o?.tamamlanan ?? 0} tamamlanan</i></div>
          <div><span>Bugün ciro</span><b>{para.format(o?.ciro ?? 0)}</b><i>seans ücretleri</i></div>
          <div><span>Lab teslim bekleyen</span><b>{o?.labBekleyen ?? 0}</b><i className={o?.labGecikti ? 'ds-kir' : ''}>{o?.labGecikti ?? 0} gecikti</i></div>
          <div><span>Plan onayı bekleyen</span><b>{o?.onayBekleyen ?? 0}</b><i>proforma</i></div>
        </div>

        {/* ------------------------------------------------- çizelge */}
        {unitler.length > 0 ? (
          <div className="ds-cizelge" style={{ gridTemplateColumns: `60px repeat(${unitler.length}, 1fr)` }}>
            <div className="ds-cz-bas" />
            {unitler.map(u => <div key={u.id} className="ds-cz-bas">{u.kod} · {u.ad}{u.hekim ? ` · ${u.hekim}` : ''}</div>)}
            {saatler.map(dk => (
              <div key={dk} style={{ display: 'contents' }}>
                <div className="ds-cz-saat">{String(Math.floor(dk / 60)).padStart(2, '0')}:{String(dk % 60).padStart(2, '0')}</div>
                {unitler.map(u => {
                  const h = hucre(u.id, dk);
                  return <div key={u.id} className="ds-cz-hucre">{h.length ? h.map(satirKutusu) : <div className="ds-r bos">boş</div>}</div>;
                })}
              </div>
            ))}
          </div>
        ) : (
          <div className="bilgi-kutusu">Ünit tanımlı değil - <a href="#" onClick={e => { e.preventDefault(); git('/dis-unit') }}>Diş › Ayarlar › Ünitler</a>'den koltukları tanımlayın. Randevular aşağıdaki listede.</div>
        )}
        {unitsiz.length > 0 && unitler.length > 0 && (
          <div className="ds-arac"><span className="sonuk">Ünitsiz randevular:</span>{unitsiz.map(satirKutusu)}</div>
        )}

        {/* ------------------------------------------------- liste */}
        <div className="ds-dg" style={{ marginTop: 10 }}><table>
          <thead><tr><th className="orta">Saat</th><th>Hasta</th><th className="orta">Yaş</th><th>Hekim / Ünit</th><th>Planlı işlem</th><th className="orta">Plan satırı</th><th>Uyarı</th><th className="orta">Plan durumu</th><th className="sag">Bakiye</th><th className="orta">Durum</th></tr></thead>
          <tbody>
            {satirlar.map(s => (
              <tr key={s.id} className={secili === s.id ? 'sel' : ''} onClick={() => setSecili(s.id)} onDoubleClick={() => git(`/dis-hasta/${s.hastaId}`, { state: { geri: '/dis-akis' } })}>
                <td className="orta">{saatMetni(s.baslangic)}</td>
                <td>{s.hasta}</td>
                <td className="orta">{s.yas ?? ''}</td>
                <td>{s.hekim}{s.unitKod ? ` · ${s.unitKod}` : ''}</td>
                <td>{s.disNo ? `${s.disNo} ` : ''}{s.planliIslem}{s.seansSayisi ? ` · ${s.yapilanSeans}/${s.seansSayisi} seans` : ''}</td>
                <td className="orta">{s.planNo ? <code>{s.planNo} / {s.planSira}</code> : <span className="rozet gri">plan yok</span>}</td>
                <td>{s.alerji && s.alerji.split(', ').map(a => <span key={a} className="rozet hata">{a}</span>)}
                    {s.labAsama != null && s.labAsama >= 5 && s.labAsama < 8 && <span className="rozet ok">Lab işi geldi</span>}</td>
                <td className="orta">{s.planDurum ? <span className="rozet mavi">{PD[s.planDurum]} · {s.planYapilan}/{s.planToplamSatir}</span> : '—'}</td>
                <td className={`sag${s.bakiye > 0 ? ' ds-kir' : ''}`}>{para.format(s.bakiye)}</td>
                <td className="orta">
                  <span className={`rozet ${s.seansDurum === 1 ? 'mavi' : s.seansDurum === 2 ? 'ok' : RD[s.randevuDurum]?.[1] ?? 'gri'}`}>
                    {s.seansDurum === 1 ? 'Ünitte' : s.seansDurum === 2 ? 'Tamamlandı' : RD[s.randevuDurum]?.[0]}
                  </span>
                  {s.randevuDurum === 3 && yetki('randevu') && <button className="d" style={{ marginLeft: 4 }} onClick={e => { e.stopPropagation(); void yenidenPlanla(s) }}>▶ Yeniden planla</button>}
                  {s.randevuDurum === 1 && !s.seansId && yetki('dis.seans') && <button className="d" style={{ marginLeft: 4 }} onClick={e => { e.stopPropagation(); void seansAc(s) }}>🪑 Seans</button>}
                  {s.seansId && s.seansDurum === 1 && <button className="d" style={{ marginLeft: 4 }} onClick={e => { e.stopPropagation(); git(`/dis-seans/${s.seansId}`, { state: { geri: '/dis-akis' } }) }}>Seans kartı</button>}
                </td>
              </tr>
            ))}
            {satirlar.length === 0 && <tr><td colSpan={10} className="sonuk">Bu günde diş randevusu yok. Randevu kartında bölüm "Diş" ya da ünit seçilen randevular burada görünür.</td></tr>}
          </tbody>
        </table></div>
        <div className="sonuk" style={{ marginTop: 6 }}>Satır = randevu (ünit + hekim) + başvuru; seans açılınca plan satırı ücretlenir. Çizelge kutusunda <code>TP-… / n</code> = plan satırı; ünitteki hastada kalan süre çubuğu (aşınca kırmızı); "Gelmedi" satırında ▶ Yeniden planla aynı plan satırıyla yeni randevu açar.</div>
      </div>
    </>
  );
}
