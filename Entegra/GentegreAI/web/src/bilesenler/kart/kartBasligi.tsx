import type { ReactNode } from 'react';
import type { KartMetaYaniti } from '../../api/sozlesme';
import { kidemMetni } from '../bicim';
import type { DetayDurumu } from '../detayDurumu';
import type { Deger } from '../kartAlanCizim';
import { IstemAkisi } from '../radyoloji/IstemAkisi';
import { YatisSeridi } from '../yatan/YatisSeridi';

/**
 * KART BAŞLIĞI ve ÜST ŞERİDİ - KAYNAĞA ÖZEL PARÇALAR (refaktör 23.10.2026, GenForm'dan ayrıldı).
 *
 * `kartBaslikRozeti`: başlık satırında, kartın kimliği olan bilgi (hasta dosya no, personel durumu /
 * görev / kıdem / belge, doküman sürümü) - hangi sekmede olursan ol görünür.
 * `kartUstSeridi`: kimlik şeridinin ALTINDA, sekmelerin ÜSTÜNDE duran şerit (radyoloji istem akışı,
 * yatış). Yalnız kayıtlı kartta.
 */
export interface KartBaslikBaglami {
  kaynak: string;
  id: number | 'yeni';
  yeniMi: boolean;
  deger: Record<string, Deger>;
  meta: KartMetaYaniti | null;
  detaylar: Record<string, DetayDurumu>;
}

const ortada = { margin: '0 auto', display: 'flex', alignItems: 'center' } as const;

const ROZETLER: Record<string, (b: KartBaslikBaglami) => ReactNode> = {
  // HASTADA BAŞLIK ROZETİ YOK (kullanıcı 17.11.2026: "başlıkta ad soyad kutusunun olduğu yere kimlik no ve doğum
  //   tarihini taşı", "durum da oraya gelsin", "dosya no kimlikno label'lara gerek yok"): dosya no · kimlik no · doğum
  //   tarihi ve durum rozeti kimlik şeridinin görüntüleme bandında (KartKimlikSeridi hastaSar), ad soyadın altında.
  // Personel durumu BASLIKTA rozet (kullanici): aktif yesil, isten
  //   cikis tarihi girilmisse pasif kirmizi - cikis tarihi olan biri
  //   "aktif" gorunmesin. Serit alani olarak ayrica cizilmez.
  //   DIS HEKIMDE baslik rozeti YOK (kullanici): durum seritte combo.
  // DURUM ŞERİTTE, GÖREV ROZETİ YOK (kullanıcı 17.11.2026: "başlıktan durumu ana rol sağına taşı.. durum sağındaki
  //   radyoloji yazan rozeti kaldır"): Aktif / Pasif rozeti kimlik şeridinde Ana Rol'ün sağında (KartKimlikSeridi
  //   personelDurumu); görev zaten şeritte alan olarak duruyor. Başlıkta kıdem ve belge uyarıları kalır.
  personel: ({ detaylar }) => {
    const ozluk = detaylar.ozluk?.guncel[0];
    const cikis = String((ozluk?.istenCikisTarihi as string | undefined) ?? '');
    const kidem = kidemMetni(
      String((ozluk?.iseGirisTarihi as string | undefined) ?? ''), cikis || null);
    // BELGE DURUMU (mockup personel_belge_takibi.html): hangi sekmede olursan ol.
    const belge = detaylar.belgeDurumu?.guncel ?? [];
    const eksik = belge.filter(x => (Number(x.durum) === 1 && Number(x.zorunlu) === 1) || Number(x.durum) === 2).length;
    const yakin = belge.filter(x => Number(x.durum) === 3).length;
    return (
      <span style={{ ...ortada, gap: 8 }}>
        {kidem && (
          <span style={{ fontWeight: 400, fontSize: 11.5, opacity: .9 }}>
            Kıdem {kidem}
          </span>
        )}
        {eksik > 0 && <span className="rozet hata" title="Eksik / süresi dolan belge">{eksik} eksik belge</span>}
        {yakin > 0 && <span className="rozet uyari" title="Süresi yaklaşan belge">{yakin} yaklaşıyor</span>}
      </span>
    );
  },
  // DOKUMAN DURUM ROZETI UST BASLIKTA (kullanici): "Yayında v1"
  //   kartin kimligidir - hangi sekmede olursan ol gorunmeli. Arac
  //   cubugunda dururken Kaydet/Kapat dugmelerinin arasinda kayboluyordu.
  //   HASH GOSTERILMEZ (kullanici): 64 haneli ozet kullaniciya bir sey
  //   anlatmiyor; icerik kimligi gerektiginde Icerik sekmesinde.
  dokuman: ({ deger, meta }) => (
    <span style={{ ...ortada, gap: 6 }}>
      <span className={`rozet ${Number(deger.durum) === 3 ? 'ok'
                        : Number(deger.durum) === 2 ? 'mavi'
                        : Number(deger.durum) === 4 ? 'gri' : 'uyari'}`}>
        {meta?.alanlar.find(a => a.ad === 'durum')?.kodlar?.[String(deger.durum ?? '')]
         ?? 'Taslak'} v{String(deger.surumNo ?? 1)}
      </span>
      {Number(deger.onaydakiSurum) > 0 && (
        <span className="rozet mavi">v{String(deger.onaydakiSurum)} onayda</span>
      )}
    </span>
  ),
};

const SERITLER: Record<string, (id: number) => ReactNode> = {
  // RADYOLOJI ISTEMI (310): akis seridi + ozet KIMLIK SERIDININ ALTINDA,
  //   sekmelerin USTUNDE - hangi sekmede olursan ol "istem nerede"
  //   gorunmeli (mockup radyoloji_istem_karti.html).
  'radyoloji-istem': id => <IstemAkisi istemId={id} />,
  // YATIS KARTI (695, mockup yatis_karti.html): kimlik + son vital
  //   seridi SEKMELERIN DISINDA - yatan hastada "kim, nerede, kacinci
  //   gun, nasil" her kararin onkosulu; sekmeye gomulurse hekim her
  //   seferinde tiklar.
  yatan: id => <YatisSeridi yatisId={id} />,
};

/** Başlıktaki kaynağa özel rozet (yeni kartta yok). */
export function kartBaslikRozeti(b: KartBaslikBaglami): ReactNode {
  return b.yeniMi ? null : ROZETLER[b.kaynak]?.(b) ?? null;
}

/** Kimlik şeridinin altındaki kaynağa özel şerit (yeni kartta yok). */
export function kartUstSeridi(kaynak: string, id: number | 'yeni'): ReactNode {
  return id === 'yeni' ? null : SERITLER[kaynak]?.(id) ?? null;
}
