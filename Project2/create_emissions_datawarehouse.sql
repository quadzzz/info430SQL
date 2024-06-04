-- Switch to the new database
USE Team8_EmissionsDataWarehouse;
GO

-- Create tables for your dimensions and fact table
CREATE TABLE dimCountry (
    country_id INT PRIMARY KEY,
    country_code VARCHAR(3),
    country_name VARCHAR(50)
);

CREATE TABLE dimYear (
    year_id INT PRIMARY KEY,
    year INT
);

CREATE TABLE dimRegion (
    region_id INT PRIMARY KEY,
    region VARCHAR(50)
);

CREATE TABLE dimSubRegion (
    sub_region_id INT PRIMARY KEY,
    sub_region VARCHAR(50)
);

CREATE TABLE dimEmissionSource (
    emission_source_id INT PRIMARY KEY,
    emission_source VARCHAR(50)
);

CREATE TABLE dimSector (
    sector_id INT PRIMARY KEY,
    sector VARCHAR(100)
);

CREATE TABLE dimGas (
    gas_id INT PRIMARY KEY,
    gas VARCHAR(50)
);

CREATE TABLE factEmissions (
    country_id INT,
    year_id INT,
    region_id INT,
    sub_region_id INT,
    emission_source_id INT,
    sector_id INT,
    gas_id INT,
    emissions_quantity FLOAT,
    PRIMARY KEY (country_id, year_id, sector_id, gas_id, emission_source_id, region_id, sub_region_id),
    FOREIGN KEY (country_id) REFERENCES dimCountry(country_id),
    FOREIGN KEY (year_id) REFERENCES dimYear(year_id),
    FOREIGN KEY (region_id) REFERENCES dimRegion(region_id),
    FOREIGN KEY (sub_region_id) REFERENCES dimSubRegion(sub_region_id),
    FOREIGN KEY (emission_source_id) REFERENCES dimEmissionSource(emission_source_id),
    FOREIGN KEY (sector_id) REFERENCES dimSector(sector_id),
    FOREIGN KEY (gas_id) REFERENCES dimGas(gas_id)
);
GO






