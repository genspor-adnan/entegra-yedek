import { useCallback, useContext, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { Modal } from '../../bilesenler/Modal';
import { StokAramaPenceresi } from '../../bilesenler/StokAramaPenceresi';
import { useSekmedeAc } from '../../bilesenler/KartAdi';
import { mesaj } from '../../bilesenler/mesaj';
import { bugunIso, sayi, tarihYaz } from '../../bilesenler/bicim';
import { EkranSekmesiBaglami, LISTE_TAZELE_OLAYI } from '../../bilesenler/sekmeBaglami';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { UEB_STILI } from './uretimStil';

/**
 * ÜRETİM EMİRLERİ — BASİT SEVİYE (1253, mockup uretim_basit.html ②). Kullanıcı 02.11.2026: "bazı müşterilerimiz KOBİ
 * basit üretim yapıyor.. üretim emri ve fişi karmaşık gelebilir".
 *
 * Basit seviyede emir yalnız İŞ LİSTESİDİR: ne üretilecek, kaç adet, ne zamana, müşteri / not, malzeme yetiyor mu,
 * üretilen. "▶ Üret…" üretilen adedi sorar ve arka planda ÜRETİM FİŞİNİ keser (sunucu /emri/{id}/uret: sarf + giriş +
 * maliyet); emir dolunca kendiliğinden kapanır. Onay, rezerv, sarf fişi, maliyet kapanışı yok - o adımlar Standart
 * seviyede (generic emir listesi / kartı). Veri yapısı aynı uretim_emri; seviye yalnız görüneni değiştirir.
 */
interface Satir {
  id: number; no: string; stokId: number; mamulAd: string; adet: number; uretilenAdet: number; termin: string | null;
  durum: number; aciklama: string; malzemeHazir: number;
}

export function UretimEmirleriBasit() {
  const { yetki } = useOturum();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const sekmedeAc = useSekmedeAc();
  const [satirlar, setSatirlar] = useState<Satir[]>([]);
  const [tamamlananlar, setTamamlananlar] = useState(false);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState('');
  const [uret, setUret] = useState<Satir | null>(null);
  const [yeni, setYeni] = useState(false);

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    try {
      const y = await api.liste('uretim-emri', {
        sayfa: 1, boyut: 300, sirala: [{ alan: 'termin', yon: 'asc' }],
        filtre: tamamlananlar ? { alan: 'durum', op: 'esitDegil', deger: 0 } : { alan: 'durum', op: 'arasinda', deger: [1, 5] },
      });
      setSatirlar(y.satirlar.map(s => ({
        id: Number(s.id), no: String(s.no ?? ''), stokId: Number(s.stokId ?? 0), mamulAd: String(s.mamulAd ?? ''),
        adet: Number(s.adet ?? 0), uretilenAdet: Number(s.uretilenAdet ?? 0), termin: (s.termin as string | null) ?? null,
        durum: Number(s.durum ?? 0), aciklama: String(s.aciklama ?? ''), malzemeHazir: Number(s.malzemeHazir ?? 100),
      })));
      setHata('');
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [tamamlananlar]);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => {
    const tazele = (e: Event) => { if ((e as CustomEvent<string>).detail === 'uretim-emri') void yukle() };
    window.addEventListener(LISTE_TAZELE_OLAYI, tazele);
    return () => window.removeEventListener(LISTE_TAZELE_OLAYI, tazele);
  }, [yukle]);
  useEffect(() => { ekranSekmesi?.baslik(c('Üretim Emirleri'), '/uretim-emri', '🏭') }, [ekranSekmesi]);

  const ekle = yetki('uretim', 'ekle');
  const uretir = yetki('uretim.fis', 'ekle');

  return (
    <div className="ueb">
      <style>{UEB_STILI}</style>
      <div className="sayfabas"><div className="basrow"><h1>🏭 {c('Üretim Emirleri')}</h1><span className="yol">{c('Üretim › Üretim Emirleri')}</span>
        <span className="sag"><span className="rozet gri">{c('Basit seviye · iş listesi')}</span></span></div></div>
      <div className="ueb-arac">
        {ekle && <button className="d bir" onClick={() => setYeni(true)}>＋ {c('Yeni emir')}</button>}
        <button className="d" onClick={() => window.print()}>🖨 {c('İş listesi yazdır')}</button>
        <span className="ayrac" />
        <label className="chk"><input type="checkbox" checked={tamamlananlar} onChange={e => setTamamlananlar(e.target.checked)} /> {c('Tamamlananları göster')}</label>
        <span className="sp" />
        <button className="d" onClick={() => void yukle()}>↻</button>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <table className="ueb-dg">
        <thead><tr><th>{c('Ürün')}</th><th className="sg">{c('Miktar')}</th><th>{c('Termin')}</th><th>{c('Müşteri / not')}</th><th>{c('Malzeme')}</th><th style={{ width: 200 }}>{c('Üretilen')}</th><th style={{ width: 120 }} /></tr></thead>
        <tbody>
          {satirlar.map(s => {
            const oran = s.adet > 0 ? Math.min(100, Math.round(s.uretilenAdet * 100 / s.adet)) : 0;
            const bitti = s.durum >= 6 || s.durum === 0;
            const gecikti = !bitti && s.termin && s.termin.slice(0, 10) < bugunIso();
            return (
              <tr key={s.id} className={bitti ? 'bitti' : ''}>
                <td><b><button type="button" className="bag" onClick={() => sekmedeAc(`/uretim-emri/${s.id}`)}>{s.mamulAd}</button></b> <span className="sl">{s.no}</span></td>
                <td className="sg">{sayi.format(s.adet)}</td>
                <td className={gecikti ? 'eks' : ''}>{s.termin ? tarihYaz(s.termin) : <span className="sl">—</span>}</td>
                <td>{s.aciklama || <span className="sl">{c('stok için')}</span>}</td>
                <td>{bitti ? <span className="sl">—</span> : s.malzemeHazir >= 100 ? <span className="rz ok">{c('Yeterli')}</span> : <span className="rz uy">%{s.malzemeHazir} · {c('eksik var')}</span>}</td>
                <td><span className="bar"><i style={{ width: `${oran}%` }} /></span><span className="sl">{sayi.format(s.uretilenAdet)} / {sayi.format(s.adet)}</span></td>
                <td>{!bitti && uretir && <button type="button" className="d mor" onClick={() => setUret(s)}>▶ {c('Üret…')}</button>}
                    {s.durum === 6 && <span className="rz ok">{c('Tamamlandı')}</span>}{s.durum === 7 && <span className="rz gri">{c('Kapatıldı')}</span>}{s.durum === 0 && <span className="rz hata">{c('İptal')}</span>}</td>
              </tr>);
          })}
          {!yukleniyor && satirlar.length === 0 && <tr><td colSpan={7} className="sl bos">{c('Açık üretim emri yok. "＋ Yeni emir" ile ne üretileceğini, kaç adet ve ne zamana yazın.')}</td></tr>}
        </tbody>
      </table>
      <div className="sl kucuk" style={{ padding: '0 12px 10px' }}>{c('Üret: üretilen adedi yazın; malzemeler ürün ağacından sarf deposundan düşer, ürün girer, maliyet hesaplanır (üretim fişi). Kalan adet emirde açık kalır; emir dolunca kapanır.')}</div>
      {uret && <UretPenceresi emir={uret} onKapat={() => setUret(null)} onBitti={() => { setUret(null); void yukle() }} />}
      {yeni && <YeniEmirPenceresi onKapat={() => setYeni(false)} onBitti={() => { setYeni(false); void yukle() }} />}
    </div>
  );
}

