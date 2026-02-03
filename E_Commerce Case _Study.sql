create database ECommerce;
use ECommerce;

select * from Customers;
select * from orderdetails;
select * from orders;
select * from products;

-- Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

select location, count(customer_id) as number_of_customers
from customers
group by location
order by number_of_customers desc
limit 3;

-- Determine the distribution of customers by the number of orders placed. This insight will help in segmenting customers into one-time buyers,
--  occasional shoppers, and regular customers for tailored marketing strategies.
SELECT
  Number_of_Orders,
  COUNT(Customer_ID) AS Number_of_Customers
FROM (
  SELECT
    Customer_ID,
    COUNT(Order_ID) AS Number_of_Orders
  FROM
    Orders
  GROUP BY
    Customer_ID
) AS Customer_Order_Counts
GROUP BY
  Number_of_Orders
ORDER BY
  Number_of_Orders ASC;

-- Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
-- Hint: Return the result table which includes average quantity and the total revenue in descending order.

select product_id, avg(quantity) avg_pur_quan, sum(quantity * price_per_unit) as total_revenue
from orderdetails
group by product_id
having avg(quantity) = 2
order by avg_pur_quan desc, total_revenue desc;

-- For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.
-- Hints : Use the “Products”, “OrderDetails” and “Orders” table.
-- Return the result table which will help you count the unique number of customers in descending order.

select p.category, count(distinct o.customer_id) as unique_customers
from products as p
join orderdetails as od on p.product_id = od.product_id
join orders as o on od.order_id = o.order_id
group by p.category
order by unique_customers desc;

-- Analyze the month-on-month percentage change in total sales to identify growth trends.
-- Hint: Use the “Orders” table.
-- Return the result table which will help you get the month (YYYY-MM), Total Sales and Percent Change of the total amount (Present month value- Previous month value/ Previous month value)*100.
-- The resulting change in percentage should be rounded to 2 decimal places.

with month_sales as
(select date_format(order_date, '%Y-%m') as yearmonth, sum(total_amount) as total_sales
from orders
group by date_format(order_date, '%Y-%m')
order by yearmonth
)
select *,
round(((total_sales - lag(total_sales) over(order by yearmonth)) / lag(total_sales) over(order by yearmonth)) * 100, 2) as percentage_change
from month_sales;

-- Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.
-- Hint: Use the “Orders” Table. 
-- Return the result table which will help you get the month (YYYY-MM), Average order value and Change in the average order value (Present month value- Previous month value).
-- Both the resulting AvgOrderValue and ChangeInValue column should be rounded to two decimal places, with the final results ordered in descending order by ChangeInValue.

with avg_month_order as
( select date_format(order_date, '%Y-%m') as month, round(avg(total_amount),2) as AvgOrderValue
from orders
group by date_format(order_date, '%Y-%m') 
order by month
)
select *, (AvgOrderValue - lag(AvgOrderValue) over(order by month)) as ChangeInValue
from avg_month_order
order by ChangeInValue desc;

-- Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
-- Hint: Use the “OrderDetails” table.
-- Return the result table limited to top 5 product according to the SalesFrequency column in descending order.

select product_id, count(*) as salesFrequency
from orderdetails
group by product_id
order by salesFrequency desc limit 5;

-- List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
-- Hint: Use the “Products”, “Orders”, “OrderDetails” and “Customers” table.
-- Return the result table which will help you get the product names along with the count of unique customers who belong to the lower 40% of the customer pool.

select p.product_id, p.name, count(distinct c.customer_id) as UniqueCustomerCount
from products as p 
join orderdetails as od on p.product_id = od.product_id
join orders as o on od.order_id = o.order_id
join customers as c on o.customer_id = c.customer_id
group by p.product_id, p.name
having UniqueCustomerCount < 40;

-- Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
-- Hint: Use the “Orders” table.
-- Return the result table which will help you get the count of the number of customers who made the first purchase on monthly basis.
-- The resulting table should be ascendingly ordered according to the month.

WITH CustomerFirstPurchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM
        Orders
    GROUP BY
        customer_id
),
MonthlyNewCustomers AS (
    SELECT
        date_format(first_purchase_date, '%Y-%m') AS purchase_month,
        COUNT(customer_id) AS new_customers
    FROM
        CustomerFirstPurchase
    GROUP BY
        purchase_month
)
SELECT *
FROM
    MonthlyNewCustomers
ORDER BY
    purchase_month ASC;


-- Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.
-- Hint: Use the “Orders” table.
-- Return the result table which will help you get the month (YYYY-MM) and the Total sales made by the company limiting to top 3 months.
-- The resulting table should be in descending order suggesting the highest sales month.

select date_format(order_date, '%Y-%m') as month, sum(total_amount) as totalsales
from orders
group by date_format(order_date, '%Y-%m')
order by totalsales desc
limit 3;




WITH CustomerFirstPurchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM
        Orders
    GROUP BY
        customer_id
),
MonthlyNewCustomers AS (
    SELECT
        date_format(first_purchase_date, '%Y-%m') AS purchase_month,
        COUNT(customer_id) AS new_customers
    FROM
        CustomerFirstPurchase
    GROUP BY
        purchase_month
)
SELECT *
FROM
    MonthlyNewCustomers
ORDER BY
    purchase_month ASC;



