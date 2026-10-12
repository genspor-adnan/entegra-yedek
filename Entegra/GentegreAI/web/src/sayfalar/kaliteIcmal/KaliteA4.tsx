import type { KaliteIcmali } from '../../api/uclar/kaliteIcmal';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { durumRozeti, hedefMetni, sonucMetni } from './kaliteIcmalOrtak';

/**
 * A4 KALİTE GÖSTERGELERİ DÖNEM RAPORU. Göstergeler (seçiliyse yalnız onlar;
 * kaynağı olmayanlar basılmaz), güvenlik özeti. Hasta bilgisi basılmaz.
 */
export function KaliteA4({ v, antet, duzenleyen, secili }: {
  v: KaliteIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: string[];
}) {
  const o = v.ozet;
  const liste = (secili.length ? v.gostergeler.filter(g => secili.includes(g.kod)) : v.gostergeler).filter(g => g.durum !== 'kaynakyok');
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>KALİTE GÖSTERGELERİ DÖNEM RAPORU</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Önceki: {tarihKisa(v.donem.oncekiBas)} - {tarihKisa(v.donem.oncekiBit)}</span>
        <span>Gösterge: {liste.length} · hedefte {liste.filter(g => g.durum === 'hedefte').length}</span>
        <span>{secili.length ? `Seçili ${liste.length} gösterge` : 'Tüm göstergeler'}</span>
      </div>
      <table className="a4-t kl-a4t">
        <thead><tr><th>Kod</th><th>Gösterge</th><th>Hedef</th><th>Dönem</th><th>Önceki</th><th>Durum</th></tr></thead>
        <tbody>
          {liste.map(g => (
            <tr key={g.kod}><td>{g.kod}</td><td>{g.ad}</td><td>{hedefMetni(g.yon, g.hedef, g.birim)}</td><td>{sonucMetni(g.sonuc, g.birim)}</td>
              <td>{sonucMetni(g.onceki, g.birim)}</td><td>{durumRozeti(g.durum).ad}</td></tr>
          ))}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Kritik / panik bildirim (hedefte)</td><td>{o.bildirimHedefte} / {o.bildirim}</td></tr>
        <tr><td>GRS olay bildirimi (ciddi / ölüm)</td><td>{o.grs} ({o.grsCiddi})</td></tr>
        <tr><td>Düşme / gelişen bası yarası</td><td>{o.dusme} / {o.basi}</td></tr>
        <tr><td>El hijyeni uyum · memnuniyet</td><td>{sonucMetni(o.elOran, '%')} · {sonucMetni(o.memnuniyetOran, '%')}</td></tr>
        <tr className="kalan ki-kalan"><td>HEDEF DIŞI GÖSTERGE</td><td>{liste.filter(g => g.durum === 'disi').length}</td></tr>
      </tbody></table>
      <p className="a4-not">Hedef dışı göstergeler için düzeltici-önleyici faaliyet (DÖF) Kalite Yönetim Birimi tarafından açılır.
        {o.kaynakYok ? ` Kaydı sistemde tutulmayan ${o.kaynakYok} SKS göstergesi rapora alınmadı.` : ''} Bu raporda hasta kimlik bilgisi yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Kalite Yönetim Direktörü · İmza</div><div>Onaylayan<br />Başhekim · Kaşe · İmza</div></div>
    </div>
  );
}
