import { useEffect, useState } from 'react';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { useOturum } from '../kimlik/OturumBaglami';
import { LISTELER } from './Liste';

interface MenuOgesi {
  yol: string;
  ad: string;
  ic: string;
  rz: string;
  grup?: string;
  altGrup?: string;
  /** Grup ICINDEKI sira (kucuk once). Gruplarin kendi sirasi degismez. */
  sira?: number;
}

type MenuSatiri =
  | { tur: 'duz'; m: MenuOgesi }
  | { tur: 'grup'; ad: string; alt: MenuOgesi[] };

/** Sira korunarak grupla: her benzersiz grup adi ILK gorundugu yerde acilir. */
function grupla(liste: MenuOgesi[], sec: (m: MenuOgesi) => string | undefined): MenuSatiri[] {
  const satirlar: MenuSatiri[] = [];
  const indeks = new Map<string, number>();
  liste.forEach(m => {
    const ad = sec(m);
    if (!ad) { satirlar.push({ tur: 'duz', m }); return }
    if (!indeks.has(ad)) {
      indeks.set(ad, satirlar.length);
      satirlar.push({ tur: 'grup', ad, alt: [] });
    }
    (satirlar[indeks.get(ad)!] as { tur: 'grup'; ad: string; alt: MenuOgesi[] }).alt.push(m);
  });
  return satirlar;
}

/**
 * Uygulama kabugu — ana mockup (Ekranlar/gentegre_v4_web.html, "Konsept C") duzeni:
 *   ust (56px): marka + genel arama (Ctrl+K) + ikonlar + kullanici
 *   govde: yan (250px menu, altta komut paleti ipucu) + ana (sayfa icerigi)
 *
 * Menu kullanicinin YETKISINE gore uretilir; yetkisiz modul hic cizilmez.
 */
/**
 * Ana menu grup ikonlari. Hepsi ayni kart ikonuydu (📇) - gruplar birbirinden
 * ayirt edilemiyordu. Grup adi ANAHTAR: yeni grup eklenirse buraya bir satir.
 * Listede olmayan grup icin notr klasor cizilir.
 */
const GRUP_IKON: Record<string, string> = {
  'Hasta':   '🏥',
  'Cari':    '🤝',
  'Satış':   '🛍️',
  'Alış':    '🛒',
  'Kasa':    '💵',
  'Banka':   '🏦',
  'CRM':     '📈',
  'Stok':    '📦',
  'İK':      '👥',
  'Yönetim': '🛠️',
};

/** Arayuz dilleri - db/081: taraf_kullanici.dil (0 TR / 1 EN / 2 DE). */
const DILLER = [
  { deger: 0, ad: 'Türkçe',  bayrak: '🇹🇷' },
  { deger: 1, ad: 'English', bayrak: '🇬🇧' },
  { deger: 2, ad: 'Deutsch', bayrak: '🇩🇪' },
] as const;

