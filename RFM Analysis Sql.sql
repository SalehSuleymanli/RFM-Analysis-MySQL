create view DATATABLE as(
select transaction_id, customerid,transaction_date,SUM(quantity*avg_price)over(partition
by customerid) as monetary from rfm
where customerid is not null and transaction_date is not null and transaction_id is not
null)
create view RFM1 as(
select distinct customerid,DATEDIFF(d,max(transaction_date)over(partition by
customerid),getdate()) as RECENCY,MONETARY,
COUNT(transaction_id)over(partition by customerid) as FREQUENCY from datatable)
create view RFMSCORE AS(
select customerid,recency,monetary,frequency,
ntile(4)over(order by monetary desc) as "monetaryscore",
ntile(4)over(order by recency asc) as "recencyscore",
ntile(4)over(order by frequency desc )as "frequencyscore" from rfm1)
select* into rfmscoretable from rfmscore
DROP VIEW IF EXISTS rfmscore;
DROP VIEW IF EXISTS rfmtable;
DROP VIEW IF EXISTS rfm1;

select* from rfmscoretable
--at risk
select*from rfmscoretable where monetaryscore =4 and recencyscore =4 and 
frequencyscore=4
order by monetaryscore,recencyscore,frequencyscore
--New customers
select*from rfmscoretable where monetaryscore =3 and recencyscore =3 and 
frequencyscore=1
order by monetaryscore,recencyscore,frequencyscore
--best customers
select*from rfmscoretable where monetaryscore =1 and recencyscore =1 and 
frequencyscore =1
order by monetaryscore,recencyscore,frequencyscore
--highest spending
select*from rfmscoretable where monetaryscore in(1,2) and recencyscore in(1) and 
frequencyscore in(4)
order by monetaryscore,recencyscore,frequencyscore
--lowest spending
select*from rfmscoretable where monetaryscore in(3,4) and recencyscore in(1) and 
frequencyscore in(1)
order by monetaryscore,recencyscore,frequencyscore
--churned best customers
select*from rfmscoretable where monetaryscore in(1,2) and recencyscore in(4) and 
frequencyscore in (1,2)
order by monetaryscore,recencyscore,frequencyscore



;

select customerid,recency,monetary,frequency,monetaryscore,recencyscore,frequencyscore 
,(case when 
monetaryscore in(1,2)  and recencyscore=1 and frequencyscore=4 then 'high spending new customers'

when monetaryscore in(3,4)  and recencyscore=1 and frequencyscore=1 then 'lowest spending new customers'

when monetaryscore in(1,2)  and recencyscore=4 and frequencyscore in (1,2) then 'churned best  customers'

when monetaryscore =1  and recencyscore=1 and frequencyscore =1 then ' best  customers' 
else 'standart customers'
end) as Category

from rfmscoretable order by category

