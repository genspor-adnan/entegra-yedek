import { useCallback, useEffect, useState } from 'react';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { FormAlan, FormAlanTipi, FormBolum, FormCevap, FormImzaTanimi, FormSablonSatiri, FormSahip, FormTanimi } from '../../api/uclar/form';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { FormCizici, SAHIP_ADI } from '../../bilesenler/form/FormCizici';

/**
 * ŞABLON EDİTÖRÜ `/form-editor/:id` (form motoru 740) — mockup
 * Ekranlar/Formlar/form_sablon_editoru.html. Döküm tasarımcısı deseni: solda
 * bölüm → alan ağacı (sahip rozeti), ortada canlı önizleme (test doldurma),
 * sağda seçili öğenin özellikleri. Kaydet = taslak (sürüm aynı), Yayınla =
 * sürüm + 1; dolduranlar kendi sürümüyle saklanır. Resmî kopya düzenlenmez.
 */
const TIPLER: [FormAlanTipi, string][] = [
  ['metin', 'Metin'], ['uzunmetin', 'Uzun metin'], ['sayi', 'Sayı'], ['tarih', 'Tarih'], ['secim', 'Seçim'], ['coklu', 'Çoklu seçim'],
  ['evethayir', 'Evet / Hayır'], ['onay', 'Onay kutusu'], ['olcek', 'Ölçek (0-10 / 1-5)'], ['skor', 'Skor tablosu'], ['metinblok', 'Metin bloğu (parametreli)'],
];
const SAHIPLER: FormSahip[] = ['hasta', 'calisan', 'hekim', 'hemsire', 'anestezi', 'cerrah'];
const IMZA_YONTEM: Record<number, string> = { 1: 'Kanvas', 2: 'OTP', 3: 'Kullanıcı', 4: 'Kağıt', 5: 'Beyan' };

