select
    tae.data:objectType::string as source_format,
    tae.data:result:formatType::string as target_format,
    count(distinct tae.data:contextId::string) as distinct_courses,
    count(distinct tae.data:userId::string) as distinct_users,
    count(tae.event_type) as download_count
from cdm_tlm.ally_events tae
where
    tae.event_type = 'COMPLETE_DOWNLOAD_ALTERNATIVE_FORMAT'
    and tae.event_date >= {event_date}
group by 
    source_format,
    target_format
order by
    source_format,
    target_format