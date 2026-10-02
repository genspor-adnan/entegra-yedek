import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { KaynakArama } from './KaynakArama';
import { GenGrid } from './GenGrid';
import { ReceteKarti } from './recete/ReceteKarti';
import type { ListeSatiri } from '../api/sozlesme';
import type { SablonTercihleri } from '../api/uclar/liste';
import { guvenli, mesaj, onay } from './mesaj';
import { tarihSaat, para } from './bicim';
import { c } from '../dil/ceviri';

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
const MUAYENE_DURUM: Record<number, string> = {
  0: 'İptal', 1: 'Açık', 2: 'Sonuç bekliyor', 3: 'Tamamlandı',
};

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
 * e-REÇETE (mockup muayene_karti.html "e-Reçete" paneli).
 *
 * Araç çubuğu · reçete başlığı (tür · provizyon · tanı · açıklama) · ilaç
 * tablosu. <b>Yazma yolu SUNUCU uçlarıdır</b>: ilaç ekleme reçeteyi yoksa
 * açar, uyarıyı ekleme ANINDA döndürür (hekim ilacı seçerken görsün, on ilaç
 * yazıp imzaya basınca değil) ve imza reçeteyi kilitler. İstemci sırayı
 * kurmaz, kuralı tekrarlamaz.
 */
