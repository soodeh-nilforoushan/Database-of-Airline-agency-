select sum(price) as selledTicket 
from trip,ticket,buy
where trip.tripid= ticket.tripid and buy.ticketId=ticket.ticketid 
