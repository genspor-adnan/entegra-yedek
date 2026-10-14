import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { KaynakArama } from './KaynakArama';
import { ReceteKarti } from './recete/ReceteKarti';
import type { SablonTercihleri } from '../api/uclar/liste';
import { guvenli, mesaj } from './mesaj';
import { tarihSaat, para } from './bicim';
import { c } from '../dil/ceviri';
import { MUAYENE_DURUM } from './muayeneKodlari';
import { Modal } from './Modal';

/**
 * MUAYENE KARTININ EK SEKMELERİ (mockup `muayene_karti.html`):
 * e-Reçete · Sevk / Konsültasyon · İşlem & Ücret · Geçmiş.
 *
 * <b>Tek uç, dört sekme:</b> dördü de aynı muayenenin çevresindeki kayıtlar;
 * sekme değiştikçe ayrı istek atmak kart açılışını dört gidiş dönüşe
 * çıkarırdı. Veri `GET /api/muayene/{id}/sekme-verisi`den gelir.
 *
 * <b>Bu sekmeler YAZMAZ:</b> reçete Reçeteler ekranında, ücret satırı
 * başvuru belgesinde, konsültasyon yeni bir muayene olarak oluşur. Burada
 * gösterilen her satır o kayıtların ÖZETİDİR - aynı kural iki yerde
 * yazılmasın.
 */

type Satir = Record<string, unknown>;

export interface SekmeVerisi {
  belgeId: number | null;
  ustMuayeneId: number | null;
  /** Muayenenin tanı kodları ("I21.0 · E11.9") - reçete başlığında görünür. */
  tanilar: string;
  receteler: Satir[];
  receteSatirlari: Satir[];
  konsultasyonlar: Satir[];
  islemler: Satir[];
  gecmis: Satir[];
}

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);

// Reçete türü / durum / kullanım adları artık SUNUCUDA (recete-satir listesi).

/** Sekme verisini bir kez çeker; dört sekme aynı sonucu kullanır. */
export function useMuayeneSekmeVerisi(muayeneId: number, tazele: number) {
  const [veri, setVeri] = useState<SekmeVerisi | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    if (!(muayeneId > 0)) return;
    try { setVeri(await api.muayeneSekmeVerisi(muayeneId) as never) }
    catch (h) { setHata(hataMetni(h)) }
  }, [muayeneId]);

  useEffect(() => { void yukle() }, [yukle, tazele]);
  return { veri, hata };
}

function Kabuk({ hata, veri, children }:
  { hata: string | null; veri: SekmeVerisi | null; children: React.ReactNode }) {
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;
  return <>{children}</>;
}

/**
 * e-REÇETE SEKMESİ (mockup Ekranlar/Muayene/recete_karti.html - kullanıcı:
 * "e-reçete sekmesini recete_karti gibi yap").
 *
 * Gövde REÇETE KARTININ KENDİSİ (ReceteKarti, gömülü kip): reçete bilgileri
 * (tür · tanılar · açıklama), ilaç gridi, sağda alerji/etkileşim bandı,
 * aktif ilaçlar, imza ve Medula. Kart ile sekme AYNI bileşen - kural iki
 * yerde yazılmaz. <b>Yazma yolu SUNUCU uçlarıdır</b>: ilaç ekleme reçeteyi
 * yoksa açar ve uyarıyı ekleme ANINDA döndürür; imza reçeteyi kilitler.
 *
 * Gösterilen reçete: açık TASLAK, yoksa en son reçete. Muayenede birden çok
 * reçete varsa üstte seçici çıkar. Hiç reçete yoksa boş durum: ilk ilaç
 * eklenince reçete sunucuda açılır.
 */
