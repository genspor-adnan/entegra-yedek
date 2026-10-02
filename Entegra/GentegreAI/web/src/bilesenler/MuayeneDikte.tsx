import { useEffect, useRef, useState } from 'react';
import { Modal } from './Modal';
import { duzelt } from './goz/dikteMotoru';
import { c } from '../dil/ceviri';

/**
 * MUAYENE DİKTESİ (kullanıcı: "muayeneye dikte ekle").
 *
 * Göz dikte penceresinin (705) sade karşılığı: hedef yalnız SERBEST METİN
 * alanları (Şikâyet, Hikâye, Değerlendirme / Plan) - kodlu alan (tanı, çıkış
 * şekli) dikteyle yazılmaz, yanlış duyulan bir kod sessizce kayda geçerdi.
 *
 * <b>ÜÇ ALAN, FARE NEREDEYSE ORAYA</b> (kullanıcı): Şikâyet, Hikâye ve
 * Değerlendirme / Plan kartın güncel metniyle açılır; fare hangi alanın
 * üstündeyse (ya da hangisine tıklandıysa) dikte onun SONUNA yazar.
 *
 * <b>Karta kendiliğinden yazılmaz.</b> Hekim alanlarda görür ve düzeltir;
 * "Karta aktar" DEĞİŞEN alanları karta yazar (noktalama / cümle başı
 * düzeltilerek), kayıt kartın Kaydet'iyle gider.
 *
 * <b>Ses tarayıcıda çözülür</b> (Web Speech API): ses tarayıcının tanıma
 * hizmetine gider. Ekran bunu başlıkta söyler; ses hiçbir yerde saklanmaz.
 */

interface TanimaOlayi {
  resultIndex: number;
  results: ArrayLike<ArrayLike<{ transcript: string }> & { isFinal: boolean }>;
}
interface Taniyici {
  lang: string; continuous: boolean; interimResults: boolean;
  start(): void; stop(): void;
  onresult: ((o: TanimaOlayi) => void) | null;
  onerror: ((o: { error: string }) => void) | null;
  onend: (() => void) | null;
  // TANI OLAYLARI (göz diktesiyle aynı): "kayıtta diyor ama yazmıyor"u ayırır.
  onstart?: (() => void) | null;
  onaudiostart?: (() => void) | null;
  onsoundstart?: (() => void) | null;
  onspeechstart?: (() => void) | null;
  onnomatch?: (() => void) | null;
}

function taniyiciYap(): Taniyici | null {
  const p = window as unknown as { SpeechRecognition?: new () => Taniyici;
                                   webkitSpeechRecognition?: new () => Taniyici };
  const Sinif = p.SpeechRecognition ?? p.webkitSpeechRecognition;
  if (!Sinif) return null;
  const t = new Sinif();
  t.lang = 'tr-TR';
  t.continuous = true;
  t.interimResults = true;
  return t;
}

/** Söylenen noktalama komutları ("virgül", "nokta", "yeni satır"). */
export function sozluNoktalama(metin: string): string {
  return metin
    .replace(/\s*\byeni satır\b\s*/gi, '\n')
    .replace(/\s*\bvirgül\b/gi, ',')
    .replace(/\s*\bnokta\b/gi, '.')
    .replace(/\s*\bsoru işareti\b/gi, '?')
    .replace(/\s*\biki nokta\b/gi, ':');
}

export interface DikteHedefi { ad: string; baslik: string }

