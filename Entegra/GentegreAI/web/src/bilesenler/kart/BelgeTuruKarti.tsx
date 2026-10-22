import { useEffect, useMemo, useState, type ReactNode } from 'react';
import { api } from '../../api/istemci';
import type { BelgeTuruKapsamOnizleme, BelgeTuruKartOzeti, BelgeTuruPersonel } from '../../api/uclar/belgeTakip';
import type { SekmeParcalari } from '../kartSekmeleri';
import type { Deger } from '../kartAlanCizim';
import { guvenli, mesaj, onay } from '../mesaj';
import { tarihSaat, tarihYaz } from '../bicim';

/**
 * İK › BELGE TÜRÜ KARTI (mockup Ekranlar/IK/personel_belge_turu.html (2), kullanıcı 22.10.2026
 * "mockup'a göre yap, öneriler hariç"). Kart generic (KartKatalogu.PersonelBelgeTuru); burası
 * mockup'ın generic'te olmayan parçaları:
 *
 *   · Genel        : Belge türü · Geçerlilik (Süresiz / Süreli anahtarı) · Kayıt kuralları kutuları,
 *                    sağda Özet (kime zorunlu, sayılar, çubuk), geçerlilik uyarısı ve Kayıt bilgisi.
 *   · Kime zorunlu : kapsam gridinin sağında KAYDEDİLMEMİŞ kurallarla önizleme.
 *   · Personel durumu · Hatırlatma · Hareketler : ek sekmeler (yalnız kayıtlı kartta).
 *
 * Kural sunucuda (PersonelBelgeTurUclari, v_personel_belge_durum) - burada sayı hesaplanmaz.
 */

