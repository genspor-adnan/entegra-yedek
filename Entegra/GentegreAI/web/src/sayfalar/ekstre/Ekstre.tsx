import { EkstreIkon } from '../../bilesenler/EkstreIkon';
import { CariBilgiBandi } from '../../bilesenler/CariBilgiBandi';
import { CariAksiyonMenusu } from '../../bilesenler/CariAksiyonMenusu';
import { useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { Navigate, useLocation, useNavigate, useSearchParams } from 'react-router-dom';
import { EkranSekmesiBaglami, LISTE_TAZELE_OLAYI, baslikAnahtari, sekmeAdi } from '../../bilesenler/sekmeBaglami';
import { belgeTuruBilgisi } from '../belgeTuru';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { Ekstre as Veri, EkstreHesapSecimi, EkstreParasi, EkstreSatiri, EkstreTuru } from '../../api/uclar/ekstre';
import { para, paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { mesaj } from '../../bilesenler/mesaj';
import { TarafArama } from '../../bilesenler/TarafArama';
import { c } from '../../dil/ceviri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { BelgeKarti } from '../BelgeKarti';
import { KasaIslemKarti } from '../KasaIslemKarti';
import { DevirPenceresi } from '../cari/CariDevirPenceresi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { stil as icmalStili } from '../hasta/icmal/icmalStil';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';

/**
 * EKSTRE - TEK EKRAN `/ekstre?tur=..&id=..` (mockup Ekranlar/ekstre_tek_ekran.html, kullanıcı
 * 23.10.2026: "müşteri/tedarikçi/kasa/banka/pos modülleri tek ekstre listesi kullanabilir mi" →
 * "genel ekstre mockup uygula").
 *
 * Beş hesap türü aynı ekranda: Cari (müşteri / tedarikçi), Kasa, Banka, POS, Kredi (+ kredi
 * kartı). Rakamlar SUNUCUDAN (EkstreUclari): para birimi başına dönem başı DEVİR, hareketler,
 * yürüyen bakiye. Ortak: hesap seçici, dönem, Liste / Aylık görünümü, çift tık → hareketi
 * üreten belge / kasa işlemi, A4 çıktı. Türe göre: cari'de Borç / Alacak ve B / A, vade sütunu,
 * Detay görünümü (belge kalemleri), Devir / Açılış penceresi; hesaplarda Giriş / Çıkış ve
 * karşı cari sütunu. Liste ve kartlardaki "Σ Ekstre" bu ekranı hesapla açar; sekme anahtarı
 * yol olduğu için açık Ekstre sekmesi yeniden kullanılır (yeni sekme açılmaz).
 */
type Gorunum = 'liste' | 'detay' | 'aylik';

const TUR_AD: Record<EkstreTuru, string> = { cari: '💼 Cari', kasa: '💵 Kasa', banka: '🏦 Banka', pos: '📟 POS', kredi: '📑 Kredi', kredikarti: '💳 Kredi Kartı' };
const KART_YOLU: Record<EkstreTuru, string> = { cari: '/cari', kasa: '/kasa-hesap', banka: '/banka-hesap', pos: '/pos-hesap', kredi: '/kredi-hesap', kredikarti: '/kredi-karti' };
const AYLAR = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
const v_adet = (v: Veri) => v.ozet.adet;
const yilBasi = () => `${new Date().getFullYear()}-01-01`;
const p = (n: number) => para.format(n);
const kisa = (n: number) => (Math.abs(n) >= 1e6 ? `${(n / 1e6).toLocaleString('tr-TR', { maximumFractionDigits: 1 })} M` : paraYaz(n));
/** Tarih; saati varsa (kasa / banka hareketi) yanına. */
const tarihSaat = (t: string) => {
  const saat = t.length >= 16 ? t.slice(11, 16) : '';
  return tarihKisa(t) + (saat && saat !== '00:00' ? ` ${saat}` : '');
};

/** Eski /cari-ekstre?tarafId= ve /hesap-ekstre?hesapId= yolları tek ekrana. */
export function EkstreYonlendir({ tur, alan }: { tur: 'cari' | 'hesap'; alan: string }) {
  const [arama] = useSearchParams();
  const q = new URLSearchParams(arama);
  const id = q.get(alan); q.delete(alan); q.delete('ad');
  q.set('tur', tur); if (id) q.set('id', id);
  return <Navigate to={`/ekstre?${q}`} replace />;
}

export function Ekstre() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici, yetki } = useOturum();
  const tur = (arama.get('tur') || 'cari') as EkstreTuru | 'hesap';
  const id = Number(arama.get('id') ?? 0);
  const bas = arama.get('bas') ?? yilBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const gor = (arama.get('gor') ?? 'liste') as Gorunum;
  const [veri, setVeri] = useState<Veri | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState('');
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [secili, setSecili] = useState<EkstreSatiri | null>(null);
  /** STANDART İŞARET SÜTUNU (kullanıcı: "grid'e standart check ekle"): işaretli satırlar. Satır tıkı tek
   *  işaret koyduğundan çıktı buna bakmaz - A4 hep dönemin tamamı. */
  const [isaretli, setIsaretli] = useState<Set<number>>(new Set());
  const [acikKasa, setAcikKasa] = useState<number | null>(null);
  const [acikBelge, setAcikBelge] = useState<number | null>(null);
  const [devirAcik, setDevirAcik] = useState(false);
  const [yenile, setYenile] = useState(0);
  /** KAYNAKTAN AÇILIŞ (kullanıcı 26.10.2026: "müşteri/ted/kasa/banka vb kaynaktan ekstre sekmesi açılırsa
   *  cari kasa banka vb buton seçimlerin olduğu satır görünmesin.. prompt aramadan ekstre diye açılırsa seçimler
   *  gelsin", "cari arama da kalksın"): ekran bir hesapla (id) açıldıysa tür düğmeleri ve hesap arama kutusu yok; menü / komut aramasından boş açılınca var.
   *  Açılıştaki adrese bakılır - sonradan hesap seçmek düğmeleri gizlemez. Aynı sekme hesapsız adrese
   *  geçerse (kullanıcı: "prompt tan ekstre girişi yaptım boş ekstre ekranı geldi ama ... seçim butonları
   *  gelmedi" - hesaplı açılmış genel Ekstre sekmesi komut aramasıyla yeniden kullanıldı) genel ekrana döner. */
  const [kaynaktan, setKaynaktan] = useState(() => id > 0);
  useEffect(() => { if (!id) setKaynaktan(false) }, [id]);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v) yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true });
  }, [arama, setArama]);

  useEffect(() => {
    setHata(''); setYukleniyor(true); setSecili(null); setIsaretli(new Set());
    const q = new URLSearchParams({ tur, bas, bit });
    if (id) q.set('id', String(id));
    api.ekstre(q).then(v => {
      setVeri(v);
      // 'hesap' türü sunucuda çözüldü - adres gerçek türü taşısın (sekme / yenileme).
      if (v.tur !== tur) degistir({ tur: v.tur });
    }).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tur, id, bas, bit, yenile]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const cari = veri ? veri.harf === 'C' : tur === 'cari';
  const gercekTur: EkstreTuru = veri?.tur ?? (tur === 'hesap' ? 'kasa' : tur);
  const h = veri?.hesap ?? null;
  const o = veri?.ozet;
  const etiket = (b: string, a: string) => (cari ? b : a);
  const bakiyeYaz = (n: number) => (cari ? `${p(Math.abs(n))} ${n > 0.005 ? 'B' : n < -0.005 ? 'A' : ''}`.trim() : p(n));

  /** SATIR TIKI (kullanıcı: "satır tıklayınca check işaretlensin, başka satır işaretlenince
   *  diğerleri kalksın"): tık = tek işaret; çoklu işaret yalnız kutucuklardan. */
  const satirSec = (s: EkstreSatiri) => { setSecili(s); setIsaretli(new Set([s.id])) };
  /** Satırı üreten kayıt: önce kasa işlemi, yoksa belge. */
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  /**
   * KAYIT KENDİ SEKMESİNDE (kullanıcı 27.10.2026: "ekstrede belge çift tıklayıp açılacaksa hemen yanda yeni
   * sekmede açılsın.. modal değil"): kasa işlemi /kasa-islem/<id>, belge türünün kart yolunda - sekme ekstrenin
   * sağına açılır (EkranSekmeleri). Sekmeler kapalıysa (eski görünüm) modal.
   */
  const kayitAc = (s: EkstreSatiri | null) => {
    if (!s) { mesaj('Önce bir satır seçin.'); return }
    if (!s.kasaIslemId && !s.belgeId) { mesaj('Bu satırın bağlı olduğu bir kayıt yok (devir / açılış).'); return }
    if (ekranSekmesi) {
      ekranSekmesi.kartaGit(s.kasaIslemId ? `/kasa-islem/${s.kasaIslemId}` : `${belgeTuruBilgisi(s.tur).liste}/${s.belgeId}`);
      return;
    }
    if (s.kasaIslemId) setAcikKasa(s.kasaIslemId);
    else setAcikBelge(s.belgeId);
  };
  const kutu = (b: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{b}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const gunFarki = (t: string | null | undefined) => (t ? Math.round((Date.now() - new Date(t).getTime()) / 864e5) : null);

  const konum = useLocation();
  const kartaGit = (y: string) => (ekranSekmesi ? ekranSekmesi.kartaGit(y) : git(y));
  // Sekmede açılan kayıt kaydedilince / silinince ekstre tazelenir (modal kapanışındaki tazelemenin yerine).
  useEffect(() => {
    const tazele = () => setYenile(x => x + 1);
    window.addEventListener(LISTE_TAZELE_OLAYI, tazele);
    return () => window.removeEventListener(LISTE_TAZELE_OLAYI, tazele);
  }, []);
  /**
   * BELGEYİ KOPYALA (kullanıcı 26.10.2026: "aksiyon menüsüne diğer altına Belgeyi Kopyala ekle.. eğer tek belge
   * seçili ise ve o belge içinde izlemli satır yoksa kopyala varsa uyar"): işaretli (yoksa seçili) TEK belge
   * satırı; lot / seri takipli kalem varsa kopyalanmaz - kopyada lot yeniden seçilmeli, aynı lot ikinci kez
   * düşülemez. Kopya yeni belge kartında KAYDEDİLMEMİŞ açılır (BelgeKarti kopyaId).
   */
  const belgeyiKopyala = async () => {
    const tum = veri?.paralar.flatMap(x => x.satirlar) ?? [];
    const sec = isaretli.size ? tum.filter(s => isaretli.has(s.id)) : secili ? [secili] : [];
    if (sec.length !== 1) { mesaj(sec.length ? c('Kopyalamak için tek bir belge seçin.') : c('Önce kopyalanacak belgeyi seçin.')); return }
    const s = sec[0];
    if (!s.belgeId || s.kasaIslemId) { mesaj(c('Seçili satır bir belge değil (kasa işlemi / devir) - kopyalanamaz.')); return }
    try {
      const y = await api.belgeOku(s.belgeId);
      const izlemli = (y.satirlar ?? []).filter(r => Number(r.izleme ?? 0) > 0
        || ((r.izlemler as unknown[] | undefined)?.length ?? 0) > 0);
      if (izlemli.length) {
        mesaj(c('Bu belgede lot / seri takipli kalem var, kopyalanamaz: {0}. Yeni belgeyi bu kalemlerin lotunu seçerek girin.')
          .replace('{0}', izlemli.map(r => String(r.stokAdi || r.stokKodu || '')).filter(Boolean).join(', ')));
        return;
      }
      // Cari de adreste: kart açılırken carisiz kalıp cari arama penceresini açmasın.
      kartaGit(`/belge/yeni?kopya=${s.belgeId}${h ? `&tarafId=${h.id}&tarafUnvan=${encodeURIComponent(h.ad)}` : ''}`);
    } catch (h) { mesaj(hataMetni(h)) }
  };
  // SEKME BAŞLIĞI HESABIN ADI (kullanıcı 26.10.2026: "ekstre sekme başlıkta cari/kasa... adın ilk 2 kelimesi").
  const sekmeBasligi = h ? sekmeAdi(h.ad) : '';
  const baslikYolu = baslikAnahtari(konum);
  useEffect(() => { if (ekranSekmesi && sekmeBasligi) ekranSekmesi.baslik(sekmeBasligi, baslikYolu) }, [ekranSekmesi, sekmeBasligi, baslikYolu]);
  const turler = veri?.turler ?? [];
  const gorunumler: [Gorunum, string][] = [['liste', '☰ Liste'], ...(cari ? [['detay', '🧾 Detay'] as [Gorunum, string]] : []), ['aylik', '📆 Aylık']];

  return (
    <div className="hi ek">
      <style>{icmalStili + EKSTRE_STILI}</style>
      <div className="sayfabas">
        {/* BAŞLIK (kullanıcı 26.10.2026: "Ekstre — Cari yerine Ekstre / ikon Cari"): tür ikonuyla.
            ARAÇ ÇUBUĞU BAŞLIK SATIRINDA, STANDART LİSTE DÜĞMESİ BOYUNDA (kullanıcı 26.10.2026: "ekstrede üstte kart
            aç/belge aç vb butonlar diğer listedeki butonlardan daha mı büyük", "standart listeler deseni büyüklüğünde
            yap sonra da 1.sıraya al"): .d düğmeler, sağda - Kartı Aç · Belge / İşlem Aç · türe özgü · Çıktı · Kapat.
            HESAP ADI altta (kullanıcı: "cari adı bir alt satırda olsun"). */}
        <div className="basrow gg-bas"><h1><EkstreIkon boyut={20} /> {c('Ekstre')} / {TUR_AD[gercekTur]}</h1><span className="yol">Finans › {c('Ekstre')}</span>
          <div className="sag ek-arac">
            {h && <button type="button" className="d" onClick={() => git(`${KART_YOLU[gercekTur]}/${h.id}`)}>🗂 {c('Kartı Aç')}</button>}
            <button type="button" className="d" disabled={!secili} title={secili ? 'Seçili satırın belgesi / kasa işlemi' : 'Önce bir satır seçin'}
                    onClick={() => kayitAc(secili)}>📂 {c('Belge / İşlem Aç')}</button>
            {/* AKSİYON (kullanıcı 26.10.2026, Delphi cari listesi Aksiyon menüsü): caride belge / tahsilat / ödeme /
                açılış fişi tek menüde, müşteri / tedarikçiye göre - Devir / Açılış düğmesi bu menüye taşındı.
                Kasa / banka / POS hesabında düğme yerinde kalır. */}
            {h && gercekTur === 'cari' && (
              <CariAksiyonMenusu id={h.id} ad={h.ad} git={kartaGit}
                                 onAcilis={() => setDevirAcik(true)} onKopyala={() => void belgeyiKopyala()} />)}
            {h && gercekTur !== 'cari' && yetki('finans.devir', 'gor') && (
              <button type="button" className="d" onClick={() => setDevirAcik(true)}>↪️ {c('Devir / Açılış')}</button>)}
            {cari && yetki('finans.cari_icmali', 'gor') && <button type="button" className="d" onClick={() => git('/cari-icmali')}>📒 {c('Cari İcmali')}</button>}
            {gercekTur === 'kasa' && yetki('kasa.gun_sonu', 'gor') && <button type="button" className="d" onClick={() => git('/kasa-gun-sonu')}>🧮 {c('Gün Sonu')}</button>}
            {gercekTur === 'banka' && yetki('banka.hareket', 'gor') && <button type="button" className="d" onClick={() => git(`/banka-hareket${h ? `?hesapId=${h.id}` : ''}`)}>🔗 {c('Banka Hareketleri')}</button>}
            <CiktiMenusu etiket={cari ? 'Cari Ekstre' : 'Hesap Ekstresi'} dosyaAdi={`Ekstre ${h?.ad ?? ''} ${bas} ${bit}`.trim()} devre={!veri || !h}>
              {veri && h && <EkstreA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
            </CiktiMenusu>
            {/* KAPAT (kullanıcı 24.10.2026: "ekstre sekmeye kapat butonu ekle"): kartlardaki gibi en sağda;
                ekranın kendi sekmesini kapatır (sekme yoksa başlangıca döner). */}
            <button type="button" className="d" onClick={() => ekranSekmesi ? ekranSekmesi.kapat() : git('/panel')}>✖ {c('Kapat')}</button>
          </div>
        </div>
        {/* CARİ BİLGİ BANDI (26.10.2026): carinin avatarlı özeti; bakiye kutularda olduğundan bantta yok.
            Kasa / banka / POS hesabında yalnız ad. */}
        {h && (gercekTur === 'cari'
          ? <div className="ek-bant"><CariBilgiBandi id={h.id} tazele={yenile} bakiyesiz /></div>
          : <div className="ek-hesap-ad">{h.ad}</div>)}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {/* BAKİYE ROZETİ KALKTI (kullanıcı 26.10.2026: "Bakiye TL .. şerit var.. bunlar zaten kutularda var..
          kaldıralım") - Bakiye kutusu aynı bilgiyi (yerel + dövizler) veriyor. Kaynaktan açılışta şerit boş kalır, yok. */}
      {!kaynaktan && <div className="hi-serit">
        <div className="ek-seg">
          {(Object.keys(TUR_AD) as EkstreTuru[]).filter(t => turler.length === 0 ? t === gercekTur : turler.includes(t)).map(t => (
            <button key={t} type="button" className={t === gercekTur ? 'on' : ''}
                    onClick={() => { if (t !== gercekTur) { const q = new URLSearchParams(arama); q.set('tur', t); q.delete('id'); if (gor === 'detay') q.delete('gor'); setArama(q, { replace: true }) } }}>
              {TUR_AD[t]}</button>
          ))}
        </div>
        <HesapSecici tur={gercekTur} secili={h ? { id: h.id, ad: h.ad, altBilgi: h.altBilgi, kod: h.kod } : null}
                     onSec={s => degistir({ id: String(s.id) })} />
      </div>}

      {/* İKİNCİ ŞERİT (kullanıcı: "dönem ve liste/aylık butonlar bir alt satıra"): dönem + görünüm. */}
      <div className="hi-serit ek-serit2">
        <div className="ek-seg">
          {gorunumler.map(([k, ad]) => (
            <button key={k} type="button" className={gor === k ? 'on' : ''} onClick={() => degistir({ gor: k === 'liste' ? '' : k })}>{ad}</button>))}
        </div>
                <div className="sel">📅 {c('Dönem')}:
          <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value })} /> –
          <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
          <button type="button" className="ek-mini" onClick={() => degistir({ bas: yilBasi(), bit: bugunYerel() })}>Bu yıl</button>
        </div>
<span className="sp" />
        {yukleniyor && <span className="ki-soluk">yükleniyor…</span>}
        {veri && h && <span className="ki-soluk">{v_adet(veri)} hareket · {tarihKisa(bas)} – {tarihKisa(bit)}</span>}
      </div>

      {veri && !h && !hata && (
        <div className="ek-bos">{c('Ekstresi görülecek')} {TUR_AD[gercekTur].replace(/^\S+\s/, '').toLocaleLowerCase('tr-TR')} {c('hesabını yukarıdaki kutudan seçin.')}</div>)}

      {veri && h && o && (<>
        <div className="hi-ozet">
          {kutu(`Devir (${tarihKisa(bas)})`, bakiyeYaz(o.devirYerel), `${veri.yerel}${cari ? ' · B / A' : ''}`)}
          {kutu(`Dönem ${etiket('Borç', 'Giriş')}`, kisa(o.borcYerel), `${o.borcAdet} hareket`, cari ? '' : 'iyi')}
          {kutu(`Dönem ${etiket('Alacak', 'Çıkış')}`, kisa(o.alacakYerel), `${o.alacakAdet} hareket`, cari ? 'iyi' : 'teh')}
          {kutu('Bakiye', bakiyeYaz(o.bakiyeYerel),
            veri.paralar.filter(x => !x.yerelMi && Math.abs(x.bakiye) > 0.005).map(x => `${x.doviz} ${bakiyeYaz(x.bakiye)}`).join(' · ') || veri.yerel,
            cari ? (o.bakiyeYerel > 0.005 ? 'teh' : o.bakiyeYerel < -0.005 ? 'iyi' : '') : (o.bakiyeYerel < -0.005 ? 'teh' : ''))}
          {cari
            ? kutu('Vadesi Geçen', kisa(h.vadesiGecen ?? 0), (h.vadesiGecen ?? 0) > 0.005 ? 'bugün itibarıyla (FIFO)' : 'yok', (h.vadesiGecen ?? 0) > 0.005 ? 'uy' : '')
            : kutu('Açılış Bakiyesi', p(h.acilisBakiye ?? 0), h.acilisTarihi ? tarihKisa(h.acilisTarihi) : 'hesap kartı')}
          {kutu(etiket('Son Tahsilat', 'Son Çıkış'), o.sonAlacak ? tarihKisa(o.sonAlacak) : '—', o.sonAlacak ? `${kisa(o.sonAlacakTutar)} · ${o.sonAlacakTur}` : 'dönemde yok')}
          {kutu(etiket('Son Borçlanma', 'Son Giriş'), o.sonBorc ? tarihKisa(o.sonBorc) : '—', o.sonBorc ? `${kisa(o.sonBorcTutar)} · ${o.sonBorcTur}` : 'dönemde yok')}
          {cari
            ? kutu('Risk', (h.riskLimiti ?? 0) > 0 ? `%${Math.round(Math.max(h.toplamBakiye ?? 0, 0) * 100 / (h.riskLimiti ?? 1))}` : 'limitsiz',
                   (h.riskLimiti ?? 0) > 0 ? `limit ${kisa(h.riskLimiti ?? 0)} · vade ${h.vadeGun ?? 0} gün` : `vade ${h.vadeGun ?? 0} gün`,
                   (h.riskLimiti ?? 0) > 0 && (h.toplamBakiye ?? 0) > (h.riskLimiti ?? 0) ? 'teh' : '')
            : kutu('Son Hareket', o.sonHareket ? tarihKisa(o.sonHareket) : '—', o.sonHareket ? `${gunFarki(o.sonHareket)} gün önce` : 'dönemde yok')}
        </div>

        <div className="hi-govde">
          <div className="ek-grup">
            {/* BAŞLIK SATIRI KALKTI (kullanıcı 26.10.2026: "gridin en üst kısmında "Cari Hesap Ekstresi" satırı var
                o da gereksiz") - ekran başlığı ve çıktı aynı adı taşıyor. */}
            {gor === 'aylik'
              ? <AylikTablo v={veri} cari={cari} bakiyeYaz={bakiyeYaz} onAy={(b, s) => degistir({ bas: b, bit: s, gor: '' })} />
              : <EkstreTablosu v={veri} cari={cari} detay={gor === 'detay'} bakiyeYaz={bakiyeYaz}
                               secili={secili} onSec={satirSec} onAc={kayitAc} isaretli={isaretli} setIsaretli={setIsaretli} />}
          </div>
        </div>
      </>)}

      {acikKasa !== null && <KasaIslemKarti kayitIdProp={acikKasa} onKapat={() => { setAcikKasa(null); setYenile(t => t + 1) }} />}
      {acikBelge !== null && <BelgeKarti id={acikBelge} onKapat={() => setAcikBelge(null)} />}
      {devirAcik && h && (
        <DevirPenceresi tur={gercekTur} id={h.id} onKapat={() => setDevirAcik(false)}
                        onKaydedildi={() => { setDevirAcik(false); setYenile(t => t + 1) }} />)}
    </div>
  );
}

