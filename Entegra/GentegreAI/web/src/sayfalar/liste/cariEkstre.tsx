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
 * Hasta / müşteri / tedarikçi listelerinin ve cari kartının "📄 Ekstre"si bu listeyi açar
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
  };
}

/** A4 ekstre + çıktı menüsü. Cari seçilmeden (tüm carilerin hareketi) menü kapalı. */
function CariEkstreCiktisi({ tarafId, ad, bas, bit }: { tarafId: number; ad: string; bas: string; bit: string }) {
  const { kullanici } = useOturum();
  const [veri, setVeri] = useState<ListeYaniti | null>(null);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);

  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);
  useEffect(() => {
    setVeri(null);
    if (!tarafId) return;
    const filtre = filtreBirlestir([
      { alan: 'tarafId', op: 'esit', deger: tarafId } as Kosul,
      tarihKosulu('islemTarihi', bas, bit),
    ]);
    // Döküm TÜM aralık: grid sayfalı, kâğıt sayfasız (bir carinin dönem hareketi birkaç yüz satır).
    api.liste('cari-ekstre', { sayfa: 1, boyut: 5000, filtre, toplam: ['borc', 'alacak'] })
       .then(setVeri).catch(h => mesaj(hataMetni(h)));
  }, [tarafId, bas, bit]);

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
