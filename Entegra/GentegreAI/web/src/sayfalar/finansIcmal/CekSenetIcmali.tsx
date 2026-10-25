import { Fragment, useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import { cekSenetIcmalUclari, type CekSenetEvrak, type CekSenetIcmali as Veri } from '../../api/uclar/cekSenetIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, isiRengi, kisaTl, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';

/**
 * ÇEK / SENET İCMALİ `/cek-senet-icmali` - mockup Ekranlar/İcmal/cek_senet_icmali.html.
 * "Elimizde ne kadarlık çek / senet var, nerede (portföy, banka, teminat, ciro), ne zaman paraya
 * dönüyor, hangisi riskli; kendi verdiğimiz çeklere hesapta karşılık var mı?" Durum Çek / Senet
 * Listesi ile aynı kural (evrakın durumu = son hareketi). Dövizli evrak bugünkü kurla TL (karar
 * 25.10.2026); alış kuru ve kur farkı satır ayrıntısında. İcmal KAYIT YAZMAZ: "tahsile ver" ve
 * "ciro et" çek / senet listesindeki akışa gider. Rakamlar sunucuda; ekran toplamaz.
 */
type Sekme = 'port' | 'akis' | 'vade' | 'kes' | 'ver';
type Yon = 'alinan' | 'verilen' | 'ikisi';

const turAdi = (t: number) => (t === 2 ? 'Senet' : 'Çek');

function kalanMetni(g: number) {
  if (g < 0) return `${-g} gün geçti`;
  if (g === 0) return 'bugün';
  return `${g} gün`;
}

/** Durum rozeti (renk) - metin listedeki durum adı + sunucunun eki. */
function Rozet({ e }: { e: CekSenetEvrak }) {
  if (e.yon === 2) {
    if (e.durum === 60) return <span className="bo-rz kir">karşılıksız{e.durumEk ? ` · ${e.durumEk}` : ''}</span>;
    if (e.durum === 10) {
      if (e.kalanGun < 0) return <span className="bo-rz kir">vadesi geçti · ödenmedi</span>;
      if (e.yetersiz) return <span className="bo-rz kir" title="Vade günündeki hesap bakiyesi bu evrakı karşılamıyor">ödenecek · bakiye yetersiz</span>;
      return <span className="bo-rz sari">ödenecek</span>;
    }
    return <span className="bo-rz">{e.durumAdi.toLocaleLowerCase('tr')}</span>;
  }
  switch (e.durum) {
    case 10: return e.kalanGun < 0
      ? <span className="bo-rz sari">portföyde · vadesi geçti</span>
      : <span className="bo-rz ok">portföyde</span>;
    case 30: return <span className="bo-rz mavi">bankada tahsilde{e.durumEk ? ` · ${e.durumEk}` : ''}</span>;
    case 40: return <span className="bo-rz pas">teminatta{e.durumEk ? ` · ${e.durumEk}` : ''}</span>;
    case 20: return <span className="bo-rz sari" title="Vadesi gelmemiş ciro: keşideci ödemezse rücu edilir">ciro edildi{e.ciroCari ? ` · ${e.ciroCari}` : ''}</span>;
    case 60: return <span className="bo-rz kir" title="Takip notu, hatırlatma ve ödeme sözü ayrı takip ekranındadır">karşılıksız / protestolu{e.durumEk ? ` · ${e.durumEk}` : ''}</span>;
    default: return <span className="bo-rz">{e.durumAdi}</span>;
  }
}

export function CekSenetIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const { kullanici } = useOturum();
  const antet = useAntet();
  const tur = Number(arama.get('tur') ?? 0);
  const para = arama.get('para') ?? '';
  const banka = arama.get('banka') ?? '';
  const vade = arama.get('vade') ?? '';
  const yon = (arama.get('yon') ?? 'alinan') as Yon;
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('port');
  const [ara, setAra] = useState('');
  const [acik, setAcik] = useState<number | null>(null);
  const [secili, setSecili] = useState<Set<number>>(new Set());

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams();
    if (tur) q.set('tur', String(tur));
    if (para) q.set('para', para);
    if (banka) q.set('banka', banka);
    if (vade) q.set('vade', vade);
    cekSenetIcmalUclari.cekSenetIcmali(q)
      .then(v => { setVeri(v); setSecili(new Set()); setAcik(null) })
      .catch(h => setHata(hataMetni(h)))
      .finally(() => setYukleniyor(false));
  }, [tur, para, banka, vade]);

  /** Tutar: para birimi seçili değilse TL (bugünkü kurla), seçiliyse o para. */
  const t = (n: number) => (para ? `${tl(n)} ${para}` : `${tl(n)} ₺`);
  const kt = (n: number) => (para ? `${tl(n)} ${para}` : kisaTl(n));

  const kartAc = (e: CekSenetEvrak) => {
    const yol = `/${e.tur === 2 ? 'senet' : 'cek'}/${e.id}`;
    if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol);
  };

  const q = ara.trim().toLocaleLowerCase('tr');
  const uyar = (e: CekSenetEvrak) => !q || [e.seriNo, e.kesideci, e.cari, e.banka, e.hesap]
    .some(x => x.toLocaleLowerCase('tr').includes(q));
  const portfoyListesi = useMemo(() => {
    if (!veri) return [];
    const l = yon === 'alinan' ? veri.alinan : yon === 'verilen' ? veri.verilen : [...veri.alinan, ...veri.verilen];
    return l.filter(uyar);
  }, [veri, yon, ara]); // eslint-disable-line react-hooks/exhaustive-deps
  const listeToplami = veri ? veri.toplam[yon] : { adet: 0, tutar: 0 };
  const seciliEvrak = (veri?.alinan ?? []).filter(e => secili.has(e.id));
  const seciliTutar = seciliEvrak.reduce((s, e) => s + e.deger, 0);
  const cevir = (id: number) => setSecili(s => { const n = new Set(s); n.has(id) ? n.delete(id) : n.add(id); return n });

  /** Tahsile ver / ciro: icmal kayıt yazmaz, seçilen türün listesindeki işlem akışına gider. */
  const listeyeGit = () => git(seciliEvrak.length > 0 && seciliEvrak.every(e => e.tur === 2) ? '/senet' : tur === 2 ? '/senet' : '/cek');

  const o = veri?.ozet;
  const enBuyukTakvim = Math.max(0, ...(veri?.takvim ?? []).flatMap(d => [d.alinan, d.verilen]));
  const enBuyukDurum = Math.max(0, ...(veri?.durumlar ?? []).map(d => d.tutar));

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + CEK_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Çek / Senet İcmali</h1><span className="yol">Finans › İcmaller › Çek / Senet İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Çek / Senet İcmali" dosyaAdi={`Çek Senet İcmali ${veri ? tarihT(veri.tarih) : ''}`} devre={!veri}>
          {veri && <CekSenetA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} t={t} />}
        </CiktiMenusu>
        <div className="sepv" />
        <button onClick={listeyeGit} disabled={seciliEvrak.length === 0}
          title="İcmal kayıt yazmaz: çek / senet listesindeki işlem akışı açılır, seçtiğiniz evrakları orada tahsile verirsiniz">
          🏦 Seçilenleri bankaya tahsile ver…{seciliEvrak.length ? ` (${seciliEvrak.length})` : ''}</button>
        <button onClick={listeyeGit} disabled={seciliEvrak.length === 0}
          title="İcmal kayıt yazmaz: çek / senet listesindeki işlem akışı açılır, ciroyu orada yaparsınız">
          ↪ Seçilenleri ciro et…</button>
        <span className="sp" />
        <button onClick={() => git('/tahsilat-odeme-icmali')}>💳 Tahsilat / Ödeme</button>
        <button onClick={() => git('/nakit-akis-icmali')}>📈 Nakit Akış (Vade)</button>
        <button onClick={() => git(tur === 2 ? '/senet' : '/cek')}>📋 Çek / Senet Listesi</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="si-seg">
          {([['alinan', 'Alınan (müşteri)'], ['verilen', 'Verilen (kendi)'], ['ikisi', 'İkisi']] as const).map(([k, a]) =>
            <button key={k} type="button" className={yon === k ? 'on' : ''} onClick={() => degistir({ yon: k === 'alinan' ? '' : k })}>{a}</button>)}
        </div>
        <div className="si-seg">
          {([[0, 'Çek + Senet'], [1, 'Çek'], [2, 'Senet']] as const).map(([k, a]) =>
            <button key={k} type="button" className={tur === k ? 'on' : ''} onClick={() => degistir({ tur: String(k) })}>{a}</button>)}
        </div>
        <div className="sel">📅 Vade:
          <select value={vade} onChange={e => degistir({ vade: e.target.value })}>
            <option value="">Tümü</option>
            <option value="gecmis">Vadesi geçmiş</option>
            <option value="7">7 gün içinde</option>
            <option value="30">30 gün içinde</option>
            <option value="60">60 gün içinde</option>
            <option value="90">90 gün içinde</option>
            <option value="sonra">90 günden sonra</option>
          </select></div>
        <div className="sel">🏦 Banka:
          <select value={banka} onChange={e => degistir({ banka: e.target.value })}>
            <option value="">Tümü</option>
            {(veri?.secim.bankalar ?? []).map(b => <option key={b} value={b}>{b}</option>)}
          </select></div>
        <div className="sel">💱 Para birimi:
          <select value={para} onChange={e => degistir({ para: e.target.value })}>
            <option value="">TL karşılığı</option>
            {(veri?.secim.paralar ?? []).map(p => <option key={p} value={p}>{p}</option>)}
          </select></div>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.gecmis.adet > 0 && <span className="bo-rz sari">Vadesi geçmiş portföyde: <b>{o.gecmis.adet}</b></span>}
        {o && o.karsiliksiz.adet > 0 && <span className="bo-rz kir">Karşılıksız: <b>{o.karsiliksiz.adet}</b></span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Portföyde" deg={kt(o.portfoy.tutar)}
            alt={`${o.portfoy.adet} evrak${o.portfoy.ortVade != null ? ` · ort. vade ${o.portfoy.ortVade} gün` : ''}`} />
          <Kutu bas="Bankada Tahsilde" deg={kt(o.tahsilde.tutar)}
            alt={`${o.tahsilde.adet} evrak${o.tahsilde.hesaplar.length ? ' · ' + o.tahsilde.hesaplar.slice(0, 3).map(h => `${h.ad} ${h.adet}`).join(' · ') : ''}`} sinif="iyi" />
          <Kutu bas="Teminatta" deg={kt(o.teminat.tutar)} alt={`${o.teminat.adet} evrak`} />
          <Kutu bas="Ciro Edilen (vadesi gelmemiş)" deg={kt(o.ciro.tutar)} alt={`${o.ciro.adet} evrak · rücu riski`} sinif={o.ciro.adet ? 'uy' : ''} />
          <Kutu bas="30 Gün İçinde Vadeli" deg={kt(o.gun30.tutar)} alt={`${o.gun30.adet} evrak · portföy + tahsilde`} />
          <Kutu bas="Vadesi Geçmiş" deg={kt(o.gecmis.tutar)} alt={`${o.gecmis.adet} evrak hâlâ portföyde`} sinif={o.gecmis.adet ? 'teh' : ''} />
          <Kutu bas="Karşılıksız / Protestolu" deg={kt(o.karsiliksiz.tutar)} alt={`${o.karsiliksiz.cek} çek · ${o.karsiliksiz.senet} senet`} sinif={o.karsiliksiz.adet ? 'teh' : ''} />
          <Kutu bas="Verilen (ödenecek)" deg={kt(o.verilen.tutar)}
            alt={`${o.verilen.adet} kendi evrakımız · 60 gün içinde ${o.verilen.gun60}${o.verilen.gecmis ? ` · ${o.verilen.gecmis} vadesi geçti` : ''}`} sinif="mor" />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['port', 'Portföy', portfoyListesi.length], ['akis', 'Durum Akışı', null], ['vade', 'Vade Takvimi', null],
              ['kes', 'Keşideci / Banka', null], ['ver', 'Verilen Çekler', veri.verilen.length]]} />

            {sekme === 'port' && <>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Seri no, keşideci, cari, banka…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                <span className="ki-soluk">portföydeki alınan evrakı kutucukla seç → tahsile ver / ciro · satıra tıkla: evrak geçmişi · çift tık: evrak kartı · vadeye göre</span>
              </div>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr>
                    <th style={{ width: 24 }}><input type="checkbox"
                      checked={veri.alinan.some(e => e.secilebilir) && veri.alinan.filter(e => e.secilebilir && uyar(e)).every(e => secili.has(e.id))}
                      onChange={ev => setSecili(ev.target.checked ? new Set(portfoyListesi.filter(e => e.secilebilir).map(e => e.id)) : new Set())} /></th>
                    <th>Tür</th><th>Seri No</th>{yon === 'ikisi' && <th>Yön</th>}<th>Keşideci</th><th>{yon === 'verilen' ? 'Verildiği cari' : 'Alındığı cari'}</th>
                    <th>Banka / Şube</th><th className="orta">Vade</th><th className="sag">Kalan Gün</th><th className="sag">Tutar</th><th>Durum</th>
                  </tr></thead>
                  <tbody>
                    {portfoyListesi.length === 0 && <tr><td colSpan={11} className="bos">Bu süzgeçte açık çek / senet yok.</td></tr>}
                    {portfoyListesi.slice(0, 1000).map(e => (
                      <Fragment key={e.id}>
                        <tr className={e.yetersiz ? 'cs-kir' : ''} style={{ cursor: 'pointer' }}
                          onClick={() => setAcik(a => (a === e.id ? null : e.id))} onDoubleClick={() => kartAc(e)}>
                          <td onClick={ev => ev.stopPropagation()}>
                            {e.secilebilir && <input type="checkbox" checked={secili.has(e.id)} onChange={() => cevir(e.id)} />}</td>
                          <td><span className="ok">{acik === e.id ? '▾' : '▸'}</span>{turAdi(e.tur)}</td>
                          <td>{e.seriNo || <span className="ki-soluk">—</span>}</td>
                          {yon === 'ikisi' && <td>{e.yon === 1 ? 'Alınan' : 'Verilen'}</td>}
                          <td>{e.kesideci}{e.ucuncuKisi && <span className="ki-soluk"> (3. kişi)</span>}</td>
                          <td>{e.cari}</td>
                          <td>{e.banka ? `${e.banka}${e.bankaSube ? ' · ' + e.bankaSube : ''}` : <span className="ki-soluk">—</span>}</td>
                          <td className="orta">{tarihT(e.vade)}</td>
                          <td className={'sag' + (e.kalanGun < 0 ? ' kir' : '')}>{kalanMetni(e.kalanGun)}</td>
                          <td className="sag">{tl(e.deger)}{!para && e.doviz !== 'TL' && <span className="ki-soluk" title={`${tl(e.tutar)} ${e.doviz} · bugünkü kurla`}> ({e.doviz})</span>}</td>
                          <td><Rozet e={e} /></td>
                        </tr>
                        {acik === e.id && <tr className="si-det"><td colSpan={11}><EvrakAyrinti e={e} para={para} /></td></tr>}
                      </Fragment>
                    ))}
                    {portfoyListesi.length > 1000 && <tr><td colSpan={11} className="ki-soluk">… {portfoyListesi.length - 1000} evrak daha (süzgeçle daraltın)</td></tr>}
                    <tr className="top">
                      <td colSpan={yon === 'ikisi' ? 9 : 8}>Toplam ({listeToplami.adet} evrak){seciliEvrak.length > 0 && ` · seçili ${seciliEvrak.length} · ${tl(seciliTutar)}`}{q && ' · arama toplamı değiştirmez'}</td>
                      <td className="sag">{tl(listeToplami.tutar)}</td><td />
                    </tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Durum evrakın son hareketinden (portföye giriş, ciro, bankaya tahsile ve teminata verme, tahsil, karşılıksız / iade) — Çek / Senet
                Listesi ile aynı. Ciro edilmiş evrak vadesi gelene kadar listede kalır (rücu riski). Dövizli evrak bugünkü kurla TL'dir; alış kuru ve
                kur farkı satır ayrıntısında{o.kurYok ? ` (${o.kurYok} evrakın para biriminde kur yok, alış kuru kullanıldı)` : ''}.
                "Tahsile ver" ve "Ciro et" çek / senet listesindeki işlem akışını açar — icmal kayıt yazmaz, kayıt sizde.
              </div>
            </>}

            {sekme === 'akis' && (
              <div className="si-iki">
                <Kutucuk baslik="Durumlara göre alınan evraklar" not="bugün">
                  <table className="hi-tablo"><thead><tr><th>Durum</th><th className="sag">Evrak</th><th className="sag">Tutar</th><th style={{ width: 140 }} /></tr></thead>
                    <tbody>{veri.durumlar.map(d => (
                      <tr key={d.kod}><td className={d.kod === 60 ? 'kir' : ''}>{d.ad}</td><td className="sag">{d.adet}</td>
                        <td className={'sag' + (d.kod === 60 ? ' kir' : '')}>{tl(d.tutar)}</td>
                        <td><Cubuk yuzde={enBuyukDurum > 0 ? (d.tutar * 100) / enBuyukDurum : 0} renk={d.kod === 60 ? '#c0413d' : undefined} /></td></tr>))}
                    </tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Dönem içi hareketler" not={`${tarihT(veri.donem.bas)} – ${tarihT(veri.donem.bit)} · kayıt kuruyla`}>
                  <table className="hi-tablo"><thead><tr><th>Hareket</th><th className="sag">Evrak</th><th className="sag">Tutar</th></tr></thead>
                    <tbody>
                      <tr className="si-grup"><td colSpan={3}>Alınan</td></tr>
                      {veri.donem.alinan.map(d => <tr key={'a' + d.ad}><td>{d.ad}</td><td className="sag">{d.adet}</td>
                        <td className={'sag' + (d.islem === 134 && d.tutar ? ' kir' : '')}>{tl(d.tutar)}</td></tr>)}
                      <tr className="si-grup"><td colSpan={3}>Verilen</td></tr>
                      {veri.donem.verilen.map(d => <tr key={'v' + d.ad}><td>{d.ad}</td><td className="sag">{d.adet}</td><td className="sag">{tl(d.tutar)}</td></tr>)}
                    </tbody></table>
                </Kutucuk>
              </div>
            )}

            {sekme === 'vade' && (
              <Kutucuk baslik="Vade takvimi" not="alınan (giriş) ve verilen (çıkış) evrak · hafta / ay">
                <table className="hi-tablo"><thead><tr><th>Dönem</th><th className="sag">Alınan</th><th className="sag">Evrak</th>
                  <th className="sag">Verilen</th><th className="sag">Evrak</th><th className="sag">Net</th></tr></thead>
                  <tbody>
                    {veri.takvim.map(d => (
                      <tr key={d.ad}>
                        <td className={d.gecmis ? 'kir' : ''}>{d.ad}</td>
                        <td className="si-isi" style={{ background: isiRengi(d.alinan, enBuyukTakvim) }}>{d.alinan ? tl(d.alinan) : '—'}</td>
                        <td className="sag">{d.alinanAdet}</td>
                        <td className="si-isi" style={{ background: isiRengi(d.verilen, enBuyukTakvim) }}>{d.verilen ? tl(d.verilen) : '—'}</td>
                        <td className="sag">{d.verilenAdet}</td>
                        <td className={'sag' + (d.net < 0 ? ' kir' : ' si-yesil')}>{d.net > 0 ? '+' : ''}{tl(d.net)}</td>
                      </tr>))}
                    <tr className="top"><td>Toplam</td><td className="sag">{tl(veri.takvimToplam.alinan)}</td><td className="sag">{veri.takvimToplam.alinanAdet}</td>
                      <td className="sag">{tl(veri.takvimToplam.verilen)}</td><td className="sag">{veri.takvimToplam.verilenAdet}</td>
                      <td className="sag">{veri.takvimToplam.net > 0 ? '+' : ''}{tl(veri.takvimToplam.net)}</td></tr>
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>
                  Alınan = portföy + bankada tahsilde (ciro edilen ve teminattaki hariç). Nakit Akış (Vade) İcmali bu takvimi fatura vadeleriyle birleştirir.
                </div>
              </Kutucuk>
            )}

            {sekme === 'kes' && (
              <div className="si-iki">
                <Kutucuk baslik="Keşideci yoğunlaşması" not={`tek keşidecideki risk · portföy + tahsilde + teminat ${kt(veri.riskToplam)}`}>
                  <table className="hi-tablo"><thead><tr><th>Keşideci</th><th className="sag">Evrak</th><th className="sag">Tutar</th><th className="sag">Pay</th><th>Karşılıksız geçmişi</th></tr></thead>
                    <tbody>
                      {veri.kesideciler.length === 0 && <tr><td colSpan={5} className="bos">Elde alınan evrak yok.</td></tr>}
                      {veri.kesideciler.slice(0, 100).map(k => (
                        <tr key={k.ad}>
                          <td>{k.ad}{k.ucuncuKisi && <span className="ki-soluk" title={k.cariler.join(', ')}> (3. kişi)</span>}</td>
                          <td className="sag">{k.adet}</td><td className="sag">{tl(k.tutar)}</td>
                          <td className={'sag' + (k.pay >= 25 ? ' kir' : '')}>%{k.pay.toLocaleString('tr-TR')}</td>
                          <td className={k.karsiliksiz ? 'kir' : ''}>{k.karsiliksiz
                            ? `${k.karsiliksiz}${k.karsiliksizYil ? ` (${k.karsiliksizYil})` : ''}`
                            : k.ucuncuKisi ? <span className="ki-soluk">bilinmiyor</span> : '0'}</td>
                        </tr>))}
                    </tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Banka bazında" not="muhatap banka">
                  <table className="hi-tablo"><thead><tr><th>Muhatap banka</th><th className="sag">Evrak</th><th className="sag">Tutar</th><th style={{ width: 120 }} /></tr></thead>
                    <tbody>
                      {veri.bankaDagilim.length === 0 && <tr><td colSpan={4} className="bos">—</td></tr>}
                      {veri.bankaDagilim.map(b => (
                        <tr key={b.ad}><td>{b.ad}</td><td className="sag">{b.adet}</td><td className="sag">{tl(b.tutar)}</td><td><Cubuk yuzde={b.pay} /></td></tr>))}
                    </tbody></table>
                </Kutucuk>
              </div>
            )}

            {sekme === 'ver' && <>
              <Kutucuk baslik="Verilen (kendi) çek / senetlerimiz" not="ödeme günü hesapta karşılık olmalı · vadeye göre · çift tık: evrak kartı">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo"><thead><tr><th>Tür</th><th>Seri No</th><th>Verildiği cari</th><th>Banka hesabı</th><th className="orta">Vade</th>
                    <th className="sag">Kalan Gün</th><th className="sag">Tutar</th><th className="sag" title="Vade günündeki hesap bakiyesi (hesabın para biriminde)">Vadede bakiye</th><th>Durum</th></tr></thead>
                    <tbody>
                      {veri.verilen.length === 0 && <tr><td colSpan={9} className="bos">Ödenecek kendi çek / senedimiz yok.</td></tr>}
                      {veri.verilen.map(e => (
                        <tr key={e.id} className={e.yetersiz || (e.durum === 10 && e.kalanGun < 0) ? 'cs-kir' : ''} style={{ cursor: 'pointer' }} onDoubleClick={() => kartAc(e)}>
                          <td>{turAdi(e.tur)}</td><td>{e.seriNo}</td><td>{e.cari}</td>
                          <td>{e.hesap ? <>{e.hesap}{e.hesapTahmini && <span className="ki-soluk" title="Evrakta hesap yok: bankası ve para birimi aynı tek hesap varsayıldı"> (varsayılan)</span>}</>
                            : <span className="ki-soluk">{e.banka || 'hesap belirsiz'}</span>}</td>
                          <td className="orta">{tarihT(e.vade)}</td>
                          <td className={'sag' + (e.kalanGun < 0 ? ' kir' : '')}>{kalanMetni(e.kalanGun)}</td>
                          <td className="sag">{tl(e.deger)}{!para && e.doviz !== 'TL' && <span className="ki-soluk"> ({tl(e.tutar)} {e.doviz})</span>}</td>
                          <td className={'sag' + (e.yetersiz ? ' kir' : '')}>{e.vadeBakiye != null ? `${tl(e.vadeBakiye)} ${e.hesapDoviz === 'TL' ? '₺' : e.hesapDoviz}` : <span className="ki-soluk">—</span>}</td>
                          <td><Rozet e={e} /></td>
                        </tr>))}
                      <tr className="top"><td colSpan={6}>Toplam ({veri.toplam.verilen.adet} evrak)</td><td className="sag">{tl(veri.toplam.verilen.tutar)}</td><td colSpan={2} /></tr>
                    </tbody></table>
                </div>
              </Kutucuk>
              {veri.hesaplar.length > 0 && (
                <Kutucuk baslik="Hesap karşılığı" not="bugünkü defter bakiyesi + tahsildeki çeklerden gelecek − ödenecek evrak">
                  <table className="hi-tablo"><thead><tr><th>Banka hesabı</th><th className="sag">Bugünkü bakiye</th><th className="sag">30 gün içinde ödenecek</th>
                    <th className="sag">Tahsilden gelecek (30 g)</th><th className="sag">30. gün kalan</th><th className="sag">Tüm ödenecek</th><th>Sonuç</th></tr></thead>
                    <tbody>{veri.hesaplar.map(h => {
                      const p = (n: number) => `${tl(n)} ${h.doviz === 'TL' ? '₺' : h.doviz}`;
                      return (
                        <tr key={h.hesapId}><td>{h.ad}{h.tahmini && <span className="ki-soluk"> (varsayılan)</span>}</td><td className="sag">{p(h.bakiye)}</td>
                          <td className="sag">{p(h.odenecek30)} <span className="ki-soluk">· {h.adet30}</span></td><td className="sag">{p(h.giris30)}</td>
                          <td className={'sag' + (h.kalan30 < 0 ? ' kir' : '')}>{p(h.kalan30)}</td><td className="sag">{p(h.odenecekToplam)} <span className="ki-soluk">· {h.adet}</span></td>
                          <td>{h.yeterli && !h.yetersizEvrak ? <span className="bo-rz ok">yeterli</span>
                            : <span className="bo-rz kir">{h.yetersizEvrak ? `${h.yetersizEvrak} evrakta yetersiz` : 'yetersiz'}</span>}</td></tr>);
                    })}</tbody></table>
                </Kutucuk>
              )}
              <div className="ki-soluk si-not">
                Vadede bakiye = hesabın bugünkü defter bakiyesi (Hesap Listesi'ndeki bakiye) + o hesapta tahsildeki alınan çeklerden vadesi gelenler −
                aynı hesaptan o güne kadar ödenecek evrakların toplamı. Karşılamıyorsa satır kırmızı — karşılıksız çek yazmamak için.
                {veri.hesapsizVerilen > 0 && ` ${veri.hesapsizVerilen} evrakta banka hesabı belli değil; karşılaştırılamadı.`}
              </div>
            </>}
          </div>
        </div>
      </>)}
    </div>
  );
}