/**
 * Hesap seçici. CARİ: uygulamanın jenerik cari arama modalı (TarafArama - kullanıcı 23.10.2026:
 * "ekstrede cari arama jenerik cari arama modal olsun"; genel kural: cari seçimi her yerde aynı
 * ekrandan). Kasa / banka / POS / kredi: hesaplar az - yazdıkça süzülen açılır liste, ok + Enter.
 */
export function HesapSecici({ tur, secili, onSec }: {
  tur: EkstreTuru; secili: { id: number; ad: string; altBilgi: string; kod: string } | null;
  onSec(s: EkstreHesapSecimi): void;
}) {
  const [acik, setAcik] = useState(false);
  if (tur === 'cari') {
    return (
      <div className="ek-sec">
        <div className="sel ek-sec-kutu" onClick={() => setAcik(true)} title="Cari ara (müşteri / tedarikçi)">🔍
          {secili ? <><b>{secili.ad}</b> <span className="bo-rz mavi">{[secili.kod, secili.altBilgi].filter(Boolean).join(' · ')}</span></>
                  : <span className="ki-soluk">{c('Cari seçin…')}</span>}
          <span className="ok">…</span>
        </div>
        {/* kartYok (kullanıcı: "jenerik aramada yeni ve düzenle butonları görünmesin"): burada yalnız seçim. */}
        <TarafArama acik={acik} kaynaklar={['cari']} kartYok yerTutucu="Müşteri / tedarikçi ara…"
                    onKapat={() => setAcik(false)}
                    onSec={sec => { setAcik(false); onSec({ id: sec.id, ad: sec.unvan, kod: '', altBilgi: '', durum: 1 }) }} />
      </div>
    );
  }
  return <HesapAcilirListe tur={tur} secili={secili} onSec={onSec} />;
}