const STIL = `
.bt-iki { display: grid; grid-template-columns: minmax(0, 1fr) 320px; gap: 12px; align-items: start }
@media (max-width: 1100px) { .bt-iki { grid-template-columns: minmax(0, 1fr) } }
.bt-kutu { border: 1px solid var(--cizgi); border-radius: 4px; background: var(--yuz); margin-bottom: 10px; overflow: hidden }
.bt-kutu > h6 { margin: 0; padding: 6px 10px; font-size: 12px; color: var(--yazi2); background: var(--kartzem);
  border-bottom: 1px solid var(--cizgi); display: flex; gap: 8px; align-items: center }
.bt-kutu > h6 .sag { margin-left: auto; font-weight: normal; color: var(--soluk); font-size: 11px }
.bt-kutu > .ic { padding: 8px 10px }
.bt-kv { display: grid; grid-template-columns: auto 1fr; gap: 5px 12px; font-size: 12px }
.bt-kv > b { color: var(--soluk); font-weight: normal }
.bt-cubuk { height: 8px; border-radius: 4px; overflow: hidden; display: flex; background: var(--cizgi); margin-top: 10px }
.bt-cubuk i { display: block; height: 100% }
.bt-uyari { border: 1px solid var(--uyarikenar); background: var(--uyarizem); color: var(--uyari); border-radius: 4px;
  padding: 7px 10px; font-size: 12px; margin-bottom: 10px; line-height: 1.5 }
.bt-bilgi { border: 1px solid var(--cizgi); background: var(--kartzem); color: var(--yazi2); border-radius: 4px;
  padding: 7px 10px; font-size: 12px; margin-bottom: 10px; line-height: 1.5 }
.bt-anahtar { display: flex; gap: 6px; margin: 2px 0 6px }
.bt-anahtar button { border: 1px solid var(--cizgi); background: var(--yuz); color: var(--yazi); border-radius: 3px;
  padding: 4px 12px; font: inherit; cursor: pointer }
.bt-anahtar button.on { border-color: var(--mor); color: var(--yazi2); font-weight: 700; box-shadow: 0 0 0 1px var(--mor) inset }
.bt-anahtar button:disabled { cursor: default }
.bt-suresiz input { opacity: .4; pointer-events: none }
.bt-not { color: var(--soluk); font-size: 11.5px }
.bt-ok { color: var(--ok); font-weight: 700 } .bt-hata { color: var(--hata); font-weight: 700 } .bt-sari { color: var(--uyari); font-weight: 700 }
.bt-liste { list-style: none; margin: 0; padding: 0 }
.bt-liste li { display: flex; gap: 8px; align-items: center; padding: 5px 0; border-bottom: 1px dashed var(--cizgi) }
.bt-liste li:last-child { border-bottom: none }
.bt-liste li span:first-child { flex: 1 }
.bt-rz { padding: 1px 9px; border-radius: 10px; font-size: 11px; display: inline-block; border: 1px solid var(--cizgi);
  background: var(--kartzem); color: var(--yazi) }
.bt-rz.ok { background: var(--okzem); color: var(--ok); border-color: var(--okkenar) }
.bt-rz.hata { background: var(--hatazem); color: var(--hata); border-color: var(--hatakenar) }
.bt-rz.uyari { background: var(--uyarizem); color: var(--uyari); border-color: var(--uyarikenar) }
.bt-rz.mavi { color: var(--mor) }
.bt-sayac { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 10px; margin-bottom: 10px }
.bt-sayac button { border: 1px solid var(--cizgi); border-left: 4px solid var(--cizgi); border-radius: 4px; padding: 7px 10px;
  background: var(--kartzem); text-align: left; font: inherit; cursor: pointer; color: var(--yazi) }
.bt-sayac button.on { box-shadow: 0 0 0 2px var(--mor) inset }
.bt-sayac .bt-e { font-size: 11px; color: var(--soluk); display: block } .bt-sayac .bt-d { display: block; font-size: 19px; font-weight: 700; color: var(--yazi2) }
.bt-sayac .ok { border-left-color: var(--ok) } .bt-sayac .ok .bt-d { color: var(--ok) }
.bt-sayac .hata { border-left-color: var(--hata) } .bt-sayac .hata .bt-d { color: var(--hata) }
.bt-sayac .uyari { border-left-color: var(--uyari) } .bt-sayac .uyari .bt-d { color: var(--uyari) }
.bt-arac { display: flex; gap: 6px; align-items: center; padding: 5px 8px; border: 1px solid var(--cizgi); border-bottom: none;
  border-radius: 4px 4px 0 0; background: var(--kartzem); flex-wrap: wrap }
.bt-arac .sag { margin-left: auto; color: var(--soluk); font-size: 11.5px }
.bt-tablo { width: 100%; border-collapse: collapse; font-size: 12px; border: 1px solid var(--cizgi) }
.bt-tablo th { text-align: left; padding: 6px 8px; background: var(--kartzem); border-bottom: 1px solid var(--cizgi); color: var(--yazi2);
  white-space: nowrap }
.bt-tablo td { padding: 5px 8px; border-bottom: 1px solid var(--cizgi); white-space: nowrap }
.bt-tablo tr.hata td { background: var(--hatazem) } .bt-tablo tr.uyari td { background: var(--uyarizem) }
.bt-tablo tr.tik { cursor: pointer }
.bt-tablo td.s { text-align: right }
.bt-alt { padding: 5px 8px; border: 1px solid var(--cizgi); border-top: none; color: var(--soluk); font-size: 11.5px; display: flex; gap: 14px }
.bt-sablon { border: 1px dashed var(--cizgi); border-radius: 4px; background: var(--kartzem); padding: 8px 10px;
  white-space: pre-wrap; line-height: 1.55; font-size: 12px }
.bt-sablon i { background: var(--uyarizem); color: var(--uyari); font-style: normal; border-radius: 3px; padding: 0 3px }
.bt-cizelge { position: relative; height: 56px; margin: 6px 40px 0 }
.bt-cizelge .h { position: absolute; left: 0; right: 0; top: 34px; height: 5px; border-radius: 3px }
.bt-cizelge .n { position: absolute; top: 0; transform: translateX(-50%); text-align: center; font-size: 11px; color: var(--soluk);
  white-space: nowrap }
`;

const Stil = () => <style>{STIL}</style>;

const n = (x: unknown) => Number(x ?? 0);
const durumSinif = (d: number) => d === 4 ? 'ok' : d === 3 ? 'uyari' : 'hata';

// ================================================================ GENEL ====

