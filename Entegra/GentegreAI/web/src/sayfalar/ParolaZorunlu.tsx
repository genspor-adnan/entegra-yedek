import { useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni, urunAdi } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';

/**
 * ZORUNLU PAROLA DEĞİŞİMİ (674) — kullanıcı: "ilk giriş şifreleri default
 * personel kartın ID si olsun.. ama ilk girişte değiştirmeye zorlasın".
 *
 * Varsayılan parola kart ID'sidir; ID gizli bir bilgi değildir, bu yüzden
 * parola değil TEK KULLANIMLIK BİR KAPIdır. Ekran uygulamanın ÖNÜNE geçer:
 * `parola_degismeli` bayrağı sürdükçe hiçbir rota çizilmez - "sonra
 * değiştiririm" diyebilen bir kullanıcı o parolayla kalırdı.
 *
 * Çıkış düğmesi durur: kendi hesabı olmayan bir bilgisayarda oturum açan
 * kişi parola belirlemeden de çıkabilmeli.
 */
export function ParolaZorunlu() {
  const { kullanici, tazele, cikisYap } = useOturum();
  const [eski, setEski] = useState('');
  const [yeni1, setYeni1] = useState('');
  const [yeni2, setYeni2] = useState('');
  const [hata, setHata] = useState<string | null>(null);
  const [bekliyor, setBekliyor] = useState(false);

  const PAROLA_KURALI = 'En az 8 karakter; küçük harf, BÜYÜK harf, rakam ve '
                      + 'harf/rakam dışı bir karakter (ör. .!?*-_) içermeli.';

  async function gonder(e: React.FormEvent) {
    e.preventDefault();
    setHata(null);
    if (yeni1 !== yeni2) { setHata('Parolalar aynı değil.'); return }
    if (yeni1 === eski) { setHata('Yeni parola eskisiyle aynı olamaz.'); return }
    setBekliyor(true);
    try {
      await api.parolaDegistir(eski, yeni1);
      // Bayrak sunucuda dustu; /ben tazelenince ekran kendiliginden kapanir.
      await tazele();
    } catch (h) { setHata(hataMetni(h)) }
    finally { setBekliyor(false) }
  }

  return (
    <div className="giris-sayfa">
      <form className="giris-kart" onSubmit={gonder}>
        <div className="giris-marka">
          <img src={`${import.meta.env.BASE_URL}gentegre-sembol.svg`} alt="" />
          <h1>{urunAdi(kullanici?.urunModu)}</h1>
        </div>
        <p className="alt-baslik">İlk giriş — parolanızı değiştirin</p>
        <div className="bilgi-kutusu">
          <b>{kullanici?.ad}</b> · kullanıcı adı <b>{kullanici?.kod}</b>
          <div>
            Hesabınız varsayılan parolayla açıldı (personel kart numaranız).
            Devam etmek için kendi parolanızı belirleyin.
          </div>
        </div>
        <label>
          Mevcut parola
          <input type="password" value={eski} autoFocus autoComplete="current-password"
                 onChange={e => setEski(e.target.value)} />
        </label>
        <label>
          Yeni parola
          <input type="password" value={yeni1} autoComplete="new-password"
                 onChange={e => setYeni1(e.target.value)} />
        </label>
        <label>
          Yeni parola (tekrar)
          <input type="password" value={yeni2} autoComplete="new-password"
                 onChange={e => setYeni2(e.target.value)} />
        </label>
        <p className="sonuk">{PAROLA_KURALI}</p>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <button className="d bir" type="submit" disabled={bekliyor}>
          {bekliyor ? 'Kaydediliyor…' : 'Parolayı Değiştir ve Devam Et'}
        </button>
        <button className="d" type="button" onClick={() => void cikisYap()}>
          Çıkış
        </button>
      </form>
    </div>
  );
}
