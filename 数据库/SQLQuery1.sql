--����
create nonclustered index flight_index on flight(date);
exec sp_helpindex flight;

create nonclustered index ticket_index on flight(date);
exec sp_helpindex ticket;



--��ͼ1��������ʾ��Ӧ�����Ѷ�Ʊ���������
if exists(select * from sysobjects where name = 'soldOutFirstSeatAmount' and type = 'v')
drop view soldOutFirstSeatAmount
go
create view soldOutFirstSeatAmount
  as
  select airnum,date,count(class_level) �������
  from ticket 
  where class_level = '�����' 
  group by airnum,date
go
--����
select * from soldOutFirstSeatAmount

--��ͼ2��������ʾ ��Ӧ�����Ѷ�Ʊ�ľ��ò���
if exists(select * from sysobjects where name = 'soldOutSecondSeatAmount' and type = 'v')
drop view soldOutSecondSeatAmount
go
create view soldOutSecondSeatAmount
  as
  select airnum,date,count(class_level) ���ò���
  from ticket
  where class_level = '���ò�'
  group by airnum,date
go
--����
select * from soldOutSecondSeatAmount

--��ͼ3��������ʾ������ĸ���λ�Ķ���
if exists(select * from sysobjects where name = 'amountOfSeat' and type = 'v')
drop view amountOfSeat
go
create view amountOfSeat
  as
  select airnum,date,first_class_seat,second_calss_seat
  from flight,airplane
  where flight.planenum = airplane.planenum
go
--����
select * from amountOfSeat

--��ͼ4��������ʾ���������λ����Ʊ��
if exists(select * from sysobjects where name = 'tickets_left' and type = 'v')
drop view tickets_left
go
create view tickets_left
  as
  select amountOfSeat.airnum,amountOfSeat.date,
        (amountOfSeat.first_class_seat-isnull(soldOutFirstSeatAmount.�������,0)) �������Ʊ,
		(amountOfSeat.second_calss_seat-isnull(soldOutSecondSeatAmount.���ò���,0)) ���ò���Ʊ
  from (soldOutFirstSeatAmount right join amountOfSeat on soldOutFirstSeatAmount.airnum
       = amountOfSeat.airnum and soldOutFirstSeatAmount.date = amountOfSeat.date) left join 
	   soldOutSecondSeatAmount on amountOfSeat.airnum = soldOutSecondSeatAmount.airnum and
	   amountOfSeat.date = soldOutSecondSeatAmount.date
go
--����
select * from tickets_left

--��ͼ5��������ʾϵͳ��ѯ��������Ҫ�ĺ�����Ϣ
if exists(select * from sysobjects where name = 'flightInformation' and type = 'v')
drop view flightInformation
go
create view flightInformation
  as
  select f.airnum,f.start_station,f.end_station,f.date,f.start_time,f.end_time,plane_model,
  �������Ʊ,���ò���Ʊ,price*3.00 ����ռ۸�,price*1.00 ���òռ۸�,comp_name
  from flight f,tickets_left tl,airplane ap
  where f.airnum = tl.airnum and f.date = tl.date and f.planenum = ap.planenum
go
--����
select * from flightInformation

--��ͼ6��������ʾ������Ϣ
if exists(select * from sysobjects where name = 'orderInformation' and type = 'v')
drop view orderInformation
go
create view orderInformation
  as
  select orderform.ordernum,start_station,end_station,ticket.date,orderform.orderDate,count(*) ��������,
  total_money,ticket_status,start_time,username
  from (flight right join ticket on ticket.airnum = flight.airnum 
  and ticket.date = flight.date) right join orderform on ticket.ordernum = orderform.ordernum
  group by orderform.ordernum,start_station,end_station,ticket.date,orderform.orderDate,total_money,ticket_status,start_time,username
go
--����
select * from orderInformation where username = '18725087325'

update ticket set ticket_status = 0 where ticketnum = '070410003'
select seatnum from ticket where ordernum = '100012'
select * from ticket

--��ͼ7��������ʾ��Ʊ��Ϣ
if exists(select * from sysobjects where name = 'ticketInformation' and type = 'v')
drop view ticketInformation
go
create view ticketInformation
  as
  select ticketnum,ticket.airnum,start_station,end_station,ticket.date,start_time,end_time,
         name,class_level,seatnum,ordernum
  from ticket,passage,flight
  where ticket.airnum = flight.airnum and ticket.date = flight.date and ticket.id = passage.id
go
--����
select * from ticketInformation where ordernum = '100009'

select passage.id,name,phonenum,class_level,seatnum 
                                from passage,ticket,flight 
                                where passage.id = ticket.id 
                                and ticket.airnum = flight.airnum
                                and ticket.date = flight.date
								and start_station like '%'+ '����'+'%'
								and end_station like '%' +'�Ϻ�'+'%'
								and flight.date ='2021-07-04'

