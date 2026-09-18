import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat } from './bicim';

/**
 * GELEN RAPOR PANELİ (817) — liste satırının altında ham mesaj ve özet.
 *
 * "Eşleşmedi" yazan satırın cevabı mesajın kendisindedir: hangi accession
 * numarası geldi, hangi kurum gönderdi, hasta kimliği tutuyor mu. Çözümlenemeyen
 * mesajda <b>tek kaynak ham metindir</b> - bu yüzden her mesaj saklanıyor.
 *
 * <b>Panel salt okunurdur.</b> Mesaj elle düzeltilmez: yanlış eşleşen rapor
 * araç çubuğundaki "İsteğe Bağla" ile doğru işe bağlanır, gerisi karşı tarafla
 * konuşulur.
 */

type Kayit = Record<string, unknown>;

const DURUM: Record<number, string> = {
  0: 'Çözümlenemedi', 1: 'Eşleşmedi', 2: 'İşlendi', 3: 'Mükerrer', 4: 'Hata',
};

const durumSinifi = (d: number) =>
  d === 2 ? 'rozet olumlu' : d === 3 ? 'rozet gri' : 'rozet hata';

export function TeleradGelenPaneli({ gelenId }: { gelenId: number }) {
  const [k, setK] = useState<Kayit | null>(null);
  const [hata, setHata] = useState('');

  useEffect(() => {
    let iptal = false;
    setHata(''); setK(null);
    api.teleradGelen<Kayit>(gelenId)
      .then(y => { if (!iptal) setK(y) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [gelenId]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!k) return <div className="not kucuk">Yükleniyor…</div>;

  const durum = Number(k.durum ?? 0);
  return (
    <div className="telerad-iz">
      <div className="telerad-gelen-ozet">
        <span className={durumSinifi(durum)}>{DURUM[durum] ?? ''}</span>
        <b>{String(k.accessionNo ?? '—')}</b>
        <span className="sonuk">Geliş: {tarihSaat(k.geldiZamani)}</span>
        <span className="sonuk">Kaynak IP: {String(k.kaynakIp ?? '—')}</span>
        <span className="sonuk">MSH-10: {String(k.kontrolNo ?? '—')}</span>
        <span className="sonuk">
          Raporlayan: {String(k.radyologAd ?? '—')}
          {k.radyologTckn ? ` (${String(k.radyologTckn)})` : ''}
        </span>
      </div>
      {String(k.hata ?? '') && <div className="uyari-kutusu kucuk">{String(k.hata)}</div>}

      <div className="telerad-iz-govde">
        <div>
          <h5>Gelen ORU</h5>
          {/* Segment sonu \r: ekranda alt alta görünsün diye satıra bölünür -
              saklanan metnin kendisi değişmez. */}
          <pre>{String(k.ham ?? '').split('\r').join('\n')}</pre>
        </div>
      </div>
    </div>
  );
}
