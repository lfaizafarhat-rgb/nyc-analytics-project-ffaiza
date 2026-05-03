-- models/assignment_work/staging/stg_nyc_open_restaurant_apps.sql
-- Clean and standardize NYC Open Restaurant applications data
-- One row per restaurant application

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'source_nyc_open_restaurants_app') }}
),

cleaned AS (
    SELECT
        -- Get all columns from source, except ones we're transforming
        * EXCEPT (
            objectid,
            globalid,
            seating_interest_sidewalk,
            restaurant_name,
            legal_business_name,
            doing_business_as_dba,
            bulding_number,
            street,
            borough,
            zip,
            business_address,
            food_service_establishment,
            sidewalk_dimensions_length,
            sidewalk_dimensions_width,
            sidewalk_dimensions_area,
            roadway_dimensions_length,
            roadway_dimensions_width,
            roadway_dimensions_area,
            approved_for_sidewalk_seating,
            approved_for_roadway_seating,
            qualify_alcohol,
            sla_serial_number,
            sla_license_type,
            time_of_submission,
            latitude,
            longitude,
            bin,
            bbl,
            nta,
            landmark_district_or_building,
            landmarkdistrict_terms,
            community_board,
            census_tract,
            council_district,
            healthcompliance_terms
        )

        -- Identifiers
        , CAST(objectid AS STRING) AS objectid
        , CAST(globalid AS STRING) AS globalid

        -- Application info
        , CAST(seating_interest_sidewalk AS STRING) AS seating_interest_sidewalk
        , CAST(restaurant_name AS STRING) AS restaurant_name
        , CAST(legal_business_name AS STRING) AS legal_business_name
        , CAST(doing_business_as_dba AS STRING) AS doing_business_as_dba
        , CAST(bulding_number AS STRING) AS bulding_number
        , CAST(street AS STRING) AS street
        , CAST(borough AS STRING) AS borough
        , CAST(zip AS STRING) AS zip
        , CAST(business_address AS STRING) AS business_address
        , CAST(food_service_establishment AS STRING) AS food_service_establishment

        -- Dimensions & areas
        , CAST(sidewalk_dimensions_length AS FLOAT64) AS sidewalk_dimensions_length
        , CAST(sidewalk_dimensions_width AS FLOAT64) AS sidewalk_dimensions_width
        , CAST(sidewalk_dimensions_area AS FLOAT64) AS sidewalk_dimensions_area
        , CAST(roadway_dimensions_length AS FLOAT64) AS roadway_dimensions_length
        , CAST(roadway_dimensions_width AS FLOAT64) AS roadway_dimensions_width
        , CAST(roadway_dimensions_area AS FLOAT64) AS roadway_dimensions_area

        -- Approvals & licenses
        , CAST(approved_for_sidewalk_seating AS STRING) AS approved_for_sidewalk_seating
        , CAST(approved_for_roadway_seating AS STRING) AS approved_for_roadway_seating
        , CAST(qualify_alcohol AS STRING) AS qualify_alcohol
        , CAST(sla_serial_number AS STRING) AS sla_serial_number
        , CAST(sla_license_type AS STRING) AS sla_license_type

        , CAST(time_of_submission AS TIMESTAMP) AS time_of_submission
        , CAST(latitude AS FLOAT64) AS latitude
        , CAST(longitude AS FLOAT64) AS longitude
        , CAST(bin AS STRING) AS bin
        , CAST(bbl AS STRING) AS bbl
        , CAST(nta AS STRING) AS nta
        , CAST(landmark_district_or_building AS STRING) AS landmark_district_or_building
        , CAST(landmarkdistrict_terms AS STRING) AS landmarkdistrict_terms
        , CAST(community_board AS STRING) AS community_board
        , CAST(census_tract AS STRING) AS census_tract
        , CAST(council_district AS STRING) AS council_district
        , CAST(healthcompliance_terms AS STRING) AS healthcompliance_terms

        -- Metadata
        , CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    -- Deduplicate
    QUALIFY ROW_NUMBER() OVER (PARTITION BY objectid ORDER BY time_of_submission DESC) = 1
)

SELECT * 
FROM cleaned