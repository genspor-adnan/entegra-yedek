import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type Kosul, type ListeSatiri, type ListeYaniti } from '../../api/sozlesme';
import { para } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { filtreBirlestir, tarihKosulu } from '../../bilesenler/gridSorgu';
import { mesaj } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { stil as icmalStili } from '../hasta/icmal/icmalStil';

/**
 * KASA › CARİ EKSTRE ARAÇLARI (kullanıcı 23.10.2026: "ekstre için sağ üst deseni olarak belge aç butonu
 * ve yazdır/önizle/kaydet olan icmaldeki butonu ekle", "cari ekstreye tarih aralığı filtre ekle").
 *
 * Hasta / müşteri / tedarikçi listelerinin ve cari kartının "Σ Ekstre"si bu listeyi açar
 * (`/cari-ekstre?tarafId=..&ad=..`) - ekstre tek ekranda. Burada:
 *  · `cariEkstreHedefi`: satırı ÜRETEN kayıt (önce kasa işlemi, yoksa belge) - çift tık ve "📄 Belge Aç".
 *  · `CariEkstreCiktisi`: icmal ekranlarının çıktı menüsü (Baskı Önizleme / Yazdır / PDF · Word · Excel ·
 *    HTML) - A4 ekstre, ekrandaki tarih aralığıyla aynı kümeden.
 */

export type EkstreHedefi = { tur: 'kasa' | 'belge'; id: number };

/** Ekstre satırını üreten kayıt; açılacak kayıt yoksa null. */
export function cariEkstreHedefi(satir: ListeSatiri | null | undefined): EkstreHedefi | null {
  if (!satir) return null;
  const kasaId = Number(satir.kasaIslemId ?? 0);
  const belgeId = Number(satir.belgeId ?? 0);
  if (kasaId) return { tur: 'kasa', id: kasaId };
  if (belgeId) return { tur: 'belge', id: belgeId };
  return null;
}

/** Liste ekranının Cari Ekstre bağlantıları: tarih aralığı, satırın kaydını açma, sağ üst çıktı menüsü. */
export function useCariEkstreEkrani(etkin: boolean, sorgu: URLSearchParams,
                                    ac: (h: EkstreHedefi) => void) {
  const [aralik, setAralik] = useState({ bas: '', bit: '' });
  const onTarihAraligi = useCallback((bas: string, bit: string) => setAralik({ bas, bit }), []);
  const tarafId = Number(sorgu.get('tarafId')) || 0;
  const ad = sorgu.get('ad') ?? '';
  /** Satırın kaydını açar; açılacak kayıt yoksa söyler. */
  const kayitAc = (satir: ListeSatiri | null | undefined) => {
    if (!satir) { mesaj('Önce bir satır seçin.'); return }
    const h = cariEkstreHedefi(satir);
    if (h) ac(h); else mesaj('Bu satırın bağlı olduğu bir belge yok.');
  };
  return {
    onTarihAraligi: etkin ? onTarihAraligi : undefined,
    kayitAc,
    basSag: etkin ? <CariEkstreCiktisi tarafId={tarafId} ad={ad} bas={aralik.bas} bit={aralik.bit} /> : undefined,
    // DETAY (kullanıcı 23.10.2026: "analiz sağına Detay butonu ekle" - belge kalemleri): ek görünüm.
    ekGorunumler: etkin ? [{ ad: 'Detay', ik: '🧾',
      icerik: <CariEkstreDetay tarafId={tarafId} bas={aralik.bas} bit={aralik.bit} onAc={kayitAc} /> }] : undefined,
  };
}

/** Ekstre kümesini (cari + tarih aralığı) tek istekte çeker - A4 ve Detay görünümü ortak. */
function useEkstreKumesi(tarafId: number, bas: string, bit: string) {
  const [veri, setVeri] = useState<ListeYaniti | null>(null);
  useEffect(() => {
    setVeri(null);
    if (!tarafId) return;
    const filtre = filtreBirlestir([
      { alan: 'tarafId', op: 'esit', deger: tarafId } as Kosul,
      tarihKosulu('islemTarihi', bas, bit),
    ]);
    // TÜM aralık: grid sayfalı, kâğıt / detay sayfasız (bir carinin dönem hareketi birkaç yüz satır).
    api.liste('cari-ekstre', { sayfa: 1, boyut: 5000, filtre, toplam: ['borc', 'alacak'] })
       .then(setVeri).catch(h => mesaj(hataMetni(h)));
  }, [tarafId, bas, bit]);
  return veri;
}

/** Belgenin KENDİ hareketi mi (tahsilat değil) - kalemleri o satırın altına gelir. */
const belgeHareketi = (s: ListeSatiri) => Number(s.belgeId ?? 0) > 0 && !Number(s.kasaIslemId ?? 0);

