SELECT HEI_TOTALS_COLS_ROWS.AgeGroup
		, HEI_TOTALS_COLS_ROWS.Gender
		, HEI_TOTALS_COLS_ROWS.Total

FROM (

			(SELECT HEI_Status_Detailed.age_group AS 'AgeGroup'
					, HEI_Status_Detailed.Gender
						, IF(HEI_Status_Detailed.Id IS NULL, 0, SUM(IF(HEI_Status_Detailed.PMTCT = 'EID', 1, 0))) as 'Total'
						, HEI_Status_Detailed.sort_order

		FROM
		(SELECT Id, Patient_Identifier, Patient_Name, age_group, Age, Age_at_Test, Gender, Date_Sample_Taken, Test_Result, 'EID' AS 'PMTCT', sort_order
			FROM

		(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age_, Age, Gender, age_group, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Age_,
                                               concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								 
                                 -- First NAT Test at 6 weeks or First Contact section of the HEI form filled

								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4569 -- First Contact or 6 weeks form section
									AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- First NAT test observations inside the HIV Exposed Infant Register
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4569
								 )) AS HEIClients_Status
                                 having Age_ <= 12   



) AS HEI_Status_Detailed_

left outer join 

(Select person_id, concat(Age_at_Test, ' ', 'weeks') as Age_at_Test
FROM
(select o.person_id, value_numeric as Age_at_Test
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
				from obs where concept_id = 4569 -- First Contact or 6 weeks form section
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as 6weeks_test
			on 6weeks_test.person_id = o.person_id
			where o.concept_id = 4570 -- Age at test
			and o.obs_datetime = max_observation
            and o.voided = 0
            )Age_test
)test_age
on test_age.person_id = HEI_Status_Detailed_.Id

left outer join 

(select o.person_id, Date_Sample_Taken
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                , cast(value_datetime as date) as Date_Sample_Taken
				from obs where concept_id = 4575 -- Date sample taken
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as sample_
			on sample_.person_id = o.person_id
			where o.concept_id = 4569 -- First Contact or 6 weeks form section
			and o.obs_datetime = max_observation
            and o.voided = 0
            )sample_date
on sample_date.person_id = HEI_Status_Detailed_.Id

left outer join 

(select distinct o.person_id,
        case
           when value_coded = 1738 then "Positive"
           when value_coded = 1016 then "Negative"
           when value_coded = 4220 then "Indeterminate"
           else ""
       end AS Test_Result
from obs o
		inner join
			(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                from obs where concept_id = 4569 -- First Contact or 6 weeks form section
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as test_result
			on test_result.person_id = o.person_id
			where o.concept_id = 4578 -- HEI Test Result
			and o.obs_datetime = max_observation
            and o.voided = 0
            )results
on results.person_id = HEI_Status_Detailed_.Id
)HEI_Status_Detailed

			GROUP BY HEI_Status_Detailed.age_group, HEI_Status_Detailed.Gender
			ORDER BY HEI_Status_Detailed.sort_order)
			
			
	UNION ALL

			(SELECT 'Total' AS 'AgeGroup'
					, 'All' AS 'Gender'		
						, IF(HEI_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HEI_STATUS_DRVD_COLS.PMTCT = 'EID', 1, 0))) as 'Total'
						, 99 AS sort_order
			FROM 
			
			(SELECT Id, Patient_Identifier, Patient_Name, age_group, Age, Age_at_Test, Gender, Date_Sample_Taken, Test_Result, 'EID' AS 'PMTCT', sort_order
			
			FROM

		(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age_, Age, Gender, age_group, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Age_,
                                               concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								 
                                 -- First NAT Test at 6 weeks or First Contact section of the HEI form filled

								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4569 -- First Contact or 6 weeks form section
									AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- First NAT test observations inside the HIV Exposed Infant Register
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4569
								 )) AS HEIClients_Status
                                 having Age_ <= 12   



) AS HEI_Status_Detailed_

left outer join 

(Select person_id, concat(Age_at_Test, ' ', 'weeks') as Age_at_Test
FROM
(select o.person_id, value_numeric as Age_at_Test
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
				from obs where concept_id = 4569 -- First Contact or 6 weeks form section
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as 6weeks_test
			on 6weeks_test.person_id = o.person_id
			where o.concept_id = 4570 -- Age at test
			and o.obs_datetime = max_observation
            and o.voided = 0
            )Age_test
)test_age
on test_age.person_id = HEI_Status_Detailed_.Id

left outer join 

(select o.person_id, Date_Sample_Taken
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                , cast(value_datetime as date) as Date_Sample_Taken
				from obs where concept_id = 4575 -- Date sample taken
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as sample_
			on sample_.person_id = o.person_id
			where o.concept_id = 4569 -- First Contact or 6 weeks form section
			and o.obs_datetime = max_observation
            and o.voided = 0
            )sample_date
on sample_date.person_id = HEI_Status_Detailed_.Id

left outer join 

(select distinct o.person_id,
        case
           when value_coded = 1738 then "Positive"
           when value_coded = 1016 then "Negative"
           when value_coded = 4220 then "Indeterminate"
           else ""
       end AS Test_Result
from obs o
		inner join
			(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                from obs where concept_id = 4569 -- First Contact or 6 weeks form section
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as test_result
			on test_result.person_id = o.person_id
			where o.concept_id = 4578 -- HEI Test Result
			and o.obs_datetime = max_observation
            and o.voided = 0
            )results
on results.person_id = HEI_Status_Detailed_.Id
)AS HEI_STATUS_DRVD_COLS
		)
		
	) AS HEI_TOTALS_COLS_ROWS
ORDER BY HEI_TOTALS_COLS_ROWS.sort_order

