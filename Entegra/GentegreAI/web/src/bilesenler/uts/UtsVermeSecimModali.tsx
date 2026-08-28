import { useCallback, useEffect, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import type { UtsBelgeBildirimYaniti } from '../../api/istemci';
import { type Kosul, type ListeSatiri, hataMetni } from '../../api/sozlesme';

/**
 * ÜTS VERME - FATURA SEÇİM LİSTESİ (230, kullanıcı): verme bildirimi elle
 * form yerine e-Belgesi HAZIRLANMIŞ/GÖNDERİLMİŞ satış faturalarından yapılır.
 * İşaretlenen faturaların seri/lot satırları belge köprüsüyle ÜTS'ye gider;
 * belge üstünde ÜTS rozeti (Bildirilmedi/Kısmi/Bildirildi) güncellenir.
 * Aynı iş fatura listesindeki sağ tuş "ÜTS Bildir" ile de yapılabilir.
 */
export function UtsVermeSecimModali({ onKapat, onTamam, onElleGiris }: {
  onKapat(): void;
  onTamam(mesaj: string): void;
  /** Belgeye bağlı olmayan tekil verme için eski elle form. */
  onElleGiris(): void;
}) {
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [cip, setCip] = useState<'bekleyen' | 'tumu'>('bekleyen');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [gonderiyor, setGonderiyor] = useState(false);
  const [hata, setHata] = useState('');
  const [sonuclar, setSonuclar] = useState<UtsBelgeBildirimYaniti[]>([]);

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try {
      // Satış faturası (15) + e-Belgesi hazırlanmış/gönderilmiş.
      const kosullar: Kosul[] = [
        { alan: 'tur', op: 'esit', deger: 15 },
        { alan: 'efaturaKodu', op: 'esitDegil', deger: 0 },
      ];
      if (cip === 'bekleyen')
        kosullar.push({ alan: 'utsDurum', op: 'esitDegil', deger: 2 });
      const y = await api.liste('belge', {
        sayfa: 1, boyut: 100,
        sirala: [{ alan: 'belgeTarihi', yon: 'desc' }],
        filtre: { op: 'and', kosullar },
      });
      setSatirlar(y.satirlar);
      setSecili(new Set());
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setYukleniyor(false);
    }
  }, [cip]);

  useEffect(() => { void yukle(); }, [yukle]);

  const isaretle = (id: number) => setSecili(t => {
    const y = new Set(t);
    if (y.has(id)) y.delete(id); else y.add(id);
    return y;
  });

  const bildir = async () => {
    if (secili.size === 0) { setHata('Önce fatura işaretleyin.'); return }
    setGonderiyor(true); setHata(''); setSonuclar([]);
    const toplanan: UtsBelgeBildirimYaniti[] = [];
    try {
      for (const id of secili) {
        try {
          toplanan.push(await api.utsBelgedenBildir(id));
        } catch (h) {
          const b = satirlar.find(x => Number(x.id) === id);
          toplanan.push({
            belgeNo: String(b?.belgeNo ?? id), toplam: 0, basarili: 0, hatali: 1,
            sonuclar: [], mesaj: hataMetni(h),
          });
        }
      }
      setSonuclar(toplanan);
      const tamam = toplanan.reduce((a, s) => a + s.basarili, 0);
      const hatali = toplanan.reduce((a, s) => a + s.hatali, 0);
      if (hatali === 0 && tamam > 0) {
        onTamam(`${toplanan.length} faturadan ${tamam} satır ÜTS'ye bildirildi.`);
        return;
      }
      await yukle();   // rozetler tazelensin; sonuçlar modalda kalır
    } finally {
      setGonderiyor(false);
    }
  };

  return (
    <Modal baslik="ÜTS Verme Bildirimi — Fatura Seç" onKapat={onKapat}
      alt={<>
        <button className="d bir" disabled={gonderiyor || secili.size === 0}
                onClick={() => void bildir()}>
          {gonderiyor ? 'Bildiriliyor…' : `➤ Seçilenleri Bildir (${secili.size})`}
        </button>
        <button className="d" disabled={gonderiyor} onClick={onElleGiris}>
          Elle Giriş
        </button>
        <button className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                onClick={onKapat}>Kapat</button>
      </>}>
      <div style={{ padding: 10 }}>
        <div style={{ display: 'flex', gap: 6, marginBottom: 8 }}>
          <button type="button" className={`cip${cip === 'bekleyen' ? ' on' : ''}`}
                  onClick={() => setCip('bekleyen')}>Bildirilmemiş / Kısmi</button>
          <button type="button" className={`cip${cip === 'tumu' ? ' on' : ''}`}
                  onClick={() => setCip('tumu')}>Tümü</button>
          <span style={{ alignSelf: 'center', fontSize: 12 }}>
            e-Belgesi hazırlanmış/gönderilmiş satış faturaları
          </span>
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}
        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <div style={{ maxHeight: 300, overflowY: 'auto' }}>
            <table className="grid">
              <thead>
                <tr>
                  <th style={{ width: 30 }}></th>
                  <th>Belge No</th><th>Tarih</th><th>Cari</th>
                  <th style={{ textAlign: 'right' }}>Toplam</th>
                  <th style={{ textAlign: 'center' }}>ÜTS</th>
                </tr>
              </thead>
              <tbody>
                {satirlar.map(s => {
                  const id = Number(s.id);
                  const uts = Number(s.utsDurum ?? 0);
                  return (
                    <tr key={id} style={{ cursor: 'pointer' }}
                        onClick={() => isaretle(id)}>
                      <td style={{ textAlign: 'center' }}>
                        <input type="checkbox" checked={secili.has(id)} readOnly />
                      </td>
                      <td>{String(s.belgeNo ?? '')}</td>
                      <td>{String(s.belgeTarihi ?? '').slice(0, 10)}</td>
                      <td>{String(s.tarafUnvan ?? '')}</td>
                      <td style={{ textAlign: 'right' }}>{String(s.genelToplam ?? '')}</td>
                      <td style={{ textAlign: 'center' }}>
                        <span className={`rozet ${uts === 2 ? 'ok' : uts === 1 ? 'uyari' : 'gri'}`}>
                          {uts === 2 ? 'Bildirildi' : uts === 1 ? 'Kısmi' : 'Bildirilmedi'}
                        </span>
                      </td>
                    </tr>
                  );
                })}
                {satirlar.length === 0 && (
                  <tr><td colSpan={6} style={{ textAlign: 'center', padding: 12 }}>
                    Uygun fatura yok.
                  </td></tr>
                )}
              </tbody>
            </table>
          </div>
        )}

        {sonuclar.length > 0 && (
          <div style={{ marginTop: 10 }}>
            {sonuclar.map((s, i) => (
              <div key={i} className={s.hatali > 0 ? 'hata-kutusu' : 'bilgi-kutusu'}>
                <b>{s.belgeNo}</b>: {s.mesaj}
                {s.sonuclar.filter(x => !x.basarili).map((x, j) => (
                  <div key={j} style={{ fontSize: 12 }}>
                    • {x.stok} {x.seriNo || x.lotNo}: {x.mesaj}
                  </div>
                ))}
              </div>
            ))}
          </div>
        )}
      </div>
    </Modal>
  );
}
