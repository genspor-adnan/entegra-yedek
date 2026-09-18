/**
 * PORTAL MENÜSÜ V2 (796/818) — saf mantık, React yok.
 *
 * Mockup: `Ekranlar/Portal/portal_dis_doktor.html`, `portal_dis_kurum.html`,
 * `portal_hasta.html` — sol dar menü, kısa liste, gruplar üstünde küçük
 * başlık.
 *
 * <b>Kaynak tek:</b> hangi ekranların görüneceğine YETKİ karar verir
 * (`menuSatirlariKur` zaten yetki + ürün modu + modül süzgecinden geçmiş
 * satırları veriyor). Buradaki tablo yalnız <i>adlandırma ve gruplama</i>
 * yapar: portal kullanıcısına "Hasta Listesi" değil "Hastalarım" denir,
 * "Teleradyoloji çalışma listesi" değil "Tetkiklerim".
 *
 * <b>Tabloda olmayan ekran GİZLENMEZ:</b> "Diğer" bölümüne düşer. Yetkisi
 * olan bir ekranı menüden düşürmek, kullanıcının erişimi varmış gibi görünüp
 * ekranı bulamaması demekti - yetki eklendiğinde menü kendiliğinden büyür.
 */

export interface PortalOgesi {
  yol: string;
  ad: string;
  ic: string;
}

export interface PortalBolumu {
  ad: string;
  ogeler: PortalOgesi[];
}

/** Menü satırının portal menüsünde ihtiyaç duyulan alanları. */
export interface MenuKaynagi {
  yol: string;
  ad: string;
  ic: string;
  /** Çevrilmemiş ad - eşleme dilden bağımsız olsun. */
  adHam?: string;
  /**
   * Ekranın liste KAYNAĞI (`telerad-teslim` gibi). Kapsam süzgeci bununla
   * çalışır; özel sayfalarda (pano, ayar) yoktur.
   */
  kaynak?: string;
}

/** 1 dış doktor · 2 dış kurum · 3 hasta. */
export type PortalTuru = 1 | 2 | 3;

interface Etiket { ad: string; ic: string; bolum: string; sira: number }

/**
 * YOL -> (ad, ikon, bölüm) eşlemesi. Anahtar ROTA'dır: menü adı dile göre
 * değişir, rota değişmez.
 *
 * Aynı ekran üç portalda farklı adlanır: dış hekimin "İstemlerim"i kendi
 * açtığı istemler, hastanınki kendi tetkikleri. Tek ad kullanmak üçünden
 * ikisinde yanlış olurdu.
 */
const ETIKETLER: Record<PortalTuru, Record<string, Etiket>> = {
  // ---------------------------------------------------------- dış doktor ----
  1: {
    '/hasta':           { ad: 'Hastalarım',         ic: '👤', bolum: 'Portal', sira: 10 },
    '/lab-istem':       { ad: 'Lab istemlerim',     ic: '🧾', bolum: 'Laboratuvar', sira: 20 },
    '/lab-numune':      { ad: 'Numune durumu',      ic: '🔎', bolum: 'Laboratuvar', sira: 30 },
    '/lab-sonuc':       { ad: 'Lab sonuçları',      ic: '📄', bolum: 'Laboratuvar', sira: 40 },
    '/radyoloji':       { ad: 'Tetkiklerim',        ic: '🖥', bolum: 'Radyoloji', sira: 50 },
    '/mesajlar':        { ad: 'Yazışmalar',         ic: '💬', bolum: 'İşlem', sira: 70 },
    '/yapay-zeka':      { ad: 'Yardım (AI rehber)', ic: '❓', bolum: 'İşlem', sira: 90 },
  },
  // ------------------------------------------------------------ dış kurum ----
  2: {
    '/hasta':           { ad: 'Gönderdiğim hastalar', ic: '👤', bolum: 'Portal', sira: 10 },
    '/lab-istem':       { ad: 'İstemlerim',           ic: '🧾', bolum: 'Laboratuvar', sira: 20 },
    '/lab-numune':      { ad: 'Numune durumu',        ic: '🔎', bolum: 'Laboratuvar', sira: 30 },
    '/lab-sonuc':       { ad: 'Lab sonuçları',        ic: '📄', bolum: 'Laboratuvar', sira: 40 },
    '/teleradyoloji':   { ad: 'Görüntü isteklerim',   ic: '🖥', bolum: 'Görüntüleme', sira: 50 },
    // İSG FİRMA YETKİLİSİ (830): OSGB'nin anlaşmalı firmasının kendi
    //   kayıtları. Aynı portal türünü (kurum) kullanır; hangi satırların
    //   çıkacağına yetki karar verir - klinik/yönetici rolünde `isg.*` yok.
    '/isg-firma':       { ad: 'Firmam',                ic: '🏭', bolum: 'Portal', sira: 12 },
    '/isg-calisan':     { ad: 'Çalışanlarım',          ic: '👷', bolum: 'Portal', sira: 14 },
    // MALİ (824): yalnız YÖNETİCİ rolünde açılır - klinik rolde `portal.mali`
    //   yetkisi yok, menü satırı hiç üretilmez.
    '/kurum-belge':     { ad: 'Faturalarım',          ic: '🧾', bolum: 'Mali', sira: 60 },
    '/kurum-ekstre':    { ad: 'Cari ekstrem',         ic: '📑', bolum: 'Mali', sira: 62 },
    '/mesajlar':        { ad: 'Yazışmalar',           ic: '💬', bolum: 'İşlem', sira: 70 },
    '/yapay-zeka':      { ad: 'Yardım (AI rehber)',   ic: '❓', bolum: 'İşlem', sira: 90 },
  },
  // ----------------------------------------------------------------- hasta ----
  3: {
    '/hasta':           { ad: 'Kayıtlarım',         ic: '🪪', bolum: 'Portalım', sira: 10 },
    '/randevu':         { ad: 'Randevularım',       ic: '📅', bolum: 'Portalım', sira: 20 },
    '/lab-sonuc':       { ad: 'Lab sonuçlarım',     ic: '🧪', bolum: 'Sonuçlarım', sira: 30 },
    '/lab-istem':       { ad: 'Tetkik istemlerim',  ic: '🧾', bolum: 'Sonuçlarım', sira: 40 },
    '/radyoloji':       { ad: 'Görüntülemelerim',   ic: '🖥', bolum: 'Sonuçlarım', sira: 50 },
    '/yapay-zeka':      { ad: 'Yardım',             ic: '❓', bolum: 'Hesabım', sira: 90 },
  },
};

