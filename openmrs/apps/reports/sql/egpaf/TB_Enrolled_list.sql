SELECT distinct Patient_Identifier, Patient_Name, Age , Gender, age_group, TB_Treatment_History, Key_Populations, HIV_Status, Clients_ON_ART, TB_Diagnosis
FROM
(
    (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age , Gender, age_group, 'New Patient' AS 'TB_Treatment_History'
        FROM
                        
            (select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                observed_age_group.name AS age_group,
                observed_age_group.sort_order AS sort_order

            from obs o
            -- New TB Patient
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Start Date
                            where ob.concept_id = 2237
                            and ob.value_datetime >= CAST('#startDate#'AS DATE)
                            and ob.value_datetime <= CAST('#endDate#'AS DATE)
                            and ob.voided = 0
                        )
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            where ob.person_id in (
                                        -- New Clients
                                            select distinct person_id
                                                from obs
                                                where concept_id = 3785 and value_coded = 1034
                                                and obs_datetime >= CAST('#startDate#'AS DATE)
                                                and obs_datetime <= CAST('#endDate#'AS DATE)
                                            )
                        )

                    
                    AND o.person_id not in (
                        select distinct os.person_id 
                            from obs os
                                -- Patient must not be a tranfer in	
                            where os.concept_id = 	3772 and os.value_coded =2095
                        AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                        AND patient.voided = 0 AND os.voided = 0
                        )
                    
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS NEW_TB_CLIENTS
        ORDER BY NEW_TB_CLIENTS.Age)


    UNION

        (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age , Gender, age_group, 'Relapsed Patient' AS 'TB_Treatment_History'
            FROM
                (select distinct patient.patient_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group,
                    observed_age_group.sort_order AS sort_order

                from obs o
            -- Relapsed TB Client
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Start Date
                            where ob.concept_id = 2237
                            and ob.value_datetime >= CAST('#startDate#'AS DATE)
                            and ob.value_datetime <= CAST('#endDate#'AS DATE) 
                        )
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            where ob.person_id in (
                                        -- Relapsed Clients
                                            select distinct person_id
                                                from obs
                                                where concept_id = 3785 and value_coded = 1084
                                                and ob.value_datetime >= CAST('#startDate#'AS DATE)
                                                and ob.value_datetime <= CAST('#endDate#'AS DATE)
                                            )
                        )



                    AND o.person_id not in (
                        select distinct os.person_id 
                        from obs os
                            -- Client must not be a transfer in
                        where os.concept_id = 3772 and os.value_coded =2095
                        AND os.obs_datetime >= CAST('#startDate#' AS DATE)
                        and os.obs_datetime <= CAST('#endDate#'AS DATE)
                        AND patient.voided = 0 AND os.voided = 0
                        )
                    
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS RELAPSE_TB_CLIENTS
    ORDER BY RELAPSE_TB_CLIENTS.Age)

    UNION


    (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age , Gender, age_group, 'Treatment after loss to follow up' AS 'TB_Treatment_History'
            FROM
                (select distinct patient.patient_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group,
                    observed_age_group.sort_order AS sort_order

                from obs o
            -- Relapsed TB Client
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Start Date
                            where ob.concept_id = 2237
                            and ob.value_datetime >= CAST('#startDate#'AS DATE)
                            and ob.value_datetime <= CAST('#endDate#'AS DATE) 
                        )
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            where ob.person_id in (
                                        -- Treatment after loss to follow up
                                            select distinct person_id
                                                from obs
                                                where concept_id = 3785 and value_coded = 3786
                                                and ob.value_datetime >= CAST('#startDate#'AS DATE)
                                                and ob.value_datetime <= CAST('#endDate#'AS DATE)
                                            )
                        )



                    AND o.person_id not in (
                        select distinct os.person_id 
                        from obs os
                            -- Client must not be a transfer in
                        where os.concept_id = 3772 and os.value_coded = 3786
                        AND os.obs_datetime >= CAST('#startDate#' AS DATE)
                        and os.obs_datetime <= CAST('#endDate#'AS DATE)
                        AND patient.voided = 0 AND os.voided = 0
                        )
                    
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TREATMENT_AFTER_LTFU
    ORDER BY TREATMENT_AFTER_LTFU.Age)

    UNION


    (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age , Gender, age_group, 'Treatment after failure' AS 'TB_Treatment_History'
            FROM
                (select distinct patient.patient_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group,
                    observed_age_group.sort_order AS sort_order

                from obs o
                    -- TB Treatment start date
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Start Date
                            where ob.concept_id = 2237
                            and ob.value_datetime >= CAST('#startDate#'AS DATE)
                            and ob.value_datetime <= CAST('#endDate#'AS DATE) 
                        )
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            where ob.person_id in (
                                        -- Treatment after failure 
                                            select distinct person_id
                                                from obs
                                                where concept_id = 3785 and value_coded = 1037
                                                and ob.value_datetime >= CAST('#startDate#'AS DATE)
                                                and ob.value_datetime <= CAST('#endDate#'AS DATE)
                                            )
                        )



                    AND o.person_id not in (
                        select distinct os.person_id 
                        from obs os
                            -- Client must not be a transfer in
                        where os.concept_id = 3772 and os.value_coded = 1037
                        AND os.obs_datetime >= CAST('#startDate#' AS DATE)
                        and os.obs_datetime <= CAST('#endDate#'AS DATE)
                        -- AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                        AND patient.voided = 0 AND os.voided = 0
                        )
                    
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TREATMENT_AFTER_FAILURE
    ORDER BY TREATMENT_AFTER_FAILURE.Age)

) AS TB_HISTORY

