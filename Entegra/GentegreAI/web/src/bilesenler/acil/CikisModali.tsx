import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';

/**
 * ACİL ÇIKIŞ KARARI (716).
 *
 * ÇIKIŞ TANISI ZORUNLU - ön tanıyla kapatılan dosya ne klinik kalite
 * göstergesine ne TİG'e girebilir. Kuralın sahibi veritabanı tetiği; buradaki
 * kontrol yalnız kullanıcıya hangi kutunun eksik olduğunu göstermek için
 * (tetik hatası alan adı söyleyemez).
 *
 * YATIŞ KARARI HEDEF BÖLÜM İSTER: "yatışa karar verildi ama nereye" yatan
 * hasta tarafında karşılıksız kalır.
 *
 * ICD KODU ARANARAK SEÇİLİR, elle yazılmaz: serbest metin tanı, göstergeyi
 * hesaplayan kod eşleşmesini sessizce ıskalar.
 */
const CIKIS_SEKLI: { kod: number; ad: string }[] = [
  { kod: 1, ad: 'Taburcu' },
  { kod: 2, ad: 'Servise yatış' },
  { kod: 3, ad: 'Yoğun bakım' },
  { kod: 4, ad: 'Sevk (başka kuruma)' },
  { kod: 5, ad: 'Ölüm' },
  { kod: 6, ad: 'Kendi isteğiyle ayrıldı' },
  { kod: 7, ad: 'Ameliyathane' },
];

interface Bolum { id: number; ad: string }
interface Tani { kod: string; ad: string }

