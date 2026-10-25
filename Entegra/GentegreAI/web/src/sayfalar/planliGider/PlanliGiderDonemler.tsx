import { useEffect, useState } from 'react';
import { hataMetni } from '../../api/sozlesme';
import { planliGiderUclari as u, type PlanliGiderDonemi, type PlanliGiderOnerisi } from '../../api/uclar/planliGider';
import { para, tutarOku } from '../../bilesenler/bicim';
import { mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { Modal } from '../../bilesenler/Modal';
import { DONEM_CIPLERI, type DonemCipi, ayUzun, donemCipSayisi, donemIslemleri, donemSuz, durumRozeti, gunT } from './planliGiderOrtak';

/**
 * DÖNEMLER SEKMESİ (mockup planli_gider_karti.html "Dönemler" + planli_gider.html eşleştirme önerisi).
 * Satırlar sunucunun takvimden TÜRETTİĞİ dönemlerdir; saklanan yalnız istisna (atla, bu dönem tutarı,
 * eşleşme). Her işlem sunucuya gider, ardından kart tazelenir (`onDegisti`) - ekran durum hesaplamaz.
 */
const tl = (n: number) => para.format(n);

export type DonemIslemi = 'esles' | 'atla' | 'tutar' | 'geriAl' | 'kaldir' | 'odeme';

/** Bir dönem işlemini çalıştırır (kart hızlı işlemleri de kullanır). true = kart tazelenmeli. */
export async function donemIslemiYap(id: number, d: PlanliGiderDonemi, is: Exclude<DonemIslemi, 'esles' | 'odeme'>, doviz: string) {
  const ad = ayUzun(d.vade);
  if (is === 'atla') {
    const not = await metinSor(`${ad} dönemi atlansın mı? Atlanan dönem nakit akışa yazılmaz.`, '', 'Açıklama (neden)');
    if (not == null) return false;
    await u.planliGiderAtla(id, d.vade, not);
  } else if (is === 'tutar') {
    const v = await metinSor(`${ad} döneminin tutarı (nakit çıkışı, ${doviz || 'TL'}). Boş bırakılırsa elle tutar kaldırılır.`,
                             d.elleTutar != null ? tl(d.elleTutar) : '', 'Tutar');
    if (v == null) return false;
    const tutar = v.trim() ? tutarOku(v) : null;
    if (tutar != null && !(tutar >= 0)) { mesaj('Geçerli bir tutar yazın.'); return false }
    await u.planliGiderDonemTutar(id, d.vade, tutar, '');
  } else if (is === 'geriAl') {
    if (!await onay(`${ad}: atlama / elle yazılan tutar geri alınsın mı?`)) return false;
    await u.planliGiderGeriAl(id, d.vade);
  } else if (is === 'kaldir') {
    if (!await onay(`${ad} dönemindeki eşleşme kaldırılsın mı? Kayıt silinmez; dönem yeniden "planlı / gecikti" sayılır.`)) return false;
    await u.planliGiderEslesmeKaldir(id, d.vade);
  }
  return true;
}

export function DonemlerSekmesi({ id, donemler, doviz, yazilabilir, odemeYetkisi, seciliVade, onSecVade, onDegisti, onOdeme, oneriIstegi }: {
  id: number; donemler: PlanliGiderDonemi[]; doviz: string; yazilabilir: boolean; odemeYetkisi: boolean;
  seciliVade: string | null; onSecVade(v: string | null): void;
  onDegisti(): void; onOdeme(vade: string): void;
  /** Artınca seçili dönemin öneri penceresi açılır (karttaki "Eşleştir" hızlı işlemi). */
  oneriIstegi: number;
}) {
  const [cip, setCip] = useState<DonemCipi>('yakin');
  const [oneri, setOneri] = useState<PlanliGiderDonemi | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const satirlar = donemSuz(donemler, cip);
  const secili = donemler.find(d => d.vade === seciliVade) ?? null;
  const izin = donemIslemleri(secili);

  useEffect(() => {
    if (!oneriIstegi) return;
    const d = donemler.find(x => x.vade === seciliVade);
    if (d) { setCip(c => (donemSuz(donemler, c).includes(d) ? c : 'tumu')); setOneri(d) }
  }, [oneriIstegi]);   // eslint-disable-line react-hooks/exhaustive-deps

  const calistir = async (is: Exclude<DonemIslemi, 'esles' | 'odeme'>) => {
    if (!secili) return;
    setMesgul(true);
    try { if (await donemIslemiYap(id, secili, is, doviz)) onDegisti() } catch (h) { mesaj(hataMetni(h)) } finally { setMesgul(false) }
  };
  const odenen = donemler.filter(d => d.eslesen).length;
  /** Sıradaki (ilk planlı / bugünkü) dönem satırı vurgulanır (mockup .grup). */
  const siradaki = donemler.find(d => d.durum === 'planli' || d.durum === 'bugun')?.vade;
  const gec = donemler.filter(d => d.durum === 'gec').length;

  return (
    <>
      <div className="pg-serit">
        {DONEM_CIPLERI.map(([k, ad]) => {
          const n = donemCipSayisi(donemler, k);
          return <span key={k} className={'pg-cip mavi' + (cip === k ? ' on' : '')} onClick={() => setCip(k)}>{ad}{n != null ? ` (${n})` : ''}</span>;
        })}
        <span className="pg-sp" />
        {yazilabilir && <>
          <button type="button" className="d pg-mini" disabled={!izin.esles || mesgul} onClick={() => secili && setOneri(secili)}>🔗 Eşleştir</button>
          <button type="button" className="d pg-mini" disabled={!izin.atla || mesgul} onClick={() => void calistir('atla')}>⏭ Atla</button>
          <button type="button" className="d pg-mini" disabled={!izin.tutar || mesgul} onClick={() => void calistir('tutar')}>✎ Tutar</button>
          <button type="button" className="d pg-mini" disabled={!izin.geriAl || mesgul} onClick={() => void calistir('geriAl')}>↶ Geri al</button>
          <button type="button" className="d pg-mini" disabled={!izin.kaldir || mesgul} onClick={() => void calistir('kaldir')}>✂ Eşleşmeyi kaldır</button>
        </>}
        {odemeYetkisi && <button type="button" className="d pg-mini" disabled={!izin.odeme || mesgul} onClick={() => secili && onOdeme(secili.vade)}>💳 Ödeme Oluştur</button>}
      </div>
      <div className="pg-liste" style={{ border: '1px solid var(--cizgi2)', borderRadius: 3, maxHeight: 520 }}>
        <table className="pg-dg">
          <thead><tr><th>Dönem</th><th>Plan tarihi</th><th className="pg-sag">Plan</th><th className="pg-sag">Gerçek</th><th className="pg-sag">Fark</th>
            <th>Ödeme</th><th>Eşleşen kayıt</th><th>Eşleşme</th><th>Durum</th></tr></thead>
          <tbody>
            {satirlar.map(d => {
              const r = durumRozeti(d.durum, d.gun);
              return (
                <tr key={d.vade} className={d.vade === seciliVade ? 'sec' : d.vade === siradaki ? 'grup' : ''}
                    onClick={() => onSecVade(d.vade)} onDoubleClick={() => { onSecVade(d.vade); if (yazilabilir && donemIslemleri(d).esles) setOneri(d) }}>
                  <td>{ayUzun(d.vade)}</td>
                  <td>{gunT(d.planTarihi)}{d.kaydirildi && <span className="pg-soluk"> · {d.kaydirmaNedeni}</span>}</td>
                  <td className="pg-sag">{tl(d.plan)}{d.elleTutar != null && <> <span className="pg-rz sari" title="Bu dönem için elle yazılan tutar">elle</span></>}
                    {d.dondurulmus && <span className="pg-soluk" title="Geçmiş dönem o günkü planıyla donduruldu"> ❄</span>}</td>
                  <td className="pg-sag">{d.gercek != null ? tl(d.gercek) : <span className="pg-soluk">—</span>}</td>
                  <td className={'pg-sag' + (d.fark ? (d.fark > 0 ? ' pg-borc' : ' pg-ok') : ' pg-soluk')}>{d.fark != null ? tl(d.fark) : '—'}</td>
                  <td>{d.odemeTarihi ? gunT(d.odemeTarihi) : '—'}</td>
                  <td>{d.eslesen ? `${d.eslesen.no}${d.eslesen.metin ? ` · ${d.eslesen.metin}` : ''}` : <span className="pg-soluk">—</span>}</td>
                  <td className="pg-soluk">{d.eslesen ? (d.otomatik ? 'otomatik' : 'elle') : '—'}</td>
                  <td><span className={'pg-rz ' + r.renk}>{r.ad}</span>{d.aciklama && <small>{d.aciklama}</small>}</td>
                </tr>
              );
            })}
            {satirlar.length === 0 && <tr><td colSpan={9} className="pg-bos">Bu süzgeçte dönem yok.</td></tr>}
          </tbody>
          <tfoot><tr><td colSpan={9}>{donemler.length} dönem · {odenen} eşleşti{gec ? ` · ${gec} geç ödendi` : ''}</td></tr></tfoot>
        </table>
      </div>
      <div className="pg-ipucu">Dönem satırları takvimden <b>türetilir</b>; yalnız istisnası saklanır (atlandı, bu dönem farklı tutar, eşleşen kayıt).
        Geçmiş dönemin planı sonradan tanım değişse de değişmez (o günkü tutar dönemle birlikte saklanır). Çift tık = eşleştirme önerileri.</div>
      {oneri && <OneriPenceresi id={id} donem={oneri} onKapat={() => setOneri(null)} onEslesti={() => { setOneri(null); onDegisti() }} />}
    </>
  );
}

/** EŞLEŞTİRME ÖNERİSİ: sunucunun adayları (kasa / banka ödemesi, alış faturası, işlenmemiş banka hareketi). */
function OneriPenceresi({ id, donem, onKapat, onEslesti }: { id: number; donem: PlanliGiderDonemi; onKapat(): void; onEslesti(): void }) {
  const [liste, setListe] = useState<PlanliGiderOnerisi[] | null>(null);
  const [hata, setHata] = useState('');
  const [secim, setSecim] = useState<string>('');
  const [mesgul, setMesgul] = useState(false);
  useEffect(() => {
    let iptal = false;
    u.planliGiderOneriler(id, donem.vade)
      .then(l => { if (!iptal) { setListe(l); const s = l.filter(x => x.secilebilir); if (s.length === 1) setSecim(`${s[0].tur}:${s[0].id}`) } })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [id, donem.vade]);
  const sec = liste?.find(x => `${x.tur}:${x.id}` === secim) ?? null;
  const esle = async () => {
    if (!sec) return;
    setMesgul(true);
    try { await u.planliGiderEsles(id, donem.vade, sec.tur, sec.id); onEslesti() } catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  };
  const r = durumRozeti(donem.durum, donem.gun);
  return (
    <Modal baslik={`🔗 Eşleştirme önerisi — ${ayUzun(donem.vade)}`} onKapat={onKapat} dar={false} enUst
           alt={<>
             <button type="button" className="d bir" disabled={!sec || mesgul} onClick={() => void esle()}>🔗 Eşleştir</button>
             <button type="button" className="d" onClick={onKapat}>Vazgeç</button>
           </>}>
      <div style={{ marginBottom: 8 }}>Plan {gunT(donem.planTarihi)} · {tl(donem.plan)} <span className={'pg-rz ' + r.renk}>{r.ad}</span></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <table className="pg-dg">
        <thead><tr><th /><th>Kayıt</th><th>Tarih</th><th>Cari</th><th>Masraf</th><th className="pg-sag">Tutar</th><th>Neden önerildi</th></tr></thead>
        <tbody>
          {liste == null && !hata && <tr><td colSpan={7} className="pg-bos">aranıyor…</td></tr>}
          {liste?.length === 0 && <tr><td colSpan={7} className="pg-bos">Plan tarihi ± tolerans ve tutar ± tolerans içinde aday kayıt yok.</td></tr>}
          {liste?.map(o => {
            const k = `${o.tur}:${o.id}`;
            return (
              <tr key={k} className={(secim === k ? 'sec' : '') + (o.secilebilir ? '' : ' pasif')}
                  onClick={() => o.secilebilir && setSecim(k)}>
                <td><input type="radio" checked={secim === k} disabled={!o.secilebilir} onChange={() => setSecim(k)} /></td>
                <td>{o.no}<small>{o.tur === 'fatura' ? 'Alış faturası' : o.tur === 'banka' ? 'Banka hareketi · işlenmemiş' : 'Kasa / banka ödemesi'}</small></td>
                <td>{gunT(o.tarih)}</td><td>{o.taraf || '—'}</td><td>{o.masraf || '—'}</td>
                <td className="pg-sag">{tl(o.tutar)}</td>
                <td>{o.secilebilir ? o.neden : <span className="pg-borc">{o.engel || o.neden}</span>}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
      <div className="pg-ipucu">Banka hareketi henüz işlenmemişse eşleşme "Banka Hareketleri" ekranında işlenince kesinleşir; o zamana kadar dönem
        <i> beklemede</i> sayılır ve nakit akışa çıkış olarak yazılmaz. Alış faturası eşleşirse dönem "faturalandı" olur, akışa faturanın vadesiyle girer.</div>
    </Modal>
  );
}
