-- Clean and standardize NYC Open Restaurant Applications data
-- One row per application

WITH source AS (
    SELECT * FROM {{ source('raw', 'source_nyc_open_restaurants_app') }}
),

cleaned AS (
    SELECT
        -- Get all columns from source, except ones we are transforming below
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
        ),

        -- Identifiers
        CAST(objectid AS STRING) AS application_id,
        CAST(globalid AS STRING) AS global_id,

        -- Restaurant info
        CAST(restaurant_name AS STRING) AS restaurant_name,
        CAST(legal_business_name AS STRING) AS legal_business_name,
        CAST(doing_business_as_dba AS STRING) AS dba_name,
        CAST(bulding_number AS STRING) AS bulding_number,
        CAST(street AS STRING) AS street_name,
        UPPER(TRIM(CAST(borough AS STRING))) AS borough,
        CAST(zip AS STRING) AS postal_zip,
        CAST(business_address AS STRING) AS business_address,

        -- Food service permit
        CAST(food_service_establishment AS STRING) AS fse_permit_number,

        -- Sidewalk seating dimensions
        CAST(sidewalk_dimensions_length AS FLOAT) AS sidewalk_length_ft,
        CAST(sidewalk_dimensions_width AS FLOAT) AS sidewalk_width_ft,
        CAST(sidewalk_dimensions_area AS FLOAT) AS sidewalk_area_sqft,

        -- Roadway seating dimensions
        CAST(roadway_dimensions_length AS FLOAT) AS roadway_length_ft,
        CAST(roadway_dimensions_width AS FLOAT) AS roadway_width_ft,
        CAST(roadway_dimensions_area AS FLOAT) AS roadway_area_sqft,

        -- Approvals
        UPPER(TRIM(CAST(approved_for_sidewalk_seating AS STRING))) AS approved_sidewalk,
        UPPER(TRIM(CAST(approved_for_roadway_seating AS STRING))) AS approved_roadway,

        -- Alcohol license
        UPPER(TRIM(CAST(qualify_alcohol AS STRING))) AS qualifies_alcohol,
        CAST(sla_serial_number AS STRING) AS sla_serial_number,
        CAST(sla_license_type AS STRING) AS sla_license_type,

        -- Submission date
        CAST(time_of_submission AS TIMESTAMP) AS submission_time,

        -- Coordinates
        CAST(latitude AS DECIMAL) AS latitude,
        CAST(longitude AS DECIMAL) AS longitude,

        -- Building identifiers
        CAST(bin AS STRING) AS bin,
        CAST(bbl AS STRING) AS bbl,

        -- Neighborhood info
        CAST(nta AS STRING) AS nta,
        CAST(landmark_district_or_building AS STRING) AS landmark_terms,
        CAST(landmarkdistrict_terms AS STRING) AS landmark_compliance,
        CAST(community_board AS STRING) AS community_board,
        CAST(census_tract AS STRING) AS census_tract,
        CAST(council_district AS STRING) AS council_district,
        CAST(healthcompliance_terms AS STRING) AS health_compliance_terms,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    -- Filters: only include applications with valid IDs and submission times
    WHERE objectid IS NOT NULL
    AND time_of_submission IS NOT NULL

    -- Deduplicate: keep the latest submission per objectid
    QUALIFY ROW_NUMBER() OVER (PARTITION BY objectid ORDER BY time_of_submission DESC) = 1
)

SELECT * FROM cleaned
-- All columns here will be part of the table: stg_nyc_open_restaurants_app