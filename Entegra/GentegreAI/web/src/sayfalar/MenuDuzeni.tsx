import { useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { c } from '../dil/ceviri';
import { LISTELER } from './Liste';
import { menuSatirlariKur, type MenuSatiri } from './kabuk/menuAgaci';
import { BOLGE_HBYS } from './kabuk/menuBolgeleri';
import { grupKodu, ogeKodu, type MenuDuzenSatiri } from './kabuk/menuDuzeni';

/**
 * MENÜ DÜZENİ (979, mockup `Ekranlar/Ayarlar/menu_duzenleme_v2.html`).
 *
 * Menü ağacı KODDAN kurulur; bu ekran kurumun <b>farkını</b> düzenler ve
 * sunucuda `menu_duzen` olarak saklar. Satırı olmayan düğüm varsayılan yerinde
 * çıkar - yeni bir modül eklendiğinde şube düzeni onu gizlemez.
 *
 * <b>Gizlemek yetki değildir:</b> menüden kaldırılan ekran, yetkisi olan
 * kullanıcıya adresten yine açılır. Ekranda bu uyarı yazılı durur.
 */
type Dugum = {
  tur: 'bolge' | 'grup' | 'ekran';
  kod: string;
  /** Koddaki ad (çevrilmemiş olabilir) - "sistem adı" olarak gösterilir. */
  sistemAd: string;
  ad: string;
  ikon?: string;
  ustKod?: string;
  derinlik: number;
  /** Ekran düğümünde rota - "nereye gider" sütunu. */
  yol?: string;
};

/**
 * `gomulu`: Kurum Profili'nin "Menü Düzeni" sekmesinde çizilirken ekranın
 * kendi başlığı ve yol çizgisi gizlenir - kart zaten "Kurum Profili › Menü
 * Düzeni" diyor, ikinci başlık ekranı ikiye bölüyordu.
 */
export function MenuDuzeni({ gomulu }: { gomulu?: boolean } = {}) {
  const { kullanici, yetki } = useOturum();
  const duzenleyebilir = yetki('menu.duzen', 'degistir');
  const [subeId, setSubeId] = useState<number>(kullanici?.subeId ?? 0);
  const [duzen, setDuzen] = useState<MenuDuzenSatiri[]>([]);
  const [subeyeOzel, setSubeyeOzel] = useState(0);
  const [secili, setSecili] = useState<string | null>(null);
  const [surukle, setSurukle] = useState<string | null>(null);
  /**
   * AĞAÇ KATLANIR, VARSAYILAN KAPALI (kullanıcı 06.10.2026: "grup kapanır
   * açılır olsun", "gruplar kapalı olsun default"): tam menü ~330 düğüm -
   * hepsi açıkken aranan satır ekrana sığmıyordu.
   */
  const [acik, setAcik] = useState<Record<string, boolean>>({});
  const acikMi = (kod: string) => acik[kod] === true;
  const ac = (kod: string) => setAcik(o => ({ ...o, [kod]: !o[kod] }));
  const [mesaj, setMesaj] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);

  // Varsayılan ağaç: menüyü çizen AYNI kuruluş (menuSatirlariKur) - ekranda
  //   başka bir sıralama göstermek, kaydedilen düzenin menüde farklı çıkması
  //   demekti.
  const satirlar: MenuSatiri[] = useMemo(
    () => menuSatirlariKur(LISTELER, yetki, kullanici?.urunModu, kullanici?.moduller),
    [yetki, kullanici?.urunModu, kullanici?.moduller]);

  const bolgeli = kullanici?.urunModu === 2 && kullanici?.menuBolgeli === 1;

  /** Ağacı düz listeye açar: bölge › grup › ekran (mockup soldaki ağaç). */
  const dugumler: Dugum[] = useMemo(() => {
    const d: Dugum[] = [];
    const gruplar = satirlar.filter(s => s.tur === 'grup') as Extract<MenuSatiri, { tur: 'grup' }>[];
    const duzOgeler = satirlar.filter(s => s.tur === 'duz') as Extract<MenuSatiri, { tur: 'duz' }>[];

    const grupEkle = (sat: Extract<MenuSatiri, { tur: 'grup' }>, ustKod?: string) => {
      const kod = grupKodu(sat);
      d.push({ tur: 'grup', kod, sistemAd: kod, ad: sat.ad, ustKod, derinlik: ustKod ? 2 : 1 });
      for (const m of sat.alt)
        d.push({
          tur: 'ekran', kod: ogeKodu(m), sistemAd: m.adHam ?? m.ad, ad: m.ad,
          ikon: m.ic, ustKod: kod, derinlik: ustKod ? 3 : 2, yol: m.yol,
        });
    };

    if (bolgeli) {
      for (const b of BOLGE_HBYS) {
        d.push({ tur: 'bolge', kod: b.ad, sistemAd: b.ad, ad: c(b.ad), derinlik: 1 });
        for (const g of b.gruplar) {
          const sat = gruplar.find(x => grupKodu(x) === g);
          if (sat) grupEkle(sat, b.ad);
        }
      }
      // Bölgeye yazılmamış grup: Yönetim bölgesinin altına düşer (menuBolgeleri
      //   kuralı) - burada da aynı yere konur ki ekran menüyle aynı şeyi göstersin.
      const yazilanlar = new Set(BOLGE_HBYS.flatMap(b => b.gruplar));
      for (const sat of gruplar)
        if (!yazilanlar.has(grupKodu(sat))) grupEkle(sat, BOLGE_HBYS[BOLGE_HBYS.length - 1].ad);
    } else {
      for (const sat of gruplar) grupEkle(sat);
    }
    for (const s of duzOgeler)
      d.push({
        tur: 'ekran', kod: ogeKodu(s.m), sistemAd: s.m.adHam ?? s.m.ad, ad: s.m.ad,
        ikon: s.m.ic, derinlik: 1, yol: s.m.yol,
      });
    return d;
  }, [satirlar, bolgeli]);

  useEffect(() => {
    let iptal = false;
    setYukleniyor(true);
    api.menuDuzen(subeId || undefined)
      .then(y => { if (!iptal) { setDuzen(y.satirlar); setSubeyeOzel(y.subeyeOzel) } })
      .catch(h => { if (!iptal) setMesaj(hataMetni(h)) })
      .finally(() => { if (!iptal) setYukleniyor(false) });
    return () => { iptal = true };
  }, [subeId]);

  const fark = (kod: string) => duzen.find(x => x.sistemKod === kod);
  /**
   * BASAMAKLI GİZLEME (kullanıcı 06.10.2026): "grup görünmez yapılırsa
   * altındakiler de görünmez olur, görünür yapılırsa altındakiler görünür".
   *
   * Alt düğümün KENDİ kaydı yazılmaz - üstünü takip eder. Böylece grubu geri
   * açınca altındakiler kendiliğinden döner; alt satırlara tek tek "gizli"
   * yazılsaydı grup açıldığında hepsi gizli kalırdı.
   */
  const ustGizli = (dugum: Dugum): boolean => {
    let kod = dugum.ustKod;
    const gorulen = new Set<string>();
    while (kod && !gorulen.has(kod)) {
      gorulen.add(kod);
      if (fark(kod)?.gizli === 1) return true;
      kod = dugumler.find(x => x.kod === kod)?.ustKod;
    }
    return false;
  };
  /** Ekranda gizli görünür mü: kendi işareti ya da üstünden miras. */
  const gizliMi = (dugum: Dugum) => fark(dugum.kod)?.gizli === 1 || ustGizli(dugum);
  const seciliDugum = dugumler.find(x => x.kod === secili) ?? null;

  /** Farkı günceller: değer varsayılana döndüyse satır SİLİNİR (fark kalmasın). */
  const farkYaz = (dugum: Dugum, parca: Partial<MenuDuzenSatiri>) => {
    setDuzen(onceki => {
      const mevcut = onceki.find(x => x.sistemKod === dugum.kod);
      const yeni: MenuDuzenSatiri = {
        dugumTur: dugum.tur === 'bolge' ? 1 : dugum.tur === 'grup' ? 2 : 4,
        sistemKod: dugum.kod,
        ustKod: dugum.ustKod ?? null,
        sira: null, gorunenAd: '', ikon: '', gizli: 0, acilistaAcik: 0,
        ...mevcut, ...parca,
      };
      const bos = yeni.gizli === 0 && yeni.acilistaAcik === 0
        && !yeni.gorunenAd && !yeni.ikon && (yeni.sira === null || yeni.sira === undefined);
      const kalan = onceki.filter(x => x.sistemKod !== dugum.kod);
      return bos ? kalan : [...kalan, yeni];
    });
  };

  const kaydet = async () => {
    if (!subeId) { setMesaj(c('Şube seçili değil.')); return }
    try {
      const y = await api.menuDuzenKaydet(subeId, duzen);
      setSubeyeOzel(y.satir);
      setMesaj(c('Kaydedildi') + ` · ${y.satir} ${c('değişiklik')}`);
    } catch (h) { setMesaj(hataMetni(h)) }
  };

  const sifirla = async () => {
    if (!subeId) return;
    try {
      await api.menuDuzenSifirla(subeId);
      setDuzen([]); setSubeyeOzel(0);
      setMesaj(c('Varsayılan düzene dönüldü.'));
    } catch (h) { setMesaj(hataMetni(h)) }
  };

  /** Sürükle-bırak: aynı üstteki kardeşler arasında SIRA değiştirir. */
  const birak = (hedef: Dugum) => {
    if (!surukle || surukle === hedef.kod) { setSurukle(null); return }
    const kaynak = dugumler.find(x => x.kod === surukle);
    setSurukle(null);
    if (!kaynak || kaynak.tur !== hedef.tur || kaynak.ustKod !== hedef.ustKod) {
      // FARKLI SEVİYE / FARKLI ÜST: mockup'ta derinlik değiştirme var, ama
      //   ekran burada yalnız KARDEŞ SIRASI değiştiriyor - grubu başka bölgeye
      //   taşımak bölge tanımını (kod) değiştirmek demek, o ayrı iş.
      setMesaj(c('Yalnız aynı başlık altındaki düğümler kendi aralarında sıralanır.'));
      return;
    }
    const kardes = dugumler.filter(x => x.tur === kaynak.tur && x.ustKod === kaynak.ustKod);
    const sira = kardes.map(x => x.kod).filter(k => k !== kaynak.kod);
    const i = sira.indexOf(hedef.kod);
    sira.splice(i < 0 ? sira.length : i, 0, kaynak.kod);
    setDuzen(onceki => {
      let sonuc = [...onceki];
      sira.forEach((kod, indeks) => {
        const d = dugumler.find(x => x.kod === kod)!;
        const mevcut = sonuc.find(x => x.sistemKod === kod);
        const yeni: MenuDuzenSatiri = {
          dugumTur: d.tur === 'bolge' ? 1 : d.tur === 'grup' ? 2 : 4,
          sistemKod: kod, ustKod: d.ustKod ?? null,
          gorunenAd: '', ikon: '', gizli: 0, acilistaAcik: 0,
          ...mevcut, sira: (indeks + 1) * 10,
        };
        sonuc = [...sonuc.filter(x => x.sistemKod !== kod), yeni];
      });
      return sonuc;
    });
  };

  return (
    <div className="mn-ekran">
      <div className="mn-ust">
        {!gomulu && <>
          <h2>{c('Menü Düzeni')}</h2>
          <span className="sonuk">{c('Yönetim › Ayarlar › Menü Düzeni')}</span>
        </>}
        <span className="mn-bosluk" />
        <select className="mn-inp" value={subeId} onChange={e => setSubeId(Number(e.target.value))}>
          {(kullanici?.subeler ?? []).map(s => <option key={s.id} value={s.id}>{c(s.ad, 'kod')}</option>)}
        </select>
        <span className={`rozet ${subeyeOzel > 0 ? 'olumlu' : 'gri'}`}>
          {subeyeOzel > 0 ? `${c('şubeye özel')} · ${subeyeOzel}` : c('varsayılan düzen')}
        </span>
        <button type="button" className="d birincil" disabled={!duzenleyebilir}
                onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>
        <button type="button" className="d" disabled={!duzenleyebilir || subeyeOzel === 0}
                onClick={() => void sifirla()}>⤾ {c('Varsayılana dön')}</button>
      </div>

      {mesaj && <div className="mn-mesaj">{mesaj}</div>}
      <div className="mn-uyari">{c('Gizlemek yetki değildir: menüden kaldırılan ekran, yetkisi olan '
        + 'kullanıcıya adresten yine açılır. Erişimi kapatmak için Yetkiler ekranını kullanın.')}</div>

      <div className="mn-govde">
        {/* AĞAÇ */}
        <div className="mn-agac">
          <div className="mn-agac-bas">{c('Sürükleyerek sırala · göz ile gizle')}
            <span className="sonuk"> · {dugumler.length} {c('düğüm')}</span>
            <span className="mn-bosluk" />
            <button type="button" className="d mini" onClick={() => setAcik(
              Object.fromEntries(dugumler.filter(x => dugumler.some(y => y.ustKod === x.kod))
                                         .map(x => [x.kod, true])))}>⤢ {c('Tümünü aç')}</button>
            <button type="button" className="d mini" onClick={() => setAcik({})}>⤡ {c('Kapat')}</button>
          </div>
          {yukleniyor && <div className="sonuk" style={{ padding: 10 }}>{c('yükleniyor')}…</div>}
          {dugumler.filter(d => {
            // ÜST ZİNCİRİ KAPALIYSA ÇİZİLMEZ: bölge kapalıysa grupları da,
            //   grup kapalıysa ekranları da gizlenir.
            let k = d.ustKod;
            const gorulen = new Set<string>();
            while (k && !gorulen.has(k)) {
              gorulen.add(k);
              if (!acikMi(k)) return false;
              k = dugumler.find(x => x.kod === k)?.ustKod;
            }
            return true;
          }).map(d => {
            const f = fark(d.kod);
            const kendiGizli = f?.gizli === 1;
            const mirasGizli = !kendiGizli && ustGizli(d);
            const gizli = kendiGizli || mirasGizli;
            return (
              <div key={d.kod}
                   className={`mn-dugum d${d.derinlik}${secili === d.kod ? ' sec' : ''}`
                              + `${gizli ? ' gizli' : ''}${surukle === d.kod ? ' surukle' : ''}`}
                   draggable={duzenleyebilir}
                   onDragStart={() => setSurukle(d.kod)}
                   onDragOver={e => e.preventDefault()}
                   onDrop={() => birak(d)}
                   onClick={() => setSecili(d.kod)}>
                <span className="tut">⠿</span>
                {dugumler.some(x => x.ustKod === d.kod) ? (
                  <button type="button" className="d mini mn-ok"
                          title={acikMi(d.kod) ? c('Kapat') : c('Aç')}
                          onClick={e => { e.stopPropagation(); ac(d.kod) }}>
                    {acikMi(d.kod) ? '▾' : '▸'}</button>
                ) : <span className="mn-ok-bos" />}
                {d.ikon && <span className="ikon">{d.ikon}</span>}
                <span className="ad">{f?.gorunenAd || d.ad}</span>
                <span className="sag">
                  <span className="rozet gri">{c(d.tur === 'bolge' ? 'bölge' : d.tur === 'grup' ? 'grup' : 'ekran')}</span>
                  {/* ÜSTÜ GİZLİYSE düğme kapalı: alt düğümü tek tek göstermek,
                      grubu kapalıyken menüde yalnız o satırı çizmek demekti. */}
                  <button type="button" className="d mini"
                          disabled={!duzenleyebilir || mirasGizli}
                          title={mirasGizli ? c('Üst başlık gizli - önce onu açın')
                                 : kendiGizli ? c('Göster') : c('Gizle')}
                          onClick={e => { e.stopPropagation(); farkYaz(d, { gizli: kendiGizli ? 0 : 1 }) }}>
                    {gizli ? '🚫' : '👁'}</button>
                </span>
              </div>
            );
          })}
        </div>

        {/* ÖZELLİKLER */}
        <div className="mn-ozellik">
          {!seciliDugum ? (
            <div className="sonuk">{c('Düzenlemek için soldan bir düğüm seçin.')}</div>
          ) : (
            <>
              <h5>{c('Seçili düğüm')} · {c(seciliDugum.tur === 'bolge' ? 'bölge'
                : seciliDugum.tur === 'grup' ? 'grup' : 'ekran')}</h5>
              <div className="mn-izgara">
                <label className="mn-kutu"><span>{c('Sistem adı (değişmez)')}</span>
                  <div className="mn-inp pasif">{seciliDugum.sistemAd}</div></label>
                <label className="mn-kutu"><span>{c('Görünen ad')}</span>
                  <input className="mn-inp" disabled={!duzenleyebilir}
                         value={fark(seciliDugum.kod)?.gorunenAd ?? ''}
                         placeholder={seciliDugum.ad}
                         onChange={e => farkYaz(seciliDugum, { gorunenAd: e.target.value })} /></label>
                <label className="mn-kutu"><span>{c('İkon')}</span>
                  <input className="mn-inp" disabled={!duzenleyebilir}
                         value={fark(seciliDugum.kod)?.ikon ?? ''}
                         placeholder={seciliDugum.ikon ?? '—'}
                         onChange={e => farkYaz(seciliDugum, { ikon: e.target.value })} /></label>
                <label className="mn-kutu"><span>{c('Üst başlık')}</span>
                  <div className="mn-inp pasif">{seciliDugum.ustKod ? c(seciliDugum.ustKod) : '—'}</div></label>
                <label className="mn-kutu"><span>{c('Sıra')}</span>
                  <div className="mn-inp pasif">{fark(seciliDugum.kod)?.sira ?? c('varsayılan')}</div></label>
                <label className="mn-kutu"><span>{c('Derinlik')}</span>
                  <div className="mn-inp pasif">{seciliDugum.derinlik}</div></label>
                <label className="mn-kutu"><span>{c('Durum')}</span>
                  <select className="mn-inp"
                          disabled={!duzenleyebilir || (fark(seciliDugum.kod)?.gizli !== 1 && ustGizli(seciliDugum))}
                          value={fark(seciliDugum.kod)?.gizli === 1 ? '1' : '0'}
                          onChange={e => farkYaz(seciliDugum, { gizli: Number(e.target.value) })}>
                    <option value="0">{c('Görünür')}</option>
                    <option value="1">{c('Gizli')}</option>
                  </select></label>
                {seciliDugum.yol && (
                  <label className="mn-kutu"><span>{c('Rota')}</span>
                    <div className="mn-inp pasif">{seciliDugum.yol}</div></label>
                )}
              </div>
              <div className="mn-bilgi">{c('Sistem adı değişmez: rota, yetki ve kod eşlemesi ona bağlıdır. '
                + 'Değiştirilen yalnız görünen addır. Sıra sürükleyerek değişir; boş bırakılan alan '
                + 'varsayılana döner ve kayıttan düşer.')}</div>
            </>
          )}
        </div>

        {/* ÖNİZLEME */}
        <div className="mn-onizle">
          <div className="mn-onizle-bas">{c('Önizleme')}</div>
          {dugumler.filter(d => !gizliMi(d)).map(d => {
            const ad = fark(d.kod)?.gorunenAd || d.ad;
            return (
              <div key={`o-${d.kod}`} className={`mn-oge d${d.derinlik}`}>
                {d.ikon && <span>{fark(d.kod)?.ikon || d.ikon}</span>} {ad}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
