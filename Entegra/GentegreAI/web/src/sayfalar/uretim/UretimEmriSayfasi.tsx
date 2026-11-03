import { useParams } from 'react-router-dom';
import { Liste } from '../Liste';
import type { ListeTanimi } from '../listeTanimlari';
import { useUretimSeviyesi } from '../../bilesenler/useUretimSeviyesi';
import { UretimEmirleriBasit } from './UretimEmirleriBasit';

/**
 * /uretim-emri ROTASI SEVİYEYE GÖRE (1253, mockup uretim_basit.html ②): basit seviyede sade iş listesi
 * (UretimEmirleriBasit), standart / denetimlide generic emir listesi ve kartı. Kart adresi (/uretim-emri/:id) her
 * seviyede generic karttır - basit listedeki ürün adı da oraya gider (ayrıntı gerektiğinde).
 */
export function UretimEmriSayfasi({ tanim }: { tanim: ListeTanimi }) {
  const sv = useUretimSeviyesi();
  const { id } = useParams();
  if (!sv.yuklendi) return <div className="yukleniyor">Yükleniyor…</div>;
  if (sv.basit && !id) return <UretimEmirleriBasit />;
  return <Liste tanim={tanim} />;
}
