import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { AcikOturum, GirisDenemesi, HesapBilgisi } from '../api/uclar/kimlik';
import { hataMetni } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { TEMA_ADI, TEMA_IKON, temaUygula, type Tema } from './tema';
import { tarihSaat } from './bicim';
import { DILLER } from './diller';
import { telefonAyir, telefonBirlestir, ulkeEtiketi, ULKE_KODLARI } from './telefon';
import {
  gorunumOku, gorunumKaydet, LISTE_SATIR_SECENEKLERI,
  type GorunumTercihi, type Yogunluk,
} from './gorunum';
import {
  bildirimOku, bildirimKaydet, olaylar, masaustuIzniIste,
  type BildirimTercihi,
} from './bildirimTercihi';

/**
 * KULLANICI AYARLARI (669) — üst şeritteki avatardan açılan pencere.
 * Tasarım: `Ekranlar/Ayarlar/kullanici_ayarlari.html`.
 *
 * Dört sekme: Hesabım · Görünüm · Güvenlik · Bildirimler. Önceki tek sayfalık
 * pencere kimlik + dil/tema + şifre taşıyordu; eksik olan üç şey eklendi -
 * ROLLER (665), AÇIK OTURUMLAR ve BİLDİRİM TERCİHLERİ.
 *
 * İKİ KURAL:
 *  · KİŞİSEL ≠ KURUMSAL. Bu pencere yalnız kendi hesabı değiştirir; kurumun
 *    ayarları Yönetim altında ve ayrı yetkide kalır.
 *  · OLMAYAN ÖZELLİK ÇİZİLMEZ. Mockup'taki 2 adımlı doğrulama bölümü burada
 *    YOK: sunucuda TOTP akışı yok, "Aç" düğmesi koymak yalan olurdu. Şemadaki
 *    `totp_aktif` yalnız DURUM olarak okunur.
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
  const { aksiyonDegeri } = useOturum();
  const [sekme, setSekme] = useState<'hesap' | 'gorunum' | 'guvenlik' | 'bildirim'>('hesap');

  if (!ayar.acik) return null;

  return (
    <div className="kaperde"
         onMouseDown={e => { if (e.target === e.currentTarget) ayar.kapat() }}>
      <div className="kawin kullanici-ayarlari" role="dialog" aria-label="Kullanıcı Ayarları">
        <div className="kabas">
          <span>👤 {c('Kullanıcı Ayarları')}</span>
          <span className="kapt">{c('Değişiklikler yalnız kendi hesabınızı etkiler')}</span>
        </div>

        <div className="ka-sekmeler" role="tablist">
          {([
            ['hesap', 'Hesabım'],
            ['gorunum', 'Görünüm'],
            ['guvenlik', 'Güvenlik'],
            ['bildirim', 'Bildirimler'],
          ] as const).map(([k, ad]) => (
            <button key={k} type="button" role="tab" aria-selected={sekme === k}
                    className={`ka-sekme${sekme === k ? ' on' : ''}`}
                    onClick={() => setSekme(k)}>
              {c(ad)}
            </button>
          ))}
        </div>

        <div className="kagov">
          {sekme === 'hesap' && <Hesabim c={c} />}
          {sekme === 'gorunum' && (
            <Gorunum c={c} tema={tema} setTema={setTema}
                     seciliDil={ayar.seciliDil} setSeciliDil={ayar.setSeciliDil}
                     kilitli={ayar.kaydediliyor} />
          )}
          {sekme === 'guvenlik' && <Guvenlik ayar={ayar} c={c} />}
          {sekme === 'bildirim' && (
            <Bildirimler c={c} iskontoTavani={aksiyonDegeri('basvuru.iskonto')} />
          )}
        </div>

        <div className="kaalt-durum">{DURUM[sekme]}</div>

        {/* STANDART ALT SERIT: solda Iptal, sagda birincil Kaydet. Kaydet
            YALNIZ dil ve sifreyi gonderir - gorunum/bildirim tercihleri kendi
            sekmelerinde ANINDA kaydedilir (tek kutucuk icin pencereyi
            kapatmak gerekmesin). */}
        <div className="kaalt">
          <button className="d kapat-dugmesi" onClick={ayar.kapat}
                  disabled={ayar.kaydediliyor}>{c('İptal')}</button>
          <button className="d bir" onClick={() => void ayar.tamam()}
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
  hesap: 'Dil ve şifre Kaydet ile yazılır.',
  gorunum: 'Tema ve yoğunluk anında uygulanır; dil Kaydet ile yazılır.',
  guvenlik: 'Şifre değişince bu oturum dışındaki tüm oturumlar kapanır.',
  bildirim: 'Bildirim tercihleri anında kaydedilir.',
};