export function FormSablonEditor() {
  const { id: param } = useParams();
  const id = Number(param ?? 0);
  const git = useNavigate();
  const konum = useLocation();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const geri = (konum.state as { geri?: string } | null)?.geri ?? sorgu.get('geri') ?? '/form-sablon';
  const kapat = useCallback(() => git(geri), [git, geri]);

  const [s, setS] = useState<FormSablonSatiri | null>(null);
  const [t, setT] = useState<FormTanimi>({ bolumler: [] });
  const [hata, setHata] = useState<string | null>(null);
  const [sec, setSec] = useState<{ b: number; a?: number } | null>(null);
  const [test, setTest] = useState<FormCevap>({});
  const [kirli, setKirli] = useState(false);
  const [sekme, setSekme] = useState<'ozellik' | 'sablon'>('ozellik');

  useEffect(() => {
    api.formSablon(id).then(y => { setS(y); setT(y.tanim?.bolumler ? y.tanim : { bolumler: [] }); setSec(y.tanim?.bolumler?.length ? { b: 0 } : null) }).catch(h => setHata(hataMetni(h)));
  }, [id]);
  const yazar = yetki('form.sablon') && s?.resmi === 0;
  const guncelle = (f: (x: FormTanimi) => FormTanimi) => { setT(x => f(structuredClone(x))); setKirli(true) };
  const bolum = sec ? t.bolumler[sec.b] : undefined;
  const alan = sec?.a !== undefined && bolum ? bolum.alanlar[sec.a] : undefined;

  const bolumEkle = async () => {
    const ad = await metinSor('Bölüm adı:'); if (!ad) return;
    guncelle(x => { x.bolumler.push({ kod: `b${x.bolumler.length + 1}_${Date.now() % 1000}`, ad, sahip: 'hasta', alanlar: [] }); return x });
    setSec({ b: t.bolumler.length });
  };
  const alanEkle = (tip: FormAlanTipi = 'metin') => {
    if (!sec) { mesaj('Önce bölüm seçin.'); return }
    guncelle(x => { const b = x.bolumler[sec.b]; b.alanlar.push({ kod: `a${Date.now() % 100000}`, tip, etiket: tip === 'metinblok' ? '' : 'Yeni alan', metin: tip === 'metinblok' ? 'Sayın {hasta.ad}, …' : undefined }); return x });
    setSec({ b: sec.b, a: bolum!.alanlar.length });
  };
  const sil = async () => {
    if (!sec) return;
    if (sec.a === undefined) { if (!await onay(`"${bolum?.ad}" bölümü ve alanları silinsin mi?`)) return; guncelle(x => { x.bolumler.splice(sec.b, 1); return x }); setSec(null); return }
    guncelle(x => { x.bolumler[sec.b].alanlar.splice(sec.a!, 1); return x }); setSec({ b: sec.b });
  };
  const tasi = (yon: -1 | 1) => {
    if (!sec) return;
    guncelle(x => {
      if (sec.a === undefined) { const i = sec.b, j = i + yon; if (j < 0 || j >= x.bolumler.length) return x; [x.bolumler[i], x.bolumler[j]] = [x.bolumler[j], x.bolumler[i]]; setSec({ b: j }) }
      else { const l = x.bolumler[sec.b].alanlar; const i = sec.a, j = i + yon; if (j < 0 || j >= l.length) return x; [l[i], l[j]] = [l[j], l[i]]; setSec({ b: sec.b, a: j }) }
      return x;
    });
  };
  const bolumDegis = (k: keyof FormBolum, v: unknown) => sec && guncelle(x => { (x.bolumler[sec.b] as unknown as Record<string, unknown>)[k] = v; return x });
  const alanDegis = (k: keyof FormAlan, v: unknown) => sec?.a !== undefined && guncelle(x => { const a = x.bolumler[sec.b].alanlar[sec.a!] as unknown as Record<string, unknown>; if (v === '' || v === undefined || v === false) delete a[k]; else a[k] = v; return x });
  const kaydet = async (yayinla: boolean) => {
    if (!s) return;
    if (t.bolumler.some(b => !b.alanlar.length)) { if (!await onay('Boş bölüm var. Yine de kaydedilsin mi?')) return }
    const not = yayinla ? await metinSor(`v${s.surum + 1} sürüm notu:`) : '';
    if (yayinla && not === null) return;
    await guvenli(async () => {
      const y = await api.formTanimKaydet(id, t, yayinla, not ?? '');
      setKirli(false); setS(x => x ? { ...x, surum: y.surum } : x);
      mesaj(yayinla ? `v${y.surum} yayınlandı.` : 'Taslak kaydedildi.');
    });
  };

  if (hata) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!s) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;
  return (
    <div className="fm-sayfa fm-editor-sayfa">
      <div className="sayfabas"><div className="basrow">
        <button className="d geri-dugme" onClick={kapat}>← Geri</button>
        <h1>✎ {s.ad}</h1><span className="yol"><code>{s.kod}</code> · v{s.surum}{kirli ? ' (değişti)' : ''} · {s.aile_adi} · {s.baglam_adi}{s.resmi === 1 ? ' · RESMÎ (kilitli)' : ''}</span>
        <div className="sag">
          {yazar && <><button className="d" onClick={() => void bolumEkle()}>＋ Bölüm</button><button className="d" onClick={() => alanEkle()}>＋ Alan</button><button className="d" onClick={() => alanEkle('metinblok')}>＋ Metin bloğu</button>
            <button className="d" onClick={() => tasi(-1)} disabled={!sec}>▲</button><button className="d" onClick={() => tasi(1)} disabled={!sec}>▼</button><button className="d" onClick={() => void sil()} disabled={!sec}>🗑</button></>}
          <button className="d" onClick={() => setTest({})}>🧪 Testi sıfırla</button>
          {yazar && <><button className="d" onClick={() => void kaydet(false)} disabled={!kirli}>💾 Kaydet</button><button className="d bir" onClick={() => void kaydet(true)}>🚀 Yayınla v{s.surum + 1}</button></>}
        </div>
      </div></div>
      <div className="fm-editor">
        <div className="fm-ed-agac">
          <div className="sonuk" style={{ fontSize: 10.5, padding: '0 8px 4px' }}>BÖLÜMLER · sahip</div>
          {t.bolumler.map((b, bi) => (
            <div key={b.kod}>
              <div className={`fm-ed-bolum${sec?.b === bi && sec.a === undefined ? ' sec' : ''}`} onClick={() => setSec({ b: bi })}>
                {b.asama ? <span className="rozet mor">{b.asama}</span> : '▸'} {b.ad} <span className={`rozet fm-sahip-${b.sahip}`}>{SAHIP_ADI[b.sahip]}</span>
              </div>
              {b.alanlar.map((a, ai) => (
                <div key={a.kod} className={`fm-ed-alan${sec?.b === bi && sec.a === ai ? ' sec' : ''}`} onClick={() => setSec({ b: bi, a: ai })}>
                  <i>{a.tip}</i>{a.tip === 'metinblok' ? (a.metin ?? '').slice(0, 30) : a.etiket}{a.zorunlu && <span className="fm-z">*</span>}
                </div>
              ))}
            </div>
          ))}
          {!t.bolumler.length && <div className="sonuk" style={{ padding: 8 }}>Bölüm yok — "＋ Bölüm".</div>}
        </div>
        <div className="fm-ed-tuval">
          <FormCizici bolumler={t.bolumler} cevap={test} onChange={(k, v) => setTest(c => ({ ...c, [k]: v }))} parametreler={{ 'hasta.ad': 'Örnek Hasta', 'kurum.ad': 'Kurum', tarih: new Date().toLocaleDateString('tr-TR') }} sahipRozeti tanim={t} />
          {t.imzalar?.length ? <div className="fm-bolum"><h3 className="fm-bolum-bas">İmzalar</h3><div className="sonuk">{t.imzalar.map(i => `${SAHIP_ADI[i.rol] ?? i.rol} (${i.yontem.map(y => IMZA_YONTEM[y]).join('/')}${i.zorunlu ? ', zorunlu' : ''}${i.asama ? `, aşama ${i.asama}` : ''})`).join(' · ')}</div></div> : null}
        </div>
        <div className="fm-ed-oze">
          <div className="ka-sekmeler" style={{ padding: '0 0 6px' }}>
            <div className={`ka-sekme${sekme === 'ozellik' ? ' on' : ''}`} onClick={() => setSekme('ozellik')}>{alan ? 'Alan' : bolum ? 'Bölüm' : 'Seçim yok'}</div>
            <div className={`ka-sekme${sekme === 'sablon' ? ' on' : ''}`} onClick={() => setSekme('sablon')}>Şablon (hesap · imza)</div>
          </div>
          {sekme === 'ozellik' && alan && sec && (
            <>
              <Oz lb="Kod"><input className="fm-giris" value={alan.kod} disabled={!yazar} onChange={e => alanDegis('kod', e.target.value.replace(/[^\w]/g, '_'))} /></Oz>
              <Oz lb="Tip"><select className="fm-giris" value={alan.tip} disabled={!yazar} onChange={e => alanDegis('tip', e.target.value)}>{TIPLER.map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}</select></Oz>
              {alan.tip === 'metinblok'
                ? <Oz lb="Metin ({hasta.ad}, {kurum.ad}, {alanKodu})"><textarea className="fm-giris" rows={6} value={alan.metin ?? ''} disabled={!yazar} onChange={e => alanDegis('metin', e.target.value)} /></Oz>
                : <Oz lb="Etiket"><input className="fm-giris" value={alan.etiket ?? ''} disabled={!yazar} onChange={e => alanDegis('etiket', e.target.value)} /></Oz>}
              {(alan.tip === 'secim' || alan.tip === 'coklu') && <Oz lb="Seçenekler (her satır bir seçenek)"><textarea className="fm-giris" rows={5} value={(alan.secenek ?? []).join('\n')} disabled={!yazar} onChange={e => alanDegis('secenek', e.target.value.split('\n').map(x => x.trim()).filter(Boolean))} /></Oz>}
              {alan.tip === 'olcek' && <Oz lb="En büyük (10 → 0-10, 5 → 1-5)"><input className="fm-giris" type="number" value={alan.max ?? 10} disabled={!yazar} onChange={e => alanDegis('max', Number(e.target.value))} /></Oz>}
              {alan.tip === 'skor' && <Oz lb="Satırlar (JSON: [{kod, etiket, secenek:[{ad, puan}]}])"><textarea className="fm-giris" rows={8} defaultValue={JSON.stringify(alan.satirlar ?? [], null, 1)} disabled={!yazar}
                onBlur={e => { try { alanDegis('satirlar', JSON.parse(e.target.value)) } catch { mesaj('Satır JSON hatalı.') } }} /></Oz>}
              {alan.tip !== 'metinblok' && <label className="fm-onay"><input type="checkbox" checked={!!alan.zorunlu} disabled={!yazar} onChange={e => alanDegis('zorunlu', e.target.checked)} /><span>Zorunlu</span></label>}
              {alan.tip === 'evethayir' && <label className="fm-onay"><input type="checkbox" checked={!!alan.aciklamaEvetse} disabled={!yazar} onChange={e => alanDegis('aciklamaEvetse', e.target.checked)} /><span>Evet ise açıklama iste</span></label>}
              <Oz lb="Koşul: alan kodu = değer (boş = her zaman)"><div className="fm-ikili">
                <input className="fm-giris" placeholder="alan" value={alan.kosul?.alan ?? ''} disabled={!yazar} onChange={e => alanDegis('kosul', e.target.value ? { alan: e.target.value, deger: alan.kosul?.deger ?? true } : undefined)} />
                <input className="fm-giris" placeholder="değer (Evet için boş)" value={alan.kosul?.deger === true ? '' : String(alan.kosul?.deger ?? '')} disabled={!yazar || !alan.kosul} onChange={e => alanDegis('kosul', { alan: alan.kosul!.alan, deger: e.target.value || true })} />
              </div></Oz>
              <Oz lb="Hedef alan (tablo.kolon — ör. muayene.sikayet)"><input className="fm-giris" value={alan.hedefAlan ?? ''} disabled={!yazar} onChange={e => alanDegis('hedefAlan', e.target.value)} /></Oz>
              <Oz lb="Yardım metni"><input className="fm-giris" value={alan.yardim ?? ''} disabled={!yazar} onChange={e => alanDegis('yardim', e.target.value)} /></Oz>
            </>
          )}
          {sekme === 'ozellik' && !alan && bolum && (
            <>
              <Oz lb="Bölüm adı"><input className="fm-giris" value={bolum.ad} disabled={!yazar} onChange={e => bolumDegis('ad', e.target.value)} /></Oz>
              <Oz lb="Kod"><input className="fm-giris" value={bolum.kod} disabled={!yazar} onChange={e => bolumDegis('kod', e.target.value.replace(/[^\w]/g, '_'))} /></Oz>
              <Oz lb="Sahip (kim doldurur)"><select className="fm-giris" value={bolum.sahip} disabled={!yazar} onChange={e => bolumDegis('sahip', e.target.value)}>{SAHIPLER.map(x => <option key={x} value={x}>{SAHIP_ADI[x]}</option>)}</select></Oz>
              <Oz lb="Aşama (aşamalı formda; boş = 1)"><input className="fm-giris" type="number" value={bolum.asama ?? ''} disabled={!yazar} onChange={e => bolumDegis('asama', e.target.value ? Number(e.target.value) : undefined)} /></Oz>
              <div className="sonuk" style={{ fontSize: 11 }}>Hasta / çalışan bölümleri SMS bağlantısında görünür; hekim, hemşire, anestezi, cerrah bölümleri yalnız iç ekranda.</div>
            </>
          )}
          {sekme === 'sablon' && (
            <>
              <Oz lb="Hesap (JSON: {kaynak?, ortalama?, esikler:[{min,max,ad,renk,gorev}]})"><textarea className="fm-giris" rows={8} defaultValue={JSON.stringify(t.hesap ?? {}, null, 1)} disabled={!yazar}
                onBlur={e => { try { const h = JSON.parse(e.target.value); guncelle(x => { if (Object.keys(h).length) x.hesap = h; else delete x.hesap; return x }) } catch { mesaj('Hesap JSON hatalı.') } }} /></Oz>
              <div className="fm-etiket">İmzalar</div>
              {(t.imzalar ?? []).map((im, i) => (
                <div key={i} className="fm-imza-satir">
                  <select className="fm-giris" value={im.rol} disabled={!yazar} onChange={e => guncelle(x => { x.imzalar![i].rol = e.target.value; return x })}>{[...SAHIPLER, 'tanik', 'vasi'].map(r => <option key={r} value={r}>{SAHIP_ADI[r] ?? r}</option>)}</select>
                  <div className="fm-cipler">{Object.entries(IMZA_YONTEM).map(([k, ad]) => <button key={k} type="button" className={`fm-cip${im.yontem.includes(Number(k)) ? ' on' : ''}`} disabled={!yazar} onClick={() => guncelle(x => { const y = x.imzalar![i].yontem; x.imzalar![i].yontem = y.includes(Number(k)) ? y.filter(z => z !== Number(k)) : [...y, Number(k)]; return x })}>{ad}</button>)}</div>
                  <label className="fm-onay fm-onay-ic"><input type="checkbox" checked={!!im.zorunlu} disabled={!yazar} onChange={e => guncelle(x => { x.imzalar![i].zorunlu = e.target.checked; return x })} /><span>zorunlu</span></label>
                  <input className="fm-giris" style={{ width: 50 }} type="number" placeholder="aşama" value={im.asama ?? ''} disabled={!yazar} onChange={e => guncelle(x => { x.imzalar![i].asama = e.target.value ? Number(e.target.value) : undefined; return x })} />
                  {yazar && <button className="d mini" onClick={() => guncelle(x => { x.imzalar!.splice(i, 1); return x })}>✕</button>}
                </div>
              ))}
              {yazar && <button className="d" onClick={() => guncelle(x => { (x.imzalar ??= []).push({ rol: 'hasta', yontem: [1], zorunlu: true } as FormImzaTanimi); return x })}>＋ İmza</button>}
              <div className="sonuk" style={{ fontSize: 11, marginTop: 8 }}>Kanal, geçerlilik, tekrar, aşamalı ve durum alanları şablon kartında (liste › Düzenle).</div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

function Oz({ lb, children }: { lb: string; children: React.ReactNode }) {
  return <div className="fm-oz"><div className="fm-etiket">{lb}</div>{children}</div>;
}
