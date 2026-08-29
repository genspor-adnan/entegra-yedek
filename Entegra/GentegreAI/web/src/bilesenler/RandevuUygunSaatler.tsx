import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { type RandevuBolumDugumu, hataMetni } from '../api/sozlesme';

/**
 * UYGUN SAATLER ŞERİDİ (Ekranlar/randevu_karti.html): seçili hekim ve tarih
 * için o günün slotları. Dolu saatler çizili ve tıklanamaz, seçili saat
 * maviyle işaretli; boş bir saate tıklamak kartın başlangıcını oraya taşır.
 *
 * Saat düzeni MİRAS zinciriyle çözülür (251): hekimin kendi ayarı → bölümün
 * ayarı → Genel Ayarlar. Kartın kendi süresi slot adımını değiştirmez; süre
 * yalnız DOLULUK hesabında kullanılır (20 dk'lık randevu iki 15 dk'lık slotu
 * kapatır).
 */
interface Ayar {
  baslangicSaat: string;
  bitisSaat: string;
  ogleBaslangic: string;
  ogleBitis: string;
  slotDk: number;
}

const VARSAYILAN: Ayar = {
  baslangicSaat: '09:00', bitisSaat: '18:00',
  ogleBaslangic: '', ogleBitis: '', slotDk: 15,
};

const dk = (saat: string) => {
  const [s, d] = (saat || '').split(':').map(Number);
  return Number.isFinite(s) ? (s || 0) * 60 + (d || 0) : NaN;
};
const saatMetni = (t: number) =>
  `${String(Math.floor(t / 60)).padStart(2, '0')}:${String(t % 60).padStart(2, '0')}`;

