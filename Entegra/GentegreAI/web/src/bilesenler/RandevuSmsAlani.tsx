import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { c } from '../dil/ceviri';
import type { Deger } from './kartAlanCizim';

/**
 * RANDEVU KARTI › SMS (1382, kullanıcı 19.11.2026: "randevu kartına SMS Gönder Check ekle.. default seçili olsun..
 * randevu alan hastaya randevu bilgilerini içeren bir sms atalım.. şubeye özgü olsun mesaj.. istersek mesajı
 * değiştirebilelim.. 1 gün kala hatırlatma mesajı göndereceğiz opsiyonel olarak").
 *
 * "SMS Gönder" işaretliyse kayıtta bilgi SMS'i gider; metin şubenin şablonundan önizlenir, kartta değiştirilebilir
 * (değişen metin `smsMetni` ile kayda gider, boşsa şube şablonu). Şube ayarında hatırlatma açıksa "Hatırlatma SMS'i"
 * ikinci işareti. Gönderim sunucuda (RandevuHatirlatmasi) - aynı randevu saatine bilgi ikinci kez gitmez.
 */
const acikMi = (v: unknown) => v === true || v === 1 || v === '1';

export function RandevuSmsAlani({ deger, alanDegistir, id, salt }: {
  deger: Record<string, unknown>;
  alanDegistir(ad: string, v: Deger): void;
  id: number | null;
  salt: boolean;
}) {
  const [onizleme, setOnizleme] = useState<{ bilgi: string; telefonVar: boolean; hatirlatmaAcik: boolean;
                                             hatirlatmaSaat: number; bilgiGitti: boolean } | null>(null);
  const hastaId = Number(deger.hastaId) || null;
  const baslangic = String(deger.baslangic ?? '');
  const bolum = Number(deger.bolum) || null;
  const hekimId = Number(deger.hekimId) || null;

  // Önizleme kartın alanlarıyla (kaydedilmemiş hâli) - yazarken her tuşta değil, kısa bekleyerek.
  useEffect(() => {
    let iptal = false;
    const z = window.setTimeout(() => {
      api.randevuSmsOnizleme({ randevuId: id, hastaId, baslangic: baslangic || null, bolum, hekimId })
        .then(y => { if (!iptal) setOnizleme(y) })
        .catch(() => { if (!iptal) setOnizleme(null) });
    }, 300);
    return () => { iptal = true; window.clearTimeout(z) };
  }, [id, hastaId, baslangic, bolum, hekimId]);

  const gonder = acikMi(deger.smsGonder);
  const hatirlatma = acikMi(deger.smsHatirlatma);
  const telefonYok = !!hastaId && !!onizleme && !onizleme.telefonVar;
  const gitti = gonder && !!onizleme?.bilgiGitti;
  // İŞARET BANDA TAŞINDI, MESAJ KUTUSU KALKTI (kullanıcı 19.11.2026: "sms gönder check'ini durum rozeti sağına taşı..
  //   mesaj editine gerek yok"): metin her zaman şube şablonu. Bölüm yalnız söylenecek bir şey varsa çizilir.
  if (!onizleme?.hatirlatmaAcik && !telefonYok && !gitti) return null;

  return (
    <div className="kagrup rv-sms">
      <h6>📱 {c('SMS')}</h6>
      {telefonYok && (
        <div className="kucuk rv-sms-uyari">⚠ {c('Hastanın cep telefonu yok - SMS gönderilemez.')}</div>
      )}
      {gitti && (
        <div className="sonuk kucuk">{c('Bu randevu saati için bilgi SMS\'i gönderildi; saat değişirse yeniden gönderilir.')}</div>
      )}
      {onizleme?.hatirlatmaAcik && (
        <label className="rv-sms-isaret">
          <input type="checkbox" checked={hatirlatma} disabled={salt} aria-label={c('Hatırlatma SMS\'i')}
                 onChange={e => alanDegistir('smsHatirlatma', e.target.checked)} />
          {c('Hatırlatma SMS\'i')} <span className="sonuk kucuk">({onizleme.hatirlatmaSaat} {c('saat önce')})</span>
        </label>
      )}
    </div>
  );
}
