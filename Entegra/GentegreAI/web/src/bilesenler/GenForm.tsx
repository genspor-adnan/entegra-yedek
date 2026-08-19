import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import {
  ApiHatasi,
  type KartAlanMeta, type KartDetayMeta, type KartMetaYaniti, type KartYetkisi,
} from '../api/sozlesme';
import { GenDetayTablo, type DetayDurumu, bosDetay, detayFarki } from './GenDetayTablo';

interface Props {
  kaynak: string;
  id: number | 'yeni';
  baslik?: string;
  onKapat?(): void;
  onKaydedildi?(id: number): void;
  /** Mockup'ta olup backend'i henuz olmayan sekmeler (or. "UTS Bilgileri") - "yakinda" gosterilir. */
  yerTutucuSekmeler?: string[];
  /** "Genel" sekmesinde alt-bolum kutularinin YANINA mockup'taki gibi bos "Resim" kutusu ekler. */
  resimYerTutucu?: boolean;
}

/** Modal sarmalayici — mockup'taki .kaperde / .kawin duzeni. */
function Modal({ baslik, ustBilgi, ustSerit, sekmeBar, alt, onKapat, children }: {
  baslik: string;
  ustBilgi?: React.ReactNode;
  ustSerit?: React.ReactNode;
  sekmeBar?: React.ReactNode;
  alt: React.ReactNode;
  onKapat?(): void;
  children: React.ReactNode;
}) {
  useEffect(() => {
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') onKapat?.() };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
  }, [onKapat]);

  return (
    <div className="kaperde" onMouseDown={e => { if (e.target === e.currentTarget) onKapat?.() }}>
      <div className="kawin genis" onMouseDown={e => e.stopPropagation()}>
        <div className="kabas">
          <span>{baslik}</span>
          {ustBilgi}
          <span className="kapt">Esc ile kapanir</span>
        </div>
        {/* Mockup: Kaydet/Sil/Yazdir/Kapat baslikla idstrip ARASINDA arac cubugu (alt degil). */}
        <div className="katoolbar">{alt}</div>
        {ustSerit}
        {sekmeBar}
        <div className="kagov">{children}</div>
      </div>
    </div>
  );
}

/** Kart ici sekme: alan grubu, detay tablosu, ya da henuz baglanmamis yer tutucu. */
type SekmeTanimi =
  | { tur: 'grup'; anahtar: string; baslik: string; alanlar: KartAlanMeta[] }
  | { tur: 'detay'; anahtar: string; baslik: string; detay: KartDetayMeta }
  | { tur: 'yerTutucu'; anahtar: string; baslik: string };

const detaySekmeAnahtari = (detayAd: string) => `d:${detayAd}`;
const grupSekmeAnahtari = (grupAd: string) => `g:${grupAd}`;

/** Sekme DEGIL, ust seritte sabit gorunen grup (mockup idstrip). */
const KIMLIK_GRUP = 'Kimlik';

type Deger = string | number | boolean | null;

/**
 * Kart sozlesmesini (§3) tuketen genel form.
 *
 *  - Alan listesi, etiketler, zorunluluk ve uzunluk sinirlari SUNUCUDAN gelir
 *    (/alanlar). Yetkisiz alan hic donmedigi icin arayuzde gizleme mantigi yok.
 *  - Kaydetmede `surum` geri gonderilir; baskasi degistirmisse sunucu 409 doner ve
 *    kullaniciya "guncel hali al" secenegi sunulur (§1.3).
 *  - Alan hatalari (`alanlar[]`) ilgili girdinin altina yazilir.
 *  - Detaylar FARK olarak gonderilir (eklenen / degisen / silinen), tam liste degil.
 */
