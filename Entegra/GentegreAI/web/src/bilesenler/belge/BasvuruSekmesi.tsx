import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { para, tarihSaat } from '../bicim';

/**
 * BASVURU / PROVIZYON / ONCEKI BASVURULAR sekmeleri (298).
 *
 * Mockup: Ekranlar/kayit_kabul_basvuru.html. Kayit kabulun doldurdugu
 * bilgiler basligin degil BU sekmenin isi: baslik yalnizca "kim, hangi
 * bolum, hangi hekim, kim odeyecek" dortlusunu tutar (dar ve her turde
 * ayni), gerisi burada.
 *
 * MEDULA ENTEGRASYONU YOK: provizyon alanlari ELLE girilir. Sorgu servisine
 * baglanildiginda ayni alanlar otomatik dolacak - ekran degismeyecek.
 */

/**
 * belge_basvuru (298) alanlarinin ekran karsiligi - hepsi tek nesnede.
 * Index imzasi kayit hatti icin: govde ureticisi alanlari tek tek saymadan
 * (Object.entries ile) gecirir, yeni alan eklerken tek dosya degisir.
 */
export interface BasvuruBilgi {
  [alan: string]: string | number | null | undefined;
  basvuruTuru?: number | null;
  gelisSekli?: number | null;
  gelisNedeni?: number | null;
  oda?: number | null;
  siraNo?: string;
  refakatci?: string;
  // Ambulans (300) - odeyiciden bagimsiz, hastaya ait kimlik bilgisi.
  ambulansHastaNo?: string;
  ambulansBileklikNo?: string;
  // PROVIZYON (299) - belge_provizyon 1:1. SGK ve ozel sigorta AYNI ANDA
  // olabilir (SGK ana odeyici, tamamlayici police farki ustlenir), o yuzden
  // her odeyicinin kendi durumu/numarasi/orani var.
  sgkDurum?: number | null;
  sgkProvizyonNo?: string;
  sgkProvizyonTipi?: number | null;
  sgkProvizyonTarihi?: string | null;
  sgkGecerlilik?: string | null;
  sgkKarsilama?: number | string | null;
  sgkTutar?: number | string | null;
  sgkRedNedeni?: string;
  sgkSigortaTuru?: string;
  // SGK'da iki numara var: basvuru (muracaat) ve takip. Faturalama TAKIP
  // numarasi uzerinden yapilir - ikisi karistirilmamali (300).
  sgkBasvuruNo?: string;
  sgkTakipNo?: string;
  sgkTakipTarihi?: string | null;
  sgkTakipTuru?: number | null;
  sgkTesisKodu?: string;
  sgkMustehaklik?: number | null;
  sgkMustehaklikZaman?: string | null;  // salt okunur
  sgkSevkli?: number | null;
  sgkSevkKurum?: string;
  ossKurumId?: number | null;
  ossKurumAdi?: string;                 // salt okunur (join)
  ossDurum?: number | null;
  ossProvizyonNo?: string;
  ossProvizyonTarihi?: string | null;
  ossGecerlilik?: string | null;
  ossKarsilama?: number | string | null;
  ossTutar?: number | string | null;
  ossRedNedeni?: string;
  ossPoliceNo?: string;
  ossHasarNo?: string;
  ossBrans?: string;
  provizyonAciklama?: string;
}

/** Kod listesi combosu - deger kod_deger.deger, gosterim ad. */
function KodSecim({ etiket, listeKod, deger, onDeger, kilitli, zorunlu }: {
  etiket: string; listeKod: string; deger?: number | null;
  onDeger(v: number | null): void; kilitli?: boolean; zorunlu?: boolean;
}) {
  const [secenekler, setSecenekler] = useState<{ deger: number; ad: string }[]>([]);
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe(listeKod);
        if (!iptal) setSecenekler(y.degerler.filter(d => d.aktif === 1));
      } catch { /* liste yoksa combo bos kalir - kayit engellenmez */ }
    })();
    return () => { iptal = true };
  }, [listeKod]);

  return (
    <label className="alan">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <select value={deger ?? ''} disabled={kilitli}
              onChange={e => onDeger(e.target.value ? Number(e.target.value) : null)}>
        <option value="">— Seçiniz —</option>
        {secenekler.map(x => <option key={x.deger} value={x.deger}>{x.ad}</option>)}
      </select>
    </label>
  );
}

