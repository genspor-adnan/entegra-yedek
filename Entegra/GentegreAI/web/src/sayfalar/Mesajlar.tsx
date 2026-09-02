import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { useOturum } from '../kimlik/OturumBaglami';
import { guvenli, mesaj as bilgiMesaji } from '../bilesenler/mesaj';
import { Modal } from '../bilesenler/Modal';

/**
 * MESAJLAR (341/342) — İletişim & AI › Mesajlar.
 *
 * Mockup: `Ekranlar/umesajlar.html`. Üç panel: SOL sohbet listesi (arama +
 * çipler), ORTA mesaj akışı (balonlar, yanıtlama, yazma satırı), SAĞ sohbet
 * bilgisi (künye, üyeler, ekler, iliştirilen kayıtlar, sabitlenenler).
 *
 * GERÇEK ZAMANLI İLETİM YOK: ekran açıkken liste ve akış kısa aralıkla
 * tazelenir (`TAZELE_MS`). Kurum içi trafik düşük; soket altyapısı sonradan
 * eklenebilir - uçlar değişmeden.
 */
const TAZELE_MS = 8000;

type Sohbet = {
  id: number; tip: number; baslik: string; karsiId: number | null;
  sonTarih: string | null; sonMetin: string; sonGonderenId: number | null;
  okunmamis: number; uyeSayisi: number;
  favori: number; sabit: number; sessiz: number; arsiv: number; rol: number;
};

type Mesaj = {
  id: number; gonderenId: number; gonderen: string; tip: number; metin: string;
  tarih: string; durum: number; sabit: number;
  yanitId: number | null; yanitMetin: string | null; yanitGonderen: string | null;
  okumayan: number;
};

const CIPLER = [
  { kod: 'tumu',      ad: 'Tümü' },
  { kod: 'okunmamis', ad: 'Okunmamış' },
  { kod: 'grup',      ad: 'Gruplar' },
  { kod: 'favori',    ad: '★ Favoriler' },
  { kod: 'arsiv',     ad: '🗄 Arşiv' },
];

/** "09:52" / "dün" / "13.08" - mockup'taki liste damgası. */
function kisaZaman(iso: string | null): string {
  if (!iso) return '';
  const t = new Date(iso);
  const bugun = new Date();
  const ayniGun = t.toDateString() === bugun.toDateString();
  if (ayniGun) return t.toTimeString().slice(0, 5);
  const dun = new Date(bugun); dun.setDate(bugun.getDate() - 1);
  if (t.toDateString() === dun.toDateString()) return 'dün';
  return `${String(t.getDate()).padStart(2, '0')}.${String(t.getMonth() + 1).padStart(2, '0')}`;
}

const saat = (iso: string) => new Date(iso).toTimeString().slice(0, 5);

/** Akistaki gun ayraci: "Bugün" / "Dün" / "13.08.2026". */
function gunEtiketi(iso: string): string {
  const t = new Date(iso);
  const bugun = new Date();
  if (t.toDateString() === bugun.toDateString()) return 'Bugün';
  const dun = new Date(bugun); dun.setDate(bugun.getDate() - 1);
  if (t.toDateString() === dun.toDateString()) return 'Dün';
  return t.toLocaleDateString('tr-TR');
}

/** Adın baş harfleri (mockup'taki yuvarlak avatar). */
function basHarf(ad: string): string {
  const p = ad.trim().split(/\s+/).filter(Boolean);
  if (p.length === 0) return '?';
  return (p[0][0] + (p.length > 1 ? p[p.length - 1][0] : '')).toLocaleUpperCase('tr');
}

/** Avatar rengi addan türetilir - aynı kişi her yerde aynı renk. */
const RENKLER = ['#2f6db3', '#7a4fb0', '#2e7d46', '#b5731a', '#a3312f', '#0f6f7a'];
const renk = (ad: string) =>
  RENKLER[[...ad].reduce((t, c) => t + c.charCodeAt(0), 0) % RENKLER.length];

