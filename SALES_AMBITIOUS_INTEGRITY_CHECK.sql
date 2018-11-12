## SUPER-AMBITIOUS-INTEGRITY-CHECK-FOR-SALES-CARDS

# Commercial - Total Policies/Endorsements and Total Premium over time

select month(cap.`date_sold`), year(cap.`date_sold`), sum(cap.`final_premium`), count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by month(cap.`date_sold`), year(cap.`date_sold`)
order by cap.`date_sold`;


select month(cap.`date_sold`), year(cap.`date_sold`), count(distinct(cap.`uuid`)), count(distinct(caen.`id`)),
count(distinct(cap.`uuid`))+ count(distinct(caen.`id`))
from  `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_quotes` caq on caq.`uuid` = cap.`commercial_agency_quote_uuid`
left join `commercial_agency_endorsements` caen on caen.`commercial_agency_quote_uuid` = caq.`uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by month(cap.`date_sold`), year(cap.`date_sold`)
order by cap.`date_sold`;


# Commercial - Total Premium by Month

select month(cap.`date_sold`), year(cap.`date_sold`), sum(cap.`final_premium`), count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by month(cap.`date_sold`), year(cap.`date_sold`)
order by cap.`date_sold`;



# Commercial - Total Policies by Month

select month(cap.`date_sold`), year(cap.`date_sold`), count(cap.`uuid`), sum(case when cap.`commercial_agency_product_id` = 7 then 1 else 0 end) as 'cyber_flag', sum(case when cap.`commercial_agency_product_id` != 7 then 1 else 0 end) as 'comm_flag'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by month(cap.`date_sold`), year(cap.`date_sold`)
order by cap.`date_sold`;

# Commercial - Total Policies by Day
# Commercial - Total Policies by Day (Last 90 Days)

select (cap.`date_sold`), year(cap.`date_sold`), count(cap.`uuid`), sum(case when cap.`commercial_agency_product_id` = 7 then 1 else 0 end) as 'cyber_flag', sum(case when cap.`commercial_agency_product_id` != 7 then 1 else 0 end) as 'comm_flag'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cap.`date_sold`
order by cap.`date_sold` desc;


# Commercial - Total Policies by Carrier

select (cap.`date_sold`), year(cap.`date_sold`), count(cap.`uuid`), cac.`name` as 'carrier'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_carriers` cac on cac.`id` = cap.`commercial_agency_carrier_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by cap.`date_sold`, cac.`name`
order by cap.`date_sold` desc;

select (cap.`date_sold`), year(cap.`date_sold`), count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_carriers` cac on cac.`id` = cap.`commercial_agency_carrier_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by cap.`date_sold`
order by cap.`date_sold` desc;


# Commercial - Online Quotes by Day - T90 [X NOT VERIFIED]

select caq.`uuid`, convert_tz(caq.`created_at`,'utc','us/pacific')
from `commercial_agency_quotes` caq
left join `commercial_agency_accounts` caa on caa.`uuid` = caq.`commercial_agency_account_uuid`
where caa.`test_account`=0 and caq.`commercial_quote_id` is not null and datediff(now(),convert_tz(caq.`created_at`,'utc','us/pacific')) <= 90
order by caq.`created_at` asc;

select caq.`uuid`, convert_tz(caa.`created_at`,'utc','us/pacific')
from `commercial_agency_quotes` caq
left join `commercial_agency_accounts` caa on caa.`uuid` = caq.`commercial_agency_account_uuid`
where caa.`test_account`=0 and caq.`commercial_quote_id` is not null and datediff(now(),convert_tz(caa.`created_at`,'utc','us/pacific')) <= 90
order by caa.`created_at` asc;

# Commercial - Total Policies by Month and Industry

select month(cap.`date_sold`), year(cap.`date_sold`), count(cap.`uuid`), cbs.`name` as 'business_seg'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
left join `commercial_business_segments` cbs on cbs.`id` = cbt.`commercial_business_segment_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by date_format(cap.`date_sold`,"%Y-%m"), cbs.`name`
order by date_format(cap.`date_sold`,"%Y-%m") desc, count(cap.`uuid`) desc;


