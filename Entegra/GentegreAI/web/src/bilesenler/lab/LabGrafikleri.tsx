import { useCallback, useEffect, useRef, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import type { LabGrafigi } from '../../api/uclar/lab';
import { hataMetni } from '../../api/sozlesme';
import { guvenli, mesaj, onay } from '../mesaj';
import { tarihSaat } from '../bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c as cev } from '../../dil/ceviri';

/**
 * GRAFİK TİPLİ SONUÇ (892 — KTS denetim maddesi L10).
 *
 * Elektroforez eğrisi, kromatogram ya da jel görüntüsü; cihazdan gömülü
 * (HL7 OBX-2 = ED) gelebilir, sayı dizisi (NA) olabilir ya da bağlantısız
 * cihazın kâğıt çıktısı taranıp elle eklenebilir.
 *
 * <b>Seri görüntüye çevrilmez, ÇİZİLİR.</b> Sunucu noktaları saklıyor;
 * ekran onları SVG olarak çizer - eğriyi kaydederken resme dönüştürmek,
 * ölçeği ve veriyi sonsuza kadar dondurmak olurdu.
 *
 * <b>"Raporda" bayrağı burada değiştirilir:</b> ham kalibrasyon eğrisi
 * laboratuvarın iç kaydıdır, protein elektroforezi ise raporun parçasıdır -
 * kararı uzman verir.
 */
const TUR: Record<number, string> = {
  1: 'Elektroforez', 2: 'Kromatogram', 3: 'Jel / blot',
  4: 'Kalibrasyon eğrisi', 5: 'Reaksiyon eğrisi', 9: 'Diğer',
};

/** Sunucudan gelen `{"y":[…]}` (ve varsa `x`) dizisi. */
function seriCoz(metin: string | null): { x: number[]; y: number[] } | null {
  if (!metin) return null;
  try {
    const o = JSON.parse(metin) as { x?: number[]; y?: number[] };
    const y = Array.isArray(o.y) ? o.y.map(Number).filter(v => !Number.isNaN(v)) : [];
    if (y.length === 0) return null;
    const x = Array.isArray(o.x) && o.x.length === y.length
      ? o.x.map(Number) : y.map((_, i) => i + 1);
    return { x, y };
  } catch { return null }
}

/** Seriyi SVG yol verisine çevirir (0-100 kutusuna ölçekli). */
function yol(x: number[], y: number[]): string {
  const enAzY = Math.min(...y), enCokY = Math.max(...y);
  const enAzX = Math.min(...x), enCokX = Math.max(...x);
  const araY = enCokY - enAzY || 1, araX = enCokX - enAzX || 1;
  return y.map((v, i) => {
    const px = ((x[i] - enAzX) / araX) * 100;
    // SVG'de y aşağı doğru büyür: eğri ters çizilmesin diye 100'den çıkarılır.
    const py = 100 - ((v - enAzY) / araY) * 100;
    return `${i === 0 ? 'M' : 'L'}${px.toFixed(2)},${py.toFixed(2)}`;
  }).join(' ');
}

export function LabGrafikleri({ satirId, baslik, onKapat }: {
  satirId: number; baslik?: string; onKapat(): void;
}) {
  const { aksiyonVar } = useOturum();
  const [satirlar, setSatirlar] = useState<LabGrafigi[]>([]);
  const [urller, setUrller] = useState<Record<number, string>>({});
  const [hata, setHata] = useState<string | null>(null);
  const dosyaSec = useRef<HTMLInputElement>(null);

  const yukle = useCallback(async () => {
    try {
      const y = await api.labGrafikler(satirId);
      setSatirlar(y.satirlar ?? []);
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [satirId]);
  useEffect(() => { void yukle() }, [yukle]);

  // GÖRÜNTÜLER BLOB OLARAK ÇEKİLİR: <img src> Authorization başlığı
  //   taşıyamaz, token URL'de taşınmaz.
  useEffect(() => {
    let iptal = false;
    const adresler: string[] = [];
    void (async () => {
      const yeni: Record<number, string> = {};
      for (const g of satirlar) {
        if (!g.dokumanId || !(g.contentType ?? '').startsWith('image/')) continue;
        try {
          const u = await api.labGrafikUrl(g.dokumanId);
          adresler.push(u); yeni[g.id] = u;
        } catch { /* görüntü açılamazsa satır yine listelenir */ }
      }
      if (!iptal) setUrller(yeni);
    })();
    return () => {
      iptal = true;
      adresler.forEach(u => URL.revokeObjectURL(u));
    };
  }, [satirlar]);

  const yukleDosya = async (dosya: File) => {
    await guvenli(async () => {
      const y = await api.labGrafikYukle(satirId, dosya, 9, dosya.name);
      mesaj(y.mesaj);
      await yukle();
    });
  };

  const raporda = async (g: LabGrafigi) => {
    await guvenli(async () => {
      await api.labGrafikDuzenle(g.id, { raporda: g.raporda !== 1 });
      await yukle();
    });
  };

  const turDegis = async (g: LabGrafigi, tur: number) => {
    await guvenli(async () => {
      await api.labGrafikDuzenle(g.id, { tur });
      await yukle();
    });
  };

  const kaldir = async (g: LabGrafigi) => {
    if (!await onay('Grafik sonuç kaydı kaldırılacak. Sürdürülsün mü?')) return;
    await guvenli(async () => {
      const y = await api.labGrafikSil(g.id);
      mesaj(y.mesaj);
      await yukle();
    });
  };

  return (
    <Modal baslik={`〰️ ${cev('Grafik sonuçlar')}${baslik ? ' · ' + baslik : ''}`}
           onKapat={onKapat}
           alt={<button type="button" className="d" onClick={onKapat}>{cev('Kapat')}</button>}>
      {hata && <div className="hata-kutusu">{hata}</div>}

      {aksiyonVar('lab.grafik.yukle') && (
        <div className="ds-sr">
          <input ref={dosyaSec} type="file" style={{ display: 'none' }}
                 accept="image/png,image/jpeg,application/pdf"
                 onChange={e => {
                   const d = e.target.files?.[0];
                   if (d) void yukleDosya(d);
                   e.target.value = '';
                 }} />
          <button type="button" className="d" onClick={() => dosyaSec.current?.click()}>
            📤 {cev('Grafik yükle (tarama / cihaz çıktısı)')}
          </button>
          {/* BAĞLANTISIZ CİHAZ GERÇEĞİ: birçok elektroforez cihazı çıktıyı
              yalnız kâğıda basar; taranıp eklenmezse eğri hasta dosyasında
              hiç olmaz. */}
        </div>
      )}

      {satirlar.length === 0 && (
        <div className="ds-ic sonuk">
          {cev('Bu tetkikte grafik sonuç yok. Cihaz gönderirse kendiliğinden eklenir.')}
        </div>
      )}

      {satirlar.map(g => {
        const seri = seriCoz(g.seri);
        return (
          <div key={g.id} className="kagrup" style={{ marginTop: 8 }}>
            <h6>
              {g.baslik || TUR[g.tur] || cev('Grafik')}
              <span className="sp">
                {TUR[g.tur] ?? ''}
                {g.cihaz ? ` · ${g.cihaz}` : ''}
                {g.kaynak === 2 ? ` · ${cev('elle yüklendi')}` : ''}
                {` · ${tarihSaat(g.eklemeTarihi)}`}
              </span>
            </h6>

            {seri && (
              <svg viewBox="0 0 100 100" preserveAspectRatio="none"
                   style={{ width: '100%', height: 160, background: 'var(--yuz2)' }}>
                <path d={yol(seri.x, seri.y)} fill="none" stroke="var(--vurgu)"
                      strokeWidth="0.8" vectorEffect="non-scaling-stroke" />
              </svg>
            )}
            {seri && (
              <div className="not">
                {seri.y.length} {cev('nokta')}
                {g.birimY ? ` · ${g.birimY}` : ''}
              </div>
            )}

            {urller[g.id] && (
              <img src={urller[g.id]} alt={g.baslik}
                   style={{ maxWidth: '100%', display: 'block' }} />
            )}
            {g.dokumanId && !urller[g.id] && (
              <div className="ds-ic">
                <span className="sonuk">{g.contentType}</span>{' · '}
                <button type="button" className="d kucuk"
                        onClick={() => void guvenli(async () => {
                          const u = await api.labGrafikUrl(g.dokumanId!);
                          window.open(u, '_blank');
                        })}>
                  {cev('Aç')}
                </button>
              </div>
            )}

            <div className="ds-sr" style={{ marginTop: 6 }}>
              <select value={g.tur} onChange={e => void turDegis(g, Number(e.target.value))}>
                {Object.entries(TUR).map(([k, a]) =>
                  <option key={k} value={k}>{a}</option>)}
              </select>
              <label className="ds-onay">
                <input type="checkbox" checked={g.raporda === 1}
                       onChange={() => void raporda(g)} />
                {cev('Raporda göster')}
              </label>
              <button type="button" className="d kucuk" onClick={() => void kaldir(g)}>
                {cev('Kaldır')}
              </button>
            </div>
          </div>
        );
      })}
    </Modal>
  );
}
