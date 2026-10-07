/**
 * Hedef sunucu adresini VEKİL YOLUNA çevirir.
 *
 * Tarayıcı hep GenProfil'in kendi kaynağına istek atar; adres yolun içinde
 * base64url olarak taşınır ve Node tarafındaki vekil (vekil.mjs) hedefe
 * iletir. Böylece bağlanılan sunucuda CORS ayarı GEREKMEZ - araç her kurumun
 * sunucusuna olduğu gibi bağlanır.
 */
export function vekilTabani(adres: string): string {
  const temiz = adres.trim().replace(/\/+$/, '').replace(/\/api$/i, '');
  const tam = /^https?:\/\//i.test(temiz) ? temiz : `http://${temiz}`;
  const b64 = btoa(tam).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  return `/vekil/${b64}`;
}

const ANAHTAR = 'genprofil.adres';

export const adresDeposu = {
  oku: () => localStorage.getItem(ANAHTAR) ?? '',
  yaz: (a: string) => localStorage.setItem(ANAHTAR, a),
  sil: () => localStorage.removeItem(ANAHTAR),
};
