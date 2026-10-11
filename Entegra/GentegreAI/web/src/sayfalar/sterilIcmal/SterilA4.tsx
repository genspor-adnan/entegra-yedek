import type { SterilIcmali } from '../../api/uclar/sterilIcmal';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { yuzde } from './sterilIcmalOrtak';

/**
 * A4 STERİLİZASYON DÖNEM İCMALİ. Cihaz (seçiliyse yalnız onlar) ve bölüm
 * tabloları, güvenlik özeti. Hasta bilgisi basılmaz.
 */
export function SterilA4({ v, antet, duzenleyen, secili }: {
  v: SterilIcmali; antet: Record<string, unknown> | null; duzenleyen: string; secili: number[];
}) {
  const o = v.ozet;
  const cihazlar = secili.length ? v.cihazlar.filter(c => secili.includes(c.id)) : v.cihazlar;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>STERİLİZASYON DÖNEM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.donem.bas)} - {tarihKisa(v.donem.bit)}</b></span>
        <span>Döngü: {o.sterilDongu} sterilizasyon · {o.yikamaDongu} yıkama</span>
        <span>Paket: {o.uretilen} üretilen · {o.kullanilan} kullanılan</span><span>{secili.length ? `Seçili ${cihazlar.length} cihaz` : 'Tüm cihazlar'}</span>
      </div>
      <table className="a4-t st-a4t">
        <thead><tr><th>Cihaz</th><th>Döngü</th><th>Serbest</th><th>Başarısız / İptal</th><th>Test</th><th>Doluluk</th><th>Validasyon</th></tr></thead>
        <tbody>
          {cihazlar.map(c => (
            <tr key={c.id}><td>{c.ad}</td><td>{c.dongu}</td><td>{c.serbest}</td><td>{c.basarisiz}</td><td>{c.test}</td><td>{yuzde(c.doluluk)}</td>
              <td>{c.validasyon ? tarihKisa(c.validasyon) : '—'}</td></tr>
          ))}
        </tbody>
      </table>
      {v.bolumler.length > 0 && (
        <table className="a4-t st-a4t">
          <thead><tr><th>Bölüm</th><th>Kullanılan Paket</th><th>Set Çeşidi</th><th>İmplant Seti</th></tr></thead>
          <tbody>
            {v.bolumler.map(b => <tr key={b.bolum}><td>{b.bolum}</td><td>{b.paket}</td><td>{b.setCesidi}</td><td>{b.implant}</td></tr>)}
          </tbody>
        </table>
      )}
      <table className="a4-toplam"><tbody>
        <tr><td>İndikatör okuması / başarısız</td><td>{o.indikatorOkuma} / {o.indikatorBasarisiz}</td></tr>
        <tr><td>Geri çağrılan paket (kullanılmış)</td><td>{o.geriCagrilanPaket} ({o.geriKullanilmis})</td></tr>
        <tr><td>Karantinada paket</td><td>{o.karantina}</td></tr>
        <tr><td>Süresi dolan paket</td><td>{o.suresiDolan}{o.islenmemis ? ` (${o.islenmemis} işlenmemiş)` : ''}</td></tr>
        <tr className="kalan ki-kalan"><td>CİHAZ DOLULUĞU</td><td>{yuzde(o.doluluk)}</td></tr>
      </tbody></table>
      <p className="a4-not">Eşiğe yakın birim: {o.esigeYakin}.{o.validasyonGeciken.length ? ` Validasyonu geciken: ${o.validasyonGeciken.join(', ')}.` : ''}
        {' '}Hasta kimlik bilgisi bu belgede yer almaz.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Sterilizasyon Sorumlusu · İmza</div><div>Onaylayan<br />Enfeksiyon Kontrol Komitesi · İmza</div></div>
    </div>
  );
}
