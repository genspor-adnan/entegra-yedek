import { Fragment, useEffect, useMemo, useState } from 'react';
import { hataMetni } from '../../api/sozlesme';
import {
  karlilikIcmalUclari, type KarlilikIcmali as Veri, type KarlilikMusteriSatiri, type KarSeviye, type MaliyetKaynagi, type MatrisHucresi,
} from '../../api/uclar/karlilikIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import { ayAdi, ayBasi, DovizRozetleri, EkranA4, eksi, hazirDonem, kisa, sayi, simge, tarihT, TICARI_ICMAL_STILI, tl, useGezinti, yuzde } from './ticariIcmalOrtak';

/**
 * KÂRLILIK İCMALİ `/karlilik-icmali` - mockup Ekranlar/İcmal/karlilik_icmali.html (kararlar 25.10.2026).
 * "Kimden, hangi üründen, hangi temsilciyle para kazanıyoruz; nerede iskonto kârı yiyor; zararına
 * satış var mı?" Rakamlar SUNUCUDAN (KarlilikIcmalUclari): net satış belge dip toplamından, maliyet
 * satış anındaki ortalama maliyet, temsilci belgeden. Maliyetsiz satır rozetle, maliyet altı kırmızı,
 * hedef marjın altı sarı. Ekran toplamaz, yalnız gösterir.
 */
type Sekme = 'mus' | 'urn' | 'tem' | 'kat' | 'zar' | 'mtr' | 'trd' | 'onz';


const ISI = ['', '#eef5fd', '#d7e7fb', '#b7d3f4', '#8fb8ea'];
const ABC_SINIF: Record<string, string> = { A: 'ok', B: 'mavi', C: 'pas' };
const MARJ_ADI: Record<MatrisHucresi['marj'], string> = { dusuk: 'Düşük marj', orta: 'Orta marj', yuksek: 'Yüksek marj' };
const CIRO_ADI: Record<MatrisHucresi['ciro'], string> = { A: 'Yüksek ciro (A)', B: 'Orta ciro (B)', C: 'Düşük ciro (C)' };

/** Marj hücresi: maliyet altı kırmızı ⚠, hedef marjın altı sarı rozet (sınıflama sunucudan). */
function MarjHucresi({ marj, seviye, hedef }: { marj: number | null; seviye: KarSeviye; hedef: number }) {
  return (
    <td className={'sag' + (seviye === 'zarar' ? ' kir' : '')}>
      {yuzde(marj)}{seviye === 'zarar' && ' ⚠'}
      {seviye === 'hedef_alti' && <span className="bo-rz sari" style={{ marginLeft: 4 }} title={`Hedef marj %${sayi(hedef)}`}>hedef altı</span>}
    </td>
  );
}

function MaliyetRozeti({ k }: { k: MaliyetKaynagi }) {
  const [sinif, ad] = k === 'ortalama' ? ['ok', 'ortalama'] : k === 'kart' ? ['mavi', 'kart fiyatı'] : k === 'hizmet' ? ['pas', 'hizmet']
    : k === 'kismi' ? ['sari', 'kısmen maliyetsiz'] : ['sari', 'maliyetsiz'];
  return <span className={'bo-rz ' + sinif}>{ad}</span>;
}

/** Marj puan değişimi rozeti (önceki döneme göre). */
function PuanRozeti({ p }: { p: number | null }) {
  if (p == null) return <span className="ki-soluk">—</span>;
  const sinif = Math.abs(p) < 0.05 ? 'pas' : p > 0 ? 'ok' : 'kir';
  return <span className={'bo-rz ' + sinif}>{p > 0 ? '+' : p < 0 ? '−' : ''}{Math.abs(p).toLocaleString('tr-TR', { maximumFractionDigits: 1 })} p</span>;
}