export function MuayeneDikte({ hedefler, degerOku, onYaz, onKapat }: {
  hedefler: DikteHedefi[];
  /** Alanın kartta ŞU ANKİ metni (pencere onunla açılır). */
  degerOku(ad: string): string;
  /** Değişen alanın yeni metnini karta yazar (kaydedilmemiş değişiklik). */
  onYaz(ad: string, metin: string): void;
  onKapat(): void;
}) {
  const [hedef, setHedefState] = useState(hedefler[0]?.ad ?? '');
  // ETKIN ALAN REF'TE DE: taniyicinin onresult'u baslatildigi andaki
  //   kapanisi tasir; fare baska alana gecince yazim oraya kaymali.
  const hedefRef = useRef(hedef);
  const setHedef = (ad: string) => { hedefRef.current = ad; setHedefState(ad) };
  const [baslangic] = useState<Record<string, string>>(
    () => Object.fromEntries(hedefler.map(h => [h.ad, degerOku(h.ad)])));
  const [metinler, setMetinler] = useState<Record<string, string>>(baslangic);
  const [gecici, setGecici] = useState('');
  const [dinliyor, setDinliyor] = useState(false);
  const [hata, setHata] = useState('');
  const taniyici = useRef<Taniyici | null>(null);
  // DİNLEME NİYETİ: tanıyıcı sessizlikte kendi kapanır; hekim "dur" demedikçe
  //   yeniden başlatılır - aksi hâlde iki cümle arası susunca dikte ölür.
  const istek = useRef(false);
  const sonBaslangic = useRef(0);
  const destekli = typeof window !== 'undefined' && !!taniyiciYap();
  const guvenli = typeof window !== 'undefined' && window.isSecureContext === true;

  // ---- TEŞHİS (kullanıcı: "ses olmadı") - göz diktesinde yaşanmış vakalar:
  //   * mikrofon izni / cihaz yok           -> hata metni
  //   * Windows varsayılan girişi "Stereo Karışımı" gibi DÖNGÜ cihazı ->
  //     tanıyıcı sistem sesini dinler; cihaz adı ekranda + uyarı
  //   * ses geliyor, metin gelmiyor         -> Windows "Çevrimiçi konuşma
  //     tanıma" kapalı / ağ engeli; tarayıcı HATA VERMEDEN susar
  //   * mikrofonu iki yerden açmak (ölçer + tanıyıcı) bazı sürücülerde
  //     tanıyıcıya sessizlik dinletir -> 6 sn ses yoksa ölçer bırakılır
  const [seviye, setSeviye] = useState(0);
  const [cihazAdi, setCihazAdi] = useState('');
  const [sonOlay, setSonOlay] = useState('');
  const [hizmetIpucu, setHizmetIpucu] = useState(false);
  const metinGeldi = useRef(false);
  const sesDuyuldu = useRef(false);
  const olcerBirakildi = useRef(false);
  const sesDuzeni = useRef<{ ctx: AudioContext; akis: MediaStream; kare: number } | null>(null);
  const dongucuMu = /stereo (mix|karışımı|karisimi)|what u hear|loopback|wave out|mix/i.test(cihazAdi);
  const olay = (ad: string) => {
    setSonOlay(`${ad} · ${new Date().toLocaleTimeString('tr-TR')}`);
    if (ad === 'metin geldi') metinGeldi.current = true;
  };

  const sesOlcumuAc = async () => {
    if (sesDuzeni.current) return;
    try {
      const akis = await navigator.mediaDevices.getUserMedia({ audio: true });
      // Bu arada durduruldu ya da ikinci bir olcer acildiysa bu akisi birak -
      //   yoksa mikrofon acik kalir (pencere acilir acilmaz baslatmada olur).
      if (!istek.current || sesDuzeni.current) { akis.getTracks().forEach(t => t.stop()); return }
      setCihazAdi(akis.getAudioTracks()[0]?.label ?? '');
      const ctx = new AudioContext();
      const coz = ctx.createAnalyser();
      coz.fftSize = 512;
      ctx.createMediaStreamSource(akis).connect(coz);
      const tampon = new Uint8Array(coz.frequencyBinCount);
      // SANIYEDE ~10 CIZIM (kullanici: "biraz yavas"): her karede state
      //   yazmak pencereyi saniyede 60 kez yeniden ciziyordu.
      let son = 0;
      const olc = (zaman: number) => {
        if (zaman - son >= 100) {
          son = zaman;
          coz.getByteTimeDomainData(tampon);
          let enBuyuk = 0;
          for (const v of tampon) enBuyuk = Math.max(enBuyuk, Math.abs(v - 128));
          setSeviye(Math.min(1, enBuyuk / 40));
        }
        if (sesDuzeni.current) sesDuzeni.current.kare = requestAnimationFrame(olc);
      };
      sesDuzeni.current = { ctx, akis, kare: 0 };
      sesDuzeni.current.kare = requestAnimationFrame(olc);
    } catch (h) {
      const ad = (h as { name?: string }).name ?? '';
      setHata(ad === 'NotAllowedError'
        ? 'Mikrofon izni verilmedi: adres çubuğundaki kilit simgesinden izin verin.'
        : ad === 'NotFoundError' ? 'Mikrofon bulunamadı: cihaz bağlı mı?'
        : `Mikrofon açılamadı (${ad || 'bilinmeyen'}).`);
    }
  };
  const sesOlcumuKapat = () => {
    const d = sesDuzeni.current;
    sesDuzeni.current = null;
    if (!d) return;
    cancelAnimationFrame(d.kare);
    d.akis.getTracks().forEach(t => t.stop());
    void d.ctx.close();
    setSeviye(0);
  };

  useEffect(() => () => {
    istek.current = false;
    sesOlcumuKapat();
    try { taniyici.current?.stop() } catch { /* zaten durmuş */ }
  }, []);

  const baslat = () => {
    setHata('');
    const t = taniyiciYap();
    if (!t) return;
    if (!olcerBirakildi.current) void sesOlcumuAc();
    metinGeldi.current = false;
    sesDuyuldu.current = false;
    setHizmetIpucu(false);
    t.onstart = () => olay('motor açıldı');
    t.onaudiostart = () => {
      olay('ses akışı geldi');
      window.setTimeout(() => {
        if (!istek.current || metinGeldi.current || olcerBirakildi.current || sesDuyuldu.current) return;
        olcerBirakildi.current = true;
        sesOlcumuKapat();
        olay('ölçer bırakıldı, yeniden başlatılıyor');
        try { t.stop() } catch { /* zaten durmuş */ }
      }, 6000);
    };
    t.onsoundstart = () => { sesDuyuldu.current = true; olay('ses duyuldu') };
    t.onspeechstart = () => {
      olay('konuşma duyuldu');
      window.setTimeout(() => {
        if (!istek.current || metinGeldi.current) return;
        // KONUSMA DUYULDU AMA METIN YOK: once OLCERI birak ve tanimayi
        //   yeniden baslat (mikrofonun iki yerden acilmasi bazi suruculerde
        //   taniyiciya bozuk ses verir). Olcersiz de metin gelmezse hizmet
        //   sorunudur - ipucu o zaman gosterilir.
        if (!olcerBirakildi.current) {
          olcerBirakildi.current = true;
          sesOlcumuKapat();
          olay('metin yok: ölçer bırakıldı, yeniden deneniyor');
          try { t.stop() } catch { /* zaten durmuş */ }
          return;
        }
        setHizmetIpucu(true);
      }, 8000);
    };
    t.onnomatch = () => olay('duydu, anlamadı');
    t.onresult = o => {
      let son = '';
      let ara = '';
      for (let i = o.resultIndex; i < o.results.length; i++) {
        const r = o.results[i];
        if (r.isFinal) son += r[0].transcript;
        else ara += r[0].transcript;
      }
      // Ham metin biriktirilir; DUZELTME (noktalama, cumle basi) eklerken
      //   yapilir - her parcaya nokta koymak cumleyi bolerdi.
      if (son) {
        olay('metin geldi');
        setHizmetIpucu(false);
        const ad = hedefRef.current;
        setMetinler(m => ({ ...m,
          [ad]: sozluNoktalama(`${m[ad] ?? ''} ${son}`).replace(/[ 	]+/g, ' ').trimStart() }));
      }
      setGecici(ara);
    };
    t.onerror = o => {
      olay(`hata: ${o.error}`);
      if (o.error === 'no-speech' || o.error === 'aborted') return;
      istek.current = false;
      setHata(o.error === 'not-allowed' || o.error === 'service-not-allowed'
        ? 'Mikrofon / ses tanıma izni verilmedi: adres çubuğundaki kilit simgesinden izin verin.'
        : o.error === 'audio-capture'
        ? 'Mikrofon bulunamadı ya da başka bir uygulama kullanıyor.'
        : o.error === 'network'
        ? 'Tanıma hizmetine ulaşılamadı (ağ). Tarayıcının ses tanıma sunucusuna erişim gerekir.'
        : `Ses tanıma durdu (${o.error}).`);
    };
    // KENDILIGINDEN KAPANINCA YENIDEN BASLAT; 1 sn'den sik kapanirsa dur
    //   (izin reddi gibi kalici durumda saniyede onlarca deneme olmasin).
    t.onend = () => {
      // ESKI TANIYICI yeniden baslamaz: yerine yenisi kurulduysa (pencere
      //   yeniden baglandi / tekrar baslatildi) iki tanıyıcı ayni anda yazardi.
      if (taniyici.current !== t) return;
      setGecici('');
      if (!istek.current) { setDinliyor(false); return }
      const simdi = Date.now();
      if (simdi - sonBaslangic.current < 1000) {
        istek.current = false;
        setDinliyor(false);
        setHata('Dikte sürdürülemedi: mikrofon başka bir uygulamada olabilir.');
        return;
      }
      sonBaslangic.current = simdi;
      try { t.start() } catch { istek.current = false; setDinliyor(false) }
    };
    taniyici.current = t;
    istek.current = true;
    sonBaslangic.current = Date.now();
    try { t.start(); setDinliyor(true) }
    catch { istek.current = false; setHata('Ses tanıma başlatılamadı.') }
  };

  // OTOMATIK BASLAT (kullanici: "dikte penceresi acilinca otomatik
  //   baslasin"): guvenli adres ve destekli tarayicida pencere acilir acilmaz
  //   dinler; degilse Baslat kapali kalir ve sebebi yazilidir.
  useEffect(() => {
    if (guvenli && destekli) baslat();
  }, []);   // yalniz acilista

  const durdur = () => {
    istek.current = false;
    olcerBirakildi.current = false;
    sesOlcumuKapat();
    try { taniyici.current?.stop() } catch { /* zaten durmuş */ }
    setDinliyor(false);
    setGecici('');
  };

  const degisenler = hedefler.filter(h => (metinler[h.ad] ?? '') !== (baslangic[h.ad] ?? ''));
  /** Degisen alanlari karta yazar ve pencereyi kapatir. */
  const aktar = () => {
    for (const h of degisenler) onYaz(h.ad, duzelt(metinler[h.ad] ?? ''));
    durdur();
    onKapat();
  };

  return (
    <Modal baslik={c('Dikte')} dar buyutmeYok onKapat={() => { durdur(); onKapat() }}
           alt={<>
             <button type="button" className="d bir" disabled={degisenler.length === 0} onClick={aktar}>
               ✓ {c('Karta aktar')}{degisenler.length ? ` (${degisenler.length})` : ''}
             </button>
             <button type="button" className="d" onClick={() => { durdur(); onKapat() }}>
               {c('Kapat')}
             </button>
           </>}>
      <div className="muayene-dikte">
        <p className="not">
          {c('Fare hangi alanın üstündeyse dikte oraya yazar. Ses tarayıcının tanıma hizmetinde çözülür, saklanmaz; metin "Karta aktar" demeden karta yazılmaz, kayıt Kaydet ile.')}
        </p>
        {!guvenli && <div className="hata-kutusu">{c('Dikte yalnız https ya da localhost adresinde çalışır.')}</div>}
        {guvenli && !destekli && (
          <div className="hata-kutusu">{c('Bu tarayıcı ses tanımayı desteklemiyor (Chrome / Edge kullanın).')}</div>
        )}
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="mdikte-arac">
          {!dinliyor ? (
            <button type="button" className="d bir" disabled={!guvenli || !destekli} onClick={baslat}>
              🎤 {c('Başlat')}
            </button>
          ) : (
            <button type="button" className="d teh" onClick={durdur}>⏹ {c('Durdur')}</button>
          )}
          {dinliyor && <span className="rozet hata md-kayit">● {c('Dinleniyor')}</span>}
          {/* SEVIYE GERCEK SESTEN: hareket etmiyorsa mikrofon duymuyor. */}
          {dinliyor && (
            <span className="md-seviye" title={c('Mikrofon seviyesi')}>
              <i style={{ width: `${Math.round(seviye * 100)}%` }} />
            </span>
          )}
        </div>
        {(cihazAdi || sonOlay) && (
          <div className="not md-tani">
            {cihazAdi && <>🎙 {cihazAdi}</>}
            {cihazAdi && sonOlay && ' · '}
            {sonOlay && <span title={c('Tanıma motorunun son olayı')}>{sonOlay}</span>}
          </div>
        )}
        {dongucuMu && (
          <div className="uyari-kutusu">
            Giriş cihazı <b>{cihazAdi}</b> bir mikrofon değil, sistem sesini geri
            döngüleyen sanal giriş. Tarayıcının KENDİ mikrofon seçimi Windows
            varsayılanını ezer: Chrome'da <b>chrome://settings/content/microphone</b>
            (Edge'de edge://settings/content/microphone) listesinden gerçek
            mikrofonu seçin, sayfayı yenileyin. Windows'ta da Ses › Kayıt'tan
            mikrofonu varsayılan yapın.
          </div>
        )}
        {hizmetIpucu && (
          <div className="uyari-kutusu">
            Mikrofon sesi alıyor ama tanıma hizmetinden metin gelmiyor. Windows'ta
            <b> Ayarlar › Gizlilik ve güvenlik › Konuşma › Çevrimiçi konuşma
            tanıma</b> kapalıysa tarayıcı hata vermeden susar; ağ engeli de aynı
            sonucu verir. Ayarı ya da mikrofonu yeni değiştirdiyseniz tarayıcıyı
            <b>tamamen</b> kapatıp açın (arka planda çalışmaya devam edebilir).
          </div>
        )}

        {hedefler.map(h => {
          const aktif = h.ad === hedef;
          return (
            <div key={h.ad} className={`md-alan${aktif ? ' aktif' : ''}`}
                 onMouseEnter={() => setHedef(h.ad)}>
              <div className="md-alan-bas">
                <b>{h.baslik}</b>
                {aktif && <span className="rozet mavi">🎤 {c('dikte buraya')}</span>}
              </div>
              <textarea rows={h.ad === 'karar' ? 4 : 3} value={metinler[h.ad] ?? ''}
                        aria-label={h.baslik}
                        placeholder={aktif ? c('Konuşun… "virgül", "nokta", "yeni satır" söylenebilir.') : ''}
                        onFocus={() => setHedef(h.ad)}
                        onChange={e => setMetinler(m => ({ ...m, [h.ad]: e.target.value }))} />
              {/* ANLIK METIN etkin alanin altinda: kesin sonuc duraklayinca gelir. */}
              {aktif && (gecici || dinliyor) && (
                <div className={`md-gecici${gecici ? ' var' : ''}`} aria-live="polite">
                  {gecici || c('Dinleniyor… duraklayınca metin alana geçer.')}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </Modal>
  );
}
