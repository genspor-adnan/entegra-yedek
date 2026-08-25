import { useEffect, useRef } from 'react';
import type { KolonMeta, Siralama } from '../../api/sozlesme';

/**
 * GRIDIN UC NOKTA MENUSU - tip, ogeler ve cizim.
 *
 * Menu YALNIZ GRIDLE ilgili islemleri tasir (kullanici): yenile, disa aktar,
 * satir filtresi, siralama, secim, sayfa boyu, gruplama, satir yuksekligi,
 * kolonlar. Gorunum (Liste / Grup / Analiz) ve arama gorunumu (Tüm / Son / Sık)
 * BURADA DEGIL: ikisi de arac cubugunda kendi dugmeleriyle duruyor ve menude
 * tekrarlaniyordu - ayni ayari iki yerden degistirmek, hangisinin gecerli
 * oldugu sorusunu doguruyordu.
 */
export type MenuOgesi = {
  ik: string; ad: string; secili?: boolean; devre?: string; ayrac?: boolean; fn(): void;
  /** Satirin sagindaki kucuk dugmeler (kolon sirasi: yukari/asagi). Menu
      bunlara basilinca KAPANMAZ - ust uste tasima yapilabilsin. */
  yan?: { ik: string; ipucu: string; devre?: boolean; fn(): void }[];
};

export type SatirBoyu = 'sik' | 'normal' | 'genis';

/** Menu ogelerini uretmek icin gridin durumu ve eylemleri. */
export interface GridMenuGirdisi {
  kolonlar: KolonMeta[];
  tumKolonlar: KolonMeta[];
  satirSayisi: number;
  seciliSayisi: number;
  sirala: Siralama[];
  filtreAcik: boolean;
  filtreVar: boolean;
  sayfaBoyu: number;
  /** Disaridan sabit boyut verildiyse sayfa boyu degistirilemez. */
  boyutSabit: boolean;
  kullaniciGrup: string | null;
  satirBoyu: SatirBoyu;
  yukle(): void;
  csvIndir(): void;
  setFiltreAcik(f: (acikMi: boolean) => boolean): void;
  filtreleriTemizle(): void;
  siralamayiTemizle(): void;
  tumunuSec(): void;
  secimiTemizle(): void;
  secimiTersineCevir(): void;
  sayfaBoyuSec(n: number): void;
  gruplaSec(ad: string | null): void;
  satirBoyuSec(v: SatirBoyu): void;
  kolonDegistir(k: KolonMeta): void;
  kolonTasi(ad: string, yon: -1 | 1): void;
  kolonlariSifirla(): void;
}

