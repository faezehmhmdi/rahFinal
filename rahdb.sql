-- Hosts Table 
create table Hosts
(
    id      int unsigned auto_increment,
    name    varchar(255) not null,
    manager varchar(255) not null,
    primary key (id),
    key (name, manager)
);

-- Supporter Table
create table Supporter
(
    id        int unsigned auto_increment,
    name      varchar(255) not null,
    telephone varchar(16)  not null, -- account for country code and + sign
    key (id),
    primary key (id, name),
    constraint valid_telephone_number check (telephone REGEXP '^\\+?[0-9]+$')
);

-- platform Table
create table Platform
(
    id          int unsigned auto_increment,
    name        varchar(255)  not null,
    url         varchar(2048) not null,
    description text          not null,
    primary key (id),
    key (name)
);

-- Place Table
create table Place
(
    id      int unsigned auto_increment,
    name    varchar(255) not null,
    isEmpty boolean      not null default 1,
    primary key (id),
    key (name)
);


-- Conferences Table
create table Conference
(
    id               int unsigned auto_increment,
    request_number   varchar(255) not null,
    request_sentDate Date         not null,
    topic            varchar(255) not null,
    start_Date       Date         not null,
    start_time       time(0)      not null default '08:00:00',
    end_time         time(0)      not null default '08:00:00',
    placeId          int unsigned ,
    hostId           int unsigned,
    platformId       int unsigned,
    supporterId      int unsigned,
    isCanceled       boolean               default 0,
    isHost           boolean               default 1, -- if 0 we are guest if 1 we are host
	confDesc		 text,
	confGuests		 text,
    primary key (id),
    key (request_number, topic),
    check (start_time <= end_time),
    foreign key (hostId) references Hosts (id)
        on update cascade
        on delete cascade,
    foreign key (supporterId) references Supporter (id)
        on update cascade
        on delete cascade,
    foreign key (platformId) references Platform (id)
        on update cascade
        on delete cascade,
    foreign key (placeId) references Place (id)
        on update cascade
        on delete cascade
);

-- Conference Descriptions TABLE
create table ConfDescription
(
	id	int unsigned auto_increment,
	confDesc text,
	confID int unsigned,
	primary key(id),
	foreign key(confID) references Conference (id)
);
-- Admin Account Table
create table AdminAcc
(
    username varbinary(255),
    pass     varbinary(255) not null, -- password hash might be much larger than password itself
    primary key (username)
);

-- Login Table
create table logins
(
    id         int unsigned auto_increment,
    username   varbinary(255) not null,
    login_time timestamp      not null default NOW(),
    primary key (id),
    foreign key (username) references AdminAcc (username) on delete cascade
);

--plco table
create table plco (
	select Conference.start_Date, Conference.start_time, Conference.placeId, Place.name
	from Conference join Place 
		on Conference.placeId = Place.id
);

-- Add Host Function
delimiter //
create function addHost(hostName varchar(255), manager varchar(255))
    returns int unsigned
begin
    if (select count(*) from Hosts as h where (h.name = hostName) and (h.manager = manager)) = 0 then
        insert into Hosts values (null, hostName, manager);
		return (select LAST_INSERT_ID());
    else
    	return return (select MAX(id) from Hosts as h where (h.name = hostName) and (h.manager = manager));
    end if;
end
//
delimiter ;

-- Edit Host info Function
delimiter //
create function editHost(id int unsigned, name varchar(255), manager varchar(255))
    returns char(64)
begin
    declare res char(64);
    if (select count(*) from Hosts as h where (h.id = id)) = 1 then
        update Hosts as h
        set h.name = coalesce (name, h.name),
            h.manager = coalesce (manager, h.manager)
        where h.id = id;
        set res = 'Host edited.';
    else
        set res = 'Host with id doesn\'t exist.';
    end if;
    return res;
end
//
delimiter ;

-- Add Supporter Function
delimiter //
create function addSupporter(supporterName varchar(255), telephone varchar(16))
    returns int unsigned
begin
    if (select count(*) from Supporter as s where (s.name = supporterName) and (s.telephone = telephone)) = 0 then
        insert into Supporter values (null, supporterName, telephone);
        return (select LAST_INSERT_ID());
    else
		return (select MAX(id) from Supporter where (name = supporterName) and (telephone = telephone));
    end if;
end
//
delimiter ;

-- Edit Supporter Function
delimiter //
create function editSupporter (id int unsigned, supporterName varchar(255), telephone varchar(16))
	returns char(64)
