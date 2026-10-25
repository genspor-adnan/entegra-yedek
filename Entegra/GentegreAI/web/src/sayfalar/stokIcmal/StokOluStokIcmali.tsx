import { Fragment, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { OluStokIcmali as Veri, OluStokSatiri } from '../../api/uclar/stokIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import { ayYil, Cubuk, isiRengi, kisaTl, Kutu, Kutucuk, sayi, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useStokKarti, useSuzgec } from './stokIcmalOrtak';

/**
 * ÖLÜ STOK / DEVİR HIZI İCMALİ `/stok-olu-stok-icmali` (1174) - mockup Ekranlar/Stok/stok_olu_stok_icmali.html.
 * "Hangi mala para bağladık ve dönmüyor; neyi iade / transfer / kampanya ile eritelim?"
 */
type Sekme = 'olu' | 'devir' | 'abc' | 'trend';
const ONERI: Record<OluStokSatiri['oneri'], [string, string]> = {
  skt: ['SKT önce — iade / imha', 'kir'], transfer: ['Transfer', 'ok'], iade: ['Tedarikçiye iade', 'mavi'],
  sayim: ['Sayımla doğrula', ''], kampanya: ['Kampanya / fiyat', 'sari'],
};
const SINIF: Record<string, [string, string]> = {
  hizli: ['Hızlı', 'ok'], normal: ['Normal', 'mavi'], yavas: ['Yavaş', 'sari'], olu: ['Ölü', 'kir'],
};
const oran = (n: number) => '%' + n.toLocaleString('tr-TR', { maximumFractionDigits: 1 });

export function StokOluStokIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const kartAc = useStokKarti();
  const tarih = arama.get('tarih') ?? bugunYerel();
  const esik = Number(arama.get('esik') ?? 180);
  const her = arama.get('hareket') === 'her';
  const depo = Number(arama.get('depo') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('olu');
  const [ara, setAra] = useState('');
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const [siralama, setSiralama] = useState<'tutar' | 'devir' | 'gun'>('tutar');

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ tarih, esik: String(esik) });
    if (her) q.set('hareket', 'her');
    if (depo) q.set('depo', String(depo));
    if (kategori) q.set('kategori', String(kategori));
    api.oluStokIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [tarih, esik, her, depo, kategori]);

  const filtre = (kod: string, ad: string, kat: string) => {
    const q = ara.trim().toLocaleLowerCase('tr');
    return !q || kod.toLocaleLowerCase('tr').includes(q) || ad.toLocaleLowerCase('tr').includes(q) || kat.toLocaleLowerCase('tr').includes(q);
  };
  const oluler = useMemo(() => (veri?.oluler ?? []).filter(x => filtre(x.kod, x.ad, x.kategori)), [veri, ara]); // eslint-disable-line react-hooks/exhaustive-deps
  const devir = useMemo(() => {
    const l = (veri?.devir ?? []).filter(x => filtre(x.kod, x.ad, x.kategori));
    return siralama === 'tutar' ? l : [...l].sort((a, b) => siralama === 'devir' ? b.devir - a.devir : (b.devirGun ?? 1e9) - (a.devirGun ?? 1e9));
  }, [veri, ara, siralama]); // eslint-disable-line react-hooks/exhaustive-deps
  const o = veri?.ozet;
  const cevir = (id: number) => setAcik(a => { const n = new Set(a); n.has(id) ? n.delete(id) : n.add(id); return n });
  const mxTrend = Math.max(1, ...(veri?.trend ?? []).map(t => t.olu));

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Ölü Stok / Devir Hızı İcmali</h1><span className="yol">Stok &amp; Hizmet › İcmaller › Ölü Stok / Devir Hızı İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Ölü Stok / Devir Hızı İcmali" dosyaAdi={`Ölü Stok İcmali ${tarih}`} devre={!veri}>
          {veri && <OluA4 v={veri} satirlar={oluler} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
        </CiktiMenusu>
        <button onClick={() => git('/stok-transfer')}>🔄 Stok Transfer</button>
        <span className="sp" />
        <button onClick={() => git('/stok-deger-icmali')}>📦 Stok Değer İcmali</button>
        <button onClick={() => git('/stok-hareket-icmali')}>🔁 Stok Hareket İcmali</button>
        <button onClick={() => git('/stok-kritik-stok-icmali')}>🚨 Kritik Stok</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Tarih itibarıyla:
          <input type="date" value={tarih} max={bugunYerel()} onChange={e => e.target.value && degistir({ tarih: e.target.value })} /></div>
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
        <span className="ki-soluk">Ölü eşiği</span>
        <div className="si-seg">
          {[90, 180, 365].map(g => <button key={g} type="button" className={esik === g ? 'on' : ''} onClick={() => degistir({ esik: g === 180 ? '' : String(g) })}>{g} gün</button>)}
        </div>
        <span className="ki-soluk">Hareket sayılan</span>
        <div className="si-seg">
          <button type="button" className={!her ? 'on' : ''} onClick={() => degistir({ hareket: '' })}>Yalnız çıkış</button>
          <button type="button" className={her ? 'on' : ''} onClick={() => degistir({ hareket: 'her' })}>Her hareket</button>
        </div>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Ölü Stok Değeri" deg={kisaTl(o.oluDeger)} alt={`${o.oluKalem} kalem · ${esik}+ gün ${her ? 'hareketsiz' : 'çıkışsız'}`} sinif={o.oluKalem ? 'teh' : ''} />
          <Kutu bas="Ölü Oranı" deg={oran(o.oluOran)} alt={`stok değerinin · önceki ay sonu ${oran(o.oncekiOran)}`} sinif={o.oluOran ? 'uy' : ''} />
          <Kutu bas="Devir Hızı" deg={o.devir.toLocaleString('tr-TR')} alt="yılda · çıkan maliyet / ort. stok" />
          <Kutu bas="Stokta Kalma" deg={o.devirGun ? `${o.devirGun} gün` : '—'} alt="365 / devir hızı" />
          <Kutu bas="Hiç Çıkmamış" deg={sayi(o.hicCikmayan)} alt={`ölü kalem · ${kisaTl(o.hicCikmayanDeger)}`} sinif="mor" />
          <Kutu bas={`Yavaş (${Math.round(esik / 2) + 1}–${esik} gün)`} deg={kisaTl(o.yavasDeger)} alt={`${o.yavasKalem} kalem · ölüye aday`} sinif={o.yavasKalem ? 'uy' : ''} />
          <Kutu bas="Ölü + SKT Yakın" deg={sayi(o.oluSktYakin)} alt={`kalem · ${esik} gün içinde miat · ${kisaTl(o.oluSktYakinDeger)}`} sinif={o.oluSktYakin ? 'teh' : ''} />
          <Kutu bas="A Sınıfı" deg={sayi(o.aKalem)} alt={`kalem · çıkışın %80'i · ${sayi(o.kalem)} bakiyeli`} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['olu', 'Ölü Stoklar', oluler.length], ['devir', 'Devir Hızı', null], ['abc', 'ABC × Hız', null], ['trend', 'Ölü Stok Gelişimi', null]]} />

            {(sekme === 'olu' || sekme === 'devir') && (
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Stok kodu, adı ya da kategori…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                {sekme === 'olu' && <span className="ki-soluk">satıra tıkla: depo kırılımı ve öneri gerekçesi · ada tıkla: stok kartı · tutara göre sıralı</span>}
                {sekme === 'devir' && <>
                  <span className="ki-soluk">Sırala:</span>
                  <div className="si-seg">
                    {([['tutar', 'Tutar'], ['devir', 'Devir'], ['gun', 'Gün']] as const).map(([k, a]) =>
                      <button key={k} type="button" className={siralama === k ? 'on' : ''} onClick={() => setSiralama(k)}>{a}</button>)}
                  </div></>}
              </div>
            )}

            {sekme === 'olu' && <>
              <table className="hi-tablo">
                <thead><tr><th>Kod</th><th>Stok Adı</th><th>Kategori</th><th className="sag">Miktar</th><th className="sag">Tutar</th>
                  <th>Son Giriş</th><th>Son Çıkış</th><th className="orta">{her ? 'Hareketsiz' : 'Çıkışsız'}</th><th>En Yakın SKT</th><th>ABC</th><th>Öneri</th></tr></thead>
                <tbody>
                  {oluler.length === 0 && <tr><td colSpan={11} className="bos">
                    {esik} günden uzun {her ? 'hareketsiz' : 'çıkışsız'} bakiyeli kalem yok.
                    {' '}Stok hareket geçmişi kısaysa (ör. aktarımla gelen devir) bu liste zamanla dolar.</td></tr>}
                  {oluler.slice(0, 1000).map(x => <OluSatiri key={x.id} x={x} acik={acik.has(x.id)} cevir={cevir} kartAc={kartAc} tarih={veri.tarih} esik={esik} />)}
                  <tr className="top"><td colSpan={4}>Toplam ({sayi(oluler.length)} kalem)</td><td className="sag">{tl(oluler.reduce((t, x) => t + x.tutar, 0))}</td><td colSpan={6} /></tr>
                </tbody>
              </table>
              <div className="ki-soluk si-not">
                Öneri sırası: SKT eşikten önce doluyorsa <b>iade / imha</b> · başka depoda aynı stok son 90 günde çıkıyorsa <b>transfer</b> ·
                son alış 12 aydan yeniyse <b>tedarikçiye iade</b> · maliyeti yoksa <b>sayımla doğrula</b> · kalanında <b>kampanya / fiyat</b>.
                Öneri yalnız yol gösterir; belgeyi kullanıcı açar.
              </div>
            </>}

            {sekme === 'devir' && <>
              <table className="hi-tablo">
                <thead><tr><th>Kod</th><th>Stok Adı</th><th className="sag">Ort. Stok</th><th className="sag">Çıkan (12 ay)</th><th className="sag">Devir</th>
                  <th className="sag">Gün</th><th style={{ width: 150 }}>Hız</th><th>Sınıf</th><th>ABC</th></tr></thead>
                <tbody>
                  {devir.slice(0, 1000).map(x => {
                    const [ad, sinif] = SINIF[x.sinif];
                    return (
                      <tr key={x.id}><td>{x.kod}</td><td><span className="lnk" onClick={() => kartAc(x.id)}>{x.ad}</span></td>
                        <td className="sag">{sayi(x.ortalamaStok)}</td><td className="sag">{sayi(x.cikan12)}</td>
                        <td className={'sag' + (x.devir >= 6 ? ' si-yesil' : x.devir < 0.5 ? ' kir' : '')}><b>{x.devir.toLocaleString('tr-TR')}</b></td>
                        <td className={'sag' + ((x.devirGun ?? 0) > 365 ? ' kir' : '')}>{x.devirGun ?? '—'}</td>
                        <td><Cubuk yuzde={Math.min(100, (x.devir / 15) * 100)} renk={x.sinif === 'olu' ? '#c0413d' : x.sinif === 'yavas' ? '#d39a2c' : x.sinif === 'hizli' ? '#2e7d46' : undefined} /></td>
                        <td><span className={'bo-rz ' + sinif}>{ad}</span></td><td>{x.abc}</td></tr>
                    );
                  })}
                </tbody>
              </table>
              <div className="ki-soluk si-not">
                Devir = son 12 ayın çıkışı / ay sonu bakiyelerinin ortalaması (tek noktadan değil). Gün = 365 / devir. Sınıf: hızlı ≥ 6 · normal 2–6 ·
                yavaş &lt; 2 · ölü = eşikten uzun {her ? 'hareketsiz' : 'çıkışsız'}. Transfer çıkış sayılmaz.
              </div>
            </>}

            {sekme === 'abc' && (
              <div className="si-iki">
                <Kutucuk baslik="ABC × Hız" not="hücre = kalem · stok değeri">
                  <table className="hi-tablo"><thead><tr><th>Çıkış payı \ Hız</th>{['hizli', 'normal', 'yavas', 'olu'].map(s => <th key={s} className="sag">{SINIF[s][0]}</th>)}</tr></thead>
                    <tbody>{veri.matris.map(m => {
                      const mx = Math.max(1, ...veri.matris.flatMap(z => z.hucreler.map(h => h.tutar)));
                      return (
                        <tr key={m.abc}><td><b>{m.abc}</b> · {m.abc === 'A' ? "çıkışın %80'i" : m.abc === 'B' ? 'sonraki %15' : 'son %5'}</td>
                          {m.hucreler.map(h => <td key={h.sinif} className="si-isi" style={{ background: m.abc === 'C' && h.sinif === 'olu' && h.kalem ? '#f3c4bf' : isiRengi(h.tutar, mx) }}>
                            {h.kalem ? `${h.kalem} · ${kisaTl(h.tutar)}` : '—'}</td>)}</tr>
                      );
                    })}</tbody></table>
                  <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>C × Ölü tasfiye adayı; A × Hızlı kalemlerde kritik stok seviyesi tanımlı olmalı.</div>
                </Kutucuk>
                <Kutucuk baslik="Pareto" not="kalem payı → çıkış payı">
                  <table className="hi-tablo"><thead><tr><th>Sınıf</th><th className="sag">Kalem</th><th className="sag">Kalem %</th><th className="sag">Çıkış %</th><th style={{ width: 150 }} /></tr></thead>
                    <tbody>{veri.pareto.map(p => (
                      <tr key={p.abc}><td>{p.abc}</td><td className="sag">{p.kalem}</td><td className="sag">{oran(p.kalemOran)}</td><td className="sag">{oran(p.cikisOran)}</td>
                        <td><Cubuk yuzde={p.cikisOran} /></td></tr>))}</tbody></table>
                  <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>ABC: son 12 ay çıkış tutarına (ortalama maliyetle) göre; çıkışı olmayan kalem C.</div>
                </Kutucuk>
              </div>
            )}

            {sekme === 'trend' && (
              <Kutucuk baslik="Ölü stok gelişimi (ay sonları)" not="o gün eşikten uzun çıkışsız kalan stok değeri · bugünkü maliyetle">
                <table className="hi-tablo"><thead><tr><th>Ay sonu</th><th className="sag">Ölü stok</th><th className="sag">Kalem</th><th className="sag">Stok değeri</th>
                  <th className="sag">Oran</th><th style={{ width: 200 }} /></tr></thead>
                  <tbody>{veri.trend.map((t, i) => (
                    <tr key={t.tarih}><td>{i === veri.trend.length - 1 ? <b>{tarihT(t.tarih)} (bugün)</b> : ayYil(t.tarih)}</td>
                      <td className="sag">{tl(t.olu)}</td><td className="sag">{t.kalem}</td><td className="sag">{tl(t.deger)}</td><td className="sag">{oran(t.oran)}</td>
                      <td><Cubuk yuzde={(100 * t.olu) / mxTrend} renk={i === veri.trend.length - 1 ? '#c0413d' : undefined} /></td></tr>))}</tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>
                  Önceki ay sonundan bu yana ölüye düşen {o.buDonemDusen} kalem · ölüden çıkan (yeniden hareket gören) {o.buDonemCikan} kalem.
                  Geçmiş ay sonu bakiyeleri bugünkü bakiyeden sonraki hareketler geri sarılarak bulunur.
                </div>
              </Kutucuk>
            )}
          </div>
        </div>
      </>)}
    </div>
  );
}

