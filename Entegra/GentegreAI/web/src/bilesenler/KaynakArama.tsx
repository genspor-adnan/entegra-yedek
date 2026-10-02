import { useEffect, useRef, useState, type ReactNode } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { Modal } from './Modal';
import { c } from '../dil/ceviri';

/**
 * KAYNAK ARAMA PENCERESİ — bir liste kaynağında (ICD, ilaç, tetkik…) arayıp
 * tek satır seçtiren genel pencere.
 *
 * <b>Neden ayrı pencere:</b> binlerce satırlı katalogda combo kullanılamaz
 * (ICD ~20 bin satır), tek satırlık "önce yaz sonra listeden seç" akışı ise
 * hekimi iki adıma zorluyordu. Pencere yazdıkça arar - kod ya da adın bir
 * parçası yeter.
 *
 * <b>Arama SUNUCUDA:</b> filtre liste sözleşmesiyle gider (`kod` başlar /
 * `ad` içerir); ekran katalog taşımaz, yetkisiz kaynak zaten hiç dönmez.
 */

type Satir = Record<string, unknown>;

export function KaynakArama({ kaynak, baslik, kodAlani = 'kod', adAlani = 'ad',
                              ekKosul, onceki, oncekiBaslik = 'Öncekiler',
                              sablon, sablonBaslik = 'Şablon', yz,
                              acikKalir = false, ustSecimler, onSec, onKapat }: {
  kaynak: string;
  baslik: string;
  kodAlani?: string;
  adAlani?: string;
  /** Kaynağa özel sabit süzgeç (ör. yalnız aktif kayıtlar). */
  ekKosul?: { alan: string; op: 'esit'; deger: unknown };
  /** Ekrana özel üçüncü liste (ör. bu HASTANIN önceki tanıları). */
  onceki?: () => Promise<{ kod: string; ad: string }[]>;
  oncekiBaslik?: string;
  /** Bölüm / doktor şablonunun hazır listesi (931: şablonun sık tanıları). */
  sablon?: () => Promise<{ kod: string; ad: string }[]>;
  sablonBaslik?: string;
  /**
   * YZ ÖNERİSİ (kullanıcı): hekime olası tanı listesi. Satırlar gerekçe ve
   * olasılıkla çizilir; ekleme yine hekimin seçimiyle. `not`: kırmızı bayrak,
   * eksik bilgi ve "karar hekimindir" uyarısı.
   */
  yz?: () => Promise<{ satirlar: { kod: string; ad: string; olasilik?: string; gerekce?: string }[];
                       notlar: string[]; uyari: string }>;
  /**
   * ÇOK SEÇİM (kullanıcı: "tanı çok seçimli olabilir.. her seçimde ekran
   * kapanmasın"): satır tıklamak yalnız İŞARETLER, pencere açık kalır;
   * "Seçilenleri Ekle" (ya da çift tık) ekler ve KAPATIR ("ekle deyince
   * kapanmalı"). Hata alan satır işaretli kalır, pencere açık kalır.
   */
  acikKalir?: boolean;
  /** Arama kutusunun ÜSTÜNDE çizilen seçiciler (ör. tanı türü / taraf) -
      seçimle birlikte gönderilecek değerleri çağıran tutar. */
  ustSecimler?: ReactNode;
  onSec(satir: Satir): void | Promise<unknown>;
  onKapat(): void;
}) {
  const [metin, setMetin] = useState('');
  /** Hazır listeler: '' arama · 'sik' · 'son' · 'onceki' (kullanıcı). */
  // 'son' listesi UÇTA duruyor ama düğmesi yok (kullanıcı): sık kullanılan
  //   zaten son kullanılanı kapsıyordu, iki düğme aynı işi yapıyordu.
  const [kip, setKip] = useState<'' | 'sik' | 'onceki' | 'sablon' | 'yz'>('');
  /** YZ yanıtının notları (kırmızı bayrak, eksik bilgi) ve uyarısı. */
  const [yzNot, setYzNot] = useState<{ notlar: string[]; uyari: string } | null>(null);
  const [satirlar, setSatirlar] = useState<Satir[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const kutu = useRef<HTMLInputElement | null>(null);
  /** Bu pencerede eklenen kodlar (yalnız `acikKalir`). Ref: toplu eklemede
      döngü güncel listeyi görsün. */
  const [eklenen, setEklenen] = useState<string[]>([]);
  const eklenenRef = useRef<string[]>([]);
  const [gonderilen, setGonderilen] = useState<string | null>(null);
  /**
   * İŞARETLİ SATIRLAR (kullanıcı: "ICD arama gridine de check deseni" +
   * "birini seçince diğerleri kalkmasın.. istediğim kadar seçeyim.. kendim
   * istersem kaldırayım"): tık satırın işaretini açar/kapatır, diğerleri
   * KALIR (stok aramadaki tekli seçimden farklı); Shift tık aralığı ekler.
   * Soldaki kutu aynı işi görür. Çift tık hemen ekler,
   * "Seçilenleri Ekle" işaretlileri sırayla ekler. Kod ile tutulur - arama
   * değişince de işaret korunur; bu yüzden işaretliler listenin ÜSTÜNDE çip
   * olarak HEP görünür (kullanıcı: "yine çok ekledi" - önceki listede
   * işaretlenen, ekranda görünmeyen satır da ekleniyordu). Çipteki ✕ kaldırır.
   */
  const [isaretli, setIsaretli] = useState<Map<string, Satir>>(() => new Map());
  const [capa, setCapa] = useState(0);
  const [topluEkleniyor, setTopluEkleniyor] = useState(false);
  const kodu = (r: Satir) => String(r[kodAlani] ?? '');

  /** Tek satırı ekler; başarıda true. Aynı kod ikinci kez gönderilmez. */
  const ekle = async (r: Satir) => {
    const kod = kodu(r);
    if (eklenenRef.current.includes(kod)) return true;
    setGonderilen(kod);
    try {
      await onSec(r);
      eklenenRef.current = [...eklenenRef.current, kod];
      setEklenen(eklenenRef.current);
      return true;
    } catch { return false /* hata mesajını çağıran gösterir; satır işaretlenmez */ }
    finally { setGonderilen(null) }
  };

  /** Çift tık: satırı ekler ve pencereyi KAPATIR (ekle = bitti, kullanıcı);
      hata alırsa açık kalır. */
  const sec = async (r: Satir) => {
    if (!acikKalir) { onSec(r); return }
    if (gonderilen !== null || topluEkleniyor) return;
    if (await ekle(r)) onKapat();
    else kutu.current?.focus();
  };

  const isaretDegistir = (r: Satir) => setIsaretli(m => {
    const n = new Map(m);
    const k = kodu(r);
    n.has(k) ? n.delete(k) : n.set(k, r);
    return n;
  });

  const satirTikla = (e: { shiftKey: boolean }, i: number, r: Satir) => {
    if (e.shiftKey) {
      // Shift: çapadan bu satıra aralığı EKLER (mevcut işaretler kalır).
      const [a, b] = capa <= i ? [capa, i] : [i, capa];
      setIsaretli(m => {
        const n = new Map(m);
        for (const x of satirlar.slice(a, b + 1)) n.set(kodu(x), x);
        return n;
      });
      return;
    }
    setCapa(i);
    isaretDegistir(r);
  };

  /** İşaretlileri SIRAYLA ekler (ilk tanı ana, sonrakiler ek - sıra önemli)
      ve pencereyi KAPATIR (kullanıcı: "ekle deyince kapanmalı"). Hata alan
      varsa pencere açık kalır, yalnız o satırlar işaretli durur. */
  const isaretlileriEkle = async () => {
    if (topluEkleniyor || isaretli.size === 0) return;
    setTopluEkleniyor(true);
    const kalan = new Map<string, Satir>();
    try {
      for (const [k, r] of isaretli) if (!(await ekle(r))) kalan.set(k, r);
      setIsaretli(kalan);
    } finally { setTopluEkleniyor(false) }
    if (kalan.size === 0) onKapat();
    else kutu.current?.focus();
  };

  useEffect(() => { kutu.current?.focus() }, []);

  /**
   * SIK / SON / ÖNCEKİ listeleri (461): poliklinikte tanı dağılımı dardır -
   * hekimin yazdığı ilk beş kod işin çoğunu görür. Aramadan önce bunları
   * göstermek hem yazmayı kaldırır hem de AYNI hastalığın hep AYNI kodla
   * yazılmasını sağlar; iki farklı ICD ile yazılan hastalık raporu ve
   * e-Nabız paketini ikiye böler.
   */
  useEffect(() => {
    if (kip === '') return;
    let iptal = false;
    setYukleniyor(true);
    void (async () => {
      try {
        if (kip === 'yz') {
          // YZ: modele gider (kontör) - yalnız düğmeye basılınca, bir kez.
          setYzNot(null);
          const y = yz ? await yz() : { satirlar: [], notlar: [], uyari: '' };
          if (!iptal) { setSatirlar(y.satirlar as unknown as Satir[]); setYzNot({ notlar: y.notlar, uyari: y.uyari }) }
        } else if (kip === 'onceki' || kip === 'sablon') {
          const kaynagi = kip === 'onceki' ? onceki : sablon;
          const liste = kaynagi ? await kaynagi() : [];
          if (!iptal) setSatirlar(liste as unknown as Satir[]);
        } else {
          const y = await api.katalogKullanilan(kaynak);
          if (!iptal) setSatirlar(y.sik as unknown as Satir[]);
        }
        if (!iptal) setHata(null);
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
      finally { if (!iptal) setYukleniyor(false) }
    })();
    return () => { iptal = true };
  // yz BAĞIMLILIK DEĞİL: satır içi fonksiyon her çizimde yenilenir; bağımlı
  //   olsaydı her çizim modeli yeniden çağırıp kontör düşerdi.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kip, kaynak, onceki, sablon]);

  // DEBOUNCE: her tuşta sorgu atmak 20 bin satırlık katalogda sunucuyu
  //   gereksiz yorar; 300 ms yazma duraklaması yeterli.
  useEffect(() => {
    const anahtar = metin.trim();
    if (anahtar.length < 2) { if (kip === '') setSatirlar([]); return }
    let iptal = false;
    const zaman = setTimeout(() => {
      setYukleniyor(true);
      void (async () => {
        try {
          const y = await api.liste(kaynak, {
            sayfa: 1, boyut: 50,
            filtre: {
              op: 'and',
              kosullar: [
                ...(ekKosul ? [ekKosul] : []),
                { op: 'or', kosullar: [
                  { alan: kodAlani, op: 'baslar', deger: anahtar },
                  { alan: adAlani, op: 'icerir', deger: anahtar },
                ] },
              ],
            },
          });
          if (!iptal) { setSatirlar(y.satirlar as Satir[]); setHata(null) }
        } catch (h) { if (!iptal) setHata(hataMetni(h)) }
        finally { if (!iptal) setYukleniyor(false) }
      })();
    }, 300);
    return () => { iptal = true; clearTimeout(zaman) };
  }, [metin, kaynak, kodAlani, adAlani, ekKosul, kip]);

  return (
    // TAM EKRAN OLMAZ (kullanici: "ICD arama ekrani max olmasin"): kart tam
    //   ekrandayken kayitli tercih arama penceresini de ekrana yayiyordu.
    <Modal baslik={baslik} dar enUst buyutmeYok onKapat={onKapat}
           alt={<>
             {acikKalir && eklenen.length > 0 && (
               <span className="not" style={{ marginRight: 'auto' }}>
                 ✓ {eklenen.length} {c('kayıt eklendi')}
               </span>
             )}
             {acikKalir && isaretli.size > 0 && (
               <button type="button" className="b" disabled={topluEkleniyor}
                       onClick={() => void isaretlileriEkle()}>
                 ✓ {c('Seçilenleri Ekle')} ({isaretli.size})
               </button>
             )}
             <button type="button" className="d" onClick={onKapat}>{c('Kapat')}</button>
           </>}>
      <div className="kaynak-arama">
        {ustSecimler && <div className="kaynak-arama-secim">{ustSecimler}</div>}
        <div className="kaynak-arama-arac">
          <span className="ara-kutu">
            <span>🔍</span>
            <input type="search" ref={kutu} value={metin} placeholder={c('Kod ya da ad…')}
                   onChange={e => { setMetin(e.target.value); setKip('') }} />
          </span>
          <button type="button" className={`d${kip === 'sik' ? ' bir' : ''}`}
                  onClick={() => { setMetin(''); setKip(kip === 'sik' ? '' : 'sik') }}>
            ⭐ Sık Kullandıklarım
          </button>
          {yz && (
            <button type="button" className={`d yz-dugme${kip === 'yz' ? ' bir' : ''}`}
                    title={c('Girilen şikâyet, hikâye, bulgu, yaş ve cinsiyetten olası tanıları önerir. Ad, soyad ve kimlik no gönderilmez.')}
                    onClick={() => { setMetin(''); setKip(kip === 'yz' ? '' : 'yz') }}>
              🤖 {c('YZ Önerisi')}
            </button>
          )}
          {sablon && (
            <button type="button" className={`d${kip === 'sablon' ? ' bir' : ''}`}
                    onClick={() => { setMetin(''); setKip(kip === 'sablon' ? '' : 'sablon') }}>
              📋 {sablonBaslik}
            </button>
          )}
          {onceki && (
            <button type="button" className={`d${kip === 'onceki' ? ' bir' : ''}`}
                    onClick={() => { setMetin(''); setKip(kip === 'onceki' ? '' : 'onceki') }}>
              📁 {oncekiBaslik}
            </button>
          )}
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}
        {!hata && kip === 'yz' && yzNot && (
          <div className="rk-bant mavi yz-not">
            <b>🤖 {c(yzNot.uyari || 'YZ önerisidir; tanı kararı hekimindir.')}</b>
            {yzNot.notlar.map(n => <div key={n}>{n}</div>)}
          </div>
        )}
        {!hata && kip === '' && metin.trim().length < 2 && (
          <p className="not">En az iki harf/rakam yazın ya da hazır listelerden seçin.</p>
        )}
        {!hata && satirlar.length === 0 && (kip !== '' || metin.trim().length >= 2) && (
          <p className="not">{yukleniyor ? 'Yükleniyor…' : 'Kayıt yok.'}</p>
        )}

        {acikKalir && isaretli.size > 0 && (
          <div className="kaynak-arama-secilen" aria-label={c('Seçilenler')}>
            <b>{c('Eklenecek')} ({isaretli.size}):</b>
            {[...isaretli.entries()].map(([k, r]) => (
              <span key={k} className="kaynak-arama-cip" title={String(r[adAlani] ?? '')}>
                {k}{r[adAlani] ? ` · ${String(r[adAlani])}` : ''}
                <button type="button" aria-label={`${k} ${c('kaldır')}`}
                        onClick={() => setIsaretli(m => { const n = new Map(m); n.delete(k); return n })}>✕</button>
              </span>
            ))}
            <button type="button" className="d kucuk" onClick={() => setIsaretli(new Map())}>
              {c('Tümünü kaldır')}
            </button>
          </div>
        )}
        {acikKalir && satirlar.length > 0 && (
          <p className="not kaynak-arama-ipucu">
            {c('İstediğiniz kadar tanıyı işaretleyin (tekrar tık işareti kaldırır), sonra "Seçilenleri Ekle". Çift tık tek tanıyı hemen ekler.')}
          </p>
        )}
        {satirlar.length > 0 && (
          <table className="detay-tablo">
            <thead><tr>
              {acikKalir && (
                <th style={{ width: 32 }} className="hiza-orta">
                  <input type="checkbox" title={c('Listedekilerin tümünü seç / bırak')}
                    checked={satirlar.every(r => isaretli.has(kodu(r)))}
                    onChange={e => setIsaretli(m => {
                      const n = new Map(m);
                      for (const r of satirlar)
                        e.target.checked ? n.set(kodu(r), r) : n.delete(kodu(r));
                      return n;
                    })} />
                </th>
              )}
              <th style={{ width: 120 }}>Kod</th><th>Ad</th>
            </tr></thead>
            <tbody>
              {satirlar.map((r, i) => {
                const kod = String(r[kodAlani] ?? '');
                const ekli = acikKalir && eklenen.includes(kod);
                const isa = acikKalir && isaretli.has(kod);
                return (
                <tr key={i} className={`tiklanir${isa ? ' isaretli' : ''}${ekli ? ' eklendi' : ''}`}
                    aria-selected={isa || undefined}
                    onMouseDown={e => { if (acikKalir && e.shiftKey) e.preventDefault() }}
                    onClick={e => { acikKalir ? satirTikla(e, i, r) : void sec(r) }}
                    onDoubleClick={() => { if (acikKalir) void sec(r) }}>
                  {acikKalir && (
                    <td className="hiza-orta">
                      <input type="checkbox" checked={isa}
                        onClick={e => e.stopPropagation()}
                        onChange={() => { setCapa(i); isaretDegistir(r) }} />
                    </td>
                  )}
                  <td><b>{ekli ? '✓ ' : gonderilen === kod ? '… ' : ''}{kod}</b></td>
                  <td>{String(r[adAlani] ?? '')}
                    {r.olasilik != null && (
                      <span className={`rozet ${r.olasilik === 'yuksek' ? 'hata' : r.olasilik === 'dusuk' ? 'gri' : 'uyari'} yz-olasilik`}>
                        {r.olasilik === 'yuksek' ? c('Yüksek') : r.olasilik === 'dusuk' ? c('Düşük') : c('Orta')}
                      </span>
                    )}
                    {r.gerekce ? <div className="yz-gerekce">{String(r.gerekce)}</div> : null}</td>
                </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
    </Modal>
  );
}
