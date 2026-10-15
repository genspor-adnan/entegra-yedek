import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import type { KonsultasyonOnizleme } from '../../api/uclar/konsultasyon';
import type { SekmeParcalari } from '../../bilesenler/kartSekmeleri';
import type { Deger } from '../../bilesenler/kartAlanCizim';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import { tarihSaat } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';
import { MuayeneHastaBandi, useMuayeneHastaBilgisi } from '../../bilesenler/MuayeneSekmesiz';
import { KonsAkis, KonsAlinti, KONS_ACILIYET, KONS_KARSILAMA } from './KonsultasyonPanelleri';
import { KonsultasyonIslemPenceresi, type KonsIslem } from './KonsultasyonIslemPenceresi';

/**
 * KONSÜLTASYON KARTI (1107) - mockup Ekranlar/Muayene/konsultasyon_karti.html.
 *
 *   KonsultasyonIstekGovdesi : (1) istek - İsteyen | Karşılayan iki taraf, aciliyet
 *                              (süreyle), soru (500, e-Nabız notu), otomatik özet,
 *                              Taslak / Gönder. Kaydet / yetki / kirli genel kartta.
 *   KonsultasyonYanitSeridi  : (2) yanıt muayenesinin üstünde - akış, soru alıntısı,
 *                              yapısal sonuç, hastada, yönlendir / reddet.
 * Terim "yanıtla"dır (kullanıcı: "üstlenme yerine yanıtlama").
 */

const sayi = (v: unknown) => Number(v ?? 0);

