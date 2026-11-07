import type { ListeSatiri } from '../api/sozlesme';
import { sayi } from './bicim';
import { Bos, IletisimBlok, Sat, yoksaTire } from './TarafAramaOrtak';
import { metin, sayiya, tarihYaz } from './tarafDuzeni';

/**
 * PERSONEL ARAMASI - düzen bileşenleri (mockup Ekranlar/taraf_arama.html "Personel", kullanıcı 05.11.2026: "personel
 * ve ilgili aramayı da bu standartlara göre yap"). Veri personel listesinin satırından (v_personel_durum: bugün,
 * kıdem, kalan izin, onayda talep, eksik bilgi, doğum günü). KİMLİK NO KOLONDA YOK (kullanıcı: "kimlik no olmasın");
 * ham kimlik no ile ARAMA sürer (08.10.2026 isteği). Ayrılmış / pasif personel hiç gelmez.
 *
 * bugunKod (963): 0 pasif · 1 çalışıyor · 2 izinde · 3 raporlu · 4 deneme süresinde.
 */

function BugunNoktasi({ s }: { s: ListeSatiri }) {
  const k = sayiya(s.bugunKod);
  const sinif = k === 2 ? 'g' : k === 3 ? 'k' : k === 4 ? 's' : 'y';
  return <span className={`ta-nokta ${sinif}`} />;
}

export function PersonelBasliklar() {
  return (
    <>
      <th>Sicil</th>
      <th className="ad">Ad Soyad</th>
      <th>Rol</th>
      <th>Bölüm</th>
      <th className="ta-g2">Görev</th>
      <th>Cep</th>
      <th>Bugün</th>
      <th className="ta-g2">Yönetici</th>
      <th className="hiza-orta ta-g2">İşe Giriş</th>
      <th className="hiza-orta">Kalan İzin</th>
    </>
  );
}

export function PersonelHucreler({ s }: { s: ListeSatiri }) {
  const kalan = s.kalanIzin == null || s.kalanIzin === '' ? '' : `${sayi.format(sayiya(s.kalanIzin))} g`;
  return (
    <>
      <td>{yoksaTire(s.kod)}</td>
      <td className="ad">
        <b>{metin(s.unvan)}</b>
        {metin(s.eksik) && <small>eksik: {metin(s.eksik)}</small>}
      </td>
      <td><span className="ta-kirp dar">{yoksaTire(s.rolAdi)}</span></td>
      <td><span className="ta-kirp">{yoksaTire(s.departmanAdi)}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{yoksaTire(s.gorev)}</span></td>
      <td><span className="ta-kirp dar">{metin(s.cepTel) || metin(s.telefon) || <Bos />}</span></td>
      <td><BugunNoktasi s={s} /><span className="ta-kirp" style={{ display: 'inline-block', verticalAlign: 'middle' }}>{metin(s.bugun) || 'Çalışıyor'}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{yoksaTire(s.yoneticiAdi)}</span></td>
      <td className="hiza-orta ta-g2">{tarihYaz(s.iseGirisTarihi) || <Bos />}</td>
      <td className="hiza-orta">{kalan || <Bos />}</td>
    </>
  );
}

export function PersonelOnizleme({ s }: { s: ListeSatiri }) {
  const k = sayiya(s.bugunKod);
  const kalan = s.kalanIzin == null || s.kalanIzin === '' ? '' : sayi.format(sayiya(s.kalanIzin));
  const hak = s.hakToplam == null || s.hakToplam === '' ? '' : sayi.format(sayiya(s.hakToplam));
  const talep = sayiya(s.onaydaTalep);
  return (
    <>
      <h4>{metin(s.unvan)}</h4>
      <div className="ta-kod">
        {[metin(s.kod), metin(s.rolAdi), metin(s.departmanAdi), metin(s.gorev)].filter(Boolean).join(' · ')}
      </div>
      {k === 2 && <div className="ta-uyar">🏖 {metin(s.bugun) || 'İzinde'}</div>}
      {k === 3 && <div className="ta-uyar kir">🩺 {metin(s.bugun) || 'Raporlu'}</div>}
      {k === 4 && <div className="ta-uyar">⏳ {metin(s.bugun) || 'Deneme süresinde'}</div>}
      {metin(s.eksik) && <div className="ta-uyar kir">⚠ Eksik bilgi: {metin(s.eksik)}</div>}
      {sayiya(s.dogumBugun) === 1 && <div className="ta-uyar">🎂 Doğum günü bugün</div>}

      <div className="ta-blok"><h5>Bugün</h5>
        <Sat etiket="Durum" v={<><BugunNoktasi s={s} />{metin(s.bugun) || 'Çalışıyor'}</>} />
        <Sat etiket="Yönetici" v={metin(s.yoneticiAdi)} />
      </div>

      <IletisimBlok s={s} />

      <div className="ta-blok"><h5>Çalışma</h5>
        <Sat etiket="İşe giriş" v={tarihYaz(s.iseGirisTarihi)} />
        <Sat etiket="Kıdem" v={metin(s.kidem)} />
        {(kalan || hak) && <Sat etiket="Yıllık izin" v={`${kalan || '0'} / ${hak || '—'} gün`} />}
        <Sat etiket="Onayda talep" v={talep > 0 ? sayi.format(talep) : 'yok'} sinif={talep > 0 ? 'ta-borc' : undefined} />
      </div>
    </>
  );
}