/** Bölüm sırası portal türüne göre - mockuplardaki sıra. */
const BOLUM_SIRASI: Record<PortalTuru, string[]> = {
  1: ['Portal', 'Laboratuvar', 'Radyoloji', 'İşlem'],
  2: ['Portal', 'Laboratuvar', 'Görüntüleme', 'Mali', 'İşlem'],
  3: ['Portalım', 'Sonuçlarım', 'Hesabım'],
};

const DIGER = 'Diğer';

export const PORTAL_ADI: Record<PortalTuru, string> = {
  1: 'Hekim Portalı',
  2: 'Kurum Portalı',
  3: 'Hasta Portalı',
};

/**
 * Yetkili menü öğelerini portal bölümlerine ayırır.
 *
 * Boş bölüm hiç dönmez: "Laboratuvar" başlığı altında hiçbir şey yoksa
 * başlığın kendisi de çizilmez.
 */
export function portalBolumleri(ogeler: MenuKaynagi[], portalTuru: PortalTuru,
                                portalKaynaklar?: string[]): PortalBolumu[] {
  const tablo = ETIKETLER[portalTuru] ?? {};
  const kova = new Map<string, { oge: PortalOgesi; sira: number }[]>();
  const kapsam = portalKaynaklar ? new Set(portalKaynaklar) : null;

  for (const m of ogeler) {
    // KAPSAMI KAPALI EKRAN MENÜDE DURMAZ (796 V2): dış kurum rolünde
    //   `teleradyoloji` yetkisi var ama "Teslim Kuyruğu" ekranının portal
    //   kuralı `false` - açılsa boş gelirdi. Boş gelecek ekranı göstermek,
    //   her zaman hata veren düğme göstermekle aynı sınıfta.
    //
    //   Eşleme tablosunda ADI GEÇEN ekran süzgeçten muaf: onlar portal için
    //   bilerek seçilmiş ekranlar (mesajlaşma, AI rehber gibi kaynağı
    //   olmayanlar da buradan geçer).
    const tabloda = m.yol in tablo;
    if (!tabloda && kapsam && m.kaynak && !kapsam.has(m.kaynak)) continue;
    if (!tabloda && kapsam && !m.kaynak) continue;
    const e = tablo[m.yol];
    const bolum = e?.bolum ?? DIGER;
    // Eşlemede yoksa ekranın KENDİ adı kullanılır: uydurma ad, kullanıcının
    //   aradığı ekranı bulamaması demek olurdu.
    const oge: PortalOgesi = { yol: m.yol, ad: e?.ad ?? m.ad, ic: e?.ic ?? m.ic };
    const liste = kova.get(bolum) ?? [];
    liste.push({ oge, sira: e?.sira ?? 1000 });
    kova.set(bolum, liste);
  }

  const sirali = [...BOLUM_SIRASI[portalTuru] ?? [], DIGER];
  const sonuc: PortalBolumu[] = [];
  for (const ad of sirali) {
    const liste = kova.get(ad);
    if (!liste || liste.length === 0) continue;
    sonuc.push({
      ad,
      ogeler: [...liste].sort((a, b) => a.sira - b.sira || a.oge.ad.localeCompare(b.oge.ad, 'tr'))
                        .map(x => x.oge),
    });
    kova.delete(ad);
  }
  // Sıralamada adı geçmeyen bölüm (ileride eklenen) kaybolmasın.
  for (const [ad, liste] of kova)
    sonuc.push({ ad, ogeler: liste.map(x => x.oge) });
  return sonuc;
}

/** Aktif yola karşılık gelen bölüm - açılır menüde o bölüm açık gelir. */
export function aktifBolum(bolumler: PortalBolumu[], yol: string): string | null {
  // EN UZUN EŞLEŞME: "/lab-sonuc" ile "/lab" aynı anda eşleşirse derindeki.
  let enIyi: { ad: string; uzunluk: number } | null = null;
  for (const b of bolumler)
    for (const o of b.ogeler)
      if ((yol === o.yol || yol.startsWith(o.yol + '/'))
          && (!enIyi || o.yol.length > enIyi.uzunluk))
        enIyi = { ad: b.ad, uzunluk: o.yol.length };
  return enIyi?.ad ?? null;
}
