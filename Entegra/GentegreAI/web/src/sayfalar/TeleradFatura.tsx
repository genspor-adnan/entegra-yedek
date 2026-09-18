import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';

/**
 * TELERADYOLOJİ DÖNEM FATURASI (803) — mockup
 * `Ekranlar/Teleradyoloji/telerad_kurum_sozlesme.html` ("Dönem Faturası Üret").
 *
 * Teleradyoloji işi tek tek faturalanmaz: dönem sonunda o kurumun onaylanmış
 * işleri TEK satış faturasına girer.
 *
 * <b>Önce önizleme, sonra fatura.</b> Ekran önce "bu dönemde ne faturalanacak"
 * sorusunu cevaplar - kurum icmalindeki desenin aynısı (289). Faturaya
 * GİREMEYEN işler de listelenir: eksikleri sessizce atlamak, kuruma eksik
 * fatura kesmek demekti.
 *
 * <b>Tutarı istemci hesaplamaz.</b> Satır tutarları sunucudan gelir, faturanın
 * kendisini belge hattı hesaplar (`BelgeHesap`). Burada yalnız gösterim var.
 */

interface Satir {
  hizmetId: number; hizmetAdi: string; kdv: number; birimFiyat: number;
  slaAsildi: boolean; adet: number; tutar: number; cezaOrani: number;
}
interface Eksik { id: number; istekNo: string; ucret: number; sebep: string }
interface Ozet {
  tarafId: number; kurumAdi: string; ucretModeli: number; cezaOrani: number;
  satirlar: Satir[]; eksikler: Eksik[]; istekIdler: number[]; toplam: number;
}
interface Kurum { id: number; kurumAdi?: string; unvan?: string }

const UCRET_MODELI: Record<number, string> =
  { 1: 'Tetkik başı', 2: 'Aylık sabit + aşım', 3: 'Vaka başı' };

const para = (t: number) =>
  Number(t).toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/** Ayın ilk ve son günü: dönem faturası ay bazlıdır (sözleşme periyodu). */
const ayAraligi = (ay: string) => {
  const [y, a] = ay.split('-').map(Number);
  const son = new Date(y, a, 0);
  return { bas: `${ay}-01`, bit: `${ay}-${String(son.getDate()).padStart(2, '0')}` };
};

const gecenAy = () => {
  const t = new Date();
  const g = new Date(t.getFullYear(), t.getMonth() - 1, 1);
  return `${g.getFullYear()}-${String(g.getMonth() + 1).padStart(2, '0')}`;
};

