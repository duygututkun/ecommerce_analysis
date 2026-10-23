--  ANALİZ SORULARI
-- 1. Teslim edilen sipariş sayısı nedir? Teslim edilmemiş siparişlerin durum dağılımı nasıldır?
-- 2. Toplam gelir nedir?
-- 3. Ortalama sipariş tutarı nedir? Ödeme yöntemine göre nasıl değişiyor?
-- 4. En fazla ve en az sipariş hangi şehirlerden gelmektedir?
-- 5. Gelir tutarı en yüksek şehirler hangileridir?
-- 6. En çok satan ürün kategorileri nelerdir?
-- 7. Gelir tutarı en yüksek ürün kategorileri hangileridir ve toplam gelirdeki payları nedir?
-- 8. Her kategori içinde en çok satan ilk 3 ürün nedir?
-- 9. En çok kullanılan ödeme yöntemi hangisidir?
-- 10. Taksitli ödeme oranı nedir?
-- 11. Siparişlerin ortalama onay süresi ve teslim süresi ne kadardır?
-- 12. Geç teslim edilen sipariş oranı nedir? Zamanla nasıl değişiyor?
-- 13. Teslimat gecikmeleri en çok hangi şehirlerde yaşanıyor?
-- 14. Satıcıların performansı nasıldır? (sipariş sayısı,ürün sayısı,gelir,geç teslim oranı,iptal sipariş oranı)
-- 15. En yüksek gelir elde eden ilk %20 satıcı toplam gelirin yüzde kaçını oluşturuyor?
-- 16. Siparişlerin onaylanma ve ve teslimat sürelerinin dağılımı nasıldır?
-- 17. Teslimat süresi 2 haftadan uzun olan siparişler hangi şehir ve satıcılarda yoğunlaşıyor?
-- 18. Günlük ve aylık sipariş sayıları nasıl değişmektedir?
-- 19. Müşteriler en çok hangi saatlerde sipariş vermektedir?
-- 20. Sipariş yoğunluğu haftanın günlerine göre nasıl değişmektedir?
-- 21. Her şehirde en yüksek harcama yapan müşteriler kimlerdir?
-- 22. Aylık gelir ve bir önceki aya göre değişim oranı nedir?
-- 23. Gelirin zaman içerisindeki değişimi nasıldır? (Kümülatif gelir)
-- 24. Yıllara göre büyüme oranı nedir?


-- 1.1. Teslim edilmiş sipariş sayısı ve oranı

SELECT 
  COUNT(*) AS delivered_orders,
  CAST(100.0*COUNT(*)/(SELECT COUNT(*) FROM df_Orders) AS DECIMAL(18,2)) AS delivered_rate
FROM df_Orders
WHERE order_status='delivered';

-- 1.2. Teslim edilmemiş siparişlerin durum dağılımı

SELECT order_status,COUNT(*) AS order_count FROM df_Orders
WHERE order_status!='delivered'
GROUP BY order_status
ORDER BY order_count DESC;

-- 2.1. Tamamlanmış siparişler için toplam gelir

SELECT SUM(oi.price+oi.shipping_charges) AS revenue FROM df_OrderItems oi
JOIN df_Orders o ON o.order_id=oi.order_id
WHERE o.order_status='delivered';

-- 2.2. Ödemeye göre toplam gelir (onaylanmamış,iptal edilmiş,mevcut olmayan siparişler hariç)

SELECT SUM(p.payment_value) AS revenue FROM df_Payments p
JOIN df_Orders o ON o.order_id=p.order_id
WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL;

-- 3.1. Ortalama sipariş tutarı

SELECT ROUND(SUM(p.payment_value)/COUNT(p.order_id),2) AS avg_value FROM df_Payments p
JOIN df_Orders o ON o.order_id=p.order_id
WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL;

-- 3.2. Medyan sipariş tutarı

SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.payment_value) OVER() AS median_value
FROM df_Payments p
JOIN df_Orders o ON o.order_id=p.order_id
WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL;

