import { Fragment, useEffect, useMemo, useState } from 'react';
import { hataMetni } from '../../api/sozlesme';
import { ticariIcmalUclari, type SatisIcmali as Veri, type SatisMusteriSatiri } from '../../api/uclar/ticariIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import { ayAdi, ayBasi, DegisimRozeti, DovizRozetleri, EkranA4, eksi, FaturasizKutusu, hazirDonem, kisa, ParaTablosuGorunumu, sayi, simge, tarihT, TICARI_ICMAL_STILI, tl, useGezinti, yuzde } from './ticariIcmalOrtak';

/**
 * SATIŞ İCMALİ `/satis-icmali` - mockup Ekranlar/İcmal/satis_icmali.html (kararlar 25.10.2026).
 * "Bu dönem kime ne sattık, geçen yıla göre nasılız, nerede kâr ediyoruz, nerede zararına
 * satıyoruz?" Rakamlar SUNUCUDAN (TicariIcmalUclari): tutar belge dip toplamından, temsilci
 * belgeden, dövizli satış belge kuruyla TL. Satıra tıkla: belge listesi · çift tık: cari
 * ekstresi · ada tıkla: cari kartı.
 */
type Sekme = 'cari' | 'stok' | 'donem' | 'kir' | 'dik' | 'onz';


