SELECT DISTINCT display_name "Patient Name",sol.product_id Product,sol.name Description,CAST(po.product_qty AS INTEGER)"Qty Ordered",CAST(qty_delivered AS INTEGER) "Qty Delivered",lot_name "Batch NO",
spo.expiry_date "Expiry Date",pu.name "Unit of Measure"
FROM res_partner rp
LEFT OUTER JOIN procurement_order po ON partner_dest_id = rp.id
LEFT OUTER JOIN  sale_order_line sol ON sale_line_id = sol.id
LEFT OUTER JOIN  stock_pack_operation sp ON sol.product_id = sp.product_id
LEFT OUTER JOIN  stock_pack_operation_lot spo ON sp.id = spo.operation_id
LEFT OUTER JOIN  product_uom pu ON sol.product_uom = pu.id
WHERE sol.state = 'sale'

