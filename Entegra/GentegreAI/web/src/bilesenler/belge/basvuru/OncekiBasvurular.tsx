import { useEffect, useState } from 'react';
import { api } from '../../../api/istemci';
import { hataMetni } from '../../../api/sozlesme';
import { para, tarihSaat } from '../../bicim';

// ================================================== ONCEKI BASVURULAR ====
export function OncekiBasvurular({ tarafId, haricBelgeId, baslik, onAc, onYeni }: {
  tarafId?: number | null;
  /** Acik olan basvuru listede tekrar gosterilmez. */
  haricBelgeId?: number;
  /** Kutu basligi - hasta kartinda "Başvuru Geçmişi". */
  baslik?: string;
  /** Satira CIFT TIK: basvuruyu acar (mockup hasta_kimlik_karti.html). */
  onAc?(belgeId: number): void;
  /** "＋ Yeni Başvuru" - verilirse dugme cizilir. */
  onYeni?(): void;
}) {
  const [satirlar, setSatirlar] = useState<Record<string, unknown>[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    if (!tarafId) { setSatirlar([]); return }
    let iptal = false;
    setYukleniyor(true);
    void (async () => {
      try {
        const y = await api.liste('belge', {
          sayfa: 1, boyut: 50,
          sirala: [{ alan: 'belgeTarihi', yon: 'desc' }],
          filtre: { op: 'and', kosullar: [
            { alan: 'tur', op: 'esit', deger: 19 },
            { alan: 'tarafId', op: 'esit', deger: tarafId },
          ] },
        });
        if (!iptal) setSatirlar(y.satirlar.filter(r => Number(r.id) !== haricBelgeId));
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
      finally { if (!iptal) setYukleniyor(false) }
    })();
    return () => { iptal = true };
  }, [tarafId, haricBelgeId]);

  if (!tarafId) return <div className="not">Önce hasta seçin.</div>;

  return (
    <div className="kagrup">
      <h6>
        {baslik ?? 'Önceki Başvurular'}
        {satirlar.length > 0 && <span className="b">{satirlar.length}</span>}
        {onYeni && (
          <button type="button" className="d bir" style={{ marginLeft: 'auto' }}
                  onClick={onYeni}>＋ Yeni Başvuru</button>
        )}
      </h6>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <table className="detay-tablo">
        <thead>
          <tr>
            <th style={{ width: 130 }}>Protokol</th>
            <th style={{ width: 140 }}>Tarih</th>
            <th>Bölüm</th>
            <th>Hekim / Personel</th>
            <th>Ödeyen Kurum</th>
            <th className="hiza-sag" style={{ width: 120 }}>Tutar</th>
            <th style={{ width: 110 }}>Kapanma</th>
          </tr>
        </thead>
        <tbody>
          {satirlar.map(r => (
            /* CIFT TIK basvuruyu acar (mockup): tek tik secim degil - liste
               salt okunur, secilecek bir sey yok. */
            <tr key={String(r.id)}
                className={onAc ? 'tiklanir' : undefined}
                onDoubleClick={onAc ? () => onAc(Number(r.id)) : undefined}
                title={onAc ? 'Başvuruyu açmak için çift tıklayın' : undefined}>
              <td><code>{String(r.belgeNo ?? '')}</code></td>
              <td>{tarihSaat(String(r.belgeTarihi ?? ''))}</td>
              <td>{String(r.poliklinik ?? '') || <span className="sonuk">—</span>}</td>
              <td>{String(r.doktor ?? '') || <span className="sonuk">—</span>}</td>
              <td>{String(r.odeyenKurumAdi ?? '') || <span className="sonuk">kendi öder</span>}</td>
              <td className="hiza-sag">{para.format(Number(r.genelToplam ?? 0))}</td>
              <td>{String(r.kapanmaAdi ?? '')}</td>
            </tr>
          ))}
          {!yukleniyor && satirlar.length === 0 && (
            <tr><td colSpan={7} className="bos">Bu hastanın başka başvurusu yok.</td></tr>
          )}
        </tbody>
      </table>
      {yukleniyor && <div className="yukleniyor">Yükleniyor…</div>}
    </div>
  );
}

