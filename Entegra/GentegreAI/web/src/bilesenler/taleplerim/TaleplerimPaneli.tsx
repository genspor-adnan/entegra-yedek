import { useEffect, useState } from 'react';
import { TaleplerimBaglami, useTaleplerim } from './taleplerimBaglami';
import { DuyuruListesi, duyuruKartAc } from '../duyuru/DuyuruOrtak';
import { useOturum } from '../../kimlik/OturumBaglami';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { para } from '../bicim';
import { guvenli, metinSor } from '../mesaj';
import { c } from '../../dil/ceviri';
import { yeniTalepAc, type YeniTalepTuru } from './YeniTalepModali';
import { GelenEylemler, bekleme, gelenGruplari, iskontoKararAc, onayIkon } from './GelenIsler';
import { GRUP_SINIF, TUR_IKON, gunYaz, talepleriYenile } from './useTaleplerimOzeti';
import type { TalepSatiri } from '../../api/uclar/izin';

/**
 * TALEPLER ERİŞİMİ (mockup taleplerim.html bölüm 0 + gelen_talepler.html):
 *  ① üst şeritte 📨 = TALEPLERİM (yeşil nokta: kendi talebimde yeni hareket;
 *    hızlı talep + son 5 talep). TALEBİ ALANIN işi 🔔'de: BanaGelenlerPaneli.
 *  ② avatar menüsü - en üstte Taleplerim, izin bakiyem, ödenecek tutar.
 * Veri kabukta bir kez okunur (useTaleplerimOzeti) ve bağlamla dağıtılır;
 * Taleplerim sayfası ve anlık bildirimler de aynı bağlamı kullanır.
 */
export { TaleplerimBaglami, useTaleplerim };

const HIZLI: [YeniTalepTuru, string, string][] = [
  ['izin', '✈️', 'İzin'], ['avans', '💸', 'Avans'], ['masraf', '🧾', 'Masraf'], ['belge', '📄', 'Belge'], ['ariza', '🔧', 'Arıza'],
];

/** Satırın ikinci satırı: onaydaysa kimde ve kaç gündür; değilse durum. */
export function nerede(s: TalepSatiri): string {
  if (s.grup === 'onayda' && s.adimAd) {
    const g = s.adimBaslama ? Math.floor((Date.now() - new Date(s.adimBaslama).getTime()) / 86400000) : 0;
    return `${s.adimAd} ${c('onayında')}${g > 0 ? ` · ${g} ${c('gündür')}` : ''}`;
  }
  if (s.grup === 'red' && s.redNeden) return `${c('Red')}: ${s.redNeden}`;
  return s.durumAdi;
}

/** Dışarı tıklanınca kapanan küçük açılır pencere - zil/dil menüsü ile aynı davranış. */
function useDisariKapat(acik: boolean, kapat: () => void) {
  useEffect(() => {
    if (!acik) return;
    window.addEventListener('click', kapat);
    return () => window.removeEventListener('click', kapat);
  }, [acik, kapat]);
}

const PERSONEL_YOK = "Personel kartınız yok - İK'ya başvurun";

