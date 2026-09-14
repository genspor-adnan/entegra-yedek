import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './kurumTipiAyarlari.css';
import { api } from '../api/istemci';
import { useOturum } from '../kimlik/OturumBaglami';
import { hataMetni, type KurumProfil, type KurumProfilYaniti } from '../api/sozlesme';
import { mesaj } from './mesaj';

/**
 * Kurum tipi kartlarinin ikonu ve bir cumlelik tanimi - mockup'tan; ad ve sira
 * DB'den (kurum_tipi) gelir, burada yalniz gorsel tarafi durur.
 */
const TIP_GORSEL: Record<string, { ikon: string; aciklama: string }> = {
  muayenehane:     { ikon: '🩺',  aciklama: 'Tek hekim · muayene · reçete · randevu · basit tahsilat' },
  dal_goz:         { ikon: '👁',  aciklama: 'Göz muayene (OD/OS) · görüntüleme cihazları · gözlük/lens · enjeksiyon · ameliyathane' },
  dal_ftr:         { ikon: '🦵',  aciklama: 'FTR muayene · seans programı (kür) · uygulama ünitleri · ölçek/skala takibi' },
  goruntuleme:     { ikon: '🩻',  aciklama: 'Radyoloji istem/rapor · PACS · teleradyoloji · maliyet (cihaz)' },
  lab:             { ikon: '🧪',  aciklama: 'LIS · cihaz entegrasyonu · biyokimya/mikro/genetik · sonuç formları · dış kurum' },
  goruntuleme_lab: { ikon: '🩻🧪', aciklama: 'Radyoloji + LIS birlikte · dış kurum portalı · ortak kabul' },
  dis:             { ikon: '🦷',  aciklama: 'Odontogram · tedavi planı/proforma · ünit çizelgesi · protez lab · taksit' },
  tip_merkezi:     { ikon: '🏥',  aciklama: 'Poliklinikler · muayene · lab + radyoloji · teletıp · e-Nabız tam · kurum sözleşmeleri' },
  hastane:         { ikon: '🏨',  aciklama: '+ yatan hasta · ameliyathane · eczane/depo · acil · yoğun bakım · HBYS tam (sonraki faz)' },
  erp:             { ikon: '🏭',  aciklama: 'Üretim · ticaret · stok · satış/alış · muhasebe (HBYS modülleri kapalı)' },
};

/** Entegrasyon gerekliligi (491): 2 zorunlu · 1 onerilen · 0 opsiyonel. */
const GEREKLILIK: Record<number, string> = {
  2: 'zorunlu', 1: 'önerilen', 0: 'opsiyonel',
};

/** Modul varsayilan rozeti: 1 acik · 2 opsiyonel · 0 bu tipte anlamsiz. */
const MATRIS_ISARET: Record<number, { sinif: string; im: string }> = {
  1: { sinif: 'm-on',  im: '●' },
  2: { sinif: 'm-ops', im: '◐' },
  0: { sinif: 'm-off', im: '○' },
};

/**
 * KURUM PROFILI & SISTEM AYARLARI - Yönetim › Kurum Profili (489'da Firma
 * Bilgileri'nin sekmesinden kendi ekranina tasindi).
 *
 * Ekranin duzeni Ekranlar/Ayarlar/kurum_tipi_ayarlari.html mockup'indan BIREBIR
 * alindi; mockup'in CSS'i `.kt-kok` altina kapsullendi (kurum tipi kartlari,
 * modul matrisi ve rozetler uygulamanin genel temasindan bagimsiz durur).
 *
 * SIMDILIK GORUNUM: secimler ve kutucuklar henuz `kurum_profil` tablosuna
 * baglanmadi - kurulum sihirbazinin ekran karsiligi. Baglama sirasinda bu
 * bilesenin ic sekme duzeni degismeyecek.
 */
const SEKMELER = ['1 · Profil', '2 · Modüller', '3 · Kayıt & Ücretlendirme', '4 · Klinik Ayarlar', '5 · Entegrasyonlar', '6 · Kaynaklar (birim/ünit/cihaz)', '7 · Özet & Kurulum'];