--��ͼ8�����ڹ���Ա��ѯ������Ϣ
if exists(select * from sysobjects where name = 'adminFlightInfo' and type = 'v')
drop view adminFlightInfo
go
create view adminFlightInfo
  as
  select f.airnum,f.date,f.start_station,f.end_station,plane_model,f.start_time,f.end_time,comp_name,f.price,
  �������Ʊ,���ò���Ʊ,(ISNULL(�������,0)+ISNULL(���ò���,0)) ��Ʊ��
  from (flight f left join soldOutFirstSeatAmount soldF on soldF.airnum = f.airnum and soldF.date = f.date) left join
  soldOutSecondSeatAmount soldS on soldS.airnum = f.airnum and soldS.date = f.date,tickets_left tl,airplane ap
  where f.airnum = tl.airnum and f.date = tl.date and f.planenum = ap.planenum 
go
--����
select * from adminFlightInfo

--  select airline.start_station,airline.end_station,sum(��Ʊ��) ��Ʊ����
--  from adminFlightInfo,airline
--  where airline.start_station = adminFlightInfo.start_station and airline.end_station = adminFlightInfo.end_station
--  group by airline.start_station,airline.end_station


--��ͼ9�����ڲ�ѯָ�����ڵĸ������������
if exists(select * from sysobjects where name = 'soleAmount' and type = 'v')
drop view soleAmount
go
create view soleAmount
  as  
  select flight.airnum,flight.date,start_station,end_station,comp_name,count(*) ��������,orderDate
  from orderform,ticket,flight
  where ticket.ordernum = orderform.ordernum and ticket.airnum = flight.airnum and ticket.date = flight.date
  and ticket.ticket_status != 1
  group by flight.airnum,flight.date,start_station,end_station,comp_name,orderDate
go
--����
select airnum,date,start_station,end_station,comp_name,sum(��������) ���� 
from soleAmount 
where orderDate like '%'+'2021-07'+'%'
group by airnum,date,start_station,end_station,comp_name

select airnum,date,start_station,end_station,comp_name,sum(��������) ���� 
from soleAmount 
where orderDate = '2021-06-06'
group by airnum,date,start_station,end_station,comp_name



--�洢����1�����������ѯ������Ϣ
if exists(select name from sysobjects where name = 'searchFlight' and type = 'p')
drop procedure searchFlight
go
create procedure searchFlight
 @start_station varchar(20),@end_station varchar(20),@date date
 as
 select *
 from flightInformation
 where start_station like '%'+@start_station+'%' and end_station like '%'+@end_station+'%' 
       and date = @date
go
--����
exec searchFlight '����','�Ϻ�','2021-07-04'
go

--�洢����2����Ʊ�ɹ�ʱ��passage�������Ӧ�ĳ˿���Ϣ
if exists(select name from sysobjects where name = 'newPassage' and type = 'p')
drop procedure newPassage
go
create procedure newPassage
 @id varchar(20),@name varchar(20),@phonenum varchar(20)
 as
 declare @isexist int
 select @isexist = (select count(*) from passage where id = @id)
 if(@isexist != 1)
 begin
 insert into passage(id,name,phonenum)
 values(@id,@name,@phonenum)
 end
go

--����
exec newPassage '520421198909071490','�ߺ�','15432451269'
go
select * from passage

----------------------------------------------------------------------------------
--�洢����3����Ʊ�ɹ�������亽��Ų�ѯ�亽˾
--if exists(select name from sysobjects where name = 'searchComp' and type = 'p')
--drop procedure searchComp
--go
--create procedure searchComp
-- @airnum varchar(20)
-- as
-- select comp_name
-- from flight
-- where airnum = @airnum
--go
--����
----------------------------------------------------------------------------------

--�洢����3����Ʊ�ɹ�����member������Ӧ�Ļ�Ա��Ϣ
if exists(select name from sysobjects where name = 'newMember' and type = 'p')
drop procedure newMember
go
create procedure newMember
 @id varchar(20),@airnum varchar(20),@date date
 as
 declare @comp_name varchar(20),@isexist int
 select @comp_name = (select comp_name from flight where airnum = @airnum and date = @date)
 select @isexist = (select count(*)from member where id = @id and comp_name = @comp_name)
 if(@isexist != 1)
 begin
 insert into member(id,comp_name,mlevel,mileage)
 values(@id,@comp_name,'��ͨ��Ա',0)
 end
go
--����
exec newMember '54246319910507652X','CZ6147','2021-07-10'
go
select * from member


--�洢����4����Ʊ�ɹ�����ticket���в�����Ӧ�Ļ�Ʊ��Ϣ
if exists(select name from sysobjects where name = 'newTicket' and type = 'p')
drop procedure newTicket
go
create procedure newTicket
 @ticketnum varchar(20),@airnum varchar(20),@date date,@class_level varchar(20),
 @id varchar(20),@ordernum varchar(20)
 as
 insert into ticket(ticketnum,airnum,date,class_level,id,ordernum)
 values(@ticketnum,@airnum,@date,@class_level,@id,@ordernum)
go
--����
exec newTicket '060310002','CZ6147','2021-07-10','���ò�','54246319910507652X','100017'
go
select * from ticket
select * from flightInformation

