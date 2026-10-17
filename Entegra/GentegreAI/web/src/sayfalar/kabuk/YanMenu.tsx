/**
 * SOL MENU (yan serit icerigi): Ana Sayfa, Favori, gruplar/ogeler ve oturum bilgisi.
 * Kabuk.tsx'ten cikarildi (kullanici: "refaktor") - acik/kapali grup durumu buraya ait;
 * Kabuk ust seridi ve pencereleri yonetir. BOLGELER YOK (17.10.2026): menu tek seviye grup.
 *
 * Menu satirlari HAZIR gelir (kabuk/menuAgaci.menuSatirlariKur); tercihler
 * (favori, en son, calisma alani) Kabuk'un kancasindan (useMenuTercihleri)
 * gecirilir - kayit noktasi (sonKaydet) rota degisimini Kabuk izler.
 */
import { useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';

/** Tek satır olarak çizilen gruplar (içinde tek ekran). */
const TEK_SATIR_GRUPLAR = new Set(['Dökümler']);
import { menuYolu, yolEslesir } from '../../bilesenler/taleplerim/personelTalebi';
import { c, cm } from '../../dil/ceviri';
import { MenuIkon, grupla, GRUP_IKON, GRUP_IKON_CEV, ALTGRUP_IKON,
         type MenuOgesi, type MenuSatiri } from './menuAgaci';
import { SURUM_ETIKET } from '../../surum';
import type { useMenuTercihleri } from './useMenuTercihleri';

export interface YanMenuProps {
  satirlar: MenuSatiri[];
  tercih: ReturnType<typeof useMenuTercihleri>;
  panelYetkisi: boolean;
  aktifSubeAd?: string;
  kullaniciKod?: string;
  rolAdi?: string;
  /** Aktif subenin kurum profili (786) - Oturum bolumunde yazilir. */
  kurumProfilAdi?: string;
}

export function YanMenu({ satirlar, tercih, panelYetkisi, aktifSubeAd,
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

  /** Grupsuz duz oge (Ana Sayfa disinda or. Demirbas). */
  const duzCiz = (m: MenuOgesi) => (
    <NavLink key={m.yol} to={m.yol}
             className={() => `mi ${secili(m.yol) ? 'on' : ''}`}>
      <MenuIkon ic={m.ic} />
      <span>{m.ad}</span>
      {yildiz(m.yol)}
    </NavLink>
  );
  /** Grup satiri (acilir-kapanir ana menu + alt gruplari). */
  const grupCiz = (s: Extract<MenuSatiri, { tur: 'grup' }>) =>
    // TEK SATIRLIK GRUP (kullanıcı 10.10.2026: Dökümler "tek tıklık giriş"):
    //   grup menüdeki yerini korur (sıra, menü düzeni), ama açılır başlık
    //   yerine doğrudan ekrana giden tek satır çizilir - grup adı ve ikonuyla.
    s.alt.length === 1 && TEK_SATIR_GRUPLAR.has(s.alt[0].grupHam ?? '')
      ? duzCiz({ ...s.alt[0], ad: s.ad, ic: s.ikon ?? GRUP_IKON[s.ad] ?? s.alt[0].ic })
      : (
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

            {/* GRUPLAR VE DUZ OGELER tek seviyede, menu sirasiyla (bolgeler kaldirildi 17.10.2026). */}
            {satirlar.map(s => s.tur === 'duz' ? duzCiz(s.m) : grupCiz(s))}
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
