import { Fragment, useContext, useEffect, useMemo, useState } from 'react';
import { hataMetni } from '../../api/sozlesme';
import {
  satinalmaIcmalUclari, type BekleyenSatiri, type KalemTuru, type SatinalmaIcmali as Veri, type TedarikciKarneSatiri,
} from '../../api/uclar/satinalmaIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { onay } from '../../bilesenler/mesaj';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { ayBasi, EkranA4, hazirDonem, kisa, sayi, tarihT, TICARI_ICMAL_STILI, tl, useGezinti, yuzde } from '../ticariIcmal/ticariIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';

/**
 * SATINALMA SÜREÇ İCMALİ `/satinalma-icmali` - mockup Ekranlar/İcmal/satinalma_icmali.html (kararlar 25.10.2026).
 * "Talepler nerede tıkanıyor, kim bekletiyor, hangi tedarikçi güvenilir, fiyatlar ne kadar arttı, bütçenin ne
 * kadarı kaldı?" Alış İcmali gerçekleşen alışı anlatır; bu ekran SÜRECİ - talepten ödemeye her aşamanın süresi
 * ve bekleyeni. Rakamlar SUNUCUDAN (SatinalmaIcmalUclari); ekran toplamaz. Onay / ret burada verilmez (Onay
 * ekranı); buradan yalnız belgeye gidilir ve onaycıya hatırlatılır (günde bir).
 */
type Sekme = 'hun' | 'bek' | 'ted' | 'fiy' | 'but' | 'krt' | 'onz';


const KAYNAKLAR: [number, string][] = [[0, 'Hepsi'], [1, 'Birim talebi'], [2, 'Kritik stok'], [3, 'Arıza'], [5, 'Yatırım']];
/** Huni satırı → Bekleyenler sekmesindeki aşama süzgeci (aşama adının başı). */
const HUNI_ASAMA: Record<string, string> = {
  talep: 'Taslak', onay: 'Onay', teklif: 'Teklif', siparis: 'Sipariş', kabul: 'Mal kabul', fatura: 'Fatura kontrolü',
};
const gun = (n: number | null | undefined) => (n == null ? '—' : `${n.toLocaleString('tr-TR', { maximumFractionDigits: 1 })} gün`);

const KalemRozeti = ({ k }: { k: KalemTuru }) =>
  k === 'urun' ? null : <span className="bo-rz mavi" style={{ marginLeft: 4 }}>{k === 'hizmet' ? 'hizmet' : 'ürün + hizmet'}</span>;

const OncelikRozeti = ({ o }: { o: BekleyenSatiri['oncelik'] }) =>
  <span className={'bo-rz ' + (o === 'acil' ? 'kir' : o === 'yuksek' ? 'sari' : 'pas')}>{o === 'acil' ? 'acil' : o === 'yuksek' ? 'yüksek' : 'normal'}</span>;

