import { useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import type { BaslangicKutucugu, GostergePaneliOzet } from '../api/uclar/gosterge';
import { gostergeDegeri } from '../bilesenler/GostergeIcerik';
import { c } from '../dil/ceviri';
import { useOturum } from '../kimlik/OturumBaglami';
import { MenuIkon, GRUP_IKON, GRUP_IKON_CEV, menuSatirlariKur } from './kabuk/menuAgaci';
import { LISTELER } from './Liste';
import { kartAdi, kartSekmeYolu, kartSekmesiVar } from './listeTanimlari.Ortak';
import { SekmeGorunurBaglami } from '../bilesenler/sekmeBaglami';

/** Başlangıç'taki büyük arama kutusu Kabuk'un komut paletini açar. */
export const PALET_AC_OLAYI = 'gentegre-palet-ac';
/** Palet işlemini çalıştırır (detail = palet yolu, ör. "#kayitli:/muayene") - Kabuk dinler. */
export const PALET_GIT_OLAYI = 'gentegre-palet-git';
/** Palet "Kayıtlı ... Kartı" işleminin öneki (Kabuk ile aynı). */
const KAYITLI_ONEK = '#kayitli:';

function selam(): string {
  const s = new Date().getHours();
  if (s < 6) return c('İyi geceler');
  if (s < 12) return c('Günaydın');
  if (s < 18) return c('İyi çalışmalar');
  return c('İyi akşamlar');
}

/** Öneri (rolün elle düzeni yoksa): menüden en fazla bu kadar kutucuk. */
const ONERI_SINIRI = 12;
/** AZ EKRANLI KULLANICI (kullanıcı 16.10.2026: "10 adet altında menü varsa bölümlü değil büyük
    ikonlu göster"): bundan az ekranda gruplu kutular yerine büyük ikonlu karolar. */
const BUYUK_IKON_SINIRI = 10;

/**
 * BAŞLANGIÇ SEKMESİ (ana ekran v3 + mockup Ekranlar/Dashboard/gosterge_panelleri.html).
 *
 *  - İLK KUTUCUK = rolün yetkili olduğu gösterge panelleri (ayrı bölüm yok); satırda
 *    panelin ilk göstergesi.
 *  - Sonra ROLÜN kutucukları: kurum rol başına ELLE düzenler (rol_baslangic). Düzen
 *    yoksa rolün yetkili menüsünden öneri çizilir (grup başına bir kutucuk).
 *  - Satırdaki sayı gösterge kataloğundan (kutucuk düzeninde seçilen gösterge).
 * Önceki Ana Sayfa paneli "Genel" gösterge paneli olarak açılır (/gosterge/genel).
 */
export function Baslangic() {
  const git = useNavigate();
  const { kullanici, yetki } = useOturum();
  const [paneller, setPaneller] = useState<GostergePaneliOzet[] | null>(null);
  const [rolKutucuklari, setRolKutucuklari] = useState<BaslangicKutucugu[] | null>(null);
  const [bekleyen, setBekleyen] = useState<Awaited<ReturnType<typeof api.baslangicBekleyen>> | null>(null);

  useEffect(() => {
    void api.gostergeler().then(setPaneller).catch(() => setPaneller([]));
    void api.baslangic().then(setRolKutucuklari).catch(() => setRolKutucuklari([]));
    void api.baslangicBekleyen().then(setBekleyen).catch(() => setBekleyen(null));
  }, [kullanici?.id, kullanici?.subeId]);

  const menu = useMemo(() => menuSatirlariKur(LISTELER, yetki, kullanici?.urunModu, kullanici?.moduller),
                       [yetki, kullanici?.urunModu, kullanici?.moduller]);
  /** MENÜ İKONLARI (kullanıcı 14.10.2026: "açılış ekrandaki menülere ikonlar gelsin"): satırın
      ikonu sol menüdeki ikonudur (yola göre) - rolün elle düzenlediği kutucuklarda da. */
  const ikonlar = useMemo(() => {
    const m = new Map<string, string>();
    for (const sat of menu) for (const o of sat.tur === 'duz' ? [sat.m] : sat.alt) m.set(o.yol, o.ic);
    return m;
  }, [menu]);

  // ÖNERİ: rolün yetkili menüsü (sol menüyle aynı süzgeç), grup başına bir kutucuk.
  const oneri = useMemo<BaslangicKutucugu[]>(() => {
    const satirlar = menu;
    const kutular: BaslangicKutucugu[] = [];
    const duzler: BaslangicKutucugu['satirlar'] = [];
    for (const s of satirlar) {
      if (s.tur === 'duz') { if (s.m.yol !== '/panel') duzler.push({ yol: s.m.yol, ad: s.m.ad }); continue }
      kutular.push({ ad: s.ad, ikon: s.ikon ?? GRUP_IKON[s.ad] ?? GRUP_IKON_CEV[s.ad] ?? '📁',
                     satirlar: s.alt.slice(0, 6).map(m => ({ yol: m.yol, ad: m.ad })) });
    }
    if (duzler.length) kutular.push({ ad: c('Diğer'), ikon: '📁', satirlar: duzler.slice(0, 6) });
    return kutular.slice(0, ONERI_SINIRI);
  }, [menu]);

  const elle = (rolKutucuklari?.length ?? 0) > 0;
  const kutucuklar = elle ? rolKutucuklari! : oneri;
  /** Menüdeki bütün ekranlar (grup sırasıyla, grup adıyla) - az ise sade başlangıç. */
  const ekranlar = useMemo(() => menu.flatMap(s => (s.tur === 'duz'
      ? [{ ...s.m, grup: '' }] : s.alt.map(m => ({ ...m, grup: s.ad }))))
    .filter(m => m.yol !== '/panel'), [menu]);
  const sade = ekranlar.length > 0 && ekranlar.length < BUYUK_IKON_SINIRI;
  /** Son açılanlar (kabuk menü tercihleri, kullanıcı başına tarayıcıda). */
  const yerelListe = (anahtar: string): string[] => {
    try { const l = JSON.parse(localStorage.getItem(`${anahtar}.${kullanici?.id ?? 0}`) ?? '[]'); return Array.isArray(l) ? l : [] }
    catch { return [] }
  };
  // Sekme her görününce yeniden çizilir: son açılanlar o anki tercihlerden okunur (sekme açık kalır).
  useContext(SekmeGorunurBaglami);
  const ekranBul = (yol: string) => {
    // "Kayıtlı ... Kartı" palet işlemi: kartı sekmede açılan liste (menüde olan) - tıklayınca aynı arama.
    if (yol.startsWith(KAYITLI_ONEK)) {
      const kartYol = yol.slice(KAYITLI_ONEK.length);
      const l = LISTELER.find(x => kartSekmesiVar(x) && kartSekmeYolu(x) === kartYol);
      const menude = ekranlar.find(e => e.yol.split('?')[0] === `/${l?.rota ?? l?.kaynak}`);
      return l && menude ? { yol, ad: `Kayıtlı ${kartAdi(l)}`, ic: '📂', grup: menude.grup } : undefined;
    }
    return ekranlar.find(e => e.yol === yol || e.yol.split('?')[0] === yol.split('?')[0]);
  };
  const ekranKart = (e: { yol: string; ad: string; ic: string; grup: string }) => (
    <a key={e.yol} className="bsl-kart" onClick={() => e.yol.startsWith(KAYITLI_ONEK)
         ? window.dispatchEvent(new CustomEvent(PALET_GIT_OLAYI, { detail: e.yol })) : git(e.yol)}>
      <span className="bsl-kart-i"><MenuIkon ic={e.ic || '📁'} /></span>
      <span className="bsl-kart-a">{c(e.ad)}</span>
      {e.grup && <span className="bsl-kart-y">{c(e.grup)}</span>}
    </a>
  );

  // SADE BAŞLANGIÇ (kullanıcı 16.10.2026, mockup Ekranlar/Ayarlar/ana_ekran_sekmeli.html): az ekranlı
  //   kullanıcıda ortalanmış tek sütun - selam, büyük arama, son açılanlar / ekranlarım küçük kartlar
  //   (ikon · ad · grup). "Sık kullandıklarım" yok (kullanıcı 16.10.2026: "gerek yok").
  if (sade) {
    // Son açılanlar tek sıra: 4 ekran (kullanıcı 16.10.2026).
    const son = yerelListe('sonMenuler').map(ekranBul).filter(Boolean).slice(0, 4) as typeof ekranlar;
    return (
      <div className="sahne bsl-sade">
        <div className="bsl-sade-ic">
          <h1>{selam()}, {kullanici?.ad ?? ''}</h1>
          <div className="bsl-sade-alt">
            {new Date().toLocaleDateString('tr-TR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
            {kullanici?.rolAdi ? ` · ${kullanici.rolAdi}` : ''}
            {' · '}{c('Açmak istediğiniz ekranı yazın; açtıklarınız üstte sekme olarak kalır.')}
          </div>
          <button type="button" className="bsl-ara" onClick={() => window.dispatchEvent(new Event(PALET_AC_OLAYI))}>
            🔍 <span>{c('Ne açmak istiyorsunuz?')}</span><kbd>Ctrl K</kbd>
          </button>
          {son.length > 0 && <><div className="bsl-bolum">{c('Son açılanlar')}</div>
            <div className="bsl-kartlar bsl-tek-sira">{son.map(ekranKart)}</div></>}
          {/* BEKLEYEN İŞLER (kullanıcı 16.10.2026): konsültasyon / sonucu gelen istem / bugünkü randevu;
              kart ilgili ekrana gider (o ekrana yetki yoksa tıklanmaz). */}
          {bekleyen && (() => {
            const ekranVar = (yol: string) => ekranlar.some(e => e.yol.split('?')[0] === yol);
            const isler = [
              { yol: '/konsultasyon', ic: '🤝', ad: `${bekleyen.konsultasyon} ${c('konsültasyon')}`,
                y: bekleyen.konsultasyonGecikmis > 0 ? `${bekleyen.konsultasyonGecikmis} ${c('tanesinin süresi geçti')}` : c('yanıt bekliyor') },
              { yol: '/hekim-listesi', ic: '🧪', ad: `${bekleyen.istemSonuc} ${c('istem sonucu')}`, y: c('son 7 günde geldi') },
              { yol: '/randevu', ic: '📅', ad: `${bekleyen.randevu} ${c('randevu')}`,
                y: `${c('bugün')} · ${bekleyen.randevuBekleyen} ${c('bekliyor')}` },
            ];
            return <><div className="bsl-bolum">{c('Bekleyen işler')}</div>
              <div className="bsl-kartlar">{isler.map(i => (
                <a key={i.yol} className={`bsl-kart${ekranVar(i.yol) ? '' : ' bsl-kart-pasif'}`}
                   onClick={() => { if (ekranVar(i.yol)) git(i.yol) }}>
                  <span className="bsl-kart-i">{i.ic}</span>
                  <span className="bsl-kart-a">{i.ad}</span>
                  <span className="bsl-kart-y">{i.y}</span>
                </a>))}
              </div></>;
          })()}
          <div className="bsl-bolum">{c('Ekranlarım')}</div>
          <div className="bsl-kartlar">
            {ekranlar.map(ekranKart)}
            {(paneller ?? []).map(p => ekranKart({ yol: `/gosterge/${p.kod}`, ad: p.ad, ic: p.ikon || '📊', grup: c('Gösterge Panelleri') }))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{selam()}, {kullanici?.ad ?? ''}</h1>
          <span className="yol">
            {new Date().toLocaleDateString('tr-TR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
            {kullanici?.rolAdi ? ` · ${kullanici.rolAdi}` : ''}
          </span>
        </div>
      </div>
      <div className="sahne bsl">
        <button type="button" className="bsl-ara" onClick={() => window.dispatchEvent(new Event(PALET_AC_OLAYI))}>
          🔍 <span>{c('Ne açmak istiyorsunuz? (ekran, hasta, gösterge paneli…)')}</span><kbd>Ctrl K</kbd>
        </button>

        <div className="bsl-bolum">{c('Ekranlarım')}
          {!elle && rolKutucuklari !== null && <span className="sonuk"> · {c('rolünüz için önerilen düzen')}</span>}
        </div>
        <div className="bsl-kutular">
          {(paneller?.length ?? 0) > 0 && (
            <div className="bsl-kutu bsl-gp">
              <div className="bsl-kb">📊 {c('Gösterge Panelleri')}<span className="rozet mavi">{paneller!.length}</span></div>
              {paneller!.map(p => (
                <a key={p.kod} onClick={() => git(`/gosterge/${p.kod}`)}>
                  <span>{p.ikon} {c(p.ad)}</span>
                  {p.ilk && <span className={`s ${p.ilk.vurgu === 'tehlike' ? 'k' : ''}`}>
                    {gostergeDegeri(p.ilk)} · {c(p.ilk.baslik).toLocaleLowerCase('tr')}</span>}
                </a>
              ))}
            </div>
          )}
          {kutucuklar.map((k, i) => (
            <div key={i} className="bsl-kutu">
              <div className="bsl-kb"><MenuIkon ic={k.ikon || '📁'} /> {c(k.ad)}</div>
              {k.satirlar.map((s, j) => (
                <a key={j} onClick={() => git(s.yol)}>
                  <span className="bsl-ad">{ikonlar.get(s.yol) && <MenuIkon ic={ikonlar.get(s.yol)!} />}{c(s.ad)}</span>
                  {s.deger && <span className={`s ${s.deger.vurgu === 'tehlike' ? 'k' : ''}`}>{gostergeDegeri(s.deger)}</span>}
                </a>
              ))}
            </div>
          ))}
        </div>
      </div>
    </>
  );
}
