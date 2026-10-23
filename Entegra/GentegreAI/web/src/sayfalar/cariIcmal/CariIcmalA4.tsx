import type { CariIcmal, CariIcmalSatiri } from '../../api/uclar/cariIcmal';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { para, paraYaz } from '../../bilesenler/bicim';
import { dovizBakiyeMetni } from '../../bilesenler/grid/satirHucre';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { bakiyeMetni } from './CariIcmalTablolari';

/**
 * A4 CARİ HESAP İCMALİ - yönetime / muhasebeye verilir. Seçili cari varsa yalnız onlar.
 * Müşteriler ve tedarikçiler ayrı bölümde, net pozisyon altta.
 */
export function CariIcmalA4({ v, satirlar, antet, duzenleyen, secimVar }: {
  v: CariIcmal; satirlar: CariIcmalSatiri[]; antet: Record<string, unknown> | null; duzenleyen: string; secimVar: boolean;
}) {
  const p = (n: number) => para.format(n);
  const t = (l: CariIcmalSatiri[], f: (c: CariIcmalSatiri) => number) => l.reduce((s, c) => s + f(c), 0);
  const bolumler: [string, CariIcmalSatiri[]][] = [
    ['MÜŞTERİLER', satirlar.filter(c => c.grup === 'musteri')],
    ['TEDARİKÇİLER', satirlar.filter(c => c.grup === 'tedarikci')],
  ];
  const alacak = t(satirlar.filter(c => c.bakiye > 0), c => c.bakiye);
  const borc = -t(satirlar.filter(c => c.bakiye < 0), c => c.bakiye);
  const kapsam = v.kapsam === 'musteri' ? 'Müşteri' : v.kapsam === 'tedarikci' ? 'Tedarikçi' : 'Müşteri + Tedarikçi';
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>CARİ HESAP İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihKisa(v.bas)} – {tarihKisa(v.bit)}</b></span>
        <span>Kapsam: {kapsam}{secimVar ? ` · ${satirlar.length} seçili cari` : ` · ${satirlar.length} cari`}</span>
        <span>Tutarlar: TL karşılığı (hareket kuru)</span><span>Vadesi geçen: bugüne göre</span>
      </div>
      <table className="a4-t ci-a4t">
        <thead><tr><th>Kod</th><th>Ünvan</th><th>Devir</th><th>Borç</th><th>Alacak</th><th>Bakiye</th><th>Vadesi geçen</th></tr></thead>
        <tbody>
          {bolumler.map(([ad, l]) => l.length === 0 ? null : [
            <tr key={ad} className="ci-a4grup"><td colSpan={7}>{ad} ({l.length})</td></tr>,
            ...l.map(c => (
              <tr key={c.id}><td>{c.kod}</td><td>{c.ad}</td><td>{p(c.devir)}</td><td>{p(c.donemBorc)}</td><td>{p(c.donemAlacak)}</td>
                <td>{bakiyeMetni(c.bakiye)}</td><td>{Math.abs(c.vadesiGecen) > 0.005 ? p(Math.abs(c.vadesiGecen)) : '—'}</td></tr>
            )),
            <tr key={ad + '-t'} className="ci-a4top"><td colSpan={2}>{ad === 'MÜŞTERİLER' ? 'Müşteriler' : 'Tedarikçiler'} toplamı</td>
              <td>{p(t(l, c => c.devir))}</td><td>{p(t(l, c => c.donemBorc))}</td><td>{p(t(l, c => c.donemAlacak))}</td>
              <td>{bakiyeMetni(t(l, c => c.bakiye))}</td><td>{p(t(l, c => Math.abs(c.vadesiGecen)))}</td></tr>,
          ])}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Alacağımız (borçlu cariler)</td><td>{paraYaz(alacak)}</td></tr>
        <tr><td>Borcumuz (alacaklı cariler)</td><td>{paraYaz(borc)}</td></tr>
        <tr><td>Vadesi geçen alacak / borç</td><td>{p(t(satirlar.filter(c => c.vadesiGecen > 0), c => c.vadesiGecen))} / {p(-t(satirlar.filter(c => c.vadesiGecen < 0), c => c.vadesiGecen))}</td></tr>
        <tr className="kalan ki-kalan"><td>NET POZİSYON</td><td>{paraYaz(alacak - borc)}</td></tr>
      </tbody></table>
      <p className="a4-not">Devir: dönem başından önceki bakiye. Bakiye = devir + dönem borç − dönem alacak (B: cari borçlu, A: cari alacaklı).
        Hareketler Kasa › Cari Ekstre ile aynı kümeden. Vadesi geçen: karşı yöndeki hareket önce vadesi en eski kalemi kapatır.</p>
      <div className="a4-imza"><div>Hazırlayan<br />{duzenleyen || 'Ad Soyad'} · İmza</div><div>Onaylayan<br />Mali İşler · Kaşe · İmza</div></div>
    </div>
  );
}

/**
 * CARİ HESAP MUTABAKAT MEKTUBU - seçili (yoksa bakiyesi olan) her cariye bir sayfa.
 * Bakiye dönem sonu (bitiş tarihi) itibarıyla; dövizli cari kendi para biriminde de yazılır.
 */
export function MutabakatMektuplari({ v, satirlar, antet, duzenleyen }: {
  v: CariIcmal; satirlar: CariIcmalSatiri[]; antet: Record<string, unknown> | null; duzenleyen: string;
}) {
  const p = (n: number) => para.format(n);
  return (<>
    {satirlar.map(c => {
      // Yalnız TL'si olan caride para birimi satırı tekrar olurdu - dövizli cariye yazılır.
      const doviz = c.doviz.split(';').some(x => x && !x.startsWith('TL:')) ? dovizBakiyeMetni(c.doviz) : '';
      return (
        <div key={c.id} className="hi-a4 ci-mektup">
          <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
          <h3>CARİ HESAP MUTABAKAT MEKTUBU</h3>
          <p><b>Sayın {c.ad}</b>{c.kod ? ` (${c.kod})` : ''},</p>
          <p>Şirketimiz kayıtlarında {tarihKisa(v.bit)} tarihi itibarıyla cari hesabınız{' '}
            <b>{p(Math.abs(c.bakiye))} TL {c.bakiye > 0.005 ? 'BORÇ' : c.bakiye < -0.005 ? 'ALACAK' : ''}</b> bakiye vermektedir.</p>
          {doviz && <p>Para birimi bazında: <b>{doviz}</b> (B: borç, A: alacak).</p>}
          <p>Mutabık olduğunuz takdirde bu mektubun bir örneğini imzalayıp kaşeleyerek, mutabık değilseniz hesap
            ekstrenizle birlikte 15 gün içinde tarafımıza iletmenizi rica ederiz.</p>
          <table className="a4-t"><thead><tr><th>Tarih</th><th>Bakiye (TL)</th><th>B / A</th></tr></thead>
            <tbody><tr><td>{tarihKisa(v.bit)}</td><td>{p(Math.abs(c.bakiye))}</td><td>{c.bakiye > 0.005 ? 'B' : c.bakiye < -0.005 ? 'A' : '—'}</td></tr></tbody></table>
          <p style={{ marginTop: 16 }}>☐ Mutabıkız &nbsp;&nbsp;&nbsp; ☐ Mutabık değiliz (ekstremiz ektedir)</p>
          <div className="a4-imza"><div>{String(antet?.unvan ?? antet?.ad ?? 'Şirketimiz')}<br />Kaşe · İmza</div><div>{c.ad}<br />Kaşe · İmza</div></div>
        </div>
      );
    })}
  </>);
}
