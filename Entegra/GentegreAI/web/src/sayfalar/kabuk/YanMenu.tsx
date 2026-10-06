/**
 * SOL MENU (yan serit icerigi): Ana Sayfa, calisma alani, Favori, En Son,
 * bolgeler/gruplar/ogeler ve oturum bilgisi. Kabuk.tsx'ten cikarildi
 * (kullanici: "refaktor") - acik/kapali grup, bolge accordion ve calisma
 * alani durumu buraya ait; Kabuk ust seridi ve pencereleri yonetir.
 *
 * Menu satirlari HAZIR gelir (kabuk/menuAgaci.menuSatirlariKur); tercihler
 * (favori, en son, calisma alani) Kabuk'un kancasindan (useMenuTercihleri)
 * gecirilir - kayit noktasi (sonKaydet) rota degisimini Kabuk izler.
 */
import { useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { menuYolu, yolEslesir } from '../../bilesenler/taleplerim/personelTalebi';
import { c, cm } from '../../dil/ceviri';
import { MenuIkon, grupla, GRUP_IKON, GRUP_IKON_CEV, ALTGRUP_IKON,
         type MenuOgesi, type MenuSatiri } from './menuAgaci';
import { BOLGE_HBYS, GRUP_SIRA_HBYS, grupBolgesi,
         type MenuBolgesi } from './menuBolgeleri';
import { SURUM_ETIKET } from '../../surum';
import type { useMenuTercihleri } from './useMenuTercihleri';

export interface YanMenuProps {
  satirlar: MenuSatiri[];
  /** HBYS (urun modu 2): bolgeler + calisma alani; ERP duz grup listesi. */
  bolgeliMenu: boolean;
  tercih: ReturnType<typeof useMenuTercihleri>;
  panelYetkisi: boolean;
  aktifSubeAd?: string;
  kullaniciKod?: string;
  rolAdi?: string;
  /** Aktif subenin kurum profili (786) - Oturum bolumunde yazilir. */
  kurumProfilAdi?: string;
}

export function YanMenu({ satirlar, bolgeliMenu, tercih, panelYetkisi, aktifSubeAd,
                          kullaniciKod, rolAdi, kurumProfilAdi }: YanMenuProps) {
  const konum = useLocation();
  // SEÇİLİ MADDE: talep kartı personel listesinden açıldıysa personel listesi;
  //   eşleşme tam yol ya da alt yol ("/personel-izin" Personel'i yakmasın).
  const yol = menuYolu(konum.pathname, konum.state);
  const secili = (m: string) => yolEslesir(yol, m);
  const { favoriler, favoriToggle } = tercih;

  /** "liste" rozetinin yerine yildiz: bos = ekle, dolu = cikar. */
  const yildiz = (yol: string) => (
    <button type="button" className="rz"
            title={c(favoriler.includes(yol) ? 'Favorilerden çıkar' : 'Favorilere ekle')}
            style={{ border: 0, background: 'transparent', cursor: 'pointer',
                     padding: 0, fontSize: 13, lineHeight: 1 }}
            onClick={e => { e.preventDefault(); e.stopPropagation(); favoriToggle(yol) }}>
      {favoriler.includes(yol) ? '★' : '☆'}
    </button>
  );

  // Acik/kapali durumu kullanici ELLE degistirmedikce, aktif alt-ogeyi iceren grup
  //   otomatik acik gelir (dogrudan /tedarikci gibi bir URL'e gelindiginde de gorunsun).
  const [acikGruplar, setAcikGruplar] = useState<Record<string, boolean>>({});
  const grupAcikMi = (ad: string, alt: MenuOgesi[]) =>
    ad in acikGruplar ? acikGruplar[ad] : alt.some(m => secili(m.yol));

  // BOLGE ACCORDION (V2): HBYS'de gruplar 7 bolge altinda; ayni anda TEK bolge
  //   acik, digerleri kapali - menu hicbir zaman bir ekrani asmaz. Kullanici
  //   secmedikce aktif rotayi iceren bolge acik gelir; hicbiri icermiyorsa
  //   ilk bolge (Hasta Akisi). Tekrar tiklaninca kapanir ('' = hicbiri).
  const [acikBolge, setAcikBolge] = useState<string | null>(null);
  // Satirin bolgesi: grup satiri grup adiyla, grupsuz DUZ oge (Demirbas) kendi
  //   adiyla bulunur; bolge listesinde olmayan duz oge bolgelerin ustunde kalir.
  const satirBolgesi = (s: MenuSatiri): MenuBolgesi | undefined =>
    s.tur === 'grup'
      // Kurumun tasidigi bolge once (979): menu duzeninde grup baska bolgeye
      //   alinmissa koddaki harita degil, o gecerli.
      ? (s.bolge ? BOLGE_HBYS.find(b => b.ad === s.bolge) : undefined)
        ?? grupBolgesi(s.alt.find(m => m.grupHam)?.grupHam)
      : GRUP_SIRA_HBYS.includes(s.m.adHam ?? '') ? grupBolgesi(s.m.adHam) : undefined;
  const satirAktifMi = (s: MenuSatiri) => s.tur === 'grup'
    ? s.alt.some(m => secili(m.yol)) : secili(s.m.yol);
  const tumBolgeler = bolgeliMenu
    ? BOLGE_HBYS.map(b => ({ b, satirlar: satirlar.filter(s => satirBolgesi(s)?.ad === b.ad) }))
      .filter(x => x.satirlar.length > 0)
    : [];
  const bolgeAktifMi = (b: MenuBolgesi) =>
    satirlar.some(s => satirBolgesi(s)?.ad === b.ad && satirAktifMi(s));
  // TUM BOLGELER GORUNUR (kullanici): calisma-alanina gore bolge gizleme ve
  //   "Diger bolgeler" satiri kaldirildi - hicbir profilde cikmasin. Bolge
  //   modu zaten yalniz hastane/tip merkezinde acik (Kabuk: bolgeliMenu);
  //   orada da tum bolgeler alt alta, accordion ile tek acik durur.
  const bolgeler = tumBolgeler;
  // Ayni rota iki bolgede olabilir (Medula Kabul: Kayit Kabul + Medula) - kullanici
  //   secmediyse ILK aktif bolge acilir; bolge icine her tiklama (grup ya da oge)
  //   o bolgeyi sabitler, geldigi yer acik kalir.
  const bolgeAcikMi = (b: MenuBolgesi) => {
    if (acikBolge !== null) return acikBolge === b.ad;
    const ilkAktif = bolgeler.find(x => bolgeAktifMi(x.b))?.b.ad ?? bolgeler[0]?.b.ad;
    return ilkAktif === b.ad;
  };
  const bolgeCevir = (b: MenuBolgesi) => setAcikBolge(bolgeAcikMi(b) ? '' : b.ad);

  /** Grupsuz duz oge (Ana Sayfa disinda or. Demirbas). */
  const duzCiz = (m: MenuOgesi) => (
    <NavLink key={m.yol} to={m.yol}
             className={() => `mi ${secili(m.yol) ? 'on' : ''}`}>
      <MenuIkon ic={m.ic} />
      <span>{m.ad}</span>
      {yildiz(m.yol)}
    </NavLink>
  );
  /** Grup satiri (acilir-kapanir ana menu + alt gruplari) - bolgeli ve bolgesiz menude ortak. */
  const grupCiz = (s: Extract<MenuSatiri, { tur: 'grup' }>) => (
              <div key={s.ad}>
                <button
                  type="button"
                  className="mi"
                  style={{ width: '100%', border: 0, background: 'transparent', cursor: 'pointer' }}
                  onClick={() => setAcikGruplar(g => ({ ...g, [s.ad]: !grupAcikMi(s.ad, s.alt) }))}
                >
                  <MenuIkon ic={s.ikon ?? GRUP_IKON[s.ad] ?? GRUP_IKON_CEV[s.ad] ?? '📁'} />
                  <span>{s.ad}</span>
                  <span className="rz">{grupAcikMi(s.ad, s.alt) ? '▾' : '▸'}</span>
                </button>
                {grupAcikMi(s.ad, s.alt) && grupla(s.alt, m => m.altGrup).map(a => a.tur === 'duz' ? (
                  <NavLink
                    key={a.m.yol}
                    to={a.m.yol}
                    className={() => `mi ${secili(a.m.yol) ? 'on' : ''}`}
                    style={{ paddingLeft: 34 }}
                  >
                    <MenuIkon ic={a.m.ic} />
                    <span>{a.m.ad}</span>
                    {yildiz(a.m.yol)}
                  </NavLink>
                ) : (
                  // Ikinci seviye (ör. Yönetim › Ayarlar): kendi ac/kapa durumu,
                  //   bir tik daha icerden.
                  <div key={`${s.ad}/${a.ad}`}>
                    <button
                      type="button"
                      className="mi"
                      style={{ width: '100%', border: 0, background: 'transparent',
                               cursor: 'pointer', paddingLeft: 34 }}
                      onClick={() => setAcikGruplar(g => ({
                        ...g, [`${s.ad}/${a.ad}`]: !grupAcikMi(`${s.ad}/${a.ad}`, a.alt) }))}
                    >
                      <span className="ic">{ALTGRUP_IKON[a.ad] ?? '⚙️'}</span>
                      <span>{a.ad}</span>
                      <span className="rz">{grupAcikMi(`${s.ad}/${a.ad}`, a.alt) ? '▾' : '▸'}</span>
                    </button>
                    {grupAcikMi(`${s.ad}/${a.ad}`, a.alt) && a.alt.map(m => (
                      <NavLink
                        key={m.yol}
                        to={m.yol}
                        className={() => `mi ${secili(m.yol) ? 'on' : ''}`}
                        style={{ paddingLeft: 52 }}
                      >
                        <MenuIkon ic={m.ic} />
                        <span>{m.ad}</span>
                        {yildiz(m.yol)}
                      </NavLink>
                    ))}
                  </div>
                ))}
              </div>
  );

  return (
          <div className="yanic">
            {/* Panel menude YOKTU: kullanici bir listeye girince ana sayfaya
                donmenin yolu kalmiyordu. En ustte, gruplarin disinda. */}
            {/* Ana Sayfa da YETKIYE bagli (241, kullanici: "anasayfayi da
                yetkilerde en basa al"). */}
            {panelYetkisi && (
              <NavLink to="/panel"
                       className={() => `mi ${yol === '/panel' ? 'on' : ''}`}>
                <span className="ic">🏠</span>
                <span>{cm('Ana Sayfa')}</span>
              </NavLink>
            )}

            {/* FAVORI grubu Ana Sayfa'nin ALTINDA (kullanici): yildizlanan ogeler bu
                menunun altinda; diger gruplar gibi acilir-kapanir, varsayilan
                ACIK. Bos ise hic cizilmez. */}
            {favoriler.length > 0 && (
              <div>
                <button type="button" className="mi"
                        style={{ width: '100%', border: 0, background: 'transparent', cursor: 'pointer' }}
                        onClick={() => setAcikGruplar(g => ({ ...g, '⭐Favori': !(g['⭐Favori'] ?? true) }))}>
                  <span className="ic">⭐</span>
                  <span>{cm('Favori')}</span>
                  <span className="rz">{(acikGruplar['⭐Favori'] ?? true) ? '▾' : '▸'}</span>
                </button>
                {/* Siralama EKLEME sirasi degil ANA MENU sirasi (kullanici):
                    Musteri Listesi menude tekliften ustteyse favoride de ustte. */}
                {(acikGruplar['⭐Favori'] ?? true) && satirlar
                  .flatMap(sat => (sat.tur === 'duz' ? [sat.m] : sat.alt))
                  .filter(m => favoriler.includes(m.yol))
                  .map(m => {
                  const yol = m.yol;
                  return (
                    <NavLink key={`fav-${yol}`} to={yol} style={{ paddingLeft: 34 }}
                             className={() => `mi ${secili(yol) ? 'on' : ''}`}>
                      <MenuIkon ic={m.ic} />
                      <span>{m.ad}</span>
                      {yildiz(yol)}
                    </NavLink>
                  );
                })}
              </div>
            )}

            {/* EN SON BOLUMU KALDIRILDI (kullanici): favoriler bilerek
                isaretleniyor; kendiliginden biriken ikinci bir liste menuyu
                uzatiyordu. Son kullanim bilgisi DURUYOR - komut paleti
                (Ctrl+K) siralamasinda kullaniliyor. */}

            {/* "Calisma alani" bolum basligi kaldirildi (kullanici). */}
            {/* BOLGESIZ (ERP) ya da bolgeye girmeyen duz ogeler. */}
            {satirlar.filter(s => !bolgeliMenu || (s.tur === 'duz' && !satirBolgesi(s))).map(s => s.tur === 'duz' ? (
              <NavLink
                key={s.m.yol}
                to={s.m.yol}
                className={() => `mi ${secili(s.m.yol) ? 'on' : ''}`}
              >
                <MenuIkon ic={s.m.ic} />
                <span>{s.m.ad}</span>
                {yildiz(s.m.yol)}
              </NavLink>
            ) : grupCiz(s))}

            {/* BOLGELER (V2, HBYS): renkli baslik + accordion; grup satirlari
                bolgesiz menuyle AYNI cizimdir (grupCiz). */}
            {bolgeler.map(({ b, satirlar: alt }) => (
              <div key={b.ad} onClickCapture={() => { if (bolgeAcikMi(b)) setAcikBolge(b.ad) }}>
                <button type="button" className="mn-bolge" onClick={() => bolgeCevir(b)}
                        title={c(bolgeAcikMi(b) ? 'Bölgeyi kapat' : 'Bölgeyi aç')}>
                  <i style={{ background: b.renk }} />
                  <span>{cm(b.ad)}</span>
                  <span className="rz">{bolgeAcikMi(b) ? '▾' : '▸'}</span>
                </button>
                {bolgeAcikMi(b) && alt.map(s => s.tur === 'grup' ? grupCiz(s) : duzCiz(s.m))}
              </div>
            ))}
            <div className="bolum">{cm('Oturum')}</div>
            <div className="mi" style={{ cursor: 'default' }}>
              <span className="ic">🏢</span>
              <span>{aktifSubeAd ?? '-'}</span>
            </div>
            <div className="mi" style={{ cursor: 'default' }}>
              <span className="ic">👤</span>
              <span>{kullaniciKod}</span>
              <span className="rz">{rolAdi}</span>
            </div>
            {/* KURUM PROFILI (786, kullanici: "oturum basligi altina profil
                ikonu ve saginda o anki o subedeki secili profil gelsin"):
                menu, kart sekmeleri ve rol onerileri bu profile gore
                suzuluyor - hangisinde oldugu yazili dursun. */}
            {kurumProfilAdi && (
              <div className="mi" style={{ cursor: 'default' }}
                   title={cm('Bu şubenin kurum profili')}>
                <span className="ic">🪪</span>
                <span>{kurumProfilAdi}</span>
              </div>
            )}
            {/* UYGULAMA SÜRÜMÜ (kullanıcı: "versiyon no ver ve görünür olsun"). */}
            <div className="mi" style={{ cursor: 'default', opacity: 0.7 }}
                 title={cm('Uygulama sürümü')}>
              <span className="ic">🏷️</span>
              <span>{SURUM_ETIKET}</span>
            </div>
          </div>
  );
}
