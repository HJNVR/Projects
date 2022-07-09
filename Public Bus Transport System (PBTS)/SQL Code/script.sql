
# Question1
set @plate_no = 'SKJ8213C';
set @year = '2019';
set @m1 = '1';
set @m2 = '12';

select plateno as 'Bus Plate', extract(month from tdate) as 'Month',
count(*) as 'Total number of trips', count(distinct bt.sid) as 'Total number of services',
count(distinct did) as 'Total number of drivers'
from bustrip bt inner join service s on bt.sid = s.sid
and bt.plateno = @plate_no and extract(year from tdate) = @year
and extract(month from tdate) >= @m1 and extract(month from tdate) <= @m2
group by plateno,extract(month from tdate);


# Question 2: 
set @add_des = 'plaza';

select s.stopid as 'Stop ID', locationdes as 'Location', address as 'Address',st.sid as 'SID',
if(normal=1,'Normal','Express') as 'Type',weekdayfreq as 'Weekday Freq',weekendfreq as 'Weekend Freq'
from stop s inner join stoprank st on s.stopid = st.stopid
and (locationdes like concat('%', @add_des, '%') or address like concat('%', @add_des, '%'))
inner join service se on se.sid = st.sid left outer join normal n
on n.sid = se.sid;


# Question 3: 
select c.cardid as 'Replaced Card', expiry as 'Expiry', 
count(rdate) as 'Number of rides', oldcardid as 'Old card', 
oldcount as 'Number of Rides of Old card'from citylink c left outer join ride r1 on c.cardid = r1.cardid
left outer join (select c.cardid, count(rdate) as 'oldcount' from citylink c 
left outer join ride r1 on c.cardid = r1.cardid group by c.cardid) 
as t on c.oldcardid = t.cardid where oldcardid is not null  group by c.cardid order by expiry desc; 


# Question 4: 
delimiter $$
create procedure findXthPopularStop(in startdate date, in enddate date, in x int)
begin
	
    with table3 as
	(with table2 as
	(with table1 as
	(select alightstop from ride
		where alightstop is not null and rdate between startdate and enddate
		union all
		select boardstop from ride where rdate between startdate and enddate
		union all
		select stopid from stoprank where (stopid, sid, rankorder) in(
		select stopid, sid, max(rankorder) from stoprank 
		where (stopid,sid) in (select boardstop, sid from ride where alightstop is NULL and 
							rdate between startdate and enddate)
		group by stopid, sid))
	select alightstop, count(*) as counts from table1 group by table1.alightstop order by counts desc)
	select 
	case 
		when @prevRank = counts then @curRank
		when @prevRank := counts then @curRank := @curRank + 1
	end as ranking , alightstop 
	from table2, (select @curRank :=0, @prevRank := NULL) r)
	select alightstop as "BusStop ID" from table3 where ranking = x;
	
end $$
delimiter ; 

call findXthPopularStop('2021-01-01', '2021-01-31', 1);

# Question 5: 

delimiter $$
create function LastStop (serviceID int)
returns int
DETERMINISTIC
begin
declare laststopid int;

set laststopid = (select stopid from stoprank where sid = serviceID and
rankorder = (select max(rankorder) from stoprank where sid = serviceID));
return laststopid;
end $$
delimiter ;

set @StartDate = '2019-01-30';
set @EndDate = '2021-05-27';
set @CLID = 25;
with tempride as 
 (select r.cardid, discount, sid, rdate, boardstop, alightstop, ifnull(alightstop, laststop(sid)) as alightstop2
 from ride r, citylink cl, cardtype ct
 where r.cardid = cl.cardid and cl.type = ct.type 
    and r.cardid = @CLID and rdate between @Startdate and @enddate)
select rdate as 'Ride Date', sid as SID, boardstop as 'Board Stop', temp.locationdes as 'Board Location',
alightstop as 'Alight Stop', s2.locationdes as 'Alight Location',
basefee*(1-discount) as 'Fare Paid'
from (select * from tempride t, stop s1, stoppair sp
where t.boardstop = s1.stopid and t.boardstop = sp.fromstop and t.alightstop2 = sp.tostop) 
temp left outer join stop s2 on temp.alightstop = s2.stopid
order by rdate;


# Question 6:
set @ServiceID = 16;
set @StartDate = '2020-03-25';
set @ENdDate = '2021-03-01';
with maxstop as
(select sid, rankorder from stoprank where stopid=(laststop(sid)))
select r.sid as 'SID', count(cardid) as 'Number of Passengers Ferried',
rankorder as 'Total Number of Stops',
(select count(*) from
(select boardstop from ride where rdate between @StartDate and @EndDate and sid = @serviceid
union
select alightstop from ride where rdate between @StartDate and @EndDate and sid = @serviceid)
temp)
as 'Total Number of Unique Stops'
from ride r, maxstop m where r.sid = m.sid and (rdate between @StartDate and @EndDate) and r.sid = @serviceid
group by r.sid, rankorder;

# Question 7: 
set @X = 19;

select officerid, yearsemp, name, count(id) as offence_num, count(paycard) as offence_paid_card,
sum(penalty) as penalty_amount, count(distinct sid,sdate,stime) as unique_bustrip
from officer ofr left join offence ofe on ofr.officerid = ofe.oid
where yearsemp >= @X
group by officerid, yearsemp, name;


# Question 8: 
set @x = 4; 

with table2 as
(with table1 as 
(select d.did as d, d.name as n, 
count(*) as numtrips, count(distinct sid) as numservices, count(distinct plateno) as numbuses
from driver d join bustrip b on d.did = b.did  group by b.did, d.name order by numtrips desc)
select 
case 
	when @prevRank = numtrips then @curRank 
    when @prevRank := numtrips then @curRank := @curRank + 1
end as "Rank", table1.d as "Driver ID", table1.n as "Name", table1.numtrips as "Number of trips", 
table1.numservices as "Number of unique services", table1.numbuses as "Number of unique buses"
from table1,
(select @curRank :=0, @prevRank := NULL) r)
select * from table2 where table2.rank <= @x;


