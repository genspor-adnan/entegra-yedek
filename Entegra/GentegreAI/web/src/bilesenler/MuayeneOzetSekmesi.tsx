import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { tarihSaat } from './bicim';
import { c, ilacAdi } from '../dil/ceviri';
import type { EkSekmeBaglami } from './GenForm';
import type { SekmeVerisi } from './MuayeneSekmeleri';

/**
 * MUAYENE ÖZETİ SEKMESİ (mockup Ekranlar/Muayene/muayene_karti_v2.html).
 *
 * Kart bu sekmeyle açılır: diğer sekmelerde YAZILANIN derlenmiş görünümü.
 * Burada alan yazılmaz - özet kutusuna tıklamak ilgili sekmeye götürür.
 *
 *  - Üstte beş kutu: vital · ana tanı · istemler · reçete · karar.
 *  - Solda özet metni: kartın değerleri + son vital + tanı adları + onaylı
 *    anormal sonuçlar + reçete. Metin ekranda BİRLEŞTİRİLİR, hesap yapılmaz;
 *    rapora / e-Nabız'a giden derlenmiş metin yine "Muayene Özeti" penceresi.
 *  - Sağda tamamlama kontrolü (SUNUCUNUN kuralı - "Tamamla" ile aynı
 *    liste), bugün bekleyen istemler ve son muayeneler.
 */
type Satir = Record<string, unknown>;
const m = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);

