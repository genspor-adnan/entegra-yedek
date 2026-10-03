import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { ApiHatasi, hataMetni } from '../../api/sozlesme';
import type { SterilDonguKart as Kart, SterilEtiket } from '../../api/uclar/steril';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { Al, DurumRozeti, Etiket, SonucRozeti, zaman } from './ortak';
import { useEscIleKapat } from '../../bilesenler/Modal';

/**
 * DÖNGÜ KARTI `/steril-dongu/:id` (868) — mockup dis_steril_dongu_karti.html. Modal:
 * başlık (cihaz, sayaç, program, süre, durum), adım şeridi; sekmeler: yük içeriği
 * (paketler), indikatörler (BD / Helix / sınıf 5 / biyolojik; sonuç girişi), parametreler
 * (döngü bitti girişi + program eşiği), serbest bırakma (kontrol listesi + karar), etiket &
 * depo (serbest sonrası etiketler), günlük (olaylar).
 */
type Sekme = 'yuk' | 'ind' | 'param' | 'serbest' | 'etiket' | 'gunluk';
const IND_ADI: Record<number, string> = { 1: 'Bowie-Dick', 2: 'Helix / PCD', 3: 'Sınıf 4', 4: 'Sınıf 5 entegratör', 5: 'Sınıf 6', 6: 'Biyolojik', 7: 'Vakum testi' };