/** Satır ayrıntısı: nereden geldi, ciro zinciri, kur, hareket geçmişi, risk. */
function EvrakAyrinti({ e, para }: { e: CekSenetEvrak; para: string }) {
  const giris = e.hareketler.find(h => h.islem === 130);
  return (
    <div className="cs-ayr">
      <div>
        {tarihT(giris?.tarih ?? e.tarih)} {e.yon === 1 ? 'alındı' : 'verildi'}{e.cari ? `: ${e.cari}` : ''}
        {(e.girisIslemNo || giris?.islemNo) && ` (${e.yon === 1 ? 'tahsilat' : 'ödeme'} ${e.girisIslemNo || giris?.islemNo})`}
        {e.makbuzNo && ` · makbuz ${e.makbuzNo}`}
        {e.yon === 1 && e.ucuncuKisi && <> · ciro zinciri: {e.kesideci} → {e.cari} → bize{e.durum === 20 && e.ciroCari ? ` → ${e.ciroCari}` : ''} · <span className="kir">risk: keşideci 3. kişi</span></>}
        {e.yon === 1 && !e.ucuncuKisi && e.durum === 20 && e.ciroCari && ` · ciro: bize → ${e.ciroCari} (vadesine kadar rücu riski)`}
      </div>
      {e.doviz !== 'TL' && (
        <div>
          {tl(e.tutar)} {e.doviz} · alış kuru {e.alisKuru.toLocaleString('tr-TR', { maximumFractionDigits: 4 })} → {tl(e.alisDeger)} ₺ ·
          bugünkü kur {e.bugunKur != null ? e.bugunKur.toLocaleString('tr-TR', { maximumFractionDigits: 4 }) : <span className="kir">yok (alış kuru kullanıldı)</span>}
          {' → '}{tl(e.alisDeger + e.kurFarki)} ₺ · kur farkı <b className={e.kurFarki < 0 ? 'kir' : 'si-yesil'}>{e.kurFarki > 0 ? '+' : ''}{tl(e.kurFarki)} ₺</b>
          {para && <span className="ki-soluk"> (para birimi süzgecinde tutarlar {para})</span>}
        </div>
      )}
      {e.hareketler.length > 0 && (
        <div>Geçmiş: {e.hareketler.map((h, i) => (
          <span key={i}>{i > 0 && ' · '}{tarihT(h.tarih)} {h.ad}{h.cari ? ` (${h.cari})` : ''}{h.hesap ? ` [${h.hesap}]` : ''}{h.aciklama ? ` — ${h.aciklama}` : ''}</span>))}
        </div>
      )}
      {e.aciklama && <div>Açıklama: {e.aciklama}</div>}
    </div>
  );
}

