import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat, para } from './bicim';

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
  receteler: Satir[];
  receteSatirlari: Satir[];
  konsultasyonlar: Satir[];
  islemler: Satir[];
  gecmis: Satir[];
}

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);

const RECETE_TUR: Record<number, string> = {
  0: 'Normal', 1: 'Normal', 2: 'Kırmızı', 3: 'Yeşil', 4: 'Mor', 5: 'Turuncu',
};
const RECETE_DURUM: Record<number, string> = {
  0: 'İptal', 1: 'Taslak', 2: 'İmzalı', 3: 'Medulaya gönderildi',
};
const KULLANIM: Record<number, string> = {
  0: '', 1: 'Ağızdan', 2: 'Damardan', 3: 'Kas içi', 4: 'Cilt altı',
  5: 'Haricen', 6: 'Solunum', 7: 'Rektal',
};
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

/** e-REÇETE: bu muayenenin reçeteleri ve ilaç satırları (mockup tablosu). */
export function MuayeneReceteSekmesi({ veri, hata }:
  { veri: SekmeVerisi | null; hata: string | null }) {
  const git = useNavigate();
  return (
    <Kabuk hata={hata} veri={veri}>
      <div className="muayene-arac">
        <button type="button" className="d bir" onClick={() => git('/recete')}>
          ＋ Yeni Reçete
        </button>
      </div>
      {veri && veri.receteler.length === 0 && (
        <p className="not ic">
          Bu muayenede reçete yok. Reçete <b>Reçeteler</b> ekranında yazılır;
          imzalanınca e-Nabız reçete paketi kuyruğa girer.
        </p>
      )}
      {veri?.receteler.map(r => {
        const id = sayi(r.id);
        const satirlar = veri.receteSatirlari.filter(s => sayi(s.receteId) === id);
        const durum = sayi(r.durum);
        return (
          <div className="kagrup" key={id}>
            <h6>
              <b>{metin(r.receteNo) || `#${id}`}</b>
              <span className="rozet gri">{RECETE_TUR[sayi(r.tur)] ?? ''}</span>
              <span className={`rozet ${durum >= 2 ? 'olumlu' : durum === 0 ? 'gri' : 'uyari'}`}>
                {RECETE_DURUM[durum] ?? ''}
              </span>
              <span className="not">
                {r.tarih ? tarihSaat(r.tarih) : ''}
                {metin(r.hekim) ? ` · ${metin(r.hekim)}` : ''}
                {` · ${sayi(r.ilac)} ilaç`}
              </span>
            </h6>
            {satirlar.length > 0 && (
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th>İlaç (barkod)</th><th>Doz</th><th>Periyot</th>
                    <th>Kullanım</th><th className="hiza-orta">Süre</th>
                    <th className="hiza-sag">Kutu</th><th>Not</th>
                  </tr>
                </thead>
                <tbody>
                  {satirlar.map((s, i) => (
                    <tr key={i}>
                      <td>{metin(s.ilac)}
                        {metin(s.barkod) && <span className="sonuk"> · {metin(s.barkod)}</span>}
                      </td>
                      <td>{metin(s.doz)}</td>
                      <td>{metin(s.periyot)}</td>
                      <td>{KULLANIM[sayi(s.kullanim)] ?? ''}</td>
                      <td className="hiza-orta">
                        {sayi(s.sureGun) > 0 ? `${sayi(s.sureGun)} gün` : '—'}
                      </td>
                      <td className="hiza-sag">{sayi(s.kutu)}</td>
                      <td>
                        {metin(s.aciklama)}
                        {metin(s.uyari) && (
                          <span className="rozet hata" title="Etkileşim/alerji uyarısı">
                            {metin(s.uyari).slice(0, 40)}
                          </span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        );
      })}
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
          Konsültasyonlar
          <span className="not">{veri?.konsultasyonlar.length ?? 0} istek</span>
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
          <table className="detay-tablo">
            <thead>
              <tr><th>Bölüm</th><th>Hekim</th><th className="hiza-orta">Tarih</th>
                  <th>Ana tanı</th><th className="hiza-orta">Durum</th><th /></tr>
            </thead>
            <tbody>
              {veri?.konsultasyonlar.map(k => (
                <tr key={sayi(k.id)}>
                  <td>{metin(k.bolum) || '—'}</td>
                  <td>{metin(k.hekim) || '—'}</td>
                  <td className="hiza-orta">{k.tarih ? tarihSaat(k.tarih) : '—'}</td>
                  <td>{metin(k.anaTani) || <span className="sonuk">—</span>}</td>
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
              ))}
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

/** GEÇMİŞ: aynı hastanın diğer muayeneleri. */
export function MuayeneGecmisSekmesi({ veri, hata }:
  { veri: SekmeVerisi | null; hata: string | null }) {
  const git = useNavigate();
  return (
    <Kabuk hata={hata} veri={veri}>
      <div className="kagrup">
        <h6>
          Geçmiş muayeneler
          <span className="not">{veri?.gecmis.length ?? 0} kayıt</span>
        </h6>
        {veri && veri.gecmis.length === 0 ? (
          <p className="not ic">Bu hastanın başka muayenesi yok.</p>
        ) : (
          <table className="detay-tablo">
            <thead>
              <tr><th className="hiza-orta" style={{ width: 130 }}>Tarih</th>
                  <th>Bölüm / Hekim</th><th>Şikâyet</th><th>Ana tanı</th>
                  <th className="hiza-orta">Durum</th><th /></tr>
            </thead>
            <tbody>
              {veri?.gecmis.map(g => (
                <tr key={sayi(g.id)}>
                  <td className="hiza-orta">{g.tarih ? tarihSaat(g.tarih) : '—'}</td>
                  <td>{metin(g.bolum) || '—'}
                    {metin(g.hekim) && <span className="sonuk"> · {metin(g.hekim)}</span>}
                  </td>
                  <td>{metin(g.sikayet) || <span className="sonuk">—</span>}</td>
                  <td>{metin(g.anaTani) || <span className="sonuk">—</span>}</td>
                  <td className="hiza-orta">
                    <span className={`rozet ${sayi(g.durum) === 3 ? 'olumlu' : 'uyari'}`}>
                      {MUAYENE_DURUM[sayi(g.durum)] ?? ''}
                    </span>
                  </td>
                  <td>
                    <button type="button" className="d"
                            onClick={() => git(`/muayene/${sayi(g.id)}`)}>Aç</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </Kabuk>
  );
}