function HesapAcilirListe({ tur, secili, onSec }: {
  tur: EkstreTuru; secili: { id: number; ad: string; altBilgi: string; kod: string } | null;
  onSec(s: EkstreHesapSecimi): void;
}) {
  const [acik, setAcik] = useState(false);
  const [metin, setMetin] = useState('');
  const [liste, setListe] = useState<EkstreHesapSecimi[]>([]);
  const [imlec, setImlec] = useState(0);
  const kutu = useRef<HTMLDivElement | null>(null);
  useEffect(() => {
    if (!acik) return;
    const z = setTimeout(() => {
      api.ekstreHesaplar(tur, metin).then(l => { setListe(l); setImlec(0) }).catch(() => setListe([]));
    }, 200);
    return () => clearTimeout(z);
  }, [acik, tur, metin]);
  useEffect(() => {
    if (!acik) return;
    const kapat = (e: MouseEvent) => { if (!kutu.current?.contains(e.target as Node)) setAcik(false) };
    document.addEventListener('mousedown', kapat);
    return () => document.removeEventListener('mousedown', kapat);
  }, [acik]);
  const sec = (s: EkstreHesapSecimi) => { onSec(s); setAcik(false); setMetin('') };
  return (
    <div className="ek-sec" ref={kutu}>
      <div className="sel ek-sec-kutu" onClick={() => setAcik(true)}>🔍
        {acik
          ? <input autoFocus value={metin} placeholder="hesap adı…"
                   onChange={e => setMetin(e.target.value)}
                   onKeyDown={e => {
                     if (e.key === 'ArrowDown') { setImlec(i => Math.min(i + 1, liste.length - 1)); e.preventDefault() }
                     else if (e.key === 'ArrowUp') { setImlec(i => Math.max(i - 1, 0)); e.preventDefault() }
                     else if (e.key === 'Enter' && liste[imlec]) sec(liste[imlec]);
                     else if (e.key === 'Escape') setAcik(false);
                   }} />
          : secili ? <><b>{secili.ad}</b> <span className="bo-rz mavi">{[secili.kod, secili.altBilgi].filter(Boolean).join(' · ')}</span></>
                   : <span className="ki-soluk">{c('Hesap seçin…')}</span>}
        <span className="ok">▾</span>
      </div>
      {acik && (
        <div className="ek-sec-liste">
          {liste.length === 0 && <div className="ek-sec-bos">{metin ? 'Eşleşen yok.' : 'Yükleniyor…'}</div>}
          {liste.map((s, i) => (
            <div key={s.id} className={'ek-sec-satir' + (i === imlec ? ' on' : '') + (s.durum !== 1 ? ' pasif' : '')}
                 onMouseEnter={() => setImlec(i)} onClick={() => sec(s)}>
              <b>{s.ad}</b><span>{[s.kod, s.altBilgi].filter(Boolean).join(' · ')}{s.durum !== 1 ? ' · pasif' : ''}</span>
            </div>))}
        </div>)}
    </div>
  );
}

