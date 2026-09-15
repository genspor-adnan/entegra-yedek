import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { AcikOturum, GirisDenemesi } from '../api/uclar/kimlik';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj, onay } from './mesaj';
import { tarihSaat } from './bicim';
import { cihazAdi } from './cihazAdi';

/**
 * KULLANICI KARTI › GÜVENLİK — yöneticinin başkasının hesabında yapabilecekleri.
 * Mockup: `Ekranlar/Ayarlar/kullanicilar.html`.
 *
 * Listedeki satır eylemlerinin aynısı, kartın içinde: kullanıcı kartı açıkken
 * "listeye dönüp satırı seçip sağ tuş" yaptırmak, aynı işi iki kez öğretmek olurdu.
 *
 * ÜÇ EYLEM AYRIDIR, biri ötekinin yerini tutmaz:
 *  · Parola sıfırla → hesap PAROLASIZ duruma döner + oturumlar kapanır.
 *    Yönetici parola YAZMAZ; kişi ilk girişte kendi parolasını koyar.
 *  · Kilidi çöz    → hatalı giriş kilidi. Parolayı bilen ama üç kez yanlış yazan
 *    kişiye parola sıfırlatmak gereksiz bir tur attırır.
 *  · Oturumları kapat → parola DEĞİŞMEDEN cihazlar düşer (işten ayrılan, kayıp cihaz).
 */
export function KullaniciGuvenlik({ kullaniciId, saltOkunur }: {
  kullaniciId: number;
  saltOkunur: boolean;
}) {
  const [oturumlar, setOturumlar] = useState<AcikOturum[] | null>(null);
  const [gecmis, setGecmis] = useState<GirisDenemesi[] | null>(null);
  const [hata, setHata] = useState('');
  const [islemde, setIslemde] = useState(false);

  const yukle = useCallback(async () => {
    try {
      const [o, g] = await Promise.all([
        api.kullaniciOturumlari(kullaniciId),
        api.kullaniciGirisGecmisi(kullaniciId),
      ]);
      setOturumlar(o); setGecmis(g);
    } catch (e) { setHata(hataMetni(e)) }
  }, [kullaniciId]);

  useEffect(() => { void yukle() }, [yukle]);

  const calistir = async (is: () => Promise<{ mesaj: string }>) => {
    setIslemde(true); setHata('');
    try {
      const y = await is();
      mesaj(y.mesaj);
      await yukle();
    } catch (e) { setHata(hataMetni(e)) } finally { setIslemde(false) }
  };

  const parolaSifirla = async () => {
    // ONAY ŞART: sıfırlama kişinin oturumlarını da kapatır - yanlış kartta
    //   basıldığında kişi çalışamaz hale gelir.
    if (!await onay('Parola sıfırlansın mı?\n\n'
      + 'Hesap PAROLASIZ duruma alınır ve tüm oturumları kapanır. '
      + 'Kişi ilk girişte kimliğini doğrulayıp kendi parolasını belirler.')) return;
    await guvenli(() => calistir(() => api.kullaniciParolaSifirla(kullaniciId)));
  };

  const oturumKapat = async () => {
    if (!await onay('Açık oturumların hepsi kapatılsın mı?\n\n'
      + 'Parola DEĞİŞMEZ; kişi yeniden giriş yapabilir.')) return;
    await guvenli(() => calistir(() => api.kullaniciOturumKapat(kullaniciId)));
  };

  return (
    <div className="kagrup">
      <h6>Güvenlik <span>yönetici işlemleri · hepsi işlem günlüğüne yazılır</span></h6>

      <div className="ka-dugmeler" style={{ justifyContent: 'flex-start', gap: 8, padding: 10 }}>
        <button className="d" disabled={saltOkunur || islemde} onClick={() => void parolaSifirla()}>
          🔑 Parola Sıfırla
        </button>
        <button className="d" disabled={saltOkunur || islemde}
                onClick={() => void guvenli(() => calistir(() => api.kullaniciKilitCoz(kullaniciId)))}>
          🔓 Kilidi Çöz
        </button>
        <button className="d" disabled={saltOkunur || islemde} onClick={() => void oturumKapat()}>
          ⎋ Oturumları Kapat
        </button>
      </div>
      <div className="kanot">
        Parola burada <b>yazılmaz</b>: sıfırlama hesabı parolasız duruma alır, kişi ilk
        girişte kendi parolasını belirler. Yöneticinin belirlediği parola, kâğıda yazılan
        ya da telefonda söylenen paroladır.
      </div>

      <h6 style={{ marginTop: 4 }}>Açık Oturumlar
        <span>{oturumlar ? `${oturumlar.length} cihaz` : ''}</span></h6>
      <table className="grid">
        <thead><tr><th>Cihaz</th><th>IP</th><th>Şube</th><th>Son kullanım</th></tr></thead>
        <tbody>
          {!oturumlar && <tr><td colSpan={4}>Yükleniyor…</td></tr>}
          {oturumlar?.length === 0 && (
            <tr><td colSpan={4} className="bos">Açık oturum yok.</td></tr>
          )}
          {oturumlar?.map(o => (
            <tr key={o.id}>
              <td>{cihazAdi(o.istemci)}</td>
              <td className="sonuk">{o.ip || '—'}</td>
              <td className="sonuk">{o.sube || '—'}</td>
              <td className="sonuk">{tarihSaat(o.sonKullanim)}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <h6 style={{ marginTop: 4 }}>Son Giriş Hareketleri</h6>
      <table className="grid">
        <thead><tr><th>Zaman</th><th>Sonuç</th><th>IP</th></tr></thead>
        <tbody>
          {!gecmis && <tr><td colSpan={3}>Yükleniyor…</td></tr>}
          {gecmis?.length === 0 && <tr><td colSpan={3} className="bos">Kayıt yok.</td></tr>}
          {gecmis?.map((g, i) => (
            <tr key={i}>
              <td>{tarihSaat(g.tarih)}</td>
              {/* Başarısız denemeler de görünür: yalnız başarılı girişleri
                  göstermek, birinin denediğini gizlerdi. */}
              <td>{g.basarili
                    ? <span className="rozet ok">başarılı</span>
                    : <span className="rozet hata">{g.sebep || 'başarısız'}</span>}</td>
              <td className="sonuk">{g.ip || '—'}</td>
            </tr>
          ))}
        </tbody>
      </table>

      {hata && <div className="kauyari">{hata}</div>}
    </div>
  );
}
