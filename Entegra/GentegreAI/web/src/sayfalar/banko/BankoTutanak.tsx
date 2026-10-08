import { useCallback, useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { OturumDetay } from '../../api/uclar/bankoOturum';
import { FARK_NEDENLERI } from '../../api/uclar/bankoOturum';

/**
 * KASA TESLİM TUTANAĞI `/banko-tutanak/:id` (991) — mockup
 * Ekranlar/Kayıt Kabul/kasa_teslim_tutanagi.html.
 *
 * YAZDIRILMAK İÇİN VAR: gün sonunda sayılan para elden teslim edilir ve iki
 * taraf imzalar. Ekrandaki akış kaydı yeterli değil - imza fiziksel bir
 * belgeye atılır ve denetimde o belge istenir.
 *
 * A (olması gereken) / B (sayım farkı) / teslim edilen üçlüsü mockup'tan:
 * tutar tek satırda verilirse "neden bu kadar" sorusu cevapsız kalır. Tutar
 * ayrıca YAZIYLA yazılır - rakamda tek hane değişikliği belgeyi sahteleştirir,
 * yazı onu yakalar.
 *
 * Döküm kalemleri: kupür sayımı, ödeme türü dağılımı, POS eşleşmesi ve çek
 * teslim listesi. Hepsi oturumun kendi verisinden gelir; tutanak ikinci bir
 * hesap yapmaz - yapsaydı ekranla tutanak arasında fark çıkabilirdi.
 */
export function BankoTutanak() {
  const { id } = useParams();
  const [d, setD] = useState<OturumDetay | null>(null);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    try { setD(await api.bankoOturumGetir(Number(id))) }
    catch (h) { setHata(hataMetni(h)) }
  }, [id]);
  useEffect(() => { void yukle() }, [yukle]);

  if (hata) return <div className="tt-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!d) return <div className="tt-sayfa sonuk">Yükleniyor…</div>;

  const o = d.oturum;
  const kupur = d.kupurler.filter(k => k.asama === 2);
  const nakitKovasi = d.turler.filter(t => t.kasaDurumu === 1);
  const digerKova = d.turler.filter(t => t.kasaDurumu !== 1);
  const cekToplam = d.cekler.reduce((a, c) => a + c.tutar, 0);

  return (
    <div className="tt-sayfa">
      <style>{stil}</style>

      <div className="tt-arac">
        <button type="button" className="d birincil" onClick={() => window.print()}>
          🖨 Tutanağı Yazdır
        </button>
        <span className="tt-not">
          Yazdırılan belge iki taraf imzasıyla saklanır; ekran kaydı imzanın yerine
          geçmez.
        </span>
      </div>

      <div className="tt-kagit">
        <div className="tt-ust">
          <div>
            <div className="tt-baslik">KASA TESLİM TUTANAĞI</div>
            <div className="tt-alt">Banko vardiya kapanışı — nakit teslimi</div>
          </div>
          <div className="tt-no">
            <div>{o.tutanakNo || '(numara kapanışta verilir)'}</div>
            <div className="tt-alt">Oturum #{o.id}</div>
          </div>
        </div>

        <div className="tt-kutular">
          <div className="tt-kutu">
            <div className="tt-kb">Teslim eden</div>
            <div className="tt-ad">{o.gorevli}</div>
            <div className="tt-alt">{o.bankoKod} — {o.bankoAd}</div>
            <div className="tt-alt">{o.vardiya || 'vardiya belirtilmedi'}</div>
          </div>
          <div className="tt-kutu">
            <div className="tt-kb">Teslim alan</div>
            <div className="tt-ad">{o.kapanisOnayId ? 'onaylandı' : '(imza bekliyor)'}</div>
            <div className="tt-alt">
              {o.kapanisTs ? new Date(o.kapanisTs).toLocaleString('tr-TR') : '—'}
            </div>
          </div>
          <div className="tt-kutu">
            <div className="tt-kb">Oturum</div>
            <div className="tt-alt">Açılış: {zaman(o.acilisTs)}</div>
            <div className="tt-alt">Teslim: {zaman(o.kapanisTalepTs)}</div>
            <div className="tt-alt">İşlem: {o.islemAdet}</div>
          </div>
        </div>

        {/* A / B / teslim edilen: tutar tek satirda verilirse "neden bu kadar"
            sorusu cevapsiz kalir. */}
        <table className="tt-tablo tt-hesap">
          <tbody>
            <tr><td>Devir (açılış)</td><td>{para(o.devirTutar)}</td></tr>
            {o.acilisFark !== 0 && (
              <tr><td>Açılış farkı</td><td>{para(o.acilisFark)}</td></tr>
            )}
            <tr><td>Nakit tahsilat</td><td>+{para(o.nakitTahsilat)}</td></tr>
            <tr><td>Nakit iade</td><td>−{para(o.nakitIade)}</td></tr>
            <tr className="tt-a"><td>A · KASADA OLMASI GEREKEN</td><td>{para(o.kapanisBeklenen)}</td></tr>
            <tr><td>Sayılan nakit</td><td>{para(o.kapanisSayim)}</td></tr>
            <tr className={'tt-b' + (o.kapanisFark !== 0 ? ' tt-kir' : '')}>
              <td>B · SAYIM FARKI (sayılan − olması gereken)</td>
              <td>{para(o.kapanisFark)}</td>
            </tr>
            <tr><td>Kasada bırakılan (yarının devri)</td><td>{para(o.kasadaBirakilan)}</td></tr>
            <tr className="tt-teslim">
              <td>TESLİM EDİLEN</td><td>{para(o.teslimEdilen)} ₺</td>
            </tr>
          </tbody>
        </table>
        <div className="tt-yazi">
          Yazıyla: <b>{yaziyla(o.teslimEdilen)}</b>
        </div>

        {o.kapanisFark !== 0 && (
          <div className="tt-fark">
            <div className="tt-kb">
              Fark beyanı — {para(Math.abs(o.kapanisFark))} ₺{' '}
              {o.kapanisFark < 0 ? 'noksan' : 'fazla'}
              {(FARK_NEDENLERI.find(f => f.kod === o.farkNeden)?.ad) &&
                ` · ${FARK_NEDENLERI.find(f => f.kod === o.farkNeden)!.ad}`}
            </div>
            <div>{o.farkAciklama || '(açıklama girilmedi)'}</div>
            <div className="tt-alt">
              {o.farkIslemId
                ? `Fark fişi: #${o.farkIslemId} - kasa bakiyesi sayıma çekildi.`
                : 'Fark fişi üretilmedi; kasa bakiyesi sayımdan farklı kalır.'}
            </div>
          </div>
        )}

        {kupur.length > 0 && (
          <>
            <div className="tt-bolum">Kupür dökümü</div>
            <table className="tt-tablo tt-kupur">
              <thead><tr><th>Kupür</th><th>Adet</th><th>Tutar</th></tr></thead>
              <tbody>
                {kupur.map(k => (
                  <tr key={k.birim}>
                    <td>{k.birim === 1 ? 'Bozuk' : `${k.birim} ₺`}</td>
                    <td>{k.adet}</td>
                    <td>{para(k.birim * k.adet)}</td>
                  </tr>
                ))}
                <tr className="tt-a">
                  <td>Sayılan toplam</td>
                  <td>{kupur.reduce((a, k) => a + k.adet, 0)}</td>
                  <td>{para(kupur.reduce((a, k) => a + k.birim * k.adet, 0))}</td>
                </tr>
              </tbody>
            </table>
          </>
        )}

        {d.turler.length > 0 && (
          <>
            <div className="tt-bolum">Ödeme türü dağılımı</div>
            <table className="tt-tablo">
              <thead>
                <tr><th>Tür</th><th>Adet</th><th>Net tutar</th><th>Sayıma girer</th></tr>
              </thead>
              <tbody>
                {[...nakitKovasi, ...digerKova].map(t => (
                  <tr key={t.tur}>
                    <td>{t.turAdi}</td><td>{t.adet}</td><td>{para(t.net)}</td>
                    <td>{t.kasaDurumu === 1 ? 'Evet' : 'Hayır'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </>
        )}

        {d.pos.some(p => p.cihazToplam != null) && (
          <>
            <div className="tt-bolum">POS gün sonu eşleşmesi</div>
            <table className="tt-tablo">
              <thead><tr><th>Terminal</th><th>Sistem</th><th>Cihaz</th><th>Fark</th></tr></thead>
              <tbody>
                {d.pos.filter(p => p.cihazToplam != null).map(p => (
                  <tr key={p.bankoPosId}>
                    <td>{p.bankaAdi} · {p.terminalNo}</td>
                    <td>{para(p.sistemToplam)}</td>
                    <td>{para(p.cihazToplam ?? 0)}</td>
                    <td className={p.fark ? 'tt-kir' : ''}>{para(p.fark ?? 0)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </>
        )}

        {d.cekler.length > 0 && (
          <>
            <div className="tt-bolum">
              Çek / senet teslim listesi — {d.cekler.length} evrak · {para(cekToplam)} ₺
            </div>
            <table className="tt-tablo">
              <thead>
                <tr><th>Tür</th><th>Seri no</th><th>Banka</th><th>Keşideci</th>
                  <th>Vade</th><th>Tutar</th></tr>
              </thead>
              <tbody>
                {d.cekler.map(c => (
                  <tr key={c.cekId}>
                    <td>{c.tur === 2 ? 'Senet' : 'Çek'}</td>
                    <td>{c.seriNo || '—'}</td>
                    <td>{c.bankaAdi || '—'}</td>
                    <td>{c.kesideci || c.tarafUnvan || '—'}</td>
                    <td>{c.vade ? new Date(c.vade).toLocaleDateString('tr-TR') : '—'}</td>
                    <td>{para(c.tutar)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <div className="tt-alt tt-ic">
              Bu evrak nakit sayımına girmez; fiziken teslim edilir ve portföyde izlenir.
            </div>
          </>
        )}

        <div className="tt-imza">
          <div>
            <div className="tt-cizgi" />
            Teslim eden · {o.gorevli}
          </div>
          <div>
            <div className="tt-cizgi" />
            Teslim alan
          </div>
        </div>

        <div className="tt-dipnot">
          Yukarıda dökümü verilen nakit ve kıymetli evrak sayılarak teslim edilmiştir.
          Kapanan oturum düzeltilmez; hatalı tahsilat iade/düzeltme fişiyle çözülür.
        </div>
      </div>
    </div>
  );
}

const para = (n: number) =>
  n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const zaman = (t: string | null) =>
  t ? new Date(t).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' }) : '—';

/**
 * Tutarı yazıyla: rakamda tek hane değişikliği belgeyi sahteleştirir, yazı
 * onu yakalar - bu yüzden tutanakta ikisi birlikte durur.
 */
function yaziyla(n: number): string {
  const birler = ['', 'bir', 'iki', 'üç', 'dört', 'beş', 'altı', 'yedi', 'sekiz', 'dokuz'];
  const onlar = ['', 'on', 'yirmi', 'otuz', 'kırk', 'elli', 'altmış', 'yetmiş', 'seksen', 'doksan'];
  const basamak = (x: number): string => {
    if (x === 0) return '';
    const y = Math.floor(x / 100), k = Math.floor((x % 100) / 10), b = x % 10;
    return (y ? (y === 1 ? 'yüz' : birler[y] + 'yüz') : '') + onlar[k] + birler[b];
  };
  const grup = (x: number, ad: string): string => {
    if (x === 0) return '';
    // "birbin" denmez, "bin" denir; ama "birmilyon" denir.
    const g = basamak(x);
    return (x === 1 && ad === 'bin' ? '' : g) + ad;
  };
  const tam = Math.floor(Math.abs(n));
  const kurus = Math.round((Math.abs(n) - tam) * 100);
  if (tam === 0 && kurus === 0) return 'sıfır Türk Lirası';
  const metin =
    grup(Math.floor(tam / 1_000_000_000) % 1000, 'milyar')
    + grup(Math.floor(tam / 1_000_000) % 1000, 'milyon')
    + grup(Math.floor(tam / 1000) % 1000, 'bin')
    + basamak(tam % 1000);
  return (n < 0 ? 'eksi ' : '') + (metin || 'sıfır') + ' Türk Lirası'
         + (kurus ? ` ${basamak(kurus)} kuruş` : '');
}

const stil = `
.tt-sayfa { padding: 14px 16px 24px; }
.tt-arac { display:flex; gap:10px; align-items:center; margin-bottom:12px; flex-wrap:wrap; }
.tt-not { color: var(--ikincil-metin, #6b7a8b); font-size:11px; }
.tt-kagit { max-width: 820px; background:#fff; color:#1f2d3a; border:1px solid #cdd6e0;
  border-radius:4px; padding:24px 28px; margin:0 auto; font-size:12px; }
.tt-ust { display:flex; justify-content:space-between; align-items:flex-start;
  border-bottom:2px solid #1f2d3a; padding-bottom:8px; margin-bottom:14px; }
.tt-baslik { font-size:17px; font-weight:bold; letter-spacing:.5px; }
.tt-alt { color:#6b7a8b; font-size:11px; }
.tt-no { text-align:right; font-family:Consolas,monospace; font-weight:bold; }
.tt-kutular { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; margin-bottom:14px; }
.tt-kutu { border:1px solid #e3e9f0; border-radius:4px; padding:8px 10px; }
.tt-kb { font-size:10.5px; color:#6b7a8b; text-transform:uppercase; letter-spacing:.4px;
  margin-bottom:3px; }
.tt-ad { font-weight:bold; }
.tt-tablo { border-collapse:collapse; width:100%; margin-bottom:10px; }
.tt-tablo th { text-align:left; font-size:10.5px; color:#3a5573; border-bottom:1px solid #cdd6e0;
  padding:4px 6px; }
.tt-tablo td { border-bottom:1px solid #eef2f6; padding:4px 6px; }
.tt-tablo td:last-child, .tt-tablo th:last-child { text-align:right;
  font-family:Consolas,monospace; }
.tt-hesap td:first-child { width:70%; }
.tt-a td, .tt-b td { font-weight:bold; background:#f5f8fb; }
.tt-teslim td { font-weight:bold; font-size:14px; border-top:2px solid #1f2d3a;
  border-bottom:2px solid #1f2d3a; }
.tt-kir td, td.tt-kir { color:#b3261e; }
.tt-yazi { font-size:11.5px; margin:-4px 0 12px; }
.tt-fark { border:1px solid #f3c4bf; background:#fbe9e7; border-radius:4px; padding:8px 10px;
  margin-bottom:12px; }
.tt-bolum { font-weight:bold; font-size:12px; margin:12px 0 4px; border-bottom:1px solid #cdd6e0;
  padding-bottom:3px; }
.tt-kupur td:first-child { width:40%; }
.tt-ic { margin:-6px 0 10px; }
.tt-imza { display:grid; grid-template-columns:1fr 1fr; gap:40px; margin-top:28px; }
.tt-cizgi { border-top:1px solid #1f2d3a; margin-bottom:4px; height:34px; }
.tt-dipnot { margin-top:18px; font-size:10.5px; color:#6b7a8b; line-height:1.6;
  border-top:1px solid #e3e9f0; padding-top:8px; }

/* YAZDIRMA: araç çubuğu ve uygulama kabuğu kâğıda çıkmaz; tutanak tek
   sayfada, kenarsız. */
@media print {
  .tt-arac, .kabuk > *:not(.ana), .ana > *:not(.tt-sayfa) { display:none !important; }
  .tt-sayfa { padding:0; }
  .tt-kagit { border:none; border-radius:0; max-width:none; padding:0; }
  .tt-tablo { page-break-inside:avoid; }
}
`;

export default BankoTutanak;
