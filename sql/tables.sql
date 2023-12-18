-- 1. Settings Addon
if not exists (select *from sys.objects where name = 'tb_addon')
begin
create table tb_addon (
	addon_id uniqueidentifier
	, created_on datetime
	, created_by nvarchar(255)
	, modified_on datetime
	, modified_by nvarchar(255)
	, addon_code nvarchar(50)
	, addon_desc nvarchar(50)
	, remark nvarchar(255)
	, amt money
	, is_in_use int
	, display_seq int
	, is_global int
)
end
go

-- 2. 
if not exists (select *from sys.objects where name = 'tb_ajax_cmd')
begin
create table tb_ajax_cmd (
	ajax_cmd_id uniqueidentifier
	, created_on datetime
	, created_by nvarchar(255)
	, modified_on datetime
	, modified_by nvarchar(255)
	, cmd_group nvarchar(50)
	, cmd_code nvarchar(50)
	, cmd_axn nvarchar(50)
	, description nvarchar(255)
	, is_in_use int
	, display_seq int
	, is_user_define int
	, run_async int
	, require_sess int
	, handling_incoming_data int
	, skip_using_db_tx int
	, cache_data int
	, module_id int
	, get_override int
)
end
go

-- 3. 
if not exists (select *from sys.objects where name = 'tb_ajax_cmd_notif')
begin
create table tb_ajax_cmd_notif (
	ajax_cmd_id uniqueidentifier
	, step_seq int
	, notif_code nvarchar(50)
	, id_fld1 nvarchar(255)
	, id_fld2 nvarchar(255)
	, id_fld3 nvarchar(255)
	, id_fld4 nvarchar(255)
	, id_fld5 nvarchar(255)
)
end
go

-- 4. 
if not exists (select *from sys.objects where name = 'tb_ajax_cmd_sess')
begin
create table tb_ajax_cmd_sess (
	created_on datetime
	, created_by nvarchar(255)
	, group_code nvarchar(50)
	, sess_name nvarchar(255)
	, data_type nvarchar(50)
)
end
go

-- 5.
if not exists (select *from sys.objects where name = 'tb_ajax_cmd_step')
begin
create table tb_ajax_cmd_step (
	ajax_cmd_step_id uniqueidentifier
	, ajax_cmd_id uniqueidentifier
	, seq int
	, sql_stm nvarchar(max)
	, return_msg int
	, is_finalize_step int
	, json_var_name nvarchar(255)
)
end
go

-- 6. 
if not exists (select *from sys.objects where name = 'tb_ajax_cmd_step_param')
begin
create table tb_ajax_cmd_step_param (
	ajax_cmd_step_param_id uniqueidentifier
	, ajax_cmd_step_id uniqueidentifier
	, seq int
	, caller_param_name nvarchar(255)
	, param_name nvarchar(255)
	, data_type nvarchar(255)
	, display_text nvarchar(255)
	, is_compulsory int 
	, is_hidden int
	, def_value nvarchar(255)
	, is_out_param int
	, out_param_name nvarchar(255)
	, get_value_from_prev_step int
	, enc int
)
end
go

-- 7. 
if not exists (select *from sys.objects where name = 'tb_ajax_cmd_step_setting')
begin
create table tb_ajax_cmd_step_setting (
	ajax_cmd_step_id uniqueidentifier
	, setting_group nvarchar(50)
	, fld_name nvarchar(255)
	, enc int
)
end
go

-- 8. 
if not exists (select *from sys.objects where name = 'tb_ajax_cmd_user')
begin
create table tb_ajax_cmd_user (
	user_group_id uniqueidentifier
	, user_id uniqueidentifier
	, cmd_group nvarchar(50)
	, cmd_code nvarchar(50)
	, cmd_axn nvarchar(50)
	, role_id int
)
end
go

-- 9. 
if not exists (select *from sys.objects where name = 'tb_ajax_cmd_wf')
begin
create table tb_ajax_cmd_wf (
	ajax_cmd_id uniqueidentifier
	, id_fld1 nvarchar(255)
	, id_fld2 nvarchar(255)
	, id_fld3 nvarchar(255)
	, id_fld4 nvarchar(255)
	, id_fld5 nvarchar(255)
	, axn nvarchar(50)
)
end
go

-- 10. App modules
if not exists (select *from sys.objects where name = 'tb_app')
begin
create table tb_app (
	app_id int
	, app_code nvarchar(15)
	, app_name nvarchar(50)
	, app_version nvarchar(10)
	, app_url nvarchar(255)
	, app_img nvarchar(255)
	, app_status_id int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, app_img_file_name nvarchar(255)
	, row_guid uniqueidentifier
	, app_path nvarchar(255)
)
end
go

-- 11. 
if not exists (select *from sys.objects where name = 'tb_app_access_map')
begin
create table tb_app_access_map (
	app_uid uniqueidentifier
	, app_id int
	, created_on datetime
	, created_by nvarchar(255)
	, row_guid uniqueidentifier
)
end
go

-- 12. 
if not exists (select *from sys.objects where name = 'tb_app_uid')
begin
create table tb_app_uid (
	app_uid uniqueidentifier
	, display_text nvarchar(255)
	, url nvarchar(255)
	, img nvarchar(255) 
	, is_in_use int
	, created_on datetime
	, created_by nvarchar(255)
	, display_seq int
)
end
go

-- 13. 
if not exists (select *from sys.objects where name = 'tb_cal_detail_status')
begin
create table tb_cal_detail_status (
	cal_detail_status_id int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, code nvarchar(50)
	, description nvarchar(50)
	, is_in_use int
	, display_seq int
)
end
go

-- 14. 
if not exists (select *from sys.objects where name = 'tb_cal_status')
begin
create table tb_cal_status (
	cal_status_id int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, code nvarchar(50)
	, description nvarchar(50)
	, is_in_use int
	, display_seq int
	, allow_edit int
)
end
go

-- 15. 
if not exists (select *from sys.objects where name = 'tb_cal_type')
begin
create table tb_cal_type (
	cal_type_id int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, code nvarchar(50)
	, description nvarchar(50)
	, is_public int
	, is_in_use int
	, display_seq int
)
end
go

-- 16.
if not exists (select *from sys.objects where name = 'tb_co_last_id')
begin
create table tb_co_last_id (
	co_row_guid uniqueidentifier
	, tb_name nvarchar(255)
	, last_id int
	, modified_on datetime
)
end
go