export function KarlilikIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useGezinti();
  const bas = arama.get('bas') ?? ayBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const karsi = arama.get('karsi') === 'gy' ? 'gy' : 'od';
  const sube = Number(arama.get('sube') ?? 0);
  const temsilci = Number(arama.get('temsilci') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const para = arama.get('para') ?? '';
  const iadeDus = arama.get('iadesiz') !== '1';
  const hizmetDahil = arama.get('hizmetsiz') !== '1';
  const maliyetsizHaric = arama.get('msz') === 'haric';
  const bugunMaliyet = arama.get('maliyet') === 'bugun';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('mus');
  const [acik, setAcik] = useState<Set<string>>(new Set());
  const [ara, setAra] = useState('');
  const [secBelge, setSecBelge] = useState(0);
  const [secStok, setSecStok] = useState(0);
  const [hucre, setHucre] = useState<MatrisHucresi | null>(null);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit, karsi });
    if (sube) q.set('sube', String(sube));
    if (temsilci) q.set('temsilci', String(temsilci));
    if (kategori) q.set('kategori', String(kategori));
    if (para) q.set('para', para);
    if (!iadeDus) q.set('iade', '0');
    if (!hizmetDahil) q.set('hizmet', '0');
    if (maliyetsizHaric) q.set('maliyetsiz', 'haric');
    if (bugunMaliyet) q.set('maliyet', 'bugun');
    karlilikIcmalUclari.karlilikIcmali(q).then(v => { setVeri(v); setHucre(null) }).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, karsi, sube, temsilci, kategori, para, iadeDus, hizmetDahil, maliyetsizHaric, bugunMaliyet]);

  const q = ara.trim().toLocaleLowerCase('tr');
  const musteriler = useMemo(() => (veri?.musteriler ?? []).filter(m => !q || m.ad.toLocaleLowerCase('tr').includes(q)
    || m.temsilci.toLocaleLowerCase('tr').includes(q)), [veri, q]);
  const urunler = useMemo(() => (veri?.urunler ?? []).filter(u => !q || u.kod.toLocaleLowerCase('tr').includes(q)
    || u.ad.toLocaleLowerCase('tr').includes(q) || u.kategori.toLocaleLowerCase('tr').includes(q)), [veri, q]);
  const cevir = (k: string) => setAcik(a => { const n = new Set(a); n.has(k) ? n.delete(k) : n.add(k); return n });
  const o = veri?.ozet;
  const pb = veri?.para ?? '';
  const hedef = veri?.hedefMarj ?? 15;
  const karsiAdi = karsi === 'gy' ? 'Geçen yıl' : 'Önceki dönem';
  const cariKarti = (m: { id: number; musteri: boolean; tedarikci: boolean }) => gz.cariKarti(m.id, m.tedarikci && !m.musteri);
  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tümü';
  const temsilciAdi = temsilci ? veri?.secim.temsilciler.find(t => t.id === temsilci)?.ad ?? '' : 'Tümü';
  const kipYazi = `KDV hariç${iadeDus ? ' · iade düşülmüş' : ' · iade düşülmemiş'}${hizmetDahil ? '' : ' · hizmetler hariç'}${pb ? ` · ${pb} cinsinden` : ''}`;

  const a4 = veri && <KarlilikA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi} temsilci={temsilciAdi} kip={kipYazi} />;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI + KARLILIK_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Kârlılık İcmali</h1><span className="yol">Satış › İcmaller › Kârlılık İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Kârlılık İcmali" dosyaAdi={`Kârlılık İcmali ${bas} ${bit}`} devre={!veri}>{a4}</CiktiMenusu>
        <button disabled={!secBelge} onClick={() => gz.belgeKarti(secBelge)} title={secBelge ? '' : 'Önce Zararlı Satışlar sekmesinde bir satıra tıklayın'}>📄 Seçili belgeyi aç</button>
        <button disabled={!secStok} onClick={() => gz.stokKarti(secStok)} title={secStok ? 'Stok kartı (fiyatlar)' : 'Önce bir ürün satırına tıklayın'}>🏷 Fiyat listesine git</button>
        <span className="sp" />
        <button onClick={() => gz.git('/satis-icmali')}>🛍️ Satış İcmali</button>
        <button onClick={() => gz.git('/stok-deger-icmali')}>💰 Stok Değer İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Dönem:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} />
          –<input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
          <select value="" onChange={e => { if (!e.target.value) return; const [b1, b2] = hazirDonem(e.target.value); degistir({ bas: b1, bit: b2 }) }}>
            <option value="">hazır…</option><option value="buay">Bu ay</option><option value="gecenay">Geçen ay</option><option value="buyil">Bu yıl</option>
          </select></div>
        <div className="sel">⇄ Karşılaştır:
          <select value={karsi} onChange={e => degistir({ karsi: e.target.value === 'gy' ? 'gy' : '' })}>
            <option value="od">Önceki dönem</option><option value="gy">Geçen yılın aynı dönemi</option>
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">👤 Temsilci:
          <select value={temsilci} onChange={e => degistir({ temsilci: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.temsilciler ?? []).map(t => <option key={t.id} value={t.id}>{t.ad}</option>)}
          </select></div>
        <div className="sel">🗂 Kategori:
          <select value={kategori} onChange={e => degistir({ kategori: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.kategoriler ?? []).map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
          </select></div>
        <div className="sel">💱 Para birimi:
          <select value={para} onChange={e => degistir({ para: e.target.value })}>
            <option value="">TL karşılığı</option>
            {(veri?.secim.paralar ?? []).map(p => <option key={p} value={p}>{p} (yalnız {p} belgeler)</option>)}
          </select></div>
        <div className="si-seg" title="Bugünkü maliyet yalnız fiyat kararı için bilgidir; A4 her zaman satış anındaki maliyetle basılır">
          <button type="button" className={!bugunMaliyet ? 'on' : ''} onClick={() => degistir({ maliyet: '' })}>Satış anı maliyeti</button>
          <button type="button" className={bugunMaliyet ? 'on' : ''} onClick={() => degistir({ maliyet: 'bugun' })}>Bugünkü maliyetle</button>
        </div>
        <label className="ti-chk"><input type="checkbox" checked={iadeDus} onChange={e => degistir({ iadesiz: e.target.checked ? '' : '1' })} /> İadeleri düş</label>
        <label className="ti-chk"><input type="checkbox" checked={hizmetDahil} onChange={e => degistir({ hizmetsiz: e.target.checked ? '' : '1' })} /> Hizmetler dahil</label>
        <label className="ti-chk"><input type="checkbox" checked={maliyetsizHaric} onChange={e => degistir({ msz: e.target.checked ? 'haric' : '' })} /> Maliyetsiz satırları hariç tut</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.maliyetsiz.satir > 0 && <span className="bo-rz sari">Maliyetsiz satır: {o.maliyetsiz.satir}{o.maliyetsiz.haric ? ' (hariç)' : ''}</span>}
        {veri && veri.aktarimTahakkuk.belge > 0 && <span className="bo-rz mavi"
          title="Delphi'den satırsız aktarılan geçmiş faturalar: ürün ve maliyet taşımadıkları için bu icmale girmez">
          Aktarılan satış tahakkuku: {veri.aktarimTahakkuk.belge.toLocaleString('tr-TR')} belge · {kisa(veri.aktarimTahakkuk.tutar, '')} (icmale girmez)</span>}
      </div>

      {veri && o && (<>
        {veri.maliyetKipi === 'bugun' && (
          <div className="hi-serit" style={{ background: '#fffaf0' }}>
            <span className="bo-rz sari">Bugünkü maliyetle</span>
            <span className="ki-soluk">Maliyetler bugünkü ortalamadır - yalnız fiyat kararı için bilgi. Geçmiş satışın gerçek kârı satış anındaki maliyetledir; A4 her zaman satış anıyla basılır.</span>
          </div>
        )}
        <div className="hi-ozet">
          <Kutu bas="Net Satış" deg={kisa(o.net, pb)} alt={`KDV hariç${iadeDus ? ' · iade düşülmüş' : ''}`} sinif="mor" />
          <Kutu bas="Satılan Malın Maliyeti" deg={kisa(o.maliyet, pb)} alt={veri.maliyetKipi === 'bugun' ? 'bugünkü ortalama maliyet (bilgi)' : 'satış anındaki ortalama maliyet'} />
          <Kutu bas="Brüt Kâr" deg={kisa(o.kar, pb)} alt={`${karsiAdi.toLocaleLowerCase('tr')} ${tl(o.karsiKar)}`} sinif={o.kar >= 0 ? 'iyi' : 'teh'} />
          <Kutu bas="Brüt Kâr %" deg={yuzde(o.marj)}
            alt={`${karsiAdi.toLocaleLowerCase('tr')} ${yuzde(o.karsiMarj)}${o.marjFark != null ? ` · ${o.marjFark > 0 ? '+' : o.marjFark < 0 ? '−' : ''}${Math.abs(o.marjFark).toLocaleString('tr-TR', { maximumFractionDigits: 1 })} puan` : ''}`}
            sinif={o.marj == null ? '' : o.marj < 0 ? 'teh' : o.marj < hedef ? 'uy' : 'iyi'} />
          <Kutu bas="İskonto" deg={o.iskonto ? `−${kisa(o.iskonto, pb)}` : '—'} alt={o.kar > 0 ? `kârın %${sayi(o.iskontoKarOran)}'i kadar` : 'brüt satıştan'} />
          <Kutu bas="Zararlı Satır" deg={sayi(o.zararli.satir)} alt={o.zararli.satir ? `${eksi(o.zararli.tutar)} ${simge(pb)} · ${o.zararli.musteri} müşteri` : 'maliyet altı satış yok'}
            sinif={o.zararli.satir ? 'teh' : ''} />
          <Kutu bas="Maliyetsiz Satır" deg={sayi(o.maliyetsiz.satir)}
            alt={o.maliyetsiz.satir === 0 ? 'bütün satırların maliyeti var' : `${tl(o.maliyetsiz.net)} ${simge(pb)} satış · ${o.maliyetsiz.haric ? 'toplamdan çıkarıldı' : 'kâra %100 yazıldı'}`}
            sinif={o.maliyetsiz.satir ? 'uy' : ''} />
          <Kutu bas="Hizmet Payı" deg={o.hizmet.dahil ? yuzde(o.hizmet.pay) : '—'} alt={o.hizmet.dahil ? `${tl(o.hizmet.net)} ${simge(pb)} · maliyet 0` : 'hizmetler hariç'} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['mus', 'Müşteri', veri.musteriler.length], ['urn', 'Ürün', null], ['tem', 'Temsilci', null],
              ['kat', 'Kategori / Şube / Para birimi', null], ['zar', 'Zararlı Satışlar', veri.zararli.sayi],
              ['mtr', 'Ciro × Marj', null], ['trd', 'Trend', null], ['onz', '🖨 Önizleme (A4)', null]]} />

            {(sekme === 'mus' || sekme === 'urn') && (
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder={sekme === 'mus' ? '🔍 Müşteri ya da temsilci…' : '🔍 Kod, ürün / hizmet ya da kategori…'} value={ara}
                  onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                <span className="ki-soluk">{sekme === 'mus'
                  ? 'ABC: kâra katkıya göre (A ilk %80, B sonraki %15, C kalan) · satıra tıkla: ürün dağılımı · ada tıkla: cari kartı · çift tık: cari ekstresi'
                  : 'satıra tıkla: müşteri dağılımı · ada tıkla: stok kartı'}</span>
              </div>
            )}

            {sekme === 'mus' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Müşteri</th><th>Temsilci</th><th className="sag">Net satış</th><th className="sag">Maliyet</th><th className="sag">Brüt kâr</th>
                    <th className="sag">Marj</th><th className="sag">{karsiAdi} marj</th><th className="sag">İskonto</th><th className="orta">ABC</th>
                    <th className="sag">Kâr payı</th><th style={{ width: 100 }} /></tr></thead>
                  <tbody>
                    {musteriler.length === 0 && <tr><td colSpan={11} className="bos">Bu dönemde satış yok.</td></tr>}
                    {musteriler.slice(0, 500).map(m => (
                      <MusteriSatiri key={m.id} m={m} acik={acik.has('c' + m.id)} hedef={hedef}
                        tikla={() => cevir('c' + m.id)} cift={() => gz.ekstre(m.id)} kart={() => cariKarti(m)} />
                    ))}
                    {musteriler.length > 500 && <tr><td colSpan={11} className="bos">… {musteriler.length - 500} müşteri daha (aramayla daraltın)</td></tr>}
                    <tr className="top"><td colSpan={2}>Toplam ({veri.musteriToplam.musteri} müşteri)</td>
                      <td className="sag">{tl(veri.musteriToplam.net)}</td><td className="sag">{tl(veri.musteriToplam.maliyet)}</td>
                      <td className="sag">{tl(veri.musteriToplam.kar)}</td><td className="sag">{yuzde(veri.musteriToplam.marj)}</td>
                      <td className="sag">{yuzde(veri.musteriToplam.oncekiMarj)}</td><td className="sag">{eksi(veri.musteriToplam.iskonto)}</td>
                      <td /><td className="sag">%100</td><td /></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Net satış belge dip toplamından (fn_belge_diptoplam) satır payına bölüştürülür; maliyet = satırın stoktan çıktığı andaki ortalama
                maliyet × miktar. Fatura irsaliyeden türemişse maliyet irsaliyenin çıkış anındandır (stok bir kez çıkar). İade, iade edilen satışın
                maliyetiyle eksi yazılır. Hizmet satırında maliyet 0. Maliyet altı kırmızı ⚠, hedef marjın (%{sayi(hedef)}) altı sarı rozet.
                {pb ? ` Tutarlar ${pb} cinsinden (belge kuruyla; maliyet aynı kurla çevrilir).` : ' Dövizli satışlar belge kuruyla TL.'}
              </div>
            </>}

            {sekme === 'urn' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Kod</th><th>Ürün / Hizmet</th><th>Kategori</th><th className="sag">Miktar</th><th className="sag">Ort. satış</th>
                    <th className="sag">Ort. maliyet</th><th className="sag">Net satış</th><th className="sag">Brüt kâr</th><th className="sag">Marj</th>
                    <th className="orta">Değişim</th><th>Maliyet</th></tr></thead>
                  <tbody>
                    {urunler.length === 0 && <tr><td colSpan={11} className="bos">Kalem yok.</td></tr>}
                    {urunler.slice(0, 500).map(u => (
                      <Fragment key={u.anahtar}>
                        <tr className={'ac' + (secStok && secStok === u.stokId ? ' ti-sec' : '')}
                          onClick={() => { cevir('u' + u.anahtar); if (u.stokId) setSecStok(u.stokId) }}>
                          <td><span className="ok">{acik.has('u' + u.anahtar) ? '▾' : '▸'}</span>{u.kod}</td>
                          <td>{u.stokId ? <span className="lnk" onClick={e => { e.stopPropagation(); gz.stokKarti(u.stokId) }}>{u.ad}</span> : u.ad}</td>
                          <td>{u.kategori}</td><td className="sag">{sayi(u.miktar)}</td>
                          <td className="sag">{u.ortSatis == null ? '—' : tl(u.ortSatis)}</td>
                          <td className="sag">{u.ortMaliyet == null ? <span className="ki-soluk">{u.hizmet ? '—' : '?'}</span> : tl(u.ortMaliyet)}</td>
                          <td className="sag">{tl(u.net)}</td>
                          <td className={'sag' + (u.seviye === 'zarar' ? ' kir' : '')}><b>{tl(u.kar)}</b></td>
                          <MarjHucresi marj={u.marj} seviye={u.seviye} hedef={hedef} />
                          <td className="orta"><PuanRozeti p={u.marjDegisim} /></td>
                          <td><MaliyetRozeti k={u.maliyetKaynagi} /></td></tr>
                        {acik.has('u' + u.anahtar) && (
                          <tr className="si-det"><td colSpan={11}>
                            {u.musteriler.map(m => `${m.ad}: ${sayi(m.miktar)} · ${tl(m.net)} · kâr ${tl(m.kar)}`).join('   ·   ')}
                            {u.musteri > u.musteriler.length && `   · … ${u.musteri - u.musteriler.length} müşteri daha`}
                          </td></tr>
                        )}
                      </Fragment>
                    ))}
                    {urunler.length > 500 && <tr><td colSpan={11} className="bos">… {urunler.length - 500} kalem daha</td></tr>}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">"Maliyetsiz": stok çıkışı anında ortalama maliyet 0 ya da tanımsız (girişi hiç olmamış / kartta alış fiyatı
                yok). Varsayılan: kâra %100 yazılır ve rozetle uyarılır; şeritteki "Maliyetsiz satırları hariç tut" işaretlenirse toplamdan çıkarılır.
                "Kart fiyatı": giriş belgesi yok, stok kartının alış fiyatı kullanıldı. Değişim: {karsiAdi.toLocaleLowerCase('tr')} marjına göre puan.</div>
            </>}

            {sekme === 'tem' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Temsilci</th><th className="sag">Müşteri</th><th className="sag">Net satış</th><th className="sag">Brüt kâr</th>
                    <th className="sag">Marj</th><th className="sag">İskonto</th><th className="sag">İskonto / brüt satış</th><th className="sag">Zararlı satır</th>
                    <th className="sag">Tahsil edilen</th></tr></thead>
                  <tbody>
                    {veri.temsilciler.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde satış yok.</td></tr>}
                    {veri.temsilciler.map(t => (
                      <tr key={t.id} className="ac" onDoubleClick={() => degistir({ temsilci: String(t.id) })}>
                        <td className={t.id === -1 ? 'ki-soluk' : ''}>{t.ad}</td><td className="sag">{t.musteri}</td>
                        <td className="sag">{tl(t.net)}</td><td className={'sag' + (t.seviye === 'zarar' ? ' kir' : '')}>{tl(t.kar)}</td>
                        <MarjHucresi marj={t.marj} seviye={t.seviye} hedef={hedef} />
                        <td className="sag">{eksi(t.iskonto)}</td><td className="sag">%{sayi(t.iskontoOran)}</td>
                        <td className={'sag' + (t.zararli ? ' kir' : '')}>{t.zararli}</td><td className="sag">{tl(t.tahsil)}</td></tr>
                    ))}
                    <tr className="top"><td>Toplam</td><td className="sag">{veri.temsilciToplam.musteri}</td><td className="sag">{tl(veri.temsilciToplam.net)}</td>
                      <td className="sag">{tl(veri.temsilciToplam.kar)}</td><td className="sag">{yuzde(veri.temsilciToplam.marj)}</td>
                      <td className="sag">{eksi(veri.temsilciToplam.iskonto)}</td><td className="sag">%{sayi(veri.temsilciToplam.iskontoOran)}</td>
                      <td className="sag">{veri.temsilciToplam.zararli}</td><td className="sag">{tl(veri.temsilciToplam.tahsil)}</td></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Temsilci belgedeki satıcıdır (cari kartındaki temsilci kullanılmaz). Tahsil edilen: dönem faturalarının KDV dahil
                tutarından cari hareketinde açık kalmayan kısım (FIFO, Cari İcmali ile aynı; bilgi - prim hesabı Prim Planı ekranındadır). Çift tık: temsilciyle süz.</div>
            </>}

            {sekme === 'kat' && <>
              <div className="si-iki">
                <Kutucuk baslik="Kategori" not="ana kategori · pay: brüt kârdaki payı">
                  <table className="hi-tablo"><thead><tr><th>Kategori</th><th className="sag">Net satış</th><th className="sag">Brüt kâr</th>
                    <th className="sag">Marj</th><th className="sag">Pay</th></tr></thead>
                    <tbody>
                      {veri.kirilim.kategori.length === 0 && <tr><td colSpan={5} className="bos">Kalem yok.</td></tr>}
                      {veri.kirilim.kategori.map(k => (
                        <tr key={k.ad}><td>{k.ad}</td><td className="sag">{tl(k.net)}</td><td className={'sag' + (k.seviye === 'zarar' ? ' kir' : '')}>{tl(k.kar)}</td>
                          <MarjHucresi marj={k.marj} seviye={k.seviye} hedef={hedef} /><td className="sag">%{sayi(k.pay)}</td></tr>))}
                    </tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Şube / depo">
                  <table className="hi-tablo"><thead><tr><th>Şube · Depo</th><th className="sag">Net satış</th><th className="sag">Brüt kâr</th><th className="sag">Marj</th></tr></thead>
                    <tbody>{veri.kirilim.subeDepo.map(s => (
                      <tr key={s.ad}><td>{s.ad}</td><td className="sag">{tl(s.net)}</td><td className={'sag' + (s.kar < 0 ? ' kir' : '')}>{tl(s.kar)}</td>
                        <td className="sag">{yuzde(s.marj)}</td></tr>))}</tbody></table>
                </Kutucuk>
              </div>
              <Kutucuk baslik="Para birimi" not="TL karşılığı belge kuruyla">
                <table className="hi-tablo"><thead><tr><th>Para birimi</th><th className="sag">Belge</th><th className="sag">Döviz satış</th>
                  <th className="sag">TL satış</th><th className="sag">TL maliyet</th><th className="sag">Marj</th></tr></thead>
                  <tbody>
                    {veri.kirilim.para.satirlar.length === 0 && <tr><td colSpan={6} className="bos">Bu dönemde belge yok.</td></tr>}
                    {veri.kirilim.para.satirlar.map(p => (
                      <tr key={p.para}><td>{p.para}</td><td className="sag">{p.belge}</td>
                        <td className="sag">{p.doviz == null ? '—' : `${simge(p.para)} ${tl(p.doviz)}`}</td>
                        <td className="sag">{tl(p.tl)}</td><td className="sag">{tl(p.tlMaliyet)}</td><td className="sag">{yuzde(p.marj)}</td></tr>))}
                    <tr className="top"><td>Toplam</td><td className="sag">{veri.kirilim.para.toplam.belge}</td><td />
                      <td className="sag">{tl(veri.kirilim.para.toplam.tl)}</td><td className="sag">{tl(veri.kirilim.para.toplam.tlMaliyet)}</td>
                      <td className="sag">{yuzde(veri.kirilim.para.toplam.marj)}</td></tr>
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Maliyet her zaman TL tutulur (stok değerlemesi TL); dövizli satışta marj belge kuruyla
                  hesaplanır. Tek döviz seçilirse maliyet de aynı belge kuruyla o dövize çevrilir (bugünkü kurla değil). Bu tablo her zaman TL karşılığıdır.</div>
              </Kutucuk>
            </>}

            {sekme === 'zar' && <>
              <Kutucuk baslik="⚠ Maliyetin altında satılan satırlar" not="satıra tıkla: seç (belgeyi aç / fiyat listesine git) · çift tık: belge · ürüne tıkla: stok kartı">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo"><thead><tr><th>Belge</th><th>Tarih</th><th>Müşteri</th><th>Temsilci</th><th>Ürün</th>
                    <th className="sag">Miktar</th><th className="sag">Net fiyat</th><th className="sag">Maliyet</th><th className="sag">Fark</th>
                    <th className="sag">İskonto</th><th>Neden (tahmin)</th></tr></thead>
                    <tbody>
                      {veri.zararli.satirlar.length === 0 && <tr><td colSpan={11} className="bos">Maliyet altı satış yok.</td></tr>}
                      {veri.zararli.satirlar.map((z, i) => (
                        <tr key={i} className={'ac' + (secBelge === z.belgeId && secStok === z.stokId ? ' ti-sec' : '')}
                          onClick={() => { setSecBelge(z.belgeId); setSecStok(z.stokId) }} onDoubleClick={() => gz.belgeKarti(z.belgeId)}>
                          <td><span className="lnk" onClick={e => { e.stopPropagation(); gz.belgeKarti(z.belgeId) }}>{z.belgeNo || `#${z.belgeId}`}</span></td>
                          <td>{tarihT(z.tarih).slice(0, 5)}</td><td>{z.cari}</td>
                          <td className={z.temsilci === '(temsilcisiz)' ? 'ki-soluk' : ''}>{z.temsilci}</td>
                          <td><span className="lnk" onClick={e => { e.stopPropagation(); gz.stokKarti(z.stokId) }}>{z.urun}</span></td>
                          <td className="sag">{sayi(z.miktar)}</td><td className="sag kir">{tl(z.netFiyat)}</td><td className="sag">{tl(z.maliyet)}</td>
                          <td className="sag kir">{tl(z.fark)}</td><td className="sag">%{sayi(z.iskonto)}</td>
                          <td>{z.neden && <span className={'bo-rz ' + (z.neden === 'maliyet_arti' ? 'kir' : 'sari')}
                            title={z.neden === 'maliyet_arti' ? `liste ${z.listeFiyati == null ? '—' : tl(z.listeFiyati)} · son alış ${z.sonAlis == null ? '—' : tl(z.sonAlis)}` : ''}>{z.nedenAdi}</span>}</td>
                        </tr>))}
                      {veri.zararli.sayi > veri.zararli.satirlar.length && <tr><td colSpan={11} className="bos">… {veri.zararli.sayi - veri.zararli.satirlar.length} satır daha</td></tr>}
                      {veri.zararli.sayi > 0 && <tr className="top"><td colSpan={8}>Toplam ({veri.zararli.sayi} satır)</td>
                        <td className="sag kir">{tl(veri.zararli.tutar)}</td><td colSpan={2} /></tr>}
                    </tbody></table>
                </div>
              </Kutucuk>
              <div className="ki-soluk si-not">Net fiyat = satırın belge dip toplamından aldığı pay / miktar (KDV hariç); maliyet satış anındaki ortalama birim maliyet.
                Neden tahmini: iskonto %{sayi(veri.esik.yuksekIskonto)}'den büyükse "yüksek iskonto"; stok kartında satış fiyatı varsa ve son alış maliyeti onu
                aşmışsa "maliyet arttı, fiyat eski"; ikisi de değilse boş. Hedef marjın altındaki (ama maliyetin üstündeki) satışlar ayrı listelenmez - Müşteri ve
                Ürün sekmelerinde sarı rozetle görünür.</div>
            </>}

            {sekme === 'mtr' && <>
              <Kutucuk baslik="Ciro × marj matrisi — müşteri" not="hücreye tıkla: müşteri listesi">
                <table className="hi-tablo ka-matris"><thead><tr><th />
                  <th className="orta">Düşük marj (&lt; %{sayi(veri.esik.dusukMarj)})</th>
                  <th className="orta">Orta marj (%{sayi(veri.esik.dusukMarj)}–{sayi(veri.esik.yuksekMarj)})</th>
                  <th className="orta">Yüksek marj (&gt; %{sayi(veri.esik.yuksekMarj)})</th></tr></thead>
                  <tbody>
                    {(['A', 'B', 'C'] as const).map(c => (
                      <tr key={c}><th>{CIRO_ADI[c]}</th>
                        {(['dusuk', 'orta', 'yuksek'] as const).map(mj => {
                          const h = veri.matris.find(x => x.ciro === c && x.marj === mj);
                          if (!h) return <td key={mj} />;
                          const sec = hucre?.ciro === c && hucre?.marj === mj;
                          return (
                            <td key={mj} className={'sag ac' + (sec ? ' ka-sec' : '')} style={{ background: ISI[h.isi] || undefined }}
                              onClick={() => setHucre(sec ? null : h)}>
                              {h.musteri} müşteri · {tl(h.net)}
                              {h.oneri && <><br /><span className="ki-soluk">{h.oneri}</span></>}
                            </td>
                          );
                        })}
                      </tr>
                    ))}
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Ciro sınıfı ABC (net satışa göre, A ilk %80, B sonraki %15, C kalan); marj eşikleri
                  %{sayi(veri.esik.dusukMarj)} ve %{sayi(veri.esik.yuksekMarj)}. Net satışı olmayan müşteri matrise girmez.</div>
              </Kutucuk>
              {hucre && (
                <Kutucuk baslik={`${CIRO_ADI[hucre.ciro]} · ${MARJ_ADI[hucre.marj]}`} not={`${hucre.musteri} müşteri · çift tık: cari ekstresi`}>
                  <table className="hi-tablo"><thead><tr><th>Müşteri</th><th className="sag">Net satış</th><th className="sag">Brüt kâr</th><th className="sag">Marj</th></tr></thead>
                    <tbody>
                      {hucre.musteriler.length === 0 && <tr><td colSpan={4} className="bos">Bu hücrede müşteri yok.</td></tr>}
                      {hucre.musteriler.map(m => (
                        <tr key={m.id} className="ac" onDoubleClick={() => gz.ekstre(m.id)}><td>{m.ad}</td><td className="sag">{tl(m.net)}</td>
                          <td className={'sag' + (m.kar < 0 ? ' kir' : '')}>{tl(m.kar)}</td><td className="sag">{yuzde(m.marj)}</td></tr>))}
                      {hucre.musteri > hucre.musteriler.length && <tr><td colSpan={4} className="bos">… {hucre.musteri - hucre.musteriler.length} müşteri daha</td></tr>}
                    </tbody></table>
                </Kutucuk>
              )}
            </>}

            {sekme === 'trd' && (
              <Kutucuk baslik="Aylık brüt kâr — son 12 ay" not="çubuk: brüt kâr">
                <table className="hi-tablo"><thead><tr><th>Ay</th><th className="sag">Net satış</th><th className="sag">Maliyet</th><th className="sag">Brüt kâr</th>
                  <th className="sag">Marj</th><th className="sag">İskonto oranı</th><th className="sag">Maliyetsiz</th><th style={{ width: 220 }} /></tr></thead>
                  <tbody>
                    {veri.trend.aylar.map(a => (
                      <tr key={a.ay}><td>{a.kismiGun ? <b>{ayAdi(a.ay)} ({a.kismiGun}'i)</b> : ayAdi(a.ay)}
                        {a.aktarimSatirYok && <span className="bo-rz mavi" style={{ marginLeft: 4 }}
                          title={`${a.aktarim} belge Delphi'den satırsız tahakkuk olarak aktarıldı`}>aktarım: satır yok</span>}</td>
                        <td className="sag">{tl(a.net)}</td><td className="sag">{tl(a.maliyet)}</td>
                        <td className={'sag' + (a.kar < 0 ? ' kir' : '')}>{tl(a.kar)}</td><td className="sag">{yuzde(a.marj)}</td>
                        <td className="sag">%{sayi(a.iskontoOran)}</td>
                        <td className={'sag' + (a.maliyetsiz ? '' : ' ki-soluk')}>{a.maliyetsiz}</td><td><Cubuk yuzde={a.cubuk} /></td></tr>
                    ))}
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Son ay bitiş gününe kadardır. Web'den önceki aylar Delphi'den satırsız tahakkuk olarak
                  geldiyse o aylar boş kalır ve "aktarım: satır yok" rozetiyle belirtilir. Şube, temsilci, kategori, para ve hizmet seçimi uygulanır.</div>
              </Kutucuk>
            )}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.belge} belge</span><span>{o.musteri} müşteri</span><span>{o.kalem} kalem</span>
          <span>Maliyet: {veri.maliyetKipi === 'bugun' ? 'bugünkü ortalama (bilgi)' : 'satış anı ortalaması'}</span>
          <span>Karşılaştırma: {karsiAdi.toLocaleLowerCase('tr')} ({tarihT(veri.karsi.bas)} – {tarihT(veri.karsi.bit)})</span>
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}
    </div>
  );
}

