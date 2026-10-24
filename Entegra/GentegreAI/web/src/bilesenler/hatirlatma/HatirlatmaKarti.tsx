import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import type { HatirlatmaDetay, HatirlatmaYazma } from '../../api/uclar/hatirlatma';
import { Modal } from '../Modal';
import { TarafArama } from '../TarafArama';
import { guvenli, mesaj, onay } from '../mesaj';
import { tarihSaat, yerelAnMetni } from '../bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { KAYIT_TURLERI, erteleSecenekleri, hatirlatmaDegisti, hizliZamanlar, kayitIkonu, kisaZaman,
         type HatirlatmaAcIstegi } from './hatirlatmaDeposu';
import { HATIRLATMA_STIL } from './hatirlatmaStil';

/**
 * HATIRLATMA KARTI (mockup kisisel_hatirlatici.html (3)): her ekrandan açılan pencere.
 * Şerit Başlık · Tarih · Saat · Öncelik; sekmeler Genel · Tekrar & uyarı · Bağlı kayıt · Paylaşım · Geçmiş.
 * Kural sunucuda (HatirlatmaUclari): görünürlük, düzenleme izni, tekrarın sonraki zamanı.
 */

type Sekme = 'genel' | 'tekrar' | 'bag' | 'paylas' | 'gecmis';
const SEKMELER: [Sekme, string][] = [
  ['genel', '📝 Genel'], ['tekrar', '🔁 Tekrar & uyarı'], ['bag', '🔗 Bağlı kayıt'], ['paylas', '👥 Paylaşım'], ['gecmis', '🕘 Geçmiş'],
];
const TEKRARLAR: [number, string][] = [[0, 'Yok'], [1, 'Her gün'], [2, 'Haftalık'], [3, 'Aylık'], [4, 'Yıllık'], [5, 'İş günleri']];
const GUNLER = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];
const UYARILAR: [number, string][] = [[0, 'Zamanında'], [5, '5 dk önce'], [15, '15 dk önce'], [60, '1 saat önce'], [1440, '1 gün önce']];
const RENKLER = ['', 'var(--hatazem)', 'var(--uyarizem)', 'var(--okzem)', '#eef4fc'];
const ONCELIK: [number, string][] = [[1, 'Düşük'], [2, 'Normal'], [3, 'Yüksek']];

const bos = (i: HatirlatmaAcIstegi): HatirlatmaYazma => ({
  baslik: i.baslik ?? '', notu: '',
  zaman: i.zaman ?? yerelAnMetni(hizliZamanlar().find(z => z.ad === '1 saat sonra')!.zaman),
  uyarDk: 15, oncelik: 2, renk: 0, etiket: '', tekrar: 0, tekrarAralik: 1, tekrarGunler: 0, tekrarBitis: null,
  kanalUygulama: true, kanalSms: false, kanalEposta: false,
  kaynak: i.kaynak ?? '', kaynakId: i.kaynakId ?? null, kaynakAd: i.kaynakAd ?? '',
  paylasim: 0, paylasimDepartmanId: null, herkesKapatir: true, paylasilanDuzenler: false, paylasilanlar: [],
});

