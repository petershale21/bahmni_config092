SELECT ARV_regimen AS Regimen_Name,
	IF(Id is null, 0,SUM(IF(Weight_ >=0  and Weight_ <4.0 AND Age < 15,1,0))) AS "0-3.9kg",
    IF(Id is null, 0,SUM(IF(Weight_ >=4.0  and Weight_ <6.0 AND Age < 15,1,0))) AS "4-5.9kg",
    IF(Id is null, 0,SUM(IF(Weight_ >=6.0  and Weight_ <10.0 AND Age < 15,1,0))) AS "6-9.9kg",
    IF(Id is null, 0,SUM(IF(Weight_ >=10.0  and Weight_ <14 AND Age < 15,1,0))) AS "10-13.9kg",
	IF(Id is null, 0,SUM(IF(Weight_ >=14.0  and Weight_ <20 AND Age < 15,1,0))) AS "14-19.9kg",
	IF(Id is null, 0,SUM(IF(Weight_ >=20.0  and Weight_ <25 AND Age < 15,1,0))) AS "20-24.9kg",
	IF(Id is null, 0,SUM(IF(Weight_ >=25.0  and Weight_ <35 AND Age < 15,1,0))) AS "25-34.9kg",
	IF(Id is null, 0,SUM(IF(Weight_ >=35.0  AND Age < 15,1,0))) AS ">=35kg"

FROM (

SELECT A.person_id as Id, ARV_regimen, Age, Weight_
FROM
(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) as ARV_regimen, 'drug_count_1' as outcome, Age
						FROM
						(
							select distinct o.person_id,o.value_coded as current_regimen, 
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2250
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 INNER JOIN person on o.person_id = person.person_id
							 AND o.concept_id = 2250 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4175,4243))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
						)currentreg
							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as substitute_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 4284
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 4284 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4175,4243))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)substitutereg ON currentreg.person_id = substitutereg.person_id

							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as switch_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2268
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 2268 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4175,4243))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)switchreg ON currentreg.person_id = switchreg.person_id
                
UNION

-- 3 months supply
SELECT person_id as Id, ARV_regimen, outcome, Age
FROM( (
		SELECT person_id, ARV_regimen, outcome, Age 
					FROM( 
						SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) as ARV_regimen, 'drug_count_3' as outcome, Age
						FROM
						(
							select distinct o.person_id,o.value_coded as current_regimen,
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2250
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 INNER JOIN person on o.person_id = person.person_id
							 AND o.concept_id = 2250 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4177))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
						)currentreg
							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as substitute_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 4284
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 4284 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4177))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)substitutereg ON currentreg.person_id = substitutereg.person_id

                            LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as switch_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2268
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 2268 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4177))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)switchreg ON currentreg.person_id = switchreg.person_id
								)regimen 
								) 
		UNION
		
		(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_3' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
					floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						 INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					
                 LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

                    )regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_3' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
					floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						 INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4177))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    )regimen
					)

UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_3' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
					floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4177
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4177
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4177
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
	)regimen
	
)
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.person_id not in (
									select distinct(o.person_id)
									from obs o
									where o.person_id in (
											-- FOLLOW UPS
												select firstquery.person_id
												from
												(
												select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, max(oss.value_datetime) as latest_followup_obs
												from obs oss
															where oss.voided=0 
															and oss.concept_id=3752 
															and oss.obs_datetime <= CAST('#endDate#' AS DATE)
															and oss.obs_datetime > DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
															group by oss.person_id) firstquery
												inner join (
															select os.person_id,datediff(max(os.value_datetime), CAST('#endDate#' AS DATE)) as last_ap
															from obs os
															where concept_id = 3752
															and os.obs_datetime <= CAST('#endDate#' AS DATE)
															group by os.person_id
															having last_ap < 0
												) secondquery
												on firstquery.person_id = secondquery.person_id
									) and o.person_id in (
											-- TOUTS
											select distinct(person_id)
											from
											(
												select os.person_id, max(os.value_datetime) as latest_transferout
												from obs os
												where os.concept_id=2266
												group by os.person_id
												having latest_transferout <= CAST('#endDate#' AS DATE)
											) as TOUTS
									)
		)
AND ARTCurrent_PrevMonths.person_id not in (
						-- Death
									select distinct p.person_id
									from person p
									where dead = 1
									and death_date <= CAST('#endDate#' AS DATE)		
										)
			
