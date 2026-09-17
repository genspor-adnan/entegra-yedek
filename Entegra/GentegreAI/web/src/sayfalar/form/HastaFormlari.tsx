import { useCallback, useEffect, useState } from 'react';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { HastaFormlari as Veri } from '../../api/uclar/form';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, listeSor, mesaj, onay } from '../../bilesenler/mesaj';

/**
 * HASTA FORMLARI `/hasta-formlar/:hastaId` (form motoru 740) — mockup
 * Ekranlar/Formlar/form_hasta_kartinda.html. Hastanın tüm formları (onam,
 * değerlendirme, beyan) bağlam gruplarıyla; buradan iç ekranda doldur, SMS
 * gönder, tablete ver (açık sayfa aynı tarayıcıda), aç, yeniden gönder.
 * Kapat: geldiği yere.
 */
const AILE: Record<number, [string, string]> = { 1: ['Onam', 'mor'], 2: ['Değerlendirme', 'mavi'], 3: ['Kontrol listesi', 'ok'], 4: ['Beyan', 'ok'], 5: ['Anket', 'uyari'] };
const DURUM: Record<number, string> = { 1: 'mor', 2: 'mor', 3: 'uyari', 4: 'ok', 5: 'hata', 6: 'hata', 7: 'hata', 8: 'hata' };