-- 17.
if not exists (select *from sys.objects where name = 'tb_co_profile')
begin
create table tb_co_profile (
	co_id int
	, co_row_guid uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, co_name nvarchar(255)
	, co_code nvarchar(50)
	, reg_no nvarchar(255)
	, addr1 nvarchar(255)
	, addr2 nvarchar(255)
	, postcode nvarchar(50)
	, city nvarchar(255)
	, state nvarchar(255)
	, country nvarchar(255)
	, phone nvarchar(50)
	, fax nvarchar(50)
	, email nvarchar(50)
	, mobile_phone nvarchar(50)
	, co_status_id int
	, org_id int
	, file_quota_mb bigint
	, total_file_size_b bigint
)
end
go

-- 18.
if not exists (select *from sys.objects where name = 'tb_co_status')
begin
create table tb_co_status (
	co_status_id int
	, co_status_desc nvarchar(50)
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, allow_login int
	, is_in_use int
)
end
go

-- 19. 
if not exists (select *from sys.objects where name = 'tb_condiment')
begin
create table tb_condiment (
	condiment_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, condiment_code nvarchar(50)
	, condiment_desc nvarchar(255)
	, remarks nvarchar(255)
	, is_in_use int
	, display_seq int
	, is_global int
)
end
go

-- 20. 
if not exists (select *from sys.objects where name = 'tb_country')
begin
create table tb_country (
	country_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, country_code nvarchar(5)
	, country_desc nvarchar(50)
	, nationality nvarchar(50)
	, is_default int
	, display_seq int
) 
end
go

-- 21.
if not exists (select *from sys.objects where name = 'tb_daily_avail')
begin
create table tb_daily_avail (
	daily_avail_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, dt datetime
	, prod_id uniqueidentifier
	, qty int
	, sold_qty int
)
end
go

-- 22. 
if not exists (select *from sys.objects where name = 'tb_date')
begin
create table tb_date (
	id int
	, dt datetime
	, yr int
	, mth int
	, qtr int
	, wk int
	, dow int
	, day_mth int
	, day_yr int
)
end
go

-- 23. 
if not exists (select *from sys.objects where name = 'tb_day_end_closing')
begin
create table tb_day_end_closing (
	day_end_closing_id uniqueidentifier
	, modified_by nvarchar(255)
	, co_id uniqueidentifier
	, dt datetime
	, remarks nvarchar(max)
	, start_time datetime
	, end_time datetime
	, complete_time datetime
	, row_guid uniqueidentifier
)
end
go

-- 24. 
if not exists (select *from sys.objects where name = 'tb_dept')
begin
create table tb_dept (
	dept_id uniqueidentifier 
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, main_dept_id uniqueidentifier
	, dept_code nvarchar(20)
	, dept_desc nvarchar(50)
	, is_in_use int
	, display_seq int
	, user_fld0 nvarchar(255)
	, user_fld1 nvarchar(255)
	, user_fld2 nvarchar(255)
	, user_fld3 nvarchar(255)
	, user_fld4 nvarchar(255)
	, user_fld5 nvarchar(255)
	, user_fld6 nvarchar(255)
	, user_fld7 nvarchar(255)
	, user_fld8 nvarchar(255)
	, user_fld9 nvarchar(255)
)
end
go

-- 25.
if not exists (select *from sys.objects where name = 'tb_discount')
begin
create table tb_discount (
	discount_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, discount_desc nvarchar(255)
	, discount_pct numeric
	, discount_amt money
	, start_dt datetime
	, end_dt datetime
	, is_in_use int
	, display_seq int
	, is_global int
)
end
go

-- 26.
if not exists (select *from sys.objects where name = 'tb_division')
begin
create table tb_division (
	division_id uniqueidentifier 
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, co_id uniqueidentifier
	, division_code nvarchar(20)
	, division_desc nvarchar(50)
	, is_in_use int
	, display_seq int
	, user_fld0 nvarchar(255)
	, user_fld1 nvarchar(255)
	, user_fld2 nvarchar(255)
	, user_fld3 nvarchar(255)
	, user_fld4 nvarchar(255)
	, user_fld5 nvarchar(255)
	, user_fld6 nvarchar(255)
	, user_fld7 nvarchar(255)
	, user_fld8 nvarchar(255)
	, user_fld9 nvarchar(255)
)
end
go

-- 27.
if not exists (select *from sys.objects where name = 'tb_food_menu')
begin
create table tb_food_menu (
	menu_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, menu_code nvarchar(50)
	, menu_desc nvarchar(255)
	, is_in_use int
	, display_seq int
	, sell_on_web int
	, sell_in_outlet int
)
end
go

-- 28. 
if not exists (select *from sys.objects where name = 'tb_food_menu_season')
begin
create table tb_food_menu_season (
	menu_id uniqueidentifier
	, season_id uniqueidentifier 
	, display_seq int
)
end
go

-- 29. 
if not exists (select *from sys.objects where name = 'tb_food_menu_prod')
begin
create table tb_food_menu_prod (
	menu_id uniqueidentifier
	, prod_id uniqueidentifier
	, display_seq int
)
end
go

-- 30. 
if not exists (select *from sys.objects where name = 'tb_guest')
begin
create table tb_guest (
	guest_id uniqueidentifier 
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, guest_name nvarchar(255)
	, mobile_phone nvarchar(50)
	, email nvarchar(50)
	, start_dt datetime
	, end_dt datetime
)
end
go

-- 31. 
if not exists (select *from sys.objects where name = 'tb_guest_addr')
begin
create table tb_guest_addr (
	guest_addr_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, guest_id uniqueidentifier
	, seq int
	, is_primary_addr int
	, location_name nvarchar(255)
	, addr_line1 nvarchar(50)
	, addr_line2 nvarchar(50)
	, postcode nvarchar(50)
	, city nvarchar(50)
	, state nvarchar(50)
	, country nvarchar(50)
	, phone nvarchar(50)
	, contact_name nvarchar(255)
	, remarks nvarchar(255)
)
end
go

-- 32. 
if not exists (select *from sys.objects where name = 'tb_last_id')
begin
create table tb_last_id (
	tb_name nvarchar(255)
	, last_id bigint
	, modified_on datetime
)
end
go

