	SELECT distinct patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age

	FROM
			(
				SELECT distinct 
								p.identifier AS patientIdentifier,
								concat(pn.given_name, ' ', pn.family_name) AS patientName,
								floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age
								
								
				FROM obs o
				
										INNER JOIN patient_identifier p ON o.person_id = p.patient_id AND p.identifier_type = 3 AND p.preferred=1
										INNER JOIN person_name pn ON p.patient_id = pn.person_id
										INNER JOIN person ps on ps.person_id = p.patient_id
										AND o.person_id in
										(				
											select distinct person_id from obs o
											where concept_id = 2237 
											AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))

									
										) 								
										AND o.voided = 0
													
			) AS PatientIntake
	ORDER BY 2

