
  SELECT distinct Patient_Identifier,
				  Patient_Name,
				  Age,
				  DOB,
				  Gender,
				  Client_Outcome,
				  Date_TransferedOut,
				  Date_TransferedIn,
				  Date_IIT,
				  Date_Died,
				  Date_Stopped

FROM(
	
	(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name", Age,DOB, Gender, 'Active' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 AND MONTH(o.obs_datetime) >= MONTH(CAST('#startDate#' AS DATE)) 
								 AND MONTH(o.obs_datetime) <= MONTH(CAST('#endDate#' AS DATE))
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages'
           -- having Age <=19

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS NEWLY INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 
						AND MONTH(o.value_datetime) >= MONTH(CAST('#startDate#' AS DATE)) 
						AND MONTH(o.value_datetime) <= MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						)		
				 AND patient.voided = 0 AND o.voided = 0

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
														and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
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
											and death_date <= CAST('#endDate#' AS DATE)		
						)
					)

  AND Clients_Seen.Id not in (

                         select o.person_id

                                        -- Transfer In
											from obs o 
											INNER JOIN patient ON o.person_id = patient.patient_id
											INNER JOIN person ON patient.patient_id = person.person_id
											INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											where concept_id = 3634 and o.value_coded = 2095
											and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
											and o.voided = 0
  )  

  AND Clients_Seen.Id not in (
											select person_id
											from 
												(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
												from obs oss
												inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
												and oss.obs_datetime < cast('#startDate#' as DATE)
												group by p.person_id
												having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
										)                
					-- AND Age <=19
ORDER BY Clients_Seen.patientName)

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name", Age,DOB, Gender, 'Active' AS 'Client_Outcome'
FROM (
(select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- Multi Month Duration MMD
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
							AND CAST(os.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
							)
						
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where concept_id = 2249
							AND MONTH(os.value_datetime) >= MONTH(CAST('#startDate#' AS DATE)) 
							AND MONTH(os.value_datetime) <= MONTH(CAST('#endDate#' AS DATE))
							AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
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
													AND CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
													AND CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													AND CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
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
									where death_date <= cast('#endDate#' as date)
									and dead = 1
						 )

        and active_clients.person_id not in(
                                    select o.person_id
											from obs o 
											INNER JOIN patient ON o.person_id = patient.patient_id
											INNER JOIN person ON patient.patient_id = person.person_id
											INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											where concept_id = 3634 and o.value_coded = 2095
											and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
											and o.voided = 0

                         )

		 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages')
		   
) AS ARTCurrent_PrevMonths
 -- WHERE Age <=19
 )

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name", Age,DOB, Gender, 'Interruption in Treatment' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
								   p.identifier as ART_Number,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								   person.birthdate as DOB,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group

				from 

									(	
										
										select o.person_id
										from obs o
												INNER JOIN patient ON o.person_id = patient.patient_id
												AND patient.voided = 0 AND o.voided = 0
												AND o.person_id in (
														select person_id
														from 
															(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
															from obs oss
															inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
															and oss.obs_datetime < cast('#startDate#' as DATE)
															group by p.person_id
															having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) < 29) as On_ART_Beginning_Quarter
												)
												AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														from obs oss
														inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														and oss.obs_datetime <= cast('#endDate#' as DATE)
														group by p.person_id
														having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												)
												INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
										UNION
										select o.person_id
										from obs o
												INNER JOIN patient ON o.person_id = patient.patient_id
												AND patient.voided = 0 AND o.voided = 0
												AND o.concept_id = 2249 and cast(o.value_datetime as date) >= cast('#startDate#' as DATE) and cast(o.value_datetime as date) <= cast('#endDate#' as DATE)
												AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														from obs oss
														inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														and oss.obs_datetime <= cast('#endDate#' as DATE)
														group by p.person_id
														having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												)
												INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id


									) as IIT
									INNER JOIN patient ON IIT.person_id = patient.patient_id
									AND patient.voided = 0 
									 AND IIT.person_id in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 2249
											AND datediff(CAST('#endDate#' AS DATE), os.value_datetime) > 0						
									)
									-- NOT Transfered Out to Another Site
									AND IIT.person_id not in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 4155 and os.value_coded = 2146
											AND os.obs_datetime <= CAST('#endDate#' AS DATE)						
									)
									-- NOT DEAD
									AND IIT.person_id not in (
											select person_id 
											from person 
											where death_date <= CAST('#endDate#' AS DATE)
											and dead = 1
									)

                                    AND IIT.person_id in(
                                                -- Not active at the end of the quarter
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
                                                where active_clients.latest_follow_up <= cast('#endDate#' as date)
                                    )

                                  
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')  AS IIT
		   -- WHERE Age <=19
)

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name", Age,DOB, Gender, 'Transfer In' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
								   p.identifier as ART_Number,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								   person.birthdate as DOB,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group

				from 

									(	
									select distinct o.person_id 
									from obs o 
									where o.person_id in		
										(	select o.person_id
											from obs o 
											INNER JOIN patient ON o.person_id = patient.patient_id
											INNER JOIN person ON patient.patient_id = person.person_id
											INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											where concept_id = 3634 and o.value_coded = 2095
											and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
											and o.voided = 0)

                                    OR o.person_id in(
                                        select os.person_id 
												from obs os
												where os.concept_id = 2253
                                                AND DATE (os.value_datetime)>=CAST('#startDate#' AS DATE) 
                                                AND DATE (os.value_datetime)<=CAST('#endDate#' AS DATE)
												AND os.voided = 0


                                    )
                                        
									) as transfer_in
									INNER JOIN patient ON transfer_in.person_id = patient.patient_id
									AND patient.voided = 0 
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')  AS TransferIn
		   -- WHERE Age <=19
		   )

