import { Fragment, useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import { servisIcmalUclari, type TeknikServisIcmali as Veri, type ServisTeknisyenSatiri } from '../../api/uclar/servisIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { EkranA4, kisa, sayi, tarihT, TICARI_ICMAL_STILI, tl, yuzde } from '../ticariIcmal/ticariIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';

/**
 * TEKNİK SERVİS İCMALİ `/teknik-servis-icmali` - mockup Ekranlar/İcmal/teknik_servis_icmali.html
 * (kararlar 25.10.2026). "Taahhüdümüzü tutuyor muyuz, hangi teknisyen ilk gidişte çözüyor, hangi cihaz
 * sık arızalanıyor, sözleşmeler kâr ediyor mu, faturalanmayı unuttuğumuz iş var mı?"
 * Rakamlar SUNUCUDAN (ServisIcmalUclari): çağrı → iş emri → ziyaret, dönem çağrının açılışına göre;
 * ciro = ücretli + üretici garantisi, sözleşme / kendi garantimiz / iç iş servis maliyetidir.
 */
type Sekme = 'ozt' | 'tek' | 'cih' | 'sla' | 'prc' | 'emn' | 'soz' | 'ftr' | 'onz';
const ayBasi = () => bugunYerel().slice(0, 8) + '01';
const saat = (n: number | null | undefined) => (n == null ? '—' : `${n.toLocaleString('tr-TR', { maximumFractionDigits: 1 })} saat`);
const KAPSAMLAR: [number, string][] = [[0, 'Tüm kapsam'], [1, 'Ücretli'], [2, 'Sözleşme'], [3, 'Üretici garantisi'], [4, 'Kendi garantimiz']];
const SAHIPLIK: [number, string, string][] = [[2, 'Dış (müşteri)', '2'], [1, 'İç (demirbaş)', '1'], [0, 'İkisi', '3']];
const SLA_ROZET: Record<string, [string, string]> = { uygun: ['ok', 'uygun'], sinirda: ['sari', 'sınırda'], ihlal: ['kir', 'ihlal'] };

function hazirDonem(k: 'buay' | 'gecenay' | 'buyil'): [string, string] {
  const b = new Date();
  const s = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  if (k === 'buyil') return [`${b.getFullYear()}-01-01`, bugunYerel()];
  if (k === 'gecenay') return [s(new Date(b.getFullYear(), b.getMonth() - 1, 1)), s(new Date(b.getFullYear(), b.getMonth(), 0))];
  return [ayBasi(), bugunYerel()];
}

/** Kart ve liste gezintisi (kart sekmesi deseni: kendi sekmesinde). */
function useServisGezinti() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  const kart = (yol: string) => { if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol) };
  return {
    git,
    isEmri: (id: number) => id > 0 && kart(`/demirbas-is-emri/${id}`),
    cagri: (id: number) => id > 0 && kart(`/servis-cagri/${id}`),
    sozlesme: (id: number) => id > 0 && kart(`/servis-sozlesme/${id}`),
    emanet: (id: number) => id > 0 && kart(`/servis-emanet/${id}`),
    cari: (id: number) => id > 0 && kart(`/cari/${id}`),
  };
}

