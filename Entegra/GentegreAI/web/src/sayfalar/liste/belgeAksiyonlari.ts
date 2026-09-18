import { api } from '../../api/istemci';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';
import type { UtsBelgeBildirimYaniti } from '../../api/istemci';

/**
 * BELGE VE KART AKSIYONLARI (belge · cari · aday · stok · hesap).
 *
 * `Liste.tsx` icindeki `aksiyon()` govdesinden konu bazli ayrildi (ÜTS/kasa
 * ile ayni desen): belge acma-silme-donusumu, mukellefiyet sorgusu, aday
 * donusumu, stok kopyalama ve hesap ekstresi. Ekran state'ine dokunan isler
 * BAGLAM nesnesiyle gelir.
 *
 * Donus: aksiyon burada ele alindiysa true.
 */
export interface BelgeBaglam {
  tazele(): void;
  git(yol: string): void;
  /** Kaydin kendi kart rotasina gider (tanim.kartYolu tabanli). */
  kartaGit(kayitId: unknown): void;
  /** Belge karti MODAL acilir - listenin rotasi degismez. */
  setAcikBelgeId(id: number): void;
  /** "Yeni" belge: kart tur seridi bu grubun turleriyle acilir. */
  setYeniBelgeTuru(tur: number): void;
  setDonusum(d: { belgeId: number; belgeTur: number; hedef?: number }): void;
  /** ÜTS belge koprusu sonucu (226): satir satir verme/alma raporu. */
  setUtsBelgeSonuc(sonuc: UtsBelgeBildirimYaniti): void;
  /** Liste tanimindaki varsayilan belge turu ("Yeni" bunu acar). */
  varsayilanBelgeTuru?: number;
}

