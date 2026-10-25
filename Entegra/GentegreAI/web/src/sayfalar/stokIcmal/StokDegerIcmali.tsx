import { Fragment, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { StokDegerIcmali as Veri, StokDegerSatiri } from '../../api/uclar/stokIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import {
  ayYil, Cubuk, isiRengi, IZLEME_ADI, kisaTl, Kutu, Kutucuk, sayi, Sekmeler, STOK_ICMAL_STILI, tarihT, tl,
  useAntet, useStokKarti, useSuzgec,
} from './stokIcmalOrtak';

/**
 * STOK DEĞER İCMALİ `/stok-deger-icmali` (1173) - mockup Ekranlar/Stok/stok_deger_icmali.html.
 * "Depoda ne kadarlık mal var, nerede, ne kadar süredir duruyor?" Tarih itibarıyla bakiye ×
 * birim maliyet (ortalama maliyet varsayılan; son alış / satış fiyatı seçilebilir).
 */
type Sekme = 'stok' | 'kat' | 'yas' | 'dik';
const YONTEM: [Veri['yontem'], string][] = [['ort', 'Ortalama maliyet'], ['son', 'Son alış'], ['satis', 'Satış fiyatı']];

export function StokDegerIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const kartAc = useStokKarti();
  const tarih = arama.get('tarih') ?? bugunYerel();
  const depo = Number(arama.get('depo') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const yontem = (arama.get('yontem') ?? 'ort') as Veri['yontem'];
  const pasif = arama.get('pasif') === '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('stok');
  const [ara, setAra] = useState('');
  const [acik, setAcik] = useState<Set<number>>(new Set());

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ tarih, yontem });
    if (depo) q.set('depo', String(depo));
    if (kategori) q.set('kategori', String(kategori));
    if (pasif) q.set('pasif', '1');
    api.stokDegerIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [tarih, depo, kategori, yontem, pasif]);

  const satirlar = useMemo(() => {
    const q = ara.trim().toLocaleLowerCase('tr');
    return (veri?.stoklar ?? []).filter(s => !q || s.kod.toLocaleLowerCase('tr').includes(q) || s.ad.toLocaleLowerCase('tr').includes(q)
      || s.kategori.toLocaleLowerCase('tr').includes(q));
  }, [veri, ara]);
  const o = veri?.ozet;
  const enBuyuk = Math.max(1, ...(veri?.stoklar ?? []).map(s => s.tutar));
  const yontemAdi = YONTEM.find(y => y[0] === yontem)?.[1] ?? '';
  const dikkatSayi = veri ? veri.dikkat.eksi.length + veri.dikkat.maliyetsiz.length + veri.dikkat.lotUyumsuz.length : null;
  const cevir = (id: number) => setAcik(a => { const n = new Set(a); n.has(id) ? n.delete(id) : n.add(id); return n });
  const degisim = o ? o.deger - o.oncekiDeger : 0;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Stok Değer İcmali</h1><span className="yol">Stok &amp; Hizmet › İcmaller › Stok Değer İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Stok Değer İcmali" dosyaAdi={`Stok Değer İcmali ${tarih}`} devre={!veri}>
          {veri && <DegerA4 v={veri} satirlar={satirlar} antet={antet} duzenleyen={kullanici?.ad ?? ''} yontemAdi={yontemAdi} />}
        </CiktiMenusu>
        <span className="sp" />
        <button onClick={() => git('/stok-skt-icmali')}>⏳ SKT / Lot İcmali</button>
        <button onClick={() => git('/stok-sayim-fark-icmali')}>⚖ Sayım Fark İcmali</button>
        <button onClick={() => git('/stok-sayim')}>🧮 Stok Sayımları</button>
        <button onClick={() => git('/stok')}>📦 Stok Listesi</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Tarih itibarıyla:
          <input type="date" value={tarih} max={bugunYerel()} onChange={e => e.target.value && degistir({ tarih: e.target.value })} /></div>
        <div className="sel">🏬 Depo:
          <select value={depo} onChange={e => degistir({ depo: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.depoListesi ?? []).map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}
          </select></div>
        <div className="sel">🗂 Kategori:
          <select value={kategori} onChange={e => degistir({ kategori: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.kategoriler ?? []).map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
          </select></div>
        <div className="si-seg">
          {YONTEM.map(([k, ad]) => <button key={k} type="button" className={yontem === k ? 'on' : ''} onClick={() => degistir({ yontem: k === 'ort' ? '' : k })}>{ad}</button>)}
        </div>
        <label className="sel"><input type="checkbox" checked={pasif} onChange={e => degistir({ pasif: e.target.checked ? '1' : '' })} /> Pasif stoklar dahil</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.eksiKalem > 0 && <span className="bo-rz kir">Eksi bakiyeli: {o.eksiKalem} kalem</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Stok Değeri" deg={kisaTl(o.deger)} alt={`${yontemAdi.toLocaleLowerCase('tr')} · KDV hariç`} sinif="mor" />
          <Kutu bas="Kalem" deg={sayi(o.kalem)} alt={`bakiyesi olan / ${sayi(o.aktifStok)} aktif stok`} />
          <Kutu bas="Miktar" deg={sayi(o.miktar)} alt="ana birimde (karışık birim)" />
          <Kutu bas="Lotlu Kalem" deg={sayi(o.lotluKalem)} alt={`değerin %${o.deger > 0 ? Math.round((100 * o.lotluDeger) / o.deger) : 0}'i${veri.bugun ? ` · ${sayi(o.lotSayisi)} lot` : ''}`} />
          <Kutu bas="Hareketsiz (180+ gün)" deg={kisaTl(o.hareketsizDeger)} alt={`${o.hareketsizKalem} kalem · değerin %${o.deger > 0 ? ((100 * o.hareketsizDeger) / o.deger).toFixed(1).replace('.', ',') : 0}'i`} sinif={o.hareketsizDeger > 0 ? 'uy' : ''} />
          <Kutu bas="Maliyeti Tanımsız" deg={sayi(o.maliyetsiz)} alt="kalem · değere 0 ile girdi" sinif={o.maliyetsiz > 0 ? 'teh' : ''} />
          <Kutu bas="Eksi Bakiye" deg={sayi(o.eksiKalem)} alt={`kalem · ${sayi(o.eksiMiktar)} adet`} sinif={o.eksiKalem > 0 ? 'teh' : ''} />
          <Kutu bas="Önceki Ay Sonu" deg={kisaTl(o.oncekiDeger)} alt={`${tarihT(o.oncekiAySonu)} · ${degisim >= 0 ? '+' : '−'}${kisaTl(Math.abs(degisim))}`} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['stok', 'Stok Bazında', satirlar.length], ['kat', 'Kategori × Depo', null], ['yas', 'Stok Yaşı', null], ['dik', 'Dikkat', dikkatSayi]]} />

            {sekme === 'stok' && <>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Stok kodu, adı ya da kategori…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                <span className="ki-soluk">satıra tıkla: depo {veri.bugun ? 've lot ' : ''}kırılımı · ada tıkla: stok kartı</span>
              </div>
              <table className="hi-tablo">
                <thead><tr><th>Kod</th><th>Stok Adı</th><th>Kategori</th><th>Birim</th><th>İzleme</th>
                  <th className="sag">Miktar</th><th className="sag">Birim Maliyet</th><th className="sag">Tutar</th><th style={{ width: 110 }}>Pay</th>
                  <th>Son Giriş</th><th>Son Çıkış</th><th className="sag">Hareketsiz</th></tr></thead>
                <tbody>
                  {satirlar.length === 0 && <tr><td colSpan={12} className="bos">Bu süzgeçte bakiyesi olan stok yok.</td></tr>}
                  {satirlar.slice(0, 1000).map(s => <StokSatiri key={s.id} s={s} acik={acik.has(s.id)} cevir={cevir} kartAc={kartAc} enBuyuk={enBuyuk} />)}
                  <tr className="top"><td colSpan={5}>Toplam ({sayi(satirlar.length)} kalem)</td>
                    <td className="sag">{sayi(satirlar.reduce((t, s) => t + s.miktar, 0))}</td><td />
                    <td className="sag">{tl(satirlar.reduce((t, s) => t + s.tutar, 0))}</td><td colSpan={4} /></tr>
                </tbody>
              </table>
              <div className="ki-soluk si-not">
                Tutar = miktar × birim maliyet. Ortalama maliyet giriş belgelerinin ağırlıklı ortalaması (üretim maliyetiyle aynı kaynak);
                maliyeti olmayan kalem 0 ile toplanır ve Dikkat'te listelenir. Geçmiş tarihte bakiye, o tarihten sonraki hareketler geri sarılarak bulunur.
              </div>
            </>}

            {sekme === 'kat' && (
              <table className="hi-tablo">
                <thead><tr><th>Kategori</th>{veri.depolar.map(d => <th key={d.id} className="sag">{d.ad}</th>)}
                  <th className="sag">Toplam</th><th className="sag">Kalem</th><th className="sag">Pay</th></tr></thead>
                <tbody>
                  {veri.katDepo.map(k => {
                    const mx = Math.max(1, ...veri.katDepo.flatMap(x => x.hucreler));
                    return (
                      <tr key={k.kategori}><td>{k.kategori}</td>
                        {k.hucreler.map((h, i) => <td key={i} className="si-isi" style={{ background: isiRengi(h, mx) }}>{h ? tl(h) : '—'}</td>)}
                        <td className="sag"><b>{tl(k.toplam)}</b></td><td className="sag">{k.kalem}</td>
                        <td className="sag">%{o.deger > 0 ? ((100 * k.toplam) / o.deger).toFixed(1).replace('.', ',') : '0'}</td></tr>
                    );
                  })}
                  <tr className="top"><td>Toplam</td>
                    {veri.depolar.map((d, i) => <td key={d.id} className="sag">{tl(veri.katDepo.reduce((t, k) => t + (k.hucreler[i] ?? 0), 0))}</td>)}
                    <td className="sag">{tl(o.deger)}</td><td className="sag">{o.kalem}</td><td className="sag">%100</td></tr>
                </tbody>
              </table>
            )}

            {sekme === 'yas' && (
              <div className="si-iki">
                <Kutucuk baslik="Son hareketten bu yana (hareketsizlik)" not="tutar · kalem">
                  <table className="hi-tablo"><thead><tr><th>Dilim</th><th className="sag">Tutar</th><th className="sag">Kalem</th><th style={{ width: 140 }}>Pay</th></tr></thead>
                    <tbody>{veri.yas.map((d, i) => (
                      <tr key={d.ad}><td className={i === 3 ? 'kir' : ''}>{d.ad}</td><td className="sag">{tl(d.tutar)}</td><td className="sag">{d.kalem}</td>
                        <td><Cubuk yuzde={o.deger > 0 ? (100 * d.tutar) / o.deger : 0} renk={i === 3 ? '#c0413d' : undefined} /></td></tr>))}
                    </tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Devir hızı (son 12 ay)" not="çıkan maliyet / stok değeri">
                  <table className="hi-tablo"><thead><tr><th>Kategori</th><th className="sag">Devir</th><th className="sag">Gün karşılığı</th></tr></thead>
                    <tbody>
                      {veri.devir.length === 0 && <tr><td colSpan={3} className="bos">Çıkış hareketi yok.</td></tr>}
                      {veri.devir.map(d => (
                        <tr key={d.kategori}><td>{d.kategori}</td><td className="sag">{d.devir ? d.devir.toLocaleString('tr-TR') : '—'}</td>
                          <td className={'sag' + (d.gun && d.gun > 365 ? ' kir' : '')}>{d.gun ? `${d.gun} gün` : '—'}</td></tr>))}
                    </tbody></table>
                  <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Gün karşılığı = 365 / devir: mevcut stok bu hızla kaç günde biter.</div>
                </Kutucuk>
              </div>
            )}

            {sekme === 'dik' && (
              <div className="si-iki">
                <Kutucuk baslik="⛔ Eksi bakiye" not="depoda olmayan mal çıkmış">
                  <table className="hi-tablo"><thead><tr><th>Stok</th><th>Depo</th><th className="sag">Bakiye</th><th>Son çıkış</th></tr></thead>
                    <tbody>{veri.dikkat.eksi.length === 0 ? <tr><td colSpan={4} className="bos">Yok.</td></tr>
                      : veri.dikkat.eksi.map((x, i) => <tr key={i}><td><span className="lnk" onClick={() => kartAc(x.id)}>{x.kod}</span> · {x.ad}</td><td>{x.depo}</td>
                        <td className="sag kir">{sayi(x.miktar)}</td><td>{tarihT(x.sonCikis)}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="⚠ Maliyeti tanımsız" not="değere 0 girdi · alış belgesi yok">
                  <table className="hi-tablo"><thead><tr><th>Stok</th><th className="sag">Miktar</th><th>Son giriş</th></tr></thead>
                    <tbody>{veri.dikkat.maliyetsiz.length === 0 ? <tr><td colSpan={3} className="bos">Yok.</td></tr>
                      : veri.dikkat.maliyetsiz.map(x => <tr key={x.id}><td><span className="lnk" onClick={() => kartAc(x.id)}>{x.kod}</span> · {x.ad}</td>
                        <td className="sag">{sayi(x.miktar)}</td><td>{x.sonGiris ? tarihT(x.sonGiris) : 'devir (aktarım)'}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="🏷 Lot toplamı stok bakiyesini tutmuyor" not={veri.bugun ? 'sayımda "lotsuz bakiye" satırı çıkar' : 'yalnız bugün için'}>
                  <table className="hi-tablo"><thead><tr><th>Stok</th><th className="sag">Stok</th><th className="sag">Lot toplamı</th><th className="sag">Fark</th></tr></thead>
                    <tbody>{veri.dikkat.lotUyumsuz.length === 0 ? <tr><td colSpan={4} className="bos">Yok.</td></tr>
                      : veri.dikkat.lotUyumsuz.map(x => <tr key={x.id}><td><span className="lnk" onClick={() => kartAc(x.id)}>{x.kod}</span> · {x.ad}</td>
                        <td className="sag">{sayi(x.miktar)}</td><td className="sag">{sayi(x.lotToplam)}</td><td className="sag kir">{sayi(x.lotsuz)}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="💤 En değerli hareketsiz kalemler (180+ gün)">
                  <table className="hi-tablo"><thead><tr><th>Stok</th><th className="sag">Tutar</th><th>Son hareket</th></tr></thead>
                    <tbody>{veri.dikkat.hareketsiz.length === 0 ? <tr><td colSpan={3} className="bos">Yok.</td></tr>
                      : veri.dikkat.hareketsiz.map(x => <tr key={x.id}><td><span className="lnk" onClick={() => kartAc(x.id)}>{x.kod}</span> · {x.ad}</td>
                        <td className="sag">{tl(x.tutar)}</td><td className="kir">{x.hareketsizGun == null ? 'hiç hareket yok' : `${x.hareketsizGun} gün`}</td></tr>)}</tbody></table>
                </Kutucuk>
              </div>
            )}
          </div>
        </div>
      </>)}
    </div>
  );
}

function StokSatiri({ s, acik, cevir, kartAc, enBuyuk }: {
  s: StokDegerSatiri; acik: boolean; cevir(id: number): void; kartAc(id: number): void; enBuyuk: number;
}) {
  const kirilim = s.depolar.length > 1 || s.lotlar.length > 0;
  const gun = s.hareketsizGun;
  return (
    <Fragment>
      <tr className={kirilim ? 'ac' : ''} onClick={() => kirilim && cevir(s.id)}>
        <td>{kirilim && <span className="ok">{acik ? '▾' : '▸'}</span>}{s.kod}</td>
        <td><span className="lnk" onClick={e => { e.stopPropagation(); kartAc(s.id) }}>{s.ad}</span></td>
        <td>{s.kategori}</td><td>{s.birim}</td>
        <td>{s.izleme ? <span className="bo-rz mavi">{IZLEME_ADI[s.izleme] ?? 'İzlemli'}</span> : <span className="ki-soluk">—</span>}</td>
        <td className={'sag' + (s.miktar < 0 ? ' kir' : '')}>{sayi(s.miktar)}</td>
        <td className={'sag' + (s.birimMaliyet === 0 ? ' ki-soluk' : '')}>{tl(s.birimMaliyet)}</td>
        <td className={'sag' + (s.tutar < 0 ? ' kir' : '')}><b>{tl(s.tutar)}</b></td>
        <td><Cubuk yuzde={(100 * Math.max(0, s.tutar)) / enBuyuk} /></td>
        <td>{tarihT(s.sonGiris)}</td><td>{tarihT(s.sonCikis)}</td>
        <td className="sag">{gun == null ? <span className="bo-rz kir">hareket yok</span>
          : gun > 180 ? <span className="bo-rz kir">{gun} gün</span> : gun > 90 ? <span className="bo-rz sari">{gun} gün</span> : <span className="ki-soluk">—</span>}</td>
      </tr>
      {acik && kirilim && (
        <tr className="si-det"><td colSpan={12}>
          {s.depolar.map(d => `${d.depo} ${sayi(d.miktar)}`).join(' · ')}
          {s.lotlar.length > 0 && <> &nbsp;·&nbsp; lotlar: {s.lotlar.slice(0, 30).map(l => `${l.lot || 'lotsuz'} (${ayYil(l.skt)}) ${sayi(l.kalan)}`).join(' · ')}
            {s.lotlar.length > 30 && ` … ${s.lotlar.length - 30} lot daha`}</>}
          {Math.abs(s.lotsuz) > 0.00001 && <span className="kir"> · lotsuz bakiye {sayi(s.lotsuz)} — lot toplamı stok bakiyesini tutmuyor</span>}
        </td></tr>
      )}
    </Fragment>
  );
}

function DegerA4({ v, satirlar, antet, duzenleyen, yontemAdi }: {
  v: Veri; satirlar: StokDegerSatiri[]; antet: Record<string, unknown> | null; duzenleyen: string; yontemAdi: string;
}) {
  const o = v.ozet;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>STOK DEĞER İCMALİ</h3>
      <div className="a4-hasta">
        <span>Tarih itibarıyla: <b>{tarihT(v.tarih)}</b></span><span>Değerleme: {yontemAdi}</span>
        <span>Depo: {v.depolar.map(d => d.ad).join(', ') || '—'}</span><span>Kalem: {sayi(o.kalem)} · Miktar {sayi(o.miktar)}</span>
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Kategori</th>{v.depolar.map(d => <th key={d.id}>{d.ad}</th>)}<th>Toplam</th><th>Pay</th></tr></thead>
        <tbody>{v.katDepo.map(k => (
          <tr key={k.kategori}><td>{k.kategori}</td>{k.hucreler.map((h, i) => <td key={i}>{h ? tl(h) : '—'}</td>)}
            <td>{tl(k.toplam)}</td><td>%{o.deger > 0 ? ((100 * k.toplam) / o.deger).toFixed(1).replace('.', ',') : '0'}</td></tr>))}</tbody>
      </table>
      <div className="ml-alt" style={{ fontWeight: 'bold', margin: '8px 0 2px' }}>Stoklar ({sayi(satirlar.length)})</div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Stok</th><th>Miktar</th><th>Birim maliyet</th><th>Tutar</th></tr></thead>
        <tbody>{satirlar.map(s => <tr key={s.id}><td>{s.kod} · {s.ad}</td><td>{sayi(s.miktar)}</td><td>{tl(s.birimMaliyet)}</td><td>{tl(s.tutar)}</td></tr>)}</tbody>
      </table>
      <table className="a4-toplam"><tbody>
        {v.depolar.map((d, i) => <tr key={d.id}><td>{d.ad}</td><td>{tl(v.katDepo.reduce((t, k) => t + (k.hucreler[i] ?? 0), 0))}</td></tr>)}
        <tr><td>Hareketsiz (180+ gün)</td><td>{tl(o.hareketsizDeger)}</td></tr>
        <tr className="kalan ki-kalan"><td>STOK DEĞERİ</td><td>{tl(o.deger)} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Miktar depo bakiyesinden (geçmiş tarihte sonraki hareketler geri sarılır); birim maliyet {yontemAdi.toLocaleLowerCase('tr')}. KDV hariç.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali İşler / Yönetim<br />Kaşe · İmza</div></div>
    </div>
  );
}

export default StokDegerIcmali;
