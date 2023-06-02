SELECT distinct ID, patientIdentifier, patientName, Age, Visit_type, Trimester, Estimated_Date_Delivery, High_Risk_Pregnancy, Syphilis_Screening_Results,
		Syphilis_Treatment_Completed, Haemoglobin, HIV_Status_Known_Before_Visit, Final_HIV_Status, Subsequent_HIV_Test_Results , MUAC, TB_Status,
		Iron, Folate, Blood_Group

FROM
(
select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
from obs o
    -- ANC Clients
     INNER JOIN patient ON o.person_id = patient.patient_id
		AND o.person_id in
			(
				select latest_consultation.person_id
                from
				(
					select B.person_id, B.obs_group_id, B.obs_datetime
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 4663
									and obs_datetime >= cast('#startDate#' as date)
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 4658
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id

				) AS latest_consultation
				
			) 
	    AND patient.voided = 0 AND o.voided = 0
    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	WHERE CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
	AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE) 
)AS ANC_Clients

left outer join 

(
	-- Visit type (First visit or subsequent visit)
 select o.person_id,case
 when o.value_coded = 4659 then "First Visit"
 when o.value_coded = 4660 then "Subsequent Visit"
else "N/A"
end AS Visit_type
from obs o
where o.concept_id = 4658 and o.voided = 0
and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE) 
Group by o.person_id
) VisitType
on ANC_Clients.Id = VisitType.person_id

left outer join 

(
	-- Trimester for First visit
 select o.person_id,case
 when o.value_numeric < 12 then "1st Trimester"
 when o.value_numeric > 11 
 and o.value_numeric < 25 then "2nd Trimetser"
 when o.value_numeric > 24 then "3rd Trimester"
else "N/A"
end AS Trimester
from obs o
where o.concept_id = 2423 and o.voided = 0
and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
Group by o.person_id
) Gestational_Period
on ANC_Clients.Id = Gestational_Period.person_id

-- EDD
left outer join
	(
	select person_id,CAST(value_datetime AS DATE) as Estimated_Date_Delivery
	from obs where concept_id = 4627 and voided = 0
	)edd_date
	on ANC_Clients.Id = edd_date.person_id

left outer join

	(
	-- Syphilis Treatment Completed
		select o.person_id,case
		when o.value_coded = 4353 then "No Risk"
		when o.value_coded = 4354 then "Age less than 16 years"
		when o.value_coded = 4355 then "Age more than 40 years"
		when o.value_coded = 4356 then "Previous SB or NND"
		when o.value_coded = 4357 then "History 3 or more consecutive spontaneous miscarriages"
		when o.value_coded = 4358 then "Birth Weight< 2500g"
		when o.value_coded = 4359 then "Birth Weight > 4500g"
		when o.value_coded = 4360 then "Previous Hx of Hypertension/pre-eclampsia/eclampsia"
		when o.value_coded = 4361 then "Isoimmunization Rh(-)"
		when o.value_coded = 1050 then "Renal Disease"
		when o.value_coded = 4362 then "Cardiac Disease"
		when o.value_coded = 1048 then "Diabetes"
		when o.value_coded = 4363 then "Known Substance Abuse"
		when o.value_coded = 4364 then "Pelvic Mass"
		when o.value_coded = 4365 then "Other Medical Problems"
		when o.value_coded = 4366 then "Previous Surgery on Reproductive Tract"
		when o.value_coded = 1033 then "Other Answer"
		else "N/A"
		end AS High_Risk_Pregnancy
		from obs o
		where o.concept_id = 4352 and o.voided = 0
		and o.obs_datetime >= CAST('#startDate#' AS DATE)
		and o.obs_datetime <= CAST('#endDate#'AS DATE)
		Group by o.person_id
		) High_Risk_Preg
		on ANC_Clients.Id = High_Risk_Preg.person_id

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

on Syphilis_Screening_Res.person_id = ANC_Clients.Id

