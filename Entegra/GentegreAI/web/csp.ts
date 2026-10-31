import { createHash } from 'node:crypto'
import type { Plugin } from 'vite'
import { YAZDIR_BETIGI } from './src/bilesenler/yazdirBetigi.ts'

/**
 * İÇERİK GÜVENLİK POLİTİKASI (kod inceleme 30.10.2026 K61). Oturum anahtarları localStorage'da; kaçan tek
 * bir XSS onları okuyup dışarı yollayabilirdi. Politika yalnız bu kökenden betik çalıştırır, istek yalnız bu
 * kökene (API aynı kökende, nginx proxy) gider - sızan betik veriyi DIŞARI gönderemez.
 *
 * Neden meta etiketi (nginx başlığı değil): her kurulumla birlikte gider, nginx'e dokunmadan yürürlüğe girer.
 * `frame-ancestors` meta'da çalışmaz - onu nginx'in X-Frame-Options DENY'ı karşılar.
 *
 * Satır içi betikler yalnız HASH ile: index.html'in yedek kurtarma betiği (derlenmiş HTML'den okunur) ve
 * yazdırma pencerelerinin ortak betiği (yazdirBetigi.ts). Yazdırma pencereleri ve sandbox iframe politikayı
 * devralır. Stil `unsafe-inline`: React `style=` öznitelikleri ve yazdırma şablonları satır içi stil kullanır;
 * stil enjeksiyonu betik çalıştırmaz.
 */
export function sha256(metin: string): string {
  return `'sha256-${createHash('sha256').update(metin, 'utf8').digest('base64')}'`
}

/** HTML'deki `src`'siz `<script>` gövdeleri. */
export function satirIciBetikler(html: string): string[] {
  return [...html.matchAll(/<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/gi)].map(m => m[1])
}

export function cspMetni(html: string, apiKokeni?: string): string {
  const hashler = [...new Set([...satirIciBetikler(html), YAZDIR_BETIGI].map(sha256))]
  const baglanti = ["'self'", ...(apiKokeni ? [apiKokeni] : [])]
  return [
    "default-src 'self'",
    `script-src 'self' ${hashler.join(' ')}`,
    "style-src 'self' 'unsafe-inline'",
    // e-Fatura XSLT şablonları dış logo (https) ve gömülü (data:) resim taşıyabilir.
    `img-src ${baglanti.join(' ')} data: blob: https:`,
    "font-src 'self' data:",
    `connect-src ${baglanti.join(' ')}`,
    // Çağrı kaydı santralin kendi adresinden (https) çalınır; önizlemeler blob.
    `media-src ${baglanti.join(' ')} blob: https:`,
    "frame-src 'self' blob:",
    "worker-src 'self' blob:",
    "object-src 'none'",
    "base-uri 'self'",
    "form-action 'self'",
  ].join('; ')
}

/** VITE_API mutlak bir adresse (ayrı köken) connect-src'ye eklenir; göreli yol aynı kökendir. */
export function apiKokeni(vitApi: string | undefined): string | undefined {
  if (!vitApi || !/^https?:\/\//i.test(vitApi)) return undefined
  try { return new URL(vitApi).origin } catch { return undefined }
}

/** Yalnız üretim derlemesinde; geliştirme sunucusu (HMR satır içi betik ister) etkilenmez. */
export function cspEklentisi(): Plugin {
  return {
    name: 'gentegre-csp',
    apply: 'build',
    transformIndexHtml: {
      order: 'post',
      handler(html) {
        const csp = cspMetni(html, apiKokeni(process.env.VITE_API))
        return html.replace(/<head>/i, `<head>\n    <meta http-equiv="Content-Security-Policy" content="${csp}" />`)
      },
    },
  }
}
