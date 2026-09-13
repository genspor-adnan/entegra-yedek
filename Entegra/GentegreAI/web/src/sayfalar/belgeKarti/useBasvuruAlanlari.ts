import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { type BasvuruBilgi } from '../../bilesenler/belge/BasvuruSekmesi';

/**
 * BAŞVURU BAŞLIĞININ KENDİ DURUMU — ödeyen kurum, bölüm, personel, başvuru
 * sekmesi alanları.
 *
 * Beş state ve onları güncelleyen iki efekt `BelgeKarti` içinde, 45 state'in
 * arasında duruyordu; hangisinin hangi efektle değiştiğini görmek için bin
 * satır taramak gerekiyordu. Buradakiler HBYS'ye özgü: ERP belgesinde hiç
 * kullanılmazlar.
 *
 * Kart yalnız değer ve setter alır - kuralların kendisi (kimin ne zaman
 * doldurulacağı) kartta kalır, çünkü belge türüne ve kullanıcı akışına
 * bağlıdır.
 */
export function useBasvuruAlanlari(p: {
  /** Belge bir başvuru mu - değilse efektler çalışmaz. */
  basvuruMu: boolean;
  /** Dış hekim gönderimi (lab/görüntüleme) modu. */
  gonderenModu: boolean;
}) {
  /**
   * ÖDEYEN KURUM (296): başvurunun faturalanacağı kurum (anlaşmalı kurum /
   * sigorta / SGK). Boş = hasta kendi öder.
   */
  const [odeyenKurumId, setOdeyenKurumId] = useState<number | null>(null);

  /**
   * BAŞVURU BAŞLIĞI (296/297): başvurulan BÖLÜM ve karşılayan PERSONEL.
   * Personel HEKİM OLMAK ZORUNDA DEĞİL (kullanıcı): diyetisyen,
   * fizyoterapist, teknisyen de başvuru karşılar - kısıt "randevu verilebilir
   * personel" + seçili bölüm. İkisi de belge_basvuru uzantısında saklanır.
   */
  const [bolumId, setBolumId] = useState<number | null>(null);
  const [personelId, setPersonelId] = useState<number | null>(null);

  /**
   * Seçili hekim/gönderen ADI: arama ekranından gelen kişi combo listesinde
   * olmayabilir (ör. işareti kaldırılmış dış hekim), ad ayrıca tutulur.
   */
  const [personelAd, setPersonelAd] = useState('');

  /**
   * BAŞVURU SEKMESİ (298) alanları TEK NESNEDE: on kadar alan için ayrı ayrı
   * state tutmak kartı şişiriyordu; hepsi belge_basvuru uzantısına gider.
   */
  const [basvuruBilgi, setBasvuruBilgi] = useState<BasvuruBilgi>({});

  // Tür SORULMADIĞI için kayıtta boş kalmasın: lab/görüntüleme kurumunda
  //   başvuru türü 5 ("Laboratuvar / Görüntüleme") olarak damgalanır.
  useEffect(() => {
    if (!p.basvuruMu || !p.gonderenModu) return;
    setBasvuruBilgi(o => (Number(o.basvuruTuru ?? 0) === 5 ? o : { ...o, basvuruTuru: 5 }));
  }, [p.basvuruMu, p.gonderenModu]);

  return {
    odeyenKurumId, setOdeyenKurumId,
    bolumId, setBolumId,
    personelId, setPersonelId,
    personelAd, setPersonelAd,
    basvuruBilgi, setBasvuruBilgi,
  };
}

/**
 * SEÇİLİ KİŞİNİN ADI — combo listesinde yoksa sunucudan çözülür.
 *
 * `useBasvuruAlanlari`dan AYRI, çünkü görevli listesi başvuru
 * kaynaklarından gelir ve o kanca başvuru alanlarından SONRA çağrılır
 * (bölüm kimliğini o alanlar verir). İkisini tek kancada toplamak
 * döngüsel bir bağımlılık olurdu.
 */
export function usePersonelAdi(personelId: number | null,
                               gorevliler: { id: number; ad: string }[],
                               setPersonelAd: (ad: string) => void) {
  // Seçili kişinin adı: liste yüklendiğinde ya da belge açıldığında çözülür.
  useEffect(() => {
    if (!personelId) { setPersonelAd(''); return }
    const g = gorevliler.find(x => x.id === personelId);
    if (g) { setPersonelAd(g.ad); return }
    void (async () => {
      try {
        const y = await api.liste('basvuru-hekim', {
          sayfa: 1, boyut: 1,
          filtre: { op: 'and', kosullar: [{ alan: 'id', op: 'esit', deger: personelId }] },
        });
        setPersonelAd(String(y.satirlar[0]?.ad ?? ''));
      } catch { /* ad okunamazsa kutu boş görünür, kimlik korunur */ }
    })();
  }, [personelId, gorevliler, setPersonelAd]);

}
