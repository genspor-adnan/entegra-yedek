import { useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import type { KalemFiyati, Secim, Tetkik } from './istemTipleri';

/**
 * RADYOLOJI ISTEMINDE TETKIK SECIMI VE FIYATI.
 *
 * `IstemModali` govdesinde arama, secili liste, modalite agaci, dort ozet
 * hesabi ve fiyat cozumleme yan yana duruyordu. Hepsi ayni soruya hizmet
 * ediyor: "hangi tetkikler, kaca?" - bu yuzden tek kancada toplandi.
 */
export function useIstemSecimi(opts: {
  acik: boolean;
  hastaId: number;
  odeyenKurumId: number | null;
  tetkikler: Tetkik[];
  /** Randevudan gelen on secili tetkik (317). */
  onSeciliHizmetId?: number | null;
}) {
  const { acik, hastaId, odeyenKurumId, tetkikler, onSeciliHizmetId } = opts;

  const [ara, setAra] = useState('');
  const [secili, setSecili] = useState<Secim[]>([]);
  const [fiyatlar, setFiyatlar] = useState<Record<number, KalemFiyati>>({});

  /**
   * RANDEVUNUN TETKIKI (317) acilista secili gelir: hasta o tetkik icin gun
   * almisti, kabul masasinin listeden yeniden bulmasi hem yavas hem hataya
   * acik. Tetkikler yuklendikten sonra bir kez uygulanir - kullanici sonra
   * cikarabilir ya da yenisini ekleyebilir.
   */
  const onSecimUygulandi = useRef(false);
  useEffect(() => { if (!acik) onSecimUygulandi.current = false }, [acik]);
  useEffect(() => {
    if (!acik || !onSeciliHizmetId || onSecimUygulandi.current) return;
    const t = tetkikler.find(x => x.id === onSeciliHizmetId);
    if (!t) return;
    onSecimUygulandi.current = true;
    setSecili(s => (s.some(x => x.tetkik.id === t.id) ? s
      : [...s, { tetkik: t, oncelik: 1, kontrast: t.varsayilanKontrast ?? 0 }]));
  }, [acik, onSeciliHizmetId, tetkikler]);

  // FIYAT: secili tetkikler / odeyen kurum degistikce yeniden cozulur.
  //   Kurum degisince kampanya ve sozlesme listesi de degisir (302) -
  //   ekrandaki tutar kaydedilecek tutarla ayni kalmali.
  useEffect(() => {
    if (!acik) return;
    let birak = false;
    void (async () => {
      // BAZ LISTE: kampanya -> SOZLESME -> cari -> varsayilan sirasi (302)
      //   yalniz bu ucta cozuluyor; kalem fiyatina listeyi VERMEZSEK kurum
      //   sozlesmesindeki liste devreye girmez ve ekran 0 gosterirdi.
      let listeId: number | null = null;
      try {
        listeId = (await api.belgeVarsayilanListe(19, hastaId, odeyenKurumId)).listeId;
      } catch { /* liste cozulemezse kalem kendi kuralina duser */ }
      const yeni: Record<number, KalemFiyati> = {};
      for (const sec of secili) {
        try {
          const f = await api.fiyatKalem({ hizmetId: sec.tetkik.id },
                                         { tarafId: hastaId, kurumId: odeyenKurumId,
                                           listeId });
          yeni[sec.tetkik.id] = {
            liste: Number(f.bazFiyat ?? 0),
            tutar: Number(f.fiyat ?? f.bazFiyat ?? 0),
            kdv: Number(sec.tetkik.kdv ?? 0),
          };
        } catch { /* fiyat cozulemezse satir 0 gorunur, kabul engellenmez */ }
      }
      if (!birak) setFiyatlar(yeni);
    })();
    return () => { birak = true };
  }, [acik, secili, odeyenKurumId, hastaId]);

  /** Mockup'taki tutar kutusu: liste, indirim, KDV, genel toplam. */
  const toplam = useMemo(() => {
    let liste = 0, net = 0, kdv = 0;
    secili.forEach(sec => {
      const f = fiyatlar[sec.tetkik.id];
      if (!f) return;
      liste += f.liste;
      net += f.tutar;
      kdv += (f.tutar * f.kdv) / 100;
    });
    return { liste, net, kdv, indirim: liste - net, genel: net + kdv };
  }, [secili, fiyatlar]);

  /** Protokoldeki PERSONEL uyarilari (314) - hastaya degil, kabul masasina. */
  const uyarilar = useMemo(() => tekilMetinler(secili, s => s.tetkik.ozelUyari,
                                               s => s.tetkik.kod), [secili]);

  /** Secili tetkiklerin hazirlik talimatlari - AYNI metin tekrar edilmez. */
  const talimatlar = useMemo(
    () => tekilMetinler(secili, s => s.tetkik.hazirlik,
                        s => s.tetkik.modaliteAdi || s.tetkik.ad), [secili]);

  /** Modaliteye gore gruplu, aramayla suzulmus tetkik agaci. */
  const agac = useMemo(() => {
    const k = ara.trim().toLocaleLowerCase('tr');
    const suz = k
      ? tetkikler.filter(t => t.ad.toLocaleLowerCase('tr').includes(k)
                           || t.kod.toLocaleLowerCase('tr').includes(k))
      : tetkikler;
    const gruplar = new Map<string, Tetkik[]>();
    suz.forEach(t => {
      const g = t.modaliteAdi || 'Diğer';
      if (!gruplar.has(g)) gruplar.set(g, []);
      gruplar.get(g)!.push(t);
    });
    return [...gruplar.entries()];
  }, [tetkikler, ara]);

  const ekle = (t: Tetkik) => {
    if (secili.some(s => s.tetkik.id === t.id)) return;
    // KONTRAST varsayilani cekim protokolunden (314) gelir: "kontrastli mi"
    //   sorusunun dogru cevabi tetkikin protokolunde yazilidir, kabul masasi
    //   her seferinde secmesin.
    setSecili(x => [...x, { tetkik: t, oncelik: 1,
                            kontrast: Number(t.varsayilanKontrast ?? 0) }]);
  };
  const cikar = (id: number) => setSecili(x => x.filter(s => s.tetkik.id !== id));
  const degistir = (id: number, y: Partial<Secim>) =>
    setSecili(x => x.map(s => (s.tetkik.id === id ? { ...s, ...y } : s)));

  return { ara, setAra, secili, setSecili, fiyatlar,
           toplam, uyarilar, talimatlar, agac, ekle, cikar, degistir };
}

/** Ayni metni iki kez gostermeyen baslik+metin listesi. */
function tekilMetinler(
  secili: Secim[],
  metinAl: (s: Secim) => string | undefined,
  baslikAl: (s: Secim) => string,
) {
  const gorulen = new Set<string>();
  const liste: { baslik: string; metin: string }[] = [];
  secili.forEach(sec => {
    const metin = (metinAl(sec) ?? '').trim();
    if (!metin || gorulen.has(metin)) return;
    gorulen.add(metin);
    liste.push({ baslik: baslikAl(sec), metin });
  });
  return liste;
}
