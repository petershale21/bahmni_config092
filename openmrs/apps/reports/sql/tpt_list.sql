(SELECT DISTINCT patientIdentifier AS "Patient Identifier", ART_number, File_number, patientName AS "Patient Name", Age, 'TPT_Started' AS 'Program_Status'

FROM
        (
			SELECT distinct 
							p.identifier AS patientIdentifier,
							patient_identifier.identifier as ART_Number,
							pi.identifier as File_Number,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age

					FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									AND o.person_id in
										(				
											SELECT DISTINCT person_id FROM obs o
											WHERE concept_id = 2227 AND value_coded = 2146
											AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
										) 								
									AND o.voided = 0
									INNER JOIN person ps ON ps.person_id = patient.patient_id AND ps.voided = 0
									INNER JOIN person_name pn ON ps.person_id = pn.person_id AND pn.preferred = 1
									INNER JOIN patient_identifier p ON p.patient_id = ps.person_id AND p.identifier_type = 3 AND p.preferred=1
									LEFT OUTER JOIN patient_identifier ON patient_identifier.patient_id = ps.person_id AND patient_identifier.identifier_type = 5
									LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = ps.person_id AND pi.identifier_type = 11
									
									
			
		) AS Clients_started
ORDER BY 2)

UNION

(SELECT distinct patientIdentifier AS "Patient Identifier", ART_number, File_number, patientName AS "Patient Name", Age, 'TPT_Completed' AS 'Program_Status'

FROM
        (
			(SELECT distinct 
							p.identifier AS patientIdentifier,
							patient_identifier.identifier as ART_Number,
							pi.identifier as File_Number,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age
							
							FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									AND o.person_id in
									(				
												
										select distinct os.person_id
										from obs os
										where os.concept_id = 4821 
										AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
										AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
														
									)	
									AND o.voided = 0
									INNER JOIN person ps ON ps.person_id = patient.patient_id AND ps.voided = 0
									INNER JOIN person_name pn ON ps.person_id = pn.person_id AND pn.preferred = 1
									INNER JOIN patient_identifier p ON p.patient_id = ps.person_id AND p.identifier_type = 3 AND p.preferred=1
									LEFT OUTER JOIN patient_identifier ON patient_identifier.patient_id = ps.person_id AND patient_identifier.identifier_type = 5
									LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = ps.person_id AND pi.identifier_type = 11
												
														
									)							
			
		) AS Clients_completed
ORDER BY 2)
