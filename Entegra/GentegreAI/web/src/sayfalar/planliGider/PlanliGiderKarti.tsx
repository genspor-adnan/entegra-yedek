import { useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { hataAyristir, hataMetni } from '../../api/sozlesme';
import {
  planliGiderUclari as u,
  type PlanliGiderArtis, type PlanliGiderKartAlanlari, type PlanliGiderKarti as Veri, type PlanliGiderKategorisi,
} from '../../api/uclar/planliGider';
import { para, sayiOku } from '../../bilesenler/bicim';
import { DokumanGalerisi } from '../../bilesenler/DokumanGalerisi';
import { GenLookup } from '../../bilesenler/GenLookup';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { EkranSekmesiBaglami, LISTE_TAZELE_OLAYI, sekmeAdi } from '../../bilesenler/sekmeBaglami';
import { TarafSecici } from '../../bilesenler/TarafArama';
import { useOturum } from '../../kimlik/OturumBaglami';
import { DOVIZ_KODLARI } from '../belgeSabitleri';
import { DonemlerSekmesi, donemIslemiYap } from './PlanliGiderDonemler';
import { PLANLI_GIDER_KAYNAGI, odemeOlustur, usePlanliKartAc } from './PlanliGiderListesi';
import { TedarikciSecici, useKayitAdi } from './PlanliGiderSeciciler';
import {
  HAFTA_GUNLERI, HESAP_KAYNAKLARI, ODEME_YONTEMLERI, PERIYOTLAR, TATIL_KURALLARI, TUTAR_TURLERI,
  adi, ayKisa, ayUzun, bitisTuru, cubukBoyu, donemIslemleri, durumRozeti, gunT, kategoriOntanimi,
  odemeGunuMetni, odenecekDonem, tedarikciZorunlu, type BitisTuru,
} from './planliGiderOrtak';
import { PLANLI_GIDER_STILI } from './planliGiderStil';

/**
 * PLANLI GİDER KARTI (1177) - mockup Ekranlar/ERP/planli_gider_karti.html.
 *
 * Proje kart deseni: listeden "Yeni" / çift tık ile KENDİ EKRAN SEKMESİNDE açılır, Kaydet sekmeyi kapatır;
 * "Ödeme Oluştur"un açtığı kasa işlemi kartı yeni sekmede. Tanım kendiliğinden kayıt AÇMAZ.
 *
 * Özet şeridi, dönemler, önizlemeler (sonraki 12 tutar / 8 ödeme günü), uyarılar ve zaman çizgisi SUNUCUNUN
 * hesabıdır: ekran tutar / tarih türetmez. Düzenleme sonrası önizleme ancak KAYDEDİNCE güncellenir.
 * Kategori seçimi öntanımı yalnız boş alanlara yazar (karar 25.10.2026, `kategoriOntanimi`).
 */
type Sekme = 'genel' | 'tutar' | 'takvim' | 'eslesme' | 'donem' | 'belge' | 'gecmis';
const SEKMELER: [Sekme, string][] = [
  ['genel', 'Genel'], ['tutar', 'Tutar'], ['takvim', 'Takvim'], ['eslesme', 'Ödeme & Eşleştirme'],
  ['donem', 'Dönemler'], ['belge', 'Belgeler'], ['gecmis', 'Geçmiş'],
];
/** Alan -> sekme: kayıt doğrulama hatası gelince hatalı alanın sekmesine geçilir. */
const ALAN_SEKMESI: Record<string, Sekme> = {
  tutar: 'tutar', tutarTur: 'tutar', doviz: 'tutar', kdvOran: 'tutar', stopajOran: 'tutar', ortalamaDonem: 'tutar', hesapKaynak: 'tutar',
  periyot: 'takvim', odemeGunu: 'takvim', tatilKural: 'takvim', baslangic: 'takvim', bitis: 'takvim', donemSayisi: 'takvim', hatirlatmaGun: 'takvim',
  odemeHesapId: 'eslesme', odemeYontem: 'eslesme', karsiIban: 'eslesme', odemeAciklama: 'eslesme', eslesGun: 'eslesme', eslesYuzde: 'eslesme', eslesOtomatik: 'eslesme',
};
const KATEGORI_IKON: Record<string, string> = {
  kira: '🏬', enerji: '⚡', abonelik: '📡', vergi_sgk: '🏛️', sigorta: '🛡️', hizmet: '🤝', aidat: '🏢', diger: '🗓️',
};
const KDV_ORANLARI = [0, 1, 10, 20];
const STOPAJ_ORANLARI = [0, 10, 15, 20];
const HATIRLATMA_GUNLERI = [0, 1, 2, 3, 5, 7, 10, 15, 30];
const LOOKUP_KOD_AD = [{ ad: 'kod', baslik: 'Kod' }, { ad: 'ad', baslik: 'Ad', genis: true }];
const LOOKUP_HESAP = [{ ad: 'kod', baslik: 'Kod' }, { ad: 'ad', baslik: 'Hesap Adı', genis: true }, { ad: 'dovizCinsi', baslik: 'Döviz' }];
const AKTIF = { alan: 'durum', op: 'esit' as const, deger: 1 };
const tl = (n: number) => para.format(n);
const tam = (n: number) => n.toLocaleString('tr-TR', { maximumFractionDigits: 0 });
const sayiMetni = (n: number | null | undefined) => (n == null ? '' : n.toLocaleString('tr-TR', { maximumFractionDigits: 4, useGrouping: false }));
type Artis = Omit<PlanliGiderArtis, 'yeniKdvHaric' | 'uygulandi'> & Partial<Pick<PlanliGiderArtis, 'yeniKdvHaric' | 'uygulandi'>>;

/** Rota sayfası: `/planli-gider/:id` (`yeni` = yeni kayıt). */
export function PlanliGiderKarti() {
  const { id } = useParams();
  const kayitId = id === 'yeni' ? 0 : Number(id);
  if (!(kayitId >= 0) || Number.isNaN(kayitId)) return null;
  return <Kart key={kayitId} kayitId={kayitId} />;
}

function Kart({ kayitId }: { kayitId: number }) {
  const git = useNavigate();
  const konum = useLocation();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const kartAc = usePlanliKartAc();
  const { kullanici } = useOturum();
  const [veri, setVeri] = useState<Veri | null>(null);
  const [k, setK] = useState<PlanliGiderKartAlanlari | null>(null);
  const [artislar, setArtislar] = useState<Artis[]>([]);
  const ilk = useRef('');
  const [hata, setHata] = useState('');
  const [alanHata, setAlanHata] = useState<Record<string, string>>({});
  const [sekme, setSekme] = useState<Sekme>('genel');
  const [mesgul, setMesgul] = useState(false);
  const [seciliVade, setSeciliVade] = useState<string | null>(null);
  const [oneriIstegi, setOneriIstegi] = useState(0);
  /** Kullanıcının bu oturumda dokunduğu alanlar (kategori öntanımı bunları ezmez). */
  const dokunulan = useRef(new Set<string>());
  /** Seçicilerden gelen görünen adlar (sözleşmede yalnız id olan alanlar). */
  const [adlar, setAdlar] = useState<{ masrafMerkezi?: string; sorumlu?: string; odemeHesap?: string }>({});

  const imza = (kart: unknown, a: unknown) => JSON.stringify([kart, a]);
  const kirli = !!k && imza(k, artislar) !== ilk.current;
  const kirliRef = useRef(false);
  kirliRef.current = kirli;

  const yukle = useCallback(async (kartiDe: boolean) => {
    try {
      const v = await u.planliGiderKart(kayitId);
      setVeri(v);
      setHata('');
      if (kartiDe) {
        setK(v.kart);
        const a = v.artislar.map(x => ({ ...x }));
        setArtislar(a);
        ilk.current = imza(v.kart, a);
        dokunulan.current = new Set();
        setAdlar({});
      }
      setSeciliVade(s => s ?? odenecekDonem(v.donemler)?.vade ?? null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [kayitId]);
  useEffect(() => { void yukle(true) }, [yukle]);

  // SEKME BAŞLIĞI: kaydın adı (ilk 2 kelime), yeni kayıtta "Yeni Planlı Gider".
  useEffect(() => {
    ekranSekmesi?.baslik(kayitId ? sekmeAdi(veri?.kart.ad || 'Planlı Gider') : 'Yeni Planlı Gider', konum.pathname);
  }, [ekranSekmesi, konum.pathname, kayitId, veri?.kart.ad]);

  const kapat = useCallback(() => { if (ekranSekmesi) ekranSekmesi.kapat(); else git('/planli-gider') }, [ekranSekmesi, git]);
  const kapatIste = useCallback(async () => {
    if (kirliRef.current && !await onay('Kaydedilmemiş değişiklikler var. Kaydetmeden kapatılsın mı?')) return;
    kapat();
  }, [kapat]);
  // Sekmenin × / Alt+W'si kartın kendi Kapat'ını çağırır (kayıtsız değişiklik sorusu).
  useEffect(() => {
    if (!ekranSekmesi) return;
    ekranSekmesi.kapatmaIsleyicisi(() => { void kapatIste() }, () => kirliRef.current);
    return () => ekranSekmesi.kapatmaIsleyicisi(null);
  }, [ekranSekmesi, kapatIste]);

  const tazeleListe = () => window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: PLANLI_GIDER_KAYNAGI }));

  const yaz = <A extends keyof PlanliGiderKartAlanlari>(alan: A, deger: PlanliGiderKartAlanlari[A]) => {
    dokunulan.current.add(alan as string);
    setK(o => (o ? { ...o, [alan]: deger } : o));
    setAlanHata(h => { if (!h[alan as string]) return h; const y = { ...h }; delete y[alan as string]; return y });
  };
  const kategoriSec = (kat: PlanliGiderKategorisi | null) => {
    setK(o => (o ? { ...o, kategoriId: kat?.id ?? null, ...(kat ? kategoriOntanimi(o, kat, dokunulan.current) : {}) } : o));
  };

  const kaydet = async () => {
    if (!k) return;
    // ÖDENECEK YER ZORUNLU (kullanıcı 25.10.2026) - tek istisna Vergi / SGK kategorisi. Sunucu da doğrular.
    const katKod = veri?.kategoriler.find(x => x.id === k.kategoriId)?.kod;
    if (!k.tarafId && tedarikciZorunlu(katKod)) {
      setAlanHata({ tarafId: 'Ödenecek yer (tedarikçi) seçin.' }); setHata('Ödenecek yer (tedarikçi) seçilmeli.'); setSekme('genel'); return;
    }
    setMesgul(true); setHata(''); setAlanHata({});
    const govde = { kart: k, artislar: artislar.map(({ id, gecerlilik, tur, deger, aciklama }) => ({ id, gecerlilik, tur, deger, aciklama })) };
    try {
      if (kayitId) await u.planliGiderGuncelle(kayitId, govde);
      else await u.planliGiderEkle(govde);
      ilk.current = imza(k, artislar);
      kirliRef.current = false;
      tazeleListe();
      kapat();
    } catch (h) {
      const c = hataAyristir(h);
      if (c.cakisma) {
        // 409 (§ iyimser eşzamanlılık): başkası değiştirmiş - iki yol.
        const benim = await onay(`${c.mesaj}\n\nTamam: benim değişikliklerimi uygula · İptal: güncel hâli yükle (değişikliklerim bırakılır).`);
        if (benim) {
          // Güncel sürüm damgası alınır, kullanıcının değerleri kalır; bir sonraki Kaydet onunla gider.
          let surum = String(c.cakisma.guncel.surum ?? '');
          if (!surum) surum = (await u.planliGiderKart(kayitId)).kart.surum;
          setK(o => (o ? { ...o, surum } : o));
          setHata('Güncel sürüm alındı - değişikliklerinizi yazmak için yeniden Kaydet\'e basın.');
        } else await yukle(true);
      } else {
        setHata(c.mesaj);
        setAlanHata(c.alanlar);
        if (c.ilkAlan && ALAN_SEKMESI[c.ilkAlan]) setSekme(ALAN_SEKMESI[c.ilkAlan]);
        else if (c.ilkAlan) setSekme('genel');
      }
    } finally { setMesgul(false) }
  };

  const sil = async () => {
    if (!kayitId || !await onay(`"${k?.ad}" planlı gider tanımı silinsin mi? Eşleşmiş dönemi olan tanım silinmez - pasife alın.`, true)) return;
    setMesgul(true);
    try { await u.planliGiderSil(kayitId); tazeleListe(); kapat() } catch (h) { mesaj(hataMetni(h)) } finally { setMesgul(false) }
  };
  const islem = async (f: () => Promise<unknown>, tazele = true) => {
    setMesgul(true);
    try { await f(); if (tazele) await yukle(!kirliRef.current); tazeleListe() } catch (h) { mesaj(hataMetni(h)) } finally { setMesgul(false) }
  };

  if (!veri || !k) {
    return <div className="sahne"><style>{PLANLI_GIDER_STILI}</style>
      {hata ? <div className="hata-kutusu">{hata} <button type="button" className="d" onClick={kapat}>Kapat</button></div> : <div className="pg-soluk">yükleniyor…</div>}
    </div>;
  }

  const yazilabilir = kayitId ? veri.yetkiler.degistir : true;
  const kilit = !yazilabilir;
  const kat = veri.kategoriler.find(x => x.id === k.kategoriId) ?? null;
  const o = veri.ozet;
  const hedef = veri.donemler.find(d => d.vade === seciliVade) ?? odenecekDonem(veri.donemler);
  const hedefIzin = donemIslemleri(hedef ?? null);
  const sonrakiArtis = artislar.filter(a => !a.uygulandi).sort((a, b) => a.gecerlilik.localeCompare(b.gecerlilik))[0];
  const artisRozeti = sonrakiArtis ? `${ayKisa(sonrakiArtis.gecerlilik)} ${sonrakiArtis.gecerlilik.slice(0, 4)}: ${sonrakiArtis.tur === 1 ? `+%${sayiMetni(sonrakiArtis.deger)}` : tl(sonrakiArtis.deger)}` : '';
  const takvimMetni = `${adi(PERIYOTLAR, k.periyot)} · ${odemeGunuMetni(k.periyot, k.odemeGunu)} · tatilse ${adi(TATIL_KURALLARI, k.tatilKural).toLocaleLowerCase('tr')}`;
  const odemeOlusturHedef = (vade?: string) => islem(() => odemeOlustur(kayitId, kartAc, vade));
  const hizliDonem = (is: 'atla' | 'tutar') => hedef && islem(() => donemIslemiYap(kayitId, hedef, is, k.doviz));
  const cariEkstre = () => (k.tarafId ? kartAc(`/ekstre?tur=cari&id=${k.tarafId}`) : k.masrafId ? kartAc(`/masraf/${k.masrafId}`) : undefined);

  return (
    <div className="sahne">
      <style>{PLANLI_GIDER_STILI}</style>
      <div className="pg">
        {/* KİMLİK BAŞLIĞI */}
        <div className="pg-bas">
          <div className="pg-avatar">{KATEGORI_IKON[kat?.kod ?? ''] ?? '🗓️'}{kat && <small>{kat.ad}</small>}</div>
          <div className="pg-kim">
            <div className="pg-ad">{k.ad || (kayitId ? '—' : 'Yeni Planlı Gider')}</div>
            <div className="pg-alt">
              Kategori <b>{kat?.ad ?? '—'}</b> · Ödenecek yer <b>{k.taraf || '—'}</b> · Masraf <b>{k.masraf || '—'}</b>
              {k.subeId ? <> · Şube <b>{k.sube ?? kullanici?.subeler.find(s => s.id === k.subeId)?.ad ?? k.subeId}</b></> : null}
            </div>
            <div className="pg-rzlar">
              <span className={'pg-rz ' + (k.durum === 1 ? 'ok' : '')}>● {k.durum === 1 ? 'Aktif' : 'Pasif'}</span>
              <span className={'pg-rz' + (k.tutarTur === 1 ? '' : k.tutarTur === 4 ? ' mavi' : ' sari')}>{adi(TUTAR_TURLERI, k.tutarTur)}</span>
              <span className="pg-rz mavi">{takvimMetni}</span>
              {artisRozeti && <span className="pg-rz mavi">{artisRozeti}</span>}
              {k.bitis && <span className="pg-rz sari">Bitiş {gunT(k.bitis)}{o.kalanDonem != null ? ` · ${o.kalanDonem} dönem kaldı` : ''}</span>}
              {kirli && <span className="pg-rz sari">kaydedilmedi</span>}
            </div>
          </div>
          <div className="pg-islem">
            {kayitId > 0 && veri.yetkiler.sil && <button type="button" className="d" disabled={mesgul} onClick={() => void sil()}>🗑 Sil</button>}
            <button type="button" className="d" onClick={() => void kapatIste()}>Kapat</button>
            {yazilabilir && <button type="button" className="d bir" disabled={mesgul} onClick={() => void kaydet()}>💾 Kaydet</button>}
          </div>
        </div>

        {/* HIZLI İŞLEM: tanım kendiliğinden kayıt AÇMAZ; ödemeyi insan oluşturur. */}
        {kayitId > 0 && (
          <div className="pg-hizli">
            {veri.yetkiler.odeme && <button type="button" className="d onay" disabled={mesgul || !hedefIzin.odeme || k.durum !== 1}
              onClick={() => hedef && void odemeOlusturHedef(hedef.vade)}>💳 Ödeme Oluştur{hedef ? ` — ${ayUzun(hedef.vade).split(' ')[0]}` : ''}</button>}
            {yazilabilir && <>
              <button type="button" className="d" disabled={mesgul || !hedefIzin.esles}
                onClick={() => { setSekme('donem'); setOneriIstegi(n => n + 1) }}>🔗 Eşleştir</button>
              <button type="button" className="d" disabled={mesgul || !hedefIzin.atla} onClick={() => void hizliDonem('atla')}>⏭ Dönemi Atla</button>
              <button type="button" className="d" disabled={mesgul || !hedefIzin.tutar} onClick={() => void hizliDonem('tutar')}>✎ Bu Dönemin Tutarı</button>
            </>}
            <span className="pg-sepv" />
            <button type="button" className="d" disabled={mesgul} onClick={() => void islem(async () => {
              if (kirliRef.current) { mesaj('Önce değişiklikleri kaydedin.'); return }
              const y = await u.planliGiderKopyala(kayitId); kartAc(`/planli-gider/${y.id}`);
            }, false)}>⧉ Kopyala</button>
            {yazilabilir && <button type="button" className="d" onClick={() => yaz('durum', k.durum === 1 ? 0 : 1)}
              title="Durumu değiştirir - Kaydet ile yazılır">{k.durum === 1 ? '⏸ Pasife Al' : '▶ Aktife Al'}</button>}
            <span className="pg-sepv" />
            <button type="button" className="d" onClick={() => git('/nakit-akis-icmali')}>📊 Nakit Akış İcmali</button>
            {k.tarafId ? <button type="button" className="d" onClick={cariEkstre}>📄 Cari Ekstre</button>
              : k.masrafId ? <button type="button" className="d" onClick={cariEkstre} title="Carisiz tanım: masraf kalemi">🧾 Masraf Kalemi</button> : null}
            <span className="pg-sp" />
            {seciliVade && hedef && <span className="pg-soluk">hedef dönem: {ayUzun(hedef.vade)}</span>}
          </div>
        )}

        {/* ÖZET ŞERİDİ: her sekmede görünür; tıklayınca ilgili sekme. */}
        {kayitId > 0 && (
          <div className="pg-ozet tik">
            <div onClick={() => setSekme('tutar')}><div className="pg-ob">Dönem tutarı</div><div className="pg-od">{tl(o.donemTutari)} {k.doviz === 'TL' ? '₺' : k.doviz}</div>
              <div className="pg-ox">{tam(o.kdvHaric)}{o.kdv ? ` + KDV ${tam(o.kdv)}` : ''}{o.stopaj ? ` − stopaj ${tam(o.stopaj)}` : ''}{artisRozeti ? ` · ${artisRozeti}` : ''}</div></div>
            <div onClick={() => setSekme('takvim')}><div className="pg-ob">Sonraki ödeme</div><div className="pg-od">{o.sonraki ? gunT(o.sonraki.tarih) : '—'}</div>
              <div className="pg-ox">{o.sonraki ? `${o.sonraki.gun} gün sonra · ${o.sonraki.gunAdi}` : 'planlı dönem yok'}</div></div>
            <div onClick={() => setSekme('donem')}><div className="pg-ob">Bu yıl ödenen</div><div className="pg-od">{tam(o.buYilOdenen)} ₺</div>
              <div className="pg-ox">{o.buYilOdenenDonem} / {o.buYilDonem} dönem · plan {tam(o.buYilPlan)}</div></div>
            <div onClick={() => setSekme('donem')}><div className="pg-ob">Kalan taahhüt</div><div className="pg-od">{o.kalanTaahhut != null ? `${tam(o.kalanTaahhut)} ₺` : 'süresiz'}</div>
              <div className="pg-ox">{o.kalanDonem != null ? `${o.kalanDonem} dönem` : ''}{k.bitis ? ` · ${gunT(k.bitis)}'e kadar` : ''}</div></div>
            <div onClick={() => setSekme('donem')}><div className="pg-ob">Zamanında</div>
              <div className={'pg-od' + (o.zamanindaOran != null && o.zamanindaOran >= 80 ? ' pg-ok' : '')}>{o.zamanindaOran != null ? `%${tam(o.zamanindaOran)}` : '—'}</div>
              <div className="pg-ox">{o.ortGecikme != null ? `ort. gecikme ${o.ortGecikme.toLocaleString('tr-TR', { maximumFractionDigits: 1 })} gün` : 'ödenmiş dönem yok'}</div>
              {o.zamanindaOran != null && <div className="pg-bar"><i style={{ width: `${Math.max(0, Math.min(100, o.zamanindaOran))}%` }} /></div>}</div>
            <div onClick={() => setSekme('eslesme')}><div className="pg-ob">Plan − gerçek</div>
              <div className={'pg-od' + (o.planGercekFark12 ? (o.planGercekFark12 > 0 ? ' pg-borc' : ' pg-ok') : '')}>{o.planGercekFark12 != null ? tl(o.planGercekFark12) : '—'}</div>
              <div className="pg-ox">son 12 ay{o.planGercekFark12 === 0 ? ' · fark yok' : ''}</div></div>
          </div>
        )}

        {hata && <div className="hata-kutusu" style={{ margin: 8 }}>{hata}</div>}

        <div className="pg-govde kart">
          <div className="pg-ana">
            <div className="pg-tabs">
              {SEKMELER.map(([s, ad]) => (
                <div key={s} className={'pg-tab' + (sekme === s ? ' on' : '')} onClick={() => setSekme(s)}>{ad}
                  {s === 'donem' && kayitId > 0 && <span className="n">{veri.donemler.length}</span>}</div>
              ))}
            </div>
            <div className="pg-pane">
              {sekme === 'genel' && <GenelSekmesi k={k} kat={kat} veri={veri} kilit={kilit} hata={alanHata} adlar={adlar} setAdlar={setAdlar}
                                                   yaz={yaz} kategoriSec={kategoriSec} kartAc={kartAc} subeAdi={k.sube ?? kullanici?.subeler.find(s => s.id === (k.subeId || kullanici?.subeId))?.ad ?? ''} />}
              {sekme === 'tutar' && <TutarSekmesi k={k} veri={veri} kilit={kilit} hata={alanHata} yaz={yaz} kirli={kirli}
                                                   artislar={artislar} setArtislar={setArtislar} />}
              {sekme === 'takvim' && <TakvimSekmesi k={k} veri={veri} kilit={kilit} hata={alanHata} yaz={yaz} kirli={kirli} sorumlu={adlar.sorumlu} />}
              {sekme === 'eslesme' && <EslesmeSekmesi k={k} veri={veri} kilit={kilit} hata={alanHata} yaz={yaz} adlar={adlar} setAdlar={setAdlar}
                                                       onDonem={v => { setSeciliVade(v); setSekme('donem'); setOneriIstegi(n => n + 1) }} />}
              {sekme === 'donem' && (kayitId
                ? <DonemlerSekmesi id={kayitId} donemler={veri.donemler} doviz={k.doviz} yazilabilir={yazilabilir} odemeYetkisi={veri.yetkiler.odeme}
                                   seciliVade={seciliVade} onSecVade={setSeciliVade} oneriIstegi={oneriIstegi}
                                   onDegisti={() => void islem(async () => {})} onOdeme={v => void odemeOlusturHedef(v)} />
                : <div className="pg-soluk">Dönemler kayıttan sonra takvimden türetilir - önce kaydedin.</div>)}
              {sekme === 'belge' && (kayitId
                ? <DokumanGalerisi kartAdi="planliGider" kaynakId={kayitId} saltOkunur={kilit} />
                : <div className="pg-soluk">Belge eklemek için önce kartı kaydedin.</div>)}
              {sekme === 'gecmis' && <GecmisSekmesi veri={veri} />}
            </div>
          </div>
          <YanPanel veri={veri} k={k} kayitId={kayitId} odeme={veri.yetkiler.odeme} mesgul={mesgul}
                    onOdeme={v => void odemeOlusturHedef(v)} onDonemler={() => setSekme('donem')} />
        </div>
        <div className="pg-altbar">
          {kayitId > 0 && <span>Oluşturan {k.ekleyenAd || '—'}{k.eklemeTarihi ? ` · ${gunT(k.eklemeTarihi)}` : ''}</span>}
          {k.degistirmeTarihi && <span>Son değişiklik {gunT(k.degistirmeTarihi)}</span>}
          <span className="pg-sp">Planlı gider kayıt değildir: kasa / banka hareketi ya da fatura oluşturmaz</span>
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------- sekmeler ----
type Yaz = <A extends keyof PlanliGiderKartAlanlari>(alan: A, deger: PlanliGiderKartAlanlari[A]) => void;
type Ortak = { k: PlanliGiderKartAlanlari; veri: Veri; kilit: boolean; hata: Record<string, string>; yaz: Yaz };
type Adlar = { masrafMerkezi?: string; sorumlu?: string; odemeHesap?: string };

function Alan({ etiket, zorunlu, hata, sinif = '', children }: { etiket: string; zorunlu?: boolean; hata?: string; sinif?: string; children: React.ReactNode }) {
  return (
    <div className={'pg-fld ' + sinif}>
      <span className={'pg-et' + (zorunlu ? ' pg-req' : '')}>{etiket}</span>
      {children}
      {hata && <span className="pg-hata">{hata}</span>}
    </div>
  );
}

function Radyo<T extends number | string>({ liste, deger, kilit, sec }: { liste: [T, string][]; deger: T; kilit: boolean; sec(v: T): void }) {
  return (
    <div className={'pg-radyo' + (kilit ? ' kilit' : '')}>
      {liste.map(([v, ad]) => <span key={String(v)} className={deger === v ? 'on' : ''} onClick={() => !kilit && sec(v)}>{ad}</span>)}
    </div>
  );
}

/** Sayı kutusu: yazarken metin, odaktan çıkınca sayıya çevrilir (tr-TR virgül). */
function SayiKutu({ deger, kilit, sag = true, onDegis, min }: { deger: number | null; kilit: boolean; sag?: boolean; min?: number; onDegis(n: number | null): void }) {
  const [m, setM] = useState(sayiMetni(deger));
  useEffect(() => { setM(sayiMetni(deger)) }, [deger]);
  return <input value={m} disabled={kilit} style={sag ? { textAlign: 'right' } : undefined} inputMode="decimal"
                onChange={e => setM(e.target.value)}
                onBlur={() => { const n = m.trim() ? sayiOku(m) : null; const v = n != null && Number.isFinite(n) ? (min != null ? Math.max(min, n) : n) : null; onDegis(v); setM(sayiMetni(v)) }} />;
}

function GenelSekmesi({ k, kat, veri, kilit, hata, yaz, kategoriSec, kartAc, adlar, setAdlar, subeAdi }: Ortak & {
  kat: PlanliGiderKategorisi | null; kategoriSec(k: PlanliGiderKategorisi | null): void; kartAc(yol: string): void;
  adlar: Adlar; setAdlar(f: (a: Adlar) => Adlar): void; subeAdi: string;
}) {
  const merkezAdi = useKayitAdi('masraf-merkezi', k.masrafMerkeziId, adlar.masrafMerkezi ?? k.masrafMerkezi);
  const sorumluAdi = useKayitAdi('personel', k.sorumluId, adlar.sorumlu ?? k.sorumlu, ['unvan', 'ad']);
  const zorunluTed = tedarikciZorunlu(kat?.kod);
  return (<>
    <div className="pg-grp"><h4>Gider</h4><div className="pg-gi"><div className="pg-f">
      <Alan etiket="Ad" zorunlu hata={hata.ad} sinif="g2">
        <input value={k.ad} maxLength={150} disabled={kilit} placeholder="ör. Depo kirası" onChange={e => yaz('ad', e.target.value)} /></Alan>
      <Alan etiket="Kategori" zorunlu hata={hata.kategoriId}>
        <select value={k.kategoriId ?? 0} disabled={kilit} onChange={e => kategoriSec(veri.kategoriler.find(x => x.id === Number(e.target.value)) ?? null)}>
          <option value={0}>— seçin —</option>
          {veri.kategoriler.map(x => <option key={x.id} value={x.id}>{x.ad}</option>)}
        </select></Alan>
      <Alan etiket="Durum" hata={hata.durum}>
        <Radyo liste={[[1, 'Aktif'], [0, 'Pasif']]} deger={k.durum} kilit={kilit} sec={v => yaz('durum', v)} /></Alan>
      <Alan etiket="Ödenecek yer (tedarikçi)" zorunlu={zorunluTed} sinif="g2"
            hata={hata.tarafId}>
        <TedarikciSecici deger={k.taraf} tarafId={k.tarafId} kilitli={kilit}
                         onSec={s => { yaz('tarafId', s?.id ?? null); yaz('taraf', s?.unvan ?? '') }}
                         onKartAc={id => kartAc(`/tedarikci/${id}`)} />
        {!zorunluTed && <span className="pg-ipucu" style={{ marginTop: 0 }}>Vergi / SGK: carisiz bırakılabilir.</span>}</Alan>
      <Alan etiket="Masraf kalemi" zorunlu hata={hata.masrafId} sinif="g2">
        <div className="pg-yanyana">
          <GenLookup kaynak="masraf" alanlar={LOOKUP_KOD_AD} sabitFiltre={AKTIF} deger={k.masraf} saltOkunur={kilit}
                     onSec={s => { yaz('masrafId', s ? Number(s.id) : null); yaz('masraf', s ? [s.kod, s.ad].filter(Boolean).join(' · ') : '') }} />
          {k.masrafId ? <button type="button" className="pg-bag" onClick={() => kartAc(`/masraf/${k.masrafId}`)}>Kart ›</button> : null}
        </div></Alan>
      <Alan etiket="Masraf merkezi" hata={hata.masrafMerkeziId}>
        <GenLookup kaynak="masraf-merkezi" alanlar={LOOKUP_KOD_AD} sabitFiltre={AKTIF} deger={merkezAdi} saltOkunur={kilit}
                   onSec={s => { yaz('masrafMerkeziId', s ? Number(s.id) : null); setAdlar(a => ({ ...a, masrafMerkezi: s ? String(s.ad ?? '') : '' })) }} /></Alan>
      <Alan etiket="Şube"><div className="pg-ro">{subeAdi || '—'}</div></Alan>
      <Alan etiket="Sorumlu" hata={hata.sorumluId}>
        <TarafSecici etiket="Sorumlu" deger={sorumluAdi} kilitli={kilit} kaynaklar={['personel']} yerTutucu="Personel ara…"
                     onSec={s => { yaz('sorumluId', s.id); setAdlar(a => ({ ...a, sorumlu: s.unvan })) }}
                     onTemizle={() => { yaz('sorumluId', null); setAdlar(a => ({ ...a, sorumlu: '' })) }} /></Alan>
      <Alan etiket="Referans no" hata={hata.referansNo}>
        <input value={k.referansNo} maxLength={60} disabled={kilit} placeholder="ör. Sözleşme 2025/014" onChange={e => yaz('referansNo', e.target.value)} /></Alan>
      <Alan etiket="Açıklama" hata={hata.aciklama} sinif="g4">
        <textarea value={k.aciklama} maxLength={500} disabled={kilit} onChange={e => yaz('aciklama', e.target.value)} /></Alan>
    </div></div></div>
    <div className="pg-grp"><h4>Kategori öntanımları <span className="pg-sp pg-soluk">kategori seçilince yalnız boş alanlara doldurulur, değiştirilebilir</span></h4><div className="pg-gi">
      <table className="pg-dg">
        <thead><tr><th>Kategori</th><th>Masraf kalemi</th><th>Tutar türü</th><th>Tatil</th><th>Hatırlatma</th></tr></thead>
        <tbody>{veri.kategoriler.map(x => (
          <tr key={x.id} className={x.id === kat?.id ? 'sec' : ''}><td>{x.id === kat?.id ? <b>{x.ad}</b> : x.ad}</td><td>{x.masraf || '—'}</td>
            <td>{adi(TUTAR_TURLERI, x.tutarTur)}{x.hesapKaynak ? ` · ${x.hesapKaynak.toLocaleUpperCase('tr')}` : ''}</td>
            <td>{adi(TATIL_KURALLARI, x.tatilKural)}</td><td>{x.hatirlatmaGun ? `${x.hatirlatmaGun} gün önce` : '—'}</td></tr>))}
        </tbody>
      </table>
    </div></div>
  </>);
}

function TutarSekmesi({ k, veri, kilit, hata, yaz, kirli, artislar, setArtislar }: Ortak & {
  kirli: boolean; artislar: Artis[]; setArtislar(f: (a: Artis[]) => Artis[]): void;
}) {
  const o = veri.ozet;
  const tutarEtiketi = k.tutarTur === 1 ? 'Tutar (KDV hariç)' : k.tutarTur === 5 ? 'Varsayılan dönem tutarı (KDV hariç)' : 'Geçmiş yoksa kullanılacak tutar (KDV hariç)';
  const artisYaz = (i: number, d: Partial<Artis>) => setArtislar(a => a.map((x, j) => (j === i ? { ...x, ...d } : x)));
  return (<>
    <div className="pg-grp"><h4>Tutar türü</h4><div className="pg-gi">
      <Radyo liste={TUTAR_TURLERI} deger={k.tutarTur} kilit={kilit} sec={v => yaz('tutarTur', v)} />
      {hata.tutarTur && <span className="pg-hata">{hata.tutarTur}</span>}
      <div className="pg-ipucu">
        {k.tutarTur === 1 && 'Sabit: her dönem aynı tutar, artış kuralları uygulanır.'}
        {k.tutarTur === 2 && 'Ortalama: eşleşen gerçek ödemelerden (masraf kalemi + cari) son N dönemin ortalaması; geçmiş yoksa aşağıdaki tutar. Tahmini rozetiyle gösterilir.'}
        {k.tutarTur === 3 && 'Geçen yıl aynı ay (mevsimsel kalem - elektrik, doğalgaz): geçen yılın aynı dönemindeki gerçekleşen; yoksa aşağıdaki tutar.'}
        {k.tutarTur === 4 && 'Hesaplanan: KDV = KDV İcmali\'nin son kesin dönem "ödenecek"i (sonraki aylara aynı tutar, tahmini); SGK = son 3 ödemenin ortalaması.'}
        {k.tutarTur === 5 && 'Elle (her dönem): her dönemin tutarı Dönemler sekmesinden "Tutar" ile yazılır; yazılmayan dönemde aşağıdaki tutar kullanılır.'}
        {' '}Bir dönemin tutarı elle yazılırsa o dönem için elle yazılan geçerlidir.
      </div>
    </div></div>
    <div className="pg-iki">
      <div className="pg-grp"><h4>Tutar</h4><div className="pg-gi"><div className="pg-f k2">
        {k.tutarTur === 2 && <Alan etiket="Ortalama alınacak dönem sayısı (N)" hata={hata.ortalamaDonem} sinif="g2">
          <select value={k.ortalamaDonem} disabled={kilit} onChange={e => yaz('ortalamaDonem', Number(e.target.value))}>
            {[2, 3, 4, 6, 12].map(n => <option key={n} value={n}>Son {n} dönem</option>)}</select></Alan>}
        {k.tutarTur === 4 && <Alan etiket="Hesap kaynağı" hata={hata.hesapKaynak} sinif="g2">
          <Radyo liste={HESAP_KAYNAKLARI} deger={k.hesapKaynak} kilit={kilit} sec={v => yaz('hesapKaynak', v)} /></Alan>}
        <Alan etiket={tutarEtiketi} zorunlu={k.tutarTur === 1} hata={hata.tutar}>
          <SayiKutu deger={k.tutar} kilit={kilit} min={0} onDegis={n => yaz('tutar', n ?? 0)} /></Alan>
        <Alan etiket="Para birimi" hata={hata.doviz}>
          <select value={k.doviz} disabled={kilit} onChange={e => yaz('doviz', e.target.value)}>
            {[...new Set(['TL', ...DOVIZ_KODLARI, k.doviz])].filter(Boolean).map(d => <option key={d} value={d}>{d}</option>)}</select></Alan>
        <Alan etiket="KDV" hata={hata.kdvOran}>
          <select value={k.kdvOran} disabled={kilit} onChange={e => yaz('kdvOran', Number(e.target.value))}>
            {[...new Set([...KDV_ORANLARI, k.kdvOran])].map(n => <option key={n} value={n}>{n ? `%${n}` : 'Yok'}</option>)}</select></Alan>
        <Alan etiket="KDV tutarı"><div className="pg-ro" style={{ justifyContent: 'flex-end' }}>{tl(o.kdv)}</div></Alan>
        <Alan etiket="Stopaj" hata={hata.stopajOran}>
          <select value={k.stopajOran} disabled={kilit} onChange={e => yaz('stopajOran', Number(e.target.value))}>
            {[...new Set([...STOPAJ_ORANLARI, k.stopajOran])].map(n => <option key={n} value={n}>{n ? `%${n}` : 'Yok'}</option>)}</select></Alan>
        <Alan etiket="Stopaj tutarı"><div className="pg-ro" style={{ justifyContent: 'flex-end' }}>{tl(o.stopaj)}</div></Alan>
        <Alan etiket="Nakit çıkışı (dönem)" sinif="g2">
          <div className="pg-ro" style={{ justifyContent: 'flex-end' }}><b>{tl(o.donemTutari)} {k.doviz}</b>
            {kirli && <span className="pg-not-kaydet">kaydedince güncellenir</span>}</div></Alan>
      </div>
      <div className="pg-ipucu">Stopajlı kirada (şahıstan kira) nakit çıkışı = brüt − stopaj; stopaj ayrıca "Muhtasar" planlı giderine eklenir.</div>
      </div></div>
      <div className="pg-grp"><h4>Artış kuralları
        {!kilit && <span className="pg-sp"><button type="button" className="d pg-mini"
          onClick={() => setArtislar(a => [...a, { id: 0, gecerlilik: `${new Date().getFullYear() + 1}-01-01`, tur: 1, deger: 0, aciklama: '' }])}>＋ Kural</button></span>}
      </h4><div className="pg-gi">
        <table className="pg-dg">
          <thead><tr><th>Geçerlilik</th><th>Tür</th><th className="pg-sag">Oran / tutar</th><th className="pg-sag">Yeni KDV hariç</th><th>Not</th>{!kilit && <th />}</tr></thead>
          <tbody>
            {artislar.map((a, i) => (
              <tr key={`${a.id}-${i}`}>
                <td><input type="date" className="pg-hucre" value={a.gecerlilik} disabled={kilit || a.uygulandi} onChange={e => artisYaz(i, { gecerlilik: e.target.value })} /></td>
                <td><select className="pg-hucre" value={a.tur} disabled={kilit || a.uygulandi} onChange={e => artisYaz(i, { tur: Number(e.target.value) })}>
                  <option value={1}>Oran (%)</option><option value={2}>Yeni tutar</option></select></td>
                <td className="pg-sag"><SayiKutu deger={a.deger} kilit={kilit || !!a.uygulandi} onDegis={n => artisYaz(i, { deger: n ?? 0 })} /></td>
                <td className="pg-sag">{a.yeniKdvHaric != null ? tl(a.yeniKdvHaric) : <span className="pg-soluk">kaydedince</span>}</td>
                <td><input className="pg-hucre" value={a.aciklama} maxLength={200} disabled={kilit} placeholder={a.uygulandi ? 'uygulandı' : 'planlı'}
                           onChange={e => artisYaz(i, { aciklama: e.target.value })} />
                  {a.uygulandi ? <small>uygulandı</small> : a.id ? <span className="pg-rz mavi">planlı</span> : null}</td>
                {!kilit && <td>{!a.uygulandi && <button type="button" className="pg-bag" title="Kuralı sil" onClick={() => setArtislar(l => l.filter((_, j) => j !== i))}>✕</button>}</td>}
              </tr>))}
            {artislar.length === 0 && <tr><td colSpan={6} className="pg-bos">Artış kuralı yok.</td></tr>}
          </tbody>
        </table>
        {hata.artislar && <span className="pg-hata">{hata.artislar}</span>}
        <div className="pg-ipucu">TÜFE'ye otomatik bağlama yok: oran açıklanınca kural güncellenir. Kural, geçerlilik tarihinden sonraki bütün dönemlere uygulanır.</div>
      </div></div>
    </div>
    <div className="pg-grp"><h4>Önizleme — sonraki 12 dönem (nakit çıkışı){kirli && <span className="pg-not-kaydet">kaydedince güncellenir</span>}</h4><div className="pg-gi">
      <div className="pg-onizle">
        {veri.onizleme.tutarlar.slice(0, 12).map(t => <span key={t.vade} className={t.artis ? 'k' : ''}>{ayKisa(t.vade)} {tam(t.tutar)}</span>)}
        {veri.onizleme.tutarlar.length === 0 && <span>{k.id ? 'Önümüzdeki dönem yok.' : 'Kaydedince sunucu hesaplar.'}</span>}
      </div>
      <div className="pg-ipucu">Sarı: artış kuralının ilk uygulandığı dönem.</div>
    </div></div>
  </>);
}

function TakvimSekmesi({ k, veri, kilit, hata, yaz, kirli, sorumlu }: Ortak & { kirli: boolean; sorumlu?: string }) {
  const [bitis, setBitis] = useState<BitisTuru>(bitisTuru(k));
  useEffect(() => { setBitis(bitisTuru(k)) }, [k.id]);   // eslint-disable-line react-hooks/exhaustive-deps
  const bitisSec = (b: BitisTuru) => {
    setBitis(b);
    if (b === 'suresiz') { yaz('bitis', null); yaz('donemSayisi', null) }
    else if (b === 'tarih') yaz('donemSayisi', null);
    else yaz('bitis', null);
  };
  const o = veri.ozet;
  const gunler = k.periyot === 1 ? HAFTA_GUNLERI.map((g, i) => [i + 1, g] as [number, string])
    : Array.from({ length: 31 }, (_, i) => [i + 1, odemeGunuMetni(k.periyot, i + 1)] as [number, string]);
  return (<>
    <div className="pg-iki">
      <div className="pg-grp"><h4>Takvim</h4><div className="pg-gi"><div className="pg-f k2">
        <Alan etiket="Periyot" zorunlu hata={hata.periyot} sinif="g2">
          <Radyo liste={PERIYOTLAR} deger={k.periyot} kilit={kilit} sec={v => { yaz('periyot', v); if (v === 1 && k.odemeGunu > 7) yaz('odemeGunu', 1) }} /></Alan>
        <Alan etiket={k.periyot === 1 ? 'Ödeme günü (hafta)' : 'Ödeme günü'} zorunlu hata={hata.odemeGunu}>
          <select value={k.odemeGunu} disabled={kilit} onChange={e => yaz('odemeGunu', Number(e.target.value))}>
            {gunler.map(([g, ad]) => <option key={g} value={g}>{ad}</option>)}</select></Alan>
        <Alan etiket="Tatile / hafta sonuna denk gelirse" hata={hata.tatilKural}>
          <Radyo liste={TATIL_KURALLARI} deger={k.tatilKural} kilit={kilit} sec={v => yaz('tatilKural', v)} /></Alan>
        <Alan etiket="Başlangıç" zorunlu hata={hata.baslangic}>
          <input type="date" value={k.baslangic ?? ''} disabled={kilit} onChange={e => yaz('baslangic', e.target.value)} /></Alan>
        <Alan etiket="Bitiş" hata={hata.bitis ?? hata.donemSayisi}>
          <Radyo liste={[['suresiz', 'Süresiz'], ['tarih', 'Tarihte'], ['donem', 'N dönem sonra']] as [BitisTuru, string][]} deger={bitis} kilit={kilit} sec={bitisSec} /></Alan>
        {bitis === 'tarih' && <Alan etiket="Bitiş tarihi" zorunlu>
          <input type="date" value={k.bitis ?? ''} min={k.baslangic} disabled={kilit} onChange={e => yaz('bitis', e.target.value || null)} /></Alan>}
        {bitis === 'donem' && <Alan etiket="Dönem sayısı" zorunlu>
          <SayiKutu deger={k.donemSayisi} kilit={kilit} min={1} onDegis={n => yaz('donemSayisi', n ? Math.round(n) : null)} /></Alan>}
        <Alan etiket="Dönem sayısı (sunucu)">
          <div className="pg-ro">{o.toplamDonem != null ? `${o.toplamDonem}${o.kalanDonem != null ? ` (${o.toplamDonem - o.kalanDonem} geçti,${o.kalanDonem} kaldı)` : ''}` : 'süresiz'}
            {kirli && <span className="pg-not-kaydet">kaydedince güncellenir</span>}</div></Alan>
      </div>
      <div className="pg-ipucu">Tatiller Resmi Tatiller tanımından. Ayın 29-31'i seçilirse kısa ayda ayın son günü.</div>
      </div></div>
      <div className="pg-grp"><h4>Hatırlatma</h4><div className="pg-gi"><div className="pg-f k2">
        <Alan etiket="Ne zaman" hata={hata.hatirlatmaGun}>
          <select value={k.hatirlatmaGun} disabled={kilit} onChange={e => yaz('hatirlatmaGun', Number(e.target.value))}>
            {[...new Set([...HATIRLATMA_GUNLERI, k.hatirlatmaGun])].sort((a, b) => a - b).map(n => <option key={n} value={n}>{n ? `${n} gün önce` : 'Hatırlatma yok'}</option>)}</select></Alan>
        <Alan etiket="Kime"><div className="pg-ro">{k.sorumluId ? (sorumlu || k.sorumlu || 'Sorumlu') : 'Sorumlu seçilmedi (Genel sekmesi)'}</div></Alan>
        <Alan etiket="Kanal"><div className="pg-ro">Bildirim kuyruğu</div></Alan>
        <Alan etiket="Gecikince"><div className="pg-ro">Her gün, en çok 5 kez</div></Alan>
      </div>
      <div className="pg-ipucu">Ödeme eşleşince o dönemin hatırlatması durur. Bitişe 90 gün kala yenileme hatırlatması gider.</div>
      </div></div>
    </div>
    <div className="pg-grp"><h4>Önizleme — sonraki 8 ödeme günü{kirli && <span className="pg-not-kaydet">kaydedince güncellenir</span>}</h4><div className="pg-gi">
      <div className="pg-onizle">
        {veri.onizleme.tarihler.slice(0, 8).map(t => (
          <span key={t.tarih} className={t.kaydirildi ? 'k' : ''}>{gunT(t.tarih)} {new Date(`${t.tarih}T12:00:00`).toLocaleDateString('tr-TR', { weekday: 'short' })}{t.kaydirildi && t.neden ? ` · ${t.neden}` : ''}</span>))}
        {veri.onizleme.tarihler.length === 0 && <span>{k.id ? 'Önümüzdeki ödeme günü yok.' : 'Kaydedince sunucu hesaplar.'}</span>}
      </div>
      <div className="pg-ipucu">Sarı: tatil / hafta sonu nedeniyle kaydırılan gün.</div>
    </div></div>
  </>);
}

function EslesmeSekmesi({ k, veri, kilit, hata, yaz, adlar, setAdlar, onDonem }: Ortak & {
  adlar: Adlar; setAdlar(f: (a: Adlar) => Adlar): void; onDonem(vade: string): void;
}) {
  const hesapAdi = useKayitAdi('hesap', k.odemeHesapId, adlar.odemeHesap ?? k.odemeHesap);
  const bekleyen = veri.donemler.filter(d => d.durum === 'gecikti' || d.durum === 'beklemede' || d.durum === 'bugun');
  const son = [...veri.donemler].reverse().find(d => d.eslesen);
  return (<>
    <div className="pg-iki">
      <div className="pg-grp"><h4>Ödeme</h4><div className="pg-gi"><div className="pg-f k2">
        <Alan etiket="Ödeme hesabı" zorunlu hata={hata.odemeHesapId} sinif="g2">
          <GenLookup kaynak="hesap" alanlar={LOOKUP_HESAP} sabitFiltre={AKTIF} deger={hesapAdi} saltOkunur={kilit}
                     onSec={s => { yaz('odemeHesapId', s ? Number(s.id) : null); setAdlar(a => ({ ...a, odemeHesap: s ? String(s.ad ?? '') : '' })) }} /></Alan>
        <Alan etiket="Yöntem" hata={hata.odemeYontem}>
          <select value={k.odemeYontem} disabled={kilit} onChange={e => yaz('odemeYontem', Number(e.target.value))}>
            {ODEME_YONTEMLERI.map(([v, ad]) => <option key={v} value={v}>{ad}</option>)}</select></Alan>
        <Alan etiket="Karşı IBAN" hata={hata.karsiIban}>
          <input value={k.karsiIban} maxLength={34} disabled={kilit} placeholder="TR.. (boşsa cari kartından)"
                 onChange={e => yaz('karsiIban', e.target.value.toUpperCase().replace(/\s+/g, ''))} /></Alan>
        <Alan etiket="Ödeme açıklaması (şablon)" hata={hata.odemeAciklama} sinif="g2">
          <input value={k.odemeAciklama} maxLength={200} disabled={kilit} placeholder="{ay} {yil} {ad}"
                 onChange={e => yaz('odemeAciklama', e.target.value)} /></Alan>
      </div>
      <div className="pg-bilgi">"Ödeme Oluştur" bu bilgilerle <b>taslak</b> tediye açar (Kasa İşlemi; cari + masraf + açıklama dolu); kesinleştiren kullanıcıdır.
        Kredi kartı seçilirse nakit çıkışı kartın ekstre son ödeme gününde görünür, ayrıca çıkış yazılmaz.</div>
      </div></div>
      <div className="pg-grp"><h4>Gerçekleşme eşleştirmesi</h4><div className="pg-gi"><div className="pg-f k2">
        <Alan etiket="Eşleşecek masraf"><div className="pg-ro">{k.masraf || 'masraf kalemi yok'}</div></Alan>
        <Alan etiket="Eşleşecek cari"><div className="pg-ro">{k.taraf || 'cari yok'}</div></Alan>
        <Alan etiket="Tarih toleransı (± gün)" hata={hata.eslesGun}>
          <SayiKutu deger={k.eslesGun} kilit={kilit} min={0} onDegis={n => yaz('eslesGun', Math.round(n ?? 0))} /></Alan>
        <Alan etiket="Tutar toleransı (± %)" hata={hata.eslesYuzde}>
          <SayiKutu deger={k.eslesYuzde} kilit={kilit} min={0} onDegis={n => yaz('eslesYuzde', n ?? 0)} /></Alan>
        <Alan etiket="Kaynaklar" sinif="g2"><div className="pg-ro">Kasa / banka ödemesi · alış faturası · banka hareketi (işlenmemiş)</div></Alan>
        <Alan etiket="Otomatik eşleşme" sinif="g2" hata={hata.eslesOtomatik}>
          <Radyo liste={[[1, 'Tek aday varsa otomatik'], [0, 'Her zaman öneri']]} deger={k.eslesOtomatik} kilit={kilit} sec={v => yaz('eslesOtomatik', v)} /></Alan>
      </div>
      <div className="pg-ipucu">Alış faturası eşleşirse dönem "faturalandı" olur; nakit akışa faturanın vadesiyle girer, plan düşer — iki kez sayılmaz.
        Otomatik eşleşme loglu ve dönem satırından geri alınabilir.</div>
      </div></div>
    </div>
    <div className="pg-grp"><h4>Eşleşme bekleyen dönemler <span className="pg-sp pg-soluk">{bekleyen.length ? `${bekleyen.length} dönem` : 'bu tanım için yok'}</span></h4><div className="pg-gi">
      {bekleyen.map(d => {
        const r = durumRozeti(d.durum, d.gun);
        return <div key={d.vade} className="pg-kisi"><div><b>{ayUzun(d.vade)} · {tl(d.plan)}</b><small>plan {gunT(d.planTarihi)} <span className={'pg-rz ' + r.renk}>{r.ad}</span></small></div>
          {!kilit && k.id > 0 && <div className="pg-ik"><button type="button" className="d pg-mini" onClick={() => onDonem(d.vade)}>🔗 Önerileri gör</button></div>}</div>;
      })}
      <div className="pg-soluk" style={{ marginTop: 6 }}>{son ? `Son eşleşme: ${ayUzun(son.vade)} ← ${son.eslesen!.no}${son.odemeTarihi ? ` · ${gunT(son.odemeTarihi)}` : ''} · ${son.otomatik ? 'otomatik' : 'elle'}.` : 'Henüz eşleşmiş dönem yok.'}</div>
    </div></div>
  </>);
}

function GecmisSekmesi({ veri }: { veri: Veri }) {
  return (<>
    <table className="pg-dg">
      <thead><tr><th>Zaman</th><th>İşlem</th></tr></thead>
      <tbody>
        {veri.zaman.map((z, i) => <tr key={i}><td style={{ whiteSpace: 'nowrap' }}>{gunT(z.tarih)}</td>
          <td><span className={z.tur === 'ok' ? 'pg-ok' : z.tur === 'kir' ? 'pg-borc' : ''}>{z.metin}</span></td></tr>)}
        {veri.zaman.length === 0 && <tr><td colSpan={2} className="pg-bos">Kayıt yok.</td></tr>}
      </tbody>
    </table>
    <div className="pg-ipucu">Alan bazlı değişiklikler ve eşleşmeler işlem günlüğüne (ISLEMLOG) yazılır; ayrıntı Yönetim › İşlem Günlüğü'nde.</div>
  </>);
}

// --------------------------------------------------------------- yan panel ----
function YanPanel({ veri, k, kayitId, odeme, mesgul, onOdeme, onDonemler }: {
  veri: Veri; k: PlanliGiderKartAlanlari; kayitId: number; odeme: boolean; mesgul: boolean;
  onOdeme(vade: string): void; onDonemler(): void;
}) {
  const sonraki = useMemo(() => veri.donemler.filter(d => d.durum === 'gecikti' || d.durum === 'bugun' || d.durum === 'planli').slice(0, 3), [veri.donemler]);
  const son12 = useMemo(() => {
    const i = veri.donemler.findIndex(d => d.durum === 'planli' || d.durum === 'bugun');
    const gecmis = i < 0 ? veri.donemler : veri.donemler.slice(0, i);
    return gecmis.slice(-12);
  }, [veri.donemler]);
  const enBuyuk = Math.max(0, ...son12.map(d => d.gercek ?? d.plan));
  if (!kayitId) {
    return <div className="pg-yan"><h5>Yeni tanım</h5>
      <div className="pg-bilgi" style={{ marginTop: 0 }}>Bu tanım hiçbir kayıt <b>kendiliğinden</b> oluşturmaz. Kaydedince dönemler takvimden türetilir;
        sonraki ödemeler, önizleme ve Nakit Akış İcmali'ndeki "Planlı: {k.ad || 'ad'}" satırı sunucuda hesaplanır.</div></div>;
  }
  return (
    <div className="pg-yan">
      <h5>Sonraki ödemeler</h5>
      {sonraki.length === 0 && <div className="pg-soluk">Planlı dönem yok.</div>}
      {sonraki.map((d, i) => {
        const r = durumRozeti(d.durum, d.gun);
        return (
          <div key={d.vade} className="pg-kisi">
            <div className="pg-av">{Number(d.planTarihi.slice(8, 10))}</div>
            <div><b>{gunT(d.planTarihi)} · {tl(d.plan)}</b>
              <small>{d.kaydirildi && d.kaydirmaNedeni ? d.kaydirmaNedeni : r.ad}{d.elleTutar != null ? ' · elle tutar' : ''}</small></div>
            {i === 0 && odeme && k.durum === 1 && <div className="pg-ik"><button type="button" className="d pg-mini" disabled={mesgul} title="Ödeme Oluştur" onClick={() => onOdeme(d.vade)}>💳</button></div>}
          </div>
        );
      })}
      {veri.uyarilar.length > 0 && <>
        <h5>Dikkat</h5>
        {veri.uyarilar.map((w, i) => <div key={i} className={'pg-uyari ' + (w.seviye === 'kir' ? '' : w.seviye)}>{w.metin}</div>)}
      </>}
      <h5>Son 12 dönem <a onClick={onDonemler}>Dönemler ›</a></h5>
      {son12.length === 0 ? <div className="pg-soluk">Geçmiş dönem yok.</div> : <>
        <div className="pg-mini12">
          {son12.map((d, i) => <i key={d.vade} className={i === son12.length - 1 ? 'y' : ''} title={`${ayUzun(d.vade)}: ${tl(d.gercek ?? d.plan)}`}
                                  style={{ height: cubukBoyu(d.gercek ?? d.plan, enBuyuk, 52), opacity: d.eslesen ? 1 : .45 }} />)}
        </div>
        <div className="pg-mini12l">{son12.map(d => <span key={d.vade}>{ayKisa(d.vade)}</span>)}</div>
        <div className="pg-ipucu">Soluk: eşleşmemiş dönem (plan tutarı).</div>
      </>}
      <h5>Nakit akışa etkisi</h5>
      <div className="pg-pin">
        {k.durum === 1 ? <>Nakit Akış İcmali'nde <b>"Planlı: {k.ad}"</b> satırı{veri.ozet.sonraki ? `, sonraki çıkış ${gunT(veri.ozet.sonraki.tarih)}` : ''}.</>
          : <>Pasif tanım nakit akışta görünmez.</>}
        {veri.ozet.kalanTaahhut != null && <small>Kalan taahhüt {tl(veri.ozet.kalanTaahhut)} · {veri.ozet.kalanDonem} dönem</small>}
        {k.odemeYontem === 3 && <small>Kredi kartı: çıkış kartın ekstre son ödeme gününde.</small>}
      </div>
      {veri.zaman.length > 0 && <>
        <h5>Zaman çizgisi</h5>
        <div className="pg-zaman">
          {veri.zaman.slice(0, 6).map((z, i) => <div key={i} className={z.tur}>{z.metin}<small>{gunT(z.tarih)}</small></div>)}
        </div>
      </>}
    </div>
  );
}

export default PlanliGiderKarti;
