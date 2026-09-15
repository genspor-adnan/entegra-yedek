import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { AcikOturum, GirisDenemesi } from '../api/uclar/kimlik';
import type { KullaniciLogSatiri } from '../api/uclar/ayar';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat } from './bicim';
import { cihazAdi } from './cihazAdi';
import { KartKullaniciRolu } from './KartKullaniciRolu';
import { KartKullaniciSubeleri } from './KartKullaniciSubeleri';

/**
 * KULLANICILAR EKRANI › GRİDİN ALTINDAKİ SEKMELER
 * (mockup `Ekranlar/Ayarlar/kullanicilar.html` `.sekmeler` + `.alt`).
 *
 * <b>Seçili satırın ayrıntısı listeyi kaybetmeden görünmeli</b>: yöneticinin
 * işi tek hesapta bitmiyor - "kim kilitli, kimin oturumu açık kalmış" diye
 * satır satır geziliyor. Her satır için kart açıp kapatmak aynı soruyu her
 * seferinde baştan sordururdu.
 *
 * DÖRT SEKME, DÖRT AYRI SORU:
 *  · Roller ve Şubeler → "bu kişi neye yetkili" (kart ile AYNI bileşen, aynı
 *    veri; iki yerde iki ayrı doğru olmasın).
 *  · Açık Oturumlar → "şu an nerede açık" · aile başına tek sayılır.
 *  · Giriş Hareketleri → "girebiliyor mu, deneyen var mı" (başarısızlar dahil).
 *  · İşlem Günlüğü → "bu HESABA ne yapıldı" - kişinin yaptıkları değil.
 *
 * Sekme içerikleri SEÇİLİ SATIR DEĞİŞİNCE yüklenir; ekrana girer girmez dört
 * isteği birden atmak, listeyi gezerken her satırda dört istek demekti.
 */

const SEKMELER = ['Roller ve Şubeler', 'Açık Oturumlar',
                  'Giriş Hareketleri', 'İşlem Günlüğü'] as const;
type Sekme = typeof SEKMELER[number];

/** islem_log.islem_tipi - Delphi ULog kodlarıyla aynı. */
const ISLEM_ADI: Record<number, string> = { 1: 'ekleme', 2: 'değişiklik', 3: 'silme' };

export function KullaniciAltPanel({ kullaniciId, saltOkunur }: {
  kullaniciId: number;
  saltOkunur: boolean;
}) {
  const [sekme, setSekme] = useState<Sekme>('Roller ve Şubeler');
  const [oturumlar, setOturumlar] = useState<AcikOturum[] | null>(null);
  const [gecmis, setGecmis] = useState<GirisDenemesi[] | null>(null);
  const [gunluk, setGunluk] = useState<KullaniciLogSatiri[] | null>(null);
  const [hata, setHata] = useState('');

  // Oturum sayısı SEKME ROZETİNDE durur (mockup): "açık oturum var mı"
  //   sorusunun cevabı sekmeye girmeden görünmeli.
  useEffect(() => {
    let iptal = false;
    setOturumlar(null); setGecmis(null); setGunluk(null); setHata('');
    api.kullaniciOturumlari(kullaniciId)
      .then(o => { if (!iptal) setOturumlar(o) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [kullaniciId]);

  const yukle = useCallback(async () => {
    try {
      if (sekme === 'Giriş Hareketleri' && !gecmis)
        setGecmis(await api.kullaniciGirisGecmisi(kullaniciId));
      if (sekme === 'İşlem Günlüğü' && !gunluk)
        setGunluk(await api.kullaniciIslemGunlugu(kullaniciId));
    } catch (h) { setHata(hataMetni(h)) }
  }, [sekme, kullaniciId, gecmis, gunluk]);

  useEffect(() => { void yukle() }, [yukle]);

  return (
    <div className="altpanel">
      <div className="altpanel-sekmeler">
        {SEKMELER.map(s => (
          <button type="button" key={s}
                  className={`altpanel-sekme${s === sekme ? ' on' : ''}`}
                  onClick={() => setSekme(s)}>
            {s}
            {s === 'Açık Oturumlar' && oturumlar && oturumlar.length > 0 && (
              <span className="rozet mavi">{oturumlar.length}</span>
            )}
          </button>
        ))}
      </div>

      <div className="altpanel-govde">
        {hata && <div className="kauyari">{hata}</div>}

        {/* KART ILE AYNI BILESEN: rol atama iki yerde iki ayri kod olsaydi
            biri duzeltilip oteki unutulurdu. */}
        {sekme === 'Roller ve Şubeler' && (
          <div className="altpanel-iki">
            <KartKullaniciRolu kartId={kullaniciId} saltOkunur={saltOkunur} />
            <KartKullaniciSubeleri kartId={kullaniciId} saltOkunur={saltOkunur} />
          </div>
        )}

        {sekme === 'Açık Oturumlar' && (
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
        )}

        {sekme === 'Giriş Hareketleri' && (
          <table className="grid">
            <thead><tr><th>Zaman</th><th>Sonuç</th><th>IP</th></tr></thead>
            <tbody>
              {!gecmis && <tr><td colSpan={3}>Yükleniyor…</td></tr>}
              {gecmis?.length === 0 && <tr><td colSpan={3} className="bos">Kayıt yok.</td></tr>}
              {/* Başarısız denemeler de görünür: yalnız başarılı girişleri
                  göstermek, birinin denediğini gizlerdi. */}
              {gecmis?.map((g, i) => (
                <tr key={i}>
                  <td>{tarihSaat(g.tarih)}</td>
                  <td>{g.basarili
                        ? <span className="rozet ok">başarılı</span>
                        : <span className="rozet hata">{g.sebep || 'başarısız'}</span>}</td>
                  <td className="sonuk">{g.ip || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {sekme === 'İşlem Günlüğü' && (
          <table className="grid">
            <thead><tr><th>Zaman</th><th>İşlem</th><th>Yapan</th><th>IP</th></tr></thead>
            <tbody>
              {!gunluk && <tr><td colSpan={4}>Yükleniyor…</td></tr>}
              {gunluk?.length === 0 && (
                <tr><td colSpan={4} className="bos">Bu hesaba yapılmış işlem yok.</td></tr>
              )}
              {gunluk?.map((g, i) => (
                <tr key={i}>
                  <td>{tarihSaat(g.tarih)}</td>
                  {/* Serbest açıklama yoksa ham işlem tipi: satır hiç olmazsa
                      "değişiklik oldu" bilgisini vermeli. */}
                  <td>{g.islem || ISLEM_ADI[g.islemTipi] || '—'}</td>
                  <td className="sonuk">{g.kullanici || '—'}</td>
                  <td className="sonuk">{g.ip || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