/** Kisa metin alani. */
function MetinAlani({ etiket, deger, onDeger, kilitli, ipucu }: {
  etiket: string; deger?: string; onDeger(v: string): void;
  kilitli?: boolean; ipucu?: string;
}) {
  return (
    <label className="alan">
      <span className="etiket">{etiket}</span>
      <input value={deger ?? ''} disabled={kilitli} placeholder={ipucu}
             onChange={e => onDeger(e.target.value)} />
    </label>
  );
}

/**
 * Tarih-saat alani. Bos deger `null` gider: bos metin ('') gonderilirse
 * sunucu onu gecersiz tarih sayip "bos birakilamaz" hatasi verir.
 */
function ZamanAlani({ etiket, deger, onDeger, kilitli }: {
  etiket: string; deger?: string | null; onDeger(v: string | null): void;
  kilitli?: boolean;
}) {
  return (
    <label className="alan">
      <span className="etiket">{etiket}</span>
      <input type="datetime-local" value={String(deger ?? '').slice(0, 16)}
             disabled={kilitli}
             onChange={e => onDeger(e.target.value || null)} />
    </label>
  );
}

// ====================================================== HASTA SERIDI ====
/**
 * SECILI HASTA SERIDI (298, mockup "hasta" bloku): kabul boyunca ekranda
 * kalir - memur hastayi dogruladigini her an gorsun. Alanlar hasta
 * kaynagindan (taraf + taraf_hasta + varsayilan adres) tek istekle gelir.
 *
 * Mockup'taki ALERJI / KRONIK uyari cubugu YOK: o veriyi tutan bir tablo
 * henuz yok, uydurma bilgi gostermek yaniltici olurdu. Yerine gercek veriden
 * "son basvuru" uyarisi cizilir.
 */
export function HastaSeridi({ tarafId }: { tarafId?: number | null }) {
  const [h, setH] = useState<Record<string, unknown> | null>(null);

  useEffect(() => {
    if (!tarafId) { setH(null); return }
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('hasta', {
          sayfa: 1, boyut: 1,
          filtre: { alan: 'id', op: 'esit', deger: tarafId },
        });
        if (!iptal) setH(y.satirlar[0] ?? null);
      } catch { if (!iptal) setH(null) }
    })();
    return () => { iptal = true };
  }, [tarafId]);

  if (!tarafId) return null;

  const ad = String(h?.unvan ?? '');
  const bas = ad.split(/\s+/).filter(Boolean).slice(0, 2)
                .map(x => x[0]?.toLocaleUpperCase('tr') ?? '').join('');
  const dogum = String(h?.dogumTarihi ?? '').slice(0, 10);
  const yas = h?.yas != null && h.yas !== '' ? `${h.yas} y` : '';
  const sonBasvuru = String(h?.sonBasvuru ?? '').slice(0, 10);

  return (
    <div className="hasta-serit">
      <span className="avatar">{bas || '—'}</span>
      <span className="hs">
        <span className="k">Hasta</span>
        <span className="v">{ad || '—'}</span>
      </span>
      <span className="hs">
        <span className="k">T.C. / Dosya No</span>
        <span className="v">{String(h?.vkno ?? '—')} · {String(h?.kod ?? '—')}</span>
      </span>
      <span className="hs">
        <span className="k">Doğum / Cinsiyet</span>
        <span className="v">
          {[dogum ? dogum.split('-').reverse().join('.') : '',
            String(h?.cinsiyetAdi ?? ''), yas].filter(Boolean).join(' · ') || '—'}
        </span>
      </span>
      <span className="hs">
        <span className="k">Telefon</span>
        <span className="v">{String(h?.cepTel ?? '') || '—'}</span>
      </span>
      <span className="hs">
        <span className="k">Son Başvuru</span>
        <span className="v">
          {sonBasvuru ? sonBasvuru.split('-').reverse().join('.')
                      : <span className="sonuk">ilk başvuru</span>}
        </span>
      </span>
    </div>
  );
}