function MusteriSatiri({ m, acik, hedef, tikla, cift, kart }: {
  m: KarlilikMusteriSatiri; acik: boolean; hedef: number; tikla(): void; cift(): void; kart(): void;
}) {
  return (
    <Fragment>
      <tr className="ac" onClick={tikla} onDoubleClick={cift}>
        <td className="ti-ad"><span className="ok">{acik ? '▾' : '▸'}</span>
          <span className="lnk" onClick={e => { e.stopPropagation(); kart() }}>{m.ad}</span><DovizRozetleri l={m.doviz} />
          {m.maliyetsiz > 0 && <span className="bo-rz sari" style={{ marginLeft: 4 }} title={`${m.maliyetsiz} satırın maliyeti yok`}>maliyetsiz</span>}</td>
        <td className={m.temsilci === '(temsilcisiz)' ? 'ki-soluk' : ''}>{m.temsilci}</td>
        <td className="sag">{tl(m.net)}</td><td className="sag">{tl(m.maliyet)}</td>
        <td className={'sag' + (m.seviye === 'zarar' ? ' kir' : '')}><b>{tl(m.kar)}</b></td>
        <MarjHucresi marj={m.marj} seviye={m.seviye} hedef={hedef} />
        <td className="sag">{m.yeni ? <span className="ki-soluk">yeni</span> : yuzde(m.oncekiMarj)}</td>
        <td className="sag">{eksi(m.iskonto)}</td>
        <td className="orta"><span className={'bo-rz ' + ABC_SINIF[m.abc]}>{m.abc}</span></td>
        <td className="sag">%{sayi(m.karPayi)}</td>
        <td><Cubuk yuzde={m.cubuk} /></td>
      </tr>
      {acik && (
        <tr className="si-det"><td colSpan={11}>
          {m.urunler.map((u, i) => (
            <Fragment key={u.anahtar}>{i > 0 && '  ·  '}
              {u.ad}: {sayi(u.miktar)} · {tl(u.net)} · <span className={u.kar < 0 ? 'kir' : ''}>kâr {tl(u.kar)} ({yuzde(u.marj)})</span>
              {u.maliyetsiz && <span className="bo-rz sari" style={{ marginLeft: 4 }}>maliyetsiz</span>}
            </Fragment>
          ))}
          {m.urunSayisi > m.urunler.length && `  ·  … ${m.urunSayisi - m.urunler.length} kalem daha`}
        </td></tr>
      )}
    </Fragment>
  );
}

