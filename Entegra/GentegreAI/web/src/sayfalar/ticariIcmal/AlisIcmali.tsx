import { Fragment, useEffect, useMemo, useState } from 'react';
import { hataMetni } from '../../api/sozlesme';
import { ticariIcmalUclari, type AlisIcmali as Veri, type AlisTedarikciSatiri, type AlisUrunSatiri } from '../../api/uclar/ticariIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import {
  ayAdi, DegisimRozeti, DovizRozetleri, EkranA4, eksi, FaturasizKutusu, kisa, ParaTablosuGorunumu, sayi, simge,
  tarihT, TICARI_ICMAL_STILI, tl, useGezinti, yuzde,
} from './ticariIcmalOrtak';

/**
 * ALIŞ İCMALİ `/alis-icmali` - mockup Ekranlar/İcmal/alis_icmali.html (kararlar 25.10.2026).
 * "Kimden ne aldık, ne kadar ödedik, fiyatlar nasıl değişti, hangi tedarikçi geç getiriyor,
 * nerede pahalı alıyoruz?" Rakamlar SUNUCUDAN (TicariIcmalUclari): tutar belge dip toplamından,
 * hizmet alımları dahil (Stok / Hizmet / İkisi), dövizli alış belge kuruyla TL. Gelen e-Fatura
 * kutusunda bekleyen (kaydedilmemiş) fatura alışa sayılmaz, Dikkat'te listelenir.
 */
type Sekme = 'ted' | 'stok' | 'fiyat' | 'donem' | 'dik' | 'onz';
const yilBasi = () => `${bugunYerel().slice(0, 4)}-01-01`;

function hazirDonem(k: string): [string, string] {
  const b = new Date();
  const s = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  if (k === 'buay') return [bugunYerel().slice(0, 8) + '01', bugunYerel()];
  if (k === 'gecenay') return [s(new Date(b.getFullYear(), b.getMonth() - 1, 1)), s(new Date(b.getFullYear(), b.getMonth(), 0))];
  if (k === 'gecenyil') return [`${b.getFullYear() - 1}-01-01`, `${b.getFullYear() - 1}-12-31`];
  return [yilBasi(), bugunYerel()];
}

