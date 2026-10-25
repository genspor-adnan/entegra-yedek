import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import { finansIcmalUclari, type NakitAkisIcmali as Veri, type NakitKalemi } from '../../api/uclar/finansIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { FINANS_ICMAL_STILI, HESAP_IKON, isaretli, useCariKarti, useKartAc } from './finansIcmalOrtak';

/**
 * NAKİT AKIŞ (VADE) İCMALİ `/nakit-akis-icmali` - mockup Ekranlar/İcmal/nakit_akis_icmali.html.
 * "Önümüzdeki haftalarda kasada / bankada ne kadar param olacak, hangi hafta eksiye düşüyorum,
 * ne yaparsam düzelir?" Rakamlar sunucuda (FinansIcmalUclari); ekran toplamaz.
 * SENARYO yalnız görünümdür: ayarlar adres çubuğunda durur, hiçbir belgeye yazılmaz.
 */
type Sekme = 'akis' | 'giris' | 'cikis' | 'senaryo';
const UFUKLAR: [number, string][] = [[30, '30 gün'], [90, '90 gün'], [180, '180 gün'], [365, '12 ay']];
const GUVEN_RENK: Record<string, string> = { 'yüksek': 'ok', orta: 'sari', 'düşük': 'kir', '3. kişi çek': 'sari', bilinmiyor: 'pas' };
const kisaTarih = (t: string) => new Date(t).toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit' });

