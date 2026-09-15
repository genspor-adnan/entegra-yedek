import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { IcmalYaniti } from '../../api/uclar/yatan';
import { paraYaz, tarihYaz } from '../bicim';

/**
 * YATAN HASTA HİZMET İCMALİ — mockup
 * `Ekranlar/Yatan/yatan_hizmet_fatura.html`.
 *
 * <b>Satırlar elle girilmez, düşer:</b> yatak ücreti gün sonu tahakkukundan,
 * ilaç kalemi uygulama kaydından (barkodla), tetkik ve görüntüleme order'dan.
 * Elle giriş açık bırakılsaydı aynı kalem hem otomatik hem elle iki kez
 * faturalanırdı — yatan hastada en sık görülen fatura hatası budur.
 *
 * <b>Hasta payı UYDURULMAZ:</b> SUT kapsam ve paket kuralları Medula'nın işi.
 * İcmal yalnız kapsam dışı olduğu kesin olanı (refakat, ödeyen kurumu olmayan
 * yatış) hasta payına yazar; gerisini "kurum" sütununda gösterir ve kesin
 * cevabın provizyondan geleceğini söyler. Tahmini bir yüzde, hastaya yanlış
 * rakam söylemenin en kısa yoludur.
 */

interface YatisSecenegi { id: number; hasta: string; yatak: string; dosyaNo: string }

const ORDER_TUR: Record<number, string> = {
  3: 'Tetkik', 4: 'Görüntüleme', 5: 'Konsültasyon',
};