export function AlisIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useGezinti();
  const bas = arama.get('bas') ?? yilBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const karsi = arama.get('karsi') === 'od' ? 'od' : 'gy';
  const sube = Number(arama.get('sube') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const kalem = arama.get('kalem') === 'stok' ? 'stok' : arama.get('kalem') === 'hizmet' ? 'hizmet' : 'hepsi';
  const para = arama.get('para') ?? '';
  const kdvDahil = arama.get('kdv') === '1';
  const iadeDus = arama.get('iadesiz') !== '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('ted');
  const [secili, setSecili] = useState(0);
  const [acik, setAcik] = useState<Set<string>>(new Set());
  const [ara, setAra] = useState('');

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit, karsi, kalem });
    if (sube) q.set('sube', String(sube));
    if (kategori) q.set('kategori', String(kategori));
    if (para) q.set('para', para);
    if (kdvDahil) q.set('kdv', '1');
    if (!iadeDus) q.set('iade', '0');
    ticariIcmalUclari.alisIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, karsi, sube, kategori, kalem, para, kdvDahil, iadeDus]);

  const q = ara.trim().toLocaleLowerCase('tr');
  const tedarikciler = useMemo(() => (veri?.tedarikciler ?? []).filter(t => !q || t.ad.toLocaleLowerCase('tr').includes(q)), [veri, q]);
  const urunler = useMemo(() => (veri?.urunler ?? []).filter(u => !q || u.kod.toLocaleLowerCase('tr').includes(q)
    || u.ad.toLocaleLowerCase('tr').includes(q) || u.kategori.toLocaleLowerCase('tr').includes(q)), [veri, q]);
  const fiyatlar = useMemo(() => (veri?.fiyat.satirlar ?? []).filter(f => !q || f.kod.toLocaleLowerCase('tr').includes(q)
    || f.ad.toLocaleLowerCase('tr').includes(q) || f.tedarikci.toLocaleLowerCase('tr').includes(q)), [veri, q]);
  const cevir = (k: string) => setAcik(a => { const n = new Set(a); n.has(k) ? n.delete(k) : n.add(k); return n });
  const o = veri?.ozet;
  const pb = veri?.para ?? '';
  const karsiAdi = karsi === 'od' ? 'Önceki dönem' : 'Geçen yıl';
  const d = veri?.dikkat;
  const dikkatSayisi = d ? d.sozlesmeUstu.length + d.ucuz.length + d.irsaliye.sayi + d.geciken.length + d.gelen.length : null;
  const cariKarti = (t: { id: number; musteri: boolean; tedarikci: boolean }) => gz.cariKarti(t.id, t.tedarikci && !t.musteri);
  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tümü';
  const katAdi = kategori ? veri?.secim.kategoriler.find(k => k.id === kategori)?.ad ?? '' : '';
  const kipYazi = `${kdvDahil ? 'KDV dahil' : 'KDV hariç'}${iadeDus ? ' · iade düşülmüş' : ' · iade düşülmemiş'}`
    + `${kalem !== 'hepsi' ? ` · yalnız ${kalem === 'stok' ? 'stok' : 'hizmet'}` : ''}${katAdi ? ` · ${katAdi}` : ''}${pb ? ` · ${pb} cinsinden` : ''}`;

  const a4 = veri && <AlisA4 v={veri} satirlar={tedarikciler} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi} kip={kipYazi} />;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Alış İcmali</h1><span className="yol">Alış › İcmaller › Alış İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Alış İcmali" dosyaAdi={`Alış İcmali ${bas} ${bit}`} devre={!veri}>{a4}</CiktiMenusu>
        <button disabled={!secili} onClick={() => gz.ekstre(secili)} title={secili ? '' : 'Önce tedarikçi satırına tıklayın'}>📄 Seçili tedarikçinin ekstresi</button>
        <span className="sp" />
        <button onClick={() => gz.git('/satis-icmali')}>🛍️ Satış İcmali</button>
        <button onClick={() => gz.git('/stok-kritik-stok-icmali')}>🚨 Kritik Stok</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Dönem:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} />
          –<input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
          <select value="" onChange={e => { if (!e.target.value) return; const [b1, b2] = hazirDonem(e.target.value); degistir({ bas: b1, bit: b2 }) }}>
            <option value="">hazır…</option><option value="buay">Bu ay</option><option value="gecenay">Geçen ay</option>
            <option value="buyil">Bu yıl</option><option value="gecenyil">Geçen yıl</option>
          </select></div>
        <div className="sel">⇄ Karşılaştır:
          <select value={karsi} onChange={e => degistir({ karsi: e.target.value === 'od' ? 'od' : '' })}>
            <option value="gy">Geçen yılın aynı dönemi</option><option value="od">Önceki dönem</option>
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">🗂 Kategori:
          <select value={kategori} onChange={e => degistir({ kategori: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.kategoriler ?? []).map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
          </select></div>
        <div className="si-seg">
          {([['stok', 'Stok'], ['hizmet', 'Hizmet'], ['hepsi', 'İkisi']] as const).map(([k, ad]) => (
            <button key={k} type="button" className={kalem === k ? 'on' : ''} onClick={() => degistir({ kalem: k === 'hepsi' ? '' : k })}>{ad}</button>
          ))}
        </div>
        <div className="sel">💱 Para birimi:
          <select value={para} onChange={e => degistir({ para: e.target.value })}>
            <option value="">TL karşılığı</option>
            {(veri?.secim.paralar ?? []).map(p => <option key={p} value={p}>{p} (yalnız {p} belgeler)</option>)}
          </select></div>
        <div className="si-seg">
          <button type="button" className={!kdvDahil ? 'on' : ''} onClick={() => degistir({ kdv: '' })}>KDV hariç</button>
          <button type="button" className={kdvDahil ? 'on' : ''} onClick={() => degistir({ kdv: '1' })}>KDV dahil</button>
        </div>
        <label className="ti-chk"><input type="checkbox" checked={iadeDus} onChange={e => degistir({ iadesiz: e.target.checked ? '' : '1' })} /> İadeleri düş</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {veri && veri.aktarimTahakkuk.belge > 0 && <span className="bo-rz mavi"
          title="Delphi'den satırsız aktarılan geçmiş faturalar: tutarları cari hesapta, ürün / maliyet / KDV ayrıntısı olmadığı için bu icmale girmez">
          Aktarılan alış tahakkuku: {veri.aktarimTahakkuk.belge.toLocaleString('tr-TR')} belge · {veri.aktarimTahakkuk.tutar.toLocaleString('tr-TR', { maximumFractionDigits: 0 })} ₺ (icmale girmez)</span>}
        {d && d.irsaliye.sayi > 0 && <span className="bo-rz sari" style={{ cursor: 'pointer' }} onClick={() => setSekme('dik')}>
          Faturası gelmemiş irsaliye: {d.irsaliye.sayi}</span>}
      </div>

      {veri && o && d && (<>
        <div className="hi-ozet">
          <Kutu bas="Net Alış" deg={kisa(o.net, pb)} alt={`${kdvDahil ? 'KDV dahil' : 'KDV hariç'}${iadeDus ? ' · iade düşülmüş' : ''}`} sinif="mor" />
          <Kutu bas={karsi === 'od' ? 'Önceki Dönem' : 'Geçen Yıl Aynı Dönem'} deg={yuzde(o.degisim, true)} alt={`${tl(o.karsiNet)} ${simge(pb)}`} />
          <Kutu bas="Belge" deg={sayi(o.belge)} alt={`fatura ${o.fatura} · fiş ${o.fis}`} />
          <Kutu bas="Tedarikçi" deg={sayi(o.tedarikci)} alt={`ilk 3 tedarikçi alışın %${sayi(o.ilk3Pay)}'i`} />
          <Kutu bas="Alış İadesi" deg={o.iade ? `−${kisa(o.iade, pb)}` : '—'} alt={`${o.iadeBelge} belge`} sinif={o.iade ? 'iyi' : ''} />
          <Kutu bas="Fiyat Artışı" deg={yuzde(o.fiyatArtisi, true)} alt={`aynı kalemde dönem başına göre (ağırlıklı) · ${o.fiyatKalem} kalem`}
            sinif={(o.fiyatArtisi ?? 0) > 0 ? 'uy' : 'iyi'} />
          <Kutu bas="Ort. Teslim Süresi" deg={o.teslimGun == null ? '—' : `${sayi(o.teslimGun)} gün`} alt={`sipariş → giriş · ${o.teslimSiparis} sipariş`} />
          <Kutu bas="Vadesi Gelen Borç" deg={`${kisa(o.vadesiGelen, '')}`}
            alt={`30 gün içinde ödenecek${o.vadesiGelenGecmis > 0.005 ? ` · ${tl(o.vadesiGelenGecmis)} gecikmiş` : ''}`} sinif={o.vadesiGelen > 0.005 ? 'teh' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['ted', 'Tedarikçi Bazında', veri.tedarikciler.length], ['stok', 'Ürün Bazında', null], ['fiyat', 'Fiyat Gelişimi', veri.fiyat.kalem || null],
              ['donem', 'Ay Trendi', null], ['dik', 'Dikkat', dikkatSayisi], ['onz', '🖨 Önizleme (A4)', null]]} />

            {(sekme === 'ted' || sekme === 'stok' || sekme === 'fiyat') && (
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder={sekme === 'ted' ? '🔍 Tedarikçi…' : '🔍 Kod, ürün / hizmet ya da tedarikçi…'} value={ara}
                  onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                <span className="ki-soluk">{sekme === 'ted'
                  ? 'satıra tıkla: kategori dağılımı · çift tık: cari ekstresi · ada tıkla: cari kartı · net alışa göre sıralı'
                  : sekme === 'stok' ? 'satıra tıkla: tedarikçi dağılımı (birden çok tedarikçiden alınan kalemlerde fiyat karşılaştırması)'
                  : 'aynı kalemin dönem başı ve son alış fiyatı · artışa göre sıralı · dönemde en az 2 alışı olan kalemler'}</span>
              </div>
            )}

            {sekme === 'ted' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Tedarikçi</th><th className="sag">Belge</th><th className="sag">Brüt</th><th className="sag">İskonto</th><th className="sag">İade</th>
                    <th className="sag">Net Alış</th><th className="sag">{karsiAdi}</th><th className="orta">Değişim</th><th className="sag">Pay</th>
                    <th className="sag">Teslim (gün)</th><th className="sag">Açık Borç (TL)</th><th style={{ width: 100 }} /></tr></thead>
                  <tbody>
                    {tedarikciler.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde alış yok.</td></tr>}
                    {tedarikciler.slice(0, 500).map(t => (
                      <TedarikciSatiri key={t.id} t={t} acik={acik.has('t' + t.id)} secili={secili === t.id}
                        tikla={() => { setSecili(t.id); cevir('t' + t.id) }} cift={() => gz.ekstre(t.id)} kart={() => cariKarti(t)} />
                    ))}
                    {tedarikciler.length > 500 && <tr><td colSpan={12} className="bos">… {tedarikciler.length - 500} tedarikçi daha</td></tr>}
                    <tr className="top"><td>Toplam ({veri.tedarikciToplam.tedarikci} tedarikçi)</td><td className="sag">{veri.tedarikciToplam.belge}</td>
                      <td className="sag">{tl(veri.tedarikciToplam.brut)}</td><td className="sag">{eksi(veri.tedarikciToplam.iskonto)}</td>
                      <td className="sag">{eksi(veri.tedarikciToplam.iade)}</td><td className="sag">{tl(veri.tedarikciToplam.net)}</td>
                      <td className="sag">{tl(veri.tedarikciToplam.gecenYil)}</td><td className="orta">{yuzde(veri.tedarikciToplam.degisim, true)}</td>
                      <td className="sag">%100</td><td className="sag">{sayi(veri.tedarikciToplam.teslimGun)}</td>
                      <td className="sag">{tl(veri.tedarikciToplam.acikBorc)}</td><td /></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Net alış = brüt − iskonto − iade ({kdvDahil ? 'KDV dahil' : 'KDV hariç'}, belge dip toplamından). Teslim süresi = alış
                siparişinin tarihi → mal kabul / giriş belgesinin tarihi (siparişli alımlarda). Açık borç cari bakiyeden (TL).</div>
              <Kutucuk baslik="Para birimi" not="TL karşılığı belge kuruyla · kur farkı yalnız açık (ödenmemiş) borç için">
                <ParaTablosuGorunumu t={veri.paraTablosu} satis={false} />
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Borçta kur artışı aleyhimizedir (kırmızı). Şeritte tek döviz seçilirse sekmeler o
                  dövizin cinsinden gösterir; bu tablo her zaman TL karşılığıdır. Fiyat Gelişimi dövizli kalemde döviz fiyatını karşılaştırır.</div>
              </Kutucuk>
            </>}

            {sekme === 'stok' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Kod</th><th>Ürün / Hizmet</th><th className="sag">Miktar</th><th className="sag">Net Alış</th><th className="sag">Ort. Fiyat</th>
                    <th className="sag">En Düşük</th><th className="sag">En Yüksek</th><th className="sag">Son Fiyat</th><th className="sag">Tedarikçi</th>
                    <th className="sag">Satılan</th><th className="sag">Stokta</th></tr></thead>
                  <tbody>
                    {urunler.length === 0 && <tr><td colSpan={11} className="bos">Kalem yok.</td></tr>}
                    {urunler.slice(0, 500).map(u => (
                      <UrunSatiri key={u.anahtar} u={u} acik={acik.has('u' + u.anahtar)} cevir={() => cevir('u' + u.anahtar)} stokAc={gz.stokKarti} />
                    ))}
                    {urunler.length > 500 && <tr><td colSpan={11} className="bos">… {urunler.length - 500} kalem daha</td></tr>}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Satılan / Stokta: aynı dönemde satılan miktar (satış − satış iadesi) ve bugünkü bakiye — alınan malın ne kadarının
                döndüğünü gösterir; hizmette boştur. Birden çok tedarikçiden alınan kalemde en ucuz tedarikçi açılan satırda koyu.</div>
            </>}

            {sekme === 'fiyat' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Kod</th><th>Ürün / Hizmet</th><th>Tedarikçi</th><th className="sag">İlk Fiyat</th><th>İlk Tarih</th><th className="sag">Son Fiyat</th>
                    <th>Son Tarih</th><th className="sag">Değişim</th><th className="sag">Etki ({simge(pb)})</th></tr></thead>
                  <tbody>
                    {fiyatlar.length === 0 && <tr><td colSpan={9} className="bos">Dönemde aynı tedarikçiden en az iki kez alınan kalem yok.</td></tr>}
                    {fiyatlar.map(f => {
                      const s = f.degisim > 0.05 ? 'kir' : f.degisim < -0.05 ? 'si-yesil' : 'ki-soluk';
                      const p = f.para !== veri.yerelPara ? ` ${simge(f.para)}` : '';
                      return (
                        <tr key={f.anahtar + '|' + f.tedarikciId + '|' + f.para} className="ac" onDoubleClick={() => gz.ekstre(f.tedarikciId)}>
                          <td>{f.kod}</td><td>{f.stokId ? <span className="lnk" onClick={() => gz.stokKarti(f.stokId)}>{f.ad}</span> : f.ad}</td><td>{f.tedarikci}</td>
                          <td className="sag">{tl(f.ilkFiyat)}{p}</td><td>{tarihT(f.ilkTarih)}</td><td className="sag">{tl(f.sonFiyat)}{p}</td><td>{tarihT(f.sonTarih)}</td>
                          <td className={'sag ' + s}>{yuzde(f.degisim, true)}</td>
                          <td className={'sag ' + s}>{f.etki > 0 ? '+' : ''}{tl(f.etki)}</td></tr>
                      );
                    })}
                    <tr className="top"><td colSpan={7}>Ağırlıklı ortalama fiyat değişimi (alış tutarıyla) · {veri.fiyat.kalem} kalem</td>
                      <td className="sag">{yuzde(veri.fiyat.agirlikliDegisim, true)}</td><td className="sag">{veri.fiyat.etki > 0 ? '+' : ''}{tl(veri.fiyat.etki)}</td></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Etki = (son fiyat − ilk fiyat) × dönemde ilk alıştan sonra alınan miktar: fiyat artışının döneme maliyeti. Fiyat satırın
                KDV hariç birim fiyatıdır; dövizli kalemde ilk / son fiyat döviz cinsinden karşılaştırılır (kur etkisi fiyat artışı sayılmaz), etki belge kurlarıyla
                {pb ? ` ${pb}` : ' TL'}. Hizmet alımlarında da aynı kural.</div>
            </>}

            {sekme === 'donem' && (
              <Kutucuk baslik="Aylık alış" not="alış · satılan malın maliyeti · stok değişimi">
                <table className="hi-tablo"><thead><tr><th>Ay</th><th className="sag">Net Alış</th><th className="sag">Geçen Yıl</th><th className="orta">Değişim</th>
                  <th className="sag">Stok Alışı</th><th className="sag">Satılan Malın Maliyeti</th><th className="sag">Fark (stoğa giden)</th><th style={{ width: 200 }} /></tr></thead>
                  <tbody>
                    {veri.trend.aylar.map(a => (
                      <tr key={a.ay}><td>{a.kismiGun ? <b>{ayAdi(a.ay)} ({a.kismiGun}'i)</b> : ayAdi(a.ay)}</td>
                        <td className="sag">{tl(a.net)}</td><td className="sag">{tl(a.gecenYil)}</td>
                        <td className="orta"><DegisimRozeti d={a.degisim} ters /></td><td className="sag">{tl(a.stokAlis)}</td>
                        <td className="sag">{a.smm == null ? '—' : tl(a.smm)}</td>
                        <td className={'sag' + (a.fark == null ? ' ki-soluk' : a.fark < 0 ? ' si-yesil' : '')}>
                          {a.fark == null ? '—' : `${a.fark > 0 ? '+' : ''}${tl(a.fark)}`}</td>
                        <td><Cubuk yuzde={a.cubuk} /></td></tr>
                    ))}
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Fark eksi = satılan, alınandan fazla (stok eriyor); artı = stok büyüyor. Stok alışı
                  yalnız stok satırlarıdır (hizmet hariç); satılan malın maliyeti ortalama maliyetle, Stok Hareket İcmali ile aynı hareket kaynağından
                  {pb ? ' — tek döviz seçiliyken gösterilmez' : ''}. Geçen yıl sütunu her zaman geçen yılın aynı ayıdır.</div>
              </Kutucuk>
            )}

            {sekme === 'dik' && <>
              <div className="si-iki">
                <Kutucuk baslik="⚠ Sözleşme fiyatının üstünde alış" not="yürürlükteki tedarikçi sözleşmesi">
                  <table className="hi-tablo"><thead><tr><th>Belge</th><th>Tedarikçi</th><th>Ürün</th><th className="sag">Fiyat</th><th className="sag">Sözleşme</th></tr></thead>
                    <tbody>
                      {d.sozlesmeUstu.length === 0 && <tr><td colSpan={5} className="bos">Sözleşme fiyatı üstünde alış yok (ya da sözleşme tanımlı değil).</td></tr>}
                      {d.sozlesmeUstu.map((x, i) => (
                        <tr key={i} className="ac" onDoubleClick={() => gz.belgeKarti(x.belgeId)}><td>{x.belgeNo || `#${x.belgeId}`}</td><td>{x.cari}</td>
                          <td>{x.urun}</td><td className="sag kir">{tl(x.fiyat)} {simge(x.para)}</td>
                          <td className="sag" title={x.sozlesmeNo}>{tl(x.sozlesme)} {simge(x.para)}</td></tr>))}
                    </tbody></table>
                </Kutucuk>
                <Kutucuk baslik="🔁 Aynı kalem, daha ucuz tedarikçi var" not="son 90 gün · TL alışlar">
                  <table className="hi-tablo"><thead><tr><th>Ürün</th><th>Alınan</th><th className="sag">Fiyat</th><th>Ucuz olan</th><th className="sag">Fiyat</th></tr></thead>
                    <tbody>
                      {d.ucuz.length === 0 && <tr><td colSpan={5} className="bos">Belirgin fiyat farkı yok.</td></tr>}
                      {d.ucuz.map((x, i) => (
                        <tr key={i}><td>{x.urun}</td><td>{x.alinan}</td><td className="sag kir">{tl(x.fiyat)}</td><td>{x.ucuz}</td>
                          <td className="sag si-yesil">{tl(x.ucuzFiyat)}</td></tr>))}
                    </tbody></table>
                </Kutucuk>
              </div>
              <div className="si-iki">
                <FaturasizKutusu v={d.irsaliye} baslik="🧾 Faturası gelmemiş alış irsaliyeleri" belgeAc={gz.belgeKarti} />
                <Kutucuk baslik="⏱ Geciken siparişler" not="termin geçti, mal gelmedi">
                  <table className="hi-tablo"><thead><tr><th>Sipariş</th><th>Tedarikçi</th><th>Termin</th><th className="sag">Açık miktar</th><th className="orta">Gecikme</th></tr></thead>
                    <tbody>
                      {d.geciken.length === 0 && <tr><td colSpan={5} className="bos">Geciken sipariş yok.</td></tr>}
                      {d.geciken.map(x => (
                        <tr key={x.id} className="ac" onDoubleClick={() => gz.belgeKarti(x.id)}><td>{x.no || `#${x.id}`}</td><td>{x.cari}</td>
                          <td>{tarihT(x.termin)}</td><td className="sag">{sayi(x.acikMiktar)}</td>
                          <td className="orta"><span className={'bo-rz ' + (x.gecikme > 7 ? 'kir' : 'sari')}>{x.gecikme} gün</span></td></tr>))}
                    </tbody></table>
                </Kutucuk>
              </div>
              <Kutucuk baslik="📥 Gelen e-Fatura kutusunda bekleyen" not={`henüz kaydedilmedi · alışa sayılmadı · ${tl(d.gelenTutar)} ₺`}>
                <table className="hi-tablo"><thead><tr><th>Tedarikçi</th><th>Tür</th><th>Fatura No</th><th>Tarih</th><th className="sag">Tutar</th><th className="orta">Bekleyen</th></tr></thead>
                  <tbody>
                    {d.gelen.length === 0 && <tr><td colSpan={6} className="bos">Kutuda kaydedilmeyi bekleyen fatura yok.</td></tr>}
                    {d.gelen.map(x => (
                      <tr key={x.id} className="ac" onDoubleClick={() => gz.git('/gelen-belge')}><td>{x.cari}</td><td>{x.tur}</td><td>{x.no}</td><td>{tarihT(x.tarih)}</td>
                        <td className="sag">{tl(x.tutar)}{x.para && x.para !== 'TRY' && x.para !== 'TL' ? ` ${x.para}` : ''}</td>
                        <td className="orta"><span className={'bo-rz ' + ((x.bekleyen ?? 0) > 7 ? 'kir' : 'pas')}>{x.bekleyen ?? '—'} gün</span></td></tr>))}
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Kutudaki fatura kaydedilene kadar cari ve stok etkisi yoktur; sayılsa icmal muhasebeyle
                  tutmazdı (karar 25.10.2026). Tutar e-Faturanın ödenecek tutarıdır. Çift tık: Gelen Kutusu.</div>
              </Kutucuk>
            </>}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.belge} belge</span><span>{o.tedarikci} tedarikçi</span>
          <span>Karşılaştırma: {karsiAdi.toLocaleLowerCase('tr')} ({tarihT(veri.karsi.bas)} – {tarihT(veri.karsi.bit)})</span>
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}
    </div>
  );
}

function TedarikciSatiri({ t, acik, secili, tikla, cift, kart }: {
  t: AlisTedarikciSatiri; acik: boolean; secili: boolean; tikla(): void; cift(): void; kart(): void;
}) {
  return (
    <Fragment>
      <tr className={'ac' + (secili ? ' ti-sec' : '')} onClick={tikla} onDoubleClick={cift}>
        <td className="ti-ad"><span className="ok">{acik ? '▾' : '▸'}</span>
          <span className="lnk" onClick={e => { e.stopPropagation(); kart() }}>{t.ad}</span><DovizRozetleri l={t.doviz} /></td>
        <td className="sag">{t.belge}</td><td className="sag">{tl(t.brut)}</td><td className="sag">{eksi(t.iskonto)}</td>
        <td className={'sag' + (t.iade ? '' : ' ki-soluk')}>{eksi(t.iade)}</td>
        <td className="sag"><b>{tl(t.net)}</b></td>
        <td className={'sag' + (t.gecenYil == null ? ' ki-soluk' : '')}>{t.gecenYil == null ? '—' : tl(t.gecenYil)}</td>
        <td className="orta"><DegisimRozeti d={t.degisim} yeni={t.gecenYil == null} ters /></td>
        <td className="sag">%{sayi(t.pay)}</td>
        <td className={'sag' + (t.gecTeslim ? ' kir' : t.teslimGun == null ? ' ki-soluk' : '')}>{sayi(t.teslimGun)}</td>
        <td className={'sag' + (t.acikBorc > 0.005 ? '' : ' ki-soluk')}>{tl(t.acikBorc)}</td>
        <td><Cubuk yuzde={t.cubuk} /></td>
      </tr>
      {acik && (
        <tr className="si-det"><td colSpan={12}>
          {t.kategoriler.map(k => `${k.ad} ${tl(k.net)}`).join(' · ')}
          {t.sonAlis && `   ·   son alış ${tarihT(t.sonAlis)}`}
        </td></tr>
      )}
    </Fragment>
  );
}

function UrunSatiri({ u, acik, cevir, stokAc }: { u: AlisUrunSatiri; acik: boolean; cevir(): void; stokAc(id: number): void }) {
  const f = (n: number | null) => (n == null ? '—' : tl(n));
  return (
    <Fragment>
      <tr className="ac" onClick={cevir}>
        <td><span className="ok">{acik ? '▾' : '▸'}</span>{u.kod}</td>
        <td>{u.stokId ? <span className="lnk" onClick={e => { e.stopPropagation(); stokAc(u.stokId) }}>{u.ad}</span> : u.ad}
          {u.hizmet && <span className="bo-rz pas" style={{ marginLeft: 4 }}>hizmet</span>}</td>
        <td className="sag">{sayi(u.miktar)}</td><td className="sag"><b>{tl(u.net)}</b></td><td className="sag">{f(u.ortFiyat)}</td>
        <td className="sag">{f(u.enDusuk)}</td><td className="sag">{f(u.enYuksek)}</td><td className="sag">{f(u.sonFiyat)}</td>
        <td className="sag">{u.tedarikci}</td>
        <td className="sag">{u.satilan == null ? '' : sayi(u.satilan)}</td>
        <td className={'sag' + (u.stokta != null && u.stokta <= 0 ? ' kir' : '')}>{u.stokta == null ? '' : sayi(u.stokta)}</td>
      </tr>
      {acik && (
        <tr className="si-det"><td colSpan={11}>
          {u.tedarikciler.map((t, i) => (
            <Fragment key={t.id}>{i > 0 && '   ·   '}
              {t.enUcuz ? <b>{t.ad}</b> : t.ad} {sayi(t.miktar)} · ort. {f(t.ortFiyat)}
              {t.fark != null && t.fark > 0.05 && <span className="kir"> (+%{t.fark.toLocaleString('tr-TR')})</span>}
            </Fragment>
          ))}
        </td></tr>
      )}
    </Fragment>
  );
}

function AlisA4({ v, satirlar, antet, duzenleyen, sube, kip }: {
  v: Veri; satirlar: AlisTedarikciSatiri[]; antet: Record<string, unknown> | null; duzenleyen: string; sube: string; kip: string;
}) {
  const o = v.ozet;
  const dovizli = v.para ? [] : v.paraTablosu.satirlar.filter(p => !p.yerel && p.doviz);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>ALIŞ İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>{kip}</span>
        <span>Şube: {sube}</span><span>{o.belge} belge · {o.tedarikci} tedarikçi</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Tedarikçi</th><th>Belge</th><th>Net Alış</th><th>{v.karsi.tur === 'od' ? 'Önceki Dönem' : 'Geçen Yıl'}</th><th>Pay</th></tr></thead>
        <tbody>{satirlar.map(t => <tr key={t.id}><td>{t.ad}</td><td>{t.belge}</td><td>{tl(t.net)}</td>
          <td>{t.gecenYil == null ? '—' : tl(t.gecenYil)}</td><td>%{sayi(t.pay)}</td></tr>)}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>Brüt alış</span><span>{tl(o.brut)}</span></div>
        <div><span>İskonto</span><span>{eksi(o.iskonto)}</span></div>
        <div><span>İade{v.iadeDus ? '' : ' (düşülmedi)'}</span><span>{eksi(o.iade)}</span></div>
        <div className="b"><span>NET ALIŞ</span><span>{tl(o.net)} {simge(v.para)}</span></div>
        {dovizli.length > 0 && <div className="not"><span>bunun {dovizli.map(p => `${simge(p.para)} ${tl(p.doviz ?? 0)} (ort. kur ${(p.ortKur ?? 0).toLocaleString('tr-TR', { maximumFractionDigits: 4 })})`).join(', ')} dövizli</span><span /></div>}
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Satınalma Müdürü<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Alış İcmali · tutarlar belge dip toplamlarından · {kip}</p>
    </div>
  );
}

export default AlisIcmali;
