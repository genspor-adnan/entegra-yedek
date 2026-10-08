import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './kurumTipiAyarlari.css';
import { api } from '../api/istemci';
import { useOturum } from '../kimlik/OturumBaglami';
import { MenuDuzeni } from '../sayfalar/MenuDuzeni';
import { hataMetni, type KurumProfil, type KurumProfilYaniti, type ProfilRolu }
  from '../api/sozlesme';
import { mesaj, onay } from './mesaj';
import { c } from '../dil/ceviri';

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
  osgb:            { ikon: '👷',  aciklama: 'İşyeri hekimliği: firma · çalışan · Ek-2 (SMS) · periyodik takvim · ziyaret · iş kazası · İSG-KATİP süre' },
  hastane:         { ikon: '🏨',  aciklama: '+ yatan hasta · ameliyathane · eczane/depo · acil · yoğun bakım · HBYS tam (sonraki faz)' },
  erp:             { ikon: '🏭',  aciklama: 'Üretim · ticaret · stok · satış/alış · muhasebe (HBYS modülleri kapalı)' },
};

/** Entegrasyon gerekliligi (491): 2 zorunlu · 1 onerilen · 0 opsiyonel. */
const GEREKLILIK: Record<number, string> = {
  2: 'zorunlu', 1: 'önerilen', 0: 'opsiyonel',
};

/**
 * KURUM PROFILI & SISTEM AYARLARI - Yönetim › Kurum Profili (489'da Firma
 * Bilgileri'nin sekmesinden kendi ekranina tasindi).
 *
 * Ekranin duzeni Ekranlar/Ayarlar/kurum_tipi_ayarlari.html mockup'indan BIREBIR
 * alindi; mockup'in CSS'i `.kt-kok` altina kapsullendi (kurum tipi kartlari,
 * modul matrisi ve rozetler uygulamanin genel temasindan bagimsiz durur).
 *
 * KAYDEDER: "Modüller" sekmesindeki aç/kapa kutucukları `profil.moduller`'i
 * günceller, "Kaydet & Uygula" ise `api.kurumProfilYaz` (PUT /kurum-profil)
 * ile kurum_profil.moduller'e YAZAR ve aktif şubenin menüsünü hemen tazeler
 * (359/364). Yani profil başına menü buradan ayarlanır - koda gömmeye gerek yok.
 */
