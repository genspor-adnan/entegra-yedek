import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { type ListeSatiri, hataMetni } from '../api/sozlesme';

/**
 * RANDEVU TAKVİMİ (243) - günlük ve haftalık görünüm (kullanıcı isteği).
 *
 * Saat aralıkları ve çalışma günleri Randevu Ayarları'ndan gelir
 * (referans: randevu.baslangic_saat / bitis_saat / slot_dk / calisma_gunleri).
 * Hücreye tıklamak o saat için yeni randevu açar; dolu randevuya tıklamak
 * kartı açar - liste görünümüyle aynı kart, ikinci bir ekran yok.
 */
type Gorunum = 'gun' | 'hafta';

interface Ayarlar {
  baslangicSaat: string;
  bitisSaat: string;
  slotDk: number;
  calismaGunleri: number[];   // 1 Pzt … 7 Paz
}

const VARSAYILAN: Ayarlar = {
  baslangicSaat: '09:00', bitisSaat: '18:00', slotDk: 15,
  calismaGunleri: [1, 2, 3, 4, 5, 6],
};

const GUN_ADI = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/** "09:00" -> 540 (dakika). */
const dk = (saat: string) => {
  const [s, d] = (saat || '0:0').split(':').map(Number);
  return (s || 0) * 60 + (d || 0);
};
const saatMetni = (toplam: number) =>
  `${String(Math.floor(toplam / 60)).padStart(2, '0')}:${String(toplam % 60).padStart(2, '0')}`;

const isoGun = (t: Date) => t.toISOString().slice(0, 10);
/** Pazartesi başlangıçlı hafta. */
function haftaBasi(t: Date) {
  const g = new Date(t);
  const fark = (g.getDay() + 6) % 7;
  g.setDate(g.getDate() - fark);
  return g;
}

export function RandevuTakvimi({ ayarlar, onYeni, onAc, yenile }: {
  ayarlar?: Partial<Ayarlar>;
  /** Boş hücre: o tarih-saatte yeni randevu. */
  onYeni(baslangic: string): void;
  /** Dolu randevu: kartı aç. */
  onAc(id: number): void;
  /** Dışarıdan tazeleme sayacı (kayıt sonrası). */
  yenile?: number;
}) {
  const ayar = { ...VARSAYILAN, ...ayarlar };
  const [gorunum, setGorunum] = useState<Gorunum>('gun');
  const [gun, setGun] = useState(() => isoGun(new Date()));
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  // Gorunume gore tarih araligi.
  const gunler = useMemo(() => {
    if (gorunum === 'gun') return [gun];
    const bas = haftaBasi(new Date(gun));
    return Array.from({ length: 7 }, (_, i) => {
      const t = new Date(bas);
      t.setDate(bas.getDate() + i);
      return isoGun(t);
    }).filter((_, i) => ayar.calismaGunleri.includes(i + 1));
  }, [gorunum, gun, ayar.calismaGunleri]);

  const yukle = useCallback(async () => {
    if (gunler.length === 0) return;
    setYukleniyor(true); setHata('');
    try {
      const y = await api.liste('randevu', {
        sayfa: 1, boyut: 500,
        sirala: [{ alan: 'baslangic', yon: 'asc' }],
        filtre: {
          op: 'and',
          kosullar: [
            { alan: 'tarih', op: 'arasinda', deger: [gunler[0], gunler[gunler.length - 1]] },
            { alan: 'durum', op: 'esitDegil', deger: 4 },
          ],
        },
      });
      setSatirlar(y.satirlar);
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [gunler]);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  // Saat dilimleri (slot).
  const slotlar = useMemo(() => {
    const bas = dk(ayar.baslangicSaat);
    const bit = dk(ayar.bitisSaat);
    const adim = Math.max(5, Number(ayar.slotDk) || 15);
    const liste: number[] = [];
    for (let t = bas; t < bit; t += adim) liste.push(t);
    return liste;
  }, [ayar.baslangicSaat, ayar.bitisSaat, ayar.slotDk]);

  /** gun + slot -> o aralikta baslayan randevular. */
  const hucre = (tarih: string, slot: number) => {
    const adim = Math.max(5, Number(ayar.slotDk) || 15);
    return satirlar.filter(r => {
      if (String(r.tarih ?? '').slice(0, 10) !== tarih) return false;
      const b = dk(String(r.saat ?? ''));
      return b >= slot && b < slot + adim;
    });
  };

  const kaydir = (yon: number) => {
    const t = new Date(gun);
    t.setDate(t.getDate() + (gorunum === 'gun' ? yon : yon * 7));
    setGun(isoGun(t));
  };

  return (
    <div className="kagrup">
      <div className="numaralama-bas bitisik">
        <h6>Takvim</h6>
        <button type="button" className={`cip${gorunum === 'gun' ? ' on' : ''}`}
                onClick={() => setGorunum('gun')}>Günlük</button>
        <button type="button" className={`cip${gorunum === 'hafta' ? ' on' : ''}`}
                onClick={() => setGorunum('hafta')}>Haftalık</button>
        <button type="button" className="d" onClick={() => kaydir(-1)}>‹</button>
        <input type="date" value={gun} onChange={e => setGun(e.target.value)} />
        <button type="button" className="d" onClick={() => kaydir(1)}>›</button>
        <button type="button" className="d" onClick={() => setGun(isoGun(new Date()))}>
          Bugün
        </button>
        {yukleniyor && <span style={{ fontSize: 11, opacity: .7 }}>Yükleniyor…</span>}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div style={{ overflowX: 'auto' }}>
        <table className="grid randevu-takvim">
          <thead>
            <tr>
              <th style={{ width: 64 }}>Saat</th>
              {gunler.map(g => {
                const t = new Date(g);
                return (
                  <th key={g} style={{ textAlign: 'center' }}>
                    {GUN_ADI[(t.getDay() + 6) % 7]} {g.slice(8, 10)}.{g.slice(5, 7)}
                  </th>
                );
              })}
            </tr>
          </thead>
          <tbody>
            {slotlar.map(slot => (
              <tr key={slot}>
                <td style={{ textAlign: 'center', opacity: .75 }}>{saatMetni(slot)}</td>
                {gunler.map(g => {
                  const kayitlar = hucre(g, slot);
                  return (
                    <td key={g + slot} style={{ cursor: 'pointer', verticalAlign: 'top' }}
                        onClick={() => kayitlar.length === 0
                          && onYeni(`${g}T${saatMetni(slot)}`)}>
                      {kayitlar.map(r => (
                        <div key={String(r.id)}
                             onClick={e => { e.stopPropagation(); onAc(Number(r.id)) }}
                             title={`${String(r.hekim ?? '')} · ${String(r.bolumAdi ?? '')}`}
                             style={{
                               background: Number(r.durum) === 2 ? 'var(--okzem)'
                                          : Number(r.durum) === 3 ? 'var(--hatazem)'
                                          : 'var(--yuz2)',
                               border: '1px solid var(--cizgi)', borderRadius: 4,
                               padding: '2px 6px', marginBottom: 2, fontSize: 11.5,
                             }}>
                          <b>{String(r.hasta ?? '')}</b>
                          <div style={{ opacity: .75 }}>
                            {String(r.saat ?? '')}–{String(r.bitis ?? '')} · {String(r.hekim ?? '')}
                          </div>
                        </div>
                      ))}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
