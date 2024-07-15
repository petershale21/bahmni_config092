SELECT patientIdentifier , patientName , Age, Gender, age_group, sort_order
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order
        from obs o
								-- Pregnant on ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 -- AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 AND o.person_id in(
													select person_id
													from
													(
													(select o.person_id
														from obs o
														inner join
															(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
																from obs where concept_id = 5420
																and cast(obs_datetime as date) >= cast('#startDate#' as date)
															and cast(obs_datetime as date) <= cast('#endDate#' as date)
																and voided = 0
																-- 
																group by person_id) as hiv_status
															on hiv_status.person_id = o.person_id
															where o.concept_id = 4427 and o.value_coded = 1738
															and cast(o.obs_datetime as date) >= cast('#startDate#' as date)
															and cast(o.obs_datetime as date) <= cast('#endDate#' as date)
													)

													UNION

													(
														select ob.person_id
														from obs ob
														where ob.concept_id = 4343 and ob.value_coded in(4341,4342) -- ANC Initiated on ART
														and CAST(ob.obs_datetime AS DATE) >= CAST('#startDate#'AS DATE)
														and CAST(ob.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
														and ob.voided = 0
													)
													)Hiv_Pos	
													
													)
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#'AS DATE)
								 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages'

) AS pregnant