/** A4: HER ZAMAN satış anındaki maliyetle (sunucunun `a4` bloğu; karar 25.10.2026). */
function KarlilikA4({ v, antet, duzenleyen, sube, temsilci, kip }: {
  v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; sube: string; temsilci: string; kip: string;
}) {
  const a = v.a4;
  const pb = simge(v.para);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>KÂRLILIK İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>{kip}</span>
        <span>Maliyet: satış anındaki ortalama maliyet</span><span>{a.toplam.musteri} müşteri · {a.toplam.kalem} kalem</span>
        <span>Şube: {sube} · Temsilci: {temsilci}</span>
        <span>{v.maliyetsizHaric ? 'Maliyetsiz satırlar hariç' : 'Maliyetsiz satırlar kâra yazıldı'}</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Müşteri</th><th>Net satış</th><th>Maliyet</th><th>Brüt kâr</th><th>Marj</th></tr></thead>
        <tbody>{a.musteriler.map(m => <tr key={m.id}><td>{m.ad}</td><td>{tl(m.net)}</td><td>{tl(m.maliyet)}</td>
          <td>{tl(m.kar)}</td><td>{yuzde(m.marj)}</td></tr>)}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>Net satış</span><span>{tl(a.toplam.net)}</span></div>
        <div><span>Satılan malın maliyeti</span><span>{eksi(a.toplam.maliyet)}</span></div>
        {a.toplam.maliyetsizNet > 0.005 && <div><span>Maliyetsiz satır (kâra yazıldı)</span><span>{tl(a.toplam.maliyetsizNet)}</span></div>}
        <div className="b"><span>BRÜT KÂR</span><span>{tl(a.toplam.kar)} {pb} · {yuzde(a.toplam.marj)}</span></div>
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Genel Müdür<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Kârlılık İcmali · genel giderler dağıtılmamıştır (brüt kâr) · tutarlar belge dip toplamlarından (fn_belge_diptoplam)
        {a.doviz.length > 0 && ` · ${a.doviz.map(d => `${simge(d.para)} ${tl(d.tutar)}`).join(' ve ')} dövizli satış belge kuruyla`}</p>
    </div>
  );
}

const KARLILIK_STILI = `
.hi-tablo.ka-matris td { text-align:right; cursor:pointer; }
.hi-tablo.ka-matris td.ka-sec { outline:2px solid #2f6db3; outline-offset:-2px; }
.hi-tablo.ka-matris th:first-child { text-align:left; }
`;

export default KarlilikIcmali;
