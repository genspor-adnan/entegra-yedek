import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { EFaturaBilgiBaslik, EFaturaBilgiSatiri, EFaturaKodlari } from '../../api/uclar/efatura';
import { mesaj } from '../mesaj';

/**
 * e-FATURA BİLGİLERİ - fatura tipine / senaryoya göre GİB'in istediği ek bilgiler
 * (Delphi FATBASLIK.PLANID + FATBASLIK_USER + FATURA_USER.IHRACAT karşılığı;
 * kullanıcı 11.10.2026: "tüm tiplere göre olsun.. tevkifat, ihracat, ihraç
 * kayıtlı, kdv istisna vb"):
 *   - Tevkifatlı (22): tevkifat kodu (oran koddan)
 *   - KDV İstisna (24) ve KDV'si sıfır kalem: istisna nedeni
 *   - İhraç Kayıtlı (9): 701-704
 *   - İhracat senaryosu (3): navlun / sigorta + kalem başına GTİP, teslim şartı,
 *     taşıma şekli, kap cinsi / no / adet
 *   - SGK (25): ilave tip, mükellef kodu / adı, dosya no, dönem
 *   - Kamu senaryosu (7): ödeme IBAN'ı
 * Bölüm yalnız gerekiyorsa açılır; Hazırla eksikleri zaten tek mesajda söyler.
 */
