import { useEffect, useState } from 'react';
import { NavLink, Outlet, useLocation } from 'react-router-dom';
import { useOturum } from '../../kimlik/OturumBaglami';
import { menuSatirlariKur } from '../kabuk/menuAgaci';
import { LISTELER } from '../Liste';
import { KullaniciAyarlari } from '../../bilesenler/KullaniciAyarlari';
import { useKullaniciAyari } from '../kabuk/useMenuTercihleri';
import { TEMA_IKON, temaOku, temaSonraki, temaUygula, type Tema }
  from '../../bilesenler/tema';
import { aktifBolum, portalBolumleri, PORTAL_ADI, type PortalTuru } from './portalMenu';
import { PortalBaslikSaglayici } from './portalBaslik';
import { c } from '../../dil/ceviri';

/**
 * PORTAL KABUĞU V2 (796/818) — dış hekim, dış kurum ve hasta portalları.
 *
 * <b>Neden ayrı kabuk:</b> kurum içi kabuk 13 gruplu menü, favoriler, çalışma
 * alanı, komut paleti, şube seçimi ve bildirim paneli taşıyor. Portal
 * kullanıcısının tek şubesi, beş-altı ekranı ve çoğu zaman bir telefonu var.
 * Aynı kabuğu "sadeleştirerek" kullanmak, her yeni kurum içi özelliğin
 * portalda da gizlenmesini gerektirirdi - biri unutulduğunda portal
 * kullanıcısı göremeyeceği bir düğmeye basar.
 *
 * <b>Telefon ilk:</b> dar ekranda menü ÇEKMECE (off-canvas), üstte tek satır
 * başlık ve hamburger; geniş ekranda sol sabit şerit (mockup
 * `Ekranlar/Portal/*.html`). Kırılma noktası 900px - tablet dikeyde de
 * çekmece, çünkü 186px menü + liste tabloları o genişlikte sıkışıyor.
 *
 * <b>Menü açılır:</b> bölümler accordion; aynı anda tek bölüm açık. Beş ekran
 * için bile katlanır menü, telefonda listenin ekranın yarısını yemesini
 * engelliyor. Aktif ekranın bölümü kendiliğinden açık gelir.
 *
 * <b>Menü kaynağı tek:</b> hangi ekranların çizileceğine yetki karar veriyor
 * (`menuSatirlariKur`); portal tablosu yalnız adlandırıp gruplar
 * (`portalMenu.ts`). Portala özel bir "izinli ekranlar listesi" tutulsaydı,
 * sunucu yetki verdiği hâlde ekran menüde çıkmazdı.
 */
