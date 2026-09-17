import { useCallback, useEffect, useState } from 'react';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { IsgCalisanKarti as Kart } from '../../api/uclar/isg';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay, secimSor } from '../../bilesenler/mesaj';
import { MARUZIYET } from './IsgPano';

/**
 * ÇALIŞAN KARTI `/isg-calisan/:id` (İSG 741) — mockup Ekranlar/ISG/isg_calisan_karti.html.
 * Hasta kartının işyeri uzantısı: kimlik & işyeri, maruziyet → tetkik paketi,
 * muayene geçmişi (Ek-2 formuna gider), aşı, tıbbi özet, olaylar. Butonlar:
 * Ek-2 muayene aç (SMS ya da iç ekran), formu gönder, olay bildir, aşı,
 * genel hasta kartı. Modal; kapat geldiği yere. Düzenleme gizli generic kart.
 */
const KANAAT: Record<number, string> = { 1: 'ok', 2: 'uyari', 3: 'hata' };
type Sekme = 'kimlik' | 'maruziyet' | 'muayene' | 'asi' | 'tibbi' | 'olay';

export function IsgCalisanKarti() {
  const { id: param } = useParams();
  const id = Number(param ?? 0);
  const git = useNavigate();
  const konum = useLocation();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const durumS = konum.state as { geri?: string } | null;
  const geri = durumS?.geri ?? sorgu.get('geri') ?? '/isg-calisan';
  const kapat = useCallback(() => git(geri), [git, geri]);
  useEffect(() => { const f = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() }; window.addEventListener('keydown', f); return () => window.removeEventListener('keydown', f) }, [kapat]);
  const [k, setK] = useState<Kart | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('kimlik');
  const yukle = useCallback(async () => { try { setK(await api.isgCalisanKart(id)); setHata(null) } catch (h) { setHata(hataMetni(h)) } }, [id]);
  useEffect(() => { if (id) void yukle() }, [id, yukle]);

  const buradan = `/isg-calisan/${id}?geri=${encodeURIComponent(geri)}`;
  const muayeneAc = async () => {
    const tur = await secimSor('Muayene türü', [{ kod: '2', ad: 'Periyodik' }, { kod: '1', ad: 'İşe giriş' }, { kod: '3', ad: 'İşe dönüş' }, { kod: '4', ad: 'Erken kontrol' }, { kod: '5', ad: 'İş değişikliği' }]);
    if (!tur) return;
    const kanal = await secimSor('Çalışan bölümü nasıl doldurulacak?', [{ kod: '3', ad: `📱 SMS ile telefonuna gönder (${k?.calisan.cep_tel || 'telefon yok'})` }, { kod: '2', ad: '🖥 Tablette / kioskta (şimdi)' }, { kod: '1', ad: '🩺 İç ekranda birlikte doldur' }]);
    if (!kanal) return;
    await guvenli(async () => {
      const y = await api.isgMuayeneAc(id, { tur: Number(tur), kanal: Number(kanal) });
      if (y.mevcut) mesaj('Bu çalışanın açık muayenesi zaten var; ona gidiliyor.');
      if (Number(kanal) === 2 && y.baglanti) window.open(y.baglanti, '_blank', 'noopener');
      if (y.formIstekId) git(`/form-doldur/${y.formIstekId}?geri=${encodeURIComponent(buradan)}`); else await yukle();
    });
  };
  const olayBildir = () => git(`/isg-olay/yeni?geri=${encodeURIComponent(buradan)}&firmaId=${k?.calisan.firma_id}&calisanId=${id}`);

  if (yeniMi(param)) return <Perde baslik="👷 Çalışan" kapat={kapat}><div className="fm-kagov">Yeni çalışan <b>Çalışanlar › ＋ Çalışan</b> ile açılır (hasta kaydı + firma).</div></Perde>;
  if (hata) return <Perde baslik="👷 Çalışan" kapat={kapat}><div className="hata-kutusu">{hata}</div></Perde>;
  if (!k) return <Perde baslik="👷 Çalışan" kapat={kapat}><span className="sonuk">Yükleniyor…</span></Perde>;
  const c = k.calisan;
  const acik = k.muayeneler.find(m => m.durum === 1);
  const maruz = [...new Set([...(c.bolum_maruziyet ?? []), ...(c.maruziyet ?? [])])];
  const yas = c.dogum_tarihi ? Math.floor((Date.now() - new Date(c.dogum_tarihi).getTime()) / 31557600000) : null;
  const tarih = (d?: string | null) => d ? new Date(d).toLocaleDateString('tr-TR') : '—';
  const baslik = <>👷 Çalışan Kartı — {c.calisan_adi}<span className="kapt">{c.firma_adi} › {c.bolum_adi || '—'} · {c.gorev} · <span className={`isg-teh isg-teh-${c.tehlike === 1 ? 'az' : c.tehlike === 2 ? 't' : 'ct'}`}>{c.tehlike_adi}</span> · Esc</span></>;
  return (
    <Perde baslik={baslik} kapat={kapat}>
      <div className="fm-doldur-arac">
        {yetki('isg.muayene', 'ekle') && <button className="d bir" onClick={() => void muayeneAc()}>🩺 Ek-2 muayene {acik ? 'devam' : 'aç'}</button>}
        {acik?.form_istek_id && <button className="d" onClick={() => git(`/form-doldur/${acik.form_istek_id}?geri=${encodeURIComponent(buradan)}`)}>📄 Açık Ek-2 formu</button>}
        {yetki('isg.olay', 'ekle') && <button className="d" onClick={olayBildir}>🚨 Olay bildir</button>}
        <button className="d" onClick={() => git(`/isg-calisan-kart/${id}?geri=${encodeURIComponent(buradan)}`)}>✎ Düzenle / aşı</button>
        <button className="d" onClick={() => git(`/hasta-formlar/${c.hasta_id}?geri=${encodeURIComponent(buradan)}`)}>📋 Tüm formlar</button>
        <span className="sp" />
        <button className="d" onClick={() => git(`/hasta/${c.hasta_id}?geri=${encodeURIComponent(buradan)}`)}>🪪 Genel hasta kartı</button>
      </div>
      <div className="fm-kpis">
        <div className="fm-kpi"><div className="b">Son muayene</div><div className="d">{tarih(c.son_muayene)} <small>{c.son_muayene_tur ? ['', 'işe giriş', 'periyodik', 'işe dönüş', 'erken', 'iş değişikliği'][c.son_muayene_tur] : ''}</small></div></div>
        <div className="fm-kpi"><div className="b">Kanaat</div><div className={`d${c.son_kanaat === 2 ? ' sari' : c.son_kanaat === 3 ? ' kir' : c.son_kanaat === 1 ? ' ok' : ''}`}>{c.son_kanaat_adi ?? '—'}</div></div>
        <div className="fm-kpi"><div className="b">Sonraki periyodik</div><div className={`d${c.kalan_gun < 0 ? ' kir' : c.kalan_gun <= 30 ? ' sari' : ''}`}>{tarih(c.vade)} <small>{c.kalan_gun < 0 ? `${-c.kalan_gun} gün geçti` : `${c.kalan_gun} gün`}</small></div></div>
        <div className="fm-kpi"><div className="b">Periyot</div><div className="d">{c.periyot_hesap} ay <small>{c.periyot_ay ? 'hekim kısaltması' : c.calisma >= 3 ? 'gece' : 'tehlike sınıfı'}</small></div></div>
        <div className="fm-kpi"><div className="b">Aşı</div><div className={`d${k.asilar.some(a => a.vadesi_gecti) ? ' sari' : ''}`}>{k.asilar.length ? k.asilar.slice(0, 2).map(a => `${a.asi_adi.split(' ')[0]} ${a.doz}`).join(' · ') : '—'}</div></div>
        <div className="fm-kpi"><div className="b">Olay</div><div className={`d${k.olaylar.some(o => o.durum === 1) ? ' kir' : ''}`}>{k.olaylar.length ? `${k.olaylar.length} (${k.olaylar.filter(o => o.tur === 1).length} kaza)` : '—'}</div></div>
      </div>
      <div className="ka-sekmeler" style={{ padding: '0 0 8px' }}>
        {([['kimlik', 'Kimlik & İşyeri'], ['maruziyet', 'Maruziyet & Tetkik Paketi'], ['muayene', `Muayene Geçmişi (${k.muayeneler.length})`], ['asi', `Aşı (${k.asilar.length})`], ['tibbi', 'Tıbbi Özet'], ['olay', `Olaylar (${k.olaylar.length})`]] as [Sekme, string][]).map(([s, ad]) => (
          <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{ad}</div>
        ))}
      </div>
      {sekme === 'kimlik' && (
        <>
          <div className="isg-frm">
            <Al lb="Ad Soyad" v={<b>{c.calisan_adi}</b>} /><Al lb="TCKN" v={c.tckn} /><Al lb="Doğum" v={`${tarih(c.dogum_tarihi)}${yas != null ? ` (${yas})` : ''}`} /><Al lb="Cep" v={c.cep_tel} />
            <Al lb="Firma" v={c.firma_adi} /><Al lb="Bölüm" v={c.bolum_adi} /><Al lb="Görev" v={c.gorev} /><Al lb="İşe giriş" v={tarih(c.ise_giris)} />
            <Al lb="Çalışma şekli" v={c.calisma_adi} /><Al lb="Durum" v={<span className={`rozet ${c.durum === 1 ? 'ok' : 'hata'}`}>{c.durum_adi}{c.isten_ayrilis ? ` · ${tarih(c.isten_ayrilis)}` : ''}</span>} /><Al lb="Eğitim" v={c.egitim} /><Al lb="KVKK açık rıza" v={c.riza_tarihi ? <span className="rozet ok">Alındı {tarih(c.riza_tarihi)}</span> : <span className="rozet uyari">Yok</span>} />
            <Al lb="Meslek öyküsü" v={c.meslek_oykusu} genis /><Al lb="Kullanılan KKD" v={c.kkd} genis />
          </div>
          <div className="isg-zaman"><span className="sonuk">Periyodik süre:</span><div className="cz"><i className={c.kalan_gun < 0 ? 'k' : ''} style={{ width: `${Math.max(2, Math.min(100, 100 - (c.kalan_gun / (c.periyot_hesap * 30)) * 100))}%` }} /></div><span>{tarih(c.son_muayene)} → {tarih(c.vade)} · {c.periyot_hesap} ay</span></div>
        </>
      )}
      {sekme === 'maruziyet' && (
        <>
          <div style={{ padding: '4px 0 8px' }}><b style={{ fontSize: 12 }}>Maruziyetler</b> <span className="sonuk">(bölüm varsayılanı + kişiye özel)</span><br />
            {maruz.length ? maruz.map(m => <span key={m} className={`isg-mrz${(c.maruziyet ?? []).includes(m) ? ' on' : ''}`}>{MARUZIYET[m] ?? m}</span>) : <span className="sonuk">Tanımsız — firma kartında bölüme ya da çalışan kartına yazın.</span>}
          </div>
          <div className="isg-frm"><Al lb="Tetkik paketi (bölüm)" v={c.tetkik_paketi} genis /><Al lb="Periyot" v={`${c.periyot_hesap} ay${c.periyot_ay ? ' (hekim kısaltması)' : ''}`} /><Al lb="Tetkik öneri" v={tetkikOneri(maruz)} genis /></div>
          <div className="sonuk" style={{ fontSize: 11 }}>Paket = maruziyet kodlarının birleşimi; "Ek-2 muayene aç" formunun Tetkikler bölümünde sonuçlar işaretlenir. Lab / radyoloji istemi genel hasta kartından.</div>
        </>
      )}
      {sekme === 'muayene' && (
        <table className="fm-tablo">
          <thead><tr><th>Tarih</th><th>Tür</th><th>Hekim</th><th>Ek-2 formu</th><th>Kanaat</th><th>Koşul</th><th>Sonraki</th><th>Durum</th><th></th></tr></thead>
          <tbody>
            {k.muayeneler.map(m => (
              <tr key={m.id}>
                <td>{tarih(m.tarih)}</td><td>{m.tur_adi}</td><td>{m.hekim_adi}</td>
                <td>{m.form_istek_id ? <span className={`rozet ${m.form_durum === 4 ? 'ok' : m.form_durum === 3 ? 'uyari' : 'mor'}`}>{m.form_durum_adi ?? '—'}</span> : <span className="sonuk">elle</span>}</td>
                <td>{m.kanaat ? <span className={`rozet ${KANAAT[m.kanaat]}`}>{m.kanaat_adi}</span> : '—'}</td>
                <td className="fm-not">{m.kosul}</td><td>{tarih(m.sonraki_tarih)}</td>
                <td><span className={`rozet ${m.durum === 2 ? 'ok' : m.durum === 3 ? 'hata' : 'mor'}`}>{m.durum_adi}</span></td>
                <td className="fm-sag">
                  {m.form_istek_id && <button className="d mini" onClick={() => git(`/form-doldur/${m.form_istek_id}?geri=${encodeURIComponent(buradan)}`)}>Ek-2</button>}
                  {m.durum === 1 && m.form_durum === 4 && yetki('isg.muayene', 'degistir') && <button className="d mini" onClick={() => void guvenli(async () => { await api.isgMuayeneIsle(m.id); await yukle() })}>Kanaati işle</button>}
                  {m.durum === 1 && yetki('isg.muayene', 'degistir') && <button className="d mini" onClick={() => void (async () => { if (await onay('Muayene iptal edilsin mi?', true)) await guvenli(async () => { await api.isgMuayeneIptal(m.id); await yukle() }) })()}>İptal</button>}
                </td>
              </tr>
            ))}
            {!k.muayeneler.length && <tr><td colSpan={9} className="sonuk">Muayene yok.</td></tr>}
          </tbody>
        </table>
      )}
      {sekme === 'asi' && (
        <>
          <table className="fm-tablo">
            <thead><tr><th>Aşı</th><th>Doz</th><th>Tarih</th><th>Sonraki</th><th>Durum</th><th>Not</th></tr></thead>
            <tbody>{k.asilar.map(a => <tr key={a.id}><td>{a.asi_adi}</td><td>{a.doz}</td><td>{tarih(a.tarih)}</td><td>{tarih(a.sonraki)}</td><td>{a.vadesi_gecti ? <span className="rozet uyari">Doz vadesi geçti</span> : a.sonraki ? <span className="rozet ok">Planlı</span> : <span className="rozet ok">Tam</span>}</td><td className="fm-not">{a.aciklama}</td></tr>)}
              {!k.asilar.length && <tr><td colSpan={6} className="sonuk">Aşı kaydı yok.</td></tr>}</tbody>
          </table>
          <div className="fm-doldur-arac"><button className="d" onClick={() => git(`/isg-calisan-kart/${id}?geri=${encodeURIComponent(buradan)}`)}>＋ Doz kaydet (kart › Aşılar)</button></div>
        </>
      )}
      {sekme === 'tibbi' && (
        <div className="isg-frm"><Al lb="Alerji" v={k.tibbi.alerji} /><Al lb="Kronik tanı" v={k.tibbi.kronik} /><Al lb="İlaç" v={k.tibbi.ilac} />
          <div className="sonuk" style={{ gridColumn: 'span 4', fontSize: 11 }}>Genel hasta kartındaki Tıbbi Özet (hasta_alerji · hasta_kronik_tani · hasta_ilac) salt okunur; düzenleme genel hasta kartından.</div></div>
      )}
      {sekme === 'olay' && (
        <table className="fm-tablo">
          <thead><tr><th>Tarih</th><th>Tür</th><th>Yer</th><th>Açıklama</th><th>Yaralanma</th><th>SGK bildirim</th><th>Durum</th><th></th></tr></thead>
          <tbody>{k.olaylar.map(o => <tr key={o.id}><td>{new Date(o.tarih).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' })}</td><td><span className={`rozet ${o.tur === 1 ? 'hata' : o.tur === 2 ? 'uyari' : 'mor'}`}>{o.tur_adi}</span></td><td>{o.yer}</td><td className="fm-not">{o.aciklama}</td><td>{o.yaralanma}{o.gun_kaybi ? ` · ${o.gun_kaybi} gün` : ''}</td><td>{o.sgk_bildirim ? `✓ ${tarih(o.sgk_bildirim)}` : o.sgk_gecikti ? <span className="rozet hata">Gecikti</span> : o.sgk_kalan_gun != null ? <span className="rozet uyari">{o.sgk_kalan_gun} gün</span> : '—'}</td><td>{o.durum_adi}</td><td className="fm-sag"><button className="d mini" onClick={() => git(`/isg-olay/${o.id}?geri=${encodeURIComponent(buradan)}`)}>Aç</button></td></tr>)}
            {!k.olaylar.length && <tr><td colSpan={8} className="sonuk">Olay yok.</td></tr>}</tbody>
        </table>
      )}
    </Perde>
  );
}

function yeniMi(p?: string) { return p === 'yeni' }
function tetkikOneri(m: number[]): string {
  const t: string[] = [];
  if (m.includes(1)) t.push('Odyometri'); if (m.includes(2) || m.includes(3) || m.includes(13)) t.push('SFT', 'PA akciğer grafisi');
  if (m.includes(3) || m.includes(14)) t.push('Hemogram', 'KCFT', 'İdrar (ağır metal)'); if (m.includes(4)) t.push('Göz muayenesi');
  if (m.includes(5)) t.push('EKG', 'Nörolojik muayene', 'Denge'); if (m.includes(6)) t.push('Hemogram', 'Glukoz', 'Lipid');
  if (m.includes(7)) t.push('Hepatit B serolojisi'); if (m.includes(9)) t.push('İdrar'); if (m.includes(10)) t.push('El-kol nörolojik'); if (m.includes(11)) t.push('Hemogram (dozimetre)');
  if (m.includes(12)) t.push('Portör (gaita, boğaz)');
  return [...new Set(t)].join(' · ');
}
function Al({ lb, v, genis }: { lb: string; v: React.ReactNode; genis?: boolean }) {
  return <div className={`isg-al${genis ? ' isg-genis' : ''}`}><div className="fm-etiket">{lb}</div><div className="isg-v">{v || '—'}</div></div>;
}
function Perde({ baslik, kapat, children }: { baslik: React.ReactNode; kapat: () => void; children: React.ReactNode }) {
  return (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">{baslik}<button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button></div>
        <div className="kagov fm-kagov">{children}</div>
      </div>
    </div>
  );
}
