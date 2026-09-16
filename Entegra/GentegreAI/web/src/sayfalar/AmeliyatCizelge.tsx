import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { CizelgeBloku, CizelgeYaniti } from '../api/uclar/ameliyathane';
import { useOturum } from '../kimlik/OturumBaglami';
import { tarihYaz } from '../bilesenler/bicim';
import { ameliyathaneAksiyonu } from './liste/ameliyathaneAksiyonlari';
import { useAmeliyatAcilModallari } from './liste/useAmeliyatAcilModallari';
import { AmeliyatAcilModallari } from './liste/AmeliyatAcilModallari';

/**
 * AMELİYATHANE — ODA × SAAT ÇİZELGESİ (715/719).
 * Mockup: `Ekranlar/Ameliyathane/ameliyat_plani.html` "Masa Çizelgesi".
 *
 * NEDEN AYRI SAYFA. Generic liste satır çizer, blok çizmez: "hangi vakalar
 * var" sorusunu yanıtlar ama "hangi masa ne zaman boş" sorusunu yanıtlayamaz.
 * İkinci soru ameliyathanenin günlük kararının kendisi - bir acil vaka
 * geldiğinde nereye konacağı buradan okunur. Aynı veri Ameliyat Planı
 * listesinde de duruyor; bu sayfa onun yerine geçmiyor, yanına geliyor.
 *
 * BLOKLAR DAKİKA HASSASİYETİNDE YERLEŞİR, saat kutusuna değil. Mockup
 * `colspan` kullanıyordu; 08:10–09:55 süren bir vakayı iki tam saate
 * yuvarlamak, çizelgenin tek işini (boşluğu göstermek) bozardı - 09:55'te
 * biten vakadan sonraki 5 dakika kayıp görünürdü.
 *
 * ŞERİT GERÇEĞİ GÖSTERİR, PLANI DEĞİL. Başlamış vaka gerçek aralığını kaplar
 * (sunucu kararı); planlanan vaka planını. Hep plan çizilseydi ekran sabah
 * verilen sözü gösterir, geciken vakanın sonrakini ittiği görünmezdi. Plan ile
 * gerçek arasındaki fark bloğun altındaki ince şeritle ayrıca gösteriliyor.
 *
 * DÜĞMELER LİSTEDEKİLERLE AYNI KODU ÇALIŞTIRIR (`ameliyathaneAksiyonu`):
 * time-out kapısı, "zaten kaydedilmiş" düzeltmesi ve kontrol listesi modalı
 * burada da aynen geçerli. Sayfaya özel bir "hızlı başlat" yazsaydık, kurallar
 * iki yerde yaşar ve biri zamanla gerisinde kalırdı.
 */
const DURUM_AD: Record<number, string> = {
  0: 'Planlandı', 1: 'Hazırlık', 2: 'Sürüyor', 3: 'Kapanışta', 4: 'Bitti', 8: 'İptal',
};
/** Blok rengi durumdan; gecikme ayrı işaret (çünkü süren vaka da gecikmeli olabilir). */
const DURUM_SINIF: Record<number, string> = {
  0: 'bekliyor', 1: 'hazirlik', 2: 'suruyor', 3: 'kapanis', 4: 'bitti', 8: 'iptal',
};

const iso = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const saatYaz = (t: string | null | undefined) =>
  t ? new Date(t).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }) : '—';
const dk = (a: string, b: string) => (new Date(b).getTime() - new Date(a).getTime()) / 60000;

