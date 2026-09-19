import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { ArayanYaniti, CagriPano as Pano, CagriSatiri, KapatIstegi } from '../../api/uclar/cagri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, secimSor } from '../../bilesenler/mesaj';

/**
 * OPERATÖR PANOSU `/cagri-pano` (Çağrı Merkezi 839) — mockup
 * Ekranlar/CagriMerkezi/cagri_operator_panosu.html. Üstte softphone çubuğu
 * (agent durumu, aktif çağrı süresi), solda kuyruk + bugünkü çağrılar, ortada
 * arayan kartı (tanıma → kişi özeti, hızlı işlemler, geçmiş, betik), sağda
 * çağrı kaydı (konu ağacı, sonuç, not, geri arama). 5 sn'de bir yenilenir;
 * santral olayı gelince (webhook) çağrı kuyrukta / aktifte belirir.
 */
export const SONUCLAR: { kod: number; ad: string }[] = [
  { kod: 1, ad: 'Çözüldü' }, { kod: 7, ad: 'Randevu verildi' }, { kod: 6, ad: 'Bilgi verildi' }, { kod: 2, ad: 'Geri aranacak' },
  { kod: 3, ad: 'Görev açıldı' }, { kod: 5, ad: 'Yönlendirildi' }, { kod: 4, ad: 'Ulaşılamadı' }, { kod: 8, ad: 'Vazgeçti' },
];
const AGENT_DURUM: Record<number, { ad: string; sinif: string }> = {
  1: { ad: 'Hazır', sinif: 'hazir' }, 2: { ad: 'Çağrıda', sinif: 'mesgul' }, 3: { ad: 'İşlem sonrası', sinif: 'islem' }, 4: { ad: 'Mola', sinif: 'mola' }, 5: { ad: 'Çıkış', sinif: 'cikis' },
};
export const sureYaz = (sn: number) => `${Math.floor(sn / 60)}:${String(Math.max(0, sn) % 60).padStart(2, '0')}`;
const saat = (d?: string | null) => d ? new Date(d).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }) : '';
const KANAL_IK: Record<number, string> = { 1: '📞', 2: '💬', 3: '📱', 4: '🌐', 5: '✉️' };
type Sekme = 'hizli' | 'ozet' | 'gecmis' | 'betik';