-- 3.3. Ödeme yöntemine göre ortalama sipariş tutarı

SELECT p.payment_type,ROUND(SUM(p.payment_value)/COUNT(o.order_id),2) AS avg_value FROM df_Payments p
JOIN df_Orders o ON o.order_id=p.order_id
WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
GROUP BY p.payment_type
ORDER BY avg_value DESC;

-- 4.1. En çok sipariş veren ilk 5 şehir

SELECT TOP 5 c.customer_city,COUNT(*) AS order_count FROM df_Customers c
JOIN df_Orders o ON o.customer_id=c.customer_id
GROUP BY c.customer_city
ORDER BY order_count DESC;

-- 4.2. En az siparişe sahip şehirler

SELECT c.customer_city,COUNT(*) AS order_count FROM df_Customers c
JOIN df_Orders o ON o.customer_id=c.customer_id
GROUP BY c.customer_city
HAVING COUNT(*)<20;

-- 4.3. Şehirlerin yüzde kaçının sipariş sayısı 20'den az

WITH LowOrderCities AS(
    SELECT c.customer_city,COUNT(*) AS order_count FROM df_Customers c
    JOIN df_Orders o ON o.customer_id=c.customer_id
    GROUP BY c.customer_city
    HAVING COUNT(*)<20
)
SELECT
  CAST(100.0*COUNT(*)/(SELECT COUNT(DISTINCT customer_city) FROM df_Customers) AS DECIMAL(18,2)) AS city_rate
FROM LowOrderCities;

select distinct customer_city from df_Customers;

-- 5. Gelir tutarı en yüksek ilk 5 şehir

SELECT TOP 5 c.customer_city,SUM(p.payment_value) AS revenue FROM df_Customers c
JOIN df_Orders o ON o.customer_id=c.customer_id
JOIN df_Payments p ON p.order_id=o.order_id
WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
GROUP BY c.customer_city
ORDER BY revenue DESC;

-- 6. En çok satan ürün kategorileri (ilk 5)

SELECT TOP 5 dp.product_category_name,COUNT(*) AS order_count FROM DistinctProducts dp
JOIN df_OrderItems oi ON oi.product_id=dp.product_id
WHERE dp.product_category_name IS NOT NULL
GROUP BY dp.product_category_name
ORDER BY order_count DESC;

-- 7. Gelir tutarı en yüksek ürün kategorileri ve toplam gelirdeki payları (ilk 10)

WITH CategoryRevenue AS(
    SELECT dp.product_category_name,SUM(p.payment_value) AS revenue FROM DistinctProducts dp
    JOIN df_OrderItems oi ON oi.product_id=dp.product_id
    JOIN df_Orders o ON o.order_id=oi.order_id
    JOIN df_Payments p ON p.order_id=o.order_id
    WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
    GROUP BY dp.product_category_name
)
SELECT TOP 10 product_category_name,revenue,ROUND(100.0*revenue/SUM(revenue) OVER(),2) AS revenue_rate
FROM CategoryRevenue
ORDER BY revenue_rate DESC;

-- 8. Her kategoride en çok satan ilk 3 ürün (eşitlikler dahil)

WITH ProductRank AS(
    SELECT 
      dp.product_category_name,
      oi.product_id,
      COUNT(*) AS order_count,
      DENSE_RANK() OVER(PARTITION BY dp.product_category_name ORDER BY COUNT(*) DESC) AS product_rank
    FROM df_OrderItems oi
    JOIN DistinctProducts dp ON dp.product_id=oi.product_id
    WHERE dp.product_category_name IS NOT NULL
    GROUP BY dp.product_category_name,oi.product_id
)
SELECT * FROM ProductRank
WHERE product_rank<=3;

-- 9. En çok kullanılan ödeme yöntemi

SELECT
  p.payment_type,
  COUNT(*) AS order_count,
  CAST(100.0*COUNT(*)/SUM(COUNT(*)) OVER() AS DECIMAL(18,2)) AS order_rate
