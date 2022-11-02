select distinct patientIdentifier,
				patientName,
				Age,
				ANC_visit,
				Trimester,
				Estimated_Date_Delivery,
				Gestational_Period,
				High_Risk_Pregnancy,
				Syphilis_Screening_Results,
				Syphilis_Treatment_Completed,
				Haemoglobin,
				HIV_Status_Known_Before_Visit,
				Final_HIV_Status,
				Subsequent_HIV_Test_Results,
				MUAC,
				Tuberculosis,
				Iron,
				Folate,
				Blood_Group
				
from obs o
inner join
(

SELECT ID, patientIdentifier , patientName, Age, ANC_visit, Trimester
FROM
(
-- FIRST ANC, 1ST TRIMESTER
select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						(select name from concept_name cn where cn.concept_id = 4659 and concept_name_type='FULLY_SPECIFIED') AS ANC_visit,
                        '1st_trimester' as 'Trimester'
from obs o
    -- First ANC Clients
     INNER JOIN patient ON o.person_id = patient.patient_id 
	    AND o.concept_id = 4658 and o.value_coded = 4659
	    AND patient.voided = 0 AND o.voided = 0
	    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

    -- 1st trimester
    AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
												)
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
    AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric < 13)
	WHERE CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE) 
)AS first_anc_1st_trimester


UNION

-- SUBSEQUENT, 1ST TRIMESTER
SELECT ID, patientIdentifier , patientName, Age, ANC_visit, Trimester
FROM
(
select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						(select name from concept_name cn where cn.concept_id = 4660 and concept_name_type='FULLY_SPECIFIED') AS ANC_visit,
                        '1st_trimester' as 'Trimester'
from obs o
    -- First ANC Clients
     INNER JOIN patient ON o.person_id = patient.patient_id 
	    AND o.concept_id = 4658 and o.value_coded = 4660
	    AND patient.voided = 0 AND o.voided = 0
	    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

    -- 1st trimester
    AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
												)
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
    AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric < 13)
	WHERE CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
)AS subsequent_1st_trimester


UNION
SELECT ID,patientIdentifier ,patientName, Age, ANC_visit, Trimester
FROM
(
-- FIRST ANC, 2ND TRIMESTER
select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						(select name from concept_name cn where cn.concept_id = 4659 and concept_name_type='FULLY_SPECIFIED') AS ANC_visit,
                        '2nd_trimester' as 'Trimester'
from obs o
    -- First ANC Clients
     INNER JOIN patient ON o.person_id = patient.patient_id 
	    AND o.concept_id = 4658 and o.value_coded = 4659
	    AND patient.voided = 0 AND o.voided = 0
	    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

    -- 2nd trimester
    AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
												)
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
    AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric >= 13 and value_numeric < 25)
	WHERE CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
)AS first_2nd_trimester


UNION

SELECT ID, patientIdentifier, patientName, Age, ANC_visit, Trimester
FROM
(
-- SUBSEQUENT, 2ND TRIMESTER

select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						(select name from concept_name cn where cn.concept_id = 4660 and concept_name_type='FULLY_SPECIFIED') AS ANC_visit,
                        '2nd_trimester' as 'Trimester'
from obs o
    -- First ANC Clients
     INNER JOIN patient ON o.person_id = patient.patient_id 
	    AND o.concept_id = 4658 and o.value_coded = 4660
	    AND patient.voided = 0 AND o.voided = 0
	    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

    -- 1st trimester
    AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
												)
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
    AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric >= 13 and value_numeric < 25)
	WHERE CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
) AS subsquent_2nd_trimester

    UNION

SELECT ID, patientIdentifier,patientName, Age, ANC_visit, Trimester
FROM
(
    -- FIRST ANC, 3RD TRIMESTER
select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						(select name from concept_name cn where cn.concept_id = 4659 and concept_name_type='FULLY_SPECIFIED') AS ANC_visit,
                        '3rd_trimester' as 'Trimester'
from obs o
    -- First ANC Clients
     INNER JOIN patient ON o.person_id = patient.patient_id 
	    AND o.concept_id = 4658 and o.value_coded = 4659
	    AND patient.voided = 0 AND o.voided = 0
	    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

    -- 3rd trimester
    AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
												)
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
    AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric > 25)
	WHERE CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
)AS first_3rd_trimester


UNION


SELECT ID, patientIdentifier,patientName, Age, ANC_visit, Trimester
FROM
(
-- SUBSEQUENT, 3RD TRIMESTER

select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						(select name from concept_name cn where cn.concept_id = 4660 and concept_name_type='FULLY_SPECIFIED') AS ANC_visit,
                        '3rd_trimester' as 'Trimester'
from obs o
    -- Subsequent ANC Clients
     INNER JOIN patient ON o.person_id = patient.patient_id 
	    AND o.concept_id = 4658 and o.value_coded = 4660
	    AND patient.voided = 0 AND o.voided = 0
	    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

    -- 3rd trimester
    AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
												)
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
    AND o.person_id in (select o.person_id from obs o where concept_id = 2423 and value_numeric > 25)
	WHERE CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE) 

)AS subsequent_3rd_trimester