// ============================================================ BASVURU ====
export function BasvuruSekmesi({ bilgi, degistir, kilitli, protokolNo, randevuBilgi }: {
  bilgi: BasvuruBilgi;
  degistir(y: Partial<BasvuruBilgi>): void;
  kilitli: boolean;
  protokolNo: string;
  /** Belgeye bagli randevu varsa ozeti (tarih · kaynak) - salt okunur. */
  randevuBilgi?: string;
}) {
  return (
    <div className="kagrup">
      <h6>Başvuru Bilgileri</h6>
      <div className="alan-izgara dort-sutun">
        <label className="alan">
          <span className="etiket">Protokol No</span>
          <input value={protokolNo || '(kaydedince atanacak)'} readOnly />
        </label>
        <KodSecim etiket="Başvuru Türü" listeKod="basvuru.tur" zorunlu
                  deger={bilgi.basvuruTuru} kilitli={kilitli}
                  onDeger={v => degistir({ basvuruTuru: v })} />
        <KodSecim etiket="Geliş Şekli" listeKod="basvuru.gelis_sekli"
                  deger={bilgi.gelisSekli} kilitli={kilitli}
                  onDeger={v => degistir({ gelisSekli: v })} />
        <KodSecim etiket="Geliş Nedeni" listeKod="basvuru.gelis_nedeni"
                  deger={bilgi.gelisNedeni} kilitli={kilitli}
                  onDeger={v => degistir({ gelisNedeni: v })} />

        <KodSecim etiket="Poliklinik Odası" listeKod="basvuru.oda"
                  deger={bilgi.oda} kilitli={kilitli}
                  onDeger={v => degistir({ oda: v })} />
        <MetinAlani etiket="Sıra No" deger={bilgi.siraNo} kilitli={kilitli}
                    ipucu="örn. A-037" onDeger={v => degistir({ siraNo: v })} />
        <MetinAlani etiket="Refakatçi" deger={bilgi.refakatci} kilitli={kilitli}
                    onDeger={v => degistir({ refakatci: v })} />
        {/* Randevu SALT OKUNUR: bag randevu tarafinda kurulur (randevu.belge_id),
            burada yalnizca "hangi randevudan geldi" okunur. */}
        <label className="alan">
          <span className="etiket">Randevu</span>
          <input value={randevuBilgi || '—'} readOnly />
        </label>

        {/* AMBULANS (300): yalniz gelis sekli Ambulans iken sorulur - ama
            DOLU ise her zaman gorunur, yoksa gelis sekli sonradan
            degistirildiginde kayitli numara ekranda kaybolurdu. */}
        {(Number(bilgi.gelisSekli ?? 0) === 2
          || (bilgi.ambulansHastaNo ?? '') !== ''
          || (bilgi.ambulansBileklikNo ?? '') !== '') && (
          <>
            <MetinAlani etiket="Ambulans Hasta No" deger={bilgi.ambulansHastaNo}
                        kilitli={kilitli} ipucu="112 kayıt no"
                        onDeger={v => degistir({ ambulansHastaNo: v })} />
            <MetinAlani etiket="Bileklik No" deger={bilgi.ambulansBileklikNo}
                        kilitli={kilitli}
                        onDeger={v => degistir({ ambulansBileklikNo: v })} />
          </>
        )}
      </div>
    </div>
  );
}

// ========================================================== PROVIZYON ====
const MUSTEHAKLIK: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Sorgulanmadı', sinif: '' },
  1: { ad: 'Müstehak',     sinif: 'olumlu' },
  2: { ad: 'Müstehak değil', sinif: 'teh' },
};