-- 33.
if not exists (select *from sys.objects where name = 'tb_license_activation_code')
begin
create table tb_license_activation_code (
	license_activation_id uniqueidentifier
	, co_code nvarchar(15)
	, start_dt datetime
	, end_dt datetime
	, activation_code nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, row_guid uniqueidentifier
	, ip_addr varchar(50)
)
end
go

-- 34.
if not exists (select *from sys.objects where name = 'tb_log')
begin
create table tb_log (
	log_id bigint
	, log_type_id int
	, workstation nvarchar(255)
	, uid nvarchar(255)
	, msg nvarchar(max)
	, remarks nvarchar(255)
	, is_sent int
	, co_id int
	, app_id int
	, module_id int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
)
end
go

-- 35. 
if not exists (select *from sys.objects where name = 'tb_mail')
begin
create table tb_mail (
	row_id int
	, row_guid uniqueidentifier
	, sent_to_email nvarchar(max)
	, cc_to_email nvarchar(max)
	, reply_to nvarchar(max)
	, subject nvarchar(255)
	, body_text nvarchar(max)
	, attach_file nvarchar(max)
	, created_on nvarchar(max)
	, sent_status_id int
	, sent_on datetime
	, mail_type_id int
)
end
go

-- 36. 
if not exists (select *from sys.objects where name = 'tb_main_dept')
begin
create table tb_main_dept (
	main_dept_id uniqueidentifier 
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, co_id uniqueidentifier
	, main_dept_code nvarchar(20)
	, main_dept_desc nvarchar(50)
	, is_in_use int
	, display_seq int
	, user_fld0 nvarchar(255)
	, user_fld1 nvarchar(255)
	, user_fld2 nvarchar(255)
	, user_fld3 nvarchar(255)
	, user_fld4 nvarchar(255)
	, user_fld5 nvarchar(255)
	, user_fld6 nvarchar(255)
	, user_fld7 nvarchar(255)
	, user_fld8 nvarchar(255)
	, user_fld9 nvarchar(255)
)
end
go

-- 37. 
if not exists (select *from sys.objects where name = 'tb_map_id')
begin
create table tb_map_id (
	id int
	, guid_id uniqueidentifier
	, created_on datetime
)
end
go

-- 38. 
if not exists (select *from sys.objects where name = 'tb_season')
begin
create table tb_season (
	season_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, dept_id uniqueidentifier
	, season_desc nvarchar(255)
	, start_dt datetime
	, end_dt datetime
	, is_in_use int
	, display_seq int
	, is_global int
	, msg_on_screen nvarchar(max)
)
end
go

-- 39.
if not exists (select *from sys.objects where name = 'tb_memo')
begin
create table tb_memo (
	memo_id uniqueidentifier
	,co_id uniqueidentifier 
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, subject nvarchar(255)
	, msg nvarchar(max)
	, start_dt datetime
	, end_dt datetime
)
end
go

-- 40. 
if not exists (select *from sys.objects where name = 'tb_module')
begin
create table tb_module (
	module_id int
	, module_code nvarchar(255)
	, module_name nvarchar(255)
	, module_version nvarchar(255)
	, module_url nvarchar(255)
	, module_img nvarchar(255)
	, module_status_id int
	, app_id int
	, created_on datetime
	, created_by nvarchar(255)
	, module_img_file_name nvarchar(255)
	, row_guid uniqueidentifier
	, access_options int
	, display_seq int
)
end
go

-- 41.
if not exists (select *from sys.objects where name = 'tb_notif')
begin
create table tb_notif (
	notif_id int
	, app_uid uniqueidentifier
	, notif_code nvarchar(50)
	, notif_desc nvarchar(255)
	, msg_subject nvarchar(max)
	, msg_body nvarchar(max)
	, is_in_use int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
)
end
go

-- 42. 
if not exists (select *from sys.objects where name = 'tb_notif_log')
begin
create table tb_notif_log (
	notif_log_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, co_id uniqueidentifier
	, id1 nvarchar(255)
	, id2 nvarchar(255)
	, id3 nvarchar(255)
	, id4 nvarchar(255)
	, id5 nvarchar(255)
	, url nvarchar(255)
	, val1 nvarchar(max)
	, val2 nvarchar(max)
	, val3 nvarchar(max)
	, notif_id int
	, send_on datetime
	, process_on datetime
	, skip_send int
	, mail_id uniqueidentifier
	, remarks nvarchar(255)
)
end
go

-- 43. 
if not exists (select *from sys.objects where name = 'tb_notif_proc')
begin
create table tb_notif_proc (
	notif_proc_id uniqueidentifier
	, notif_code nvarchar(50)
	, parent_notif_code nvarchar(50)
	, sql_stm nvarchar(max)
	, has_criteria int
)
end
go

-- 44. 
if not exists (select *from sys.objects where name = 'tb_obj_ext')
begin
create table tb_obj_ext (
	ext_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, co_id uniqueidentifier
	, ext_group nvarchar(50)
	, ext_code nvarchar(50)
	, ext_seq int 
	, id1 varchar
	, id2 varchar
	, id3 varchar
	, id4 varchar
	, id5 varchar
	, f0 nvarchar(255)
	, f1 nvarchar(255)
	, f2 nvarchar(255)
	, f3 nvarchar(255)
	, f4 nvarchar(255)
	, f5 nvarchar(255)
	, f6 nvarchar(255)
	, f7 nvarchar(255)
	, f8 nvarchar(255)
	, f9 nvarchar(255)
	, f10 nvarchar(255)
	, f11 nvarchar(255)
	, f12 nvarchar(255)
	, f13 nvarchar(255)
	, f14 nvarchar(255)
	, f15 nvarchar(255)
	, f16 nvarchar(255)
	, f17 nvarchar(255)
	, f18 nvarchar(255)
	, f19 nvarchar(255)
	, m0 nvarchar(max)
	, m1 nvarchar(max)
	, m2 nvarchar(max)
	, m3 nvarchar(max)
	, m4 nvarchar(max)
	, m5 nvarchar(max)
	, m6 nvarchar(max)
	, m7 nvarchar(max)
	, m8 nvarchar(max)
	, m9 nvarchar(max)
)
end
go

-- 45.
if not exists (select *from sys.objects where name = 'tb_period_type')
begin
create table tb_period_type (
	period_type_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, code nvarchar(50)
	, description nvarchar(50)
	, is_in_use int
	, display_seq int
)
end
go

