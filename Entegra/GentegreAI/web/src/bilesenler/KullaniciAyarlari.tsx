import { useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import type { AcikOturum, GirisDenemesi, HesapBilgisi } from '../api/uclar/kimlik';
import { hataMetni } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { LISTELER, modulAcikMi } from '../sayfalar/listeTanimlari';
import { modUyar } from '../api/sozlesme';
import { TEMA_ADI, TEMA_IKON, temaUygula, type Tema } from './tema';
import { tarihSaat } from './bicim';
import { cihazAdi } from './cihazAdi';
import { DILLER } from './diller';
import { Bayrak } from './Bayrak';
import { telefonAyir, telefonBirlestir, ulkeEtiketi, ULKE_KODLARI } from './telefon';
import {
  gorunumOku, gorunumKaydet, LISTE_SATIR_SECENEKLERI, YAZI_BOYU_SECENEKLERI,
  GRID_CIZGI_SECENEKLERI, type GorunumTercihi, type Yogunluk, type YaziBoyu, type GridCizgi,
} from './gorunum';
import {
  bildirimOku, bildirimKaydet, olaylar, masaustuIzniIste, denemeBildirimi,
  type BildirimTercihi,
} from './bildirimTercihi';
import { calismaOku, calismaKaydet, type CalismaTercihi } from './calismaTercihi';
import { sifreGucu, basHarfler, gunOnce } from './kullaniciAyarlariKurallari';
import { profilResmiSil, profilResmiYukle, useProfilResmi } from './profilResmi';

/**
 * KULLANICI AYARLARI (669) — üst şeritteki avatardan açılan pencere.
 * Tasarım: `Ekranlar/Ayarlar/kullanici_ayarlari.html` (edit ve etiketler
 * birebir; 5 tur karşılaştırma ile eşitlendi).
 *
 * Dört sekme: Hesabım · Görünüm · Güvenlik · Bildirimler. Üstte KİMLİK BAŞI
 * (avatar, ad, kod, roller, son giriş, şifre yaşı, 2 adımlı doğrulama durumu).
 *
 * İKİ KURAL:
 *  · KİŞİSEL ≠ KURUMSAL. Bu pencere yalnız kendi hesabı değiştirir; kurumun
 *    ayarları Yönetim altında ve ayrı yetkide kalır. Kurumun kuralı olan alan
 *    (tarih biçimi, sayı ayıracı, oturum süresi) GRİ gösterilir, gizlenmez.
 *  · OLMAYAN ÖZELLİK ÇİZİLMEZ. Mockup'taki görünen ad, profil fotoğrafı,
 *    e-posta/SMS/mobil kanalları, 2 adımlı doğrulama KURULUMU ve "son 5
 *    şifreden farklı" kuralı sunucuda yok - düğmesini koymak yalan olurdu.
 *    2 adımlı doğrulama yalnız DURUM olarak (başlıkta) okunur.
 */
export function KullaniciAyarlari({ ayar, tema, setTema, c }: {
  ayar: {
    acik: boolean; kapat(): void; tamam(): Promise<void>;
    seciliDil: number; setSeciliDil(d: number): void;
    eskiSifre: string; setEskiSifre(s: string): void;
    sifre1: string; setSifre1(s: string): void;
    sifre2: string; setSifre2(s: string): void;
    mesaj: string; kaydediliyor: boolean;
  };
  tema: Tema;
  setTema(t: Tema): void;
  c(m: string): string;
}) {
  const { aksiyonDegeri, kullanici } = useOturum();
  const [sekme, setSekme] = useState<'hesap' | 'gorunum' | 'guvenlik' | 'bildirim'>('hesap');
  const [h, setH] = useState<HesapBilgisi | null>(null);
  const [hataH, setHataH] = useState('');

  // ILETISIM alt sekmede duzenlenir, ALTTAKI Kaydet ile yazilir (mockup: tek
  //   Kaydet). Ayri "Iletisim Bilgisini Kaydet" dugmesi kalkti.
  const [eposta, setEposta] = useState('');
  const [ulke, setUlke] = useState('+90');
  const [numara, setNumara] = useState('');
  const [iletisimHata, setIletisimHata] = useState('');
  // PROFIL FOTOGRAFI: avatara tiklayinca dosya secilir; personel kartinin
  //   varsayilan resmi olur (profilResmi.ts). Kaldir -> bas harfler.
  const resimUrl = useProfilResmi(kullanici?.id);
  const dosyaRef = useRef<HTMLInputElement | null>(null);
  const [resimIslem, setResimIslem] = useState('');
  const resimSec = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const dosya = e.target.files?.[0]; e.target.value = '';
    if (!dosya || !kullanici) return;
    if (dosya.size > 2 * 1024 * 1024) { setResimIslem(c("Fotoğraf 2 MB'tan küçük olmalı.")); return }
    setResimIslem(c('Yükleniyor…'));
    try { await profilResmiYukle(kullanici.id, dosya); setResimIslem('') }
    catch (h) { setResimIslem(hataMetni(h)) }
  };
  const resimKaldir = async () => {
    if (!kullanici) return;
    setResimIslem(c('Kaldırılıyor…'));
    try { await profilResmiSil(kullanici.id); setResimIslem('') }
    catch (h) { setResimIslem(hataMetni(h)) }
  };

  useEffect(() => {
    if (!ayar.acik) return;
    let iptal = false;
    api.hesabim()
      .then(y => {
        if (iptal) return;
        setH(y); setEposta(y.eposta);
        const t = telefonAyir(y.cepTel);
        setUlke(t.ulke); setNumara(t.numara);
      })
      .catch(e => { if (!iptal) setHataH(hataMetni(e)) });
    return () => { iptal = true };
  }, [ayar.acik]);

  const cepTel = telefonBirlestir({ ulke, numara });
  const iletisimDegisti = !!h && (eposta.trim() !== h.eposta || cepTel !== h.cepTel);
  const dilDegisti = ayar.seciliDil !== (kullanici?.dil ?? 0);
  const sifreVar = !!(ayar.sifre1 || ayar.sifre2 || ayar.eskiSifre);

  const bekleyen = [
    dilDegisti && c('dil'), iletisimDegisti && c('iletişim'), sifreVar && c('şifre'),
  ].filter(Boolean) as string[];

  /** Kaydet: önce iletişim (ayrı uç), sonra dil + şifre (hook). */
  const kaydet = async () => {
    setIletisimHata('');
    if (iletisimDegisti) {
      try { await api.iletisimKaydet(eposta.trim(), cepTel); setH(x => x ? { ...x, eposta: eposta.trim(), cepTel } : x) }
      catch (e) { setIletisimHata(hataMetni(e)); return }
    }
    await ayar.tamam();
  };

  const tavan = aksiyonDegeri('basvuru.iskonto');
  const acikBildirim = useMemo(() => {
    const t = bildirimOku();
    return olaylar(tavan).filter(o => (t.olaylar[o.kod] ?? { zil: true }).zil).length;
  }, [tavan, sekme]);

  if (!ayar.acik) return null;

  const ad = h?.unvan || kullanici?.ad || kullanici?.kod || '';
  const durum = bekleyen.length > 0
    ? `${c('Kaydedilmemiş')} ${bekleyen.length} ${c('değişiklik')} · ${bekleyen.join(', ')}`
    : DURUM[sekme];

  return (
    <div className="kaperde"
         onMouseDown={e => { if (e.target === e.currentTarget) ayar.kapat() }}>
      <div className="kawin kullanici-ayarlari" role="dialog" aria-label="Kullanıcı Ayarları">
        <div className="kabas">
          <span>👤 {c('Kullanıcı Ayarları')}</span>
          <span className="kapt">{c('Değişiklikler yalnız kendi hesabınızı etkiler')}</span>
          <button type="button" className="ka-kapat" title={c('Kapat')} onClick={ayar.kapat}>✕</button>
        </div>

        {/* KİMLİK BAŞI (mockup .kimlik): kim, hangi rol, son giriş. */}
        <div className="ka-kimlik">
          <input ref={dosyaRef} type="file" style={{ display: 'none' }}
                 accept="image/jpeg,image/png,image/webp" onChange={e => void resimSec(e)} />
          <button type="button" className="ka-avatar" title={c('Profil fotoğrafı yükle')}
                  onClick={() => dosyaRef.current?.click()}>
            {resimUrl ? <img src={resimUrl} alt="" /> : basHarfler(ad)}
            <span className="kalem">✎</span>
          </button>
          <div>
            <div className="ka-ad">{ad}</div>
            <div className="ka-alt">
              {h?.eposta || <span className="sonuk">{c('e-posta yok')}</span>}
              {' · '}{c('Kullanıcı kodu')} <b>{kullanici?.kod}</b> · ID {kullanici?.id}
              {h?.gorev && <> · {h.gorev}</>}
            </div>
            <div className="ka-rozetler">
              <span className="rozet mavi">{c('Ana rol')}: {h?.anaRol || kullanici?.rolAdi || '-'}</span>
              {h?.ekRoller.map(r => <span key={r} className="rozet mor">+ {r}</span>)}
              <span className="rozet ok">{c('Aktif')}</span>
              {(kullanici?.subeler ?? []).length > 0 && (
                <span className="rozet gri">{(kullanici?.subeler ?? []).map(s => s.ad).join(' · ')}</span>
              )}
            </div>
          </div>
          <div className="ka-kimlik-sag">
            {c('Son giriş')}: <b>{h?.sonGiris ? tarihSaat(h.sonGiris) : '—'}</b>{h?.sonGirisIp && <> · {h.sonGirisIp}</>}<br />
            {c('Şifre değişimi')}: {h?.parolaTarihi ? gunOnce(h.parolaTarihi, c) : <span className="sonuk">{c('bilinmiyor')}</span>}<br />
            <span className={`rozet ${h?.totpAktif ? 'ok' : 'uyari'}`}>
              {c('2 adımlı doğrulama')} {h?.totpAktif ? c('açık') : c('kapalı')}
            </span>
          </div>
        </div>
        {hataH && <div className="kauyari">{hataH}</div>}

        <div className="ka-sekmeler" role="tablist">
          {([
            ['hesap', 'Hesabım'],
            ['gorunum', 'Görünüm'],
            ['guvenlik', 'Güvenlik'],
            ['bildirim', 'Bildirimler'],
          ] as const).map(([k, adi]) => (
            <button key={k} type="button" role="tab" aria-selected={sekme === k}
                    className={`ka-sekme${sekme === k ? ' on' : ''}`}
                    onClick={() => setSekme(k)}>
              {c(adi)}
              {k === 'bildirim' && acikBildirim > 0 && (
                <span className="rozet mavi" style={{ marginLeft: 4 }}>{acikBildirim} {c('açık')}</span>
              )}
            </button>
          ))}
        </div>

        <div className="kagov">
          {sekme === 'hesap' && (
            <Hesabim c={c} h={h} eposta={eposta} setEposta={setEposta} ulke={ulke} setUlke={setUlke}
                     numara={numara} setNumara={setNumara} kilitli={ayar.kaydediliyor}
                     hata={iletisimHata} tavan={tavan}
                     resim={{ url: resimUrl, islem: resimIslem, sec: () => dosyaRef.current?.click(), kaldir: () => void resimKaldir() }} />
          )}
          {sekme === 'gorunum' && (
            <Gorunum c={c} tema={tema} setTema={setTema}
                     seciliDil={ayar.seciliDil} setSeciliDil={ayar.setSeciliDil}
                     kilitli={ayar.kaydediliyor} />
          )}
          {sekme === 'guvenlik' && <Guvenlik ayar={ayar} c={c} ad={ad} />}
          {sekme === 'bildirim' && <Bildirimler c={c} iskontoTavani={tavan} />}
        </div>

        <div className="kaalt-durum">{durum}</div>

        {/* STANDART ALT SERIT: solda Iptal, sagda birincil Kaydet. Kaydet dil,
            iletisim ve sifreyi gonderir - gorunum/bildirim/calisma tercihleri
            kendi sekmelerinde ANINDA kaydedilir. */}
        <div className="kaalt">
          <button className="d kapat-dugmesi" onClick={ayar.kapat}
                  disabled={ayar.kaydediliyor}>{c('İptal')}</button>
          <button className="d bir" onClick={() => void kaydet()}
                  disabled={ayar.kaydediliyor}>
            {ayar.kaydediliyor ? c('Kaydediliyor…') : c('Kaydet')}
          </button>
        </div>
      </div>
    </div>
  );
}

