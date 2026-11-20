import type { ReactNode } from 'react';
import type { AcikLabRaporu, AcikLabOnceki } from '../../api/uclar/raporGonderim';
import { gunNokta, tarihSaat } from '../../bilesenler/bicim';
import { cinsiyetAdi } from '../../bilesenler/kisiKodlari';
import { c } from '../../dil/ceviri';

/**
 * TIBBİ LABORATUVAR TETKİK SONUÇ RAPORU (1394; kullanıcı 20.11.2026: "rapor sayfası için bakanlığın standardı vardı ona
 * bak" - kaynak Ekranlar/Lab'daki iki örnek rapor; mockup radyoloji_rapor_hasta_goruntuleme.html §7).
 *
 * Hastanın / gönderen doktorun bağlantıda gördüğü lab sonucu: başlık (kurum), kimlik bloğu (hasta, maskeli T.C., doğum /
 * cinsiyet, dosya / PROTOKOL no, rapor no, ÖRNEK no, isteyen, kurum, şube), zaman bloğu (istem, numune alma, kabul, uzman
 * onay, basım), tablo (Tetkik Adı, Sonuç, Durum, Birim, Referans Aralığı / Karar Sınırı, Geçmiş Sonuç ×2), işaret
 * açıklaması, uzman ve dipnotlar.
 *
 * DURUM OKLARI (kullanıcı: "H yerine yukarı / aşağı ok olsun.. panik için çift ok"): ↑ yüksek · ↓ düşük · ↑↑ kritik
 * yüksek · ↓↓ kritik düşük. Bayrak sunucudan (N / L / H / LL / HH + panik).
 */
export function durumOku(bayrak: string, panik: boolean): { ok: string; sinif: string } | null {
  const b = (bayrak || '').toUpperCase();
  const yon = b.startsWith('H') ? 'h' : b.startsWith('L') ? 'l' : '';
  if (!yon) return null;
  const kritik = panik || b === 'HH' || b === 'LL';
  return { ok: (yon === 'h' ? '↑' : '↓').repeat(kritik ? 2 : 1), sinif: `ls-ok ${yon}${kritik ? ' pnk' : ''}` };
}

function Ok({ bayrak, panik }: { bayrak: string; panik: boolean }) {
  const d = durumOku(bayrak, panik);
  return d ? <span className={d.sinif} title={d.ok.length === 2 ? c('Kritik değer') : undefined}>{d.ok}</span> : null;
}

function Onceki({ v }: { v: AcikLabOnceki | null }) {
  if (!v || !v.deger) return <td className="ls-onc bos">—</td>;
  const d = durumOku(v.bayrak, v.panik);
  return <td className={`ls-onc${d ? (d.sinif.includes(' h') ? ' yuk' : ' dus') : ''}`}>{v.deger}{d && <> <Ok bayrak={v.bayrak} panik={v.panik} /></>}</td>;
}

