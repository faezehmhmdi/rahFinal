-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 14, 2020 at 11:48 AM
-- Server version: 10.4.13-MariaDB
-- PHP Version: 7.4.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rah`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `showConfs` (IN `showDate` DATE)  begin
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
    ) as tmp where (tmp.start_Date = showDate)
    order by tmp.start_Date desc, tmp.start_time asc;
end$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `addAdmin` (`username` VARBINARY(255), `pass` VARBINARY(255)) RETURNS CHAR(64) CHARSET utf8mb4 begin
    declare res char(64);
    if (select count(*) from AdminAcc as t where t.username = username) = 0 then
        insert into AdminAcc values (username, SHA2(pass, 256));
        set res = 'Admin account saved';
    else
        set res = 'Account Duplication';
    end if;
    return res;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `addConfDescription` (`id` INT UNSIGNED, `descript` TEXT) RETURNS CHAR(64) CHARSET utf8mb4 begin
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
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `addConference` (`request_number` VARCHAR(255), `request_sentDate` DATE, `topic` VARCHAR(255), `start_Date` DATE, `start_time` TIME(0), `end_time` TIME(0), `isCanceled` BOOLEAN, `isHost` BOOLEAN, `hname` VARCHAR(255), `hmanager` VARCHAR(255), `placeName` VARCHAR(255), `platformName` VARCHAR(255), `platUrl` VARCHAR(2048), `platDescription` TEXT, `supnName` VARCHAR(255), `supTelephone` VARCHAR(16), `confDesc` TEXT, `confGuests` TEXT) RETURNS INT(10) UNSIGNED begin
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
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `addHost` (`hostName` VARCHAR(255), `manager` VARCHAR(255)) RETURNS INT(10) UNSIGNED begin
    if (select count(*) from Hosts as h where (h.name = hostName) and (h.manager = manager)) = 0 then
        insert into Hosts values (null, hostName, manager);
		return (select LAST_INSERT_ID());
    else
    	return (select MAX(id) from Hosts as h where (h.name = hostName) and (h.manager = manager));
    end if;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `addPlace` (`placName` VARCHAR(255), `isEmp` BOOLEAN) RETURNS CHAR(64) CHARSET utf8mb4 begin
	declare res char(64);
	if(select count(*) from Place as pl where (pl.name = placName)) = 0 then
		insert into Place values (null, placName, isEmp);
		set res = "Place added";
	else
		set res = "duplicate";
	end if;
	return res;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `addPlatform` (`platName` VARCHAR(255), `url` VARCHAR(2048), `description` TEXT) RETURNS INT(10) UNSIGNED begin
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
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `addSupporter` (`supporterName` VARCHAR(255), `telephone` VARCHAR(16)) RETURNS INT(10) UNSIGNED begin
    if (select count(*) from Supporter as s where (s.name = supporterName) and (s.telephone = telephone)) = 0 then
        insert into Supporter values (null, supporterName, telephone);
        return (select LAST_INSERT_ID());
    else
		return (select MAX(id) from Supporter where (name = supporterName) and (telephone = telephone));
    end if;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `cancelConf` (`id` INT UNSIGNED) RETURNS CHAR(64) CHARSET utf8mb4 begin
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
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `deleteConf` (`id` INT UNSIGNED) RETURNS CHAR(64) CHARSET utf8mb4 begin
	declare res char(64);
	if (select count(*) from Conference as c where (c.id = id)) = 1 then
		delete from Conference
		where Conference.id = id;
		set res = 'deleted';
	else
		set res = 'problem';
	end if;
	return res;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `detect` (`n` VARCHAR(255), `dateS` DATE, `timeS` TIME(0), `timeE` TIME(0)) RETURNS CHAR(64) CHARSET utf8mb4 begin
	declare res char(64);
	declare plId int unsigned;
	set plID = findPlaceId (n);
	if (select DISTINCT count(*) from Conference as C where (C.placeId = plId) and (C.start_Date = dateS) and ((C.end_time >= timeS) and (C.start_time <= timeE))) = 0 then
		set res = "not taken";
	else
		set res = "taken";
	end if;
	return res;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `editHost` (`id` INT UNSIGNED, `name` VARCHAR(255), `manager` VARCHAR(255)) RETURNS CHAR(64) CHARSET utf8mb4 begin
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
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `editPlace` (`id` INT UNSIGNED, `placName` VARCHAR(255), `isEmp` BOOLEAN) RETURNS CHAR(64) CHARSET utf8mb4 begin
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
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `editPlatform` (`id` INT UNSIGNED, `platName` VARCHAR(255), `url` VARCHAR(2048), `description` TEXT) RETURNS CHAR(64) CHARSET utf8mb4 begin
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
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `editSupporter` (`id` INT UNSIGNED, `supporterName` VARCHAR(255), `telephone` VARCHAR(16)) RETURNS CHAR(64) CHARSET utf8mb4 begin
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
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `findPlaceId` (`n` VARCHAR(255)) RETURNS INT(10) UNSIGNED begin
	declare myid int unsigned;
	set myid = (select id from Place WHERE Place.name = n);
	return myid;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `login` (`username` VARBINARY(255), `pass_text` VARBINARY(255)) RETURNS CHAR(64) CHARSET utf8mb4 begin
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
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `returnPlace` (`placName` VARCHAR(255)) RETURNS INT(10) UNSIGNED begin
	if(select count(*) from Place as pl where (pl.name = placName)) = 0 then
		return (select LAST_INSERT_ID());
	else
		return (select id from Place where (place.name = placName));
	end if;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `undoCancelConf` (`id` INT UNSIGNED) RETURNS CHAR(64) CHARSET utf8mb4 begin
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
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `adminacc`
--

CREATE TABLE `adminacc` (
  `username` varbinary(255) NOT NULL,
  `pass` varbinary(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `adminacc`
--

INSERT INTO `adminacc` (`username`, `pass`) VALUES
(0x61646d696e, 0x39616631356233333665366139363139393238353337646633306232653661323337363536396663663964376537373365636365646536353630363532396130),
(0x68656c6c6f, 0x30336163363734323136663365313563373631656531613565323535663036373935333632336338623338386234343539653133663937386437633834366634),
(0x6e657741646d696e, 0x30666665316162643161303832313533353363323333643665303039363133653935656563343235333833326137363161663238666633376163356131353063),
(0xd8a7d8afd985db8cd986, 0x30336163363734323136663365313563373631656531613565323535663036373935333632336338623338386234343539653133663937386437633834366634);

-- --------------------------------------------------------

--
-- Table structure for table `conference`
--

CREATE TABLE `conference` (
  `id` int(10) UNSIGNED NOT NULL,
  `request_number` varchar(255) NOT NULL,
  `request_sentDate` date NOT NULL,
  `topic` varchar(255) NOT NULL,
  `start_Date` date NOT NULL,
  `start_time` time NOT NULL DEFAULT '08:00:00',
  `end_time` time NOT NULL DEFAULT '08:00:00',
  `placeId` int(10) UNSIGNED DEFAULT NULL,
  `hostId` int(10) UNSIGNED DEFAULT NULL,
  `platformId` int(10) UNSIGNED DEFAULT NULL,
  `supporterId` int(10) UNSIGNED DEFAULT NULL,
  `isCanceled` tinyint(1) DEFAULT 0,
  `isHost` tinyint(1) DEFAULT 1,
  `confDesc` text DEFAULT NULL,
  `confGuests` text DEFAULT NULL
) ;

--
-- Dumping data for table `conference`
--

INSERT INTO `conference` (`id`, `request_number`, `request_sentDate`, `topic`, `start_Date`, `start_time`, `end_time`, `placeId`, `hostId`, `platformId`, `supporterId`, `isCanceled`, `isHost`, `confDesc`, `confGuests`) VALUES
(13, '3333', '2020-09-05', 'تست اشغال میزبان', '2020-09-05', '10:18:00', '11:17:00', 1, 3, 1, 1, 0, 1, '', ''),
(14, '4444', '2020-09-05', 'تست مهمان 1', '2020-09-05', '10:24:00', '11:24:00', 4, 2, 5, 8, 0, 0, 'موفق', ' '),
(16, '1111', '2020-09-05', 'تست ', '2020-09-05', '10:53:00', '11:53:00', 5, 1, 1, 8, 0, 1, '', ''),
(18, '5555', '2020-09-07', 'مهمان دوشنبه', '2020-09-07', '07:55:00', '08:55:00', 2, 11, 4, 2, 0, 0, '', ' '),
(20, '8448', '2020-09-13', 'یکشنبه', '2020-09-13', '07:51:00', '08:51:00', 1, 10, 1, 13, 0, 1, '', ''),
(21, '9663', '2020-09-13', 'اشغال؟', '2020-09-13', '07:52:00', '08:52:00', 2, 12, 1, 13, 0, 1, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `hosts`
--

CREATE TABLE `hosts` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `manager` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `hosts`
--

INSERT INTO `hosts` (`id`, `name`, `manager`) VALUES
(12, 'دفتر فناوری', 'جناب آقای'),
(1, 'دفتر فناوری', 'ریاست'),
(10, 'دفتر فناوری', 'معاون'),
(8, 'شرکت ...', 'آقای رئیس'),
(7, 'شرکت ...', 'رئیس و معاون'),
(11, 'شرکت ...', 'ریاست'),
(2, 'شرکت پالایش', 'رئیس شرکت'),
(9, 'شرکت پالایش', 'ریاست'),
(3, 'میزبان', 'معاون');

-- --------------------------------------------------------

--
-- Table structure for table `logins`
--

CREATE TABLE `logins` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varbinary(255) NOT NULL,
  `login_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `logins`
