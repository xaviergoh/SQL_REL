## SUPER-AMBITIOUS-INTEGRITY-CHECK-FOR-AGENCY-CARDS

# Commercial - Surplus accounts by business type

select count(distinct(caa.`uuid`)), cbt.`name`
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
where caa.`test_account`=0 
and cap.`product_filing_status` = "Non-Admitted"
and caa.`created_at` > date_sub(now(), INTERVAL 6 MONTH)
group by cbt.`name`;

# Commercial - Surplus accounts by status

select date_format(cap.`date_sold`,"%Y-%m"), count(distinct(caa.`uuid`)), caatm.`status`
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caa.`uuid`


where caa.`test_account`=0 
and cap.`product_filing_status` = "Non-Admitted"
and caatm.`team_role` = "Owner"
and convert_tz(caa.`created_at`,'utc','us/pacific') > date_sub(convert_tz(now(),'utc','us/pacific'), INTERVAL 6 MONTH)
group by caatm.`status`, date_format(cap.`date_sold`,"%Y-%m")
order by date_format(cap.`date_sold`,"%Y-%m"), caatm.`status`;

# Commercial - Average Number of Days to Close Sale for Surplus vs Normal by Month

select 
	date_format(caa.`created_at`,"%Y-%m") as 'datestamp', 
	convert_tz(caa.`created_at`, 'utc', 'us/pacific') as 'created_at',  
	cap.`product_filing_status`, 
	avg(datediff(cap.`date_sold`,convert_tz(caa.`created_at`, 'utc', 'us/pacific'))) as 'avg_days_to_close'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and cap.`product_filing_status` is not null
and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by date_format(caa.`created_at`,"%Y-%m"), cap.`product_filing_status`
order by date_format(caa.`created_at`,"%Y-%m"), cap.`product_filing_status`;


# Total Policies by Month and Agent
# Commercial - Total Policies by Month and Agent

select month(cap.`date_sold`), year(cap.`date_sold`), count(cap.`uuid`), cae.`name`
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees`cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
left join `commercial_business_segments` cbs on cbs.`id` = cbt.`commercial_business_segment_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by date_format(cap.`date_sold`,"%Y-%m"), cae.`name`
order by date_format(cap.`date_sold`,"%Y-%m") desc, cae.`name` asc;

# Commercial - Total Policies by Agent and Industry

select count(cap.`uuid`), cae.`name`, cbs.`name` as 'segment'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees`cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
left join `commercial_business_segments` cbs on cbs.`id` = cbt.`commercial_business_segment_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by cae.`name`, cbs.`name`
order by cae.`name` asc;

# Commercial - Total Policies by Agent and Carrier

select count(cap.`uuid`), cae.`name`, cac.`name` as 'carrier'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees`cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_carriers` cac on cac.`id` = cap.`commercial_agency_carrier_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by cae.`name`, cac.`name`
order by cae.`name` asc;

# Commercial - Total Premium by Agent and Carrier

select count(cap.`uuid`), sum(cap.`final_premium`), cae.`name`, cac.`name` as 'carrier'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees`cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_carriers` cac on cac.`id` = cap.`commercial_agency_carrier_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by cae.`name`, cac.`name`
order by cae.`name` asc;

# Commercial - Total Policies by Agent and Source
# Commercial - Total Policies by Agent by Source

select count(cap.`uuid`), cae.`name`, sources.`name` as 'carrier'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees`cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `sources` sources on sources.`id` = caa.`source_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by cae.`name`, sources.`name`
order by cae.`name` asc;

###
# Commercial - Total Sales and Cross-Sales by Agent
##
select
f.`employee`, 
count(f.`uuid`) as 'total_pol',
count(distinct(f.`commercial_agency_account_uuid`)) as 'unique_accounts',
count(case when f.`commercial_agency_account_uuid` in 
		(select crossSold.`commercial_agency_account_uuid` from 
			(select 
				cap.`commercial_agency_account_uuid`, count(*) as 'count' 
			from `commercial_agency_policies` cap
			left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
			where caa.`test_account`=0 
			and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
			group by cap.`commercial_agency_account_uuid`
			)crossSold 
		where crossSold.`count` > 1) then f.`commercial_agency_account_uuid` end)
 as 'total_cross_sales',
sum(case when f.`prod_id` = 7 then 1 else 0 end) as 'num_cyber',
sum(case when f.`prod_id` != 7 then 1 else 0 end) as 'num_comm'

from
(select cap.`commercial_agency_account_uuid`, cap.`uuid`, cap.`commercial_agency_quote_uuid`, cap.`commercial_agency_product_id` as 'prod_id', cap.`commercial_agency_employee_id`, cae.`name` as 'employee'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
) f

left join `commercial_agency_quotes` caq on caq.`uuid` = f.`commercial_agency_quote_uuid`
group by f.`employee`
order by f.`employee`;

# Commercial - Account Conversion by Agent

select owner_claim.`employee`, count(distinct(owner_claim.`uuid`)), sum(owner_claim.`sold`)
from
(select distinct caa.`uuid`, case when cap.`uuid` is not null then 1 else 0 end as 'sold', ifnull(cae.`name`, "Not Assigned") as 'employee'
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0 and caatm.`team_role` = "Owner") owner_claim
group by owner_claim.`employee`;

# Commercial - Monthly Average Premium

select sum(f.`final_premium`) / count(distinct(f.`commercial_agency_employee_id`)), f.`type`
from
(select cap.`commercial_agency_account_uuid`, cap.`final_premium`, cap.`commercial_agency_employee_id`, case when cap.`commercial_agency_product_id` = 7 then 'cyber' else 'comm' end as 'type'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and cap.`commercial_agency_employee_id` != 7
and cap.`date_sold` > "2018-09-31" and cap.`date_sold` < "2018-11-01") f
group by f.`type`;

# Commercial - Average Monthly Policies per IA split by commercial / cyber

select count(f.`uuid`) / count(distinct(f.`commercial_agency_employee_id`)), f.`type`
from
(select cap.`commercial_agency_account_uuid`, cap.`uuid`, cap.`commercial_agency_employee_id`, case when cap.`commercial_agency_product_id` = 7 then 'cyber' else 'comm' end as 'type'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and cap.`commercial_agency_employee_id` != 7
and cap.`date_sold` > "2018-09-31" and cap.`date_sold` < "2018-11-01"
/* and cap.`date_sold` > "2018-10-31" */) f
group by f.`type`;

# Commercial - Total Policies and Cross-Sales by Agent [x tally]

select
f.`employee`, 
count(f.`uuid`) as 'total_pol',

