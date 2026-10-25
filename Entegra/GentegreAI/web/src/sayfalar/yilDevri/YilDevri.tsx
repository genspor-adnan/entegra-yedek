import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import {
  yilDevriUclari as api, type DevirDegerleme, type DevirDurumu, type DevirFis, type DevirKontrol,
  type DevirOnizleme, type DevirSecenek,
} from '../../api/uclar/yilDevri';
import { para, tarihSaat } from '../../bilesenler/bicim';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { YD_STILI } from './yilDevriStil';

/**
 * YIL SONU / YIL BAŞI DEVRİ `/yil-devri` — mockup Ekranlar/Muhasebe/yil_sonu_devir.html (1155).
 *
 * Beş adım sıralı ve kilide kadar geri alınabilir; iş kuralları veritabanında (fn_yil_devri_*).
 * Her adımın "Fiş önizleme"si adımı GERÇEK fonksiyonla çalıştırıp geri alır - önizleme ile
 * kesilen fiş aynı koddan çıkar. Cari / kasa / stok bakiyeleri sıfırlanmaz (ekstreler kesintisiz).
 */
const ADIMLAR = [
  { no: 1, ad: 'Ön Kontrol', alt: 'Açık işler, fişlenmemiş belgeler, eksik kurlar' },
  { no: 2, ad: 'Değerleme', alt: '31.12 kuruyla döviz değerlemesi' },
  { no: 3, ad: 'Kapanış', alt: 'Gelir tablosu hesapları kapanır, dönem kârı 590 / 591' },
  { no: 4, ad: 'Yeni Yıl', alt: 'Dönem, belge numaraları, izin hakları' },
  { no: 5, ad: 'Açılış & Kilit', alt: '01.01 açılış fişi, yıl kilidi' },
] as const;

const TUR_ROZET: Record<string, [string, string]> = {
  engel: ['kir', 'Engel'], uyari: ['sari', 'Uyarı'], bilgi: ['mavi', 'Bilgi'],
};
const p = (n: number | null | undefined) => para.format(Number(n ?? 0));
const varsayilanYil = () => { const d = new Date(); return d.getMonth() < 6 ? d.getFullYear() - 1 : d.getFullYear() };