export function SatisIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useGezinti();
  const bas = arama.get('bas') ?? ayBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const karsi = arama.get('karsi') === 'od' ? 'od' : 'gy';
  const sube = Number(arama.get('sube') ?? 0);
  const temsilci = Number(arama.get('temsilci') ?? 0);
  const para = arama.get('para') ?? '';
  const kdvDahil = arama.get('kdv') === '1';
  const iadeDus = arama.get('iadesiz') !== '1';
  const taslak = arama.get('taslak') === '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('cari');
  const [secili, setSecili] = useState(0);
  const [acik, setAcik] = useState<Set<string>>(new Set());
  const [ara, setAra] = useState('');
  const [trendGun, setTrendGun] = useState(false);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit, karsi });
    if (sube) q.set('sube', String(sube));
    if (temsilci) q.set('temsilci', String(temsilci));
    if (para) q.set('para', para);
    if (kdvDahil) q.set('kdv', '1');
    if (!iadeDus) q.set('iade', '0');
    if (taslak) q.set('taslak', '1');
    ticariIcmalUclari.satisIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, karsi, sube, temsilci, para, kdvDahil, iadeDus, taslak]);

  const q = ara.trim().toLocaleLowerCase('tr');
  const musteriler = useMemo(() => (veri?.musteriler ?? []).filter(m => !q || m.ad.toLocaleLowerCase('tr').includes(q)
    || m.temsilci.toLocaleLowerCase('tr').includes(q)), [veri, q]);
  const urunler = useMemo(() => (veri?.urunler ?? []).filter(u => !q || u.kod.toLocaleLowerCase('tr').includes(q)
    || u.ad.toLocaleLowerCase('tr').includes(q) || u.kategori.toLocaleLowerCase('tr').includes(q)), [veri, q]);
  const cevir = (k: string) => setAcik(a => { const n = new Set(a); n.has(k) ? n.delete(k) : n.add(k); return n });
  const o = veri?.ozet;
  const pb = veri?.para ?? '';
  const karsiAdi = karsi === 'od' ? 'Önceki dönem' : 'Geçen yıl';
  const dikkatSayisi = veri ? veri.dikkat.zarar.length + veri.dikkat.dusen.length + veri.dikkat.irsaliye.sayi + veri.dikkat.ebelge.length : null;
  const cariKarti = (m: { id: number; musteri: boolean; tedarikci: boolean }) => gz.cariKarti(m.id, m.tedarikci && !m.musteri);
  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tümü';
  const temsilciAdi = temsilci ? veri?.secim.temsilciler.find(t => t.id === temsilci)?.ad ?? '' : 'Tümü';
  const kipYazi = `${kdvDahil ? 'KDV dahil' : 'KDV hariç'}${iadeDus ? ' · iade düşülmüş' : ' · iade düşülmemiş'}${pb ? ` · ${pb} cinsinden` : ''}`;

  const a4 = veri && <SatisA4 v={veri} satirlar={musteriler} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi} temsilci={temsilciAdi} kip={kipYazi} />;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Satış İcmali</h1><span className="yol">Satış › İcmaller › Satış İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Satış İcmali" dosyaAdi={`Satış İcmali ${bas} ${bit}`} devre={!veri}>{a4}</CiktiMenusu>
        <button disabled={!secili} onClick={() => gz.ekstre(secili)} title={secili ? '' : 'Önce müşteri satırına tıklayın'}>📄 Seçili carinin ekstresi</button>
        <span className="sp" />
        <button onClick={() => gz.git('/alis-icmali')}>🛒 Alış İcmali</button>
        <button onClick={() => gz.git('/cari-icmali')}>📒 Cari İcmali</button>
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
          <select value={karsi} onChange={e => degistir({ karsi: e.target.value === 'od' ? 'od' : '' })}>
            <option value="gy">Geçen yılın aynı dönemi</option><option value="od">Önceki dönem</option>
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
        <label className="ti-chk"><input type="checkbox" checked={taslak} onChange={e => degistir({ taslak: e.target.checked ? '1' : '' })} /> Taslak belgeler dahil</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {veri && veri.aktarimTahakkuk.belge > 0 && <span className="bo-rz mavi"
          title="Delphi'den satırsız aktarılan geçmiş faturalar: tutarları cari hesapta, ürün / maliyet / KDV ayrıntısı olmadığı için bu icmale girmez">
          Aktarılan satış tahakkuku: {veri.aktarimTahakkuk.belge.toLocaleString('tr-TR')} belge · {veri.aktarimTahakkuk.tutar.toLocaleString('tr-TR', { maximumFractionDigits: 0 })} ₺ (icmale girmez)</span>}
        {veri && veri.dikkat.irsaliye.sayi > 0 && <span className="bo-rz sari" style={{ cursor: 'pointer' }} onClick={() => setSekme('dik')}>
          Faturası kesilmemiş irsaliye: {veri.dikkat.irsaliye.sayi}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Net Satış" deg={kisa(o.net, pb)} alt={kipYazi.replace(/ · [A-Z]{3} cinsinden$/, '')} sinif="mor" />
          <Kutu bas={karsi === 'od' ? 'Önceki Dönem' : 'Geçen Yıl Aynı Dönem'} deg={yuzde(o.degisim, true)} alt={`${tl(o.karsiNet)} ${simge(pb)}`}
            sinif={o.degisim == null ? '' : o.degisim >= 0 ? 'iyi' : 'teh'} />
          <Kutu bas="Belge" deg={sayi(o.belge)} alt={`fatura ${o.fatura} · fiş ${o.fis}`} />
          <Kutu bas="Müşteri" deg={sayi(o.musteri)} alt={`yeni müşteri ${o.yeniMusteri}`} />
          <Kutu bas="İade" deg={o.iade ? `−${kisa(o.iade, pb)}` : '—'} alt={`${o.iadeBelge} belge · satışın %${sayi(o.iadeOran)}'i`} sinif={o.iade ? 'teh' : ''} />
          <Kutu bas="İskonto" deg={o.iskonto ? `−${kisa(o.iskonto, pb)}` : '—'} alt={`brüt satışın %${sayi(o.iskontoOran)}'i`} />
          <Kutu bas="Brüt Kâr" deg={kisa(o.kar, pb)} alt={`marj ${yuzde(o.marj)} · ort. maliyetle`} sinif={o.kar >= 0 ? 'iyi' : 'teh'} />
          <Kutu bas="Vadesi Geçen" deg={kisa(o.vadesiGecen, pb)} alt="bu dönemin faturalarından" sinif={o.vadesiGecen > 0.005 ? 'uy' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['cari', 'Müşteri Bazında', veri.musteriler.length], ['stok', 'Ürün Bazında', null], ['donem', 'Gün / Ay Trendi', null],
              ['kir', 'Kırılımlar', null], ['dik', 'Dikkat', dikkatSayisi], ['onz', '🖨 Önizleme (A4)', null]]} />

            {(sekme === 'cari' || sekme === 'stok') && (
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder={sekme === 'cari' ? '🔍 Müşteri ya da temsilci…' : '🔍 Kod, ürün / hizmet ya da kategori…'} value={ara}
                  onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                <span className="ki-soluk">{sekme === 'cari'
                  ? 'satıra tıkla: belge listesi · çift tık: cari ekstresi · ada tıkla: cari kartı · net satışa göre sıralı'
                  : 'satıra tıkla: müşteri dağılımı · ada tıkla: stok kartı'}</span>
              </div>
            )}

            {sekme === 'cari' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Müşteri</th><th>Temsilci</th><th className="sag">Belge</th><th className="sag">Brüt</th><th className="sag">İskonto</th>
                    <th className="sag">İade</th><th className="sag">Net Satış</th><th className="sag">{karsiAdi}</th><th className="orta">Değişim</th>
                    <th className="sag">Brüt Kâr</th><th className="sag">Marj</th><th style={{ width: 100 }}>Pay</th></tr></thead>
                  <tbody>
                    {musteriler.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde satış yok.</td></tr>}
                    {musteriler.slice(0, 500).map(m => (
                      <MusteriSatiri key={m.id} m={m} acik={acik.has('c' + m.id)} secili={secili === m.id}
                        tikla={() => { setSecili(m.id); cevir('c' + m.id) }} cift={() => gz.ekstre(m.id)} kart={() => cariKarti(m)}
                        belgeAc={gz.belgeKarti} />
                    ))}
                    {musteriler.length > 500 && <tr><td colSpan={12} className="bos">… {musteriler.length - 500} müşteri daha (aramayla daraltın)</td></tr>}
                    <tr className="top"><td colSpan={2}>Toplam ({veri.musteriToplam.musteri} müşteri)</td>
                      <td className="sag">{veri.musteriToplam.belge}</td><td className="sag">{tl(veri.musteriToplam.brut)}</td>
                      <td className="sag">{eksi(veri.musteriToplam.iskonto)}</td><td className="sag">{eksi(veri.musteriToplam.iade)}</td>
                      <td className="sag">{tl(veri.musteriToplam.net)}</td><td className="sag">{tl(veri.musteriToplam.gecenYil)}</td>
                      <td className="orta">{yuzde(veri.musteriToplam.degisim, true)}</td><td className="sag">{tl(veri.musteriToplam.kar)}</td>
                      <td className="sag">{yuzde(veri.musteriToplam.marj)}</td><td /></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Net satış = brüt − iskonto − iade ({kdvDahil ? 'KDV dahil' : 'KDV hariç'}, belgenin dip toplamından; ekran toplamaz). Brüt kâr = net satış −
                satılan malın ortalama maliyeti; hizmet satırlarında maliyet 0. İrsaliyeden türeyen fatura bir kez sayılır; temsilci belgedeki
                satıcıdır. {pb ? `Tutarlar ${pb} cinsinden (belge kuruyla).` : 'Dövizli satışlar belge kuruyla TL; döviz rozeti satırın döviz tutarıdır.'}
              </div>
            </>}

            {sekme === 'stok' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Kod</th><th>Ürün / Hizmet</th><th>Kategori</th><th className="sag">Miktar</th><th className="sag">Ort. Fiyat</th>
                    <th className="sag">Liste Fiyatı</th><th className="sag">Net Satış</th><th className="sag">Maliyet</th><th className="sag">Brüt Kâr</th>
                    <th className="sag">Marj</th><th className="sag">Müşteri</th></tr></thead>
                  <tbody>
                    {urunler.length === 0 && <tr><td colSpan={11} className="bos">Kalem yok.</td></tr>}
                    {urunler.slice(0, 500).map(u => (
                      <Fragment key={u.anahtar}>
                        <tr className="ac" onClick={() => cevir('u' + u.anahtar)}>
                          <td><span className="ok">{acik.has('u' + u.anahtar) ? '▾' : '▸'}</span>{u.kod}</td>
                          <td>{u.stokId ? <span className="lnk" onClick={e => { e.stopPropagation(); gz.stokKarti(u.stokId) }}>{u.ad}</span> : u.ad}</td>
                          <td>{u.kategori}</td><td className="sag">{sayi(u.miktar)}</td>
                          <td className={'sag' + (u.dusukFiyat ? ' kir' : '')}>{u.ortFiyat == null ? '—' : tl(u.ortFiyat)}</td>
                          <td className="sag">{u.listeFiyati == null ? '—' : tl(u.listeFiyati)}</td>
                          <td className="sag"><b>{tl(u.net)}</b></td><td className="sag">{u.maliyet == null ? '—' : tl(u.maliyet)}</td>
                          <td className={'sag' + (u.eksiMarj ? ' kir' : '')}>{tl(u.kar)}</td>
                          <td className={'sag' + (u.eksiMarj ? ' kir' : '')}>{yuzde(u.marj)}{u.eksiMarj && ' ⚠'}</td>
                          <td className="sag">{u.musteri}</td></tr>
                        {acik.has('u' + u.anahtar) && (
                          <tr className="si-det"><td colSpan={11}>
                            {u.musteriler.map(m => `${m.ad}: ${sayi(m.miktar)} · ${tl(m.net)}`).join('   ·   ')}
                            {u.musteri > u.musteriler.length && `   · … ${u.musteri - u.musteriler.length} müşteri daha`}
                          </td></tr>
                        )}
                      </Fragment>
                    ))}
                    {urunler.length > 500 && <tr><td colSpan={11} className="bos">… {urunler.length - 500} kalem daha</td></tr>}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Ort. fiyat = net satış / miktar; liste fiyatının %10'dan fazla altındaki ortalama ve eksi marj kırmızı. Liste
                fiyatı stok kartının satış fiyatından (aynı para biriminde ise){kdvDahil ? '; KDV dahil kipinde karşılaştırma yapılmaz' : ''}.</div>
            </>}

            {sekme === 'donem' && <>
              {veri.trend.gunler && (
                <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                  <div className="si-seg">
                    <button type="button" className={!trendGun ? 'on' : ''} onClick={() => setTrendGun(false)}>Son 12 ay</button>
                    <button type="button" className={trendGun ? 'on' : ''} onClick={() => setTrendGun(true)}>Dönem gün gün</button>
                  </div>
                </div>
              )}
              {(!trendGun || !veri.trend.gunler) ? (
                <Kutucuk baslik="Aylık satış — son 12 ay" not="geçen yılla karşılaştırma · çubuk: net satış">
                  <table className="hi-tablo"><thead><tr><th>Ay</th><th className="sag">Net Satış</th><th className="sag">Geçen Yıl</th>
                    <th className="orta">Değişim</th><th className="sag">Belge</th><th className="sag">Brüt Kâr</th><th className="sag">Marj</th><th style={{ width: 220 }} /></tr></thead>
                    <tbody>
                      {veri.trend.aylar.map(a => (
                        <tr key={a.ay}><td>{a.kismiGun ? <b>{ayAdi(a.ay)} ({a.kismiGun}'i)</b> : ayAdi(a.ay)}</td>
                          <td className="sag">{tl(a.net)}</td><td className="sag">{tl(a.gecenYil)}</td>
                          <td className="orta"><DegisimRozeti d={a.degisim} /></td><td className="sag">{a.belge}</td>
                          <td className="sag">{tl(a.kar)}</td><td className="sag">{yuzde(a.marj)}</td><td><Cubuk yuzde={a.cubuk} /></td></tr>
                      ))}
                    </tbody></table>
                  <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Son ay bitiş gününe kadardır ve geçen yılın aynı günlerine karşılaştırılır
                    (ayın tamamıyla değil). Trend her zaman 12 aydır; şube, temsilci, para ve KDV seçimi uygulanır.</div>
                </Kutucuk>
              ) : (
                <Kutucuk baslik="Dönem gün gün" not={`${karsiAdi.toLocaleLowerCase('tr')} aynı günüyle`}>
                  <table className="hi-tablo"><thead><tr><th>Gün</th><th className="sag">Net Satış</th><th>{karsiAdi} günü</th><th className="sag">{karsiAdi}</th>
                    <th className="orta">Değişim</th><th className="sag">Belge</th><th className="sag">Brüt Kâr</th><th className="sag">Marj</th></tr></thead>
                    <tbody>
                      {(veri.trend.gunler ?? []).map(g => (
                        <tr key={g.tarih}><td>{new Date(g.tarih).toLocaleDateString('tr-TR', { weekday: 'short', day: '2-digit', month: '2-digit' })}</td>
                          <td className="sag">{tl(g.net)}</td><td className="ki-soluk">{tarihT(g.karsiTarih)}</td><td className="sag">{tl(g.karsi)}</td>
                          <td className="orta"><DegisimRozeti d={g.degisim} /></td><td className="sag">{g.belge}</td>
                          <td className="sag">{tl(g.kar)}</td><td className="sag">{yuzde(g.marj)}</td></tr>
                      ))}
                    </tbody></table>
                </Kutucuk>
              )}
            </>}

            {sekme === 'kir' && <>
              <div className="si-iki">
                <Kutucuk baslik="Temsilci" not="belgedeki satıcı">
                  <table className="hi-tablo"><thead><tr><th>Temsilci</th><th className="sag">Net Satış</th><th className="sag">Müşteri</th>
                    <th className="sag">Marj</th><th className="sag">Tahsil edilen</th></tr></thead>
                    <tbody>{veri.kirilim.temsilci.map(t => (
                      <tr key={t.id} className="ac" onDoubleClick={() => degistir({ temsilci: String(t.id) })}>
                        <td className={t.id === -1 ? 'ki-soluk' : ''}>{t.ad}</td><td className="sag">{tl(t.net)}</td><td className="sag">{t.musteri}</td>
                        <td className="sag">{yuzde(t.marj)}</td><td className="sag">{tl(t.tahsil)}</td></tr>))}</tbody></table>
                  <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Tahsil edilen: dönem faturalarının KDV dahil tutarından cari hareketinde
                    açık kalmayan kısım (FIFO, Cari İcmali ile aynı). Çift tık: temsilciyle süz.</div>
                </Kutucuk>
                <Kutucuk baslik="Kategori" not="ana kategori">
                  <table className="hi-tablo"><thead><tr><th>Kategori</th><th className="sag">Net Satış</th><th className="sag">Pay</th><th className="sag">Marj</th></tr></thead>
                    <tbody>{veri.kirilim.kategori.map(k => (
                      <tr key={k.ad}><td>{k.ad}</td><td className="sag">{tl(k.net)}</td><td className="sag">%{sayi(k.pay)}</td><td className="sag">{yuzde(k.marj)}</td></tr>))}</tbody></table>
                </Kutucuk>
              </div>
              <div className="si-iki">
                <Kutucuk baslik="Şube / depo">
                  <table className="hi-tablo"><thead><tr><th>Şube · Depo</th><th className="sag">Net Satış</th><th className="sag">Belge</th></tr></thead>
                    <tbody>{veri.kirilim.subeDepo.map(s => <tr key={s.ad}><td>{s.ad}</td><td className="sag">{tl(s.net)}</td><td className="sag">{s.belge}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Belge türü ve ödeme">
                  <table className="hi-tablo"><thead><tr><th>Tür</th><th className="sag">Net</th><th className="sag">Belge</th></tr></thead>
                    <tbody>{veri.kirilim.belgeTuru.map(s => <tr key={s.ad}><td>{s.ad}</td><td className={'sag' + (s.net < 0 ? ' kir' : '')}>{tl(s.net)}</td>
                      <td className="sag">{s.belge}</td></tr>)}</tbody></table>
                </Kutucuk>
              </div>
              <Kutucuk baslik="Para birimi" not="TL karşılığı belge kuruyla · kur farkı yalnız açık (tahsil edilmemiş) kısım için">
                <ParaTablosuGorunumu t={veri.kirilim.para} satis />
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Şeritte tek döviz seçilirse bütün sekmeler yalnız o dövizdeki belgeleri o dövizin
                  cinsinden gösterir (karışık para toplanmaz). Kur farkı tahmindir; gerçekleşen kur farkı tahsilatta fişlenir. Bu tablo her zaman TL karşılığıdır.</div>
              </Kutucuk>
            </>}

            {sekme === 'dik' && <>
              <div className="si-iki">
                <Kutucuk baslik="⚠ Zararına / maliyet altı satış" not="satış fiyatı ortalama maliyetin altında">
                  <table className="hi-tablo"><thead><tr><th>Belge</th><th>Müşteri</th><th>Ürün</th><th className="sag">Fiyat</th><th className="sag">Maliyet</th></tr></thead>
                    <tbody>
                      {veri.dikkat.zarar.length === 0 && <tr><td colSpan={5} className="bos">Maliyet altı satış yok.</td></tr>}
                      {veri.dikkat.zarar.map((z, i) => (
                        <tr key={i} className="ac" onDoubleClick={() => gz.belgeKarti(z.belgeId)}><td>{z.belgeNo || `#${z.belgeId}`}</td><td>{z.cari}</td><td>{z.urun}</td>
                          <td className="sag kir">{tl(z.fiyat)}</td><td className="sag">{tl(z.maliyet)}</td></tr>))}
                    </tbody></table>
                </Kutucuk>
                <Kutucuk baslik="📉 Satışı düşen müşteriler" not={`${karsiAdi.toLocaleLowerCase('tr')} göre −%20'den fazla`}>
                  <table className="hi-tablo"><thead><tr><th>Müşteri</th><th className="sag">Bu dönem</th><th className="sag">{karsiAdi}</th><th className="sag">Değişim</th></tr></thead>
                    <tbody>
                      {veri.dikkat.dusen.length === 0 && <tr><td colSpan={4} className="bos">Belirgin düşüş yok.</td></tr>}
                      {veri.dikkat.dusen.map(x => (
                        <tr key={x.id} className="ac" onDoubleClick={() => gz.ekstre(x.id)}><td>{x.ad}</td>
                          <td className={'sag' + (x.kayip ? ' ki-soluk' : '')}>{tl(x.simdi)}</td><td className="sag">{tl(x.once)}</td>
                          <td className="sag kir">{x.kayip ? 'kayıp müşteri' : yuzde(x.degisim, true)}</td></tr>))}
                    </tbody></table>
                </Kutucuk>
              </div>
              <div className="si-iki">
                <FaturasizKutusu v={veri.dikkat.irsaliye} baslik="🧾 Faturası kesilmemiş satış irsaliyeleri" belgeAc={gz.belgeKarti} />
                <Kutucuk baslik="📨 e-Belgesi gönderilmemiş fatura">
                  <table className="hi-tablo"><thead><tr><th>Belge</th><th>Müşteri</th><th>Tarih</th><th>Durum</th></tr></thead>
                    <tbody>
                      {veri.dikkat.ebelge.length === 0 && <tr><td colSpan={4} className="bos">Dönemin bütün faturaları gönderilmiş.</td></tr>}
                      {veri.dikkat.ebelge.map(x => (
                        <tr key={x.id} className="ac" onDoubleClick={() => gz.belgeKarti(x.id)}><td>{x.no || `#${x.id}`}{x.iade && ' (iade)'}</td>
                          <td>{x.cari}</td><td>{tarihT(x.tarih)}</td>
                          <td><span className={'bo-rz ' + (x.durum === 'gönderim hatası' ? 'kir' : 'sari')}>{x.durum}</span></td></tr>))}
                    </tbody></table>
                </Kutucuk>
              </div>
              <div className="ki-soluk si-not">Satır çift tık: belge kartı (müşteride cari ekstresi). Faturası kesilmemiş irsaliyeler satışa girmez; tutar açık
                satırların KDV hariç payıdır.</div>
            </>}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.belge} belge</span><span>{o.musteri} müşteri</span>
          <span>Karşılaştırma: {karsiAdi.toLocaleLowerCase('tr')} ({tarihT(veri.karsi.bas)} – {tarihT(veri.karsi.bit)})</span>
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}
    </div>
  );
}

