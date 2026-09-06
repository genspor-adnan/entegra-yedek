import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { tarihSaat } from './bicim';

/**
 * SONUÇ ONAY ÜST ŞERİDİ (446, mockup Ekranlar/Lab/lab_biyokimya_sonuc_onay.html
 * ".ozet").
 *
 * <b>Sayaç işe giriş kapısıdır</b>, süs değil: çipi olan her kutu tıklanır ve
 * listeyi o süzgeçle açar. Radyoloji panosundaki (320) desenin aynısı.
 *
 * <b>Oto-onay oranı burada duruyor</b> çünkü kuyruğun neden kısa ya da uzun
 * olduğunu tek başına o söyler: oran düştüyse ya kural sıkılaştı ya bir cihaz
 * bayrak basıyor demektir.
 *
 * <b>Cihaz durumu şeritte</b>: cihaz sessizce durduğunda sonuç gelmez ve bu
 * ekranda "onay bekleyen azaldı" gibi görünür - bağı kurmak için yan yana
 * duruyorlar.
 *
 * Sayılar tek uçtan gelir (`GET /api/lab/ozet`); altı ayrı istek hem yavaş
 * hem de şeridin yarısını boş gösterirdi.
 */

/** Kutunun listedeki çip karşılığı; yoksa kutu bilgi olarak kalır. */
interface Kutu {
  anahtar: string;
  etiket: string;
  deger: string;
  alt?: string;
  vurgu?: 'uyari' | 'hata';
  /** `lab-sonuc` çip dizisindeki sıra (listeTanimlari.ts). */
  cip?: number;
}

export function LabOzetSeridi({ yenile, onCip }: {
  /** Liste tazelendiğinde sayaçlar da tazelensin. */
  yenile?: number;
  onCip?(indeks: number): void;
}) {
  const [veri, setVeri] = useState<{
    sayaclar: Record<string, number>; cihazlar: Record<string, unknown>[];
  } | null>(null);

  const yukle = useCallback(async () => {
    // Sayaç şeridi zorunlu değil: hata liste akışını kesmemeli.
    try { setVeri(await api.labOzet()) } catch { /* sessiz */ }
  }, []);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  if (!veri) return null;
  const s = veri.sayaclar;
  const onaylanan = Number(s.bugunOnaylanan ?? 0);
  const oto = Number(s.bugunOtoOnay ?? 0);
  // Payda sıfırken "%0" yazmak yanlış: bugün henüz onay yok demektir.
  const oran = onaylanan > 0 ? Math.round((oto * 100) / onaylanan) : null;

  const kutular: Kutu[] = [
    { anahtar: 'cihazda', etiket: 'Cihazda', deger: String(s.cihazda ?? 0),
      alt: 'tetkik' },
    { anahtar: 'onay', etiket: 'Onay bekliyor', deger: String(s.onayBekleyen ?? 0),
      cip: 0 },
    { anahtar: 'oto', etiket: 'Otomatik onaylanan (bugün)',
      deger: oran === null ? '—' : `%${oran}`,
      alt: oran === null ? 'bugün onay yok' : `${oto}/${onaylanan} · kural geçen` },
    { anahtar: 'panik', etiket: 'Panik açık', deger: String(s.panikAcik ?? 0),
      alt: 'teyit bekliyor', vurgu: Number(s.panikAcik ?? 0) > 0 ? 'hata' : undefined,
      cip: 1 },
    { anahtar: 'tat', etiket: 'TAT aşımı', deger: String(s.tatAsimi ?? 0),
      alt: 'istem', vurgu: Number(s.tatAsimi ?? 0) > 0 ? 'uyari' : undefined },
    { anahtar: 'tekrar', etiket: 'Tekrar numune', deger: String(s.tekrarNumune ?? 0),
      alt: 'yeni numune gerekir',
      vurgu: Number(s.tekrarNumune ?? 0) > 0 ? 'uyari' : undefined, cip: 3 },
  ];

  return (
    <div className="lab-ozet">
      {kutular.map(k => {
        const tiklanir = k.cip !== undefined && !!onCip;
        const govde = (
          <>
            <span className="b">{k.etiket}</span>
            <span className={`d${k.vurgu ? ` ${k.vurgu}` : ''}`}>
              {k.deger}{k.alt && <small>{k.alt}</small>}
            </span>
          </>
        );
        return tiklanir ? (
          <button type="button" className="lab-ozet-kutu" key={k.anahtar}
                  title="Listeyi bu süzgeçle aç"
                  onClick={() => onCip?.(k.cip as number)}>
            {govde}
          </button>
        ) : (
          <div className="lab-ozet-kutu bilgi" key={k.anahtar}>{govde}</div>
        );
      })}

      {/* CİHAZ DURUMU: mockup'taki yeşil/kırmızı rozetler. Son mesaj saati
          rozetin başlığında - "yeşil ama dört saattir susuyor" hâli
          ancak böyle görülür. */}
      <div className="lab-ozet-kutu bilgi">
        <span className="b">Cihaz durumu</span>
        <span className="d cihazlar">
          {veri.cihazlar.length === 0
            ? <small>lab cihazı tanımlı değil</small>
            : veri.cihazlar.map(c => {
                const hata = String(c.sonHata ?? '').trim() !== '';
                return (
                  <span key={String(c.kod)}
                        className={`rozet ${hata ? 'hata' : 'olumlu'}`}
                        title={`${String(c.ad ?? '')}\n`
                             + `son mesaj: ${c.sonMesaj ? tarihSaat(c.sonMesaj) : 'yok'}`
                             + ` · bugün ${String(c.bugunMesaj ?? 0)} mesaj`
                             + (hata ? `\nson hata: ${String(c.sonHata)}` : '')}>
                    {String(c.kod ?? '')}
                  </span>
                );
              })}
        </span>
      </div>
    </div>
  );
}
