import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * GÖZ ÜNİTESİ KANBANI — mockup `Ekranlar/Goz/goz_unite_panosu.html`.
 *
 * <b>Ünitede iş, hastanın kendisinden çok NEREDE beklediğiyle yönetilir.</b>
 * Grid "kim var" sorusunu cevaplıyordu; "hangi masada yığılma var" sorusunu
 * ancak istasyonlar yan yana durunca cevaplayabiliyorsun.
 *
 * Aynı veriyi gridle PAYLAŞIR (`goz-akis` listesi): ikinci bir uç açmak, aynı
 * ekranda iki farklı "22 dk" üretmenin en kısa yoluydu.
 *
 * <b>SÜRÜKLE-BIRAK tek yol değil, KISA YOLDUR.</b> Kartı sütuna bırakmak
 * hastayı o istasyona alır; aynı işi araç çubuğundaki "İstasyona Al" düğmesi
 * de yapıyor. Dokunmatik ekranda ve ekran okuyucuda sürükleme güvenilmez —
 * yalnız sürüklemeye bağlanan bir pano, tablet kullanan üniteyi ekrandan
 * koparırdı.
 *
 * <b>Taşıma kararını SUNUCU verir:</b> kapanmış satır, aynı istasyona taşıma
 * ve dilatasyon uyarısı orada değerlendirilir. Kanban yalnız isteği yollar ve
 * dönen cümleyi gösterir.
 */

/** Mockuptaki altı istasyon; 6 (tamamlandı) kanbanda sütun değil, hedeftir. */
const ISTASYONLAR = [
  { kod: 1, ad: '1 · Kabul / bekleme' },
  { kod: 2, ad: '2 · Ön tetkik' },
  { kod: 3, ad: '3 · Hekim muayenesi' },
  { kod: 4, ad: '4 · Görüntüleme' },
  { kod: 5, ad: '5 · Karar / işlem' },
] as const;

export interface AkisSatiri {
  id: number;
  hastaId: number;
  /** Ziyarette açılmış göz muayenesi (yoksa 0): "Muayeneyi Aç" buna bakar. */
  gozMuayeneId?: number;
  hasta: string;
  istasyon: number;
  oda: string;
  hekim: string;
  siraNo: number;
  beklemeDk: number;
  dilatasyonHazir: number;
  dilatasyonHazirAdi: string;
  /** Damlanın etkisine kalan dakika (sunucu hesaplar, 20 dk). */
  dilatasyonKalanDk: number | null;
  muayeneTuruAdi: string;
}

/** Dilatasyon süresi (dk) — çubuğun paydası; sunucudaki eşikle aynı. */
const DILATASYON_DK = 20;

