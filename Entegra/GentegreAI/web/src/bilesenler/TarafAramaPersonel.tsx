import type { ListeSatiri } from '../api/sozlesme';
import { sayi } from './bicim';
import { c } from '../dil/ceviri';
import { OnizlemeBasligi } from './TarafAramaCari';
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
      <td>{metin(s.kod) || <span className="gh-sonuk">—</span>}</td>
      <td className="ad">
        <b>{metin(s.unvan)}</b>
        {metin(s.eksik) && <small>eksik: {metin(s.eksik)}</small>}
      </td>
      <td><span className="ta-kirp dar">{metin(s.rolAdi) || <span className="gh-sonuk">—</span>}</span></td>
      <td><span className="ta-kirp">{metin(s.departmanAdi) || <span className="gh-sonuk">—</span>}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{metin(s.gorev) || <span className="gh-sonuk">—</span>}</span></td>
      <td><span className="ta-kirp dar">{metin(s.cepTel) || metin(s.telefon) || <span className="gh-sonuk">—</span>}</span></td>
      <td><BugunNoktasi s={s} /><span className="ta-kirp" style={{ display: 'inline-block', verticalAlign: 'middle' }}>{metin(s.bugun) || 'Çalışıyor'}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{metin(s.yoneticiAdi) || <span className="gh-sonuk">—</span>}</span></td>
      <td className="hiza-orta ta-g2">{tarihYaz(s.iseGirisTarihi) || <span className="gh-sonuk">—</span>}</td>
      <td className="hiza-orta">{kalan || <span className="gh-sonuk">—</span>}</td>
    </>
  );
}

export function PersonelOnizleme({ s, onKapat }: { s: ListeSatiri | undefined; onKapat(): void }) {
  if (!s) return <div className="ta-on"><OnizlemeBasligi onKapat={onKapat} /><div className="gh-sonuk">{c('Satır seçin')}</div></div>;
  const k = sayiya(s.bugunKod);
  const kalan = s.kalanIzin == null || s.kalanIzin === '' ? '' : sayi.format(sayiya(s.kalanIzin));
  const hak = s.hakToplam == null || s.hakToplam === '' ? '' : sayi.format(sayiya(s.hakToplam));
  const talep = sayiya(s.onaydaTalep);
  const iletisimVar = metin(s.cepTel) || metin(s.telefon) || metin(s.eposta);
  return (
    <div className="ta-on">
      <OnizlemeBasligi onKapat={onKapat} />
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
        <div className="ta-sat"><span>Durum</span><span><BugunNoktasi s={s} />{metin(s.bugun) || 'Çalışıyor'}</span></div>
        {metin(s.yoneticiAdi) && <div className="ta-sat"><span>Yönetici</span><span>{metin(s.yoneticiAdi)}</span></div>}
      </div>

      <div className="ta-blok"><h5>İletişim</h5>
        {metin(s.cepTel) && <div className="ta-sat"><span>Cep</span><span>{metin(s.cepTel)}</span></div>}
        {metin(s.telefon) && <div className="ta-sat"><span>Telefon</span><span>{metin(s.telefon)}</span></div>}
        {metin(s.eposta) && <div className="ta-sat"><span>E-posta</span><span>{metin(s.eposta)}</span></div>}
        {!iletisimVar && <div className="gh-sonuk">—</div>}
      </div>

      <div className="ta-blok"><h5>Çalışma</h5>
        {tarihYaz(s.iseGirisTarihi) && <div className="ta-sat"><span>İşe giriş</span><span>{tarihYaz(s.iseGirisTarihi)}</span></div>}
        {metin(s.kidem) && <div className="ta-sat"><span>Kıdem</span><span>{metin(s.kidem)}</span></div>}
        {(kalan || hak) && <div className="ta-sat"><span>Yıllık izin</span><span>{kalan || '0'} / {hak || '—'} gün</span></div>}
        <div className="ta-sat"><span>Onayda talep</span><span className={talep > 0 ? 'ta-borc' : ''}>{talep > 0 ? sayi.format(talep) : 'yok'}</span></div>
      </div>
    </div>
  );
}
