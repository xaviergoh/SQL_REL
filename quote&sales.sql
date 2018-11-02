select 
caa.uuid,
cae.`Agent status` as 'status',
date_claimed.created_at as 'Date acc claimed',
date_closed.created_at as 'Date acc closed/sold',
caa.state_id,
caa.created_at,
caa.updated_at,
caa.commercial_shopper_id,
caa.website_outcome,
caa.source_id,
caa.`origin`,
caa.brand_id,
brands.name as 'Brand',
caa.annual_projected_gross_sales,
caa.number_of_employees,
caa.priority_score,
caa.business_type_id,
st.name as State,
pol.SellingAgent,
case when pol.SellingAgent ='Online Sale' then 'Online Sale' else 'Offline Sale' end as 'Online Sale Flag',
case when cae.`Agent status` is NULL then "No Status" else cae.`Agent status`  end as STATUS1,
convert_tz(caa.created_at,'UTC','US/Pacific') as CreatedAtPacific, 
cae.`Agent` as agent,
cae.`Agent Role` as 'Agent Role',
caacr.reason as closure_reason,
sources.name as Source, 
ch.campaign as 'Marketing Campaign',
pol.numPolicy, 
pol.totalPremium, 
case when pol1.RenewedRewrittenPolicies is null then 0 else pol1.RenewedRewrittenPolicies end as RenewedRewrittenPolicies,
case when pol1.RNRWEndorsements is null then 0 else pol1.RNRWEndorsements end as RNRWEndorsements ,
case when pol1.RenewedRewrittenPremium is null then 0 else pol1.RenewedRewrittenPremium end as RenewedRewrittenPremium,
pol.cyber,  #42819, 42,815
pol.`Comm Auto`, 
qut.numQuote,
(case when pol.numPolicy is not null then 1 else 0 end) as Sold_Policy, 
pol.date_sold,
pol.`Cyber Endorsement`,
table1.num_endorsements,
(case when qut.numQuote is not null then 1 else 0 end ) as Quoted,
case when cqc.quote is not null then 1 else 0 end as Quoted_online,

-- ADD CrossSaleFlag = # of Policies + # of Endorsements  - RNRWPolicies - RNRWEndorsements
case when (pol.numPolicy - ifnull(pol1.RenewedRewrittenPolicies,0)) > 1 then 1 else 0 end as CrossSaleFlag,
-- ADD CrossSaleInclEndFlag = # of Policies + # of Endorsements  - RNRWPolicies - RNRWEndorsements
case when (pol.numPolicy + ifnull(table1.num_endorsements,0) - ifnull(pol1.RenewedRewrittenPolicies,0)-ifnull(pol1.RNRWEndorsements,0)) > 1 then 1 else 0 end as CrossSaleInclEndFlag,
tab2.AgentAssignedDate,
tab2.AssignedAgentSuperV,
cbt.name as 'Business Type',
case when caa.uuid in (select cap.`commercial_agency_account_uuid` from commercial_agency_policies cap where cap.final_premium<1000) then 1 else 0 end as 'MicroPolicy Flag',
case when caa.uuid in (select caq.`commercial_agency_account_uuid` from commercial_agency_quotes caq where caq.`annual_premium`<1000) then 1 else 0 end as 'MicroPolicy Quote Flag',
t2.nps_rating,
t2.nps_comment


from commercial_agency_accounts caa

left join states st on st.id=caa.`state_id`
left join (

-- start of pol: Number of policies sold at Account Level
select distinct cap.`commercial_agency_account_uuid` as ID, cae.name as SellingAgent, COUNT(*) as numPolicy, SUM(cap.`final_premium`) as totalPremium, cap.`date_sold`,
MAX(cap.Cyber) as cyber, MAX(cap.`Comm Auto`) as 'Comm Auto',
case when cap.commercial_agency_quote_uuid in 
(select cape.commercial_agency_quote_uuid from commercial_agency_endorsements cape where cape.`commercial_agency_product_id` = 7)
then 1 else 0 end as 'Cyber Endorsement'
from (select *, case when cap.`commercial_agency_product_id` =7 then 1 else 0 end as Cyber,
case when cap.`commercial_agency_product_id` = 5 then 1 else 0 end as 'Comm Auto'
from commercial_agency_policies cap) cap
left join commercial_agency_employees cae on cae.id=cap.commercial_agency_employee_id
group by cap.`commercial_agency_account_uuid`
) pol on pol.ID=caa.uuid
-- end of pol

