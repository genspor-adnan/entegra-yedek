/**
 * Giriş ekranında son başarılı girişin kullanıcı kodu öntanımlı gelir
 * (kullanıcı 09.10.2026). Yalnız tarayıcıya ait bir kolaylık: parola
 * saklanmaz, depo erişilemezse (gizli pencere vb.) sessizce boş döner.
 */
/** Kurulum başına (bkz. api/cekirdek ANAHTAR): FETA girişinde başka kurulumun kullanıcısı önerilmesin. */
const KURULUM = (import.meta.env.BASE_URL ?? '/').replace(/^\/+|\/+$/g, '');
const ANAHTAR = `gentegre.sonKullanici${KURULUM ? `@${KURULUM}` : ''}`;

export function sonKullaniciOku(): string | null {
  try { return localStorage.getItem(ANAHTAR) || null } catch { return null }
}

export function sonKullaniciYaz(kod: string) {
  try { if (kod.trim()) localStorage.setItem(ANAHTAR, kod.trim()) } catch { /* yoksay */ }
}