export function MuayeneReceteSekmesi({ veri, hata, muayeneId, tazele, ilacAra, onIlacAraTamam, kaydetRef }: {
  veri: SekmeVerisi | null; hata: string | null;
  muayeneId: number;
  tazele(): void;
  /** İLAÇ ARAMAYI AÇ (özet › kontrol listesi "Reçete"): taslak varsa onun
      araması, yoksa ilk ilacın araması (sunucu yeni taslak açar). */
  ilacAra?: boolean;
  onIlacAraTamam?(): void;
  /** Gösterilen reçetenin dış kaydet bağlantısı (muayene çerçevesi 💾). */
  kaydetRef?: { current: (() => Promise<void>) | null };
}) {
  const [aramaAcik, setAramaAcik] = useState(false);
  /** Kullanıcının seçtiği reçete (birden çok reçetede); null = varsayılan. */
  const [secilenId, setSecilenId] = useState<number | null>(null);
  /** Bölüm / doktor şablonlarının reçete şablonları (931). */
  const [sablonReceteleri, setSablonReceteleri] = useState<SablonTercihleri['receteler']>([]);
  useEffect(() => {
    let iptal = false;
    void api.muayeneSablonTercihleri(muayeneId)
      .then(y => { if (!iptal) setSablonReceteleri(y.receteler) })
      .catch(() => { /* şablon tercihi yoksa düğme çıkmaz */ });
    return () => { iptal = true };
  }, [muayeneId]);

  /** REÇETE ŞABLONU (931): gruptaki ilaçlar sırayla yazılır; uyarılar tek mesajda. */
  const sablondanYaz = (i: number) => guvenli(async () => {
    const r = sablonReceteleri[i];
    if (!r) return;
    const uyarilar: string[] = [];
    for (const s of r.satirlar) {
      const y = await api.receteIlacEkle(muayeneId, { barkod: s.barkod, doz: s.doz, periyot: s.periyot,
        sureGun: s.sureGun, kutu: s.kutu, aciklama: s.aciklama });
      if (s.kullanimSekli > 0)
        await api.receteSatirGuncelle(y.receteId, y.satirId, { kullanimSekli: s.kullanimSekli });
      ((y.uyarilar ?? []) as { metin?: string }[]).forEach(u => uyarilar.push(`${s.ilac}: ${u.metin ?? ''}`));
    }
    tazele();
    mesaj(`${r.grup}: ${r.satirlar.length} ilaç yazıldı.`
      + (uyarilar.length ? `\n\nUYARI:\n· ${uyarilar.join('\n· ')}` : ''));
  });

  /** İlk ilaç (reçete yokken): sunucu reçeteyi açar, uyarıyı döndürür. */
  const ilacEkle = (barkod: string, ad: string) => guvenli(async () => {
    const y = await api.receteIlacEkle(muayeneId, { barkod });
    const uyari = (y.uyarilar ?? []) as { metin?: string }[];
    if (uyari.length)
      mesaj(`${ad} eklendi.\n\nUYARI:\n· ${uyari.map(u => u.metin ?? '').join('\n· ')}`);
    tazele();
  });

  const receteler = [...(veri?.receteler ?? [])].sort((a, b) => sayi(b.id) - sayi(a.id));
  const varsayilan = receteler.find(r => sayi(r.durum) === 1) ?? receteler[0];
  const gosterilen = receteler.find(r => sayi(r.id) === secilenId) ?? varsayilan;
  const taslakGosteriliyor = sayi(gosterilen?.durum) === 1;

  // Taslak gösteriliyorsa istek ReceteKarti'ye geçer (aramayı o açar);
  //   taslak yoksa (reçete yok ya da hepsi imzalı) burada açılır.
  useEffect(() => {
    if (!ilacAra || !veri || taslakGosteriliyor) return;
    setAramaAcik(true);
    onIlacAraTamam?.();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [ilacAra, veri, taslakGosteriliyor]);

  const sablonSecici = sablonReceteleri.length > 0 && (
    <select className="recete-sablon" value="" aria-label={c('Reçete şablonundan yaz')}
            title={c('Bölüm / doktor şablonundaki hazır reçeteyi yazar')}
            onChange={e => { if (e.target.value !== '') void sablondanYaz(Number(e.target.value)) }}>
      <option value="">📋 {c('Şablondan…')}</option>
      {sablonReceteleri.map((r, i) => (
        <option key={`${r.sablon}-${r.grup}`} value={i}>{r.grup} ({r.satirlar.length}) · {r.sablon}</option>
      ))}
    </select>
  );

  return (
    <Kabuk hata={hata} veri={veri}>
      {aramaAcik && (
        <KaynakArama
          kaynak="ilac" baslik="İlaç ara (barkod / ad / etken madde)"
          kodAlani="barkod" adAlani="ad"
          ekKosul={{ alan: 'aktif', op: 'esit', deger: 1 }}
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

      {/* BIRDEN COK RECETE: hangisinin gosterildigi secilir (taslak once). */}
      {receteler.length > 1 && (
        <div className="muayene-arac rk-secici">
          {receteler.map(r => (
            <button key={sayi(r.id)} type="button"
                    className={`d${sayi(r.id) === sayi(gosterilen?.id) ? ' bir' : ''}`}
                    onClick={() => setSecilenId(sayi(r.id))}>
              {metin(r.receteNo) || `#${sayi(r.id)}`} · {sayi(r.durum) === 1 ? c('Taslak')
                : sayi(r.durum) === 4 ? c('İptal') : c('İmzalı')}
            </button>
          ))}
        </div>
      )}

      {gosterilen ? (
        <ReceteKarti key={sayi(gosterilen.id)} receteId={sayi(gosterilen.id)} gomulu
          ilacAra={ilacAra && taslakGosteriliyor} onIlacAraTamam={onIlacAraTamam}
          ekAraclar={sayi(gosterilen.durum) === 1 ? sablonSecici : null}
          onKapat={() => { setSecilenId(null); tazele() }}
          onDegisti={tazele} kaydetRef={kaydetRef} />
      ) : (
        // BOS DURUM: recete henuz yok - ilk ilac eklenince sunucuda acilir.
        <div className="kagrup rk-bos">
          <div className="muayene-arac">
            <button type="button" className="d bir" onClick={() => setAramaAcik(true)}>＋ {c('İlaç')}</button>
            <button type="button" className="d"
                    onClick={() => void guvenli(async () => {
                      const y = await api.receteOncekiKopyala(muayeneId);
                      mesaj(y.mesaj);
                      tazele();
                    })}>
              🕘 {c('Önceki reçeteyi kopyala')}
            </button>
            {sablonSecici}
          </div>
          <p className="not ic">{c('Bu muayenede reçete yok. İlk ilaç eklenince reçete taslak olarak açılır.')}</p>
        </div>
      )}
    </Kabuk>
  );
}

/** SEVK / KONSÜLTASYON: karttaki sevk alanları + istenen konsültasyonlar. */
export function MuayeneKonsultasyonSekmesi({ veri, hata, icerik }:
  { veri: SekmeVerisi | null; hata: string | null; icerik?: React.ReactNode }) {
  const git = useNavigate();
  return (
    <Kabuk hata={hata} veri={veri}>
      {icerik}
      <div className="kagrup">
        <h6>
          Konsültasyon isteği
          <span className="not">
            kurum içi · {veri?.konsultasyonlar.length ?? 0} istek
          </span>
        </h6>
        {veri?.ustMuayeneId ? (
          <p className="not ic">
            Bu muayene bir konsültasyon isteğidir.{' '}
            <button type="button" className="d"
                    onClick={() => git(`/muayene/${veri.ustMuayeneId}`)}>
              İsteyen muayeneyi aç
            </button>
          </p>
        ) : null}
        {veri && veri.konsultasyonlar.length === 0 ? (
          <p className="not ic">
            İstenen konsültasyon yok. Konsültasyon, hastayı başka bir bölüme
            yönlendiren <b>yeni bir muayene</b> olarak açılır.
          </p>
        ) : (
          /* MOCKUP KOLONLARI: Brans / Hekim · Soru · Istem · Yanit · Durum.
             Soru isteyen hekimin cumlesi, yanit cevaplayanin karari - ikisi de
             konsultasyon muayenesinde durur. */
          <table className="detay-tablo">
            <thead>
              <tr><th>{c('Branş / Hekim')}</th><th>Soru</th>
                  <th className="hiza-orta">İstem</th><th>Yanıt</th>
                  <th className="hiza-orta">Durum</th><th /></tr>
            </thead>
            <tbody>
              {veri?.konsultasyonlar.map(k => {
                const yanit = metin(k.yanit);
                return (
                  <tr key={sayi(k.id)}>
                    <td>{metin(k.bolum) || '—'}
                      {metin(k.hekim) && <span className="sonuk"> · {metin(k.hekim)}</span>}
                    </td>
                    <td>{metin(k.soru) || <span className="sonuk">—</span>}</td>
                    <td className="hiza-orta">{k.tarih ? tarihSaat(k.tarih) : '—'}</td>
                    <td>
                      {yanit ? yanit.slice(0, 120) : <span className="sonuk">bekliyor</span>}
                      {metin(k.anaTani) && (
                        <span className="rozet olumlu" title={c('Konsültasyon tanısı')}>
                          {metin(k.anaTani)}
                        </span>
                      )}
                    </td>
                    <td className="hiza-orta">
                      <span className={`rozet ${sayi(k.durum) === 3 ? 'olumlu' : 'uyari'}`}>
                        {MUAYENE_DURUM[sayi(k.durum)] ?? ''}
                      </span>
                    </td>
                    <td>
                      <button type="button" className="d"
                              onClick={() => git(`/muayene/${sayi(k.id)}`)}>Aç</button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
    </Kabuk>
  );
}

/** İŞLEM & ÜCRET: başvuru belgesinin satırları (tahakkuk oradan çıkar). */
export function MuayeneUcretSekmesi({ veri, hata }:
  { veri: SekmeVerisi | null; hata: string | null }) {
  const git = useNavigate();
  const toplam = (veri?.islemler ?? []).reduce((t, s) => t + sayi(s.tutar), 0);
  return (
    <Kabuk hata={hata} veri={veri}>
      <div className="kagrup">
        <h6>
          İşlem & Ücret
          <span className="not">
            başvuru belgesi{veri?.belgeId ? ` #${veri.belgeId}` : ''}
          </span>
        </h6>
        {veri && veri.islemler.length === 0 ? (
          <p className="not ic">
            Başvuruda ücret satırı yok. Muayene, tetkik ve işlem ücretleri
            başvuru belgesinde toplanır; tamamlanınca tahakkuka düşer.
          </p>
        ) : (
          <table className="detay-tablo">
            <thead>
              <tr><th style={{ width: 110 }}>Kod</th><th>İşlem</th>
                  <th className="hiza-sag">Adet</th><th className="hiza-sag">Birim</th>
                  <th className="hiza-sag">İskonto</th><th className="hiza-orta">KDV</th>
                  <th className="hiza-sag">Tutar</th></tr>
            </thead>
            <tbody>
              {veri?.islemler.map(s => (
                <tr key={sayi(s.id)}>
                  <td>{metin(s.kod) || '—'}</td>
                  <td>{metin(s.ad)}
                    {metin(s.aciklama) && <span className="sonuk"> · {metin(s.aciklama)}</span>}
                  </td>
                  <td className="hiza-sag">{sayi(s.adet).toLocaleString('tr-TR')}</td>
                  <td className="hiza-sag">{para.format(sayi(s.birimFiyat))}</td>
                  <td className="hiza-sag">
                    {sayi(s.iskonto) > 0 ? `%${sayi(s.iskonto)}` : '—'}
                  </td>
                  <td className="hiza-orta">%{sayi(s.kdv)}</td>
                  <td className="hiza-sag"><b>{para.format(sayi(s.tutar))}</b></td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr>
                <td colSpan={6} className="hiza-sag"><b>Toplam</b></td>
                <td className="hiza-sag"><b>{para.format(toplam)}</b></td>
              </tr>
            </tfoot>
          </table>
        )}
        <div className="not">
          Tutarlar başvuru belgesinden okunur; indirim, sigorta payı ve
          tahakkuk kararı orada verilir - aynı hesap iki yerde yapılmaz.
          {veri?.belgeId ? (
            <>
              {' '}
              <button type="button" className="d"
                      onClick={() => git(`/basvuru/${veri.belgeId}`)}>
                Başvuruyu aç
              </button>
            </>
          ) : null}
        </div>
      </div>
    </Kabuk>
  );
}

/**
 * ÖNCEKİ MUAYENEDEN SEÇMELİ KOPYALAMA PENCERESİ (mockup v7): Geçmiş sekmesi ve
 * sekmesiz düzenin sağ sütunu aynı pencereyi açar. Fizik muayene ve vital
 * listede yok - o günün ölçümüdür (sunucu kuralı).
 */
export function OncekiKopyaPenceresi({ muayeneId, kaynakId, onKapat, onKopyalandi }: {
  muayeneId: number; kaynakId: number; onKapat(): void; onKopyalandi(): void;
}) {
  const [kopyaAlan, setKopyaAlan] = useState<string[]>(KOPYA_ALANLARI.map(a => a[0]));
  const kopyala = () => guvenli(async () => {
    if (kopyaAlan.length === 0) return;
    const y = await api.muayeneOncekiKopyala(muayeneId, kaynakId, kopyaAlan);
    onKapat();
    mesaj(y.mesaj);
    onKopyalandi();
  });
  return (
        <Modal baslik={c('Önceki muayeneden kopyala')} dar enUst buyutmeYok onKapat={() => onKapat()}
               alt={<>
                 <button type="button" className="d" onClick={() => onKapat()}>{c('Vazgeç')}</button>
                 <button type="button" className="d bir" disabled={kopyaAlan.length === 0}
                         onClick={() => void kopyala()}>↺ {c('Kopyala')}</button>
               </>}>
          <p className="not">{c('Boş alanlar doldurulur, yazdıklarınız değişmez. Tanılar eklenir; aynı ICD varsa atlanır.')}</p>
          {KOPYA_ALANLARI.map(([k, ad]) => (
            <label key={k} className="kopya-secim">
              <input type="checkbox" checked={kopyaAlan.includes(k)}
                     onChange={e => setKopyaAlan(l => e.target.checked ? [...l, k] : l.filter(x => x !== k))} />
              {c(ad)}
            </label>
          ))}
          <p className="not">{c('Fizik muayene ve vital kopyalanmaz: o günün ölçümüdür.')}</p>
        </Modal>
      
  );
}

/** Önceki muayeneden kopyalanabilen alanlar (sunucu anahtarı, etiket). */
const KOPYA_ALANLARI: [string, string][] = [
  ['sikayet', 'Şikâyet'], ['hikaye', 'Hikâye'],
  ['gecmis', 'Özgeçmiş / soygeçmiş / alışkanlık notları'], ['tanilar', 'Tanılar'],
];

/**
 * GEÇMİŞ (mockup `muayene_karti.html`): solda **Önceki muayeneler (kurum)**
 * - Tarih · Hekim · Tanı · Özet · aç / kopyala; sağda **e-Nabız / dış kurum**
 * kutusu.
 *
 * <b>"↺ Kopyala" sunucuda</b> (seçmeli - pencerede alanlar işaretlenir): kronik hastanın anamnezi ve tanıları önceki
 * muayeneden taşınır; boş alan doldurulur, hekimin yazdığı EZİLMEZ. Fizik
 * muayene ve vital kopyalanmaz - onlar o günün ölçümüdür.
 */
export function MuayeneGecmisSekmesi({ veri, hata, muayeneId, tazele }:
  { veri: SekmeVerisi | null; hata: string | null;
    muayeneId: number; tazele(): void }) {
  const git = useNavigate();

  // SEÇMELİ KOPYALAMA (mockup muayene_karti_v7): hangi alanlar taşınsın.
  //   Fizik muayene ve vital listede YOK - o günün ölçümüdür (sunucu kuralı).
  const [kopyaKaynak, setKopyaKaynak] = useState<number | null>(null);

  return (
    <Kabuk hata={hata} veri={veri}>
      {kopyaKaynak !== null && <OncekiKopyaPenceresi muayeneId={muayeneId} kaynakId={kopyaKaynak}
                                                     onKapat={() => setKopyaKaynak(null)} onKopyalandi={tazele} />}
      <div className="muayene-ikili">
        <div className="mi-sol">
          <div className="kagrup">
            <h6>
              Önceki muayeneler <span className="not">kurum içi</span>
              <span style={{ marginLeft: 'auto' }} />
              <span className="not">{veri?.gecmis.length ?? 0} kayıt</span>
            </h6>
            {veri && veri.gecmis.length === 0 ? (
              <p className="not ic">{c('Bu hastanın başka muayenesi yok.')}</p>
            ) : (
              <table className="detay-tablo">
                <thead>
                  <tr><th className="hiza-orta" style={{ width: 120 }}>Tarih</th>
                      <th>Hekim</th><th>Tanı</th><th>Özet</th><th /></tr>
                </thead>
                <tbody>
                  {veri?.gecmis.map(g => (
                    <tr key={sayi(g.id)}>
                      <td className="hiza-orta">{g.tarih ? tarihSaat(g.tarih) : '—'}</td>
                      <td>{metin(g.hekim) || '—'}
                        {metin(g.bolum) && <span className="sonuk"> · {metin(g.bolum)}</span>}
                      </td>
                      <td>{metin(g.tanilar) || <span className="sonuk">—</span>}</td>
                      <td>{metin(g.ozet) || <span className="sonuk">—</span>}</td>
                      <td className="hiza-orta" style={{ whiteSpace: 'nowrap' }}>
                        <button type="button" className="d ikon-dugme" title={c('Muayeneyi aç')}
                                onClick={() => git(`/muayene/${sayi(g.id)}`)}>📂</button>
                        <button type="button" className="d ikon-dugme"
                                title={c('Anamnez ve tanıları bu muayeneye kopyala')}
                                onClick={() => setKopyaKaynak(sayi(g.id))}>↺</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>

        <div className="mi-sag">
          <div className="kagrup">
            <h6>e-Nabız / dış kurum</h6>
            {/* DIS KURUM GECMISI HENUZ YOK: e-Nabiz sorgu servisi (hasta
                izniyle anlik gecmis) bagli degil. Bos kutu "veri yok" gibi
                okunmasin - neyin eksik oldugu yazili. */}
            <p className="not ic">
              Hastanın başka kurumlardaki kayıtları e-Nabız <b>hasta geçmişi
              sorgusu</b> ile gelir; o servis henüz bağlı değil. Kurumun
              gönderdiği paketler <b>e-Nabız</b> menüsünde izlenir.
            </p>
          </div>
        </div>
      </div>
    </Kabuk>
  );
}

/** Muayenede gösterilen reçete: açık taslak, yoksa en son reçete (sekmeyle aynı kural). */
export function gosterilenRecete(veri: SekmeVerisi | null) {
  const receteler = [...(veri?.receteler ?? [])].sort((a, b) => sayi(b.id) - sayi(a.id));
  return receteler.find(r => sayi(r.durum) === 1) ?? receteler[0];
}

/**
 * REÇETE GÖSTERİM KİPİ (kullanıcı 15.10.2026, mockup v7 "Reçete" tablosu): ilaç · doz · kutu
 * ve reçete no / durum satırı. Düzenleme reçete kartının kendisi (MuayeneReceteSekmesi).
 */
export function ReceteGosterim({ veri }: { veri: SekmeVerisi | null }) {
  const r = gosterilenRecete(veri);
  const satirlar = r ? (veri?.receteSatirlari ?? []).filter(s => sayi(s.receteId) === sayi(r.id)) : [];
  if (!r || satirlar.length === 0) return <div className="fm-bos">{c('Reçete yazılmadı')}</div>;
  const imzali = sayi(r.durum) !== 1;
  return (
    <>
      <table className="fm-goster fm-tablo">
        <thead><tr><th>{c('İlaç')}</th><th>{c('Doz')}</th><th className="hiza-orta">{c('Kutu')}</th></tr></thead>
        <tbody>
          {satirlar.map((s, i) => (
            <tr key={i}>
              <td>{metin(s.ilac)}</td>
              <td>{[metin(s.periyot), metin(s.doz)].filter(Boolean).join(' × ') || '—'}</td>
              <td className="hiza-orta">{sayi(s.kutu) || '—'}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="fm-bos">{metin(r.receteNo)} · {imzali ? c('imzalı') : c('taslak · imzasız')}</div>
    </>
  );
}