export function HastaFormlari() {
  const { hastaId: param } = useParams();
  const hastaId = Number(param ?? 0);
  const git = useNavigate();
  const konum = useLocation();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const geri = (konum.state as { geri?: string } | null)?.geri ?? sorgu.get('geri') ?? '/hasta';
  const kaynakTur = sorgu.get('kaynakTur') ? Number(sorgu.get('kaynakTur')) : undefined;
  const kaynakId = sorgu.get('kaynakId') ? Number(sorgu.get('kaynakId')) : undefined;
  const kapat = useCallback(() => git(geri), [git, geri]);
  useEffect(() => { const f = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() }; window.addEventListener('keydown', f); return () => window.removeEventListener('keydown', f) }, [kapat]);

  const [v, setV] = useState<Veri | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [suzgec, setSuzgec] = useState<'hepsi' | 'bekleyen' | 'tamam'>('hepsi');
  const yukle = useCallback(async () => {
    try { setV(await api.hastaFormlari(hastaId)); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, [hastaId]);
  useEffect(() => { void yukle() }, [yukle]);

  const buradanGeri = `/hasta-formlar/${hastaId}?geri=${encodeURIComponent(geri)}`;
  const sablonSec = async (baslik: string) => {
    if (!v) return null;
    const s = await listeSor(baslik, v.sablonlar.map(x => ({ kod: String(x.id), ad: `${x.ad} (${AILE[x.aile]?.[0] ?? ''})` })));
    return s ? v.sablonlar.find(x => String(x.id) === s) ?? null : null;
  };
  const icEkran = async () => {
    const s = await sablonSec('Hangi form doldurulacak?'); if (!s) return;
    await guvenli(async () => {
      const y = await api.formGonder({ sablonId: s.id, hastaId, kanal: 1, kaynakTur: kaynakTur ?? s.baglam, kaynakId });
      git(`/form-doldur/${y.id}?geri=${encodeURIComponent(buradanGeri)}`);
    });
  };
  const sms = async (kanal: 3 | 4) => {
    const s = await sablonSec(kanal === 3 ? 'SMS ile gönderilecek form' : 'E-posta ile gönderilecek form'); if (!s) return;
    if (!await onay(`${s.ad} formu ${kanal === 3 ? `${v?.hasta.cepTel || '(telefon yok)'} numarasına SMS` : `${v?.hasta.eposta || '(e-posta yok)'} adresine e-posta`} ile gönderilsin mi?`)) return;
    await guvenli(async () => { await api.formGonder({ sablonId: s.id, hastaId, kanal, kaynakTur: kaynakTur ?? s.baglam, kaynakId }); mesaj('Bağlantı kuyruğa alındı.'); await yukle() });
  };
  const tablet = async () => {
    const s = await sablonSec('Tablette / kioskta doldurulacak form'); if (!s) return;
    await guvenli(async () => {
      const y = await api.formGonder({ sablonId: s.id, hastaId, kanal: 2, kaynakTur: kaynakTur ?? s.baglam, kaynakId });
      // Aynı tarayıcıda açık sayfa: hasta kimlik doğrulaması + form; personel
      //   sekmeye döner. Yeni sekme - hasta uygulamayı görmesin.
      window.open(y.baglanti ?? `/f/${y.kod}`, '_blank', 'noopener');
      await yukle();
    });
  };

  const baslik = <>📋 Formlar — {v?.hasta.ad ?? ''}<span className="kapt">{v?.hasta.cepTel} · Esc ile kapanır</span></>;
  if (hata) return <Perde baslik={baslik} kapat={kapat}><div className="hata-kutusu">{hata}</div></Perde>;
  if (!v) return <Perde baslik={baslik} kapat={kapat}><span className="sonuk">Yükleniyor…</span></Perde>;

  const liste = v.istekler.filter(i => suzgec === 'hepsi' || (suzgec === 'bekleyen' ? i.durum < 4 : i.durum === 4));
  const gruplar = new Map<string, typeof liste>();
  for (const i of liste) { const k = `${i.kaynak_adi}${i.kaynak_id ? ` #${i.kaynak_id}` : ''}`; gruplar.set(k, [...(gruplar.get(k) ?? []), i]) }
  const eksikImza = v.istekler.filter(i => i.aile === 1 && i.durum < 4).length;
  return (
    <Perde baslik={baslik} kapat={kapat}>
      <div className="fm-doldur-arac">
        {yetki('form.gonder') && <>
          <button className="d bir" onClick={() => void icEkran()}>＋ Form doldur</button>
          <button className="d" onClick={() => void sms(3)}>📱 SMS ile gönder</button>
          <button className="d" onClick={() => void sms(4)}>✉️ E-posta</button>
          <button className="d" onClick={() => void tablet()}>🖥 Tablete ver</button>
        </>}
        <span className="sp" />
        <span className="sonuk">Göster:</span>
        {(['hepsi', 'bekleyen', 'tamam'] as const).map(s => <button key={s} className={`d${suzgec === s ? ' bir' : ''}`} onClick={() => setSuzgec(s)}>{s === 'hepsi' ? 'Tümü' : s === 'bekleyen' ? 'Bekleyen' : 'Tamamlanan'}</button>)}
      </div>
      <div className="fm-kpis">
        <div className="fm-kpi"><div className="b">Form</div><div className="d">{v.istekler.length}</div></div>
        <div className="fm-kpi"><div className="b">Tamamlanan</div><div className="d ok">{v.istekler.filter(i => i.durum === 4).length}</div></div>
        <div className="fm-kpi"><div className="b">Bekleyen</div><div className={`d${v.istekler.some(i => i.durum < 4) ? ' sari' : ''}`}>{v.istekler.filter(i => i.durum < 4).length}</div></div>
        <div className="fm-kpi"><div className="b">İmza eksik onam</div><div className={`d${eksikImza ? ' kir' : ''}`}>{eksikImza}</div></div>
      </div>
      {liste.length === 0 && <div className="sonuk" style={{ padding: 12 }}>Kayıt yok.</div>}
      {[...gruplar.entries()].map(([grup, satirlar]) => (
        <section key={grup} className="fm-bolum">
          <h3 className="fm-bolum-bas">{grup}</h3>
          <table className="fm-tablo">
            <thead><tr><th>Form</th><th>Aile</th><th>Kanal</th><th>Tarih</th><th>Dolduran</th><th>Skor / sonuç</th><th>İmza</th><th>Durum</th><th></th></tr></thead>
            <tbody>
              {satirlar.map(i => (
                <tr key={i.id}>
                  <td><b>{i.sablon_adi}</b></td>
                  <td><span className={`rozet ${AILE[i.aile]?.[1] ?? 'mor'}`}>{i.aile_adi}</span></td>
                  <td>{i.kanal_adi}</td>
                  <td>{new Date(i.tamamlanma ?? i.ekleme_tarihi).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' })}</td>
                  <td>{i.dolduran_adi || (i.durum === 4 ? 'Hasta' : '—')}</td>
                  <td>{i.skor != null ? <b>{i.skor}</b> : ''} {i.sonuc}</td>
                  <td>{i.imza_sayisi > 0 ? `✓ ${i.imza_sayisi}` : '—'}</td>
                  <td><span className={`rozet ${DURUM[i.durum] ?? 'mor'}`}>{i.durum_adi}{i.suresi_gecti ? ' (süresi geçti)' : ''}</span></td>
                  <td className="fm-sag">
                    <button className="d mini" onClick={() => git(`/form-doldur/${i.id}?geri=${encodeURIComponent(buradanGeri)}`)}>{i.durum === 4 ? 'Aç' : 'Doldur'}</button>
                    {yetki('form.gonder') && i.durum < 4 && (i.kanal === 3 || i.kanal === 4) && <button className="d mini" onClick={() => void guvenli(async () => { await api.formHatirlat(i.id); mesaj('Hatırlatma kuyruğa alındı.') })}>Hatırlat</button>}
                    {yetki('form.gonder') && (i.durum === 5 || i.durum === 6) && <button className="d mini" onClick={() => void guvenli(async () => { await api.formYeniden(i.id); mesaj('Yeni bağlantı gönderildi.'); await yukle() })}>Yeniden gönder</button>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      ))}
    </Perde>
  );
}

function Perde({ baslik, kapat, children }: { baslik: React.ReactNode; kapat: () => void; children: React.ReactNode }) {
  return (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">{baslik}<button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button></div>
        <div className="kagov fm-kagov">{children}</div>
      </div>
    </div>
  );
}
