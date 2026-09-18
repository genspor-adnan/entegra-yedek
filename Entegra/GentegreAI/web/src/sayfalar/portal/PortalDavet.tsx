import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';

/**
 * PORTAL DAVET SAYFASI (822) — hastanın telefonunda, OTURUMSUZ.
 *
 * Akış: SMS/e-postadaki bağlantı buraya düşer → kişi TCKN'sinin son 4 hanesini
 * ve kendi belirlediği parolayı yazar → hesap açılır → giriş ekranı.
 *
 * <b>İki parçalı doğrulama:</b> bağlantı tek başına yetmez. Yanlış numaraya
 * giden ya da ekran görüntüsü paylaşılan bir SMS, yoksa başkasının sağlık
 * kayıtlarını açardı. Beş yanlış denemede bağlantı kapanır.
 *
 * <b>Sebep söylenmez:</b> "süresi dolmuş" ile "böyle bir bağlantı yok" ayrımı,
 * elindeki jetonun gerçek olup olmadığını söylerdi - tek mesaj.
 */
export function PortalDavet() {
  const { jeton = '' } = useParams();
  const git = useNavigate();

  const [durum, setDurum] = useState<'yukleniyor' | 'gecerli' | 'gecersiz'>('yukleniyor');
  const [kisi, setKisi] = useState('');
  const [son4, setSon4] = useState('');
  const [parola1, setParola1] = useState('');
  const [parola2, setParola2] = useState('');
  const [hata, setHata] = useState('');
  const [kaydediliyor, setKaydediliyor] = useState(false);
  const [bitti, setBitti] = useState<{ kod: string } | null>(null);

  useEffect(() => {
    let iptal = false;
    api.davetDurum(jeton)
      .then(y => {
        if (iptal) return;
        setDurum(y.gecerli ? 'gecerli' : 'gecersiz');
        setKisi(y.kisi ?? '');
      })
      .catch(() => { if (!iptal) setDurum('gecersiz') });
    return () => { iptal = true };
  }, [jeton]);

  async function gonder(e: React.FormEvent) {
    e.preventDefault();
    setHata('');
    if (son4.trim().length !== 4) { setHata('TCKN’nizin son 4 hanesini yazın.'); return }
    if (parola1.length < 6) { setHata('Parola en az 6 karakter olmalı.'); return }
    if (parola1 !== parola2) { setHata('İki parola aynı değil.'); return }

    setKaydediliyor(true);
    try {
      const y = await api.davetKullan(jeton, son4.trim(), parola1);
      setBitti({ kod: y.kod });
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setKaydediliyor(false);
    }
  }

  if (durum === 'yukleniyor')
    return <div className="davet-sayfa"><div className="davet-kart">Yükleniyor…</div></div>;

  if (durum === 'gecersiz')
    return (
      <div className="davet-sayfa">
        <div className="davet-kart">
          <h1>Bağlantı geçersiz</h1>
          <p className="sonuk">
            Bu davet bağlantısı kullanılmış ya da süresi dolmuş olabilir.
            Kurumunuzdan yeni bir davet isteyin.
          </p>
        </div>
      </div>
    );

  if (bitti)
    return (
      <div className="davet-sayfa">
        <div className="davet-kart">
          <h1>Hesabınız açıldı</h1>
          <p>Kullanıcı kodunuz: <b>{bitti.kod}</b></p>
          <p className="sonuk">Belirlediğiniz parolayla giriş yapabilirsiniz.</p>
          <button type="button" className="d bir davet-dugme" onClick={() => git('/')}>
            Giriş ekranına git
          </button>
        </div>
      </div>
    );

  return (
    <div className="davet-sayfa">
      <form className="davet-kart" onSubmit={gonder}>
        <h1>Hasta Portalı</h1>
        {kisi && <p className="sonuk">Sayın {kisi}, hesabınızı burada açabilirsiniz.</p>}

        <label className="alan">
          <span className="etiket">TCKN son 4 hane</span>
          {/* inputMode=numeric: telefonda sayı tuş takımı açılsın. */}
          <input value={son4} onChange={e => setSon4(e.target.value.replace(/\D/g, ''))}
                 inputMode="numeric" maxLength={4} autoComplete="off" />
        </label>

        <label className="alan">
          <span className="etiket">Yeni parola</span>
          <input type="password" value={parola1} onChange={e => setParola1(e.target.value)}
                 autoComplete="new-password" />
        </label>

        <label className="alan">
          <span className="etiket">Parola (tekrar)</span>
          <input type="password" value={parola2} onChange={e => setParola2(e.target.value)}
                 autoComplete="new-password" />
        </label>

        {hata && <div className="hata-kutusu">{hata}</div>}

        <button type="submit" className="d bir davet-dugme" disabled={kaydediliyor}>
          {kaydediliyor ? 'Kaydediliyor…' : 'Hesabımı aç'}
        </button>

        <p className="not kucuk">
          Bu bağlantı bir kez kullanılır. Daveti siz istemediyseniz bağlantıyı kullanmayın.
        </p>
      </form>
    </div>
  );
}