export function GenForm({ kaynak, id, baslik, onKapat, onKaydedildi, yerTutucuSekmeler, resimYerTutucu }: Props) {
  const yeniMi = id === 'yeni';

  const [meta, setMeta] = useState<KartMetaYaniti | null>(null);
  const [deger, setDeger] = useState<Record<string, Deger>>({});
  const [ilkDeger, setIlkDeger] = useState<Record<string, Deger>>({});
  const [surum, setSurum] = useState<string | undefined>();
  const [yetki, setYetki] = useState<KartYetkisi>({ duzenle: false, sil: false, gizliAlanlar: [] });
  const [detaylar, setDetaylar] = useState<Record<string, DetayDurumu>>({});

  const [yukleniyor, setYukleniyor] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});
  const [cakisma, setCakisma] = useState<{ alanlar: string[]; guncel: Record<string, unknown> } | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    setHata(null);
    try {
      const m = await api.kartAlanlari(kaynak);
      setMeta(m);
      setYetki(m.yetki);

      const bosDetaylar: Record<string, DetayDurumu> = {};
      m.detaylar.forEach(d => { bosDetaylar[d.ad] = bosDetay() });

      if (yeniMi) {
        const baslangic: Record<string, Deger> = {};
        m.alanlar.forEach(a => { baslangic[a.ad] = a.tip === 'mantik' ? false : '' });
        setDeger(baslangic);
        setIlkDeger(baslangic);
        setSurum(undefined);
        setDetaylar(bosDetaylar);
      } else {
        const k = await api.kartOku(kaynak, id as number);
        const gelen: Record<string, Deger> = {};
        m.alanlar.forEach(a => {
          const d = k.kart[a.ad];
          gelen[a.ad] = a.tip === 'mantik' ? Number(d) === 1 : (d === null || d === undefined ? '' : String(d));
        });
        setDeger(gelen);
        setIlkDeger(gelen);
        setSurum(k.kart.surum as string | undefined);
        setYetki(k.yetki);
        m.detaylar.forEach(d => {
          bosDetaylar[d.ad] = bosDetay(k.detaylar?.[d.ad] ?? []);
        });
        setDetaylar(bosDetaylar);
      }
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally {
      setYukleniyor(false);
    }
  }, [kaynak, id, yeniMi]);

  useEffect(() => { void yukle() }, [yukle]);

  const gruplar = useMemo(() => {
    const harita = new Map<string, KartAlanMeta[]>();
    meta?.alanlar.forEach(a => {
      if (a.ad === 'id') return;
      const g = a.grup ?? 'Genel';
      harita.set(g, [...(harita.get(g) ?? []), a]);
    });
    return [...harita.entries()];
  }, [meta]);

  /**
   * "Kimlik" grubu sekme DEGIL — mockup'taki idstrip gibi ust seritte, her sekmede
   * sabit gorunur (kod/unvan/durum gibi karti tanimlayan alanlar).
   */
  const kimlikAlanlari = useMemo(
    () => gruplar.find(([ad]) => ad === KIMLIK_GRUP)?.[1] ?? [],
    [gruplar],
  );

  /** Mockup'taki gibi sekmeli kart: Kimlik disindaki her alan grubu + her detay tablosu ayri sekme. */
  const sekmeler = useMemo<SekmeTanimi[]>(() => {
    const s: SekmeTanimi[] = gruplar
      .filter(([ad]) => ad !== KIMLIK_GRUP)
      .map(([ad, alanlar]) => ({ tur: 'grup', anahtar: grupSekmeAnahtari(ad), baslik: ad, alanlar }));
    meta?.detaylar.forEach(d => {
      s.push({ tur: 'detay', anahtar: detaySekmeAnahtari(d.ad), baslik: d.baslik, detay: d });
    });
    (yerTutucuSekmeler ?? []).forEach(baslik => {
      s.push({ tur: 'yerTutucu', anahtar: `y:${baslik}`, baslik });
    });
    return s;
  }, [gruplar, meta, yerTutucuSekmeler]);

  const [aktifSekme, setAktifSekme] = useState<string | null>(null);
  useEffect(() => {
    if (sekmeler.length && !sekmeler.some(s => s.anahtar === aktifSekme)) {
      setAktifSekme(sekmeler[0].anahtar);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sekmeler]);

  /** Hangi alan hangi sekmede — hata gelince o sekmeye atlamak icin. Kimlik her zaman gorunur, atlamaya gerek yok. */
  const sekmeBul = useCallback((alanAdi: string): string | null => {
    if (alanAdi.includes('.')) return detaySekmeAnahtari(alanAdi.split('.')[0]);
    const alan = meta?.alanlar.find(a => a.ad === alanAdi);
    const grup = alan?.grup ?? 'Genel';
    return grup === KIMLIK_GRUP ? null : grupSekmeAnahtari(grup);
  }, [meta]);

  /**
   * Yalniz DEGISEN alanlar gonderilir (§3.2: alan gondermemek "degistirme" demektir).
   *
   * YENI kayitta bos birakilan alan HIC GONDERILMEZ - null gondermek NOT NULL +
   * varsayilanli kolonlarda (durum, bayraklar) kaydi patlatiyordu. Bos gonderilmeyince
   * veritabani varsayilani devreye girer.
   * DUZENLEMEDE ise bos deger anlamlidir: kullanici alani temizlemis olabilir -> null.
   */
  const degisenAlanlar = useCallback(() => {
    const govde: Record<string, unknown> = {};
    meta?.alanlar.forEach(a => {
      if (!a.yazilabilir || a.ad === 'id') return;
      const yeni = deger[a.ad];

      if (yeniMi) {
        if (a.tip === 'mantik') { if (yeni) govde[a.ad] = true; return }
        if (yeni === '' || yeni === null || yeni === undefined) return;
        govde[a.ad] = yeni;
        return;
      }

      if (yeni === ilkDeger[a.ad]) return;
      govde[a.ad] = a.tip === 'mantik' ? Boolean(yeni) : (yeni === '' ? null : yeni);
    });
    return govde;
  }, [meta, deger, ilkDeger, yeniMi]);

  async function kaydet() {
    setKaydediyor(true);
    setHata(null);
    setAlanHatalari({});
    setCakisma(null);
    setBilgi(null);
    try {
      const govde = {
        surum,
        kart: degisenAlanlar(),
        detaylar: Object.fromEntries(
          Object.entries(detaylar)
            .map(([ad, durum]) => [ad, detayFarki(durum)])
            .filter(([, fark]) => {
              const f = fark as ReturnType<typeof detayFarki>;
              return (f.eklenen?.length ?? 0) + (f.degisen?.length ?? 0) + (f.silinen?.length ?? 0) > 0;
            })),
      };

      const yanit = yeniMi
        ? await api.kartEkle(kaynak, govde)
        : await api.kartGuncelle(kaynak, id as number, govde);

      onKaydedildi?.(Number(yanit.kart.id));
      onKapat?.();
      return;
    } catch (h) {
      if (h instanceof ApiHatasi) {
        if (h.dogrulamaMi && h.hata.alanlar) {
          setAlanHatalari(Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])));
          setHata(h.message);
          const hedefSekme = h.hata.alanlar[0] ? sekmeBul(h.hata.alanlar[0].alan) : null;
          if (hedefSekme) setAktifSekme(hedefSekme);
        } else if (h.cakismaMi) {
          setCakisma({
            alanlar: h.hata.cakisanAlanlar ?? [],
            guncel: h.hata.guncelDeger ?? {},
          });
        } else {
          setHata(`${h.hata.kod}: ${h.message}${h.hata.engel ? ` (${h.hata.engel.tablo}: ${h.hata.engel.adet})` : ''}`);
        }
      } else {
        setHata(String(h));
      }
    } finally {
      setKaydediyor(false);
    }
  }

  async function sil() {
    setHata(null);
    try {
      await api.kartSil(kaynak, id as number);
      onKapat?.();
    } catch (h) {
      if (h instanceof ApiHatasi) {
        setHata(h.hata.engel
          ? `${h.message} (${h.hata.engel.tablo}: ${h.hata.engel.adet} kayit)`
          : `${h.hata.kod}: ${h.message}`);
      }
    }
  }

  if (yukleniyor)
    return (
      <Modal baslik={baslik ?? kaynak} alt={<button className="d" onClick={onKapat}>Kapat</button>} onKapat={onKapat}>
        <div className="yukleniyor-satir">Yukleniyor…</div>
      </Modal>
    );

  if (!meta)
    return (
      <Modal baslik={baslik ?? kaynak} alt={<button className="d" onClick={onKapat}>Kapat</button>} onKapat={onKapat}>
        <div className="hata-kutusu">{hata}</div>
      </Modal>
    );

  const salt = !yeniMi && !yetki.duzenle;
  const aktif = sekmeler.find(s => s.anahtar === aktifSekme) ?? sekmeler[0];

  /** Sekme icinde mockup'taki gibi alt-bolumler (or. Genel -> Tanım/Sınıflandırma). */
  const altGruplaVar = (alanlar: KartAlanMeta[]) => {
    const harita = new Map<string, KartAlanMeta[]>();
    alanlar.forEach(a => {
      const g = a.altGrup ?? '';
      harita.set(g, [...(harita.get(g) ?? []), a]);
    });
    return [...harita.entries()];
  };

  const renderGirdi = (a: KartAlanMeta) => (
    a.tip === 'mantik' ? (
      <input
        key={a.ad}
        type="checkbox"
        checked={Boolean(deger[a.ad])}
        disabled={salt || !a.yazilabilir}
        onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.checked }))}
      />
    ) : a.kodlar ? (
      <select
        key={a.ad}
        value={String(deger[a.ad] ?? '')}
        disabled={salt || !a.yazilabilir}
        onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.value }))}
      >
        <option value="">—</option>
        {Object.entries(a.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
      </select>
    ) : (
      <input
        key={a.ad}
        type={a.tip === 'tarih' ? 'text' : 'text'}
        value={String(deger[a.ad] ?? '')}
        maxLength={a.enFazlaUzunluk ?? undefined}
        disabled={salt || !a.yazilabilir}
        onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.value }))}
      />
    )
  );

  const renderAlan = (a: KartAlanMeta) => (
    <label key={a.ad} className={`alan tip-${a.tip}`}>
      <span className="etiket">
        {a.baslik}{a.zorunlu && <b className="zorunlu"> *</b>}
      </span>
      {renderGirdi(a)}
      {alanHatalari[a.ad] && <span className="alan-hata">{alanHatalari[a.ad]}</span>}
    </label>
  );

  /**
   * Mockup'taki ".ikili" (or. Raf Ömrü: sayi + birim combo TEK etiket altinda yan yana).
   * `eslesAlan` ile baska bir alani gosteren alan, o alani kendi satirina EKLER; hedef alan
   * ayri satir olarak TEKRAR RENDER EDILMEZ.
   */
  const renderAlanListesi = (alanlar: KartAlanMeta[]) => {
    const eslesenler = new Set(alanlar.map(a => a.eslesAlan).filter(Boolean));
    return alanlar
      .filter(a => !eslesenler.has(a.ad))
      .map(a => {
        const hedef = a.eslesAlan ? alanlar.find(x => x.ad === a.eslesAlan) : undefined;
        if (!hedef) return renderAlan(a);
        return (
          <label key={a.ad} className={`alan tip-${a.tip}`}>
            <span className="etiket">
              {a.baslik}{a.zorunlu && <b className="zorunlu"> *</b>}
            </span>
            <div className="ikili">{renderGirdi(a)}{renderGirdi(hedef)}</div>
            {(alanHatalari[a.ad] || alanHatalari[hedef.ad]) && (
              <span className="alan-hata">{alanHatalari[a.ad] || alanHatalari[hedef.ad]}</span>
            )}
          </label>
        );
      });
  };

  return (
    <Modal
      baslik={`${baslik ?? kaynak} ${yeniMi ? '— Yeni' : `#${id}`}`}
      ustBilgi={
        <>
          {surum && <span className="rozet gri">surum {surum}</span>}
          {salt && <span className="rozet uyari">salt okunur</span>}
        </>
      }
      ustSerit={kimlikAlanlari.length > 0 && (
        <div className="kaid">
          <div className="alan-izgara">{renderAlanListesi(kimlikAlanlari)}</div>
        </div>
      )}
      sekmeBar={sekmeler.length > 1 && (
        <div className="katab">
          {sekmeler.map(s => (
            <div
              key={s.anahtar}
              className={`kat${s.anahtar === aktif?.anahtar ? ' on' : ''}`}
              onClick={() => setAktifSekme(s.anahtar)}
            >
              {s.baslik}
              {s.tur === 'detay' && <span className="b">{(detaylar[s.detay.ad] ?? bosDetay()).guncel.length}</span>}
            </div>
          ))}
        </div>
      )}
      onKapat={onKapat}
      alt={
        <>
          {!salt && (
            <button className="d bir" disabled={kaydediyor} onClick={() => void kaydet()}>
              {kaydediyor ? 'Kaydediliyor…' : 'Kaydet'}
            </button>
          )}
          {!yeniMi && yetki.sil && (
            <button className="d teh" onClick={() => void sil()}>Sil</button>
          )}
          <button className="d" onClick={onKapat}>Kapat</button>
        </>
      }
    >
      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      {cakisma && (
        <div className="cakisma-kutusu">
          <b>Bu kaydi baska bir kullanici degistirdi.</b>
          {cakisma.alanlar.length > 0 && <div>Cakisan alanlar: {cakisma.alanlar.join(', ')}</div>}
          <div className="cakisma-arac">
            <button className="d" onClick={() => { setCakisma(null); void yukle() }}>Guncel hali al (degisikliklerim gider)</button>
            <button className="d" onClick={() => {
              // Sunucudaki guncel surumu alip kendi degisikliklerimi UZERINE yaz
              setSurum(String(cakisma.guncel.surum ?? ''));
              setCakisma(null);
            }}>Benim degisikliklerimi uygula</button>
          </div>
        </div>
      )}

      {aktif?.tur === 'grup' && (() => {
        const gruplanmis = altGruplaVar(aktif.alanlar);
        const adli = gruplanmis.filter(([b]) => b);
        const adsiz = gruplanmis.find(([b]) => !b)?.[1] ?? [];
        return (
          <>
            {/* Mockup: Tanım/Sınıflandırma · Vergi & Ana Birim ... AYNI SATIRDA yan yana (.row > .col > .grp). */}
            {adli.length > 0 && (
              <div className="kasira">
                {adli.map(([altBaslik, alanlar]) => (
                  <div className="kagrup" key={altBaslik}>
                    <h6>{altBaslik}</h6>
                    <div className="alan-izgara tek-sutun">{renderAlanListesi(alanlar)}</div>
                  </div>
                ))}
                {resimYerTutucu && aktif.baslik === 'Genel' && (
                  <div className="kagrup kagrup-resim">
                    <h6>Resim</h6>
                    <div className="resim-kutusu">🖼️</div>
                  </div>
                )}
              </div>
            )}
            {adsiz.length > 0 && <div className="alan-izgara">{renderAlanListesi(adsiz)}</div>}
          </>
        );
      })()}

      {aktif?.tur === 'detay' && (
        <GenDetayTablo
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          hatalar={alanHatalari}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
        />
      )}

      {aktif?.tur === 'yerTutucu' && (
        <div style={{ padding: 40, textAlign: 'center', color: 'var(--soluk)' }}>
          {aktif.baslik} sekmesi yakında.
        </div>
      )}
    </Modal>
  );
}
