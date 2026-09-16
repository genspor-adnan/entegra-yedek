import { useCallback, useEffect, useState } from 'react';
import { api, } from '../../api/istemci';
import type { AmeliyatKontrolSatiri } from '../../api/uclar/ameliyathane';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';

/**
 * GÜVENLİ CERRAHİ KONTROL LİSTESİ (DSÖ · 715).
 *
 * ÜÇ AŞAMA AYRI BAŞLIKLARDA, çünkü üçü ayrı anlarda ve ayrı kişilerle
 * yapılıyor: sign-in anestezi öncesi, time-out kesiden hemen önce, sign-out
 * hasta salondan çıkmadan. Tek düz liste olsaydı ekip "hepsini sonunda
 * işaretleyelim" derdi - listenin bütün değeri o üç duruştan geliyor.
 *
 * TIME-OUT (aşama 2) EKSİKSE KESİ KAYDEDİLMEZ; burada da ayrıca gösteriliyor
 * ki kullanıcı redde takılmadan önce görsün.
 *
 * TOPLU KAYDEDİLİR: madde başına istek atsaydık, kopan bir bağlantı yarım
 * işaretlenmiş bir time-out bırakır ve kesiyi haksız yere serbest bırakabilirdi.
 */
const ASAMA_ADI: Record<number, string> = {
  1: '1 · Sign-in (anestezi öncesi)',
  2: '2 · Time-out (kesiden hemen önce)',
  3: '3 · Sign-out (salondan çıkmadan)',
};

export function KontrolListesiModali({ ameliyatId, ameliyatNo, onKapat, onTamam }: {
  ameliyatId: number;
  ameliyatNo?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [maddeler, setMaddeler] = useState<AmeliyatKontrolSatiri[]>([]);
  const [degisen, setDegisen] = useState<Record<number, number>>({});
  const [yukleniyor, setYukleniyor] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    try {
      const y = await api.ameliyatKontrolListesi(ameliyatId);
      setMaddeler(y.maddeler);
      setDegisen({});
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [ameliyatId]);

  useEffect(() => { void yukle() }, [yukle]);

  const isaretli = (m: AmeliyatKontrolSatiri) => degisen[m.id] ?? m.isaretli;

  const kaydet = async () => {
    setHata('');
    const yanitlar = Object.entries(degisen)
      .map(([id, v]) => ({ id: Number(id), isaretli: v }));
    if (yanitlar.length === 0) { onKapat(); return }
    setKaydediyor(true);
    try {
      await api.ameliyatKontrolYaz(ameliyatId, yanitlar);
      mesaj(`${yanitlar.length} madde kaydedildi.`);
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  const asamalar = [1, 2, 3].filter(a => maddeler.some(m => m.asama === a));
  const timeoutEksik = maddeler
    .filter(m => m.asama === 2 && m.zorunlu === 1 && isaretli(m) !== 1).length;

  return (
    <Modal baslik={`Güvenli Cerrahi Kontrol Listesi${ameliyatNo ? ` — ${ameliyatNo}` : ''}`}
           onKapat={onKapat}
           alt={
             <>
               <button className="d onay" disabled={kaydediyor || yukleniyor}
                       onClick={() => void kaydet()}>
                 {kaydediyor ? '⏳ Kaydediliyor…' : '💾 Kaydet'}
               </button>
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {yukleniyor && <div className="not">Yükleniyor…</div>}

      {!yukleniyor && timeoutEksik > 0 && (
        <div className="uyari-kutusu">
          Time-out tamamlanmadı: <b>{timeoutEksik}</b> zorunlu madde işaretsiz.
          Kesi adımı bu maddeler işaretlenmeden kaydedilmez.
        </div>
      )}

      {asamalar.map(a => (
        <div className="kagrup" key={a}>
          <h6>{ASAMA_ADI[a] ?? `Aşama ${a}`}</h6>
          <div className="secim-listesi">
            {maddeler.filter(m => m.asama === a).map(m => (
              <label className="secim-satiri" key={m.id}>
                <input type="checkbox" checked={isaretli(m) === 1}
                       onChange={e => setDegisen(d => ({
                         ...d, [m.id]: e.target.checked ? 1 : 0,
                       }))} />
                <span>
                  {m.maddeMetin}
                  {m.zorunlu !== 1 && <span className="alan-notu"> (isteğe bağlı)</span>}
                  {/* İŞARETLEYEN VE SAAT GÖSTERİLİR: liste bir imzadır, kimin
                      ne zaman dediği sonradan sorulur. */}
                  {m.isaretZamani && (
                    <span className="alan-notu">
                      {' · '}{m.isaretleyen || '—'}
                      {' · '}{new Date(m.isaretZamani).toLocaleTimeString('tr-TR',
                                { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  )}
                </span>
              </label>
            ))}
          </div>
        </div>
      ))}

      <div className="not">
        Madde metinleri ameliyat açılırken <b>kopyalandı</b>: kurum listeyi
        sonradan değiştirse de bu ameliyatta neyin sorulduğu sabit kalır.
      </div>
    </Modal>
  );
}