/** Belgenin KENDİ hareketi mi (tahsilat değil) - kalemleri o satırın altına gelir. */
const belgeHareketi = (s: EkstreSatiri) => s.belgeId > 0 && !s.kasaIslemId;
const sayi = (v: unknown) => Number(v ?? 0) || 0;

/** Para birimi gruplu hareket tablosu: devir satırı, yürüyen bakiye, grup toplamı, genel toplam (yerel). */
function EkstreTablosu({ v, cari, detay, bakiyeYaz, secili, onSec, onAc, isaretli, setIsaretli }: {
  v: Veri; cari: boolean; detay: boolean; bakiyeYaz(n: number): string;
  secili: EkstreSatiri | null; onSec(s: EkstreSatiri): void; onAc(s: EkstreSatiri): void;
  isaretli: Set<number>; setIsaretli(s: Set<number>): void;
}) {
  const tumIdler = v.paralar.flatMap(x => x.satirlar.map(s => s.id));
  const hepsi = tumIdler.length > 0 && tumIdler.every(id => isaretli.has(id));
  const degistir = (id: number) => { const y = new Set(isaretli); if (y.has(id)) y.delete(id); else y.add(id); setIsaretli(y) };
  // DETAY (cari): belge hareketinin kalemleri belge ucundan, 8'erli, en çok 200 belge.
  const [kalemler, setKalemler] = useState<Record<number, Record<string, unknown>[]>>({});
  useEffect(() => {
    setKalemler({});
    if (!detay) return;
    const idler = [...new Set(v.paralar.flatMap(x => x.satirlar).filter(belgeHareketi).map(s => s.belgeId))].slice(0, 200);
    let iptal = false;
    void (async () => {
      for (let i = 0; i < idler.length; i += 8) {
        const parca = await Promise.all(idler.slice(i, i + 8).map(id =>
          api.belgeOku(id).then(y => [id, y.satirlar ?? []] as const).catch(() => [id, []] as const)));
        if (iptal) return;
        setKalemler(k => ({ ...k, ...Object.fromEntries(parca) }));
      }
    })();
    return () => { iptal = true };
  }, [v, detay]);

  const n = cari ? 10 : 9;
  const bos = v.paralar.every(x => x.satirlar.length === 0);
  return (
    <div className="ek-dg">
      <table className="hi-tablo ek-tablo">
        <thead><tr>
          <th className="cbk"><input type="checkbox" className="grid-cb" checked={hepsi} title="Tümünü işaretle"
                                     onChange={() => setIsaretli(hepsi ? new Set() : new Set(tumIdler))} /></th>
          <th>Tarih</th><th>{cari ? 'Belge No' : 'Makbuz / Belge'}</th><th>İşlem</th>
          <th>{cari ? 'Hesap' : 'Cari / Karşı Hesap'}</th><th>Açıklama</th>
          {cari && <th>Vade</th>}
          <th className="sag">{cari ? 'Borç' : 'Giriş'}</th><th className="sag">{cari ? 'Alacak' : 'Çıkış'}</th><th className="sag">Bakiye</th>
        </tr></thead>
        <tbody>
          {bos && <tr><td colSpan={n} className="ek-bos-satir">Bu dönemde hareket yok{v.paralar.length > 0 ? ' - devir bakiyesi aşağıda' : ''}.</td></tr>}
          {v.paralar.map(x => (
            <ParaGrubu key={x.doviz} x={x} cari={cari} n={n} bakiyeYaz={bakiyeYaz} detay={detay} kalemler={kalemler}
                       bas={v.bas} secili={secili} onSec={onSec} onAc={onAc} isaretli={isaretli} degistir={degistir} />))}
          {v.paralar.length > 1 && (
            <tr className="ek-genel">
              <td colSpan={n - 3}>GENEL TOPLAM ({v.yerel} karşılığı, hareket kuru)</td>
              <td className="sag">{p(v.ozet.borcYerel)}</td><td className="sag">{p(v.ozet.alacakYerel)}</td>
              <td className={'sag' + (cari && v.ozet.bakiyeYerel > 0.005 ? ' kir' : '')}>{bakiyeYaz(v.ozet.bakiyeYerel)}</td>
            </tr>)}
        </tbody>
      </table>
    </div>
  );
}