FROM df_Payments p
JOIN df_Orders o ON o.order_id=p.order_id
WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
GROUP BY p.payment_type
ORDER BY order_count DESC;

-- 10. Taksitli ödeme oranı

WITH Installments AS(
    SELECT p.payment_installments FROM df_Payments p
    JOIN df_Orders o ON o.order_id=p.order_id
    WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
)
SELECT
  COUNT(*) AS installment_order_count,
  CAST(100.0*COUNT(*)/(SELECT COUNT(*) FROM Installments) AS DECIMAL(18,2)) AS installment_order_rate
FROM Installments
WHERE payment_installments>1;

-- 11.1. Siparişlerin ortalama onay süresi

SELECT
  AVG(DATEDIFF(HOUR,order_purchase_timestamp,order_approved_at)) AS avg_approval_time
FROM df_Orders;

-- 11.2. Siparişlerin ortalama teslim süresi

SELECT
  AVG(DATEDIFF(DAY,order_purchase_timestamp,order_delivered_timestamp)) AS avg_delivery_time
FROM df_Orders;

-- 12.1. Geç teslim edilen sipariş oranı

SELECT
  COUNT(*) AS late_delivery_count,
  CAST(100.0*COUNT(*)/(SELECT COUNT(*) FROM df_Orders
                       WHERE order_delivered_timestamp IS NOT NULL) AS DECIMAL(18,2)) AS late_delivery_rate
FROM df_Orders
WHERE DATEDIFF(DAY,order_delivered_timestamp,order_estimated_delivery_date)<0;

-- 12.2. Aylık gecikme oranı

WITH MonthlyOrders AS(
    SELECT
      YEAR(order_purchase_timestamp) AS order_year,
      MONTH(order_purchase_timestamp) AS order_month,
      COUNT(*) AS order_count
    FROM df_Orders
    WHERE order_delivered_timestamp IS NOT NULL
    GROUP BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp)
),
LateOrders AS(
    SELECT
      YEAR(order_purchase_timestamp) AS order_year,
      MONTH(order_purchase_timestamp) AS order_month,
      COUNT(*) AS late_delivery_count
    FROM df_Orders
    WHERE DATEDIFF(DAY,order_delivered_timestamp,order_estimated_delivery_date)<0
    GROUP BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp)
)
SELECT
  m.order_year,
  m.order_month,
  ISNULL(l.late_delivery_count,0) AS late_delivery_count,
  CAST(100.0*ISNULL(l.late_delivery_count,0)/m.order_count AS DECIMAL(18,2)) AS late_delivery_rate
FROM MonthlyOrders m
LEFT JOIN LateOrders l ON l.order_year=m.order_year AND l.order_month=m.order_month
ORDER BY order_year,order_month;

-- 13. En yüksek geç teslim edilen sipariş sayısına sahip şehirler (ilk 5)

SELECT TOP 5 c.customer_city,COUNT(*) AS late_delivery_count FROM df_Orders o
JOIN df_Customers c ON c.customer_id=o.customer_id
WHERE DATEDIFF(DAY,o.order_delivered_timestamp,o.order_estimated_delivery_date)<0
GROUP BY c.customer_city
ORDER BY late_delivery_count DESC;

-- 14. Satıcı performansı (sipariş sayısı,ürün sayısı,gelir,geç teslim oranı,iptal sipariş oranı)

