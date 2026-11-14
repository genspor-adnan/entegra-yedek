import { useEffect, useMemo, useRef, useState } from 'react';
import { c } from '../../dil/ceviri';
import { Modal } from '../../bilesenler/Modal';
import { hataMetni } from '../../api/sozlesme';

/**
 * ŞABLON SEÇ MODALI (kullanıcı 14.11.2026: "otomatik şablon gelmiş ama uygun değil.. rapor kısmı boş gelsin.. sağ
 * taraftan şablon seçimi combo yerine modal ile olsun"; mockup Ekranlar/Radyoloji/radyoloji_rapor_sablon_secimi.html).
 *
 * Sağ paneldeki combonun yerine geçer: arama (ad / kod), kapsam çipleri (Bu tetkike bağlı · Benim · Genel · Hepsi),
 * biçim çipleri (Tek · Parçalı · Yapısal), "yalnız bu modalite", solda gruplu liste, sağda ÖNİZLEME (bölüm başlıkları +
 * varsayılan metin, onizlemeGetir ile tembel yüklenir, önbellekli). Altta "bu tetkik için varsayılanım yap": bir sonraki
 * raporda listede en üstte "önerilen" rozetiyle gelir, yine otomatik UYGULANMAZ. Yıldız = kişisel favori.
 * Varsayılan / favori / son kullanılan tarayıcı deposunda (hekimin bilgisayarı; sunucuya taşınırsa anahtarlar aynı).
 */
export interface SecilebilirSablon {
  id: number; kod: string; ad: string; surum: number; tetkigeOzel: number;
  modalite?: number; yapisalTur?: number; kapsam?: number; bolumSayisi?: number;
  /** 1343: şablon kartındaki biçim (1 tek, 2 parçalı) ve giriş (1 serbest, 2 yapısal). */
  bicim?: number; giris?: number;
}
export interface OnizlemeBolumu { baslik: string; metin: string }

const DEPO_VARSAYILAN = (hizmetId: number) => `gentegre.rad.sablonVarsayilan.${hizmetId}`;
const DEPO_SON = (hizmetId: number) => `gentegre.rad.sablonSon.${hizmetId}`;
const DEPO_FAVORI = 'gentegre.rad.sablonFavori';

function depoOku(anahtar: string): string | null { try { return localStorage.getItem(anahtar) } catch { return null } }
function depoYaz(anahtar: string, deger: string | null) {
  try { if (deger === null) localStorage.removeItem(anahtar); else localStorage.setItem(anahtar, deger) } catch { /* özel pencere */ }
}
export const sablonTercihi = {
  varsayilan: (hizmetId: number) => Number(depoOku(DEPO_VARSAYILAN(hizmetId)) ?? 0) || null,
  sonKullanilan: (hizmetId: number) => Number(depoOku(DEPO_SON(hizmetId)) ?? 0) || null,
  sonKullanilanYaz: (hizmetId: number, sablonId: number) => { if (hizmetId > 0) depoYaz(DEPO_SON(hizmetId), String(sablonId)) },
  favoriler: (): Set<number> => new Set((depoOku(DEPO_FAVORI) ?? '').split(',').map(Number).filter(Boolean)),
};

type Kapsam = 'tetkik' | 'benim' | 'genel' | 'hepsi';
type Bicim = 'hepsi' | 'tek' | 'parcali' | 'yapisal';