UNION


(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name", Age,DOB, Gender, 'Transfer Out' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
								   p.identifier as ART_Number,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								   person.birthdate as DOB,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group

				from 

		(select o.person_id
		from obs o
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND patient.voided = 0 AND o.voided = 0
				 AND o.person_id in (
						select person_id
						from 
							(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
							 from obs oss
							 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
							 and oss.obs_datetime < cast('#startDate#' as DATE)
							 group by p.person_id
							 having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) < 29) as On_ART_Beginning_Quarter
				 )
				 AND o.person_id in (
					select person_id
					from 
						(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
						 from obs oss
						 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
						 and oss.obs_datetime <= cast('#endDate#' as DATE)
						 group by p.person_id
						 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
				 )
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		group by patient.patient_id
		UNION
		select o.person_id
		from obs o
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND patient.voided = 0 AND o.voided = 0
				 AND o.concept_id = 2249 and cast(o.value_datetime as date) >= cast('#startDate#' as DATE) and cast(o.value_datetime as date) <= cast('#endDate#' as DATE)
				 AND o.person_id in (
					select person_id
					from 
						(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
						 from obs oss
						 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
						 and oss.obs_datetime <= cast('#endDate#' as DATE)
						 group by p.person_id
						 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
				 )
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
				group by patient.patient_id
                                        
				) as touts

				INNER JOIN patient ON touts.person_id = patient.patient_id
				AND patient.voided = 0
				-- Transfered Out to Another Site
	 			AND touts.person_id in (
					select distinct os.person_id 
					from obs os
					where os.concept_id = 4155 and os.value_coded = 2146
				AND os.obs_datetime <= CAST('#endDate#' AS DATE)						
	 		)
	 		-- NOT DEAD
	 		AND touts.person_id not in (
				select distinct person_id 
				from person 
				where death_date <= CAST('#endDate#' AS DATE)
				and dead = 1
	 	)
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')  AS TransferOut
		   -- WHERE Age <=19
		   )

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name", Age,DOB, Gender, 'Stopped Treatment' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
								   p.identifier as ART_Number,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								   person.birthdate as DOB,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group

				from 

									(

										select o.person_id
										from obs o
												INNER JOIN patient ON o.person_id = patient.patient_id
												AND patient.voided = 0 AND o.voided = 0
												AND o.person_id in (
														select person_id
														from 
															(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
															from obs oss
															inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
															and oss.obs_datetime < cast('#startDate#' as DATE)
															group by p.person_id
															having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) < 29) as On_ART_Beginning_Quarter
												)
												AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														from obs oss
														inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														and oss.obs_datetime <= cast('#endDate#' as DATE)
														group by p.person_id
														having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												)
												INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
										UNION
										select o.person_id
										from obs o
												INNER JOIN patient ON o.person_id = patient.patient_id
												AND patient.voided = 0 AND o.voided = 0
												AND o.concept_id = 2249 and cast(o.value_datetime as date) >= cast('#startDate#' as DATE) and cast(o.value_datetime as date) <= cast('#endDate#' as DATE)
												AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														from obs oss
														inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														and oss.obs_datetime <= cast('#endDate#' as DATE)
														group by p.person_id
														having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												)
												INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id

									) as stopped
									INNER JOIN patient ON stopped.person_id = patient.patient_id
									AND patient.voided = 0 
									AND stopped.person_id in 
									(
										select distinct os.person_id 
									from obs os
									where os.concept_id = 3701 
									AND os.value_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')  AS StoppedTreatment
		   -- WHERE Age <=19
		   )

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name", Age,DOB, Gender, 'Reinitiating Treatment' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
								   p.identifier as ART_Number,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								   person.birthdate as DOB,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group

				from 

									(	


										select distinct o.person_id
										from obs o
										-- PATIENTS WITH NO CLINICAL CONTACT OR ARV PICK-UP FOR GREATER THAN 28 DAYS
										-- SINCE THEIR LAST EXPECTED CONTACT WHO RESTARTED ARVs WITHIN THE REPORTING PERIOD
										INNER JOIN patient ON o.person_id = patient.patient_id
										AND patient.voided = 0 AND o.voided = 0
										AND o.person_id in (
											select person_id
											from 
												(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
												from obs oss
												inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
												and oss.obs_datetime < cast('#startDate#' as DATE)
												group by p.person_id
												having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
										)

										-- Client Seen: As either patient OR Treatment Buddy
										AND (						 
												o.person_id in (
														select distinct os.person_id
														from obs os
														where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
														AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												)
												
												-- Client Seen and Date Restarted picked 
												OR o.person_id in (
														select distinct os.person_id
														from obs os
														where os.concept_id = 3708 AND os.value_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												)
										)
										-- Still on treatment at the end of the reporting period
										AND o.person_id in (
											select person_id
											from 
												(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
												from obs oss
												inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
												and oss.obs_datetime >= cast('#startDate#' as DATE) and oss.obs_datetime <= cast('#endDate#' as DATE)
												group by p.person_id
												having datediff(CAST('#endDate#' AS DATE), latest_follow_up) <= 28) as Still_On_Treatment_End_Period
										)
										
										-- Transfered Out to Another Site during thier latest encounter before the start date
										AND o.person_id not in (
											select person_id
											from 
												(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS last_obs_tout
												from obs oss
												inner join person p on oss.person_id=p.person_id and oss.concept_id = 4155 and oss.voided=0
												and oss.obs_datetime < cast('#startDate#' as DATE)
												group by p.person_id
												having last_obs_tout = 2146) as Transfered_Out_In_Last_Encounter
										)
										
										-- NOT Transfered In from another Site
										AND o.person_id not in (
												select os.person_id 
												from obs os
												where os.concept_id = 2253
                                                AND DATE (os.value_datetime)>=CAST('#startDate#' AS DATE) 
                                                AND DATE (os.value_datetime)<=CAST('#endDate#' AS DATE)
												AND os.voided = 0					
										)						 
										
										AND o.person_id not in (
													select person_id 
													from person 
													where death_date <= CAST('#endDate#' AS DATE)
													and dead = 1
										)
                                        
                                                                           
									) as reinitiating
									INNER JOIN patient ON reinitiating.person_id = patient.patient_id
									AND patient.voided = 0 
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')  AS ReinitiatingTreatment
		   -- WHERE Age <=19
		   )

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name", Age,DOB, Gender, 'Died' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
								   p.identifier as ART_Number,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								   person.birthdate as DOB,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group

				from 

									(	
										select person_id 
													from person 
													where death_date <= CAST('#endDate#' AS DATE)
													and dead = 1
                                                    and CAST(death_date AS DATE) >= CAST('#startDate#' AS DATE)
											        and CAST(death_date AS DATE) <= CAST('#endDate#' AS DATE)
											        -- and CAST(death_date AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
										

									) as died
									INNER JOIN patient ON died.person_id = patient.patient_id
									AND patient.voided = 0 
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages')  AS Died
		   -- WHERE Age <=19
))client_outcomes

