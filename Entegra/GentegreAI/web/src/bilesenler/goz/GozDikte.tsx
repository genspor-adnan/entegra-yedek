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
  start(): void; stop(): void;
  onresult: ((o: TanimaOlayi) => void) | null;
  onerror: ((o: { error: string }) => void) | null;
  onend: (() => void) | null;
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
  // DINLEME NIYETI: kullanıcı "dur" demedikçe açık kalır. Tanıyıcı kendi
  //   kendine kapanabiliyor (sessizlik, ağ, motorun kendi zaman aşımı);
  //   niyet ayrı tutulmazsa hekim iki cümle arasında sustuğunda dikte
  //   sessizce ölür ve konuşmaya devam eden hekim hiçbir şey yazılmadığını
  //   sonradan fark eder.
  const istek = useRef(false);
  const sonBaslangic = useRef(0);
  const [sessiz, setSessiz] = useState(false);

  useEffect(() => {
    void (async () => {
      try { setSozluk(await api.gozDikteSozluk()) } catch (h) { setHata(hataMetni(h)) }
    })();
    return () => {
      istek.current = false;
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
    if (!sozluk) return;
    const esik = sozluk.guvenEsigi ?? 0.6;
    const saat = new Date().toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });

    if (!guvenliMi(guven, esik)) {
      // EŞİK ALTI YAZILMAZ ama GİZLENMEZ: hekim "söyledim ama yazmadı"
      //   dediğinde dökümde satırı görsün.
      setDokum(d => [{ saat, hedefAdi: '—', metin: parca, guven,
                       durum: 'atıldı (düşük güven)' }, ...d]);
      return;
    }

    setSessiz(false);
    const sonuc = dikteAyristir(parca, sozluk);
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
    const t = taniyiciYap();
    if (!t) {
      setHata('Bu tarayıcı ses tanımayı desteklemiyor: metni elle yazabilirsiniz.');
      return;
    }
    t.onresult = (o: TanimaOlayi) => {
      let araSonuc = '';
      for (let i = o.resultIndex; i < o.results.length; i++) {
        const r = o.results[i];
        const ilk = r[0];
        if (r.isFinal) parcaIsle(ilk.transcript, ilk.confidence ?? 0);
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
                 : <button className="d" onClick={basla}>🎙 Dinlemeye başla</button>}
               <button className="d onay" disabled={yaziyor || !metin.trim()}
                       onClick={() => void yaz()}>✔ Onayla ve alana yaz</button>
               <button className="d" onClick={() => { dur(); onKapat() }}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!destekli.current && (
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
          <span className="dalga">
            {[8, 15, 22, 12, 26, 18, 9, 20, 24, 14, 7, 17, 23, 11, 19, 6]
              .map((y, i) => <i key={i} style={{ height: y }} />)}
          </span>
        )}
        <span className="sayac">{sureMetni}</span>
        <span className="sonuk">
          Hedef: <b>{hedefAdi(hedef)}</b>
          {gozGerekir && <> · <span className={goz === 1 ? 'od' : 'os'}>
            {goz === 1 ? 'OD' : 'OS'}</span></>}
        </span>
        <span className="sonuk sag-not">
          Ses tarayıcının tanıma hizmetinde çözülür; kayıt saklanmaz.
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
