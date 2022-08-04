SELECT distinct patientIdentifier AS "Patient Identifier", ART_Number AS "ART Number", patientName AS "Patient Name", age_group AS "Age Group", Age, Gender, location_name AS "Location"

FROM
        (
			SELECT distinct 
							patient_identifier.identifier AS patientIdentifier,
							p.identifier AS ART_Number,
							concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
							observed_age_group.name AS age_group,
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
							person.gender AS Gender,
							l.name as location_name
							
			FROM obs o
								INNER JOIN patient ON o.person_id = patient.patient_id
								INNER JOIN patient_identifier p ON o.person_id = p.patient_id 
								INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								JOIN location l on o.location_id = l.location_id and l.retired=0
								INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   		WHERE observed_age_group.report_group_name = 'Modified_Ages'
								AND o.person_id not in
								(				
									select person_id from obs where concept_id = 2249
								)								
									
								AND p.identifier_type = 5 
								AND o.voided = 0
			
		) AS Patient_MissedAppointments

ORDER BY 2;