export function Mesajlar() {
  const { kullanici } = useOturum();
  const benId = kullanici?.id ?? 0;

  const [filtre, setFiltre] = useState('tumu');
  const [ara, setAra] = useState('');
  const [sohbetler, setSohbetler] = useState<Sohbet[]>([]);
  const [ozet, setOzet] = useState({ okunmamisMesaj: 0, okunmamisSohbet: 0,
                                    bugunMesaj: 0, bugunEk: 0, bugunKayit: 0 });
  const [secili, setSecili] = useState<number | null>(null);
  const [mesajlar, setMesajlar] = useState<Mesaj[]>([]);
  const [metin, setMetin] = useState('');
  const [yanit, setYanit] = useState<Mesaj | null>(null);
  const [bilgi, setBilgi] = useState<{
    kunye: Record<string, unknown> | null;
    uyeler: Record<string, unknown>[]; ekler: Record<string, unknown>[];
    kayitlar: Record<string, unknown>[]; sabitler: Record<string, unknown>[];
  } | null>(null);
  /** Yazma satirindaki ek menusu (mockup: bes madde). */
  const [atacAcik, setAtacAcik] = useState(false);
  /** Ilistirilecek kayit penceresi (mockup "Gentegre Kaydi Ilistir"). */
  const [kayitAcik, setKayitAcik] = useState(false);
  /** Sohbet ICINDE arama (mockup ust seritteki buyutec): akisi suzer. */
  const [akisAra, setAkisAra] = useState<string | null>(null);
  /** Sag panel gorunur mu (mockup "i" ikonu). */
  const [sagAcik, setSagAcik] = useState(true);
  /** Kunye kutusu acik mi - AVATARA tiklayinca acilir/kapanir (kullanici). */
  const [kunyeAcik, setKunyeAcik] = useState(true);
  const [emojiAcik, setEmojiAcik] = useState(false);
  const ekRef = useRef<HTMLDivElement | null>(null);
  const sabitRef = useRef<HTMLDivElement | null>(null);
  const [yeniAcik, setYeniAcik] = useState<null | 'kisi' | 'grup'>(null);
  const akisRef = useRef<HTMLDivElement | null>(null);

  const seciliSohbet = useMemo(
    () => sohbetler.find(s => s.id === secili) ?? null, [sohbetler, secili]);

  // Sohbet ICI arama istemci tarafinda: akis zaten bellekte, her tusa sunucuya
  //   gitmek gereksiz. Arama kapaliyken (null) tam akis gosterilir.
  const gorunenMesajlar = useMemo(() => {
    const q = (akisAra ?? '').trim().toLocaleLowerCase('tr');
    if (!q) return mesajlar;
    return mesajlar.filter(m => m.metin.toLocaleLowerCase('tr').includes(q));
  }, [mesajlar, akisAra]);

  const listeYukle = useCallback(async () => {
    const y = await api.mesajSohbetler(filtre, ara);
    setSohbetler((y.sohbetler ?? []) as unknown as Sohbet[]);
    if (y.ozet) setOzet(y.ozet);
  }, [filtre, ara]);

  const akisYukle = useCallback(async (sohbetId: number) => {
    const y = await api.mesajAkis(sohbetId);
    setMesajlar((y.mesajlar ?? []) as unknown as Mesaj[]);
    await api.mesajOkundu(sohbetId);
  }, []);

  useEffect(() => { void guvenli(listeYukle) }, [listeYukle]);

  useEffect(() => {
    if (secili === null) { setMesajlar([]); setBilgi(null); return }
    void guvenli(async () => {
      await akisYukle(secili);
      setBilgi(await api.mesajBilgi(secili));
    });
  }, [secili, akisYukle]);

  // TAZELEME: liste ve açık sohbet birlikte. Sekme arka plandayken de çalışır -
  //   kullanıcı geri döndüğünde okunmamış sayısı güncel olsun.
  useEffect(() => {
    const t = window.setInterval(() => {
      void listeYukle().catch(() => { /* tazelemede sessiz */ });
      if (secili !== null) void akisYukle(secili).catch(() => { /* sessiz */ });
    }, TAZELE_MS);
    return () => window.clearInterval(t);
  }, [listeYukle, akisYukle, secili]);

  // Yeni mesaj gelince akışın SONUNA kaydır (mockup: akış altta açılır).
  useEffect(() => {
    const el = akisRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [mesajlar.length, secili]);

  async function gonder() {
    const yazi = metin.trim();
    if (!yazi || secili === null) return;
    await guvenli(async () => {
      await api.mesajGonder(secili, yazi, yanit?.id);
      setMetin(''); setYanit(null);
      await akisYukle(secili);
      await listeYukle();
    });
  }

  async function bayrak(s: Sohbet, alan: 'favori' | 'sabit' | 'sessiz' | 'arsiv') {
    await guvenli(async () => {
      await api.mesajBayrak(s.id, { [alan]: s[alan] ? 0 : 1 });
      await listeYukle();
    });
  }

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Mesajlar</h1>
          <span className="yol">İletişim &amp; AI › Mesajlar</span>
        </div>
      </div>

      {/* Araç çubuğu - mockup'taki üst şerit. */}
      <div className="msj-arac">
        <button className="d bir" onClick={() => setYeniAcik('kisi')}>💬 Yeni Sohbet</button>
        <button className="d" onClick={() => setYeniAcik('grup')}>👥 Yeni Grup</button>
        <button className="d" disabled title="Sıradaki iş">📎 Kayıt İliştir</button>
        <button className="d" disabled title="Sıradaki iş">✅ Görev Oluştur</button>
        <span className="msj-durum">
          Okunmamış: <b>{ozet.okunmamisMesaj} mesaj / {ozet.okunmamisSohbet} sohbet</b>
          {' · '}Bugün: <b>{ozet.bugunMesaj} mesaj</b> · {ozet.bugunEk} ek ·{' '}
          {ozet.bugunKayit} iliştirilen kayıt
          {seciliSohbet && <> · Seçili: <b>{seciliSohbet.baslik}</b></>}
        </span>
      </div>

      <div className="msj-govde">
        {/* ---------------------------------------------- SOL: sohbet listesi */}
        <div className="msj-sol">
          {/* Mockup'taki "benim" seridi: kendi avatarim + hizli dugmeler. */}
          <div className="msj-benim">
            <div className="msj-av" style={{ background: renk(kullanici?.ad ?? '') }}>
              {basHarf(kullanici?.ad ?? '')}
            </div>
            <div style={{ minWidth: 0 }}>
              <div className="ad">{kullanici?.ad ?? ''}</div>
              <div className="sonuk">{kullanici?.rolAdi ?? ''}</div>
            </div>
            <div className="msj-ikonlar">
              <span title="Yeni sohbet" onClick={() => setYeniAcik('kisi')}>💬</span>
              <span title="Yeni grup" onClick={() => setYeniAcik('grup')}>👥</span>
            </div>
          </div>
          <div className="msj-ara">
            <input placeholder="Sohbet / kişi ara…" value={ara}
                   onChange={e => setAra(e.target.value)} />
          </div>
          <div className="msj-cipler">
            {CIPLER.map(c => (
              <span key={c.kod} className={`msj-cip${filtre === c.kod ? ' on' : ''}`}
                    onClick={() => setFiltre(c.kod)}>
                {c.ad}
                {c.kod === 'okunmamis' && ozet.okunmamisMesaj > 0 && (
                  <b> {ozet.okunmamisMesaj}</b>
                )}
              </span>
            ))}
          </div>

          <div className="msj-liste">
            {sohbetler.length === 0 && <div className="not">Sohbet yok.</div>}
            {sohbetler.map(s => (
              <div key={s.id} className={`msj-satir${s.id === secili ? ' on' : ''}`}
                   onClick={() => setSecili(s.id)}>
                <div className="msj-av" style={{ background: renk(s.baslik) }}>
                  {s.tip === 2 ? '👥' : basHarf(s.baslik)}
                </div>
                <div className="msj-satir-ic">
                  <div className="msj-satir-ust">
                    <span className="ad">
                      {s.sabit === 1 && '📌 '}{s.baslik}
                      {s.tip === 2 && <span className="sonuk"> · {s.uyeSayisi} üye</span>}
                    </span>
                    <span className="sa">{kisaZaman(s.sonTarih)}</span>
                  </div>
                  <div className="msj-satir-alt">
                    <span className="pv">
                      {s.sonGonderenId === benId && s.sonMetin ? 'Siz: ' : ''}{s.sonMetin}
                    </span>
                    {s.okunmamis > 0 && <span className="msj-sayac">{s.okunmamis}</span>}
                    {s.sessiz === 1 && <span className="sonuk" title="Bildirim kapalı">🔕</span>}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ------------------------------------------------ ORTA: mesaj akışı */}
        <div className="msj-orta">
          {seciliSohbet === null ? (
            <div className="not" style={{ padding: 24 }}>
              Soldan bir sohbet seçin ya da <b>Yeni Sohbet</b> açın.
            </div>
          ) : (
            <>
              <div className="msj-ust">
                <div className="msj-av" style={{ background: renk(seciliSohbet.baslik) }}>
                  {seciliSohbet.tip === 2 ? '👥' : basHarf(seciliSohbet.baslik)}
                </div>
                <div style={{ minWidth: 0 }}>
                  <div className="nm">{seciliSohbet.baslik}</div>
                  <div className="du sonuk">
                    {seciliSohbet.tip === 2
                      ? `${seciliSohbet.uyeSayisi} üye`
                      : [String(bilgi?.kunye?.gorev ?? ''),
                         String(bilgi?.kunye?.departman ?? ''),
                         String(bilgi?.kunye?.sube ?? '')]
                          .filter(Boolean).join(' · ') || 'Kişi sohbeti'}
                  </div>
                </div>
                <div className="msj-ikonlar">
                  {/* Mockup ust serit ikonlari: ara · ekler · sabitlenenler ·
                      bildirim · bilgi. Ekler/sabitler sag paneldeki ilgili
                      kutuya kaydirir - ayri pencere acmak ayni bilgiyi iki
                      yerde tutmak olurdu. */}
                  <span className={akisAra !== null ? 'on' : ''} title="Sohbette ara"
                        onClick={() => setAkisAra(a => (a === null ? '' : null))}>🔎</span>
                  <span title="Ekli dosyalar" onClick={() => {
                    setSagAcik(true);
                    window.setTimeout(() => ekRef.current?.scrollIntoView({ block: 'nearest' }), 0);
                  }}>📎</span>
                  <span title="Sabitlenen mesajlar" onClick={() => {
                    setSagAcik(true);
                    window.setTimeout(() => sabitRef.current?.scrollIntoView({ block: 'nearest' }), 0);
                  }}>📌</span>
                  <span className={sagAcik ? 'on' : ''} title="Sohbet bilgisi"
                        onClick={() => setSagAcik(a => !a)}>ℹ</span>
                  <span className={seciliSohbet.favori ? 'on' : ''} title="Favori"
                        onClick={() => void bayrak(seciliSohbet, 'favori')}>★</span>
                  <span className={seciliSohbet.sabit ? 'on' : ''} title="Sabitle"
                        onClick={() => void bayrak(seciliSohbet, 'sabit')}>📌</span>
                  <span className={seciliSohbet.sessiz ? 'on' : ''} title="Bildirimi kapat"
                        onClick={() => void bayrak(seciliSohbet, 'sessiz')}>🔕</span>
                  <span className={seciliSohbet.arsiv ? 'on' : ''} title="Arşivle"
                        onClick={() => void bayrak(seciliSohbet, 'arsiv')}>🗄</span>
                </div>
              </div>

              {akisAra !== null && (
                <div className="msj-akisara">
                  <input autoFocus placeholder="Bu sohbette ara…" value={akisAra}
                         onChange={e => setAkisAra(e.target.value)} />
                  <span className="sonuk">{gorunenMesajlar.length} sonuç</span>
                  <span className="x" onClick={() => setAkisAra(null)}>✕</span>
                </div>
              )}

              <div className="msj-akis" ref={akisRef}>
                {gorunenMesajlar.map((m, i) => (
                  <div key={m.id} className="msj-satirkap">
                  {/* GUN AYRACI: tarih degisince araya "Bugün / dün / 13.08". */}
                  {(i === 0 || new Date(gorunenMesajlar[i - 1].tarih).toDateString()
                              !== new Date(m.tarih).toDateString()) && (
                    <div className="msj-gun">{gunEtiketi(m.tarih)}</div>
                  )}
                  {m.tip === 3 ? (
                    <div className="msj-sistem">{m.metin}</div>
                  ) : (
                  <div
                       className={`msj-balon${m.gonderenId === benId ? ' benim' : ''}`}>
                    {m.gonderenId !== benId && seciliSohbet.tip === 2 && (
                      <div className="kim">{m.gonderen}</div>
                    )}
                    {m.yanitId && (
                      <div className="alinti">
                        <b>{m.yanitGonderen}</b> {m.yanitMetin}
                      </div>
                    )}
                    <div className="metin">
                      {m.durum === 2 ? <i className="sonuk">Bu mesaj silindi.</i> : m.metin}
                    </div>
                    <div className="alt">
                      {m.sabit === 1 && <span title="Sabitlenmiş">📌</span>}
                      <span>{saat(m.tarih)}</span>
                      {m.gonderenId === benId && (
                        <span className={m.okumayan === 0 ? 'tik ok' : 'tik'}
                              title={m.okumayan === 0 ? 'Okundu' : 'İletildi'}>✓✓</span>
                      )}
                      {m.durum === 1 && (
                        <span className="islem" onClick={() => setYanit(m)}>↩</span>
                      )}
                      {m.durum === 1 && (
                        <span className="islem" title={m.sabit ? 'Sabitlemeyi kaldır' : 'Sabitle'}
                              onClick={() => void guvenli(async () => {
                                await api.mesajSabit(m.id, m.sabit === 1);
                                if (secili !== null) {
                                  await akisYukle(secili);
                                  setBilgi(await api.mesajBilgi(secili));
                                }
                              })}>📌</span>
                      )}
                      {m.durum === 1 && m.gonderenId === benId && (
                        <span className="islem" title="Sil"
                              onClick={() => void guvenli(async () => {
                                await api.mesajSil(m.id);
                                if (secili !== null) await akisYukle(secili);
                              })}>🗑</span>
                      )}
                    </div>
                  </div>
                  )}
                  </div>
                ))}
                {gorunenMesajlar.length === 0 && (
                  <div className="not">
                    {akisAra ? 'Aramaya uyan mesaj yok.' : 'Henüz mesaj yok - ilk mesajı siz yazın.'}
                  </div>
                )}
              </div>

              {yanit && (
                <div className="msj-yanit">
                  <span className="bar" />
                  <div style={{ minWidth: 0 }}>
                    <div className="a">Yanıtlanan · {yanit.gonderen}</div>
                    <div className="t">{yanit.metin}</div>
                  </div>
                  <span className="x" onClick={() => setYanit(null)}>✕</span>
                </div>
              )}

              <div className="msj-yazma">
                {/* Ek menusu - mockup'taki bes madde. Bugun calisan tek madde
                    KAYIT ILISTIRME; otekiler dokuman deposu / gorev baglaninca
                    acilacak, simdiden gorunup yaniltmasin diye pasif. */}
                <div className="msj-atac">
                  <span title="İliştir" onClick={() => setAtacAcik(a => !a)}>📎</span>
                  {atacAcik && (
                    <div className="msj-atac-menu" onMouseLeave={() => setAtacAcik(false)}>
                      <div onClick={() => { setAtacAcik(false); setKayitAcik(true) }}>
                        📑 Gentegre Kaydı İliştir…
                      </div>
                      <div className="pasif" title="Sıradaki iş">📄 Dosya / Görsel</div>
                      <div className="pasif" title="Sıradaki iş">✅ Görev Oluştur…</div>
                      <div className="pasif" title="Sıradaki iş">🖐 Onay İsteği Gönder…</div>
                      <div className="pasif" title="Sıradaki iş">📊 Rapor / Döküm Paylaş…</div>
                    </div>
                  )}
                </div>
                <div className="msj-atac">
                  <span title="Emoji" onClick={() => setEmojiAcik(a => !a)}>🙂</span>
                  {emojiAcik && (
                    <div className="msj-atac-menu msj-emoji" onMouseLeave={() => setEmojiAcik(false)}>
                      {['🙂', '👍', '🙏', '✅', '❗', '📌', '🎉', '😅', '🤝', '📎', '⏱', '❤️']
                        .map(e => (
                          <span key={e} onClick={() => { setMetin(t => t + e); setEmojiAcik(false) }}>
                            {e}
                          </span>
                        ))}
                    </div>
                  )}
                </div>
                <input placeholder="Mesaj yaz…" value={metin}
                       onChange={e => setMetin(e.target.value)}
                       onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); void gonder() } }} />
                <button className="d bir" onClick={() => void gonder()}>➤ Gönder</button>
              </div>
            </>
          )}
        </div>

        {/* ------------------------------------------- SAĞ: sohbet bilgisi */}
        <div className="msj-sag" hidden={!sagAcik}>
          {seciliSohbet === null ? (
            <div className="not">Sohbet seçilmedi.</div>
          ) : (
            <>
              {/* SOHBET BİLGİSİ - mockup düzeni: büyük avatar + ad + ünvan,
                  altında künye satırları. AVATARA TIKLAYINCA künye kapanır
                  (kullanıcı): dar ekranda ekler/kayıtlar yukarı gelsin. */}
              <div className="msj-kunye">
                <div className="msj-kunye-av" title="Künyeyi aç / kapat"
                     style={{ background: renk(seciliSohbet.baslik) }}
                     onClick={() => setKunyeAcik(a => !a)}>
                  {seciliSohbet.tip === 2 ? '👥' : basHarf(seciliSohbet.baslik)}
                </div>
                <div className="nm">{seciliSohbet.baslik}</div>
                <div className="mt sonuk">
                  {seciliSohbet.tip === 2
                    ? `Grup · ${seciliSohbet.uyeSayisi} katılımcı`
                    : [String(bilgi?.kunye?.gorev ?? ''), String(bilgi?.kunye?.departman ?? '')]
                        .filter(Boolean).join(' · ') || 'Kişi sohbeti'}
                </div>
                <div className="tuslar">
                  {seciliSohbet.tip === 1 && seciliSohbet.karsiId && (
                    <a className="minibtn" href={`/personel/${seciliSohbet.karsiId}`}>
                      👤 Personel Kartı
                    </a>
                  )}
                  <span className="minibtn"
                        onClick={() => setAkisAra(a => (a === null ? '' : null))}>
                    🔎 Sohbette Ara
                  </span>
                </div>
              </div>

              {kunyeAcik && bilgi?.kunye && (
                <div className="kagrup">
                  <h6>Künye</h6>
                  <div className="msj-kv"><span>Telefon</span><b>{String(bilgi.kunye.telefon || '—')}</b></div>
                  <div className="msj-kv"><span>Cep</span><b>{String(bilgi.kunye.cep || '—')}</b></div>
                  <div className="msj-kv"><span>E-posta</span><b>{String(bilgi.kunye.eposta || '—')}</b></div>
                  <div className="msj-kv"><span>Şube</span><b>{String(bilgi.kunye.sube || '—')}</b></div>
                  <div className="msj-kv"><span>Kod</span><b>{String(bilgi.kunye.kod || '—')}</b></div>
                  {String(bilgi.kunye.cari ?? '') !== '' && (
                    <>
                      <div className="msj-kv"><span>Cari</span><b>{String(bilgi.kunye.cari)}</b></div>
                      <div className="tuslar">
                        <a className="minibtn on" href={`/cari/${Number(bilgi.kunye.cariId)}`}>
                          👤 Cari Kartını Aç
                        </a>
                      </div>
                    </>
                  )}
                </div>
              )}

              {kunyeAcik && seciliSohbet.tip === 2 && (
                <div className="kagrup">
                  <h6>Katılımcılar ({bilgi?.uyeler.length ?? 0})</h6>
                  {(bilgi?.uyeler ?? []).map((u, i) => (
                    <div key={i} className="msj-uye">
                      <span className="msj-av kk" style={{ background: renk(String(u.ad ?? '')) }}>
                        {basHarf(String(u.ad ?? ''))}
                      </span>
                      <span className="ad">
                        {String(u.ad ?? '')}
                        {Number(u.kullaniciId) === benId && <i className="sonuk"> (sen)</i>}
                      </span>
                      <span className={`rozet ${Number(u.rol) === 2 ? 'mor' : 'gri'}`}>
                        {Number(u.rol) === 2 ? 'yönetici' : 'üye'}
                      </span>
                    </div>
                  ))}
                </div>
              )}

              <div className="kagrup" ref={sabitRef}>
                <h6>📌 Sabitlenen mesajlar ({bilgi?.sabitler.length ?? 0})</h6>
                {(bilgi?.sabitler ?? []).length === 0
                  ? <div className="not">Sabitlenmiş mesaj yok.</div>
                  : (bilgi?.sabitler ?? []).map((m, i) => (
                    <div key={i} className="not">
                      <b>{String(m.gonderen ?? '')}</b>: {String(m.metin ?? '')}
                    </div>
                  ))}
              </div>

              <div className="kagrup" ref={ekRef}>
                <h6>📎 Ekli dosyalar ({bilgi?.ekler.length ?? 0})</h6>
                {(bilgi?.ekler ?? []).length === 0
                  ? <div className="not">Ek yok.</div>
                  : (bilgi?.ekler ?? []).map((e, i) => (
                    <div key={i} className="msj-uye">
                      <span className="ad">📎 {String(e.ad ?? '')}</span>
                      <span className="sonuk">{kisaZaman(String(e.tarih ?? ''))}</span>
                    </div>
                  ))}
              </div>

              <div className="kagrup">
                <h6>🔗 İliştirilen kayıtlar ({bilgi?.kayitlar.length ?? 0})</h6>
                {(bilgi?.kayitlar ?? []).length === 0
                  ? <div className="not">İliştirilmiş kayıt yok.</div>
                  : (bilgi?.kayitlar ?? []).map((k, i) => (
                    <div key={i} className="msj-uye">
                      {/* "Karti Ac": kart kopyalanmaz, ilgili ekran calisir -
                          yetki orada kontrol edilir (342). */}
                      <a className="ad" href={`/${String(k.modul)}/${Number(k.kayitId)}`}>
                        📑 {String(k.ozet || `${k.modul} #${k.kayitId}`)}
                      </a>
                      <span className="sonuk">{kisaZaman(String(k.tarih ?? ''))}</span>
                    </div>
                  ))}
              </div>
              <div className="kagrup">
                <h6>🔔 Bildirim</h6>
                <div className="msj-kv">
                  <span>Durum</span>
                  <b>
                    <span className={`rozet ${seciliSohbet.sessiz ? 'gri' : 'ok'}`}>
                      {seciliSohbet.sessiz ? 'Sessiz' : 'Açık'}
                    </span>
                  </b>
                </div>
                <div className="tuslar">
                  <span className="minibtn" onClick={() => void bayrak(seciliSohbet, 'sessiz')}>
                    {seciliSohbet.sessiz ? '🔔 Bildirimi Aç' : '🔕 Bildirimi Kapat'}
                  </span>
                  <span className="minibtn" onClick={() => void bayrak(seciliSohbet, 'arsiv')}>
                    {seciliSohbet.arsiv ? '📥 Arşivden Çıkar' : '🗄 Arşivle'}
                  </span>
                  <span className="minibtn" onClick={() => void bayrak(seciliSohbet, 'favori')}>
                    {seciliSohbet.favori ? '☆ Favoriden Çıkar' : '★ Favorile'}
                  </span>
                </div>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Mockup'un alt notu: okundu kuralini ve ilistirmenin ne YAPMADIGINI
          soyler - kullanici "mesajimi okudu mu" sorusunu buradan cevaplar. */}
      <div className="not msj-altnot">
        Okundu bilgisi mesaj başına tutulmaz: üyenin <b>son okuma</b> damgası mesaj
        tarihinden büyükse mesaj o üye için okunmuştur; grupta herkes okuduğunda
        tik maviye döner. Mesajlar <b>şubeler arasıdır</b>. Kayıt iliştirmede kartın
        kendisi kopyalanmaz - “Kartı Aç” ilgili ekranı çalıştırır, yetkisi olmayan
        kullanıcı yalnız özet satırını görür.
      </div>

      {kayitAcik && secili !== null && (
        <KayitIlistir
          onKapat={() => setKayitAcik(false)}
          onIlistir={async (modul, kayitId, ozet) => {
            await guvenli(async () => {
              await api.mesajGonder(secili, ozet || `${modul} #${kayitId}`, undefined,
                                    { modul, kayitId, ozet });
              setKayitAcik(false);
              await akisYukle(secili);
              setBilgi(await api.mesajBilgi(secili));
              await listeYukle();
            });
          }}
        />
      )}

      {yeniAcik && (
        <YeniSohbet
          tip={yeniAcik}
          onKapat={() => setYeniAcik(null)}
          onAcildi={async id => {
            setYeniAcik(null);
            await guvenli(listeYukle);
            setSecili(id);
          }}
        />
      )}
    </>
  );
}