export function NakitAkisIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici, yetki } = useOturum();
  const antet = useAntet();
  const cariKarti = useCariKarti();
  const kartAc = useKartAc();
  // SÜZGEÇ ve SENARYO adres çubuğunda. Varsayılanı açık olan kutular kapatılınca 'yok' yazılır
  //   (useSuzgec boş / '0' değeri siler).
  const ufuk = Number(arama.get('ufuk') ?? 90);
  const periyot = arama.get('periyot') === 'ay' ? 'ay' : 'hafta';
  const hesaplar = arama.get('hesaplar') ?? '';
  const sube = Number(arama.get('sube') ?? 0);
  const ilkHafta = arama.get('ilk') !== 'yok';
  const planli = arama.get('planli') !== 'yok';
  const gecikme = arama.get('gecikme') !== 'yok';
  const oran = arama.get('oran') ?? '';
  const kars = arama.get('kars') ?? '';
  const ertele = Number(arama.get('ertele') ?? 0);
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('akis');
  const [ara, setAra] = useState('');

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ ufuk: String(ufuk), periyot });
    if (hesaplar) q.set('hesaplar', hesaplar);
    if (sube) q.set('sube', String(sube));
    if (!ilkHafta) q.set('ilkHafta', '0');
    if (!planli) q.set('planli', '0');
    if (!gecikme) q.set('gecikme', '0');
    if (oran) q.set('oran', oran);
    if (kars) q.set('karsiliksiz', kars === 'yok' ? '0' : kars);
    if (ertele) q.set('ertele', String(ertele));
    finansIcmalUclari.nakitAkisIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [ufuk, periyot, hesaplar, sube, ilkHafta, planli, gecikme, oran, kars, ertele]);

  const o = veri?.ozet;
  const suz = (l: NakitKalemi[]) => {
    const q = ara.trim().toLocaleLowerCase('tr');
    return l.filter(k => !q || k.taraf.toLocaleLowerCase('tr').includes(q) || k.belge.toLocaleLowerCase('tr').includes(q)
      || k.kaynak.toLocaleLowerCase('tr').includes(q));
  };
  const girisler = veri ? suz(veri.girisler) : [];
  const cikislar = veri ? suz(veri.cikislar) : [];
  const donemAdi = (b: string, s: string) => veri?.periyot === 'ay'
    ? new Date(b).toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' })
    : `${kisaTarih(b)} – ${kisaTarih(s)}`;
  const enBuyuk = Math.max(1, ...(veri?.haftalar ?? []).map(h => h.kapanis));
  const kalemAc = (k: NakitKalemi) => {
    if (k.belgeId) kartAc(`/belge/${k.belgeId}`);
    else if (k.cekId) kartAc(`/cek/${k.cekId}`);
    else if (k.tarafId) cariKarti(k.tarafId, k.kolon === 'tedarikci');
  };
  const birim = periyot === 'ay' ? 'ay' : 'hafta';

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + FINANS_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Nakit Akış (Vade) İcmali</h1><span className="yol">Finans › İcmaller › Nakit Akış (Vade) İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Nakit Akış İcmali" dosyaAdi={`Nakit Akış İcmali ${veri?.bugun.slice(0, 10) ?? ''} ${ufuk} gün`} devre={!veri}>
          {veri && <NakitA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} donemAdi={donemAdi} />}
        </CiktiMenusu>
        <button onClick={() => setSekme('senaryo')}>✏️ Senaryo: {veri ? (veri.senaryo.gecikme ? 'tahsilat gecikmesi…' : 'vadeye göre…') : '…'}</button>
        <span className="sp" />
        {yetki('finans.tahsilat_odeme_icmali') && <button onClick={() => git('/tahsilat-odeme-icmali')}>💳 Tahsilat / Ödeme</button>}
        <button onClick={() => git('/cek-senet-icmali')}>🧾 Çek / Senet</button>
        {kullanici?.urunModu === 2 && yetki('finans.alacak_yaslandirma')
          ? <button onClick={() => git('/alacak-yaslandirma')}>⏳ Alacak Yaşlandırma</button>
          : yetki('finans.cari_icmali') && <button onClick={() => git('/cari-icmali')}>⏳ Cari İcmali (yaşlandırma)</button>}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Başlangıç: <b>{veri ? tarihT(veri.bugun) : '…'}</b> (bugün)</div>
        <div className="si-seg">
          {UFUKLAR.map(([g, ad]) => <button key={g} type="button" className={ufuk === g ? 'on' : ''} onClick={() => degistir({ ufuk: g === 90 ? '' : String(g) })}>{ad}</button>)}
        </div>
        <div className="si-seg">
          <button type="button" className={periyot === 'hafta' ? 'on' : ''} onClick={() => degistir({ periyot: '' })}>Haftalık</button>
          <button type="button" className={periyot === 'ay' ? 'on' : ''} onClick={() => degistir({ periyot: 'ay' })}>Aylık</button>
        </div>
        <HesapSecici v={veri} secili={hesaplar} sec={h => degistir({ hesaplar: h })} />
        {(veri?.secim.subeler.length ?? 0) > 1 && (
          <div className="sel">🏢 Şube:
            <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
              <option value={0}>Tümü</option>
              {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
            </select></div>)}
        <label className="fi-chk"><input type="checkbox" checked={ilkHafta} onChange={e => degistir({ ilk: e.target.checked ? '' : 'yok' })} /> Vadesi geçmiş alacakları ilk {birim === 'ay' ? 'aya' : 'haftaya'} koy</label>
        <label className="fi-chk"><input type="checkbox" checked={planli} onChange={e => degistir({ planli: e.target.checked ? '' : 'yok' })} /> Planlı ödemeler (maaş, kredi, kart, ödeme planı) dahil</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && <span className={'bo-rz ' + (o.enDusuk < 0 ? 'kir' : 'ok')}>En düşük bakiye: {tl(o.enDusuk)} ₺ · {o.enDusukSira}. {birim}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Bugünkü Nakit" deg={`${tl(o.acilis)} ₺`} alt={`kasa ${tl(o.kasa)} · banka ${tl(o.banka)}${o.pos ? ` · POS ${tl(o.pos)}` : ''}`} sinif="mor" />
          <Kutu bas={`Beklenen Giriş (${ufuk} g)`} deg={`${tl(o.giris)} ₺`} alt={`fatura ${tl(o.girisFatura)} · çek/senet ${tl(o.girisCek)} · plan ${tl(o.girisPlan)}`} sinif="iyi" />
          <Kutu bas={`Beklenen Çıkış (${ufuk} g)`} deg={`${tl(o.cikis)} ₺`} alt={`tedarikçi ${tl(o.cikisTedarikci)} · verilen çek ${tl(o.cikisCek)} · planlı ${tl(o.cikisPlanli)}`} sinif="teh" />
          <Kutu bas={`${ufuk}. Gün Bakiyesi`} deg={`${tl(o.sonBakiye)} ₺`} alt={`bugünden ${isaretli(o.fark)}`} sinif={o.sonBakiye < 0 ? 'teh' : o.fark < 0 ? 'uy' : 'iyi'} />
          <Kutu bas="En Düşük Nokta" deg={`${tl(o.enDusuk)} ₺`} alt={`${tarihT(o.enDusukBas)} ${birim}${birim === 'ay' ? 'ı' : 'sı'}`} sinif={o.enDusuk < 0 ? 'teh' : ''} />
          <Kutu bas="Vadesi Geçmiş Alacak" deg={`${tl(o.vadesiGecmisAlacak)} ₺`}
            alt={o.gecmisOran != null ? `gerçekleşme oranı geçmişte %${o.gecmisOran}` : 'geçmiş gerçekleşme verisi yok'} sinif={o.vadesiGecmisAlacak ? 'uy' : ''} />
          <Kutu bas="Ort. Tahsilat Gecikmesi" deg={o.ortGecikme != null ? `${o.ortGecikme} gün` : '—'} alt="vadeden sonra · son 6 ay" />
          <Kutu bas="Kredi Limiti Boşta" deg={o.kmh ? `${tl(o.kmh)} ₺` : '—'}
            alt={o.kmhHesaplar.length ? o.kmhHesaplar.map(k => k.ad).join(' · ') : 'tanımlı KMH limiti yok'} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['akis', periyot === 'ay' ? 'Aylık Akış' : 'Haftalık Akış', null], ['giris', 'Girişler', veri.girisler.length],
              ['cikis', 'Çıkışlar', veri.cikislar.length], ['senaryo', 'Senaryo', null]]} />

            {sekme === 'akis' && <>
              <Kutucuk baslik={`${periyot === 'ay' ? 'Aylık' : 'Haftalık'} nakit akışı`} not="kırmızı satır = eksi bakiye · seçili senaryoyla">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>{periyot === 'ay' ? 'Ay' : 'Hafta'}</th><th className="sag">Açılış</th><th className="sag">Fatura tahsilatı</th>
                      <th className="sag">Çek / senet</th><th className="sag">Plan</th><th className="sag">Toplam giriş</th>
                      <th className="sag">Tedarikçi ödemesi</th><th className="sag">Verilen çek</th><th className="sag">Planlı (maaş, kredi, kart, plan)</th>
                      <th className="sag">Toplam çıkış</th><th className="sag">Kapanış</th><th style={{ width: 120 }} /></tr></thead>
                    <tbody>
                      {veri.haftalar.map(h => {
                        const p = (n: number, sinif: string) => <td className={'sag ' + (n ? sinif : 'ki-soluk')}>{n ? tl(n) : '—'}</td>;
                        return (
                          <tr key={h.bas} className={h.kapanis < 0 ? 'fi-eksi' : ''}>
                            <td>{h.kapanis < 0 ? <b>{donemAdi(h.bas, h.bit)}</b> : donemAdi(h.bas, h.bit)}
                              {h.gecmisDahil && <span className="bo-rz sari" style={{ marginLeft: 4 }}>vadesi geçmiş dahil</span>}</td>
                            <td className="sag">{tl(h.acilis)}</td>
                            {p(h.fatura, 'si-yesil')}{p(h.cek, 'si-yesil')}{p(h.plan, 'si-yesil')}
                            <td className="sag si-yesil"><b>{tl(h.giris)}</b></td>
                            {p(h.tedarikci, 'kir')}{p(h.verilenCek, 'kir')}{p(h.planli, 'kir')}
                            <td className="sag kir"><b>{tl(h.cikis)}</b></td>
                            <td className={'sag' + (h.kapanis < 0 ? ' kir' : '')}><b>{tl(h.kapanis)}{h.kapanis < 0 && ' ⚠'}</b></td>
                            <td><Cubuk yuzde={(100 * Math.max(0, h.kapanis)) / enBuyuk} /></td>
                          </tr>
                        );
                      })}
                      <tr className="top"><td>{ufuk} gün</td><td className="sag">{tl(o.acilis)}</td><td className="sag">{tl(o.girisFatura)}</td>
                        <td className="sag">{tl(o.girisCek)}</td><td className="sag">{tl(o.girisPlan)}</td><td className="sag">{tl(o.giris)}</td>
                        <td className="sag">{tl(o.cikisTedarikci)}</td><td className="sag">{tl(o.cikisCek)}</td><td className="sag">{tl(o.cikisPlanli)}</td>
                        <td className="sag">{tl(o.cikis)}</td><td className="sag">{tl(o.sonBakiye)}</td><td /></tr>
                    </tbody>
                  </table>
                </div>
                <div className="fi-ipucu">Giriş: açık satış alacaklarının vadesi (tahsilat planı varsa plan), portföy + tahsildeki + teminattaki çek / senet vadesi,
                  tahsilat planları. Çıkış: açık borçların vadesi (ödeme planı varsa plan), verilen çek / senet, planlı ödemeler. Açılış = seçili kasa / banka / POS
                  hesaplarının bugünkü bakiyesi. Dövizli kalemler bugünkü kurla TL. Kesin bakiye değil, vadeye dayalı tahmindir.</div>
              </Kutucuk>
              <div className="si-iki">
                <Kutucuk baslik={`Döviz pozisyonu (${ufuk} gün)`} not="döviz cinsinden · TL karşılığı bugünkü kurla">
                  <table className="hi-tablo"><thead><tr><th>Para birimi</th><th className="sag">Girecek</th><th className="sag">Çıkacak</th>
                    <th className="sag">Açık pozisyon</th><th className="sag">Bugünkü kur</th><th className="sag">TL karşılığı</th></tr></thead>
                    <tbody>
                      {veri.doviz.length === 0 && <tr><td colSpan={6} className="bos">Dövizli açık kalem yok.</td></tr>}
                      {veri.doviz.map(d => (
                        <tr key={d.doviz}><td>{d.doviz}</td><td className="sag">{tl(d.girecek)}</td><td className="sag">{tl(d.cikacak)}</td>
                          <td className={'sag' + (d.acik < 0 ? ' kir' : '')}>{isaretli(d.acik)}</td>
                          <td className="sag">{d.kur != null ? d.kur.toLocaleString('tr-TR', { maximumFractionDigits: 4 }) : <span className="bo-rz kir">kur yok</span>}</td>
                          <td className={'sag' + ((d.tl ?? 0) < 0 ? ' kir' : '')}>{d.tl != null ? isaretli(d.tl) : '—'}</td></tr>))}
                    </tbody></table>
                  <div className="fi-ipucu">Açık pozisyon eksiyse kur yükselişi aleyhimizedir: borcun TL karşılığı büyür. Kur yoksa kalem kendi (geçmiş) kuruyla akışa girer.</div>
                </Kutucuk>
                <Kutucuk baslik="⚠ Planlı gider tanımı" not="tekrarlayan gider">
                  <table className="hi-tablo"><thead><tr><th>Gider</th><th>Kaynak</th><th>Durum</th></tr></thead>
                    <tbody>
                      {veri.tanimlar.map(t => (
                        <tr key={t.gider}><td>{t.gider}</td><td style={{ whiteSpace: 'normal' }}>{t.kaynak}</td>
                          <td>{t.durum === 'akista' ? <span className="bo-rz ok">akışta</span>
                            : t.durum === 'kapali' ? <span className="bo-rz pas">planlı ödemeler kapalı</span>
                            : <span className="bo-rz sari">planlı gider tanımı yok · akışta görünmüyor</span>}</td></tr>))}
                    </tbody></table>
                </Kutucuk>
              </div>
            </>}

            {(sekme === 'giris' || sekme === 'cikis') && <>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Cari, belge ya da kaynak…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 260 }} />
                <span className="ki-soluk">vadeye göre · çift tık: belge / evrak kartı</span>
              </div>
              {sekme === 'giris'
                ? <GirisTablosu l={girisler} ac={kalemAc} />
                : <CikisTablosu l={cikislar} ac={kalemAc} />}
              <div className="ki-soluk si-not">
                {sekme === 'giris'
                  ? <>Beklenen tarih = vade + carinin son 6 aydaki ortalama tahsilat gecikmesi (Senaryo'da "gecikmeyi uygula" açıksa akış bu tarihe göre çizilir).
                    Vadesi geçmiş kalem ilk {birim === 'ay' ? 'aya' : 'haftaya'} gerçekleşme oranıyla girer. Güven, carinin geçmiş ödeme düzenine göre (≤ 7 gün yüksek, ≤ 30 gün orta).</>
                  : <>Planlı ödemeler: ödeme planları (71), kredi taksitleri (58), kredi kartı borcu (57, son ödeme gününe) ve maaş (personel kartlarındaki aylık
                    net maaş toplamı, ay sonu) - kira, vergi, abonelik tanımı yoksa bu satırlar boş kalır. "Pazarlık edilebilir" kalemler Senaryo'daki ertelemeye uyar.</>}
              </div>
            </>}

            {sekme === 'senaryo' && (
              <div className="si-iki">
                <Kutucuk baslik="Senaryo ayarları" not="yalnız bu ekranda · kaydedilmez">
                  <table className="hi-tablo fi-senaryo"><tbody>
                    <tr><td>Tahsilatlara carinin ortalama gecikmesini uygula</td>
                      <td><input type="checkbox" checked={gecikme} onChange={e => degistir({ gecikme: e.target.checked ? '' : 'yok' })} /></td></tr>
                    <tr><td>Vadesi geçmiş alacakların gerçekleşme oranı</td>
                      <td><select value={oran} onChange={e => degistir({ oran: e.target.value })}>
                        <option value="">%{veri.senaryo.gecmisOran ?? 100} (geçmiş{veri.senaryo.gecmisOran == null ? ' verisi yok' : ''})</option>
                        {[100, 90, 80, 70, 60, 50, 30].map(x => <option key={x} value={String(x)}>%{x}</option>)}
                      </select></td></tr>
                    <tr><td>3. kişi çeklerinde karşılıksız payı</td>
                      <td><select value={kars} onChange={e => degistir({ kars: e.target.value })}>
                        <option value="">%5</option><option value="yok">%0</option>
                        {[2, 10, 15, 20].map(x => <option key={x} value={String(x)}>%{x}</option>)}
                      </select></td></tr>
                    <tr><td>Tedarikçi ödemelerini ertele</td>
                      <td><select value={ertele} onChange={e => degistir({ ertele: e.target.value })}>
                        {[0, 7, 15, 30, 45].map(x => <option key={x} value={x}>{x} gün</option>)}
                      </select> <span className="ki-soluk">(yalnız "pazarlık edilebilir")</span></td></tr>
                    <tr><td>Yeni satış varsayımı (henüz faturalanmamış)</td><td><b>Yok</b> <span className="ki-soluk">(bu sürümde)</span></td></tr>
                  </tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Senaryo sonucu" not="en düşük bakiye ve tarihi">
                  <table className="hi-tablo"><thead><tr><th>Senaryo</th><th className="sag">En düşük</th><th>{periyot === 'ay' ? 'Ay' : 'Hafta'}</th>
                    <th className="sag">{ufuk}. gün</th></tr></thead>
                    <tbody>
                      {veri.senaryolar.map(s => (
                        <tr key={s.ad}><td>{s.secili ? <b>{s.ad} (seçili)</b> : s.ad}</td>
                          <td className={'sag' + (s.enDusuk < 0 ? ' kir' : ' si-yesil')}>{s.secili ? <b>{tl(s.enDusuk)}</b> : tl(s.enDusuk)}</td>
                          <td>{kisaTarih(s.hafta)}</td><td className={'sag' + (s.sonBakiye < 0 ? ' kir' : '')}>{tl(s.sonBakiye)}</td></tr>))}
                    </tbody></table>
                  <div className="fi-ipucu">Senaryo yalnız görünümdür; hiçbir belgenin vadesi değişmez. A4 çıktısına seçili senaryo yazılır.</div>
                </Kutucuk>
              </div>
            )}
          </div>
        </div>

        <div className="ki-soluk si-not">{o.girisKalem} giriş · {o.cikisKalem} çıkış kalemi · Ufuk: {ufuk} gün · Hesap sunucuda, ekran toplamaz.</div>
      </>)}
    </div>
  );
}

