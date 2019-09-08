
use latest;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `latest`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `BuyingTicket` (IN `ticketId` INT, IN `customerId` INT)  BEGIN

DECLARE priceTicket float DEFAULT 0;
DECLARE priceTicketAirline float DEFAULT 0;
DECLARE AirLineID float DEFAULT 0;
DECLARE tmp_deposit float DEFAULT 0;
DECLARE tmp_withdraw float DEFAULT 0;
DECLARE currentAmount float DEFAULT 0;
DECLARE FinalpriceTicket float DEFAULT 0;
DECLARE AmountFlag bool DEFAULT 0;
SELECT trip.price INTO priceTicket FROM ticket INNER JOIN trip ON ticket.tripid = trip.tripid WHERE ticket.ticketid=ticketId LIMIT 1;
SET FinalpriceTicket =((priceTicket*9)/100)+priceTicket;

SELECT SUM(amount) INTO tmp_deposit FROM transaction_customer WHERE transaction_customer.customer_id=customerId AND deposite=0;
IF(tmp_deposit IS NULL) THEN
        SET tmp_deposit=0;
END IF;
SELECT SUM(amount) INTO tmp_withdraw FROM transaction_customer WHERE transaction_customer.customer_id=customerId AND deposite=1;
IF(tmp_withdraw IS NULL) THEN
        SET tmp_withdraw=0;
END IF;
SET currentAmount =tmp_deposit-tmp_withdraw;
IF (currentAmount < FinalpriceTicket) THEN
	SET AmountFlag=1;
END IF;
IF (AmountFlag != 1) THEN
	call latest.withdrawCustomer(customerId,FinalpriceTicket);
    SELECT trip.ALid INTO AirLineID FROM ticket INNER JOIN trip ON ticket.tripid=trip.tripid LIMIT 1;
    
    SET priceTicketAirline=(priceTicket *98) / 100;
    INSERT buy (customerid,buytime,rahgiri,ticketId)
		VALUE (customerId,NOW(), FLOOR(RAND() * 4000) + 1000,ticketId);
	INSERT transaction_airlinecompnay(registerdate,amount,description,buyid,airline_id)
		VALUE (NOW(),priceTicketAirline,"Selling Ticket",LAST_INSERT_ID(),AirLineID);
	SELECT AmountFlag,currentAmount,FinalpriceTicket,tmp_withdraw,tmp_deposit,'enter';
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Checkout` (IN `airlineid` INT)  BEGIN
SELECT buy.rahgiri,buy.buytime,transaction_airlinecompnay.amount FROM transaction_airlinecompnay INNER JOIN buy
ON buy.buyid=transaction_airlinecompnay.buyid
WHERE transaction_airlinecompnay.airline_id =airlineid;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckoutSUM` (IN `airlineid` INT)  BEGIN
DECLARE SUMRECORD FLOAT;
DECLARE DATELAST DATE;
SELECT date INTO DATELAST FROM checkout_airline WHERE airlineid=checkout_airline.airlineid ORDER BY idcheckout_airline LIMIT 1;
SELECT SUM(transaction_airlinecompnay.amount) INTO SUMRECORD FROM transaction_airlinecompnay 
WHERE transaction_airlinecompnay.airline_id=airlineid AND transaction_airlinecompnay.registerdate > DATELAST;

INSERT checkout_airline(sum,date,rahgiri,airlineid)
VALUE (SUMRECORD,NOW(),FLOOR(RAND() * 4000) + 1000,airlineid);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DepositCustomer` (IN `customerId` INT, IN `price` FLOAT)  BEGIN
INSERT transaction_customer (registerdate,amount,deposite,description,customer_id)
VALUE (NOW(),price,0,'deposite',customerId);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `withdrawCustomer` (IN `customerId` INT, IN `price` FLOAT)  BEGIN
INSERT transaction_customer (registerdate,amount,deposite,description,customer_id)
VALUE (NOW(),price,1,'Withdrawal',customerId);
IF price >= 100000 THEN 
	INSERT transaction_customer (registerdate,amount,deposite,description,customer_id)
	VALUE (NOW(),10000,0,'gift',customerId);
END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `airlinecompany`
--

CREATE TABLE `airlinecompany` (
  `ALid` int(11) NOT NULL ,
  `airLineName` varchar(45) DEFAULT NULL,
  `registerDate` datetime DEFAULT NULL,
  `branchName` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `phone` char(10) DEFAULT NULL,
  `managerFirstName` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `managerLastName` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `address` varchar(500) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `airlinecompany`
--

INSERT INTO `airlinecompany` (`ALid`, `airLineName`, `registerDate`, `branchName`, `phone`, `managerFirstName`, `managerLastName`, `address`) VALUES
(0, '1', '2012-12-11', NULL, NULL, NULL, NULL, NULL),
(8, 'de', '2012-12-11', NULL, NULL, NULL, NULL, NULL),
(11, 'de', '2012-12-11', NULL, NULL, NULL, NULL, NULL);



#drop trigger update_airlinecompany;
DELIMITER $$


Create trigger update_airlinecompany after update on airlinecompany
FOR EACH ROW
BEGIN
    IF (NEW.airlinename != OLD.airlinename) THEN
        INSERT INTO update_airlinecompany 
            (alid , field , old_value , new_value , modified ) 
        VALUES 
            (old.alid, "airLineName", OLD.airlinename, NEW.airlinename, NOW());
    END IF;
    IF (NEW.registerdate != OLD.registerdate) THEN
        INSERT INTO update_arilinecompany
            (alid , field , old_value , new_value , modified ) 
        VALUES 
            (old.alid, "registerdate", OLD.registerdate, NEW.registerdate, NOW());
    END IF;
END$$

DELIMITER ;


create table `deleted_airlines`(
	`oldAlid` int(11) not null,
    `oldregisterDate` datetime default null,
    `oldairLineName` varchar(45) default null,
    `modifieddate` date);
DELIMITER $$
create trigger `deleted_airlinecompany` after delete on `airlinecompany` for each row begin
	set@old_id=OLD.ALid;
    set@old_registerDate=OLD.registerDate;
    set@old_airLineName=OLD.airLineName;
    insert into deleted_airlines
    values (@old_id,@old_registerDate,@old_airLineName,Now());    
    END
$$
DELIMITER ;
--
-- Table structure for table `airlinecompany_tel`
--

CREATE TABLE `airlinecompany_tel` (
  `ALid` int(11) NOT NULL,
  `tel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `airplane`
