import { api } from '../api/istemci';
import type { ListeSatiri } from '../api/sozlesme';
import { type CipTanimi, type TarafBaglam, metin, sayiya, tarihYaz } from './tarafDuzeni';
export { AKTIF_KOSULU } from './tarafDuzeni';

/**
 * MÜŞTERİ / TEDARİKÇİ ARAMASI - cari düzeninin kuralları (mockup Ekranlar/taraf_arama.html, kullanıcı 05.11.2026).
 * Bileşenler TarafAramaCari.tsx'te, düzen nesnesi tarafDuzenleri.ts'te. Vergi / kimlik no ne kolonda ne aramada;
 * pasif cari hiç gelmez (kullanıcı 05.11.2026).
 */

/** Çipler sunucu koşulu olur: istemcide süzmek sayfaya sığan 50 satırı süzmek olurdu. */
export function cariCipleri(b: TarafBaglam): CipTanimi[] {
  return [
    { kod: 'aday',        ad: 'Aday',           ipucu: 'CRM adayı - henüz müşteri değil',      kosul: { alan: 'aday', op: 'esit', deger: 1 } },
    { kod: 'bakiyeli',    ad: 'Bakiyeli',       ipucu: 'Bakiyesi sıfır olmayanlar',            kosul: { alan: 'bakiye', op: 'esitDegil', deger: 0 } },
    { kod: 'vadesiGecen', ad: 'Vadesi geçen',   ipucu: 'Vadesi geçmiş borcu olanlar',
      kosul: { alan: b.tedarikci ? 'vadesiGecenOdeme' : 'vadesiGecen', op: 'buyuk', deger: 0 } },
    { kod: 'risk',        ad: 'Risk sınırında', ipucu: 'Risk limitinin %70 ve üstünde',        kosul: { alan: 'riskYuzde', op: 'buyukEsit', deger: 70 } },
    { kod: 'efatura',     ad: 'e-Fatura',       ipucu: 'e-Fatura mükellefi',                   kosul: { alan: 'efatura', op: 'esit', deger: 1 } },
    { kod: 'dovizli',     ad: 'Dövizli',        ipucu: 'Döviz bakiyesi olanlar',               kosul: { alan: 'dovizli', op: 'esit', deger: 1 } },
  ];
}


/** Satır rengi: aday (gri) › risk aşıldı › vadesi geçen (mockup lejantı). */
export function cariSatirSinifi(s: ListeSatiri, b: TarafBaglam): string {
  if (Number(s.aday) === 1 && Number(s.musteri) !== 1 && Number(s.tedarikci) !== 1) return 's-gri';
  if (sayiya(s.riskYuzde) > 100) return 's-risk';
  if (sayiya(b.tedarikci ? s.vadesiGecenOdeme : s.vadesiGecen) > 0) return 's-vade';
  return '';
}

/** Önizlemenin kart + son belgeler kısmı: satıra odaklanınca okunur, pencere açıkken id başına bir kez. */
export interface CariEk {
  fiyatListesi: string;
  vadeGun: string;
  notlar: string;
  belgeler: { tarih: string; ad: string; tutar: number }[];
  /** Kart ya da belge listesi okunamadı (yetki yok): blok çizilmez, hata gösterilmez. */
  kartYok: boolean;
  belgeYok: boolean;
}
const ekOnbellek = new Map<string, Promise<CariEk>>();
export function ekOnbellegiTemizle() { ekOnbellek.clear() }

/** ISO tarih -> "gg.aa" (önizlemedeki son belgeler). */
const gunAy = (v: unknown): string => tarihYaz(v).slice(0, 5);

export function cariEkGetir(id: number, tedarikci: boolean): Promise<CariEk> {
  const anahtar = `${id}:${tedarikci ? 't' : 'm'}`;
  let p = ekOnbellek.get(anahtar);
  if (!p) {
    p = (async () => {
      const ek: CariEk = { fiyatListesi: '', vadeGun: '', notlar: '', belgeler: [], kartYok: false, belgeYok: false };
      try {
        const y = await api.kartOku('cari', id);
        const k = y.kart;
        const alan = tedarikci ? 'alisFiyatListesiId' : 'satisFiyatListesiId';
        const fid = k[alan];
        ek.fiyatListesi = fid == null || fid === '' ? '' : (y.kodAd?.[alan]?.[String(fid)] ?? String(fid));
        const kosul = y.detaylar?.[tedarikci ? 'satinalmaKosul' : 'satisKosul']?.[0];
        ek.vadeGun = sayiya(kosul?.vadeGun) > 0 ? String(sayiya(kosul?.vadeGun)) : '';
        ek.notlar = metin(k.notlar);
      } catch { ek.kartYok = true }
      try {
        const y = await api.liste('belge', { sayfa: 1, boyut: 4, filtre: { alan: 'tarafId', op: 'esit', deger: id } });
        ek.belgeler = y.satirlar.map(b => ({
          tarih: gunAy(b.belgeTarihi),
          ad: [metin(b.turAdi), metin(b.belgeNo)].filter(Boolean).join(' '),
          tutar: sayiya(b.genelToplam),
        }));
      } catch { ek.belgeYok = true }
      return ek;
    })();
    ekOnbellek.set(anahtar, p);
    p.catch(() => ekOnbellek.delete(anahtar));
  }
  return p;
}