export function GozUniteKanban({ yenile, seciliId, onSec, onTasi }: {
  /** Liste tazelendiğinde kanban da tazelensin. */
  yenile?: number;
  seciliId?: number | null;
  /**
   * Seçilen kartın TAMAMI döner, yalnız id değil: araç çubuğu düğmeleri
   * (oda ata, muayeneyi aç) satırın odasına ve muayene kimliğine bakıyor.
   */
  onSec?(satir: AkisSatiri): void;
  /** Kart başka sütuna bırakıldı: (akış satırı, hedef istasyon). */
  onTasi?(satir: AkisSatiri, istasyon: number): void;
}) {
  const [satirlar, setSatirlar] = useState<AkisSatiri[] | null>(null);
  /** Sürüklenen kart ve üzerinde durulan sütun — yalnız görsel geri bildirim. */
  const [surukle, setSurukle] = useState<AkisSatiri | null>(null);
  const [hedef, setHedef] = useState<number | null>(null);

  const yukle = useCallback(async () => {
    // Kanban zorunlu değil: hatası liste akışını kesmemeli.
    try {
      const y = await api.liste('goz-akis', { sayfa: 1, boyut: 200 });
      setSatirlar(y.satirlar as unknown as AkisSatiri[]);
    } catch { /* sessiz */ }
  }, []);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  if (!satirlar) return null;

  return (
    <div className="kanban">
      {ISTASYONLAR.map(ist => {
        const kolon = satirlar.filter(s => s.istasyon === ist.kod);
        // KENDİ SÜTUNUNA BIRAKMA VURGULANMAZ: sunucu da reddediyor, ekran
        //   bunu baştan söylemeli.
        const birakilabilir = !!surukle && surukle.istasyon !== ist.kod;
        return (
          <div key={ist.kod}
               className={`kol${kolon.length >= 3 ? ' dolu' : ''}`
                          + (hedef === ist.kod && birakilabilir ? ' hedef' : '')}
               onDragOver={e => {
                 if (!birakilabilir) return;
                 e.preventDefault();      // bırakmaya izin ver
                 setHedef(ist.kod);
               }}
               onDragLeave={() => setHedef(h => (h === ist.kod ? null : h))}
               onDrop={e => {
                 e.preventDefault();
                 setHedef(null);
                 if (surukle && birakilabilir) onTasi?.(surukle, ist.kod);
                 setSurukle(null);
               }}>
            <div className="kb">{ist.ad}<span className="sp">{kolon.length}</span></div>
            {kolon.length === 0 && <div className="bos">—</div>}
            {kolon.map(s => (
              <div key={s.id}
                   className={`is${s.id === seciliId ? ' secili' : ''}`
                              + (surukle?.id === s.id ? ' suruklenen' : '')}
                   draggable={!!onTasi}
                   onDragStart={e => {
                     setSurukle(s);
                     // Sürükleme verisi metin olarak da taşınır: tarayıcı
                     //   bazı hâllerde boş veriyle sürüklemeyi iptal ediyor.
                     e.dataTransfer.setData('text/plain', String(s.id));
                     e.dataTransfer.effectAllowed = 'move';
                   }}
                   onDragEnd={() => { setSurukle(null); setHedef(null) }}
                   onClick={() => onSec?.(s)}>
                <b>{s.hasta}</b>
                {/* İkinci satır "kim ilgileniyor / nerede": hekim ve oda,
                    hastayı çağıracak kişinin ilk baktığı iki bilgi. */}
                <span className="sonuk">
                  {[s.hekim, s.oda].filter(Boolean).join(' · ') || '—'}
                </span>
                <span className="sonuk">
                  {s.siraNo ? `sıra ${s.siraNo} · ` : ''}{s.beklemeDk} dk
                  {s.muayeneTuruAdi ? ` · ${s.muayeneTuruAdi}` : ''}
                </span>

                {/* DİLATASYON SAYACI ÇUBUKLA (mockup): pano uzaktan okunuyor,
                    "13 dk kaldı" yazısını okumak için yaklaşmak gerekir.
                    Hazır olan yeşile döner. */}
                {s.dilatasyonHazirAdi && (
                  <span className="dilat">
                    <span className={`rozet ${s.dilatasyonHazir ? 'ok' : 'mor'}`}>
                      💧 {s.dilatasyonHazir
                        ? 'hazır'
                        : `${s.dilatasyonKalanDk ?? DILATASYON_DK} dk`}
                    </span>
                    <span className={`dcubuk${s.dilatasyonHazir ? ' hazir' : ''}`}>
                      <i style={{
                        width: `${s.dilatasyonHazir ? 100
                          : Math.round(((DILATASYON_DK - (s.dilatasyonKalanDk ?? DILATASYON_DK))
                                        / DILATASYON_DK) * 100)}%`,
                      }} />
                    </span>
                  </span>
                )}

                {/* Bekleme eşiği: yarım saati geçen hasta kolonun içinde de
                    ayrışsın - kolon sayacı "yığılma var" der, bu satır
                    "kimde" der. */}
                {s.beklemeDk >= 30 && <span className="rozet sari">⏱ uzun bekleme</span>}
              </div>
            ))}
          </div>
        );
      })}
    </div>
  );
}