/** "Genel" sekmesi: üç kutu solda, özet sağda (mockup). Yeni kartta sağ sütun yok. */
export function BelgeTuruGenel({ id, deger, parcalar, tazele }: {
  id: number | null;
  deger: Record<string, Deger>;
  parcalar?: SekmeParcalari;
  tazele: number;
}) {
  const [ozet, setOzet] = useState<BelgeTuruKartOzeti | null>(null);
  useEffect(() => {
    if (!id) return;
    let iptal = false;
    api.belgeTuruKartOzet(id).then(o => { if (!iptal) setOzet(o) }, () => { /* özet zorunlu değil */ });
    return () => { iptal = true };
  }, [id, tazele]);

  const ay = deger.gecerlilikAy;
  const sureli = ay !== null && ay !== undefined && String(ay) !== '';
  const anahtar = (
    <div className="bt-anahtar">
      <button type="button" className={sureli ? '' : 'on'}
              onClick={() => parcalar?.alanDegistir('gecerlilikAy', null)}>Süresiz</button>
      <button type="button" className={sureli ? 'on' : ''}
              onClick={() => { if (!sureli) parcalar?.alanDegistir('gecerlilikAy', 12) }}>Süreli</button>
    </div>
  );
  const not = sureli
    ? `Geçerlilik tarihi girilmezse belge tarihi + ${n(ay)} ay olarak hesaplanır.`
    : 'Süresiz belge: bir kez girilir, yaklaşma / dolma uyarısı yok.';

  const sol = parcalar ? (
    <div>
      {parcalar.altGrupCiz('Belge türü')}
      <div className={sureli ? '' : 'bt-suresiz'}>
        {parcalar.altGrupCiz('Geçerlilik', { ic: anahtar, ek: undefined })}
      </div>
      <div className="bt-not" style={{ margin: '-4px 0 10px 4px' }}>{not}</div>
      {parcalar.altGrupCiz('Kayıt kuralları')}
      {parcalar.altGrupCiz('')}
    </div>
  ) : null;

  if (!id) return <><Stil />{sol}</>;

  const toplam = ozet ? Math.max(ozet.personel, ozet.tamam + ozet.eksik + ozet.doldu + ozet.yaklasan, 1) : 1;
  const y = (v: number) => `${(v * 100) / toplam}%`;
  return (
    <div className="bt-iki">
      <Stil />
      {sol}
      <div>
        <div className="bt-kutu"><h6>Özet</h6><div className="ic">
          {ozet ? <>
            <div className="bt-kv">
              <b>Kime zorunlu</b><span>{ozet.kapsam}</span>
              <b>Kapsamdaki personel</b><span>{ozet.personel.toLocaleString('tr')}</span>
              <b>Belgesi tamam</b><span className="bt-ok">{ozet.tamam.toLocaleString('tr')}</span>
              <b>Eksik / dosya yok</b><span className={ozet.eksik ? 'bt-hata' : ''}>{ozet.eksik.toLocaleString('tr')}</span>
              <b>Süresi doldu</b><span className={ozet.doldu ? 'bt-hata' : ''}>{ozet.doldu.toLocaleString('tr')}</span>
              {sureli && <><b>{n(deger.hatirlatGun)} gün içinde dolacak</b>
                <span className={ozet.yaklasan ? 'bt-sari' : ''}>{ozet.yaklasan.toLocaleString('tr')}</span></>}
            </div>
            <div className="bt-cubuk">
              <i style={{ width: y(ozet.tamam), background: 'var(--ok)' }} />
              <i style={{ width: y(ozet.yaklasan), background: 'var(--uyari)' }} />
              <i style={{ width: y(ozet.eksik + ozet.doldu), background: 'var(--hata)' }} />
            </div>
          </> : <span className="bt-not">Yükleniyor…</span>}
        </div></div>
        {sureli && (
          <div className="bt-uyari">⚠ Geçerlilik süresini değiştirmek girilmiş belgelerin geçerlilik tarihlerini
            {' '}<b>değiştirmez</b>; yalnız yeni girilen ve tarihi boş bırakılan belgeler yeni süreyle hesaplanır.</div>
        )}
        {ozet && (
          <div className="bt-kutu"><h6>Kayıt</h6><div className="ic"><div className="bt-kv">
            <b>Ekleyen</b><span>{[ozet.ekleyen, tarihYaz(ozet.eklemeTarihi)].filter(Boolean).join(' · ')}</span>
            {ozet.degistirmeTarihi && <><b>Son değiştiren</b>
              <span>{[ozet.degistiren, tarihSaat(ozet.degistirmeTarihi)].filter(Boolean).join(' · ')}</span></>}
            <b>Geçerli olduğu yer</b><span>{ozet.subeId === 0 ? 'Kurum geneli (tüm şubeler)' : ozet.sube}</span>
          </div></div></div>
        )}
      </div>
    </div>
  );
}

