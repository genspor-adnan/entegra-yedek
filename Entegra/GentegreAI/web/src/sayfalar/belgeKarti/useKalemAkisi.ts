import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { hamSayi } from '../../bilesenler/bicim';
import type { SatirDurumu } from '../belgeSatir';
import { sonAnahtar, paketIcerigiUygula } from '../belgeKalem';
import { stokSeciminiCoz } from './stokSecimi';
import type { BasvuruBilgi } from '../../bilesenler/belge/BasvuruSekmesi';

/**
 * KALEM AKIŞI: seçilen stok/hizmeti kalem penceresine, pencereden dönen satırı
 * gride yazar.
 *
 * İki kural burada yaşıyor ve ikisi de bir hatadan doğdu:
 *
 *  · PAKET satırı FİYATSIZ yazılır - içerik satırları kendi fiyatlarıyla
 *    geldiği için pakete de fiyat yazılsaydı belge toplamı İKİ KEZ sayardı.
 *  · ANAHTAR HER ZAMAN SAYI olmalı; bozuksa (NaN/undefined) hiçbir satırla
 *    eşleşmez ve her kayıt YENİ satır ekler - kullanıcının "ücreti tek seçtim,
 *    çift ekledi" dediği durum budur. Bozuk anahtar sessizce tazelenir.
 */
export function useKalemAkisi({
  satirlar, setSatirlar, setKalem, setKalemDegisti, setHata,
  yerelPara, raporDovizi, setRaporDovizi, setBelgeKuru,
  cariId, odeyenKurumId, fiyatListesiId, kampanyaId, basvuruBilgi, alisMi,
}: {
  satirlar: SatirDurumu[];
  setSatirlar: (f: (s: SatirDurumu[]) => SatirDurumu[]) => void;
  setKalem: (s: SatirDurumu | null) => void;
  setKalemDegisti: (v: boolean) => void;
  setHata: (m: string | null) => void;
  yerelPara: string;
  raporDovizi: string;
  setRaporDovizi: (d: string) => void;
  setBelgeKuru: (k: string) => void;
  cariId: number | null;
  odeyenKurumId: number | null;
  fiyatListesiId: number | null;
  kampanyaId: number | null;
  basvuruBilgi: BasvuruBilgi;
  alisMi: boolean;
}) {
  /**
   * STOK / HİZMET SEÇİLDİ (arama penceresinden): kalem penceresini açar.
   *
   * FİYAT ÖNCE ÇÖZÜLÜR, PENCERE SONRA AÇILIR: pencere `satir` prop'unu
   * açılışta kopyalar (useState); sonradan gönderilen fiyat güncellemesi ona
   * ULAŞMAZ.
   */
  const stokSecildi = async (sec: Record<string, unknown>) => {
    const yeni = await stokSeciminiCoz(sec, {
      satirlar, yerelPara, tarafId: cariId, odeyenKurumId,
      fiyatListesiId, kampanyaId, basvuruBilgi,
    });
    setKalem(yeni);
  };

  /** Kalem penceresinden dönen satırı yazar (yeni ise ekler). */
  const kalemKaydet = (satir: SatirDurumu) => {
    const yazilacak = satir.paket
      ? { ...satir, birimFiyat: '0', dovizFiyat: '0' }
      : satir;
    setSatirlar(s => {
      const ge = Number.isFinite(yazilacak.anahtar)
        ? yazilacak : { ...yazilacak, anahtar: sonAnahtar(s) + 1 };
      return s.some(x => x.anahtar === ge.anahtar)
        ? s.map(x => (x.anahtar === ge.anahtar ? ge : x))
        : [...s, ge];
    });
    setKalemDegisti(true);

    // RAPOR DÖVİZİ İLK DÖVİZLİ KALEMDEN gelir (kullanıcı): dövizli fiyatla
    //   kalem eklenince belge o dövizde raporlanır, kur da kalemin kurudur.
    //   Sonraki kalemler rapor dövizini DEĞİŞTİRMEZ - kullanıcı isterse
    //   kutudan kendisi seçer.
    if (satir.fiyatDovizi && satir.fiyatDovizi !== yerelPara && raporDovizi === yerelPara) {
      setRaporDovizi(satir.fiyatDovizi);
      const k = hamSayi(satir.kur);
      if (k > 0) setBelgeKuru(String(k));
    }

    // PAKET (124): paket seçilince İÇERİĞİ de eklenir - "paket item +
    //   içerikleri tümüyle" (kullanıcı). İçerik satırları paketin adediyle
    //   çarpılır ve FİYATSIZ gelir; düzenlenebilir (kullanıcı pakette olmayan
    //   bir şeyi çıkarabilir).
    if (!satir.paket || !satir.stokId) return;
    void api.paketIcerigi(satir.stokId, alisMi)
      .then(icerik => {
        if (icerik.length === 0) return;
        setSatirlar(s => paketIcerigiUygula(s, satir, icerik));
      })
      .catch(h => setHata(hataMetni(h)));
  };

  return { stokSecildi, kalemKaydet };
}
