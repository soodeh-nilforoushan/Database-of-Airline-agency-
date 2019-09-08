#in the name of God
#query number 2
insert into customer values(1,"sara","seyedi",0012,"ali","shiraz","2011-12-11 11:11:11",1234,99988);
insert into customer values(2,"saba","kaseb",0022,"korosh","tehran","2011-10-11 01:11:11",0234,99488);
insert into customer values(3,"arsalan","kaseb",0032,"omid","shiraz","2011-10-11 01:11:11",0134,99288);

insert into company values(12,"parsian",null,13,null,45,null);
insert into company values(13,"parsian",null,16,null,95,null);
insert into company values(14,"sepand",null,17,null,65,null);

insert into employee values(12,76,1);
insert into employee values(13,87,2);
insert into employee values(14,87,3);



select customer.customerid,firstname,lastname
from employee join customer join company
where company.comapanyname="parsian" and customer.customerid=employee.customerid and company.enrollmentnum=employee.enrollmentnum;

#quer number 4
insert into airlinecompany values(21,"taban","2011-12-12 11:10:12","pasdaran",87654,"abas","rasti","shariati");
insert into airlinecompany values(98,"zagros","2001-10-12 11:10:12","pasdaran",87914,"abas","saghai","valiasr");
insert into airlinecompany values(45,"iranair","2001-10-12 11:10:12","jordan",87354,"nader","ghasemi","jordan");

insert into airplane values("airbus",400);

insert into trip values(44,"sari","tehran","business","airbus","mardani",21,null,null,null,null,null);
insert into trip values(75,"tehran","shiraz","business","airbus","kazemi",98,null,null,null,null,null);
insert into trip values(36,"tehran","sari","business","airbus","mardani",21,null,null,null,null,null);

insert into chartertrip values(78,44,"12:59", "14:08","1:00","3:00");
insert into chartertrip values(28,36,"13:59", "14:48","2:00","3:00");
insert into chartertrip values(34,75,"13:10", "14:58","1:00","3:00");

select charterid,chartertrip.tripid , goingtime , backingtime ,goinglenghttime , backinglenghttime
from chartertrip join trip join airlinecompany
where airlinecompany.ALid=21 and chartertrip.tripid=trip.tripid and trip.origin="sari" and trip.destination="tehran" and (chartertrip.goingtime >"12:00" and chartertrip.backingtime<"15:00")
union 
select charterid,chartertrip.tripid ,goingtime ,backingtime ,goinglenghttime , backinglenghttime
from chartertrip join trip join airlinecompany
where airlinecompany.ALid=21 and chartertrip.tripid=trip.tripid and trip.origin="tehran" and trip.destination="sari" and (chartertrip.goingtime >"12:00" and chartertrip.backingtime<"15:00");

#quert number 6
insert into airplane values("topolof",200);

insert into airlinecompany values(43,"zagors","2001-12-11 11:10:12","dolat",87154,"mohamad","rasti","shariati");
insert into airlinecompany values(47,"kishair","2003-02-11 01:10:12","zafaraniye",097154,"mahdiyar","asadi","kave");

insert into trip values(124,"kerman","esfahan","economy","topolof","sardari",200,43,"2:00",null,null,null);
insert into trip values(125,"esfahan","kerman","economy","topolof","ghsemi",230,47,"3:00",null,null,null);
insert into trip values(126,"save","esfahan","economy","topolof","abedi",200,43,"2:00",null,null,null);


insert into onewaytrip values(11,124,"2011-12-10 11:03:00","3:00");
insert into onewaytrip values (12,125,"2010-11-10 11:07:00","2:00");
insert into onewaytrip values (13,126,"2009-11-10 10:07:00","1:00");

insert into specialist values(68,"sare","atai",3849,79878,"aghdasiye");
insert into specialist values(70,"mahan","tabatabayi",9658,92798,"pasdaran");

insert into verificationtripbyspecialist values("accepted",68,124);
insert into verificationtripbyspecialist values("accepted",70,125);

insert into ticket values(68,124,23);
insert into ticket values(70,125,24);

insert into customer values(70,"ali","nazer",776,"akbar","tehran","2011-11-09 12:12:12",49,9898);

insert into buy values(70,23,"2010-10-09 16:16",888,23);
insert into buy values(70,24,"2011-10-09 16:26",688,24);




select distinct triptime,airLineName,trip.airplanename,pilotname
from  airlinecompany join trip join onewaytrip join ticket join buy join customer
where buy.ticketId=ticket.ticketid and buy.customerid=customer.customerid and trip.tripid=ticket.tripid and trip.tripid=onewaytrip.tripid and trip.ALid=airlinecompany.ALid 
and trip.origin="esfahan" and trip.destination="kerman" and customer.customerid=70
union
select distinct triptime,airLineName,trip.airplanename,pilotname
from  airlinecompany join trip join onewaytrip join ticket join buy join customer
where buy.ticketId=ticket.ticketid and buy.customerid=customer.customerid and trip.tripid=ticket.tripid and trip.tripid=onewaytrip.tripid and trip.ALid=airlinecompany.ALid 
and trip.origin="kerman" and trip.destination="esfahan" and customer.customerid=70
;
#query 8

insert into supportteam values(44,"zahra","karimi","1","2002-11-11 12:13:14");