// ========================================================= KİME ZORUNLU ====

/** Kapsam gridinin sağında önizleme - grid her değiştiğinde (kaydetmeden) yeniden hesaplanır. */
export function BelgeTuruKapsam({ id, grid, satirlar }: {
  id: number | null;
  grid: ReactNode;
  satirlar: Record<string, unknown>[];
}) {
  const kurallar = useMemo(() => satirlar.map(s => ({
    departmanId: n(s.departmanId) || null, gorevId: n(s.gorevId) || null,
  })), [satirlar]);
  const anahtar = JSON.stringify(kurallar);
  const [o, setO] = useState<BelgeTuruKapsamOnizleme | null>(null);
  useEffect(() => {
    let iptal = false;
    const t = setTimeout(() => {
      api.belgeTuruKapsamOnizle(id ?? 0, JSON.parse(anahtar)).then(y => { if (!iptal) setO(y) }, () => { /* sessiz */ });
    }, 300);
    return () => { iptal = true; clearTimeout(t) };
  }, [id, anahtar]);

  const birimler = o?.birimler ?? [];
  const ilk = birimler.slice(0, 5);
  const kalan = birimler.slice(5);
  return (
    <>
      <Stil />
      <div className="bt-bilgi">Satırda <b>birim</b> ve/veya <b>görev</b> seçilir. İkisi boş satır = <b>tüm personel</b>.
        {' '}Hiç satır yoksa belge <b>isteğe bağlıdır</b>: girilebilir, eksik sayılmaz.</div>
      <div className="bt-iki">
        <div>{grid}</div>
        <div>
          <div className="bt-kutu"><h6>Kapsam önizleme <span className="sag">kaydetmeden hesaplanır</span></h6><div className="ic">
            {!o ? <span className="bt-not">Hesaplanıyor…</span>
              : kurallar.length === 0 ? <span className="bt-not">Kural yok - belge isteğe bağlı.</span>
              : <>
                <div className="bt-kv">
                  <b>Kapsama giren</b><span><b className="bt-ok" style={{ color: 'var(--yazi2)' }}>{o.toplam.kapsama.toLocaleString('tr')}</b> aktif personel</span>
                  <b>Eksik / süresi dolmuş</b><span className={o.toplam.eksik ? 'bt-hata' : ''}>{o.toplam.eksik.toLocaleString('tr')}</span>
                  <b>Kayıtla yeni eksik çıkacak</b><span className={o.toplam.yeniEksik ? 'bt-hata' : ''}>+{o.toplam.yeniEksik.toLocaleString('tr')}</span>
                  <b>Kapsamdan çıkacak</b><span>{o.toplam.cikacak.toLocaleString('tr')}</span>
                </div>
                <ul className="bt-liste" style={{ marginTop: 8 }}>
                  {o.satirlar.map(s => (
                    <li key={s.sira}><span>{s.sira}. kural</span>
                      <span className="bt-rz">{s.eslesen.toLocaleString('tr')} eşleşen</span>
                      <span className={`bt-rz${s.eksik ? ' hata' : ''}`}>{s.eksik.toLocaleString('tr')} eksik</span></li>
                  ))}
                </ul>
              </>}
          </div></div>
          {ilk.length > 0 && (
            <div className="bt-kutu"><h6>Birim dağılımı</h6><div className="ic"><ul className="bt-liste">
              {ilk.map(b => <li key={b.ad}><span>{b.ad}</span><span className="bt-rz">{b.sayi}</span></li>)}
              {kalan.length > 0 && <li><span>Diğer {kalan.length} birim</span>
                <span className="bt-rz">{kalan.reduce((t, b) => t + b.sayi, 0)}</span></li>}
            </ul></div></div>
          )}
        </div>
      </div>
    </>
  );
}

// ====================================================== PERSONEL DURUMU ====

