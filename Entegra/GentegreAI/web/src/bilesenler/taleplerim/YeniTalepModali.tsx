import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { SaatSec, dk } from '../calisma/calismaOrtak';
import { para, bugunIso, tutarOku } from '../bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { talepleriYenile, gunYaz } from './useTaleplerimOzeti';
import { mesaj } from '../mesaj';
import { ArizaBildirModali } from './ArizaBildirModali';
import type { IzinBakiyesi } from '../../api/uclar/izin';

/**
 * YENİ TALEP PENCERELERİ (Taleplerim, mockup bölüm 2): kişi KENDİ adına
 * izin, avans, masraf ve belge talebi açar. Uçlar kendi kaydında İK yetkisi
 * aramaz (sunucu KendiTalebi); taraf her zaman oturumdaki kişidir.
 *
 * Her yerden açılır (üst şerit paneli, Taleplerim sayfası): pencere kabukta
 * tek kez durur, `yeniTalepAc('izin')` olayıyla açılır.
 */
export type YeniTalepTuru = 'izin' | 'avans' | 'masraf' | 'belge' | 'ariza';

const OLAY = 'gentegre:yeni-talep';
export const yeniTalepAc = (tur: YeniTalepTuru) =>
  window.dispatchEvent(new CustomEvent<YeniTalepTuru>(OLAY, { detail: tur }));

/** Kabukta bir kez: olayı dinler, pencereyi çizer. */
export function YeniTalepKatmani() {
  const [tur, setTur] = useState<YeniTalepTuru | null>(null);
  useEffect(() => {
    const dinle = (e: Event) => setTur((e as CustomEvent<YeniTalepTuru>).detail);
    window.addEventListener(OLAY, dinle);
    return () => window.removeEventListener(OLAY, dinle);
  }, []);
  if (!tur) return null;
  if (tur === 'ariza') return <ArizaBildirModali onKapat={() => setTur(null)} />;
  return <YeniTalepModali tur={tur} onKapat={() => setTur(null)} />;
}

const IZIN_TURLERI: [number, string][] = [[1, 'Yıllık izin'], [2, 'Mazeret izni'], [3, 'Rapor'], [4, 'Ücretsiz izin'], [9, 'Diğer']];
const BELGE_TURLERI: [number, string][] = [[1, 'Çalışma belgesi'], [2, 'Maaş yazısı'], [3, 'Vize yazısı'], [4, 'SGK hizmet dökümü'], [9, 'Diğer']];
const TESLIM: [number, string][] = [[1, 'Elden'], [2, 'E-posta'], [3, 'Kargo']];
const MASRAF_BELGE: [number, string][] = [[1, 'Fatura'], [2, 'Fiş'], [3, 'e-Arşiv'], [4, 'Bilet'], [5, 'Gider pusulası'], [9, 'Diğer']];

const BASLIK: Record<Exclude<YeniTalepTuru, 'ariza'>, string> = {
  izin: '✈️ Yeni izin talebi', avans: '💸 Yeni avans talebi',
  masraf: '🧾 Yeni masraf beyanı', belge: '📄 Yeni belge talebi',
};

interface MasrafSatiri { tarih: string; belgeTuru: number; belgeNo: string; tutar: string; kdv: string; aciklama: string }
const bosSatir = (): MasrafSatiri => ({ tarih: bugunIso(), belgeTuru: 2, belgeNo: '', tutar: '', kdv: '', aciklama: '' });

/** Bir sonraki ay "YYYY-MM": avansın ilk kesinti dönemi varsayılanı. */
const sonrakiAy = () => {
  const d = new Date(); d.setDate(1); d.setMonth(d.getMonth() + 1);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
};

