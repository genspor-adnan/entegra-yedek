import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { HaftalikPlan, PlanZiyareti } from '../api/uclar/disHekim';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';
import { GenLookup } from '../bilesenler/GenLookup';
import { Modal } from '../bilesenler/Modal';
import { c as cev } from '../dil/ceviri';

/**
 * DIŞ DOKTOR HAFTALIK ZİYARET PLANI (1290, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html §3).
 *
 * NEDEN AYRI SAYFA: liste satır çizer, takvim çizmez; temsilci haftasını gün sütunlarında görür, ziyareti sürükleyip
 * başka güne taşır. "Planı Üret" sunucuda (fn_dis_hekim_plan_uret) sıklıktan ÖNERİ çıkarır (kesik çerçeve); temsilci
 * onaylar ya da kaldırır. ROTA (§4) kullanıcı kararıyla yapılmadı.
 */
const GUNLER = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum'];

const haftaBasi = (d: Date) => {
  const x = new Date(d); x.setHours(0, 0, 0, 0);
  x.setDate(x.getDate() - ((x.getDay() + 6) % 7));
  return x;
};
const isoGun = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const saat = (iso: string) => new Date(iso).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });

export function DisHekimPlan() {
  const git = useNavigate();
  const [hafta, setHafta] = useState(() => haftaBasi(new Date()));
  const [temsilci, setTemsilci] = useState<number | undefined>(undefined);
  const [veri, setVeri] = useState<HaftalikPlan | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [yenile, setYenile] = useState(0);
  const [gunBasi, setGunBasi] = useState(6);
  const [grupla, setGrupla] = useState(true);
  const [hedef, setHedef] = useState<number | null>(null);
  const [surukle, setSurukle] = useState<PlanZiyareti | null>(null);
  // ELLE EKLE (kullanıcı 10.11.2026: "plana dış dr ekleyebilmem lazım, Planı Üret dışında"): gün başlığındaki ＋,
  //   dış doktor araması + saat; POST /planla ile planlı (durum 0, öneri değil) ziyaret.
  const [ekleGun, setEkleGun] = useState<number | null>(null);
  const [ekleHekim, setEkleHekim] = useState<{ id: number; ad: string } | null>(null);
  const [ekleSaat, setEkleSaat] = useState('10:00');

  useEffect(() => {
    void (async () => {
      try { const y = await api.disHekimPlan(isoGun(hafta), temsilci); setVeri(y); setHata(null); if (!temsilci) setTemsilci(y.temsilciId) }
      catch (h) { setHata(hataMetni(h)) }
    })();
  }, [hafta, temsilci, yenile]);

  const haftaDegis = (f: number) => { const d = new Date(hafta); d.setDate(d.getDate() + 7 * f); setHafta(d) };
  const gunTarihi = (i: number) => { const d = new Date(hafta); d.setDate(d.getDate() + i); return d };
  const bugun = isoGun(new Date());
  const tazele = () => setYenile(t => t + 1);

  const uret = () => guvenli(async () => {
    const y = await api.disHekimPlanUret({ haftaBas: isoGun(hafta), temsilciId: temsilci, gunBasi, grupla });
    mesaj(y.mesaj); tazele();
  });
  const onayla = (z: PlanZiyareti) => guvenli(async () => { await api.disHekimZiyaretOnayla(z.id); tazele() });
  const iptal = async (z: PlanZiyareti) => {
    if (!z.oneri && !await onay(`${z.hekim_ad} ziyareti iptal edilecek. Onaylıyor musunuz?`)) return;
    await guvenli(async () => { const y = await api.disHekimZiyaretIptal(z.id); mesaj(y.mesaj); tazele() });
  };
  const birak = (gunIdx: number) => {
    setHedef(null);
    if (!surukle || surukle.durum !== 0) return;
    const eski = new Date(surukle.tarih);
    const yeni = gunTarihi(gunIdx); yeni.setHours(eski.getHours(), eski.getMinutes(), 0, 0);
    if (isoGun(yeni) === isoGun(eski)) return;
    const z = surukle; setSurukle(null);
    void guvenli(async () => { await api.disHekimZiyaretTasi(z.id, `${isoGun(yeni)}T${String(yeni.getHours()).padStart(2, '0')}:${String(yeni.getMinutes()).padStart(2, '0')}:00`); tazele() });
  };

  const ekle = () => {
    if (ekleGun === null || !ekleHekim) { mesaj('Dış doktor seçin.'); return }
    const gun = isoGun(gunTarihi(ekleGun));
    void guvenli(async () => {
      const y = await api.disHekimPlanla({ hekimId: ekleHekim.id, tarih: `${gun}T${ekleSaat || '10:00'}:00`, temsilciId: temsilci });
      mesaj(y.mesaj); setEkleGun(null); setEkleHekim(null); tazele();
    });
  };

  const ziyaretler = veri?.ziyaretler ?? [];
  const oneri = ziyaretler.filter(z => z.oneri === 1).length;
  const yapildi = ziyaretler.filter(z => z.durum === 1).length;
  const temsilciAd = veri?.temsilciler.find(t => t.id === temsilci)?.ad ?? '';

  return (
    <div className="sayfa">
      <div className="sayfabas">
        <div className="basrow">
          <h1>{cev('Ziyaret Planı')}</h1>
          <span className="yol">{cev('Kurumlar & Sigorta › Ziyaret Planı')}</span>
        </div>
      </div>
      <div className="cz-sayfa">
        <div className="cp-arac">
          <button className="d" onClick={() => haftaDegis(-1)}>‹ {cev('Önceki hafta')}</button>
          <span style={{ fontWeight: 700 }}>{gunTarihi(0).toLocaleDateString('tr-TR')} – {gunTarihi(4).toLocaleDateString('tr-TR')}</span>
          <button className="d" onClick={() => haftaDegis(1)}>{cev('Sonraki hafta')} ›</button>
          <button className="d" onClick={() => setHafta(haftaBasi(new Date()))}>{cev('Bu hafta')}</button>
          {veri && veri.temsilciler.length > 1 && (
            <select value={temsilci ?? 0} onChange={e => setTemsilci(Number(e.target.value) || undefined)} data-testid="plan-temsilci">
              {veri.temsilciler.map(t => <option key={t.id} value={t.id}>{t.ad}</option>)}
            </select>
          )}
          <span className="dhp-uret" style={{ marginLeft: 'auto' }}>
            <label>{cev('Gün başı')} <input type="number" min={1} max={20} value={gunBasi} onChange={e => setGunBasi(Number(e.target.value) || 6)} /></label>
            <label><input type="checkbox" checked={grupla} onChange={e => setGrupla(e.target.checked)} /> {cev('Aynı ilçe aynı gün')}</label>
            <button className="d bir" onClick={() => void uret()} data-testid="plan-uret" title={cev('Sıklığı dolan, planı olmayan hekimlere öneri ziyaret açar')}>⚙ {cev('Planı Üret')}</button>
          </span>
          <button className="d" onClick={() => git('/dis-hekim-vade')}>⏰ {cev('Ziyaret Vadesi')}</button>
          <button className="d" onClick={() => git('/dis-hekim-ziyaret/yeni')}>＋ {cev('Ziyaret')}</button>
          <button className="d" onClick={tazele}>⟳</button>
        </div>

        {veri && (
          <div className="cz-ozet">
            <div className="kutu"><b>{cev('Temsilci')}</b><span style={{ fontSize: 13 }}>{temsilciAd || '—'}</span></div>
            <div className="kutu"><b>{cev('Planlı')}</b><span>{ziyaretler.filter(z => z.durum === 0).length}</span></div>
            <div className="kutu ok"><b>{cev('Yapıldı')}</b><span>{yapildi}</span></div>
            <div className="kutu sari"><b>{cev('Öneri')}</b><span>{oneri}<small>{cev('onay bekliyor')}</small></span></div>
            {veri.vade && <>
              <div className="kutu kir"><b>{cev('Geciken hekim')}</b><span>{veri.vade.geciken}</span></div>
              <div className="kutu"><b>{cev('Bu hafta planlanacak')}</b><span>{veri.vade.planlanacak}<small>{cev('vadesi dolan, planı yok')}</small></span></div>
              <div className="kutu kir"><b>{cev('Gönderimi düşen')}</b><span>{veri.vade.dusen}</span></div>
              <div className="kutu"><b>{cev('Açık talepli')}</b><span>{veri.vade.talepli}</span></div>
            </>}
          </div>
        )}
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="dhp-hafta">
          {GUNLER.map((ad, i) => {
            const gun = isoGun(gunTarihi(i));
            const liste = ziyaretler.filter(z => isoGun(new Date(z.tarih)) === gun);
            const ilceler = [...new Set(liste.map(z => z.hekim_ilce).filter(Boolean))].join(' / ');
            return (
              <div key={ad} className={`dhp-gun${gun === bugun ? ' bugun' : ''}${hedef === i ? ' hedef' : ''}`}
                   onDragOver={e => { if (surukle) { e.preventDefault(); setHedef(i) } }}
                   onDragLeave={() => setHedef(h => h === i ? null : h)}
                   onDrop={e => { e.preventDefault(); birak(i) }}>
                <h5>{ad} {gunTarihi(i).toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit' })}<small>{liste.length} {cev('ziyaret')}{ilceler ? ` · ${ilceler}` : ''}</small>
                  <button type="button" className="bs-kalem" title={cev('Bu güne dış doktor ekle')} data-testid={`plan-ekle-${i}`}
                          onClick={() => { setEkleGun(i); setEkleHekim(null) }}>＋</button></h5>
                <div className="dhp-govde">
                  {liste.map(z => (
                    <div key={z.id}
                         className={`dhp-kart${z.durum === 1 ? ' yapildi' : ''}${z.oneri === 1 ? ' oneri' : ''}${z.durum === 0 && new Date(z.tarih) < new Date() && gun !== bugun ? ' gecik' : ''}`}
                         draggable={z.durum === 0}
                         onDragStart={() => setSurukle(z)} onDragEnd={() => { setSurukle(null); setHedef(null) }}
                         onDoubleClick={() => git(`/dis-hekim-ziyaret/${z.id}`)}
                         title={z.notu}>
                      <b>{saat(z.tarih)} {z.hekim_ad}</b>{z.hekim_ilce ? ` · ${z.hekim_ilce}` : ''}
                      <div className="s">{z.durum === 1 ? `${z.tur_ad} · ${z.sonuc_ad}` : z.oneri === 1 ? z.notu : z.amac_ad}{z.acik_talep > 0 ? ` · ${z.acik_talep} ${cev('açık talep')}` : ''}</div>
                      {z.durum === 0 && (
                        <div className="d">
                          {z.oneri === 1 && <button className="d" title={cev('Öneriyi plana al')} onClick={() => void onayla(z)}>✓</button>}
                          <button className="d" title={cev('Ziyaret kartı (yapıldı olarak kaydet)')} onClick={() => git(`/dis-hekim-ziyaret/${z.id}`)}>📝</button>
                          <button className="d" title={z.oneri === 1 ? cev('Öneriyi kaldır') : cev('Planı iptal et')} onClick={() => void iptal(z)}>✖</button>
                        </div>
                      )}
                    </div>
                  ))}
                  {liste.length === 0 && <div className="dhp-bos">{cev('sürükle-bırak ile ziyaret taşı')}</div>}
                </div>
              </div>
            );
          })}
        </div>
      </div>
      {ekleGun !== null && (
        <Modal baslik={`${cev('Plana Ekle')} — ${GUNLER[ekleGun]} ${gunTarihi(ekleGun).toLocaleDateString('tr-TR')}`} onKapat={() => setEkleGun(null)} enUst dar
          alt={<>
            <button className="d bir" disabled={!ekleHekim} onClick={ekle}>📅 {cev('Planla')}</button>
            <button className="d kapat-dugmesi" onClick={() => setEkleGun(null)}>✖ {cev('Vazgeç')}</button>
          </>}>
          <div className="alan-izgara" data-testid="plan-ekle">
            <GenLookup kaynak="dis-hekim" etiket={cev('Dış Doktor')} zorunlu
                       alanlar={[{ ad: 'unvan', baslik: 'Dış Doktor', genis: true }, { ad: 'kurum', baslik: 'Kurum' }, { ad: 'departmanAdi', baslik: 'Bölüm' }]}
                       deger={ekleHekim?.ad}
                       onSec={x => setEkleHekim(x ? { id: Number(x.id), ad: String(x.unvan ?? '') } : null)} />
            <label className="alan">
              <span className="etiket">{cev('Saat')}</span>
              <input type="time" value={ekleSaat} onChange={e => setEkleSaat(e.target.value)} />
            </label>
          </div>
          <div className="not" style={{ marginTop: 8 }}>{cev('Planlı ziyaret temsilciye yazılır; yapılınca karttan "Yapıldı" olarak kaydedilir.')}</div>
        </Modal>
      )}
    </div>
  );
}
