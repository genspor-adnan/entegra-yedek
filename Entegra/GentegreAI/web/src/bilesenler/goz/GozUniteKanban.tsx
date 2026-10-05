import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { Kosul } from '../../api/sozlesme';
import { GOZ_KANBAN_SUTUNLARI, GOZ_PANO_ESIK } from './gozPanoSabitleri';

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

const ISTASYONLAR = GOZ_KANBAN_SUTUNLARI;

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
  /** Süreç v2: "açılmadı" / "#id açık" / "tamamlandı". */
  muayeneDurum?: string;
  // ---- 976 (mockup kart ayrıntıları) ----
  /** Çağrıldı ve kaynağı atandı: hasta ŞU AN masada (kart vurgulu). */
  islemde?: number;
  cagrildi?: number;
  /** Acil muayene türü - sıraya göre değil, aciliyete göre çağrılır. */
  acil?: number;
  /** 16 yaş altı: refakatçi ve ayrı yaklaşım gerektiriyor. */
  cocuk?: number;
  yas?: number | null;
  cinsiyet?: number | null;
  /** "Otoref ✔ · Tonometri —": hekime almadan önce bakılan tek şey. */
  onTetkik?: string;
  /** "GİB 26/24 · otoref −2,25 / −2,00". */
  olcumOzet?: string;
  /** Tanımlı oda / cihaz (976) - serbest metin yerine. */
  kaynakId?: number | null;
}

const { dilatasyonDk: DILATASYON_DK, beklemeKritikDk: BEKLEME_KRITIK } = GOZ_PANO_ESIK;

export function GozUniteKanban({ yenile, seciliId, filtre, onSec, onTasi }: {
  /** Liste tazelendiğinde kanban da tazelensin. */
  yenile?: number;
  seciliId?: number | null;
  /**
   * 976: ŞERİT ÇİPLERİ VE SOL PANEL KANBANI DA SÜZER. Kanban kendi isteğini
   * süzgeçsiz atarken "Geciken" çipi gridi süzüyor, kanban dolu kalıyordu -
   * kullanıcı için pano süzgeci çalışmıyor demekti.
   */
  filtre?: Kosul;
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
      const y = await api.liste('goz-akis', { sayfa: 1, boyut: 200, filtre });
      setSatirlar(y.satirlar as unknown as AkisSatiri[]);
    } catch { /* sessiz */ }
  }, [filtre]);

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
                              + (surukle?.id === s.id ? ' suruklenen' : '')
                              // ŞU AN İŞLEMDE olan kart vurgulu (mockup `.simdi`):
                              //   bekleyenle aynı görünen kart, sırayı
                              //   olduğundan uzun gösteriyor.
                              + (s.islemde ? ' simdi' : '')
                              + (s.acil ? ' acil' : '')}
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
                <b>{s.hasta}
                  {/* YAŞ VE CİNSİYET ADIN YANINDA (mockup "39 K"): çocuk
                      hastaya yaklaşım farklı, karta bakan bunu adla birlikte
                      okumalı. */}
                  {s.yas ? <span className="gk-yas"> {s.yas}{s.cinsiyet === 1 ? ' E' : s.cinsiyet === 2 ? ' K' : ''}</span> : null}
                </b>
                {/* ACİL VE ÇOCUK ROZETİ: sıraya göre değil, önceliğe göre
                    çağrılan iki durum. */}
                {/* SAYI İLE && KULLANILMAZ: `0 && ...` JSX'te "0" basıyor -
                    kartta adın altında sebepsiz bir sıfır çıkıyordu. */}
                {(s.acil || s.cocuk) ? (
                  <span className="gk-rozetler">
                    {s.acil ? <span className="rozet hata">acil</span> : null}
                    {s.cocuk ? <span className="rozet mor">çocuk</span> : null}
                  </span>
                ) : null}
                {/* İkinci satır "kim ilgileniyor / nerede": hekim ve oda,
                    hastayı çağıracak kişinin ilk baktığı iki bilgi. */}
                <span className="sonuk">
                  {[s.hekim, s.oda].filter(Boolean).join(' · ') || '—'}
                </span>
                {/* ÖN TETKİK ve ÖLÇÜM: mockup kartta "Otoref ✔ · Tonometri —"
                    ve "GİB 26/24" yazıyor - hastayı hekime almadan önce
                    bakılan iki satır. Ölçüm yoksa satır çizilmez. */}
                {s.istasyon === 2 && s.onTetkik && <span className="sonuk">{s.onTetkik}</span>}
                {s.olcumOzet && <span className="sonuk">{s.olcumOzet}</span>}
                <span className="sonuk">
                  {s.siraNo ? `sıra ${s.siraNo} · ` : ''}{s.beklemeDk} dk
                  {s.muayeneTuruAdi ? ` · ${s.muayeneTuruAdi}` : ''}
                </span>
                {s.muayeneDurum && (
                  <span className={`rozet ${s.muayeneDurum === 'açılmadı' ? 'pas' : s.muayeneDurum === 'tamamlandı' ? 'ok' : 'mavi'}`}
                        style={{ alignSelf: 'flex-start' }}>
                    👁 {s.muayeneDurum}
                  </span>
                )}

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
                {s.beklemeDk >= BEKLEME_KRITIK && <span className="rozet sari">⏱ uzun bekleme</span>}
                {/* ÇAĞRILDI AMA GELMEDİ ile KİMSE ÇAĞIRMADI ayrı görünür (702):
                    ikisi aynı görünürse sıra kimsede kalmıyor. */}
                {!s.islemde && s.cagrildi
                  ? <span className="rozet mavi">📢 çağrıldı</span>
                  : null}
              </div>
            ))}
          </div>
        );
      })}
    </div>
  );
}