export function TaleplerimPaneli() {
  const oz = useTaleplerim();
  const git = useNavigate();
  const [acik, setAcik] = useState(false);
  const kapat = () => { setAcik(false); oz?.gorulduIsaretle() };
  useDisariKapat(acik, kapat);
  if (!oz) return null;
  const { veri, bakiye, yeniler, acik: aciklar } = oz;
  const yeniKume = new Set(yeniler.map(s => `${s.tur}${s.id}`));
  const son5 = (veri?.satirlar ?? []).slice(0, 5);
  const personel = veri?.personel ?? false;
  const ac = () => { setAcik(true); void oz.yukle() };
  const kapatKendi = (s: TalepSatiri) => guvenli(async () => { await api.arizaOnayla(s.id); talepleriYenile() });
  const yenidenAc = async (s: TalepSatiri) => {
    const n = await metinSor(c('Ne düzelmedi?'), '', c('Açıklama'));
    if (n) await guvenli(async () => { await api.arizaYenidenAc(s.id, n); talepleriYenile() });
  };

  return (
    <span className="zil-sar" onMouseDown={e => e.stopPropagation()}>
      <button type="button" className={`ib${acik ? ' on' : ''}`} title={c('Taleplerim')}
              onClick={e => { e.stopPropagation(); if (acik) kapat(); else ac() }}>
        📨
        {yeniler.length > 0 && <span className="tl-nokta" title={c('Talebinizde yeni hareket')} />}
      </button>
      {acik && (
        <div className="zil-panel tl-panel" onClick={e => e.stopPropagation()}>
          <div className="zil-baslik tl-pb">📨 {c('Taleplerim')}
            <span>{`${aciklar.length} ${c('açık')}${yeniler.length > 0 ? ` · ${yeniler.length} ${c('yeni hareket')}` : ''}`}</span></div>
          <>
            <div className="tl-hizli">
              {HIZLI.map(([t, ic, ad]) => {
                const olur = personel || t === 'ariza';
                return (
                  <button key={t} type="button" disabled={!olur} title={olur ? undefined : c(PERSONEL_YOK)}
                          onClick={() => { kapat(); yeniTalepAc(t) }}><i>{ic}</i>{c(ad)}</button>
                );
              })}
            </div>
            {son5.length === 0 && <div className="zil-bos">{c('Henüz talebiniz yok.')}</div>}
            <ul className="tl-son">
              {son5.map(s => {
                const yeni = yeniKume.has(`${s.tur}${s.id}`);
                const cozuldu = s.tur === 'ariza' && s.durum === 4;
                return (
                  <li key={`${s.tur}${s.id}`} className={yeni || cozuldu ? 'yeni' : ''}
                      onClick={() => { kapat(); git(`/taleplerim?sec=${s.tur}-${s.id}`) }}>
                    <span>{TUR_IKON[s.tur]}</span>
                    <span><b>{s.baslik}{s.tutar ? ` ${para.format(s.tutar)}` : ''}</b> · {s.detay}
                      <small>{nerede(s)}</small></span>
                    {cozuldu ? (
                      <span className="tl-ey">
                        <button type="button" className="d tl-ok" title={c('Evet, kapat')}
                                onClick={e => { e.stopPropagation(); void kapatKendi(s) }}>✔ {c('Kapat')}</button>
                        <button type="button" className="d tl-tehlike" title={c('Düzelmedi, yeniden aç')}
                                onClick={e => { e.stopPropagation(); void yenidenAc(s) }}>↩</button>
                      </span>
                    ) : <span className={`tl-chip ${GRUP_SINIF[s.grup]}`}>{yeni ? c('Yeni') : s.durumAdi}</span>}
                  </li>
                );
              })}
            </ul>
          </>
          <div className="tl-pa">
            <span>{bakiye ? <>✈️ {c('İzin bakiyem')}: <b>{gunYaz(bakiye.kalan)} {c('gün')}</b></> : ''}</span>
            <button type="button" className="tl-link" onClick={() => { kapat(); git('/taleplerim') }}>{c('Tümünü gör')} →</button>
          </div>
        </div>
      )}
    </span>
  );
}

/**
 * 🔔 BİLDİRİMLER = BANA GELENLER (kullanıcı: "taleplerim burada kalsın, bana
 * gelenleri duyuru (zil)'e aktar - bu format / görünüm ile"). Kırmızı rozet
 * işlem bekleyen iş (bana gelen arıza + onayımı bekleyen + iskonto); yeni iş
 * gelince nabız atar. Gruplar ve tek tık işlemler GelenIsler'de.
 */
