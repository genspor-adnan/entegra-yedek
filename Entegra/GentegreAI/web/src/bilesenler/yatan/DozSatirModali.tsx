import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { EmarDoz, EmarOrder } from '../../api/uclar/yatan';
import { DozUygulamaModali } from './DozUygulamaModali';

/**
 * DOZ KUYRUĞU SATIRINDAN UYGULAMA PENCERESİ.
 *
 * Grid satırı yalnız "hangi doz" bilgisini taşıyor; uygulama penceresi ise
 * ilacın dozunu, yolunu ve planlanan saatini de gösteriyor. İkisini tek
 * kaynaktan (eMAR ucu) okuyoruz: satırın kolonlarından ikinci bir "order"
 * nesnesi kurmak, çizelgede görünenle pencerede görüneni ayrıştırırdı.
 *
 * <b>Atlama modu doğrudan açılabilir</b> (grid'in "Atlandı" düğmesi): hemşire
 * zaten kararını vermiş; pencereyi önce uygulama modunda açmak fazladan bir
 * tıklama olurdu.
 */
export function DozSatirModali({ yatisId, dozId, atlaModu, onKapat, onTamam }: {
  yatisId: number;
  dozId: number;
  atlaModu?: boolean;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [veri, setVeri] = useState<{ doz: EmarDoz; order: EmarOrder; hasta: string } | null>(null);
  const [hata, setHata] = useState('');

  useEffect(() => {
    void (async () => {
      try {
        // DOZ BUGÜNÜN ÇİZELGESİNDE OLMAYABİLİR (dün geciken doz): gün,
        //   satırın kendi planlanan tarihinden alınır.
        const bugun = await api.emar(yatisId);
        let d = bugun.dozlar.find(x => x.id === dozId);
        let od = bugun.orderlar.find(o => o.id === d?.orderId);

        if (!d) {
          const o = await api.yatisOzeti(yatisId);
          const gun = o.ozet.girisTarihi.slice(0, 10);
          const eski = await api.emar(yatisId, gun);
          d = eski.dozlar.find(x => x.id === dozId);
          od = eski.orderlar.find(x => x.id === d?.orderId);
        }

        if (!d || !od) { setHata('Doz kaydı bulunamadı.'); return }

        const ozet = await api.yatisOzeti(yatisId);
        setVeri({
          doz: d, order: od,
          hasta: `${ozet.ozet.hasta}${ozet.ozet.yatak ? ` · ${ozet.ozet.yatak}` : ''}`,
        });
      } catch { setHata('Doz kaydı okunamadı.') }
    })();
  }, [yatisId, dozId]);

  if (hata) {
    // Pencere açılamadıysa sessizce kapanmak yerine sebebi söyleyip kapanır.
    queueMicrotask(() => { alert(hata); onKapat() });
    return null;
  }
  if (!veri) return null;

  return (
    <DozUygulamaModali
      doz={veri.doz}
      order={veri.order}
      hasta={veri.hasta}
      acilisAtlaModu={atlaModu}
      onKapat={onKapat}
      onTamam={onTamam}
    />
  );
}
