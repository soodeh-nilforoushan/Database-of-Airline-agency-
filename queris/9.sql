select  comapanyname  ,price
from buy,customer,employee,trip,ticket,company
where buy.customerid=customer.customerid and employee.customerid=customer.customerid and employee.enrollmentnum=company.enrollmentnum
and trip.tripid=ticket.tripid and
timestampdiff(DAY,buy.buytime,NOW()) <20;
