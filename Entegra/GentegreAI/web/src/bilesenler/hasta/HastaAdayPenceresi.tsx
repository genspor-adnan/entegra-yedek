import { useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { c } from '../../dil/ceviri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { Modal } from '../Modal';

/**
 * KÜÇÜK HASTA ADAY EKRANI (kullanıcı 16.10.2026: "randevu için liste aramadaki yeni butonu küçük bir
 * hasta aday ekranı çıkarsın: ad soyad, tel zorunlu, doğum tar ve cinsiyet zorunlu olmayan").
 *
 * Kayıt "hasta-aday" kartına gider (durum ADAY): kimlik / dosya no kuralları kartla aynı - dosya no
 * cep numarasından türer (kartGovdesi). Doğum tarihi ya da cinsiyet girildiyse hasta bilgisi satırı da
 * yazılır; boşsa sonra tam hasta kartında tamamlanır.
 */
export function HastaAdayPenceresi({ aranan = '', onKapat, onKaydedildi }: {
  /** Aramaya yazılan metin: rakamsa telefona, değilse ada ön dolar. */
  aranan?: string;
  onKapat(): void;
  onKaydedildi(h: { id: number; unvan: string }): void;
}) {
  const { kullanici } = useOturum();
  const rakam = /^[\d\s+()-]{7,}$/.test(aranan.trim());
  const [ilkAd, ...kalan] = rakam ? [''] : aranan.trim().split(/\s+/);
  const [ad, setAd] = useState(ilkAd ?? '');
  const [soyad, setSoyad] = useState(kalan.join(' '));
  const [tel, setTel] = useState(rakam ? aranan.trim() : '');
  const [dogum, setDogum] = useState('');
  const [cinsiyet, setCinsiyet] = useState('');
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);

  const kaydet = async () => {
    if (!ad.trim() || !soyad.trim()) { setHata(c('Ad ve soyad zorunlu.')); return }
    if (tel.replace(/\D/g, '').length < 10) { setHata(c('Telefon zorunlu (en az 10 rakam).')); return }
    if (!!dogum !== !!cinsiyet) { setHata(c('Doğum tarihi ve cinsiyet birlikte girilir - ikisini de girin ya da ikisini de boş bırakın.')); return }
    setHata(null); setMesgul(true);
    try {
      const unvan = `${ad.trim()} ${soyad.trim()}`;
      const y = await api.kartEkle('hasta-aday', {
        kart: {
          ad: ad.trim(), soyad: soyad.trim(), unvan, cepTel: tel.trim(), kod: tel.trim(),
          grup: 101, hasta: 1, musteri: 1, durum: 2, subeId: kullanici?.subeId ?? null,
        },
        // Hasta bilgisi satırı (taraf_hasta) YALNIZ ikisi birlikte varsa: veritabanı satırda cinsiyet
        //   (E/K) ve doğum tarihini zorunlu tutar (480) - aday satırsız açılır, tam kartta tamamlanır.
        ...(dogum && cinsiyet ? { detaylar: { ozluk: { eklenen: [{ dogumTarihi: dogum, cinsiyet: Number(cinsiyet) }] } } } : {}),
      });
      onKaydedildi({ id: Number(y.kart.id), unvan });
    } catch (h) { setHata(hataMetni(h)) }
    finally { setMesgul(false) }
  };

  const etiket: React.CSSProperties = { display: 'flex', flexDirection: 'column', gap: 4, fontSize: 12, fontWeight: 600, color: '#3a4a5a' };
  const kutu: React.CSSProperties = { height: 32, padding: '0 10px', border: '1px solid #cbd5e0', borderRadius: 5, fontSize: 13, fontWeight: 'normal' };
  return (
    <Modal baslik={`🧑 ${c('Yeni Hasta (Aday)')}`} dar enUst buyutmeYok onKapat={onKapat}
           alt={<>
             <button type="button" className="d bir" disabled={mesgul} onClick={() => void kaydet()}>💾 {c('Kaydet ve Seç')}</button>
             <button type="button" className="d" style={{ marginLeft: 'auto' }} onClick={onKapat}>{c('Kapat')}</button>
           </>}>
      <form onSubmit={e => { e.preventDefault(); void kaydet() }}
            style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, minWidth: 380 }}>
        <label style={etiket}>{c('Ad')} *<input style={kutu} value={ad} autoFocus={!ad} onChange={e => setAd(e.target.value)} maxLength={50} /></label>
        <label style={etiket}>{c('Soyad')} *<input style={kutu} value={soyad} onChange={e => setSoyad(e.target.value)} maxLength={60} /></label>
        <label style={{ ...etiket, gridColumn: '1 / -1' }}>{c('Telefon')} *
          <input style={kutu} value={tel} inputMode="tel" autoFocus={!!ad && !tel} placeholder="05xx xxx xx xx"
                 onChange={e => setTel(e.target.value)} maxLength={30} /></label>
        <label style={etiket}>{c('Doğum tarihi')}<input style={kutu} type="date" value={dogum} onChange={e => setDogum(e.target.value)} /></label>
        <label style={etiket}>{c('Cinsiyet')}
          <select style={kutu} value={cinsiyet} onChange={e => setCinsiyet(e.target.value)}>
            <option value="">—</option><option value="2">{c('Kadın')}</option><option value="1">{c('Erkek')}</option>
          </select></label>
        <p className="not" style={{ gridColumn: '1 / -1', margin: 0 }}>
          {c('Aday kayıt: kimlik ve diğer bilgiler hasta geldiğinde tam hasta kartında tamamlanır.')}</p>
        {hata && <div className="hata-kutusu" style={{ gridColumn: '1 / -1' }}>{hata}</div>}
        <button type="submit" hidden />
      </form>
    </Modal>
  );
}