--

CREATE TABLE `airplane` (
  `airplanename` varchar(45) NOT NULL,
  `capacity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `airplane`
--

INSERT INTO `airplane` (`airplanename`, `capacity`) VALUES
('irair2', 200),
('irair4', 200),
('iran1', 350);

-- --------------------------------------------------------

--
-- Table structure for table `branch`
--

CREATE TABLE `branch` (
  `address` varchar(45) DEFAULT NULL,
  `firstName` varchar(45) DEFAULT NULL,
  `LastName` varchar(45) DEFAULT NULL,
  `ALid` int(11) DEFAULT NULL,
  `branchid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `branch_delete` (
  `old_ALid` int(11) NOT NULL,
  `old_branchid` int(11) NOT NULL,
  `old_firstname` varchar(45) DEFAULT NULL,
  `old_lastname` varchar(45) DEFAULT NULL,
  `old_address` varchar(45) DEFAULT NULL,
  `deleteddate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
DELIMITER $$
CREATE TRIGGER `branch_AFTER_DELETE` AFTER DELETE ON `branch` FOR EACH ROW BEGIN
	SET @old_ALid = OLD.ALid;
    SET @old_branchid=OLD.branchid;
	SET @old_firstname = OLD.firstname;
	SET @old_lastname = OLD. lastname;
    SET @old_address=OLD.address;
	INSERT INTO branch_delete
    
	VALUES (@old_ALid,@old_branchid,@old_firstname,@old_lastname,@old_address,NOW());
END
$$
DELIMITER ;

create table update_branch(
tracking_id int auto_increment primary key,
alid int,
branchid int,
field varchar(45),
old_value varchar(45),
new_value varchar(45),
modified datetime);

DELIMITER $$


Create trigger update_branch after update on branch
FOR EACH ROW
BEGIN
    IF (NEW.firstname != OLD.firstname) THEN
        INSERT INTO update_branch
            (alid,branchid , field , old_value , new_value , modified ) 
        VALUES 
            (old.alid,old.branchid, "firstname", OLD.firstname, NEW.firstname, NOW());
    END IF;
    IF (NEW.lastname != OLD.lastname) THEN
        INSERT INTO update_branch
            (alid ,branchid, field , old_value , new_value , modified ) 
        VALUES 
            (old.alid,old.branchid, "lastname", OLD.lastname, NEW.lastname, NOW());
    END IF;
	IF (NEW.address != OLD.address) THEN
        INSERT INTO update_branch
            (alid ,branchid, field , old_value , new_value , modified ) 
        VALUES 
            (old.alid,old.branchid, "address", OLD.address, NEW.address, NOW());
    END IF;
END$$

DELIMITER ;
/*update branch
set address="niyavaran"
where branchid=123;*/
-- --------------------------------------------------------

--
-- Table structure for table `branch_tel`
--

CREATE TABLE `branch_tel` (
  `branchid` int(11) NOT NULL,
  `tel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `buy`
--

CREATE TABLE `buy` (
  `customerid` int(11) DEFAULT NULL,
  `buyid` int(11) NOT NULL,
  `buytime` datetime DEFAULT NULL,
  `rahgiri` int(11) DEFAULT NULL,
  `ticketId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `buy`
--

INSERT INTO `buy` (`customerid`, `buyid`, `buytime`, `rahgiri`, `ticketId`) VALUES
(0, 0, '2018-01-16 19:41:14', 3131, 11),
(11, 11, '2012-12-11 12:12:12', 123456, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `chartertrip`
--
CREATE TABLE `chartertrip` (
  `charterid` int(11) NOT NULL,
  `tripid` int(11) DEFAULT NULL,
  `goingtime` time DEFAULT NULL,
  `backingtime` time DEFAULT NULL,
  `goinglenghttime` time DEFAULT NULL,
  `backinglenghttime` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `checkout_airline`
--

CREATE TABLE `checkout_airline` (
  `idcheckout_airline` int(11) NOT NULL,
  `sum` float DEFAULT NULL,
  `date` date DEFAULT NULL,
  `rahgiri` int(11) DEFAULT NULL,
  `airlineid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `communicationteam`
--

CREATE TABLE `communicationteam` (
  `ct_id` int(11) DEFAULT NULL,
  `firstName` varchar(45) DEFAULT NULL,
  `LastName` varchar(45) DEFAULT NULL,
  `enrollmentnum` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `communicationteam`
--

INSERT INTO `communicationteam` (`ct_id`, `firstName`, `LastName`, `enrollmentnum`, `status`) VALUES
(46, '1', '1', 46, 0);

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

CREATE TABLE `company` (
  `enrollmentnum` int(11) NOT NULL,
  `comapanyname` varchar(45) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `registerno` varchar(45) DEFAULT NULL,
  `phone` varchar(45) DEFAULT NULL,
  `perosn` varchar(45) DEFAULT NULL,
  `personno` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`enrollmentnum`, `comapanyname`, `address`, `registerno`, `phone`, `perosn`, `personno`) VALUES
(46, '1', '4', '2', '3', '5', '6');


create table company_tracking(
enrollmentnum int(11),
field varchar(45),
old_address varchar(45),
new_address varchar(45),
modified datetime);


#insert into company values (12,"taban","resalat");


#insert into company values(13,"mahan","aghda");
DELIMITER $$


CREATE TRIGGER update_company AFTER UPDATE on company
FOR EACH ROW
BEGIN
    IF (NEW.address != OLD.address) THEN
        INSERT INTO company_tracking 
    ( enrollmentnum, field , old_address , new_address , modified ) 
        VALUES 
    (NEW.enrollmentnum, "address", OLD.address, NEW.address, NOW());
    END IF;
END$$

DELIMITER ;


-- --------------------------------------------------------

--
-- Table structure for table `company_tel`
--

CREATE TABLE `company_tel` (
  `enrollmentnum` int(11) NOT NULL,
  `tel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `complaint`
--

CREATE TABLE `complaint` (
  `complaintid` int(11) NOT NULL,
  `stid` int(11) DEFAULT NULL,
  `subjectComplaint` varchar(45) DEFAULT NULL,
  `customerid` int(11) DEFAULT NULL,
  `sendTime` datetime DEFAULT NULL,
  `answertime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customerid` int(11) NOT NULL,
  `firstname` varchar(45) DEFAULT NULL,
  `lastname` varchar(45) DEFAULT NULL,
  `nationalcode` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `fathername` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `birthcity` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `birthdate` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `acountno` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `phone` varchar(500) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customerid`, `firstname`, `lastname`, `nationalcode`, `fathername`, `birthcity`, `birthdate`, `acountno`, `phone`) VALUES
(0, 'faraz', 'jalili', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 'ali', 'maleki', NULL, NULL, NULL, NULL, NULL, NULL),
(33, '1', '2', '3', '4', '5', '6', '7', '8');

--
-- Triggers `customer`
--
DELIMITER $$
CREATE TRIGGER `customer_AFTER_DELETE` AFTER DELETE ON `customer` FOR EACH ROW BEGIN
	SET @old_id = OLD.customerid;
	SET @old_firstname = OLD.firstname;
	SET @old_lastname = OLD. lastname;
	INSERT INTO customer_delete
    
	VALUES (@old_id,@old_firstname,@old_lastname,NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `customer_AFTER_UPDATE` AFTER UPDATE ON `customer` FOR EACH ROW BEGIN
	   SET @old_id = OLD.customerid;
	   SET @new_id = NEW.customerid;
       
	   SET @old_firstname = OLD.firstname;
	   SET @new_firstname = NEW.firstname;
       
	   SET @old_lastname = OLD. lastname;
	   SET @new_lastname = NEW.lastname;
       INSERT INTO logcustomer
	    VALUES (@old_id, @new_id, @old_firstname, @new_firstname,@old_lastname,@new_lastname,NOW());
END
$$
DELIMITER ;

--
-- Table structure for table `logcustomer`
--


CREATE TABLE `registered_customer` (
  `rc_id` int(11) NOT NULL,
  `ssn` int(11) DEFAULT NULL,
  `customerid` int(11) DEFAULT NULL,
  `fathername` varchar(45) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `birthplace` varchar(45) DEFAULT NULL,
  `accountnumber` int(11) DEFAULT NULL,
  `timeRegistered` datetime DEFAULT NULL,
  `paidway` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `logRegisteredcustomer` (
  `idlogRegisteredcustomer` int(11) NOT NULL,
  `old_id` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `new_id` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `old_fathername` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `new_fathername` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `old_birthplace` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `new_birthplace` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `old_birthdate` datetime,
  `new_birthdate` datetime,
  accountnumber int,
  paidway varchar(45) check( paidway="online" or paidway= "account"),
  `changedate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DELIMITER $$
CREATE TRIGGER `registeredCustomer_AFTER_UPDATE` AFTER UPDATE ON registered_customer FOR EACH ROW BEGIN
	   SET @old_id = OLD.rc_id;
       
	   SET @old_fathername = OLD.fathername;
	   SET @new_fathername = NEW.fathername;
       
	   SET @old_birthplace = OLD. birthplace;
	   SET @new_birthplace = NEW.birthplace;
       
	   SET @old_birthdate = OLD. birthdate;
	   SET @new_birthdate = NEW.birthdate;
       
       set @old_accountnumber=old.accountnumber;
        set @new_accountnumber=new.accountnumber;
        
        set @old_paidway=old.paidway;
        set @new_paidway=new.paidway;
       
       INSERT INTO logcustomer
	    VALUES (@old_id, @old_fathername,@new_fathername, @old_birthplace,@new_birthplace,@old_birthdate,@new_birthdate,NOW());
END
$$
DELIMITER ;


-- --------------------------------------------------------

--
-- Table structure for table `customer_add`
--

CREATE TABLE `customer_add` (
  `customerid` int(11) NOT NULL,
  `address` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `customer_tels`
--

CREATE TABLE `customer_tels` (
  `customerid` int(11) NOT NULL,
  `tel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `cutomer_delete`
--

CREATE TABLE `cutomer_delete` (
  `idcutomer_delete` int(11) NOT NULL,
  `id` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `firstname` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `lastname` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `registerdate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `enrollmentnum` int(11) NOT NULL,
  `personalnum` int(11) NOT NULL,
  `customerid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `employee_tel`
--

CREATE TABLE `employee_tel` (
  `enrollmentnum` int(11) NOT NULL,
  `personalnum` int(11) NOT NULL,
  `tel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `logcustomer`
--

CREATE TABLE `logcustomer` (
  `idlogcustomer` int(11) NOT NULL,
  `old_id` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `new_id` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `old_firstname` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `new_firstname` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `old_lastname` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `new_lastname` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `changedate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `mainoffice`
--

CREATE TABLE `mainoffice` (
  `officeid` int(11) NOT NULL,
  `firstname` varchar(45) DEFAULT NULL,
  `lastName` varchar(45) DEFAULT NULL,
  `address` varchar(45) DEFAULT NULL,
  `ALid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mainoffice_delete` (
  `old_ALid` int(11) NOT NULL,
  `old_officeid` int(11) NOT NULL,
  `old_firstname` varchar(45) DEFAULT NULL,
  `old_lastname` varchar(45) DEFAULT NULL,
  `old_address` varchar(45) DEFAULT NULL,
  `deleteddate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
DELIMITER $$
CREATE TRIGGER `mainoffice_AFTER_DELETE` AFTER DELETE ON `mainoffice` FOR EACH ROW BEGIN
	SET @old_ALid = OLD.ALid;
    SET @old_officeid=OLD.officeid;
	SET @old_firstname = OLD.firstname;
	SET @old_lastname = OLD. lastname;
    SET @old_address=OLD.address;
	INSERT INTO mainoffice_delete
    
	VALUES (@old_ALid,@old_officeid,@old_firstname,@old_lastname,@old_address,NOW());
END
$$
DELIMITER ;
-- --------------------------------------------------------

--
-- Table structure for table `mainoffice_tel`
--

CREATE TABLE `mainoffice_tel` (
  `officeid` int(11) NOT NULL,
  `mainOffice_tel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `onewaytrip`
--

CREATE TABLE `onewaytrip` (
  `onewaytrip` int(11) NOT NULL,
  `tripid` int(11) DEFAULT NULL,
  `triptime` datetime DEFAULT NULL,
  `triplenghttime` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `onlineanswer`
--

CREATE TABLE `onlineanswer` (
  `answerid` int(11) NOT NULL,
  `customerid` int(11) DEFAULT NULL,
  `sendTime` datetime DEFAULT NULL,
  `answertime` datetime DEFAULT NULL,
  `stid` int(11) DEFAULT NULL,
  `subjectComplaint` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

CREATE TABLE `registeredcustomer_delete` (
  `old_rc_id` int(11) NOT NULL,
  `old_ssn` int(11) default NULL,
  `old_customerid` int(11) DEFAULT NULL,
  `old_fathername` varchar(45) DEFAULT NULL,
  `old_birthdate` date DEFAULT NULL,
  `old_accountnumber` int(11) default NULL,
  `old_timeRegistered` datetime DEFAULT NULL,
  `old_paidway` varchar(45),
  `modified` datetime default null
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



DELIMITER $$
CREATE TRIGGER `registered_customer_AFTER_DELETE` AFTER DELETE ON `registered_customer` FOR EACH ROW BEGIN
	SET @old_rc_id = OLD.rc_id;
	SET @old_ssn = OLD.ssn;
	SET @old_customerid = OLD.customerid;
	SET @old_fathername = OLD.fathername;
	SET @old_birthdate = OLD.birthdate;
	SET @old_birthplace = OLD.birthplace;
    SET @old_accountnumber=OLD.accountnumber;
    SET @old_timeRegistered=OLD.timeRegistered;
    SET @old_paidway=OLD.paidway;
	INSERT INTO registeredcustomer_delete
    
	VALUES (@old_rc_id,@old_ssn,@old_customerid,@old_fathername,@old_birthdate,@old_birthplace,@old_accountnumber,@old_timeRegistered,@old_paidway,NOW());
END
$$
DELIMITER ;
-- --------------------------------------------------------

--
-- Table structure for table `rejecetedtrips`
--

CREATE TABLE `rejecetedtrips` (
  `id` int(11) NOT NULL,
  `description` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `tripId` int(11) DEFAULT NULL,
  `rejecetedtripscol` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `specialist`
--

CREATE TABLE `specialist` (
  `specialistssn` int(11) NOT NULL,
  `firstname` varchar(45) DEFAULT NULL,
  `lastname` varchar(45) DEFAULT NULL,
  `nationalcode` varchar(45) DEFAULT NULL,
  `phone` varchar(45) DEFAULT NULL,
  `address` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `specialist`
--

INSERT INTO `specialist` (`specialistssn`, `firstname`, `lastname`, `nationalcode`, `phone`, `address`) VALUES
(8, 'fewf', 'de', NULL, NULL, NULL),
(11, 'fewf', 'de', NULL, NULL, NULL),
(44, '1', '2', '3', '4', '5');

-- --------------------------------------------------------

--
-- Table structure for table `specialist_address`
--

CREATE TABLE `specialist_address` (
  `specialistssn` int(11) NOT NULL,
  `address` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `specialist_tels`
--

CREATE TABLE `specialist_tels` (
  `tel` int(11) NOT NULL,
  `specialistssn` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `supportteam`
--

CREATE TABLE `supportteam` (
  `stid` int(11) NOT NULL,
  `firstname` varchar(45) DEFAULT NULL,
  `lastname` varchar(45) DEFAULT NULL,
  `onOroff` varchar(45) DEFAULT NULL,
  `lastOnline` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `supportteam`
--
create table `supportteam_tracking`(
 `trackingid` int auto_increment primary key,
 `stid` int(11) not null,
 `field` varchar(45),
  `oldvalue` varchar(45),
  `newvalue` varchar(45),
  `lastonnline` datetime,
  `rightnow` varchar(45));
  
DELIMITER $$
CREATE TRIGGER `supportteam_AFTER_UPDATE` AFTER UPDATE ON `supportteam` FOR EACH ROW BEGIN
if (new.onOroff="on" and old.onOroff="off") then
insert into supportteam_tracking (stid,field,oldvalue,newvalue,lastonline,rightnow)values
(old.stid,"Onoroff",old.onOroff, new.onOroff, null,"right now");
end if;
if (new.onOroff="off" and old.onOroff="on") then
insert into supportteam_tracking(stid, field,oldvalue,newvalue,lastonline,rightnow) values
(old.stid,"Onoroff",old.onOroff,new.onOroff,now(),null);
end if;
END;
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ticket`
--

CREATE TABLE `ticket` (
  `specialistssn` int(11) DEFAULT NULL,
  `tripid` int(11) DEFAULT NULL,
  `ticketid` int(11) NOT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ticket`
--

INSERT INTO `ticket` (`specialistssn`, `tripid`, `ticketid`) VALUES
(11, 11, 11);

-- --------------------------------------------------------

--
-- Table structure for table `transaction_airlinecompnay`
--

CREATE TABLE `transaction_airlinecompnay` (
  `idtransaction_airlinecompnay` int(11) NOT NULL,
  `registerdate` date DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `description` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `buyid` int(11) DEFAULT NULL,
  `airline_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `transaction_customer`
--

CREATE TABLE `transaction_customer` (
  `idtransaction_user` int(11) NOT NULL,
  `registerdate` date DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `deposite` tinyint(4) DEFAULT NULL,
  `description` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `transaction_customer`
--

INSERT INTO `transaction_customer` (`idtransaction_user`, `registerdate`, `amount`, `deposite`, `description`, `customer_id`) VALUES
(5, '2018-01-16', 120000, 0, 'deposite', 0),
(7, '2018-01-16', 10000, 0, 'gift', 0),
(8, '2018-01-16', 10000, 1, 'Withdrawal', 0),
(9, '2018-01-16', 130.8, 1, 'Withdrawal', 0),
(10, '2018-01-16', 130.8, 1, 'Withdrawal', 0),
(11, '2018-01-17', 130.8, 1, 'Withdrawal', 0);

-- --------------------------------------------------------

--
-- Table structure for table `trip`
--

CREATE TABLE `trip` (
  `tripid` int(11) NOT NULL,
  `origin` varchar(45) DEFAULT NULL,
  `destination` varchar(45) DEFAULT NULL,
  `class` varchar(45) DEFAULT NULL,
  `airplanename` varchar(45) DEFAULT NULL,
  `pilotname` varchar(45) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `ALid` int(11) DEFAULT NULL ,
  `hourflight` varchar(45) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `type` tinyint(4) DEFAULT NULL,
  `tripcol` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `trip`
--

INSERT INTO `trip` (`tripid`, `origin`, `destination`, `class`, `airplanename`, `pilotname`, `price`, `ALid`, `hourflight`, `capacity`, `type`, `tripcol`) VALUES
(11, 'dddd', 'd', 'businuss', 'irair4', 'de', '120.00', 8, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `unregistered_customer`
--

CREATE TABLE `unregistered_customer` (
  `unc_id` int(11) NOT NULL,
  `customerid` int(11) DEFAULT NULL,
  `ssn` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `updatedstatus`
--

CREATE TABLE `updatedstatus` (
  `idupdatedstatus` int(11) NOT NULL,
  `verificationStatusNEW` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `verificationStatusOLD` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `tripid` int(11) DEFAULT NULL,
  `dateupdated` datetime
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `verificationemployeebycommunicationteam`
--

CREATE TABLE `verificationemployeebycommunicationteam` (
  `enrollmentnum` int(11) NOT NULL,
  `ct_id` int(11) NOT NULL,
  `verificationStatus` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `verificationtripbyspecialist`
--

CREATE TABLE `verificationtripbyspecialist` (
  `verificationStatus` varchar(45) DEFAULT NULL,
  `specialistssn` int(11) NOT NULL,
  `tripid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `verificationtripbyspecialist`
--

INSERT INTO `verificationtripbyspecialist` (`verificationStatus`, `specialistssn`, `tripid`) VALUES
('1', 11, 11);

--
-- Triggers `verificationtripbyspecialist`
--

DELIMITER $$
CREATE TRIGGER `verificationtripbyspecialist_AFTER_UPDATE` AFTER UPDATE ON `verificationtripbyspecialist` FOR EACH ROW BEGIN
   SET @new = NEW.verificationStatus;
   SET @ss = NEW.specialistssn;
   SET @tripid = NEW.tripid;
   INSERT INTO updatedstatus VALUES (NEW.verificationStatus,OLD.verificationStatus,NEW.tripid,now());
   IF ( @new = 'accepted') THEN
		INSERT ticket(specialistssn,tripid)
		VALUE (@ss,@tripid);
	ELSE 
		INSERT rejecetedtrips(description,tripId)
		VALUE ('rejected',@tripid);
    
   END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `airlinecompany`
--
ALTER TABLE `airlinecompany`
  ADD PRIMARY KEY (`ALid`);

--
-- Indexes for table `airlinecompany_tel`
--
ALTER TABLE `airlinecompany_tel`
  ADD PRIMARY KEY (`ALid`,`tel`);

--
-- Indexes for table `airplane`
--
ALTER TABLE `airplane`
  ADD PRIMARY KEY (`airplanename`);

--
-- Indexes for table `branch`
--
ALTER TABLE `branch`
  ADD PRIMARY KEY (`branchid`),
  ADD KEY `ALid` (`ALid`);

--
-- Indexes for table `branch_tel`
--
ALTER TABLE `branch_tel`
  ADD PRIMARY KEY (`branchid`,`tel`);

--
-- Indexes for table `buy`
--
ALTER TABLE `buy`
  ADD PRIMARY KEY (`buyid`),
  ADD KEY `customerid` (`customerid`);

--
-- Indexes for table `chartertrip`
--
ALTER TABLE `chartertrip`
  ADD PRIMARY KEY (`charterid`),
  ADD KEY `tripid` (`tripid`);

--
-- Indexes for table `checkout_airline`
--
ALTER TABLE `checkout_airline`
  ADD PRIMARY KEY (`idcheckout_airline`);

--
-- Indexes for table `communicationteam`
--
ALTER TABLE `communicationteam`
  ADD KEY `enrollmentnum` (`enrollmentnum`);

--
-- Indexes for table `company`
--
ALTER TABLE `company`
  ADD PRIMARY KEY (`enrollmentnum`);

--
-- Indexes for table `company_tel`
--
ALTER TABLE `company_tel`
  ADD PRIMARY KEY (`enrollmentnum`,`tel`);

--
-- Indexes for table `complaint`
--
ALTER TABLE `complaint`
  ADD PRIMARY KEY (`complaintid`),
  ADD KEY `stid` (`stid`),
  ADD KEY `customerid` (`customerid`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customerid`);

--
-- Indexes for table `customer_add`
--
ALTER TABLE `customer_add`
  ADD PRIMARY KEY (`customerid`,`address`);

--
-- Indexes for table `customer_tels`
--
ALTER TABLE `customer_tels`
  ADD PRIMARY KEY (`customerid`,`tel`);

--
-- Indexes for table `cutomer_delete`
--
ALTER TABLE `cutomer_delete`
  ADD PRIMARY KEY (`idcutomer_delete`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`enrollmentnum`,`personalnum`),
  ADD KEY `customerid` (`customerid`);

--
-- Indexes for table `employee_tel`
--
ALTER TABLE `employee_tel`
  ADD PRIMARY KEY (`enrollmentnum`,`personalnum`,`tel`);

--
-- Indexes for table `logcustomer`
--
ALTER TABLE `logcustomer`
  ADD PRIMARY KEY (`idlogcustomer`);

--
-- Indexes for table `mainoffice`
--
ALTER TABLE `mainoffice`
  ADD PRIMARY KEY (`officeid`),
  ADD KEY `ALid` (`ALid`);

--
-- Indexes for table `mainoffice_tel`
--
ALTER TABLE `mainoffice_tel`
  ADD PRIMARY KEY (`officeid`,`mainOffice_tel`);

--
-- Indexes for table `onewaytrip`
--
ALTER TABLE `onewaytrip`
  ADD PRIMARY KEY (`onewaytrip`),
  ADD KEY `tripid` (`tripid`);

--
-- Indexes for table `onlineanswer`
--
ALTER TABLE `onlineanswer`
  ADD PRIMARY KEY (`answerid`),
  ADD KEY `stid` (`stid`),
  ADD KEY `customerid` (`customerid`);

--
-- Indexes for table `registered_customer`
--
ALTER TABLE `registered_customer`
  ADD PRIMARY KEY (`rc_id`),
  ADD KEY `customerid` (`customerid`);

--
-- Indexes for table `rejecetedtrips`
--
ALTER TABLE `rejecetedtrips`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `specialist`
--
ALTER TABLE `specialist`
  ADD PRIMARY KEY (`specialistssn`);

--
-- Indexes for table `specialist_address`
--
ALTER TABLE `specialist_address`
  ADD PRIMARY KEY (`specialistssn`,`address`);

--
-- Indexes for table `specialist_tels`
--
ALTER TABLE `specialist_tels`
  ADD PRIMARY KEY (`specialistssn`,`tel`);

--
-- Indexes for table `supportteam`
--
ALTER TABLE `supportteam`
  ADD PRIMARY KEY (`stid`);

--
-- Indexes for table `ticket`
--
ALTER TABLE `ticket`
  ADD PRIMARY KEY (`ticketid`),
  ADD KEY `specialistssn` (`specialistssn`,`tripid`);

--
-- Indexes for table `transaction_airlinecompnay`
--
ALTER TABLE `transaction_airlinecompnay`
  ADD PRIMARY KEY (`idtransaction_airlinecompnay`);

--
-- Indexes for table `transaction_customer`
--
ALTER TABLE `transaction_customer`
  ADD PRIMARY KEY (`idtransaction_user`),
  ADD KEY `customer_transaction_idx` (`customer_id`);

--
-- Indexes for table `trip`
--
ALTER TABLE `trip`
  ADD PRIMARY KEY (`tripid`),
  ADD KEY `ALid` (`ALid`),
  ADD KEY `airplanename` (`airplanename`);

--
-- Indexes for table `unregistered_customer`
--
ALTER TABLE `unregistered_customer`
  ADD PRIMARY KEY (`unc_id`),
  ADD KEY `customerid` (`customerid`);

--
-- Indexes for table `updatedstatus`
--
ALTER TABLE `updatedstatus`
  ADD PRIMARY KEY (`idupdatedstatus`);

--
-- Indexes for table `verificationemployeebycommunicationteam`
--
ALTER TABLE `verificationemployeebycommunicationteam`
  ADD PRIMARY KEY (`enrollmentnum`,`ct_id`);

--
-- Indexes for table `verificationtripbyspecialist`
--
ALTER TABLE `verificationtripbyspecialist`
  ADD PRIMARY KEY (`tripid`,`specialistssn`),
  ADD KEY `specialistssn` (`specialistssn`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `checkout_airline`
--
ALTER TABLE `checkout_airline`
  MODIFY `idcheckout_airline` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cutomer_delete`
--
ALTER TABLE `cutomer_delete`
  MODIFY `idcutomer_delete` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logcustomer`
--
ALTER TABLE `logcustomer`
  MODIFY `idlogcustomer` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rejecetedtrips`
--
ALTER TABLE `rejecetedtrips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transaction_airlinecompnay`
--
ALTER TABLE `transaction_airlinecompnay`
  MODIFY `idtransaction_airlinecompnay` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transaction_customer`
--
ALTER TABLE `transaction_customer`
  MODIFY `idtransaction_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `updatedstatus`
--
ALTER TABLE `updatedstatus`
  MODIFY `idupdatedstatus` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `airlinecompany_tel`
--
ALTER TABLE `airlinecompany_tel`
  ADD CONSTRAINT `branchid_tel_FK` FOREIGN KEY (`ALid`) REFERENCES `branch` (`ALid`);

--
-- Constraints for table `branch`
--
ALTER TABLE `branch`
  ADD CONSTRAINT `branch_ibfk_1` FOREIGN KEY (`ALid`) REFERENCES `airlinecompany` (`ALid`) ON DELETE CASCADE;

--
-- Constraints for table `branch_tel`
--
ALTER TABLE `branch_tel`
  ADD CONSTRAINT `branch_tel_FK` FOREIGN KEY (`branchid`) REFERENCES `branch` (`branchid`);

--
-- Constraints for table `buy`
--
ALTER TABLE `buy`
  ADD CONSTRAINT `buy_ibfk_1` FOREIGN KEY (`customerid`) REFERENCES `customer` (`customerid`),
  ADD CONSTRAINT `buy_ibfk_2` FOREIGN KEY (`ticketId`) REFERENCES `ticket` (`ticketid`) on delete cascade;
;

--
-- Constraints for table `chartertrip`
--
ALTER TABLE `chartertrip`
  ADD CONSTRAINT `chartertrip_ibfk_1` FOREIGN KEY (`tripid`) REFERENCES `trip` (`tripid`)on delete cascade ;

--
-- Constraints for table `communicationteam`
--
ALTER TABLE `communicationteam`
  ADD CONSTRAINT `communicationteam_ibfk_1` FOREIGN KEY (`enrollmentnum`) REFERENCES `company` (`enrollmentnum`);

--
-- Constraints for table `company_tel`
--
ALTER TABLE `company_tel`
  ADD CONSTRAINT `company_tel_ibfk_1` FOREIGN KEY (`enrollmentnum`) REFERENCES `company` (`enrollmentnum`);

--
-- Constraints for table `complaint`
--
ALTER TABLE `complaint`
  ADD CONSTRAINT `complaint_ibfk_1` FOREIGN KEY (`stid`) REFERENCES `supportteam` (`stid`),
  ADD CONSTRAINT `complaint_ibfk_2` FOREIGN KEY (`customerid`) REFERENCES `customer` (`customerid`);

--
-- Constraints for table `customer_add`
--
ALTER TABLE `customer_add`
  ADD CONSTRAINT `customer_add_ibfk_1` FOREIGN KEY (`customerid`) REFERENCES `customer` (`customerid`);

--
-- Constraints for table `customer_tels`
--
ALTER TABLE `customer_tels`
  ADD CONSTRAINT `customer_tels_ibfk_1` FOREIGN KEY (`customerid`) REFERENCES `customer` (`customerid`);

--
-- Constraints for table `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`enrollmentnum`) REFERENCES `company` (`enrollmentnum`),
  ADD CONSTRAINT `employee_ibfk_2` FOREIGN KEY (`customerid`) REFERENCES `customer` (`customerid`);

--
-- Constraints for table `employee_tel`
--
ALTER TABLE `employee_tel`
  ADD CONSTRAINT `employee_tel_ibfk_1` FOREIGN KEY (`enrollmentnum`,`personalnum`) REFERENCES `employee` (`enrollmentnum`, `personalnum`);

--
-- Constraints for table `mainoffice`
--
ALTER TABLE `mainoffice`
  ADD CONSTRAINT `mainoffice_ibfk_1` FOREIGN KEY (`ALid`) REFERENCES `airlinecompany` (`ALid`);

--
-- Constraints for table `mainoffice_tel`
--
ALTER TABLE `mainoffice_tel`
  ADD CONSTRAINT `mainOffice_tel_fk` FOREIGN KEY (`officeid`) REFERENCES `mainoffice` (`officeid`);

--
-- Constraints for table `onewaytrip`
--
ALTER TABLE `onewaytrip`
  ADD CONSTRAINT `onewaytrip_ibfk_1` FOREIGN KEY (`tripid`) REFERENCES `trip` (`tripid`) on delete cascade;

--
-- Constraints for table `onlineanswer`
--
ALTER TABLE `onlineanswer`
  ADD CONSTRAINT `onlineanswer_ibfk_1` FOREIGN KEY (`stid`) REFERENCES `supportteam` (`stid`),
  ADD CONSTRAINT `onlineanswer_ibfk_2` FOREIGN KEY (`customerid`) REFERENCES `customer` (`customerid`);

--
-- Constraints for table `registered_customer`
--
ALTER TABLE `registered_customer`
  ADD CONSTRAINT `registered_customer_ibfk_1` FOREIGN KEY (`customerid`) REFERENCES `customer` (`customerid`);

--
-- Constraints for table `specialist_address`
--
ALTER TABLE `specialist_address`
  ADD CONSTRAINT `specialist_address_ibfk_1` FOREIGN KEY (`specialistssn`) REFERENCES `specialist` (`specialistssn`);

--
-- Constraints for table `specialist_tels`
--
ALTER TABLE `specialist_tels`
  ADD CONSTRAINT `specialist_tels_ibfk_1` FOREIGN KEY (`specialistssn`) REFERENCES `specialist` (`specialistssn`);

--
-- Constraints for table `ticket`
--
ALTER TABLE `ticket`
  ADD CONSTRAINT `ticket_ibfk_1` FOREIGN KEY (`specialistssn`,`tripid`) REFERENCES `verificationtripbyspecialist` (`specialistssn`, `tripid`) on delete cascade;

--
-- Constraints for table `transaction_customer`
--
ALTER TABLE `transaction_customer`
  ADD CONSTRAINT `customer_transaction` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customerid`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `trip`
--
ALTER TABLE `trip`
  ADD CONSTRAINT `trip_ibfk_1` FOREIGN KEY (`ALid`) REFERENCES `airlinecompany` (`ALid`) on delete cascade,
  ADD CONSTRAINT `trip_ibfk_2` FOREIGN KEY (`airplanename`) REFERENCES `airplane` (`airplanename`);

--
-- Constraints for table `unregistered_customer`
--
ALTER TABLE `unregistered_customer`
  ADD CONSTRAINT `unregistered_customer_ibfk_1` FOREIGN KEY (`customerid`) REFERENCES `customer` (`customerid`);

--
-- Constraints for table `verificationtripbyspecialist`
--
ALTER TABLE `verificationtripbyspecialist`
  ADD CONSTRAINT `verificationtripbyspecialist_ibfk_1` FOREIGN KEY (`tripid`) REFERENCES `trip` (`tripid`) on delete cascade,
  ADD CONSTRAINT `verificationtripbyspecialist_ibfk_2` FOREIGN KEY (`specialistssn`) REFERENCES `specialist` (`specialistssn`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;