export function Kabuk() {
  const { kullanici, cikisYap, subeDegistir, dilDegistir, yetki } = useOturum();
  const konum = useLocation();
  const git = useNavigate();

  // Menu, liste tanimlarindan uretilir; yetkisiz modul hic cizilmez. menuGrup verilen
  //   ogeler ("Cari" -> Musteri/Tedarikci/Kisi Listesi) acilir-kapanir bir ana menu
  //   altinda TOPLANIR; menuGrup'suz ogeler eskisi gibi duz sirada kalir.
  const yetkiliListeler = LISTELER.filter(l => yetki(l.yetkiKodu));
  const moduller: MenuOgesi[] =
    yetkiliListeler.map(l => ({
      yol: `/${l.rota ?? l.kaynak}`, ad: l.menuAd, ic: l.ic,
      rz: l.ozelSayfa ? 'ayar' : 'liste', grup: l.menuGrup, altGrup: l.menuAltGrup,
      sira: l.menuSira,
    }));

  // Iki seviye: grup (Cari, Kasa, Yönetim…) ve grubun icinde alt grup
  //   (Yönetim › Ayarlar). Ayni yardimci iki seviyede de kullanilir.
  const satirlar = grupla(moduller, m => m.grup);
  // Sira YALNIZ grup icinde uygulanir: gruplarin kendi sirasi (Hasta, Cari,
  //   Satis...) tanim sirasindan gelir, menuSira onu kaydirmamali.
  satirlar.forEach(sat => {
    if (sat.tur !== 'grup') return;
    sat.alt = sat.alt
      .map((m, i) => ({ m, i }))
      .sort((a, b) => (a.m.sira ?? 900 + a.i) - (b.m.sira ?? 900 + b.i) || a.i - b.i)
      .map(x => x.m);
  });

  // Acik/kapali durumu kullanici ELLE degistirmedikce, aktif alt-ogeyi iceren grup
  //   otomatik acik gelir (dogrudan /tedarikci gibi bir URL'e gelindiginde de gorunsun).
  const [acikGruplar, setAcikGruplar] = useState<Record<string, boolean>>({});
  const [kullaniciAyariAcik, setKullaniciAyariAcik] = useState(false);
  const [eskiSifre, setEskiSifre] = useState('');
  const [sifre1, setSifre1] = useState('');
  const [sifre2, setSifre2] = useState('');
  const [seciliDil, setSeciliDil] = useState(0);
  const [ayarMesaji, setAyarMesaji] = useState('');
  const [ayarKaydediliyor, setAyarKaydediliyor] = useState(false);
  /** Bayrak dugmesinin acilir listesi. */
  const [dilMenusu, setDilMenusu] = useState(false);
  const grupAcikMi = (ad: string, alt: typeof moduller) =>
    ad in acikGruplar ? acikGruplar[ad] : alt.some(m => konum.pathname.startsWith(m.yol));

  const aktifSube = kullanici?.subeler.find(s => s.id === kullanici?.subeId);
  const basHarfler = (kullanici?.ad ?? '?')
    .split(' ').filter(Boolean).slice(0, 2).map(p => p[0]?.toLocaleUpperCase('tr')).join('');

  /** Ust seritteki arama kutusu komut paletini acar (paletin kendi kisayolu Ctrl+K). */
  const paletiAc = () =>
    window.dispatchEvent(new KeyboardEvent('keydown', { key: 'k', ctrlKey: true, bubbles: true }));

  const ayarKapat = () => {
    setKullaniciAyariAcik(false);
    setAyarMesaji('');
    setEskiSifre('');
    setSifre1('');
    setSifre2('');
  };

  const ayarTamam = async () => {
    setAyarMesaji('');
    if (sifre1 || sifre2 || eskiSifre) {
      if (!eskiSifre) { setAyarMesaji('Mevcut şifre gerekli.'); return }
      if (sifre1.length < 8) { setAyarMesaji('Şifre en az 8 karakter olmalı.'); return }
      if (sifre1 !== sifre2) { setAyarMesaji('Şifreler aynı değil.'); return }
    }

    setAyarKaydediliyor(true);
    try {
      if (seciliDil !== (kullanici?.dil ?? 0)) await dilDegistir(seciliDil);
      if (sifre1 || sifre2 || eskiSifre) {
        await api.parolaDegistir(eskiSifre, sifre1);
        ayarKapat();
        await cikisYap();
        return;
      }
      ayarKapat();
    } catch (e) {
      setAyarMesaji(e instanceof Error ? e.message : 'Kullanıcı ayarları kaydedilemedi.');
    } finally {
      setAyarKaydediliyor(false);
    }
  };

  /** Bayraktan dil degistir - Kullanici Ayarlari'ndaki kutuyla ayni ucu cagirir. */
  async function dilSec(dil: number) {
    if (dil === (kullanici?.dil ?? 0)) return;
    try { await dilDegistir(dil) } catch { /* oturum katmani hatayi gosterir */ }
  }

  useEffect(() => {
    if (kullaniciAyariAcik) setSeciliDil(kullanici?.dil ?? 0);
  }, [kullaniciAyariAcik, kullanici?.dil]);

  useEffect(() => {
    if (!dilMenusu) return;
    const kapat = () => setDilMenusu(false);
    document.addEventListener('mousedown', kapat);
    return () => document.removeEventListener('mousedown', kapat);
  }, [dilMenusu]);

  useEffect(() => {
    if (!kullaniciAyariAcik) return;
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') ayarKapat() };
    window.addEventListener('keydown', esc);
    return () => window.removeEventListener('keydown', esc);
  }, [kullaniciAyariAcik]);

  return (
    <div className="kabuk">
      <header className="ust">
        <div className="marka marka-bag" role="link" tabIndex={0}
             title="Ana sayfa"
             onClick={() => git('/panel')}
             onKeyDown={e => { if (e.key === 'Enter') git('/panel') }}>
          {/* BASE_URL: uygulama alt yolda yayinda olabilir (/ai). Mutlak "/..." yazmak
              yayinda 404 veriyordu - sunucu kokunde degil /ai altinda duruyor. */}
          <span className="lg">
            <img src={`${import.meta.env.BASE_URL}gentegre-sembol.svg`} alt="Gentegre" />
          </span>
          Gentegre AI
        </div>

        <button className="ara" onClick={paletiAc} title="Komut paleti">
          <span>🔍</span>
          <span>Ara ya da komut yaz…</span>
          <kbd>Ctrl K</kbd>
        </button>

        <div className="ustsag">
          {kullanici?.subeYazma === false && <span className="rozet uyari">salt okuma</span>}

          {(kullanici?.subeler.length ?? 0) > 1 && (
            <select
              value={kullanici?.subeId ?? ''}
              onChange={e => void subeDegistir(Number(e.target.value))}
              title="Calisilan sube"
            >
              {kullanici?.subeler.map(s => (
                <option key={s.id} value={s.id}>{s.ad}{s.yazma ? '' : ' (salt okuma)'}</option>
              ))}
            </select>
          )}

          <button className="ib" title="Bildirimler">🔔</button>

          {/* Dil secimi: zilin saginda bayrak. Kullanici Ayarlari icindeki dil
              kutusuyla AYNI degeri yazar (taraf_kullanici.dil) - burasi kisayol. */}
          <span className="dil-sec" onMouseDown={e => e.stopPropagation()}>
            <button type="button" className="ib" title={`Dil — ${DILLER[kullanici?.dil ?? 0]?.ad ?? ''}`}
                    onClick={() => setDilMenusu(a => !a)}>
              {DILLER[kullanici?.dil ?? 0]?.bayrak ?? '🏳️'}
            </button>
            {dilMenusu && (
              <span className="dil-menu">
                {DILLER.map(d => (
                  <button key={d.deger} type="button"
                          className={`dil-oge${(kullanici?.dil ?? 0) === d.deger ? ' on' : ''}`}
                          onClick={() => { setDilMenusu(false); void dilSec(d.deger) }}>
                    <span className="bayrak">{d.bayrak}</span> {d.ad}
                  </button>
                ))}
              </span>
            )}
          </span>
          <button className="ib" title="Yardim">?</button>
          <button className="ib" title="Cikis" onClick={() => void cikisYap()}>⏻</button>
          <button
            type="button"
            className="avt"
            title={`Kullanıcı Ayarları — ${kullanici?.ad ?? ''}`}
            onClick={() => setKullaniciAyariAcik(true)}
          >
            {basHarfler}
          </button>
        </div>
      </header>

      <div className="govde">
        <aside className="yan">
          <div className="yanic">
            {/* Panel menude YOKTU: kullanici bir listeye girince ana sayfaya
                donmenin yolu kalmiyordu. En ustte, gruplarin disinda. */}
            <NavLink to="/panel"
                     className={() => `mi ${konum.pathname === '/panel' ? 'on' : ''}`}>
              <span className="ic">🏠</span>
              <span>Ana Sayfa</span>
            </NavLink>

            <div className="bolum">Calisma alani</div>
            {satirlar.map(s => s.tur === 'duz' ? (
              <NavLink
                key={s.m.yol}
                to={s.m.yol}
                className={() => `mi ${konum.pathname.startsWith(s.m.yol) ? 'on' : ''}`}
              >
                <span className="ic">{s.m.ic}</span>
                <span>{s.m.ad}</span>
                <span className="rz">{s.m.rz}</span>
              </NavLink>
            ) : (
              <div key={s.ad}>
                <button
                  type="button"
                  className="mi"
                  style={{ width: '100%', border: 0, background: 'transparent', cursor: 'pointer' }}
                  onClick={() => setAcikGruplar(g => ({ ...g, [s.ad]: !grupAcikMi(s.ad, s.alt) }))}
                >
                  <span className="ic">{GRUP_IKON[s.ad] ?? '📁'}</span>
                  <span>{s.ad}</span>
                  <span className="rz">{grupAcikMi(s.ad, s.alt) ? '▾' : '▸'}</span>
                </button>
                {grupAcikMi(s.ad, s.alt) && grupla(s.alt, m => m.altGrup).map(a => a.tur === 'duz' ? (
                  <NavLink
                    key={a.m.yol}
                    to={a.m.yol}
                    className={() => `mi ${konum.pathname.startsWith(a.m.yol) ? 'on' : ''}`}
                    style={{ paddingLeft: 34 }}
                  >
                    <span className="ic">{a.m.ic}</span>
                    <span>{a.m.ad}</span>
                    <span className="rz">{a.m.rz}</span>
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
                      <span className="ic">⚙️</span>
                      <span>{a.ad}</span>
                      <span className="rz">{grupAcikMi(`${s.ad}/${a.ad}`, a.alt) ? '▾' : '▸'}</span>
                    </button>
                    {grupAcikMi(`${s.ad}/${a.ad}`, a.alt) && a.alt.map(m => (
                      <NavLink
                        key={m.yol}
                        to={m.yol}
                        className={() => `mi ${konum.pathname.startsWith(m.yol) ? 'on' : ''}`}
                        style={{ paddingLeft: 52 }}
                      >
                        <span className="ic">{m.ic}</span>
                        <span>{m.ad}</span>
                        <span className="rz">{m.rz}</span>
                      </NavLink>
                    ))}
                  </div>
                ))}
              </div>
            ))}

            <div className="bolum">Oturum</div>
            <div className="mi" style={{ cursor: 'default' }}>
              <span className="ic">🏢</span>
              <span>{aktifSube?.ad ?? '-'}</span>
            </div>
            <div className="mi" style={{ cursor: 'default' }}>
              <span className="ic">👤</span>
              <span>{kullanici?.kod}</span>
              <span className="rz">{kullanici?.rolAdi}</span>
            </div>
          </div>

          <div className="yanalt">
            <div className="yankart">
              <div className="b">⌘ Komut paleti</div>
              <div className="s">Ctrl+K ile her ekrana, karta ve aksiyona tek satirdan ulas.</div>
            </div>
          </div>
        </aside>

        <main className="ana"><Outlet /></main>
      </div>

      {kullaniciAyariAcik && (
        <div className="kaperde" onMouseDown={e => { if (e.target === e.currentTarget) ayarKapat() }}>
          <div className="kawin kullanici-ayarlari" role="dialog" aria-label="Kullanıcı Ayarları">
            <div className="kabas">
              <span>👤 Kullanıcı Ayarları</span>
              <span className="kapt">Ortak\UKullaniciDuzenle · KULLANICI</span>
            </div>

            <div className="kagov">
              <div className="kagrup">
                <h6>Kimlik <span>kendi hesabınızda salt okunur</span></h6>
                <div className="kasat">
                  <label>Kullanıcı Adı</label>
                  <div className="kaara">
                    <input value={kullanici?.ad ?? ''} disabled />
                    <button className="kabtn" disabled title="Rehberden seç">⋯</button>
                    <span className="karoz">ID {kullanici?.id ?? '-'}</span>
                  </div>
                  <label>Kullanıcı Kodu</label><input value={kullanici?.kod ?? ''} disabled />
                  <label>Rol</label><input value={kullanici?.rolAdi ?? ''} disabled />
                  <label>Kullanıcı Durumu</label><input value="Aktif" disabled />
                  <label>Çalışılan Şube</label><input value={aktifSube?.ad ?? '-'} disabled />
                  <label>Dil</label>
                  <select value={seciliDil} onChange={e => setSeciliDil(Number(e.target.value))} disabled={ayarKaydediliyor}>
                    <option value={0}>Türkçe</option>
                    <option value={1}>English</option>
                    <option value={2}>Deutsch</option>
                  </select>
                </div>
              </div>

              <div className="kagrup">
                <h6>Şifre</h6>
                <div className="kasat">
                  <label>Mevcut Şifre</label>
                  <input
                    type="password"
                    value={eskiSifre}
                    onChange={e => setEskiSifre(e.target.value)}
                    disabled={ayarKaydediliyor}
                    autoComplete="current-password"
                  />
                  <label>Yeni Şifre</label>
                  <div className="kaara">
                    <input
                      type="password"
                      value={sifre1}
                      onChange={e => setSifre1(e.target.value)}
                      disabled={ayarKaydediliyor}
                      autoComplete="new-password"
                    />
                    {sifre1 && sifre1 === sifre2 && <span className="kaok">✓</span>}
                  </div>
                  <label>Yeni Şifre (Tekrar)</label>
                  <div className="kaara">
                    <input
                      type="password"
                      value={sifre2}
                      onChange={e => setSifre2(e.target.value)}
                      disabled={ayarKaydediliyor}
                      autoComplete="new-password"
                    />
                    {sifre2 && sifre1 === sifre2 && <span className="kaok">✓</span>}
                  </div>
                </div>
                {ayarMesaji && <div className="kauyari">{ayarMesaji}</div>}
                <div className="kanot">Şifre boş bırakılırsa değiştirilmez. Şifre değişirse oturum kapanır; yeni şifreyle tekrar girilir.</div>
              </div>
            </div>

            <div className="kaalt">
              <button className="bas" onClick={() => void ayarTamam()} disabled={ayarKaydediliyor}>
                {ayarKaydediliyor ? 'Kaydediliyor...' : 'Tamam'}
              </button>
              <button onClick={ayarKapat} disabled={ayarKaydediliyor}>İptal</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