export function BanaGelenlerPaneli() {
  const oz = useTaleplerim();
  const git = useNavigate();
  const { yetki } = useOturum();
  const [acik, setAcik] = useState(false);
  const [sekme, setSekme] = useState<'gelen' | 'duyuru'>('gelen');
  const kapat = () => setAcik(false);
  useDisariKapat(acik, kapat);
  if (!oz) return null;
  const { veri, gelen, islemBekleyen, nabiz, duyurular, duyuruYeni } = oz;
  const gruplar = gelenGruplari(gelen, veri?.onaylar ?? [], oz.iskontolar);
  // AÇILIŞ SEKMESİ: işlem bekleyen varsa iş, yoksa okunmamış duyuru varsa duyurular.
  const ac = () => {
    setSekme(islemBekleyen > 0 || duyuruYeni === 0 ? 'gelen' : 'duyuru');
    setAcik(true); oz.nabziSondur(); void oz.yukle();
  };

  return (
    <span className="zil-sar" onMouseDown={e => e.stopPropagation()}>
      <button type="button" className={`ib${acik ? ' on' : ''}`} title={c('Bildirimler')}
              onClick={e => { e.stopPropagation(); if (acik) kapat(); else ac() }}>
        🔔
        {islemBekleyen > 0 && <span className={`zil-rozet${nabiz ? ' tl-nabiz' : ''}`} title={c('İşlem bekleyen')}>{islemBekleyen}</span>}
        {duyuruYeni > 0 && <span className="dy-mavi" title={c('Okunmamış duyuru')}>{duyuruYeni}</span>}
      </button>
      {acik && (
        <div className="zil-panel tl-panel" onClick={e => e.stopPropagation()}>
          <div className="zil-baslik tl-pb">🔔 {c('Bildirimler')}
            <span>{[islemBekleyen > 0 ? `${islemBekleyen} ${c('işlem bekliyor')}` : '',
                    duyuruYeni > 0 ? `${duyuruYeni} ${c('okunmamış duyuru')}` : ''].filter(Boolean).join(' · ')}</span></div>
          <div className="tl-psek">
            <button type="button" className={sekme === 'gelen' ? 'on' : ''} onClick={() => setSekme('gelen')}>
              {c('Bana gelenler')}{islemBekleyen > 0 && <b>{islemBekleyen}</b>}</button>
            <button type="button" className={sekme === 'duyuru' ? 'on' : ''} onClick={() => setSekme('duyuru')}>
              {c('Duyurular')}{duyuruYeni > 0 && <b className="dy-b">{duyuruYeni}</b>}</button>
          </div>
          {sekme === 'duyuru' ? <DuyuruListesi satirlar={duyurular} sonra={kapat} /> : <>
            <ul className="tl-son tl-gelen">
              {gruplar.length === 0 && <li className="tl-bos">{c('Bekleyen işiniz yok.')} ✔</li>}
              {gruplar.map(g => [
                <li key={g.kod} className="tl-grpb">{c(g.ad)}</li>,
                ...g.ogeler.map(o => o.tip === 'iskonto' ? (
                  <li key={o.anahtar} onClick={() => { kapat(); iskontoKararAc(o.t) }}>
                    <span>％</span>
                    <span><b>%{o.t.oran} · {para.format(o.t.tutar)}</b> · {o.t.hasta || o.t.belgeNo}
                      <small>{c('isteyen')}: {o.t.isteyen} · {bekleme(o.t.istekTs)}{o.t.gerekce ? ` · “${o.t.gerekce}”` : ''}</small></span>
                    <GelenEylemler oge={o} sonra={kapat} />
                  </li>
                ) : o.tip === 'ariza' ? (
                  <li key={o.anahtar} className={g.kod === 'acil' ? 'tl-li-acil' : ''}
                      onClick={() => { kapat(); git(`/taleplerim?sekme=gelen&sec=${o.anahtar}`) }}>
                    <span>🧰</span>
                    <span><b>{o.a.talepNo} · {o.a.aciklama}</b>{o.a.konum ? ` · ${o.a.konum}` : ''}
                      <small>{o.a.talepEdenAdi}{o.a.telefon ? ` · ☎ ${o.a.telefon}` : ''} · {bekleme(o.a.eklemeTarihi)} {c('önce')}{o.a.benim ? ` · ${o.a.durumAdi}` : ''}</small></span>
                    <GelenEylemler oge={o} ata={false} />
                  </li>
                ) : (
                  <li key={o.anahtar} onClick={() => { kapat(); git(`/taleplerim?sekme=gelen&sec=${o.anahtar}`) }}>
                    <span>{onayIkon(o.o)}</span>
                    <span><b>{o.o.konu}</b> · {o.o.talepEden}
                      <small>{o.o.adimAd} · {bekleme(o.o.baslama)}{o.o.gecikmeGun > 0 ? ` · ${c('termin geçti')}` : ''}</small></span>
                    <GelenEylemler oge={o} />
                  </li>
                )),
              ])}
            </ul>
          </>}
          <div className="tl-pa">
            {sekme === 'duyuru' && yetki('duyuru', 'ekle')
              ? <button type="button" className="tl-link" onClick={() => { kapat(); duyuruKartAc() }}>＋ {c('Duyuru yayınla')}</button>
              : <span />}
            {sekme === 'duyuru'
              ? (yetki('duyuru') ? <button type="button" className="tl-link" onClick={() => { kapat(); git('/duyurular') }}>{c('Tüm duyurular')} →</button> : <span />)
              : <button type="button" className="tl-link" onClick={() => { kapat(); git('/taleplerim?sekme=gelen') }}>{c('Tümünü gör')} →</button>}
          </div>
        </div>
      )}
    </span>
  );
}

