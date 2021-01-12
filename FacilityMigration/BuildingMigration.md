in ArcCatalog
 * ArcToolbox -> Data Management Tools -> Geodatabase Administration -> Create Enterprise Geodatabase
   * this will create the database, and the SDE user
   * See T:\GIS\PROJECTS\AKR\ArcSDE Deployment\Guidance Documents\Create Enterprise Geodatabase.png for details
   * browse to Authorization file (\\inpakrovmXXX\c$\Program Files\ESRI\License<release#>\sysgen
     or \\inpakrovmgis\transfer\keycodes or T:\GIS\PROJECTS\AKR\ArcSDE Deployment\keycodes
in SSMS
 * Create a new database user gis with login gis and schema gis
 * make this user members for th db_datareaders, db_datawriters, and db_ddladmins
in ArcCatalog
 * create a new database connection with GIS
 * right click import multiple.. and copy feature classes from old to new
 * Add/edit permissions (new should be same as old)
 * Enable archiving, versioning, editor tracking on the following feature classes

Create server logins & database users (sde, gis, akr_editor_web, akr_reader_web, nps\Domain Users)
Create windows logins & database users for domain accts (abaltensperger, bjsorbel, jjcusik, jsrose, resarwas, alsouthwould, smdevenny)



Building QC
geometryID is non-null, unique and wellformed for all pts and polys
buildingid is non-null and unique for all "spatial locations", however all point_types and polys that represent a single structure must have the same id
the following attributes must be the same for all buildingids (all point types, polys

Edit building centroids (has all attributes).  Each structure must have one and only one centroid.
A building may have other building points

I Propose AKR_BLDG_pt and AKR_BLDG_py are not editable views build from the following tables
      (could be a table, built whenever posting to default, if view is too slow)
  AKR_BLDG_center_pt     (pointtype == 'Center point')
  AKR_BLDG_other_pt      (pointtype != 'Center point'; not null)
  AKR_BLDG_footprint_py  (polygontype == 'Perimeter polygon')
  AKR_BLDG_other_py      (polygontype != 'Perimeter polygon'; not null)

  AKR_BLDG_center_pt - has all the attributes of AKR_BLDG_pt/py.  These attributes are only in the center_pt feature class, and apply
             to all features that share a common FEATUREID
    bldgname       o (optional free text)
    bldgaltname    o (optional free text)
    maplabel       o (optional free text)
    bldgstatus     * (non-null; domain value) (? if faclocid is not null should 'match' Location.status ?)
    bldgcode       o (if faclocid is non-null then populated from FMSS_Export.LocationSpecTemplate.DOI_Code)
    bldgtype       o (optional domain value)
    facowner       o (if faclocid is non-null then populated from FMSS_Export.Location.AssetOwnership)
    facoccupant    o (if faclocid is non-null then populated from FMSS_Export.Location.Occupant)
    facmaintain    o (if faclocid is non-null then populated from FMSS_Export.LocationSpecTemplate.FAMARESP)
    facuse         o (if faclocid is non-null then populated from FMSS_Export.LocationSpecTemplate.PRIMUSE)
    seasonal       o (if faclocid is non-null then populated from FMSS_Export.LocationSpecTemplate.OPSEAS)
    seasdesc       o (optional free text)
    isextant       * (non-null; domain value;  must be consistent with bldgstatus)
    isoutpark      c (managed by spatial query)
    publicdisplay  * (non-null; domain value; must be consistent with dataaccess)
    dataaccess     * (non-null; domain value; must be consistent with publicdisplay)
    unitcode       * (if faclocid is non-null then populated from FMSS_Export.Location.Park); can be null if groupcode provided
                     (i.e. a building may be in a network but not a park); for buildings not in a park, use nearest park and set isoutpark = Y?
                     What about headquarters? AKRO is not in domain any other odd balls?
    unitname       c (calculated from unitcode)
    groupcode      o (required if unitcode is null; domain values for Alaska?; if unitcode and group code both non-null then they must be related)
                     if null then calc'd from unitcode domain
    groupname      c (calculated from groupname)
    regioncode     c (if faclocid is non-null then populated from FMSS_Export.Location.Region)
    faclocid       o (if non-null must be a valid foreign key to FMSS_Export.Location.Location; generally one-to-one; many-to-one allowed; one-to-many not possible)
    facassetid     o (if non-null must be a valid foreign key to FMSS_Export.Asset.Assetnum; generally one-to-one; many-to-one allowed; one-to-many not possible)
    crid           o (optional guid foreign key to Cultural Resources GIS database)
    asmisis        o (optional foreign key to asmis database)
    cliid          o (if faclocid is non-null then populated from FMSS_Export.LocationSpecTemplate.CLINO)
    lcsid          o (if faclocid is non-null then populated from FMSS_Export.LocationSpecTemplate.CLASSSTR)
    firebldgid     o (optional foreign key to fire database)
    

  AKR_BLDG_*
    objectid           (esri managed)
    createdate/user    (esri managed)
    editdate/user      (esri managed)
    geometryid         (non null, unique, well formed, user can ignore; will be added by SDE if null)
    featureid        * (non null, foreign key to AKR_BLDG_centroid_pt.buildingid, must be managed by user)
    point/poly_type  * (must be non-null; must be in domain; and follow rules above; managed by user)
    shape            * (non null, esri managed, user editable)
    mapmethod        * (non-null; domain value)
    xyaccuracy       * (non-null; domain value)
    iscurrentgeo     * (one and only one 'version' of a feature is yes; maybe delete with history/archive)
    mapsource        * (required free text; i.e. non null and not empty string)
    sourcedate	     o (optional null or valid date managed by user)
    notes            o (nullable free text)
    webuser/comment  o (only expose to web editors ? - revisit with enterprise editing workflow)

    