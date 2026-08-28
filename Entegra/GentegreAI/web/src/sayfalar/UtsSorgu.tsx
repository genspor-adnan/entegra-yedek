import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { UtsMesaji, UtsSorguYaniti } from '../api/istemci';

/**
 * ÜTS ÜRÜN SORGU (223) - UNO/LNO/SNO ile ÜTS'den canlı tekil ürün sorgusu.
 * Ekran YALNIZ API çağırır (endpoint/JSON bilgisi sunucuda). Üstte hesap
 * şeridi: hangi kurum no + hangi ortam (TEST rozeti) çalışıyor bir bakışta
 * görünsün - Delphi'de yanlış ortama bildirim atma kazaları oluyordu.
 */
export function UtsSorgu() {
  const [uno, setUno] = useState('');
  const [lotNo, setLotNo] = useState('');
  const [seriNo, setSeriNo] = useState('');
  const [sorguluyor, setSorguluyor] = useState(false);
  const [yanit, setYanit] = useState<UtsSorguYaniti | null>(null);
  const [hata, setHata] = useState('');
  const [hesap, setHesap] = useState<{ kurumNo: string; testMi: boolean;
    url: string; tokenVar: boolean; tokenSonu: string } | null>(null);
  const [hesapHata, setHesapHata] = useState('');

  useEffect(() => {
    let iptal = false;
    api.utsHesapDurum()
      .then(h => { if (!iptal) setHesap(h) })
      .catch(h => { if (!iptal) setHesapHata(h instanceof Error ? h.message : String(h)) });
    return () => { iptal = true };
  }, []);

  const sorgula = async (e?: React.FormEvent) => {
    e?.preventDefault();
    if (!uno.trim()) { setHata('Ürün numarası (UNO) girin.'); return }
    await calistir(() => api.utsTekilUrun({
      uno: uno.trim(),
      lotNo: lotNo.trim() || undefined,
      seriNo: seriNo.trim() || undefined,
    }));
  };

  // Ayrintili sorgu DENEYSEL uc (sozlesme s170) - yalniz rapor; UNO/LNO/SNO
  //   herhangi biriyle calisir.
  const ayrintili = async () => {
    if (!uno.trim() && !lotNo.trim() && !seriNo.trim()) {
      setHata('Ayrıntılı sorgu için UNO, LNO ya da SNO girin.'); return;
    }
    await calistir(() => api.utsAyrintili({
      uno: uno.trim() || undefined,
      lotNo: lotNo.trim() || undefined,
      seriNo: seriNo.trim() || undefined,
    }));
  };

  const calistir = async (f: () => Promise<UtsSorguYaniti>) => {
    setSorguluyor(true); setHata(''); setYanit(null);
    try {
      setYanit(await f());
    } catch (h) {
      setHata(h instanceof Error ? h.message : String(h));
    } finally {
      setSorguluyor(false);
    }
  };

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>ÜTS Ürün Sorgu</h1>
          <span className="yol">Stok › ÜTS Ürün Sorgu</span>
        </div>
      </div>

      <div style={{ padding: '0 20px 20px', overflow: 'auto' }}>
        {/* Hesap şeridi: kurum + ortam bir bakışta - yanlış ortama bildirim
            kazası Delphi'de yaşanmıştı. */}
        {hesapHata ? (
          <div className="hata-kutusu">{hesapHata}</div>
        ) : hesap && (
          <div className="bilgi-kutusu">
            <span className={`rozet ${hesap.testMi ? 'uyari' : 'ok'}`}>
              {hesap.testMi ? 'TEST ORTAMI' : 'CANLI'}
            </span>
            {' '}Kurum No: <b>{hesap.kurumNo || '—'}</b>
            {' · '}Token: {hesap.tokenVar ? `••••${hesap.tokenSonu}` : 'GİRİLMEMİŞ'}
            {' · '}{hesap.url}
          </div>
        )}

        <div className="kagrup" style={{ maxWidth: 980 }}>
          <h6>Sorgu</h6>
          <form className="alan-izgara dort-sutun" onSubmit={sorgula}>
            <label className="alan">
              <span className="etiket zorunlu-isaret">Ürün No (UNO)</span>
              <input value={uno} maxLength={23} autoFocus
                     onChange={e => setUno(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket">Lot No (LNO)</span>
              <input value={lotNo} maxLength={20} onChange={e => setLotNo(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket">Seri No (SNO)</span>
              <input value={seriNo} maxLength={20} onChange={e => setSeriNo(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket">&nbsp;</span>
              <span className="ikili">
                <button type="submit" className="d bir" disabled={sorguluyor}>
                  {sorguluyor ? 'Sorgulanıyor…' : '🔍 ÜTS’de Sorgula'}
                </button>
                <button type="button" className="d" disabled={sorguluyor}
                        title="Deneysel ayrıntılı tekil ürün servisi"
                        onClick={() => void ayrintili()}>
                  Ayrıntılı
                </button>
              </span>
            </label>
          </form>
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}

        {yanit && (
          <div style={{ maxWidth: 980 }}>
            <MesajListesi mesajlar={yanit.mesajlar} />
            {yanit.sonuc != null && <SonucKarti sonuc={yanit.sonuc} />}
            {yanit.sonuc == null && yanit.basarili && (
              <div className="bilgi-kutusu">Sonuç boş döndü.</div>
            )}
          </div>
        )}
      </div>
    </>
  );
}

function MesajListesi({ mesajlar }: { mesajlar: UtsMesaji[] }) {
  if (!mesajlar.length) return null;
  return (
    <div className="kagrup" style={{ marginBottom: 8, padding: 10 }}>
      {mesajlar.map((m, i) => (
        <div key={i}>
          <span className={`rozet ${m.tip === 'HATA' ? 'hata'
                                  : m.tip === 'UYARI' ? 'uyari' : 'bilgi'}`}>
            {m.tip ?? 'BİLGİ'}
          </span>{' '}
          {m.met ?? ''}{m.kod ? ` (${m.kod})` : ''}
        </div>
      ))}
    </div>
  );
}

/** ÜTS cevabı (SNC) - alanlar servise göre değişir; anahtar/değer dökümü. */
function SonucKarti({ sonuc }: { sonuc: unknown }) {
  const kayitlar = Array.isArray(sonuc) ? sonuc : [sonuc];
  return (
    <>
      {kayitlar.map((k, i) => (
        <div key={i} className="kagrup" style={{ marginBottom: 8 }}>
          <table className="detay-tablo">
            <tbody>
              {Object.entries((k ?? {}) as Record<string, unknown>).map(([ad, deger]) => (
                <tr key={ad}>
                  <td style={{ fontWeight: 600, width: 220 }}>{AD_SOZLUGU[ad] ?? ad}</td>
                  <td>{bicimle(deger)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ))}
    </>
  );
}

/** Üç harfli ÜTS kodları okunur başlığa (bilinenler; kalanlar ham kalır). */
const AD_SOZLUGU: Record<string, string> = {
  UNO: 'Ürün Numarası', LNO: 'Lot/Batch No', SNO: 'Seri No', ADT: 'Adet',
  URT: 'Üretim Tarihi', SKT: 'Son Kullanma', UTP: 'Ürün Tipi', TTI: 'Takip Tipi',
  UDI: 'Eşsiz Kimlik (UDI)', MME: 'Marka / Model', SKG: 'Sahip Kurum',
  KKG: 'Kullanan Kurum', BID: 'Bildirim Id', BTI: 'Bildirim Tipi',
  KUN: 'Kurum No', AKU: 'Kurum Unvanı', BNO: 'Belge No', DUR: 'Durum',
};

function bicimle(deger: unknown): string {
  if (deger == null) return '';
  // UNIX ms tarih alanları (ÜTS bazı tarihler için sayı döndürür).
  if (typeof deger === 'number' && deger > 1_000_000_000_000)
    return new Date(deger).toLocaleDateString('tr-TR');
  if (typeof deger === 'object') return JSON.stringify(deger);
  return String(deger);
}
