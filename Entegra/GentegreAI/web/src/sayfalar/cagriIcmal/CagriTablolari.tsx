import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { CagriIcmali } from '../../api/uclar/cagriIcmal';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { GUN_ADI, dkMetni, slaRozeti, sureMetni, yuzde } from './cagriIcmalOrtak';

/** Çağrı merkezi icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const s = (n: number) => n.toLocaleString('tr-TR');
function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}

/** KUYRUKLAR - tık tek, Ctrl / Shift çoklu; ▸ sonuç dağılımı; seçilenler A4'ü süzer. */
export function KuyrukTablosu({ v, secili, setSecili }: { v: CagriIcmali; secili: number[]; setSecili(x: number[]): void }) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.kuyruklar.map(k => k.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.kuyruklar.length > 0 && v.kuyruklar.every(k => secili.includes(k.id));
  const o = v.ozet;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.kuyruklar.map(k => k.id))} /></th>
          <th>Kuyruk</th><th className="sag">Gelen</th><th className="sag">Cevaplanan</th><th className="sag">Terk</th><th className="sag">Sesli / Mesai Dışı</th>
          <th className="sag">Cevap %</th><th>SLA</th><th className="sag">Ort. Bekleme</th><th className="sag">En Uzun</th><th className="sag">Ort. Görüşme</th>
          <th className="sag">Randevu</th></tr></thead>
        <tbody>
          {v.kuyruklar.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde gelen çağrı yok.</td></tr>}
          {v.kuyruklar.map(k => {
            const sec = secili.includes(k.id); const sl = slaRozeti(k.ozet.sla, k.hedef);
            return (
              <Fragment key={k.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(k.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(k.id, e)} /></td>
                  <td><a className="ki-lnk" onClick={e => ac(k.id, e)}>{acik.includes(k.id) ? '▾' : '▸'}</a> <b>{k.ad}</b>
                    <div className="ki-soluk">SLA {k.slaSn} sn · hedef %{k.hedef}{k.slaTanimsiz && ' (tanımsız, varsayılan)'}</div></td>
                  <td className="sag">{s(k.ozet.gelen)}</td><td className="sag">{s(k.ozet.cevaplanan)}</td><td className="sag">{k.ozet.terk || '—'}</td>
                  <td className="sag">{k.ozet.sesli || '—'}</td><td className="sag">{yuzde(k.ozet.cevapOrani)}</td>
                  <td><span className={'bo-rz ' + sl.renk}>{sl.ad}</span></td><td className="sag">{sureMetni(k.ozet.ortBekleme)}</td>
                  <td className="sag">{sureMetni(k.ozet.enUzunBekleme)}</td><td className="sag">{sureMetni(k.ozet.ortGorusme)}</td>
                  <td className="sag">{k.ozet.randevu || '—'}</td>
                </tr>
                {acik.includes(k.id) && (
                  <tr className="lb-alt"><td /><td colSpan={11}>Sonuç dağılımı ({k.ozet.cevaplanan} cevaplanan): {k.sonuclar.map(x => `${x.ad} ${x.adet}`).join('  ·  ') || '—'}</td></tr>
                )}
              </Fragment>
            );
          })}
          {v.kuyruklar.length > 0 && (
            <tr className="top"><td /><td>Toplam · {v.kuyruklar.length} kuyruk</td><td className="sag">{s(o.gelen)}</td><td className="sag">{s(o.cevaplanan)}</td>
              <td className="sag">{o.terk}</td><td className="sag">{o.sesli}</td><td className="sag">{yuzde(o.cevapOrani)}</td>
              <td>{yuzde(o.sla)}</td><td className="sag">{sureMetni(o.ortBekleme)}</td><td className="sag">{sureMetni(o.enUzunBekleme)}</td>
              <td className="sag">{sureMetni(o.ortGorusme)}</td><td className="sag">{o.randevu}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Gelen = cevaplanan + terk + sesli mesaj / mesai dışı (+ çalan / beklemede kalanlar). SLA = kuyruğun süresi içinde cevaplanan /
        (cevaplanan + terk); sesli mesaj SLA'ya girmez. Randevuya dönüşme = sonucu "Randevu verildi" olan / cevaplanan.
        {o.asiriSure > 0 && ` ${o.asiriSure} çağrı 4 saatten uzun görünüyor (kapanmamış kayıt) - görüşme süresi ortalamasına girmedi.`}</div>
    </>
  );
}

export function TemsilciTablosu({ v }: { v: CagriIcmali }) {
  const enCok = Math.max(1, ...v.temsilciler.map(t => t.gelen + t.giden));
  const top = v.temsilciler.reduce((a, t) => ({ gelen: a.gelen + t.gelen, giden: a.giden + t.giden, konusma: a.konusma + t.konusmaSn, randevu: a.randevu + t.randevu,
    z: a.z + t.geriZamaninda, g: a.g + t.geriGec, y: a.y + t.geriYok }), { gelen: 0, giden: 0, konusma: 0, randevu: 0, z: 0, g: 0, y: 0 });
  return (
    <table className="hi-tablo">
      <thead><tr><th>Temsilci</th><th>Dahili</th><th className="sag">Gelen</th><th className="sag">Giden</th><th className="sag">Konuşma</th>
        <th className="sag">Ort. Görüşme</th><th className="sag">Ort. İşlem Sonrası</th><th className="sag">Randevu</th><th className="sag">Dönüşüm</th>
        <th className="sag">Geri Arama (zamanında / geç / yok)</th><th className="sag">Kalite</th><th>İş Yükü</th></tr></thead>
      <tbody>
        {v.temsilciler.length === 0 && <tr><td colSpan={12} className="bos">Temsilci kaydı yok.</td></tr>}
        {v.temsilciler.map(t => (
          <tr key={t.id}><td><b>{t.ad}</b></td><td>{t.dahili || '—'}</td><td className="sag">{s(t.gelen)}</td><td className="sag">{s(t.giden)}</td>
            <td className="sag">{sureMetni(t.konusmaSn)}</td><td className="sag">{sureMetni(t.ortGorusme)}</td><td className="sag">{sureMetni(t.ortIslemSonrasi)}</td>
            <td className="sag">{t.randevu || '—'}</td><td className="sag">{yuzde(t.donusum)}</td>
            <td className="sag">{t.geriZamaninda} / {t.geriGec} / <span className={t.geriYok ? 'kir' : ''}>{t.geriYok}</span></td>
            <td className="sag">{t.kalite != null ? t.kalite.toLocaleString('tr-TR') : '—'}</td><td><Cubuk oran={100 * (t.gelen + t.giden) / enCok} /></td></tr>
        ))}
        {v.temsilciler.length > 0 && (
          <tr className="top"><td colSpan={2}>Toplam · {v.temsilciler.length} temsilci</td><td className="sag">{s(top.gelen)}</td><td className="sag">{s(top.giden)}</td>
            <td className="sag">{sureMetni(top.konusma)}</td><td className="sag">{sureMetni(v.ozet.ortGorusme)}</td><td className="sag">{sureMetni(v.ozet.ortIslemSonrasi)}</td>
            <td className="sag">{top.randevu}</td><td className="sag">{yuzde(v.ozet.donusum)}</td><td className="sag">{top.z} / {top.g} / {top.y}</td><td /><td /></tr>
        )}
      </tbody>
    </table>
  );
}

export function YogunlukTablosu({ v }: { v: CagriIcmali }) {
  const enCok = Math.max(1, ...v.saatler.map(x => x.gelen));
  const enCokGun = Math.max(1, ...v.gunler.map(x => x.gunBasina));
  return (
    <div className="lb-kalite">
      <div>
        <div className="lb-bas">Saat Bazında Yoğunluk <span className="ki-soluk">dönem toplamı · SLA düşüşü personel planına yön verir</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Saat</th><th className="sag">Gelen</th><th className="sag">Cevaplanan</th><th className="sag">Terk</th><th className="sag">Sesli</th>
            <th>SLA</th><th className="sag">Ort. Bekleme</th><th>Yoğunluk</th></tr></thead>
          <tbody>
            {v.saatler.map(x => {
              const sl = slaRozeti(x.sla, v.ozet.slaHedef);
              return (
                <tr key={x.saat}><td>{x.saat < 0 ? 'Mesai dışı / sesli' : `${String(x.saat).padStart(2, '0')}:00 – ${String(x.saat + 1).padStart(2, '0')}:00`}</td>
                  <td className="sag">{x.gelen}</td><td className="sag">{x.cevaplanan}</td><td className="sag">{x.terk || '—'}</td><td className="sag">{x.sesli || '—'}</td>
                  <td><span className={'bo-rz ' + sl.renk}>{sl.ad}</span></td><td className="sag">{sureMetni(x.ortBekleme)}</td><td><Cubuk oran={100 * x.gelen / enCok} /></td></tr>
              );
            })}
            <tr className="top"><td>Toplam</td><td className="sag">{v.ozet.gelen}</td><td className="sag">{v.ozet.cevaplanan}</td><td className="sag">{v.ozet.terk}</td>
              <td className="sag">{v.ozet.sesli}</td><td>{yuzde(v.ozet.sla)}</td><td className="sag">{sureMetni(v.ozet.ortBekleme)}</td><td /></tr>
          </tbody>
        </table>
      </div>
      <div>
        <div className="lb-bas">Haftanın Günü <span className="ki-soluk">gün başına = toplam / dönemdeki o gün sayısı</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Gün</th><th className="sag">Gün Sayısı</th><th className="sag">Gelen</th><th className="sag">Gün Başına</th><th className="sag">Cevap %</th><th>Yoğunluk</th></tr></thead>
          <tbody>
            {v.gunler.map(g => (
              <tr key={g.gun}><td>{GUN_ADI[g.gun]}</td><td className="sag">{g.gunSayisi}</td><td className="sag">{g.gelen}</td><td className="sag">{g.gunBasina}</td>
                <td className="sag">{yuzde(g.cevapOrani)}</td><td><Cubuk oran={100 * g.gunBasina / enCokGun} /></td></tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export function GeriAramaTablosu({ v }: { v: CagriIcmali }) {
  const o = v.ozet;
  return (
    <>
      <div className="ki-not">Hedef: {dkMetni(o.hedefDk)} (ayar cagri.geri_arama_hedef_dk). İstek = "geri aranacak" notu, terk ve sesli mesaj. Tamamlanma
        = istekten sonra aynı numaraya / kişiye yapılan ilk giden arama; bulunamayan ama elle tamam işaretlenen istek "süresiz" sayılır.</div>
      <table className="hi-tablo">
        <thead><tr><th>Kaynak</th><th className="sag">İstek</th><th className="sag">Zamanında</th><th className="sag">Geç</th><th className="sag">Yapılmadı</th>
          <th className="sag">Süresiz Tamam</th><th className="sag">Ulaşıldı</th><th className="sag">Ort. Süre</th><th className="sag">Zamanında %</th></tr></thead>
        <tbody>
          {v.geriAramaOzet.length === 0 && <tr><td colSpan={9} className="bos">Geri arama isteği yok.</td></tr>}
          {v.geriAramaOzet.map(g => (
            <tr key={g.kaynak}><td>{g.kaynak}</td><td className="sag">{g.istek}</td><td className="sag">{g.zamaninda}</td><td className="sag">{g.gec || '—'}</td>
              <td className={'sag' + (g.yapilmadi ? ' kir' : '')}>{g.yapilmadi || '—'}</td><td className="sag">{g.tamam || '—'}</td><td className="sag">{g.ulasildi}</td>
              <td className="sag">{dkMetni(g.ortSure)}</td><td className="sag">{yuzde(g.oran)}</td></tr>
          ))}
          {v.geriAramaOzet.length > 0 && (
            <tr className="top"><td>Toplam</td><td className="sag">{o.geriIstek}</td><td className="sag">{o.geriZamaninda}</td><td className="sag">{o.geriGec}</td>
              <td className="sag">{o.geriYok}</td><td colSpan={3} /><td className="sag">{yuzde(o.geriOran)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="lb-bas">Geciken ve Yapılmayan Geri Aramalar <span className="ki-soluk">numaralar maskeli · en fazla 50</span></div>
      <table className="hi-tablo">
        <thead><tr><th>İstek</th><th>Arayan</th><th>Telefon</th><th>Kuyruk</th><th>Kaynak</th><th>Temsilci</th><th className="sag">Süre</th><th>Durum</th></tr></thead>
        <tbody>
          {v.gecikenler.length === 0 && <tr><td colSpan={8} className="bos">Geciken geri arama yok.</td></tr>}
          {v.gecikenler.map(g => (
            <tr key={g.id}><td>{new Date(g.istek).toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })}</td>
              <td>{g.arayan}</td><td>{g.telefon}</td><td>{g.kuyruk}</td><td>{g.kaynak}</td><td>{g.temsilci}</td><td className="sag">{dkMetni(g.sure)}</td>
              <td><span className={'bo-rz ' + (g.durum === 'gec' ? 'sari' : 'kir')}>{g.durum === 'gec' ? 'geç' : 'yapılmadı'}</span></td></tr>
          ))}
        </tbody>
      </table>
    </>
  );
}

export function KampanyaTablosu({ v }: { v: CagriIcmali }) {
  const t = v.kampanyalar.reduce((a, k) => ({ kisi: a.kisi + k.kisi, arama: a.arama + k.arama, ulasilan: a.ulasilan + k.ulasilan, onay: a.onay + k.onay,
    iptal: a.iptal + k.iptal, ulasilamadi: a.ulasilamadi + k.ulasilamadi, bekliyor: a.bekliyor + k.bekliyor }),
    { kisi: 0, arama: 0, ulasilan: 0, onay: 0, iptal: 0, ulasilamadi: 0, bekliyor: 0 });
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Kampanya</th><th>Tür</th><th>Kanal</th><th className="sag">Kişi</th><th className="sag">Arama</th><th className="sag">Ulaşılan</th>
          <th className="sag">Onayladı / Randevu</th><th className="sag">İptal Etti</th><th className="sag">Ulaşılamadı</th><th className="sag">Bekliyor</th><th className="sag">Başarı</th></tr></thead>
        <tbody>
          {v.kampanyalar.length === 0 && <tr><td colSpan={11} className="bos">Bu dönemde kampanya yok.</td></tr>}
          {v.kampanyalar.map(k => (
            <tr key={k.id}><td><b>{k.ad}</b></td><td>{k.tur}</td><td>{k.kanal}</td><td className="sag">{k.kisi}</td><td className="sag">{k.arama}</td>
              <td className="sag">{k.ulasilan}</td><td className="sag">{k.onay}</td><td className="sag">{k.iptal || '—'}</td><td className="sag">{k.ulasilamadi || '—'}</td>
              <td className="sag">{k.bekliyor || '—'}</td><td className="sag">{yuzde(k.basari)}</td></tr>
          ))}
          {v.kampanyalar.length > 0 && (
            <tr className="top"><td colSpan={3}>Toplam · {v.kampanyalar.length} kampanya</td><td className="sag">{t.kisi}</td><td className="sag">{t.arama}</td>
              <td className="sag">{t.ulasilan}</td><td className="sag">{t.onay}</td><td className="sag">{t.iptal}</td><td className="sag">{t.ulasilamadi}</td>
              <td className="sag">{t.bekliyor}</td><td className="sag">{yuzde(t.ulasilan ? 100 * t.onay / t.ulasilan : null)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Başarı = onaylayan / ulaşılan · arama = kişi başına deneme toplamı · dönemle kesişen kampanyalar.</div>
    </>
  );
}
