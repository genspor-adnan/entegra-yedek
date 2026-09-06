import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { code128Desen } from '../bilesenler/barkod128';

/**
 * TÜP BARKOD ETİKETİ (444, mockup: Ekranlar/Lab/lab_istem_numune_kabul.html).
 *
 * <b>Etiket fiziksel bir belgedir</b>: tüpün üstüne yapışır, cihaz onu okur,
 * kabul ekranı onu arar. Bu yüzden çıktı ekrandan ayrı bir sayfa - araç
 * çubuğu ve menü basılmaz, sayfada yalnız etiketler kalır.
 *
 * <b>Hasta adı kısaltılır ama yaş/cinsiyet ve doğum tarihi kalır.</b> 35 mm
 * genişliğinde tam ad sığmıyor; aynı adlı iki hasta ise laboratuvarın klasik
 * kazası - ayırt eden bilgi doğum tarihidir.
 *
 * <b>Acil istemde kırmızı şerit</b> (mockup kuralı): cihazda STAT önceliği
 * alacak tüp, kan alma bankosunda da bakışta ayrılmalı.
 *
 * Barkod SVG olarak çizilir (bkz. barkod128.ts): raster görüntüde dar barlar
 * yazıcıda kayboluyor, hazır kütüphane ise tek barkod için onlarca KB.
 */

type Satir = Record<string, unknown>;

const TUP: Record<number, { ad: string; renk: string; yazi?: string }> = {
  1: { ad: 'SARI (jelli)', renk: '#e8c33a' },
  2: { ad: 'MOR (EDTA)', renk: '#8d6bb5', yazi: '#fff' },
  3: { ad: 'MAVİ (sitrat)', renk: '#4d8fd6', yazi: '#fff' },
  4: { ad: 'GRİ (florür)', renk: '#9aa5b1' },
  5: { ad: 'YEŞİL (heparin)', renk: '#4e9e72', yazi: '#fff' },
  6: { ad: 'İDRAR KABI', renk: '#d9b871' },
  9: { ad: 'DİĞER', renk: '#c9d6e5' },
};

const NUMUNE: Record<number, string> = {
  1: 'Serum', 2: 'Plazma', 3: 'Tam kan', 4: 'İdrar', 5: 'Gaita',
  6: 'BOS', 7: 'Sürüntü', 9: 'Diğer',
};

const CINSIYET: Record<number, string> = { 1: 'E', 2: 'K' };

/** "AYŞE YILMAZ" → "Yılmaz A." — etikete sığan ama ayırt eden biçim. */
const kisaAd = (tam: string): string => {
  const p = tam.trim().split(/\s+/).filter(Boolean);
  if (p.length === 0) return '';
  if (p.length === 1) return p[0];
  const soyad = p[p.length - 1];
  const ad = p.slice(0, -1).map(x => x[0] + '.').join('');
  const duzelt = (s: string) =>
    s.charAt(0) + s.slice(1).toLocaleLowerCase('tr');
  return `${duzelt(soyad)} ${ad.toLocaleUpperCase('tr')}`;
};

const gun = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '';
};

const gunAy = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? `${m.slice(8, 10)}.${m.slice(5, 7)}` : '';
};

const yas = (dogum: unknown): string => {
  const m = String(dogum ?? '').slice(0, 10);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(m)) return '';
  const d = new Date(m), b = new Date();
  let y = b.getFullYear() - d.getFullYear();
  const ay = b.getMonth() - d.getMonth();
  if (ay < 0 || (ay === 0 && b.getDate() < d.getDate())) y--;
  return String(y);
};

/** Code 128 desenini SVG çubuklarına çevirir. */
function Barkod({ metin, yukseklik = 34, modul = 1.6 }:
                { metin: string; yukseklik?: number; modul?: number }) {
  const desen = code128Desen(metin);
  if (!desen) return null;
  const cubuklar: { x: number; g: number }[] = [];
  let x = 0;
  for (let i = 0; i < desen.length;) {
    let n = 1;
    while (i + n < desen.length && desen[i + n] === desen[i]) n++;
    if (desen[i] === '1') cubuklar.push({ x: x, g: n * modul });
    x += n * modul;
    i += n;
  }
  return (
    <svg className="etiket-barkod" width={desen.length * modul} height={yukseklik}
         viewBox={`0 0 ${desen.length * modul} ${yukseklik}`}
         shapeRendering="crispEdges" role="img" aria-label={`Barkod ${metin}`}>
      {cubuklar.map((c, i) => (
        <rect key={i} x={c.x} y={0} width={c.g} height={yukseklik} fill="#000" />
      ))}
    </svg>
  );
}

