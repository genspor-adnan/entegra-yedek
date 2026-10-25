import { useState } from 'react';
import { AyarSekmeSeridi } from '../bilesenler/AyarSekmeSeridi';
import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';
import { NumaralamaSekmesi } from '../bilesenler/NumaralamaSekmesi';
import { BelgeYaziSekmesi } from '../bilesenler/BelgeYaziSekmesi';
import { useOturum } from '../kimlik/OturumBaglami';
import { c } from '../dil/ceviri';

const SEKMELER = [
  // Guvenlik 2. sirada (kullanici). ENTEGRASYON sekmesi kalkti (22.10.2026): hesaplar bagimsiz
  //   liste / kart ekraninda - Yonetim › Entegrasyonlar (/entegrasyon-hesap).
  { anahtar: 'genel',       baslik: 'Genel' },
  { anahtar: 'guvenlik',    baslik: 'Güvenlik' },
  { anahtar: 'numaralama',  baslik: 'Belge No' },
  // Belge No'nun SAGINDA (768): ikisi de "belge nasil ciksin" ayari -
  //   biri numarayi, oteki metni belirler.
  { anahtar: 'belge-yazisi', baslik: 'Belge Yazıları' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/**
 * Genel Ayarlar (Yönetim › Ayarlar › Genel) — firma geneli DAVRANIS ayarlari.
 *
 * Ayarlar `public.referans` tablosunda ve sunucuda BEYAZ LISTE ile korunuyor
 * (AyarDeposu). Alan cizimi/kayit AyarAlani'nda ortak: etiket ustte, "?" ikonu
 * saginda, kayit aninda.
 *
 * ENTEGRASYON HESAPLARI artik burada degil: bagimsiz liste / kart ekrani
 * (Yonetim › Entegrasyonlar, listeTanimlari.Yonetim - 22.10.2026).
 */
export function GenelAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = useAyarlar();
  const { yetki } = useOturum();

  // Belge yazisi sablonlari IK yetkisine bagli: satis kullanicisi personel
  //   yazisi sablonunu duzenlememeli.
  const sekmeler = SEKMELER.filter(s => s.anahtar !== 'belge-yazisi' || yetki('ik.belge_talep'));

  const alan = (anahtar: string, etiket: string,
                ek?: Partial<Parameters<typeof AyarAlani>[0]>) => (
    <AyarAlani anahtar={anahtar} etiket={etiket} ayarlar={ayarlar} onYaz={yaz} {...ek} />
  );

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Genel Ayarlar</h1>
          <span className="yol">{c('Yönetim › Ayarlar › Genel')}</span>
        </div>
      </div>

      <AyarSekmeSeridi sekmeler={sekmeler} aktif={aktif} onSec={a => setAktif(a as typeof aktif)} />

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : aktif === 'genel' ? (
          <>
            <div className="kagrup">
              <h6>Genel</h6>
              {/* Doviz combosu Belge Girisi editiyle ayni olcude (160px - tema
                  .ayar-formu select kurali); kod listesi genel.doviz, ETIKETE
                  tiklaninca jenerik modalda yonetilir. */}
              <div className="alan-izgara ayar-formu ayar-yanyana">
                {/* ÜRÜN MODU BURADAN KALDIRILDI (kullanıcı 07.10.2026): ürünün
                    ERP mi HBYS mi olduğu KURULUM kararıdır - kurum tipiyle
                    birlikte Kurum Profili'nde (ve GenProfil aracında) set
                    edilir. Günlük ayar ekranında durması, menüyü ve markayı tek
                    tıkla değiştirebilen bir düğmeyi herkesin önüne koymaktı.
                    Ayarın kendisi (`genel.urun_modu`) yerinde; yalnız bu ekranda
                    çizilmiyor. */}
                {alan('genel.varsayilan_doviz', 'Döviz', { listeKod: 'genel.doviz' })}
                {/* YEREL PARA BIRIMI ve SAAT FARKI BURADAN KALDIRILDI (666/667).
                    Ikisi de artik SUBENIN ayari: Yönetim > Firma Bilgileri >
                    Adres > Yerel Ayarlar. Kurum geneline koymak, yurt disinda
                    subesi olan kurumda "hangisini yazayim" ikilemi yaratiyordu.
                    Saat farki ayrica ARTIK GEREKSIZ: zaman damgalari timestamptz
                    (667), gosterim subenin saat diliminde yapiliyor - elle
                    girilen bir kayma yaz saatinde yilda iki kez yanlis olurdu. */}
                <div className="kanot">
                  Yerel para birimi ve saat dilimi <b>şube ayarıdır</b>:
                  Yönetim › Firma Bilgileri › Yerel Ayarlar.
                </div>
              </div>
            </div>

            <div className="kagrup">
              <h6>{c('Belge Girişi')}</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('belge.geri_gun_siniri', 'Belgeler geriye dönük kaç güne kadar girilebilir')}
              </div>
            </div>

            <div className="kagrup">
              <h6>{c('Listeler')}</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('liste.sayfa_boyu', 'Sayfa boyu (bir sayfadaki kayıt sayısı)')}
              </div>
            </div>

            {/* SATINALMA (724/729/732). Bu ayarlar OLMADAN akış uçları kendi
                varsayılanlarına düşer ve kritik stok işi hiç çalışmaz - kapının
                nerede olduğu görünsün diye buraya konuldu.

                ONAY EŞİKLERİ BOŞ BIRAKILABİLİR: boşsa uç kendi varsayılanını
                kullanır (0 / 50.000 / 250.000) ve o varsayılanın gerekçesi
                kuralın yanında durur (db/729). */}
            <div className="kagrup">
              <h6>{c('Satınalma')}</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('satinalma.esik_satinalma',
                      'Satınalma birimi onayı için alt tutar (boş = her talepte)')}
                {alan('satinalma.esik_mali',
                      'Mali işler onayı için alt tutar (boş = 50.000)')}
                {alan('satinalma.esik_ust',
                      'Üst yönetim onayı için alt tutar (boş = 250.000)')}
                {alan('satinalma.sozlu_onay_saat',
                      'Sözlü onayın yazılı tamamlanma süresi, saat (boş = 24)')}
                {alan('satinalma.eslestirme_tolerans_kurus',
                      'Fatura eşleştirmesinde yok sayılacak fark, kuruş (boş = 100)')}
              </div>
            </div>

            {/* KRİTİK STOK VARSAYILAN KAPALI: kurumun istemediği halde
                kendiliğinden satınalma talebi açmak, para harcanan bir süreci
                habersiz başlatmak olurdu. Açılınca saatlik iş çalışır ve depo
                başına TEK taslak talep açar (onaya insan gönderir). */}
            <div className="kagrup">
              <h6>{c('Kritik Stok → Satınalma Talebi')}</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('satinalma.kritik_stok_aktif',
                      'Asgari stoğun altına düşen kalemler için otomatik talep açılsın',
                      { tip: 'mantik' })}
                {alan('satinalma.kritik_hedef_kat',
                      'Azami stok tanımsızsa hedef = asgari × bu kat (boş = 2)')}
                {alan('satinalma.kritik_departman',
                      'Otomatik talebin açılacağı birim no (boş = birimsiz taslak)')}
                {alan('satinalma.kritik_isteyen',
                      'Otomatik talepte "isteyen" personel no (boş = yazılmaz)')}
              </div>
            </div>

            {/* İCMAL EŞİKLERİ (1176, kararlar 25.10.2026): icmaller rakamı sunucuda
                hesaplar; buradaki değerler yalnız rozet / renk eşiğidir. Boş = parantezdeki
                varsayılan. Aşama hedefi boşsa Satınalma Süreç İcmali hedef sütununu boş bırakır. */}
            <div className="kagrup">
              <h6>İcmal Eşikleri</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('satis.hedef_marj', 'Kârlılık: hedef marj, % — altı sarı rozet (boş = 15)')}
                {alan('muhasebe.babs_sinir', 'KDV: Ba / Bs bildirim sınırı, TL (boş = 5.000)')}
                {alan('satinalma.hedef_gun_onay', 'Satınalma: talep onayı hedef süresi, gün (boş = hedef yok)')}
                {alan('satinalma.hedef_gun_teklif', 'Satınalma: teklif hedef süresi, gün (boş = hedef yok)')}
                {alan('satinalma.hedef_gun_siparis', 'Satınalma: siparişe dönüş hedef süresi, gün (boş = hedef yok)')}
                {alan('satinalma.hedef_gun_kabul', 'Satınalma: mal kabul hedef süresi, gün (boş = hedef yok)')}
                {alan('satinalma.hedef_gun_odeme', 'Satınalma: ödeme hedef süresi, gün (boş = hedef yok)')}
                {alan('servis.tekrar_ariza_gun', 'Teknik servis: tekrar arıza sayılan süre, gün (boş = 30)')}
                {alan('uretim.sapma_maliyet_yuzde', 'Üretim: maliyet sapması eşiği, ± % (boş = 5)')}
                {alan('uretim.sapma_sarf_yuzde', 'Üretim: sarf farkı eşiği, ± % (boş = 5)')}
                {alan('uretim.fire_hedef_kat', 'Üretim: fire eşiği, ürün ağacı hedefinin katı (boş = 1,5)')}
                {alan('masraf.artis_esik_yuzde', 'Masraf: olağan dışı artış eşiği, son 3 ay / önceki 6 ay, % (boş = 25)')}
                {alan('masraf.mukerrer_gun', 'Masraf: mükerrer şüphesi, aynı cari + tutar ± gün (boş = 1)')}
                {alan('satis.limit_davranis', 'Satış: risk limiti aşımında belge — "uyar" ya da "engelle" (boş = uyar)')}
                {alan('banka.mutabakat_tolerans_kurus', 'Banka mutabakat: eşleştirme toleransı, kuruş (boş = 0)')}
                {alan('banka.mutabakat_dort_goz', 'Banka mutabakat: onaylayan hazırlayandan farklı olmalı', { tip: 'mantik' })}
              </div>
            </div>

            {/* DEPOLAR (729): eczanenin ve teknik servisin kendi deposu vardır;
                genel depodan düşmek iki birimin sayımını da bozar. Boşsa uç
                kurumun varsayılan deposuna düşer. */}
            <div className="kagrup">
              <h6>Depolar</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('eczane.depo',
                      'Eczane giriş/çıkış fişlerinin deposu (boş = varsayılan depo)')}
                {alan('demirbas.parca_depo',
                      'Teknik servis parça çıkışının deposu (boş = varsayılan depo)')}
              </div>
            </div>
          </>
        ) : aktif === 'numaralama' ? (
          // Belge / tahsilat / odeme numaralandirmasi (152) - dort grid.
          <NumaralamaSekmesi />
        ) : aktif === 'belge-yazisi' ? (
          // Belge talebinde uretilen resmi yazinin sablonlari (768).
          <BelgeYaziSekmesi />
        ) : (
          <>
            <div className="kagrup">
              <h6>Oturum</h6>
              <div className="alan-izgara ayar-formu">
                {alan('guvenlik.jwt_dakika', 'Oturum süresi (dakika)')}
                {alan('guvenlik.refresh_gun', 'Oturumu açık tutma (gün)')}
                {/* Etiket KISA: uzun cumle satiri dagitiyordu, ayrinti "?" ikonunda. */}
                {alan('guvenlik.tek_oturum', 'Tek oturum', { tip: 'mantik' })}
              </div>
            </div>

            <div className="kagrup">
              <h6>{c('Parola ve Kilit')}</h6>
              <div className="alan-izgara ayar-formu">
                {alan('guvenlik.parola_min_uzunluk', 'En az parola uzunluğu')}
                {alan('guvenlik.hatali_giris_siniri', 'Kaç hatalı girişten sonra kilitlensin')}
                {alan('guvenlik.kilit_dakika', 'Kilit süresi (dakika)')}
              </div>
            </div>
          </>
        )}
      </div>
    </>
  );
}