export function YeniTalepModali({ tur, onKapat }: { tur: Exclude<YeniTalepTuru, 'ariza'>; onKapat(): void }) {
  const { kullanici } = useOturum();
  const ben = kullanici?.id ?? 0;
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const [bakiye, setBakiye] = useState<IzinBakiyesi | null>(null);

  // --- izin
  const [izinTur, setIzinTur] = useState(1);
  const [saatli, setSaatli] = useState(false);
  const [bas, setBas] = useState(bugunIso());
  const [bit, setBit] = useState(bugunIso());
  const [saatBas, setSaatBas] = useState('');
  const [saatBit, setSaatBit] = useState('');
  // --- avans
  const [tutar, setTutar] = useState('');
  const [taksit, setTaksit] = useState(1);
  const [donem, setDonem] = useState(sonrakiAy());
  // --- masraf
  const [satirlar, setSatirlar] = useState<MasrafSatiri[]>([bosSatir()]);
  // --- belge
  const [belgeTur, setBelgeTur] = useState(1);
  const [amac, setAmac] = useState('');
  const [muhatap, setMuhatap] = useState('');
  const [adet, setAdet] = useState(1);
  const [teslim, setTeslim] = useState(1);
  // --- ortak
  const [aciklama, setAciklama] = useState('');

  useEffect(() => {
    if (tur === 'izin' && ben) api.izinBakiye(ben).then(setBakiye).catch(() => setBakiye(null));
  }, [tur, ben]);

  const masrafToplam = satirlar.reduce((t, s) => t + (tutarOku(s.tutar) || 0), 0);

  /** Doğrulama: sunucu da yapar; burada yalnız boş form gönderilmesin. */
  const denetle = (): string | null => {
    if (tur === 'izin') {
      if (!bas) return 'Başlangıç tarihi seçin.';
      if (!saatli && bit < bas) return 'Bitiş başlangıçtan önce olamaz.';
      if (saatli && (!saatBas || !saatBit)) return 'Saatli izinde iki saati de seçin.';
    }
    if (tur === 'avans' && !(tutarOku(tutar) > 0)) return 'Avans tutarını girin.';
    if (tur === 'masraf') {
      const dolu = satirlar.filter(s => s.belgeNo.trim() || s.tutar.trim());
      if (dolu.length === 0) return 'En az bir belge satırı girin.';
      if (dolu.some(s => !s.belgeNo.trim())) return 'Her satırda belge no zorunlu (belgesiz masraf beyan edilmez).';
      if (dolu.some(s => !(tutarOku(s.tutar) > 0))) return 'Her satırda tutar girin.';
    }
    if (tur === 'belge' && !amac.trim()) return 'Belgenin ne için istendiğini yazın.';
    return null;
  };

  /**
   * KAYDET: önce taslak açılır, "gönder" ise zincir kurulur. Zincir kurulamazsa
   * (ör. âmir tanımlı değil) talep TASLAK kalır - kişi Taleplerim'den sonra
   * gönderebilir; yazdığı kaybolmaz.
   */
  const kaydet = async (gonderilsin: boolean) => {
    const h = denetle();
    if (h) { setHata(h); return }
    setHata(null); setMesgul(true);
    let id = 0;
    try {
      if (tur === 'izin') {
        const y = await api.izinAc({
          tarafId: ben, tur: izinTur, baslangic: bas, bitis: saatli ? bas : bit, isGunu: true,
          aciklama: aciklama.trim() || undefined,
          saatBas: saatli ? saatBas : undefined, saatBit: saatli ? saatBit : undefined,
        });
        id = y.id;
        if (gonderilsin) await api.izinGonder(id);
      } else if (tur === 'avans') {
        const y = await api.avansAc({
          tarafId: ben, tutar: tutarOku(tutar), taksitSayisi: taksit,
          ilkDonem: donem || undefined, gerekce: aciklama.trim() || undefined,
        });
        id = y.id;
        if (gonderilsin) await api.avansGonder(id);
      } else if (tur === 'masraf') {
        const y = await api.masrafAc({ tarafId: ben, aciklama: aciklama.trim() || undefined });
        id = y.id;
        for (const s of satirlar.filter(x => x.belgeNo.trim() || x.tutar.trim())) {
          await api.masrafSatirEkle(id, {
            harcamaTarihi: s.tarih || undefined, belgeTuru: s.belgeTuru, belgeNo: s.belgeNo.trim(),
            tutar: tutarOku(s.tutar), kdvTutar: tutarOku(s.kdv) || undefined,
            aciklama: s.aciklama.trim() || undefined,
          });
        }
        if (gonderilsin) await api.masrafGonder(id);
      } else {
        // BELGE TALEBİ açılışta zinciri kendisi kurar - taslağı yok.
        await api.belgeTalepAc({
          tarafId: ben, tur: belgeTur, amac: amac.trim(), muhatap: muhatap.trim() || undefined,
          adet, teslimSekli: teslim, aciklama: aciklama.trim() || undefined,
        });
      }
      talepleriYenile();
      onKapat();
    } catch (e) {
      if (id) {
        // TASLAK OLUŞTU, GÖNDERİM KALDI: pencere kapanır (tekrar "Gönder"
        //   ikinci bir taslak açardı), neden mesajla söylenir.
        talepleriYenile();
        onKapat();
        void mesaj(`${hataMetni(e)}

${c('Talep taslak olarak kaydedildi; Taleplerim ekranından düzeltip gönderebilirsiniz.')}`);
      } else setHata(hataMetni(e));
    } finally { setMesgul(false) }
  };

  const alt = (
    <>
      {tur !== 'belge' && (
        <button type="button" className="d" disabled={mesgul} onClick={() => void kaydet(false)}>💾 {c('Taslak')}</button>
      )}
      <button type="button" className="d bir" disabled={mesgul} onClick={() => void kaydet(true)}>📨 {c('Gönder')}</button>
      <span className="ck-bosluk" />
      <button type="button" className="d" onClick={onKapat}>{c('Kapat')}</button>
    </>
  );

  return (
    <Modal baslik={c(BASLIK[tur])} ustBilgi={kullanici?.ad} dar buyutmeYok alt={alt} onKapat={onKapat}>
      <div className="tl-form">
        {hata && <div className="hata-kutusu">{hata}</div>}

        {tur === 'izin' && <>
          <div className="tl-iki">
            <label className="rk-fld"><span className="ck-etiket">{c('İzin türü')} <b className="ak-zor">*</b></span>
              <select value={izinTur} onChange={e => setIzinTur(Number(e.target.value))}>
                {IZIN_TURLERI.map(([k, a]) => <option key={k} value={k}>{c(a)}</option>)}
              </select></label>
            <div className="rk-fld"><span className="ck-etiket">{c('Süre')}</span>
              <div className="ck-cipler">
                <button type="button" className={`ck-cip${!saatli ? ' on' : ''}`} onClick={() => setSaatli(false)}>{c('Gün boyu')}</button>
                <button type="button" className={`ck-cip${saatli ? ' on' : ''}`} onClick={() => setSaatli(true)}>{c('Saatli (yarım gün)')}</button>
              </div></div>
          </div>
          {!saatli ? (
            <div className="rk-fld"><span className="ck-etiket">{c('Tarih aralığı')} <b className="ak-zor">*</b></span>
              <div className="ck-ikili">
                <input type="date" value={bas} onChange={e => { setBas(e.target.value); if (bit < e.target.value) setBit(e.target.value) }} />
                <span className="sonuk">–</span>
                <input type="date" value={bit} min={bas} onChange={e => setBit(e.target.value)} />
              </div></div>
          ) : (
            <div className="tl-iki">
              <label className="rk-fld"><span className="ck-etiket">{c('Gün')} <b className="ak-zor">*</b></span>
                <input type="date" value={bas} onChange={e => setBas(e.target.value)} /></label>
              <div className="rk-fld"><span className="ck-etiket">{c('Saat')} <b className="ak-zor">*</b></span>
                <div className="ck-ikili">
                  <SaatSec deger={saatBas} onChange={v => { setSaatBas(v); if (saatBit && dk(saatBit) <= dk(v)) setSaatBit('') }} />
                  <span className="sonuk">–</span>
                  <SaatSec deger={saatBit} sonra={saatBas} disabled={!saatBas} onChange={setSaatBit} />
                </div></div>
            </div>
          )}
          <div className="tl-uyari">
            📅 {saatli
              ? c('Saatli izin tek gündür; 4,5 saate kadar 0,5 gün, üstü 1 gün sayılır.')
              : c('Gün sayısı iş günü olarak hesaplanır (hafta sonu ve resmî tatil sayılmaz).')}
            {bakiye && <> · {c('Kalan bakiyen')}: <b>{gunYaz(bakiye.kalan)} {c('gün')}</b></>}
            <br />{c('Onaylanınca çalışma planın kendiliğinden kapanır; ayrıca istisna girilmez.')}
          </div>
        </>}

        {tur === 'avans' && <>
          <div className="tl-iki">
            <label className="rk-fld"><span className="ck-etiket">{c('Tutar (₺)')} <b className="ak-zor">*</b></span>
              <input inputMode="decimal" value={tutar} onChange={e => setTutar(e.target.value)} placeholder="0,00" /></label>
            <label className="rk-fld"><span className="ck-etiket">{c('Taksit')}</span>
              <select value={taksit} onChange={e => setTaksit(Number(e.target.value))}>
                {Array.from({ length: 12 }, (_, i) => i + 1).map(n => <option key={n} value={n}>{n}</option>)}
              </select></label>
          </div>
          <label className="rk-fld"><span className="ck-etiket">{c('İlk kesinti dönemi')}</span>
            <input type="month" value={donem} onChange={e => setDonem(e.target.value)} /></label>
          {tutarOku(tutar) > 0 && (
            <div className="tl-uyari">💸 {c('Aylık kesinti')}: <b>{para.format(tutarOku(tutar) / taksit)}</b> × {taksit}</div>
          )}
        </>}

        {tur === 'masraf' && <>
          <table className="tl-masraf">
            <thead><tr>
              <th>{c('Tarih')}</th><th>{c('Belge')}</th><th>{c('Belge no')} *</th>
              <th className="sag">{c('Tutar')} *</th><th className="sag">{c('KDV')}</th><th />
            </tr></thead>
            <tbody>
              {satirlar.map((s, i) => {
                const yaz = (k: keyof MasrafSatiri, v: string | number) =>
                  setSatirlar(l => l.map((x, j) => j === i ? { ...x, [k]: v } : x));
                return (
                  <tr key={i}>
                    <td><input type="date" value={s.tarih} onChange={e => yaz('tarih', e.target.value)} /></td>
                    <td><select value={s.belgeTuru} onChange={e => yaz('belgeTuru', Number(e.target.value))}>
                      {MASRAF_BELGE.map(([k, a]) => <option key={k} value={k}>{c(a)}</option>)}</select></td>
                    <td><input value={s.belgeNo} onChange={e => yaz('belgeNo', e.target.value)} /></td>
                    <td><input className="sag" inputMode="decimal" value={s.tutar} onChange={e => yaz('tutar', e.target.value)} /></td>
                    <td><input className="sag" inputMode="decimal" value={s.kdv} onChange={e => yaz('kdv', e.target.value)} /></td>
                    <td><button type="button" className="cl-bag sonuk" title={c('Satırı sil')} disabled={satirlar.length === 1}
                                onClick={() => setSatirlar(l => l.filter((_, j) => j !== i))}>✕</button></td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          <div className="tl-masraf-alt">
            <button type="button" className="d" onClick={() => setSatirlar(l => [...l, bosSatir()])}>＋ {c('Belge ekle')}</button>
            <span className="sp" />{c('Toplam')}: <b>{para.format(masrafToplam)}</b>
          </div>
        </>}

        {tur === 'belge' && <>
          <div className="tl-iki">
            <label className="rk-fld"><span className="ck-etiket">{c('Belge türü')} <b className="ak-zor">*</b></span>
              <select value={belgeTur} onChange={e => setBelgeTur(Number(e.target.value))}>
                {BELGE_TURLERI.map(([k, a]) => <option key={k} value={k}>{c(a)}</option>)}
              </select></label>
            <label className="rk-fld"><span className="ck-etiket">{c('Teslim')}</span>
              <select value={teslim} onChange={e => setTeslim(Number(e.target.value))}>
                {TESLIM.map(([k, a]) => <option key={k} value={k}>{c(a)}</option>)}
              </select></label>
          </div>
          <label className="rk-fld"><span className="ck-etiket">{c('Ne için')} <b className="ak-zor">*</b></span>
            <input value={amac} onChange={e => setAmac(e.target.value)} placeholder={c('ör. banka kredi başvurusu')} /></label>
          <div className="tl-iki">
            <label className="rk-fld"><span className="ck-etiket">{c('Muhatap')}</span>
              <input value={muhatap} onChange={e => setMuhatap(e.target.value)} placeholder={c('ilgili makama')} /></label>
            <label className="rk-fld"><span className="ck-etiket">{c('Adet')}</span>
              <input type="number" min={1} max={10} value={adet} onChange={e => setAdet(Math.max(1, Number(e.target.value) || 1))} /></label>
          </div>
        </>}

        <label className="rk-fld"><span className="ck-etiket">{tur === 'avans' ? c('Gerekçe') : c('Açıklama')}</span>
          <input value={aciklama} onChange={e => setAciklama(e.target.value)} maxLength={300} /></label>
      </div>
    </Modal>
  );
}
