import type { ListeSatiri } from '../api/sozlesme';
import { c } from '../dil/ceviri';
import { OnizlemeBasligi } from './TarafAramaCari';
import { metin, tarihYaz } from './tarafDuzeni';

/**
 * İLGİLİ KİŞİ ARAMASI - düzen bileşenleri (mockup Ekranlar/taraf_arama.html "İlgili Kişi", kullanıcı 05.11.2026).
 * Kaynak `kisi` (taraf kisi = 1): bağlı cari, görev, cep, telefon, e-posta. Pasif kişi gelmez. Mockup'taki KVKK /
 * karar verici / son temas kolonları şemada yok - geldiğinde buraya eklenir.
 */

export function KisiBasliklar() {
  return (
    <>
      <th className="ad">Ad Soyad</th>
      <th>Bağlı Kurum</th>
      <th>Görev</th>
      <th>Cep</th>
      <th className="ta-g2">Telefon</th>
      <th className="ta-g2">E-posta</th>
      <th className="hiza-orta ta-g2">Eklendi</th>
    </>
  );
}

export function KisiHucreler({ s }: { s: ListeSatiri }) {
  return (
    <>
      <td className="ad"><b>{metin(s.unvan)}</b>{metin(s.kod) && <small>{metin(s.kod)}</small>}</td>
      <td><span className="ta-kirp">{metin(s.bagliCari) || <span className="gh-sonuk">—</span>}</span></td>
      <td><span className="ta-kirp">{metin(s.gorev) || <span className="gh-sonuk">—</span>}</span></td>
      <td><span className="ta-kirp dar">{metin(s.cepTel) || <span className="gh-sonuk">—</span>}</span></td>
      <td className="ta-g2"><span className="ta-kirp dar">{metin(s.telefon) || <span className="gh-sonuk">—</span>}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{metin(s.eposta) || <span className="gh-sonuk">—</span>}</span></td>
      <td className="hiza-orta ta-g2">{tarihYaz(s.eklemeTarihi) || <span className="gh-sonuk">—</span>}</td>
    </>
  );
}

export function KisiOnizleme({ s, onKapat }: { s: ListeSatiri | undefined; onKapat(): void }) {
  if (!s) return <div className="ta-on"><OnizlemeBasligi onKapat={onKapat} /><div className="gh-sonuk">{c('Satır seçin')}</div></div>;
  const iletisimVar = metin(s.cepTel) || metin(s.telefon) || metin(s.eposta);
  return (
    <div className="ta-on">
      <OnizlemeBasligi onKapat={onKapat} />
      <h4>{metin(s.unvan)}</h4>
      <div className="ta-kod">{[metin(s.gorev), metin(s.bagliCari)].filter(Boolean).join(' · ')}</div>

      <div className="ta-blok"><h5>İletişim</h5>
        {metin(s.cepTel) && <div className="ta-sat"><span>Cep</span><span>{metin(s.cepTel)}</span></div>}
        {metin(s.telefon) && <div className="ta-sat"><span>Telefon</span><span>{metin(s.telefon)}</span></div>}
        {metin(s.eposta) && <div className="ta-sat"><span>E-posta</span><span>{metin(s.eposta)}</span></div>}
        {!iletisimVar && <div className="gh-sonuk">—</div>}
      </div>

      <div className="ta-blok"><h5>Kayıt</h5>
        {metin(s.bagliCari) && <div className="ta-sat"><span>Bağlı cari</span><span>{metin(s.bagliCari)}</span></div>}
        {metin(s.kod) && <div className="ta-sat"><span>Kişi kodu</span><span>{metin(s.kod)}</span></div>}
        {tarihYaz(s.eklemeTarihi) && <div className="ta-sat"><span>Eklendi</span><span>{tarihYaz(s.eklemeTarihi)}</span></div>}
      </div>
    </div>
  );
}
