import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';

/** Adi cozulecek satir: urun kimligi ve hangi kaynakta arandigi. */
export interface UrunIstegi { id: number; hizmet: boolean }

/**
 * URUN KAPSAMLI DETAY SATIRLARINDA AD COZUMU (268 · 328).
 *
 * Kampanya ve prim detaylarinda kapsam bir URUNSE hucrede yalniz id duruyordu
 * ("4262") - hangi hizmet oldugu okunamiyordu. Adlar id -> ad sozlugunde
 * tutulur; satira secim aninda yazilan ad (ör. `iskontoYeriAdi`) onceliklidir,
 * bu sozluk yalniz ESKI kayitlarin bosluklarini doldurur.
 *
 * Stok ve hizmet AYRI kaynaklardan gelir; ad cozulemezse id gorunur ve satir
 * yine calisir - ad kozmetiktir, kaydi engellememeli.
 */
export function useUrunAdlari(
  aktif: boolean,
  satirlar: Record<string, unknown>[],
  /** Satirdan istek uretir; ad gerekmiyorsa null doner. */
  istekCoz: (satir: Record<string, unknown>) => UrunIstegi | null,
) {
  const [adlar, setAdlar] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!aktif) return;
    const eksik = satirlar
      .map(istekCoz)
      .filter((x): x is UrunIstegi => !!x && x.id > 0 && !adlar[String(x.id)]);
    if (eksik.length === 0) return;

    let iptal = false;
    void (async () => {
      const yeni: Record<string, string> = {};
      for (const kaynak of ['stok', 'hizmet'] as const) {
        const idler = eksik.filter(e => (kaynak === 'hizmet') === e.hizmet).map(e => e.id);
        if (idler.length === 0) continue;
        try {
          const y = await api.liste(kaynak, {
            sayfa: 1, boyut: idler.length,
            filtre: { op: 'or', kosullar: idler.map(id => ({ alan: 'id', op: 'esit', deger: id })) },
          });
          y.satirlar.forEach(r => {
            yeni[String(r.id)] = `${String(r.kod ?? '')} ${String(r.ad ?? '')}`.trim();
          });
        } catch { /* ad cozulemezse id gorunur - satir yine calisir */ }
      }
      if (!iptal && Object.keys(yeni).length) setAdlar(m => ({ ...m, ...yeni }));
    })();
    return () => { iptal = true };
  // `adlar` bilerek bagimlilikta degil: sozluk buyudukce dongu olurdu.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [aktif, satirlar]);

  /** Secim aninda gelen adi hemen sozluge yazar (ikinci istek atilmaz). */
  const ekle = (id: number, ad: string) =>
    setAdlar(m => ({ ...m, [String(id)]: ad }));

  return { adlar, ekle };
}

/**
 * KATEGORI SECENEKLERI (328, kullanici: "kategori combo hizmet/stok secimine
 * gore"). Kategori tablosu stok ve hizmet icin ORTAK; hangisinde kullanildigi
 * ancak SAYIMLA anlasilir - kategori LISTESI bu iki sayimi zaten donduruyor,
 * o yuzden kod tablosu yerine liste ucundan cekilir.
 */
export function useKategoriSecenekleri(aktif: boolean) {
  const [kategoriler, setKategoriler] = useState<
    { id: number; ad: string; stok: number; hizmet: number }[]>([]);

  useEffect(() => {
    if (!aktif) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('kategori', { sayfa: 1, boyut: 500 });
        if (!iptal) setKategoriler(y.satirlar.map(r => ({
          id: Number(r.id),
          // Kod + ad: kampanyadaki kategori combosuyla ayni okunus ("K1 - Genel").
          ad: `${String(r.kod ?? '')} ${String(r.ad ?? '')}`.trim(),
          stok: Number(r.stokSayisi ?? 0), hizmet: Number(r.hizmetSayisi ?? 0),
        })));
      } catch { /* liste alinamazsa kategori combosu bos kalir */ }
    })();
    return () => { iptal = true };
  }, [aktif]);

  return kategoriler;
}
