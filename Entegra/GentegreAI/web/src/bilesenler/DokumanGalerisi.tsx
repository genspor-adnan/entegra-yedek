import { useEffect, useRef, useState, type FormEvent } from 'react';
import { onay } from './mesaj';
import { api } from '../api/istemci';
import { type DokumanSatiri, hataMetni } from '../api/sozlesme';
import { tarihYaz } from './bicim';
import { dosyaIndirUrl } from './indir';
import { c } from '../dil/ceviri';
import { DosyaTuruSimgesi, dosyaTuru } from './DosyaTuruSimgesi';

const boyutYaz = (b: number) => b < 1024 ? `${b} B` : b < 1024 * 1024 ? `${(b / 1024).toFixed(0)} KB` : `${(b / 1024 / 1024).toFixed(1)} MB`;

const dosyaTipiBaslik = (contentType: string) => {
  if (contentType.startsWith('image/')) return 'Resim';
  if (contentType === 'application/pdf') return 'PDF';
  if (contentType.includes('word')) return 'Word';
  if (contentType.includes('excel') || contentType.includes('spreadsheet')) return 'Excel';
  if (contentType.includes('powerpoint') || contentType.includes('presentation')) return 'PowerPoint';
  if (contentType === 'text/plain') return 'Metin';
  return 'Dosya';
};

const resimMi = (s: DokumanSatiri) => s.contentType.startsWith('image/');

// Tur onerileri KARTA gore: personel ozluk belgeleri ile firma gorselleri
//   ayni listede olsaydi ikisi de kirli gorunurdu. Liste ONERIDIR - kullanici
//   serbest metin de yazabilir (datalist).
const OZLUK_TURLERI = [
  'Adli Sicil',
  'Diploma',
  'İş Sözleşmesi',
  'Kimlik Fotokopisi',
  'Sağlık Raporu',
  'SGK İşe Giriş',
];

// Firma karti (193): logo / kase / imza ayrimini BELGE TURU tasir; belgede
//   hangi gorselin basilacagi buna gore secilir (fn_sube_gorsel).
const FIRMA_GORSELLERI = ['Logo', 'Kaşe', 'İmza', 'Antet'];

// Demirbaş belgeleri (10.10.2026): eski yapılandırılmış belge türleri öneri oldu.
// Stok kartı (stok_karti_v2.html): ürün görseli, teknik föy, sertifika, kılavuz.
const STOK_BELGELERI = ['Ürün görseli', 'Teknik föy', 'Kullanım kılavuzu', 'Prospektüs', 'Sertifika', 'Analiz sertifikası'];