// ROLLER KENDI SEKMESINDE (789, kullanici: "modüllerin sağına Roller diye
//   sekme aç ve rolleri oraya taşı"): profil sekmesi tip kartlari + modul
//   ozeti + iki rol tablosuyla uzayip gidiyordu; rol isi ayri bir adimdir.
// MODÜLLER -> MENÜ DÜZENİ (kullanıcı 06.10.2026): modül aç/kapa ve kurum tipi
//   matrisi kaldırıldı; modül paketi TİPTEN gelir, kurumun ayarladığı şey
//   menünün YERLEŞİMİ. Ekran (979) sekmeye gömülü.
// DATA KULLANIMI (kullanıcı): hizmet / stok kategorileri modül sekmesinde
//   duruyordu; orası artık menü. "Kurum hangi veriyi kullanıyor" sorusu
//   Roller'in arkasında kendi sekmesinde.
// SEKME: ÜSTTE İKON, ALTTA ETİKET (kullanıcı 06.10.2026) - sıra numarası
//   kaldırıldı: sekme eklenip çıkarıldığında numaralar kayıyordu ve kullanıcı
//   ekranı adıyla arıyor, "4" ile değil.
const SEKMELER: { ad: string; ic: string }[] = [
  { ad: 'Profil',               ic: '🏥' },
  { ad: 'Menü Düzeni',          ic: '🌳' },
  { ad: 'Roller',               ic: '👥' },
  { ad: 'Data Kullanımı',       ic: '🗄' },
  { ad: 'Kayıt & Ücretlendirme', ic: '🧾' },
  { ad: 'Klinik Ayarlar',       ic: '🩺' },
  { ad: 'Entegrasyonlar',       ic: '🔌' },
  { ad: 'Kaynaklar',            ic: '🪑' },
  { ad: 'Özet & Kurulum',       ic: '✅' },
];

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

  /**
   * Kurum tipi degisince modul OVERRIDE'lari silinir: yeni tipin varsayilan
   * paketi gecerli olsun - eski tipten kalan "lab kapali" gibi bir isaret
   * kullaniciyi sasirtirdi.
   */
  const tipSec = (kod: string) => degistir({ kurumTipi: kod, moduller: {} });

  /**
   * ROLLER TEK TABLODA (kullanici: *"2 rol griditini teke düşür.. böyle
   * karışıklık oluyor.. roller seçilip kaydet dendiğinde o profil için roller
   * listesine gelir"*).
   *
   * Eskiden iki tablo vardi: ustte "kurulacak sablonlar" (ayri bir
   * "Seçilenleri kur" dugmesiyle), altta "bu profilde gecerli roller" (ust
   * seritteki Kaydet ile). Ayni rol iki listede iki farkli kutucukla
   * gorunuyordu ve hangisinin ne yaptigi belirsizdi.
   *
   * Artik TEK tablo: kurulu roller + bu tipin HENUZ KURULMAMIS sablonlari.
   * Kutucuk tek bir soruyu sorar - "bu profilde gecerli mi". Kaydet, isaretli
   * olup kurulmamis olanlari once KURAR, sonra gecerlilik haritasini yazar.
   */
  const [rolSuzgec, setRolSuzgec] = useState<'tumu' | 'gecerli' | 'sablon'>('tumu');
  /**
   * TIPE UYMAYANLAR DA GORUNSUN (kullanici: "buradaki tüm roller olsun").
   * Varsayilan KAPALI: 785'teki "lab merkezinde dis hekimi gorunmesin"
   * kurali duruyor - artik kapatilabiliyor, kaldirilmis degil.
   */
  const [tumTipler, setTumTipler] = useState(false);
  /** Bu tipin kurulmamis sablon rolleri - agaca "kurulacak" olarak girer. */
  const [kurulacakRol, setKurulacakRol] = useState<
    { kod: string; ad: string; amac: string; ekran: number; aksiyon: number;
      bolum: string; ust?: string | null; sira: number; tipUygun: boolean }[]>([]);
  /** Bolum sirasi sunucudan (`KadroBolumleri`). */
  const [rolBolumleri, setRolBolumleri] = useState<string[]>([]);
  const [rolMesgul, setRolMesgul] = useState(false);

  /**
   * PROFILDE GECERLI ROLLER (786, kullanici: "profil sayfasinda altta her bir
   * profil icin gecerli (aktif) rolleri isaretleyeyim.. ustte kaydet deyip o
   * profilin rollerine girince onlar gecerli olsun").
   *
   * Liste KURULU TUM ROLLERDIR - kapatilacaklari gormeden isaretleme yapilamaz.
   * Sablonun karari `varsayilan` sutununda ipucu olarak durur; kutucuk kurumun
   * kararidir ve ust seritteki Kaydet ile yazilir.
   */
  const [profilRol, setProfilRol] = useState<ProfilRolu[]>([]);
  const [rolGecerli, setRolGecerli] = useState<Set<string>>(new Set());
  const [rolYazili, setRolYazili] = useState(false);
  const tip = profil?.kurumTipi ?? '';

  /** Kurulu roller + bu tipin kurulmamis sablonlari - TEK tablonun kaynagi. */
  const rolleriTazele = async (secimiKoru = false) => {
    if (!tip) { setProfilRol([]); setKurulacakRol([]); setRolGecerli(new Set()); return }
    const y = await api.profilRolleri(tip);
    setProfilRol(y.roller);
    setRolYazili(y.yazili);
    setRolBolumleri(y.bolumler ?? []);
    const t = await api.standartRoller(tip, true);
    const eksik = t.roller.filter(r => !r.mevcut);
    setKurulacakRol(eksik.map(r => ({
      kod: r.kod, ad: r.ad, amac: r.amac, ekran: r.ekran, aksiyon: r.aksiyon,
      bolum: r.bolum, ust: r.ust, sira: r.sira, tipUygun: r.tipUygun })));
    if (!secimiKoru)
      setRolGecerli(new Set(y.roller.filter(r => r.gecerli || r.kilitli).map(r => r.kod)));
  };

  useEffect(() => {
    let iptal = false;
    void (async () => {
      try { if (!iptal) await rolleriTazele() }
      catch { /* yetkisi yoksa bolum bos kalir */ }
    })();
    return () => { iptal = true };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tip]);

  const rolCevir = (kod: string, kilitli = false, portal = false) => {
    if (kilitli) return;                      // yonetici/atanmamis kapanamaz
    const acik = !rolGecerli.has(kod);
    setRolGecerli(o => {
      const n = new Set(o);
      if (n.has(kod)) n.delete(kod); else n.add(kod);
      return n;
    });
    // PORTAL SATIRI KAYDET'İ BEKLEMEZ: kutusu geçerlilik haritasına değil
    //   doğrudan `rol.aktif`e yazar (829: harita portal rolünü kapatmıyor,
    //   dolayısıyla Kaydet'e bırakmak kutuyu hiçbir şey yapmayan bir süse
    //   çevirirdi). Hata olursa kutu geri alınır.
    if (!portal) return;
    void (async () => {
      try {
        const y = await api.portalRolAktif({ kod, aktif: acik });
        setProfilRol(o => o.map(r => (r.kod === kod ? { ...r, aktif: y.aktif } : r)));
        if (!acik && y.kisi > 0)
          mesaj(c('Bu rolde {n} kullanıcı var; artık giriş yapamazlar.')
                 .replace('{n}', String(y.kisi)));
      } catch (h) {
        setRolGecerli(o => {
          const n = new Set(o);
          if (acik) n.delete(kod); else n.add(kod);
          return n;
        });
        mesaj(hataMetni(h));
      }
    })();
  };

  /**
   * YETKILERI SABLONA HIZALA: ayri ve ACIK bir islem - Kaydet'e binmez.
   * Elle verilmis yetkileri siler, bu yuzden onay ister.
   */
  /**
   * TABLONUN KAYNAGI: kurulu roller + kurulmamis sablonlar TEK liste.
   * Kurulmamis satir `kurulu: false` tasir; oteki alanlari sablonun
   * onerisiyle doldurulur (sablon: true, varsayilan: true) - o satir zaten
   * "bu tipe onerilir" demektir.
   */
  const tumRol = [
    ...profilRol.map(r => ({ ...r, kurulu: true, tipUygun: true })),
    ...kurulacakRol.map(r => ({
      id: 0, kod: r.kod, ad: r.ad, amac: r.amac,
      aktif: false, sistem: false, kisi: 0,
      sablon: true, modul: null as string | null, modulKapali: false,
      varsayilan: r.tipUygun, gecerli: false, yazili: false, kilitli: false, portal: false,
      bolum: r.bolum, ust: r.ust, sira: r.sira,
      kurulu: false, tipUygun: r.tipUygun,
    })),
  ].filter(r => tumTipler || r.kurulu || r.tipUygun);
  const kurulacakSecili = kurulacakRol.filter(r => rolGecerli.has(r.kod)).length;

  /**
   * AGAC: bolum -> kok roller -> altlar. Hiyerarsi SUNUCUDAN (`SablonKadro`);
   * haritada yeri olmayan rol "Diger" bolumune, kok olarak duser - gizlenmez.
   *
   * Suzgece uymayan bir dugum, ALTI uyuyorsa yine cizilir: ustu gorunmeyen
   * bir alt rol nerede calistigini soylemez.
   */
  type RolDugum = (typeof tumRol)[number] & { alt: RolDugum[] };
  const rolSuzgecinden = (r: (typeof tumRol)[number]) =>
    rolSuzgec === 'tumu' ? true
      : rolSuzgec === 'gecerli' ? rolGecerli.has(r.kod)
      : r.varsayilan;

  const rolAgaci = (() => {
    const kok = new Map<string, RolDugum[]>();
    const dugumler = new Map<string, RolDugum>();
    for (const r of tumRol) dugumler.set(r.kod, { ...r, alt: [] });
    for (const d of dugumler.values()) {
      const ust = d.ust ? dugumler.get(d.ust) : undefined;
      if (ust) { ust.alt.push(d); continue }
      const bolum = d.bolum || 'Diğer';
      kok.set(bolum, [...(kok.get(bolum) ?? []), d]);
    }
    const sirala = (l: RolDugum[]): RolDugum[] =>
      [...l].sort((x, y) => (x.sira ?? 9000) - (y.sira ?? 9000)
                            || x.ad.localeCompare(y.ad, 'tr'))
        .map(d => ({ ...d, alt: sirala(d.alt) }));
    // Suzgec: kendisi VEYA bir alti geciyorsa kalir.
    const suz = (l: RolDugum[]): RolDugum[] => l
      .map(d => ({ ...d, alt: suz(d.alt) }))
      .filter(d => rolSuzgecinden(d) || d.alt.length > 0);

    const sirali = [...(rolBolumleri.length ? rolBolumleri : [...kok.keys()]), 'Diğer'];
    const sonuc: { bolum: string; ogeler: RolDugum[] }[] = [];
    for (const bolum of sirali) {
      if (sonuc.some(x => x.bolum === bolum)) continue;
      const ogeler = suz(sirala(kok.get(bolum) ?? []));
      if (ogeler.length) sonuc.push({ bolum, ogeler });
    }
    // Sunucunun bolum listesinde olmayan bolumler (yeni eklenmis) sona.
    for (const [bolum, l] of kok)
      if (!sonuc.some(x => x.bolum === bolum)) {
        const ogeler = suz(sirala(l));
        if (ogeler.length) sonuc.push({ bolum, ogeler });
      }
    return sonuc;
  })();

  /** Bolumdeki TOPLAM rol (alt dallar dahil). */
  const rolSay = (l: RolDugum[]): number =>
    l.reduce((n, d) => n + 1 + rolSay(d.alt), 0);

  /** Tek dugum: kutucuk + rozetler + altlar. */
  const rolDugumu = (d: RolDugum): React.ReactNode => (
    <li key={d.kod}>
      <label className={`kt-rol${rolGecerli.has(d.kod) ? ' on' : ''}`
                        + `${d.kurulu ? '' : ' yeni'}${d.tipUygun ? '' : ' disi'}`}>
        <input type="checkbox" checked={rolGecerli.has(d.kod)} disabled={d.kilitli}
               onChange={() => rolCevir(d.kod, d.kilitli, d.portal)}
               title={d.kilitli ? c('Bu rol pasife alınamaz')
                      : d.portal ? c('Portal rolü: kutu doğrudan aktif/pasif yazar, Kaydet beklemez')
                      : c('Bu kurum profilinde geçerli mi')} />
        <span className="ad">{d.ad}</span>
        <span className="kod">{d.kod}</span>
        {d.amac && <span className="amac" title={d.amac}>{d.amac}</span>}
        {d.kisi > 0 && <span className="rz kisi">{d.kisi} kişi</span>}
        {d.kilitli && <span className="rz">kilitli</span>}
        {!d.kurulu && <span className="rz yeni">kurulacak</span>}
        {!d.tipUygun && !d.portal
          && <span className="rz" title={c('Bu kurum tipinde önerilmez')}>başka tip</span>}
        {d.portal && <span className="rz mor" title={c('Dışarıya açılan kapı: kurum tipiyle '
          + 'kapanmaz, bu kutudan açılıp kapanır')}>portal</span>}
        {d.kurulu && (d.aktif
          ? <span className="rz ok">aktif</span>
          : <span className="rz pas">pasif</span>)}
        {d.sablon && d.varsayilan && <span className="rz" title={c('Bu tipe önerilir')}>✔ şablon</span>}
        {d.modulKapali && <span className="rz" title={`Modül kapalı: ${d.modul}`}>⊘ modül</span>}
      </label>
      {d.alt.length > 0 && <ul className="kt-dal">{d.alt.map(rolDugumu)}</ul>}
    </li>
  );

  const sablonaHizala = async () => {
    const kodlar = profilRol.filter(r => r.sablon).map(r => r.kod);
    if (!kodlar.length) { void mesaj('Bu tipte kurulu şablon rolü yok.'); return }
    if (!await onay(`${kodlar.length} rolün yetkileri şablona çekilsin mi?\n\n`
      + 'Bu rollere ELLE verilmiş yetkiler silinir; kullanıcılar ve rol adları korunur.')) return;
    setRolMesgul(true);
    try {
      const y = await api.standartRolleriKur({
        kurumTipi: profil?.kurumTipi || undefined, kodlar, guncelle: true });
      void mesaj(`Güncellendi: ${y.guncellendi.join(', ') || '—'}`
                 + `${y.kuruldu.length ? ` · Kuruldu: ${y.kuruldu.join(', ')}` : ''}`);
      await rolleriTazele(true);
    } catch (h) { void mesaj(hataMetni(h)) } finally { setRolMesgul(false) }
  };

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
      // ISARETLI AMA KURULMAMIS SABLON ROLLER ONCE KURULUR (kullanici:
      //   "roller seçilip kaydet dendiğinde o profil için roller listesine
      //   gelir"). Ayri bir "Seçilenleri kur" dugmesi yok: tablodaki kutucuk
      //   tek bir soruyu soruyor, Kaydet onu gerceklestiriyor.
      let adaylar = profilRol.map(r => r.kod);
      const kurulacak = kurulacakRol.filter(r => rolGecerli.has(r.kod)).map(r => r.kod);
      if (kurulacak.length > 0) {
        const k = await api.standartRolleriKur({
          kurumTipi: profil.kurumTipi || undefined, kodlar: kurulacak, guncelle: false });
        // Kurulan roller artik "aday" listesindedir: sunucu "isaretsiz = pasif"
        //   kararini ancak neyin gosterildigini bilirse verebilir.
        adaylar = [...new Set([...adaylar, ...k.kuruldu, ...k.atlandi])];
      }

      // ROL HARITASI AYNI KAYDETTE (786): isaretliler gecerli, isaretsizler
      //   pasif.
      const y = await api.kurumProfilYaz({
        ...profil, subeId,
        ...(adaylar.length > 0
            ? { roller: [...rolGecerli].filter(k => adaylar.includes(k)), rolAdaylari: adaylar }
            : {}),
      });
      if (kurulacak.length > 0) await rolleriTazele(true);
      setProfil(y.profil);
      setVeri(v => (v ? { ...v, profil: y.profil } : v));
      setHata(null);
      if (profilRol.length > 0) setRolYazili(true);
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
          <label htmlFor="kt-sube">{c('Şube:')}</label>
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

      <div className="sekmeler kt-sekmeler">
        {SEKMELER.map((t, i) => (
          <div key={t.ad} className={`sekme${i === aktif ? ' on' : ''}`}
               title={t.ad} onClick={() => setAktif(i)}>
            <span className="kt-sekme-ic">{t.ic}</span>
            <span className="kt-sekme-ad">{c(t.ad)}</span>
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
            <label className="req">{c('Ürün modu')}</label>
            <select className="inp" value={profil?.urunModu ?? 2}
                    onChange={e => degistir({ urunModu: Number(e.target.value) })}>
              <option value={2}>{c('HBYS (GenoTIP AI)')}</option>
              <option value={1}>{c('ERP (Gentegre AI)')}</option>
              <option value={3}>{c('İkisi (tıp merkezi + ticari)')}</option>
            </select>
          </div>
          <div className="fld">
            <label className="req">{c('Kurum tipi')}</label>
            <select className="inp" value={profil?.kurumTipi ?? ''}
                    onChange={e => tipSec(e.target.value)}>
              {(veri?.tipler ?? []).map(t => (
                <option key={t.kod} value={t.kod}>{t.ad}</option>
              ))}
            </select>
          </div>
          <div className="fld">
            <label>{c('Alt tip / branş')}</label>
            <input className="inp" value={profil?.altTip ?? ''} maxLength={60}
                   placeholder="örn. Dahiliye"
                   onChange={e => degistir({ altTip: e.target.value })} />
          </div>
          <div className="fld">
            <label>Basamak (açıklama)</label>
            <input className="inp" value={profil?.basamak ?? ''} maxLength={60}
                   placeholder="örn. 2. basamak özel"
                   title="Bilgi metni. Akılcı test istemi basamak kısıtı ŞUBE KARTINDAKİ 'Sağlık Tesisi Basamağı' alanından okunur (873)."
                   onChange={e => degistir({ basamak: e.target.value })} />
          </div>
          <div className="fld">
            <label>{c('Tesis kodu (ÇKYS)')}</label>
            <input className="inp" value={profil?.tesisKodu ?? ''} maxLength={20}
                   placeholder="11xxxxxx"
                   onChange={e => degistir({ tesisKodu: e.target.value })} />
          </div>
          <div className="fld">
            <label>{c('Şube yapısı')}</label>
            <select className="inp" value={profil?.subeYapisi ?? 1}
                    onChange={e => degistir({ subeYapisi: Number(e.target.value) })}>
              <option value={1}>{c('Tek şube')}</option>
              <option value={2}>{c('Çok şube (her şube kendi tesis kodu)')}</option>
            </select>
          </div>
          <div className="fld">
            <label>{c('Hekim sayısı / ünite')}</label>
            <div className="ikili-sayi">
              <input className="inp" type="number" min={0} value={profil?.hekimSayisi ?? 1}
                     onChange={e => degistir({ hekimSayisi: Number(e.target.value) })} />
              <input className="inp" type="number" min={0} value={profil?.uniteSayisi ?? 1}
                     onChange={e => degistir({ uniteSayisi: Number(e.target.value) })} />
            </div>
          </div>
          <div className="fld">
            <label>{c('Dil / para birimi')}</label>
            <div className="ikili-sayi">
              <select className="inp" value={profil?.dil ?? 'tr'}
                      onChange={e => degistir({ dil: e.target.value })}>
                <option value="tr">{c('Türkçe')}</option>
                <option value="en">{c('English')}</option>
                <option value="de">{c('Deutsch')}</option>
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
            <label>{c('Kimlik no biçimi')}</label>
            <select className="inp" value={profil?.kimlikBicimi ?? 'otomatik'}
                    onChange={e => degistir({ kimlikBicimi: e.target.value })}>
              <option value="otomatik">{c('Doğrulama yok (varsayılan)')}</option>
              <option value="tc">{c('T.C. Kimlik No (11 hane + kontrol hanesi)')}</option>
              <option value="serbest">{c('Serbest — biçim kontrolü yok')}</option>
              <option value="desen">{c('Özel desen (düzenli ifade)')}</option>
            </select>
          </div>
          {profil?.kimlikBicimi === 'desen' && (
            <div className="fld">
              <label>{c('Desen / açıklama')}</label>
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
            <b>{c('Açık:')}</b>{' '}
            {(veri?.moduller ?? []).filter(m => tipVarsayilani(m.kod) === 1)
              .map(m => m.ad).join(' · ') || '—'}
            <br />
            <b>{c('Opsiyonel:')}</b>{' '}
            {(veri?.moduller ?? []).filter(m => tipVarsayilani(m.kod) === 2)
              .map(m => m.ad).join(' · ') || '—'}
            <br />
            <b>{c('Kapalı:')}</b>{' '}
            {(veri?.moduller ?? []).filter(m => tipVarsayilani(m.kod) === 0)
              .map(m => m.ad).join(' · ') || '—'}
          </div>
        </div>
      </div>

      <div className="pnl" hidden={aktif !== 1}>
        {/* MENÜ DÜZENİ (979) BURAYA GÖMÜLÜ (kullanıcı 06.10.2026: "modüller
            sekmesini rename 'Menü Düzeni', kurum tipi ve modülleri gridini
            kaldır, menü düzeni ekranını taşı").

            Kurum tipi × modül matrisi KALDIRILDI: modül paketi tipten gelir ve
            Profil sekmesinde tip seçilirken zaten görünüyor; kurumun burada
            ayarladığı şey artık menünün YERLEŞİMİDİR.

            Bileşen AYNI (`/menu-duzeni` rotası da onu açar) - iki kopya bakım
            edilmiyor. */}
        <MenuDuzeni gomulu />
      </div>

      {/* 4 · DATA KULLANIMI: kurumun hangi veriyi kullandığı. Kategoriler
          Modüller sekmesinden taşındı (kullanıcı 06.10.2026). */}
      <div className="pnl" hidden={aktif !== 3}>
        <div className="ic sonuk">
          Kurumun hangi işleri yaptığı ve hangi veriyi kullandığı. Kapatılan
          kategorinin <b>altındaki hizmet ve stoklar da pasif</b> olur.
        </div>
        {/* HIZMET / STOK KATEGORILERI (527, kullanici: "profile gore kimler
            neyi kullanacak - gorüntuleme merkezi sadece radyoloji kullanir,
            laboratuvar sadece tahlil islemleri gibi").
            Kategori kapaninca ALTINDAKI HIZMET/STOKLAR da pasif olur
            (kullanici: "ikisi de pasif olsun veya aktif") - yayilimi DB
            tetigi yapar. Elle kapatilan kayit geri acilmaz. */}
        <div className="grp">
          <div className="hdr k4">{c('Hizmet / Stok Kategorileri')}</div>
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
        {/* KADRO AĞACI (kullanıcı: "rol seçim gridini de bu ağaç şekline
            çevir ve buradaki tüm roller olsun"). Mockup:
            Ekranlar/Ayarlar/rol_agaci.html. Tablo satırları hangi rolün
            kimin altında olduğunu göstermiyordu; kadro düzeni ancak ağaçta
            okunuyor. Kutucuk ve Kaydet davranışı DEĞİŞMEDİ. */}
        <div className="grp" style={{ margin: '10px' }}>
          <div className="gb">Kadro ağacı — {tipAdi(profil?.kurumTipi) || '—'}
            <span style={{ marginLeft: 'auto', display: 'inline-flex', gap: 6, alignItems: 'center' }}>
              <span className="sonuk" style={{ fontSize: 11 }}>
                {rolGecerli.size}/{tumRol.length} seçili
                {kurulacakSecili > 0 ? ` · ${kurulacakSecili} kurulacak` : ''}
              </span>
              {([['tumu', 'Tümü'], ['gecerli', 'Geçerli'], ['sablon', 'Şablon önerisi']] as const)
                .map(([k, ad]) => (
                  <button key={k} type="button"
                          className={`d${rolSuzgec === k ? ' bir' : ''}`}
                          onClick={() => setRolSuzgec(k)}>{ad}</button>
                ))}
              {/* TİPE UYMAYANLAR: 785'teki süzgeç duruyor, kapatılabiliyor. */}
              <button type="button" className={`d${tumTipler ? ' bir' : ''}`}
                      title={c('Bu kurum tipinde önerilmeyen rolleri de göster')}
                      onClick={() => setTumTipler(v => !v)}>
                {tumTipler ? '✔ ' : ''}Diğer tiplerin rolleri
              </button>
              <button className="d" type="button"
                      onClick={() => setRolGecerli(new Set(tumRol
                        .filter(r => r.varsayilan || r.kilitli).map(r => r.kod)))}>
                ↺ Şablon önerisi
              </button>
              <button className="d" type="button" disabled={rolMesgul}
                      title="Kurulu şablon rollerinin yetkilerini şablonun haline geri çeker"
                      onClick={() => void sablonaHizala()}>🧩 Yetkileri şablona hizala</button>
              <button className="d" type="button" onClick={() => git('/rol')}>{c('Roller ekranı')}</button>
            </span>
          </div>
          <div className="ic sonuk">
            İşaretli roller bu profilde <b>geçerlidir</b>; işaretsizler <b>pasife</b> alınır
            (silinmez, kullanıcıları kalır). <b>{c('Kurulacak')}</b> yazan satır henüz kurulmamış
            şablon rolüdür: işaretleyip <b>Kaydet</b> derseniz kurulur ve bu profilin roller
            listesine girer. Ağaç kadro düzenini gösterir — <b>yetki hiyerarşik değildir</b>,
            üstteki rolün yetkisi alttakini kapsamaz.
            {rolYazili ? '' : ' Henüz işaretlenmedi: şu an şablonun önerisi geçerli.'}
          </div>
          {tumRol.length === 0
            ? <div className="ic sonuk">{c('Kurum tipi seçilince roller listelenir.')}</div>
            : (
              <div className="ic kt-agac">
                {rolAgaci.map(b => (
                  <div key={b.bolum} className="kt-bolum">
                    <div className="kt-bolum-ad">{b.bolum}
                      {/* ALT DALLAR DA SAYILIR: "1 rol" yazan bir bölümün
                          altında on satır durması sayacı yalancı yapardı. */}
                      <span className="sonuk">· {rolSay(b.ogeler)} rol</span>
                    </div>
                    <ul className="kt-dal kt-kok">{b.ogeler.map(o => rolDugumu(o))}</ul>
                  </div>
                ))}
                {rolAgaci.length === 0 && (
                  <div className="sonuk">{c('Süzgece uyan rol yok.')}</div>
                )}
              </div>
            )}
        </div>
      </div>
      <div className="pnl" hidden={aktif !== 4}>
          <div className="hdr k4">
            <div className="fld"><label>{c('Başvuru modeli')}</label><div className="inp combo">{c('Tek başvuru = tek muayene')}<span className="sonuk">· tıp merkezi: başvuru altında çoklu hizmet · hastane: yatış</span></div></div>
            <div className="fld"><label>{c('Ödeyen kurumlar')}</label><div className="inp">☑ Özel (kendi) · ☑ SGK · ☑ Özel sigorta (ÖSS) · ☐ Kurum sözleşmeleri · ☐ Yabancı/sağlık turizmi</div></div>
            <div className="fld"><label>{c('SGK faturalama')}</label><div className="inp combo">{c('Dönem icmali (289)')}<span className="sonuk">· vaka bazlı</span></div></div>
            <div className="fld"><label>{c('Provizyon')}</label><div className="inp combo">{c('Medula otomatik')}<span className="sonuk">· elle · yok</span></div></div>
            <div className="fld"><label>Fiyat listesi</label><div className="inp combo">Özel 2026 (varsayılan) · SUT (SGK) · kurum sözleşmesi</div></div>
            <div className="fld"><label>{c('Ücretlendirme anı')}</label><div className="inp combo">Muayene açılınca (muayene ücreti) + işlem anında <span className="sonuk">· diş: seans; lab/rad: istem</span></div></div>
            <div className="fld"><label>{c('Ön ödeme')}</label><div className="inp combo">{c('İsteğe bağlı')}<span className="sonuk">· zorunlu (teletıp/özel)</span></div></div>
            <div className="fld"><label>{c('Belge üretimi')}</label><div className="inp combo">{c('Tahsil edilen kadar fiş, kalanı tahakkuk (352)')}<span className="sonuk">· her işlem fatura · dönem faturası</span></div></div>
            <div className="fld"><label>e-Belge</label><div className="inp combo">e-Arşiv (hasta) · e-Fatura (kurum) · entegratör: İzibiz</div></div>
            <div className="fld"><label>{c('Numara şablonları')}</label><div className="inp">Protokol: {'{'}yıl{'}'}/{'{'}sıra{'}'} · Hasta no: H{'{'}sıra:6{'}'} · Plan: TP-{'{'}yıl{'}'}/{'{'}sıra{'}'}</div></div>
            <div className="fld"><label>{c('Hasta kimlik doğrulama')}</label><div className="inp combo">KPS (opsiyonel) · kimlik no zorunlu · yabancı: pasaport</div></div>
            <div className="fld"><label>KVKK</label><div className="inp">☑ Hasta kayıtları özel nitelikli · ☑ erişim günlüğü · saklama: 10 yıl (sağlık) · 15 yıl (personel sağlık)</div></div>
          </div>
        </div>

      <div className="pnl" hidden={aktif !== 5}>
          <div className="ikiPanel">
            <div className="hdr" style={{gridTemplateColumns: '1fr 1fr'}}>
              <div className="fld"><label>{c('Muayene şablonu')}</label><div className="inp combo">{c('Dahiliye genel')}<span className="sonuk">· dal: göz OD/OS, FTR skala, diş odontogram</span></div></div>
              <div className="fld"><label>{c('Tamamlama kuralı')}</label><div className="inp">☑ Ana tanı · ☑ Şikâyet · ☐ Vital · ☑ Karar</div></div>
              <div className="fld"><label>Randevu</label><div className="inp">Slot 20 dk · hekim takvimi · ☐ ünit · ☐ cihaz · ☐ online</div></div>
              <div className="fld"><label>{c('Sıra / çağırma')}</label><div className="inp combo">{c('Kapalı')}<span className="sonuk">· sıra ekranı / anons</span></div></div>
              <div className="fld"><label>{c('Onam türleri')}</label><div className="inp">{c('Genel tedavi · KVKK · (dal: işlem onamları)')}</div></div>
              <div className="fld"><label>{c('Reçete')}</label><div className="inp">{c('Medula e-reçete · alerji/etkileşim kontrolü ☑')}</div></div>
              <div className="fld"><label>{c('Rapor türleri')}</label><div className="inp">İstirahat · ilaç · durum bildirir · ☐ sağlık kurulu</div></div>
              <div className="fld"><label>{c('Kronik takip')}</label><div className="inp">☑ DM · ☑ HT · ☐ glokom · ☐ DR · ☐ periodontal</div></div>
            </div>
            <div className="grp" style={{margin: '10px'}}><div className="gb">{c('Tip bazlı klinik varsayılanlar')}</div>
              <div className="dg"><table><thead><tr><th>Tip</th><th>Muayene</th><th>Kaynak</th><th>{c('Özel kural')}</th></tr></thead>
                <tbody>
                  <tr><td>{c('Muayenehane')}</td><td>branş şablonu</td><td>hekim takvimi</td><td>tek başvuru = tek muayene</td></tr>
                  <tr><td>Göz</td><td>{c('OD/OS ölçüm tabloları')}</td><td>ünite akışı: ön tetkik → hekim → görüntüleme</td><td>{c('GİB panik, dilatasyon zamanlayıcı, IOL/UTS')}</td></tr>
                  <tr><td>FTR</td><td>skala/ölçek (VAS, ROM, Barthel)</td><td>uygulama ünitleri + fizyoterapist</td><td>kür (seans paketi), SUT seans limiti, hekim onaylı program</td></tr>
                  <tr><td>{c('Görüntüleme')}</td><td>—</td><td>cihaz + tekniker + radyolog</td><td>SLA, kritik bulgu, teleradyoloji, çekim süresi maliyeti</td></tr>
                  <tr><td>Laboratuvar</td><td>—</td><td>cihaz + bölüm</td><td>panik, oto-onay, KK, Akılcı Lab formları</td></tr>
                  <tr><td>Diş</td><td>odontogram + periodontal</td><td>ünit + hekim</td><td>tedavi planı/proforma, seans ücretlendirme, lab iş emri</td></tr>
                  <tr><td>{c('Tıp merkezi')}</td><td>branş şablonları</td><td>poliklinik + lab + rad</td><td>çoklu hizmet başvurusu, kurum sözleşmeleri, teletıp</td></tr>
                  <tr><td>{c('Hastane')}</td><td>+ yatan hasta, ameliyat</td><td>servis/yatak/ameliyathane</td><td>yatış/çıkış (106), eczane, acil, yoğun bakım</td></tr>
                </tbody></table></div></div>
          </div>
        </div>

      <div className="pnl" hidden={aktif !== 6}>
          {/* ENTEGRASYONLAR CANLI (491, kullanici): mockup'ta 12 sabit satir
              vardi ve "bağlı / test / gizli" rozetleri gercek hesaplara
              bakmiyordu. Gereklilik urun modu + acik modullerden, durum
              entegrasyon_hesap'tan - ikisi de sunucuda
              (fn_kurum_entegrasyon_durumu). Ilgisiz entegrasyon (ERP'de SKRS,
              stok kapaliyken ÜTS) hic listelenmez. */}
          <div className="dg"><table><thead><tr>
              <th>{c('Entegrasyon')}</th><th>{c('Bu kurulumda')}</th><th>Hesap</th>
              <th className="orta">Durum</th><th>{c('Son sonuç')}</th><th>{c('Aksiyon')}</th></tr></thead>
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
            Hesaplar <b>{c('Yönetim › Modül Ayarları › Genel')}</b> ekranındaki{' '}
            <code>entegrasyon_hesap</code> kayıtlarıdır; şube hesabı varsa o,
            yoksa kurum geneli okunur. Zorunlu olup hesabı olmayanlar{' '}
            <b>{c('Özet &amp; Kurulum')}</b> listesinde de bekleyen adım olarak görünür.
            PACS/DICOM, lab cihaz ara katmanı, sanal POS, e-İmza, KPS ve WebRTC
            için hesap tanımı henüz yok — bağlandıklarında bu listeye eklenecek.
          </div>
        </div>

      <div className="pnl" hidden={aktif !== 7}>
          <div className="ikiPanel">
            <div className="grp" style={{margin: '10px'}}><div className="gb">{c('Birimler / kaynaklar')}<span className="sp">tipe göre: oda · ünit · cihaz · servis/yatak</span></div>
              <div className="dg"><table><thead><tr><th>Kaynak</th><th>Tür</th><th>{c('Bağlı')}</th><th className="orta">Randevu</th><th className="orta">Aktif</th></tr></thead>
                <tbody>
                  <tr><td>{c('Muayene Odası 1')}</td><td>oda</td><td>Dr. A. Koç · Dahiliye</td><td className="orta">✔</td><td className="orta">✔</td></tr>
                  <tr className="sonuk"><td>{c('Ünit 1–4')}</td><td>ünit</td><td>diş kliniğinde</td><td className="orta">—</td><td className="orta">gizli</td></tr>
                  <tr className="sonuk"><td>MR-1, BT-1 …</td><td>cihaz</td><td>görüntüleme merkezinde</td><td className="orta">—</td><td className="orta">gizli</td></tr>
                  <tr className="sonuk"><td>{c('Servis A · 12 yatak')}</td><td>servis/yatak</td><td>hastanede</td><td className="orta">—</td><td className="orta">gizli</td></tr>
                </tbody></table></div>
              <div style={{padding: '6px 10px'}}><div className="btn">＋ Kaynak</div></div></div>
            <div className="hdr" style={{gridTemplateColumns: '1fr 1fr'}}>
              <div className="fld"><label>{c('Departmanlar / poliklinikler')}</label><div className="inp">Dahiliye (SKRS 1000) <span className="sonuk">· tıp merkezinde çoklu</span></div></div>
              <div className="fld"><label>{c('Hekimler')}</label><div className="inp">Dr. A. Koç · tescil ✔ · ÇKYS ✔</div></div>
              <div className="fld"><label>{c('Personel rolleri')}</label><div className="inp">{c('Hekim · sekreter · (hemşire)')}<span className="sonuk">· tekniker, hijyenist, radyolog, fizyoterapist tipe göre</span></div></div>
              <div className="fld"><label>Depolar</label><div className="inp">{c('Sarf deposu')}<span className="sonuk">· ünit deposu, eczane, hammadde (ERP)</span></div></div>
              <div className="fld"><label>{c('Kasalar / banka')}</label><div className="inp">{c('TL Kasası · POS hesabı · Banka')}</div></div>
              <div className="fld"><label>{c('Çalışma saatleri')}</label><div className="inp">{c('Hafta içi 09:00–18:00 · Cmt 09:00–13:00')}</div></div>
            </div>
          </div>
        </div>

      <div className="pnl" hidden={aktif !== 8}>
          {/* OZET VE KURULUM ADIMLARI CANLI (490, kullanici: "profil yanlış
              geliyor" + "kurulum adımları tablosunu da canlıya bağla"):
              mockup'tan gelen sabit sekiz satir hangi adimin gercekten tamam
              oldugunu soylemiyordu. Karar SUNUCUDA (fn_kurum_kurulum_adimlari):
              her adimin sarti bir sayim/varlik sorgusu, ekran yalniz cizer.
              Urun modu ve kapali modul disi adimlar hic gelmez. */}
          <div className="ozet">
            <div className="kart"><div className="b">{c('Profil')}</div>
              <div className="d">{tipAdi(profil?.kurumTipi) || '—'}</div></div>
            <div className="kart"><div className="b">{c('Açık modül')}</div>
              <div className="d">{acikModulSayisi}{' '}
                <small>· {opsiyonelModulSayisi} opsiyonel</small></div></div>
            <div className="kart"><div className="b">{c('Kurulum adımı')}</div>
              <div className="d">{tamamAdim}/{kurulum.length}{' '}
                <small>· {bekleyenAdim} bekliyor</small></div></div>
          </div>
          <div className="dg"><table><thead><tr>
              <th className="orta">#</th><th>{c('Kurulum adımı')}</th><th>Durum</th>
              <th className="orta">Sonuç</th><th>{c('Aksiyon')}</th></tr></thead>
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
          <div className="ic sonuk">{c('Kaydet →')}<code>kurum_profil</code> + <code>kurum_modul</code> güncellenir; menü (listeTanimlari <code>urunModu/kurumTipi</code> süzmesi), yetki şablonları, kart sekmeleri (KartKatalogu <code>kurumTipi</code>), varsayılan ayarlar (ayar tablosu) tek işlemle uygulanır; değişiklik <code>islem_log</code>'a.</div>
        </div>
    </div>
  );
}
