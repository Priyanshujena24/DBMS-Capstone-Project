USE smartstay;

INSERT INTO facility (facility_id, name) VALUES
  (1,'WiFi'),(2,'AC'),(3,'Meals'),(4,'Laundry'),(5,'Power Backup'),
  (6,'CCTV'),(7,'Parking'),(8,'Gym'),(9,'RO Water'),(10,'Housekeeping')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO property (property_id,name,address,area,city,state,pin_code,latitude,longitude,description) VALUES
  (1,'SmartStay Sohna Heights','Plot 14, Sector 2, Near Bus Stand','Sohna','Gurugram','Haryana','122103',28.247600,77.066100,'Quiet PG near the Sohna bus stand.'),
  (2,'SmartStay Sohna Greens','Plot 52, Sector 5, Sohna-Palwal Road','Sohna','Gurugram','Haryana','122103',28.239500,77.072000,'Family-run hostel with home-style meals.'),
  (3,'SmartStay Golf Course Road','C-31, Sector 54, Golf Course Road','Golf Course Road','Gurugram','Haryana','122011',28.433500,77.103000,'PG for working professionals near Rapid Metro.'),
  (4,'SmartStay Cyber Hub','88, Sector 24, DLF Phase 3','DLF Phase 3','Gurugram','Haryana','122002',28.494000,77.089000,'Walking distance to Cyber Hub offices.'),
  (5,'SmartStay Rohtak MDU','27, Model Town, Near MDU Gate 1','Model Town','Rohtak','Haryana','124001',28.874200,76.618000,'Student hostel next to MDU.')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT IGNORE INTO property_facility (property_id,facility_id) VALUES
  (1,1),(1,3),(1,5),(1,6),(1,9),(1,10),(2,1),(2,3),(2,5),(2,6),(2,9),
  (3,1),(3,2),(3,4),(3,5),(3,6),(3,7),(3,8),(3,9),(3,10),
  (4,1),(4,2),(4,4),(4,5),(4,6),(4,9),(4,10),(5,1),(5,3),(5,5),(5,6),(5,9);

INSERT INTO room (room_id,property_id,room_number,capacity,monthly_rent) VALUES
  (1,1,'101',1,13000),(2,1,'102',2,9500),(3,2,'101',2,9000),
  (4,2,'201',3,10100),(5,3,'101',1,10400),(6,3,'201',3,10100),
  (7,4,'102',2,7600),(8,5,'101',1,10400)
ON DUPLICATE KEY UPDATE monthly_rent = VALUES(monthly_rent);

INSERT INTO tenant (tenant_id,full_name,phone,email,gender,occupation_type,organisation) VALUES
  (1,'Aarav Sharma','9810011001','aarav.sharma@example.com','Male','Professional','Maruti Suzuki'),
  (2,'Rohan Verma','9810011002','rohan.verma@example.com','Male','Student','Raisina University'),
  (3,'Ishita Gupta','9810011003','ishita.gupta@example.com','Female','Student','Raisina University'),
  (4,'Karan Malhotra','9810011004','karan.malhotra@example.com','Male','Professional','Hero MotoCorp'),
  (5,'Priya Singh','9810011005','priya.singh@example.com','Female','Professional','Sohna Civil Hospital')
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

INSERT INTO allocation (allocation_id,tenant_id,room_id,start_date,status) VALUES
  (1,1,1,'2025-01-01','Active'),(2,2,2,'2025-02-01','Active'),
  (3,3,2,'2025-02-01','Active'),(4,4,3,'2025-03-01','Active'),
  (5,5,4,'2025-03-01','Active')
ON DUPLICATE KEY UPDATE status = VALUES(status), end_date = NULL;

INSERT INTO rent_payment (rent_id,allocation_id,rent_month,amount,status,payment_date,method) VALUES
  (1,1,DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH),'%Y-%m-01'),13000,'Paid',DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY),'UPI'),
  (2,2,DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH),'%Y-%m-01'),9500,'Pending',NULL,NULL),
  (3,3,DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH),'%Y-%m-01'),9500,'Paid',DATE_SUB(CURRENT_DATE, INTERVAL 4 DAY),'Cash'),
  (4,4,DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH),'%Y-%m-01'),9000,'Pending',NULL,NULL),
  (5,5,DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH),'%Y-%m-01'),10100,'Paid',DATE_SUB(CURRENT_DATE, INTERVAL 3 DAY),'UPI')
ON DUPLICATE KEY UPDATE amount = VALUES(amount);

