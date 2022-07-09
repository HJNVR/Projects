create schema G1T4;
use G1T4;

# crete tables
create table service
(sid int not null primary key,
 normal TINYINT(1)); 
 
create table normal 
(sid int not null primary key, 
 weekdayfreq int, 
 weekendfreq int,
 constraint normal_fk foreign key(sid) references service(sid));

create table express
(sid int not null primary key,
 availableweekend TINYINT(1),
 availableph TINYINT(1),
 constraint express_fk foreign key(sid) references service(sid));
   
create table company
(sid int not null, 
 company varchar(20) not null,
 constraint company_pk primary key(sid, company),
 constraint company_fk foreign key(sid) references service(sid));

create table driver
(did int not null primary key, 
 nric char(9),
 name varchar(50),
 dob date, 
 gender char(1));
 
create table officer 
(officerid int not null primary key,
 name varchar(50), 
 yearsemp int);

create table bus
(plateno char(8) not null primary key, 
 fueltype varchar(10),
 capacity int);
   
create table bustrip
(sid int not null, 
 tdate date not null, 
 starttime time not null, 
 endtime time, 
 plateno char(8),
 did int,
 constraint company_pk primary key(sid, tdate, starttime),
 constraint bustrip_fk1 foreign key(sid) references service(sid),
 constraint bustrip_fk2 foreign key(plateno) references bus(plateno),
 constraint bustrip_fk3 foreign key(did) references driver(did));

create table cardtype
(type varchar(10) not null primary key, 
 discount float,
 mintopamount int, 
 description varchar(200));
 
create table citylink
(cardid int not null primary key, 
 balance float, 
 expiry date, 
 type varchar(10), 
 oldcardid int,
 constraint citylink_fk1 foreign key(type) references cardtype(type), 
 constraint citylink_fk2 foreign key(oldcardid) references citylink(cardid));
 
create table offence
(id int not null primary key, 
 nric char(9),
 time time, 
 penalty float, 
 paycard int, 
 sid int, 
 sdate date, 
 stime time, 
 oid int,
 constraint offence_fk1 foreign key(paycard) references citylink(cardid),
 constraint offence_fk2 foreign key(sid, sdate, stime) references bustrip(sid, tdate, starttime),
 constraint offence_fk3 foreign key(oid) references officer(officerid));
 

create table stop
(stopid int not null primary key, 
 locationdes varchar(50), 
 address varchar(50));
 
create table stoppair
(fromstop int not null, 
 tostop int not null, 
 basefee float not null,
 constraint stoppair_pk primary key(fromstop, tostop),
 constraint stoppair_fk1 foreign key(fromstop) references stop(stopid), 
 constraint stoppair_fk2 foreign key(tostop) references stop(stopid));
 
create table stoprank 
(stopid int not null, 
 sid int not null, 
 rankorder int,
 constraint stoprank_pk primary key(stopid, sid),
 constraint stoprank_fk1 foreign key(stopid) references stop(stopid),
 constraint stoprank_fk2 foreign key(sid) references service(sid));
 
create table ride
(cardid int not null, 
 rdate date not null, 
 usephone TINYINT(1),
 boardstop int, 
 sid int, 
 alightstop int, 
 boardtime time not null, 
 alighttime time, 
 constraint ride_pk primary key(cardid, rdate, boardtime),
 constraint ride_fk1 foreign key(boardstop, sid) references stoprank(stopid, sid),
 constraint ride_fk2 foreign key(alightstop) references stop(stopid));

# Insert data
 LOAD DATA INFILE '/Applications/config/text files/G1T4/data/service.txt' INTO TABLE service FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/normal.txt' INTO TABLE normal FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/express.txt' INTO TABLE express FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/company.txt' INTO TABLE company FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/driver.txt' INTO TABLE driver FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/bus.txt' INTO TABLE bus FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/bustrip.txt' INTO TABLE bustrip FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/officer.txt' INTO TABLE officer FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/cardtype.txt' INTO TABLE cardtype FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/citylink.txt'
INTO TABLE citylink
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(cardID, balance, expiry, type, @oldcardid)
SET oldcardid = NULLIF(@oldcardid, 'NULL')
;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/offence.txt' 
INTO TABLE offence FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, nric, time, penalty, @paycard, sid,	sdate, stime, oid)
SET paycard = NULLIF(@paycard, 'NULL');

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/stop.txt' INTO TABLE stop FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/stoppair.txt' INTO TABLE stoppair FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/stoprank.txt' INTO TABLE stoprank FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

LOAD DATA INFILE '/Applications/config/text files/G1T4/data/ride.txt'  
INTO TABLE ride FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(cardID, rdate, usephone, boardstop, sid, @alightstop, boardtime, @alighttime)
SET alightstop = NULLIF(@alightstop, 'NULL'),
alighttime = NULLIF(@alighttime, 'NULL');

