SELECT * FROM FMSSExport
-- Standard Requirements (pg 10)
-- FACLOCID
SELECT Location, Count(*) FROM FMSSExport group by Location order by location
-- UNITCODE
SELECT Park, Count(*) FROM FMSSExport group by Park order by Park
SELECT Park, Count(*) FROM FMSSExport where Park not in (select Code from DOM_UNITCODE) group by Park order by Park
-- REGION
SELECT Region, Count(*) FROM FMSSExport group by Region
-- FACOCCUPANT
SELECT Occupant, Count(*) FROM FMSSExport group by Occupant
SELECT Occupant, Count(*) FROM FMSSExport where Occupant not in (select Code from DOM_FACOCCUMAINT) group by Occupant
-- LCSID
SELECT CLASSSTR, Count(*) FROM FMSSExport group by CLASSSTR order by CLASSSTR
SELECT CLASSSTR, Count(*) FROM FMSSExport where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS') group by CLASSSTR order by CLASSSTR
-- FACOWNER
SELECT Asset_Ownership, Count(*) FROM FMSSExport group by Asset_Ownership order by Asset_Ownership
SELECT Asset_Ownership, Count(*) FROM FMSSExport where Asset_Ownership not in (select Code from DOM_FACOWNER) group by Asset_Ownership order by Asset_Ownership
-- CLIID
SELECT CLINO, Count(*) FROM FMSSExport group by CLINO order by CLINO
SELECT CLINO, Count(*) FROM FMSSExport where CLINO not in ('', 'NONE', 'N', 'NA', 'N/A') group by CLINO order by CLINO
-- FACMAINTAIN
SELECT FAMARESP, Count(*) FROM FMSSExport group by FAMARESP order by FAMARESP
SELECT FAMARESP, Count(*) FROM FMSSExport  where FAMARESP not in (select Code from DOM_FACOCCUMAINT) group by FAMARESP
SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, count(*) FROM FMSSExport group by FAMARESP order by FAMARESP
-- SEASONAL
SELECT OPSEAS, Count(*) FROM FMSSExport group by OPSEAS order by OPSEAS
SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, count(*) FROM FMSSExport group by OPSEAS order by OPSEAS
-- FACUSE
SELECT PRIMUSE, Count(*) FROM FMSSExport group by PRIMUSE order by PRIMUSE
SELECT PRIMUSE, Count(*) FROM FMSSExport where PRIMUSE not in (select Code from DOM_FACUSE) group by PRIMUSE order by PRIMUSE
-- BLDGCODE
SELECT DOI_Code, Count(*) FROM FMSSExport group by DOI_Code order by doi_code
SELECT DOI_Code, Count(*) FROM FMSSExport where DOI_Code is not null and DOI_Code <> '00000000' group by DOI_Code order by doi_code
SELECT DOI_Code, Count(*) FROM FMSSExport where DOI_Code in (select Code from DOM_BLDGCODETYPE) group by DOI_Code order by doi_code
SELECT DOI_Code, Count(*) FROM FMSSExport where DOI_Code not in (select Code from DOM_BLDGCODETYPE) group by DOI_Code order by doi_code
-- Get Asset List for validation of AssetID
-- Extras
-- BLDGTYPE
SELECT Predominant_Use, Count(*) FROM FMSSExport group by Predominant_Use order by Predominant_Use
SELECT Predominant_Use, Count(*) FROM FMSSExport where Predominant_Use in (select Type from DOM_BLDGCODETYPE) group by Predominant_Use order by Predominant_Use
SELECT Predominant_Use, Count(*) FROM FMSSExport where Predominant_Use not in (select Type from DOM_BLDGCODETYPE) group by Predominant_Use order by Predominant_Use
SELECT DOI_Code, Predominant_Use, Count(*) FROM FMSSExport where Predominant_Use not in (select Type from DOM_BLDGCODETYPE) group by DOI_Code, Predominant_Use order by Predominant_Use
-- BLDGSTATUS
SELECT Status, Count(*) FROM FMSSExport group by Status
SELECT Status, Count(*) FROM FMSSExport where Status not in (select Code from DOM_BLDGSTATUS) group by Status
-- PARKID
SELECT PARKNUMB, Count(*) FROM FMSSExport where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none') group by PARKNUMB

