import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { IzlemYaniti } from '../../api/uclar/yatan';
import { guvenli, mesaj, metinSor } from '../mesaj';
import { tarihSaat } from '../bicim';
import { VitalEgrisi } from './VitalEgrisi';

/**
 * HEMŞİRE İZLEM — mockup `Ekranlar/Yatan/hemsire_izlem.html`.
 *
 * <b>Nöbet ekranı:</b> ölçüm girişi, eğri, aldığı-çıkardığı ve risk ölçekleri
 * aynı yerde. Dördü ayrı ekrana bölünseydi hemşire her ölçümde dört kez
 * gezinir ve kayıt nöbet sonunda toplu yazılırdı — saatinde yazılmayan izlem,
 * izlem değildir.
 *
 * <b>Hızlı giriş tek satır:</b> ölçüm kartı açıp kapatmak, dört saatte bir
 * tekrarlanan bir iş için fazla. Alanlar boş bırakılabilir — ölçülmeyen
 * parametre yazılmaz, sıfır yazılmaz.
 *
 * <b>Erken uyarı skorunu SUNUCU hesaplar</b> (699): eşik aşılınca ekran
 * "hekime bildir" der ve bildirim ölçümün satırına yazılır. "Acaba arasam mı"
 * kararı kişiye bırakılmaz.
 */

const SEKMELER = [
  { kod: 'vital',  ad: 'Vital Eğrisi' },
  { kod: 'sivi',   ad: 'Aldığı–Çıkardığı' },
  { kod: 'risk',   ad: 'Risk Ölçekleri' },
  { kod: 'gozlem', ad: 'Gözlem Notları' },
] as const;

const SIVI_TUR: Record<number, string> = {
  1: 'Oral', 2: 'IV', 3: 'Kan ürünü', 4: 'İdrar', 5: 'Drenaj', 6: 'Kusma', 7: 'Gaita',
};
const OLCEK: Record<number, string> = {
  1: 'İtaki düşme riski', 2: 'Braden bası yarası',
  3: 'NRS-2002 beslenme', 4: 'Glasgow koma skalası',
};
const DUZEY: Record<number, string> = { 1: 'Düşük', 2: 'Orta', 3: 'Yüksek' };

/** Değerlendirme kaç saat sonra "süresi geçti" sayılır (yatış kartıyla aynı). */
const TAZELIK_SAAT = 24;

interface YatisSecenegi { id: number; hasta: string; yatak: string }

const sayi = (m: string) => {
  const t = m.trim();
  if (!t) return null;
  const d = Number(t.replace(',', '.'));
  return Number.isFinite(d) ? d : null;
};

