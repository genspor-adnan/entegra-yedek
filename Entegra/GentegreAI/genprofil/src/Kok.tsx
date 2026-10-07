import { useState } from 'react';
import { MemoryRouter } from 'react-router-dom';
import { tabanAyarla } from '@web/api/cekirdek';
import { OturumSaglayici } from '@web/kimlik/OturumBaglami';
import { adresDeposu, vekilTabani } from './vekil';
import { Giris } from './Giris';
import { Profil } from './Profil';

/**
 * GENPROFİL — kurum profili bakım aracı.
 *
 * Kullanıcı: *"GenProfil diye yeni proje oluştur, bunun içine kurum-profili'ni
 * al, girişte user/pass/adres bilgilerini al ve bağlandığın sunucunun profilini
 * düzenle kaydet ve çık."*
 *
 * Teknisyen aracı: kurumun sunucu adresini, kullanıcı adını ve parolasını
 * girer; ekran kurum profilini açar, kaydeder, çıkar. Profil ekranı ve API
 * istemcisi **web projesinden paylaşılır** (`@web`), kopyalanmaz - iki ayrı
 * kurum profili ekranı iki ayrı davranış demekti.
 *
 * Adres ÖNCE alınır: oturum sağlayıcısı mount olduğunda `/ben` çağırıyor,
 * taban adresi belirlenmeden açmak isteği yanlış sunucuya gönderirdi.
 */
export function Kok() {
  const [adres, setAdres] = useState('');

  const bagla = (a: string) => {
    tabanAyarla(vekilTabani(a));
    adresDeposu.yaz(a);
    setAdres(a);
  };

  const kop = () => {
    // Adresi bırakıp başa dön: "çık" sunucu bağlantısını da bırakmalı.
    adresDeposu.sil();
    setAdres('');
  };

  if (!adres) return <Giris onBagla={bagla} />;
  return (
    // MemoryRouter: paylaşılan ekranlar `useNavigate` kullanıyor, ama bu araçta
    //   gezinecek bir rota yok - adres çubuğu da kirlenmesin.
    <MemoryRouter>
      <OturumSaglayici>
        <Profil adres={adres} onKop={kop} />
      </OturumSaglayici>
    </MemoryRouter>
  );
}
