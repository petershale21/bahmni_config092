select distinct Patient_Identifier,
				ART_Number,
				File_Number,
				Patient_Name, 
				Age, 
				DOB, 
				Gender, 
				age_group, 
				Program_Status,
                _weight as "Weight",
				regimen_name,
                VL_result,
				Adherence
from -- obs o
-- left outer join

(
	(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, File_Number, patientName AS "Patient_Name", Age,DOB, Gender, age_group, 'Initiated' AS 'Program_Status'
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   pi.identifier as File_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group
									  

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						  INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
                                AND CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE) 
								AND CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )	
                         and o.person_id not in (
							-- Died
									select person_id 
									from person 
									where cast(death_date as date) <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5 AND p.preferred = 1
						 LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11 AND pi.preferred = 1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_ART_Clients
                   where Age < 15
ORDER BY Newly_Initiated_ART_Clients.Age)

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, File_Number, patientName AS "Patient_Name", Age,DOB, Gender, age_group, 'Seen' AS 'Program_Status'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
								   p.identifier as ART_Number,
								   pi.identifier as File_Number,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								   person.birthdate as DOB,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group
								  
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5 AND p.preferred = 1
								 LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11 and pi.preferred = 1
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 
											AND CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											AND CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)		
				 		AND patient.voided = 0 AND o.voided = 0
				 		AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							and os.voided = 0
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )	

							)
AND Clients_Seen.Id not in (
							select distinct(o.person_id)
							from obs o
							where o.person_id in (
									-- FOLLOW UPS
										select firstquery.person_id
										from
										(
										select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
										from obs oss
													where oss.voided=0 
													and oss.concept_id=3752 
													and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
													group by oss.person_id) firstquery
										inner join (
													select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
													from obs os
													where concept_id = 3752 and os.voided = 0
													and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													group by os.person_id
													having last_ap < 0
										) secondquery
										on firstquery.person_id = secondquery.person_id
							) and o.person_id in (
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2266 and os.voided = 0
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
							)				
		)

AND Clients_Seen.Id not in 
					(
						select distinct(o.person_id)
						from obs o
						where o.person_id in (
								-- FOLLOW UPS
											select firstquery.person_id
											from
											(
											select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
											from obs oss
														where oss.voided=0 
														and oss.concept_id=3752 
														and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
														and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
														group by oss.person_id) firstquery
											inner join (
														select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
														from obs os
														where concept_id = 3752
														and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
														group by os.person_id
														having last_ap < 0
											) secondquery
											on firstquery.person_id = secondquery.person_id
						)
						and o.person_id in (
								-- Death
											select distinct p.person_id
											from person p
											where dead = 1
											and cast(death_date as date) <= CAST('#endDate#' AS DATE)		
						)
					)

AND Clients_Seen.Id not in (
						select active_clients.person_id
								from
								-- Missed Appointments
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and cast(obs_datetime as date) <= cast('#endDate#' AS DATE)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								
							)

AND Clients_Seen.Id not in (
							-- Visitors
							select distinct os.person_id from obs os
							where os.concept_id = 5416
							AND os.value_coded = 1 and os.voided = 0
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

							)    

AND Age < 15
ORDER BY Clients_Seen.patientName)

UNION


