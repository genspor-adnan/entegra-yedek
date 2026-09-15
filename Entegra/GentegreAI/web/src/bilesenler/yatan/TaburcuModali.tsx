import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type {
  CikisIlaci, CikisKontrolMaddesi, EpikrizYaniti, IcmalYaniti, YatisOzeti,
} from '../../api/uclar/yatan';
import { Modal } from '../Modal';
import { TarafArama } from '../TarafArama';
import { mesaj } from '../mesaj';
import { paraYaz } from '../bicim';

/**
 * TABURCU VE EPİKRİZ — mockup `Ekranlar/Yatan/taburcu_epikriz.html`.
 *
 * <b>Taburcu tek düğme değil, KAPANIŞTIR:</b> klinik (epikriz), idari (çıkış
 * şekli, kontrol randevusu) ve mali (icmal) üç işi birden bitirir. Mockup'ın
 * dört sekmesi de bu yüzden burada: üçünü ayrı ekrana bölmek, taburcuyu
 * "düğmeye bas, gerisini birileri halletsin" hâline getirirdi.
 *
 * <b>Çıkış kontrolü iki kademeli:</b> ENGEL (sonuç bekleyen tetkik, imzasız
 * sözel order, yazılmamış epikriz) taburcuyu durdurur; UYARI hekim kararıyla
 * geçilir. Hepsini engel yapmak hekimi sistemi aşmaya iter, hepsini uyarı
 * yapmak kontrolü süse çevirir.
 *
 * <b>Sonuç bekleyen tetkik varsa takip hekimi ZORUNLU:</b> hasta çıkınca
 * bekleyen sonuç çalışma listesinden de düşer — sahipsiz kalan sonuç,
 * bulunmamış sonuçtur.
 *
 * <b>Epikriz taslağı yatış boyunca birikir</b>, tetkik özeti order'lardan
 * derlenir ama hekim düzenlemeden epikrize girmiş sayılmaz.
 *
 * <b>Çıkış reçetesi evde kullandığı ilaçlarla birlikte çıkar:</b> yalnız
 * yenileri göstermek, hastanın kendi ilacını kesip kesmeyeceğini belirsiz
 * bırakır.
 */

const SEKMELER = [
  { kod: 'kontrol', ad: 'Çıkış Kontrolü' },
  { kod: 'epikriz', ad: 'Epikriz' },
  { kod: 'recete',  ad: 'Çıkış Reçetesi & Kontrol' },
  { kod: 'mali',    ad: 'Mali Kapanış' },
] as const;

const ILAC_KAYNAK: Record<number, string> = {
  1: 'yatış tedavisinin devamı', 2: 'yeni', 3: 'evde kullandığı',
};

interface KodDeger { deger: number; ad: string }