--�洢����5�������µĶ�����Ϣ
if exists(select name from sysobjects where name = 'newOrder' and type = 'p')
drop procedure newOrder
go
create procedure newOrder
 @ordernum varchar(20),@orderDate date,@username varchar(20),@total_money float
 as
 insert into orderform(ordernum,orderDate,username,total_money)
 values(@ordernum,@orderDate,@username,@total_money)
go
--����
exec newOrder '100016','2021-06-06','18725087325',650
go

--�洢����6������ʵ�ֻ�Ʊ�۸�ĸ���
if exists(select name from sysobjects where name = 'priceFluctuation' and type = 'p')
drop procedure priceFluctuation
go
create procedure priceFluctuation
 as
 update flight
 set price = price * 1.25
 --where DATEDIFF(DAY,@nowDate,date) < 4 and DATEDIFF(DAY,@nowDate,date) > 0
 where DATEDIFF(DAY,GETDATE(),date) < 4 and DATEDIFF(DAY,GETDATE(),date) > 0
go
--����
exec priceFluctuation
select * from flightInformation
select * from flight
--�洢����7�����ڽ���Ʊ�۸�����۸����
if exists(select name from sysobjects where name = 'rePriceFluctuation' and type = 'p')
drop procedure rePriceFluctuation
go
create procedure rePriceFluctuation
 as
 update flight
 set price = price / 1.25
 --where DATEDIFF(DAY,@nowDate,date) < 4 and DATEDIFF(DAY,@nowDate,date) > 0
 where DATEDIFF(DAY,GETDATE(),date) < 4 and DATEDIFF(DAY,GETDATE(),date) > 0
go
--����
exec rePriceFluctuation
select * from flight

--�洢����8����ѯ�˺�������ӹ��ĳ˻�����Ϣ
if exists(select name from sysobjects where name = 'oldPassagers' and type = 'p')
drop procedure oldPassagers
go
create procedure oldPassagers
 @username varchar(20)
 as
 select distinct passage.id,passage.name,passage.phonenum
 from orderform,ticket,passage
 where.orderform.ordernum = ticket.ordernum and passage.id = ticket.id
  and username = @username
go
--����
exec oldPassagers '18725087325'


--������1,��Ʊ�ɹ���Ϊ�˿͵Ļ�Ա��Ϣ���Ӷ�Ӧ�������
if exists(select * from sysobjects where name = 'addMileage' and type = 'tr')
drop trigger addMileage
go
create trigger addMileage
on ticket
after insert
as
  declare @airnum varchar(20),@date date,
          @start_station varchar(20),@end_station varchar(20),@mileage int,
          @id varchar(20),@comp_name varchar(20) 
  select @airnum = airnum,@date = date,@id = id
  from inserted
  select @start_station = (select start_station from flight where airnum = @airnum and date = @date)
  select @end_station = (select end_station from flight where airnum = @airnum and date = @date)
  select @comp_name = (select comp_name from flight where airnum = @airnum and date = @date)
  select @mileage = (select mileage from airline where start_station = @start_station 
                                                   and end_station = @end_station)
  update member
  set mileage = mileage + @mileage
  where id = @id and comp_name = @comp_name  
  
  select @mileage = (select mileage from member where id = @id and comp_name = @comp_name)
  if(@mileage > 40000)
  begin
  update member
  set mlevel = '������Ա'
  where id = @id and comp_name = @comp_name 
  end
  else if(@mileage > 80000)
   begin
  update member
  set mlevel = '�𿨻�Ա'
  where id = @id and comp_name = @comp_name 
  end
go
--����
select * from member

--������2,��Ʊ�ɹ���Ϊ�˿ͼ��ٶ�Ӧ�������
if exists(select * from sysobjects where name = 'deleteMileage' and type = 'tr')
drop trigger deleteMileage
go
create trigger deleteMileage
on ticket
after update
as
  declare @airnum varchar(20),@date date,
          @start_station varchar(20),@end_station varchar(20),@mileage int,
          @id varchar(20),@comp_name varchar(20) 
  select @airnum = airnum,@date = date,@id = id
  from deleted
  select @start_station = (select start_station from flight where airnum = @airnum and date = @date)
  select @end_station = (select end_station from flight where airnum = @airnum and date = @date)
  select @comp_name = (select comp_name from flight where airnum = @airnum and date = @date)
  select @mileage = (select mileage from airline where start_station = @start_station 
                                                   and end_station = @end_station)
  update member
  set mileage = mileage - @mileage
  where id = @id and comp_name = @comp_name

  select @mileage = (select mileage from member where id = @id and comp_name = @comp_name)
  if(@mileage < 40000)
   begin
     update member
     set mlevel = '��ͨ��Ա'
     where id = @id and comp_name = @comp_name 
   end
  else if(@mileage < 80000)
   begin
    update member
    set mlevel = '������Ա'
    where id = @id and comp_name = @comp_name 
   end
go
--����
select * from member

select count(*) from ticket where ticketnum like '0603'+'%'
