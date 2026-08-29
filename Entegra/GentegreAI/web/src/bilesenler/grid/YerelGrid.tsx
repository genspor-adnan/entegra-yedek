import { useState } from 'react';
import { GridMenu, type MenuOgesi } from './GridMenu';
import { dosyaIndirUrl } from '../indir';

/**
 * YEREL GRID: elde hazır bir kayıt dizisini GenGrid diliyle gösterir -
 * başlığa tıklayınca sıralama (▲/▼), ilk kolon başlığındaki ⋮ menüsünde
 * "CSV Kaydet" + kolon göster/gizle (oturumluk).
 *
 * GenGrid'den farkı: sunucu listesine bağlı değil (sayfalama/filtre yok),
 * ekranda üretilmiş sonuçlar için - ÜTS sorgu sonucu, "hazırla" raporu gibi.
 */
export function YerelGrid({ kayitlar, kolonOncelik = [], adSozlugu = {},
                           gizliAlanlar, csvAdi, bicimle = varsayilanBicim,
                           bosMetin = 'Kayıt yok', maxYukseklik }: {
  kayitlar: Record<string, unknown>[];
  /** Bu adlar varsa önce ve bu sırayla çizilir; kalanlar geldiği sırada. */
  kolonOncelik?: string[];
  /** Alan adı → okunur başlık; eşi olmayan ham kalır. */
  adSozlugu?: Record<string, string>;
  /** Hiç gösterilmeyecek alanlar (kopya/gürültü kolonları). */
  gizliAlanlar?: Set<string>;
  csvAdi: string;
  bicimle?(deger: unknown): string;
  bosMetin?: string;
  /** Verilirse grid bu yükseklikte kalır, satırlar içeride kaydırılır. */
  maxYukseklik?: number;
}) {
  const [menuKonum, setMenuKonum] = useState<{ x: number; y: number } | null>(null);
  const [gizli, setGizli] = useState<Set<string>>(new Set());
  const [sirala, setSirala] = useState<{ ad: string; yon: 1 | -1 } | null>(null);

  const tumKolonlar: string[] = [];
  const gorulen = new Set<string>();
  for (const ad of kolonOncelik)
    if (kayitlar.some(k => k[ad] != null)) { tumKolonlar.push(ad); gorulen.add(ad); }
  for (const k of kayitlar)
    for (const ad of Object.keys(k))
      if (!gorulen.has(ad) && !gizliAlanlar?.has(ad) && k[ad] != null) {
        tumKolonlar.push(ad); gorulen.add(ad);
      }
  const kolonlar = tumKolonlar.filter(ad => !gizli.has(ad));

  // Yerel siralama: sayi kolonlari sayisal, digerleri metin (tr).
  const sirali = sirala
    ? [...kayitlar].sort((a, b) => {
        const x = a[sirala.ad]; const y = b[sirala.ad];
        const nx = Number(x); const ny = Number(y);
        const c = !Number.isNaN(nx) && !Number.isNaN(ny) && x !== '' && y !== ''
          ? nx - ny
          : String(x ?? '').localeCompare(String(y ?? ''), 'tr');
        return c * sirala.yon;
      })
    : kayitlar;
  const siralaTikla = (ad: string) => setSirala(t =>
    t?.ad === ad ? (t.yon === 1 ? { ad, yon: -1 } : null) : { ad, yon: 1 });

  const csvIndir = () => {
    const bas = kolonlar.map(ad => adSozlugu[ad] ?? ad).join(';');
    const govde = sirali.map(k =>
      kolonlar.map(ad => bicimle(k[ad]).replace(/;/g, ',')).join(';')).join('\n');
    // BOM: Excel CSV'yi UTF-8 okusun (Türkçe karakterler bozulmasın).
    const url = URL.createObjectURL(new Blob(['﻿' + bas + '\n' + govde],
      { type: 'text/csv;charset=utf-8' }));
    dosyaIndirUrl(url, csvAdi, true);
  };

  const menuOgeleri: MenuOgesi[] = [
    { ik: '📄', ad: 'CSV Kaydet', fn: csvIndir },
    ...tumKolonlar.map((ad, i) => ({
      ik: gizli.has(ad) ? '○' : '●',
      ad: adSozlugu[ad] ?? ad,
      secili: !gizli.has(ad),
      ayrac: i === 0,
      fn: () => setGizli(t => {
        const y = new Set(t);
        if (y.has(ad)) y.delete(ad); else if (kolonlar.length > 1) y.add(ad);
        return y;
      }),
    })),
  ];

  return (
    <div className="kagrup">
      <div style={{ overflowX: 'auto', maxHeight: maxYukseklik,
                    overflowY: maxYukseklik ? 'auto' : undefined }}>
        <table className="grid">
          <thead>
            <tr>
              {kolonlar.map((ad, i) => (
                <th key={ad} style={{ cursor: 'pointer', whiteSpace: 'nowrap' }}
                    onClick={() => siralaTikla(ad)}>
                  {/* ⋮ ILK KOLON basliginda (kullanici) - GenGrid'deki yerlesim.
                      stopPropagation SART: tik window'a kabarirsa GridMenu'nun
                      "disari tiklandi" dinleyicisi menuyu ANINDA kapatiyordu. */}
                  {i === 0 && (
                    <button type="button" title="Grid menüsü"
                            style={{ padding: '0 6px', marginRight: 6,
                                     border: 'none', background: 'transparent',
                                     cursor: 'pointer', fontWeight: 700,
                                     fontSize: 15, lineHeight: 1 }}
                            onClick={e => {
                              e.stopPropagation();
                              const r = e.currentTarget.getBoundingClientRect();
                              setMenuKonum(menuKonum ? null
                                : { x: r.left, y: r.bottom + 4 });
                            }}>⋮</button>
                  )}
                  {adSozlugu[ad] ?? ad}
                  {sirala?.ad === ad && (sirala.yon === 1 ? ' ▲' : ' ▼')}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {sirali.map((k, i) => (
              <tr key={i}>
                {kolonlar.map(ad => <td key={ad}>{bicimle(k[ad])}</td>)}
              </tr>
            ))}
            {sirali.length === 0 && (
              <tr><td colSpan={Math.max(kolonlar.length, 1)}
                      style={{ textAlign: 'center', padding: 12 }}>{bosMetin}</td></tr>
            )}
          </tbody>
        </table>
      </div>
      <GridMenu konum={menuKonum} ogeler={menuOgeleri}
                onKapat={() => setMenuKonum(null)} />
    </div>
  );
}

function varsayilanBicim(deger: unknown): string {
  if (deger == null) return '';
  if (typeof deger === 'object') return JSON.stringify(deger);
  return String(deger);
}
