
select distinct 
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender,
			o.value_numeric as Viral_Load,
			cast(max(o.obs_datetime) as date) as Date_Results_Captured
						

                from obs o
						
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
										 Select viral_load.person_id
                                    from(
										select VL_count.person_id, cast(VL_count.max_observation as date) as "Date Results Captured", Viral_load 
										from
										(select o.person_id, max_observation, value_numeric as Viral_load
												from obs o
												-- Viral Load copies per ml recorded greater than 1000 
												inner join
													(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
														from obs where concept_id = 4273 -- VL monitoring template
														and cast(obs_datetime as date) <= cast('#endDate#' as date)
														and voided = 0
														group by person_id) as latest_vl_result
													on latest_vl_result.person_id = o.person_id
													where o.concept_id = 2254 
													and o.obs_datetime = max_observation
													and o.voided = 0
													having value_numeric >= 1000
												)VL_count
                                    )viral_load
						 )
						 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(obs_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 2254 
				   and o.value_numeric >= 1000
				   and o.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('#endDate#' as datetime), interval 1 day)
				   Group  BY patientIdentifier 
				   order by 2