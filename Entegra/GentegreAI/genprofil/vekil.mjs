/**
 * VEKİL (proxy): `/vekil/<base64url(adres)>/api/...` → `<adres>/api/...`
 *
 * NEDEN VEKİL: GenProfil hangi kurumun sunucusuna bağlanacağını kullanıcıdan
 * alır. Tarayıcıdan doğrudan istek atmak, o sunucunun CORS listesine aracın
 * adresini eklemeyi gerektirirdi - her kurumda bir ayar daha. Vekil ile
 * tarayıcı hep kendi kaynağına konuşur, hedefe Node tarafı gider: sunucuda
 * hiçbir ayar gerekmez.
 *
 * Hedef adres YOLUN İÇİNDE taşınır (başlıkta değil): böylece istemci yalnız
 * API tabanını değiştirir, istek gönderen ortak kod (api/cekirdek.ts) hiç
 * değişmez.
 */
import { request as httpIstek } from 'node:http';
import { request as httpsIstek } from 'node:https';

const KALIP = /^\/vekil\/([A-Za-z0-9_-]+)(\/.*)?$/;

/** base64url çöz - tarayıcıdaki `btoa` çıktısı URL güvenli hale getirilmiş olur. */
function adresCoz(b64) {
  const d = b64.replace(/-/g, '+').replace(/_/g, '/');
  return Buffer.from(d, 'base64').toString('utf8');
}

export function vekilAraKatmani(istek, yanit, sonraki) {
  const e = KALIP.exec(istek.url ?? '');
  if (!e) return sonraki();

  let hedef;
  try { hedef = new URL(adresCoz(e[1])) } catch {
    yanit.statusCode = 400;
    yanit.end('Gecersiz hedef adres');
    return;
  }
  // SADECE HTTP(S): `file:` ya da başka bir şema ile yerel dosya okutulmasın.
  if (hedef.protocol !== 'http:' && hedef.protocol !== 'https:') {
    yanit.statusCode = 400;
    yanit.end('Yalniz http/https');
    return;
  }

  const yol = (hedef.pathname.replace(/\/+$/, '') + (e[2] ?? '/')).replace(/\/{2,}/g, '/');
  const gonder = hedef.protocol === 'https:' ? httpsIstek : httpIstek;
  const basliklar = { ...istek.headers };
  // Host hedefin olmalı; vekilin kendi başlıkları hedefi yanıltmasın.
  basliklar.host = hedef.host;
  delete basliklar.origin;
  delete basliklar.referer;
  delete basliklar['accept-encoding'];

  const dis = gonder({
    protocol: hedef.protocol, hostname: hedef.hostname,
    port: hedef.port || (hedef.protocol === 'https:' ? 443 : 80),
    method: istek.method, path: yol, headers: basliklar,
  }, cevap => {
    yanit.statusCode = cevap.statusCode ?? 502;
    for (const [ad, deger] of Object.entries(cevap.headers)) {
      if (ad.toLowerCase() === 'transfer-encoding') continue;
      yanit.setHeader(ad, deger);
    }
    cevap.pipe(yanit);
  });
  dis.on('error', h => {
    yanit.statusCode = 502;
    yanit.setHeader('content-type', 'application/json; charset=utf-8');
    // Hata gövdesi uygulamanın hata biçiminde: ekran onu okuyup yazabilsin.
    yanit.end(JSON.stringify({ hata: { kod: 'SUNUCU', mesaj: `Sunucuya ulasilamadi: ${h.message}` } }));
  });
  istek.pipe(dis);
}