export function TeleradFatura() {
  const git = useNavigate();
  const [sorgu] = useSearchParams();
  const [kurumlar, setKurumlar] = useState<Kurum[]>([]);
  const [kurumId, setKurumId] = useState<number>(Number(sorgu.get('kurumId')) || 0);
  const [ay, setAy] = useState(gecenAy);
  const [ozet, setOzet] = useState<Ozet | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  // Kurum listesi ORTAK LİSTE UCUNDAN: ayrı bir "kurum seçimi" ucu açmak,
  //   yetki ve şube süzmesini ikinci kez yazmak demekti.
  useEffect(() => {
    void (async () => {
      try {
        const y = await api.liste('telerad-kurum', { sayfa: 1, boyut: 200 });
        const satirlar = (y.satirlar ?? []) as unknown as Kurum[];
        setKurumlar(satirlar);
        if (!kurumId && satirlar.length > 0) setKurumId(satirlar[0].id);
      } catch (h) { setHata(hataMetni(h)) }
    })();
    // İlk açılışta bir kez: kurum listesi dönem değişince yenilenmez.
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const yukle = useCallback(async () => {
    if (!kurumId) return;
    setYukleniyor(true); setHata('');
    try {
      const { bas, bit } = ayAraligi(ay);
      setOzet(await api.teleradFaturaOnizleme<Ozet>(kurumId, bas, bit));
    } catch (h) { setHata(hataMetni(h)); setOzet(null) }
    finally { setYukleniyor(false) }
  }, [kurumId, ay]);

  useEffect(() => { void yukle() }, [yukle]);

  const uret = async () => {
    if (!ozet || ozet.satirlar.length === 0) return;
    const { bas, bit } = ayAraligi(ay);
    if (!(await onay(
          `${ozet.kurumAdi} için ${ozet.satirlar.length} satırlık dönem faturası `
          + `üretilsin mi? Toplam ${para(ozet.toplam)} ₺, ${ozet.istekIdler.length} istek `
          + 'faturalanmış olarak işaretlenecek.'))) return;
    await guvenli(async () => {
      const sonuc = await api.teleradFatura(kurumId, bas, bit);
      mesaj(`Fatura üretildi: ${sonuc.satir} satır, ${sonuc.istek} istek.`);
      git(`/belge/${sonuc.belgeId}`);
    });
  };

  const kurumAdi = (k: Kurum) => k.kurumAdi ?? k.unvan ?? `#${k.id}`;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Teleradyoloji Dönem Faturası</h1>
          <span className="yol">Radyoloji › Teleradyoloji › Dönem Faturası</span>
        </div>
        <div className="basarac">
          <select value={kurumId} onChange={e => setKurumId(Number(e.target.value))}>
            {kurumlar.map(k => <option key={k.id} value={k.id}>{kurumAdi(k)}</option>)}
          </select>
          <input type="month" value={ay} onChange={e => setAy(e.target.value)} />
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
          <button className="d basari" disabled={!ozet || ozet.satirlar.length === 0}
                  onClick={() => void uret()}>🧾 Fatura Üret</button>
          {yukleniyor && <span className="sonuk">Yükleniyor…</span>}
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}

        {ozet && (
          <div className="pano-satir">
            <div className="kagrup">
              <h6>Faturalanacak İşler
                <span className="sonuk">
                  {UCRET_MODELI[ozet.ucretModeli] ?? '—'}
                  {ozet.cezaOrani > 0 && ` · SLA cezası %${ozet.cezaOrani}`}
                </span>
              </h6>
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th>Tetkik</th><th className="hiza-sag">Adet</th>
                    <th className="hiza-sag">Birim</th><th className="hiza-sag">İskonto</th>
                    <th className="hiza-sag">KDV</th><th className="hiza-sag">Tutar</th>
                  </tr>
                </thead>
                <tbody>
                  {ozet.satirlar.map((s, i) => (
                    <tr key={i}>
                      <td>
                        {s.hizmetAdi}
                        {s.slaAsildi && <span className="rozet hata"> SLA aşımı</span>}
                      </td>
                      <td className="hiza-sag">{s.adet}</td>
                      <td className="hiza-sag">{para(s.birimFiyat)}</td>
                      <td className="hiza-sag">{s.cezaOrani > 0 ? `%${s.cezaOrani}` : '—'}</td>
                      <td className="hiza-sag">%{s.kdv}</td>
                      <td className="hiza-sag">{para(s.tutar)}</td>
                    </tr>
                  ))}
                  {ozet.satirlar.length === 0 && !yukleniyor && (
                    <tr><td className="bos" colSpan={6}>
                      Bu dönemde faturalanacak iş yok. Yalnız onaylanmış/teslim edilmiş
                      ve daha önce faturalanmamış istekler faturaya girer.
                    </td></tr>
                  )}
                </tbody>
                {ozet.satirlar.length > 0 && (
                  <tfoot>
                    <tr>
                      <td colSpan={5}><b>Toplam</b> <span className="sonuk">
                        (KDV ve iskonto faturada hesaplanır)</span></td>
                      <td className="hiza-sag"><b>{para(ozet.toplam)}</b></td>
                    </tr>
                  </tfoot>
                )}
              </table>
              <div className="pano-not">
                Ücret istek açılırken sözleşme tarifesinden kopyalanmıştı; burada yalnız
                toplanıyor. <b>SLA cezası satır iskontosudur</b> — yalnız süresi kaçan
                işlere uygulanır. Fatura tutarını belge hattı hesaplar.
              </div>
            </div>

            <div className="kagrup">
              <h6>Faturaya Giremeyenler
                <span className="sonuk">düzeltilmeden fatura eksik kalır</span></h6>
              <table className="detay-tablo">
                <thead>
                  <tr><th>İstek</th><th className="hiza-sag">Ücret</th><th>Sebep</th></tr>
                </thead>
                <tbody>
                  {ozet.eksikler.map(e => (
                    <tr key={e.id}>
                      <td>
                        <button className="d mini" onClick={() => git(`/teleradyoloji/${e.id}`)}>
                          {e.istekNo || `#${e.id}`}
                        </button>
                      </td>
                      <td className="hiza-sag">{para(e.ucret)}</td>
                      <td><span className="rozet uyari">{e.sebep}</span></td>
                    </tr>
                  ))}
                  {ozet.eksikler.length === 0 && (
                    <tr><td className="bos" colSpan={3}>
                      Dönemin bütün onaylı işleri faturaya giriyor.
                    </td></tr>
                  )}
                </tbody>
              </table>
              <div className="pano-not">
                Tetkik eşleşmesi olmayan ya da ücreti yazılmamış istek faturaya
                <b> giremez</b>: eksiği sessizce atlamak kuruma eksik fatura kesmek olurdu.
                İstek numarasına tıklayıp düzeltebilirsiniz.
              </div>
            </div>
          </div>
        )}
      </div>
    </>
  );
}