/**
 * DETAY GÖRÜNÜMÜ: ekstre satırları, her belge hareketinin altında o belgenin kalemleri (kod, ad,
 * miktar, KDV'li birim fiyat, KDV, tutar). Kalemler mevcut belge ucundan (belge başına bir istek,
 * en çok 200 belge). Satıra çift tık: kaydı açar.
 */
function CariEkstreDetay({ tarafId, bas, bit, onAc }: {
  tarafId: number; bas: string; bit: string; onAc(s: ListeSatiri): void;
}) {
  const veri = useEkstreKumesi(tarafId, bas, bit);
  const [kalemler, setKalemler] = useState<Record<number, Record<string, unknown>[]>>({});
  useEffect(() => {
    setKalemler({});
    if (!veri) return;
    const idler = [...new Set(veri.satirlar.filter(belgeHareketi).map(s => Number(s.belgeId)))].slice(0, 200);
    let iptal = false;
    void (async () => {
      for (let i = 0; i < idler.length; i += 8) {
        const parca = await Promise.all(idler.slice(i, i + 8).map(id =>
          api.belgeOku(id).then(y => [id, y.satirlar ?? []] as const).catch(() => [id, []] as const)));
        if (iptal) return;
        setKalemler(k => ({ ...k, ...Object.fromEntries(parca) }));
      }
    })();
    return () => { iptal = true };
  }, [veri]);

  if (!tarafId) return <div className="not" style={{ padding: 20 }}>Detay için bir cari seçin (listeden "Σ Ekstre").</div>;
  if (!veri) return <div className="not" style={{ padding: 20 }}>Yükleniyor…</div>;
  const p = (n: number) => para.format(n);
  return (
    <div className="ce-detay">
      <style>{DETAY_STILI}</style>
      <table>
        <thead><tr><th>Tarih</th><th>Belge No</th><th>İşlem / Kalem</th><th>Açıklama</th>
          <th className="s">Miktar</th><th className="s">Birim Fiyat</th><th className="s">Borç</th>
          <th className="s">Alacak</th><th className="s">Bakiye</th></tr></thead>
        <tbody>
          {veri.satirlar.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde hareket yok.</td></tr>}
          {veri.satirlar.map((x, i) => {
            const k = belgeHareketi(x) ? kalemler[Number(x.belgeId)] : undefined;
            return [
              <tr key={`h${String(x.id ?? i)}`} className="hareket" onDoubleClick={() => onAc(x)}
                  title="Çift tık: kaydı aç">
                <td>{tarihKisa(String(x.islemTarihi ?? ''))}</td><td>{String(x.belgeNo ?? '')}</td>
                <td><b>{String(x.turAdi ?? '')}</b></td><td>{String(x.aciklama ?? '')}</td>
                <td /><td />
                <td className="s">{sayi(x.borc) ? p(sayi(x.borc)) : ''}</td>
                <td className="s">{sayi(x.alacak) ? p(sayi(x.alacak)) : ''}</td>
                <td className="s">{p(sayi(x.bakiye))}</td>
              </tr>,
              ...(belgeHareketi(x) && !k
                ? [<tr key={`y${i}`} className="kalem"><td /><td /><td colSpan={7} className="soluk">kalemler yükleniyor…</td></tr>]
                : []),
              ...(k ?? []).map((r, j) => (
                <tr key={`k${i}-${j}`} className="kalem">
                  <td /><td className="soluk">{String(r.stokKodu ?? '')}</td>
                  <td>↳ {String(r.stokAdi || r.hizmetAdi || r.masrafAdi || r.aciklama || '')}</td>
                  <td className="soluk">{r.kdv != null ? `KDV %${sayi(r.kdv)}` : ''}</td>
                  <td className="s">{sayi(r.miktar).toLocaleString('tr-TR')}</td>
                  <td className="s">{p(sayi(r.birimFiyatKdvli ?? r.birimFiyat))}</td>
                  {/* KDV DAHİL: üstteki borç / alacak KDV'li - kalem toplamı ona eşit görünsün. */}
                  <td className="s soluk">{p(Math.round(sayi(r.tutar) * (1 + sayi(r.kdv) / 100) * 100) / 100)}</td><td /><td />
                </tr>
              )),
            ];
          })}
        </tbody>
      </table>
    </div>
  );
}

