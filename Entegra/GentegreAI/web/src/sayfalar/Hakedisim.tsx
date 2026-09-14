import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { para } from '../bilesenler/bicim';

/** Para bicimi + simge: `para` bir Intl bicimlendiricisidir. */
const tl = (v: unknown) => `${para.format(Number(v ?? 0))} ₺`;

/**
 * HAKEDİŞLERİM — hekimin KENDİ prim dökümü.
 * Mockup: <code>Ekranlar/Muayene/hekim_hakedislerim.html</code>.
 *
 * Prim modülündeki hakediş listesi/kartı MUHASEBENİN ekranıdır (bütün
 * kişiler, onay, dönem kapatma). Bu ekran tek kişiliktir ve SALT OKUNUR:
 * hekim hakedişini okur, tutarı tartışmalıysa muhasebeye gider.
 *
 * <b>Süzgeci sunucu koyar.</b> Kişi parametresi YOKTUR - uç oturumun
 * kişisini kullanır (`prim.kendi` yetkisi). İstemciye bırakılsaydı adres
 * çubuğundaki bir sayıyı değiştiren herkes başkasının primini okurdu.
 *
 * <b>Tahsil edilen ile bekleyen ayrı gösterilir.</b> Prim planı "hakediş
 * anı = tahsilatta" ise faturalanmış ama tahsil edilmemiş tutar henüz hak
 * edilmiş değildir; tek toplam, hekime olmayan parayı vaat ederdi.
 */

interface Satir {
  id: number; tarih: string; hasta: string; kalem: string;
  kaynakTur: number; kaynakAdi: string; pay: number; payAdi: string;
  taban: number; oranTipi: number; deger: number; tutar: number;
  durum: number; durumAdi: string; rolAdi: string;
  belgeNo: string; belgeTurAdi: string;
}
interface Gecmis {
  id: number; donemBaslangic: string; donemBitis: string;
  durum: number; toplam: number; aciklama: string;
}

/** Dönem durumu: 0 taslak · 1 kapandı · 2 ödendi (hakedis.durum). */
const DONEM_DURUM: Record<number, string> = {
  0: 'Taslak', 1: 'Kapandı', 2: 'Ödendi',
};

const gunMetni = (t: Date) =>
  `${t.getFullYear()}-${String(t.getMonth() + 1).padStart(2, '0')}-${String(t.getDate()).padStart(2, '0')}`;

/** Ayın ilk ve son günü - "dönem" hep bir aydır (hakediş dönemi de öyle). */
function ayAraligi(ay: string): { bas: string; bit: string } {
  const [y, a] = ay.split('-').map(Number);
  return { bas: gunMetni(new Date(y, a - 1, 1)), bit: gunMetni(new Date(y, a, 0)) };
}

const buAy = () => new Date().toISOString().slice(0, 7);
const kisaTarih = (ham: unknown) => String(ham ?? '').slice(8, 10) + '.' + String(ham ?? '').slice(5, 7);

/** Oran metni: yüzde ise "%10", tutar ise para (oran_tipi 1 yüzde · 2 tutar). */
const oranMetni = (tip: number, deger: number) =>
  tip === 2 ? tl(deger) : `%${String(deger).replace('.', ',')}`;

