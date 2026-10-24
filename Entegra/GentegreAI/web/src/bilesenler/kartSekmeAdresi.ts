/**
 * KART SEKME ADRESİ (kullanıcı 24.10.2026: "formlarda max ikonu yerine sekme ikonu, basınca formu yeni
 * sekmede açsın"). Pencerede açılmış bir kayıt kartının kendi sekmesindeki adresi.
 *
 * Adresi rotaları kuran yer (App `Yollar`) bilir: yetki, ürün modu ve modül süzmesi rotalarla AYNI olsun ki
 * dönen adres gerçekten açılsın. Kartlar (GenForm, BelgeKarti) liste tanımlarını içe almaz - döngüsel import
 * olurdu; çözücü bu küçük modül üzerinden verilir. Adres yoksa (rota yok / yetki yok) `null`: pencere sekme
 * düğmesini çizmez.
 */
export type KartSekmeIstegi = { kaynak: string; id: number; belgeTuru?: number };
type Cozucu = (k: KartSekmeIstegi) => string | null;

let cozucu: Cozucu = () => null;

export function kartSekmeAdresiAyarla(f: Cozucu) { cozucu = f }
export const kartSekmeAdresi = (k: KartSekmeIstegi) => cozucu(k);