export function SablonSecModal({ sablonlar, seciliId, hizmetId, modalite, raporDolu, onizlemeGetir, onUygula, onBos, onKapat }: {
  sablonlar: SecilebilirSablon[];
  seciliId: number | null;
  hizmetId: number;
  /** İstemin modalite kodu (rad.modalite); 0 = bilinmiyor, modalite çipi gizlenir. */
  modalite: number;
  /** Raporda yazılmış metin var: uygulamada onay sorulacağı bilgisi (uyarı satırı). */
  raporDolu: boolean;
  onizlemeGetir(sablonId: number): Promise<OnizlemeBolumu[]>;
  onUygula(sablonId: number): Promise<void> | void;
  onBos(): void;
  onKapat(): void;
}) {
  const varsayilanId = useMemo(() => sablonTercihi.varsayilan(hizmetId), [hizmetId]);
  const sonId = useMemo(() => sablonTercihi.sonKullanilan(hizmetId), [hizmetId]);
  const [favoriler, setFavoriler] = useState<Set<number>>(() => sablonTercihi.favoriler());
  const [arama, setArama] = useState('');
  const [kapsam, setKapsam] = useState<Kapsam>(() => (sablonlar.some(s => s.tetkigeOzel === 1) ? 'tetkik' : 'hepsi'));
  const [bicim, setBicim] = useState<Bicim>('hepsi');
  const [yalnizModalite, setYalnizModalite] = useState(modalite > 0);
  const [secili, setSecili] = useState<number | null>(seciliId ?? varsayilanId ?? sonId ?? null);
  const [varsayilanYap, setVarsayilanYap] = useState(false);
  const [onizleme, setOnizleme] = useState<OnizlemeBolumu[] | null>(null);
  const [onizlemeHata, setOnizlemeHata] = useState('');
  const [uygulaniyor, setUygulaniyor] = useState(false);
  const onbellek = useRef(new Map<number, OnizlemeBolumu[]>());
  const aramaRef = useRef<HTMLInputElement>(null);

  // Biçim / giriş şablon kartındaki ayardan (1343); eski kayıt için bölüm sayısı / form yedeği.
  const bicimi = (s: SecilebilirSablon): Bicim =>
    (s.giris != null ? Number(s.giris) === 2 : Number(s.yapisalTur ?? 0) > 0) ? 'yapisal'
      : (s.bicim != null ? Number(s.bicim) === 2 : Number(s.bolumSayisi ?? 0) > 1) ? 'parcali' : 'tek';
  const bicimAdi = (b: Bicim) => b === 'yapisal' ? c('Yapısal') : b === 'parcali' ? c('Parçalı') : c('Tek A4');

  const suzulmus = useMemo(() => {
    const q = arama.trim().toLocaleLowerCase('tr');
    return sablonlar.filter(s =>
      (kapsam === 'hepsi' || (kapsam === 'tetkik' ? s.tetkigeOzel === 1
        : kapsam === 'benim' ? s.tetkigeOzel !== 1 && s.kapsam === 1
        : s.tetkigeOzel !== 1 && s.kapsam !== 1))
      && (bicim === 'hepsi' || bicimi(s) === bicim)
      && (!yalnizModalite || !modalite || !s.modalite || Number(s.modalite) === modalite)
      && (!q || s.ad.toLocaleLowerCase('tr').includes(q) || (s.kod ?? '').toLocaleLowerCase('tr').includes(q)));
  }, [sablonlar, arama, kapsam, bicim, yalnizModalite, modalite]);

  // Gruplar: bu tetkike bağlı · benim · genel; her grup içinde önerilen (varsayılan) ve favoriler önde.
  const gruplar = useMemo(() => {
    const sira = (s: SecilebilirSablon) => (s.id === varsayilanId ? 0 : favoriler.has(s.id) ? 1 : s.id === sonId ? 2 : 3);
    const sirala = (l: SecilebilirSablon[]) => [...l].sort((a, b) => sira(a) - sira(b) || a.ad.localeCompare(b.ad, 'tr'));
    return [
      { ad: '⭐ ' + c('Bu tetkike bağlı'), liste: sirala(suzulmus.filter(s => s.tetkigeOzel === 1)) },
      { ad: '★ ' + c('Benim şablonlarım'), liste: sirala(suzulmus.filter(s => s.tetkigeOzel !== 1 && s.kapsam === 1)) },
      { ad: c('Genel'), liste: sirala(suzulmus.filter(s => s.tetkigeOzel !== 1 && s.kapsam !== 1)) },
    ].filter(g => g.liste.length > 0);
  }, [suzulmus, varsayilanId, favoriler, sonId]);
  const duz = useMemo(() => gruplar.flatMap(g => g.liste), [gruplar]);

  // Seçili satır listede yoksa ilk satır.
  useEffect(() => { if (duz.length && !duz.some(s => s.id === secili)) setSecili(duz[0].id) }, [duz, secili]);

  // Önizleme tembel + önbellekli.
  useEffect(() => {
    if (!secili) { setOnizleme(null); return }
    const h = onbellek.current.get(secili);
    if (h) { setOnizleme(h); setOnizlemeHata(''); return }
    let iptal = false;
    setOnizleme(null); setOnizlemeHata('');
    onizlemeGetir(secili).then(b => { if (!iptal) { onbellek.current.set(secili, b); setOnizleme(b) } })
      .catch(e => { if (!iptal) setOnizlemeHata(hataMetni(e)) });
    return () => { iptal = true };
  }, [secili, onizlemeGetir]);

  useEffect(() => { aramaRef.current?.focus() }, []);

  const favoriDegistir = (id: number) => {
    const y = new Set(favoriler); if (y.has(id)) y.delete(id); else y.add(id);
    setFavoriler(y); depoYaz(DEPO_FAVORI, [...y].join(','));
  };
  const uygula = async () => {
    if (!secili || uygulaniyor) return;
    setUygulaniyor(true);
    try {
      if (hizmetId > 0) depoYaz(DEPO_VARSAYILAN(hizmetId), varsayilanYap ? String(secili) : (varsayilanId === secili ? null : depoOku(DEPO_VARSAYILAN(hizmetId))));
      await onUygula(secili);
    } finally { setUygulaniyor(false) }
  };
  const tusla = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      const i = duz.findIndex(s => s.id === secili);
      const y = duz[Math.min(duz.length - 1, Math.max(0, i + (e.key === 'ArrowDown' ? 1 : -1)))];
      if (y) setSecili(y.id);
    } else if (e.key === 'Enter' && (e.target as HTMLElement).tagName !== 'BUTTON') { e.preventDefault(); void uygula() }
    else if (e.key === '/' && (e.target as HTMLElement).tagName !== 'INPUT') { e.preventDefault(); aramaRef.current?.focus() }
  };

  const seciliSablon = duz.find(s => s.id === secili) ?? sablonlar.find(s => s.id === secili);
  const cip = (on: boolean, ad: string, tikla: () => void, sayi?: number) => (
    <button type="button" className={`ssm-cip${on ? ' on' : ''}`} onClick={tikla}>{ad}{sayi !== undefined && <i>{sayi}</i>}</button>);
  const kapsamSayisi = (k: Kapsam) => sablonlar.filter(s => k === 'hepsi' || (k === 'tetkik' ? s.tetkigeOzel === 1
    : k === 'benim' ? s.tetkigeOzel !== 1 && s.kapsam === 1 : s.tetkigeOzel !== 1 && s.kapsam !== 1)).length;

  return (
    <Modal baslik={c('Şablon Seç')} ekSinif="ssm-modal" onKapat={onKapat}
           alt={<>
             <label className="ssm-varsayilan">
               <input type="checkbox" checked={varsayilanYap} onChange={e => setVarsayilanYap(e.target.checked)} disabled={!secili || hizmetId <= 0} />
               {c('Bu tetkik için varsayılanım yap')} <span className="sonuk kucuk">({c('bir dahaki raporda önerilir, otomatik uygulanmaz')})</span>
             </label>
             <span className="ck-bosluk" />
             <button type="button" className="d" onClick={onBos} title={c('Şablonsuz serbest yazım')}>◻ {c('Boş rapor')}</button>
             <button type="button" className="d bir" disabled={!secili || uygulaniyor} onClick={() => void uygula()}>
               {uygulaniyor ? '⏳' : '✔'} {c('Uygula')}</button>
             <button type="button" className="d" onClick={onKapat}>✖ {c('Kapat')}</button>
           </>}>
      <div className="ssm" onKeyDown={tusla}>
        <div className="ssm-serit">
          <input ref={aramaRef} className="ssm-ara" value={arama} placeholder={c('Şablon adı ya da kodu…')}
                 onChange={e => setArama(e.target.value)} />
          <span className="ssm-ayrac" />
          {cip(kapsam === 'tetkik', '⭐ ' + c('Bu tetkike bağlı'), () => setKapsam('tetkik'), kapsamSayisi('tetkik'))}
          {cip(kapsam === 'benim', '★ ' + c('Benim şablonlarım'), () => setKapsam('benim'), kapsamSayisi('benim'))}
          {cip(kapsam === 'genel', c('Genel'), () => setKapsam('genel'), kapsamSayisi('genel'))}
          {cip(kapsam === 'hepsi', c('Hepsi'), () => setKapsam('hepsi'), sablonlar.length)}
          <span className="ssm-ayrac" />
          {cip(bicim === 'hepsi', c('Tüm biçimler'), () => setBicim('hepsi'))}
          {cip(bicim === 'tek', c('Tek'), () => setBicim('tek'))}
          {cip(bicim === 'parcali', c('Parçalı'), () => setBicim('parcali'))}
          {cip(bicim === 'yapisal', c('Yapısal'), () => setBicim('yapisal'))}
          {modalite > 0 && <><span className="ssm-ayrac" />{cip(yalnizModalite, c('Yalnız bu modalite'), () => setYalnizModalite(v => !v))}</>}
        </div>
        {raporDolu && <div className="ssm-uyari">⚠ {c('Raporda yazılmış metin var: şablon uygulanırken bölüm metinleri şablonun varsayılanıyla değişir (onay sorulur).')}</div>}
        <div className="ssm-icerik">
          <div className="ssm-liste" role="listbox" aria-activedescendant={secili ? `ssm-${secili}` : undefined}>
            {duz.length === 0 && <div className="sonuk kucuk ssm-bos">{c('Eşleşen şablon yok.')}</div>}
            {gruplar.map(g => (
              <div key={g.ad}>
                <h6>{g.ad} · {g.liste.length}</h6>
                {g.liste.map(s => (
                  <div key={s.id} id={`ssm-${s.id}`} role="option" aria-selected={s.id === secili}
                       className={`ssm-o${s.id === secili ? ' on' : ''}`}
                       onClick={() => setSecili(s.id)} onDoubleClick={() => { setSecili(s.id); void uygula() }}>
                    <button type="button" className={`ssm-yildiz${favoriler.has(s.id) ? ' on' : ''}`} title={c('Favori')}
                            onClick={e => { e.stopPropagation(); favoriDegistir(s.id) }}>{favoriler.has(s.id) ? '★' : '☆'}</button>
                    <span className="ssm-ad">
                      <b>{s.ad}</b> <span className={`ssm-rozet ${bicimi(s)}`}>{bicimAdi(bicimi(s))}</span>
                      {s.id === varsayilanId && <span className="ssm-rozet oneri">{c('önerilen')}</span>}
                      {s.id === sonId && s.id !== varsayilanId && <span className="ssm-rozet son">{c('son kullanılan')}</span>}
                      <small>{s.kod || '—'}{s.kapsam === 1 ? ` · ${c('kişisel')}` : ` · ${c('genel')}`}{Number(s.bolumSayisi ?? 0) > 1 ? ` · ${s.bolumSayisi} ${c('bölüm')}` : ''}</small>
                    </span>
                    <span className="ssm-sag">v{s.surum}</span>
                  </div>))}
              </div>))}
          </div>
          <div className="ssm-oniz">
            <h6>{c('Önizleme')}{seciliSablon && <span className="sonuk">{seciliSablon.kod ? `${seciliSablon.kod} · ` : ''}v{seciliSablon.surum}</span>}</h6>
            {!secili && <div className="sonuk kucuk">{c('Soldan bir şablon seçin.')}</div>}
            {secili && onizlemeHata && <div className="hata-kutusu">{onizlemeHata}</div>}
            {secili && !onizleme && !onizlemeHata && <div className="sonuk kucuk">{c('Yükleniyor…')}</div>}
            {onizleme && (
              <div className="ssm-a4">
                {onizleme.length === 0 && <div className="sonuk">{c('Şablonun bölümü yok (boş A4).')}</div>}
                {onizleme.map((b, i) => (
                  <div key={i}>
                    {b.baslik && <div className="ssm-bb">{b.baslik.toLocaleUpperCase('tr')}:</div>}
                    <div className="ssm-bm">{b.metin || <span className="sonuk">—</span>}</div>
                  </div>))}
              </div>
            )}
          </div>
        </div>
      </div>
    </Modal>
  );
}