count(case when f.`commercial_agency_account_uuid` in 
		(select crossSold.`commercial_agency_account_uuid` from 
			(select 
				cap.`commercial_agency_account_uuid`, count(*) as 'count' 
			from `commercial_agency_policies` cap
			left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
			where caa.`test_account`=0 
			and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite") 
			group by cap.`commercial_agency_account_uuid`
			)crossSold 
		where crossSold.`count` > 1) then f.`commercial_agency_account_uuid` end)
 as 'total_cross_sales',
 
sum(case when f.`prod_id` = 7 then 1 else 0 end) as 'num_cyber',
sum(case when f.`prod_id` != 7 then 1 else 0 end) as 'num_comm'
from
(select cap.`commercial_agency_account_uuid`, cap.`uuid`, cap.`commercial_agency_product_id` as 'prod_id', cap.`commercial_agency_employee_id`, cae.`name` as 'employee'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
) f
group by f.`employee`
order by f.`employee`;

###
#Commercial - Lead Distribution by Agent
###
-- REVISIT

###
#Total Workers Compensation Policies by Agent [ x verified ]
###

select cae.`name` as 'employee', count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and cap.`commercial_agency_product_id` = 4
and cap.`date_sold` >= "2018-10-01"
group by cae.`name`
order by cae.`name`;

###
#Total Policies by Agent and Product
###

select cae.`name` as 'employee', caprod.`name` as 'product', count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cae.`name`, caprod.`name`
order by cae.`name`, caprod.`name`;

###
#Total Premium by Agent and Product
###

