SELECT distinct patientIdentifier
               ,ART_number
               ,patientName
               ,Gender
               ,Age
               ,Program_Status
               ,HIV_Status
               ,WHO_Staging
               ,VL_result
               ,Pregnancy_Status

FROM    
((SELECT DISTINCT Id, patientIdentifier, ART_number, patientName,Gender, Age, 'TPT_Started' AS 'Program_Status'

FROM
        (
			SELECT distinct 
							patient.patient_Id as Id,
                            p.identifier AS patientIdentifier,
							patient_identifier.identifier as ART_Number,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
                            ps.gender AS Gender,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age

					FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									AND o.person_id in
										(				
											SELECT DISTINCT person_id FROM obs o
                                            -- Started IPT
											WHERE concept_id = 2227 AND value_coded = 2146
                                            and o.voided = 0
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

(SELECT distinct Id,patientIdentifier, ART_number, patientName, Gender, Age, 'TPT_Completed' AS 'Program_Status'

FROM
        (
			(SELECT distinct 
                            patient.patient_Id as Id,
							p.identifier AS patientIdentifier,
							patient_identifier.identifier as ART_Number,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
                            ps.gender AS Gender,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age
							
							FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									AND o.person_id in
									(				
												
										select distinct os.person_id
										from obs os
                                        -- IPT Completed
										where os.concept_id = 4821 
                                        and os.voided = 0
										AND CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
										AND CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
														
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
)tpt_uptake

left outer JOIN

(select
       o.person_id,
       case
           when value_coded = 2167 then "Stage I"
           when value_coded = 2168 then "Stage II"
           when value_coded = 2169 then "Stage III"
           when value_coded = 2170 then "Stage IV"
           else ""
       end AS WHO_Staging
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as staging
		 from obs oss
         -- WHO Staging
		 where oss.concept_id = 2224 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 2224
	and  o.obs_datetime = max_observation
	) clinical_staging
ON tpt_uptake.Id = clinical_staging.person_id

left outer JOIN

-- Viral Load Results
(SELECT distinct person_id, VL_result
From
((select o.person_id, max_observation, "Undetectable" as "VL_result"
	from obs o
	inner join
		(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
			from obs where concept_id = 4273
			and cast(obs_datetime as date) <= cast('#endDate#' as date)
			and voided = 0
			-- Viral Load Undetectable
			group by person_id) as latest_vl_result
		on latest_vl_result.person_id = o.person_id
		where o.concept_id = 4266 and o.value_coded = 4263
		and o.obs_datetime = max_observation
			)

UNION

(select o.person_id, max_observation, "Less than 20" as "VL_result"
	from obs o
	inner join
		(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
			from obs where concept_id = 4273
			and cast(obs_datetime as date) <= cast('#endDate#' as date)
			and voided = 0
			-- Viral Load < 20
			group by person_id) as latest_vl_result
		on latest_vl_result.person_id = o.person_id
		where o.concept_id = 4266 and o.value_coded = 4264
		and o.obs_datetime = max_observation
		 )

UNION

(Select greater_than_20.person_id, max_observation, Viral_Load
from
(select o.person_id, max_observation
from obs o
inner join
	(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
		from obs where concept_id = 4273
		and obs_datetime <= cast('#endDate#' as date)
		and voided = 0
		-- Viral Load >=20
		group by person_id) as latest_vl_result
	on latest_vl_result.person_id = o.person_id
	where o.concept_id = 4266 and o.value_coded = 4265
	and o.obs_datetime = max_observation) greater_than_20
	inner join 
	(select o.person_id, value_numeric as Viral_load
		from obs o
		-- Viral Load copies per ml recorded
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
				from obs where concept_id = 4273
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as latest_vl_result
			on latest_vl_result.person_id = o.person_id
			where o.concept_id = 2254 
			and o.obs_datetime = max_observation
		 )numeric_value
	on greater_than_20.person_id = numeric_value.person_id
		 )
)viral_load_result	
	)results
ON tpt_uptake.Id = results.person_id

left outer JOIN

(select
       o.person_id,
       case
           when value_coded = 2141 then "Pregnant"
           when value_coded = 3771 then "Not-Pregnant"
           when value_coded = 2148 then "Do not Know"
           when value_coded = 1975 then "Not Applicable"
           else ""
       end AS Pregnancy_Status
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as pregnancy
		 from obs oss
         -- Pregnancy
		 where oss.concept_id = 2149 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 2149
	and  o.obs_datetime = max_observation
	and o.voided = 0
	) pregnancy_status
ON tpt_uptake.Id = pregnancy_status.person_id

left outer join

(SELECT distinct person_id, HIV_Status
From
((select o.person_id, max_observation, "HIV Negative" as "HIV_Status"
	from obs o
	inner join
		(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
			from obs where concept_id = 4930  -- IPT form
			and cast(obs_datetime as date) >= cast('#startDate#' as date)
			and cast(obs_datetime as date) <= cast('#endDate#' as date)
			and voided = 0
			-- IPT information filled in TPT form
			group by person_id) as tpt_result
		on tpt_result.person_id = o.person_id
		where o.concept_id = 2227 
		and cast(obs_datetime as date) >= cast('#startDate#' as date)
		and cast(obs_datetime as date) <= cast('#endDate#' as date)
		and o.person_id in (
							select distinct os.person_id
							from obs os
                             -- HIV Negative
							where os.concept_id = 4521 and os.value_coded = 1016 
                            and os.voided = 0
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		)
		and o.obs_datetime = max_observation
			)

UNION

(
	select person_id, max_observation, "HIV Positive" as "HIV_Status"
	from(
	(select distinct o.person_id, max_observation-- , "HIV Positive" as "HIV_Status"
	from obs o
	inner join
		(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
			from obs where concept_id = 3753 -- Patient Register in HIV followup form
			-- and cast(obs_datetime as date) >= cast('#startDate#' as date)
			and cast(obs_datetime as date) <= cast('#endDate#' as date)
			and voided = 0
			-- IPT information filled in HIV followup form
			group by person_id) as tpt_result
			on tpt_result.person_id = o.person_id
			where o.concept_id = 2227 
			and cast(o.obs_datetime as date) >= cast('#startDate#' as date)
			and cast(o.obs_datetime as date) <= cast('#endDate#' as date)
			and o.obs_datetime = max_observation)

			UNION
			
	 (select o.person_id, max_observation-- , "HIV Positive" as "HIV_Status"
				from obs o
				inner join
					(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs where concept_id = 4930  -- IPT form
						and cast(obs_datetime as date) >= cast('#startDate#' as date)
						and cast(obs_datetime as date) <= cast('#endDate#' as date)
						and voided = 0
						-- IPT information filled in TPT form
						group by person_id) as tpt_result
					on tpt_result.person_id = o.person_id
					where o.concept_id = 2227 -- Started IPT
					-- and cast(obs_datetime as date) >= cast('#startDate#' as date)
					and cast(obs_datetime as date) <= cast('#endDate#' as date)
					and o.person_id in (
										select distinct os.person_id
										from obs os
										-- HIV Positive
										where os.concept_id = 4521 and os.value_coded = 1738 
										and os.voided = 0
										AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
										AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					)
					and o.obs_datetime = max_observation

			
	)
	)hiv_pos
)

)hiv_status
)status_recorded
on tpt_uptake.Id = status_recorded.person_id