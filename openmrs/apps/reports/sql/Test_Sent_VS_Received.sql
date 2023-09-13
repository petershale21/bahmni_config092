Select Id, patientIdentifier as "Patient Identifier", ART_Number as "ART Number", patientName as "Patient Name",age_group, Age, Gender, date_collected as "Date Specimen Collected",Test, received,sort_order
From
(select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                p.identifier as ART_Number,
                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                o.date_created as date_collected,
                observed_age_group.name AS age_group,
                "TestDone" AS Test,
                observed_age_group.sort_order AS sort_order

            from orders o
            -- Viral Load Tests Sent
                    INNER JOIN patient ON o.patient_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                    AND o.concept_id = 5484
                    AND CAST(o.date_created AS DATE)>= CAST('#startDate#' AS DATE)
					AND CAST(o.date_created AS DATE) <= CAST('#endDate#' AS DATE)
                    LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                WHERE observed_age_group.report_group_name = 'Modified_Ages') as test
Left Outer Join
(
    select distinct o.person_id,
     case
		when o.concept_id = 5486 then "Received"
        else "Pending" 
		end AS received
    from obs o

) as received
on test.Id = received.person_id

