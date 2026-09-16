import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { tarihYaz, tutarOku } from '../../bilesenler/bicim';
import type { DozAdimi, HazirlamaAdimi, IsEmriAdimi } from '../../api/uclar/akisTedarik';

/**
 * ECZANE · BİYOMEDİKAL · SATINALMA LİSTE AKSİYONLARI (722-724 uçları).
 *
 * KURAL İSTEMCİDE TEKRAR EDİLMEZ. Sıra, çift kontrol, iade ölçütleri, onay
 * basamağı, ağırlık kilidi ve teknik eleme SUNUCUDA. Buradaki kod yalnız
 * düğmeyi uca bağlar ve sunucunun reddini kullanıcıya SORUYA çevirir.
 *
 * ZORLAMA ÖNCE REDDİ GÖRÜR. `zorla` bayrağını baştan göndermiyoruz: önce
 * normal istek gider, sunucu "geçilemez / eksik / erken" derse kullanıcıya
 * gerekçe sorulur ve ancak o zaman ikinci istek `zorla` ile gönderilir.
 * Baştan göndermek kuralı süse çevirirdi; hiç sormamak ise acil durumda
 * ekibi sistemin dışında iş yapmaya iterdi.
 *
 * KAÇIŞI OLMAYAN İKİ KURAL: iade ölçütleri (ambalaj açık / sulandırılmış /
 * soğuk zincir bozuk) ve sınır dışı ölçümde "uygun" sonucu. Orada risk bir
 * süreç ihlâli değil, hastaya giden ilacın ve ölçümün kendisi - bu yüzden
 * gerekçe sorulmuyor, doğrudan sunucunun reddi gösteriliyor.
 */
export interface TedarikBaglam {
  tazele(): void;
  /** Rota degistirir (or. yeni acilan tutanagin kartina gider). */
  git?(yol: string): void;
  /** Belge kartini MODAL acar (or. tutanaktan siparisine). */
  belgeAc?(belgeId: number): void;
}

/**
 * OLCUM KUTUSUNDAN SAYI OKUR. `Number('2,5')` NaN doner ve JSON'da `null`
 * olur: kullanici sicakligi yazdigini sanirken tutanaga HICBIR SEY
 * yazilmiyordu (E2E'de yakalandi). Turkce klavyede ondalik ayraci virguldur,
 * "2.5" de "2,5" de ayni olcumdur. Rakam hic yoksa deger YAZILMAZ ve
 * kullaniciya soylenir - sessizce 0 yazmak "0 derece olctum" demek olurdu.
 */
function olcumOku(ham: string | null): { deger?: number; uyari?: string } {
  const t = (ham ?? '').trim();
  if (t === '') return {};
  if (!/\d/.test(t))
    return { uyari: `"${t}" sıcaklık olarak okunamadı - ölçüm tutanağa yazılmadı.` };
  return { deger: tutarOku(t) };
}

/** Sunucu "zorla" isteyen bir redde mi düştü? Mesajdan değil, koddan bakılır. */
function zorlanabilir(h: unknown): boolean {
  const m = hataMetni(h);
  return /geçilemez|tamamlanmadı|işaretsiz|önce açılamaz|gelmeden|dolmuş|doğrulayamaz|kontrol edemez/i
    .test(m);
}

async function gerekceliTekrar(
  h: unknown, soru: string, tekrar: (gerekce: string) => Promise<unknown>,
): Promise<boolean> {
  if (!zorlanabilir(h)) { mesaj(hataMetni(h)); return false }
  const gerekce = await metinSor(`${hataMetni(h)}\n\n${soru}`, '', 'Gerekçe');
  if (!gerekce) return false;
  await tekrar(gerekce);
  return true;
}

const DOZ_ADIMLARI: Record<string, { adim: DozAdimi; ad: string }> = {
  'eczane-doz.hazirla': { adim: 'hazirla', ad: 'Hazırlandı' },
  'eczane-doz.kontrol': { adim: 'kontrol', ad: 'Kontrol edildi' },
  'eczane-doz.teslim': { adim: 'teslim', ad: 'Teslim edildi' },
  'eczane-doz.iade': { adim: 'iade', ad: 'İade' },
  'eczane-doz.imha': { adim: 'imha', ad: 'İmha' },
};

const HAZIRLAMA_ADIMLARI: Record<string, { adim: HazirlamaAdimi; ad: string }> = {
  'eczane-hazirlama.hasta-geldi': { adim: 'hasta-geldi', ad: 'Hasta geldi' },
  'eczane-hazirlama.hazirla': { adim: 'hazirla', ad: 'Hazırlamaya başla' },
  'eczane-hazirlama.dogrula': { adim: 'dogrula', ad: '2. eczacı doğrulaması' },
  'eczane-hazirlama.teslim': { adim: 'teslim', ad: 'Teslim' },
};

const ISEMRI_ADIMLARI: Record<string, { adim: IsEmriAdimi; ad: string }> = {
  'demirbas-is-emri.ata': { adim: 'ata', ad: 'Atandı' },
  'demirbas-is-emri.mudahale': { adim: 'mudahale', ad: 'Müdahaleye başla' },
  'demirbas-is-emri.parca-bekle': { adim: 'parca-bekle', ad: 'Parça bekliyor' },
  'demirbas-is-emri.dis-servis': { adim: 'dis-servis', ad: 'Dış servise gönder' },
  'demirbas-is-emri.tamamla': { adim: 'tamamla', ad: 'Tamamla' },
};

