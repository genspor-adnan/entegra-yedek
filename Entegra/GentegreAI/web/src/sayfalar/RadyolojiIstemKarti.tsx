import { useCallback, useContext, useEffect, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { EkranSekmesiBaglami, sekmeAdi } from '../bilesenler/sekmeBaglami';
import { guvenli } from '../bilesenler/mesaj';
import { DokumanGalerisi } from '../bilesenler/DokumanGalerisi';
import { KaynakArama } from '../bilesenler/KaynakArama';
import { HastaSeridi } from '../bilesenler/belge/basvuru/HastaSeridi';
import { TarafArama } from '../bilesenler/TarafArama';
import { PacsGoruntuleri } from '../bilesenler/radyoloji/PacsGoruntuleri';
import { yerelZamanDamgasi } from './liste/zaman';

/**
 * RADYOLOJİ İSTEM KARTI (283) — mockup Ekranlar/Radyoloji/radyoloji_istem_karti_v2.html (01.11.2026).
 *
 * Generic karta sığmaz: kutusuz kimlik bandı + ince akış çizgisi + Kabul Bilgileri / İstem, çekim öncesi
 * kontrol, çekim / görüntü blokları + sağda istem kâğıdı. İstem başvurunun radyoloji
 * satırından doğar; ücret ve ödeyen kurum oradan gelir, burada tekrar sorulmaz.
 */
type Sozluk = Record<string, unknown>;
const M = (o: Sozluk | null, k: string) => (o && o[k] != null ? String(o[k]) : '');
const N = (o: Sozluk | null, k: string) => (o && o[k] != null ? Number(o[k]) : 0);
const zaman = (v: unknown) => v ? new Date(String(v)).toLocaleString('tr-TR',
  { dateStyle: 'short', timeStyle: 'short' }) : '';

/** Sunucu zamanı (UTC an) -> datetime-local girdisi için yerel "yyyy-MM-ddTHH:mm". */
const yerelDamga = (v: string) => {
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? '' : new Date(d.getTime() - d.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
};

const DURUM_RENK: Record<number, string> = { 0: 'kir', 1: 'pas', 2: 'mavi', 3: 'sari', 4: 'sari', 5: 'ok', 6: 'ok' };

export function RadyolojiIstemKarti() {
  const { id } = useParams();
  const git = useNavigate();
  const { yetki } = useOturum();
  const istemId = Number(id);
  const [k, setK] = useState<Sozluk | null>(null);
  const [akis, setAkis] = useState<Sozluk | null>(null);
  const [kontrol, setKontrol] = useState<{ soruId: number; soru: string; yanitTipi: number; zorunlu: number;
                                           yanit: string; kaydeden: string; kayitZamani: string | null }[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  /** BLOK BAZLI DÜZENLEME (kullanıcı 01.11.2026: "kaydedildiğinde kabul bilgileri sağında kalem ikonu olsun..
   *  kaleme basınca tekrar edit moda geçebilsin"): genel Düzenle yok, her blok kendi kalemiyle. */
  const [duzen, setDuzen] = useState(false);
  const [cekimDuzen, setCekimDuzen] = useState(false);
  /** İSTEM KÂĞIDI / KONTROL KALEMLE (kullanıcı 02.11.2026: "istem kağıdı ve çekim kontrol gridlerine de kalem edit
   *  ekle.. diğerleri gibi"): görünümde etiket / dosya listesi, kalemle düzenleme. */
  const [kagitDuzen, setKagitDuzen] = useState(false);
  const [kontrolDuzen, setKontrolDuzen] = useState(false);
  const [kontrolTaslak, setKontrolTaslak] = useState<Record<number, string>>({});
  /**
   * ELLE ÇEKİM GİRİŞİ (kullanıcı 01.11.2026: "çekim bilgisini ne zaman gireceğim.. cihaza bağlantı yoksa manuel
   * girmek gerekir"): cihaz entegrasyonu (MPPS / PACS) yoksa teknisyen çekim bilgisini karttan girer - istem
   * "Çekildi" olur. Yazım genel kart ucundan (çalışma listesindeki "Çekildi" ile aynı yol; kontrol listesi
   * tamamlanmadan sunucu reddeder).
   */
  type Cekim = { zaman: string; cihazId: number | null; teknikerId: number | null; teknikerAd: string;
                 kontrast: number; kontrastMl: string; seri: string; goruntu: string; dlp: string; ctdi: string };
  const [cekim, setCekim] = useState<Cekim | null>(null);
  const [cihazlar, setCihazlar] = useState<{ id: number; ad: string }[]>([]);
  const [teknikerArama, setTeknikerArama] = useState(false);
  const cs = (p: Partial<Cekim>) => setCekim(c => c ? { ...c, ...p } : c);
  const { kullanici } = useOturum();
  /** ICD SEÇİMİ (kullanıcı 01.11.2026: "ICD seçemedim.. genel seçim ekranı gelsin"): muayenedeki ICD-10 araması. */
  const [icdAcik, setIcdAcik] = useState(false);
  const [onTaniAdi, setOnTaniAdi] = useState('');
  type Form = { klinikBilgi: string; onTani: string; oncelik: number; kontrast: number; kontrastMl: string; seriSayisi: string; goruntuSayisi: string;
                yon: number; accessionNo: string };
  const [form, setForm] = useState<Form | null>(null);
  const formAl = (o: Sozluk): Form => ({
    klinikBilgi: M(o, 'klinikBilgi'), onTani: M(o, 'onTani'), oncelik: N(o, 'oncelik') || 1,
    kontrast: N(o, 'kontrast'), kontrastMl: N(o, 'kontrastMl') ? M(o, 'kontrastMl') : '',
    seriSayisi: N(o, 'seriSayisi') ? M(o, 'seriSayisi') : '', goruntuSayisi: N(o, 'goruntuSayisi') ? M(o, 'goruntuSayisi') : '',
    yon: N(o, 'yon'), accessionNo: M(o, 'accessionNo'),
  });
  const fs = (p: Partial<Form>) => setForm(f => f ? { ...f, ...p } : f);

  const kontrolYukle = useCallback(async () => {
    const kn = await api.radyolojiKontrol(istemId);
    setKontrol((kn.sorular ?? []).map(s => ({
      soruId: Number(s.soruId), soru: String(s.soru ?? ''), yanitTipi: Number(s.yanitTipi ?? 1), zorunlu: Number(s.zorunlu ?? 0),
      yanit: String(s.yanit ?? ''), kaydeden: String(s.kaydeden ?? ''), kayitZamani: s.kayitZamani ? String(s.kayitZamani) : null })));
  }, [istemId]);
  /** KONTROL YANITLARI (kullanıcı 01.11.2026, elle çekim): kalemle açılan blokta girilir, Kaydet hepsini yazar. */
  const kontrolKaydet = (degisen: { soruId: number; yanit: string }[]) => void guvenli(async () => {
    if (degisen.length) await api.radyolojiKontrolKaydet(istemId, degisen);
    await kontrolYukle();
    setKontrolDuzen(false);
  });
  const yukle = useCallback(async () => {
    if (!istemId) return;
    try {
      setHata(null);
      const kd = await api.radyolojiKartDetay(istemId);
      setK(kd); setForm(formAl(kd)); setOnTaniAdi(M(kd, 'onTaniAdi'));
      setAkis(await api.radyolojiAkis(istemId));
      await kontrolYukle();
    } catch (h) { setHata(hataMetni(h)) }
  }, [istemId, kontrolYukle]);
  useEffect(() => { void yukle() }, [yukle]);
  // KABUL KİPİ (1242, kullanıcı 01.11.2026): dış kurumdan gönderilen hastada başvuru kaydından sonra kart
  //   "?kabul=1" ile açılır - çekimden önceyse doğrudan düzenlemede: dış accession, doktor notu (klinik bilgi),
  //   istem kâğıdı taraması. "İstem taraması başvuruda değil istemde - doktor oradan bakar."
  const [arama] = useSearchParams();
  const kabulKipi = arama.get('kabul') === '1';
  const [kabulAcildi, setKabulAcildi] = useState(false);
  // 1244: KABUL EDİLMEMİŞ İSTEM (kabul_tarihi boş) ilk açılışta da düzenlemede gelir ("ilk istem oluştuğunda
  //   editler açık"); kabul bilgileri kaydedilince etiket görünümüne döner.
  useEffect(() => {
    if (kabulAcildi || !k) return;
    setKabulAcildi(true);
    const kabulBekliyor = !M(k, 'kabulTarihi') && N(k, 'durum') <= 1 && !M(k, 'studyUid');
    if ((kabulKipi || kabulBekliyor) && yetki('radyoloji-istem', 'degistir') && N(k, 'durum') <= 1) {
      setForm(formAl(k)); setDuzen(true); setKagitDuzen(true);
      if (yetki('radyoloji', 'degistir')) setKontrolDuzen(true);
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [k, kabulKipi]);
  // SEKME BAŞLIĞI = HASTA ADI (kullanıcı 27.10.2026: "rad istem sekme caption a da hasta ismi gelsin").
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const hastaAdi = M(k, 'hastaAdi').trim();
  useEffect(() => {
    if (ekranSekmesi && hastaAdi && istemId) ekranSekmesi.baslik(sekmeAdi(hastaAdi), `/radyoloji/${istemId}`);
  // ekranSekmesi bağlamı sekme ömrü boyunca aynı.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [hastaAdi, istemId]);

  const durum = N(k, 'durum');
  const cekildi = durum >= 2 || !!M(k, 'studyUid');
  const accBekliyor = N(k, 'accessionBekliyor') === 1;
  // AKIŞ (v2 mockup): ince adım çizgisi. KABUL adımı accession'ın verilmesidir (sevkli hastada kabul kartında);
  //   RANDEVU yalnız randevulu istemde görünür.
  const adimlar = [
    { ad: 'İstem', t: akis?.['istemZamani'], tamam: true },
    ...(akis?.['randevuZamani'] ? [{ ad: 'Randevu', t: akis?.['randevuZamani'], tamam: true }] : []),
    { ad: 'Kabul', t: k?.['kabulTarihi'], tamam: !!M(k, 'kabulTarihi') || cekildi },
    { ad: 'Çekim', t: akis?.['cekimZamani'], tamam: cekildi },
    { ad: 'Rapor', t: akis?.['raporZamani'], tamam: durum >= 3 },
    { ad: 'Onay', t: akis?.['onayZamani'], tamam: durum >= 5 },
    { ad: 'Teslim', t: akis?.['teslimZamani'], tamam: durum >= 6 },
  ];
  const simdiIdx = adimlar.findIndex(a => !a.tamam);

  const cekimAc = async () => {
    if (!k) return;
    const sayi = (a: string) => (N(k, a) ? M(k, a) : '');
    setCekim({
      // Daha önce çekildiyse kendi zamanı, değilse ŞİMDİ (yerel saat - UTC'ye kaymasın).
      zaman: M(k, 'cekimTarihi') ? yerelDamga(M(k, 'cekimTarihi')) : yerelZamanDamgasi(),
      cihazId: N(k, 'cihazId') || null,
      teknikerId: N(k, 'teknikerId') || kullanici?.id || null,
      teknikerAd: M(k, 'tekniker') || kullanici?.ad || '',
      kontrast: N(k, 'kontrast') > 0 ? 1 : 0, kontrastMl: sayi('kontrastMl'),
      seri: sayi('seriSayisi'), goruntu: sayi('goruntuSayisi'), dlp: sayi('dlp'), ctdi: sayi('ctdi'),
    });
    setDuzen(false); setCekimDuzen(true);
    try {
      const y = await api.liste('radyoloji-cihaz', { sayfa: 1, boyut: 50,
        filtre: N(k, 'modalite') ? { alan: 'modalite', op: 'esit', deger: N(k, 'modalite') } : undefined });
      setCihazlar(y.satirlar.map(r => ({ id: Number(r.id), ad: `${String(r.ad ?? '')}${r.oda ? ` · ${String(r.oda)}` : ''}` })));
    } catch { setCihazlar([]) }
  };
  const cekimKaydet = async () => {
    if (!cekim) return;
    if (!cekim.zaman) { await guvenli(async () => { throw new Error('Çekim zamanı girilmeli.') }); return }
    const ondalik = (v: string) => (v.trim() ? Number(v.replace(',', '.')) : null);
    await guvenli(async () => {
      const mevcut = await api.kartOku('radyoloji-istem', istemId);
      await api.kartGuncelle('radyoloji-istem', istemId, {
        surum: mevcut.kart.surum,
        kart: {
          ...(N(k, 'durum') < 2 ? { durum: 2 } : {}),
          cekimTarihi: cekim.zaman, cihazId: cekim.cihazId, teknikerId: cekim.teknikerId,
          kontrast: cekim.kontrast, kontrastMl: cekim.kontrast ? ondalik(cekim.kontrastMl) : null,
          seriSayisi: cekim.seri ? Number(cekim.seri) : 0, goruntuSayisi: cekim.goruntu ? Number(cekim.goruntu) : 0,
          dlp: ondalik(cekim.dlp), ctdi: ondalik(cekim.ctdi),
        },
      });
      setCekimDuzen(false); setCekim(null);
      await yukle();
    });
  };

  const kaydet = async () => {
    if (!form) return;
    await guvenli(async () => {
      await api.radyolojiIstemGuncelle(istemId, {
        klinikBilgi: form.klinikBilgi, onTani: form.onTani, oncelik: form.oncelik,
        kontrast: form.kontrast,
        kontrastMl: form.kontrastMl ? Number(form.kontrastMl.replace(',', '.')) : null,
        seriSayisi: form.seriSayisi ? Number(form.seriSayisi) : null,
        goruntuSayisi: form.goruntuSayisi ? Number(form.goruntuSayisi) : null,
        // Yön SUT kodunda (1237) - kartta sorulmaz, mevcut değer korunur.
        yon: form.yon,
        // Accession yalnız değiştiyse gider (sunucu çekimden sonra değişikliği reddeder).
        accessionNo: form.accessionNo.trim() !== M(k, 'accessionNo') ? form.accessionNo.trim() : null,
      });
      // Başarı mesajı YOK (kullanıcı 01.11.2026: "kaydet deyince İstem güncellendi. mesajı gelmesin"): blok
      //   etiket görünümüne dönmesi yeterli geri bildirim.
      setDuzen(false); setCekimDuzen(false);
      await yukle();
    });
  };

  if (hata) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div>
    <button className="d" onClick={() => git('/radyoloji')}>◀ İstem Listesi</button></div>;
  if (!k) return <div className="fm-sayfa"><div className="fm-bolum">Yükleniyor…</div></div>;

  const kontrastAd = N(k, 'kontrast') === 1 ? `Verildi${N(k, 'kontrastMl') ? ` · ${M(k, 'kontrastMl')} ml` : ''}` : 'Verilmedi';
  const doz = M(k, 'dlp') || M(k, 'ctdi') ? `DLP ${M(k, 'dlp') || '—'} · CTDIvol ${M(k, 'ctdi') || '—'}` : '';
  const yanitli = kontrol.filter(s => s.yanit).length;
  const ikili = (et: string, deger: string, tam = false) => <>
    <span className="rik-et">{et}</span>
    <span className={`rik-d${tam ? ' rik-tam' : ''}`}>{deger || <span className="rik-soluk">—</span>}</span>
  </>;
  const sevkli = !!(N(k, 'istekHekimId') || M(k, 'disHekimAd'));
  const isteyenKurum = M(k, 'isteyenKurum');

  return (
    <div className="fm-sayfa rik">
      <style>{RIK_STIL}</style>
      {/* BAŞLIK: ad + accession rozeti + tek satır araç (v2 mockup Ekranlar/Radyoloji/radyoloji_istem_karti_v2.html). */}
      <div className="rik-bas">
        <h1>☢️ Radyoloji İstemi</h1>
        {accBekliyor ? <span className="rik-acc bekliyor">Accession kabulde verilecek</span>
          : M(k, 'accessionNo') && <span className="rik-acc">{M(k, 'accessionNo')}{N(k, 'accessionDis') === 1 ? ' · dış' : ''}</span>}
        <div className="rik-sag">
          {<>
            {/* GÖRÜNTÜLE (11.11.2026): PACS'taki çalışma OHIF'te (yeni sekme); study_uid yoksa accession ile aranır. */}
            {cekildi && yetki('radyoloji', 'gor') &&
              <button className="d" title="DICOM görüntüleyici (OHIF)" onClick={() => void guvenli(async () => {
                const y = await api.dicomGoruntule({ istemId });
                window.open(y.url, '_blank', 'noopener');
              })}>🖼 Görüntüle</button>}
            {/* RAPOR (kullanıcı 27.10.2026): raporu kendi sekmesinde açar; rapor ekranındaki "İstem" buraya döner. */}
            {yetki('radyoloji', 'gor') &&
              <button className="d bir" onClick={() => {
                // Çekim yoksa rapor açılmaz - uyarı (kullanıcı 01.11.2026). Teleradyoloji gelen istem (kaynak 2) muaf.
                if (!cekildi && N(k, 'kaynak') !== 2) {
                  void guvenli(async () => { throw new Error('Çekim bilgisi girilmeden rapor yazılamaz. Önce "Çekim bilgisi gir" ile çekimi kaydedin.') });
                  return;
                }
                if (ekranSekmesi) ekranSekmesi.kartaGit(`/radyoloji/rapor/${istemId}`); else git(`/radyoloji/rapor/${istemId}`);
              }}>📄 Rapor</button>}
            <button className="d" title="Yenile" onClick={() => void yukle()}>⟳</button>
            <button className="d" onClick={() => git('/radyoloji')}>◀ Liste</button>
          </>}
        </div>
      </div>

      {/* HASTA BANDI = BAŞVURU BANDI (kullanıcı 01.11.2026: "hasta bandını başvuru gibi yap.. izinler yerine İsteyen
          adı ve bölüm ekle.. açık tah ve belge olmasın"). */}
      <HastaSeridi tarafId={N(k, 'hastaId') || null} kurumAdi={M(k, 'odeyenKurum')} belgeId={N(k, 'belgeId') || null}
                   protokolNo={M(k, 'protokol')} paraYok provizyonGizli
                   tetkik={{ ad: M(k, 'tetkikAdi'), kod: M(k, 'tetkikKodu') }}
                   // İSTEM DURUMU BANDIN "DURUM" HÜCRESİNDE (kullanıcı 01.11.2026): Bekliyor / Sevkli / Acil.
                   durumEk={<>
                     <span className={`rz ${DURUM_RENK[durum] ?? ''}`}>{M(k, 'durumAdi') || '—'}</span>
                     {sevkli && <span className="rik-sevk">Sevkli</span>}
                     {N(k, 'oncelik') >= 2 && <span className="rz kir">Acil</span>}
                   </>}
                   isteyen={{ ad: M(k, 'isteyenHekim'),
                              bolum: [M(k, 'isteyenBolum'), isteyenKurum && isteyenKurum !== M(k, 'isteyenHekim') ? isteyenKurum : '']
                                       .filter(Boolean).join(' · ') || M(k, 'isteyenBrans') }} />

      {/* AKIŞ - ince adım çizgisi. */}
      <div className="rik-akis">
        {adimlar.map((a, i) => (
          <div key={a.ad} className={`rik-adim${a.tamam ? ' ok' : i === simdiIdx ? ' simdi' : ''}`}>
            {a.ad}<small>{zaman(a.t) || (i === simdiIdx ? 'şimdi' : '—')}</small>
          </div>
        ))}
      </div>

      <div className="rik-govde">
        <div>
          {/* KABUL BİLGİLERİ / İSTEM: düzenlemede girdiler, değilse kutusuz etiket-değer. Yön ve kontrast
              SORULMAZ - SUT kodunun içinde ("DİZ - SAĞ, KONTRASTSIZ"); verilen kontrast çekimde girilir. */}
          <div className="rik-blok">
            <h4>Kabul Bilgileri
              {duzen ? <span className="rik-blokarac">
                  <button type="button" className="d bir" onClick={() => void kaydet()}>💾 Kaydet</button>
                  {/* İlk kabulde Vazgeç yok: kabul edilmemiş istem düzenlemede kalır. */}
                  {!!M(k, 'kabulTarihi') &&
                    <button type="button" className="d" onClick={() => { setForm(formAl(k)); setDuzen(false) }}>Vazgeç</button>}
                </span>
                : yetki('radyoloji-istem', 'degistir') &&
                  <button type="button" className="rik-kalem" title="Düzenle"
                          onClick={() => { setForm(formAl(k)); setCekimDuzen(false); setDuzen(true) }}>✎</button>}</h4>
            {duzen ? (
              <div className="rik-form">
                {/* SIRA (kullanıcı 01.11.2026): 1. satır Ön Tanı + sağında Öncelik; Accession yalnız düzenlemede
                    (görünümde başlıktaki rozette); İSTEYEN hasta bandında (salt okunur, başvurudaki Gönderen). */}
                <span className="rik-et">Ön Tanı</span>
                <span className="rik-ara">
                  <input style={{ flex: '0 0 84px', cursor: 'text' }} value={form?.onTani ?? ''} maxLength={20} placeholder="ICD-10"
                         onChange={e => { fs({ onTani: e.target.value }); setOnTaniAdi('') }} />
                  <span className="rik-icd">{onTaniAdi}</span>
                  <button type="button" title="ICD-10 tanı ara" onClick={() => setIcdAcik(true)}>🔍</button>
                </span>
                <span className="rik-et">Öncelik</span>
                <span className="rik-seg">
                  {([[1, 'Normal'], [2, 'Acil']] as const).map(([d, ad]) => (
                    <button type="button" key={d} className={(form?.oncelik ?? 1) === d ? (d === 2 ? 'on acil' : 'on') : ''}
                            onClick={() => fs({ oncelik: d })}>{ad}</button>))}
                </span>

                <span className="rik-et">Accession No</span>
                <input className="inp" maxLength={16} value={form?.accessionNo ?? ''} disabled={cekildi}
                       placeholder={accBekliyor ? 'dış no · boşsa kurum no' : undefined}
                       title={cekildi ? 'Çekim yapıldı - accession değişmez.' : 'Dışarıdan gelen hastanın numarası'}
                       onChange={e => fs({ accessionNo: e.target.value })} />
                <span /><span />

                <span className="rik-et">Klinik Bilgi</span>
                <textarea className="inp rik-tam" rows={2} value={form?.klinikBilgi ?? ''}
                          placeholder="Doktor notu / istem gerekçesi…"
                          onChange={e => fs({ klinikBilgi: e.target.value })} />
              </div>
            ) : (
              <div className="rik-bilgi">
                {/* Accession burada yok - başlıktaki rozette (kullanıcı 01.11.2026). */}
                {ikili('Ön Tanı', M(k, 'onTani') ? `${M(k, 'onTani')}${M(k, 'onTaniAdi') ? ` · ${M(k, 'onTaniAdi')}` : ''}` : '')}
                {ikili('Öncelik', M(k, 'oncelikAdi') || 'Normal')}
                {ikili('Klinik Bilgi', M(k, 'klinikBilgi'), true)}
              </div>
            )}
          </div>

          {/* ÇEKİM / GÖRÜNTÜ: çekimden önce tek satır + "Çekim bilgisi gir"; Study UID kartta yok (PACS'ta). */}
          <div className="rik-blok">
            {cekimDuzen && cekim ? <>
              <h4>Çekim / Görüntü {cekildi ? '' : <span className="rik-ip" style={{ marginLeft: 0 }}>· elle giriş</span>}
                <span className="rik-blokarac">
                  <button type="button" className="d bir" onClick={() => void cekimKaydet()}>
                    {cekildi ? '💾 Kaydet' : '✓ Çekildi'}</button>
                  <button type="button" className="d" onClick={() => { setCekimDuzen(false); setCekim(null) }}>Vazgeç</button>
                </span></h4>
              <div className="rik-form">
                <span className="rik-et">Çekim Zamanı</span>
                <input className="inp" type="datetime-local" value={cekim.zaman} onChange={e => cs({ zaman: e.target.value })} />
                <span className="rik-et">Cihaz</span>
                <select className="inp" value={cekim.cihazId ?? ''} onChange={e => cs({ cihazId: e.target.value ? Number(e.target.value) : null })}>
                  <option value="">— seçin —</option>
                  {cihazlar.map(c => <option key={c.id} value={c.id}>{c.ad}</option>)}
                </select>

                <span className="rik-et">Tekniker</span>
                <span className="rik-ara">
                  <input readOnly value={cekim.teknikerAd} placeholder="Tekniker seç…" onClick={() => setTeknikerArama(true)} />
                  <button type="button" title="Tekniker ara" onClick={() => setTeknikerArama(true)}>…</button>
                </span>
                <span className="rik-et">Kontrast</span>
                <span className="rik-satir">
                  <span className="rik-seg">
                    {([[0, 'Verilmedi'], [1, 'Verildi']] as const).map(([d, ad]) => (
                      <button type="button" key={d} className={cekim.kontrast === d ? 'on' : ''}
                              onClick={() => cs({ kontrast: d })}>{ad}</button>))}
                  </span>
                  <input className="inp" style={{ width: 70 }} placeholder="ml" value={cekim.kontrastMl}
                         onChange={e => cs({ kontrastMl: e.target.value })} disabled={cekim.kontrast !== 1} />
                </span>

                <span className="rik-et">Seri / Görüntü</span>
                <span className="rik-satir">
                  <input className="inp" style={{ width: 70 }} placeholder="seri" value={cekim.seri}
                         onChange={e => cs({ seri: e.target.value.replace(/\D/g, '') })} />
                  <input className="inp" style={{ width: 80 }} placeholder="görüntü" value={cekim.goruntu}
                         onChange={e => cs({ goruntu: e.target.value.replace(/\D/g, '') })} />
                </span>
                <span className="rik-et">Doz (DLP / CTDI)</span>
                <span className="rik-satir">
                  <input className="inp" style={{ width: 80 }} placeholder="DLP" value={cekim.dlp}
                         onChange={e => cs({ dlp: e.target.value })} />
                  <input className="inp" style={{ width: 80 }} placeholder="CTDIvol" value={cekim.ctdi}
                         onChange={e => cs({ ctdi: e.target.value })} />
                </span>
              </div>
            </> : !cekildi ? (
              <div className="rik-tek">📷 <b>Henüz çekilmedi.</b>
                {N(k, 'durum') >= 1 && yetki('radyoloji-istem', 'degistir')
                  ? <button type="button" className="d" style={{ marginLeft: 'auto' }} onClick={() => void cekimAc()}>
                      📷 Çekim bilgisi gir</button>
                  : <span>Cihaz, tekniker, seri / görüntü ve doz çekimde dolar.</span>}
              </div>
            ) : <>
              <h4>Çekim / Görüntü
                {yetki('radyoloji-istem', 'degistir') &&
                  <button type="button" className="rik-kalem" title="Düzenle" onClick={() => void cekimAc()}>✎</button>}</h4>
              <div className="rik-bilgi">
                {ikili('Cihaz', M(k, 'cihaz') || M(k, 'modaliteAdi'))}
                {ikili('Tekniker', M(k, 'tekniker'))}
                {ikili('Çekim', zaman(k['cekimTarihi']))}
                {ikili('Kontrast', kontrastAd)}
                {ikili('Seri / Görüntü', N(k, 'seriSayisi') || N(k, 'goruntuSayisi')
                  ? `${N(k, 'seriSayisi')} seri · ${N(k, 'goruntuSayisi')} görüntü` : '')}
                {doz && ikili('Doz', doz)}
              </div>
            </>}
          </div>

          {/* PACS GÖRÜNTÜLERİ (kullanıcı 11.11.2026: hasta kartından buraya taşındı): hastanın PACS'taki tüm çalışmaları,
              istemin kendi çalışması vurgulu; "Bağla" study_uid yazar, "Aç" OHIF. Yalnız kayıtlı istemde ve hasta belliyken. */}
          {istemId > 0 && N(k, 'hastaId') > 0 && yetki('radyoloji', 'gor') && (
            <div className="rik-blok">
              <h4>PACS Görüntüleri <span className="rik-ip" style={{ marginLeft: 0 }}>· hastanın PACS'taki çalışmaları</span></h4>
              <PacsGoruntuleri hastaId={N(k, 'hastaId')} istemId={istemId} vurguStudyUid={M(k, 'studyUid')}
                               vurguAccession={M(k, 'accessionNo')} bagliDegisti={() => void yukle()} />
            </div>
          )}
        </div>

        {/* İSTEM KÂĞIDI / DIŞ KURUM BELGELERİ (310 kaynağı "radyoloji-istem") - sağ sütun; radyolog buradan bakar. */}
        <div className="rik-sagsutun">
          {/* İSTEM KÂĞIDI: görünümde dosya listesi; kalemle ekle / sil (dosya yüklenince kaydolur - "Tamam" yeter). */}
          <div className="rik-blok rik-kagit">
            <h4>İstem Kâğıdı
              {kagitDuzen
                ? <span className="rik-blokarac"><button type="button" className="d bir" onClick={() => setKagitDuzen(false)}>✓ Tamam</button></span>
                : yetki('radyoloji-istem', 'degistir') &&
                  <button type="button" className="rik-kalem" title="Düzenle" onClick={() => setKagitDuzen(true)}>✎</button>}</h4>
            {istemId > 0 && (kagitDuzen
              ? <DokumanGalerisi kartAdi="radyoloji-istem" kaynakId={istemId} saltOkunur={false} />
              : <div className="rik-kagitliste"><DokumanGalerisi kartAdi="radyoloji-istem" kaynakId={istemId} saltOkunur gosterim /></div>)}
          </div>
          {/* ÇEKİM ÖNCESİ KONTROL - İSTEM KÂĞIDI ALTINDA, HER ZAMAN GÖRÜNÜR (kullanıcı 01.11.2026); kalemle yanıtlanır. */}
          <div className="rik-blok">
            <h4>Çekim Öncesi Kontrol
              {kontrol.length > 0 && (kontrolDuzen
                ? <span className="rik-blokarac">
                    <button type="button" className="d bir" onClick={() => kontrolKaydet(
                      kontrol.filter(s => (kontrolTaslak[s.soruId] ?? s.yanit) !== s.yanit)
                             .map(s => ({ soruId: s.soruId, yanit: (kontrolTaslak[s.soruId] ?? '').trim() })))}>💾 Kaydet</button>
                    <button type="button" className="d" onClick={() => { setKontrolTaslak({}); setKontrolDuzen(false) }}>Vazgeç</button>
                  </span>
                : yetki('radyoloji', 'degistir') && !cekildi &&
                  <button type="button" className="rik-kalem" title="Düzenle"
                          onClick={() => { setKontrolTaslak({}); setKontrolDuzen(true) }}>✎</button>)}
              {!kontrolDuzen && kontrol.length > 0 && <span className="rik-ip">{kontrol.length} soru · {yanitli} yanıt</span>}</h4>
            {kontrol.length === 0 ? (
              <div className="rik-tek">Bu tetkik türü ({M(k, 'modaliteAdi') || '—'}) için kontrol sorusu tanımlı değil.</div>
            ) : (
              <table className="rik-kontrol"><tbody>
                {kontrol.map(s => {
                  const deger = kontrolTaslak[s.soruId] ?? s.yanit;
                  return (
                    <tr key={s.soruId}>
                      <td>{s.yanit ? '☑' : '☐'}</td>
                      <td>{s.soru}{s.zorunlu ? <span className="rik-soluk"> *</span> : null}</td>
                      <td className="rik-y">
                        {kontrolDuzen ? (
                          s.yanitTipi === 2
                            ? <input className="inp" style={{ width: 110 }} value={deger} placeholder="değer"
                                     onChange={e => setKontrolTaslak(t => ({ ...t, [s.soruId]: e.target.value }))} />
                            : <span className="rik-seg">
                                {['Evet', 'Hayır'].map(y => (
                                  <button type="button" key={y} className={deger === y ? 'on' : ''}
                                          onClick={() => setKontrolTaslak(t => ({ ...t, [s.soruId]: deger === y ? '' : y }))}>{y}</button>))}
                              </span>
                        ) : <>{s.yanit ? <b className="rik-yanit">{s.yanit}</b> : '—'}
                              {s.kaydeden && <span className="rik-soluk"> · {s.kaydeden}{s.kayitZamani ? ` ${zaman(s.kayitZamani)}` : ''}</span>}</>}
                      </td>
                    </tr>);
                })}
              </tbody></table>
            )}
          </div>
        </div>
      </div>

      <TarafArama acik={teknikerArama} kaynaklar={['personel']} yerTutucu="Tekniker / personel ara…"
                  onKapat={() => setTeknikerArama(false)}
                  onSec={sec => { cs({ teknikerId: sec.id, teknikerAd: sec.unvan }); setTeknikerArama(false) }} />
      {icdAcik && (
        <KaynakArama kaynak="icd" baslik="ICD-10 tanı ara" ilkSik kullanimIsaretle
                     ekKosul={{ alan: 'aktif', op: 'esit', deger: 1 }}
                     onSec={s => { fs({ onTani: String(s.kod ?? '') }); setOnTaniAdi(String(s.ad ?? '')); setIcdAcik(false) }}
                     onKapat={() => setIcdAcik(false)} />
      )}

      <div className="statusbar" style={{ marginTop: 10, display: 'flex', gap: 18 }}>
        <span>Bekleme (istem→çekim): <b>{akis?.['beklemeDk'] != null ? `${N(akis, 'beklemeDk')} dk` : '—'}</b></span>
        <span>Rapor: <b>{M(akis, 'raporNo') || (N(akis, 'raporDurum') ? 'Taslak' : '—')}</b>{M(akis, 'raporYazan') ? ` · ${M(akis, 'raporYazan')}` : ''}</span>
        <span className="sp">Oluşturan: <b>{M(akis, 'olusturan')}</b> · {zaman(akis?.['istemZamani'])}</span>
      </div>
    </div>
  );
}

/* v2 YERLEŞİM (kullanıcı 01.11.2026: "rad istem ekranı kutularla çok kalabalık.. mockup yap" → "uygun"). Sınıflar
   "rik-" önekli: tema.css'teki kısa adlarla (.d düğme) çakışmasın. */
const RIK_STIL = `
.rik .rik-bas{display:flex;align-items:center;gap:8px;padding:6px 2px 8px;border-bottom:1px solid #e3e9f0}
.rik .rik-bas h1{margin:0;font-size:15px;color:var(--baslik,#14315a)}
.rik .rik-acc{font-family:Consolas,monospace;font-size:13px;color:var(--baslik,#14315a);background:#f3f6fa;border:1px solid #e3e9f0;border-radius:3px;padding:1px 6px}
.rik .rik-acc.bekliyor{color:#a46a10;border-color:#f0dcb6;background:#fdf8ee;font-family:inherit;font-size:11px}
.rik .rik-sag{margin-left:auto;display:flex;gap:4px}
/* BANT TEK SATIR, ARALIKLI (kullanıcı 01.11.2026): etiket değerin solunda, bölümler ayraçla; sığmazsa değer kırpılır. */
.rik .rik-band{display:flex;flex-wrap:nowrap;align-items:baseline;padding:9px 4px;border-bottom:1px solid #e3e9f0;overflow:hidden;white-space:nowrap}
.rik .rik-band > div{padding:0 22px;border-left:1px solid #e3e9f0;min-width:0;overflow:hidden;text-overflow:ellipsis}
.rik .rik-band > div:first-child{padding-left:0;border-left:0}
.rik .rik-k{font-size:10px;color:var(--soluk,#6b7a8b);text-transform:uppercase;letter-spacing:.3px;margin-right:7px}
.rik .rik-v{font-size:12.5px;font-weight:bold}
.rik .rik-hasta .rik-v{font-size:14px;color:var(--baslik,#14315a);margin-left:7px}
.rik .rik-band{align-items:center}
.rik .rik-hasta{display:flex;align-items:center;flex-shrink:0}
.rik .rik-kod,.rik .rik-icd,.rik .rik-soluk{color:var(--soluk,#6b7a8b);font-size:11px}
.rik .rik-sevk{display:inline-block;margin-left:4px;padding:1px 8px;border-radius:10px;font-size:10.5px;background:#fdf3e1;color:#a46a10;border:1px solid #f0dcb6}
.rik .rik-akis{display:flex;padding:8px 18px 10px;border-bottom:1px solid #e3e9f0}
.rik .rik-adim{flex:1;text-align:center;font-size:10.5px;color:var(--soluk,#6b7a8b);position:relative;padding-top:15px}
.rik .rik-adim::before{content:"";position:absolute;top:3px;left:50%;transform:translateX(-50%);width:10px;height:10px;border-radius:50%;background:#fff;border:2px solid #cdd6e0;z-index:1}
.rik .rik-adim::after{content:"";position:absolute;top:8px;left:50%;width:100%;height:2px;background:#e3e9f0}
.rik .rik-adim:last-child::after{display:none}
.rik .rik-adim small{display:block;font-size:9.5px;font-weight:normal;color:var(--soluk,#6b7a8b)}
.rik .rik-adim.ok{color:#2e7d46;font-weight:bold}
.rik .rik-adim.ok::before{background:#2e7d46;border-color:#2e7d46}
.rik .rik-adim.ok::after{background:#9fd0ae}
.rik .rik-adim.simdi{color:#2f6db3;font-weight:bold}
.rik .rik-adim.simdi::before{background:#2f6db3;border-color:#2f6db3;box-shadow:0 0 0 3px rgba(47,109,179,.2)}
/* Bloklar çok genişti (kullanıcı 01.11.2026: "kabul ve çekim gridlerini biraz daralt"): sol sütun en çok 820 px. */
/* Sağ sütun (istem kâğıdı + kontrol) kalan genişliği doldurur (kullanıcı 02.11.2026: "sağında boşluk var.. sağa doğru uzat"). */
.rik .rik-govde{display:grid;grid-template-columns:minmax(0,820px) minmax(360px,1fr);gap:14px;padding:12px 0}
@media (max-width:1000px){.rik .rik-govde{grid-template-columns:1fr}}
.rik .rik-blok{border:1px solid #e3e9f0;border-radius:4px;margin-bottom:12px;background:#fff}
.rik .rik-blok h4{margin:0;padding:6px 10px;font-size:11.5px;color:var(--baslik,#14315a);background:#f3f6fa;border-bottom:1px solid #e3e9f0;border-radius:4px 4px 0 0;display:flex;gap:8px;align-items:center}
.rik .rik-ip{margin-left:auto;font-weight:normal;color:var(--soluk,#6b7a8b);font-size:10.5px}
.rik .rik-form,.rik .rik-bilgi{display:grid;grid-template-columns:110px minmax(0,1fr) 90px minmax(0,1fr);gap:7px 10px;padding:10px;align-items:center}
.rik .rik-bilgi{gap:6px 10px;align-items:baseline}
.rik .rik-et{font-size:11px;color:var(--soluk,#6b7a8b);text-align:right}
.rik .rik-d{font-size:12px;min-width:0}
.rik .rik-tam{grid-column:2 / -1}
/* tema.css ".inp { grid-column: 2 }" kart formunda ikinci çift sütunu (Cihaz) alt satıra düşürüyordu. */
.rik .rik-form > .inp:not(.rik-tam){grid-column:auto}
.rik .rik-satir{display:flex;gap:6px;align-items:center;min-width:0}
.rik .rik-satir > *{flex:1;min-width:0}
.rik .rik-satir > .rik-seg,.rik .rik-satir > input[style]{flex:0 0 auto}
.rik .rik-ara{display:flex;align-items:center;border:1px solid var(--cizgi,#cdd6e0);border-radius:2px;background:#fff;height:24px;min-width:0}
.rik .rik-ara input{flex:1;min-width:0;border:0;height:22px;padding:0 7px;background:transparent;font-size:12px;cursor:pointer;outline:none}
.rik .rik-ara .rik-icd{flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;padding-right:6px}
.rik .rik-ara button{border:0;border-left:1px solid #e3e9f0;background:transparent;height:22px;padding:0 8px;color:var(--soluk,#6b7a8b);cursor:pointer}
.rik .rik-seg{display:inline-flex;border:1px solid var(--cizgi,#cdd6e0);border-radius:3px;overflow:hidden;height:24px;width:max-content}
.rik .rik-seg button{border:0;border-right:1px solid #e3e9f0;background:#fff;padding:0 12px;font-size:11.5px;cursor:pointer}
.rik .rik-seg button:last-child{border-right:0}
.rik .rik-seg button.on{background:#d7e7fb;color:var(--baslik,#14315a);font-weight:bold}
/* ACİL KIRMIZI (kullanıcı 01.11.2026). */
.rik .rik-seg button.on.acil{background:#c0392b;color:#fff}
.rik textarea.inp{height:auto;min-height:46px;padding:5px 7px;resize:vertical}
.rik .rik-tek{padding:8px 10px;color:var(--soluk,#6b7a8b);font-size:11.5px;display:flex;gap:6px;align-items:center}
.rik .rik-tek b{color:var(--yazi,#1f2d3a);font-weight:normal}
.rik .rik-link{margin-left:auto;border:0;background:none;color:var(--soluk,#6b7a8b);font-size:10.5px;cursor:pointer}
.rik .rik-kontrol{width:100%;border-collapse:collapse;font-size:11.5px}
.rik .rik-kontrol td{padding:5px 10px;border-top:1px solid #e3e9f0}
.rik .rik-kontrol tr:first-child td{border-top:0}
.rik .rik-kontrol td:first-child{width:20px}
.rik .rik-y{color:var(--soluk,#6b7a8b);text-align:right;white-space:nowrap}
.rik .rik-y .rik-seg{vertical-align:middle}
.rik .rik-kontrol td{vertical-align:middle}
.rik .rik-sagsutun{align-self:start;min-width:0}
.rik .rik-kagit{overflow:hidden}
/* Dar sütunda kontrol: soru üstte, yanıt altında sağa yaslı. */
.rik .rik-sagsutun .rik-kontrol td.rik-y{white-space:normal}
.rik .rik-sagsutun .rik-tek{flex-wrap:wrap}
.rik .rik-yanit{color:var(--yazi,#1f2d3a);font-weight:600}
.rik .rik-kagitliste{padding:6px 10px}
.rik .rik-kagitliste .fm-bos{color:var(--soluk,#6b7a8b);font-size:11.5px;padding:4px 0}
.rik .rik-kalem{margin-left:2px;border:1px solid transparent;background:none;color:var(--vurgu,#2f6db3);font-size:14px;line-height:1;padding:2px 6px;border-radius:3px;cursor:pointer}
.rik .rik-kalem:hover{border-color:#cdd6e0;background:#fff}
.rik .rik-blokarac{margin-left:auto;display:flex;gap:4px}
.rik .rik-blokarac .d{padding:2px 9px;font-size:11px}
/* Doküman galerisi dar sütunda: kendi çerçevesi kalkar, araç düğmeleri sarar. */
.rik .rik-kagit .kagrup{border:0;margin:0;box-shadow:none}
.rik .rik-kagit .kagrup > h6{display:flex;flex-wrap:wrap;gap:4px;align-items:center}
.rik .rik-kagit .kagrup > h6 .d{padding:2px 7px;min-width:0}
`;
