import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { KullaniciOzeti } from '../api/uclar/ayar';

/**
 * KULLANICILAR ÜST ŞERİDİ (mockup `Ekranlar/Ayarlar/kullanicilar.html` `.ozet`).
 *
 * <b>Şerit ARAMA KUTUSUNUN ÜSTÜNDE</b> (kullanıcı: "arama editi üstüne daha
 * iyi"): arama kutusu "ne arıyorum"u sorar, kutular "neye bakmam gerek"i
 * söyler - ekrana girildiğinde önce ikincisi okunmalı.
 *
 * <b>Sayaç bir giriş kapısıdır</b>, süs değil: çipi olan her kutu tıklanır ve
 * listeyi o süzgeçle açar (lab sonuç onay şeridindeki desenin aynısı).
 *
 * Kutuların seçimi "kaç hesap var" değil <b>"bakılmamış ne kaldı"</b>:
 *  · Parolasız → hesaba kim girerse girsin, parolayı kişi henüz koymadı.
 *  · Kilitli → hatalı giriş; kendiliğinden çözülür ama bekleyen kişi arar.
 *  · 90 gün girmemiş → açılıp kullanılmayan hesap, kilitliden daha sessiz risk.
 *  · Hesabı olmayan personel → kişi giriş yapmayı deneyene kadar fark edilmez.
 */
export function KullaniciOzetSeridi({ yenile, onCip }: {
  /** Liste tazelendiğinde sayaçlar da tazelensin. */
  yenile?: number;
  /** `kullanici` çip dizisindeki sıraya götürür (listeTanimlari.Yonetim.ts). */
  onCip?(indeks: number): void;
}) {
  const [o, setO] = useState<KullaniciOzeti | null>(null);

  const yukle = useCallback(async () => {
    // Sayaç şeridi zorunlu değil: hatası liste akışını kesmemeli.
    try { setO(await api.kullaniciOzet()) } catch { /* sessiz */ }
  }, []);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  if (!o) return null;

  const kutular: {
    anahtar: string; etiket: string; deger: number; alt: string;
    vurgu?: 'uyari' | 'hata'; cip?: number;
  }[] = [
    { anahtar: 'aktif', etiket: 'Aktif hesap', deger: o.aktif,
      alt: o.pasif === 0 ? `${o.toplam} hesabın hepsi aktif`
                         : `${o.toplam} hesabın ${o.pasif}'i pasif`,
      cip: 0 },
    { anahtar: 'parolasiz', etiket: 'Parolasız', deger: o.parolasiz,
      alt: 'ilk girişte belirleyecek',
      // SIFIRKEN NÖTR: her zaman sarı duran kutu, gerçekten sarı olduğunda
      //   fark edilmez.
      vurgu: o.parolasiz > 0 ? 'uyari' : undefined, cip: 2 },
    { anahtar: 'kilitli', etiket: 'Kilitli', deger: o.kilitli,
      alt: 'hatalı giriş', vurgu: o.kilitli > 0 ? 'hata' : undefined, cip: 3 },
    { anahtar: 'uykuda', etiket: '90 gün girmemiş', deger: o.uykuda,
      alt: 'gözden geçirin' },
    { anahtar: 'hesapsiz', etiket: 'Hesabı olmayan personel', deger: o.hesapsiz,
      alt: `aktif personel · ${o.personel}`,
      vurgu: o.hesapsiz > 0 ? 'uyari' : undefined },
    { anahtar: 'oturum', etiket: 'Açık oturum', deger: o.oturum,
      alt: `${o.oturumKisi} kullanıcı` },
  ];

  return (
    <div className="kul-ozet">
      {kutular.map(k => {
        const govde = (
          <>
            <span className="bas">{k.etiket}</span>
            <span className={`deg${k.vurgu ? ` ${k.vurgu}` : ''}`}>
              {k.deger.toLocaleString('tr')}
            </span>
            <span className="alt">{k.alt}</span>
          </>
        );
        return k.cip !== undefined && onCip ? (
          <button type="button" className="k" key={k.anahtar}
                  title="Listeyi bu süzgeçle aç"
                  onClick={() => onCip(k.cip as number)}>
            {govde}
          </button>
        ) : (
          <div className="k bilgi" key={k.anahtar}>{govde}</div>
        );
      })}
    </div>
  );
}
