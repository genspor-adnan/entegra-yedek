import { Fragment, useEffect, useState } from 'react';
import { hataMetni } from '../../api/sozlesme';
import {
  temsilciPerformansUclari, type DonemKipi, type HedefListesi, type TemsilciPerformans as Veri,
} from '../../api/uclar/temsilciPerformans';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { Modal } from '../../bilesenler/Modal';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import { EkranA4, eksi, kisa, sayi, tarihT, TICARI_ICMAL_STILI, tl, useGezinti, yuzde } from './ticariIcmalOrtak';

/**
 * TEMSİLCİ PERFORMANS İCMALİ `/temsilci-performans` - mockup Ekranlar/İcmal/temsilci_performans_icmali.html
 * (kararlar 25.10.2026). "Hangi temsilci hedefinde, kim kârlı satıyor, kimin müşterisi ödemiyor, prim ne çıkıyor?"
 * Rakamlar SUNUCUDAN (TemsilciPerformansUclari): temsilci faturadan (satıcı), ciro / kâr Kârlılık İcmali kuralıyla,
 * vade ve ödeme davranışı müşterinin temsilcisine göre, prim Prim Planı'nın hakediş satırlarından. Ekran hesap yapmaz.
 */
type Sekme = 'ozt' | 'hdf' | 'gid' | 'prt' | 'tah' | 'akt' | 'prm' | 'onz';

const KIP_ADI: Record<DonemKipi, string> = { ay: 'Ay', ceyrek: 'Çeyrek', yil: 'Yıl' };
const SKOR_SINIF: Record<string, string> = { A: 'ok', B: 'mavi', C: 'sari', D: 'kir' };
const ayKisa = (t: string) => new Date(t).toLocaleDateString('tr-TR', { month: 'short' });
const ayUzun = (t: string) => new Date(t).toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' });

function donemAdi(v: Pick<Veri, 'kip' | 'bas' | 'bit'>) {
  const d = new Date(v.bas);
  if (v.kip === 'yil') return String(d.getFullYear());
  if (v.kip === 'ceyrek') return `${Math.floor(d.getMonth() / 3) + 1}. çeyrek ${d.getFullYear()}`;
  return ayUzun(v.bas);
}

/** Dönem kaydırma: ay / çeyrek / yıl kadar ileri - geri (tarih YYYY-MM-DD). */
function kaydir(tarih: string, kip: DonemKipi, yon: number) {
  const d = new Date(tarih + 'T00:00:00Z');
  const ay = kip === 'yil' ? 12 : kip === 'ceyrek' ? 3 : 1;
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + yon * ay, 1)).toISOString().slice(0, 10);
}

function HedefCubugu({ oran }: { oran?: number }) {
  if (oran == null) return <span className="ki-soluk">—</span>;
  const renk = oran >= 100 ? '#2e7d46' : oran >= 80 ? undefined : '#c0413d';
  return <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}><Cubuk yuzde={oran} renk={renk} /> %{sayi(oran)}</span>;
}