begin
	declare res char(64);
	if (select count(*) from Supporter as s where (s.id = id)) = 1 then
		update Supporter as s
		set s.name = coalesce (supporterName, s.name),
			s.telephone = coalesce (telephone, s.telephone)
		where s.id = id;
		set res = 'Supporter Edited.';
	else
		set res = 'Supporter with id doesn\'t exist.';
	end if;
	return res;
end
//
delimiter ;

-- Add Platform Function
delimiter //
create function addPlatform (platName varchar(255), url varchar(2048), description text)
    returns int unsigned
begin
    if (select count(*)
        from Platform as p
        where (p.name = platName)
          and (p.url = url)
          and (p.description = description)) = 0 then
        insert into Platform values (null, platName, url, description);
        return (select LAST_INSERT_ID());
    else
        return (select MAX(id) from Platform where (name = platName) and (url = url) and (description = description));
    end if;
end
//
delimiter ;

-- Edit Platform Function
delimiter //
create function editPlatform (id int unsigned, platName varchar(255), url varchar(2048), description text)
	returns char(64)
begin
	declare res char(64);
	if (select count(*) from Platform as p where (p.id = id)) = 1 then
		update Platform as pl
		set pl.name = coalesce (platName, pl.name),
			pl.url = coalesce (url, pl.url),
			pl.description = coalesce (description, pl.description)
		where pl.id = id;
		set res = 'Platform edited.';
	else
		set res = 'Platform with id doesn\'t exist.';
	end if;
	return res;
end
//
delimiter ;

-- Add Place Function
delimiter //
create function addPlace (placName varchar(255), isEmp boolean)
    returns char (64)
begin
	declare res char(64);
	if(select count(*) from Place as pl where (pl.name = placName)) = 0 then
		insert into Place values (null, placName, isEmp);
		set res = "Place added";
	else
		set res = "duplicate";
	end if;
	return res;
end
//
delimiter ;

-- Return Place id Function
delimiter //
create function returnPlace (placName varchar(255))
	returns int unsigned
begin
	if(select count(*) from Place as pl where (pl.name = placName)) = 0 then
		return (select LAST_INSERT_ID());
	else
		return (select MAX(id) from Place where (name = placName));
	end if;
end
//
delimiter ;
-- Edit Place Function
delimiter //
create function editPlace (id int unsigned, placName varchar(255), isEmp boolean)
	returns char(64)
begin
	declare res char(64);
	if (select count(*) from Place as p where (p.id = id)) = 1 then
		update Place as p
		set p.name = coalesce (placName, p.name),
			p.isEmpty = coalesce (isEmp, p.isEmpty)
		where p.id = id;
		set res = 'Place edited';
	else
		set res = 'Place with id doesn\'t exist.';
	end if;
	return res;
end
//
delimiter ;

-- fix foregin key problem
-- Add Participator Function
delimiter //
create function addPartic(name varchar(255))
	returns char(64)
begin
	declare res char(64);
	declare confID int unsigned;
	set confID = (select LAST_INSERT_ID() from Conference);
	if(select count(*)
		from participator as p 
		where (p.name = name)
		and (p.confID = confID)) = 0 then
		insert into Participator values('', name , confID);
		set res = 'Participator added.';
	else
		set res = 'Already exists.';
	end if;
	return res;
end
//
delimiter ;

delimiter //
create function editPartic(id int unsigned, particName varchar(255))
	returns char(64)
begin
	declare res char(64);
	-- declare confID = (select LAST_INSERT_ID() from Conference); Should we also change the ConfID ??
	if (select count(*) from Participator as p where (p.id = id)) = 1 then
		update Participator as p
		set p.name = coalesce (particName, p.name)
		where p.id = id;
		set res = 'Participator edited.';
	else
		set res = 'Participator with id doesn\'t exist.';
	end if;
	return res;
end
//
delimiter ;


-- Add Conference Function
delimiter //
create function addConference(request_number varchar(255), request_sentDate Date, topic varchar(255), start_Date Date,
                              start_time time(0), end_time time(0), isCanceled boolean, isHost boolean,
							  hname varchar(255), hmanager varchar(255),placeName varchar(255), platformName varchar(255),
							  platUrl varchar(2048), platDescription text, supnName varchar(255), supTelephone varchar(16),
							  confDesc text, confGuests text)
    returns int unsigned