type Suzgec = 'hep' | 'ok' | 'eks' | 'dol' | 'yak';
const suz = (s: BelgeTuruPersonel, f: Suzgec) =>
  f === 'hep' ? true : f === 'ok' ? s.durum === 4 : f === 'eks' ? s.durum === 1 : f === 'dol' ? s.durum === 2 : s.durum === 3;

export function BelgeTuruPersonelSekmesi({ id, hatirlatGun, tazele, git, saltOkunur, onSayilar }: {
  id: number;
  hatirlatGun: number;
  tazele: number;
  git(yol: string): void;
  saltOkunur: boolean;
  onSayilar?(sorun: number): void;
}) {
  const [satirlar, setSatirlar] = useState<BelgeTuruPersonel[] | null>(null);
  const [f, setF] = useState<Suzgec>('hep');
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [yenile, setYenile] = useState(0);
  useEffect(() => {
    let iptal = false;
    api.belgeTuruPersonel(id).then(y => {
      if (iptal) return;
      setSatirlar(y);
      // Varsayılan seçim: hatırlatılacak olanlar (eksik / doldu) - mockup'taki gibi.
      setSecili(new Set(y.filter(s => s.durum === 1 || s.durum === 2).map(s => s.personelId)));
    }, () => setSatirlar([]));
    return () => { iptal = true };
  }, [id, tazele, yenile]);
  useEffect(() => {
    if (satirlar) onSayilar?.(satirlar.filter(s => (s.zorunlu && s.durum === 1) || s.durum === 2).length);
  }, [satirlar, onSayilar]);

  if (!satirlar) return <div className="bt-not" style={{ padding: 12 }}>Yükleniyor…</div>;
  const say = (x: Suzgec) => satirlar.filter(s => suz(s, x)).length;
  const kapsam = satirlar.filter(s => s.zorunlu).length;
  const gorunen = satirlar.filter(s => suz(s, f));
  const tumuSecili = gorunen.length > 0 && gorunen.every(s => secili.has(s.personelId));
  const kartlar: { k: Suzgec; e: string; v: number; s?: string }[] = [
    { k: 'hep', e: 'Kapsamdaki personel', v: kapsam },
    { k: 'ok', e: 'Tamam', v: say('ok'), s: 'ok' },
    { k: 'eks', e: 'Eksik / dosya yok', v: say('eks'), s: 'hata' },
    { k: 'dol', e: 'Süresi doldu', v: say('dol'), s: 'hata' },
    { k: 'yak', e: `${hatirlatGun} gün içinde`, v: say('yak'), s: 'uyari' },
  ];

  const hatirlat = async () => {
    const idler = [...secili];
    if (idler.length === 0) { mesaj('Önce personel seçin.'); return }
    if (!await onay(`${idler.length} personele eksik / süresi dolan belgeleri için hatırlatma gönderilecek `
                  + '(e-postası varsa e-posta, yoksa SMS). Onaylıyor musunuz?')) return;
    await guvenli(async () => {
      const y = await api.belgeTakipHatirlat(idler);
      mesaj(`${y.kuyruga} personele hatırlatma gönderim kuyruğuna alındı.`
          + (y.atlanan.length ? `\n\nGönderilmeyen ${y.atlanan.length}:\n` + y.atlanan.map(a => `• ${a.ad}: ${a.neden}`).join('\n') : ''));
      setYenile(t => t + 1);
    });
  };

  const csv = () => {
    const bas = ['Personel', 'Birim', 'Görev', 'Belge tarihi', 'Geçerlilik', 'Kalan gün', 'Dosya', 'Durum'];
    const kac = (v: unknown) => `"${String(v ?? '').replace(/"/g, '""')}"`;
    const govde = gorunen.map(s => [s.ad, s.birim, s.gorev, s.belgeTarihi ? tarihYaz(s.belgeTarihi) : '',
      s.gecerlilikTarihi ? tarihYaz(s.gecerlilikTarihi) : '', s.kalanGun ?? '', s.dosyaSayisi, s.durumAdi].map(kac).join(';'));
    const blob = new Blob(['﻿' + [bas.map(kac).join(';'), ...govde].join('\r\n')], { type: 'text/csv;charset=utf-8' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob); a.download = 'belge-personel-durumu.csv'; a.click();
    setTimeout(() => URL.revokeObjectURL(a.href), 1000);
  };

  return (
    <div style={{ padding: '10px 14px' }}>
      <Stil />
      <div className="bt-sayac">
        {kartlar.map(k => (
          <button type="button" key={k.k} className={`${k.s ?? ''}${f === k.k ? ' on' : ''}`} onClick={() => setF(k.k)}>
            <span className="bt-e">{k.e}</span><span className="bt-d">{k.v.toLocaleString('tr')}</span>
          </button>
        ))}
      </div>
      <div className="bt-arac">
        <label style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
          <input type="checkbox" checked={tumuSecili} disabled={saltOkunur}
                 onChange={e => setSecili(o => {
                   const y = new Set(o);
                   gorunen.forEach(s => e.target.checked ? y.add(s.personelId) : y.delete(s.personelId));
                   return y;
                 })} /> Tümünü seç
        </label>
        <button type="button" className="d" disabled={saltOkunur || secili.size === 0} onClick={() => void hatirlat()}>📤 Seçililere hatırlat</button>
        <button type="button" className="d" onClick={csv}>⬇ Excel</button>
        <span className="sag">Satıra çift tık = personel kartı açılır</span>
      </div>
      <table className="bt-tablo">
        <thead><tr><th style={{ width: 24 }} /><th>Personel</th><th>Birim</th><th>Görev</th><th>Belge tarihi</th>
          <th>Geçerlilik</th><th>Kalan</th><th>Dosya</th><th>Son hatırlatma</th><th>Durum</th></tr></thead>
        <tbody>
          {gorunen.map(s => (
            <tr key={s.personelId} className={`tik ${s.durum === 1 || s.durum === 2 ? 'hata' : s.durum === 3 ? 'uyari' : ''}`}
                onDoubleClick={() => git(`/personel/${s.personelId}`)}>
              <td><input type="checkbox" checked={secili.has(s.personelId)} disabled={saltOkunur}
                         onChange={e => setSecili(o => { const y = new Set(o); if (e.target.checked) y.add(s.personelId); else y.delete(s.personelId); return y })} /></td>
              <td>{s.ad}</td><td>{s.birim}</td><td>{s.gorev}</td>
              <td>{s.belgeTarihi ? tarihYaz(s.belgeTarihi) : <span className="bt-not">—</span>}</td>
              <td>{s.gecerlilikTarihi ? tarihYaz(s.gecerlilikTarihi) : <span className="bt-not">—</span>}</td>
              <td className={s.kalanGun == null ? 'bt-not' : s.kalanGun < 0 ? 'bt-hata' : s.durum === 3 ? 'bt-sari' : 'bt-ok'}>
                {s.kalanGun == null ? '—' : `${s.kalanGun < 0 ? '−' : ''}${Math.abs(s.kalanGun)} gün`}</td>
              <td>{s.dosyaSayisi > 0 ? '📄' : s.belgeVar ? <span className="bt-hata">yok</span> : <span className="bt-not">—</span>}</td>
              <td className="bt-not">{s.sonHatirlatma ? `${tarihYaz(s.sonHatirlatma)} · ${s.sonHatirlatmaKanal}` : '—'}</td>
              <td><span className={`bt-rz ${durumSinif(s.durum)}`}>{s.durumAdi}</span>
                {!s.zorunlu && <span className="bt-not"> · isteğe bağlı</span>}</td>
            </tr>
          ))}
          {gorunen.length === 0 && <tr><td colSpan={10} className="bt-not">Kayıt yok.</td></tr>}
        </tbody>
      </table>
      <div className="bt-alt"><span>{gorunen.length.toLocaleString('tr')} / {satirlar.length.toLocaleString('tr')} personel gösteriliyor</span>
        <span>{secili.size.toLocaleString('tr')} seçili</span></div>
    </div>
  );
}

// =========================================================== HATIRLATMA ====

/** {{degisken}} vurgulu şablon metni. */
function Sablon({ metin }: { metin: string }) {
  const parcalar = metin.split(/(\{\{[^}]+\}\})/g);
  return <>{parcalar.map((p, i) => p.startsWith('{{') ? <i key={i}>{p}</i> : <span key={i}>{p}</span>)}</>;
}

