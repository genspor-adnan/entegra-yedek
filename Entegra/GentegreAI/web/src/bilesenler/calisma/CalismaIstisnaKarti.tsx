import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CalismaIstisnaBaglam } from '../../api/uclar/ayar';
import { Modal } from '../Modal';
import { guvenli, mesaj, onay } from '../mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { GUN_AD, Grp, SLOTLAR, bugunIso, dk, gun10, isoGun, metin, sayi, tarihSaat } from './calismaOrtak';

/**
 * İZİN & İSTİSNA KARTI — mockup `Ekranlar/Randevu/izin_istisna_karti.html`.
 *
 * İstisna şablonu değiştirmeden planı belirli tarihler için EZER. Tür büyük
 * düğmelerle seçilir ve formu belirler: İzin / Kongre / Kapalı gün boyu
 * kapatır (saat alanları pasif); Saat değişikliği o günlerin bloğunu
 * yenisiyle değiştirir; Ek mesai yeni blok ekler (saat ve kanal zorunlu).
 * Alt bölüm planın o haftayı nasıl göreceğini, sağ panel ETKİLENEN
 * RANDEVULARI gösterir: onaydan önce toplu aktarma / kaydırma / SMS / iptal.
 * Onay akışı Bekliyor → Onaylı; yalnız onaylı istisna takvimi kapatır.
 * İK'dan onaylanan izin burada girilmez, salt okunur listelenir.
 */

const TURLER: { kod: number; ad: string; ic: string; ne: string }[] = [
  { kod: 1, ad: 'İzin', ic: '🏖', ne: 'o günler randevu yok' },
  { kod: 2, ad: 'Kongre / eğitim', ic: '🎓', ne: 'o günler randevu yok' },
  { kod: 3, ad: 'Saat değişikliği', ic: '🕘', ne: 'o günler başka saat' },
  { kod: 4, ad: 'Ek mesai', ic: '➕', ne: 'ek çalışma bloğu' },
  { kod: 5, ad: 'Kapalı', ic: '⛔', ne: 'bölüm / gün kapalı' },
];
const turAd = (k: number | null | undefined) => TURLER.find(t => t.kod === k)?.ad ?? '';
const KAPATAN = (t: number) => t === 1 || t === 2 || t === 5;
const SAATLI = (t: number) => t === 3 || t === 4;
const KANAL: [string, string][] = [['B', 'Banko'], ['P', 'Portal'], ['C', 'Çağrı']];
const DURUM: Record<number, [string, string]> = { 0: ['Onay bekliyor', 'uyari'], 1: ['Onaylı', 'ok'], 2: ['İptal', 'gri'] };

interface Deger {
  hekimId: number; tur: number; departmanId: number | null; subeId: number | null; durum: number;
  basTarih: string; bitTarih: string; saatBas: string; saatBit: string; slotDk: number | null;
  kanallar: string[]; aciklama: string;
}

const bos = (hekimId?: number): Deger => ({
  hekimId: hekimId ?? 0, tur: 1, departmanId: null, subeId: null, durum: 0,
  basTarih: bugunIso(), bitTarih: bugunIso(), saatBas: '', saatBit: '', slotDk: null, kanallar: [], aciklama: '',
});

const kartaCevir = (k: Record<string, unknown>): Deger => ({
  hekimId: sayi(k.hekimId), tur: sayi(k.tur) || 1,
  departmanId: k.departmanId == null ? null : sayi(k.departmanId), subeId: k.subeId == null ? null : sayi(k.subeId),
  durum: sayi(k.durum), basTarih: gun10(k.basTarih), bitTarih: gun10(k.bitTarih),
  saatBas: metin(k.saatBas), saatBit: metin(k.saatBit), slotDk: k.slotDk == null ? null : sayi(k.slotDk) || null,
  kanallar: metin(k.kanallar).split(',').filter(Boolean), aciklama: metin(k.aciklama),
});

const govde = (v: Deger): Record<string, unknown> => ({
  hekimId: v.hekimId || null, tur: v.tur, departmanId: v.departmanId, subeId: v.subeId, durum: v.durum,
  basTarih: v.basTarih, bitTarih: v.bitTarih,
  // Gün boyu kapatan türde saat / slot / kanal tutulmaz (plan onları okumaz).
  saatBas: SAATLI(v.tur) ? v.saatBas : null, saatBit: SAATLI(v.tur) ? v.saatBit : null,
  slotDk: SAATLI(v.tur) ? v.slotDk : null,
  kanallar: v.tur === 4 ? KANAL.map(([k]) => k).filter(k => v.kanallar.includes(k)).join(',') : null,
  aciklama: v.aciklama.trim(),
});