export function SterilDonguKarti() {
  const { id } = useParams(); const git = useNavigate(); const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const [k, setK] = useState<Kart | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('yuk');
  const [prm, setPrm] = useState({ tepeSicaklik: '', platoDk: '', tepeBasinc: '', kurutmaDk: '', hataKodu: '' });
  const [karar, setKarar] = useState<'serbest' | 'karantina' | 'basarisiz'>('serbest'); const [kararNotu, setKararNotu] = useState('');
  const [etiketler, setEtiketler] = useState<SterilEtiket[]>([]);
  const kapat = useCallback(() => git(sorgu.get('geri') ?? '/steril-dongu'), [git, sorgu]);
  const yukle = useCallback(async () => {
    try {
      const y = await api.sterilDongu(Number(id)); setK(y); setHata(null);
      const d = y.dongu; setPrm({ tepeSicaklik: d.tepe_sicaklik?.toString() ?? '', platoDk: d.plato_dk?.toString() ?? '', tepeBasinc: d.tepe_basinc?.toString() ?? '', kurutmaDk: d.kurutma_dk?.toString() ?? '', hataKodu: d.hata_kodu ?? '' });
      if (d.durum === 2) setSekme('param'); else if (d.durum === 3 || d.durum === 8) setSekme('ind');
    } catch (h) { setHata(hataMetni(h)) }
  }, [id]);
  useEffect(() => { if (id) void yukle() }, [id, yukle]);
  // Esc yalniz EN USTTEKI pencereyi kapatir (kartin icinde acik pencere varsa o).
  useEscIleKapat(kapat);
  const duzenle = yetki('steril.dongu', 'degistir');

  const bitir = async () => {
    await guvenli(async () => { await api.sterilDonguBitir(Number(id), { tepeSicaklik: prm.tepeSicaklik === '' ? null : Number(prm.tepeSicaklik), platoDk: prm.platoDk === '' ? null : Number(prm.platoDk), tepeBasinc: prm.tepeBasinc === '' ? null : Number(prm.tepeBasinc), kurutmaDk: prm.kurutmaDk === '' ? null : Number(prm.kurutmaDk), hataKodu: prm.hataKodu }); mesaj('Döngü bitti; indikatör sonuçlarını girip serbest bırakın.'); await yukle(); setSekme('ind') });
  };
  const indikator = async (tur: number, sonuc: number) => {
    const mevcut = k?.indikatorler.find(i => i.tur === tur);
    const lot = mevcut?.lot || (await metinSor(`${IND_ADI[tur]} lot no`, '', 'Lot')); if (lot === null) return;
    await guvenli(async () => { const y = await api.sterilIndikator(Number(id), { tur, lot, sonuc }); mesaj(y.mesaj); await yukle(); if (y.geriCagirmaId) git(`/steril-izleme?geriCagirma=${y.geriCagirmaId}`) });
  };
  const indikatorEkle = async () => {
    const t = await metinSor('İndikatör türü: 1 Bowie-Dick · 2 Helix · 3 Sınıf 4 · 4 Sınıf 5 · 5 Sınıf 6 · 6 Biyolojik · 7 Vakum', '6', 'Tür'); if (t === null) return;
    const lot = await metinSor('Lot no', '', 'Lot'); if (lot === null) return;
    await guvenli(async () => { await api.sterilIndikator(Number(id), { tur: Number(t), lot, sonuc: Number(t) === 6 ? 3 : 0 }); await yukle() });
  };
  const serbest = async () => {
    const dene = async (bdOnayNotu?: string) => api.sterilSerbest(Number(id), { karar, notu: kararNotu, bdOnayNotu });
    await guvenli(async () => {
      let y;
      try { y = await dene() }
      catch (h) {
        if (h instanceof ApiHatasi && (h.hata.engel as { kod?: string } | undefined)?.kod === 'SERBEST_EKSIK' && (h.hata.engel as { eksik?: string[] }).eksik?.some(e => e.includes('Bowie-Dick'))) {
          const n = await metinSor(`${h.message}\n\nGünün Bowie-Dick sonucu yok. Sorumlu onay notu ile devam:`, '', 'Onay notu'); if (n === null || !n.trim()) return;
          y = await dene(n.trim());
        } else throw h;
      }
      mesaj(y.mesaj); setEtiketler(y.etiketler ?? []); await yukle(); if (y.etiketler?.length) setSekme('etiket');
    });
  };
  const iptal = async () => { if (!await onay('Döngü iptal edilsin mi? Paketler hazırlığa döner.')) return; await guvenli(async () => { await api.sterilDonguIptal(Number(id), 'Ekrandan iptal'); await yukle() }) };

  if (hata && !k) return <div className="kaperde" onClick={kapat}><div className="kawin tam" onClick={e => e.stopPropagation()}><div className="kabas">Döngü<button className="kabas-dugme" onClick={kapat}>✖</button></div><div className="kagov"><div className="hata-kutusu">{hata}</div></div></div></div>;
  if (!k) return null;
  const d = k.dongu;
  const adimlar = [{ ad: 'Yükleme', ok: true }, { ad: 'Program', ok: true }, { ad: 'Döngü', ok: d.durum !== 2, on: d.durum === 2 }, { ad: 'İndikatörler', ok: [4, 5, 6].includes(d.durum), on: d.durum === 3 || d.durum === 8 }, { ad: 'Serbest bırakma', ok: [4, 5, 6].includes(d.durum), on: false }, { ad: 'Etiket & depo', ok: d.durum === 4, on: false }];
  const bd = k.indikatorler.find(i => i.tur === 1), helix = k.indikatorler.find(i => i.tur === 2), s5 = k.indikatorler.find(i => i.tur === 4 || i.tur === 5), bio = k.indikatorler.find(i => i.tur === 6), vakum = k.indikatorler.find(i => i.tur === 7);
  const bugunBd = d.bd_sonuc === 1;
  const kontrol = [
    { ad: 'Döngü bitti, cihaz hata kodu yok', ok: d.durum !== 2 && !d.hata_kodu, kir: !!d.hata_kodu },
    { ad: `Plato ≥ ${d.hedef_sicaklik ?? '?'}°C · ≥ ${d.hedef_plato_dk ?? '?'} dk (ölçülen ${d.tepe_sicaklik ?? '—'}°C · ${d.plato_dk ?? '—'} dk)`, ok: d.tepe_sicaklik !== null && d.tepe_sicaklik !== undefined && d.plato_dk !== null && d.plato_dk !== undefined && (d.hedef_sicaklik === null || d.hedef_sicaklik === undefined || d.tepe_sicaklik >= d.hedef_sicaklik) && (d.hedef_plato_dk === null || d.hedef_plato_dk === undefined || d.plato_dk >= d.hedef_plato_dk), kir: d.tepe_sicaklik !== null && d.tepe_sicaklik !== undefined && d.hedef_sicaklik !== null && d.hedef_sicaklik !== undefined && d.tepe_sicaklik < d.hedef_sicaklik },
    { ad: 'Sınıf 5/6 entegratör kabul bölgesinde', ok: s5?.sonuc === 1, kir: s5?.sonuc === 2 },
    { ad: 'Günün Bowie-Dick sonucu kayıtlı (ya da onay notu)', ok: bugunBd || !!d.bd_onay_notu, kir: false },
    { ad: d.implant_var ? 'İmplant yükü: biyolojik indikatör eklendi' : 'Yükte implant kiti yok → biyolojik gerekmiyor', ok: d.implant_var ? !!bio : true, kir: !!d.implant_var && !bio },
    { ad: 'Paketler kuru, bütün, şeritler dönmüş (gözle kontrol)', ok: false, kir: false },
  ];
  return (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">♨️ Döngü #{d.sayac_no} · {d.cihaz_adi} · {d.program_adi} <DurumRozeti durum={d.durum} ad={d.durum_adi} /><button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button></div>
        <div className="kagov fm-kagov">
          <div className="st-adim">{adimlar.map((a, i) => <span key={i} className={a.on ? 'on' : a.ok ? 'ok' : ''}>{i + 1} · {a.ad}</span>)}</div>
          <div className="isg-frm">
            <Al lb="Cihaz" v={d.cihaz_adi} /><Al lb="Sayaç no" v={d.sayac_no} /><Al lb="Program" v={`${d.program_adi}${d.hedef_sicaklik ? ` · ${d.hedef_sicaklik}°C / ${d.hedef_plato_dk} dk` : ''}`} /><Al lb="Başlangıç" v={zaman(d.baslama)} />
            <Al lb="Bitiş" v={d.bitis ? zaman(d.bitis) : `çalışıyor · ${d.sure_dk} dk`} /><Al lb="Operatör" v={d.operator_adi || '—'} /><Al lb="Onay" v={d.onaylayan_adi ? `${d.onaylayan_adi} · ${zaman(d.onay_zamani)}` : '—'} /><Al lb="Yük" v={d.test_programi ? 'Test (boş kazan)' : `${d.paket_sayisi} paket`} />
          </div>
          {d.bd_onay_notu && <div className="uyari-kutusu" style={{ margin: '8px 0' }}>⚠ Bowie-Dick kayıtlı değilken sorumlu onayıyla açıldı: "{d.bd_onay_notu}"</div>}
          <div className="fm-doldur-arac">
            {duzenle && d.durum === 2 && <button className="d bir" onClick={() => setSekme('param')}>⏹ Döngü bitti (parametre gir)</button>}
            {duzenle && (d.durum === 3 || d.durum === 5) && <button className="d bir" onClick={() => setSekme('serbest')}>✅ Serbest bırak</button>}
            {duzenle && [2, 3, 8].includes(d.durum) && <button className="d" onClick={() => void iptal()}>⛔ İptal</button>}
            <button className="d" onClick={() => git(`/steril-izleme?donguId=${d.id}`)}>🔍 İzle</button>
            <span className="sp" /><span className="sonuk">Kural: parametre ✓ + Bowie-Dick/Helix (gün) ✓ + sınıf 5 ✓ → serbest; biri kaldı → başarısız; biyolojik bekliyor → karantina.</span>
          </div>
          <div className="ka-sekmeler">
            {(['yuk', 'ind', 'param', 'serbest', 'etiket', 'gunluk'] as Sekme[]).map(s => <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{{ yuk: `Yük içeriği (${k.paketler.length})`, ind: 'İndikatörler', param: 'Parametreler', serbest: 'Serbest bırakma', etiket: `Etiket & depo${etiketler.length ? ` (${etiketler.length})` : ''}`, gunluk: `Günlük (${k.olaylar.length})` }[s]}</div>)}
          </div>
          {sekme === 'yuk' && (
            <table className="fm-tablo"><thead><tr><th>#</th><th>Paket barkodu</th><th>İçerik</th><th>Paket türü</th><th>Paketleyen</th><th>Raf</th><th>SKT</th><th>Durum</th></tr></thead>
              <tbody>{k.paketler.map((p, i) => <tr key={p.id} className="tik" onDoubleClick={() => git(`/steril-izleme?barkod=${encodeURIComponent(p.barkod)}`)}><td>{i + 1}</td><td>{p.barkod}</td><td>{p.birim_adi}{p.implant ? <span className="st-rz sari" style={{ marginLeft: 6 }}>implant</span> : null}</td><td>{p.paket_tur_adi}</td><td>{p.paketleyen_adi} · {zaman(p.paketleme_zamani)}</td><td>{p.raf}</td><td>{p.skt ? new Date(p.skt).toLocaleDateString('tr-TR') : '—'}</td><td>{p.durum_adi}</td></tr>)}
                {!k.paketler.length && <tr><td colSpan={8} className="sonuk">{d.test_programi ? 'Test döngüsü: boş kazan + test paketi.' : 'Paket yok.'}</td></tr>}</tbody></table>
          )}
          {sekme === 'ind' && (
            <>
              <div className="st-ind">
                {[{ t: 1, i: bd, k: 'günlük · boş kazan' }, { t: 2, i: helix, k: 'günlük · içi boş aletler' }, { t: 4, i: s5, k: 'her döngü · kazan ortası' }, { t: 6, i: bio, k: 'haftalık · implantta her döngü' }, ...(vakum ? [{ t: 7, i: vakum, k: 'günlük · sızdırmazlık' }] : [])].map(x => (
                  <div key={x.t} className={`i ${x.i?.sonuc === 1 ? 'ok' : x.i?.sonuc === 2 ? 'kir' : x.i ? 'bek' : ''}`}>
                    <b>{IND_ADI[x.t]}</b><div className="sonuk">{x.k}{x.i?.lot ? ` · lot ${x.i.lot}` : ''}</div>
                    <div className="son">{x.i ? <SonucRozeti s={x.i.sonuc} /> : <span className="sonuk">bu döngüde yok</span>}</div>
                    {x.i?.inkubasyonBitis && x.i.sonuc === 3 && <div className="sonuk">okuma: {zaman(x.i.inkubasyonBitis)}</div>}
                    {x.i?.okuyanAdi && <div className="sonuk">{x.i.okuyanAdi} · {zaman(x.i.okumaZamani)}</div>}
                    {duzenle && x.i && x.i.sonuc !== 1 && x.i.sonuc !== 2 && <div style={{ display: 'flex', gap: 4, marginTop: 4 }}><button className="d mini ok" onClick={() => void indikator(x.t, 1)}>Geçti</button><button className="d mini kir" onClick={() => void indikator(x.t, 2)}>Kaldı</button></div>}
                    {duzenle && !x.i && x.t !== 1 && x.t !== 2 && <button className="d mini" style={{ marginTop: 4 }} onClick={() => void indikatorEkle()}>＋ Ekle</button>}
                  </div>))}
              </div>
              <div className="fm-doldur-arac">{duzenle && <button className="d" onClick={() => void indikatorEkle()}>＋ İndikatör ekle (biyolojik / sınıf 6 / vakum)</button>}<span className="sonuk">Biyolojik: 24 s inkübasyon; negatif → karantina kalkar; pozitif → geri çağırma otomatik açılır.</span></div>
              <table className="fm-tablo"><thead><tr><th>Tür</th><th>Lot</th><th>Konum</th><th>Sonuç</th><th>Okuyan</th><th>Zaman</th><th>Not</th></tr></thead>
                <tbody>{k.indikatorler.map(i => <tr key={i.id}><td>{i.turAdi}</td><td>{i.lot || '—'}</td><td>{i.konum}</td><td><SonucRozeti s={i.sonuc} /></td><td>{i.okuyanAdi || '—'}</td><td>{zaman(i.okumaZamani)}</td><td>{i.notu}</td></tr>)}</tbody></table>
            </>
          )}
          {sekme === 'param' && (
            <>
              <div className="isg-frm">
                {(['tepeSicaklik', 'platoDk', 'tepeBasinc', 'kurutmaDk'] as const).map(kk => <div key={kk} className="al"><span className="lb">{{ tepeSicaklik: 'Tepe sıcaklık (°C)', platoDk: 'Plato süresi (dk)', tepeBasinc: 'Tepe basınç (bar)', kurutmaDk: 'Kurutma (dk)' }[kk]}</span><input className="inp" type="number" step="0.1" value={prm[kk]} onChange={e => setPrm(x => ({ ...x, [kk]: e.target.value }))} disabled={!duzenle || d.durum !== 2} /></div>)}
                <div className="al"><span className="lb">Cihaz hata kodu</span><input className="inp" value={prm.hataKodu} onChange={e => setPrm(x => ({ ...x, hataKodu: e.target.value }))} disabled={!duzenle || d.durum !== 2} /></div>
                <Al lb="Program eşiği" v={d.hedef_sicaklik ? `${d.hedef_sicaklik}°C · ${d.hedef_plato_dk} dk plato` : '—'} />
                <Al lb="Kaynak" v="Elle giriş (cihaz veri bağlantısı bağlanınca otomatik)" g2 />
              </div>
              {duzenle && d.durum === 2 && <div className="fm-doldur-arac"><button className="d bir" onClick={() => void bitir()}>⏹ Döngü bitti — parametreleri kaydet</button><span className="sonuk">Kaydedince döngü "indikatör bekliyor" olur.</span></div>}
            </>
          )}
          {sekme === 'serbest' && (
            <>
              <ul className="st-chk">{kontrol.map((c, i) => <li key={i}><span className={`k ${c.ok ? 'ok' : c.kir ? 'no' : ''}`}>{c.ok ? '✓' : c.kir ? '!' : '·'}</span>{c.ad}</li>)}</ul>
              <div className="isg-frm">
                <div className="al"><span className="lb">Karar</span><select className="inp" value={karar} onChange={e => setKarar(e.target.value as typeof karar)} disabled={!duzenle}><option value="serbest">✅ Serbest</option><option value="karantina">⏸ Karantina (biyolojik bekleniyor)</option><option value="basarisiz">⛔ Başarısız — paketleri yeniden işle</option></select></div>
                <div className="al g2"><span className="lb">Not / gerekçe</span><input className="inp" value={kararNotu} onChange={e => setKararNotu(e.target.value)} disabled={!duzenle} /></div>
                <Al lb="Serbest bırakan" v={d.onaylayan_adi || '(kaydedince siz)'} />
              </div>
              {duzenle && (d.durum === 3 || d.durum === 5) ? <div className="fm-doldur-arac"><button className="d bir" onClick={() => void serbest()}>{karar === 'serbest' ? '✅ Serbest bırak ve etiketleri hazırla' : karar === 'karantina' ? '⏸ Karantinaya al' : '⛔ Başarısız'}</button><span className="sonuk">Onay ISLEMLOG'a yazılır; kayıt defteri satırı oluşur. Etiket onaysız basılmaz.</span></div>
                : <div className="sonuk" style={{ padding: 6 }}>{d.durum === 2 ? 'Önce döngüyü bitirin (Parametreler).' : `Döngü sonuçlandı: ${d.durum_adi}${d.karar_notu ? ` · ${d.karar_notu}` : ''}`}</div>}
            </>
          )}
          {sekme === 'etiket' && (
            <>
              <div className="fm-doldur-arac"><button className="d" onClick={() => window.print()} disabled={!etiketler.length && d.durum !== 4}>🖨 Etiketleri yazdır</button><span className="sonuk">Etiket yazıcı: {k.kurallar.etiketYazici || 'tanımsız (Ayarlar › Kurallar)'} · 50×30 mm · Code128</span></div>
              <div className="st-etkler">{(etiketler.length ? etiketler : k.paketler.filter(p => p.durum === 3).map(p => ({ paketId: p.id, barkod: p.barkod, icerik: p.birim_adi, cihaz: d.cihaz_adi, donguNo: d.sayac_no, tarih: d.bitis ?? d.baslama, skt: p.skt, operatorAdi: d.onaylayan_adi, raf: p.raf }))).map(e => <Etiket key={e.paketId} e={e} />)}
                {!etiketler.length && !k.paketler.some(p => p.durum === 3) && <div className="sonuk">Etiketler serbest bırakma onayından sonra oluşur.</div>}</div>
            </>
          )}
          {sekme === 'gunluk' && (
            <table className="fm-tablo"><thead><tr><th>Zaman</th><th>Kim</th><th>Olay</th><th>Açıklama</th></tr></thead>
              <tbody>{k.olaylar.map(o => <tr key={o.id}><td>{zaman(o.zaman)}</td><td>{o.kullaniciAdi || 'sistem'}</td><td>{o.turAdi}</td><td>{o.aciklama}</td></tr>)}</tbody></table>
          )}
        </div>
      </div>
    </div>
  );
}