export function SatinalmaIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useGezinti();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const kartaGit = (yol: string) => { if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else gz.git(yol) };
  const bas = arama.get('bas') ?? ayBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const sube = Number(arama.get('sube') ?? 0);
  const departman = Number(arama.get('departman') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const tedarikci = Number(arama.get('tedarikci') ?? 0);
  const butce = Number(arama.get('butce') ?? 0);
  const kaynak = Number(arama.get('kaynak') ?? 0);
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [tazele, setTazele] = useState(0);
  const [sekme, setSekme] = useState<Sekme>('hun');
  const [asamaSuz, setAsamaSuz] = useState('');
  const [secili, setSecili] = useState<BekleyenSatiri | null>(null);
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const [isliyor, setIsliyor] = useState(false);
  const [ara, setAra] = useState('');

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit });
    if (sube) q.set('sube', String(sube));
    if (departman) q.set('departman', String(departman));
    if (kategori) q.set('kategori', String(kategori));
    if (tedarikci) q.set('tedarikci', String(tedarikci));
    if (butce) q.set('butce', String(butce));
    if (kaynak) q.set('kaynak', String(kaynak));
    satinalmaIcmalUclari.satinalmaIcmali(q)
      .then(v => { setVeri(v); setSecili(s => (s ? v.bekleyenler.find(x => x.anahtar === s.anahtar) ?? null : null)) })
      .catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, sube, departman, kategori, tedarikci, butce, kaynak, tazele]);

  const q = ara.trim().toLocaleLowerCase('tr');
  const bekleyenler = useMemo(() => (veri?.bekleyenler ?? []).filter(b => (!asamaSuz || b.asama.startsWith(asamaSuz))
    && (!q || [b.no, b.konu, b.kimde, b.talepEden].some(x => x.toLocaleLowerCase('tr').includes(q)))), [veri, asamaSuz, q]);
  const tedarikciler = useMemo(() => (veri?.tedarikciler ?? []).filter(t => !q || t.ad.toLocaleLowerCase('tr').includes(q)), [veri, q]);
  const fiyatlar = useMemo(() => (veri?.fiyat.satirlar ?? []).filter(f => !q || [f.kod, f.ad, f.tedarikci].some(x => x.toLocaleLowerCase('tr').includes(q))), [veri, q]);
  const cevir = (id: number) => setAcik(a => { const n = new Set(a); n.has(id) ? n.delete(id) : n.add(id); return n });

  /** Belgeyi kendi sekmesinde açar (kart sekmesi deseni). Sipariş ve fatura belge kartıdır. */
  const belgeAc = (b: BekleyenSatiri) => {
    if (b.belgeTur === 'talep') kartaGit(`/satinalma-talep/${b.id}`);
    else if (b.belgeTur === 'teklif') kartaGit(`/satinalma-teklif/${b.id}`);
    else gz.belgeKarti(b.id);
  };

  const hatirlat = async (b: BekleyenSatiri) => {
    setHata(''); setBilgi('');
    if (!b.hatirlatilabilir) return;
    if (!await onay(`${b.no} — ${b.kimde}\n\n${b.gun} gündür onay bekliyor. Onaycıya hatırlatma gönderilsin mi?\n\n`
      + 'Aynı belge için günde bir hatırlatma gönderilir; aynı onaycıya ikinci kez hatırlatılırsa zincirin bir üst basamağına da bilgi gider. '
      + 'Hatırlatma talebin günlüğüne yazılır.')) return;
    setIsliyor(true);
    try {
      const y = await satinalmaIcmalUclari.hatirlat('talep', b.id);
      setBilgi(`${y.talepNo}: ${y.alicilar.map(a => a.ad).join(', ') || 'onaycı'} kişisine hatırlatıldı (${y.adimAd}).`
        + (y.eskalasyon && y.ustAdim ? ` İkinci hatırlatma — üst basamağa (${y.ustAdim.ad}: ${y.ustBilgi.map(a => a.ad).join(', ')}) bilgi gitti.` : '')
        + (y.ikinci && !y.eskalasyon ? ' İkinci hatırlatma; bilgi verilecek üst basamak yok.' : '')
        + (y.bildirim === 0 ? ' Bildirim kuyruğa yazılamadı (alıcının e-posta / cep bilgisi eksik olabilir) — hatırlatma yine kaydedildi.' : ''));
      setTazele(t => t + 1);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };

  const o = veri?.ozet;
  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tümü';
  const a4 = veri && <SatinalmaA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi} />;
  const hedefVar = veri ? Object.values(veri.hedefler).some(x => x != null) : false;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Satınalma Süreç İcmali</h1><span className="yol">Satınalma › İcmaller › Satınalma Süreç İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Satınalma İcmali" dosyaAdi={`Satınalma Süreç İcmali ${bas} ${bit}`} devre={!veri}>{a4}</CiktiMenusu>
        <button disabled={!secili} onClick={() => secili && belgeAc(secili)} title={secili ? '' : 'Önce Bekleyenler sekmesinde satır seçin'}>📄 Seçili belgeyi aç</button>
        <button disabled={!secili || !secili.hatirlatilabilir || !veri?.yetkiler.hatirlat || isliyor} onClick={() => secili && hatirlat(secili)}
          title={!secili ? 'Önce onay bekleyen bir talep seçin' : !secili.hatirlatilabilir ? (secili.bugunHatirlatildi ? 'Bugün hatırlatıldı — günde bir' : 'Yalnız onay bekleyen talepte') : ''}>
          🔔 Onaycıya hatırlat</button>
        <span className="sp" />
        <button onClick={() => gz.git('/alis-icmali')}>🛒 Alış İcmali</button>
        <button onClick={() => gz.git('/siparis-icmali')}>📋 Sipariş İcmali (alış)</button>
        <button onClick={() => gz.git('/stok-kritik-stok-icmali')}>⚠ Kritik Stok İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Talep tarihi:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} />
          –<input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
          <select value="" onChange={e => { if (!e.target.value) return; const [b1, b2] = hazirDonem(e.target.value); degistir({ bas: b1, bit: b2 }) }}>
            <option value="">hazır…</option><option value="buay">Bu ay</option><option value="gecenay">Geçen ay</option>
            <option value="buyil">Bu yıl</option><option value="gecenyil">Geçen yıl</option>
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">🏬 Talep eden bölüm:
          <select value={departman} onChange={e => degistir({ departman: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.departmanlar ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">🗂 Kategori:
          <select value={kategori} onChange={e => degistir({ kategori: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.kategoriler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">🤝 Tedarikçi:
          <select value={tedarikci} onChange={e => degistir({ tedarikci: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.tedarikciler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">💰 Bütçe kalemi:
          <select value={butce} onChange={e => degistir({ butce: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.butceler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="si-seg">
          {KAYNAKLAR.map(([k, ad]) => (
            <button key={k} type="button" className={kaynak === k ? 'on' : ''} onClick={() => degistir({ kaynak: String(k) })}>{ad}</button>
          ))}
        </div>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.uzunOnay > 0 && <span className="bo-rz kir" style={{ cursor: 'pointer' }} onClick={() => { setAsamaSuz('Onay'); setSekme('bek') }}>
          {o.uzunOnayEsik} günden uzun onay bekleyen: {o.uzunOnay}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Talep" deg={sayi(o.talep)} alt={`tahmini ${kisa(o.talepTutar, '')} · ${o.kritik} kritik stoktan`} />
          <Kutu bas="Açık Talep" deg={sayi(o.acik)} alt={`onayda ${o.onayda} · teklifte ${o.teklifte} · onaylı ${o.onayli}`} sinif={o.acik ? 'uy' : ''} />
          <Kutu bas="Talep → Sipariş" deg={gun(o.talepSiparisGun)}
            alt={`medyan ${gun(o.talepSiparisMedyan)}${o.bolunen ? ` · ${o.bolunen} bölünen` : ''}`} />
          <Kutu bas="Sipariş → Mal Kabul" deg={gun(o.kabulGun)} alt={o.terminUyum == null ? 'termin ölçülmedi' : `termin uyumu %${sayi(o.terminUyum)}`}
            sinif={o.terminUyum != null && o.terminUyum < 80 ? 'uy' : ''} />
          <Kutu bas="Teklif / Talep" deg={o.teklifTalep == null ? '—' : sayi(o.teklifTalep)} alt={`tek teklifle sipariş ${o.tekTeklif}`} sinif={o.tekTeklif ? 'uy' : ''} />
          <Kutu bas="Tasarruf" deg={kisa(o.tasarruf, '')} alt={`ortalama teklife göre${o.tasarrufOran != null ? ` · %${sayi(o.tasarrufOran)}` : ''}`} sinif={o.tasarruf > 0 ? 'iyi' : ''} />
          <Kutu bas="Fatura Uyuşmazlığı" deg={sayi(o.uyusmaz)} alt={`ödeme durduruldu ${o.odemeDurdu} · ${tl(o.farkTutar)} ₺ fark`} sinif={o.uyusmaz ? 'teh' : ''} />
          <Kutu bas="Bütçe Kullanımı" deg={o.butceKullanim == null ? '—' : `%${sayi(o.butceKullanim)}`} alt="gerçekleşen + taahhüt / yıllık"
            sinif={o.butceKullanim != null && o.butceKullanim >= 90 ? 'teh' : 'mor'} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['hun', 'Süreç Hunisi', null], ['bek', 'Bekleyenler', veri.bekleyenSayi || null], ['ted', 'Tedarikçi Karnesi', null],
              ['fiy', 'Fiyat Analizi', null], ['but', 'Bütçe', null], ['krt', 'Kritik Stoktan Gelen', veri.kritik.length || null],
              ['onz', '🖨 Önizleme (A4)', null]]} />

            {(sekme === 'bek' || sekme === 'ted' || sekme === 'fiy') && (
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder={sekme === 'bek' ? '🔍 Belge, konu, kişi…' : sekme === 'ted' ? '🔍 Tedarikçi…' : '🔍 Kod, ürün / hizmet ya da tedarikçi…'}
                  value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 260 }} />
                {sekme === 'bek' && <select value={asamaSuz} onChange={e => setAsamaSuz(e.target.value)}>
                  <option value="">Bütün aşamalar</option>
                  {Object.values(HUNI_ASAMA).map(a => <option key={a} value={a}>{a}</option>)}
                </select>}
                <span className="ki-soluk">{sekme === 'bek' ? 'satıra tıkla: seç · çift tık: belgeyi aç · en uzun bekleyen üstte'
                  : sekme === 'ted' ? 'satıra tıkla: dönemdeki tedarikçi olayları · ada tıkla: cari kartı' : 'son alışın 3. önceki alışa göre değişimi · etkiye göre sıralı'}</span>
              </div>
            )}

            {sekme === 'hun' && (
              <Kutucuk baslik="Talepten ödemeye süreç hunisi" not="satıra tıkla: o aşamadaki belgeler">
                <table className="hi-tablo">
                  <thead><tr><th>Aşama</th><th className="sag">Adet</th><th className="sag">Tutar</th><th className="sag">Bu aşamada bekleyen</th>
                    <th className="sag">Ort. bekleme</th><th className="sag">Hedef</th><th style={{ width: 160 }}>Akış</th></tr></thead>
                  <tbody>
                    {veri.huni.map(h => (
                      <tr key={h.kod} className={HUNI_ASAMA[h.kod] ? 'ac' : ''}
                        onClick={() => { if (HUNI_ASAMA[h.kod]) { setAsamaSuz(HUNI_ASAMA[h.kod]); setSekme('bek') } }}>
                        <td>{h.sira} · {h.ad}</td><td className="sag">{sayi(h.adet)}</td><td className="sag">{tl(h.tutar)}</td>
                        <td className="sag">{h.bekleyen ? <>{h.bekleyen} <span className="ki-soluk">{h.bekleyenNot}</span></> : '—'}</td>
                        <td className={'sag' + (h.hedefAsimi ? ' kir' : '')}>{gun(h.ortGun)}</td>
                        <td className="sag ki-soluk">{gun(h.hedefGun)}</td>
                        <td><Cubuk yuzde={h.cubuk} /></td></tr>
                    ))}
                    <tr><td className="ki-soluk">Reddedilen / iptal</td><td className="sag">{sayi(veri.redIptal.adet)}</td>
                      <td className="sag">{tl(veri.redIptal.tutar)}</td><td /><td /><td /><td /></tr>
                  </tbody>
                </table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Dönem talep tarihidir; aşamalar o taleplerden türer. 1–4 talep sayısıdır (tutar:
                  1–3 talebin tahmini tutarı, 4 sipariş tutarı), 5 sipariş sayısı, 6–7 fatura kontrolü sayısı. Teklif aşaması atlanan (doğrudan siparişe dönen) talepler
                  3. satırda sayılmaz. Sipariş süresi onayın (teklif kararı varsa onun) bitişinden <b>ilk</b> siparişe kadardır — talep birden çok siparişe bölündüyse
                  ilk sipariş esas alınır. {hedefVar ? 'Hedef süreler Genel Ayarlar › Satınalma › aşama hedef süresi; aşan ortalama kırmızı.'
                    : 'Hedef süre tanımlı değil (Genel Ayarlar › Satınalma › aşama hedef süresi); yalnız ortalama gösterilir.'}</div>
              </Kutucuk>
            )}

            {sekme === 'bek' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Belge</th><th>Aşama</th><th>Talep eden</th><th>Konu</th><th className="sag">Tutar</th><th>Kimde</th>
                    <th className="orta">Bekliyor</th><th className="orta">Öncelik</th><th /></tr></thead>
                  <tbody>
                    {bekleyenler.length === 0 && <tr><td colSpan={9} className="bos">Bekleyen belge yok.</td></tr>}
                    {bekleyenler.map(b => (
                      <tr key={b.anahtar} className={'ac' + (secili?.anahtar === b.anahtar ? ' sec' : '')}
                        onClick={() => setSecili(b)} onDoubleClick={() => belgeAc(b)}>
                        <td>{b.no}</td><td>{b.asama}{b.not && <span className="ki-soluk"> · {b.not}</span>}</td><td>{b.talepEden}</td>
                        <td>{b.konu}<KalemRozeti k={b.kalem} />{b.bolundu && <span className="bo-rz sari" style={{ marginLeft: 4 }} title="Talep birden çok siparişe bölündü; süre ilk siparişe göre">bölündü</span>}</td>
                        <td className="sag">{tl(b.tutar)}</td><td>{b.kimde}</td>
                        <td className="orta"><span className={'bo-rz ' + (b.gecikme ? 'kir' : b.gun > 3 ? 'sari' : 'pas')}>{b.gun} gün</span></td>
                        <td className="orta"><OncelikRozeti o={b.oncelik} /></td>
                        <td onClick={e => e.stopPropagation()} style={{ whiteSpace: 'nowrap' }}>
                          {b.belgeTur === 'talep' && b.asama.startsWith('Onay') ? <>
                            <button disabled={!b.hatirlatilabilir || !veri.yetkiler.hatirlat || isliyor} onClick={() => hatirlat(b)}
                              title={b.bugunHatirlatildi ? 'Bugün hatırlatıldı — aynı belge için günde bir' : ''}>🔔 Hatırlat</button>
                            {b.hatirlatmaSayi > 0 && <span className="ki-soluk" title={b.sonHatirlatma ? `son: ${new Date(b.sonHatirlatma).toLocaleString('tr-TR')}` : ''}>
                              {' '}{b.hatirlatmaSayi} kez{b.bugunHatirlatildi ? ' · bugün' : ''}</span>}
                          </> : <span className="lnk" onClick={() => belgeAc(b)}>{b.belgeTur === 'teklif' ? 'Teklife git' : b.belgeTur === 'siparis' ? 'Siparişe git'
                            : b.belgeTur === 'fatura' ? 'Kontrole git' : 'Talebe git'}</span>}
                        </td></tr>
                    ))}
                    {veri.bekleyenSayi > veri.bekleyenler.length && <tr><td colSpan={9} className="bos">… {veri.bekleyenSayi - veri.bekleyenler.length} belge daha</td></tr>}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">"Kimde": onay zincirinde bekleyen basamağın kişisi (atanmamışsa basamağın rolü), teklifte yanıt veren firma sayısı, mal kabulde
                tedarikçi, fatura kontrolünde kontrolü açan. "Hatırlat" onaycıya bildirim gönderir (mevcut onay bildirimi; kanal kullanıcının e-posta / cep bilgisine
                göre); aynı belge için günde bir, aynı onaycıya ikinci kez hatırlatılırsa bir üst basamağa da bilgi gider. Onay / ret Onay ekranındadır.</div>
            </>}

            {sekme === 'ted' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Tedarikçi</th><th className="sag">Sipariş</th><th className="sag">Tutar</th><th className="sag">Zamanında</th>
                    <th className="sag">Ort. gecikme</th><th className="sag">Eksik / fazla</th><th className="sag">Kalite ret</th><th className="sag">Fiyat sapması</th>
                    <th className="sag">Fatura farkı</th><th className="orta">Skor</th></tr></thead>
                  <tbody>
                    {tedarikciler.length === 0 && <tr><td colSpan={10} className="bos">Bu dönemin taleplerinden verilmiş sipariş yok.</td></tr>}
                    {tedarikciler.map(t => <TedarikciSatiri key={t.id} t={t} acik={acik.has(t.id)} cevir={() => cevir(t.id)}
                      kart={() => gz.cariKarti(t.id, true)} />)}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Skor tedarikçi olaylarından türer (gecikme, uygunsuzluk, fatura farkı; son 1 yıl) — icmal yeniden hesaplamaz, Tedarikçi
                Listesi'ndeki skorun aynısıdır; açılan satırda dönemin olayları. Zamanında: söz verilen teslim tarihi olan siparişlerden ilk mal kabulü (yoksa ilk teslim)
                o tarihte ya da önce olanlar; teslim edilmemiş ve tarihi geçmiş sipariş gecikmiş sayılır. Fiyat sapması: sipariş birim fiyatının o tarihten önceki son 3
                alışın ortalamasına göre farkı (tutarla ağırlıklı).</div>
            </>}

            {sekme === 'fiy' && <>
              <Kutucuk baslik="Fiyat analizi — son 3 alış" not={`${veri.fiyat.kalem} kalem · etki ${veri.fiyat.etki > 0 ? '+' : ''}${tl(veri.fiyat.etki)} ₺`}>
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Kod</th><th>Ürün / Hizmet</th><th>Tedarikçi</th><th className="sag">3. önceki</th><th className="sag">2. önceki</th>
                      <th className="sag">Son alış</th><th className="sag">Değişim</th><th className="sag">Bu dönem miktar</th><th className="sag">Etkisi</th></tr></thead>
                    <tbody>
                      {fiyatlar.length === 0 && <tr><td colSpan={9} className="bos">Dönemin siparişlerinde en az iki alışı olan kalem yok.</td></tr>}
                      {fiyatlar.map(f => {
                        const s = f.yuksek ? 'kir' : (f.degisim ?? 0) < -0.05 ? 'si-yesil' : '';
                        return (
                          <tr key={f.anahtar}>
                            <td>{f.kod}</td>
                            <td>{f.stokId ? <span className="lnk" onClick={() => gz.stokKarti(f.stokId)}>{f.ad}</span> : f.ad}
                              {f.hizmet && <span className="bo-rz mavi" style={{ marginLeft: 4 }}>hizmet</span>}</td>
                            <td>{f.tedarikci}</td>
                            <td className="sag" title={f.onceki3Tarih ? tarihT(f.onceki3Tarih) : ''}>{f.onceki3 == null ? '—' : tl(f.onceki3)}</td>
                            <td className="sag" title={tarihT(f.onceki2Tarih)}>{tl(f.onceki2)}</td>
                            <td className="sag" title={tarihT(f.sonTarih)}>{tl(f.son)}</td>
                            <td className={'sag ' + s}>{yuzde(f.degisim, true)}</td><td className="sag">{sayi(f.miktar)}</td>
                            <td className={'sag ' + s}>{f.etki > 0 ? '+' : ''}{tl(f.etki)}</td></tr>
                        );
                      })}
                      {veri.fiyat.kalem > veri.fiyat.satirlar.length && <tr><td colSpan={9} className="bos">… {veri.fiyat.kalem - veri.fiyat.satirlar.length} kalem daha</td></tr>}
                    </tbody>
                  </table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Kalemler dönemin siparişlerinden; alış fiyatı kesin alış faturası satırının KDV hariç birim
                  fiyatıdır (iade hariç). Değişim son alışın 3. önceki alışa (iki alış varsa öncekine) göre farkı; etkisi = (son − 3. önceki) × bu dönem sipariş miktarı.
                  %10 üstü artış kırmızı. Hizmet alımları da dahildir.</div>
              </Kutucuk>
              <Kutucuk baslik="Teklif tasarrufu" not={`ortalama teklife göre ${tl(veri.tasarruf.toplam)} ₺${veri.tasarruf.oran != null ? ` · %${sayi(veri.tasarruf.oran)}` : ''} · son alışa göre ${tl(veri.tasarruf.sonAlisFark)} ₺`}>
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Sipariş</th><th>Talep</th><th>Teklif</th><th>Tedarikçi</th><th className="sag">Teklif sayısı</th><th className="sag">Ort. teklif</th>
                      <th className="sag">Kazanan</th><th className="sag">Tasarruf</th><th className="sag">Son alışa göre</th></tr></thead>
                    <tbody>
                      {veri.tasarruf.satirlar.length === 0 && <tr><td colSpan={9} className="bos">En az iki teklifle verilmiş sipariş yok.</td></tr>}
                      {veri.tasarruf.satirlar.map(t => (
                        <tr key={t.siparisId} className="ac" onDoubleClick={() => gz.belgeKarti(t.siparisId)}>
                          <td>{t.siparisNo}</td><td>{t.talepNo}</td>
                          <td><span className="lnk" onClick={() => kartaGit(`/satinalma-teklif/${t.teklifId}`)}>{t.teklifNo}</span></td>
                          <td>{t.tedarikci}<KalemRozeti k={t.kalem} /></td><td className="sag">{t.teklifSayisi}</td>
                          <td className="sag">{tl(t.ortTeklif)}</td><td className="sag">{tl(t.kazananTeklif)}</td>
                          <td className={'sag ' + (t.tasarruf > 0 ? 'si-yesil' : t.tasarruf < 0 ? 'kir' : '')}>{tl(t.tasarruf)}{t.oran != null && <span className="ki-soluk"> %{sayi(t.oran)}</span>}</td>
                          <td className={'sag ' + (t.sonAlisFark == null ? 'ki-soluk' : t.sonAlisFark > 0 ? 'si-yesil' : t.sonAlisFark < 0 ? 'kir' : '')}>
                            {t.sonAlisFark == null ? '—' : tl(t.sonAlisFark)}</td></tr>
                      ))}
                      <tr className="top"><td colSpan={7}>Toplam ({veri.tasarruf.satirlar.length} sipariş)</td><td className="sag">{tl(veri.tasarruf.toplam)}</td>
                        <td className="sag">{tl(veri.tasarruf.sonAlisFark)}</td></tr>
                    </tbody>
                  </table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Tasarruf = geçerli tekliflerin ortalaması − kazanan teklif (en yüksek teklife göre ölçmek
                  tasarrufu şişirir). Son alışa göre = sipariş kalemlerinin siparişten önceki son alış fiyatıyla tutarı − sipariş tutarı (artı = ucuza alındı).
                  Tek teklifle verilen siparişler tasarrufa katılmaz: {veri.tasarruf.tekTeklif} sipariş · {tl(veri.tasarruf.tekTeklifTutar)} ₺.</div>
              </Kutucuk>
            </>}

            {sekme === 'but' && (
              <Kutucuk baslik={`Bütçe — ${veri.butce.yil}`} not="taahhüt de harcamadır">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Kalem</th><th className="sag">Yıllık plan</th><th className="sag">Gerçekleşen (fatura)</th><th className="sag">Taahhüt (açık sipariş)</th>
                      <th className="sag">Onaylı talep</th><th className="sag">Kalan</th><th className="sag">Kullanım</th><th>Aşım davranışı</th><th style={{ width: 120 }} /></tr></thead>
                    <tbody>
                      {veri.butce.satirlar.length === 0 && <tr><td colSpan={9} className="bos">{veri.butce.yil} yılı için tanımlı bütçe kalemi yok.</td></tr>}
                      {veri.butce.satirlar.map(k => (
                        <tr key={k.id} className="ac" onDoubleClick={() => kartaGit(`/satinalma-butce/${k.id}`)}>
                          <td>{k.kod} {k.ad}</td><td className="sag">{tl(k.plan)}</td><td className="sag">{tl(k.gerceklesen)}</td><td className="sag">{tl(k.taahhut)}</td>
                          <td className="sag ki-soluk">{tl(k.onayliTalep)}</td><td className={'sag' + (k.kalan < 0 ? ' kir' : '')}>{tl(k.kalan)}</td>
                          <td className={'sag' + (k.kullanim >= 90 ? ' kir' : '')}>%{sayi(k.kullanim)}</td>
                          <td><span className={'bo-rz ' + (k.asim === 2 ? 'kir' : k.asim === 0 ? 'pas' : 'sari')}>{k.asimAd}</span></td>
                          <td><Cubuk yuzde={k.kullanim} renk={k.kullanim >= 90 ? '#b3261e' : undefined} /></td></tr>
                      ))}
                      {veri.butce.satirlar.length > 0 && <tr className="top"><td>Toplam</td><td className="sag">{tl(veri.butce.toplam.plan)}</td>
                        <td className="sag">{tl(veri.butce.toplam.gerceklesen)}</td><td className="sag">{tl(veri.butce.toplam.taahhut)}</td>
                        <td className="sag">{tl(veri.butce.toplam.onayliTalep)}</td><td className="sag">{tl(veri.butce.toplam.kalan)}</td>
                        <td className="sag">{veri.butce.toplam.kullanim == null ? '—' : `%${sayi(veri.butce.toplam.kullanim)}`}</td><td /><td /></tr>}
                    </tbody>
                  </table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Taahhüt de harcamadır: açık sipariş henüz faturalanmadı ama parası bağlandı, kalan onu düşer
                  (talep onayındaki bütçe kontrolüyle aynı hesap). Onaylı talep bilgi amaçlı ayrı sütunda; kalandan düşülmez (siparişe dönmeyebilir). Bütçe yılı dönem
                  sonunun yılıdır; bölüm / kategori / tedarikçi süzgeci bu sekmeye uygulanmaz.</div>
              </Kutucuk>
            )}

            {sekme === 'krt' && (
              <Kutucuk baslik="Kritik stoktan otomatik / elle açılan talepler" not={`${veri.kritik.length} talep`}>
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Talep</th><th>Tarih</th><th>Kaynak</th><th>Ürün</th><th className="sag">Talep miktarı</th><th>Durum</th>
                      <th className="sag">Talep → sipariş</th><th>Tedarikçi</th></tr></thead>
                    <tbody>
                      {veri.kritik.length === 0 && <tr><td colSpan={8} className="bos">Bu dönemde kritik stoktan açılan talep yok.</td></tr>}
                      {veri.kritik.map(k => (
                        <tr key={k.id} className="ac" onDoubleClick={() => kartaGit(`/satinalma-talep/${k.id}`)}>
                          <td>{k.no}</td><td>{tarihT(k.tarih)}</td><td>{k.kaynakAd}</td><td>{k.urun}</td><td className="sag">{sayi(k.miktar)}</td>
                          <td><span className={'bo-rz ' + (k.durum === 5 ? 'ok' : k.durum === 3 || k.durum === 8 ? 'kir' : k.durum === 0 ? 'pas' : 'sari')}>{k.durumAd}</span>
                            {k.bolundu && <span className="bo-rz sari" style={{ marginLeft: 4 }}>bölündü</span>}</td>
                          <td className="sag">{gun(k.talepSiparisGun)}</td>
                          <td>{k.siparisId ? <span className="lnk" onClick={() => gz.belgeKarti(k.siparisId)}>{k.tedarikci}</span> : '—'}</td></tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Kaynağı "kritik stok" olan talepler; elle açılanlar Kritik Stok İcmali'nin "Talep aç"
                  eyleminden, otomatik olanlar zamanlı kritik stok işinden. Talep → sipariş: talep tarihinden ilk siparişe.</div>
              </Kutucuk>
            )}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.talep} talep</span><span>{o.siparis} sipariş</span><span>{o.tedarikci} tedarikçi</span>
          {o.hizmetTalep > 0 && <span>{o.hizmetTalep} talepte hizmet alımı</span>}
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}
    </div>
  );
}

function TedarikciSatiri({ t, acik, cevir, kart }: { t: TedarikciKarneSatiri; acik: boolean; cevir(): void; kart(): void }) {
  const skorSinif = t.skor == null ? 'pas' : t.skor >= 85 ? 'ok' : t.skor >= 70 ? 'sari' : 'kir';
  return (
    <Fragment>
      <tr className="ac" onClick={cevir}>
        <td><span className="ok">{acik ? '▾' : '▸'}</span><span className="lnk" onClick={e => { e.stopPropagation(); kart() }}>{t.ad}</span>
          {t.hizmet && <span className="bo-rz mavi" style={{ marginLeft: 4 }}>{t.urun ? 'ürün + hizmet' : 'hizmet'}</span>}</td>
        <td className="sag">{t.siparis}</td><td className="sag">{tl(t.tutar)}</td>
        <td className={'sag' + (t.zamanindaOran != null && t.zamanindaOran < 70 ? ' kir' : '')}>{t.zamanindaOran == null ? '—' : `%${sayi(t.zamanindaOran)}`}</td>
        <td className="sag">{gun(t.ortGecikme)}</td><td className="sag">{t.eksikFazla || '—'}</td><td className="sag">{t.kaliteRet || '—'}</td>
        <td className={'sag' + ((t.fiyatSapma ?? 0) > 5 ? ' kir' : '')}>{yuzde(t.fiyatSapma, true)}</td><td className="sag">{t.faturaFark || '—'}</td>
        <td className="orta"><span className={'bo-rz ' + skorSinif}>{t.skor == null ? '—' : sayi(t.skor)}</span></td>
      </tr>
      {acik && (t.olaylar.length === 0
        ? <tr className="det"><td colSpan={10}>Dönemde tedarikçi olayı yok.</td></tr>
        : t.olaylar.map((x, i) => (
          <tr key={i} className="det"><td colSpan={2}>{new Date(x.zaman).toLocaleDateString('tr-TR')} · {x.turAd}</td>
            <td colSpan={6}>{x.aciklama}</td><td className="sag" colSpan={2}>{x.skorEtki > 0 ? '+' : ''}{sayi(x.skorEtki)} puan</td></tr>
        )))}
    </Fragment>
  );
}

function SatinalmaA4({ v, antet, duzenleyen, sube }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; sube: string }) {
  const o = v.ozet;
  const satirlar = v.huni.filter(h => h.kod !== 'talep');
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>SATINALMA SÜREÇ İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>Şube: {sube}</span>
        <span>{o.talep} talep · {o.siparis} sipariş</span><span>Bütçe yılı: {v.butce.yil}</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Aşama</th><th>Adet</th><th>Tutar</th><th>Bekleyen</th><th>Ort. bekleme</th><th>Hedef</th></tr></thead>
        <tbody>{satirlar.map(h => <tr key={h.kod}><td>{h.ad}</td><td>{h.adet}</td><td>{tl(h.tutar)}</td><td>{h.bekleyen ?? '—'}</td>
          <td>{gun(h.ortGun)}</td><td>{gun(h.hedefGun)}</td></tr>)}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>Talep (tahmini)</span><span>{tl(o.talepTutar)}</span></div>
        <div><span>Siparişe dönen</span><span>{tl(o.siparisTutar)}</span></div>
        <div><span>Teklif tasarrufu (ortalama teklife göre)</span><span>{tl(o.tasarruf)}</span></div>
        <div><span>Fatura uyuşmazlığı</span><span>{o.uyusmaz} · {tl(o.farkTutar)}</span></div>
        <div className="b"><span>ÖDEMEYE ONAYLANAN</span><span>{tl(o.odemeOnay)} ₺</span></div>
      </div>
      <div className="a4-imza"><div>Satınalma Sorumlusu<br />Ad Soyad · İmza</div><div>Mali İşler Müdürü<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Satınalma Süreç İcmali · tutarlar KDV hariç · bütçe kullanımı taahhüt dahil
        {o.butceKullanim != null ? ` (%${sayi(o.butceKullanim)})` : ''}</p>
    </div>
  );
}

export default SatinalmaIcmali;