export function BelgeTuruHatirlatmaSekmesi({ gecerlilikAy, hatirlatGun, git }: {
  gecerlilikAy: number | null;
  hatirlatGun: number;
  git(yol: string): void;
}) {
  const [sablonlar, setSablonlar] = useState<Awaited<ReturnType<typeof api.belgeTuruSablonlar>> | null>(null);
  useEffect(() => { api.belgeTuruSablonlar().then(setSablonlar, () => setSablonlar([])) }, []);

  // Çizelge oranı: geçerlilik gün sayısının içinde uyarı noktası (en az %10 yeşil kalsın).
  const gun = (gecerlilikAy ?? 0) * 30;
  const uyariYuzde = gun > 0 ? Math.max(10, Math.min(85, ((gun - hatirlatGun) / gun) * 85)) : 85;
  return (
    <div style={{ padding: '10px 14px' }}>
      <Stil />
      <div className="bt-iki">
        <div>
          <div className="bt-kutu"><h6>Zaman çizelgesi
            <span className="sag">{gecerlilikAy ? `${gecerlilikAy} ay geçerli · ${hatirlatGun} gün önce uyar` : 'Süresiz'}</span></h6>
            <div className="ic">
              {gecerlilikAy ? <>
                <div className="bt-cizelge">
                  <div className="h" style={{ background: `linear-gradient(90deg, var(--ok) 0 ${uyariYuzde}%, var(--uyari) ${uyariYuzde}% 85%, var(--hata) 85%)` }} />
                  <div className="n" style={{ left: 0 }}>Belge tarihi<br />&nbsp;</div>
                  <div className="n" style={{ left: `${uyariYuzde}%` }}>−{hatirlatGun} gün<br /><b className="bt-sari">Yaklaşıyor</b></div>
                  <div className="n" style={{ left: '85%' }}>Geçerlilik sonu<br /><b className="bt-hata">Doldu</b></div>
                </div>
                <div className="bt-not" style={{ marginTop: 6 }}>Yeşil = tamam · sarı = yaklaşıyor (personel kartında ve listede uyarı) ·
                  kırmızı = doldu (eksik sayılır).</div>
              </> : <div className="bt-not">Süresiz belge: bir kez girilir; yaklaşma / dolma uyarısı yok. Yalnız eksikse hatırlatılır.</div>}
            </div></div>
          <div className="bt-kutu"><h6>Hatırlatma nasıl gönderilir</h6><div className="ic bt-not" style={{ lineHeight: 1.6 }}>
            Belge Takip listesinde ya da bu kartın <b>Personel durumu</b> sekmesinde seçili personele
            {' '}<b>📤 Hatırlat</b>. E-postası olana e-posta, olmayana SMS gider; aynı kişiye 24 saatte bir.
            Mesajda personelin bütün eksik / süresi dolan / yaklaşan belgeleri listelenir.
          </div></div>
        </div>
        <div>
          {sablonlar === null ? <span className="bt-not">Yükleniyor…</span> : sablonlar.map(s => (
            <div className="bt-kutu" key={s.id}>
              <h6>{s.kanal === 2 ? 'E-posta şablonu' : 'SMS şablonu'}<span className="sag">{s.kod}{!s.aktif && ' · pasif'}</span></h6>
              <div className="ic">
                <div className="bt-sablon">{s.konu && <><b>Konu:</b> <Sablon metin={s.konu} />{'\n\n'}</>}<Sablon metin={s.govde} /></div>
                <div style={{ marginTop: 6 }}>
                  <button type="button" className="d" onClick={() => git(`/bildirim-sablon/${s.id}`)}>✎ Şablonu düzenle</button>
                  {' '}<span className="bt-not">Bildirim şablonları ekranında açılır (tüm türlerde ortak).</span>
                </div>
              </div>
            </div>
          ))}
          {sablonlar?.length === 0 && <div className="bt-uyari">Hatırlatma şablonu bulunamadı (1137).</div>}
        </div>
      </div>
    </div>
  );
}

