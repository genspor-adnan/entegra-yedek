import { useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import type { BaslangicKutucugu, GostergePaneliOzet } from '../api/uclar/gosterge';
import { gostergeDegeri } from '../bilesenler/GostergeIcerik';
import { c } from '../dil/ceviri';
import { useOturum } from '../kimlik/OturumBaglami';
import { useSubeLogo } from '../bilesenler/subeLogo';
import { MenuIkon, GRUP_IKON, GRUP_IKON_CEV, menuSatirlariKur } from './kabuk/menuAgaci';
import { SURUM_ETIKET } from '../surum';
import { useTaleplerim } from '../bilesenler/taleplerim/taleplerimBaglami';
import { duyuruOkuAc } from '../bilesenler/duyuru/DuyuruOrtak';
import { GelenEylemler, bekleme, gelenGruplari, iskontoKararAc, onayIkon, type GelenGrup } from '../bilesenler/taleplerim/GelenIsler';
import { Modal } from '../bilesenler/Modal';
import { mesaj } from '../bilesenler/mesaj';
import { PALET_SESLI_OLAYI, sesliGirisVar } from '../bilesenler/sesliGiris';
import { menuDuzeniUygula, MENU_DUZEN_OLAYI, type MenuDuzenSatiri } from './kabuk/menuDuzeni';
import { LISTELER } from './Liste';
import { kartAdi, kartSekmeYolu, kartSekmesiVar } from './listeTanimlari.Ortak';
import { SekmeGorunurBaglami } from '../bilesenler/sekmeBaglami';
import { MikrofonIkon } from '../bilesenler/MikrofonIkon';

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
  // ALT SATIR 3. SIRA (kullanıcı 24.10.2026): 3. SATIR: Profil / Şube Adı.
  const aktifSube = kullanici?.subeler.find(s => s.id === kullanici?.subeId);
  const oturumYeri = [kullanici?.kurumTipiAdi, aktifSube?.ad].filter(Boolean).join(' / ');
  // KÖŞE LOGOLARI (kullanıcı 24.10.2026): sol üst bizim (Gentegre), sağ üst şube logosu.
  const subeLogo = useSubeLogo(aktifSube?.logoDokumanId);
  const logolar = (
    <>
      <img className="bsl-logo bsl-logo-sol" src={`${import.meta.env.BASE_URL}gentegre-sembol.svg`} alt="Gentegre" />
      {/* MAVİ LOGO (kullanıcı 24.10.2026: "arka zemin şeffaf olsun logo mavi olsun"): logo maske
          olur, rengi tema vurgusu - beyaz / şeffaf logo açık sayfada da görünür. */}
      {subeLogo && <span className="bsl-logo bsl-logo-sag" role="img" aria-label={aktifSube?.ad ?? ''}
                         style={{ '--logo': `url("${subeLogo}")` } as React.CSSProperties} />}
    </>
  );
  const [paneller, setPaneller] = useState<GostergePaneliOzet[] | null>(null);
  const [rolKutucuklari, setRolKutucuklari] = useState<BaslangicKutucugu[] | null>(null);
  const [bekleyen, setBekleyen] = useState<Awaited<ReturnType<typeof api.baslangicBekleyen>> | null>(null);
  /** ALT MENÜ (kullanıcı 17.10.2026: "kutulardaki menülerde alt menü varsa ok ile açılabilsin, default
      kapalı"): açık alt başlıklar - anahtar "kutu/altbaşlık". */
  const [acikAlt, setAcikAlt] = useState<Set<string>>(new Set());
  /** Ayrıntısı açık bildirim grubu (kart tıklanınca). */
  const [bildirimDetay, setBildirimDetay] = useState<GelenGrup['kod'] | null>(null);

  useEffect(() => {
    void api.gostergeler().then(setPaneller).catch(() => setPaneller([]));
    void api.baslangic().then(setRolKutucuklari).catch(() => setRolKutucuklari([]));
    void api.baslangicBekleyen().then(setBekleyen).catch(() => setBekleyen(null));
  }, [kullanici?.id, kullanici?.subeId]);

  /**
   * MENÜ DÜZENİ BURADA DA (kullanıcı 17.10.2026: "genprofil'de 13 aktif 6 pasif grup var, admin olarak
   * girdiğimde tüm gruplar aktif geldi"): kutular düzensiz ağaçtan kuruluyordu - kurumun gizlediği
   * grup / ekran ana sayfada görünüyordu. Sol menüyle (Kabuk) aynı okuma ve aynı uygulama.
   */
  const [menuDuzen, setMenuDuzen] = useState<MenuDuzenSatiri[]>([]);
  useEffect(() => {
    if (!kullanici?.id) return;
    let iptal = false;
    const oku = () => api.menuDuzen().then(y => { if (!iptal) setMenuDuzen(y.satirlar) }).catch(() => {});
    oku();
    window.addEventListener(MENU_DUZEN_OLAYI, oku);
    return () => { iptal = true; window.removeEventListener(MENU_DUZEN_OLAYI, oku) };
  }, [kullanici?.id, kullanici?.subeId]);
  const menu = useMemo(() => menuDuzeniUygula(
                         menuSatirlariKur(LISTELER, yetki, kullanici?.urunModu, kullanici?.moduller), menuDuzen),
                       [yetki, kullanici?.urunModu, kullanici?.moduller, menuDuzen]);
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
                     satirlar: s.alt.map(m => ({ yol: m.yol, ad: m.ad, altGrup: m.altGrup })) });
    }
    if (duzler.length) kutular.push({ ad: c('Diğer'), ikon: '📁', satirlar: duzler });
    // GRUP SINIRI YOK (kullanıcı 17.10.2026: "admin ile girdim, gelmeyen menüler var - doküman, kalite,
    //   yönetim"): 12 kutu sınırı geniş yetkili rolde sondaki grupları kesiyordu.
    return kutular;
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

  /** Son açılanlar (en yeni önce) - sade görünümde tek sıra, kutulu görünümde kendi kutusu. */
  const sonAcilanlar = yerelListe('sonMenuler').map(ekranBul).filter(Boolean) as typeof ekranlar;
  /**
   * BEKLEYEN İŞLER (kullanıcı 16.10.2026): konsültasyon / sonucu gelen istem / bugünkü randevu; kart
   * ilgili ekrana gider (o ekrana yetki yoksa tıklanmaz). Sade ve kutulu görünüm aynı listeyi çizer.
   */
  const ekranVar = (yol: string) => ekranlar.some(e => e.yol.split('?')[0] === yol);
  /**
   * DUYURU (kullanıcı 17.10.2026: "bekleyen işlerde duyuru varsa o da görünsün"): zil panelinin zaten
   * okuduğu liste (Taleplerim bağlamı) - ikinci istek yok. Kart okunmamış en yeni duyuruyu açar; hepsi
   * okunduysa en yenisini. Okunmamış kritik duyuru varsa alt satır kırmızı.
   */
  const talep = useTaleplerim();
  const duyurular = talep?.duyurular ?? [];
  // SAYI OKUNMAMIŞ DUYURU (kullanıcı 17.10.2026: "okudum'a basınca duyuru sayısını 0 yapsın"): okudum
  //   denmemiş ya da okunduktan sonra güncellenmiş olanlar.
  const okunmamis = duyurular.filter(x => !x.okudu || x.eskiSurumOkundu);
  // DUYURU VE ONAY HEP GÖRÜNÜR, ötekiler sayı 0'dan büyükse (kullanıcı 17.10.2026: "bekleyen işlerde
  //   duyuru ve onay sabit kalsın, diğerleri sayı 0'dan büyük olursa gelsin").
  type Is = { yol: string; ic: string; ad: string; y: string; acil?: boolean; tikla?: () => void; sabit?: boolean; sayi?: number };
  const duyuruIsi: Is[] = [{
    yol: '#duyuru', ic: '📣', ad: `${okunmamis.length} ${c('duyuru')}`,
    y: (talep?.kritikBekleyen.length ?? 0) > 0 ? `${talep!.kritikBekleyen.length} ${c('kritik, okunmadı')}`
      : okunmamis.length > 0 ? c('okunmadı') : duyurular.length > 0 ? c('hepsi okundu') : c('duyuru yok'),
    acil: (talep?.kritikBekleyen.length ?? 0) > 0,
    // Duyuru yoksa açılacak bir şey yok - kart soluk durur.
    tikla: duyurular.length > 0 ? () => duyuruOkuAc((okunmamis[0] ?? duyurular[0]).id) : undefined,
    sabit: true,
  }];
  const bekleyenIsler: Is[] = (bekleyen ? [
    ...duyuruIsi,
    // ONAY HEP GÖRÜNÜR (17.10.2026) - kart Onayımdakiler'e gider.
    { yol: '/onay-kutusu', ic: '✍️', ad: `${bekleyen.onay} ${c('onay bekliyor')}`,
      y: bekleyen.onayGeciken > 0 ? `${bekleyen.onayGeciken} ${c('tanesi gecikti')}` : c('Onayımdakiler'),
      acil: bekleyen.onayGeciken > 0, sabit: true },
    { yol: '/konsultasyon', ic: '🤝', ad: `${bekleyen.konsultasyon} ${c('konsültasyon')}`, sayi: bekleyen.konsultasyon,
      y: bekleyen.konsultasyonGecikmis > 0 ? `${bekleyen.konsultasyonGecikmis} ${c('tanesinin süresi geçti')}` : c('yanıt bekliyor'),
      acil: bekleyen.konsultasyonGecikmis > 0 },
    { yol: '/hekim-listesi', ic: '🧪', ad: `${bekleyen.istemSonuc} ${c('istem sonucu')}`, y: c('son 7 günde geldi'),
      sayi: bekleyen.istemSonuc },
    { yol: '/randevu', ic: '📅', ad: `${bekleyen.randevu} ${c('randevu')}`,
      y: `${c('bugün')} · ${bekleyen.randevuBekleyen} ${c('bekliyor')}`, sayi: bekleyen.randevu },
    // ÖZLÜK BELGELERİM (kullanıcı 22.10.2026): eksik / süresi dolan belgesi varsa kart; basınca liste.
    { yol: '#belgelerim', ic: '📎', ad: `${bekleyen.belgeEksik || bekleyen.belgeYaklasan} ${c(bekleyen.belgeEksik ? 'eksik belgem' : 'belgemin süresi yaklaşıyor')}`,
      y: bekleyen.belgeEksik && bekleyen.belgeYaklasan ? `${bekleyen.belgeYaklasan} ${c('tanesinin süresi yaklaşıyor')}` : c('özlük dosyam'),
      acil: bekleyen.belgeEksik > 0, sayi: bekleyen.belgeEksik + bekleyen.belgeYaklasan,
      tikla: () => mesaj(`${c('Özlük dosyanızda tamamlanması gereken belgeler')}:\n\n`
        + bekleyen.belgeler.map(x => `• ${x.belge} - ${x.durum === 3 && x.kalanGun !== null ? `${x.kalanGun} ${c('gün kaldı')}` : x.durumAdi}`).join('\n')
        + `\n\n${c('Belgelerinizi İnsan Kaynakları birimine iletin.')}`) },
    // İK: kurum geneli eksiği olan personel (yalnız belge takip yetkilisine gelir).
    { yol: '/personel-belge-ozet', ic: '🗂', ad: `${bekleyen.ikBelgeEksikKisi ?? 0} ${c('personelde eksik belge')}`,
      y: (bekleyen.ikBelgeDolduKisi ?? 0) > 0 ? `${bekleyen.ikBelgeDolduKisi} ${c('kişide süresi doldu')}` : c('Belge Takibi'),
      acil: (bekleyen.ikBelgeDolduKisi ?? 0) > 0, sayi: bekleyen.ikBelgeEksikKisi ?? 0 },
  ] as Is[] : duyuruIsi).filter(i => i.sabit || (i.sayi ?? 0) > 0);

  /**
   * BİLDİRİMLER (kullanıcı 18.10.2026: "home'da bildirimler de bekleyen işler altında görünsün" -> "kutu
   * olarak görünsün, basılınca detay gelsin"): zilin (Bana gelenler) içeriği TÜR TÜR KART - acil /
   * atanmamış / bendeki arıza, iskonto onayı, onayımı bekleyen; kart sayıyı ve en eskinin bekleme süresini
   * gösterir. Karta basınca o türün kayıtları pencerede: satır kaydı açar, zildeki hızlı işlem düğmeleri
   * de orada. Aynı bağlamdan (ikinci istek yok); boş tür kartı yok.
   */
  const bildirimGruplari = talep ? gelenGruplari(talep.gelen, talep.veri?.onaylar ?? [], talep.iskontolar) : [];
  const BILDIRIM_KART: Record<GelenGrup['kod'], { ic: string; ad: string }> = {
    acil: { ic: '🚨', ad: 'acil arıza' }, atanmamis: { ic: '🧰', ad: 'atanmamış arıza' },
    bende: { ic: '🔧', ad: 'bendeki arıza' }, iskonto: { ic: '％', ad: 'iskonto onayı' },
    onay: { ic: '⏳', ad: 'onayımı bekleyen' },
  };
  const ogeZamani = (o: GelenGrup['ogeler'][number]) =>
    o.tip === 'iskonto' ? o.t.istekTs : o.tip === 'ariza' ? o.a.eklemeTarihi : o.o.baslama;
  // AYRI BÖLÜM YOK (kullanıcı 18.10.2026: "bekleyen işler altında olsun, yeni bölüm ekleme"): kartlar
  //   Bekleyen işler şeridinin içinde, işlerin ardından.
  const bildirimKartlari = bildirimGruplari.map(g => {
          const k = BILDIRIM_KART[g.kod];
          const enEski = g.ogeler.map(ogeZamani).filter(Boolean).sort()[0];
          return (
            <a key={g.kod} className="bsl-kart" onClick={() => setBildirimDetay(g.kod)}>
              <span className="bsl-kart-i">{k.ic}</span>
              <span className="bsl-kart-a">{g.ogeler.length} {c(k.ad)}</span>
              <span className={`bsl-kart-y${g.kod === 'acil' ? ' bsl-kart-acil' : ''}`}>
                {enEski ? `${c('en eskisi')} ${bekleme(enEski)}` : c('ayrıntı')}</span>
            </a>
          );
        });
  const detayGrup = bildirimGruplari.find(g => g.kod === bildirimDetay);
  const bildirimPenceresi = detayGrup && (
    <Modal baslik={`${BILDIRIM_KART[detayGrup.kod].ic} ${c(detayGrup.ad)} · ${detayGrup.ogeler.length}`} dar buyutmeYok
           onKapat={() => setBildirimDetay(null)}
           alt={<><span className="ck-bosluk" />
             <button type="button" className="d" onClick={() => { setBildirimDetay(null); git('/taleplerim?sekme=gelen') }}>{c('Tümünü aç')} →</button>
             <button type="button" className="d" onClick={() => setBildirimDetay(null)}>✖ {c('Kapat')}</button></>}>
      <ul className="tl-son tl-gelen bsl-bil-liste">
        {detayGrup.ogeler.map(o => {
          const kapatAc = () => { setBildirimDetay(null); if (o.tip === 'iskonto') iskontoKararAc(o.t); else git(`/taleplerim?sekme=gelen&sec=${o.anahtar}`) };
          return o.tip === 'iskonto' ? (
            <li key={o.anahtar} onClick={kapatAc}>
              <span>％</span>
              <span><b>%{o.t.oran}</b> · {o.t.hasta || o.t.belgeNo}
                <small>{c('isteyen')}: {o.t.isteyen} · {bekleme(o.t.istekTs)}{o.t.gerekce ? ` · “${o.t.gerekce}”` : ''}</small></span>
              <GelenEylemler oge={o} sonra={() => setBildirimDetay(null)} />
            </li>
          ) : o.tip === 'ariza' ? (
            <li key={o.anahtar} className={detayGrup.kod === 'acil' ? 'tl-li-acil' : ''} onClick={kapatAc}>
              <span>🧰</span>
              <span><b>{o.a.talepNo} · {o.a.aciklama}</b>{o.a.konum ? ` · ${o.a.konum}` : ''}
                <small>{o.a.talepEdenAdi}{o.a.telefon ? ` · ☎ ${o.a.telefon}` : ''} · {bekleme(o.a.eklemeTarihi)} {c('önce')}{o.a.benim ? ` · ${o.a.durumAdi}` : ''}</small></span>
              <GelenEylemler oge={o} ata={false} />
            </li>
          ) : (
            <li key={o.anahtar} onClick={kapatAc}>
              <span>{onayIkon(o.o)}</span>
              <span><b>{o.o.konu}</b> · {o.o.talepEden}
                <small>{o.o.adimAd} · {bekleme(o.o.baslama)}{o.o.gecikmeGun > 0 ? ` · ${c('termin geçti')}` : ''}</small></span>
              <GelenEylemler oge={o} />
            </li>
          );
        })}
      </ul>
    </Modal>
  );

  /**
   * ÜST ŞERİT: son açılanlar (tek sıra, 4 ekran) + bekleyen işler. KUTULU GÖRÜNÜMDE DE AYNI (kullanıcı
   * 17.10.2026: "kutulu olan ekranlarda da Son açılanlar ve Bekleyen işler üstte, 10 adetten az olan gibi
   * görünsün") - iki görünüm tek çizimi kullanır. KUTULU GÖRÜNÜMDE 8 (kullanıcı 17.10.2026: "son açılan
   * ve bekleyen işler 8 tane gelsin"): geniş sayfada satırda 8 kart, son açılanlardan 8 ekran; dar sade
   * görünümde 4.
   */
  const ustSerit = (adet: 4 | 8) => (
    <>
      {sonAcilanlar.length > 0 && <><div className="bsl-bolum">{c('Son açılanlar')}</div>
        <div className={`bsl-kartlar bsl-kartlar-orta bsl-tek-sira${adet === 8 ? ' bsl-sekizli' : ''}`}>{sonAcilanlar.slice(0, adet).map(ekranKart)}</div></>}
      {(bekleyenIsler.length > 0 || bildirimKartlari.length > 0) && <><div className="bsl-bolum">{c('Bekleyen işler')}</div>
        <div className={`bsl-kartlar bsl-kartlar-orta${adet === 8 ? ' bsl-sekizli' : ' bsl-dortlu'}`}>{bekleyenIsler.map(i => (
          <a key={i.yol} className={`bsl-kart${i.tikla || ekranVar(i.yol) ? '' : ' bsl-kart-pasif'}`}
             onClick={() => { if (i.tikla) i.tikla(); else if (ekranVar(i.yol)) git(i.yol) }}>
            <span className="bsl-kart-i">{i.ic}</span>
            <span className="bsl-kart-a">{i.ad}</span>
            <span className={`bsl-kart-y${i.acil ? ' bsl-kart-acil' : ''}`}>{i.y}</span>
          </a>))}
          {bildirimKartlari}
        </div></>}
      {bildirimPenceresi}
    </>
  );

  // SADE BAŞLANGIÇ (kullanıcı 16.10.2026, mockup Ekranlar/Ayarlar/ana_ekran_sekmeli.html): az ekranlı
  //   kullanıcıda ortalanmış tek sütun - selam, büyük arama, son açılanlar / ekranlarım küçük kartlar
  //   (ikon · ad · grup). "Sık kullandıklarım" yok (kullanıcı 16.10.2026: "gerek yok").
  if (sade) {
    return (
      <div className="sahne bsl-sade">
        {logolar}
        <div className="bsl-sade-ic">
          <h1>{selam()}, {kullanici?.ad ?? ''}</h1>
          <div className="bsl-sade-alt">
            {new Date().toLocaleDateString('tr-TR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
            {kullanici?.rolAdi ? ` · ${kullanici.rolAdi}` : ''}
            {' · '}{c('Açmak istediğiniz ekranı yazın; açtıklarınız üstte sekme olarak kalır.')}
            {' · '}<span className="bsl-surum" title={c('Uygulama sürümü')}>{c('Sürüm')} {SURUM_ETIKET}</span>
          </div>
          {oturumYeri && <div className="bsl-sade-alt bsl-oturum">{oturumYeri}</div>}
          <button type="button" className="bsl-ara" onClick={() => window.dispatchEvent(new Event(PALET_AC_OLAYI))}>
            🔍 <span>{c('Ne açmak istiyorsunuz?')}</span><kbd>Ctrl K</kbd>
            {sesliGirisVar() && <span className="bsl-ara-mik" role="button" title={c('Sesle ara')}
                onClick={e => { e.stopPropagation(); window.dispatchEvent(new Event(PALET_SESLI_OLAYI)) }}><MikrofonIkon /></span>}
          </button>
          {ustSerit(4)}
          <div className="bsl-bolum">{c('Ekranlarım')}</div>
          <div className="bsl-kartlar bsl-kartlar-orta">
            {ekranlar.map(ekranKart)}
            {(paneller ?? []).map(p => ekranKart({ yol: `/gosterge/${p.kod}`, ad: p.ad, ic: p.ikon || '📊', grup: c('Gösterge Panelleri') }))}
          </div>
        </div>
      </div>
    );
  }

  // KUTULU GÖRÜNÜM ORTALI (kullanıcı 17.10.2026: "sola yanaşık değil ortalı yap hepsini"): selam,
  //   arama, üst şeritler ve kutular tek ortalı sütunda - sade görünümle aynı düzen, daha geniş.
  return (
    <>
      {/* Kaydırılan alan (sahne) TAM GENİŞLİK - çubuk en sağda; ortalama içteki sütunda (kullanıcı
          17.10.2026: "scroll en sağda olsun", "ortada duruyor"). */}
      <div className="sahne bsl">
       {logolar}
       <div className="bsl-orta">
        <h1 className="bsl-selam">{selam()}, {kullanici?.ad ?? ''}</h1>
        <div className="bsl-sade-alt">
          {new Date().toLocaleDateString('tr-TR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
          {kullanici?.rolAdi ? ` · ${kullanici.rolAdi}` : ''}
          {' · '}<span className="bsl-surum" title={c('Uygulama sürümü')}>{c('Sürüm')} {SURUM_ETIKET}</span>
        </div>
        {oturumYeri && <div className="bsl-sade-alt bsl-oturum">{oturumYeri}</div>}
        <button type="button" className="bsl-ara" onClick={() => window.dispatchEvent(new Event(PALET_AC_OLAYI))}>
          🔍 <span>{c('Ne açmak istiyorsunuz? (ekran, hasta, gösterge paneli…)')}</span><kbd>Ctrl K</kbd>
          {sesliGirisVar() && <span className="bsl-ara-mik" role="button" title={c('Sesle ara')}
                onClick={e => { e.stopPropagation(); window.dispatchEvent(new Event(PALET_SESLI_OLAYI)) }}><MikrofonIkon /></span>}
        </button>

        {ustSerit(8)}
        <div className="bsl-bolum">{c('Ekranlarım')}
          {!elle && rolKutucuklari !== null && <span className="sonuk"> · {c('rolünüz için önerilen düzen')}</span>}
        </div>
        <div className="bsl-kutular">
          {(paneller?.length ?? 0) > 0 && (
            <div className="bsl-kutu bsl-gp">
              <div className="bsl-kb">📊 {c('Gösterge Panelleri')}<span className="rozet mavi">{paneller!.length}</span></div>
              {/* 6 PANEL GÖRÜNÜR, FAZLASI KAYDIRILIR (kullanıcı 17.10.2026) - diğer kutularla aynı. */}
              <div className="bsl-satirlar">
              {paneller!.map(p => (
                <a key={p.kod} onClick={() => git(`/gosterge/${p.kod}`)}>
                  <span>{p.ikon} {c(p.ad)}</span>
                  {p.ilk && <span className={`s ${p.ilk.vurgu === 'tehlike' ? 'k' : ''}`}>
                    {gostergeDegeri(p.ilk)} · {c(p.ilk.baslik).toLocaleLowerCase('tr')}</span>}
                </a>
              ))}
              </div>
            </div>
          )}
          {kutucuklar.map((k, i) => (
            <div key={i} className="bsl-kutu">
              <div className="bsl-kb"><MenuIkon ic={k.ikon || '📁'} /> {c(k.ad)}</div>
              {/* 6 SATIR GÖRÜNÜR, FAZLASI KAYDIRILIR (kullanıcı 17.10.2026). */}
              <div className="bsl-satirlar">
              {(() => {
                const satir = (s: typeof k.satirlar[number], j: string | number, alt = false) => (
                  <a key={j} onClick={() => git(s.yol)} className={alt ? 'bsl-alt' : undefined}>
                    <span className="bsl-ad">{ikonlar.get(s.yol) && <MenuIkon ic={ikonlar.get(s.yol)!} />}{c(s.ad)}</span>
                    {s.deger && <span className={`s ${s.deger.vurgu === 'tehlike' ? 'k' : ''}`}>{gostergeDegeri(s.deger)}</span>}
                  </a>
                );
                // Alt başlığı olan satırlar menüdeki gibi tek başlık altında toplanır (ilk göründüğü yerde).
                const sira: (string | typeof k.satirlar[number])[] = [];
                const altlar = new Map<string, typeof k.satirlar>();
                for (const s of k.satirlar) {
                  if (!s.altGrup) { sira.push(s); continue }
                  if (!altlar.has(s.altGrup)) { altlar.set(s.altGrup, []); sira.push(s.altGrup) }
                  altlar.get(s.altGrup)!.push(s);
                }
                return sira.map((x, j) => {
                  if (typeof x !== 'string') return satir(x, j);
                  const anahtar = `${k.ad}/${x}`, acik = acikAlt.has(anahtar);
                  return (
                    <div key={`a-${x}`}>
                      <a onClick={() => setAcikAlt(o => { const y = new Set(o); if (acik) y.delete(anahtar); else y.add(anahtar); return y })}>
                        <span className="bsl-ad"><span className="ic">{acik ? '▾' : '▸'}</span>{c(x)}</span>
                        <span className="s">{altlar.get(x)!.length}</span>
                      </a>
                      {acik && altlar.get(x)!.map((s, i) => satir(s, `${x}-${i}`, true))}
                    </div>
                  );
                });
              })()}
              </div>
            </div>
          ))}
        </div>
       </div>
      </div>
    </>
  );
}
