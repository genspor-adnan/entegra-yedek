import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type SubeOzeti, hataMetni, urunAdi, URUN_GENOTIP } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { c } from '../dil/ceviri';
import { sonKullaniciOku } from '../kimlik/sonKullanici';

/**
 * Giris ekrani. Cok subeli kullanicida sube secimi giris akisinin parcasidir:
 * kullanici/parola dogrulanip subeler ogrenilir, sube secilince oturum acilir.
 * (Sunucu sube secilmeden de token verir; burada secim once sorulur ki
 * kullanici hangi subede calistigini bilerek girsin.)
 */
export function Giris() {
  const { girisYap } = useOturum();
  // Son başarılı girişin kodu öntanımlı; hiç giriş yoksa eski varsayılan.
  const [kod, setKod] = useState(() => sonKullaniciOku() ?? 'admin');
  const [parola, setParola] = useState('');
  const [subeler, setSubeler] = useState<SubeOzeti[] | null>(null);
  const [subeId, setSubeId] = useState<number | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [bekliyor, setBekliyor] = useState(false);
  // DEMO OLARAK DENE (964): yalnız DEMO kurulumda sunucu liste döner.
  const [demoGirisler, setDemoGirisler] = useState<{ kod: string; baslik: string; parola: string }[]>([]);
  useEffect(() => { api.demoGirisler().then(y => setDemoGirisler(y.girisler)).catch(() => setDemoGirisler([])) }, []);
  async function demoGir(k: { kod: string; parola: string }) {
    setHata(null); setBekliyor(true);
    try { await girisYap(k.kod, k.parola) } catch (h) { setHata(hataMetni(h)) } finally { setBekliyor(false) }
  }
  // ILK GIRIS (kullanici): personel eklenince acilan hesabin parolasi bostur;
  //   kisi burada kendi parolasini tanimlar. IKI ADIM (denetim 28.09.2026 #5):
  //   1. kullanici + TCKN son 4 -> kayitli kanala kod, 2. kod + yeni parola.
  //   TCKN son 4 tek basina parola belirlemeye yetmez.
  const [ilkAdim, setIlkAdim] = useState<0 | 1 | 2>(0);
  const [tcknSon4, setTcknSon4] = useState('');
  const [yeni1, setYeni1] = useState('');
  const [yeni2, setYeni2] = useState('');
  const [bilgi, setBilgi] = useState<string | null>(null);
  // PAROLAMI UNUTTUM (843, kullanici): kayitli cep / e-postaya tek kullanimlik
  //   kod, kodla yeni parola. 1. adim kullanici kodu, 2. adim kod + parola.
  const [unuttumAdim, setUnuttumAdim] = useState<0 | 1 | 2>(0);
  const [dogrulamaKodu, setDogrulamaKodu] = useState('');
  /**
   * URUN ADI (502, kullanici: "login de Gentegre yazıyor, moda göre GenoTIP AI
   * veya Gentegre AI yazmalı"). Baslik sabitti; HBYS kurulumunda yanlis urunun
   * adini gosteriyordu. Mod sunucudan (anonim `/api/kimlik/marka`) gelir;
   * cevap gelene kadar ya da sunucuya ulasilamazsa KURULUM YOLUNDAN tahmin
   * edilir - "/genotipai/" altinda calisan kopya GenoTIP'tir.
   */
  const yoldanMod = import.meta.env.BASE_URL.includes('genotip')
    ? URUN_GENOTIP : undefined;
  // Son bilinen mod tarayıcıda saklanır: sunucu cevabı gelene kadar "Gentegre AI"
  //   yanıp sönüyordu (kullanıcı: "loginde gentegre ai geliyor, hbys ise GenoTIP AI").
  const saklanan = (() => { try { const v = Number(localStorage.getItem('gentegre.urunModu')); return v > 0 ? v : undefined } catch { return undefined } })();
  const [urunModu, setUrunModu] = useState<number | undefined>(saklanan ?? yoldanMod);
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.marka();
        if (!iptal && y.urunModu > 0) { setUrunModu(y.urunModu); try { localStorage.setItem('gentegre.urunModu', String(y.urunModu)) } catch { /* yoksay */ } }
      } catch { /* sunucu/veritabani yoksa yoldan gelen tahmin kalir */ }
    })();
    return () => { iptal = true };
  }, []);
  const baslik = urunAdi(urunModu);
  useEffect(() => { document.title = baslik }, [baslik]);
  /* Marka seridi: sembol + urun adi (kabuktaki ust seritle AYNI gorunum).
     BASE_URL: uygulama alt yolda yayinda (/genotipai) - mutlak "/..." 404 verir. */
  const marka = (
    <div className="giris-marka">
      <img src={`${import.meta.env.BASE_URL}gentegre-sembol.svg`} alt="" />
      <h1>{baslik}</h1>
    </div>
  );

  const PAROLA_KURALI = 'En az 8 karakter; küçük harf, BÜYÜK harf, rakam ve '
                      + 'harf/rakam dışı bir karakter (ör. .!?*-_) içermeli.';

  async function ilkParola(e: React.FormEvent) {
    e.preventDefault();
    setHata(null); setBilgi(null);
    if (ilkAdim === 2 && yeni1 !== yeni2) { setHata('Parolalar aynı değil.'); return }
    setBekliyor(true);
    try {
      if (ilkAdim === 1) {
        // Sunucu her durumda ayni cevabi verir; kod gelmediyse "yeniden iste".
        const y = await api.ilkParolaKod(kod, tcknSon4);
        setBilgi(y.mesaj);
        setIlkAdim(2);
        return;
      }
      const y = await api.ilkParola(kod, dogrulamaKodu, yeni1);
      setBilgi(y.mesaj);
      setIlkAdim(0);
      setParola(''); setYeni1(''); setYeni2(''); setTcknSon4(''); setDogrulamaKodu('');
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setBekliyor(false);
    }
  }

  async function parolaUnuttum(e: React.FormEvent) {
    e.preventDefault();
    setHata(null); setBilgi(null);
    setBekliyor(true);
    try {
      if (unuttumAdim === 1) {
        const y = await api.parolaUnuttum(kod);
        // Hesap yoksa da sunucu genel cevap verir; kullanici 2. adima gecer,
        //   kod gelmediyse "Kodu yeniden iste" ile doner.
        setBilgi(y.gonderildi
          ? `Doğrulama kodu ${y.kanal === 'sms' ? 'SMS ile' : 'e-posta ile'} ${y.hedef} adresine gönderildi (${y.dakika} dk geçerli).`
          : y.mesaj);
        setUnuttumAdim(2);
        return;
      }
      if (yeni1 !== yeni2) { setHata('Parolalar aynı değil.'); return }
      const y = await api.parolaUnuttumDogrula(kod, dogrulamaKodu, yeni1);
      setBilgi(y.mesaj);
      setUnuttumAdim(0);
      setParola(''); setYeni1(''); setYeni2(''); setDogrulamaKodu('');
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setBekliyor(false);
    }
  }

  async function gonder(e: React.FormEvent) {
    e.preventDefault();
    setHata(null);
    setBekliyor(true);
    try {
      if (subeler === null) {
        // 1. adim: kimlik dogrulama - sube secimi gerekiyorsa listeyi goster
        const yanit = await api.giris(kod, parola);
        if (yanit.subeSecimiGerekli) {
          setSubeler(yanit.kullanici.subeler);
          setSubeId(yanit.kullanici.subeler.find(s => s.varsayilan)?.id ?? yanit.kullanici.subeler[0]?.id ?? null);
          return;
        }
        await girisYap(kod, parola);
      } else {
        // 2. adim: secilen sube ile giris
        await girisYap(kod, parola, subeId ?? undefined);
      }
    } catch (h) {
      // Hesap var ama parolasi HIC tanimlanmamis: dogrudan parola belirleme
      //   ekranina gecilir (kullanici: "sifre bossa user pass ekrani direk ciksin").
      if (h instanceof ApiHatasi && h.hata.kod === 'ILK_PAROLA') {
        setIlkAdim(1);
        setHata(null);
        setBilgi(h.hata.mesaj);
      } else {
        setHata(hataMetni(h));
      }
      setSubeler(null);
    } finally {
      setBekliyor(false);
    }
  }

  if (unuttumAdim > 0) {
    return (
      <div className="giris-sayfa">
        {/* key: formlar ayni konumda; key'siz React "Parolami unuttum" dugmesinin
            DOM dugumunu bu formun submit dugmesi olarak yeniden kullaniyor ve
            tiklamanin varsayilan eylemi formu hemen gonderiyordu. */}
        <form key="unuttum" className="giris-kart" onSubmit={parolaUnuttum}>
          {marka}
          <p className="alt-baslik">
            {unuttumAdim === 1 ? 'Şifremi unuttum — hesabınızı yazın' : 'Şifremi unuttum — kodu ve yeni parolayı yazın'}
          </p>
          <label>
            Kimlik No/Telefon/E-Posta
            <input value={kod} onChange={e => setKod(e.target.value)} autoFocus={unuttumAdim === 1}
                   autoComplete="off" readOnly={unuttumAdim === 2} />
          </label>
          {unuttumAdim === 1 ? (
            <p style={{ fontSize: 11, opacity: .8, margin: '2px 0 6px' }}>
              Hesabınızda kayıtlı cep telefonuna (yoksa e-posta adresine) 6 haneli doğrulama kodu gönderilir.
            </p>
          ) : (
            <>
              <label>
                Doğrulama kodu
                <input value={dogrulamaKodu} maxLength={6} inputMode="numeric" autoFocus autoComplete="one-time-code"
                       onChange={e => setDogrulamaKodu(e.target.value.replace(/\D/g, ''))} />
              </label>
              <label>{c('Yeni parola')}<input type="password" value={yeni1} autoComplete="new-password"
                       onChange={e => setYeni1(e.target.value)} />
              </label>
              <label>
                Yeni parola (tekrar)
                <input type="password" value={yeni2} autoComplete="new-password"
                       onChange={e => setYeni2(e.target.value)} />
              </label>
              <p style={{ fontSize: 11, opacity: .8, margin: '2px 0 6px' }}>{PAROLA_KURALI}</p>
            </>
          )}
          {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}
          {hata && <div className="hata-kutusu">{hata}</div>}
          <button type="submit" disabled={bekliyor}>
            {bekliyor ? 'Bekleyin…' : unuttumAdim === 1 ? 'Kod Gönder' : 'Parolayı Değiştir'}
          </button>
          {unuttumAdim === 2 && (
            <button type="button" className="d" style={{ marginTop: 8 }}
                    onClick={() => { setUnuttumAdim(1); setHata(null); setBilgi(null) }}>
              Kodu yeniden iste
            </button>
          )}
          <button type="button" className="d" style={{ marginTop: 8 }}
                  onClick={() => { setUnuttumAdim(0); setHata(null); setBilgi(null) }}>
            Girişe dön
          </button>
        </form>
      </div>
    );
  }

  if (ilkAdim > 0) {
    return (
      <div className="giris-sayfa">
        <form key="ilk-parola" className="giris-kart" onSubmit={ilkParola}>
          {marka}
          <p className="alt-baslik">
            {ilkAdim === 1 ? c('İlk giriş — kimliğinizi doğrulayın')
                           : c('İlk giriş — kodu ve yeni parolayı yazın')}
          </p>
          <label>
            Kullanıcı (sicil no)
            <input value={kod} onChange={e => setKod(e.target.value)} autoFocus={ilkAdim === 1}
                   readOnly={ilkAdim === 2} />
          </label>
          {ilkAdim === 1 ? (
            <>
              <label>
                Kimlik No — son 4 hane
                <input value={tcknSon4} maxLength={4} inputMode="numeric"
                       onChange={e => setTcknSon4(e.target.value.replace(/\D/g, ''))} />
              </label>
              <p style={{ fontSize: 11, opacity: .8, margin: '2px 0 6px' }}>
                Bilgiler doğruysa hesabınızda kayıtlı cep telefonuna (yoksa e-posta adresine)
                6 haneli doğrulama kodu gönderilir. Kayıtlı iletişim bilginiz yoksa yöneticinize başvurun.
              </p>
            </>
          ) : (
            <>
              <label>
                Doğrulama kodu
                <input value={dogrulamaKodu} maxLength={6} inputMode="numeric" autoFocus autoComplete="one-time-code"
                       onChange={e => setDogrulamaKodu(e.target.value.replace(/\D/g, ''))} />
              </label>
              <label>{c('Yeni parola')}<input type="password" value={yeni1} autoComplete="new-password"
                       onChange={e => setYeni1(e.target.value)} />
              </label>
              <label>
                Yeni parola (tekrar)
                <input type="password" value={yeni2} autoComplete="new-password"
                       onChange={e => setYeni2(e.target.value)} />
              </label>
              <p style={{ fontSize: 11, opacity: .8, margin: '2px 0 6px' }}>{PAROLA_KURALI}</p>
            </>
          )}
          {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}
          {hata && <div className="hata-kutusu">{hata}</div>}
          <button type="submit" disabled={bekliyor}>
            {bekliyor ? 'Bekleyin…' : ilkAdim === 1 ? 'Kod Gönder' : 'Parolayı Belirle'}
          </button>
          {ilkAdim === 2 && (
            <button type="button" className="d" style={{ marginTop: 8 }}
                    onClick={() => { setIlkAdim(1); setHata(null); setBilgi(null) }}>
              Kodu yeniden iste
            </button>
          )}
          <button type="button" className="d" style={{ marginTop: 8 }}
                  onClick={() => { setIlkAdim(0); setHata(null) }}>
            Girişe dön
          </button>
        </form>
      </div>
    );
  }

  return (
    <div className="giris-sayfa">
      <form key="giris" className="giris-kart" onSubmit={gonder}>
        {marka}
        <p className="alt-baslik">
          {subeler === null ? 'Kullanici adi ve parola' : 'Calisacaginiz subeyi secin'}
        </p>

        {subeler === null ? (
          <>
            <label>
              Kimlik No/Telefon/E-Posta
              {/* OTOMATIK TAMAMLAMA KAPALI (780, kullanici): kullanici adi
                  ve parola alanlarinda tarayicinin kayitli kimlik onerisi
                  cikmasin. Paroladaki "new-password", Chrome/Edge'in
                  `off`u yok saymasi yuzunden (bkz. otomatikTamamlama.ts). */}
              <input value={kod} onChange={e => setKod(e.target.value)} autoFocus={!kod}
                     autoComplete="off" />
            </label>
            <label>
              Parola
              {/* Kod hazır geliyorsa imleç doğrudan parolada. */}
              <input type="password" value={parola} autoComplete="new-password"
                     autoFocus={!!kod} onChange={e => setParola(e.target.value)} />
            </label>
          </>
        ) : (
          <label>
            Sube
            <select value={subeId ?? ''} onChange={e => setSubeId(Number(e.target.value))}>
              {subeler.map(s => (
                <option key={s.id} value={s.id}>
                  {s.ad}{s.varsayilan ? ' (varsayilan)' : ''}{s.yazma ? '' : ' — salt okuma'}
                </option>
              ))}
            </select>
          </label>
        )}

        {hata && <div className="hata-kutusu">{hata}</div>}
        {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

        <button type="submit" disabled={bekliyor}>
          {bekliyor ? 'Bekleyin…' : subeler === null ? 'Giris' : 'Devam'}
        </button>
        {subeler === null && (
          /* Metin bağlantısı (kullanıcı: "buton değil label olsun"). */
          <a href="#" className="giris-baglanti"
             onClick={e => { e.preventDefault(); setUnuttumAdim(1); setHata(null); setBilgi(null) }}>
            Şifremi Unuttum
          </a>
        )}
        {subeler === null && demoGirisler.length > 0 && (
          <div className="giris-demo">
            <span>{c('Demo olarak dene')}</span>
            <div>{demoGirisler.map(k => (
              <button key={k.kod} type="button" className="d" disabled={bekliyor} onClick={() => void demoGir(k)}>{c(k.baslik)}</button>
            ))}</div>
          </div>
        )}

      </form>
    </div>
  );
}
