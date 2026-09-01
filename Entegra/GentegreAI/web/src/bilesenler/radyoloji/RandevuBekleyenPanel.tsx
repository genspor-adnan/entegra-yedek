import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';

/**
 * RANDEVU BEKLEYEN İSTEMLER PANELİ (316).
 *
 * Takvimin solunda durur: randevusu olmayan radyoloji istemleri. İki yolla
 * randevuya dönüşür -
 *   1) satırı takvimdeki boş saate SÜRÜKLE-BIRAK,
 *   2) satırı seç, takvimde boş saate TIKLA (dokunmatik/erişilebilirlik yolu).
 * İkisi de aynı ucu çağırır; kural (çakışma, kapasite, cihaz kapatma)
 * veritabanı tetiğindedir - panel yalnız hangi istem, hangi saat sorusunu sorar.
 *
 * Panel yalnız CİHAZ sütunlu görünümde iş görür (randevunun kaynağı cihazdır),
 * bu yüzden başlıkta o uyarı vardır.
 */

export interface BekleyenIstem {
  id: number;
  accessionNo: string;
  hasta: string;
  hastaId: number;
  tetkik: string;
  hizmetId: number;
  modalite: number;
  modaliteAdi: string;
  oncelik: number;
  /** Çekim protokolünden gelen süre (314); 0 ise cihaz varsayılanı kullanılır. */
  sureDk: number;
  istemZamani: string;
}

/** "3 gün", "5 sa", "40 dk" - istemin ne kadardır beklediği. */
function bekleme(zaman: string): string {
  const t = new Date(zaman);
  if (Number.isNaN(t.getTime())) return '';
  const dk = Math.max(0, Math.round((Date.now() - t.getTime()) / 60000));
  if (dk < 60) return `${dk} dk`;
  if (dk < 60 * 24) return `${Math.floor(dk / 60)} sa`;
  return `${Math.floor(dk / 1440)} gün`;
}

export function RandevuBekleyenPanel({ secili, onSecim, onRandevuModali, yenile }: {
  secili: BekleyenIstem | null;
  onSecim(istem: BekleyenIstem | null): void;
  /** Satırdaki 📅 - elle tarih/saat/cihaz seçilen modal. */
  onRandevuModali(istem: BekleyenIstem): void;
  /** Dışarıdan tazeleme sayacı: randevu verilince istem listeden düşer. */
  yenile?: number;
}) {
  const [satirlar, setSatirlar] = useState<BekleyenIstem[]>([]);
  const [ara, setAra] = useState('');
  const [modalite, setModalite] = useState<number | ''>('');
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try {
      const y = await api.radyolojiRandevuBekleyen();
      setSatirlar(y.map(r => ({
        id: Number(r.id),
        accessionNo: String(r.accessionNo ?? ''),
        hasta: String(r.hasta ?? ''),
        hastaId: Number(r.hastaId ?? 0),
        tetkik: String(r.tetkik ?? ''),
        hizmetId: Number(r.hizmetId ?? 0),
        modalite: Number(r.modalite ?? 0),
        modaliteAdi: String(r.modaliteAdi ?? ''),
        oncelik: Number(r.oncelik ?? 1),
        sureDk: Number(r.sureDk ?? 0),
        istemZamani: String(r.istemZamani ?? ''),
      })));
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, []);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  // Modalite çipleri VERİDEN türer: kurumda olmayan modalite çipi çıkmasın.
  const modaliteler = useMemo(() => {
    const m = new Map<number, string>();
    satirlar.forEach(r => { if (r.modalite) m.set(r.modalite, r.modaliteAdi || String(r.modalite)) });
    return [...m.entries()].sort((a, b) => a[1].localeCompare(b[1], 'tr'));
  }, [satirlar]);

  const suzulmus = useMemo(() => {
    const a = ara.trim().toLocaleLowerCase('tr');
    return satirlar.filter(r => {
      if (modalite !== '' && r.modalite !== modalite) return false;
      if (!a) return true;
      return `${r.hasta} ${r.tetkik} ${r.accessionNo}`.toLocaleLowerCase('tr').includes(a);
    });
  }, [satirlar, ara, modalite]);

  return (
    <div className="bekleyen-panel">
      <div className="bekleyen-bas">
        <b>Randevu Bekleyen</b>
        <span className="bekleyen-sayi">{suzulmus.length}</span>
        <button type="button" className="d" title="Listeyi tazele"
                onClick={() => void yukle()}>⟳</button>
      </div>

      <input className="bekleyen-ara" value={ara} placeholder="Hasta / tetkik ara…"
             onChange={e => setAra(e.target.value)} />

      {modaliteler.length > 1 && (
        <div className="bekleyen-cipler">
          <button type="button" className={`cip${modalite === '' ? ' on' : ''}`}
                  onClick={() => setModalite('')}>Tümü</button>
          {modaliteler.map(([kod, ad]) => (
            <button key={kod} type="button" className={`cip${modalite === kod ? ' on' : ''}`}
                    onClick={() => setModalite(modalite === kod ? '' : kod)}>{ad}</button>
          ))}
        </div>
      )}

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="bekleyen-liste">
        {yukleniyor && satirlar.length === 0 && <div className="bekleyen-bos">Yükleniyor…</div>}
        {!yukleniyor && suzulmus.length === 0 && (
          <div className="bekleyen-bos">Randevu bekleyen istem yok.</div>
        )}
        {suzulmus.map(r => (
          <div key={r.id}
               className={`bekleyen-kart${secili?.id === r.id ? ' secili' : ''}`
                          + (r.oncelik >= 2 ? ' acil' : '')}
               draggable
               /* Sürükle-bırak yükü İSTEMİN TAMAMI: bırakma anında panelin
                  seçili satırına bakmak gerekmesin - seçim state'i sürükleme
                  sırasında değişirse (ya da hiç oturmazsa) randevu düşerdi. */
               onDragStart={e => {
                 onSecim(r);
                 e.dataTransfer.setData('application/x-radyoloji-istem', JSON.stringify(r));
                 e.dataTransfer.effectAllowed = 'move';
               }}
               onClick={() => onSecim(secili?.id === r.id ? null : r)}
               title={`${r.accessionNo} · ${r.tetkik}`}>
            <div className="bekleyen-satir1">
              <b>{r.hasta || '(hasta yok)'}</b>
              {r.oncelik >= 2 && <span className="rozet acil">ACİL</span>}
              <button type="button" className="bekleyen-takvim" title="Tarih/saat seçerek randevu ver"
                      onClick={e => { e.stopPropagation(); onRandevuModali(r) }}>📅</button>
            </div>
            <div className="bekleyen-satir2">{r.tetkik}</div>
            <div className="bekleyen-satir3">
              <span>{r.modaliteAdi}</span>
              {r.sureDk > 0 && <span>· {r.sureDk} dk</span>}
              <span className="bekleyen-sure">{bekleme(r.istemZamani)}</span>
            </div>
          </div>
        ))}
      </div>

      {secili && (
        <div className="bekleyen-ipucu">
          <b>{secili.hasta}</b> seçili — takvimde <b>cihaz sütununda</b> boş bir saate
          tıklayın ya da kartı sürükleyip bırakın.
        </div>
      )}
    </div>
  );
}