/** ▶ ÜRET — "Kaç adet üretildi?" + tarih + fire; onay = fiş kesilir (uretim_basit.html ② modal). */
function UretPenceresi({ emir, onKapat, onBitti }: { emir: Satir; onKapat(): void; onBitti(): void }) {
  const kalan = Math.max(0, emir.adet - emir.uretilenAdet);
  const [adet, setAdet] = useState(String(kalan || emir.adet));
  const [tarih, setTarih] = useState(bugunIso());
  const [fireAdet, setFireAdet] = useState('');
  const [fireStok, setFireStok] = useState<{ id: number; ad: string } | null>(null);
  const [fireAra, setFireAra] = useState(false);
  const [eksiyeIzin, setEksiyeIzin] = useState(false);
  const [hata, setHata] = useState('');
  const [mesgul, setMesgul] = useState(false);
  const n = Number(adet.replace(',', '.')) || 0;
  const calistir = async () => {
    if (n <= 0) { setHata(c('Adet sıfırdan büyük olmalı.')); return }
    setMesgul(true); setHata('');
    try {
      const y = await api.uretimEmriUret(emir.id, { adet: n, tarih: `${tarih}T${new Date().toTimeString().slice(0, 5)}`,
        fireStokId: fireStok?.id ?? null, fireAdet: Number(fireAdet.replace(',', '.')) || null, eksiyeIzin });
      mesaj([y.mesaj, ...y.uyarilar].join('\n'));
      window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'uretim-fisi' }));
      onBitti();
    } catch (h) {
      const m = hataMetni(h);
      setHata(m);
      // Malzeme yetmiyorsa "yine de" seçeneği açılır (basit / standart: uyarıyla izin).
      if (/stok|yetmiyor|eksik|yetersiz/i.test(m)) setEksiyeIzin(false);
    } finally { setMesgul(false) }
  };
  if (fireAra) return <StokAramaPenceresi etkin yalnizStok tekSecim onSec={(s: ListeSatiri) => { setFireStok({ id: Number(s.id), ad: String(s.ad ?? '') }); setFireAra(false) }} onKapat={() => setFireAra(false)} />;
  return (
    <Modal baslik={`▶ ${c('Üret')} — ${emir.mamulAd}`} dar enUst buyutmeYok onKapat={onKapat}
           alt={<><span style={{ marginLeft: 'auto' }} /><button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>
                 <button type="button" className="d yesil" disabled={mesgul || n <= 0} onClick={() => void calistir()}>✔ {c('Üret ve fişi oluştur')}</button></>}>
      <div className="alan-izgara tek-sutun" style={{ padding: 10 }}>
        {hata && <div className="hata-kutusu">{hata}{!eksiyeIzin && /stok|yetmiyor|eksik|yetersiz/i.test(hata) && (
          <div><label className="chk"><input type="checkbox" checked={eksiyeIzin} onChange={e => setEksiyeIzin(e.target.checked)} /> {c('Yine de üret (stok eksiye düşer)')}</label></div>)}</div>}
        <label className="alan"><span className="etiket zorunlu-isaret">{c('Kaç adet üretildi?')}</span><input autoFocus className="sag" value={adet} onChange={e => setAdet(e.target.value)} /></label>
        <label className="alan"><span className="etiket">{c('Tarih')}</span><input type="date" value={tarih} onChange={e => setTarih(e.target.value)} /></label>
        <label className="alan"><span className="etiket">{c('Fire')}</span>
          <span style={{ display: 'flex', gap: 6 }}>
            <button type="button" className="d" onClick={() => setFireAra(true)}>{fireStok ? fireStok.ad : c('malzeme seç…')}</button>
            <input className="sag" style={{ width: 70 }} placeholder={c('adet')} value={fireAdet} onChange={e => setFireAdet(e.target.value)} disabled={!fireStok} /></span></label>
        <div className="sl" style={{ fontSize: 11 }}>{c('Malzemeler ürün ağacından sarf deposundan düşülecek.')} {kalan > n ? `${c('Kalan')} ${sayi.format(kalan - n)} ${c('adet emirde açık kalır.')}` : c('Emir tamamlanır.')}</div>
        {emir.malzemeHazir < 100 && <div className="bilgi-kutusu">⚠ {c('Malzeme hazırlık')} %{emir.malzemeHazir} — {c('eksik malzeme varsa kayıt uyarır.')}</div>}
      </div>
    </Modal>
  );
}

