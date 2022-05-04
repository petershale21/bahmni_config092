
Select Distinct Patient_Identifier, Patient_Name,Age, Gender, age_group,HIV_Testing_Initiation, HIV_Status, Distribution_Date, IFNULL(Kits_Distributed,1) AS "Distributed Kits", IFNULL(Kits_Returned,0) AS "Returned Kits"
from(
SELECT Id,Patient_Identifier, Patient_Name, Age, Gender, age_group, HIV_Testing_Initiation  , HIV_Status
FROM (
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Self-test' AS 'HIV_Testing_Initiation'
                          , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   observed_age_group.sort_order AS sort_order
						from obs o
								-- HTS SELF TEST STRATEGY
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4845 and value_coded = 4822
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE)) 
								 
								 -- HAS HIV POSITIVE RESULTS 
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4844 and os.value_coded = 1738
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 ) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
		
UNION
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Self-test' AS 'HIV_Testing_Initiation'
				, HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   observed_age_group.sort_order AS sort_order
						from obs o
								-- HTS SELF TEST STRATEGY
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4845 and value_coded = 4822
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- HAS HIV NEGATIVE RESULTS 
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4844 and os.value_coded = 1016
									AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 ) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
		
UNION
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Self-test' AS 'HIV_Testing_Initiation'
				 , HIV_Status, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   (select name from concept_name cn where cn.concept_id = 2148 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   observed_age_group.sort_order AS sort_order
						from obs o
								-- HTS SELF TEST STRATEGY
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4845 and value_coded = 4822
								 AND patient.voided = 0 AND o.voided = 0
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								 
								 -- HAS HIV UNKNOWN RESULTS 
								    AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4844 and os.value_coded = 2148
									AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								    AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND patient.voided = 0 AND o.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 ) AS HTSClients_HIV_Status
		ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
		
) AS HTS_Status_Detailed
Group by Id
ORDER BY HTS_Status_Detailed.HIV_Testing_Initiation
			, HTS_Status_Detailed.sort_order) AS SelfTest

-- Number of Distributed Kits	
Left outer join
(
	select o.person_id as Id, (count(o.value_coded) + 1) as Kits_Distributed
             from obs o
                INNER JOIN patient ON o.person_id = patient.patient_id 
                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                
                AND o.voided=0
				where o.concept_id = 4836  and o.value_coded in (4837, 4838, 4839)
				AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
				AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
				Group by o.person_id
 ) as num_distributed
 on SelfTest.Id = num_distributed.Id

 -- Number of kits returned

Left outer join
(
	select o.person_id as Id, count(value_coded) as Kits_Returned
        from obs o
    INNER JOIN patient ON o.person_id = patient.patient_id 
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                
    AND o.voided=0
    AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
    AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
								                
    where concept_id in (4844) and value_coded not in (2148)
	Group by o.person_id
) as num_returned
on SelfTest.Id = num_returned.Id

-- DISTRIBUTION DATE
left outer join
	(select o.person_id,CAST(latest_distribution_date AS DATE) as Distribution_Date
	from obs o 
	inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as latest_distribution_date
     from obs oss
     where oss.concept_id = 4824 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest 
  on latest.person_id = o.person_id
  where concept_id = 4824
  and  o.obs_datetime = max_observation 
  ) as distibutedDate
	on SelfTest.Id = distibutedDate.person_id