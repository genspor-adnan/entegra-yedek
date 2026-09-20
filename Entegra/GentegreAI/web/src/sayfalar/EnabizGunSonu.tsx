import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { AySonuSatiri, GunSonuPanosu } from '../api/uclar/enabiz';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj } from '../bilesenler/mesaj';
import { gunNokta, tarihSaat } from '../bilesenler/bicim';
import { c as cev } from '../dil/ceviri';

/**
 * GÜN SONU VE GÖNDERİM ORANI (884 — KTS maddeleri H13 / D24).
 *
 * Ekran iki soruyu birden cevaplar, çünkü denetimde ikisi peş peşe sorulur:
 * "gün sonu gönderiliyor mu" ve "gönderim oranı %95-103 aralığında mı".
 *
 * <b>Oran kurumun KENDİ tarafındaki orandır:</b> üretilen paketlerin kaçı
 * gönderildi. Bakanlık tarafındaki sayı geri bildirim raporundan gelir;
 * denetimde iki sayı karşılaştırılır. Aralık dışı gün kırmızıdır - eksik
 * gönderim, denetimde ilk bakılan yerdir.
 *
 * <b>Gün sonu elle de hesaplanabilir:</b> zamanlı iş gece çalışır ama geç
 * girilen kayıtlardan sonra gün yeniden hesaplanabilmeli (satırlar
 * güncellenir, ikinci kayıt açılmaz).
 */
