SELECT distinct Id, patientIdentifier, patientName, Age,age_group, Gender, diagnosis_type.TB_DIAGNOSIS, test_result, TB_Start_Date, TB_Treatment_Initiation, Key_Populations
 FROM (
(Select distinct Id, patientIdentifier , patientName, Age, age_group, Gender, "GeneXpert" AS "TB_DIAGNOSIS"
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					--  TB Clients diagnosed by GeneXpert
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3814 and o.value_coded = 3824
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)

UNION

(Select distinct Id, patientIdentifier , patientName, Age, age_group, Gender, "LPA" AS "TB_DIAGNOSIS"
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					--  TB Clients diagnosed by Line Probe Assay
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3814 and o.value_coded = 3825
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)

UNION

(Select distinct Id, patientIdentifier , patientName, Age, age_group, Gender, "Sputum Smear Microscopy" AS "TB_DIAGNOSIS"
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					--  TB Clients diagnosed by Sputum Smear Microscopy
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3815 and o.value_coded = 3819
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)

UNION

(Select distinct Id, patientIdentifier , patientName, Age, age_group, Gender, "Sputum_Culture" AS "TB_DIAGNOSIS"
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- TB Clients diagnosed by Sputum Culture
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3815 and o.value_coded = 1045
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)

UNION

(Select distinct Id, patientIdentifier , patientName, Age, age_group, Gender, "X-Ray" AS "TB_DIAGNOSIS"
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- TB Clients diagnosed by X-Ray
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3815 and o.value_coded = 1045
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)
)diagnosis_type

left outer join
-- TEST RESULTS
(select person_id, test_result
from
(
(
 -- Phenotypic Test Results
 select o.person_id,case 
 when o.value_coded = 1016 then "Negative"
 when o.value_coded = 3828 then "Scanty 1"
 when o.value_coded = 3829 then "Scanty 2"
 when o.value_coded = 3830 then "Scanty 3"
 when o.value_coded = 3831 then "Scanty 4"
 when o.value_coded = 3832 then "Scanty 5"
 when o.value_coded = 3833 then "Scanty 6"
 when o.value_coded = 3834 then "Scanty 7"
 when o.value_coded = 3835 then "Scanty 8"
 when o.value_coded = 3836 then "Scanty 9"
 when o.value_coded = 3837 then "Pos 1+"
 when o.value_coded = 3838 then "Pos 2+"
 when o.value_coded = 3839 then "Pos 3+"
else "N/A" 
end AS test_result
from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as latest_results
		 from obs oss
		 where oss.concept_id = 3840 and oss.voided=0
		 and oss.obs_datetime >= cast('#startDate#' as date)
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 3840
	and o.obs_datetime = max_observation
	and o.voided = 0	
	)

UNION

(
 -- GeneXpert Test Results
 select o.person_id,case
 when o.value_coded = 3816 then "MTB Detected,RS"
 when o.value_coded = 3817 then "MTB Detected,RR"
 when o.value_coded = 3818 then "MTB Detected,RSI"
 when o.value_coded = 3820 then "MTB not Detected"
else "N/A" 
end AS test_result
from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as latest_results
		 from obs oss
		 where oss.concept_id = 3787 and oss.voided=0
		 and oss.obs_datetime >= cast('#startDate#' as date)
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 3787
	and o.obs_datetime = max_observation
	and o.voided = 0	
	)

UNION

(
 -- LPA Test Results
 select o.person_id,case
 when o.value_coded = 1738 then "Positive"
 when o.value_coded = 1016 then "Negative"
 when o.value_coded = 3801 then "Contaminated"
else "N/A" 
end AS test_result
from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as latest_results
		 from obs oss
		 where oss.concept_id = 3805 and oss.voided=0
		 and oss.obs_datetime >= cast('#startDate#' as date)
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 3805
	and o.obs_datetime = max_observation
	and o.voided = 0	
	)
)test
)test_result
on test_result.person_id = diagnosis_type.Id

Left Outer Join
(
-- TB Treatment Start Date
	select o.person_id, CAST(start_date AS DATE) as TB_Start_Date
	from obs o
    inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as start_date
     from obs oss
     where oss.concept_id = 2237 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest
    on latest.person_id = o.person_id 
) as tb_start_date
on diagnosis_type.Id = tb_start_date.person_id

Left Outer Join
(
-- Died before treatment
	select o.person_id, "Died Before Treatment" as "TB_Treatment_Initiation"
	from obs o
	where o.concept_id = 3789 and o.value_coded = 3791
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id
) as died
on diagnosis_type.Id = died.person_id

Left Outer Join
(
-- High Risk Population
 select o.person_id,case
 when o.value_coded = 3669 then "Factory worker"
 when o.value_coded = 3667 then "Miner"
 when o.value_coded = 3670 then "Health Worker"
 when o.value_coded = 3777 then "Household member of current miner"
 when o.value_coded = 3778 then "Household member of ex miner"
 when o.value_coded = 3779 then "Prison Staff"
 when o.value_coded = 3671 then "Prisoner"
 when o.value_coded = 3668 then "Ex-miner"
 when o.value_coded = 4654 then "Public Transport"
 when o.value_coded = 4919 then "Contact of DRTB patient"
else "N/A" 
end AS Key_Populations
from obs o
where o.concept_id = 3776 and o.voided = 0
Group by o.person_id
) risk
on diagnosis_type.Id = risk.person_id