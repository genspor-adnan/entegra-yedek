import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';

/**
 * TALEBİ AMELİYATA PLANLA (715/719).
 *
 * İKİ ENGEL, İKİ AŞAMA. Sunucu önce reddeder: ön hazırlık eksikse ne eksik
 * olduğunu, salon doluysa kimin olduğunu söyler. Kullanıcı ısrar ederse ikinci
 * istekte "rağmen" bayrağı ve gerekçe gider, gerekçe işlem günlüğüne yazılır.
 * Bayrakları baştan göndermek kuralı hiç işletmemek olurdu; engellemek ise
 * acil vakayı planlanamaz kılardı - ikisi de yanlış.
 *
 * SÜRE TALEPTEN GELİR (tahmini süre), ekranda ezilebilir. Sıfır bırakılırsa
 * sunucu 60 dakika sayar - çakışma hesabı sıfır süreyi "hiç masa kullanmıyor"
 * diye okurdu.
 */
interface Salon { id: number; kod: string; ad: string; acilAyrilmis: number }

/** "2026-09-16T08:30" - datetime-local biçimi, YEREL saat. */
const yerelZaman = (t: Date) =>
  new Date(t.getTime() - t.getTimezoneOffset() * 60000).toISOString().slice(0, 16);

export function PlanlamaModali({ talepId, talepNo, hastaAdi, islem, tahminiSure,
                                 eksikler, onKapat, onTamam }: {
  talepId: number;
  talepNo?: string;
  hastaAdi?: string;
  islem?: string;
  /** Talebin tahmini süresi (dk) - 0 ise sunucu 60 sayar. */
  tahminiSure?: number;
  /** Listede hesaplanmış eksik hazırlık metni - kullanıcı baştan görsün. */
  eksikler?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [salonlar, setSalonlar] = useState<Salon[]>([]);
  const [salonId, setSalonId] = useState<number | ''>('');
  const [baslangic, setBaslangic] = useState(() => yerelZaman(new Date()));
  const [sure, setSure] = useState<number>(tahminiSure && tahminiSure > 0 ? tahminiSure : 60);
  const [planDisi, setPlanDisi] = useState(false);
  const [gerekce, setGerekce] = useState('');
  /** Sunucunun reddettiği engeller - ikinci istekte "rağmen" olarak geçilir. */
  const [engel, setEngel] = useState<{ eksik: boolean; cakisma: boolean }>(
    { eksik: false, cakisma: false });
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    try {
      const y = await api.liste('ameliyatSalon', {
        sayfa: 1, boyut: 100,
        filtre: { alan: 'aktif', op: 'esit', deger: 1 },
      });
      const liste = y.satirlar.map(r => ({
        id: Number(r.id), kod: String(r.kod ?? ''), ad: String(r.ad ?? ''),
        acilAyrilmis: Number(r.acilAyrilmis ?? 0),
      })) as Salon[];
      setSalonlar(liste);
      // ACİLE AYRILMIŞ SALON ÖN SEÇİLİ GELMEZ: o masa boş dursun diye
      //   ayrılmıştır, planlı vakayla doldurmak ayırmanın amacını bozar.
      const uygun = liste.find(s => s.acilAyrilmis !== 1) ?? liste[0];
      if (uygun) setSalonId(uygun.id);
    } catch (h) { setHata(hataMetni(h)) }
  }, []);

  useEffect(() => { void yukle() }, [yukle]);

  const kaydet = async () => {
    setHata('');
    if (!salonId) { setHata('Salon seçilmeli.'); return }
    if (engel.eksik && !gerekce.trim()) {
      setHata('Eksik hazırlıkla planlıyorsanız gerekçe yazın.'); return;
    }
    setKaydediyor(true);
    try {
      const y = await api.ameliyatPlanla(talepId, {
        salonId, planBaslangic: baslangic, planSureDk: sure,
        planDisi: planDisi ? 1 : 0,
        eksigeRagmen: engel.eksik, cakismayaRagmen: engel.cakisma,
        gerekce: gerekce.trim() || undefined,
      });
      mesaj(`Ameliyat planlandı${y.ameliyatNo ? `: ${y.ameliyatNo}` : ''}.`
          + ' Güvenli cerrahi kontrol listesi açıldı.');
      onTamam?.();
      onKapat();
    } catch (h) {
      const m = hataMetni(h);
      setHata(m);
      // Sunucunun iki kuralı da mesajla kendini tanıtıyor; "rağmen" düğmesini
      //   yalnız gerçekten o engel çıktığında açıyoruz - her redde zorlama
      //   sunmak, kuralı süsten ibaret yapardı.
      if (m.includes('Ön hazırlık')) setEngel(e => ({ ...e, eksik: true }));
      if (m.includes('aynı saatte')) setEngel(e => ({ ...e, cakisma: true }));
    } finally { setKaydediyor(false) }
  };

  const zorlama = engel.eksik || engel.cakisma;

  return (
    <Modal baslik={`Ameliyata Planla${talepNo ? ` — ${talepNo}` : ''}`} onKapat={onKapat} dar
           alt={
             <>
               <button className={zorlama ? 'd teh' : 'd onay'} disabled={kaydediyor}
                       onClick={() => void kaydet()}>
                 {kaydediyor ? '⏳ Planlanıyor…'
                   : zorlama ? '⚠ Yine de Planla' : '📅 Planla'}
               </button>
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kagrup">
        <h6>Vaka</h6>
        <div className="alan-izgara tek-sutun">
          <label className="alan">
            <span className="etiket">Hasta</span>
            <input readOnly value={hastaAdi ?? ''} />
          </label>
          <label className="alan">
            <span className="etiket">Planlanan İşlem</span>
            <input readOnly value={islem ?? ''} />
          </label>
          {eksikler && (
            <div className="not">
              Eksik ön hazırlık: <b>{eksikler}</b>. Sunucu bu talebi gerekçesiz
              planlamaz - masaya alınıp orada iptal edilmek en pahalı hatadır.
            </div>
          )}
        </div>
      </div>

      <div className="kagrup">
        <h6>Plan</h6>
        <div className="alan-izgara tek-sutun">
          <label className="alan">
            <span className="etiket zorunlu-isaret">Salon</span>
            <select value={salonId}
                    onChange={e => setSalonId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">— seçiniz —</option>
              {salonlar.map(s => (
                <option key={s.id} value={s.id}>
                  {s.kod} · {s.ad}{s.acilAyrilmis === 1 ? ' (acile ayrılmış)' : ''}
                </option>
              ))}
            </select>
          </label>
          <label className="alan">
            <span className="etiket zorunlu-isaret">Tarih / Saat</span>
            <input type="datetime-local" value={baslangic}
                   onChange={e => setBaslangic(e.target.value)} />
          </label>
          <label className="alan">
            <span className="etiket">Süre (dk)</span>
            <span className="ikili">
              <input type="number" min={5} step={5} value={sure}
                     onChange={e => setSure(Number(e.target.value))} />
              <span className="alan-notu">
                {tahminiSure && tahminiSure > 0 ? 'talepten geldi' : 'varsayılan'}
              </span>
            </span>
          </label>
          <label className="alan">
            <span className="etiket">Plan Dışı</span>
            <label className="secim-satiri">
              <input type="checkbox" checked={planDisi}
                     onChange={e => setPlanDisi(e.target.checked)} />
              <span>Plan dışı (acil eklenen) vaka</span>
            </label>
          </label>
          {zorlama && (
            <label className="alan">
              <span className="etiket zorunlu-isaret">Gerekçe</span>
              <input value={gerekce} maxLength={200}
                     placeholder="Neden bu koşulda planlanıyor?"
                     onChange={e => setGerekce(e.target.value)} />
            </label>
          )}
        </div>
        <div className="not">
          Planlanınca talep <b>planlandı</b> olur, talebin işlemi ameliyatın ana
          işlem satırına taşınır ve <b>güvenli cerrahi kontrol listesi</b> o anki
          madde metinleriyle kopyalanır.
        </div>
      </div>
    </Modal>
  );
}
