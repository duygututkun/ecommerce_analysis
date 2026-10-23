-- NULL VE DUPLICATE(YİNELENEN) DEĞERLERİ BULMA

-- 1.Customers Tablosunda Null ve Duplicate Değerler

SELECT 'customer_id' AS column_name,COUNT(*) AS null_count FROM df_Customers
WHERE customer_id IS NULL
UNION ALL
SELECT 'customer_city',COUNT(*) FROM df_Customers
WHERE customer_city IS NULL
UNION ALL
SELECT 'customer_state',COUNT(*) FROM df_Customers
WHERE customer_state IS NULL;

SELECT customer_id,COUNT(*) AS duplicate_count FROM df_Customers
GROUP BY customer_id
HAVING COUNT(*)>1;

--Customers tablosunda kritik alanlarda null ve duplicate değer yok

-- 2.OrderItems Tablosunda Null ve Duplicate Değerler

SELECT 'order_id' AS column_name,COUNT(*) AS null_count FROM df_OrderItems
WHERE order_id IS NULL
UNION ALL
SELECT 'product_id',COUNT(*) FROM df_OrderItems
WHERE product_id IS NULL
UNION ALL
SELECT 'seller_id',COUNT(*) FROM df_OrderItems
WHERE seller_id IS NULL
UNION ALL
SELECT 'price',COUNT(*) FROM df_OrderItems
WHERE price IS NULL
UNION ALL
SELECT 'shipping_charges',COUNT(*) FROM df_OrderItems
WHERE shipping_charges IS NULL;

SELECT order_id,COUNT(*) AS duplicate_count FROM df_OrderItems
GROUP BY order_id
HAVING COUNT(*)>1;

--OrderItems tablosunda null ve duplicate değer yok

-- 3.Orders Tablosunda Null ve Duplicate Değerler

SELECT 'order_id' AS column_name,COUNT(*) AS null_count FROM df_Orders
WHERE order_id IS NULL
UNION ALL
SELECT 'customer_id',COUNT(*) FROM df_Orders
WHERE customer_id IS NULL
UNION ALL
SELECT 'order_status',COUNT(*) FROM df_Orders
WHERE order_status IS NULL
UNION ALL
SELECT 'order_purchase_timestamp',COUNT(*) FROM df_Orders
WHERE order_purchase_timestamp IS NULL
UNION ALL
SELECT 'order_approved_at',COUNT(*) FROM df_Orders
WHERE order_approved_at IS NULL
UNION ALL
SELECT 'order_delivered_timestamp',COUNT(*) FROM df_Orders
WHERE order_delivered_timestamp IS NULL
UNION ALL
SELECT 'order_estimated_delivery_date',COUNT(*) FROM df_Orders
WHERE order_estimated_delivery_date IS NULL;

SELECT order_id,COUNT(*) AS duplicate_count FROM df_Orders
GROUP BY order_id
HAVING COUNT(*)>1;

--order_approved_at: 9 NULL değer var
--order_delivered_timestamp: 1889 NULL değer var
--Orders tablosunda duplicate değer yok

-- 4.Payments Tablosunda Null ve Duplicate Değerler

SELECT 'order_id' AS column_name,COUNT(*) AS null_count FROM df_Payments
WHERE order_id IS NULL
UNION ALL
SELECT 'payment_sequential',COUNT(*) FROM df_Payments
WHERE payment_sequential IS NULL
UNION ALL
SELECT 'payment_type',COUNT(*) FROM df_Payments
WHERE payment_type IS NULL
UNION ALL
SELECT 'payment_installments',COUNT(*) FROM df_Payments
WHERE payment_installments IS NULL
UNION ALL
SELECT 'payment_value',COUNT(*) FROM df_Payments
WHERE payment_value IS NULL;

SELECT order_id,COUNT(*) AS duplicate_count FROM df_Payments
GROUP BY order_id
HAVING COUNT(*)>1;

--Payments tablosunda null ve duplicate değer yok

-- 5.Products Tablosunda Null ve Duplicate Değerler

SELECT 'product_id' AS column_name,COUNT(*) AS null_count FROM df_Products
WHERE product_id IS NULL
UNION ALL
SELECT 'product_category_name',COUNT(*) FROM df_Products
WHERE product_category_name IS NULL
UNION ALL
SELECT 'product_weight_g',COUNT(*) FROM df_Products
WHERE product_weight_g IS NULL;

SELECT product_id,COUNT(*) AS duplicate_count FROM df_Products
GROUP BY product_id
HAVING COUNT(*)>1;

--product_category_name: 308 NULL değer var
--product_weight_g: 15 NULL değer var
--Products tablosunda product_id unique(benzersiz) değil

-- Products tablosunda yinelenen product_id kayıtları tutarsız ürün tanımlarını mı temsil ediyor?

SELECT product_id FROM df_Products
GROUP BY product_id
HAVING COUNT(DISTINCT product_category_name)>1 OR COUNT(DISTINCT product_weight_g)>1
  OR COUNT(DISTINCT product_length_cm)>1 OR COUNT(DISTINCT product_height_cm)>1
  OR COUNT(DISTINCT product_width_cm)>1;

--Tüm duplicate(yinelenen) kayıtlar ürün özellikleri açısından tamamen tutarlı

SELECT DISTINCT product_id,product_category_name,product_weight_g,product_length_cm,
       product_height_cm,product_width_cm
INTO DistinctProducts FROM df_Products;
