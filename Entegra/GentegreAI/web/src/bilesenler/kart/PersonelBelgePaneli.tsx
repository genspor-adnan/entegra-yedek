import { Fragment, useEffect, useState, type ReactNode } from 'react';
import { api } from '../../api/istemci';
import { DokumanGalerisi } from '../DokumanGalerisi';
import { Modal } from '../Modal';
import { guvenli, mesaj, onay } from '../mesaj';
import { tarihSaat, tarihYaz } from '../bicim';
import { YAZDIR_ETIKETI } from '../yazdirBetigi';

/**
 * PERSONEL KARTI "BELGELER" SEKMESİ (1135-1137, mockup Ekranlar/IK/personel_belge_takibi.html (1)).
 * Kullanıcı 22.10.2026 "tek olsun" + "mockup gibi olmalı":
 *  · iç sekmeler: Özlük belgeleri (durum) · Belge kayıtları (düzenlenebilir grid);
 *  · sayaç kartları + özlük dosyası çubuğu; gruplu liste, satır rengi durumdan;
 *  · satırda işlem: Eksik ⬆ Yükle · Süresi doldu ⬆ Yenile · Yaklaşıyor 🔔 Hatırlat ·
 *    dosyası yok ⬆ Dosya; satıra tıklayınca belgenin dosyaları;
 *  · sağda Dikkat paneli; "📤 Eksikleri personele bildir".
 * Yükle / Yenile belge satırını ve dosyasını TEK adımda yazar (POST /api/ik/belge-takip/{id}/belge).
 * Mockup'taki vize başvurusu, şablon ve portal onayı sonraki aşamalar.
 */

type Satir = Record<string, unknown>;
const n = (x: unknown) => Number(x ?? 0);

const STIL = `
.pb-ust { display: flex; align-items: center; gap: 8px; margin: 10px 14px 0; flex-wrap: wrap }
.pb-isk { border: 1px solid var(--cizgi); background: var(--yuz); color: var(--yazi); border-radius: 14px;
  padding: 4px 13px; font: inherit; cursor: pointer }
.pb-isk.on { background: var(--mor); border-color: var(--mor); color: #fff; font-weight: 700 }
.pb-isk .say { margin-left: 6px; background: var(--uyarizem); color: var(--yazi2); border-radius: 8px; padding: 0 6px; font-size: 11px }
.pb-govde { display: grid; grid-template-columns: minmax(0, 1fr) 300px; gap: 12px; margin: 10px 14px }
@media (max-width: 1100px) { .pb-govde { grid-template-columns: minmax(0, 1fr) } }
.pb-kartlar { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 10px }
.pb-kart { border: 1px solid var(--cizgi); border-left: 4px solid var(--cizgi2); border-radius: 4px; padding: 7px 10px;
  background: var(--kartzem) }
.pb-kart .pb-e { font-size: 11px; color: var(--soluk) } .pb-kart .pb-d { font-size: 19px; font-weight: 700; color: var(--yazi2) }
.pb-kart.mavi { border-left-color: var(--mor) } .pb-kart.ok { border-left-color: var(--ok) } .pb-kart.ok .pb-d { color: var(--ok) }
.pb-kart.hata { border-left-color: var(--hata) } .pb-kart.hata .pb-d { color: var(--hata) }
.pb-kart.uyari { border-left-color: var(--uyari) } .pb-kart.uyari .pb-d { color: var(--uyari) }
.pb-cubuk { display: flex; align-items: center; gap: 10px; margin: 10px 0 8px; font-size: 12px; color: var(--soluk) }
.pb-cubuk .c { flex: 1; height: 8px; border-radius: 4px; overflow: hidden; display: flex; background: var(--cizgi) }
.pb-cubuk .y { font-weight: 700; color: var(--yazi2) }
.pb-tablo tr.pb-hata td { background: var(--hatazem) } .pb-tablo tr.pb-uyari td { background: var(--uyarizem) }
.pb-tablo tr.pb-tik { cursor: pointer }
.pb-tablo .k-hata { color: var(--hata); font-weight: 700 } .pb-tablo .k-uyari { color: var(--uyari); font-weight: 700 }
.pb-tablo .zr { color: var(--hata); font-weight: 700 }
.pb-tablo td .d { padding: 1px 8px; font-size: 11.5px }
.pb-rz { padding: 1px 9px; border-radius: 10px; font-size: 11px; display: inline-block; border: 1px solid }
.pb-rz.ok { background: var(--okzem); color: var(--ok); border-color: var(--okkenar) }
.pb-rz.hata { background: var(--hatazem); color: var(--hata); border-color: var(--hatakenar) }
.pb-rz.uyari { background: var(--uyarizem); color: var(--uyari); border-color: var(--uyarikenar) }
.pb-kv { display: grid; grid-template-columns: 92px minmax(0, 1fr); gap: 0 8px }
.pb-kv > span:nth-child(odd) { color: var(--soluk); font-size: 11.5px }
.pb-yan { display: flex; flex-direction: column; gap: 10px }
.pb-kutu { border: 1px solid var(--cizgi); border-radius: 4px; background: var(--kartzem) }
.pb-kutu .b { padding: 6px 10px; background: var(--grupzem); color: var(--grupyazi); font-weight: 700; border-bottom: 1px solid var(--cizgi) }
.pb-kutu ul { list-style: none; margin: 0; padding: 4px 10px }
.pb-kutu li { display: flex; gap: 8px; padding: 6px 0; border-bottom: 1px dashed var(--cizgi); font-size: 12px }
.pb-kutu li:last-child { border-bottom: none }
.pb-kutu .i { flex: none; width: 18px; height: 18px; border-radius: 50%; display: inline-flex; align-items: center;
  justify-content: center; font-size: 11px; font-weight: 700 }
.pb-kutu .i.hata { background: var(--hatazem); color: var(--hata); border: 1px solid var(--hatakenar) }
.pb-kutu .i.uyari { background: var(--uyarizem); color: var(--uyari); border: 1px solid var(--uyarikenar) }
.pb-kutu .i.ok { background: var(--okzem); color: var(--ok); border: 1px solid var(--okkenar) }
.pb-alt { display: flex; justify-content: space-between; font-size: 11px; color: var(--soluk); padding: 6px 2px 0 }
.pb-form { display: grid; grid-template-columns: 130px minmax(0, 1fr); gap: 8px 10px; align-items: center }
`;

