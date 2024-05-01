USE Team8NordstromDB
GO

-- INSERT INTO tblBrand (BrandDescription) VALUES ('designer')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('shoe women')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('shoe men')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('youth clothing')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('clothing women')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('clothing men')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('denim women')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('fine jewlery')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('athletic')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('plus size women')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('accessories')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('youth shoes')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('cosmetics')
-- INSERT INTO tblBrand (BrandDescription) VALUES ('home')


-- ALTER TABLE tblBrand
-- ADD BrandName VARCHAR(50) default 'Unknown';

UPDATE tblBrand
SET BrandName = CASE 
    WHEN BrandID = 1 THEN 'Gucci'
    WHEN BrandID = 2 THEN 'Jeffrey Campbell'
    WHEN BrandID = 3 THEN 'To Boot New York'
    WHEN BrandID = 4 THEN 'Habitual Kids'
    WHEN BrandID = 5 THEN 'Reformation'
    WHEN BrandID = 6 THEN 'Marc Fisher'
    WHEN BrandID = 7 THEN 'AMIRI'
    WHEN BrandID = 8 THEN 'Mini Rodini'
    WHEN BrandID = 9 THEN 'Treasure & Bond'
    WHEN BrandID = 10 THEN 'BOSS'
    WHEN BrandID = 11 THEN 'Good American'
    WHEN BrandID = 12 THEN 'Bony Levy'
    WHEN BrandID = 13 THEN 'Nike'
    WHEN BrandID = 14 THEN 'NYDJ'
    WHEN BrandID = 15 THEN 'Fjallraven'
    WHEN BrandID = 16 THEN 'Stride Rite'
    WHEN BrandID = 17 THEN 'MAC'
    WHEN BrandID = 18 THEN 'Boll & Branch'

    ELSE 'Other Brand'
END;




SELECT * FROM tblBrand
GO