INSERT INTO complaint (complaint_id,tenant_id,category,description,status) VALUES
  (1,1,'Maintenance','Ceiling fan makes a loud noise at night.','Open'),
  (2,4,'Facilities','Hot water is not available in the morning.','In Progress')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO designation (designation_id,title) VALUES
  (1,'Manager'),(2,'Warden'),(3,'Security Guard'),(4,'Cleaner')
ON DUPLICATE KEY UPDATE title = VALUES(title);

INSERT INTO employee (employee_id,full_name,phone,email,designation_id,property_id,joining_date,basic_salary,is_active) VALUES
  (1,'Rajesh Kumar','9911022001','rajesh.kumar@smartstay.in',1,1,'2020-01-01',42000,TRUE),
  (2,'Sunita Devi','9911022002','sunita.devi@smartstay.in',2,1,'2020-01-01',24000,TRUE),
  (3,'Anil Chauhan','9911022005','anil.chauhan@smartstay.in',1,3,'2020-01-01',38000,TRUE)
ON DUPLICATE KEY UPDATE basic_salary = VALUES(basic_salary);

INSERT INTO user_account (user_id,username,password_hash,role,employee_id) VALUES
  (1,'admin','$2a$10$eUHjkaZCuEIAA4uR1Ft64e88ufPzkNS3JImFIblNQ/tdy8ibnBnVO','ADMIN',NULL),
  (2,'emp1','$2a$10$pGDNsDs9s/zrzxrrRKDIH.tbNfuTUSYT0YokhZqu7JJjagUOvQQSa','EMPLOYEE',1),
  (3,'emp2','$2a$10$pGDNsDs9s/zrzxrrRKDIH.tbNfuTUSYT0YokhZqu7JJjagUOvQQSa','EMPLOYEE',2),
  (4,'emp3','$2a$10$pGDNsDs9s/zrzxrrRKDIH.tbNfuTUSYT0YokhZqu7JJjagUOvQQSa','EMPLOYEE',3)
ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash);

INSERT INTO tax_slab (slab_id,annual_from,annual_to,rate_percent) VALUES
  (1,0,240000,0),(2,240000,480000,5),(3,480000,720000,10),(4,720000,NULL,20)
ON DUPLICATE KEY UPDATE rate_percent = VALUES(rate_percent);

SET @seed_workday = CASE
  WHEN DAYOFWEEK(CURRENT_DATE) = 1 THEN DATE_SUB(CURRENT_DATE, INTERVAL 2 DAY)
  ELSE DATE_SUB(CURRENT_DATE, INTERVAL (DAYOFWEEK(CURRENT_DATE) - 2) DAY)
END;

INSERT INTO attendance (employee_id,att_date,status,check_in,check_out) VALUES
  (1,@seed_workday,'Present','09:00:00','17:00:00'),
  (2,@seed_workday,'Late','09:30:00','17:00:00'),
  (3,@seed_workday,'Present','09:10:00','17:00:00')
ON DUPLICATE KEY UPDATE status = VALUES(status), check_in = VALUES(check_in), check_out = VALUES(check_out);

INSERT INTO leave_request (leave_id,employee_id,start_date,end_date,reason,status,applied_on) VALUES
  (1,2,DATE_ADD(@seed_workday, INTERVAL 2 DAY),DATE_ADD(@seed_workday, INTERVAL 3 DAY),'Personal leave','Pending',CURRENT_DATE)
ON DUPLICATE KEY UPDATE reason = VALUES(reason), status = VALUES(status);

INSERT INTO visitor (visitor_id,visitor_name,phone,tenant_id,property_id,visit_datetime,purpose) VALUES
  (1,'Mahendra Sharma','9899000101',1,1,NOW(),'Father visiting')
ON DUPLICATE KEY UPDATE purpose = VALUES(purpose);

INSERT INTO payroll (employee_id,pay_month,basic_salary,working_days,days_present,approved_leave_days,days_absent,late_marks,absence_deduction,late_deduction,tax_deduction,net_salary) VALUES
  (1,DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH),'%Y-%m-01'),42000,26,20,0,6,0,9692.31,0,752.56,31555.13),
  (2,DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH),'%Y-%m-01'),24000,26,22,0,4,3,3692.31,923.08,0,19384.61),
  (3,DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH),'%Y-%m-01'),38000,26,23,0,3,1,4384.62,0,0,33615.38)
ON DUPLICATE KEY UPDATE net_salary = VALUES(net_salary);