export function PersonelBelgePaneli({ personelId, personelAd, durumlar, kayitlar, kayitSayisi, saltOkunur, onYenile }: {
  personelId: number;
  /** Kontrol listesi çıktısının başlığı. */
  personelAd: string;
  /** v_personel_belge_durum satırları (kart detayı "belgeDurumu"). */
  durumlar: Satir[];
  /** "Belge kayıtları" iç sekmesinde çizilen düzenlenebilir grid. */
  kayitlar: ReactNode;
  kayitSayisi: number;
  saltOkunur: boolean;
  /** Sunucuda belge eklendi: kartın belge detaylarını yeniden oku. */
  onYenile(): Promise<void>;
}) {
  const [ic, setIc] = useState<'ozluk' | 'kayit' | 'hareket'>('ozluk');
  const [seciliId, setSeciliId] = useState<number | null>(null);
  const [sayilar, setSayilar] = useState<Record<number, number>>({});
  const [yukle, setYukle] = useState<{ turId: number; ad: string; yenile: boolean } | null>(null);

  const zorunlu = durumlar.filter(d => n(d.zorunlu) === 1);
  const tamam = zorunlu.filter(d => n(d.durum) === 4).length;
  const yaklasanZ = zorunlu.filter(d => n(d.durum) === 3).length;
  const eksik = zorunlu.filter(d => n(d.durum) === 1).length;
  const doldu = durumlar.filter(d => n(d.durum) === 2).length;
  const yaklasan = durumlar.filter(d => n(d.durum) === 3).length;
  const yuzde = zorunlu.length ? Math.round(100 * (tamam + yaklasanZ) / zorunlu.length) : 100;
  const pay = (x: number) => `${zorunlu.length ? 100 * x / zorunlu.length : 0}%`;
  const sorunlu = durumlar.some(d => [1, 2, 3].includes(n(d.durum)) && (n(d.zorunlu) === 1 || n(d.durum) > 1));
  const secili = durumlar.find(d => n(d.belgeId) === seciliId);
  // Hatırlatma günü türden; tek tür sayılmasın diye en sık kullanılan gösterilir.
  const hatirlatGun = (() => {
    const say = new Map<number, number>();
    durumlar.forEach(d => { const g = n(d.hatirlatGun) || 60; say.set(g, (say.get(g) ?? 0) + 1) });
    return [...say.entries()].sort((a, b) => b[1] - a[1])[0]?.[0] ?? 60;
  })();

  const hatirlat = async () => {
    if (!await onay('Eksik / süresi dolan / yaklaşan belgeler personele bildirilecek (e-postası varsa e-posta, yoksa SMS). Onaylıyor musunuz?')) return;
    await guvenli(async () => {
      const y = await api.belgeTakipHatirlat([personelId]);
      mesaj(y.kuyruga > 0 ? 'Hatırlatma gönderim kuyruğuna alındı.'
                          : `Gönderilmedi: ${y.atlanan.map(a => a.neden).join(', ') || 'bilinmeyen neden'}.`);
    });
  };

  // DİKKAT: süresi dolan, eksik zorunlu, dosyası yüklenmemiş, yaklaşanlar tek satırda.
  const dikkat: { sinif: 'hata' | 'uyari'; metin: string }[] = [
    ...durumlar.filter(d => n(d.durum) === 2).map(d => ({ sinif: 'hata' as const,
      metin: `${d.belge} ${Math.abs(n(d.kalanGun))} gün önce doldu.` })),
    ...zorunlu.filter(d => n(d.durum) === 1).map(d => ({ sinif: 'hata' as const,
      metin: n(d.belgeId) > 0 ? `${d.belge}: dosyası yüklenmedi.` : `${d.belge} yok.` })),
    ...(yaklasan ? [{ sinif: 'uyari' as const, metin: durumlar.filter(d => n(d.durum) === 3)
      .map(d => `${d.belge} ${n(d.kalanGun)} gün`).join(', ') + '.' }] : []),
  ];

  let sonGrup = '';
  return (
    <>
      <style>{STIL}</style>
      <div className="pb-ust">
        <button type="button" className={`pb-isk${ic === 'ozluk' ? ' on' : ''}`} onClick={() => setIc('ozluk')}>🗂 Özlük belgeleri</button>
        <button type="button" className={`pb-isk${ic === 'kayit' ? ' on' : ''}`} onClick={() => setIc('kayit')}>
          ✎ Belge kayıtları<span className="say">{kayitSayisi}</span>
        </button>
        <button type="button" className={`pb-isk${ic === 'hareket' ? ' on' : ''}`} onClick={() => setIc('hareket')}>🕘 Hareketler</button>
        <span style={{ flex: 1 }} />
        {durumlar.length > 0 && (
          <button type="button" className="d" onClick={() => kontrolListesi(personelAd, durumlar)}>🖨 Özlük dosyası kontrol listesi</button>
        )}
        {!saltOkunur && sorunlu && (
          <button type="button" className="d" onClick={() => void hatirlat()}>📤 Eksikleri personele bildir</button>
        )}
      </div>

      {ic === 'kayit' && kayitlar}
      {ic === 'hareket' && <Hareketler personelId={personelId} />}

      {ic === 'ozluk' && durumlar.length === 0 && (
        <div style={{ margin: '10px 14px', color: 'var(--soluk)' }}>
          Bu personele zorunlu belge tanımlı değil (İK › Belge Takibi › Belge Türleri › Kime zorunlu).
          Elindeki belgeleri "Belge kayıtları"na girebilirsiniz.
        </div>
      )}

      {ic === 'ozluk' && durumlar.length > 0 && (
        <div className="pb-govde">
          <div>
            <div className="pb-kartlar">
              <div className="pb-kart mavi" style={{ borderWidth: 2, borderColor: 'var(--mor)', borderLeftWidth: 4 }}><div className="pb-e">Zorunlu belge</div><div className="pb-d">{zorunlu.length}</div></div>
              <div className="pb-kart ok"><div className="pb-e">Tamam</div><div className="pb-d">{tamam}</div></div>
              <div className="pb-kart hata"><div className="pb-e">Eksik</div><div className="pb-d">{eksik}</div></div>
              <div className="pb-kart hata"><div className="pb-e">Süresi doldu</div><div className="pb-d">{doldu}</div></div>
              <div className="pb-kart uyari"><div className="pb-e">Süresi yaklaşan</div><div className="pb-d">{yaklasan}</div></div>
            </div>
            <div className="pb-cubuk">
              Özlük dosyası
              <div className="c" title={`Tamam ${tamam} · Yaklaşan ${yaklasanZ} · Eksik / doldu ${zorunlu.length - tamam - yaklasanZ}`}>
                <span style={{ width: pay(tamam), background: 'var(--ok)' }} />
                <span style={{ width: pay(yaklasanZ), background: 'var(--uyari)' }} />
                <span style={{ width: pay(zorunlu.length - tamam - yaklasanZ), background: 'var(--hata)' }} />
              </div>
              <span className="y">%{yuzde}</span>
            </div>

            <table className="grid pb-tablo">
              <thead>
                <tr>
                  <th>Belge</th><th className="hiza-orta">Zorunlu</th><th>Durum</th><th>Belge tarihi</th>
                  <th>Geçerlilik</th><th>Kalan</th><th className="hiza-orta">Dosya</th><th />
                </tr>
              </thead>
              <tbody>
                {durumlar.map(d => {
                  const grup = String(d.grupAdi ?? '');
                  const baslik = grup !== sonGrup;
                  sonGrup = grup;
                  const durum = n(d.durum);
                  const belgeId = n(d.belgeId);
                  const dosya = belgeId > 0 ? (sayilar[belgeId] ?? n(d.dosyaSayisi)) : 0;
                  const kalan = d.kalanGun == null || d.kalanGun === '' ? null : n(d.kalanGun);
                  const sinif = durum === 1 || durum === 2 ? 'pb-hata' : durum === 3 ? 'pb-uyari' : '';
                  const ad = String(d.belge ?? '');
                  return (
                    <Fragment key={String(d.id)}>
                      {baslik && <tr className="grup-bas"><td colSpan={8}>{grup}</td></tr>}
                      <tr className={`${sinif}${belgeId > 0 ? ' pb-tik' : ''}${belgeId > 0 && belgeId === seciliId ? ' secili' : ''}`}
                          title={belgeId > 0 ? 'Dosyalarını göster' : undefined}
                          onClick={() => belgeId > 0 && setSeciliId(belgeId === seciliId ? null : belgeId)}>
                        <td>{ad}</td>
                        <td className={`hiza-orta${n(d.zorunlu) === 1 && (durum === 1 || durum === 2) ? ' zr' : ''}`}>
                          {n(d.zorunlu) === 1 ? '✓' : ''}
                        </td>
                        <td><span className={`pb-rz ${durum === 4 ? 'ok' : durum === 3 ? 'uyari' : 'hata'}`}>{String(d.durumAdi ?? '')}</span></td>
                        <td>{d.belgeTarihi ? tarihYaz(String(d.belgeTarihi)) : '—'}</td>
                        <td>{d.gecerlilikTarihi ? tarihYaz(String(d.gecerlilikTarihi)) : belgeId > 0 ? 'süresiz' : '—'}</td>
                        <td className={durum === 2 ? 'k-hata' : durum === 3 ? 'k-uyari' : 'sonuk'}>
                          {kalan == null ? '' : `${kalan < 0 ? '−' : ''}${Math.abs(kalan)} gün`}
                        </td>
                        <td className="hiza-orta" title={dosya > 0 ? `${dosya} dosya` : undefined}>
                          {dosya > 0 ? (dosya > 1 ? `📄${dosya}` : '📄') : ''}
                        </td>
                        <td className="hiza-sag" style={{ whiteSpace: 'nowrap' }} onClick={e => e.stopPropagation()}>
                          {!saltOkunur && durum === 1 && belgeId === 0 && (
                            <button type="button" className="d" onClick={() => setYukle({ turId: n(d.belgeTuruId), ad, yenile: false })}>⬆ Yükle</button>
                          )}
                          {!saltOkunur && durum === 1 && belgeId > 0 && (
                            <button type="button" className="d" onClick={() => setSeciliId(belgeId)}>⬆ Dosya</button>
                          )}
                          {!saltOkunur && durum === 2 && (
                            <button type="button" className="d" onClick={() => setYukle({ turId: n(d.belgeTuruId), ad, yenile: true })}>⬆ Yenile</button>
                          )}
                          {!saltOkunur && durum === 3 && (
                            <button type="button" className="d" onClick={() => void hatirlat()}>🔔 Hatırlat</button>
                          )}
                        </td>
                      </tr>
                    </Fragment>
                  );
                })}
              </tbody>
            </table>

            {secili && (
              <div className="pb-kutu" style={{ marginTop: 10 }}>
                <div className="b">📎 {String(secili.belge ?? '')} - dosyalar</div>
                <DokumanGalerisi key={seciliId!} kartAdi="personelBelge" kaynakId={seciliId!} saltOkunur={saltOkunur}
                                 onSayi={x => setSayilar(o => o[seciliId!] === x ? o : { ...o, [seciliId!]: x })} />
              </div>
            )}
            <div className="pb-alt">
              <span>Zorunlu {zorunlu.length} belge · durum belge türü kurallarından (İK › Belge Türleri)</span>
              <span>Belge erişimi loglanır</span>
            </div>
          </div>

          <div className="pb-yan">
            <div className="pb-kutu">
              <div className="b">⚑ Dikkat</div>
              <ul>
                {dikkat.length === 0 && <li><span className="i ok">✓</span>Eksik ya da süresi dolan belge yok.</li>}
                {dikkat.map((x, i) => (
                  <li key={i}><span className={`i ${x.sinif}`}>{x.sinif === 'hata' ? '!' : '⏱'}</span>{x.metin}</li>
                ))}
              </ul>
            </div>
            <div className="pb-kutu">
              <div className="b" style={{ display: 'flex' }}>🔔 Hatırlatma kuralı
                <span style={{ marginLeft: 'auto', fontWeight: 400, fontSize: 11 }}>belge türünden</span></div>
              <ul>
                <li className="pb-kv"><span>{hatirlatGun} gün önce</span><span>"Yaklaşıyor" - listede sarı, İK takipte</span></li>
                <li className="pb-kv"><span>elle</span><span>📤 personele e-posta, yoksa SMS (24 saatte bir)</span></li>
                <li className="pb-kv"><span>süre dolunca</span><span>"Süresi doldu" - eksik sayılır</span></li>
              </ul>
            </div>
          </div>
        </div>
      )}

      {yukle && (
        <BelgeYukle personelId={personelId} turId={yukle.turId} ad={yukle.ad} yenile={yukle.yenile}
                    onKapat={() => setYukle(null)}
                    onBitti={async () => { setYukle(null); await onYenile() }} />
      )}
    </>
  );
}