insert into onlineanswer values(133,2,"2011-09-09 02:02:02","2011-09-09 11:02:02",44,"how is this working");
insert into onlineanswer values(145,2,"2011-09-09 02:02:02","2011-09-09 12:02:02",44, "I have a question");

select onlineanswer.stid,onlineanswer.answerid,onlineanswer.subjectComplaint,onlineanswer.answertime
from onlineanswer join customer
where customer.customerid=2 and onlineanswer.stid=44;








#query 10
insert into trip values (146,"kish","shiraz","business","airbus","hoseini",123.23,43,"2:00",300,null,null);
insert into trip values (147,"kish","mashhad","business","airbus","mardani",103,43,"2:00",300,null,null);

insert into specialist values(72,"maryam","abasi",38412,7778878,"aghdasiye");
insert into specialist values(74,"mahan","asghari",961258,9273498,"shariati");

insert into verificationtripbyspecialist values("accepted",72,146);
insert into verificationtripbyspecialist values("accepted",74,147);

insert into ticket values(72,146,113);
insert into ticket values(74,147,119);

insert into customer values(88,"meli","sedighi",678,"ali","tehran","2000-10-10 11:11",567,87678);
insert into buy values(88,777,"2011-03-04 07:12",999,113);
insert into buy values(88,555,"2012-03-04 07:12",898,119);

insert into registered_customer values(89,678,88,"sadegh","2000-11-02","ahvaz",567,"2009-10-12 12:34","account");
insert into registered_customer values(90,456,88,"nader","2010-11-02","kerman",565,"2001-02-11 12:37","online");



select trip.tripid,registered_customer.customerid
from registered_customer join buy join ticket join trip 
where registered_customer.customerid=buy.customerid and registered_customer.customerid=88 and buy.ticketid=ticket.ticketid and ticket.tripid=trip.tripid and registered_customer.paidway="account";

#query 12
insert into airlinecompany values(55,"mahan",null,null,null,null,null,null);

insert into trip values(102,"yazd","ahvaz","business","airbus","asghari",160,55,"2:00",null,null,null);
insert into trip values(103,"yazd","ghazvin","business","airbus","abasahl",160,55,"2:00",null,null,null);

insert into specialist values(60,"maryam","kavosi",38411,7978878,"aghdasiye");
insert into specialist values(62,"mahan","saberi",961158,4273498,"shariati");

insert into verificationtripbyspecialist values("accepted",60,102);
insert into verificationtripbyspecialist values("accepted",62,103);

insert into ticket values(60,102,242);
insert into ticket values(62,103,323);

insert into buy values(88,744,"2001-11-02 23:12",87899,242);
insert into buy values(88,877,"2001-11-01 23:12",87599,323);

#insert into buy values(90,933,"2002-12-08  21:11",868698,323);

select buy.ticketid,trip.class
from buy join ticket join trip join airlinecompany
where buy.ticketId=ticket.ticketid and ticket.tripid=trip.tripid and trip.ALid=airlinecompany.ALid and airlinecompany.airlinename="mahan";

#query 14


select *
from deleted_airlines 
where modifieddate> "2018-01-01";

#query 16
insert into supportteam values(1,"zahra","sadeghi",1,"2012-10-10 11:11:15");
insert into supportteam values(3,"mohammad","sadeghi",1,"2012-10-10 11:12:15");

insert into onlineanswer values(2,0,"2011-11-10 11:11:11","2011-11-10 12:12:12", 1,"how is this working");
insert into onlineanswer values(3,11,"2012-10-10 10:10:10","2012-10-10 11:11:11", 3,"help me");

select answerid,supportteam.stid,supportteam.firstname,customerid,answertime,subjectComplaint 
from onlineanswer join supportteam
where onlineanswer.stid=supportteam.stid; 


insert into supportteam values (5,"ramin","khakbaz",1,"2013-11-12 11:11:11");
insert into supportteam values(7,"kiarash","godarzi",1,"2013-12-12 10:10:10");

insert into complaint values(1,5,"issue with buying",1,"2013-11-12 13:10:10","2013-11-12 14:10:10");
insert into complaint values(2,7,"technical problem",2,"2013-12-12 14:10:10","2013-12-12 15:10:10");

select complaintid,supportteam.stid,supportteam.firstname,customerid,complaint.answertime
from complaint join supportteam
where complaint.stid=supportteam.stid;

#query 18
insert into unregistered_customer values(12,1,889);

insert into trip values(130,"mashhad","kashan","business","airbus","sami",221,43,"3:00",200,null,null);
insert into trip values(132,"ramsar","tehran","economy","airbus","shamlo",112,47,"2:00",200,null,null);

insert into verificationtripbyspecialist values("accepted",68,130);
insert into verificationtripbyspecialist values("accepted",70,132);

insert into ticket values(68,130,144);
insert into ticket values(70,132,146);

insert into buy values(1,99,"2001-12-12 11:11:11",1287,144);
insert into buy values(1,100,"2002-11-11 13:13:13",1000,146);

select trip.tripid,trip.origin,trip.destination,trip.class,trip.hourflight
from customer join unregistered_customer join buy join ticket join trip
where unregistered_customer.customerid=1 and customer.customerid=unregistered_customer.customerid and buy.ticketId=ticket.ticketid and ticket.tripid=trip.tripid;