export function CagriOperator() {
  const git = useNavigate();
  const [sorgu, setSorgu] = useSearchParams();
  const { yetki } = useOturum();
  const [p, setP] = useState<Pano | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [seciliId, setSeciliId] = useState<number>(Number(sorgu.get('cagri') ?? 0));
  const [arayan, setArayan] = useState<ArayanYaniti | null>(null);
  const [sekme, setSekme] = useState<Sekme>('hizli');
  const [tik, setTik] = useState(0);
  // kayıt formu
  const [konuId, setKonuId] = useState(0); const [altKonuId, setAltKonuId] = useState(0); const [sonuc, setSonuc] = useState(1);
  const [notu, setNotu] = useState(''); const [geriArama, setGeriArama] = useState(''); const [gorevKonu, setGorevKonu] = useState(''); const [memnuniyet, setMemnuniyet] = useState(0);

  const yukle = useCallback(async () => {
    try { const y = await api.cagriPano(); setP(y); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle(); const t = setInterval(() => { void yukle(); setTik(x => x + 1) }, 5000); return () => clearInterval(t) }, [yukle]);
  useEffect(() => { const t = setInterval(() => setTik(x => x + 1), 1000); return () => clearInterval(t) }, []);

  // Seçili çağrı: aktif çağrı ya da listeden tıklanan (kayıt bekleyen / kuyruktaki).
  const secili: CagriSatiri | null = useMemo(() => {
    if (!p) return null;
    if (seciliId) return [...p.bugun, ...p.bekleyen, ...(p.aktif ? [p.aktif] : [])].find(c => c.id === seciliId) ?? null;
    return p.aktif;
  }, [p, seciliId]);
  useEffect(() => { if (!seciliId && p?.aktif) setSeciliId(p.aktif.id) }, [p, seciliId]);
  useEffect(() => {
    if (!secili) { setArayan(null); return }
    setKonuId(secili.konu_id ?? 0); setAltKonuId(secili.alt_konu_id ?? 0); setSonuc(secili.sonuc || 1); setNotu(secili.notu ?? ''); setGeriArama(''); setGorevKonu(''); setMemnuniyet(secili.memnuniyet ?? 0);
    api.cagriArayan(secili.arayan_no, secili.taraf_id ?? undefined).then(setArayan).catch(h => setHata(hataMetni(h)));
    setSorgu(s => { s.set('cagri', String(secili.id)); return s }, { replace: true });
  }, [secili?.id, secili?.arayan_no, secili?.taraf_id]); // eslint-disable-line react-hooks/exhaustive-deps

  const durumDegistir = async (d: number) => {
    let mola: number | undefined;
    if (d === 4) { const m = await secimSor('Mola sebebi', [{ kod: '1', ad: 'Yemek' }, { kod: '2', ad: 'Kısa mola' }, { kod: '3', ad: 'Eğitim' }, { kod: '4', ad: 'Toplantı' }, { kod: '5', ad: 'Diğer' }]); if (!m) return; mola = Number(m) }
    await guvenli(async () => { await api.cagriAgentDurum(d, mola); await yukle() });
  };
  const ara = async () => {
    const tel = await metinSor('Aranacak numara', arayan?.ozet?.cepTel ?? '', 'Telefon'); if (tel === null) return;
    await guvenli(async () => { const y = await api.cagriBaslat({ kanal: 1, yon: 2, arayanNo: tel.trim(), tarafId: arayan?.tarafId ?? null }); setSeciliId(y.id); await yukle() });
  };
  const ustlen = async (c: CagriSatiri) => { await guvenli(async () => { await api.cagriUstlen(c.id); setSeciliId(c.id); await yukle() }) };
  const kapat = async () => {
    if (!secili) return;
    if (!konuId) { mesaj('Konu seçin.'); return }
    if (sonuc === 2 && !geriArama) { mesaj('"Geri aranacak" için tarih/saat girin.'); return }
    const g: KapatIstegi = { konuId, altKonuId: altKonuId || null, sonuc, notu, tarafId: arayan?.tarafId ?? secili.taraf_id ?? null,
      geriArama: sonuc === 2 ? new Date(geriArama).toISOString() : null, gorevKonu: gorevKonu || null, memnuniyet: memnuniyet || null };
    await guvenli(async () => { const y = await api.cagriKapat(secili.id, g); mesaj(y.gorevId ? `Kayıt tamamlandı; görev #${y.gorevId} açıldı.` : 'Çağrı kaydı tamamlandı.'); setSeciliId(0); await yukle() });
  };
  const mesajGonder = async (sablon: 'odeme_linki' | 'yol_tarifi' | 'anket') => {
    if (!secili) return;
    let tutar: string | undefined, baglanti: string | undefined;
    if (sablon === 'odeme_linki') { const t = await metinSor('Tutar (TL)', arayan?.ozet ? String(Math.max(0, arayan.ozet.bakiye)) : '', 'Tutar'); if (t === null) return; tutar = t; const l = await metinSor('Ödeme bağlantısı', '', 'Bağlantı'); if (l === null) return; baglanti = l }
    if (sablon === 'anket') { const l = await metinSor('Anket bağlantısı (form motoru)', '', 'Bağlantı'); if (l === null) return; baglanti = l }
    if (sablon === 'yol_tarifi') { const l = await metinSor('Harita bağlantısı', 'https://maps.google.com/?q=', 'Konum'); if (l === null) return; baglanti = l }
    await guvenli(async () => { await api.cagriMesaj(secili.id, { sablon, tutar, baglanti }); mesaj('Mesaj bildirim kuyruğuna alındı.'); await yukle() });
  };
  const ilgiliVeGit = (yol: string) => { if (secili) sessionStorage.setItem('cagri.aktif', String(secili.id)); git(yol) };

  if (hata && !p) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!p) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;
  const ag = p.agent; const ad = AGENT_DURUM[ag?.durum ?? 5];
  const buradan = `/cagri-pano${secili ? `?cagri=${secili.id}` : ''}`;
  const geriP = `?geri=${encodeURIComponent(buradan)}`;
  const o = arayan?.ozet;
  const konular = p.konular.filter(k => !k.ust_id); const altlar = p.konular.filter(k => k.ust_id === konuId);
  const konu = konular.find(k => k.id === konuId);
  const sureSn = secili?.cevap ? Math.floor((Date.now() - new Date(secili.cevap).getTime()) / 1000) : secili ? Math.floor((Date.now() - new Date(secili.baslama).getTime()) / 1000) : 0;
  void tik;
  const kisiYolu = o ? (o.hasta ? `/hasta/${o.tarafId}` : `/cari/${o.tarafId}`) : '';
  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>🎧 Operatör Panosu</h1><span className="yol">Çağrı Merkezi › Operatör Panosu · {ag ? `Dahili ${ag.dahili || '—'}` : 'Agent kaydı yok'}{ag?.kuyruk_adlari ? ` · ${ag.kuyruk_adlari}` : ''}</span>
        <div className="sag">
          {yetki('cagri.giden') && <button className="d" onClick={() => git('/cagri-giden')}>📤 Geri arama · Kampanya</button>}
          {yetki('cagri.supervizor') && <button className="d" onClick={() => git('/cagri-supervizor')}>📊 Süpervizör</button>}
          <button className="d" onClick={() => git('/dokumler?grup=%C3%87a%C4%9Fr%C4%B1%20Merkezi')}>📊 Dökümler</button>
        </div></div></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="cg-soft">
        <span className={`cg-dur ${ad.sinif}`}>● {ad.ad}</span>
        {secili ? <>
          <span className="cg-no">{secili.arayan_no || '—'}</span>
          <span className="cg-soft-sonuk">{secili.yon_adi} · {secili.kuyruk_adi || secili.kanal_adi} · {secili.durum_adi}</span>
          {secili.durum <= 3 && <span className="cg-sure">⏱ {sureYaz(sureSn)}</span>}
          {secili.durum === 1 && <button className="cg-tb ok" onClick={() => void ustlen(secili)}>📞 Cevapla / üstlen</button>}
          {secili.durum <= 4 && <button className="cg-tb kir" onClick={() => void kapat()}>💾 Kaydet &amp; kapat</button>}
          <button className="cg-tb" onClick={() => setSeciliId(0)}>✖ Bırak</button>
        </> : <span className="cg-soft-sonuk">Aktif çağrı yok — kuyruktan seç ya da ara.</span>}
        <span className="sp">
          <span className="cg-soft-sonuk">Bugün {p.ozet.cagri} çağrı · ort. {sureYaz(p.ozet.ortSureSn)} · kaçan {p.ozet.kacan} · SLA {p.ozet.gunCevaplanan ? Math.round(100 * p.ozet.gunSla / p.ozet.gunCevaplanan) : 0}%</span>
          {yetki('cagri.kayit', 'ekle') && <button className="cg-tb" onClick={() => void ara()}>📞 Ara</button>}
          {ag?.durum !== 4 ? <button className="cg-tb" onClick={() => void durumDegistir(4)}>☕ Mola</button> : null}
          {ag?.durum !== 1 && <button className="cg-tb ok" onClick={() => void durumDegistir(1)}>✔ Hazır</button>}
          {ag?.durum !== 5 && <button className="cg-tb" onClick={() => void durumDegistir(5)}>⏻ Çıkış</button>}
        </span>
      </div>
      <div className="cg-uc">
        <div>
          <section className="fm-bolum"><h3 className="fm-bolum-bas">⏳ Kuyruk <span className="sp sonuk">{p.bekleyen.length} bekliyor</span></h3>
            <ul className="cg-kuy">
              {p.bekleyen.map(c => <li key={c.id} className={c.id === secili?.id ? 'sel' : ''} onClick={() => setSeciliId(c.id)}>
                <span>{KANAL_IK[c.kanal] ?? '📞'}</span><span><b>{c.arayan_no || c.kanal_adi}</b><br /><span className="sonuk">{c.taraf_adi || 'Tanınmıyor'} · {c.kuyruk_adi || c.durum_adi}</span></span>
                <span className="bek">{sureYaz(Math.floor((Date.now() - new Date(c.baslama).getTime()) / 1000))}</span></li>)}
              {!p.bekleyen.length && <li className="sonuk">Bekleyen çağrı yok.</li>}
            </ul>
            <div className="sonuk" style={{ fontSize: 11 }}>{p.kuyruklar.map(q => `${q.ad} (${q.bekleyen})`).join(' · ')}</div>
          </section>
          <section className="fm-bolum"><h3 className="fm-bolum-bas">📋 Bugünkü çağrılarım</h3>
            <ul className="cg-kuy">
              {p.bugun.map(c => <li key={c.id} className={c.id === secili?.id ? 'sel' : ''} onClick={() => setSeciliId(c.id)}>
                <span>{c.durum === 4 ? '📝' : c.durum === 6 ? '📵' : c.sonuc === 2 ? '↩' : '✔'}</span>
                <span>{saat(c.baslama)} · {c.taraf_adi || c.arayan_no}<br /><span className="sonuk">{c.durum === 4 ? 'Kayıt bekliyor' : c.sonuc_adi || c.durum_adi}{c.konu_adi ? ` · ${c.konu_adi}` : ''}</span></span>
                <span className="sonuk">{sureYaz(c.sure_sn)}</span></li>)}
              {!p.bugun.length && <li className="sonuk">Henüz çağrı yok.</li>}
            </ul>
          </section>
        </div>
        <div>
          {secili ? <>
            <div className="cg-gelen">
              <div className="ari"><span style={{ fontSize: 24 }}>{KANAL_IK[secili.kanal] ?? '📞'}</span><span className="no">{secili.arayan_no || '—'}</span>
                {o ? <><span className="kim">{o.ad}</span>{o.hasta ? <span className="rz mavi">Hasta</span> : null}{o.musteri ? <span className="rz mor">Cari</span> : null}{o.personel ? <span className="rz">Personel</span> : null}</>
                   : <span className="rz sari">Tanınmıyor</span>}
                <span className="sp">
                  {o && <button className="d mini" onClick={() => ilgiliVeGit(`${kisiYolu}${geriP}`)}>👤 Kişi kartı</button>}
                  {(arayan?.adaylar.length ?? 0) > 1 && <button className="d mini" onClick={async () => {
                    const s = await secimSor('Arayan kim?', arayan!.adaylar.map(a => ({ kod: String(a.taraf_id), ad: `${a.ad} (${a.hasta ? 'hasta' : a.musteri ? 'cari' : 'kişi'})` }))); if (!s) return;
                    setArayan(await api.cagriArayan(secili.arayan_no, Number(s)));
                  }}>🔁 Başka kişi</button>}
                  {!o && <button className="d mini" onClick={() => ilgiliVeGit(`/hasta/yeni${geriP}&cepTel=${encodeURIComponent(secili.arayan_no)}`)}>＋ Yeni hasta</button>}
                </span>
              </div>
              {o && <>
                <div className="oz"><span className="lb">Kod / TC</span><b>{o.kod || '—'} · {o.tckn || '—'}{o.dogumTarihi ? ` · ${new Date(o.dogumTarihi).toLocaleDateString('tr-TR')}` : ''}</b></div>
                <div className="oz"><span className="lb">Son ziyaret</span><b>{o.sonZiyaret || '—'}</b></div>
                <div className="oz"><span className="lb">Yaklaşan randevu</span><b>{o.yaklasanRandevu?.metin ?? '—'}</b></div>
                <div className="oz"><span className="lb">Sonuç</span><b className={o.bekleyenSonuc ? 'cg-sari' : ''}>{o.bekleyenSonuc ? `${o.bekleyenSonuc} bekleyen` : 'Bekleyen yok'}{o.hazirSonuc ? ` · ${o.hazirSonuc} hazır (7 g)` : ''}</b></div>
                <div className="oz"><span className="lb">Bakiye</span><b className={o.bakiye > 0 ? 'cg-kir' : ''}>{o.bakiye.toLocaleString('tr-TR', { minimumFractionDigits: 2 })} ₺{o.bakiye > 0 ? ' borç' : ''}</b></div>
                <div className="oz"><span className="lb">Açık görev / son çağrı</span><b>{o.acikGorev} görev · {arayan?.sonCagrilar.length ?? 0} çağrı (son: {arayan?.sonCagrilar[0] ? saat(arayan.sonCagrilar[0].baslama) + ' ' + new Date(arayan.sonCagrilar[0].baslama).toLocaleDateString('tr-TR') : '—'})</b></div>
              </>}
            </div>
            <div className="ka-sekmeler" style={{ padding: '0 0 8px' }}>
              {(['hizli', 'ozet', 'gecmis', 'betik'] as Sekme[]).map(s => <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{{ hizli: '⚡ Hızlı İşlem', ozet: '👤 Kişi Özeti', gecmis: '📜 Geçmiş Çağrılar', betik: '📖 Betik' }[s]}</div>)}
            </div>
            {sekme === 'hizli' && (
              <div className="cg-hizli">
                <div className="h" onClick={() => ilgiliVeGit(`/randevu/yeni${geriP}${o ? `&hastaId=${o.tarafId}` : ''}`)}><div className="ik">📅</div><b>Randevu Ver</b>Hekim/bölüm takvimi</div>
                <div className={`h${o?.yaklasanRandevu ? '' : ' pas'}`} onClick={() => o?.yaklasanRandevu && ilgiliVeGit(`/randevu/${o.yaklasanRandevu.id}${geriP}`)}><div className="ik">✏️</div><b>Randevu Değiştir</b>{o?.yaklasanRandevu?.metin ?? 'Yaklaşan randevu yok'}</div>
                <div className={`h${o ? '' : ' pas'}`} onClick={() => o && ilgiliVeGit(`/hasta/${o.tarafId}${geriP}`)}><div className="ik">🧪</div><b>Sonuç Bilgisi</b>{o ? `Hazır: ${o.hazirSonuc} · Bekleyen: ${o.bekleyenSonuc}` : '—'}</div>
                <div className="h" onClick={() => void mesajGonder('odeme_linki')}><div className="ik">💳</div><b>Ödeme Linki</b>{o && o.bakiye > 0 ? `${o.bakiye.toLocaleString('tr-TR')} ₺` : 'SMS / WhatsApp'}</div>
                <div className="h" onClick={() => void mesajGonder('yol_tarifi')}><div className="ik">🗺️</div><b>Yol Tarifi Gönder</b>WhatsApp konum</div>
                <div className="h" onClick={() => { setGorevKonu(g => g || `Şikayet: ${o?.ad ?? secili.arayan_no}`); setSonuc(3); setKonuId(konular.find(k => k.hizli_islem === 4)?.id ?? konuId) }}><div className="ik">⚠️</div><b>Şikayet Aç</b>Görev (48 saat)</div>
                <div className="h" onClick={() => { setSonuc(2); if (!geriArama) { const d = new Date(Date.now() + 2 * 3600000); d.setSeconds(0, 0); setGeriArama(new Date(d.getTime() - d.getTimezoneOffset() * 60000).toISOString().slice(0, 16)) } }}><div className="ik">↩️</div><b>Geri Arama Planla</b>Tarih/saat + not</div>
                <div className={`h${o ? '' : ' pas'}`} onClick={() => o && ilgiliVeGit(`/hasta-formlar/${o.tarafId}${geriP}`)}><div className="ik">📋</div><b>Form Gönder</b>Onam / anket (SMS link)</div>
              </div>
            )}
            {sekme === 'ozet' && (o ? (
              <div className="isg-frm">
                <Al lb="Ad" v={o.ad} /><Al lb="Kod" v={o.kod || '—'} /><Al lb="TC / VKN" v={o.tckn || '—'} /><Al lb="Cep / Telefon" v={`${o.cepTel || '—'} · ${o.telefon || '—'}`} />
                <Al lb="Doğum" v={o.dogumTarihi ? new Date(o.dogumTarihi).toLocaleDateString('tr-TR') : '—'} /><Al lb="Cinsiyet" v={o.cinsiyet === 1 ? 'Erkek' : o.cinsiyet === 2 ? 'Kadın' : '—'} />
                <Al lb="Son ziyaret" v={o.sonZiyaret || '—'} /><Al lb="Yaklaşan randevu" v={o.yaklasanRandevu?.metin ?? '—'} />
                <Al lb="Bekleyen sonuç" v={String(o.bekleyenSonuc)} /><Al lb="Hazır sonuç (7 g)" v={String(o.hazirSonuc)} /><Al lb="Bakiye" v={`${o.bakiye.toLocaleString('tr-TR', { minimumFractionDigits: 2 })} ₺`} /><Al lb="Açık görev" v={String(o.acikGorev)} />
              </div>
            ) : <div className="sonuk">Arayan tanınmadı; "Yeni hasta" ya da "Başka kişi" ile bağlayın.</div>)}
            {sekme === 'gecmis' && (
              <table className="fm-tablo"><thead><tr><th>Tarih</th><th>Kanal</th><th>Yön</th><th>Konu</th><th>Agent</th><th className="fm-sag">Süre</th><th>Sonuç</th></tr></thead>
                <tbody>{(arayan?.sonCagrilar ?? []).filter(c => c.id !== secili.id).map(c => <tr key={c.id} onDoubleClick={() => git(`/cagri/${c.id}${geriP}`)}>
                  <td>{new Date(c.baslama).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' })}</td><td>{KANAL_IK[c.kanal]} {c.kanal_adi}</td><td>{c.yon_adi}</td>
                  <td>{c.konu_adi}{c.alt_konu_adi ? ` › ${c.alt_konu_adi}` : ''}</td><td>{c.agent_adi}</td><td className="fm-sag">{sureYaz(c.sure_sn)}</td><td>{c.sonuc_adi || c.durum_adi}</td></tr>)}
                  {!(arayan?.sonCagrilar ?? []).filter(c => c.id !== secili.id).length && <tr><td colSpan={7} className="sonuk">Önceki çağrı yok.</td></tr>}
                </tbody></table>
            )}
            {sekme === 'betik' && (
              <div className="cg-betik">{konu?.betik ? <><b>{konu.ad}:</b> {konu.betik}</> : <><b>Karşılama:</b> "{p.agent?.agent_adi ? `Merhaba, ben ${p.agent.agent_adi.split(' ')[0]}, ` : ''}size nasıl yardımcı olabilirim?"<br /><b>Kimlik doğrulama (randevu/sonuç için):</b> ad soyad + doğum yılı ya da TC son 4. Üçüncü kişiye sonuç bilgisi verilmez (KVKK).<br /><b>Kapanış:</b> "Başka bir konuda yardımcı olabilir miyim? İyi günler dileriz."<br /><span className="sonuk">Konu seçilince o konunun betiği gelir (Ayarlar › Konu ağacı).</span></>}</div>
            )}
          </> : (
            <div className="fm-bolum sonuk">Kuyruktan bir çağrı seçin, bugünkü çağrılardan "kayıt bekleyen" bir kaydı açın ya da 📞 Ara ile giden çağrı başlatın.
              {yetki('cagri.ayar') && <> Santral bağlı değilse: <a href="#" onClick={e => { e.preventDefault(); git('/cagri-santral') }}>Ayarlar › Santral</a>.</>}</div>
          )}
        </div>
        <div>
          <section className="fm-bolum"><h3 className="fm-bolum-bas">📝 Çağrı kaydı <span className="sp sonuk">{secili ? `#C-${secili.id}` : ''}</span></h3>
            {secili ? <>
              <div className="cg-lb">Konu</div>
              <div className="cg-konu">{konular.map(k => <span key={k.id} className={`k${konuId === k.id ? ' on' : ''}`} onClick={() => { setKonuId(k.id); setAltKonuId(0) }}>{k.ad}</span>)}</div>
              {altlar.length > 0 && <><div className="cg-lb">Alt konu</div><div className="cg-konu">{altlar.map(k => <span key={k.id} className={`k${altKonuId === k.id ? ' on' : ''}`} onClick={() => setAltKonuId(k.id)}>{k.ad}</span>)}</div></>}
              <div className="cg-lb">Not</div>
              <textarea className="cg-not" value={notu} onChange={e => setNotu(e.target.value)} rows={4} placeholder={konu?.sonuclar ? `Sonuç önerileri: ${konu.sonuclar}` : 'Görüşme notu'} />
              <div className="isg-frm" style={{ gridTemplateColumns: '1fr 1fr' }}>
                <div className="al"><span className="lb">Sonuç</span><select className="inp" value={sonuc} onChange={e => setSonuc(Number(e.target.value))}>{SONUCLAR.map(s => <option key={s.kod} value={s.kod}>{s.ad}</option>)}</select></div>
                <div className="al"><span className="lb">Memnuniyet (1-5)</span><select className="inp" value={memnuniyet} onChange={e => setMemnuniyet(Number(e.target.value))}><option value={0}>—</option>{[1, 2, 3, 4, 5].map(n => <option key={n} value={n}>{'★'.repeat(n)}</option>)}</select></div>
                {sonuc === 2 && <div className="al g2"><span className="lb">Geri arama zamanı</span><input className="inp" type="datetime-local" value={geriArama} onChange={e => setGeriArama(e.target.value)} /></div>}
                {(sonuc === 3 || gorevKonu) && <div className="al g2"><span className="lb">Görev / şikayet konusu</span><input className="inp" value={gorevKonu} onChange={e => setGorevKonu(e.target.value)} placeholder="Görev açılacaksa konu" /></div>}
              </div>
              <div className="fm-doldur-arac">
                <button className="d bir" onClick={() => void kapat()}>💾 Kaydet &amp; Kapat</button>
                <button className="d" onClick={() => { setSonuc(2); setSekme('hizli') }}>↩ Geri arama</button>
                <button className="d" onClick={() => git(`/cagri/${secili.id}${geriP}`)}>📞 Kart</button>
              </div>
            </> : <div className="sonuk">Çağrı seçilmedi.</div>}
          </section>
          {secili && (arayan?.sonCagrilar[0]?.id === secili.id || secili.ilgili_sayisi > 0) && (
            <section className="fm-bolum"><h3 className="fm-bolum-bas">🔗 Bu çağrıda açılanlar</h3>
              <div className="sonuk">{secili.ilgili_sayisi} kayıt · ayrıntı çağrı kartında.</div>
            </section>
          )}
          {o && (o.bekleyenSonuc > 0 || o.bakiye > 0 || (arayan?.sonCagrilar.length ?? 0) >= 2) && (
            <section className="fm-bolum"><h3 className="fm-bolum-bas">🤖 Öneri</h3>
              <ul className="cg-oneri">
                {o.bekleyenSonuc > 0 && <li>Bekleyen tetkik sonucu var; hazır olunca "sonuç hazır" kampanyası bilgilendirir.</li>}
                {o.bakiye > 0 && <li>Bakiye {o.bakiye.toLocaleString('tr-TR')} ₺ — ödeme linki teklif edilebilir.</li>}
                {(arayan?.sonCagrilar.length ?? 0) >= 2 && <li>Son 5 çağrının {arayan!.sonCagrilar.filter(c => c.konu_adi === 'Randevu').length} tanesi randevu; tekrar arayan hasta.</li>}
              </ul>
            </section>
          )}
        </div>
      </div>
      <div className="fm-doldur-arac sonuk" style={{ fontSize: 11 }}>Kuyruk toplam {p.ozet.bekleyen} · bugün {p.ozet.gunCevaplanan} cevaplanan · SLA {p.ozet.gunCevaplanan ? Math.round(100 * p.ozet.gunSla / p.ozet.gunCevaplanan) : 0}% · 5 sn'de bir yenilenir</div>
    </div>
  );
}

function Al({ lb, v }: { lb: string; v: React.ReactNode }) {
  return <div className="al"><span className="lb">{lb}</span><span className="inp ro">{v}</span></div>;
}