function ParaGrubu({ x, cari, n, bakiyeYaz, detay, kalemler, bas, secili, onSec, onAc, isaretli, degistir }: {
  x: EkstreParasi; cari: boolean; n: number; bakiyeYaz(n: number): string; detay: boolean;
  kalemler: Record<number, Record<string, unknown>[]>; bas: string;
  secili: EkstreSatiri | null; onSec(s: EkstreSatiri): void; onAc(s: EkstreSatiri): void;
  isaretli: Set<number>; degistir(id: number): void;
}) {
  const bakiyeSinif = (b: number) => 'sag' + (cari && b > 0.005 ? ' kir' : '');
  return (
    <>
      <tr className="ek-para"><td colSpan={n}>{x.doviz} · {x.adet} hareket</td></tr>
      <tr className="ek-devir">
        <td className="cbk" /><td>{tarihKisa(bas)}</td><td /><td>Devir</td><td /><td colSpan={cari ? 2 : 1}>Dönem başı bakiye</td>
        <td /><td /><td className={bakiyeSinif(x.devir)}>{bakiyeYaz(x.devir)}</td>
      </tr>
      {x.satirlar.map(s => {
        const k = detay && belgeHareketi(s) ? kalemler[s.belgeId] : undefined;
        return [
          <tr key={s.id} className={'ek-satir' + (secili?.id === s.id ? ' secili' : '') + (s.bakiyeDahil ? '' : ' haric')}
              onClick={() => onSec(s)} onDoubleClick={() => onAc(s)} title={s.bakiyeDahil ? 'Çift tık: kaydı aç' : 'Bakiyeye dahil değil (plan / bilgi satırı)'}>
            <td className="cbk"><input type="checkbox" className="grid-cb" checked={isaretli.has(s.id)}
                                       onClick={e => e.stopPropagation()} onChange={() => degistir(s.id)} /></td>
            <td>{tarihSaat(s.tarih)}</td><td>{s.belgeNo || s.islemNo}</td><td>{s.turAdi}</td><td className="ek-karsi">{s.karsi}</td>
            <td className="ek-acik">{s.aciklama}</td>
            {cari && <td>{s.vade ? tarihKisa(s.vade) : ''}</td>}
            <td className="sag">{s.borc ? p(s.borc) : ''}</td><td className="sag">{s.alacak ? p(s.alacak) : ''}</td>
            <td className={bakiyeSinif(s.bakiye)}>{bakiyeYaz(s.bakiye)}</td>
          </tr>,
          ...(detay && belgeHareketi(s) && !k
            ? [<tr key={`y${s.id}`} className="ek-kalem"><td /><td /><td /><td colSpan={n - 3} className="soluk">kalemler yükleniyor…</td></tr>] : []),
          ...(k ?? []).map((r, j) => (
            <tr key={`k${s.id}-${j}`} className="ek-kalem">
              <td /><td /><td className="soluk">{String(r.stokKodu ?? '')}</td>
              <td colSpan={2}>↳ {String(r.stokAdi || r.hizmetAdi || r.masrafAdi || r.aciklama || '')}</td>
              <td className="soluk">{sayi(r.miktar).toLocaleString('tr-TR')} × {p(sayi(r.birimFiyatKdvli ?? r.birimFiyat))}{r.kdv != null ? ` · KDV %${sayi(r.kdv)}` : ''}</td>
              {cari && <td />}
              <td className="sag soluk">{p(Math.round(sayi(r.tutar) * (1 + sayi(r.kdv) / 100) * 100) / 100)}</td><td /><td />
            </tr>)),
        ];
      })}
      <tr className="ek-ara">
        <td colSpan={n - 3}>{x.doviz} toplamı</td>
        <td className="sag">{p(x.borc)}</td><td className="sag">{p(x.alacak)}</td>
        <td className={bakiyeSinif(x.bakiye)}>{bakiyeYaz(x.bakiye)}</td>
      </tr>
    </>
  );
}

