import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { Modal } from './Modal';
import { guvenli, mesaj } from './mesaj';

type Tur = { id: number; ad: string; grup: number; grupAdi: string; aktif: boolean };

/**
 * İK › BELGE TÜRLERİ "↕ Sırayı düzenle" (mockup personel_belge_turu.html (1)). Sıra grup içinde
 * anlamlı (liste grup başlıklı); türler grubunun içinde ▲ ▼ ile taşınır, kaydedince 10, 20, 30 ...
 * yazılır. Personel kartı Belgeler sekmesi ve hatırlatma metni aynı sırayı izler.
 */
export function BelgeTuruSiraModali({ onKapat, onKaydedildi }: { onKapat(): void; onKaydedildi(): void }) {
  const [turler, setTurler] = useState<Tur[] | null>(null);
  const [degisti, setDegisti] = useState(false);
  useEffect(() => {
    void guvenli(async () => {
      const y = await api.liste('personel-belge-turu', { sayfa: 1, boyut: 500 });
      setTurler(y.satirlar.map(s => ({ id: Number(s.id), ad: String(s.ad ?? ''), grup: Number(s.grup ?? 5),
        grupAdi: String(s.grupAdi ?? ''), aktif: Number(s.aktif) === 1 })));
    });
  }, []);

  const tasi = (id: number, yon: -1 | 1) => {
    if (!turler) return;
    const i = turler.findIndex(t => t.id === id);
    let j = i + yon;
    while (j >= 0 && j < turler.length && turler[j].grup !== turler[i].grup) j += yon;
    if (j < 0 || j >= turler.length) return;
    const y = [...turler];
    [y[i], y[j]] = [y[j], y[i]];
    setTurler(y);
    setDegisti(true);
  };

  const kaydet = () => void guvenli(async () => {
    if (!turler) return;
    // Grup sırası korunur; her grubun içi ekrandaki sırayla.
    const sirali = turler.map((t, i) => ({ t, i })).sort((a, b) => a.t.grup - b.t.grup || a.i - b.i).map(x => x.t.id);
    const y = await api.belgeTuruSira(sirali);
    mesaj(y.degisen ? `${y.degisen} türün sırası güncellendi.` : 'Sıra değişmedi.');
    onKaydedildi();
  });

  const gruplar = turler ? [...new Set(turler.map(t => t.grup))].sort((a, b) => a - b) : [];
  return (
    <Modal baslik="↕ Belge türlerinin sırası" dar enUst onKapat={onKapat}
           alt={<>
             <button type="button" className="d" onClick={onKapat}>Vazgeç</button>
             <button type="button" className="d bir" disabled={!degisti} onClick={kaydet}>💾 Kaydet</button>
           </>}>
      {!turler ? <div style={{ padding: 12 }}>Yükleniyor…</div> : (
        <div style={{ padding: '6px 4px', maxHeight: '60vh', overflow: 'auto' }}>
          {gruplar.map(g => {
            const ic = turler.filter(t => t.grup === g);
            return (
              <div key={g} style={{ marginBottom: 10 }}>
                <div style={{ fontWeight: 700, color: 'var(--yazi2)', padding: '4px 6px', background: 'var(--kartzem)',
                              border: '1px solid var(--cizgi)', borderRadius: 4 }}>{ic[0]?.grupAdi}</div>
                {ic.map((t, k) => (
                  <div key={t.id} style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '4px 6px',
                                           borderBottom: '1px dashed var(--cizgi)', opacity: t.aktif ? 1 : 0.55 }}>
                    <span style={{ width: 28, color: 'var(--soluk)', textAlign: 'right' }}>{(k + 1) * 10}</span>
                    <span style={{ flex: 1 }}>{t.ad}{!t.aktif && ' (pasif)'}</span>
                    <button type="button" className="d" disabled={k === 0} title="Yukarı"
                            onClick={() => tasi(t.id, -1)}>▲</button>
                    <button type="button" className="d" disabled={k === ic.length - 1} title="Aşağı"
                            onClick={() => tasi(t.id, 1)}>▼</button>
                  </div>
                ))}
              </div>
            );
          })}
        </div>
      )}
    </Modal>
  );
}
