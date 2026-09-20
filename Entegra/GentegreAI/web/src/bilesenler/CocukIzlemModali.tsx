import { useCallback, useEffect, useState } from 'react';
import { Modal } from './Modal';
import { api } from '../api/istemci';
import type { CocukIzlemi } from '../api/uclar/cocukIzlem';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj } from './mesaj';
import { gunNokta } from './bicim';
import { c as cev } from '../dil/ceviri';

/**
 * BEBEK / ÇOCUK İZLEMİ (899 — KTS maddesi H10, USS 209).
 *
 * <b>İzlem sırasını sunucu söyler</b> (son izlem + 1): elle sayılan sıra,
 * USS'de yanlış izlem demektir.
 *
 * <b>Persentil ölçümle birlikte görünür.</b> Hekim değeri girip kaydettiği
 * anda eğrideki yerini görmeli; ayrı bir ekrana gitmek, bakılmamasına yol
 * açar. Eğri verisi yüklü değilse persentil yerine bunu SÖYLERİZ - boş bir
 * hücre "ölçüm kötü" diye okunabilir.
 */
const SAYI = (v: string): number | null => {
  const t = v.trim().replace(',', '.');
  if (t === '') return null;
  const s = Number(t);
  return Number.isFinite(s) ? s : null;
};

function persentilMetni(p: number | null | undefined): string {
  if (p === null || p === undefined) return '—';
  return `%${p}`;
}

export function CocukIzlemModali({ hastaId, cocukAdi, belgeId, onKapat }: {
  hastaId: number; cocukAdi?: string; belgeId?: number | null; onKapat(): void;
}) {
  const [izlemler, setIzlemler] = useState<CocukIzlemi[]>([]);
  const [sonraki, setSonraki] = useState(1);
  const [egriVar, setEgriVar] = useState(true);
  const [boy, setBoy] = useState('');
  const [kilo, setKilo] = useState('');
  const [bas, setBas] = useState('');
  const [oneri, setOneri] = useState('');
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      const y = await api.cocukIzlemGecmisi(hastaId);
      setIzlemler(y.izlemler ?? []);
      setSonraki(y.sonraki ?? 1);
      setEgriVar(y.egriVar);
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [hastaId]);
  useEffect(() => { void yukle() }, [yukle]);

  const kaydet = async () => {
    await guvenli(async () => {
      const y = await api.cocukIzlemEkle({
        tarafId: hastaId, kacinciIzlem: sonraki, belgeId: belgeId ?? null,
        boyCm: SAYI(boy), kiloKg: SAYI(kilo), basCevresiCm: SAYI(bas),
        oneri: oneri.trim(),
      });
      mesaj(y.kiloPersentil !== null
        ? `${y.mesaj} Kilo persentili %${y.kiloPersentil}.`
        : y.mesaj);
      setBoy(''); setKilo(''); setBas(''); setOneri('');
      await yukle();
    });
  };

  return (
    <Modal baslik={`👶 ${cev('Çocuk İzlemi')}${cocukAdi ? ' · ' + cocukAdi : ''}`}
           onKapat={onKapat}
           alt={<>
             <button type="button" className="b" onClick={() => void kaydet()}>
               {cev('Kaydet')} ({sonraki}. {cev('izlem')})
             </button>
             <button type="button" className="d" onClick={onKapat}>{cev('Kapat')}</button>
           </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}

      {!egriVar && (
        // EĞRİ VERİSİ YOK: persentil sütunları boş kalacak; bunu söylemek,
        //   boş hücreyi "ölçüm kötü" diye okutmaktan iyidir.
        <div className="uyari-kutusu">
          {cev('Büyüme eğrisi (LMS) verisi yüklü değil - persentil hesaplanmayacak. '
             + 'İzlem yine kaydedilir ve e-Nabız\'a gönderilir.')}
        </div>
      )}

      <div className="ds-sr">
        <div className="alan">
          <label>{cev('Boy (cm)')}</label>
          <input value={boy} onChange={e => setBoy(e.target.value)} inputMode="decimal" />
        </div>
        <div className="alan">
          <label>{cev('Kilo (kg)')}</label>
          <input value={kilo} onChange={e => setKilo(e.target.value)} inputMode="decimal" />
        </div>
        <div className="alan">
          <label>{cev('Baş çevresi (cm)')}</label>
          <input value={bas} onChange={e => setBas(e.target.value)} inputMode="decimal" />
        </div>
      </div>
      <div className="alan">
        <label>{cev('Öneri')}</label>
        <input value={oneri} onChange={e => setOneri(e.target.value)} />
      </div>

      <div className="ds-gb" style={{ marginTop: 10 }}>
        {cev('İzlem geçmişi')}
        <span className="ds-sp sonuk">{izlemler.length} {cev('kayıt')}</span>
      </div>
      <div className="ds-dg"><table>
        <thead><tr>
          <th className="orta">{cev('İzlem')}</th><th className="orta">{cev('Tarih')}</th>
          <th className="sag">{cev('Ay')}</th>
          <th className="sag">{cev('Boy')}</th><th className="sag">{cev('Kilo')}</th>
          <th className="sag">{cev('Kilo %')}</th><th className="sag">{cev('Boy %')}</th>
          <th className="orta">{cev('Durum')}</th>
        </tr></thead>
        <tbody>
          {izlemler.map(i => (
            <tr key={i.id} className={i.durum === 0 ? 'sonuk' : undefined}>
              <td className="orta">{i.kacinciIzlem}</td>
              <td className="orta">{gunNokta(i.izlemTarihi)}</td>
              <td className="sag">{i.yasAy ?? '—'}</td>
              <td className="sag">{i.boyCm ?? '—'}</td>
              <td className="sag">{i.kiloKg ?? '—'}</td>
              <td className="sag">{persentilMetni(i.kiloPersentil)}</td>
              <td className="sag">{persentilMetni(i.boyPersentil)}</td>
              <td className="orta">
                {i.durum === 1
                  ? <span className="rozet olumlu">{cev('Geçerli')}</span>
                  : <span className="rozet gri" title={i.iptalNeden}>{cev('İptal')}</span>}
              </td>
            </tr>
          ))}
          {izlemler.length === 0 && (
            <tr><td colSpan={8} className="not">{cev('Kayıtlı izlem yok.')}</td></tr>
          )}
        </tbody>
      </table></div>
    </Modal>
  );
}
