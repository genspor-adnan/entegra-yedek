import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { BzbhBildirimi } from '../api/uclar/bzbh';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj, metinSor, onay } from '../bilesenler/mesaj';
import { gunNokta, tarihSaat } from '../bilesenler/bicim';
import { useOturum } from '../kimlik/OturumBaglami';
import { c as cev } from '../dil/ceviri';

/**
 * BZBH BİLDİRİM PANOSU (882 — KTS denetim maddesi H5).
 *
 * Enfeksiyon kontrol biriminin günlük ekranı. Muayenede bildirimi zorunlu
 * bir tanı konulduğunda burada BEKLEYEN bir satır belirir; vaka tipi ve
 * klinik belirti başlangıcı girilip "Bildir" denince **214 Bulaşıcı
 * Hastalık Bildirim** paketi üretilir ve e-Nabız kuyruğuna girer.
 *
 * <b>Gecikme en üstte.</b> Grup A'da süre tanıdan itibaren 24 saat ve
 * denetimde ilk sorulan şey gecikmedir; geciken satır kırmızı rozetle ve
 * listenin başında durur.
 *
 * <b>Vazgeçmek de bir karardır:</b> "tanı yanlıştı, bildirim gerekmiyor"
 * gerekçesiz kapatılamaz - denetimde "neden bildirilmedi" sorulur.
 */
const DURUM_ROZET: Record<number, string> = { 0: 'uyari', 1: 'ok', 2: 'gri' };

type Suzgec = 'bekleyen' | 'bildirilen' | 'tumu';