export function Hakedisim() {
  const [ay, setAy] = useState(buAy);
  const [veri, setVeri] = useState<Awaited<ReturnType<typeof api.hakedisim>> | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  /** Kaynak çipi: '' tümü, yoksa rol adı (Muayene / Girişim / İsteyen hekim…). */
  const [cip, setCip] = useState('');

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    const { bas, bit } = ayAraligi(ay);
    try { setVeri(await api.hakedisim(bas, bit)) }
    catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [ay]);

  useEffect(() => { void yukle() }, [yukle]);

  const satirlar = useMemo(
    () => ((veri?.satirlar ?? []) as unknown as Satir[])
      .filter(s => cip === '' || s.rolAdi === cip),
    [veri, cip]);

  const o = veri?.ozet;
  const tahsilOran = o && o.toplam > 0 ? Math.round(o.tahsil * 100 / o.toplam) : 0;
  // Ortalama İŞLEM primi: satır sayısına bölünür - hekimin "bir işten ne
  //   kalıyor" sorusu bu; toplam/gün ya da toplam/hasta başka sorular.
  const ortalama = o && o.satir > 0 ? o.toplam / Number(o.satir) : 0;

  /** Satırlar rol adına göre gruplanır: "bu para nereden geldi". */
  const gruplar = useMemo(() => {
    const m = new Map<string, Satir[]>();
    for (const s of satirlar) {
      const ad = s.rolAdi || 'Diğer';
      (m.get(ad) ?? m.set(ad, []).get(ad)!).push(s);
    }
    return [...m.entries()];
  }, [satirlar]);

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Hakedişlerim</h1>
          <span className="yol">Muayene › Hakedişlerim</span>
        </div>
        <div className="basarac">
          <input type="month" value={ay} onChange={e => setAy(e.target.value)} />
          <button className="d" onClick={() => setAy(buAy())}>Bu ay</button>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
          {yukleniyor && <span className="sonuk">Yükleniyor…</span>}
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}

        {/* ÖZET: ilk soru "bu ay ne kadar", ikincisi "ne kadarı kesinleşti". */}
        <div className="pano-sayaclar">
          <div className="pano-kutu">
            <span className="ik">💰</span>
            <span className="s">{tl(o?.toplam ?? 0)}</span>
            <span className="e">Dönem hakedişi · {o?.satir ?? 0} işlem</span>
          </div>
          <div className="pano-kutu">
            <span className="ik">✅</span>
            <span className="s">{tl(o?.tahsil ?? 0)}</span>
            <span className="e">Tahsil edilen · %{tahsilOran}</span>
          </div>
          <div className={`pano-kutu${(o?.bekleyen ?? 0) > 0 ? ' uy' : ''}`}>
            <span className="ik">⏳</span>
            <span className="s">{tl(o?.bekleyen ?? 0)}</span>
            <span className="e">Tahsilat bekleyen</span>
          </div>
          <div className="pano-kutu">
            <span className="ik">📊</span>
            <span className="s">{tl(ortalama)}</span>
            <span className="e">Ortalama işlem primi</span>
          </div>
          <div className="pano-kutu">
            <span className="ik">🧾</span>
            <span className="s">{tl(o?.taban ?? 0)}</span>
            <span className="e">Üretilen ciro (taban)</span>
          </div>
        </div>

        <div className="pano-satir">
          {/* SATIRLAR: kaynak (rol) başlıklarıyla gruplu. */}
          <div className="kagrup">
            <h6>
              Hakediş satırları
              <span className="baslik-eylem">
                <button type="button" className={`d${cip === '' ? ' bir' : ''}`}
                        onClick={() => setCip('')}>Tümü</button>
                {(veri?.kirilim ?? []).map(k => (
                  <button key={k.ad} type="button"
                          className={`d${cip === k.ad ? ' bir' : ''}`}
                          onClick={() => setCip(k.ad)}>
                    {k.ad}
                  </button>
                ))}
              </span>
            </h6>
            <div className="detay-kaydir">
              <table className="detay-tablo">
                <thead><tr>
                  <th>Tarih</th><th>Hasta</th><th>Belge</th><th>İşlem</th>
                  <th className="orta">Kaynak</th><th className="orta">Pay</th>
                  <th className="sag">Taban</th><th className="orta">Oran</th>
                  <th className="sag">Hakediş</th><th className="orta">Durum</th>
                </tr></thead>
                <tbody>
                  {gruplar.map(([ad, liste]) => (
                    <Fragmanli key={ad} ad={ad} liste={liste} />
                  ))}
                  {satirlar.length === 0 && !yukleniyor && (
                    <tr><td colSpan={10} className="bos">
                      Bu dönemde hakediş satırınız yok.
                    </td></tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>

          <div style={{ minWidth: 280, maxWidth: 320 }}>
            {/* KIRILIM: hangi iş ne kadar getirdi. */}
            <div className="kagrup">
              <h6>Dönem özeti</h6>
              <table className="detay-tablo">
                <tbody>
                  {(veri?.kirilim ?? []).map(k => (
                    <tr key={k.ad}>
                      <td>{k.ad}</td>
                      <td className="sag sonuk">{k.satir}</td>
                      <td className="sag"><b>{tl(k.tutar)}</b></td>
                    </tr>
                  ))}
                  <tr>
                    <td><b>Toplam</b></td>
                    <td className="sag sonuk">{o?.satir ?? 0}</td>
                    <td className="sag"><b>{tl(o?.toplam ?? 0)}</b></td>
                  </tr>
                </tbody>
              </table>
            </div>

            {/* ÖDEME GEÇMİŞİ: kapanmış dönemler - "geçen ay ne aldım". */}
            <div className="kagrup">
              <h6>Ödeme geçmişi</h6>
              <table className="detay-tablo">
                <thead><tr>
                  <th>Dönem</th><th className="sag">Tutar</th><th className="orta">Durum</th>
                </tr></thead>
                <tbody>
                  {((veri?.gecmis ?? []) as unknown as Gecmis[]).map(g => (
                    <tr key={g.id}>
                      <td>{String(g.donemBaslangic).slice(0, 7).split('-').reverse().join('/')}</td>
                      <td className="sag">{tl(g.toplam)}</td>
                      <td className="orta">
                        <span className={`rozet${g.durum === 2 ? ' olumlu'
                                                : g.durum === 1 ? ' uyari' : ''}`}>
                          {DONEM_DURUM[g.durum] ?? '—'}
                        </span>
                      </td>
                    </tr>
                  ))}
                  {(veri?.gecmis ?? []).length === 0 && !yukleniyor && (
                    <tr><td colSpan={3} className="bos">Kapanmış dönem yok.</td></tr>
                  )}
                </tbody>
              </table>
            </div>

            <div className="not" style={{ padding: '6px 10px' }}>
              Dönem kapanana kadar tutar <b>kesinleşmez</b>: iptal, iade ve geç
              tahsilat satırları etkiler. Dönemi muhasebe kapatır.
            </div>
          </div>
        </div>
      </div>
    </>
  );

  /** Grup başlığı + satırları - tek geçişte, sırayı bozmadan. */
  function Fragmanli({ ad, liste }: { ad: string; liste: Satir[] }) {
    const toplam = liste.reduce((t, s) => t + Number(s.tutar ?? 0), 0);
    return (
      <>
        <tr className="grup-satiri">
          <td colSpan={8}><b>{ad}</b> <span className="sonuk">· {liste.length} işlem</span></td>
          <td className="sag"><b>{tl(toplam)}</b></td>
          <td />
        </tr>
        {liste.map(s => (
          <tr key={s.id}>
            <td>{kisaTarih(s.tarih)}</td>
            <td>{s.hasta || <span className="sonuk">—</span>}</td>
            <td className="sonuk">{s.belgeNo || '—'}</td>
            <td>{s.kalem || s.belgeTurAdi}</td>
            {/* KAYNAK: tahsilattan mı faturalamadan mı doğdu - hakedişin
                kesinliğini bu belirler. */}
            <td className="orta">
              <span className={`rozet${s.kaynakTur === 1 ? '' : ' uyari'}`}>
                {s.kaynakAdi}
              </span>
            </td>
            <td className="orta"><span className="rozet gri">{s.payAdi}</span></td>
            <td className="sag">{tl(s.taban)}</td>
            <td className="orta">{oranMetni(s.oranTipi, s.deger)}</td>
            <td className="sag"><b>{tl(s.tutar)}</b></td>
            <td className="orta">
              <span className={`rozet${s.durum === 2 ? ' olumlu' : ''}`}>{s.durumAdi}</span>
            </td>
          </tr>
        ))}
      </>
    );
  }
}
