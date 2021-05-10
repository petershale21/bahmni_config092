select sm.name as Product_Description,pu.name as Pack_Size, count(pu.name) as Total_Pack_dispensed, (pu.factor*count(pu.name)) as Total_Number_of_Tablets_Dispensed
from stock_move sm
LEFT OUTER JOIN sale_order_line so ON sm.product_id = so.product_id
LEFT OUTER JOIN product_uom pu ON so.product_uom = pu.id
WHERE so.state = 'sale'
group by sm.name,pu.name,pu.factor;
