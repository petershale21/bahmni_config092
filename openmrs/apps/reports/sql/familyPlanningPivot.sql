
(
 		SELECT distinct DRVD_ROWS.FP_Visit as ' ===> FP Attendance'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 					
		
		FROM (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender,       
                             CASE
                                WHEN code = 2093 THEN 'New Acceptor (starting FP method)'
                                WHEN code = 4539 THEN 'Revisit (already on FP method)'
                                WHEN code = 2303 THEN 'Total Restart'
                             ELSE 'typeOfFpVisit'
                             END AS 'FP_Visit', sort_order
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,
                                               o.value_coded as 'code'

						from obs o
								-- FP Attendance 

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4538 and o.value_coded IN (2093,4539,2303)
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) AS new_fp
		    ORDER BY new_fp.sort_order desc
			
			)DRVD_ROWS 
			GROUP BY DRVD_ROWS.FP_Visit
			ORDER BY DRVD_ROWS.FP_Visit desc
					
)

UNION ALL 
(	SELECT '==>   On ART','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)
                                               
UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.OnART as 'On ART'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, OnART
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,       
                            	  				CASE WHEN o.concept_id = 2403 THEN 'Yes' 
												ELSE 'No'
												END AS 'OnART'
                                                
						from obs o
								-- FP Attendance on ART 

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 
								 AND patient.voided = 0 AND o.voided = 0 
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) prep
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.OnART
				ORDER BY DRVD_ROWS.OnART desc
)


UNION ALL 
(	SELECT '==>   FP Issued method','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)
                                               
UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.FP_Method as 'Family Planning Method Issued'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier",FP_Method, patientName AS "Patient_Name", Age, age_group, Gender
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,       
                            	  			CASE 
												WHEN o.value_coded = 5205 THEN 'Progestrone only pill' 
												WHEN o.value_coded = 5206 THEN 'Combined oral contraceptive' 
												WHEN o.value_coded = 5207 THEN 'Depo medroxy progestrone acetate subcutatneous (DMPA-SC)' 
												WHEN o.value_coded = 5208 THEN 'Depo medroxy progestrone acetate intramusc' 
												WHEN o.value_coded = 5209 THEN 'Noristrate (NTE)' 
												WHEN o.value_coded = 2314 THEN 'Implant' 
												WHEN o.value_coded = 4551 THEN 'Jadelle' 
												WHEN o.value_coded = 5212 THEN 'Norplant' 
												WHEN o.value_coded = 4441 THEN 'Lactational Amenorrhea Method' 
												WHEN o.value_coded = 4552 THEN 'Copper T380A' 
												WHEN o.value_coded = 5214 THEN 'Intra Uterine Contraceptive Device(IUCD)' 
												WHEN o.value_coded = 4440 THEN 'Bilateral Tubal Ligation (BTL)' 
												WHEN o.value_coded = 2497 THEN 'Vasectomy' 
												WHEN o.value_coded = 4229 THEN 'Male Condoms' 
												WHEN o.value_coded = 4230 THEN 'Female Condoms' 
												WHEN o.value_coded = 4553 THEN 'Standard Days Method' 
												WHEN o.value_coded = 5215 THEN 'Emegency Pill' 
												WHEN o.value_coded = 1154 THEN 'None' 
											ELSE 'None'
											END AS 'FP_Method'
                                                
						from obs o
								-- FP attendacnce FP Method provided

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2481 								 
								 AND patient.voided = 0 AND o.voided = 0 
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) FP_Method
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.FP_Method
				ORDER BY DRVD_ROWS.FP_Method desc
)