export function HatirlatmaKarti({ istek, onKapat }: { istek: HatirlatmaAcIstegi; onKapat(): void }) {
  const git = useNavigate();
  const { kullanici } = useOturum();
  const [id, setId] = useState<number | null>(istek.id ?? null);
  const [d, setD] = useState<HatirlatmaYazma>(() => bos(istek));
  const [detay, setDetay] = useState<HatirlatmaDetay | null>(null);
  const [kisiAdlari, setKisiAdlari] = useState<Record<number, string>>({});
  const [sekme, setSekme] = useState<Sekme>('genel');
  const [hata, setHata] = useState('');
  const [erteleAcik, setErteleAcik] = useState(false);
  const [arama, setArama] = useState<string | null>(null);
  const [kisiAra, setKisiAra] = useState('');
  const [kisiSonuc, setKisiSonuc] = useState<{ id: number; ad: string }[]>([]);
  const [birimler, setBirimler] = useState<{ id: number; ad: string }[]>([]);
  const [ozelUyari, setOzelUyari] = useState(false);
  const [tazele, setTazele] = useState(0);

  useEffect(() => {
    if (!id) return;
    let iptal = false;
    api.hatirlatma(id).then(y => {
      if (iptal) return;
      const s = y.satir;
      setDetay(y);
      setD({
        baslik: s.baslik, notu: s.notu, zaman: s.zamanYerel, uyarDk: s.uyarDk, oncelik: s.oncelik, renk: s.renk,
        etiket: s.etiket, tekrar: s.tekrar, tekrarAralik: s.tekrarAralik, tekrarGunler: s.tekrarGunler,
        tekrarBitis: s.tekrarBitis ?? null, kanalUygulama: s.kanalUygulama, kanalSms: s.kanalSms, kanalEposta: s.kanalEposta,
        kaynak: s.kaynak, kaynakId: s.kaynakId ?? null, kaynakAd: s.kaynakAd,
        paylasim: s.paylasim, paylasimDepartmanId: y.paylasimDepartmanId ?? null, herkesKapatir: y.herkesKapatir,
        paylasilanDuzenler: y.paylasilanDuzenler, paylasilanlar: y.paylasilanlar.map(p => p.id),
      });
      setKisiAdlari(Object.fromEntries(y.paylasilanlar.map(p => [p.id, p.ad])));
      setOzelUyari(!UYARILAR.some(([v]) => v === s.uyarDk));
    }, h => setHata(String((h as Error).message ?? h)));
    return () => { iptal = true };
  }, [id, tazele]);

  useEffect(() => {
    if (sekme !== 'paylas' || d.paylasim !== 1) return;
    const t = setTimeout(() => { api.hatirlatmaKisiler(kisiAra).then(setKisiSonuc, () => setKisiSonuc([])) }, 250);
    return () => clearTimeout(t);
  }, [kisiAra, sekme, d.paylasim]);
  useEffect(() => {
    if (sekme === 'paylas' && d.paylasim === 2 && birimler.length === 0) api.hatirlatmaBirimler().then(setBirimler, () => {});
  }, [sekme, d.paylasim, birimler.length]);

  const benim = !detay || detay.satir.benim;
  const duzenlenir = benim || !!detay?.paylasilanDuzenler;
  const acik = !detay || detay.satir.acik;
  const yaz = <K extends keyof HatirlatmaYazma>(k: K, v: HatirlatmaYazma[K]) => setD(o => ({ ...o, [k]: v }));
  const tarih = d.zaman.slice(0, 10), saat = d.zaman.slice(11, 16);
  const zamanDate = useMemo(() => new Date(d.zaman), [d.zaman]);

  const kaydet = async (kapat = true) => {
    setHata('');
    if (!d.baslik.trim()) { setHata('Başlık gerekli.'); setSekme('genel'); return false }
    const ok = await guvenli(async () => {
      if (id) await api.hatirlatmaGuncelle(id, d);
      else { const y = await api.hatirlatmaEkle(d); setId(y.id) }
      hatirlatmaDegisti();
    });
    if (ok && kapat) onKapat();
    return ok;
  };
  const eylem = (f: () => Promise<unknown>, kapat = true) => void guvenli(async () => {
    await f(); hatirlatmaDegisti(); if (kapat) onKapat(); else setTazele(t => t + 1);
  });

  const tamamla = () => eylem(async () => {
    if (!id) return;
    const y = await api.hatirlatmaTamamla(id);
    if (!y.kapandi && y.sonuc) mesaj(`Tamamlandı. Tekrarlayan hatırlatma: ${y.sonuc}`);
  });
  const sil = async () => {
    if (!id || !await onay(`"${d.baslik}" silinsin mi?`, true)) return;
    eylem(() => api.hatirlatmaSil(id));
  };
  const kopyala = () => eylem(async () => { if (id) { const y = await api.hatirlatmaKopyala(id); setId(y.id) } }, false);

  const bagli = d.kaynak && d.kaynakId;
  const turAdi = (k: string) => KAYIT_TURLERI[k.split('/')[0]]?.ad ?? k;

  const govde = (
    <div className="hk-govde">
      <style>{HATIRLATMA_STIL}</style>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {sekme === 'genel' && (
        <div className="hk-form">
          <div className="hk-alan hk-g4"><label>Hızlı zaman</label>
            <div className="hk-hizli">
              {hizliZamanlar().map(z => {
                const m = yerelAnMetni(z.zaman);
                return <button type="button" key={z.ad} disabled={!duzenlenir} className={m === d.zaman ? 'on' : ''}
                               onClick={() => yaz('zaman', m)}>{z.ad}<small>{kisaZaman(z.zaman)}</small></button>;
              })}
            </div></div>
          <div className="hk-alan hk-g4"><label>Not</label>
            <textarea rows={4} value={d.notu} disabled={!duzenlenir} maxLength={2000}
                      onChange={e => yaz('notu', e.target.value)} placeholder="Ayrıntı, telefon, yapılacak…" /></div>
          <div className="hk-alan hk-g2"><label>Etiket</label>
            <input value={d.etiket} maxLength={60} disabled={!duzenlenir} placeholder="🏷 ör. Hasta takibi"
                   onChange={e => yaz('etiket', e.target.value)} /></div>
          <div className="hk-alan hk-g2"><label>Renk</label>
            <div className="hk-sec">
              {RENKLER.map((r, i) => (
                <button type="button" key={i} className={d.renk === i ? 'on' : ''} disabled={!duzenlenir}
                        style={{ background: r || 'var(--yuz)', minWidth: 34 }} onClick={() => yaz('renk', i)}>{i === 0 ? '—' : '●'}</button>
              ))}
            </div></div>
        </div>
      )}

      {sekme === 'tekrar' && (
        <div className="hk-form">
          <div className="hk-alan hk-g4"><label>Tekrar</label>
            <div className="hk-sec">{TEKRARLAR.map(([v, a]) => (
              <button type="button" key={v} disabled={!duzenlenir} className={d.tekrar === v ? 'on' : ''}
                      onClick={() => setD(o => ({ ...o, tekrar: v,
                        tekrarGunler: v === 2 && o.tekrarGunler === 0 ? 1 << ((zamanDate.getDay() + 6) % 7) : o.tekrarGunler }))}>{a}</button>
            ))}</div></div>
          {d.tekrar === 2 && (
            <div className="hk-alan hk-g2"><label>Günler</label>
              <div className="hk-gunler">{GUNLER.map((g, i) => (
                <button type="button" key={g} disabled={!duzenlenir} className={(d.tekrarGunler & (1 << i)) ? 'on' : ''}
                        onClick={() => yaz('tekrarGunler', d.tekrarGunler ^ (1 << i))}>{g}</button>
              ))}</div></div>
          )}
          {d.tekrar === 3 && (
            <div className="hk-alan hk-g2"><label>Ayın</label><div className="hk-bilgi-satir">{zamanDate.getDate()}. günü</div></div>
          )}
          {d.tekrar > 0 && d.tekrar !== 5 && (
            <div className="hk-alan"><label>Her</label>
              <input type="number" min={1} max={99} value={d.tekrarAralik} disabled={!duzenlenir}
                     onChange={e => yaz('tekrarAralik', Math.max(1, Number(e.target.value) || 1))} /></div>
          )}
          {d.tekrar > 0 && (
            <div className="hk-alan"><label>Bitiş (boş = hiç bitmesin)</label>
              <input type="date" value={d.tekrarBitis ?? ''} disabled={!duzenlenir}
                     onChange={e => yaz('tekrarBitis', e.target.value || null)} /></div>
          )}
          <div className="hk-alan hk-g4"><label>Uyar</label>
            <div className="hk-sec">
              {UYARILAR.map(([v, a]) => (
                <button type="button" key={v} disabled={!duzenlenir} className={!ozelUyari && d.uyarDk === v ? 'on' : ''}
                        onClick={() => { setOzelUyari(false); yaz('uyarDk', v) }}>{a}</button>
              ))}
              <button type="button" disabled={!duzenlenir} className={ozelUyari ? 'on' : ''} onClick={() => setOzelUyari(true)}>Özel…</button>
              {ozelUyari && <span className="hk-ozel"><input type="number" min={0} max={43200} value={d.uyarDk} disabled={!duzenlenir}
                                        onChange={e => yaz('uyarDk', Math.max(0, Number(e.target.value) || 0))} /> dk önce</span>}
            </div></div>
          <div className="hk-alan hk-g4"><label>Kanal</label>
            <label className="hk-chk"><input type="checkbox" checked={d.kanalUygulama} disabled={!duzenlenir}
                                             onChange={e => yaz('kanalUygulama', e.target.checked)} />
              <span><b>Uygulama (zil + açılır uyarı)</b><small>Oturum açıksa ekranın sağ altında uyarı çıkar; değilse zilde bekler.</small></span></label>
            <label className="hk-chk"><input type="checkbox" checked={d.kanalSms} disabled={!duzenlenir}
                                             onChange={e => yaz('kanalSms', e.target.checked)} />
              <span><b>SMS</b><small>Kullanıcı hesabınızdaki (yoksa kartınızdaki) cep telefonuna; bildirim kuyruğundan gider, kontör düşer.</small></span></label>
            <label className="hk-chk"><input type="checkbox" checked={d.kanalEposta} disabled={!duzenlenir}
                                             onChange={e => yaz('kanalEposta', e.target.checked)} />
              <span><b>E-posta</b><small>Hesabınızdaki e-posta adresine.</small></span></label>
          </div>
          <div className="hk-alan hk-g4 hk-soluk">{d.tekrar > 0
            ? 'Tamamlayınca bir sonraki tarih kendiliğinden kurulur; geçmişte her tekrar ayrı satır.'
            : 'Tek seferlik: tamamlanınca listeden düşer (Tamamlanan çipinde kalır).'}</div>
        </div>
      )}

      {sekme === 'bag' && (
        <div className="hk-iki">
          <div className="hk-form">
            <div className="hk-alan hk-g4"><label>Bağlı kayıt</label>
              {bagli
                ? <div className="hk-bilgi-satir">{kayitIkonu(d.kaynak)} <b>{d.kaynakAd || `${turAdi(d.kaynak)} #${d.kaynakId}`}</b>
                    <span className="hk-soluk"> · {turAdi(d.kaynak)}</span></div>
                : <div className="hk-bilgi-satir hk-soluk">Bağlı kayıt yok.</div>}
            </div>
            <div className="hk-alan hk-g4"><label>Kayıt seç</label>
              <div className="hk-sec">
                {(['hasta', 'cari', 'personel', 'kisi'] as const).map(k => (
                  <button type="button" key={k} disabled={!duzenlenir} onClick={() => setArama(k)}>
                    {KAYIT_TURLERI[k].ic} {KAYIT_TURLERI[k].ad}…</button>
                ))}
                {bagli && <button type="button" disabled={!duzenlenir}
                                  onClick={() => setD(o => ({ ...o, kaynak: '', kaynakId: null, kaynakAd: '' }))}>✕ Bağlantıyı kaldır</button>}
              </div>
            </div>
            <div className="hk-alan hk-g4 hk-soluk">Diğer kayıtlar (belge, randevu, görev, stok…) kendi kartındaki
              {' '}<b>⏰ Hatırlat</b> düğmesiyle ya da listede sağ tıkla bağlanır. Kayıt kartında "⏰ N" rozeti yalnız size görünür.</div>
          </div>
          <div className="hk-yan">
            <div className="hk-kutu"><h6>Kayıt</h6><div className="hk-ic">
              {bagli ? <>
                <div className="hk-kv"><b>Tür</b><span>{turAdi(d.kaynak)}</span><b>Kayıt</b><span>{d.kaynakAd || `#${d.kaynakId}`}</span></div>
                <div style={{ marginTop: 8 }}><button type="button" className="d"
                  onClick={() => { onKapat(); git(`/${d.kaynak}/${d.kaynakId}`) }}>↗ Kaydı aç</button></div>
              </> : <span className="hk-soluk">—</span>}
            </div></div>
          </div>
          {arama && <TarafArama acik kaynaklar={[arama]} onKapat={() => setArama(null)}
                                onSec={s => { setD(o => ({ ...o, kaynak: s.kaynak || arama, kaynakId: s.id, kaynakAd: s.unvan })); setArama(null) }} />}
        </div>
      )}

      {sekme === 'paylas' && (
        <div className="hk-form">
          {!benim && <div className="hk-alan hk-g4 hk-bilgi">Bu hatırlatmayı {detay?.satir.sahip} sizinle paylaştı; paylaşımı yalnız sahibi değiştirir.</div>}
          <div className="hk-alan hk-g4"><label>Kime</label>
            <div className="hk-sec">{([[0, 'Yalnız ben'], [1, 'Ben + seçtiklerim'], [2, 'Birim']] as [number, string][]).map(([v, a]) => (
              <button type="button" key={v} disabled={!benim} className={d.paylasim === v ? 'on' : ''} onClick={() => yaz('paylasim', v)}>{a}</button>
            ))}</div></div>
          {d.paylasim === 1 && <>
            <div className="hk-alan hk-g4"><label>Paylaşılanlar</label>
              <div className="hk-cipler">
                {d.paylasilanlar.length === 0 && <span className="hk-soluk">Henüz kimse seçilmedi.</span>}
                {d.paylasilanlar.map(k => (
                  <span key={k} className="hk-cip">👤 {kisiAdlari[k] ?? `#${k}`}
                    {detay?.paylasilanlar.find(p => p.id === k)?.tamam && <small> ✓</small>}
                    {benim && <button type="button" onClick={() => yaz('paylasilanlar', d.paylasilanlar.filter(x => x !== k))}>✕</button>}</span>
                ))}
              </div></div>
            {benim && <div className="hk-alan hk-g4"><label>Kişi ekle</label>
              <input value={kisiAra} onChange={e => setKisiAra(e.target.value)} placeholder="🔍 Kullanıcı adı…" />
              <div className="hk-sonuc">{kisiSonuc.filter(k => !d.paylasilanlar.includes(k.id)).slice(0, 8).map(k => (
                <button type="button" key={k.id} onClick={() => { setKisiAdlari(o => ({ ...o, [k.id]: k.ad }));
                  yaz('paylasilanlar', [...d.paylasilanlar, k.id]) }}>＋ {k.ad}</button>
              ))}</div></div>}
          </>}
          {d.paylasim === 2 && (
            <div className="hk-alan hk-g2"><label>Birim</label>
              <select value={d.paylasimDepartmanId ?? ''} disabled={!benim}
                      onChange={e => yaz('paylasimDepartmanId', e.target.value ? Number(e.target.value) : null)}>
                <option value="">— seçin —</option>
                {detay?.paylasimDepartmanId && !birimler.some(b => b.id === detay.paylasimDepartmanId) &&
                  <option value={detay.paylasimDepartmanId}>{detay.paylasimDepartman}</option>}
                {birimler.map(b => <option key={b.id} value={b.id}>{b.ad}</option>)}
              </select></div>
          )}
          {d.paylasim > 0 && <div className="hk-alan hk-g4">
            <label className="hk-chk"><input type="checkbox" checked={d.herkesKapatir} disabled={!benim}
                                             onChange={e => yaz('herkesKapatir', e.target.checked)} />
              <span><b>Herhangi biri tamamlayınca herkes için kapansın</b><small>İşaretsizse her kişi kendi işaretini koyar.</small></span></label>
            <label className="hk-chk"><input type="checkbox" checked={d.paylasilanDuzenler} disabled={!benim}
                                             onChange={e => yaz('paylasilanDuzenler', e.target.checked)} />
              <span><b>Paylaşılanlar düzenleyebilsin</b><small>İşaretsizse yalnız görür, erteler, tamamlar.</small></span></label>
          </div>}
          <div className="hk-alan hk-g4 hk-bilgi">Başkasına <b>iş vermek</b> için Görev kullanılır (sorumlu, son tarih, onay).
            Hatırlatma yalnız haber verir; paylaşılan kişinin iş listesine girmez.</div>
        </div>
      )}

      {sekme === 'gecmis' && (
        <table className="hk-tablo">
          <thead><tr><th>Zaman</th><th>Olay</th><th>Ayrıntı</th><th>Kullanıcı</th></tr></thead>
          <tbody>
            {(detay?.hareketler ?? []).map((h, i) => (
              <tr key={i}><td>{tarihSaat(h.zaman)}</td>
                <td><span className={`hk-rz ${h.olayKod === 5 ? 'ok' : h.olayKod === 3 ? 'sari' : h.olayKod === 1 ? 'ok' : 'mavi'}`}>{h.olay}</span></td>
                <td>{h.ayrinti}</td><td>{h.kullanici || 'Sistem'}</td></tr>
            ))}
            {!detay?.hareketler.length && <tr><td colSpan={4} className="hk-soluk">Kayıt yok.</td></tr>}
          </tbody>
        </table>
      )}
    </div>
  );

  return (
    <Modal baslik={`⏰ ${id ? 'Hatırlatma' : 'Yeni hatırlatma'}${d.baslik ? ` — ${d.baslik}` : ''}`} enUst buyutmeYok onKapat={onKapat}
      alt={<>
        {duzenlenir && <button type="button" className="d bir" onClick={() => void kaydet()}>💾 Kaydet</button>}
        {id && acik && <button type="button" className="d yesil" onClick={tamamla}>✓ Tamamlandı</button>}
        {id && !acik && <button type="button" className="d" onClick={() => eylem(() => api.hatirlatmaAc(id), false)}>↺ Yeniden aç</button>}
        {id && <span className="hk-ertele-sar">
          <button type="button" className="d" onClick={() => setErteleAcik(a => !a)}>⏱ Ertele ▾</button>
          {erteleAcik && <div className="hk-menu">{erteleSecenekleri().map(e => (
            <button type="button" key={e.ad} onClick={() => eylem(() => api.hatirlatmaErtele(id, { dakika: e.dakika, zaman: e.zaman }))}>{e.ad}</button>
          ))}</div>}
        </span>}
        {id && <button type="button" className="d" onClick={kopyala}>⧉ Kopyala</button>}
        {id && benim && <button type="button" className="d" onClick={() => void sil()}>🗑 Sil</button>}
        <button type="button" className="d kapat-dugmesi" style={{ marginLeft: 'auto' }} onClick={onKapat}>✖ Kapat</button>
      </>}
      ustSerit={(
        <div className="hk-serit">
          <div className="hk-alan hk-bas"><label>Başlık *</label>
            <input autoFocus={!id} value={d.baslik} maxLength={200} disabled={!duzenlenir}
                   onChange={e => yaz('baslik', e.target.value)} onKeyDown={e => { if (e.key === 'Enter') void kaydet() }}
                   placeholder="ör. Ahmet Bey'i ara — tahlil sonucu" /></div>
          <div className="hk-alan"><label>Tarih *</label>
            <input type="date" value={tarih} disabled={!duzenlenir} onChange={e => yaz('zaman', `${e.target.value}T${saat || '09:00'}`)} /></div>
          <div className="hk-alan"><label>Saat *</label>
            <input type="time" value={saat} disabled={!duzenlenir} onChange={e => yaz('zaman', `${tarih}T${e.target.value}`)} /></div>
          <div className="hk-alan"><label>Öncelik</label>
            <div className="hk-sec">{ONCELIK.map(([v, a]) => (
              <button type="button" key={v} disabled={!duzenlenir} className={d.oncelik === v ? 'on' : ''} onClick={() => yaz('oncelik', v)}>{a}</button>
            ))}</div></div>
        </div>
      )}
      sekmeBar={(
        <div className="katab">
          {SEKMELER.map(([k, a]) => (
            <div key={k} className={`kat${sekme === k ? ' on' : ''}`} onClick={() => setSekme(k)} role="tab" aria-selected={sekme === k}>
              {a}
              {k === 'bag' && bagli && <span className="b">1</span>}
              {k === 'paylas' && d.paylasim === 1 && d.paylasilanlar.length > 0 && <span className="b">{d.paylasilanlar.length}</span>}
              {k === 'gecmis' && !!detay?.hareketler.length && <span className="b">{detay.hareketler.length}</span>}
            </div>
          ))}
        </div>
      )}
      altSerit={(
        <div className="hk-durum">
          <span>{id ? `Kayıt #${id}` : 'Yeni kayıt'}</span>
          <span>Sahibi: {detay?.satir.sahip ?? kullanici?.ad ?? ''}</span>
          {detay && !acik && <span className="hk-rz ok">✓ tamamlandı{detay.satir.tamamlanma ? ` ${tarihSaat(detay.satir.tamamlanma)}` : ''}</span>}
          <span style={{ marginLeft: 'auto' }}>Zaman şubenin saat diliminde</span>
        </div>
      )}>
      {govde}
    </Modal>
  );
}