/** Yeni kişi sohbeti / grup: kullanıcı arama + seçim. */
function YeniSohbet({ tip, onKapat, onAcildi }: {
  tip: 'kisi' | 'grup'; onKapat(): void; onAcildi(id: number): Promise<void>;
}) {
  const [ara, setAra] = useState('');
  const [kisiler, setKisiler] = useState<{ id: number; ad: string; gorev: string }[]>([]);
  const [secili, setSecili] = useState<number[]>([]);
  const [grupAdi, setGrupAdi] = useState('');

  useEffect(() => {
    const t = window.setTimeout(() => {
      void guvenli(async () => setKisiler((await api.mesajKisiler(ara)).kisiler));
    }, 250);
    return () => window.clearTimeout(t);
  }, [ara]);

  const sec = (id: number) => setSecili(s =>
    tip === 'kisi' ? [id] : s.includes(id) ? s.filter(x => x !== id) : [...s, id]);

  /** Listeyi tek tek isaretleyip "Aç"a basmak yerine CIFT TIK: kisi
      sohbetinde dogrudan acar, grupta secime ekler (kullanici). */
  const ac = async (id: number) => {
    if (tip === 'grup') { sec(id); return }
    await guvenli(async () => {
      const y = await api.mesajSohbetAc({ tip: 1, uyeler: [id] });
      await onAcildi(y.id);
    });
  };

  return (
    <Modal baslik={tip === 'kisi' ? 'Yeni Sohbet' : 'Yeni Grup'} onKapat={onKapat}
      alt={
        <>
          <button className="d bir" onClick={() => void guvenli(async () => {
            if (secili.length === 0) { bilgiMesaji('En az bir kişi seçin.'); return }
            const y = await api.mesajSohbetAc({
              tip: tip === 'kisi' ? 1 : 2,
              ad: tip === 'grup' ? grupAdi : undefined,
              uyeler: secili,
            });
            await onAcildi(y.id);
          })}>Aç</button>
          <button className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>
        </>
      }>
      {tip === 'grup' && (
        <div className="alan-izgara tek-sutun" style={{ marginBottom: 8 }}>
          <label>Grup adı
            <input value={grupAdi} onChange={e => setGrupAdi(e.target.value)}
                   placeholder="ör. Satış Ekibi" />
          </label>
        </div>
      )}
      <input placeholder="Kişi ara…" value={ara} onChange={e => setAra(e.target.value)}
             style={{ width: '100%', marginBottom: 8 }} />
      <div className="msj-secim">
        {kisiler.map(k => (
          <div key={k.id} className={`msj-satir${secili.includes(k.id) ? ' on' : ''}`}
               onClick={() => sec(k.id)}
               onDoubleClick={() => void ac(k.id)}
               title="Çift tıkla: seç ve aç">
            <div className="msj-av" style={{ background: renk(k.ad) }}>{basHarf(k.ad)}</div>
            <div className="msj-satir-ic">
              <div className="ad">{k.ad}</div>
              <div className="sonuk">{k.gorev}</div>
            </div>
          </div>
        ))}
        {kisiler.length === 0 && <div className="not">Kullanıcı bulunamadı.</div>}
      </div>
    </Modal>
  );
}

