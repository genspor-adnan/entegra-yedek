import { Fragment } from 'react';
import type { KolonMeta } from '../api/sozlesme';

/**
 * GRID HUCRE YARDIMCILARI - durum rozeti, JSON/log govdesi cozumleme,
 * "eski -> yeni" degisim ayirmasi ve gorunum seridi.
 *
 * GenGrid 1002 satira ulasmisti; bu parcalar gridin DURUMUNA dokunmuyor
 * (yalniz gelen degeri bicimliyor), o yuzden ayri dosyada.
 */
/**
 * GENEL KURAL: aktif/pasif durumu her listede AYNI gorunur - yesil "Aktif" /
 * kirmizi "Pasif" rozeti (kullanici: "durumlar hep boyle gosterilmeli").
 *
 * Iki kaynak: mantik tipli `durum` kolonu (1/0) ve sunucuda metne cevrilmis
 * durum kolonlari ("Aktif"/"Pasif"). Belge/kasa gibi COK DEGERLI durum
 * kolonlari (taslak/kesin/iptal) bu kalibin disinda kalir - onlar rozet degil
 * duz metin, cunku iki renkli bir gosterim yaniltirdi.
 */
export function durumRozeti(deger: unknown, kolon: KolonMeta) {
  // "durum" kolonu bazi kaynaklarda mantik (1/0), bazilarinda kod tipinde -
  //   ikisinde de AYNI rozet cikmali; kod tipinde ham "1" gostermek kullaniciya
  //   hicbir sey soylemiyordu. Cok degerli durum kolonlari (belge/kasa:
  //   taslak/kesin/iptal) 0/1 disinda deger tasidigi icin bu kalibin disinda kalir.
  const sayisalDurum = kolon.ad === 'durum'
    && (kolon.tip === 'mantik' || kolon.tip === 'kod')
    && (Number(deger) === 1 || Number(deger) === 0);
  const aktifMi =
    sayisalDurum ? Number(deger) === 1
    : deger === 'Aktif' ? true
    : deger === 'Pasif' ? false
    : null;
  if (aktifMi === null) return null;
  return (
    <span className={`rozet ${aktifMi ? 'ok' : 'hata'}`}>{aktifMi ? 'Aktif' : 'Pasif'}</span>
  );
}

/** "İçerik" penceresi (ör. islem-log > bilgi) - JSON ise okunakli bicimde, degilse duz metin. */
export function icerikMetni(deger: unknown): string {
  if (deger === null || deger === undefined || deger === '') return 'İçerik yok.';
  if (typeof deger !== 'string') return String(deger);
  try {
    return JSON.stringify(JSON.parse(deger), null, 2);
  } catch {
    return deger;
  }
}

export function jsonCoz(deger: unknown): unknown {
  if (deger === null || deger === undefined || deger === '') return null;
  if (typeof deger !== 'string') return deger;
  try {
    return JSON.parse(deger);
  } catch {
    return deger;
  }
}

export const degerMetni = (deger: unknown) =>
  deger === null || deger === undefined || deger === '' ? '-' : String(deger);

export const degisimAyir = (deger: unknown): { onceki?: string; sonraki?: string; duz: string } => {
  const metin = degerMetni(deger);
  const ayirac = ' -> ';
  const indeks = metin.indexOf(ayirac);
  if (indeks < 0) return { duz: metin };
  return {
    onceki: metin.slice(0, indeks) || '-',
    sonraki: metin.slice(indeks + ayirac.length) || '-',
    duz: metin,
  };
};

export function LogTablosu({ deger }: { deger: unknown }) {
  const veri = jsonCoz(deger);
  if (veri === null) return <div className="grid-bilgi">İçerik yok.</div>;
  if (typeof veri !== 'object') return <div className="grid-bilgi">{icerikMetni(veri)}</div>;

  const satirlar: { bolum: string; alan: string; onceki?: string; sonraki?: string; deger: string }[] = [];
  const ekle = (bolum: string, alan: string, ham: unknown) => {
    const d = degisimAyir(ham);
    satirlar.push({ bolum, alan, onceki: d.onceki, sonraki: d.sonraki, deger: d.duz });
  };
  const nesneEkle = (bolum: string, nesne: Record<string, unknown>) =>
    Object.entries(nesne).forEach(([alan, ham]) => ekle(bolum, alan, ham));

  const kok = veri as Record<string, unknown>;
  if (kok.kart && typeof kok.kart === 'object' && !Array.isArray(kok.kart))
    nesneEkle('Kart', kok.kart as Record<string, unknown>);
  if (kok.detaylar && typeof kok.detaylar === 'object' && !Array.isArray(kok.detaylar)) {
    Object.entries(kok.detaylar as Record<string, unknown>).forEach(([detayAd, liste]) => {
      if (Array.isArray(liste)) {
        liste.forEach((satir, i) => {
          if (satir && typeof satir === 'object' && !Array.isArray(satir))
            nesneEkle(`${detayAd} #${i + 1}`, satir as Record<string, unknown>);
        });
      }
    });
  }
  if (satirlar.length === 0) nesneEkle('Bilgi', kok);

  const degisimVar = satirlar.some(s => s.onceki !== undefined || s.sonraki !== undefined);
  const gruplar = satirlar.reduce<Record<string, typeof satirlar>>((sonuc, satir) => {
    (sonuc[satir.bolum] ??= []).push(satir);
    return sonuc;
  }, {});
  const kolonSayisi = degisimVar ? 3 : 2;

  return (
    <table className="grid">
      <thead>
        <tr>
          <th>Alan</th>
          {degisimVar ? <><th>Önceki</th><th>Sonraki</th></> : <th>Değer</th>}
        </tr>
      </thead>
      <tbody>
        {Object.entries(gruplar).map(([bolum, liste]) => (
          <Fragment key={bolum}>
            <tr className="log-bolum-satiri">
              <td colSpan={kolonSayisi}>Bölüm: {bolum}</td>
            </tr>
            {liste.map((s, i) => (
              <tr key={`${s.bolum}:${s.alan}:${i}`}>
                <td>{s.alan}</td>
                {degisimVar ? <><td>{s.onceki ?? '-'}</td><td>{s.sonraki ?? s.deger}</td></> : <td>{s.deger}</td>}
              </tr>
            ))}
          </Fragment>
        ))}
      </tbody>
    </table>
  );
}

/** Mockup: cip seridinde Liste/Grup/Analiz gorunum secimi (search kutusunun hemen sagi). */
export const GORUNUMLER: { v: 'liste' | 'grup' | 'analiz'; ik: string; ad: string }[] = [
  { v: 'liste', ik: '▤', ad: 'Liste' },
  { v: 'grup', ik: '▦', ad: 'Grup' },
  { v: 'analiz', ik: '📊', ad: 'Analiz' },
];