UNION
-- 6 months supply
SELECT person_id as Id, ARV_regimen, outcome, Age
FROM( (
		SELECT person_id, ARV_regimen, outcome, Age  
					FROM( 
						SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) as ARV_regimen, 'drug_count_6' as outcome, Age
						FROM
						(
							select distinct o.person_id,o.value_coded as current_regimen,
                            floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2250
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
                             INNER JOIN person on o.person_id = person.person_id
							 AND o.concept_id = 2250 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4247))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
						)currentreg
							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as substitute_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 4284
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 4284 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4247))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)substitutereg ON currentreg.person_id = substitutereg.person_id

							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as switch_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2268
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 2268 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4247))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)switchreg ON currentreg.person_id = switchreg.person_id
								)regimen 
								) 
		UNION
		
		(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id)regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                        INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

					)regimen
					)
	   
UNION

(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
					
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

					)regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
					
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
					
					)regimen
					)


UNION

(SELECT person_id, ARV_regimen, outcome, Age  
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
					
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
					
					)regimen
					)
UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen, 'drug_count_6' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                    INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4247
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4247
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

					 LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4247
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id


	)regimen
	
)
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.person_id not in (
									select distinct(o.person_id)
									from obs o
									where o.person_id in (
											-- FOLLOW UPS
												select firstquery.person_id
												from
												(
												select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, max(oss.value_datetime) as latest_followup_obs
												from obs oss
															where oss.voided=0 
															and oss.concept_id=3752 
															and oss.obs_datetime <= CAST('#endDate#' AS DATE)
															and oss.obs_datetime > DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
															group by oss.person_id) firstquery
												inner join (
															select os.person_id,datediff(max(os.value_datetime), CAST('#endDate#' AS DATE)) as last_ap
															from obs os
															where concept_id = 3752
															and os.obs_datetime <= CAST('#endDate#' AS DATE)
															group by os.person_id
															having last_ap < 0
												) secondquery
												on firstquery.person_id = secondquery.person_id
									) and o.person_id in (
											-- TOUTS
											select distinct(person_id)
											from
											(
												select os.person_id, max(os.value_datetime) as latest_transferout
												from obs os
												where os.concept_id=2266
												group by os.person_id
												having latest_transferout <= CAST('#endDate#' AS DATE)
											) as TOUTS
									)
		)
AND ARTCurrent_PrevMonths.person_id not in (
						-- Death
									select distinct p.person_id
									from person p
									where dead = 1
									and death_date <= CAST('#endDate#' AS DATE)		
										)
UNION

-- Other months supply

SELECT person_id as Id, ARV_regimen, outcome, Age
FROM( (
		SELECT person_id, ARV_regimen, outcome, Age 
					FROM( 
						SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) as ARV_regimen,'drug_count_other' as outcome, Age
						FROM
						(
							select distinct o.person_id,o.value_coded as current_regimen,
                            floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2250
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
                             INNER JOIN person on o.person_id = person.person_id
							 AND o.concept_id = 2250 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4176,4245,4246,4820))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
						)currentreg
							LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as substitute_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 4284
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 4284 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4176,4245,4246,4820))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)substitutereg ON currentreg.person_id = substitutereg.person_id
								
                            LEFT OUTER JOIN
							(
							select distinct o.person_id,o.value_coded as switch_regimen 
							from obs o

                            inner join 
                                        (select ob.person_id,cast(max(ob.obs_datetime) as date) maxdate 
                                        from obs ob
                                        where ob.concept_id = 2268
                                        AND cast(ob.obs_datetime as date) <= cast('#endDate#' as date)
                                        AND MONTH(ob.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                        AND YEAR(ob.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                        and ob.voided = 0
                                        group by ob.person_id 
                                        )latest 
                                    on latest.person_id = o.person_id
                                    
											-- CLIENTS SEEN FOR ART
							 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                             INNER JOIN obs os on latest.person_id = os.person_id	
							 AND o.concept_id = 2268 
							 AND o.voided = 0    
                             AND (os.concept_id = 4174 AND os.value_coded in (4247))
                             AND os.voided = 0
                             and CAST(o.obs_datetime as date) = maxdate
				             and CAST(o.obs_datetime AS DATE) = CAST(os.obs_datetime AS DATE)                              
                             and o.person_id in(
                                                SELECT oss.person_id
                                                FROM obs oss
                                                WHERE oss.concept_id = 3843 AND oss.value_coded = 3841 OR oss.value_coded = 3842
                                                AND MONTH(oss.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                AND oss.voided = 0 
                                                )
												
                            AND o.person_id not in (
                                            select oss.person_id
                                            from obs oss
                                                        -- CLIENTS NEWLY INITIATED ON ART													
                                            WHERE (oss.concept_id = 2249 
                                                AND MONTH(oss.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(oss.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                )
                                                AND oss.voided = 0)
							)switchreg ON currentreg.person_id = switchreg.person_id

                                )regimen 
								) 
		UNION
		
		(SELECT person_id, ARV_regimen, outcome, Age
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                          INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4176,4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4176,4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4176,4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)
	   
UNION

(SELECT person_id, ARV_regimen, outcome, Age
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                          INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4245,4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

                    )regimen
					)

UNION

(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4246,4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)


UNION

(SELECT person_id, ARV_regimen, outcome, Age 
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)

UNION
(SELECT person_id, ARV_regimen, outcome, Age
		FROM(
			SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
			FROM(
					(select distinct o.person_id,o.value_coded current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                         INNER JOIN person on o.person_id = person.person_id
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND o.concept_id = 2250
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
									)
					)
				)currentreg
					LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as substitute_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND o.concept_id = 4284
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4820))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id
                    
                    LEFT OUTER JOIN
					(
					(select distinct o.person_id,o.value_coded as switch_regimen
						FROM obs o
						-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
						  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
						  AND o.concept_id = 2268
						  AND o.voided = 0 
						  AND o.person_id in (
												SELECT oss.person_id
												FROM obs oss
												WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
												AND oss.concept_id = 4174 and (oss.value_coded in (4247))
												)
						 
                 
           WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
                    
                    )regimen
					)

UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                    INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4176
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4176
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4176
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id

	)regimen
	)

UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                     INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4245
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4245
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4245
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
	)regimen
	)
		   
UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                    INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4246
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4246
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4246
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
	)regimen
	)
UNION

(SELECT distinct person_id, ARV_regimen, outcome, Age
FROM(SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen,'drug_count_other' as outcome, Age
                FROM(SELECT o.person_id,o.value_coded as current_regimen,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
                    INNER JOIN person on o.person_id = person.person_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2250
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4820
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
					))currentreg
					LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as substitute_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 4284
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4176
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)substitutereg
					ON substitutereg.person_id =  currentreg.person_id

                    LEFT OUTER JOIN
					(
					SELECT o.person_id,o.value_coded as switch_regimen
					FROM obs o
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
					 AND o.voided = 0 
					 AND o.concept_id  = 2268
					 AND o.person_id in(
										SELECT oss.person_id
										FROM obs oss
										WHERE MONTH(oss.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND YEAR(oss.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
										AND oss.concept_id = 4174 and oss.value_coded = 4820
										AND oss.person_id in (
															select distinct os.person_id from obs os
															where 
															MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)) 
															AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH))
															AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
															)
										)
					 				 
				WHERE o.person_id not in (
						select distinct(person_id)
						from
								(
								select os.person_id, cast(max(os.obs_datetime) as date) as latest_visit
												from obs os
												where os.concept_id=3843
												and os.obs_datetime <= CAST('#endDate#' AS DATE)
												group by os.person_id
												
								) as visit
						where CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						and latest_visit > CAST(o.obs_datetime AS DATE) 
						and latest_visit <= CAST('#endDate#' AS DATE)
										)	
					)switchreg
					ON switchreg.person_id =  currentreg.person_id
	)regimen
	)
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.person_id not in (
									select distinct(o.person_id)
									from obs o
									where o.person_id in (
											-- FOLLOW UPS
												select firstquery.person_id
												from
												(
												select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, max(oss.value_datetime) as latest_followup_obs
												from obs oss
															where oss.voided=0 
															and oss.concept_id=3752 
															and oss.obs_datetime <= CAST('#endDate#' AS DATE)
															and oss.obs_datetime > DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -7 MONTH)
															group by oss.person_id) firstquery
												inner join (
															select os.person_id,datediff(max(os.value_datetime), CAST('#endDate#' AS DATE)) as last_ap
															from obs os
															where concept_id = 3752
															and os.obs_datetime <= CAST('#endDate#' AS DATE)
															group by os.person_id
															having last_ap < 0
												) secondquery
												on firstquery.person_id = secondquery.person_id
									) and o.person_id in (
											-- TOUTS
											select distinct(person_id)
											from
											(
												select os.person_id, max(os.value_datetime) as latest_transferout
												from obs os
												where os.concept_id=2266
												group by os.person_id
												having latest_transferout <= CAST('#endDate#' AS DATE)
											) as TOUTS
									)
		)
AND ARTCurrent_PrevMonths.person_id not in (
						-- Death
									select distinct p.person_id
									from person p
									where dead = 1
									and death_date <= CAST('#endDate#' AS DATE)		
										)
)A

LEFT OUTER JOIN 

(select o.person_id,value_numeric as Weight_
		from obs o 
		inner join 
				(select person_id,max(obs_datetime) maxdate 
				from obs a
				where obs_datetime <= '#endDate#'
				and concept_id = 119
				group by person_id 
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 119
			and  o.obs_datetime = maxdate	
			)weight
		on A.person_id = weight.person_id
	)X
	Group by ARV_regimen