import { useState, type ReactNode } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { mesaj } from './mesaj';
import { c } from '../dil/ceviri';
import { Modal } from './Modal';
import type { RandevuSeriSablonu } from '../api/uclar/ayar';

const GUN_ADLARI = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
/** ISO gün: 1 Pzt … 7 Paz. */
const isoGunu = (t: string) => { const g = new Date(`${t}T12:00`).getDay(); return g === 0 ? 7 : g };
const gunEkle = (t: string, n: number) => {
  const d = new Date(`${t}T12:00`); d.setDate(d.getDate() + n);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};
const bugun = () => { const d = new Date(); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}` };

/** FTR sıklığı → haftanın günleri (sunucudaki eski planlayıcıyla aynı: 5 Pzt–Cum, 3 Pzt/Çar/Cum, 2 Sal/Per). */
export function sikliktanGunler(siklik: number): number[] {
  return siklik >= 5 ? [1, 2, 3, 4, 5] : siklik === 4 ? [1, 2, 4, 5] : siklik === 3 ? [1, 3, 5] : siklik === 2 ? [2, 4] : [1];
}

interface Satir { tarih: string; saat: string; tamam?: boolean; mesaj?: string; oneri?: string | null }

/**
 * SERİ RANDEVU PENCERESİ (kullanıcı 17.10.2026: "FTR için çoklu randevu (5-10-15 seans)" + "genel tekrarla").
 *
 * Seans sayısı, haftanın günleri, saat ve süreden tarih listesi üretilir; "Kontrol Et" her satırı
 * sunucuda veritabanı kurallarıyla dener (yazmadan) - çakışan satırda aynı gün için öneri gelir,
 * saat satırda değiştirilebilir. Kaydet uygun satırları tek işlemde yazar (FTR'de seansları da).
 */
export function RandevuSeriPenceresi({ baslik, kaynak, ilkTarih, saat: ilkSaat, sureDk, adet: ilkAdet, gunler: ilkGunler,
                                       hekimId, ustAlan, onceKaydet, ilkDahil, onKapat, onKaydedildi }: {
  baslik: string;
  /** sablon: kaydedilmemiş yeni randevu - yalnız önizleme; kayıtta önce ilk randevu yazılır (onceKaydet). */
  kaynak: { kaynakRandevuId: number } | { ftrProgramId: number } | { sablon: RandevuSeriSablonu };
  /**
   * YENİ KARTTA TEKRARLA (kullanıcı 17.10.2026): Kaydet önce ilk randevuyu kartın kendi kaydıyla yazar,
   * verilen işi (tekrarlar) onun id'siyle çalıştırır; kart sonra kapanır.
   */
  onceKaydet?(sonra: (ilkId: number) => Promise<void>): Promise<void>;
  /** YENİ KARTTA TEKRARLA (kullanıcı 17.10.2026): sayı kaydedilmemiş ilk randevuyu da içerir - üretilen
   *  tekrar bir eksiktir. Kayıtlı randevuda sayı bundan sonraki tekrar sayısıdır; FTR'de seans sayısı. */
  ilkDahil?: boolean;
  ilkTarih: string;
  saat: string;
  sureDk: number;
  adet: number;
  gunler: number[];
  /** FTR: seçilen fizyoterapist (programdakini ezer, kayıtta programa da yazılır). */
  hekimId?: number | null;
  /** Üstte ek alan (FTR: fizyoterapist seçici) - seçici çağırandan gelir: TarafArama GenForm'u, GenForm bu
   *  pencereyi içe aktarıyor; burada içe aktarmak döngüsel import olurdu. */
  ustAlan?: ReactNode;
  onKapat(): void;
  onKaydedildi(adet: number): void;
}) {
  const [baslangic, setBaslangic] = useState(ilkTarih < bugun() ? bugun() : ilkTarih);
  const [saat, setSaat] = useState(ilkSaat || '09:00');
  const [sure, setSure] = useState(sureDk || 15);
  const [adet, setAdet] = useState(Math.max(1, ilkAdet));
  const [gunler, setGunler] = useState<number[]>(ilkGunler.length ? ilkGunler : [isoGunu(ilkTarih)]);
  const [satirlar, setSatirlar] = useState<Satir[]>([]);
  const [kontrollu, setKontrollu] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);

  /** Tarih listesini kurallardan üret (kontrol durumu sıfırlanır). */
  const uret = () => {
    const l: Satir[] = [];
    const hedef = ilkDahil ? adet - 1 : adet;
    for (let i = 0, t = baslangic; l.length < hedef && i < 400; i++, t = gunEkle(t, 1))
      if (gunler.includes(isoGunu(t))) l.push({ tarih: t, saat });
    setSatirlar(l); setKontrollu(false);
    return l;
  };

  const gonder = async (kaydet: boolean, liste: Satir[]) => {
    if (liste.length === 0) {
      setHata(ilkDahil && adet <= 1 ? c('Toplam en az 2 olmalı (ilk randevu dahil).') : c('Önce tarihleri üretin (en az bir gün seçin).'));
      return;
    }
    setHata(null); setMesgul(true);
    if (kaydet && onceKaydet) {
      // İlk randevu + tekrarlar: kart kaydedilir, tekrarlar ilk randevunun id'siyle yazılır.
      try {
        await onceKaydet(async ilkId => {
          const y = await api.randevuSeri({ kaynakRandevuId: ilkId, sureDk: sure, kaydet: true,
                                            baslangiclar: liste.map(s => `${s.tarih}T${s.saat}`) });
          const kalan = y.satirlar.filter(s => !s.tamam);
          mesaj(`${c('İlk randevu')} + ${y.uygun} ${c('tekrar kaydedildi.')}`
                + (kalan.length ? ` ${kalan.length} ${c('satır uygun değildi')}: ${kalan.map(s => s.baslangic.replace('T', ' ')).join(', ')}` : ''));
          onKaydedildi(y.uygun);
        });
      } catch (h) { setHata(hataMetni(h)) }
      finally { setMesgul(false) }
      return;
    }
    try {
      const y = await api.randevuSeri({ ...kaynak, sureDk: sure, kaydet, hekimId: hekimId ?? undefined,
                                        baslangiclar: liste.map(s => `${s.tarih}T${s.saat}`) });
      const sonuc = new Map(y.satirlar.map(s => [s.baslangic, s]));
      setSatirlar(liste.map(s => { const r = sonuc.get(`${s.tarih}T${s.saat}`); return { ...s, tamam: r?.tamam, mesaj: r?.mesaj, oneri: r?.oneri } }));
      setKontrollu(true);
      if (kaydet && y.kaydedildi) {
        const kalan = y.satirlar.filter(s => !s.tamam).length;
        if (kalan === 0) { onKaydedildi(y.uygun); return }
        // Uygun olanlar yazıldı; kalanlar düzeltilip yeniden kaydedilebilir.
        setSatirlar(l => l.filter(s => !s.tamam));
        setHata(`${y.uygun} ${c('randevu kaydedildi')}; ${kalan} ${c('satır uygun değil - saatini değiştirip yeniden kaydedin.')}`);
        onKaydedildi(y.uygun);
      }
    } catch (h) { setHata(hataMetni(h)) }
    finally { setMesgul(false) }
  };

  const uygun = satirlar.filter(s => s.tamam).length;
  const saatDegis = (i: number, v: string) => { setSatirlar(l => l.map((s, j) => j === i ? { ...s, saat: v, tamam: undefined, mesaj: '', oneri: null } : s)); setKontrollu(false) };
  const kutu: React.CSSProperties = { height: 28, padding: '0 6px' };

  return (
    <Modal baslik={baslik} enUst buyutmeYok onKapat={onKapat}
           alt={<>
             <button type="button" className="d" disabled={mesgul} onClick={() => void gonder(false, satirlar.length ? satirlar : uret())}>
               🔎 {c('Kontrol Et')}</button>
             <button type="button" className="d bir" disabled={mesgul || !kontrollu || uygun === 0}
                     title={!kontrollu ? c('Önce kontrol edin.') : undefined}
                     onClick={() => void gonder(true, satirlar)}>💾 {c('Kaydet')}{kontrollu ? ` (${uygun})` : ''}</button>
             <button type="button" className="d" style={{ marginLeft: 'auto' }} onClick={onKapat}>✖ {c('Kapat')}</button>
           </>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, minWidth: 620 }}>
        <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', alignItems: 'flex-end', fontSize: 12, fontWeight: 600 }}>
          <label style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>{c('İlk tarih')}
            <input type="date" style={kutu} value={baslangic} onChange={e => { setBaslangic(e.target.value); setSatirlar([]); setKontrollu(false) }} /></label>
          <label style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>{c('Saat')}
            <input type="time" style={kutu} value={saat} onChange={e => { setSaat(e.target.value); setSatirlar([]); setKontrollu(false) }} /></label>
          <label style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>{c('Süre (dk)')}
            <input type="number" min={5} step={5} style={{ ...kutu, width: 70 }} value={sure}
                   onChange={e => { setSure(Number(e.target.value) || 0); setKontrollu(false) }} /></label>
          <label style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>{ilkDahil ? c('Toplam randevu (ilk dahil)') : 'kaynakRandevuId' in kaynak ? c('Tekrar sayısı (bundan sonra)') : c('Seans sayısı')}
            <span style={{ display: 'flex', gap: 4 }}>
              {[5, 10, 15, 20].map(n => (
                <button key={n} type="button" className={`d${adet === n ? ' bir' : ''}`}
                        onClick={() => { setAdet(n); setSatirlar([]); setKontrollu(false) }}>{n}</button>
              ))}
              <input type="number" min={1} max={60} style={{ ...kutu, width: 60 }} value={adet}
                     onChange={e => { setAdet(Math.min(60, Math.max(1, Number(e.target.value) || 1))); setSatirlar([]); setKontrollu(false) }} />
            </span></label>
        </div>
        {ustAlan && <div style={{ maxWidth: 360 }} onChange={() => setKontrollu(false)}>{ustAlan}</div>}
        <div style={{ display: 'flex', gap: 4, alignItems: 'center', fontSize: 12, fontWeight: 600 }}>
          {c('Günler')}:
          {GUN_ADLARI.map((g, i) => (
            <button key={g} type="button" className={`cip${gunler.includes(i + 1) ? ' on' : ''}`}
                    onClick={() => { setGunler(l => l.includes(i + 1) ? l.filter(x => x !== i + 1) : [...l, i + 1]); setSatirlar([]); setKontrollu(false) }}>{c(g)}</button>
          ))}
          <button type="button" className="d" style={{ marginLeft: 'auto' }} onClick={() => uret()}>🗓 {c('Tarihleri Üret')}</button>
        </div>

        {ilkDahil && satirlar.length > 0 && <div className="not" style={{ margin: 0 }}>{c('1. randevu: karttaki randevu. Aşağıdakiler tekrarlar.')}</div>}
        {satirlar.length > 0 && (
          <div style={{ maxHeight: 360, overflowY: 'auto', border: '1px solid var(--cizgi)', borderRadius: 4 }}>
            <table className="grid" style={{ width: '100%' }}>
              <thead><tr><th style={{ width: 36 }}>#</th><th>{c('Tarih')}</th><th style={{ width: 110 }}>{c('Saat')}</th><th>{c('Durum')}</th><th style={{ width: 34 }} /></tr></thead>
              <tbody>
                {satirlar.map((s, i) => (
                  <tr key={`${s.tarih}-${i}`}>
                    <td>{i + (ilkDahil ? 2 : 1)}</td>
                    <td>{GUN_ADLARI[isoGunu(s.tarih) - 1]} {s.tarih.split('-').reverse().join('.')}</td>
                    <td><input type="time" style={{ ...kutu, width: 96 }} value={s.saat} onChange={e => saatDegis(i, e.target.value)} /></td>
                    <td>
                      {s.tamam === true && <span className="rozet ok">✔ {c('Uygun')}</span>}
                      {s.tamam === false && <>
                        <span className="rozet hata" title={s.mesaj}>✖ {s.mesaj}</span>
                        {s.oneri && <button type="button" className="d" style={{ marginLeft: 6 }}
                                            onClick={() => saatDegis(i, s.oneri!)}>{c('Öneri')} {s.oneri} ↩</button>}
                      </>}
                      {s.tamam === undefined && <span className="sonuk">{c('kontrol edilmedi')}</span>}
                    </td>
                    <td><button type="button" className="d" title={c('Satırı çıkar')}
                                onClick={() => { setSatirlar(l => l.filter((_, j) => j !== i)) }}>✕</button></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        {kontrollu && <div className="not" style={{ margin: 0 }}>{uygun} / {satirlar.length} {c('satır uygun. Kaydet yalnız uygun satırları yazar.')}</div>}
        {hata && <div className="hata-kutusu">{hata}</div>}
      </div>
    </Modal>
  );
}