export function BzbhPanosu() {
  const { aksiyonVar } = useOturum();
  const [liste, setListe] = useState<BzbhBildirimi[]>([]);
  const [sayac, setSayac] = useState<{ bekleyen: number; geciken: number; bildirilen: number } | null>(null);
  const [tipler, setTipler] = useState<{ kod: number; ad: string }[]>([]);
  const [suzgec, setSuzgec] = useState<Suzgec>('bekleyen');
  const [hata, setHata] = useState<string | null>(null);
  const [taslak, setTaslak] = useState<Record<number, { vakaTipi: string; belirti: string }>>({});
  const bildirebilir = aksiyonVar('bzbh.bildir');

  const yukle = useCallback(async () => {
    try {
      const durum = suzgec === 'bekleyen' ? 0 : suzgec === 'bildirilen' ? 1 : undefined;
      const y = await api.bzbhPano(durum);
      setListe(y.bildirimler); setSayac(y.sayac); setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [suzgec]);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => { api.bzbhVakaTipleri().then(y => setTipler(y.tipler)).catch(() => setTipler([])) }, []);

  const alan = (b: BzbhBildirimi) => taslak[b.id] ?? {
    vakaTipi: b.vakaTipi ? String(b.vakaTipi) : '',
    belirti: b.belirtiTarihi ? String(b.belirtiTarihi).slice(0, 10) : '',
  };
  const yaz = (id: number, ek: Partial<{ vakaTipi: string; belirti: string }>) =>
    setTaslak(t => ({ ...t, [id]: { ...alan(liste.find(x => x.id === id)!), ...t[id], ...ek } }));

  const bildir = async (b: BzbhBildirimi) => {
    const a = alan(b);
    if (!a.vakaTipi) { mesaj('Vaka tipi seçin.'); return }
    if (!a.belirti) { mesaj('Klinik belirtilerin başladığı tarihi girin.'); return }
    if (!await onay(`${b.hasta} · ${b.hastalik} (${b.icdKod}) bildirilsin mi?\n\n`
                  + '214 Bulaşıcı Hastalık Bildirim paketi üretilir ve e-Nabız kuyruğuna girer.')) return;
    await guvenli(async () => {
      const y = await api.bzbhBildir(b.id, { vakaTipi: Number(a.vakaTipi), belirtiTarihi: a.belirti });
      mesaj(y.mesaj);
      await yukle();
    });
  };

  const vazgec = async (b: BzbhBildirimi) => {
    const gerekce = await metinSor(
      'Bildirimden vazgeçme gerekçesi (denetimde sorulur):', '', 'BZBH bildirimi');
    if (gerekce === null || gerekce.trim() === '') return;
    await guvenli(async () => { await api.bzbhVazgec(b.id, gerekce.trim()); await yukle() });
  };

  return (
    <div className="liste-sayfa">
      <div className="ds-arac">
        <b>🦠 {cev('Bildirimi Zorunlu Bulaşıcı Hastalık')}</b>
        {([['bekleyen', `Bekleyen (${sayac?.bekleyen ?? 0})`],
           ['bildirilen', `Bildirilen (${sayac?.bildirilen ?? 0})`],
           ['tumu', 'Tümü']] as [Suzgec, string][]).map(([k, ad]) => (
          <span key={k} className={`cip${suzgec === k ? ' on' : ''}`} onClick={() => setSuzgec(k)}>{ad}</span>
        ))}
        {(sayac?.geciken ?? 0) > 0 && (
          <span className="rozet hata">{sayac!.geciken} {cev('geciken bildirim')}</span>
        )}
        <span className="ds-sp sonuk">
          {cev('Tanı konulunca satır kendiliğinden açılır; vaka tipi ve belirti tarihi girilince 214 paketi üretilir.')}
        </span>
        <button className="d" onClick={() => void yukle()} title={cev('Yenile')}>⟳</button>
      </div>

      {hata && <div className="hata-kutusu" style={{ margin: 10 }}>{hata}</div>}

      <div className="ds-dg" style={{ margin: 10 }}><table>
        <thead><tr>
          <th className="orta">{cev('Tanı zamanı')}</th><th>Hasta</th>
          <th>{cev('Hastalık')}</th><th className="orta">ICD</th>
          <th className="orta">{cev('Grup')}</th>
          <th className="orta">{cev('Vaka tipi')}</th>
          <th className="orta">{cev('Belirti başlangıcı')}</th>
          <th className="orta">{cev('Durum')}</th><th className="orta">{cev('Paket')}</th><th />
        </tr></thead>
        <tbody>
          {liste.map(b => {
            const a = alan(b);
            const acik = b.durum === 0;
            return (
              <tr key={b.id} className={b.gecikti ? 'ds-kir' : ''}>
                <td className="orta">{b.taniZamani ? tarihSaat(b.taniZamani) : '—'}</td>
                <td>{b.hasta}<div className="sonuk">{b.hastaKimlik}</div></td>
                <td>{b.hastalik || <span className="sonuk">{b.icdAdi}</span>}
                  {b.gecikti && <span className="rozet hata" style={{ marginLeft: 4 }}>
                    {cev('gecikti')} ({b.sureSaat} {cev('saat')})</span>}</td>
                <td className="orta">{b.icdKod}</td>
                <td className="orta"><span className="rozet mavi">{b.grupAdi}</span></td>
                <td className="orta">
                  {acik && bildirebilir ? (
                    <select value={a.vakaTipi} onChange={e => yaz(b.id, { vakaTipi: e.target.value })}>
                      <option value="">{cev('Seçin…')}</option>
                      {tipler.map(t => <option key={t.kod} value={t.kod}>{t.ad}</option>)}
                    </select>
                  ) : (b.vakaTipiAdi || '—')}
                </td>
                <td className="orta">
                  {acik && bildirebilir ? (
                    <input type="date" value={a.belirti}
                           onChange={e => yaz(b.id, { belirti: e.target.value })} />
                  ) : (b.belirtiTarihi ? gunNokta(b.belirtiTarihi) : '—')}
                </td>
                <td className="orta">
                  <span className={`rozet ${DURUM_ROZET[b.durum] ?? 'gri'}`}>{b.durumAdi}</span>
                  {b.not_ ? <div className="sonuk">{b.not_}</div> : null}
                </td>
                <td className="orta sonuk">{b.paketNo || '—'}</td>
                <td className="orta ds-satir-arac">
                  {acik && bildirebilir && (
                    <button className="d onay" onClick={() => void bildir(b)}>📤 {cev('Bildir')}</button>
                  )}
                  {acik && bildirebilir && (
                    <button className="d" title={cev('Bildirim gerekmiyor')}
                            onClick={() => void vazgec(b)}>✕</button>
                  )}
                </td>
              </tr>
            );
          })}
          {liste.length === 0 && (
            <tr><td colSpan={10} className="sonuk">{cev('Kayıt yok.')}</td></tr>
          )}
        </tbody>
      </table></div>
    </div>
  );
}
