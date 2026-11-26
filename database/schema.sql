CREATE DATABASE IF NOT EXISTS smartstay
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE smartstay;

CREATE TABLE facility (
  facility_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (facility_id),
  UNIQUE KEY uq_facility_name (name)
) ENGINE=InnoDB;

CREATE TABLE property (
  property_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL,
  area VARCHAR(80) NOT NULL,
  city VARCHAR(60) NOT NULL,
  state VARCHAR(60) NOT NULL DEFAULT 'Haryana',
  pin_code CHAR(6) NOT NULL,
  latitude DECIMAL(9,6) NOT NULL,
  longitude DECIMAL(9,6) NOT NULL,
  description VARCHAR(300) NULL,
  PRIMARY KEY (property_id),
  UNIQUE KEY uq_property_name (name),
  KEY ix_property_city (city),
  CONSTRAINT chk_property_pin CHECK (pin_code REGEXP '^[0-9]{6}$'),
  CONSTRAINT chk_property_lat CHECK (latitude BETWEEN -90 AND 90),
  CONSTRAINT chk_property_lon CHECK (longitude BETWEEN -180 AND 180)
) ENGINE=InnoDB;

CREATE TABLE property_facility (
  property_id INT UNSIGNED NOT NULL,
  facility_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (property_id, facility_id),
  CONSTRAINT fk_property_facility_property FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE,
  CONSTRAINT fk_property_facility_facility FOREIGN KEY (facility_id) REFERENCES facility(facility_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE room (
  room_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL,
  room_number VARCHAR(10) NOT NULL,
  capacity TINYINT UNSIGNED NOT NULL,
  monthly_rent DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (room_id),
  UNIQUE KEY uq_room_property_number (property_id, room_number),
  CONSTRAINT fk_room_property FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE RESTRICT,
  CONSTRAINT chk_room_capacity CHECK (capacity BETWEEN 1 AND 6),
  CONSTRAINT chk_room_rent CHECK (monthly_rent > 0)
) ENGINE=InnoDB;

CREATE TABLE tenant (
  tenant_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(100) NOT NULL,
  phone CHAR(10) NOT NULL,
  email VARCHAR(120) NULL,
  gender ENUM('Male','Female','Other') NOT NULL,
  occupation_type ENUM('Student','Professional') NOT NULL,
  organisation VARCHAR(100) NULL,
  PRIMARY KEY (tenant_id),
  UNIQUE KEY uq_tenant_phone (phone),
  CONSTRAINT chk_tenant_phone CHECK (phone REGEXP '^[6-9][0-9]{9}$')
) ENGINE=InnoDB;

CREATE TABLE allocation (
  allocation_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id INT UNSIGNED NOT NULL,
  room_id INT UNSIGNED NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NULL,
  status ENUM('Active','Vacated') NOT NULL DEFAULT 'Active',
  active_tenant_id INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN status = 'Active' THEN tenant_id ELSE NULL END) STORED,
  PRIMARY KEY (allocation_id),
  UNIQUE KEY uq_allocation_active_tenant (active_tenant_id),
  KEY ix_allocation_room_status (room_id, status),
  CONSTRAINT fk_allocation_tenant FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id) ON DELETE RESTRICT,
  CONSTRAINT fk_allocation_room FOREIGN KEY (room_id) REFERENCES room(room_id) ON DELETE RESTRICT,
  CONSTRAINT chk_allocation_dates CHECK ((status = 'Active' AND end_date IS NULL) OR (status = 'Vacated' AND end_date IS NOT NULL AND end_date >= start_date))
) ENGINE=InnoDB;

CREATE TABLE rent_payment (
  rent_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  allocation_id INT UNSIGNED NOT NULL,
  rent_month DATE NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  status ENUM('Pending','Paid') NOT NULL DEFAULT 'Pending',
  payment_date DATE NULL,
  method ENUM('Cash','UPI','Card','Bank Transfer') NULL,
  PRIMARY KEY (rent_id),
  UNIQUE KEY uq_rent_allocation_month (allocation_id, rent_month),
  KEY ix_rent_month_status (rent_month, status),
  CONSTRAINT fk_rent_allocation FOREIGN KEY (allocation_id) REFERENCES allocation(allocation_id) ON DELETE RESTRICT,
  CONSTRAINT chk_rent_amount CHECK (amount > 0),
  CONSTRAINT chk_rent_payment CHECK ((status = 'Pending' AND payment_date IS NULL AND method IS NULL) OR status = 'Paid')
) ENGINE=InnoDB;

