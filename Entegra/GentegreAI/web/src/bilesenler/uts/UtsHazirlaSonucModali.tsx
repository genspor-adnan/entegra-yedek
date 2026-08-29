import { Modal } from '../Modal';
import { YerelGrid } from '../grid/YerelGrid';
import type { UtsHazirlaYaniti } from '../../api/istemci';

/**
 * VERME HAZIRLA raporu (kullanıcı): kaç satır bekleyene alındı + hangileri
 * NEDEN alınamadı. Atlananlar düz metin değil GRİD - sıralanır, ⋮ menüsünden
 * CSV kaydedilir (eksikleri toplu düzeltmek için liste gerekiyor).
 */
const AD_SOZLUGU: Record<string, string> = {
  belgeNo: 'Belge No', tarih: 'Tarih', cari: 'Cari', stok: 'Stok',
  urunNo: 'Ürün No (UNO)', seriNo: 'Seri No', lotNo: 'Lot No',
  adet: 'Adet', sebep: 'Neden Atlandı',
};

// "Neden" kolonu erken: okunacak asil bilgi o, urun/lot ayrintisi ikincil.
const KOLON_SIRASI = ['belgeNo', 'tarih', 'cari', 'stok', 'sebep',
                      'urunNo', 'seriNo', 'lotNo', 'adet'];

export function UtsHazirlaSonucModali({ sonuc, onKapat }: {
  sonuc: UtsHazirlaYaniti;
  onKapat(): void;
}) {
  const atlanan = sonuc.atlanan as unknown as Record<string, unknown>[];
  return (
    <Modal baslik="ÜTS Verme Bildirimi — Hazırlama Sonucu" onKapat={onKapat}
      alt={<button className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                   onClick={onKapat}>Kapat</button>}>
      <div style={{ padding: 10 }}>
        <div className={sonuc.olusan > 0 ? 'bilgi-kutusu' : 'hata-kutusu'}>
          {sonuc.mesaj}
        </div>
        {atlanan.length > 0 && (
          <>
            <div style={{ margin: '10px 0 6px', fontWeight: 600 }}>
              Hazırlanamayan satırlar ({sonuc.atlananSayisi})
            </div>
            <YerelGrid kayitlar={atlanan} kolonOncelik={KOLON_SIRASI}
                       adSozlugu={AD_SOZLUGU} csvAdi="uts-verme-atlananlar.csv"
                       bosMetin="Atlanan satır yok." maxYukseklik={380} />
          </>
        )}
      </div>
    </Modal>
  );
}