export async function tedarikAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  secililer: ListeSatiri[] | undefined,
  b: TedarikBaglam,
): Promise<boolean> {
  const bizim = kod.startsWith('eczane-') || kod.startsWith('kontrollu-')
             || kod.startsWith('demirbas-is-emri.') || kod.startsWith('demirbas-kalibrasyon.')
             || kod.startsWith('demirbas-cihaz.') || kod.startsWith('satinalma-');
  if (!bizim) return false;
  // CRUD kodlari (yeni / duzenle / sil) genel makinede kalir.
  //
  // TEK ISTISNA: MAL KABUL TUTANAGI. Genel kart yalniz BASLIK satirini yazar;
  //   muayene satirlarini irsaliyeden kopyalayan is ayri bir uctadir. "Yeni"
  //   genel makineye giderse sifir kalemli, muayene edilemeyen bir tutanak
  //   kaliyordu ortada (E2E'de kaldi da) - ustelik karti ham `belge_id`
  //   istiyordu, kimsenin ezberinde olmayan bir ic numara.
  if (kod !== 'satinalma-kabul.yeni'
      && (kod.endsWith('.yeni') || kod.endsWith('.duzenle') || kod.endsWith('.sil')))
    return false;

  const id = Number(satir?.id ?? 0);
  const kayitGerek = () => { mesaj('Önce bir kayıt seçin.'); return true };

  // ====================================================== eczane · doz ==
  if (DOZ_ADIMLARI[kod]) {
    if (!id) return kayitGerek();
    const { adim, ad } = DOZ_ADIMLARI[kod];
    if (adim === 'imha' && !await onay(`${satir?.ilac ?? 'Doz'} imha edilsin mi?`, true))
      return true;
    await guvenli(async () => {
      try {
        const y = await api.eczaneDozAdim(id, { adim });
        if (y.uyarilar?.length) mesaj(y.uyarilar.join('\n'));
        b.tazele();
      } catch (h) {
        // ÇİFT KONTROL GEÇİLEBİLİR AMA GEREKÇELİ (tek eczacılı nöbet).
        const oldu = await gerekceliTekrar(h,
          `${ad} adımı için çift kontrol kuralı geçilecek. Gerekçe:`,
          async gerekce => {
            const y = await api.eczaneDozAdim(id, { adim, zorla: true, gerekce });
            if (y.uyarilar?.length) mesaj(y.uyarilar.join('\n'));
            b.tazele();
          });
        if (!oldu) throw h;
      }
    });
    return true;
  }

  // ================================================ eczane · hazırlama ==
  if (HAZIRLAMA_ADIMLARI[kod]) {
    if (!id) return kayitGerek();
    const { adim, ad } = HAZIRLAMA_ADIMLARI[kod];
    await guvenli(async () => {
      try {
        const y = await api.eczaneHazirlamaAdim(id, { adim });
        if (y.uyarilar?.length) mesaj(y.uyarilar.join('\n'));
        b.tazele();
      } catch (h) {
        const oldu = await gerekceliTekrar(h, `${ad} için gerekçe:`, async gerekce => {
          const y = await api.eczaneHazirlamaAdim(id, { adim, zorla: true, gerekce });
          if (y.uyarilar?.length) mesaj(y.uyarilar.join('\n'));
          b.tazele();
        });
        if (!oldu) throw h;
      }
    });
    return true;
  }

  if (kod === 'eczane-hazirlama.iptal') {
    if (!id) return kayitGerek();
    const gerekce = await metinSor('Hazırlama iptal edilecek. Nedeni:', '', 'İptal nedeni');
    if (!gerekce) return true;
    await guvenli(async () => {
      await api.eczaneHazirlamaAdim(id, { adim: 'iptal', gerekce });
      b.tazele();
    });
    return true;
  }

  // DOZ HESABI: girdiler sırayla sorulur. Sonuç `hesaplanan` kolonuna yazılır;
  //   uygulanacak dozu eczacı kartta girer.
  if (kod === 'eczane-hazirlama.doz-hesapla') {
    if (!id) return kayitGerek();
    const boy = Number(await metinSor('Hastanın boyu (cm):', '', 'Boy') ?? 0);
    if (!boy) return true;
    const kilo = Number(await metinSor('Hastanın kilosu (kg):', '', 'Kilo') ?? 0);
    if (!kilo) return true;
    const krkl = Number(await metinSor(
      'Kreatinin klirensi (mL/dk) - Calvert (AUC) hesabı için. Yoksa boş bırakın:',
      '', 'KrKl') ?? 0);
    await guvenli(async () => {
      const y = await api.eczaneDozHesapla(id, {
        boyCm: boy, kiloKg: kilo, krkl: krkl || undefined,
      });
      const satirlar = y.kalemler.map(k => k.hesaplanan === null
        ? `• ${k.ad}: çözülemedi (${k.protokolDoz}) - elle girilmeli`
        : `• ${k.ad}: ${k.hesaplanan} ${k.birim ?? ''} (${k.yontem})`);
      mesaj(`VYA: ${y.vyaM2} m²\n\n${satirlar.join('\n')}\n\n${y.not}`);
      b.tazele();
    });
    return true;
  }

  // ===================================================== eczane · iade ==
  if (kod.startsWith('eczane-iade.karar')) {
    if (!id) return kayitGerek();
    const karar = kod === 'eczane-iade.karar-stok' ? 1
                : kod === 'eczane-iade.karar-imha' ? 2 : 3;
    await guvenli(async () => {
      const y = await api.eczaneIadeKarar(id, { karar });
      if (y.girisBelgeId) mesaj(`Stoğa alındı - giriş fişi ${y.girisBelgeId}.`);
      if (y.uyarilar?.length) mesaj(y.uyarilar.join('\n'));
      b.tazele();
    });
    return true;
  }

  // ===================================================== eczane · imha ==
  if (kod === 'eczane-imha.onayla') {
    if (!id) return kayitGerek();
    const komisyon = await metinSor(
      'İmha komisyonu üyeleri (imha tek kişinin işi değildir):', '', 'Komisyon');
    if (!komisyon) return true;
    await guvenli(async () => { await api.eczaneImhaOnayla(id, komisyon); b.tazele() });
    return true;
  }

  if (kod === 'eczane-imha.imha-et') {
    if (!id) return kayitGerek();
    if (!await onay('Tutanaktaki kalemler imha edilecek ve stoktan düşülecek. Sürdürülsün mü?',
                    true)) return true;
    const atik = await metinSor('Atık teslim no (varsa):', '', 'Atık teslim no');
    await guvenli(async () => {
      const y = await api.eczaneImhaEt(id, { atikTeslimNo: atik ?? undefined });
      mesaj(`İmha edildi. Çıkış fişi ${y.belgeId}, ${y.satir} kalem`
            + (y.defterSatiri > 0 ? `, ${y.defterSatiri} kontrollü ilaç defter satırı.` : '.'));
      b.tazele();
    });
    return true;
  }

  // ================================================ kontrollü · sayım ==
  if (kod === 'kontrollu-sayim.kapat') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      try {
        const y = await api.eczaneSayimKapat(id, {});
        mesaj(y.uyumsuz > 0 ? 'Fark tutanağıyla kapatıldı.' : 'Sayım uyumlu kapandı.');
        b.tazele();
      } catch (h) {
        // FARK VARKEN KAPATMA AYRI BİR KARAR: kontrollü ilaç farkı bir olaydır.
        if (!/fark var/i.test(hataMetni(h))) throw h;
        const aciklama = await metinSor(
          `${hataMetni(h)}\n\nFark tutanağı açılarak kapatılacak. Açıklama:`, '', 'Açıklama');
        if (!aciklama) return;
        const y = await api.eczaneSayimKapat(id, { farklaKapat: true, aciklama });
        mesaj(`Fark tutanağıyla kapatıldı (${y.uyumsuz} satır).`);
        b.tazele();
      }
    });
    return true;
  }

  // ================================================ biyomedikal · iş emri ==
  if (ISEMRI_ADIMLARI[kod]) {
    if (!id) return kayitGerek();
    const { adim, ad } = ISEMRI_ADIMLARI[kod];
    await guvenli(async () => {
      try {
        const y = await api.demirbasIsEmriAdim(id, { adim });
        if (y.uyarilar?.length) mesaj(y.uyarilar.join('\n'));
        b.tazele();
      } catch (h) {
        const oldu = await gerekceliTekrar(h,
          `${ad} - eksik maddeyle kapatma gerekçesi:`, async gerekce => {
            const y = await api.demirbasIsEmriAdim(id, { adim, zorla: true, gerekce });
            if (y.uyarilar?.length) mesaj(y.uyarilar.join('\n'));
            b.tazele();
          });
        if (!oldu) throw h;
      }
    });
    return true;
  }

  if (kod === 'demirbas-is-emri.iptal') {
    if (!id) return kayitGerek();
    const gerekce = await metinSor('İş emri iptal edilecek. Nedeni:', '', 'İptal nedeni');
    if (!gerekce) return true;
    await guvenli(async () => {
      await api.demirbasIsEmriAdim(id, { adim: 'iptal', gerekce }); b.tazele();
    });
    return true;
  }

  if (kod === 'demirbas-is-emri.parca-cikis') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      const y = await api.demirbasParcaCikis(id, {});
      mesaj(`${y.satir} parça stoktan düşüldü - çıkış fişi ${y.belgeId}.`);
      b.tazele();
    });
    return true;
  }

  // =========================================== biyomedikal · kalibrasyon ==
  if (kod === 'demirbas-kalibrasyon.tamamla') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      const bitir = async (ek: Record<string, unknown>) => {
        const y = await api.demirbasKalibrasyonTamamla(id, ek);
        if (y.uyarilar?.length) mesaj(y.uyarilar.join('\n'));
        b.tazele();
      };
      try { await bitir({}) }
      catch (h) {
        const m = hataMetni(h);
        // UYGUNSUZ SONUCUN ASIL SORUSU: cihaz ne zamandır sapıyordu.
        if (/geriye dönük/i.test(m)) {
          const d = await metinSor(
            'Cihaz ne zamandan beri sapıyor, bu sürede kaç hastada kullanıldı?',
            '', 'Geriye dönük değerlendirme');
          if (!d) return;
          await bitir({ geriyeDonukDeger: d });
          return;
        }
        if (/referans/i.test(m)) {
          const g = await metinSor(`${m}\n\nYine de sonuçlandırma gerekçesi:`, '', 'Gerekçe');
          if (!g) return;
          try { await bitir({ zorla: true, gerekce: g }) }
          catch (h2) {
            if (!/geriye dönük/i.test(hataMetni(h2))) throw h2;
            const d = await metinSor(
              'Cihaz ne zamandan beri sapıyor, bu sürede kaç hastada kullanıldı?',
              '', 'Geriye dönük değerlendirme');
            if (!d) return;
            await bitir({ zorla: true, gerekce: g, geriyeDonukDeger: d });
          }
          return;
        }
        throw h;
      }
    });
    return true;
  }

  // ================================================ biyomedikal · hareket ==
  if (kod.startsWith('demirbas-cihaz.hareket')) {
    if (!id) return kayitGerek();
    const hareket = kod === 'demirbas-cihaz.hareket-zimmet' ? 1
                  : kod === 'demirbas-cihaz.hareket-yer' ? 2
                  : kod === 'demirbas-cihaz.hareket-havuz' ? 3 : 7;
    if (hareket === 7 && !await onay(
      'Cihaz HURDAYA ayrılacak. Bu işlem cihazı envanterden düşürür. Sürdürülsün mü?', true))
      return true;
    const aciklama = await metinSor(
      hareket === 7 ? 'Hurda gerekçesi:' : 'Açıklama:', '', 'Açıklama');
    if (hareket === 7 && !aciklama) return true;
    await guvenli(async () => {
      await api.demirbasHareket(id, { hareket, aciklama: aciklama ?? undefined });
      b.tazele();
    });
    return true;
  }

  // ==================================================== satınalma · talep ==
  if (kod === 'satinalma-talep.gonder') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      const y = await api.satinalmaTalepGonder(id);
      const zincir = y.basamaklar.map(x => `${x.basamak}. ${ROL_ADI[x.rol] ?? 'Onay'}`).join(' → ');
      mesaj(`Onaya gönderildi.\nTutar: ${y.tutar}\nBütçe: ${BUTCE_ADI[y.butceDurumu]}\n`
            + `Zincir: ${zincir}`);
      b.tazele();
    });
    return true;
  }

  if (kod.startsWith('satinalma-talep.karar-')) {
    if (!id) return kayitGerek();
    const karar = kod === 'satinalma-talep.karar-onayla' ? 'onayla' as const
                : kod === 'satinalma-talep.karar-reddet' ? 'reddet' as const
                : kod === 'satinalma-talep.karar-bilgi' ? 'bilgi-iste' as const
                : 'sozlu-onay' as const;
    let gerekce: string | null = '';
    if (karar === 'reddet' || karar === 'bilgi-iste') {
      gerekce = await metinSor(
        karar === 'reddet' ? 'Red gerekçesi:' : 'Hangi bilgi isteniyor?', '', 'Gerekçe');
      if (!gerekce) return true;
    }
    await guvenli(async () => {
      const y = await api.satinalmaTalepKarar(id, { karar, gerekce: gerekce ?? undefined });
      mesaj(y.sonrakiBasamak
        ? `${y.basamak}. basamak kaydedildi - sıradaki basamak: ${y.sonrakiBasamak}.`
        : `Zincir tamamlandı (talep durumu ${y.talepDurum}).`);
      b.tazele();
    });
    return true;
  }

  if (kod === 'satinalma-talep.birlestir') {
    const secim = (secililer ?? []).map(s => Number(s.id)).filter(Boolean);
    if (secim.length < 2) {
      mesaj('Birleştirmek için en az iki talep seçin - ilk seçilen HEDEF olur.');
      return true;
    }
    const [hedef, ...kaynak] = secim;
    if (!await onay(
      `${kaynak.length} talep, ${hedef} numaralı talebe birleştirilecek. `
      + 'Kaynak talepler silinmez; "birleştirildi" olarak kapanır. Sürdürülsün mü?'))
      return true;
    await guvenli(async () => {
      const y = await api.satinalmaTalepBirlestir(hedef, kaynak);
      mesaj(`${y.birlestirilen} talep birleştirildi, ${y.tasinanSatir} satır taşındı.`);
      b.tazele();
    });
    return true;
  }

  if (kod === 'satinalma-talep.siparise') {
    if (!id) return kayitGerek();
    const taraf = Number(await metinSor(
      'Sipariş hangi tedarikçiye verilecek? (cari no)', '', 'Tedarikçi') ?? 0);
    if (!taraf) return true;
    const sozTeslim = await metinSor(
      'Söz verilen teslim tarihi (YYYY-AA-GG) - gecikme bu tarihten sayılır:',
      '', 'Teslim tarihi');
    await guvenli(async () => {
      const y = await api.satinalmaSiparise(id, {
        tarafId: taraf, sozTeslim: sozTeslim || undefined,
      });
      mesaj(`Alış siparişi ${y.belgeId} oluşturuldu (${y.baglanan}/${y.satir} satır bağlandı).`
            + (y.uyarilar?.length ? `\n${y.uyarilar.join('\n')}` : ''));
      b.tazele();
    });
    return true;
  }

  // =================================================== satınalma · teklif ==
  if (kod === 'satinalma-teklif.davet') {
    if (!id) return kayitGerek();
    if (!await onay(
      'Davet gönderilecek ve DEĞERLENDİRME AĞIRLIKLARI KİLİTLENECEK. '
      + 'Sonradan ağırlık değiştirmek, kazananı seçip gerekçeyi sonra yazmaktır. Sürdürülsün mü?'))
      return true;
    await guvenli(async () => {
      const y = await api.satinalmaTeklifDavet(id, {});
      mesaj(`Davet gönderildi (${y.firmaSayisi} firma). Ağırlıklar kilitlendi.`
            + (y.uyarilar?.length ? `\n${y.uyarilar.join('\n')}` : ''));
      b.tazele();
    });
    return true;
  }

  if (kod === 'satinalma-teklif.ac') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      const goster = (y: { elenen: number; puanlanan: number; siralama: { unvan: string; tutar: number; puanToplam: number | null; durum: number; elemeNeden: string }[] }) => {
        const satirlar = y.siralama.map(s => s.durum === 3
          ? `• ${s.unvan}: ELENDİ (${s.elemeNeden})`
          : `• ${s.unvan}: ${s.tutar} · puan ${s.puanToplam ?? '-'}`);
        mesaj(`Teklifler açıldı (${y.puanlanan} puanlandı, ${y.elenen} elendi).\n\n`
              + satirlar.join('\n'));
        b.tazele();
      };
      try { goster(await api.satinalmaTeklifAc(id, {})) }
      catch (h) {
        // ERKEN AÇILIŞ: son tarihten önce açılan teklif, diğer firmalara
        //   söylenebilecek bir bilgidir - gerekçesi günlüğe yazılır.
        if (!/önce açılamaz/i.test(hataMetni(h))) throw h;
        const g = await metinSor(`${hataMetni(h)}\n\nErken açılış gerekçesi:`, '', 'Gerekçe');
        if (!g) return;
        goster(await api.satinalmaTeklifAc(id, { zorla: true, gerekce: g }));
      }
    });
    return true;
  }

  if (kod === 'satinalma-teklif.karar') {
    if (!id) return kayitGerek();
    const firma = Number(await metinSor(
      'Kazanan firmanın cari numarası:', '', 'Kazanan firma') ?? 0);
    if (!firma) return true;
    await guvenli(async () => {
      try {
        const y = await api.satinalmaTeklifKarar(id, { kararFirmaId: firma });
        mesaj(y.enDusukAlindi ? 'Karar kaydedildi (en düşük teklif).' : 'Karar kaydedildi.');
        b.tazele();
      } catch (h) {
        // EN DÜŞÜK ALINMIYORSA GEREKÇE ŞART - denetimin ilk sorusu.
        if (!/en düşük/i.test(hataMetni(h))) throw h;
        const g = await metinSor(`${hataMetni(h)}\n\nKarar gerekçesi:`, '', 'Gerekçe');
        if (!g) return;
        await api.satinalmaTeklifKarar(id, { kararFirmaId: firma, gerekce: g });
        b.tazele();
      }
    });
    return true;
  }

  // ================================================== satınalma · sipariş ==
  if (kod === 'satinalma-siparis.gecikme') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      const y = await api.satinalmaSiparisTakip(id, { gecikmeBildir: true });
      mesaj(`Gecikme bildirildi (${y.gecikmeGun} gün).`
            + (y.olayYazildi ? ' Tedarikçi performansına işlendi.' : ''));
      b.tazele();
    });
    return true;
  }

  if (kod === 'satinalma-siparis.ceza') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      try {
        const y = await api.satinalmaCeza(id, {});
        mesaj(`Gecikme cezası işlendi: ${y.cezaTutar} (${y.gecikmeGun} gün)`
              + (y.ustSinir ? `, üst sınır ${y.ustSinir}.` : '.'));
        b.tazele();
      } catch (h) {
        // SÖZLEŞMESİZ CEZA HESAPLANMAZ: oran sözleşmede yazar.
        if (!/sözleşmede/i.test(hataMetni(h))) throw h;
        const t = Number(await metinSor(
          `${hataMetni(h)}\n\nCeza tutarı:`, '', 'Ceza tutarı') ?? 0);
        if (!t) return;
        const y = await api.satinalmaCeza(id, { tutar: t });
        mesaj(`Gecikme cezası işlendi: ${y.cezaTutar}.`);
        b.tazele();
      }
    });
    return true;
  }

  // =================================================== satınalma · mal kabul ==
  // TUTANAK BELGEDEN DOĞAR: önce hangi irsaliyenin muayene edileceği sorulur,
  //   satırlar o belgeden kopyalanır. Boş bir kart açıp kullanıcıdan belge
  //   numarası beklemek, sayılacak kalemleri hiç getirmemek demekti.
  if (kod === 'satinalma-kabul.yeni') {
    await guvenli(async () => {
      const y = await api.satinalmaKabulBekleyenBelgeler();
      if (y.satirlar.length === 0) {
        mesaj('Tutanak bekleyen alış irsaliyesi/faturası yok.\n\n'
              + 'Tutanak bir belgeden doğar: önce mal girişinin irsaliyesi '
              + 'kaydedilmeli. (Tutanağı olan belge bu listede görünmez.)');
        return;
      }
      const secenekler = y.satirlar.map(x => ({
        kod: String(x.id),
        ad: `${x.belgeNo} · ${tarihYaz(String(x.belgeTarihi))} · ${x.tedarikci || '(tedarikçi yok)'}`
            + ` · ${x.satir} kalem${x.tur === 11 ? ' · fatura' : ''}`,
      }));
      const secim = await listeSor(
        'Hangi irsaliye muayene edilecek? (satırlar bu belgeden kopyalanır)',
        secenekler, secenekler[0].kod, 'Belge');
      if (!secim) return;
      const belge = y.satirlar.find(x => String(x.id) === secim);
      const komisyon = await metinSor(
        'Muayene komisyonu (kimler sayıyor) - sonra da yazılabilir:', '', 'Komisyon');
      if (komisyon === null) return;
      const t = await api.satinalmaKabul({
        belgeId: Number(secim),
        siparisBelgeId: belge?.siparisBelgeId ?? undefined,
        komisyon: komisyon || undefined,
      });
      // SİPARİŞ BAĞI YOKSA SÖYLENİR: karşılaştırma yapılamayacağını kullanıcı
      //   tutanağı doldurduktan sonra değil, şimdi bilmeli.
      const notlar = [`Tutanak açıldı: ${t.satir} kalem.`];
      if (!belge?.siparisBelgeId)
        notlar.push('Belgenin sipariş bağı yok - sipariş miktarı '
                    + 'karşılaştırması için kartta "Sipariş" alanını doldurun.');
      mesaj(notlar.join('\n'));
      b.tazele();
      b.git?.(`/satinalma-kabul/${t.id}`);
    });
    return true;
  }

  if (kod === 'satinalma-kabul.tumunu-kabul') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      const y = await api.satinalmaKabulTumunu(id);
      // KAREKOD EKSİĞİ AYNI PENCEREDE (737): "sayılan = irsaliye miktarı"
      //   demek kutuları saydığını iddia etmektir; okutulmamış kutu varsa
      //   kullanıcı bunu kabul imzasından ÖNCE görmeli.
      mesaj([`${y.kabulEdilen} kalem kabul edildi (sayılan = irsaliye miktarı).`,
             ...(y.uyarilar?.length ? ['', ...y.uyarilar] : [])].join('\n'));
      b.tazele();
    });
    return true;
  }

  if (kod.startsWith('satinalma-kabul.karar-')) {
    if (!id) return kayitGerek();
    const sonuc = kod === 'satinalma-kabul.karar-kabul' ? 1
                : kod === 'satinalma-kabul.karar-kismi' ? 2 : 3;
    let uygunsuzluk: string | null = '';
    if (sonuc !== 1) {
      uygunsuzluk = await metinSor(
        sonuc === 2 ? 'Hangi kalemde ne eksik/uygunsuz?' : 'Ret gerekçesi:',
        '', 'Uygunsuzluk');
      if (!uygunsuzluk) return true;
    }
    if (sonuc === 3 && !await onay(
      'Sevkiyat REDDEDİLECEK. Sipariş açık kalır (mal geri gidiyor, taahhüt sürüyor). '
      + 'Sürdürülsün mü?', true)) return true;
    await guvenli(async () => {
      const bitir = async (ek: Record<string, unknown>) => {
        const y = await api.satinalmaKabulKarar(id, {
          sonuc, uygunsuzluk: uygunsuzluk ?? undefined, ...ek,
        });
        // KARAR SESSİZ KALMAZ (737): uyarı yoksa hiçbir şey söylenmiyordu,
        //   kullanıcı düğmeye bastı mı basmadı mı anlamıyordu. Ret ve kısmi
        //   kabulde en azından soru soruluyor; asıl sessiz kalan "Kabul"dü.
        const ad = sonuc === 1 ? 'Kabul' : sonuc === 2 ? 'Kısmi kabul' : 'Ret';
        mesaj([`Tutanak "${ad}" olarak kapatıldı`
               + (y.retKalem > 0 ? ` (${y.retKalem} kalem reddedildi).` : '.'),
               ...(y.uyarilar?.length ? ['', ...y.uyarilar] : [])].join('\n'));
        b.tazele();
      };
      try { await bitir({}) }
      catch (h) {
        // SOĞUK ZİNCİR ÖLÇÜMÜ: "ölçülmedi" ile "uygun" aynı şey değil.
        if (!/soğuk zincir/i.test(hataMetni(h))) throw h;
        const uygun = await onay(
          'Soğuk zincir ölçümü uygun muydu? (Hayır = uygunsuz, tutanağa yazılır)');
        const sic = await metinSor('Ölçülen sıcaklık (°C) - biliniyorsa:', '', 'Sıcaklık');
        const olcum = olcumOku(sic);
        if (olcum.uyari) mesaj(olcum.uyari);
        await bitir({
          sogukZincirUygun: uygun ? 1 : 2,
          sicaklik: olcum.deger,
        });
      }
    });
    return true;
  }

  // KAREKOD OKUMA. Okuyucu klavye emülasyonlu: kutuyu okuttuğunda kod metin
  //   kutusuna yazılıp Enter'a basılmış olur. Birden çok kod satır satır
  //   yapıştırılabilsin diye çok satırlı okunuyor.
  if (kod === 'satinalma-kabul.karekod') {
    if (!id) return kayitGerek();
    const ham = await metinSor(
      'Karekodu okutun (birden çok kod satır satır yapıştırılabilir, '
      + 'Ctrl+Enter ile onaylanır):',
      '', 'Karekod', true);
    if (!ham) return true;
    const kodlar = ham.split(/[\r\n]+/).map(x => x.trim()).filter(Boolean);
    if (kodlar.length === 0) return true;
    await guvenli(async () => {
      const y = await api.satinalmaKabulKarekod(id, kodlar);
      // SONUÇ SINIFLARI AYRI AYRI SAYILIR: "12 okutuldu" demek, 3'ünün
      //   mükerrer olduğunu gizlerdi.
      const bas = [`${y.yazildi} kutu yazıldı`];
      if (y.mukerrer > 0) bas.push(`${y.mukerrer} MÜKERRER`);
      if (y.beklenmeyen > 0) bas.push(`${y.beklenmeyen} beklenmeyen`);
      if (y.okunamadi > 0) bas.push(`${y.okunamadi} okunamadı`);

      const sorunlu = y.sonuclar.filter(x => x.sonuc !== 'yazildi' || x.uyari);
      const ayrinti = sorunlu.map(x => x.sonuc === 'okunamadi'
        ? `• Okunamadı: ${x.mesaj}`
        : `• ${x.ad || x.gtin}${x.seriNo ? ` / ${x.seriNo}` : ''}: `
          + (x.sonuc === 'mukerrer' ? x.mesaj
             : x.sonuc === 'beklenmeyen' ? 'bu tutanakta beklenmiyor'
             : x.uyari));

      const tablo = y.ozet
        .filter(o => o.beklenen > 0 || o.okutulan > 0)
        .map(o => `• ${o.ad}: ${o.okutulan} / ${o.beklenen}`
                  + (o.sktCeliskisi > 0 ? ` · ${o.sktCeliskisi} miad çelişkisi` : '')
                  + (o.miadiGecmis > 0 ? ` · ${o.miadiGecmis} MİADI GEÇMİŞ` : ''));

      mesaj([bas.join(' · '), ayrinti.join('\n'), '', tablo.join('\n')]
              .filter(Boolean).join('\n'));
      b.tazele();
    });
    return true;
  }

  if (kod === 'satinalma-kabul.karekod-ozet') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      const y = await api.satinalmaKabulKarekodOzet(id);
      const tablo = y.ozet.map(o => `• ${o.ad}: ${o.okutulan} / ${o.beklenen}`
        + (o.sktCeliskisi > 0 ? ` · ${o.sktCeliskisi} miad çelişkisi` : '')
        + (o.miadiGecmis > 0 ? ` · ${o.miadiGecmis} MİADI GEÇMİŞ` : ''));
      mesaj(tablo.length > 0
        ? `Okutulan / Beklenen\n\n${tablo.join('\n')}`
        : 'Bu tutanakta muayene satırı yok.');
    });
    return true;
  }

  // ==================================================== satınalma · İTS ==
  // KUYRUĞA ALMA MUAYENEDEN SONRA: hangi kutunun kabul edildiği kararla
  //   belli olur. Uç açık tutanağı reddeder; burada da kullanıcıya
  //   sunucunun sebebini gösteriyoruz, ekran kendi kuralını yazmıyor.
  if (kod === 'satinalma-kabul.its-gonder') {
    if (!id) return kayitGerek();
    const gln = await metinSor(
      'Gönderen deponun GLN numarası (İTS mal alımda ister) - biliniyorsa:',
      '', 'GLN');
    if (gln === null) return true;
    await guvenli(async () => {
      const y = await api.satinalmaKabulItsGonder(id, {
        karsiGln: gln || undefined, simdiGonder: false,
      });
      const satirlar = [`Bildirim ${y.bildirimId} kuyruğa alındı (${y.kuyrukta} kutu).`];
      if (y.uyarilar?.length) satirlar.push(...y.uyarilar);
      satirlar.push(y.gonderim);
      mesaj(satirlar.join('\n'));
      b.tazele();
    });
    return true;
  }

  if (kod === 'satinalma-kabul.its-durum') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      const y = await api.satinalmaKabulItsDurum(id);
      if (y.bildirimler.length === 0) {
        mesaj('Bu tutanak için İTS bildirimi yok - önce karekod okutun.');
        return;
      }
      const DURUM: Record<number, string> = {
        0: 'Taslak', 1: 'Kuyrukta', 2: 'Gönderiliyor',
        3: 'Gönderildi', 4: 'HATALI', 5: 'İptal',
      };
      const bas = y.bildirimler.map(x =>
        `• #${x.id} ${DURUM[x.durum] ?? x.durum}`
        + ` · ${x.kutu} kutu / ${x.kalem} kalem`
        + (x.testMi ? ' · TEST ORTAMI' : '')
        + (x.itsBildirimNo ? ` · İTS no ${x.itsBildirimNo}` : '')
        + (x.hataMesaj ? ` · ${x.hataMesaj}` : '')
        + (x.aciklama ? ` · ${x.aciklama}` : ''));
      const kalem = y.kalemler.map(x =>
        `   ${x.ad}${x.lot ? ` / lot ${x.lot}` : ''}: ${x.adet} kutu`
        + (x.beklenmeyen > 0 ? ` (${x.beklenmeyen} beklenmeyen)` : ''));
      // HESAP KAPALIYSA SÖYLENİR: kuyruk duruyorsa sebebi budur.
      const kapi = y.hesapVar
        ? (y.testMi ? 'İTS hesabı TEST ortamında.' : '')
        : 'İTS hesabı tanımlı değil - kuyruk bekler.';
      mesaj([bas.join('\n'), '', kalem.join('\n'), '', kapi]
              .filter(Boolean).join('\n'));
    });
    return true;
  }

  if (kod === 'satinalma-kabul.its-iptal') {
    if (!id) return kayitGerek();
    await guvenli(async () => {
      const y = await api.satinalmaKabulItsDurum(id);
      // İPTAL EDİLEBİLİR OLAN: taslak, kuyrukta ya da hatalı. Gönderilmiş
      //   bildirim İTS'te kayıt oluşturdu; geri alma ayrı bildirimdir.
      const aday = y.bildirimler.filter(x => [0, 1, 4].includes(x.durum));
      if (aday.length === 0) {
        mesaj('İptal edilebilir bildirim yok (gönderilmiş bildirim için '
              + 'iade/deaktivasyon gerekir).');
        return;
      }
      const hedef = aday[aday.length - 1];
      const gerekce = await metinSor(
        `#${hedef.id} numaralı bildirim (${hedef.kutu} kutu) iptal edilecek. Gerekçe:`,
        '', 'Gerekçe');
      if (!gerekce) return;
      await api.satinalmaKabulItsIptal(id, hedef.id, gerekce);
      b.tazele();
    });
    return true;
  }
  if (kod === 'satinalma-kabul.siparise-git') {
    const sip = Number(satir?.siparisBelgeId ?? 0);
    if (!sip) {
      mesaj('Tutanakta sipariş belgesi yok - kartın "Sipariş" alanından bağlayın.');
      return true;
    }
    // BELGE KARTI MODAL AÇILIR (737): düğmenin adı "Git"ti ama hiçbir yere
    //   gitmiyordu - belge numarasını yazıp kullanıcıyı Siparişler ekranında
    //   o numarayı aramaya bırakıyordu. Sipariş `belge` tür 9'dur; belge kartı
    //   id ile açılır, hangi listede olduğumuzdan bağımsızdır.
    if (b.belgeAc) b.belgeAc(sip);
    else mesaj(`Sipariş belge no: ${sip}`);
    return true;
  }

  // ========================================= satınalma · fatura kontrolü ==
  if (kod === 'satinalma-fatura.eslestir') {
    if (!id) return kayitGerek();
    const fatura = Number(satir?.faturaBelgeId ?? 0);
    if (!fatura) { mesaj('Satırda fatura belgesi yok.'); return true }
    await guvenli(async () => {
      const y = await api.satinalmaFaturaEslestir(fatura);
      mesaj(`Sipariş ${y.siparisTutar} · Teslim ${y.teslimTutar} · Fatura ${y.faturaTutar}\n`
            + `Fark: ${y.farkTutar}${y.farkMetni ? `\n${y.farkMetni}` : ''}`);
      b.tazele();
    });
    return true;
  }

  if (kod.startsWith('satinalma-fatura.odeme-')) {
    if (!id) return kayitGerek();
    const karar = kod === 'satinalma-fatura.odeme-onay' ? 1
                : kod === 'satinalma-fatura.odeme-durdur' ? 2 : 3;
    let metin: string | null = '';
    if (karar !== 1) {
      metin = await metinSor(karar === 2 ? 'Durdurma gerekçesi:' : 'İtiraz metni:',
                             '', 'Gerekçe');
      if (!metin) return true;
    }
    await guvenli(async () => {
      try {
        await api.satinalmaOdemeKarar(id, { karar, metin: metin ?? undefined });
        b.tazele();
      } catch (h) {
        // FARKLI FATURADA ONAY: gerekçe ya da mahsup ister.
        if (!/gerekçe ya da mahsup/i.test(hataMetni(h))) throw h;
        const g = await metinSor(`${hataMetni(h)}\n\nOnay gerekçesi:`, '', 'Gerekçe');
        if (!g) return;
        await api.satinalmaOdemeKarar(id, { karar, metin: g });
        b.tazele();
      }
    });
    return true;
  }

  return false;
}

const ROL_ADI: Record<number, string> = {
  1: 'Birim sorumlusu', 2: 'Satınalma', 3: 'Başhekim / müdür',
  4: 'Mali işler', 5: 'Yönetim kurulu',
};

const BUTCE_ADI: Record<number, string> = {
  0: 'kalem seçilmemiş', 1: 'yeterli', 2: 'aşıyor (ek onay)', 3: 'aşıyor (engel)',
};