/* ========================================================== HESABIM ==== */

function Hesabim({ c }: { c(m: string): string }) {
  const { kullanici } = useOturum();
  const [h, setH] = useState<HesapBilgisi | null>(null);
  const [eposta, setEposta] = useState('');
  // Telefon EKRANDA ikiye ayrilir (kullanici: "+90 ayri olsun"); saklama
  //   bicimi tek metin olarak kalir (bkz. telefon.ts).
  const [ulke, setUlke] = useState('+90');
  const [numara, setNumara] = useState('');
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [islemde, setIslemde] = useState(false);

  useEffect(() => {
    let iptal = false;
    api.hesabim()
      .then(y => {
        if (iptal) return;
        setH(y); setEposta(y.eposta);
        const t = telefonAyir(y.cepTel);
        setUlke(t.ulke); setNumara(t.numara);
      })
      .catch(e => { if (!iptal) setHata(hataMetni(e)) });
    return () => { iptal = true };
  }, []);

  const kaydet = async () => {
    setIslemde(true); setHata(''); setBilgi('');
    try {
      await api.iletisimKaydet(eposta.trim(), cepTel);
      setBilgi(c('İletişim bilgisi güncellendi.'));
    } catch (e) { setHata(hataMetni(e)) } finally { setIslemde(false) }
  };

  const cepTel = telefonBirlestir({ ulke, numara });
  const degisti = !!h && (eposta.trim() !== h.eposta || cepTel !== h.cepTel);

  return (
    <>
      <div className="kagrup">
        <h6>{c('Kimlik')} <span>{c('ad ve görev personel kartından gelir')}</span></h6>
        <div className="kasat">
          <label>{c('Kullanıcı Adı')}</label>
          <input value={h?.unvan || kullanici?.ad || ''} disabled />
          <label>{c('Görev')}</label><input value={h?.gorev ?? ''} disabled />
          <label>{c('Kullanıcı Kodu')}</label><input value={kullanici?.kod ?? ''} disabled />
          <label>{c('Çalışılan Şube')}</label>
          <input value={kullanici?.subeler.find(s => s.id === kullanici?.subeId)?.ad ?? '-'} disabled />
        </div>
      </div>

      <div className="kagrup">
        <h6>{c('İletişim')} <span>{c('bunları siz değiştirirsiniz')}</span></h6>
        <div className="kasat">
          <label>{c('E-posta')}</label>
          <input value={eposta} onChange={e => setEposta(e.target.value)}
                 disabled={islemde} autoComplete="email" />
          <label>{c('Cep Telefonu')}</label>
          <div className="kaara">
            {/* Ulke kodu AYRI kutu: numara alanina her seferinde "+90" yazmak
                hem zaman kaybi hem de "0090"/"0"/"+90" karisikligi kaynagiydi. */}
            <select className="ka-ulke" value={ulke} disabled={islemde}
                    onChange={e => setUlke(e.target.value)}>
              {ULKE_KODLARI.map(u => (
                <option key={u.kod} value={u.kod} title={u.ad}>{ulkeEtiketi(u.kod)}</option>
              ))}
            </select>
            <input value={numara} disabled={islemde} autoComplete="tel-national"
                   placeholder="555 123 45 67"
                   /* Yapistirlan "+90 555…" / "0532…" kendiliginden ayrisir. */
                   onChange={e => {
                     const t = telefonAyir(e.target.value);
                     if (/^\s*(\+|00)/.test(e.target.value)) { setUlke(t.ulke); setNumara(t.numara) }
                     else setNumara(e.target.value);
                   }} />
          </div>
        </div>
        <div className="ka-dugmeler">
          <button className="d" disabled={!degisti || islemde} onClick={() => void kaydet()}>
            {islemde ? c('Kaydediliyor…') : c('İletişim Bilgisini Kaydet')}
          </button>
        </div>
        {hata && <div className="kauyari">{hata}</div>}
        {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}
      </div>

      {/* ROLLER (665): salt okunur. "Neden bu ekranı açamıyorum / neden onay
          bana düşmüyor" sorusu en çok burada sorulur - cevabı yetki matrisine
          girmeden okunabilmeli. Değiştirmek yöneticinin işidir. */}
      <div className="kagrup">
        <h6>{c('Rollerim')} <span>{c('salt okunur')}</span></h6>
        <div className="ka-liste">
          <div className="ka-satir"><span>{c('Ana rol')}</span>
            <b>{h?.anaRol || kullanici?.rolAdi || '-'}</b></div>
          <div className="ka-satir"><span>{c('Ek roller')}</span>
            <b>{h && h.ekRoller.length > 0
                 ? h.ekRoller.map(r => <span key={r} className="rozet mor">{r}</span>)
                 : <span className="sonuk">{c('yok')}</span>}</b></div>
          <div className="ka-satir"><span>{c('Şubeler')}</span>
            <b>{(kullanici?.subeler ?? []).map(s => s.ad).join(' · ') || '-'}</b></div>
        </div>
        <div className="kanot">
          {c('Yetki, ana rol ile ek rollerin birleşimidir; sayısal sınırlarda en yüksek değer geçerlidir. Rol değişimi yöneticinin işidir.')}
        </div>
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
    <>
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
        <div className="kasat">
          <label>{c('Dil')}</label>
          <select value={seciliDil} onChange={e => setSeciliDil(Number(e.target.value))}
                  disabled={kilitli}>
            {DILLER.map(d => <option key={d.deger} value={d.deger}>{d.ad}</option>)}
          </select>
        </div>
        <div className="kanot">{c('Dil Kaydet ile yazılır; kişi hangi cihazdan girerse girsin kendi dilini bulur.')}</div>
      </div>

      <div className="kagrup">
        <h6>{c('Yoğunluk')} <span>{c('anında uygulanır')}</span></h6>
        <div className="ka-secenekler">
          {([['sikisik', '≡', 'Sıkışık'], ['normal', '☰', 'Normal'],
             ['ferah', '☷', 'Ferah']] as const).map(([k, ik, ad]) => (
            <button key={k} type="button"
                    className={`ka-sec${g.yogunluk === k ? ' on' : ''}`}
                    onClick={() => void yaz({ ...g, yogunluk: k as Yogunluk })}>
              <span className="ikon">{ik}</span>{c(ad)}
            </button>
          ))}
        </div>
        <div className="kasat" style={{ marginTop: 8 }}>
          <label>{c('Liste satır sayısı')}</label>
          <select value={g.listeSatir}
                  onChange={e => void yaz({ ...g, listeSatir: Number(e.target.value) })}>
            {LISTE_SATIR_SECENEKLERI.map(n => (
              <option key={n} value={n}>{n} {c('kayıt / sayfa')}</option>
            ))}
          </select>
        </div>
        <div className="kanot">
          {c('“Sıkışık” aynı ekrana daha çok satır sığdırır. Liste satır sayısı listelerin AÇILIŞ değeridir; tek bir listede geçici olarak değiştirmek bu ayarı bozmaz.')}
        </div>
        {hata && <div className="kauyari">{hata}</div>}
      </div>
    </>
  );
}

