import { useEffect, useRef, useState, type FormEvent } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type DokumanSatiri } from '../api/sozlesme';
import { tarihYaz } from './bicim';

const boyutYaz = (b: number) => b < 1024 ? `${b} B` : b < 1024 * 1024 ? `${(b / 1024).toFixed(0)} KB` : `${(b / 1024 / 1024).toFixed(1)} MB`;

const dosyaTipiIkon = (contentType: string) => {
  if (contentType.startsWith('image/')) return '🖼️';
  if (contentType === 'application/pdf') return '📕';
  if (contentType.includes('word')) return '📘';
  if (contentType.includes('excel') || contentType.includes('spreadsheet')) return '📗';
  if (contentType === 'text/plain') return '📄';
  return '📎';
};

const dosyaTipiBaslik = (contentType: string) => {
  if (contentType.startsWith('image/')) return 'Resim';
  if (contentType === 'application/pdf') return 'PDF';
  if (contentType.includes('word')) return 'Word';
  if (contentType.includes('excel') || contentType.includes('spreadsheet')) return 'Excel';
  if (contentType === 'text/plain') return 'Metin';
  return 'Dosya';
};

const resimMi = (s: DokumanSatiri) => s.contentType.startsWith('image/');

const belgeTuruSecenekleri = [
  'Adli Sicil',
  'Diploma',
  'İş Sözleşmesi',
  'Kimlik Fotokopisi',
  'Sağlık Raporu',
  'SGK İşe Giriş',
];

function ResimBandi({ resimler, resimUrlleri }: { resimler: DokumanSatiri[]; resimUrlleri: Record<number, string> }) {
  return (
    <div style={{ display: 'flex', gap: 8, overflowX: 'auto', padding: 10, background: 'var(--yuz2)', margin: '0 10px 10px', borderRadius: 4 }}>
      {resimler.map(s => (
        <div key={s.id} style={{ flex: '0 0 auto', width: 100, textAlign: 'center' }}>
          <div
            style={{
              width: 100, height: 100, border: s.varsayilan ? '2px solid var(--mor)' : '1px solid var(--cizgi)',
              borderRadius: 4, overflow: 'hidden', background: 'var(--yuz)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              cursor: resimUrlleri[s.id] ? 'pointer' : 'default',
            }}
            title="Büyük açmak için tıklayın"
            onClick={() => resimUrlleri[s.id] && window.open(resimUrlleri[s.id], '_blank')}
          >
            {resimUrlleri[s.id]
              ? <img src={resimUrlleri[s.id]} alt={s.ad} style={{ width: '100%', height: '100%', objectFit: 'contain' }} />
              : <span style={{ fontSize: 24 }}>🖼️</span>}
          </div>
          <div style={{ fontSize: 10, color: 'var(--soluk)', marginTop: 3, wordBreak: 'break-all' }}>{s.ad}</div>
        </div>
      ))}
    </div>
  );
}

/**
 * Genel resim/doküman galerisi (057_dokuman.sql) - kaynak-bağımsız (kartAdi: "personel",
 * "cari", "kisi", "stok" - backend'de fiziksel tabloya çevriliyor). "Dosya Ekle" HER ZAMAN
 * gride ekler (kullanıcı: resim/doküman ayrım yapmadan tek liste); resimleri ayrıca
 * gözden geçirmek için açılır/kapanır bir "Resimleri Göster" bandı var (100x100, soldan
 * sağa) - resimler grid'den çıkmaz, band sadece EK bir görünüm.
 *
 * Araç çubuğu (Gör/Düzenle/İndir/Paylaş/Varsayılan Yap/Sil) satır SEÇİMİ üzerinde çalışır -
 * gridde artık aksiyon sütunu yok. Seçim: tek tık = tek seçim, Ctrl/Cmd+tık = ekle/çıkar,
 * Shift+tık = aralık, checkbox tıklaması = her zaman ekle/çıkar.
 */