/** A4 ekstre + çıktı menüsü. Cari seçilmeden (tüm carilerin hareketi) menü kapalı. */
function CariEkstreCiktisi({ tarafId, ad, bas, bit }: { tarafId: number; ad: string; bas: string; bit: string }) {
  const { kullanici } = useOturum();
  const veri = useEkstreKumesi(tarafId, bas, bit);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const etiket = 'Cari Ekstre';
  return (
    <>
      <style>{icmalStili + EKSTRE_A4_STILI}</style>
      <CiktiMenusu etiket={etiket} dosyaAdi={`${etiket} ${ad}`.trim()} devre={!tarafId || !veri}>
        {veri && <EkstreA4 v={veri} ad={ad} bas={bas} bit={bit} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
      </CiktiMenusu>
    </>
  );
}

const sayi = (v: unknown) => Number(v ?? 0) || 0;
/** Detay görünümü: hareket satırı çizgili, kalemler girintili ve soluk. */
const DETAY_STILI = `
.ce-detay { background:var(--kart, #fff); border:1px solid var(--cizgi, #d9dee5); border-radius:6px; overflow:auto; }
.ce-detay table { width:100%; border-collapse:collapse; font-size:12.5px; }
.ce-detay th { position:sticky; top:0; background:var(--baslik-zemin, #f1f4f8); text-align:left; padding:6px 8px; font-weight:600; border-bottom:1px solid var(--cizgi, #d9dee5); }
.ce-detay td { padding:4px 8px; border-bottom:1px solid var(--cizgi-acik, #eef1f5); }
.ce-detay .s { text-align:right; white-space:nowrap; }
.ce-detay tr.hareket td { border-top:1px solid var(--cizgi, #d9dee5); }
.ce-detay tr.hareket:hover { background:var(--secili-zemin, #eef4fb); cursor:pointer; }
.ce-detay tr.kalem td { font-size:12px; }
.ce-detay tr.kalem td:nth-child(3) { padding-left:22px; }
.ce-detay .soluk { color:var(--soluk, #6b7785); }
.ce-detay .bos { text-align:center; padding:18px; color:var(--soluk, #6b7785); }
`;
/** İşlem ve Açıklama metin kolonu - icmal tablosu 3. kolondan sonrasını sağa yaslar. */
const EKSTRE_A4_STILI = `
.ce-a4t th:nth-child(3), .ce-a4t td:nth-child(3), .ce-a4t th:nth-child(4), .ce-a4t td:nth-child(4) { text-align:left; }
.ce-a4t th:nth-child(1) { width:11%; } .ce-a4t th:nth-child(2) { width:15%; } .ce-a4t th:nth-child(4) { width:24%; }
`;

/** A4 CARİ HESAP EKSTRESİ: para birimi başına hareketler, borç / alacak toplamı, kapanış bakiyesi. */
export function EkstreA4({ v, ad, bas, bit, antet, duzenleyen }: {
  v: ListeYaniti; ad: string; bas: string; bit: string;
  antet: Record<string, unknown> | null; duzenleyen: string;
}) {
  const p = (n: number) => para.format(n);
  // Para birimi grupları (sunucu sıralı verir); grup yoksa tek küme.
  const birimler = [...new Set(v.satirlar.map(s => String(s.dovizCinsi ?? '') || 'TL'))];
  const kume = (b: string) => v.satirlar.filter(s => (String(s.dovizCinsi ?? '') || 'TL') === b);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>CARİ HESAP EKSTRESİ</h3>
      <div className="a4-hasta">
        <span>Cari: <b>{ad || '—'}</b></span>
        <span>Dönem: {bas ? tarihKisa(bas) : 'başlangıç'} - {bit ? tarihKisa(bit) : 'bugün'}</span>
        <span>Hareket: {v.toplamKayit}</span>
      </div>
      {v.satirlar.length === 0 && <p className="a4-not">Bu dönemde hareket yok.</p>}
      {birimler.map(b => {
        const s = kume(b);
        const borc = s.reduce((t, x) => t + sayi(x.borc), 0);
        const alacak = s.reduce((t, x) => t + sayi(x.alacak), 0);
        const kapanis = sayi(s[s.length - 1]?.bakiye);
        return (
          <div key={b}>
            {birimler.length > 1 && <h4 style={{ margin: '8px 0 4px' }}>{b}</h4>}
            <table className="a4-t ce-a4t">
              <thead><tr><th>Tarih</th><th>Belge No</th><th>İşlem</th><th>Açıklama</th><th>Borç</th><th>Alacak</th><th>Bakiye</th></tr></thead>
              <tbody>
                {s.map((x, i) => (
                  <tr key={String(x.id ?? i)}>
                    <td>{tarihKisa(String(x.islemTarihi ?? ''))}</td><td>{String(x.belgeNo ?? '')}</td>
                    <td>{String(x.turAdi ?? '')}</td><td>{String(x.aciklama ?? '')}</td>
                    <td>{sayi(x.borc) ? p(sayi(x.borc)) : ''}</td><td>{sayi(x.alacak) ? p(sayi(x.alacak)) : ''}</td>
                    <td>{p(sayi(x.bakiye))}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <table className="a4-toplam"><tbody>
              <tr><td>Borç toplamı ({b})</td><td>{p(borc)}</td></tr>
              <tr><td>Alacak toplamı ({b})</td><td>{p(alacak)}</td></tr>
              <tr className="kalan"><td>KAPANIŞ BAKİYESİ ({b})</td><td>{p(kapanis)}</td></tr>
            </tbody></table>
          </div>
        );
      })}
      <p className="a4-not">Bakiye kümülatiftir: dönem öncesi hareketler kapanışa dahildir. Bu belge fatura yerine geçmez.</p>
    </div>
  );
}
