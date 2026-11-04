import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { ayarSayi } from '../../api/ayarlar';
import { hataMetni } from '../../api/sozlesme';
import type { MrzSonucu } from '../../api/uclar/kimlik';
import { c } from '../../dil/ceviri';
import { Modal } from '../Modal';
import { mrzOku, mrzSatirlari } from './mrzOcr';
import { aktarimPaketi, eslesendenMevcut, karsilastir, type KarsilastirmaSatiri, type MevcutDegerler, type MrzAktarim } from './mrzAktarim';

/**
 * KİMLİĞİ OKUT PENCERESİ (1255, mockup Ekranlar/Kayıt Kabul/kimlik_mrz_okut.html ②③).
 *
 * Sol: kamera (kartın arka yüzü çerçeveye alınır, alt bant OCR'a gider) ya da dosya / tarayıcı görüntüsü ya da
 * yapıştırılan / okuyucu cihazdan gelen MRZ metni. Hepsi aynı çözücüye düşer: `POST /api/kimlik/mrz-coz`. Sağ: ham
 * satırlar, çözülen alanlar - kayıtlı hasta / açık kart ile karşılaştırma, kullanıcı farkları tek tek onaylar.
 *
 * Görüntü SAKLANMAZ, sunucuya GİTMEZ (OCR tarayıcıda). Ham MRZ da saklanmaz.
 */
export type KimlikKipi = 'kamera' | 'dosya' | 'metin';

export interface KimlikOkutPenceresiOzellikleri {
  onKapat(): void;
  /**
   * Açık kart (hasta kartından açıldıysa): karşılaştırma tabanı o karttır. Yoksa (başvuru araması) taban kayıtlı
   * hastadır.
   */
  mevcut?: { id: number | 'yeni'; degerler: MevcutDegerler };
  /** Alanlar HEDEF karta aktarılır: açık karta ya da (arama bağlamında) açılacak yeni karta. */
  onAktar(paket: MrzAktarim): void;
  /** Bu kimlikle kayıtlı BAŞKA hasta var: açılır / seçilir, farklar paketle taşınır. */
  onHastaAc?(hastaId: number, paket: MrzAktarim, adSoyad: string): void;
  /** Uyruk kod → ad (kart kod listesinden); mevcut değer tabloda adla görünsün. */
  uyrukAdlari?: Record<string, string>;
}

const ADIMLAR = ['Kartı göster', 'MRZ okundu', 'Kontrol haneleri', 'Hasta eşleşmesi', 'Karta aktar'];

