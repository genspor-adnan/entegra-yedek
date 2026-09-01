import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';

/**
 * SARF / KONTRAST DÜŞÜMÜ (320) — mockup Ekranlar/radyoloji_sarf_kontrast.html.
 *
 * Çekim "Çekildi" işaretlenince açılır: tetkikin çekim protokolündeki malzeme
 * listesi ÖNERİ olarak gelir, teknisyen gerçek kullanımı düzeltir ve onaylar.
 *
 * Neden onay adımı var: kontrast miktarı hastanın kilosuna göre değişir, damar
 * yolu ikinci kanül gerektirebilir, CD her hastaya verilmez. Sessiz otomatik
 * düşüm stok sayımını baştan bozar.
 *
 * Onaylanınca stok ÇIKIŞ FİŞİ (tur 4) üretilir - stok bakiyesi, lot düşümü ve
 * maliyet mevcut belge hattında çözülür.
 */

interface SarfSatiri {
  stokId: number; kod: string; ad: string; birim: string; izleme: number;
  protokolMiktar: number; dusumTipi: number; kural: string;
  kalan: number; minStok: number;
}
interface Lot {
  stokId: number;
  /** Cikista lot METNI degil kimligi gecerli: ayni lot no farkli girislerde tekrar eder. */
  seriLotId: number;
  lotNo: string; seriNo: string;
  sonKullanmaTarihi?: string | null; kalan: number;
}

const say = (v: number) =>
  new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 2 }).format(v);