# Commercial - Average Premium per Policy by Month

select month(cap.`date_sold`), year(cap.`date_sold`), avg(cap.`final_premium`), count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and year(cap.`date_sold`) = year(now())
group by date_format(cap.`date_sold`,"%Y-%m")
order by cap.`date_sold`;


# Commercial - Average Premium per Policy by Month (excluding CommAuto)

select month(cap.`date_sold`), year(cap.`date_sold`), avg(cap.`final_premium`), count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and year(cap.`date_sold`) = year(now()) and cap.`commercial_agency_product_id` != 5
group by date_format(cap.`date_sold`,"%Y-%m")
order by cap.`date_sold`;

# Commercial - Total Policies by Month and Product
# Commercial - Total Policies by Product

select month(cap.`date_sold`), year(cap.`date_sold`), count(cap.`uuid`), caprod.`name` as 'product'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by date_format(cap.`date_sold`,"%Y-%m"), caprod.`name`
order by date_format(cap.`date_sold`,"%Y-%m") desc, count(cap.`uuid`) desc;

# Commercial - Total Premium by Month and Product

select cap.`date_sold`, year(cap.`date_sold`), sum(cap.`final_premium`), count(cap.`uuid`), caprod.`name` as 'product'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cap.`date_sold`, caprod.`name`
order by cap.`date_sold` desc, count(cap.`uuid`) desc;


# Commercial - Quote Rate, Close Rate and Cross-Sale Rates by Day Type [ X NOT COMPLETE ]
	-- Cross sale rate does not make sense here in this card.
select
	quotesPolicies.`day_of_week` as 'day_type', 
	(quotesPolicies.`numQuotes_day`) as 'num_Quotes', 
	quotesPolicies.`numPolicies_day` as 'num_Policies',
	quotesPolicies.`numAccounts_day` as 'num_Accounts',
	quotesPolicies.`numQuotedAccounts_day` as 'num_QuotedAccounts', 
	quotesPolicies.`numSoldAccounts_day` as 'num_SoldAccounts',
	(quotesPolicies.`numQuotedAccounts_day` / quotesPolicies.`numAccounts_day`) as 'quote_rate',
	(quotesPolicies.`numSoldAccounts_day` / quotesPolicies.`numAccounts_day`) as 'close_rate',
	(crossSold.`numCrossSold_day` / quotesPolicies.`numSoldAccounts_day`) as 'cross_sale_rate'

from
	(select 
		DAYNAME(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) as 'day_of_week',
		/* case when WEEKDAY(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) in (0,1,2,3,4) then 'Work Days'
						when WEEKDAY(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) = 5 then 'Saturday'
						when WEEKDAY(convert_tz(caa.`created_at`, 'utc', 'us/pacific')) = 6 then 'Sunday'
						end as 'day_type', */
		count(distinct(case when caq.`outcome` = "quote" then caq.`uuid` end)) as 'numQuotes_day',
		count(cap.`uuid`) as 'numPolicies_day',
		count(distinct(caa.`uuid`)) as 'numAccounts_day',
		count(distinct(case when caq.`uuid` is not null then caa.`uuid` end)) as 'numQuotedAccounts_day',
		count(distinct(case when cap.`uuid` is not null then caa.`uuid` end)) as 'numSoldAccounts_day'
	
	from `commercial_agency_accounts` caa
	left join `commercial_agency_quotes` caq on caa.`uuid` = caq.`commercial_agency_account_uuid`
	left join `commercial_agency_policies` cap on cap.`commercial_agency_quote_uuid` = caq.`uuid`
		
	where caa.`test_account`=0
	group by DAYNAME(convert_tz(caa.`created_at`, 'utc', 'us/pacific'))
	order by WEEKDAY(convert_tz(caa.`created_at`, 'utc', 'us/pacific'))
	) quotesPolicies
	
