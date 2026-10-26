import { useEffect, useLayoutEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { useOturum } from '../kimlik/OturumBaglami';
import { c } from '../dil/ceviri';

/**
 * CARİ AKSİYON MENÜSÜ (kullanıcı 26.10.2026: "delphi erp projesinde cari listede aksiyon butonu menüsü vardı.. bir
 * cariye belge seçme veya tahsilat veya açılış fişi girme gibi seçimler vardı.. ekstre ekranında devir/açılış butonu
 * kaldırıp Aksiyon butonu koy. müşteri/tedarikçi durumuna göre menüyü uyarla").
 *
 * Delphi karşılığı: UReharadlg AksiyonEkleTus / PopupMenuYeni - Alış Belgesi, Satış Belgesi, Açılış Fişi Gir,
 * Cari Tahsilat, Cari Ödeme, Cariler Arası Transfer, Tahsilat / Ödeme Planı. Delphi rol ayırmıyordu; burada
 * müşteriye satış + tahsilat, tedarikçiye alış + ödeme gelir; hem müşteri hem tedarikçiyse (ya da rolsüzse) hepsi,
 * menü o zaman daha geniş (4 sütun - kullanıcı 26.10.2026: "hem tedarikçi hem müş ise aksiyon menüsü daha geniş olsun").
 * Müşteri / tedarikçi listesi önizlemesinde ve cari kartında da aynı menü (Fatura / Sipariş / Tahsilat düğmeleri yerine).
 * Her seçim kendi sekmesinde, cari dolu (ve kilitli) açılır; Açılış Fişi ekranın kendi devir penceresidir.
 */
type Oge = { ad: string; yol?: string; tikla?: () => void; yetkili: boolean };

const belgeYolu = (rota: string, id: number, ad: string) =>
  `${rota}/yeni?${rota === '/belge' ? 'tur=15&' : ''}tarafId=${id}&tarafUnvan=${encodeURIComponent(ad)}`;
const kasaYolu = (tur: number, id: number, ad: string) =>
  `/kasa-islem/yeni?tur=${tur}&tarafId=${id}&tarafUnvan=${encodeURIComponent(ad)}`;

export function CariAksiyonMenusu({ id, ad, git, onAcilis }: {
  id: number; ad: string;
  /** Kart sekmesi yolu (ekranSekmesi.kartaGit ya da navigate). */
  git(yol: string): void;
  /** Açılış fişi / devir - verilmezse menüde yok. */
  onAcilis?: () => void;
}) {
  const { yetki } = useOturum();
  const [acik, setAcik] = useState(false);
  const [rol, setRol] = useState<{ musteri: boolean; tedarikci: boolean } | null>(null);
  useEffect(() => {
    let iptal = false;
    api.liste('cari', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: id } })
       .then(y => {
         const s = y.satirlar[0];
         if (!iptal && s) setRol({ musteri: Number(s.musteri) === 1, tedarikci: Number(s.tedarikci) === 1 });
       }, () => { /* rol okunamadı: hepsi gösterilir */ });
    return () => { iptal = true };
  }, [id]);
  useEffect(() => {
    if (!acik) return;
    const kapat = () => setAcik(false);
    window.addEventListener('click', kapat);
    return () => window.removeEventListener('click', kapat);
  }, [acik]);

  // Müşteri bayrağı satış + tahsilat, tedarikçi bayrağı alış + ödeme; ikisi de yoksa ya da okunamadıysa hepsi.
  const rolsuz = !rol || (!rol.musteri && !rol.tedarikci);
  const satis = rolsuz || !!rol?.musteri;
  const alis = rolsuz || !!rol?.tedarikci;
  const genis = satis && alis;
  // Menü ekrandan taşarsa (sağ panelde düğme sağ kenara yakın) sola kaydırılır.
  const liste = useRef<HTMLDivElement>(null);
  const [kayma, setKayma] = useState(0);
  useLayoutEffect(() => {
    if (!acik) { setKayma(0); return }
    const el = liste.current; if (!el) return;
    const r = el.getBoundingClientRect(), tasma = r.right - kayma - (window.innerWidth - 8);
    setKayma(tasma > 0 ? Math.min(tasma, r.left - kayma - 8) : 0);
  }, [acik, genis]);
  const belge = yetki('belge', 'ekle'), kasa = yetki('kasa_islem', 'ekle');

  const gruplar: [string, Oge[]][] = [];
  if (satis) {
    gruplar.push([c('Satış Belgesi'), [
      { ad: c('Satış Faturası'), yol: belgeYolu('/belge', id, ad), yetkili: belge },
      { ad: c('Satış Fişi'), yol: belgeYolu('/satis-fisi', id, ad), yetkili: belge },
      { ad: c('Satış İrsaliyesi'), yol: belgeYolu('/satis-irsaliye', id, ad), yetkili: belge },
      { ad: c('Satış Tahakkuku'), yol: belgeYolu('/tahakkuk', id, ad), yetkili: belge },
      { ad: c('Satış Siparişi'), yol: belgeYolu('/siparis', id, ad), yetkili: belge },
      { ad: c('Satış Teklifi'), yol: belgeYolu('/teklif', id, ad), yetkili: belge },
    ]]);
    gruplar.push([c('Cari Tahsilat'), [
      { ad: `💵 ${c('Nakit')}`, yol: kasaYolu(21, id, ad), yetkili: kasa },
      { ad: `🏦 ${c('Havale / EFT')}`, yol: kasaYolu(22, id, ad), yetkili: kasa },
      { ad: `📟 ${c('POS')}`, yol: kasaYolu(25, id, ad), yetkili: kasa },
      { ad: `🧾 ${c('Çek')}`, yol: kasaYolu(23, id, ad), yetkili: kasa },
      { ad: `📜 ${c('Senet')}`, yol: kasaYolu(24, id, ad), yetkili: kasa },
      { ad: `📅 ${c('Tahsilat Planı')}`, yol: kasaYolu(61, id, ad), yetkili: kasa },
    ]]);
  }
  if (alis) {
    gruplar.push([c('Alış Belgesi'), [
      { ad: c('Alış Faturası'), yol: belgeYolu('/alis-fatura', id, ad), yetkili: belge },
      { ad: c('Alış Fişi'), yol: belgeYolu('/alis-fisi', id, ad), yetkili: belge },
      { ad: c('Alış İrsaliyesi'), yol: belgeYolu('/alis-irsaliye', id, ad), yetkili: belge },
      { ad: c('Alış Tahakkuku'), yol: belgeYolu('/borc-tahakkuk', id, ad), yetkili: belge },
      { ad: c('Alış Siparişi'), yol: belgeYolu('/alis-siparis', id, ad), yetkili: belge },
    ]]);
    gruplar.push([c('Cari Ödeme'), [
      { ad: `💵 ${c('Nakit')}`, yol: kasaYolu(31, id, ad), yetkili: kasa },
      { ad: `🏦 ${c('Havale / EFT')}`, yol: kasaYolu(32, id, ad), yetkili: kasa },
      { ad: `💳 ${c('Kredi Kartı')}`, yol: kasaYolu(35, id, ad), yetkili: kasa },
      { ad: `🧾 ${c('Çek')}`, yol: kasaYolu(33, id, ad), yetkili: kasa },
      { ad: `📜 ${c('Senet')}`, yol: kasaYolu(34, id, ad), yetkili: kasa },
      { ad: `📅 ${c('Ödeme Planı')}`, yol: kasaYolu(71, id, ad), yetkili: kasa },
    ]]);
  }
  gruplar.push([c('Diğer'), [
    ...(onAcilis ? [{ ad: `↪️ ${c('Açılış Fişi / Devir')}`, tikla: onAcilis, yetkili: yetki('finans.devir', 'gor') }] : []),
    { ad: `🔁 ${c('Cariler Arası Transfer')}`, yol: kasaYolu(49, id, ad), yetkili: kasa },
  ]]);
  const gorunen = gruplar.map(([b, o]) => [b, o.filter(x => x.yetkili)] as [string, Oge[]]).filter(([, o]) => o.length);
  if (!gorunen.length) return null;

  return (
    <span className="dugme-menu cam">
      <style>{CAM_STILI}</style>
      <button type="button" className="d" aria-haspopup="menu" aria-expanded={acik}
              onClick={e => { e.stopPropagation(); setAcik(a => !a) }}>⚡ {c('Aksiyon')} ▾</button>
      {acik && (
        <div ref={liste} className={`dugme-menu-liste cam-liste${genis ? ' genis' : ''}`} role="menu"
             style={kayma ? { transform: `translateX(${-kayma}px)` } : undefined} onClick={e => e.stopPropagation()}>
          {gorunen.map(([baslik, ogeler]) => (
            <div key={baslik} className="cam-grup">
              <div className="cam-bas">{baslik}</div>
              {ogeler.map(o => (
                <button key={o.ad} type="button" className="mi" role="menuitem"
                        onClick={() => { setAcik(false); if (o.tikla) o.tikla(); else if (o.yol) git(o.yol) }}>{o.ad}</button>))}
            </div>))}
        </div>)}
    </span>
  );
}

const CAM_STILI = `
.cam .cam-liste { left: 0; right: auto; display: grid; grid-template-columns: repeat(2, minmax(150px, auto)); gap: 2px 10px;
  padding: 6px; max-height: 70vh; overflow: auto }
.cam .cam-liste.genis { grid-template-columns: repeat(4, minmax(140px, auto)) }
.cam .cam-grup { display: flex; flex-direction: column }
.cam .cam-liste .mi { white-space: nowrap }
.cam .cam-bas { font-size: 10.5px; font-weight: bold; color: var(--soluk, #6b7a8b); text-transform: uppercase; letter-spacing: .3px;
  padding: 6px 8px 3px; border-bottom: 1px solid var(--cizgi2, #e3e9f0); margin-bottom: 2px }
`;