export function CikisModali({ basvuruId, protokolNo, hastaAdi, onKapat, onTamam }: {
  basvuruId: number;
  protokolNo?: string;
  hastaAdi?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [cikisSekli, setCikisSekli] = useState<number>(1);
  const [taniKod, setTaniKod] = useState('');
  const [taniAd, setTaniAd] = useState('');
  const [taniArama, setTaniArama] = useState('');
  const [taniSonuc, setTaniSonuc] = useState<Tani[]>([]);
  const [bolumler, setBolumler] = useState<Bolum[]>([]);
  const [bolumId, setBolumId] = useState<number | ''>('');
  const [notu, setNotu] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const yatisaGidiyor = cikisSekli === 2 || cikisSekli === 3;

  const bolumYukle = useCallback(async () => {
    try {
      const y = await api.liste('departman', { sayfa: 1, boyut: 200 });
      setBolumler(y.satirlar.map(r => ({
        id: Number(r.id), ad: String(r.ad ?? ''),
      })));
    } catch { /* bölüm listesi gelmezse alan boş kalır, çıkış yine yapılabilir */ }
  }, []);

  useEffect(() => { if (yatisaGidiyor && bolumler.length === 0) void bolumYukle() },
           [yatisaGidiyor, bolumler.length, bolumYukle]);

  // TANI ARAMASI GECİKMELİ DEĞİL, DÜĞMEYLE: acil ekranında her tuşta 40 bin
  //   satırlık katalogda arama yapmak, yazmayı takip edemeyecek kadar yavaş.
  const taniAra = async () => {
    const q = taniArama.trim();
    if (q.length < 2) { setHata('En az iki karakter yazın.'); return }
    setHata('');
    try {
      const y = await api.liste('icd', {
        sayfa: 1, boyut: 25,
        filtre: { op: 'and', kosullar: [
          { alan: 'aktif', op: 'esit', deger: 1 },
          { op: 'or', kosullar: [
            { alan: 'kod', op: 'baslar', deger: q },
            { alan: 'ad', op: 'icerir', deger: q },
          ] },
        ] },
      });
      setTaniSonuc(y.satirlar.map(r => ({
        kod: String(r.kod ?? ''), ad: String(r.ad ?? ''),
      })));
    } catch (h) { setHata(hataMetni(h)) }
  };

  const kaydet = async () => {
    setHata('');
    if (!taniKod) { setHata('Çıkış tanısı seçilmeli.'); return }
    if (yatisaGidiyor && !bolumId) { setHata('Yatış için hedef bölüm seçilmeli.'); return }
    setKaydediyor(true);
    try {
      const y = await api.acilCikis(basvuruId, {
        cikisSekli, cikisTani: taniKod,
        hedefBolumId: bolumId === '' ? null : bolumId,
        cikisNotu: notu,
      });
      mesaj(`Çıkış kaydedildi. Toplam süre: ${y.sure?.toplamDk ?? '—'} dk.`
          + (y.yatakTemizlige ? ' Yatak temizliğe alındı.' : ''));
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`Çıkış Kararı${protokolNo ? ` — ${protokolNo}` : ''}`} onKapat={onKapat} dar
           alt={
             <>
               <button className="d onay" disabled={kaydediyor}
                       onClick={() => void kaydet()}>
                 {kaydediyor ? '⏳ Kaydediliyor…' : '🚪 Çıkışı Kaydet'}
               </button>
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kagrup">
        <h6>Çıkış</h6>
        <div className="alan-izgara tek-sutun">
          <label className="alan">
            <span className="etiket">Hasta</span>
            <input readOnly value={hastaAdi ?? ''} />
          </label>
          <label className="alan">
            <span className="etiket zorunlu-isaret">Çıkış Şekli</span>
            <select value={cikisSekli} onChange={e => setCikisSekli(Number(e.target.value))}>
              {CIKIS_SEKLI.map(c => <option key={c.kod} value={c.kod}>{c.ad}</option>)}
            </select>
          </label>
          {cikisSekli === 4 && (
            <div className="not">
              Sevk ayrı yetki ister (<b>acil.sevk</b>): hastayı başka kuruma
              yollamak kurumun dışına taşan bir karardır, taburcu değildir.
            </div>
          )}
          {yatisaGidiyor && (
            <label className="alan">
              <span className="etiket zorunlu-isaret">Hedef Bölüm</span>
              <select value={bolumId}
                      onChange={e => setBolumId(e.target.value ? Number(e.target.value) : '')}>
                <option value="">— seçiniz —</option>
                {bolumler.map(b => <option key={b.id} value={b.id}>{b.ad}</option>)}
              </select>
            </label>
          )}
        </div>
      </div>

      <div className="kagrup">
        <h6>Çıkış Tanısı (ICD-10)</h6>
        <div className="alan-izgara tek-sutun">
          <label className="alan">
            <span className="etiket zorunlu-isaret">Seçilen</span>
            <input readOnly value={taniKod ? `${taniKod} · ${taniAd}` : ''}
                   placeholder="Aşağıdan arayıp seçin" />
          </label>
          <label className="alan">
            <span className="etiket">Ara</span>
            <span className="ikili">
              <input value={taniArama} placeholder="Kod ya da tanı adı"
                     onChange={e => setTaniArama(e.target.value)}
                     onKeyDown={e => { if (e.key === 'Enter') void taniAra() }} />
              <button className="d" onClick={() => void taniAra()}>🔍 Ara</button>
            </span>
          </label>
          {taniSonuc.length > 0 && (
            <div className="secim-listesi">
              {taniSonuc.map(t => (
                <button className="secim-satiri" key={t.kod}
                        onClick={() => { setTaniKod(t.kod); setTaniAd(t.ad); setTaniSonuc([]) }}>
                  {t.kod} · {t.ad}
                </button>
              ))}
            </div>
          )}
          <label className="alan">
            <span className="etiket">Çıkış Notu / Öneriler</span>
            <input value={notu} maxLength={500} onChange={e => setNotu(e.target.value)} />
          </label>
        </div>
        <div className="not">
          Çıkış kaydedilince hastanın yatağı <b>temizliğe</b> düşer (boşa değil) -
          temizlenmemiş yatağa hasta yollamak panonun yalan söylemesi olurdu.
        </div>
      </div>
    </Modal>
  );
}
