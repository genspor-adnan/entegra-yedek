import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { UretimSeviyesi } from '../../api/uclar/uretimFisi';
import { uretimSeviyesiOnbellegiTemizle } from '../../bilesenler/useUretimSeviyesi';
import { onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';

/**
 * ÜRETİM SEVİYESİ AYARI (1253, mockup uretim_basit.html ③ "Kurum Profili › Üretim"). Kurum profili ekranı bu üründe
 * GenProfil'de olduğu için ayar önce Genel Ayarlar › Üretim sekmesindeydi; 04.11.2026'dan beri Üretim › Ayarlar ›
 * Üretim Ayarları sayfasında (UretimAyarlar, 1262). Üç kart + "Üretim emri kullan" + karşılaştırma tablosu.
 * Alta geçiş sunucuda kapılı: açık emir ya da karantinadaki fiş varken denetimliden inilmez.
 */
const SEVIYELER: { kod: UretimSeviyesi; ad: string; alt: string; aciklama: string }[] = [
  { kod: 'basit', ad: 'Basit', alt: 'KOBİ', aciklama: 'Tek ekran fiş · emir isteğe bağlı · fire tek alan · işçilik tek tutar' },
  { kod: 'standart', ad: 'Standart', alt: 'maliyet takibi', aciklama: 'Emir akışı · kısmi giriş · operasyon süreleri · plan / gerçek maliyet · lot' },
  { kod: 'denetimli', ad: 'Denetimli', alt: 'tıbbi cihaz / ilaç / gıda', aciklama: 'Ön kontroller · karantina · kalite · e-imza (parola) · izlenebilirlik · denetim izi' },
];

const TABLO: [string, string, string, string][] = [
  ['Üretim emri kullan', 'kapalı (açılabilir)', 'açık', 'açık · zorunlu'],
  ['Malzeme eksikken kaydet', 'uyarıyla izin', 'yetkiyle', 'yok'],
  ['Farklı giriş deposu', 'gizli (bağlantıyla)', 'açık', 'açık · karantina'],
  ['Lot / seri', 'stok kartında izleme varsa', 'açık', 'zorunlu (FEFO)'],
  ['İşçilik / gider', 'tek tutar (ağaçtan)', 'operasyonlardan', 'operasyonlardan'],
  ['Fire', 'tek alan · normal', 'normal / anormal', 'normal / anormal'],
  ['Sil', '"Sil" → ters kayıt (stok geri döner, iz kalır)', '"Sil" → ters kayıt', '"Ters Kayıt" (gerekçe zorunlu)'],
  ['Emir başlatma', 'yok (Üret… fiş keser)', 'Onayla → Başlat', 'Onayla → Serbest Bırak (ön kontrol + imza) → Başlat'],
  ['Maliyet (IAS 2)', 'her seviyede aynı: malzeme + işçilik + normal fire − yan ürün; anormal fire gidere', '', ''],
];

export function UretimSeviyeAyari() {
  const [seviye, setSeviye] = useState<UretimSeviyesi>('basit');
  const [emirKullan, setEmirKullan] = useState(false);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [mesgul, setMesgul] = useState(false);

  useEffect(() => { void api.uretimSeviye().then(y => { setSeviye(y.seviye); setEmirKullan(y.emirKullan) }).catch(h => setHata(hataMetni(h))) }, []);

  const yaz = async (s: UretimSeviyesi, e: boolean) => {
    if (s !== seviye && ['denetimli', 'standart', 'basit'].indexOf(s) > ['denetimli', 'standart', 'basit'].indexOf(seviye)
        && !await onay(c('Alt seviyeye geçiliyor: ekrandan bazı alanlar kalkar, kayıtlar bozulmaz. Açık emir ya da kalite bekleyen fiş varsa sunucu geçişi reddeder. Devam?'))) return;
    setMesgul(true); setHata('');
    try {
      const y = await api.uretimSeviyeYaz(s, e);
      setSeviye(y.seviye); setEmirKullan(y.emirKullan);
      uretimSeviyesiOnbellegiTemizle();
      setBilgi(c('Üretim seviyesi kaydedildi. Menü hemen güncellenir; açık üretim ekranları yeniden açılınca yeni düzeni gösterir.'));
      setTimeout(() => setBilgi(''), 4000);
    } catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  };

  return (
    <>
      <style>{USA_STILI}</style>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}
      <div className="kagrup">
        <h6>{c('Üretim seviyesi')}</h6>
        <div className="usa-ayar">
          {SEVIYELER.map(s => (
            <button type="button" key={s.kod} className={`sec${seviye === s.kod ? ' on' : ''}`} disabled={mesgul} onClick={() => void yaz(s.kod, emirKullan)}>
              <b>{seviye === s.kod ? '◉' : '○'} {c(s.ad)} <small>{c(s.alt)}</small></b><span>{c(s.aciklama)}</span>
            </button>))}
        </div>
        <div className="usa-emir">
          <label className="chk"><input type="checkbox" checked={emirKullan} disabled={mesgul || seviye !== 'basit'} onChange={e => void yaz(seviye, e.target.checked)} /> {c('Üretim emri kullan')}</label>
          <span className="sl">{seviye === 'basit'
            ? c('Kapalıysa menüde yalnız Üretim Fişi görünür; açıksa Üretim Emirleri sade iş listesidir ("Üret…" fişi keser).')
            : c('Standart ve Denetimli seviyede üretim emri her zaman açıktır.')}</span>
        </div>
        <table className="usa-tablo">
          <thead><tr><th>{c('Seçenek')}</th><th>{c('Basit')}</th><th>{c('Standart')}</th><th>{c('Denetimli')}</th></tr></thead>
          <tbody>{TABLO.map(([a, b, s, d]) => <tr key={a}><td>{c(a)}</td>{s === '' && d === '' ? <td colSpan={3}>{c(b)}</td> : <><td>{c(b)}</td><td>{c(s)}</td><td>{c(d)}</td></>}</tr>)}</tbody>
        </table>
        <div className="sl usa-not">{c('Ekran ve kayıt yapısı tektir; seviye yalnız görüneni ve zorunlulukları değiştirir. Üst seviyeye geçişte eski kayıtlar bozulmaz, yeni alanlar boş başlar. Alta geçiş: açık emir ya da karantinadaki fiş varken engellenir.')}</div>
      </div>
    </>
  );
}

