import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { DisHastaKarti as Kart, DisIslemSecenegi, DisPlanSatiri } from '../../api/uclar/dis';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { gunNokta, para, tarihSaat } from '../../bilesenler/bicim';
import {
  DIS_SIRASI, DURUM_ADLARI, Odontogram, SUT_SIRASI, disAdi, disGorunumleri,
  durumSinifi, type DisSecim,
} from '../../bilesenler/dis/Odontogram';

/**
 * DİŞ HASTA KARTI — mockup `Ekranlar/Dis Klinigi/dis_hasta_karti_v5.html`.
 *
 * Odontogram + tedavi planı TEK SEKMEDE: hekim dişe bakar, aynı ekranda planı
 * görür ve işlem ekler. Dişe/yüzeye tıkla → plan tablosunda o dişin satırları
 * üste çıkar (▸); plan satırına tıkla → şemada diş seçilir.
 *
 * "✔ Yapıldı" tek tıkla iki kayıt: satır tamamlanır, başvuruya ücret düşer,
 * odontogramda planlanan çerçeve tamamlanana döner - hepsi sunucuda
 * (`/api/dis/plan-satir/{id}/yapildi`); ekran yalnız sonucu çizer.
 *
 * Sağ panel: seçili diş bulguları · hızlı bulgu paleti · ağız özeti · plan &
 * ücret özeti (kullanıcı: ikisi de "hasta nerede" sorusunun cevabı, yan yana
 * okunuyor; mockup v5'te ücret özeti plan tablosunun altındaydı).
 */

const PLAN_DURUM: Record<number, [string, string]> = {
  1: ['Taslak', 'gri'], 2: ['Sunuldu', 'mavi'], 3: ['Onaylı', 'ok'], 4: ['Sürüyor', 'mavi'],
  5: ['Tamamlandı', 'ok'], 6: ['İptal', 'hata'], 7: ['Süresi doldu', 'uyari'],
};
const SATIR_DURUM: Record<number, [string, string]> = {
  1: ['Planlı', 'gri'], 2: ['Sürüyor', 'mavi'], 3: ['Yapıldı', 'ok'], 4: ['İptal', 'hata'], 5: ['Ertelendi', 'uyari'],
};
const LAB_ASAMA: Record<number, string> = {
  1: 'Ölçü bekliyor', 2: 'Gönderildi', 3: 'Tasarım onayı', 4: 'Üretim', 5: 'Geldi', 6: 'Prova',
  7: 'Geri gönderildi', 8: 'Teslim edildi', 9: 'İptal',
};
const LAB_IS: Record<number, string> = {
  1: 'Kron', 2: 'Köprü', 3: 'İmplant üstü', 4: 'Total protez', 5: 'Parsiyel protez',
  6: 'Ortodonti apareyi', 7: 'Gece plağı', 8: 'Diğer',
};
/** Hızlı bulgu paleti (mockup): seçili yüzeye uygular. */
const HIZLI_BULGU: { kod: number; ad: string; ik: string; tumDis?: boolean }[] = [
  { kod: 2, ad: 'Çürük', ik: '●' }, { kod: 11, ad: 'Kompozit', ik: '◐' }, { kod: 10, ad: 'Amalgam', ik: '◑' },
  { kod: 30, ad: 'Kron', ik: '♛', tumDis: true }, { kod: 20, ad: 'Kanal', ik: '┃', tumDis: true },
  { kod: 40, ad: 'İmplant', ik: '⚙', tumDis: true }, { kod: 50, ad: 'Eksik', ik: '✕', tumDis: true },
  { kod: 60, ad: 'Kırık', ik: '↯' }, { kod: 61, ad: 'Aşınma', ik: '◔' }, { kod: 0, ad: 'Sağlam', ik: '⌀', tumDis: true },
];
const rozetSinifi = (k: number) => durumSinifi(k) === 'curuk' ? 'uyari' : durumSinifi(k) === 'eksik' ? 'gri'
  : durumSinifi(k) === 'kanal' ? 'mor' : durumSinifi(k) === 'implant' ? 'ok' : k === 0 ? 'ok' : 'mavi';

type Sekme = 'odo' | 'perio' | 'gecmis' | 'lab';