-- INCLUDE MISSED APPOINTMENTS WITHIN 28 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, File_Number, patientName AS "Patient_Name", Age,DOB, Gender, age_group, 'MissedWithin28Days' AS 'Program_Status'
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									    pi.identifier as File_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
						 -- begin
						select active_clients.person_id
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
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) <= 28
				
				
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							and os.voided = 0
							)
						
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where concept_id = 2249
							AND CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							and os.voided = 0
							)
        and active_clients.person_id not in(
								-- Visitors
							select person_id 
							FROM
								(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
								from obs where concept_id = 5416 
								and value_coded = 1 and voided = 0
								and cast(obs_datetime as date) <= cast('#endDate#' as date)
								and voided = 0
								group by person_id)visitor
							)

		and active_clients.person_id not in (
							-- TOUTS
									select tout_clients.person_id
                                from
                                (select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
                                    from obs B
                                    inner join
                                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                    from obs where concept_id = 2403
                                    and cast(obs_datetime as date) <= cast('#endDate#' as date)
                                    and voided = 0
                                    group by person_id) as A
                                    on A.observation_id = B.obs_group_id
                                    where concept_id = 2398
                                    and A.observation_id = B.obs_group_id
                                    and voided = 0
                                    group by B.person_id
                                ) as tout_clients
                                where tout_clients.latest_consultation < cast('#endDate#' as date)
										
										)
			

		and active_clients.person_id not in (
									select person_id 
									from person 
									where cast(death_date as date) <= cast('#endDate#' as date)
									and dead = 1
						 )
						 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5 and p.preferred = 1
						 LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11 and pi.preferred = 1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TwentyEightDayDefaulters
                   WHERE Age < 15
				   order by TwentyEightDayDefaulters.patientName)

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, File_Number, patientName AS "Patient_Name", Age,DOB, Gender, age_group, 'Seen_Prev_Months' AS 'Program_Status'
FROM (
(select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									    pi.identifier as File_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- 
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
						 -- begin
						select active_clients.person_id
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id	
								) as active_clients
								where active_clients.latest_follow_up >= cast('#endDate#' as date)
				
				
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							AND os.voided = 0
							)
						
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where concept_id = 2249
							AND CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							AND os.voided = 0
							)
        and active_clients.person_id not in(
								-- Visitors
							select person_id 
							FROM
								(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
								from obs where concept_id = 5416 
								and value_coded = 1 and voided = 0
								and cast(obs_datetime as date) <= cast('#endDate#' as date)
								and voided = 0
								group by person_id)visitor
							)	

		and active_clients.person_id not in (
							select distinct(o.person_id)
							from obs o
							where o.person_id in (
									-- FOLLOW UPS
										select firstquery.person_id
										from
										(
										select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
										from obs oss
													where oss.voided=0 
													and oss.concept_id=3752 
													and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
													group by oss.person_id) firstquery
										inner join (
													select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
													from obs os
													where concept_id = 3752
													and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													group by os.person_id
													having last_ap < 0
										) secondquery
										on firstquery.person_id = secondquery.person_id
							) and o.person_id in (
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2266
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
							)			
										)
			

		and active_clients.person_id not in (
									select person_id 
									from person 
									where CAST(death_date AS DATE) <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
						 )
						 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5 AND p.preferred = 1
						 LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11 AND pi.preferred = 1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages')
		   
) AS ARTCurrent_PrevMonths
 WHERE Age < 15
ORDER BY ARTCurrent_PrevMonths.Age)

) previous

left outer join
(
-- regimen
select distinct a.person_id, 
case 
when ARV_regimen = 2201 then '1c'
when ARV_regimen = 2203 then '1d'
when ARV_regimen = 2205 then '1e'
when ARV_regimen = 2207 then '1f'
when ARV_regimen = 3672 then '1g'
when ARV_regimen = 3673 then '1h'
when ARV_regimen = 4678 then '1j'
when ARV_regimen = 4679 then '1k'
when ARV_regimen = 4680 then '1m'
when ARV_regimen = 4681 then '1n'
when ARV_regimen = 4682 then '1p'
when ARV_regimen = 4683 then '1q'
when ARV_regimen = 2143 then 'other'
when ARV_regimen = 2210 then '2c'
when ARV_regimen = 2209 then '2d'
when ARV_regimen = 3674 then '2e'
when ARV_regimen = 3675 then '2f'
when ARV_regimen = 3676 THEN "2g"
when ARV_regimen = 3677 THEN "2h"
when ARV_regimen = 3678 THEN "2i"
when ARV_regimen = 4689 THEN "2j"
when ARV_regimen = 4690 THEN "2k"
when ARV_regimen = 4691 THEN "2L"
when ARV_regimen = 4692 THEN "2m"
when ARV_regimen = 4693 THEN "2n"
when ARV_regimen = 4694 THEN "2o"
when ARV_regimen = 4695 THEN "2p"
when ARV_regimen = 4849 THEN "2q"
when ARV_regimen = 4850 THEN "2r"
when ARV_regimen = 4851 THEN "2s"
when ARV_regimen = 3683 THEN "3a"
when ARV_regimen = 3684 THEN "3b"
when ARV_regimen = 3685 THEN "3c"
when ARV_regimen = 4706 THEN "3d"
when ARV_regimen = 4707 THEN "3e"
when ARV_regimen = 4708 THEN "3f"
when ARV_regimen = 4709 THEN "3g"
when ARV_regimen = 4710 THEN "3h"
when ARV_regimen = 2202 THEN "4c"
when ARV_regimen = 2204 THEN "4d"
when ARV_regimen = 3679 THEN "4e"
when ARV_regimen = 3680 THEN "4f"
when ARV_regimen = 4684 THEN "4g"
when ARV_regimen = 4685 THEN "4h"
when ARV_regimen = 4686 THEN "4j"
when ARV_regimen = 4687 THEN "4k"
when ARV_regimen = 4688 THEN "4L"
when ARV_regimen = 3681 THEN "5a"
when ARV_regimen = 3682 THEN "5b"
when ARV_regimen = 4696 THEN "5c"
when ARV_regimen = 4697 THEN "5d"
when ARV_regimen = 4698 THEN "5e"
when ARV_regimen = 4699 THEN "5f"
when ARV_regimen = 4700 THEN "5g"
when ARV_regimen = 4701 THEN "5h"
when ARV_regimen = 3686 THEN "6a"
when ARV_regimen = 3687 THEN "6b"
when ARV_regimen = 4702 THEN "6c"
when ARV_regimen = 4703 THEN "6d"
when ARV_regimen = 4704 THEN "6e"
when ARV_regimen = 4705 THEN "6f"
when ARV_regimen = 4714 THEN "1a"
when ARV_regimen = 4715 THEN "1b"
else 'NewRegimen' end as regimen_name
from obs a
inner join 
		( SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen
		FROM(
					
					(select distinct o.person_id, max(o.obs_datetime) as maxdate, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_coded)), 20) AS current_regimen
					from obs o 
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					where o.concept_id = 2250
					AND o.voided = 0
					and o.obs_datetime <= cast('#endDate#' as date)
					group by person_id) as currentreg
					
					LEFT OUTER JOIN									

					
					(select distinct o.person_id, max(o.obs_datetime) as maxdate, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_coded)), 20) AS substitute_regimen
					from obs o 
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					where o.concept_id = 4284
					AND o.voided = 0
					and o.obs_datetime <= cast('#endDate#' as date)
					group by person_id) as substitutereg
					ON substitutereg.person_id =  currentreg.person_id

					LEFT OUTER JOIN					

					
					(select distinct o.person_id, max(o.obs_datetime) as maxdate, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_coded)), 20) AS switch_regimen
					from obs o 
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					where o.concept_id = 2268
					AND o.voided = 0
					and o.obs_datetime <= cast('#endDate#' as date)
					group by person_id) as switchreg
					ON switchreg.person_id =  currentreg.person_id
		)				
		
		)latest 
		on latest.person_id = a.person_id
) regimen

