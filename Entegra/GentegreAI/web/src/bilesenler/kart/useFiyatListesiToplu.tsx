import { useState, type Dispatch, type ReactNode, type SetStateAction } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { c } from '../../dil/ceviri';
import { type DetayDurumu, bosDetay, detayFarki } from '../detayDurumu';
import { Modal } from '../Modal';
import { mesaj as bilgiMesaji, onay as onaySor } from '../mesaj';

/**
 * FİYAT LİSTESİ TOPLU İŞLEMLERİ (534 / 535 / 541, refaktör 22.10.2026 - GenForm'dan ayrıldı).
 *
 * Kartın alt araç çubuğundaki Fiyat Güncelle / Çarpan Gir / Katkı Gir / Durum Değiştir / SKRS'den
 * Güncelle düğmeleri, pencereleri ve sunucu çağrıları tek yerde. Satır SEÇİMİ gridde yaşıyor
 * (`setSeciliSatirlar` detay sekmesine gider); kategori süzgeci GenForm'da kalır - gridin combosu.
 */
export interface FiyatListesiTopluGirdisi {
  /** Fiyat listesi kartı mı (değilse düğme yok; seçim durumu yine çalışır). */
  etkin: boolean;
  id: number | 'yeni' | null | undefined;
  yeniMi: boolean;
  /** 1 Özel · 2 TTB/HUV · 3 SUT. */
  tarifeTipi: number;
  detaylar: Record<string, DetayDurumu>;
  setDetaylar: Dispatch<SetStateAction<Record<string, DetayDurumu>>>;
  /** Sayfalı satır detayının sunucudaki toplamı ve açık sayfası (525). */
  satirToplam?: number;
  satirSayfa?: number;
  satirKategori: { id: number; agac: number[]; ad: string } | null;
  yukle(): Promise<void>;
  detaySayfaCek(ad: string, sayfaNo: number): Promise<void>;
}