export function LabEtiket() {
  const [param] = useSearchParams();
  const git = useNavigate();
  const istemId = param.get('istem') ? Number(param.get('istem')) : undefined;
  const numuneId = param.get('numune') ? Number(param.get('numune')) : undefined;
  const [kopya, setKopya] = useState(1);
  const [veri, setVeri] = useState<{ etiketler: Satir[]; kurum: Satir | null } | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try { setVeri(await api.labEtiket({ istemId, numuneId }) as never) }
    catch (h) { setHata(hataMetni(h)) }
  }, [istemId, numuneId]);

  useEffect(() => { void yukle() }, [yukle]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;

  const hazirlik = veri.etiketler
    .map(e => String(e.hazirlik ?? '').trim())
    .filter(Boolean)
    .filter((v, i, a) => a.indexOf(v) === i);

  // KOPYA: aynı tüpten iki etiket (biri tüpe, biri isteme/arşive) yaygın
  //   uygulama; ayrı ayrı basmak yerine adet seçilir.
  const basilacak = veri.etiketler.flatMap(e =>
    Array.from({ length: kopya }, (_, k) => ({ e, k })));

  return (
    <div className="etiket-sayfa">
      <div className="cikti-arac">
        <button className="d bir" onClick={() => window.print()}>🏷 Etiketleri Bas</button>
        <span className="not">Kopya:</span>
        {[1, 2, 3].map(n => (
          <button key={n} className={`d${n === kopya ? ' bir' : ''}`}
                  onClick={() => setKopya(n)}>{n}×</button>
        ))}
        <span className="not">
          {veri.etiketler.length} tüp · {basilacak.length} etiket
        </span>
        <span style={{ marginLeft: 'auto' }} />
        <button className="d" onClick={() => git(-1)}>✖ Kapat</button>
      </div>

      {/* HASTA HAZIRLIĞI etikete basılmaz (yer yok) ama bankoda görünür:
          açlık gerektiren tetkikte tüp alınmadan önce sorulmalı. */}
      {hazirlik.length > 0 && (
        <div className="uyari-kutusu yazdirma">
          ⚠ Hasta hazırlığı: {hazirlik.join(' · ')}
        </div>
      )}

      <div className="etiketler">
        {basilacak.map(({ e, k }) => {
          const tup = TUP[Number(e.tupTipi ?? 9)] ?? TUP[9];
          const acil = Number(e.oncelik ?? 1) === 3;
          const barkod = String(e.barkod ?? '');
          return (
            <div className={`etiket${acil ? ' acil' : ''}`} key={`${e.id}-${k}`}>
              <div className="serit" style={{ background: tup.renk }} />
              <div className="govde">
                <div className="ust">
                  <b className="tup" style={{ color: tup.renk === '#e8c33a'
                                                     ? '#8a6d0b' : tup.renk }}>
                    {tup.ad}
                  </b>
                  {acil && <span className="acil-rozet">ACİL / STAT</span>}
                  <span className="tarih">{gunAy(e.istemTarihi)}</span>
                </div>

                <Barkod metin={barkod} />
                <div className="barkod-metin">{barkod}</div>

                <div className="hasta">
                  {kisaAd(String(e.hasta ?? ''))}
                  {' · '}
                  {[yas(e.dogumTarihi), CINSIYET[Number(e.cinsiyet ?? 0)] ?? '']
                    .filter(Boolean).join('')}
                  {gun(e.dogumTarihi) ? ` · ${gun(e.dogumTarihi)}` : ''}
                </div>
                <div className="alt">
                  {String(e.istemNo ?? '')}
                  {String(e.tetkikler ?? '') ? ` · ${e.tetkikler}` : ''}
                </div>
                <div className="alt2">
                  {NUMUNE[Number(e.numuneTipi ?? 0)] ?? ''}
                  {String(e.bolumler ?? '') ? ` · ${e.bolumler}` : ''}
                  {kopya > 1 ? ` · ${k + 1}/${kopya}` : ''}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