function MusteriSatiri({ m, acik, secili, tikla, cift, kart, belgeAc }: {
  m: SatisMusteriSatiri; acik: boolean; secili: boolean; tikla(): void; cift(): void; kart(): void; belgeAc(id: number): void;
}) {
  return (
    <Fragment>
      <tr className={'ac' + (secili ? ' ti-sec' : '')} onClick={tikla} onDoubleClick={cift}>
        <td className="ti-ad"><span className="ok">{acik ? '▾' : '▸'}</span>
          <span className="lnk" onClick={e => { e.stopPropagation(); kart() }}>{m.ad}</span><DovizRozetleri l={m.doviz} /></td>
        <td className={m.temsilci === '(temsilcisiz)' ? 'ki-soluk' : ''}>{m.temsilci}</td>
        <td className="sag">{m.belge}</td><td className="sag">{tl(m.brut)}</td><td className="sag">{eksi(m.iskonto)}</td>
        <td className={'sag' + (m.iade ? ' kir' : ' ki-soluk')}>{eksi(m.iade)}</td>
        <td className="sag"><b>{tl(m.net)}</b></td>
        <td className={'sag' + (m.gecenYil == null ? ' ki-soluk' : '')}>{m.gecenYil == null ? '—' : tl(m.gecenYil)}</td>
        <td className="orta"><DegisimRozeti d={m.degisim} yeni={m.yeni && m.gecenYil == null} /></td>
        <td className={'sag' + (m.dusukMarj ? ' kir' : '')}>{tl(m.kar)}</td>
        <td className={'sag' + (m.dusukMarj ? ' kir' : '')}>{yuzde(m.marj)}{m.dusukMarj && ' ⚠'}</td>
        <td><Cubuk yuzde={m.cubuk} /></td>
      </tr>
      {acik && (
        <tr className="si-det"><td colSpan={12}>
          {m.belgeler.map((b, i) => (
            <Fragment key={b.id}>{i > 0 && '  ·  '}
              <span className="lnk" onClick={() => belgeAc(b.id)}>{b.no || `#${b.id}`}</span> {tarihT(b.tarih).slice(0, 5)}
              {b.iade ? <span className="kir"> iade −{tl(b.tutar)}</span> : ` · ${tl(b.tutar)}`}
            </Fragment>
          ))}
          {m.belgeSayisi > m.belgeler.length && `  ·  … ${m.belgeSayisi - m.belgeler.length} belge daha`}
        </td></tr>
      )}
    </Fragment>
  );
}