export function useFiyatListesiToplu(p: FiyatListesiTopluGirdisi) {
  const { id, detaylar, satirKategori } = p;
  /** Satir gridinde secili satirlar (534) - toplu islem dugmesi ust arac
      cubugunda, secim ise gridde yasiyor. */
  const [seciliSatirlar, setSeciliSatirlar] = useState<ReadonlySet<number>>(new Set());
  /** Acik toplu deger penceresi (534). */
  const [topluCarpan, setTopluCarpan] = useState(false);
  const [topluCarpanDeger, setTopluCarpanDeger] = useState('');
  /** "Durum Değiştir" acilir menusu (534). */
  const [durumMenusu, setDurumMenusu] = useState(false);
  /** Toplu "Katkı Gir" penceresi (541). */
  const [topluKatki, setTopluKatki] = useState(false);
  const [topluKatkiOran, setTopluKatkiOran] = useState('');
  /** Toplu "Fiyat Güncelle" penceresi (kullanici, Özel tarife). */
  const [fiyatGuncelle, setFiyatGuncelle] = useState(false);
  const [fiyatYonu, setFiyatYonu] = useState<'artir' | 'azalt'>('artir');
  const [fiyatYuzde, setFiyatYuzde] = useState('');
  /** SKRS tazeleme surerken dugme kilitli (535). */
  const [skrsCalisiyor, setSkrsCalisiyor] = useState(false);
  /** Toplu uygulama sunucuya giderken dugmeler kilitli. */
  const [topluCalisiyor, setTopluCalisiyor] = useState(false);

  /**
   * SUT LISTESINI SKRS AMBARINDAN TAZELE (535). Kaydedilmemis satir
   * degisikligi varsa once sorulur: tazeleme sunucuda yapiliyor ve kart
   * yeniden okunuyor - ekrandaki duzenleme kaybolurdu.
   */
  const skrsGuncelle = async () => {
    if (typeof id !== 'number') return;
    const durum = detaylar.satirlar;
    if (durum) {
      const fark = detayFarki(durum);
      if (fark.eklenen || fark.degisen || fark.silinen) {
        const devam = await onaySor(
          'Kaydedilmemiş satır değişiklikleri var. SKRS güncellemesi kartı '
          + 'yeniden okur ve bu değişiklikler kaybolur. Devam edilsin mi?');
        if (!devam) return;
      }
    }
    setSkrsCalisiyor(true);
    try {
      const s2 = await api.fiyatSutGuncelle(id);
      await bilgiMesaji(s2.mesaj);
      await p.yukle();
    } catch (h) {
      await bilgiMesaji(hataMetni(h));
    } finally {
      setSkrsCalisiyor(false);
    }
  };

  /** Secili satirlarin DURUMUNU topluca yazar (534). 1 Aktif · 0 Pasif. */
  const topluDurum = (yeni: number) => {
    p.setDetaylar(t => {
      const d = t.satirlar ?? bosDetay();
      const guncel = d.guncel.map((s2, i) =>
        seciliSatirlar.has(i) ? { ...s2, durum: yeni } : s2);
      return { ...t, satirlar: { ...d, guncel } };
    });
    setDurumMenusu(false);
  };

  /**
   * TOPLU SATIR DEGERI - SUNUCUDA (kullanici: "modalde 3 buton: seçili
   * satıra uygula · <kategori> uygula · tüm listeye uygula").
   *
   * Kategori ve "tüm liste" kapsamlari ekranda YUKLU OLMAYAN satirlari da kapsiyor -
   * istemcide yapilsaydi 14 bin satirlik listede yalnizca gorunen sayfa
   * degisir, kullanici "uygulandi" mesajini gorup eksik listeyle devam
   * ederdi. Seçili kapsam da ayni yoldan gider: uc dugmenin biri kaydedilmis,
   * ikisi kaydedilmemis degisiklik uretseydi "Kaydet" belirsizlesirdi.
   */
  const topluUygula = async (
    islem: 'carpan' | 'katki' | 'fiyat-yuzde',
    deger: number,
    kapsam: 'secili' | 'kategori' | 'tumu',
    yon?: 'artir' | 'azalt',
  ): Promise<boolean> => {
    if (typeof id !== 'number' || !Number.isFinite(deger) || deger <= 0) return false;
    const durum = detaylar['satirlar'];
    // Sunucuda yazip kartI yeniden okuyoruz: ekrandaki kaydedilmemis
    //   duzenleme kaybolur - once sorulur (SKRS tazelemesiyle ayni kural).
    if (durum) {
      const fark = detayFarki(durum);
      if (fark.eklenen || fark.degisen || fark.silinen) {
        const devam = await onaySor(
          'Kaydedilmemiş satır değişiklikleri var. Toplu uygulama satırları '
          + 'sunucuda günceller ve bu değişiklikler kaybolur. Devam edilsin mi?');
        if (!devam) return false;
      }
    }
    if (kapsam === 'tumu') {
      const devam = await onaySor(
        `Listenin TAMAMINA uygulanacak (${(p.satirToplam
          ?? durum?.guncel.length ?? 0).toLocaleString('tr')} satır). Devam edilsin mi?`);
      if (!devam) return false;
    }
    const satirIdler = kapsam === 'secili'
      ? [...seciliSatirlar].map(i => Number(durum?.guncel[i]?.id)).filter(x => x > 0)
      : undefined;
    if (kapsam === 'secili' && !satirIdler?.length) {
      await bilgiMesaji('Seçili satırların henüz kaydedilmemiş olanları toplu '
                        + 'uygulamaya giremez - önce Kaydet.');
      return false;
    }
    setTopluCalisiyor(true);
    try {
      const s2 = await api.fiyatTopluDeger(id, {
        islem, deger, kapsam, satirIdler,
        kategoriId: kapsam === 'kategori' ? satirKategori?.id : undefined, yon,
      });
      await bilgiMesaji(s2.mesaj);
      setSeciliSatirlar(new Set());
      await p.detaySayfaCek('satirlar', p.satirSayfa ?? 1);
      return true;
    } catch (h) {
      await bilgiMesaji(hataMetni(h));
      return false;
    } finally {
      setTopluCalisiyor(false);
    }
  };

  /**
   * TOPLU PENCERELERIN ARAC CUBUGU: uc kapsam dugmesi sola, Kapat saga
   * (kullanici). Hangi dugmeye basildiysa kapsam odur - pencerede ayrica
   * "kapsam" secmek gerekmiyor.
   */
  const topluButonlar = (gecerli: boolean,
                         calistir: (kapsam: 'secili' | 'kategori' | 'tumu') => void,
                         kapat: () => void) => {
    // DEGER BOSKEN DUGMELER PASIF DEGIL (kullanici: "butonlar da pasif
    //   geliyor"): pencere acildiginda kutu zaten bos oluyordu ve UC dugme
    //   birden gri geliyor, ekran bozuk gorunuyordu. Eksik deger tiklanınca
    //   SOYLENIR - kapsam dugmesi yalniz KENDI on kosulu yoksa kilitlenir
    //   (satir secilmemis / kategori secilmemis).
    const dogrula = (kapsam: 'secili' | 'kategori' | 'tumu') => {
      if (!gecerli) { void bilgiMesaji('Önce geçerli bir değer girin.'); return }
      if (kapsam === 'secili' && seciliSatirlar.size === 0) {
        void bilgiMesaji('Önce satırlar sekmesinden satır seçin.'); return;
      }
      if (kapsam === 'kategori' && !satirKategori) {
        void bilgiMesaji('Önce satırlar sekmesindeki kategori combosundan bir dal seçin.');
        return;
      }
      calistir(kapsam);
    };
    return (
    <>
      <button type="button" className="d bir"
              disabled={topluCalisiyor}
              title={seciliSatirlar.size === 0 ? 'Gridde satır seçilmedi' : undefined}
              onClick={() => dogrula('secili')}>
        {seciliSatirlar.size} satıra uygula
      </button>
      <button type="button" className="d"
              disabled={topluCalisiyor}
              title={satirKategori
                     ? `"${satirKategori.ad}" ve alt kategorilerindeki tüm satırlar`
                     : 'Satırlar sekmesinde kategori seçin'}
              onClick={() => dogrula('kategori')}>
        {satirKategori ? `${satirKategori.ad} uygula` : 'Kategoriye uygula'}
      </button>
      <button type="button" className="d" disabled={topluCalisiyor}
              title="Listedeki bütün satırlar (ekranda görünmeyenler dâhil)"
              onClick={() => dogrula('tumu')}>
        Tüm listeye uygula
      </button>
      <button type="button" className="d kapat-dugmesi" onClick={kapat}>✖ {c('Kapat')}</button>
    </>
    );
  };

  const tip = p.tarifeTipi;
  const araclar: ReactNode = !p.etkin || p.yeniMi ? null : (
    <>
      {/* FIYAT GUNCELLE (kullanici: "özel fiyat tipinde Sil butonu
          sağına Fiyat Güncelle; modalde Artır/Azalt combosu ve yüzde
          editi"). Yalniz OZEL tarifede: TTB fiyati katsayi x carpan'dan,
          SUT fiyati SKRS ambarindan dogar - orada fiyata elle yuzde
          uygulamak bir sonraki turetmede geri alinirdi. Secili satirlara
          calisir, oteki toplu dugmelerle ayni kural. */}
      {tip === 1 && (
        <button type="button" className="d"
                disabled={seciliSatirlar.size === 0}
                title={seciliSatirlar.size === 0
                       ? 'Önce satırlardan seçim yapın'
                       : `Seçili ${seciliSatirlar.size} satırın fiyatını yüzdeyle güncelle`}
                onClick={() => { setFiyatYuzde(''); setFiyatYonu('artir');
                                 setFiyatGuncelle(true) }}>
          ↕ Fiyat Güncelle{seciliSatirlar.size > 0 ? ` (${seciliSatirlar.size})` : ''}
        </button>
      )}
      {/* TOPLU CARPAN (534, kullanici: "sil butonu sagina Çarpan Gir
          butonu ekle, sadece TTB/HUV'da gorunsun" · "carpan butonu
          ustteki silin sagina al"): donem carpani binlerce satirda ayni -
          tek tek yazmak is degil. Secim gridde, dugme burada. */}
      {tip === 2 && (
        <button type="button" className="d"
                disabled={seciliSatirlar.size === 0}
                title={seciliSatirlar.size === 0
                       ? 'Önce satırlardan seçim yapın'
                       : `Seçili ${seciliSatirlar.size} satıra çarpan yaz`}
                onClick={() => { setTopluCarpanDeger(''); setTopluCarpan(true) }}>
          ✖ Çarpan Gir{seciliSatirlar.size > 0 ? ` (${seciliSatirlar.size})` : ''}
        </button>
      )}
      {/* KATKI GIR (541, kullanici: "TTB ve SUT turlerinde durum degis
          butonu soluna Katkı Gir ekle; gelen modalde girilen orani fiyat
          ile carpip hasta katkiyi guncelle"). Hastadan alinacak tutar
          tarifeye gore fiyatin sabit bir orani oluyor (TSS hastasinda
          TTB'nin, SGK'da SUT'un) - 14 bin satirda tek tek yazilmaz.
          Ozel tarifede YOK: orada hastanin odedigi zaten fiyatin
          kendisidir, ayrica bir katki alinmaz. */}
      {[2, 3].includes(tip) && (
        <button type="button" className="d"
                disabled={seciliSatirlar.size === 0}
                title={seciliSatirlar.size === 0
                       ? 'Önce satırlardan seçim yapın'
                       : `Seçili ${seciliSatirlar.size} satıra katkı yaz`}
                onClick={() => { setTopluKatkiOran(''); setTopluKatki(true) }}>
          ◈ Katkı Gir{seciliSatirlar.size > 0 ? ` (${seciliSatirlar.size})` : ''}
        </button>
      )}
      {/* DURUM DEGISTIR (534, kullanici: "ustteki sil sagina 'Durum
          Değiştir' butonu gir, altina menu gelsin Aktif ve Pasif,
          secince isaretli satirlari aktif/pasif yapsin"). Fiyat listesi
          buyuk (14 bin satir): kalemi tek tek acip durum kutusunu
          cevirmek is degil - kategori kapatmadan da bir grup satir
          gecici olarak kapatilabilmeli. */}
      <span className="durum-sec">
        <button type="button" className="d"
                disabled={seciliSatirlar.size === 0}
                title={seciliSatirlar.size === 0
                       ? 'Önce satırlardan seçim yapın'
                       : `Seçili ${seciliSatirlar.size} satırın durumu`}
                onClick={() => setDurumMenusu(a => !a)}>
          ◐ Durum Değiştir{seciliSatirlar.size > 0 ? ` (${seciliSatirlar.size})` : ''} ▾
        </button>
        {durumMenusu && (
          <span className="durum-menu">
            <button type="button" className="durum-oge"
                    onClick={() => topluDurum(1)}>✓ Aktif</button>
            <button type="button" className="durum-oge"
                    onClick={() => topluDurum(0)}>⊘ Pasif</button>
          </span>
        )}
      </span>
      {/* SKRS'DEN GUNCELLE (535, kullanici: "SUT fiyat tipi icin durum
          degis saginda 'SKRS'den Güncelle' ekle, basinca SKRS'den
          guncellesin"): SUT fiyati elle degismez (518/533) - tek mesru
          yazma yolu bu. Ambardan okur (520), servise gitmez. */}
      {tip === 3 && (
        <button type="button" className="d" disabled={skrsCalisiyor}
                title={c('SUT fiyatlarını SKRS ambarından tazele')}
                onClick={() => { void skrsGuncelle() }}>
          {skrsCalisiyor ? '⏳ Güncelleniyor…' : '⭳ SKRS’den Güncelle'}
        </button>
      )}
    </>
  );

  const pencereler: ReactNode = (
    <>
      {/* KATKI PENCERESI (541): oran x fiyat = hastadan alinacak katki.
          Oran CARPAN olarak okunur (0,80 -> fiyatin %80'i) - 518'deki
          `fn_fiyat_katki_uret` ile ayni dil, iki yerde iki anlam olmasin. */}
      {topluKatki && (
        <Modal baslik={`Katkı — ${seciliSatirlar.size} satır`} dar enUst ekSinif="mesaj-pencere toplu-pencere" buyutmeYok
               onKapat={() => setTopluKatki(false)}
               alt={topluButonlar(
                 Number.isFinite(Number(topluKatkiOran.replace(',', '.')))
                 && topluKatkiOran.trim() !== '',
                 kapsam => {
                   const oran = Number(topluKatkiOran.replace(',', '.'));
                   void topluUygula('katki', oran, kapsam)
                     .then(oldu => { if (oldu) setTopluKatki(false) });
                 },
                 () => setTopluKatki(false))}>
          <div className="toplu-kutu">
            <label className="alan tip-para">
              <span className="etiket">{c('Fiyatın Oranını Girin')}</span>
              <input autoFocus inputMode="decimal" value={topluKatkiOran}
                     onChange={e => setTopluKatkiOran(e.target.value)} />
            </label>
            <div className="ic sonuk">
              Hasta katkısı = fiyat × oran. Örnek: <b>0,80</b> girilirse
              fiyatın %80'i katkı olarak yazılır.
            </div>
          </div>
        </Modal>
      )}

      {/* FIYAT GUNCELLE PENCERESI (kullanici): yon (artir/azalt) + yuzde.
          Fiyat = fiyat x (1 ± yuzde/100), kurusa yuvarlanir. Katki/carpan
          ELLENMEZ: Ozel tarifede katki kullanilmiyor, carpan ise TTB'nin. */}
      {fiyatGuncelle && (() => {
        const yuzde = Number(fiyatYuzde.replace(',', '.'));
        const gecerli = fiyatYuzde.trim() !== '' && Number.isFinite(yuzde) && yuzde > 0;
        return (
        <Modal baslik={`Fiyat Güncelle — ${seciliSatirlar.size} satır`} dar enUst
               ekSinif="mesaj-pencere toplu-pencere" buyutmeYok
               onKapat={() => setFiyatGuncelle(false)}
               alt={topluButonlar(gecerli, kapsam => {
                 void topluUygula('fiyat-yuzde', yuzde, kapsam, fiyatYonu)
                   .then(oldu => { if (oldu) setFiyatGuncelle(false) });
               }, () => setFiyatGuncelle(false))}>
          <div className="toplu-kutu">
            <label className="alan">
              <span className="etiket">İşlem</span>
              <select value={fiyatYonu}
                      onChange={e => setFiyatYonu(e.target.value as 'artir' | 'azalt')}>
                <option value="artir">{c('Artır')}</option>
                <option value="azalt">{c('Azalt')}</option>
              </select>
            </label>
            <label className="alan tip-para">
              <span className="etiket">% giriniz</span>
              <input autoFocus inputMode="decimal" value={fiyatYuzde}
                     onChange={e => setFiyatYuzde(e.target.value)} />
            </label>
            <div className="ic sonuk">
              Yeni fiyat = fiyat {fiyatYonu === 'azalt' ? '−' : '+'} %{fiyatYuzde || '…'}.
              Örnek: 100,00 fiyat <b>10</b> ile{' '}
              <b>{fiyatYonu === 'azalt' ? '90,00' : '110,00'}</b> olur.
              Kuruşa yuvarlanır; kaydedene kadar sunucuya yazılmaz.
            </div>
          </div>
        </Modal>
        );
      })()}

      {/* TOPLU CARPAN PENCERESI (534): tek sayi, secilen kapsamdaki
          satirlara yazilir; fiyat = katsayi x carpan olarak SUNUCUDA
          yeniden dogar (uc de ayni kurali isletir). */}
      {topluCarpan && (
        <Modal baslik={`Çarpan — ${seciliSatirlar.size} satır`} dar enUst ekSinif="mesaj-pencere toplu-pencere" buyutmeYok
               onKapat={() => setTopluCarpan(false)}
               alt={topluButonlar(
                 Number.isFinite(Number(topluCarpanDeger.replace(',', '.')))
                 && topluCarpanDeger.trim() !== '',
                 kapsam => {
                   const sayi = Number(topluCarpanDeger.replace(',', '.'));
                   void topluUygula('carpan', sayi, kapsam)
                     .then(oldu => { if (oldu) setTopluCarpan(false) });
                 },
                 () => setTopluCarpan(false))}>
          <div className="toplu-kutu">
            <label className="alan tip-para">
              <span className="etiket">Çarpan</span>
              <input autoFocus inputMode="decimal" value={topluCarpanDeger}
                     onChange={e => setTopluCarpanDeger(e.target.value)} />
            </label>
            <div className="ic sonuk">
              Fiyat = katsayı × çarpan olarak yeniden hesaplanır.
            </div>
          </div>
        </Modal>
      )}
    </>
  );

  return { seciliSatirlar, setSeciliSatirlar, araclar, pencereler };
}