WITH Revenue AS(
    SELECT oi.seller_id,SUM(oi.price+oi.shipping_charges) AS revenue FROM df_OrderItems oi
    JOIN df_Orders o ON o.order_id=oi.order_id
    WHERE order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
    GROUP BY oi.seller_id
),
DeliveredOrders AS(
    SELECT oi.seller_id,COUNT(*) AS delivered_orders FROM df_OrderItems oi
    JOIN df_Orders o ON o.order_id=oi.order_id
    WHERE o.order_delivered_timestamp IS NOT NULL
    GROUP BY oi.seller_id
),
LateDelivery AS(
    SELECT
      oi.seller_id,
      CAST(100.0*COUNT(*)/do.delivered_orders AS DECIMAL(18,2)) AS late_delivery_rate
    FROM DeliveredOrders do
    JOIN df_OrderItems oi ON oi.seller_id=do.seller_id
    JOIN df_Orders o ON o.order_id=oi.order_id
    WHERE DATEDIFF(DAY,o.order_delivered_timestamp,o.order_estimated_delivery_date)<0
    GROUP BY oi.seller_id,do.delivered_orders
),
TotalOrders AS(
    SELECT seller_id,COUNT(*) AS total_order FROM df_OrderItems
    GROUP BY seller_id
),
Canceled AS(
    SELECT
      oi.seller_id,
      CAST(100.0*COUNT(*)/t.total_order AS DECIMAL(18,2)) AS canceled_rate
    FROM TotalOrders t
    JOIN df_OrderItems oi ON oi.seller_id=t.seller_id
    JOIN df_Orders o ON o.order_id=oi.order_id
    WHERE o.order_status='canceled'
    GROUP BY oi.seller_id,t.total_order
)
SELECT
  oi.seller_id,
  COUNT(*) AS order_count,
  COUNT(DISTINCT product_id) AS product_count,
  ISNULL(r.revenue,0) AS revenue,
  ISNULL(ld.late_delivery_rate,0) AS late_delivery_rate,
  ISNULL(c.canceled_rate,0) AS canceled_rate
FROM df_OrderItems oi
LEFT JOIN TotalOrders t ON t.seller_id=oi.seller_id
LEFT JOIN Revenue r ON r.seller_id=oi.seller_id
LEFT JOIN LateDelivery ld ON ld.seller_id=oi.seller_id
LEFT JOIN Canceled c ON c.seller_id=oi.seller_id
GROUP BY oi.seller_id,ld.late_delivery_rate,c.canceled_rate,r.revenue;

-- 15. En yüksek gelir elde eden ilk %20 satıcı toplam gelirin yüzde kaçını oluşturuyor

WITH Top20Sellers AS(
    SELECT TOP 20 PERCENT oi.seller_id,SUM(p.payment_value) AS revenue FROM df_Payments p
    JOIN df_Orders o ON o.order_id=p.order_id
    JOIN df_OrderItems oi ON oi.order_id=o.order_id
    WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
    GROUP BY oi.seller_id
    ORDER BY revenue DESC
),
TotalRevenue AS(
    SELECT SUM(p.payment_value) AS total_revenue FROM df_Payments p
    JOIN df_Orders o ON o.order_id=p.order_id
    WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
)
SELECT
  ROUND(100.0*SUM(revenue)/(SELECT total_revenue FROM TotalRevenue),2) AS revenue_rate
FROM Top20Sellers;

-- 16.1. Siparişlerin onaylanma sürelerine göre dağılımı

WITH ApprovalTimes AS(
    SELECT
      order_id,
      DATEDIFF(MINUTE,order_purchase_timestamp,order_approved_at) AS total_minutes
    FROM df_Orders
    WHERE order_approved_at IS NOT NULL
),
ApprovalTimeSegments AS(
    SELECT *,
      CASE WHEN total_minutes<60 THEN 'Fast(<1 hour)'
           WHEN total_minutes<1440 THEN 'Normal(1-24 hour)'
           ELSE 'Slow(>=1 day)'
      END AS approval_segment
    FROM ApprovalTimes
)
SELECT
  approval_segment,
  COUNT(*) AS order_count,
  CAST(100.0*COUNT(*)/SUM(COUNT(*)) OVER() AS DECIMAL(18,2)) AS order_rate
FROM ApprovalTimeSegments
GROUP BY approval_segment
ORDER BY order_rate DESC;

-- 16.2. Siparişlerin teslim sürelerine göre dağılımı