select cae.`name` as 'employee', caprod.`name` as 'product', sum(cap.`final_premium`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cae.`name`, caprod.`name`
order by cae.`name`, caprod.`name`;

###
#Commercial - QC Processed Applications by Month
###

select date_format(cap.`qc_completed_at`,"%Y-%m"),cae.`name`, count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`qc_employee_id`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by date_format(cap.`qc_completed_at`,"%Y-%m"), cae.`name`
order by date_format(cap.`qc_completed_at`,"%Y-%m"), cae.`name`;


###
#Commercial - Claimed Accounts with No Status by Agent
###

select caa.`uuid`, caatm.`status`, cae.`name`, cae.`role`
from `commercial_agency_account_team_memberships` caatm
left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0 and caatm.`team_role` = "Owner"
/* and cae.`role` in ("Agent", "Supervisor") */
and caatm.`status` is null
order by cae.`name`;

###
#Commercial - Total Lapsed Followups by Agent [Revisit Query...]
###
select 
lapsedAgent.`employee`, lapsedAgent.`uuid`, lapsedAgent.`latest_followup_id`, lapsedAgent.`Lapsed`
from
(select
	caa.`uuid`,
	cafu_latest.`fu_id` as 'latest_followup_id',
	caatm.`id` as 'caatm_id',
	case when (cafu_latest.`latest_scheduled` < now() and cafu_latest.`completed_at` is null) then 1 else 0 end as 'Lapsed',
	cae.`name` as 'employee'
from `commercial_agency_accounts` caa
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid`=caa.uuid 
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
inner join
#subtable to find latest follow up
 		(select cafu_1.`caatm_id`, cafu_1.`uuid`, cafu_1.`id` as 'fu_id', cafu_1.`created_at` as 'latest_followup_created', cafu_1.`scheduled_for` as 'latest_scheduled', cafu_1.`completed_at`
  		from
        (
        select caa.`uuid`, cafu.`id`, cafu.`created_at`, cafu.`scheduled_for`, cafu.`completed_at`, cafu.`commercial_agency_account_team_membership_id` as 'caatm_id'
         from `commercial_agency_follow_ups` cafu
        left join `commercial_agency_account_team_memberships` caatm on caatm.`id` = cafu.`commercial_agency_account_team_membership_id`
        left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`       
        ) cafu_1
        inner join
        (select caa.`uuid`, MAX(cafu.`created_at`) as 'latest_created'
         from `commercial_agency_follow_ups` cafu
        left join `commercial_agency_account_team_memberships` caatm on caatm.`id` = cafu.`commercial_agency_account_team_membership_id`
        left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`
        group by caa.`uuid`) cafu_2     
        on cafu_1.`uuid` = cafu_2.`uuid` and cafu_2.`latest_created` = cafu_1.`created_at`
		group by cafu_1.`uuid`
        )cafu_latest on caatm.`id` = cafu_latest.`caatm_id`
where caa.`test_account`=0
and caatm.`status` = "Follow-Up"
and cae.`role` = "Agent"
) lapsedAgent
where lapsedAgent.`Lapsed` > 0
/* group by lapsedAgent.`employee`; */
order by lapsedAgent.`employee`;

###
#Commercial - Total Quotes by Carrier and Product
###

select
	cac.`name` as 'carrier',caprod.`name` as 'product', count(caq.`uuid`) as 'num_quotes', avg(caq.`annual_premium`)
from `commercial_agency_quotes` caq
left join `commercial_agency_accounts` caa on caa.`uuid` = caq.`commercial_agency_account_uuid`
left join `commercial_agency_products` caprod on caprod.`id` = caq.`commercial_agency_product_id`
left join `commercial_agency_carriers` cac on cac.`id` = caq.`commercial_agency_carrier_id`
where caa.`test_account`=0
and date_format(caq.`created_at`, "%Y-%m") = date_format(now(), "%Y-%m")
/* and date_format(convert_tz(caq.`created_at`, 'utc', 'us/pacific'), "%Y-%m") = date_format(convert_tz(now(), 'utc','us/pacific'), "%Y-%m") */
and caq.`annual_premium` is not null
group by cac.`name`, caprod.`name`;

###
#Commercial - Total Scheduled Followups By Day and Intent
###

###
#Commercial - Total No Touch Leads
###

###
#Commercial - Total High Premium Quotes by Lead
###
-- Table containing shopper info on Leads which have quotes recorded of over $5000
select 
	convert_tz(caa.`created_at`, 'utc', 'us/pacific') as 'created_at',
	caa.`uuid` as 'caa_uuid', cae.`name` as 'employee', cafu.`intent`, sources.`name` as 'source', caq.`annual_premium`, caprod.`name` as 'product', cac.`name` as 'carrier'
	
from `commercial_agency_quotes` caq
left join `commercial_agency_accounts` caa on caa.`uuid` = caq.`commercial_agency_account_uuid`
left join `commercial_agency_products` caprod on caprod.`id` = caq.`commercial_agency_product_id`
left join `commercial_agency_carriers` cac on cac.`id` = caq.`commercial_agency_carrier_id`
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_follow_ups` cafu on cafu.`commercial_agency_account_team_membership_id` = caatm.`id`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
left join `sources` sources on sources.`id` = caa.`source_id`
where caa.`test_account`=0 and caq.`annual_premium` > 5000
/* and caatm.`team_role` = "Owner" and caatm.`status` = "Follow-Up" and cae.`role` in ("Agent") */
group by caa.`uuid`
order by caq.`created_at`;

###
#Commercial - Total Original and Cross Sold Policies by Agent Tenure
###

###
# Commercial - Avg. Monthly Sales per Agent by Month and Agent Tenure
###

###
# Commercial - Total Premium by Month and Agent Tenure
###

###
# Commercial - Avg. Premium per Agent by Month and Agent Tenure
###

###
# Commercial - Calls by Source by Hour
###
-- owned by Marketing

###
# Commercial - Cross Sales and Endorsements by Agent
###

select
f.`employee`, 
count(f.`uuid`) as 'total_pol',
count(distinct(f.`commercial_agency_account_uuid`)) as 'unique_accounts',
count(case when f.`commercial_agency_account_uuid` in 
		(select crossSold.`commercial_agency_account_uuid` from 
			(select 
				cap.`commercial_agency_account_uuid`, count(*) as 'count' 
			from `commercial_agency_policies` cap
			left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
			where caa.`test_account`=0 
			and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite") 
			group by cap.`commercial_agency_account_uuid`
			)crossSold 
		where crossSold.`count` > 1) then f.`commercial_agency_account_uuid` end)
 as 'total_cross_sales',
sum(case when f.`prod_id` = 7 then 1 else 0 end) as 'num_cyber',
sum(case when f.`prod_id` != 7 then 1 else 0 end) as 'num_comm',
count(caen.`id`) as 'num_end',
(count(f.`uuid`) + count(caen.`id`)) / count(distinct(f.`commercial_agency_account_uuid`)) as 'pol+endPerAccount'

from
(select cap.`commercial_agency_account_uuid`, cap.`uuid`, cap.`commercial_agency_quote_uuid`, cap.`commercial_agency_product_id` as 'prod_id', cap.`commercial_agency_employee_id`, cae.`name` as 'employee'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and year(cap.`date_sold`) = year(convert_tz(now(), 'utc','us/pacific'))
) f

left join `commercial_agency_quotes` caq on caq.`uuid` = f.`commercial_agency_quote_uuid`
left join `commercial_agency_endorsements` caen on caen.`commercial_agency_quote_uuid` = caq.`uuid`
group by f.`employee`
order by f.`employee`;


###
# Commercial - Comm. Auto Sales Metrics by Business Type
###

select 
	cbt.`name` as 'business_type',
	count(cap.`uuid`) as 'total_pol',
	sum(cap.`final_premium`) as 'final_premium'

from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and cap.`commercial_agency_product_id` = 5
group by cbt.`name`;

###
# Commercial - Comm. Auto Sales Metrics by State
###

select 
	states.`abbreviation` as 'state',
	count(cap.`uuid`) as 'total_pol',
	sum(cap.`final_premium`) as 'final_premium'

from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
left join `states` states on states.id = caa.`state_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and cap.`commercial_agency_product_id` = 5
group by states.`abbreviation`;

###
# Commercial - Comm. Auto Leads to Sales Conversion by Business Type
###

select 
	cbt.`name` as 'business_type',
	count(distinct(caa.`uuid`)) as 'total_accounts',
	count(distinct(case when caa.`uuid` in (select cap.`commercial_agency_account_uuid` from `commercial_agency_policies` cap where cap.`commercial_agency_product_id` = 5 /*comm auto*/) then caa.`uuid` end)) as 'total_sold_accounts', #distinct sold accounts
	count(distinct(case when caa.`uuid` in (select cap.`commercial_agency_account_uuid` from `commercial_agency_policies` cap where cap.`commercial_agency_product_id` = 5)then caa.`uuid` end))/ count(distinct(caa.`uuid`)) as 'conversion_rate'

from `commercial_agency_quotes` caq
left join `commercial_agency_accounts` caa on caa.`uuid` = caq.`commercial_agency_account_uuid`
left join `commercial_agency_policies` cap on cap.`commercial_agency_quote_uuid` = caq.`uuid`
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cbt.`name`;

###
#Commercial - Comm. Auto Lead to Sales Conversion by State
###

select 
	states.`name` as 'state',
	count(distinct(caa.`uuid`)) as 'total_accounts',
	count(distinct(case when caa.`uuid` in (select cap.`commercial_agency_account_uuid` from `commercial_agency_policies` cap where cap.`commercial_agency_product_id` = 5 /*comm auto*/) then caa.`uuid` end)) as 'total_sold_accounts', #distinct sold accounts
	count(distinct(case when caa.`uuid` in (select cap.`commercial_agency_account_uuid` from `commercial_agency_policies` cap where cap.`commercial_agency_product_id` = 5)then caa.`uuid` end))/ count(distinct(caa.`uuid`)) as 'conversion_rate'

from `commercial_agency_quotes` caq
left join `commercial_agency_accounts` caa on caa.`uuid` = caq.`commercial_agency_account_uuid`
left join `commercial_agency_policies` cap on cap.`commercial_agency_quote_uuid` = caq.`uuid`
left join `states` states on states.`id` = caa.`state_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by states.`name`;

###
#Commercial - Accounts Assisted by Commercial Associate
###

select
	date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m"), 
	count(distinct(caa.`uuid`)) as 'total_accounts',
	
	count(distinct(case when caa.`uuid` in 
		(select caatm.`commercial_agency_account_uuid` 
		from `commercial_agency_account_team_memberships` caatm
		where caatm.`team_role` = "CA Lead" and caatm.`commercial_agency_employee_id` is not null)
		then caa.`uuid` end)) as 'total_assisted',
	count(distinct(case when caa.`uuid` in 
		(select caatm.`commercial_agency_account_uuid` 
		from `commercial_agency_account_team_memberships` caatm
		where caatm.`team_role` = "CA Lead" and caatm.`commercial_agency_employee_id` is not null)
		then caa.`uuid` end)) / count(distinct(caa.`uuid`)) as 'percentage_assist'

from `commercial_agency_accounts` caa
where caa.`test_account`=0 
group by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m")
order by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m");

###
#Commercial - Sold Accounts Assisted by Commercial Associate
###

select
	date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m"), 
	count(distinct(cap.`commercial_agency_account_uuid`)) as 'total_sold_accounts',
	
	count(distinct(case when cap.`commercial_agency_account_uuid` in 
		(select caatm.`commercial_agency_account_uuid` 
		from `commercial_agency_account_team_memberships` caatm
		where caatm.`team_role` = "CA Lead" and caatm.`commercial_agency_employee_id` is not null)
		then caa.`uuid` end)) as 'total_assisted',
	count(distinct(case when cap.`commercial_agency_account_uuid` in 
		(select caatm.`commercial_agency_account_uuid` 
		from `commercial_agency_account_team_memberships` caatm
		where caatm.`team_role` = "CA Lead" and caatm.`commercial_agency_employee_id` is not null)
		then caa.`uuid` end)) / count(distinct(caa.`uuid`)) as 'percentage_assist'

from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m")
order by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m");

###
#PAD and PAM Monthly Stats - Commercial
###

###
#Monthly PAM - Commercial
###

###
#Monthly PAD - Commercial
###

###
#Commercial and Cyber - Attempt Rate by OB Rep
###
-- Attempt rate for a rep = Total attempts completed by rep / Total accounts assigned to the rep.
select
	cae.`name` as 'employee', case when caatm.`status` like "%closed%" then "Closed" else caatm.`status` end as 'status', count(distinct(caatm.`commercial_agency_account_uuid`)) as 'accounts', 
	avg(cafu.`attempt`) as 'avg_attempt_v1',
	sum(cafu.`attempt`) / count(distinct(caatm.`commercial_agency_account_uuid`)) as 'avg_attempts_v2'
	
from `commercial_agency_account_team_memberships` caatm
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`
left join `commercial_agency_follow_ups` cafu on cafu.`commercial_agency_account_team_membership_id` = caatm.`id`
where caa.`test_account`=0 and cae.`role` = "Outbound"
group by cae.`name`, case when caatm.`status` like "%closed%" then "Closed" else caatm.`status` end
order by cae.`name`, case when caatm.`status` like "%closed%" then "Closed" else caatm.`status` end;

-- test case gloria
select sum(f.`attempt`) / count(distinct(f.`commercial_agency_account_uuid`)) as 'avg'
from 
(
select caatm.`commercial_agency_account_uuid`, cafu.`attempt`, caatm.`commercial_agency_employee_id`
from `commercial_agency_account_team_memberships` caatm
left join `commercial_agency_follow_ups` cafu on cafu.`commercial_agency_account_team_membership_id` = caatm.`id`
left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`
where caa.`test_account`=0 and caatm.`commercial_agency_employee_id` = 191
) f;

###
#Commercial - Attempt Rate on Strike Rule Accounts by OB Rep (Based on Completed Followups) [x verified]
###
-- Attempt rate for a given period of account closure = Total completed followups on accounts closed due to strike rule/ Total accounts closed due to strike rule

select date_format(convert_tz(caacri.`created_at`, 'utc', 'us/pacific'), "%Y-%m") as 'year-month', count(cafu.`id`),
count(distinct(caacri.`commercial_agency_account_uuid`)) as 'total_acc',
(count(cafu.`id`)) /*total followups*/ / count(distinct(caacri.`commercial_agency_account_uuid`)) as 'attempt_rate'

from `commercial_agency_follow_ups` cafu
left join `commercial_agency_account_team_memberships` caatm on caatm.`id` = cafu.`commercial_agency_account_team_membership_id`
left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`
left join `commercial_agency_account_closure_reason_instances` caacri on caacri.`commercial_agency_account_uuid`= caa.`uuid`
left join `commercial_agency_account_closure_reasons` caacr on caacr.`id`= caacri.`closure_reason_id`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0
and cae.`role` = "Outbound"
and caacr.`reason` = "Strike Rule"
/* and cafu.`completed_at` is not null */
group by date_format(convert_tz(caacri.`created_at`, 'utc', 'us/pacific'), "%Y-%m")
order by date_format(convert_tz(caacri.`created_at`, 'utc', 'us/pacific'), "%Y-%m");

-- 2018 apr test for Alaina
select count(cafu.`id`), avg(cafu.`attempt`)
from `commercial_agency_follow_ups` cafu
left join `commercial_agency_account_team_memberships` caatm on caatm.`id` = cafu.`commercial_agency_account_team_membership_id`
left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`
left join `commercial_agency_account_closure_reason_instances` caacri on caacri.`commercial_agency_account_uuid`= caa.`uuid`
left join `commercial_agency_account_closure_reasons` caacr on caacr.`id`= caacri.`closure_reason_id`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0 
and cae.`role` = "Outbound" and date_format(convert_tz(caacri.`created_at`, 'utc', 'us/pacific'), "%Y-%m") = "2018-04" 
and cae.`id` = 147
and caacr.`reason` = "Strike Rule";

select
cafu.attempt
/* , avg(cafu.attempt) */
from commercial_agency_follow_ups cafu
left join `commercial_agency_account_team_memberships` caatm on caatm.`id` = cafu.`commercial_agency_account_team_membership_id`
left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`
left join `commercial_agency_account_closure_reason_instances` caacri on caacri.`commercial_agency_account_uuid`= caa.`uuid`
left join `commercial_agency_account_closure_reasons` caacr on caacr.`id`= caacri.`closure_reason_id`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0 
and cae.`role` = "Outbound" and date_format(convert_tz(caacri.`created_at`, 'utc', 'us/pacific'), "%Y-%m") = "2018-04" 
and cae.`id` = 147
and caacr.`reason` = "Strike Rule";

###
#Commercial - Attempt Rate on Strike Rule Accounts by OB Rep (Based on Calls Data)
###
-- Attempt rate for a given period of account closure = Total attempts on accounts closed due to strike rule/ Total accounts closed due to strike rule


###
#Commercial and Cyber - Distribution of OB Rep Calls by Variance
###
-- Y-axis of this card divides the accounts assigned to each OB rep in two buckets - one containing accounts that are always called in the same time bucket (either AM or PM) and the other where accounts are called in both the time buckets.

###
#Personal Lines - Distribution of OB Rep Calls by Variance
###
-- Y-axis of this card divides the accounts assigned to each OB rep in two buckets - one containing accounts that are always called in the same time bucket (either AM or PM) and the other where accounts are called in both the time buckets.

###
#Commercial - Total Policies (including endorsements) by Agent and Product [Good ref]
###

select cae.`name` as 'employee', caprod.`name` as 'product', count(cap.`uuid`) as 'num_pol', count(caen.`id`) as 'num_end'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
left join `commercial_agency_quotes` caq on caq.`uuid` = cap.`commercial_agency_quote_uuid`
left join `commercial_agency_endorsements` caen on caen.`commercial_agency_quote_uuid` = caq.`uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cae.`name`, caprod.`name`
order by cae.`name`, caprod.`name`;

###
#Commercial - Total Number of Quote Proposals created by IA/Associate
###

select cae.`name`, count(caad.`uuid`) as 'num_proposals'
from `commercial_agency_account_documents` caad
join `commercial_agency_employees` cae on cae.id = caad.`uploader_id`
join `commercial_agency_accounts` caa on caa.uuid = caad.`commercial_agency_account_uuid`
where caa.`test_account`=0 and caad.`document_file_name` like "CoverHound_QuoteProposal%"
group by cae.`name`
order by count(caad.`uuid`) desc;

###
#Commercial - Number of Quote Proposals generated by groupings and individuals
###

/* The number of quote proposals generated by a team or individual where teams are defined as :
1. Vahan / Jocelyn
2. Carlos / Erik
3. Irma / Sheena
4. Scott / Kendall
5. Felix / Kendall
6. Brent / Ben
Any other IA and agent not listed is shown as an individual */

select 
	case when cae.`name` like "%vahan%" or cae.`name` like "%jocelyn%" then 'Vahan / Jocelyn'
		when cae.`name` like "%carlos%" or cae.`name` like "%erik%" then 'Carlos / Erik'
		when cae.`name` like "%irma%" or cae.`name` like "%sheena%" then 'Irma / Sheena'
		when cae.`name` like "%scott%" or cae.`name` like "%kendall%" then 'Scott / Kendall'
		when cae.`name` like "%felix%" or cae.`name` like "%kendall%" then 'Felix / Kendall'
		when cae.`name` like "%brent%" or cae.`name` like "%ben%" then 'Brent / Ben'
	else cae.`name` end as 'group_ind',

	count(caad.`uuid`) as 'num_proposals'
from `commercial_agency_account_documents` caad
join `commercial_agency_employees` cae on cae.id = caad.`uploader_id`
join `commercial_agency_accounts` caa on caa.uuid = caad.`commercial_agency_account_uuid`
where caa.`test_account`=0 and caad.`document_file_name` like "CoverHound_QuoteProposal%"
group by case when cae.`name` like "%vahan%" or cae.`name` like "%jocelyn%" then 'Vahan / Jocelyn'
		when cae.`name` like "%carlos%" or cae.`name` like "%erik%" then 'Carlos / Erik'
		when cae.`name` like "%irma%" or cae.`name` like "%sheena%" then 'Irma / Sheena'
		when cae.`name` like "%scott%" or cae.`name` like "%kendall%" then 'Scott / Kendall'
		when cae.`name` like "%felix%" or cae.`name` like "%kendall%" then 'Felix / Kendall'
		when cae.`name` like "%brent%" or cae.`name` like "%ben%" then 'Brent / Ben'
	else cae.`name` end
order by count(caad.`uuid`) desc;

###
#Commercial - Average Quote Proposal per Account split by 6x6 member or not
###

select
	agentProposals.`group-ind`, count(agentProposals.`uuid`) as 'num_proposals', 
	count(distinct(agentProposals.`caa_uuid`)) as 'total_acc',
	count(agentProposals.`uuid`) / count(distinct(agentProposals.`caa_uuid`)) as 'average_proposals'
from
(select
	convert_tz(caad.`created_at`,'utc','us/pacific') as 'created_at',
	caad.`uuid`,
	caa.`uuid` as 'caa_uuid',
	case when cae.`name` like "%vahan%" or cae.`name` like "%jocelyn%" or cae.`name` like "%carlos%" 
			or cae.`name` like "%erik%" or cae.`name` like "%irma%" or cae.`name` like "%sheena%"
			or cae.`name` like "%scott%" or cae.`name` like "%felix%" or cae.`name` like "%kendall%"
			or cae.`name` like "%brent%" or cae.`name` like "%ben%" then 'member' else 'non-member'
	end as 'group-ind'
	

from `commercial_agency_account_documents` caad
join `commercial_agency_employees` cae on cae.id = caad.`uploader_id`
join `commercial_agency_accounts` caa on caa.uuid = caad.`commercial_agency_account_uuid`
where caa.`test_account`=0 and caad.`document_file_name` like "CoverHound_QuoteProposal%"
)agentProposals
group by agentProposals.`group-ind`;


###
#Commercial and Cyber Total Premium by IA
###

select cae.`name`, count(cap.`uuid`) as 'num_pol', 
count(case when cap.`commercial_agency_product_id` != 7 then cap.`uuid` end) as 'commercial',
count(case when cap.`commercial_agency_product_id` = 7 then cap.`uuid` end) as 'cyber',
sum(cap.`final_premium`) as 'total_premium',
sum(case when cap.`commercial_agency_product_id` != 7 then cap.`final_premium` end) as 'comm_prenmium',
sum(case when cap.`commercial_agency_product_id` = 7 then cap.`final_premium` end) as 'cyber_premium'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees`cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_carriers` cac on cac.`id` = cap.`commercial_agency_carrier_id`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cae.`name`
order by cae.`name` asc;

###
#Commercial and Cyber Average Premium by IA
###

select cae.`name`, count(cap.`uuid`) as 'num_pol', 
count(case when cap.`commercial_agency_product_id` != 7 then cap.`uuid` end) as 'commercial',
count(case when cap.`commercial_agency_product_id` = 7 then cap.`uuid` end) as 'cyber',
avg(cap.`final_premium`) as 'total_premium',
avg(case when cap.`commercial_agency_product_id` != 7 then cap.`final_premium` end) as 'comm_prenmium',
avg(case when cap.`commercial_agency_product_id` = 7 then cap.`final_premium` end) as 'cyber_premium'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees`cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_carriers` cac on cac.`id` = cap.`commercial_agency_carrier_id`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cae.`name`
order by cae.`name` asc;

###
#Commercial and Policies Sold per Account by IA [x verified]
###
-- Includes Endorsements...

select cae.`name`, count(cap.`uuid`) as 'num_pol', 
count(case when cap.`commercial_agency_product_id` != 7 then cap.`uuid` end) as 'commercial_pol',
count(case when cap.`commercial_agency_product_id` = 7 then cap.`uuid` end) as 'cyber_pol',
count(distinct(cap.`commercial_agency_account_uuid`)) as 'total_accounts',
count(distinct(case when cap.`commercial_agency_product_id` != 7 then cap.`commercial_agency_account_uuid` end)) as 'commercial_accounts',
count(distinct(case when cap.`commercial_agency_product_id` = 7 then cap.`commercial_agency_account_uuid` end)) as 'cyber_accounts',
count(case when cap.`commercial_agency_product_id` != 7 then cap.`uuid` end) / 
count(distinct(case when cap.`commercial_agency_product_id` != 7 then cap.`commercial_agency_account_uuid` end)) as 'avg_pol_commercial',
count(case when cap.`commercial_agency_product_id` = 7 then cap.`uuid` end) / 
count(distinct(case when cap.`commercial_agency_product_id` = 7 then cap.`commercial_agency_account_uuid` end)) as 'avg_pol_cyber'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees`cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `commercial_agency_carriers` cac on cac.`id` = cap.`commercial_agency_carrier_id`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cae.`name`
order by cae.`name` asc;

###
#Agents Account Conversion
###
-- filter status "no market"
select cae.`name`, count(distinct(caa.`uuid`)) as 'total_accounts', count(distinct(cap.`commercial_agency_account_uuid`)) as 'sold_accounts', count(distinct(caa.`uuid`)) - count(distinct(cap.`commercial_agency_account_uuid`)) as 'unsold_accounts' 
from `commercial_agency_accounts` caa
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0
and caatm.`team_role` = "Owner"
and ifnull(caatm.`status`, "n") not like "%no market%"
group by cae.`name`
order by cae.`name`;

###
#Commercial - Total Policies by Agent and Source
###

select cae.`name` as 'employee', sources.`name` as 'source', count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
left join `sources` sources on sources.`id` = caa.`source_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cae.`name`, sources.`name`
order by cae.`name`, sources.`name`;

###
#Commercial - Percentage of Sales that are monoline by Agent [x verified]
###
 -- monoline sale is a sale to an account with just 1 single product with no endorsements

select percentMono.*, count(distinct cap2.`commercial_agency_account_uuid`) as 'total_sold',
percentMono.`mono_accounts` / count(distinct cap2.`commercial_agency_account_uuid`) as 'percentage_monoline'
from

(select cae.`name` as 'employee', cae.`id`, count(distinct cap.`commercial_agency_account_uuid`) as 'mono_accounts'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = cap.`commercial_agency_employee_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and cap.`commercial_agency_account_uuid` not in
	#accounts with sold policy AND endorsement
	(select distinct caq.`commercial_agency_account_uuid`
	from `commercial_agency_quotes` caq
	where exists
	# quotes with sold policy AND endorsement
	(select distinct caen.`commercial_agency_quote_uuid`, caen.`id`
	from `commercial_agency_endorsements` caen
	left join `commercial_agency_policies` cap on cap.`commercial_agency_quote_uuid` = caen.`commercial_agency_quote_uuid`
	where caen.`commercial_agency_quote_uuid` = caq.`uuid`)
	)
and cap.`commercial_agency_account_uuid` not in 
	#accounts with >1 sold policy
	(select cap.`commercial_agency_account_uuid` from `commercial_agency_policies` cap
	group by cap.`commercial_agency_account_uuid`
	having count(*) > 1
	)
group by cae.`name`
order by cae.`name`) percentMono
left join `commercial_agency_policies` cap2 on cap2.`commercial_agency_employee_id` = percentMono.`id`
group by percentMono.`employee`
order by percentMono.`employee`;

###
#Commercial - Leads to Sales Conversion by time
###

select date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m") as 'date',
count(distinct(caa.`uuid`)) as 'total_accounts', count(distinct(cap.`commercial_agency_account_uuid`)) as 'sold_accounts',
count(distinct(caa.`uuid`)) - count(distinct(cap.`commercial_agency_account_uuid`)) as 'unsold_accounts',
count(distinct(cap.`commercial_agency_account_uuid`)) / count(distinct(caa.`uuid`)) as 'percentage_sold'

from `commercial_agency_accounts` caa
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0
and cae.`role` in ("Agent","IA Supervisor","Supervisor")
and cae.`name` not in ("Amber Bachman", "Anthony Huerta", "Cyberman Online Sale", "Jesse Contreas", "Joe Perry", "Kellie Wilson", "Maurice John", "Randy Padilla")
group by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m")
order by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m");


###
#Commercial - Lead to sale conversion rate by day and time of lead creation
###

select
	hour(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) as 'hour',
	dayname(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) as 'day_of_week',
	count(distinct(caa.`uuid`)) as 'total_accounts', count(distinct(cap.`commercial_agency_account_uuid`)) as 'sold_accounts',
	count(distinct(caa.`uuid`)) - count(distinct(cap.`commercial_agency_account_uuid`)) as 'unsold_accounts',
	count(distinct(cap.`commercial_agency_account_uuid`)) / count(distinct(caa.`uuid`)) as 'percentage_sold'

from `commercial_agency_accounts` caa
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0
and year(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) = year(now())
group by hour(convert_tz(caa.`created_at`, 'utc', 'us/pacific')),
	dayname(convert_tz(caa.`created_at`, 'utc', 'us/pacific'))
order by hour(convert_tz(caa.`created_at`, 'utc', 'us/pacific')),
	dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) asc;
	
###
#Commercial - Number of Quote Proposals generate
###
/* The number of quote proposals generated by a team or individual where teams are defined as :
1. Vahan / Jocelyn
2. Carlos / Arlene
3. Irma / Erik
4. Scott / Sheena
5. Felix / Kendall
6. Brent / Ben
Any other IA and agent not listed is shown as an individual */
select 
	case when cae.`name` like "%vahan%" or cae.`name` like "%jocelyn%" then 'Vahan / Jocelyn'
		when cae.`name` like "%carlos%" or cae.`name` like "%arlene%" then 'Carlos / Arlene'
		when cae.`name` like "%irma%" or cae.`name` like "%erik%" then 'Irma / Erik'
		when cae.`name` like "%scott%" or cae.`name` like "%sheena%" then 'Scott / Sheena'
		when cae.`name` like "%Felix Monarrez%" or cae.`name` like "%Kendall Peters%" then 'Felix / Kendall'
		when cae.`name` like "%brent%" or cae.`name` like "%Ben Gross%"then 'Brent / Ben'
	else cae.`name` end as 'group_ind',

	count(caad.`uuid`) as 'num_proposals'
from `commercial_agency_account_documents` caad
join `commercial_agency_employees` cae on cae.id = caad.`uploader_id`
join `commercial_agency_accounts` caa on caa.uuid = caad.`commercial_agency_account_uuid`
where caa.`test_account`=0 and caad.`document_file_name` like "CoverHound_QuoteProposal%"
group by case when cae.`name` like "%vahan%" or cae.`name` like "%jocelyn%" then 'Vahan / Jocelyn'
		when cae.`name` like "%carlos%" or cae.`name` like "%arlene%" then 'Carlos / Arlene'
		when cae.`name` like "%irma%" or cae.`name` like "%erik%" then 'Irma / Erik'
		when cae.`name` like "%scott%" or cae.`name` like "%sheena%" then 'Scott / Sheena'
		when cae.`name` like "%Felix Monarrez%" or cae.`name` like "%Kendall Peters%" then 'Felix / Kendall'
		when cae.`name` like "%brent%" or cae.`name` like "%Ben Gross%" then 'Brent / Ben'
	else cae.`name` end
order by cae.`name`;

###
#Commercial - Total number of leads over time by type of day (Weekday/Weekend)
###
select 
	weeklyLeads.`date` as 'year-week', weeklyLeads.`week_leads`,weeklyLeads.`weekday_leads`,weeklyLeads.`weekend_leads`,
	weeklyLeads.`weekday_leads`/weeklyLeads.`week_leads` as 'weekday_percent',
	weeklyLeads.`weekend_leads`/weeklyLeads.`week_leads` as 'weekend_percent'
from
(select date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%X-%V") as 'date',
count(distinct(caa.`uuid`)) as 'week_leads',
count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then caa.`uuid` end)) as 'weekday_leads',
count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then caa.`uuid` end)) as 'weekend_leads'
from `commercial_agency_accounts` caa
where caa.`test_account`=0
group by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%X-%V")
order by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%X-%V")
)weeklyLeads
order by weeklyLeads.`date`;

###
#Commercial - Total number of policies and endorsements sold over time by type of day (Weekday/Weekend)
###

select 
	weeklyPols.`date` as 'year-week', 
	weeklyPols.`week_policies`,
	weeklyPols.`weekday_pols`,
	weeklyPols.`weekend_pols`,
	weeklyPols.`weekday_pols`/weeklyPols.`week_policies` as 'weekday_percent_pol',
	weeklyPols.`weekend_pols`/weeklyPols.`week_policies` as 'weekend_percent_pol',
	
	weeklyEnds.`date` as 'year-week', 
	weeklyEnds.`week_endorsements`,
	weeklyEnds.`weekday_ends`,
	weeklyEnds.`weekend_ends`,
	weeklyEnds.`weekday_ends`/weeklyEnds.`week_endorsements` as 'weekday_percent_end',
	weeklyEnds.`weekend_ends`/weeklyEnds.`week_endorsements` as 'weekend_percent_end',
	
	(weeklyPols.`weekday_pols` + weeklyEnds.`weekday_ends`) /
	(weeklyEnds.`week_endorsements` + weeklyPols.`week_policies`) as 'weekday_percentage_total',
	
	(weeklyPols.`weekend_pols` + weeklyEnds.`weekend_ends`) /
	(weeklyEnds.`week_endorsements` + weeklyPols.`week_policies`) as 'weekday_percentage_total'
	
from

(select 
	date_format(cap.`date_sold`, "%X-%V") as 'date',
	count(distinct(cap.`uuid`)) as 'week_policies',
	count(distinct(case when dayofweek(cap.`date_sold`) in (2,3,4,5,6) then cap.`uuid` end)) as 'weekday_pols',
	count(distinct(case when dayofweek(cap.`date_sold`) in (1,7) then cap.`uuid` end)) as 'weekend_pols'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_endorsements` caen on caen.`commercial_agency_quote_uuid` = cap.`commercial_agency_quote_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by date_format(cap.`date_sold`, "%X-%V")
order by date_format(cap.`date_sold`, "%X-%V")
)weeklyPols

left join

(select 
	date_format(convert_tz(caen.`created_at`, 'utc', 'us/pacific'), "%X-%V") as 'date',
	count(distinct(caen.`id`)) as 'week_endorsements',
	count(distinct(case when dayofweek(convert_tz(caen.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then caen.`id` end)) as 'weekday_ends',
	count(distinct(case when dayofweek(convert_tz(caen.`created_at`, 'utc', 'us/pacific')) in (1,7) then caen.`id` end)) as 'weekend_ends'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_endorsements` caen on caen.`commercial_agency_quote_uuid` = cap.`commercial_agency_quote_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by date_format(convert_tz(caen.`created_at`, 'utc', 'us/pacific'), "%X-%V")
order by date_format(convert_tz(caen.`created_at`, 'utc', 'us/pacific'), "%X-%V")
)weeklyEnds on weeklyEnds.`date` = weeklyPols.`date`

order by weeklyPols.`date`;

###
#Commercial -Lead to Sale Conversion rate over time by type of day (Weekday/Weekend)
###

select 
	date_format(caa.`created_at`, "%X-%V") as 'created_at',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then caa.`uuid` end)) as 'weekday_accs',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then caa.`uuid` end)) as 'weekend_accs',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then cap.`commercial_agency_account_uuid` end)) as 'weekday_sold_accs',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then cap.`commercial_agency_account_uuid` end)) as 'weekend_sold_accs',
	
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then cap.`commercial_agency_account_uuid` end)) /
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then caa.`uuid` end))
	as 'weekday_conversion',
	
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then cap.`commercial_agency_account_uuid` end)) /
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then caa.`uuid` end))
	as 'weekend_conversion'
	
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
where caa.`test_account`=0
group by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%X-%V")
order by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%X-%V");

###
#Commercial - Lead to Sale Conversion rate by IA by type of day (Weekday/Weekend) lead created
###

select 
	cae.`name` as 'employee',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then caa.`uuid` end)) as 'weekday_accs',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then caa.`uuid` end)) as 'weekend_accs',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then cap.`commercial_agency_account_uuid` end)) as 'weekday_sold_accs',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then cap.`commercial_agency_account_uuid` end)) as 'weekend_sold_accs',
	
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then cap.`commercial_agency_account_uuid` end)) /
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then caa.`uuid` end))
	as 'weekday_conversion',
	
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then cap.`commercial_agency_account_uuid` end)) /
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then caa.`uuid` end))
	as 'weekend_conversion'
	
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and convert_tz(caa.`created_at`, 'utc', 'us/pacific') > "2018-01-01 00:00:00"
group by cae.`name`
order by cae.`name`;

###
#Commercial - Average Number of Days to Close Sale for weekday vs weekend by Month
###


select 
	date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m") as 'created_at',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then caa.`uuid` end)) as 'weekday_accs',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then caa.`uuid` end)) as 'weekend_accs',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then cap.`commercial_agency_account_uuid` end)) as 'weekday_sold_accs',
	count(distinct(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then cap.`commercial_agency_account_uuid` end)) as 'weekend_sold_accs',
	
	sum(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then datediff(cap.`created_at`, caa.`created_at`) end) /
	count((case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (2,3,4,5,6) then cap.`commercial_agency_account_uuid` end)) as 'avg_date_diff_weekday',
	sum(case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then datediff(cap.`created_at`, caa.`created_at`) end) / 
	count((case when dayofweek(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (1,7) then cap.`commercial_agency_account_uuid` end)) as 'avg_date_diff_weekend'
	
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m")
order by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%Y-%m");


###
#Commercial - Top leads by business type business types
###

select
cbt.`name` as 'business_type', count(distinct(caa.`uuid`)) as 'total_leads'
from `commercial_agency_accounts` caa
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
where caa.`test_account`=0 and year(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) = year(convert_tz(now(),'utc','us/pacific'))
group by cbt.`name`
order by cbt.`name`;


###
#Commercial - Percent IA accounts sent to CAs by Agent
###

select
cae.`name` as 'employee',
count(distinct(caatm.`commercial_agency_account_uuid`)) as 'total_accounts',
count(case when caatm.`commercial_agency_account_uuid` in (select caatm.`commercial_agency_account_uuid` from `commercial_agency_account_team_memberships` caatm where caatm.`team_role` = "CA Lead" and caatm.`commercial_agency_employee_id` is not null) then caatm.`commercial_agency_account_uuid` end) as 'accounts_sent',

count(case when caatm.`commercial_agency_account_uuid` in (select caatm.`commercial_agency_account_uuid` from `commercial_agency_account_team_memberships` caatm where caatm.`team_role` = "CA Lead" and caatm.`commercial_agency_employee_id` is not null) then caatm.`commercial_agency_account_uuid` end) /
count(distinct(caatm.`commercial_agency_account_uuid`)) as 'percentage_sent'

from `commercial_agency_account_team_memberships` caatm
left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0 and convert_tz(caa.`created_at`,'utc','us/pacific') > "2018-05-01 00:00:00"
group by cae.`name`
order by cae.`name`;


###
#Commercial - Percent IA accounts sent to CAs by Agent
###

select
date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%X-%V"),
count(distinct(caatm.`commercial_agency_account_uuid`)) as 'total_accounts',
count(case when caatm.`commercial_agency_account_uuid` in (select caatm.`commercial_agency_account_uuid` from `commercial_agency_account_team_memberships` caatm where caatm.`team_role` = "CA Lead" and caatm.`commercial_agency_employee_id` is not null) then caatm.`commercial_agency_account_uuid` end) as 'accounts_sent',

count(case when caatm.`commercial_agency_account_uuid` in (select caatm.`commercial_agency_account_uuid` from `commercial_agency_account_team_memberships` caatm where caatm.`team_role` = "CA Lead" and caatm.`commercial_agency_employee_id` is not null) then caatm.`commercial_agency_account_uuid` end) /
count(distinct(caatm.`commercial_agency_account_uuid`)) as 'percentage_sent'

from `commercial_agency_account_team_memberships` caatm
left join `commercial_agency_accounts` caa on caa.`uuid` = caatm.`commercial_agency_account_uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0 and convert_tz(caa.`created_at`,'utc','us/pacific') > "2018-05-01 00:00:00"
and cae.`role` in ("Agent","IA Supervisor")
and cae.`name` not in ("Amber Bachman", "Anthony Huerta", "Cyberman Online Sale", "Kellie Wilson")
group by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%X-%V")
order by date_format(convert_tz(caa.`created_at`, 'utc', 'us/pacific'), "%X-%V");


###
#Commercial - Offline Quotes by Agent split by Product
###

select cae.`name` as 'employee', caprod.`name` as 'product', count(caq.`uuid`) as 'count'
from `commercial_agency_quotes` caq
left join `commercial_agency_accounts` caa on caa.`uuid` = caq.`commercial_agency_account_uuid`
left join `commercial_agency_products` caprod on caprod.`id` = caq.`commercial_agency_product_id`
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0
and caq.`origin` = "portal"
/* and caq.annual_premium is not null and caq.`annual_premium` <> 0 and caq.outcome <>'referral' */
and cae.`name` not in ("Kendall Diaz") and cae.`name` is not null
group by cae.`name`, caprod.`name`
order by cae.`name`, caprod.`name`;

###
#Commercial - Offline Quotes by CA Lead filtered by Product and Carrier
###

select cae.`name` as 'employee', caprod.`name` as 'product', count(caq.`uuid`) as 'count'
from `commercial_agency_quotes` caq
left join `commercial_agency_accounts` caa on caa.`uuid` = caq.`commercial_agency_account_uuid`
left join `commercial_agency_products` caprod on caprod.`id` = caq.`commercial_agency_product_id`
left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
where caa.`test_account`=0
and caq.`origin` = "portal"
/* and caq.annual_premium is not null and caq.`annual_premium` <> 0 and caq.outcome <>'referral' */
and cae.`name` not in ("Kendall Diaz") and cae.`name` is not null
and caprod.`id` is not null
group by cae.`name`, caprod.`name`
order by cae.`name`, caprod.`name`;

###
#Commercial - Average Number of Carriers Per Associate Split by Product
###

select quotedCarriersProd.`employee`, quotedCarriersProd.`product`, 
sum(quotedCarriersProd.`carriers_quotedProduct`) / count(quotedCarriersProd.`caa_uuid`) as 'average_carriers_prod'
from
	(select caQuotes.`employee`, caQuotes.`caa_uuid`, caQuotes.`product`, count(distinct caQuotes.`carrier`) as 'carriers_quotedProduct'
	 from 
		(select
		caq.`uuid`, caa.`uuid` as 'caa_uuid', cae.`name` as 'employee', caprod.`name` as 'product', cac.`name` as 'carrier'
		from `commercial_agency_quotes` caq
		left join `commercial_agency_products` caprod on caprod.`id`= caq.`commercial_agency_product_id`
		left join `commercial_agency_account_team_memberships` caatm on caatm.`commercial_agency_account_uuid` = caq.`commercial_agency_account_uuid`
		inner join `commercial_agency_employees` cae on cae.`id` = caatm.`commercial_agency_employee_id`
		left join `commercial_agency_carriers` cac on cac.`id` = caq.`commercial_agency_carrier_id`
		left join `commercial_agency_accounts` caa on caa.`uuid` = caq.`commercial_agency_account_uuid`
		where caa.`test_account`=0
		and caatm.`team_role` = "CA Lead"
		) caQuotes
	group by caQuotes.`employee`, caQuotes.`caa_uuid`, caQuotes.`product`
	order by caQuotes.`employee`, caQuotes.`caa_uuid`, caQuotes.`product`
	) quotedCarriersProd
group by quotedCarriersProd.`employee`, quotedCarriersProd.`product`
order by quotedCarriersProd.`employee`, quotedCarriersProd.`product`;

###
#Commercial - Alternate Cross Sale Rates by Agent - For the Current Month
###

###
#Commercial - Alternate Cross Sale Rates for the Current Year by Month (without Endorsements)
###