-- *******************************
-- QC CHECKS
-- Error if FACLOCID is in FMSSEXPORT and the FMSS value does not match the GIS value (both must be valid and non null)
-- FACLOCID (No additional checks required)
-- UNITCODE
select p.OBJECTID, 'Error: UNITCODE does not match FMSS.Park' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Park, Location FROM FMSSExport where Park in (select Code from DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT')
-- REGION (No Checks required)
-- FACOCCUPANT
select p.OBJECTID, 'Error: FACOCCUPANT does not match FMSS.Occupant' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Occupant, Location FROM FMSSExport where Occupant in (select Code from DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID where p.FACOCCUPANT <> f.Occupant
-- LCSID (61, largely leading zeros)
select p.OBJECTID, 'Error: LCSID does not match FMSS.CLASSSTR' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (select CLASSSTR, Location FROM FMSSExport where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS')) as f
  on f.Location = p.FACLOCID where p.LCSID <> f.CLASSSTR
-- FACOWNER (1284)
select p.OBJECTID, 'Error: FACOWNER does not match FMSS.Asset_Ownership' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Asset_Ownership, Location FROM FMSSExport where Asset_Ownership in (select Code from DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID where p.FACOWNER <> f.Asset_Ownership
-- CLIID (0)
select p.OBJECTID, 'Error: CLIID does not match FMSS.CLINO' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (select CLINO, Location FROM FMSSExport where CLINO not in ('', 'NONE', 'N', 'NA', 'N/A')) as f
  on f.Location = p.FACLOCID where p.CLIID <> f.CLINO
-- FACMAINTAIN (1378)
select p.OBJECTID, 'Error: FACMAINTAIN does not match FMSS.FAMARESP' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where p.FACMAINTAIN <> f.FAMARESP
-- SEASONAL (0)
select p.OBJECTID, 'Error: SEASONAL does not match FMSS.OPSEAS' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS
-- FACUSE (21 - investigate)
select p.OBJECTID, 'Error: FACUSE does not match FMSS.PRIMUSE' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PRIMUSE, Location FROM FMSSExport where PRIMUSE in (select Code from DOM_FACUSE)) as f
  on f.Location = p.FACLOCID where p.FACUSE <> f.PRIMUSE
-- BLDGCODE (10 - investigate)
select p.OBJECTID, 'Error: BLDGCODE does not match FMSS.DOI_Code' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT DOI_Code, Location FROM FMSSExport where DOI_Code in (select Code from DOM_BLDGCODETYPE)) as f
  on f.Location = p.FACLOCID where p.BLDGCODE <> f.DOI_Code
-- BLDGTYPE (Ignore values in FMSS; we will calc from BLDGCODE)
-- BLDGSTATUS (143)
select p.OBJECTID, 'Error: BLDGSTATUS does not match FMSS.Status' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Status, Location FROM FMSSExport where Status in (select Code from DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where p.BLDGSTATUS <> f.Status
-- PARKBLDGID (145 - investigate)
select p.OBJECTID, 'Error: PARKBLDGID does not match FMSS.PARKNUMB' as Issue from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PARKNUMB, Location FROM FMSSExport where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none')) as f
  on f.Location = p.FACLOCID where p.PARKBLDGID <> f.PARKNUMB


-- *******************************
-- FIXES - ERRORS in Existing Data
-- if FACLOCID is in FMSSEXPORT and the FMSS value does not match the GIS value (both must be valid and non null)
-- UNITCODE (0)
select p.UNITCODE, p.GROUPCODE, f.Park from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Park, Location FROM FMSSExport where Park in (select Code from DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where p.UNITCODE <> f.Park and f.Park = 'WEAR' and p.UNITCODE not in ('CAKR', 'KOVA', 'NOAT') order by p.UNITCODE, f.Park
-- REGION (Ignore FMSS region code value - we ensure it is always AKR; if FMSS says something different it is wrong)
-- FACOCCUPANT (1398)
select p.FACOCCUPANT, f.Occupant from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Occupant, Location FROM FMSSExport where Occupant in (select Code from DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID where p.FACOCCUPANT <> f.Occupant order by p.FACOCCUPANT, f.Occupant
update p set FACOCCUPANT = f.Occupant from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Occupant, Location FROM FMSSExport where Occupant in (select Code from DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID where p.FACOCCUPANT <> f.Occupant
-- LCSID (61, largely leading zeros)
select p.LCSID, f.CLASSSTR from gis.AKR_BLDG_CENTER_PT as p join
  (select CLASSSTR, Location FROM FMSSExport where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS')) as f
  on f.Location = p.FACLOCID where p.LCSID <> f.CLASSSTR order by p.LCSID, f.CLASSSTR
update p set LCSID = f.CLASSSTR from gis.AKR_BLDG_CENTER_PT as p join
  (select CLASSSTR, Location FROM FMSSExport where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS')) as f
  on f.Location = p.FACLOCID where p.LCSID <> f.CLASSSTR
-- FACOWNER (1284)
select p.FACOWNER, f.Asset_Ownership from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Asset_Ownership, Location FROM FMSSExport where Asset_Ownership in (select Code from DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID where p.FACOWNER <> f.Asset_Ownership order by p.FACOWNER, f.Asset_Ownership
update p set FACOWNER = f.Asset_Ownership from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Asset_Ownership, Location FROM FMSSExport where Asset_Ownership in (select Code from DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID where p.FACOWNER <> f.Asset_Ownership
-- CLIID (0)
select p.CLIID, f.CLINO from gis.AKR_BLDG_CENTER_PT as p join
  (select CLINO, Location FROM FMSSExport where CLINO not in ('', 'NONE', 'N', 'NA', 'N/A')) as f
  on f.Location = p.FACLOCID where p.CLIID <> f.CLINO order by p.CLIID, f.CLINO
update p set CLIID = f.CLINO from gis.AKR_BLDG_CENTER_PT as p join
  (select CLINO, Location FROM FMSSExport where CLINO not in ('', 'NONE', 'N', 'NA', 'N/A')) as f
  on f.Location = p.FACLOCID where p.CLIID <> f.CLINO
-- FACMAINTAIN (1378)
select p.FACMAINTAIN, f.FAMARESP from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where p.FACMAINTAIN <> f.FAMARESP order by p.FACMAINTAIN, f.FAMARESP
update p set FACMAINTAIN = f.FAMARESP from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where p.FACMAINTAIN <> f.FAMARESP
-- SEASONAL (0)
select p.SEASONAL, f.OPSEAS from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS order by p.SEASONAL, f.OPSEAS
update p set SEASONAL = f.OPSEAS from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where p.SEASONAL <> f.OPSEAS
-- FACUSE (21 - investigate)
select p.FACUSE, f.PRIMUSE from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PRIMUSE, Location FROM FMSSExport where PRIMUSE in (select Code from DOM_FACUSE)) as f
  on f.Location = p.FACLOCID where p.FACUSE <> f.PRIMUSE order by p.FACUSE, f.PRIMUSE
update p set FACUSE = f.PRIMUSE from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PRIMUSE, Location FROM FMSSExport where PRIMUSE in (select Code from DOM_FACUSE)) as f
  on f.Location = p.FACLOCID where p.FACUSE <> f.PRIMUSE
-- BLDGCODE (10 - investigate)
select p.BLDGCODE, f.DOI_Code from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT DOI_Code, Location FROM FMSSExport where DOI_Code in (select Code from DOM_BLDGCODETYPE)) as f
  on f.Location = p.FACLOCID where p.BLDGCODE <> f.DOI_Code order by p.BLDGCODE, f.DOI_Code
update p set BLDGCODE = f.DOI_Code from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT DOI_Code, Location FROM FMSSExport where DOI_Code in (select Code from DOM_BLDGCODETYPE)) as f
  on f.Location = p.FACLOCID where p.BLDGCODE <> f.DOI_Code
-- BLDGTYPE (Ignore values in FMSS; we will calc from BLDGCODE)
-- BLDGSTATUS (143)
select p.BLDGSTATUS, f.Status from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Status, Location FROM FMSSExport where Status in (select Code from DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where p.BLDGSTATUS <> f.Status order by p.BLDGSTATUS, f.Status
update p set BLDGSTATUS = f.Status from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Status, Location FROM FMSSExport where Status in (select Code from DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where p.BLDGSTATUS <> f.Status
-- PARKBLDGID (145 - investigate)
select p.PARKBLDGID, f.PARKNUMB from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PARKNUMB, Location FROM FMSSExport where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none')) as f
  on f.Location = p.FACLOCID where p.PARKBLDGID <> f.PARKNUMB order by p.PARKBLDGID, f.PARKNUMB
update p set PARKBLDGID = f.PARKNUMB from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PARKNUMB, Location FROM FMSSExport where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none')) as f
  on f.Location = p.FACLOCID where p.PARKBLDGID <> f.PARKNUMB


  -- *******************************
-- FIXES - CALCULATIONS
-- if FACLOCID is in FMSSEXPORT and FMSS has a valid non null value for X and X is null
-- UNITCODE (nothing)
select p.UNITCODE, f.Park from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Park, Location FROM FMSSExport where Park in (select Code from DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where (p.UNITCODE is null and f.Park is not null) order by p.UNITCODE, f.Park
update p set UNITCODE = f.Park from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Park, Location FROM FMSSExport where Park in (select Code from DOM_UNITCODE)) as f
  on f.Location = p.FACLOCID where (p.UNITCODE is null and f.Park is not null)
-- REGION (Ignore FMSS region code value - we ensure it is always AKR; if FMSS says something different it is wrong)
-- FACOCCUPANT (4)
select p.FACOCCUPANT, f.Occupant from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Occupant, Location FROM FMSSExport where Occupant in (select Code from DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID where (p.FACOCCUPANT is null and f.Occupant is not null) order by p.FACOCCUPANT, f.Occupant
update p set FACOCCUPANT = f.Occupant from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Occupant, Location FROM FMSSExport where Occupant in (select Code from DOM_FACOCCUMAINT)) as f
  on f.Location = p.FACLOCID where (p.FACOCCUPANT is null and f.Occupant is not null)
-- LCSID (63)
select p.LCSID, f.CLASSSTR from gis.AKR_BLDG_CENTER_PT as p join
  (select CLASSSTR, Location FROM FMSSExport where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS')) as f
  on f.Location = p.FACLOCID where (p.LCSID is null and f.CLASSSTR is not null) order by p.LCSID, f.CLASSSTR
update p set LCSID = f.CLASSSTR from gis.AKR_BLDG_CENTER_PT as p join
  (select CLASSSTR, Location FROM FMSSExport where CLASSSTR not in ('', 'NONE', 'N', 'NA', 'N/A', 'LCS')) as f
  on f.Location = p.FACLOCID where (p.LCSID is null and f.CLASSSTR is not null)
-- FACOWNER (1)
select p.FACOWNER, f.Asset_Ownership from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Asset_Ownership, Location FROM FMSSExport where Asset_Ownership in (select Code from DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID where (p.FACOWNER is null and f.Asset_Ownership is not null) order by p.FACOWNER, f.Asset_Ownership
update p set FACOWNER = f.Asset_Ownership from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Asset_Ownership, Location FROM FMSSExport where Asset_Ownership in (select Code from DOM_FACOWNER)) as f
  on f.Location = p.FACLOCID where (p.FACOWNER is null and f.Asset_Ownership is not null)
-- CLIID (35)
select p.CLIID, f.CLINO from gis.AKR_BLDG_CENTER_PT as p join
  (select CLINO, Location FROM FMSSExport where CLINO not in ('', 'NONE', 'N', 'NA', 'N/A')) as f
  on f.Location = p.FACLOCID where (p.CLIID is null and f.CLINO is not null) order by p.CLIID, f.CLINO
update p set CLIID = f.CLINO from gis.AKR_BLDG_CENTER_PT as p join
  (select CLINO, Location FROM FMSSExport where CLINO not in ('', 'NONE', 'N', 'NA', 'N/A')) as f
  on f.Location = p.FACLOCID where (p.CLIID is null and f.CLINO is not null)
-- FACMAINTAIN (2)
select p.FACMAINTAIN, f.FAMARESP from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where (p.FACMAINTAIN is null and f.FAMARESP is not null) order by p.FACMAINTAIN, f.FAMARESP
update p set FACMAINTAIN = f.FAMARESP from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when FAMARESP = 'Fed Gov' then 'FEDERAL' when FAMARESP = 'State Gov' then 'STATE'  when FAMARESP = '' then NULL else upper(FAMARESP) end as FAMARESP, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where (p.FACMAINTAIN is null and f.FAMARESP is not null)
-- SEASONAL (1403)
select p.SEASONAL, f.OPSEAS from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where (p.SEASONAL is null and f.OPSEAS is not null) order by p.SEASONAL, f.OPSEAS
update p set SEASONAL = f.OPSEAS from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT case when OPSEAS = 'Y' then 'Yes' when OPSEAS = 'N' then 'No' else 'Unknown' end as OPSEAS, location FROM FMSSExport) as f
  on f.Location = p.FACLOCID where (p.SEASONAL is null and f.OPSEAS is not null)
-- FACUSE (891)
select p.FACUSE, f.PRIMUSE from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PRIMUSE, Location FROM FMSSExport where PRIMUSE in (select Code from DOM_FACUSE)) as f
  on f.Location = p.FACLOCID where (p.FACUSE is null and f.PRIMUSE is not null) order by p.FACUSE, f.PRIMUSE
update p set FACUSE = f.PRIMUSE from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PRIMUSE, Location FROM FMSSExport where PRIMUSE in (select Code from DOM_FACUSE)) as f
  on f.Location = p.FACLOCID where (p.FACUSE is null and f.PRIMUSE is not null)
-- BLDGCODE (1259)
select p.BLDGCODE, f.DOI_Code from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT DOI_Code, Location FROM FMSSExport where DOI_Code in (select Code from DOM_BLDGCODETYPE)) as f
  on f.Location = p.FACLOCID where (p.BLDGCODE is null and f.DOI_Code is not null) order by p.BLDGCODE, f.DOI_Code
update p set BLDGCODE = f.DOI_Code from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT DOI_Code, Location FROM FMSSExport where DOI_Code in (select Code from DOM_BLDGCODETYPE)) as f
  on f.Location = p.FACLOCID where (p.BLDGCODE is null and f.DOI_Code is not null)
-- BLDGTYPE (Ignore values in FMSS; we will calc from BLDGCODE)
-- BLDGSTATUS (0)
select p.BLDGSTATUS, f.Status from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Status, Location FROM FMSSExport where Status in (select Code from DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where (p.BLDGSTATUS is null and f.Status is not null) order by p.BLDGSTATUS, f.Status
update p set BLDGSTATUS = f.Status from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT Status, Location FROM FMSSExport where Status in (select Code from DOM_BLDGSTATUS)) as f
  on f.Location = p.FACLOCID where (p.BLDGSTATUS is null and f.Status is not null)
-- PARKBLDGID (167)
select p.PARKBLDGID, f.PARKNUMB from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PARKNUMB, Location FROM FMSSExport where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none')) as f
  on f.Location = p.FACLOCID where p.PARKBLDGID is null and f.PARKNUMB is not null order by p.PARKBLDGID, f.PARKNUMB
update p set PARKBLDGID = f.PARKNUMB from gis.AKR_BLDG_CENTER_PT as p join
  (SELECT PARKNUMB, Location FROM FMSSExport where PARKNUMB not in ('', 'n', 'n/a', 'na', 'none')) as f
  on f.Location = p.FACLOCID where (p.PARKBLDGID is null and f.PARKNUMB is not null)
