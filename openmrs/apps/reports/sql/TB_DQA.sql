SELECT distinct patientIdentifier,TB_Number, patientName, Age,age_group, Gender, Linkage, High_Risk_Populations, TB_Start_Date, Site, X_Ray_Results,Diagnostic_Genotypic_Test_Results, Diagnostic_Phenotypic_Test_Results, TB_Treatment_Outcome, Action_Treatment_Failures_or_Drug_Resistant, HIV_Status, Clients_ON_ART, Prevention_of_OIs, HIV
 FROM (
(Select distinct Id, TB_Number, patientIdentifier , patientName, Age, age_group, Gender
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						pi2.identifier AS TB_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('2022-09-30' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					--  TB Clients 
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type in (7)
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('2022-09-30' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id in (4153, 1158)
						AND CAST(o.obs_datetime AS DATE) >= CAST('2022-09-01' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('2022-09-30' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)

)diagnosis_type


Left Outer Join
(
-- TB Treatment Start Date
	select o.person_id, CAST(start_date AS DATE) as TB_Start_Date
	from obs o
    inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as start_date
     from obs oss
     where oss.concept_id = 2237 and oss.voided=0
     and oss.obs_datetime < cast('2022-09-30' as date)
     group by oss.person_id
    )latest
    on latest.person_id = o.person_id 
) as tb_start_date
on diagnosis_type.Id = tb_start_date.person_id

Left Outer Join
(
-- Died before treatment
	select o.person_id, "Died Before Treatment" as "TB_Treatment_Initiation"
	from obs o
	where o.concept_id = 3789 and o.value_coded = 3791
	and o.voided = 0
	and o.obs_datetime >= cast('2022-09-01' as date)
	and o.obs_datetime <= cast('2022-09-30' as date)
	group by o.person_id
) as died
on diagnosis_type.Id = died.person_id

Left Outer Join
(
-- High Risk Population
 select o.person_id,case
 when o.value_coded = 3669 then "Factory worker"
 when o.value_coded = 3667 then "Miner"
 when o.value_coded = 3670 then "Health Worker"
 when o.value_coded = 3777 then "Household member of current miner"
 when o.value_coded = 3778 then "Household member of ex miner"
 when o.value_coded = 3779 then "Prison Staff"
 when o.value_coded = 3671 then "Prisoner"
 when o.value_coded = 3668 then "Ex-miner"
 when o.value_coded = 4654 then "Public Transport"
 when o.value_coded = 4919 then "Contact of DRTB patient"
else "N/A" 
end AS High_Risk_Populations
from obs o
where o.concept_id = 3776 and o.voided = 0
Group by o.person_id
) risk
on diagnosis_type.Id = risk.person_id

Left Outer Join
(
-- Linkage
 select o.person_id,case
 when o.value_coded = 3773 then "Newly registered"
 when o.value_coded = 2095 then "Transfer In"
 when o.value_coded = 3774 then "Moved in"
 when o.value_coded = 3775 then "Transfer in from outside Lesotho"
else "N/A" 
end AS Linkage
from obs o
where o.concept_id = 3772 and o.voided = 0
Group by o.person_id
) link
on diagnosis_type.Id = link.person_id

Left Outer Join
(
-- XRAY Results
 select o.person_id,case
 when o.value_coded = 4171 then "XRay Suggestive of TB"
 when o.value_coded = 4672 then "XRay Not Suggestive of TB"
else "N/A" 
end AS X_Ray_Results
from obs o
where o.concept_id = 4673 and o.voided = 0
Group by o.person_id
) x_ray
on diagnosis_type.Id = x_ray.person_id

Left Outer Join
(
-- XRAY Results
 select o.person_id,case
 when o.value_coded = 3824 then "GeneXpert test type"
 when o.value_coded = 3825 then "Line Probe Assay test type"
else "N/A" 
end AS Diagnostic_Genotypic_Test_Results
from obs o
where o.concept_id = 4673 and o.voided = 0
Group by o.person_id
) Genotypic
on diagnosis_type.Id = Genotypic.person_id

Left Outer Join
(
-- Diagnostic phenotypic test results
 select o.person_id,case
 when o.value_coded = 3819 then "Sputum smear microscopy"
 when o.value_coded = 1045 then "Sputum Culture"
else "N/A" 
end AS Diagnostic_Phenotypic_Test_Results
from obs o
where o.concept_id = 3815 and o.voided = 0
Group by o.person_id
) phenotypic
on diagnosis_type.Id = phenotypic.person_id

Left Outer Join
(
-- TB Treatment Outcome
 select o.person_id,case
 when o.value_coded = 1068 then "Cured"
 when o.value_coded = 2242 then "Completed"
 when o.value_coded = 3650 then "Died"
 when o.value_coded = 2302 then "Lost to Follow-up"
 when o.value_coded = 3793 then "Failed treatment"
 when o.value_coded = 3794 then "Failed treatment and is resistant"
else "N/A" 
end AS TB_Treatment_Outcome
from obs o
where o.concept_id = 3776 and o.voided = 0
Group by o.person_id
) outcome
on diagnosis_type.Id = outcome.person_id

Left Outer Join
(
-- TB Treatment Outcome
 select o.person_id,case
 when o.value_coded = 3707 then "Restarted on First Line Drugs"
 when o.value_coded = 3808 then "Started on Second Line Drugs"
else "N/A" 
end AS Action_Treatment_Failures_or_Drug_Resistant
from obs o
where o.concept_id = 3806 and o.voided = 0
Group by o.person_id
) action_taken
on diagnosis_type.Id = action_taken.person_id

-- HIV STATUS	
left outer join
	(
	select person_id, value_coded as Status_Code
	from obs where concept_id = 4666 and voided = 0
	)Status

	inner join
	(
		select concept_id, name AS HIV_Status
			from concept_name 
				where name in ('Known Positive', 'Known Negative', 'New Positive', 'New Negative') 
	) concept_name
	on concept_name.concept_id = Status.Status_Code 

on Status.person_id = diagnosis_type.Id

-- Active on ART (Initiated, Seen, Missed)
left outer join
(
    Select Clients_ON_ART, Person_id
    FROM
    (
        select active_clients.person_id AS Person_id, "Active" AS "Clients_ON_ART"
    -- , active_clients.latest_follow_up
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('2022-09-30' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id	
								) as active_clients
								-- where active_clients.latest_follow_up >= cast('2022-09-30' as date)
                                where DATEDIFF(CAST('2022-09-30' AS DATE),latest_follow_up) <=28 

    ) As Active

    UNION

    -- Defaulted Clients
    Select Clients_ON_ART, Person_id
    FROM
    (
        select active_clients.person_id AS Person_id, "Defaulted" AS "Clients_ON_ART"
   
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('2022-09-30' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id	
								) as active_clients
                                where DATEDIFF(CAST('2022-09-30' AS DATE),latest_follow_up) > 28


    ) As Missed
) on_art
on on_art.Person_id = diagnosis_type.Id

Left Outer Join
(
-- Prevention of OIs
 select o.person_id,case
 when o.value_coded = 4669 then "TB, New ART"
 when o.value_coded = 4670 then "TB, Already on ART"
 when o.value_coded = 2330 then "OI, Provided CPT"
 when o.value_coded = 4619 then "Dapsone"
else "N/A" 
end AS Prevention_of_OIs
from obs o
where o.concept_id = 4667 and o.voided = 0
Group by o.person_id
) prevention
on diagnosis_type.Id = prevention.person_id

Left Outer Join
(
-- Site
 select o.person_id,case
 when o.value_coded = 3773 then "Extra Pulmonary"
 when o.value_coded = 2095 then "Pulmonary"
else "N/A" 
end AS Site
from obs o
where o.concept_id = 	3788 and o.voided = 0
Group by o.person_id
) P_EP
on diagnosis_type.Id = P_EP.person_id


Left Outer Join
(
-- HIV Status
 select o.person_id,case
 when o.value_coded = 4323 then "Known Positive"
 when o.value_coded = 4664 then "New Positive"
 when o.value_coded = 4324 then "Known Negative"
 when o.value_coded = 4665 then "New Negative"
else "N/A" 
end AS HIV
from obs o
where o.concept_id = 4666 and o.voided = 0
Group by o.person_id
) H
on diagnosis_type.Id = H.person_id