/** Kartın İSTEK gövdesi (genel kartın içinde, alanlar kart değerine yazılır). */
export function KonsultasyonIstekGovdesi({ kartId, deger, parcalar, bantYok }: {
  kartId: number | 'yeni'; deger: Record<string, Deger>; parcalar?: SekmeParcalari;
  /** Muayenenin içinden açılan pencerede hasta bandı çizilmez. */
  bantYok?: boolean;
}) {
  const git = useNavigate();
  const durum = sayi(deger.durum);
  const yeni = kartId === 'yeni';
  const duzenlenir = yeni || durum === 6 || durum === 1;
  const [v, setV] = useState<KonsultasyonOnizleme | null>(null);
  const [islem, setIslem] = useState<KonsIslem | null>(null);
  const [tazele, setTazele] = useState(0);
  useEffect(() => {
    if (yeni) return;
    let iptal = false;
    api.konsultasyonOnizleme(kartId).then(y => { if (!iptal) setV(y) }).catch(() => { if (!iptal) setV(null) });
    return () => { iptal = true };
  }, [kartId, yeni, durum, tazele]);

  const soru = String(deger.soru ?? '');
  const aciliyet = sayi(deger.aciliyet) || 1;
  const gonder = () => {
    if (!soru.trim()) { mesaj(c('Soru / istek notu zorunlu.')); return }
    if (!deger.hedefBolumId) { mesaj(c('Karşılayan bölümü seçin.')); return }
    parcalar?.alanDegistir('durum', 1);
    parcalar?.kaydet();
  };

  // HASTA BANDI (kullanıcı 15.10.2026): isteyen muayenenin bandı - sekmesiz muayenedeki ile aynı.
  //   PENCEREDE YOK (muayene bandı zaten üstte); listeden açılan kartta muayeneden ya da hastanın
  //   son muayenesinden.
  const bant = useMuayeneHastaBilgisi(bantYok ? 0 : Number(deger.isteyenMuayeneId ?? 0), 0, bantYok ? 0 : Number(deger.tarafId ?? 0));
  return (
    <div className="kns-kart">
      {!bantYok && bant && <MuayeneHastaBandi bilgi={bant} />}
      {!yeni && v && (
        <div className="kns-hasta-serit">
          <span><b>{v.k.no}</b></span>
          {/* HASTA VE İSTEYEN HEKİM (kullanıcı 15.10.2026): taslak açılırken muayeneden gelir. */}
          {v.k.hasta && <span>{c('Hasta')} <b>{v.k.hasta}</b>{v.k.hastaKod && <span className="not"> · {v.k.hastaKod}</span>}</span>}
          {v.k.isteyen && <span>{c('İsteyen')} <b>{v.k.isteyen}</b></span>}
          {v.k.basvuruNo && <span>{c('Başvuru')} <b>{v.k.basvuruNo}</b></span>}
          <span>{c('Durum')} <b>{c(DURUM[durum] ?? '')}</b></span>
          {v.alerjiler.length > 0 && <span className="rozet hata" style={{ marginLeft: 'auto' }}>{c('Alerji')}: {v.alerjiler.join(', ')}</span>}
        </div>
      )}
      {/* İSTEK ZAMANI + ACİLİYET TEK SATIR (kullanıcı 15.10.2026: "istek zamanı sağına aciliyet taşı").
          İstek zamanı İsteyen grubundan gizli (gizliKartAlanlari) - burada salt gösterilir. */}
      <div className="kns-satir kns-zaman">
        <span className="etiket">{c('İstek zamanı')}</span>
        <b>{deger.istekZamani ? tarihSaat(deger.istekZamani) : '—'}</b>
        <span className="etiket kns-aciliyet-et">{c('Aciliyet')} *</span>
        <div className="kns-secim">
          {[1, 2, 3].map(a => (
            <button key={a} type="button" disabled={!duzenlenir} className={aciliyet === a ? 'on' : ''}
                    onClick={() => parcalar?.alanDegistir('aciliyet', a)}>{c(KONS_ACILIYET[a])}</button>
          ))}
        </div>
        {deger.sonZaman ? <span className="not">{c('Yanıt süresi sonu')}: {tarihSaat(deger.sonZaman)}</span> : null}
      </div>
      {!yeni && v && durum !== 6 && <KonsAkis v={v} />}

      <div className="kns-iki">
        <div>
          {parcalar?.altGrupCiz('İsteyen', { ek: <span className="not">· {c('kim, neden soruyor')}</span> })}
        </div>
        <div>
          {parcalar?.altGrupCiz('Karşılayan', { ek: <span className="not">· {c('kime, nerede')}</span> })}
        </div>
      </div>

      <div className="kns-soru">
        <span className="etiket">{c('Soru / istek notu')} *</span>
        <textarea rows={4} maxLength={500} value={soru} disabled={!duzenlenir}
                  onChange={e => parcalar?.alanDegistir('soru', e.target.value)} />
        <span className="not">{soru.length} / 500 · {c('e-Nabız konsültasyon notu')}</span>
      </div>

      {v && (
        <div className="kagrup">
          <h6>{c('Konsültana otomatik giden özet')} <span className="not">{c('karşı tarafta görünür · düzenlenmez')}</span></h6>
          <div className="kns-sat"><span>{c('Tanılar')}</span><b>{v.tanilar.join(' · ') || '—'}</b></div>
          <div className="kns-sat"><span>{c('Son lab')}</span><b>{v.lab.join(' · ') || '—'}</b></div>
          <div className="kns-sat"><span>{c('Aktif ilaçlar')}</span><b>{v.ilaclar.join(' · ') || '—'}</b></div>
        </div>
      )}

      {v && (durum === 3 || durum === 4 || durum === 9) && (
        <div className="kagrup">
          <h6>{c('Yanıt')} <span className="not">{v.k.yanitlayan}</span></h6>
          {durum === 9
            ? <div className="kns-sat"><span>{c('Ret gerekçesi')}</span><b className="kns-kir">{v.k.retGerekce}</b></div>
            : <div className="kns-sat"><span>{c('Sonuç')}</span><b>{c(SONUC[v.k.sonuc] ?? '—')}</b></div>}
          <div className="kns-araclar">
            {v.k.yanitMuayeneId && durum !== 9 && (
              <button type="button" className="d" onClick={() => git(`/muayene/${v.k.yanitMuayeneId}`)}>{c('Yanıt muayenesini aç')}</button>
            )}
            {durum === 3 && (
              <button type="button" className="d bir" onClick={() => void guvenli(async () => {
                mesaj((await api.konsultasyonGordum(Number(kartId))).mesaj); setTazele(t => t + 1);
              })}>👁 {c('Gördüm')}</button>
            )}
          </div>
        </div>
      )}

      <div className="uyari-kutusu">
        {c('Bölüme gönderilen istek bölümün Konsültasyon Listesi’ne düşer; bölümün hekimi “Yanıtla” der. Süre aciliyetten sayılır, listede süresi geçen istek kırmızı görünür.')}
      </div>
      <div className="kns-araclar">
        {(durum === 1 || durum === 2) && !yeni && <>
          <button type="button" className="d" onClick={() => setIslem('yonlendir')}>↪ {c('Yönlendir')}</button>
          <button type="button" className="d sil" onClick={() => setIslem('reddet')}>✕ {c('Reddet')}</button>
        </>}
        <span style={{ flex: 1 }} />
        {(yeni || durum === 6) && <>
          <button type="button" className="d" onClick={() => parcalar?.kaydet()}>💾 {c('Taslak')}</button>
          <button type="button" className="d bir" onClick={gonder}>📤 {c('Gönder')}</button>
        </>}
      </div>
      {islem && !yeni && (
        <KonsultasyonIslemPenceresi id={kartId} islem={islem} onKapat={() => setIslem(null)}
          onTamam={() => { setIslem(null); setTazele(t => t + 1) }} />
      )}
    </div>
  );
}

