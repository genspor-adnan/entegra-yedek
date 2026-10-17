import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { c } from '../dil/ceviri';

/**
 * Randevu kartının ALT ÖZET ŞERİDİ (Ekranlar/randevu_karti.html: "Hasta No ·
 * Son Randevu · Açık Bakiye · Oluşturan").
 *
 * Kartın kendi alanları değil, hastanın BAĞLAMI: kayıt kabul masası randevuyu
 * verirken hastanın geçmişini ve borcunu görsün. Hasta seçili değilken şerit
 * hiç çizilmez - boş etiketler bilgi değil gürültüdür.
 */
export function RandevuOzetSeridi({ hastaId, hariçId, olusturan, ertelemeIzi }: {
  hastaId: number | null;
  /** Düzenlenen randevu, "son randevu" hesabına katılmaz. */
  hariçId?: number | null;
  /** Kartın ekleme tarihi (katalog alanı) - mockup'taki "Oluşturan" bilgisi. */
  olusturan?: string;
  /** Randevu ertelendi ya da ertelemeyle açıldı (1119): izi listedeki "Erteleme" kolonundan okunur. */
  ertelemeIzi?: boolean;
}) {
  const [hasta, setHasta] = useState<{ kod: string; bakiye: number } | null>(null);
  const [son, setSon] = useState<string>('');
  const [erteleme, setErteleme] = useState('');

  useEffect(() => {
    if (!ertelemeIzi || !hariçId) { setErteleme(''); return }
    let iptal = false;
    api.liste('randevu', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: hariçId } })
      .then(y => { if (!iptal) setErteleme(String(y.satirlar[0]?.erteleme ?? '')) })
      .catch(() => { /* iz bilgisi zorunlu degil */ });
    return () => { iptal = true };
  }, [ertelemeIzi, hariçId]);

  useEffect(() => {
    if (!hastaId) { setHasta(null); setSon(''); return }
    let iptal = false;
    void (async () => {
      try {
        const [hastalar, randevular] = await Promise.all([
          api.liste('hasta', {
            sayfa: 1, boyut: 1,
            filtre: { alan: 'id', op: 'esit', deger: hastaId },
          }),
          api.liste('randevu', {
            sayfa: 1, boyut: 5,
            sirala: [{ alan: 'baslangic', yon: 'desc' }],
            filtre: {
              op: 'and',
              kosullar: [
                { alan: 'hastaId', op: 'esit', deger: hastaId },
                { alan: 'durum', op: 'icinde', deger: [1, 2, 3] },
              ],
            },
          }),
        ]);
        if (iptal) return;
        const h = hastalar.satirlar[0];
        setHasta(h ? { kod: String(h.kod ?? ''), bakiye: Number(h.bakiye ?? 0) } : null);
        const gecmis = randevular.satirlar.find(r => !hariçId || Number(r.id) !== hariçId);
        setSon(gecmis
          ? `${String(gecmis.tarih ?? '').slice(0, 10).split('-').reverse().join('.')}`
            + ` · ${String(gecmis.bolumAdi ?? '')} (${String(gecmis.durumAdi ?? '')})`
          : '');
      } catch { /* ozet bilgisi zorunlu degil - hata kart akisini kesmez */ }
    })();
    return () => { iptal = true };
  }, [hastaId, hariçId]);

  if (!hastaId) return null;

  return (
    <div className="randevu-ozet">
      <span>{c('Hasta No:')}<b>{hasta?.kod || '—'}</b></span>
      <span>{c('Son Randevu:')}<b>{son || 'yok'}</b></span>
      <span>{c('Açık Bakiye:')}<b>
        {(hasta?.bakiye ?? 0).toLocaleString('tr-TR', { minimumFractionDigits: 2 })} ₺
      </b></span>
      {erteleme && <span>{c('Erteleme:')}<b>{erteleme}</b></span>}
      {olusturan && (
        <span>{c('Oluşturma:')}<b>{olusturan.slice(0, 10).split('-').reverse().join('.')}</b></span>
      )}
    </div>
  );
}