--

INSERT INTO `logins` (`id`, `username`, `login_time`) VALUES
(1, 0x61646d696e, '2020-09-13 02:54:38'),
(2, 0x6e657741646d696e, '2020-09-14 07:44:35');

-- --------------------------------------------------------

--
-- Table structure for table `place`
--

CREATE TABLE `place` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `isEmpty` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `place`
--

INSERT INTO `place` (`id`, `name`, `isEmpty`) VALUES
(1, 'سازمان راهداری', 1),
(2, 'اتاق کنفرانس', 1),
(3, 'طبقه 1', 1),
(4, 'اتاق جلسه', 1),
(5, 'طبقه 2', 1),
(6, 'اتاق 1', 1);

-- --------------------------------------------------------

--
-- Table structure for table `platform`
--

CREATE TABLE `platform` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `url` varchar(2048) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `platform`
--

INSERT INTO `platform` (`id`, `name`, `url`, `description`) VALUES
(1, ' ', ' ', ' '),
(2, 'Skype', 'Skype.com', 'اسکایپ'),
(3, 'zoom', 'zoom.com', 'زوم'),
(4, 'Skype', 'Skype.com', 'اسکایپ بیزینس'),
(5, 'google meet', 'googlemeet.com', 'گوگل میت'),
(6, 'zoom', 'Skype.com', '');