/* ========================================================= GÜVENLİK ==== */

function Guvenlik({ ayar, c }: {
  ayar: {
    eskiSifre: string; setEskiSifre(s: string): void;
    sifre1: string; setSifre1(s: string): void;
    sifre2: string; setSifre2(s: string): void;
    mesaj: string; kaydediliyor: boolean;
  };
  c(m: string): string;
}) {
  const [oturumlar, setOturumlar] = useState<AcikOturum[] | null>(null);
  const [gecmis, setGecmis] = useState<GirisDenemesi[] | null>(null);
  const [hata, setHata] = useState('');
  const [islemde, setIslemde] = useState(false);

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

  return (
    <>
      <div className="kagrup">
        <h6>{c('Şifre')}</h6>
        <div className="kasat">
          <label>{c('Mevcut Şifre')}</label>
          <input type="password" value={ayar.eskiSifre} autoComplete="current-password"
                 onChange={e => ayar.setEskiSifre(e.target.value)}
                 disabled={ayar.kaydediliyor} />
          <label>{c('Yeni Şifre')}</label>
          <div className="kaara">
            <input type="password" value={ayar.sifre1} autoComplete="new-password"
                   onChange={e => ayar.setSifre1(e.target.value)}
                   disabled={ayar.kaydediliyor} />
            {ayar.sifre1 && ayar.sifre1 === ayar.sifre2 && <span className="kaok">✓</span>}
          </div>
          <label>{c('Yeni Şifre (Tekrar)')}</label>
          <div className="kaara">
            <input type="password" value={ayar.sifre2} autoComplete="new-password"
                   onChange={e => ayar.setSifre2(e.target.value)}
                   disabled={ayar.kaydediliyor} />
            {ayar.sifre2 && ayar.sifre1 === ayar.sifre2 && <span className="kaok">✓</span>}
          </div>
        </div>
        {ayar.mesaj && <div className="kauyari">{ayar.mesaj}</div>}
        <div className="kanot">
          {c('Şifre boş bırakılırsa değiştirilmez. Şifre değişince oturum kapanır; yeni şifreyle tekrar girilir.')}
        </div>
      </div>

      {/* AÇIK OTURUMLAR: gerçek veri (public.oturum). Kişinin kendi denetimi -
          tanımadığı cihazı yöneticiyi beklemeden kapatabilir. */}
      <div className="kagrup">
        <h6>{c('Açık Oturumlar')}
          <span>{oturumlar ? `${oturumlar.length} ${c('cihaz')}` : ''}</span></h6>
        <table className="grid">
          <thead>
            <tr><th>{c('Cihaz')}</th><th>{c('IP')}</th><th>{c('Son kullanım')}</th><th></th></tr>
          </thead>
          <tbody>
            {!oturumlar && <tr><td colSpan={4}>{c('Yükleniyor…')}</td></tr>}
            {oturumlar?.length === 0 && (
              <tr><td colSpan={4} className="bos">{c('Açık oturum yok.')}</td></tr>
            )}
            {oturumlar?.map(o => (
              <tr key={o.id}>
                <td>{cihazAdi(o.istemci)}
                  {o.buCihaz && <span className="rozet ok" style={{ marginLeft: 6 }}>
                    {c('bu tarayıcı')}</span>}</td>
                <td className="sonuk">{o.ip || '—'}</td>
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
          {c('Tanımadığınız bir satır görürseniz önce oturumu kapatın, sonra şifrenizi değiştirin. “Bu tarayıcı” işareti IP ve tarayıcı eşleşmesinden çıkarılır.')}
        </div>
      </div>

      <div className="kagrup">
        <h6>{c('Son Giriş Hareketleri')}</h6>
        <table className="grid">
          <thead><tr><th>{c('Zaman')}</th><th>{c('Sonuç')}</th><th>{c('IP')}</th></tr></thead>
          <tbody>
            {!gecmis && <tr><td colSpan={3}>{c('Yükleniyor…')}</td></tr>}
            {gecmis?.length === 0 && (
              <tr><td colSpan={3} className="bos">{c('Kayıt yok.')}</td></tr>
            )}
            {gecmis?.map((g, i) => (
              <tr key={i}>
                <td>{tarihSaat(g.tarih)}</td>
                <td>{g.basarili
                      ? <span className="rozet ok">{c('başarılı')}</span>
                      : <span className="rozet hata">{g.sebep || c('başarısız')}</span>}</td>
                <td className="sonuk">{g.ip || '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="kanot">
          {c('Başarısız denemeler de yazılır — yalnız başarılı girişleri göstermek, birinin denediğini gizlerdi.')}
        </div>
      </div>
      {hata && <div className="kauyari">{hata}</div>}
    </>
  );
}

/** "Mozilla/5.0 (Windows NT 10.0…) … Chrome/…" → "Chrome · Windows". */
function cihazAdi(istemci: string): string {
  if (!istemci) return 'Bilinmeyen cihaz';
  const tarayici = /Edg\//.test(istemci) ? 'Edge'
    : /Chrome\//.test(istemci) ? 'Chrome'
    : /Firefox\//.test(istemci) ? 'Firefox'
    : /Safari\//.test(istemci) ? 'Safari' : 'Tarayıcı';
  const isletim = /Android/.test(istemci) ? 'Android'
    : /iPhone|iPad/.test(istemci) ? 'iOS'
    : /Windows/.test(istemci) ? 'Windows'
    : /Mac OS/.test(istemci) ? 'macOS'
    : /Linux/.test(istemci) ? 'Linux' : '';
  return isletim ? `${tarayici} · ${isletim}` : tarayici;
}

/* ====================================================== BİLDİRİMLER ==== */

function Bildirimler({ c, iskontoTavani }: { c(m: string): string; iskontoTavani: number }) {
  const [t, setT] = useState<BildirimTercihi>(() => bildirimOku());
  const [izin, setIzin] = useState<NotificationPermission>(
    typeof Notification === 'undefined' ? 'denied' : Notification.permission);
  const [hata, setHata] = useState('');
  const liste = olaylar(iskontoTavani);

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

  return (
    <>
      <div className="kagrup">
        <h6>{c('Neyi nereden alayım?')} <span>{c('yalnız yetkiniz olan olaylar')}</span></h6>
        {liste.length === 0 ? (
          <div className="kanot">{c('Şu an size düşen bir bildirim türü yok.')}</div>
        ) : (
          <table className="grid">
            <thead>
              <tr>
                <th>{c('Olay')}</th>
                <th style={{ textAlign: 'center' }}>🔔 {c('Zil')}</th>
                <th style={{ textAlign: 'center' }}>🖥 {c('Masaüstü')}</th>
              </tr>
            </thead>
            <tbody>
              {liste.map(o => {
                const d = t.olaylar[o.kod] ?? { zil: true, masaustu: false };
                return (
                  <tr key={o.kod}>
                    <td><b>{c(o.ad)}</b>
                      <div className="sonuk">{c(o.aciklama)}</div></td>
                    <td style={{ textAlign: 'center' }}>
                      <input type="checkbox" checked={d.zil} disabled={o.kilit}
                             onChange={e => void degistir(o.kod, 'zil', e.target.checked)} />
                    </td>
                    <td style={{ textAlign: 'center' }}>
                      <input type="checkbox" checked={d.masaustu} disabled={o.kilit}
                             onChange={e => void degistir(o.kod, 'masaustu', e.target.checked)} />
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
        <div className="kanot">
          {c('Liste yetkinize göre kurulur: onaylama yetkiniz yoksa iskonto satırı hiç görünmez. E-posta ve SMS kanalları henüz yok - olmayan bir kanalın kutusunu çizmek “haber verilecek” demek olurdu.')}
          {izin === 'denied' && (
            <> <b>{c('Tarayıcı bildirim izni reddedilmiş')}</b> — {c('masaüstü bildirimi için tarayıcı ayarından izin verilmeli.')}</>
          )}
        </div>
        {hata && <div className="kauyari">{hata}</div>}
      </div>

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
        </div>
        <div className="kanot">
          {c('Sessiz saatte masaüstü bildirimi çıkmaz; bildirim SİLİNMEZ - zil listesinde durur, sonra görülür.')}
        </div>
      </div>
    </>
  );
}
