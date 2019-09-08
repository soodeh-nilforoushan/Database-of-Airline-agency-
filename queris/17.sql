select customer.firstname,customer.lastname,customer.customerid,timeRegistered
from registered_customer,customer where
customer.customerid=registered_customer.customerid  and
 timestampdiff(DAY,timeRegistered,NOW()) <30;