/** Alt şeritteki açıklama sekmeye göre değişir: ne zaman geçerli olduğu farklı. */
const DURUM: Record<string, string> = {
  hesap: 'Dil, iletişim ve şifre Kaydet ile yazılır; çalışma tercihleri anında.',
  gorunum: 'Tema anında uygulanır, kaydet gerekmez.',
  guvenlik: 'Güvenlik değişiklikleri işlem günlüğüne yazılır.',
  bildirim: 'Değişiklikler hemen geçerli olur.',
};

/* ========================================================== HESABIM ==== */

function Hesabim({ c, h, eposta, setEposta, ulke, setUlke, numara, setNumara, kilitli, hata, tavan, resim }: {
  c(m: string): string; h: HesapBilgisi | null;
  eposta: string; setEposta(v: string): void; ulke: string; setUlke(v: string): void;
  numara: string; setNumara(v: string): void; kilitli: boolean; hata: string; tavan: number;
  resim: { url: string | null; islem: string; sec(): void; kaldir(): void };
}) {
  const { kullanici, kaynaklar } = useOturum();
  const [yetkiAcik, setYetkiAcik] = useState(false);
  const [calisma, setCalisma] = useState<CalismaTercihi>(() => calismaOku());
  const [g, setG] = useState<GorunumTercihi>(() => gorunumOku());
  const [tHata, setTHata] = useState('');

  const calismaYaz = async (y: CalismaTercihi) => {
    setCalisma(y); setTHata('');
    try { await calismaKaydet(y) } catch (e) { setTHata(hataMetni(e)) }
  };
  const gorunumYaz = async (y: GorunumTercihi) => {
    setG(y); setTHata('');
    try { await gorunumKaydet(y) } catch (e) { setTHata(hataMetni(e)) }
  };

  // ACILIS EKRANI secenekleri: kisinin YETKILI oldugu menu ekranlari.
  const ekranlar = useMemo(() => LISTELER
    .filter(l => l.menuGrup && !l.menuGizli && kaynaklar.some(k => k.kod === l.yetkiKodu && k.gor)
      && (!l.urunModu || modUyar(l.urunModu, kullanici?.urunModu))
      && modulAcikMi(l, kullanici?.moduller))
    .map(l => ({ rota: l.rota ?? l.kaynak, ad: `${l.menuGrup} › ${l.menuAd ?? l.baslik}` })),
    [kaynaklar, kullanici?.urunModu, kullanici?.moduller]);

  const aktifSube = kullanici?.subeler.find(s => s.id === kullanici?.subeId);
  const ulkeKod = aktifSube?.ulkeKod ?? 'TR';
  const yerelTr = ulkeKod === 'TR' || ulkeKod === 'DE';
  const gorulen = kaynaklar.filter(k => k.gor);

  return (
    <>
      <div className="ka-ikili">
        <div>
          <div className="kagrup">
            <h6>{c('İletişim')} <span>{c('bunları siz değiştirirsiniz')}</span></h6>
            <div className="kasat">
              <label>{c('Ad Soyad')}</label>
              <div className="kaara">
                <input value={h?.unvan || kullanici?.ad || ''} disabled />
                <span className="rozet gri">{c('personel kartından')}</span>
              </div>
              <label>{c('Kullanıcı kodu')}</label><input value={kullanici?.kod ?? ''} disabled />
              <label className="ka-zorunlu">{c('E-posta')}</label>
              <input value={eposta} onChange={e => setEposta(e.target.value)}
                     disabled={kilitli} autoComplete="email" />
              <label>{c('Cep telefonu')}</label>
              <div className="kaara">
                {/* Ulke kodu AYRI kutu: numara alanina her seferinde "+90" yazmak
                    hem zaman kaybi hem de "0090"/"0"/"+90" karisikligi kaynagiydi. */}
                <select className="ka-ulke" value={ulke} disabled={kilitli}
                        onChange={e => setUlke(e.target.value)}>
                  {ULKE_KODLARI.map(u => (
                    <option key={u.kod} value={u.kod} title={u.ad}>{ulkeEtiketi(u.kod)}</option>
                  ))}
                </select>
                <input value={numara} disabled={kilitli} autoComplete="tel-national"
                       placeholder="555 123 45 67"
                       /* Yapistirlan "+90 555…" / "0532…" kendiliginden ayrisir. */
                       onChange={e => {
                         const t = telefonAyir(e.target.value);
                         if (/^\s*(\+|00)/.test(e.target.value)) { setUlke(t.ulke); setNumara(t.numara) }
                         else setNumara(e.target.value);
                       }} />
              </div>
              <label>{c('Profil fotoğrafı')}</label>
              <div className="kaara">
                <button type="button" className="d" onClick={resim.sec}>📷 {c('Yükle')}</button>
                <button type="button" className="d" disabled={!resim.url} onClick={resim.kaldir}>{c('Kaldır')}</button>
                <span className="sonuk">{resim.islem || (resim.url ? c('personel kartının varsayılan resmi') : c('baş harfler kullanılır'))}</span>
              </div>
            </div>
            {hata && <div className="kauyari">{hata}</div>}
            <div className="kanot">
              {c('Ad, sicil ve görev bilgisi personel kartında durur — buradan değişmez. Kendi kartını düzenleyebilen kişi kendi görevini de değiştirebilirdi.')}
            </div>
          </div>

          {/* ROLLER (665): salt okunur. "Neden bu ekranı açamıyorum / neden onay
              bana düşmüyor" sorusu en çok burada sorulur - cevabı yetki matrisine
              girmeden okunabilmeli. Değiştirmek yöneticinin işidir. */}
          <div className="kagrup">
            <h6>{c('Rollerim')} <span>{c('salt okunur')}</span></h6>
            <div className="ka-liste">
              <div className="ka-satir"><span>{c('Ana rol')}</span>
                <b>{h?.anaRol || kullanici?.rolAdi || '-'}</b></div>
              <div className="ka-satir"><span>{c('Ek rol')}</span>
                <b>{h && h.ekRoller.length > 0
                     ? h.ekRoller.map(r => <span key={r} className="rozet mor">{r}</span>)
                     : <span className="sonuk">{c('yok')}</span>}</b></div>
              {tavan > 0 && (
                <div className="ka-satir"><span>{c('İskonto tavanı')}</span><b>%{tavan}</b></div>
              )}
              <div className="ka-satir"><span>{c('Şubeler')}</span>
                <b>{(kullanici?.subeler ?? []).map(s => (
                  <span key={s.id}>{s.ad}{s.id === kullanici?.subeId && <span className="rozet ok" style={{ marginLeft: 4 }}>{c('aktif')}</span>}</span>
                ))}</b></div>
              <div className="ka-satir"><span></span>
                <button type="button" className="d" onClick={() => setYetkiAcik(a => !a)}>
                  🛡 {yetkiAcik ? c('Yetkileri gizle') : c('Yetkilerimi gör')}
                </button></div>
              {yetkiAcik && (
                <div className="ka-yetkiler">
                  {gorulen.length === 0 && <span className="sonuk">{c('Görülebilir kaynak yok.')}</span>}
                  {gorulen.map(k => (
                    <span key={k.kod} className="rozet gri" title={`${c('Gör')}${k.ekle ? ' · ' + c('Ekle') : ''}${k.degistir ? ' · ' + c('Değiştir') : ''}${k.sil ? ' · ' + c('Sil') : ''}`}>
                      {k.kod}{k.degistir ? ' ✎' : ''}{k.sil ? ' 🗑' : ''}
                    </span>
                  ))}
                </div>
              )}
            </div>
            <div className="kanot">
              {c('Yetki ana rol ile ek rollerin birleşimidir; sayısal sınırlarda en yüksek değer geçerlidir. Rol değişimi yöneticinin işidir — burada yalnız görünür, çünkü “neden bu ekranı açamıyorum” sorusu çoğu zaman burada cevaplanır.')}
            </div>
          </div>
        </div>

        <div>
          <div className="kagrup">
            <h6>{c('Çalışma Tercihleri')} <span>{c('anında kaydedilir')}</span></h6>
            <div className="kasat">
              <label>{c('Açılış şubesi')}</label>
              <select value={calisma.acilisSube} onChange={e => void calismaYaz({ ...calisma, acilisSube: Number(e.target.value) })}>
                <option value={0}>{c('Son kullanılan şube')}</option>
                {(kullanici?.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
              </select>
              <label>{c('Açılış ekranı')}</label>
              <select value={calisma.acilisEkran} onChange={e => void calismaYaz({ ...calisma, acilisEkran: e.target.value })}>
                <option value="">{c('Ana Sayfa (Panel)')}</option>
                {ekranlar.map(e => <option key={e.rota} value={e.rota}>{e.ad}</option>)}
              </select>
              <label>{c('Liste satır sayısı')}</label>
              <select value={g.listeSatir} onChange={e => void gorunumYaz({ ...g, listeSatir: Number(e.target.value) })}>
                {LISTE_SATIR_SECENEKLERI.map(n => <option key={n} value={n}>{n} {c('kayıt / sayfa')}</option>)}
              </select>
              <label>{c('Tarih biçimi')}</label>
              <div className="kaara"><input value={yerelTr ? 'gg.aa.yyyy' : 'yyyy-mm-dd'} disabled /><span className="rozet gri">{c('şube ayarı')}</span></div>
              <label>{c('Sayı ayıracı')}</label>
              <div className="kaara"><input value={yerelTr ? '1.234,56' : '1,234.56'} disabled /><span className="rozet gri">{c('şube ayarı')}</span></div>
              <label>{c('Oturum süresi')}</label>
              <div className="kaara"><input value={c('30 gün · yenilenen oturum')} disabled /><span className="rozet gri">{c('kurum ayarı')}</span></div>
            </div>
            {tHata && <div className="kauyari">{tHata}</div>}
            <div className="kanot">
              {c('Açılış şubesi yetkili olduğunuz şubeler arasından seçilir; kurumun oturum süresi gibi kuralları kişi değiştiremez — gri gösterilir, gizlenmez.')}
            </div>
          </div>

          <div className="kagrup">
            <h6>{c('Kısayollar')}</h6>
            <div className="ka-liste">
              <div className="ka-satir"><span>{c('Hızlı arama / komut paleti')}</span><b>Ctrl + K</b></div>
              <div className="ka-satir"><span>{c('Komut paleti (yedek)')}</span><b>Ctrl + Shift + P · F1</b></div>
              <div className="ka-satir"><span>{c('Pencereyi kapat')}</span><b>Esc</b></div>
              <div className="ka-satir"><span>{c('Sonuç girişinde kaydet')}</span><b>Ctrl + Enter</b></div>
              <div className="ka-satir"><span>{c('Klavye kısayolları')}</span>
                <span className="sonuk">{c('yalnız tanımlı olanlar listelenir')}</span></div>
            </div>
          </div>
        </div>
      </div>

      <div className="ka-bilgi">
        <span>ℹ</span>
        <div>{c('Buradaki ayarlar yalnız sizin hesabınız içindir. Kurumun tamamını ilgilendiren ayarlar (kurum tipi, modüller, e-Belge, fiyat listeleri) Yönetim › Ayarlar altındadır ve ayrı yetki ister.')}</div>
      </div>
    </>
  );
}

/* ========================================================== GÖRÜNÜM ==== */

function Gorunum({ c, tema, setTema, seciliDil, setSeciliDil, kilitli }: {
  c(m: string): string; tema: Tema; setTema(t: Tema): void;
  seciliDil: number; setSeciliDil(d: number): void; kilitli: boolean;
}) {
  const [g, setG] = useState<GorunumTercihi>(() => gorunumOku());
  const [hata, setHata] = useState('');

  const yaz = async (yeni: GorunumTercihi) => {
    setG(yeni); setHata('');
    try { await gorunumKaydet(yeni) } catch (e) { setHata(hataMetni(e)) }
  };

  return (
    <div className="ka-ikili">
      <div>
        <div className="kagrup">
          <h6>{c('Tema')} <span>{c('bu cihazda saklanır')}</span></h6>
          <div className="ka-secenekler">
            {(['sistem', 'gunduz', 'gece'] as Tema[]).map(t => (
              <button key={t} type="button"
                      className={`ka-sec${tema === t ? ' on' : ''}`}
                      onClick={() => { setTema(t); temaUygula(t) }}>
                <span className="ikon">{TEMA_IKON[t]}</span>{c(TEMA_ADI[t])}
              </button>
            ))}
          </div>
          <div className="kanot">
            {c('Tema hesapta değil tarayıcıda durur: aynı kişi poliklinikteki bilgisayarda gündüz, evde gece kullanabilir.')}
          </div>
        </div>

        <div className="kagrup">
          <h6>{c('Dil')} <span>{c('hesapta saklanır')}</span></h6>
          <div className="ka-secenekler">
            {DILLER.map(d => (
              <button key={d.deger} type="button" disabled={kilitli}
                      className={`ka-sec${seciliDil === d.deger ? ' on' : ''}`}
                      onClick={() => setSeciliDil(d.deger)}>
                <span className="ikon"><Bayrak dil={d.deger} boy={20} /></span>{d.ad}
              </button>
            ))}
          </div>
          <div className="kanot">
            {c('Dil hesapta saklanır (üst şeritteki bayrak aynı değeri yazar) — kişi hangi cihazdan girerse girsin kendi dilini bulur. Kaydet ile yazılır.')}
          </div>
        </div>
      </div>

      <div>
        <div className="kagrup">
          <h6>{c('Yoğunluk ve Yazı')} <span>{c('anında uygulanır')}</span></h6>
          <div className="ka-secenekler">
            {([['sikisik', '≡', 'Sıkışık'], ['normal', '☰', 'Normal'],
               ['ferah', '☷', 'Ferah']] as const).map(([k, ik, adi]) => (
              <button key={k} type="button"
                      className={`ka-sec${g.yogunluk === k ? ' on' : ''}`}
                      onClick={() => void yaz({ ...g, yogunluk: k as Yogunluk })}>
                <span className="ikon">{ik}</span>{c(adi)}
              </button>
            ))}
          </div>
          <div className="kasat" style={{ paddingTop: 0 }}>
            <label>{c('Yazı boyu')}</label>
            <select value={g.yaziBoyu} onChange={e => void yaz({ ...g, yaziBoyu: Number(e.target.value) as YaziBoyu })}>
              {YAZI_BOYU_SECENEKLERI.map(s => <option key={s.deger} value={s.deger}>{c(s.ad)}</option>)}
            </select>
            <label>{c('Grid çizgileri')}</label>
            <select value={g.gridCizgi} onChange={e => void yaz({ ...g, gridCizgi: e.target.value as GridCizgi })}>
              {GRID_CIZGI_SECENEKLERI.map(s => <option key={s.deger} value={s.deger}>{c(s.ad)}</option>)}
            </select>
          </div>
          <div className="kanot">
            {c('“Sıkışık” aynı ekrana daha çok satır sığdırır — veznede ekran küçük, listede satır sayısı kararı hızlandırır. Yazı boyu tüm arayüzü ölçekler.')}
          </div>
          {hata && <div className="kauyari">{hata}</div>}
        </div>

        <div className="kagrup">
          <h6>{c('Önizleme')}</h6>
          <table className="grid">
            <thead><tr><th>{c('Belge No')}</th><th>{c('Cari')}</th><th style={{ textAlign: 'right' }}>{c('Tutar')}</th><th style={{ textAlign: 'center' }}>{c('Durum')}</th></tr></thead>
            <tbody>
              <tr><td>FT-2026-000118</td><td>Neslihan ARSLAN</td><td style={{ textAlign: 'right' }}>2.386,00</td>
                  <td style={{ textAlign: 'center' }}><span className="rozet ok">{c('Tahsil')}</span></td></tr>
              <tr><td>FT-2026-000117</td><td>Murat DEMİR</td><td style={{ textAlign: 'right' }}>640,00</td>
                  <td style={{ textAlign: 'center' }}><span className="rozet uyari">{c('Bekliyor')}</span></td></tr>
            </tbody>
          </table>
          <div className="kanot">
            {c('Ayarın etkisi gerçek bir grid üzerinde görünür — kaydedip listeye dönüp beğenmeyip geri gelmek gerekmesin.')}
          </div>
        </div>
      </div>
    </div>
  );
}

/* ========================================================= GÜVENLİK ==== */

function Guvenlik({ ayar, c, ad }: {
  ayar: {
    eskiSifre: string; setEskiSifre(s: string): void;
    sifre1: string; setSifre1(s: string): void;
    sifre2: string; setSifre2(s: string): void;
    mesaj: string; kaydediliyor: boolean;
  };
  c(m: string): string; ad: string;
}) {
  const [oturumlar, setOturumlar] = useState<AcikOturum[] | null>(null);
  const [gecmis, setGecmis] = useState<GirisDenemesi[] | null>(null);
  const [hata, setHata] = useState('');
  const [islemde, setIslemde] = useState(false);
  const guc = sifreGucu(ayar.sifre1, ad);
  const esit = !!ayar.sifre1 && ayar.sifre1 === ayar.sifre2;

  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const [o, g] = await Promise.all([api.oturumlar(), api.girisGecmisi()]);
        if (iptal) return;
        setOturumlar(o); setGecmis(g);
      } catch (e) { if (!iptal) setHata(hataMetni(e)) }
    })();
    return () => { iptal = true };
  }, []);

  const kapat = async (id: number) => {
    setIslemde(true); setHata('');
    try {
      await api.oturumKapat(id);
      setOturumlar(await api.oturumlar());
    } catch (e) { setHata(hataMetni(e)) } finally { setIslemde(false) }
  };

  const gucRozet = !ayar.sifre1 ? null
    : guc.puan >= 4 ? <span className="rozet ok">{c('güçlü')}</span>
    : guc.puan >= 2 ? <span className="rozet uyari">{c('orta')}</span>
    : <span className="rozet hata">{c('zayıf')}</span>;

  return (
    <div className="ka-ikili">
      <div>
        <div className="kagrup">
          <h6>{c('Şifre Değiştir')}</h6>
          <div className="kasat">
            <label className="ka-zorunlu">{c('Mevcut şifre')}</label>
            <input type="password" value={ayar.eskiSifre} autoComplete="current-password"
                   onChange={e => ayar.setEskiSifre(e.target.value)}
                   disabled={ayar.kaydediliyor} />
            <label className="ka-zorunlu">{c('Yeni şifre')}</label>
            <div className="kaara">
              <input type="password" value={ayar.sifre1} autoComplete="new-password"
                     onChange={e => ayar.setSifre1(e.target.value)}
                     disabled={ayar.kaydediliyor} />
              {gucRozet}
            </div>
            <label className="ka-zorunlu">{c('Yeni şifre (tekrar)')}</label>
            <div className="kaara">
              <input type="password" value={ayar.sifre2} autoComplete="new-password"
                     onChange={e => ayar.setSifre2(e.target.value)}
                     disabled={ayar.kaydediliyor} />
              {esit && <span className="kaok">✓</span>}
            </div>
          </div>
          {ayar.sifre1 && (
            <div className="ka-guc-kutu">
              <div className="ka-guc"><i style={{ width: `${guc.puan * 25}%` }} className={guc.puan >= 4 ? 'ok' : guc.puan >= 2 ? 'orta' : 'zayif'} /></div>
              <div className="sonuk ka-kurallar">
                {guc.kurallar.map(k => <span key={k.ad}>{k.tamam === null ? '•' : k.tamam ? '✔' : '✖'} {c(k.ad)}</span>)}
                <span>{esit ? '✔' : '✖'} {c('Tekrar eşleşiyor')}</span>
              </div>
            </div>
          )}
          {ayar.mesaj && <div className="kauyari">{ayar.mesaj}</div>}
          <div className="kanot">
            {c('Şifre boş bırakılırsa değiştirilmez. Şifre değişince tüm oturumlar kapanır; yeni şifreyle tekrar girilir. Şifreyi değiştirmenin sebebi çoğu zaman “başkası biliyor olabilir”dir; eski oturumun açık kalması değişikliği anlamsız kılardı.')}
          </div>
        </div>

      </div>

      <div>
        {/* AÇIK OTURUMLAR: gerçek veri (public.oturum). Kişinin kendi denetimi -
            tanımadığı cihazı yöneticiyi beklemeden kapatabilir. */}
        <div className="kagrup">
          <h6>{c('Açık Oturumlar')}
            <span>{oturumlar ? `${oturumlar.length} ${c('cihaz')}` : ''}</span></h6>
          <table className="grid">
            <thead>
              <tr><th>{c('Cihaz')}</th><th>{c('Yer / IP')}</th><th>{c('Son işlem')}</th><th></th></tr>
            </thead>
            <tbody>
              {!oturumlar && <tr><td colSpan={4}>{c('Yükleniyor…')}</td></tr>}
              {oturumlar?.length === 0 && (
                <tr><td colSpan={4} className="bos">{c('Açık oturum yok.')}</td></tr>
              )}
              {oturumlar?.map(o => (
                <tr key={o.id} className={o.buCihaz ? 'ka-bu' : ''}>
                  <td>{cihazAdi(o.istemci)}
                    {o.buCihaz && <span className="rozet ok" style={{ marginLeft: 6 }}>
                      {c('bu cihaz')}</span>}</td>
                  <td className="sonuk">{[o.sube, o.ip].filter(Boolean).join(' · ') || '—'}</td>
                  <td className="sonuk">{tarihSaat(o.sonKullanim)}</td>
                  <td style={{ textAlign: 'right' }}>
                    {o.buCihaz ? <span className="sonuk">—</span> : (
                      <button className="d" disabled={islemde}
                              onClick={() => void kapat(o.id)}>{c('Kapat')}</button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="kanot">
            {c('Tanımadığınız bir satır görürseniz önce oturumu kapatın, sonra şifrenizi değiştirin. “Bu cihaz” işareti IP ve tarayıcı eşleşmesinden çıkarılır.')}
          </div>
        </div>
        <div className="kagrup">
          <h6>{c('Son Hareketler')}</h6>
          <table className="grid">
            <thead><tr><th>{c('Zaman')}</th><th>{c('İşlem')}</th><th>{c('Yer')}</th></tr></thead>
            <tbody>
              {!gecmis && <tr><td colSpan={3}>{c('Yükleniyor…')}</td></tr>}
              {gecmis?.length === 0 && (
                <tr><td colSpan={3} className="bos">{c('Kayıt yok.')}</td></tr>
              )}
              {gecmis?.map((g, i) => (
                <tr key={i}>
                  <td>{tarihSaat(g.tarih)}</td>
                  <td>{c('Giriş')} {g.basarili
                        ? <span className="rozet ok">{c('başarılı')}</span>
                        : <span className="rozet hata">{g.sebep || c('başarısız')}</span>}</td>
                  <td className="sonuk">{g.ip || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="kanot">
            {c('Hatalı giriş denemeleri de yazılır — başarılı girişleri görmek, birinin denediğini göstermez.')}
          </div>
        </div>
        {hata && <div className="kauyari">{hata}</div>}
      </div>
    </div>
  );
}


/* ====================================================== BİLDİRİMLER ==== */

function Bildirimler({ c, iskontoTavani }: { c(m: string): string; iskontoTavani: number }) {
  const [t, setT] = useState<BildirimTercihi>(() => bildirimOku());
  const [izin, setIzin] = useState<NotificationPermission>(
    typeof Notification === 'undefined' ? 'denied' : Notification.permission);
  const [hata, setHata] = useState('');
  const [deneme, setDeneme] = useState('');
  const liste = olaylar(iskontoTavani);
  const kilitliler = liste.filter(o => o.kilit);

  const yaz = async (yeni: BildirimTercihi) => {
    setT(yeni); setHata('');
    try { await bildirimKaydet(yeni) } catch (e) { setHata(hataMetni(e)) }
  };

  const degistir = async (kod: string, kanal: 'zil' | 'masaustu', deger: boolean) => {
    // Masaustu ACILIRKEN tarayici izni istenir: izin vermeden isaretlemek,
    //   kullaniciya calisacakmis gibi gorunup hic bildirim gondermezdi.
    if (kanal === 'masaustu' && deger) {
      const sonuc = await masaustuIzniIste();
      setIzin(sonuc);
      if (sonuc !== 'granted') {
        setHata(c('Tarayıcı bildirim izni verilmedi - masaüstü bildirimi açılamadı.'));
        return;
      }
    }
    const mevcut = t.olaylar[kod] ?? { zil: true, masaustu: false };
    await yaz({ ...t, olaylar: { ...t.olaylar, [kod]: { ...mevcut, [kanal]: deger } } });
  };

  const denemeGonder = async () => {
    setDeneme('');
    const sonuc = await masaustuIzniIste();
    setIzin(sonuc);
    if (sonuc !== 'granted') { setDeneme(c('Tarayıcı izni yok — masaüstü bildirimi çıkmaz.')); return }
    setDeneme(denemeBildirimi(c('Gentegre AI deneme bildirimi'), c('Bildirimler çalışıyor.'))
      ? c('Deneme bildirimi gönderildi.') : c('Tarayıcı bildirimi göstermedi.'));
  };

  return (
    <>
      <div className="kagrup">
        <h6>{c('Neyi nereden alayım?')} <span>{c('yalnız yetkiniz olan olaylar listelenir')}</span></h6>
        {liste.length === 0 ? (
          <div className="kanot">{c('Şu an size düşen bir bildirim türü yok.')}</div>
        ) : (
          <table className="grid">
            <thead>
              <tr>
                <th>{c('Olay')}</th>
                <th style={{ textAlign: 'center' }}>🔔 {c('Zil')}</th>
                <th style={{ textAlign: 'center' }}>🖥 {c('Masaüstü')}</th>
                <th>{c('Not')}</th>
              </tr>
            </thead>
            <tbody>
              {liste.map(o => {
                const d = t.olaylar[o.kod] ?? { zil: true, masaustu: false };
                return (
                  <tr key={o.kod}>
                    <td><b>{c(o.ad)}</b></td>
                    <td style={{ textAlign: 'center' }}>
                      <input type="checkbox" checked={o.kilit || d.zil} disabled={o.kilit}
                             title={o.kilit ? c('Kapatılamaz') : undefined}
                             onChange={e => void degistir(o.kod, 'zil', e.target.checked)} />
                    </td>
                    <td style={{ textAlign: 'center' }}>
                      <input type="checkbox" checked={d.masaustu} disabled={o.kilit}
                             onChange={e => void degistir(o.kod, 'masaustu', e.target.checked)} />
                    </td>
                    <td className="sonuk">{c(o.aciklama)}{o.kilit && <> · <span className="rozet hata">{c('kapatılamaz')}</span></>}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
        <div className="kanot">
          {c('Liste yetkinize göre kurulur: onaylama yetkiniz yoksa iskonto satırı hiç görünmez. E-posta, SMS ve mobil kanalları henüz yok — olmayan bir kanalın kutusunu çizmek “haber verilecek” demek olurdu.')}
          {izin === 'denied' && (
            <> <b>{c('Tarayıcı bildirim izni reddedilmiş')}</b> — {c('masaüstü bildirimi için tarayıcı ayarından izin verilmeli.')}</>
          )}
        </div>
        {hata && <div className="kauyari">{hata}</div>}
      </div>

      <div className="ka-ikili">
        <div className="kagrup">
          <h6>{c('Sessiz Saatler')}</h6>
          <div className="kasat">
            <label>{c('Sessiz saat')}</label>
            <div className="kaara">
              <input type="checkbox" checked={t.sessiz.acik}
                     onChange={e => void yaz({ ...t, sessiz: { ...t.sessiz, acik: e.target.checked } })} />
              <input type="time" value={t.sessiz.bas} disabled={!t.sessiz.acik}
                     onChange={e => void yaz({ ...t, sessiz: { ...t.sessiz, bas: e.target.value } })} />
              <span>—</span>
              <input type="time" value={t.sessiz.bit} disabled={!t.sessiz.acik}
                     onChange={e => void yaz({ ...t, sessiz: { ...t.sessiz, bit: e.target.value } })} />
            </div>
            <label>{c('Hafta sonu')}</label>
            <select value={t.sessiz.haftaSonu ? '1' : '0'}
                    onChange={e => void yaz({ ...t, sessiz: { ...t.sessiz, haftaSonu: e.target.value === '1' } })}>
              <option value="0">{c('Hafta içi gibi')}</option>
              <option value="1">{c('Tüm gün sessiz')}</option>
            </select>
            <label>{c('İstisna')}</label>
            <div className="kaara">
              <input value={kilitliler.length ? kilitliler.map(o => c(o.ad)).join(' · ') : c('yok')} disabled />
              {kilitliler.length > 0 && <span className="rozet hata">{c('her zaman çalar')}</span>}
            </div>
          </div>
          <div className="kanot">
            {c('Sessiz saatte bildirim silinmez, ertelenir — masaüstü bildirimi çıkmaz, zil listesinde birikmiş olarak durur.')}
          </div>
        </div>

        <div className="kagrup">
          <h6>{c('Masaüstü Bildirimi')}</h6>
          <div className="ka-liste">
            <div className="ka-satir"><span>{c('Tarayıcı izni')}</span>
              <b><span className={`rozet ${izin === 'granted' ? 'ok' : izin === 'denied' ? 'hata' : 'gri'}`}>
                {izin === 'granted' ? c('verildi') : izin === 'denied' ? c('reddedildi') : c('sorulmadı')}</span></b></div>
            <div className="ka-satir"><span>{c('Test')}</span>
              <button type="button" className="d" onClick={() => void denemeGonder()}>🔔 {c('Deneme bildirimi gönder')}</button></div>
            {deneme && <div className="ka-satir"><span></span><b className="sonuk">{deneme}</b></div>}
          </div>
          <div className="kanot">
            {c('Deneme bildirimi düğmesi bilerek var: “bildirim gelmiyor” şikâyetinin yarısı tarayıcının kendi izin ayarındadır, kurulumda test edilebilmeli.')}
          </div>
        </div>
      </div>
    </>
  );
}
