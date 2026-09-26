import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { guvenli, mesaj } from '../bilesenler/mesaj';

/**
 * RADYOLOJİ İSTEM KARTI (283) — mockup Ekranlar/Radyoloji/radyoloji_istem_karti.html.
 *
 * Generic karta sığmaz: kimlik şeridi + 6 adımlı AKIŞ ŞERİDİ + İstem Bilgisi /
 * Çekim-Görüntü / Kontrol Listesi grupları + özet. İstem başvurunun radyoloji
 * satırından doğar; ücret ve ödeyen kurum oradan gelir, burada tekrar sorulmaz.
 */
type Sozluk = Record<string, unknown>;
const M = (o: Sozluk | null, k: string) => (o && o[k] != null ? String(o[k]) : '');
const N = (o: Sozluk | null, k: string) => (o && o[k] != null ? Number(o[k]) : 0);
const zaman = (v: unknown) => v ? new Date(String(v)).toLocaleString('tr-TR',
  { dateStyle: 'short', timeStyle: 'short' }) : '';
const gun = (v: unknown) => v ? new Date(String(v)).toLocaleDateString('tr-TR') : '';

const DURUM_RENK: Record<number, string> = { 0: 'kir', 1: 'pas', 2: 'mavi', 3: 'sari', 4: 'sari', 5: 'ok', 6: 'ok' };

