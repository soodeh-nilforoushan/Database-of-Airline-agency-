select distinct trip.tripid,count(*)
from customer,buy,ticket, airlinecompany,trip
where trip.tripid=ticket.tripid and airlinecompany.ALid=trip.ALid and buy.ticketid=ticket.ticketid and customer.customerid=buy.customerid
group by trip.tripid
having count(*)=2;