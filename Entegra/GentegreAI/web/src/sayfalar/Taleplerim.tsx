import { useEffect, useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { OnayAdimi } from '../api/uclar/onay';
import type { TalepSatiri } from '../api/uclar/izin';
import { useOturum } from '../kimlik/OturumBaglami';
import { para, tarihSaat } from '../bilesenler/bicim';
import { guvenli, metinSor, onay } from '../bilesenler/mesaj';
import { c } from '../dil/ceviri';
import { useTaleplerim, nerede } from '../bilesenler/taleplerim/TaleplerimPaneli';
import { yeniTalepAc, type YeniTalepTuru } from '../bilesenler/taleplerim/YeniTalepModali';
import { GRUP_SINIF, TUR_AD, TUR_IKON, gunYaz, talepleriYenile } from '../bilesenler/taleplerim/useTaleplerimOzeti';
import { ArizaTakipPaneli } from '../bilesenler/taleplerim/ArizaTakipPaneli';
import { GelenEylemler, bekleme, gelenGruplari, iskontoKararAc, onayIkon, type GelenOge } from '../bilesenler/taleplerim/GelenIsler';
import type { OnayBekleyenSatiri } from '../api/uclar/izin';

/**
 * TALEPLERİM `/taleplerim` (mockup Ekranlar/Taleplerim/taleplerim.html).
 *
 * Herkes KENDİ izin, avans, masraf, belge, arıza ve malzeme taleplerini tek
 * yerde açar ve izler: hangi onayda, kaç gündür, kimde. Yetki istemez -
 * sunucu yalnız oturumdaki kişinin kayıtlarını döner (/api/ben/talepler).
 * Onay VERMEK burada değil: "Onayımı bekleyenler" Onayımdakiler ekranına gider.
 */
type GrupSuz = 'acik' | 'tamam' | 'red' | 'taslak' | 'tumu';
const GRUP_CIP: [GrupSuz, string][] = [['acik', 'Açık'], ['tamam', 'Tamamlanan'], ['red', 'Reddedilen'], ['taslak', 'Taslak'], ['tumu', 'Tümü']];
const grupUyar = (s: TalepSatiri, g: GrupSuz) =>
  g === 'tumu' ? true
    : g === 'acik' ? s.grup === 'onayda' || s.grup === 'acik' || s.grup === 'taslak'
      : g === 'tamam' ? s.grup === 'tamam'
        : g === 'red' ? s.grup === 'red' || s.grup === 'iptal'
          : s.grup === 'taslak';

const YENI: { tur: YeniTalepTuru | 'malzeme'; ic: string; ad: string; alt: string }[] = [
  { tur: 'izin', ic: '✈️', ad: 'İzin', alt: 'yıllık · mazeret · yarım gün' },
  { tur: 'avans', ic: '💸', ad: 'Avans', alt: 'maaş avansı · taksitli' },
  { tur: 'masraf', ic: '🧾', ad: 'Masraf', alt: 'fiş / fatura beyanı' },
  { tur: 'belge', ic: '📄', ad: 'Belge', alt: 'çalışma belgesi · maaş yazısı' },
  { tur: 'ariza', ic: '🧰', ad: 'Arıza', alt: 'cihaz · bina · BT' },
  { tur: 'malzeme', ic: '📥', ad: 'Malzeme', alt: 'satınalma talebi' },
];

const anahtar = (s: TalepSatiri) => `${s.tur}-${s.id}`;
const gunOnce = (t: string) => {
  const g = Math.floor((Date.now() - new Date(t).getTime()) / 86400000);
  return g <= 0 ? c('bugün') : g === 1 ? c('dün') : `${g} ${c('gün önce')}`;
};

export function Taleplerim() {
  const oz = useTaleplerim();
  const { kullanici, yetki } = useOturum();
  const git = useNavigate();
  const [parametre, setParametre] = useSearchParams();
  const [grup, setGrup] = useState<GrupSuz>((parametre.get('grup') as GrupSuz) || 'acik');
  const [tur, setTur] = useState<string>('tumu');
  const [ara, setAra] = useState('');
  const secAnahtar = parametre.get('sec');
  const sekme = parametre.get('sekme') === 'gelen' ? 'gelen' : 'benim';
  const sekmeSec = (k: 'gelen' | 'benim') => {
    const p = new URLSearchParams();
    if (k === 'gelen') p.set('sekme', 'gelen');
    setParametre(p, { replace: true });
  };

  // Sayfadan çıkarken hareketler "görüldü" - yeşil nokta söner.
  useEffect(() => () => oz?.gorulduIsaretle(), []); // eslint-disable-line react-hooks/exhaustive-deps

  const satirlar = useMemo(() => oz?.veri?.satirlar ?? [], [oz?.veri]);
  const yeniKume = useMemo(() => new Set((oz?.yeniler ?? []).map(anahtar)), [oz?.yeniler]);

  // Seçili talep listede yoksa (ör. panelden tamamlanmış birine gelindi) süzgeç Tümü'ne açılır.
  useEffect(() => {
    if (!secAnahtar) return;
    const s = satirlar.find(x => anahtar(x) === secAnahtar);
    if (s && !grupUyar(s, grup)) setGrup('tumu');
  }, [secAnahtar, satirlar]); // eslint-disable-line react-hooks/exhaustive-deps

  const sayac = (g: GrupSuz) => satirlar.filter(s => grupUyar(s, g)).length;
  const gorunen = satirlar.filter(s => grupUyar(s, grup) && (tur === 'tumu' || s.tur === tur)
    && (!ara.trim() || `${s.no ?? ''} ${s.baslik} ${s.detay}`.toLocaleLowerCase('tr').includes(ara.trim().toLocaleLowerCase('tr'))));
  const secili = satirlar.find(s => anahtar(s) === secAnahtar) ?? null;
  const sec = (s: TalepSatiri | null) => {
    const p = new URLSearchParams(parametre);
    if (s) p.set('sec', anahtar(s)); else p.delete('sec');
    setParametre(p, { replace: true });
  };

  if (!oz) return null;
  const { veri, bakiye } = oz;
  const personel = veri?.personel ?? false;
  const onayda = satirlar.filter(s => s.grup === 'onayda');
  const enEski = onayda.reduce<TalepSatiri | null>((m, s) =>
    s.adimBaslama && (!m?.adimBaslama || s.adimBaslama < m.adimBaslama) ? s : m, null);
  const enEskiGun = enEski?.adimBaslama ? Math.floor((Date.now() - new Date(enEski.adimBaslama).getTime()) / 86400000) : 0;
  const hak = bakiye ? (bakiye.hakGun ?? 0) + bakiye.devirGun + bakiye.ekGun : 0;
  const yuzde = (n: number) => hak > 0 ? `${Math.min(100, (n / hak) * 100)}%` : '0%';

  const yeniTikla = (t: typeof YENI[number]['tur']) => {
    // ARIZA (954) artık pencere: ayrı sayfaya gitmeden Taleplerim içinde.
    if (t === 'malzeme') git('/satinalma-talep');
    else yeniTalepAc(t);
  };
  const yeniAcik = (t: typeof YENI[number]['tur']) =>
    t === 'ariza' ? yetki('ariza.talep') : t === 'malzeme' ? yetki('satinalma.talep') : personel;

  return (
    <div className="tl-sayfa-dis">
      <div className="sayfabas"><div className="basrow">
        <h1>📨 {c('Taleplerim')}</h1>
        <span className="yol">{kullanici?.ad}{kullanici?.rolAdi ? ` · ${kullanici.rolAdi}` : ''} · {c('taleplerinizi açar, size gelenleri sonuçlandırırsınız')}</span>
        <div className="sag">
          <button type="button" className="d" onClick={() => void oz.yukle()}>⟳ {c('Yenile')}</button>
        </div>
      </div></div>

      <div className="tl-sekmeler">
        <button type="button" className={sekme === 'benim' ? 'on' : ''} onClick={() => sekmeSec('benim')}>
          {c('Taleplerim')} <span className="tl-say">{sayac('acik')} {c('açık')}</span></button>
        {(oz.ekip || (veri?.onaylar?.length ?? 0) > 0 || oz.iskontoTavan > 0) && (
          <button type="button" className={sekme === 'gelen' ? 'on' : ''} onClick={() => sekmeSec('gelen')}>
            {c('Bana gelenler')} {oz.islemBekleyen > 0 && <span className="tl-say tl-say-k">{oz.islemBekleyen}</span>}</button>
        )}
        {yetki('ariza') && <button type="button" onClick={() => git('/ariza-talep')}>{c('Ekibimin işleri')} ↗</button>}
        <button type="button" onClick={() => git('/onay-kutusu')}>{c('Tüm onaylar')} ↗</button>
      </div>

      {sekme === 'gelen' ? <BanaGelenler secAnahtar={secAnahtar} sec={k => {
        const p = new URLSearchParams({ sekme: 'gelen' });
        if (k) p.set('sec', k);
        setParametre(p, { replace: true });
      }} /> : (
      <div className="tl-sayfa">
        <div className="tl-bolum">＋ {c('Yeni talep')}</div>
        <div className="tl-yeni">
          {YENI.map(y => {
            const a = yeniAcik(y.tur);
            return (
              <button key={y.tur} type="button" className="tl-kutu" disabled={!a}
                      title={a ? undefined : y.tur === 'ariza' || y.tur === 'malzeme' ? c('Yetkiniz yok') : c('Personel kartınız yok - İK\'ya başvurun')}
                      onClick={() => yeniTikla(y.tur)}>
                <span className="i">{y.ic}</span><b>{c(y.ad)}</b><span>{c(y.alt)}</span></button>
            );
          })}
        </div>

        <div className="cl-ozetler">
          <div className="cl-kpi"><span className="k">{c('Yıllık izin bakiyem')}</span>
            <span className="v">{bakiye ? `${gunYaz(bakiye.kalan)} ${c('gün')}` : '—'}</span>
            {bakiye && hak > 0 && (
              <div className="tl-bakiye"><i style={{ width: yuzde(bakiye.kullanilanGun + bakiye.planlananGun), background: '#9cc1ea' }} />
                <i style={{ width: yuzde(bakiye.onaydaGun), background: '#e0a33a' }} /></div>
            )}
            <span className="a">{bakiye
              ? `${gunYaz(hak)} ${c('hak')} · ${gunYaz(bakiye.kullanilanGun + bakiye.planlananGun)} ${c('kullanıldı/planlı')} · ${gunYaz(bakiye.onaydaGun)} ${c('onayda')}`
              : personel ? c('bakiye hesaplanamadı') : c('personel kartı yok')}</span></div>
          <button type="button" className={`cl-kpi${enEskiGun >= 3 ? ' dikkat' : ''}`} onClick={() => setGrup('acik')}>
            <span className="k">{c('Açık taleplerim')}</span><span className="v">{sayac('acik')}</span>
            <span className="a">{enEski && enEskiGun > 0 ? `${c('en eskisi')} ${enEskiGun} ${c('gündür')} ${enEski.adimAd ?? ''} ${c('onayında')}` : `${onayda.length} ${c('onayda')}`}</span></button>
          <div className="cl-kpi"><span className="k">{c('Bana ödenecek')}</span>
            <span className="v">{para.format(veri?.odenecek ?? 0)}</span>
            <span className="a">{c('onaylı avans + son 60 gün onaylı masraf')}</span></div>
          <button type="button" className={`cl-kpi${(veri?.onayBekleyen ?? 0) > 0 ? ' kirmizi' : ''}`} onClick={() => git('/onay-kutusu')}>
            <span className="k">{c('Onayımı bekleyen')}</span><span className="v">{veri?.onayBekleyen ?? 0}</span>
            <span className="a">{c('size atanmış onay basamağı')} →</span></button>
        </div>

        <div className="cl-arac tl-arac">
          <input className="tl-ara" value={ara} placeholder={`🔍 ${c('Talep no / konu ara…')}`} onChange={e => setAra(e.target.value)} />
          <span className="cl-ayrac" />
          {GRUP_CIP.map(([k, a]) => (
            <button key={k} type="button" className={`ck-cip tl-cip${grup === k ? ' on' : ''}`} onClick={() => setGrup(k)}>{c(a)} <b>{sayac(k)}</b></button>
          ))}
          <span className="cl-ayrac" />
          {[['tumu', 'Tüm türler'] as const, ...Object.entries(TUR_AD)].map(([k, a]) => (
            <button key={k} type="button" className={`ck-cip tl-cip${tur === k ? ' on' : ''}`} onClick={() => setTur(k)}>
              {k !== 'tumu' ? `${TUR_IKON[k as TalepSatiri['tur']]} ` : ''}{c(a)}</button>
          ))}
        </div>

        <div className={`tl-govde${secili ? ' detayli' : ''}`}>
          <div className="cl-tablo tl-tablo">
            <table className="cl-grid">
              <thead><tr>
                <th>{c('Tür')}</th><th>{c('No · Konu')}</th><th className="tl-sag">{c('Tutar')}</th>
                <th>{c('Durum')}</th><th>{c('Kimde / ne durumda')}</th><th>{c('Son hareket')}</th>
              </tr></thead>
              <tbody>
                {gorunen.map(s => (
                  <tr key={anahtar(s)} onClick={() => sec(secili && anahtar(secili) === anahtar(s) ? null : s)}
                      className={`tl-satir${secili && anahtar(secili) === anahtar(s) ? ' secili' : ''}${s.grup === 'tamam' || s.grup === 'iptal' ? ' pasif' : ''}${yeniKume.has(anahtar(s)) ? ' tl-satir-yeni' : ''}`}>
                    <td><span className={`tl-tur tl-t-${s.tur}`}>{TUR_IKON[s.tur]} {c(TUR_AD[s.tur])}</span></td>
                    <td className="cl-tarih"><b>{s.no || `#${s.id}`}</b> · {s.baslik}<small>{s.detay}</small></td>
                    <td className="tl-sag">{s.tutar ? para.format(s.tutar) : '—'}</td>
                    <td><span className={`tl-chip ${GRUP_SINIF[s.grup]}`}>{s.durumAdi}</span>
                      {yeniKume.has(anahtar(s)) && <span className="tl-chip tl-c-ok" style={{ marginLeft: 4 }}>{c('Yeni')}</span>}</td>
                    <td className="cl-kim">{s.grup === 'onayda' && s.adimAd
                      ? <><b>{s.adimAd}</b><br /><span className={(s.gecikmeGun ?? 0) > 0 ? 'tl-gec' : ''}>{nerede(s).replace(`${s.adimAd} ${c('onayında')}`, '').replace(/^ · /, '') || c('bekliyor')}{(s.gecikmeGun ?? 0) > 0 ? ` · ${c('termin geçti')}` : ''}</span></>
                      : s.grup === 'red' && s.redNeden ? `“${s.redNeden}”` : s.grup === 'taslak' ? c('gönderilmedi') : '—'}</td>
                    <td className="cl-kim">{tarihSaat(s.sonHareket)}<br />{gunOnce(s.sonHareket)}</td>
                  </tr>
                ))}
                {gorunen.length === 0 && (
                  <tr><td colSpan={6} className="sonuk" style={{ padding: 14, textAlign: 'center' }}>
                    {satirlar.length === 0 ? c('Henüz talebiniz yok. Yukarıdan yeni talep açabilirsiniz.') : c('Bu süzgeçte talep yok.')}</td></tr>
                )}
              </tbody>
            </table>
          </div>
          {secili && (secili.tur === 'ariza'
            ? <ArizaTakipPaneli id={secili.id} onKapat={() => sec(null)} />
            : <TalepDetayi s={secili} onKapat={() => sec(null)} />)}
        </div>

        <div className="tl-bilgi">ℹ {c('Onaylanan izin bordroya ve çalışma planına kendiliğinden işlenir; ayrıca çalışma istisnası girilmez - yarım gün izinde yalnız o saatler kapanır.')}</div>
      </div>
      )}
    </div>
  );
}

/**
 * BANA GELENLER (mockup gelen_talepler.html ③): ekibime düşen arıza ve
 * onayıma gelen talep tek listede, grup grup; satırda tek tık işlem, sağda
 * ayrıntı (arıza: takip paneli; onay: zincir + karar).
 */
function BanaGelenler({ secAnahtar, sec }: { secAnahtar: string | null; sec(k: string | null): void }) {
  const oz = useTaleplerim();
  if (!oz) return null;
  const gruplar = gelenGruplari(oz.gelen, oz.veri?.onaylar ?? [], oz.iskontolar);
  const tum = gruplar.flatMap(g => g.ogeler);
  const secili: GelenOge | null = tum.find(o => o.anahtar === secAnahtar) ?? null;
  // Seçili arıza listeden düştüyse (ör. başkası devraldı) yine de panelde açık kalsın.
  const arizaId = secAnahtar?.startsWith('ariza-') ? Number(secAnahtar.slice(6)) : null;

  return (
    <div className="tl-sayfa">
      <div className={`tl-govde${secAnahtar ? ' detayli' : ''}`}>
        <div className="cl-tablo tl-tablo">
          <table className="cl-grid">
            <thead><tr>
              <th>{c('Tür')}</th><th>{c('No · Konu')}</th><th>{c('Talep eden')}</th><th>{c('Bekliyor')}</th><th>{c('İşlem')}</th>
            </tr></thead>
            <tbody>
              {gruplar.map(g => [
                <tr key={g.kod} className="grupbas"><td colSpan={5}>{c(g.ad)}<span>{g.ogeler.length}</span></td></tr>,
                ...g.ogeler.map(o => (
                  <tr key={o.anahtar} onClick={() => o.tip === 'iskonto' ? iskontoKararAc(o.t) : sec(secAnahtar === o.anahtar ? null : o.anahtar)}
                      className={`tl-satir${secAnahtar === o.anahtar ? ' secili' : ''}${g.kod === 'acil' ? ' tl-acil-sat' : ''}`}>
                    {o.tip === 'iskonto' ? <>
                      <td><span className="tl-tur">％ {c('İskonto')}</span></td>
                      <td className="cl-tarih"><b>{o.t.belgeNo}</b> · %{o.t.oran} · {para.format(o.t.tutar)}<small>{o.t.hasta}{o.t.kurum ? ` · ${o.t.kurum}` : ''} · {o.t.satirSayisi} {c('satır')}{o.t.gerekce ? ` · “${o.t.gerekce}”` : ''}</small></td>
                      <td className="cl-kim"><b>{o.t.isteyen}</b>{o.t.doktor && <><br />{o.t.doktor}</>}</td>
                      <td className="cl-kim">{bekleme(o.t.istekTs)}</td>
                    </> : o.tip === 'ariza' ? <>
                      <td><span className="tl-tur tl-t-ariza">🧰 {c('Arıza')}</span></td>
                      <td className="cl-tarih"><b>{o.a.talepNo}</b> · {o.a.aciklama}<small>{o.a.kategoriAdi}{o.a.konum ? ` · ${o.a.konum}` : ''}{o.a.benim ? ` · ${o.a.durumAdi}` : ''}</small></td>
                      <td className="cl-kim"><b>{o.a.talepEdenAdi}</b>{o.a.telefon && <><br />☎ {o.a.telefon}</>}</td>
                      <td className={`cl-kim${g.kod === 'acil' ? ' tl-gec' : ''}`}>{bekleme(o.a.eklemeTarihi)}</td>
                    </> : <>
                      <td><span className="tl-tur">{onayIkon(o.o)} {c('Onay')}</span></td>
                      <td className="cl-tarih"><b>{o.o.kayitNo || '—'}</b> · {o.o.konu}<small>{o.o.akisAd} · {o.o.adimAd}{o.o.olcu ? ` · ${o.o.olcuAdi} ${o.o.olcu}` : ''}</small></td>
                      <td className="cl-kim"><b>{o.o.talepEden}</b></td>
                      <td className={`cl-kim${o.o.gecikmeGun > 0 ? ' tl-gec' : ''}`}>{bekleme(o.o.baslama)}{o.o.gecikmeGun > 0 ? ` · ${c('termin geçti')}` : ''}</td>
                    </>}
                    <td><GelenEylemler oge={o} /></td>
                  </tr>
                )),
              ])}
              {tum.length === 0 && (
                <tr><td colSpan={5} className="sonuk" style={{ padding: 14, textAlign: 'center' }}>{c('Bekleyen işiniz yok.')} ✔</td></tr>
              )}
            </tbody>
          </table>
        </div>
        {arizaId != null && <ArizaTakipPaneli id={arizaId} onKapat={() => sec(null)} />}
        {secili?.tip === 'onay' && <OnayDetayi o={secili.o} onKapat={() => sec(null)} />}
      </div>
      <div className="tl-bilgi">ℹ {c('Yeni iş ekranın sol altına anlık bildirim olarak da düşer. Masaüstü bildirimini Kullanıcı ayarlarım › Bildirimler\'den açabilirsiniz.')}</div>
    </div>
  );
}

/** Onaya gelen talebin zinciri + karar. */
function OnayDetayi({ o, onKapat }: { o: OnayBekleyenSatiri; onKapat(): void }) {
  const [adimlar, setAdimlar] = useState<OnayAdimi[] | null>(null);
  useEffect(() => {
    setAdimlar(null);
    api.onayZinciri(o.kaynakTur, o.kaynakId).then(z => setAdimlar(z.adimlar)).catch(() => setAdimlar([]));
  }, [o.kaynakTur, o.kaynakId]);
  return (
    <div className="tl-detay">
      <div className="tl-grp">
        <h6>{onayIkon(o)} {o.kayitNo || o.akisAd}<span className="tl-chip tl-c-bek" style={{ marginLeft: 'auto' }}>{c('Onayınızda')}</span>
          <button type="button" className="cl-bag sonuk" title={c('Kapat')} onClick={onKapat}>✕</button></h6>
        <div className="tl-ic">
          <div className="tl-sat"><span>{c('Konu')}</span><span>{o.konu}</span></div>
          <div className="tl-sat"><span>{c('Talep eden')}</span><b>{o.talepEden}</b></div>
          {o.olcu ? <div className="tl-sat"><span>{o.olcuAdi || c('Ölçü')}</span><b>{o.olcu}</b></div> : null}
          <div className="tl-sat"><span>{c('Basamak')}</span><span>{o.adimAd} · {bekleme(o.baslama)}</span></div>
          <div className="tl-eylem"><GelenEylemler oge={{ tip: 'onay', anahtar: '', o }} sonra={onKapat} /></div>
        </div>
      </div>
      <div className="tl-grp">
        <h6>{c('Onay akışı')}</h6>
        <div className="tl-ic"><div className="tl-zc">
          {adimlar == null && <div className="sonuk">{c('yükleniyor')}…</div>}
          {adimlar?.map(a => {
            const d = a.durum === 1 || a.durum === 4 ? 'ok' : a.durum === 2 ? 'red' : a.durum === 5 ? 'atla' : 'bek';
            return (
              <div key={a.id} className={`tl-zo ${d}`}><b>{a.sira}. {a.ad}</b>
                <small>{d === 'ok' ? `✓ ${c('onaylandı')}` : d === 'red' ? `✕ ${c('reddedildi')}` : d === 'atla' ? c('atlandı') : c('bekliyor')}{a.kararZamani ? ` · ${tarihSaat(a.kararZamani)}` : ''}</small>
                {a.gerekce && <div className="tl-gerekce">“{a.gerekce}”</div>}</div>
            );
          })}
        </div></div>
      </div>
    </div>
  );
}

/** Sağ panel: seçili talebin özeti, onay zinciri ve eylemler. */
function TalepDetayi({ s, onKapat }: { s: TalepSatiri; onKapat(): void }) {
  const [adimlar, setAdimlar] = useState<OnayAdimi[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const zincirli = s.kaynakTur > 0;

  useEffect(() => {
    setAdimlar(null); setHata(null);
    if (!zincirli || s.grup === 'taslak') return;
    api.onayZinciri(s.kaynakTur, s.id).then(z => setAdimlar(z.adimlar)).catch(e => setHata(hataMetni(e)));
  }, [s.kaynakTur, s.id, s.grup, zincirli]);

  // EYLEMLER: yalnız kendi uçları olan türler. Belge talebi açılışta zincire
  //   girer ve geri çekilemez (İK reddeder); arıza/malzeme kendi ekranında.
  const gonderilir = s.grup === 'taslak' && (s.tur === 'izin' || s.tur === 'avans' || s.tur === 'masraf');
  const cekilir = (s.grup === 'taslak' || s.grup === 'onayda') && (s.tur === 'izin' || s.tur === 'avans' || s.tur === 'masraf');

  const gonder = () => guvenli(async () => {
    if (s.tur === 'izin') await api.izinGonder(s.id);
    else if (s.tur === 'avans') await api.avansGonder(s.id);
    else await api.masrafGonder(s.id);
    talepleriYenile();
  });
  const geriCek = async () => {
    const neden = s.grup === 'taslak'
      ? (await onay(c('Taslak silinsin (iptal) mi?'), true) ? c('Taslak vazgeçildi') : null)
      : await metinSor(c('Talep geri çekilsin mi? Kısa bir neden yazın.'), '', c('Neden'));
    if (!neden) return;
    await guvenli(async () => {
      if (s.tur === 'izin') await api.izinIptal(s.id, neden);
      else if (s.tur === 'avans') await api.avansIptal(s.id, neden);
      else await api.masrafIptal(s.id, neden);
      talepleriYenile();
    });
  };

  return (
    <div className="tl-detay">
      <div className="tl-grp">
        <h6>{TUR_IKON[s.tur]} {s.no || `#${s.id}`} · {s.baslik}
          <span className={`tl-chip ${GRUP_SINIF[s.grup]}`} style={{ marginLeft: 'auto' }}>{s.durumAdi}</span>
          <button type="button" className="cl-bag sonuk" title={c('Kapat')} onClick={onKapat}>✕</button></h6>
        <div className="tl-ic">
          <div className="tl-sat"><span>{c('Ayrıntı')}</span><span>{s.detay}</span></div>
          {s.tutar != null && <div className="tl-sat"><span>{c('Tutar')}</span><b>{para.format(s.tutar)}</b></div>}
          <div className="tl-sat"><span>{c('Açıldı')}</span><span>{tarihSaat(s.eklemeTarihi)}</span></div>
          <div className="tl-sat"><span>{c('Son hareket')}</span><span>{tarihSaat(s.sonHareket)}</span></div>
          {s.redNeden && <div className="tl-sat"><span>{c('Red nedeni')}</span><span className="tl-gec">{s.redNeden}</span></div>}
          {(gonderilir || cekilir) && (
            <div className="tl-eylem">
              {gonderilir && <button type="button" className="d bir" onClick={() => void gonder()}>📨 {c('Onaya gönder')}</button>}
              {cekilir && <button type="button" className="d tl-tehlike" onClick={() => void geriCek()}>↩ {s.grup === 'taslak' ? c('Vazgeç') : c('Geri çek')}</button>}
            </div>
          )}
        </div>
      </div>
      {zincirli && s.grup !== 'taslak' && (
        <div className="tl-grp">
          <h6>{c('Onay akışı')}<span className="tl-grp-ek">{adimlar ? `${adimlar.length} ${c('basamak')}` : ''}</span></h6>
          <div className="tl-ic">
            {hata && <div className="sonuk">{hata}</div>}
            {!hata && adimlar == null && <div className="sonuk">{c('yükleniyor')}…</div>}
            {adimlar?.length === 0 && <div className="sonuk">{c('Bu talep onay zincirine girmedi.')}</div>}
            <div className="tl-zc">
              {adimlar?.map(a => {
                const durum = a.durum === 1 || a.durum === 4 ? 'ok' : a.durum === 2 ? 'red' : a.durum === 5 ? 'atla' : 'bek';
                return (
                  <div key={a.id} className={`tl-zo ${durum}`}>
                    <b>{a.sira}. {a.ad}</b>
                    <small>{durum === 'ok' ? `✓ ${c('onaylandı')}` : durum === 'red' ? `✕ ${c('reddedildi')}` : durum === 'atla' ? c('atlandı') : a.durum === 3 ? c('bilgi istendi') : c('bekliyor')}
                      {a.kararZamani ? ` · ${tarihSaat(a.kararZamani)}` : ''}</small>
                    {a.gerekce && <div className="tl-gerekce">“{a.gerekce}”</div>}
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
