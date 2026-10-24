import { useEffect, useState, type ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { ListeSatiri } from '../../api/sozlesme/liste';
import { hastaIcmalUclari, type HastaIcmali } from '../../api/uclar/hastaIcmal';
import { gunMetni as tarih, para, tarihSaat } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';

/**
 * HASTA KARTI SEKMELERİ (kullanıcı 24.10.2026, mockup Kayıt Kabul/hasta_karti_v5.html):
 * Randevular · Mali · Onam & Belgeler. Üçü de kartın detayı değil, başka ekranların kayıtları -
 * salt okunur liste. Veri mevcut uçlardan: `randevu` / `onam` / `onam-metni` listeleri ve hasta
 * icmali; yetkisi olmayan kullanıcı sunucudan 403 alır, sekmede o hata yazar.
 */

type Durum<T> = { veri: T | null; hata: string; yukleniyor: boolean };
function useVeri<T>(yukle: () => Promise<T>, bag: unknown[]): Durum<T> {
  const [d, setD] = useState<Durum<T>>({ veri: null, hata: '', yukleniyor: true });
  useEffect(() => {
    let iptal = false;
    setD(x => ({ ...x, yukleniyor: true }));
    yukle().then(v => { if (!iptal) setD({ veri: v, hata: '', yukleniyor: false }) })
      .catch(e => { if (!iptal) setD({ veri: null, hata: hataMetni(e), yukleniyor: false }) });
    return () => { iptal = true };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, bag);
  return d;
}

const s = (v: unknown) => String(v ?? '');
const bos = (metin: string, kolon: number) => <tr><td colSpan={kolon} className="bos">{c(metin)}</td></tr>;
const Kutu = ({ baslik, sag, children }: { baslik: string; sag?: ReactNode; children: ReactNode }) => (
  <div className="kagrup">
    <h6>{c(baslik)}{sag && <span style={{ marginLeft: 'auto', display: 'flex', gap: 6 }}>{sag}</span>}</h6>
    {children}
  </div>
);

// ------------------------------------------------------------ RANDEVULAR ----
const RANDEVU_CIPLERI = [
  { k: 'gelecek', ad: 'Gelecek' }, { k: 'gecmis', ad: 'Geçmiş' },
  { k: 'gelmedi', ad: 'Gelmedi' }, { k: 'iptal', ad: 'İptal' },
] as const;
type RandevuCip = typeof RANDEVU_CIPLERI[number]['k'];
// randevu.durum: 1 Planlandı, 2 Geldi, 3 Gelmedi, 4 İptal, 5 Ertelendi.
const randevuCipi = (r: ListeSatiri, simdi: number): RandevuCip => {
  const d = Number(r.durum);
  if (d === 4) return 'iptal';
  if (d === 3) return 'gelmedi';
  return (d === 1 || d === 5) && new Date(s(r.baslangic)).getTime() > simdi ? 'gelecek' : 'gecmis';
};
const DURUM_ROZET: Record<number, string> = { 1: 'mavi', 2: 'ok', 3: 'hata', 4: 'gri', 5: 'sari' };

export function HastaRandevulari({ hastaId }: { hastaId: number }) {
  const git = useNavigate();
  const d = useVeri(() => api.liste('randevu', {
    sayfa: 1, boyut: 200, sirala: [{ alan: 'baslangic', yon: 'desc' }],
    filtre: { op: 'and', kosullar: [{ alan: 'hastaId', op: 'esit', deger: hastaId }] },
  }).then(y => y.satirlar), [hastaId]);
  const simdi = Date.now();
  const satirlar = d.veri ?? [];
  const sayilar = Object.fromEntries(RANDEVU_CIPLERI.map(x => [x.k, satirlar.filter(r => randevuCipi(r, simdi) === x.k).length]));
  const [cip, setCip] = useState<RandevuCip | null>(null);
  // Varsayılan: gelecek randevu varsa o, yoksa geçmiş.
  const secili = cip ?? (sayilar.gelecek > 0 ? 'gelecek' : 'gecmis');
  const gorunen = satirlar.filter(r => randevuCipi(r, simdi) === secili);
  if (secili === 'gelecek') gorunen.reverse();
  return (
    <Kutu baslik="Randevular" sag={<>
      {RANDEVU_CIPLERI.map(x => (
        <button key={x.k} type="button" className={`cip${secili === x.k ? ' on' : ''}`} onClick={() => setCip(x.k)}>
          {c(x.ad)} <b>{sayilar[x.k]}</b></button>))}
      <button type="button" className="d bir" onClick={() => git(`/randevu/yeni?hastaId=${hastaId}`)}>{c('＋ Randevu')}</button></>}>
      {d.hata && <div className="hata-kutusu">{d.hata}</div>}
      <table className="detay-tablo">
        <thead><tr>
          <th style={{ width: 140 }}>{c('Tarih')}</th><th>{c('Bölüm')}</th><th>{c('Doktor')}</th>
          <th>{c('Hizmet / Cihaz')}</th><th style={{ width: 110 }}>{c('Tip')}</th><th style={{ width: 130 }}>{c('Kaynak')}</th>
          <th style={{ width: 110 }}>{c('Durum')}</th>
        </tr></thead>
        <tbody>
          {gorunen.map(r => (
            <tr key={s(r.id)}>
              <td>{secili === 'gelecek' ? <b>{tarihSaat(s(r.baslangic))}</b> : tarihSaat(s(r.baslangic))}</td>
              <td>{s(r.bolumAdi) || <span className="sonuk">—</span>}</td>
              <td>{s(r.hekim) || <span className="sonuk">—</span>}</td>
              <td>{s(r.hizmet) || s(r.cihaz) || <span className="sonuk">—</span>}</td>
              <td>{s(r.tipAdi)}</td>
              <td>{s(r.kaynakAdi)}</td>
              <td><span className={`rozet ${DURUM_ROZET[Number(r.durum)] ?? 'gri'}`}>{s(r.durumAdi)}</span>
                {s(r.erteleme) && <small className="sonuk" title={s(r.erteleme)}> ↻</small>}</td>
            </tr>))}
          {!d.yukleniyor && !d.hata && gorunen.length === 0 && bos('Bu grupta randevu yok.', 7)}
        </tbody>
      </table>
      {d.yukleniyor && <div className="yukleniyor">{c('Yükleniyor…')}</div>}
    </Kutu>
  );
}

// ------------------------------------------------------------------ MALİ ----
export function HastaMali({ hastaId }: { hastaId: number }) {
  const git = useNavigate();
  const d = useVeri<HastaIcmali>(() => hastaIcmalUclari.hastaIcmal(hastaId), [hastaId]);
  const o = d.veri?.ozet;
  const acik = (d.veri?.basvurular ?? []).filter(b => !b.iptal && b.kalan > 0.005);
  const kalan = o?.kalan ?? 0;
  return (
    <>
      {d.hata && <div className="hata-kutusu">{d.hata}</div>}
      <div className="kasira">
        <div className="kasutun" style={{ flex: 1, minWidth: 0 }}>
          <Kutu baslik="Hesap Özeti" sag={<>
            <button type="button" className="d" onClick={() => git(`/hasta-icmal/${hastaId}`)}>📊 {c('Hesap İcmali')}</button>
            <button type="button" className="d" onClick={() => git(`/ekstre?tur=cari&id=${hastaId}`)}>📄 {c('Ekstre')}</button></>}>
            <table className="detay-tablo">
              <thead><tr><th>{c('Kalem')}</th><th className="hiza-sag" style={{ width: 140 }}>{c('Tutar')}</th></tr></thead>
              <tbody>
                <tr><td>{c('Hasta payı (katkı + fark ücreti)')}</td><td className="hiza-sag">{o ? para.format(o.hastaPayi) : '…'}</td></tr>
                <tr><td>{c('Tahsil edilen')}</td><td className="hiza-sag ml-alacak">{o ? para.format(o.tahsil - o.iade) : '…'}</td></tr>
                <tr><td>{c('Avans')}</td><td className="hiza-sag">{o ? para.format(o.avans) : '…'}</td></tr>
                <tr><td>{c('Kurum payı')}</td><td className="hiza-sag sonuk">{o ? para.format(o.kurumPayi) : '…'}</td></tr>
                <tr style={{ fontWeight: 'bold' }}><td>{c('Hasta bakiyesi')}</td>
                  <td className={`hiza-sag ${kalan > 0.005 ? 'ml-borc' : kalan < -0.005 ? 'ml-alacak' : ''}`}>
                    {o ? `${para.format(Math.abs(kalan))}${kalan > 0.005 ? ' ' + c('borç') : kalan < -0.005 ? ' ' + c('alacak') : ''}` : '…'}</td></tr>
              </tbody>
            </table>
            {d.veri && <div className="not" style={{ padding: '6px 10px' }}>
              {c('Dönem')}: {tarih(d.veri.donem.bas)} – {tarih(d.veri.donem.bit)} · {o?.basvuru ?? 0} {c('başvuru')}</div>}
          </Kutu>
        </div>
        <div className="kasutun" style={{ flex: 1, minWidth: 0 }}>
          <Kutu baslik="Açık Kalemler">
            <table className="detay-tablo">
              <thead><tr><th style={{ width: 140 }}>{c('Başvuru')}</th><th>{c('Bölüm / Doktor')}</th>
                <th style={{ width: 100 }}>{c('Tarih')}</th><th className="hiza-sag" style={{ width: 120 }}>{c('Kalan')}</th></tr></thead>
              <tbody>
                {acik.map(b => (
                  <tr key={b.id} className="tiklanir" title={c('Başvuruyu açmak için çift tıklayın')}
                      onDoubleClick={() => git(`/basvuru/${b.id}`)}>
                    <td><code>{b.no}</code></td>
                    <td>{[b.bolum, b.hekim].filter(Boolean).join(' · ') || <span className="sonuk">—</span>}</td>
                    <td>{tarih(b.tarih ?? '')}</td>
                    <td className="hiza-sag ml-borc">{para.format(b.kalan)}</td>
                  </tr>))}
                {!d.yukleniyor && !d.hata && acik.length === 0 && bos('Açık kalem yok.', 4)}
              </tbody>
            </table>
            <div className="not" style={{ padding: '6px 10px' }}>
              {c('Tahsilat banko oturumunun kasasına yazılır; makbuz / e-Arşiv aynı akış (Banko › Tahsilat Al).')}</div>
          </Kutu>
        </div>
      </div>
      {d.yukleniyor && <div className="yukleniyor">{c('Yükleniyor…')}</div>}
    </>
  );
}

// ------------------------------------------------------- ONAM & BELGELER ----
// onam.sonuc: 1 verildi, 0 reddedildi, diğer geri çekildi.
const onamRozet = (r: ListeSatiri) => {
  const gecerlilik = s(r.gecerlilik);
  if (Number(r.sonuc) === 1 && gecerlilik && new Date(gecerlilik).getTime() < Date.now())
    return <span className="rozet sari">{c('Süresi doldu')}</span>;
  return <span className={`rozet ${Number(r.sonuc) === 1 ? 'ok' : Number(r.sonuc) === 0 ? 'hata' : 'gri'}`}>{s(r.sonucAdi)}</span>;
};

export function HastaOnamlari({ hastaId }: { hastaId: number }) {
  const d = useVeri(async () => {
    const [onam, metin] = await Promise.all([
      api.liste('onam', { sayfa: 1, boyut: 200, sirala: [{ alan: 'tarih', yon: 'desc' }],
        filtre: { op: 'and', kosullar: [{ alan: 'tarafId', op: 'esit', deger: hastaId }] } }),
      // Zorunlu ve aktif metinler: hastada geçerli onamı yoksa "Eksik" satırı olarak görünür.
      api.liste('onam-metni', { sayfa: 1, boyut: 100,
        filtre: { op: 'and', kosullar: [{ alan: 'zorunlu', op: 'esit', deger: 1 }, { alan: 'durum', op: 'esit', deger: 1 }] } }),
    ]);
    return { onamlar: onam.satirlar, zorunlu: metin.satirlar };
  }, [hastaId]);
  const onamlar = d.veri?.onamlar ?? [];
  const verilmisAd = new Set(onamlar.filter(r => Number(r.sonuc) === 1).map(r => s(r.onamAdi)));
  const eksik = (d.veri?.zorunlu ?? []).filter(m => !verilmisAd.has(s(m.ad)));
  return (
    <Kutu baslik="Onam & Belgeler">
      {d.hata && <div className="hata-kutusu">{d.hata}</div>}
      <table className="detay-tablo">
        <thead><tr>
          <th>{c('Belge')}</th><th style={{ width: 70 }}>{c('Sürüm')}</th><th style={{ width: 140 }}>{c('Tarih')}</th>
          <th style={{ width: 140 }}>{c('İmza / Kanal')}</th><th style={{ width: 170 }}>{c('Veren')}</th>
          <th style={{ width: 110 }}>{c('Geçerlilik')}</th><th style={{ width: 120 }}>{c('Durum')}</th>
        </tr></thead>
        <tbody>
          {eksik.map(m => (
            <tr key={`m${s(m.id)}`}>
              <td><b>{s(m.ad)}</b></td><td>{s(m.surum)}</td><td className="sonuk">—</td><td className="sonuk">—</td>
              <td className="sonuk">—</td><td className="sonuk">—</td>
              <td><span className="rozet hata" title={c('Zorunlu onam - hastada geçerli kaydı yok')}>{c('Eksik')}</span></td>
            </tr>))}
          {onamlar.map(r => (
            <tr key={s(r.id)}>
              <td>{s(r.onamAdi)}</td><td>{s(r.surum)}</td><td>{tarihSaat(s(r.tarih))}</td><td>{s(r.kanalAdi)}</td>
              <td>{s(r.verenKisi) ? `${s(r.verenKisi)}${s(r.yakinlik) ? ` (${s(r.yakinlik)})` : ''}` : c('kendisi')}</td>
              <td>{s(r.gecerlilik) ? tarih(s(r.gecerlilik)) : c('süresiz')}</td>
              <td>{onamRozet(r)}</td>
            </tr>))}
          {!d.yukleniyor && !d.hata && onamlar.length === 0 && eksik.length === 0 && bos('Bu hastanın onam kaydı yok.', 7)}
        </tbody>
      </table>
      {d.yukleniyor && <div className="yukleniyor">{c('Yükleniyor…')}</div>}
      <div className="not" style={{ padding: '6px 10px' }}>
        {c('Zorunlu onamlar Yönetim › Onam Metni Listesi\'nde "Zorunlu" işaretli metinlerdir; onam başvuru / işlem akışında alınır.')}</div>
    </Kutu>
  );
}