-- 46.
if not exists (select *from sys.objects where name = 'tb_prod_cat')
begin
create table tb_prod_cat (
	prod_cat_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, prod_cat_desc nvarchar(255)
	, is_in_use int
	, display_seq int
	, is_global int
)
end
go

-- 47.
if not exists (select *from sys.objects where name = 'tb_prod_code')
begin
create table tb_prod_code (
	prod_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, prod_cat_id uniqueidentifier
	, prod_code nvarchar(20)
	, prod_desc nvarchar(255)
	, prod_size nvarchar(20)
	, prod_color nvarchar(20)
	, barcode nvarchar(20)
	, price money
	, cost money
	, uom_id uniqueidentifier
	, prod_type_id int
	, prod_group_id uniqueidentifier
	, parent_prod_id uniqueidentifier
	, is_in_use int
	, is_global int
	, max_allow_on_same_day int
	, img_url nvarchar(255)
	, tax_code1 nvarchar(50)
	, amt_inclusive_tax1 int
	, tax_code2 nvarchar(50)
	, amt_inclusive_tax2 int
	, calc_tax2_after_add_tax1 int
	, net_amt money
	, gross_amt money
	, start_dt datetime
	, end_dt datetime
	, prepare_time int
	, sell_on_web int
	, sell_in_outlet int
	, prod_desc2 nvarchar(max)
	, keep_daily_avail int
)
end
go

-- 48.
if not exists (select *from sys.objects where name = 'tb_prod_group')
begin
create table tb_prod_group (
	prod_group_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, prod_group_desc nvarchar(50)
	, is_in_use int
	, display_seq int
	, is_global int
)
end
go

-- 49. 
if not exists (select *from sys.objects where name = 'tb_prod_type')
begin
create table tb_prod_type (
	prod_type_id int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, prod_type_desc nvarchar(50)
	, is_in_use int
	, display_seq int
) 
end
go

-- 50. 
if not exists (select *from sys.objects where name = 'tb_profiler_trans')
begin
create table tb_profiler_trans (
	profiler_trans_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, tr_date datetime
	, tr_type nvarchar(5)
	, doc_no nvarchar(30)
	, profile_id uniqueidentifier
	, remarks nvarchar(max)
	, amt money
	--, override_by nvarchar(255)
	--, override_on datetime
	, total_tax money
	, total_discount money
	, rounding_adj_amt money
	, bill_discount_amt money
	, bill_discount_pct numeric 
	, calc_bill_discount_amt money
	--, bill_discount_override_by nvarchar(255)
	, disc_remarks nvarchar(255)
	, with_deposit int
	, is_credit_sales int
	, outstanding_amt money
	, last_settle_on datetime
	, with_voucher int
	, guest_name nvarchar(255)
	, tr_status nvarchar(50)
	, delivery_time nvarchar(5)
)
end
go

-- 51. 
if not exists (select *from sys.objects where name = 'tb_profiler_trans_void_log')
begin
create table tb_profiler_trans_void_log (
	void_log_id uniqueidentifier
	, created_on datetime
	, created_by nvarchar(255)
	, profiler_trans_id uniqueidentifier 
	, seq int
	, is_void int
	, tr_date datetime
	, void_reason nvarchar(255)
)
end
go

-- 52. 
if not exists (select *from sys.objects where name = 'tb_pymt_type')
begin
create table tb_pymt_type (
	pymt_type_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, pymt_type_desc nvarchar(50)
	, sys_pymt_type_id int
	, is_in_use int
	, display_seq int
	, is_global int
	, pymt_type_img_idx int
	, allow_payment_change_due int
	, get_credit_card_detail int
	, get_ref_no int
	, img varbinary(max)
)
end
go

-- 53. 
if not exists (select *from sys.objects where name = 'tb_repeat_type')
begin
create table tb_repeat_type (
	repeat_type_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, code nvarchar(50)
	, description nvarchar(50)
	, is_in_use int
	, display_seq int
)
end
go

-- 54.
if not exists (select *from sys.objects where name = 'tb_request')
begin
create table tb_request (
	request_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, request_code nvarchar(50)
	, request_desc nvarchar(50)
	, remarks nvarchar(255)
	, group_code nvarchar(50)
	, is_in_use int
	, display_seq int
	, is_global int
)
end
go

-- 55. 
if not exists (select *from sys.objects where name = 'tb_reset_pwd_log')
begin
create table tb_reset_pwd_log (
	reset_id uniqueidentifier
	, login_id nvarchar(255)
	, user_host nvarchar(50)
	, created_on datetime
	, browser_name nvarchar(50)
	, os_platform nvarchar(50)
	, browser_version nvarchar(50)
	, status_id int
)
end
go

-- 56. 
if not exists (select * from sys.objects where name = 'tb_rpt_sch')
begin
create table tb_rpt_sch (
	rpt_sch_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, rpt_code nvarchar(50)
	, remarks nvarchar(255)
	, last_run_on datetime 
	, start_dt datetime
	, end_dt datetime
	, run_at nvarchar(20)
	, schedule_type nvarchar(50)
	, interval nvarchar(50)
	, duration nvarchar(50)
	, repeat_on nvarchar(50)
	, output_format nvarchar(50)
)
end
go

-- 57.
if not exists (select * from sys.objects where name = 'tb_rpt_sch_email')
begin
create table tb_rpt_sch_email (
	rpt_sch_email_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, rpt_sch_id uniqueidentifier
	, email nvarchar(255)
)
end
go

-- 58.
if not exists (select *from sys.objects where name = 'tb_rpt_sch_param')
begin
create table tb_rpt_sch_param (
	rpt_sch_param_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, rpt_sch_id uniqueidentifier
	, param_name nvarchar(255)
	, param_value nvarchar(255)
)
end
go

-- 59. 
if not exists (select *from sys.objects where name = 'tb_rpt_sch_param_func')
begin
create table tb_rpt_sch_param_func (
	created_on datetime
	, func_name nvarchar(255)
	, data_type nvarchar(50)
	, display_seq int
	, remarks nvarchar(255)
)
end
go

-- 60. 
if not exists (select *from sys.objects where name = 'tb_rpt_tmpl')
begin
create table tb_rpt_tmpl (
	rpt_tmpl_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, rpt_group nvarchar(50)
	, rpt_code nvarchar(50)
	, rpt_desc nvarchar(255)
	, is_in_use int
	, display_seq int
	, is_user_define int
	, co_id uniqueidentifier
	, gen_method_id int
	, storage_type_id int
	, sch_ps_file nvarchar(255)
)
end
go

