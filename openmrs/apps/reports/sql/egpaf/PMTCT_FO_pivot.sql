SELECT distinct HTS_TOTALS_COLS_ROWS.AgeGroup
		    , HTS_TOTALS_COLS_ROWS.Positive_Outcomes
	    	, HTS_TOTALS_COLS_ROWS.Negative_Outcomes
			, HTS_TOTALS_COLS_ROWS.Indeterminate_Outcomes

FROM (

			(SELECT HTS_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
					
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.Outcome_Type = 'Positive', 1, 0))) AS Positive_Outcomes
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.Outcome_Type = 'Negative', 1, 0))) AS Negative_Outcomes
							, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.Outcome_Type = 'Indeterminate', 1, 0))) AS Indeterminate_Outcomes
						, HTS_STATUS_DRVD_ROWS.sort_order
			FROM (

					
(SELECT distinct Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age , Gender, age_group, Outcome_Type, sort_order
							 
	FROM

			(select distinct patient.patient_id AS Id,
							patient_identifier.identifier AS patientIdentifier,
							concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
							person.gender AS Gender,
							observed_age_group.name AS age_group,
							observed_age_group.sort_order AS sort_order,
							case
							when o.value_coded = 1738 then "Positive"
							when o.value_coded = 1016 then "Negative"
							when o.value_coded = 4220 then "Indeterminate"
							else "N/A"
							end as Outcome_Type

			from obs o
					-- HIV EXPOSED INFANTS
						INNER JOIN patient ON o.person_id = patient.patient_id 
						AND o.concept_id = 4578
						AND o.person_id in (
							select os.person_id
							from obs os
							where os.concept_id = 4558
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)
						AND o.person_id in (
							select os.person_id 
							from obs os
							where os.concept_id = 4587 and os.value_numeric >= 18
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)
						AND patient.voided = 0 AND o.voided = 0
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
					WHERE observed_age_group.report_group_name = 'Modified_Ages'
			) AS HTSClients_HIV_STATUS
			Group by Id
	ORDER BY HTSClients_HIV_STATUS.Age)



			) AS HTS_STATUS_DRVD_ROWS

			GROUP BY HTS_STATUS_DRVD_ROWS.age_group, HTS_STATUS_DRVD_ROWS.Gender
			ORDER BY HTS_STATUS_DRVD_ROWS.sort_order
			)
			
			
	 UNION ALL

			(SELECT 'Total' AS 'AgeGroup'
					
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.Outcome_Type = 'Positive', 1, 0))) AS Positive_Outcomes
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.Outcome_Type = 'Negative', 1, 0))) AS Negative_Outcomes
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.Outcome_Type = 'Indeterminate', 1, 0))) AS Indeterminate_Outcomes
						, 99 AS sort_order
			FROM (

					
(SELECT distinct Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age , Gender, age_group, Outcome_Type,sort_order
							 
	FROM

			(select distinct patient.patient_id AS Id,
							patient_identifier.identifier AS patientIdentifier,
							concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
							person.gender AS Gender,
							observed_age_group.name AS age_group,
							observed_age_group.sort_order AS sort_order,
							case
							when o.value_coded = 1738 then "Positive"
							when o.value_coded = 1016 then "Negative"
							when o.value_coded = 4220 then "Indeterminate"
							else "N/A"
							end as Outcome_Type

			from obs o
					-- HIV EXPOSED INFANTS
						INNER JOIN patient ON o.person_id = patient.patient_id 
						AND o.concept_id = 4578
						AND o.person_id in (
							select os.person_id
							from obs os
							where os.concept_id = 4558
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)
						AND o.person_id in (
							select os.person_id 
							from obs os
							where os.concept_id = 4587 and os.value_numeric >= 18
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)
						AND patient.voided = 0 AND o.voided = 0
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
					WHERE observed_age_group.report_group_name = 'Modified_Ages'
			) AS HTSClients_HIV_STATUS
			Group by Id
	ORDER BY HTSClients_HIV_STATUS.Age)



			) AS HTS_STATUS_DRVD_COLS
		)
		
	) AS HTS_TOTALS_COLS_ROWS
ORDER BY HTS_TOTALS_COLS_ROWS.sort_order

