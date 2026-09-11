import { useEffect, useState } from 'react';
import { api } from '../../../api/istemci';
import { para } from '../../bicim';
import { MUSTEHAKLIK } from './alanlar';

/**
 * SECILI HASTA SERIDI (298, mockup "hasta" bloku): kabul boyunca ekranda
 * kalir - memur hastayi dogruladigini her an gorsun. Alanlar hasta
 * kaynagindan (taraf + taraf_hasta + varsayilan adres) tek istekle gelir.
 *
 * Mockup'taki ALERJI / KRONIK uyari cubugu YOK: o veriyi tutan bir tablo
 * henuz yok, uydurma bilgi gostermek yaniltici olurdu. Yerine gercek veriden
 * "son basvuru" uyarisi cizilir.
 */
export function HastaSeridi({ tarafId, mustehaklik, protokolNo, kilitli, acikBelge,
                              kurumAdi, acikBorc, onAra, onYeniHasta }: {
  tarafId?: number | null;
  /** BELGENIN odeyen kurumu (kullanici): serit hastanin sigortasini degil,
      bu basvuruyu odeyecek kurumu gosterir - ikisi farkli olabilir. */
  kurumAdi?: string;
  /** Bu BASVURUNUN acik borcu = ucretlendirme genel toplami - tahsilat.
      Verilmezse hastanin genel acik bakiyesi gosterilir. */
  acikBorc?: number;
  /**
   * ACIK BELGE (495, kullanici: "belge kesilmedi rozeti yerine dönüşmeyen
   * tutarı gösteren Açık Belge"): kovalarin faturaya/tahakkuka daha
   * cevrilmemis kismi. Rozet "kesildi mi" diyordu; sorulan "ne kadari kaldi".
   * Sunucudan gelir (belge.acikBelgeTutari) - istemci toplamaz.
   */
  acikBelge?: number | null;
  /** Belgenin SGK mustehaklik durumu (299) - sigortanin yanina rozet. */
  mustehaklik?: number | null;
  /** Belge numarasi - mockupta arama satirinin son alani. */
  protokolNo?: string;
  kilitli?: boolean;
  /** Arama penceresini acar; kutulara yazilan metin ON-DOLGU olarak gecer. */
  onAra?(metin: string): void;
  onYeniHasta?(): void;
}) {
  const [h, setH] = useState<Record<string, unknown> | null>(null);
  /**
   * ARAMA SATIRI kutulari (mockup, kullanici: "butonlarin altinda tcno, hasta
   * no, ad soyad, protokolno, ara buton, yeni hasta kaydi buton"). Secili hasta
   * varsa onun bilgileriyle dolu gelir; memur uzerine yazip Ara'ya (ya da
   * Enter'a) basinca BASKA hastayi arar.
   */
  const [tc, setTc] = useState('');
  const [dosyaNo, setDosyaNo] = useState('');
  const [adSoyad, setAdSoyad] = useState('');

  useEffect(() => {
    if (!tarafId) { setH(null); setTc(''); setDosyaNo(''); setAdSoyad(''); return }
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('hasta', {
          sayfa: 1, boyut: 1,
          filtre: { alan: 'id', op: 'esit', deger: tarafId },
        });
        if (iptal) return;
        const s = y.satirlar[0] ?? null;
        setH(s);
        setTc(String(s?.vkno ?? ''));
        setDosyaNo(String(s?.kod ?? ''));
        setAdSoyad(String(s?.unvan ?? ''));
      } catch { if (!iptal) setH(null) }
    })();
    return () => { iptal = true };
  }, [tarafId]);

  const ad = String(h?.unvan ?? '');
  const bas = ad.split(/\s+/).filter(Boolean).slice(0, 2)
                .map(x => x[0]?.toLocaleUpperCase('tr') ?? '').join('');
  /* Cinsiyet seritte IKON + TEK HARF (kullanici): "Erkek"/"Kadın" hucrede
     yer kapliyordu, ikon tek bakista okunuyor. Kayitsizsa hic yazilmaz. */
  const cinsiyetAdi = String(h?.cinsiyetAdi ?? '');
  const cinsiyet = cinsiyetAdi.startsWith('E') ? '♂ E'
                 : cinsiyetAdi.startsWith('K') ? '♀ K' : '';
  const borc = acikBorc != null ? acikBorc : Number(h?.acikBorc ?? 0);
  const dogum = String(h?.dogumTarihi ?? '').slice(0, 10);
  const yas = h?.yas != null && h.yas !== '' ? `${h.yas} y` : '';

  /**
   * Ara: memurun DEGISTIRDIGI kutuyla arar (T.C. > dosya no > ad). Kutular
   * secili hastanin bilgileriyle dolu geldigi icin dokunulmamis degeri arama
   * metni saymak yanlis olurdu - ustelik T.C. MASKELI gosterilir
   * ("111******10"), onunla arama hicbir sey bulmaz. Hicbiri degismemisse
   * pencere bos acilir (tum liste).
   */
  const ara = () => {
    const degisen = [[tc, h?.vkno], [dosyaNo, h?.kod], [adSoyad, h?.unvan]]
      .map(([kutu, kayitli]) => String(kutu ?? '').trim() === String(kayitli ?? '').trim()
        ? '' : String(kutu ?? '').trim())
      .find(Boolean);
    onAra?.(degisen ?? '');
  };
  const enter = (e: React.KeyboardEvent) => { if (e.key === 'Enter') { e.preventDefault(); ara() } };

  // F3 = Ara (mockup butonunun etiketi). Tarayicinin "sayfada bul-sonraki"
  //   davranisi engellenir; kilitli belgede kisayol da calismaz.
  useEffect(() => {
    if (kilitli) return;
    const tus = (e: KeyboardEvent) => {
      if (e.key !== 'F3') return;
      e.preventDefault();
      ara();
    };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kilitli, tc, dosyaNo, adSoyad, h]);

  return (
    <>
      {/* 1) HASTA ARAMA SATIRI (mockup): arac cubugunun altinda, bandin
             ustunde. PROTOKOL VERILINCE KAYBOLUR (kullanici): basvuru
             acildiktan sonra hasta degismez - degismesi gerekiyorsa basvuru
             iptal edilip yenisi acilir, satir o zaman geri gelir. */}
      {!protokolNo && (
      <div className="hasta-arama">
        <label className="alan">
          <span className="etiket">T.C. Kimlik No</span>
          <input value={tc} disabled={kilitli} onKeyDown={enter}
                 onChange={e => setTc(e.target.value)} />
        </label>
        <label className="alan">
          <span className="etiket">Hasta No</span>
          <input value={dosyaNo} disabled={kilitli} onKeyDown={enter}
                 onChange={e => setDosyaNo(e.target.value)} />
        </label>
        <label className="alan genis">
          <span className="etiket">Ad Soyad</span>
          <input value={adSoyad} disabled={kilitli} onKeyDown={enter}
                 onChange={e => setAdSoyad(e.target.value)} />
        </label>
        {/* Protokol no BELGENIN numarasi - aranmaz, kayitta atanir. Satir
            zaten yalniz protokol YOKKEN cizildigi icin hep bos gorunur;
            numara verilince alan Basvuru sekmesinde okunur. */}
        <label className="alan">
          <span className="etiket">Protokol No</span>
          <input value="" readOnly placeholder="(kaydedince atanacak)" />
        </label>
        <button type="button" className="d bir" onClick={ara}
                disabled={kilitli}>🔍 Ara (F3)</button>
        <button type="button" className="d" onClick={() => onYeniHasta?.()}
                disabled={kilitli}>✚ Yeni Hasta Kaydı</button>
      </div>
      )}

      {/* 2) SECILI HASTA BANDI - hasta secilene kadar cizilmez. */}
      {tarafId ? (
    <div className="hasta-serit">
      <span className="avatar">{bas || '—'}</span>
      <span className="hs">
        <span className="k">Hasta</span>
        <span className="v">{ad || '—'}</span>
      </span>
      <span className="hs">
        <span className="k">T.C. / Dosya No</span>
        <span className="v">{String(h?.vkno ?? '—')} · {String(h?.kod ?? '—')}</span>
      </span>
      <span className="hs">
        <span className="k">Doğum / Cinsiyet</span>
        <span className="v">
          {[dogum ? dogum.split('-').reverse().join('.') : '',
            cinsiyet, yas].filter(Boolean).join(' · ') || '—'}
        </span>
      </span>
      {/* ODEYEN KURUM (kullanici): eski "Sigorta" hucresi hastanin kayitli
          sigortasini yaziyordu; kabul memurunun gormesi gereken bu basvuruyu
          ODEYECEK kurum. Mustehaklik BELGEYE ait (her basvuruda yeniden
          sorgulanir), kuruma degil - o yuzden rozet disaridan gelir. */}
      <span className="hs">
        <span className="k">Ödeyen Kurum</span>
        <span className="v">
          {kurumAdi || String(h?.sigortaAdi ?? '') || '—'}
          {mustehaklik != null && mustehaklik > 0 && (
            <span className={`rozet ${MUSTEHAKLIK[mustehaklik]?.sinif ?? ''}`}>
              {MUSTEHAKLIK[mustehaklik]?.ad}
            </span>
          )}
        </span>
      </span>
      {/* Telefon ve son basvuru seritte YOK (kullanici): hasta zaten secilmis
          durumda - ikisi de arama penceresinde ise yarar, kabul ekraninda yer
          kaplar. Kalan hucreler seride esit araliklarla dagitilir. */}
      {/* ACIK TAHSILAT saga yaslanir (mockup): kabul memuru "tahsilat gerekiyor
          mu" sorusunu tek bakista gorsun. Deger BU BASVURUNUN farkidir
          (ucretlendirme genel toplami - tahsilat, kullanici) ve ucret/tahsilat
          girildikce ANINDA degisir; disaridan gelmezse hastanin genel acik
          bakiyesine duser. */}
      <span className="hs sag">
        {/* Isaret hucrenin ADINI da degistirir (kullanici): ucret > tahsilat
            ise KIRMIZI "Açık Tahsilat", tahsilat > ucret ise YESIL "Alacaklı"
            (hasta lehine bakiye - iade/mahsup gerekir), esitse notr siyah. */}
        <span className="k">{borc < 0 ? 'Alacaklı' : 'Açık Tahsilat'}</span>
        <span className={`v ${borc > 0 ? 'teh' : borc < 0 ? 'olumlu' : ''}`}>
          {para.format(Math.abs(borc))} ₺
        </span>
      </span>
      {/* ACIK BELGE, acik tahsilatin yaninda (kullanici): "belge kesilmedi"
          rozeti yalniz evet/hayir diyordu - burada KALAN TUTAR yazar, sifirsa
          belge tamamen kesilmis demektir. */}
      {acikBelge != null && (
        <span className="hs sag">
          <span className="k">Açık Belge</span>
          <span className={`v ${Number(acikBelge) > 0 ? 'teh' : 'olumlu'}`}>
            {para.format(Number(acikBelge))} ₺
          </span>
        </span>
      )}
    </div>
      ) : null}
    </>
  );
}

// ============================================================ BASVURU ====