left join
	(select
	 	DAYNAME(accountsPol.`created_at`) as 'day_of_week', count(distinct(accountsPol.`uuid`)) as 'numCrossSold_day'
	from
	 	(select 
	 		convert_tz(caa.`created_at`, 'utc', 'us/pacific') as 'created_at', caa.`uuid`, count(cap.`uuid`) as 'numPolicies'
	 		-- group_concat(DAYNAME(convert_tz(caa.`created_at`, 'utc', 'us/pacific')))
		from `commercial_agency_policies` cap
		left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
		left join `commercial_agency_quotes` caq on caq.`commercial_agency_account_uuid` = cap.`commercial_agency_account_uuid`
		where caa.`test_account`=0 and caq.`outcome` = "quote"
		group by caa.`uuid`			
		) accountsPol
		where accountsPol.`numPolicies` > 1
		group by DAYNAME(convert_tz(accountsPol.`created_at`, 'utc', 'us/pacific'))
		order by WEEKDAY(convert_tz(accountsPol.`created_at`, 'utc', 'us/pacific'))
	)crossSold on crossSold.`day_of_week` = quotesPolicies.`day_of_week`


group by quotesPolicies.`day_of_week`
order by (case when quotesPolicies.`day_of_week` = "Monday" then 0
			when quotesPolicies.`day_of_week` = "Tuesday" then 1
			when quotesPolicies.`day_of_week` = "Wednesday" then 2
			when quotesPolicies.`day_of_week` = "Thursday" then 3
			when quotesPolicies.`day_of_week` = "Friday" then 4
			when quotesPolicies.`day_of_week` = "Saturday" then 5
			when quotesPolicies.`day_of_week` = "Sunday" then 6 end);


# Commercial - Total Premium (inc Endorsement) by Business Type and Product [ X VERIFIED ]

select sum(cap.`final_premium`) as 'final_premium', ifnull(cbt.`name`, 'Not Specified') as 'business'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
/* left join `commercial_agency_endorsements` caen on caen.`commercial_agency_quote_uuid` = cap.`commercial_agency_quote_uuid` */
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cbt.`name`
order by cbt.`name`;			

# Commercial - Average Premium by Business Type and Product

select avg(cap.`final_premium`) as 'avg_premium', ifnull(cbt.`name`, 'Not Specified') as 'business'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
/* left join `commercial_agency_endorsements` caen on caen.`commercial_agency_quote_uuid` = cap.`commercial_agency_quote_uuid` */
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by cbt.`name`
order by cbt.`name`;

# Commercial - Total Premium by Month and Carrier
# Commercial - Total Premium by Carrier by Month
# Commercial - Total Policies by Carriers

select month(cap.`date_sold`), year(cap.`date_sold`), cac.`name` as 'carrier', sum(cap.`final_premium`), avg(cap.`final_premium`), count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_carriers` cac on cac.`id` = cap.`commercial_agency_carrier_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by month(cap.`date_sold`), year(cap.`date_sold`), cac.`name`
order by cap.`date_sold`;


# Commercial - Average Premium Per Account

select month(cap.`date_sold`), year(cap.`date_sold`), sum(cap.`final_premium`)/(count(distinct(cap.`commercial_agency_account_uuid`))) as 'avg_prem_sold' ,count(distinct(cap.`commercial_agency_account_uuid`)) as 'sold accounts'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by month(cap.`date_sold`), year(cap.`date_sold`)
order by cap.`date_sold`;

#Commercial - Average Premium by Product by Month

select month(cap.`date_sold`), year(cap.`date_sold`), count(cap.`uuid`), avg(cap.`final_premium`) as 'product_premium', caprod.`name` as 'product'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by date_format(cap.`date_sold`,"%Y-%m"), caprod.`name`
order by date_format(cap.`date_sold`,"%Y-%m") desc, count(cap.`uuid`) desc;

