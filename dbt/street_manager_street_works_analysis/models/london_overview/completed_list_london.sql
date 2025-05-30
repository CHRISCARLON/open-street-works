{% set table_alias = 'completed_works_list_london_latest' %}
{{ config(materialized='table', alias=table_alias) }}

{% set current_schema = 'raw_data_' ~ var('year') %}
{% set current_table = '"' ~ var('month') ~ '_' ~ var('year') ~ '"' %}

SELECT DISTINCT ON (permit_table.permit_reference_number)
    permit_table.event_type,
    permit_table.event_time,
    permit_table.permit_reference_number,
    permit_table.promoter_organisation,
    permit_table.promoter_swa_code,
    permit_table.highway_authority,
    permit_table.highway_authority_swa_code,
    permit_table.work_category,
    permit_table.works_location_type,
    permit_table.proposed_start_date,
    permit_table.proposed_end_date,
    permit_table.actual_start_date_time,
    permit_table.actual_end_date_time,
    permit_table.collaborative_working,
    permit_table.activity_type,
    permit_table.is_traffic_sensitive,
    permit_table.is_ttro_required,
    permit_table.traffic_management_type_ref,
    permit_table.street_name,
    permit_table.road_category,
    permit_table.usrn,
    permit_table.work_status_ref,
    open_usrn.geometry,
    geo_place.ofgem_electricity_licence,
    geo_place.ofgem_gas_licence,
    geo_place.ofcom_licence,
    geo_place.ofwat_licence,
    COALESCE(uprn_counts.uprn_count, 0) as uprn_count,
    {{ current_timestamp() }} AS date_processed
FROM {{ current_schema }}.{{ current_table }} AS permit_table
LEFT JOIN os_open_usrns.open_usrns_latest AS open_usrn ON permit_table.usrn = open_usrn.usrn
LEFT JOIN geoplace_swa_codes.LATEST_ACTIVE AS geo_place ON CAST(permit_table.promoter_swa_code AS INT) = CAST(geo_place.swa_code AS INT)
LEFT JOIN {{ ref('uprn_usrn_count') }} as uprn_counts ON permit_table.usrn = uprn_counts.usrn
WHERE permit_table.work_status_ref = 'completed'
    AND permit_table.event_type = 'WORK_STOP'
    AND permit_table.highway_authority IN (
        'LONDON BOROUGH OF BARNET',
        'TRANSPORT FOR LONDON (TFL)',
        'LONDON BOROUGH OF HARROW',
        'LONDON BOROUGH OF BRENT',
        'LONDON BOROUGH OF TOWER HAMLETS',
        'LONDON BOROUGH OF ENFIELD',
        'LONDON BOROUGH OF EALING',
        'LONDON BOROUGH OF MERTON',
        'LONDON BOROUGH OF CROYDON',
        'LONDON BOROUGH OF BARKING AND DAGENHAM',
        'LONDON BOROUGH OF SUTTON',
        'LONDON BOROUGH OF BEXLEY',
        'ROYAL BOROUGH OF KENSINGTON AND CHELSEA',
        'LONDON BOROUGH OF SOUTHWARK',
        'LONDON BOROUGH OF HILLINGDON',
        'LONDON BOROUGH OF CAMDEN',
        'LONDON BOROUGH OF WALTHAM FOREST',
        'LONDON BOROUGH OF REDBRIDGE',
        'CITY OF WESTMINSTER',
        'ROYAL BOROUGH OF GREENWICH',
        'LONDON BOROUGH OF ISLINGTON',
        'LONDON BOROUGH OF HARINGEY',
        'LONDON BOROUGH OF NEWHAM',
        'LONDON BOROUGH OF HACKNEY',
        'LONDON BOROUGH OF HAMMERSMITH & FULHAM',
        'LONDON BOROUGH OF HOUNSLOW',
        'LONDON BOROUGH OF WANDSWORTH',
        'ROYAL BOROUGH OF KINGSTON UPON THAMES',
        'LONDON BOROUGH OF LAMBETH',
        'LONDON BOROUGH OF HAVERING',
        'LONDON BOROUGH OF RICHMOND UPON THAMES',
        'LONDON BOROUGH OF LEWISHAM',
        'CITY OF LONDON CORPORATION',
        'LONDON BOROUGH OF BROMLEY'
    )