export function ProvizyonSekmesi({ bilgi, degistir, kilitli, kurumAdi, kurumlar }: {
  bilgi: BasvuruBilgi;
  degistir(y: Partial<BasvuruBilgi>): void;
  kilitli: boolean;
  /** Belgenin odeyen kurumu - SGK bloÄunda bilgi olarak gosterilir. */
  kurumAdi?: string;
  /** Anlasmali kurumlar: ozel sigorta sirketi buradan secilir (tur 2). */
  kurumlar?: { id: number; ad: string; tur?: number }[];
}) {
  const m = MUSTEHAKLIK[Number(bilgi.sgkMustehaklik ?? 0)] ?? MUSTEHAKLIK[0];

  return (
    <>
      {/* IKI PROVIZYON AYNI ANDA (kullanici): hasta hem SGK'li olabilir hem
          tamamlayici policesi bulunabilir - SGK karsilamadigi farki ozel
          sigorta ustlenir. Bu yuzden gruplar kurum turune gore GIZLENMEZ,
          ikisi de acik durur; doldurulmayan grup bos kalir. */}
      <div className="kagrup">
        <h6>SGK / MEDULA Provizyonu</h6>
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
      </div>

      <div className="kagrup">
        <h6>Özel / Tamamlayıcı Sigorta Provizyonu</h6>
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
    </>
  );
}

// ================================================== ONCEKI BASVURULAR ====
export function OncekiBasvurular({ tarafId, haricBelgeId }: {
  tarafId?: number | null;
  /** Acik olan basvuru listede tekrar gosterilmez. */
  haricBelgeId?: number;
}) {
  const [satirlar, setSatirlar] = useState<Record<string, unknown>[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    if (!tarafId) { setSatirlar([]); return }
    let iptal = false;
    setYukleniyor(true);
    void (async () => {
      try {
        const y = await api.liste('belge', {
          sayfa: 1, boyut: 50,
          sirala: [{ alan: 'belgeTarihi', yon: 'desc' }],
          filtre: { op: 'and', kosullar: [
            { alan: 'tur', op: 'esit', deger: 19 },
            { alan: 'tarafId', op: 'esit', deger: tarafId },
          ] },
        });
        if (!iptal) setSatirlar(y.satirlar.filter(r => Number(r.id) !== haricBelgeId));
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
      finally { if (!iptal) setYukleniyor(false) }
    })();
    return () => { iptal = true };
  }, [tarafId, haricBelgeId]);

  if (!tarafId) return <div className="not">Önce hasta seçin.</div>;

  return (
    <div className="kagrup">
      <h6>Önceki Başvurular {satirlar.length > 0 && <span className="b">{satirlar.length}</span>}</h6>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <table className="detay-tablo">
        <thead>
          <tr>
            <th style={{ width: 130 }}>Protokol</th>
            <th style={{ width: 140 }}>Tarih</th>
            <th>Bölüm</th>
            <th>Hekim / Personel</th>
            <th>Ödeyen Kurum</th>
            <th className="hiza-sag" style={{ width: 120 }}>Tutar</th>
            <th style={{ width: 110 }}>Kapanma</th>
          </tr>
        </thead>
        <tbody>
          {satirlar.map(r => (
            <tr key={String(r.id)}>
              <td><code>{String(r.belgeNo ?? '')}</code></td>
              <td>{tarihSaat(String(r.belgeTarihi ?? ''))}</td>
              <td>{String(r.poliklinik ?? '') || <span className="sonuk">—</span>}</td>
              <td>{String(r.doktor ?? '') || <span className="sonuk">—</span>}</td>
              <td>{String(r.odeyenKurumAdi ?? '') || <span className="sonuk">kendi öder</span>}</td>
              <td className="hiza-sag">{para.format(Number(r.genelToplam ?? 0))}</td>
              <td>{String(r.kapanmaAdi ?? '')}</td>
            </tr>
          ))}
          {!yukleniyor && satirlar.length === 0 && (
            <tr><td colSpan={7} className="bos">Bu hastanın başka başvurusu yok.</td></tr>
          )}
        </tbody>
      </table>
      {yukleniyor && <div className="yukleniyor">Yükleniyor…</div>}
    </div>
  );
}