-- Key Population groups
left outer join
	(
        select distinct a.person_id, a.value_coded as population_code,
            case 
            when a.value_coded = 3669 then 'Factory worker'
            when a.value_coded = 3667 then 'Miner'
            when a.value_coded = 3670 then 'Health worker'
            when a.value_coded = 3777 then 'Household member of current miner(HMCM)'
            when a.value_coded = 3778 then 'Household member of ex miner (HMXM)'
            when a.value_coded = 3779 then 'Correctional Staff'
            when a.value_coded = 3671 then 'Inmates'
            when a.value_coded = 3668 then 'Ex-miner'
            when a.value_coded = 4664 then 'Public Transport Operator'
            when a.value_coded = 4919 then 'Contact of DRTB patient'
            else 'Other' end as key_pop
    from obs a
        WHERE concept_id = 3776
         and voided = 0

        
)AS key_pop

inner join
	(
		select concept_id, name AS Key_Populations
			from concept_name 
				where name in ('Factory worker', 'Miner', 'Health worker', 'Household member of current miner', 'Household member of ex miner'
                                    'Prison Staff', 'Prisoner', 'Ex-miner', 'Public Transport', 'Contact of DRTB patient' ) 
	) concept_name
	on concept_name.concept_id = key_pop.population_code

on key_pop.person_id = TB_HISTORY.Id

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
	) hiv_concept_name
	on hiv_concept_name.concept_id = Status.Status_Code 

on Status.person_id = TB_HISTORY.Id 

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
on on_art.Person_id = TB_HISTORY.Id 

left outer JOIN

(
    Select person_id, TB_Diagnosis
    FROM(
    (select distinct o.person_id, "Pulmonary Bacteriologic" as "TB_Diagnosis" 
    FROM obs o
    -- Bacteriologically confirmed Genotypic test results and Phenotypic test results
    where o.concept_id in (3814, 3815) 
    and o.obs_datetime >= CAST('#startDate#' AS DATE)
    and o.obs_datetime <= CAST('#endDate#' AS DATE)
    and o.voided = 0
    and o.person_id in (
        select ob.person_id 
        FROM obs ob
        -- Pulmonary TB
        where ob.concept_id = 3788 and ob.value_coded = 1018
        and ob.obs_datetime >= CAST('#startDate#' AS DATE)
        and ob.obs_datetime <= CAST('#endDate#' AS DATE)
        and ob.voided = 0
        )
    or o.person_id in (
        select ob.person_id
        FROM obs ob
        -- Pulmonary TB, Bacteriologically Confirmed
        where ob.concept_id = 2236 and ob.value_coded = 2234
        and ob.obs_datetime >= CAST('#startDate#' AS DATE)
        and ob.obs_datetime <= CAST('#endDate#' AS DATE)
        and ob.voided = 0
         )

    ) 

    UNION 

    (select distinct o.person_id, "Pulmonary Clinical" as "TB_Diagnosis" 
    FROM obs o
    -- Clinical Diagnosis X-Ray
    where o.concept_id = 4673 and o.value_coded = 4171
    and o.obs_datetime >= CAST('#startDate#' AS DATE)
    and o.obs_datetime <= CAST('#endDate#' AS DATE)
    and o.voided = 0
    and o.person_id in (
        select ob.person_id 
        FROM obs ob
        -- Pulmonary TB
        where ob.concept_id = 3788 and ob.value_coded = 1018
        and ob.obs_datetime >= CAST('#startDate#' AS DATE)
        and ob.obs_datetime <= CAST('#endDate#' AS DATE)
        and ob.voided = 0
        )
    or o.person_id in (
        select ob.person_id 
        FROM obs ob
        -- Pulmonary TB, Clinically Diagnosed
        where ob.concept_id = 2236 and ob.value_coded = 2235
        and ob.obs_datetime >= CAST('#startDate#' AS DATE)
        and ob.obs_datetime <= CAST('#endDate#' AS DATE)
        and ob.voided = 0
         )

    )

    UNION

    (select distinct ob.person_id, "Extra-Pulmonary" as "TB_Diagnosis" 
        FROM obs ob
        -- Extra Pulmonary TB
        where ob.concept_id = 3788 and ob.value_coded = 2233
        and ob.obs_datetime >= CAST('#startDate#' AS DATE)
        and ob.obs_datetime <= CAST('#endDate#' AS DATE)
        and ob.voided = 0
        or ob.person_id in (
        select ob.person_id 
        FROM obs ob
        -- Extra Pulmonary TB in ART Intake
        where ob.concept_id = 2236 and ob.value_coded = 2233
        and ob.obs_datetime >= CAST('#startDate#' AS DATE)
        and ob.obs_datetime <= CAST('#endDate#' AS DATE)
        and ob.voided = 0
         )

    )

)diagnosis_type
)diagnosis
on diagnosis.person_id = TB_HISTORY.Id
