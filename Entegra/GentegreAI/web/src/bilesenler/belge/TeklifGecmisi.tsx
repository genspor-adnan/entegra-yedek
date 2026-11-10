import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { BelgeGecmisKaydi } from '../../api/uclar/belge';
import { hataMetni } from '../../api/sozlesme';
import { TEKLIF_DURUMLARI } from '../../sayfalar/belgeSabitleri';
import { c } from '../../dil/ceviri';

/**
 * TEKLİF GEÇMİŞİ (kullanıcı 09.11.2026: "satış teklifine Geçmiş diye bir sekme ekleyip durum/revizyon vb
 * değişimleri orada tutsak"): belgenin `islem_log` olayları - oluşturma, kaydetme, durum değişimi (Sunuldu → Kabul),
 * siparişe dönüşüm, kalem ekleme/silme. Yeni tablo yok; ham log metne burada çevrilir (gecmisOlayi). Revizyon (R1/R2)
 * ileride aynı sekmeye gelir. Şimdilik yalnız teklif kartında (SEKMELER.teklif).
 */

/** Dönüşüm logundaki hedef tür -> olay başlığı. */
const DONUSUM_BASLIGI: Record<string, string> = {
  '19': 'Siparişe dönüştürüldü', '9': 'Alış siparişine dönüştürüldü', '14': 'İrsaliyeye dönüştürüldü',
  '15': 'Faturaya dönüştürüldü', '16': 'Fişe dönüştürüldü', '17': 'Tahakkuka dönüştürüldü',
};

export interface GecmisOlayi { baslik: string; ayrinti: string }

/** Log satırını kullanıcı diline çevirir - saf, test edilir. */
export function gecmisOlayi(k: BelgeGecmisKaydi): GecmisOlayi {
  let b: Record<string, unknown> = {};
  try { b = JSON.parse(k.bilgi || '{}') as Record<string, unknown> } catch { /* bozuk bilgi: ham gösterilir */ }
  const kalem = b.satirAdedi != null && b.satirAdedi !== '' ? `${b.satirAdedi} kalem` : '';
  const aksiyon = String(b.aksiyon ?? '');

  if (k.tabloId !== 30) {
    // Satır / alt kayıt logu (üst = belge): stok adı varsa göster.
    const ad = String(b.stokAdi ?? b.ad ?? b.kalemAdi ?? '');
    const fiil = k.islemTipi === 1 ? 'eklendi' : k.islemTipi === 3 ? 'silindi' : 'değişti';
    return { baslik: `Kalem ${fiil}`, ayrinti: ad };
  }
  if (aksiyon === 'teklif-durum') {
    const [eski, yeni] = String(b.teklifDurum ?? '').split('->').map(x => x.trim());
    const ad = (kod: string) => TEKLIF_DURUMLARI[kod] ?? kod;
    return { baslik: 'Durum değişti', ayrinti: eski && yeni ? `${ad(eski)} → ${ad(yeni)}` : String(b.teklifDurum ?? '') };
  }
  if (aksiyon === 'donustur') {
    const no = k.hedefBelgeNo ? `No ${k.hedefBelgeNo}` : '';
    return { baslik: DONUSUM_BASLIGI[String(b.hedefTur ?? '')] ?? 'Belgeye dönüştürüldü',
             ayrinti: [no, kalem].filter(Boolean).join(' · ') };
  }
  if (aksiyon === 'termin') return { baslik: 'Termin güncellendi', ayrinti: b.yeniTermin ? `${b.yeniTermin}` : kalem };
  // İç onay (1282): sunma / geri çekme belge loguna düşer; kararlar onay loguna (Onay sekmesi).
  if (aksiyon === 'onaya-sun') return { baslik: 'Onaya sunuldu', ayrinti: [b.sonTarih ? `son ${b.sonTarih}` : '', b.not ? `"${b.not}"` : ''].filter(Boolean).join(' · ') };
  if (aksiyon === 'onay-geri-cek') return { baslik: 'Onaydan geri çekildi', ayrinti: '' };
  if (k.islemTipi === 1) return { baslik: 'Teklif oluşturuldu', ayrinti: [b.belgeNo ? `No ${b.belgeNo}` : '', kalem].filter(Boolean).join(' · ') };
  if (k.islemTipi === 3) return { baslik: 'Teklif silindi', ayrinti: b.belgeNo ? `No ${b.belgeNo}` : '' };
  return { baslik: 'Kaydedildi', ayrinti: kalem };
}

const zaman = (iso: string) => {
  const d = new Date(iso);
  if (isNaN(d.getTime())) return iso;
  return d.toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
};

export function TeklifGecmisi({ belgeId }: { belgeId: number }) {
  const [kayitlar, setKayitlar] = useState<BelgeGecmisKaydi[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  useEffect(() => {
    if (!belgeId) { setKayitlar([]); return }
    let iptal = false;
    api.belgeGecmis(belgeId)
      .then(k => { if (!iptal) setKayitlar(k) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [belgeId]);

  if (!belgeId) return <div className="bilgi-kutusu">{c('Geçmiş, teklif kaydedildikten sonra oluşur.')}</div>;
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (kayitlar === null) return <div className="bilgi-kutusu">{c('Yükleniyor…')}</div>;
  if (kayitlar.length === 0) return <div className="bilgi-kutusu">{c('Henüz kayıtlı olay yok.')}</div>;

  return (
    <div className="kutu" data-testid="teklif-gecmis">
      <table className="detay-tablo">
        <thead>
          <tr><th style={{ width: 150 }}>{c('Tarih')}</th><th style={{ width: 180 }}>{c('Kullanıcı')}</th>
              <th style={{ width: 220 }}>{c('Olay')}</th><th>{c('Ayrıntı')}</th></tr>
        </thead>
        <tbody>
          {kayitlar.map(k => {
            const o = gecmisOlayi(k);
            return (
              <tr key={k.id}>
                <td>{zaman(k.tarih)}</td>
                <td>{k.kullanici || '—'}</td>
                <td><b>{c(o.baslik)}</b></td>
                <td>{o.ayrinti}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
