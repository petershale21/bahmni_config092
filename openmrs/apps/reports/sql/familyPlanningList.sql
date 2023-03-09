

SELECT distinct Patient_Identifier,Patient_Name,Age,age_group, Gender,
 FP_Visit,OnART,OnPreP,FP_Method as 'Family Planning Method Issued',LIGATION AS 'Bilateral Tubal Ligation',STD_DAYS_METHODS AS 'Standard Days Method',DUAL_PRO AS 'Dual Protection',IUCD_REMOVED as 'IUCD Removed',TB_SCREENING AS 'TB Screening',STI_SCREENING AS 'STI Screening'
FROM
( 

	 (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender,       
                             CASE
                                WHEN code = 2093 THEN 'New'
                                WHEN code = 4539 THEN 'Revisit'
                                WHEN code = 2303 THEN 'Restarted'
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
			
			)FP_VISITS 

			LEFT JOIN 
			(
				SELECT distinct o.person_id AS Id, 	  
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
								
			)on_art 
			ON FP_VISITS.Id = on_art.Id

			LEFT OUTER JOIN 
			(
				SELECT distinct o.person_id AS Id, 	  
						CASE WHEN o.concept_id = 5029 THEN 'Yes' 
						ELSE 'No'
						END AS 'OnPreP'

						from obs o
								-- FP attendacnce on PREP

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								
			)FP_PREP
			ON FP_VISITS.Id = FP_PREP.Id

			LEFT OUTER JOIN 
			(
				SELECT distinct o.person_id AS Id, 	  
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
						ELSE 'Method not selected'
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
								 order by o.value_coded desc
								
			)FP_METHOD
			ON FP_VISITS.Id = FP_METHOD.Id

			LEFT OUTER JOIN 
			(
				
				SELECT distinct o.person_id AS Id, 	  
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
								-- FP attendacnce FP LIGATION Protection
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 2481
								 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 order by o.value_coded desc
								
			)	BILATERAL_TUBAL_LIGATION
			ON FP_VISITS.Id = BILATERAL_TUBAL_LIGATION.Id

			LEFT OUTER JOIN 
			(
				
				SELECT distinct o.person_id AS Id, 	  
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
								 order by o.value_coded desc
								
			)	STANDARD_DAYS_METHOD
			ON FP_VISITS.Id = STANDARD_DAYS_METHOD.Id

			LEFT OUTER JOIN 
			(
				
				SELECT distinct o.person_id AS Id, 	  
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
								 AND o.concept_id = 4543   
								 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 order by o.value_coded desc
								
			)	DUAL_PROTECTION
			ON FP_VISITS.Id = DUAL_PROTECTION.Id

			LEFT OUTER JOIN 
			(
				
				SELECT distinct o.person_id AS Id, 	  
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
								 order by o.value_coded desc
								
			)IUC_REMOVED	
			ON FP_VISITS.Id = IUC_REMOVED.Id

			LEFT OUTER JOIN 
			(
				
				SELECT distinct o.person_id AS Id, 	  
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
								 order by o.value_coded desc
								
			)TB_SERVICE_PROVIDED			
			ON FP_VISITS.Id = TB_SERVICE_PROVIDED.Id

			LEFT OUTER JOIN 
			(
				
				SELECT distinct o.person_id AS Id, 	  
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
								 order by o.value_coded desc
								
			)STI_SERVICE_PROVIDED
			
			ON FP_VISITS.Id = STI_SERVICE_PROVIDED.Id

)