-- 61. 
if not exists (select *from sys.objects where name = 'tb_rpt_tmpl_step')
begin
create table tb_rpt_tmpl_step (
	rpt_tmpl_step_id uniqueidentifier
	, rpt_tmpl_id uniqueidentifier
	, seq int
	, sql_stm nvarchar(max)
	, json_var_name nvarchar(50)
	, tmpl_file nvarchar(255)
	, inject_to_var nvarchar(50)
	, merge_mode int
)
end
go

-- 62.
if not exists (select *from sys.objects where name = 'tb_rpt_tmpl_step_param')
begin
create table tb_rpt_tmpl_step_param (
	rpt_tmpl_step_param_id uniqueidentifier
	, rpt_tmpl_step_id uniqueidentifier
	, seq int
	, caller_param_name nvarchar(255)
	, param_name nvarchar(255)
	, data_type nvarchar(50)
	, display_text nvarchar(255)
	, is_compulsory int
	, is_hidden int
	, def_value nvarchar(255)
	, subquery_code nvarchar(50)
)
end
go

-- 63. 
if not exists (select *from sys.objects where name = 'tb_rpt_tmpl_subquery')
begin
create table tb_rpt_tmpl_subquery (
	subquery_code nvarchar(50)
	, created_on datetime
	, created_by nvarchar(255)
	, sql nvarchar(max)
	, text_fld_name nvarchar(255)
	, value_fld_name nvarchar(255)
)
end
go

-- 64.
if not exists (select *from sys.objects where name = 'tb_rpt_tmpl_usage')
begin
create table tb_rpt_tmpl_usage (
	usage_id bigint
	, rpt_tmpl_id uniqueidentifier 
	, co_id uniqueidentifier
	, created_on datetime
	, created_by nvarchar(255)
	, url nvarchar(255)
	, query_param nvarchar(max)
	, start_time datetime 
	, end_time datetime
	, duration_ms int
	, status nvarchar(255)
)
end
go

-- 65. 
if not exists (select *from sys.objects where name = 'tb_rpt_tmpl_user')
begin
create table tb_rpt_tmpl_user (
	user_group_id uniqueidentifier
	, user_id uniqueidentifier
	, rpt_group nvarchar(50)
	, rpt_code nvarchar(50)
)
end
go

-- 66. 
if not exists (select *from sys.objects where name = 'tb_state')
begin
create table tb_state (
	state_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, state_code nvarchar(5)
	, state_desc nvarchar(50)
	, country_id uniqueidentifier
)
end
go

-- 67. 
if not exists (select *from sys.objects where name = 'tb_stock_trans')
begin
create table tb_stock_trans (
	tr_id uniqueidentifier
	, tr_date datetime
	, tr_type nvarchar(5)
	, doc_no nvarchar(30)
	, prod_id uniqueidentifier
	, qty int
	, cost money
	, sell_price money
	, profile_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, seq int
	, profiler_trans_id uniqueidentifier
	, discount_amt money
	, discount_pct numeric
	--, discount_override_by nvarchar(255)
	--, discount_id uniqueidentifier
	, disc_remarks nvarchar(255)
	, disc_total_calc money
	, is_ready int
	--, pymt_type_id uniqueidentifier
	--, ref_no nvarchar(255)
	, remarks nvarchar(255)
	, amt money
	--, price_override_by nvarchar(255)
	--, price_override_remarks nvarchar(255)
	, c1 nvarchar(255)
	, c2 nvarchar(255)
	, c3 nvarchar(255)
	, coupon_no nvarchar(255)
	, coupon_id uniqueidentifier
	, tax_code1 nvarchar(255) 
	, tax_pct1 money
	, tax_amt1 money
	, tax_amt1_calc money
	, tax_code2 nvarchar(255)
	, tax_pct2 money
	, tax_amt2 money
	, tax_amt2_calc money
)
end
go

-- 68.
if not exists (select *from sys.objects where name = 'tb_stock_trans_void')
begin
create table tb_stock_trans_void (
	tr_id uniqueidentifier
	, tr_date datetime
	, tr_type nvarchar(5)
	, doc_no nvarchar(30)
	, prod_id uniqueidentifier
	, qty int
	, cost money
	, sell_price money
	, profile_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, seq int
	, profiler_trans_id uniqueidentifier
	, discount_amt money
	, discount_pct numeric
	--, discount_override_by nvarchar(255)
	--, discount_id uniqueidentifier
	, disc_remarks nvarchar(255)
	, disc_total_calc money
	, is_ready int
	--, pymt_type_id uniqueidentifier
	--, ref_no nvarchar(255)
	, remarks nvarchar(255)
	, amt money
	--, price_override_by nvarchar(255)
	--, price_override_remarks nvarchar(255)
	, c1 nvarchar(255)
	, c2 nvarchar(255)
	, c3 nvarchar(255)
	, coupon_no nvarchar(255)
	, coupon_id uniqueidentifier
	, tax_code1 nvarchar(255)
	, tax_pct1 money
	, tax_amt1 money
	, tax_amt1_calc money
	, tax_code2 nvarchar(255)
	, tax_pct2 money
	, tax_amt2 money
	, tax_amt2_calc money
	--, void_on datetime
	--, void_by nvarchar(255)
)
end
go

-- 69.
if not exists (select *from sys.objects where name = 'tb_stock_trans_void_item_log')
begin
create table tb_stock_trans_void_item_log (
	void_item_id uniqueidentifier 
	, created_on datetime
	, create_by nvarchar(255)
	, doc_no nvarchar(50)
	, prod_desc nvarchar(255)
	, qty int
	, amt money
	, reason nvarchar(510)
	, pos_station nvarchar(50)
)
end
go

-- 70.
if not exists (select *from sys.objects where name = 'tb_sys_msg')
begin
create table tb_sys_msg (
	created_on datetime
	, create_by nvarchar(255)
	, msg_group nvarchar(50)
	, msg_code nvarchar(50)
	, msg nvarchar(max)
	, msg2 nvarchar(max)
	, axn_text nvarchar(max)
	, axn_url nvarchar(max)
	, axn_text2 nvarchar(max)
	, axn_url2 nvarchar(max)
	, axn_text3 nvarchar(max)
	, axn_url3 nvarchar(max)
	, is_in_use int
)
end
go