export function TaburcuModali({ yatisId, onKapat, onTamam }: {
  yatisId: number;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [sekme, setSekme] = useState<string>('kontrol');
  const [ozet, setOzet] = useState<YatisOzeti | null>(null);
  const [maddeler, setMaddeler] = useState<CikisKontrolMaddesi[]>([]);
  const [sekiller, setSekiller] = useState<KodDeger[]>([]);
  const [cikisSekli, setCikisSekli] = useState(1);
  const [taniKodu, setTaniKodu] = useState('');
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);

  // Sonucu takip edecek hekim (mockup: taburcu onay penceresi).
  const [takipHekimId, setTakipHekimId] = useState<number | null>(null);
  const [takipHekimAd, setTakipHekimAd] = useState('');
  const [hekimArama, setHekimArama] = useState(false);

  // Epikriz ve çıkış reçetesi.
  const [epi, setEpi] = useState<EpikrizYaniti | null>(null);
  const [sikayet, setSikayet] = useState('');
  const [hikaye, setHikaye] = useState('');
  const [bulgular, setBulgular] = useState('');
  const [tetkikOzet, setTetkikOzet] = useState('');
  const [tedavi, setTedavi] = useState('');
  const [seyir, setSeyir] = useState('');
  const [oneriler, setOneriler] = useState('');
  const [kontrolTarihi, setKontrolTarihi] = useState('');
  const [ilaclar, setIlaclar] = useState<CikisIlaci[]>([]);

  const [icmal, setIcmal] = useState<IcmalYaniti | null>(null);

  useEffect(() => {
    void (async () => {
      try {
        const [o, k, s] = await Promise.all([
          api.yatisOzeti(yatisId),
          api.yatisCikisKontrol(yatisId),
          api.kodListe('yatan.cikis_sekli'),
        ]);
        setOzet(o);
        setMaddeler(k.maddeler);
        setSekiller(s.degerler.filter(d => d.aktif === 1));
        setTaniKodu(o.ozet.cikisTani || o.ozet.yatisTani || '');
      } catch (h) { setHata(hataMetni(h)) }

      try {
        const e = await api.epikriz(yatisId);
        setEpi(e);
        if (e.epikriz) {
          setSikayet(e.epikriz.sikayet); setHikaye(e.epikriz.hikaye);
          setBulgular(e.epikriz.bulgular); setTedavi(e.epikriz.tedavi);
          setSeyir(e.epikriz.seyir); setOneriler(e.epikriz.oneriler);
          // TASLAK KAYDEDİLENİN ÜSTÜNE YAZMAZ: hekim düzelttiyse onunki geçerli.
          setTetkikOzet(e.epikriz.tetkikOzet || e.tetkikTaslak);
          setKontrolTarihi(e.epikriz.kontrolTarihi?.slice(0, 10) ?? '');
          try {
            const j = JSON.parse(e.epikriz.cikisIlaclari || '[]') as CikisIlaci[];
            if (Array.isArray(j) && j.length > 0) setIlaclar(j);
          } catch { /* bozuk jsonb ekranı düşürmesin */ }
        } else {
          setTetkikOzet(e.tetkikTaslak);
        }
      } catch { /* epikriz yoksa boş açılır */ }

      try { setIcmal(await api.yatisIcmal(yatisId)) } catch { /* icmal zorunlu değil */ }
    })();
  }, [yatisId]);

  const engeller = maddeler.filter(m => m.engel && !m.tamam);
  const tetkikEngeli = engeller.some(m => m.kod === 'tetkik');
  // TAKİP HEKİMİ seçilince tetkik engeli aşılır (sunucu da aynı kuralı uygular).
  const acikEngeller = engeller.filter(m => !(m.kod === 'tetkik' && takipHekimId));

  const epikrizKaydet = async () => {
    setHata('');
    setKaydediyor(true);
    try {
      await api.epikrizKaydet(yatisId, {
        sikayet, hikaye, bulgular, tetkikOzet, tedavi, seyir, oneriler,
        kontrolTarihi: kontrolTarihi || null,
        cikisIlaclari: ilaclar,
      });
      mesaj('Epikriz kaydedildi.');
      setMaddeler((await api.yatisCikisKontrol(yatisId)).maddeler);
      setEpi(await api.epikriz(yatisId));
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  const imzala = async () => {
    setHata('');
    try {
      await api.epikrizImzala(yatisId);
      mesaj('Epikriz imzalandı.');
      setEpi(await api.epikriz(yatisId));
      setMaddeler((await api.yatisCikisKontrol(yatisId)).maddeler);
    } catch (h) { setHata(hataMetni(h)) }
  };

  const taburcuEt = async () => {
    setHata('');
    if (tetkikEngeli && !takipHekimId) {
      setSekme('kontrol');
      setHata('Sonuç bekleyen tetkik var: sonucu takip edecek hekim seçilmeli.');
      return;
    }
    setKaydediyor(true);
    try {
      const y = await api.yatisTaburcu(yatisId, {
        cikisSekli, cikisTaniKodu: taniKodu, takipHekimId,
      });
      mesaj((y.durum === 5 ? 'Hasta kurum dışına sevk edildi.' : 'Hasta taburcu edildi.')
            + (y.kontrolRandevusu ? ' Kontrol randevusu açıldı.' : ''));
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  const planla = async () => {
    setHata('');
    setKaydediyor(true);
    try {
      await api.yatisTaburcuPlanla(yatisId, new Date().toISOString().slice(0, 10));
      mesaj('Taburcu planlandı — yatak panosunda "bugün çıkacak" görünür.');
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  const ilacEkle = () => setIlaclar(l => [...l, {
    ad: '', doz: '', yol: 'PO', sure: '', not: '', kaynak: 2,
  }]);
  const ilacDegistir = (i: number, alan: keyof CikisIlaci, deger: string | number) =>
    setIlaclar(l => l.map((x, j) => (j === i ? { ...x, [alan]: deger } : x)));
  const ilacSil = (i: number) => setIlaclar(l => l.filter((_, j) => j !== i));

  const o = ozet?.ozet;
  const t = icmal?.toplam;

  return (
    <>
      <TarafArama
        acik={hekimArama}
        kaynaklar={['basvuru-hekim']}
        yerTutucu="Sonucu takip edecek hekimi ara…"
        onKapat={() => setHekimArama(false)}
        onSec={s => { setTakipHekimId(s.id); setTakipHekimAd(s.unvan); setHekimArama(false) }}
      />

      <Modal baslik="🚪 Taburcu ve Epikriz"
             ustBilgi={o ? `${o.hasta} · ${o.yatak || '—'} · ${o.gun}. gün` : undefined}
             onKapat={onKapat}
             alt={
               <>
                 <button className="d onay" disabled={kaydediyor || acikEngeller.length > 0}
                         onClick={() => void taburcuEt()}>✔ Taburcu Et</button>
                 {/* PLANLAMA AYRI: hekim sabah karar verir, çıkış öğleden sonra
                     olur. Arada yatak dolu ama panoda "bugün boşalacak" görünür. */}
                 <button className="d" disabled={kaydediyor}
                         onClick={() => void planla()}>📅 Taburcu Planla</button>
                 {sekme !== 'kontrol' && sekme !== 'mali' && (
                   <button className="d" disabled={kaydediyor}
                           onClick={() => void epikrizKaydet()}>💾 Epikrizi Kaydet</button>
                 )}
                 <button className="d" onClick={onKapat}>✖ Kapat</button>
               </>
             }>
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="alan-izgara">
          <label className="alan">
            <span className="etiket zorunlu-isaret">Çıkış şekli</span>
            <select value={cikisSekli} onChange={e => setCikisSekli(Number(e.target.value))}>
              {sekiller.map(s => <option key={s.deger} value={s.deger}>{s.ad}</option>)}
            </select>
          </label>
          <label className="alan">
            <span className="etiket">Çıkış tanısı (ICD)</span>
            <input value={taniKodu} onChange={e => setTaniKodu(e.target.value)} />
          </label>
        </div>

        <div className="altpanel-sekmeler" style={{ marginTop: 8 }}>
          {SEKMELER.map(s => (
            <button key={s.kod} className={`altpanel-sekme${sekme === s.kod ? ' on' : ''}`}
                    onClick={() => setSekme(s.kod)}>
              {s.ad}
              {s.kod === 'kontrol' && acikEngeller.length > 0 && (
                <span className="rozet hata">{acikEngeller.length}</span>
              )}
              {s.kod === 'epikriz' && epi?.epikriz?.imzaDurum === 1 && (
                <span className="rozet ok">imzalı</span>
              )}
            </button>
          ))}
        </div>

        {/* ------------------------------------------------ ÇIKIŞ KONTROLÜ */}
        {sekme === 'kontrol' && (
          <>
            <div className="cikis-kontrol" style={{ marginTop: 8 }}>
              {maddeler.map(m => {
                const asildi = m.kod === 'tetkik' && !m.tamam && !!takipHekimId;
                return (
                  <div key={m.kod}
                       className={`sat2${m.tamam ? '' : asildi ? ' eksik'
                                        : m.engel ? ' engel' : ' eksik'}`}>
                    <div className="ik">{m.tamam ? '✓' : asildi ? '⚠' : m.engel ? '⛔' : '⚠'}</div>
                    <div className="ad2">
                      {m.ad}{!m.tamam && m.sayi > 0 && <> · {m.sayi}</>}
                      <small>{m.not}</small>
                    </div>
                    <div>
                      <span className={`rozet ${m.tamam ? 'ok' : asildi ? 'sari'
                                                : m.engel ? 'hata' : 'sari'}`}>
                        {m.tamam ? 'tamam'
                         : asildi ? `takip: ${takipHekimAd}`
                         : m.engel ? 'taburcuyu engeller' : 'hekim onayıyla geçilir'}
                      </span>
                    </div>
                  </div>
                );
              })}
            </div>

            {tetkikEngeli && (
              <div className="alan-izgara" style={{ marginTop: 8 }}>
                <label className="alan">
                  <span className="etiket zorunlu-isaret">Sonucu takip edecek hekim</span>
                  <span className="deger-serit">
                    <input readOnly style={{ flex: 1, minWidth: 0 }} value={takipHekimAd}
                           placeholder="Seçilmedi" onClick={() => setHekimArama(true)} />
                    <button className="d" onClick={() => setHekimArama(true)}>🔍</button>
                  </span>
                </label>
              </div>
            )}

            <div className="not">
              <b>Sonucu takip edecek hekim seçilmeden</b> sonuç bekleyen tetkikli hasta
              taburcu edilemez: hasta çıkınca bekleyen sonuç çalışma listesinden de düşer
              ve sahipsiz kalan sonuç, bulunmamış sonuçtur. Taburcuda açık order'lar
              kapanır, bekleyen dozlar "atlandı · Taburcu" olarak <b>silinmeden</b> kapanır
              ve yatak <b>temizlik bekliyor</b> durumuna düşer.
            </div>
          </>
        )}

        {/* ------------------------------------------------------- EPİKRİZ */}
        {sekme === 'epikriz' && (
          <>
            <div className="epikriz-alanlar">
              <label><span>Şikâyet ve hikâye</span>
                <textarea rows={3} value={sikayet}
                          onChange={e => setSikayet(e.target.value)} /></label>
              <label><span>Öykü / özgeçmiş</span>
                <textarea rows={2} value={hikaye}
                          onChange={e => setHikaye(e.target.value)} /></label>
              <label><span>Fizik muayene bulguları</span>
                <textarea rows={3} value={bulgular}
                          onChange={e => setBulgular(e.target.value)} /></label>
              <label>
                <span>Tetkikler
                  <i className="taslak-rozet">order'lardan derlendi · hekim düzenleyebilir</i>
                </span>
                <textarea rows={4} value={tetkikOzet}
                          onChange={e => setTetkikOzet(e.target.value)} />
              </label>
              <label><span>Tedavi ve klinik seyir</span>
                <textarea rows={4} value={tedavi}
                          onChange={e => setTedavi(e.target.value)} /></label>
              <label><span>Çıkış durumu</span>
                <textarea rows={2} value={seyir}
                          onChange={e => setSeyir(e.target.value)} /></label>
            </div>
            <div className="epikriz-alt">
              {epi?.epikriz?.imzaDurum === 1
                ? <span className="rozet ok">e-imza atıldı</span>
                : <button className="d" disabled={!epi?.epikriz}
                          onClick={() => void imzala()}>✍ Epikrizi İmzala</button>}
              <span className="sonuk">
                Taslak epikriz taburcuyu durdurmaz; imza sonradan atılabilir.
              </span>
            </div>
            <div className="not">
              <b>Epikriz yatış boyunca birikir</b>, çıkış saatinde sıfırdan yazılmaz: altı
              günlük seyri son anda hatırlamak, epikrizi "yatırıldı, tedavi edildi, taburcu
              edildi" cümlesine indirger. Tetkik özeti <b>derlenmiş bir taslaktır</b> —
              hekim düzenlemeden epikrize girmiş sayılmaz.
            </div>
          </>
        )}

        {/* --------------------------------------- ÇIKIŞ REÇETESİ & KONTROL */}
        {sekme === 'recete' && (
          <>
            <table className="izlem-tablo">
              <thead>
                <tr><th>İlaç</th><th>Doz</th><th>Yol</th><th>Süre</th>
                    <th>Kullanım notu</th><th>Kaynak</th><th /></tr>
              </thead>
              <tbody>
                {ilaclar.length === 0 && (
                  <tr><td colSpan={7} className="sonuk">
                    Çıkış reçetesi boş. Yatışta verilen ilaçlardan ekleyebilir ya da yeni
                    satır açabilirsiniz.
                  </td></tr>
                )}
                {ilaclar.map((il, i) => (
                  <tr key={i}>
                    <td><input value={il.ad} onChange={e => ilacDegistir(i, 'ad', e.target.value)} /></td>
                    <td><input style={{ width: 70 }} value={il.doz}
                               onChange={e => ilacDegistir(i, 'doz', e.target.value)} /></td>
                    <td><input style={{ width: 60 }} value={il.yol}
                               onChange={e => ilacDegistir(i, 'yol', e.target.value)} /></td>
                    <td><input style={{ width: 80 }} value={il.sure}
                               onChange={e => ilacDegistir(i, 'sure', e.target.value)} /></td>
                    <td><input value={il.not}
                               onChange={e => ilacDegistir(i, 'not', e.target.value)} /></td>
                    <td>
                      <select value={il.kaynak}
                              onChange={e => ilacDegistir(i, 'kaynak', Number(e.target.value))}>
                        {[1, 2, 3].map(k => (
                          <option key={k} value={k}>{ILAC_KAYNAK[k]}</option>
                        ))}
                      </select>
                    </td>
                    <td><button className="d" onClick={() => ilacSil(i)}>✖</button></td>
                  </tr>
                ))}
              </tbody>
            </table>

            <div className="epikriz-alt">
              <button className="d" onClick={ilacEkle}>＋ Satır Ekle</button>
              {(epi?.ilacAdaylari.length ?? 0) > 0 && (
                <button className="d" onClick={() => setIlaclar(l => [
                  ...l,
                  ...(epi?.ilacAdaylari ?? []).map(a => ({
                    ad: a.ad, doz: a.doz, yol: a.yol, sure: '',
                    not: a.siklik, kaynak: 1,
                  })),
                ])}>💊 Yatış İlaçlarını Getir ({epi?.ilacAdaylari.length})</button>
              )}
            </div>

            <div className="alan-izgara" style={{ marginTop: 8 }}>
              <label className="alan">
                <span className="etiket">Kontrol tarihi</span>
                <input type="date" value={kontrolTarihi}
                       onChange={e => setKontrolTarihi(e.target.value)} />
              </label>
              <label className="alan" style={{ gridColumn: '1 / -1' }}>
                <span className="etiket">Öneriler</span>
                <input value={oneriler} onChange={e => setOneriler(e.target.value)}
                       placeholder="örn. bol sıvı, ateş tekrarında acile başvuru" />
              </label>
            </div>

            <div className="not">
              Çıkış reçetesi <b>evde kullandığı ilaçlarla birlikte</b> çıkar: yalnız yeni
              yazılanları göstermek, hastanın kendi ilacını kesip kesmeyeceğini belirsiz
              bırakır. <b>Kontrol randevusu taburcuyla birlikte açılır</b> — "on gün sonra
              gelin" denip randevu verilmeyen hastanın yarısı gelmez.
            </div>
          </>
        )}

        {/* -------------------------------------------------- MALİ KAPANIŞ */}
        {sekme === 'mali' && (
          <>
            {t ? (
              <>
                <div className="kagrup">
                  <h6>Toplam <span>hizmet icmalinden</span></h6>
                  <div className="ic">
                    <div className="sat"><span>Hizmet toplamı</span>
                      <b>{paraYaz(t.hizmet)}</b></div>
                    <div className="sat"><span>Kurum payı</span>
                      <b>{paraYaz(t.kurum)}
                        <span className="sonuk"> {t.kurumVar
                          ? (t.provizyonVar ? '· provizyonlu' : '· provizyon yok')
                          : '· ödeyen kurum yok'}</span></b></div>
                    <div className="sat"><span>Hasta payı</span>
                      <b>{paraYaz(t.hasta)}</b></div>
                    <div className="sat"><span>Faturalanmamış</span>
                      <b>{paraYaz(t.faturalanmamis)}
                        {t.faturalanmamis > 0 && (
                          <span className="rozet sari"> faturaya alınmalı</span>
                        )}</b></div>
                  </div>
                </div>
                <div className="kagrup">
                  <h6>Kapanış adımları</h6>
                  <div className="ic">
                    <div className="sat"><span>Yatak</span>
                      <b>{o?.yatak || '—'} → <span className="rozet sari">temizlik bekliyor</span></b></div>
                    <div className="sat"><span>Açık order'lar</span>
                      <b>taburcuda kapanır · bekleyen dozlar "atlandı"</b></div>
                    <div className="sat"><span>Provizyon</span>
                      <b>{t.provizyonVar ? 'çıkış bildirimiyle kapanır' : 'alınmamış'}</b></div>
                    <div className="sat"><span>Yatak ücreti</span>
                      <b>gün sonu işinde birikir · taburcuda toplu hesaplanmaz</b></div>
                  </div>
                  <div className="not">
                    <b>Yatak ücreti gün sonu işinde birikir</b>, taburcuda toplu
                    hesaplanmaz: on günlük yatışta fatura son gün üretilseydi ara
                    provizyon, iskonto ve paket kontrolü hep geç kalırdı. Taburcu yalnız
                    <b> kapanıştır</b>.
                  </div>
                </div>
              </>
            ) : (
              <div className="sonuk" style={{ padding: 10 }}>İcmal okunamadı.</div>
            )}
          </>
        )}
      </Modal>
    </>
  );
}
