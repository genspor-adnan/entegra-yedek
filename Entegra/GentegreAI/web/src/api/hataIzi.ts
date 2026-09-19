/**
 * SON HATA İZİ (871) — ekranda en son görülen API hata kodu.
 *
 * Bağlamsal yardım asistanı "bu hata ne demek" sorusunu cevaplayabilsin diye
 * istemci, sunucudan dönen SON hata kodunu (yalnız kodu: DOGRULAMA, YASAK,
 * IS_KURALI... ya da engel kodu) kısa süre hatırlar. Mesaj metni, alan
 * değerleri, kayıt verisi TUTULMAZ - asistana yalnız kod gider, açıklamayı
 * sunucu üretir.
 *
 * Rota değişince asistan paneli izi temizler; 3 dakikadan eski iz de
 * gönderilmez (eski ekranın hatasını yeni ekranda anlatmasın).
 */
export interface HataIzi { kod: string; zaman: number }

let son: HataIzi | null = null;
const dinleyiciler = new Set<() => void>();

export function hataIziKaydet(kod: string, engelKodu?: string) {
  const k = (engelKodu || kod || '').trim().toUpperCase();
  if (!k) return;
  son = { kod: k, zaman: Date.now() };
  dinleyiciler.forEach(d => d());
}

export function hataIziTemizle() {
  if (son === null) return;
  son = null;
  dinleyiciler.forEach(d => d());
}

/** 3 dakikadan yeni iz; yoksa null. */
export function sonHataIzi(): HataIzi | null {
  if (son && Date.now() - son.zaman > 3 * 60_000) return null;
  return son;
}

export function hataIziDinle(d: () => void) {
  dinleyiciler.add(d);
  return () => { dinleyiciler.delete(d) };
}
