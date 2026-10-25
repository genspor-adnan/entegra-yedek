import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { KritikSatiri, KritikStokIcmali as Veri } from '../../api/uclar/stokIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { kisaTl, Kutu, Kutucuk, sayi, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useStokKarti, useSuzgec } from './stokIcmalOrtak';

/**
 * KRİTİK STOK İCMALİ `/stok-kritik-stok-icmali` (1174) - mockup Ekranlar/Stok/stok_kritik_stok_icmali.html.
 * "Neyi bugün sipariş etmeliyim, ne kadar? Hangisi yolda, hangisi başka depoda var?" Eşik ve hedef
 * kuralı otomatik kritik stok talebiyle (732) aynı; rakamlar sunucuda.
 */
type Sekme = 'krt' | 'tuk' | 'oneri' | 'fazla';
type Suzme = 'kritik' | 'tukeniyor' | 'tumu';
const anahtar = (x: { stokId: number; depoId: number }) => `${x.stokId}:${x.depoId}`;

export function StokKritikStokIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const kartAc = useStokKarti();
  const depo = Number(arama.get('depo') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const gun = Number(arama.get('gun') ?? 90);
  const tedarik = Number(arama.get('tedarik') ?? 7);
  const suzme = (arama.get('goster') ?? 'tumu') as Suzme;
  const tip = Number(arama.get('tip') ?? 0);
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [tazele, setTazele] = useState(0);
  const [sekme, setSekme] = useState<Sekme>('krt');
  const [ara, setAra] = useState('');
  const [secili, setSecili] = useState<Set<string>>(new Set());
  const [miktar, setMiktar] = useState<Record<string, number>>({});
  const [oneriSecili, setOneriSecili] = useState<Set<string>>(new Set());
  const [oneriDeger, setOneriDeger] = useState<Record<string, { min: number; max: number }>>({});
  const [isliyor, setIsliyor] = useState(false);
  const [ilkYonlendirme, setIlkYonlendirme] = useState(false);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ gun: String(gun), tedarik: String(tedarik) });
    if (depo) q.set('depo', String(depo));
    if (kategori) q.set('kategori', String(kategori));
    if (tip) q.set('tip', String(tip));
    api.kritikStokIcmali(q).then(v => {
      setVeri(v);
      setSecili(new Set(v.kritikler.filter(x => x.siparis > 0 && !x.talep && !x.siparisNo).map(anahtar)));
      setMiktar({}); setOneriSecili(new Set()); setOneriDeger({});
    }).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [depo, kategori, gun, tedarik, tip, tazele]);

  // MİN HİÇ TANIMLI DEĞİLSE (ilk açılış) liste boş görünmesin: öneri sekmesine yönlendir.
  useEffect(() => {
    if (veri && !ilkYonlendirme) {
      setIlkYonlendirme(true);
      if (veri.ozet.satir > 0 && veri.ozet.minTanimsiz === veri.ozet.satir && veri.oneriler.length > 0) setSekme('oneri');
    }
  }, [veri, ilkYonlendirme]);

  const q = ara.trim().toLocaleLowerCase('tr');
  const uyar = (kod: string, ad: string) => !q || kod.toLocaleLowerCase('tr').includes(q) || ad.toLocaleLowerCase('tr').includes(q);
  const kritikler = useMemo(() => (veri?.kritikler ?? []).filter(x => uyar(x.kod, x.ad)
    && (suzme === 'tumu' || (suzme === 'kritik' ? x.kritik || x.yok : x.tukeniyor))), [veri, ara, suzme]); // eslint-disable-line react-hooks/exhaustive-deps
  const oneriler = useMemo(() => (veri?.oneriler ?? []).filter(x => uyar(x.kod, x.ad)), [veri, ara]); // eslint-disable-line react-hooks/exhaustive-deps
  const o = veri?.ozet;
  const mk = (x: KritikSatiri) => miktar[anahtar(x)] ?? x.siparis;
  const seciliKalemler = kritikler.filter(x => secili.has(anahtar(x)) && mk(x) > 0);
  const seciliTutar = seciliKalemler.reduce((t, x) => t + mk(x) * x.fiyat, 0);
  const seciliDepolar = [...new Set(seciliKalemler.map(x => x.depoId))];
  const cevir = (k: string, set: typeof setSecili) => set(s => { const n = new Set(s); n.has(k) ? n.delete(k) : n.add(k); return n });

  const talepAc = async () => {
    if (seciliDepolar.length !== 1) { setHata('Talep depo başına açılır: tek depodaki kalemleri seçin (üstten depo seçebilirsiniz).'); return }
    setIsliyor(true); setHata(''); setBilgi('');
    try {
      const r = await api.kritikTalepAc(seciliDepolar[0], seciliKalemler.map(x => ({ stokId: x.stokId, miktar: mk(x) })));
      setBilgi(`Taslak satınalma talebi açıldı: ${r.talepNo || '#' + r.id} · ${r.kalem} kalem${r.atlanan ? ` · ${r.atlanan} kalemin zaten açık talebi vardı, atlandı` : ''}. Onaya göndermek için talebi açın.`);
      setTazele(t => t + 1);
      git(`/satinalma-talep/${r.id}`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };

  const limitUygula = async () => {
    const l = oneriler.filter(x => oneriSecili.has(anahtar(x)));
    const depolar = [...new Set(l.map(x => x.depoId))];
    if (l.length === 0) return;
    setIsliyor(true); setHata(''); setBilgi('');
    try {
      let n = 0;
      for (const d of depolar) {
        const r = await api.kritikLimitYaz(d, l.filter(x => x.depoId === d).map(x => {
          const v = oneriDeger[anahtar(x)];
          return { stokId: x.stokId, min: v?.min ?? x.oneriMin, max: v?.max ?? x.oneriMax };
        }));
        n += r.yazilan;
      }
      setBilgi(`${n} stok × depo satırına min / max yazıldı (stok kartı › Stok Durumu'nda da görünür).`);
      setTazele(t => t + 1);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };

  const depoAdi = depo ? veri?.secim.depoListesi.find(d => d.id === depo)?.ad : 'Tüm depolar';

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Kritik Stok İcmali</h1><span className="yol">Stok &amp; Hizmet › İcmaller › Kritik Stok İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Kritik Stok İcmali" dosyaAdi={`Kritik Stok İcmali ${depoAdi ?? ''}`} devre={!veri}>
          {veri && <KritikA4 v={veri} satirlar={kritikler} mk={mk} antet={antet} duzenleyen={kullanici?.ad ?? ''} depoAdi={depoAdi ?? ''} />}
        </CiktiMenusu>
        <div className="sepv" />
        {veri?.yetkiler.talep && (
          <button disabled={isliyor || seciliKalemler.length === 0} onClick={talepAc}
            title="Seçili kalemlerden taslak satınalma talebi (depo başına bir talep)">
            🛒 Seçilenlerden Satınalma Talebi{seciliKalemler.length ? ` (${seciliKalemler.length})` : ''}</button>
        )}
        <button onClick={() => git('/stok-transfer')}>🔄 Stok Transfer</button>
        {veri?.yetkiler.limit && sekme === 'oneri' && (
          <button disabled={isliyor || oneriSecili.size === 0} onClick={limitUygula}>🎯 Min / Max önerisini uygula{oneriSecili.size ? ` (${oneriSecili.size})` : ''}</button>
        )}
        <span className="sp" />
        <button onClick={() => git('/stok-deger-icmali')}>📦 Stok Değer İcmali</button>
        <button onClick={() => git('/stok-olu-stok-icmali')}>💤 Ölü Stok / Devir Hızı</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu" style={{ margin: '6px 0', padding: '6px 10px', background: '#e2f3e8', border: '1px solid #bfe3cb', borderRadius: 4 }}>{bilgi}</div>}

      <div className="hi-serit">
        <div className="sel">🏬 Depo:
          <select value={depo} onChange={e => degistir({ depo: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.depoListesi ?? []).map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}
          </select></div>
        <div className="sel">🗂 Kategori:
          <select value={kategori} onChange={e => degistir({ kategori: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.kategoriler ?? []).map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
          </select></div>
        <div className="sel">🏷 Stok tipi:
          <select value={tip} onChange={e => degistir({ tip: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.tipler ?? []).map(t => <option key={t.id} value={t.id}>{t.ad}</option>)}
            <option value={-1}>(tipi tanımsız)</option>
          </select></div>
        <div className="sel">📈 Tüketim ortalaması:
          <select value={gun} onChange={e => degistir({ gun: e.target.value === '90' ? '' : e.target.value })}>
            {[30, 60, 90, 180].map(g => <option key={g} value={g}>Son {g} gün</option>)}
          </select></div>
        <div className="sel">🚚 Tedarik süresi:
          <select value={tedarik} onChange={e => degistir({ tedarik: e.target.value === '7' ? '' : e.target.value })}>
            {[3, 7, 14, 21, 30, 45, 60].map(g => <option key={g} value={g}>{g} gün</option>)}
          </select></div>
        {sekme === 'krt' && (
          <div className="si-seg">
            {([['kritik', 'Kritik altı / yok'], ['tukeniyor', 'Tükenmek üzere'], ['tumu', 'Tümü']] as const).map(([k, a]) =>
              <button key={k} type="button" className={suzme === k ? 'on' : ''} onClick={() => degistir({ goster: k === 'tumu' ? '' : k })}>{a}</button>)}
          </div>
        )}
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && <span className="bo-rz" title="Genel Ayarlar › satinalma.kritik_stok_aktif">Otomatik talep: <b>{o.otomatikTalep ? 'açık' : 'kapalı'}</b></span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Kritik Altı" deg={sayi(o.kritik)} alt={`kalem · eldeki ≤ asgari · ${o.sktYakinKalem} kalemde SKT yakın lot düşüldü`} sinif={o.kritik ? 'teh' : ''} />
          <Kutu bas="Stokta Yok" deg={sayi(o.yok)} alt={`kalem · son ${veri.gun} günde çıkışı var`} sinif={o.yok ? 'teh' : ''} />
          <Kutu bas={`${veri.tedarik} Günde Biter`} deg={sayi(o.tukeniyor)} alt="kalem · tedarik süresinden kısa" sinif={o.tukeniyor ? 'uy' : ''} />
          <Kutu bas="Yolda" deg={sayi(o.yolda)} alt="kalem · açık talep / sipariş" />
          <Kutu bas="Önerilen Sipariş" deg={kisaTl(o.siparisTutar)} alt={`${o.siparisKalem} kalem · son alış fiyatıyla`} sinif="mor" />
          <Kutu bas="Min Tanımsız" deg={sayi(o.minTanimsiz)} alt={`/ ${sayi(o.satir)} stok × depo · ${o.minTanimsizA}'i A sınıfı`} sinif={o.minTanimsiz ? 'uy' : ''} />
          <Kutu bas="Max Üstü" deg={sayi(o.maxUstu)} alt={`kalem · fazla ${kisaTl(o.maxUstuTutar)}`} />
          <Kutu bas="Diğer Depoda Var" deg={sayi(o.baskaDepoda)} alt="kritik kalem transferle karşılanır" sinif={o.baskaDepoda ? 'iyi' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['krt', 'Kritik Altı', kritikler.length], ['tuk', 'Tükenme Takvimi', null],
              ['oneri', 'Min / Max Önerisi', oneriler.length], ['fazla', 'Max Üstü', veri.maxUstu.length]]} />

            {(sekme === 'krt' || sekme === 'oneri') && (
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Stok kodu ya da adı…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                <span className="ki-soluk">{sekme === 'krt'
                  ? 'kutucukla seç → talep · "Sipariş" hücresi düzenlenebilir · ada tıkla: stok kartı · tükenme gününe göre sıralı'
                  : 'seç → "Min / Max önerisini uygula" · min ve max hücreleri düzenlenebilir'}</span>
              </div>
            )}

            {sekme === 'krt' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th style={{ width: 24 }}><input type="checkbox" checked={kritikler.length > 0 && kritikler.every(x => secili.has(anahtar(x)))}
                    onChange={e => setSecili(e.target.checked ? new Set(kritikler.map(anahtar)) : new Set())} /></th>
                    <th>Kod</th><th>Stok Adı</th>{!depo && <th>Depo</th>}<th>Birim</th><th className="sag">Eldeki</th>
                    <th className="sag" title="SKT'si 30 gün içinde dolan (ya da geçmiş) lot - eldekinden düşüldü">SKT ≤ 30 g</th><th className="sag">Yolda</th>
                    <th className="sag">Min</th><th className="sag">Max</th><th className="sag">Günlük</th><th className="orta">Yeter</th>
                    <th className="sag">Sipariş</th><th className="sag">Tutar</th><th>Tedarikçi (son alış)</th><th>Durum</th></tr></thead>
                  <tbody>
                    {kritikler.length === 0 && <tr><td colSpan={16} className="bos">
                      Bu süzgeçte kritik ya da tükenmek üzere kalem yok.{o.minTanimsiz === o.satir ? ' Hiçbir stokta asgari seviye tanımlı değil — "Min / Max Önerisi" sekmesinden tanımlayabilirsiniz.' : ''}</td></tr>}
                    {kritikler.slice(0, 1000).map(x => {
                      const k = anahtar(x);
                      return (
                        <tr key={k}>
                          <td><input type="checkbox" checked={secili.has(k)} onChange={() => cevir(k, setSecili)} /></td>
                          <td>{x.kod}</td><td><span className="lnk" onClick={() => kartAc(x.stokId)}>{x.ad}</span></td>
                          {!depo && <td>{x.depo}</td>}<td>{x.birim}</td>
                          <td className={'sag' + (x.eldeki <= 0 ? ' kir' : '')}><b>{sayi(x.eldeki)}</b></td>
                          <td className="sag">{x.sktYakin ? <span className="bo-rz sari">{sayi(x.sktYakin)}</span> : <span className="ki-soluk">—</span>}</td>
                          <td className="sag">{x.yolda ? sayi(x.yolda) : <span className="ki-soluk">—</span>}</td>
                          <td className="sag">{x.min != null ? sayi(x.min) : <span className="ki-soluk">—</span>}</td>
                          <td className="sag">{x.max != null ? sayi(x.max) : <span className="ki-soluk">—</span>}</td>
                          <td className="sag">{x.gunluk.toLocaleString('tr-TR')}</td>
                          <td className="orta">{x.eldeki <= 0 ? <span className="bo-rz kir">bitti</span>
                            : x.yeter == null ? <span className="ki-soluk">—</span>
                            : <span className={'bo-rz ' + (x.yeter <= veri.tedarik ? 'sari' : '')}>{Math.floor(x.yeter)} gün</span>}</td>
                          <td className="sag"><input type="number" min={0} value={mk(x)} style={{ width: 70, textAlign: 'right' }}
                            onChange={e => setMiktar(m => ({ ...m, [k]: Math.max(0, Number(e.target.value) || 0) }))} /></td>
                          <td className="sag">{x.fiyat ? tl(mk(x) * x.fiyat) : <span className="ki-soluk" title="son alış fiyatı yok">—</span>}</td>
                          <td>{x.tedarikci ? `${x.tedarikci} · ${tarihT(x.sonAlisTarihi)} · ${tl(x.fiyat)}` : <span className="ki-soluk">alış belgesi yok</span>}</td>
                          <td>
                            {x.talep && <span className="bo-rz sari">Talep {x.talep}</span>}
                            {x.siparisNo && <span className="bo-rz mavi">Sipariş {x.siparisNo} · yolda</span>}
                            {!x.talep && !x.siparisNo && <span className="bo-rz kir">Talep yok</span>}
                            {x.baskaDepo && <span className="bo-rz ok" style={{ marginLeft: 4 }}>{x.baskaDepo}'da {sayi(x.baskaFazla)} fazla</span>}
                            {x.minTanimsiz && <span className="ki-soluk" style={{ marginLeft: 4 }}>min yok: önerilen max'a</span>}
                          </td>
                        </tr>
                      );
                    })}
                    <tr className="top"><td colSpan={depo ? 12 : 13}>Seçili {seciliKalemler.length} kalem · önerilen sipariş</td>
                      <td className="sag">{tl(seciliTutar)}</td><td colSpan={2} /></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Eldeki = kalan − rezerve − SKT'si 30 gün içinde dolan lot ({o.sktYakinKalem} kalemde {sayi(o.sktYakinMiktar)}; satılamayacak mal sayılmaz).
                Kritik = eldeki ≤ asgari (depo bazında; yoksa stok kartının). Sipariş = hedef − eldeki − yolda; hedef = azami,
                yoksa asgari × {o.hedefKat} (otomatik talep ile aynı kural), asgari de yoksa önerilen max. Yeter = (eldeki + yolda) / günlük çıkış
                (son {veri.gun} gün, transfer çıkışı dahil). Talep TASLAK açılır, onaya siz gönderirsiniz; açık talebi olan kalem atlanır.
              </div>
            </>}

            {sekme === 'tuk' && (
              <Kutucuk baslik="Tükenme takvimi — önümüzdeki 30 gün" not={`bu tüketim hızıyla stoğun bittiği gün · tedarik süresi ${veri.tedarik} gün`}>
                <table className="hi-tablo"><thead><tr><th>Dilim</th><th className="sag">Biten kalem</th><th>Kalemler</th><th className="sag">Tedarik süresi içinde</th></tr></thead>
                  <tbody>{veri.takvim.map(t => (
                    <tr key={t.ad}><td>{t.ad}</td><td className="sag"><b>{t.kalem}</b></td>
                      <td style={{ whiteSpace: 'normal' }}>{t.ornekler.map(x => `${x.kod}${x.yeter != null && x.yeter > 0 ? ` (${Math.floor(x.yeter)} g)` : ''}${x.yolda ? ` · yolda ${sayi(x.yolda)}` : ''}`).join(', ')}
                        {t.kalem > t.ornekler.length && ` … ${t.kalem - t.ornekler.length} kalem daha`}</td>
                      <td className={'sag' + (t.tedarikIcinde ? ' kir' : ' ki-soluk')}>{t.tedarikIcinde ? `${t.tedarikIcinde} ▲` : '—'}</td></tr>))}</tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>▲ = tedarik süresi içinde biter: şimdi sipariş verilmezse boşluk olur.</div>
              </Kutucuk>
            )}

            {sekme === 'oneri' && <>
              <table className="hi-tablo">
                <thead><tr><th style={{ width: 24 }}><input type="checkbox" checked={oneriler.length > 0 && oneriler.every(x => oneriSecili.has(anahtar(x)))}
                  onChange={e => setOneriSecili(e.target.checked ? new Set(oneriler.map(anahtar)) : new Set())} disabled={!veri.yetkiler.limit} /></th>
                  <th>Kod</th><th>Stok Adı</th>{!depo && <th>Depo</th>}<th>ABC</th><th className="sag">Günlük</th><th className="sag">Dalgalanma</th><th className="sag">Tedarik</th>
                  <th className="sag">Şimdiki Min</th><th className="sag">Önerilen Min</th><th className="sag">Şimdiki Max</th><th className="sag">Önerilen Max</th><th className="sag">Eldeki</th></tr></thead>
                <tbody>
                  {oneriler.length === 0 && <tr><td colSpan={13} className="bos">Son {veri.gun} günde çıkışı olan kalem yok — öneri üretilemez.</td></tr>}
                  {oneriler.slice(0, 1000).map(x => {
                    const k = anahtar(x);
                    const v = oneriDeger[k] ?? { min: x.oneriMin, max: x.oneriMax };
                    const yaz = (alan: 'min' | 'max', n: number) => setOneriDeger(d => ({ ...d, [k]: { ...v, [alan]: Math.max(0, n || 0) } }));
                    return (
                      <tr key={k}>
                        <td><input type="checkbox" checked={oneriSecili.has(k)} onChange={() => cevir(k, setOneriSecili)} disabled={!veri.yetkiler.limit} /></td>
                        <td>{x.kod}</td><td><span className="lnk" onClick={() => kartAc(x.stokId)}>{x.ad}</span></td>{!depo && <td>{x.depo}</td>}
                        <td><span className={'bo-rz ' + (x.abc === 'A' ? 'ok' : x.abc === 'B' ? 'mavi' : '')}>{x.abc}</span></td>
                        <td className="sag">{x.gunluk.toLocaleString('tr-TR')}</td><td className="sag">±{x.sigma.toLocaleString('tr-TR')}</td><td className="sag">{x.tedarik} g</td>
                        <td className="sag">{x.min != null ? sayi(x.min) : x.kartMin != null ? <span className="ki-soluk" title="stok kartı geneli">{sayi(x.kartMin)} (kart)</span> : <span className="ki-soluk">—</span>}</td>
                        <td className="sag"><input type="number" min={0} value={v.min} style={{ width: 64, textAlign: 'right' }} onChange={e => yaz('min', Number(e.target.value))} /></td>
                        <td className="sag">{x.max != null ? sayi(x.max) : <span className="ki-soluk">—</span>}</td>
                        <td className="sag"><input type="number" min={0} value={v.max} style={{ width: 64, textAlign: 'right' }} onChange={e => yaz('max', Number(e.target.value))} /></td>
                        <td className={'sag' + (x.eldeki <= 0 ? ' kir' : '')}>{sayi(x.eldeki)}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
              <div className="ki-soluk si-not">
                Önerilen min = günlük × tedarik süresi + emniyet stoku (dalgalanma × 1,65 × √tedarik, %95 hizmet düzeyi). Önerilen max = min + 30 günlük tüketim.
                Uygula, seçili satırların depo bazındaki min / max değerini yazar (stok kartı › Stok Durumu ile aynı, loglu); kart genelindeki asgariye dokunmaz.
                Son {veri.gun} günde çıkışı olmayan {o.cikissiz} satıra öneri üretilmez.{!veri.yetkiler.limit && ' Uygulamak için stok kartında değiştirme yetkisi gerekir.'}
              </div>
            </>}

            {sekme === 'fazla' && (
              <Kutucuk baslik="Max seviyesinin üstündekiler" not="fazla = eldeki − max · fazla tutara göre">
                <table className="hi-tablo"><thead><tr><th>Kod</th><th>Stok Adı</th>{!depo && <th>Depo</th>}<th className="sag">Eldeki</th><th className="sag">Max</th>
                  <th className="sag">Fazla</th><th className="sag">Fazla Tutar</th><th className="sag">Kaç günlük</th><th>Öneri</th></tr></thead>
                  <tbody>
                    {veri.maxUstu.length === 0 && <tr><td colSpan={9} className="bos">Max tanımlı ve üstünde olan kalem yok.</td></tr>}
                    {veri.maxUstu.map(x => (
                      <tr key={anahtar(x)}><td>{x.kod}</td><td><span className="lnk" onClick={() => kartAc(x.stokId)}>{x.ad}</span></td>{!depo && <td>{x.depo}</td>}
                        <td className="sag">{sayi(x.eldeki)}</td><td className="sag">{sayi(x.max)}</td><td className="sag kir">{sayi(x.fazla)}</td><td className="sag">{tl(x.tutar)}</td>
                        <td className="sag">{x.fazlaGun != null ? `${x.fazlaGun} gün` : '—'}</td>
                        <td>{x.oneri === 'transfer' ? <span className="bo-rz ok">{x.oneriDepo}'ya transfer</span> : <span className="bo-rz sari">Alımı durdur</span>}
                          {x.acikTalep && <span className="bo-rz kir" style={{ marginLeft: 4 }}>açık talep / sipariş var</span>}</td></tr>))}
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Açık talebi olan max üstü kalemde talep onaylanırsa fazla büyür.</div>
              </Kutucuk>
            )}
          </div>
        </div>
      </>)}
    </div>
  );
}

function KritikA4({ v, satirlar, mk, antet, duzenleyen, depoAdi }: {
  v: Veri; satirlar: KritikSatiri[]; mk(x: KritikSatiri): number; antet: Record<string, unknown> | null; duzenleyen: string; depoAdi: string;
}) {
  const o = v.ozet;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>KRİTİK STOK İCMALİ</h3>
      <div className="a4-hasta">
        <span>Depo: <b>{depoAdi}</b></span><span>Tüketim: son {v.gun} gün ortalaması</span>
        <span>Kritik altı: {o.kritik} · stokta yok {o.yok}</span><span>Tedarik süresi: {v.tedarik} gün</span>
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Stok</th><th>Eldeki</th><th>Yolda</th><th>Min</th><th>Yeter</th><th>Sipariş</th><th>Tedarikçi</th></tr></thead>
        <tbody>{satirlar.map(x => <tr key={`${x.stokId}:${x.depoId}`}><td>{x.kod} · {x.ad}{v.depo ? '' : ` (${x.depo})`}</td><td>{sayi(x.eldeki)}</td>
          <td>{x.yolda ? sayi(x.yolda) : '—'}</td><td>{x.min != null ? sayi(x.min) : '—'}</td>
          <td>{x.eldeki <= 0 ? 'bitti' : x.yeter != null ? `${Math.floor(x.yeter)} gün` : '—'}</td><td>{sayi(mk(x))}</td><td>{x.tedarikci || '—'}</td></tr>)}</tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Kritik altı kalem</td><td>{o.kritik}</td></tr>
        <tr><td>Yolda (açık talep / sipariş)</td><td>{o.yolda}</td></tr>
        <tr className="kalan ki-kalan"><td>ÖNERİLEN SİPARİŞ</td><td>{tl(satirlar.reduce((t, x) => t + mk(x) * x.fiyat, 0))} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Min / max depo bazında (yoksa stok kartı geneli) · sipariş tutarı son alış fiyatıyla, KDV hariç.</p>
      <div className="a4-imza"><div>Depo Sorumlusu<br />Ad Soyad · İmza</div><div>Satınalma<br />Onay · İmza</div></div>
    </div>
  );
}

export default StokKritikStokIcmali;