ON previous.Id = regimen.person_id

left outer JOIN

 (SELECT weight_.Id, _weight
 from
 (select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_numeric)), 20) as _weight
		 from obs oss
		 where oss.concept_id = 119 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id)AS weight_
 )peads_weight
ON previous.Id = peads_weight.Id

left outer join

(SELECT distinct person_id, VL_result
From
((select o.person_id, max_observation, "Undetectable" as "VL_result"
	from obs o
	inner join
		(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
			from obs where concept_id = 4273
			and obs_datetime <= cast('#endDate#' as date)
			and voided = 0
			-- Viral Load Undetectable
			group by person_id) as latest_vl_result
		on latest_vl_result.person_id = o.person_id
		where o.concept_id = 4266 and o.value_coded = 4263
		and o.obs_datetime = max_observation
		and o.voided = 0
			)

UNION

(select o.person_id, max_observation, "Less than 20" as "VL_result"
	from obs o
	inner join
		(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
			from obs where concept_id = 4273
			and obs_datetime <= cast('#endDate#' as date)
			and voided = 0
			-- Viral Load < 20
			group by person_id) as latest_vl_result
		on latest_vl_result.person_id = o.person_id
		where o.concept_id = 4266 and o.value_coded = 4264
		and o.obs_datetime = max_observation
		and o.voided = 0
		 )

UNION

(Select greater_than_20.person_id, max_observation, Viral_Load
from
(select o.person_id, max_observation
from obs o
inner join
	(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
		from obs where concept_id = 4273
		and obs_datetime <= cast('#endDate#' as date)
		and voided = 0
		-- Viral Load >=20
		group by person_id) as latest_vl_result
	on latest_vl_result.person_id = o.person_id
	where o.concept_id = 4266 and o.value_coded = 4265
	and o.obs_datetime = max_observation
	and o.voided = 0) greater_than_20
	inner join 
	(select o.person_id, value_numeric as Viral_load
		from obs o
		-- Viral Load copies per ml recorded
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
				from obs where concept_id = 4273
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as latest_vl_result
			on latest_vl_result.person_id = o.person_id
			where o.concept_id = 2254 
			and o.obs_datetime = max_observation
			and o.voided = 0
		 )numeric_value
	on greater_than_20.person_id = numeric_value.person_id
		 )
)viral_load_result	
	)results

ON previous.Id = results.person_id

-- Adherence
left outer join

(select
       o.person_id,
       case
           when value_coded = 2305 then "Good Adherence"
           when value_coded = 2306 then "Fair Adherence"
           when value_coded = 3702 then "Poor Adherence"
		   when value_coded = 1975 then "Not Applicable"
           else ""
       end AS Adherence
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as hiv_adherence
		 from obs oss
		 where oss.concept_id = 2308 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 2308
	and  o.obs_datetime = max_observation
	and o.voided = 0
	) hiv_adherence
ON previous.Id = hiv_adherence.person_id
