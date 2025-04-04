 /*
DDL Script: Creating Bronze Layer Tables and Procedure to load the Data

Script Purpose: 
	This script creates tables in the 'bronze' schema, dropping existing ones if already exist.
	The script also loads the data into the 'bronze' schema from external CSV files.
*/

-- Drop table if exists and create the CRM tables
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'bronze' AND tablename = 'crm_cust_info') THEN
        DROP TABLE bronze.crm_cust_info;
    END IF;
END $$;

CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);

-- CRM Product Info
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'bronze' AND tablename = 'crm_prd_info') THEN
        DROP TABLE bronze.crm_prd_info;
    END IF;
END $$;

CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(100),
    prd_cost FLOAT,
    prd_line VARCHAR(50),
    prd_start_dt VARCHAR(50),
    prd_end_dt VARCHAR(50)
);

-- CRM Sales Details
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'bronze' AND tablename = 'crm_sales_details') THEN
        DROP TABLE bronze.crm_sales_details;
    END IF;
END $$;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales FLOAT,
    sls_quantity INT,
    sls_price FLOAT
);

-- ERP Customer AZ12
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'bronze' AND tablename = 'erp_cust_az12') THEN
        DROP TABLE bronze.erp_cust_az12;
    END IF;
END $$;

CREATE TABLE bronze.erp_cust_az12 (
    CID VARCHAR(50),
    BDATE VARCHAR(50),
    GEN VARCHAR(50)
);

-- ERP Location A101
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'bronze' AND tablename = 'erp_loc_a101') THEN
        DROP TABLE bronze.erp_loc_a101;
    END IF;
END $$;

CREATE TABLE bronze.erp_loc_a101 (
    CID VARCHAR(50),
    CNTRY VARCHAR(50)
);

-- ERP Product Category G1V2
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'bronze' AND tablename = 'erp_px_cat_g1v2') THEN
        DROP TABLE bronze.erp_px_cat_g1v2;
    END IF;
END $$;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    ID VARCHAR(50),
    CAT VARCHAR(50),
    SUBCAT VARCHAR(50),
    MAINTENANCE VARCHAR(50)
);

-- Checking Data has loaded correctly
SELECT * FROM bronze.crm_cust_info;
SELECT * FROM bronze.crm_prd_info;
SELECT * FROM bronze.crm_sales_details;
SELECT * FROM bronze.erp_cust_az12;
SELECT * FROM bronze.erp_loc_a101;
SELECT * FROM bronze.erp_px_cat_g1v2;

-- Creating a Bronze Layer Procedure
CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    -- Start of the procedure
    batch_start_time := clock_timestamp();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    -- Loading CRM Tables
    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    -- CRM Customer Info
    BEGIN
        start_time := clock_timestamp();
        RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
        EXECUTE 'TRUNCATE TABLE bronze.crm_cust_info';
        RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
        EXECUTE 'COPY bronze.crm_cust_info 
            FROM ''/Users/alessandrosuarez/Documents/GitHub/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'' 
            DELIMITER '','' 
            CSV HEADER';
        end_time := clock_timestamp();
        RAISE NOTICE '>> Rows Loaded: %', (SELECT COUNT(*) FROM bronze.crm_cust_info);
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error loading bronze.crm_cust_info: %', SQLERRM;
    END;

    -- CRM Product Info
    BEGIN
        start_time := clock_timestamp();
        RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
        EXECUTE 'TRUNCATE TABLE bronze.crm_prd_info';
        RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
        EXECUTE 'COPY bronze.crm_prd_info 
            FROM ''/Users/alessandrosuarez/Documents/GitHub/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'' 
            DELIMITER '','' 
            CSV HEADER';
        end_time := clock_timestamp();
        RAISE NOTICE '>> Rows Loaded: %', (SELECT COUNT(*) FROM bronze.crm_prd_info);
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error loading bronze.crm_prd_info: %', SQLERRM;
    END;

    -- CRM Sales Details
    BEGIN
        start_time := clock_timestamp();
        RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
        EXECUTE 'TRUNCATE TABLE bronze.crm_sales_details';
        RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
        EXECUTE 'COPY bronze.crm_sales_details 
            FROM ''/Users/alessandrosuarez/Documents/GitHub/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'' 
            DELIMITER '','' 
            CSV HEADER';
        end_time := clock_timestamp();
        RAISE NOTICE '>> Rows Loaded: %', (SELECT COUNT(*) FROM bronze.crm_sales_details);
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error loading bronze.crm_sales_details: %', SQLERRM;
    END;

    -- ERP Customer AZ12
    BEGIN
        start_time := clock_timestamp();
        RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
        EXECUTE 'TRUNCATE TABLE bronze.erp_cust_az12';
        RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
        EXECUTE 'COPY bronze.erp_cust_az12 
            FROM ''/Users/alessandrosuarez/Documents/GitHub/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'' 
            DELIMITER '','' 
            CSV HEADER';
        end_time := clock_timestamp();
        RAISE NOTICE '>> Rows Loaded: %', (SELECT COUNT(*) FROM bronze.erp_cust_az12);
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error loading bronze.erp_cust_az12: %', SQLERRM;
    END;

    -- ERP Location A101
    BEGIN
        start_time := clock_timestamp();
        RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
        EXECUTE 'TRUNCATE TABLE bronze.erp_loc_a101';
        RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
        EXECUTE 'COPY bronze.erp_loc_a101 
            FROM ''/Users/alessandrosuarez/Documents/GitHub/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'' 
            DELIMITER '','' 
            CSV HEADER';
        end_time := clock_timestamp();
        RAISE NOTICE '>> Rows Loaded: %', (SELECT COUNT(*) FROM bronze.erp_loc_a101);
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error loading bronze.erp_loc_a101: %', SQLERRM;
    END;

    -- ERP Product Category G1V2
    BEGIN
        start_time := clock_timestamp();
        RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
        EXECUTE 'TRUNCATE TABLE bronze.erp_px_cat_g1v2';
        RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        EXECUTE 'COPY bronze.erp_px_cat_g1v2 
            FROM ''/Users/alessandrosuarez/Documents/GitHub/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'' 
            DELIMITER '','' 
            CSV HEADER';
        end_time := clock_timestamp();
        RAISE NOTICE '>> Rows Loaded: %', (SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2);
        RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM end_time - start_time);
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error loading bronze.erp_px_cat_g1v2: %', SQLERRM;
    END;

    -- End of the procedure
    batch_end_time := clock_timestamp();
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE '   - Total Load Duration: % seconds', EXTRACT(EPOCH FROM batch_end_time - batch_start_time);
    RAISE NOTICE '==========================================';
END $$;

-- Execute the stored procedure
CALL bronze.load_bronze();
