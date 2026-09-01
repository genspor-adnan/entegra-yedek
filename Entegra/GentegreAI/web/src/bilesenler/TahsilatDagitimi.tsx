import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { para } from './bicim';
import { mesaj } from './mesaj';

/**
 * TAHSİLAT DAĞITIMI (321) — ödeme hangi belge SATIRINA gitti?
 *
 * Tahsilat bugüne kadar yalnız belgeye bağlanıyordu; "hangi tetkiğin parası
 * alındı" bilinmiyordu. Prim kuralı <b>tahsil edildikçe</b> olduğu için bu
 * kırılım gerçek veri olmak zorunda - oransal tahmin primi yanlış tetikler.
 *
 * Panel kaydetmez: seçimi dışarı verir (onDegisti), kasa işlemi kaydedildikten
 * sonra tek istekle yazılır. İşlem henüz kaydedilmemişken de çalışır.
 */

export interface DagitimSecimi { belgeSatirId: number; pay: number; tutar: number }

interface Satir {
  satirId: number; sira: number; kalem: string; kalemKod: string;
  tutar: number; hastaTutar: number; kurumTutar: number;
  hastaTahsil: number; kurumTahsil: number;
  hastaKalan: number; kurumKalan: number;
  buIslemHasta: number; buIslemKurum: number;
}