export function TemsilciPerformansIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useGezinti();
  const kip = (['ay', 'ceyrek', 'yil'].includes(arama.get('kip') ?? '') ? arama.get('kip') : 'ay') as DonemKipi;
  const tarih = arama.get('tarih') ?? bugunYerel();
  const sube = Number(arama.get('sube') ?? 0);
  const iadeDus = arama.get('iadesiz') !== '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('ozt');
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const [secili, setSecili] = useState(0);
  const [hedefAcik, setHedefAcik] = useState(false);
  const [tazele, setTazele] = useState(0);
  const [bilgi, setBilgi] = useState('');

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ kip, tarih });
    if (sube) q.set('sube', String(sube));
    if (!iadeDus) q.set('iade', '0');
    temsilciPerformansUclari.temsilciPerformans(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [kip, tarih, sube, iadeDus, tazele]);

  const cevir = (id: number) => setAcik(a => { const n = new Set(a); n.has(id) ? n.delete(id) : n.add(id); return n });
  const o = veri?.ozet;
  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tümü';
  const kipYazi = `KDV hariç${iadeDus ? ' · iadeler düşülmüş' : ' · iadeler düşülmemiş'}`;
  const a4 = veri && <TemsilciA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi} kip={kipYazi} />;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Temsilci Performans İcmali</h1><span className="yol">Satış › İcmaller › Temsilci Performans İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Performans İcmali" dosyaAdi={`Temsilci Performans İcmali ${veri ? donemAdi(veri) : ''}`} devre={!veri}>{a4}</CiktiMenusu>
        <button disabled={secili <= 0} onClick={() => gz.git(`/personel/${secili}`)}
          title={secili > 0 ? '' : 'Önce bir temsilci satırına tıklayın'}>👤 Personel kartı</button>
        <button onClick={() => gz.git('/cari')}>📋 Müşteri listesi</button>
        {veri?.hedefYetkisi && <button onClick={() => setHedefAcik(true)}>🎯 Hedef tanımla…</button>}
        <span className="sp" />
        <button onClick={() => gz.git('/karlilik-icmali')}>💹 Kârlılık İcmali</button>
        <button onClick={() => gz.git('/teklif-icmali')}>🎯 Teklif Dönüşüm</button>
        <button onClick={() => gz.git('/musteri-risk-icmali')}>🛡️ Müşteri Risk</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="not" style={{ margin: '0 12px' }}>{bilgi}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Dönem:
          <button type="button" onClick={() => degistir({ tarih: kaydir(tarih, kip, -1) })} title="Önceki">◀</button>
          <b>{veri ? donemAdi(veri) : '…'}</b>
          <button type="button" onClick={() => degistir({ tarih: kaydir(tarih, kip, 1) })} title="Sonraki">▶</button>
        </div>
        <div className="si-seg">
          {(['ay', 'ceyrek', 'yil'] as DonemKipi[]).map(k => (
            <button key={k} type="button" className={kip === k ? 'on' : ''} onClick={() => degistir({ kip: k === 'ay' ? '' : k })}>{KIP_ADI[k]}</button>
          ))}
        </div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <label className="ti-chk"><input type="checkbox" checked={iadeDus} onChange={e => degistir({ iadesiz: e.target.checked ? '' : '1' })} /> İadeler düşülsün</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.temsilcisizCiro > 0.005 && <span className="bo-rz sari" title="Faturada temsilci (satıcı) seçilmemiş: toplama girer, prime ve hedefe girmez">
          Temsilcisiz fatura cirosu: {kisa(o.temsilcisizCiro, '')}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Toplam Ciro" deg={kisa(o.ciro, '')} alt={o.hedef != null ? `hedef ${tl(o.hedef)} · %${sayi(o.hedefOran ?? 0)}` : 'temsilcili faturalar · hedef yok'} sinif="mor" />
          <Kutu bas="Brüt Kâr" deg={kisa(o.kar, '')} alt={`marj ${yuzde(o.marj)}`} sinif={o.kar >= 0 ? 'iyi' : 'teh'} />
          <Kutu bas="Tahsilat" deg={kisa(o.tahsilat, '')} alt={`ciroya oran ${yuzde(o.tahsilatOran)} · dönem faturalarından`} />
          <Kutu bas="Vadesi Geçen" deg={kisa(o.vadesiGecen, '')} alt={`${o.vadesiGecenMusteri} müşteri`} sinif={o.vadesiGecen > 0.005 ? 'teh' : ''} />
          <Kutu bas="Yeni Müşteri" deg={sayi(o.yeniMusteri)} alt="ilk faturası bu dönemde" />
          <Kutu bas="Ort. İskonto" deg={yuzde(o.iskontoOran)} alt="brüt satışa göre" sinif={(o.iskontoOran ?? 0) > 10 ? 'uy' : ''} />
          <Kutu bas="Teklif" deg={sayi(o.teklif)} alt="dönemde verilen (iptal hariç)" />
          <Kutu bas="Hakediş (Prim)" deg={o.prim != null ? kisa(o.prim, '') : '—'} alt={veri.prim.planVar ? 'Prim Planı hakediş satırları' : 'Prim Planı tanımlı değil'} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['ozt', 'Özet', veri.temsilciler.length], ['hdf', 'Hedef / Gerçekleşen', veri.hedefler.length || null], ['gid', 'Aylık Gidişat', null],
              ['prt', 'Müşteri Portföyü', null], ['tah', 'Tahsilat Kalitesi', null], ['akt', 'Aktivite', null],
              ['prm', 'Prim', veri.prim.satirlar.length || null], ['onz', '🖨 Önizleme (A4)', null]]} />

            {sekme === 'ozt' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Temsilci</th><th className="sag">Ciro</th><th className="sag">Brüt kâr</th><th className="sag">Marj</th>
                    <th className="sag">Tahsilat</th><th className="sag">Vadesi geçen</th><th className="sag">Aktif müşteri</th><th className="sag">Yeni</th>
                    <th className="sag">Ort. iskonto</th><th className="sag">Teklif</th><th style={{ width: 150 }}>Hedef (ciro)</th></tr></thead>
                  <tbody>
                    {veri.temsilciler.length === 0 && <tr><td colSpan={11} className="bos">Bu dönemde satış yok.</td></tr>}
                    {veri.temsilciler.map(t => (
                      <Fragment key={t.id}>
                        <tr className={'ac' + (secili === t.id ? ' ti-sec' : '')} onClick={() => { cevir(t.id); setSecili(t.id) }}>
                          <td className={t.id === -1 ? 'ki-soluk' : ''}><span className="ok">{acik.has(t.id) ? '▾' : '▸'}</span>{t.ad}</td>
                          <td className="sag">{tl(t.ciro)}</td><td className={'sag' + (t.kar < 0 ? ' kir' : '')}>{tl(t.kar)}</td>
                          <td className="sag">{yuzde(t.marj)}</td><td className="sag">{tl(t.tahsilat)}</td>
                          <td className={'sag' + (t.vadesiGecen > 0.005 ? ' kir' : '')}>{tl(t.vadesiGecen)}</td>
                          <td className="sag">{t.aktifMusteri}</td><td className="sag">{t.yeniMusteri || '—'}</td>
                          <td className="sag">{yuzde(t.iskontoOran)}</td><td className="sag">{t.teklif || '—'}</td>
                          <td>{t.id === -1 ? '—' : <HedefCubugu oran={t.hedefOran} />}</td></tr>
                        {acik.has(t.id) && (
                          <tr className="si-det"><td colSpan={11}>
                            {t.musteriler.length === 0 ? 'Bu dönemde müşteri yok.' : t.musteriler.map((m, i) => (
                              <Fragment key={m.id}>{i > 0 && '   ·   '}<span className="lnk" onClick={() => gz.cariKarti(m.id)}>{m.ad}</span>: {tl(m.net)} · kâr {tl(m.kar)}</Fragment>
                            ))}
                            {t.aktifMusteri > t.musteriler.length && `   · … ${t.aktifMusteri - t.musteriler.length} müşteri daha`}
                          </td></tr>
                        )}
                      </Fragment>
                    ))}
                    <tr className="top"><td>Toplam</td><td className="sag">{tl(veri.toplam.ciro)}</td><td className="sag">{tl(veri.toplam.kar)}</td>
                      <td className="sag">{yuzde(veri.toplam.marj)}</td><td className="sag">{tl(veri.toplam.tahsilat)}</td>
                      <td className="sag">{tl(veri.toplam.vadesiGecen)}</td><td className="sag">{veri.toplam.aktifMusteri}</td>
                      <td className="sag">{veri.toplam.yeniMusteri}</td><td className="sag">{yuzde(veri.toplam.iskontoOran)}</td>
                      <td className="sag">{veri.toplam.teklif}</td><td /></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Temsilci FATURADAN (faturadaki satıcı) - cari başka temsilciye geçse de eski faturalar eski temsilcide kalır. Faturasında temsilci
                olmayan satış "(temsilcisiz)" satırında: toplama girer, prime ve hedefe girmez. Ciro ve brüt kâr Kârlılık İcmali ile aynı (KDV hariç,
                satış anı maliyeti); tahsilat = dönem faturalarının açık kalmayan kısmı (FIFO). Vadesi geçen: müşterinin temsilcisine (son 12 ayın en
                çok satış yapanı) göre, Cari İcmali yaşlandırması. Satıra tıkla: müşteriler.
              </div>
            </>}

            {sekme === 'hdf' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Temsilci</th><th>Ölçüt</th><th className="sag">Hedef</th><th className="sag">Gerçekleşen</th><th style={{ width: 160 }}>Oran</th>
                    <th className="sag">Kalan</th><th className="sag">{veri.tahminVar ? 'Dönem sonu tahmini' : 'Tahmin'}</th></tr></thead>
                  <tbody>
                    {veri.hedefler.length === 0 && <tr><td colSpan={7} className="bos">
                      Bu dönem için hedef tanımlı değil.{veri.hedefYetkisi && <> <span className="lnk" onClick={() => setHedefAcik(true)}>Hedef tanımla…</span></>}</td></tr>}
                    {veri.hedefler.map(h => {
                      const adet = h.olcut === 4;
                      const f = (n: number) => (adet ? sayi(n) : tl(n));
                      return (
                        <tr key={`${h.temsilciId}-${h.olcut}`}>
                          <td>{h.temsilci}</td><td>{h.olcutAdi}</td><td className="sag">{f(h.hedef)}</td><td className="sag">{f(h.gerceklesen)}</td>
                          <td><HedefCubugu oran={h.oran} /></td><td className="sag">{h.kalan > 0 ? f(h.kalan) : '—'}</td>
                          <td className={'sag' + (h.tahmin != null && h.tahmin < h.hedef ? ' kir' : '')}>{h.tahmin == null ? '—' : f(h.tahmin)}</td></tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Hedef temsilci × ay × ölçüt (ciro, brüt kâr, tahsilat, yeni müşteri); çeyrek / yıl seçiliyse ayların toplamı.
                Dönem sonu tahmini yalnız içinde bulunulan dönemde: bugüne kadarki hızla doğrusal (gerçekleşen × dönem günü / geçen gün).</div>
            </>}

            {sekme === 'gid' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Temsilci</th>{veri.gidisat.aylar.map(a => <th key={a} className="sag">{ayKisa(a)}</th>)}
                    <th className="sag">Geçen yıl {ayKisa(veri.gidisat.gecenYilAy)}</th><th className="sag">Değişim</th></tr></thead>
                  <tbody>
                    {veri.gidisat.satirlar.length === 0 && <tr><td colSpan={9} className="bos">Satış yok.</td></tr>}
                    {veri.gidisat.satirlar.map(s => (
                      <tr key={s.id}><td className={s.id === -1 ? 'ki-soluk' : ''}>{s.ad}</td>
                        {s.degerler.map((d, i) => <td key={i} className="sag">{tl(d)}</td>)}
                        <td className="sag">{s.gecenYil == null ? '—' : tl(s.gecenYil)}</td>
                        <td className={'sag ' + (s.degisim == null ? 'ki-soluk' : s.degisim >= 0 ? 'si-yesil' : 'kir')}>
                          {s.degisim == null ? (s.gecenYil == null ? 'yeni' : '—') : yuzde(s.degisim, true)}</td></tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Son 6 ayın net cirosu (dönem sonunun ayı dahil) ve geçen yılın aynı ayı; tutarlar Satış / Kârlılık İcmali ile aynı.</div>
            </>}

            {sekme === 'prt' && <>
              <table className="hi-tablo">
                <thead><tr><th>Temsilci</th><th className="sag">Müşteri</th><th className="sag">Bu dönem alan</th><th className="sag">90 gündür almayan</th>
                  <th className="sag">Kaybedilen (12 ay)</th><th className="sag">İlk 5 müşteri payı</th><th className="sag">Limit aşan</th></tr></thead>
                <tbody>
                  {veri.portfoy.map(p => (
                    <tr key={p.id}><td className={p.id === -1 ? 'ki-soluk' : ''}>{p.ad}</td><td className="sag">{p.musteri}</td><td className="sag">{p.buDonemAlan}</td>
                      <td className={'sag' + (p.almayan90 > 0 ? ' kir' : '')}>{p.almayan90}</td><td className={'sag' + (p.kaybedilen > 0 ? ' kir' : '')}>{p.kaybedilen}</td>
                      <td className="sag">{p.ilk5Pay == null ? '—' : `%${sayi(p.ilk5Pay)}`}</td><td className={'sag' + (p.limitAsan > 0 ? ' kir' : '')}>{p.limitAsan}</td></tr>
                  ))}
                </tbody>
              </table>
              <div className="ki-soluk si-not">Müşterinin temsilcisi: son 12 ayda ona en çok satış yapan (yoksa önceki 12 ayın). 90 gündür almayan: son 12 ayda alıp
                son 90 günde faturası olmayan. Kaybedilen: önceki 12 ayda alıp son 12 ayda hiç almayan. Limit aşan: bakiyesi risk limitini geçen (Cari İcmali).</div>
            </>}

            {sekme === 'tah' && <>
              <table className="hi-tablo">
                <thead><tr><th>Temsilci</th><th className="sag">Tahsilat</th><th className="sag">Ort. tahsil süresi</th><th className="sag">Ort. gecikme</th>
                  <th className="sag">Zamanında</th><th className="sag">Vadesi geçen</th><th className="sag">90+</th><th className="sag">Karşılıksız (12 ay)</th><th className="orta">Skor</th></tr></thead>
                <tbody>
                  {veri.tahsilat.map(t => (
                    <tr key={t.id}><td className={t.id === -1 ? 'ki-soluk' : ''}>{t.ad}</td><td className="sag">{tl(t.tahsilat)}</td>
                      <td className="sag">{t.ortTahsilGun == null ? '—' : `${sayi(t.ortTahsilGun)} gün`}</td>
                      <td className={'sag' + ((t.ortGecikme ?? 0) > 15 ? ' kir' : '')}>{t.ortGecikme == null ? '—' : `${sayi(t.ortGecikme)} gün`}</td>
                      <td className="sag">{t.zamaninda == null ? '—' : `%${sayi(t.zamaninda)}`}</td>
                      <td className={'sag' + (t.vadesiGecen > 0.005 ? ' kir' : '')}>{tl(t.vadesiGecen)}</td>
                      <td className={'sag' + (t.d90p > 0.005 ? ' kir' : '')}>{t.d90p > 0.005 ? tl(t.d90p) : '—'}</td>
                      <td className={'sag' + (t.karsiliksiz > 0 ? ' kir' : '')}>{t.karsiliksiz || '—'}</td>
                      <td className="orta">{t.skor ? <span className={'bo-rz ' + SKOR_SINIF[t.skor]} title={`${t.skorPuan} puan`}>{t.skor}</span> : '—'}</td></tr>
                  ))}
                </tbody>
              </table>
              <div className="ki-soluk si-not">Müşteri Risk İcmali'nin kuralları: ödeme süresi FIFO (fatura → onu kapatan tahsilat, son 12 ay), skor aynı yöntemle (A–D),
                temsilcinin müşterilerinin fatura sayısıyla ağırlıklı ortalama.</div>
            </>}

            {sekme === 'akt' && <>
              <table className="hi-tablo">
                <thead><tr><th>Temsilci</th><th className="sag">Görüşme</th><th className="sag">Toplantı</th><th className="sag">Görev</th><th className="sag">Teklif</th>
                  <th className="sag">Açık görev</th><th className="sag">Geciken görev</th><th className="sag">Temas başına ciro</th></tr></thead>
                <tbody>
                  {veri.aktivite.length === 0 && <tr><td colSpan={8} className="bos">Temsilci yok.</td></tr>}
                  {veri.aktivite.map(a => (
                    <tr key={a.id}><td>{a.ad}</td><td className="sag">{a.gorusme}</td><td className="sag">{a.toplanti}</td><td className="sag">{a.gorev}</td>
                      <td className="sag">{a.teklif}</td><td className="sag">{a.acikGorev}</td>
                      <td className={'sag' + (a.gecikenGorev > 0 ? ' kir' : '')}>{a.gecikenGorev}</td>
                      <td className="sag">{a.temasBasinaCiro == null ? '—' : tl(a.temasBasinaCiro)}</td></tr>
                  ))}
                </tbody>
              </table>
              <div className="ki-soluk si-not">Görev kayıtlarından (sorumlu = temsilci): görüşme / aktivite, toplantı, görev - dönemde başlayanlar; açık ve geciken bugün
                itibarıyla. Kayıt girilmiyorsa sütun sıfır görünür - performans değil kayıt alışkanlığı ölçülür, dikkatle yorumlayın.</div>
            </>}

            {sekme === 'prm' && <>
              {!veri.prim.planVar && <div className="not">Prim Planı tanımlı değil - prim hesaplanmıyor. Prim Planı ekranından plan tanımlanınca hakediş satırları burada görünür.</div>}
              {veri.prim.planVar && <>
                <table className="hi-tablo">
                  <thead><tr><th>Temsilci</th><th>Plan</th><th className="sag">Taslak</th><th className="sag">Kesin</th><th className="sag">Onaylı</th>
                    <th className="sag">Ödendi</th><th className="sag">Toplam</th></tr></thead>
                  <tbody>
                    {veri.prim.satirlar.length === 0 && <tr><td colSpan={7} className="bos">Bu dönemde hakediş satırı yok.</td></tr>}
                    {veri.prim.satirlar.map(p => (
                      <tr key={p.id}><td>{p.ad}</td><td>{p.plan || '—'}</td><td className="sag">{tl(p.taslak)}</td><td className="sag">{tl(p.kesin)}</td>
                        <td className="sag">{tl(p.onayli)}</td><td className="sag">{tl(p.odendi)}</td><td className="sag"><b>{tl(p.toplam)}</b></td></tr>
                    ))}
                    <tr className="top"><td colSpan={2}>Toplam</td><td className="sag">{tl(veri.prim.toplam.taslak)}</td><td className="sag">{tl(veri.prim.toplam.kesin)}</td>
                      <td className="sag">{tl(veri.prim.toplam.onayli)}</td><td className="sag">{tl(veri.prim.toplam.odendi)}</td>
                      <td className="sag">{tl(veri.prim.toplam.toplam)}</td></tr>
                  </tbody>
                </table>
                <div className="ki-soluk si-not">Prim Planı motorunun yazdığı hakediş satırları (iptal hariç), satır tarihine göre dönemde. İcmal prim hesaplamaz;
                  onay ve ödeme Prim / Hakediş ekranlarından. Temsilcisiz satış prime girmez.</div>
              </>}
            </>}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>
      </>)}

      {hedefAcik && veri && (
        <HedefModali ay={veri.bas} onKapat={() => setHedefAcik(false)}
          onTamam={m => { setHedefAcik(false); setBilgi(m); setTazele(x => x + 1) }} />
      )}
    </div>
  );
}

/** HEDEF TANIMLA: seçili ayın hedefleri temsilci × ölçüt ızgarasında; değişen hücre tek tek yazılır (loglu). */
function HedefModali({ ay, onKapat, onTamam }: { ay: string; onKapat(): void; onTamam(m: string): void }) {
  const [donem, setDonem] = useState(ay.slice(0, 7));
  const [liste, setListe] = useState<HedefListesi | null>(null);
  const [deger, setDeger] = useState<Record<string, string>>({});
  const [hata, setHata] = useState('');
  const [isliyor, setIsliyor] = useState(false);
  const anahtar = (t: number, o: number) => `${t}-${o}`;

  useEffect(() => {
    setHata('');
    temsilciPerformansUclari.temsilciHedefleri(`${donem}-01`).then(l => {
      setListe(l);
      setDeger(Object.fromEntries(l.hedefler.map(h => [anahtar(h.temsilciId, h.olcut), String(h.hedef).replace('.', ',')])));
    }).catch(h => setHata(hataMetni(h)));
  }, [donem]);

  const kaydet = async () => {
    if (!liste) return;
    const eski = Object.fromEntries(liste.hedefler.map(h => [anahtar(h.temsilciId, h.olcut), h.hedef]));
    const yazilacak: { temsilciId: number; olcut: number; hedef: number | null }[] = [];
    for (const t of liste.temsilciler) for (const o of liste.olcutler) {
      const ham = (deger[anahtar(t.id, o.id)] ?? '').trim();
      const sayiDeger = ham === '' ? null : Number(ham.replace(/\./g, '').replace(',', '.'));
      if (sayiDeger != null && (Number.isNaN(sayiDeger) || sayiDeger < 0)) { setHata(`${t.ad} · ${o.ad}: geçersiz sayı.`); return }
      const once = eski[anahtar(t.id, o.id)] ?? null;
      if ((sayiDeger || null) !== (once || null)) yazilacak.push({ temsilciId: t.id, olcut: o.id, hedef: sayiDeger || null });
    }
    if (yazilacak.length === 0) { onTamam('Hedeflerde değişiklik yok.'); return }
    setIsliyor(true); setHata('');
    try {
      for (const y of yazilacak) await temsilciPerformansUclari.temsilciHedefYaz({ ...y, donem: `${donem}-01` });
      onTamam(`${yazilacak.length} hedef güncellendi (${ayUzun(`${donem}-01`)}).`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };

  return (
    <Modal baslik="🎯 Temsilci hedefleri" buyutmeYok onKapat={onKapat}
      alt={<>
        <button type="button" className="b" disabled={isliyor || !liste?.yetki} onClick={() => void kaydet()}>Kaydet</button>
        <button type="button" className="d" onClick={onKapat}>✖ Vazgeç</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="alan"><label>Ay</label><input type="month" value={donem} onChange={e => e.target.value && setDonem(e.target.value)} /></div>
      {!liste ? <div className="ki-soluk">yükleniyor…</div> : (
        <div style={{ maxHeight: 420, overflow: 'auto' }}>
          <table className="hi-tablo">
            <thead><tr><th>Temsilci</th>{liste.olcutler.map(o => <th key={o.id} className="sag">{o.ad}</th>)}</tr></thead>
            <tbody>
              {liste.temsilciler.length === 0 && <tr><td colSpan={5} className="bos">Temsilci yok (aktif personel ya da satıcı).</td></tr>}
              {liste.temsilciler.map(t => (
                <tr key={t.id}><td>{t.ad}</td>
                  {liste.olcutler.map(o => (
                    <td key={o.id} className="sag">
                      <input style={{ width: 110, textAlign: 'right' }} inputMode="decimal" placeholder="—" disabled={!liste.yetki}
                        value={deger[anahtar(t.id, o.id)] ?? ''} onChange={e => setDeger(d => ({ ...d, [anahtar(t.id, o.id)]: e.target.value }))} /></td>
                  ))}</tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <div className="not">Boş = o ölçüt için hedef yok. Tutarlar TL (KDV hariç ciro / brüt kâr; tahsilat KDV dahil); yeni müşteri adet. Her değişiklik loglanır.</div>
    </Modal>
  );
}

function TemsilciA4({ v, antet, duzenleyen, sube, kip }: {
  v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; sube: string; kip: string;
}) {
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>TEMSİLCİ PERFORMANS İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{donemAdi(v)}</b> ({tarihT(v.bas)} – {tarihT(v.bit)})</span><span>Şube: {sube}</span>
        <span>{kip}</span><span>Temsilci: faturadaki satıcı · brüt kâr Kârlılık İcmali kuralı</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Temsilci</th><th>Ciro</th><th>Brüt kâr</th><th>Tahsilat</th><th>Vadesi geçen</th><th>Hedef %</th></tr></thead>
        <tbody>{v.temsilciler.map(t => <tr key={t.id}><td>{t.ad}</td><td>{tl(t.ciro)}</td><td>{tl(t.kar)}</td><td>{tl(t.tahsilat)}</td>
          <td>{tl(t.vadesiGecen)}</td><td>{t.hedefOran == null ? '—' : `%${sayi(t.hedefOran)}`}</td></tr>)}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>Ciro (temsilcili)</span><span>{tl(v.ozet.ciro)}</span></div>
        {v.ozet.temsilcisizCiro > 0.005 && <div><span>Temsilcisiz ciro</span><span>{tl(v.ozet.temsilcisizCiro)}</span></div>}
        <div><span>Brüt kâr</span><span>{tl(v.ozet.kar)}</span></div>
        <div><span>Tahsilat</span><span>{tl(v.ozet.tahsilat)}</span></div>
        {v.ozet.vadesiGecen > 0.005 && <div><span>Vadesi geçen</span><span>{eksi(v.ozet.vadesiGecen)}</span></div>}
        <div className="b"><span>HAKEDİŞ (PRİM)</span><span>{v.ozet.prim == null ? '—' : `${tl(v.ozet.prim)} ₺`}</span></div>
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Satış Müdürü<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Temsilci Performans İcmali · temsilcisiz satış prime girmez · hakediş Prim Planı satırlarından (onaydan sonra kesinleşir)</p>
    </div>
  );
}

export default TemsilciPerformansIcmali;
