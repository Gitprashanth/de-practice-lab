-- Datasets for the three layers. thelook_ecommerce lives in the US multi-region,
-- so my datasets must be in US too (BigQuery cannot join across locations).
CREATE SCHEMA IF NOT EXISTS `de-practice-lab-511020.bronze` OPTIONS (location = 'US');
CREATE SCHEMA IF NOT EXISTS `de-practice-lab-511020.silver` OPTIONS (location = 'US');
CREATE SCHEMA IF NOT EXISTS `de-practice-lab-511020.gold`   OPTIONS (location = 'US');
