with rule_month_score as (
    select
        instance_id,
        date_trunc(month, scoring_timestamp)::date as month_start,
        date_trunc(quarter, scoring_timestamp)::date as quarter_start,
        rule,
        dense_rank() over (partition by instance_id order by month_start desc) as month_rank,
        -- MIN
        round(min(numeric_score),2) as min_score,
        lag(min_score) over (partition by rule order by month_start) as last_month_min_score,
        min_score - last_month_min_score as min_score_improvement_month,
        lag(min_score) over (partition by rule order by quarter_start) as last_quarter_min_score,
        min_score - last_quarter_min_score as min_score_improvement_quarter,
        -- AVG
        round(avg(numeric_score),2) as avg_score,
        lag(avg_score) over (partition by rule order by month_start) as last_month_avg_score,
        avg_score - last_month_avg_score as avg_score_improvement_month,
        lag(avg_score) over (partition by rule order by quarter_start) as last_quarter_avg_score,
        avg_score - last_quarter_avg_score as avg_score_improvement_quarter,
        -- MAX
        round(max(numeric_score),2) as max_score,
        lag(max_score) over (partition by rule order by month_start) as last_month_max_score,
        max_score - last_month_max_score as max_score_improvement_month,
        lag(max_score) over (partition by rule order by quarter_start) as last_quarter_max_score,
        max_score - last_quarter_max_score as max_score_improvement_quarter
    from cdm_aly.content_score
    group by 1,2,3,4
) 

/***** UNCOMMENT (remove "--" from) THE LINE BELOW YOUR QUESTION AND RUN THE QUERY TO SEE RESULTS *****/

/* in which AX areas are we IMPROVING most? */

--select rule, avg_score, avg_score_improvement_month, avg_score_improvement_quarter from rule_month_score where month_rank = 1 and avg_score is not null order by avg_score_improvement_quarter desc limit 5; 

/* in which AX areas are we WORSENING most? */

--select rule, avg_score, avg_score_improvement_month, avg_score_improvement_quarter from rule_month_score where month_rank = 1 and avg_score is not null order by avg_score_improvement_quarter asc limit 5; 

/* in which AX areas are we performing BEST? */

--select rule, min_score, avg_score, max_score from rule_month_score where month_rank = 1 and avg_score is not null order by avg_score desc limit 5; 

/* in which AX areas are we performing WORST? */

-- select rule, min_score, avg_score, max_score from rule_month_score where month_rank = 1 and avg_score is not null order by avg_score asc limit 5; 

/* Show me the full history of AX performance per rule */

-- select * from rule_month_score order by rule, month_start desc;

/***** Ignore everything below this line *****/
select 'Uncomment a line above and run the query again to see results' as oops