export function EnabizGunSonu() {
  const [veri, setVeri] = useState<GunSonuPanosu | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [tarih, setTarih] = useState(() =>
    new Date(Date.now() - 86400000).toISOString().slice(0, 10));
  const [acikGun, setAcikGun] = useState<number | null>(null);
  const [satirlar, setSatirlar] = useState<{ skrsKod: number; ad: string; sayi: number }[]>([]);
  // AY SONU (885): 408 aynı ölçütleri KLİNİK kırılımıyla ister.
  const [aylar, setAylar] = useState<AySonuSatiri[]>([]);
  const [kodsuz, setKodsuz] = useState<{ ad: string; muayene: number }[]>([]);
  const [acikAy, setAcikAy] = useState<number | null>(null);
  const [aySatir, setAySatir] = useState<{ klinikKodu: string; klinik: string; skrsKod: number; ad: string; sayi: number }[]>([]);

  const yukle = useCallback(async () => {
    try {
      setVeri(await api.enabizGunSonuPano());
      const a = await api.enabizAySonuListe();
      setAylar(a.aylar); setKodsuz(a.kodsuzBolumler); setHata(null);
    }
    catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  const hesapla = async () => {
    await guvenli(async () => {
      const y = await api.enabizGunSonuHesapla(tarih);
      mesaj(y.mesaj);
      await yukle();
    });
  };

  const ayHesapla = async () => {
    const d = new Date(tarih);
    await guvenli(async () => {
      const y = await api.enabizAySonuHesapla(d.getFullYear(), d.getMonth() + 1);
      mesaj(y.mesaj);
      await yukle();
    });
  };

  const ayAc = async (id: number) => {
    if (acikAy === id) { setAcikAy(null); return }
    const y = await api.enabizAySonuDetay(id);
    setAySatir(y.satirlar); setAcikAy(id);
  };

  const gunAc = async (id: number) => {
    if (acikGun === id) { setAcikGun(null); return }
    const y = await api.enabizGunSonuDetay(id);
    setSatirlar(y.satirlar); setAcikGun(id);
  };

  if (hata) return <div className="hata-kutusu" style={{ margin: 10 }}>{hata}</div>;
  if (!veri) return <div className="sonuk" style={{ padding: 12 }}>{cev('Yükleniyor…')}</div>;

  const o = veri.ozet;
  return (
    <div className="liste-sayfa">
      <div className="ds-arac">
        <b>📅 {cev('Gün Sonu ve Gönderim Oranı')}</b>
        <span className={`rozet ${o.toplamUretilen === 0 ? 'gri' : o.aralikta ? 'ok' : 'hata'}`}>
          {cev('Gönderim oranı')}: %{o.genelOran}
        </span>
        <span className="sonuk">
          ({o.toplamGonderilen}/{o.toplamUretilen} {cev('paket')} ·
          {cev(' Bakanlık aralığı')} %{o.altSinir}-{o.ustSinir})
        </span>
        <span className="ds-sp">
          <input type="date" value={tarih} onChange={e => setTarih(e.target.value)} />
          <button className="d bir" onClick={() => void hesapla()}>
            🧮 {cev('Gün sonunu hesapla')}
          </button>
          <button className="d" onClick={() => void ayHesapla()}
                  title={cev('Seçili tarihin ayı için 408 paketi')}>
            📆 {cev('Ay sonunu hesapla')}
          </button>
          <button className="d" onClick={() => void yukle()} title={cev('Yenile')}>⟳</button>
        </span>
      </div>

      {!o.aralikta && o.toplamUretilen > 0 && (
        <div className="uyari-kutusu" style={{ margin: 10 }}>
          {cev('Gönderim oranı Bakanlığın beklediği aralığın dışında')} (%{o.genelOran}).{' '}
          {cev('Bekleyen paketler e-Nabız kuyruğunda (enabiz.gonder işi kapalı olabilir) ya da hata almış olabilir.')}
        </div>
      )}

      <div className="lab-ikili" style={{ margin: 10 }}>
        <div className="kagrup">
          <div className="ds-gb">{cev('Gün sonu kayıtları')}</div>
          <div className="ds-dg"><table>
            <thead><tr>
              <th className="orta">{cev('Gün')}</th><th className="orta">{cev('Ölçüt')}</th>
              <th className="sag">{cev('Toplam')}</th><th className="orta">{cev('Paket')}</th>
              <th className="orta">{cev('Hesap')}</th>
            </tr></thead>
            <tbody>
              {veri.gunler.map(g => (
                <>
                  <tr key={g.id} onClick={() => void gunAc(g.id)} style={{ cursor: 'pointer' }}>
                    <td className="orta">{gunNokta(g.tarih)}</td>
                    <td className="orta">{g.olcut}</td>
                    <td className="sag">{g.toplam}</td>
                    <td className="orta">
                      {g.paketNo
                        ? <span className={`rozet ${g.paketDurum === 3 ? 'ok' : 'uyari'}`}>{g.paketNo}</span>
                        : <span className="sonuk">—</span>}
                    </td>
                    <td className="orta sonuk">{tarihSaat(g.hesapZamani)}</td>
                  </tr>
                  {acikGun === g.id && (
                    <tr key={`${g.id}-d`}><td colSpan={5}>
                      <table className="ds-icon-tablo">
                        <tbody>
                          {satirlar.map(s => (
                            <tr key={s.skrsKod}>
                              <td className="sonuk">{s.skrsKod}</td>
                              <td>{s.ad}</td>
                              <td className="sag"><b>{s.sayi}</b></td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </td></tr>
                  )}
                </>
              ))}
              {veri.gunler.length === 0 && (
                <tr><td colSpan={5} className="sonuk">{cev('Gün sonu kaydı yok - tarih seçip hesaplayın.')}</td></tr>
              )}
            </tbody>
          </table></div>
        </div>

        <div className="kagrup">
          <div className="ds-gb">{cev('Paket gönderim oranı (gün · paket türü)')}</div>
          <div className="ds-dg"><table>
            <thead><tr>
              <th className="orta">{cev('Gün')}</th><th className="orta">{cev('Paket')}</th>
              <th className="sag">{cev('Üretilen')}</th><th className="sag">{cev('Gönderilen')}</th>
              <th className="sag">{cev('Bekleyen')}</th><th className="sag">{cev('Hatalı')}</th>
              <th className="sag">{cev('Oran')}</th>
            </tr></thead>
            <tbody>
              {veri.oranlar.map((r, i) => (
                <tr key={i} className={r.oran < o.altSinir ? 'ds-kir' : ''}>
                  <td className="orta">{gunNokta(r.tarih)}</td>
                  <td className="orta"><b>{r.paketKodu}</b></td>
                  <td className="sag">{r.uretilen}</td>
                  <td className="sag">{r.gonderilen}</td>
                  <td className="sag">{r.bekleyen || ''}</td>
                  <td className="sag">{r.hatali || ''}</td>
                  <td className="sag">%{r.oran}</td>
                </tr>
              ))}
              {veri.oranlar.length === 0 && (
                <tr><td colSpan={7} className="sonuk">{cev('Bu aralıkta paket yok.')}</td></tr>
              )}
            </tbody>
          </table></div>
        </div>
      </div>

      {/* AY SONU (885): 408 aynı ölçütleri klinik (branş) kırılımıyla gönderir.
          Klinik kodu olmayan bölümün işi pakete GİRMEZ - uyarı burada. */}
      <div className="kagrup" style={{ margin: 10 }}>
        <div className="ds-gb">{cev('Ay sonu (408) — klinik kırılımlı')}
          {kodsuz.length > 0 && (
            <span className="rozet uyari" style={{ marginLeft: 6 }}>
              {kodsuz.length} {cev('bölümün SKRS klinik kodu yok')} —{' '}
              {cev('işleri ay sonu paketine girmiyor')}
            </span>
          )}
        </div>
        <div className="ds-dg"><table>
          <thead><tr>
            <th className="orta">{cev('Dönem')}</th><th className="orta">{cev('Klinik')}</th>
            <th className="orta">{cev('Satır')}</th><th className="orta">{cev('Paket')}</th>
            <th className="orta">{cev('Hesap')}</th>
          </tr></thead>
          <tbody>
            {aylar.map(a => (
              <>
                <tr key={a.id} onClick={() => void ayAc(a.id)} style={{ cursor: 'pointer' }}>
                  <td className="orta"><b>{String(a.ay).padStart(2, '0')}.{a.yil}</b></td>
                  <td className="orta">{a.klinik}</td>
                  <td className="orta">{a.satir}</td>
                  <td className="orta">
                    {a.paketNo
                      ? <span className={`rozet ${a.paketDurum === 3 ? 'ok' : 'uyari'}`}>{a.paketNo}</span>
                      : <span className="sonuk">—</span>}
                  </td>
                  <td className="orta sonuk">{tarihSaat(a.hesapZamani)}</td>
                </tr>
                {acikAy === a.id && (
                  <tr key={`${a.id}-d`}><td colSpan={5}>
                    <table className="ds-icon-tablo">
                      <thead><tr>
                        <th>{cev('Klinik')}</th><th>{cev('Ölçüt')}</th><th className="sag">{cev('Sayı')}</th>
                      </tr></thead>
                      <tbody>
                        {aySatir.map((r, i) => (
                          <tr key={i}>
                            <td>{r.klinikKodu} {r.klinik ? `· ${r.klinik}` : ''}</td>
                            <td>{r.ad}</td>
                            <td className="sag"><b>{r.sayi}</b></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </td></tr>
                )}
              </>
            ))}
            {aylar.length === 0 && (
              <tr><td colSpan={5} className="sonuk">{cev('Ay sonu kaydı yok.')}</td></tr>
            )}
          </tbody>
        </table></div>
      </div>
    </div>
  );
}
