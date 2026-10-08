import { useEffect } from 'react';
import { BankoOturumu } from '../../sayfalar/banko/BankoOturumu';

/**
 * BANKO OTURUMU MODALI (kullanıcı 08.10.2026: "banko oturumunu şu mockup gibi
 * modal yap ve bankolar dan seçilerek 'Oturum Aç' butonuyla girilsin").
 *
 * Bankolar listesinden açılır ve **akışın tamamını** taşır: açılış talebi,
 * onay bekleme, gün içi şerit, gün sonu sayımı (kupür, ödeme türü dökümü, POS
 * eşleşmesi, çek listesi) ve teslim. Önce "yalnız açılış modal, gerisi tam
 * sayfa" yapmıştım; görevliyi iki ayrı yere göndermek yerine tek yerde
 * tutmak istendi.
 *
 * AKIŞ EKRANI AYNI BİLEŞEN (`BankoOturumu` gömülü modda): modala ikinci bir
 * kopya yazmak, iki ayrı davranış demekti. Tam sayfa rota (`/banko-oturum`)
 * duruyor - adres çubuğundan açmak ve tutanak dönüşü oradan çalışıyor.
 *
 * Geniş ve kendi kaydırmasıyla: gün sonu panelinde dört tablo var, dar bir
 * modal hepsini daraltırdı.
 */
export function BankoOturumModali({ bankoId, onKapat }: {
  bankoId: number;
  onKapat(): void;
}) {
  // ESC ile kapanır: modal bir pencere gibi davranmalı.
  useEffect(() => {
    const t = (e: KeyboardEvent) => { if (e.key === 'Escape') onKapat() };
    window.addEventListener('keydown', t);
    return () => window.removeEventListener('keydown', t);
  }, [onKapat]);

  return (
    <div className="bom-ort" onClick={onKapat}>
      <div className="bom" onClick={e => e.stopPropagation()}>
        <style>{stil}</style>
        <div className="bom-bas">
          🏦 Banko Oturumu
          <button type="button" className="bom-kapat" onClick={onKapat} title="Kapat (Esc)">✖</button>
        </div>
        <div className="bom-govde">
          <BankoOturumu gomulu acilisBanko={bankoId} onKapat={onKapat} />
        </div>
      </div>
    </div>
  );
}

const stil = `
.bom-ort { position:fixed; inset:0; background:rgba(16,28,42,.45); z-index:900;
  display:flex; align-items:flex-start; justify-content:center; padding:32px 16px }
.bom { width:min(1080px,100%); max-height:calc(100vh - 64px); display:flex; flex-direction:column;
  background:var(--kart,#fff); border:1px solid var(--cizgi,#cdd6e0); border-radius:8px;
  box-shadow:0 18px 48px rgba(16,28,42,.28); overflow:hidden }
.bom-bas { background:linear-gradient(#2b5c95,#1c4374); color:#fff; padding:9px 12px;
  font-weight:bold; font-size:13.5px; display:flex; align-items:center; flex:none }
.bom-kapat { margin-left:auto; background:none; border:none; color:#fff; cursor:pointer; font-size:14px }
/* Kaydırma GÖVDEDE: başlık sabit kalsın, uzun gün sonu paneli altta kırpılmasın. */
.bom-govde { overflow-y:auto; padding:12px 14px 16px; flex:1 1 auto; min-height:0 }
`;

export default BankoOturumModali;
