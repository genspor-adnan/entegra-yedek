import type { GunSonu } from '../../api/uclar/kasaGunSonu';
import { para, paraYaz } from '../../bilesenler/bicim';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';

/**
 * A4 GÜN SONU KASA RAPORU. Kasalar (seçiliyse yalnız onlar), POS ve özet.
 * Gün kapanmadıysa "TASLAK" yazar. Hasta bilgisi basılmaz.
 */
export function GunSonuA4({ v, antet, duzenleyen, secili }: {
  v: GunSonu; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const p = (n: number) => para.format(n);
  const o = v.ozet;
  const kapali = !!v.kapanis?.kapali;
  const kasalar = secili.length ? v.kasalar.filter(k => secili.includes(k.id)) : v.kasalar;
  const gunAdi = new Date(v.tarih).toLocaleDateString('tr-TR', { weekday: 'long' });
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>GÜN SONU KASA RAPORU{kapali ? '' : ' (TASLAK)'}</h3>
      <div className="a4-hasta">
        <span>Tarih: <b>{tarihKisa(v.tarih)} {gunAdi}</b></span>
        <span>Gün durumu: {kapali ? `Kapalı · ${v.kapanis!.kapatan}` : 'Açık (taslak)'}</span>
        <span>Kasa {v.kasalar.length} · POS {v.poslar.length} · Banka {v.bankalar.length}</span>
        <span>{secili.length ? `Seçili ${kasalar.length} kasa` : 'Tüm kasalar'}</span>
      </div>
      <table className="a4-t gs-a4t">
        <thead><tr><th>Kasa</th><th>Açılış</th><th>Giriş</th><th>Çıkış</th><th>Transfer</th><th>Beklenen</th><th>Sayılan</th><th>Fark</th></tr></thead>
        <tbody>
          {kasalar.map(k => (
            <tr key={k.id}><td>{k.ad}</td><td>{p(k.devir)}</td><td>{p(k.giris)}</td><td>{p(k.cikis)}</td><td>{p(k.transfer)}</td>
              <td>{p(k.beklenen)}</td><td>{k.sayilan != null ? p(k.sayilan) : k.acik ? 'açık' : '—'}</td><td>{k.fark != null ? p(k.fark) : '—'}</td></tr>
          ))}
        </tbody>
      </table>
      {v.poslar.length > 0 && (
        <table className="a4-t gs-a4t">
          <thead><tr><th>POS</th><th>Terminal</th><th>Adet</th><th>Sistem</th><th>Gün Sonu</th><th>Fark</th></tr></thead>
          <tbody>
            {v.poslar.map(x => (
              <tr key={x.id}><td>{x.ad}</td><td>{x.terminal || '—'}</td><td>{x.adet}</td><td>{p(x.sistem)}</td>
                <td>{x.batch != null ? p(x.batch) : '—'}</td><td>{x.fark != null ? p(x.fark) : '—'}</td></tr>
            ))}
          </tbody>
        </table>
      )}
      <table className="a4-toplam"><tbody>
        <tr><td>Devir (açılış)</td><td>{paraYaz(o.devir)}</td></tr>
        <tr><td>+ Nakit giriş</td><td>{paraYaz(o.girisNakit)}</td></tr>
        <tr><td>− Nakit çıkış</td><td>{paraYaz(o.cikisNakit)}</td></tr>
        <tr><td>− Bankaya yatırılan</td><td>{paraYaz(o.bankayaYatirilan)}</td></tr>
        <tr><td>= Beklenen kasa bakiyesi</td><td>{paraYaz(o.beklenen)}</td></tr>
        <tr><td>Sayım farkı</td><td>{paraYaz(o.kasaFark)}</td></tr>
        <tr className="kalan ki-kalan"><td>ERTESİ GÜN DEVRİ{o.ertesiKesin ? '' : ' (kesin değil)'}</td><td>{paraYaz(o.ertesiGunDevri)}</td></tr>
      </tbody></table>
      <p className="a4-not">POS {paraYaz(o.pos)} ({o.posAdet} çekim, gün sonu farkı {paraYaz(o.posFark)}) · Havale / EFT {paraYaz(o.havale)}
        ({o.havaleAdet} işlem, ekstre farkı {paraYaz(o.bankaFark)}).{!kapali && v.engeller.length ? ` Açık engeller: ${v.engeller.join('; ')}.` : ''}
        {' '}Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Kasa Sorumlusu<br />Ad Soyad · İmza</div><div>Mali İşler<br />Kaşe · İmza</div></div>
    </div>
  );
}