WITH DeliveryTimes AS(
    SELECT
      order_id,
      DATEDIFF(DAY,order_purchase_timestamp,order_delivered_timestamp) AS delivery_time
    FROM df_Orders
    WHERE order_delivered_timestamp IS NOT NULL
),
DeliveryTimeSegments AS(
    SELECT *,
      CASE WHEN delivery_time<7 THEN 'Fast(<1 week)'
           WHEN delivery_time<14 THEN 'Normal(1-2 week)'
           ELSE 'Slow(>=2 week)'
      END AS delivery_segment
    FROM DeliveryTimes
)
SELECT
  delivery_segment,
  COUNT(*) AS order_count,
  CAST(100.0*COUNT(*)/SUM(COUNT(*)) OVER() AS DECIMAL(18,2)) AS order_rate
FROM DeliveryTimeSegments
GROUP BY delivery_segment
ORDER BY order_rate DESC;

-- 17. Teslimatı 2 haftadan uzun süren siparişlerin incelenmesi

-- şehir bazında

SELECT TOP 5 c.customer_city,COUNT(*) AS long_delivery_count FROM df_Orders o
JOIN df_Customers c ON c.customer_id=o.customer_id
WHERE DATEDIFF(DAY,o.order_purchase_timestamp,o.order_delivered_timestamp)>14
GROUP BY c.customer_city
ORDER BY long_delivery_count DESC;

-- satıcı bazında

SELECT
  oi1.seller_id,
  COUNT(*) AS long_delivery_count,
  CAST(100.0*COUNT(*)/(SELECT COUNT(*) FROM df_OrderItems oi2
                        WHERE oi1.seller_id=oi2.seller_id) AS DECIMAL(18,2)) AS long_delivery_rate
FROM df_Orders o
JOIN df_OrderItems oi1 ON oi1.order_id=o.order_id
WHERE DATEDIFF(DAY,o.order_purchase_timestamp,o.order_delivered_timestamp)>14
GROUP BY oi1.seller_id
ORDER BY long_delivery_count DESC;

-- 18.1. Günlük sipariş sayısı

SELECT CAST(order_purchase_timestamp AS DATE) AS order_day,COUNT(*) AS order_count FROM df_Orders
GROUP BY CAST(order_purchase_timestamp AS DATE)
ORDER BY order_count DESC;

-- 18.2. Aylık sipariş sayısı

SELECT
  YEAR(order_purchase_timestamp) AS order_year,
  MONTH(order_purchase_timestamp) AS order_month,
  COUNT(*) AS order_count
FROM df_Orders
GROUP BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp)
ORDER BY order_year,order_month;

-- 19. En yoğun sipariş verilen saatler

SELECT DATEPART(HOUR,order_purchase_timestamp) AS order_hour,COUNT(*) AS order_count FROM df_Orders
GROUP BY DATEPART(HOUR,order_purchase_timestamp)
ORDER BY order_count DESC;

-- 20. En yoğun sipariş verilen günler

SELECT DATENAME(WEEKDAY,order_purchase_timestamp) AS order_day,COUNT(*) AS order_count FROM df_Orders
GROUP BY DATENAME(WEEKDAY,order_purchase_timestamp)
ORDER BY order_count DESC;

-- 21. Her şehirde en yüksek harcama yapan müşteriler (eşitlikler dahil)

WITH CustomerRank AS(
    SELECT
      c.customer_city,
      c.customer_id,
      SUM(p.payment_value) AS payment_value,
      DENSE_RANK() OVER(PARTITION BY c.customer_city ORDER BY SUM(p.payment_value) DESC) AS customer_rank
    FROM df_Customers c
    JOIN df_Orders o ON o.customer_id=c.customer_id
    JOIN df_Payments p ON p.order_id=o.order_id
    WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
    GROUP BY c.customer_city,c.customer_id
)
SELECT customer_city,customer_id,payment_value FROM CustomerRank
WHERE customer_rank=1;

-- 22. Aylık gelir ve bir önceki aya göre değişim oranı