export function KurumTipiAyarlari() {
  const [aktif, setAktif] = useState(0);
  const { kullanici, tazele } = useOturum();
  const git = useNavigate();
  /**
   * HANGI SUBENIN PROFILI (364/489): her zaman BIR SUBE.
   *
   * "Kurum geneli (tüm şubeler)" secenegi KALDIRILDI (kullanici): kurum
   * geneli satiri duzenlenince kendi subesinin ayri satiri olan kullanici
   * degisikligi ekraninda goremiyordu ("ayarladim ama degismedi"). Artik
   * her sube kendi profilini ayri ayri set eder; kurum geneli satiri
   * (sube 0) yalnizca DB'de devralma yedegi olarak durur.
   */
  const [subeId, setSubeId] = useState(kullanici?.subeId ?? 0);

  // Aktif sube oturumla birlikte gec geliyorsa (ilk cizimde null) ilk
  //   subeye kilitlenir - combo bos kalmasin.
  useEffect(() => {
    if (subeId !== 0) return;
    const ilk = kullanici?.subeId ?? kullanici?.subeler?.[0]?.id ?? 0;
    if (ilk !== 0) setSubeId(ilk);
  }, [kullanici, subeId]);
  const [veri, setVeri] = useState<KurumProfilYaniti | null>(null);
  /** Ekrandaki (henuz kaydedilmemis) profil. */
  const [profil, setProfil] = useState<KurumProfil | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [kaydediyor, setKaydediyor] = useState(false);
  /** Kategori yazilirken o satirin kutucugu kilitlenir (527). */
  const [kategoriYazan, setKategoriYazan] = useState<number | null>(null);

  const yukle = useCallback(async () => {
    try {
      const y = await api.kurumProfil(subeId);
      setVeri(y);
      setProfil(y.profil);
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [subeId]);
  useEffect(() => { void yukle() }, [yukle]);

  const degistir = (y: Partial<KurumProfil>) =>
    setProfil(o => (o ? { ...o, ...y } : o));

  /** Secili tipin modul varsayilani (matris satiri). */
  const tipVarsayilani = (modul: string) =>
    veri?.matris.find(m => m.kurumTipi === profil?.kurumTipi && m.modul === modul)?.varsayilan ?? 0;

  /** Modul BU KURULUMDA acik mi: once override, yoksa tip varsayilani (1 = acik). */
  const modulAcik = (modul: string) => {
    const o = profil?.moduller?.[modul];
    return o !== undefined ? o === 1 : tipVarsayilani(modul) === 1;
  };

  const modulCevir = (modul: string) => {
    if (!profil) return;
    const yeni = { ...(profil.moduller ?? {}) };
    yeni[modul] = modulAcik(modul) ? 0 : 1;
    degistir({ moduller: yeni });
  };

  /**
   * Kurum tipi degisince modul OVERRIDE'lari silinir: yeni tipin varsayilan
   * paketi gecerli olsun - eski tipten kalan "lab kapali" gibi bir isaret
   * kullaniciyi sasirtirdi.
   */
  const tipSec = (kod: string) => degistir({ kurumTipi: kod, moduller: {} });


  /**
   * KATEGORI ACIK/KAPALI (527). Yalniz kategori yazilir; altindaki hizmet ve
   * stoklarin durumunu DB tetigi yayar - kural iki yerde tekrarlanmasin.
   */
  const kategoriDegis = async (id: number, acik: boolean) => {
    setKategoriYazan(id);
    try {
      await api.kurumKategoriYaz(id, acik ? 1 : 0);
      await yukle();
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setKategoriYazan(null);
    }
  };

  /** Secili kurum tipinin onerdigi kategori setini uygular (527). */
  const kategoriOnerisiUygula = async () => {
    setKategoriYazan(-1);
    try {
      const s2 = await api.kurumKategoriUygula();
      await yukle();
      setHata(null);
      await mesaj(s2.mesaj);
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setKategoriYazan(null);
    }
  };

  const kaydet = async () => {
    if (!profil) return;
    setKaydediyor(true);
    try {
      const y = await api.kurumProfilYaz({ ...profil, subeId });
      setProfil(y.profil);
      setVeri(v => (v ? { ...v, profil: y.profil } : v));
      setHata(null);
      // AKTIF SUBEYI etkilediyse menu/rotalar hemen degissin: acik modul kumesi
      //   oturumdan geliyor (359/364), yoksa kullanici degisikligi ancak yeniden
      //   giriste gorurdu.
      const aktifSube = kullanici?.subeId ?? 0;
      if (subeId === aktifSube) await tazele();
      mesaj('Kurum profili kaydedildi.'
            + (subeId !== aktifSube ? ' (Menü aktif şubenin profiline göre çizilir.)' : ''));
    } catch (h) { setHata(hataMetni(h)) }
    finally { setKaydediyor(false) }
  };

  const tipAdi = (kod?: string) => veri?.tipler.find(t => t.kod === kod)?.ad ?? '';

  // Ozet kutulari ve kurulum adimlari (7. sekme) - hepsi sunucudan.
  const kurulum = veri?.kurulum ?? [];
  const entegrasyonlar = veri?.entegrasyonlar ?? [];
  const tamamAdim = kurulum.filter(a => a.durum === 1).length;
  const bekleyenAdim = kurulum.length - tamamAdim;

  // Ozet kutulari icin canli sayilar (7. sekme).
  const acikModulSayisi = (veri?.moduller ?? []).filter(m => modulAcik(m.kod)).length;
  const opsiyonelModulSayisi = (veri?.matris ?? [])
    .filter(m => m.kurumTipi === profil?.kurumTipi && m.varsayilan === 2).length;

  return (
    <div className="kt-kok">
      <div className="toolbar">
        <div className={`btn primary${kaydediyor ? ' sonuk' : ''}`}
             onClick={() => { if (!kaydediyor) void kaydet() }}>
          💾 {kaydediyor ? 'Kaydediliyor…' : 'Kaydet & Uygula'}
        </div>
        <div className="btn" onClick={() => void yukle()}>↩ Kaydedilmişe Dön</div>
        {/* PROFIL SUBESI (364/489): YALNIZ SUBELER. Sube secilip kaydedilince
            o sube kendi profiline sahip olur; ilk acilista degerler kurum
            genelinden devralinmis gorunur. */}
        <span className="sp" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <label htmlFor="kt-sube">Şube:</label>
          <select id="kt-sube" value={subeId}
                  onChange={e => setSubeId(Number(e.target.value))}>
            {(kullanici?.subeler ?? []).map(s => (
              <option key={s.id} value={s.id}>{s.ad}</option>
            ))}
          </select>
          {subeId !== 0 && profil?.devralindi && (
            <span className="rz">kurum genelinden devralındı</span>
          )}
          {subeId !== 0 && !profil?.devralindi && (
            <span className="rz mavi">bu şubenin kendi profili</span>
          )}
        </span>
        <div className="btn sp">📖 Kurulum Rehberi</div>
      </div>
      {hata && <div className="hata-kutusu" style={{ margin: 8 }}>{hata}</div>}

      {/* AKTIF SUBE UYARISI (364, kullanici: "kurum tipi görüntüleme ama lab ve
          muayene görünüyor"): menu AKTIF SUBENIN profilinden cizilir - baska
          bir subenin profilini duzenlerken kendi menusu degismez. */}
      {subeId !== (kullanici?.subeId ?? 0) && (
        <div className="uyari" style={{ margin: '8px 10px' }}>
          Başka bir şubenin profilini düzenliyorsunuz; kendi menünüz değişmez.
          <span className="btn" style={{ display: 'inline-flex', marginLeft: 8 }}
                onClick={() => setSubeId(kullanici?.subeId ?? 0)}>
            ▶ Aktif şubeye geç
          </span>
        </div>
      )}

      <div className="sekmeler">
        {SEKMELER.map((b, i) => (
          <div key={b} className={`sekme${i === aktif ? ' on' : ''}`}
               onClick={() => setAktif(i)}>
            {b}
          </div>
        ))}
      </div>

      <div className="pnl" hidden={aktif !== 0}>
        <div className="ic sonuk">Kurum tipi menüyü, varsayılan modülleri, kayıt/ücretlendirme kurallarını ve klinik şablonları belirler. Sonradan değiştirilebilir; kapanan modülün verisi silinmez, menüden kalkar.</div>

        {/* KURUM TIPI KARTLARI - tiklanir; secim `kurum_profil.kurum_tipi`. */}
        <div className="tipler">
          {/* ERP KARTI YOK (kullanici): "üretim/ticaret" bir KURUM TIPI degil,
              urun modudur - altin altindaki "Ürün modu" combosu zaten onu
              secer. Iki yerde durmasi "hangisi gecerli" sorusunu uretiyordu.
              Kurulumun tipi zaten 'erp' ise kart gorunur, aksi halde secili
              tip ekranda hic gozukmezdi. */}
          {(veri?.tipler ?? []).filter(t => t.kod !== 'erp' || profil?.kurumTipi === 'erp')
            .map(t => (
            <div key={t.kod}
                 className={`tip${profil?.kurumTipi === t.kod ? ' sec' : ''}`}
                 onClick={() => tipSec(t.kod)}>
              <div className="ic">{TIP_GORSEL[t.kod]?.ikon ?? '🏢'}</div>
              <div className="ad">{t.ad}</div>
              <div className="k">{TIP_GORSEL[t.kod]?.aciklama ?? ''}</div>
              {profil?.kurumTipi === t.kod && <span className="rz mavi">Seçili</span>}
            </div>
          ))}
        </div>

        <div className="hdr k4">
          <div className="fld">
            <label className="req">Ürün modu</label>
            <select className="inp" value={profil?.urunModu ?? 2}
                    onChange={e => degistir({ urunModu: Number(e.target.value) })}>
              <option value={2}>HBYS (GenoTIP AI)</option>
              <option value={1}>ERP (Gentegre AI)</option>
              <option value={3}>İkisi (tıp merkezi + ticari)</option>
            </select>
          </div>
          <div className="fld">
            <label className="req">Kurum tipi</label>
            <select className="inp" value={profil?.kurumTipi ?? ''}
                    onChange={e => tipSec(e.target.value)}>
              {(veri?.tipler ?? []).map(t => (
                <option key={t.kod} value={t.kod}>{t.ad}</option>
              ))}
            </select>
          </div>
          <div className="fld">
            <label>Alt tip / branş</label>
            <input className="inp" value={profil?.altTip ?? ''} maxLength={60}
                   placeholder="örn. Dahiliye"
                   onChange={e => degistir({ altTip: e.target.value })} />
          </div>
          <div className="fld">
            <label>Basamak</label>
            <input className="inp" value={profil?.basamak ?? ''} maxLength={60}
                   placeholder="örn. 2. basamak özel"
                   onChange={e => degistir({ basamak: e.target.value })} />
          </div>
          <div className="fld">
            <label>Tesis kodu (ÇKYS)</label>
            <input className="inp" value={profil?.tesisKodu ?? ''} maxLength={20}
                   placeholder="11xxxxxx"
                   onChange={e => degistir({ tesisKodu: e.target.value })} />
          </div>
          <div className="fld">
            <label>Şube yapısı</label>
            <select className="inp" value={profil?.subeYapisi ?? 1}
                    onChange={e => degistir({ subeYapisi: Number(e.target.value) })}>
              <option value={1}>Tek şube</option>
              <option value={2}>Çok şube (her şube kendi tesis kodu)</option>
            </select>
          </div>
          <div className="fld">
            <label>Hekim sayısı / ünite</label>
            <div className="ikili-sayi">
              <input className="inp" type="number" min={0} value={profil?.hekimSayisi ?? 1}
                     onChange={e => degistir({ hekimSayisi: Number(e.target.value) })} />
              <input className="inp" type="number" min={0} value={profil?.uniteSayisi ?? 1}
                     onChange={e => degistir({ uniteSayisi: Number(e.target.value) })} />
            </div>
          </div>
          <div className="fld">
            <label>Dil / para birimi</label>
            <div className="ikili-sayi">
              <select className="inp" value={profil?.dil ?? 'tr'}
                      onChange={e => degistir({ dil: e.target.value })}>
                <option value="tr">Türkçe</option>
                <option value="en">English</option>
                <option value="de">Deutsch</option>
              </select>
              <select className="inp" value={profil?.paraBirimi ?? 'TL'}
                      onChange={e => degistir({ paraBirimi: e.target.value })}>
                <option value="TL">TL</option>
                <option value="USD">USD</option>
                <option value="EUR">EUR</option>
              </select>
            </div>
          </div>
          {/* KIMLIK NO BICIMI (679, kullanici: "kimlik biçimini kurum
              profiline ayar olarak ekle"). Etiket 671'de genellesti
              ("Kimlik No") ama dogrulama T.C. algoritmasiydi: yurt disinda
              gercek numarayi reddedip kaydi imkansiz kilardi, topluca
              kapatmak ise Turkiye'de yanlis TCKN'yi sessizce gecirirdi. */}
          <div className="fld">
            <label>Kimlik no biçimi</label>
            <select className="inp" value={profil?.kimlikBicimi ?? 'otomatik'}
                    onChange={e => degistir({ kimlikBicimi: e.target.value })}>
              <option value="otomatik">Otomatik — şubenin ülkesine göre</option>
              <option value="tc">T.C. Kimlik No (11 hane + kontrol hanesi)</option>
              <option value="serbest">Serbest — biçim kontrolü yok</option>
              <option value="desen">Özel desen (düzenli ifade)</option>
            </select>
          </div>
          {profil?.kimlikBicimi === 'desen' && (
            <div className="fld">
              <label>Desen / açıklama</label>
              <div className="ikili-sayi">
                <input className="inp" placeholder="^[A-Z0-9]{6,12}$"
                       value={profil?.kimlikDeseni ?? ''}
                       onChange={e => degistir({ kimlikDeseni: e.target.value })} />
                <input className="inp" placeholder="6-12 hane pasaport no"
                       value={profil?.kimlikAciklama ?? ''}
                       onChange={e => degistir({ kimlikAciklama: e.target.value })} />
              </div>
            </div>
          )}
        </div>

        {/* Secili tipin varsayilan paketi - matristen uretilir. */}
        <div className="grp" style={{ margin: '10px' }}>
          <div className="gb">Bu tipin varsayılan paketi — {tipAdi(profil?.kurumTipi)}</div>
          <div className="ic">
            <b>Açık:</b>{' '}
            {(veri?.moduller ?? []).filter(m => tipVarsayilani(m.kod) === 1)
              .map(m => m.ad).join(' · ') || '—'}
            <br />
            <b>Opsiyonel:</b>{' '}
            {(veri?.moduller ?? []).filter(m => tipVarsayilani(m.kod) === 2)
              .map(m => m.ad).join(' · ') || '—'}
            <br />
            <b>Kapalı:</b>{' '}
            {(veri?.moduller ?? []).filter(m => tipVarsayilani(m.kod) === 0)
              .map(m => m.ad).join(' · ') || '—'}
          </div>
        </div>
      </div>

      <div className="pnl" hidden={aktif !== 1}>
        <div className="ic sonuk">● açık · ◐ opsiyonel (aç/kapat) · ○ bu tipte anlamsız (gizli). Matris tipin VARSAYILANIDIR; alttaki kutucuklar bu kurulumun kendi seçimini yazar. Modül kapanınca menü, yetkiler ve kart sekmeleri gizlenir; veri kalır.</div>

        {/* TIP x MODUL VARSAYILANLARI (kurum_tipi_modul) - secili tip vurgulu. */}
        <div className="dg matris">
          <table>
            <thead>
              <tr>
                <th>Kurum tipi</th>
                {(veri?.moduller ?? []).map(m => (
                  <th key={m.kod} className="orta" style={{ fontSize: '10px' }}>{m.ad}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {(veri?.tipler ?? []).map(t => (
                <tr key={t.kod} className={profil?.kurumTipi === t.kod ? 'sel' : ''}
                    style={{ cursor: 'pointer' }} onClick={() => tipSec(t.kod)}>
                  <td><b>{t.ad}</b></td>
                  {(veri?.moduller ?? []).map(m => {
                    const v = veri?.matris.find(x => x.kurumTipi === t.kod && x.modul === m.kod)
                                ?.varsayilan ?? 0;
                    const i = MATRIS_ISARET[v] ?? MATRIS_ISARET[0];
                    return (
                      <td key={m.kod} className="orta">
                        <span className={i.sinif}>{i.im}</span>
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* BU KURULUMUN SECIMI - override'lar kurum_profil.moduller'e yazilir. */}
        <div className="grp" style={{ margin: '10px' }}>
          <div className="gb">Bu kurumda açık modüller — {tipAdi(profil?.kurumTipi)}</div>
          <div className="modul-kutulari">
            {(veri?.moduller ?? []).map(m => {
              const vars = tipVarsayilani(m.kod);
              const acik = modulAcik(m.kod);
              const ozel = profil?.moduller?.[m.kod] !== undefined
                           && (profil?.moduller?.[m.kod] === 1) !== (vars === 1);
              return (
                <label key={m.kod} className={`modul-kutu${acik ? ' acik' : ''}`}
                       title={vars === 1 ? 'Bu tipin varsayılan paketinde açık'
                              : vars === 2 ? 'Opsiyonel - açıp kapatabilirsiniz'
                              : 'Bu tipte anlamsız; yine de açabilirsiniz'}>
                  <input type="checkbox" checked={acik} onChange={() => modulCevir(m.kod)} />
                  <span>{m.ad}</span>
                  <span className={MATRIS_ISARET[vars].sinif}>{MATRIS_ISARET[vars].im}</span>
                  {ozel && <span className="rz mavi">özel</span>}
                </label>
              );
            })}
          </div>
          <div className="ic sonuk">
            Rozet tipin varsayılanını gösterir; kutucuk bu kurulumun seçimidir.
            Varsayılandan ayrılan modüller <b>özel</b> işaretiyle durur.
            <b> Kaydet &amp; Uygula</b> ile yazılır.
          </div>
        </div>

        {/* HIZMET / STOK KATEGORILERI (527, kullanici: "profile gore kimler
            neyi kullanacak - gorüntuleme merkezi sadece radyoloji kullanir,
            laboratuvar sadece tahlil islemleri gibi").
            Kategori kapaninca ALTINDAKI HIZMET/STOKLAR da pasif olur
            (kullanici: "ikisi de pasif olsun veya aktif") - yayilimi DB
            tetigi yapar. Elle kapatilan kayit geri acilmaz. */}
        <div className="grp">
          <div className="hdr k4">Hizmet / Stok Kategorileri</div>
          <div className="ic sonuk">
            Kurumun hangi işleri yaptığı. Kapatılan kategorinin
            <b> altındaki hizmet ve stoklar da pasif</b> olur; yeniden açınca
            geri gelirler (elle kapattıklarınız kapalı kalır). Rozet seçili
            kurum tipinin <b>önerisidir</b> - bağlayıcı değil.
          </div>
          <div className="ktkutu">
            {(veri?.kategoriler ?? []).map(k => (
              <label key={k.id} className={`ktsatir${k.aktif ? ' on' : ''}`}>
                <input type="checkbox" checked={k.aktif === 1}
                       disabled={kategoriYazan === k.id}
                       onChange={e => { void kategoriDegis(k.id, e.target.checked) }} />
                <span className="ktad">{k.ad}</span>
                <span className="ktetiket">{k.tur === 1 ? 'stok' : 'hizmet'}</span>
                <span className="ktadet">{k.adet.toLocaleString('tr')}</span>
                {k.onerilen === 1
                  ? <span className="rozet olumlu">önerilen</span>
                  : <span className="rozet">bu tipte gerekmez</span>}
              </label>
            ))}
          </div>
          <div className="ktarac">
            <button type="button" className="d"
                    disabled={kategoriYazan !== null}
                    onClick={() => { void kategoriOnerisiUygula() }}>
              ↺ Tipin önerisini uygula
            </button>
            <span className="ic sonuk">
              Seçili tipin ({profil?.kurumTipi}) önerdiği kategorileri açar,
              ötekileri kapatır.
            </span>
          </div>
        </div>
      </div>

      <div className="pnl" hidden={aktif !== 2}>
          <div className="hdr k4">
            <div className="fld"><label>Başvuru modeli</label><div className="inp combo">Tek başvuru = tek muayene <span className="sonuk">· tıp merkezi: başvuru altında çoklu hizmet · hastane: yatış</span></div></div>
            <div className="fld"><label>Ödeyen kurumlar</label><div className="inp">☑ Özel (kendi) · ☑ SGK · ☑ Özel sigorta (ÖSS) · ☐ Kurum sözleşmeleri · ☐ Yabancı/sağlık turizmi</div></div>
            <div className="fld"><label>SGK faturalama</label><div className="inp combo">Dönem icmali (289) <span className="sonuk">· vaka bazlı</span></div></div>
            <div className="fld"><label>Provizyon</label><div className="inp combo">Medula otomatik <span className="sonuk">· elle · yok</span></div></div>
            <div className="fld"><label>Fiyat listesi</label><div className="inp combo">Özel 2026 (varsayılan) · SUT (SGK) · kurum sözleşmesi</div></div>
            <div className="fld"><label>Ücretlendirme anı</label><div className="inp combo">Muayene açılınca (muayene ücreti) + işlem anında <span className="sonuk">· diş: seans; lab/rad: istem</span></div></div>
            <div className="fld"><label>Ön ödeme</label><div className="inp combo">İsteğe bağlı <span className="sonuk">· zorunlu (teletıp/özel)</span></div></div>
            <div className="fld"><label>Belge üretimi</label><div className="inp combo">Tahsil edilen kadar fiş, kalanı tahakkuk (352) <span className="sonuk">· her işlem fatura · dönem faturası</span></div></div>
            <div className="fld"><label>e-Belge</label><div className="inp combo">e-Arşiv (hasta) · e-Fatura (kurum) · entegratör: İzibiz</div></div>
            <div className="fld"><label>Numara şablonları</label><div className="inp">Protokol: {'{'}yıl{'}'}/{'{'}sıra{'}'} · Hasta no: H{'{'}sıra:6{'}'} · Plan: TP-{'{'}yıl{'}'}/{'{'}sıra{'}'}</div></div>
            <div className="fld"><label>Hasta kimlik doğrulama</label><div className="inp combo">KPS (opsiyonel) · kimlik no zorunlu · yabancı: pasaport</div></div>
            <div className="fld"><label>KVKK</label><div className="inp">☑ Hasta kayıtları özel nitelikli · ☑ erişim günlüğü · saklama: 10 yıl (sağlık) · 15 yıl (personel sağlık)</div></div>
          </div>
        </div>

      <div className="pnl" hidden={aktif !== 3}>
          <div className="ikiPanel">
            <div className="hdr" style={{gridTemplateColumns: '1fr 1fr'}}>
              <div className="fld"><label>Muayene şablonu</label><div className="inp combo">Dahiliye genel <span className="sonuk">· dal: göz OD/OS, FTR skala, diş odontogram</span></div></div>
              <div className="fld"><label>Tamamlama kuralı</label><div className="inp">☑ Ana tanı · ☑ Şikâyet · ☐ Vital · ☑ Karar</div></div>
              <div className="fld"><label>Randevu</label><div className="inp">Slot 20 dk · hekim takvimi · ☐ ünit · ☐ cihaz · ☐ online</div></div>
              <div className="fld"><label>Sıra / çağırma</label><div className="inp combo">Kapalı <span className="sonuk">· sıra ekranı / anons</span></div></div>
              <div className="fld"><label>Onam türleri</label><div className="inp">Genel tedavi · KVKK · (dal: işlem onamları)</div></div>
              <div className="fld"><label>Reçete</label><div className="inp">Medula e-reçete · alerji/etkileşim kontrolü ☑</div></div>
              <div className="fld"><label>Rapor türleri</label><div className="inp">İstirahat · ilaç · durum bildirir · ☐ sağlık kurulu</div></div>
              <div className="fld"><label>Kronik takip</label><div className="inp">☑ DM · ☑ HT · ☐ glokom · ☐ DR · ☐ periodontal</div></div>
            </div>
            <div className="grp" style={{margin: '10px'}}><div className="gb">Tip bazlı klinik varsayılanlar</div>
              <div className="dg"><table><thead><tr><th>Tip</th><th>Muayene</th><th>Kaynak</th><th>Özel kural</th></tr></thead>
                <tbody>
                  <tr><td>Muayenehane</td><td>branş şablonu</td><td>hekim takvimi</td><td>tek başvuru = tek muayene</td></tr>
                  <tr><td>Göz</td><td>OD/OS ölçüm tabloları</td><td>ünite akışı: ön tetkik → hekim → görüntüleme</td><td>GİB panik, dilatasyon zamanlayıcı, IOL/UTS</td></tr>
                  <tr><td>FTR</td><td>skala/ölçek (VAS, ROM, Barthel)</td><td>uygulama ünitleri + fizyoterapist</td><td>kür (seans paketi), SUT seans limiti, hekim onaylı program</td></tr>
                  <tr><td>Görüntüleme</td><td>—</td><td>cihaz + tekniker + radyolog</td><td>SLA, kritik bulgu, teleradyoloji, çekim süresi maliyeti</td></tr>
                  <tr><td>Laboratuvar</td><td>—</td><td>cihaz + bölüm</td><td>panik, oto-onay, KK, Akılcı Lab formları</td></tr>
                  <tr><td>Diş</td><td>odontogram + periodontal</td><td>ünit + hekim</td><td>tedavi planı/proforma, seans ücretlendirme, lab iş emri</td></tr>
                  <tr><td>Tıp merkezi</td><td>branş şablonları</td><td>poliklinik + lab + rad</td><td>çoklu hizmet başvurusu, kurum sözleşmeleri, teletıp</td></tr>
                  <tr><td>Hastane</td><td>+ yatan hasta, ameliyat</td><td>servis/yatak/ameliyathane</td><td>yatış/çıkış (106), eczane, acil, yoğun bakım</td></tr>
                </tbody></table></div></div>
          </div>
        </div>

      <div className="pnl" hidden={aktif !== 4}>
          {/* ENTEGRASYONLAR CANLI (491, kullanici): mockup'ta 12 sabit satir
              vardi ve "bağlı / test / gizli" rozetleri gercek hesaplara
              bakmiyordu. Gereklilik urun modu + acik modullerden, durum
              entegrasyon_hesap'tan - ikisi de sunucuda
              (fn_kurum_entegrasyon_durumu). Ilgisiz entegrasyon (ERP'de SKRS,
              stok kapaliyken ÜTS) hic listelenmez. */}
          <div className="dg"><table><thead><tr>
              <th>Entegrasyon</th><th>Bu kurulumda</th><th>Hesap</th>
              <th className="orta">Durum</th><th>Son sonuç</th><th>Aksiyon</th></tr></thead>
            <tbody>
              {entegrasyonlar.map(e => (
                <tr key={e.kod}>
                  <td><b>{e.ad}</b> <span className="sonuk">{e.kod}</span></td>
                  <td>
                    <span className={`rz ${e.gereklilik === 2 ? 'sari' : ''}`}>
                      {GEREKLILIK[e.gereklilik] ?? 'opsiyonel'}
                    </span>{' '}
                    <span className="sonuk">{e.gerekce}</span>
                  </td>
                  <td>{e.hesap || <span className="sonuk">—</span>}</td>
                  <td className="orta">
                    <span className={`rz ${e.durum === 2 ? 'ok' : e.durum === 1 ? 'sari' : 'pas'}`}>
                      {e.durum === 2 ? 'canlı' : e.durum === 1 ? 'test' : 'hesap yok'}
                    </span>
                  </td>
                  {/* SON BAGLANTI SONUCU hesabin kendi denemesinden gelir -
                      "bağlı" rozeti yeterli degil, servis dun cevap vermemis
                      olabilir. */}
                  <td className="sonuk uzun">{e.sonSonuc || '—'}</td>
                  <td>
                    <div className="btn" style={{ display: 'inline-flex' }}
                         onClick={() => git('/genel-ayarlar')}>
                      ▶ {e.durum === 0 ? 'Hesap tanımla' : 'Hesabı aç'}
                    </div>
                  </td>
                </tr>
              ))}
              {entegrasyonlar.length === 0 && (
                <tr><td colSpan={6} className="sonuk" style={{ padding: 8 }}>
                  Bu kurulumda entegrasyon gerekmiyor.
                </td></tr>
              )}
            </tbody></table></div>
          <div className="ic sonuk">
            Hesaplar <b>Yönetim › Modül Ayarları › Genel</b> ekranındaki{' '}
            <code>entegrasyon_hesap</code> kayıtlarıdır; şube hesabı varsa o,
            yoksa kurum geneli okunur. Zorunlu olup hesabı olmayanlar{' '}
            <b>Özet &amp; Kurulum</b> listesinde de bekleyen adım olarak görünür.
            PACS/DICOM, lab cihaz ara katmanı, sanal POS, e-İmza, KPS ve WebRTC
            için hesap tanımı henüz yok — bağlandıklarında bu listeye eklenecek.
          </div>
        </div>

      <div className="pnl" hidden={aktif !== 5}>
          <div className="ikiPanel">
            <div className="grp" style={{margin: '10px'}}><div className="gb">Birimler / kaynaklar <span className="sp">tipe göre: oda · ünit · cihaz · servis/yatak</span></div>
              <div className="dg"><table><thead><tr><th>Kaynak</th><th>Tür</th><th>Bağlı</th><th className="orta">Randevu</th><th className="orta">Aktif</th></tr></thead>
                <tbody>
                  <tr><td>Muayene Odası 1</td><td>oda</td><td>Dr. A. Koç · Dahiliye</td><td className="orta">✔</td><td className="orta">✔</td></tr>
                  <tr className="sonuk"><td>Ünit 1–4</td><td>ünit</td><td>diş kliniğinde</td><td className="orta">—</td><td className="orta">gizli</td></tr>
                  <tr className="sonuk"><td>MR-1, BT-1 …</td><td>cihaz</td><td>görüntüleme merkezinde</td><td className="orta">—</td><td className="orta">gizli</td></tr>
                  <tr className="sonuk"><td>Servis A · 12 yatak</td><td>servis/yatak</td><td>hastanede</td><td className="orta">—</td><td className="orta">gizli</td></tr>
                </tbody></table></div>
              <div style={{padding: '6px 10px'}}><div className="btn">＋ Kaynak</div></div></div>
            <div className="hdr" style={{gridTemplateColumns: '1fr 1fr'}}>
              <div className="fld"><label>Departmanlar / poliklinikler</label><div className="inp">Dahiliye (SKRS 1000) <span className="sonuk">· tıp merkezinde çoklu</span></div></div>
              <div className="fld"><label>Hekimler</label><div className="inp">Dr. A. Koç · tescil ✔ · ÇKYS ✔</div></div>
              <div className="fld"><label>Personel rolleri</label><div className="inp">Hekim · sekreter · (hemşire) <span className="sonuk">· tekniker, hijyenist, radyolog, fizyoterapist tipe göre</span></div></div>
              <div className="fld"><label>Depolar</label><div className="inp">Sarf deposu <span className="sonuk">· ünit deposu, eczane, hammadde (ERP)</span></div></div>
              <div className="fld"><label>Kasalar / banka</label><div className="inp">TL Kasası · POS hesabı · Banka</div></div>
              <div className="fld"><label>Çalışma saatleri</label><div className="inp">Hafta içi 09:00–18:00 · Cmt 09:00–13:00</div></div>
            </div>
          </div>
        </div>

      <div className="pnl" hidden={aktif !== 6}>
          {/* OZET VE KURULUM ADIMLARI CANLI (490, kullanici: "profil yanlış
              geliyor" + "kurulum adımları tablosunu da canlıya bağla"):
              mockup'tan gelen sabit sekiz satir hangi adimin gercekten tamam
              oldugunu soylemiyordu. Karar SUNUCUDA (fn_kurum_kurulum_adimlari):
              her adimin sarti bir sayim/varlik sorgusu, ekran yalniz cizer.
              Urun modu ve kapali modul disi adimlar hic gelmez. */}
          <div className="ozet">
            <div className="kart"><div className="b">Profil</div>
              <div className="d">{tipAdi(profil?.kurumTipi) || '—'}</div></div>
            <div className="kart"><div className="b">Açık modül</div>
              <div className="d">{acikModulSayisi}{' '}
                <small>· {opsiyonelModulSayisi} opsiyonel</small></div></div>
            <div className="kart"><div className="b">Kurulum adımı</div>
              <div className="d">{tamamAdim}/{kurulum.length}{' '}
                <small>· {bekleyenAdim} bekliyor</small></div></div>
          </div>
          <div className="dg"><table><thead><tr>
              <th className="orta">#</th><th>Kurulum adımı</th><th>Durum</th>
              <th className="orta">Sonuç</th><th>Aksiyon</th></tr></thead>
            <tbody>
              {kurulum.map(a => (
                <tr key={a.kod}>
                  <td className="orta">{a.sira}</td>
                  <td>{a.ad}</td>
                  <td className="sonuk">{a.bilgi}</td>
                  <td className="orta">
                    <span className={`rz ${a.durum === 1 ? 'ok' : 'sari'}`}>
                      {a.durum === 1 ? 'tamam' : 'bekliyor'}
                    </span>
                  </td>
                  <td>
                    {/* Bekleyen adimda ekrana GOTUREN dugme: "eksik" demek
                        yetmez, kullanici nereye gidecegini de bilmeli. */}
                    {a.durum === 1 ? null : (
                      <div className="btn" style={{ display: 'inline-flex' }}
                           onClick={() => git(a.rota)}>▶ {a.aksiyon}</div>
                    )}
                  </td>
                </tr>
              ))}
              {kurulum.length === 0 && (
                <tr><td colSpan={5} className="sonuk" style={{ padding: 8 }}>
                  Kurulum adımı yok.
                </td></tr>
              )}
            </tbody></table></div>
          <div style={{padding: '8px 12px', display: 'flex', gap: '6px'}}>
            <div className={`btn primary${kaydediyor ? ' sonuk' : ''}`}
                 onClick={() => { if (!kaydediyor) void kaydet() }}>
              💾 Profili Kaydet &amp; Menüyü Uygula
            </div>
            {/* Adimlar baska ekranda tamamlaniyor - donunce listeyi tazele. */}
            <div className="btn" onClick={() => void yukle()}>🔄 Adımları yenile</div>
          </div>
          <div className="ic sonuk">Kaydet → <code>kurum_profil</code> + <code>kurum_modul</code> güncellenir; menü (listeTanimlari <code>urunModu/kurumTipi</code> süzmesi), yetki şablonları, kart sekmeleri (KartKatalogu <code>kurumTipi</code>), varsayılan ayarlar (ayar tablosu) tek işlemle uygulanır; değişiklik <code>islem_log</code>'a.</div>
        </div>
    </div>
  );
}
