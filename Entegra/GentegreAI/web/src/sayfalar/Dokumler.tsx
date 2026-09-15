import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import {
  hataMetni, type DokumKatalogu, type DokumKaydi, type DokumTanimi, type ListeYaniti, type OzetYaniti,
} from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { mesaj, onay } from '../bilesenler/mesaj';
import { DokumListesi } from './dokum/DokumListesi';
import { Tasarla } from './dokum/Tasarla';
import { Istatistik } from './dokum/Istatistik';
import { Onizleme } from './dokum/Onizleme';
import { BaskiOnizleme } from './dokum/BaskiOnizleme';
import { ozetMi } from './dokum/SonucTablosu';
import { bosTanim, kuralAraligi, parametreAlanlari } from './dokum/ortak';

/**
 * DÖKÜMLER & İSTATİSTİK (686) — mockup Ekranlar/Ayarlar/dokum_tasarimcisi.html
 * ve dokum_baski_onizleme.html; plan dokuman/10_DOKUM_ISTATISTIK_PLANI.md.
 *
 * Koşul verilerek (tarih aralığı, kurumlar, doktorlar…) tasarlanan, kaydedilip
 * tekrar çalıştırılan döküm. SQL istemcide YOK: tanım JSON gider, sorguyu
 * sunucudaki liste motoru üretir - alanlar katalogdan, değerler parametre.
 *
 * Mockup'ın "AI Asistan" ve "Zamanlama" sekmeleri BURADA YOK (Aşama C/D);
 * "Menüde Yeri" sekmesi de ekran değil, tasarım notuydu.
 *
 * Bu dosya yalnız VERİ ve AKIŞ (katalog, liste, seçim, kaydet, çalıştır);
 * her sekmenin çizimi `sayfalar/dokum/` altında, saf hesaplar `ortak.ts`'te.
 */

type Sekme = 'liste' | 'tasarla' | 'istatistik' | 'onizle' | 'baski';

