import { useEffect, useRef, useState } from 'react';
import { Modal } from './Modal';
import { mesajDinleyiciAta, type MesajIstegi, type ParaSecimi } from './mesaj';
import { para as paraBicim, tutarOku } from './bicim';
import { urunAdi } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';

/**
 * "Gentegre AI Mesajı" penceresi - uygulamanin TEK mesaj/onay ekrani.
 *
 * App'in koküne bir kez konur; `mesaj()` ve `onay()` cagrilari buraya duser.
 * Tarayicinin alert/confirm kutulari sayfayi kilitliyor ve "localhost diyor ki"
 * basligiyla cikiyordu.
 *
 * Kuyruk YOK: ust uste gelen mesajda son istek gosterilir - kullanici arka
 * arkaya diyalog kapatmak zorunda kalmasin.
 */
export function MesajKatmani() {
  /** Girdi kutusu - "×" temizledikten sonra imlec icinde kalsin. */
  const girdiKutusu = useRef<HTMLInputElement | null>(null);
  const { kullanici } = useOturum();
  const [istek, setIstek] = useState<MesajIstegi | null>(null);
  const [girdi, setGirdi] = useState('');
  /* PARA ISTEGI alanlari - tutar, birim, kur, neden ve para ustu. */
  const [pDoviz, setPDoviz] = useState('TL');
  const [pKur, setPKur] = useState('1');
  const [pNeden, setPNeden] = useState('');
  const [pHata, setPHata] = useState('');

  useEffect(() => {
    mesajDinleyiciAta(setIstek);
    return () => mesajDinleyiciAta(null);
  }, []);

  /**
   * KUTU VARSAYILANLA DOLU BASLAR (kullanici: POS/dönüşüm tutarı soruldugunda
   * "50.000,00" yaziyordu ama Enter'a basinca "Tutar sıfırdan büyük olmalı"
   * diyordu). Kutuda GORUNEN deger `girdi || girdiVarsayilan` idi: kullanici
   * uzerine yazmadikca state BOS kaliyor ve cagirana bos metin donuyordu.
   * Varsayilan artik state'e yazilir - gorunen ile donen ayni degerdir.
   */
  useEffect(() => {
    setGirdi(istek?.girdiMi ? (istek.girdiVarsayilan ?? '') : '');
    if (istek?.paraMi) {
      const p = istek.para ?? {};
      const yerel = p.yerelPara || 'TL';
      setGirdi(p.varsayilan ?? '');
      setPDoviz(p.doviz || yerel);
      setPKur('1');
      setPNeden(p.nedenler?.[0]?.kod ?? '');
      setPHata('');
    }
  }, [istek]);

  /* DOVIZ SECILINCE KURU GETIR: kur alani elle doldurulabilir ama gunun kuru
     hazir gelmeli - kullanici her tahsilatta kur tablosuna bakmasin. */
  const p = istek?.para;
  const yerelPara = p?.yerelPara || 'TL';
  const kurGetir = p?.kurGetir;
  useEffect(() => {
    if (!istek?.paraMi || !kurGetir || pDoviz === yerelPara) { setPKur('1'); return }
    let iptal = false;
    void (async () => {
      try { const k = await kurGetir(pDoviz); if (!iptal && k) setPKur(String(k)) }
      catch { /* kur yoksa kullanici elle girer */ }
    })();
    return () => { iptal = true };
  }, [istek?.paraMi, kurGetir, pDoviz, yerelPara]);

  if (!istek) return null;

  /**
   * PARA ISTEGINI DOGRULA ve sonucu uret. Hata varsa null doner ve pencere
   * ACIK kalir - yanlis tutar sessizce kapanip cagirani 0 ile birakmasin.
   */
  const paraSonucu = (): ParaSecimi | null => {
    const se = istek.para ?? {};
    const ham = tutarOku(girdi);
    if (!(ham > 0)) { setPHata('Tutar sıfırdan büyük olmalı.'); return null }
    if (se.enCok != null && ham > se.enCok + 0.005) {
      setPHata(`En fazla ${paraBicim.format(se.enCok)} girilebilir.`); return null;
    }
    if (se.nedenler?.length && !pNeden) { setPHata('Neden seçilmeli.'); return null }
    const kur = Math.abs(tutarOku(pKur)) || 1;
    const isaret = se.eksiMi ? -1 : 1;
    const yuvarla = (x: number) => Math.round(x * 100) / 100;
    const sonuc: ParaSecimi = {
      tutar: yuvarla(ham * isaret), doviz: pDoviz, kur,
      yerelTutar: yuvarla(ham * kur * isaret),
      ...(se.nedenler?.length ? { neden: pNeden } : {}),
    };
    return sonuc;
  };

  const kapat = (sonuc: boolean) => {
    // Metin istegi ise degeri (iptalde null) ayri geri cagirimla veririz.
    if (istek.paraMi) {
      if (sonuc) {
        const s = paraSonucu();
        if (!s) return;                       // hatali: pencere acik kalir
        istek.cozumPara?.(s);
      } else istek.cozumPara?.(null);
    }
    else if (istek.girdiMi) istek.cozumMetin?.(sonuc ? girdi : null);
    else if (istek.secenekler) istek.cozumSecim?.(istek.varsayilanKod ?? '');
    else istek.cozum(sonuc);
    setIstek(null);
    setGirdi('');
  };

  /** Cok secenekli soruda dugmeye basildi (Kaydet / İptal / Geri Dön). */
  const secildi = (kod: string) => {
    istek.cozumSecim?.(kod);
    setIstek(null);
    setGirdi('');
  };

  return (
    <Modal
      baslik={`${urunAdi(kullanici?.urunModu)} Mesajı`}
      dar
      // DAHA DA DAR (543, kullanici: "gelen mesajlar çok geniş"): `dar`
      //   kart olcusu (560px) - bir satirlik uyari icin fazlasiyla genis
      //   duruyordu, goz metni bulmak icin pencerede geziniyordu.
      ekSinif="mesaj-pencere"
      buyutmeYok
      enUst
      onKapat={() => kapat(false)}
      alt={
        istek.secenekler ? (
          // COK SECENEKLI soru (or. "Kaydet / İptal / Geri Dön"): dugmeler
          //   verildigi SIRADA cizilir, ilki one cikan secimdir.
          <>
            {istek.secenekler.map((x, i) => (
              <button key={x.kod} type="button"
                      className={`d ${x.sinif ?? ''}`.trim()}
                      autoFocus={i === 0}
                      onClick={() => secildi(x.kod)}>
                {x.ad}
              </button>
            ))}
          </>
        ) : (
        <>
          {/* Onay kutusundaki ikinci dugme "Kapat" (kullanici): "Vazgeç"
              yapilmis bir isi geri aliyormus izlenimi veriyordu - oysa soru
              henuz cevaplanmadi, kutu kapaniyor. */}
          {istek.onayMi && (
            <button type="button" className="d kapat-dugmesi"
                    onClick={() => kapat(false)}>Kapat</button>
          )}
          <button type="button"
                  className={`d ${istek.tehlike ? 'teh' : 'bir'}`}
                  autoFocus
                  onClick={() => kapat(true)}>
            {istek.onayMi ? 'Tamam' : 'Kapat'}
          </button>
        </>
        )
      }
    >
      {/* Satir sonlari korunur: sunucudan gelen cok satirli aciklamalar
          (or. "Gönderilemedi (HTTP 400): ...") okunakli kalsin.
          CERCEVESIZ (543, kullanici: "mesaj ekranı alta doğru çok uzamış"):
          metin bir KART bolumu degil - `.kagrup` kutusu pencerenin icine
          ikinci bir cerceve ve ikinci bir kenar boslugu koyuyor, iki
          cumlelik uyari 192 piksele cikiyordu. */}
      <div className="mesaj-govde">
        <div style={{ whiteSpace: 'pre-wrap', lineHeight: 1.45 }}>
          {istek.metin}
        </div>
        {/* PARA ISTEGI: tutar + birim, dovizde kur ve yerel karsilik, istege
            gore neden combosu ve para ustu. */}
        {istek.paraMi && (() => {
          const se = istek.para ?? {};
          const kodlar = se.dovizler ?? ['TL', 'USD', 'EUR', 'GBP'];
          const dovizli = pDoviz !== yerelPara;
          const kurSayi = Math.abs(tutarOku(pKur)) || 1;
          const hamTutar = tutarOku(girdi);
          const isaret = se.eksiMi ? '−' : '';
          return (
          <div className="alan-izgara tek-sutun ayar-formu para-sor"
               style={{ paddingTop: 10 }}>
            <label className="alan">
              <span className="etiket zorunlu-isaret">Tutar</span>
              <span className="ikili">
                <input className="hiza-sag genis-deger" autoFocus value={girdi}
                       onChange={e => { setGirdi(e.target.value); setPHata('') }}
                       onKeyDown={e => { if (e.key === 'Enter') kapat(true) }} />
                {/* PARA BIRIMI TUTARIN SAGINDA (kullanici): dovizli kasada
                    "100" ne demek belirsizdi - birim yaninda okunmali. */}
                <select className="birim" title="Para birimi" value={pDoviz}
                        onChange={e => { setPDoviz(e.target.value); setPHata('') }}>
                  {kodlar.map(k => <option key={k} value={k}>{k}</option>)}
                  {!kodlar.includes(pDoviz) && <option value={pDoviz}>{pDoviz}</option>}
                </select>
              </span>
            </label>

            {/* DOVIZ SECILDIYSE kur ve YEREL KARSILIK: kasaya yazilan tutar
                yerel karsiliktir; kullanici neyin isleneceğini gormeli. */}
            {dovizli && (
              <label className="alan">
                <span className="etiket">Kur</span>
                <span className="ikili">
                  <input className="hiza-sag" value={pKur}
                         onChange={e => { setPKur(e.target.value); setPHata('') }} />
                  <span className="birim-metin">{yerelPara}/{pDoviz}</span>
                </span>
                <span className="ipucu">
                  Yerel karşılık: <b>{isaret}{paraBicim.format(hamTutar * kurSayi)} {yerelPara}</b>
                  {' · '}işlem {isaret}{paraBicim.format(hamTutar)} {pDoviz} olarak da saklanır
                </span>
              </label>
            )}

            {/* IADE / IPTAL NEDENI: serbest metin degil KOD - rapor
                "fazla tahsilat" ile "fazla alindi"yi ayni sayamiyordu. */}
            {!!se.nedenler?.length && (
              <label className="alan">
                <span className="etiket zorunlu-isaret">
                  {se.nedenEtiket ?? 'İade / İptal Nedeni'}
                </span>
                <select className="genis-deger" value={pNeden}
                        onChange={e => { setPNeden(e.target.value); setPHata('') }}>
                  <option value="">— seçiniz —</option>
                  {se.nedenler.map(x => <option key={x.kod} value={x.kod}>{x.ad}</option>)}
                </select>
              </label>
            )}


            {!!pHata && <div className="hata-kutusu">{pHata}</div>}
          </div>
          );
        })()}
        {istek.girdiMi && (
          <div className="alan-izgara tek-sutun ayar-formu" style={{ paddingTop: 10 }}>
            <label className="alan">
              {istek.girdiEtiket && <span className="etiket">{istek.girdiEtiket}</span>}
              {/* SECENEKLI GIRDI: kutu yerine acilir liste (kullanici).
                  Kod ezberletmek yerine ad gosterilir; donen deger koddur. */}
              {istek.girdiSecenekleri ? (
                <select className="genis-deger" autoFocus
                        value={girdi}
                        onChange={e => setGirdi(e.target.value)}
                        onKeyDown={e => { if (e.key === 'Enter') kapat(true) }}>
                  {istek.girdiSecenekleri.map(x => (
                    <option key={x.kod} value={x.kod}>{x.ad}</option>
                  ))}
                </select>
              ) : (
              <span className="ikili">
                <input className="genis-deger" autoFocus
                       ref={girdiKutusu}
                       value={girdi}
                       onChange={e => setGirdi(e.target.value)}
                       onKeyDown={e => { if (e.key === 'Enter') kapat(true) }} />
                {/* TEMIZLE (kullanici: "tutar sorma modalinde edite clear ×
                    ekle"): kutu onerilen tutarla DOLU acilir; baska bir rakam
                    yazmak icin once elle silmek gerekiyordu. × kutuyu bosaltir
                    ve imleci icine birakir - kullanici dogrudan yazar. */}
                {girdi !== '' && (
                  <button type="button" className="d mini" title="Temizle"
                          onClick={() => { setGirdi(''); girdiKutusu.current?.focus() }}>
                    ×
                  </button>
                )}
              </span>
              )}
            </label>
          </div>
        )}
      </div>
    </Modal>
  );
}
