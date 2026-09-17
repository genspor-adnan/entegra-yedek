import { useCallback, useEffect, useState } from 'react';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { FormCevap, FormImza, FormIstekKarti } from '../../api/uclar/form';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { FormCizici, SAHIP_ADI, skorHesapla, zorunluEksikler } from '../../bilesenler/form/FormCizici';
import { ImzaKanvas } from '../../bilesenler/form/ImzaKanvas';

/**
 * FORM DOLDURMA (iç ekran / tablet) `/form-doldur/:id` — mockuplar
 * Ekranlar/Formlar/form_onam_imza.html, form_hemsire_degerlendirme.html,
 * form_guvenli_cerrahi.html. Klinik rol tüm bölümleri görür (sahip rozeti),
 * kendi bölümünü yazar; hasta bölümü hasta beyanından gelmişse salt okunur
 * "beyan" rozetiyle. Aşamalı formda yalnız açık aşama yazılır. İmzalar:
 * hasta → kanvas (tablet), kullanıcı → "İmzala" (kullanıcı adı + zaman).
 * Kapat: geldiği yere (?geri= / state.geri).
 */
const DURUM: Record<number, [string, string]> = {
  1: ['Gönderildi', 'mor'], 2: ['Açıldı', 'mor'], 3: ['Taslak', 'uyari'], 4: ['Tamamlandı', 'ok'],
  5: ['Süresi doldu', 'hata'], 6: ['Kilitli', 'hata'], 7: ['Reddetti', 'hata'], 8: ['İptal', 'hata'],
};