export function MuayeneReceteSekmesi({ veri, hata, muayeneId, tazele }: {
  veri: SekmeVerisi | null; hata: string | null;
  muayeneId: number;
  tazele(): void;
}) {
  const [aramaAcik, setAramaAcik] = useState(false);
  /** Gridde ONAY KUTUSU işaretli ilaç satırları (kırmızı Sil bunlara uygulanır). */
  const [isaretli, setIsaretli] = useState<ListeSatiri[]>([]);
  /** Gridde tıklanan (odaktaki) satır - Düzenle işaret yoksa bunu açar. */
  const [secili, setSecili] = useState<ListeSatiri | null>(null);
  /** Açık reçete kartı (Düzenle): ilaçlar detayında doz/periyot/süre/kutu/tarif. */
  const [kartReceteId, setKartReceteId] = useState<number | null>(null);
  /** Grid yeniden okunsun (ekle/sil sonrası). */
  const [gridTazele, setGridTazele] = useState(0);
  const yenile = () => { setGridTazele(t => t + 1); setIsaretli([]); tazele() };
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
    yenile();
    mesaj(`${r.grup}: ${r.satirlar.length} ilaç yazıldı.`
      + (uyarilar.length ? `\n\nUYARI:\n· ${uyarilar.join('\n· ')}` : ''));
  });

  /** Seçilen ilacı ekler; sunucudan dönen uyarıyı hekime gösterir. */
  const ilacEkle = (barkod: string, ad: string) => guvenli(async () => {
    const y = await api.receteIlacEkle(muayeneId, { barkod });
    const uyari = (y.uyarilar ?? []) as { metin?: string }[];
    if (uyari.length)
      mesaj(`${ad} eklendi.\n\nUYARI:\n· ${uyari.map(u => u.metin ?? '').join('\n· ')}`);
    yenile();
  });

  /** İşaretli ilaçları çıkarır. İMZALI REÇETEDEN İLAÇ ÇIKMAZ - kural uçta;
      imzalı satır işaretliyse sunucunun mesajı gösterilir. */
  const sil = () => guvenli(async () => {
    if (isaretli.length === 0) return;
    if (!await onay(`${isaretli.length} ilaç reçeteden çıkarılacak. Onaylıyor musunuz?`)) return;
    for (const s of isaretli)
      await api.receteIlacSil(sayi(s.receteId), sayi(s.id));
    yenile();
  });

  // SABIT FILTRE NESNESI SABIT KALMALI: her cizimde yeni nesne GenGrid'i
  //   yeniden yukletir (yanip sonme).
  const filtre = useMemo(() => ({ alan: 'muayeneId', op: 'esit' as const, deger: muayeneId }),
                         [muayeneId]);
  // DUZENLE hedefi: isaretli ilk satir, yoksa gridde secili satir.
  const duzenlenecek = isaretli[0] ?? secili;
  const acikRecete = veri?.receteler.find(r => sayi(r.durum) === 1);
  const uyariVar = (veri?.receteSatirlari ?? []).some(s => metin(s.uyari) !== '');

  return (
    <Kabuk hata={hata} veri={veri}>
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

      {/* RECETE ILAC GRIDI (kullanici: "GenGrid yap.. basa check.. uste
          + Ilac butonu, sagina kirmizi sil"). Ilaclar muayenenin TUM
          receteleriyle tek gridde; "Reçete" kolonu taslak/imzali ayrimini
          gosterir. */}
      <div className="kagrup recete-grid">
        <div className="numaralama-bas bitisik">
          <span className="baslik-eylem">
            {/* Kopyala + Ilac'in SOLUNDA (kullanici). */}
            <button type="button" className="d"
                    onClick={() => void guvenli(async () => {
                      const y = await api.receteOncekiKopyala(muayeneId);
                      mesaj(y.mesaj);
                      yenile();
                    })}>
              🕘 {c('Önceki reçeteyi kopyala')}
            </button>
            {/* REÇETE ŞABLONU (931): bölüm / doktor şablon kartında tanımlı. */}
            {sablonReceteleri.length > 0 && (
              <select className="recete-sablon" value="" aria-label={c('Reçete şablonundan yaz')}
                      title={c('Bölüm / doktor şablonundaki hazır reçeteyi yazar')}
                      onChange={e => { if (e.target.value !== '') void sablondanYaz(Number(e.target.value)) }}>
                <option value="">📋 {c('Şablondan…')}</option>
                {sablonReceteleri.map((r, i) => (
                  <option key={`${r.sablon}-${r.grup}`} value={i}>{r.grup} ({r.satirlar.length}) · {r.sablon}</option>
                ))}
              </select>
            )}
            <button type="button" className="d bir" onClick={() => setAramaAcik(true)}>
              ＋ {c('İlaç')}
            </button>
            {/* DUZENLE (kullanici: "+ Ilac saginda"): recete KARTINI acar -
                ilaclar detayinda doz/periyot/sure/kutu/tarif. Imzali recete
                degismez (kural sunucuda). */}
            {/* Duzenle ve Sil YALNIZ IKON (kullanici); ne yaptigi title'da. */}
            <button type="button" className="d ikon-dugme" disabled={!duzenlenecek}
                    aria-label={c('Düzenle')}
                    title={duzenlenecek ? c('Reçeteyi düzenle') : c('Önce satır seçin')}
                    onClick={() => duzenlenecek && setKartReceteId(sayi(duzenlenecek.receteId))}>
              ✎
            </button>
            <button type="button" className="d teh ikon-dugme" disabled={isaretli.length === 0}
                    aria-label={c('Sil')}
                    title={isaretli.length ? `${c('İşaretli ilaçları çıkar')} (${isaretli.length})`
                                           : c('Önce satır işaretleyin')}
                    onClick={() => void sil()}>
              🗑
            </button>
            {acikRecete && (
              <button type="button" className="d bir"
                      onClick={() => void guvenli(async () => {
                        if (!await onay('Reçete imzalanacak. İmzalanan reçete '
                                      + 'değiştirilemez, ilaçlar hastanın aktif ilaç '
                                      + 'listesine işlenir. Onaylıyor musunuz?')) return;
                        const y = await api.receteImzala(sayi(acikRecete.id));
                        mesaj(y.mesaj);
                        yenile();
                      })}>
                ✍ {c('e-İmzala')}
              </button>
            )}
          </span>
          {/* Recete etiketi ve rozetler DUGMELERIN SAGINDA (kullanici). */}
          <h6>
            {c('Reçete')}
            {acikRecete && <span className="rozet uyari">{metin(acikRecete.receteNo) || c('Taslak')}</span>}
            {veri && veri.receteSatirlari.length > 0 && (
              <span className={`rozet ${uyariVar ? 'hata' : 'olumlu'}`}>
                {uyariVar ? '⚠ Etkileşim / alerji uyarısı var' : 'Etkileşim / alerji: temiz'}
              </span>
            )}
          </h6>
        </div>
        <GenGrid
          key={`recete-satir-${muayeneId}-${gridTazele}`}
          kaynak="recete-satir"
          gomulu
          seritGizli
          aramaGizli
          boyut={50}
          sabitFiltre={filtre}
          onIsaretliDegisti={setIsaretli}
          onSecimDegisti={setSecili}
          onSatirAc={satir => setKartReceteId(sayi(satir.receteId))}
        />
      </div>

      {/* RECETE KARTI (mockup recete_karti.html): tür, tanılar, ilaç satırı
          düzeltme, imza ve Medula tek pencerede. */}
      {kartReceteId !== null && kartReceteId > 0 && (
        <ReceteKarti receteId={kartReceteId}
          onKapat={() => { setKartReceteId(null); yenile() }}
          onDegisti={() => setGridTazele(t => t + 1)} />
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
 * GEÇMİŞ (mockup `muayene_karti.html`): solda **Önceki muayeneler (kurum)**
 * - Tarih · Hekim · Tanı · Özet · aç / kopyala; sağda **e-Nabız / dış kurum**
 * kutusu.
 *
 * <b>"↺ Kopyala" sunucuda:</b> kronik hastanın anamnezi ve tanıları önceki
 * muayeneden taşınır; boş alan doldurulur, hekimin yazdığı EZİLMEZ. Fizik
 * muayene ve vital kopyalanmaz - onlar o günün ölçümüdür.
 */
export function MuayeneGecmisSekmesi({ veri, hata, muayeneId, tazele }:
  { veri: SekmeVerisi | null; hata: string | null;
    muayeneId: number; tazele(): void }) {
  const git = useNavigate();

  const kopyala = (kaynakId: number) => guvenli(async () => {
    if (!await onay('Önceki muayenenin anamnezi ve tanıları bu muayeneye '
                  + 'kopyalanacak. Boş alanlar doldurulur, yazdıklarınız '
                  + 'değişmez. Onaylıyor musunuz?')) return;
    const y = await api.muayeneOncekiKopyala(muayeneId, kaynakId);
    mesaj(y.mesaj);
    tazele();
  });

  return (
    <Kabuk hata={hata} veri={veri}>
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
                                onClick={() => void kopyala(sayi(g.id))}>↺</button>
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