export function DokumanGalerisi({ kartAdi, kaynakId, saltOkunur }: {
  kartAdi: string; kaynakId: number; saltOkunur: boolean;
}) {
  const [satirlar, setSatirlar] = useState<DokumanSatiri[] | null>(null);
  const [resimUrlleri, setResimUrlleri] = useState<Record<number, string>>({});
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [bandAcik, setBandAcik] = useState(false);
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [paylasimMesaji, setPaylasimMesaji] = useState<string | null>(null);
  const [duzenlenen, setDuzenlenen] = useState<{ id: number; ad: string; belgeTuru: string } | null>(null);
  const girdiRef = useRef<HTMLInputElement | null>(null);
  const sonSeciliIndex = useRef<number | null>(null);

  const satirlarim = satirlar ?? [];
  const resimler = satirlarim.filter(resimMi);
  const seciliSatir = secili.size === 1 ? satirlarim.find(s => secili.has(s.id)) : undefined;
  const seciliResimMi = seciliSatir !== undefined && resimMi(seciliSatir) && !seciliSatir.varsayilan;

  // Ortak hata yakalama - her aksiyon aynı try/catch/setHata'yı tekrar etmesin.
  const calistir = async (fn: () => Promise<DokumanSatiri[]>) => {
    try {
      setSatirlar(await fn());
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    }
  };

  const secimiDegistir = (id: number, index: number) => {
    setSecili(onceki => {
      const yeni = new Set(onceki);
      if (yeni.has(id)) yeni.delete(id); else yeni.add(id);
      return yeni;
    });
    sonSeciliIndex.current = index;
  };

  // Tek tık = tek seçim (seçimi değiştirir). Ctrl/Cmd+tık = tek satırı ekle/çıkar.
  // Shift+tık = son seçilenden bu satıra kadar aralığı seç.
  const satirTiklandi = (e: React.MouseEvent, id: number, index: number) => {
    if (e.shiftKey && sonSeciliIndex.current !== null) {
      const [bas, son] = [sonSeciliIndex.current, index].sort((a, b) => a - b);
      setSecili(new Set(satirlarim.slice(bas, son + 1).map(s => s.id)));
    } else if (e.ctrlKey || e.metaKey) {
      secimiDegistir(id, index);
    } else {
      setSecili(new Set([id]));
      sonSeciliIndex.current = index;
    }
  };

  const yenile = () => {
    api.dokumanlar(kartAdi, kaynakId)
      .then(setSatirlar)
      .catch(h => setHata(h instanceof ApiHatasi ? h.message : String(h)));
  };

  useEffect(() => { yenile() }, [kartAdi, kaynakId]);

  // Resim blob URL'lerini SADECE band acikken cek (liste ucu icerik dondurmuyor, sadece
  // metadata - gereksiz indirme yapmayalim).
  useEffect(() => {
    if (!bandAcik) return;
    resimler.forEach(s => {
      if (resimUrlleri[s.id]) return;
      api.dokumanIcerikUrl(s.id).then(url => setResimUrlleri(h => ({ ...h, [s.id]: url }))).catch(() => { /* onizleme yoksa sessiz gec */ });
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [bandAcik, satirlar]);

  const dosyaSecildi = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const dosya = e.target.files?.[0];
    e.target.value = '';
    if (!dosya) return;
    setYukleniyor(true);
    setHata(null);
    try {
      await calistir(() => api.dokumanYukle(kartAdi, kaynakId, dosya, false));
    } finally {
      setYukleniyor(false);
    }
  };

  const icerikUrl = async (id: number) => resimUrlleri[id] ?? await api.dokumanIcerikUrl(id);

  const indir = async (satir: DokumanSatiri) => {
    try {
      const url = await icerikUrl(satir.id);
      const a = document.createElement('a');
      a.href = url;
      a.download = satir.ad;
      a.click();
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    }
  };

  const gor = async (satir: DokumanSatiri) => {
    try {
      window.open(await icerikUrl(satir.id), '_blank');
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    }
  };

  const duzenle = async (satir: DokumanSatiri) => {
    setDuzenlenen({ id: satir.id, ad: satir.ad, belgeTuru: satir.belgeTuru || '' });
  };

  const duzenlemeKaydet = async (e: FormEvent) => {
    e.preventDefault();
    if (!duzenlenen || !duzenlenen.ad.trim()) return;
    const satir = satirlarim.find(s => s.id === duzenlenen.id);
    if (satir && duzenlenen.ad === satir.ad && duzenlenen.belgeTuru === (satir.belgeTuru || '')) {
      setDuzenlenen(null);
      return;
    }
    await calistir(() => api.dokumanDuzenle(kartAdi, kaynakId, duzenlenen.id, duzenlenen.ad, duzenlenen.belgeTuru));
    setDuzenlenen(null);
  };

  const paylas = async (satir: DokumanSatiri) => {
    setPaylasimMesaji(null);
    try {
      const url = await api.dokumanPaylas(kartAdi, kaynakId, satir.id);
      try {
        await navigator.clipboard.writeText(url);
        setPaylasimMesaji(`Bağlantı panoya kopyalandı: ${url}`);
      } catch {
        setPaylasimMesaji(url);
      }
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    }
  };

  const varsayilanYap = async () => {
    if (seciliSatir) await calistir(() => api.dokumanVarsayilanYap(kartAdi, kaynakId, seciliSatir.id));
  };

  const seciliSil = async () => {
    if (secili.size === 0) return;
    if (!window.confirm(`${secili.size} dosya silinsin mi?`)) return;
    let liste: DokumanSatiri[] | null = null;
    try {
      for (const id of secili) liste = await api.dokumanSil(kartAdi, kaynakId, id);
      setSatirlar(liste);
      setSecili(new Set());
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    }
  };

  return (
    <div className="kagrup">
      <h6>
        Resim / Doküman
        {!saltOkunur && (
          <>
            <input ref={girdiRef} type="file" style={{ display: 'none' }} onChange={e => void dosyaSecildi(e)}
              accept="image/jpeg,image/png,image/webp,image/gif,application/pdf,.doc,.docx,.xls,.xlsx,text/plain" />
            <button type="button" className="d bir" title="Dosya Ekle" disabled={yukleniyor} onClick={() => girdiRef.current?.click()}>
              {yukleniyor ? '…' : '＋'}
            </button>
            <button type="button" className="d teh" title="Sil" disabled={secili.size === 0} onClick={() => void seciliSil()}>🗑️</button>
          </>
        )}
        {resimler.length > 0 && (
          <button type="button" className="d" title={bandAcik ? 'Resim Kapat' : 'Resimleri Göster'} onClick={() => setBandAcik(a => !a)}>
            🖼️
          </button>
        )}
        <button type="button" className="d" title="Gör" disabled={!seciliSatir} onClick={() => seciliSatir && void gor(seciliSatir)}>👁️</button>
        {!saltOkunur && (
          <button type="button" className="d" title="Düzenle" disabled={!seciliSatir} onClick={() => seciliSatir && void duzenle(seciliSatir)}>✏️</button>
        )}
        <button type="button" className="d" title="İndir" disabled={!seciliSatir} onClick={() => seciliSatir && void indir(seciliSatir)}>⬇️</button>
        <button type="button" className="d" title="Paylaş" disabled={!seciliSatir} onClick={() => seciliSatir && void paylas(seciliSatir)}>🔗</button>
        {!saltOkunur && seciliResimMi && (
          <button type="button" className="d" title="Varsayılan Yap" onClick={() => void varsayilanYap()}>⭐</button>
        )}
      </h6>
      {hata && <div className="alan-hata" style={{ margin: '0 10px' }}>{hata}</div>}
      {paylasimMesaji && <div style={{ margin: '0 10px 10px', wordBreak: 'break-all', fontSize: 12, color: 'var(--soluk)' }}>{paylasimMesaji}</div>}

      {duzenlenen && (
        <>
          <div className="perde" style={{ zIndex: 420 }} onClick={() => setDuzenlenen(null)} />
          <form className="lookup-pencere" style={{ zIndex: 421, width: 'min(440px, 92vw)' }} onSubmit={e => void duzenlemeKaydet(e)}>
            <strong>Doküman Düzenle</strong>
            <label className="alan">
              <span className="etiket">Belge Türü</span>
              <input
                value={duzenlenen.belgeTuru}
                onChange={e => setDuzenlenen(d => d && ({ ...d, belgeTuru: e.target.value }))}
                list="dokuman-belge-turu-secenekleri"
                autoFocus
                placeholder="İş sözleşmesi, sağlık raporu..."
              />
              <datalist id="dokuman-belge-turu-secenekleri">
                {belgeTuruSecenekleri.map(s => <option key={s} value={s} />)}
              </datalist>
            </label>
            <label className="alan">
              <span className="etiket">Ad</span>
              <input value={duzenlenen.ad} onChange={e => setDuzenlenen(d => d && ({ ...d, ad: e.target.value }))} />
            </label>
            <div className="lookup-alt">
              <span></span>
              <div style={{ display: 'flex', gap: 8 }}>
                <button type="button" onClick={() => setDuzenlenen(null)}>İptal</button>
                <button type="submit" disabled={!duzenlenen.ad.trim()}>Kaydet</button>
              </div>
            </div>
          </form>
        </>
      )}

      {bandAcik && <ResimBandi resimler={resimler} resimUrlleri={resimUrlleri} />}

      {satirlarim.length > 0 && (
        <table className="detay-tablo" style={{ margin: 10, width: 'calc(100% - 20px)' }}>
          <thead>
            <tr>
              <th style={{ width: 30 }}></th>
              <th style={{ width: 150 }}>Belge Türü</th>
              <th>Ad</th>
              <th style={{ width: 42, textAlign: 'center' }}>Tipi</th>
              <th style={{ width: 90 }}>Boyut</th>
              <th style={{ width: 90 }}>Tarih</th>
            </tr>
          </thead>
          <tbody>
            {satirlarim.map((s, index) => (
              <tr key={s.id} style={{ cursor: 'pointer', background: secili.has(s.id) ? 'var(--yuz2)' : undefined }}
                onClick={e => satirTiklandi(e, s.id, index)}>
                <td onClick={e => e.stopPropagation()}>
                  <input type="checkbox" checked={secili.has(s.id)} onChange={() => secimiDegistir(s.id, index)} />
                </td>
                <td>{s.belgeTuru || ''}</td>
                <td>{s.ad}{s.varsayilan && resimMi(s) && ' (varsayılan)'}</td>
                <td style={{ textAlign: 'center' }} title={dosyaTipiBaslik(s.contentType)}>{dosyaTipiIkon(s.contentType)}</td>
                <td>{boyutYaz(s.boyut)}</td>
                <td>{tarihYaz(s.eklemeTarihi)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {satirlar?.length === 0 && <div className="bos" style={{ padding: 10 }}>Henüz dosya yok.</div>}
    </div>
  );
}