left outer join

	(
	-- Syphilis Treatment Completed
		select o.person_id,case
		when o.value_coded = 2146 then "Yes"
		when o.value_coded = 2147 then "No"
		when o.value_coded = 1975 then "Not applicable"
		else "N/A"
		end AS Syphilis_Treatment_Completed
		from obs o
		where o.concept_id = 1732 and o.voided = 0
		and o.obs_datetime >= CAST('#startDate#' AS DATE)
		and o.obs_datetime <= CAST('#endDate#'AS DATE)
		Group by o.person_id
		) Syphilis_Treatment_Comp
		on ANC_Clients.Id = Syphilis_Treatment_Comp.person_id

-- ANEMIA HAEMOGLOBIN
left outer join
	(
	select person_id,value_numeric as Haemoglobin
	from obs o
	where concept_id = 3204 and voided = 0
	)Haemoglobin_Anemia
	on ANC_Clients.Id = Haemoglobin_Anemia.person_id
 
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

on HIV_Status.person_id = ANC_Clients.Id

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

on F_HIV_Status.person_id = ANC_Clients.Id

-- Subsequent HIV Test Results

left outer join

	(
	-- Syphilis Treatment Completed
		select o.person_id,case
		when o.value_coded = 1738 then "Positive"
		when o.value_coded = 1016 then "Negative"
        when o.value_coded = 4321 then "Decline"
		when o.value_coded = 1975 then "Not applicable"
		else "N/A"
		end AS Subsequent_HIV_Test_Results
		from obs o
		where o.concept_id = 4325 and o.voided = 0
		and o.obs_datetime >= CAST('#startDate#' AS DATE)
		and o.obs_datetime <= CAST('#endDate#'AS DATE)
		Group by o.person_id
		) Subsequent_HIV_Status
		on ANC_Clients.Id = Subsequent_HIV_Status.person_id

-- MUAC
left outer join
	(
	select person_id, value_numeric as MUAC
	from obs where concept_id = 2086 and voided = 0
	)Muac
	on ANC_Clients.Id = Muac.person_id

-- TB Status

left outer join
	(
	-- TB Status
		select o.person_id,case
		when o.value_coded = 3709 then "No signs"
		when o.value_coded = 1876 then "Suspected"
		when o.value_coded = 3639 then "On TB treatment"
		else "N/A"
		end AS TB_Status
		from obs o
		where o.concept_id = 3710 and o.voided = 0
		Group by o.person_id
		) TBStatus
		on ANC_Clients.Id = TBStatus.person_id

left outer join 
	(
	-- Iron
		select o.person_id,case
		when o.value_coded = 4668 then "Prophylaxis"
		when o.value_coded = 1067 then "On Treatment"
		when o.value_coded = 4298 then "Not Given"
		else "N/A"
		end AS Iron
		from obs o
		where o.concept_id = 4299 and o.voided = 0
		Group by o.person_id
		) IronStatus
		on ANC_Clients.Id = IronStatus.person_id

left outer join 
	(
	-- Folate
		select o.person_id,case
		when o.value_coded = 4668 then "Prophylaxis"
		when o.value_coded = 1067 then "On Treatment"
		when o.value_coded = 4298 then "Not Given"
		else "N/A"
		end AS Folate
		from obs o
		where o.concept_id = 4300 and o.voided = 0
		and o.obs_datetime >= CAST('#startDate#' AS DATE)
    	and o.obs_datetime <= CAST('#endDate#'AS DATE)
		Group by o.person_id
		) Folate_Status
		on ANC_Clients.Id = Folate_Status.person_id

left outer join 
	(
	-- Blood Group
		select o.person_id,case
		when o.value_coded = 4309 then "Blood Group, A+"
		when o.value_coded = 4310 then "Blood Group, A-"
		when o.value_coded = 4311 then "Blood Group, B+"
		when o.value_coded = 4312 then "Blood Group, B-"
		when o.value_coded = 4313 then "Blood Group, O+"
		when o.value_coded = 4314 then "Blood Group, O-"
		when o.value_coded = 4315 then "Blood Group, AB+"
		when o.value_coded = 4316 then "Blood Group, AB-"
		else "N/A"
		end AS Blood_Group
		from obs o
		where o.concept_id = 1179 and o.voided = 0
		and o.obs_datetime >= CAST('#startDate#' AS DATE)
    	and o.obs_datetime <= CAST('#endDate#'AS DATE)
		Group by o.person_id
		) Blood_Group_Status
		on ANC_Clients.Id = Blood_Group_Status.person_id