export function KimlikOkutPenceresi({ onKapat, mevcut, onAktar, onHastaAc, uyrukAdlari }: KimlikOkutPenceresiOzellikleri) {
  const [izin, setIzin] = useState<{ kamera: boolean; dosya: boolean; esik: number } | null>(null);
  const [kip, setKip] = useState<KimlikKipi>('kamera');
  const [metin, setMetin] = useState('');
  const [guven, setGuven] = useState<number | null>(null);
  const [satirlar, setSatirlar] = useState<string[]>([]);
  const [sonuc, setSonuc] = useState<MrzSonucu | null>(null);
  const [hata, setHata] = useState('');
  const [mesgul, setMesgul] = useState(false);
  const [kameraDurum, setKameraDurum] = useState('');
  const [secimler, setSecimler] = useState<Record<string, boolean>>({});
  const video = useRef<HTMLVideoElement>(null);
  const akis = useRef<MediaStream | null>(null);
  const tarama = useRef<number | null>(null);
  const okunuyor = useRef(false);

  // Ayar (kayit.kimlik_okutma): 1 kamera · 2 tarayıcı / dosya · 3 ikisi; ilk kip izinli olan.
  useEffect(() => {
    void (async () => {
      const okutma = await ayarSayi('kayit.kimlik_okutma', 3);
      const esik = await ayarSayi('kayit.ocr_esik', 90);
      const kamera = okutma === 1 || okutma === 3;
      const dosya = okutma === 2 || okutma === 3;
      setIzin({ kamera, dosya, esik });
      setKip(kamera ? 'kamera' : dosya ? 'dosya' : 'metin');
    })();
  }, []);

  /** Satırları sunucuya çözdürür; geçerliyse tarama durur. */
  const coz = useCallback(async (sat: string[], ocrGuven: number | null) => {
    if (sat.length < 2) return false;
    setMesgul(true); setHata('');
    try {
      const y = await api.mrzCoz(sat.join('\n'));
      setSatirlar(y.satirlar?.length ? y.satirlar : sat);
      setGuven(ocrGuven);
      setSonuc(y);
      setSecimler({});
      return y.gecerli;
    } catch (h) { setHata(hataMetni(h)); return false }
    finally { setMesgul(false) }
  }, []);

  // ------------------------------------------------------------- kamera --
  const kameraDurdur = useCallback(() => {
    if (tarama.current) { window.clearInterval(tarama.current); tarama.current = null }
    akis.current?.getTracks().forEach(t => t.stop()); akis.current = null;
    if (video.current) video.current.srcObject = null;
  }, []);

  const kameraBaslat = useCallback(async () => {
    kameraDurdur(); setKameraDurum(c('Kamera açılıyor…')); setSonuc(null); setSatirlar([]);
    try {
      const s = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment', width: { ideal: 1920 }, height: { ideal: 1080 } }, audio: false });
      akis.current = s;
      if (video.current) { video.current.srcObject = s; await video.current.play() }
      setKameraDurum(c('Kartın ARKA yüzünü çerçeveye tutun - okuma otomatik'));
      tarama.current = window.setInterval(() => void kare(), 1300);
    } catch (h) {
      setKameraDurum(''); setHata(c('Kamera açılamadı: ') + hataMetni(h) + ' ' + c('Dosyadan ya da MRZ metnini yapıştırarak devam edin.'));
    }
    async function kare() {
      const v = video.current;
      if (!v || okunuyor.current || v.videoWidth === 0) return;
      okunuyor.current = true;
      try {
        // Çerçeve: genişliğin %11-89'u, yüksekliğin %19-81'i (mockup .kart); MRZ bandı kartın alt %40'ı.
        const kx = v.videoWidth * 0.11, kw = v.videoWidth * 0.78, ky = v.videoHeight * 0.19, kh = v.videoHeight * 0.62;
        const o = await mrzOku(v, { x: kx, y: ky + kh * 0.58, w: kw, h: kh * 0.42 });
        if (o.satirlar.length >= 2) {
          setKameraDurum(`${o.satirlar.length} ${c('satır okundu')} · ${c('OCR güveni')} %${o.guven}`);
          // Güven 0 = motor güven vermedi (beyaz listeli okuma) - eşik uygulanmaz, kontrol haneleri karar verir.
          if ((o.guven === 0 || o.guven >= (izin?.esik ?? 90)) && await coz(o.satirlar, o.guven)) kameraDurdur();
        } else setKameraDurum(c('MRZ aranıyor… kartı yaklaştırın, yansımayı giderin'));
      } catch (h) { setHata(c('OCR çalıştırılamadı: ') + hataMetni(h)); kameraDurdur() }
      finally { okunuyor.current = false }
    }
  }, [coz, izin, kameraDurdur]);

  useEffect(() => {
    if (izin && kip === 'kamera' && izin.kamera && !sonuc?.gecerli) void kameraBaslat();
    else kameraDurdur();
    return kameraDurdur;
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kip, izin]);

  // -------------------------------------------------------------- dosya --
  const dosyaSec = async (d: File | undefined) => {
    if (!d) return;
    setMesgul(true); setHata(''); setSonuc(null);
    try {
      const url = URL.createObjectURL(d);
      try {
        const im = new Image();
        await new Promise<void>((cozul, red) => { im.onload = () => cozul(); im.onerror = () => red(new Error(c('Görüntü okunamadı'))); im.src = url });
        const o = await mrzOku(im);
        if (o.satirlar.length < 2) { setHata(c('Görüntüde MRZ satırı bulunamadı - kartın arka yüzünü / pasaportun alt kenarını net ve düz tarayın.')); setSatirlar(mrzSatirlari(o.metin)); return }
        if (o.guven > 0 && o.guven < (izin?.esik ?? 90)) setHata(`${c('OCR güveni düşük')} (%${o.guven} < %${izin?.esik ?? 90}) - ${c('yeniden tarayın ya da metni yapıştırın.')}`);
        await coz(o.satirlar, o.guven);
      } finally { URL.revokeObjectURL(url) }
    } catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  };

  // -------------------------------------------------------------- metin --
  const metinCoz = () => void coz(mrzSatirlari(metin), null);

  // ------------------------------------------------------ karşılaştırma --
  const eslesen = sonuc?.eslesen ?? null;
  const mevcutId = mevcut?.id;
  /** Eşleşen hasta açık kartın kendisi mi. */
  const ayniKart = !!eslesen && typeof mevcutId === 'number' && eslesen.id === mevcutId;
  const baskaHasta = !!eslesen && !ayniKart;
  const taban: MevcutDegerler | null = baskaHasta ? eslesendenMevcut(eslesen!) : mevcut?.degerler ?? null;
  const satirlarK: KarsilastirmaSatiri[] = useMemo(() => sonuc ? karsilastir(sonuc, taban, uyrukAdlari) : [],
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [sonuc, baskaHasta, mevcutId]);
  const secili = (r: KarsilastirmaSatiri) => secimler[r.anahtar] ?? r.al;
  const paket = () => aktarimPaketi(sonuc!, satirlarK.map(r => ({ ...r, al: secili(r) })), baskaHasta ? eslesen!.id : null);

  const adim = !sonuc ? (satirlar.length ? 1 : 0) : !sonuc.gecerli ? 2 : 3;
  const engel = sonuc?.engellendi === true;
  const birincil = !sonuc?.gecerli ? null
    : baskaHasta ? { metin: `👤 ${c('Hastayı Aç ve Farkları Uygula')}`, is: () => onHastaAc?.(eslesen!.id, paket(), `${eslesen!.ad} ${eslesen!.soyad}`.trim()) }
    : mevcut ? { metin: `✔ ${c('Karta Aktar')}`, is: () => onAktar(paket()) }
    : { metin: `＋ ${c('Yeni Hasta (dolu)')}`, is: () => onAktar(paket()) };

  const yenidenOkut = () => { setSonuc(null); setSatirlar([]); setGuven(null); setHata(''); setMetin(''); if (kip === 'kamera') void kameraBaslat() };

  return (
    <Modal baslik={`📷 ${c('Kimliği Okut')}${sonuc?.bicim ? ` · ${sonuc.bicim === 'TD3' ? c('Pasaport (TD-3)') : sonuc.bicim === 'TD1' ? c('Kimlik Kartı (TD-1)') : 'TD-2'}` : ''}`}
           ekSinif="kart-orta" enUst onKapat={() => { kameraDurdur(); onKapat() }}
           alt={<>
             <button type="button" className="d" onClick={yenidenOkut} disabled={mesgul}>↺ {c('Yeniden Okut')}</button>
             <span style={{ marginLeft: 'auto' }} />
             <button type="button" className="d" onClick={() => { kameraDurdur(); onKapat() }}>{c('Vazgeç')}</button>
             {birincil && (
               <button type="button" className="d bir" disabled={mesgul || engel} title={engel ? sonuc?.uyarilar?.[0] : undefined}
                       onClick={() => { kameraDurdur(); birincil.is() }}>{birincil.metin}</button>
             )}
           </>}>
      <div className="mrz-adim">
        {ADIMLAR.map((a, i) => <span key={a} className={`a${i < adim ? ' bitti' : i === adim ? ' simdi' : ''}`}>{i + 1} {c(a)}</span>)}
      </div>
      <div className="mrz-kip">
        {izin?.kamera && <button type="button" className={`d${kip === 'kamera' ? ' bir' : ''}`} onClick={() => setKip('kamera')}>📷 {c('Kamera')}</button>}
        {izin?.dosya && <button type="button" className={`d${kip === 'dosya' ? ' bir' : ''}`} onClick={() => setKip('dosya')}>📁 {c('Dosyadan / tarayıcıdan')}</button>}
        <button type="button" className={`d${kip === 'metin' ? ' bir' : ''}`} onClick={() => setKip('metin')}>⌨ {c('MRZ metnini yapıştır')}</button>
        {guven != null && guven > 0 && <span className="rozet gri" style={{ marginLeft: 'auto' }}>{c('OCR güveni')} %{guven}</span>}
      </div>
      {hata && <div className="hata-kutusu mrz-kutu" style={{ margin: '0 10px' }}>{hata}</div>}
      <div className="mrz-iki">
        <div>
          {kip === 'kamera' && (
            <div className="mrz-kamera">
              <video ref={video} muted playsInline />
              <div className="kart"><div className="mrzbant" /></div>
              <div className="ipucu">{kameraDurum}</div>
            </div>
          )}
          {kip === 'dosya' && (
            <div className="mrz-dosya">
              <input type="file" accept="image/*" disabled={mesgul} onChange={e => void dosyaSec(e.target.files?.[0])} />
              <div className="not">{c('Kimlik kartının arka yüzü ya da pasaportun fotoğraflı sayfası - düz, net, 300 dpi. Görüntü sunucuya gitmez.')}</div>
            </div>
          )}
          {kip === 'metin' && (
            <div className="mrz-metin">
              <textarea rows={3} value={metin} spellCheck={false} placeholder={'I<TURA12B345675<<<<<<<<<<<<<<<\n9001011M3012316TUR100000001462\nYILMAZ<<AHMET<<<<<<<<<<<<<<<<<'}
                        onChange={e => setMetin(e.target.value)} />
              <div className="not">{c('MRZ okuyucu cihaz klavye gibi yazar: imleç kutudayken kartı okutun ya da satırları yapıştırın.')}</div>
              <button type="button" className="d bir" disabled={mesgul || mrzSatirlari(metin).length < 2} onClick={metinCoz}>{c('Çöz')}</button>
            </div>
          )}
          {satirlar.length > 0 && (
            <>
              <div className="kbas">{c('Ham MRZ')}</div>
              <pre className={`mrz-ham${sonuc && !sonuc.gecerli ? ' hata' : sonuc?.gecerli ? ' ok' : ''}`}>{satirlar.join('\n')}</pre>
            </>
          )}
          {sonuc && !sonuc.gecerli && <div className="uyari-kutusu mrz-kutu">{sonuc.hatalar.join(' ')} {c('Yeniden okutun.')}</div>}
          {sonuc?.uyarilar?.map(u => <div key={u} className={`${sonuc.engellendi ? 'hata-kutusu' : 'uyari-kutusu'} mrz-kutu`}>⚠ {u}</div>)}
        </div>
        <div>
          {sonuc && (
            <>
              <div className="kbas">{c('Çözülen alanlar')}</div>
              <table className="mrz-tablo">
                <thead><tr><th>{c('Al')}</th><th>{c('Alan')}</th><th>MRZ</th><th>{baskaHasta ? c('Kayıtlı hasta') : mevcut ? c('Karttaki') : c('Kayıtlı')}</th><th>{c('Sonuç')}</th></tr></thead>
                <tbody>
                  {satirlarK.map(r => (
                    <tr key={r.anahtar} className={r.durum === 'fark' ? 'fark' : ''}>
                      <td><input type="checkbox" checked={secili(r)} disabled={r.bozuk || !r.mrz || engel}
                                 onChange={e => setSecimler(s => ({ ...s, [r.anahtar]: e.target.checked }))} /></td>
                      <td>{c(r.etiket)}</td>
                      <td className={r.bozuk ? 'bozuk' : ''}>{r.mrzGoster || '—'}</td>
                      <td className="sl">{r.mevcutGoster || '—'}</td>
                      <td>{r.bozuk ? <span className="rozet hata">{c('Kontrol tutmadı')}</span>
                        : r.durum === 'ayni' ? <span className="rozet ok">{c('Aynı')}</span>
                        : r.durum === 'fark' ? <span className="rozet uyari">{c('Farklı')}</span>
                        : r.durum === 'dolacak' ? <span className="rozet mavi">{c('Dolacak')}</span>
                        : <span className="rozet gri">—</span>}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {baskaHasta && (
                <div className="bilgi-kutusu mrz-kutu">ℹ {c('Bu kimlikle kayıtlı hasta var')}: <b>{eslesen!.ad} {eslesen!.soyad} · {eslesen!.kod}</b>
                  {eslesen!.sonBasvuru ? ` · ${c('son başvuru')} ${String(eslesen!.sonBasvuru).slice(8, 10)}.${String(eslesen!.sonBasvuru).slice(5, 7)}.${String(eslesen!.sonBasvuru).slice(0, 4)}` : ''}.
                  {' '}{c('"Hastayı Aç" kartı açar; işaretli farklar karta yazılır, kaydetmeden önce kontrol edilir.')}</div>
              )}
              {!baskaHasta && !mevcut && sonuc.gecerli && (
                <div className="bilgi-kutusu mrz-kutu">ℹ {c('Bu numarayla kayıtlı hasta yok - "Yeni Hasta" kartı alanlar dolu açılır. Ad / soyad MRZ\'de büyük ASCII gelir; T.C. vatandaşında MERNİS gerçek harfleri getirir.')}</div>
              )}
            </>
          )}
          {!sonuc && <div className="not" style={{ padding: 10 }}>{c('MRZ: kimlik kartının arka yüzündeki / pasaportun alt kenarındaki 2-3 satırlık makinece okunur bölge. Her sayısal alanın kontrol hanesi vardır; tutmayan alan kırmızı çizilir ve karta aktarılmaz.')}</div>}
        </div>
      </div>
    </Modal>
  );
}