const kisaTarih = (s: string) => { const [y, m, g] = s.split('-'); return y ? `${g}.${m}` : s };
const aralikMetni = (b: string, e: string) => b === e ? kisaTarih(b) : `${kisaTarih(b)}–${kisaTarih(e)}`;

/**
 * hekimSabit: Çalışma Planları'nda işaretli doktorla açıldı - doktor dolu gelir
 * ve değiştirilemez (yalnız yeni kayıtta; açılan kaydın doktoru zaten kayıttan).
 */
export function CalismaIstisnaKarti({ id, hekimId: ilkHekim, hekimSabit, onKapat }: { id: number | 'yeni'; hekimId?: number; hekimSabit?: boolean; onKapat(): void }) {
  const git = useNavigate();
  const { yetki } = useOturum();
  const yazar = yetki('randevu.plan');
  const [kayitId, setKayitId] = useState<number | null>(id === 'yeni' ? null : id);
  const [d, setD] = useState<Deger>(() => bos(ilkHekim));
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [surum, setSurum] = useState<string | undefined>();
  const [kodlar, setKodlar] = useState<Record<string, Record<string, string>>>({});
  const [baglam, setBaglam] = useState<CalismaIstisnaBaglam | null>(null);
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [sonuclar, setSonuclar] = useState<Record<number, { basarili: boolean; mesaj: string }>>({});
  const [aktarHedef, setAktarHedef] = useState<number | ''>('');
  const [aktarAcik, setAktarAcik] = useState(false);
  const [tazele, setTazele] = useState(0);
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);

  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));

  const oku = async (kid: number) => {
    const y = await api.kartOku('calisma-istisna', kid);
    const v = kartaCevir(y.kart);
    setKayitId(kid); setD(v); setIlk(v); setSurum(y.kart.surum as string | undefined);
  };

  useEffect(() => {
    let iptal = false;
    (async () => {
      try {
        const m = await api.kartAlanlari('calisma-istisna');
        if (iptal) return;
        setKodlar(Object.fromEntries(m.alanlar.map(a => [a.ad, a.kodlar ?? {}])));
        if (id !== 'yeni') await oku(id);
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
      finally { if (!iptal) setYukleniyor(false) }
    })();
    return () => { iptal = true };
  }, [id]);

  // BAĞLAM: hafta, etkilenen randevular, yakın istisnalar - form değiştikçe.
  const baglamAnahtar = JSON.stringify([d.hekimId, d.basTarih, d.bitTarih, d.tur, d.saatBas, d.saatBit, d.departmanId, kayitId, tazele]);
  useEffect(() => {
    if (!(d.hekimId > 0) || !d.basTarih) { setBaglam(null); return }
    let iptal = false;
    const z = setTimeout(() => {
      api.calismaIstisnaBaglam({
        hekimId: d.hekimId, bas: d.basTarih, bit: d.bitTarih || d.basTarih, tur: d.tur,
        saatBas: SAATLI(d.tur) && !Number.isNaN(dk(d.saatBas)) ? d.saatBas : undefined,
        saatBit: SAATLI(d.tur) && !Number.isNaN(dk(d.saatBit)) ? d.saatBit : undefined,
        departmanId: d.departmanId, id: kayitId,
      }).then(y => {
        if (iptal) return;
        setBaglam(y);
        // Varsayılan: hepsi seçili (mockup) - sonuç alınmış satırlar hariç.
        setSecili(new Set(y.randevular.map(r => r.id)));
      }).catch(h => { if (!iptal) setHata(hataMetni(h)) });
    }, 350);
    return () => { iptal = true; clearTimeout(z) };
  }, [baglamAnahtar]);   // eslint-disable-line react-hooks/exhaustive-deps

  // HAFTA ŞERİDİ: kayıtlı plan + bu formun etkisi (kendi satırları çıkarılır).
  const hafta = useMemo(() => {
    if (!baglam) return [];
    const bas = new Date(baglam.haftaBas + 'T00:00:00');
    return Array.from({ length: 7 }, (_, i) => {
      const g = new Date(bas); g.setDate(g.getDate() + i);
      const iso = isoGun(g);
      const satir = baglam.hafta.filter(h => String(h.gun).slice(0, 10) === iso && (kayitId === null || h.istisnaId !== kayitId));
      const acik = satir.filter(h => h.kaynak === 1 || h.kaynak === 2);
      const kapali = satir.find(h => h.kaynak === 3 || h.kaynak === 4);
      const bloklar = acik.map(h => `${(h.saatBas ?? '').replace(/:00$/, '')}–${(h.saatBit ?? '').replace(/:00$/, '')}${h.sablon && h.sablon !== 'Standart hafta' ? ' · ' + h.sablon : ''}`);
      const icinde = iso >= d.basTarih && iso <= (d.bitTarih || d.basTarih);
      let metinler = bloklar, kapat = !!kapali && !icinde, ek = false;
      if (kapali && !icinde) metinler = [kapali.kaynak === 4 ? (kapali.aciklama || 'İK izni') : turAd(kapali.istisnaTur)];
      if (icinde) {
        if (KAPATAN(d.tur)) { metinler = [turAd(d.tur)]; kapat = true }
        else if (d.tur === 3) { metinler = [`${d.saatBas || '--:--'}–${d.saatBit || '--:--'}`]; ek = true }
        else if (d.tur === 4) { metinler = [...bloklar, `+ ${d.saatBas || '--:--'}–${d.saatBit || '--:--'}`]; ek = true }
      }
      return { iso, gun: `${GUN_AD[i]} ${g.getDate()}`, metinler, kapat, ek, bos: metinler.length === 0 };
    });
  }, [baglam, d, kayitId]);

  const dogrula = (v: Deger) => {
    if (!(v.hekimId > 0)) return c('Doktor seçilmeli.');
    if (!v.basTarih || !v.bitTarih) return c('Tarih aralığı girilmeli.');
    if (v.bitTarih < v.basTarih) return c('Bitiş tarihi başlangıçtan önce olamaz.');
    if (SAATLI(v.tur) && (Number.isNaN(dk(v.saatBas)) || Number.isNaN(dk(v.saatBit)) || dk(v.saatBas) >= dk(v.saatBit)))
      return c('Saat değişikliği / ek mesai için saatler SS:DD biçiminde ve başlangıç bitişten önce olmalı.');
    if (v.tur === 4 && v.kanallar.length === 0) return c('Ek mesai için en az bir kanal seçin.');
    if (!v.aciklama.trim()) return c('Açıklama / neden girilmeli.');
    return null;
  };

  const kaydet = (ek?: Partial<Deger>, sonraMesaj?: string) => guvenli(async () => {
    const v = { ...d, ...ek };
    const h = dogrula(v);
    if (h) { setHata(h); return }
    setHata(null); setKaydediyor(true);
    try {
      if (kayitId === null) {
        const y = await api.kartEkle('calisma-istisna', { kart: govde(v) });
        const yeniId = sayi(y.kart.id);
        await oku(yeniId);
        git(`/calisma-istisna/${yeniId}`, { replace: true });
      } else {
        const once = ilk ? govde(ilk) : {};
        const fark = Object.fromEntries(Object.entries(govde(v)).filter(([k, x]) => once[k] !== x));
        if (Object.keys(fark).length > 0) await api.kartGuncelle('calisma-istisna', kayitId, { surum, kart: fark });
        await oku(kayitId);
      }
      setTazele(t => t + 1);
      mesaj(sonraMesaj ?? c('İstisna kaydedildi.'));
    } finally { setKaydediyor(false) }
  });

  const onayla = () => guvenli(async () => {
    const bekleyen = (baglam?.randevular ?? []).filter(r => !sonuclar[r.id]?.basarili).length;
    if (KAPATAN(d.tur) && bekleyen > 0
        && !await onay(`${bekleyen} ${c('randevu için işlem seçilmedi; olduğu gibi kalır ve takvimde kapalı zeminde görünür. Onaylansın mı?')}`)) return;
    await kaydet({ durum: 1 }, c('İstisna onaylandı - plan bu tarihler için değişti.'));
  });

  const iptalEt = () => guvenli(async () => {
    if (!await onay(c('İstisna iptal edilecek; plan şablondaki haline döner. Devam edilsin mi?'), true)) return;
    await kaydet({ durum: 2 }, c('İstisna iptal edildi.'));
  });

  const sil = () => guvenli(async () => {
    if (kayitId === null) return;
    if (!await onay(c('İstisna silinecek. Devam edilsin mi?'), true)) return;
    await api.kartSil('calisma-istisna', kayitId);
    onKapat();
  });

  const toplu = (islem: 'iptal' | 'aktar' | 'kaydir' | 'sms') => guvenli(async () => {
    const idler = [...secili];
    if (idler.length === 0) { setHata(c('Önce randevu seçin.')); return }
    if (islem === 'aktar' && aktarHedef === '') { setHata(c('Aktarılacak doktoru seçin.')); return }
    const soru = islem === 'iptal' ? `${idler.length} ${c('randevu iptal edilecek. Devam edilsin mi?')}`
      : islem === 'sms' ? `${idler.length} ${c('hastaya SMS gönderilecek. Devam edilsin mi?')}` : null;
    if (soru && !await onay(soru, islem === 'iptal')) return;
    setHata(null);
    const y = await api.calismaIstisnaRandevu(islem, idler, aktarHedef === '' ? undefined : aktarHedef);
    setSonuclar(o => ({ ...o, ...Object.fromEntries(y.sonuc.map(s => [s.id, { basarili: s.basarili, mesaj: s.mesaj }])) }));
    const ok = y.sonuc.filter(s => s.basarili).length;
    mesaj(`${ok} / ${y.sonuc.length} ${c('randevu işlendi.')}`);
    setAktarAcik(false);
    // SMS randevuyu değiştirmez; diğerleri listeden düşer.
    if (islem !== 'sms') setTazele(t => t + 1);
  });

  const ad = (alan: string, v: number | null) => (v ? kodlar[alan]?.[String(v)] : '') ?? '';
  const secenekler = (alan: string) => Object.entries(kodlar[alan] ?? {}).sort((a, b) => a[1].localeCompare(b[1], 'tr'));
  const randevular = baglam?.randevular ?? [];
  const tumSecili = randevular.length > 0 && randevular.every(r => secili.has(r.id));
  const [durumAd, durumSinif] = DURUM[d.durum] ?? DURUM[0];
  const tarihBaslik = d.basTarih ? (d.basTarih === d.bitTarih ? kisaTarih(d.basTarih) : aralikMetni(d.basTarih, d.bitTarih)) : '';
  const baslik = [ad('hekimId', d.hekimId), tarihBaslik].filter(Boolean).join(' · ');
  const kilitli = !yazar || d.durum === 2;

  return (
    <Modal baslik={`🏖 ${c('İzin & İstisna')}${baslik ? ' — ' + baslik : kayitId === null ? ' — ' + c('Yeni') : ''}`}
      ekSinif="kart-calisma" buyutmeYok onKapat={onKapat}
      ustSerit={<div className="ck-kimlik ck-k4">
          <label className="rk-fld"><span className="ck-etiket">{c('Doktor')} <b className="ak-zor">*</b></span>
            <select className="ck-buyuk" value={d.hekimId || ''} disabled={kilitli || (!!hekimSabit && kayitId === null)} title={hekimSabit && kayitId === null ? c('Çalışma Planları listesinde seçilen doktor') : undefined} onChange={e => yaz('hekimId', Number(e.target.value) || 0)}>
              <option value="">{c('Seçin…')}</option>
              {secenekler('hekimId').map(([k, a]) => <option key={k} value={k}>{a}</option>)}
            </select></label>
          <div className="rk-fld"><span className="ck-etiket">{c('Tarih aralığı')} <b className="ak-zor">*</b></span>
            <div className="ck-ikili">
              <input type="date" value={d.basTarih} disabled={kilitli}
                     onChange={e => setD(o => ({ ...o, basTarih: e.target.value, bitTarih: o.bitTarih < e.target.value ? e.target.value : o.bitTarih }))} />
              <span className="sonuk">–</span>
              <input type="date" value={d.bitTarih} min={d.basTarih} disabled={kilitli} onChange={e => yaz('bitTarih', e.target.value)} />
            </div></div>
          <label className="rk-fld"><span className="ck-etiket">{c('Bölüm')}</span>
            <select value={d.departmanId ?? ''} disabled={kilitli} onChange={e => yaz('departmanId', e.target.value ? Number(e.target.value) : null)}>
              <option value="">{c('Tümü')}</option>
              {secenekler('departmanId').map(([k, a]) => <option key={k} value={k}>{a}</option>)}
            </select></label>
          <div className="rk-fld"><span className="ck-etiket">{c('Durum')}</span>
            <div className="ck-durum"><span className={`rozet ${durumSinif}`}>{c(durumAd)}</span></div></div>
        </div>}
      alt={<>
          {yazar && <button type="button" className="d bir" disabled={kaydediyor || yukleniyor || d.durum === 2} onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>}
          {yazar && d.durum === 0 && <button type="button" className="d ok" disabled={kaydediyor || yukleniyor} onClick={() => void onayla()}>✔ {c('Onayla')}</button>}
          {yazar && kayitId !== null && d.durum !== 2 && <button type="button" className="d" disabled={kaydediyor} onClick={() => void iptalEt()}>✖ {c('İptal Et')}</button>}
          {yazar && kayitId !== null && <button type="button" className="d teh" onClick={() => void sil()}>🗑 {c('Sil')}</button>}
          <span className="ck-bosluk" />
          <button type="button" className="d kapat-dugmesi" onClick={onKapat}>{c('Kapat')}</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {yukleniyor ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
      <div className="ck-govde ck-genis-sag">
        <div className="ck-sol">
          <Grp baslik={c('Ne oluyor?')}>
            <div className="ck-iz">
              <div className="ck-turler ck-tam">
                {TURLER.map(t => (
                  <button key={t.kod} type="button" disabled={kilitli} className={`ck-tur${d.tur === t.kod ? ' on' : ''}`} onClick={() => yaz('tur', t.kod)}>
                    <b>{t.ic} {c(t.ad)}</b><span>{c(t.ne)}</span></button>
                ))}
              </div>
              <div className="rk-fld"><span className="ck-etiket">{c('Saat (yalnız saat değişikliği / ek mesai)')}{SAATLI(d.tur) && <> <b className="ak-zor">*</b></>}</span>
                <div className="ck-ikili">
                  <input className="ck-saat" value={SAATLI(d.tur) ? d.saatBas : ''} placeholder="--:--" disabled={kilitli || !SAATLI(d.tur)} onChange={e => yaz('saatBas', e.target.value)} />
                  <span className="sonuk">–</span>
                  <input className="ck-saat" value={SAATLI(d.tur) ? d.saatBit : ''} placeholder="--:--" disabled={kilitli || !SAATLI(d.tur)} onChange={e => yaz('saatBit', e.target.value)} />
                </div></div>
              <label className="rk-fld"><span className="ck-etiket">{c('Slot (boş = şablondaki)')}</span>
                <select value={SAATLI(d.tur) ? (d.slotDk ?? '') : ''} disabled={kilitli || !SAATLI(d.tur)} onChange={e => yaz('slotDk', e.target.value ? Number(e.target.value) : null)}>
                  <option value="">{c('Şablondaki')}</option>
                  {SLOTLAR.map(s => <option key={s} value={s}>{s} dk</option>)}
                </select></label>
              <label className="rk-fld"><span className="ck-etiket">{c('Şube')}</span>
                <select value={d.subeId ?? ''} disabled={kilitli} onChange={e => yaz('subeId', e.target.value ? Number(e.target.value) : null)}>
                  <option value="">{c('Tümü')}</option>
                  {secenekler('subeId').map(([k, a]) => <option key={k} value={k}>{a}</option>)}
                </select></label>
              <div className="rk-fld"><span className="ck-etiket">{c('Kanallar (ek mesai için)')}{d.tur === 4 && <> <b className="ak-zor">*</b></>}</span>
                <div className="ck-cipler">
                  {KANAL.map(([k, a]) => (
                    <button key={k} type="button" disabled={kilitli || d.tur !== 4} className={`ck-cip${d.tur === 4 && d.kanallar.includes(k) ? ' on' : ''}`}
                            onClick={() => yaz('kanallar', d.kanallar.includes(k) ? d.kanallar.filter(x => x !== k) : [...d.kanallar, k])}>{c(a)}</button>
                  ))}
                </div></div>
              <label className="rk-fld ck-tam"><span className="ck-etiket">{c('Açıklama / neden')} <b className="ak-zor">*</b></span>
                <input value={d.aciklama} maxLength={300} disabled={kilitli} onChange={e => yaz('aciklama', e.target.value)} /></label>
            </div>
          </Grp>

          <Grp baslik={c('Plan bu haftayı nasıl görecek')}
               ek={baglam ? `${aralikMetni(baglam.haftaBas, isoGun(new Date(new Date(baglam.haftaBas + 'T00:00:00').getTime() + 6 * 864e5)))}` : undefined}>
            {!baglam ? <div className="ck-iz sonuk ck-tam">{c('Doktor ve tarih seçin.')}</div> : (<>
              <div className="ck-hafta">
                {hafta.map(h => (
                  <div key={h.iso} className={`ck-hg${h.kapat ? ' kapali' : h.ek ? ' ek' : h.bos ? ' bos' : ''}`}>
                    <div className="t">{c(h.gun.split(' ')[0])} {h.gun.split(' ')[1]}</div>
                    {h.bos ? '—' : h.metinler.map((m, i) => <div key={i}>{c(m)}</div>)}
                  </div>
                ))}
              </div>
              <div className="ck-bilgi ck-kutu ck-alt">{KAPATAN(d.tur)
                ? <>{c('Onaylanınca taralı günler randevu takviminde')} <b>"{c(turAd(d.tur))}"</b> {c('diye kapanır; o günlere yeni randevu verilemez.')}</>
                : d.tur === 3 ? c('Onaylanınca bu günlerde yalnız yeni saatlerde randevu verilir; şablon değişmez.')
                : c('Onaylanınca bu günlere ek çalışma bloğu açılır; seçili kanallardan randevu alınabilir.')}</div>
            </>)}
          </Grp>
        </div>

        {/* SAĞ: etkilenen randevular */}
        <div className="ck-sag">
          {d.tur !== 4 && randevular.length > 0 && (
            <div className="uyari-kutusu ck-kutu">⚠ {c('Bu aralıkta')} <b>{randevular.length} {c('randevu')}</b> {c('var. Onaylamadan önce ne olacaklarını seçin — seçilmeyenler olduğu gibi kalır ve takvimde')} <b>{c('taralı (kapalı) zeminde')}</b> {c('görünür.')}</div>
          )}
          <Grp sinif="ck-grp-sag" baslik={c('Etkilenen randevular')} ek={String(randevular.length)}>
            {d.tur === 4 ? <div className="ck-iz sonuk">{c('Ek mesai mevcut randevuları etkilemez.')}</div> : (<>
              <table className="ck-dg">
                <thead><tr>
                  <th><input type="checkbox" checked={tumSecili} disabled={randevular.length === 0}
                             onChange={e => setSecili(e.target.checked ? new Set(randevular.map(r => r.id)) : new Set())} /></th>
                  <th>{c('Tarih')}</th><th>{c('Hasta')}</th><th>{c('Tür')}</th><th>{c('Durum')}</th></tr></thead>
                <tbody>
                  {randevular.map(r => {
                    const s = sonuclar[r.id];
                    return (
                      <tr key={r.id}>
                        <td><input type="checkbox" checked={secili.has(r.id)}
                                   onChange={e => setSecili(o => { const y = new Set(o); if (e.target.checked) y.add(r.id); else y.delete(r.id); return y })} /></td>
                        <td>{tarihSaat(r.baslangic).slice(0, 5)} {tarihSaat(r.baslangic).slice(11)}</td>
                        <td>{r.hasta}{!r.telefonVar && <span className="sonuk" title={c('Cep telefonu yok - SMS gönderilemez')}> 📵</span>}</td>
                        <td>{r.tip}</td>
                        <td>{s && !s.basarili
                          ? <span className="rozet hata" title={s.mesaj}>{c('Yapılamadı')}</span>
                          : s ? <span className="rozet ok" title={s.mesaj}>{c('İşlendi')}</span>
                          : <span className="rozet mavi">{c('Planlandı')}</span>}</td>
                      </tr>
                    );
                  })}
                  {randevular.length === 0 && <tr><td colSpan={5} className="sonuk">{baglam ? c('Bu aralıkta planlı randevu yok.') : c('Doktor ve tarih seçin.')}</td></tr>}
                </tbody>
              </table>
              {Object.values(sonuclar).some(s => !s.basarili) && (
                <ul className="ck-liste ck-hatalar">
                  {Object.entries(sonuclar).filter(([, s]) => !s.basarili).map(([rid, s]) => <li key={rid}>#{rid}: {s.mesaj}</li>)}
                </ul>
              )}
              <div className="ck-toplu">
                {aktarAcik ? (<>
                  <select value={aktarHedef} onChange={e => setAktarHedef(e.target.value ? Number(e.target.value) : '')}>
                    <option value="">{c('Doktor seçin…')}</option>
                    {(baglam?.doktorlar ?? []).map(x => <option key={x.id} value={x.id}>{x.ad}{x.ayniBolum ? '' : ` (${c('başka bölüm')})`}</option>)}
                  </select>
                  <button type="button" className="d ck-kucuk bir" disabled={aktarHedef === '' || secili.size === 0} onClick={() => void toplu('aktar')}>✔ {c('Aktar')}</button>
                  <button type="button" className="d ck-kucuk" onClick={() => setAktarAcik(false)}>{c('Vazgeç')}</button>
                </>) : (<>
                  <button type="button" className="d ck-kucuk" disabled={secili.size === 0} onClick={() => setAktarAcik(true)}>👨‍⚕️ {c('Başka doktora aktar…')}</button>
                  <button type="button" className="d ck-kucuk" disabled={secili.size === 0} onClick={() => void toplu('kaydir')}>📅 {c('Sonraki boş güne kaydır')}</button>
                  <button type="button" className="d ck-kucuk" disabled={secili.size === 0} onClick={() => void toplu('sms')}>✉ {c('Hastaya SMS ile bildir')}</button>
                  <button type="button" className="d ck-kucuk teh" disabled={secili.size === 0} onClick={() => void toplu('iptal')}>✖ {c('İptal et')}</button>
                </>)}
              </div>
            </>)}
          </Grp>

          <div className="ck-bilgi ck-kutu">ℹ <b>{c('İK\'dan onaylanan personel izni')}</b> {c('burada ayrıca girilmez: izin modülünden onaylanan yıllık izin / rapor planı kendiliğinden kapatır ve aşağıda')}
            {' '}<span className="rozet gri">{c('İK izni')}</span> {c('etiketiyle salt okunur görünür.')}</div>

          <Grp sinif="ck-grp-sag" baslik={c('Doktorun yakın istisnaları')} ilkKapali ek={baglam ? String(baglam.yakin.length) : undefined}>
            <table className="ck-dg">
              <thead><tr><th>{c('Tarih')}</th><th>{c('Tür')}</th><th>{c('Kaynak')}</th><th>{c('Durum')}</th></tr></thead>
              <tbody>
                {(baglam?.yakin ?? []).map(y => {
                  const bu = y.kaynak === 'istisna' && y.id === kayitId;
                  return (
                    <tr key={`${y.kaynak}${y.id}`} className={y.kaynak === 'istisna' && !bu ? 'ck-tik' : ''} title={y.aciklama}
                        onClick={() => { if (y.kaynak === 'istisna' && !bu) git(`/calisma-istisna/${y.id}`) }}>
                      <td>{aralikMetni(String(y.bas).slice(0, 10), String(y.bit).slice(0, 10))}</td>
                      <td>{y.tur}</td>
                      <td>{bu ? c('Bu kart') : y.kaynak === 'ik' ? <span className="rozet gri">{c('İK izni')}</span> : c('Plan')}</td>
                      <td>{y.onayli ? <span className="rozet ok">{c('Onaylı')}</span> : <span className="rozet uyari">{c('Bekliyor')}</span>}</td>
                    </tr>
                  );
                })}
                {baglam && baglam.yakin.length === 0 && <tr><td colSpan={4} className="sonuk">{c('Yakın istisna yok.')}</td></tr>}
              </tbody>
            </table>
          </Grp>
        </div>
      </div>
      )}
      <div className="ck-ozet">
              <span>{c('İstisna No')}: <b>{kayitId ? `İS-${String(kayitId).padStart(4, '0')}` : '—'}</b></span>
              {baglam?.kayit && <span>{c('Giren')}: <b>{baglam.kayit.ekleyen || '—'} · {tarihSaat(baglam.kayit.eklemeTarihi)}</b></span>}
              {kayitId !== null && <span>{c('Onaylayan')}: <b>{baglam?.kayit?.onayTarihi ? `${baglam.kayit.onaylayan || '—'} · ${tarihSaat(baglam.kayit.onayTarihi)}` : '—'}</b></span>}
            </div>
    </Modal>
  );
}