export function DisHastaKarti() {
  const { hastaId: param } = useParams();
  const hastaId = Number(param ?? 0);
  const git = useNavigate();
  const { yetki } = useOturum();
  const konum = useLocation();
  // KAPAT: geldigi yere (gunluk akis state.geri verir), yoksa hasta listesine.
  // GERI ZINCIRI: plan karti -> hasta karti -> Kapat, plan kartina doner; plan
  //   karti da KENDI geldigi yere (ustGeri) donebilsin diye state ile tasinir.
  const durum = konum.state as { geri?: string; ustGeri?: string } | null;
  const geri = durum?.geri ?? '/dis-hasta';
  const ustGeri = durum?.ustGeri;
  const kapat = useCallback(() => git(geri, ustGeri ? { state: { geri: ustGeri } } : undefined), [git, geri, ustGeri]);
  // Buradan acilan generic kart/listeler (odeme plani, lab isleri, genel hasta
  //   karti) ?geri= ile bu sayfaya doner; ozel kartlar (seans, plan) state.geri alir.
  const geriParam = encodeURIComponent(konum.pathname);
  useEffect(() => {
    const f = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() };
    window.addEventListener('keydown', f);
    return () => window.removeEventListener('keydown', f);
  }, [kapat]);
  const [kart, setKart] = useState<Kart | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [secili, setSecili] = useState<DisSecim | null>(null);
  const [sekme, setSekme] = useState<Sekme>('odo');
  const [gorunum, setGorunum] = useState<'sema' | 'tablo'>('sema');
  const [katmanlar, setKatmanlar] = useState({ mevcut: true, plan: true, tamam: true });
  const [sadeceSorunlu, setSadeceSorunlu] = useState(false);
  const [planSuzgec, setPlanSuzgec] = useState<'secili' | 'tumu' | 'yapilan' | 'bekleyen'>('secili');
  const [anamnezAcik, setAnamnezAcik] = useState(false);
  const [anamnez, setAnamnez] = useState({ dentalAnamnez: '', bruksizm: false, sigara: false, hijyenDurum: '', tmeBulgu: '' });
  const [islemAra, setIslemAra] = useState<{ acik: boolean; q: string; sonuc: DisIslemSecenegi[]; iskonto: string; seans: string }>(
    { acik: false, q: '', sonuc: [], iskonto: '0', seans: '' });
  const [sut, setSut] = useState(false);
  const planYazar = yetki('dis.plan');
  const bulguYazar = yetki('dis.hasta');

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    try {
      const k = await api.disHastaKarti(hastaId);
      setKart(k); setHata(null);
      if (k.disMuayene?.dentisyon === 2) setSut(true);
    } catch (h) { setHata(hataMetni(h)) }
    finally { setYukleniyor(false) }
  }, [hastaId]);
  useEffect(() => { void yukle() }, [yukle]);

  const gorunumler = useMemo(() => disGorunumleri(kart?.odontogram ?? []), [kart]);
  const satirlar = kart?.satirlar ?? [];
  const satirlarSirali = useMemo(() => {
    let s = satirlar;
    if (planSuzgec === 'yapilan') s = s.filter(x => x.durum === 3);
    else if (planSuzgec === 'bekleyen') s = s.filter(x => x.durum === 1 || x.durum === 2 || x.durum === 5);
    if (planSuzgec === 'secili' && secili) {
      s = [...s].sort((a, b) => (a.disNo === secili.disNo ? 0 : 1) - (b.disNo === secili.disNo ? 0 : 1) || a.faz - b.faz || a.sira - b.sira);
    }
    return s;
  }, [satirlar, planSuzgec, secili]);

  // Ağız özeti: odontogram katman 1'den sayılır (DMFT: çürük · eksik · dolgu/kron).
  const ozet = useMemo(() => {
    const t = (sinif: string) => Object.entries(gorunumler)
      .filter(([, g]) => g.bulgular.some(b => durumSinifi(b.durumKod) === sinif) || (sinif === 'dolgu' && Object.values(g.yz).some(v => v === 'dolgu' || v === 'kompozit')))
      .map(([n]) => n);
    const eksik = Object.entries(gorunumler).filter(([, g]) => g.eksik).map(([n]) => n);
    const kron = Object.entries(gorunumler).filter(([, g]) => g.kron).map(([n]) => n);
    const kanal = Object.entries(gorunumler).filter(([, g]) => g.kanal).map(([n]) => n);
    const implant = Object.entries(gorunumler).filter(([, g]) => g.implant).map(([n]) => n);
    const curuk = Object.entries(gorunumler).filter(([, g]) => Object.values(g.yz).some(v => v === 'curuk')).map(([n]) => n);
    const dolgu = Object.entries(gorunumler).filter(([, g]) => Object.values(g.yz).some(v => v === 'dolgu' || v === 'kompozit')).map(([n]) => n);
    void t;
    return { eksik, kron, kanal, implant, curuk, dolgu,
             mevcut: (sut ? 20 : 32) - eksik.length,
             dmft: { d: curuk.length, m: eksik.length, f: dolgu.length + kron.length } };
  }, [gorunumler, sut]);

  const sec = (s: DisSecim) => { setSecili(s); setPlanSuzgec('secili') };

  // ---- yazma
  const bulguYaz = async (kod: number, tumDis?: boolean) => {
    if (!secili) { mesaj('Önce şemada bir diş ya da yüzey seçin.'); return }
    const yz = tumDis ? '' : secili.yz.join('');
    await guvenli(async () => {
      await api.disBulguYaz(hastaId, { disNo: secili.disNo, yuzeyler: yz, durumKod: kod, kaynak: 1 });
      await yukle();
    });
  };
  const bulguSil = async (id: number) => {
    if (!await onay('Bulgu pasifleştirilsin mi? Geçmişte kalır, şemadan düşer.')) return;
    await guvenli(async () => { await api.disBulguSil(id); await yukle(); });
  };
  const islemAraYap = async (q: string) => {
    setIslemAra(a => ({ ...a, q }));
    try {
      const y = await api.disIslemAra(q, kart?.fiyatListesi);
      setIslemAra(a => ({ ...a, sonuc: y.satirlar }));
    } catch { /* sessiz */ }
  };
  const planSatirEkle = async (h: DisIslemSecenegi, genel = false) => {
    const disNo = genel ? 0 : (secili?.disNo ?? 0);
    if (!genel && !disNo) { mesaj('Önce şemada bir diş seçin ya da "Genel işlem" kullanın.'); return }
    await guvenli(async () => {
      const y = await api.disPlanSatirEkle(hastaId, {
        // Kapanmış plana satır eklenmez: planId boş gider, sunucu yeni taslak açar.
        planId: kart?.plan && kart.plan.durum <= 4 ? kart.plan.id : null, disNo,
        yuzeyler: genel ? '' : (secili?.yz.length === 5 ? '' : secili?.yz.join('')),
        hizmetId: h.id,
        iskonto: Number(islemAra.iskonto.replace(',', '.')) || 0,
        seansSayisi: Number(islemAra.seans) || undefined,
      });
      setIslemAra({ acik: false, q: '', sonuc: [], iskonto: '0', seans: '' });
      mesaj(y.planNo ? `Yeni plan açıldı: ${y.planNo}` : 'Plan satırı eklendi.');
      await yukle();
    });
  };
  const yapildi = async (s: DisPlanSatiri) => {
    if (!await onay(`${s.disNo ? `Diş ${s.disNo} · ` : ''}${s.islem} yapıldı olarak işaretlensin mi? Başvuruya ücret satırı düşer.`)) return;
    await guvenli(async () => {
      const y = await api.disPlanSatirYapildi(s.id);
      mesaj((y.ucret > 0 ? `Ücret satırı yazıldı: ${para.format(y.ucret)}. ` : '') + (y.uyari ?? ''));
      await yukle();
    });
  };
  const satirIptal = async (s: DisPlanSatiri) => {
    if (!await onay(`${s.islem} satırı iptal edilsin mi?`)) return;
    await guvenli(async () => { await api.disPlanSatirIptal(s.id); await yukle(); });
  };
  const anamnezKaydet = async () => {
    await guvenli(async () => { await api.disMuayeneGuncelle(hastaId, anamnez); setAnamnezAcik(false); await yukle(); });
  };
  const planSun = async () => {
    if (!kart?.plan) return;
    await guvenli(async () => { await api.disPlanSun(kart.plan!.id); mesaj('Plan hastaya sunuldu.'); await yukle(); });
  };
  const planOnayla = async () => {
    if (!kart?.plan) return;
    if (!await onay('Hasta onayı alındı mı? Onaylı satır fiyatı değişmez.')) return;
    await guvenli(async () => { await api.disPlanOnayla(kart.plan!.id); mesaj('Plan onaylandı.'); await yukle(); });
  };
  const seansAc = async () => {
    await guvenli(async () => {
      const y = await api.disSeansAc({ hastaId, planId: kart?.plan?.id ?? null });
      if (y.basvuruAcildi) mesaj(`Başvuru ${y.basvuruNo} açıldı (ödeyen: ${y.odeyen})${y.provizyonBekliyor ? ' - Medula provizyonu bekliyor' : ''}; seans başvuruya bağlandı.`);
      // Seans karti kapaninca BURAYA doner (prensip: ekran nereden acildiysa oraya).
      git(`/dis-seans/${y.id}`, { state: { geri: konum.pathname, ustGeri: geri } });
    });
  };

  const Perde = ({ children }: { children: ReactNode }) => (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">🦷 Diş Hasta Kartı<span className="kapt">Esc ile kapanır</span>
          <button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button></div>
        <div className="kagov">{children}</div>
      </div>
    </div>
  );
  if (hata) return <Perde><div className="hata-kutusu">{hata}</div></Perde>;
  if (!kart) return <Perde><span className="sonuk">Yükleniyor…</span></Perde>;

  const h = kart.hasta, plan = kart.plan;
  const seciliG = secili ? gorunumler[secili.disNo] : undefined;
  const bakiye = plan ? plan.yapilan - plan.tahsil : 0;
  const ilerleme = plan && plan.satirSayisi > 0 ? Math.round(100 * plan.yapilanSayisi / plan.satirSayisi) : 0;
  const sira = sut ? SUT_SIRASI : DIS_SIRASI;

  return (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">
          <span>🦷 {h.unvan}{h.yas != null ? ` · ${h.yas}` : ''}</span>
          <span className="ds-kabas-yol">Diş › Hasta Kartı</span>
          {plan && <span className={`rozet ${PLAN_DURUM[plan.durum]?.[1] ?? 'gri'}`}>{plan.planNo} · {PLAN_DURUM[plan.durum]?.[0]}</span>}
          {bakiye > 0 && <span className="rozet hata">bakiye {para.format(bakiye)}</span>}
          {yukleniyor && <span className="ds-kabas-yol">yenileniyor…</span>}
          <span className="kapt">Esc ile kapanır</span>
          <button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button>
        </div>
        <div className="kagov ds-kagov">
        <div className="ds-arac ds-kart-arac">
          {yetki('dis.seans') && <button className="d bir" onClick={() => void seansAc()}>🪑 Muayene / Seans Aç</button>}
          {planYazar && plan?.durum === 1 && <button className="d" onClick={() => void planSun()}>📤 Proforma / Sun</button>}
          {planYazar && plan && (plan.durum === 1 || plan.durum === 2) && <button className="d onay" onClick={() => void planOnayla()}>✍ Hasta Onayı</button>}
          {plan && <button className="d" onClick={() => git(`/dis-plan/${plan.id}`, { state: { geri: konum.pathname, ustGeri: geri } })}>📋 Plan Kartı</button>}
          {plan?.odemePlaniId
            ? <button className="d" onClick={() => git(`/dis-odeme-plani/${plan.odemePlaniId}?geri=${geriParam}`)}>💳 Ödeme Planı</button>
            // Odeme plani YOKSA yeni kart acilir (kullanici): plan ve toplam on dolu,
            //   kaydet/kapat odontograma doner - liste ekranina dusurmek isi yarim birakiyordu.
            : plan && yetki('dis.odeme') && <button className="d" onClick={() => git(`/dis-odeme-plani/yeni?planId=${plan.id}&toplam=${plan.net}&geri=${geriParam}`)}>💳 Ödeme Planı</button>}
          {/* Lab isi YOKSA yeni is emri karti acilir (kullanici): hasta on dolu,
              kaydet/kapat odontograma doner. Varsa hastanin lab listesi. */}
          <button className="d" onClick={() => git(`/dis-lab-isemri/yeni?hastaId=${hastaId}&hastaAd=${encodeURIComponent(kart?.hasta.unvan ?? '')}&geri=${geriParam}`)}>🧪 Lab İş Emri</button>
          <button className="d" onClick={() => git(`/hasta/${hastaId}?geri=${geriParam}`)}>↗ Genel Hasta Kartı</button>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
          <button className="d ds-sp" onClick={kapat}>✖ Kapat</button>
        </div>

      <div className="ds-sahne">
        {/* ------------------------------------------------------ üst bilgi */}
        <div className="ds-hdr">
          <div><label>Hasta</label><div className="ds-inp big">{h.unvan}{h.yas != null ? ` · ${h.yas}` : ''}{h.cepTel ? ` · ${h.cepTel}` : ''}</div></div>
          {/* TIBBI UYARILAR (kullanici): alerji (kirmizi) + kronik tani (turuncu) +
              surekli ilac (mavi) - Tibbi Ozet kaynaklari. Genel muayene
              kullanilmayan kurulumda giris buradan: "+" dugmeleri hasta on dolu
              kayit karti acar, kapatinca odontograma doner. */}
          <div><label>Tıbbi uyarılar</label><div className="ds-inp">
            {h.alerji && h.alerji.split(', ').map(a => <span key={'a' + a} className="rozet hata" title="Alerji">{a}</span>)}
            {h.kronik && h.kronik.split(', ').map(a => <span key={'k' + a} className="rozet uyari" title="Kronik tanı">{a}</span>)}
            {h.ilac && h.ilac.split(', ').map(a => <span key={'i' + a} className="rozet mavi" title="Sürekli ilaç">💊 {a}</span>)}
            {!h.alerji && !h.kronik && !h.ilac && <span className="sonuk">uyarı yok</span>}
            {yetki('muayene') && <span className="ds-uyari-ekle">
              {([['hasta-alerji', 'alerji'], ['hasta-kronik', 'kronik'], ['hasta-ilac', 'ilaç']] as [string, string][]).map(([k, ad]) =>
                <button key={k} className="d mini" title={`${ad} kaydı ekle`}
                  onClick={() => git(`/${k}/yeni?hastaId=${hastaId}&hastaAd=${encodeURIComponent(h.unvan)}&geri=${geriParam}`)}>+{ad}</button>)}
            </span>}
          </div></div>
          {/* DENTAL ANAMNEZ (kullanici: "nereden girilecek"): dis_muayene icin ayri
              kart yok - burada ✎ ile duzenlenir (son dis muayene satiri, yoksa acilir). */}
          <div><label>Dental anamnez</label><div className="ds-inp">{h.dentalAnamnez || <span className="sonuk">—</span>}
            {kart.disMuayene?.bruksizm && <span className="rozet uyari">bruksizm</span>}
            {kart.disMuayene?.sigara && <span className="rozet uyari">sigara</span>}
            {kart.disMuayene?.hijyenDurum && <span className="rozet gri">hijyen: {kart.disMuayene.hijyenDurum}</span>}
            {yetki('dis.hasta') && <span className="ds-uyari-ekle"><button className="d mini" title="Dental anamnezi düzenle"
              onClick={() => { setAnamnez({ dentalAnamnez: h.dentalAnamnez, bruksizm: !!kart.disMuayene?.bruksizm, sigara: !!kart.disMuayene?.sigara, hijyenDurum: kart.disMuayene?.hijyenDurum ?? '', tmeBulgu: kart.disMuayene?.tmeBulgu ?? '' }); setAnamnezAcik(a => !a) }}>✎</button></span>}
          </div>
          {anamnezAcik && (
            <div className="ds-anamnez">
              <textarea rows={3} style={{ width: '100%' }} placeholder="Dental anamnez: şikayet, geçmiş tedaviler, alışkanlıklar…" value={anamnez.dentalAnamnez} onChange={e => setAnamnez(a => ({ ...a, dentalAnamnez: e.target.value }))} />
              <div className="ds-arac" style={{ padding: '4px 0 0', background: 'transparent', borderBottom: 'none' }}>
                <label><input type="checkbox" checked={anamnez.bruksizm} onChange={e => setAnamnez(a => ({ ...a, bruksizm: e.target.checked }))} /> bruksizm</label>
                <label><input type="checkbox" checked={anamnez.sigara} onChange={e => setAnamnez(a => ({ ...a, sigara: e.target.checked }))} /> sigara</label>
                <label className="sonuk">hijyen <input value={anamnez.hijyenDurum} placeholder="iyi / orta / kötü" style={{ width: 90 }} onChange={e => setAnamnez(a => ({ ...a, hijyenDurum: e.target.value }))} /></label>
                <label className="sonuk">TME <input value={anamnez.tmeBulgu} placeholder="klik / ağrı / —" style={{ width: 110 }} onChange={e => setAnamnez(a => ({ ...a, tmeBulgu: e.target.value }))} /></label>
                <span className="ds-sp">
                  <button className="d onay" onClick={() => void anamnezKaydet()}>💾 Kaydet</button>
                  <button className="d" onClick={() => setAnamnezAcik(false)}>Vazgeç</button>
                </span>
              </div>
            </div>
          )}
          </div>
          <div><label>Son ziyaret / hekim</label><div className="ds-inp">
            {h.sonMuayene ? `${gunNokta(h.sonMuayene)}${h.sonHekim ? ' · ' + h.sonHekim : ''}` : <span className="sonuk">muayene yok</span>}
            {h.seansSayisi > 0 && <span className="sonuk"> · {h.seansSayisi} seans</span>}
          </div></div>
        </div>

        <div className="ka-sekmeler">
          {([['odo', '🦷 Odontogram & Tedavi Planı'], ['perio', 'Periodontal Kayıt'], ['gecmis', 'Tedavi Geçmişi'], ['lab', 'Protez / Lab']] as [Sekme, string][])
            .map(([k, ad]) => <div key={k} className={`ka-sekme${sekme === k ? ' on' : ''}`} onClick={() => setSekme(k)}>{ad}</div>)}
        </div>

        {/* ============================================ ODONTOGRAM + PLAN */}
        {sekme === 'odo' && (
          <div className="ds-odo-alan">
            <div className="ds-sol">
              <div className="ds-arac">
                <span className="ds-gorunum">
                  <span className={gorunum === 'sema' ? 'on' : ''} onClick={() => setGorunum('sema')}>🦷 Anatomik şema</span>
                  <span className={gorunum === 'tablo' ? 'on' : ''} onClick={() => setGorunum('tablo')}>☰ Diş tablosu</span>
                </span>
                <span className="ds-sep" />
                <span className={`cip${!sut ? ' on' : ''}`} onClick={() => setSut(false)}>Daimi dişler</span>
                <span className={`cip${sut ? ' on' : ''}`} onClick={() => setSut(true)}>Süt dişleri</span>
                <span className="ds-sep" />
                <span className={`cip${katmanlar.mevcut ? ' on' : ''}`} onClick={() => setKatmanlar(k => ({ ...k, mevcut: !k.mevcut }))}>Mevcut durum</span>
                <span className={`cip${katmanlar.plan ? ' on' : ''}`} onClick={() => setKatmanlar(k => ({ ...k, plan: !k.plan }))}>Planlanan</span>
                <span className={`cip${katmanlar.tamam ? ' on' : ''}`} onClick={() => setKatmanlar(k => ({ ...k, tamam: !k.tamam }))}>Tamamlanan</span>
                <span className="ds-sep" />
                <span className={`cip${sadeceSorunlu ? ' on' : ''}`} onClick={() => setSadeceSorunlu(s => !s)}>⚠ Yalnız sorunlu dişler</span>
                <span className="ds-sp sonuk">Dişe/yüzeye tıkla → plan satırları o dişe süzülür. Kesikli kırmızı = planlanan, yeşil = tamamlanan.</span>
              </div>

              {gorunum === 'sema' ? (
                <>
                  <Odontogram satirlar={kart.odontogram} secili={secili} onSec={sec} katmanlar={katmanlar} dentisyon={sut ? 2 : 1} />
                  <div className="ds-lej">
                    <span><i style={{ background: 'rgba(96,54,30,.78)' }} /> Çürük</span>
                    <span><i style={{ background: '#9aa7b5' }} /> Amalgam</span>
                    <span><i style={{ background: 'rgba(110,160,220,.55)' }} /> Kompozit</span>
                    <span><i style={{ background: '#d9a12b' }} /> Kron / köprü</span>
                    <span><i style={{ background: '#fff', borderColor: '#b3261e', borderWidth: 2 }} /> Kanal</span>
                    <span><i style={{ background: '#8c96a0' }} /> İmplant</span>
                    <span><i style={{ background: '#fff', border: '1px dashed #c7ced6' }} /> Eksik</span>
                    <span><i style={{ border: '1.5px dashed #b3261e' }} /> Planlanan</span>
                    <span><i style={{ border: '1.5px solid #2e7d46' }} /> Tamamlanan</span>
                  </div>
                </>
              ) : (
                <div className="ds-dg"><table>
                  <thead><tr><th className="orta">Diş</th><th>Ad</th><th>Mevcut durum</th><th>Planlanan</th><th>Tamamlanan</th><th className="orta">Son bulgu</th><th className="orta">Perio (cep max)</th></tr></thead>
                  <tbody>
                    {sira.filter(no => !sadeceSorunlu || gorunumler[no]).map(no => {
                      const g = gorunumler[no];
                      const planS = satirlar.filter(s => s.disNo === no && s.durum !== 3 && s.durum !== 4);
                      const tamamS = satirlar.filter(s => s.disNo === no && s.durum === 3);
                      const cep = kart.perioCep.find(c => c.disNo === no)?.cep;
                      return (
                        <tr key={no} className={`${secili?.disNo === no ? 'sel' : ''}${g?.eksik ? ' eksik' : ''}`}
                            onClick={() => sec({ disNo: no, yz: ['M', 'D', 'O', 'V', 'L'] })}>
                          <td className="orta"><b>{no}</b></td>
                          <td>{disAdi(no)}</td>
                          <td>{g?.bulgular.length
                            ? g.bulgular.map(b => <span key={b.id} className={`rozet ${rozetSinifi(b.durumKod)}`}>{DURUM_ADLARI[b.durumKod] ?? b.durumKod}{b.yuzeyler ? ' ' + b.yuzeyler : ''}</span>)
                            : <span className="rozet ok">sağlam</span>}</td>
                          <td>{planS.map(s => <span key={s.id} className="rozet hata">{s.islem}{s.yuzeyler ? ' ' + s.yuzeyler : ''}</span>)}</td>
                          <td>{tamamS.map(s => <span key={s.id} className="rozet ok">{s.islem}</span>)}</td>
                          <td className="orta sonuk">{g?.bulgular[0] ? gunNokta(g.bulgular[0].tarih) : '—'}</td>
                          <td className={`orta${cep && cep >= 5 ? ' ds-kir' : ''}`}>{cep != null ? `${cep} mm` : '—'}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table></div>
              )}

              {/* ------------------------------------------- tedavi planı */}
              <div className="ds-grp ds-grp-ic">
                <div className="ds-gb">📋 Tedavi planı {plan ? <>{plan.durum >= 5 && <span className="sonuk">(kapanmış plan; yeni işlem yeni plan açar) </span>}<b>{plan.planNo}</b> · {plan.hekim || '—'} · {gunNokta(plan.tarih)} <span className={`rozet ${PLAN_DURUM[plan.durum]?.[1] ?? 'gri'}`}>{PLAN_DURUM[plan.durum]?.[0]}</span></> : <span className="sonuk">henüz plan yok - ilk işlem eklenince taslak plan açılır</span>}
                  <span className="ds-sp">
                    <span className={`cip${planSuzgec === 'secili' ? ' on' : ''}`} onClick={() => setPlanSuzgec('secili')}>▸ seçili diş üstte</span>
                    <span className={`cip${planSuzgec === 'tumu' ? ' on' : ''}`} onClick={() => setPlanSuzgec('tumu')}>Tümü</span>
                    <span className={`cip${planSuzgec === 'yapilan' ? ' on' : ''}`} onClick={() => setPlanSuzgec('yapilan')}>Yapılanlar</span>
                    <span className={`cip${planSuzgec === 'bekleyen' ? ' on' : ''}`} onClick={() => setPlanSuzgec('bekleyen')}>Bekleyenler</span>
                    {plan?.oncekiPlanNo && <span className="sonuk"> · önceki plan {plan.oncekiPlanNo} (tamamlandı)</span>}
                  </span>
                </div>
                <div className="ds-dg"><table className="ds-plan">
                  <thead><tr><th className="orta">#</th><th className="orta">Diş</th><th>İşlem</th><th className="orta">Yüzey</th><th className="orta">Seans</th><th className="sag">Ücret</th><th className="sag">İnd.</th><th className="sag">Net</th><th className="orta">Tarih</th><th className="orta">Durum</th><th /></tr></thead>
                  <tbody>
                    {satirlarSirali.map(s => {
                      const secMi = secili?.disNo === s.disNo && s.disNo > 0;
                      return (
                        <tr key={s.id} className={secMi ? 'dis-sec' : s.durum === 4 ? 'soluk' : ''}
                            onClick={() => s.disNo && sec({ disNo: s.disNo, yz: s.yuzeyler ? s.yuzeyler.split('') : ['M', 'D', 'O', 'V', 'L'] })}>
                          <td className="orta sonuk">{s.sira}</td>
                          <td className="orta"><b>{s.disNo || (s.disNolar || '—')}</b></td>
                          <td>{secMi ? '▸ ' : ''}{s.islem}{s.labGerekir && <span className="rozet uyari" style={{ marginLeft: 4 }}>{s.labIsemriId ? 'lab' : 'lab gerek'}</span>}</td>
                          <td className="orta">{s.yuzeyler || (s.disNo ? 'tüm' : '—')}</td>
                          <td className="orta">{s.yapilanSeans}/{s.seansSayisi}</td>
                          <td className="sag">{para.format(s.listeFiyat)}</td>
                          <td className="sag">{s.iskonto ? '−' + para.format(s.iskonto) : ''}</td>
                          <td className="sag">{para.format(s.net)}</td>
                          <td className="orta">{s.tamamlanma ? gunNokta(s.tamamlanma) : s.randevu ? tarihSaat(s.randevu) : s.ilkSeans ? gunNokta(s.ilkSeans) : '—'}</td>
                          <td className="orta"><span className={`rozet ${SATIR_DURUM[s.durum]?.[1] ?? 'gri'}`}>{SATIR_DURUM[s.durum]?.[0]}</span></td>
                          <td className="orta ds-satir-arac">
                            {planYazar && s.durum < 3 && <button className="d" onClick={e => { e.stopPropagation(); void yapildi(s) }}>✔ Yapıldı</button>}
                            {planYazar && s.durum < 3 && <button className="d" title="İptal" onClick={e => { e.stopPropagation(); void satirIptal(s) }}>✕</button>}
                          </td>
                        </tr>
                      );
                    })}
                    {satirlar.length > 0 && (
                      <tr className="grup"><td colSpan={5}>TOPLAM · {satirlar.filter(s => s.durum !== 4).length} işlem</td>
                        <td className="sag">{para.format(plan?.toplam ?? 0)}</td><td className="sag">−{para.format(plan?.indirim ?? 0)}</td><td className="sag">{para.format(plan?.net ?? 0)}</td><td colSpan={3} /></tr>
                    )}
                    {satirlar.length === 0 && <tr><td colSpan={11} className="sonuk">Plan satırı yok.</td></tr>}
                  </tbody>
                </table></div>

                {planYazar && (
                  <div className="ds-arac" style={{ borderTop: '1px solid var(--cizgi2)' }}>
                    <button className="d bir" onClick={() => { if (!secili) { mesaj('Önce şemada bir diş seçin.'); return } setIslemAra(a => ({ ...a, acik: true })); void islemAraYap('') }}>
                      ＋ Seçili dişe işlem ekle{secili ? ` (${secili.disNo}${secili.yz.length < 5 ? ' ' + secili.yz.join('') : ''})` : ''}
                    </button>
                    <button className="d" onClick={() => { setSecili(null); setIslemAra(a => ({ ...a, acik: true })); void islemAraYap('') }}>＋ Genel işlem</button>
                    {plan && <button className="d" onClick={() => window.print()}>🖨 Hasta imzalı plan</button>}
                    <span className="ds-sp sonuk">Plan satırı = başvuru satırı adayı; "Yapıldı" işaretlenince başvuruya düşer. Tahsilat kasa modülüyle.</span>
                  </div>
                )}

                {islemAra.acik && (
                  <div className="ds-islem-ara">
                    <div className="ds-arac">
                      <b>{secili ? `Diş ${secili.disNo}${secili.yz.length < 5 ? ' · ' + secili.yz.join('') : ''}` : 'Genel işlem'}</b>
                      <input autoFocus placeholder="İşlem ara (ad / kod)…" value={islemAra.q} onChange={e => void islemAraYap(e.target.value)} style={{ minWidth: 260 }} />
                      <label className="sonuk">İnd. <input value={islemAra.iskonto} onChange={e => setIslemAra(a => ({ ...a, iskonto: e.target.value }))} style={{ width: 70 }} /></label>
                      <label className="sonuk">Seans <input value={islemAra.seans} placeholder="hizmetten" onChange={e => setIslemAra(a => ({ ...a, seans: e.target.value }))} style={{ width: 70 }} /></label>
                      <button className="d" onClick={() => setIslemAra(a => ({ ...a, acik: false }))}>Kapat</button>
                    </div>
                    <div className="ds-dg" style={{ maxHeight: 220, overflowY: 'auto' }}><table>
                      <thead><tr><th>Kod</th><th>İşlem</th><th className="sag">Fiyat</th><th className="orta">Seans</th><th className="orta">Lab</th><th /></tr></thead>
                      <tbody>
                        {islemAra.sonuc.map(x => (
                          <tr key={x.id}>
                            <td className="sonuk">{x.kod}</td><td>{x.ad}</td>
                            <td className="sag">{para.format(x.fiyat)}</td>
                            <td className="orta">{x.standartSeans}</td>
                            <td className="orta">{x.labGerekir ? 'lab' : ''}</td>
                            <td><button className="d onay" onClick={() => void planSatirEkle(x, !secili)}>Ekle</button></td>
                          </tr>
                        ))}
                        {islemAra.sonuc.length === 0 && <tr><td colSpan={6} className="sonuk">Diş işlemi bulunamadı - hizmet kartında "Diş işlemi" işareti gerekir.</td></tr>}
                      </tbody>
                    </table></div>
                  </div>
                )}

              </div>
            </div>

            {/* ----------------------------------------------- sağ panel */}
            <div className="ds-sag">
              <div className="ds-grp">
                <div className="ds-gb">Seçili diş: <b>{secili ? `${secili.disNo} · ${disAdi(secili.disNo)}` : '—'}</b>
                  <span className="ds-sp sonuk">{secili && secili.yz.length < 5 ? `yüzey: ${secili.yz.join(', ')}` : secili ? 'tüm diş' : 'şemadan seçin'}</span></div>
                <div className="ds-dg"><table>
                  <thead><tr><th>Durum</th><th className="orta">Yüzey</th><th className="orta">Tarih</th><th>Kaynak</th><th /></tr></thead>
                  <tbody>
                    {(seciliG?.bulgular ?? []).map(b => (
                      <tr key={b.id}>
                        <td><span className={`rozet ${rozetSinifi(b.durumKod)}`}>{DURUM_ADLARI[b.durumKod] ?? b.durumKod}</span></td>
                        <td className="orta">{b.yuzeyler || 'tüm'}</td>
                        <td className="orta">{gunNokta(b.tarih)}</td>
                        <td className="sonuk">{['', 'Muayene', 'RVG/pano', 'Hasta beyanı', 'Dış kayıt', 'Seans'][b.kaynak] ?? ''}{b.notMetin ? ' · ' + b.notMetin : ''}</td>
                        <td>{bulguYazar && <button className="d" title="Pasifleştir" onClick={() => void bulguSil(b.id)}>✕</button>}</td>
                      </tr>
                    ))}
                    {satirlar.filter(s => secili && s.disNo === secili.disNo && s.durum !== 4).map(s => (
                      <tr key={'p' + s.id}>
                        <td><span className={`rozet ${s.durum === 3 ? 'ok' : 'hata'}`}>{s.durum === 3 ? 'Yapıldı' : 'Plan'}: {s.islem}</span></td>
                        <td className="orta">{s.yuzeyler || 'tüm'}</td>
                        <td className="orta">{s.tamamlanma ? gunNokta(s.tamamlanma) : '—'}</td>
                        <td className="sonuk">{plan?.planNo}</td><td />
                      </tr>
                    ))}
                    {secili && !seciliG?.bulgular.length && !satirlar.some(s => s.disNo === secili.disNo && s.durum !== 4)
                      && <tr><td colSpan={5} className="sonuk">Kayıt yok - sağlam.</td></tr>}
                  </tbody>
                </table></div>
              </div>

              {bulguYazar && (
                <div className="ds-grp">
                  <div className="ds-gb">Hızlı bulgu <span className="ds-sp sonuk">seçili yüzeye uygular</span></div>
                  <div className="ds-palet">
                    {HIZLI_BULGU.map(b => <span key={b.kod} className="cip" onClick={() => void bulguYaz(b.kod, b.tumDis)}>{b.ik} {b.ad}</span>)}
                  </div>
                </div>
              )}

              <div className="ds-grp">
                <div className="ds-gb">Ağız özeti</div>
                <div className="ds-ic">
                  <div><b>Mevcut diş: {ozet.mevcut}</b> · eksik: {ozet.eksik.join(', ') || '—'} · dolgu: {ozet.dolgu.join(', ') || '—'} · kron: {ozet.kron.join(', ') || '—'} · kanal: {ozet.kanal.join(', ') || '—'} · implant: {ozet.implant.join(', ') || '—'} · çürük: {ozet.curuk.join(', ') || '—'}</div>
                  <div style={{ marginTop: 4 }}><b>DMFT: {ozet.dmft.d + ozet.dmft.m + ozet.dmft.f}</b> (D {ozet.dmft.d} · M {ozet.dmft.m} · F {ozet.dmft.f})
                    {kart.disMuayene && <> · oklüzyon: {['—', 'Angle I', 'Angle II', 'Angle III'][kart.disMuayene.okluzyonSinif] ?? '—'}{kart.disMuayene.tmeBulgu ? ` · TME: ${kart.disMuayene.tmeBulgu}` : ''}</>}
                  </div>
                  {kart.perio && <div className="sonuk" style={{ marginTop: 4 }}>Son periodontal kayıt {gunNokta(kart.perio.tarih)}{kart.perio.plakIndeksi != null ? ` · PI %${kart.perio.plakIndeksi}` : ''}{kart.perio.bopOran != null ? ` · kanama %${kart.perio.bopOran}` : ''} · cep ≥5 mm: {kart.perio.cep5Sayisi} bölge{kart.perio.evre ? ` · evre ${kart.perio.evre}${kart.perio.derece}` : ''}</div>}
                </div>
              </div>

                {/* PLAN & ÜCRET ÖZETİ AĞIZ ÖZETİNİN ALTINDA (kullanıcı): iki özet de
                  "hasta nerede" sorusunun cevabı - biri ağzın, öteki paranın
                  durumu. Plan tablosunun altındayken uzun planlarda ekranın
                  dibine kayıyor, hekim rakamları görmek için kaydırıyordu. */}
              {plan && (
                <div className="ds-plan-alt">
                  <div className="ds-gb ds-gb-duz">Plan &amp; ücret özeti <span className="ds-sp sonuk">{plan.proformaNo || plan.planNo}{plan.gecerlilikBitis ? ` · geçerlilik ${gunNokta(plan.gecerlilikBitis)}` : ''}</span></div>
                  <div className="ds-ozet6">
                    <div><span>Toplam</span><b>{para.format(plan.toplam)}</b></div>
                    <div><span>İndirim</span><b>−{para.format(plan.indirim)}</b></div>
                    <div><span>Net</span><b>{para.format(plan.net)}</b></div>
                    <div><span>Yapılan</span><b>{para.format(plan.yapilan)}</b></div>
                    <div><span>Tahsil</span><b>{para.format(plan.tahsil)}</b></div>
                    <div><span>Bakiye (yapılan−tahsil)</span><b className={bakiye > 0 ? 'ds-kir' : ''}>{para.format(bakiye)}</b></div>
                  </div>
                  <div className="ds-bar"><i style={{ width: `${ilerleme}%` }} /></div>
                  <div className="sonuk" style={{ padding: '4px 10px 8px' }}>
                    İlerleme {plan.yapilanSayisi} / {plan.satirSayisi} işlem
                    {(() => { const n = satirlar.find(s => s.durum === 1 || s.durum === 2); return n ? ` · sonraki: ${n.disNo ? n.disNo + ' ' : ''}${n.islem}${n.randevu ? ' (' + tarihSaat(n.randevu) + ')' : ''}` : '' })()}
                    {plan.odemePlaniId ? <> · <a href="#" onClick={e => { e.preventDefault(); git(`/dis-odeme-plani/${plan.odemePlaniId}`) }}>💳 Ödeme planı</a></> : ''}
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* ============================================ PERİODONTAL */}
        {sekme === 'perio' && (
          <div className="ds-grp" style={{ margin: 10 }}>
            <div className="ds-gb">Periodontal kayıt {kart.perio ? <span className="sonuk">· son kayıt {gunNokta(kart.perio.tarih)}</span> : <span className="sonuk">· kayıt yok</span>}</div>
            {kart.perio ? (
              <>
                <div className="ds-ozet6" style={{ gridTemplateColumns: 'repeat(5,1fr)' }}>
                  <div><span>Plak indeksi</span><b>{kart.perio.plakIndeksi != null ? `%${kart.perio.plakIndeksi}` : '—'}</b></div>
                  <div><span>Kanama (BOP)</span><b>{kart.perio.bopOran != null ? `%${kart.perio.bopOran}` : '—'}</b></div>
                  <div><span>Cep ≥ 5 mm</span><b className={kart.perio.cep5Sayisi > 0 ? 'ds-kir' : ''}>{kart.perio.cep5Sayisi}</b></div>
                  <div><span>Ortalama CAL</span><b>{kart.perio.ortCal != null ? `${kart.perio.ortCal} mm` : '—'}</b></div>
                  <div><span>Evre / derece</span><b>{kart.perio.evre ? `${kart.perio.evre}${kart.perio.derece}` : '—'}</b></div>
                </div>
                <div className="ds-dg"><table><thead><tr><th className="orta">Diş</th><th className="orta">En derin cep</th></tr></thead>
                  <tbody>{kart.perioCep.map(c => <tr key={c.disNo}><td className="orta">{c.disNo}</td><td className={`orta${c.cep >= 5 ? ' ds-kir' : ''}`}>{c.cep} mm</td></tr>)}</tbody></table></div>
              </>
            ) : <div className="ds-ic sonuk">6 nokta cep ölçümü ekranı sonraki sürümde; kayıt <code>dis_periodontal</code> / <code>dis_periodontal_olcum</code> tablolarına yazılır.</div>}
          </div>
        )}

        {/* ============================================ GEÇMİŞ */}
        {sekme === 'gecmis' && (
          <div className="ds-grp" style={{ margin: 10 }}>
            <div className="ds-gb">Tedavi geçmişi <span className="ds-sp sonuk">seans işlemleri, en yeni üstte</span></div>
            <div className="ds-dg"><table>
              <thead><tr><th className="orta">Tarih</th><th>Hekim</th><th className="orta">Diş</th><th>İşlem</th><th className="orta">Seans</th><th className="sag">Ücret</th><th className="orta">Plan</th><th className="orta">Durum</th></tr></thead>
              <tbody>
                {kart.gecmis.map(g => (
                  <tr key={g.id}>
                    <td className="orta">{tarihSaat(g.tarih)}</td><td>{g.hekim}</td>
                    <td className="orta">{g.disNo || '—'}{g.yuzeyler ? ' ' + g.yuzeyler : ''}</td><td>{g.islem}</td>
                    <td className="orta">{g.seansNo}/{g.seansSayisi}</td>
                    <td className="sag">{g.ucret ? para.format(g.ucret) : ''}</td>
                    <td className="orta sonuk">{g.planNo}</td>
                    <td className="orta"><span className={`rozet ${g.tamamlandi ? 'ok' : 'mavi'}`}>{g.tamamlandi ? 'Yapıldı' : 'Sürüyor'}</span></td>
                  </tr>
                ))}
                {kart.gecmis.length === 0 && <tr><td colSpan={8} className="sonuk">Seans kaydı yok.</td></tr>}
              </tbody>
            </table></div>
          </div>
        )}

        {/* ============================================ LAB */}
        {sekme === 'lab' && (
          <div className="ds-grp" style={{ margin: 10 }}>
            <div className="ds-gb">Protez / lab işleri <span className="ds-sp"><button className="d" onClick={() => git(`/dis-lab-isemri?hastaId=${hastaId}`)}>🧪 İş emirleri</button></span></div>
            <div className="ds-dg"><table>
              <thead><tr><th>İş emri</th><th>Laboratuvar</th><th className="orta">Diş</th><th>İş</th><th>Malzeme / renk</th><th className="orta">Gönderim</th><th className="orta">Beklenen</th><th className="orta">Aşama</th><th className="sag">Lab maliyeti</th></tr></thead>
              <tbody>
                {kart.labIsleri.map(l => (
                  <tr key={l.id} onDoubleClick={() => git(`/dis-lab-isemri/${l.id}`)}>
                    <td>{l.isemriNo}</td><td>{l.lab}</td><td className="orta">{l.disNolar}</td><td>{LAB_IS[l.isTuru]}</td>
                    <td>{l.malzeme}{l.renk ? ' · ' + l.renk : ''}</td>
                    <td className="orta">{l.gonderim ? gunNokta(l.gonderim) : '—'}</td>
                    <td className="orta">{l.beklenen ? gunNokta(l.beklenen) : '—'}</td>
                    <td className="orta"><span className={`rozet ${l.asama === 8 ? 'ok' : l.asama >= 5 ? 'uyari' : 'mavi'}`}>{LAB_ASAMA[l.asama]}</span></td>
                    <td className="sag">{para.format(l.labFiyat)}</td>
                  </tr>
                ))}
                {kart.labIsleri.length === 0 && <tr><td colSpan={9} className="sonuk">Lab işi yok.</td></tr>}
              </tbody>
            </table></div>
          </div>
        )}
      </div>
        </div>
      </div>
    </div>
  );
}
