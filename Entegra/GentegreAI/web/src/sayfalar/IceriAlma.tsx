import { useEffect, useRef, useState } from 'react';
import { AyarSekmeSeridi } from '../bilesenler/AyarSekmeSeridi';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { dosyaIndirUrl } from '../bilesenler/indir';
import { mesaj as bilgiMesaji, onay as onaySor } from '../bilesenler/mesaj';
import type {
  IceriAlmaHedefi, CozumSonucu, OnizlemeSonucu, YuklemeKaydi, EslemeKurali,
} from '../api/uclar/iceriAlma';

const SEKMELER = [
  { anahtar: 'sihirbaz', baslik: 'Sihirbaz' },
  { anahtar: 'sablonlar', baslik: 'Şablonlar' },
  { anahtar: 'gecmis', baslik: 'Geçmiş Yüklemeler' },
  { anahtar: 'kurallar', baslik: 'Eşleme Kuralları' },
] as const;
type Sekme = typeof SEKMELER[number]['anahtar'];

const ADIMLAR = ['Dosya & Hedef', 'Kolon Eşleme', 'Ön İzleme & Doğrulama', 'Aktarım'];

const DURUM_ADI: Record<number, { ad: string; sinif: string }> = {
  1: { ad: 'Tamam', sinif: 'ok' },
  2: { ad: 'Kısmi', sinif: 'uyari' },
  3: { ad: 'Hata', sinif: 'hata' },
  4: { ad: 'Geri alındı', sinif: 'gri' },
};

function tarihMetni(ham: string) {
  const t = new Date(ham);
  return Number.isNaN(t.getTime()) ? ham : t.toLocaleString('tr');
}

/**
 * EXCEL'DEN İÇERİ ALMA (548) — Yönetim › Veri Aktarımı.
 * Mockup: Ekranlar/Ayarlar/excel_iceri_alma.html
 *
 * Tek sihirbaz, çok hedef: cari / stok / hizmet / fiyat listesi satırı /
 * alış-satış faturası aynı dört adımdan geçer. Hedef "hangi alanlar var"
 * sorusunu ve (fiyat listesinde) hedef listeyi belirler.
 *
 * ÜÇÜNCÜ ADIMA KADAR HİÇBİR ŞEY YAZILMAZ — sunucu önizlemede yalnız okur;
 * yazma tek işlemde, "Aktarımı Başlat" ile olur.
 */
