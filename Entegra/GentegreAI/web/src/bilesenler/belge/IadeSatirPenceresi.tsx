import { useCallback, useEffect, useRef, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { ApiHatasi } from '../../api/sozlesme';
import { para } from '../bicim';

/** Iade edilebilir bir gecmis fatura satiri (v_iade_edilebilir_satir). */
export interface IadeSatiri {
  satirId: number;
  belgeId: number;
  belgeNo: string;
  belgeTarihi: string;
  satirTur: number;
  stokId: number | null;
  stokKodu: string | null;
  stokAdi: string | null;
  hizmetId: number | null;
  aciklama: string;
  miktar: number;
  iadeMiktar: number;
  kalanMiktar: number;
  birim: number;
  birimFiyat: number;
  iskonto: number;
  kdv: number;
  izleme: number;
  izlemeKodu: string;
  /** Kullanicinin iade edecegi miktar (varsayilan: kalanin tamami). */
  secilenMiktar?: string;
}

/**
 * IADE KALEM SECIMI - "onceki alinanlar" (kullanici).
 *
 * Iade faturasinda stok aranmaz: musteriye DAHA ONCE satilmis kalemler
 * listelenir, kullanici hangisinden ne kadar geri geldigini isaretler. Fiyat,
 * iskonto ve KDV kaynak satirdan gelir - elle girilen fiyat cari bakiyesini ve
 * KDV'yi tutarsiz birakirdi.
 *
 * Kismi iade dogal: satirdaki miktar kalanina kadar degistirilebilir; kalan
 * sunucuda (v_iade_edilebilir_satir) her zaman yeniden hesaplanir.
 */
export function IadeSatirPenceresi({ tarafId, tarafUnvan, belgeId, turler, onSec, onKapat }: {
  tarafId: number;
  tarafUnvan: string;
  /** Belge uzerinden iade: yalniz o belgenin satirlari listelenir. */
  belgeId?: number;
  /**
   * Hangi belge turlerinden iade edilebilir: iade FATURASI fatura satirlarini,
   * iade IRSALIYESI irsaliye satirlarini gorur (133) - ayni mal iki kaynaktan
   * iade edilip cift sayilmasin.
   */
  turler?: number[];
  onSec(satirlar: IadeSatiri[]): void;
  onKapat(): void;
}) {
  const [satirlar, setSatirlar] = useState<IadeSatiri[]>([]);
  const [secili, setSecili] = useState<Record<number, string>>({});
  const [arama, setArama] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const zamanlayici = useRef<number | undefined>(undefined);

  // Tur listesi her render'da yeni DIZI olarak geliyor; bagimlilikta referans
  //   yerine metin kullanilir - yoksa yukle surekli yeniden kurulup donerdi.
  const turAnahtar = (turler ?? []).join(',');

  const yukle = useCallback(async (metin: string) => {
    setYukleniyor(true);
    setHata(null);
    try {
      const y = await api.iadeSatirlari(tarafId, belgeId, metin.trim() || undefined,
                                        turAnahtar ? turAnahtar.split(',').map(Number) : undefined);
      setSatirlar(y as unknown as IadeSatiri[]);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
      setSatirlar([]);
    } finally { setYukleniyor(false) }
  }, [tarafId, belgeId, turAnahtar]);

  useEffect(() => { void yukle('') }, [yukle]);

  const yaz = (metin: string) => {
    setArama(metin);
    window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => void yukle(metin), 250);
  };

  const isaretle = (r: IadeSatiri) => setSecili(s => {
    const yeni = { ...s };
    if (yeni[r.satirId] !== undefined) delete yeni[r.satirId];
    else yeni[r.satirId] = String(r.kalanMiktar);
    return yeni;
  });

  const miktarYaz = (satirId: number, deger: string) =>
    setSecili(s => ({ ...s, [satirId]: deger }));

  const sayi = (m: string) => Number(String(m).replace(',', '.')) || 0;

  const secilenler = satirlar
    .filter(r => secili[r.satirId] !== undefined)
    .map(r => ({ ...r, secilenMiktar: secili[r.satirId] }));

  const gecersiz = secilenler.find(r =>
    sayi(r.secilenMiktar ?? '') <= 0 || sayi(r.secilenMiktar ?? '') > r.kalanMiktar);

  const toplam = secilenler.reduce(
    (t, r) => t + sayi(r.secilenMiktar ?? '') * r.birimFiyat * (100 - r.iskonto) / 100, 0);

  return (
    <Modal
      baslik={`İade Edilecek Kalemler — ${tarafUnvan}`}
      onKapat={onKapat}
      alt={
        <>
          <button className="d ana" disabled={secilenler.length === 0 || !!gecersiz}
                  title={gecersiz ? 'Miktar 0 ile kalan arasında olmalı.' : ''}
                  onClick={() => onSec(secilenler)}>
            ✔ Seçilenleri Ekle{secilenler.length > 0 ? ` (${secilenler.length})` : ''}
          </button>
          <span className="ayrac" />
          <span className="kapt">Toplam: {para.format(toplam)}</span>
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>
        </>
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="kagrup">
          <div className="cipler" style={{ margin: 10 }}>
            <div className="ara" style={{
              maxWidth: 320, margin: 0, height: 23, borderRadius: 12,
              background: 'var(--yuz)', color: 'var(--yazi)', border: '1px solid var(--cizgi)',
            }}>
              <span>🔍</span>
              <input
                autoFocus
                style={{ border: 0, background: 'transparent', outline: 'none', width: '100%', color: 'inherit' }}
                placeholder="Stok / belge no ara…"
                value={arama}
                onChange={e => yaz(e.target.value)}
              />
            </div>
            <span className="alan-notu">
              Fiyat, iskonto ve KDV kaynak faturadan gelir; miktar kalana kadar değiştirilebilir.
            </span>
          </div>

          <table className="detay-tablo secilebilir">
            <thead>
              <tr>
                <th style={{ width: 28 }} />
                <th style={{ width: 150 }}>Belge</th>
                <th style={{ width: 90 }}>Tarih</th>
                <th style={{ width: 110 }}>Kod</th>
                <th>Stok / Hizmet</th>
                <th className="hiza-sag" style={{ width: 70 }}>Miktar</th>
                <th className="hiza-sag" style={{ width: 70 }}>İade</th>
                <th className="hiza-sag" style={{ width: 70 }}>Kalan</th>
                <th className="hiza-sag" style={{ width: 90 }}>Br. Fiyat</th>
                <th className="hiza-sag" style={{ width: 90 }}>İade Miktarı</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map(r => {
                const isaretli = secili[r.satirId] !== undefined;
                return (
                  <tr key={r.satirId} className={isaretli ? 'secili' : ''}
                      onClick={() => isaretle(r)}>
                    <td className="hiza-orta" onClick={e => e.stopPropagation()}>
                      <input type="checkbox" checked={isaretli} onChange={() => isaretle(r)} />
                    </td>
                    <td><code>{r.belgeNo || '—'}</code></td>
                    <td>{String(r.belgeTarihi ?? '').slice(0, 10).split('-').reverse().join('.')}</td>
                    <td><code>{r.stokKodu ?? ''}</code></td>
                    <td>{r.stokAdi || r.aciklama}</td>
                    <td className="hiza-sag">{Number(r.miktar).toLocaleString('tr-TR')}</td>
                    <td className="hiza-sag sonuk">
                      {Number(r.iadeMiktar) > 0 ? Number(r.iadeMiktar).toLocaleString('tr-TR') : '—'}
                    </td>
                    <td className="hiza-sag"><b>{Number(r.kalanMiktar).toLocaleString('tr-TR')}</b></td>
                    <td className="hiza-sag">{para.format(Number(r.birimFiyat))}</td>
                    <td className="hiza-sag" onClick={e => e.stopPropagation()}>
                      {isaretli && (
                        <input
                          className="hiza-sag"
                          style={{ width: 76 }}
                          value={secili[r.satirId]}
                          onChange={e => miktarYaz(r.satirId, e.target.value)}
                        />
                      )}
                    </td>
                  </tr>
                );
              })}
              {!yukleniyor && satirlar.length === 0 && (
                <tr><td colSpan={10} className="bos">
                  Bu cariye kesilmiş, iade edilebilir kalem yok.
                </td></tr>
              )}
            </tbody>
          </table>
          {yukleniyor && <div className="yukleniyor">Yükleniyor…</div>}
        </div>
      </>
    </Modal>
  );
}
