import { c } from '../../dil/ceviri';
import {
  KATEGORILER, KOMPOZISYON, SOZLUK, SOZLUK_ETIKET, YONETIM, genelOneri, lezyonKategorisi, modaliteAlanlari,
  sonKategori, yeniLezyon, type BiradsDurumu, type BiradsModalite, type Kategori, type Lezyon,
} from './birads';

/**
 * BI-RADS FORMU (1194, mockup Ekranlar/Radyoloji/radyoloji_birads_v2.html). İki yerde kullanılır:
 *  - Giriş = Yapısal: ortada GENİŞ form (lezyonlar yan yana) - BULGULAR + SONUÇ bundan üretilir.
 *  - Giriş = Serbest: sağda YARDIMCI panel - "Rapora aktar" ile metne dökülür.
 * Kategori önerisi kural motorundan (birads.ts); son kategori radyoloğun, farklıysa gerekçe zorunlu.
 */
export function BiradsFormu({ durum, setDurum, modalite, genis, kilitli, onAktar }: {
  durum: BiradsDurumu;
  setDurum(d: BiradsDurumu): void;
  modalite: BiradsModalite;
  genis: boolean;
  kilitli: boolean;
  /** Yalnız serbest girişte: formu BULGULAR / SONUÇ'a yaz. */
  onAktar?(): void;
}) {
  const oneri = genelOneri(durum, modalite);
  const son = sonKategori(durum, modalite);
  const alanlar = modaliteAlanlari(modalite);
  const lezYaz = (i: number, x: Partial<Lezyon>) =>
    setDurum({ ...durum, sonElle: null, lezyonlar: durum.lezyonlar.map((l, k) => (k === i ? { ...l, ...x } : l)) });

  return (
    <div className={`brf${genis ? ' genis' : ''}`}>
      <div className="brf-bas">
        <b>BI-RADS · {genis ? c('yapısal form') : c('yardımcı panel')}</b>
        <span className="sonuk kucuk">{modalite === 'mg' ? 'Mamografi' : modalite === 'mr' ? 'Meme MR' : 'Meme US'}</span>
      </div>
      <div className="brf-ic">
        <label className="brf-satir"><span>{modalite === 'mg' ? c('Meme kompozisyonu') : modalite === 'mr' ? c('FGT miktarı') : c('Doku kompozisyonu')}</span>
          <select value={durum.kompozisyon} disabled={kilitli} onChange={e => setDurum({ ...durum, kompozisyon: e.target.value })}>
            {KOMPOZISYON[modalite].map(x => <option key={x}>{x}</option>)}
          </select></label>

        <div className={`brf-lezler${genis ? ' genis' : ''}`}>
          {durum.lezyonlar.map((l, i) => (
            <div className="brf-lez" key={i}>
              <div className="brf-lez-bas">
                <b>{c('Lezyon')} {i + 1}</b> <span>{l.taraf} {l.saat}{l.boyut ? ` · ${l.boyut}` : ''}</span>
                <span className={`brf-k k${lezyonKategorisi(l, modalite).kategori[0]}`}>BI-RADS {lezyonKategorisi(l, modalite).kategori}</span>
                {!kilitli && <button type="button" className="brf-sil" title={c('Lezyonu sil')}
                  onClick={() => setDurum({ ...durum, sonElle: null, lezyonlar: durum.lezyonlar.filter((_, k) => k !== i) })}>✕</button>}
              </div>
              <div className="brf-lez-ic">
                <div className="brf-ilk4">
                  <label>{c('Taraf')}<select value={l.taraf} disabled={kilitli} onChange={e => lezYaz(i, { taraf: e.target.value })}>
                    <option>Sağ</option><option>Sol</option></select></label>
                  <label>{c('Saat')}<input value={l.saat} readOnly={kilitli} placeholder="10:00" onChange={e => lezYaz(i, { saat: e.target.value })} /></label>
                  <label>{c('Meme başına')}<input value={l.uzaklik} readOnly={kilitli} placeholder="3 cm" onChange={e => lezYaz(i, { uzaklik: e.target.value })} /></label>
                  <label>{c('Boyut')}<input value={l.boyut} readOnly={kilitli} placeholder="14×9 mm" onChange={e => lezYaz(i, { boyut: e.target.value })} /></label>
                </div>
                <div className={`brf-soz${genis ? ' genis' : ''}`}>
                  {alanlar.map(a => (
                    <label className={`brf-satir${genis ? ' dar' : ''}`} key={a}><span>{SOZLUK_ETIKET[a]}</span>
                      <select value={l[a]} disabled={kilitli} onChange={e => lezYaz(i, { [a]: e.target.value })}>
                        {SOZLUK[a].map(x => <option key={x}>{x}</option>)}
                      </select></label>
                  ))}
                </div>
                <label className="brf-onay"><input type="checkbox" checked={l.buyume} disabled={kilitli}
                  onChange={e => lezYaz(i, { buyume: e.target.checked })} /> {c('önceki tetkike göre büyüme')}</label>
              </div>
            </div>
          ))}
        </div>
        {!kilitli && (
          <div className="brf-dugmeler">
            <button type="button" className="d mini"
                    onClick={() => setDurum({ ...durum, sonElle: null, lezyonlar: [...durum.lezyonlar, yeniLezyon(modalite)] })}>＋ {c('Lezyon ekle')}</button>
            {durum.lezyonlar.length > 0 && (
              <button type="button" className="d mini" onClick={() => setDurum({ ...durum, sonElle: null, lezyonlar: [] })}>
                {c('Lezyon yok (BI-RADS 1)')}</button>
            )}
          </div>
        )}

        <div className={`brf-altlar${genis ? ' genis' : ''}`}>
          <div className="brf-oneri">
            <div>{c('Önerilen')}: <span className={`brf-k k${oneri.kategori[0]}`}>BI-RADS {oneri.kategori}</span></div>
            <div className="brf-neden">{oneri.nedenler.map((x, i) => <span key={i}>{x}</span>)}</div>
          </div>
          <div className="brf-karar">
            <label className="brf-satir"><span><b>{c('Son kategori')}</b></span>
              <select value={son} disabled={kilitli}
                      onChange={e => setDurum({ ...durum, sonElle: e.target.value === oneri.kategori ? null : e.target.value as Kategori })}>
                {KATEGORILER.map(k => <option key={k} value={k}>BI-RADS {k}</option>)}
              </select></label>
            {son !== oneri.kategori && (
              <div className="brf-uyari">{c('Öneriden farklı - gerekçe zorunlu')}:
                <input value={durum.gerekce} readOnly={kilitli} placeholder={c('ör. önceki tetkikle stabil')}
                       onChange={e => setDurum({ ...durum, gerekce: e.target.value })} /></div>
            )}
            <div className="brf-yonetim">{YONETIM[son]}</div>
          </div>
        </div>
        {onAktar && !kilitli && (
          <div className="brf-dugmeler">
            <button type="button" className="d bir" onClick={onAktar}>⤵ {c('Rapora aktar')}</button>
            <span className="sonuk kucuk">{c('Bulgular ve Sonuç formdan yeniden yazılır')}</span>
          </div>
        )}
      </div>
    </div>
  );
}