left join (select cap1.`commercial_agency_account_uuid`,count(cap1.uuid) as RenewedRewrittenPolicies,count(caen.`id`) as RNRWEndorsements,sum(cap1.final_premium) as RenewedRewrittenPremium from commercial_agency_policies cap1
left join commercial_agency_endorsements caen on caen.`commercial_agency_quote_uuid`=cap1.`commercial_agency_quote_uuid`
 where cap1.sale_type in ('Renewal','Rewrite') group by cap1.`commercial_agency_account_uuid` )pol1 on pol1.`commercial_agency_account_uuid`=pol.ID
 
 left join (#Adds agents and commercial associates
select 
caatm.commercial_agency_account_uuid,
MAX(case when caatm.team_role = "Owner" then cae.name end) as 'Agent',
MAX(case when caatm.team_role = "Owner" then caatm.status end) as 'Agent status',
MAX(case when caatm.team_role = "Owner" then cae.role end) as 'Agent Role',
MAX(case when caatm.team_role = "CA Lead" then cae.name end) as 'CA Lead',
MAX(case when caatm.team_role = "CA Lead" then caatm.status end) as 'CA Lead status',
MAX(case when caatm.team_role = "CA Lead" then cae.role end) as 'CA Lead Role'
from commercial_agency_account_team_memberships caatm
left join commercial_agency_employees cae on cae.id = caatm.commercial_agency_employee_id
group by caatm.commercial_agency_account_uuid
) cae on cae.commercial_agency_account_uuid = caa.uuid
left join sources on sources.id=caa.`source_id`
left join (
select distinct caq.`commercial_agency_account_uuid`, count(*) as numQuote
from commercial_agency_quotes caq
where caq.`outcome` = 'quote'
group by caq.`commercial_agency_account_uuid`
) qut on qut.`commercial_agency_account_uuid` = caa.uuid
left join (
select tab1.`commercial_agency_account_uuid`,convert_tz(min(tab1.`created_at`),'UTC','US/Pacific') as AgentAssignedDate,tab1.`commercial_agency_employee_id`,tab1.name as AssignedAgentSuperV,tab1.role 
from 
(select cact.`commercial_agency_account_uuid`,cact.`commercial_agency_employee_id`,cact.created_at,cae.name,cae.role from commercial_agency_activities cact 
left join commercial_agency_employees cae on cae.id=cact.`commercial_agency_employee_id`
left join commercial_agency_accounts caa on caa.uuid=cact.`commercial_agency_account_uuid`
where caa.test_account=0
)tab1
where (tab1.role='Agent' or tab1.role='Supervisor')
group by tab1.`commercial_agency_account_uuid`
)tab2 on tab2.`commercial_agency_account_uuid`=caa.uuid
left join (
select distinct cqc.`commercial_shopper_id`, MAX(cq.`annual_amount`) as quote
from commercial_quotes cq
right join commercial_quote_collections cqc on cqc.`id` = cq.`commercial_quote_collection_id`
group by cqc.`commercial_shopper_id`#10379
) cqc on cqc.`commercial_shopper_id` = caa.`commercial_shopper_id`
left join (
select cap.`commercial_agency_account_uuid` , COUNT(*) as num_endorsements
from commercial_agency_endorsements cape
join commercial_agency_policies cap on cap.`commercial_agency_quote_uuid` = cape.`commercial_agency_quote_uuid`
group by cap.`commercial_agency_account_uuid`
) table1 on table1.commercial_agency_account_uuid = caa.`uuid`
left join commercial_business_types cbt on cbt.id = caa.`business_type_id`
left join (
        select caact.message, caact.created_at, caact.`commercial_agency_account_uuid`
        from commercial_agency_activities caact
        join(
        select caact.`commercial_agency_account_uuid` , min(caact.id) as id
        from commercial_agency_activities caact
        where (caact.message like '%Updated Owner from%' or caact.message like '%Updated Owner to%' or caact.message like '%Assigned%')
        group by caact.`commercial_agency_account_uuid`) t1 on t1.id = caact.id and t1.`commercial_agency_account_uuid` = caact.`commercial_agency_account_uuid`
) date_claimed on date_claimed.`commercial_agency_account_uuid` = caa.`uuid`
left join (
        select caact.created_at, caact.`commercial_agency_account_uuid`
        from commercial_agency_activities caact
        join(
        select  caact.`commercial_agency_account_uuid` , MAX(caact.id) as id
        from commercial_agency_activities caact
        where (caact.message like '%Updated%Status%Closed%'  or caact.message like '%Updated%Status%Sold%')
        group by caact.`commercial_agency_account_uuid`) t1 on t1.id = caact.id and t1.`commercial_agency_account_uuid` = caact.`commercial_agency_account_uuid`
) date_closed on date_closed.`commercial_agency_account_uuid` = caa.`uuid`
left join 
(select caacri.*
from commercial_agency_account_closure_reason_instances caacri
join (
select caacri.`commercial_agency_account_uuid`,MAX(id) as id
from commercial_agency_account_closure_reason_instances caacri
group by caacri.`commercial_agency_account_uuid`) t1 on t1.id = caacri.id) caacri on caacri.commercial_agency_account_uuid = caa.uuid
left join commercial_agency_account_closure_reasons caacr on caacr.id = caacri.`closure_reason_id`
left join commercial_shopper_hit_joins cshj on cshj.commercial_shopper_id = caa.`commercial_shopper_id`
left join commercial_hits ch on ch.id = cshj.commercial_hit_id
left join brands on brands.id = caa.`brand_id`
left join (
        select cns.`commercial_agency_account_uuid`, cns.`nps_rating`,cns.`nps_comment`
        from commercial_nps_surveys cns
        join(
        select commercial_agency_account_uuid, MAX(id) as id
        from commercial_nps_surveys
        where commercial_agency_account_uuid is not null and `nps_rating` is not null
        group by commercial_agency_account_uuid
        ) t1 on t1.commercial_agency_account_uuid = cns.`commercial_agency_account_uuid` and t1.id = cns.id
) t2 on t2.commercial_agency_account_uuid = caa.`uuid`
where caa.`test_account` = 0;