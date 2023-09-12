SELECT ageGroup, 
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'First_Visit', 1, 0))) AS ANC_1st_visits,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = '1st_trimester_visits', 1, 0))) AS 1st_trimester_visits,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = '2nd_trimester_visits', 1, 0))) AS 2nd_trimester_visits,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = '3rd_trimester_visits', 1, 0))) AS 3rd_trimester_visits,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'high_risk_pregnancy', 1, 0))) AS high_risk_pregnancy,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'followUp_visit', 1, 0))) AS Subsequent_visit,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'Syphilis_Positive_Results_less_36_Weeks', 1, 0))) AS Syphilis_Positive_Results_less_36_Weeks,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'Syphilis_Positive_Results_Greater_36_Weeks', 1, 0))) AS Syphilis_Positive_Results_Greater_36_Weeks,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'Syphilis_Treatment_Completed', 1, 0))) AS Syphilis_Treatment_Completed,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'Haemoglobin_less_12gdl_less_36_weeks', 1, 0))) AS Haemoglobin_less_12gdl_less_36_weeks,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'Haemoglobin_Greater_12gdl_less_36_weeks', 1, 0))) AS Haemoglobin_Greater_12gdl_less_36_weeks,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'Haemoglobin_less_12gdl_Greater_36_weeks', 1, 0))) AS Haemoglobin_less_12gdl_Greater_36_weeks,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'Haemoglobin_Greater_12gdl_Greater_36_weeks', 1, 0))) AS Haemoglobin_Greater_12gdl_Greater_36_weeks,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'MUAC_less_23', 1, 0))) AS MUAC_less_23,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'Suspected_with_TB', 1, 0))) AS Suspected_with_TB,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'tetatus_protected', 1, 0))) AS tetatus_protected,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'Iron_folate', 1, 0))) AS Iron_folate,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'HIV_positive_male_partner', 1, 0))) AS HIV_positive_male_partner,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'TB_Treatment', 1, 0))) AS TB_Treatment,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'ON_INH', 1, 0))) AS ON_INH,
IF(Id IS NULL, 0, SUM(IF(ANC_visit = 'pregnancy_complications', 1, 0))) AS pregnancy_complications
FROM 
	( 
		SELECT Id, ANC_visit,ageGroup
		FROM
		( 
			-- First visit
			select o.person_id as Id,'First_Visit' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
						FROM
						( 
							select distinct o.person_id AS Id,
								floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
							from obs o
							INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
						) as a
						WHERE age < 15
				      	   )
			WHERE concept_id = 4658 and value_coded = 4659
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			
			-- visits in first trimester 4658 and value_coded in (4659,4660)
			
			select o.person_id as Id,'1st_trimester_visits' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
										
								) as a
								WHERE age < 15
												)
			AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric < 13)
			WHERE concept_id = 4658 and value_coded in (4659)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- visits in second
			
			select o.person_id as Id,'2nd_trimester_visits' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
									WHERE o.concept_id = 4658 and o.value_coded = 4659
								) as a
								WHERE age < 15
												)
			AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric >= 13 and value_numeric <= 25)
			WHERE concept_id = 4658 and value_coded in (4659)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- visits in third
			select o.person_id as Id,'3rd_trimester_visits' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
									WHERE o.concept_id = 4658 and o.value_coded = 4659
								) as a
								WHERE age < 15
					      )
			AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric > 25)
			WHERE concept_id = 4658 and value_coded in (4659)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- high risk pregnancies
			
			select o.person_id as Id,'high_risk_pregnancy' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age < 15
												)
			WHERE concept_id = 4352 and value_coded != 4353
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- total ANC follow up visits 2nd,3rd,4th
			
			select o.person_id as Id,'followUp_visit' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age < 15
												)							
			where concept_id = 4658 and value_coded = 4660
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- syphilis Positive Results <36 weeks
			
			select distinct a.person_id, 'Syphilis_Positive_Results_less_36_Weeks' as ANC_visit,'Under15' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age < 15
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			where concept_id = 4305 and value_coded =4306
			and a.obs_datetime >= CAST('#startDate#' AS DATE)
    		and a.obs_datetime <= CAST('#endDate#'AS DATE)

			
			UNION
			-- syphilis Positive Results >36 weeks
			
			select distinct a.person_id, 'Syphilis_Positive_Results_Greater_36_Weeks' as ANC_visit,'Under15' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age < 15
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period >= 36
							)
			where concept_id = 4305 and value_coded =4306
			and a.obs_datetime >= CAST('#startDate#' AS DATE)
    		and a.obs_datetime <= CAST('#endDate#'AS DATE)

			UNION

			-- Syphilis Treatment Completed
			select distinct a.person_id, 'Syphilis_Treatment_Completed' as ANC_visit,'Under15' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age < 15
							)
			where concept_id = 1732 and value_coded = 2146
			and a.obs_datetime >= CAST('#startDate#' AS DATE)
    		and a.obs_datetime <= CAST('#endDate#'AS DATE)

			UNION
			-- Haemoglobin_less_12gdl_less_36_weeks
			select distinct a.person_id, 'Haemoglobin_less_12gdl_less_36_weeks' as ANC_visit,'Under15' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age < 15
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin < 12
							)
			UNION
			-- Haemoglobin_less_12gdl_Greater_36_weeks
			select distinct a.person_id, 'Haemoglobin_Greater_12gdl_less_36_weeks' as ANC_visit,'Under15' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age < 15
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin >= 12
							)
			UNION
			-- Haemoglobin_less_12gdl_Greater_36_weeks

			select distinct a.person_id, 'Haemoglobin_less_12gdl_Greater_36_weeks' as ANC_visit,'Under15' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age <15
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin < 12
							)
			UNION
			-- Haemoglobin_Greater_12gdl_Greater_36_weeks

			select distinct a.person_id, 'Haemoglobin_Greater_12gdl_Greater_36_weeks' as ANC_visit,'Under15' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age >=20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period >= 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin >= 12
							)
			UNION

			select distinct a.person_id, 'MUAC_less_23' as ANC_visit,'Under15' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age < 15
							)
			AND a.person_Id in (Select Id
									FROM
									(	select person_id as Id, value_numeric as MUAC
											from obs o 
											where concept_id = 2086 and voided = 0
											and o. obs_datetime >= CAST('#startDate#' AS DATE)
											and o. obs_datetime <= CAST('#endDate#'AS DATE)
											and o.value_numeric <23
									) as muac
									)

			UNION

			select distinct a.person_id, 'Suspected_with_TB' as ANC_visit,'Under15' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age < 15
							)
			AND a.person_Id in (Select Id
									FROM
									(	select person_id as Id, value_coded as TB_Status
										from obs os
										where concept_id = 3710 and voided = 0
										)TB_Status

										inner join
										(
											select concept_id, name AS Tuberculosis
												from concept_name 
													where name in ('No signs', 'Suspected / Probable', 'On TB treatment') 
										) tb_concept
										on tb_concept.concept_id = TB_Status.TB_Status 
										where tb_concept.Tuberculosis = 'Suspected / Probable'
									) 

			UNION
			-- Pregnancies protected against tetatus
			
			select o.person_id as Id,'tetatus_protected' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age < 15
												)
			where concept_id = 4317
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- Provided with Iron 4299 and Folate 4300
			
			select o.person_id as Id,'Iron_folate' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age < 15
												)
			and concept_id in (4300,4299) AND value_coded in (4668)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- 
			select o.person_id as Id,'HIV_positive_male_partner' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age < 15
												)
			where concept_id = 1741 and value_coded in ( 1738,4323)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			-- Referred for TB treatment
			select o.person_id as Id,'TB_Treatment' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age < 15
												)
			where concept_id = 4337 and value_coded != 1975
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			-- Initiated on INH
			select o.person_id as Id,'ON_INH' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age < 15
												)
			where concept_id = 4337 and value_coded = 4333
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			-- total pregnancy complications
			select o.person_id as Id,'pregnancy_complications' as ANC_visit,'Under15' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age < 15
												)
			where (concept_id = 4367 and value_coded != 4368)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			
			UNION

			-- ------------------------------------- 15-19years -------------------------------
			-- First visit
			select o.person_id as Id,'First_Visit' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
						FROM
						( 
							select distinct o.person_id AS Id,
								floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
							from obs o
							INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
						) as a
						WHERE age > 14
							and age <20
				      	   )
			WHERE concept_id = 4658 and value_coded = 4659
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			
			-- visits in first trimester 4658 and value_coded in (4659,4660)
			
			select o.person_id as Id,'1st_trimester_visits' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
									
								) as a
								WHERE age > 14
							and age <20
												)
			AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric < 13)
			WHERE concept_id = 4658 and value_coded in (4659)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- visits in second
			
			select o.person_id as Id,'2nd_trimester_visits' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								
								) as a
								WHERE age > 14
							and age <20
												)
			AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric >= 13 and value_numeric <= 25)
			WHERE concept_id = 4658 and value_coded in (4659)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- visits in third
			select o.person_id as Id,'3rd_trimester_visits' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
									
								) as a
								WHERE age > 14
							and age <20
					      )
			AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric > 25)
			WHERE concept_id = 4658 and value_coded in (4659)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- high risk pregnancies
			
			select o.person_id as Id,'high_risk_pregnancy' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
												)
			WHERE concept_id = 4352 and value_coded != 4353
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- total ANC follow up visits 2nd,3rd,4th
			
			select o.person_id as Id,'followUp_visit' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
												)							
			where concept_id = 4658 and value_coded = 4660
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION

			-- syphilis Positive Results <36 weeks
			
			select distinct a.person_id, 'Syphilis_Positive_Results_less_36_Weeks' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age > 14
								and Age <20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			where concept_id = 4305 and value_coded =4306
			and a.obs_datetime >= CAST('#startDate#' AS DATE)
    		and a.obs_datetime <= CAST('#endDate#'AS DATE)

			UNION

			-- syphilis Positive Results >36 weeks
			
			select distinct a.person_id, 'Syphilis_Positive_Results_Greater_36_Weeks' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age > 14
								and Age <20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period > 36
							)
			where concept_id = 4305 and value_coded =4306
			and a.obs_datetime >= CAST('#startDate#' AS DATE)
    		and a.obs_datetime <= CAST('#endDate#'AS DATE)

			UNION

			-- Syphilis Treatment Completed
			select distinct a.person_id, 'Syphilis_Treatment_Completed' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age > 14
								and Age <20
							)
			where concept_id = 1732 and value_coded = 2146
			and a.obs_datetime >= CAST('#startDate#' AS DATE)
    		and a.obs_datetime <= CAST('#endDate#'AS DATE)

			UNION
			-- Haemoglobin_less_12gdl_less_36_weeks

			select distinct a.person_id, 'Haemoglobin_less_12gdl_less_36_weeks' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age > 14
								and Age <20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin < 12
							)
			UNION
			-- Haemoglobin_less_12gdl_Greater_36_weeks

			select distinct a.person_id, 'Haemoglobin_Greater_12gdl_less_36_weeks' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age > 14
								and Age <20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin >= 12
							)

			UNION
			-- Haemoglobin_less_12gdl_Greater_36_weeks

			select distinct a.person_id, 'Haemoglobin_less_12gdl_less_36_weeks' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age > 14
								and Age <20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period >= 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin < 12
							)
			UNION
			-- Haemoglobin_Greater_12gdl_Greater_36_weeks

			select distinct a.person_id, 'Haemoglobin_Greater_12gdl_less_36_weeks' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age > 14
								and Age <20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period >= 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin >= 12
							)

			
			UNION
			select distinct a.person_id, 'MUAC_less_23' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
							)
			AND a.person_Id in (Select Id
									FROM
									(	select person_id as Id, value_numeric as MUAC
											from obs o 
											where concept_id = 2086 and voided = 0
											and o. obs_datetime >= CAST('#startDate#' AS DATE)
											and o. obs_datetime <= CAST('#endDate#'AS DATE)
											and o.value_numeric <23
									)AS MUAC
									)

			UNION

			select distinct a.person_id, 'Suspected_with_TB' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
							)
			AND a.person_Id in (Select Id
									FROM
									(	select person_id as Id, value_coded as TB_Status
										from obs os
										where concept_id = 3710 and voided = 0
										)TB_Status

										inner join
										(
											select concept_id, name AS Tuberculosis
												from concept_name 
													where name in ('No signs', 'Suspected / Probable', 'On TB treatment') 
										) tb_concept
										on tb_concept.concept_id = TB_Status.TB_Status 
										where tb_concept.Tuberculosis = 'Suspected / Probable'
									) 

			UNION
			-- Pregnancies protected against tetatus
			
			select o.person_id as Id,'tetatus_protected' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
												)
			where concept_id = 4317
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- Provided with Iron 4299 and Folate 4300
			
			select o.person_id as Id,'Iron_folate' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
												)
			and concept_id in (4300,4299) AND value_coded in (4668)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- 
			select o.person_id as Id,'HIV_positive_male_partner' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
												)
			where concept_id = 1741 and value_coded in ( 1738,4323)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			-- Referred for TB treatment
			select o.person_id as Id,'TB_Treatment' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
												)
			where concept_id = 4337 and value_coded != 1975
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			-- Initiated on INH
			select o.person_id as Id,'ON_INH' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
												)
			where concept_id = 4337 and value_coded = 4333
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			-- total pregnancy complications
			select o.person_id as Id,'pregnancy_complications' as ANC_visit,'15-19years' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age > 14
							and age <20
												)
			where (concept_id = 4367 and value_coded != 4368)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			
			UNION

			-- -------------------------------- above 20 ----------------------------------------------
			-- First Visit
			select o.person_id as Id,'First_Visit' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age >=20
												)
			WHERE concept_id = 4658 and value_coded = 4659
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#' 

			UNION

			-- 1st trimester visits
			select o.person_id as Id,'1st_trimester_visits' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								
								) as a
								WHERE age >=20
												)
			AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric < 13)
			WHERE concept_id = 4658 and value_coded in (4659)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#' 
			

			UNION
			-- visits in second Trimester
			
			select o.person_id as Id,'2nd_trimester_visits' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								
								) as a
								WHERE age >=20
												)
			AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric >= 13 and value_numeric <= 25)
			WHERE concept_id = 4658 and value_coded in (4659)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- visits in third
			select o.person_id as Id,'3rd_trimester_visits' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
									
								) as a
								WHERE age >=20
												)
			AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric > 25)
			WHERE concept_id = 4658 and value_coded in (4659)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- high risk pregnancies
			
			select o.person_id as Id,'high_risk_pregnancy' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0 
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age >=20
												)
			WHERE concept_id = 4352 and value_coded != 4353
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- total ANC follow up visits 2nd,3rd,4th
			
			select o.person_id as Id,'followUp_visit' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age >=20
												)
			where concept_id = 4658 and value_coded = 4660
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- Syphilis_Positive_Results_less_36_Weeks
			
			select distinct a.person_id, 'Syphilis_Positive_Results_less_36_Weeks' as ANC_visit,'Above20' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age <=20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			where concept_id = 4305 and value_coded =4306
			and a.obs_datetime >= CAST('#startDate#' AS DATE)
    		and a.obs_datetime <= CAST('#endDate#'AS DATE)
			

			UNION
			-- Syphilis_Positive_Results_Greater_36_Weeks
			
			select distinct a.person_id, 'Syphilis_Positive_Results_Greater_36_Weeks' as ANC_visit,'Above20' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age <=20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period > 36
							)
			where concept_id = 4305 and value_coded =4306
			and a.obs_datetime >= CAST('#startDate#' AS DATE)
    		and a.obs_datetime <= CAST('#endDate#'AS DATE)

			UNION

			-- Syphilis Treatment Completed
			select distinct a.person_id, 'Syphilis_Treatment_Completed' as ANC_visit,'15-19years' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE  Age >= 20
							)
			where concept_id = 1732 and value_coded = 2146
			and a.obs_datetime >= CAST('#startDate#' AS DATE)
    		and a.obs_datetime <= CAST('#endDate#'AS DATE)

			UNION
			-- Haemoglobin_less_12gdl_less_36_weeks

			select distinct a.person_id, 'Haemoglobin_less_12gdl_less_36_weeks' as ANC_visit,'Above20' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age >=20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin < 12
							)
			UNION
			-- Haemoglobin_Greater_12gdl_less_36_weeks

			select distinct a.person_id, 'Haemoglobin_Greater_12gdl_less_36_weeks' as ANC_visit,'Above20' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age >=20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period < 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin >= 12
							)

		    UNION
			-- Haemoglobin_less_12gdl_Greater_36_weeks

			select distinct a.person_id, 'Haemoglobin_less_12gdl_Greater_36_weeks' as ANC_visit,'Above20' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age >=20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period >= 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin < 12
							)
			UNION
			-- Haemoglobin_Greater_12gdl_Greater_36_weeks

			select distinct a.person_id, 'Haemoglobin_Greater_12gdl_less_36_weeks' as ANC_visit,'Above20' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age >=20
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Gestational_Period
										from obs o
										where o.concept_id = 2423 and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Ges_Period
								WHERE Gestational_Period >= 36
							)
			AND a.person_Id in (select Id
								FROM
								( 
									select distinct o.person_id AS Id, o.value_numeric as Haemoglobin
										from obs o
										where o.concept_id = 3204 
										and o.voided = 0
										and o.obs_datetime >= CAST('#startDate#' AS DATE)
										and o.obs_datetime <= CAST('#endDate#' AS DATE)	
								) as Haemo
								WHERE Haemoglobin >= 12
							)


			UNION

			select distinct a.person_id, 'MUAC_less_23' as ANC_visit,'Above20' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age >=20
							) 
			AND a.person_Id in (Select Id
									FROM
									(	select person_id as Id, value_numeric as MUAC
											from obs o 
											where concept_id = 2086 and voided = 0
											and o. obs_datetime >= CAST('#startDate#' AS DATE)
											and o. obs_datetime <= CAST('#endDate#'AS DATE)
											and o.value_numeric <23
									) as Muac
									)

			UNION

			select distinct a.person_id, 'Suspected_with_TB' as ANC_visit,'Above20' as ageGroup
			from obs a
			INNER JOIN person ON person.person_id = a.person_id AND person.voided = 0
			AND a.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE Age >=20
							)
			AND a.person_Id in (Select Id
									FROM
									(	select person_id as Id, value_coded as TB_Status
										from obs os
										where concept_id = 3710 and voided = 0
										)TB_Status

										inner join
										(
											select concept_id, name AS Tuberculosis
												from concept_name 
													where name in ('No signs', 'Suspected / Probable', 'On TB treatment') 
										) tb_concept
										on tb_concept.concept_id = TB_Status.TB_Status 
										where tb_concept.Tuberculosis = 'Suspected / Probable'
									)

			UNION
			-- Pregnancies protected against tetatus
			
			select o.person_id as Id,'tetatus_protected' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age >=20
												)
			where concept_id = 4317
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- Provided with Iron 4299 and Folate 4300
			
			select o.person_id as Id,'Iron_folate' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age >=20
												)
			and concept_id in (4300,4299) AND value_coded in (4668)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
			

			UNION
			-- 
			select o.person_id as Id,'HIV_positive_male_partner' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age >=20
												)
			where concept_id = 1741 and value_coded in ( 1738,4323)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			-- Referred for TB treatment
			select o.person_id as Id,'TB_Treatment' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age >=20
												)
			where concept_id = 4337 and value_coded != 1975
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			-- Initiated on INH
			select o.person_id as Id,'ON_INH' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age >=20
												)
			where concept_id = 4337 and value_coded = 4333
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'

			UNION
			-- total pregnancy complications
			select o.person_id as Id,'pregnancy_complications' as ANC_visit,'Above20' as ageGroup
			from obs o
			INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
			AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age								   
									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
								WHERE age >=20
												)
			where (concept_id = 4367 and value_coded != 4368)
			AND obs_datetime BETWEEN '#startDate#' and '#endDate#'
		)as a	


    left outer join
	(
	select person_id, value_coded as Status_Code
	from obs os
	where concept_id = 4427 and voided = 0
	and os.obs_datetime >= CAST('#startDate#' AS DATE)
    and os.obs_datetime <= CAST('#endDate#'AS DATE)
	)HIV_Status

	inner join
	(
		select concept_id, name AS HIV_Status_Known_Before_Visit
			from concept_name 
				where name in ('Positive', 'Negative', 'Unknown') 
	) hiv_concept_name
	on hiv_concept_name.concept_id = HIV_Status.Status_Code 
    on HIV_Status.person_id = a.Id

	)as ab 
	group by ageGroup
