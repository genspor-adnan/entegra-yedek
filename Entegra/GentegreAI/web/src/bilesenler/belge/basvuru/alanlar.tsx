import { useEffect, useState } from 'react';
import { api } from '../../../api/istemci';

/**
 * BASVURU / PROVIZYON EKRANLARININ ORTAK ALAN BILESENLERI.
 *
 * Uc ekran da ayni kutulari kullaniyor (kod listesi combosu, segment,
 * kisa metin, zaman); tek dosyada durunca yeni bir alan turu eklemek de
 * bicim degisikligi de tek yerde oluyor.
 */
/** Kod listesi combosu - deger kod_deger.deger, gosterim ad. */
export function KodSecim({ etiket, listeKod, deger, onDeger, kilitli, zorunlu, vurgu }: {
  etiket: string; listeKod: string; deger?: number | null;
  onDeger(v: number | null): void; kilitli?: boolean; zorunlu?: boolean;
  /**
   * Bu deger SECILIYSE combo kirmizi cizilir (or. Acil). Segment'ten combo'ya
   * dondugunde (kullanici: "başvuru türünü combo ya dönüştür") acil vurgusu
   * kaybolmasin - "acil mi degil mi" listede goze carpan seydi.
   */
  vurgu?: number;
}) {
  const [secenekler, setSecenekler] = useState<{ deger: number; ad: string }[]>([]);
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe(listeKod);
        if (!iptal) setSecenekler(y.degerler.filter(d => d.aktif === 1));
      } catch { /* liste yoksa combo bos kalir - kayit engellenmez */ }
    })();
    return () => { iptal = true };
  }, [listeKod]);

  return (
    <label className="alan">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <select className={vurgu != null && Number(deger ?? 0) === vurgu ? 'acil' : undefined}
              value={deger ?? ''} disabled={kilitli}
              onChange={e => onDeger(e.target.value ? Number(e.target.value) : null)}>
        <option value="">— Seçiniz —</option>
        {secenekler.map(x => <option key={x.deger} value={x.deger}>{x.ad}</option>)}
      </select>
    </label>
  );
}

/**
 * SEGMENT SECIM (mockup .seg): kod listesini combo yerine yan yana dugmelerle
 * gosterir - az secenekli, sik kullanilan alanlar icin (Başvuru Türü). Liste
 * beklenenden uzun gelirse (5'ten fazla) combo'ya duser: 10 dugme satiri
 * tasirirdi.
 */
export function KodSegment({ etiket, listeKod, deger, onDeger, kilitli, zorunlu, vurgu }: {
  etiket: string; listeKod: string; deger?: number | null;
  onDeger(v: number | null): void; kilitli?: boolean; zorunlu?: boolean;
  /** Bu degerdeki secenek secilince KIRMIZI cizilir (ör. Acil). */
  vurgu?: number;
}) {
  const [secenekler, setSecenekler] = useState<{ deger: number; ad: string }[]>([]);
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe(listeKod);
        if (!iptal) setSecenekler(y.degerler.filter(d => d.aktif === 1));
      } catch { /* liste yoksa segment bos kalir - kayit engellenmez */ }
    })();
    return () => { iptal = true };
  }, [listeKod]);

  if (secenekler.length > 5) {
    return <KodSecim etiket={etiket} listeKod={listeKod} deger={deger}
                     onDeger={onDeger} kilitli={kilitli} zorunlu={zorunlu} />;
  }
  return (
    <label className="alan genis-4">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <span className={`seg${kilitli ? ' kilitli' : ''}`}>
        {secenekler.map(s => (
          <span key={s.deger}
                className={`s${s.deger === vurgu ? ' acil' : ''}`
                           + (Number(deger ?? 0) === s.deger ? ' on' : '')}
                onClick={() => { if (!kilitli) onDeger(s.deger) }}>
            {s.ad}
          </span>
        ))}
      </span>
    </label>
  );
}

/** Kisa metin alani. */
export function MetinAlani({ etiket, deger, onDeger, kilitli, ipucu }: {
  etiket: string; deger?: string; onDeger(v: string): void;
  kilitli?: boolean; ipucu?: string;
}) {
  return (
    <label className="alan">
      <span className="etiket">{etiket}</span>
      <input value={deger ?? ''} disabled={kilitli} placeholder={ipucu}
             onChange={e => onDeger(e.target.value)} />
    </label>
  );
}

/**
 * Tarih-saat alani. Bos deger `null` gider: bos metin ('') gonderilirse
 * sunucu onu gecersiz tarih sayip "bos birakilamaz" hatasi verir.
 */
export function ZamanAlani({ etiket, deger, onDeger, kilitli }: {
  etiket: string; deger?: string | null; onDeger(v: string | null): void;
  kilitli?: boolean;
}) {
  return (
    <label className="alan">
      <span className="etiket">{etiket}</span>
      <input type="datetime-local" value={String(deger ?? '').slice(0, 16)}
             disabled={kilitli}
             onChange={e => onDeger(e.target.value || null)} />
    </label>
  );
}

// ====================================================== HASTA SERIDI ====

/** Mustehaklik sorgusunun uc sonucu - rozet adi ve rengi. */
export const MUSTEHAKLIK: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Sorgulanmadı', sinif: '' },
  1: { ad: 'Müstehak',     sinif: 'olumlu' },
  2: { ad: 'Müstehak değil', sinif: 'teh' },
};

