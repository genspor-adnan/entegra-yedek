import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { UtsMesaji, UtsSorguYaniti } from '../api/istemci';
import { GridMenu, type MenuOgesi } from '../bilesenler/grid/GridMenu';
import { dosyaIndirUrl } from '../bilesenler/indir';

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
  // Sonuc gorunumu (kullanici): LISTE = grid tablosu (cok kayitta dogal),
  //   KART = anahtar/deger dokumu (tek kaydin tum alanlari).
  const [gorunum, setGorunum] = useState<'liste' | 'kart'>('liste');
  const [yanit, setYanit] = useState<UtsSorguYaniti | null>(null);

  // ÜTS "bulunamadı"yı HATA degil BOS DIZI olarak dondurur (canlıda görüldü).
  const kayitlar = (Array.isArray(yanit?.sonuc)
    ? yanit!.sonuc : yanit?.sonuc != null ? [yanit.sonuc] : []) as Record<string, unknown>[];
  const toplamAdet = kayitlar.reduce((a, k) => a + (Number(k.ADT ?? k.adet) || 0), 0);
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
    // Eski programın akışı: yalnız ürün no girildiyse ve TEKİL sorgu boş
    //   dönerse otomatik AYRINTILI sorguya düşülür (ürünün tekilleri listelenir).
    await calistir(async () => {
      const tekil = await api.utsTekilUrun({
        uno: uno.trim(),
        lotNo: lotNo.trim() || undefined,
        seriNo: seriNo.trim() || undefined,
      });
      const bos = tekil.basarili
        && (tekil.sonuc == null || (Array.isArray(tekil.sonuc) && tekil.sonuc.length === 0));
      if (!bos) return tekil;
      return api.utsAyrintili({
        uno: uno.trim(),
        lotNo: lotNo.trim() || undefined,
        seriNo: seriNo.trim() || undefined,
      });
    });
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

        {/* Liste / Kart secimi - liste ekranlarindaki gorunum cipleriyle ayni dil. */}
        <div style={{ display: 'flex', gap: 6, margin: '0 0 8px' }}>
          <button type="button" className={`cip${gorunum === 'liste' ? ' on' : ''}`}
                  onClick={() => setGorunum('liste')}>☰ Liste</button>
          <button type="button" className={`cip${gorunum === 'kart' ? ' on' : ''}`}
                  onClick={() => setGorunum('kart')}>🗂 Kart</button>
          {/* Sayac ciplerin SAGINDA (kullanici). */}
          {kayitlar.length > 0 && (
            <span style={{ alignSelf: 'center', fontSize: 12 }}>
              <b>{kayitlar.length}</b> kayıt listelendi
              {toplamAdet > 0 && <> · toplam adet <b>{toplamAdet}</b></>}
            </span>
          )}
        </div>

        <div className="kagrup" style={{ maxWidth: 980 }}>
          <h6>Sorgu</h6>
          {/* Izgara degil FLEX: editler dar (%35 kisik) ve SOLA yanasik
              (kullanici) - izgara kolonlari genise dagitiyordu. */}
          <form id="uts-sorgu-form" onSubmit={sorgula}
                style={{ display: 'flex', gap: 18, flexWrap: 'wrap',
                         alignItems: 'center', padding: 10 }}>
            <label className="alan" style={{ display: 'flex', gap: 8,
                                             alignItems: 'center' }}>
              <span className="etiket zorunlu-isaret"
                    style={{ whiteSpace: 'nowrap' }}>Ürün No (UNO)</span>
              <input value={uno} maxLength={23} autoFocus style={{ width: 170 }}
                     onChange={e => setUno(e.target.value)} />
            </label>
            <label className="alan" style={{ display: 'flex', gap: 8,
                                             alignItems: 'center' }}>
              <span className="etiket" style={{ whiteSpace: 'nowrap' }}>Lot No (LNO)</span>
              <input value={lotNo} maxLength={20} style={{ width: 140 }}
                     onChange={e => setLotNo(e.target.value)} />
            </label>
            <label className="alan" style={{ display: 'flex', gap: 8,
                                             alignItems: 'center' }}>
              <span className="etiket" style={{ whiteSpace: 'nowrap' }}>Seri No (SNO)</span>
              <input value={seriNo} maxLength={20} style={{ width: 140 }}
                     onChange={e => setSeriNo(e.target.value)} />
            </label>
          </form>
          {/* Butonlar izgara HUCRESINDE degil (kirpiliyordu) - kutunun altinda
              kendi satirlarinda; submit form="..." ile forma bagli. */}
          <div style={{ display: 'flex', gap: 6, padding: '0 10px 10px' }}>
            <button type="submit" form="uts-sorgu-form" className="d bir"
                    disabled={sorguluyor}>
              {sorguluyor ? 'Sorgulanıyor…' : '🔍 ÜTS’de Sorgula'}
            </button>
            <button type="button" className="d" disabled={sorguluyor}
                    title="Deneysel ayrıntılı tekil ürün servisi"
                    onClick={() => void ayrintili()}>
              Ayrıntılı
            </button>
          </div>
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}

        {yanit && (
          <div>
            <MesajListesi mesajlar={yanit.mesajlar} />
            {kayitlar.length > 0 ? (
              gorunum === 'liste'
                ? <SonucListesi kayitlar={kayitlar} />
                : <SonucKarti sonuc={kayitlar} />
            ) : yanit.basarili ? (
              <div className="bilgi-kutusu">
                ÜTS'de bu ölçütlerle tekil ürün kaydı bulunamadı.
              </div>
            ) : null}
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

/** Kolon öncelik sırası: bilinenler önde, kalanlar geldiği sırada. */
const KOLON_ONCELIK = [
  'UNO', 'urunNumarasi', 'LNO', 'lotBatchNumarasi', 'SNO', 'seriNumarasi',
  'ADT', 'adet', 'kullanilabilirAdet', 'URT', 'uretimTarihiString',
  'SKT', 'sonKullanmaTarihiString', 'MME', 'urunTanimi', 'sahibiUnvan',
  'UTP', 'UAK', 'olusturulmaTarihiString',
];

/** LİSTE görünümü: kayıtlar satır, alanlar kolon - grid tablosu.
    ⋮ menüsü: CSV kaydet + kolon göster/gizle (oturumluk). */
function SonucListesi({ kayitlar }: { kayitlar: Record<string, unknown>[] }) {
  const [menuKonum, setMenuKonum] = useState<{ x: number; y: number } | null>(null);
  const [gizli, setGizli] = useState<Set<string>>(new Set());

  const tumKolonlar: string[] = [];
  const gorulen = new Set<string>();
  for (const ad of KOLON_ONCELIK)
    if (kayitlar.some(k => k[ad] != null)) { tumKolonlar.push(ad); gorulen.add(ad); }
  for (const k of kayitlar)
    for (const ad of Object.keys(k))
      if (!gorulen.has(ad) && !GIZLI_ALANLAR.has(ad) && k[ad] != null) {
        tumKolonlar.push(ad); gorulen.add(ad);
      }
  const kolonlar = tumKolonlar.filter(ad => !gizli.has(ad));

  const csvIndir = () => {
    const bas = kolonlar.map(ad => AD_SOZLUGU[ad] ?? ad).join(';');
    const govde = kayitlar.map(k =>
      kolonlar.map(ad => bicimle(k[ad]).replace(/;/g, ',')).join(';')).join('\n');
    const url = URL.createObjectURL(new Blob(['﻿' + bas + '\n' + govde],
      { type: 'text/csv;charset=utf-8' }));
    dosyaIndirUrl(url, 'uts-sorgu.csv', true);
  };

  const menuOgeleri: MenuOgesi[] = [
    { ik: '📄', ad: 'CSV Kaydet', fn: csvIndir },
    ...tumKolonlar.map((ad, i) => ({
      ik: gizli.has(ad) ? '○' : '●',
      ad: AD_SOZLUGU[ad] ?? ad,
      secili: !gizli.has(ad),
      ayrac: i === 0,
      fn: () => setGizli(t => {
        const y = new Set(t);
        if (y.has(ad)) y.delete(ad); else if (kolonlar.length > 1) y.add(ad);
        return y;
      }),
    })),
  ];

  return (
    <div className="kagrup">
      <div style={{ display: 'flex', justifyContent: 'flex-end', padding: '4px 6px 0' }}>
        <button type="button" className="d" title="Grid menüsü"
                onClick={e => {
                  const r = e.currentTarget.getBoundingClientRect();
                  setMenuKonum(menuKonum ? null : { x: r.left - 160, y: r.bottom + 4 });
                }}>⋮</button>
      </div>
      <div style={{ overflowX: 'auto' }}>
        <table className="grid">
          <thead>
            <tr>{kolonlar.map(ad => <th key={ad}>{AD_SOZLUGU[ad] ?? ad}</th>)}</tr>
          </thead>
          <tbody>
            {kayitlar.map((k, i) => (
              <tr key={i}>
                {kolonlar.map(ad => <td key={ad}>{bicimle(k[ad])}</td>)}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <GridMenu konum={menuKonum} ogeler={menuOgeleri}
                onKapat={() => setMenuKonum(null)} />
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
              {Object.entries((k ?? {}) as Record<string, unknown>)
                .filter(([ad, deger]) => !GIZLI_ALANLAR.has(ad) && deger != null)
                .map(([ad, deger]) => (
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

/** ÜTS alan adları okunur başlığa: üç harfli kodlar (tekil sorgu) +
    camelCase adlar (ayrıntılı sorgu); bilinmeyenler ham kalır. */
const AD_SOZLUGU: Record<string, string> = {
  UNO: 'Ürün Numarası', LNO: 'Lot/Batch No', SNO: 'Seri No', ADT: 'Adet',
  URT: 'Üretim Tarihi', SKT: 'Son Kullanma', UTP: 'Ürün Tipi', TTI: 'Takip Tipi',
  UDI: 'Eşsiz Kimlik (UDI)', MME: 'Marka / Model', SKG: 'Sahip Kurum',
  KKG: 'Kullanan Kurum', BID: 'Bildirim Id', BTI: 'Bildirim Tipi',
  KUN: 'Kurum No', AKU: 'Kurum Unvanı', BNO: 'Belge No', DUR: 'Durum',
  UIK: 'Üretici/İthalatçı Kurum No', UAK: 'Takip Şekli',
  // Ayrıntılı sorgu (camelCase) alanları.
  urunNumarasi: 'Ürün Numarası', seriNumarasi: 'Seri No',
  lotBatchNumarasi: 'Lot/Batch No', adet: 'Adet',
  kullanilabilirAdet: 'Kullanılabilir Adet', sahibiUnvan: 'Sahibi',
  sahibi: 'Sahibi Kurum No', ureticiIthalatciKurumNo: 'Üretici/İthalatçı No',
  urunTanimi: 'Ürün Tanımı', essizKimlik: 'Eşsiz Kimlik (UDI)',
  uretimTarihiString: 'Üretim Tarihi', sonKullanmaTarihiString: 'Son Kullanma',
  olusturulmaTarihiString: 'Oluşturulma',
};

/** Ayrıntılı cevabındaki gürültü: *ForExcel kopyaları ve ms cinsinden tarih
    çiftleri (String'lisi zaten var) gösterilmez. */
const GIZLI_ALANLAR = new Set([
  'essizKimlikForExcel', 'ureticiIthalatciKurumNoForExcel',
  'kullanilabilirAdetForExcel', 'olusturulmaTarihi', 'sonKullanmaTarihi',
  'uretimTarihi', 'urunBilgileri',
]);

function bicimle(deger: unknown): string {
  if (deger == null) return '';
  // Sayı → tarih SEZGİSİ YOK: ÜTS kurum numaraları da 13 haneli sayı
  //   (UIK 2667... "10.07.2054" görünmüştü); tarihler zaten metin geliyor.
  if (typeof deger === 'object') return JSON.stringify(deger);
  return String(deger);
}
