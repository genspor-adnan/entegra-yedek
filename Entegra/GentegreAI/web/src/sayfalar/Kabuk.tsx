import { useEffect, useState } from 'react';
import { useMenuTercihleri, useKullaniciAyari } from './kabuk/useMenuTercihleri';
import { DILLER } from '../bilesenler/diller';
import { KullaniciAyarlari } from '../bilesenler/KullaniciAyarlari';
import { useProfilResmi } from '../bilesenler/profilResmi';
import { useSubeLogo } from '../bilesenler/subeLogo';
import { menuSatirlariKur } from './kabuk/menuAgaci';
import { YanMenu } from './kabuk/YanMenu';
import { TEMA_ADI, TEMA_IKON, temaOku, temaSonraki, temaUygula, type Tema }
  from '../bilesenler/tema';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { ZilPaneli } from '../bilesenler/ZilPaneli';
import { Bayrak } from '../bilesenler/Bayrak';
import { c, ceviriYukle, ceviriDinle } from '../dil/ceviri';
import { useOturum } from '../kimlik/OturumBaglami';
import { urunAdi } from '../api/sozlesme';
import { AiRehberPaneli } from '../bilesenler/AiRehberPaneli';
import { LISTELER } from './Liste';

export function Kabuk() {
  const { kullanici, cikisYap, subeDegistir, dilDegistir, yetki } = useOturum();
  const konum = useLocation();
  const git = useNavigate();

  // MENU AGACI (kabuk/menuAgaci): yetki + urun modu + kurum modulu suzgeci,
  //   grup/alt-grup, urune gore grup sirasi - hepsi saf fonksiyonda.
  const satirlar = menuSatirlariKur(LISTELER, yetki, kullanici?.urunModu, kullanici?.moduller);

  /**
   * FAVORILER (kullanici): alt menu ogelerinin sagindaki yildiz ☆ tiklaninca
   * oge menunun EN USTUNDEKI "Favoriler" bolumune de girer; asil yerinde ★
   * dolu gorunur, tekrar tiklaninca cikar.
   *
   * SUNUCUDA saklanir (397, public.kullanici_tercih): localStorage'ta iken
   * site verisi silinince, baska makineden ya da baska adresten (dev
   * localhost:5173 ile sunucudaki /ai AYRI origin) girilince liste bos
   * geliyordu - kullanicinin gozunde "Favoriler menusu kayboldu".
   * localStorage artik yalniz CEVRIMDISI KOPYA: sunucuya ulasilamazsa menu
   * yine dolu acilir, ilk yazmada sunucu tekrar dogruyu ogrenir.
   */
  // MENU TERCIHLERI (favoriler sunucuda + en son kullanilanlar yerelde)
  //   kendi kancasinda: kabuk/useMenuTercihleri.
  const tercih = useMenuTercihleri(kullanici?.id,
      { aktif: kullanici?.subeId, liste: kullanici?.subeler ?? [], degistir: subeDegistir });

  /**
   * KAYIT NOKTASI ROTA DEGISIMI (menu tiklamasi DEGIL): ayni ekrana favoriden,
   * dogrudan URL'den, geri tusundan ya da bir kart icindeki baglantidan da
   * gelinebiliyor. Menuye onClick baglamak bunlarin cogunu kacirirdi.
   * En UZUN eslesen yol alinir - "/kasa-islem" ile "/kasa" ayni anda eslesirse
   * dogru olan derindeki.
   */
  useEffect(() => {
    const hepsi = satirlar.flatMap(sat => (sat.tur === 'duz' ? [sat.m] : sat.alt));
    const eslesen = hepsi
      .filter(m => konum.pathname === m.yol || konum.pathname.startsWith(m.yol + '/'))
      .sort((a, b) => b.yol.length - a.yol.length)[0];
    if (eslesen) tercih.sonKaydet(eslesen.yol);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [konum.pathname, satirlar]);

  // KULLANICI AYARLARI PENCERESI (sifre + dil) kendi kancasinda.
  const ayar = useKullaniciAyari({
    mevcutDil: kullanici?.dil ?? 0, dilDegistir, cikisYap,
  });
  /** Bayrak dugmesinin acilir listesi. */
  const [dilMenusu, setDilMenusu] = useState(false);
  const [tema, setTema] = useState<Tema>(() => temaOku());
  // DIL (194): sozluk sunucudan iner; degisince menu yeniden cizilsin diye
  //   sayac artirilir (sozluk modul kapsaminda, React state'i degil).
  const [ceviriSurumu, setCeviriSurumu] = useState(0);
  useEffect(() => ceviriDinle(() => setCeviriSurumu(s => s + 1)), []);
  // Sozluk MODUL kapsaminda (React state degil): indiginde React kendiliginden
  //   yeniden cizmez. Menu bu bilesenin icinde oldugu icin state degisimiyle
  //   tazelenir; ANA ALAN (liste/kart) ayri agac - ona `key` verilerek yeniden
  //   kurulur. Dil degisimi nadir ve bilincli bir eylem; sayfa yenilemekle
  //   ayni etkiyi verir ama oturum ve konum korunur.
  useEffect(() => { void ceviriYukle(kullanici?.dil ?? 0) }, [kullanici?.dil]);
  /** Sol menu acik/kapali - tercih tarayicida kalir (dar ekranda kapali calisilir). */
  const [menuKapali, setMenuKapali] = useState<boolean>(() => {
    try { return localStorage.getItem('gentegre.menu') === 'kapali' } catch { return false }
  });
  const menuCevir = () => setMenuKapali(k => {
    try { localStorage.setItem('gentegre.menu', k ? 'acik' : 'kapali') } catch { /* gizli sekme */ }
    return !k;
  });
  const aktifSube = kullanici?.subeler.find(s => s.id === kullanici?.subeId);
  // ŞUBE MARKASI (kullanıcı: "başlıktaki merkez combosunu kaldır, onun yerine
  //   şube logo ve adını soldaki GenoTIP AI gibi yaz"): combo yerine logo + ad;
  //   çok şubeli kullanıcıda tıklayınca şube listesi açılır (değiştirme kalır).
  const subeLogo = useSubeLogo(aktifSube?.logoDokumanId);
  const [subeMenusu, setSubeMenusu] = useState(false);
  const cokSube = (kullanici?.subeler.length ?? 0) > 1;
  useEffect(() => {
    if (!subeMenusu) return;
    const kapat = () => setSubeMenusu(false);
    document.addEventListener('mousedown', kapat);
    return () => document.removeEventListener('mousedown', kapat);
  }, [subeMenusu]);
  // Sekme başlığı ürün adı + şube: HBYS kurulumunda "Gentegre AI" kalıyordu.
  useEffect(() => {
    document.title = `${urunAdi(kullanici?.urunModu)}${aktifSube ? ` · ${aktifSube.ad}` : ''}`;
  }, [kullanici?.urunModu, aktifSube]);
  const basHarfler = (kullanici?.ad ?? '?')
    .split(' ').filter(Boolean).slice(0, 2).map(p => p[0]?.toLocaleUpperCase('tr')).join('');
  // PROFIL FOTOGRAFI: personel kartinin varsayilan resmi (profilResmi.ts) -
  //   yoksa bas harfler. Ayarlar penceresinden yuklenince burada da tazelenir.
  const profilResmi = useProfilResmi(kullanici?.id);

  /** Ust seritteki arama kutusu komut paletini acar (paletin kendi kisayolu Ctrl+K). */
  const paletiAc = () =>
    window.dispatchEvent(new KeyboardEvent('keydown', { key: 'k', ctrlKey: true, bubbles: true }));

  /** Bayraktan dil degistir - Kullanici Ayarlari'ndaki kutuyla ayni ucu cagirir. */
  async function dilSec(dil: number) {
    if (dil === (kullanici?.dil ?? 0)) return;
    try { await dilDegistir(dil) } catch { /* oturum katmani hatayi gosterir */ }
  }

  useEffect(() => {
    if (!dilMenusu) return;
    const kapat = () => setDilMenusu(false);
    document.addEventListener('mousedown', kapat);
    return () => document.removeEventListener('mousedown', kapat);
  }, [dilMenusu]);


  return (
    <div className={`kabuk${menuKapali ? ' menu-kapali' : ''}`}>
      <header className="ust">
        {/* Menu ac/kapa: markanin SOLUNDA - kapaninca ana alan tam genislige acilir. */}
        <button className="ib menu-tus" onClick={menuCevir}
                title={menuKapali ? 'Menüyü aç' : 'Menüyü kapat'}
                aria-expanded={!menuKapali}>
          ☰
        </button>
        <div className="marka marka-bag" role="link" tabIndex={0}
             title={c('Ana sayfa')}
             onClick={() => git('/panel')}
             onKeyDown={e => { if (e.key === 'Enter') git('/panel') }}>
          {/* BASE_URL: uygulama alt yolda yayinda olabilir (/ai). Mutlak "/..." yazmak
              yayinda 404 veriyordu - sunucu kokunde degil /ai altinda duruyor. */}
          <span className="lg">
            <img src={`${import.meta.env.BASE_URL}gentegre-sembol.svg`} alt="Gentegre" />
          </span>
          {/* Marka urun moduna gore (215): ikon ayni, ad degisir. */}
          {urunAdi(kullanici?.urunModu)}
        </div>

        <button className="ust-ara" onClick={paletiAc} title={c('Komut paleti')}>
          <span>🔍</span>
          <span>{c('Ara ya da komut yaz…')}</span>
          <kbd>Ctrl K</kbd>
        </button>

        {/* Sube markasi ARA KUTUSU ile TEMA dugmesi arasinda ortada (kullanici). */}
        {aktifSube && (
          <span className="sube-marka-kap" onMouseDown={e => e.stopPropagation()}>
            <div className={`marka sube-marka${cokSube ? ' marka-bag' : ''}`}
                 role={cokSube ? 'button' : undefined} tabIndex={cokSube ? 0 : undefined}
                 title={cokSube ? c('Çalışılan şube - değiştirmek için tıklayın') : c('Çalışılan şube')}
                 onClick={() => cokSube && setSubeMenusu(v => !v)}
                 onKeyDown={e => { if (cokSube && e.key === 'Enter') setSubeMenusu(v => !v) }}>
              <span className="lg">
                {subeLogo
                  ? <img src={subeLogo} alt="" />
                  : <span className="sube-harf">{aktifSube.ad.trim().charAt(0).toLocaleUpperCase('tr')}</span>}
              </span>
              {aktifSube.ad}{cokSube && <span className="sube-ok">▾</span>}
            </div>
            {subeMenusu && (
              <span className="dil-menu sube-menu">
                {kullanici?.subeler.map(s => (
                  <button key={s.id} type="button"
                          className={`dil-oge${s.id === kullanici?.subeId ? ' on' : ''}`}
                          onClick={() => { setSubeMenusu(false); if (s.id !== kullanici?.subeId) void subeDegistir(s.id) }}>
                    {s.ad}{s.yazma ? '' : <span className="sonuk"> ({c('salt okuma')})</span>}
                  </button>
                ))}
              </span>
            )}
          </span>
        )}

        <div className="ustsag">
          {kullanici?.subeYazma === false && <span className="rozet uyari">{c('salt okuma')}</span>}

          {/* GECE / GUNDUZ: uc durumlu - Sistem, Gündüz, Gece. Secim tarayicida
              saklanir (ayni hesap iki cihazda farkli olabilir). */}
          <button className="ib" title={`${c('Tema')} — ${c(TEMA_ADI[tema])}`}
                  onClick={() => { const y = temaSonraki(tema); setTema(y); temaUygula(y) }}>
            {TEMA_IKON[tema]}
          </button>

          {/* MESAJLAR ve AI (menu yeniden duzeni, plan kural 6): bunlar ARAC,
              is akisi degil - ana menude iki ogelik bir grup aciyorlardi.
              Ust cubuga alindi; yetkisi/modulu olmayanda hic cizilmez. */}
          {yetki('mesaj') && (
            <NavLink to="/mesajlar" className="ib" title={c('Mesajlar')}>💬</NavLink>
          )}
          {yetki('ai') && (
            <NavLink to="/yapay-zeka" className="ib" title={c('Yapay Zeka')}>✨</NavLink>
          )}

          {/* ZIL (662): onay bekleyen isler - simdilik iskonto onaylari.
              Dugme vardi ama hicbir sey yapmiyordu. */}
          <ZilPaneli c={c} />

          {/* Dil secimi: zilin saginda bayrak. Kullanici Ayarlari icindeki dil
              kutusuyla AYNI degeri yazar (taraf_kullanici.dil) - burasi kisayol. */}
          <span className="dil-sec" onMouseDown={e => e.stopPropagation()}>
            <button type="button" className="ib" title={`${c('Dil')} — ${DILLER[kullanici?.dil ?? 0]?.ad ?? ''}`}
                    onClick={() => setDilMenusu(a => !a)}>
              <Bayrak dil={kullanici?.dil ?? 0} boy={18} />
            </button>
            {dilMenusu && (
              <span className="dil-menu">
                {DILLER.map(d => (
                  <button key={d.deger} type="button"
                          className={`dil-oge${(kullanici?.dil ?? 0) === d.deger ? ' on' : ''}`}
                          onClick={() => { setDilMenusu(false); void dilSec(d.deger) }}>
                    <span className="bayrak"><Bayrak dil={d.deger} /></span> {d.ad}
                  </button>
                ))}
              </span>
            )}
          </span>
          <button className="ib" title={c('Yardım')}>?</button>
          {/* ÇIKIŞ AYIRT EDİLİR (kullanıcı): zil/yardım/dil ikonlarıyla aynı
              görünümdeydi ve başlığı Türkçesizdi ("Cikis"). Yanlışlıkla
              basıldığında oturum kapanan tek düğme bu - komşularından ayrı
              dursun: solunda ince ayraç, üzerine gelince kırmızı vurgu. */}
          <span className="ust-ayrac" aria-hidden="true" />
          {/* ÇIKIŞ İKONU: ⏻ (U+23FB) sistem fontlarında yok, tarayıcı boş kutu
              çiziyordu; yazılı düğme de şeritte fazla yer kapladı (kullanıcı:
              "bu sefer de büyük oldu, ikon haline getir"). Çizim artık inline
              SVG - fonta bağlı değil, komşu ikonlarla aynı 30px kutuda.
              Kırmızı kalır: üst şeritteki tek yıkıcı düğme bu. */}
          <button type="button" className="ib cikis" title={c('Oturumu kapat')}
                  onClick={() => void cikisYap()}>
            <svg viewBox="0 0 24 24" width="16" height="16" aria-hidden="true"
                 fill="none" stroke="currentColor" strokeWidth="2"
                 strokeLinecap="round" strokeLinejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
              <polyline points="16 17 21 12 16 7" />
              <line x1="21" y1="12" x2="9" y2="12" />
            </svg>
          </button>
          <button
            type="button"
            className="avt"
            title={`Kullanıcı Ayarları — ${kullanici?.ad ?? ''}`}
            onClick={() => ayar.setAcik(true)}
          >
            {profilResmi ? <img src={profilResmi} alt="" /> : basHarfler}
          </button>
        </div>
      </header>

      <div className="govde">
        <aside className="yan">
          <YanMenu satirlar={satirlar} bolgeliMenu={kullanici?.urunModu === 2} tercih={tercih}
                   panelYetkisi={yetki('panel')} aktifSubeAd={aktifSube?.ad}
                   kullaniciKod={kullanici?.kod} rolAdi={kullanici?.rolAdi} />
        </aside>

        <main className="ana" key={ceviriSurumu}><Outlet /></main>
      </div>

      {/* KULLANICI AYARLARI (669): dort sekmeli pencere ayri bilesende
          (bilesenler/KullaniciAyarlari.tsx). Kabuk'ta gomulu dururken
          Hesabim/Gorunum/Guvenlik/Bildirim sekmeleri kabugu 200 satir daha
          buyutecekti; pencerenin kendi verisi de var (hesap, oturumlar). */}
      <KullaniciAyarlari ayar={ayar} tema={tema} setTema={setTema} c={c} />

      {/* AI REHBER (447): sag altta, her ekranda. Yol gosterir; kayit
          degistirmez. Yetkisi olmayana hic cizilmez. */}
      {yetki('ai.rehber') && <AiRehberPaneli urunModu={kullanici?.urunModu} />}
    </div>
  );
}