const USA_STILI = `
.usa-ayar { display:grid; grid-template-columns:repeat(3,1fr); gap:8px; padding:10px }
.usa-ayar .sec { border:1px solid var(--cizgi2,#e3e9f0); border-radius:6px; padding:8px 10px; display:flex; flex-direction:column; gap:3px; cursor:pointer; background:#fff; text-align:left; font:inherit }
.usa-ayar .sec b small { font-weight:400; color:var(--soluk,#6b7a8b); margin-left:4px } .usa-ayar .sec span { color:var(--soluk,#6b7a8b); font-size:11px }
.usa-ayar .sec.on { border-color:var(--mavi,#2f6db3); background:#f3f8fe }
.usa-emir { display:flex; gap:10px; align-items:center; padding:0 10px 10px; flex-wrap:wrap; font-size:12px } .usa-emir .chk { display:inline-flex; gap:6px; align-items:center; font-weight:600 }
.usa-tablo { border-collapse:collapse; width:calc(100% - 20px); margin:0 10px 8px; border:1px solid var(--cizgi2,#e3e9f0); font-size:11px }
.usa-tablo th { background:linear-gradient(#f4f7fb,#e7eef6); border-bottom:1px solid var(--cizgi,#cdd6e0); border-right:1px solid var(--cizgi2,#e3e9f0); text-align:left; padding:5px 8px; color:#3a5573 }
.usa-tablo td { border-bottom:1px solid var(--cizgi2,#e3e9f0); border-right:1px solid #eef2f6; padding:4px 8px }
.usa-not { font-size:10.5px; padding:0 10px 10px } .sl { color:var(--soluk,#6b7a8b) }
`;