/**
 * KAYIT ILISTIRME (342) - mockup'taki "Gentegre Kaydi Ilistir...".
 *
 * Kartin kendisi KOPYALANMAZ: modul + kayit kimligi mesaja baglanir, sohbette
 * ozet satiri gorunur, "Karti Ac" ilgili ekrani calistirir ve yetki orada
 * kontrol edilir.
 */
function KayitIlistir({ onKapat, onIlistir }: {
  onKapat(): void;
  onIlistir(modul: string, kayitId: number, ozet: string): Promise<void>;
}) {
  const MODULLER = [
    { kod: 'belge', ad: 'Belge (fatura / irsaliye / sipariş)' },
    { kod: 'cari',  ad: 'Cari kartı' },
    { kod: 'stok',  ad: 'Stok kartı' },
    { kod: 'hasta', ad: 'Hasta kartı' },
  ];
  const [modul, setModul] = useState('belge');
  const [kayitId, setKayitId] = useState('');
  const [ozet, setOzet] = useState('');

  return (
    <Modal baslik="Kayıt İliştir" dar onKapat={onKapat}
      alt={
        <>
          <button className="d bir" onClick={() => {
            const id = Number(kayitId);
            if (!id) { bilgiMesaji('Kayıt numarası girin.'); return }
            void onIlistir(modul, id, ozet.trim());
          }}>İliştir</button>
          <button className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>
        </>
      }>
      <div className="alan-izgara tek-sutun">
        <label>Modül
          <select value={modul} onChange={e => setModul(e.target.value)}>
            {MODULLER.map(m => <option key={m.kod} value={m.kod}>{m.ad}</option>)}
          </select>
        </label>
        <label>Kayıt no
          <input value={kayitId} onChange={e => setKayitId(e.target.value)}
                 placeholder="ör. 114325" />
        </label>
        <label>Özet (sohbette görünecek)
          <input value={ozet} onChange={e => setOzet(e.target.value)}
                 placeholder="ör. TKF.2026/0453 · Teklif" />
        </label>
      </div>
    </Modal>
  );
}