-- Track Cohort -> TxCurr Q4 2019 to Q4 2020

inner join 

	( 
		select active_clients.person_id-- , Age-- , active_clients.latest_follow_up
			from
			(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up, B.obs_datetime, Age
				from obs B
				inner join 
				(select o.person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id,
				floor(datediff(CAST('2019-09-30' AS DATE), person.birthdate)/365) AS Age
				from obs o
				INNER JOIN patient ON o.person_id = patient.patient_id
				INNER JOIN person ON patient.patient_id = person.person_id
				where concept_id = 3753
				and obs_datetime <= cast('2020-09-30' as date)
				and o.voided = 0
				group by person_id
				having Age <=19) as A
				on A.observation_id = B.obs_group_id
				where concept_id = 3752
				and A.observation_id = B.obs_group_id
                and voided = 0	
				group by B.person_id	
				) as active_clients
				where active_clients.latest_follow_up >= CAST('2019-09-30' AS DATE)
	)tracked_clients
	on tracked_clients.person_id = client_outcomes.Id
			

-- Date Transferred out
left outer JOIN
	   (
		select os.person_id, CAST(max(os.value_datetime) AS DATE) as Date_TransferedOut
		from obs os
		where os.concept_id=2266 and os.voided = 0
		 and os.value_datetime < cast('#endDate#' as date)
		group by os.person_id
	   )date_tout
	   on client_outcomes.Id = date_tout.person_id