UNION

SELECT ID, patientIdentifier,patientName, Age, ANC_visit, Trimester
FROM
(
-- FIRST ANC NO GESTATIONAL PERIOD
select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						(select name from concept_name cn where cn.concept_id = 4659 and concept_name_type='FULLY_SPECIFIED') AS ANC_visit,
                        'NULL' as 'Trimester'
from obs o
    -- First ANC Clients
     INNER JOIN patient ON o.person_id = patient.patient_id 
	    AND o.concept_id = 4658 and o.value_coded = 4659
	    AND patient.voided = 0 AND o.voided = 0
	    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

    -- no trimester
    AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
												)
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
    AND o.person_id not in (select o.person_id from obs o where concept_id = 2423)
	WHERE CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
)AS first_no_trimester


UNION

SELECT ID, patientIdentifier,patientName, Age, ANC_visit, Trimester
FROM
(
-- SUBSEQUENT, NO GESTATIONAL PERIOD

select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						(select name from concept_name cn where cn.concept_id = 4660 and concept_name_type='FULLY_SPECIFIED') AS ANC_visit,
                        'NULL' as 'Trimester'
from obs o
    -- Subsequent ANC Clients
     INNER JOIN patient ON o.person_id = patient.patient_id 
	    AND o.concept_id = 4658 and o.value_coded = 4660
	    AND patient.voided = 0 AND o.voided = 0
	    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

    -- no trimester
    AND o.person_Id in (select id
								FROM
								( 
									select distinct o.person_id AS Id,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

									from obs o
									INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3	
								) as a
												)
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
    AND o.person_id not in (select o.person_id from obs o where concept_id = 2423)
	WHERE CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
)AS subsquent_no_trimester
) AS ANC
ON o.person_id = ID

-- Gestational period
left outer join
	(
	select person_id, value_numeric as Gestational_Period
	from obs where concept_id = 2423 and voided = 0
	)current_gestation
	on ANC.Id = current_gestation.person_id

-- EDD
left outer join
	(
	select person_id,CAST(value_datetime AS DATE) as Estimated_Date_Delivery
	from obs where concept_id = 4627 and voided = 0
	)intake_date
	on ANC.Id = intake_date.person_id

-- High Risk Pregnancy
left outer join
	(
	select person_id, value_coded as Risk_Code
	from obs where concept_id = 4352 and voided = 0
	)High_Risk_Preg

	inner join
	(
		select concept_id, name AS High_Risk_Pregnancy
			from concept_name 
				where name in ('No Risk', 'Age less than 16 years', 'Age more than 40 years', 'History 3 or more consecutive spontaneous miscarriages',
								'Birth Weight< 2500g', 'Birth Weight > 4500g', 'Previous Hx of Hypertension/pre-eclampsia/eclampsia', 'Isoimmunization Rh(-)',
								'Renal Disease', 'Cardiac Disease', 'Diabetes', 'Known Substance Abuse', 'Pelvic Mass', 'Other Medical Problems', 
								'Previous Surgery on Reproductive Tract', 'Other Answer') 
	) concept_name
	on concept_name.concept_id = High_Risk_Preg.Risk_Code 

on High_Risk_Preg.person_id = ANC.Id

-- Syphilis_Screening_Results
left outer join
	(

		select distinct a.person_id, Syphilis_Results.value_coded,
				case 
				when Syphilis_Results.value_coded = 4306 then 'Reactive'
				when Syphilis_Results.value_coded = 4307 then 'Non Reactive'
				when Syphilis_Results.value_coded = 4308 then 'Not done'
				else 'NewResult' end as Syphilis_Screening_Results
	from obs a
	inner join 
		( SELECT person_id, value_coded from obs o
			where concept_id = 4305 and voided = 0
			and o.obs_datetime >= CAST('#startDate#' AS DATE)
    		and o.obs_datetime <= CAST('#endDate#'AS DATE)
		) Syphilis_Results

		ON a.person_id = Syphilis_Results.person_id
	

	) Syphilis_Screening_Res

on Syphilis_Screening_Res.person_id = ANC.Id

-- Syphilis Treatment Completed
left outer join
	(
	select person_id, value_coded as Treatment_Code
	from obs os
	where concept_id = 1732 and voided = 0
	and os.obs_datetime >= CAST('#startDate#' AS DATE)
    and os.obs_datetime <= CAST('#endDate#'AS DATE)
	)Syphilis_Treatment_Comp

	inner join
	(
		select concept_id, name AS Syphilis_Treatment_Completed
			from concept_name 
				where name in ('Yes','No','Not Applicable') 
	) treatment_concept
	on treatment_concept.concept_id = Syphilis_Treatment_Comp.Treatment_Code 