export function YatanIcmal({ yenile }: { yenile?: number }) {
  const [yatislar, setYatislar] = useState<YatisSecenegi[]>([]);
  const [yatisId, setYatisId] = useState<number | null>(null);
  const [veri, setVeri] = useState<IcmalYaniti | null>(null);

  useEffect(() => {
    void (async () => {
      try {
        // TABURCU OLANLAR DA LİSTEDE: icmal çoğu zaman çıkıştan sonra okunur.
        const y = await api.liste('yatan', { sayfa: 1, boyut: 200 });
        const s = y.satirlar.map(r => ({
          id: Number(r.id), hasta: String(r.hasta ?? ''),
          yatak: String(r.yatak ?? ''), dosyaNo: String(r.dosyaNo ?? ''),
        }));
        setYatislar(s);
        setYatisId(o => o ?? (s[0]?.id ?? null));
      } catch { /* liste yoksa icmal de yok */ }
    })();
  }, []);

  const yukle = useCallback(async () => {
    if (!yatisId) { setVeri(null); return }
    try { setVeri(await api.yatisIcmal(yatisId)) } catch { setVeri(null) }
  }, [yatisId]);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  if (yatislar.length === 0) return null;
  const t = veri?.toplam;

  return (
    <div className="icmal-pano">
      <div className="emar-serit">
        <label>Yatış
          <select value={yatisId ?? ''} onChange={e => setYatisId(Number(e.target.value))}>
            {yatislar.map(y => (
              <option key={y.id} value={y.id}>
                {y.dosyaNo ? `${y.dosyaNo} · ` : ''}{y.hasta}{y.yatak ? ` · ${y.yatak}` : ''}
              </option>
            ))}
          </select>
        </label>
        {veri && (
          <div className="emar-ozet">
            <span>{veri.yatis.klinik || '—'}</span>
            <span><b>{veri.yatis.gun}</b> gün</span>
            <span>{veri.yatis.odeyen || 'Kendi ödemeli'}
              {t?.kurumVar && !t.provizyonVar && (
                <span className="rozet sari"> provizyon yok</span>
              )}
            </span>
          </div>
        )}
      </div>

      {veri && (
        <div className="icmal-govde">
          <table className="izlem-tablo icmal-tablo">
            <thead>
              <tr>
                <th>Tarih</th><th>Hizmet / malzeme</th><th>SUT</th>
                <th className="sag">Adet</th><th className="sag">Birim</th>
                <th className="sag">Tutar</th><th>Kaynak</th><th>Durum</th>
              </tr>
            </thead>
            <tbody>
              <tr className="grup"><td colSpan={8}>YATAK VE REFAKAT</td></tr>
              {veri.yatak.length === 0 && (
                <tr><td colSpan={8} className="sonuk">
                  Tahakkuk yok — gün sonu işi henüz çalışmadı ya da odanın ücret
                  hizmeti tanımsız.
                </td></tr>
              )}
              {veri.yatak.map(y => (
                <tr key={`${y.kaynak}-${y.ad}`}>
                  <td>{tarihYaz(y.ilk)}{y.son !== y.ilk && ` – ${tarihYaz(y.son)}`}</td>
                  <td>{y.ad}</td>
                  <td className="sonuk">{y.sut || '—'}</td>
                  <td className="sag">{y.adet}</td>
                  <td className="sag">{paraYaz(y.birim)}</td>
                  <td className="sag">{paraYaz(y.tutar)}</td>
                  <td className="sonuk">gün sonu</td>
                  <td>
                    {y.faturasiz > 0
                      ? <span className="rozet sari">Faturalanmadı</span>
                      : <span className="rozet ok">Faturalandı</span>}
                    {/* REFAKAT KAPSAM DIŞI: hastaya "oda farkı" diye anlatılan
                        kalem burada görünmeli. */}
                    {y.kaynak === 2 && <span className="rozet"> kapsam dışı</span>}
                  </td>
                </tr>
              ))}

              <tr className="grup"><td colSpan={8}>İLAÇ VE UYGULAMA</td></tr>
              {veri.ilac.length === 0 && (
                <tr><td colSpan={8} className="sonuk">Uygulanmış doz yok.</td></tr>
              )}
              {veri.ilac.map(i => (
                <tr key={i.ad}>
                  <td>{i.ilk ? tarihYaz(i.ilk) : '—'}
                      {i.son && i.son !== i.ilk && ` – ${tarihYaz(i.son)}`}</td>
                  <td>{i.ad}</td>
                  <td className="sonuk">{i.sut || '—'}</td>
                  <td className="sag">{i.adet}</td>
                  <td className="sag">{i.birim ? paraYaz(i.birim) : '—'}</td>
                  <td className="sag">{i.tutar ? paraYaz(i.tutar) : '—'}</td>
                  <td className="sonuk">
                    ilaç uygulama
                    {/* BARKODSUZ UYGULAMA görünür kalır: engellenmiyor ama
                        faturada da izi olmalı. */}
                    {i.barkodsuz > 0 && ` · ${i.barkodsuz} elle`}
                  </td>
                  <td>{i.hizmetId
                    ? <span className="rozet sari">Faturalanmadı</span>
                    : <span className="rozet">Hizmet kartı yok</span>}</td>
                </tr>
              ))}

              <tr className="grup"><td colSpan={8}>TETKİK · GÖRÜNTÜLEME · KONSÜLTASYON</td></tr>
              {veri.tetkik.length === 0 && (
                <tr><td colSpan={8} className="sonuk">Order yok.</td></tr>
              )}
              {veri.tetkik.map((k, i) => (
                <tr key={`${k.ad}-${i}`}>
                  <td>{tarihYaz(k.tarih)}</td>
                  <td>{k.ad}</td>
                  <td className="sonuk">{k.sut || '—'}</td>
                  <td className="sag">1</td>
                  <td className="sag">{k.birim ? paraYaz(k.birim) : '—'}</td>
                  <td className="sag">{k.birim ? paraYaz(k.birim) : '—'}</td>
                  <td className="sonuk">{ORDER_TUR[k.tur] ?? 'order'}</td>
                  <td>{k.durum === 1
                    ? <span className="rozet sari">Sonuç bekliyor</span>
                    : <span className="rozet ok">Tamamlandı</span>}</td>
                </tr>
              ))}
            </tbody>
          </table>

          {t && (
            <div className="izlem-skor">
              <div className="k"><span>HİZMET TOPLAMI</span>
                <b>{paraYaz(t.hizmet)}</b>
                <i>{veri.yatis.gun} gün</i></div>
              <div className="k"><span>KURUM PAYI</span>
                <b>{paraYaz(t.kurum)}</b>
                <i>{t.kurumVar ? (t.provizyonVar ? 'provizyonlu' : 'provizyon yok')
                              : 'ödeyen kurum yok'}</i></div>
              <div className="k uy"><span>HASTA PAYI</span>
                <b>{paraYaz(t.hasta)}</b>
                <i>kapsam dışı kalemler</i></div>
              <div className="k"><span>FATURALANMAMIŞ</span>
                <b>{paraYaz(t.faturalanmamis)}</b>
                <i>belgeye geçmedi</i></div>
            </div>
          )}

          <div className="not">
            <b>Satırlar elle girilmez, düşer:</b> yatak ücreti gün sonu tahakkukundan,
            ilaç kalemi uygulama kaydından, tetkik order'dan. <b>Kurum/hasta ayrımının
            kesin cevabı Medula provizyonundan gelir</b> — burada yalnız kapsam dışı
            olduğu kesin olan (refakat, ödeyen kurumu olmayan yatış) hasta payına
            yazılır; tahmini bir yüzde uydurmak hastaya yanlış rakam söylemek olurdu.
          </div>
        </div>
      )}
    </div>
  );
}
