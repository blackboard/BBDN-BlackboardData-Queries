select
    lt.start_date,
    lt.name as term,
    count(distinct case when lc.design_mode = 'C' then lc.id else null end) as classic_count,
    count(distinct case when lc.design_mode in ('U','P') then lc.id else null end) as ultra_count,
    round(ultra_count / (classic_count + ultra_count) * 100, 0) as ultra_percent
from cdm_lms.course lc
inner join cdm_lms.term lt
    on lt.id = lc.term_id
where lt.start_date > '{date}'
group by 
    lt.start_date,
    lt.name
order by
    lt.start_date