export function RandevuUygunSaatler({ hekimId, hekimAdi, bolum, tarih, sureDk, seciliSaat,
                                      hariçId, onSec }: {
  hekimId: number | null;
  /** Baslikta gosterilir (mockup: "Uygun Saatler — 02.09.2026 · Uzm. Dr. ..."). */
  hekimAdi?: string;
  bolum: number | null;
  /** yyyy-mm-dd */
  tarih: string;
  sureDk: number;
  /** HH:mm - kartta seçili saat. */
  seciliSaat: string;
  /** Düzenlenen randevu (kendi saatini "dolu" saymamak için). */
  hariçId?: number | null;
  onSec(saat: string): void;
}) {
  const [dolu, setDolu] = useState<{ bas: number; bit: number }[]>([]);
  const [agac, setAgac] = useState<RandevuBolumDugumu[]>([]);
  const [genel, setGenel] = useState<Ayar>(VARSAYILAN);
  const [hata, setHata] = useState('');

  // Genel ayarlar + bölüm/hekim düzeni: kart açıkken bir kez.
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const [ayarlar, dugumler] = await Promise.all([
          api.ayarlar(), api.randevuBolumleri(),
        ]);
        if (iptal) return;
        const bul = (a: string) => ayarlar.find(x => x.anahtar === a)?.deger ?? '';
        setGenel({
          baslangicSaat: bul('randevu.baslangic_saat') || VARSAYILAN.baslangicSaat,
          bitisSaat: bul('randevu.bitis_saat') || VARSAYILAN.bitisSaat,
          ogleBaslangic: bul('randevu.ogle_baslangic'),
          ogleBitis: bul('randevu.ogle_bitis'),
          slotDk: Number(bul('randevu.slot_dk')) || VARSAYILAN.slotDk,
        });
        setAgac(dugumler);
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
    })();
    return () => { iptal = true };
  }, []);

  /** Hekim → bölüm → genel: ilk dolu değer kazanır. */
  const ayar = useMemo<Ayar>(() => {
    const bolumDugum = agac.find(d => d.departmanId === bolum)
      ?? agac.find(d => d.hekimler.some(h => h.hekimId === hekimId));
    const hekimAyar = bolumDugum?.hekimler.find(h => h.hekimId === hekimId);
    const ilk = (...a: (string | number | null | undefined)[]) =>
      a.find(v => v !== '' && v !== null && v !== undefined);
    return {
      baslangicSaat: String(ilk(hekimAyar?.baslangicSaat, bolumDugum?.ayar.baslangicSaat,
                                genel.baslangicSaat)),
      bitisSaat: String(ilk(hekimAyar?.bitisSaat, bolumDugum?.ayar.bitisSaat, genel.bitisSaat)),
      ogleBaslangic: String(ilk(hekimAyar?.ogleBaslangic, bolumDugum?.ayar.ogleBaslangic,
                                genel.ogleBaslangic) ?? ''),
      ogleBitis: String(ilk(hekimAyar?.ogleBitis, bolumDugum?.ayar.ogleBitis,
                            genel.ogleBitis) ?? ''),
      slotDk: Number(ilk(hekimAyar?.slotDk, bolumDugum?.ayar.slotDk, genel.slotDk)) || 15,
    };
  }, [agac, bolum, hekimId, genel]);

  // O hekimin o günkü randevuları (iptaller hariç).
  const yukle = useCallback(async () => {
    if (!hekimId || !tarih) { setDolu([]); return }
    try {
      const y = await api.liste('randevu', {
        sayfa: 1, boyut: 200,
        filtre: {
          op: 'and',
          kosullar: [
            { alan: 'hekimId', op: 'esit', deger: hekimId },
            { alan: 'tarih', op: 'esit', deger: tarih },
            { alan: 'durum', op: 'esitDegil', deger: 4 },
          ],
        },
      });
      setDolu(y.satirlar
        .filter(r => !hariçId || Number(r.id) !== hariçId)
        .map(r => {
          const bas = dk(String(r.saat ?? ''));
          return { bas, bit: bas + (Number(r.sureDk) || 0) };
        })
        .filter(x => Number.isFinite(x.bas)));
    } catch (h) { setHata(hataMetni(h)) }
  }, [hekimId, tarih, hariçId]);

  useEffect(() => { void yukle() }, [yukle]);

  const slotlar = useMemo(() => {
    const bas = dk(ayar.baslangicSaat);
    const bit = dk(ayar.bitisSaat);
    if (!Number.isFinite(bas) || !Number.isFinite(bit)) return [];
    const liste: number[] = [];
    for (let t = bas; t < bit; t += ayar.slotDk) liste.push(t);
    return liste;
  }, [ayar]);

  const secili = dk(seciliSaat);
  const ogleBas = dk(ayar.ogleBaslangic);
  const ogleBit = dk(ayar.ogleBitis);

  /** Slot, süresi boyunca dolu bir randevuyla ya da öğle arasıyla çakışıyor mu. */
  const kapali = (t: number) => {
    const son = t + (Number(sureDk) || ayar.slotDk);
    if (Number.isFinite(ogleBas) && Number.isFinite(ogleBit)
        && t < ogleBit && son > ogleBas) return true;
    return dolu.some(d => t < d.bit && son > d.bas);
  };

  if (!hekimId) {
    return (
      <div className="kagrup" style={{ marginTop: 12 }}>
        <div className="numaralama-bas bitisik"><h6>Uygun Saatler</h6></div>
        <div style={{ padding: '8px 12px', fontSize: 11.5, opacity: .7 }}>
          Hekim seçilince o günün uygun saatleri listelenir.
        </div>
      </div>
    );
  }

  return (
    <div className="kagrup" style={{ marginTop: 12 }}>
      <div className="numaralama-bas bitisik">
        <h6>
          Uygun Saatler — {tarih.split('-').reverse().join('.')}
          {hekimAdi ? ` · ${hekimAdi}` : ''}
        </h6>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="saat-serit">
        {slotlar.map(t => {
          const dolulukVar = kapali(t);
          const bu = t === secili;
          return (
            <button key={t} type="button"
                    className={`saat${dolulukVar ? ' dolu' : ''}${bu ? ' secili' : ''}`}
                    disabled={dolulukVar && !bu}
                    onClick={() => onSec(saatMetni(t))}>
              {saatMetni(t)}
            </button>
          );
        })}
        {slotlar.length === 0 && (
          <span style={{ fontSize: 11.5, opacity: .7 }}>
            Bu hekim için çalışma saati tanımlı değil.
          </span>
        )}
      </div>
      <div style={{ padding: '2px 12px 8px', fontSize: 11, opacity: .7 }}>
        Dolu saatler üzeri çizili; seçili saat maviyle işaretli. Süre {sureDk || ayar.slotDk} dk
        olduğu için taşan slotlar da kapalı görünür.
      </div>
    </div>
  );
}