export function FormDoldur() {
  const { id: param } = useParams();
  const id = Number(param ?? 0);
  const git = useNavigate();
  const konum = useLocation();
  const [sorgu] = useSearchParams();
  const { kullanici, yetki } = useOturum();
  const durumS = konum.state as { geri?: string } | null;
  const geri = durumS?.geri ?? sorgu.get('geri') ?? '/form-istek';
  const kapat = useCallback(() => git(geri), [git, geri]);
  useEffect(() => { const f = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() }; window.addEventListener('keydown', f); return () => window.removeEventListener('keydown', f) }, [kapat]);

  const [k, setK] = useState<FormIstekKarti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [cevap, setCevap] = useState<FormCevap>({});
  const [imzalar, setImzalar] = useState<FormImza[]>([]);
  const [kirli, setKirli] = useState(false);

  const yukle = useCallback(async () => {
    try {
      const y = await api.formIstek(id);
      setK(y); setCevap({ ...(y.cevap ?? {}), ...(y.taslak ?? {}) }); setImzalar(y.imzalar ?? []); setHata(null); setKirli(false);
    } catch (h) { setHata(hataMetni(h)) }
  }, [id]);
  useEffect(() => { void yukle() }, [yukle]);

  const i = k?.istek;
  const tamam = i?.durum === 4;
  const yazar = yetki('form.doldur') && !tamam && i?.durum !== 8 && i?.durum !== 7;
  const acikAsama = i?.asama ?? 1;
  const bolumler = k?.tanim.bolumler ?? [];
  const hastaBolumu = (sahip: string) => sahip === 'hasta' || sahip === 'calisan';
  // Hasta bölümü UZAKTAN beyanla (SMS/kiosk bağlantısı, imza yöntemi 5) dolduysa
  //   personel değiştirmez; tablette aynı oturumda atılan kanvas imzası bölümü kilitlemez.
  const beyanVar = imzalar.some(x => (x.rol === 'hasta' || x.rol === 'calisan') && x.yontem === 5);
  const salt = (b: { sahip: string; asama?: number }) => !yazar || (k?.asamali === 1 && (b.asama ?? 1) !== acikAsama) || (hastaBolumu(b.sahip) && beyanVar);
  const degistir = (kod: string, v: unknown) => { setCevap(c => ({ ...c, [kod]: v })); setKirli(true) };

  const kaydet = async (tamamla: boolean) => {
    if (!k) return;
    if (tamamla) {
      const hedef = k.asamali === 1 ? bolumler.filter(b => (b.asama ?? 1) === acikAsama) : bolumler.filter(b => !hastaBolumu(b.sahip) || !beyanVar);
      const eksik = zorunluEksikler(hedef, cevap);
      if (eksik.length) { mesaj('Zorunlu alanlar boş: ' + eksik.join(', ')); return }
      const gerekli = (k.tanim.imzalar ?? []).filter(x => x.zorunlu && (k.asamali !== 1 || (x.asama ?? 1) === acikAsama));
      const eksikImza = gerekli.filter(x => !imzalar.some(y => y.rol === x.rol));
      if (eksikImza.length) { mesaj('Eksik imza: ' + eksikImza.map(x => SAHIP_ADI[x.rol] ?? x.rol).join(', ')); return }
      if (!await onay(k.asamali === 1 && acikAsama < asamaSayisi(k) ? `${acikAsama}. aşama kapatılsın mı?` : 'Form tamamlansın mı? Tamamlanan form değiştirilemez.')) return;
    }
    await guvenli(async () => {
      const y = await api.formCevap(id, { cevap, imzalar, tamamla });
      if (tamamla) mesaj(y.durum === 4 ? `Form tamamlandı${y.sonuc ? ` · ${y.sonuc}` : ''}${y.skor != null ? ` · skor ${y.skor}` : ''}` : `${y.asama}. aşama açıldı.`);
      await yukle();
    });
  };
  const imzala = (rol: string) => {
    setImzalar(l => [...l.filter(x => x.rol !== rol), { rol, ad: kullanici?.ad ?? '', yontem: 3, zaman: new Date().toISOString() }]); setKirli(true);
  };
  const hastaImza = (rol: string, png: string | undefined) => {
    setImzalar(l => png ? [...l.filter(x => x.rol !== rol), { rol, ad: i?.hasta_adi ?? '', yontem: 1, zaman: new Date().toISOString(), veri: png }] : l.filter(x => x.rol !== rol));
    setKirli(true);
  };
  const aktar = async () => {
    await guvenli(async () => {
      const y = await api.formAktar(id);
      mesaj((y.yazilan.length ? 'Aktarıldı: ' + y.yazilan.join(' · ') : 'Aktarılacak alan yok.') + (y.atlanan.length ? `\nAtlanan: ${y.atlanan.join(' · ')}` : ''));
      await yukle();
    });
  };

  const baslik = (
    <>📋 {i?.sablon_adi ?? 'Form'}{i && <> — {i.hasta_adi}</>}
      {i && <span className={`rozet ${DURUM[i.durum]?.[1] ?? 'mor'}`} style={{ marginLeft: 8 }}>{DURUM[i.durum]?.[0] ?? i.durum_adi}</span>}
      {k?.asamali === 1 && i && <span className="rozet mor" style={{ marginLeft: 6 }}>Aşama {acikAsama}/{asamaSayisi(k)}</span>}
      <span className="kapt">{i?.kaynak_adi} · {i?.kanal_adi} · v{i?.surum} · Esc ile kapanır</span></>
  );
  if (hata) return <Perde baslik={baslik} kapat={kapat}><div className="hata-kutusu">{hata}</div></Perde>;
  if (!k || !i) return <Perde baslik={baslik} kapat={kapat}><span className="sonuk">Yükleniyor…</span></Perde>;

  const hesap = skorHesapla(k.tanim, cevap);
  const imzaTanimlari = k.tanim.imzalar ?? [];
  return (
    <Perde baslik={baslik} kapat={kapat}>
      <div className="fm-doldur-arac">
        {yazar && <button className="d" onClick={() => void kaydet(false)} disabled={!kirli}>💾 Taslak kaydet</button>}
        {yazar && <button className="d bir" onClick={() => void kaydet(true)}>{k.asamali === 1 && acikAsama < asamaSayisi(k) ? `✔ ${acikAsama}. aşamayı kapat` : '✔ Tamamla'}</button>}
        {tamam && yetki('form.aktar') && i.kaynak_tur === 3 && <button className="d" onClick={() => void aktar()}>⬇ Beyanı kayda aktar{i.aktarim_zamani ? ' (yeniden)' : ''}</button>}
        <button className="d" onClick={() => window.print()}>🖨 Yazdır</button>
        <span className="sp" />
        {beyanVar && <span className="rozet ok">📱 Hasta beyanı var</span>}
        {i.aktarim_zamani && <span className="rozet mor">Aktarıldı</span>}
        {hesap.skor !== null && <span className={`rozet ${hesap.esik?.renk === 'kir' ? 'hata' : hesap.esik?.renk === 'sari' ? 'uyari' : 'ok'}`}>Skor {hesap.skor}{hesap.esik ? ` · ${hesap.esik.ad}` : ''}</span>}
      </div>
      <FormCizici bolumler={bolumler} cevap={cevap} onChange={degistir} salt={salt} parametreler={k.parametreler} sahipRozeti tanim={k.tanim} />
      {imzaTanimlari.length > 0 && (
        <section className="fm-bolum">
          <h3 className="fm-bolum-bas">İmzalar</h3>
          <div className="fm-imzalar">
            {imzaTanimlari.map(t => {
              const var_ = imzalar.find(x => x.rol === t.rol);
              const hastaRol = t.rol === 'hasta' || t.rol === 'calisan' || t.rol === 'tanik' || t.rol === 'vasi';
              const asamaUygun = k.asamali !== 1 || (t.asama ?? 1) === acikAsama;
              return (
                <div key={t.rol} className="fm-imza-kutu">
                  <div className="fm-imza-bas">{SAHIP_ADI[t.rol] ?? (t.rol === 'tanik' ? 'Tanık' : t.rol === 'vasi' ? 'Vasi' : t.rol)}{t.zorunlu && ' *'}
                    {var_ && <span className="rozet ok" style={{ marginLeft: 6 }}>✓ {var_.ad} · {new Date(var_.zaman).toLocaleString('tr-TR')}</span>}
                  </div>
                  {hastaRol ? (
                    var_?.veri || (yazar && asamaUygun) ? <ImzaKanvas deger={var_?.veri} salt={!yazar || !asamaUygun || (var_?.yontem === 5)} etiket={t.rol === 'hasta' ? i.hasta_adi : undefined} onChange={png => hastaImza(t.rol, png)} />
                      : var_ ? <span className="sonuk">{var_.yontem === 5 ? 'Beyan onayı (bağlantıdan)' : var_.yontem === 2 ? 'SMS OTP' : 'imzalı'}</span> : <span className="sonuk">Tablette imzalanır</span>
                  ) : (
                    var_ ? null : yazar && asamaUygun ? <button className="d" onClick={() => imzala(t.rol)}>✍️ İmzala ({kullanici?.ad})</button> : <span className="sonuk">bekliyor</span>
                  )}
                </div>
              );
            })}
          </div>
        </section>
      )}
    </Perde>
  );
}

/** Modal perdesi: bileşen DIŞINDA tanımlı - içeride tanımlansa her state
 *  değişiminde remount olur, imza kanvası ve odak kaybolurdu. */
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

function asamaSayisi(k: FormIstekKarti): number {
  return Math.max(1, ...(k.tanim.bolumler ?? []).map(b => b.asama ?? 1));
}
