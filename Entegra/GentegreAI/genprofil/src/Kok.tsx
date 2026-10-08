import { useCallback, useState } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { tabanAyarla } from '@web/api/cekirdek';
import { OturumSaglayici } from '@web/kimlik/OturumBaglami';
import { MesajKatmani } from '@web/bilesenler/MesajKatmani';
import { adresDeposu, vekilTabani } from './vekil';
import { Giris, type Baglanti } from './Giris';
import { Profil } from './Profil';

/**
 * GENPROFİL — kurum profili bakım aracı.
 *
 * Kullanıcı: *"GenProfil diye yeni proje oluştur, bunun içine kurum-profili'ni
 * al, girişte user/pass/adres bilgilerini al ve bağlandığın sunucunun profilini
 * düzenle kaydet ve çık."*
 *
 * Teknisyen aracı: adres, kullanıcı ve parola tek ekranda girilir; araç kurum
 * profilini açar, kaydeder, çıkar. Profil ekranı ve API istemcisi **web
 * projesinden paylaşılır** (`@web`), kopyalanmaz - iki ayrı kurum profili
 * ekranı iki ayrı davranış demekti.
 *
 * Adres ÖNCE kurulur (`tabanAyarla`): oturum sağlayıcısı mount olduğunda
 * `/ben` çağırıyor; taban belirlenmeden açmak isteği yanlış sunucuya
 * gönderirdi.
 *
 * `key={baglanti.adres}`: sunucu değişince oturum sağlayıcısı ve paylaşılan
 * ekran SIFIRDAN kurulur - eski sunucunun kullanıcısı, profili ve menüsü yeni
 * bağlantıya taşınmasın.
 *
 * MESAJ KATMANI de paylaşılır: dinleyici kurulmazsa `mesaj()` tarayıcının
 * `alert`ine, `onay()` `confirm`e düşüyor - `paraSor()` ise sessizce null
 * dönüyordu, yani profil ekranının bir sorusu hiç sorulmamış sayılırdı.
 */
export function Kok() {
  const [baglanti, setBaglanti] = useState<Baglanti | null>(null);
  const [hata, setHata] = useState('');

  const bagla = useCallback((b: Baglanti) => {
    tabanAyarla(vekilTabani(b.adres));
    adresDeposu.yaz(b.adres);
    setHata('');
    setBaglanti(b);
  }, []);

  const kop = useCallback(() => {
    // ADRES KORUNUR, oturum bırakılır: aynı sunucuya tekrar bağlanmak çoğu
    //   zaman olan iş ve giriş ekranı adresi hatırlıyor. Parola hiç
    //   saklanmadığı için burada bırakılacak bir gizli bilgi yok.
    setBaglanti(null);
  }, []);

  // Giriş tutmadıysa bağlantı ekranına dön ve nedeni göster: adres doğru ama
  //   parola yanlış olabilir, ikisi de aynı formda duruyor.
  const girisHatasi = useCallback((m: string) => { setHata(m); setBaglanti(null) }, []);

  if (!baglanti) return <Giris onBagla={bagla} hata={hata} />;

  return (
    // MemoryRouter: paylaşılan ekranlar `useNavigate` kullanıyor, ama bu araçta
    //   gezinecek bir rota yok - adres çubuğu da kirlenmesin.
    <MemoryRouter key={baglanti.adres}>
      <OturumSaglayici>
        <MesajKatmani />
        <Profil baglanti={baglanti} onKop={kop} onGirisHatasi={girisHatasi} />
      </OturumSaglayici>
    </MemoryRouter>
  );
}