/** Eksik belgeyi yükle / süresi doleni yenile: belge satırı + dosyası tek adımda. */
function BelgeYukle({ personelId, turId, ad, yenile, onKapat, onBitti }: {
  personelId: number; turId: number; ad: string; yenile: boolean;
  onKapat(): void; onBitti(): Promise<void>;
}) {
  const [tarih, setTarih] = useState(new Date().toISOString().slice(0, 10));
  const [gecerlilik, setGecerlilik] = useState('');
  const [no, setNo] = useState('');
  const [dosya, setDosya] = useState<File | null>(null);
  const [bekle, setBekle] = useState(false);

  const kaydet = async () => {
    if (!dosya) { mesaj('Dosya seçin.'); return }
    setBekle(true);
    try {
      await guvenli(async () => {
        const f = new FormData();
        f.append('belgeTuruId', String(turId));
        if (tarih) f.append('belgeTarihi', tarih);
        if (gecerlilik) f.append('gecerlilikTarihi', gecerlilik);
        f.append('belgeNo', no);
        f.append('dosya', dosya);
        await api.belgeTakipYukle(personelId, f);
        await onBitti();
      });
    } finally { setBekle(false) }
  };

  return (
    <Modal baslik={`${yenile ? '⬆ Yenile' : '⬆ Yükle'} — ${ad}`} dar buyutmeYok onKapat={onKapat}
           alt={<>
             <button className="birincil" disabled={bekle || !dosya} onClick={() => void kaydet()}>Kaydet</button>
             <button onClick={onKapat}>Vazgeç</button>
           </>}>
      <div className="pb-form" style={{ padding: 4 }}>
        <label>Dosya</label>
        <input type="file" accept="application/pdf,image/*" onChange={e => setDosya(e.target.files?.[0] ?? null)} />
        <label>Belge tarihi</label>
        <input type="date" value={tarih} onChange={e => setTarih(e.target.value)} />
        <label>Geçerlilik</label>
        <input type="date" value={gecerlilik} onChange={e => setGecerlilik(e.target.value)} title="Boş bırakılırsa belge türünün süresinden" />
        <label>Belge no</label>
        <input value={no} maxLength={60} onChange={e => setNo(e.target.value)} />
      </div>
      <div className="sonuk" style={{ marginTop: 8 }}>Geçerlilik boşsa belge tarihi + türün geçerlilik süresi.</div>
    </Modal>
  );
}

