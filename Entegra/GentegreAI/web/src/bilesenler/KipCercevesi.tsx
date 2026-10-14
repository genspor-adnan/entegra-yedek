import type { ReactNode } from 'react';
import { c } from '../dil/ceviri';

/**
 * GÖSTERİM / DÜZENLEME ÇERÇEVESİ (kullanıcı 15.10.2026, muayene: "tanı, istem ve reçete için de
 * aynı deseni yap"). Başlıkta ✎ düzenlemeye geçer; düzenlemede 💾 kaydeder (kart KAPANMAZ) ve
 * gösterime döner. Gösterim mockup v7'deki sade satırlardır; düzenleme ekranın kendi grid/düğmeleri.
 *
 * Kip durumunu çağıran tutar (kart açılınca dolu bölüm gösterimde, boş bölüm düzenlemede açılır).
 */
export function KipCercevesi({ baslik, duzen, onDuzen, onKaydet, gosterim, children, ek }: {
  baslik: string;
  duzen: boolean;
  onDuzen(duzen: boolean): void;
  /** 💾: kartı kapatmadan kaydet. */
  onKaydet?(): void;
  gosterim: ReactNode;
  children: ReactNode;
  /** Başlığın sağına (her iki kipte) ek bilgi, ör. "3/5 sonuç". */
  ek?: ReactNode;
}) {
  return (
    <div className="kasira"><div className={`kagrup${duzen ? '' : ' katlanir-kapali'}`}>
      <h6 className="katlanir-bas" onClick={() => { if (duzen) onKaydet?.(); onDuzen(!duzen) }}>
        {c(baslik)}
        <span className="katlanir-sag" title={duzen ? c('Kaydet ve gösterime dön') : c('Düzenle')}>
          {duzen ? '💾' : '✎'}</span>
        {ek}
      </h6>
      {duzen ? <div className="fm-duzen">{children}</div> : gosterim}
    </div></div>
  );
}
