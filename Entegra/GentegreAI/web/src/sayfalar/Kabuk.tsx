import { NavLink, Outlet, useLocation } from 'react-router-dom';
import { useOturum } from '../kimlik/OturumBaglami';
import { LISTELER } from './Liste';

/**
 * Uygulama kabugu — ana mockup (Ekranlar/gentegre_v4_web.html, "Konsept C") duzeni:
 *   ust (56px): marka + genel arama (Ctrl+K) + ikonlar + kullanici
 *   govde: yan (250px menu, altta komut paleti ipucu) + ana (sayfa icerigi)
 *
 * Menu kullanicinin YETKISINE gore uretilir; yetkisiz modul hic cizilmez.
 */
export function Kabuk() {
  const { kullanici, cikisYap, subeDegistir, yetki } = useOturum();
  const konum = useLocation();

  // Menu, liste tanimlarindan uretilir; yetkisiz modul hic cizilmez.
  const moduller = LISTELER
    .filter(l => yetki(l.yetkiKodu))
    .map(l => ({ yol: `/${l.kaynak}`, ad: l.menuAd, ic: l.ic, rz: 'liste' }));

  const aktifSube = kullanici?.subeler.find(s => s.id === kullanici?.subeId);
  const basHarfler = (kullanici?.ad ?? '?')
    .split(' ').filter(Boolean).slice(0, 2).map(p => p[0]?.toLocaleUpperCase('tr')).join('');

  /** Ust seritteki arama kutusu komut paletini acar (paletin kendi kisayolu Ctrl+K). */
  const paletiAc = () =>
    window.dispatchEvent(new KeyboardEvent('keydown', { key: 'k', ctrlKey: true, bubbles: true }));

  return (
    <div className="kabuk">
      <header className="ust">
        <div className="marka">
          <span className="lg">G</span>
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
          <button className="ib" title="Yardim">?</button>
          <button className="ib" title="Cikis" onClick={() => void cikisYap()}>⏻</button>
          <div className="avt" title={`${kullanici?.ad} · ${kullanici?.rolAdi}`}>{basHarfler}</div>
        </div>
      </header>

      <div className="govde">
        <aside className="yan">
          <div className="yanic">
            <div className="bolum">Calisma alani</div>
            {moduller.map(m => (
              <NavLink
                key={m.yol}
                to={m.yol}
                className={() => `mi ${konum.pathname.startsWith(m.yol) ? 'on' : ''}`}
              >
                <span className="ic">{m.ic}</span>
                <span>{m.ad}</span>
                <span className="rz">{m.rz}</span>
              </NavLink>
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
    </div>
  );
}