// =========================================================== HAREKETLER ====

export function BelgeTuruHareketSekmesi({ id, tazele }: { id: number; tazele: number }) {
  const [satirlar, setSatirlar] = useState<Awaited<ReturnType<typeof api.belgeTuruHareketler>> | null>(null);
  useEffect(() => { api.belgeTuruHareketler(id).then(setSatirlar, () => setSatirlar([])) }, [id, tazele]);
  const sinif = (islem: string) => islem === 'Eklendi' ? 'ok' : islem.includes('silindi') || islem === 'Silindi' ? 'hata' : 'mavi';
  return (
    <div style={{ padding: '10px 14px' }}>
      <Stil />
      <div className="bt-iki">
        <table className="bt-tablo">
          <thead><tr><th>Zaman</th><th>İşlem</th><th>Ayrıntı</th><th>Kullanıcı</th></tr></thead>
          <tbody>
            {satirlar === null && <tr><td colSpan={4} className="bt-not">Yükleniyor…</td></tr>}
            {satirlar?.length === 0 && <tr><td colSpan={4} className="bt-not">Kayıt yok.</td></tr>}
            {satirlar?.map((s, i) => (
              <tr key={i}><td>{tarihSaat(s.zaman)}</td><td><span className={`bt-rz ${sinif(s.islem)}`}>{s.islem}</span></td>
                <td style={{ whiteSpace: 'normal' }}>{s.ayrinti}</td><td>{s.kullanici}</td></tr>
            ))}
          </tbody>
        </table>
        <div className="bt-kutu"><h6>Not</h6><div className="ic bt-not" style={{ lineHeight: 1.6 }}>
          Tür ve kapsam değişiklikleri işlem loguna yazılır (1600 / 1601). Personel bazında belge hareketleri
          personel kartı › Belgeler › Hareketler'de.
        </div></div>
      </div>
    </div>
  );
}

