import { useCallback, useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { guvenli, mesaj } from '../bilesenler/mesaj';
import { tarihSaat } from '../bilesenler/bicim';

interface KatalogDurumu {
  kod: string;
  ad: string;
  sonCalisma?: string | null;
  satirSayisi: number;
  sonuc: string;
  basarili: boolean;
  mevcutSatir: number;
}

/**
 * KLİNİK KATALOGLAR (400, Faz 0) — ICD-10 ve ilaç listesinin durumu ve
 * dosyadan yüklenmesi.
 *
 * İki kaynak da gerçektir: SKRS senkronu (Entegrasyon Hesapları ekranından)
 * ve BURADAN dosya yükleme. SKRS hesabı bir Faz 0 kapısıdır (başvuru işi);
 * kapanana kadar katalog boş kalmasın diye bakanlığın yayınladığı liste
 * doğrudan yüklenebiliyor. İlaç barkod listesi zaten SKRS'de yoktur.
 */
export function KatalogAyarlar() {
  const [durum, setDurum] = useState<KatalogDurumu[]>([]);
  const [yukleniyor, setYukleniyor] = useState(true);
  const icdDosya = useRef<HTMLInputElement | null>(null);
  const ilacDosya = useRef<HTMLInputElement | null>(null);

  const oku = useCallback(async () => {
    setYukleniyor(true);
    try { setDurum(await api.katalogDurum()) }
    catch { setDurum([]) }
    finally { setYukleniyor(false) }
  }, []);

  useEffect(() => { void oku() }, [oku]);

  /**
   * Dosya TARAYICIDA okunur ve metin olarak gönderilir: ayrı bir dosya
   * yükleme ucu (multipart) açmadan, mevcut JSON sözleşmesi yeterli.
   * Büyük listelerde (ICD ~20 bin satır ≈ 1,5 MB) sorun olmuyor.
   */
  const yukle = async (tur: 'icd' | 'ilac', dosya: File | undefined) => {
    if (!dosya) return;
    const icerik = await dosya.text();
    await guvenli(async () => {
      const y = tur === 'icd'
        ? await api.katalogIcdYukle(icerik)
        : await api.katalogIlacYukle(icerik);
      mesaj(`${y.yazilan} satır yazıldı`
          + (y.atlanan ? `, ${y.atlanan} satır atlandı (eksik kod/ad).` : '.'));
      await oku();
    });
  };

  const satir = (kod: string) => durum.find(d => d.kod === kod);

  const kutu = (kod: string, baslik: string, aciklama: string,
                sutunlar: string, girdi: React.RefObject<HTMLInputElement | null>,
                tur: 'icd' | 'ilac') => {
    const d = satir(kod);
    return (
      <div className="kagrup" style={{ marginBottom: 12 }}>
        <h6>{baslik}
          <span className="sag" style={{ marginLeft: 'auto', display: 'flex', gap: 8 }}>
            <span className={`rozet ${d && d.mevcutSatir > 0 ? 'ok' : 'uyari'}`}>
              {d ? `${d.mevcutSatir.toLocaleString('tr-TR')} kayıt` : 'boş'}
            </span>
            <button className="d" onClick={() => girdi.current?.click()}>⬆ Dosyadan Yükle</button>
          </span>
        </h6>
        <div className="not">
          {aciklama}
          <br /><b>Sütunlar:</b> <code>{sutunlar}</code> — ayraç <code>;</code>,
          sekme ya da <code>,</code> olabilir; başlık satırı varsa atlanır.
          <br />
          <b>Son güncelleme:</b>{' '}
          {d?.sonCalisma ? tarihSaat(d.sonCalisma) : 'hiç çalışmadı'}
          {d?.sonuc ? ` — ${d.sonuc}` : ''}
        </div>
        <input ref={girdi} type="file" accept=".csv,.txt,.tsv" style={{ display: 'none' }}
               onChange={e => { void yukle(tur, e.target.files?.[0]); e.target.value = '' }} />
      </div>
    );
  };

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Klinik Kataloglar</h1>
          <span className="yol">Yönetim › Ortak Platform › Klinik Kataloglar</span>
        </div>
      </div>

      {yukleniyor && <div className="not" style={{ margin: 12 }}>Yükleniyor…</div>}

      {kutu('icd', 'ICD-10 Tanı Kataloğu',
            'Muayene tanısı, provizyon ve e-Nabız aynı kodu bekler. SKRS hesabı '
          + 'tanımlıysa Entegrasyon Hesapları ekranındaki "SKRS Senkron" da bu '
          + 'tabloyu doldurur.',
            'kod ; ad ; üst_kod(ops) ; cinsiyet(0/1/2, ops)', icdDosya, 'icd')}

      {kutu('ilac', 'İlaç Kataloğu (barkod)',
            'e-Reçete ve sarf çıkışı barkoddan okur. Bu liste SKRS\'de yoktur — '
          + 'İTS / TİTCK\'nın yayınladığı ilaç listesi buradan yüklenir.',
            'barkod ; ad ; etken_madde(ops) ; atc(ops) ; firma(ops) ; reçete_türü(0-4, ops) ; ambalaj(ops)',
            ilacDosya, 'ilac')}

      <div className="not" style={{ margin: 12 }}>
        <b>Yükleme birleştirir, silmez:</b> var olan kod güncellenir, olmayan
        eklenir. Dosyada bulunmayan kod <b>pasife çekilmez</b> — eksik bir dosya
        yüzünden binlerce tanının kaybolması, ertesi gün “tanı bulunamıyor”
        olarak geri gelirdi.
      </div>
    </>
  );
}
