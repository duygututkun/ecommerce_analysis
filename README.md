# E-Ticaret Veri Analizi

Bu projede, bir e-ticaret şirketinin Eylül 2016 - Eylül 2018 dönemine ait 89K+ sipariş kaydından oluşan satış verileri SQL ile analiz edilmiş ve Power BI kullanılarak görselleştirilmiştir.

Amaç; satış performansını, ödeme tercihlerini, lojistik performansını, müşteri davranışını, zamana bağlı değişimleri ve satıcı performansını incelemektir.

## Dataset

Veri seti; df_Customers, df_OrderItems, df_Orders, df_Payments ve df_Products olmak üzere 5 ilişkisel tablodan oluşmaktadır. Bu tablolar ürün detayları, ödeme bilgileri, müşteri kimliği, siparişlerin oluşturulmasından teslim edilmesine kadar geçen sürece ilişkin tarih bilgileri dahil olmak üzere her sipariş hakkında kapsamlı bilgiler içermektedir.

Kullanılan veri seti: https://www.kaggle.com/datasets/bytadit/ecommerce-order-dataset

## Kullanılan Teknolojiler

- SQL
- Power BI

## Öne Çıkan Bulgular

1) **Toplam gelir 2.15 Milyar BRL'dir.**

   3 yıllık dönem incelendiğinde toplam gelir Kasım 2017'de en yüksek, Eylül 2018'de en düşük seviyeye ulaşmıştır.

2) **En çok tercih edilen ödeme yöntemi *credit_card* (%73,69), en az tercih edilen ödeme yöntemi ise *debit_card* (%1,44) olmuştur.**

   Müşterilerin kredi kartını daha fazla tercih etme nedeni sunulan ödeme kolaylıkları olabilir. Ödemelerin %50,39'unun taksitli olarak gerçekleştirilmesi taksit imkanlarının ödeme tercihlerinde önemli bir etken olduğunu göstermektedir.

3) **Ortalama sipariş tutarı 24.165,41 BRL, medyan ise 15.007 BRL'dir.**

   Bu durum, bazı yüksek tutarlı siparişlerin ortalamayı yükselttiğini göstermektedir.

4) **Gelirin %74,53'ü *toys* kategorisinden geliyor.**

   *Toys* kategorisi toplam gelirin büyük çoğunluğunu oluşturmaktadır. Bu durum, *toys* kategorisinin şirket için önemli bir gelir kaynağı olduğunu gösterirken bir yandan şirketin tek bir kategoriye olan bağımlılığı risk yaratabilir.

5) ***Sao Paulo* sipariş yoğunluğu açısından öne çıkan şehir olmuştur.**

   Bu durum, Sao Paulo'nun şirketin satış performansında önemli bir konuma sahip olduğunu göstermektedir.

6) **Şehirlerin %86,43'ünde sipariş sayısı 20'nin altında kalmıştır.**

   Şehirlerin büyük çoğunluğunda sipariş sayısının düşük olması, siparişlerin belirli şehirlerde yoğunlaştığını göstermektedir.

7) **Siparişlerin %97,89'u başarıyla teslim edilmiştir.**

   Operasyonun genel olarak başarılı bir şekilde yürütüldüğünü göstermektedir.

8) **Kasım 2017 satış performansında öne çıkan dönem olmuştur.**

   Bu dönem, hem sipariş sayısının hem de elde edilen gelirin en yüksek seviyeye ulaştığı dönemdir. Aynı zamanda 24 Kasım 2017 tüm dönem içerisindeki en yüksek sipariş sayısına ulaşılan gün olmuştur. Bunun nedeni black friday indirimleri olabilir.

9) **Toplam gelirin %82,59'u en yüksek gelir elde eden satıcıların %20'sinden oluşuyor.**

    Gelirin büyük çoğunluğu küçük bir satıcı grubunda yoğunlaşmıştır. Bu satıcıların toplam gelir içerisindeki yüksek payı, şirketin gelir performansında önemli bir etkiye sahiptir. Yüksek gelir elde eden satıcıların performansının ve platformdaki devamlılığının korunmasının yanı sıra diğer satıcıların performanslarının geliştirilmesi gelir kaynaklarının çeşitlendirilmesine ve satıcı yoğunlaşmasının azaltılmasına katkı sağlayabilir.

10) **Sipariş yoğunluğunun en yüksek olduğu gün Salı, en düşük olduğu gün ise Cumartesi olmuştur. Gün içerisinde en yoğun sipariş verilen saat aralığı ise 14:00-15:00'dir.**

    Müşteri yoğunluğunun yüksek olduğu bu dönemlerde kampanyalar planlanabilir.

11) **Siparişlerin %32,56'sı 2 hafta veya daha uzun sürede teslim ediliyor.**

    Bu durum müşteri deneyimini olumsuz etkileyebilir.
