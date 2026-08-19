import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type KolonMeta, type Kosul, type ListeSatiri, type Siralama } from '../api/sozlesme';
import { bicimle } from './bicim';
import { GenKomutPaleti, GenSagTus, GenToolbar, hedefte, useAksiyonlar } from './Aksiyonlar';

interface Props {
  /** Liste kaynagi: 'cari', 'belge', 'stok' ... */
  kaynak: string;
  baslik?: string;
  /** Ust satirdaki kirilma yolu: "Cari › Musteriler" */
  yol?: string;
  sabitFiltre?: Kosul;
  /** Toplami istenen kolon adlari (sunucu hesaplar). */
  toplam?: string[];
  boyut?: number;
  onSatirAc?(satir: ListeSatiri): void;
  /** Aksiyon katalogu ekrani ("cari-liste"); verilirse arac cubugu + sag tus + palet gelir. */
  aksiyonEkrani?: string;
  onAksiyon?(kod: string, satir: ListeSatiri | null): void;
  /** Ust cip filtreleri: { ad, filtre } — mockup'taki "Aktif / Pasif / Tumu" seridi. */
  cipler?: { ad: string; filtre?: Kosul }[];
}

/** Mockup: cip seridinde Liste/Grup/Analiz gorunum secimi (search kutusunun hemen sagi). */
const GORUNUMLER: { v: 'liste' | 'grup' | 'analiz'; ik: string; ad: string }[] = [
  { v: 'liste', ik: '▤', ad: 'Liste' },
  { v: 'grup', ik: '▦', ad: 'Grup' },
  { v: 'analiz', ik: '📊', ad: 'Analiz' },
];

/**
 * Liste ekrani — ana mockup (gentegre_v4_web.html) duzeni:
 *   sayfa basligi + kirilma yolu + aksiyon dugmeleri
 *   cip filtreleri + hizli arama
 *   kutu icinde grid + alt bilgi seridi
 *
 * Kolonlar SUNUCUDAN gelir (/kolonlar): yetkisiz kolon listede hic donmedigi icin
 * arayuzde gizleme mantigi YOKTUR. Filtre, siralama ve sayfalama da sunucuda calisir.
 */
