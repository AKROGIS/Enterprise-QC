Facilities Database Upgrade
===========================

Immediate Todo (Regan, UNO):
----------------------------
* Fix trail qc/calculations: TRLISADMIN should match FMSS.PRIMUSE
* Fix trail qc/calculations: TRLCLASS, TRLSURFACE
* Import photos
* Script to create FGDB
* Rename akr_facility to akr_facility_archive2018 and akr_facility2 to akr_facility
* Check permissions of tables/views - hide all QC only items
* Add metadata where missing (Joel)
* Describe all tables/views without metadata
* Document deviations from data standards
* Test sync with national datasets
* Test/Fix layer files (Julie)
* Send lists of building issues to Scott - on Regan's desktop


Long term Todo (Regan, UNO):
----------------------------
* Automate update of FMSSExport and FMSSExport_Asset
* Calculate/Test closest trail segment to a trail feature
* Feature class gis.AKR_UNIT should be updated from akr_bnd.gis.AKPARKS_UNIT_OUTLINE
  as needed.  Or, update akr_bnd.gis.AKPARKS_UNIT_OUTLINE to use geometry for shape
  instead of SDE binary then we can use it directly in all queries and delete
  gis.AKR_UNIT (check speed)
* Get other missing foreign key data: ASMIS, LCS, CLS, Fire, CR, RIP


Data Quality Improvements (Team):
---------------------------------
* Run calcs and fix QC issues for TRLISADMIN, TRLCLASS, and TRLSURFACE
* Activate two disabled queries in TRAILS_FEATURE_PT, and fix the few remaining issues
* Fixes to Trails for new MAINTAINER QC check
* Add Sheep Camp picnic shelter to buildings from POI
* Convert few remaining Arbitrary line to Center line in roads and trails
* Add operating FMSS Locations to GIS
* Topology checks for roads and trails
* Remove 'Unknown' values for records with ISOUTPARK = 'No' and/or
  PUBLICDISPLAY = 'Public Map Display'
* Fix issues with parking lot areas not matching FMSS
* Fix issues with trail length not matching FMSS
* Fix issues with trail length being too short
* Try and compare Building footprint with FMSS Square footage? - lots of issues
* Connect (by FEATUREID) all roads/trails with the same name
* Fix inconsistencies in trails between ISEXTANT, TRLSTATUS, and TRLFEATTYPE
  - `select TRLFEATTYPE, ISEXTANT, TRLSTATUS, count(*) from gis.TRAILS_LN_evw group by ISEXTANT, TRLSTATUS, TRLFEATTYPE`
* Compare FMSS Description/ParkName with TRLNAME, RDNAME, LOTNAME, BLDGNAME
* TRLFEATTYPE: Compare with FMSS/Status i.e. if it is an existing FMSS trail,
  then it can't be a 'Unofficial Trail' or 'Non-NPS Trail'
  - `select TRLSTATUS, TRLFEATTYPE, count(*) from gis.TRAILS_LN_evw where FACLOCID is not null group by TRLSTATUS, TRLFEATTYPE order by TRLSTATUS, TRLFEATTYPE`
* Compare TRLUSE with FMSS.TRLUSE
  - `select t.TRLUSE, f.TRLUSE from gis.TRAILS_LN_evw as t join FMSSExport as f on t.FACLOCID = f.Location`


Issues to discuss (Team):
-------------------------
(See 'TODO's in [SQL code](https://github.com/regan-sarwas/Building-QC/blob/master/New%20Schema%20Migration/NewViews.sql) for additional details on these issues)
* Define FEATUREID (What is a feature? Can this be a foriegn key?)
* Are there any attributes that should be consistent for all segments of a feature?
* Review UNITCODE QC/calculations: Spatial v. DOM v. FMSS?
* Review GROUPCODE QC/calculations: Spatial (gis.AKR_GROUPS) v. DOM_UNITCODE?
* Review non-standard domain values for FMSS. See Maintainer, Status, Road Class
* Should we standardize the three different maintainer domains
* Should we enforce any requirements on STATUS, ISEXTANT, ISOUTPARK, UNITCODE, FACUSE,
  or others when PUBLICDISPLAY = 'Public Map Display'?
* Should Roads and Trails default to LINETYPE = 'Center line'?  This is an assumption by
  users; what good is 'Arbitrary line'?. Regardless, we should filter for 'Center line' in
  the layer definition query, or create a separate dataset for LINETYPE != 'Center line'
* Review schema changes to TRAILS_LN
  - TRLSTATUS: remove 'Not Applicable' from Domain; consider removing 'Abandoned'
    (use decommissioned instead) to match domain of roads/buildings
  - Renamed: TRLUSE_SOCIALTRL, TRLUSE_ANIMALTRL to TRLISSOCIAL, TRLISANIMAL
  - Removed: TRLUSE_OTHER (Y/N), TRLUSE_UNKNOWN (Y/N)
  - For TRAILS_LN.TRLUSE_* 'Yes' means specifically built for, 'No' means specifically
    prohibited; NULL (default) means this use is unspecified, unknown, or N/A
  - For TRAILS_LN.TRLUSE should we augment the standard by adding AKR uses and prohibitions?
    (review SQL function); We could add new column TRLUSE_AKR
* Review schema changes to TRAILS_FEATURE_PT
  - TRLFEATTYPE is now a text domain and no longer an integer *subtype*, so we cannot
    use different domains for TRLFEATSUBTYPE.  Is this ok?
* Are there illogical combinations of TRLFEATTYPE and TRLIS*?
  - `select TRLFEATTYPE, TRLISADMIN, TRLISSOCIAL, TRLISANIMAL, count(*) from gis.TRAILS_LN_evw group by TRLFEATTYPE, TRLISADMIN, TRLISSOCIAL, TRLISANIMAL`
* Are there illogical combinations of TRLTYPE and TRLUSE_*?
  - `select TRLTYPE, TRLUSE, count(*) from gis.TRAILS_LN_evw group by TRLTYPE, TRLUSE`