// ============================================================ ÜST PARÇALAR ====

/** Başlıkta personel durumu rozetleri (mockup şeridindeki "5 eksik / doldu · 6 yaklaşıyor"). */
export function BelgeTuruBaslik({ id, tazele }: { id: number; tazele: number }) {
  const [o, setO] = useState<BelgeTuruKartOzeti | null>(null);
  useEffect(() => { api.belgeTuruKartOzet(id).then(setO, () => { /* sessiz */ }) }, [id, tazele]);
  if (!o) return null;
  return <>
    {o.eksik + o.doldu > 0 && <span className="rozet hata">{o.eksik + o.doldu} eksik / doldu</span>}
    {o.yaklasan > 0 && <span className="rozet uyari">{o.yaklasan} yaklaşıyor</span>}
  </>;
}

/** Kart araç çubuğu: Kopyala · Eksiği olanlara hatırlat · Belge Takip listesinde aç. */
export function BelgeTuruAraclari({ id, ad, git, saltOkunur }: {
  id: number; ad: string; git(yol: string): void; saltOkunur: boolean;
}) {
  const kopyala = async () => {
    if (!await onay(`"${ad}" kapsamıyla birlikte kopyalanacak. Yeni türün adı: "Kopya ${ad}".`)) return;
    await guvenli(async () => {
      const y = await api.belgeTuruKopyala(id);
      git(`/personel-belge-turu/${y.id}`);
    });
  };
  const hatirlat = async () => {
    await guvenli(async () => {
      const idler = (await api.belgeTuruPersonel(id))
        .filter(s => (s.zorunlu && s.durum === 1) || s.durum === 2).map(s => s.personelId);
      if (idler.length === 0) { mesaj('Bu belgede eksiği ya da süresi dolmuş personel yok.'); return }
      if (!await onay(`${idler.length} personele eksik / süresi dolan belgeleri için hatırlatma gönderilecek `
                    + '(e-postası varsa e-posta, yoksa SMS). Onaylıyor musunuz?')) return;
      const y = await api.belgeTakipHatirlat(idler);
      mesaj(`${y.kuyruga} personele hatırlatma gönderim kuyruğuna alındı.`
          + (y.atlanan.length ? `\n\nGönderilmeyen ${y.atlanan.length}:\n` + y.atlanan.map(a => `• ${a.ad}: ${a.neden}`).join('\n') : ''));
    });
  };
  return <>
    <button type="button" className="d" disabled={saltOkunur} onClick={() => void kopyala()}>⧉ Kopyala</button>
    <button type="button" className="d" disabled={saltOkunur} onClick={() => void hatirlat()}>📤 Eksiği olanlara hatırlat</button>
    <button type="button" className="d" onClick={() => git('/personel-belge-ozet')}>📋 Belge Takip listesinde aç</button>
  </>;
}