on Syphilis_Treatment_Comp.person_id = ANC.Id

-- ANEMIA HAEMOGLOBIN
left outer join
	(
	select person_id,value_numeric as Haemoglobin
	from obs o
	where concept_id = 3204 and voided = 0
	)Haemoglobin_Anemia
	on ANC.Id = Haemoglobin_Anemia.person_id
 
-- HIV Status Known Before Visit	
left outer join
	(
	select person_id, value_coded as Status_Code
	from obs os
	where concept_id = 4427 and voided = 0
	and os.obs_datetime >= CAST('#startDate#' AS DATE)
    and os.obs_datetime <= CAST('#endDate#'AS DATE)
	)HIV_Status

	inner join
	(
		select concept_id, name AS HIV_Status_Known_Before_Visit
			from concept_name 
				where name in ('Positive', 'Negative', 'Unknown') 
	) hiv_concept_name
	on hiv_concept_name.concept_id = HIV_Status.Status_Code 

on HIV_Status.person_id = ANC.Id

-- Final HIV Status	
left outer join
	(
	select person_id, value_coded as Final_Status_Code
	from obs os
	where concept_id = 2165 and voided = 0
	)F_HIV_Status

	inner join
	(
		select concept_id, name AS Final_HIV_Status
			from concept_name 
				where name in ('Positive', 'Negative') 
	) final_hiv_concept_name
	on final_hiv_concept_name.concept_id = F_HIV_Status.Final_Status_Code 

on F_HIV_Status.person_id = ANC.Id

-- Subsequent HIV Test Results

left outer join
	(
	select person_id, value_coded as Subsequent_Final_Status
	from obs os
	where concept_id = 4325 and voided = 0
	)Subsequent_HIV_Status

	inner join
	(
		select concept_id, name AS Subsequent_HIV_Test_Results
			from concept_name 
				where name in ('Positive', 'Negative', 'Declined', 'Not Applicable') 
	) subsequent_hiv_concept
	on subsequent_hiv_concept.concept_id = Subsequent_HIV_Status.Subsequent_Final_Status 

on Subsequent_HIV_Status.person_id = ANC.Id

-- MUAC
left outer join
	(
	select person_id, value_numeric as MUAC
	from obs where concept_id = 2086 and voided = 0
	)Muac
	on ANC.Id = Muac.person_id

-- TB Status

left outer join
	(
	select person_id, value_coded as TB_Status
	from obs os
	where concept_id = 3710 and voided = 0
	)TB_Status

	inner join
	(
		select concept_id, name AS Tuberculosis
			from concept_name 
				where name in ('No signs', 'Suspected / Probable', 'On TB treatment') 
	) tb_concept
	on tb_concept.concept_id = TB_Status.TB_Status 

on TB_Status.person_id = ANC.Id

-- Iron
left outer join
	(
	select person_id, value_coded as Iron_Status
	from obs os
	where concept_id = 4299 and voided = 0
	and os.obs_datetime >= CAST('#startDate#' AS DATE)
    and os.obs_datetime <= CAST('#endDate#'AS DATE)
	)Iron_Status

	inner join
	(
		select concept_id, name AS Iron
			from concept_name 
				where name in ('Prophylaxis', '	On Treatment', 'Not Dispensed') 
	) iron_concept
	on iron_concept.concept_id = Iron_Status.Iron_Status 

on Iron_Status.person_id = ANC.Id

-- Folate
left outer join
	(
	select person_id, value_coded as Folate_Status
	from obs os
	where concept_id = 4300 and voided = 0
	and os.obs_datetime >= CAST('#startDate#' AS DATE)
    and os.obs_datetime <= CAST('#endDate#'AS DATE)
	)Folate_Status

	inner join
	(
		select concept_id, name AS Folate
			from concept_name 
				where name in ('Prophylaxis', '	On Treatment', 'Not Dispensed') 
	) folate_concept
	on folate_concept.concept_id = Folate_Status.Folate_Status 

on Folate_Status.person_id = ANC.Id

-- Blood Group
left outer join
	(
	select person_id, value_coded as Blood_Group_Status
	from obs os
	where concept_id = 1179 and voided = 0
	and os.obs_datetime >= CAST('#startDate#' AS DATE)
    and os.obs_datetime <= CAST('#endDate#'AS DATE)
	)Blood_Group_Status

	inner join
	(
		select concept_id, name AS Blood_Group
			from concept_name 
				where name in ('Blood Group, A+', 'Blood Group, A-', '	Blood Group, B+', 'Blood Group, B-',
								 'Blood Group, O+', 'Blood Group, O-', 'Blood Group, AB+', 'Blood Group, AB-') 
	) blood_group_concept
	on blood_group_concept.concept_id = Blood_Group_Status.Blood_Group_Status 

on Blood_Group_Status.person_id = ANC.Id