-- Date Transferred In
	left outer JOIN
	   (
		select os.person_id, CAST(max(os.value_datetime) AS DATE) as Date_TransferedIn
		from obs os
		where os.concept_id=2253 and os.voided = 0
		-- and os.value_datetime < cast('#endDate#' as date)
        and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		and CAST(os.value_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH) 
		group by os.person_id
	   )date_tin
	   on client_outcomes.Id = date_tin.person_id

-- Date Died 
	left outer JOIN
	   (
			select distinct p.person_id, CAST(max(p.death_date) AS DATE) as Date_Died
			from person p
			where dead = 1
			and death_date >= CAST('#startDate#' AS DATE) and death_date <= CAST('#endDate#' AS DATE)
	   )date_died
	   on client_outcomes.Id = date_died.person_id

-- Date Interruption in Treatment 
	left outer JOIN

		(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up,
		CAST(DATE_ADD(latest_follow_up, INTERVAL 29 DAY) AS DATE) as Date_IIT
		from obs oss 
		inner join 		
				(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
				from obs oss 
				inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
				and oss.obs_datetime <= cast('#endDate#' as DATE)
				group by p.person_id
				having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) IIT_
				on IIT_.person_id = oss.person_id
		and oss.concept_id = 3752 and oss.voided=0
		and oss.obs_datetime <= cast('#endDate#' as DATE)
		group by person_id
		having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28)Interruption_in_treatment
		on client_outcomes.Id = Interruption_in_treatment.person_id

-- Date Treatment Stopped
left outer join
(select o.person_id,CAST(o.value_datetime AS DATE) as Date_Stopped
from obs o 
	where concept_id = 3701 and o.voided = 0
	and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH) 
	and o.person_id in (
			select os.person_id
			from obs os
			where os.concept_id=3767 and os.value_coded = 2297 and os.voided = 0	
	
	)	
	)datestopped
ON client_outcomes.Id = datestopped.person_id



	