function OluSatiri({ x, acik, cevir, kartAc, tarih, esik }: {
  x: OluStokSatiri; acik: boolean; cevir(id: number): void; kartAc(id: number): void; tarih: string; esik: number;
}) {
  const [ad, sinif] = ONERI[x.oneri];
  const sktYakin = x.enYakinSkt && (new Date(x.enYakinSkt).getTime() - new Date(tarih).getTime()) / 864e5 <= esik;
  return (
    <Fragment>
      <tr className="ac" onClick={() => cevir(x.id)}>
        <td><span className="ok">{acik ? '▾' : '▸'}</span>{x.kod}</td>
        <td><span className="lnk" onClick={e => { e.stopPropagation(); kartAc(x.id) }}>{x.ad}</span></td>
        <td>{x.kategori}</td><td className="sag">{sayi(x.miktar)}</td>
        <td className={'sag' + (x.birimMaliyet === 0 ? ' ki-soluk' : '')}><b>{tl(x.tutar)}</b></td>
        <td>{tarihT(x.sonGiris)}</td><td>{x.sonCikis ? tarihT(x.sonCikis) : <span className="ki-soluk">hiç</span>}</td>
        <td className="orta">{x.gun == null ? <span className="bo-rz kir">hareket yok</span>
          : x.hicCikmadi ? <span className="bo-rz mor">girişten beri · {x.gun} gün</span>
          : <span className={'bo-rz ' + (x.gun > 365 ? 'kir' : 'sari')}>{x.gun} gün</span>}</td>
        <td className={sktYakin ? 'kir' : ''}>{x.enYakinSkt ? ayYil(x.enYakinSkt) + (sktYakin ? ' ⚠' : '') : <span className="ki-soluk">—</span>}</td>
        <td>{x.abc}</td>
        <td><span className={'bo-rz ' + sinif}>{ad}</span></td>
      </tr>
      {acik && (
        <tr className="si-det"><td colSpan={11}>
          {x.depolar.map(d => `${d.depo} ${sayi(d.miktar)}`).join(' · ')}
          {x.oneriNot && <> &nbsp;·&nbsp; {x.oneriNot}</>}
          {x.tedarikci && x.oneri !== 'iade' && <> &nbsp;·&nbsp; son alış: {x.tedarikci} ({tarihT(x.sonAlisTarihi)})</>}
          {' '}· birim maliyet {tl(x.birimMaliyet)}
        </td></tr>
      )}
    </Fragment>
  );
}