export function SarfOnayModali({ istemId, accessionNo, tetkikAdi, onKapat, onTamam }: {
  istemId: number;
  accessionNo?: string;
  tetkikAdi?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [satirlar, setSatirlar] = useState<SarfSatiri[]>([]);
  const [lotlar, setLotlar] = useState<Lot[]>([]);
  const [depo, setDepo] = useState<{ id: number | null; ad: string }>({ id: null, ad: '' });
  const [miktar, setMiktar] = useState<Record<number, number>>({});
  const [secim, setSecim] = useState<Record<number, boolean>>({});
  /** Stok -> secilen seri_lot_id. */
  const [lotSecim, setLotSecim] = useState<Record<number, number>>({});
  const [dusuldu, setDusuldu] = useState(false);
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);
  const [yukleniyor, setYukleniyor] = useState(true);

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try {
      const y = await api.radyolojiSarf(istemId);
      const liste = (y.satirlar ?? []).map(r => ({
        stokId: Number(r.stokId), kod: String(r.kod ?? ''), ad: String(r.ad ?? ''),
        birim: String(r.birim ?? ''), izleme: Number(r.izleme ?? 0),
        protokolMiktar: Number(r.protokolMiktar ?? 0),
        dusumTipi: Number(r.dusumTipi ?? 1), kural: String(r.kural ?? ''),
        kalan: Number(r.kalan ?? 0), minStok: Number(r.minStok ?? 0),
      })) as SarfSatiri[];
      setSatirlar(liste);
      setLotlar((y.lotlar ?? []).map(l => ({
        stokId: Number(l.stokId), seriLotId: Number(l.seriLotId ?? 0),
        lotNo: String(l.lotNo ?? ''), seriNo: String(l.seriNo ?? ''),
        sonKullanmaTarihi: (l.sonKullanmaTarihi as string) ?? null,
        kalan: Number(l.kalan ?? 0),
      })));
      setDepo({ id: y.depoId ?? null, ad: String(y.depoAdi ?? '') });
      setDusuldu((y.dusulen ?? []).length > 0);

      // ONDEN ISARETLI: "otomatik" tipli satirlar. "Istenirse" tipli malzeme
      //   (CD) yalniz kabulde istenmisse isaretlenir - herkese CD yazmak
      //   stogu bosuna tuketir.
      const cd = Number(y.cdIstendi ?? 0) === 1;
      const s: Record<number, boolean> = {};
      const m: Record<number, number> = {};
      liste.forEach(r => {
        s[r.stokId] = r.dusumTipi === 1 || cd;
        m[r.stokId] = r.protokolMiktar;
      });
      setSecim(s); setMiktar(m);
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [istemId]);

  useEffect(() => { void yukle() }, [yukle]);

  /** Stok başına lot listesi - SKT'si en yakın olan başta (miadı önce dolan). */
  const stokLotlari = useMemo(() => {
    const harita: Record<number, Lot[]> = {};
    lotlar.forEach(l => { (harita[l.stokId] ??= []).push(l) });
    return harita;
  }, [lotlar]);

  const kaydet = async () => {
    setHata('');
    const gonder = satirlar
      .filter(r => secim[r.stokId] && (miktar[r.stokId] ?? 0) > 0)
      .map(r => {
        const secilen = lotSecim[r.stokId];
        const lot = (stokLotlari[r.stokId] ?? []).find(l => l.seriLotId === secilen)
          ?? (stokLotlari[r.stokId] ?? [])[0];
        return {
          stokId: r.stokId, miktar: miktar[r.stokId],
          // Izlemli stokta lot ZORUNLU: belge hatti lotsuz cikisi reddeder,
          //   ve lot METNI degil kimligi (seri_lot_id) gecerli.
          izlemler: r.izleme > 0 && lot
            ? [{ seriLotId: lot.seriLotId, miktar: miktar[r.stokId] }]
            : undefined,
        };
      });
    if (gonder.length === 0) { setHata('Düşülecek malzeme seçilmedi.'); return }

    const izlemsiz = satirlar.find(r =>
      secim[r.stokId] && r.izleme > 0 && (stokLotlari[r.stokId] ?? []).length === 0);
    if (izlemsiz) {
      setHata(`${izlemsiz.ad} lot takipli ama bu depoda bakiyeli lot yok - `
              + 'önce stok girişi yapılmalı.');
      return;
    }

    setKaydediyor(true);
    try {
      const y = await api.radyolojiSarfDus(istemId, { depoId: depo.id ?? undefined,
                                                      satirlar: gonder });
      const kritik = (y.kritik ?? []) as { ad: string; kalan: number; minStok: number }[];
      mesaj(kritik.length > 0
        ? `Sarf düşüldü. KRİTİK SEVİYE: ${kritik.map(k =>
            `${k.ad} (${say(k.kalan)} kaldı)`).join(', ')} - satın alma gerekebilir.`
        : 'Sarf düşüldü, stok çıkış fişi oluşturuldu.');
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`Sarf Onayı${accessionNo ? ` — ${accessionNo}` : ''}`} onKapat={onKapat}
           alt={
             <>
               <button className="d onay" disabled={kaydediyor || satirlar.length === 0}
                       onClick={() => void kaydet()}>
                 {kaydediyor ? '⏳ Düşülüyor…' : '✔ Onayla ve Düş'}
               </button>
               <button className="d" onClick={onKapat}>↷ Şimdilik Atla</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {dusuldu && (
        <div className="uyari-kutusu">
          Bu isteme daha önce sarf düşülmüş. Yeniden onaylarsanız <b>ikinci bir çıkış
          fişi</b> oluşur - yalnız eksik kalan malzemeyi işaretleyin.
        </div>
      )}

      <div className="kagrup">
        <h6>
          {tetkikAdi ?? 'Çekim'}
          <span className="sonuk"> · depo: {depo.ad || '—'}</span>
        </h6>

        {yukleniyor && <div className="bos">Yükleniyor…</div>}
        {!yukleniyor && satirlar.length === 0 && (
          <div className="not">
            Bu tetkikin çekim protokolünde <b>malzeme listesi tanımlı değil</b>.
            Çekim Protokolleri ekranından tetkikin <b>Malzeme / Sarf</b> sekmesine
            kontrast, enjektör, film gibi kalemleri ekleyin.
          </div>
        )}

        {satirlar.length > 0 && (
          <table className="detay-tablo">
            <thead>
              <tr>
                <th style={{ width: 28 }} />
                <th>Stok</th>
                <th className="hiza-sag">Protokol</th>
                <th className="hiza-sag">Kullanılan</th>
                <th>Birim</th>
                <th>Lot / SKT</th>
                <th className="hiza-sag">Kalan</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map(r => {
                const lot = stokLotlari[r.stokId] ?? [];
                const kritik = r.minStok > 0 && r.kalan - (miktar[r.stokId] ?? 0) <= r.minStok;
                return (
                  <tr key={r.stokId}>
                    <td>
                      <input type="checkbox" checked={!!secim[r.stokId]}
                             onChange={e => setSecim(s => ({ ...s, [r.stokId]: e.target.checked }))} />
                    </td>
                    <td>
                      {r.ad || r.kod}
                      {r.kural && <div className="sonuk">{r.kural}</div>}
                      {r.dusumTipi === 2 && <span className="rozet gri">istenirse</span>}
                    </td>
                    <td className="hiza-sag sonuk">{say(r.protokolMiktar)}</td>
                    <td className="hiza-sag">
                      <input type="number" min={0} step="0.01" style={{ width: 78 }}
                             value={miktar[r.stokId] ?? 0}
                             onChange={e => setMiktar(m =>
                               ({ ...m, [r.stokId]: Number(e.target.value) }))} />
                    </td>
                    <td className="sonuk">{r.birim}</td>
                    <td>
                      {r.izleme === 0 ? <span className="sonuk">—</span>
                        : lot.length === 0 ? <span className="rozet hata">lot yok</span>
                        : (
                          <select value={lotSecim[r.stokId] ?? lot[0].seriLotId}
                                  onChange={e => setLotSecim(l =>
                                    ({ ...l, [r.stokId]: Number(e.target.value) }))}>
                            {lot.map(l => (
                              <option key={l.seriLotId} value={l.seriLotId}>
                                {l.lotNo || l.seriNo}
                                {l.sonKullanmaTarihi
                                  ? ` · ${String(l.sonKullanmaTarihi).slice(0, 10)
                                          .split('-').reverse().join('.')}` : ''}
                                {` · ${say(l.kalan)}`}
                              </option>
                            ))}
                          </select>
                        )}
                    </td>
                    <td className={`hiza-sag${kritik ? ' teh' : ''}`}>
                      {say(r.kalan)}
                      {kritik && <div className="sonuk">eşik {say(r.minStok)}</div>}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}

        <div className="not">
          Protokoldeki miktarlar <b>varsayılandır</b>: kullanılmayanı çıkarın, fazla
          kullanılanı artırın. Onaylayınca <b>stok çıkış fişi</b> oluşur ve depo
          bakiyesi düşer.
        </div>
      </div>
    </Modal>
  );
}