/** AYLIK: para birimi başına ay satırı - ay başı, borç / alacak (giriş / çıkış), net, ay sonu, hareket, değişim çubuğu. */
function AylikTablo({ v, cari, bakiyeYaz, onAy }: { v: Veri; cari: boolean; bakiyeYaz(n: number): string; onAy(bas: string, bit: string): void }) {
  const aylar = useMemo(() => {
    const [by, bm] = v.bas.slice(0, 7).split('-').map(Number);
    const [sy, sm] = v.bit.slice(0, 7).split('-').map(Number);
    const l: { y: number; m: number }[] = [];
    for (let y = by, m = bm; y < sy || (y === sy && m <= sm); m++) { if (m > 12) { m = 1; y++ } l.push({ y, m }) }
    return l;
  }, [v.bas, v.bit]);
  const sonGun = (y: number, m: number) => new Date(y, m, 0).getDate();
  return (
    <div className="ek-dg">
      <table className="hi-tablo ek-tablo">
        <thead><tr><th>Ay</th><th className="sag">Ay Başı</th><th className="sag">{cari ? 'Borç' : 'Giriş'}</th><th className="sag">{cari ? 'Alacak' : 'Çıkış'}</th>
          <th className="sag">Net</th><th className="sag">Ay Sonu</th><th className="sag">Hareket</th><th>Değişim</th></tr></thead>
        <tbody>
          {v.paralar.map(x => {
            const toplam = aylar.map(a => {
              const s = x.satirlar.filter(r => r.bakiyeDahil && Number(r.tarih.slice(0, 4)) === a.y && Number(r.tarih.slice(5, 7)) === a.m);
              return { ...a, borc: s.reduce((t, r) => t + r.borc, 0), alacak: s.reduce((t, r) => t + r.alacak, 0), adet: s.length };
            });
            const enb = Math.max(...toplam.map(t => Math.abs(t.borc - t.alacak)), 1);
            let bak = x.devir;
            return [
              <tr key={x.doviz} className="ek-para"><td colSpan={8}>{x.doviz}</td></tr>,
              <tr key={x.doviz + 'd'} className="ek-devir"><td>Devir ({tarihKisa(v.bas)})</td><td colSpan={4} /><td className="sag">{bakiyeYaz(x.devir)}</td><td colSpan={2} /></tr>,
              ...toplam.map(t => {
                const bas = bak; const net = t.borc - t.alacak; bak += net;
                const g = Math.round(Math.abs(net) / enb * 100);
                const ay = `${t.y}-${String(t.m).padStart(2, '0')}`;
                return (
                  <tr key={x.doviz + ay} className="ek-satir" title="Tıkla: bu ayın hareketleri"
                      onClick={() => onAy(ay + '-01', `${ay}-${String(sonGun(t.y, t.m)).padStart(2, '0')}`)}>
                    <td>{AYLAR[t.m - 1]} {t.y}</td><td className="sag">{bakiyeYaz(bas)}</td>
                    <td className="sag">{t.borc ? p(t.borc) : '—'}</td><td className="sag">{t.alacak ? p(t.alacak) : '—'}</td>
                    <td className={'sag' + (cari && net > 0.005 ? ' kir' : '')}>{net ? (net > 0 ? '+' : '−') + p(Math.abs(net)) : '—'}</td>
                    <td className="sag"><b>{bakiyeYaz(bak)}</b></td><td className="sag">{t.adet || '—'}</td>
                    <td><span className="ek-cubuk"><i className={net >= 0 ? 'art' : 'az'} style={{ width: `${g}%` }} /></span></td>
                  </tr>);
              }),
              <tr key={x.doviz + 't'} className="ek-ara"><td>{x.doviz} toplamı</td><td className="sag">{bakiyeYaz(x.devir)}</td>
                <td className="sag">{p(x.borc)}</td><td className="sag">{p(x.alacak)}</td>
                <td className="sag">{(x.borc - x.alacak >= 0 ? '+' : '−') + p(Math.abs(x.borc - x.alacak))}</td>
                <td className="sag">{bakiyeYaz(x.bakiye)}</td><td className="sag">{x.adet}</td><td /></tr>,
            ];
          })}
        </tbody>
      </table>
    </div>
  );
}