#Commercial - Total Premium by State

select sum(cap.`final_premium`), states.`name`
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `states` states on states.`id` = caa.`state_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by states.`name`
order by states.`name`;


#Commercial - Total Number of Policies Sold by State

select count(cap.`final_premium`), states.`name`
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `states` states on states.`id` = caa.`state_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by states.`name`
order by states.`name`;


# Commercial - Total Policies by Month (Including Endorsements)

select month(cap.`date_sold`), year(cap.`date_sold`), sum(cap.`final_premium`), count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and cap.`commercial_agency_product_id` != 5
group by month(cap.`date_sold`), year(cap.`date_sold`)
order by cap.`date_sold`;

# Commercial - Cross Sales and Endorsements by Month (Excluding Commercial Auto)

select month(cap.`date_sold`), year(cap.`date_sold`), sum(cap.`final_premium`), count(cap.`uuid`)
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and cap.`commercial_agency_product_id` != 5
group by month(cap.`date_sold`), year(cap.`date_sold`)
order by cap.`date_sold`;
--

select month(cap.`date_sold`), year(cap.`date_sold`), count(distinct(cap.`uuid`)), count(distinct(caen.`id`)),
count(distinct(cap.`uuid`))+ count(distinct(caen.`id`))
from  `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_quotes` caq on caq.`uuid` = cap.`commercial_agency_quote_uuid`
left join `commercial_agency_endorsements` caen on caen.`commercial_agency_quote_uuid` = caq.`uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
and cap.`commercial_agency_product_id` != 5
group by month(cap.`date_sold`), year(cap.`date_sold`)
order by cap.`date_sold`;

# Commercial - Sold accounts split by combination of products purchased
### TBD

# Commercial - Cross Sale Rate by Lead Product for Online Accounts
### 

# Commercial - Total Policies/Endorsements by Business Type

select month(cap.`date_sold`), year(cap.`date_sold`), count(distinct(cap.`uuid`)), count(distinct(caen.`id`)),
count(distinct(cap.`uuid`))+ count(distinct(caen.`id`)), cbt.`name`
from  `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_quotes` caq on caq.`uuid` = cap.`commercial_agency_quote_uuid`
left join `commercial_agency_endorsements` caen on caen.`commercial_agency_quote_uuid` = caq.`uuid`
left join `commercial_business_types` cbt on cbt.`id` = caa.`business_type_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by month(cap.`date_sold`), year(cap.`date_sold`), cbt.`name`
order by cap.`date_sold`;

# Commercial - Total Premium by Month and Shopper Priority
select
	year(cap.`date_sold`),
	month(cap.`date_sold`),
	case when caa.`priority_score` > 500 then 'high' else 'low' end as 'shopper priority',
	sum(cap.`final_premium`)
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by date_format(cap.`date_sold`,"%Y-%m"), case when caa.`priority_score` > 500 then 'high' else 'low' end;


# Commercial - Total Policies by Month and Shopper Priority
select
	year(cap.`date_sold`),
	month(cap.`date_sold`),
	case when caa.`priority_score` > 500 then 'high' else 'low' end as 'shopper priority',
	count(cap.`final_premium`)
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by date_format(cap.`date_sold`,"%Y-%m"), case when caa.`priority_score` > 500 then 'high' else 'low' end;

# Commercial - Average Premium by Month and Shopper Priority
select
	year(cap.`date_sold`),
	month(cap.`date_sold`),
	case when caa.`priority_score` > 500 then 'high' else 'low' end as 'shopper priority',
	sum(cap.`final_premium`) / count(distinct(caa.`uuid`)) as 'avg_prem'
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by date_format(cap.`date_sold`,"%Y-%m"), case when caa.`priority_score` > 500 then 'high' else 'low' end;

# Commercial - Total Premium By Product and Shoppers Priority

