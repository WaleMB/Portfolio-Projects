-- Creating a Script from BikeStores Database with joins

select o.order_id, concat(c.first_name,'',c.last_name) as name, c.city, c.state, o.order_date,
sum(oi.quantity) as total_units,
sum(oi.quantity * oi.list_price) as revenue,
pd.product_name,
ct.category_name,
st.store_name,
concat(stf.first_name,'',stf.last_name) as sales_rep
from orders o
join customers c
on o.customer_id = c.customer_id
join order_items oi
on o.order_id= oi.order_id
join production.products pd
on oi.product_id=pd.product_id
join production.categories ct
on pd.category_id=ct.category_id
join stores st
on o.store_id=st.store_id
join staffs stf
on o.staff_id=stf.staff_id
group by o.order_id, concat(c.first_name,'',c.last_name), c.city, c.state, 
o.order_date, pd.product_name, ct.category_name, st.store_name, concat(stf.first_name,'',stf.last_name);