const DURUM: Record<number, string> = {
  6: 'Taslak', 1: 'Yanıt bekliyor', 2: 'Yanıtlanıyor', 3: 'Yanıtlandı', 4: 'İsteyen gördü', 9: 'Reddedildi', 0: 'İptal',
};
const SONUC: Record<number, string> = {
  1: 'Engel yok / önerilerle', 2: 'Ertelenmeli', 3: 'Devralınmalı (nakil)', 4: 'Takip edeceğim',
};

/**
 * YANIT ŞERİDİ (mockup kart 2): muayene bir konsültasyonun yanıt muayenesiyse kartın üstünde.
 * Yanıt muayenenin kendisidir (tanı, istem, reçete, ücret, e-Nabız 252 orada); burada akış,
 * soru, yapısal sonuç ve yönlendir / reddet. Muayene tamamlanınca istek "yanıtlandı" olur.
 */
export function KonsultasyonYanitSeridi({ muayeneId }: { muayeneId: number }) {
  const [id, setId] = useState<number | null>(null);
  const [v, setV] = useState<KonsultasyonOnizleme | null>(null);
  const [tazele, setTazele] = useState(0);
  const [islem, setIslem] = useState<KonsIslem | null>(null);
  useEffect(() => {
    let iptal = false;
    api.konsultasyonYanitMuayenesi(muayeneId).then(y => { if (!iptal) setId(y.id ?? null) }).catch(() => { if (!iptal) setId(null) });
    return () => { iptal = true };
    // Yönlendirme / ret yanıt muayenesini istekten ayırır: şerit yeniden sorar, bağ yoksa kaybolur.
  }, [muayeneId, tazele]);
  useEffect(() => {
    if (!id) { setV(null); return }
    let iptal = false;
    api.konsultasyonOnizleme(id).then(y => { if (!iptal) setV(y) }).catch(() => { if (!iptal) setV(null) });
    return () => { iptal = true };
  }, [id, tazele]);
  if (!id || !v) return null;
  const k = v.k;
  const acik = k.durum === 1 || k.durum === 2;
  // Sonuç / hastada sessiz: şerit kendisi yenilenir, onay penceresi akışı bölmesin.
  const calistir = (f: () => Promise<unknown>) => guvenli(async () => { await f(); setTazele(t => t + 1) });
  return (
    <div className="kns-yanit">
      <div className="kns-yanit-bas">
        🩺 <b>{c('Konsültasyon Yanıtı')}</b>
        <span className="not">{k.no} · {k.isteyen}{k.istekBolum ? ` (${k.istekBolum})` : ''} → {k.hedefBolum}</span>
      </div>
      <KonsAkis v={v} />
      <KonsAlinti baslik={`SORU · ${k.isteyen}${k.istekBolum ? ` (${k.istekBolum})` : ''} · ${tarihSaat(k.istekZamani)} · ${KONS_ACILIYET[k.aciliyet] ?? ''} · ${KONS_KARSILAMA[k.karsilamaYeri] ?? ''}`}
                  metin={k.soru} />
      <div className="kns-ysatir">
        <span className="etiket">{c('Sonuç')}</span>
        <div className="kns-secim">
          {[1, 2, 3, 4].map(s => (
            <button key={s} type="button" disabled={!(k.durum === 2 || k.durum === 3)} className={k.sonuc === s ? 'on' : ''}
                    onClick={() => void calistir(() => api.konsultasyonSonuc(id, s))}>{c(SONUC[s])}</button>
          ))}
        </div>
        <span style={{ flex: 1 }} />
        {k.durum === 2 && !k.hastadaZamani && (
          <button type="button" className="d" onClick={() => void calistir(() => api.konsultasyonHastada(id))}>🚶 {c('Hastadayım')}</button>
        )}
        {acik && <>
          <button type="button" className="d" onClick={() => setIslem('yonlendir')}>↪ {c('Yönlendir')}</button>
          <button type="button" className="d sil" onClick={() => setIslem('reddet')}>✕ {c('Reddet')}</button>
        </>}
      </div>
      {islem && (
        <KonsultasyonIslemPenceresi id={id} islem={islem} onKapat={() => setIslem(null)}
          onTamam={() => { setIslem(null); setTazele(t => t + 1) }} />
      )}
    </div>
  );
}