/** A4: para birimi başına hareketler, devir satırı, borç / alacak toplamı, kapanış bakiyesi. */
function EkstreA4({ v, antet, duzenleyen }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string }) {
  const cari = v.harf === 'C';
  const h = v.hesap!;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>{cari ? 'CARİ HESAP EKSTRESİ' : 'HESAP EKSTRESİ'}</h3>
      <div className="a4-hasta">
        <span>{cari ? 'Cari' : 'Hesap'}: <b>{h.ad}</b> {h.kod ? `(${h.kod})` : ''}</span>
        <span>Dönem: {tarihKisa(v.bas)} - {tarihKisa(v.bit)}</span>
        <span>{h.altBilgi}</span>
        <span>Hareket: {v.ozet.adet}</span>
      </div>
      {v.paralar.map(x => (
        <div key={x.doviz}>
          {v.paralar.length > 1 && <h4 style={{ margin: '8px 0 4px' }}>{x.doviz}</h4>}
          <table className="a4-t ek-a4t">
            <thead><tr><th>Tarih</th><th>Belge No</th><th>İşlem</th><th>Açıklama</th>
              <th>{cari ? 'Borç' : 'Giriş'}</th><th>{cari ? 'Alacak' : 'Çıkış'}</th><th>Bakiye</th></tr></thead>
            <tbody>
              <tr><td>{tarihKisa(v.bas)}</td><td /><td>Devir</td><td>Dönem başı bakiye</td><td /><td /><td>{p(x.devir)}</td></tr>
              {x.satirlar.map(s => (
                <tr key={s.id}>
                  <td>{tarihKisa(s.tarih)}</td><td>{s.belgeNo || s.islemNo}</td><td>{s.turAdi}</td>
                  <td>{[s.karsi, s.aciklama].filter(Boolean).join(' · ')}</td>
                  <td>{s.borc ? p(s.borc) : ''}</td><td>{s.alacak ? p(s.alacak) : ''}</td><td>{p(s.bakiye)}</td>
                </tr>))}
            </tbody>
          </table>
          <table className="a4-toplam"><tbody>
            <tr><td>Devir ({x.doviz})</td><td>{p(x.devir)}</td></tr>
            <tr><td>{cari ? 'Borç' : 'Giriş'} toplamı ({x.doviz})</td><td>{p(x.borc)}</td></tr>
            <tr><td>{cari ? 'Alacak' : 'Çıkış'} toplamı ({x.doviz})</td><td>{p(x.alacak)}</td></tr>
            <tr className="kalan"><td>KAPANIŞ BAKİYESİ ({x.doviz})</td><td>{p(x.bakiye)}{cari ? (x.bakiye > 0.005 ? ' (B)' : x.bakiye < -0.005 ? ' (A)' : '') : ''}</td></tr>
          </tbody></table>
        </div>))}
      <p className="a4-not">{cari ? 'Borç bakiyesi (B): cari bize borçlu; alacak bakiyesi (A): biz cariye borçluyuz. ' : ''}Devir, dönem öncesi hareketlerin toplamıdır. Bu belge fatura yerine geçmez.</p>
    </div>
  );
}

