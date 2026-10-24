import { useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { Modal } from './Modal';
import { guvenli, mesaj } from './mesaj';
import { RAPOR_ALT_TUR, RAPOR_TUR_SECENEK } from './muayeneKodlari';

/**
 * MUAYENE RAPOR EKLE (kullanici: "eklerken direkt modal açılsın ön bilgilerle,
 * diğer kısımları doldurayım ve kaydedeyim"). Tür şablonu + başlangıç bugün
 * ön dolu gelir; hekim gün/açıklama/ICD'yi doldurup kaydeder. Kayıt TASLAK
 * rapor açar (grid'de belirir, e-İmzala ile onaylanır).
 */
// Tür ve alt tür ORTAK sözlükten (muayeneKodlari): özet penceresi aynı
//   kodları sözlük olarak okuyor, iki liste tutmak ikisinin ayrışmasıydı.
const TURLER = RAPOR_TUR_SECENEK;
const ALT_TURLER = RAPOR_ALT_TUR;

/** YEREL takvim günü "yyyy-mm-dd" (kullanıcı 15.10.2026: "başlama 15 ekim, bitiş 14 ekim geliyor") -
    toISOString UTC'ye çevirir; +03'te yerel gece yarısı bir önceki güne kayıyordu. */
const yerelGun = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const bugun = () => yerelGun(new Date());

export function MuayeneRaporModal({ muayeneId, ilkTur, onKapat, onKaydedildi, rapor }: {
  muayeneId: number;
  ilkTur: number;
  onKapat(): void;
  onKaydedildi(): void;
  /** DÜZENLEME (kullanıcı 15.10.2026: "＋ rapor ekranıyla çift tıklayıp düzenlenen ekran farklı"): mevcut
      rapor satırı - aynı pencere değerleriyle açılır, kayıt güncelleme ucuna gider. */
  rapor?: Record<string, unknown>;
}) {
  const duzenle = rapor?.id != null;
  const [tur, setTur] = useState(duzenle ? Number(rapor!.tur ?? ilkTur) : ilkTur);
  const [altTur, setAltTur] = useState(duzenle ? Number(rapor!.altTur ?? 0) : 0);
  const [baslangic, setBaslangic] = useState(duzenle && rapor!.baslangic ? String(rapor!.baslangic).slice(0, 10) : bugun());
  const [gun, setGun] = useState(duzenle ? Number(rapor!.gun ?? 1) : 1);
  const [aciklama, setAciklama] = useState(duzenle ? String(rapor!.aciklama ?? '') : '');
  const [icdKod, setIcdKod] = useState(duzenle ? String(rapor!.icdKod ?? '') : '');
  const [mesgul, setMesgul] = useState(false);

  // Bitiş = başlangıç + gün - 1 (istirahat başlangıç günü dâhil).
  const bitis = useMemo(() => {
    if (!baslangic || gun <= 0) return '';
    const d = new Date(baslangic + 'T00:00:00');
    d.setDate(d.getDate() + gun - 1);
    return yerelGun(d);
  }, [baslangic, gun]);

  const kaydet = async () => {
    // ALT TÜR ZORUNLU (kullanıcı 15.10.2026) - SGK'ya giden raporda alt tür boş olamaz.
    if (!altTur) { mesaj('Alt tür zorunlu.'); return }
    setMesgul(true);
    await guvenli(async () => {
      const govde = { tur, altTur, baslangic, gun, bitis: bitis || undefined,
                      aciklama: aciklama.trim(), icdKod: icdKod.trim() };
      const y = duzenle ? await api.muayeneRaporGuncelle(Number(rapor!.id), govde)
                        : await api.muayeneRaporEkle(muayeneId, govde);
      mesaj(y.mesaj);
      onKaydedildi();
      onKapat();
    });
    setMesgul(false);
  };

  const kutu: React.CSSProperties = { padding: '7px 9px', fontSize: 14,
    border: '1px solid #cbd5e0', borderRadius: 6, width: '100%' };
  const etiket: React.CSSProperties = { fontSize: 12, fontWeight: 600, color: '#334',
    marginBottom: 3, display: 'block' };

  return (
    <Modal baslik={duzenle ? '📄 Rapor' : '📄 Rapor Ekle'} onKapat={onKapat} dar buyutmeYok
      alt={<>
        <button className="d bir" disabled={mesgul} onClick={() => void kaydet()}>
          💾 Kaydet (Taslak)</button>
        {/* "Kapat" sağa yaslı (kullanıcı 15.10.2026) - diğer kartlardaki gibi. */}
        <button className="d" style={{ marginLeft: 'auto' }} onClick={onKapat}>✖ Kapat</button>
      </>}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, padding: '2px' }}>
        <div>
          <label style={etiket}>Tür (şablon)</label>
          <select style={kutu} value={tur} onChange={e => setTur(Number(e.target.value))}>
            {TURLER.map(t => <option key={t.k} value={t.k}>{t.ad}</option>)}
          </select>
        </div>
        <div>
          <label style={etiket}>Alt tür (SGK) *</label>
          <select style={kutu} value={altTur} onChange={e => setAltTur(Number(e.target.value))}>
            {ALT_TURLER.map(t => <option key={t.k} value={t.k}>{t.k === 0 ? '— seçin —' : t.ad}</option>)}
          </select>
        </div>
        <div>
          <label style={etiket}>Başlangıç</label>
          <input type="date" style={kutu} value={baslangic}
            onChange={e => setBaslangic(e.target.value)} />
        </div>
        <div>
          <label style={etiket}>Gün</label>
          <input type="number" min={0} style={kutu} value={gun}
            onChange={e => setGun(Math.max(0, Number(e.target.value)))} />
        </div>
        <div>
          <label style={etiket}>Bitiş (otomatik)</label>
          <input type="date" style={{ ...kutu, background: '#f3f5f8' }} value={bitis} readOnly />
        </div>
        <div>
          <label style={etiket}>ICD-10 kodu</label>
          <input style={kutu} value={icdKod} onChange={e => setIcdKod(e.target.value)}
            placeholder="ör. J06.9" />
        </div>
        <div style={{ gridColumn: '1 / -1' }}>
          <label style={etiket}>Açıklama</label>
          <textarea style={{ ...kutu, minHeight: 64, resize: 'vertical' }} value={aciklama}
            onChange={e => setAciklama(e.target.value)}
            placeholder="Rapor gerekçesi / notu" />
        </div>
      </div>
      <div className="not ic" style={{ marginTop: 8 }}>
        Kayıt <b>taslak</b> olarak açılır; grid'de belirir ve <b>✍ e-İmzala</b> ile
        onaylanır. İmzalanan rapor değiştirilemez.
      </div>
    </Modal>
  );
}
