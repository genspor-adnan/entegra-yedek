import { useState } from 'react';
import { api } from '../../../api/istemci';
import { guvenli, mesaj } from '../../mesaj';
import { tarihSaat } from '../../bicim';
import { KodSecim, MetinAlani, ZamanAlani, MUSTEHAKLIK } from './alanlar';
import type { BasvuruBilgi } from '../BasvuruSekmesi';

export function ProvizyonSekmesi({ bilgi, degistir, kilitli, kurumAdi, kurumlar,
                                  kurumTuru, belgeId, tarafId, hekimId,
                                  onTazele }: {
  bilgi: BasvuruBilgi;
  degistir(y: Partial<BasvuruBilgi>): void;
  kilitli: boolean;
  /** Kayitli basvuru id'si - servis cagrisi ancak KAYITLI belgede yapilir. */
  belgeId?: number;
  /** Hasta (belge.taraf_id) ve karsilayan hekim - police sorgusu ikisini ister. */
  tarafId?: number;
  hekimId?: number | null;
  /** Provizyon paylari belge satirlarina yazar - kart yeniden okunmali. */
  onTazele?(): void;
  /** Odeyen kurumun turu (taraf_kurum.tur): 1 Özel / 2 ÖSS / 3 SGK. */
  kurumTuru?: number;
  /** Belgenin odeyen kurumu - SGK bloÄunda bilgi olarak gosterilir. */
  kurumAdi?: string;
  /** Anlasmali kurumlar: ozel sigorta sirketi buradan secilir (tur 2). */
  kurumlar?: { id: number; ad: string; tur?: number }[];
}) {
  const m = MUSTEHAKLIK[Number(bilgi.sgkMustehaklik ?? 0)] ?? MUSTEHAKLIK[0];
  const [sigortaMesgul, setSigortaMesgul] = useState(false);

  /**
   * POLICE SORGUSU (430) - checkPolicy. Poliçe numarasi ZORUNLU: sigorta
   * sirketi kimlik numarasini tek basina kabul etmiyor ("poliçe null olamaz"),
   * numarayi bulan searchPolicy servisi ise test ortaminda yayinlanmamis.
   */
  const policeSorgula = async () => {
    const kurumId = Number(bilgi.ossKurumId ?? 0);
    if (!kurumId) { mesaj('Önce sigorta şirketini seçin.'); return }
    if (!bilgi.ossPoliceNo) { mesaj('Poliçe numarası girilmeli.'); return }
    setSigortaMesgul(true);
    await guvenli(async () => {
      const y = await api.sigortaPoliceSorgu({
        tarafId: Number(tarafId ?? 0), kurumId, hekimId: hekimId ?? undefined,
        policeNo: String(bilgi.ossPoliceNo ?? ''),
      });
      // Sirketin dondugu poliçe adi/numarasi karta yazilir: elle girilen
      //   numara eksik/hatali yazilmis olabilir.
      degistir({ ossPoliceNo: y.policeNo || bilgi.ossPoliceNo });
      const notlar = y.notlar?.length ? y.notlar.join(String.fromCharCode(10)) : '';
      mesaj(notlar ? y.mesaj + String.fromCharCode(10, 10) + notlar : y.mesaj);
    });
    setSigortaMesgul(false);
  };

  /**
   * PROVIZYON AL / GUNCELLE (430) - createProvision. Yanittaki tutar kirilimi
   * belge satirlarinin kurum/hasta payini SUNUCUDA yazar; kart yeniden
   * okunmali, yoksa ekranda eski paylar durur.
   */
  const provizyonAl = async () => {
    if (!belgeId) { mesaj('Önce başvuruyu kaydedin.'); return }
    if (!Number(bilgi.ossKurumId ?? 0)) { mesaj('Önce sigorta şirketini seçin.'); return }
    setSigortaMesgul(true);
    await guvenli(async () => {
      const y = await api.sigortaProvizyon({ belgeId });
      mesaj(y.mesaj);
      onTazele?.();
    });
    setSigortaMesgul(false);
  };

  /*
   * ALANLAR KURUM TURUNE GORE (kullanici): eskiden iki provizyon grubu da her
   * zaman ciziliyordu; ÖSS hastasinda MEDULA alanlari, SGK hastasinda police
   * alanlari bos duruyordu.
   *   SGK (4)  : MEDULA grubu. Hastanin TAMAMLAYICI policesi de olabilir -
   *              o grup istege bagli acilir (kayitli police varsa acik gelir).
   *   TSS (3)  : HER IKISI - asil odeyici SGK (MEDULA), farki ustlenen
   *              tamamlayici police ozel sigorta grubunda; ikisi de acik.
   *   ÖSS (2)  : yalniz ozel sigorta grubu; MEDULA alanlari hic cizilmez.
   */
  const sgkVar = kurumTuru !== 2;
  const [tamamlayici, setTamamlayici] = useState(false);
  const ossVar = kurumTuru === 2 || kurumTuru === 3 || tamamlayici
                 || (bilgi.ossKurumId ?? null) !== null
                 || !!bilgi.ossProvizyonNo || !!bilgi.ossPoliceNo;

  return (
    <>
      {sgkVar && (
      <div className="kagrup">
        {/* "Provizyon Al" dugmesi GRUP BASLIGINDA saga yasli (kullanici):
            arac cubugundan alindi - hangi odeyiciden provizyon alindigi
            dugmenin yerinden anlasilsin (SGK ayri, ozel sigorta ayri). */}
        <h6>
          SGK / MEDULA Provizyonu
          <button type="button" className="d bir sag" disabled
                  title="MEDULA provizyon sorgusu henüz bağlı değil - alanlar elle doldurulur.">
            🧾 Provizyon Al
          </button>
        </h6>
        <div className="alan-izgara dort-sutun">
          <label className="alan">
            <span className="etiket">Kurum</span>
            <input value={kurumAdi || "—"} readOnly />
          </label>
          <KodSecim etiket="Durum" listeKod="provizyon.durum"
                    deger={bilgi.sgkDurum} kilitli={kilitli}
                    onDeger={v => degistir({ sgkDurum: v })} />
          <MetinAlani etiket="Provizyon No" deger={bilgi.sgkProvizyonNo}
                      kilitli={kilitli} ipucu="örn. P2026-0083471"
                      onDeger={v => degistir({ sgkProvizyonNo: v })} />
          <ZamanAlani etiket="Provizyon Tarihi" deger={bilgi.sgkProvizyonTarihi}
                      kilitli={kilitli}
                      onDeger={v => degistir({ sgkProvizyonTarihi: v })} />

          <KodSecim etiket="Provizyon Tipi" listeKod="basvuru.provizyon_tipi"
                    deger={bilgi.sgkProvizyonTipi} kilitli={kilitli}
                    onDeger={v => degistir({ sgkProvizyonTipi: v })} />
          <MetinAlani etiket="Sigorta Türü" deger={bilgi.sgkSigortaTuru}
                      kilitli={kilitli} ipucu="4/a · 4/b · 4/c"
                      onDeger={v => degistir({ sgkSigortaTuru: v })} />
          {/* Basvuru (muracaat) no ile takip no AYRI numaralardir; faturalama
              takip numarasi uzerinden yapilir. */}
          <MetinAlani etiket="Başvuru No" deger={bilgi.sgkBasvuruNo} kilitli={kilitli}
                      onDeger={v => degistir({ sgkBasvuruNo: v })} />
          <MetinAlani etiket="Takip No" deger={bilgi.sgkTakipNo} kilitli={kilitli}
                      onDeger={v => degistir({ sgkTakipNo: v })} />

          <ZamanAlani etiket="Takip Tarihi" deger={bilgi.sgkTakipTarihi}
                      kilitli={kilitli}
                      onDeger={v => degistir({ sgkTakipTarihi: v })} />
          <KodSecim etiket="Takip Türü" listeKod="provizyon.takip_turu"
                    deger={bilgi.sgkTakipTuru} kilitli={kilitli}
                    onDeger={v => degistir({ sgkTakipTuru: v })} />
          <MetinAlani etiket="Tesis Kodu" deger={bilgi.sgkTesisKodu} kilitli={kilitli}
                      onDeger={v => degistir({ sgkTesisKodu: v })} />
          <ZamanAlani etiket="Geçerlilik" deger={bilgi.sgkGecerlilik}
                      kilitli={kilitli}
                      onDeger={v => degistir({ sgkGecerlilik: v })} />

          <label className="alan">
            <span className="etiket">Karşılama %</span>
            <input className="hiza-sag" value={String(bilgi.sgkKarsilama ?? "")}
                   disabled={kilitli}
                   onChange={e => degistir({ sgkKarsilama: e.target.value })} />
          </label>
          <label className="alan">
            <span className="etiket">Onaylanan Tutar</span>
            <input className="hiza-sag" value={String(bilgi.sgkTutar ?? "")}
                   disabled={kilitli}
                   onChange={e => degistir({ sgkTutar: e.target.value })} />
          </label>
          <label className="alan">
            <span className="etiket">Müstehaklık</span>
            <span className="deger-serit">
              <span className={`rozet ${m.sinif}`}>{m.ad}</span>
              {bilgi.sgkMustehaklikZaman && (
                <span className="sonuk">{tarihSaat(bilgi.sgkMustehaklikZaman)}</span>
              )}
            </span>
          </label>

          <label className="alan">
            <span className="etiket">Sevkli mi?</span>
            <select value={Number(bilgi.sgkSevkli ?? 0)} disabled={kilitli}
                    onChange={e => degistir({ sgkSevkli: Number(e.target.value) })}>
              <option value={0}>Hayır</option>
              <option value={1}>Evet</option>
            </select>
          </label>
          <MetinAlani etiket="Sevk Eden Kurum" deger={bilgi.sgkSevkKurum}
                      kilitli={kilitli || Number(bilgi.sgkSevkli ?? 0) === 0}
                      onDeger={v => degistir({ sgkSevkKurum: v })} />
          {/* Red nedeni yalniz REDDEDILDI durumunda anlamli. */}
          <MetinAlani etiket="Red Nedeni" deger={bilgi.sgkRedNedeni}
                      kilitli={kilitli || Number(bilgi.sgkDurum ?? 0) !== 2}
                      onDeger={v => degistir({ sgkRedNedeni: v })} />
        </div>
        <div className="not">
          Provizyon alınmadan başvuru açılabilir; kurum payı ancak provizyon
          numarası girildikten sonra faturalanmalıdır. Müstehaklık sorgusu
          (MEDULA) henüz bağlı değil — alanlar elle doldurulur.
        </div>
        {/* TAMAMLAYICI SIGORTA: SGK'li hastada police de olabilir - SGK'nin
            karsilamadigi farki ozel sigorta ustlenir. Grup istege bagli acilir. */}
        {!ossVar && (
          <div className="katoolbar" style={{ borderTop: '1px solid var(--cizgi)' }}>
            <button type="button" className="d" disabled={kilitli}
                    title="Hastanın tamamlayıcı/özel sigorta poliçesi varsa alanları aç"
                    onClick={() => setTamamlayici(true)}>
              ＋ Tamamlayıcı Sigorta Provizyonu
            </button>
          </div>
        )}
      </div>
      )}

      {ossVar && (
      <div className="kagrup">
        <h6>
          {kurumTuru === 2 ? 'Özel Sigorta Provizyonu'
                           : 'Tamamlayıcı Sigorta Provizyonu'}
          {/* SERVIS BAGLI (430): kurumun sigorta hesabi tanimliysa poliçe
              sorgusu ve provizyon buradan alinir. Hesabi olmayan kurumda uc
              "hesap tanimli degil" der ve alanlar ELLE doldurulmaya devam
              eder - eski davranis bozulmuyor.
              Kaydedilmemis basvuruda dugmeler pasif: servise gonderilecek
              kalemler henuz veritabaninda yok. */}
          <button type="button" className="d bir sag" disabled={sigortaMesgul || !belgeId}
                  title={belgeId ? 'Provizyon al / güncelle (sigorta servisi)'
                                 : 'Önce başvuruyu kaydedin.'}
                  onClick={provizyonAl}>
            🧾 Provizyon Al
          </button>
          <button type="button" className="d bir sag" disabled={sigortaMesgul || !belgeId}
                  title={belgeId ? 'Poliçe bu kurumda geçerli mi (checkPolicy)'
                                 : 'Önce başvuruyu kaydedin.'}
                  onClick={policeSorgula}>
            🔎 Poliçe Sorgula
          </button>
        </h6>
        <div className="alan-izgara dort-sutun">
          {/* Sirket belgenin odeyen kurumundan FARKLI olabilir. */}
          <label className="alan">
            <span className="etiket">Sigorta Şirketi</span>
            <select value={bilgi.ossKurumId ?? ""} disabled={kilitli}
                    onChange={e => degistir({
                      ossKurumId: e.target.value ? Number(e.target.value) : null })}>
              <option value="">— Yok —</option>
              {(kurumlar ?? []).filter(k => (k.tur ?? 0) === 2)
                .map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
            </select>
          </label>
          <KodSecim etiket="Durum" listeKod="provizyon.durum"
                    deger={bilgi.ossDurum} kilitli={kilitli}
                    onDeger={v => degistir({ ossDurum: v })} />
          <MetinAlani etiket="Provizyon No" deger={bilgi.ossProvizyonNo} kilitli={kilitli}
                      onDeger={v => degistir({ ossProvizyonNo: v })} />
          <ZamanAlani etiket="Provizyon Tarihi" deger={bilgi.ossProvizyonTarihi}
                      kilitli={kilitli}
                      onDeger={v => degistir({ ossProvizyonTarihi: v })} />

          <MetinAlani etiket="Poliçe No" deger={bilgi.ossPoliceNo} kilitli={kilitli}
                      onDeger={v => degistir({ ossPoliceNo: v })} />
          <MetinAlani etiket="Hasar / Dosya No" deger={bilgi.ossHasarNo} kilitli={kilitli}
                      onDeger={v => degistir({ ossHasarNo: v })} />
          <MetinAlani etiket="Branş" deger={bilgi.ossBrans} kilitli={kilitli}
                      ipucu="örn. Yatarak Tedavi"
                      onDeger={v => degistir({ ossBrans: v })} />
          <ZamanAlani etiket="Geçerlilik" deger={bilgi.ossGecerlilik}
                      kilitli={kilitli}
                      onDeger={v => degistir({ ossGecerlilik: v })} />

          <label className="alan">
            <span className="etiket">Karşılama %</span>
            <input className="hiza-sag" value={String(bilgi.ossKarsilama ?? "")}
                   disabled={kilitli}
                   onChange={e => degistir({ ossKarsilama: e.target.value })} />
          </label>

          <label className="alan">
            <span className="etiket">Onaylanan Tutar</span>
            <input className="hiza-sag" value={String(bilgi.ossTutar ?? "")}
                   disabled={kilitli}
                   onChange={e => degistir({ ossTutar: e.target.value })} />
          </label>
          <MetinAlani etiket="Red Nedeni" deger={bilgi.ossRedNedeni}
                      kilitli={kilitli || Number(bilgi.ossDurum ?? 0) !== 2}
                      onDeger={v => degistir({ ossRedNedeni: v })} />
        </div>
      </div>
      )}
    </>
  );
}