CREATE TABLE complaint (
  complaint_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id INT UNSIGNED NOT NULL,
  category ENUM('Room','Maintenance','Facilities','Other') NOT NULL,
  description VARCHAR(500) NOT NULL,
  status ENUM('Open','In Progress','Resolved') NOT NULL DEFAULT 'Open',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_at DATETIME NULL,
  PRIMARY KEY (complaint_id),
  KEY ix_complaint_status_created (status, created_at),
  CONSTRAINT fk_complaint_tenant FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE visitor (
  visitor_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  visitor_name VARCHAR(100) NOT NULL,
  phone CHAR(10) NOT NULL,
  tenant_id INT UNSIGNED NOT NULL,
  property_id INT UNSIGNED NOT NULL,
  visit_datetime DATETIME NOT NULL,
  purpose VARCHAR(150) NOT NULL,
  PRIMARY KEY (visitor_id),
  KEY ix_visitor_property_datetime (property_id, visit_datetime),
  CONSTRAINT fk_visitor_tenant FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id) ON DELETE RESTRICT,
  CONSTRAINT fk_visitor_property FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE RESTRICT,
  CONSTRAINT chk_visitor_phone CHECK (phone REGEXP '^[6-9][0-9]{9}$')
) ENGINE=InnoDB;

CREATE TABLE enquiry (
  enquiry_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NULL,
  name VARCHAR(100) NOT NULL,
  phone CHAR(10) NOT NULL,
  email VARCHAR(120) NULL,
  message VARCHAR(500) NOT NULL,
  status ENUM('New','Contacted','Closed') NOT NULL DEFAULT 'New',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (enquiry_id),
  CONSTRAINT fk_enquiry_property FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE SET NULL,
  CONSTRAINT chk_enquiry_phone CHECK (phone REGEXP '^[6-9][0-9]{9}$')
) ENGINE=InnoDB;

CREATE TABLE designation (
  designation_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(100) NOT NULL,
  PRIMARY KEY (designation_id),
  UNIQUE KEY uq_designation_title (title)
) ENGINE=InnoDB;

CREATE TABLE employee (
  employee_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(100) NOT NULL,
  phone CHAR(10) NOT NULL,
  email VARCHAR(120) NULL,
  designation_id INT UNSIGNED NOT NULL,
  property_id INT UNSIGNED NOT NULL,
  joining_date DATE NOT NULL,
  basic_salary DECIMAL(12,2) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (employee_id),
  UNIQUE KEY uq_employee_phone (phone),
  CONSTRAINT fk_employee_designation FOREIGN KEY (designation_id) REFERENCES designation(designation_id) ON DELETE RESTRICT,
  CONSTRAINT fk_employee_property FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE RESTRICT,
  CONSTRAINT chk_employee_phone CHECK (phone REGEXP '^[6-9][0-9]{9}$'),
  CONSTRAINT chk_employee_salary CHECK (basic_salary > 0)
) ENGINE=InnoDB;

