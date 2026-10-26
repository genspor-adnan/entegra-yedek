import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../../sayfalar/hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../../sayfalar/kurum/icmal/kurumIcmalStil';
import { satirTutari, type SatirDurumu } from '../../sayfalar/belgeSatir';
import { hamSayi, para } from '../bicim';
import { useCariSatiri } from '../cariSatiri';
import { CiktiMenusu } from '../cikti/CiktiMenusu';
import { IcmalAntet } from '../cikti/IcmalAntet';

/**
 * TEKLİF ÇIKTISI (kullanıcı 26.10.2026: "teklif kartına kapat butonu soluna "Teklif" önizleme/yazdır/kaydet
 * butonu ekle icmal gibi"): icmallerin Çıktı Menüsü (Baskı Önizleme · Yazdır · PDF / Word / Excel / HTML) +
 * teklifin A4'ü - antet, müşteri, teklif bilgileri, kalemler, toplamlar, imza.
 *
 * Rakamlar kartın gösterdiğiyle aynı: satır tutarı satirTutari (kalem gridi), toplamlar kartın dip toplamı
 * (`toplam` - kaydedilmemiş kalem de dahil). Ayrı hesap yok.
 */
const STIL = `
.tk-a4 .tk-t th:nth-child(1), .tk-a4 .tk-t td:nth-child(1) { width: 4%; text-align: center }
.tk-a4 .tk-t th:nth-child(2) { width: 40% }
.tk-a4 .tk-t td:nth-child(2) { white-space: normal; text-align: left }
.tk-a4 .tk-t th:nth-child(2) { text-align: left }
.tk-a4 .tk-dip { margin: 6px 0 0 auto; width: 46%; border-collapse: collapse; font-size: 10px }
.tk-a4 .tk-dip td { border: 1px solid #ccc; padding: 2px 6px; text-align: right }
.tk-a4 .tk-dip td:first-child { text-align: left }
.tk-a4 .tk-dip tr.b td { font-weight: bold; background: #f1f4f8 }
.tk-a4 .tk-kosul { margin-top: 10px; font-size: 10px; line-height: 1.5 }
`;

export function TeklifCiktisi({ cariId, belgeNo, revizeNo, tarih, gecerlilikGun, konu, teslim, aciklama, satirlar, toplam }: {
  cariId: number;
  belgeNo: string;
  revizeNo: string;
  /** Teklif tarihi (yerel ISO / datetime-local). */
  tarih: string;
  gecerlilikGun: string;
  konu: string;
  teslim: string;
  aciklama: string;
  satirlar: SatirDurumu[];
  toplam: { matrah: number; kdv: number; genel: number };
}) {
  const { kullanici } = useOturum();
  const cari = useCariSatiri(cariId);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const gun = hamSayi(gecerlilikGun);
  const t = tarih ? new Date(tarih) : null;
  const tarihT = (d: Date | null) => (d && !Number.isNaN(d.getTime()) ? d.toLocaleDateString('tr-TR') : '—');
  const gecerlilik = t && gun > 0 ? new Date(t.getTime() + gun * 86400000) : null;
  const kalemler = satirlar.filter(s => s.stokId || s.hizmetId || s.stokAdi);
  const no = [belgeNo, revizeNo && `Rev. ${revizeNo}`].filter(Boolean).join(' · ') || '(kaydedilmedi)';
  const adres = [cari?.adres, [cari?.ilce, cari?.il].filter(Boolean).join(' / ')].filter(Boolean).join(' · ');

  return (
    <>
      <style>{hastaIcmalStili + kurumIcmalStili + STIL}</style>
      <CiktiMenusu etiket="Teklif" dosyaAdi={`Teklif ${belgeNo || ''} ${String(cari?.unvan ?? '')}`.trim()}>
        <div className="hi-a4 tk-a4">
          <IcmalAntet antet={antet} duzenleyen={kullanici?.ad ?? ''} />
          <h3>{konu ? `TEKLİF - ${konu.toLocaleUpperCase('tr-TR')}` : 'TEKLİF'}</h3>
          <div className="a4-hasta">
            <span>Sayın: <b>{String(cari?.unvan ?? '')}</b></span>
            <span>Teklif No: <b>{no}</b></span>
            <span>{adres}</span>
            <span>Teklif Tarihi: <b>{tarihT(t)}</b></span>
            <span>{cari?.vkno ? `VKN / TCKN: ${cari.vkno}` : ''}</span>
            <span>Geçerlilik: <b>{gecerlilik ? `${tarihT(gecerlilik)} (${gun} gün)` : '—'}</b></span>
          </div>
          <table className="a4-t tk-t">
            <thead><tr><th>#</th><th>Ürün / Hizmet</th><th>Miktar</th><th>Birim Fiyat</th><th>İsk. %</th><th>KDV %</th><th>Tutar</th></tr></thead>
            <tbody>
              {kalemler.map((s, i) => {
                const adet = hamSayi(s.adet), fiyat = hamSayi(s.birimFiyat);
                const isk = [s.iskonto, s.iskonto2].map(hamSayi).filter(x => x > 0).join(' + ');
                return (
                  <tr key={s.anahtar}>
                    <td>{i + 1}</td>
                    <td>{s.stokAdi}{s.aciklama ? ` - ${s.aciklama}` : ''}</td>
                    <td>{adet.toLocaleString('tr-TR')} {s.birimAdi ?? ''}</td>
                    <td>{para.format(fiyat)}</td>
                    <td>{isk}</td>
                    <td>{hamSayi(s.kdv)}</td>
                    <td>{para.format(satirTutari(adet, fiyat, s.iskonto, s.iskonto2))}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          <table className="tk-dip"><tbody>
            <tr><td>Ara Toplam (KDV hariç)</td><td>{para.format(toplam.matrah)}</td></tr>
            <tr><td>KDV</td><td>{para.format(toplam.kdv)}</td></tr>
            <tr className="b"><td>GENEL TOPLAM</td><td>{para.format(toplam.genel)}</td></tr>
          </tbody></table>
          <div className="tk-kosul">
            {teslim && <div>Teslim Şekli: <b>{teslim}</b></div>}
            {aciklama && <div>Açıklama: {aciklama}</div>}
          </div>
          <div className="a4-imza"><div>Teklifi Veren<br />Kaşe · İmza</div><div>Teklifi Kabul Eden<br />Kaşe · İmza</div></div>
        </div>
      </CiktiMenusu>
    </>
  );
}
