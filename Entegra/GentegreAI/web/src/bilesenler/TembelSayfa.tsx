import { Component, Suspense, lazy, type ComponentType, type ReactNode } from 'react';
import { c } from '../dil/ceviri';

/**
 * ROTA BAZLI YÜKLEME (denetim 28.09.2026): uygulama tek bir 2,5 MB JS
 * paketiydi - giriş ekranı bile bütün modüllerin kodunu indiriyordu. Bir
 * ekranın kodu artık o ekrana ilk girildiğinde gelir.
 *
 * Rota yapısı, yetki kapıları ve derin bağlantılar DEĞİŞMEZ: `App.tsx`
 * aynı `<Route>` ağacını kurar, yalnız `element`in kodu sonradan yüklenir.
 *
 * Yükleme sırasında sayfa yerinde "Yükleniyor…" durur; parça yüklenemezse
 * (yeni sürüm yayınlandı, ağ koptu) sonsuz beklemek yerine hata ve "yeniden
 * dene" gösterilir.
 */
class ParcaHataSiniri extends Component<{ children: ReactNode }, { hata: boolean }> {
  state = { hata: false };
  static getDerivedStateFromError() { return { hata: true } }
  render() {
    if (!this.state.hata) return this.props.children;
    return (
      <div className="tam-ekran-bilgi" role="alert">
        <p>{c('Sayfa yüklenemedi. Bağlantınızı kontrol edip yeniden deneyin.')}</p>
        {/* Yeni sürüm yayınlandıysa eski parça adı artık yok: tam yenileme gerekir. */}
        <button className="d bir" type="button" onClick={() => window.location.reload()}>
          {c('Yeniden Dene')}
        </button>
      </div>
    );
  }
}

/**
 * Adlandırılmış dışa aktarımı tembel bileşene çevirir:
 * `const X = tembel(() => import('./sayfalar/X'), 'X')`.
 */
export function tembel<M extends Record<string, unknown>, K extends keyof M & string>(
  yukle: () => Promise<M>, ad: K,
): ComponentType<M[K] extends ComponentType<infer P> ? P : never> {
  const Tembel = lazy(async () => ({ default: (await yukle())[ad] as ComponentType<object> }));
  function TembelSayfa(p: object) {
    return (
      <ParcaHataSiniri>
        <Suspense fallback={<div className="tam-ekran-bilgi">{c('Yukleniyor…')}</div>}>
          <Tembel {...p} />
        </Suspense>
      </ParcaHataSiniri>
    );
  }
  TembelSayfa.displayName = `Tembel(${ad})`;
  return TembelSayfa as ComponentType<M[K] extends ComponentType<infer P> ? P : never>;
}
