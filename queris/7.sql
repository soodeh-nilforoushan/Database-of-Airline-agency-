select sum(price*0.09) as 'sum of tax'
from trip, buy ,customer,ticket
 where trip.tripid= ticket.tripid  and
 customer.customerid= buy.customerid 
and buy.ticketId=ticket.ticketid