export function LabSonucRaporu({ lab, kurum, baglanti }: {
  lab: AcikLabRaporu;
  kurum: Record<string, unknown>;
  /** Doğrulama adresi (dipnotta). */
  baglanti?: string;
}) {
  const b = lab.baslik;
  const alan = (ad: string, deger: ReactNode) => <div><span>{ad}</span><b>{deger || '—'}</b></div>;
  const gunler = lab.gecmisGunler ?? [];
  const adres = [kurum.adres, [kurum.ilce, kurum.il].filter(Boolean).join(' / ')].filter(x => String(x ?? '').trim() !== '').join(' · ');
  return (
    <div className="ls-rapor" data-testid="lab-sonuc-raporu">
      <div className="ls-bas">
        <small>{String(kurum.unvan ?? '').toLocaleUpperCase('tr')}</small>
        <b>{c('Tıbbi Laboratuvar Tetkik Sonuç Raporu')}</b>
      </div>
      <div className="ls-kimlik">
        {alan(c('Hastanın Adı, Soyadı'), b.hasta)}
        {alan(c('Tetkiki İsteyen'), b.isteyen)}
        {alan(c('T.C. Kimlik No'), b.tc)}
        {alan(c('Gönderileceği Yer'), b.gonderilecekYer)}
        {alan(c('Doğum Tarihi / Cinsiyet'), [b.dogumTarihi ? gunNokta(b.dogumTarihi) : '', cinsiyetAdi(b.cinsiyet)].filter(Boolean).join(' / '))}
        {alan(c('Kurum'), b.kurum)}
        {alan(c('Dosya No / Protokol No'), [b.dosyaNo, b.protokolNo].filter(Boolean).join(' / '))}
        {alan(c('Şube'), b.sube)}
        {alan(c('Rapor Numarası'), b.raporNo)}
        {alan(c('Örnek No'), b.ornekNo)}
      </div>
      <div className="ls-kimlik ls-zaman">
        {alan(c('Tetkik İstem Zamanı'), b.istemZamani ? tarihSaat(b.istemZamani) : '')}
        {alan(c('Numune Kabul Zamanı'), b.numuneKabul ? tarihSaat(b.numuneKabul) : '')}
        {alan(c('Numune Alma Zamanı'), b.numuneAlma ? tarihSaat(b.numuneAlma) : '')}
        {alan(c('Uzman Onay Zamanı'), b.onayZamani ? tarihSaat(b.onayZamani) : '')}
        {alan(c('Rapor Basım Zamanı'), b.basimZamani ? tarihSaat(b.basimZamani) : '')}
      </div>
      <div className="ls-bolum"><b>{c(lab.bolumAd)}</b>{b.onayZamani && <span>{c('Uzman Onay Tarihi')}: {tarihSaat(b.onayZamani)}</span>}</div>
      <div className="ls-kaydir">
        <table className="ls-tablo">
          <thead>
            <tr>
              <th>{c('Tetkik Adı')}</th><th className="sag">{c('Sonuç')}</th><th className="orta">{c('Durum')}</th><th>{c('Birim')}</th>
              <th>{c('Referans Aralığı / Karar Sınırı')}</th>
              {/* GEÇMİŞ İKİ SONUÇ (kullanıcı: "son 2 gönderimin sonuçlarını da ekle"): hastanın önceki iki başvuru günü. */}
              {gunler.map(g => <th key={g} className="sag ls-onc-b">{c('Geçmiş Sonuç')}<small>{gunNokta(g)}</small></th>)}
            </tr>
          </thead>
          <tbody>
            {lab.satirlar.length === 0 && <tr><td colSpan={5 + gunler.length} className="ls-bos">{c('Gösterilecek sonuç yok.')}</td></tr>}
            {lab.satirlar.map((s, i) => {
              const d = durumOku(s.bayrak, s.panik);
              return (
                <tr key={i}>
                  <td><b>{s.ad}</b>{s.ornekNo && <small>{s.ornekNo}</small>}{s.yorum && <small className="ls-yorum">{s.yorum}</small>}</td>
                  <td className={`sag ls-sonuc${d ? (d.sinif.includes(' h') ? ' yuk' : ' dus') : ''}`}>{s.sonuc}</td>
                  <td className="orta"><Ok bayrak={s.bayrak} panik={s.panik} /></td>
                  <td>{s.birim}</td>
                  <td className="ls-ref">{s.referans}{s.kararNotu && <small>{s.kararNotu}</small>}</td>
                  {gunler.length > 0 && <Onceki v={s.onceki1} />}
                  {gunler.length > 1 && <Onceki v={s.onceki2} />}
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      {lab.gizlenen > 0 && (
        <div className="ls-gizli" data-testid="lab-gizlenen">ℹ <b>{lab.gizlenen} {c('testinizin')}</b> {c('sonucu bu sayfada gösterilmez. Bu sonuç için lütfen hekiminize ya da kurumumuza başvurun')}
          {kurum.telefon ? <>: <b>{String(kurum.telefon)}</b></> : '.'}</div>
      )}
      <div className="ls-lejant">
        <span><span className="ls-ok h">↑</span> {c('Yüksek')}</span><span><span className="ls-ok l">↓</span> {c('Düşük')}</span>
        <span><span className="ls-ok h pnk">↑↑</span> {c('Kritik Yüksek')}</span><span><span className="ls-ok l pnk">↓↓</span> {c('Kritik Düşük')}</span>
      </div>
      {lab.uzman?.ad && (
        <div className="ls-imza"><div>{lab.uzman.ad}{lab.uzman.tescilNo && <small>{c('Diploma / Tescil No')}: {lab.uzman.tescilNo}</small>}
          <em>✔ {c('Onaylandı')}{b.onayZamani ? ` · ${tarihSaat(b.onayZamani)}` : ''}</em></div></div>
      )}
      <ol className="ls-dipnot">
        <li>{c('Onaysız raporlar geçersizdir.')}</li>
        <li>{c('Bu rapor, yalnızca analizi yapılan numuneyi kapsamaktadır.')}</li>
        <li>{c('Uygunsuz örnekler veya test sonuçları ile ilgili açıklamalar, varsa, ilgili testin altında not olarak belirtilmektedir.')}</li>
        {baglanti && <li>{c('Bu raporun doğruluğunu şu adresten denetleyebilirsiniz')}: {baglanti.replace(/^https?:\/\//, '')}</li>}
      </ol>
      <div className="ls-alt"><span>{[String(kurum.unvan ?? ''), adres, String(kurum.telefon ?? '')].filter(Boolean).join(' · ')}</span></div>
    </div>
  );
}
