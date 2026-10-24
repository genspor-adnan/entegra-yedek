import { Fragment, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { SayimFarkIcmali as Veri } from '../../api/uclar/stokIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import {
  IZLEME_ADI, kisaTl, Kutu, Kutucuk, sayi, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useStokKarti, useSuzgec,
} from './stokIcmalOrtak';

/**
 * SAYIM FARK İCMALİ `/stok-sayim-fark-icmali` (1173) - mockup Ekranlar/Stok/stok_sayim_fark_icmali.html.
 * "Sayımlar ne kadar fark çıkardı, hangi kalemler sürekli eksik, hangi depo uzun süredir
 * sayılmadı?" Tutar = fark × satırın sayım anındaki birim maliyeti (kesilen fişlerle aynı).
 */
type Sekme = 'sayim' | 'kalem' | 'kir' | 'dik';
const yilBasi = () => `${new Date().getFullYear()}-01-01`;
const fark = (n: number) => `${n > 0 ? '+' : ''}${sayi(n)}`;
const tutarSinifi = (n: number) => (n > 0.005 ? 'si-yesil' : n < -0.005 ? 'kir' : '');
const DURUM: Record<string, [string, string]> = { tekrar: ['Tekrar eden eksik', 'kir'], lot: ['Lot karışıklığı', 'sari'], tek: ['Tek sefer', 'ok'] };