export function GenGrid({ kaynak, baslik, yol, sabitFiltre, toplam, boyut = 50, onSatirAc,
                          aksiyonEkrani, onAksiyon, cipler }: Props) {
  const [kolonlar, setKolonlar] = useState<KolonMeta[]>([]);
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [toplamKayit, setToplamKayit] = useState(0);
  const [toplamlar, setToplamlar] = useState<Record<string, unknown> | undefined>();
  const [sayfa, setSayfa] = useState(1);
  const [sirala, setSirala] = useState<Siralama[]>([]);
  const [arama, setArama] = useState('');
  const [cipIndeks, setCipIndeks] = useState(0);
  // Mockup: Liste/Grup/Analiz gorunum secimi. Grup/Analiz backend'de HENUZ YOK -
  //   grid yerine "yakinda" yer tutucu gosterilir (aksiyon stub'lariyla ayni durustluk).
  const [gorunum, setGorunum] = useState<'liste' | 'grup' | 'analiz'>('liste');
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [sureMs, setSureMs] = useState(0);

  const [seciliSatir, setSeciliSatir] = useState<ListeSatiri | null>(null);
  const [sagTusKonumu, setSagTusKonumu] = useState<{ x: number; y: number } | null>(null);

  // Ilk sutun: onay kutusu (coklu secim, su an icin sadece yuklu sayfa) + "3 nokta" grid menusu.
  const [secili, setSecili] = useState<Set<string>>(new Set());
  useEffect(() => { setSecili(new Set()) }, [kaynak]);

  const [filtreAcik, setFiltreAcik] = useState(false);
  const [filtreDeger, setFiltreDeger] = useState<Record<string, string>>({});
  const filtreZamanlayici = useRef<number | undefined>(undefined);
  const [gridMenuKonum, setGridMenuKonum] = useState<{ x: number; y: number } | null>(null);

  // Aksiyonlar secili kayda gore yeniden cozulur: "belge zaten gonderilmis" gibi
  //   kosullar sunucuda degerlendirilir, istemci kural yazmaz.
  const { aksiyonlar } = useAksiyonlar(
    aksiyonEkrani ?? 'cari-liste',
    seciliSatir?.id != null ? Number(seciliSatir.id) : null);

  const aksiyonCalistir = (kod: string) => onAksiyon?.(kod, seciliSatir);

  // Mockup'taki "Aksiyon Sec + Uygula" (cip seridiyle ayni satir, saga yanasik) -
  //   sag tus menusuyle AYNI katalog seti (ayni ekranda iki farkli tetikleme yolu).
  const [aksiyonSecim, setAksiyonSecim] = useState('');
  const aksiyonKombo = useMemo(() => aksiyonlar.filter(a => hedefte(a, 'sagtus')), [aksiyonlar]);
  useEffect(() => { if (!aksiyonKombo.some(a => a.kod === aksiyonSecim)) setAksiyonSecim('') }, [aksiyonKombo, aksiyonSecim]);
  const secilenAksiyon = aksiyonKombo.find(a => a.kod === aksiyonSecim);
  const aramaZamanlayici = useRef<number | undefined>(undefined);

  useEffect(() => {
    let iptal = false;
    api.kolonlar(kaynak)
      .then(y => { if (!iptal) setKolonlar(y.kolonlar.filter(k => k.varsayilan)) })
      .catch((h: ApiHatasi) => { if (!iptal) setHata(h.message) });
    return () => { iptal = true };
  }, [kaynak]);

  /** Hizli arama: metin kolonlarinda 'icerir' (sunucuda pg_trgm indeksli, Turkce duyarsiz). */
  const aramaFiltresi = useCallback((): Kosul | undefined => {
    const metin = arama.trim();
    if (!metin) return undefined;
    const hedefler = kolonlar.filter(k => k.tip === 'metin' && k.filtrelenebilir);
    if (hedefler.length === 0) return undefined;
    return { op: 'or', kosullar: hedefler.map(k => ({ alan: k.ad, op: 'icerir', deger: metin })) };
  }, [arama, kolonlar]);

  /** Sutun basligi altindaki filtre satiri — su an icin metin/kod kolonlarinda "icerir". */
  const filtreSatiriFiltresi = useCallback((): Kosul | undefined => {
    const kosullar: Kosul[] = [];
    kolonlar.forEach(k => {
      if (k.tip !== 'metin' && k.tip !== 'kod') return;
      const v = (filtreDeger[k.ad] ?? '').trim();
      if (v) kosullar.push({ alan: k.ad, op: 'icerir', deger: v });
    });
    return kosullar.length ? { op: 'and', kosullar } : undefined;
  }, [filtreDeger, kolonlar]);

  const yukle = useCallback(async () => {
    if (kolonlar.length === 0) return;
    setYukleniyor(true);
    setHata(null);
    try {
      const parcalar = [sabitFiltre, cipler?.[cipIndeks]?.filtre, aramaFiltresi(), filtreSatiriFiltresi()]
        .filter(Boolean) as Kosul[];
      const filtre = parcalar.length === 0 ? undefined
        : parcalar.length === 1 ? parcalar[0]
        : { op: 'and' as const, kosullar: parcalar };

      const yanit = await api.liste(kaynak, { sayfa, boyut, sirala, filtre, toplam });
      setSatirlar(yanit.satirlar);
      setToplamKayit(yanit.toplamKayit);
      setToplamlar(yanit.toplamlar);
      setSureMs(yanit.sureMs);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? `${h.hata.kod}: ${h.message}` : String(h));
      setSatirlar([]);
    } finally {
      setYukleniyor(false);
    }
  }, [kaynak, sayfa, boyut, sirala, toplam, sabitFiltre, aramaFiltresi, filtreSatiriFiltresi, cipler, cipIndeks, kolonlar.length]);

  useEffect(() => { void yukle() }, [yukle]);

  // Arama yazarken her tusa istek atilmaz (Delphi tarafindaki debounce deseni).
  const aramaDegisti = (deger: string) => {
    window.clearTimeout(aramaZamanlayici.current);
    aramaZamanlayici.current = window.setTimeout(() => { setSayfa(1); setArama(deger) }, 350);
  };

  const filtreSatiriDegisti = (alan: string, deger: string) => {
    window.clearTimeout(filtreZamanlayici.current);
    filtreZamanlayici.current = window.setTimeout(() => {
      setSayfa(1);
      setFiltreDeger(f => ({ ...f, [alan]: deger }));
    }, 350);
  };

  const sayfaIdleri = () => satirlar.map((s, i) => String(s.id ?? i));

  /**
   * Onay kutusu ve tek-satir secimi (seciliSatir - aksiyon/duzenle hedefi) AYNI
   * durumu paylasir: TEK kutu isaretliyken o satir hedef olur (Duzenle/aksiyon
   * kombo acilir), sifir ya da birden fazlasinda hedef belirsizdir (null).
   */
  const secimiUygula = (yeni: Set<string>) => {
    setSecili(yeni);
    if (yeni.size === 1) {
      const tekId = [...yeni][0];
      const idx = satirlar.findIndex((s, i) => String(s.id ?? i) === tekId);
      setSeciliSatir(idx >= 0 ? satirlar[idx] : null);
    } else {
      setSeciliSatir(null);
    }
  };

  const satirSecimiDegistir = (id: string, index: number) => {
    const yeni = new Set(secili);
    yeni.has(id) ? yeni.delete(id) : yeni.add(id);
    secimiUygula(yeni);
    ankorRef.current = index;
  };

  /**
   * Satir tiklamasi: duz tik = TEK secim (eskisi gibi). Ctrl/Cmd+tik = o satiri
   * mevcut secime EKLE/CIKAR (coklu). Shift+tik = son "ankor"dan buraya kadar
   * ARALIK sec (standart dosya gezgini/tablo davranisi - Explorer, Excel...).
   */
  const ankorRef = useRef<number | null>(null);
  const satirTiklandi = (e: React.MouseEvent, id: string, index: number) => {
    if (e.shiftKey && ankorRef.current !== null) {
      const bas = Math.min(ankorRef.current, index);
      const son = Math.max(ankorRef.current, index);
      const yeni = new Set(secili);
      for (let k = bas; k <= son; k++) yeni.add(String(satirlar[k].id ?? k));
      secimiUygula(yeni);
      return;
    }
    if (e.ctrlKey || e.metaKey) {
      const yeni = new Set(secili);
      yeni.has(id) ? yeni.delete(id) : yeni.add(id);
      secimiUygula(yeni);
      ankorRef.current = index;
      return;
    }
    secimiUygula(new Set([id]));
    ankorRef.current = index;
  };
  const hepsiSecili = satirlar.length > 0 && sayfaIdleri().every(id => secili.has(id));
  const bazisiSecili = !hepsiSecili && sayfaIdleri().some(id => secili.has(id));

  const siralamaDegistir = (kolon: KolonMeta) => {
    if (!kolon.siralanabilir) return;
    setSirala(onceki => {
      const mevcut = onceki.find(s => s.alan === kolon.ad);
      if (!mevcut) return [{ alan: kolon.ad, yon: 'asc' }];
      if (mevcut.yon === 'asc') return [{ alan: kolon.ad, yon: 'desc' }];
      return [];
    });
    setSayfa(1);
  };

  const sonSayfa = Math.max(1, Math.ceil(toplamKayit / boyut));
  const siraIsareti = (ad: string) => {
    const s = sirala.find(x => x.alan === ad);
    return s ? (s.yon === 'asc' ? ' ↑' : ' ↓') : '';
  };

  const satirSinifi = (satir: ListeSatiri) => {
    const renk = satir.satirRengi === 'kritik' ? 'satir-kritik'
      : satir.satirRengi === 'uyari' ? 'satir-uyari'
      : satir.satirRengi === 'pasif' ? 'satir-pasif' : '';
    return `${renk} ${seciliSatir?.id === satir.id ? 'secili' : ''}`.trim();
  };

  const gorunenToplamlar = useMemo(() => Object.entries(toplamlar ?? {}), [toplamlar]);

  const hepsiRef = useRef<HTMLInputElement | null>(null);
  useEffect(() => { if (hepsiRef.current) hepsiRef.current.indeterminate = bazisiSecili }, [bazisiSecili]);

  useEffect(() => {
    if (!gridMenuKonum) return;
    const kapat = () => setGridMenuKonum(null);
    window.addEventListener('click', kapat);
    window.addEventListener('scroll', kapat, true);
    return () => { window.removeEventListener('click', kapat); window.removeEventListener('scroll', kapat, true) };
  }, [gridMenuKonum]);

  const gridMenuOgeleri: { ik: string; ad: string; secili?: boolean; devre?: string; fn(): void }[] = [
    { ik: '☑', ad: 'Tumunu Sec (bu sayfa)', devre: satirlar.length ? undefined : 'Kayit yok', fn: () => secimiUygula(new Set(sayfaIdleri())) },
    { ik: '☐', ad: 'Secimi Temizle', devre: secili.size ? undefined : 'Secili kayit yok', fn: () => secimiUygula(new Set()) },
    { ik: '⇄', ad: 'Secimi Tersine Cevir', devre: satirlar.length ? undefined : 'Kayit yok', fn: () => {
      const yeni = new Set(secili);
      sayfaIdleri().forEach(id => { yeni.has(id) ? yeni.delete(id) : yeni.add(id) });
      secimiUygula(yeni);
    } },
    {
      ik: '🔎', ad: 'Satir Filtreleme', secili: filtreAcik,
      // Kapatinca filtre TEMIZLENIR - yoksa satir gizliyken suzgec sessizce etkin kalir,
      //   "liste birden azaldi" gibi anlasilmaz bir goruntu birakir.
      fn: () => setFiltreAcik(acikMi => {
        if (acikMi) { setFiltreDeger({}); setSayfa(1) }
        return !acikMi;
      }),
    },
  ];

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{baslik ?? kaynak}</h1>
          {yol && <span className="yol">{yol}</span>}
          <div className="sag">
            {aksiyonEkrani && <GenToolbar aksiyonlar={aksiyonlar} calistir={aksiyonCalistir} />}
          </div>
        </div>
      </div>

      <div className="cipler">
        <div className="ara" style={{ maxWidth: 225, margin: 0, height: 23 }}>
          <span>🔍</span>
          <input
            style={{ border: 0, background: 'transparent', outline: 'none', width: '100%' }}
            placeholder="Bu listede ara…"
            onChange={e => aramaDegisti(e.target.value)}
          />
        </div>

        {GORUNUMLER.map(g => (
          <button
            key={g.v}
            className={`cip ${gorunum === g.v ? 'on' : ''}`}
            onClick={() => setGorunum(g.v)}
          >
            {g.ik} {g.ad}
          </button>
        ))}

        <span className="cipsag">
          {aksiyonEkrani && aksiyonKombo.length > 0 && (
            <>
              <select
                className="aksk"
                value={aksiyonSecim}
                onChange={e => setAksiyonSecim(e.target.value)}
              >
                <option value="">— Aksiyon Seç —</option>
                {aksiyonKombo.map(a => (
                  <option key={a.kod} value={a.kod}>{a.ad}</option>
                ))}
              </select>
              <button
                type="button"
                className="uygd"
                disabled={!secilenAksiyon || !secilenAksiyon.aktif}
                title={secilenAksiyon && !secilenAksiyon.aktif ? (secilenAksiyon.pasifSebep ?? '') : ''}
                onClick={() => { if (secilenAksiyon?.aktif) aksiyonCalistir(secilenAksiyon.kod) }}
              >
                Uygula
              </button>
            </>
          )}
        </span>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}

        {cipler && cipler.length > 0 && (
          <div className="durumseg">
            {/* Delphi'deki "Tum Liste / Son Aranan / Sik Aranan" (KULLANICI_ARAMA) - sadece
                Tum Liste calisir (varsayilan gorunum zaten bu); Son/Sik'in backend'i yok. */}
            <button
              className="ikon-liste on"
              title="Tüm Liste"
              onClick={() => {}}
            >
              ☰
            </button>
            <button
              className="ikon-liste"
              title="Son Aranan"
              onClick={() => alert('Son Aranan henüz bağlanmadı.')}
            >
              🕓
            </button>
            <button
              className="ikon-liste"
              title="Sık Aranan"
              onClick={() => alert('Sık Aranan henüz bağlanmadı.')}
            >
              ⭐
            </button>
            <span className="durumseg-ayrac" />
            {cipler.map((c, i) => (
              <button
                key={c.ad}
                className={i === cipIndeks ? 'on' : ''}
                onClick={() => { setCipIndeks(i); setSayfa(1) }}
              >
                {c.ad}
              </button>
            ))}
          </div>
        )}

        {gorunum !== 'liste' ? (
          <div className="kutu" style={{ padding: 48, textAlign: 'center', color: 'var(--soluk)' }}>
            {GORUNUMLER.find(g => g.v === gorunum)?.ik}{' '}
            {GORUNUMLER.find(g => g.v === gorunum)?.ad} görünümü yakında.
          </div>
        ) : (
        <div className="kutu dolgusuz">
          <div className="gridwrap">
            <div className="gridkaydir">
              <table className="grid">
                <thead>
                  <tr>
                    <th className="cbk">
                      <input
                        ref={hepsiRef}
                        type="checkbox"
                        className="grid-cb"
                        checked={hepsiSecili}
                        onChange={() => secimiUygula(hepsiSecili ? new Set() : new Set(sayfaIdleri()))}
                        title="Bu sayfadaki tumunu sec"
                      />
                      <button
                        type="button"
                        className={`grid-noktalar${gridMenuKonum ? ' on' : ''}`}
                        title="Grid menusu"
                        onClick={e => {
                          e.stopPropagation();
                          const r = e.currentTarget.getBoundingClientRect();
                          setGridMenuKonum(gridMenuKonum ? null : { x: r.left, y: r.bottom + 4 });
                        }}
                      >
                        ⋮
                      </button>
                    </th>
                    {kolonlar.map(k => (
                      <th
                        key={k.ad}
                        className={`hiza-${k.hizalama} ${k.siralanabilir ? 'siralanir' : ''}`}
                        onClick={() => siralamaDegistir(k)}
                      >
                        {k.baslik}{siraIsareti(k.ad)}
                      </th>
                    ))}
                  </tr>
                  {filtreAcik && (
                    <tr className="flt">
                      <th className="cbk" />
                      {kolonlar.map(k => (
                        <th key={k.ad}>
                          {(k.tip === 'metin' || k.tip === 'kod') && k.filtrelenebilir && (
                            <input
                              placeholder="icerir…"
                              onChange={e => filtreSatiriDegisti(k.ad, e.target.value)}
                            />
                          )}
                        </th>
                      ))}
                    </tr>
                  )}
                </thead>
                <tbody>
                  {satirlar.map((satir, i) => {
                    const id = String(satir.id ?? i);
                    return (
                      <tr
                        key={id}
                        className={satirSinifi(satir)}
                        onMouseDown={e => { if (e.shiftKey) e.preventDefault() }}
                        onClick={e => satirTiklandi(e, id, i)}
                        onDoubleClick={() => onSatirAc?.(satir)}
                        onContextMenu={e => {
                          if (!aksiyonEkrani) return;
                          e.preventDefault();
                          setSeciliSatir(satir);
                          setSagTusKonumu({ x: e.clientX, y: e.clientY });
                        }}
                      >
                        <td className="cbk">
                          <input
                            type="checkbox"
                            className="grid-cb"
                            checked={secili.has(id)}
                            onClick={e => e.stopPropagation()}
                            onChange={() => satirSecimiDegistir(id, i)}
                          />
                        </td>
                        {kolonlar.map(k => (
                          <td key={k.ad} className={`hiza-${k.hizalama}`}>
                            {bicimle(satir[k.ad], k)}
                          </td>
                        ))}
                      </tr>
                    );
                  })}
                  {!yukleniyor && satirlar.length === 0 && (
                    <tr><td colSpan={kolonlar.length + 1} className="bos">Kayit yok</td></tr>
                  )}
                </tbody>
                {gorunenToplamlar.length > 0 && (
                  <tfoot>
                    <tr>
                      <td className="cbk" />
                      {kolonlar.map((k, i) => {
                        const t = gorunenToplamlar.find(([ad]) => ad === k.ad);
                        return (
                          <td key={k.ad} className={`hiza-${k.hizalama}`}>
                            {t ? bicimle(t[1], k) : (i === 0 ? 'Toplam' : '')}
                          </td>
                        );
                      })}
                    </tr>
                  </tfoot>
                )}
              </table>
            </div>
            {yukleniyor && <div className="yukleniyor">Yukleniyor…</div>}
          </div>

          <div className="altbilgi">
            <span>Kayit: <b>{toplamKayit.toLocaleString('tr-TR')}</b>{sureMs > 0 && ` · ${sureMs} ms`}</span>
            {secili.size > 0 ? (
              <span>Secili: <b>{secili.size}</b></span>
            ) : seciliSatir && (
              <span>Secili: <b>{String(seciliSatir.unvan ?? seciliSatir.ad ?? seciliSatir.belgeNo ?? seciliSatir.id)}</b></span>
            )}
            <span className="sag">
              <button className="d" disabled={sayfa <= 1} onClick={() => setSayfa(s => s - 1)}>‹ Onceki</button>
              <span>{sayfa} / {sonSayfa}</span>
              <button className="d" disabled={sayfa >= sonSayfa} onClick={() => setSayfa(s => s + 1)}>Sonraki ›</button>
            </span>
          </div>
        </div>
        )}
      </div>

      {gridMenuKonum && (
        <div className="sag-tus" style={{ left: gridMenuKonum.x, top: gridMenuKonum.y }} onClick={e => e.stopPropagation()}>
          {gridMenuOgeleri.map((o, i) => (
            <div key={o.ad}>
              {i === 3 && <div className="ayr" />}
              <button
                disabled={!!o.devre}
                title={o.devre ?? ''}
                onClick={() => { if (!o.devre) { o.fn(); setGridMenuKonum(null) } }}
              >
                <span>{o.ik} {o.ad}</span>
                {o.secili && <span className="tk">✓</span>}
              </button>
            </div>
          ))}
        </div>
      )}

      {aksiyonEkrani && (
        <>
          <GenSagTus
            aksiyonlar={aksiyonlar}
            calistir={aksiyonCalistir}
            konum={sagTusKonumu}
            onKapat={() => setSagTusKonumu(null)}
          />
          <GenKomutPaleti aksiyonlar={aksiyonlar} calistir={aksiyonCalistir} />
        </>
      )}
    </>
  );
}