function GirisTablosu({ l, ac }: { l: NakitKalemi[]; ac(k: NakitKalemi): void }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Vade</th><th>Kaynak</th><th>Cari</th><th>Belge / Evrak</th><th className="sag">Tutar</th>
        <th className="sag">Cari ort. gecikme</th><th>Beklenen tarih</th><th>Güven</th></tr></thead>
      <tbody>
        {l.length === 0 && <tr><td colSpan={8} className="bos">Beklenen giriş yok.</td></tr>}
        {l.slice(0, 1500).map((k, i) => (
          <tr key={i} className="ac" onDoubleClick={() => ac(k)}>
            <td className={k.gecmis ? 'kir' : ''}>{tarihT(k.vade)}</td><td>{k.kaynak}</td><td>{k.taraf}</td><td>{k.belge}</td>
            <td className="sag">{tl(k.tl)}{k.doviz !== 'TL' && <span className="ki-soluk"> ({tl(k.tutar)} {k.doviz})</span>}</td>
            <td className={'sag' + ((k.gecikme ?? 0) > 7 ? ' kir' : '')}>{k.gecikme != null ? `+${k.gecikme} gün` : '—'}</td>
            <td>{!k.akista ? <span className="ki-soluk">akış dışı</span> : k.gecmis ? 'ilk dönem' : k.beklenen ? tarihT(k.beklenen) : '—'}</td>
            <td>{k.guven && <span className={'bo-rz ' + (GUVEN_RENK[k.guven] ?? '')}>{k.guven}</span>}</td></tr>))}
        {l.length > 1500 && <tr><td colSpan={8} className="ki-soluk">… {l.length - 1500} kalem daha</td></tr>}
      </tbody>
    </table>
  );
}