export function TahsilatDagitimi({ belgeId, kasaIslemId, tutar, onDegisti }: {
  belgeId: number;
  /** Kayıtlı işlemin mevcut dağıtımı ön dolu gelsin diye (düzenleme). */
  kasaIslemId?: number | null;
  /** İşlemin tutarı - dağıtılabilecek üst sınır. */
  tutar: number;
  onDegisti(secim: DagitimSecimi[]): void;
}) {
  const [satirlar, setSatirlar] = useState<Satir[]>([]);
  const [deger, setDeger] = useState<Record<string, number>>({});
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);

  const anahtar = (satirId: number, pay: number) => `${satirId}|${pay}`;

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try {
      const y = await api.kasaDagitimSatirlari(belgeId, kasaIslemId ?? undefined);
      const liste = (y.satirlar ?? []).map(r => ({
        satirId: Number(r.satirId), sira: Number(r.sira ?? 0),
        kalem: String(r.kalem ?? ''), kalemKod: String(r.kalemKod ?? ''),
        tutar: Number(r.tutar ?? 0),
        hastaTutar: Number(r.hastaTutar ?? 0), kurumTutar: Number(r.kurumTutar ?? 0),
        hastaTahsil: Number(r.hastaTahsil ?? 0), kurumTahsil: Number(r.kurumTahsil ?? 0),
        hastaKalan: Number(r.hastaKalan ?? 0), kurumKalan: Number(r.kurumKalan ?? 0),
        buIslemHasta: Number(r.buIslemHasta ?? 0), buIslemKurum: Number(r.buIslemKurum ?? 0),
      })) as Satir[];
      setSatirlar(liste);

      // Kayitli islemin kendi dagitimi varsa ONU goster; yoksa tutari
      //   siraya gore kalanlara dagit (once hasta payi - kasadan gelen para
      //   cogunlukla hastanin, kurum payi icmalle kapanir).
      const d: Record<string, number> = {};
      const varOlan = liste.some(r => r.buIslemHasta > 0 || r.buIslemKurum > 0);
      if (varOlan) {
        liste.forEach(r => {
          if (r.buIslemHasta > 0) d[anahtar(r.satirId, 1)] = r.buIslemHasta;
          if (r.buIslemKurum > 0) d[anahtar(r.satirId, 2)] = r.buIslemKurum;
        });
      } else {
        let kalan = tutar;
        liste.forEach(r => {
          [[1, r.hastaKalan], [2, r.kurumKalan]].forEach(([pay, payKalan]) => {
            if (kalan <= 0 || payKalan <= 0) return;
            const ver = Math.min(payKalan, kalan);
            d[anahtar(r.satirId, pay)] = Math.round(ver * 100) / 100;
            kalan -= ver;
          });
        });
      }
      setDeger(d);
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [belgeId, kasaIslemId, tutar]);

  useEffect(() => { void yukle() }, [yukle]);

  const toplam = useMemo(
    () => Object.values(deger).reduce((t, v) => t + (Number(v) || 0), 0), [deger]);

  useEffect(() => {
    onDegisti(Object.entries(deger)
      .filter(([, v]) => (Number(v) || 0) > 0)
      .map(([k, v]) => {
        const [satirId, pay] = k.split('|').map(Number);
        return { belgeSatirId: satirId, pay, tutar: Number(v) };
      }));
    // onDegisti her renderda degisebilir (inline fonksiyon): bagimliliga
    //   koyarsak sonsuz donguye girer - degerin kendisi yeterli.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [deger]);

  const yaz = (satirId: number, pay: number, v: number) =>
    setDeger(d => ({ ...d, [anahtar(satirId, pay)]: v }));

  const otomatik = () => {
    let kalan = tutar;
    const d: Record<string, number> = {};
    satirlar.forEach(r => {
      [[1, r.hastaKalan], [2, r.kurumKalan]].forEach(([pay, payKalan]) => {
        if (kalan <= 0 || payKalan <= 0) return;
        const ver = Math.min(payKalan, kalan);
        d[anahtar(r.satirId, pay)] = Math.round(ver * 100) / 100;
        kalan -= ver;
      });
    });
    setDeger(d);
  };

  const fark = Math.round((tutar - toplam) * 100) / 100;

  /**
   * DAGITIMI TEK BASINA KAYDET (322): kayitli islemde kartin "Değişiklikleri
   * Kaydet" yolu belgeyi ve muhasebe fisini yeniden yaziyor - yalniz dagitim
   * degistiyse bu fazla agir. Bu dugme sadece dagitim satirlarini yazar.
   */
  const [kaydediyor, setKaydediyor] = useState(false);
  const kaydet = async () => {
    if (!kasaIslemId) return;
    setHata(''); setKaydediyor(true);
    try {
      const secim = Object.entries(deger)
        .filter(([, v]) => (Number(v) || 0) > 0)
        .map(([k, v]) => {
          const [satirId, pay] = k.split('|').map(Number);
          return { belgeSatirId: satirId, pay, tutar: Number(v) };
        });
      const y = await api.kasaDagitimYaz(kasaIslemId, { belgeId, satirlar: secim });
      mesaj(y.avans > 0
        ? `Dağıtım kaydedildi. Dağıtılmayan (avans): ${para.format(y.avans)}`
        : 'Dağıtım kaydedildi.');
      await yukle();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <div className="kagrup">
      <div className="numaralama-bas bitisik">
        <h6>Tahsilat Dağıtımı</h6>
        <button type="button" className="d" onClick={otomatik}>⇄ Otomatik Dağıt</button>
        <button type="button" className="d" onClick={() => setDeger({})}>Temizle</button>
        {kasaIslemId ? (
          <button type="button" className="d bir" disabled={kaydediyor}
                  onClick={() => void kaydet()}>
            {kaydediyor ? '⏳ Kaydediliyor…' : '💾 Dağıtımı Kaydet'}
          </button>
        ) : null}
        <span className={`rozet ${fark === 0 ? 'ok' : fark > 0 ? 'uyari' : 'hata'}`}
              style={{ marginLeft: 'auto' }}>
          {fark === 0 ? 'Tam dağıtıldı'
            : fark > 0 ? `Dağıtılmayan (avans): ${para.format(fark)}`
            : `Fazla dağıtıldı: ${para.format(-fark)}`}
        </span>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {yukleniyor && <div className="bos">Yükleniyor…</div>}

      {!yukleniyor && satirlar.length === 0 && (
        <div className="not">Belgede dağıtılacak satır yok.</div>
      )}

      {satirlar.length > 0 && (
        <table className="detay-tablo">
          <thead>
            <tr>
              <th>Kalem</th>
              <th className="hiza-sag">Hasta payı<div className="sonuk">KDV dahil</div></th>
              <th className="hiza-sag">Kalan</th>
              <th className="hiza-sag">Bu tahsilat</th>
              <th className="hiza-sag">Kurum payı<div className="sonuk">KDV dahil</div></th>
              <th className="hiza-sag">Kalan</th>
              <th className="hiza-sag">Bu tahsilat</th>
            </tr>
          </thead>
          <tbody>
            {satirlar.map(r => (
              <tr key={r.satirId}>
                <td>{r.kalem || r.kalemKod || `#${r.satirId}`}</td>
                <td className="hiza-sag sonuk">{para.format(r.hastaTutar)}</td>
                <td className="hiza-sag">{para.format(r.hastaKalan)}</td>
                <td className="hiza-sag">
                  <input type="number" min={0} step="0.01" style={{ width: 92 }}
                         disabled={r.hastaTutar <= 0}
                         value={deger[anahtar(r.satirId, 1)] ?? 0}
                         onChange={e => yaz(r.satirId, 1, Number(e.target.value))} />
                </td>
                <td className="hiza-sag sonuk">{para.format(r.kurumTutar)}</td>
                <td className="hiza-sag">{para.format(r.kurumKalan)}</td>
                <td className="hiza-sag">
                  <input type="number" min={0} step="0.01" style={{ width: 92 }}
                         disabled={r.kurumTutar <= 0}
                         value={deger[anahtar(r.satirId, 2)] ?? 0}
                         onChange={e => yaz(r.satirId, 2, Number(e.target.value))} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <div className="not">
        Dağıtım <b>prim hakedişini</b> besler: prim, tetkik yapıldığında değil
        parası <b>tahsil edildikçe</b> doğar. Dağıtılmayan tutar <b>avans</b> olarak
        kalır - sonraki tahsilatta ya da başka bir kalemde kullanılabilir.
        <br />Buradaki tutarlar <b>KDV dahildir</b> (hastanın fiilen ödediği tutar);
        prim tabanı ise <b>KDV hariç matrahtır</b> - KDV kurumun geliri değildir.
      </div>
    </div>
  );
}
