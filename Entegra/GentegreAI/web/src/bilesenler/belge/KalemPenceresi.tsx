import { useEffect, useRef, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { para } from '../bicim';
import {
  type SatirDurumu, satirTutari, adetKaydir, KDV_ORANLARI,
} from '../../sayfalar/belgeSatir';
import { IzlemPenceresi } from './IzlemPenceresi';

export function KalemPenceresi({ satir, irsaliyeMi, transferMi, vergisiz, yerelPara,
                         girisIzlemi, cikisIzlemi, cikisDepoId, belgeTarihi,
                         onKapat, onKaydet }: {
  satir: SatirDurumu;
  irsaliyeMi: boolean;
  /** Mal DEPOYA giriyor: izlemli stokta fiyattan sonra lot GIRIS ekrani acilir. */
  girisIzlemi: boolean;
  /** Mal DEPODAN cikiyor: izlemli stokta lot SECIM ekrani acilir. */
  cikisIzlemi: boolean;
  /** Cikis deposu - lot listesi bu depoya gore suzulur. */
  cikisDepoId: number | null;
  /** Genel Ayarlar'daki defter para birimi - "dovizli mi" karari buna gore. */
  yerelPara: string;
  /** Stok fisi: fiyat var (muhasebe matrahi) ama KDV/iskonto YOK - vergi dogurmaz. */
  vergisiz: boolean;
  /** Depo transferi: para yok - yalniz miktar, seri/lot ve aciklama sorulur. */
  transferMi: boolean;
  /** Kur bu tarihten okunur (belge tarihi) - bugunun kuru degil. */
  belgeTarihi: string;
  onKapat(): void;
  onKaydet(r: SatirDurumu): void;
}) {
  const [r, setR] = useState<SatirDurumu>(satir);
  const [hata, setHata] = useState<string | null>(null);
  /** Lot penceresi acik mi - miktar/fiyat girildikten SONRA acilir. */
  const [izlemAcik, setIzlemAcik] = useState(false);
  /** Kur kutusu kullanici tarafindan degistirildi mi - degistiyse ustune yazma. */
  const kurElle = useRef(false);

  const degis = (alan: keyof SatirDurumu, deger: string) =>
    setR(x => ({ ...x, [alan]: deger }));

  /** Enter = Tamam: adet/fiyat yazip Enter'a basinca satir gride eklenir. */
  const tus = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') { e.preventDefault(); kaydet() }
  };

  const dovizli = r.fiyatDovizi !== yerelPara && r.fiyatDovizi !== '';

  // Dovizli kalemde gunun kuru cekilir; kullanici kutuyu elle degistirdiyse
  //   dokunulmaz (kur pazarlikli olabiliyor - "istenirse degistirilebilsin").
  useEffect(() => {
    if (!dovizli || kurElle.current) return;
    void (async () => {
      try {
        const y = await api.dovizKur(r.fiyatDovizi, belgeTarihi);
        if (y.kur && y.kur > 0 && !kurElle.current) setR(x => ({ ...x, kur: String(y.kur) }));
      } catch { /* kur yoksa kullanici elle girer */ }
    })();
  }, [dovizli, r.fiyatDovizi, belgeTarihi]);

  const adet = Number(r.adet.replace(',', '.')) || 0;
  const kur = dovizli ? (Number(r.kur.replace(',', '.')) || 0) : 1;
  const dovizFiyat = Number(r.dovizFiyat.replace(',', '.')) || 0;
  // Yerel birim fiyat: dovizli kalemde doviz fiyati x kur, degilse dogrudan girilen.
  const fiyat = dovizli
    ? Math.round(dovizFiyat * kur * 100) / 100
    : (Number(r.birimFiyat.replace(',', '.')) || 0);
  const tutar = satirTutari(adet, fiyat, r.iskonto, r.iskonto2);

  /** Izlemli stokta lot adimi: giriste DAGITIM, cikista SECIM (db/114). */
  const izlemGerekli = (girisIzlemi || cikisIzlemi) && r.satirTur === 1 && r.izleme > 0;

  function kaydet() {
    if (!r.stokId && !r.hizmetId) { setHata('Stok ya da hizmet seçilmeli.'); return }
    if (adet <= 0) { setHata('Miktar sıfırdan büyük olmalı.'); return }
    if (dovizli && kur <= 0) { setHata('Kur sıfırdan büyük olmalı.'); return }
    // Izlemli stokta once LOT dagitimi: miktar ve fiyat girildikten sonra lot
    //   ekrani acilir, kalem ancak dagitim tamamlaninca gride eklenir.
    if (izlemGerekli) { setHata(null); setIzlemAcik(true); return }
    // Belgeye YEREL fiyat gider; doviz/kur bilgisi satirda saklanir ki kalem
    //   tekrar acildiginda ayni degerlerle gelsin.
    onKaydet({ ...r, birimFiyat: String(fiyat) });
  }

  return (
    <Modal
      baslik={r.stokAdi || 'Kalem'}
      dar
      onKapat={onKapat}
      alt={
        <>
          <button className="d onay" onClick={kaydet}>💾 Tamam (Enter)</button>
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>
        </>
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {/* Cerceve kalir, BASLIK yok: pencere basligi zaten stok/hizmet adi. */}
        <div className="kagrup">
          {/* Alanlar ALT ALTA ve giris sirasinda: Miktar > Birim Fiyat > KDV >
              Iskonto. Stok/hizmet adi PENCERE BASLIGINDA yaziyor - burada
              tekrarlamak yer kaplamaktan baska ise yaramiyordu. */}
          <div className="alan-izgara tek-sutun">
            <label className="alan">
              <span className="etiket">Miktar</span>
              <span className="ikili">
                {/* Eksi isareti elle de yazilamaz. Yukari/asagi ok = +1 / -1. */}
                <input autoFocus className="hiza-sag" value={r.adet}
                       onKeyDown={e => {
                         if (e.key === 'ArrowUp') { e.preventDefault(); degis('adet', adetKaydir(r.adet, +1)) }
                         else if (e.key === 'ArrowDown') { e.preventDefault(); degis('adet', adetKaydir(r.adet, -1)) }
                         else tus(e);
                       }}
                       onChange={e => degis('adet', e.target.value.replace(/-/g, ''))} />
                {/* Fare ile hizli artir/azalt - klavyeden yazmak da serbest. */}
                <button type="button" className="mini" title="Azalt"
                        onClick={() => degis('adet', adetKaydir(r.adet, -1))}>−</button>
                <button type="button" className="mini" title="Artır"
                        onClick={() => degis('adet', adetKaydir(r.adet, +1))}>+</button>
              </span>
            </label>

            {/* Birim fiyat KARTIN para biriminde girilir (stok arama ekraninda
                gorulen fiyat/doviz). Yerel para disindaysa yaninda gunun kuru
                (elle degistirilebilir) ve ALTINDA yerel karsilik satiri cikar.
                TRANSFERDE hic sorulmaz: mal satilmiyor, depo degistiriyor. */}
            {!transferMi && (
            <label className="alan">
              <span className="etiket">Birim Fiyat</span>
              <span className="ikili">
                <input className="hiza-sag"
                       value={dovizli ? r.dovizFiyat : r.birimFiyat} onKeyDown={tus}
                       onChange={e => degis(dovizli ? 'dovizFiyat' : 'birimFiyat', e.target.value)} />
                <input className="birim" value={r.fiyatDovizi || yerelPara} readOnly tabIndex={-1} />
                {dovizli && (
                  <input className="hiza-sag kur" value={r.kur} onKeyDown={tus}
                         title="Günlük kur — değiştirilebilir"
                         onChange={e => { kurElle.current = true; degis('kur', e.target.value) }} />
                )}
              </span>
            </label>
            )}

            {!transferMi && dovizli && (
              <label className="alan">
                <span className="etiket">Yerel Para</span>
                <span className="ikili">
                  <input className="hiza-sag onizleme" value={para.format(fiyat)} readOnly />
                  <input className="birim" value={yerelPara} readOnly tabIndex={-1} />
                </span>
              </label>
            )}

            {/* Iskonto ve KDV HER TURDE girilir - irsaliyede de matrah/KDV
                hesaplanir (dip toplam ondan cikar), yalniz gridde gosterilmez. */}
            {!transferMi && !vergisiz && (
            <label className="alan">
              <span className="etiket">KDV %</span>
              <select value={r.kdv} onKeyDown={tus}
                      onChange={e => degis('kdv', e.target.value)}>
                {/* Stok kartindan gelen oran listede yoksa kaybolmasin. */}
                {(KDV_ORANLARI as readonly number[]).includes(Number(r.kdv))
                  ? null : <option value={r.kdv}>%{r.kdv}</option>}
                {KDV_ORANLARI.map(o => <option key={o} value={o}>%{o}</option>)}
              </select>
            </label>
            )}

            {/* Iki kademeli iskonto: ikincisi birincinin ARDINDAN carpimsal
                uygulanir (sunucudaki BelgeHesap.SatirTutari ile ayni sira). */}
            {!transferMi && !vergisiz && (
            <label className="alan">
              <span className="etiket">İskonto %</span>
              <span className="ikili">
                <input className="hiza-sag" value={r.iskonto} onKeyDown={tus}
                       title="1. iskonto"
                       onChange={e => degis('iskonto', e.target.value)} />
                <input className="hiza-sag" value={r.iskonto2} onKeyDown={tus}
                       title="2. iskonto (birincinin ardindan uygulanir)"
                       onChange={e => degis('iskonto2', e.target.value)} />
              </span>
            </label>
            )}

            {/* Duz metin "Seri / Lot": yalniz IZLEMSIZ stokta. Izlemli stokta
                dagitim lot ekraninda yapilir - iki ayri yerde lot tutmak
                birbirini tutmayan iki kayit uretirdi. */}
            {(irsaliyeMi || transferMi) && !izlemGerekli && (
              <label className="alan">
                <span className="etiket">Seri / Lot</span>
                <input value={r.izlemeKodu} placeholder="LOT / seri" onKeyDown={tus}
                       onChange={e => degis('izlemeKodu', e.target.value)} />
              </label>
            )}

            <label className="alan">
              <span className="etiket">Açıklama</span>
              <input value={r.aciklama} onKeyDown={tus} placeholder="Satır açıklaması"
                     onChange={e => degis('aciklama', e.target.value)} />
            </label>

            {!transferMi && (
            <label className="alan">
              <span className="etiket">Tutar (önizleme)</span>
              <input className="hiza-sag onizleme" value={para.format(tutar)} readOnly />
            </label>
            )}

            {/* Izlemli stokta girilmis lotlarin ozeti - kalem penceresine
                donuldugunde dagitimin yapildigi gorunsun. */}
            {izlemGerekli && r.izlemler.length > 0 && (
              <label className="alan">
                <span className="etiket">Lot / Seri</span>
                <input className="onizleme" readOnly
                       value={r.izlemler.map(z => `${z.lotNo || z.seriNo} (${z.miktar})`).join(', ')}
                       onClick={() => setIzlemAcik(true)}
                       title="Değiştirmek için tıklayın" />
              </label>
            )}
          </div>
        </div>

        {izlemAcik && (
          <IzlemPenceresi
            stokAdi={r.stokAdi}
            stokId={r.stokId}
            depoId={cikisDepoId}
            cikis={cikisIzlemi}
            izleme={r.izleme}
            miktar={adet}
            satirlar={r.izlemler}
            onKapat={() => setIzlemAcik(false)}
            onKaydet={izlemler => {
              setIzlemAcik(false);
              onKaydet({ ...r, birimFiyat: String(fiyat), izlemler });
            }}
          />
        )}
      </>
    </Modal>
  );
}
