import type { ListeSatiri } from '../api/sozlesme';
import { Bos, IletisimBlok, Sat, yoksaTire } from './TarafAramaOrtak';
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
      <td><span className="ta-kirp">{yoksaTire(s.bagliCari)}</span></td>
      <td><span className="ta-kirp">{yoksaTire(s.gorev)}</span></td>
      <td><span className="ta-kirp dar">{yoksaTire(s.cepTel)}</span></td>
      <td className="ta-g2"><span className="ta-kirp dar">{yoksaTire(s.telefon)}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{yoksaTire(s.eposta)}</span></td>
      <td className="hiza-orta ta-g2">{tarihYaz(s.eklemeTarihi) || <Bos />}</td>
    </>
  );
}

export function KisiOnizleme({ s }: { s: ListeSatiri }) {
  return (
    <>
      <h4>{metin(s.unvan)}</h4>
      <div className="ta-kod">{[metin(s.gorev), metin(s.bagliCari)].filter(Boolean).join(' · ')}</div>

      <IletisimBlok s={s} />

      <div className="ta-blok"><h5>Kayıt</h5>
        <Sat etiket="Bağlı cari" v={metin(s.bagliCari)} />
        <Sat etiket="Kişi kodu" v={metin(s.kod)} />
        <Sat etiket="Eklendi" v={tarihYaz(s.eklemeTarihi)} />
      </div>
    </>
  );
}
