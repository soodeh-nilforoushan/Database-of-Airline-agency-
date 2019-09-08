select timeRegistered,firstname,LastName
from registered_customer , customer
where customer.customerid= registered_customer.customerid