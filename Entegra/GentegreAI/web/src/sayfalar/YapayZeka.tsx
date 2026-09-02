import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { useOturum } from '../kimlik/OturumBaglami';
import { guvenli } from '../bilesenler/mesaj';

/**
 * YAPAY ZEKA (341/343) — İletişim & AI › Yapay Zeka.
 *
 * Mockup: `Ekranlar/ai_asistan.html`. Üç panel: SOL sohbet geçmişi + hazır
 * komutlar · ORTA akış (soru, araç çağrısı, veri tablosu, taslak + onay) ·
 * SAĞ bağlam / izinli fonksiyonlar / sayaçlar / AI log.
 *
 * MOCKUP'IN KURALI EKRANDA DA YAZILI: model veritabanına doğrudan bağlanmaz,
 * yazan işlem yapılmaz - taslak üretilir, onayı kullanıcı verir.
 */
type Mesaj = {
  id: number; rol: number; metin: string; veri: unknown; token: number;
  tarih: string; geriBildirim: number;
};
type Taslak = {
  id: number; tip: number; baslik: string; icerik: string; durum: number;
  hedefModul: string; hedefId: number | null; onayTarihi: string | null; mesajId: number | null;
};
type Arac = {
  kod: string; ad: string; aciklama: string; yetkiKodu: string; yazar: number;
  kaynakTablo?: string; listeRota?: string; listeAdi?: string;
};

/** Mockup'taki "Hazır komutlar" - araç kataloğundaki koda bağlanır. */
const KOMUT_IKON: Record<string, string> = {
  cari_vadesi_gecen: '👥', stok_kritik: '📦', bugun_ozet: '📊', gorev_taslagi: '✅',
};

const saat = (iso: string) => new Date(iso).toTimeString().slice(0, 5);
const gun = (iso: string) => new Date(iso).toLocaleDateString('tr-TR');

/** Araç sonucu: satır dizisi (jsonb) - kolonlar ilk satırdan çıkarılır. */
function tabloVerisi(veri: unknown): Record<string, unknown>[] | null {
  if (veri === null || veri === undefined) return null;
  const d = typeof veri === 'string' ? JSON.parse(veri) as unknown : veri;
  return Array.isArray(d) && d.length > 0 ? d as Record<string, unknown>[] : null;
}

