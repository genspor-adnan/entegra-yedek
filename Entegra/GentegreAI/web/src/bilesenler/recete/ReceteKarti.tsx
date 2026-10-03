import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { GenGrid } from '../GenGrid';
import { KaynakArama } from '../KaynakArama';
import { guvenli, mesaj, onay } from '../mesaj';
import { c } from '../../dil/ceviri';

/**
 * REÇETE KARTI — mockup `Ekranlar/Muayene/recete_karti.html`.
 *
 * Reçete bir BELGEDİR: imzalanınca değişmez. Bu yüzden kartın bütün yazma
 * düğmeleri durumu okur - taslakta tür/açıklama/ilaç düzenlenir, imzalıda
 * yalnız Medula'ya gönderilir. İmza ve Medula alanları SALT OKUNUR; onları
 * düğmeler (uçlar) yazar.
 *
 * Tanı reçetede GÖSTERİLMEZ (kullanıcı: "reçetedeki tanıyı kaldır"); tanı
 * muayenede girilir ve sunucu tarafı onu muayeneden okur.
 * Alerji / etkileşim uyarısı
 * ENGEL değil: ilaç eklenirken sunucu uyarır, geçilen uyarı satırda kalır ve
 * sağ panelde listelenir.
 */

const TURLER: { kod: number; ad: string; renk: string }[] = [
  { kod: 0, ad: 'Normal', renk: '#ffffff' },
  { kod: 1, ad: 'Kırmızı', renk: '#e54848' },
  { kod: 2, ad: 'Yeşil', renk: '#3fa45b' },
  { kod: 3, ad: 'Mor', renk: '#8a55c9' },
  { kod: 4, ad: 'Turuncu', renk: '#f0932b' },
];
const DURUM: Record<number, { ad: string; sinif: string }> = {
  1: { ad: 'Taslak', sinif: 'uyari' }, 2: { ad: 'İmzalı', sinif: 'olumlu' },
  3: { ad: 'Medula Kabul', sinif: 'olumlu' }, 4: { ad: 'İptal', sinif: 'gri' },
};
export const KULLANIM_SEKILLERI: { kod: number; ad: string }[] = [
  { kod: 1, ad: 'Ağızdan' }, { kod: 2, ad: 'Damardan' }, { kod: 3, ad: 'Kas içi' },
  { kod: 4, ad: 'Cilt altı' }, { kod: 5, ad: 'Haricen' }, { kod: 6, ad: 'Solunum' },
  { kod: 7, ad: 'Rektal' },
];

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);
const zaman = (v: unknown) => {
  const s = metin(v);
  if (!s) return '';
  const d = new Date(s);
  return Number.isNaN(d.getTime()) ? s : d.toLocaleString('tr-TR', {
    day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
};

export function ReceteKarti({ receteId, onKapat, onDegisti, gomulu, ekAraclar, ilacAra, onIlacAraTamam }: {
  receteId: number;
  onKapat(): void;
  /** Reçete değişince (kayıt, imza, ilaç) çağırana haber. */
  onDegisti?(): void;
  /** PENCERESİZ (muayene kartının e-Reçete sekmesi - kullanıcı: "recete_karti
      mockup'ı gibi yap"): aynı gövde sekmenin içinde çizilir; düğmeler üstte,
      kimlik şeridi yok (muayene kartı zaten hastayı gösteriyor). */
  gomulu?: boolean;
  /** Gömülü kipte araç çubuğuna eklenen düğmeler (ör. reçete şablonu). */
  ekAraclar?: React.ReactNode;
  /** İLAÇ ARAMAYI AÇ İSTEĞİ (muayene özeti › kontrol listesi "Reçete"): kart
      yüklenince taslaksa arama açılır; istek her durumda tüketilir. */
  ilacAra?: boolean;
  onIlacAraTamam?(): void;
}) {
  const [kart, setKart] = useState<Record<string, unknown> | null>(null);
  const [surum, setSurum] = useState<string | undefined>();
  /** Kod alanlarinin adlari (hasta / hekim) - kart okumasiyla gelir. */
  const [kodAd, setKodAd] = useState<Record<string, Record<string, string>>>({});
  const [hata, setHata] = useState<string | null>(null);
  const [tur, setTur] = useState(0);
  const [aciklama, setAciklama] = useState('');
  const [muayene, setMuayene] = useState<ListeSatiri | null>(null);
  const [alerjiler, setAlerjiler] = useState<ListeSatiri[]>([]);
  const [aktifIlac, setAktifIlac] = useState<ListeSatiri[]>([]);
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [isaretli, setIsaretli] = useState<ListeSatiri[]>([]);
  const [secili, setSecili] = useState<ListeSatiri | null>(null);
  const [aramaAcik, setAramaAcik] = useState(false);
  /** 📷 Karekod okutma penceresi (mockup muayene_karti_v2 reçete araç çubuğu). */
  const [karekodAcik, setKarekodAcik] = useState(false);
  const [karekod, setKarekod] = useState('');
  const [satirDuzen, setSatirDuzen] = useState<ListeSatiri | null>(null);
  const [tazele, setTazele] = useState(0);

  const yukle = useCallback(async () => {
    try {
      const y = await api.kartOku('recete', receteId);
      setKart(y.kart);
      setSurum(y.kart.surum);
      setKodAd(y.kodAd ?? {});
      setTur(sayi(y.kart.tur));
      setAciklama(metin(y.kart.aciklama));
      const muayeneId = sayi(y.kart.muayeneId);
      const hastaId = sayi(y.kart.hastaId);
      const [m, a, i, s] = await Promise.all([
        api.liste('muayene', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: muayeneId } })
           .then(r => r.satirlar[0] ?? null).catch(() => null),
        api.liste('hasta-alerji', { sayfa: 1, boyut: 20, filtre: { alan: 'hastaId', op: 'esit', deger: hastaId } })
           .then(r => r.satirlar.filter(x => sayi(x.aktif ?? 1) === 1)).catch(() => []),
        api.liste('hasta-ilac', { sayfa: 1, boyut: 20, filtre: { alan: 'hastaId', op: 'esit', deger: hastaId } })
           .then(r => r.satirlar.filter(x => sayi(x.aktif ?? 1) === 1)).catch(() => []),
        api.liste('recete-satir', { sayfa: 1, boyut: 200, filtre: { alan: 'receteId', op: 'esit', deger: receteId } })
           .then(r => r.satirlar).catch(() => []),
      ]);
      setMuayene(m); setAlerjiler(a); setAktifIlac(i); setSatirlar(s);
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [receteId]);

  useEffect(() => { void yukle() }, [yukle, tazele]);
  useEffect(() => {
    if (!ilacAra || !kart) return;
    if (sayi(kart.durum) === 1) setAramaAcik(true);
    onIlacAraTamam?.();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [ilacAra, kart]);

  const yenile = () => { setTazele(t => t + 1); setIsaretli([]); onDegisti?.() };
  const filtre = useMemo(() => ({ alan: 'receteId', op: 'esit' as const, deger: receteId }), [receteId]);

  if (!kart) {
    if (gomulu)
      return hata ? <div className="hata-kutusu">{hata}</div>
                  : <div className="yukleniyor-satir">{c('Yükleniyor…')}</div>;
    return (
      <Modal baslik={c('Reçete')} buyutmeYok onKapat={onKapat}
             alt={<button type="button" className="d" onClick={onKapat}>{c('Kapat')}</button>}>
        {hata ? <div className="hata-kutusu">{hata}</div> : <div className="yukleniyor-satir">{c('Yükleniyor…')}</div>}
      </Modal>
    );
  }

  const durum = sayi(kart.durum);
  const taslak = durum === 1;
  const muayeneId = sayi(kart.muayeneId);
  const degisti = taslak && (tur !== sayi(kart.tur) || aciklama !== metin(kart.aciklama));
  const receteNo = metin(kart.receteNo);
  const uyarilar = satirlar.filter(s => metin(s.uyari) !== '');
  const toplamKutu = satirlar.reduce((t, s) => t + sayi(s.kutu), 0);
  const duzenlenecek = isaretli[0] ?? secili;

  const kaydet = () => guvenli(async () => {
    const y = await api.kartGuncelle('recete', receteId, { surum, kart: { tur, aciklama } });
    setKart(y.kart); setSurum(y.kart.surum);
    onDegisti?.();
  });

  const imzala = () => guvenli(async () => {
    if (degisti) await api.kartGuncelle('recete', receteId, { surum, kart: { tur, aciklama } });
    if (!await onay('Reçete imzalanacak. İmzalanan reçete değiştirilemez, ilaçlar hastanın '
                  + 'aktif ilaç listesine işlenir. Onaylıyor musunuz?')) return;
    const y = await api.receteImzala(receteId);
    mesaj(y.mesaj);
    yenile();
  });

  /** e-İMZALA & MEDULA'YA GÖNDER (mockup): imza, ardından Medula. Medula
      reddederse imza YİNE geçerlidir - mesaj ikisini ayrı söyler. */
  const imzalaGonder = () => guvenli(async () => {
    if (degisti) await api.kartGuncelle('recete', receteId, { surum, kart: { tur, aciklama } });
    if (!await onay('Reçete imzalanıp Medula\'ya gönderilecek. İmzalanan reçete değiştirilemez. '
                  + 'Onaylıyor musunuz?')) return;
    const y = await api.receteImzala(receteId);
    let medula = '';
    try {
      const g = await api.medulaReceteGonder(receteId);
      medula = String((g as { mesaj?: string }).mesaj ?? 'Medula\'ya gönderildi.');
    } catch (h) { medula = `Medula: ${hataMetni(h)}` }
    mesaj(`${y.mesaj}\n${medula}`);
    yenile();
  });

  const medulayaGonder = () => guvenli(async () => {
    const y = await api.medulaReceteGonder(receteId);
    mesaj(String((y as { mesaj?: string }).mesaj ?? 'Medula\'ya gönderildi.'));
    yenile();
  });

  const kopyala = () => guvenli(async () => {
    const y = await api.receteOncekiKopyala(muayeneId);
    mesaj(y.mesaj);
    yenile();
  });

  const sil = () => guvenli(async () => {
    if (!await onay('Taslak reçete silinecek. Onaylıyor musunuz?')) return;
    await api.kartSil('recete', receteId);
    onDegisti?.();
    onKapat();
  });

  const ilacCikar = () => guvenli(async () => {
    if (isaretli.length === 0) return;
    if (!await onay(`${isaretli.length} ilaç reçeteden çıkarılacak. Onaylıyor musunuz?`)) return;
    for (const s of isaretli) await api.receteIlacSil(receteId, sayi(s.id));
    yenile();
  });

  /** Uyarılı eklemede sunucunun uyarısı gösterilir (alerji / etkileşim). */
  const ilacEkle = (barkod: string, ad: string, kare?: string) => guvenli(async () => {
    const y = await api.receteIlacEkle(muayeneId, kare ? { barkod: '', karekod: kare } : { barkod });
    const u = (y.uyarilar ?? []) as { metin?: string }[];
    if (u.length) mesaj(`${ad} eklendi.\n\nUYARI:\n· ${u.map(x => x.metin ?? '').join('\n· ')}`);
    yenile();
  });

  const hastaAdi = metin(muayene?.hastaAdi) || (kodAd.hastaId?.[String(kart.hastaId ?? '')] ?? '');
  const d = DURUM[durum] ?? DURUM[1];
  const turAdi = TURLER.find(t => t.kod === sayi(kart.tur))?.ad ?? 'Normal';

  const kimlik = (
          <div className="rk-kimlik">
            <b className="rk-ad">{hastaAdi || '—'}</b>
            {metin(muayene?.protokolNo) && <span className="sonuk">{c('Protokol')} {metin(muayene?.protokolNo)}</span>}
            <span className="sonuk">
              {c('Muayene')} <b>#{muayeneId}</b>
              {metin(muayene?.bolumAdi) && ` · ${metin(muayene?.bolumAdi)}`}
              {metin(muayene?.hekimAdi) && ` · ${metin(muayene?.hekimAdi)}`}
            </span>
            <span className="sonuk">{zaman(muayene?.baslangic)}</span>
            <span className="rk-bosluk" />
            <span className={`rozet ${d.sinif}`}>{d.ad}</span>
            <span className="rozet gri">{turAdi} {c('reçete')}</span>
            {alerjiler.slice(0, 3).map((a, i) => (
              <span key={i} className="rozet hata" title={metin(a.etkenMadde)}>
                ⚠ {c('Alerji')}: {metin(a.etken) || metin(a.etkenMadde)}
              </span>
            ))}
          </div>
  );

  const dugmeler = (<>
          {taslak && (
            <button type="button" className="d bir" disabled={!degisti} onClick={() => void kaydet()}>
              💾 {c('Kaydet')}
            </button>
          )}
          {taslak && (
            <button type="button" className="d onay" disabled={satirlar.length === 0}
                    title={satirlar.length ? '' : c('Önce ilaç ekleyin')}
                    onClick={() => void imzala()}>✍ {c('e-İmzala')}</button>
          )}
          {durum === 2 && (
            <button type="button" className="d" onClick={() => void medulayaGonder()}>
              📤 {c("Medula'ya Gönder")}
            </button>
          )}
          {taslak && (
            <button type="button" className="d onay" disabled={satirlar.length === 0}
                    title={satirlar.length ? '' : c('Önce ilaç ekleyin')}
                    onClick={() => void imzalaGonder()}>✍ {c("e-İmzala & Medula'ya Gönder")}</button>
          )}
          {taslak && (
            <button type="button" className="d" title={c('Önceki reçeteyi kopyala')}
                    onClick={() => void kopyala()}>
              🕘 {gomulu ? c('Önceki reçete') : c('Önceki reçeteyi kopyala')}
            </button>
          )}
          {/* KAREKOD ve KULLANDIGI ILACLARDAN (mockup muayene_karti_v2 recete
              arac cubugu): ilac eklemenin iki kisa yolu. */}
          {taslak && (
            <button type="button" className="d" onClick={() => { setKarekod(''); setKarekodAcik(true) }}>
              📷 {c('Karekod')}
            </button>
          )}
          {taslak && aktifIlac.length > 0 && (
            <select className="recete-sablon" value="" aria-label={c('Kullandığı ilaçlardan ekle')}
                    onChange={e => {
                      const x = aktifIlac.find(a => metin(a.barkod) === e.target.value);
                      if (x) void ilacEkle(metin(x.barkod), metin(x.ilacAd));
                    }}>
              <option value="">💊 {c('Kullandığı ilaçlardan…')}</option>
              {aktifIlac.filter(a => metin(a.barkod)).map((a, i) => (
                <option key={i} value={metin(a.barkod)}>{metin(a.ilacAd)}</option>
              ))}
            </select>
          )}
          {satirlar.length > 0 && (
            <span className={`rozet ${uyarilar.length ? 'hata' : 'olumlu'}`}
                  title={uyarilar.length ? c('Etkileşim / alerji uyarısı var') : c('Etkileşim / alerji: temiz')}>
              {uyarilar.length ? `⚠ ${uyarilar.length} ${c('uyarı')}` : `✓ ${c('Uyarı yok')}`}
            </span>
          )}
          {gomulu && ekAraclar}
          <span style={{ marginLeft: 'auto' }} />
          {gomulu && <span className={`rozet ${d.sinif}`}>{d.ad}{receteNo ? ` · ${receteNo}` : ''}</span>}
          {taslak && (
            <button type="button" className="d teh" title={c('Taslak reçeteyi sil')}
                    onClick={() => void sil()}>{gomulu ? '🗑' : `🗑 ${c('Sil')}`}</button>
          )}
          {!gomulu && (
            <button type="button" className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
          )}
        </>);

  const govde = (<>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="rk-govde">
          <div className="rk-sol">
            <div className="kagrup">
              {/* TÜR SEÇİMİ BAŞLIKTA (kullanıcı: "reçete türü başlığı olmadan
                  reçete bilgileri başlığına yerleştir"). Varsayılan Normal:
                  sunucu yeni reçeteyi tür 0 ile açar. */}
              <h6 className="rk-bilgi-bas">{c('Reçete bilgileri')}
                <span className="rk-tur-sec rk-tur-sag" role="radiogroup" aria-label={c('Reçete türü')}>
                  {TURLER.map(t => (
                    <button key={t.kod} type="button" role="radio" aria-checked={tur === t.kod}
                            disabled={!taslak}
                            className={`rk-tur${tur === t.kod ? ' on' : ''}`}
                            onClick={() => setTur(t.kod)}>
                      <i style={{ background: t.renk }} />{t.ad}
                    </button>
                  ))}
                </span>
              </h6>
            </div>

            {/* ILACLAR: ayni GenGrid deseni (muayenedeki recete gridi) -
                isaretli satirlara toplu islem, satir duzeltme pencerede. */}
            <div className="kagrup recete-grid">
              <div className="numaralama-bas bitisik">
                <span className="baslik-eylem">
                  {taslak && (
                    <button type="button" className="d bir" onClick={() => setAramaAcik(true)}>
                      ＋ {c('İlaç')}
                    </button>
                  )}
                  {taslak && (
                    <button type="button" className="d ikon-dugme" disabled={!duzenlenecek}
                            aria-label={c('Düzenle')} title={c('Seçili ilacı düzenle')}
                            onClick={() => duzenlenecek && setSatirDuzen(duzenlenecek)}>✎</button>
                  )}
                  {taslak && (
                    <button type="button" className="d teh ikon-dugme" disabled={isaretli.length === 0}
                            aria-label={c('Sil')}
                            title={isaretli.length ? `${c('İşaretli ilaçları çıkar')} (${isaretli.length})` : c('Önce satır işaretleyin')}
                            onClick={() => void ilacCikar()}>🗑</button>
                  )}
                </span>
                <h6>
                  {c('İlaçlar')}
                  {uyarilar.length > 0 && (
                    <span className="rozet hata">⚠ {uyarilar.length} {c('etkileşim / alerji uyarısı')}</span>
                  )}
                  <span className="sonuk">{satirlar.length} {c('ilaç')} · {toplamKutu} {c('kutu')}</span>
                </h6>
              </div>
              <GenGrid
                key={`rk-${receteId}-${tazele}`}
                kaynak="recete-satir"
                gomulu seritGizli aramaGizli
                boyut={100}
                sabitFiltre={filtre}
                gizliKolonlar={['receteNo', 'receteDurumAdi']}
                onIsaretliDegisti={setIsaretli}
                onSecimDegisti={setSecili}
                onSatirAc={r => { if (taslak) setSatirDuzen(r) }}
              />
            </div>
            {/* ACIKLAMA ILAC GRIDININ ALTINDA (kullanici): receteye basilan
                not ilaclardan sonra yazilir. */}
            <div className="rk-fld rk-tam rk-aciklama">
              <label htmlFor="rk-aciklama">{c('Açıklama (reçeteye basılır)')}</label>
              <input id="rk-aciklama" value={aciklama} maxLength={200} disabled={!taslak}
                     onChange={e => setAciklama(e.target.value)} />
            </div>
            <p className="not">
              {taslak
                ? c('Satıra tık = seç · çift tık = düzenle. İmzalanan reçeteden ilaç çıkarılamaz; ilaçlar hastanın aktif ilaç listesine işlenir.')
                : c('İmzalı reçete değiştirilemez; yanlış ilaç varsa reçete iptal edilip yenisi yazılır.')}
            </p>
          </div>

          <div className="rk-sag">
            {uyarilar.length > 0 && (
              <div className="rk-bant hata">
                <b>⚠ {c('Alerji / etkileşim uyarısı')}</b>
                {uyarilar.map((s, i) => (
                  <div key={i}><b>{metin(s.ilac)}</b> — {metin(s.uyari)}</div>
                ))}
                <div className="sonuk">{c('Hekim gerekçeyle geçti; gerekçe reçete satırında kalır.')}</div>
              </div>
            )}
            {uyarilar.length === 0 && satirlar.length > 0 && (
              <div className="rk-bant olumlu">{c('Etkileşim / alerji: temiz')}</div>
            )}
            <div className="rk-blk">
              <h6>{c('Hastanın aktif ilaçları')}</h6>
              <div className="rk-chips">
                {aktifIlac.length === 0 && <span className="rozet olumlu">{c('Aktif ilaç: yok')}</span>}
                {aktifIlac.map((x, i) => (
                  <span key={i} className="rozet mavi">
                    {metin(x.ilacAd)}{metin(x.doz) ? ` · ${metin(x.doz)}` : ''}
                  </span>
                ))}
              </div>
            </div>
            <div className="rk-blk">
              <h6>{c('İmza ve Medula')}</h6>
              <div className="rk-kv">
                <span>{c('Reçete no')}</span><span>{receteNo || '—'}</span>
                <span>{c('İmza')}</span><span>{zaman(kart.imzaZamani) || c('— (imzalanmadı)')}</span>
                <span>{c('Medula gönderim')}</span><span>{zaman(kart.medulaGonderim) || '—'}</span>
                <span>{c('Medula sonucu')}</span><span>{metin(kart.medulaSonuc) || c('Medula kapısı açık değil')}</span>
              </div>
              <p className="not">{c('Bu alanları düğmeler yazar; elle "imzalı" yapılamaz.')}</p>
            </div>
          </div>
        </div>
  </>);

  return (
    <>
      {gomulu
        ? <div className="rk-gomulu"><div className="muayene-arac rk-arac">{dugmeler}</div>{govde}</div>
        : (
          <Modal
            baslik={`${c('Reçete')} — ${d.ad}${receteNo ? ` · ${receteNo}` : ''}`}
            ekSinif="kart-recete"
            onKapat={onKapat}
            ustSerit={kimlik}
            alt={dugmeler}>
            {govde}
          </Modal>
        )}

      {aramaAcik && (
        <KaynakArama
          kaynak="ilac" baslik="İlaç ara (barkod / ad / etken madde)"
          kodAlani="barkod" adAlani="ad"
          ekKosul={{ alan: 'aktif', op: 'esit', deger: 1 }}
          // YZ ÖNERİSİ: etken madde -> katalog ürünleri; alerjiyle çakışan sunucuda
          //   elenir, doz önerilmez. Eklemede alerji/etkileşim uyarısı yine çalışır.
          yz={async () => {
            const y = await api.muayeneYzIlacOnerisi(muayeneId);
            return {
              satirlar: y.oneriler.map(o => ({ kod: o.barkod, barkod: o.barkod, ad: o.ad, gerekce: o.gerekce })),
              notlar: [...y.notlar, ...(y.oneriler.length === 0 ? ['YZ bu bilgilerle ilaç önermedi.'] : [])],
              uyari: y.uyari,
            };
          }}
          onKapat={() => setAramaAcik(false)}
          onSec={satir => {
            setAramaAcik(false);
            void ilacEkle(String(satir.barkod ?? ''), String(satir.ad ?? ''));
          }}
        />
      )}
      {karekodAcik && (
        <Modal baslik={c('Karekod ile ilaç ekle')} dar enUst buyutmeYok onKapat={() => setKarekodAcik(false)}
               alt={<>
                 <button type="button" className="d bir" disabled={!karekod.trim()}
                         onClick={() => { setKarekodAcik(false); void ilacEkle('', c('İlaç'), karekod.trim()) }}>
                   ＋ {c('Ekle')}
                 </button>
                 <button type="button" className="d" onClick={() => setKarekodAcik(false)}>{c('Vazgeç')}</button>
               </>}>
          <div className="rk-satir">
            <label className="rk-tam">{c('Kutunun karekodunu okutun')}
              <input autoFocus value={karekod} onChange={e => setKarekod(e.target.value)}
                     onKeyDown={e => {
                       if (e.key === 'Enter' && karekod.trim()) {
                         e.preventDefault(); setKarekodAcik(false); void ilacEkle('', c('İlaç'), karekod.trim());
                       }
                     }}
                     placeholder="01086…21…17…10…" />
            </label>
            <p className="sonuk">{c('Okuyucu karekodu yazıp Enter gönderir; ilaç katalogdaki barkoduyla eklenir.')}</p>
          </div>
        </Modal>
      )}
      {satirDuzen && (
        <ReceteSatirPenceresi receteId={receteId} satir={satirDuzen}
          onKapat={() => setSatirDuzen(null)}
          onKaydedildi={() => { setSatirDuzen(null); yenile() }} />
      )}
    </>
  );
}

/** Reçete satırı düzeltme: ilaç değişmez; doz, periyot, kullanım, süre, kutu, tarif. */
function ReceteSatirPenceresi({ receteId, satir, onKapat, onKaydedildi }: {
  receteId: number; satir: ListeSatiri; onKapat(): void; onKaydedildi(): void;
}) {
  const [doz, setDoz] = useState(metin(satir.doz));
  const [periyot, setPeriyot] = useState(metin(satir.periyot));
  const [kullanim, setKullanim] = useState(sayi(satir.kullanimSekli));
  const [sure, setSure] = useState(sayi(satir.sureGun));
  const [kutu, setKutu] = useState(Math.max(1, sayi(satir.kutu)));
  const [tarif, setTarif] = useState(metin(satir.aciklama));

  const kaydet = () => guvenli(async () => {
    await api.receteSatirGuncelle(receteId, sayi(satir.id), {
      doz, periyot, kullanimSekli: kullanim, sureGun: sure, kutu, aciklama: tarif });
    onKaydedildi();
  });

  return (
    <Modal baslik={`${c('İlaç')} — ${metin(satir.ilac)}`} dar enUst buyutmeYok onKapat={onKapat}
           alt={<>
             <button type="button" className="d bir" onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>
             <button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>
           </>}>
      <div className="rk-satir">
        <p className="sonuk">{metin(satir.barkod)}{metin(satir.etkenMadde) ? ` · ${metin(satir.etkenMadde)}` : ''}</p>
        <label>{c('Doz')}<input value={doz} maxLength={20} onChange={e => setDoz(e.target.value)} placeholder="1x1" /></label>
        <label>{c('Periyot')}<input value={periyot} maxLength={20} onChange={e => setPeriyot(e.target.value)} placeholder="3x1" /></label>
        <label>{c('Kullanım')}
          <select value={kullanim} onChange={e => setKullanim(Number(e.target.value))}>
            <option value={0}>—</option>
            {KULLANIM_SEKILLERI.map(k => <option key={k.kod} value={k.kod}>{k.ad}</option>)}
          </select>
        </label>
        <label>{c('Süre (gün)')}<input type="number" min={0} max={365} value={sure}
                                        onChange={e => setSure(Number(e.target.value))} /></label>
        <label>{c('Kutu')}<input type="number" min={1} max={99} value={kutu}
                                  onChange={e => setKutu(Number(e.target.value))} /></label>
        <label className="rk-tam">{c('Tarif')}<input value={tarif} maxLength={200}
                                  onChange={e => setTarif(e.target.value)} placeholder={c('Tok karnına…')} /></label>
      </div>
    </Modal>
  );
}
