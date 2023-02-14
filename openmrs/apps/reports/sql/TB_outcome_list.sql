SELECT distinct patientIdentifier, patientName, Age, age_group, Gender,TB_Treatment_Outcome,HIV_Status, Clients_ON_ART
 FROM (
(Select distinct Id, TB_Number, patientIdentifier , patientName, Age, age_group, Gender
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						pi2.identifier AS TB_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
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
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id in (4153, 1158)
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)

)diagnosis_type
Left Outer Join
(
-- Died before treatment
	select o.person_id, "Died Before Treatment" as "TB_Treatment_Initiation"
	from obs o
	where o.concept_id = 3789 and o.value_coded = 3791
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id
) as died
on diagnosis_type.Id = died.person_id

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
-- TB Treatment Outcome
 select o.person_id,o.value_coded, case
 when o.value_coded = 1068 then "Cured"
 when o.value_coded = 2242 then "Completed"
 when o.value_coded = 3650 then "Died"
 when o.value_coded = 2302 then "Lost to Follow-up"
 when o.value_coded = 3793 then "Failed treatment"
 when o.value_coded = 3794 then "Failed treatment and is resistant"
else "N/A" 
end AS TB_Treatment_Outcome
from obs o
where o.concept_id = 3792 and o.voided = 0
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
				where name in ("Known Positive", "Known Negative", "New Positive", "New Negative") 
	) concept_name
	on concept_name.concept_id = Status.Status_Code 

on Status.person_id = diagnosis_type.Id

-- Active on ART (Initiated, Seen, Defaulted)
left outer join
(
    Select Clients_ON_ART, Person_id
    FROM
    (
        select active_clients.person_id AS Person_id, "Already on ART" AS "Clients_ON_ART"
    -- , active_clients.latest_follow_up
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id	
								) as active_clients
								-- where active_clients.latest_follow_up >= cast('#endDate#' as date)
                                where DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) <=28 

								-- Initiated
								and active_clients.person_id not in (
								select distinct os.person_id
								from obs os
								where concept_id = 2249
								AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
								AND os.voided = 0
								)

    ) As Active

	UNION

	Select Clients_ON_ART, Person_id
    FROM
    (
        select o.person_id AS Person_id, "New_ART" AS "Clients_ON_ART"
    -- , active_clients.latest_follow_up
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 

						AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							and os.voided = 0
							AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )

    ) As Initiated

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
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id	
								) as active_clients
                                where DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 28


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
-- TB_Treatment_History
 select o.person_id,case
 when o.value_coded = 1034 then "New Patient"
 when o.value_coded = 1084 then "Relapse"
 when o.value_coded = 3786 then "Treatment after loss to follow up"
 when o.value_coded = 1037 then "Treatment after failure"
else "N/A" 
end AS TB_Treatment_History
from obs o
where o.concept_id = 3785 and o.voided = 0
Group by o.person_id
) History_TB_Treatment
on diagnosis_type.Id = History_TB_Treatment.person_id