export function StokSayimFarkIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const kartAc = useStokKarti();
  const bas = arama.get('bas') ?? yilBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const depo = Number(arama.get('depo') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const acikDahil = arama.get('acik') === '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('sayim');
  const [acik, setAcik] = useState<Set<number>>(new Set());

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit });
    if (depo) q.set('depo', String(depo));
    if (kategori) q.set('kategori', String(kategori));
    if (acikDahil) q.set('acik', '1');
    api.stokSayimFarkIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, depo, kategori, acikDahil]);

  const o = veri?.ozet;
  const sayimAc = (id: number) => git(`/stok-sayim/${id}`);
  const fisAc = (yol: string, id: number | null) => id && git(`/${yol}/${id}`);
  const dikkatSayi = veri ? veri.dikkat.tekrar.length + veri.dikkat.lotsuz.length + veri.dikkat.sayilmayan.length : null;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Sayım Fark İcmali</h1><span className="yol">Stok &amp; Hizmet › Sayım Fark İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Sayım Fark İcmali" dosyaAdi={`Sayım Fark İcmali ${bas} ${bit}`} devre={!veri}>
          {veri && <FarkA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
        </CiktiMenusu>
        <span className="sp" />
        <button onClick={() => git('/stok-sayim/yeni')}>🧮 Yeni Sayım</button>
        <button onClick={() => git('/stok-sayim')}>📋 Stok Sayımları</button>
        <button onClick={() => git('/stok-deger-icmali')}>📦 Stok Değer İcmali</button>
        <button onClick={() => git('/stok-skt-icmali')}>⏳ SKT / Lot İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Dönem:
          <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value })} /> –
          <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} /></div>
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
          <button type="button" className={!acikDahil ? 'on' : ''} onClick={() => degistir({ acik: '' })}>Kapanan sayımlar</button>
          <button type="button" className={acikDahil ? 'on' : ''} onClick={() => degistir({ acik: '1' })}>Açıklar dahil</button>
        </div>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.tekrar > 0 && <span className="bo-rz kir">Tekrar eden eksik: {o.tekrar} kalem</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Sayım" deg={sayi(o.sayim)} alt={`${o.kapanan} kapandı · ${o.acik} açık`} />
          <Kutu bas="Sayılan Satır" deg={sayi(o.sayilanSatir)} alt="lot satırları dahil" />
          <Kutu bas="Doğruluk" deg={o.dogruluk == null ? '—' : `%${o.dogruluk.toLocaleString('tr-TR')}`} alt="sistemle aynı çıkan satır" sinif={o.dogruluk != null && o.dogruluk >= 95 ? 'iyi' : 'uy'} />
          <Kutu bas="Sayım Fazlası" deg={`+${kisaTl(o.fazla)}`} alt={`${o.fazlaKalem} satır · giriş fişi`} sinif="iyi" />
          <Kutu bas="Sayım Eksiği" deg={kisaTl(o.eksik)} alt={`${o.eksikKalem} satır · çıkış fişi`} sinif={o.eksikKalem ? 'teh' : ''} />
          <Kutu bas="Net Fark" deg={kisaTl(o.net)} alt="fazla + eksik" sinif="mor" />
          <Kutu bas="Tekrar Eden" deg={sayi(o.tekrar)} alt="kalem 2+ sayımda eksik" sinif={o.tekrar ? 'uy' : ''} />
          <Kutu bas="Lotsuz Fark" deg={sayi(o.lotsuzFark)} alt="satır · fişlenemez" sinif={o.lotsuzFark ? 'uy' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['sayim', 'Sayım Bazında', veri.sayimlar.length], ['kalem', 'Kalem Bazında', veri.kalemler.length], ['kir', 'Kırılımlar', null], ['dik', 'Dikkat', dikkatSayi]]} />

            {sekme === 'sayim' && <>
              <table className="hi-tablo">
                <thead><tr><th>Sayım No</th><th>Tarih</th><th>Depo</th><th>Kapsam</th><th>Durum</th>
                  <th className="sag">Satır</th><th className="sag">Sayılan</th><th className="sag">Fark Var</th>
                  <th className="sag">Fazla ₺</th><th className="sag">Eksik ₺</th><th className="sag">Net ₺</th><th>Fişler</th></tr></thead>
                <tbody>
                  {veri.sayimlar.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde {acikDahil ? '' : 'kapanan '}sayım yok.{!acikDahil && ' (Açık sayımları görmek için "Açıklar dahil".)'}</td></tr>}
                  {veri.sayimlar.map(y => (
                    <Fragment key={y.id}>
                      <tr className="ac" onClick={() => setAcik(a => { const n = new Set(a); n.has(y.id) ? n.delete(y.id) : n.add(y.id); return n })}>
                        <td><span className="ok">{y.farkVar ? (acik.has(y.id) ? '▾' : '▸') : ''}</span><span className="lnk" onClick={e => { e.stopPropagation(); sayimAc(y.id) }}>{y.no}</span></td>
                        <td>{tarihT(y.tarih)}</td><td>{y.depo}</td><td>{y.kapsam}</td>
                        <td>{y.durum === 1 ? <span className="bo-rz ok">Kapandı</span> : <span className="bo-rz mavi">Açık</span>}</td>
                        <td className="sag">{sayi(y.satir)}</td><td className="sag">{sayi(y.sayilan)}</td><td className="sag">{y.farkVar}</td>
                        <td className="sag si-yesil">{y.fazla ? `+${tl(y.fazla)}` : '—'}</td><td className="sag kir">{y.eksik ? tl(y.eksik) : '—'}</td>
                        <td className={'sag ' + tutarSinifi(y.net)}><b>{tl(y.net)}</b></td>
                        <td>{y.girisId && <span className="lnk" onClick={e => { e.stopPropagation(); fisAc('giris-fis', y.girisId) }}>G {y.girisNo}</span>}
                          {y.girisId && y.cikisId && ' · '}
                          {y.cikisId && <span className="lnk" onClick={e => { e.stopPropagation(); fisAc('cikis-fis', y.cikisId) }}>Ç {y.cikisNo}</span>}
                          {!y.girisId && !y.cikisId && <span className="ki-soluk">—</span>}</td>
                      </tr>
                      {acik.has(y.id) && y.farklar.length > 0 && (
                        <tr className="si-det"><td colSpan={12}>
                          {y.farklar.map(f => `${f.kod}${f.lot ? ` lot ${f.lot}` : ''} ${fark(f.fark)} (${tl(f.tutar)})`).join('  ·  ')}
                          {y.durum === 0 && <span className="ki-soluk"> — açık sayım: rakamlar anlık, fiş kesilmedi</span>}</td></tr>)}
                    </Fragment>
                  ))}
                  {veri.sayimlar.length > 0 && (
                    <tr className="top"><td colSpan={5}>Toplam ({veri.sayimlar.length} sayım)</td>
                      <td className="sag">{sayi(veri.sayimlar.reduce((t, y) => t + y.satir, 0))}</td><td className="sag">{sayi(o.sayilanSatir)}</td>
                      <td className="sag">{veri.sayimlar.reduce((t, y) => t + y.farkVar, 0)}</td>
                      <td className="sag">+{tl(o.fazla)}</td><td className="sag">{tl(o.eksik)}</td><td className="sag">{tl(o.net)}</td><td /></tr>)}
                </tbody>
              </table>
              <div className="ki-soluk si-not">Tutar = fark × satırın sayım anındaki birim maliyeti — kapanan sayımın rakamı sonradan değişmez, kesilen fişlerle aynıdır. Doğruluk yalnız sayılan satırlardan.</div>
            </>}

            {sekme === 'kalem' && <>
              <table className="hi-tablo">
                <thead><tr><th>Stok</th><th>Kategori</th><th>İzleme</th><th className="sag">Sayım</th><th className="sag">Fark Çıkan</th>
                  <th className="sag">Toplam Fark</th><th className="sag">Net ₺</th><th>Son fark</th><th>Durum</th></tr></thead>
                <tbody>
                  {veri.kalemler.length === 0 && <tr><td colSpan={9} className="bos">Fark çıkan kalem yok.</td></tr>}
                  {veri.kalemler.map(k => {
                    const [ad, sinif] = DURUM[k.durum];
                    return (
                      <tr key={k.stokId}><td><span className="lnk" onClick={() => kartAc(k.stokId)}>{k.kod}</span> · {k.ad}</td><td>{k.kategori}</td>
                        <td>{k.izleme ? <span className="bo-rz mavi">{IZLEME_ADI[k.izleme] ?? 'İzlemli'}</span> : <span className="ki-soluk">—</span>}</td>
                        <td className="sag">{k.sayim}</td><td className="sag"><b>{k.farkCikan}</b></td>
                        <td className={'sag ' + tutarSinifi(k.toplamFark)}>{fark(k.toplamFark)}</td><td className={'sag ' + tutarSinifi(k.net)}>{tl(k.net)}</td>
                        <td>{tarihT(k.sonTarih)} · {fark(k.sonFark)}</td><td><span className={'bo-rz ' + sinif}>{ad}</span></td></tr>
                    );
                  })}
                </tbody>
              </table>
              <div className="ki-soluk si-not"><b>Lot karışıklığı:</b> stok toplamı tutuyor ama bir lotta fazla, diğerinde eksik — mal doğru, lot seçimi yanlış yapılmış.</div>
            </>}

            {sekme === 'kir' && (
              <div className="si-iki">
                <Kutucuk baslik="Kategori bazında">
                  <table className="hi-tablo"><thead><tr><th>Kategori</th><th className="sag">Sayılan</th><th className="sag">Fark kalem</th><th className="sag">Net ₺</th><th className="sag">Doğruluk</th></tr></thead>
                    <tbody>{veri.kirilim.kategori.map(k => <tr key={k.ad}><td>{k.ad}</td><td className="sag">{sayi(k.sayilan)}</td><td className="sag">{k.farkKalem}</td>
                      <td className={'sag ' + tutarSinifi(k.net)}>{tl(k.net)}</td><td className="sag">%{k.dogruluk.toLocaleString('tr-TR')}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Depo bazında">
                  <table className="hi-tablo"><thead><tr><th>Depo</th><th className="sag">Sayım</th><th className="sag">Fazla ₺</th><th className="sag">Eksik ₺</th><th className="sag">Net ₺</th><th>Son sayım</th></tr></thead>
                    <tbody>{veri.kirilim.depo.map(d => <tr key={d.ad}><td>{d.ad}</td><td className="sag">{d.sayim}</td><td className="sag si-yesil">+{tl(d.fazla)}</td>
                      <td className="sag kir">{tl(d.eksik)}</td><td className={'sag ' + tutarSinifi(d.net)}>{tl(d.net)}</td><td>{tarihT(d.son)}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Sayan bazında" not="satırı sayan kullanıcı">
                  <table className="hi-tablo"><thead><tr><th>Sayan</th><th className="sag">Satır</th><th className="sag">Fark çıkan</th></tr></thead>
                    <tbody>{veri.kirilim.sayan.map(s => <tr key={s.ad}><td>{s.ad}</td><td className="sag">{sayi(s.satir)}</td><td className="sag">{s.farkCikan}</td></tr>)}</tbody></table>
                </Kutucuk>
              </div>
            )}

            {sekme === 'dik' && (
              <div className="si-iki">
                <Kutucuk baslik="🔁 Tekrar eden eksikler" not="2+ sayımda eksik · kayıp / kayıtsız çıkış">
                  <table className="hi-tablo"><thead><tr><th>Stok</th><th className="sag">Eksik çıkan</th><th className="sag">Toplam</th><th className="sag">Net ₺</th></tr></thead>
                    <tbody>{veri.dikkat.tekrar.length === 0 ? <tr><td colSpan={4} className="bos">Yok.</td></tr>
                      : veri.dikkat.tekrar.map(x => <tr key={x.stokId}><td><span className="lnk" onClick={() => kartAc(x.stokId)}>{x.kod}</span> · {x.ad}</td>
                        <td className="sag">{x.farkCikan} / {x.sayim}</td><td className="sag kir">{fark(x.toplamFark)}</td><td className="sag kir">{tl(x.net)}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="💰 En yüksek tutarlı farklar" not="ilk 10">
                  <table className="hi-tablo"><thead><tr><th>Sayım</th><th>Stok · Lot</th><th className="sag">Fark</th><th className="sag">₺</th></tr></thead>
                    <tbody>{veri.dikkat.yuksek.length === 0 ? <tr><td colSpan={4} className="bos">Yok.</td></tr>
                      : veri.dikkat.yuksek.map((x, i) => <tr key={i}><td>{x.sayim}</td><td>{x.kod}{x.lot ? ` · ${x.lot}` : ''}</td>
                        <td className={'sag ' + tutarSinifi(x.fark)}>{fark(x.fark)}</td><td className={'sag ' + tutarSinifi(x.tutar)}>{tl(x.tutar)}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="🏷 Lotsuz bakiyede fark" not="fişlenemez · lot bilgisi düzeltilmeli">
                  <table className="hi-tablo"><thead><tr><th>Sayım</th><th>Stok</th><th className="sag">Sistem</th><th className="sag">Sayılan</th></tr></thead>
                    <tbody>{veri.dikkat.lotsuz.length === 0 ? <tr><td colSpan={4} className="bos">Yok.</td></tr>
                      : veri.dikkat.lotsuz.map((x, i) => <tr key={i}><td>{x.sayim}</td><td>{x.kod} · {x.ad}</td><td className="sag">{sayi(x.sistem)}</td><td className="sag">{sayi(x.sayilan)}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="⏰ Uzun süredir sayılmayan depolar" not="180+ gün ya da hiç">
                  <table className="hi-tablo"><thead><tr><th>Depo</th><th>Son sayım</th></tr></thead>
                    <tbody>{veri.dikkat.sayilmayan.length === 0 ? <tr><td colSpan={2} className="bos">Yok.</td></tr>
                      : veri.dikkat.sayilmayan.map(d => <tr key={d.id}><td>{d.ad}</td><td className="kir">{d.son ? `${tarihT(d.son)} · ${d.gun} gün` : 'hiç sayılmadı'}</td></tr>)}</tbody></table>
                </Kutucuk>
              </div>
            )}
          </div>
        </div>
      </>)}
    </div>
  );
}

function FarkA4({ v, antet, duzenleyen }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string }) {
  const o = v.ozet;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>SAYIM FARK İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>Sayım: {o.sayim} ({o.kapanan} kapandı)</span>
        <span>Doğruluk: {o.dogruluk == null ? '—' : `%${o.dogruluk.toLocaleString('tr-TR')}`}</span><span>{v.acikDahil ? 'Açık sayımlar dahil' : 'Yalnız kapanan sayımlar'}</span>
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Sayım</th><th>Tarih</th><th>Depo</th><th>Fark kalem</th><th>Fazla</th><th>Eksik</th><th>Net</th></tr></thead>
        <tbody>{v.sayimlar.map(y => <tr key={y.id}><td>{y.no}{y.durum === 0 ? ' (açık)' : ''}</td><td>{tarihT(y.tarih)}</td><td>{y.depo}</td>
          <td>{y.farkVar}</td><td>{tl(y.fazla)}</td><td>{tl(y.eksik)}</td><td>{tl(y.net)}</td></tr>)}</tbody>
      </table>
      {v.kalemler.length > 0 && <>
        <div style={{ fontWeight: 'bold', margin: '8px 0 2px' }}>Fark çıkan kalemler ({v.kalemler.length})</div>
        <table className="a4-t si-a4t">
          <thead><tr><th>Stok</th><th>Sayım</th><th>Fark çıkan</th><th>Toplam fark</th><th>Net</th></tr></thead>
          <tbody>{v.kalemler.map(k => <tr key={k.stokId}><td>{k.kod} · {k.ad}{k.durum === 'tekrar' ? ' ⚠' : ''}</td><td>{k.sayim}</td>
            <td>{k.farkCikan}</td><td>{fark(k.toplamFark)}</td><td>{tl(k.net)}</td></tr>)}</tbody>
        </table></>}
      <table className="a4-toplam"><tbody>
        <tr><td>Sayım fazlası</td><td>{tl(o.fazla)}</td></tr>
        <tr><td>Sayım eksiği</td><td>{tl(o.eksik)}</td></tr>
        <tr className="kalan ki-kalan"><td>NET SAYIM FARKI</td><td>{tl(o.net)} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Fark ve tutar sayım satırından (sayım anı maliyeti); kapanan sayımlar kesilen fişlerle aynıdır. ⚠ = 2+ sayımda eksik çıkan kalem.</p>
      <div className="a4-imza"><div>Depo Sorumlusu<br />Ad Soyad · İmza</div><div>Mali İşler / Yönetim<br />Kaşe · İmza</div></div>
    </div>
  );
}

export default StokSayimFarkIcmali;
