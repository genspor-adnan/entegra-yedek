import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { SterilAyar, SterilKurallar } from '../../api/uclar/steril';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import { Al, SonucRozeti, tarih } from './ortak';

/**
 * TEST TAKVİMİ · KURALLAR `/steril-ayar` (868) — mockup dis_steril_cihaz_ayarlar.html.
 * Sekmeler: cihazlar (kartlara bağlantı), programlar, test takvimi (son 14 gün: Bowie-Dick /
 * Helix / biyolojik / döngü; cihaz başına uyum), bakım takvimi, kurallar (Bowie-Dick,
 * karantina, seans okutma, raf ömrü, yağlama, eşikler), yetkiler & entegrasyon.
 */
type Sekme = 'cihaz' | 'program' | 'test' | 'bakim' | 'kural' | 'yetki';

export function SterilAyarlar() {
  const git = useNavigate(); const { yetki } = useOturum();
  const [y, setY] = useState<SterilAyar | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('test');
  const [k, setK] = useState<SterilKurallar | null>(null);
  const yukle = useCallback(async () => { try { const a = await api.sterilAyar(); setY(a); setK(a.kurallar); setHata(null) } catch (h) { setHata(hataMetni(h)) } }, []);
  useEffect(() => { void yukle() }, [yukle]);
  const duzenle = yetki('steril.ayar', 'degistir');
  const kaydet = async () => { if (!k) return; await guvenli(async () => { await api.sterilKurallarKaydet(k); mesaj('Kurallar kaydedildi.'); await yukle() }) };

  if (hata && !y) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!y || !k) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;
  const g = (ad: keyof SterilKurallar, v: string | number) => setK(x => x ? { ...x, [ad]: v } : x);
  const raf = (t: string, v: number) => setK(x => x ? { ...x, rafOmru: { ...x.rafOmru, [t]: v } } : x);
  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>📅 Sterilizasyon — Test Takvimi · Kurallar</h1><span className="yol">Sterilizasyon › Ayarlar</span>
        <div className="sag">{duzenle && sekme === 'kural' && <button className="d bir" onClick={() => void kaydet()}>💾 Kuralları kaydet</button>}<button className="d" onClick={() => git('/steril-pano')}>🧪 Pano</button></div></div></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="ka-sekmeler" style={{ padding: '0 20px 8px' }}>
        {(['cihaz', 'program', 'test', 'bakim', 'kural', 'yetki'] as Sekme[]).map(s => <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{{ cihaz: `⚙️ Cihazlar (${y.cihazlar.length})`, program: `🌡 Programlar (${y.programlar.length})`, test: '📅 Test takvimi', bakim: '🔧 Bakım · validasyon', kural: '📏 Kurallar', yetki: '🔐 Yetkiler & entegrasyon' }[s]}</div>)}
      </div>
      {sekme === 'cihaz' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="fm-doldur-arac">{duzenle && <button className="d" onClick={() => git('/steril-cihaz/yeni?geri=%2Fsteril-ayar')}>＋ Cihaz</button>}<button className="d" onClick={() => git('/steril-cihaz')}>Liste</button></div>
          <table className="fm-tablo"><thead><tr><th>Cihaz</th><th>Tür</th><th>Marka / model</th><th>Seri no</th><th>Sınıf / kapasite</th><th>Sayaç</th><th>Veri</th><th>Son bakım</th><th>Sonraki bakım</th><th>Validasyon</th><th>Durum</th></tr></thead>
            <tbody>{y.cihazlar.map(c => <tr key={c.id} className="tik" onDoubleClick={() => git(`/steril-cihaz/${c.id}?geri=%2Fsteril-ayar`)}><td><b>{c.ad}</b></td><td>{c.tur_adi}</td><td>{c.marka_model}</td><td>{c.seri_no}</td><td>{c.sinif_adi ? `${c.sinif_adi} · ` : ''}{c.kapasite}</td><td>{c.sayac}</td><td>{c.veri_baglanti || 'elle'}</td><td>{tarih(c.son_bakim)}</td><td className={c.sonraki_bakim && new Date(c.sonraki_bakim) < new Date() ? 'st-kir' : ''}>{tarih(c.sonraki_bakim)}</td><td>{tarih(c.son_validasyon)} → {tarih(c.sonraki_validasyon)}</td><td><span className={`st-rz ${c.durum === 1 ? 'ok' : c.durum === 2 ? 'kir' : ''}`}>{c.durum_adi}</span></td></tr>)}</tbody></table>
        </section>
      )}
      {sekme === 'program' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="fm-doldur-arac">{duzenle && <button className="d" onClick={() => git('/steril-program/yeni?geri=%2Fsteril-ayar')}>＋ Program</button>}<span className="sonuk">Program parametreleri kabul eşiğidir: döngü plato sıcaklık / süresi eşiğin altındaysa serbest bırakılamaz.</span></div>
          <table className="fm-tablo"><thead><tr><th>Program</th><th>Cihaz</th><th>°C</th><th>Plato (dk)</th><th>Kurutma (dk)</th><th>Uygun yük</th><th>Test</th><th>Varsayılan</th><th>Durum</th></tr></thead>
            <tbody>{y.programlar.map(p => <tr key={p.id} className="tik" onDoubleClick={() => git(`/steril-program/${p.id}?geri=%2Fsteril-ayar`)}><td><b>{p.ad}</b></td><td>{p.cihaz_adi}</td><td>{p.sicaklik}</td><td>{p.plato_dk}</td><td>{p.kurutma_dk}</td><td>{p.uygun_yuk}</td><td>{p.test ? '✓' : ''}</td><td>{p.varsayilan ? '✓' : ''}</td><td>{p.aktif_adi}</td></tr>)}</tbody></table>
        </section>
      )}
      {sekme === 'test' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="st-takvim">{y.takvim.map(t => { const bugun = t.gun.slice(0, 10) === new Date().toISOString().slice(0, 10); return (
            <div key={t.gun} className={`g${bugun ? ' bugun' : ''}`}><span className="gn">{new Date(t.gun).toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit' })}</span>
              {t.dongu > 0 && <span className="t pl">{t.dongu} döngü</span>}
              {t.bd > 0 && <span className="t ok">BD ✓ ×{t.bd}</span>}{t.bdKaldi > 0 && <span className="t kir">BD kaldı</span>}
              {t.dongu > 0 && t.bd === 0 && <span className="t kir">BD yok</span>}
              {t.helix > 0 && <span className="t ok">Helix ✓</span>}{t.bio > 0 && <span className="t ok">Bio ✓</span>}{t.bioBekleyen > 0 && <span className="t bek">Bio inkübasyon</span>}
            </div>) })}</div>
          <table className="fm-tablo"><thead><tr><th>Cihaz</th><th>Bowie-Dick bugün</th><th>Helix bugün</th><th>Vakum bugün</th><th>Son 7 gün BD uyumu</th><th>Son biyolojik</th><th>Bio bekleyen</th><th>Sonraki bakım</th><th>Sonraki validasyon</th></tr></thead>
            <tbody>{y.testler.map(t => { const bioGun = t.sonBio ? Math.floor((Date.now() - new Date(t.sonBio).getTime()) / 86400000) : null; return (
              <tr key={t.cihazId}><td><b>{t.cihazAdi}</b></td><td>{t.bdBugun ? <span className="st-rz ok">geçti</span> : <span className="st-rz kir">yok</span>}</td><td>{t.helixBugun ? <span className="st-rz ok">geçti</span> : <span className="st-rz sari">yok</span>}</td><td>{t.vakumBugun ? <span className="st-rz ok">geçti</span> : <span className="sonuk">—</span>}</td>
                <td>{t.son7gunDonguGun ? `${t.son7gunBd} / ${t.son7gunDonguGun} gün` : '—'}</td><td>{t.sonBio ? <>{tarih(t.sonBio)} <SonucRozeti s={t.sonBioSonuc} /> <span className={bioGun !== null && bioGun >= k.bioGecikmeUyariGun ? 'st-kir' : 'sonuk'}>({bioGun} gün)</span></> : <span className="st-kir">hiç yapılmadı</span>}</td><td>{t.bioBekleyen || '—'}</td><td>{tarih(t.sonrakiBakim)}</td><td>{tarih(t.sonrakiValidasyon)}</td></tr>) })}</tbody></table>
          <div className="sonuk" style={{ fontSize: 11, marginTop: 6 }}>Kural: Bowie-Dick her gün ilk döngü (boş kazan); Helix her gün; biyolojik her {k.bioSiklikGun} günde bir (implant yükünde her döngü); uyarı {k.bioGecikmeUyariGun} gün, engel {k.bioGecikmeEngelGun} gün.</div>
        </section>
      )}
      {sekme === 'bakim' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="fm-doldur-arac">{duzenle && <button className="d" onClick={() => git('/steril-bakim/yeni?geri=%2Fsteril-ayar')}>＋ Bakım / kalibrasyon / validasyon kaydı</button>}<button className="d" onClick={() => git('/steril-bakim')}>Liste</button></div>
          <table className="fm-tablo"><thead><tr><th>Tarih</th><th>Cihaz</th><th>İşlem</th><th>Yapan</th><th>Sonuç</th><th>Sonraki</th><th>Kalan gün</th><th>Belge</th></tr></thead>
            <tbody>{y.bakimlar.map(m => <tr key={m.id} className="tik" onDoubleClick={() => git(`/steril-bakim/${m.id}?geri=%2Fsteril-ayar`)}><td>{tarih(m.tarih)}</td><td>{m.cihaz_adi}</td><td>{m.tur_adi}</td><td>{m.yapan}</td><td>{m.sonuc}</td><td>{tarih(m.sonraki_tarih)}</td><td className={m.kalan_gun !== null && m.kalan_gun !== undefined && m.kalan_gun < 0 ? 'st-kir' : ''}>{m.kalan_gun ?? '—'}</td><td>{m.belge_no}</td></tr>)}
              {!y.bakimlar.length && <tr><td colSpan={8} className="sonuk">Bakım kaydı yok. Cihaz kartındaki "Son bakım / validasyon" tarihleri takvimi besler.</td></tr>}</tbody></table>
        </section>
      )}
      {sekme === 'kural' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <div className="isg-frm">
            <div className="al g2"><span className="lb">Bowie-Dick yapılmadan döngü</span><select className="inp" value={k.bdKurali} onChange={e => g('bdKurali', e.target.value)} disabled={!duzenle}><option value="uyari">Uyarı (serbest)</option><option value="onay">Uyarı + sorumlu onay notu (engel değil)</option><option value="engel">Engel</option></select></div>
            <div className="al g2"><span className="lb">Karantina paketleri (biyolojik bekliyor)</span><select className="inp" value={k.karantinaKullanim} onChange={e => g('karantinaKullanim', e.target.value)} disabled={!duzenle}><option value="uyari">Uyarılı kullanılabilir (implant kiti hariç)</option><option value="engel">Kullanılamaz</option></select></div>
            <div className="al"><span className="lb">Biyolojik gecikme uyarı (gün)</span><input className="inp" type="number" value={k.bioGecikmeUyariGun} onChange={e => g('bioGecikmeUyariGun', Number(e.target.value))} disabled={!duzenle} /></div>
            <div className="al"><span className="lb">Biyolojik gecikme engel (gün)</span><input className="inp" type="number" value={k.bioGecikmeEngelGun} onChange={e => g('bioGecikmeEngelGun', Number(e.target.value))} disabled={!duzenle} /></div>
            <div className="al"><span className="lb">Biyolojik sıklığı (gün)</span><input className="inp" type="number" value={k.bioSiklikGun} onChange={e => g('bioSiklikGun', Number(e.target.value))} disabled={!duzenle} /></div>
            <div className="al"><span className="lb">SKT uyarısı (gün önce)</span><input className="inp" type="number" value={k.sktUyariGun} onChange={e => g('sktUyariGun', Number(e.target.value))} disabled={!duzenle} /></div>
            <div className="al"><span className="lb">Döner alet yağlama</span><select className="inp" value={k.yaglamaZorunlu} onChange={e => g('yaglamaZorunlu', Number(e.target.value))} disabled={!duzenle}><option value={1}>Yağlanmadan yüklemeye izin verme</option><option value={0}>Uyarı yok</option></select></div>
            <div className="al"><span className="lb">Set döngü eşiği (gözden geçir)</span><input className="inp" type="number" value={k.donguEsigi} onChange={e => g('donguEsigi', Number(e.target.value))} disabled={!duzenle} /></div>
            <div className="al"><span className="lb">Seansta paket okutulmazsa</span><select className="inp" value={k.seansOkutma} onChange={e => g('seansOkutma', e.target.value)} disabled={!duzenle}><option value="uyari">Uyarı (kapatmaya izin ver)</option><option value="serbest">Sormadan geç</option><option value="engel">Engel</option></select></div>
            <div className="al"><span className="lb">Etiket yazıcı</span><input className="inp" value={k.etiketYazici} onChange={e => g('etiketYazici', e.target.value)} placeholder="Zebra ZD421 · 50×30" disabled={!duzenle} /></div>
            <div className="al g4"><span className="lb">Raf ömrü (ay) — paket türüne göre; 0 = olay bazlı (SKT basılmaz). Set tanımındaki raf ömrü öncelikli.</span>
              <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>{[['1', 'Kağıt-plastik'], ['2', 'Kağıt-plastik çift kat'], ['3', 'Tekstil çift kat'], ['4', 'Konteyner'], ['5', 'Paketsiz']].map(([t, ad]) => <label key={t} style={{ fontSize: 11 }}>{ad} <input className="inp" type="number" style={{ width: 60 }} value={k.rafOmru[t] ?? 0} onChange={e => raf(t, Number(e.target.value))} disabled={!duzenle} /></label>)}</div></div>
          </div>
          {duzenle && <div className="fm-doldur-arac"><button className="d bir" onClick={() => void kaydet()}>💾 Kuralları kaydet</button><span className="sonuk">Kurallar "uyarı / onaylı uyarı / engel" olarak seçilir; küçük klinik ile ADSM'nin katılığı farklıdır.</span></div>}
        </section>
      )}
      {sekme === 'yetki' && (
        <section className="fm-bolum" style={{ margin: '0 20px' }}>
          <table className="fm-tablo"><thead><tr><th>Rol</th><th>Döngü aç / indikatör</th><th>Serbest bırak</th><th>Paket okut (seans)</th><th>Geri çağırma</th><th>Cihaz / ayar</th></tr></thead>
            <tbody>
              <tr><td>Sterilizasyon Sorumlusu (steril_sorumlu)</td><td>✓</td><td>✓</td><td>✓</td><td>✓ başlatır / kapatır</td><td>gör + değiştir</td></tr>
              <tr><td>Diş asistanı / hemşire</td><td>yükleme, paketleme (steril.birim)</td><td>—</td><td>✓ (steril.kullanim)</td><td>—</td><td>—</td></tr>
              <tr><td>Diş hekimi</td><td>—</td><td>—</td><td>✓</td><td>değerlendirme</td><td>—</td></tr>
              <tr><td>Kalite sorumlusu</td><td>—</td><td>—</td><td>—</td><td>DÖF · kapanış (steril.izleme)</td><td>—</td></tr>
              <tr><td>Yönetici</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td><td>✓</td></tr>
            </tbody></table>
          <div className="isg-frm" style={{ marginTop: 8 }}>
            <Al lb="Yetki kodları" v="steril · steril.pano · steril.dongu · steril.birim · steril.kullanim · steril.izleme · steril.ayar" g2 />
            <Al lb="Roller" v="Kurum Profili › Roller › Sterilizasyon Sorumlusu (standart şablon); diğer rollere yetkiler rol kartından eklenir" g2 />
            <Al lb="Otoklav veri kaydı (USB / RS-232 / Ethernet)" v="Sürücü yok: parametreler döngü kartından elle; Melag / W&H / Euronda sürücüleri sonraki adım" g2 />
            <Al lb="Etiket yazıcı (ZPL)" v="Tarayıcı yazdırma (50×30 mm önizleme); ZPL sürücüsü sonraki adım" g2 />
            <Al lb="Barkod okuyucu" v="Klavye modu: pano barkod kutusu (paket → kullanım, birim → kirli)" g2 />
            <Al lb="Diş seans kaydı" v="Seans ekranından paket okutma ve 'okutulmadı' kuralı sonraki adım (bu ekranın kuralı hazır)" g2 />
          </div>
        </section>
      )}
    </div>
  );
}