export function RadyolojiIstemKarti() {
  const { id } = useParams();
  const git = useNavigate();
  const { yetki } = useOturum();
  const istemId = Number(id);
  const [k, setK] = useState<Sozluk | null>(null);
  const [akis, setAkis] = useState<Sozluk | null>(null);
  const [kontrol, setKontrol] = useState<{ soru: string; yanit: string; kaydeden: string; kayitZamani: string | null }[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [duzen, setDuzen] = useState(false);
  type Form = { klinikBilgi: string; onTani: string; oncelik: number; kontrast: number; kontrastMl: string; seriSayisi: string; goruntuSayisi: string };
  const [form, setForm] = useState<Form | null>(null);
  const formAl = (o: Sozluk): Form => ({
    klinikBilgi: M(o, 'klinikBilgi'), onTani: M(o, 'onTani'), oncelik: N(o, 'oncelik') || 1,
    kontrast: N(o, 'kontrast'), kontrastMl: N(o, 'kontrastMl') ? M(o, 'kontrastMl') : '',
    seriSayisi: N(o, 'seriSayisi') ? M(o, 'seriSayisi') : '', goruntuSayisi: N(o, 'goruntuSayisi') ? M(o, 'goruntuSayisi') : '',
  });
  const fs = (p: Partial<Form>) => setForm(f => f ? { ...f, ...p } : f);

  const yukle = useCallback(async () => {
    if (!istemId) return;
    try {
      setHata(null);
      const kd = await api.radyolojiKartDetay(istemId);
      setK(kd); setForm(formAl(kd));
      setAkis(await api.radyolojiAkis(istemId));
      const kn = await api.radyolojiKontrol(istemId);
      setKontrol((kn.sorular ?? []).map(s => ({
        soru: String(s.soru ?? ''), yanit: String(s.yanit ?? ''),
        kaydeden: String(s.kaydeden ?? ''), kayitZamani: s.kayitZamani ? String(s.kayitZamani) : null })));
    } catch (h) { setHata(hataMetni(h)) }
  }, [istemId]);
  useEffect(() => { void yukle() }, [yukle]);

  const durum = N(k, 'durum');
  // Akış adımları: done (tamam) / simdi (şu an) / boş.
  const adimlar = [
    { ad: 'İstem', t: akis?.['istemZamani'], tamam: true },
    { ad: 'Randevu', t: akis?.['randevuZamani'], tamam: !!akis?.['randevuZamani'] },
    { ad: 'Çekim', t: akis?.['cekimZamani'], tamam: durum >= 2 },
    { ad: 'Raporlanıyor', t: akis?.['raporZamani'], tamam: durum >= 3 },
    { ad: 'Onay', t: akis?.['onayZamani'], tamam: durum >= 5 },
    { ad: 'Teslim', t: akis?.['teslimZamani'], tamam: durum >= 6 },
  ];
  const simdiIdx = adimlar.findIndex(a => !a.tamam);

  const kaydet = async () => {
    if (!form) return;
    await guvenli(async () => {
      await api.radyolojiIstemGuncelle(istemId, {
        klinikBilgi: form.klinikBilgi, onTani: form.onTani, oncelik: form.oncelik,
        kontrast: form.kontrast,
        kontrastMl: form.kontrastMl ? Number(form.kontrastMl.replace(',', '.')) : null,
        seriSayisi: form.seriSayisi ? Number(form.seriSayisi) : null,
        goruntuSayisi: form.goruntuSayisi ? Number(form.goruntuSayisi) : null,
      });
      mesaj('İstem güncellendi.');
      setDuzen(false);
      await yukle();
    });
  };

  // Düzenlenebilir alan: düzen kapalıysa okunur kutu, açıksa girdi.
  const duzAlan = (etiket: string, gorunum: string, giris: React.ReactNode, tam = false) => (
    <div className="al" style={tam ? { gridColumn: '1 / -1' } : undefined}>
      <span className="lb">{etiket}</span>
      {duzen ? giris : <div className="inp" style={{ background: '#f7f8fa', minHeight: 30, padding: '5px 8px', whiteSpace: tam ? 'normal' : 'nowrap', height: 'auto' }}>{gorunum || '—'}</div>}
    </div>
  );

  const alan = (etiket: string, deger: string, tam = false) => (
    <div className="al" style={tam ? { gridColumn: '1 / -1' } : undefined}>
      <span className="lb">{etiket}</span>
      <div className="inp" style={{ background: '#f7f8fa', minHeight: 30, padding: '5px 8px',
        whiteSpace: tam ? 'normal' : 'nowrap', height: 'auto' }}>{deger || '—'}</div>
    </div>
  );

  const grup = (baslik: string, cocuk: React.ReactNode, ekBaslik?: React.ReactNode) => (
    <section className="fm-bolum" style={{ marginTop: 12 }}>
      <div style={{ fontWeight: 700, fontSize: 13, color: '#1a365d', borderLeft: '4px solid #2b6cb0',
        padding: '5px 10px', background: '#eef4fb', borderRadius: '0 4px 4px 0', marginBottom: 8,
        display: 'flex', gap: 8, alignItems: 'center' }}>{baslik}{ekBaslik}</div>
      <div className="isg-frm">{cocuk}</div>
    </section>
  );

  if (hata) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div>
    <button className="d" onClick={() => git('/radyoloji')}>◀ Çalışma Listesi</button></div>;
  if (!k) return <div className="fm-sayfa"><div className="fm-bolum">Yükleniyor…</div></div>;

  const kontrastAd = N(k, 'kontrast') === 1 ? `Verildi${M(k, 'kontrastMl') !== '0' ? ` · ${M(k, 'kontrastMl')} ml` : ''}` : 'Verilmedi';
  const doz = M(k, 'dlp') || M(k, 'ctdi') ? `DLP ${M(k, 'dlp') || '—'} · CTDIvol ${M(k, 'ctdi') || '—'}` : '— (dozsuz modalite)';

  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow">
        <h1>🧾 Radyoloji İstemi — {M(k, 'accessionNo') || `#${istemId}`}</h1>
        <span className="yol">Radyoloji › İstem Kartı · {M(k, 'modaliteAdi')}</span>
        <div className="sag">
          {duzen ? <>
            <button className="d bir" onClick={() => void kaydet()}>💾 Kaydet</button>
            <button className="d" onClick={() => { setForm(k ? formAl(k) : null); setDuzen(false) }}>Vazgeç</button>
          </> : <>
            {yetki('radyoloji-istem', 'degistir') &&
              <button className="d" onClick={() => { setForm(k ? formAl(k) : null); setDuzen(true) }}>✎ Düzenle</button>}
            {yetki('radyoloji', 'degistir') && durum >= 2 && durum < 5 &&
              <button className="d bir" onClick={() => git(`/radyoloji/rapor/${istemId}`)}>✎ Rapor Yaz</button>}
            {durum >= 3 &&
              <button className="d" onClick={() => git(`/radyoloji/rapor/${istemId}`)}>📄 Raporu Aç</button>}
            <button className="d" onClick={() => void yukle()}>⟳ Yenile</button>
            <button className="d" onClick={() => git('/radyoloji')}>◀ Çalışma Listesi</button>
          </>}
        </div>
      </div></div>

      {/* KİMLİK ŞERİDİ */}
      <section className="fm-bolum"><div className="isg-frm">
        {alan('Hasta', `${M(k, 'cinsiyet') === 'K' ? '♀' : M(k, 'cinsiyet') === 'E' ? '♂' : ''} ${M(k, 'hastaAdi')}${N(k, 'yas') ? ` · ${N(k, 'yas')} y` : ''}${M(k, 'telefon') ? ` · ☎ ${M(k, 'telefon')}` : ''}`)}
        {alan('Tetkik', `${M(k, 'tetkikKodu')} · ${M(k, 'tetkikAdi')}`)}
        {duzAlan('Öncelik', M(k, 'oncelikAdi') || 'Normal',
          <select className="inp" value={form?.oncelik ?? 1} onChange={e => fs({ oncelik: Number(e.target.value) })}>
            <option value={1}>Normal</option><option value={2}>Acil</option>
          </select>)}
        <div className="al"><span className="lb">Durum</span>
          <div className="inp" style={{ background: '#f7f8fa', minHeight: 30, padding: '5px 8px' }}>
            <span className={`rz ${DURUM_RENK[durum] ?? ''}`}>{M(k, 'durumAdi') || '—'}</span></div></div>
      </div></section>

      {/* AKIŞ ŞERİDİ */}
      <div style={{ display: 'flex', gap: 6, margin: '10px 0', flexWrap: 'wrap' }}>
        {adimlar.map((a, i) => {
          const simdi = i === simdiIdx;
          return (
            <div key={a.ad} style={{ flex: 1, minWidth: 90, textAlign: 'center', padding: '6px 4px',
              borderRadius: 6, fontSize: 12, fontWeight: 600,
              background: a.tamam ? '#e6f7ec' : simdi ? '#fff6e5' : '#f0f1f4',
              color: a.tamam ? '#0a7a3a' : simdi ? '#7a5300' : '#889',
              border: `1px solid ${a.tamam ? '#0a7a3a55' : simdi ? '#e0a83c' : '#dde'}` }}>
              {a.tamam ? '✓ ' : simdi ? '● ' : ''}{a.ad}<br />
              <span style={{ fontWeight: 400, fontSize: 11 }}>{zaman(a.t) || '—'}</span>
            </div>
          );
        })}
      </div>

      {grup('İstem Bilgisi', <>
        {alan('İsteyen Hekim / Bölüm', M(k, 'isteyenHekim') || M(k, 'isteyenKurum'))}
        {alan('Başvuru (Protokol)', M(k, 'protokol') ? `${M(k, 'protokol')} · ${gun(k['protokolTarihi'])}` : '—')}
        {duzAlan('Ön Tanı (ICD-10)', M(k, 'onTani'),
          <input className="inp" value={form?.onTani ?? ''} onChange={e => fs({ onTani: e.target.value })} placeholder="ICD-10 / ön tanı" />)}
        {alan('Ödeyen Kurum', M(k, 'odeyenKurum'))}
        {duzAlan('Klinik Bilgi / İstem Notu', M(k, 'klinikBilgi'),
          <textarea className="inp" rows={2} style={{ height: 'auto' }} value={form?.klinikBilgi ?? ''} onChange={e => fs({ klinikBilgi: e.target.value })} />, true)}
      </>)}

      {grup('Çekim / Görüntü', <>
        {alan('Modalite / Cihaz', `${M(k, 'modaliteAdi')}${M(k, 'cihaz') ? ` · ${M(k, 'cihaz')}` : ''}`)}
        {alan('Tekniker', M(k, 'tekniker'))}
        {alan('Çekim Zamanı', zaman(k['cekimTarihi']))}
        {duzAlan('Kontrast', kontrastAd,
          <div style={{ display: 'flex', gap: 6 }}>
            <select className="inp" value={form?.kontrast ?? 0} onChange={e => fs({ kontrast: Number(e.target.value) })}>
              <option value={0}>Verilmedi</option><option value={1}>Verildi</option>
            </select>
            <input className="inp" style={{ width: 80 }} placeholder="ml" value={form?.kontrastMl ?? ''}
              onChange={e => fs({ kontrastMl: e.target.value })} disabled={form?.kontrast !== 1} />
          </div>)}
        {duzAlan('Seri / Görüntü',
          N(k, 'seriSayisi') || N(k, 'goruntuSayisi') ? `${N(k, 'seriSayisi')} seri · ${N(k, 'goruntuSayisi')} görüntü` : '—',
          <div style={{ display: 'flex', gap: 6 }}>
            <input className="inp" style={{ width: 90 }} placeholder="seri" value={form?.seriSayisi ?? ''}
              onChange={e => fs({ seriSayisi: e.target.value.replace(/\D/g, '') })} />
            <input className="inp" style={{ width: 90 }} placeholder="görüntü" value={form?.goruntuSayisi ?? ''}
              onChange={e => fs({ goruntuSayisi: e.target.value.replace(/\D/g, '') })} />
          </div>)}
        {alan('Doz (DLP / CTDIvol)', doz)}
        {alan('Study UID', M(k, 'studyUid'), true)}
      </>)}

      <section className="fm-bolum" style={{ marginTop: 12 }}>
        <div style={{ fontWeight: 700, fontSize: 13, color: '#1a365d', borderLeft: '4px solid #2b6cb0',
          padding: '5px 10px', background: '#eef4fb', borderRadius: '0 4px 4px 0', marginBottom: 8 }}>
          Kontrol Listesi (çekim öncesi)</div>
        {kontrol.length === 0 ? <div style={{ padding: 8, color: '#889' }}>Bu modalitede kontrol sorusu yok.</div> : (
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}
            className="rk-tbl">
            <thead><tr style={{ background: '#f0f1f4', textAlign: 'left' }}>
              <th style={{ width: 28, padding: '6px 8px' }}></th>
              <th style={{ padding: '6px 8px' }}>Soru</th>
              <th style={{ width: 150, padding: '6px 8px' }}>Yanıt</th>
              <th style={{ width: 190, padding: '6px 8px' }}>Kaydeden</th></tr></thead>
            <tbody>
              {kontrol.map((s, i) => (
                <tr key={i} style={{ borderTop: '1px solid #e6e8ec' }}>
                  <td style={{ padding: '6px 8px' }}>{s.yanit ? '☑' : '☐'}</td>
                  <td style={{ padding: '6px 8px' }}>{s.soru}</td>
                  <td style={{ padding: '6px 8px' }}>{s.yanit || <span style={{ color: '#c00' }}>—</span>}</td>
                  <td style={{ padding: '6px 8px' }}>{s.kaydeden}{s.kayitZamani ? ` · ${zaman(s.kayitZamani)}` : ''}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      <div className="statusbar" style={{ marginTop: 10 }}>
        <span>İstem No: <b>{M(k, 'accessionNo')}</b></span>
        <span className="sp">Bekleme (istem→çekim): <b>{akis?.['beklemeDk'] != null ? `${N(akis, 'beklemeDk')} dk` : '—'}</b></span>
        <span>Rapor: <b>{M(akis, 'raporNo') || (N(akis, 'raporDurum') ? 'Taslak' : '—')}</b>{M(akis, 'raporYazan') ? ` · ${M(akis, 'raporYazan')}` : ''}</span>
        <span>Oluşturan: <b>{M(akis, 'olusturan')}</b> · {zaman(akis?.['istemZamani'])}</span>
      </div>
    </div>
  );
}