begin
	declare placeId int unsigned;
	declare hostId int unsigned;
	declare platformId int unsigned;
	declare supporterId int unsigned;
	set placeId = returnPlace(placeName);
	set hostId  = addHost (hname, hmanager);
	set platformId = addPlatform (platformName, platUrl, platDescription);
	set supporterId = addSupporter (supnName, supTelephone);
	if (select count(*)
		from Conference as c 
		where (c.request_number = request_number)
		and (c.request_sentDate = request_sentDate)
		and (c.topic = topic)) = 0 then
		insert into Conference values (null, request_number, request_sentDate, topic, start_Date, start_time, end_time,
									   placeId, hostId, platformId, supporterId, isCanceled, isHost, confDesc, confGuests);
		return (select LAST_INSERT_ID());
	else
		return 0;
	end if;
end
//
delimiter ;


-- Login Admin Function
delimiter //
create function login(username varbinary(255), pass_text varbinary(255))
    returns char(64)
begin
    declare res char(64);
    if (select count(*) from AdminAcc as temp where (temp.username = username) and (SHA2(pass_text, 256) = temp.pass)) =
       1 then
        if (select count(*) from logins where logins.username = username) = 0 then
            insert into logins values ('', username, NOW());
        else
            update logins set login_time=now() where logins.username = username;
        end if;
        set res = 'Logged in';
    else
        set res = 'Wrong username or password';
    end if;
    return res;
end
//
delimiter ;

-- Add Admin Functionp
delimiter //
create function addAdmin(username varbinary(255), pass varbinary(255))
    returns char(64)
begin
    declare res char(64);
    if (select count(*) from AdminAcc as t where t.username = username) = 0 then
        insert into AdminAcc values (username, SHA2(pass, 256));
        set res = 'Admin account saved';
    else
        set res = 'Account Duplication';
    end if;
    return res;
end
//
delimiter ;

-- Cancel Conference Function
delimiter //
create function cancelConf(id int unsigned)
	returns char(64)
begin
	declare res char(64);
	if (select count(*) from Conference as c where (c.id = id)) = 1 then
		update Conference as co
		set co.isCanceled = 1
		where co.id = id;
		set res = 'Conference canceled.';
	else
		set res = 'Conference with id doesn\'t exist.';
	end if;
	return res;
end
//
delimiter ;

delimiter //
create function undoCancelConf(id int unsigned)
	returns char(64)
begin
	declare res char(64);
	if (select count(*) from Conference as c where (c.id = id)) = 1 then
		update Conference as co
		set co.isCanceled = 0
		where co.id = id;
		set res = 'Conference is not canceled.';
	else
		set res = 'Conference with id doesn\'t exist.';
	end if;
	return res;
end
//
delimiter ;

delimiter //
create function addConfDescription (id int unsigned, descript text)
	returns char(64)
begin
	declare res char(64);
	if (select count(*) from Conference as c where (c.id = id)) = 1 then
		update Conference as co
		set co.confDesc = descript
		where co.id = id;
		set res = "desc uptaded";
	else
		set res = "Conf with id doesn\'t exist";
	end if;
	return res;
end
//
delimiter ;

delimiter //
create procedure showConfs ()
    begin
    select *
    from (
    select Conference.id, Conference.topic, Conference.isCanceled, Conference.start_Date, Conference.start_time, Conference.end_time, Hosts.name as hname, Place.name as plname,
		   Platform.url, Platform.description, Supporter.name as sname, Supporter.telephone, Conference.confDesc, Conference.confGuests
	from Conference join Hosts
		on Conference.hostId = Hosts.id
	join Place
		on Conference.placeId = Place.id
	join Platform
		on Conference.platformId = Platform.id
	join Supporter
		on Conference.supporterId = Supporter.id	
    ) as tmp
    order by tmp.start_Date desc;
end;
//

delimiter //
create function detect (n varchar(255), dateS Date, timeS time(0), timeE time(0))
	returns char(64)
begin
	declare res char(64);
	declare plId int unsigned;
	set plID = findPlaceId (n);
	if (select count(*) from Conference as C where (C.placeId = plId) and (C.start_Date = dateS) and ((C.end_time >= timeS) and (C.start_time <= timeE))) = 0 then
		set res = "not taken";
	else
		set res = "taken";
	end if;
	return res;
end
//
delimiter ;

delimiter //
create function findPlaceId (n varchar(255))
	returns int unsigned
begin
	declare myid int unsigned;
	set myid = (select id from Place where Place.name = n);
	return myid;
end
//
delimiter ;
				       
delimiter //
create function deleteConf (id int unsigned)
	returns char(64)
begin
	declare res char(64);
	if (select count(*) from Conference as c where (c.id = id)) = 1 then
		delete from Conference as co
		where co.id = id;
		set res = 'deleted';
	else
		set res = 'problem';
	end if;
	return res;
end
//
delimiter ;	