export function YilDevri() {
  const git = useNavigate();
  const { yetki, kullanici } = useOturum();
  const yazabilir = yetki('muhasebe.yil_devri', 'degistir');
  const [yil, setYil] = useState(varsayilanYil);
  const [durum, setDurum] = useState<DevirDurumu | null>(null);
  const [aktif, setAktif] = useState(1);
  const [hata, setHata] = useState<string | null>(null);
  const [calisiyor, setCalisiyor] = useState(false);
  const [sec, setSec] = useState<Required<DevirSecenek>>({ cari: true, hesap: true, bilanco: true, izin: true, kilit: true });

  const tamam = durum?.devir?.tamamAdim ?? 0;
  const kilitli = durum?.devir?.durum === 1;
  const sonraki = Math.min(tamam + 1, 5);

  const yukle = useCallback(async () => {
    setHata(null);
    try {
      const d = await api.yilDevri(yil);
      setDurum(d);
      setAktif(Math.min((d.devir?.tamamAdim ?? 0) + 1, 5));
    } catch (h) { setHata(hataMetni(h)) }
  }, [yil]);
  useEffect(() => { void yukle() }, [yukle]);

  const yurut = async (adim: number) => {
    if (adim === 5 && sec.kilit && !(await onay(
      `${yil} yılı kilitlenecek: 12 aylık dönem kapanır, ${yil} tarihli kayıt girilemez / değiştirilemez. `
      + 'Kilit bu ekrandan geri alınamaz. Devam edilsin mi?'))) return;
    setCalisiyor(true);
    try {
      const d = await api.yilDevriAdim(yil, adim, sec);
      setDurum(d);
      setAktif(Math.min(adim + 1, 5));
      mesaj(`${adim}. adım tamamlandı.`);
    } catch (h) { mesaj(hataMetni(h)) } finally { setCalisiyor(false) }
  };

  const geriAl = async () => {
    if (!(await onay(`${tamam}. adım geri alınsın mı? Bu adımın kestiği fişler ve oluşturduğu kayıtlar silinir.`))) return;
    setCalisiyor(true);
    try { const d = await api.yilDevriGeriAl(yil); setDurum(d); setAktif(Math.min((d.devir?.tamamAdim ?? 0) + 1, 5)) }
    catch (h) { mesaj(hataMetni(h)) } finally { setCalisiyor(false) }
  };

  const fislerAdim = (a: number) => durum?.fisler.filter(f => f.adim === a) ?? [];
  const donemDurum = (y: number) => durum?.donem.find(d => d.yil === y)?.durum;
  const adimDurumu = (n: number) => n <= tamam ? 'tamam' : n === aktif ? 'on' : '';
  const sonuc = Number((durum?.devir?.secenekler as { donemSonucu?: number } | undefined)?.donemSonucu ?? NaN);

  return (
    <div className="yd">
      <style>{YD_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>↪️ {c('Yıl Sonu Devri')}</h1>
          <span className="yol">{c('Muhasebe › Yıl Sonu Devri')}</span>
        </div>
      </div>

      {/* BAŞLIK: hangi yıldan hangisine */}
      <div className="yd-bas">
        <div className="yd-gecis">
          <div className="yd-yil">
            <div className="y">{yil}</div>
            <div className="a">01.01 – 31.12.{yil} · {kilitli || donemDurum(yil) === 2
              ? <span className="rz kir">{c('Kilitli')}</span>
              : tamam > 0 ? <span className="rz sari">{c('Açık · devir sürüyor')}</span>
              : <span className="rz">{c('Açık')}</span>}</div>
          </div>
          <div className="yd-ok">➜</div>
          <div className="yd-yil">
            <div className="y">{yil + 1}</div>
            <div className="a">01.01 – 31.12.{yil + 1} · {tamam >= 4
              ? <span className="rz ok">{c('Hazır')}</span> : <span className="rz mavi">{c('Hazırlanıyor')}</span>}</div>
          </div>
        </div>
        <label className="yd-alan"><span>{c('Devredilen yıl')}</span>
          <select value={yil} onChange={e => setYil(Number(e.target.value))}>
            {Array.from({ length: 6 }, (_, i) => new Date().getFullYear() - 4 + i).map(y => <option key={y} value={y}>{y}</option>)}
          </select>
        </label>
        <div className="yd-bilgi">
          {durum?.devir
            ? <>{c('Devir')} <b>{tamam}/5</b> · {c('başlatan')} {durum.devir.baslatan || '—'} · {tarihSaat(durum.devir.baslama)}
                {kilitli && durum.devir.bitis && <><br />{c('Tamamlandı')} {tarihSaat(durum.devir.bitis)}</>}</>
            : c('Bu yıl için devir başlatılmadı - 1. adımı onaylayınca başlar.')}
          <br />{c('Kapsam')}: {kullanici?.subeler.find(x => x.id === kullanici?.subeId)?.ad ?? c('oturum şubesi')}
        </div>
        <div className="yd-islem">
          <button className="d" disabled={!yazabilir || tamam === 0 || kilitli || calisiyor} onClick={() => void geriAl()}>
            ⟲ {c('Son adımı geri al')}</button>
        </div>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="yd-govde">
        {/* ADIMLAR */}
        <div className="yd-adimlar">
          {ADIMLAR.map(a => (
            <div key={a.no} className={`yd-adim ${adimDurumu(a.no)}`} onClick={() => setAktif(a.no)}>
              <div className="no">{a.no <= tamam ? '✓' : a.no}</div>
              <div><div className="ad">{c(a.ad)}</div><div className="alt">{c(a.alt)}</div></div>
            </div>
          ))}
          <div className="ayr" />
          <div className="kural"><b>{c('Sıra zorunlu')}:</b> {c('bir adım bitmeden sonraki yürütülmez. Her adım tek tek geri alınabilir — 5. adımdaki kilide kadar.')}</div>
          <div className="kural"><b>{c('Sıfırlanmayanlar')}:</b> {c('cari, kasa, banka, stok ve çek bakiyeleri. Ekstreler kesintisizdir; yeni yılın devir satırı hesaplanır, kayıt taşınmaz.')}</div>
        </div>

        {/* İÇERİK */}
        <div className="yd-icerik">
          {aktif === 1 && <KontrolAdimi yil={yil} tamam={tamam >= 1} />}
          {aktif === 2 && <DegerlemeAdimi yil={yil} tamam={tamam >= 2} sec={sec} setSec={setSec} fisler={fislerAdim(2)} />}
          {aktif === 3 && <OnizlemeAdimi yil={yil} adim={3} tamam={tamam >= 3} acik={tamam === 2} sec={sec} fisler={fislerAdim(3)}
            baslik="3 · Kapanış"
            secenekler={<label className="yd-chk"><input type="checkbox" checked={sec.bilanco}
                          onChange={e => setSec(s => ({ ...s, bilanco: e.target.checked }))} />
                          {c('Bilanço kapanış fişi de kesilsin (1–5. sınıf hesaplar 31.12\'de sıfırlanır)')}</label>}
            aciklama={<>{c('7/A yansıtma (7x0 → 7x1 → 151 / 62x / 63x / 660), gelir tablosu hesapları (6xx) → 690 → 692 → 590 kâr / 591 zarar. Vergi karşılığı (691) mali müşavirin fişidir. Kapanıştan sonra ')}{yil}{c('\'ya kayıt girilirse bu adımı geri alıp yeniden yürütün.')}</>} />}
          {aktif === 4 && <OnizlemeAdimi yil={yil} adim={4} tamam={tamam >= 4} acik={tamam === 3} sec={sec} fisler={[]}
            baslik="4 · Yeni Yıl"
            secenekler={<label className="yd-chk"><input type="checkbox" checked={sec.izin}
                          onChange={e => setSec(s => ({ ...s, izin: e.target.checked }))} />
                          {c('Yıllık izin devri (kalan gün yeni yıla, yeni hak kıdeme göre)')}</label>}
            aciklama={<>{yil + 1} {c('mali dönemi ve 12 aylık dönem açılır. Numarasında yıl geçen belge şablonları (e-Fatura / e-Arşiv / protokol) 01.01\'den 1 ile başlayan yeni yıl satırı alır; yılsız numaralar sürer. Açık sipariş, irsaliye, çek ve görevler taşınmaz — kayıt yerinde kalır.')}</>} />}
          {aktif === 5 && <OnizlemeAdimi yil={yil} adim={5} tamam={tamam >= 5} acik={tamam === 4} sec={sec} fisler={fislerAdim(5)}
            baslik="5 · Açılış & Kilit"
            uyari={<><b>{c('Kilit geri alınamaz gibi düşünün')}:</b> {yil} {c('yılının 12 ayı kilitlenir; bu yıla tarihli kayıt girilemez / değiştirilemez. Devir de bu ekrandan geri alınamaz.')}</>}
            secenekler={<label className="yd-chk"><input type="checkbox" checked={sec.kilit}
                          onChange={e => setSec(s => ({ ...s, kilit: e.target.checked }))} />
                          {yil} {c('aylık dönemleri kilitlensin, mali dönem "Kilitli" olsun')}</label>}
            aciklama={<>{c('01.01 açılış fişi: 1–5. sınıf hesapların 31.12 bakiyesi; 590 Dönem Net Kârı → 570 Geçmiş Yıllar Kârları, 591 → 580.')}</>} />}
        </div>

        {/* SAĞ SÜTUN */}
        <div className="yd-yan">
          <h5>{c('Devir özeti')}</h5>
          {ADIMLAR.map(a => (
            <div key={a.no} className="sat"><span>{c(a.ad)}</span>
              <b>{a.no <= tamam ? <span className="rz ok">{c('Tamam')}</span> : a.no === tamam + 1 ? <span className="rz sari">{c('Sırada')}</span> : '—'}</b></div>
          ))}
          <h5>{c('Rakamlar')}</h5>
          <div className="sat"><span>{c('Kesilen fiş')}</span><b>{durum?.fisler.length ?? 0}</b></div>
          {!Number.isNaN(sonuc) && <div className="sat"><span>{c('Dönem sonucu')}</span>
            <b className={sonuc >= 0 ? 'alacak' : 'borc'}>{sonuc >= 0 ? c('Kâr') : c('Zarar')} {p(Math.abs(sonuc))}</b></div>}
          <h5>{c('Günlük')}</h5>
          <ul className="yd-gunluk">
            {(durum?.gunluk ?? []).length === 0 && <li className="sonuk">{c('Henüz işlem yok.')}</li>}
            {durum?.gunluk.map((g, i) => (
              <li key={i} className={g.islem === 'yap' ? 'ok' : g.islem === 'geri' ? 'uy' : ''}>
                {g.aciklama}<br /><small>{tarihSaat(g.zaman)} · {g.kullanici || '—'}</small></li>
            ))}
          </ul>
        </div>
      </div>

      <div className="yd-alt">
        <button className="d" disabled={aktif <= 1} onClick={() => setAktif(a => a - 1)}>◀ {c('Önceki adım')}</button>
        <span className="sonuk">{c('Adım')} {aktif} / 5{kilitli ? ` · ${c('devir tamamlandı')}` : tamam >= aktif ? ` · ${c('bu adım tamamlandı')}` : ''}</span>
        <span className="sp" />
        {!kilitli && aktif === sonraki && tamam < 5 && (
          <button className="d bir" disabled={!yazabilir || calisiyor} onClick={() => void yurut(aktif)}>
            {calisiyor ? c('Çalışıyor…') : `✔ ${c(ADIMLAR[aktif - 1].ad)} — ${c('adımı yürüt')}`}</button>
        )}
        <button className="d" disabled={aktif >= 5} onClick={() => setAktif(a => a + 1)}>{c('Sonraki adım')} ▶</button>
        <button className="d" onClick={() => git(-1)}>✖ {c('Kapat')}</button>
      </div>
    </div>
  );
}

// ------------------------------------------------------------------ adımlar --

function KontrolAdimi({ yil, tamam }: { yil: number; tamam: boolean }) {
  const git = useNavigate();
  const [satirlar, setSatirlar] = useState<DevirKontrol[] | null>(null);
  const tara = useCallback(() => { setSatirlar(null); api.yilDevriKontrol(yil).then(setSatirlar, h => mesaj(hataMetni(h))) }, [yil]);
  useEffect(() => { tara() }, [tara]);
  const engel = satirlar?.filter(s => s.tur === 'engel' && s.adet > 0).length ?? 0;
  return (
    <>
      <div className="yd-pbas"><h3>1 · {c('Ön Kontrol')}</h3>
        {satirlar && (engel ? <span className="rz kir">{engel} {c('engel')}</span> : <span className="rz ok">{c('Engel yok')}</span>)}
        {tamam && <span className="rz ok">{c('Onaylandı')}</span>}
        <span className="sp"><button className="d" onClick={tara}>⟳ {c('Yeniden tara')}</button></span></div>
      <div className="yd-bilgi-serit">{yil} {c('yılında yarım kalan işler. Engel olanlar bitmeden 1. adım onaylanmaz; uyarılar devri durdurmaz. Tarama yalnız okur.')}</div>
      <div className="yd-grp"><h4>{c('Kontrol listesi')}</h4>
        <table className="yd-dg"><thead><tr><th>{c('Kontrol')}</th><th>{c('Tür')}</th><th className="s">{c('Adet')}</th><th className="s">{c('Tutar')}</th><th>{c('Durum')}</th><th /></tr></thead>
          <tbody>
            {!satirlar && <tr><td colSpan={6} className="sonuk">{c('Taranıyor…')}</td></tr>}
            {satirlar?.map(s => {
              const temiz = s.adet === 0;
              const [rz, ad] = TUR_ROZET[s.tur];
              return (
                <tr key={s.kod}>
                  <td>{s.ad}</td><td><span className={`rz ${rz}`}>{c(ad)}</span></td>
                  <td className="s">{s.adet}</td><td className="s">{s.tutar ? p(s.tutar) : ''}</td>
                  <td>{s.tur === 'bilgi' ? <span className="rz mavi">{c('Yeni yıla devreder')}</span>
                    : temiz ? <span className="rz ok">{c('Temiz')}</span>
                    : <span className={`rz ${rz}`}>{s.aciklama || c('Bakılmalı')}</span>}</td>
                  <td>{s.rota && !temiz && <span className="yd-link" onClick={() => git(`/${s.rota}`)}>{c('Listeyi aç')}</span>}</td>
                </tr>
              );
            })}
          </tbody></table>
      </div>
    </>
  );
}

function DegerlemeAdimi({ yil, tamam, sec, setSec, fisler }: {
  yil: number; tamam: boolean; sec: Required<DevirSecenek>;
  setSec: (f: (s: Required<DevirSecenek>) => Required<DevirSecenek>) => void; fisler: DevirFis[];
}) {
  const [satirlar, setSatirlar] = useState<DevirDegerleme[] | null>(null);
  useEffect(() => { setSatirlar(null); api.yilDevriDegerleme(yil).then(setSatirlar, h => mesaj(hataMetni(h))) }, [yil]);
  const secili = useMemo(() => (satirlar ?? []).filter(s => (s.kaynak === 'cari' ? sec.cari : sec.hesap) && s.kur), [satirlar, sec]);
  const gelir = secili.filter(s => s.fark > 0).reduce((t, s) => t + s.fark, 0);
  const gider = secili.filter(s => s.fark < 0).reduce((t, s) => t - s.fark, 0);
  const grup = (k: 'cari' | 'hesap') => (satirlar ?? []).filter(s => s.kaynak === k);
  return (
    <>
      <div className="yd-pbas"><h3>2 · {c('Değerleme')}</h3>{tamam && <span className="rz ok">{c('Fiş kesildi')}</span>}</div>
      <div className="yd-kutular">
        <div><div className="b">{c('Değerleme tarihi')}</div><div className="deg">31.12.{yil}</div><div className="x">{c('TCMB döviz alış (VUK 280)')}</div></div>
        <div><div className="b">{c('Kur farkı geliri')}</div><div className="deg alacak">₺ {p(gelir)}</div><div className="x">646 {c('Kambiyo Kârları')}</div></div>
        <div><div className="b">{c('Kur farkı gideri')}</div><div className="deg borc">₺ {p(gider)}</div><div className="x">656 {c('Kambiyo Zararları')}</div></div>
        <div><div className="b">{c('Net etki')}</div><div className="deg">₺ {p(gelir - gider)}</div><div className="x">{c('dönem kârına eklenir')}</div></div>
      </div>
      <div className="yd-grp"><h4>{c('Dövizli hesaplar')}
        <span className="sp">
          <label className="yd-chk"><input type="checkbox" checked={sec.cari} disabled={tamam} onChange={e => setSec(s => ({ ...s, cari: e.target.checked }))} />{c('Cariler')}</label>
          <label className="yd-chk"><input type="checkbox" checked={sec.hesap} disabled={tamam} onChange={e => setSec(s => ({ ...s, hesap: e.target.checked }))} />{c('Kasa / banka')}</label>
        </span></h4>
        <table className="yd-dg"><thead><tr><th>{c('Hesap')}</th><th>{c('Tür')}</th><th>{c('Döviz')}</th><th className="s">{c('Döviz bakiye')}</th>
          <th className="s">{c('Kayıtlı TL')}</th><th className="s">{c('31.12 kuru')}</th><th className="s">{c('Değerlenmiş TL')}</th><th className="s">{c('Kur farkı')}</th><th>{c('Muhasebe hesabı')}</th></tr></thead>
          <tbody>
            {!satirlar && <tr><td colSpan={9} className="sonuk">{c('Hesaplanıyor…')}</td></tr>}
            {satirlar?.length === 0 && <tr><td colSpan={9} className="sonuk">{c('Dövizli bakiyesi olan hesap yok - değerleme fişi kesilmez.')}</td></tr>}
            {(['cari', 'hesap'] as const).map(k => grup(k).length > 0 && [
              <tr key={k} className="ara"><td colSpan={9}>{k === 'cari' ? c('Cari hesaplar') : c('Kasa / banka')} ({grup(k).length})</td></tr>,
              ...grup(k).map(s => (
                <tr key={`${k}${s.kaynakId}${s.doviz}`} className={(k === 'cari' ? sec.cari : sec.hesap) ? '' : 'pasif'}>
                  <td>{s.ad}</td><td>{s.alt}</td><td>{s.doviz}</td>
                  <td className="s">{p(Math.abs(s.dovizBakiye))} {s.dovizBakiye >= 0 ? 'B' : 'A'}</td>
                  <td className="s">{p(s.yerelBakiye)}</td>
                  <td className="s">{s.kur ? Number(s.kur).toLocaleString('tr-TR', { minimumFractionDigits: 4 }) : <span className="borc">{c('kur yok')}</span>}</td>
                  <td className="s">{p(s.degerli)}</td>
                  <td className={`s ${s.fark > 0 ? 'alacak' : s.fark < 0 ? 'borc' : ''}`}>{s.fark > 0 ? '+' : ''}{p(s.fark)}</td>
                  <td className={s.hesap ? '' : 'borc'}>{s.hesap ?? c('eşleme yok')}</td>
                </tr>
              )),
            ])}
          </tbody></table>
        <div className="yd-ipucu">{c('Kur farkı yalnız muhasebeye işlenir (değerleme fişi, 31.12 tarihli); cari ekstresi değişmez. Müşteriye kur farkı faturası ayrıca kesilir. Stok miktar ve maliyeti değişmez.')}</div>
      </div>
      <OnizlemeAdimi yil={yil} adim={2} tamam={tamam} acik={!tamam} sec={sec} fisler={fisler} gomulu />
    </>
  );
}

/** Önizlenebilen adım: açıklama, seçenekler, "Fiş önizleme" ve kesilmiş fişler. */
function OnizlemeAdimi({ yil, adim, tamam, acik, sec, fisler, baslik, secenekler, aciklama, uyari, gomulu }: {
  yil: number; adim: number; tamam: boolean; acik: boolean; sec: Required<DevirSecenek>; fisler: DevirFis[];
  baslik?: string; secenekler?: React.ReactNode; aciklama?: React.ReactNode; uyari?: React.ReactNode; gomulu?: boolean;
}) {
  const [on, setOn] = useState<DevirOnizleme | null>(null);
  const [yuk, setYuk] = useState(false);
  useEffect(() => { setOn(null) }, [yil, adim, sec]);
  const onizle = async () => {
    setYuk(true);
    try { setOn(await api.yilDevriOnizle(yil, adim, sec)) } catch (h) { mesaj(hataMetni(h)) } finally { setYuk(false) }
  };
  const gosterilen = tamam ? fisler : on?.fisler ?? [];
  return (
    <>
      {!gomulu && <div className="yd-pbas"><h3>{c(baslik ?? '')}</h3>
        {tamam ? <span className="rz ok">{c('Tamamlandı')}</span> : acik ? <span className="rz sari">{c('Sırada')}</span> : <span className="rz">{c('Bekliyor')}</span>}</div>}
      {uyari && !tamam && <div className="yd-kir-serit">{uyari}</div>}
      {aciklama && <div className="yd-bilgi-serit">{aciklama}</div>}
      {(secenekler || !tamam) && (
        <div className="yd-secim">
          {!tamam && secenekler}
          <span className="sp" />
          {!tamam && <button className="d" disabled={!acik || yuk} title={acik ? '' : c('Önceki adımlar tamamlanmalı')}
                             onClick={() => void onizle()}>🔍 {yuk ? c('Hesaplanıyor…') : c('Önizleme')}</button>}
        </div>
      )}
      {!tamam && on && on.kayitlar.length > 0 && (
        <div className="yd-grp"><h4>{c('Oluşturulacak kayıtlar')}</h4>
          <table className="yd-dg"><tbody>
            {on.kayitlar.map(k => <tr key={k.tur}><td>{KAYIT_AD[k.tur] ?? k.tur}</td><td className="s">{k.adet}</td></tr>)}
          </tbody></table></div>
      )}
      {!tamam && on && on.sablonlar.length > 0 && (
        <div className="yd-grp"><h4>{c('Belge numaraları')}</h4>
          <table className="yd-dg"><thead><tr><th>{c('Belge türü')}</th><th>{c('Önceki numara')}</th><th>{c('Yeni yıl önek')}</th><th>{c('Başlangıç')}</th></tr></thead>
            <tbody>{on.sablonlar.map(s => <tr key={s.tur}><td>{s.turAdi}</td><td>{s.eskiNo ?? '—'}</td><td>{s.onEk || '—'}</td><td><b>{s.baslamaNo}</b></td></tr>)}</tbody>
          </table>
          <div className="yd-ipucu">{c('Numarasında yıl geçmeyen şablonlar (makbuz, kasa işlem no) sürer.')}</div></div>
      )}
      {!tamam && on && on.fisler.length === 0 && on.kayitlar.length === 0 && on.sablonlar.length === 0 && (
        <div className="yd-bilgi-serit">{c('Bu adım fiş ya da kayıt üretmiyor (tutarlar sıfır).')}</div>
      )}
      {gosterilen.map(f => <FisTablosu key={f.id} f={f} kesildi={tamam} />)}
    </>
  );
}

const KAYIT_AD: Record<string, string> = {
  mali_donem: 'Mali dönem', muhasebe_donem: 'Aylık muhasebe dönemi', numara_sablonu: 'Yeni yıl numara şablonu',
  izin_hak: 'Personel izin hakkı (yeni yıl)', kilit: 'Kilitlenecek aylık dönem', donem_durum: 'Mali dönem durumu',
};

function FisTablosu({ f, kesildi }: { f: DevirFis; kesildi: boolean }) {
  return (
    <div className="yd-grp"><h4>{f.aciklama}
      <span className="sp">{kesildi ? <span className="rz ok">{f.fisNo}</span> : <span className="rz sari">{c('önizleme')}</span>}
        <span className="sonuk">{tarihSaat(f.tarih).slice(0, 10)}</span></span></h4>
      <table className="yd-dg yd-fis"><thead><tr><th>{c('Hesap')}</th><th className="s">{c('Borç')}</th><th className="s">{c('Alacak')}</th></tr></thead>
        <tbody>{f.satirlar.map(s => (
          <tr key={s.kod}><td>{s.kod} {s.ad}{s.adet > 1 && <span className="sonuk"> · {s.adet} {c('satır')}</span>}</td>
            <td className="s">{Number(s.borc) ? p(s.borc) : ''}</td><td className="s">{Number(s.alacak) ? p(s.alacak) : ''}</td></tr>
        ))}</tbody>
        <tfoot><tr><td>{c('Toplam')}</td><td className="s">{p(f.borc)}</td><td className="s">{p(f.alacak)}</td></tr></tfoot>
      </table>
    </div>
  );
}
