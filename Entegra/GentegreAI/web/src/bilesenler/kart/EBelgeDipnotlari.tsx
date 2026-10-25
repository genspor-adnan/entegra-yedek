import { useState } from 'react';
import { Modal } from '../Modal';
import { c } from '../../dil/ceviri';
import type { KartAlanMeta } from '../../api/sozlesme';

/**
 * CARİYE ÖZEL e-BELGE DİPNOTU (1187, kullanıcı 25.10.2026: "müşteri kartında e-Belge Ayarları'na müşteriye özel
 * e-Fatura Dipnotu ve e-İrsaliye Dipnotu girişi ekle" + "dipnot girişi için modal açılsın").
 *
 * Kutuda iki düğme (dolu / boş rozetiyle); düğme modal açar, metin "Tamam" ile kartın değerine yazılır ve kartın
 * kendi Kaydet'iyle saklanır. Doluysa e-Belge hazırlamada türün genel sabit notlarının YERİNE kullanılır
 * (EFaturaServisi.NotlarAsync) - aynı {ALAN} yer tutucuları.
 */
const YER_TUTUCULAR = '{ACIKLAMA} belge açıklaması · {BELGENO} e-Belge no · {TARIH} belge tarihi · {UNVAN} alıcı ünvanı · {PaymentTotalAsText} yazıyla tutar';

export function EBelgeDipnotlari({ alanlar, deger, saltOkunur, onDegis }: {
  alanlar: KartAlanMeta[];
  deger: Record<string, unknown>;
  saltOkunur: boolean;
  onDegis(ad: string, metin: string): void;
}) {
  const [acik, setAcik] = useState<KartAlanMeta | null>(null);
  const [metin, setMetin] = useState('');
  if (alanlar.length === 0) return null;

  const ac = (a: KartAlanMeta) => { setMetin(String(deger[a.ad] ?? '')); setAcik(a) };
  const yaz = !saltOkunur && !!acik?.yazilabilir;

  return (
    <div className="adres-satir">
      {alanlar.map(a => {
        const dolu = String(deger[a.ad] ?? '').trim().length > 0;
        return (
          <label className="alan tip-metin" key={a.ad}>
            <span className="etiket">{c(a.baslik)}</span>
            <span>
              <button type="button" className="d" onClick={() => ac(a)}>✎ {c(dolu ? 'Düzenle…' : 'Gir…')}</button>
              {/* Genel dipnot kartta anılmaz (kullanıcı 25.10.2026: "müş kartından genel dipnotu kaldır") - o şube
                  ayarlarındadır; burada yalnız doluysa "cariye özel" rozeti. */}
              {dolu && <>{' '}<span className="rozet ok">{c('cariye özel')}</span></>}
            </span>
          </label>
        );
      })}
      {acik && (
        <Modal baslik={c(acik.baslik)} dar buyutmeYok enUst onKapat={() => setAcik(null)}
               alt={
                 <>
                   <button type="button" className="d" onClick={() => setAcik(null)}>✖ {c('Vazgeç')}</button>
                   {yaz && <button type="button" className="d" onClick={() => setMetin('')}>{c('Temizle')}</button>}
                   {yaz && (
                     <button type="button" className="d bir"
                             onClick={() => { onDegis(acik.ad, metin); setAcik(null) }}>✔ {c('Tamam')}</button>
                   )}
                 </>
               }>
          <div style={{ padding: 12, display: 'grid', gap: 8 }}>
            <div className="not">
              {c('Bu cariye kesilen belgenin dipnotu. Vergi notları (istisna / tevkifat) her durumda eklenir. Kartı Kaydet ile saklayın.')}
            </div>
            <textarea rows={10} value={metin} maxLength={acik.enFazlaUzunluk ?? 1000} disabled={!yaz} autoFocus
                      onChange={e => setMetin(e.target.value)} style={{ width: '100%', resize: 'vertical' }} />
            <div className="not">{c('Kullanılabilir alanlar')}: {YER_TUTUCULAR}</div>
          </div>
        </Modal>
      )}
    </div>
  );
}
