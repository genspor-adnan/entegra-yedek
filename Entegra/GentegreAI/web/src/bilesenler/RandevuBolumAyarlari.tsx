import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import {
  type RandevuAyarSatiri, type RandevuBolumDugumu, hataMetni,
} from '../api/sozlesme';

/**
 * RANDEVU AYARLARI > BÖLÜMLER (251, kullanıcı: "solda departmandan randevu
 * verilen bölümler ve bu departmandaki hekimler listelensin, sağında ise o
 * bölüme/hekime ait randevu ayarları gelsin - master detail").
 *
 * Boş bırakılan alan ÜST SEVİYEDEN miras alınır: hekim → bölüm → Genel
 * Ayarlar. Her seviyede tüm alanları doldurmaya zorlamak, tek bir öğle arası
 * farkı için bütün düzeni kopyalatırdı; bu yüzden alanlar zorunlu değil ve
 * yer tutucuda devralınan değer yazar.
 */
const GUNLER = [
  { deger: 1, ad: 'Pzt' }, { deger: 2, ad: 'Sal' }, { deger: 3, ad: 'Çar' },
  { deger: 4, ad: 'Per' }, { deger: 5, ad: 'Cum' }, { deger: 6, ad: 'Cmt' },
  { deger: 7, ad: 'Paz' },
];

/** Seçili düğüm: bölümün kendisi ya da bir hekimi. */
interface Secim { departmanId: number; hekimId: number | null }