/**
 * AVATAR MENÜSÜ (mockup ②): avatar eskiden doğrudan Kullanıcı Ayarları'nı
 * açıyordu; artık önce kişisel kısayollar, ayarlar menünün içinde.
 */
export function KullaniciMenusu({ ad, rolAdi, avatar, onAyarlar, onCikis }: {
  ad: string; rolAdi?: string; avatar: React.ReactNode; onAyarlar(): void; onCikis(): void;
}) {
  const oz = useTaleplerim();
  const git = useNavigate();
  const [acik, setAcik] = useState(false);
  const kapat = () => setAcik(false);
  useDisariKapat(acik, kapat);
  const bekleyen = oz?.islemBekleyen ?? 0;
  const odenecek = oz?.veri?.odenecek ?? 0;
  const sec = (f: () => void) => () => { kapat(); f() };

  return (
    <span className="zil-sar" onMouseDown={e => e.stopPropagation()}>
      <button type="button" className={`avt${acik ? ' on' : ''}`} title={ad}
              onClick={e => { e.stopPropagation(); setAcik(a => !a) }}>{avatar}</button>
      {acik && (
        <div className="zil-panel tl-kmenu" onClick={e => e.stopPropagation()}>
          <div className="zil-baslik tl-pb">{ad}<span>{rolAdi}</span></div>
          <button type="button" className="vurgu" onClick={sec(() => git(bekleyen > 0 ? '/taleplerim?sekme=gelen' : '/taleplerim'))}>
            📨 {c('Taleplerim')}{bekleyen > 0 && <span className="tl-rzk">{bekleyen}</span>}</button>
          {oz?.bakiye && (
            <button type="button" onClick={sec(() => git('/taleplerim'))}>
              ✈️ {c('İzin bakiyem')}<span className="tl-km-sag">{gunYaz(oz.bakiye.kalan)} {c('gün')}</span></button>
          )}
          {oz?.veri?.personel && (
            <button type="button" onClick={sec(() => git('/taleplerim?grup=acik'))}>
              💸 {c('Avans / masraf')}<span className="tl-km-sag">{odenecek > 0 ? `${para.format(odenecek)} ${c('ödenecek')}` : '—'}</span></button>
          )}
          <i className="ayr" />
          <button type="button" onClick={sec(onAyarlar)}>⚙ {c('Kullanıcı ayarlarım')}</button>
          <i className="ayr" />
          <button type="button" className="cikis" onClick={sec(onCikis)}>🚪 {c('Çıkış')}</button>
        </div>
      )}
    </span>
  );
}