export function AmeliyatCizelge() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const yazar = yetki('ameliyathane.plan');
  const [gun, setGun] = useState<Date>(() => new Date());
  const [salonId, setSalonId] = useState<number | null>(null);
  const [veri, setVeri] = useState<CizelgeYaniti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<CizelgeBloku | null>(null);
  const [ara, setAra] = useState('');
  const [yenile, setYenile] = useState(0);
  const modal = useAmeliyatAcilModallari();

  const yukle = useCallback(async () => {
    try { setVeri(await api.ameliyatCizelge(iso(gun), salonId)); setHata(null) }
    catch (h) { setHata(hataMetni(h)) }
  }, [gun, salonId, yenile]);
  useEffect(() => { void yukle() }, [yukle]);

  // ŞU AN ÇİZGİSİ yalnız BUGÜN anlamlı: geçmiş bir günün çizelgesinde "şimdi"
  //   nereyi gösterirdi belirsiz. Dakikada bir ilerler.
  const [simdi, setSimdi] = useState(() => Date.now());
  useEffect(() => { const t = setInterval(() => setSimdi(Date.now()), 60000); return () => clearInterval(t) }, []);

  const pencere = useMemo(() => {
    if (!veri) return null;
    const b = new Date(veri.saatBas).getTime();
    const s = new Date(veri.saatSon).getTime();
    return { b, s, dk: (s - b) / 60000 };
  }, [veri]);

  /** Saat başlıkları - pencereden türer (gece süren vaka pencereyi uzatır). */
  const saatler = useMemo(() => {
    if (!pencere) return [];
    const liste: Date[] = [];
    for (let t = pencere.b; t < pencere.s; t += 3600000) liste.push(new Date(t));
    return liste;
  }, [pencere]);

  const suzulmus = useMemo(() => {
    const q = ara.trim().toLocaleLowerCase('tr');
    const hepsi = veri?.ameliyatlar ?? [];
    if (!q) return hepsi;
    return hepsi.filter(a => [a.hastaAd, a.cerrahAd, a.islemAd ?? '', a.ameliyatNo]
      .some(x => x.toLocaleLowerCase('tr').includes(q)));
  }, [veri, ara]);

  const yerlesim = (a: CizelgeBloku) => {
    if (!pencere || !a.bas || !a.bit) return null;
    const b = new Date(a.bas).getTime();
    const s = new Date(a.bit).getTime();
    // Pencere dışına taşan vakayı KIRPARIZ, gizlemeyiz: gece başlayıp sabaha
    //   sarkan acil vaka masayı gerçekten işgal ediyor.
    const sol = Math.max(0, (b - pencere.b) / 60000) / pencere.dk * 100;
    const sag = Math.min(100, (Math.min(s, pencere.s) - pencere.b) / 60000 / pencere.dk * 100);
    if (sag <= 0 || sol >= 100) return null;
    return { left: `${sol}%`, width: `${Math.max(sag - sol, 1.2)}%` };
  };

  async function aksiyon(kod: string, a: CizelgeBloku) {
    await ameliyathaneAksiyonu(kod, { id: a.id, ameliyatNo: a.ameliyatNo }, {
      tazele: () => setYenile(t => t + 1),
      planlaAc: v => modal.setPlanlama(v),
      kontrolAc: v => modal.setKontrol(v),
      faturaAc: v => modal.setFaturaStok(v),
    });
  }

  const o = veri?.ozet;
  const bugunMu = iso(gun) === iso(new Date());
  const simdiSol = pencere && bugunMu && simdi > pencere.b && simdi < pencere.s
    ? `${(simdi - pencere.b) / 60000 / pencere.dk * 100}%` : null;

  return (
    <>
      <div className="sayfabas"><div className="basrow">
        <h1>Masa Çizelgesi</h1><span className="yol">Ameliyathane › Masa Çizelgesi</span>
        <div className="sag" style={{ display: 'flex', gap: 6 }}>
          <button className="d" onClick={() => git('/ameliyat')}>📋 Ameliyat Planı</button>
          <button className="d" onClick={() => git('/ameliyat-talep')}>
            ⏳ Bekleyen Talepler{o?.bekleyenTalep ? ` (${o.bekleyenTalep})` : ''}
          </button>
        </div>
      </div></div>

      <div className="cz-sayfa">
        <div className="cp-arac">
          <button className="d" onClick={() => setGun(g => { const d = new Date(g); d.setDate(d.getDate() - 1); return d })}>‹ Önceki gün</button>
          <button className="d" onClick={() => setGun(new Date())}>Bugün</button>
          <button className="d" onClick={() => setGun(g => { const d = new Date(g); d.setDate(d.getDate() + 1); return d })}>Sonraki gün ›</button>
          <b>{tarihYaz(iso(gun))}</b>
          <input type="date" value={iso(gun)} onChange={e => e.target.value && setGun(new Date(e.target.value + 'T00:00:00'))} />
          <span style={{ marginLeft: 'auto', display: 'inline-flex', gap: 6, flexWrap: 'wrap' }}>
            <input value={ara} placeholder="🔍 Hasta, hekim ya da işlem…" style={{ width: 220 }}
                   onChange={e => setAra(e.target.value)} />
            <select value={salonId ?? ''} onChange={e => setSalonId(e.target.value ? Number(e.target.value) : null)}>
              <option value="">Salon: Tümü</option>
              {veri?.salonlar.map(s => <option key={s.id} value={s.id}>{s.kod} · {s.ad}</option>)}
            </select>
            <button className="d" onClick={() => setYenile(t => t + 1)}>⟳ Tazele</button>
          </span>
        </div>

        {o && (
          <div className="cz-ozet">
            <div className="kutu"><b>Planlanan</b><span>{o.planlanan}</span></div>
            <div className="kutu ok"><b>Tamamlanan</b><span>{o.tamamlanan}</span></div>
            <div className="kutu"><b>Süren</b><span>{o.suren}</span></div>
            <div className="kutu sari"><b>Gecikmeli</b><span>{o.gecikmeli}<small>geç başlayan (15 dk+)</small></span></div>
            <div className="kutu"><b>Plan dışı</b><span>{o.planDisi}<small>acil eklenen</small></span></div>
            <div className="kutu kir"><b>Bekleyen talep</b><span>{o.bekleyenTalep}<small>planlanmamış</small></span></div>
            <div className="kutu"><b>Masa kullanımı</b><span>%{o.kullanimYuzde}<small>pencereye göre</small></span></div>
          </div>
        )}

        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="cz-ikili">
          <div className="cz-tablo">
            <div className="cz-bas">
              <div className="cz-basoda">Masa / Salon</div>
              <div className="cz-serit">
                {saatler.map((s, i) => (
                  <div key={i} className="cz-saat" style={{ left: `${i / saatler.length * 100}%`, width: `${100 / saatler.length}%` }}>
                    {s.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}
                  </div>
                ))}
              </div>
            </div>

            {(veri?.salonlar ?? []).map(s => {
              const bloklar = suzulmus.filter(a => a.salonId === s.id);
              return (
                <div className="cz-satir" key={s.id}>
                  <div className="cz-oda">
                    <b>{s.ad}</b>
                    <span>{[s.kod, s.departmanAd, s.ozellik].filter(Boolean).join(' · ')}</span>
                    {s.acilAyrilmis === 1 && <span className="rozet uyari">acile ayrılmış</span>}
                  </div>
                  <div className="cz-serit">
                    {saatler.map((_, i) => (
                      <div key={i} className="cz-cizgi" style={{ left: `${i / saatler.length * 100}%` }} />
                    ))}
                    {simdiSol && <div className="cz-simdi" style={{ left: simdiSol }} />}
                    {bloklar.map(a => {
                      const y = yerlesim(a);
                      if (!y) return null;
                      const gecikme = (a.gecikmeDk ?? 0) > 15;
                      return (
                        <div key={a.id} style={y} onClick={() => setSecili(a)}
                             className={`cz-blok ${DURUM_SINIF[a.durum] ?? ''}`
                               + (gecikme ? ' gec' : '') + (secili?.id === a.id ? ' sel' : '')}
                             title={`${a.hastaAd} · ${a.islemAd ?? ''}\n${saatYaz(a.bas)}–${saatYaz(a.bit)}`
                               + (gecikme ? `\n${a.gecikmeDk} dk geç başladı` : '')}>
                          <b>{a.islemAd || a.ameliyatNo || 'Ameliyat'}</b>
                          <span>{a.hastaAd}{a.cerrahAd ? ` · ${a.cerrahAd}` : ''} · {saatYaz(a.bas)}–{a.durum >= 4 ? saatYaz(a.bit) : ''}</span>
                          {a.planDisi === 1 && <i className="cz-bayrak">plan dışı</i>}
                        </div>
                      );
                    })}
                    {bloklar.length === 0 && <div className="cz-bos">— boş —</div>}
                  </div>
                </div>
              );
            })}

            {veri && veri.salonlar.length === 0 && (
              <div className="cz-satir"><div className="sonuk" style={{ padding: 10 }}>
                Aktif salon yok. Ameliyathane › Ayarlar › Salonlar'dan tanımlayın.
              </div></div>
            )}
          </div>

          <div className="ds-grp">
            <div className="ds-gb">{secili ? (secili.ameliyatNo || 'Ameliyat') : 'Seçili vaka'}</div>
            {secili ? (
              <div className="ds-ic">
                <div><span className="sonuk">Hasta</span> · {secili.hastaAd || '—'}</div>
                <div><span className="sonuk">İşlem</span> · {secili.islemAd || '—'}</div>
                <div><span className="sonuk">Cerrah</span> · {secili.cerrahAd || '—'}</div>
                <div><span className="sonuk">Durum</span> · {DURUM_AD[secili.durum] ?? secili.durum}
                  {secili.planDisi === 1 && <span className="rozet mavi" style={{ marginLeft: 4 }}>plan dışı</span>}</div>
                <div><span className="sonuk">Plan</span> · {saatYaz(secili.planBaslangic)}
                  {secili.planSureDk ? ` · ${secili.planSureDk} dk` : ''}</div>
                <div><span className="sonuk">Gerçek</span> · {saatYaz(secili.salonaAlma)}
                  {secili.salonaAlma
                    ? (secili.salondanCikis ?? secili.bitisZamani)
                        ? `–${saatYaz(secili.salondanCikis ?? secili.bitisZamani)}`
                        : ' · sürüyor'
                    : ''}</div>
                {secili.gecikmeDk != null && secili.gecikmeDk > 0 && (
                  <div className="rozet uyari">{secili.gecikmeDk} dk geç başladı
                    {secili.gecikmeNeden ? ` · ${secili.gecikmeNeden}` : ''}</div>)}
                {/* CERRAHİ SÜRE MASA SÜRESİNDEN AYRI: biri cerrahın işi, öteki
                    masanın işgali - aynı sayıya indirgenirse ikisi de kaybolur. */}
                {secili.kesiZamani && (
                  <div><span className="sonuk">Cerrahi</span> · {saatYaz(secili.kesiZamani)}'den
                    {' '}{Math.round(dk(secili.kesiZamani, secili.bitisZamani ?? new Date().toISOString()))} dk</div>)}
                {secili.timeoutEksik > 0 && secili.durum < 2 && (
                  <div className="rozet hata">Time-out eksik: {secili.timeoutEksik} zorunlu madde</div>)}
                {secili.durum === 8 && secili.iptalNeden && (
                  <div className="sonuk">İptal: {secili.iptalNeden}</div>)}

                <div style={{ display: 'flex', gap: 4, marginTop: 8, flexWrap: 'wrap' }}>
                  <button className="d" onClick={() => git(`/ameliyat/${secili.id}?geri=%2Fameliyat-cizelge`)}>✎ Kart</button>
                  <button className="d" onClick={() => void aksiyon('ameliyat.kontrol', secili)}>☑ Kontrol Listesi</button>
                  <button className="d" onClick={() => void aksiyon('ameliyat.fatura', secili)}>🧾 Fatura & Stok</button>
                  {yazar && secili.durum < 4 && <>
                    {!secili.salonaAlma && <button className="d" onClick={() => void aksiyon('ameliyat.salona-al', secili)}>🚪 Salona Alındı</button>}
                    {secili.salonaAlma && !secili.kesiZamani && <button className="d bir" onClick={() => void aksiyon('ameliyat.kesi', secili)}>🔪 Kesi</button>}
                    {secili.kesiZamani && !secili.bitisZamani && <button className="d onay" onClick={() => void aksiyon('ameliyat.bitis', secili)}>✅ Bitti</button>}
                    {secili.bitisZamani && !secili.salondanCikis && <button className="d" onClick={() => void aksiyon('ameliyat.cikis', secili)}>🚪 Salondan Çıktı</button>}
                  </>}
                </div>
              </div>
            ) : (
              <div className="ds-ic sonuk">
                Blok tıklayın: plan/gerçek saat, gecikme, cerrahi süre ve akış düğmeleri.
                Düğmeler liste ekranıyla aynı kuralları çalıştırır - time-out
                tamamlanmadan kesi kaydedilmez.
              </div>
            )}

            <div className="ds-gb">Okuma</div>
            <div className="ds-ic">
              <div className="cz-lej">
                <span><i className="bekliyor" />Bekliyor</span>
                <span><i className="hazirlik" />Hazırlık</span>
                <span><i className="suruyor" />Sürüyor</span>
                <span><i className="kapanis" />Kapanışta</span>
                <span><i className="bitti" />Bitti</span>
                <span><i className="iptal" />İptal</span>
                <span><i className="gec" />15 dk+ geç başladı</span>
              </div>
              <div className="sonuk" style={{ marginTop: 6 }}>
                Blok GERÇEK saatte durur: başlamış vaka salona alma–çıkış aralığını,
                başlamamış vaka planını kaplar. Masa kullanımı, gün penceresindeki
                (en erken–en geç, en az 08–18) toplam süreye göre hesaplanır.
              </div>
            </div>
          </div>
        </div>
      </div>

      <AmeliyatAcilModallari m={modal} tazele={() => setYenile(t => t + 1)} />
    </>
  );
}