/** "🕘 Hareketler": belge kaydı, dosya ve hatırlatma geçmişi (salt okunur). */
function Hareketler({ personelId }: { personelId: number }) {
  const [satirlar, setSatirlar] = useState<Awaited<ReturnType<typeof api.belgeTakipHareketler>> | null>(null);
  useEffect(() => {
    let iptal = false;
    api.belgeTakipHareketler(personelId).then(x => { if (!iptal) setSatirlar(x) }).catch(() => { if (!iptal) setSatirlar([]) });
    return () => { iptal = true };
  }, [personelId]);
  if (!satirlar) return <div style={{ margin: '10px 14px', color: 'var(--soluk)' }}>Yükleniyor…</div>;
  if (satirlar.length === 0) return <div style={{ margin: '10px 14px', color: 'var(--soluk)' }}>Henüz hareket yok.</div>;
  return (
    <div style={{ margin: '10px 14px' }}>
      <table className="grid">
        <thead><tr><th>Zaman</th><th>İşlem</th><th>Belge</th><th>Ayrıntı</th><th>Kullanıcı</th></tr></thead>
        <tbody>
          {satirlar.map((x, i) => (
            <tr key={i}>
              <td style={{ whiteSpace: 'nowrap' }}>{tarihSaat(x.zaman)}</td><td>{x.islem}</td><td>{x.belge}</td>
              <td>{x.ayrinti}</td><td>{x.kullanici}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

const kacis = (s: unknown) => String(s ?? '').replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]!));

/** Mockup "Özlük dosyası kontrol listesi": belge listesi imza alanıyla yazdırılır (yeni pencere). */
function kontrolListesi(ad: string, durumlar: Satir[]) {
  const w = window.open('', '_blank');
  if (!w) { mesaj('Açılır pencere engellendi - tarayıcıda bu siteye izin verin.'); return }
  let grup = '';
  const satirlar = durumlar.map(d => {
    const g = String(d.grupAdi ?? '');
    const bas = g !== grup ? `<tr><td colspan="6" class="g">${kacis(g)}</td></tr>` : '';
    grup = g;
    return `${bas}<tr><td>${n(d.durum) === 4 ? '☑' : '☐'} ${kacis(d.belge)}</td><td>${n(d.zorunlu) === 1 ? '✓' : ''}</td>`
      + `<td>${kacis(d.durumAdi)}</td><td>${d.belgeTarihi ? tarihYaz(String(d.belgeTarihi)) : ''}</td>`
      + `<td>${d.gecerlilikTarihi ? tarihYaz(String(d.gecerlilikTarihi)) : ''}</td><td></td></tr>`;
  }).join('');
  w.document.write(`<!doctype html><html><head><meta charset="utf-8"><title>Özlük dosyası kontrol listesi</title>
<style>body{font:12px Arial,sans-serif;margin:24px}h1{font-size:16px;margin:0 0 4px}table{width:100%;border-collapse:collapse;margin-top:12px}
th,td{border:1px solid #999;padding:4px 6px;text-align:left}th{background:#eee}td.g{background:#f3f6fa;font-weight:bold}
.imza{margin-top:40px;display:flex;justify-content:space-between}</style></head><body>
<h1>Özlük dosyası kontrol listesi</h1><div>${kacis(ad)} · ${new Date().toLocaleDateString('tr-TR')}</div>
<table><thead><tr><th>Belge</th><th>Zorunlu</th><th>Durum</th><th>Belge tarihi</th><th>Geçerlilik</th><th>Not</th></tr></thead>
<tbody>${satirlar}</tbody></table>
<div class="imza"><span>Kontrol eden (İK): ................................</span><span>İmza: ................</span></div>
${YAZDIR_ETIKETI}</body></html>`);
  w.document.close();
}
