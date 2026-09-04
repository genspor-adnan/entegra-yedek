import { describe, it, expect } from 'vitest';
import gercek from './veri/primPlaniKart.json';

/**
 * PRIM PLANI KART METASI - sunucudan gelen gercek yapinin sozlesmesi.
 *
 * Bu ekran uzun bir tur boyunca "gorunen ama uygulanmayan ayar" uretti
 * (hekim_tipi, baz, kdv_haric). Kaldirilan alanlarin geri sizmasi ve
 * kalanlarin yerinin degismesi ancak testle tutulur - metayi elle acip
 * bakmak, iki tur sonra kimsenin yapmadigi sey.
 */
const meta = gercek.meta as unknown as {
  alanlar: { ad: string; tip: string; zorunlu?: boolean; kodlar?: Record<string, string> }[];
  detaylar: { ad: string; baslik: string; alanlar: { ad: string; yazilabilir?: boolean }[] }[];
};

const alanAdlari = meta.alanlar.map(a => a.ad);
const detay = (ad: string) => meta.detaylar.find(d => d.ad === ad)!;

describe('prim plani kart metasi', () => {
  it('BASLIK SIRASI: kimlik 5 + kapsam 5 (kullanici)', () => {
    expect(alanAdlari.filter(a => a !== 'id')).toEqual([
      'kod', 'ad', 'rol', 'primZamani', 'durum',
      'odeyenTipi', 'subeId', 'baslangic', 'bitis', 'aciklama',
    ]);
  });

  it('UYGULANMAYAN ayarlar kartta YOK', () => {
    // hekim_tipi kolonu db/376 ile dustu; baz ve kdv_haric hicbir uretim
    //   fonksiyonunda okunmuyor - ekranda durmalari yanlis hesaplanan primden
    //   daha sinsiydi.
    for (const ad of ['hekimTipi', 'baz', 'kdvHaric', 'oncelik', 'hekimId', 'odeyenKurumId'])
      expect(alanAdlari).not.toContain(ad);
  });

  it('ROL ve PRIM ZAMANI zorunlu - plan tek rol icin calisir', () => {
    expect(meta.alanlar.find(a => a.ad === 'rol')?.zorunlu).toBe(true);
    expect(meta.alanlar.find(a => a.ad === 'primZamani')?.zorunlu).toBe(true);
  });

  it('SATIRDA rol YOK (379): rol plan basliginda', () => {
    expect(detay('satirlar').alanlar.map(a => a.ad)).not.toContain('rol');
  });

  it('PRIM ALANLAR: kisi disindaki kolonlar SALT OKUNUR', () => {
    const alanlar = detay('taraflar').alanlar;
    expect(alanlar.map(a => a.ad)).toContain('tarafId');
    // Tipi / Bölüm / Görev tarafin KENDI kaydindan okunur - plan satirina
    //   kopyalanmaz, yoksa kisi bolum degistirince iki kayit ayrisirdi.
    for (const ad of ['tipi', 'bolum'])
      expect(alanlar.find(a => a.ad === ad)?.yazilabilir).toBe(false);
  });
});
