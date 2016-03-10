-- MySQL Script generated by MySQL Workbench
-- St 9. březen 2016, 09:30:00 CET
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema cloudchatdb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema cloudchatdb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `cloudchatdb` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `cloudchatdb` ;

-- -----------------------------------------------------
-- Table `cloudchatdb`.`Registered_users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`Registered_users` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`Registered_users` (
  `userID` INT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(64) NOT NULL,
  `password` VARCHAR(4096) NOT NULL,
  `isActivated` TINYINT(1) NOT NULL DEFAULT 1,
  `create_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`User_settings`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`User_settings` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`User_settings` (
  `highlight_words` VARCHAR(1024) NULL DEFAULT 'nickname',
  `whois_username` VARCHAR(45) NULL DEFAULT 'user',
  `whois_realname` VARCHAR(45) NULL DEFAULT 'realname',
  `global_nickname` VARCHAR(45) NULL DEFAULT 'nickname',
  `show_joinpartquit_messages` TINYINT(1) NULL DEFAULT 1,
  `show_seconds` TINYINT(1) NULL DEFAULT 1,
  `show_video_previews` TINYINT(1) NULL DEFAULT 1,
  `show_image_previews` TINYINT(1) NULL DEFAULT 1,
  `Registred_users_userID` INT NOT NULL,
  INDEX `fk_User_settings_Registred_users_idx` (`Registred_users_userID` ASC),
  PRIMARY KEY (`Registred_users_userID`),
  CONSTRAINT `fk_User_settings_Registred_users`
    FOREIGN KEY (`Registred_users_userID`)
    REFERENCES `cloudchatdb`.`Registered_users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`IRC_servers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`IRC_servers` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`IRC_servers` (
  `serverID` INT NOT NULL AUTO_INCREMENT,
  `serverSessionID` INT NOT NULL,
  `nickname` VARCHAR(45) NULL COMMENT 'Custom server nickname in case the user doesn\'t want to use the global one.',
  `isAway` TINYINT(1) NULL,
  `isConnected` TINYINT(1) NOT NULL,
  `Registred_users_userID` INT NOT NULL,
  `serverName` VARCHAR(45) NOT NULL,
  `serverIP` VARCHAR(128) NOT NULL,
  `serverPort` INT NOT NULL DEFAULT '6667',
  `useSSL` TINYINT(1) NOT NULL DEFAULT 0,
  `serverPassword` VARCHAR(128) NULL,
  PRIMARY KEY (`serverID`, `Registred_users_userID`),
  INDEX `fk_IRC_servers_Registred_users1_idx` (`Registred_users_userID` ASC),
  CONSTRAINT `fk_IRC_servers_Registred_users1`
    FOREIGN KEY (`Registred_users_userID`)
    REFERENCES `cloudchatdb`.`Registered_users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`IRC_channels`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`IRC_channels` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`IRC_channels` (
  `channelID` INT NOT NULL AUTO_INCREMENT,
  `channelName` VARCHAR(45) NOT NULL,
  `channelPassword` VARCHAR(45) NULL,
  `isJoined` TINYINT(1) NOT NULL,
  `lastOpened` DATETIME NOT NULL,
  `IRC_servers_serverID` INT NOT NULL,
  PRIMARY KEY (`channelID`),
  INDEX `fk_IRC_channels_IRC_servers1_idx` (`IRC_servers_serverID` ASC),
  CONSTRAINT `fk_IRC_channels_IRC_servers1`
    FOREIGN KEY (`IRC_servers_serverID`)
    REFERENCES `cloudchatdb`.`IRC_servers` (`serverID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`User_data`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`User_data` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`User_data` (
  `lastLogin` DATETIME NULL,
  `lastLogoff` DATETIME NULL,
  `isSocketOn` TINYINT(1) NOT NULL,
  `Registred_users_userID` INT NOT NULL,
  PRIMARY KEY (`Registred_users_userID`),
  CONSTRAINT `fk_User_data_Registred_users1`
    FOREIGN KEY (`Registred_users_userID`)
    REFERENCES `cloudchatdb`.`Registered_users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`IRC_other_messages`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`IRC_other_messages` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`IRC_other_messages` (
  `messageID` INT NOT NULL AUTO_INCREMENT,
  `fromHostmask` VARCHAR(45) NOT NULL,
  `messageBody` VARCHAR(4096) NOT NULL,
  `commandType` VARCHAR(45) NOT NULL,
  `timeReceived` TIMESTAMP NOT NULL,
  `seen` TIMESTAMP NULL,
  `IRC_servers_serverID` INT NOT NULL,
  PRIMARY KEY (`messageID`),
  INDEX `fk_IRC_other_messages_IRC_servers1_idx` (`IRC_servers_serverID` ASC),
  CONSTRAINT `fk_IRC_other_messages_IRC_servers1`
    FOREIGN KEY (`IRC_servers_serverID`)
    REFERENCES `cloudchatdb`.`IRC_servers` (`serverID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`IRC_channel_messages`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`IRC_channel_messages` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`IRC_channel_messages` (
  `messageID` INT NOT NULL AUTO_INCREMENT,
  `fromHostmask` VARCHAR(45) NOT NULL,
  `messageBody` VARCHAR(4096) NOT NULL,
  `commandType` VARCHAR(45) NOT NULL,
  `timeReceived` TIMESTAMP NOT NULL,
  `seen` TIMESTAMP NULL,
  `IRC_channels_channelID` INT NOT NULL,
  PRIMARY KEY (`messageID`, `IRC_channels_channelID`),
  INDEX `fk_IRC_channel_messages_IRC_channels2_idx` (`IRC_channels_channelID` ASC),
  CONSTRAINT `fk_IRC_channel_messages_IRC_channels2`
    FOREIGN KEY (`IRC_channels_channelID`)
    REFERENCES `cloudchatdb`.`IRC_channels` (`channelID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`IRC_queries`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`IRC_queries` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`IRC_queries` (
  `fromHostmask` VARCHAR(45) NOT NULL,
  `fromNickname` VARCHAR(45) NULL COMMENT 'possily redundant',
  `lastOpened` DATETIME NULL,
  `IRC_servers_serverID` INT NOT NULL,
  PRIMARY KEY (`fromHostmask`, `IRC_servers_serverID`),
  INDEX `fk_IRC_queries_IRC_servers1_idx` (`IRC_servers_serverID` ASC),
  CONSTRAINT `fk_IRC_queries_IRC_servers1`
    FOREIGN KEY (`IRC_servers_serverID`)
    REFERENCES `cloudchatdb`.`IRC_servers` (`serverID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`IRC_query_messages`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`IRC_query_messages` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`IRC_query_messages` (
  `messageID` INT NOT NULL AUTO_INCREMENT,
  `fromHostmask` VARCHAR(45) NOT NULL,
  `messageBody` VARCHAR(4096) NOT NULL,
  `commandType` VARCHAR(45) NOT NULL,
  `timeReceived` TIMESTAMP NOT NULL,
  `seen` TIMESTAMP NULL,
  `IRC_queries_fromHostmask` VARCHAR(45) NOT NULL,
  `IRC_queries_IRC_servers_serverID` INT NOT NULL,
  PRIMARY KEY (`messageID`, `IRC_queries_fromHostmask`, `IRC_queries_IRC_servers_serverID`),
  INDEX `fk_IRC_query_messages_IRC_queries1_idx` (`IRC_queries_fromHostmask` ASC, `IRC_queries_IRC_servers_serverID` ASC),
  CONSTRAINT `fk_IRC_query_messages_IRC_queries1`
    FOREIGN KEY (`IRC_queries_fromHostmask` , `IRC_queries_IRC_servers_serverID`)
    REFERENCES `cloudchatdb`.`IRC_queries` (`fromHostmask` , `IRC_servers_serverID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`IRC_buffered_messages`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`IRC_buffered_messages` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`IRC_buffered_messages` (
  `messageID` INT NOT NULL,
  `messageBody` VARCHAR(4096) NULL,
  `commandType` VARCHAR(45) NULL,
  `timeSent` DATETIME NULL,
  `isChannel` TINYINT(1) NULL,
  `IRC_servers_serverID` INT NOT NULL,
  `IRC_servers_Registred_users_userID` INT NOT NULL,
  `IRC_channels_channelID` INT NOT NULL,
  PRIMARY KEY (`messageID`, `IRC_servers_serverID`, `IRC_servers_Registred_users_userID`, `IRC_channels_channelID`),
  INDEX `fk_IRC_buffered_messages_IRC_servers1_idx` (`IRC_servers_serverID` ASC, `IRC_servers_Registred_users_userID` ASC),
  INDEX `fk_IRC_buffered_messages_IRC_channels1_idx` (`IRC_channels_channelID` ASC),
  CONSTRAINT `fk_IRC_buffered_messages_IRC_servers1`
    FOREIGN KEY (`IRC_servers_serverID` , `IRC_servers_Registred_users_userID`)
    REFERENCES `cloudchatdb`.`IRC_servers` (`serverID` , `Registred_users_userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_IRC_buffered_messages_IRC_channels1`
    FOREIGN KEY (`IRC_channels_channelID`)
    REFERENCES `cloudchatdb`.`IRC_channels` (`channelID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`User_sessions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`User_sessions` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`User_sessions` (
  `session_id` VARCHAR(256) NOT NULL,
  `expires` TIMESTAMP NOT NULL,
  `create_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Registred_users_userID` INT NOT NULL,
  PRIMARY KEY (`Registred_users_userID`),
  CONSTRAINT `fk_User_sessions_Registred_users1`
    FOREIGN KEY (`Registred_users_userID`)
    REFERENCES `cloudchatdb`.`Registered_users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cloudchatdb`.`IO_Table`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cloudchatdb`.`IO_Table` ;

CREATE TABLE IF NOT EXISTS `cloudchatdb`.`IO_Table` (
  `Registered_users_userID` INT NOT NULL,
  `commandType` VARCHAR(45) NOT NULL,
  `argument1` VARCHAR(2048) NULL,
  `argument2` VARCHAR(2048) NULL,
  `argument3` VARCHAR(2048) NULL,
  `timeSent` TIMESTAMP NULL,
  `processed` TINYINT(1) NULL,
  `timeReceived` TIMESTAMP NULL,
  `fromClient` TINYINT(1) NOT NULL,
  PRIMARY KEY (`Registered_users_userID`),
  INDEX `fk_IO_Table_Registered_users1_idx` (`Registered_users_userID` ASC),
  CONSTRAINT `fk_IO_Table_Registered_users1`
    FOREIGN KEY (`Registered_users_userID`)
    REFERENCES `cloudchatdb`.`Registered_users` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;