select
	case when caa.`priority_score` > 500 then 'high' else 'low' end as 'shopper priority',
	caprod.`name`,
	sum(cap.`final_premium`)
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by case when caa.`priority_score` > 500 then 'high' else 'low' end, caprod.`name`;

# Commercial - Total Premium By Source and Shoppers Priority

select
	case when caa.`priority_score` > 500 then 'high' else 'low' end as 'shopper priority',
	sources.`name`,
	count(distinct(caa.`uuid`))
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
left join `sources` sources on sources.`id` = caa.`source_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")
group by case when caa.`priority_score` > 500 then 'high' else 'low' end, sources.`name`;


# Commercial - Total Policies by Shopper Revenue Buckets [ X VERIFIED ]

select
	case when caa.`priority_score` > 500 then 'high' else 'low' end as 'shopper priority',
	case when `annual_projected_gross_sales`=0 then '0'
		when  `annual_projected_gross_sales` is NULL then 'Unknown'
		when `annual_projected_gross_sales`>0 and `annual_projected_gross_sales`<=100000 then '0K-100K'
		when `annual_projected_gross_sales`>100000 and `annual_projected_gross_sales`<=250000 then '100K-250K'
		when `annual_projected_gross_sales`>250000 and `annual_projected_gross_sales`<=500000 then '250K-500K'
		when `annual_projected_gross_sales`>500000 and `annual_projected_gross_sales`<=750000 then '500K-750K'
		when `annual_projected_gross_sales`>750000 and `annual_projected_gross_sales`<=1000000 then '750K-1M'
		when `annual_projected_gross_sales`>1000000 and `annual_projected_gross_sales`<=5000000 then '1M-5M'
		when `annual_projected_gross_sales`>5000000 then '5M+'
		end as 'bucket',


	count(distinct(cap.`uuid`))
from `commercial_agency_accounts` caa
left join `commercial_agency_policies` cap on cap.`commercial_agency_account_uuid` = caa.`uuid`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite") and cap.`uuid` is not null
group by case when caa.`priority_score` > 500 then 'high' else 'low' end, case when `annual_projected_gross_sales`=0 then '0'
				when  `annual_projected_gross_sales` is NULL then 'Unknown'
				when `annual_projected_gross_sales`>0 and `annual_projected_gross_sales`<=100000 then '0K-100K'
				when `annual_projected_gross_sales`>100000 and `annual_projected_gross_sales`<=250000 then '100K-250K'
				when `annual_projected_gross_sales`>250000 and `annual_projected_gross_sales`<=500000 then '250K-500K'
				when `annual_projected_gross_sales`>500000 and `annual_projected_gross_sales`<=750000 then '500K-750K'
				when `annual_projected_gross_sales`>750000 and `annual_projected_gross_sales`<=1000000 then '750K-1M'
				when `annual_projected_gross_sales`>1000000 and `annual_projected_gross_sales`<=5000000 then '1M-5M'
				when `annual_projected_gross_sales`>5000000 then '5M+' end
order by caa.`annual_projected_gross_sales`;


# Commercial - Total Accounts by No. of Products Sold and Shopper Priority
###
# Commercial - Average Time to Claim an Account by Agent and Shopper Priority
###
# Commercial - Average Follow Ups by Month and Shopper Priority
###

# Commercial - Total Policies by Product

select month(cap.`date_sold`), year(cap.`date_sold`), count(cap.`uuid`), caprod.`name` as 'product'
from `commercial_agency_policies` cap
left join `commercial_agency_accounts` caa on caa.`uuid` = cap.`commercial_agency_account_uuid`
left join `commercial_agency_products` caprod on caprod.`id` = cap.`commercial_agency_product_id`
where caa.`test_account`=0 and ifnull(cap.`sale_type`,'n') not in ("Renewal" , "Rewrite")	
group by date_format(cap.`date_sold`,"%Y-%m"), caprod.`name`
order by date_format(cap.`date_sold`,"%Y-%m") desc, count(cap.`uuid`) desc;

