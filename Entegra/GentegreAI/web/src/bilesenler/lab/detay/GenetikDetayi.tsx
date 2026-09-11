import { tarihSaat } from '../../bicim';
import {
  ZIGOSITE, sayi, } from '../../labKodlari';
import { dizi, metin } from './ortak';

/** Panelde cizilen sunucu kaydi - alanlar kaynaga gore degisir. */
type Kayit = Record<string, unknown>;

const KALITIM: Record<number, string> = {
  1: 'OD', 2: 'OR', 3: 'X’e bağlı', 4: 'Mitokondriyal', 5: 'Somatik',
};

export function GenetikDetayi({ veri }: { veri: Kayit }) {
  const v = (veri.vaka ?? {}) as Kayit;
  const varyantlar = dizi(veri.varyantlar);

  const sinif = (k: unknown) => {
    const n = Number(k ?? 0);
    if (n === 5 || n === 4) return 'rozet hata';        // patojenik / olası
    if (n === 3) return 'rozet uyari';                  // VUS
    return 'rozet olumlu';                              // benign / olası benign
  };
  const SINIF: Record<number, string> = {
    1: 'Benign', 2: 'Olası benign', 3: 'VUS', 4: 'Olası patojenik', 5: 'Patojenik',
  };

  return (
    <>
      {/* VARYANT TABLOSU TAM GENİŞLİK (mockup lab_genetik.html): on bir
          kolonu yarım sütuna sıkıştırınca sınıf ve rapor işareti kırpılıyor -
          oysa raporlanacak varyantı seçmek bu ekranın işi. */}
      <div className="kagrup">
        <h6>
          🧬 Varyantlar
          <span className="sp">ACMG/AMP 2015 · sınıf sunucuda türetilir</span>
        </h6>
        <div className="detay-kaydir">
          <table className="detay-tablo">
            <thead>
              <tr>
                <th>Gen</th><th>Transkript · HGVS c.</th><th>HGVS p.</th>
                <th className="orta">Zigosite</th><th className="orta">Kalıtım</th>
                <th className="sag">Derinlik / VAF</th><th className="sag">gnomAD AF</th>
                <th>ClinVar</th><th>ACMG kriterleri</th>
                <th className="orta">Sınıf</th><th className="orta">Doğrulama</th>
                <th className="orta">Rapor</th>
              </tr>
            </thead>
            <tbody>
              {varyantlar.map(x => (
                <tr key={String(x.id)}>
                  <td><b>{metin(x.genSembol)}</b></td>
                  <td>
                    {metin(x.transkript) ? `${metin(x.transkript)}:` : ''}
                    {metin(x.hgvsC) || '—'}
                  </td>
                  <td>{metin(x.hgvsP) || '—'}</td>
                  <td className="orta">{ZIGOSITE[Number(x.zigosite ?? 0)] ?? '—'}</td>
                  <td className="orta">{KALITIM[Number(x.kalitim ?? 0)] ?? '—'}</td>
                  {/* VAF ORAN olarak saklanır (0,49 = %49): başına yüzde
                      işareti koymak değeri yüz kat küçük gösteriyordu. */}
                  <td className="sag">
                    {x.derinlik ? `${sayi(x.derinlik, 0)}×` : '—'}
                    {x.vaf ? ` · ${sayi(x.vaf, 2)}` : ''}
                  </td>
                  <td className="sag">{x.gnomadAf ? sayi(x.gnomadAf, 5) : '—'}</td>
                  <td>{metin(x.clinVar) || '—'}</td>
                  {/* ACMG KANIT KODLARI sınıfın gerekçesidir: sınıf tek
                      başına "neden patojenik" sorusunu cevaplamaz. */}
                  <td className="not">
                    {Array.isArray(x.acmg) && (x.acmg as string[]).length > 0
                      ? (x.acmg as string[]).join(' · ') : '—'}
                  </td>
                  <td className="orta">
                    <span className={sinif(x.sinif)}>
                      {SINIF[Number(x.sinif ?? 0)] ?? '—'}
                    </span>
                    {x.sinifElle ? <span className="not" title="Uzman değiştirdi"> ✎</span>
                                 : null}
                  </td>
                  <td className="orta not">
                    {Number(x.dogrulama ?? 0) === 2 ? `Sanger · ${metin(x.dogrulamaYontem)}`
                      : Number(x.dogrulama ?? 0) === 1 ? 'bekliyor' : '—'}
                  </td>
                  <td className="orta">
                    {x.raporla ? <span className="rozet olumlu">Evet</span>
                               : <span className="rozet gri">Hayır</span>}
                  </td>
                </tr>
              ))}
              {varyantlar.length === 0 && (
                <tr><td colSpan={12} className="not">Varyant kaydedilmedi.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className="lab-ikili">
      <div className="kagrup">
        <h6>Vaka</h6>
        <div className="lab-alanlar">
          <div className="fld">
            <label>Vaka no</label>
            <div className="deger buyuk">{metin(v.vakaNo) || '—'}</div>
          </div>
          <div className="fld">
            <label>Test / panel</label>
            <div className="deger">{metin(v.panel) || metin(v.tetkikAd) || '—'}</div>
          </div>
          {/* ONAM: KVKK md. 6 - onamsız rapor yok. Ekranda da en üstte. */}
          <div className="fld">
            <label>Onam</label>
            <div className="deger">
              {v.onamTarihi
                ? <span className="rozet olumlu">
                    alındı · {tarihSaat(v.onamTarihi)}
                    {metin(v.onamSurum) ? ` · ${metin(v.onamSurum)}` : ''}
                  </span>
                : <span className="rozet hata">alınmadı</span>}
            </div>
          </div>
          <div className="fld">
            <label>Tesadüfi bulgu</label>
            <div className="deger">
              {Number(v.tesadufiBulgu ?? 0) === 1 ? 'bildirilsin' : 'bildirilmesin'}
            </div>
          </div>
          <div className="fld">
            <label>DNA (ng/µL · A260/280)</label>
            <div className="deger">
              {sayi(v.dnaKonsantrasyon, 1)} · {sayi(v.dnaSaflik, 2)}
            </div>
          </div>
          <div className="fld">
            <label>Run</label>
            <div className="deger">{metin(v.run) || '—'}</div>
          </div>
        </div>
        {metin(v.uzmanYorum) && <div className="ic sonuk">{metin(v.uzmanYorum)}</div>}
      </div>

      {/* RUN / KALİTE (mockup "Run / kalite · RUN-0931"): varyantın hangi
          koşullarda çağrıldığı sonucun kendisi kadar bağlayıcıdır - düşük
          kapsama, kontaminasyon ya da cinsiyet uyumsuzluğu varyantı
          şüpheli yapar. */}
      <div className="kagrup">
        <h6>Run / kalite <span className="sp">{metin(v.run) || 'run atanmadı'}</span></h6>
        <div className="lab-alanlar">
          <div className="fld">
            <label>Kapsama / ort. derinlik</label>
            <div className="deger">
              {v.kapsamaYuzde ? `%${sayi(v.kapsamaYuzde, 1)}` : '—'}
              {v.ortDerinlik ? ` · ${sayi(v.ortDerinlik, 0)}×` : ''}
            </div>
          </div>
          <div className="fld">
            <label>Kontaminasyon</label>
            <div className="deger">
              {v.kontaminasyon ? `%${sayi(v.kontaminasyon, 2)}` : '—'}
            </div>
          </div>
          <div className="fld">
            <label>Cinsiyet doğrulama</label>
            <div className="deger">
              {Number(v.cinsiyetDogrulama ?? 0) === 1
                ? <span className="rozet olumlu">uyumlu</span>
                : Number(v.cinsiyetDogrulama ?? 0) === 2
                  ? <span className="rozet hata">uyumsuz</span>
                  : '—'}
            </div>
          </div>
          <div className="fld">
            <label>Pipeline / referans</label>
            <div className="deger">
              {[metin(v.pipeline), metin(v.referansGenom)].filter(Boolean).join(' · ') || '—'}
            </div>
          </div>
        </div>
        {metin(v.oneriler) && (
          <div className="ic"><b>Öneriler:</b> {metin(v.oneriler)}</div>
        )}
        {metin(v.sinirliliklar) && (
          <div className="ic sonuk"><b>Sınırlılıklar:</b> {metin(v.sinirliliklar)}</div>
        )}
      </div>
      </div>
    </>
  );
}

/* ------------------------------------------------------------- dış lab ----
   Gönderim bir süreçtir: kurye, soğuk zincir ve satır durumları burada.  */
