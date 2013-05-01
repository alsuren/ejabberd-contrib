--
-- ejabberd, Copyright (C) 2002-2011   ProcessOne
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation; either version 2 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
-- 02111-1307 USA
--

-- Needs MySQL (at least 4.0.x) with innodb back-end

CREATE  TABLE IF NOT EXISTS `ejabberd`.`mam_username` (
  `ID` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `STRING` VARCHAR(50) NOT NULL ,
  PRIMARY KEY (`ID`) ,
  UNIQUE INDEX `string_UNIQUE` (`STRING` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = 'general_ci, means the username strings are treated as case insensitive in sorts.';


CREATE  TABLE IF NOT EXISTS `ejabberd`.`mam_config` (
  `LOCAL_USERNAME` BIGINT UNSIGNED NOT NULL ,
  `REMOTE_JID` BIGINT UNSIGNED NOT NULL ,
  `BEHAVIOUR` ENUM('always_archive', 'never_archive', 'roster') NOT NULL ,
  INDEX `fk_mam_config_1_idx` (`LOCAL_USERNAME` ASC) ,
  INDEX `fk_mam_config_2_idx` (`REMOTE_JID` ASC) ,
  CONSTRAINT `fk_mam_config_1`
    FOREIGN KEY (`LOCAL_USERNAME` )
    REFERENCES `mydb`.`mam_username` (`ID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_mam_config_2`
    FOREIGN KEY (`REMOTE_JID` )
    REFERENCES `mydb`.`mam_username` (`ID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;

USE `mydb`;
DELIMITER $$

CREATE TRIGGER `mam_config_BINS` BEFORE INSERT ON mam_config FOR EACH ROW
BEGIN
  IF NOT (( NEW.BEHAVIOUR='roster' AND NEW.REMOTE_JID IS NULL ) OR NEW.BEHAVIOUR != 'roster') THEN
    SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'REMOTE_JID must be NULL on roster messages!';
  END IF;
END$$

CREATE TRIGGER `mam_config_BUPD` BEFORE UPDATE ON mam_config FOR EACH ROW
BEGIN
  IF NOT (( NEW.BEHAVIOUR='roster' AND NEW.REMOTE_JID IS NULL ) OR NEW.BEHAVIOUR != 'roster') THEN
    SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'REMOTE_JID must be NULL on roster messages!';
  END IF;
END

DELIMITER ;


CREATE  TABLE IF NOT EXISTS `ejabberd`.`mam_message` (
  `ID` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `LOCAL_USERNAME` BIGINT UNSIGNED NOT NULL ,
  `FROM_JID` BIGINT UNSIGNED NOT NULL ,
  `REMOTE_BARE_JID` BIGINT UNSIGNED NOT NULL ,
  `REMOTE_RESOURCE` BIGINT UNSIGNED NOT NULL ,
  `DIRECTION` ENUM('incoming', 'outgoing') NOT NULL ,
  `ADDED_AT` TIMESTAMP NOT NULL ,
  `MESSAGE` BLOB NOT NULL ,
  PRIMARY KEY (`ID`) ,
  INDEX `fk_mam_message_2_idx` (`FROM_JID` ASC) ,
  INDEX `fk_mam_message_1_idx` (`LOCAL_USERNAME` ASC) ,
  INDEX `fk_mam_message_3_idx` (`REMOTE_BARE_JID` ASC) ,
  INDEX `fk_mam_message_4_idx` (`REMOTE_RESOURCE` ASC) ,
  CONSTRAINT `fk_mam_message_1`
    FOREIGN KEY (`LOCAL_USERNAME` )
    REFERENCES `mydb`.`mam_username` (`ID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_mam_message_2`
    FOREIGN KEY (`FROM_JID` )
    REFERENCES `mydb`.`mam_username` (`ID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_mam_message_3`
    FOREIGN KEY (`REMOTE_BARE_JID` )
    REFERENCES `mydb`.`mam_username` (`ID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_mam_message_4`
    FOREIGN KEY (`REMOTE_RESOURCE` )
    REFERENCES `mydb`.`mam_username` (`ID` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;
