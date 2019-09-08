
select ct_id,verificationStatusTime from 
verificationemployeebycommunicationteam
where verificationStatus=1 and 
timestampdiff(DAY,verificationStatusTime,NOW()) <30;
