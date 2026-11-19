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
  const elle = String(deger.smsMetni ?? '');
  const metin = elle || onizleme?.bilgi || '';

  return (
    <div className="kagrup rv-sms">
      <h6>📱 {c('SMS')}</h6>
      <label className="rv-sms-isaret">
        <input type="checkbox" checked={gonder} disabled={salt} aria-label={c('SMS Gönder')}
               onChange={e => alanDegistir('smsGonder', e.target.checked)} />
        {c('SMS Gönder')} <span className="sonuk kucuk">{c('(kayıtta randevu bilgisi)')}</span>
      </label>
      {hastaId && onizleme && !onizleme.telefonVar && (
        <div className="kucuk rv-sms-uyari">⚠ {c('Hastanın cep telefonu yok - SMS gönderilemez.')}</div>
      )}
      {gonder && onizleme?.bilgiGitti && !elle && (
        <div className="sonuk kucuk">{c('Bu randevu saati için bilgi SMS\'i gönderildi; saat değişirse yeniden gönderilir.')}</div>
      )}
      {gonder && (
        <>
          <textarea className="rv-sms-metin" rows={3} maxLength={500} disabled={salt} value={metin}
                    aria-label={c('SMS metni')}
                    onChange={e => alanDegistir('smsMetni', e.target.value)} />
          <div className="kucuk rv-sms-alt">
            <span className="sonuk">{metin.length} / 500 · {Math.max(1, Math.ceil(metin.length / 153))} SMS</span>
            {elle && !salt && (
              <button type="button" className="d mini" title={c('Şubenin metnine dön')}
                      onClick={() => alanDegistir('smsMetni', '')}>↺ {c('Şube metni')}</button>
            )}
          </div>
        </>
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
