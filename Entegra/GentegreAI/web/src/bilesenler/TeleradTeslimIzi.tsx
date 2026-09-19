import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat } from './bicim';
import { c } from '../dil/ceviri';

/**
 * TESLİM DENEME GEÇMİŞİ (814) — kuyruk satırının altında açılan panel.
 *
 * "Rapor gitti mi, gitmediyse neden" sorusunun cevabı burada: hangi denemede
 * ne oldu, karşı taraf ne dedi ve <b>ne gönderdik</b>. Ham ORU ile ham ACK
 * saklanıyor çünkü bu soru aylar sonra soruluyor - e-Belge tarafındaki dersin
 * aynısı.
 *
 * <b>Panel salt okunurdur.</b> Mesaj elle düzeltilmez: eksik KAYNAKTA
 * düzeltilir (rapor, kurum kartı, hasta kaydı) ve araç çubuğundan yeniden
 * denenir. Gönderilen metni elle değiştirmek, karşı tarafa giden veri ile
 * bizdeki kaydı birbirinden ayırırdı.
 */

type Satir = Record<string, unknown>;

const SONUC: Record<number, string> = {
  1: 'Başarılı', 2: 'Uygulama hatası (AE)', 3: 'Geçici ret (AR)', 4: 'Ulaşmadı',
};

const sonucSinifi = (s: number) =>
  s === 1 ? 'rozet olumlu' : s === 2 ? 'rozet hata'
  : s === 3 ? 'rozet uyari' : 'rozet gri';

export function TeleradTeslimIzi({ teslimId }: { teslimId: number }) {
  const [satirlar, setSatirlar] = useState<Satir[]>([]);
  const [acik, setAcik] = useState<number | null>(null);
  const [hata, setHata] = useState('');

  useEffect(() => {
    let iptal = false;
    setHata(''); setAcik(null);
    api.teleradTeslimIz<{ satirlar: Satir[] }>(teslimId)
      .then(y => { if (!iptal) setSatirlar(y.satirlar) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [teslimId]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (satirlar.length === 0)
    return <div className="not kucuk">{c('Bu teslim için henüz deneme yapılmadı.')}</div>;

  return (
    <div className="telerad-iz">
      <table className="detay-tablo">
        <thead>
          <tr>
            <th>#</th><th>Zaman</th><th>Sonuç</th><th>ACK</th>
            <th>Süre</th><th>Açıklama</th><th />
          </tr>
        </thead>
        <tbody>
          {satirlar.map(s => {
            const id = Number(s.id);
            const sonuc = Number(s.sonuc ?? 4);
            return (
              <tr key={id} className={acik === id ? 'secili' : undefined}>
                <td>{String(s.denemeNo ?? '')}</td>
                <td>{tarihSaat(s.zaman)}</td>
                <td><span className={sonucSinifi(sonuc)}>{SONUC[sonuc] ?? ''}</span></td>
                <td>{String(s.ackKodu ?? '')}</td>
                <td className="sag">{String(s.sureMs ?? 0)} ms</td>
                <td>{String(s.hata ?? '')}</td>
                <td>
                  <button className="d mini" onClick={() => setAcik(acik === id ? null : id)}>
                    {acik === id ? 'Gizle' : 'Mesajı Gör'}
                  </button>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>

      {acik !== null && (() => {
        const s = satirlar.find(x => Number(x.id) === acik);
        if (!s) return null;
        return (
          <div className="telerad-iz-govde">
            <h5>{c('Gönderilen ORU')}</h5>
            {/* SEGMENT SONU \r: ekranda alt alta görünsün diye satıra bölünür -
                gönderilen metnin kendisi değişmez. */}
            <pre>{String(s.istekGovde ?? '').split('\r').join('\n')}</pre>
            <h5>{c('Alınan ACK')}</h5>
            <pre>{String(s.yanitGovde ?? '').split('\r').join('\n') || '—'}</pre>
          </div>
        );
      })()}
    </div>
  );
}