export function HemsireIzlem({ yenile, onDegisti }: {
  yenile?: number;
  onDegisti?(): void;
}) {
  const [yatislar, setYatislar] = useState<YatisSecenegi[]>([]);
  const [yatisId, setYatisId] = useState<number | null>(null);
  const [sekme, setSekme] = useState<string>('vital');
  const [veri, setVeri] = useState<IzlemYaniti | null>(null);

  // Hızlı ölçüm girişi (mockup `.giris` şeridi).
  const [ta1, setTa1] = useState(''); const [ta2, setTa2] = useState('');
  const [nabiz, setNabiz] = useState(''); const [ates, setAtes] = useState('');
  const [spo2, setSpo2] = useState(''); const [solunum, setSolunum] = useState('');
  const [agri, setAgri] = useState(''); const [gks, setGks] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);

  useEffect(() => {
    void (async () => {
      try {
        const y = await api.liste('yatan', {
          sayfa: 1, boyut: 200,
          filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3] },
        });
        const s = y.satirlar.map(r => ({
          id: Number(r.id), hasta: String(r.hasta ?? ''), yatak: String(r.yatak ?? ''),
        }));
        setYatislar(s);
        setYatisId(o => o ?? (s[0]?.id ?? null));
      } catch { /* liste yoksa panel de yok */ }
    })();
  }, []);

  const yukle = useCallback(async () => {
    if (!yatisId) { setVeri(null); return }
    try { setVeri(await api.izlem(yatisId, 48)) } catch { setVeri(null) }
  }, [yatisId]);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  if (yatislar.length === 0) return null;

  const kaydet = async () => {
    if (!yatisId) return;
    setKaydediyor(true);
    try {
      const y = await api.izlemKaydet({
        yatisId,
        sistolik: sayi(ta1), diyastolik: sayi(ta2),
        nabiz: sayi(nabiz), ates: sayi(ates), spo2: sayi(spo2),
        solunum: sayi(solunum), agriVas: sayi(agri), gks: sayi(gks),
      });
      // EŞİK AŞILDIYSA EKRAN SÖYLER: bildirimi hemşire yapar, ama sessiz
      //   kalınmaz.
      mesaj(y.bildirimGerek
        ? `Ölçüm kaydedildi — erken uyarı ${y.erkenUyari}. HEKİME BİLDİRİN.`
        : `Ölçüm kaydedildi${y.erkenUyari != null ? ` — erken uyarı ${y.erkenUyari}` : ''}.`);
      setTa1(''); setTa2(''); setNabiz(''); setAtes('');
      setSpo2(''); setSolunum(''); setAgri(''); setGks('');
      await yukle();
      onDegisti?.();
    } catch (h) { mesaj(String((h as Error).message ?? h)) }
    finally { setKaydediyor(false) }
  };

  const siviGir = async (yon: number) => {
    if (!yatisId) return;
    const m = await metinSor(
      yon === 1 ? 'Aldığı sıvı (mL) — örn. 500' : 'Çıkardığı sıvı (mL) — örn. 450', '');
    const miktar = sayi(m ?? '');
    if (!miktar) return;
    await guvenli(async () => {
      await api.siviKaydet({ yatisId, yon, tur: yon === 1 ? 2 : 4, miktarMl: miktar });
      mesaj('Sıvı kaydedildi — denge yeniden hesaplandı.');
      await yukle();
      onDegisti?.();
    });
  };

  const gozlemEkle = async () => {
    if (!yatisId) return;
    const m = await metinSor('Gözlem notu', '');
    if (!m?.trim()) return;
    await guvenli(async () => {
      await api.gozlemKaydet(yatisId, m.trim());
      mesaj('Gözlem kaydedildi.');
      await yukle();
      onDegisti?.();
    });
  };

  const bildir = async (id: number) => {
    await guvenli(async () => {
      await api.izlemBildirildi(id);
      mesaj('Hekime bildirim kaydı yazıldı.');
      await yukle();
      onDegisti?.();
    });
  };

  const son = veri?.vitaller?.[veri.vitaller.length - 1];
  const d = veri?.denge;

  return (
    <div className="izlem-pano">
      <div className="emar-serit">
        <label>Hasta
          <select value={yatisId ?? ''} onChange={e => setYatisId(Number(e.target.value))}>
            {yatislar.map(y => (
              <option key={y.id} value={y.id}>{y.yatak ? `${y.yatak} · ` : ''}{y.hasta}</option>
            ))}
          </select>
        </label>
        <button className="d" onClick={() => void siviGir(1)}>💧 Aldığı</button>
        <button className="d" onClick={() => void siviGir(2)}>🚻 Çıkardığı</button>
        <button className="d" onClick={() => void gozlemEkle()}>📝 Gözlem Notu</button>
        {son && (
          <div className="emar-ozet">
            <span>son ölçüm <b>{tarihSaat(son.zaman)}</b></span>
            <span className={son.erkenUyari != null && son.erkenUyari >= 5 ? 'teh'
                             : son.erkenUyari != null && son.erkenUyari >= 3 ? 'uy' : ''}>
              erken uyarı <b>{son.erkenUyari ?? '—'}</b>
            </span>
            {son.erkenUyari != null && son.erkenUyari >= 5 && !son.bildirimZamani && (
              <button className="d ret" onClick={() => void bildir(son.id)}>
                🔔 Hekime Bildirildi
              </button>
            )}
          </div>
        )}
      </div>

      {/* HIZLI ÖLÇÜM GİRİŞİ: boş alan yazılmaz - ölçülmeyen parametre sıfır
          değildir ve skora da katılmaz (699). */}
      <div className="izlem-giris">
        <label>Sistolik<input value={ta1} onChange={e => setTa1(e.target.value)} /></label>
        <label>Diyastolik<input value={ta2} onChange={e => setTa2(e.target.value)} /></label>
        <label>Nabız<input value={nabiz} onChange={e => setNabiz(e.target.value)} /></label>
        <label>Ateş °C<input value={ates} onChange={e => setAtes(e.target.value)} /></label>
        <label>SpO₂ %<input value={spo2} onChange={e => setSpo2(e.target.value)} /></label>
        <label>Solunum<input value={solunum} onChange={e => setSolunum(e.target.value)} /></label>
        <label>Ağrı 0-10<input value={agri} onChange={e => setAgri(e.target.value)} /></label>
        <label>GKS<input value={gks} onChange={e => setGks(e.target.value)} /></label>
        <button className="d onay" disabled={kaydediyor} onClick={() => void kaydet()}>
          ✔ Ölçümü Kaydet
        </button>
      </div>

      <div className="altpanel-sekmeler">
        {SEKMELER.map(s => (
          <button key={s.kod} className={`altpanel-sekme${sekme === s.kod ? ' on' : ''}`}
                  onClick={() => setSekme(s.kod)}>
            {s.ad}
            {s.kod === 'risk' && veri?.riskler.some(r => r.saatOnce > TAZELIK_SAAT) && (
              <span className="rozet sari">süresi geçen var</span>
            )}
          </button>
        ))}
      </div>

      <div className="izlem-govde">
        {sekme === 'vital' && veri && (
          <>
            <VitalEgrisi vitaller={veri.vitaller} />
            <table className="izlem-tablo">
              <thead>
                <tr><th>Zaman</th><th>TA</th><th>Nabız</th><th>Ateş</th><th>SpO₂</th>
                    <th>Solunum</th><th>Ağrı</th><th>Erken uyarı</th><th>Ölçen</th></tr>
              </thead>
              <tbody>
                {[...veri.vitaller].reverse().map(v => (
                  <tr key={v.id} className={v.erkenUyari != null && v.erkenUyari >= 5
                                            ? 'satir-kritik' : ''}>
                    <td>{tarihSaat(v.zaman)}</td>
                    <td>{v.sistolik != null ? `${v.sistolik}/${v.diyastolik ?? '—'}` : '—'}</td>
                    <td>{v.nabiz ?? '—'}</td>
                    <td>{v.ates != null ? Number(v.ates).toFixed(1) : '—'}</td>
                    <td>{v.spo2 ?? '—'}</td>
                    <td>{v.solunum ?? '—'}</td>
                    <td>{v.agriVas ?? '—'}</td>
                    <td>
                      {v.erkenUyari != null && (
                        <span className={`rozet ${v.erkenUyari >= 5 ? 'hata'
                                                  : v.erkenUyari >= 3 ? 'sari' : 'ok'}`}>
                          {v.erkenUyari}
                        </span>
                      )}
                      {v.bildirimZamani && <span className="sonuk"> · bildirildi</span>}
                    </td>
                    <td className="sonuk">{v.olcen || '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </>
        )}

        {sekme === 'sivi' && veri && d && (
          <>
            <div className="izlem-skor">
              <div className="k"><span>ALDIĞI (24 sa)</span><b>{Math.round(d.aldi)} mL</b></div>
              <div className="k"><span>ÇIKARDIĞI (24 sa)</span><b>{Math.round(d.cikardi)} mL</b></div>
              <div className={`k ${Math.abs(d.fark) > 500 ? 'uy' : ''}`}>
                <span>DENGE</span>
                <b>{d.fark > 0 ? '+' : ''}{Math.round(d.fark)} mL</b>
                <i>hedef ±500 mL</i>
              </div>
              <div className="k">
                <span>İDRAR</span>
                {/* KİLO ÖLÇÜMÜ YOKSA ORAN DA YOK: varsayılan kiloyla hesaplamak,
                    olmayan bir ölçümü varmış gibi gösterirdi. */}
                <b>{d.idrarOrani != null ? `${d.idrarOrani} mL/kg/sa` : `${Math.round(d.idrar)} mL`}</b>
                <i>{d.kilo != null ? `${d.kilo} kg` : 'kilo ölçümü yok'}</i>
              </div>
            </div>
            <table className="izlem-tablo">
              <thead><tr><th>Zaman</th><th>Yön</th><th>Tür</th><th>Miktar</th><th>Kaydeden</th></tr></thead>
              <tbody>
                {veri.sivilar.length === 0 && (
                  <tr><td colSpan={5} className="sonuk">Bu pencerede sıvı kaydı yok.</td></tr>
                )}
                {veri.sivilar.map(s => (
                  <tr key={s.id}>
                    <td>{tarihSaat(s.zaman)}</td>
                    <td><span className={`rozet ${s.yon === 1 ? 'mavi' : ''}`}>
                      {s.yon === 1 ? 'Aldı' : 'Çıkardı'}</span></td>
                    <td>{s.turAd || SIVI_TUR[s.tur] || '—'}{s.aciklama && ` · ${s.aciklama}`}</td>
                    <td>{Math.round(s.miktarMl)} mL</td>
                    <td className="sonuk">{s.kaydeden || '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <div className="not">
              Denge <b>hesaplanır, yazılmaz</b>: gün ortasında eklenen bir serum, elle
              tutulan toplamı sessizce yanlışlar. Kalp yetmezliği ve böbrek hastasında
              "+450" ile "+1.450" arasındaki fark tedavi değiştirir.
            </div>
          </>
        )}

        {sekme === 'risk' && veri && (
          <>
            <table className="izlem-tablo">
              <thead><tr><th>Tarih</th><th>Ölçek</th><th>Puan</th><th>Risk</th>
                         <th>Alınan önlem</th><th>Değerlendiren</th></tr></thead>
              <tbody>
                {veri.riskler.length === 0 && (
                  <tr><td colSpan={6} className="sonuk">
                    Değerlendirme yok — yatışta doldurulmalı.</td></tr>
                )}
                {veri.riskler.map(r => (
                  <tr key={r.id}>
                    <td>{tarihSaat(r.zaman)}
                      {r.saatOnce > TAZELIK_SAAT && (
                        <span className="rozet sari"> süresi geçti</span>
                      )}
                    </td>
                    <td>{r.olcekAd || OLCEK[r.olcek] || '—'}</td>
                    <td>{r.puan ?? '—'}</td>
                    <td>{r.duzey != null && (
                      <span className={`rozet ${r.duzey === 3 ? 'hata'
                                                : r.duzey === 2 ? 'sari' : 'ok'}`}>
                        {DUZEY[r.duzey]}
                      </span>)}
                    </td>
                    <td>{r.onlem || <span className="rozet hata">önlem yazılmamış</span>}</td>
                    <td className="sonuk">{r.degerlendiren || '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <div className="not">
              <b>Puan tek başına kayıt değildir; alınan önlem de satırda durur.</b>
              Değerlendirme yatışta, her 24 saatte ve durum değişiminde yenilenir —
              süresi geçen ölçek sararır ki üçüncü günü düşen hastanın puanı hâlâ yatış
              günündeki puan olmasın.
            </div>
          </>
        )}

        {sekme === 'gozlem' && veri && (
          <>
            <table className="izlem-tablo">
              <thead><tr><th style={{ width: 130 }}>Zaman</th><th>Gözlem</th>
                         <th style={{ width: 160 }}>Kaydeden</th></tr></thead>
              <tbody>
                {veri.gozlemler.length === 0 && (
                  <tr><td colSpan={3} className="sonuk">Gözlem notu yok.</td></tr>
                )}
                {veri.gozlemler.map(g => (
                  <tr key={g.id}>
                    <td>{tarihSaat(g.zaman)}</td>
                    <td>{g.not_}</td>
                    <td className="sonuk">{g.olcen || '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <div className="not">
              Gözlem notu <b>silinmez, düzeltilmez</b>: yanlış yazılan not yeni bir satırla
              düzeltilir ve ikisi de durur. Hemşire gözlemi hukuki bir kayıttır — üzerine
              yazılabilseydi değeri kalmazdı.
            </div>
          </>
        )}
      </div>
    </div>
  );
}