export function TeknikServisIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useServisGezinti();
  const bas = arama.get('bas') ?? ayBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const sube = Number(arama.get('sube') ?? 0);
  const teknisyen = Number(arama.get('teknisyen') ?? 0);
  const musteri = Number(arama.get('musteri') ?? 0);
  const mm = arama.get('mm') ?? '';
  const kapsam = Number(arama.get('kapsam') ?? 0);
  const sahiplikQ = arama.get('sahiplik') ?? '';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('ozt');
  const [acik, setAcik] = useState<Set<number>>(new Set());

  useEffect(() => {
    let iptal = false;
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit });
    if (sube) q.set('sube', String(sube));
    if (teknisyen) q.set('teknisyen', String(teknisyen));
    if (musteri) q.set('musteri', String(musteri));
    if (mm) { const [m1, m2] = mm.split('|'); if (m1) q.set('marka', m1); if (m2) q.set('model', m2) }
    if (kapsam) q.set('kapsam', String(kapsam));
    if (sahiplikQ) q.set('sahiplik', sahiplikQ);
    servisIcmalUclari.teknikServisIcmali(q)
      .then(v => { if (!iptal) setVeri(v) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) })
      .then(() => { if (!iptal) setYukleniyor(false) });
    return () => { iptal = true };
  }, [bas, bit, sube, teknisyen, musteri, mm, kapsam, sahiplikQ]);

  const o = veri?.ozet;
  const cevir = (k: number) => setAcik(a => { const n = new Set(a); n.has(k) ? n.delete(k) : n.add(k); return n });
  const sahiplikAdi = veri ? (veri.sahiplik === 1 ? 'İç servis' : veri.sahiplik === 2 ? 'Dış servis' : 'İç + dış servis') : '';
  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tümü';
  const emanetGeciken = useMemo(() => (veri?.emanetler ?? []).filter(e => e.gun > 7 || e.iadeBekleniyor).length, [veri]);
  const a4 = veri && <ServisA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi} sahiplik={sahiplikAdi} />;

  return (
    <div className="hi tsi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI + TSI_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Teknik Servis İcmali</h1><span className="yol">Teknik Servis › İcmaller › Teknik Servis İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Teknik Servis İcmali" dosyaAdi={`Teknik Servis İcmali ${bas} ${bit}`} devre={!veri}>{a4}</CiktiMenusu>
        <span className="sp" />
        <button onClick={() => gz.git('/servis-cizelge')}>📅 Çizelge</button>
        <button onClick={() => gz.git('/servis-sozlesme')}>📑 Sözleşme Listesi</button>
        <button onClick={() => gz.git('/servis-is-emri')}>🔧 İş Emiri Listesi</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Çağrı açılışı:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} />
          –<input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
          <select value="" onChange={e => { if (!e.target.value) return; const [b1, b2] = hazirDonem(e.target.value as 'buay'); degistir({ bas: b1, bit: b2 }) }}>
            <option value="">hazır…</option><option value="buay">Bu ay</option><option value="gecenay">Geçen ay</option><option value="buyil">Bu yıl</option>
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">👷 Teknisyen:
          <select value={teknisyen} onChange={e => degistir({ teknisyen: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.teknisyenler ?? []).map(t => <option key={t.id} value={t.id}>{t.ad}</option>)}
          </select></div>
        <div className="sel">👥 Müşteri:
          <select value={musteri} onChange={e => degistir({ musteri: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.musteriler ?? []).map(t => <option key={t.id} value={t.id}>{t.ad}</option>)}
          </select></div>
        <div className="sel">🏷 Marka / model:
          <select value={mm} onChange={e => degistir({ mm: e.target.value })}>
            <option value="">Tümü</option>
            {(veri?.secim.markalar ?? []).map(m => <option key={m.marka + '|' + m.model} value={m.marka + '|' + m.model}>{`${m.marka} ${m.model}`.trim()}</option>)}
          </select></div>
        <div className="si-seg">
          {KAPSAMLAR.map(([k, ad]) => <button key={k} type="button" className={kapsam === k ? 'on' : ''} onClick={() => degistir({ kapsam: String(k) })}>{ad}</button>)}
        </div>
        <div className="si-seg">
          {SAHIPLIK.map(([k, ad, d]) => <button key={k} type="button" className={veri?.sahiplik === k ? 'on' : ''} onClick={() => degistir({ sahiplik: d })}>{ad}</button>)}
        </div>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.slaAsanAcik > 0 && <span className="bo-rz kir" style={{ cursor: 'pointer' }} onClick={() => setSekme('sla')}>SLA aşan açık çağrı: {o.slaAsanAcik}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Çağrı" deg={sayi(o.cagri)} alt={`kapanan ${o.kapanan} · iptal ${o.iptal}`} />
          <Kutu bas="Açık Çağrı" deg={sayi(o.acik)} alt={`parça bekliyor ${o.parcaBekliyor} · atanmamış ${o.atanmamis}`} sinif={o.acik ? 'uy' : ''} />
          <Kutu bas="İlk Yanıt" deg={saat(o.ilkYanitSaat)} alt={`medyan ${saat(o.ilkYanitMedyan)}`} />
          <Kutu bas="Çözüm Süresi" deg={saat(o.cozumSaat)} alt="açılıştan kapanışa" />
          <Kutu bas="SLA İhlali" deg={yuzde(o.slaIhlalOran)} alt={o.slaOlculen ? `${o.slaIhlal} çağrı · ${o.slaIhlalAcik}'i hâlâ açık` : 'SLA işleyen çağrı yok'}
            sinif={o.slaIhlal ? 'teh' : ''} />
          <Kutu bas="İlk Ziyarette Çözüm" deg={yuzde(o.ilkZiyaretCozum)} alt={`ikinci ziyaret ${o.ikinciZiyaret}`} sinif={o.ilkZiyaretCozum == null ? '' : 'iyi'} />
          <Kutu bas={`Tekrar Arıza (${o.tekrarGun} gün)`} deg={sayi(o.tekrar)} alt={`aynı cihaz · ${yuzde(o.tekrarOran)}`} sinif={o.tekrar ? 'uy' : ''} />
          <Kutu bas="Servis Cirosu" deg={kisa(o.ciro, '')} alt={`işçilik ${tl(o.ciroIscilik)} · parça ${tl(o.ciroParca)}`} sinif="mor" />
          <Kutu bas="Servis Maliyeti" deg={kisa(o.maliyet, '')}
            alt={`sözleşme ${tl(o.maliyetSozlesme)} · garanti ${tl(o.maliyetGaranti)}${o.maliyetIc ? ` · iç ${tl(o.maliyetIc)}` : ''}`} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['ozt', 'Özet', null], ['tek', 'Teknisyen', veri.teknisyenler.length || null], ['cih', 'Cihaz / Model', null],
              ['sla', 'SLA', o.slaIhlal || null], ['prc', 'Parça Tüketimi', null], ['emn', 'Emanet Cihaz', veri.emanetler.length || null],
              ['soz', 'Sözleşme Kârlılığı', veri.sozlesmeToplam.zarardaki || null], ['ftr', 'Faturalanmamış', veri.faturasiz.sayi || null],
              ['onz', '🖨 Önizleme (A4)', null]]} />

            {sekme === 'ozt' && <>
              <Kutucuk baslik="Kapsama göre" not="iş emri tutarı · KDV hariç">
                <table className="hi-tablo">
                  <thead><tr><th>Kapsam</th><th className="sag">Çağrı</th><th className="sag">İş emri</th><th className="sag">İşçilik</th>
                    <th className="sag">Parça</th><th className="sag">Diğer</th><th className="sag">Toplam</th><th>Kime yazılır</th></tr></thead>
                  <tbody>
                    {veri.kapsamlar.map(k => (
                      <tr key={k.kod}><td>{k.ad}{k.ciro && <span className="bo-rz mor" style={{ marginLeft: 6 }}>ciro</span>}</td>
                        <td className="sag">{k.cagri}</td><td className="sag">{k.isEmri}</td><td className="sag">{tl(k.iscilik)}</td>
                        <td className="sag">{tl(k.parca)}</td><td className="sag">{tl(k.diger)}</td><td className="sag"><b>{tl(k.toplam)}</b></td>
                        <td className="ki-soluk">{k.kime}</td></tr>
                    ))}
                    <tr className="top"><td>Toplam</td><td className="sag">{veri.kapsamToplam.cagri}</td><td className="sag">{veri.kapsamToplam.isEmri}</td>
                      <td className="sag">{tl(veri.kapsamToplam.iscilik)}</td><td className="sag">{tl(veri.kapsamToplam.parca)}</td>
                      <td className="sag">{tl(veri.kapsamToplam.diger)}</td><td className="sag">{tl(veri.kapsamToplam.toplam)}</td><td /></tr>
                  </tbody>
                </table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Tutar hiçbir kapsamda sıfırlanmaz, yalnız tahsil yolu değişir. Ciro = ücretli +
                  üretici garantisi; sözleşme, kendi garantimiz ve iç iş servis maliyeti olarak izlenir.</div>
              </Kutucuk>
              <div className="si-iki">
                <Kutucuk baslik="Çağrı durumu (şu an)" not="dönemden bağımsız açık çağrılar">
                  <table className="hi-tablo"><thead><tr><th>Durum</th><th className="sag">Adet</th><th className="sag">SLA aşan</th></tr></thead>
                    <tbody>
                      {veri.durumlar.map(d => <tr key={d.kod}><td>{d.ad}</td><td className="sag">{d.adet}</td>
                        <td className={'sag' + (d.slaAsan ? ' kir' : '')}>{d.slaAsan}</td></tr>)}
                      <tr className="top"><td>Açık toplam</td><td className="sag">{o.acik}</td><td className="sag">{o.slaAsanAcik}</td></tr>
                    </tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Öncelik">
                  <table className="hi-tablo"><thead><tr><th>Öncelik</th><th className="sag">Çağrı</th><th className="sag">Ort. ilk yanıt</th>
                    <th className="sag">Ort. çözüm</th><th className="sag">SLA ihlali</th></tr></thead>
                    <tbody>
                      {veri.oncelikler.length === 0 && <tr><td colSpan={5} className="bos">Bu dönemde çağrı yok.</td></tr>}
                      {veri.oncelikler.map(p => <tr key={p.kod}><td>{p.ad}</td><td className="sag">{p.cagri}</td><td className="sag">{saat(p.ilkYanitSaat)}</td>
                        <td className="sag">{saat(p.cozumSaat)}</td><td className={'sag' + (p.slaIhlal ? ' kir' : '')}>{p.slaIhlal}</td></tr>)}
                    </tbody></table>
                </Kutucuk>
              </div>
            </>}

            {sekme === 'tek' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Teknisyen</th><th className="sag">Ziyaret</th><th className="sag">Çözülen çağrı</th><th className="sag">İlk ziyarette çözüm</th>
                    <th className="sag">İşçilik saati</th><th className="sag">Yol (km)</th><th className="sag">SLA ihlali</th><th className="sag">Tekrar arıza</th>
                    <th className="sag">Memnuniyet</th><th className="sag">Ciro</th><th className="sag">İmzasız</th></tr></thead>
                  <tbody>
                    {veri.teknisyenler.length === 0 && <tr><td colSpan={11} className="bos">Bu dönemde ziyaret yok.</td></tr>}
                    {veri.teknisyenler.map(t => <TeknisyenSatiri key={t.id} t={t} acik={acik.has(t.id)} tikla={() => cevir(t.id)} isEmriAc={gz.isEmri} />)}
                    {veri.teknisyenler.length > 0 && (
                      <tr className="top"><td>Toplam</td><td className="sag">{veri.teknisyenToplam.ziyaret}</td><td className="sag">{veri.teknisyenToplam.cozulen}</td>
                        <td className="sag">{yuzde(veri.teknisyenToplam.ilkZiyaretCozum)}</td><td className="sag">{sayi(veri.teknisyenToplam.iscilikSaat)}</td>
                        <td className="sag">{sayi(veri.teknisyenToplam.yolKm)}</td><td className="sag">{veri.teknisyenToplam.slaIhlal}</td>
                        <td className="sag">{veri.teknisyenToplam.tekrar}</td>
                        <td className="sag">{veri.teknisyenToplam.memnuniyet == null ? '—' : `${sayi(veri.teknisyenToplam.memnuniyet)} / 5`}</td>
                        <td className="sag">{tl(veri.teknisyenToplam.ciro)}</td><td className="sag">{veri.teknisyenToplam.imzasiz}</td></tr>
                    )}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Ziyaret = bir gidiş (iptal edilenler hariç); satıra tıkla: ziyaretleri · ziyarete çift tık: iş emri. İlk ziyarette çözüm:
                çağrının sonuçlanan ilk ziyareti "çözüldü". SLA ihlali çağrının ilk ziyaretini yapan teknisyene, tekrar arıza önceki çağrıyı kapatan
                teknisyene yazılır. Memnuniyet: ziyaret kapanışında verilen 1-5 puan ortalaması (puanlı ziyaret sayısı yanında). Ciro: ücretli ve
                üretici garantisi işlerde ziyaretin işçiliği + o ziyarette takılan parça{veri.teknisyenToplam.atanmamisCiro > 0.005
                  ? ` (ziyarete bağlanmamış parça ve diğer tutar teknisyene yazılmaz: ${tl(veri.teknisyenToplam.atanmamisCiro)})` : ''}.
                İmzasız: imza yerine gerekçe yazılarak kapatılan ziyaret.</div>
            </>}

            {sekme === 'cih' && <>
              <Kutucuk baslik="Marka / model bazında arıza" not="parktaki cihaz = müşteri cihaz parkı (aktif)">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Marka</th><th>Model</th><th className="sag">Parkta cihaz</th><th className="sag">Çağrı</th><th className="sag">Arıza / cihaz</th>
                      <th className="sag">Tekrar ({veri.tekrarGun} g)</th><th>En sık arıza</th><th className="sag">Ort. çözüm</th><th className="sag">Parça tutarı</th></tr></thead>
                    <tbody>
                      {veri.cihazlar.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde çağrı yok.</td></tr>}
                      {veri.cihazlar.map(c => (
                        <tr key={c.marka + '|' + c.model} className="ac" onDoubleClick={() => degistir({ mm: `${c.marka}|${c.model}` })}>
                          <td className={c.marka.startsWith('(') ? 'ki-soluk' : ''}>{c.marka}</td><td>{c.model}</td>
                          <td className="sag">{c.park ?? '—'}</td><td className="sag">{c.cagri}</td>
                          <td className={'sag' + ((c.arizaCihaz ?? 0) >= 0.5 ? ' kir' : '')}>{c.arizaCihaz == null ? '—' : sayi(c.arizaCihaz)}</td>
                          <td className={'sag' + (c.tekrar ? ' kir' : '')}>{c.tekrar}</td>
                          <td>{c.enSikAriza ? <>{c.enSikAriza} <span className="ki-soluk">({c.enSikAdet})</span>
                            {!c.enSikKodlu && <span className="bo-rz pas" style={{ marginLeft: 4 }} title="Arıza kodu girilmemiş - metinden gruplandı">metin</span>}</> : '—'}</td>
                          <td className="sag">{saat(c.cozumSaat)}</td><td className="sag">{tl(c.parcaTutar)}</td></tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </Kutucuk>
              <Kutucuk baslik="Arıza dağılımı" not={`${veri.arizaKodlu} iş emri kodlu · ${veri.arizaKodsuz} kodsuz (metinden)`}>
                <table className="hi-tablo"><thead><tr><th>Arıza</th><th>Kaynak</th><th className="sag">İş emri</th><th className="sag">Çağrı</th><th>Sık görülen cihaz</th></tr></thead>
                  <tbody>
                    {veri.arizalar.length === 0 && <tr><td colSpan={5} className="bos">Arıza kaydı yok.</td></tr>}
                    {veri.arizalar.map(a => <tr key={a.ad + a.kodlu}><td>{a.ad}</td>
                      <td><span className={'bo-rz ' + (a.kodlu ? 'mavi' : 'pas')}>{a.kodlu ? 'arıza kodu' : 'metin'}</span></td>
                      <td className="sag">{a.isEmri}</td><td className="sag">{a.cagri}</td><td className="ki-soluk">{a.markaModel}</td></tr>)}
                  </tbody></table>
              </Kutucuk>
              <div className="ki-soluk si-not">Arıza / cihaz = çağrı / parktaki cihaz (0,5 ve üstü kırmızı). Arıza iş emrindeki arıza kodundan; kodu olmayan eski
                kayıtlar arıza metninden gruplanır ("metin" rozeti - serbest metin olduğu için öneri niteliğindedir). Tekrar arıza: aynı cihazın önceki
                çağrısının kapanışından sonra {veri.tekrarGun} gün içinde açılan yeni çağrı (farklı arıza da olsa; süre Genel Ayarlar'dan). Satıra çift tık:
                o marka / modelle süz.</div>
            </>}

            {sekme === 'sla' && <>
              <Kutucuk baslik="SLA — sözleşme hedefi ve gerçekleşen" not={veri.sla.slasiz ? `SLA işlemeyen çağrı: ${veri.sla.slasiz}` : undefined}>
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Sözleşme</th><th>Müşteri</th><th>Kapsam</th><th className="sag">SLA</th><th className="sag">Çağrı</th><th className="sag">Ort. ilk yanıt</th>
                      <th className="sag">İhlal</th><th className="sag">En uzun gecikme</th><th>Durum</th></tr></thead>
                    <tbody>
                      {veri.sla.satirlar.length === 0 && <tr><td colSpan={9} className="bos">SLA işleyen çağrı yok.</td></tr>}
                      {veri.sla.satirlar.map(s => {
                        const [rz, ad] = SLA_ROZET[s.durum] ?? ['pas', s.durum];
                        return (
                          <tr key={s.sozlesmeId}>
                            <td>{s.sozlesmeId > 0 ? <span className="lnk" onClick={() => gz.sozlesme(s.sozlesmeId)}>{s.no}</span> : <span className="ki-soluk">{s.no}</span>}</td>
                            <td>{s.taraf}</td><td>{s.kapsam}</td><td className="sag">{s.slaSaat == null ? '—' : `${s.slaSaat} saat`}</td>
                            <td className="sag">{s.cagri}</td><td className="sag">{saat(s.ilkYanitSaat)}</td>
                            <td className={'sag' + (s.ihlal ? ' kir' : '')}>{s.ihlal}{s.acikIhlal > 0 && <span className="ki-soluk"> ({s.acikIhlal} açık)</span>}</td>
                            <td className="sag">{saat(s.enUzunGecikme)}</td><td><span className={'bo-rz ' + rz}>{ad}</span></td></tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              </Kutucuk>
              <Kutucuk baslik="⚠ SLA'yı aşan çağrılar" not="en uzun gecikme önce">
                <table className="hi-tablo"><thead><tr><th>Çağrı</th><th>Müşteri</th><th>Cihaz</th><th>Açılış</th><th>SLA bitişi</th><th>İlk yanıt</th>
                  <th className="sag">Gecikme</th><th>Sözleşme</th></tr></thead>
                  <tbody>
                    {veri.sla.ihlaller.length === 0 && <tr><td colSpan={8} className="bos">SLA aşımı yok.</td></tr>}
                    {veri.sla.ihlaller.map(x => (
                      <tr key={x.anahtar} className="ac" onDoubleClick={() => (x.anahtar.startsWith('c') ? gz.cagri(x.id) : gz.isEmri(x.id))}>
                        <td>{x.no || `#${x.id}`}{x.acik && <span className="bo-rz kir" style={{ marginLeft: 4 }}>açık</span>}</td>
                        <td>{x.taraf}</td><td>{x.cihaz}</td><td>{zaman(x.acilis)}</td><td>{zaman(x.slaBitis)}</td>
                        <td>{x.ilkYanit ? zaman(x.ilkYanit) : <span className="kir">yanıt yok</span>}</td>
                        <td className="sag kir">{saat(x.gecikmeSaat)}</td><td>{x.sozlesme}</td></tr>
                    ))}
                  </tbody></table>
              </Kutucuk>
              <div className="ki-soluk si-not">SLA saati çağrının açılışında başlar (sla_bitis açılışta yazılır, teknisyen atanınca değil): sözleşmenin SLA'sı, yoksa
                kurum varsayılanı. İhlal: ilk yanıt SLA bitişinden sonra ya da hâlâ yanıt yok ve süre geçti. Durum: ihlal yoksa uygun, çağrıların %10'undan azında
                sınırda, fazlasında ihlal. Çift tık: çağrı kartı.</div>
            </>}

            {sekme === 'prc' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Kod</th><th>Parça</th><th className="sag">Miktar</th><th className="sag">Maliyet</th><th className="sag">Tutar</th>
                    <th className="sag">Faturalanan</th><th className="sag">Faturalanmayan</th><th className="sag">Sözleşme / garanti</th><th>Üreticiye iade</th></tr></thead>
                  <tbody>
                    {veri.parcalar.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemin iş emirlerinde parça yok.</td></tr>}
                    {veri.parcalar.map(p => (
                      <tr key={p.anahtar}><td>{p.kod}</td><td>{p.ad}</td><td className="sag">{sayi(p.miktar)}</td>
                        <td className="sag">{p.maliyet == null ? '—' : tl(p.maliyet)}</td><td className="sag">{tl(p.tutar)}</td>
                        <td className="sag">{tl(p.faturalanan)}</td><td className={'sag' + (p.faturalanmayan > 0.005 ? ' kir' : '')}>{tl(p.faturalanmayan)}</td>
                        <td className="sag">{tl(p.sozlesmeGaranti)}</td>
                        <td>{p.iadeBekliyor > 0 && <span className={'bo-rz ' + (p.iadeGeciken ? 'kir' : 'sari')}>{p.iadeBekliyor} bekliyor</span>}
                          {p.iadeToplandi > 0 && <span className="bo-rz ok" style={{ marginLeft: 4 }}>toplandı {p.iadeToplandi}</span>}
                          {p.iadeBekliyor + p.iadeToplandi === 0 && '—'}</td></tr>
                    ))}
                    {veri.parcalar.length > 0 && (
                      <tr className="top"><td colSpan={2}>Toplam ({veri.parcaToplam.kalem} kalem)</td><td className="sag">{sayi(veri.parcaToplam.miktar)}</td>
                        <td className="sag">{tl(veri.parcaToplam.maliyet)}</td><td className="sag">{tl(veri.parcaToplam.tutar)}</td>
                        <td className="sag">{tl(veri.parcaToplam.faturalanan)}</td><td className="sag">{tl(veri.parcaToplam.faturalanmayan)}</td>
                        <td className="sag">{tl(veri.parcaToplam.sozlesmeGaranti)}</td>
                        <td>{veri.parcaToplam.iadeBekliyor > 0 && `${veri.parcaToplam.iadeBekliyor} bekliyor`}</td></tr>
                    )}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Parça = iş emirlerinde kullanılan parça satırları; tutar = miktar × birim fiyat. Maliyet stok kartının ortalama maliyetiyle
                (stoksuz parçada —). Faturalanan: ücretli / üretici garantisi işin faturası kesilmiş; faturalanmayan: iş kapanmış ama faturası yok (kırmızı).
                Üretici garantisinde sökülen parça toplanmazsa üretici alacağı reddeder — 15 günü geçen "bekliyor" kırmızı.</div>
            </>}

            {sekme === 'emn' && <>
              <table className="hi-tablo">
                <thead><tr><th>Emanet</th><th>Cihaz</th><th>Müşteri</th><th>İş emri</th><th>Veriliş</th><th className="orta">Gün</th><th>İş emri durumu</th></tr></thead>
                <tbody>
                  {veri.emanetler.length === 0 && <tr><td colSpan={7} className="bos">Dışarıda emanet cihaz yok.</td></tr>}
                  {veri.emanetler.map(e => (
                    <tr key={e.id} className="ac" onDoubleClick={() => gz.emanet(e.id)}>
                      <td>{e.no || `#${e.id}`}</td><td>{e.cihaz}</td><td>{e.taraf}</td>
                      <td>{e.isEmriId ? <span className="lnk" onClick={() => gz.isEmri(e.isEmriId)}>{e.isEmriNo || `#${e.isEmriId}`}</span> : '—'}</td>
                      <td>{tarihT(e.veris)}</td>
                      <td className="orta"><span className={'bo-rz ' + (e.gun > 14 ? 'kir' : e.gun > 7 ? 'sari' : 'pas')}>{e.gun}</span></td>
                      <td>{e.iadeBekleniyor ? <span className="bo-rz sari">{e.isEmriDurum}</span> : e.isEmriDurum}</td></tr>
                  ))}
                </tbody>
              </table>
              <div className="ki-soluk si-not">Şu an dışarıda olan emanet cihazlar (dönemden bağımsız){emanetGeciken ? ` · ${emanetGeciken} tanesi 7 günü geçti ya da iade bekliyor` : ''}.
                Emanet stoktan düşmez; iade edilmeden iş emri kapanmaz. İş emri çözüldü ama emanet dönmediyse sarı rozet. Çift tık: emanet kartı.</div>
            </>}

            {sekme === 'soz' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Sözleşme</th><th>Müşteri</th><th>Kapsam</th><th>Dönem</th><th className="sag">Yıllık bedel</th><th className="sag">Geçen süre payı</th>
                    <th className="sag">Harcanan işçilik</th><th className="sag">Harcanan parça</th><th className="sag">Yol / diğer</th><th className="sag">Kâr</th><th className="sag">Kâr %</th></tr></thead>
                  <tbody>
                    {veri.sozlesmeler.length === 0 && <tr><td colSpan={11} className="bos">Dönemde yürürlükte bakım sözleşmesi yok.</td></tr>}
                    {veri.sozlesmeler.map(s => (
                      <tr key={s.id}>
                        <td><span className="lnk" onClick={() => gz.sozlesme(s.id)}>{s.no}</span></td>
                        <td>{s.taraf}</td><td>{s.kapsam}</td><td>{tarihT(s.bas)}–{tarihT(s.bit)}</td>
                        <td className="sag">{tl(s.yillikBedel)}</td><td className="sag" title={`${s.gecenGun} / ${s.toplamGun} gün`}>{tl(s.gecenPay)}</td>
                        <td className="sag">{tl(s.iscilik)}{s.tarifeli > 0 && <span className="bo-rz sari" style={{ marginLeft: 4 }}
                          title="Teknisyenin maaşı ya da ziyaretin işçilik saati girilmemiş: bu ziyaretlerde personel saat maliyeti yerine tarife kullanıldı">tarife {s.tarifeli}</span>}</td>
                        <td className="sag">{tl(s.parca)}</td><td className="sag">{tl(s.diger)}</td>
                        <td className={'sag' + (s.zarar ? ' kir' : '')}><b>{tl(s.kar)}</b></td>
                        <td className={'sag' + (s.zarar ? ' kir' : '')}>{yuzde(s.karOran)}</td></tr>
                    ))}
                    {veri.sozlesmeler.length > 0 && (
                      <tr className="top"><td colSpan={4}>Toplam ({veri.sozlesmeToplam.sozlesme} sözleşme · {veri.sozlesmeToplam.zarardaki} zararda)</td>
                        <td className="sag">{tl(veri.sozlesmeToplam.yillikBedel)}</td><td className="sag">{tl(veri.sozlesmeToplam.gecenPay)}</td>
                        <td className="sag">{tl(veri.sozlesmeToplam.iscilik)}</td><td className="sag">{tl(veri.sozlesmeToplam.parca)}</td>
                        <td className="sag">{tl(veri.sozlesmeToplam.diger)}</td><td className="sag">{tl(veri.sozlesmeToplam.kar)}</td>
                        <td className="sag">{yuzde(veri.sozlesmeToplam.karOran)}</td></tr>
                    )}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Sözleşmenin başından bugüne: geçen süre payı = yıllık bedel × geçen gün / sözleşme günü. Harcanan = sözleşme kapsamındaki
                iş emirleri; işçilik personel saat maliyetiyle (aylık net maaş / 225 × işçilik saati), maaşı ya da saati girilmemiş ziyarette tarifeyle ("tarife"
                rozeti). Parça ve diğer iş emrinin tutarıdır (tutar sözleşmede de sıfırlanmaz). Zarardaki sözleşme yenilemede fiyat artışı adayıdır.</div>
            </>}

            {sekme === 'ftr' && <>
              <Kutucuk baslik="⚠ Kapanmış ama faturalanmamış ücretli işler" not={`${veri.faturasiz.sayi} iş · ${tl(veri.faturasiz.tutar)} ₺ · dönemden bağımsız`}>
                <table className="hi-tablo"><thead><tr><th>İş emri</th><th>Kapanış</th><th>Müşteri / üretici</th><th>Kapsam</th><th className="sag">İşçilik</th>
                  <th className="sag">Parça</th><th className="sag">Toplam</th><th className="orta">Gün</th></tr></thead>
                  <tbody>
                    {veri.faturasiz.liste.length === 0 && <tr><td colSpan={8} className="bos">Faturası bekleyen kapanmış iş yok.</td></tr>}
                    {veri.faturasiz.liste.map(x => (
                      <tr key={x.id} className="ac" onDoubleClick={() => gz.isEmri(x.id)}>
                        <td><span className="lnk" onClick={() => gz.isEmri(x.id)}>{x.no || `#${x.id}`}</span></td><td>{tarihT(x.kapanis)}</td>
                        <td>{x.taraf}{x.uretici && <span className="ki-soluk"> (üretici adına)</span>}</td><td>{x.kapsam}</td>
                        <td className="sag">{tl(x.iscilik)}</td><td className="sag">{tl(x.parca)}</td><td className="sag"><b>{tl(x.toplam)}</b></td>
                        <td className="orta"><span className={'bo-rz ' + (x.gun > 15 ? 'kir' : x.gun > 7 ? 'sari' : 'pas')}>{x.gun}</span></td></tr>
                    ))}
                    {veri.faturasiz.sayi > veri.faturasiz.liste.length && <tr><td colSpan={8} className="bos">… {veri.faturasiz.sayi - veri.faturasiz.liste.length} iş daha</td></tr>}
                  </tbody></table>
              </Kutucuk>
              <div className="ki-soluk si-not">Teslim edilmiş (kapanmış), ücretli ya da üretici garantili, tutarı olan ve faturası (belge) bağlanmamış dış işler. Üretici
                garantisi işleri üreticiye ayrı faturalanır. Çift tık: iş emri kartı.</div>
            </>}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.cagri} çağrı</span><span>{o.isEmri} iş emri</span><span>{o.ziyaret} ziyaret</span><span>{sahiplikAdi}</span>
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}
    </div>
  );
}

const zaman = (t: string | null | undefined) => (t ? new Date(t).toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }) : '—');

function TeknisyenSatiri({ t, acik, tikla, isEmriAc }: { t: ServisTeknisyenSatiri; acik: boolean; tikla(): void; isEmriAc(id: number): void }) {
  return (
    <Fragment>
      <tr className="ac" onClick={tikla}>
        <td className={t.id <= 0 ? 'ki-soluk' : ''}><span className="ok">{acik ? '▾' : '▸'}</span>{t.ad}</td>
        <td className="sag">{t.ziyaret}</td><td className="sag">{t.cozulen}</td>
        <td className="sag">{yuzde(t.ilkZiyaretCozum)}{t.ilkZiyaretSayi > 0 && <span className="ki-soluk"> ({t.ilkZiyaretSayi})</span>}</td>
        <td className="sag">{sayi(t.iscilikSaat)}</td><td className="sag">{sayi(t.yolKm)}</td>
        <td className={'sag' + (t.slaIhlal >= 3 ? ' kir' : '')}>{t.slaIhlal}</td><td className={'sag' + (t.tekrar >= 3 ? ' kir' : '')}>{t.tekrar}</td>
        <td className="sag">{t.memnuniyet == null ? '—' : <>{sayi(t.memnuniyet)} / 5 <span className="ki-soluk">({t.puanSayisi})</span></>}</td>
        <td className="sag">{tl(t.ciro)}</td><td className={'sag' + (t.imzasiz ? ' kir' : '')}>{t.imzasiz}</td>
      </tr>
      {acik && (
        <tr className="si-det"><td colSpan={11}>
          {t.ziyaretler.length === 0 ? 'Ziyaret yok.' : (
            <table className="hi-tablo tsi-ic">
              <thead><tr><th>Tarih</th><th>İş emri</th><th>Müşteri</th><th>Cihaz</th><th>Sonuç</th><th className="sag">Saat</th><th className="sag">Tutar</th><th className="sag">Puan</th></tr></thead>
              <tbody>{t.ziyaretler.map(z => (
                <tr key={z.id} className="ac" onDoubleClick={() => isEmriAc(z.isEmriId)}>
                  <td>{zaman(z.tarih)}</td><td>{z.isEmriNo || `#${z.isEmriId}`}</td><td>{z.taraf}</td><td>{z.cihaz}</td>
                  <td>{z.sonuc}{z.imzasiz && <span className="bo-rz sari" style={{ marginLeft: 4 }}>imzasız</span>}</td>
                  <td className="sag">{sayi(z.saat)}</td><td className="sag">{tl(z.tutar)}</td><td className="sag">{z.puan ?? '—'}</td></tr>
              ))}</tbody>
            </table>
          )}
          {t.ziyaretSayisi > t.ziyaretler.length && <div className="ki-soluk">… {t.ziyaretSayisi - t.ziyaretler.length} ziyaret daha</div>}
        </td></tr>
      )}
    </Fragment>
  );
}

function ServisA4({ v, antet, duzenleyen, sube, sahiplik }: {
  v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; sube: string; sahiplik: string;
}) {
  const o = v.ozet;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>TEKNİK SERVİS İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>Şube: {sube} · {sahiplik}</span>
        <span>{o.cagri} çağrı · {o.isEmri} iş emri · {o.ziyaret} ziyaret</span>
        <span>{o.teknisyen} teknisyen · {v.sozlesmeToplam.sozlesme} sözleşme</span>
        <span>İlk yanıt {saat(o.ilkYanitSaat)} · SLA ihlali {yuzde(o.slaIhlalOran)}</span>
        <span>İlk ziyarette çözüm {yuzde(o.ilkZiyaretCozum)} · tekrar arıza {o.tekrar}</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Teknisyen</th><th>Ziyaret</th><th>İlk ziyarette çözüm</th><th>SLA ihlali</th><th>Memnuniyet</th><th>Ciro</th></tr></thead>
        <tbody>{v.teknisyenler.map(t => <tr key={t.id}><td>{t.ad}</td><td>{t.ziyaret}</td><td>{yuzde(t.ilkZiyaretCozum)}</td><td>{t.slaIhlal}</td>
          <td>{t.memnuniyet == null ? '—' : sayi(t.memnuniyet)}</td><td>{tl(t.ciro)}</td></tr>)}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>İşçilik (ciro)</span><span>{tl(o.ciroIscilik)}</span></div>
        <div><span>Parça (ciro)</span><span>{tl(o.ciroParca)}</span></div>
        {o.ciroDiger > 0.005 && <div><span>Diğer (ciro)</span><span>{tl(o.ciroDiger)}</span></div>}
        <div><span>Servis maliyeti (sözleşme / garanti / iç)</span><span>{tl(o.maliyet)}</span></div>
        <div><span>Faturalanmamış</span><span>{tl(o.faturasizTutar)}</span></div>
        <div className="b"><span>SERVİS CİROSU</span><span>{tl(o.ciro)} ₺</span></div>
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Servis Müdürü<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Teknik Servis İcmali · tutarlar KDV hariç · ciro = ücretli + üretici garantisi · sözleşme ve garanti tutarları
        tahsil edilmez, maliyet olarak izlenir</p>
    </div>
  );
}

const TSI_STILI = `
.tsi .hi-ozet { grid-template-columns:repeat(9,1fr); }
@media (max-width:1300px) { .tsi .hi-ozet { grid-template-columns:repeat(5,1fr); } }
@media (max-width:700px) { .tsi .hi-ozet { grid-template-columns:repeat(2,1fr); } }
.tsi .hi-serit .si-seg button { padding:4px 10px; }
.hi-tablo.tsi-ic { margin:4px 0; background:#fff; }
.hi-tablo.tsi-ic td { padding-left:8px !important; }
`;

export default TeknikServisIcmali;
