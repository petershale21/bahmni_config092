(SELECT DISTINCT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, 'TPT_Started' AS 'Program_Status'

FROM
        (
			SELECT distinct 
							p.identifier AS patientIdentifier,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age

					FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									INNER JOIN person ps ON ps.person_id = patient.patient_id AND ps.voided = 0
									INNER JOIN person_name pn ON ps.person_id = pn.person_id AND pn.preferred = 1
									INNER JOIN patient_identifier p ON p.patient_id = ps.person_id AND p.identifier_type = 3 AND p.preferred=1
									AND o.person_id in
									(				
										select distinct person_id from obs o
										where concept_id = 2227 and value_coded = 2146
										AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							            AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
										
								
									) 								
									AND o.voided = 0
									
			
		) AS Clients_started
ORDER BY 2)

UNION

(SELECT distinct patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, 'TPT_Completed' AS 'Program_Status'

FROM
        (
			(SELECT distinct 
							p.identifier AS patientIdentifier,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age
							
							FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									INNER JOIN person ps ON ps.person_id = patient.patient_id AND ps.voided = 0
									INNER JOIN person_name pn ON ps.person_id = pn.person_id AND pn.preferred = 1
									INNER JOIN patient_identifier p ON p.patient_id = ps.person_id AND p.identifier_type = 3 AND p.preferred=1
									AND o.person_id in
									(				
												
										select distinct os.person_id
										from obs os
										where os.concept_id = 4821 
										AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							      		AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
														
									)				
									AND o.voided = 0					
									)							
			
		) AS Clients_completed
ORDER BY 2)