-- 71.
if not exists (select *from sys.objects where name = 'tb_sys_prop')
begin
create table tb_sys_prop (
	sys_prop_id int
	, org_id int
	, co_id int
	, prop_group nvarchar(255)
	, prop_name nvarchar(255)
	, prop_value nvarchar(max)
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, row_guid uniqueidentifier
)
end
go

-- 72.
if not exists (select *from sys.objects where name = 'tb_sys_pymt_type')
begin
create table tb_sys_pymt_type (
	sys_pymt_type_id int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, row_guid uniqueidentifier
	, sys_pymt_type_desc nvarchar(50)
	, is_in_use int
	, is_deposit int
	, is_credit_sales int
	, is_legal_tender int
)
end
go

-- 73.
if not exists (select *from sys.objects where name = 'tb_task_inbox')
begin
create table tb_task_inbox (
	task_inbox_id uniqueidentifier
	, task_inbox_url nvarchar(255)
	, task_inbox_status_id int
	, task nvarchar(max)
	, task_fk_value nvarchar(255)
	, task_fk_value2 nvarchar(255)
	, task_fk_value3 nvarchar(255)
	, remarks nvarchar(255)
	, proc_name nvarchar(255)
	, module_id int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, co_row_guid uniqueidentifier
)
end
go

-- 74.
if not exists (select *from sys.objects where name = 'tb_tax')
begin
create table tb_tax (
	tax_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, tax_code nvarchar(50)
	, tax_desc nvarchar(255)
	, tax_pct numeric(5, 2) 
	, tax_amt money
	, is_in_use int
	, display_seq int
	, is_global int
	, start_dt datetime
	, end_dt datetime
)
end
go

-- 75. 
if not exists (select *from sys.objects where name = 'tb_tr_status')
begin
create table tb_tr_status (
	tr_status nvarchar(5)
	, tr_status_desc nvarchar(50)
	, row_guid uniqueidentifier 
	, is_in_use int
	, display_seq int
)
end
go

-- 76.
if not exists (select *from sys.objects where name = 'tb_tr_type')
begin
create table tb_tr_type (
	tr_type nvarchar(5)
	, tr_type_desc nvarchar(50)
	, row_guid uniqueidentifier
	, for_ic_process int
)
end
go

-- 77.
if not exists (select *from sys.objects where name = 'tb_trans_addon')
begin
create table tb_trans_addon (
	profiler_trans_id uniqueidentifier 
	, trans_addon_id uniqueidentifier
	, tr_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, condiment_id uniqueidentifier
	, request_id uniqueidentifier
	, addon_id uniqueidentifier
	, remarks nvarchar(255)
)
end
go

-- 78.
if not exists (select *from sys.objects where name = 'tb_trans_print_log')
begin
create table tb_trans_print_log (
	profiler_trans_id uniqueidentifier
	, tr_id uniqueidentifier
	, printed_on datetime
	, printed_by datetime
	, prod_id uniqueidentifier
	, qty int
	, is_void int
)
end
go

-- 79.
if not exists (select *from sys.objects where name = 'tb_trans_table')
begin
create table tb_trans_table (
	profiler_trans_id uniqueidentifier 
	, order_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, create_by nvarchar(255)
	, remarks nvarchar(255)
)
end
go

-- 80.
if not exists (select *from sys.objects where name = 'tb_uom')
begin
create table tb_uom (
	uom_id uniqueidentifier 
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, uom_desc nvarchar(255)
	, is_in_use int
	, display_seq int
	, is_global int
)
end
go

-- 81. 
if not exists (select *from sys.objects where name = 'tb_user_access_log')
begin
create table tb_user_access_log (
	row_guid uniqueidentifier
	, login_id nvarchar(255)
	, status_id int
	, user_id uniqueidentifier 
	, sess_uid uniqueidentifier
	, user_host nvarchar(50)
	, created_on datetime
	, last_access_on datetime
	, logout_on datetime
	, browser_name nvarchar(50)
	, os_platform nvarchar(50)
	, browser_version nvarchar(50)
	, user_agent nvarchar(255)
)
end
go

-- 82. 
if not exists (select *from sys.objects where name = 'tb_user_access_log_co')
begin
create table tb_user_access_log_co (
	row_guid uniqueidentifier
	, sess_uid uniqueidentifier
	, created_on datetime
	, co_row_guid uniqueidentifier
)
end
go

-- 83.
if not exists (select *from sys.objects where name = 'tb_user_access_log_status')
begin
create table tb_user_access_log_status (
	status_id int
	, status_desc nvarchar(50)
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, is_in_use int
)
end
go

-- 84. 
if not exists (select *from sys.objects where name = 'tb_user_action')
begin
create table tb_user_action (
	user_action_id uniqueidentifier
	, user_action_desc nvarchar(255)
	, user_action_group_desc nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, display_seq int
	, module_id int
)
end
go

-- 85.
if not exists (select *from sys.objects where name = 'tb_user_allow_action')
begin
create table tb_user_allow_action (
	user_allow_action_id uniqueidentifier
	, user_id uniqueidentifier
	, user_group_id uniqueidentifier
	, user_action_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
)
end
go

-- 86. 
if not exists (select *from sys.objects where name = 'tb_user_group')
begin
create table tb_user_group (
	user_group_id uniqueidentifier
	, user_group_desc nvarchar(50)
	, is_in_use int
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, max_discount money
	, max_discount_pct numeric
)
end
go

-- 87. 
if not exists (select *from sys.objects where name = 'tb_user_status')
begin
create table tb_user_status (
	user_status_id int
	, user_status_desc nvarchar(255)
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, allow_login int
	, is_in_use int
)
end
go

-- 88. 
if not exists (select *from sys.objects where name = 'tb_user_type')
begin
create table tb_user_type (
	user_type_id int
	, user_type_desc nvarchar(20)
	, default_url nvarchar(255)
	, skip_rec_section_url nvarchar(255)
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, is_in_use int
)
end
go

-- 89. 
if not exists (select *from sys.objects where name = 'tb_users')
begin
create table tb_users (
	user_id uniqueidentifier 
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, login_id nvarchar(255)
	, user_name nvarchar(255)
	, pwd nvarchar(255)
	, pwd_expiry_on datetime
	, user_status_id int 
	, user_type_id int
	, login_validity_start datetime
	, login_validity_end datetime
	, pwd_last_change_on datetime
	, last_access_on datetime
	, accept_tnc_on datetime
	, phone nvarchar(50)
	, timezone nvarchar(50)
	, photo_url nvarchar(255)
)
end
go