-- --------------------------------------------------------

--
-- Table structure for table `supporter`
--

CREATE TABLE `supporter` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `telephone` varchar(16) NOT NULL
) ;

--
-- Dumping data for table `supporter`
--

INSERT INTO `supporter` (`id`, `name`, `telephone`) VALUES
(1, 'جناب ...', '0912'),
(2, 'جناب آقای ...', '09121234567'),
(3, 'محمدی', '0912'),
(7, 'خانم ...', '09124567893'),
(8, 'محمدی', '09123451223'),
(9, 'خانم ...', '0912'),
(13, 'جناب اکبری', '0912');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `adminacc`
--
ALTER TABLE `adminacc`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `conference`
--
ALTER TABLE `conference`
  ADD PRIMARY KEY (`id`),
  ADD KEY `request_number` (`request_number`,`topic`),
  ADD KEY `hostId` (`hostId`),
  ADD KEY `supporterId` (`supporterId`),
  ADD KEY `platformId` (`platformId`),
  ADD KEY `placeId` (`placeId`);

--
-- Indexes for table `hosts`
--
ALTER TABLE `hosts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`,`manager`);

--
-- Indexes for table `logins`
--
ALTER TABLE `logins`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`);

--
-- Indexes for table `place`
--
ALTER TABLE `place`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`);

--
-- Indexes for table `platform`
--
ALTER TABLE `platform`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`);

--
-- Indexes for table `supporter`
--
ALTER TABLE `supporter`
  ADD PRIMARY KEY (`id`,`name`),
  ADD KEY `id` (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `conference`
--
ALTER TABLE `conference`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hosts`
--
ALTER TABLE `hosts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `logins`
--
ALTER TABLE `logins`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `place`
--
ALTER TABLE `place`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `platform`
--
ALTER TABLE `platform`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `supporter`
--
ALTER TABLE `supporter`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `conference`
--
ALTER TABLE `conference`
  ADD CONSTRAINT `conference_ibfk_1` FOREIGN KEY (`hostId`) REFERENCES `hosts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `conference_ibfk_2` FOREIGN KEY (`supporterId`) REFERENCES `supporter` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `conference_ibfk_3` FOREIGN KEY (`platformId`) REFERENCES `platform` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `conference_ibfk_4` FOREIGN KEY (`placeId`) REFERENCES `place` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `logins`
--
ALTER TABLE `logins`
  ADD CONSTRAINT `logins_ibfk_1` FOREIGN KEY (`username`) REFERENCES `adminacc` (`username`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