const EKSTRE_STILI = `
/* OVAL (kullanıcı: "dönem ve seçim editleri de oval olsun"): şeritteki kutular tür / görünüm seçicisiyle aynı yuvarlaklıkta. */
.ek .ek-bant { margin-top: 6px }
.ek .ek-bant .cbb { margin-bottom: 4px }
.ek .ek-hesap-ad { margin:4px 0 8px 29px; font-size:15px; font-weight:600; color:var(--yazi2,#2c4a6b); }
.ek .ek-arac .cm-dugme { display:inline-flex; align-items:center; gap:5px; height:25px; padding:0 10px; border-radius:3px;
  border:1px solid var(--cizgi); background:linear-gradient(var(--dug1), var(--dug2)); color:var(--yazi); font-size:11.5px; cursor:pointer; }
.ek .ek-arac .cm-dugme:disabled { opacity:.45; cursor:default; }
.ek .hi-serit .sel { border-radius:13px; padding-left:10px; padding-right:10px; }
.ek .hi-serit input[type=date] { border:1px solid var(--cizgi,#cdd6e0); border-radius:10px; font-size:12px; padding:1px 6px; }
/* Çıktı menüsü en sağda: açılır liste sağa hizalı, ekrandan taşmasın. */
.ek .hi-arac .cm .cm-menu { left:auto; right:0; }
.ek .hi-arac .cm .cm-menu .cm-alt { left:auto; right:100%; }
.ek-tablo th.cbk, .ek-tablo td.cbk { width:34px; padding:4px; text-align:center; white-space:nowrap; }
.ek-seg { display:flex; border:1px solid #cdd6e0; border-radius:13px; overflow:hidden; background:#fff; }
.ek-seg button { border:0; border-right:1px solid #e3e9f0; background:none; padding:4px 11px; font-size:12px; color:#4d5d6e; cursor:pointer; white-space:nowrap; }
.ek-seg button:last-child { border-right:0; }
.ek-seg button.on { background:linear-gradient(#4d8fd6,#2f6db3); color:#fff; font-weight:bold; }
.ek-serit2 { border-top:0; padding-top:4px; }
.ek-mini { border:1px solid var(--cizgi,#cdd6e0); border-radius:10px; background:#fff; font-size:10.5px; padding:0 7px; margin-left:4px; cursor:pointer; }
.ek-sec { position:relative; min-width:320px; }
.ek-sec-kutu { display:flex; align-items:center; gap:6px; padding:2px 10px; cursor:pointer; font-size:12px; border-radius:13px; }
.ek-sec-kutu input { border:0; outline:0; flex:1; font-size:12px; min-width:180px; }
.ek-sec-kutu .ok { margin-left:auto; color:#6b7a8b; }
.ek-sec-liste { position:absolute; z-index:30; top:100%; left:0; right:0; margin-top:2px; background:#fff; border:1px solid #cdd6e0; border-radius:8px;
  box-shadow:0 6px 18px rgba(0,0,0,.12); max-height:320px; overflow:auto; }
.ek-sec-satir { padding:5px 10px; font-size:12px; cursor:pointer; display:flex; justify-content:space-between; gap:8px; }
.ek-sec-satir span { color:#6b7a8b; font-size:11px; white-space:nowrap; }
.ek-sec-satir.on { background:#eef4fb; } .ek-sec-satir.pasif b { color:#9aa7b4; font-weight:normal; }
.ek-sec-bos { padding:8px 10px; font-size:12px; color:#6b7a8b; }
.ek-bos { margin:24px 12px; padding:22px; text-align:center; color:#6b7a8b; border:1px dashed #cdd6e0; border-radius:6px; background:#fff; }
/* GRID TAM OTURSUN (kullanıcı 26.10.2026: "gridin üst ve sol kısmında boşluk var. tam otursun"): gövde
   boşluğu ve grup çerçevesi yok - grid özet kutularının altına kenardan kenara. */
.ek .hi-govde { padding:0; }
.ek-grup { background:#fff; }
.ek-dg { overflow:auto; max-height:calc(100vh - 330px); }
.ek-tablo th { position:sticky; top:0; z-index:1; }
.ek-tablo tr.ek-para td { background:#f1f5fa; font-weight:bold; color:#2c4a6b; }
.ek-tablo tr.ek-devir td { background:#fbfcfe; font-style:italic; color:#4d5d6e; }
.ek-tablo tr.ek-ara td { background:#f7f9fc; font-weight:bold; border-top:1px solid #cdd6e0; }
.ek-tablo tr.ek-genel td { background:#eef2f7; font-weight:bold; border-top:2px solid #9fb3c8; }
.ek-tablo tr.ek-satir { cursor:pointer; } .ek-tablo tr.ek-satir:hover td { background:#f6f9fd; }
.ek-tablo tr.ek-satir.secili td { background:#e4eefb; }
.ek-tablo tr.ek-satir.haric td { color:#8a98a8; font-style:italic; }
.ek-tablo tr.ek-kalem td { font-size:11.5px; color:#4d5d6e; padding-top:2px; padding-bottom:2px; }
.ek-tablo .soluk { color:#8a98a8; }
.ek-tablo .ek-acik { max-width:320px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.ek-tablo .ek-karsi { max-width:220px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.ek-tablo .ek-bos-satir { text-align:center; color:#6b7a8b; padding:16px; }
.ek-cubuk { display:inline-block; width:110px; height:8px; background:#eef2f7; border-radius:4px; overflow:hidden; vertical-align:middle; }
.ek-cubuk i { display:block; height:100%; } .ek-cubuk i.art { background:#e0a33a; } .ek-cubuk i.az { background:#5cb87a; }
.a4-t.ek-a4t th:nth-child(3), .a4-t.ek-a4t td:nth-child(3), .a4-t.ek-a4t th:nth-child(4), .a4-t.ek-a4t td:nth-child(4) { text-align:left; }
.a4-t.ek-a4t th:nth-child(1) { width:11%; } .a4-t.ek-a4t th:nth-child(2) { width:14%; } .a4-t.ek-a4t th:nth-child(4) { width:26%; }
`;

export default Ekstre;