export async function belgeAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  secililer: ListeSatiri[] | undefined,
  b: BelgeBaglam,
): Promise<boolean> {
  // DONUSUM ALT MENUSU: "belge.donustur.15" gibi kodlarda hedef tur kodun
  //   icinde gelir ve karta KILITLI gecer.
  if (kod.startsWith('belge.donustur.') && satir) {
    b.setDonusum({
      belgeId: Number(satir.id),
      belgeTur: Number(satir.tur),
      hedef: Number(kod.slice('belge.donustur.'.length)),
    });
    return true;
  }

  switch (kod) {
    // ------------------------------------------- KULLANICI YONETIMI (Guvenlik)
    // Hepsi tek satir uzerinde calisir ve ISLEMLOG'a yazilir. Yetki kontrolu
    //   sunucuda: burada yalniz onay + mesaj.
    case 'kullanici.parola-sifirla': {
      if (!satir) return true;
      const kim = String(satir.kisi || satir.kod || '');
      // ONAY SART: sifirlama kisinin oturumlarini da kapatir - yanlis satirda
      //   basildiginda kisi calisamaz hale gelir.
      if (!await onay(`${kim}: parola sıfırlansın mı?

`
        + 'Hesap parolasız duruma alınır ve TÜM oturumları kapanır. '
        + 'Kişi ilk girişte kimliğini doğrulayıp kendi parolasını belirler.')) return true;
      await guvenli(async () => {
        const y = await api.kullaniciParolaSifirla(Number(satir.id));
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'kullanici.kilit-coz': {
      if (!satir) return true;
      await guvenli(async () => {
        const y = await api.kullaniciKilitCoz(Number(satir.id));
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'kullanici.oturum-kapat': {
      if (!satir) return true;
      const kim = String(satir.kisi || satir.kod || '');
      if (!await onay(`${kim}: açık oturumların hepsi kapatılsın mı?

`
        + 'Parola DEĞİŞMEZ; kişi yeniden giriş yapabilir.')) return true;
      await guvenli(async () => {
        const y = await api.kullaniciOturumKapat(Number(satir.id));
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'kullanici.durum': {
      if (!satir) return true;
      const aktif = Number(satir.aktif) === 1;
      const kim = String(satir.kisi || satir.kod || '');
      // HESAP SILINMEZ, pasife alinir: log ve belge satirlari kullaniciya bagli.
      if (!await onay(aktif
        ? `${kim}: hesap pasife alınsın mı?

Giriş yapamaz, açık oturumları kapanır. `
          + 'Kayıtları ve geçmişi silinmez.'
        : `${kim}: hesap yeniden aktif edilsin mi?`)) return true;
      await guvenli(async () => {
        const y = await api.kullaniciDurum(Number(satir.id), !aktif);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    // PORTAL ERISIMI (819): dis hekim / kurum / hasta. Uc karttan da ayni
    //   aksiyon cagrilir; portal TURU kaydin ne oldugundan cikar - kullaniciya
    //   "bu kisi hasta mi hekim mi" diye sormak, zaten kartta yazan seyi
    //   ikinci kez sormak olurdu.
    case 'kullanici.portal': {
      if (!satir) return true;
      const tarafId = Number(satir.id);
      const kim = String(satir.unvan || satir.ad || satir.kod || '');

      await guvenli(async () => {
        const d = await api.portalHesapDurum(tarafId);
        if (d.mevcutKod) {
          mesaj(`${kim}: zaten "${d.mevcutKod}" kodlu bir hesabı var`
                + `${d.mevcutRol ? ` (${d.mevcutRol})` : ''}. `
                + 'Rolü Kullanıcılar ekranından değiştirin.');
          return;
        }

        // TUR KAYITTAN: hasta kartı hasta portalı, dış hekim kartı hekim
        //   portalı, cari/kişi kartı kurum portalı açar.
        const turler: { kod: string; ad: string }[] = [];
        if (d.disHekim === 1) turler.push({ kod: '1', ad: 'Hekim portalı (kendi istemleri)' });
        if (d.hasta === 1) turler.push({ kod: '3', ad: 'Hasta portalı (kendi kayıtları)' });
        if (d.kisi === 1 || d.musteri === 1)
          turler.push({ kod: '2', ad: 'Kurum portalı (bir kurumun işleri)' });
        if (turler.length === 0) {
          mesaj(`${kim}: bu kayda portal erişimi verilemez `
                + '(dış hekim, hasta ya da kişi/cari kartı olmalı).');
          return;
        }

        const tur = turler.length === 1 ? turler[0].kod
          : await listeSor('Hangi portal?', turler, turler[0].kod, 'Portal');
        if (!tur) return;

        // KURUM PORTALI KISI BASI: hesap kişiye açılır, kapsam KURUMA bağlanır.
        //   Hangi kurumun işlerini göreceği açıkça sorulur.
        let kurumId: number | undefined;
        if (tur === '2') {
          // VARSAYILAN BAĞLI KURUM (309): kişi kartındaki "Bağlı Kurum" zaten
          //   bu bilgiyi taşıyor - kullanıcıya kart numarası yazdırmak,
          //   kayıtlı olanı ikinci kez sormak olurdu.
          const varsayilan = d.bagliKurumId ?? (d.musteri === 1 ? d.id : 0);
          const kurumKodu = await metinSor(
            d.bagliKurumAdi
              ? `Bu hesap hangi kurumun işlerini görecek? (Bağlı kurum: ${d.bagliKurumAdi})`
              : 'Bu hesap hangi kurumun işlerini görecek?',
            varsayilan ? String(varsayilan) : '', 'Kurum (cari) kayıt numarası');
          if (!kurumKodu) return;
          kurumId = Number(kurumKodu);
          if (!kurumId) { mesaj('Geçerli bir cari kayıt numarası girin.'); return }
        }

        // ROL SORULUR, TAHMİN EDİLMEZ (824): kurum portalında iki rol var -
        //   Klinik hasta/lab ekranı görür, Yönetici yalnız fatura ve ekstre.
        //   Sunucu "ilk rolü" seçseydi muhasebeciye tıbbi ekran açılırdı.
        //   Tek rollü portal türünde soru sorulmaz.
        const rolSecenek = (d.roller ?? []).filter(r => r.portalTuru === Number(tur));
        let rolKodu: string | undefined;
        if (rolSecenek.length > 1) {
          const secim = await listeSor(
            'Bu hesap hangi rolde açılsın?',
            rolSecenek.map(r => ({ kod: r.kod, ad: r.ad })),
            rolSecenek[0].kod, 'Rol');
          if (!secim) return;
          rolKodu = secim;
        } else if (rolSecenek.length === 1) rolKodu = rolSecenek[0].kod;

        const kod = await metinSor(
          'Giriş kodu (boş bırakılırsa TCKN/VKN kullanılır):',
          d.vkno ?? '', 'Giriş kodu');
        if (kod === null) return;

        const y = await api.portalHesapAc({
          tarafId, portalTuru: Number(tur), kod: kod.trim() || undefined, kurumId,
          rolKodu,
        });
        b.tazele();
        // PAROLA YOK: yonetici parola yazmaz, kisi ilk giriste kendi koyar.
        mesaj(y.mesaj);
      });
      return true;
    }

    // TOPLU PORTAL ROLU (819): gocle gelen dis hekimlerin rolu "Rol
    //   Atanmamis" kaliyor; tek tek kart acmak 20+ islem demekti.
    case 'kullanici.portal-toplu': {
      if (!await onay('Hesabı olan tüm dış hekimlere "Dış Doktor (portal)" rolü '
        + 'atansın mı?\n\nYetkili bir iç rolü olan hesaplar ATLANIR.')) return true;
      await guvenli(async () => {
        const y = await api.portalTopluRol(1);
        b.tazele();
        // ATLANANLAR SAYIYLA DEGIL ADIYLA: "3 atlandi" demek, hangisine
        //   bakilacagini soylemez.
        mesaj(y.mesaj + (y.atlanan.length > 0
          ? ` Atlananlar: ${y.atlanan.map(a => a.unvan).join(', ')}`
          : ''));
      });
      return true;
    }

    // PORTAL DAVETI (822): baglanti KISIYE gider, hesabini kendi acar.
    case 'kullanici.portal-davet': {
      if (!satir) return true;
      const tarafId = Number(satir.id);
      const kim = String(satir.unvan || satir.ad || '');

      const kanal = await listeSor('Davet nasıl gönderilsin?',
        [{ kod: '1', ad: 'SMS' }, { kod: '2', ad: 'E-posta' }], '1', 'Kanal');
      if (!kanal) return true;

      // ALICI BOS BIRAKILABILIR: karttaki cep/e-posta kullanilir.
      const alici = await metinSor(
        kanal === '1'
          ? 'Numara (boş bırakılırsa karttaki cep telefonu):'
          : 'E-posta (boş bırakılırsa karttaki adres):',
        '', kanal === '1' ? 'Numara (905XXXXXXXXX)' : 'E-posta');
      if (alici === null) return true;

      if (!await onay(`${kim} kişisine portal daveti gönderilsin mi?

`
        + 'Tek kullanımlık bir bağlantı gider; kişi TCKN’sinin son 4 hanesiyle '
        + 'doğrulanıp kendi parolasını belirler.')) return true;

      await guvenli(async () => {
        const y = await api.portalDavetGonder({
          tarafId, kanal: Number(kanal), alici: alici.trim() || undefined,
        });
        b.tazele();
        mesaj(y.mesaj);
      });
      return true;
    }

    case 'kullanici.toplu-ac': {
      if (!await onay('Hesabı olmayan aktif personele hesap açılsın mı?\n\n'
        + 'Hesaplar PAROLASIZ açılır; kişiler ilk girişte kendi parolalarını belirler.'))
        return true;
      await guvenli(async () => {
        const y = await api.kullaniciTopluAc();
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    // Grup basina bir giris: kart tur seridini o grubun turleriyle acar.
    case 'belge.yeni':
      b.setYeniBelgeTuru(b.varsayilanBelgeTuru ?? 15);
      return true;

    case 'belge.ac':
      if (satir) b.setAcikBelgeId(Number(satir.id));
      return true;

    // MUHASEBE FISI (190): belgenin fis satirlarini acar. Fis kartı ayri bir
    //   ekran degil - "Fiş Satırları" listesi fisId ile filtrelenir.
    case 'belge.fis-gor': {
      if (!satir) return true;
      const fisId = Number(satir.fisId ?? 0);
      if (!fisId) { mesaj('Belgenin muhasebe fişi yok.'); return true }
      b.git(`/muhasebe-fis-satir?fisId=${fisId}`);
      return true;
    }

    // DONUSUM ZINCIRI (F8): kaynak ve hedef belge ayni modal kartta acilir.
    case 'belge.kaynak-ac':
    case 'belge.hedef-ac': {
      if (!satir) return true;
      const hedef = Number(kod === 'belge.kaynak-ac' ? satir.kaynakId : satir.hedefId) || 0;
      if (!hedef) {
        mesaj(kod === 'belge.kaynak-ac'
          ? 'Bu belge bir dönüşümden gelmiyor.'
          : 'Bu belgeden üretilmiş bir belge yok.');
        return true;
      }
      b.setAcikBelgeId(hedef);
      return true;
    }

    // BELGE SIL (181): izi olmayan belgede mumkun; kesin/izli belgede aksiyon
    //   zaten pasif ve sebebi title'da. Sunucu son sozu soyler.
    case 'belge.sil': {
      if (!satir) return true;
      const no = String(satir.belgeNo ?? satir.id);
      if (!await onay(`"${no}" silinecek.

Bu işlem geri alınamaz. `
                    + 'Onaylıyor musunuz?', true)) return true;
      await guvenli(async () => {
        const y = await api.belgeSil(Number(satir.id));
        mesaj(y.mesaj || 'Belge silindi.');
        b.tazele();
      });
      return true;
    }

    // CARI MUKELLEFIYET SORGUSU (183): entegratore sorar, bayragi isler.
    //   Gelen unvan/adres YALNIZ GOSTERILIR - musterinin kendi kaydi
    //   entegratorun yazimiyla ezilmemeli.
    case 'cari.ebelge-mukellef': {
      if (!satir) return true;
      await guvenli(async () => {
        const y = await api.cariEBelgeMukellef(Number(satir.id));
        const satirlar = [
          String(y.kayitli.unvan || satir.unvan || ''),
          '',
          'GİB kaydı: ' + (y.mukellef
            ? 'e-Fatura MÜKELLEFİ' : 'kayıtlı değil (e-Arşiv kesilir)') + ' — ' + y.durum,
        ];
        if (y.degisti) satirlar.push('Cari kartındaki bayrak güncellendi.');
        // GIB'den gelen unvan/adres YALNIZ GOSTERILIR: musterinin kendi
        //   kaydi entegratorun yazimiyla ezilmemeli.
        if (y.gelen.unvan) {
          satirlar.push('', 'GİB’deki bilgiler:', y.gelen.unvan);
          if (y.gelen.vergiDairesi) satirlar.push(y.gelen.vergiDairesi);
          if (y.gelen.il) satirlar.push(`${y.gelen.adres} ${y.gelen.ilce} / ${y.gelen.il}`);
        }
        mesaj(satirlar.join('\n'));
        b.tazele();
      });
      return true;
    }

    case 'belge.donustur':
      if (!satir) return true;
      // Teklif (18) yalniz KABUL (3) durumundayken donusur - sunucu da ayni
      //   kurali dogrular, burasi erken/anlasilir uyari.
      if (Number(satir.tur) === 18 && Number(satir.teklifDurum ?? 1) !== 3) {
        mesaj('Teklif yalnız KABUL durumundayken siparişe dönüştürülebilir.');
        return true;
      }
      b.setDonusum({ belgeId: Number(satir.id), belgeTur: Number(satir.tur) });
      return true;

    // Secili hesabin ekstresi - ayni ekran, hesapId sorgu parametresiyle.
    case 'hesap.ekstre':
      if (satir) b.git(`/hesap-ekstre?hesapId=${satir.id}`);
      return true;

    // ADAY -> MÜŞTERİ (122): kayit TASINMAZ, yalniz rol bayragi degisir.
    //   Boylece firsat/gorev/adres/ilgili kisi gecmisi ayni kayitta kalir;
    //   yeni bir cari acilsaydi butun bu baglar kirilirdi.
    case 'aday.donustur': {
      if (!satir) return true;
      const ad = String(satir.unvan ?? satir.ad ?? satir.id);
      if (!await onay(`"${ad}" müşteriye dönüştürülsün mü?

` +
                   "Kayıt Müşteri Listesi'ne geçer; fırsat, görev ve adres geçmişi aynı kalır.")) return true;
      void guvenli(async () => {
        const k = await api.kartOku('cari', Number(satir.id));
        await api.kartGuncelle('cari', Number(satir.id),
          { surum: k.kart.surum as string | undefined,
            kart: { musteri: true, aday: false } });
        b.tazele();
      });
      return true;
    }

    // STOK KARTI KOPYALA (126): kopya olusur ve HEMEN acilir - kullanici
    //   zaten degistirmek icin kopyaliyor, listeye donup aramasi gereksiz.
    case 'stok.kopyala': {
      if (!satir) return true;
      const ad = String(satir.ad ?? satir.kod ?? satir.id);
      if (!await onay(`"${ad}" kartı kopyalanacak.\n\n`
                 + 'Kod sonuna "_K1", ad sonuna " kopya" eklenir; paket ise içeriği de kopyalanır.\n'
                 + 'Fiyat ve barkod kopyalanmaz.')) return true;
      const yeniId = await api.stokKopyala(Number(satir.id));
      b.tazele();
      b.kartaGit(yeniId);
      return true;
    }

    // ÜTS (223): belgenin seri/lot satirlari verme/alma olarak bildirilir.
    case 'belge.uts-bildir': {
      // COKLU SECIM desteklenir (230): isaretli belgeler sirayla bildirilir.
      const hedefler = (secililer && secililer.length > 0 ? secililer
                        : satir ? [satir] : []);
      if (hedefler.length === 0) return true;
      const adlar = hedefler.length === 1
        ? `"${String(hedefler[0].belgeNo ?? hedefler[0].id)}" belgesinin`
        : `${hedefler.length} belgenin`;
      if (!await onay(`${adlar} seri/lot satırları ÜTS'ye bildirilecek.

Satışta VERME, alışta askıdakilerle eşleşip ALMA yapılır. Onaylıyor musunuz?`)) return true;
      await guvenli(async () => {
        let son: UtsBelgeBildirimYaniti | null = null;
        const ozet: string[] = [];
        for (const h of hedefler) {
          son = await api.utsBelgedenBildir(Number(h.id));
          ozet.push(son.mesaj);
        }
        if (hedefler.length === 1 && son) b.setUtsBelgeSonuc(son);
        else mesaj(ozet.join('\n'));
        b.tazele();
      });
      return true;
    }

    default:
      return false;
  }
}

/**
 * TOPLU e-BELGE (183): birden fazla satir seciliyken Hazırla/Gönder tek
 * istekte calisir. Sonuc satir satir raporlanir - bir belgenin hatasi
 * digerlerini durdurmaz.
 *
 * `aksiyon()` icinde EN BASTA denenir: gelen kutusu ve e-Belge ciktilari ayni
 * "ebelge.*" kodlarini kullaniyor, toplu secim onlardan once yakalanmali.
 */
export async function ebelgeTopluAksiyonu(
  kod: string,
  secililer: ListeSatiri[] | undefined,
  b: { tazele(): void },
): Promise<boolean> {
  if (!secililer || secililer.length <= 1) return false;
  if (kod !== 'ebelge.hazirla' && kod !== 'ebelge.gonder') return false;

  const islem = kod === 'ebelge.hazirla' ? 'hazirla' : 'gonder';
  const ad = islem === 'hazirla' ? 'hazırlanacak' : 'GÖNDERİLECEK';
  if (!await onay(`${secililer.length} belge ${ad}.\n\n`
                + (islem === 'gonder'
                   ? 'Gönderilen belge geri alınamaz. Onaylıyor musunuz?'
                   : 'Her belgeye seri ve e-Belge numarası verilir. Onaylıyor musunuz?'),
                  islem === 'gonder')) return true;
  await guvenli(async () => {
    const y = await api.belgeEBelgeToplu(secililer.map(x => Number(x.id)), islem);
    const olan = y.sonuclar.filter(r => r.basarili).length;
    const olmayan = y.sonuclar.filter(r => !r.basarili);
    mesaj(`${olan} belge tamam, ${olmayan.length} hata.`
        + (olmayan.length
           ? '\n\n' + olmayan.slice(0, 10)
               .map(r => `#${r.belgeId}: ${r.mesaj}`).join('\n')
             + (olmayan.length > 10 ? `\n… ve ${olmayan.length - 10} tane daha` : '')
           : ''));
    b.tazele();
  });
  return true;
}
