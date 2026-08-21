import { useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type DokumanSatiri } from '../api/sozlesme';
import { tarihYaz } from './bicim';

const boyutYaz = (b: number) => b < 1024 ? `${b} B` : b < 1024 * 1024 ? `${(b / 1024).toFixed(0)} KB` : `${(b / 1024 / 1024).toFixed(1)} MB`;

const belgeTuruYaz = (contentType: string) => {
  if (contentType.startsWith('image/')) return 'Resim';
  if (contentType === 'application/pdf') return 'PDF';
  if (contentType.includes('word')) return 'Word';
  if (contentType.includes('excel') || contentType.includes('spreadsheet')) return 'Excel';
  if (contentType === 'text/plain') return 'Metin';
  return 'Doküman';
};

/**
 * Genel resim/doküman galerisi (057_dokuman.sql) - kaynak-bağımsız (kartAdi: "personel",
 * "cari", "kisi", "stok" - backend'de fiziksel tabloya çevriliyor). "Dosya Ekle" HER ZAMAN
 * gride ekler (kullanıcı: resim/doküman ayrım yapmadan tek liste); resimleri ayrıca
 * gözden geçirmek için açılır/kapanır bir "Resimleri Göster" bandı var (200x200, soldan
 * sağa) - resimler grid'den çıkmaz, band sadece EK bir görünüm.
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
  const girdiRef = useRef<HTMLInputElement | null>(null);
  const sonSeciliIndex = useRef<number | null>(null);

  // Tek tık = tek seçim (seçimi değiştirir). Ctrl/Cmd+tık = tek satırı ekle/çıkar.
  // Shift+tık = son seçilenden bu satıra kadar aralığı seç.
  const satirTiklandi = (e: React.MouseEvent, id: number, index: number) => {
    if (e.shiftKey && sonSeciliIndex.current !== null) {
      const [bas, son] = [sonSeciliIndex.current, index].sort((a, b) => a - b);
      const aralik = (satirlar ?? []).slice(bas, son + 1).map(s => s.id);
      setSecili(new Set(aralik));
    } else if (e.ctrlKey || e.metaKey) {
      setSecili(onceki => {
        const yeni = new Set(onceki);
        if (yeni.has(id)) yeni.delete(id); else yeni.add(id);
        return yeni;
      });
      sonSeciliIndex.current = index;
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
    const resimler = (satirlar ?? []).filter(s => s.contentType.startsWith('image/'));
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
      setSatirlar(await api.dokumanYukle(kartAdi, kaynakId, dosya, false));
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally {
      setYukleniyor(false);
    }
  };

  const varsayilanYap = async (dokumanId: number) => {
    try {
      setSatirlar(await api.dokumanVarsayilanYap(kartAdi, kaynakId, dokumanId));
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
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
    const yeniAd = window.prompt('Yeni ad:', satir.ad);
    if (!yeniAd || yeniAd === satir.ad) return;
    try {
      setSatirlar(await api.dokumanDuzenle(kartAdi, kaynakId, satir.id, yeniAd));
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    }
  };

  const seciliSil = async () => {
    if (secili.size === 0) return;
    if (!window.confirm(`${secili.size} dosya silinsin mi?`)) return;
    try {
      let liste: DokumanSatiri[] | null = null;
      for (const id of secili) liste = await api.dokumanSil(kartAdi, kaynakId, id);
      setSatirlar(liste);
      setSecili(new Set());
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    }
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

  const resimler = (satirlar ?? []).filter(s => s.contentType.startsWith('image/'));
  const seciliResim = secili.size === 1 ? (satirlar ?? []).find(s => secili.has(s.id)) : undefined;
  const seciliResimMi = seciliResim?.contentType.startsWith('image/') ?? false;

  return (
    <div className="kagrup">
      <h6>
        Resim / Doküman
        {!saltOkunur && (
          <>
            <input ref={girdiRef} type="file" style={{ display: 'none' }} onChange={e => void dosyaSecildi(e)}
              accept="image/jpeg,image/png,image/webp,image/gif,application/pdf,.doc,.docx,.xls,.xlsx,text/plain" />
            <button type="button" className="d" disabled={yukleniyor} onClick={() => girdiRef.current?.click()}>
              {yukleniyor ? 'Yükleniyor…' : '＋ Dosya Ekle'}
            </button>
          </>
        )}
        {resimler.length > 0 && (
          <button type="button" className="d" onClick={() => setBandAcik(a => !a)}>
            {bandAcik ? 'Resim Kapat' : 'Resimleri Göster'}
          </button>
        )}
        <button type="button" className="d" disabled={secili.size !== 1}
          onClick={() => { const s = (satirlar ?? []).find(x => secili.has(x.id)); if (s) void gor(s); }}>Gör</button>
        {!saltOkunur && (
          <button type="button" className="d" disabled={secili.size !== 1}
            onClick={() => { const s = (satirlar ?? []).find(x => secili.has(x.id)); if (s) void duzenle(s); }}>Düzenle</button>
        )}
        <button type="button" className="d" disabled={secili.size !== 1}
          onClick={() => { const s = (satirlar ?? []).find(x => secili.has(x.id)); if (s) void indir(s); }}>İndir</button>
        <button type="button" className="d" disabled={secili.size !== 1}
          onClick={() => { const s = (satirlar ?? []).find(x => secili.has(x.id)); if (s) void paylas(s); }}>Paylaş</button>
        {!saltOkunur && seciliResimMi && !seciliResim?.varsayilan && (
          <button type="button" className="d" onClick={() => seciliResim && void varsayilanYap(seciliResim.id)}>Varsayılan Yap</button>
        )}
        {!saltOkunur && (
          <button type="button" className="d teh" disabled={secili.size === 0} onClick={() => void seciliSil()}>Sil</button>
        )}
      </h6>
      {hata && <div className="alan-hata" style={{ margin: '0 10px' }}>{hata}</div>}
      {paylasimMesaji && <div style={{ margin: '0 10px 10px', wordBreak: 'break-all', fontSize: 12, color: 'var(--soluk)' }}>{paylasimMesaji}</div>}

      {bandAcik && (
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
                  ? <img src={resimUrlleri[s.id]} alt={s.ad} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                  : <span style={{ fontSize: 24 }}>🖼️</span>}
              </div>
              <div style={{ fontSize: 10, color: 'var(--soluk)', marginTop: 3, wordBreak: 'break-all' }}>{s.ad}</div>
            </div>
          ))}
        </div>
      )}

      {satirlar && satirlar.length > 0 && (
        <table className="detay-tablo" style={{ margin: 10, width: 'calc(100% - 20px)' }}>
          <thead>
            <tr>
              <th style={{ width: 30 }}></th>
              <th style={{ width: 80 }}>Belge Türü</th>
              <th>Ad</th>
              <th style={{ width: 90 }}>Boyut</th>
              <th style={{ width: 90 }}>Tarih</th>
            </tr>
          </thead>
          <tbody>
            {satirlar.map((s, index) => {
              const resimMi = s.contentType.startsWith('image/');
              return (
                <tr key={s.id} style={{ cursor: 'pointer', background: secili.has(s.id) ? 'var(--yuz2)' : undefined }}
                  onClick={e => satirTiklandi(e, s.id, index)}>
                  <td onClick={e => e.stopPropagation()}>
                    <input type="checkbox" checked={secili.has(s.id)} onChange={() => {
                      setSecili(onceki => {
                        const yeni = new Set(onceki);
                        if (yeni.has(s.id)) yeni.delete(s.id); else yeni.add(s.id);
                        return yeni;
                      });
                      sonSeciliIndex.current = index;
                    }} />
                  </td>
                  <td>{resimMi ? '🖼️' : '📄'} {belgeTuruYaz(s.contentType)}</td>
                  <td>{s.ad}{s.varsayilan && resimMi && ' (varsayılan)'}</td>
                  <td>{boyutYaz(s.boyut)}</td>
                  <td>{tarihYaz(s.eklemeTarihi)}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}

      {satirlar?.length === 0 && <div className="bos" style={{ padding: 10 }}>Henüz dosya yok.</div>}
    </div>
  );
}
