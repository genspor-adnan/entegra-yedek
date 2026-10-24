import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { TABAN } from '../api/cekirdek';
import { ApiHatasi, type SubeOzeti, hataMetni, urunAdi, URUN_GENOTIP } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { aktifDil, c, ceviriDinle, ceviriYukle } from '../dil/ceviri';
import { sonKullaniciOku } from '../kimlik/sonKullanici';
import { ParolaGirdisi } from '../bilesenler/ParolaGirdisi';

/**
 * Giris ekrani. Cok subeli kullanicida sube secimi giris akisinin parcasidir:
 * kullanici/parola dogrulanip subeler ogrenilir, sube secilince oturum acilir.
 * (Sunucu sube secilmeden de token verir; burada secim once sorulur ki
 * kullanici hangi subede calistigini bilerek girsin.)
 */
export function Giris() {
  const { girisYap, dilDegistir } = useOturum();
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
   * DİL SEÇİMİ (kullanıcı 16.10.2026: "login üste dil seçimi gelmeli"): sözlük oturumsuz iner
   * (/api/ceviri). Seçim tarayıcıda saklanır; girişten sonra kullanıcının tercihine yazılır.
   */
  const [, yeniden] = useState(0);
  useEffect(() => ceviriDinle(() => yeniden(n => n + 1)), []);
  const girisDili = (() => { try { const v = localStorage.getItem('gentegre.girisDil'); return v === null ? null : Number(v) } catch { return null } })();
  useEffect(() => { if (girisDili !== null) void ceviriYukle(girisDili) }, []);   // eslint-disable-line react-hooks/exhaustive-deps
  const dilSec = (d: number) => {
    try { localStorage.setItem('gentegre.girisDil', String(d)) } catch { /* yoksay */ }
    void ceviriYukle(d);
  };
  const dilSecici = (
    <div className="giris-dil" role="group" aria-label="Dil / Language">
      {[[0, 'TR'], [1, 'EN'], [2, 'DE']].map(([d, ad]) => (
        <button key={d} type="button" className={aktifDil() === d ? 'on' : ''} onClick={() => dilSec(Number(d))}>{ad}</button>
      ))}
    </div>
  );
  /** CAPS LOCK UYARISI (giriş v2): parola alanında büyük harf kilidi açıksa. */
  const [capsAcik, setCapsAcik] = useState(false);
  const capsIzle = (e: React.KeyboardEvent<HTMLInputElement>) => setCapsAcik(e.getModifierState('CapsLock'));
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
  /* GİRİŞ PENCERESİ v2 (kullanıcı 16.10.2026, mockup Ekranlar/Ayarlar/giris_ekrani_v2.html): ortada
     tek pencere - solda dar marka şeridi (sembol + ürün adı, slogan, "YZ destekli"), sağda form.
     BASE_URL: uygulama alt yolda yayinda (/genotipai) - mutlak "/..." 404 verir. */
  const pencere = (form: React.ReactNode) => <GirisPenceresi baslik={baslik} ust={dilSecici}>{form}</GirisPenceresi>;
  /** Adım çubuğu: 1 kimlik + parola, 2 şube. */
  const adimCubugu = (n: 1 | 2) => <div className="giris-adim"><i className="on" /><i className={n === 2 ? 'on' : ''} /></div>;

  const PAROLA_KURALI = 'En az 8 karakter; küçük harf, BÜYÜK harf, rakam ve '
                      + 'harf/rakam dışı bir karakter (ör. .!?*-_) içermeli.';

  async function ilkParola(e: React.FormEvent) {
    e.preventDefault();
    setHata(null); setBilgi(null);
    if (ilkAdim === 2 && yeni1 !== yeni2) { setHata(c('Parolalar aynı değil.')); return }
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
      if (yeni1 !== yeni2) { setHata(c('Parolalar aynı değil.')); return }
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

  /** Girişte dil seçildiyse kullanıcının tercihine yazılır (oturum açılınca kabuk o dili yükler). */
  const dilTercihiYaz = () => { if (girisDili !== null) void dilDegistir(girisDili).catch(() => {}) };

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
        dilTercihiYaz();
      } else {
        // 2. adim: secilen sube ile giris
        await girisYap(kod, parola, subeId ?? undefined);
        dilTercihiYaz();
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
    // key: formlar ayni konumda; key'siz React "Parolami unuttum" dugmesinin DOM dugumunu bu
    //   formun submit dugmesi olarak yeniden kullaniyor ve tiklama formu hemen gonderiyordu.
    return pencere(
        <form key="unuttum" className="giris-kart" onSubmit={parolaUnuttum}>
          <h1>{c('Şifremi unuttum')}</h1>
          <p className="alt-baslik">
            {unuttumAdim === 1 ? c('Kayıtlı telefonunuza ya da e-posta adresinize tek kullanımlık kod göndereceğiz.')
                               : c('Gelen kodu ve yeni parolanızı yazın.')}
          </p>
          <label>
            {c('Kimlik No/Telefon/E-Posta')}
            <input value={kod} onChange={e => setKod(e.target.value)} autoFocus={unuttumAdim === 1}
                   autoComplete="off" readOnly={unuttumAdim === 2} />
          </label>
          {unuttumAdim === 1 ? (
            <p style={{ fontSize: 11, opacity: .8, margin: '2px 0 6px' }}>
              {c('Hesabınızda kayıtlı cep telefonuna (yoksa e-posta adresine) 6 haneli doğrulama kodu gönderilir.')}
            </p>
          ) : (
            <>
              <label>
                {c('Doğrulama kodu')}
                <input value={dogrulamaKodu} maxLength={6} inputMode="numeric" autoFocus autoComplete="one-time-code"
                       onChange={e => setDogrulamaKodu(e.target.value.replace(/\D/g, ''))} />
              </label>
              <label>{c('Yeni parola')}<ParolaGirdisi value={yeni1} autoComplete="new-password"
                       onChange={e => setYeni1(e.target.value)} />
              </label>
              <label>
                {c('Yeni parola (tekrar)')}
                <ParolaGirdisi value={yeni2} autoComplete="new-password"
                       onChange={e => setYeni2(e.target.value)} />
              </label>
              <p style={{ fontSize: 11, opacity: .8, margin: '2px 0 6px' }}>{c(PAROLA_KURALI)}</p>
            </>
          )}
          {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}
          {hata && <div className="hata-kutusu">{hata}</div>}
          <button type="submit" disabled={bekliyor}>
            {bekliyor ? c('Bekleyin…') : unuttumAdim === 1 ? c('Kod Gönder') : c('Parolayı Değiştir')}
          </button>
          {unuttumAdim === 2 && (
            <button type="button" className="d" style={{ marginTop: 8 }}
                    onClick={() => { setUnuttumAdim(1); setHata(null); setBilgi(null) }}>
              {c('Kodu yeniden iste')}
            </button>
          )}
          <button type="button" className="d" style={{ marginTop: 8 }}
                  onClick={() => { setUnuttumAdim(0); setHata(null); setBilgi(null) }}>
            ← {c('Girişe dön')}
          </button>
        </form>
    );
  }

  if (ilkAdim > 0) {
    return pencere(
        <form key="ilk-parola" className="giris-kart" onSubmit={ilkParola}>
          <h1>{c('Yeni parolanızı belirleyin')}</h1>
          <p className="alt-baslik">
            {ilkAdim === 1 ? c('İlk giriş — kimliğinizi doğrulayın')
                           : c('İlk giriş — kodu ve yeni parolayı yazın')}
          </p>
          <label>
            {c('Kullanıcı (sicil no)')}
            <input value={kod} onChange={e => setKod(e.target.value)} autoFocus={ilkAdim === 1}
                   readOnly={ilkAdim === 2} />
          </label>
          {ilkAdim === 1 ? (
            <>
              <label>
                {c('Kimlik No — son 4 hane')}
                <input value={tcknSon4} maxLength={4} inputMode="numeric"
                       onChange={e => setTcknSon4(e.target.value.replace(/\D/g, ''))} />
              </label>
              <p style={{ fontSize: 11, opacity: .8, margin: '2px 0 6px' }}>
                {c('Bilgiler doğruysa hesabınızda kayıtlı cep telefonuna (yoksa e-posta adresine) 6 haneli doğrulama kodu gönderilir. Kayıtlı iletişim bilginiz yoksa yöneticinize başvurun.')}
              </p>
            </>
          ) : (
            <>
              <label>
                {c('Doğrulama kodu')}
                <input value={dogrulamaKodu} maxLength={6} inputMode="numeric" autoFocus autoComplete="one-time-code"
                       onChange={e => setDogrulamaKodu(e.target.value.replace(/\D/g, ''))} />
              </label>
              <label>{c('Yeni parola')}<ParolaGirdisi value={yeni1} autoComplete="new-password"
                       onChange={e => setYeni1(e.target.value)} />
              </label>
              <label>
                {c('Yeni parola (tekrar)')}
                <ParolaGirdisi value={yeni2} autoComplete="new-password"
                       onChange={e => setYeni2(e.target.value)} />
              </label>
              <p style={{ fontSize: 11, opacity: .8, margin: '2px 0 6px' }}>{c(PAROLA_KURALI)}</p>
            </>
          )}
          {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}
          {hata && <div className="hata-kutusu">{hata}</div>}
          <button type="submit" disabled={bekliyor}>
            {bekliyor ? c('Bekleyin…') : ilkAdim === 1 ? c('Kod Gönder') : c('Parolayı Belirle')}
          </button>
          {ilkAdim === 2 && (
            <button type="button" className="d" style={{ marginTop: 8 }}
                    onClick={() => { setIlkAdim(1); setHata(null); setBilgi(null) }}>
              {c('Kodu yeniden iste')}
            </button>
          )}
          <button type="button" className="d" style={{ marginTop: 8 }}
                  onClick={() => { setIlkAdim(0); setHata(null) }}>
            ← {c('Girişe dön')}
          </button>
        </form>
    );
  }

  return pencere(
      <form key="giris" className="giris-kart" onSubmit={gonder}>
        {adimCubugu(subeler === null ? 1 : 2)}
        <h1>{subeler === null ? c('Giriş yapın') : c('Şube seçin')}</h1>
        <p className="alt-baslik">
          {subeler === null ? c('Kimlik numaranız, telefonunuz ya da e-posta adresinizle.')
                            : c('Birden çok şubede yetkiniz var. Kayıtlar seçtiğiniz şubeye yazılır.')}
        </p>

        {subeler === null ? (
          <>
            <label>
              {c('Kimlik No/Telefon/E-Posta')}
              {/* OTOMATIK TAMAMLAMA KAPALI (780, kullanici): kullanici adi
                  ve parola alanlarinda tarayicinin kayitli kimlik onerisi
                  cikmasin. Paroladaki "new-password", Chrome/Edge'in
                  `off`u yok saymasi yuzunden (bkz. otomatikTamamlama.ts). */}
              <input value={kod} onChange={e => setKod(e.target.value)} autoFocus={!kod}
                     autoComplete="off" />
            </label>
            <label>
              {c('Parola')}
              {/* Kod hazır geliyorsa imleç doğrudan parolada. */}
              <ParolaGirdisi value={parola} autoComplete="new-password"
                     autoFocus={!!kod} onChange={e => setParola(e.target.value)}
                     onKeyUp={capsIzle} onKeyDown={capsIzle} onBlur={() => setCapsAcik(false)} />
              {capsAcik && <span className="giris-caps">⇪ {c('Caps Lock açık')}</span>}
            </label>
          </>
        ) : (
          // ŞUBE KARTLARI (giriş v2): varsayılan / salt okuma rozetle; tık seçer.
          <div className="giris-subeler" role="radiogroup">
            {subeler.map(s => (
              <button key={s.id} type="button" role="radio" aria-checked={s.id === subeId}
                      className={`giris-sube${s.id === subeId ? ' on' : ''}`}
                      onClick={() => setSubeId(s.id)}>
                <span className="giris-sube-ic">🏥</span>
                <b>{s.ad}</b>
                {s.varsayilan && <span className="rozet olumlu">{c('varsayılan')}</span>}
                {!s.yazma && <span className="rozet uyari">{c('salt okuma')}</span>}
              </button>
            ))}
          </div>
        )}

        {hata && <div className="hata-kutusu">{hata}</div>}
        {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

        <button type="submit" disabled={bekliyor}>
          {bekliyor ? c('Bekleyin…') : subeler === null ? c('Giriş Yap') : c('Devam')}
        </button>
        {subeler === null && (
          /* Metin bağlantısı (kullanıcı: "buton değil label olsun"). */
          <a href="#" className="giris-baglanti"
             onClick={e => { e.preventDefault(); setUnuttumAdim(1); setHata(null); setBilgi(null) }}>
            {c('Şifremi Unuttum')}
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
  );
}

/** Giriş penceresi (v2): solda marka şeridi, sağda form - giriş ve zorunlu parola ekranları ortak. */
export function GirisPenceresi({ baslik, children, ust }: { baslik: string; children: React.ReactNode; ust?: React.ReactNode }) {
  // MÜŞTERİ ADI + LOGOSU (kullanıcı 16.10.2026): ana şubenin anteti, oturumsuz marka ucundan.
  //   Son bilinen tarayıcıda saklanır - açılışta boş satır yanıp sönmesin.
  const [kurum, setKurum] = useState<{ ad: string; logo: boolean }>(() => {
    try { return JSON.parse(localStorage.getItem('gentegre.girisKurum') ?? '') } catch { return { ad: '', logo: false } }
  });
  useEffect(() => {
    let iptal = false;
    api.marka().then(y => {
      if (iptal) return;
      const k = { ad: y.kurumAdi ?? '', logo: !!y.logoVar };
      setKurum(k);
      try { localStorage.setItem('gentegre.girisKurum', JSON.stringify(k)) } catch { /* yoksay */ }
    }).catch(() => { /* sunucu yoksa saklanan kalır */ });
    return () => { iptal = true };
  }, []);
  return (
    <div className="giris-sayfa">
      <div className="giris-pencere">
        <aside className="giris-serit">
          <div className="giris-marka">
            <img src={`${import.meta.env.BASE_URL}gentegre-sembol.svg`} alt="" />
            <span>{baslik}</span>
          </div>
          {/* LOGO VARSA YALNIZ LOGO (kullanıcı 24.10.2026: "loginde profil ve firma adına gerek yok");
              logo yüklenmemiş kurumda kurum adı logonun yerini tutar. */}
          {(kurum.ad || kurum.logo) && (
            <div className="giris-kurum">
              {kurum.logo
                ? <img src={`${TABAN}/api/kimlik/marka/logo`} alt={kurum.ad} onError={e => { (e.target as HTMLImageElement).style.display = 'none' }} />
                : <><span className="giris-kurum-ic">🏥</span><b>{kurum.ad}</b></>}
            </div>
          )}
          <div className="giris-slogan">
            <h2>{c("1990'da başladık,")}<br />{c('ilk günkü heyecanla yenileniyoruz.')}</h2>
            <span>🤖 {c('YZ destekli')}</span>
          </div>
        </aside>
        <div className="giris-sag">{ust}{children}</div>
      </div>
    </div>
  );
}
