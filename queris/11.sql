select stid ,firstname,lastname from supportteam
where onOroff=1
and timestampdiff(DAY,lastOnline,NOW()) < 30;