export function EFaturaBilgileri({ belgeId, tipi, senaryo, kilitli }: {
  belgeId: number; tipi: number; senaryo: number; kilitli: boolean;
}) {
  const [kodlar, setKodlar] = useState<EFaturaKodlari | null>(null);
  const [b, setB] = useState<EFaturaBilgiBaslik | null>(null);
  const [satirlar, setSatirlar] = useState<EFaturaBilgiSatiri[]>([]);
  const [degisti, setDegisti] = useState(false);
  const [hata, setHata] = useState('');

  useEffect(() => { api.efaturaKodlari().then(setKodlar).catch(h => setHata(hataMetni(h))) }, []);
  useEffect(() => {
    if (!belgeId) return;
    api.efaturaBilgi(belgeId).then(y => { setB(y.baslik); setSatirlar(y.satirlar); setDegisti(false) })
      .catch(h => setHata(hataMetni(h)));
  }, [belgeId]);

  const ihracat = senaryo === 3 || tipi === 26, kamu = senaryo === 7;
  const tevkifat = tipi === 22, istisna = tipi === 24, ihracKayitli = tipi === 9, sgk = tipi === 25;
  const sifirKdv = satirlar.some(s => Number(s.kdv) === 0);
  if (!belgeId) return <div className="not">e-Fatura bilgileri belge kaydedilince girilir.</div>;
  if (!(ihracat || kamu || tevkifat || istisna || ihracKayitli || sgk || sifirKdv)) return null;
  if (!b || !kodlar) return hata ? <div className="hata-kutusu">{hata}</div> : null;

  // HAZIR / GONDERILMIS e-Fatura degismez (kullanici 11.10.2026).
  const kapali = kilitli || b.efaturaDurum > 0;
  const ata = <K extends keyof EFaturaBilgiBaslik>(k: K, v: EFaturaBilgiBaslik[K]) => { setB({ ...b, [k]: v }); setDegisti(true) };
  const satirAta = (i: number, k: keyof EFaturaBilgiSatiri, v: string | number) => {
    setSatirlar(satirlar.map((s, j) => (j === i ? { ...s, [k]: v } : s))); setDegisti(true);
  };
  const kaydet = async () => {
    try {
      const y = await api.efaturaBilgiKaydet(belgeId, { baslik: b, satirlar });
      mesaj(y.mesaj); setDegisti(false);
    } catch (h) { mesaj(hataMetni(h)) }
  };
  const istisnaListe = ihracKayitli ? kodlar.ihracKayitli : kodlar.istisna;

  return (
    <div className="efb">
      <h6>e-Fatura Bilgileri <span className="kapt">fatura tipine / senaryoya göre GİB'in istediği alanlar</span>
        {!kapali && <button type="button" className="d bir" disabled={!degisti} onClick={() => void kaydet()}>💾 Kaydet</button>}
      </h6>
      <div className="alan-izgara tek-sutun">
        {tevkifat && (
          <label className="alan genis-2"><span className="etiket">Tevkifat Kodu</span>
            <select value={b.tevkifatKodu} disabled={kapali} onChange={e => ata('tevkifatKodu', Number(e.target.value))}>
              <option value={0}>— seçin —</option>
              {kodlar.tevkifat.map(k => <option key={k.deger} value={k.deger}>{k.ad}</option>)}
            </select></label>
        )}
        {(istisna || ihracKayitli || sifirKdv || ihracat) && (
          <label className="alan genis-2">
            <span className="etiket">{ihracKayitli ? 'İhraç Kayıtlı Kodu' : 'KDV İstisna Nedeni'}</span>
            <select value={b.istisnaKodu} disabled={kapali} onChange={e => ata('istisnaKodu', Number(e.target.value))}>
              <option value={0}>{ihracat ? '301 - Mal ihracatı (varsayılan)' : '— seçin —'}</option>
              {istisnaListe.map(k => <option key={k.deger} value={k.deger}>{k.ad}</option>)}
            </select></label>
        )}
        {kamu && (
          <label className="alan genis-2"><span className="etiket">Ödeme IBAN'ı</span>
            <select value={b.kamuHesapId ?? 0} disabled={kapali} onChange={e => ata('kamuHesapId', Number(e.target.value) || null)}>
              <option value={0}>— seçin —</option>
              {kodlar.hesaplar.map(h => <option key={h.id} value={h.id}>{h.ad} · {h.iban}</option>)}
            </select></label>
        )}
        {sgk && (<>
          <label className="alan"><span className="etiket">SGK İlave Tipi</span>
            <select value={b.sgkTip} disabled={kapali} onChange={e => ata('sgkTip', e.target.value)}>
              <option value="">— seçin —</option>
              {kodlar.sgkTipleri.map(k => <option key={k.kod} value={k.kod}>{k.ad}</option>)}
            </select></label>
          <label className="alan"><span className="etiket">Mükellef Kodu</span>
            <input value={b.sgkMukellefKod} disabled={kapali} onChange={e => ata('sgkMukellefKod', e.target.value)} /></label>
          <label className="alan"><span className="etiket">Mükellef Adı</span>
            <input value={b.sgkMukellefAd} disabled={kapali} onChange={e => ata('sgkMukellefAd', e.target.value)} /></label>
          <label className="alan"><span className="etiket">Dosya No</span>
            <input value={b.sgkDosyaNo} disabled={kapali} onChange={e => ata('sgkDosyaNo', e.target.value)} /></label>
          <label className="alan"><span className="etiket">Dönem</span>
            <span className="deger-serit">
              <input type="date" value={(b.sgkDonemBas ?? '').slice(0, 10)} disabled={kapali} onChange={e => ata('sgkDonemBas', e.target.value)} />
              –
              <input type="date" value={(b.sgkDonemBit ?? '').slice(0, 10)} disabled={kapali} onChange={e => ata('sgkDonemBit', e.target.value)} />
            </span></label>
        </>)}
        {ihracat && (<>
          <label className="alan"><span className="etiket">Navlun</span>
            <input type="number" step="0.01" value={b.navlun} disabled={kapali} onChange={e => ata('navlun', Number(e.target.value))} /></label>
          <label className="alan"><span className="etiket">Sigorta</span>
            <input type="number" step="0.01" value={b.sigorta} disabled={kapali} onChange={e => ata('sigorta', Number(e.target.value))} /></label>
        </>)}
      </div>
      {ihracat && (
        <table className="detay-tablo efb-ihr">
          <thead><tr><th>Kalem</th><th style={{ width: 130 }}>GTİP (12)</th><th style={{ width: 170 }}>Teslim Şartı</th>
            <th style={{ width: 150 }}>Taşıma Şekli</th><th style={{ width: 140 }}>Kap Cinsi</th><th style={{ width: 100 }}>Kap No</th>
            <th style={{ width: 80 }}>Kap Adet</th></tr></thead>
          <tbody>
            {satirlar.map((s, i) => (
              <tr key={s.satirId}>
                <td>{s.ad}</td>
                <td><input value={s.gtip} maxLength={12} disabled={kapali} onChange={e => satirAta(i, 'gtip', e.target.value.replace(/\D/g, ''))} /></td>
                <td><select value={s.teslimSarti} disabled={kapali} onChange={e => satirAta(i, 'teslimSarti', e.target.value)}>
                  <option value="">—</option>{kodlar.teslimSartlari.map(k => <option key={k.kod} value={k.kod}>{k.ad}</option>)}</select></td>
                <td><select value={s.tasimaSekli} disabled={kapali} onChange={e => satirAta(i, 'tasimaSekli', Number(e.target.value))}>
                  <option value={0}>—</option>{kodlar.tasimaSekilleri.map(k => <option key={k.deger} value={k.deger}>{k.ad}</option>)}</select></td>
                <td><select value={s.kapCinsi} disabled={kapali} onChange={e => satirAta(i, 'kapCinsi', e.target.value)}>
                  <option value="">—</option>{kodlar.kapCinsleri.map(k => <option key={k.kod} value={k.kod}>{k.ad}</option>)}</select></td>
                <td><input value={s.kapNo} disabled={kapali} onChange={e => satirAta(i, 'kapNo', e.target.value)} /></td>
                <td><input type="number" value={s.kapAdet} disabled={kapali} onChange={e => satirAta(i, 'kapAdet', Number(e.target.value))} /></td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      <style>{`.efb { margin-top: 10px; border-top: 1px solid var(--cizgi); padding-top: 6px; }
.efb h6 .d { margin-left: auto; }
.efb-ihr input, .efb-ihr select { width: 100%; }`}</style>
    </div>
  );
}