export function gridMenuOgeleri(g: GridMenuGirdisi): MenuOgesi[] {
  return [
    { ik: '⟳', ad: 'Yenile', fn: g.yukle },
    { ik: '📄', ad: 'CSV Kaydet', devre: g.satirSayisi ? undefined : 'Kayit yok',
      fn: g.csvIndir },

    {
      ik: '🔎', ad: 'Satir Filtreleme', secili: g.filtreAcik, ayrac: true,
      // Kapatinca filtre TEMIZLENIR - yoksa satir gizliyken suzgec sessizce
      //   etkin kalir, "liste birden azaldi" gibi anlasilmaz bir goruntu birakir.
      fn: () => g.setFiltreAcik(acikMi => !acikMi),
    },
    { ik: '✖', ad: 'Filtreleri Temizle', devre: g.filtreVar ? undefined : 'Etkin filtre yok',
      fn: g.filtreleriTemizle },
    { ik: '↕', ad: 'Sıralamayı Temizle', devre: g.sirala.length ? undefined : 'Siralama yok',
      fn: g.siralamayiTemizle },

    { ik: '☑', ad: 'Tumunu Sec (bu sayfa)', ayrac: true,
      devre: g.satirSayisi ? undefined : 'Kayit yok', fn: g.tumunuSec },
    { ik: '☐', ad: 'Secimi Temizle', devre: g.seciliSayisi ? undefined : 'Secili kayit yok',
      fn: g.secimiTemizle },
    { ik: '⇄', ad: 'Secimi Tersine Cevir', devre: g.satirSayisi ? undefined : 'Kayit yok',
      fn: g.secimiTersineCevir },

    // Sayfa boyu: ekran disaridan boyut verdiyse (or. gomulu grid) degistirilemez.
    ...[25, 50, 100, 200].map((n, i) => ({
      ik: '≡', ad: `Sayfada ${n} kayıt`, secili: g.sayfaBoyu === n, ayrac: i === 0,
      devre: g.boyutSabit ? 'Bu ekranda sayfa boyu sabit' : undefined,
      fn: () => g.sayfaBoyuSec(n),
    })),

    // GRUPLAMA (kullanici): secilen kolon ayni zamanda ILK SIRALAMA olur -
    //   yoksa ayni grubun satirlari listeye dagilir, baslik defalarca cizilir.
    //   Gruplanabilir kolonlar: siralanabilir olanlar (sunucu o alana gore
    //   siralayabiliyorsa gruplama da anlamlidir).
    { ik: '⊟', ad: 'Gruplama Yok', secili: !g.kullaniciGrup, ayrac: true,
      fn: () => g.gruplaSec(null) },
    ...g.kolonlar.filter(k => k.siralanabilir !== false).map(k => ({
      ik: '⊞', ad: `Grupla: ${k.baslik}`, secili: g.kullaniciGrup === k.ad,
      fn: () => g.gruplaSec(k.ad),
    })),

    // SATIR YUKSEKLIGI - tercih tarayicida, tum gridler icin ortak.
    { ik: '≡', ad: 'Satır: Sık', secili: g.satirBoyu === 'sik', ayrac: true,
      fn: () => g.satirBoyuSec('sik') },
    { ik: '≡', ad: 'Satır: Normal', secili: g.satirBoyu === 'normal',
      fn: () => g.satirBoyuSec('normal') },
    { ik: '≡', ad: 'Satır: Geniş', secili: g.satirBoyu === 'genis',
      fn: () => g.satirBoyuSec('genis') },

    // Kolon gorunurlugu - secim tarayicida saklanir, "Varsayılan Kolonlar" geri
    //   alir. Gorunur kolonlarda ayrica ↑ / ↓ ile SIRA degistirilir (kullanici).
    ...g.tumKolonlar.map((k, i) => {
      const gorunur = g.kolonlar.some(x => x.ad === k.ad);
      const sira = g.kolonlar.findIndex(x => x.ad === k.ad);
      return {
        ik: gorunur ? '☑' : '☐',
        ad: k.baslik, secili: gorunur, ayrac: i === 0,
        fn: () => g.kolonDegistir(k),
        yan: gorunur ? [
          { ik: '↑', ipucu: 'Sola al', devre: sira <= 0, fn: () => g.kolonTasi(k.ad, -1) },
          { ik: '↓', ipucu: 'Sağa al', devre: sira < 0 || sira >= g.kolonlar.length - 1,
            fn: () => g.kolonTasi(k.ad, 1) },
        ] : undefined,
      };
    }),
    { ik: '↺', ad: 'Varsayılan Kolonlar', devre: g.tumKolonlar.length ? undefined : 'Kolon yok',
      fn: g.kolonlariSifirla },
  ];
}

/** Acilan menunun kendisi. Konum null ise cizilmez. */
export function GridMenu({ konum, ogeler, onKapat }: {
  konum: { x: number; y: number } | null;
  ogeler: MenuOgesi[];
  onKapat(): void;
}) {
  /** Menunun kendisi - disari tiklama/kaydirma ayirt edilsin. */
  const menuRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!konum) return;
    // Menu SAYFA kaydirilinca kapanir (konumu sabit, yerinde asili kalirdi) ama
    //   KENDI icinde kaydirilinca KAPANMAZ: capture fazindaki dinleyici menunun
    //   kendi scroll'unu da yakaliyor ve kullanici kolon listesine inemiyordu.
    const kapat = (e: Event) => {
      if (e.target instanceof Node && menuRef.current?.contains(e.target)) return;
      onKapat();
    };
    window.addEventListener('click', kapat);
    window.addEventListener('scroll', kapat, true);
    return () => {
      window.removeEventListener('click', kapat);
      window.removeEventListener('scroll', kapat, true);
    };
  }, [konum, onKapat]);

  if (!konum) return null;
  return (
    <div ref={menuRef} className="sag-tus" style={{ left: konum.x, top: konum.y }}
         onClick={e => e.stopPropagation()}>
      {ogeler.map(o => (
        <div key={o.ad}>
          {o.ayrac && <div className="ayr" />}
          <button
            disabled={!!o.devre}
            title={o.devre ?? ''}
            onClick={() => { if (!o.devre) { o.fn(); onKapat() } }}
          >
            <span>{o.ik} {o.ad}</span>
            {o.secili && <span className="tk">✓</span>}
            {/* Kolon sirasi oklari: menu KAPANMAZ, ust uste tasima yapilir. */}
            {o.yan && (
              <span className="yan-eylem" onClick={e => e.stopPropagation()}>
                {o.yan.map(y => (
                  <button key={y.ik} type="button" title={y.ipucu} disabled={y.devre}
                          onClick={e => { e.stopPropagation(); if (!y.devre) y.fn() }}>
                    {y.ik}
                  </button>
                ))}
              </span>
            )}
          </button>
        </div>
      ))}
    </div>
  );
}
