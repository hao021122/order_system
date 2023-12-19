-- tb_app_uid
INSERT INTO tb_app_uid (app_uid, display_text, url, img, is_in_use, created_on, created_by, display_seq)
VALUES ('F3EA4C73-C898-4C54-BBA8-B0F62E7242A3', 'ORDER_SYS', 'order', 'order', 1, '2023-09-18 16:09:55.323', 'admin', 1);

-- tb_module
INSERT INTO tb_module ( module_id, module_code, module_name, module_version, module_url, module_img, module_status_id, app_id, created_on, created_by, module_img_file_name, row_guid, access_options, display_seq) 
VALUES 
(1101001, 'ORDERSETTADDONS', 'Addon Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '0004AD77-618B-462C-A333-1C8E47F1ED49', 0, NULL),
(1101002, 'ORDERSETTCAT', 'Category Setup', 1.0, NULL,NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '5AD55317-08D3-48FD-AD49-E19BDC9B0CD3', 0, NULL), 
(1101003, 'ORDERSETTGRP', 'Product Group Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '15D19D48-1139-4006-9596-17C62C5FB64C', 0,NULL),
(1101004, 'ORDERSETTMAIL', 'Mailbox Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, 'DF0D04C2-6F75-4529-87F3-946A7B316E6B', 0, NULL),
(1101005, 'ORDERSETTMENU', 'Menu Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '65CB0688-4685-4628-929B-4B5D9760CE9B',	0, NULL),
(1101006, 'ORDERSETTOUTLET', 'Outlet Profile Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '6C97736A-43C5-4743-A5E0-CAA3B3125C85', 0, NULL),
(1101007, 'ORDERSETTPYMT', 'Payment Type Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '65B195B2-066B-4FCD-912C-21CD2FF521A2', 0, NULL),
(1101008, 'ORDERSETTQUO', 'Quotation Setting Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '361E1BFE-195E-4270-BC89-2799DB4BD3E9', 0, NULL),
(1101009, 'ORDERSETTREQ', 'Request Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '8D21BE72-D1B6-48B3-95AD-43264E7C54B0', 0, NULL),
(1101010, 'ORDERSETTTAX', 'Tax Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '5C54AC00-3066-46C3-B035-9E041950A990', 0, NULL),
(1101011, 'ORDERSETTUOM', 'Unit of Measure Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '25A9CDC7-0366-401C-A0A9-580BB06C0242', 0, NULL),
(1101012, 'ORDERSETTUSER', 'User Setup', 1.0, NULL, NULL, 1, 1101000, '2023-11-24 17:32:46.270', 'admin', NULL, '941A8FB7-8858-49B3-90E9-3F379ABA6582', 0, NULL),
(2101001, 'ORDER', 'Orders', 1.0, NULL, NULL, 1, 2101000, '2023-12-06 16:00:05.510', 'admin', NULL, 'A0CD10DE-CCD0-4683-93F9-5D14AAD1D076', 0, NULL)

-- tb_co_profile
INSERT INTO tb_co_profile (co_id,co_row_guid,modified_on,modified_by,created_on,created_by,co_name,co_code,reg_no,addr1,addr2,postcode,city,state,country,phone,fax,email,mobile_phone,co_status_id,org_id,file_quota_mb,total_file_size_b)
VALUES (50,'8FDF41BB-0285-462E-8FD6-E5D4EB64A808','2023-06-30 11:28:26.537','admin','2023-06-30 11:28:26.537','admin','XXX Store',NULL,NULL,'1047, Jalan Tan Ah Kao','Taman Biru','50300','Wilayah Kuala Lumpur','Kuala Lumpur','Malaysia','0189551882',NULL,'chinleehao@gmail.com',NULL,1,66,NULL,NULL)

-- tb_org
INSERT INTO tb_org (org_id,org_name,org_img,org_status_id,org_img_file_name,org_row_guid,modified_on,modified_by,created_on,created_by,org_code) 
VALUES (66,'EG',NULL,1,NULL,'864CF27D-F951-4CD4-8539-245542ED4756','2023-05-26 18:12:27.280','admin','2023-05-26 18:12:27.280','admin','EG');

-- tb_org_status
INSERT INTO tb_org_status (org_status_id,org_status_desc,modified_on,modified_by,created_on,created_by,allow_login,is_in_use) 
VALUES (0,'Archive','2023-06-30 11:12:18.500','admin','2023-06-30 11:12:18.500','admin',0,1),
(1,'Active','2023-06-30 11:12:18.500','admin','2023-06-30 11:12:18.500','admin',1,1);

-- tb_tr_status
INSERT INTO tb_tr_status (tr_status,tr_status_desc,row_guid,is_in_use,display_seq) 
VALUES ('D','Draft','3DF91F9A-E8D8-4812-989E-6AFF27A7832D',1,1),
('S','Submited','959ADED1-8BCD-4BF6-8666-B22BC12A78FA',1,2), 
('CX','Cancel','A91F12D9-D96B-4EC3-A7E0-A367F2CD08FA',1,3),
('A','Approved','E58A6A30-6D65-488E-9303-48CDF7F04FC4',1,4),
('R','Rejected','A465BDA5-4144-4C5C-822E-5B1E3327EA3B',1,5),
('C','Completed','E77EAAA4-D0D5-4429-994E-4EEF3D977FE8',1,6);

-- tb_tr_type
INSERT INTO tb_tr_type (tr_type,tr_type_desc,row_guid,for_ic_process)
VALUES ('AC','Amendment Order Accepted in Queue','9BA55568-29E4-4355-AF9B-74A923A7221F',0),
('C','Order Cancelled','67F33D84-BDD5-40C4-A528-DC873D3DD12C',0);

-- tb_user_type
INSERT INTO tb_user_type(user_type_id,user_type_desc,default_url,skip_rec_section_url,modified_on,modified_by,created_on,created_by,is_in_use) 
VALUES (10,'Superuser',NULL,NULL,'2023-04-27 15:14:23.903','admin','2023-04-27 15:14:23.903','admin',1),
(20,'Admin',NULL,NULL,'2023-05-31 12:26:00.673','admin','2023-05-31 12:26:00.673','admin',1),
(30,'User',NULL,NULL,'2023-04-27 15:14:23.903','admin','2023-04-27 15:14:23.903','admin',1);

-- tb_user_group
INSERT INTO tb_user_group (user_group_id,user_group_desc,is_in_use,modified_on,modified_by,created_on,created_by,max_discount,max_discount_pct) 
VALUES ('E264CF57-05C5-4F11-9799-9DCA56C68012','ADM\ Superuser',1,'2023-04-27 15:15:59.840','admin','2023-04-27 15:15:59.840','admin',0.00,0),
('75075FC3-05F2-46F1-964D-4F2003E2A439','USER\ Client',1,'2023-04-27 15:15:59.840','admin','2023-04-27 15:15:59.840','admin',0.00,0),
('9EB42C04-B359-4BB7-9151-7BB3BF519AA9','ADM\ Manager',1,'2023-05-11 17:15:03.563','admin','2023-05-11 17:15:03.563','admin',0.00,0),
('10718E7C-2A0D-406F-93AC-5A20731B1708','USER\ Employee',1,'2023-05-11 17:15:03.563','admin','2023-05-11 17:15:03.563','admin',0.00,0)

-- tb_sys_prop
INSERT INTO tb_sys_prop(sys_prop_id,org_id,co_id,prop_group,prop_name,prop_value,modified_on,modified_by,created_on,created_by,row_guid) 
VALUES 
(4, 0, 0,'SYSTEM','quotation-header','Welcome To XXX Store!! Here is your quotation.','2023-06-28 17:43:23.947','admin','2023-06-28 16:44:08.903','admin','81650E38-D76A-408E-88FE-74CAFDB90EFA'),
(5, 0, 0,'SYSTEM','quotation-footer','Thanks You!!','2023-06-28 17:43:23.947','admin','2023-06-28 16:44:08.903','admin','336F3AE7-7831-40D1-821D-115EC87CF2EB'),
(6, 0, 0, 'SYSTEM', 'quotation-footer-no-of-blank-line', '3', '2023-06-28 17:43:23.947', 'admin', '2023-06-28 16:44:08.903', 'admin', 'C1900CFA-DA2B-4910-B17E-67D2BD20F087'),
(7, 0, 0, 'SYSTEM', 'smtp_port', '587', '2023-07-12 15:39:18.470', 'admin', '2023-07-11 16:10:26.173', 'admin', 'C7DDED18-4AA7-427D-990A-F0FAF5A2628B'),
(8, 0, 0, 'SYSTEM', 'smtp_mailbox_uid', '$2b$13$jF6EF5fsWMyfH1FztuxNhuAZeqRBuQT64qi7MXysBNfq9t06T6/he', '2023-07-12 15:39:18.470', 'admin', '2023-07-11 16:10:26.173', 'admin', 'E24A5678-84CF-474B-91DA-73896814855A'),
(9, 0, 0, 'SYSTEM', 'smtp_mailbox_pwd', '$2b$13$.lttP0eYJnqqyL6mqaNC9OU3qCYD4/tuiDmq0FrS.XscjuIUpJvcu', '2023-07-12 15:39:18.470', 'admin', '2023-07-11 16:10:26.173', 'admin', 'F57FA569-4A1A-4C88-A2A9-8112B10D924B'),
(10, 0, 0, 'SYSTEM', 'smtp_use_ssl', '1', '2023-07-12 15:39:18.470', 'admin', '2023-07-11 16:10:26.173', 'admin', '482CEAA7-D060-4C61-86AF-4AF96702CC45'),
(11, 0, 0, 'SYSTEM', 'smtp_disable_service', '1', '2023-07-12 15:39:18.470', 'admin', '2023-07-11 16:10:26.173', 'admin', '22CCCB91-DCCF-4726-9988-878DC0FE384C'),
(14, 0, 0, 'SYSTEM', 'receipt_no_prefix', '#QUO', '2023-08-03 12:50:52.433', 'admin', '2023-08-03 12:29:19.660', 'admin', '59B2C530-4E72-441D-9709-7687EA0F0612'),
(13, 0, 0, 'SYSTEM', 'smtp_server', 'smtp.gmail.com', '2023-07-12 15:39:18.470', 'admin', '2023-07-11 16:21:57.583', 'admin', '0D293455-E896-4D23-8610-BFE26E80DA3A'),
(15, 0, 0, 'SYSTEM', 'receipt_no_postfix', '', '2023-08-03 12:50:52.433', 'admin', '2023-08-03 12:29:19.660', 'admin', '568A59B4-4700-4907-A0F1-FD395929CEB6'),
(16, 0, 0, 'SYSTEM', 'receipt_no_len', '6', '2023-08-03 12:50:52.433', 'admin', '2023-08-03 12:29:19.660', 'admin', '950DB7EA-E500-4526-A69B-AC275552D77E'),
(17, 0, 0, 'SYSTEM', 'auth_allow_partial_pwd', '1', '2023-08-22 16:17:14.667', 'admin', '2023-08-22 16:17:14.667', 'admin', '1D98D4AD-D9E9-4ABF-BC35-093BEF601CA9'),
(18, 0, 0, 'SYSTEM', 'sess_timeout_minute', '60', '2023-08-22 16:20:35.460', 'admin', '2023-08-22 16:20:35.460', 'admin', 'D2EEDC0D-B37C-4987-8A30-2CE7905F0017'),
(1, 0, 0, 'SYSTEM', 'app_config_title', 'ORDER', '2023-09-18 16:19:01.287', 'admin', '2023-09-18 16:19:01.287', 'admin', 'A136B412-D89E-4230-BB58-952E1B5DAFC5')

