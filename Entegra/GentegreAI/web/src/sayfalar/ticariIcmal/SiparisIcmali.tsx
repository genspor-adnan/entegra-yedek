import { Fragment, useEffect, useMemo, useState } from 'react';
import { ApiHatasi, hataMetni, type BelgeYaniti } from '../../api/sozlesme';
import {
  siparisIcmalUclari, type SiparisCariSatiri, type SiparisDurumSuzgeci, type SiparisIcmali as Veri, type SiparisSatiri,
  type SiparisTerminSuzgeci, type SiparisYon, type StokDurumu, type TerminKovasi,
} from '../../api/uclar/siparisIcmal';
import { stokIcmalUclari2 } from '../../api/uclar/stokIcmal';
import { BelgeDonusumModali } from '../../bilesenler/BelgeDonusumModali';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { metinSor, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import { ayAdi, ayBasi, DovizRozetleri, EkranA4, hazirDonem, kisa, kur, sayi, simge, tarihT, TICARI_ICMAL_STILI, tl, useGezinti, yuzde } from './ticariIcmalOrtak';

/**
 * SİPARİŞ İCMALİ `/siparis-icmali` - mockup Ekranlar/İcmal/siparis_icmali.html (kararlar 25.10.2026).
 * "Kime ne söz verdik, ne kadarını teslim ettik, neyi geciktiriyoruz, elimizdeki stok yetecek mi?"
 * Satış / Alış tek ekran; rakamlar SUNUCUDAN (SiparisIcmalUclari): açıklık Açık Satır Listesi'nin
 * kuralı, tutar sipariş dip toplamının satıra düşen payı, teslim siparişten türeyen kesin belgeler.
 *
 * İRSALİYEYE DÖNÜŞTÜR: mevcut dönüşüm akışı (BelgeDonusumModali → POST /api/belge/{id}/donustur) -
 * mevcut akış her siparişten AYRI irsaliye keser; birden çok sipariş seçilince sırayla açılır.
 * KALANI KAPAT: neden zorunlu, loglu; sipariş belgesi değişmez (POST /api/siparis-icmal/kapat).
 * SATINALMA TALEBİ: Kritik Stok İcmali'nin talep ucu (taslak talep). Termin hatırlatması için
 * mevcut bir cari e-posta / ileti şablonu akışı yok - düğme konmadı.
 */
type Sekme = 'ozet' | 'satir' | 'termin' | 'perf' | 'stok' | 'trend' | 'kir' | 'onz';


const DURUMLAR: [SiparisDurumSuzgeci, string][] = [
  ['acik', 'Açık'], ['kismi', 'Kısmi'], ['kapali', 'Kapalı'], ['acikkismi', 'Açık + kısmi'], ['iptal', 'İptal'], ['tumu', 'Tümü'],
];
const DURUM_ROZET: Record<SiparisSatiri['durum'], [string, string]> = {
  acik: ['mavi', 'açık'], kismi: ['sari', 'kısmi'], kapali: ['ok', 'kapalı'], iptal: ['kir', 'kalanı kapatıldı'],
};
const STOK_ROZET: Record<StokDurumu, [string, string]> = {
  '': ['', ''], var: ['ok', 'var'], rezerve: ['ok', 'rezerve'], yolda: ['mavi', 'yolda'], eksik: ['kir', 'eksik'], hizmet: ['', 'hizmet'],
};

const EK_STIL = `
.sip .bo-rz.mor { background:#f1ecfa; color:#6a3fb5; border-color:#ddd0f2; }
.sip .bo-rz.onr { background:#fff4e0; color:#8a5a00; border-color:#f0d3a0; }
.sip .hi-tablo .orta { text-align:center; }
.sip .hi-tablo td.sec { width:22px; text-align:center; }
.sip .bilgi-kutusu.sip-tamam { margin:6px 0; padding:6px 10px; background:#e2f3e8; border:1px solid #bfe3cb; border-radius:4px; }
`;

const gunMetni = (s: SiparisSatiri) =>
  s.gun == null ? '—' : s.gun > 0 ? `${s.gun} gün` : s.gun === 0 ? 'bugün' : `${-s.gun} gün var`;

export function SiparisIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useGezinti();
  const yon: SiparisYon = arama.get('yon') === 'alis' ? 'alis' : 'satis';
  const satis = yon === 'satis';
  const bas = arama.get('bas') ?? ayBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const durum = (arama.get('durum') ?? 'acikkismi') as SiparisDurumSuzgeci;
  const termin = (arama.get('termin') ?? '') as SiparisTerminSuzgeci;
  const sube = Number(arama.get('sube') ?? 0);
  const depo = Number(arama.get('depo') ?? 0);
  const temsilci = Number(arama.get('temsilci') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const para = arama.get('para') ?? '';
  const konsinye = arama.get('konsinye') === '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState<{ metin: string; belgeler?: { id: number; no: string }[] } | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [tazele, setTazele] = useState(0);
  const [sekme, setSekme] = useState<Sekme>('ozet');
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [seciliCari, setSeciliCari] = useState(0);
  const [ara, setAra] = useState('');
  const [kova, setKova] = useState<TerminKovasi>('');
  const [kuyruk, setKuyruk] = useState<{ id: number; tur: number }[]>([]);
  const [uretilen, setUretilen] = useState<{ id: number; no: string }[]>([]);
  const [isliyor, setIsliyor] = useState(false);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ yon, bas, bit, durum });
    if (termin) q.set('termin', termin);
    if (sube) q.set('sube', String(sube));
    if (depo) q.set('depo', String(depo));
    if (temsilci) q.set('temsilci', String(temsilci));
    if (kategori) q.set('kategori', String(kategori));
    if (para) q.set('para', para);
    if (konsinye) q.set('konsinye', '1');
    siparisIcmalUclari.siparisIcmali(q).then(v => { setVeri(v); setSecili(new Set()) })
      .catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [yon, bas, bit, durum, termin, sube, depo, temsilci, kategori, para, konsinye, tazele]);

  const q = ara.trim().toLocaleLowerCase('tr');
  const icerir = (...l: string[]) => !q || l.some(x => x.toLocaleLowerCase('tr').includes(q));
  const cariler = useMemo(() => (veri?.cariler ?? []).filter(c => icerir(c.ad, c.temsilci)), [veri, q]); // eslint-disable-line react-hooks/exhaustive-deps
  const satirlar = useMemo(() => (veri?.satirlar ?? []).filter(s => (!kova || s.kova === kova) && icerir(s.no, s.cari, s.kod, s.urun)),
    [veri, q, kova]); // eslint-disable-line react-hooks/exhaustive-deps
  const tumSatirlar = useMemo(() => {
    const m = new Map<number, SiparisSatiri>();
    for (const s of veri?.satirlar ?? []) m.set(s.satirId, s);
    for (const c of veri?.cariler ?? []) for (const s of c.acikSatirlar) m.set(s.satirId, s);
    return m;
  }, [veri]);
  const seciliSatirlar = [...secili].map(id => tumSatirlar.get(id)).filter((s): s is SiparisSatiri => !!s);
  const cevirAcik = (id: number) => setAcik(a => { const n = new Set(a); n.has(id) ? n.delete(id) : n.add(id); return n });
  const cevirSec = (id: number) => setSecili(a => { const n = new Set(a); n.has(id) ? n.delete(id) : n.add(id); return n });
  const o = veri?.ozet;
  const pb = veri?.para ?? '';
  const cariAdi = satis ? 'Müşteri' : 'Tedarikçi';
  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tümü';
  const temsilciAdi = temsilci ? veri?.secim.temsilciler.find(t => t.id === temsilci)?.ad ?? '' : 'Tümü';
  const durumAdi = DURUMLAR.find(d => d[0] === durum)?.[1] ?? '';
  const cariKarti = (c: { id: number; musteri: boolean; tedarikci: boolean }) => gz.cariKarti(c.id, c.tedarikci && !c.musteri);

  // ---------------------------------------------------------- dönüştür --
  const donustur = async () => {
    setHata(''); setBilgi(null);
    const l = seciliSatirlar.filter(s => s.donusebilir);
    if (l.length === 0) { setHata('Dönüştürülecek açık satır seçilmedi (konsinye ve kapalı satırlar dönüştürülmez).'); return }
    const cari = [...new Set(l.map(s => s.tarafId))];
    if (cari.length !== 1) { setHata(`İrsaliyeye dönüştürme tek ${cariAdi.toLocaleLowerCase('tr')} içindir: aynı carinin satırlarını seçin.`); return }
    const belgeler = [...new Map(l.map(s => [s.belgeId, { id: s.belgeId, tur: s.tur, no: s.no }] as [number, { id: number; tur: number; no: string }])).values()];
    if (belgeler.length > 1 && !await onay(
      `${belgeler.length} sipariş seçildi (${l[0].cari}): ${belgeler.map(b => b.no).join(', ')}.\n\n`
      + 'Mevcut dönüşüm akışı (Siparişler › "İrsaliyeye Dönüştür") her siparişten AYRI irsaliye keser; dönüşüm penceresi '
      + 'sipariş başına sırayla açılacak ve siparişin açık satırlarını gösterecek. Devam edilsin mi?')) return;
    setUretilen([]); setKuyruk(belgeler.map(b => ({ id: b.id, tur: b.tur })));
  };
  const kuyrukIlerle = () => setKuyruk(k => { const kalan = k.slice(1); if (kalan.length === 0) setTazele(t => t + 1); return kalan });
  useEffect(() => {
    if (kuyruk.length === 0 && uretilen.length > 0)
      setBilgi({ metin: `${uretilen.length} irsaliye oluşturuldu (mevcut dönüşüm akışı) — kontrol için açın:`, belgeler: uretilen });
  }, [kuyruk.length, uretilen]);

  // ---------------------------------------------------------- kalanı kapat --
  const kalaniKapat = async () => {
    setHata(''); setBilgi(null);
    const l = seciliSatirlar.filter(s => s.donusebilir && s.kalan > 0);
    if (l.length === 0) { setHata('Kalanı kapatılacak açık satır seçilmedi.'); return }
    const neden = await metinSor(
      `${l.length} satırın kalanı kapatılacak (${l.map(s => `${s.no} · ${s.kod || s.urun} × ${sayi(s.kalan)}`).slice(0, 6).join(', ')}`
      + `${l.length > 6 ? ' …' : ''}).\n\nKalan miktar iptal edilir, satır kapalıya alınır; teslim edilen kısım ve sipariş belgesi değişmez. `
      + 'Kapanış nedeniyle loglanır.', '', 'Kapatma nedeni (zorunlu)', true);
    if (neden == null) return;
    if (neden.trim().length < 3) { setHata('Kapatma nedeni yazılmalı (en az 3 karakter).'); return }
    setIsliyor(true);
    try {
      const y = await siparisIcmalUclari.siparisKalanKapat(l.map(s => ({ satirId: s.satirId, kalan: s.kalan })), neden.trim());
      setBilgi({ metin: `${y.kapatilan} satırın kalanı kapatıldı (${y.belgeler.map(b => b.no).join(', ')}).` });
      setTazele(t => t + 1);
    } catch (h) {
      if (h instanceof ApiHatasi && h.cakismaMi) {
        setHata('Seçilen satırların bir kısmına bu arada teslim girildi; liste tazelendi, kalanları kontrol edip yeniden deneyin.');
        setTazele(t => t + 1);
      } else setHata(hataMetni(h));
    } finally { setIsliyor(false) }
  };

  // ---------------------------------------------------------- satınalma talebi --
  const talepAc = async (k: Veri['karsilama'][number]) => {
    setHata(''); setBilgi(null);
    if (!await onay(`${k.kod} ${k.ad} için ${sayi(k.eksik)} miktarında TASLAK satınalma talebi açılsın mı?\n\n`
      + `Depo: ${k.depo}. Kritik Stok İcmali'ndeki talep akışı kullanılır; açık talebi olan kalem atlanır, talebi onaya siz gönderirsiniz.`)) return;
    setIsliyor(true);
    try {
      const y = await stokIcmalUclari2.kritikTalepAc(k.depoId, [{ stokId: k.stokId, miktar: k.eksik }],
        `Sipariş İcmali · stok karşılama (ilk termin ${tarihT(k.ilkTermin)})`);
      setBilgi({ metin: `Taslak satınalma talebi açıldı: ${y.talepNo || '#' + y.id} (${y.kalem} kalem${y.atlanan ? `, ${y.atlanan} atlandı` : ''}).` });
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };

  const a4 = veri && <SiparisA4 v={veri} cariler={cariler} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi}
    temsilci={temsilciAdi} durumAdi={durumAdi} />;
  const stokSekmeAdi = satis ? 'Stok Karşılama' : 'Gelecek Mal';

  return (
    <div className="hi sip">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI + EK_STIL}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Sipariş İcmali</h1>
          <span className="yol">{satis ? 'Satış' : 'Alış'} › İcmaller › Sipariş İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Sipariş İcmali" dosyaAdi={`Sipariş İcmali ${satis ? 'satış' : 'alış'} ${bas} ${bit}`} devre={!veri}>{a4}</CiktiMenusu>
        {veri?.yetkiler.donustur && (
          <button disabled={isliyor || seciliSatirlar.length === 0} onClick={() => void donustur()}
            title="Mevcut dönüşüm akışıyla; sipariş başına bir irsaliye">
            🚚 Seçili satırları irsaliyeye dönüştür{seciliSatirlar.length ? ` (${seciliSatirlar.length})` : ''}</button>
        )}
        {veri?.yetkiler.kapat && (
          <button disabled={isliyor || seciliSatirlar.length === 0} onClick={() => void kalaniKapat()}>✂ Kalanı kapat…</button>
        )}
        <button disabled={!seciliCari} onClick={() => gz.ekstre(seciliCari)} title={seciliCari ? '' : `Önce ${cariAdi.toLocaleLowerCase('tr')} satırına tıklayın`}>
          📄 Seçili carinin ekstresi</button>
        <span className="sp" />
        <button onClick={() => gz.git('/belge-acik-satir')}>📑 Açık Satır Listesi</button>
        {satis ? <button onClick={() => gz.git('/satis-icmali')}>🛍️ Satış İcmali</button>
          : <button onClick={() => gz.git('/alis-icmali')}>🛒 Alış İcmali</button>}
        <button onClick={() => gz.git('/stok-kritik-stok-icmali')}>⚠ Kritik Stok İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && (
        <div className="bilgi-kutusu sip-tamam">{bilgi.metin}{' '}
          {bilgi.belgeler?.map((b, i) => <Fragment key={b.id}>{i > 0 && ' · '}<span className="lnk" onClick={() => gz.belgeKarti(b.id)}>{b.no}</span></Fragment>)}
        </div>
      )}

      <div className="hi-serit">
        <div className="si-seg">
          <button type="button" className={satis ? 'on' : ''} onClick={() => degistir({ yon: '', temsilci: '' })}>Satış siparişleri</button>
          <button type="button" className={!satis ? 'on' : ''} onClick={() => degistir({ yon: 'alis', temsilci: '' })}>Alış siparişleri</button>
        </div>
        <div className="sel">📅 Sipariş tarihi:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} />
          –<input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
          <select value="" onChange={e => { if (!e.target.value) return; const [b1, b2] = hazirDonem(e.target.value); degistir({ bas: b1, bit: b2 }) }}>
            <option value="">hazır…</option><option value="buay">Bu ay</option><option value="gecenay">Geçen ay</option>
            <option value="son3">Son 3 ay</option><option value="buyil">Bu yıl</option>
          </select></div>
        <div className="sel">⏰ Termin:
          <select value={termin} onChange={e => degistir({ termin: e.target.value })}>
            <option value="">Tümü</option><option value="gecen">Termini geçen</option><option value="hafta">Önümüzdeki 7 gün</option>
            <option value="ay">Önümüzdeki 30 gün</option><option value="yok">Termini yazılmamış</option>
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select>
          <select value={depo} onChange={e => degistir({ depo: e.target.value })} title="Sipariş deposu">
            <option value={0}>Bütün depolar</option>
            {(veri?.secim.depolar ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
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
        <div className="si-seg">
          {DURUMLAR.map(([k, ad]) => <button key={k} type="button" className={durum === k ? 'on' : ''}
            onClick={() => degistir({ durum: k === 'acikkismi' ? '' : k })}>{ad}</button>)}
        </div>
        <div className="sel">💱 Para birimi:
          <select value={para} onChange={e => degistir({ para: e.target.value })}>
            <option value="">TL karşılığı</option>
            {(veri?.secim.paralar ?? []).map(p => <option key={p} value={p}>{p} (yalnız {p} siparişler)</option>)}
          </select></div>
        <label className="ti-chk" title="Konsinye satış değildir: ayrı rozetle görünür; açık tutara, termine ve teslim performansına katılmaz">
          <input type="checkbox" checked={konsinye} onChange={e => degistir({ konsinye: e.target.checked ? '1' : '' })} /> Konsinye dahil</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.gecenSatir > 0 && <span className="bo-rz kir" style={{ cursor: 'pointer' }}
          onClick={() => { degistir({ termin: 'gecen' }); setSekme('satir') }}>Termini geçen: {o.gecenSatir} satır</span>}
        {o && o.terminsizAcik > 0 && <span className="bo-rz onr" title="Sipariş girişinde termin zorunluluğu önerilir (Satış Belgeleri ayarı)">
          Dikkat: {o.terminsizAcik} açık satırın termini yok</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Açık Sipariş Tutarı" deg={kisa(o.acikTutar, pb)} alt={`KDV hariç · ${o.acikSiparis} sipariş · kalan × satır payı`} sinif="mor" />
          <Kutu bas="Açık Satır" deg={sayi(o.acikSatir)} alt={`kısmi teslim ${o.kismiSatir}${o.taslakSatir ? ` · taslak belgede ${o.taslakSatir}` : ''}`} />
          <Kutu bas="Termini Geçen" deg={`${o.gecenSatir} satır`} alt={`${tl(o.gecenTutar)} ${simge(pb)}${o.gecenSatir ? ` · en eski ${o.enEskiGecikme} gün` : ''}`}
            sinif={o.gecenSatir ? 'teh' : 'iyi'} />
          <Kutu bas="Zamanında + Tam (OTIF)" deg={yuzde(o.otif)}
            alt={`kapanan ${o.kapananSatir} satırdan${o.otifGecenAy != null ? ` · geçen ay ${yuzde(o.otifGecenAy)}` : ''}`}
            sinif={o.otif == null ? '' : o.otif >= 90 ? 'iyi' : o.otif >= 75 ? 'uy' : 'teh'} />
          <Kutu bas="Ort. Teslim Süresi" deg={o.ortTeslim == null ? '—' : `${sayi(o.ortTeslim)} gün`} alt={satis ? 'sipariş → ilk irsaliye' : 'sipariş → ilk mal kabul'} />
          <Kutu bas="Dönüşüm" deg={yuzde(o.donusum)} alt={satis ? 'siparişten irsaliyeye geçen miktar' : 'siparişten teslim alınan miktar'} />
          {satis
            ? <Kutu bas="Karşılanamayan" deg={`${o.karsilanamayan} kalem`} alt="eldeki + yoldaki stok yetmiyor" sinif={o.karsilanamayan ? 'uy' : 'iyi'} />
            : <Kutu bas="Gelecek Mal" deg={kisa(o.gelecekTutar, pb)} alt={`${o.gelecekKalem} stok kalemi · açık alış siparişi`} />}
          <Kutu bas="İptal Edilen Kalan" deg={o.iptalTutar ? `−${kisa(o.iptalTutar, pb)}` : '—'} alt={`${o.iptalSatir} satır · neden yazılı`}
            sinif={o.iptalTutar ? 'teh' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['ozet', 'Özet', null], ['satir', 'Açık Satırlar', veri.satirSayisi], ['termin', 'Termin Takvimi', null],
              ['perf', 'Teslim Performansı', null], ['stok', stokSekmeAdi, satis ? veri.karsilama.length : veri.gelecek.length],
              ['trend', 'Trend', null], ['kir', 'Kırılımlar', null], ['onz', '🖨 Önizleme (A4)', null]]} />

            {(sekme === 'ozet' || sekme === 'satir') && (
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder={sekme === 'ozet' ? `🔍 ${cariAdi} ya da temsilci…` : '🔍 Sipariş, cari, kod ya da ürün…'} value={ara}
                  onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                {sekme === 'satir' && kova && <span className="bo-rz mavi" style={{ cursor: 'pointer' }} onClick={() => setKova('')}>
                  termin: {veri.takvim.find(t => t.kova === kova)?.ad} ✕</span>}
                <span className="ki-soluk">{sekme === 'ozet'
                  ? 'satıra tıkla: açık satırları · çift tık: cari ekstresi · ada tıkla: cari kartı · kalan tutara göre sıralı'
                  : `☐ seç: ${veri.yetkiler.donustur ? 'irsaliyeye dönüştür' : ''}${veri.yetkiler.donustur && veri.yetkiler.kapat ? ' / ' : ''}${veri.yetkiler.kapat ? 'kalanı kapat' : ''} · satıra tıkla: siparişi aç · durum: ${durumAdi}`}</span>
              </div>
            )}

            {sekme === 'ozet' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>{cariAdi}</th><th>Temsilci</th><th className="sag">Sipariş</th><th className="sag">Açık satır</th>
                    <th className="sag">Sipariş tutarı</th><th className="sag">Teslim edilen</th><th className="sag">Kalan tutar</th>
                    <th className="sag">Termini geçen</th><th className="sag">OTIF</th>{!satis && <th className="sag">Skor</th>}<th style={{ width: 100 }}>Pay</th></tr></thead>
                  <tbody>
                    {cariler.length === 0 && <tr><td colSpan={satis ? 10 : 11} className="bos">Bu dönemde sipariş yok.</td></tr>}
                    {cariler.slice(0, 500).map(c => (
                      <CariSatiri key={c.id} c={c} satis={satis} acik={acik.has(c.id)} secili={seciliCari === c.id}
                        tikla={() => { setSeciliCari(c.id); cevirAcik(c.id) }} cift={() => gz.ekstre(c.id)} kart={() => cariKarti(c)}
                        belgeAc={gz.belgeKarti} />
                    ))}
                    {cariler.length > 500 && <tr><td colSpan={satis ? 10 : 11} className="bos">… {cariler.length - 500} cari daha (aramayla daraltın)</td></tr>}
                    <tr className="top"><td colSpan={2}>Toplam ({veri.cariToplam.cari} {cariAdi.toLocaleLowerCase('tr')})</td>
                      <td className="sag">{veri.cariToplam.siparis}</td><td className="sag">{veri.cariToplam.acikSatir}</td>
                      <td className="sag">{tl(veri.cariToplam.siparisTutar)}</td><td className="sag">{tl(veri.cariToplam.teslimTutar)}</td>
                      <td className="sag">{tl(veri.cariToplam.kalanTutar)}</td><td className="sag">{tl(veri.cariToplam.gecenTutar)}</td>
                      <td className="sag">{yuzde(veri.cariToplam.otif)}</td>{!satis && <td />}<td /></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Kalan tutar = siparişin dip toplamının (KDV hariç) satıra düşen payı × kalan / sipariş miktarı; iskontolar düşülmüş, ekran
                toplamaz. Açıklık Açık Satır Listesi'nin kuralıdır; teslim, siparişten türeyen kesin irsaliye / fatura / fiştir (taslak teslim
                sayılmaz). Temsilci siparişteki satıcıdır. {pb ? `Tutarlar ${pb} cinsinden (sipariş kuruyla).` : 'Dövizli sipariş sipariş kuruyla TL; rozet açık kısmın döviz tutarıdır.'}
                {o.konsinyeSatir > 0 && ` Konsinye: ${o.konsinyeSatir} açık satır · ${tl(o.konsinyeTutar)} (açık tutara katılmaz).`}
              </div>
            </>}

            {sekme === 'satir' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th className="sec">
                    <input type="checkbox" checked={satirlar.length > 0 && satirlar.filter(s => s.donusebilir).every(s => secili.has(s.satirId))}
                      onChange={e => setSecili(e.target.checked ? new Set(satirlar.filter(s => s.donusebilir).map(s => s.satirId)) : new Set())} /></th>
                    <th>Sipariş</th><th>Tarih</th><th>{cariAdi}</th><th>Ürün</th><th className="sag">Sipariş</th><th className="sag">Teslim</th>
                    <th className="sag">Kalan</th><th className="sag">Kalan tutar</th><th>Termin</th><th className="sag">Gecikme</th>
                    {satis && <th className="orta">Stok</th>}<th className="orta">Durum</th></tr></thead>
                  <tbody>
                    {satirlar.length === 0 && <tr><td colSpan={satis ? 13 : 12} className="bos">Süzgece uyan satır yok.</td></tr>}
                    {satirlar.map(s => (
                      <tr key={s.satirId} className={'ac' + (secili.has(s.satirId) ? ' ti-sec' : '')} onClick={() => gz.belgeKarti(s.belgeId)}>
                        <td className="sec" onClick={e => e.stopPropagation()}>
                          {s.donusebilir && <input type="checkbox" checked={secili.has(s.satirId)} onChange={() => cevirSec(s.satirId)} />}</td>
                        <td>{s.no}</td><td>{tarihT(s.tarih).slice(0, 5)}</td><td>{s.cari}</td>
                        <td>{s.kod && <span className="ki-soluk">{s.kod} </span>}{s.urun}{s.doviz != null && <DovizRozetleri l={[{ para: s.para, tutar: s.doviz }]} />}</td>
                        <td className="sag">{sayi(s.miktar)}</td><td className="sag">{sayi(s.teslim)}</td>
                        <td className="sag"><b>{sayi(s.kalan)}</b>{s.taslak > 0 && <span className="bo-rz sari" title="Taslak irsaliye / faturada; teslim sayılmaz"> taslak {sayi(s.taslak)}</span>}</td>
                        <td className="sag">{tl(s.kalanTutar)}</td>
                        <td>{s.termin ? tarihT(s.termin) : <span className="ki-soluk">(yok)</span>}{s.termin && !s.terminSatirda && <span className="ki-soluk" title="Siparişin sözleşmeli teslim tarihi"> ·b</span>}</td>
                        <td className={'sag' + (s.gun != null && s.gun > 0 ? ' kir' : ' ki-soluk')}>{gunMetni(s)}</td>
                        {satis && <td className="orta">{s.stokDurum && <span className={'bo-rz ' + STOK_ROZET[s.stokDurum][0]}
                          title={s.eksik ? `eksik ${sayi(s.eksik)}` : ''}>{STOK_ROZET[s.stokDurum][1]}{s.eksik > 0 && ` ${sayi(s.eksik)}`}</span>}</td>}
                        <td className="orta">
                          <span className={'bo-rz ' + DURUM_ROZET[s.durum][0]} title={s.kapanis ? `${s.kapanis.neden} · ${s.kapanis.kapatan} · ${tarihT(s.kapanis.tarih)}` : ''}>
                            {DURUM_ROZET[s.durum][1]}</span>
                          {s.konsinye && <span className="bo-rz mor" style={{ marginLeft: 4 }}>konsinye</span>}</td>
                      </tr>
                    ))}
                    {veri.satirSayisi > veri.satirlar.length && <tr><td colSpan={satis ? 13 : 12} className="bos">… {veri.satirSayisi - veri.satirlar.length} satır daha (süzgeçle daraltın)</td></tr>}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Teslim = siparişten türeyen kesin irsaliye / faturaların miktarı (belge dönüşüm izi); taslak irsaliye teslim sayılmaz. Termin satırın
                teslim tarihi{satis ? '' : ', yoksa siparişin sözleşmeli teslim tarihi (·b)'}; termini olmayan satır gecikmeye girmez. "Kalanı kapat"
                kalan miktarı iptal eder, neden ister ve satırı kapalıya alır; sipariş belgesi değişmez, kapanış ayrı kayıt olarak loglanır.
                İrsaliyeye dönüştürme mevcut dönüşüm penceresini sipariş başına açar.
              </div>
            </>}

            {sekme === 'termin' && (
              <Kutucuk baslik="Termin takvimi — önümüzdeki 4 hafta" not="satıra tıkla: o haftanın satırları">
                <table className="hi-tablo">
                  <thead><tr><th>Hafta</th><th className="sag">Satır</th><th className="sag">Miktar</th><th className="sag">Tutar</th>
                    {satis && <><th className="sag">Stokta hazır</th><th className="sag">Eksik</th></>}<th style={{ width: 200 }}>Yük</th></tr></thead>
                  <tbody>
                    {veri.takvim.map(t => (
                      <tr key={t.kova} className="ac" onClick={() => { setKova(t.kova); setSekme('satir') }}>
                        <td className={t.kova === 'gecen' ? 'kir' : t.kova === 'yok' ? 'ki-soluk' : ''}>{t.ad}
                          {t.kova === 'yok' && t.satir > 0 && <span className="bo-rz onr" style={{ marginLeft: 6 }}>Dikkat</span>}</td>
                        <td className="sag">{t.satir}</td><td className="sag">{sayi(t.miktar)}</td><td className="sag">{tl(t.tutar)}</td>
                        {satis && <><td className="sag">{t.hazir ?? '—'}</td><td className={'sag' + (t.eksik ? ' kir' : '')}>{t.eksik ?? '—'}</td></>}
                        <td><Cubuk yuzde={t.cubuk} renk={t.kova === 'gecen' ? '#b3261e' : undefined} /></td></tr>
                    ))}
                  </tbody>
                </table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Termin = satırın teslim tarihi; {satis ? '' : 'satırda yoksa siparişin sözleşmeli teslim tarihi; '}
                  ikisi de yoksa "termini yazılmamış" (gecikme hesabına girmez — sipariş girişinde termin zorunluluğu önerilir). Haftalar bugünden başlar.
                  {satis && ' Stokta hazır / eksik: Stok Karşılama sekmesindeki dağıtımdan.'}</div>
              </Kutucuk>
            )}

            {sekme === 'perf' && (
              <Kutucuk baslik={`Teslim performansı — kapanan satırlar (${cariAdi.toLocaleLowerCase('tr')})`}
                not={satis ? 'Alış yönünde aynı tablo tedarikçi karnesidir' : 'tedarikçi karnesi · skor satınalma skor olaylarından'}>
                <table className="hi-tablo">
                  <thead><tr><th>{cariAdi}</th><th className="sag">Kapanan satır</th><th className="sag">Zamanında</th><th className="sag">Geç</th>
                    <th className="sag">Eksik kapanan</th><th className="sag">OTIF</th><th className="sag">Ort. gecikme</th><th className="sag">Ort. teslim süresi</th>
                    <th className="sag">Terminsiz</th>{!satis && <><th className="sag">Tedarikçi skoru</th><th className="sag">Gecikme olayı (1 yıl)</th></>}</tr></thead>
                  <tbody>
                    {veri.performans.length === 0 && <tr><td colSpan={satis ? 9 : 11} className="bos">Bu dönemin siparişlerinde kapanan satır yok.</td></tr>}
                    {veri.performans.map(p => (
                      <tr key={p.id} className="ac" onDoubleClick={() => gz.ekstre(p.id)}>
                        <td><span className="lnk" onClick={() => cariKarti(p)}>{p.ad}</span></td>
                        <PerfHucreleri d={p.deger} />
                        {!satis && <><td className={'sag' + (p.skor != null && p.skor < 70 ? ' kir' : '')}>{p.skor == null ? '—' : sayi(p.skor)}</td>
                          <td className="sag">{p.skorGecikme ?? '—'}</td></>}
                      </tr>
                    ))}
                    <tr className="top"><td>Toplam</td><PerfHucreleri d={veri.performansToplam} />{!satis && <><td /><td /></>}</tr>
                  </tbody>
                </table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Zamanında = son teslim termin gününde ya da önce (kısmi teslimde satırın
                  tamamlandığı gün). OTIF (zamanında ve tam) = zamanında VE kalan sıfır kapandı. "Kalanı kapat" ile kapanan satır eksik sayılır. Termini
                  yazılmamış satır orana girmez. Ort. teslim süresi sipariş → ilk sevk. Konsinye katılmaz.
                  {!satis && ' Tedarikçi skoru Satınalma\'nın skor olaylarından okunur; icmal yeniden hesaplamaz.'}</div>
              </Kutucuk>
            )}

            {sekme === 'stok' && satis && (
              <Kutucuk baslik="⚠ Açık satış siparişini karşılayamayan stoklar" not="eldeki: sipariş deposundaki kalan (SKT'si geçmiş lot hariç) · yoldaki: açık alış siparişi">
                <table className="hi-tablo">
                  <thead><tr><th>Kod</th><th>Ürün</th><th>Depo</th><th className="sag">Açık sipariş</th><th className="sag">Eldeki</th><th className="sag">Rezerve</th>
                    <th className="sag">Yoldaki (alış sip.)</th><th className="sag">Eksik</th><th>İlk termin</th><th>Öneri</th></tr></thead>
                  <tbody>
                    {veri.karsilama.length === 0 && <tr><td colSpan={10} className="bos">Açık siparişlerin hepsi eldeki stokla karşılanıyor.</td></tr>}
                    {veri.karsilama.map(k => (
                      <tr key={`${k.stokId}-${k.depoId}`}>
                        <td>{k.kod}</td><td><span className="lnk" onClick={() => gz.stokKarti(k.stokId)}>{k.ad}</span></td><td>{k.depo}</td>
                        <td className="sag">{sayi(k.acik)}</td><td className="sag">{sayi(k.eldeki)}</td><td className="sag">{sayi(k.rezerve)}</td>
                        <td className="sag" title={k.yoldakiNo}>{sayi(k.yoldaki)}</td>
                        <td className={'sag' + (k.eksik > 0 ? ' kir' : '')}><b>{sayi(k.eksik)}</b></td>
                        <td className={k.gecti ? 'kir' : ''}>{tarihT(k.ilkTermin)}{k.gecti && ' geçti'}</td>
                        <td>{k.oneri === 'yolda' ? <span className="bo-rz ok">yoldakiyle yetiyor</span>
                          : k.talepAcilir ? <button disabled={isliyor} onClick={() => void talepAc(k)}>Satınalma talebi aç</button>
                          : <span className="bo-rz sari">satınalma gerekli</span>}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Karşılama = eldeki (SKT'si geçmiş lot hariç) + yoldaki − açık satış siparişi.
                  Rezerve edilmiş miktar önce kendi satırını karşılar; kalan serbest stok açık siparişlere termin sırasıyla dağıtılır (ilk termin ilk alır),
                  sonra yoldaki. Dönemden bağımsız, bütün açık satış siparişleri. "Satınalma talebi aç" Kritik Stok İcmali'ndeki gibi taslak talep oluşturur
                  (satinalma.talep Ekle yetkisi); deposuz siparişte talep açılmaz.</div>
              </Kutucuk>
            )}

            {sekme === 'stok' && !satis && (
              <Kutucuk baslik="Gelecek mal — açık alış siparişleri" not="termin sırasıyla · bekleyen satış siparişi eldekinden fazlaysa işaretli">
                <table className="hi-tablo">
                  <thead><tr><th>Kod</th><th>Ürün</th><th>Tedarikçi</th><th className="sag">Gelecek miktar</th><th className="sag">Tutar</th>
                    <th>İlk termin</th><th className="sag">Geciken satır</th><th className="sag">Eldeki</th><th className="sag">Bekleyen satış sip.</th></tr></thead>
                  <tbody>
                    {veri.gelecek.length === 0 && <tr><td colSpan={9} className="bos">Açık alış siparişi yok.</td></tr>}
                    {veri.gelecek.map(g => (
                      <tr key={g.stokId} title={g.siparisler}>
                        <td>{g.kod}</td><td><span className="lnk" onClick={() => gz.stokKarti(g.stokId)}>{g.ad}</span></td><td>{g.tedarikciler}</td>
                        <td className="sag"><b>{sayi(g.kalan)}</b></td><td className="sag">{tl(g.tutar)}</td>
                        <td className={g.ilkTermin && g.ilkTermin.slice(0, 10) < veri.bugun.slice(0, 10) ? 'kir' : ''}>{tarihT(g.ilkTermin)}</td>
                        <td className={'sag' + (g.geciken ? ' kir' : '')}>{g.geciken || '—'}</td>
                        <td className="sag">{sayi(g.eldeki)}</td>
                        <td className="sag">{sayi(g.satisBekleyen)}{g.bekleniyor && <span className="bo-rz sari" style={{ marginLeft: 4 }}>bekleniyor</span>}</td></tr>
                    ))}
                  </tbody>
                </table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Açık alış sipariş satırlarının kalanı (Açık Satır Listesi kuralı), stok bazında.
                  Eldeki = kalan − rezerve (bütün depolar); bekleyen satış siparişi = açık satış sipariş kalanı.</div>
              </Kutucuk>
            )}

            {sekme === 'trend' && (
              <Kutucuk baslik={`Aylık sipariş ve ${satis ? 'sevk' : 'teslim alma'} — son 12 ay`} not="çubuk: sipariş tutarı">
                <table className="hi-tablo"><thead><tr><th>Ay</th><th className="sag">Sipariş tutarı</th><th className="sag">{satis ? 'Sevk edilen' : 'Teslim alınan'}</th>
                  <th className="sag">Ay sonu açık</th><th className="sag">OTIF</th><th className="sag">Ort. teslim</th><th style={{ width: 200 }} /></tr></thead>
                  <tbody>
                    {veri.trend.aylar.map(a => (
                      <tr key={a.ay}><td>{a.kismiGun ? <b>{ayAdi(a.ay)} ({a.kismiGun}'i)</b> : ayAdi(a.ay)}</td>
                        <td className="sag">{tl(a.siparis)}</td><td className="sag">{tl(a.sevk)}</td><td className="sag">{tl(a.aySonuAcik)}</td>
                        <td className="sag" title={`${a.kapanan} kapanan satır`}>{yuzde(a.otif)}</td>
                        <td className="sag">{a.ortTeslim == null ? '—' : `${sayi(a.ortTeslim)} gün`}</td><td><Cubuk yuzde={a.cubuk} /></td></tr>
                    ))}
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Sipariş tutarı sipariş tarihine, sevk kesin irsaliye / fatura tarihine göre.
                  Ay sonu açık: o ayın sonunda teslim edilmemiş ve kapatılmamış kalan. OTIF satırın tamamlandığı aya yazılır. Şube, depo, temsilci, kategori
                  ve para seçimi uygulanır; konsinye katılmaz.</div>
              </Kutucuk>
            )}

            {sekme === 'kir' && <>
              <div className="si-iki">
                <Kutucuk baslik="Temsilci" not="siparişteki satıcı">
                  <table className="hi-tablo"><thead><tr><th>Temsilci</th><th className="sag">Açık tutar</th><th className="sag">Termini geçen</th>
                    <th className="sag">OTIF</th><th className="sag">Cari</th></tr></thead>
                    <tbody>{veri.kirilim.temsilci.map(t => (
                      <tr key={t.id} className="ac" onDoubleClick={() => degistir({ temsilci: String(t.id) })}>
                        <td className={t.id === -1 ? 'ki-soluk' : ''}>{t.ad}</td><td className="sag">{tl(t.acikTutar)}</td>
                        <td className={'sag' + (t.gecenTutar > 0 ? ' kir' : '')}>{tl(t.gecenTutar)}</td><td className="sag">{yuzde(t.otif)}</td>
                        <td className="sag">{t.cari}</td></tr>))}</tbody></table>
                  <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Çift tık: temsilciyle süz.</div>
                </Kutucuk>
                <Kutucuk baslik="Kategori" not="ana kategori">
                  <table className="hi-tablo"><thead><tr><th>Kategori</th><th className="sag">Açık tutar</th><th className="sag">Pay</th>
                    {satis && <th className="sag">Eksik kalem</th>}</tr></thead>
                    <tbody>{veri.kirilim.kategori.map(k => (
                      <tr key={k.ad}><td>{k.ad}</td><td className="sag">{tl(k.acikTutar)}</td><td className="sag">%{sayi(k.pay)}</td>
                        {satis && <td className={'sag' + (k.eksikKalem ? ' kir' : '')}>{k.eksikKalem ?? '—'}</td>}</tr>))}</tbody></table>
                </Kutucuk>
              </div>
              <div className="si-iki">
                <Kutucuk baslik="Şube / depo">
                  <table className="hi-tablo"><thead><tr><th>Şube · Depo</th><th className="sag">Açık tutar</th><th className="sag">Açık satır</th></tr></thead>
                    <tbody>{veri.kirilim.subeDepo.map(s => <tr key={s.ad}><td>{s.ad}</td><td className="sag">{tl(s.acikTutar)}</td><td className="sag">{s.satir}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Para birimi" not="TL karşılığı sipariş kuruyla">
                  <table className="hi-tablo"><thead><tr><th>Para birimi</th><th className="sag">Sipariş</th><th className="sag">Açık (döviz)</th>
                    <th className="sag">Sipariş kuru</th><th className="sag">Açık TL</th><th className="sag">Bugünkü kurla</th></tr></thead>
                    <tbody>
                      {veri.kirilim.para.satirlar.length === 0 && <tr><td colSpan={6} className="bos">Bu dönemde sipariş yok.</td></tr>}
                      {veri.kirilim.para.satirlar.map(p => (
                        <tr key={p.para}><td>{p.para}</td><td className="sag">{p.siparis}</td>
                          <td className="sag">{p.acikDoviz == null ? '—' : `${simge(p.para)} ${tl(p.acikDoviz)}`}</td>
                          <td className="sag">{kur(p.siparisKuru)}</td><td className="sag">{tl(p.acikTl)}</td>
                          <td className="sag">{p.acikBugun == null ? '—' : tl(p.acikBugun)}</td></tr>))}
                      <tr className="top"><td>Toplam</td><td className="sag">{veri.kirilim.para.toplam.siparis}</td><td /><td />
                        <td className="sag">{tl(veri.kirilim.para.toplam.acikTl)}</td><td /></tr>
                    </tbody></table>
                  <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Açık sipariş tutarı sipariş kuruyla; bugünkü kurla değer bilgi amaçlıdır
                    ({satis ? 'faturada' : 'alış faturasında'} o günün kuru uygulanır). Bu tablo her zaman TL karşılığıdır.</div>
                </Kutucuk>
              </div>
            </>}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.acikSiparis} sipariş</span><span>{o.acikSatir} açık satır</span><span>Yön: {satis ? 'satış' : 'alış'}</span>
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}

      {kuyruk.length > 0 && (
        <BelgeDonusumModali
          key={kuyruk[0].id}
          belgeId={kuyruk[0].id}
          belgeTur={kuyruk[0].tur}
          varsayilanHedef={satis ? 14 : 10}
          hedefKilitli
          onKapat={kuyrukIlerle}
          onTamam={(yeni: BelgeYaniti) => {
            const id = Number(yeni.belge.id ?? 0);
            if (id) setUretilen(u => [...u, { id, no: String(yeni.belge.belgeNo || '#' + id) }]);
          }}
        />
      )}
    </div>
  );
}

function PerfHucreleri({ d }: { d: Veri['performansToplam'] }) {
  return (<>
    <td className="sag">{d.kapanan}</td><td className="sag">{d.zamaninda}</td><td className={'sag' + (d.gec ? ' kir' : '')}>{d.gec}</td>
    <td className={'sag' + (d.eksik ? ' kir' : '')}>{d.eksik}</td>
    <td className={'sag' + (d.otif != null && d.otif < 75 ? ' kir' : '')}><b>{yuzde(d.otif)}</b></td>
    <td className="sag">{d.ortGecikme == null ? '—' : `${sayi(d.ortGecikme)} gün`}</td>
    <td className="sag">{d.ortTeslim == null ? '—' : `${sayi(d.ortTeslim)} gün`}</td>
    <td className="sag ki-soluk">{d.terminsiz || '—'}</td>
  </>);
}

function CariSatiri({ c, satis, acik, secili, tikla, cift, kart, belgeAc }: {
  c: SiparisCariSatiri; satis: boolean; acik: boolean; secili: boolean; tikla(): void; cift(): void; kart(): void; belgeAc(id: number): void;
}) {
  const kolon = satis ? 10 : 11;
  return (
    <Fragment>
      <tr className={'ac' + (secili ? ' ti-sec' : '')} onClick={tikla} onDoubleClick={cift}>
        <td className="ti-ad"><span className="ok">{acik ? '▾' : '▸'}</span>
          <span className="lnk" onClick={e => { e.stopPropagation(); kart() }}>{c.ad}</span><DovizRozetleri l={c.doviz} />
          {c.konsinyeTutar > 0 && <span className="bo-rz mor" style={{ marginLeft: 4 }} title="Konsinye açık kalan (açık tutara katılmaz)">konsinye {tl(c.konsinyeTutar)}</span>}</td>
        <td className={c.temsilci === '(temsilcisiz)' ? 'ki-soluk' : ''}>{c.temsilci}</td>
        <td className="sag">{c.siparis}</td><td className="sag">{c.acikSatir}</td>
        <td className="sag">{tl(c.siparisTutar)}</td><td className="sag">{tl(c.teslimTutar)}</td>
        <td className="sag"><b>{tl(c.kalanTutar)}</b></td>
        <td className={'sag' + (c.gecenTutar > 0 ? ' kir' : ' ki-soluk')}>{c.gecenTutar > 0 ? tl(c.gecenTutar) : '—'}</td>
        <td className={'sag' + (c.otif != null && c.otif < 75 ? ' kir' : '')}>{yuzde(c.otif)}</td>
        {!satis && <td className={'sag' + (c.skor != null && c.skor < 70 ? ' kir' : '')}>{c.skor == null ? '—' : sayi(c.skor)}</td>}
        <td><Cubuk yuzde={c.cubuk} /></td>
      </tr>
      {acik && (
        <tr className="si-det"><td colSpan={kolon}>
          {c.acikSatirlar.length === 0 && 'Açık satır yok.'}
          {c.acikSatirlar.map((s, i) => (
            <Fragment key={s.satirId}>{i > 0 && '  ·  '}
              <span className="lnk" onClick={() => belgeAc(s.belgeId)}>{s.no}</span> {s.kod || s.urun} × {sayi(s.kalan)}
              {s.termin ? ` · ${tarihT(s.termin).slice(0, 5)}` : ' · terminsiz'}
              {s.gun != null && s.gun > 0 && <span className="kir"> ({s.gun} gün)</span>}
              {s.konsinye && <span className="bo-rz mor" style={{ marginLeft: 3 }}>konsinye</span>}
            </Fragment>
          ))}
          {c.acikSatirSayisi > c.acikSatirlar.length && `  ·  … ${c.acikSatirSayisi - c.acikSatirlar.length} satır daha`}
        </td></tr>
      )}
    </Fragment>
  );
}

function SiparisA4({ v, cariler, antet, duzenleyen, sube, temsilci, durumAdi }: {
  v: Veri; cariler: SiparisCariSatiri[]; antet: Record<string, unknown> | null; duzenleyen: string;
  sube: string; temsilci: string; durumAdi: string;
}) {
  const o = v.ozet;
  const satis = v.yon === 'satis';
  const pb = simge(v.para);
  const dovizli = v.para ? [] : v.kirilim.para.satirlar.filter(p => !p.yerel && p.acikDoviz);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>SİPARİŞ İCMALİ — AÇIK {satis ? 'SATIŞ' : 'ALIŞ'} SİPARİŞLERİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>Durum: {durumAdi.toLocaleLowerCase('tr')}</span>
        <span>Şube: {sube} · Temsilci: {temsilci}</span><span>{o.acikSiparis} sipariş · {o.acikSatir} satır</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>{satis ? 'Müşteri' : 'Tedarikçi'}</th><th>Açık satır</th><th>Kalan tutar</th><th>Termini geçen</th><th>OTIF</th></tr></thead>
        <tbody>{cariler.filter(c => c.acikSatir > 0).map(c => <tr key={c.id}><td>{c.ad}</td><td>{c.acikSatir}</td><td>{tl(c.kalanTutar)}</td>
          <td>{c.gecenTutar > 0 ? tl(c.gecenTutar) : '—'}</td><td>{yuzde(c.otif)}</td></tr>)}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>Sipariş tutarı</span><span>{tl(o.siparisTutar)}</span></div>
        <div><span>Teslim edilen</span><span>−{tl(o.teslimTutar)}</span></div>
        {o.iptalTutar > 0 && <div><span>Kalanı kapatılan</span><span>−{tl(o.iptalTutar)}</span></div>}
        <div><span>Termini geçen</span><span>{tl(o.gecenTutar)}</span></div>
        <div className="b"><span>AÇIK SİPARİŞ</span><span>{tl(o.acikTutar)} {pb}</span></div>
        {dovizli.length > 0 && <div className="not"><span>bunun {dovizli.map(p => `${simge(p.para)} ${tl(p.acikDoviz ?? 0)} (sipariş kuru ${kur(p.siparisKuru)})`).join(', ')} dövizli</span><span /></div>}
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>{satis ? 'Satış Müdürü' : 'Satınalma Müdürü'}<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Sipariş İcmali · KDV hariç · tutarlar sipariş dip toplamlarından (fn_belge_diptoplam) · ekran toplamaz</p>
    </div>
  );
}

export default SiparisIcmali;