/** ＋ YENİ EMİR — mamul, miktar, termin, not (basit: onay / rezerv yok; emir doğrudan açılır). */
function YeniEmirPenceresi({ onKapat, onBitti }: { onKapat(): void; onBitti(): void }) {
  const [stok, setStok] = useState<{ id: number; ad: string } | null>(null);
  const [ara, setAra] = useState(true);
  const [adet, setAdet] = useState('1');
  const [termin, setTermin] = useState('');
  const [not, setNot] = useState('');
  const [hata, setHata] = useState('');
  const [mesgul, setMesgul] = useState(false);
  const kaydet = async () => {
    const n = Number(adet.replace(',', '.')) || 0;
    if (!stok) { setHata(c('Ürün seçin.')); return }
    if (n <= 0) { setHata(c('Miktar sıfırdan büyük olmalı.')); return }
    setMesgul(true); setHata('');
    try {
      const y = await api.uretimEmriAc({ stokId: stok.id, adet: n, termin: termin || undefined, aciklama: not || undefined });
      mesaj(y.mesaj); onBitti();
    } catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  };
  // Arama penceresi MODALIN DIŞINDA: iki üst-üste perde birbirinin tıklamasını yutuyordu.
  if (ara) return <StokAramaPenceresi etkin yalnizStok tekSecim onSec={(s: ListeSatiri) => { setStok({ id: Number(s.id), ad: String(s.ad ?? '') }); setAra(false) }}
                                       onKapat={() => { setAra(false); if (!stok) onKapat() }} />;
  return (
    <Modal baslik={`＋ ${c('Yeni üretim emri')}`} dar enUst buyutmeYok onKapat={onKapat}
           alt={<><span style={{ marginLeft: 'auto' }} /><button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>
                 <button type="button" className="d bir" disabled={mesgul || !stok} onClick={() => void kaydet()}>💾 {c('Kaydet')}</button></>}>
      <div className="alan-izgara tek-sutun" style={{ padding: 10 }}>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <label className="alan"><span className="etiket zorunlu-isaret">{c('Ürün')}</span>
          <button type="button" className="d" onClick={() => setAra(true)}>{stok ? stok.ad : c('mamul seç…')}</button></label>
        <label className="alan"><span className="etiket zorunlu-isaret">{c('Miktar')}</span><input className="sag" value={adet} onChange={e => setAdet(e.target.value)} /></label>
        <label className="alan"><span className="etiket">{c('Termin')}</span><input type="date" value={termin} onChange={e => setTermin(e.target.value)} /></label>
        <label className="alan"><span className="etiket">{c('Müşteri / not')}</span><input value={not} maxLength={500} onChange={e => setNot(e.target.value)} placeholder={c('ör. Deniz Mobilya siparişi')} /></label>
        <div className="sl" style={{ fontSize: 11 }}>{c('Malzemeler mamulün varsayılan ürün ağacından gelir; ağaç yoksa emir açılmaz.')}</div>
      </div>
    </Modal>
  );
}
