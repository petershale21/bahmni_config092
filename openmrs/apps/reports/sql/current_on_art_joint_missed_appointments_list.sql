SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, App_Status

FROM
        (
			SELECT distinct patient.patient_id AS Id,
							patient_identifier.identifier AS patientIdentifier,
							concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
							person.gender AS Gender,
							'Missed' AS App_Status
			FROM obs o
									INNER JOIN patient ON o.person_id = patient.patient_id AND o.concept_id = 3752 and o.value_datetime in
									(				
										select latestFU
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 AND os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												having Num_Days > 0 and Num_Days <= 7
											) AS Missed
									)									
									and o.person_id in
									(				
										select person_id
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 AND os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												having Num_Days > 0 and Num_Days <= 7
											) AS Missed
									)
									AND o.person_id not in (																		 
												select distinct os.person_id 
													from obs os
													where (os.concept_id = 4155 and os.value_coded = 2146 and obs_datetime < '#endDate#' and person_id not in 
													(select person_id from
														(select person_id who, max(value_datetime) latest
														from obs 
														where concept_ID = 2266
																			group by person_id) one,
														
														 (
														select person_id,obs_datetime 
														from obs 
														where concept_id = 3843 ) two
														
														where who = person_id
														and DATE(obs_datetime) > DATE(latest))
														)													  														 							 
												)
									AND o.person_id not in (
												select person_id 
												from person 
												where death_date <= '#endDate#' 
												and dead = 1
															)
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 5
					   
			UNION
			
			
			SELECT distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   'Defaulted' AS App_Status
			FROM obs o
									INNER JOIN patient ON o.person_id = patient.patient_id and o.concept_id = 3752 and o.value_datetime in
									(				
										select latestFU
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 AND os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												having Num_Days > 7 and Num_Days < 90
											) AS Defauled
									)									
									and o.person_id in
									(				
										select person_id
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 AND os.obs_datetime <= CAST('#endDate#' AS DATE) 
												group by os.person_id
												having Num_Days > 7 and Num_Days < 90
											) AS Defauled
									)
									AND o.person_id not in (																		 
			select distinct os.person_id 
				from obs os
				where (os.concept_id = 4155 and os.value_coded = 2146 and obs_datetime < '#endDate#' and person_id not in 
				(select person_id from
					(select person_id who, max(value_datetime) latest
					from obs 
					where concept_ID = 2266
                                        group by person_id) one,
					
					 (
					select person_id,obs_datetime 
					from obs 
					where concept_id = 3843 ) two
					
					where who = person_id
					and DATE(obs_datetime) > DATE(latest))
					)													  														 							 
			)
AND o.person_id not in (
			select person_id 
			from person 
			where death_date <= '#endDate#' 
			and dead = 1
						)
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 5
					   
			UNION
			
			
			SELECT distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   'LTFU' AS App_Status
			FROM obs o
									INNER JOIN patient ON o.person_id = patient.patient_id and o.concept_id = 3752 and o.value_datetime in
									(				
										select latestFU
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 AND os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												having Num_Days >= 90
											) AS Lost
									)									
									and o.person_id in
									(				
										select person_id
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 AND os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												having Num_Days >= 90
											) AS Lost
									)
									AND o.person_id not in (																		 
			select distinct os.person_id 
				from obs os
				where (os.concept_id = 4155 and os.value_coded = 2146 and obs_datetime < '#endDate#' and person_id not in 
				(select person_id from
					(select person_id who, max(value_datetime) latest
					from obs 
					where concept_ID = 2266
                                        group by person_id) one,
					
					 (
					select person_id,obs_datetime 
					from obs 
					where concept_id = 3843 ) two
					
					where who = person_id
					and DATE(obs_datetime) > DATE(latest))
					)													  														 							 
			)
AND o.person_id not in (
			select person_id 
			from person 
			where death_date <= '#endDate#' 
			and dead = 1
						)
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 5
			
		) AS Patient_MissedAppointments

ORDER BY Patient_MissedAppointments.Gender, Patient_MissedAppointments.App_Status;