function OluA4({ v, satirlar, antet, duzenleyen }: {
  v: Veri; satirlar: OluStokSatiri[]; antet: Record<string, unknown> | null; duzenleyen: string;
}) {
  const o = v.ozet;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>ÖLÜ STOK / DEVİR HIZI İCMALİ</h3>
      <div className="a4-hasta">
        <span>Tarih itibarıyla: <b>{tarihT(v.tarih)}</b></span><span>Eşik: {v.esik} gün · {v.hareket === 'her' ? 'her hareket' : 'yalnız çıkış'}</span>
        <span>Depo: {v.depo ? v.secim.depoListesi.find(d => d.id === v.depo)?.ad : 'Tümü'}</span>
        <span>Devir hızı {o.devir.toLocaleString('tr-TR')} · {o.devirGun ?? '—'} gün</span>
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Stok</th><th>Miktar</th><th>Tutar</th><th>Son çıkış</th><th>Öneri</th></tr></thead>
        <tbody>{satirlar.map(x => <tr key={x.id}><td>{x.kod} · {x.ad}</td><td>{sayi(x.miktar)}</td><td>{tl(x.tutar)}</td>
          <td>{x.sonCikis ? tarihT(x.sonCikis) : 'hiç'}</td><td>{ONERI[x.oneri][0]}</td></tr>)}</tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Stok değeri</td><td>{tl(o.deger)}</td></tr>
        <tr><td>Yavaş</td><td>{tl(o.yavasDeger)}</td></tr>
        <tr className="kalan ki-kalan"><td>ÖLÜ STOK ({oran(o.oluOran)})</td><td>{tl(o.oluDeger)} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Ölü = eşikten uzun süre {v.hareket === 'her' ? 'hareket' : 'çıkış'} görmemiş bakiyeli kalem · ortalama maliyetle · KDV hariç.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali İşler / Yönetim<br />Kaşe · İmza</div></div>
    </div>
  );
}

export default StokOluStokIcmali;
