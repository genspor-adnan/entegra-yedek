import { useState } from 'react';
import type { KartDetayMeta } from '../../api/sozlesme';
import { DokumanGalerisi } from '../DokumanGalerisi';
import { tarihYaz } from '../bicim';

/**
 * PERSONEL BELGE DOSYASI (1136): personel kartı "Belgeler" sekmesinin altında
 * belgenin taraması (diploma, rapor...). Dosya SATIRA bağlıdır (dokuman
 * 'personel-belge', kaynak_id = personel_belge.id) - belge türü "dosyası
 * zorunlu" ise dosyasız satır Belge Durumu'nda "Dosya yok" görünür.
 *
 * Belgeler gridi satır içi düzenlenir (satır seçimi yok); hangi belgenin
 * dosyasına bakıldığı buradaki düğmelerle seçilir. Yeni satır kaydedilmeden
 * kimliği olmadığı için dosya alamaz.
 */
export function PersonelBelgeDosyalari({ meta, satirlar, saltOkunur }: {
  meta: KartDetayMeta;
  satirlar: Record<string, unknown>[];
  saltOkunur: boolean;
}) {
  const kayitli = satirlar.filter(s => Number(s.id) > 0);
  const turAdlari = meta.alanlar.find(a => a.ad === 'belgeTuruId')?.kodlar ?? {};
  const [seciliId, setSeciliId] = useState<number | null>(null);
  // Galeride yükleme / silme sonrası sayı: grid sayısı kart açılışındaki değerdir.
  const [sayilar, setSayilar] = useState<Record<number, number>>({});
  const id = kayitli.some(s => Number(s.id) === seciliId) ? seciliId! : Number(kayitli[0]?.id ?? 0);
  const yeniVar = kayitli.length < satirlar.length;

  return (
    <div style={{ marginTop: 10, border: '1px solid var(--cizgi)', borderRadius: 4 }}>
      <div style={{ padding: '6px 10px', background: 'var(--grupzem)', color: 'var(--grupyazi)', fontWeight: 700 }}>
        📎 Belge dosyaları
      </div>
      {kayitli.length === 0 ? (
        <div style={{ padding: 10, color: 'var(--soluk)' }}>
          {yeniVar ? 'Dosya eklemek için önce kartı kaydedin.' : 'Henüz belge girilmedi.'}
        </div>
      ) : (
        <>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, padding: '8px 10px' }}>
            {kayitli.map(s => {
              const sid = Number(s.id);
              const sayi = sayilar[sid] ?? Number(s.dosyaSayisi ?? 0);
              const tarih = s.belgeTarihi ? tarihYaz(String(s.belgeTarihi)) : '';
              return (
                <button key={sid} type="button" className={sid === id ? 'cip on' : 'cip'}
                        aria-pressed={sid === id}
                        title={[s.belgeNo, tarih].filter(Boolean).join(' · ') || undefined}
                        onClick={() => setSeciliId(sid)}>
                  {turAdlari[String(s.belgeTuruId)] ?? `Belge #${sid}`}
                  {' '}<span style={{ opacity: .75 }}>{sayi > 0 ? `📎 ${sayi}` : '— dosya yok'}</span>
                </button>
              );
            })}
          </div>
          {yeniVar && (
            <div style={{ padding: '0 10px 6px', color: 'var(--soluk)' }}>
              Yeni eklenen satırlara dosya kart kaydedildikten sonra eklenebilir.
            </div>
          )}
          {id > 0 && <DokumanGalerisi key={id} kartAdi="personelBelge" kaynakId={id} saltOkunur={saltOkunur}
                                     onSayi={n => setSayilar(o => o[id] === n ? o : { ...o, [id]: n })} />}
        </>
      )}
    </div>
  );
}