function CikisTablosu({ l, ac }: { l: NakitKalemi[]; ac(k: NakitKalemi): void }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Vade</th><th>Kaynak</th><th>Alacaklı</th><th>Belge / Evrak</th><th className="sag">Tutar</th><th>Ödeme hesabı</th><th>Esneklik</th></tr></thead>
      <tbody>
        {l.length === 0 && <tr><td colSpan={7} className="bos">Beklenen çıkış yok.</td></tr>}
        {l.slice(0, 1500).map((k, i) => (
          <tr key={i} className="ac" onDoubleClick={() => ac(k)}>
            <td className={k.gecmis ? 'kir' : ''}>{tarihT(k.vade)}</td><td>{k.kaynak}</td><td>{k.taraf}</td><td>{k.belge}</td>
            <td className="sag">{tl(k.tl)}{k.doviz !== 'TL' && <span className="ki-soluk"> ({tl(k.tutar)} {k.doviz})</span>}</td>
            <td>{k.hesap || <span className="ki-soluk">—</span>}</td>
            <td>{k.esneklik === 'pazarlik' ? <span className="bo-rz ok">pazarlık edilebilir</span>
              : k.esneklik === 'ertelenemez' ? <span className="bo-rz kir">ertelenemez</span> : ''}
              {!k.akista && <span className="ki-soluk"> · akış dışı</span>}</td></tr>))}
        {l.length > 1500 && <tr><td colSpan={7} className="ki-soluk">… {l.length - 1500} kalem daha</td></tr>}
      </tbody>
    </table>
  );
}