export function RandevuBolumAyarlari({ genel }: {
  /** Genel Ayarlar'daki değerler - miras zincirinin en üstü (yer tutucu metni). */
  genel: { baslangicSaat: string; bitisSaat: string; slotDk: string; varsayilanSure: string;
           calismaGunleri: string; ogleBaslangic: string; ogleBitis: string };
}) {
  const [dugumler, setDugumler] = useState<RandevuBolumDugumu[]>([]);
  const [secim, setSecim] = useState<Secim | null>(null);
  const [form, setForm] = useState<RandevuAyarSatiri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [bolumEkle, setBolumEkle] = useState(false);
  const [departmanlar, setDepartmanlar] = useState<{ id: number; ad: string }[]>([]);

  const yukle = useCallback(async (koru?: Secim | null) => {
    setYukleniyor(true); setHata('');
    try {
      const y = await api.randevuBolumleri();
      setDugumler(y);
      const s = koru ?? secim ?? (y.length ? { departmanId: y[0].departmanId, hekimId: null } : null);
      setSecim(s);
      if (s) {
        const d = y.find(x => x.departmanId === s.departmanId);
        setForm(s.hekimId == null ? d?.ayar ?? null
                                  : d?.hekimler.find(h => h.hekimId === s.hekimId) ?? null);
      }
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  // secim bilerek bagimlilikta degil: her secim degisiminde sunucuya gitmeyelim.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => { void yukle() }, [yukle]);

  const sec = (s: Secim) => {
    setSecim(s); setBilgi('');
    const d = dugumler.find(x => x.departmanId === s.departmanId);
    setForm(s.hekimId == null ? d?.ayar ?? null
                              : d?.hekimler.find(h => h.hekimId === s.hekimId) ?? null);
  };

  const degis = (alan: keyof RandevuAyarSatiri, deger: unknown) =>
    setForm(f => (f ? { ...f, [alan]: deger } as RandevuAyarSatiri : f));

  const gunSecili = (g: number) =>
    (form?.calismaGunleri ?? '').split(',').map(x => x.trim()).includes(String(g));

  const gunDegis = (g: number) => {
    const mevcut = (form?.calismaGunleri ?? '').split(',').map(x => x.trim()).filter(Boolean);
    const yeni = mevcut.includes(String(g))
      ? mevcut.filter(x => x !== String(g))
      : [...mevcut, String(g)].sort();
    degis('calismaGunleri', yeni.join(','));
  };

  const kaydet = async () => {
    if (!form) return;
    setHata(''); setBilgi('');
    try {
      await api.randevuBolumAyarYaz({
        departmanId: form.departmanId, hekimId: form.hekimId,
        baslangicSaat: form.baslangicSaat, bitisSaat: form.bitisSaat,
        ogleBaslangic: form.ogleBaslangic, ogleBitis: form.ogleBitis,
        slotDk: form.slotDk, varsayilanSure: form.varsayilanSure,
        calismaGunleri: form.calismaGunleri, aktif: form.aktif, aciklama: form.aciklama,
      });
      setBilgi('Kaydedildi.');
      await yukle(secim);
    } catch (h) { setHata(hataMetni(h)) }
  };

  /** Bölüm listesine departman ekle / çıkar (departman.randevu_verilebilir). */
  const bolumEkleAc = async () => {
    setBolumEkle(true);
    if (departmanlar.length === 0) {
      try {
        const y = await api.liste('departman', {
          sayfa: 1, boyut: 500, sirala: [{ alan: 'ad', yon: 'asc' }],
          filtre: { op: 'and', kosullar: [{ alan: 'randevuVerilebilir', op: 'esit', deger: 0 }] },
        });
        setDepartmanlar(y.satirlar.map(r => ({ id: Number(r.id), ad: String(r.ad ?? '') })));
      } catch (h) { setHata(hataMetni(h)) }
    }
  };

  const bolumeAl = async (departmanId: number) => {
    try {
      await api.randevuBolumIsaretle(departmanId, true);
      setBolumEkle(false); setDepartmanlar([]);
      await yukle({ departmanId, hekimId: null });
    } catch (h) { setHata(hataMetni(h)) }
  };

  const bolumdenCikar = async (departmanId: number) => {
    try {
      await api.randevuBolumIsaretle(departmanId, false);
      await yukle(null);
    } catch (h) { setHata(hataMetni(h)) }
  };

  if (yukleniyor) return <div className="yukleniyor">Yükleniyor…</div>;

  const secili = (d: number, h: number | null) =>
    secim?.departmanId === d && secim?.hekimId === h;

  return (
    <>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      <div style={{ display: 'flex', gap: 16, alignItems: 'flex-start' }}>
        {/* --------------------------------------------------- SOL: agac --- */}
        <div className="kagrup" style={{ flex: '0 0 320px', minWidth: 0 }}>
          <div className="numaralama-bas bitisik">
            <h6>Bölümler ve Hekimler</h6>
            <button type="button" className="d" onClick={() => void bolumEkleAc()}>＋ Bölüm</button>
          </div>

          {bolumEkle && (
            <div className="kutu" style={{ padding: 8, marginBottom: 8 }}>
              <div style={{ fontSize: 12, opacity: .75, marginBottom: 4 }}>
                Randevu verilecek departmanı seçin:
              </div>
              <select onChange={e => e.target.value && void bolumeAl(Number(e.target.value))}
                      defaultValue="">
                <option value="">— Seçiniz —</option>
                {departmanlar.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}
              </select>
              <button type="button" className="d" style={{ marginLeft: 6 }}
                      onClick={() => setBolumEkle(false)}>Vazgeç</button>
            </div>
          )}

          <div style={{ maxHeight: '60vh', overflowY: 'auto' }}>
            {dugumler.length === 0 && (
              <div style={{ padding: 12, opacity: .7, fontSize: 12 }}>
                Randevu verilen bölüm yok — “＋ Bölüm” ile ekleyin.
              </div>
            )}
            {dugumler.map(d => (
              <div key={d.departmanId}>
                <div className={`agac-satir${secili(d.departmanId, null) ? ' on' : ''}`}
                     onClick={() => sec({ departmanId: d.departmanId, hekimId: null })}>
                  <b>{d.ad}</b>
                  <span className="sag">
                    <button type="button" className="d mini"
                            title="Bölüm listesinden çıkar"
                            onClick={e => { e.stopPropagation(); void bolumdenCikar(d.departmanId) }}>
                      ✕
                    </button>
                  </span>
                </div>
                {d.hekimler.map(h => (
                  <div key={h.hekimId}
                       className={`agac-satir alt${secili(d.departmanId, h.hekimId) ? ' on' : ''}`}
                       onClick={() => sec({ departmanId: d.departmanId, hekimId: h.hekimId })}>
                    {h.ad}
                  </div>
                ))}
                {d.hekimler.length === 0 && (
                  <div className="agac-satir alt" style={{ opacity: .6, cursor: 'default' }}>
                    (bu bölümde personel yok)
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* --------------------------------------------------- SAG: form --- */}
        <div className="kagrup" style={{ flex: 1, minWidth: 0 }}>
          {!form ? (
            <div style={{ padding: 16, opacity: .7 }}>Soldan bir bölüm ya da hekim seçin.</div>
          ) : (
            <>
              <div className="numaralama-bas bitisik">
                <h6>{form.hekimId == null ? `${form.ad} — bölüm düzeni` : `${form.ad} — hekim düzeni`}</h6>
                <button type="button" className="bir" onClick={() => void kaydet()}>Kaydet</button>
              </div>
              <div style={{ fontSize: 12, opacity: .75, padding: '0 12px 8px' }}>
                Boş bırakılan alan {form.hekimId == null ? 'Genel Ayarlar’dan' : 'bölümden'} devralınır.
              </div>

              <div className="alan-izgara tek-sutun ayar-formu">
                <label className="alan">
                  <span className="etiket">Başlangıç saati</span>
                  <input value={form.baslangicSaat} placeholder={genel.baslangicSaat}
                         onChange={e => degis('baslangicSaat', e.target.value)} />
                </label>
                <label className="alan">
                  <span className="etiket">Bitiş saati</span>
                  <input value={form.bitisSaat} placeholder={genel.bitisSaat}
                         onChange={e => degis('bitisSaat', e.target.value)} />
                </label>
                <label className="alan">
                  <span className="etiket">Öğle arası başlangıcı</span>
                  <input value={form.ogleBaslangic} placeholder={genel.ogleBaslangic || '—'}
                         onChange={e => degis('ogleBaslangic', e.target.value)} />
                </label>
                <label className="alan">
                  <span className="etiket">Öğle arası bitişi</span>
                  <input value={form.ogleBitis} placeholder={genel.ogleBitis || '—'}
                         onChange={e => degis('ogleBitis', e.target.value)} />
                </label>
                <label className="alan">
                  <span className="etiket">Randevu aralığı (dk)</span>
                  <input className="hiza-sag" value={form.slotDk ?? ''} placeholder={genel.slotDk}
                         onChange={e => degis('slotDk', e.target.value ? Number(e.target.value) : null)} />
                </label>
                <label className="alan">
                  <span className="etiket">Varsayılan süre (dk)</span>
                  <input className="hiza-sag" value={form.varsayilanSure ?? ''}
                         placeholder={genel.varsayilanSure}
                         onChange={e => degis('varsayilanSure',
                                              e.target.value ? Number(e.target.value) : null)} />
                </label>
                <label className="alan">
                  <span className="etiket">Çalışma günleri</span>
                  <span style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
                    {GUNLER.map(g => (
                      <button key={g.deger} type="button"
                              className={`cip${gunSecili(g.deger) ? ' on' : ''}`}
                              onClick={() => gunDegis(g.deger)}>{g.ad}</button>
                    ))}
                  </span>
                </label>
                <label className="alan">
                  <span className="etiket">Randevuya açık</span>
                  <input type="checkbox" checked={form.aktif === 1}
                         onChange={e => degis('aktif', e.target.checked ? 1 : 0)} />
                </label>
                <label className="alan">
                  <span className="etiket">Açıklama</span>
                  <input value={form.aciklama} onChange={e => degis('aciklama', e.target.value)} />
                </label>
              </div>
            </>
          )}
        </div>
      </div>
    </>
  );
}