DECLARE @StartDate1 DATE=(SELECT MIN(order_purchase_timestamp) FROM df_Orders);
DECLARE @EndDate1 DATE=(SELECT MAX(order_purchase_timestamp) FROM df_Orders);
WITH Months AS(
    SELECT @StartDate1 AS StartDate
    UNION ALL
    SELECT DATEADD(MONTH,1,StartDate) FROM Months
    WHERE StartDate<@EndDate1
),
MonthlyRevenue AS(
    SELECT
      YEAR(o.order_purchase_timestamp) AS order_year,
      MONTH(o.order_purchase_timestamp) AS order_month,
      SUM(p.payment_value) AS revenue
    FROM df_Orders o
    JOIN df_Payments p ON p.order_id=o.order_id
    WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
    GROUP BY YEAR(o.order_purchase_timestamp),MONTH(O.order_purchase_timestamp)
),
PreviousRevunue AS(
    SELECT
      YEAR(m.StartDate) AS order_year,
      MONTH(m.StartDate) AS order_month,
      ISNULL(mr.revenue,0) AS monthly_revenue,
      LAG(ISNULL(mr.revenue,0)) OVER (ORDER BY YEAR(m.StartDate),MONTH(m.StartDate)) AS previous_month_revenue
    FROM Months m
    LEFT JOIN MonthlyRevenue mr ON mr.order_year=YEAR(m.StartDate) AND mr.order_month=MONTH(m.StartDate)
)
SELECT
  order_year,
  order_month,
  monthly_revenue,
  previous_month_revenue,
  monthly_revenue - previous_month_revenue AS revenue_change,
  ROUND(100.0*(monthly_revenue - previous_month_revenue)/NULLIF(previous_month_revenue,0),2) AS revenue_change_rate
FROM PreviousRevunue;

-- 23. Kümülatif gelir

DECLARE @StartDate2 DATE=(SELECT MIN(order_purchase_timestamp) FROM df_Orders);
DECLARE @EndDate2 DATE=(SELECT MAX(order_purchase_timestamp) FROM df_Orders);
WITH Months AS(
    SELECT @StartDate2 AS StartDate
    UNION ALL
    SELECT DATEADD(MONTH,1,StartDate) FROM Months
    WHERE StartDate<@EndDate2
),
MonthlyRevenue AS(
    SELECT
      YEAR(o.order_purchase_timestamp) AS order_year,
      MONTH(o.order_purchase_timestamp) AS order_month,
      SUM(p.payment_value) AS monthly_revenue
    FROM df_Orders o
    JOIN df_Payments p ON p.order_id=o.order_id
    WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
    GROUP BY YEAR(o.order_purchase_timestamp),MONTH(o.order_purchase_timestamp)
)
SELECT
  YEAR(m.StartDate) AS order_year,
  MONTH(m.StartDate) AS order_month,
  ISNULL(mr.monthly_revenue,0) AS monthly_revenue,
  SUM(ISNULL(mr.monthly_revenue,0)) OVER (ORDER BY YEAR(m.StartDate),MONTH(m.StartDate)) AS cumulative_revenue
FROM Months m
LEFT JOIN MonthlyRevenue mr ON mr.order_year=YEAR(m.StartDate) AND mr.order_month=MONTH(m.StartDate);

-- 24. Yıllara göre büyüme oranı

WITH YearlyRevenue AS(
    SELECT YEAR(order_purchase_timestamp) AS order_year,SUM(p.payment_value) AS yearly_revenue
    FROM df_Orders o
    JOIN df_Payments p ON p.order_id=o.order_id
    WHERE o.order_status NOT IN ('canceled','unavailable') AND o.order_approved_at IS NOT NULL
    GROUP BY YEAR(order_purchase_timestamp)
),
PreviousYearRevenue AS(
    SELECT order_year,yearly_revenue,LAG(yearly_revenue) OVER (ORDER BY order_year) AS previous_year_revenue
    FROM YearlyRevenue
)
SELECT
  order_year,
  yearly_revenue,
  previous_year_revenue,
  yearly_revenue - previous_year_revenue AS revenue_change,
  ROUND(100.0*(yearly_revenue - previous_year_revenue)/previous_year_revenue,2) AS revenue_change_rate
FROM PreviousYearRevenue
ORDER BY order_year;