function CekSenetA4({ v, antet, duzenleyen, t }: {
  v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; t(n: number): string;
}) {
  const o = v.ozet;
  const satirlar = v.alinan.filter(e => e.durum === 10 || e.durum === 30 || e.durum === 40);
  const turMetni = v.tur === 1 ? 'çek' : v.tur === 2 ? 'senet' : 'çek + senet';
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>ÇEK / SENET İCMALİ (PORTFÖY)</h3>
      <div className="a4-hasta">
        <span>Tarih itibarıyla: <b>{tarihT(v.tarih)}</b></span><span>Alınan · {turMetni}{v.banka ? ` · ${v.banka}` : ''}</span>
        <span>{satirlar.length} evrak{o.portfoy.ortVade != null ? ` · ort. vade ${o.portfoy.ortVade} gün` : ''}</span>
        <span>Vadesi geçmiş: {o.gecmis.adet} evrak</span>
      </div>
      <table className="a4-t">
        <thead><tr><th>Seri No</th><th>Keşideci</th><th>Banka</th><th>Vade</th><th style={{ textAlign: 'right' }}>Tutar</th><th>Durum</th></tr></thead>
        <tbody>{satirlar.map(e => (
          <tr key={e.id}><td>{e.seriNo}</td><td>{e.kesideci}</td><td>{e.banka || '—'}</td><td>{tarihT(e.vade)}</td>
            <td style={{ textAlign: 'right' }}>{t(e.deger)}</td>
            <td>{e.durum === 10 ? (e.kalanGun < 0 ? 'vadesi geçti' : 'portföyde') : e.durum === 30 ? 'tahsilde' : 'teminatta'}</td></tr>))}</tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Portföyde</td><td>{t(o.portfoy.tutar)}</td></tr>
        <tr><td>Bankada tahsilde</td><td>{t(o.tahsilde.tutar)}</td></tr>
        <tr><td>Teminatta</td><td>{t(o.teminat.tutar)}</td></tr>
        <tr className="kalan ki-kalan"><td>TOPLAM ALINAN</td><td>{t(o.elde.tutar)}</td></tr>
      </tbody></table>
      <p className="a4-not">Durum evrakın son hareketinden · {v.para ? `tutarlar ${v.para}` : 'dövizli evrak bugünkü kurla TL'} · banka teslim bordrosu yerine geçmez.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali İşler<br />Kaşe · İmza</div></div>
    </div>
  );
}

const CEK_STILI = `
.hi-tablo tr.cs-kir td { background:#fbe9e7; }
.cs-ayr { line-height:1.7; }
.cs-ayr > div + div { margin-top:2px; }
`;

export default CekSenetIcmali;