/** Hesap seçimi (kasa / banka / POS) - yalnız açılış bakiyesini süzer. */
function HesapSecici({ v, secili, sec }: { v: Veri | null; secili: string; sec(h: string): void }) {
  const [acik, setAcik] = useState(false);
  const kutu = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!acik) return;
    const dis = (e: MouseEvent) => { if (kutu.current && !kutu.current.contains(e.target as Node)) setAcik(false) };
    document.addEventListener('mousedown', dis);
    return () => document.removeEventListener('mousedown', dis);
  }, [acik]);
  const liste = v?.secim.hesaplar ?? [];
  const idler = new Set(secili.split(',').filter(Boolean).map(Number));
  const degis = (id: number) => {
    const n = new Set(idler.size === 0 ? liste.map(h => h.id) : idler);
    if (n.has(id)) n.delete(id); else n.add(id);
    if (n.size === 0) return;
    sec(n.size === 0 || n.size === liste.length ? '' : [...n].join(','));
  };
  const ad = idler.size === 0 ? `Tüm kasa + banka (${liste.length})` : `${idler.size} hesap`;
  return (
    <div className="sel fi-hesaplar" ref={kutu}>🏦 Hesaplar: <b className="lnk" onClick={() => setAcik(!acik)}>{ad}</b> ▾
      {acik && (
        <div className="fi-acilir">
          <label><input type="checkbox" checked={idler.size === 0} onChange={() => sec('')} /> Tümü</label>
          {liste.map(h => (
            <label key={h.id}><input type="checkbox" checked={idler.size === 0 || idler.has(h.id)}
              onChange={() => degis(h.id)} />
              {HESAP_IKON[h.tur] ?? ''} {h.ad} <span className="ki-soluk">{tl(h.bakiye)} {h.doviz}</span></label>))}
        </div>)}
    </div>
  );
}