/** Mockup "Excel'e aktar": gorunen tabloyu CSV olarak indirir (Excel acar). */
function csvIndir(satirlar: Record<string, unknown>[], ad: string) {
  const kolonlar = Object.keys(satirlar[0]);
  const kacir = (d: unknown) => {
    const m = String(d ?? '');
    return /[";\n]/.test(m) ? `"${m.replace(/"/g, '""')}"` : m;
  };
  const metin = [kolonlar.map(k => BASLIK[k] ?? k).join(';'),
                 ...satirlar.map(r => kolonlar.map(k => kacir(r[k])).join(';'))].join('\r\n');
  // BOM: Excel Turkce karakterleri BOM'suz dosyada bozuk gosteriyor.
  const bag = URL.createObjectURL(new Blob(['\uFEFF' + metin], { type: 'text/csv;charset=utf-8' }));
  const a = document.createElement('a');
  a.href = bag; a.download = `${ad}.csv`; a.click();
  URL.revokeObjectURL(bag);
}

const BASLIK: Record<string, string> = {
  cariId: 'Cari no', cari: 'Cari', bakiye: 'Bakiye', geciken_gun: 'Geciken gün',
  stokId: 'Stok no', kod: 'Kod', ad: 'Ad', mevcut: 'Mevcut', minStok: 'Min. stok',
  baslik: 'Başlık', deger: 'Değer',
};

export function YapayZeka() {
  const { kullanici } = useOturum();

  const [sohbetler, setSohbetler] = useState<Record<string, unknown>[]>([]);
  const [araclar, setAraclar] = useState<Arac[]>([]);
  const [bekleyen, setBekleyen] = useState(0);
  const [secili, setSecili] = useState<number | null>(null);
  const [mesajlar, setMesajlar] = useState<Mesaj[]>([]);
  const [taslaklar, setTaslaklar] = useState<Taslak[]>([]);
  const [gunluk, setGunluk] = useState<Record<string, unknown>[]>([]);
  const [soru, setSoru] = useState('');
  const [calisiyor, setCalisiyor] = useState(false);
  /** Mockup ust cubugundaki bolumler sag panelde kutu - tiklaninca oraya kaydirir. */
  const [fonksiyonMenu, setFonksiyonMenu] = useState(false);
  /** Ekran baglami soruya eklensin mi (mockup: "Ekran baglamini ekle"). */
  const [baglamEkli, setBaglamEkli] = useState(true);
  const akisRef = useRef<HTMLDivElement | null>(null);
  const fonkRef = useRef<HTMLDivElement | null>(null);
  const kullanimRef = useRef<HTMLDivElement | null>(null);
  const guvenlikRef = useRef<HTMLDivElement | null>(null);
  const logRef = useRef<HTMLDivElement | null>(null);
  const kaydir = (r: React.RefObject<HTMLDivElement | null>) =>
    r.current?.scrollIntoView({ block: 'nearest' });

  const listeYukle = useCallback(async () => {
    const y = await api.aiSohbetler();
    setSohbetler(y.sohbetler ?? []);
    setAraclar(y.araclar ?? []);
    setBekleyen(Number(y.bekleyenTaslak ?? 0));
  }, []);

  const sohbetYukle = useCallback(async (id: number) => {
    const y = await api.aiSohbet(id);
    setMesajlar((y.mesajlar ?? []) as unknown as Mesaj[]);
    setTaslaklar((y.taslaklar ?? []) as unknown as Taslak[]);
    setGunluk(y.gunluk ?? []);
  }, []);

  useEffect(() => { void guvenli(listeYukle) }, [listeYukle]);
  useEffect(() => {
    if (secili === null) { setMesajlar([]); setTaslaklar([]); setGunluk([]); return }
    void guvenli(() => sohbetYukle(secili));
  }, [secili, sohbetYukle]);

  useEffect(() => {
    const el = akisRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [mesajlar.length]);

  /** Sohbet yoksa açar - kullanıcı "önce sohbet aç" adımıyla uğraşmasın. */
  async function sohbetGerek(): Promise<number> {
    if (secili !== null) return secili;
    const y = await api.aiSohbetAc();
    await listeYukle();
    setSecili(y.id);
    return y.id;
  }

  async function sor(arac?: string, parametre?: Record<string, unknown>) {
    const metin = arac ? (araclar.find(a => a.kod === arac)?.ad ?? arac) : soru.trim();
    if (!metin) return;
    setCalisiyor(true);
    await guvenli(async () => {
      const id = await sohbetGerek();
      await api.aiSor(id, metin, arac, parametre, baglamEkli ? {
        ekran: 'Yapay Zeka',
        kullanici: kullanici?.ad ?? '',
        sube: kullanici?.subeler?.find(x => x.id === kullanici?.subeId)?.ad ?? '',
      } : undefined);
      setSoru('');
      await sohbetYukle(id);
      await listeYukle();
    });
    setCalisiyor(false);
  }

  const sayac = useMemo(() => ({
    fonksiyon: gunluk.length,
    kayit: gunluk.reduce((t, l) => t + Number(l.kayitSayisi ?? 0), 0),
    taslak: taslaklar.length,
    onayli: taslaklar.filter(t => t.durum === 2).length,
    token: mesajlar.reduce((t, m) => t + Number(m.token ?? 0), 0),
  }), [gunluk, taslaklar, mesajlar]);

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Yapay Zeka</h1>
          <span className="yol">İletişim &amp; AI › Yapay Zeka</span>
        </div>
      </div>

      <div className="msj-arac">
        <button className="d bir" onClick={() => void guvenli(async () => {
          const y = await api.aiSohbetAc(); await listeYukle(); setSecili(y.id);
        })}>✨ Yeni Sohbet</button>
        {/* Mockup ust cubugu: bolumler AYRI PENCERE degil, sag panelde kutu -
            ayni bilgiyi iki yerde tutmamak icin dugme oraya kaydiriyor. */}
        <button className="d" onClick={() => kaydir(fonkRef)}>🧩 İzinli Fonksiyonlar</button>
        <button className="d" onClick={() => kaydir(kullanimRef)}>📊 Kullanım / Maliyet</button>
        <button className="d" onClick={() => kaydir(guvenlikRef)}>🛡 Güvenlik Kuralları</button>
        <button className="d" onClick={() => kaydir(logRef)}>📜 AI Log</button>
        <span className="msj-durum">
          Model: <b>tanımlı değil</b> · Yetki: <b>{kullanici?.ad ?? ''}</b>
          {bekleyen > 0 && <> · Onay bekleyen taslak: <b>{bekleyen}</b></>}
        </span>
      </div>

      <div className="msj-govde">
        {/* ------------------------------------------- SOL: geçmiş + komutlar */}
        <div className="msj-sol">
          <div className="kagrup" style={{ margin: 8 }}>
            <h6>Son sohbetler</h6>
            {sohbetler.length === 0 && <div className="not">Sohbet yok.</div>}
            {sohbetler.map(s => (
              <div key={Number(s.id)}
                   className={`msj-satir${Number(s.id) === secili ? ' on' : ''}`}
                   onClick={() => setSecili(Number(s.id))}>
                <div className="msj-satir-ic">
                  <div className="ad">{String(s.baslik ?? '')}</div>
                  <div className="sonuk">
                    {gun(String(s.sonTarih))} · {Number(s.mesajSayisi ?? 0)} mesaj
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className="kagrup" style={{ margin: 8 }}>
            <h6>Hazır komutlar</h6>
            {araclar.map(a => (
              <button key={a.kod} className="ai-komut" title={a.aciklama}
                      disabled={calisiyor}
                      onClick={() => void sor(a.kod, a.kod === 'gorev_taslagi'
                        ? { konu: soru.trim() || 'Yeni görev', aciklama: soru.trim() }
                        : undefined)}>
                {KOMUT_IKON[a.kod] ?? '🧩'} {a.ad}
                {a.yazar === 1 && <span className="rozet uyari">taslak</span>}
              </button>
            ))}
            {araclar.length === 0 && (
              <div className="not">Yetkili olduğunuz fonksiyon yok.</div>
            )}
          </div>
        </div>

        {/* ------------------------------------------------------ ORTA: akış */}
        <div className="msj-orta">
          <div className="msj-akis" ref={akisRef}>
            {mesajlar.length === 0 && (
              <div className="not" style={{ padding: 16 }}>
                Sorunu yaz ya da soldaki hazır komutlardan birini çalıştır.
                Asistan veriyi yalnız <b>izinli fonksiyonlar</b> üzerinden okur.
              </div>
            )}

            {mesajlar.map(m => {
              const tablo = tabloVerisi(m.veri);
              const mTaslak = taslaklar.filter(t => t.mesajId === m.id);
              const log = gunluk.find(l => Number(l.mesajId ?? 0) === m.id);
              return (
                <div key={m.id} className={`ai-blok${m.rol === 1 ? ' benim' : ''}`}>
                  <div className="ai-bas">
                    <b>{m.rol === 1 ? (kullanici?.ad ?? 'Ben') : '✨ Gentegre Yapay Zeka'}</b>
                    <span className="sonuk">· {saat(m.tarih)}</span>
                    {log && (
                      <span className="ai-cip" title="İzinli fonksiyon çağrısı">
                        🧩 {String(log.aracKod)} · {Number(log.sureMs)} ms ·{' '}
                        {Number(log.kayitSayisi)} kayıt
                      </span>
                    )}
                  </div>

                  <div className="ai-metin">{m.metin}</div>

                  {tablo && (
                    <div className="ai-tablo">
                      <table>
                        <thead>
                          <tr>{Object.keys(tablo[0]).map(k => (
                            <th key={k}>{BASLIK[k] ?? k}</th>
                          ))}</tr>
                        </thead>
                        <tbody>
                          {tablo.slice(0, 20).map((r, i) => (
                            <tr key={i}>
                              {Object.keys(tablo[0]).map(k => (
                                <td key={k}>{String(r[k] ?? '')}</td>
                              ))}
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  )}

                  {/* TASLAK KARTI: kayıt henüz oluşmadı - onayı kullanıcı verir. */}
                  {mTaslak.map(t => (
                    <div key={t.id} className={`ai-taslak${t.durum === 2 ? ' onayli' : ''}`}>
                      <div className="bas">
                        <b>{t.tip === 1 ? '📝 Görev taslağı' : '✉️ Metin taslağı'} — {t.baslik}</b>
                        <span className={`rozet ${t.durum === 2 ? 'ok' : t.durum === 3 ? 'gri' : 'uyari'}`}>
                          {t.durum === 2 ? 'Onaylandı' : t.durum === 3 ? 'İptal' : 'Onay gerekli'}
                        </span>
                      </div>
                      <div className="icerik">{t.icerik}</div>
                      {t.durum === 1 && (
                        <div className="tuslar">
                          <button className="d bir" onClick={() => void guvenli(async () => {
                            await api.aiTaslak(t.id, false);
                            if (secili !== null) await sohbetYukle(secili);
                            await listeYukle();
                          })}>✔ Onayla ve Kaydı Oluştur</button>
                          <button className="d" onClick={() => void guvenli(async () => {
                            await api.aiTaslak(t.id, true);
                            if (secili !== null) await sohbetYukle(secili);
                            await listeYukle();
                          })}>✖ İptal</button>
                        </div>
                      )}
                      {t.durum === 2 && t.hedefId && (
                        <div className="sonuk">
                          {t.hedefModul} kaydı oluşturuldu (#{t.hedefId})
                          {t.onayTarihi && <> · {saat(String(t.onayTarihi))}</>}
                        </div>
                      )}
                    </div>
                  ))}

                  {/* KAYNAK ROZETLERI (344): hangi tablodan kac kayit okundu
                      ve ayni veri hangi ekranda dogrulanabilir. */}
                  {log && (
                    <div className="ai-kaynak">
                      {String(log.kaynakTablo ?? '') !== '' && (
                        <span className="rz">📄 {String(log.kaynakTablo)} · {Number(log.kayitSayisi)} kayıt</span>
                      )}
                      {String(log.listeRota ?? '') !== '' && (
                        <a className="rz bag" href={String(log.listeRota)}>
                          🔗 {String(log.listeAdi || 'Listede')} aç
                        </a>
                      )}
                      {tablo && (
                        <span className="rz bag"
                              onClick={() => csvIndir(tablo, String(log.aracKod))}>
                          📊 Excel'e aktar
                        </span>
                      )}
                      <span className="rz bag" title="Aynı fonksiyonu yeniden çalıştır"
                            onClick={() => void sor(String(log.aracKod))}>↻ Yeniden üret</span>
                    </div>
                  )}

                  {m.rol === 2 && (
                    <div className="ai-alt">
                      <span className={m.geriBildirim === 1 ? 'on' : ''} title="Yararlı"
                            onClick={() => void guvenli(async () => {
                              await api.aiGeriBildirim(m.id, m.geriBildirim === 1 ? 0 : 1);
                              if (secili !== null) await sohbetYukle(secili);
                            })}>👍</span>
                      <span className={m.geriBildirim === 2 ? 'on' : ''} title="Yararsız"
                            onClick={() => void guvenli(async () => {
                              await api.aiGeriBildirim(m.id, m.geriBildirim === 2 ? 0 : 2);
                              if (secili !== null) await sohbetYukle(secili);
                            })}>👎</span>
                      <span title="Kopyala"
                            onClick={() => void navigator.clipboard?.writeText(m.metin)}>⧉ Kopyala</span>
                      {m.token > 0 && <span className="sonuk">{m.token} token</span>}
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {calisiyor && (
            <div className="ai-yaziyor">
              <span className="nk"><i /><i /><i /></span> Asistan çalışıyor…
            </div>
          )}

          <div className="msj-yazma">
            {/* Mockup yazma serici: fonksiyon sec · ekran baglami · (pasifler) */}
            <div className="msj-atac">
              <span title="Fonksiyon seç" onClick={() => setFonksiyonMenu(a => !a)}>🧩</span>
              {fonksiyonMenu && (
                <div className="msj-atac-menu" onMouseLeave={() => setFonksiyonMenu(false)}>
                  {araclar.map(a => (
                    <div key={a.kod} onClick={() => {
                      setFonksiyonMenu(false);
                      void sor(a.kod, a.kod === 'gorev_taslagi'
                        ? { konu: soru.trim() || 'Yeni görev', aciklama: soru.trim() }
                        : undefined);
                    }}>{KOMUT_IKON[a.kod] ?? '🧩'} {a.ad}</div>
                  ))}
                  {araclar.length === 0 && <div className="pasif">Yetkili fonksiyon yok</div>}
                </div>
              )}
            </div>
            <span className={`ai-baglam${baglamEkli ? ' on' : ''}`}
                  title="Ekran bağlamını (ekran · kullanıcı · şube) soruya ekle"
                  onClick={() => setBaglamEkli(b => !b)}>📎 Bağlam</span>
            <input placeholder="Sor: “bu ay tahsilatı geciken cariler kim?”" value={soru}
                   disabled={calisiyor}
                   onChange={e => setSoru(e.target.value)}
                   onKeyDown={e => { if (e.key === 'Enter') void sor() }} />
            <button className="d bir" disabled={calisiyor} onClick={() => void sor()}>
              {calisiyor ? '…' : '➤ Sor'}
            </button>
          </div>
          <div className="not ai-kural">
            Yazan işlem yapılmaz — asistan yalnız <b>taslak</b> üretir, onayı sen
            verirsin. Veri doğrudan okunmaz: her çağrı <b>izinli fonksiyon</b>
            üzerinden ve senin yetkinle çalışır, çağrının izi <b>AI log</b>'a düşer.
          </div>
        </div>

        {/* -------------------------------------------------- SAĞ: bağlam/log */}
        <div className="msj-sag">
          <div className="kagrup">
            <h6>Bağlam</h6>
            <div className="msj-kv"><span>Açık ekran</span><b>Yapay Zeka</b></div>
            <div className="msj-kv"><span>Kullanıcı</span><b>{kullanici?.ad ?? ''}</b></div>
            <div className="msj-kv"><span>Şube</span><b>{kullanici?.subeler?.find(x => x.id === kullanici?.subeId)?.ad ?? ''}</b></div>
            <div className="msj-kv"><span>Model</span><b>tanımlı değil</b></div>
          </div>

          <div className="kagrup" ref={fonkRef}>
            <h6>İzinli fonksiyonlar</h6>
            {araclar.map(a => (
              <div key={a.kod} className="msj-kv">
                <span>{a.ad}</span>
                <b>{a.yazar === 1 ? 'taslak üretir' : 'okuma'}</b>
              </div>
            ))}
            <div className="not">
              Kayıt güncelleme / silme <b>kapalı</b> — hiçbir rolde açılmıyor.
            </div>
          </div>

          <div className="kagrup" ref={guvenlikRef}>
            <h6>Güvenlik kuralları</h6>
            <div className="msj-kv"><span>Okuma</span><b>izinli fonksiyon + yetki</b></div>
            <div className="msj-kv"><span>Kayıt oluşturma</span><b>yalnız onaylı taslak</b></div>
            <div className="msj-kv"><span>Kayıt güncelleme / silme</span><b>kapalı</b></div>
            <div className="msj-kv"><span>Denetim</span><b>her çağrı AI log'a</b></div>
          </div>

          <div className="kagrup" ref={kullanimRef}>
            <h6>Kullanım / maliyet</h6>
            <div className="msj-kv"><span>Bu sohbet</span><b>{sayac.token} token</b></div>
            <div className="msj-kv"><span>Model</span><b>tanımlı değil</b></div>
            <div className="not">
              Model bağlanınca token ve tahmini maliyet buradan izlenecek;
              çağrı sayısı ve okunan kayıt şimdiden sayılıyor.
            </div>
          </div>

          <div className="kagrup">
            <h6>Bu sohbette</h6>
            <div className="msj-kv"><span>Fonksiyon çağrısı</span><b>{sayac.fonksiyon}</b></div>
            <div className="msj-kv"><span>Okunan kayıt</span><b>{sayac.kayit}</b></div>
            <div className="msj-kv"><span>Üretilen taslak</span><b>{sayac.taslak}</b></div>
            <div className="msj-kv"><span>Onaylanan</span><b>{sayac.onayli}</b></div>
            <div className="msj-kv"><span>Token</span><b>{sayac.token}</b></div>
          </div>

          <div className="kagrup" ref={logRef}>
            <h6>AI log (son)</h6>
            {gunluk.length === 0 && <div className="not">Henüz çağrı yok.</div>}
            {gunluk.map(l => (
              <div key={Number(l.id)} className="msj-kv">
                <span>{saat(String(l.tarih))}</span>
                <b>{String(l.aracKod)} · {Number(l.kayitSayisi)} kayıt</b>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}