export function Dokumler() {
  const { kullanici, yetki } = useOturum();
  const yazabilir = yetki('dokum', 'ekle');
  const yonetici = yetki('dokum', 'degistir');

  const [sekme, setSekme] = useState<Sekme>('liste');
  const [katalog, setKatalog] = useState<DokumKatalogu | null>(null);
  const [liste, setListe] = useState<DokumKaydi[]>([]);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState('');

  // Açık döküm (tasarım hâli). id=0 → yeni.
  const [id, setId] = useState(0);
  const [ad, setAd] = useState('');
  const [aciklama, setAciklama] = useState('');
  const [gorunurluk, setGorunurluk] = useState(0);
  const [surum, setSurum] = useState(0);
  const [tanim, setTanim] = useState<DokumTanimi>(bosTanim());
  const [kirli, setKirli] = useState(false);

  const [parametreler, setParametreler] = useState<Record<string, unknown>>({});
  const [yanit, setYanit] = useState<ListeYaniti | OzetYaniti | null>(null);
  const [sayfa, setSayfa] = useState(1);
  const [calisiyor, setCalisiyor] = useState(false);
  const [tumCekiliyor, setTumCekiliyor] = useState(false);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  const kaynak = useMemo(() => katalog?.kaynaklar.find(k => k.ad === tanim.kaynak) ?? null, [katalog, tanim.kaynak]);
  const kolonlar = kaynak?.kolonlar ?? [];

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try {
      const [k, l] = await Promise.all([api.dokumKatalogu(), api.dokumler()]);
      setKatalog(k); setListe(l);
    } catch (h) { setHata(hataMetni(h)) }
    finally { setYukleniyor(false) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const tanimYaz = (t: DokumTanimi) => { setTanim(t); setKirli(true); setYanit(null); };

  /** Yeni döküm: ilk kaynak (belge varsa o) ile boş tanım. */
  const yeni = () => {
    const ilk = katalog?.kaynaklar.find(k => k.ad === 'belge') ?? katalog?.kaynaklar[0];
    setId(0); setAd(''); setAciklama(''); setGorunurluk(0); setSurum(0);
    setTanim(bosTanim(ilk?.ad ?? '')); setKirli(false); setYanit(null); setParametreler({});
    setSekme('tasarla');
  };

  const ac = (d: DokumKaydi, kopya = false) => {
    // STANDART dokum (688) her zaman KOPYA olarak acilir: tasarim degisirse
    //   kullanicinin kendi dokumu olur, standart tanim yerinde kalir.
    kopya = kopya || !!d.sistem;
    setId(kopya ? 0 : d.id); setAd(kopya ? `${d.ad} (kopya)` : d.ad); setAciklama(d.aciklama);
    setGorunurluk(kopya ? 0 : d.gorunurluk); setSurum(kopya ? 0 : d.surum);
    setTanim({ ...bosTanim(d.kaynak), ...d.tanim }); setKirli(kopya); setYanit(null);
    // Parametre varsayılanları: tarih kuralı varsa aralığa çevir.
    const p: Record<string, unknown> = {};
    for (const a of parametreAlanlari(d.tanim)) { const ar = a.kural ? kuralAraligi(a.kural) : null; if (ar) p[a.alan] = ar; }
    setParametreler(p);
    setSekme('tasarla');
  };

  const kaynakDegistir = (kaynakAdi: string) => {
    if (kaynakAdi === tanim.kaynak) return;
    // Kaynak değişince alanlar anlamsızlaşır: tanım sıfırlanır (kullanıcı bilerek seçer).
    tanimYaz(bosTanim(kaynakAdi)); setParametreler({});
  };

  const kaydet = async () => {
    if (!ad.trim()) { void mesaj('Döküm adı zorunlu.'); setSekme('tasarla'); return }
    try {
      const r = await api.dokumKaydet({ id, ad: ad.trim(), aciklama, kaynak: tanim.kaynak, tanim, gorunurluk, roller: [] });
      setId(r.id); setKirli(false); setSurum(s => s + 1);
      await yukle();
      void mesaj('Döküm kaydedildi.');
    } catch (h) { setHata(hataMetni(h)) }
  };

  const sil = async (d: DokumKaydi) => {
    if (!await onay(`"${d.ad}" silinsin mi? (pasife alınır, sürüm geçmişi kalır)`, true)) return;
    try { await api.dokumSil(d.id); if (d.id === id) yeni(); await yukle(); }
    catch (h) { setHata(hataMetni(h)) }
  };

  /** Çalıştır: kayıtlı ve temizse id ile, değilse tanım gönderilerek (önizleme). */
  const calistir = useCallback(async (s = sayfa, boyut = 100) => {
    setCalisiyor(true); setHata('');
    try {
      const govde = { tanim: (id > 0 && !kirli) ? undefined : tanim, parametreler, sayfa: s, boyut };
      const y = await api.dokumCalistir(id > 0 && !kirli ? id : 0, govde);
      setYanit(y);
      return y;
    } catch (h) { setHata(hataMetni(h)); return null }
    finally { setCalisiyor(false) }
  }, [id, kirli, tanim, parametreler, sayfa]);

  const sayfaDegistir = (s: number) => { setSayfa(s); void calistir(s); };

  /** Baskı için tüm sayfaları (tavana kadar) çeker; sunucu sayfa tavanı 500. */
  const tumunuCek = async () => {
    const tavan = tanim.baski?.satirTavani ?? 2000;
    setTumCekiliyor(true);
    try {
      const satirlar: Record<string, unknown>[] = [];
      let ilk: ListeYaniti | null = null;
      for (let s = 1; satirlar.length < tavan; s++) {
        const y = await api.dokumCalistir(id > 0 && !kirli ? id : 0,
          { tanim: (id > 0 && !kirli) ? undefined : tanim, parametreler, sayfa: s, boyut: 500 });
        if (ozetMi(y)) { setYanit(y); return }
        ilk ??= y;
        satirlar.push(...y.satirlar);
        if (y.satirlar.length < 500 || satirlar.length >= y.toplamKayit) break;
      }
      if (ilk) setYanit({ ...ilk, satirlar: satirlar.slice(0, tavan) });
    } catch (h) { setHata(hataMetni(h)) }
    finally { setTumCekiliyor(false) }
  };

  /** Listeden ▶: standart dokum KOPYALANMADAN, kendi kimligiyle calisir (kirli degil). */
  const listedenCalistir = (d: DokumKaydi) => {
    if (d.sistem) {
      setId(d.id); setAd(d.ad); setAciklama(d.aciklama); setGorunurluk(2); setSurum(d.surum);
      setTanim({ ...bosTanim(d.kaynak), ...d.tanim }); setKirli(false); setYanit(null);
      const p: Record<string, unknown> = {};
      for (const a of parametreAlanlari(d.tanim)) { const ar = a.kural ? kuralAraligi(a.kural) : null; if (ar) p[a.alan] = ar; }
      setParametreler(p);
    } else ac(d);
    setSekme('onizle');
  };

  const sekmeler: [Sekme, string][] = [
    ['liste', 'Dökümlerim'], ['tasarla', 'Tasarla'], ['istatistik', '📈 İstatistik'],
    ['onizle', 'Önizleme'], ['baski', '🖨 Baskı'],
  ];

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Dökümler &amp; İstatistik</h1>
          <span className="yol">Yönetim › Dökümler</span>
          {id > 0 && <span className="rozet mavi">{ad} · v{surum}</span>}
          {kirli && <span className="rozet uyari">kaydedilmedi</span>}
        </div>
        <div className="basarac">
          {yazabilir && <button className="d bir" onClick={yeni}>＋ Yeni Döküm</button>}
          {yazabilir && <button className="d onay" onClick={() => void kaydet()} disabled={!kirli && id > 0}>💾 Kaydet</button>}
          <button className="d" onClick={() => { setSekme('onizle'); void calistir(1); }} disabled={!tanim.kaynak || calisiyor}>▶ Çalıştır</button>
          <span className="sonuk" style={{ marginLeft: 8 }}>Kaynak:</span>
          <select value={tanim.kaynak} onChange={e => kaynakDegistir(e.target.value)} disabled={!katalog}>
            {!tanim.kaynak && <option value="">—</option>}
            {(katalog?.kaynaklar ?? []).map(k => <option key={k.ad} value={k.ad}>{k.baslik}</option>)}
          </select>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
          {yukleniyor && <span className="sonuk">Yükleniyor…</span>}
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {!yazabilir && (
          <div className="bilgi-kutusu">Tasarım yetkiniz yok — paylaşılan dökümleri çalıştırabilir ve basabilirsiniz.</div>
        )}

        <div className="isk-sekmeler">
          {sekmeler.map(([k, adi]) => (
            <button key={k} type="button" className={`isk-sekme${sekme === k ? ' on' : ''}`}
                    onClick={() => setSekme(k)}
                    disabled={k === 'istatistik' && tanim.cikti !== 'ozet'}
                    title={k === 'istatistik' && tanim.cikti !== 'ozet' ? 'Çıktı biçimini "İstatistik" yapın' : undefined}>
              {adi}
              {k === 'liste' && liste.length > 0 && <span className="rozet gri">{liste.length}</span>}
            </button>
          ))}
        </div>

        {sekme === 'liste' && (
          <DokumListesi liste={liste} kaynaklar={katalog?.kaynaklar ?? []} seciliId={id} yukleniyor={yukleniyor}
                        onSec={d => ac(d)} onCalistir={listedenCalistir} onKopyala={d => ac(d, true)} onSil={d => void sil(d)} />
        )}

        {sekme === 'tasarla' && (
          <Tasarla tanim={tanim} setTanim={tanimYaz} kolonlar={kolonlar} kaynakAdi={kaynak?.baslik ?? tanim.kaynak}
                   ad={ad} setAd={v => { setAd(v); setKirli(true); }} aciklama={aciklama} setAciklama={v => { setAciklama(v); setKirli(true); }}
                   gorunurluk={gorunurluk} setGorunurluk={v => { setGorunurluk(v); setKirli(true); }}
                   kurumGeneliAcabilir={yonetici} kurallar={katalog?.kurallar ?? []} />
        )}

        {sekme === 'istatistik' && (
          <Istatistik tanim={tanim} setTanim={tanimYaz} kolonlar={kolonlar}
                      fnler={katalog?.fnler ?? []} kesmeler={katalog?.kesmeler ?? []} />
        )}

        {sekme === 'onizle' && (
          <Onizleme tanim={tanim} kolonlar={kolonlar} parametreler={parametreler} setParametreler={setParametreler}
                    yanit={yanit} calisiyor={calisiyor} onCalistir={() => void calistir(1)}
                    sayfa={sayfa} setSayfa={sayfaDegistir} />
        )}

        {sekme === 'baski' && (
          <BaskiOnizleme tanim={tanim} setTanim={tanimYaz} kolonlar={kolonlar} kaynakAdi={kaynak?.baslik ?? tanim.kaynak}
                         ad={ad} yanit={yanit} parametreler={parametreler} antet={antet}
                         kullaniciAdi={kullanici?.ad || kullanici?.kod || ''} surum={surum}
                         onTumunuCek={() => void tumunuCek()} tumCekiliyor={tumCekiliyor} />
        )}
      </div>
    </>
  );
}