UNION ALL 
(	SELECT '==>   Lactational','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)
                                               
UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.LIGATION as 'Lactational Amenorrhea Method'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier",LIGATION, patientName AS "Patient_Name", Age, age_group, Gender
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,       
                            	  				CASE 						
													WHEN o.value_coded = 5205 THEN 'No' 
													WHEN o.value_coded = 5206 THEN 'No' 
													WHEN o.value_coded = 5207 THEN 'No' 
													WHEN o.value_coded = 5208 THEN 'No' 
													WHEN o.value_coded = 5209 THEN 'No' 
													WHEN o.value_coded = 2314 THEN 'No' 
													WHEN o.value_coded = 4551 THEN 'No' 
													WHEN o.value_coded = 5212 THEN 'No' 
													WHEN o.value_coded = 4441 THEN 'No' 
													WHEN o.value_coded = 4552 THEN 'No' 
													WHEN o.value_coded = 5214 THEN 'No' 
													WHEN o.value_coded = 4440 THEN 'Yes' 
													WHEN o.value_coded = 2497 THEN 'No' 
													WHEN o.value_coded = 4229 THEN 'No' 
													WHEN o.value_coded = 4230 THEN 'No' 
													WHEN o.value_coded = 4553 THEN 'No' 
													WHEN o.value_coded = 5215 THEN 'No' 
													WHEN o.value_coded = 1154 THEN 'No' 	
																																
												ELSE 'No'
												END AS 'LIGATION'
													
						from obs o
								-- FP attendacnce FP Method provided 

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2481 								 
								 AND patient.voided = 0 AND o.voided = 0 
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) LIGATIONn
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.LIGATION
				ORDER BY DRVD_ROWS.LIGATION desc
)
UNION ALL 
(	SELECT '==>   Standard Days Method','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)
                                               
UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.STD_DAYS_METHODS as 'Family Planning Method Issued'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier",STD_DAYS_METHODS, patientName AS "Patient_Name", Age, age_group, Gender
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,       
                            	  				CASE 						
													WHEN o.value_coded = 5205 THEN 'No' 
													WHEN o.value_coded = 5206 THEN 'No' 
													WHEN o.value_coded = 5207 THEN 'No' 
													WHEN o.value_coded = 5208 THEN 'No' 
													WHEN o.value_coded = 5209 THEN 'No' 
													WHEN o.value_coded = 2314 THEN 'No' 
													WHEN o.value_coded = 4551 THEN 'No' 
													WHEN o.value_coded = 5212 THEN 'No' 
													WHEN o.value_coded = 4441 THEN 'No' 
													WHEN o.value_coded = 4552 THEN 'No' 
													WHEN o.value_coded = 5214 THEN 'No' 
													WHEN o.value_coded = 4440 THEN 'No' 
													WHEN o.value_coded = 2497 THEN 'No' 
													WHEN o.value_coded = 4229 THEN 'No' 
													WHEN o.value_coded = 4230 THEN 'No' 
													WHEN o.value_coded = 4553 THEN 'Yes' 
													WHEN o.value_coded = 5215 THEN 'No' 
													WHEN o.value_coded = 1154 THEN 'No' 	
																															
												ELSE 'No'
												END AS 'STD_DAYS_METHODS'	
						from obs o
								-- FP attendacnce FP Dual Protection
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2481
								  								 
								 AND patient.voided = 0 AND o.voided = 0 
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) LIGATIONn
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.STD_DAYS_METHODS
				ORDER BY DRVD_ROWS.STD_DAYS_METHODS desc
)
UNION ALL
(	SELECT '==>   Standard Days Method','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)
                                               
UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.DUAL_PRO as 'STD'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier",DUAL_PRO, patientName AS "Patient_Name", Age, age_group, Gender
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,       
                            	  			CASE 						
							WHEN o.value_coded = 5186 THEN 'Yes'																				
							WHEN o.value_coded = 4438 THEN 'No'																				
							WHEN o.value_coded = 2136 THEN 'No'																				
							WHEN o.value_coded = 913 THEN 'No'																				
							WHEN o.value_coded = 1087 THEN 'No'																				
																									
						ELSE 'No'
						END AS 'DUAL_PRO'
					from obs o
								-- FP attendacnce FP Dual Protection
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2481
								  								 
								 AND patient.voided = 0 AND o.voided = 0 
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) LIGATIONn
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.DUAL_PRO
				ORDER BY DRVD_ROWS.DUAL_PRO desc
)
UNION ALL
(	SELECT '==>   UICD Removed','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)
                                               
UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.IUCD_REMOVED
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier",IUCD_REMOVED, patientName AS "Patient_Name", Age, age_group, Gender
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,       
												CASE 
												    WHEN o.value_coded = 1 THEN 'Yes'
												    WHEN o.value_coded = 2 THEN 'No' 
																										
												ELSE 'iucd_removd not done'
												END AS 'IUCD_REMOVED'

									
					from obs o
								-- FP attendacnce IUCD Removed
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4546   
								  								 
								 AND patient.voided = 0 AND o.voided = 0 
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) LIGATIONn
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.IUCD_REMOVED
				ORDER BY DRVD_ROWS.IUCD_REMOVED desc
)

UNION ALL
(	SELECT '==>   TB Screening','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)
                                               
UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.TB_SCREENING
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier",TB_SCREENING, patientName AS "Patient_Name", Age, age_group, Gender
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,       
												CASE 
						
													WHEN o.value_coded = 3709 THEN 'No Sign'
													WHEN o.value_coded = 1876 THEN 'Susceptive' 
													WHEN o.value_coded = 3639 THEN 'On Treatment'
													WHEN o.value_coded = 4332 THEN 'History'
																										
												ELSE 'TBScreening not done'
												END AS 'TB_SCREENING'
									
					from obs o
								-- FP attendacnce FP service TB Screening
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4447  
								    
								  								 
								 AND patient.voided = 0 AND o.voided = 0 
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) LIGATIONn
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.TB_SCREENING
				ORDER BY DRVD_ROWS.TB_SCREENING desc
)
UNION ALL
(	SELECT '==>   STI Screening','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)
                                               
UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.STI_SCREENING
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier",STI_SCREENING, patientName AS "Patient_Name", Age, age_group, Gender
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,       
												CASE 						  
													WHEN o.value_coded = 4306 THEN 'Reactive'
													WHEN o.value_coded = 4307 THEN 'Non Reactive' 
													WHEN o.value_coded = 4308 THEN 'Not done'
																										
												ELSE 'TBScreening not done'
												END AS 'STI_SCREENING'
									
					from obs o
								-- FP attendacnce FP service STI SCREENING
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4443
								  								 
								 AND patient.voided = 0 AND o.voided = 0 
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) LIGATIONn
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.STI_SCREENING
				ORDER BY DRVD_ROWS.STI_SCREENING desc
)