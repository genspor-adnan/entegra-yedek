import { useCallback, useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { webKoku, type RaporGonderimAyari as Ayar, type RaporGonderimKurali as Kural } from '../../api/uclar/raporGonderim';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { c } from '../../dil/ceviri';

/**
 * RADYOLOJİ › AYARLAR › RAPOR GÖNDERİMİ (1389; kullanıcı 20.11.2026; mockup
 * Ekranlar/Radyoloji/radyoloji_rapor_hasta_goruntuleme.html §4). Aktif şubenin ayarı:
 *  * otomatik gönderim, kritik bulguda tek süre (dk; 0 = elle), borç kuralı, hastaya kanal, bağlantı geçerliliği;
 *  * GÖNDERİM ZAMANI KURALLARI grid'i: Tümü / Kategori / Kod → hemen · N saat sonra · ertesi gün saat. Öncelik
 *    kod › kategori › tümü (sunucu RaporGonderimKurali).
 * Hiçbir alan anında yazmaz - hepsi sayfanın Kaydet'iyle (ayarlarda otomatik kayıt yok).
 */
const BOS_AYAR: Ayar = { otomatik: false, kritikDakika: 0, labPanikDakika: 0, borcKontrol: true, hastaSms: true, hastaEposta: false, gecerlilikGun: 30, webKok: '' };
type Tetkik = { id: number; kod: string; ad: string; kategori: number | null };
type Kategori = { id: number; ad: string };

const saatMetni = (dk: number) => `${String(Math.floor(dk / 60)).padStart(2, '0')}:${String(dk % 60).padStart(2, '0')}`;
const saatOku = (v: string) => { const [s, d] = v.split(':').map(Number); return Math.min(1439, Math.max(0, (s || 0) * 60 + (d || 0))) };

export function RaporGonderimAyari() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  const [ayar, setAyar] = useState<Ayar>(BOS_AYAR);
  const [kurallar, setKurallar] = useState<Kural[]>([]);
  const [ilk, setIlk] = useState('');
  const [duzenle, setDuzenle] = useState(false);
  const [tetkikler, setTetkikler] = useState<Tetkik[]>([]);
  const [kategoriler, setKategoriler] = useState<Kategori[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [kaydediliyor, setKaydediliyor] = useState(false);

  const yukle = useCallback(async () => {
    try {
      const y = await api.raporGonderimAyari();
      // Bağlantı adresi boşsa web'in kendi adresi önerilir (Kaydet'le yazılır).
      const a = { ...y.ayar, webKok: y.ayar.webKok || webKoku() };
      setAyar(a); setKurallar(y.kurallar); setDuzenle(y.degistirebilir); setHata(null);
      setIlk(JSON.stringify({ a: { ...y.ayar }, k: y.kurallar.map(sade) }));
    } catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  // Tetkik ve kategori seçenekleri: radyoloji tetkikleri (modalitesi olan hizmetler) ve onların kategorileri.
  useEffect(() => {
    let iptal = false;
    Promise.all([
      // Radyoloji tetkikleri (modalitesi olan) + laboratuvar testleri (lab tetkiğine bağlı hizmetler) - TEK tablo (1394).
      api.liste('hizmet', { sayfa: 1, boyut: 5000, filtre: { op: 'or', kosullar: [
        { alan: 'modalite', op: 'buyuk', deger: 0 }, { alan: 'labVarMi', op: 'esit', deger: 1 }] } }),
      api.liste('kategori', { sayfa: 1, boyut: 2000 }),
    ]).then(([h, k]) => {
      if (iptal) return;
      const t = h.satirlar.map(s => ({ id: Number(s.id), kod: String(s.kod ?? ''), ad: String(s.ad ?? ''),
                                       kategori: s.kategori == null ? null : Number(s.kategori) }))
        .sort((a, b) => a.ad.localeCompare(b.ad, 'tr'));
      setTetkikler(t);
      const ust = new Map(k.satirlar.map(s => [Number(s.id), s.ustId == null ? null : Number(s.ustId)]));
      // Tetkiklerin kategorileri + üstleri (üst kategoriye de kural yazılabilir).
      const kullanilan = new Set<number>();
      for (const x of t) { let id = x.kategori; let n = 0; while (id != null && !kullanilan.has(id) && n++ < 20) { kullanilan.add(id); id = ust.get(id) ?? null } }
      setKategoriler(k.satirlar.filter(s => kullanilan.has(Number(s.id)))
        .map(s => ({ id: Number(s.id), ad: String(s.ad ?? '') })).sort((a, b) => a.ad.localeCompare(b.ad, 'tr')));
    }).catch(() => { /* seçenek listesi okunamadı: mevcut kurallar yine görünür */ });
    return () => { iptal = true };
  }, []);

  // Sunucuda bağlantı adresi boşsa önerilen adres "değişiklik" sayılır - Kaydet açılır, kullanıcı onaylayıp yazar.
  const degisti = useMemo(() => ilk !== '' && JSON.stringify({ a: ayar, k: kurallar.map(sade) }) !== ilk, [ayar, kurallar, ilk]);
  const a = (k: Partial<Ayar>) => setAyar(x => ({ ...x, ...k }));
  const kuralDegis = (i: number, k: Partial<Kural>) => setKurallar(l => l.map((x, n) => n === i ? { ...x, ...k } : x));
  const tumuVar = kurallar.some(k => k.kapsam === 0);

  const kaydet = async () => {
    if (kaydediliyor) return;
    for (const k of kurallar) {
      if (k.kapsam === 1 && !k.kategoriId) { setHata(c('Kategori kuralında kategori seçilmeli.')); return }
      if (k.kapsam === 2 && !k.hizmetId) { setHata(c('Kod kuralında tetkik seçilmeli.')); return }
    }
    setKaydediliyor(true);
    try {
      await api.raporGonderimAyariYaz({ ...ayar, kurallar });
      mesaj(c('Rapor gönderimi ayarları kaydedildi.'));
      await yukle();
    } catch (h) { setHata(hataMetni(h)) }
    finally { setKaydediliyor(false) }
  };

  const tetkikAdi = (k: Kural) => {
    const t = tetkikler.find(x => x.id === k.hizmetId);
    return t ? `${t.kod} ${t.ad}`.trim() : `${k.hizmetKod ?? ''} ${k.hizmetAd ?? ''}`.trim();
  };

  return (
    <div className="rga" data-testid="rapor-gonderim-ayari">
      <div className="rt-arac">
        <button type="button" className="d bir" disabled={!duzenle || !degisti || kaydediliyor} data-testid="rga-kaydet"
                onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>
        <span className="rt-baslik"><b>📨 {c('Rapor Gönderimi Ayarı')}</b><span className="yol">{c('Radyoloji ve Laboratuvar › Ayarlar › Rapor Gönderimi Ayarı')}</span></span>
        <span className="ck-bosluk" />
        <button type="button" className="d" onClick={() => void (async () => {
          if (degisti && !await onay(c('Kaydedilmemiş değişiklik var. Kaydetmeden kapatılsın mı?'))) return;
          if (ekranSekmesi) ekranSekmesi.kapat(); else git('/radyoloji-pano');
        })()}>✖ {c('Kapat')}</button>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!duzenle && !hata && <div className="bilgi-kutusu">{c('Bu ayarı yalnız görüntüleyebilirsiniz (Rapor Gönderimi Ayarı - Değiştir yetkisi gerekir).')}</div>}

      <fieldset className="rga-govde" disabled={!duzenle}>
        <div className="kagrup rga-grp">
          <h5>{c('Otomatik gönderim')}</h5>
          <label className="rga-cb"><input type="checkbox" checked={ayar.otomatik} data-testid="rga-otomatik"
                                           onChange={e => a({ otomatik: e.target.checked })} />
            {c('Rapor / sonuç onaylanınca kurallara göre gönder')}</label>
          <div className="rga-sat"><span>{c('Radyoloji · kritik bulgu')}</span>
            <span><input type="number" min={0} max={1440} value={ayar.kritikDakika} data-testid="rga-kritik"
                         onChange={e => a({ kritikDakika: Math.max(0, Number(e.target.value) || 0) })} /> {c('dakika sonra')}</span></div>
          <div className="rga-sat"><span>{c('Laboratuvar · panik değer')}</span>
            <span><input type="number" min={0} max={1440} value={ayar.labPanikDakika} data-testid="rga-lab-panik"
                         onChange={e => a({ labPanikDakika: Math.max(0, Number(e.target.value) || 0) })} /> {c('dakika sonra')}
              <small>{c('İki süre ayrı girilir. 0 = otomatik gitmez, elle gönderilir. Kritik bulgulu rapor / panik değerli sonuçta kural tablosuna bakılmaz, yalnız bu süre geçerlidir.')}</small></span></div>
          <div className="rga-sat"><span>{c('Bağlantı geçerliliği')}</span>
            <span><input type="number" min={1} max={3650} value={ayar.gecerlilikGun}
                         onChange={e => a({ gecerlilikGun: Math.max(1, Number(e.target.value) || 1) })} /> {c('gün')}</span></div>
          <div className="rga-sat"><span>{c('Bağlantı adresi')}</span>
            <span><input className="rga-genis" value={ayar.webKok} maxLength={200} placeholder="https://…"
                         onChange={e => a({ webKok: e.target.value })} />
              <small>{c('SMS / e-postadaki bağlantının başı; hastanın açacağı adres. Boşsa bu sayfanın adresi yazılır.')}</small></span></div>
        </div>

        <div className="kagrup rga-grp">
          <h5>{c('Borç kuralı ve alıcılar')}</h5>
          <label className="rga-cb"><input type="checkbox" checked={ayar.borcKontrol} onChange={e => a({ borcKontrol: e.target.checked })} />
            {c('Başvurunun borcu varken gönderme')}</label>
          <small className="rga-not">{c('Yalnız raporun başvurusuna bakılır (hasta payı). Borç varken hastaya da gönderen dış doktora da gitmez, bağlantı ve karekod raporu açmaz; borç kapanınca bekleyenler kendiliğinden gider.')}</small>
          <div className="rga-sat"><span>{c('Hastaya')}</span>
            <span><label className="rga-cb ic"><input type="checkbox" checked={ayar.hastaSms} onChange={e => a({ hastaSms: e.target.checked })} /> SMS</label>
              <label className="rga-cb ic"><input type="checkbox" checked={ayar.hastaEposta} onChange={e => a({ hastaEposta: e.target.checked })} /> {c('E-posta')}</label></span></div>
          <div className="rga-sat"><span>{c('Gönderen dış doktora')}</span>
            <span>{c('Kartında "Rapor Bildirimi" seçili doktorlara, doktorun tercih ettiği kanaldan. Bağlantı gider (ek dosya yok).')}</span></div>
          <small className="rga-not">{c('Mesaj metinleri: Yönetim › Bildirim Şablonları › "Radyoloji raporu hazır". Hastanın bağlantıyı açması teslim edildi sayılır.')}</small>
        </div>

        <div className="kagrup rga-grp rga-tam">
          <h5>{c('Gönderim zamanı kuralları')} <span className="rga-oncelik">— {c('öncelik')}: <b>{c('Kod')}</b> › <b>{c('Kategori')}</b> › <b>{c('Tümü')}</b></span></h5>
          <div className="rga-arac">
            <button type="button" className="d" data-testid="rga-satir-ekle" onClick={() => setKurallar(l => [...l,
              { kapsam: tumuVar ? 1 : 0, kategoriId: null, hizmetId: null, zamanTur: 1, saat: 2, gunDakika: 900, aktif: true }])}>＋ {c('Satır')}</button>
          </div>
          <table className="rga-kural">
            <thead><tr><th style={{ width: 130 }}>{c('Kapsam')}</th><th>{c('Seçim')}</th><th style={{ width: 330 }}>{c('Gönderim zamanı')}</th>
              <th style={{ width: 70 }}>{c('Aktif')}</th><th style={{ width: 40 }} /></tr></thead>
            <tbody>
              {kurallar.length === 0 && <tr><td colSpan={5} className="rga-bos">{c('Kural yok - otomatik gönderim açık olsa da rapor elle gönderilir. "＋ Satır" ile "Tümü" kuralı ekleyin.')}</td></tr>}
              {kurallar.map((k, i) => (
                <tr key={i} data-testid="rga-kural-satiri">
                  <td><select value={k.kapsam} onChange={e => kuralDegis(i, { kapsam: Number(e.target.value), kategoriId: null, hizmetId: null })}>
                    <option value={0} disabled={tumuVar && k.kapsam !== 0}>{c('Tümü')}</option>
                    <option value={1}>{c('Kategori')}</option><option value={2}>{c('Kod')}</option></select></td>
                  <td>
                    {k.kapsam === 0 && <span className="soluk">— {c('bütün tetkikler')} —</span>}
                    {k.kapsam === 1 && (
                      <select value={k.kategoriId ?? 0} onChange={e => kuralDegis(i, { kategoriId: Number(e.target.value) || null })}>
                        <option value={0}>— {c('kategori seçin')} —</option>
                        {k.kategoriId && !kategoriler.some(x => x.id === k.kategoriId) && <option value={k.kategoriId}>{k.kategoriAd}</option>}
                        {kategoriler.map(x => <option key={x.id} value={x.id}
                          disabled={kurallar.some((y, n) => n !== i && y.kapsam === 1 && y.kategoriId === x.id)}>{x.ad}</option>)}
                      </select>)}
                    {k.kapsam === 2 && (<>
                      <input className="rga-tetkik" list={`rga-tetkik-${i}`} defaultValue={tetkikAdi(k)} key={`${k.hizmetId}-${tetkikler.length}`}
                             placeholder={c('🔍 tetkik kodu ya da adı…')}
                             onChange={e => {
                               const t = tetkikler.find(x => `${x.kod} ${x.ad}`.trim() === e.target.value.trim());
                               if (t && !kurallar.some((y, n) => n !== i && y.kapsam === 2 && y.hizmetId === t.id)) kuralDegis(i, { hizmetId: t.id });
                             }} />
                      <datalist id={`rga-tetkik-${i}`}>{tetkikler.map(t => <option key={t.id} value={`${t.kod} ${t.ad}`.trim()} />)}</datalist>
                      {!k.hizmetId && <small className="rga-uyari">{c('listeden seçin')}</small>}
                    </>)}
                  </td>
                  <td className="rga-zaman">
                    <select value={k.zamanTur} onChange={e => kuralDegis(i, { zamanTur: Number(e.target.value) })}>
                      <option value={0}>{c('Hemen')}</option><option value={1}>{c('Saat sonra')}</option><option value={2}>{c('Ertesi gün saat')}</option></select>
                    {k.zamanTur === 1 && <><input type="number" min={1} max={720} value={k.saat}
                                                   onChange={e => kuralDegis(i, { saat: Math.min(720, Math.max(1, Number(e.target.value) || 1)) })} /> {c('saat sonra')}</>}
                    {k.zamanTur === 2 && <input type="time" value={saatMetni(k.gunDakika)} onChange={e => kuralDegis(i, { gunDakika: saatOku(e.target.value) })} />}
                  </td>
                  <td className="hiza-orta"><input type="checkbox" checked={k.aktif} onChange={e => kuralDegis(i, { aktif: e.target.checked })} /></td>
                  <td className="hiza-orta"><button type="button" className="d" title={c('Satırı sil')}
                                                    onClick={() => setKurallar(l => l.filter((_, n) => n !== i))}>🗑</button></td>
                </tr>))}
            </tbody>
          </table>
          <small className="rga-not">{c('Radyoloji tetkikleri ve laboratuvar testleri aynı tablodadır. Önce Kod satırına bakılır; yoksa Kategori satırına (en yakın üst kategori); o da yoksa Tümü satırına. Hiçbiri uymuyorsa otomatik gönderilmez. Radyolojide her rapor kendi kuralıyla planlanır. Laboratuvarda gönderim birimi bölümdür: bölümün testlerinin tamamı onaylanınca planlanır, zaman bölümdeki testlerin kurallarından en geç olanıdır.')}</small>
        </div>
      </fieldset>
    </div>
  );
}

/** Karşılaştırma için kuralın yalnız kaydedilen alanları. */
function sade(k: Kural) {
  return { kapsam: k.kapsam, kategoriId: k.kategoriId, hizmetId: k.hizmetId, zamanTur: k.zamanTur, saat: k.saat, gunDakika: k.gunDakika, aktif: k.aktif };
}

export default RaporGonderimAyari;