const DEMIRBAS_BELGELERI = [
  'Fatura / Satın Alma', 'Garanti Belgesi', 'Zimmet Tutanağı', 'Servis Raporu',
  'Kalibrasyon Kaydı', 'Kullanım Kılavuzu', 'Ruhsat / CE Belgesi', 'Fotoğraf',
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
            title={c('Büyük açmak için tıklayın')}
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
export function DokumanGalerisi({ kartAdi, kaynakId, saltOkunur, onSayi, yeniIstegi = 0, onYeniAlindi, gosterim, karo = true }: {
  kartAdi: string; kaynakId: number; saltOkunur: boolean;
  /** Yüklenince / değişince dosya sayısı (muayene sekmesiz: bölüm görünürlüğü ve menü davranışı). */
  onSayi?(n: number): void;
  /** Artınca "＋" basılmış gibi dosya seçme penceresi açılır (muayene sol menü "Dosyalar", dosya yokken). */
  yeniIstegi?: number;
  /** İstek tüketildi: çağıran sayacı sıfırlar - yoksa galeri yeniden kurulduğunda (kart tazelenince)
      seçme penceresi tekrar açılır (kullanıcı 15.10.2026: "fizik muayene save deyince dosya seçme ekranı"). */
  onYeniAlindi?(): void;
  /** GÖSTERİM KİPİ (kullanıcı 15.10.2026, muayene "Dosyalar için de edit/save modu"): yalnız sade liste -
      ad (tıkla: indir), tür, tarih; araç çubuğu ve önizleme yok. */
  gosterim?: boolean;
  /** KARO GÖRÜNÜMÜ (stok_karti_v2.html, kullanıcı 02.11.2026 "resim/doküman sekmesini mockup gibi yap"):
      yazılı araç düğmeleri + tür süzgeci + önizlemeli dosya kartları; ★ varsayılan resim çerçeveli. */
  karo?: boolean;
}) {
  const [satirlar, setSatirlar] = useState<DokumanSatiri[] | null>(null);
  const [resimUrlleri, setResimUrlleri] = useState<Record<number, string>>({});
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [bandAcik, setBandAcik] = useState(false);
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [paylasimMesaji, setPaylasimMesaji] = useState<string | null>(null);
  const [turSuzgec, setTurSuzgec] = useState('');
  // KART / LİSTE GÖRÜNÜMÜ (kullanıcı 02.11.2026 "seçenek ekle kart/liste görünümü olabilsin"): tercih tarayıcıda
  //   hatırlanır (kişisel kolaylık); okunamazsa kart görünümü.
  const [listeGorunum, setListeGorunum] = useState(() => {
    try { return localStorage.getItem('dgk-gorunum') === 'liste' } catch { return false }
  });
  const gorunumSec = (liste: boolean) => {
    setListeGorunum(liste);
    try { localStorage.setItem('dgk-gorunum', liste ? 'liste' : 'kart') } catch { /* tercih saklanamadı */ }
  };
  const [duzenlenen, setDuzenlenen] = useState<{ id: number; ad: string; belgeTuru: string } | null>(null);
  // MASRAF BEYANI (768): bir beyanda birden çok fiş var ve hangi görselin
  //   hangi harcamaya ait olduğu bilinmeli. Ayrı bir bağ tablosu açmak
  //   yerine beyanın SATIR BELGE NUMARALARINI tür önerisi yapıyoruz -
  //   kullanıcı yüklediği fişi listeden seçerek eşliyor.
  const [masrafBelgeNolari, setMasrafBelgeNolari] = useState<string[]>([]);
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
      setHata(hataMetni(h));
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
      .catch(h => setHata(hataMetni(h)));
  };

  useEffect(() => { yenile() }, [kartAdi, kaynakId]);
  const onSayiRef = useRef(onSayi);
  onSayiRef.current = onSayi;
  useEffect(() => { if (satirlar) onSayiRef.current?.(satirlar.length) }, [satirlar]);
  // Dış "yeni dosya" isteği: kullanıcının menü tıklamasıyla aynı anda - tarayıcı seçme penceresine izin verir.
  useEffect(() => {
    if (yeniIstegi > 0 && !saltOkunur) { girdiRef.current?.click(); onYeniAlindi?.() }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [yeniIstegi, saltOkunur]);

  useEffect(() => {
    if (kartAdi !== 'personelMasraf' || !kaynakId) { setMasrafBelgeNolari([]); return }
    let gecerli = true;
    api.kartDetaySayfasi('personelMasraf', kaynakId, 'harcamalar', 1, 200)
      .then(y => {
        if (!gecerli) return;
        setMasrafBelgeNolari((y.satirlar ?? [])
          .map(r => {
            const no = String((r as Record<string, unknown>).belgeNo ?? '').trim();
            const ack = String((r as Record<string, unknown>).aciklama ?? '').trim();
            return no && ack ? `${no} — ${ack}` : no;
          })
          .filter(Boolean));
      })
      .catch(() => { if (gecerli) setMasrafBelgeNolari([]) });
    return () => { gecerli = false };
  }, [kartAdi, kaynakId]);

  // Resim blob URL'lerini SADECE band acikken cek (liste ucu icerik dondurmuyor, sadece
  // metadata - gereksiz indirme yapmayalim).
  useEffect(() => {
    if (!bandAcik && !karo) return;
    resimler.forEach(s => {
      if (resimUrlleri[s.id]) return;
      api.dokumanIcerikUrl(s.id).then(url => setResimUrlleri(h => ({ ...h, [s.id]: url }))).catch(() => { /* onizleme yoksa sessiz gec */ });
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [bandAcik, karo, satirlar]);

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
      // ONBELLEKTEKI url SERBEST BIRAKILMAZ: ayni blob'u kucuk resim de
      //   kullaniyor, birakilirsa galerideki gorsel bozulur. Yalnizca bu
      //   indirme icin yeni uretilen url birakilir.
      const onbellekte = resimUrlleri[satir.id] !== undefined;
      dosyaIndirUrl(await icerikUrl(satir.id), satir.ad, !onbellekte);
    } catch (h) {
      setHata(hataMetni(h));
    }
  };

  const gor = async (satir: DokumanSatiri) => {
    try {
      window.open(await icerikUrl(satir.id), '_blank');
    } catch (h) {
      setHata(hataMetni(h));
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
      setHata(hataMetni(h));
    }
  };

  const varsayilanYap = async () => {
    if (seciliSatir) await calistir(() => api.dokumanVarsayilanYap(kartAdi, kaynakId, seciliSatir.id));
  };

  const seciliSil = async () => {
    if (secili.size === 0) return;
    // Uygulama penceresi (tarayici confirm'i "localhost diyor ki" basligiyla
    //   cikiyordu, kullanici).
    if (!await onay(`${secili.size} dosya silinsin mi?`, true)) return;
    let liste: DokumanSatiri[] | null = null;
    try {
      for (const id of secili) liste = await api.dokumanSil(kartAdi, kaynakId, id);
      setSatirlar(liste);
      setSecili(new Set());
    } catch (h) {
      setHata(hataMetni(h));
    }
  };

  if (gosterim) return satirlarim.length === 0
    ? <div className="fm-bos">{satirlar === null ? c('Yükleniyor…') : c('Dosya eklenmedi')}</div>
    : (
      <table className="fm-goster fm-tablo">
        <thead><tr><th>{c('Dosya')}</th><th>{c('Tür')}</th><th>{c('Eklenme')}</th></tr></thead>
        <tbody>{satirlarim.map(s => (
          <tr key={s.id}>
            <td><button type="button" className="baglanti" title={c('İndir')} onClick={() => void indir(s)}>{s.ad}</button></td>
            <td>{s.belgeTuru || '—'}</td>
            <td>{tarihYaz(s.eklemeTarihi)}</td>
          </tr>
        ))}</tbody>
      </table>
    );

  const tipler = [...new Set(satirlarim.map(x => dosyaTipiBaslik(x.contentType)))];
  const gorunen = turSuzgec ? satirlarim.filter(x => dosyaTipiBaslik(x.contentType) === turSuzgec) : satirlarim;
  const duzenlemePenceresi = (
    duzenlenen && (
        <>
          <div className="perde" style={{ zIndex: 420 }} onClick={() => setDuzenlenen(null)} />
          <form className="lookup-pencere" style={{ zIndex: 421, width: 'min(440px, 92vw)' }} onSubmit={e => void duzenlemeKaydet(e)}>
            <strong>{c('Doküman Düzenle')}</strong>
            <label className="alan">
              <span className="etiket">Belge Türü</span>
              <input
                value={duzenlenen.belgeTuru}
                onChange={e => setDuzenlenen(d => d && ({ ...d, belgeTuru: e.target.value }))}
                list="dokuman-belge-turu-secenekleri"
                autoFocus
                placeholder={kartAdi === 'personelMasraf'
                  ? 'Hangi harcamanın fişi (belge no)'
                  : kartAdi === 'demirbas' ? 'Fatura, garanti belgesi, tutanak...'
                  : kartAdi === 'kys-kalibrasyon' ? 'Kalibrasyon sertifikası'
                  : kartAdi === 'kys-egitim' ? 'Katılım listesi, sertifika...'
                  : kartAdi === 'stok' ? 'Ürün görseli, teknik föy, sertifika...'
                  : 'İş sözleşmesi, sağlık raporu...'}
              />
              <datalist id="dokuman-belge-turu-secenekleri">
                {(kartAdi === 'sube' ? FIRMA_GORSELLERI
                  : kartAdi === 'demirbas' ? DEMIRBAS_BELGELERI
                  : kartAdi === 'kys-egitim' ? ['Katılım listesi', 'Sertifika', 'Eğitim sunumu', 'Sınav']
                  : kartAdi === 'personelMasraf' ? masrafBelgeNolari
                  : kartAdi === 'stok' ? STOK_BELGELERI
                  : OZLUK_TURLERI)
                  .map(s => <option key={s} value={s} />)}
              </datalist>
            </label>
            <label className="alan">
              <span className="etiket">Ad</span>
              <input value={duzenlenen.ad} onChange={e => setDuzenlenen(d => d && ({ ...d, ad: e.target.value }))} />
            </label>
            <div className="lookup-alt">
              <span></span>
              <div style={{ display: 'flex', gap: 8 }}>
                <button type="button" onClick={() => setDuzenlenen(null)}>{c('İptal')}</button>
                <button type="submit" disabled={!duzenlenen.ad.trim()}>Kaydet</button>
              </div>
            </div>
          </form>
        </>
      )
  );

  // ÇERÇEVESİZ (kullanıcı 02.11.2026 "Resim / Doküman çerçeveyi kaldır"): başlıklı kutu yok - sekme adı
  //   zaten "Resim / Doküman"; araç çubuğu ve karolar doğrudan sekmede.
  if (karo) return (
    <div className="dgk">
      {!saltOkunur && (
        <input ref={girdiRef} type="file" style={{ display: 'none' }} onChange={e => void dosyaSecildi(e)}
          accept="image/jpeg,image/png,image/webp,image/gif,application/pdf,.doc,.docx,.xls,.xlsx,text/plain" />
      )}
      <div className="dgk-arac">
        {!saltOkunur && <button type="button" className="d bir" disabled={yukleniyor} onClick={() => girdiRef.current?.click()}>
          {yukleniyor ? '…' : '＋'} {c('Dosya ekle')}</button>}
        {!saltOkunur && <button type="button" className="d" disabled={!seciliResimMi} title={c('Yalnız resim varsayılan olabilir')}
                                onClick={() => void varsayilanYap()}>⭐ {c('Varsayılan yap')}</button>}
        <button type="button" className="d" disabled={!seciliSatir} onClick={() => seciliSatir && void gor(seciliSatir)}>👁 {c('Gör')}</button>
        {!saltOkunur && <button type="button" className="d" disabled={!seciliSatir} onClick={() => seciliSatir && void duzenle(seciliSatir)}>✎ {c('Düzenle')}</button>}
        <button type="button" className="d" disabled={!seciliSatir} onClick={() => seciliSatir && void indir(seciliSatir)}>⬇ {c('İndir')}</button>
        <button type="button" className="d" disabled={!seciliSatir} onClick={() => seciliSatir && void paylas(seciliSatir)}>🔗 {c('Paylaş')}</button>
        {!saltOkunur && <button type="button" className="d" disabled={secili.size === 0} title={c('Sil')} onClick={() => void seciliSil()}>🗑</button>}
        <span className="dgk-ip">{c('★ varsayılan resim kartta görünür')}</span>
        <select className="dgk-suzgec" value={turSuzgec} onChange={e => setTurSuzgec(e.target.value)}>
          <option value="">{c('Tüm türler')}</option>
          {tipler.map(t => <option key={t} value={t}>{c(t)}</option>)}
        </select>
        {/* Belirgin ikili seçici (kullanıcı 02.11.2026 "liste/kart butonları daha belirgin"): simge + yazı, seçili dolu. */}
        <span className="dgk-gorunum" role="group" aria-label={c('Görünüm')}>
          <button type="button" className={listeGorunum ? '' : 'secili'} aria-pressed={!listeGorunum}
                  onClick={() => gorunumSec(false)}><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1" width="5" height="5" rx="1" /><rect x="8" y="1" width="5" height="5" rx="1" /><rect x="1" y="8" width="5" height="5" rx="1" /><rect x="8" y="8" width="5" height="5" rx="1" /></svg>{c('Kart')}</button>
          <button type="button" className={listeGorunum ? 'secili' : ''} aria-pressed={listeGorunum}
                  onClick={() => gorunumSec(true)}><svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"><rect x="1" y="1.5" width="2.5" height="2.5" rx=".5" /><rect x="5" y="2" width="8" height="1.6" rx=".8" /><rect x="1" y="5.75" width="2.5" height="2.5" rx=".5" /><rect x="5" y="6.2" width="8" height="1.6" rx=".8" /><rect x="1" y="10" width="2.5" height="2.5" rx=".5" /><rect x="5" y="10.5" width="8" height="1.6" rx=".8" /></svg>{c('Liste')}</button>
        </span>
      </div>
      {hata && <div className="alan-hata" style={{ margin: '0 10px' }}>{hata}</div>}
      {paylasimMesaji && <div style={{ margin: '0 10px 10px', wordBreak: 'break-all', fontSize: 12, color: 'var(--soluk)' }}>{paylasimMesaji}</div>}
      {duzenlemePenceresi}
      {satirlar === null ? <div className="bos" style={{ padding: 10 }}>{c('Yükleniyor…')}</div>
        : satirlarim.length === 0 ? (
          <div className="dgk-bos" onClick={() => !saltOkunur && girdiRef.current?.click()}>
            {c('Henüz dosya yok.')}{!saltOkunur && <> {c('Eklemek için tıklayın.')}</>}</div>
        ) : listeGorunum ? (
        <table className="detay-tablo dgk-liste">
          <thead>
            <tr>
              <th style={{ width: 30 }}></th>
              <th style={{ width: 34 }}></th>
              <th>{c('Ad')}</th>
              <th style={{ width: 150 }}>{c('Belge Türü')}</th>
              <th style={{ width: 90 }}>{c('Tipi')}</th>
              <th style={{ width: 90 }}>{c('Boyut')}</th>
              <th style={{ width: 90 }}>{c('Tarih')}</th>
            </tr>
          </thead>
          <tbody>
            {gorunen.map(s => {
              const index = satirlarim.indexOf(s);
              return (
                <tr key={s.id} className={secili.has(s.id) ? 'secili' : undefined} title={c('Tıkla: seç · çift tıkla: aç')}
                    onClick={e => satirTiklandi(e, s.id, index)} onDoubleClick={() => void gor(s)}>
                  <td onClick={e => e.stopPropagation()} onDoubleClick={e => e.stopPropagation()}>
                    <input type="checkbox" checked={secili.has(s.id)} onChange={() => secimiDegistir(s.id, index)} />
                  </td>
                  <td style={{ textAlign: 'center' }}><DosyaTuruSimgesi contentType={s.contentType} ad={s.ad} boyut={18} /></td>
                  <td>{s.varsayilan && resimMi(s) ? '★ ' : ''}{s.ad}</td>
                  <td>{s.belgeTuru || ''}</td>
                  <td>{dosyaTipiBaslik(s.contentType)}</td>
                  <td>{boyutYaz(s.boyut)}</td>
                  <td>{tarihYaz(s.eklemeTarihi)}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
        ) : (
        <div className="dgk-izgara">
          {gorunen.map(s => {
            const index = satirlarim.indexOf(s);
            const tur = dosyaTuru(s.contentType, s.ad);
            return (
              <div key={s.id} className={`dgk-dosya${secili.has(s.id) ? ' secili' : ''}${s.varsayilan && resimMi(s) ? ' vars' : ''}`}
                   title={c('Tıkla: seç · çift tıkla: aç')}
                   onClick={e => satirTiklandi(e, s.id, index)} onDoubleClick={() => void gor(s)}>
                {/* SEÇİM KUTUSU (kullanıcı 02.11.2026 "itemlara check ekle"): tıklama her zaman ekler / çıkarır. */}
                <input type="checkbox" className="dgk-sec" checked={secili.has(s.id)} title={c('Seç')}
                       onClick={e => e.stopPropagation()} onDoubleClick={e => e.stopPropagation()}
                       onChange={() => secimiDegistir(s.id, index)} />
                {/* TÜRE GÖRE SİMGE (02.11.2026): resimde önizleme, diğerlerinde türün renkli kâğıt simgesi. */}
                <div className="dgk-on" style={resimMi(s) && resimUrlleri[s.id] ? undefined : { background: tur.zemin }}>
                  {resimMi(s) && resimUrlleri[s.id]
                    ? <img src={resimUrlleri[s.id]} alt={s.ad} />
                    : <DosyaTuruSimgesi contentType={s.contentType} ad={s.ad} />}
                </div>
                <div className="dgk-alt">
                  <b>{s.varsayilan && resimMi(s) ? '★ ' : ''}{s.ad}</b>
                  <small>{[dosyaTipiBaslik(s.contentType), s.belgeTuru, tarihYaz(s.eklemeTarihi), boyutYaz(s.boyut)].filter(Boolean).join(' · ')}</small>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );

  return (
    <div className="kagrup">
      <h6>
        Resim / Doküman
        {!saltOkunur && (
          <>
            <input ref={girdiRef} type="file" style={{ display: 'none' }} onChange={e => void dosyaSecildi(e)}
              accept="image/jpeg,image/png,image/webp,image/gif,application/pdf,.doc,.docx,.xls,.xlsx,text/plain" />
            <button type="button" className="d bir" title={c('Dosya Ekle')} disabled={yukleniyor} onClick={() => girdiRef.current?.click()}>
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
        <button type="button" className="d" title={c('Gör')} disabled={!seciliSatir} onClick={() => seciliSatir && void gor(seciliSatir)}>👁️</button>
        {!saltOkunur && (
          <button type="button" className="d" title="Düzenle" disabled={!seciliSatir} onClick={() => seciliSatir && void duzenle(seciliSatir)}>✏️</button>
        )}
        <button type="button" className="d" title={c('İndir')} disabled={!seciliSatir} onClick={() => seciliSatir && void indir(seciliSatir)}>⬇️</button>
        <button type="button" className="d" title={c('Paylaş')} disabled={!seciliSatir} onClick={() => seciliSatir && void paylas(seciliSatir)}>🔗</button>
        {!saltOkunur && seciliResimMi && (
          <button type="button" className="d" title={c('Varsayılan Yap')} onClick={() => void varsayilanYap()}>⭐</button>
        )}
      </h6>
      {hata && <div className="alan-hata" style={{ margin: '0 10px' }}>{hata}</div>}
      {paylasimMesaji && <div style={{ margin: '0 10px 10px', wordBreak: 'break-all', fontSize: 12, color: 'var(--soluk)' }}>{paylasimMesaji}</div>}

      {duzenlemePenceresi}

      {bandAcik && <ResimBandi resimler={resimler} resimUrlleri={resimUrlleri} />}

      {satirlarim.length > 0 && (
        <table className="detay-tablo" style={{ margin: 10, width: 'calc(100% - 20px)' }}>
          <thead>
            <tr>
              <th style={{ width: 30 }}></th>
              <th style={{ width: 150 }}>Belge Türü</th>
              <th>Ad</th>
              <th style={{ width: 42, textAlign: 'center' }}>Tipi</th>
              <th style={{ width: 90 }}>{c('Boyut')}</th>
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
                <td style={{ textAlign: 'center' }} title={dosyaTipiBaslik(s.contentType)}><DosyaTuruSimgesi contentType={s.contentType} ad={s.ad} boyut={16} /></td>
                <td>{boyutYaz(s.boyut)}</td>
                <td>{tarihYaz(s.eklemeTarihi)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {satirlar?.length === 0 && <div className="bos" style={{ padding: 10 }}>{c('Henüz dosya yok.')}</div>}
    </div>
  );
}