function NakitA4({ v, antet, duzenleyen, donemAdi }: {
  v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; donemAdi(b: string, s: string): string;
}) {
  const o = v.ozet;
  const sn = v.senaryo;
  const senaryo = [sn.gecikme ? 'gecikme' : 'vadeye göre', `gerçekleşme %${sn.oran}`, sn.karsiliksiz ? `karşılıksız %${sn.karsiliksiz}` : '',
    sn.ertele ? `ertele ${sn.ertele} gün` : ''].filter(Boolean).join(' + ');
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>NAKİT AKIŞ (VADE) İCMALİ</h3>
      <div className="a4-hasta">
        <span>Başlangıç: <b>{tarihT(v.bugun)}</b> · {v.ufuk} gün</span>
        <span>{v.periyot === 'ay' ? 'Aylık' : 'Haftalık'} · {v.hesaplar.length ? `${v.hesaplar.length} hesap` : 'tüm kasa + banka'}</span>
        <span>Senaryo: {senaryo}</span><span>Bugünkü nakit: {tl(o.acilis)} ₺</span>
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>{v.periyot === 'ay' ? 'Ay' : 'Hafta'}</th><th>Açılış</th><th>Giriş</th><th>Çıkış</th><th>Kapanış</th></tr></thead>
        <tbody>{v.haftalar.map(h => <tr key={h.bas}><td>{donemAdi(h.bas, h.bit)}</td><td>{tl(h.acilis)}</td><td>{tl(h.giris)}</td>
          <td>{tl(h.cikis)}</td><td>{tl(h.kapanis)}</td></tr>)}</tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Beklenen giriş</td><td>{tl(o.giris)}</td></tr>
        <tr><td>Beklenen çıkış</td><td>{tl(o.cikis)}</td></tr>
        <tr><td>En düşük bakiye ({tarihT(o.enDusukBas)})</td><td>{tl(o.enDusuk)}</td></tr>
        <tr className="kalan ki-kalan"><td>{v.ufuk}. GÜN BAKİYESİ</td><td>{tl(o.sonBakiye)} ₺</td></tr>
      </tbody></table>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali İşler / Yönetim<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Nakit Akış (Vade) İcmali · vadeye dayalı tahmindir, kesin bakiye değildir · dövizli kalemler bugünkü kurla</p>
    </div>
  );
}

export default NakitAkisIcmali;
