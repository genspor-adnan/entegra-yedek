import { useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * Randevu kartının ALT ÖZET ŞERİDİ (Ekranlar/randevu_karti.html: "Hasta No ·
 * Son Randevu · Açık Bakiye · Oluşturan").
 *
 * Kartın kendi alanları değil, hastanın BAĞLAMI: kayıt kabul masası randevuyu
 * verirken hastanın geçmişini ve borcunu görsün. Hasta seçili değilken şerit
 * hiç çizilmez - boş etiketler bilgi değil gürültüdür.
 */
export function RandevuOzetSeridi({ hastaId, hariçId, olusturan }: {
  hastaId: number | null;
  /** Düzenlenen randevu, "son randevu" hesabına katılmaz. */
  hariçId?: number | null;
  /** Kartın ekleme tarihi (katalog alanı) - mockup'taki "Oluşturan" bilgisi. */
  olusturan?: string;
}) {
  const [hasta, setHasta] = useState<{ kod: string; bakiye: number } | null>(null);
  const [son, setSon] = useState<string>('');

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
                { alan: 'durum', op: 'esitDegil', deger: 4 },
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
      <span>Hasta No: <b>{hasta?.kod || '—'}</b></span>
      <span>Son Randevu: <b>{son || 'yok'}</b></span>
      <span>Açık Bakiye: <b>
        {(hasta?.bakiye ?? 0).toLocaleString('tr-TR', { minimumFractionDigits: 2 })} ₺
      </b></span>
      {olusturan && (
        <span>Oluşturma: <b>{olusturan.slice(0, 10).split('-').reverse().join('.')}</b></span>
      )}
    </div>
  );
}