CREATE TABLE user_account (
  user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL,
  password_hash VARCHAR(100) NOT NULL,
  role ENUM('ADMIN','EMPLOYEE') NOT NULL,
  employee_id INT UNSIGNED NULL,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_user_username (username),
  UNIQUE KEY uq_user_employee (employee_id),
  CONSTRAINT fk_user_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE attendance (
  attendance_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  employee_id INT UNSIGNED NOT NULL,
  att_date DATE NOT NULL,
  status ENUM('Present','Absent','Late') NOT NULL,
  check_in TIME NULL,
  check_out TIME NULL,
  PRIMARY KEY (attendance_id),
  UNIQUE KEY uq_attendance_employee_date (employee_id, att_date),
  KEY ix_attendance_date_status (att_date, status),
  CONSTRAINT fk_attendance_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE leave_request (
  leave_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  employee_id INT UNSIGNED NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reason VARCHAR(200) NOT NULL,
  status ENUM('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  applied_on DATE NOT NULL,
  PRIMARY KEY (leave_id),
  KEY ix_leave_employee_status_dates (employee_id, status, start_date, end_date),
  CONSTRAINT fk_leave_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE RESTRICT,
  CONSTRAINT chk_leave_dates CHECK (end_date >= start_date)
) ENGINE=InnoDB;

CREATE TABLE tax_slab (
  slab_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  annual_from DECIMAL(12,2) NOT NULL,
  annual_to DECIMAL(12,2) NULL,
  rate_percent DECIMAL(5,2) NOT NULL,
  PRIMARY KEY (slab_id),
  CONSTRAINT chk_tax_from CHECK (annual_from >= 0),
  CONSTRAINT chk_tax_to CHECK (annual_to IS NULL OR annual_to > annual_from),
  CONSTRAINT chk_tax_rate CHECK (rate_percent BETWEEN 0 AND 100)
) ENGINE=InnoDB;

CREATE TABLE payroll (
  payroll_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  employee_id INT UNSIGNED NOT NULL,
  pay_month DATE NOT NULL,
  basic_salary DECIMAL(12,2) NOT NULL,
  working_days SMALLINT UNSIGNED NOT NULL,
  days_present SMALLINT UNSIGNED NOT NULL,
  approved_leave_days SMALLINT UNSIGNED NOT NULL,
  days_absent SMALLINT UNSIGNED NOT NULL,
  late_marks SMALLINT UNSIGNED NOT NULL,
  absence_deduction DECIMAL(12,2) NOT NULL DEFAULT 0,
  late_deduction DECIMAL(12,2) NOT NULL DEFAULT 0,
  tax_deduction DECIMAL(12,2) NOT NULL DEFAULT 0,
  net_salary DECIMAL(12,2) NOT NULL,
  generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (payroll_id),
  UNIQUE KEY uq_payroll_employee_month (employee_id, pay_month),
  KEY ix_payroll_month (pay_month),
  CONSTRAINT fk_payroll_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE RESTRICT,
  CONSTRAINT chk_payroll_salary CHECK (basic_salary > 0 AND net_salary >= 0)
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER trg_attendance_bi
BEFORE INSERT ON attendance FOR EACH ROW
BEGIN
  DECLARE v_joining DATE;
  DECLARE v_leave INT DEFAULT 0;
  SELECT joining_date INTO v_joining FROM employee WHERE employee_id = NEW.employee_id;
  IF NEW.att_date < v_joining THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: date is before joining date'; END IF;
  IF NEW.att_date > CURRENT_DATE() THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: future dates are not allowed'; END IF;
  IF DAYOFWEEK(NEW.att_date) = 1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: Sunday is the weekly off'; END IF;
  IF NEW.status = 'Absent' AND (NEW.check_in IS NOT NULL OR NEW.check_out IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: Absent record cannot have check-in/out'; END IF;
  IF NEW.status IN ('Present','Late') THEN
    IF NEW.check_in IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: check-in time is required'; END IF;
    IF NEW.check_out IS NOT NULL AND NEW.check_out <= NEW.check_in THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: check-out must be after check-in'; END IF;
    IF NEW.status = 'Present' AND NEW.check_in > '09:15:00' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: check-in after 09:15 must be marked Late'; END IF;
    IF NEW.status = 'Late' AND NEW.check_in <= '09:15:00' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: check-in by 09:15 is not Late'; END IF;
    SELECT COUNT(*) INTO v_leave FROM leave_request WHERE employee_id = NEW.employee_id AND status = 'Approved' AND start_date <= NEW.att_date AND end_date >= NEW.att_date;
    IF v_leave > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: employee is on approved leave that day'; END IF;
  END IF;
END$$

CREATE TRIGGER trg_attendance_bu
BEFORE UPDATE ON attendance FOR EACH ROW
BEGIN
  DECLARE v_joining DATE;
  DECLARE v_leave INT DEFAULT 0;
  SELECT joining_date INTO v_joining FROM employee WHERE employee_id = NEW.employee_id;
  IF NEW.att_date < v_joining THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: date is before joining date'; END IF;
  IF NEW.att_date > CURRENT_DATE() THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: future dates are not allowed'; END IF;
  IF DAYOFWEEK(NEW.att_date) = 1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: Sunday is the weekly off'; END IF;
  IF NEW.status = 'Absent' AND (NEW.check_in IS NOT NULL OR NEW.check_out IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: Absent record cannot have check-in/out'; END IF;
  IF NEW.status IN ('Present','Late') THEN
    IF NEW.check_in IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: check-in time is required'; END IF;
    IF NEW.check_out IS NOT NULL AND NEW.check_out <= NEW.check_in THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: check-out must be after check-in'; END IF;
    IF NEW.status = 'Present' AND NEW.check_in > '09:15:00' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: check-in after 09:15 must be marked Late'; END IF;
    IF NEW.status = 'Late' AND NEW.check_in <= '09:15:00' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: check-in by 09:15 is not Late'; END IF;
    SELECT COUNT(*) INTO v_leave FROM leave_request WHERE employee_id = NEW.employee_id AND status = 'Approved' AND start_date <= NEW.att_date AND end_date >= NEW.att_date;
    IF v_leave > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance error: employee is on approved leave that day'; END IF;
  END IF;
END$$

CREATE TRIGGER trg_leave_bi
BEFORE INSERT ON leave_request FOR EACH ROW
BEGIN
  DECLARE v_joining DATE;
  DECLARE v_overlap INT DEFAULT 0;
  DECLARE v_attendance INT DEFAULT 0;
  IF NEW.end_date < NEW.start_date THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Leave error: end date is before start date'; END IF;
  SELECT joining_date INTO v_joining FROM employee WHERE employee_id = NEW.employee_id;
  IF NEW.start_date < v_joining THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Leave error: leave starts before joining date'; END IF;
  IF NEW.status IN ('Pending','Approved') THEN
    SELECT COUNT(*) INTO v_overlap FROM leave_request WHERE employee_id = NEW.employee_id AND status = 'Approved' AND start_date <= NEW.end_date AND end_date >= NEW.start_date;
    IF v_overlap > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Leave error: dates overlap an already approved leave'; END IF;
  END IF;
  IF NEW.status = 'Approved' THEN
    SELECT COUNT(*) INTO v_attendance FROM attendance WHERE employee_id = NEW.employee_id AND att_date BETWEEN NEW.start_date AND NEW.end_date AND status IN ('Present','Late');
    IF v_attendance > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Leave error: employee already has attendance on these dates'; END IF;
  END IF;
END$$

CREATE TRIGGER trg_leave_bu
BEFORE UPDATE ON leave_request FOR EACH ROW
BEGIN
  DECLARE v_joining DATE;
  DECLARE v_overlap INT DEFAULT 0;
  DECLARE v_attendance INT DEFAULT 0;
  IF NEW.end_date < NEW.start_date THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Leave error: end date is before start date'; END IF;
  SELECT joining_date INTO v_joining FROM employee WHERE employee_id = NEW.employee_id;
  IF NEW.start_date < v_joining THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Leave error: leave starts before joining date'; END IF;
  IF NEW.status IN ('Pending','Approved') THEN
    SELECT COUNT(*) INTO v_overlap FROM leave_request WHERE employee_id = NEW.employee_id AND status = 'Approved' AND leave_id <> OLD.leave_id AND start_date <= NEW.end_date AND end_date >= NEW.start_date;
    IF v_overlap > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Leave error: dates overlap an already approved leave'; END IF;
  END IF;
  IF NEW.status = 'Approved' THEN
    SELECT COUNT(*) INTO v_attendance FROM attendance WHERE employee_id = NEW.employee_id AND att_date BETWEEN NEW.start_date AND NEW.end_date AND status IN ('Present','Late');
    IF v_attendance > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Leave error: employee already has attendance on these dates'; END IF;
  END IF;
END$$

CREATE TRIGGER trg_allocation_bi
BEFORE INSERT ON allocation FOR EACH ROW
BEGIN
  DECLARE v_capacity INT;
  DECLARE v_active INT DEFAULT 0;
  IF NEW.status = 'Vacated' AND NEW.end_date IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Allocation error: vacated stay needs an end date'; END IF;
  IF NEW.status = 'Active' THEN
    IF NEW.end_date IS NOT NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Allocation error: active stay cannot have an end date'; END IF;
    SELECT capacity INTO v_capacity FROM room WHERE room_id = NEW.room_id FOR UPDATE;
    SELECT COUNT(*) INTO v_active FROM allocation WHERE room_id = NEW.room_id AND status = 'Active';
    IF v_active >= v_capacity THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Allocation error: room is already at full capacity'; END IF;
  END IF;
END$$

CREATE TRIGGER trg_allocation_bu
BEFORE UPDATE ON allocation FOR EACH ROW
BEGIN
  DECLARE v_capacity INT;
  DECLARE v_active INT DEFAULT 0;
  IF NEW.status = 'Vacated' AND NEW.end_date IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Allocation error: vacated stay needs an end date'; END IF;
  IF NEW.status = 'Active' THEN
    IF NEW.end_date IS NOT NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Allocation error: active stay cannot have an end date'; END IF;
    SELECT capacity INTO v_capacity FROM room WHERE room_id = NEW.room_id FOR UPDATE;
    SELECT COUNT(*) INTO v_active FROM allocation WHERE room_id = NEW.room_id AND status = 'Active' AND allocation_id <> OLD.allocation_id;
    IF v_active >= v_capacity THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Allocation error: room is already at full capacity'; END IF;
  END IF;
END$$

CREATE FUNCTION fn_annual_tax(p_annual DECIMAL(14,2))
RETURNS DECIMAL(14,2) READS SQL DATA
BEGIN
  DECLARE v_tax DECIMAL(14,2);
  SELECT ROUND(COALESCE(SUM(GREATEST(0, LEAST(p_annual, COALESCE(annual_to, p_annual)) - annual_from) * rate_percent / 100), 0), 2)
    INTO v_tax FROM tax_slab WHERE p_annual > annual_from;
  RETURN v_tax;
END$$

CREATE FUNCTION fn_monthly_tax(p_monthly DECIMAL(14,2))
RETURNS DECIMAL(14,2) READS SQL DATA
BEGIN
  RETURN ROUND(fn_annual_tax(p_monthly * 12) / 12, 2);
END$$

CREATE FUNCTION fn_leave_days(p_employee_id INT UNSIGNED, p_from DATE, p_to DATE)
RETURNS INT READS SQL DATA
BEGIN
  DECLARE v_date DATE;
  DECLARE v_days INT DEFAULT 0;
  IF p_to < p_from THEN RETURN 0; END IF;
  SET v_date = p_from;
  WHILE v_date <= p_to DO
    IF DAYOFWEEK(v_date) <> 1 AND EXISTS (
      SELECT 1 FROM leave_request
       WHERE employee_id = p_employee_id AND status = 'Approved'
         AND start_date <= v_date AND end_date >= v_date
    ) THEN SET v_days = v_days + 1; END IF;
    SET v_date = DATE_ADD(v_date, INTERVAL 1 DAY);
  END WHILE;
  RETURN v_days;
END$$

CREATE FUNCTION fn_working_days(p_from DATE, p_to DATE)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE v_date DATE;
  DECLARE v_days INT DEFAULT 0;
  IF p_to < p_from THEN RETURN 0; END IF;
  SET v_date = p_from;
  WHILE v_date <= p_to DO
    IF DAYOFWEEK(v_date) <> 1 THEN SET v_days = v_days + 1; END IF;
    SET v_date = DATE_ADD(v_date, INTERVAL 1 DAY);
  END WHILE;
  RETURN v_days;
END$$

CREATE PROCEDURE sp_generate_payroll(IN p_month DATE, IN p_employee_id INT UNSIGNED, IN p_overwrite BOOLEAN)
BEGIN
  DECLARE v_month DATE;
  DECLARE v_end DATE;
  DECLARE v_done INT DEFAULT 0;
  DECLARE v_employee INT UNSIGNED;
  DECLARE v_salary DECIMAL(12,2);
  DECLARE v_from DATE;
  DECLARE v_working INT;
  DECLARE v_full_working INT;
  DECLARE v_present INT;
  DECLARE v_late INT;
  DECLARE v_leave INT;
  DECLARE v_absent INT;
  DECLARE v_per_day DECIMAL(14,6);
  DECLARE v_abs_ded DECIMAL(12,2);
  DECLARE v_late_ded DECIMAL(12,2);
  DECLARE v_earned DECIMAL(12,2);
  DECLARE v_tax DECIMAL(12,2);
  DECLARE cur CURSOR FOR SELECT employee_id, basic_salary, joining_date FROM employee WHERE is_active = TRUE AND joining_date <= v_end AND (p_employee_id IS NULL OR employee_id = p_employee_id);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

  SET v_month = DATE_SUB(p_month, INTERVAL DAYOFMONTH(p_month)-1 DAY);
  SET v_end = LAST_DAY(p_month);
  IF v_end >= CURRENT_DATE() THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payroll error: month is not finished yet'; END IF;
  IF p_employee_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM employee WHERE employee_id = p_employee_id AND is_active = TRUE) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payroll error: employee not found or inactive';
  END IF;

  START TRANSACTION;
  OPEN cur;
  payroll_loop: LOOP
    FETCH cur INTO v_employee, v_salary, v_from;
    IF v_done THEN LEAVE payroll_loop; END IF;
    IF EXISTS (SELECT 1 FROM payroll WHERE employee_id = v_employee AND pay_month = v_month) THEN
      IF NOT p_overwrite THEN ITERATE payroll_loop; END IF;
      DELETE FROM payroll WHERE employee_id = v_employee AND pay_month = v_month;
    END IF;
    SET v_from = GREATEST(v_from, v_month);
    SET v_working = fn_working_days(v_from, v_end);
    SET v_full_working = fn_working_days(v_month, v_end);
    SELECT COUNT(*), COALESCE(SUM(status = 'Late'), 0) INTO v_present, v_late
      FROM attendance WHERE employee_id = v_employee AND att_date BETWEEN v_from AND v_end AND status IN ('Present','Late');
    SET v_leave = fn_leave_days(v_employee, v_from, v_end);
    SET v_absent = GREATEST(0, v_working - v_present - v_leave);
    SET v_per_day = v_salary / v_full_working;
    SET v_abs_ded = ROUND(v_absent * v_per_day, 2);
    SET v_late_ded = ROUND(FLOOR(v_late / 3) * v_per_day, 2);
    SET v_earned = GREATEST(0, ROUND(v_per_day * v_working, 2) - v_abs_ded - v_late_ded);
    SET v_tax = fn_monthly_tax(v_earned);
    INSERT INTO payroll (employee_id, pay_month, basic_salary, working_days, days_present, approved_leave_days, days_absent, late_marks, absence_deduction, late_deduction, tax_deduction, net_salary)
    VALUES (v_employee, v_month, v_salary, v_working, v_present, v_leave, v_absent, v_late, v_abs_ded, v_late_ded, v_tax, ROUND(v_earned - v_tax, 2));
  END LOOP;
  CLOSE cur;
  COMMIT;
END$$

CREATE VIEW v_room_availability AS
SELECT r.*, p.name AS property_name,
       COALESCE(a.occupied, 0) AS occupied,
       r.capacity - COALESCE(a.occupied, 0) AS available_beds,
       CASE r.capacity WHEN 1 THEN 'Single' WHEN 2 THEN 'Double' WHEN 3 THEN 'Triple' ELSE CONCAT(r.capacity, '-sharing') END AS sharing_type
  FROM room r
  JOIN property p ON p.property_id = r.property_id
  LEFT JOIN (SELECT room_id, COUNT(*) AS occupied FROM allocation WHERE status = 'Active' GROUP BY room_id) a ON a.room_id = r.room_id;

CREATE VIEW v_property_public AS
SELECT p.*,
       r.min_rent,
       r.max_rent,
       COALESCE(r.total_beds, 0) AS total_beds,
       COALESCE(r.available_beds, 0) AS available_beds,
       f.facilities
  FROM property p
  LEFT JOIN (
    SELECT property_id, MIN(monthly_rent) AS min_rent, MAX(monthly_rent) AS max_rent,
           SUM(capacity) AS total_beds, SUM(available_beds) AS available_beds
      FROM v_room_availability GROUP BY property_id
  ) r ON r.property_id = p.property_id
  LEFT JOIN (
    SELECT pf.property_id, GROUP_CONCAT(f.name ORDER BY f.name SEPARATOR ', ') AS facilities
      FROM property_facility pf JOIN facility f ON f.facility_id = pf.facility_id
     GROUP BY pf.property_id
  ) f ON f.property_id = p.property_id;

CREATE VIEW v_salary_slip AS
SELECT py.*, e.full_name, d.title AS designation, p.name AS property_name,
       ROUND(py.basic_salary * py.working_days / fn_working_days(py.pay_month, LAST_DAY(py.pay_month)), 2) AS payable_basic,
       ROUND(py.absence_deduction + py.late_deduction + py.tax_deduction, 2) AS total_deductions
  FROM payroll py
  JOIN employee e ON e.employee_id = py.employee_id
  JOIN designation d ON d.designation_id = e.designation_id
  JOIN property p ON p.property_id = e.property_id;

DELIMITER ;