export function PortalKabuk() {
  const { kullanici, cikisYap, dilDegistir, yetki } = useOturum();
  const konum = useLocation();

  const portalTuru = (kullanici?.portalTuru ?? 1) as PortalTuru;
  const satirlar = menuSatirlariKur(LISTELER, yetki, kullanici?.urunModu, kullanici?.moduller);
  const ogeler = satirlar.flatMap(s => (s.tur === 'duz' ? [s.m] : s.alt));
  // KAPSAM SUNUCUDAN (796 V2): hangi ekranin portalda satir gosterebilecegini
  //   kapsam kurallari soyluyor ve onlar sunucuda - istemci "su ekran portalda
  //   calisir" listesi tutmaz, yoksa sunucu kurali degisince menu yanilirdi.
  const bolumler = portalBolumleri(ogeler, portalTuru, kullanici?.portalKaynaklar);

  const [cekmece, setCekmece] = useState(false);
  const [acik, setAcik] = useState<string | null>(null);
  const [tema, setTema] = useState<Tema>(() => temaOku());
  // AYAR PENCERESİ KURUM İÇİ KABUKLA AYNI (parola + dil): portal kullanıcısı
  //   da parolasını değiştirebilmeli - ikinci bir pencere yazmak, birinde
  //   düzeltilen doğrulamanın ötekinde eksik kalması demekti.
  const ayar = useKullaniciAyari({
    mevcutDil: kullanici?.dil ?? 0, dilDegistir, cikisYap,
  });

  // AKTİF BÖLÜM AÇIK GELİR: kullanıcı elle bir bölüm açmadıysa, bulunduğu
  //   ekranın bölümü açılır - doğrudan bir bağlantıdan gelindiğinde menüde
  //   nerede olduğu görünsün.
  const secili = aktifBolum(bolumler, konum.pathname);
  const bolumAcikMi = (ad: string) => (acik === null ? ad === secili : acik === ad);

  // ROTA DEĞİŞİNCE ÇEKMECE KAPANIR: telefonda menüden ekrana geçince çekmece
  //   açık kalsaydı kullanıcı içeriği hiç görmezdi.
  useEffect(() => { setCekmece(false) }, [konum.pathname]);

  // ESC ile kapanır: çekmece açıkken arkadaki içerik kaydırılamaz.
  useEffect(() => {
    if (!cekmece) return;
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') setCekmece(false) };
    document.addEventListener('keydown', tus);
    return () => document.removeEventListener('keydown', tus);
  }, [cekmece]);

  useEffect(() => { document.title = `${PORTAL_ADI[portalTuru]} · ${kullanici?.ad ?? ''}` },
            [portalTuru, kullanici?.ad]);

  const temaCevir = () => {
    const y = temaSonraki(tema);
    setTema(y); temaUygula(y);
  };

  return (
    <div className="pk">
      <header className="pk-ust">
        {/* HAMBURGER YALNIZ DAR EKRANDA GÖRÜNÜR (CSS): geniş ekranda menü
            zaten sabit, düğme yer kaplamasın. */}
        <button type="button" className="pk-hamburger" aria-label="Menü"
                aria-expanded={cekmece} onClick={() => setCekmece(a => !a)}>
          {cekmece ? '✕' : '☰'}
        </button>
        <div className="pk-marka">
          <span className="pk-ad">{PORTAL_ADI[portalTuru]}</span>
          <span className="pk-kisi">{kullanici?.ad}</span>
        </div>
        <button type="button" className="pk-ikon" title="Tema" onClick={temaCevir}>
          {TEMA_IKON[tema]}
        </button>
        <button type="button" className="pk-ikon" title="Ayarlar"
                onClick={() => ayar.setAcik(true)}>⚙</button>
        <button type="button" className="pk-cikis" onClick={() => void cikisYap()}>
          Çıkış
        </button>
      </header>

      {/* KARARTMA: çekmece açıkken içeriğe dokunmak menüyü kapatır - telefonda
          en beklenen davranış. */}
      <div className={`pk-perde${cekmece ? ' acik' : ''}`}
           onClick={() => setCekmece(false)} aria-hidden="true" />

      <nav className={`pk-yan${cekmece ? ' acik' : ''}`} aria-label="Portal menüsü">
        {bolumler.length === 0 && (
          <div className="pk-bos">
            Görüntüleyebileceğiniz bir ekran tanımlı değil.<br />
            Kurumunuzla görüşün.
          </div>
        )}
        {bolumler.map(b => {
          const ackMi = bolumAcikMi(b.ad);
          return (
            <section className={`pk-bolum${ackMi ? ' on' : ''}`} key={b.ad}>
              <button type="button" className="pk-bolum-bas" aria-expanded={ackMi}
                      onClick={() => setAcik(ackMi ? '' : b.ad)}>
                <span>{b.ad}</span>
                <span className="ok" aria-hidden="true">{ackMi ? '▾' : '▸'}</span>
              </button>
              {ackMi && (
                <div className="pk-liste">
                  {b.ogeler.map(o => (
                    <NavLink key={o.yol} to={o.yol}
                             className={({ isActive }) => `pk-oge${isActive ? ' on' : ''}`}>
                      <span className="ic" aria-hidden="true">{o.ic}</span>
                      <span className="ad">{o.ad}</span>
                    </NavLink>
                  ))}
                </div>
              )}
            </section>
          );
        })}

        <div className="pk-kimlik">
          {kullanici?.ad}
          <span className="sonuk">
            {portalTuru === 1 ? 'Dış hekim' : portalTuru === 2 ? 'Anlaşmalı kurum' : 'Hasta'}
            {' · '}yalnız kendi kayıtlarınız
          </span>
        </div>
      </nav>

      <main className="pk-icerik">
        {/* EKRAN BASLIGI = MENU ADI: menude "Randevularim" yazip sayfada
            "Randevular" gostermek, kullanicinin tikladigi adi bulamamasi
            demekti. Ad tek yerde (portalMenu) durur. */}
        <PortalBaslikSaglayici ogeler={ogeler} portalTuru={portalTuru}
                               portalKaynaklar={kullanici?.portalKaynaklar}>
          <Outlet />
        </PortalBaslikSaglayici>
      </main>

      <KullaniciAyarlari ayar={ayar} tema={tema} setTema={setTema} c={c} />
    </div>
  );
}