export function IceriAlma() {
  const [aktif, setAktif] = useState<Sekme>('sihirbaz');
  const [hata, setHata] = useState<string | null>(null);

  // ---- sihirbaz durumu ----------------------------------------------------
  const [hedefler, setHedefler] = useState<IceriAlmaHedefi[]>([]);
  const [hedef, setHedef] = useState('');
  const [dosya, setDosya] = useState<File | null>(null);
  const [cozum, setCozum] = useState<CozumSonucu | null>(null);
  const [esleme, setEsleme] = useState<Record<string, string>>({});
  const [sayiBicimi, setSayiBicimi] = useState<'tr' | 'en'>('tr');
  /** Fiyat listesi hedefinde satirlarin yazilacagi liste (548). */
  const [listeId, setListeId] = useState<number | ''>('');
  const [fiyatListeleri, setFiyatListeleri] =
    useState<{ id: number; ad: string }[]>([]);
  const [adim, setAdim] = useState(1);
  const [calisiyor, setCalisiyor] = useState(false);
  const [onizleme, setOnizleme] = useState<OnizlemeSonucu | null>(null);
  const [onizlemeSuzgeci, setOnizlemeSuzgeci] = useState<'tumu' | 'sorunlu' | 'degisecek' | 'yeni'>('tumu');
  const [sonuc, setSonuc] = useState<{ yuklemeNo: number; eklenen: number;
    guncellenen: number; atlanan: number; toplam: number; mesaj: string } | null>(null);
  const girdi = useRef<HTMLInputElement | null>(null);

  // ---- öteki sekmeler -----------------------------------------------------
  const [gecmis, setGecmis] = useState<YuklemeKaydi[]>([]);
  const [kurallar, setKurallar] = useState<EslemeKurali[]>([]);

  useEffect(() => {
    void (async () => {
      try {
        const h = await api.iceriAlmaHedefleri();
        setHedefler(h);
        setHedef(a => a || h[0]?.ad || '');
      } catch (e) { setHata(hataMetni(e)) }
    })();
  }, []);

  useEffect(() => {
    if (aktif !== 'gecmis') return;
    void api.iceriAlmaGecmisi().then(setGecmis).catch(e => setHata(hataMetni(e)));
  }, [aktif]);

  useEffect(() => {
    if (aktif !== 'kurallar') return;
    void api.iceriAlmaKurallari().then(setKurallar).catch(e => setHata(hataMetni(e)));
  }, [aktif]);

  const seciliHedef = hedefler.find(h => h.ad === hedef);

  // FIYAT LISTELERI yalniz o hedef secilince cekilir: oteki hedeflerde
  //   kullanilmayan bir listeyi her acilista istemenin anlami yok.
  useEffect(() => {
    if (!seciliHedef?.listeGerekli || fiyatListeleri.length > 0) return;
    void api.liste('fiyat-listesi', { sayfa: 1, boyut: 200 })
      .then(y => setFiyatListeleri((y.satirlar ?? []).map(s => ({
        id: Number(s.id), ad: String(s.ad ?? '') }))))
      .catch(e => setHata(hataMetni(e)));
  }, [seciliHedef, fiyatListeleri.length]);

  /** Dosya seçilince hemen çözülür: başlıklar ve eşleme önerisi gelir. */
  const dosyaSec = async (f: File) => {
    if (seciliHedef?.listeGerekli && listeId === '') {
      await bilgiMesaji('Önce satırların yazılacağı fiyat listesini seçin.');
      return;
    }
    setHata(null); setSonuc(null); setOnizleme(null);
    setDosya(f);
    setCalisiyor(true);
    try {
      const c = await api.iceriAlmaCoz(f, hedef);
      setCozum(c);
      setEsleme(Object.fromEntries(c.esleme.map(e => [e.kolon, e.alan])));
      // Kayıtlı kural varsa eşleme %100 geldi - adım 2'yi atlamak mümkün ama
      //   yine de GÖSTERİLİR: kullanıcı neyin nereye gittiğini bir kez görsün.
      setAdim(2);
    } catch (e) { setHata(hataMetni(e)); setCozum(null) }
    finally { setCalisiyor(false) }
  };

  const onizle = async () => {
    if (!dosya) return;
    setHata(null); setCalisiyor(true);
    try {
      setOnizleme(await api.iceriAlmaOnizle(dosya, hedef, esleme, sayiBicimi,
                                            listeId === '' ? undefined : listeId));
      setAdim(3);
    } catch (e) { setHata(hataMetni(e)) }
    finally { setCalisiyor(false) }
  };

  const uygula = async () => {
    if (!dosya || !onizleme) return;
    const devam = await onaySor(
      `${(onizleme.yeni + onizleme.degisecek).toLocaleString('tr')} satır yazılacak`
      + (onizleme.sorunlu > 0
         ? ` · ${onizleme.sorunlu.toLocaleString('tr')} sorunlu satır atlanacak` : '')
      + '. Aktarım başlasın mı?');
    if (!devam) return;
    setHata(null); setCalisiyor(true);
    try {
      const s = await api.iceriAlmaUygula(dosya, hedef, esleme, sayiBicimi,
                                         listeId === '' ? undefined : listeId);
      setSonuc(s);
      setAdim(4);
    } catch (e) { setHata(hataMetni(e)) }
    finally { setCalisiyor(false) }
  };

  const kuralSakla = async () => {
    if (!cozum) return;
    const ad = window.prompt('Bu eşleme hangi adla saklansın?',
                             cozum.kural?.ad ?? cozum.dosyaAdi.replace(/\.[^.]+$/, ''));
    if (!ad) return;
    try {
      const s = await api.iceriAlmaKuralYaz({
        ad, hedef, baslikImzasi: cozum.baslikImzasi, esleme });
      await bilgiMesaji(s.mesaj);
    } catch (e) { setHata(hataMetni(e)) }
  };

  const sablonIndir = (h: string) =>
    dosyaIndirUrl(`/api/iceri-alma/sablon?hedef=${encodeURIComponent(h)}`, `${h}-sablon.xlsx`);

  const sifirla = () => {
    setDosya(null); setCozum(null); setEsleme({}); setOnizleme(null);
    setSonuc(null); setAdim(1);
    if (girdi.current) girdi.current.value = '';
  };

  // ======================================================== ADIM ÇİZİMLERİ ==
  const adimSeridi = (
    <div className="arac-cubugu" style={{ padding: '8px 12px', flexWrap: 'wrap' }}>
      {ADIMLAR.map((a, i) => {
        const no = i + 1;
        // GERİYE dönmek serbest, ileri atlamak değil: adım 3'e dosya
        //   çözülmeden gidilirse gösterilecek bir şey yok.
        const acik = no <= adim || (no === 2 && cozum) || (no === 3 && onizleme);
        return (
          <button key={a} type="button"
                  className={`d${no === adim ? ' bir' : ''}`}
                  disabled={!acik}
                  onClick={() => setAdim(no)}>
            {no}. {a}
          </button>
        );
      })}
      <span className="not kucuk" style={{ marginLeft: 'auto' }}>
        {dosya ? `${dosya.name}${cozum ? ` · ${cozum.satirSayisi.toLocaleString('tr')} satır · ${cozum.basliklar.length} kolon` : ''}`
               : 'Dosya seçilmedi'}
      </span>
    </div>
  );

  const adim1 = (
    <>
      <div className="kagrup">
        <h6>Kaynak Dosya</h6>
        <div style={{ padding: 12 }}>
          <input ref={girdi} type="file" accept=".xlsx"
                 style={{ display: 'none' }}
                 onChange={e => { const f = e.target.files?.[0]; if (f) void dosyaSec(f) }} />
          <button className="d bir"
                  disabled={!hedef || calisiyor
                            || (seciliHedef?.listeGerekli === true && listeId === '')}
                  title={seciliHedef?.listeGerekli && listeId === ''
                         ? 'Önce fiyat listesini seçin' : undefined}
                  onClick={() => girdi.current?.click()}>
            📄 Dosya Seç…
          </button>
          <span className="not kucuk" style={{ marginLeft: 10 }}>
            .xlsx · en çok 10 MB. İlk satır başlık kabul edilir, yalnız ilk sayfa okunur.
          </span>
        </div>
      </div>

      <div className="kagrup">
        <h6>Hedef</h6>
        <div className="alan-izgara" style={{ margin: 10 }}>
          <label className="alan">
            <span className="etiket">Ne aktarılıyor</span>
            <select value={hedef} disabled={!!cozum}
                    onChange={e => { setHedef(e.target.value); sifirla() }}>
              {hedefler.map(h => (
                <option key={h.ad} value={h.ad}>{h.ikon} {h.baslik}</option>
              ))}
            </select>
          </label>
          <label className="alan">
            <span className="etiket">Çakışma kuralı</span>
            <input readOnly value={seciliHedef
              ? `${seciliHedef.anahtarlar.join(' / ')} eşleşirse GÜNCELLE, yoksa EKLE`
              : ''} />
          </label>
          <label className="alan">
            <span className="etiket">Sayı biçimi</span>
            <select value={sayiBicimi}
                    onChange={e => setSayiBicimi(e.target.value as 'tr' | 'en')}>
              <option value="tr">Türkçe (1.234,56)</option>
              <option value="en">İngilizce (1,234.56)</option>
            </select>
          </label>
          {/* FIYAT LISTESI HEDEFI: satirlar HANGI listeye yazilacak (548).
              Ayni dosya iki farkli tarifeye yuklenebilir - bu yuzden liste
              dosyadan degil, buradan secilir. */}
          {seciliHedef?.listeGerekli && (
            <label className="alan">
              <span className="etiket req">Fiyat listesi</span>
              <select value={listeId}
                      onChange={e => setListeId(e.target.value === ''
                                                ? '' : Number(e.target.value))}>
                <option value="">— liste seçin —</option>
                {fiyatListeleri.map(l => (
                  <option key={l.id} value={l.id}>{l.ad}</option>
                ))}
              </select>
            </label>
          )}
        </div>
        <div className="not" style={{ margin: '0 10px 10px' }}>
          Şablon zorunlu değil — kendi Excel'iniz de okunur; başlıklar eşleme adımında
          eşlenir. {seciliHedef && (
            <button className="d" style={{ marginLeft: 8 }}
                    onClick={() => sablonIndir(seciliHedef.ad)}>
              ↓ Boş Şablon İndir
            </button>
          )}
        </div>
      </div>
    </>
  );

  const adim2 = cozum && (
    <>
      <div className="kagrup">
        <h6>
          Eşleme — Excel kolonu → Gentegre alanı
          <span className="rozet mor" style={{ marginLeft: 'auto' }}>
            {Object.values(esleme).filter(Boolean).length} / {cozum.basliklar.length} kolon eşleşti
          </span>
        </h6>
        <div className="not" style={{ margin: 10 }}>
          Başlıklar ve ilk satırların içeriği okundu; öneriler <b>kabul edilmeden hiçbir şey
          yazılmaz</b>. Güven yüzdesi önerinin nereden geldiğini gösterir: %100 kayıtlı
          kuraldan, %90+ bilinen başlık adından, %70 benzerlikten.
          {cozum.kural && <> Bu dosya <b>"{cozum.kural.ad}"</b> kuralıyla tanındı.</>}
        </div>
        <table className="grid" style={{ margin: 10, width: 'calc(100% - 20px)' }}>
          <thead>
            <tr>
              <th>Excel kolonu</th><th>Gentegre alanı</th>
              <th style={{ width: 90 }}>Güven</th><th>Örnek değer</th>
            </tr>
          </thead>
          <tbody>
            {cozum.esleme.map(e => {
              const secili = esleme[e.kolon] ?? '';
              return (
                <tr key={e.kolon}>
                  <td><b>{e.kolon}</b></td>
                  <td>
                    <select value={secili}
                            onChange={ev => setEsleme(t => ({ ...t, [e.kolon]: ev.target.value }))}>
                      <option value="">— aktarma —</option>
                      {seciliHedef?.alanlar.map(a => (
                        <option key={a.ad} value={a.ad}>
                          {a.baslik}{a.zorunlu ? ' *' : ''}{a.anahtar ? ' (anahtar)' : ''}
                        </option>
                      ))}
                    </select>
                  </td>
                  <td>
                    {secili === '' ? <span className="rozet gri">eşlenmedi</span>
                     : e.alan !== secili ? <span className="rozet mavi">elle</span>
                     : e.guven >= 90 ? <span className="rozet ok">%{e.guven}</span>
                     : <span className="rozet uyari">%{e.guven}</span>}
                  </td>
                  <td className="sonuk">{e.ornek}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      <div className="not" style={{ margin: '0 0 12px' }}>
        <b>Eşleme saklanabilir.</b> "Eşlemeyi Sakla" dediğinizde aynı başlık düzenindeki
        dosya bir dahaki sefere bu eşlemeyle açılır (Eşleme Kuralları sekmesi).
      </div>
    </>
  );

  const onizlemeSatirlari = (onizleme?.satirlar ?? []).filter(
    s => onizlemeSuzgeci === 'tumu' || s.durum === onizlemeSuzgeci);

  const adim3 = onizleme && (
    <>
      <div className="arac-cubugu" style={{ padding: '0 0 8px' }}>
        {([['tumu', `Tümü (${onizleme.toplam.toLocaleString('tr')})`],
           ['sorunlu', `⚠ Sorunlu (${onizleme.sorunlu.toLocaleString('tr')})`],
           ['degisecek', `✎ Değişecek (${onizleme.degisecek.toLocaleString('tr')})`],
           ['yeni', `＋ Yeni (${onizleme.yeni.toLocaleString('tr')})`]] as const).map(
          ([k, e]) => (
            <button key={k} type="button"
                    className={`d${onizlemeSuzgeci === k ? ' bir' : ''}`}
                    onClick={() => setOnizlemeSuzgeci(k)}>{e}</button>
          ))}
      </div>

      <div className="not">
        <b>Kural: yazma yok, önce göster.</b> Bu adıma kadar veritabanına hiçbir şey
        yazılmadı. Aktarım tek işlemde çalışır; sorunlu satırlar yazılmaz ve sonuç
        raporunda satır numarasıyla kalır.
      </div>

      <table className="grid" style={{ marginTop: 10 }}>
        <thead>
          <tr>
            <th style={{ width: 60 }}>Satır</th><th>Özet</th><th>Anahtar</th>
            <th style={{ width: 110 }}>Durum</th><th>Not</th>
          </tr>
        </thead>
        <tbody>
          {onizlemeSatirlari.map(s => (
            <tr key={s.satirNo}>
              <td className="hiza-orta">{s.satirNo}</td>
              <td>{s.ozet || <span className="sonuk">(boş)</span>}</td>
              <td className="sonuk">{s.anahtar}</td>
              <td>
                {s.durum === 'yeni' ? <span className="rozet ok">Yeni</span>
                 : s.durum === 'degisecek' ? <span className="rozet uyari">Değişecek</span>
                 : <span className="rozet hata">Sorunlu</span>}
              </td>
              <td className="sonuk">{s.not || '—'}</td>
            </tr>
          ))}
          {onizlemeSatirlari.length === 0 && (
            <tr><td colSpan={5} className="sonuk">Bu süzgeçte satır yok.</td></tr>
          )}
        </tbody>
      </table>
      {onizleme.toplam > onizleme.satirlar.length && (
        <div className="not kucuk">
          İlk {onizleme.satirlar.length} satır gösteriliyor; sayımlar dosyanın tamamı için.
        </div>
      )}
    </>
  );

  const adim4 = sonuc && (
    <div className="kagrup">
      <h6>Özet — Yükleme #{sonuc.yuklemeNo}</h6>
      <table className="grid" style={{ margin: 10, width: 'calc(100% - 20px)' }}>
        <tbody>
          <tr><td style={{ width: 240 }}>Eklenen</td><td><b>{sonuc.eklenen.toLocaleString('tr')}</b></td>
              <td className="sonuk">yeni kart</td></tr>
          <tr><td>Güncellenen</td><td><b>{sonuc.guncellenen.toLocaleString('tr')}</b></td>
              <td className="sonuk">anahtar eşleşti</td></tr>
          <tr><td>Atlanan</td><td><b>{sonuc.atlanan.toLocaleString('tr')}</b></td>
              <td className="sonuk">sorunlu satır</td></tr>
          <tr><td>Toplam satır</td><td><b>{sonuc.toplam.toLocaleString('tr')}</b></td>
              <td className="sonuk">{dosya?.name}</td></tr>
        </tbody>
      </table>
      <div className="not" style={{ margin: '0 10px 10px' }}>
        <b>İzi kalır.</b> Yükleme kaydı Geçmiş Yüklemeler'de durur; yazılan her kart
        işlem günlüğüne <b>#{sonuc.yuklemeNo}</b> yükleme numarasıyla işlendi.
        Geri alma bu sürümde yok — yanlış aktarımı kartlardan düzeltmek gerekir.
      </div>
    </div>
  );

  // ================================================================ ÇİZİM ==
  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Excel'den İçeri Alma</h1>
          <span className="yol">Yönetim › Veri Aktarımı › İçeri Alma Sihirbazı</span>
        </div>
      </div>

      <AyarSekmeSeridi sekmeler={SEKMELER} aktif={aktif}
                       onSec={a => setAktif(a as Sekme)} />

      {hata && <div className="hata-kutusu">{hata}</div>}

      {aktif === 'sihirbaz' && (
        <>
          {adimSeridi}
          <div style={{ padding: '0 12px 12px' }}>
            {adim === 1 && adim1}
            {adim === 2 && adim2}
            {adim === 3 && adim3}
            {adim === 4 && adim4}

            <div className="arac-cubugu" style={{ marginTop: 10 }}>
              {adim > 1 && adim < 4 && (
                <button className="d" disabled={calisiyor}
                        onClick={() => setAdim(a => a - 1)}>‹ Geri</button>
              )}
              {adim === 2 && (
                <>
                  <button className="d" onClick={() => void kuralSakla()}>💾 Eşlemeyi Sakla</button>
                  <button className="d bir" disabled={calisiyor}
                          style={{ marginLeft: 'auto' }}
                          onClick={() => void onizle()}>
                    {calisiyor ? 'Okunuyor…' : 'İleri: Ön İzleme ›'}
                  </button>
                </>
              )}
              {adim === 3 && (
                <button className="d bir" disabled={calisiyor}
                        style={{ marginLeft: 'auto' }}
                        onClick={() => void uygula()}>
                  {calisiyor ? 'Aktarılıyor…' : 'Aktarımı Başlat ›'}
                </button>
              )}
              {adim === 4 && (
                <button className="d bir" style={{ marginLeft: 'auto' }}
                        onClick={sifirla}>Yeni Aktarım</button>
              )}
            </div>
          </div>
        </>
      )}

      {aktif === 'sablonlar' && (
        <div style={{ padding: 12 }}>
          <div className="not">
            Şablon <b>zorunlu değildir</b> — sihirbaz kendi dosyanızı da okur. Alanlar ve
            zorunluluklar sunucudaki <b>kart tanımından</b> üretilir; elle güncellenmez.
          </div>
          <table className="grid" style={{ marginTop: 10 }}>
            <thead>
              <tr><th>Şablon</th><th style={{ width: 90 }}>Alan</th><th>Zorunlu alanlar</th>
                  <th>Çakışma anahtarı</th><th style={{ width: 140 }} /></tr>
            </thead>
            <tbody>
              {hedefler.map(h => (
                <tr key={h.ad}>
                  <td><b>{h.ikon} {h.baslik}</b></td>
                  <td className="hiza-orta">{h.alanlar.length}</td>
                  <td className="sonuk">
                    {h.alanlar.filter(a => a.zorunlu).map(a => a.baslik).join(', ') || '—'}
                  </td>
                  <td>{h.anahtarlar.map(a => (
                    <span key={a} className="rozet gri" style={{ marginRight: 4 }}>{a}</span>
                  ))}</td>
                  <td>
                    <button className="d" onClick={() => sablonIndir(h.ad)}>↓ Boş Şablon</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="not" style={{ marginTop: 10 }}>
            <b>Fiyat listesi satırı</b> alınırken hedef listeyi sihirbazın ilk adımında
            seçersiniz; kalem <b>kod</b> ile eşleşir (tek "Kod" sütunu verilirse önce
            stokta, yoksa hizmette aranır). <b>Fatura</b> dosyasında her satır bir
            kalemdir: aynı belge numarasını taşıyan satırlar tek faturaya toplanır,
            cari koddan / vergi numarasından / unvandan çözülür ve <b>zaten kayıtlı
            numara yeniden yazılmaz</b>. Kasa hareketi aktarımı bu sürümde yok.
          </div>
        </div>
      )}

      {aktif === 'gecmis' && (
        <div style={{ padding: 12 }}>
          <table className="grid">
            <thead>
              <tr><th>Yükleme</th><th>Tarih</th><th>Kullanıcı</th><th>Hedef</th><th>Dosya</th>
                  <th className="hiza-sag">Eklenen</th><th className="hiza-sag">Güncellenen</th>
                  <th className="hiza-sag">Atlanan</th><th>Durum</th></tr>
            </thead>
            <tbody>
              {gecmis.map(y => (
                <tr key={y.id}>
                  <td>#{y.id}</td>
                  <td>{tarihMetni(y.tarih)}</td>
                  <td>{y.kullanici}</td>
                  <td>{y.hedef}</td>
                  <td className="sonuk">{y.dosyaAdi}</td>
                  <td className="hiza-sag">{y.eklenen.toLocaleString('tr')}</td>
                  <td className="hiza-sag">{y.guncellenen.toLocaleString('tr')}</td>
                  <td className="hiza-sag">{y.atlanan.toLocaleString('tr')}</td>
                  <td>
                    <span className={`rozet ${DURUM_ADI[y.durum]?.sinif ?? 'gri'}`}>
                      {DURUM_ADI[y.durum]?.ad ?? y.durum}
                    </span>
                  </td>
                </tr>
              ))}
              {gecmis.length === 0 && (
                <tr><td colSpan={9} className="sonuk">Henüz yükleme yok.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {aktif === 'kurallar' && (
        <div style={{ padding: 12 }}>
          <div className="not">
            Kural, sihirbazda <b>"Eşlemeyi Sakla"</b> dediğinizde doğar. Bir dahaki aynı
            başlık düzenindeki dosyada eşleme hazır gelir. Dosya düzeni değişirse kural
            tutmaz, sihirbaz yine önerir.
          </div>
          <table className="grid" style={{ marginTop: 10 }}>
            <thead>
              <tr><th>Kural</th><th>Hedef</th><th>Başlıklar</th>
                  <th className="hiza-sag">Alan</th><th>Son kullanım</th><th style={{ width: 80 }} /></tr>
            </thead>
            <tbody>
              {kurallar.map(k => (
                <tr key={k.id}>
                  <td><b>{k.ad}</b></td>
                  <td>{k.hedef}</td>
                  <td className="sonuk" style={{ maxWidth: 380, overflow: 'hidden',
                                                 textOverflow: 'ellipsis' }}
                      title={k.basliklar}>{k.basliklar}</td>
                  <td className="hiza-sag">{k.alanSayisi}</td>
                  <td className="sonuk">{k.sonKullanim ? tarihMetni(k.sonKullanim) : '—'}</td>
                  <td>
                    <button className="d teh" onClick={() => void (async () => {
                      if (!await onaySor(`"${k.ad}" kuralı silinsin mi?`)) return;
                      try {
                        await api.iceriAlmaKuralSil(k.id);
                        setKurallar(t => t.filter(x => x.id !== k.id));
                      } catch (e) { setHata(hataMetni(e)) }
                    })()}>🗑</button>
                  </td>
                </tr>
              ))}
              {kurallar.length === 0 && (
                <tr><td colSpan={6} className="sonuk">Kayıtlı kural yok.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}