function SatisA4({ v, satirlar, antet, duzenleyen, sube, temsilci, kip }: {
  v: Veri; satirlar: SatisMusteriSatiri[]; antet: Record<string, unknown> | null; duzenleyen: string;
  sube: string; temsilci: string; kip: string;
}) {
  const o = v.ozet;
  const pb = simge(v.para);
  const dovizli = v.para ? [] : v.kirilim.para.satirlar.filter(p => !p.yerel && p.doviz);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>SATIŞ İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>{kip}</span>
        <span>Şube: {sube} · Temsilci: {temsilci}</span><span>{o.belge} belge · {o.musteri} müşteri</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Müşteri</th><th>Belge</th><th>Net Satış</th><th>{v.karsi.tur === 'od' ? 'Önceki Dönem' : 'Geçen Yıl'}</th><th>Marj</th></tr></thead>
        <tbody>{satirlar.map(m => <tr key={m.id}><td>{m.ad}</td><td>{m.belge}</td><td>{tl(m.net)}</td>
          <td>{m.gecenYil == null ? '—' : tl(m.gecenYil)}</td><td>{yuzde(m.marj)}</td></tr>)}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>Brüt satış</span><span>{tl(o.brut)}</span></div>
        <div><span>İskonto</span><span>{eksi(o.iskonto)}</span></div>
        <div><span>İade{v.iadeDus ? '' : ' (düşülmedi)'}</span><span>{eksi(o.iade)}</span></div>
        <div className="b"><span>NET SATIŞ</span><span>{tl(o.net)} {pb}</span></div>
        {dovizli.length > 0 && <div className="not"><span>bunun {dovizli.map(p => `${simge(p.para)} ${tl(p.doviz ?? 0)} (ort. kur ${(p.ortKur ?? 0).toLocaleString('tr-TR', { maximumFractionDigits: 4 })})`).join(', ')} dövizli</span><span /></div>}
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Satış Müdürü<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Satış İcmali · tutarlar belge dip toplamlarından (fn_belge_diptoplam) · {kip}</p>
    </div>
  );
}

export default SatisIcmali;
