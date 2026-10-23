import { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import {
  bankaHareketUclari as api, type BankaHareketDetayi, type BankaHesapOzeti, type BankaKarar, type BankaOzeti,
} from '../../api/uclar/bankaHareket';
import { listeUclari } from '../../api/uclar/liste';
import { para, tarihSaat } from '../../bilesenler/bicim';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { TarafArama } from '../../bilesenler/TarafArama';
import { c } from '../../dil/ceviri';

/**
 * BANKA HAREKETLERİ ekranının parçaları (1157, mockup Ekranlar/ERP/banka_hareketleri.html):
 *  · `BankaOzetSeridi` - hesap seçimi, "Bankadan Çek", son çekim, sayaç kutuları, banka / sistem bakiyesi.
 *  · `BankaHareketYanPanel` - seçili hareketin bankadan gelen bilgisi, öneri / karar ve "İşle".
 *  · `bankaAksiyonu` - araç çubuğu aksiyonları (çek, işle, önerilenleri işle, yoksay, geri al, öneri yenile).
 * Liste genel liste kaynağı (`banka-hareket`), hesaba ?hesapId= ile süzülür.
 */
export const BH_STILI = `
.bh-serit { display:flex; flex-direction:column; gap:8px; margin-bottom:8px }
.bh-arac { display:flex; gap:10px; align-items:flex-end; flex-wrap:wrap }
.bh-arac label { display:flex; flex-direction:column; gap:2px; font-size:11px; color:var(--soluk) }
.bh-arac select { min-width:320px }
.bh-cekim { font-size:11px; color:var(--soluk); line-height:1.4 }
.bh-kutular { display:grid; grid-template-columns:repeat(7, minmax(0,1fr)); border:1px solid var(--cizgi2); border-radius:var(--r); background:var(--kartzem) }
.bh-kutular > div { padding:7px 11px; border-right:1px solid var(--cizgi2); cursor:pointer }
.bh-kutular > div:last-child { border-right:none }
.bh-kutular > div.on { background:#eef5fd; box-shadow:inset 0 -2px 0 #2f6fb5 }
.bh-kutular .b { font-size:10.5px; color:var(--soluk); text-transform:uppercase; letter-spacing:.3px }
.bh-kutular .deg { font-size:16px; font-weight:bold; margin-top:2px }
.bh-kutular .x { font-size:10.5px; color:var(--soluk) }
.bh-uyari { border:1px solid var(--uyarikenar); background:var(--uyarizem); color:var(--uyari); border-radius:4px; padding:6px 10px; font-size:12px }
.bh-yan { padding:8px 10px; font-size:12px }
.bh-yan h5 { margin:10px 0 5px; font-size:10.5px; color:var(--soluk); text-transform:uppercase; letter-spacing:.4px }
.bh-yan h5:first-child { margin-top:0 }
.bh-kutu { border:1px solid var(--cizgi2); border-radius:4px; background:#fff; padding:6px 9px; line-height:1.55 }
.bh-sat { display:flex; justify-content:space-between; gap:10px }
.bh-sat span { color:var(--soluk) }
.bh-sat b { font-weight:normal; text-align:right; word-break:break-all }
.bh-secenek { display:flex; gap:8px; align-items:flex-start; padding:6px 8px; border:1px solid var(--cizgi2); border-radius:4px; margin-bottom:5px; background:#fff; cursor:pointer }
.bh-secenek.on { border-color:#9cc4ee; background:#f4f9ff }
.bh-secenek select { width:100%; margin-top:4px }
.bh-yan .tam { width:100%; justify-content:center; margin-top:6px }
.bh-tablo { width:100%; border-collapse:collapse; font-size:12px; background:#fff }
.bh-tablo th { text-align:left; font-weight:normal; color:var(--soluk); border-bottom:1px solid var(--cizgi2); padding:5px 8px; background:#f4f7fb }
.bh-tablo td { border-bottom:1px solid var(--cizgi2); padding:5px 8px }
.bh-tablo .sag { text-align:right }
.bh-borc { color:var(--hata) } .bh-alacak { color:var(--ok) } .bh-soluk { color:var(--soluk) }
`;

const tl = (n: number | null | undefined) => para.format(Number(n ?? 0));

// ------------------------------------------------------------- üst şerit --
export function BankaOzetSeridi({ yenile, onCip, onYenile }: { yenile: number; onCip(i: number): void; onYenile(): void }) {
  const [sorgu] = useSearchParams();
  const git = useNavigate();
  const hesapId = Number(sorgu.get('hesapId')) || null;
  const [o, setO] = useState<BankaOzeti | null>(null);
  const [cekiyor, setCekiyor] = useState(false);
  useEffect(() => { api.bankaOzet(hesapId).then(setO, h => mesaj(hataMetni(h))) }, [hesapId, yenile]);

  const cek = async () => {
    setCekiyor(true);
    try {
      const y = await api.bankaCek(hesapId);
      mesaj(y.sonuclar.map(s => s.mesaj ?? s.hata ?? '').filter(Boolean).join('\n') || c('Bağlı hesap yok.'));
      onYenile();
    } catch (h) { mesaj(hataMetni(h)) } finally { setCekiyor(false) }
  };
  const h = o?.hesap, s = o?.sayac;
  const fark = h?.bankaBakiye != null ? Number(h.bankaBakiye) - Number(h.sistemBakiye) : null;
  const kutu = (b: string, d: React.ReactNode, x: string, cip?: number, sinif = '') => (
    <div onClick={() => cip !== undefined && onCip(cip)}><div className="b">{c(b)}</div><div className={`deg ${sinif}`}>{d}</div><div className="x">{x}</div></div>
  );
  return (
    <div className="bh-serit">
      <style>{BH_STILI}</style>
      <div className="bh-arac">
        <label>{c('Banka hesabı')}
          <select value={hesapId ?? ''} onChange={e => git(`/banka-hareket${e.target.value ? `?hesapId=${e.target.value}` : ''}`, { replace: true })}>
            <option value="">{c('Bütün banka hesapları')}</option>
            {o?.hesaplar.map(x => <option key={x.id} value={x.id}>{x.kaynak === 1 ? '🟢' : x.kaynak === 2 ? '📄' : '⚪'} {x.ad}{x.iban ? ` · ${x.iban}` : ''}</option>)}
          </select>
        </label>
        <button className="d bir" disabled={cekiyor} onClick={() => void cek()}>⟳ {cekiyor ? c('Çekiliyor…') : hesapId ? c('Bankadan Çek') : c('Tümünü Çek')}</button>
        {h && <div className="bh-cekim">
          {c('Son çekim')}: <b>{h.sonCekim ? tarihSaat(h.sonCekim) : '—'}</b>
          {' · '}{h.kaynak === 1 ? (h.cekmeDk > 0 ? `${c('otomatik')}, ${h.cekmeDk >= 1440 ? c('günde bir') : `${h.cekmeDk} ${c('dk\'da bir')}`}` : c('elle'))
                 : h.kaynak === 2 ? c('dosyadan') : c('bağlantı kapalı')}
          <br />{h.sonSonuc || ''}{h.entegrasyon && ` · ${h.entegrasyon}`}{h.test && <b className="bh-borc"> · {c('TEST / BENZETİM')}</b>}
        </div>}
      </div>
      {h && h.kaynak === 1 && h.onayBitis && new Date(h.onayBitis) < new Date() && (
        <div className="bh-uyari">{c('Banka onayının (consentId) süresi doldu - çekim durur. Bankada onayı yenileyip kartın Banka Bağlantısı sekmesine girin.')}</div>
      )}
      {s && (
        <div className="bh-kutular">
          {kutu('Çekilen', s.cekilen, c('toplam'), 6)}
          {kutu('Bekleyen', s.bekleyen, `₺ ${tl(s.bekleyenTutar)}`, 0)}
          {kutu('Öneri hazır', s.oneriHazir, c('güvenli eşleşme'), 1, 'bh-alacak')}
          {kutu('Seçim bekliyor', s.secimBekleyen, c('karar gerekir'), 2)}
          {kutu('İşlendi', s.islendi, c('kasa işlemi oluştu'), 4)}
          {kutu('Banka bakiyesi', h?.bankaBakiye != null ? tl(h.bankaBakiye) : '—', h ? c('son hareket sonrası') : c('hesap seçin'))}
          {kutu('Sistem bakiyesi', h ? tl(h.sistemBakiye) : '—',
                fark == null ? '' : Math.abs(fark) < 0.005 ? c('mutabık') : `${c('fark')} ${tl(fark)}`, undefined,
                fark != null && Math.abs(fark) >= 0.005 ? 'bh-borc' : '')}
        </div>
      )}
    </div>
  );
}

// ------------------------------------------- Banka Hesabı Listesi şeridi --
/** Mockup "Banka Hesabı Listesi" özeti: kutu tıklanınca o çip (Aktif 0 · Bağlı 1 · Bekleyeni olan 2 · Dikkat 3). */
export function BankaHesapSeridi({ yenile, onCip, cip }: { yenile: number; onCip(i: number): void; cip?: number }) {
  const [o, setO] = useState<BankaHesapOzeti | null>(null);
  useEffect(() => { api.bankaHesapOzet().then(setO, () => setO(null)) }, [yenile]);
  if (!o) return null;
  const kutu = (b: string, d: React.ReactNode, x: string, k?: number, sinif = '') => (
    <div onClick={() => k !== undefined && onCip(k)} className={k !== undefined && k === cip ? 'on' : ''}
         style={k === undefined ? { cursor: 'default' } : undefined}>
      <div className="b">{c(b)}</div><div className={`deg ${sinif}`}>{d}</div><div className="x">{x}</div></div>
  );
  return (
    <div className="bh-serit">
      <style>{BH_STILI}</style>
      <div className="bh-kutular" style={{ gridTemplateColumns: 'repeat(6, minmax(0,1fr))' }}>
        {kutu('Hesap', o.hesap, `${o.tl} TL · ${o.doviz} ${c('döviz')}`, 0)}
        {kutu('Bağlı (API)', o.api, o.apiBankalar || '—', 1, 'bh-alacak')}
        {kutu('Dosyadan', o.dosya, o.dosyaBankalar || '—')}
        {kutu('Bekleyen hareket', o.bekleyen, c('işlenmemiş'), 2)}
        {kutu('Dikkat', o.dikkat, c('onay süresi · çekim hatası'), 3, o.dikkat ? 'bh-borc' : '')}
        {kutu('Toplam (TL karşılığı)', `₺ ${tl(o.toplam)}`, c('sistem bakiyesi'))}
      </div>
    </div>
  );
}

// ----------------------------------------- Banka Hesabı Kartı başlığı --
/** Kart başlığındaki bağlantı hapı: API · sıklık / onay süresi doldu · Dosya · Kapalı. */
export function BankaBaglantiRozeti({ deger }: { deger: Record<string, unknown> }) {
  const kaynak = Number(deger.bankaKaynak ?? 0), dk = Number(deger.bankaCekmeDk ?? 0);
  const bitis = deger.bankaOnayBitis ? new Date(String(deger.bankaOnayBitis)) : null;
  const doldu = kaynak === 1 && bitis !== null && bitis < new Date();
  const [sinif, metin] = kaynak === 1
    ? doldu ? ['hata', c('API · onay süresi doldu')]
      : ['ok', `API · ${dk >= 1440 ? c('günde 1') : dk > 0 ? `${dk} dk` : c('elle')}`]
    : kaynak === 2 ? ['mavi', c('Dosya')] : ['gri', c('Bağlantı kapalı')];
  return <span className={`rozet ${sinif}`} style={{ marginLeft: 8 }}>{metin}</span>;
}

// ----------------------------------------- Banka Hesabı Kartı › Hareketler --
const DURUM_SINIF: Record<string, string> = { 'Öneri hazır': 'ok', 'İşlendi': 'mavi', 'Seçim bekliyor': 'uyari' };

/** Kartın "Hareketler" sekmesi: son çekilen 20 hareket; tamamı ve işleme Banka Hareketleri ekranında. */
export function BankaHesapHareketleri({ hesapId, git }: { hesapId: number; git(yol: string): void }) {
  const [satirlar, setSatirlar] = useState<ListeSatiri[] | null>(null);
  useEffect(() => {
    listeUclari.liste('banka-hareket', { sayfa: 1, boyut: 20, filtre: { alan: 'hesapId', op: 'esit', deger: hesapId } })
      .then(y => setSatirlar(y.satirlar), h => { mesaj(hataMetni(h)); setSatirlar([]) });
  }, [hesapId]);
  return (
    <div style={{ padding: '10px 12px' }}>
      <style>{BH_STILI}</style>
      {satirlar === null ? <div className="bh-soluk">{c('Yükleniyor…')}</div>
        : satirlar.length === 0 ? <div className="bh-soluk">{c('Bu hesaba henüz bankadan hareket çekilmedi.')}</div>
        : (
          <table className="bh-tablo">
            <thead><tr><th>{c('Tarih')}</th><th>{c('Açıklama (banka)')}</th><th className="sag">{c('Tutar')}</th>
              <th className="sag">{c('Bakiye')}</th><th>{c('Durum')}</th></tr></thead>
            <tbody>{satirlar.map(s => {
              const t = Number(s.tutar ?? 0);
              return (
                <tr key={String(s.id)}>
                  <td style={{ whiteSpace: 'nowrap' }}>{tarihSaat(s.islemTarihi)}</td>
                  <td>{String(s.aciklama ?? '')}</td>
                  <td className={`sag ${t > 0 ? 'bh-alacak' : 'bh-borc'}`}>{t > 0 ? '+' : ''}{tl(t)}</td>
                  <td className="sag">{s.bakiye == null ? '' : tl(Number(s.bakiye))}</td>
                  <td><span className={`rozet ${DURUM_SINIF[String(s.durumAdi ?? '')] ?? 'gri'}`}>{c(String(s.durumAdi ?? ''), 'kod')}</span></td>
                </tr>
              );
            })}</tbody>
          </table>
        )}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 8 }}>
        <span className="bh-soluk">{c('Son çekilen banka hareketleri - tamamı ve işleme "Banka Hareketleri" ekranında.')}</span>
        <span style={{ flex: 1 }} />
        <button className="d bir" type="button" onClick={() => git(`/banka-hareket?hesapId=${hesapId}`)}>🏦 {c('Banka Hareketleri')}</button>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------- yan panel --
const TUR_AD: Record<string, string> = {
  tahsilat: 'Tahsilat', tediye: 'Tediye (ödeme)', virman: 'Virman (kendi hesap)', pos: 'POS\'tan bankaya aktarım',
  masraf: 'Masraf', yoksay: 'Yoksay',
};

export function BankaHareketYanPanel({ satir, yenile, onIslendi }: { satir: ListeSatiri | null; yenile: number; onIslendi(): void }) {
  const id = Number(satir?.id ?? 0);
  const [d, setD] = useState<BankaHareketDetayi | null>(null);
  const [karar, setKarar] = useState<BankaKarar & { cariAd?: string }>({});
  const [secim, setSecim] = useState<'oneri' | 'cari' | 'hesap' | 'masraf' | 'yoksay'>('oneri');
  const [cariAra, setCariAra] = useState(false);
  const [ibanEkle, setIbanEkle] = useState(false);
  const [kural, setKural] = useState(false);
  const [calisiyor, setCalisiyor] = useState(false);

  useEffect(() => {
    setD(null); setKarar({}); setSecim('oneri'); setIbanEkle(false); setKural(false);
    if (id > 0) api.bankaHareket(id).then(v => { setD(v); if (!v.hareket.oneri.tur) setSecim('cari') }, h => mesaj(hataMetni(h)));
  }, [id, yenile]);

  if (!satir || id <= 0) return <div className="bh-yan bh-soluk"><style>{BH_STILI}</style>{c('Bir hareket seçin.')}</div>;
  if (!d) return <div className="bh-yan bh-soluk"><style>{BH_STILI}</style>{c('Yükleniyor…')}</div>;
  const h = d.hareket, o = h.oneri;
  const gelen = h.tutar > 0;
  const islenmis = h.durum === 2, yoksayilmis = h.durum === 3;

  const isle = async () => {
    let k: BankaKarar = {};
    if (secim === 'cari') {
      if (!karar.tarafId) { mesaj(c('Cari seçin.')); return }
      k = { tur: gelen ? 'tahsilat' : 'tediye', tarafId: karar.tarafId };
    } else if (secim === 'hesap') {
      if (!karar.hedefHesapId) { mesaj(c('Karşı hesap seçin.')); return }
      const pos = d.hesaplar.find(x => x.id === karar.hedefHesapId)?.tur === 'P';
      k = { tur: pos ? 'pos' : 'virman', hedefHesapId: karar.hedefHesapId };
    } else if (secim === 'masraf') {
      if (!karar.masrafId) { mesaj(c('Masraf kalemi seçin.')); return }
      k = { tur: 'masraf', masrafId: karar.masrafId };
    } else if (secim === 'yoksay') {
      k = { tur: 'yoksay' };
    } else if (o.tur) {
      if (o.secim || ((o.tur === 'tahsilat' || o.tur === 'tediye') && !o.tarafId)) { mesaj(c('Öneri eksik - cari / hesap seçin.')); return }
      k = { tur: o.tur, tarafId: o.tarafId, belgeId: o.belgeId, hedefHesapId: o.hedefHesapId, masrafId: o.masrafId };
    }
    const tarafId = k.tarafId ?? null;
    k.ibanEkle = ibanEkle && !!tarafId;
    if (kural) k.kural = (h.karsiAd || h.aciklama).split(/\s+/).slice(0, 3).join(' ');
    setCalisiyor(true);
    try {
      const y = await api.bankaIsle(h.id, k);
      mesaj(y.kasaIslemId ? `${c('İşlendi - kasa işlemi')} #${y.kasaIslemId}` : c('Yoksayıldı.'));
      onIslendi();
    } catch (e) { mesaj(hataMetni(e)) } finally { setCalisiyor(false) }
  };

  return (
    <div className="bh-yan">
      <style>{BH_STILI}</style>
      <h5>{c('Seçili hareket')}</h5>
      <div className="bh-kutu">
        <div className="bh-sat"><span>{c('Tutar')}</span><b className={gelen ? 'bh-alacak' : 'bh-borc'}>{gelen ? '+' : ''}{tl(h.tutar)} {h.dovizCinsi}</b></div>
        <div className="bh-sat"><span>{c('İşlem / valör')}</span><b>{tarihSaat(h.islemTarihi)}{h.valorTarihi ? ` · ${tarihSaat(h.valorTarihi).slice(0, 10)}` : ''}</b></div>
        <div className="bh-sat"><span>{c('Banka ref')}</span><b>{h.bankaIslemNo}</b></div>
        {h.sinif && <div className="bh-sat"><span>{c('Sınıf (banka)')}</span><b>{h.sinif}</b></div>}
        {h.kaynak === 3 && <div className="bh-sat"><span /><b className="bh-borc">{c('BENZETİM - gerçek banka verisi değil')}</b></div>}
      </div>
      <h5>{c('Bankanın verdiği bilgi')}</h5>
      <div className="bh-kutu">
        <div>{h.aciklama}</div>
        {h.karsiAd && <div className="bh-sat"><span>{gelen ? c('Gönderen') : c('Alıcı')}</span><b>{h.karsiAd}</b></div>}
        {h.karsiIban && <div className="bh-sat"><span>IBAN</span><b>{h.karsiIban}</b></div>}
        {h.karsiVkn && <div className="bh-sat"><span>VKN / TCKN</span><b>{h.karsiVkn}</b></div>}
        {h.faturaMetni && <div className="bh-sat"><span>{c('Fatura metni')}</span><b>{h.faturaMetni}</b></div>}
      </div>

      {islenmis ? (
        <>
          <h5>{c('İşlendi')}</h5>
          <div className="bh-kutu">{TUR_AD[o.islenen ?? o.tur ?? ''] ?? ''} · {c('kasa işlemi')} {h.kasaIslemNo ?? `#${h.kasaIslemId}`}
            <div className="bh-soluk">{c('Geri almak için kasa işlemini iptal edin - hareket yeniden "Bekliyor"a döner.')}</div></div>
        </>
      ) : yoksayilmis ? (
        <><h5>{c('Yoksayıldı')}</h5><div className="bh-kutu bh-soluk">{c('Sağ tık > "Yoksaymayı geri al" ile bekleyene döner.')}</div></>
      ) : (
        <>
          <h5>{c('Ne yapılsın?')}</h5>
          {o.tur && (
            <label className={`bh-secenek ${secim === 'oneri' ? 'on' : ''}`}>
              <input type="radio" checked={secim === 'oneri'} onChange={() => setSecim('oneri')} />
              <div><b>{TUR_AD[o.tur]}{o.tarafAd ? ` · ${o.tarafAd}` : o.hedefHesapAd ? ` · ${o.hedefHesapAd}` : ''}</b>
                {o.guven ? <span className="bh-soluk"> · %{o.guven}</span> : null}
                <br /><small className="bh-soluk">{o.neden}{o.belgeNo ? ` · ${c('fatura')} ${o.belgeNo} ${c('kapanır')}` : ''}</small></div>
            </label>
          )}
          <label className={`bh-secenek ${secim === 'cari' ? 'on' : ''}`}>
            <input type="radio" checked={secim === 'cari'} onChange={() => setSecim('cari')} />
            <div style={{ flex: 1 }}><b>{gelen ? c('Tahsilat') : c('Tediye')} · {karar.cariAd ?? c('cari seç')}</b>
              <br /><button className="d mini" type="button" onClick={() => { setSecim('cari'); setCariAra(true) }}>🔎 {c('Cari ara…')}</button></div>
          </label>
          <label className={`bh-secenek ${secim === 'hesap' ? 'on' : ''}`}>
            <input type="radio" checked={secim === 'hesap'} onChange={() => setSecim('hesap')} />
            <div style={{ flex: 1 }}><b>{c('Virman / POS aktarımı')}</b>
              <select value={karar.hedefHesapId ?? ''} onChange={e => { setSecim('hesap'); setKarar(k => ({ ...k, hedefHesapId: Number(e.target.value) || null })) }}>
                <option value="">{c('karşı hesap…')}</option>
                {d.hesaplar.filter(x => x.id !== h.hesapId).map(x => <option key={x.id} value={x.id}>{x.tur === 'P' ? 'POS · ' : x.tur === 'K' ? 'Kasa · ' : ''}{x.ad}</option>)}
              </select></div>
          </label>
          {!gelen && (
            <label className={`bh-secenek ${secim === 'masraf' ? 'on' : ''}`}>
              <input type="radio" checked={secim === 'masraf'} onChange={() => setSecim('masraf')} />
              <div style={{ flex: 1 }}><b>{c('Masraf')}</b>
                <select value={karar.masrafId ?? ''} onChange={e => { setSecim('masraf'); setKarar(k => ({ ...k, masrafId: Number(e.target.value) || null })) }}>
                  <option value="">{c('masraf kalemi…')}</option>
                  {d.masraflar.map(x => <option key={x.id} value={x.id}>{x.ad}</option>)}
                </select></div>
            </label>
          )}
          <label className={`bh-secenek ${secim === 'yoksay' ? 'on' : ''}`}>
            <input type="radio" checked={secim === 'yoksay'} onChange={() => setSecim('yoksay')} />
            <div><b>{c('Yoksay')}</b><br /><small className="bh-soluk">{c('bloke, bilgi satırı, iç transferin karşı bacağı')}</small></div>
          </label>
          {h.karsiIban && (secim === 'cari' || (secim === 'oneri' && o.tarafId)) && (
            <label style={{ display: 'flex', gap: 6, alignItems: 'center', margin: '6px 0' }}>
              <input type="checkbox" checked={ibanEkle} onChange={e => setIbanEkle(e.target.checked)} />{c('Bu IBAN\'ı carinin Banka / IBAN listesine ekle')}</label>
          )}
          {secim !== 'yoksay' && secim !== 'oneri' && (
            <label style={{ display: 'flex', gap: 6, alignItems: 'center', margin: '0 0 6px' }}>
              <input type="checkbox" checked={kural} onChange={e => setKural(e.target.checked)} />
              {c('Açıklamadan kural oluştur')} ("{(h.karsiAd || h.aciklama).split(/\s+/).slice(0, 3).join(' ')}")</label>
          )}
          <button className="d bir tam" disabled={calisiyor} onClick={() => void isle()}>
            ✔ {calisiyor ? c('İşleniyor…') : secim === 'yoksay' ? c('Yoksay') : c('İşle')}</button>
          <div className="bh-soluk" style={{ marginTop: 6, fontSize: 11 }}>
            {c('İşlenen hareket kasa işlemine bağlanır; aynı banka ref ikinci kez işlenemez.')}</div>
        </>
      )}
      <TarafArama acik={cariAra} kaynaklar={['cari']} yerTutucu={c('Cari ara…')} onKapat={() => setCariAra(false)}
                  onSec={t => { setKarar(k => ({ ...k, tarafId: Number(t.id), cariAd: t.unvan })); setCariAra(false) }} />
    </div>
  );
}

// ---------------------------------------------------------------- aksiyonlar --
/** Banka Hareketleri araç çubuğu. true: kod bu ekranındı. */
export async function bankaAksiyonu(kod: string, satir: ListeSatiri | null | undefined, secililer: ListeSatiri[] | undefined,
                                    ctx: { tazele(): void; hesapId: number | null; git(yol: string): void }): Promise<boolean> {
  if (!kod.startsWith('banka.')) return false;
  const id = Number(satir?.id ?? 0);
  try {
    if (kod === 'banka.hesap-hareket') {
      // Banka Hesabı Listesi: seçili hesabın hareketleri (satır = hesap).
      if (id) ctx.git(`/banka-hareket?hesapId=${id}`);
      return true;
    }
    if (kod === 'banka.cek' || kod === 'banka.cek-tumu') {
      const y = await api.bankaCek(kod === 'banka.cek-tumu' ? null : ctx.hesapId);
      mesaj(y.sonuclar.map(s => s.mesaj ?? s.hata ?? '').filter(Boolean).join('\n') || c('Bağlı hesap yok.'));
    } else if (kod === 'banka.isle') {
      const idler = (secililer?.length ? secililer : satir ? [satir] : []).map(s => Number(s.id)).filter(x => x > 0);
      if (idler.length === 1) { await api.bankaIsle(idler[0], {}); mesaj(c('Öneriyle işlendi.')) }
      else { const y = await api.bankaTopluIsle(idler); mesaj(`${y.islenen} ${c('hareket işlendi.')}${y.hatalar.length ? '\n' + y.hatalar.join('\n') : ''}`) }
    } else if (kod === 'banka.toplu-isle') {
      if (!(await onay(c('Öneri hazır olan bütün hareketler önerileriyle işlensin mi? Her biri için kasa işlemi yazılır.')))) return true;
      const liste = await listeUclari.liste('banka-hareket', {
        sayfa: 1, boyut: 500,
        filtre: { op: 'and', kosullar: [{ alan: 'durum', op: 'esit', deger: 1 },
                                        ...(ctx.hesapId ? [{ alan: 'hesapId', op: 'esit' as const, deger: ctx.hesapId }] : [])] },
      });
      const y = await api.bankaTopluIsle(liste.satirlar.map(s => Number(s.id)));
      mesaj(`${y.islenen} ${c('hareket işlendi.')}${y.hatalar.length ? '\n' + y.hatalar.slice(0, 10).join('\n') : ''}`);
    } else if (kod === 'banka.yoksay' && id) { await api.bankaYoksay(id) }
    else if (kod === 'banka.geri-al' && id) { await api.bankaGeriAl(id) }
    else if (kod === 'banka.oneri-yenile') {
      const y = await api.bankaOneriYenile(ctx.hesapId); mesaj(`${y.yenilenen} ${c('hareketin önerisi yenilendi.')}`);
    } else return false;
    ctx.tazele();
  } catch (h) { mesaj(hataMetni(h)) }
  return true;
}
