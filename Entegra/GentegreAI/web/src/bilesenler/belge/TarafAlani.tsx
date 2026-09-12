/**
 * TarafArama ile doldurulan baslik alani (cari, satis temsilcisi...).
 *
 * GenLookup DEGIL: secim her yerde AYNI arama ekranindan yapilsin diye alan
 * kendisi salt okunur, tiklayinca (ya da "…" dugmesiyle) modali cagirir.
 */
export function TarafAlani({ etiket, deger, kilitli, ipucu, zorunlu, hata, onAc }: {
  etiket: string;
  deger?: string;
  kilitli: boolean;
  ipucu: string;
  zorunlu?: boolean;
  hata?: string;
  onAc(): void;
}) {
  return (
    <label className="alan">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <span className="lookup-kutu">
        <input readOnly value={deger ?? ''} placeholder="Seçiniz…" disabled={kilitli}
               onMouseDown={e => { if (!kilitli) { e.preventDefault(); onAc() } }} />
        {!kilitli && (
          <button type="button" className="mini" title={ipucu} onClick={onAc}>…</button>
        )}
      </span>
      {hata && <span className="alan-hata">{hata}</span>}
    </label>
  );
}

/**
 * Belge kesme ekrani (satis faturasi, siparis, irsaliye…).
 *
 * TUR URL'DEN GELIR (?tur=19). Ekran eskiden 15'e (satis faturasi) SABITTI;
 * Siparisler listesinden "Yeni" denince yine fatura ekrani aciliyordu.
 *
 * Ekran MODAL acilir (diger kartlarla ayni desen): liste arkada kalir.
 *
 * TUTAR HESABI SUNUCUDA. Ekranda gosterilen satir tutari yalnizca ONIZLEMEDIR;
 * kaydedilen degerler her zaman sunucudan donen belgeden okunur. Delphi ile kurusu
 * kurusuna ayni olmasi gereken formul (ic yuvarlama + carpimsal iskonto + banker's)
 * tek yerde, sunucuda durur — istemciye kopyalanirsa iki formul birbirinden kayar.
 */
