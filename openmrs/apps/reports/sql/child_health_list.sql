Select distinct patientIdentifier as Patient_Identifier , patientName, Months, Gender, Base_Dose, 1st_Dose, 2nd_Dose, 3rd_Dose, Fully_Immunized, Measles_1stDose, Measles_2nd_Dose, Dt_1stDose
From
(
	select distinct patient.patient_id AS Id,
			patient_identifier.identifier AS patientIdentifier,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/12) AS Months,
			person.gender AS Gender
	from obs o
					--  Children
		INNER JOIN patient ON o.person_id = patient.patient_id
		AND o.concept_id = 4285
		AND patient.voided = 0 AND o.voided = 0
		AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1	AND o.voided=0
	Group by Id
	having Months < 56

) As Child

left outer join 

(
	-- Base Dose
 select o.person_id,case
 when o.value_coded = 4453 then "BCG"
 when o.value_coded = 4454 then "Polio(OPV)"
else "N/A"
end AS Base_Dose
from obs o
where o.concept_id = 4452 and o.voided = 0
Group by o.person_id
) BaseDose
on Child.Id = BaseDose.person_id


 -- 1st Dose
left outer join
	(
		select person_id, value_coded as 1st_Code, CAST(obs_datetime AS Date) as feeding_obs_date
		from obs 
		where concept_id = 4455 and voided = 0
	) As 1stDose
	
	inner join
	(
		select concept_id, name AS 1st_Dose
			from concept_name
				where name in ('Polio(OPV)', 'Pentavalent', 'Rotavirus(RV)', 'Pneumococal(PCV)') 
	) 1st_Dose_Concepts
	on 1st_Dose_Concepts.concept_id = 1stDose.1st_Code
	on 1stDose.person_id = Child.Id

 -- 2nd Dose
left outer join
	(
		select person_id, value_coded as 2nd_Code, CAST(obs_datetime AS Date) as feeding_obs_date
		from obs 
		where concept_id = 4459 and voided = 0
	) As 2nd_Dose
	
	inner join
	(
		select concept_id, name AS 2nd_Dose
			from concept_name 
				where name in ('Polio(OPV)', 'Pentavalent', 'Rotavirus(RV)', 'Pneumococal(PCV)') 
	) 2nd_Dose_Concepts
	on 2nd_Dose_Concepts.concept_id = 2nd_Dose.2nd_Code
	on 2nd_Dose.person_id = Child.Id

 -- 3rd Dose
left outer join
	(
		select person_id, value_coded as 3rd_Code, CAST(obs_datetime AS Date) as feeding_obs_date
		from obs 
		where concept_id = 4460 and voided = 0
	) As 3rd_Dose
	
	inner join
	(
		select concept_id, name AS 3rd_Dose
			from concept_name 
				where name in ('Polio(OPV)', 'Pentavalent', 'Rotavirus(RV)', 'Pneumococal(PCV)') 
	) 3rd_Dose_Concepts
	on 3rd_Dose_Concepts.concept_id = 3rd_Dose.3rd_Code
	on 3rd_Dose.person_id = Child.Id

left outer join 
(
	-- fully immunized
 select o.person_id,case
 when o.value_coded = 1 then "Yes"
 when o.value_coded = 2 then "No"
else "N/A"
end AS Fully_Immunized
from obs o
where o.concept_id = 4462 and o.voided = 0
Group by o.person_id
) fullyImmunized
on Child.Id = fullyImmunized.person_id

left outer join 
(
	-- Measles 1st Dose
 select o.person_id,case
 when o.value_coded = 1 then "Yes"
 when o.value_coded = 2 then "No"
else "N/A"
end AS Measles_1stDose
from obs o
where o.concept_id = 4461 and o.voided = 0
Group by o.person_id
) Measles1stDose
on Child.Id = Measles1stDose.person_id

left outer join 
(
	-- Measles 2nd Dose
 select o.person_id,case
 when o.value_coded = 4483 then "Measles 2nd Dose"
else "N/A"
end AS Measles_2nd_Dose
from obs o
where o.concept_id = 4487 and o.voided = 0
Group by o.person_id
) Measles2ndDose
on Child.Id = Measles2ndDose.person_id

left outer join 
(
	-- Dt 1st Dose
 select o.person_id,case
 when o.value_coded = 4484 then "DT Booster"
else "N/A"
end AS Dt_1stDose
from obs o
where o.concept_id = 4487 and o.voided = 0
Group by o.person_id
) Dt1stDose
on Child.Id = Dt1stDose.person_id