-- 90.
if not exists (select *from sys.objects where name = 'tb_users_al')
begin
create table tb_users_al (
	user_id uniqueidentifier 
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, login_id nvarchar(255)
	, user_name nvarchar(255)
	, pwd nvarchar(255)
	, pwd_expiry_on datetime
	, user_status_id int 
	, user_type_id int
	, login_validity_start datetime
	, login_validity_end datetime
	, pwd_last_change_on datetime
	, last_access_on datetime
	, delete_on datetime
	, accept_tnc_on datetime
	, timezone nvarchar(50)
	, photo_url nvarchar(255)
)
end
go

-- 91.
if not exists (select *from sys.objects where name = 'tb_users_co')
begin
create table tb_users_co (
	users_co_id uniqueidentifier
	, user_id uniqueidentifier
	, user_status_id int
	, user_group_id uniqueidentifier
	, activate_on datetime
	, co_row_guid uniqueidentifier
)
end
go

-- 92.
if not exists (select *from sys.objects where name = 'tb_voucher')
begin
create table tb_voucher (
	voucher_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, voucher_type_id uniqueidentifier
	, voucher_no nvarchar(50)
	, is_cash_discount int
	, cash_discount_amt money
	, cash_discount_pct money
	, valid_start datetime
	, valid_end datetime
	, is_package int
	, has_utilise int
	, utilise_on datetime
	, profiler_trans_id uniqueidentifier
	, is_void int
	, void_on datetime
	, void_by nvarchar(255)
	, is_transferrable int
	, profile_id uniqueidentifier
	, total_amt money
	, is_e_voucher int
	, e_voucher_name nvarchar(255)
	, is_e_voucher_enable int
	, parent_voucher_id uniqueidentifier
	, tr_date datetime
	, voucher_no_prefix nvarchar(10)
	, use_valid_start_date int
	, e_voucher_valid_day_count int
	, voucher_no_start int
	, voucher_no_end int
	, amt_payable money
	, one_voucher_per_bill int
	, for_mon int
	, for_tue int
	, for_wed int
	, for_thu int
	, for_fri int
	, for_sat int
	, for_sun int
	, exclude_holiday int
	, include_holiday int
	, is_global int
	, voucher_no2 nvarchar(50)
)
end
go

-- 93.
if not exists (select *from sys.objects where name = 'tb_voucher_package_item')
begin
create table tb_voucher_package_item (
	voucher_package_item_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, voucher_id uniqueidentifier
	, seq int
	, prod_id uniqueidentifier
	, qty int
	, unit_price money
	, amt money
	, tax_code1 nvarchar(255)
	, tax_pct1 money
	, tax_amt1 money
	, tax_amt1_calc money
	, tax_code2 nvarchar(255)
	, tax_pct2 money
	, tax_amt2 money
	, tax_amt2_calc money
)
end
go

-- 94.
if not exists (select *from sys.objects where name = 'tb_voucher_type')
begin
create table tb_voucher_type (
	voucher_type_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, voucher_type_desc nvarchar(50)
	, no_of_digit int
	, is_in_use int
	, display_seq int
	, is_global int
)
end
go

-- 95.
if not exists (select *from sys.objects where name = 'tb_wf')
begin
create table tb_wf (
	wf_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, co_id uniqueidentifier
	, rec_type_code nvarchar(50)
	, wf_group nvarchar(50)
	, wf_code nvarchar(50)
	, wf_desc nvarchar(255)
	, is_in_use int
	, display_seq int
	, remarks nvarchar(255)
	, msg_subject nvarchar(max)
	, msg_body nvarchar(max)
)
end
go

-- 96. 
if not exists (select *from sys.objects where name = 'tb_wf_condition')
begin
create table tb_wf_condition (
	wf_condition_id uniqueidentifier
	, wf_id uniqueidentifier
	, seq int
	, fld nvarchar(255)
	, op nvarchar(50)
	, match_val nvarchar(max)
	, remarks nvarchar(255)
)
end
go

-- 97. 
if not exists (select *from sys.objects where name = 'tb_wf_email')
begin
create table tb_wf_email (
	wf_email_id uniqueidentifier
	, created_on datetime
	, created_by nvarchar(255)
	, wf_step_id uniqueidentifier
	, email nvarchar(255)
	, remarks nvarchar(255)
	, effective_from datetime
	, effective_to datetime
)
end
go

-- 98. 
if not exists (select *from sys.objects where name = 'tb_wf_rec_type')
begin
create table tb_wf_rec_type (
	wf_rec_type_id uniqueidentifier
	, created_on datetime
	, created_by nvarchar(255)
	, rec_type_group nvarchar(50)
	, rec_type_code nvarchar(50)
	, display_text nvarchar(255)
	, is_in_use int
	, display_seq int
	, on_process_sql nvarchar(255)
	, msg_subject nvarchar(max)
	, msg_body nvarchar(max)
	, on_get_receipint_sql nvarchar(255)
	, adhoc_appr_cnt int
)
end
go

-- 99.
if not exists (select *from sys.objects where name = 'tb_wf_request')
begin
create table tb_wf_request (
	wf_request_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, create_by nvarchar(255)
	, co_id uniqueidentifier
	, wf_rec_type_code nvarchar(50)
	, wf_code nvarchar(50)
	, id1 nvarchar(255)
	, id2 nvarchar(255)
	, id3 nvarchar(255)
	, id4 nvarchar(255)
	, id5 nvarchar(255)
	, url nvarchar(255)
	, val1 nvarchar(max)
	, val2 nvarchar(max)
	, val3 nvarchar(max)
	, remarks nvarchar(255)
	, first_process_on datetime
	, last_process_on datetime
	, status nvarchar(50)
	, curr_step int
	, stop_routing int
)
end
go

-- 100. 
if not exists (select *from sys.objects where name = 'tb_wf_request_email')
begin
create table tb_wf_request_email (
	request_email_id uniqueidentifier
	, wf_request_id uniqueidentifier
	, step int
	, mail_id uniqueidentifier
	, email nvarchar(255)
	, created_on datetime
	, last_send_try_on datetime
	, send_retry int
	, send_on datetime
	, read_on datetime
	, respond_on datetime
	, status nvarchar(50)
	, remarks nvarchar(255)
)
end
go

