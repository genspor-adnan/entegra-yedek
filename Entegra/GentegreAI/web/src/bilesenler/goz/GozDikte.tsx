import { useEffect, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { DikteSozlugu } from '../../api/uclar/goz';
import { Modal } from '../Modal';
import { mesaj, metinSor } from '../mesaj';
import { dikteAyristir, duzelt, guvenliMi } from './dikteMotoru';

/**
 * DİKTE (705) — mockup `Ekranlar/Goz/goz_dikte.html`.
 *
 * <b>Yalnız METİN alanına yazar.</b> Görme, refraksiyon, GİB ve kodlu alanlar
 * (ICD, LOCS) kapalıdır: yanlış duyulan "yirmi altı / yirmi yedi" sessizce
 * tedavi değiştirir. Kapalı alanların listesi de sunucudan gelir — ekranın
 * kendi listesini tutması, bir gün birinin sessizce açılması demekti.
 *
 * <b>Hiçbir şey otomatik yazılmaz.</b> Tanınan metin önce düzeltilir (terim
 * sözlüğü, noktalama), hekim görür, onaylar; yazma işi çizimle ortak kapıdan
 * (`bulgu-metni`) geçer ve mevcut metni ezmez, sonuna ekler.
 *
 * <b>Ses tarayıcıda çözülür</b> (Web Speech API). Bu, sesin tarayıcının kendi
 * tanıma hizmetine gitmesi demektir; kurum bunu istemiyorsa dikte
 * kullanılmamalı ya da yerel bir tanıma hizmeti bağlanmalıdır. Ekran bunu
 * SAKLAMAZ, başlıkta yazar — çünkü hasta muayenesinin sesi söz konusu.
 * Ses kaydı hiçbir yerde saklanmaz; sunucuya yalnız onaylanmış metin gider.
 */

/** Tarayıcı tanıma arayüzünün kullandığımız kadarı. */
interface TanimaOlayi {
  resultIndex: number;
  results: ArrayLike<ArrayLike<{ transcript: string; confidence: number }> & { isFinal: boolean }>;
}
interface Taniyici {
  lang: string; continuous: boolean; interimResults: boolean;
  maxAlternatives?: number;
  start(): void; stop(): void;
  onresult: ((o: TanimaOlayi) => void) | null;
  onerror: ((o: { error: string }) => void) | null;
  onend: (() => void) | null;
  // TANI OLAYLARI: "kayıtta yazıyor ama yazmıyor" şikâyetini ayırmak için.
  //   start → motor açıldı · audiostart → ses akışı geldi ·
  //   speechstart → konuşma duyuldu · nomatch → duydu, anlamadı.
  onstart?: (() => void) | null;
  onaudiostart?: (() => void) | null;
  onsoundstart?: (() => void) | null;
  onspeechstart?: (() => void) | null;
  onspeechend?: (() => void) | null;
  onsoundend?: (() => void) | null;
  onaudioend?: (() => void) | null;
  onnomatch?: (() => void) | null;
}

/**
 * GÜVENLİ BAĞLAM ŞARTI. Tarayıcı ses tanımayı (ve mikrofonu) yalnız https ya
 * da localhost üzerinde açar. Düz http'de `start()` sessizce başlar, ekran
 * "kayıtta" der ve hiçbir şey gelmez - hekim konuşur, yazılmaz. Bu yüzden
 * düğme en baştan kapalı ve sebebi ekranda yazılı.
 */
const guvenliBaglam = () =>
  typeof window !== 'undefined' && window.isSecureContext === true;

function taniyiciYap(dil = 'tr-TR'): Taniyici | null {
  const p = window as unknown as { SpeechRecognition?: new () => Taniyici;
                                   webkitSpeechRecognition?: new () => Taniyici };
  const Sinif = p.SpeechRecognition ?? p.webkitSpeechRecognition;
  if (!Sinif) return null;
  const t = new Sinif();
  t.lang = dil;
  t.continuous = true;
  t.interimResults = true;
  return t;
}

interface DokumSatiri {
  saat: string; hedefAdi: string; metin: string; guven: number; durum: string;
}

export function GozDikte({ gozMuayeneId, onKapat, onTamam }: {
  gozMuayeneId: number;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [sozluk, setSozluk] = useState<DikteSozlugu | null>(null);
  const [dinliyor, setDinliyor] = useState(false);
  const [ham, setHam] = useState('');
  const [gecici, setGecici] = useState('');
  const [metin, setMetin] = useState('');
  const [hedef, setHedef] = useState('onSegment.kornea');
  const [goz, setGoz] = useState(1);
  const [dokum, setDokum] = useState<DokumSatiri[]>([]);
  const [hata, setHata] = useState('');
  const [sure, setSure] = useState(0);
  const [yaziyor, setYaziyor] = useState(false);
  const taniyici = useRef<Taniyici | null>(null);
  const destekli = useRef<boolean>(!!taniyiciYap());
  const guvenli = useRef<boolean>(guvenliBaglam());
  // DINLEME NIYETI: kullanıcı "dur" demedikçe açık kalır. Tanıyıcı kendi
  //   kendine kapanabiliyor (sessizlik, ağ, motorun kendi zaman aşımı);
  //   niyet ayrı tutulmazsa hekim iki cümle arasında sustuğunda dikte
  //   sessizce ölür ve konuşmaya devam eden hekim hiçbir şey yazılmadığını
  //   sonradan fark eder.
  const istek = useRef(false);
  const sonBaslangic = useRef(0);
  const [sessiz, setSessiz] = useState(false);
  // MİKROFON SEVİYESİ ayrı ölçülür: tanıma motoru sessiz kalınca sorunun
  //   mikrofonda mı (hiç ses gelmiyor) yoksa tanıma hizmetinde mi (ses var,
  //   metin yok) olduğunu ancak bu ayırır.
  const [seviye, setSeviye] = useState(0);
  const [sonOlay, setSonOlay] = useState('');
  // KONUŞULDU AMA METİN YOK: ses geliyor, tanıma hizmeti cevap vermiyor.
  //   Windows'ta "çevrimiçi konuşma tanıma" kapalıysa Edge/Chrome sessizce
  //   hiçbir sonuç döndürmez - hata da vermez. İpucu bunu söylemeli.
  const metinGeldi = useRef(false);
  const sesDuyuldu = useRef(false);
  const [hizmetIpucu, setHizmetIpucu] = useState(false);
  // DİL bir TEŞHİS anahtarı: Türkçe model sonuç üretmiyorsa İngilizce
  //   denemesi sorunu "motor mu, model mi" diye ikiye ayırır.
  const [dil, setDil] = useState('tr-TR');
  // ÖLÇER MİKROFONU ayrı bir akış açar. Bazı sürücüler mikrofonu tek
  //   uygulamaya verir ve o zaman TANIYICI sessizlik duyar. Konuşma
  //   algılanmazsa ölçer bırakılır ve tanıma ölçersiz yeniden denenir.
  const olcerBirakildi = useRef(false);
  // HANGİ CİHAZ DİNLENİYOR: Web Speech API cihaz seçtirmez, Windows'un
  //   VARSAYILAN giriş cihazını kullanır. Varsayılan "Stereo Karışımı" gibi
  //   bir ses DÖNGÜSÜ cihazıysa tanıyıcı sistem sesini dinler, mikrofonu
  //   değil: hekim konuşur, ekran "kayıtta" der, hiçbir şey gelmez.
  //   Yaşanmış vaka - artık cihaz adı ekranda ve döngü cihazı uyarılıyor.
  const [cihazAdi, setCihazAdi] = useState('');
  const dongucuMu = /stereo (mix|karışımı|karisimi)|what u hear|loopback|wave out|mix/i
    .test(cihazAdi);
  const sesDuzeni = useRef<{ ctx: AudioContext; akis: MediaStream; kare: number } | null>(null);

  const olay = (ad: string) => {
    setSonOlay(`${ad} · ${new Date().toLocaleTimeString('tr-TR')}`);
    if (ad === 'metin geldi') metinGeldi.current = true;
  };

  /** Mikrofon seviyesini ölçmeye başla (izin isteğini de bu tetikler). */
  const sesOlcumuAc = async () => {
    if (sesDuzeni.current) return true;
    try {
      const akis = await navigator.mediaDevices.getUserMedia({ audio: true });
      setCihazAdi(akis.getAudioTracks()[0]?.label ?? '');
      const ctx = new AudioContext();
      const kaynak = ctx.createMediaStreamSource(akis);
      const coz = ctx.createAnalyser();
      coz.fftSize = 512;
      kaynak.connect(coz);
      const tampon = new Uint8Array(coz.frequencyBinCount);
      const olc = () => {
        coz.getByteTimeDomainData(tampon);
        let enBuyuk = 0;
        for (const v of tampon) enBuyuk = Math.max(enBuyuk, Math.abs(v - 128));
        setSeviye(Math.min(1, enBuyuk / 40));
        if (sesDuzeni.current) sesDuzeni.current.kare = requestAnimationFrame(olc);
      };
      sesDuzeni.current = { ctx, akis, kare: 0 };
      olc();
      return true;
    } catch (h) {
      const ad = (h as { name?: string }).name ?? '';
      setHata(ad === 'NotAllowedError'
        ? 'Mikrofon izni verilmedi: adres çubuğundaki kilit simgesinden izin verin.'
        : ad === 'NotFoundError'
        ? 'Mikrofon bulunamadı: cihaz bağlı mı?'
        : `Mikrofon açılamadı (${ad || 'bilinmeyen'}).`);
      return false;
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

  useEffect(() => {
    void (async () => {
      try { setSozluk(await api.gozDikteSozluk()) } catch (h) { setHata(hataMetni(h)) }
    })();
    return () => {
      istek.current = false;
      sesOlcumuKapat();
      try { taniyici.current?.stop() } catch { /* zaten durmuş */ }
    };
  }, []);

  // SÜRE SAYACI: dikte açıkken geçen zaman, hekimin "ne kadardır
  //   konuşuyorum" sorusunun tek göstergesi - tanıma motoru sessizce
  //   durduğunda da sayaç durur, ekran "kayıtta" yalanını söylemez.
  useEffect(() => {
    if (!dinliyor) return;
    setSure(0);
    const s = setInterval(() => setSure(t => t + 1), 1000);
    return () => clearInterval(s);
  }, [dinliyor]);

  const sureMetni = `${String(Math.floor(sure / 60)).padStart(2, '0')}:`
                  + `${String(sure % 60).padStart(2, '0')}`;

  const hedefAdi = (kod: string) =>
    sozluk?.hedefler.find(h => h.kod === kod)?.ad ?? kod;

  /** Komutun ne yaptığını insan diline çevirir: "goz:1" -> "hedefi OD yapar". */
  const komutAciklama = (eylem: string) => {
    const [tur, deger = ''] = eylem.split(':');
    if (tur === 'goz') return deger === '1' ? 'hedefi OD yapar'
      : deger === '2' ? 'hedefi OS yapar' : 'her iki göz';
    if (tur === 'hedef') return `${hedefAdi(deger)} alanına atlar`;
    if (tur === 'noktalama') return `"${deger}" koyar`;
    if (tur === 'satir') return 'satır sonu';
    if (tur === 'sil') return 'son cümleyi siler';
    if (tur === 'onayla') return 'alana yazar';
    return eylem;
  };
  const gozGerekir = !!sozluk?.hedefler.find(h => h.kod === hedef)?.gozGerekir;

  /** Ham parçayı sözlükten geçir, komutları uygula, metni biriktir. */
  const parcaIsle = (parca: string, guven: number) => {
    const esik = sozluk?.guvenEsigi ?? 0.6;
    const saat = new Date().toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });

    if (!guvenliMi(guven, esik)) {
      // EŞİK ALTI YAZILMAZ ama GİZLENMEZ: hekim "söyledim ama yazmadı"
      //   dediğinde dökümde satırı görsün.
      setDokum(d => [{ saat, hedefAdi: '—', metin: parca, guven,
                       durum: 'atıldı (düşük güven)' }, ...d]);
      return;
    }

    setSessiz(false);
    // SÖZLÜK GELMEDİYSE METİN YİNE YAZILIR: terim düzeltmesi bir iyileştirme,
    //   önkoşul değil. Eskiden sözlük isteği düşerse tanınan her cümle
    //   sessizce çöpe gidiyordu - ekran "kayıtta" derken hiçbir şey olmuyordu.
    const sonuc = dikteAyristir(parca, sozluk ?? { terimler: [], komutlar: [] });
    for (const k of sonuc.komutlar) {
      if (k.tur === 'goz') setGoz(Number(k.deger));
      if (k.tur === 'hedef') setHedef(k.deger);
      if (k.tur === 'sil') setMetin(m => m.replace(/[^.!?\n]*[.!?]?\s*$/, '').trim());
      if (k.tur === 'onayla') void yaz();
    }
    if (sonuc.metin.trim())
      setMetin(m => duzelt(m ? `${m} ${sonuc.metin}` : sonuc.metin));
    setHam(h => `${h} ${parca}`.trim());
  };

  const basla = () => {
    setHata('');
    if (!guvenli.current) {
      setHata('Dikte için güvenli bağlantı gerekir (https ya da localhost). '
            + 'Bu sayfa düz http üzerinden açıldığı için tarayıcı mikrofonu '
            + 'kapatıyor; metni elle yazıp aynı onay akışıyla ekleyebilirsiniz.');
      return;
    }
    const t = taniyiciYap(dil);
    if (!t) {
      setHata('Bu tarayıcı ses tanımayı desteklemiyor: metni elle yazabilirsiniz.');
      return;
    }
    // Mikrofonu ÖNCE aç: izin penceresi böyle net çıkar ve seviye çubuğu
    //   tanıma motorundan bağımsız çalışır.
    if (!olcerBirakildi.current) void sesOlcumuAc();
    metinGeldi.current = false;
    sesDuyuldu.current = false;
    setHizmetIpucu(false);
    t.onstart = () => olay('motor açıldı');
    t.onaudiostart = () => {
      olay('ses akışı geldi');
      // 6 sn içinde ses/konuşma duyulmadıysa ÖLÇERİ BIRAK ve tanımayı
      //   ölçersiz yeniden başlat: mikrofonu iki yerden açmak bazı
      //   sürücülerde tanıyıcıya sessizlik dinletiyor.
      window.setTimeout(() => {
        if (!istek.current || metinGeldi.current || olcerBirakildi.current) return;
        if (sesDuyuldu.current) return;
        olcerBirakildi.current = true;
        sesOlcumuKapat();
        olay('ölçer bırakıldı, yeniden başlatılıyor');
        try { t.stop() } catch { /* zaten durmuş */ }
      }, 6000);
    };
    t.onsoundstart = () => { sesDuyuldu.current = true; olay('ses duyuldu') };
    t.onsoundend = () => olay('ses kesildi');
    t.onspeechend = () => olay('konuşma bitti');
    t.onaudioend = () => olay('ses akışı kapandı');
    t.onspeechstart = () => {
      olay('konuşma duyuldu');
      // Konuşma duyulduktan 10 sn sonra hâlâ metin yoksa hizmet sorunu.
      window.setTimeout(() => {
        if (istek.current && !metinGeldi.current) setHizmetIpucu(true);
      }, 10000);
    };
    t.onnomatch = () => olay('duydu, anlamadı');
    t.onresult = (o: TanimaOlayi) => {
      let araSonuc = '';
      for (let i = o.resultIndex; i < o.results.length; i++) {
        const r = o.results[i];
        const ilk = r[0];
        if (r.isFinal) { olay('metin geldi'); parcaIsle(ilk.transcript, ilk.confidence ?? 0) }
        else araSonuc += ilk.transcript;
      }
      if (araSonuc) setSessiz(false);
      setGecici(araSonuc);
    };
    t.onerror = (o: { error: string }) => {
      // SESSİZLİK HATA DEĞİLDİR. Tanıma motoru birkaç saniye ses duymazsa
      //   `no-speech` verir; hekim muayene sırasında zaten konuşmadan
      //   bakıyor olabilir. Kırmızı hata kutusu göstermek, çalışan bir
      //   şeyi bozuk göstermekti - şeritte "sessizlik" yazar, dinleme sürer.
      // `aborted` de kullanıcının kendi durdurması ya da yeniden
      //   başlatmanın yan ürünü.
      olay(`hata: ${o.error}`);
      if (o.error === 'no-speech') { setSessiz(true); return }
      if (o.error === 'aborted') return;

      istek.current = false;
      setHata(
        o.error === 'not-allowed' || o.error === 'service-not-allowed'
          ? 'Mikrofon izni verilmedi: tarayıcı adres çubuğundaki izin '
            + 'simgesinden mikrofona izin verin.'
        : o.error === 'audio-capture'
          ? 'Mikrofon bulunamadı: cihaz bağlı mı, başka bir uygulama '
            + 'kullanıyor mu?'
        : o.error === 'network'
          ? 'Tanıma hizmetine ulaşılamadı (ağ). Metni elle yazabilirsiniz.'
          : `Ses tanıma hatası: ${o.error}`);
      setDinliyor(false);
    };

    // KENDİLİĞİNDEN KAPANINCA YENİDEN BAŞLAT: tarayıcı `continuous` olsa da
    //   oturumu belli aralıklarla kapatıyor. Niyet açıksa sürdürülür; iki
    //   başlangıç arası 1 sn'den kısaysa durulur - yoksa izin reddi gibi
    //   kalıcı bir durumda saniyede onlarca kez denenirdi.
    t.onend = () => {
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
    setSessiz(false);
    try { t.start(); setDinliyor(true) } catch { setHata('Dikte başlatılamadı.') }
  };

  const dur = () => {
    istek.current = false;
    olcerBirakildi.current = false;
    sesOlcumuKapat();
    try { taniyici.current?.stop() } catch { /* zaten durmuş */ }
    setDinliyor(false);
    setSessiz(false);
    setGecici('');
  };

  const yaz = async () => {
    const yazilacak = metin.trim();
    if (!yazilacak) { setHata('Yazılacak metin yok.'); return }
    if (gozGerekir && goz !== 1 && goz !== 2) { setHata('Göz seçilmeli.'); return }
    setHata('');
    setYaziyor(true);
    try {
      const y = await api.gozBulguMetni(gozMuayeneId, { hedef, goz, metin: yazilacak, yontem: 1 });
      setDokum(d => [{
        saat: new Date().toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }),
        hedefAdi: y.hedefAdi, metin: yazilacak, guven: 1, durum: 'yazıldı',
      }, ...d]);
      setMetin('');
      setHam('');
      mesaj(y.aciklama);
      onTamam?.();
    } catch (h) { setHata(hataMetni(h)) } finally { setYaziyor(false) }
  };

  const terimEkle = async () => {
    const soylenen = await metinSor('Nasıl söylüyorsunuz?', '', 'Söyleniş');
    if (!soylenen) return;
    const yazilan = await metinSor(`"${soylenen}" ne yazılsın?`, '', 'Yazılan');
    if (!yazilan) return;
    try {
      await api.gozDikteTerim({ soylenen, yazilan, tur: 1, kisisel: true });
      setSozluk(await api.gozDikteSozluk());
      mesaj('Kişisel sözlüğünüze eklendi.');
    } catch (h) { setHata(hataMetni(h)) }
  };

  return (
    <Modal baslik="🎙 Dikte" onKapat={() => { dur(); onKapat() }}
           ustBilgi={dinliyor ? 'kayıtta — konuşun' : 'hazır'}
           alt={
             <>
               {dinliyor
                 ? <button className="d sil" onClick={dur}>⏹ Durdur</button>
                 : <button className="d" onClick={basla}
                           disabled={!guvenli.current || !destekli.current}
                           title={guvenli.current ? '' : 'https ya da localhost gerekir'}>
                     🎙 Dinlemeye başla
                   </button>}
               <button className="d onay" disabled={yaziyor || !metin.trim()}
                       onClick={() => void yaz()}>✔ Onayla ve alana yaz</button>
               <button className="d kapat-dugmesi"
                       onClick={() => { dur(); onKapat() }}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!guvenli.current && (
        <div className="uyari-kutusu">
          Bu sayfa <b>düz http</b> üzerinden açıldı. Tarayıcılar ses tanımayı ve
          mikrofonu yalnız <b>https</b> ya da <b>localhost</b> üzerinde açar —
          dikte bu adreste çalışmaz. Metni elle yazıp aynı onay akışıyla
          alanlara ekleyebilirsiniz.
        </div>
      )}
      {dongucuMu && (
        <div className="uyari-kutusu">
          Giriş cihazı <b>{cihazAdi}</b> görünüyor — bu bir mikrofon değil,
          sistem sesini geri döngüleyen sanal giriş. Tanıma motoru Windows'un
          <b> varsayılan giriş cihazını</b> kullanır ve cihaz seçtirmez:
          Ayarlar › Sistem › Ses › Giriş'ten gerçek mikrofonu varsayılan yapın,
          sonra dikteyi yeniden başlatın.
        </div>
      )}
      {hizmetIpucu && (
        <div className="uyari-kutusu">
          Mikrofon sesi alıyor ama tanıma hizmetinden metin gelmiyor. Windows'ta
          <b> Ayarlar › Gizlilik ve güvenlik › Konuşma › Çevrimiçi konuşma
          tanıma</b> kapalıysa tarayıcı sessizce sonuç döndürmez; ağ engeli de
          aynı sonucu verir. Metni elle yazıp aynı onay akışıyla
          ekleyebilirsiniz.
        </div>
      )}
      {guvenli.current && !destekli.current && (
        <div className="uyari-kutusu">
          Bu tarayıcı ses tanımayı desteklemiyor. Metni elle yazıp aynı
          onay akışıyla alana ekleyebilirsiniz.
        </div>
      )}

      {/* KAYIT ŞERİDİ (mockup `.kayitSerit`): ekran "dinliyorum" derken
          gerçekten dinliyor olmalı - tanıma motoru kendiliğinden durduğunda
          şerit de söner. Ses kaydı hiçbir yerde tutulmaz. */}
      <div className={`dikte-serit${dinliyor ? ' acik' : ''}${sessiz ? ' sessiz' : ''}`}>
        <span className="mik">{dinliyor ? '●' : '🎙'}</span>
        <b>{!dinliyor ? 'Hazır' : sessiz ? 'DİNLİYOR (sessizlik)' : 'KAYITTA'}</b>
        {dinliyor && (
          // ÇUBUKLAR GERÇEK SESTEN: süs animasyonu, mikrofon kapalıyken de
          //   "çalışıyor" izlenimi verirdi. Hareket etmiyorsa mikrofon
          //   duymuyor demektir.
          <span className="dalga">
            {[0.35, 0.6, 0.85, 0.5, 1, 0.7, 0.4, 0.8, 0.95, 0.55, 0.3, 0.65,
              0.9, 0.45, 0.75, 0.25].map((k, i) => (
              <i key={i} style={{ height: Math.max(3, Math.round(seviye * k * 22)) }} />
            ))}
          </span>
        )}
        <span className="sayac">{sureMetni}</span>
        {dinliyor && (
          <span className="sonuk" title="tanıma motorunun son olayı">
            {sonOlay || 'olay bekleniyor…'}
            {!olcerBirakildi.current && ` · seviye %${Math.round(seviye * 100)}`}
          </span>
        )}
        {cihazAdi && (
          <span className="sonuk" title="tanımanın dinlediği giriş cihazı">
            🎧 {cihazAdi}
          </span>
        )}
        <select value={dil} disabled={dinliyor} title="tanıma dili (teşhis için)"
                onChange={e => setDil(e.target.value)}>
          <option value="tr-TR">Türkçe</option>
          <option value="en-US">English (deneme)</option>
        </select>
        <span className="sonuk">
          Hedef: <b>{hedefAdi(hedef)}</b>
          {gozGerekir && <> · <span className={goz === 1 ? 'od' : 'os'}>
            {goz === 1 ? 'OD' : 'OS'}</span></>}
        </span>
        <span className="sonuk sag-not">
          {guvenli.current
            ? 'Ses tarayıcının tanıma hizmetinde çözülür; kayıt saklanmaz.'
            : 'Güvenli bağlantı yok (http): tarayıcı mikrofonu açmıyor.'}
        </span>
      </div>

      <div className="dikte-duzen">
        <div className="dikte-sol">
          <div className="pb">Hedef alan</div>
          {(sozluk?.hedefler ?? []).map(h => (
            <button key={h.kod} type="button"
                    className={`dikte-alan${hedef === h.kod ? ' secili' : ''}`}
                    onClick={() => setHedef(h.kod)}>
              {h.ad}
              {h.gozGerekir && <span className="sp">OD · OS</span>}
            </button>
          ))}

          <div className="pb">Dikteye kapalı</div>
          {(sozluk?.kapali ?? []).map(k => (
            <div key={k.ad} className="dikte-alan kilit">🔒 {k.ad}
              <span className="sp">{k.neden}</span></div>
          ))}
          <div className="dikte-not">
            Sayısal ölçüm ve kodlu alan sesle doldurulmaz: yanlış duyulan
            bir sayı sessizce tedavi değiştirir. Bu alanlar elle ya da
            cihazdan gelir.
          </div>
        </div>

        <div className="dikte-orta">
          <div className="pb">Canlı transkript <span className="sp">ham</span></div>
          <div className="dikte-transkript">
            {ham || <span className="sonuk">Mikrofonu açıp konuşun ya da metni elle yazın.</span>}
            {gecici && <span className="gecici"> {gecici}</span>}
            {dinliyor && <span className="imlec" />}
          </div>

          <div className="pb">Düzeltilmiş metin
            <span className="sp">terim sözlüğü · noktalama uygulandı</span></div>
          <textarea className="dikte-metin" rows={5} value={metin}
                    placeholder="Onaylanacak metin burada."
                    onChange={e => setMetin(e.target.value)} />

          <div className="dikte-arac">
            <label className="alan">
              <span className="etiket">Göz</span>
              <select value={goz} disabled={!gozGerekir}
                      onChange={e => setGoz(Number(e.target.value))}>
                <option value={1}>OD · Sağ</option>
                <option value={2}>OS · Sol</option>
              </select>
            </label>
            <span className="sonuk">
              Hedef: <b>{hedefAdi(hedef)}</b> · mevcut metin ezilmez, sonuna eklenir
            </span>
            <button className="d" onClick={() => { setMetin(''); setHam('') }}>🗑 Temizle</button>
          </div>

          <div className="pb">Oturum dökümü</div>
          <div className="dikte-dokum">
            <table>
              <thead><tr><th>Saat</th><th>Hedef</th><th>Metin</th>
                <th className="orta">Güven</th><th className="orta">Durum</th></tr></thead>
              <tbody>
                {dokum.map((d, i) => (
                  <tr key={i}>
                    <td>{d.saat}</td><td>{d.hedefAdi}</td><td>{d.metin}</td>
                    <td className="orta">{d.guven ? d.guven.toFixed(2) : '—'}</td>
                    <td className="orta">
                      <span className={`rozet${d.durum === 'yazıldı' ? ' yesil' : ' kirmizi'}`}>
                        {d.durum}
                      </span>
                    </td>
                  </tr>
                ))}
                {dokum.length === 0 && (
                  <tr><td colSpan={5} className="sonuk">Henüz bir şey yazılmadı.</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        <div className="dikte-sag">
          <div className="pb">Sesli komutlar</div>
          {(sozluk?.komutlar ?? []).map(k => (
            <div key={k.id} className="dikte-komut">
              <b>"{k.soylenen}"</b>
              <span className="sp">{komutAciklama(k.eylem)}</span>
            </div>
          ))}

          <div className="pb">Sık cümleler</div>
          {(sozluk?.cumleler ?? []).map(c => (
            <button key={c.id} type="button" className="dikte-cumle"
                    onClick={() => setMetin(m => duzelt(m ? `${m} ${c.yazilan}` : c.yazilan))}>
              {c.yazilan}
            </button>
          ))}

          <div className="pb">Terim sözlüğü <span className="sp">kurum + kişisel</span></div>
          {(sozluk?.terimler ?? []).slice(0, 12).map(t => (
            <div key={t.id} className="dikte-komut">
              "{t.soylenen}" → <b>{t.yazilan}</b>
              <span className="sp">{t.kapsam === 1 ? 'kurum' : 'kişisel'}</span>
            </div>
          ))}
          <button className="d" onClick={() => void terimEkle()}>＋ Sözlüğe terim ekle</button>
          <div className="dikte-not">Ses kaydı saklanmaz; sunucuya yalnız
            onayladığınız metin gider.</div>
        </div>
      </div>
    </Modal>
  );
}