export function MuayeneOzetSekmesi({ baglam, muayeneId, sekme, tazele }: {
  baglam: EkSekmeBaglami;
  muayeneId: number;
  sekme: SekmeVerisi | null;
  /** Kart her kaydedildiğinde artar - kontrol listesi ve sonuçlar tazelenir. */
  tazele: number;
}) {
  const [sonuc, setSonuc] = useState<{ istemler: Satir[]; sonuclar: Satir[]; radyoloji: Satir[] } | null>(null);
  /** Fizik muayene metni: KAYDEDILMIS bulgu satirlarindan, sunucuda derlenir
      (bulgu_ozet alani rapor metnidir, hekim duzeltmis olabilir; bu sekme
      gridin guncel halini gosterir). */
  const [bulguMetni, setBulguMetni] = useState('');
  const [kontrol, setKontrol] = useState<{ ad: string; tamam: boolean; mesaj: string; alan: string }[] | null>(null);

  useEffect(() => {
    let iptal = false;
    void api.muayeneSonuclari(muayeneId)
      .then(y => { if (!iptal) setSonuc(y as never) }).catch(() => {});
    // EKRANDAKI satirlar (kaydedilmemis degisiklik dahil - kullanici: "yazdiklarim
    //   ozete yansimadi"); metin sunucuda ayni kuralla derlenir, YAZILMAZ.
    const satirlar = (baglam.detaySatirlari('bulgular') as Satir[])
      .filter(r => sayi(r.sablonAlanId) > 0)
      .map(r => ({
        sablonAlanId: sayi(r.sablonAlanId),
        normal: r.normal === true || sayi(r.normal) === 1,
        degerMetin: m(r.degerMetin) || null,
        degerSayi: r.degerSayi === null || r.degerSayi === undefined || r.degerSayi === ''
          ? null : Number(r.degerSayi),
        taraf: r.taraf === null || r.taraf === undefined || r.taraf === '' ? null : sayi(r.taraf),
      }));
    void api.muayeneBulguMetniOnizle(muayeneId, satirlar)
      .then(y => { if (!iptal) setBulguMetni(y.metin) }).catch(() => {});
    void api.muayeneTamamlamaKontrol(muayeneId)
      .then(y => { if (!iptal) setKontrol(y.kontroller) }).catch(() => {});
    return () => { iptal = true };
  }, [muayeneId, tazele]);

  const d = baglam.deger;
  const git = baglam.sekmeyeGit;

  // VİTAL: detay satırları sunucuda "zaman desc" sıralı - ilk satır son ölçüm.
  const v = baglam.detaySatirlari('vitaller')[0] as Satir | undefined;
  const vitalMetin = v ? [
    sayi(v.sistolik) > 0 ? `TA ${m(v.sistolik)}/${m(v.diyastolik)} mmHg` : '',
    sayi(v.nabiz) > 0 ? `Nabız ${m(v.nabiz)}/dk` : '',
    sayi(v.spo2) > 0 ? `SpO₂ %${m(v.spo2)}` : '',
    m(v.ates) ? `Ateş ${m(v.ates).replace('.', ',')} °C` : '',
    sayi(v.solunum) > 0 ? `SS ${m(v.solunum)}/dk` : '',
    m(v.agriVas) ? `VAS ${m(v.agriVas)}/10` : '',
    m(v.bki) ? `BKİ ${m(v.bki).replace('.', ',')}` : '',
  ].filter(Boolean).join(' · ') : '';

  // TANI: tür 1 = ana tanı (sunucunun ux_tani_ana kuralıyla aynı kod).
  const tanilar = baglam.detaySatirlari('tanilar') as Satir[];
  const ana = tanilar.find(t => sayi(t.tur) === 1);

  const bekleyenLab = (sonuc?.istemler ?? []).filter(i => ![5, 9].includes(sayi(i.durum ?? 1)));
  const bekleyenRad = (sonuc?.radyoloji ?? []).filter(r => !r.onayTarihi);
  // ANORMAL SONUÇ: yalnız bayraklı (H/L/HH/LL) ya da panik - normal değerler
  //   özete yazılmaz, sekmede duruyor.
  const anormal = (sonuc?.sonuclar ?? []).filter(s =>
    m(s.deger) && (sayi(s.panik) === 1 || ['H', 'L', 'HH', 'LL'].includes(m(s.bayrak))));

  const ilaclar = (sekme?.receteSatirlari ?? []) as Satir[];

  const bolum = (baslik: string, ic: React.ReactNode) => (
    <><h6>{baslik}</h6><p>{ic}</p></>
  );

  const eksikSay = (kontrol ?? []).filter(k => !k.tamam).length;

  return (
    <div className="moz">
      {/* OZET KUTULARI bilgi bandina rozet oldu (kullanici; MuayeneDurumSeridi). */}
      <div className="moz-gvd">
        <div className="kagrup moz-metin">
          <h6 className="moz-bas">{c('Muayene özeti')}
            <span className="moz-sp not">{c('diğer sekmelerden derlenir')}</span>
            <button type="button" className="d" onClick={() => git('Şablon')}>✎ {c('Düzenle')}</button>
          </h6>
          <div className="moz-ic">
            {m(d.sikayet) && bolum(c('Şikâyet'), m(d.sikayet))}
            {m(d.hikaye) && bolum(c('Hikâye'), m(d.hikaye))}
            {bulguMetni && bolum(c('Fizik muayene'), bulguMetni)}
            {vitalMetin && bolum(c('Vital'), vitalMetin)}
            {tanilar.length > 0 && bolum(c('Tanılar'), tanilar.map((t, i) => (
              <span key={i}>{i > 0 ? ' · ' : ''}{t === ana ? <b>{m(t.taniAd)}</b> : m(t.taniAd)}
                {t === ana && <span className="rozet mavi moz-r">{c('Ana')}</span>}</span>)))}
            {anormal.length > 0 && bolum(c('Tetkik'), anormal.map((s, i) => (
              <span key={i}>{i > 0 ? ' · ' : ''}
                <span className={sayi(s.panik) === 1 ? 'moz-panik' : ''}>
                  {m(s.ad)} {m(s.deger)} {m(s.birim)} ({sayi(s.panik) === 1 ? c('panik') : m(s.bayrak)})</span></span>)))}
            {ilaclar.length > 0 && bolum(c('Tedavi'),
              ilaclar.map(r => ilacAdi(m(r.ilac))).join(' · '))}
            {m(d.karar) && bolum(c('Değerlendirme / Plan'), m(d.karar))}
            {!m(d.sikayet) && !m(d.hikaye) && !m(d.karar) && tanilar.length === 0 && (
              <p className="not">{c('Henüz bir şey yazılmadı — Şablon Muayene sekmesinden başlayın.')}</p>
            )}
          </div>
        </div>

        <div className="moz-sag">
          <div className="kagrup">
            <h6 className="moz-bas">{c('Tamamlama kontrolü')}
              <span className="moz-sp not">{kontrol === null ? '…'
                : eksikSay === 0 ? c('hazır') : `${eksikSay} ${c('eksik')}`}</span></h6>
            <ul className="moz-liste">
              {(kontrol ?? []).map((k, i) => (
                <li key={i} className={k.tamam ? '' : 'eksik'} title={k.tamam ? undefined : k.mesaj}>
                  {k.tamam ? '✅' : '⚠'} {k.ad}
                </li>
              ))}
            </ul>
          </div>

          <div className="kagrup">
            <h6 className="moz-bas">{c('Bekleyen istemler')}</h6>
            <ul className="moz-liste">
              {bekleyenLab.length + bekleyenRad.length === 0 && <li className="not">{c('Bekleyen istem yok.')}</li>}
              {bekleyenLab.map((i, n) => (
                <li key={`l${n}`}>
                  {sayi(i.oncelik) === 3 && <span className="rozet hata">{c('Acil')}</span>}
                  {c('Lab')} {m(i.istemNo)}
                  <span className="moz-sp not">{sayi(i.onayli)}/{sayi(i.tetkik)} {c('onaylı')}</span>
                </li>
              ))}
              {bekleyenRad.map((r, n) => (
                <li key={`r${n}`}>{m(r.tetkik)}
                  <span className="moz-sp not">{r.cekimTarihi ? c('rapor bekliyor') : c('sırada')}</span></li>
              ))}
            </ul>
          </div>

          <div className="kagrup">
            <h6 className="moz-bas">{c('Son muayeneler')}</h6>
            <ul className="moz-liste">
              {(sekme?.gecmis ?? []).length === 0 && <li className="not">{c('Önceki muayene yok.')}</li>}
              {((sekme?.gecmis ?? []) as Satir[]).slice(0, 4).map((g, n) => (
                <li key={n} title={m(g.ozet)}>
                  <span className="not">{tarihSaat(g.tarih).slice(0, 10)}</span>
                  <span className="moz-kisa">{m(g.anaTani) || m(g.ozet) || '—'}</span>
                  <span className="moz-sp not">{m(g.hekim)}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