-- 101.
if not exists (select *from sys.objects where name = 'tb_wf_request_update_log')
begin
create table tb_wf_request_update_log (
	log_id uniqueidentifier
	, created_on datetime
	, created_by nvarchar(255)
	, wf_request_id uniqueidentifier
	, request_email_id uniqueidentifier 
	, status nvarchar(255)
	, remarks nvarchar(255)
	, val1 nvarchar(max)
	, val2 nvarchar(max)
	, val3 nvarchar(max)
	, send_on datetime 
	, process_on datetime
	, skip_send int
)
end
go

-- 102. 
if not exists (select *from sys.objects where name = 'tb_wf_status')
begin
create table tb_wf_status (
	status_code nvarchar(50)
	, created_on datetime
	, created_by nvarchar(255)
	, status_desc nvarchar(255)
	, is_in_use int
	, display_seq int
)
end
go

-- 103.
if not exists (select *from sys.objects where name = 'tb_wf_step')
begin
create table tb_wf_step (
	wf_step_id uniqueidentifier
	, wf_id uniqueidentifier
	, step int
	, description nvarchar(255)
	, no_of_appr int
	, auto_cxl_after_hours int
)
end
go

-- 104.
if not exists (select *from sys.objects where name = 'tb_tag_type')
begin
create table tb_tag_type (
	tag_type_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, create_by nvarchar(255)
	, co_id uniqueidentifier
	, tag_type nvarchar(50)
	, tag_type_desc nvarchar(255)
	, remarks nvarchar(255)
	, back_color nvarchar(50)
	, text_color nvarchar(50)
	, is_in_use int
	, display_seq nvarchar(50)
	, get_user_remarks int
	, parent_tag_type_id int
	, req_sub_tag_type_selection int
	, tag_type_group nvarchar(50)
	, tag_type_sub_group nvarchar(50)
	, user_fld0 nvarchar(255)
	, user_fld1 nvarchar(255)
	, user_fld2 nvarchar(255)
	, user_fld3 nvarchar(255)
	, user_fld4 nvarchar(255)
	, user_fld5 nvarchar(255)
	, user_fld6 nvarchar(255)
	, user_fld7 nvarchar(255)
	, user_fld8 nvarchar(255)
	, user_fld9 nvarchar(255)
)
end 
go

-- 105.
if not exists (select *from sys.objects where name = 'tb_notif_email')
begin
create table tb_notif_email (
	notif_email_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, create_by nvarchar(255)
	, co_id uniqueidentifier
	, notif_id int
	, email nvarchar(255)
	, remarks nvarchar(255)
	, effective_from datetime
	, effective_to datetime
)
end 
go

-- 106.
if not exists (select *from sys.objects where name = 'tb_profile')
begin
create table tb_profile (
	profile_id uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, profile_type nvarchar(5)
	, profile_code nvarchar(20)
	, profile_name nvarchar(255)
	, title nvarchar(50)
	, addr1 nvarchar(50)
	, addr2 nvarchar(50)
	, addr3 nvarchar(50)
	, phone nvarchar(50)
	, fax nvarchar(50)
	, contact nvarchar(50)
	, email nvarchar(255)
	, website nvarchar(255)
	, remarks nvarchar(max)
	, is_in_use int
	, dob datetime
	, membership_group_id uniqueidentifier
	, membership_type_id uniqueidentifier
	, student_id nvarchar(50)
	, student_expire_dt datetime
	, first_name nvarchar(50)
	, last_name nvarchar(50)
	, ic_no nvarchar(20)
	, nationality nvarchar(50)
	, remarks_admin nvarchar(max)
	, agreement_no nvarchar(50)
	, gender nchar(1)
	, bank_acct_no nvarchar(20)
	, bank_name nvarchar(50)
	, phone2 nvarchar(50)
	, mobile_phone nvarchar(50)
	, country nvarchar(50)
	, addr_state nvarchar(50)
	, postcode nvarchar(50)
	, acct_no nvarchar(50)
	, credit_limit money
	, total_visit int
	, last_check_in_on datetime
	, intro_profile_id uniqueidentifier
	, credit_days int
)
end
go

-- 107.
if not exists (select *from sys.objects where name = 'tb_org')
begin
create table tb_org(
	org_id int
	, org_name nvarchar(50)
	, org_img nvarchar(255)
	, org_status_id int
	, org_img_file_name nvarchar(255)
	, org_row_guid uniqueidentifier
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, org_code nvarchar(50)
)
end
go

-- 108
if not exists (select *from sys.objects where name = 'tb_org_status')
begin
create table tb_org_status (
	org_status_id int
	, org_status_desc nvarchar(20)
	, modified_on datetime
	, modified_by nvarchar(255)
	, created_on datetime
	, created_by nvarchar(255)
	, allow_login int
	, is_in_use int
)
end
go

-- 109 
if not exists (select * from sys.objects where name = 'tb_coupon_package_item')
begin
create table tb_coupon_package_item (
	coupon_package_item_id uniqueidentifier
	, created_on datetime
	, created_by nvarchar(255)
	, modified_on datetime
	, modified_by nvarchar(255)
	, coupon_id uniqueidentifier
	, seq int
	, prod_id uniqueidentifier
	, qty int
)
end
go

-- 110 
if not exists (select * from sys.objects where name = 'tb_prod_addon')
begin
create table tb_prod_addon (
	prod_addon_id uniqueidentifier
	, prod_id uniqueidentifier
	, condiment_id uniqueidentifier
	, request_group_code nvarchar(50)
	, addon_id uniqueidentifier
)
end
go

-- 111
if not exists (select * from sys.objects where name = 'tb_prod_printer')
begin
create table tb_prod_printer (
	created_on datetime
	, created_by nvarchar(255)
	, modified_on datetime 
	, modified_by nvarchar(255)
	, prod_id uniqueidentifier
	, printer_id uniqueidentifier
)
end
go

-- 112 
if not exists (select * from sys.objects where name = 'tb_printer')
begin
create table tb_printer (
	printer_id uniqueidentifier
	, created_on datetime
	, created_by nvarchar(255)
	, modified_on datetime 
	, modified_by nvarchar(255)
	, printer_code nvarchar(50)
	, printer_name nvarchar(255)
	, print_server_url nvarchar(255)
	, is_in_use int
	, display_seq int
	, is_default int
	, printer_type_id int
)
end
go

